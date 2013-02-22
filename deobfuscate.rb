require 'Base64'

defines_file = 'defines.h'

# deobfuscate in defines_file

lines = IO.readlines(defines_file).join
target = ""
count = 0
lines.each do |line| 
  if line =~/#define\s/ 
    enc_text = line.scan(/#define\s+\w+\s+deobfuscate\((.*)\)/).flatten.first
    if enc_text != nil && enc_text.length > 0
      enc_text += "\n"
      clear_text = Base64.decode64(enc_text) 
      line.gsub!(/(#define\s+\w+\s+)(.+)/, "\\1#{clear_text}")
      puts "line #{line}"
      count +=1
    end
  end
  target << line
end

if count > 0
  puts "deobfuscated #{count} strings in #{defines_file}"
  File.open(defines_file, 'w') {|f| f.write(target)}
else 
  puts "no obfuscated strings found in #{defines_file}"
end