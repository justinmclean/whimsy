#!/usr/bin/env ruby
PAGETITLE = "Member Meeting Activity Status" # Wvisible:meeting
$LOAD_PATH.unshift '/srv/whimsy/lib'

require 'whimsy/asf'
require 'wunderbar/bootstrap'
require 'date'
require 'json'
require 'tmpdir'
require_relative 'meeting-util'

# produce HTML
_html do
  _head_ do
    _style :system
    _style %{
      div.status, .status form {margin-left: 16px}
      .btn {margin: 4px}
      form {margin-bottom: 1em}
      .transcript {margin: 0 16px}
      .transcript pre {border: none; line-height: 0}
      pre._hilite {background-color: yellow}
      form p {margin-top: 1em}
      textarea {width: 100%; height: 8em}
      textarea:disabled {background-color: #EEEEEE}
    }    
  end
  _body? do
    MEETINGS = ASF::SVN['Meetings']
    attendance = MeetingUtil.get_attendance(MEETINGS)
    latest = MeetingUtil.get_latest(MEETINGS).untaint
    # determine user's name as found in members.txt
    name = ASF::Member.find_text_by_id($USER).to_s.split("\n").first
    matrix = attendance['matrix'][name]
    begin
      tracker = JSON.parse(IO.read(File.join(latest, 'non-participants.json')))
    rescue Errno::ENOENT => err
      # Fallback to reading previous meeting's data
      tracker = JSON.parse(IO.read(File.join(MeetingUtil.get_previous(MEETINGS).untaint, 'non-participants.json')))
    end
    # defaults for active users
    tracker[$USER] ||= {
      'missed' => 0,
      'status' => 'active - attended meetings recently'
    }
    active = (tracker[$USER]['missed'] == 0)
    _whimsy_body(
      title: PAGETITLE,
      subtitle: active ? 'Your Attendance Status' : 'Poll Of Inactive Members',
      relatedtitle: 'More About Meetings',
      related: {
        'https://www.apache.org/foundation/governance/meetings' => 'How Meetings & Voting Works',
        '/members/proxy' => 'Assign A Proxy For Next Meeting',
        '/members/non-participants' => 'Members Not Participating',
        'https://svn.apache.org/repos/private/foundation/members.txt' => 'See Official Members.txt File',
        MeetingUtil::RECORDS => 'Official Past Meeting Records'
      },
      helpblock: -> {
        _p do
          _ "This page shows your attendance record at past Member's meetings."
          _ %{
            It is also a poll of members who have not participated in
            ASF Members Meetings or Elections in the past three years, and 
            if you have been inactive, asks you if you wish to remain active or go emeritus.  Inactive members can
            indicate their choice by pushing one of the buttons below.
          }
        end
      }
    ) do

      _p_ do
        _span "#{name}, your current meeting attendance status is: "
        _code tracker[$USER]['status']
      end
      if active
        att = miss = 0
        matrix.each do |date, status|
          if %w(A V P).include? status
            att += 1
          else
            miss += 1
          end
        end
        _p.text_success "Great! Thanks for attending Member's meetings recently! Overall attends: #{att} Non-attends: #{miss}"
      end

      if not active
        _p.alert.alert_warning "Dear #{name}, You have missed the last " + 
          tracker[$USER]['missed'].to_s + " meetings."

        if _.post? and @status
          _h3_ 'Session Transcript'

          # setup authentication
          if $PASSWORD
            auth = [['--username', $USER, '--password', $PASSWORD]]
          else
            auth = [[]]
          end

          # apply and commit changes
          Dir.mktmpdir do |dir|
            _div_.transcript do
              work = `svn info #{latest}`[/URL: (.*)/, 1]
              _.system ['svn', 'checkout', auth, '--depth', 'empty', work, dir]
              json = File.join(dir, 'non-participants.json')
              _.system ['svn', 'update', auth, json]
              tracker = JSON.parse(IO.read(json))
              tracker[$USER]['status'] = @status
              tracker[$USER]['status'] = @suggestions
              IO.write(json, JSON.pretty_generate(tracker))
              _.system ['svn', 'diff', json], hilite: [/"status":/],
                class: {hilight: '_stdout _hilite'}
              _.system ['svn', 'commit', auth, json, '-m', @status]
            end
          end
        end
        
        _div.status do
          _form method: 'post' do
            _p %{
              Please let us know how the ASF could make it easier
              for you to participate in Member's Meetings:
            }

            _textarea name: 'suggestions', disabled: active

            _p 'Update your status (if you are inactive):'
            _button.btn.btn_success 'I wish to remain active',
              name: 'status', value: 'remain active',
              disabled: active or tracker[$USER]['status'] == 'remain active'
            _button.btn.btn_warning 'I would like to go emeritus',
              name: 'status', value: 'go emeritus',
              disabled: active or tracker[$USER]['status'] == 'go emeritus'
          end

          _p_ %{
            If you haven't attended or voted in meetings recently, please consider participating, at
            least by proxy, in the upcoming membership meeting.  See the links
            above for more information.
          }
        end
      end

      _h1_ 'Your Attendance history', id: 'attendance'
      if not name
        _p.alert.alert_danger "#{$USER} not found in members.txt"
      elsif not matrix
        _p.alert.alert_danger "#{name} not found in attendance matrix"
      else
        _table.table.table_sm style: 'margin: 0 24px; width: auto' do
          _thead do
            _tr do
              _th 'Date'
              _th 'Status'
            end
          end
          matrix.sort.reverse.each do |date, status|
            next if status == ' '
            color = 'bg-danger'
            color = 'bg-warning' if %w(e).include? status
            color = 'bg-success' if %w(A V P).include? status
            _tr_ class: color do
              _td do
                _a date, href:
                  'https://svn.apache.org/repos/private/foundation/Meetings/' + date
              end
              case status
              when 'A'
                _td 'Attended'
              when 'V'
                _td 'Voted but did not attend'
              when 'P'
                _td 'Attended via proxy'
              when '-'
                _td 'Did not attend'
              when 'e' 
                _td 'Went emeritus'
              else
                _td status
              end
            end
          end
        end
      end
    end
  end
end
