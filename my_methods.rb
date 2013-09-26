module My_methods

	def self.multi2multi(input_file,output_file,direction=0,seperator=/\t/)
		a2b = {}
		if direction == 1
			a = 1
			b = 0
		elsif direction == 0
			a = 0
			b = 1
		else 
			raise ArugmentError, "invalid direction"
		end
		File.open(output_file,"w") do |fout|
			File.open(input_file).each do |line|
				tmp = line.chomp.split(seperator)
				if a2b.has_key?(tmp[a])
					a2b[tmp[a]] += "\t#{tmp[b]}"
				else
					a2b[tmp[a]] = tmp[a]+"\t"+tmp[b]
				end
			end
			a2b.each { |k,v| fout.puts v }
		end
	end
	
	def self.map_id(input_file,output_file,reference_file,column=1,description="null description",seperator=/\t/)
		if column == -1
			puts "note:","1.the first word of each line should be an item, and the following are genes.","2.each line must not contain redundant genes!";
			reference = {}
			File.open(reference_file).each do |line|
				if	reference.has_key?(line.chomp)
					puts "redundant ID #{line.chomp} in your reference list!"
				else
					reference[line.chomp] = line.chomp
				end
			end
			File.open(input_file).each do |line|
				reference.each_key { |k| reference[k] += "\t" }
				tmp = line.chomp.split(seperator)
				item = tmp.shift
				tmp.uniq.each { |element| reference[element] += item if reference.has_key?(element) }
			end
			File.open(output_file,"w") do |fout|
				File.open(reference_file).each do |line|
					fout.puts reference[line.chomp]
				end
			end
			return nil
		end
		
		puts "note:","1.which seperator?","2.which column you want to map?","or,what description do you want to map?"
		index = {}
		File.open(input_file).each do |line|
			tmp = line.chomp.split(seperator)
			if index.has_key?(tmp[0])
				puts "watch out: redundant #{tmp[0]}"
			else 
				column == 0 ? index[tmp[0]] = description : index[tmp[0]] = tmp[column]
			end
		end
		File.open(output_file,"w") do |fout|
			File.open(reference_file).each do |line|
				if index.has_key?(line.chomp)
					fout.puts line.chomp+"\t"+index[line.chomp]
				else 
					fout.puts line.chomp
				end
			end
		end
	end
	
	def self.hitting_times(input_file,output_file,colname=true,rowname=true,seperator=/\t/)
		ht = {}
		File.open(input_file).each do |line|
			if colname == true
				colname = false
				next
			end
			tmp = []
			if rowname == true
				tmp = line.chomp.split(seperator).drop(1)
			else
				tmp = line.chomp.split(seperator)
			end
			tmp.each do |element|
				if ht.has_key?(element)
					ht[element] += 1
				else
					ht[element] = 1
				end
			end
		end
		File.open(output_file,"w") do |fout|
			ht.sort_by{ |k,v| 0-v }.each{ |k,v| fout.puts k.to_s+"\t"+k.to_s.entrez2symbol+"\t"+v.to_s }
		end
	end
	
	def self.sub_matrix(input_file,output_file,row_index_file,col_index_file="",header=true)
		row_index = {}
		File.open(row_index_file).each { |line| row_index[line.chomp] = 1 }
		col_index = []
		File.open(output_file,"w") do |fout|
			File.open(input_file).each do |line|
				if header == true
					tmp = line.chomp.split(/\t/).delete_if{ |element| element == ""}
					if col_index_file == ""
						tmp.size.times { |x| col_index.push(x) }
					else
						File.open(col_index_file).each { |line| col_index.push(tmp.index(line.chomp)) if tmp.index(line.chomp)!=nil }
					end
					header = false
					tmp_1 = ""
					col_index.each { |ci| tmp_1 = tmp_1+"\t"+tmp[ci] }
					fout.puts tmp_1
					next
				end
				tmp = line.chomp.split(/\t/)
				if row_index.has_key?(tmp[0])
					tmp_1 = tmp[0]
					col_index.each { |ci| tmp_1 = tmp_1+"\t"+tmp[ci+1] }
					fout.puts tmp_1
				end
			end
		end
	end
	
	def self.transpose(input_file,output_file,seperator=/\t/)
		matrix = []
		File.open(output_file,"w") do |fout|
			indicator = 1
			File.open(input_file).each do |line|
				if indicator == 1
					line.chomp.split(seperator).each { |element| matrix.push([element]) }
					indicator = 0
				else
					tmp = line.chomp.split(seperator)
					0.upto(matrix.size-1) do |i|
						matrix[i].push(tmp[i])
					end
				end
			end
			matrix.each { |element| fout.puts element.join("\t") }
		end
	end
	
	def self.set_method(input_file_1,input_file_2,output_file,type="intersection")
		index_1 = {}
		File.open(input_file_1).each { |line| index_1[line.chomp] = 1 }
		index_2 = {}
		File.open(input_file_2).each { |line| index_2[line.chomp] = 1 }	
		File.open(output_file,"w") do |fout|
			case type
				when "intersection"
					index_1.each { |k,v| fout.puts k if index_2.has_key?(k) }
				when "union"
					index_1.each { |k,v| index_2[k] = 1 unless index_2.has_key?(k) }
					index_2.each { |k,v| fout.puts k }
				else
			end
		end
	end
	
end