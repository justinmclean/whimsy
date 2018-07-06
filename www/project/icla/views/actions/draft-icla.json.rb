#
# Creates the draft ICLA form
#

# Called from forms.js.rb POST
# expects the following variables to be set:
# @address
# @apacheid
# @country
# @email
# @fullname
# @publicname
# @pmc
# @telephone

# returns the following keys:
# error
# focus
# ipadddr
# draft

if not @apacheid.empty?
  inuse = @apacheid.split(/ +/).select{|id| ASF::Person.find(id).icla?}.join(' ')
  if inuse != ''
    _error "Apache ID(s) '#{inuse}' already in use"
    _focus :apacheId
  return
  end
end

# capture (possibly forwarded) remote IP address
_ipaddr env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']

# get today's date
require 'date'
today = Date.today.iso8601

# split address into lines, enforcing a minimum of two lines
address = @address.strip.lines.to_a
while address.length < 2
  address.push ''
end

pmc = ASF::Committee.find(@pmc)

# produce draft
_draft <<-EOF
                    The Apache Software Foundation
     Individual Contributor License Agreement ("Agreement") V2.0
                   http://www.apache.org/licenses/

Thank you for your interest in The Apache Software Foundation (the
"Foundation"). In order to clarify the intellectual property license
granted with Contributions from any person or entity, the Foundation
must have a Contributor License Agreement ("CLA") on file that has
been signed by each Contributor, indicating agreement to the license
terms below. This license is for your protection as a Contributor as
well as the protection of the Foundation and its users; it does not
change your rights to use your own Contributions for any other purpose.
If you have not already done so, please complete and sign, then scan
and email a pdf file of this Agreement to secretary@apache.org.
Alternatively, you may send it by facsimile to the Foundation at
+1-919-573-9199. If necessary, send an original signed Agreement to
The Apache Software Foundation, Dept. 9660, Los Angeles,
CA 90084-9660, U.S.A. Please read this document carefully before
signing and keep a copy for your records.

  Full name: #{@fullname.ljust(54, '_')}

  (optional) Public name: #{@publicname.ljust(41, '_')}

  Postal Address: #{address.map {|line| line.strip.ljust(48, '_')}.
    join("\n\n                   ")}

  Country:   #{@country.ljust(54, '_')}

  Telephone: #{@telephone.ljust(54, '_')}

  E-Mail:    #{@email.ljust(54, '_')}

  (optional) preferred Apache id(s): #{@apacheid.ljust(30, '_')}

  (optional) notify project: #{pmc.display_name.ljust(38, '_')}

You accept and agree to the following terms and conditions for Your
present and future Contributions submitted to the Foundation. In
return, the Foundation shall not use Your Contributions in a way that
is contrary to the public benefit or inconsistent with its nonprofit
status and bylaws in effect at the time of the Contribution. Except
for the license granted herein to the Foundation and recipients of
software distributed by the Foundation, You reserve all right, title,
and interest in and to Your Contributions.

1. Definitions.

   "You" (or "Your") shall mean the copyright owner or legal entity
   authorized by the copyright owner that is making this Agreement
   with the Foundation. For legal entities, the entity making a
   Contribution and all other entities that control, are controlled
   by, or are under common control with that entity are considered to
   be a single Contributor. For the purposes of this definition,
   "control" means (i) the power, direct or indirect, to cause the
   direction or management of such entity, whether by contract or
   otherwise, or (ii) ownership of fifty percent (50%) or more of the
   outstanding shares, or (iii) beneficial ownership of such entity.

   "Contribution" shall mean any original work of authorship,
   including any modifications or additions to an existing work, that
   is intentionally submitted by You to the Foundation for inclusion
   in, or documentation of, any of the products owned or managed by
   the Foundation (the "Work"). For the purposes of this definition,
   "submitted" means any form of electronic, verbal, or written
   communication sent to the Foundation or its representatives,
   including but not limited to communication on electronic mailing
   lists, source code control systems, and issue tracking systems that
   are managed by, or on behalf of, the Foundation for the purpose of
   discussing and improving the Work, but excluding communication that
   is conspicuously marked or otherwise designated in writing by You
   as "Not a Contribution."

2. Grant of Copyright License. Subject to the terms and conditions of
   this Agreement, You hereby grant to the Foundation and to
   recipients of software distributed by the Foundation a perpetual,
   worldwide, non-exclusive, no-charge, royalty-free, irrevocable
   copyright license to reproduce, prepare derivative works of,
   publicly display, publicly perform, sublicense, and distribute Your
   Contributions and such derivative works.

3. Grant of Patent License. Subject to the terms and conditions of
   this Agreement, You hereby grant to the Foundation and to
   recipients of software distributed by the Foundation a perpetual,
   worldwide, non-exclusive, no-charge, royalty-free, irrevocable
   (except as stated in this section) patent license to make, have
   made, use, offer to sell, sell, import, and otherwise transfer the
   Work, where such license applies only to those patent claims
   licensable by You that are necessarily infringed by Your
   Contribution(s) alone or by combination of Your Contribution(s)
   with the Work to which such Contribution(s) was submitted. If any
   entity institutes patent litigation against You or any other entity
   (including a cross-claim or counterclaim in a lawsuit) alleging
   that your Contribution, or the Work to which you have contributed,
   constitutes direct or contributory patent infringement, then any
   patent licenses granted to that entity under this Agreement for
   that Contribution or Work shall terminate as of the date such
   litigation is filed.

4. You represent that you are legally entitled to grant the above
   license. If your employer(s) has rights to intellectual property
   that you create that includes your Contributions, you represent
   that you have received permission to make Contributions on behalf
   of that employer, that your employer has waived such rights for
   your Contributions to the Foundation, or that your employer has
   executed a separate Corporate CLA with the Foundation.

5. You represent that each of Your Contributions is Your original
   creation (see section 7 for submissions on behalf of others).  You
   represent that Your Contribution submissions include complete
   details of any third-party license or other restriction (including,
   but not limited to, related patents and trademarks) of which you
   are personally aware and which are associated with any part of Your
   Contributions.

6. You are not expected to provide support for Your Contributions,
   except to the extent You desire to provide support. You may provide
   support for free, for a fee, or not at all. Unless required by
   applicable law or agreed to in writing, You provide Your
   Contributions on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
   OF ANY KIND, either express or implied, including, without
   limitation, any warranties or conditions of TITLE, NON-
   INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.

7. Should You wish to submit work that is not Your original creation,
   You may submit it to the Foundation separately from any
   Contribution, identifying the complete details of its source and of
   any license or other restriction (including, but not limited to,
   related patents, trademarks, and license agreements) of which you
   are personally aware, and conspicuously marking the work as
   "Submitted on behalf of a third-party: [named here]".

8. You agree to notify the Foundation of any facts or circumstances of
   which you become aware that would make these representations
   inaccurate in any respect.

Please sign: #{@fullname.ljust(34, '_')} Date: #{today.ljust(16, '_')}
EOF
