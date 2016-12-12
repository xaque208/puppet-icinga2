# == Helper function attributes
#
<<<<<<< HEAD
# Returns formatted attributes for objects as string.
=======
# Returns formatted attributes for objects as strings.
>>>>>>> master
#
# === Common Explanation:
#
# To generate a valid Icinga 2 configuration all object attributes are parsed. This
<<<<<<< HEAD
# simple parsing make a decision if a part of string is to be quoted, how an array
# or dictionary is to be formatted.
#
# An array, a hash or string can assign to an object attribute. Also true and false
# are valid values.
#
# Hashes and arrays are created recursively and all parts like single items of an array,
# keys and its value are parsed separateted as strings.
#
# Strings will parsed by splitting off in parts of strings by some keywords (operators)
# like +, -, in, &&, ||, etc.
#
# NOTICE: Works only by using a white space before and after the keyword!!!
#
#   attr => 'string1 + string2 - string3'
#
# first will split in 'string1' and 'string2 + string2', 'string1' will give to
# sub function 'value_types' and the second string will be parsed again.
=======
# simple parsing algorithm takes a decision for each attribute, whether part of the
# string is to be quoted or not, and how an array or dictionary is to be formatted.
#
# An array, a hash or a string can be assigned to an object attribute. True and false
# are also valid values.
#
# Hashes and arrays are created recursively, and all parts – such as single items of an array,
# keys and its values – are parsed separately as strings.
#
# Strings are parsed in chunks, by splitting the original string into separate substrings
# at specific keywords (operators) such as +, -, in, &&, ||, etc.
#
# NOTICE: This splitting only works for keywords that are surrounded by whitespace, e.g.:
#
#   attr => 'string1 + string2 - string3'
#
# The algorithm will loop over the parameter and start by splitting it into 'string1' and 'string2 - string3'.
# 'string1' will be passed to the sub function 'value_types' and then the algorithm will continue parsing
# the rest of the string ('string2 - string3'), splitting it, passing it to value_types, etc.
>>>>>>> master
#
# Brackets are parsed for expressions:
#
#   attr => '3 * (value1 - value2) / 2'
#
<<<<<<< HEAD
# The parser also detect function calls and will parse all parameters separately.
#
#   attr => 'function(param1, param2, ...)'
#
# True and false can be used as boolean or string.
#
#   attrs => true or  attr => 'true'
#
# In Icinga you can write your own functions. For puppet use:
#
#   attrs => '{{ ... }}'
#
#   attrs => 'fct(a,b) use (c) { ... }'
#
# The individual parts of functions aren't parsed.
#
# IMPORTANT: The parser calculates which parts of a string has to quoted and which not.
#
# All fragments are quoted expect the following:
=======
# The parser also detects function calls and will parse all parameters separately.
#
#   attr => 'function(param1, param2, ...)'
#
# True and false can be used as either booleans or strings.
#
#   attrs => true or  attr => 'true'
#
# In Icinga you can write your own lambda functions with {{ ... }}. For puppet use:
#
#   attrs => '{{ ... }}'
#
# The parser analyzes which parts of the string have to be quoted and which do not.
#
# As a general rule, all fragments are quoted except for the following:
>>>>>>> master
#
#   - boolean: true, false
#   - numbers: 3 or 2.5
#   - time intervals: 3m or 2.5h  (s = seconds, m = minutes, h = hours, d = days)
<<<<<<< HEAD
#   - functions: {{ ... }}
#   - all constants are declared in parameter constants of main class icinga2:
#       NodeName
#   - names of attributes that belong to the same type of object:
#       name, check_command (host object)
#   - all attributes or variables (custom attributes) from host, service or user context:
=======
#   - functions: {{ ... }} or function () {}
#   - all constants, which are declared in the constants parameter in main class icinga2:
#       NodeName
#   - names of attributes that belong to the same type of object:
#       e.g. name and check_command for a host object
#   - all attributes or variables (custom attributes) from the host, service or user contexts:
>>>>>>> master
#       host.name, service.check_command, user.groups, ...
#
# === What isn't supported?
#
<<<<<<< HEAD
# It's not possible to use arrays or dictionaries in a string, like
#
#   attr => 'array1 + [ item1, item2, ... ]'
#
=======
# It's not currently possible to use arrays or dictionaries in a string, like
#
#   attr => 'array1 + [ item1, item2, ... ]'
#
# Assignments other than simple attribution are not currently possible either, e.g. building something like
#
#   vars += config
#
>>>>>>> master
# === Authors
#
# Icinga Development Team <info@icinga.org>
#
require 'puppet'

module Puppet
  module Icinga2
    module Utils

      def self.attributes(attrs, consts, indent=2)

        def self.value_types(value)
          if value =~ /^\d+\.?\d*[dhms]?$/ || value =~ /^(true|false)$/
            result = value
          else
            if $constants.include?(value) || value =~ /^!?(host|service|user)\./ || value =~ /^\{{2}.*\}{2}$/
              result = value
            else
              result = "\"#{value}\""
            end
          end

          return result
        end


        def self.attribute_types(attr)
          if attr =~ /^[a-zA-Z0-9_]+$/
            result = attr
          else
            result = "\"#{attr}\""
          end

          return result
        end


        def self.parse(row)
          result = ''

          if row =~ /^(?:.+)\((.*)\)\s*use\s*\((.*)\)\s*{(.*)}$/
            result += "function(%s) use (%s) { %s }" % [ $1.split(',').map {|x| parse(x.lstrip)}.join(', '), $2.strip, $3.strip ]
          elsif row =~ /^(.+)\s([\+-]|\*|\/|==|!=|&&|\|{2}|in)\s(.+)$/
            result += "%s %s %s" % [ parse($1), $2, parse($3) ]
          else
<<<<<<< HEAD
            result += case row
              #when /^(?:.+)\((.*)\)\s*use\s*\((.*)\)\s*{(.*)}$/ then
              #  "function (%s) use (%s) { %s }" % [ $1.split(',').map {|x| parse(x.lstrip)}.join(', '), $2.strip, $3.strip ]
              when /^(.+)\((.*)$/ then
                "%s(%s" % [ $1, $2.split(',').map {|x| parse(x.lstrip)}.join(', ') ]
              when /^(.*)\)$/ then
                "%s)" % [ $1.split(',').map {|x| parse(x.lstrip)}.join(', ') ]
              when /^\((.*)$/ then
                 "(%s" % [ parse($1) ]
              else
                 value_types(row.to_s)
              end
=======
            if row =~ /^(.+)\((.*)$/
              result += "%s(%s" % [ $1, $2.split(',').map {|x| parse(x.lstrip)}.join(', ') ]
            elsif row =~ /^(.*)\)$/
              result += "%s)" % [ $1.split(',').map {|x| parse(x.lstrip)}.join(', ') ]
            elsif row =~ /^\((.*)$/
              result += "(%s" % [ parse($1) ]
            else
              result += value_types(row.to_s)
            end
>>>>>>> master
          end

          return result.gsub(/" in "/, ' in ')
        end


        def self.process_array(items, indent=2)
          result = ''

          items.each do |value|
            if value.is_a?(Hash)
              result += "\n%s{\n%s%s}, " % [ ' ' * indent, process_hash(value, indent + 2), ' ' * indent ]
            elsif value.is_a?(Array)
              result += "[ %s], " % [ process_array(value, indent+2) ]
            else
              result += "%s, " % [ parse(value) ] if value != :undef
            end
          end

          return result
        end


        def self.process_hash(attrs, indent=2, level=3, prefix=' '*indent)
          result = ''

          attrs.each do |attr, value|
            if value.is_a?(Hash)
              result += case level
                when 1 then process_hash(value, indent, 2, "%s%s" % [ prefix, attr ])
                when 2 then "%s[\"%s\"] = {\n%s%s}\n" % [ prefix, attr, process_hash(value, indent), ' ' * (indent-2) ]
                else "%s%s = {\n%s%s}\n" % [ prefix, attribute_types(attr), process_hash(value, indent+2), ' ' * indent ]
              end
            elsif value.is_a?(Array)
              result += "%s%s = [ %s]\n" % [ prefix, attribute_types(attr), process_array(value) ]
            else
              if level > 1
                if level == 3
                  result += "%s%s = %s\n" % [ prefix, attribute_types(attr), parse(value) ] if value != :undef
                else
                  result += "%s[\"%s\"] = %s\n" % [ prefix, attribute_types(attr), parse(value) ] if value != :undef
                end
              else
                result += "%s%s = %s\n" % [ prefix, attr, parse(value) ] if value != :undef
              end
            end
          end

          return result
        end


        # globals (params.pp) and all keys of attrs hash itselfs must not quoted
        $constants = consts.concat(attrs.keys) << "name"
        # also with added not operetor '!'
        $constants += $constants.map {|x| "!#{x}"}

        # initialize returned configuration
        config = ''

        attrs.each do |attr, value|
          if attr =~ /^(assign|ignore) where$/
            value.each do |x|
              config += "%s%s %s\n" % [ ' ' * indent, attr, parse(x) ]
            end
          else
            if value.is_a?(Hash)
              if ['vars'].include?(attr)
                config += process_hash(value, indent+2, 1, "%s%s." % [ ' ' * indent, attr])
              else
                config += "%s%s = {\n%s%s}\n" % [ ' ' * indent, attr, process_hash(value, indent+2), ' ' * indent ]
              end
            elsif value.is_a?(Array)
              config += "%s%s = [ %s]\n" % [ ' ' * indent, attr, process_array(value) ]
            else
              config += "%s%s = %s\n" % [ ' ' * indent, attr, parse(value) ] if value != :undef
            end
          end
        end

        return config
      end

    end
  end
end
