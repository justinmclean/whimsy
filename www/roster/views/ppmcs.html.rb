#
# List of podlings
#

_html do
  _base href: '..'
  _link rel: 'stylesheet', href: "stylesheets/app.css?#{cssmtime}"
  _body? do
    _whimsy_body(
      title: 'ASF Podling List',
      breadcrumbs: {
        roster: '.',
        ppmc: 'ppmc/'
      }
    ) do
      _p 'A listing of all Podling Project Management Committees (PPMCs) from the Apache Incubator.'

      _p do
        _ 'Click on column names to sort.'
        _{"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"}
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ".each_char do |c|
          _a c, href: "ppmc/##{c}"
        end
      end

      _table.table.table_hover do
        _thead do
          _tr do
            _th.sorting_asc 'Name', data_sort: 'string-ins'
            _th 'Established', data_sort: 'string'
            _th 'Description', data_sort: 'string'
          end
        end

        project_names = @projects.map {|project| project.name}
        prev_letter=nil
        @ppmcs.sort_by {|ppmc| ppmc.display_name.downcase}.each do |ppmc|
          letter = ppmc.display_name.upcase[0]
          if letter != prev_letter
            options = {id: letter}
          else
            options = {}
          end
          prev_letter = letter
          _tr_ options do
            _td do
              if project_names.include? ppmc.name
                _a ppmc.display_name, href: "ppmc/#{ppmc.name}"
              else
                _a.label_danger ppmc.display_name, href: "ppmc/#{ppmc.name}"
              end
            end

            _td ppmc.startdate

            _td do
              # using _p here messes up the sort
              if project_names.include? ppmc.name
                _ ppmc.description
              else
                _ ppmc.description + " (not in ldap)"
              end
            end
          end
        end
      end
    end
    _script %{
      $(".table").stupidtable();
    }
  end
end
