

file1 = ARGV[0] # old
file2 = ARGV[1] # new

str1 = open(file1).read
str2 = open(file2).read

buff1 = {}
buff2 = {}
str1.each_line do |line|
  line.chomp!
  buff1[line] = true
end

puts "追加リスト (#{file1} -> #{file2})"
puts '----------'
str2.each_line do |line|
  line.chomp!
  if buff1[line]!=true
    puts line
  end
  buff2[line] = true
end

puts
puts "削除リスト (#{file1} -> #{file2})"
puts '----------'
str1.each_line do |line|
  line.chomp!
  if buff2[line]!=true
    puts line
  end
end

