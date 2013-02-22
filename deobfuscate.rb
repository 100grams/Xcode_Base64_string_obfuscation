# This script reverses (deobfuscates) any c-style #define values which have been previously obfuscated by obfuscate.rb in your 'defines_file'
# Run this script _after_ comiling your code/project

# This script is in public domain at https://github.com/100grams/Xcode_Base64_string_obfuscation.git

require 'Base64'

defines_file = 'defines.h'

def remove_deobfuscate_macro(lines)
  index = lines.gsub!(/(\n#define\s+deobfuscate\(exp\).+)\n/, '')
end


# deobfuscate in defines_file

lines = IO.readlines(defines_file).join
target = ""
count = 0
has_deobfuscate_macro = false
lines.each do |line| 
  if line =~/#define\s/ 
    define_name = line.scan(/#define\s+(\w+)/).flatten
    enc_text = line.scan(/#define\s+\w+\s+deobfuscate\((.*)\)/).flatten.first
    if enc_text != nil && enc_text.length > 0
      enc_text += "\n"
      clear_text = Base64.decode64(enc_text) 
      line.gsub!(/(#define\s+\w+\s+)(.+)/, "\\1#{clear_text}")
      count +=1
    end
    has_deobfuscate_macro |= define_name.first =~ /deobfuscate/
  end
  target << line
end

if count > 0
  puts "deobfuscated #{count} strings in #{defines_file}"
  remove_deobfuscate_macro(target) if has_deobfuscate_macro
  File.open(defines_file, 'w') {|f| f.write(target)}
else 
  puts "no obfuscated strings found in #{defines_file}"
end