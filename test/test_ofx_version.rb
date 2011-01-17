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

require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class OFXVersionTest < Test::Unit::TestCase

    def test_creating_from_array
        version = OFX::Version.new([1, 2, 3])
        
        assert_equal OFX::Version.new('1.2.3'), version

        assert_equal 1, version.major
        assert_equal 2, version.minor
        assert_equal 3, version.revision

        assert_equal [1, 2, 3], version.to_a
        assert_equal '1.2.3', version.to_dotted_s
        assert_equal '123', version.to_compact_s
    end

    def test_creating_from_compact_string
        version = OFX::Version.new('123')

        assert_equal OFX::Version.new('1.2.3'), version
        
        assert_equal 1, version.major
        assert_equal 2, version.minor
        assert_equal 3, version.revision

        assert_equal [1, 2, 3], version.to_a
        assert_equal '1.2.3', version.to_dotted_s
        assert_equal '123', version.to_compact_s
    end

    def test_creating_from_dotted_string
        version = OFX::Version.new('1.2.3')

        assert_equal OFX::Version.new([1, 2, 3]), version
        
        assert_equal 1, version.major
        assert_equal 2, version.minor
        assert_equal 3, version.revision

        assert_equal [1, 2, 3], version.to_a
        assert_equal '1.2.3', version.to_dotted_s
        assert_equal '123', version.to_compact_s
    end

    def test_creating_from_number
        version = OFX::Version.new(1)

        assert_equal OFX::Version.new([1, 0, 0]), version
        
        assert_equal 1, version.major
        assert_equal 0, version.minor
        assert_equal 0, version.revision

        assert_equal [1, 0, 0], version.to_a
        assert_equal '1.0.0', version.to_dotted_s
        assert_equal '100', version.to_compact_s
    end

    def test_creating_from_single_character
        version = OFX::Version.new('1')

        assert_equal OFX::Version.new([1, 0, 0]), version
        
        assert_equal 1, version.major
        assert_equal 0, version.minor
        assert_equal 0, version.revision

        assert_equal [1, 0, 0], version.to_a
        assert_equal '1.0.0', version.to_dotted_s
        assert_equal '100', version.to_compact_s
    end

    def test_version_comparisons
        low_version = OFX::Version.new('1.0.0')
        low_revision = OFX::Version.new('1.0.1')
        low_upgrade = OFX::Version.new('1.2.0')
        low_upgrade_patch = OFX::Version.new('1.2.1')
        next_version = OFX::Version.new('2.0.1')
        next_version_patch = OFX::Version.new('2.0.2')
        next_version_revision = OFX::Version.new('2.2.0')

        assert_equal low_version, OFX::Version.new('1.0.0')
        assert_equal low_revision, OFX::Version.new('1.0.1')
        assert_equal low_upgrade, OFX::Version.new('1.2.0')
        assert_equal low_upgrade_patch, OFX::Version.new('1.2.1')
        assert_equal next_version, OFX::Version.new('2.0.1')
        assert_equal next_version_patch, OFX::Version.new('2.0.2')
        assert_equal next_version_revision, OFX::Version.new('2.2.0')

        assert low_version < low_revision
        assert low_revision < low_upgrade
        assert low_upgrade < low_upgrade_patch
        assert low_upgrade_patch < next_version
        assert next_version < next_version_patch
        assert next_version_patch < next_version_revision

        assert low_revision > low_version
        assert low_upgrade > low_revision
        assert low_upgrade_patch > low_upgrade
        assert next_version > low_upgrade_patch
        assert next_version_patch > next_version
        assert next_version_revision > next_version_patch
    end

    def test_version_empty
        assert OFX::Version.new(nil).empty?
        assert OFX::Version.new('').empty?
        assert OFX::Version.new([0, 0, 0]).empty?
        assert OFX::Version.new('000').empty?
        assert OFX::Version.new('0.0.0').empty?
    end
    
    def test_as_hash_key
        hash =
        { OFX::Version.new(1) => 1, 
          OFX::Version.new(2) => 2}
          
        assert_equal 1, hash[OFX::Version.new('1')]
        assert_equal 2, hash[OFX::Version.new('2')]
        assert_equal nil, hash[OFX::Version.new('3')]
    end
end