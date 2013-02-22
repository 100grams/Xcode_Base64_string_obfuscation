#!/usr/bin/ruby
#
# This script obfuscates c-style #define values in your 'defines_file'
# Run this script _before_ comiling your code/project
# Make sure to also run deobfuscate.rb after the build, to revert the obfuscation in 'defines_file'
#
# This script is in public domain at https://github.com/100grams/Xcode_Base64_string_obfuscation.git
 
require 'Base64'

defines_file = 'defines.h'

def add_deobfuscate_macro(lines)
  index = lines.rindex(/(\s+)#endif/)
  lines.insert(index, "\n#define deobfuscate(exp) \[NSString stringWithBase64EncodedString:\[NSString stringWithFormat:\@\"%\@\\n\", exp\]\]\n")
end


# obfuscate string literals in defines_file

lines = IO.readlines(defines_file).join
has_deobfuscate_macro = false
target = ""
count = 0
lines.each do |line| 
  if line =~/#define\s/ 
    clear_text = line.scan(/#define\s+\w+\s+@"(.*)"/).flatten
    define_name = line.scan(/#define\s+(\w+)/).flatten
    if define_name.first !=~ /deobfuscate/ && clear_text.first !=nil && clear_text.first.length > 0
      break if clear_text.first =~ /deobfuscate/
      enc_text = Base64.encode64(clear_text.first)
      enc_text.delete! "\n"
      line.gsub!(/(#define\s+\w+\s+)(@".+")/, "\\1deobfuscate(\@\"#{enc_text}\")")
      count +=1      
    end
    has_deobfuscate_macro |= define_name.first =~ /deobfuscate/
  end
  target << line
end

if count > 0
  puts "obfuscated #{count} strings in #{defines_file}"
  add_deobfuscate_macro(target) if !has_deobfuscate_macro
  File.open(defines_file, 'w') {|f| f.write(target)}
else 
  puts "no new strings to obfuscate in #{defines_file}"
end
 
 
