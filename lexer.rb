class Lexer

	KEYWORDS = ["def","class","if","true","false","nil"]

	def tokenize(code)
		# Clean up code by removing extra line breaks using chomp function
		code.chomp!

		# Current character position we are parsing 
		i = 0

		# Collection of all parsed tokens in form [:TOKEN_TYPE, value]
		tokens = []

		# Current indent level is the number of spaces in the last indent
		current_indent = 0 
		# We keep track the indentation levels  we are in so that when we dedent, we can check if we'are
		# on the correct level 
		indent_stack = []
		# This is how to implement a very simple scanner 
		# Scan one character at the time until you find something to parse

		while i < code.size
			chunk = code[i..-1]

			# Matching standard tokens 
			#
			# Matching if, print, method name, etc
			if identifier = chunk[/\A([a-z]\w*)/, 1]
				
				# Keywords are special indentifiers tagged with their own name 'if' will result
				# in an [:IF, "IF"] token
				if KEYWORDS.include?(identifier)
					tokens << [identifier.upcase.to_sym, identifier]
				
				# Non-Keyword identifiers include method and variable names
				else
					tokens << [:IDENTIFIER, identifier]
				end

				# Skip what we just parsed
				i += identifier.size

			# Matching class names and constants starting with a capital letter.
			elsif constant = chunk[/\A([A-Z]\w*)/, 1]
				tokens << [:CONSTANT, constant]
				i += constant.size

			elsif number = chunk[/\A([0-9]+)/, 1]
				tokens << [:NUMBER, number.to_i]
				i += number.size

			elsif string = chunk[/\A " (.*?) "/, 1]
				tokens << [:STRING , string]
				i += string.size + 2
			
			# Here's the indentation magic
			#
			# We have to take case of 3 cases: 
			#
			#   if true : #   1) the block is created
			#   	line {}1
			# 		line {2}  2) new line inside the block
			#   continue # 3   ) dedent
			#
			# This elsif take care of the first case. the number of space will determine
			# The indent level

			elsif indent = chunk[/\A\:\n( +)/m, 1] # Matches ": <newline> <spaces> "
				# When we create a new block we expect the indent level to go up
				if indent.size <= current_indent
					raise "Bad indent level, got #{indent.size} indents, " + "expected > #{current_indent}"
				end
				# Adjust the current indentation level
				current_indent = indent.size
				indent_stack.push(current_indent)
				tokens << [:INDENT, indent.size]
				i += indent.size + 2
			# This elsif takes care of two cases 
			elsif indent = chunk[/\A\n( *)/m, 1]
				if indent.size == current_indent # We are in the same block using the same number of spaces
					# So nothing to do here 
					tokens << [:NEWLINE, "\n"]
				elsif indent.size < current_indent # Leaving the block 
					while indent.size < current_indent
						indent_stack.pop
						current_indent = indent_stack.first || 0
						tokens << [:DEDENT, indent.size]
					end
					tokens << [:NEWLINE, "\n"]
				else # indent.size > current_indent = Error
					 #Nothing to do because we have an error since the indent size greater than current indent
					 raise "Missing ':'";
				end
				i += indent.size + 1
			# Match long operators such as ||, &&, ==, !=, <= and >=.
			# One character long operators are matched by the catch all `else` at the bottom.
			elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/, 1]
				tokens << [operator, operator]
				i += operator.size
			elsif chunk.match(/\A /)
				i += 1
			# Catch all single characters 
			# We treat all other single characters as a token Eg .: ( ) , . ! + - <
			else
				value = chunk[0,1]
				tokens << [value, value]
				i += 1
			end
		end

		# Close all open blocks
		while indent = indent_stack.pop
			tokens << [:DEDENT, indent_stack.first || 0]
		end
		tokens
	end
end