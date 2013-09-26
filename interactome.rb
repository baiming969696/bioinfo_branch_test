class Network_PPI

	attr_reader :ppi
	attr_reader :node
	
	def initialize(ppi_file="Hybrid_PPI.txt",seperator=/\t/)
		@ppi = []
		case ppi_file
			when Array then @ppi = ppi_file
			when String then File.open(ppi_file).each { |line| @ppi.push(line.chomp.split(seperator)) }
			else raise ArgumentError,"node_list is invalid"
		end
		@node = Hash.new(0)
		@ppi.each do |element|
			@node[element[0]] += 1
			@node[element[1]] += 1
		end
	end
	
	def stat
		@node_num = @node.size
		@edge_num = @ppi.size
		print "This PPI network has ",@node_num," nodes, and ",@edge_num," edges.\n"
	end

	def output_ppi(output_file="ppi.txt")
		File.open(output_file,"w") do |fout|
			@ppi.each { |element| fout.puts element.join("\t") }
		end
	end
	
	def output_node(output_file="node.txt")
		File.open(output_file,"w") do |fout|
			@node.each { |k,v| fout.puts k }
		end
	end
	
	def test_1
	end
	
	def sub_network(node_list,type="query")
		query_node = {}
		case node_list
			when Array then node_list.each { |element| query_node[element] = 1 }
			when Hash then query_node = node_list
			when String then File.open(node_list).each { |line| query_node[line.chomp] = 1 }
			else raise ArugmentError,"node_list is invalid"
		end
		if type == "query"
			new_ppi = []
			@ppi.each do |element|
				if query_node.has_key?(element[0]) and query_node.has_key?(element[1])
					new_ppi.push(element)
				end
			end
			Network_PPI.new(new_ppi)
		elsif type == "expand"
			new_ppi = []
			@ppi.each do |element|
				if query_node.has_key?(element[0]) or query_node.has_key?(element[1])
					new_ppi.push(element)
				end
			end
			Network_PPI.new(new_ppi)
		end
	end
	
	def bridge(node_list_1,node_list_2)
		query_node_1 = {}
		case node_list_1
			when Array then node_list_1.each { |element| query_node_1[element] = 1 }
			when Hash then query_node_1 = node_list_1
			when String then File.open(node_list_1).each { |line| query_node_1[line.chomp] = 1 }
			else raise ArugmentError,"node_list_1 is invalid"
		end
		query_node_2 = {}
		case node_list_2
			when Array then node_list_2.each { |element| query_node_2[element] = 1 }
			when Hash then query_node_2 = node_list_2
			when String then File.open(node_list_2).each { |line| query_node_2[line.chomp] = 1 }
			else raise ArugmentError,"node_list_2 is invalid"
		end
		tmp_network_1 = self.sub_network(query_node_1,"expand")
		tmp_network_2 = self.sub_network(query_node_2,"expand")
		all_node = query_node_1.merge(query_node_2)
		tmp_network_1.node.each { |k,v| all_node[k] = 1 if tmp_network_2.node.has_key?(k) }
		self.sub_network(all_node.keys)
	end

end


