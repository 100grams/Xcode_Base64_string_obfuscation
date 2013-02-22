require 'Base64'

defines_file = 'defines.h'

# obfuscate string literals in defines_file

lines = IO.readlines(defines_file).join
target = ""
count = 0
lines.each do |line| 
  if line =~/#define\s/ 
    clear_text = line.scan(/#define\s+\w+\s+(.*)/).flatten
    if clear_text.first !=nil && clear_text.first.length > 0
      break if clear_text.first =~ /deobfuscate/
      enc_text = Base64.encode64(clear_text.first) #cipher.update(clear_text.first) + cipher.final
      enc_text.delete! "\n"
      line.gsub!(/(#define\s+\w+\s+)(.+)/, "\\1deobfuscate(#{enc_text})")
      puts "line #{line}"
      count +=1
    end
  end
  target << line
end

if count > 0
  puts "obfuscated #{count} strings in #{defines_file}"
  File.open(defines_file, 'w') {|f| f.write(target)}
else 
  puts "no new strings to obfuscate in #{defines_file}"
end
 
 
