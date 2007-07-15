# Copyright © 2007 Chris Guidry <chrisguidry@gmail.com>
#
# This file is part of OFX for Ruby.
# 
# OFX for Ruby is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# OFX for Ruby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module OFX
module OFX102
class Parser
option

macro
  TAG_IN        \<
  TAG_OUT       \>
  ETAG_IN       \<\/

rule

# [:state]  	pattern  						[actions]
                {ETAG_IN}               		{ state = :TAG; [:etag_in, text] }
                {TAG_IN}                		{ state = :TAG; [:tag_in, text] }

  :TAG          {TAG_OUT}               		{ state = nil;  [:tag_out, text] }
 
  :TAG          [\w\-\.]+              			{               [:element, text] }

				
                \s+(?=\S)
                .*?(?=({TAG_IN}|{ETAG_IN})+?)  	{               [:text, text] }
                .*\S(?=\s*$)            		{               [:text, text] }
                \s+(?=$)

inner

end

end # module OFX102
end # module OFX

=begin
if __FILE__ == $0
  exit  if ARGV.size != 1
  filename = ARGV.shift
  rex = OFX::OFX102::Parser.new
  begin
    rex.load_file  filename
    while  token = rex.next_token
      p token
    end
  rescue
    $stderr.printf  "%s:%d:%s\n", rex.filename, rex.lineno, $!.message
  end
end
=end
