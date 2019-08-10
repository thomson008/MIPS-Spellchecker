
#=========================================================================
# Spell checker 
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"

        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL

# You can add your data here!
tokens:                 .space 411849
.align 4
dictionary_tokens:      .space 210000  
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------




# You can add your code here!
        li $t0, 0                       # int c_idx = 0;
        lb $a0, content($t0)            # c = content[c_idx];
        li $t4, 0                       # tokens_number = 0;
TOKENIZER:
        blez $a0, dictTokenizer         #if (c == '\0'){break;}
        jal checkType                   # jump to check the type of char
        blez $t2, addAlpha              # if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z')
        li $s7, 1
        beq $t2, $s7, addPunct          # else if(c == ',' || c == '.' || c == '!' || c == '?')
        li $s7, 2
        beq $t2, $s7, addSpace          # else if(c == ' ')
        j TOKENIZER
        
addAlpha:
        li $t3, 0                       #token_c_idx = 0;
        j alphaLoop                     # do {.....}
        
alphaLoop:
        li $s0, 201                    
        mult $t4, $s0                   # calculate the addres at which to store new char by
        mflo $s1                        # multiplying the tokens number with token size and adding the current token_c_idx
        add $s0, $s1, $t3               #
        la $a3, tokens($s0)             # load the calculated address into register
        sb $a0,  0($a3)                 # tokens[tokens_number][token_c_idx] = c;
        addi $t3, $t3, 1                # token_c_idx += 1;
        addi $t0, $t0, 1                # c_idx += 1;
        la $s1, content($t0)            # load the address of next char into a3
        lb $a0, 0($s1)                  # c = content[c_idx];
        jal checkType                   # check the type to determine whether to exit the loop or continue
        blez $t2, alphaLoop             # while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
        sb $0, 1($a3)                   # tokens[tokens_number][token_c_idx] = '\0';
        addi $t4, $t4, 1                # tokens_number += 1;
        
        j TOKENIZER
        
addPunct:
        li $t3, 0                       #token_c_idx = 0;
        j punctLoop                     # do {.....}
        
punctLoop:
        li $s0, 201                    
        mult $t4, $s0                   # calculate the addres at which to store new char by
        mflo $s1                        # multiplying the tokens number with token size and adding the current token_c_idx
        add $s0, $s1, $t3               #
        la $a3, tokens($s0)             # load the calculated address into register
        sb $a0,  0($a3)                 # tokens[tokens_number][token_c_idx] = c;
        addi $t3, $t3, 1                # token_c_idx += 1;
        addi $t0, $t0, 1                # c_idx += 1;
        la $s1, content($t0)            # load the address of next char into a3
        lb $a0, 0($s1)                  # c = content[c_idx];
        jal checkType                   # check the type to determine whether to exit the loop or continue
        li $s7, 1
        beq $t2, $s7, punctLoop         # while(c == ',' || c == '.' || c == '!' || c == '?');
        sb $0, 1($a3)                   # tokens[tokens_number][token_c_idx] = '\0';
        addi $t4, $t4, 1                # tokens_number += 1;
        
        j TOKENIZER
        
addSpace:
        li $t3, 0                       #token_c_idx = 0;
        j spaceLoop
        
spaceLoop:
        li $s0, 201                    
        mult $t4, $s0                   #calculate the addres at which to store new char by
        mflo $s1                        #multiplying the tokens number with token size and adding the current token_c_idx
        add $s0, $s1, $t3
        la $a3, tokens($s0)             #load the calculated address into register
        sb $a0,  0($a3)                 # tokens[tokens_number][token_c_idx] = c;
        addi $t3, $t3, 1                # token_c_idx += 1;
        addi $t0, $t0, 1                # c_idx += 1;
        la $s1, content($t0)            # load the address of next char into a3
        lb $a0, 0($s1)                  # c = content[c_idx];
        jal checkType                   # check the type to determine whether to exit the loop or continue
        li $s7, 2
        beq $t2, $s7, spaceLoop         # while(c == ' ');
        sb $0, 1($a3)                   # tokens[tokens_number][token_c_idx] = '\0';
        addi $t4, $t4, 1                # tokens_number += 1;
        
        j TOKENIZER
        
checkType:
        slti $t1, $a0, 123              # if (c > 'z')
        blez $t1, noAlpha               # c is not alhabetic
        slti $t1, $a0, 65               # if ( c > 'A)
        li $s6, 1
        beq $t1, $s6, noAlpha           # c is not alphabetic
        li $t2, 0                       # c is alphabetic, so set $t2 to 0 (would be 1 for punctuation and 2 for space, just a convention)
        jr $ra                          # go back to PC + 4 value stored in $ra
        
noAlpha:
        slti $t1, $a0, 64               # if (c > 64)
        blez $t1, space                 # c is not a punctutation mark
        slti $t1, $a0, 33               # if (c < 33)
        li $s6, 1
        beq $t1, $s6, space               # c is not a punctuation mark
        li $t2, 1                       # 1 means punctuation mark
        jr $ra                          # go back to PC + 4 value stored in $ra
        
space:
        li $t2, 2                       # 2 means space
        jr $ra                          # go back to PC + 4 value stored in $ra

#################  NEXT PART OF CODE TOKENIZES THE DICTIONARY IN A SIMILAR WAY  #####################     
              
                          
dictTokenizer:  
        li $t0, 0                       # token counter
        li $t1, 0                       # index in dictionary string
        lb $s0, dictionary($t1)
        
tokenizer:
        blez $s0, BREAK                 # if char is 0, BREAK
        j dictAddAlpha                  # add new char to 2D array
        
dictAddAlpha:
        li $t3, 0                       # index of letter in token

dictAlphaLoop:
        li $s1, 21                      #
        mult $t0, $s1                   #
        mflo $s1                        #
        add $s3, $s1, $t3               # calculate the address at which to store a char in 2D array
        sb $s0, dictionary_tokens($s3)  # store the char
        addi $t3, $t3, 1                # update index of letter in token
        addi $t1, $t1, 1                # update index of letter in dictinary
        lb $s0, dictionary($t1)         # load next character from dictionary
        li $s6, 10
        beq $s0, $s6, nextWord          # if it is a newline, go to nextWord label
        j dictAlphaLoop                 # else, go back to loop to add next char from the dictionary

 nextWord:
        la $a1, dictionary_tokens($s3)  # load the address at which to store zero signifying end of token
        sb $0, 1($a1)                   # store zero there
        addi $t1, $t1, 1                # 
        lb $s0, dictionary($t1)         # load next char from dictionary
        addi $t0, $t0, 1                # update total number of tokens
        j tokenizer                     # go back to tokenize the next word
         
 
BREAK:    
        li $t5, 0                       # input token number
        li $s7, 201                     # max length of a token

tokenLoop:
        beq $t5, $t4, main_end          # if all the tokens are checked and printed close program
        mult $t5, $s7                   # 
        mflo $s5                        # calculate the base address of token number $t5
        lb $a0, tokens($s5)             # get first character of that token
        jal checkType                   # check its type
        bne $t2, 0, printCorrect        # if it's not a letter, simply print it without any further checks
        li $t3, 0                       # else prepare for iteration through the entire dictionary by setting index of dictionary word to zero
        
dictLoop:
        beq $t3, $t0, printWrong        # if all the words have beed checked and nothing was found, print a token with underlines
        move $a1, $s5                   #
        li $s1, 21                      #
        mult $t3, $s1                   #
        mflo $a2                        # calculate the base address of dictionary word
        jal cmploop                     # jump to compare loop which check whether the token is the same as a given word in dictionary
        li $s6, 1
        beq $t9, $s6, printCorrect      # cmploop will set $t9 to 1 if the words are the same, so if it is 1, go to printCorrect
        addi $t3, $t3, 1                # increment index of word in dictionary by 1 to check the next word
        j dictLoop
        
cmploop:
        lb $s0, tokens($a1)             # 
        lb $s1, dictionary_tokens($a2)  # load corresponding chars from a token and dictionary word
    
        bne $s0, $s1, notEqual          # if they are different, go to notEqual function
        blez $s0, endOfString           # if token char is 0, go to endOfString function
    
        addi $a1, $a1, 1                
        addi $a2, $a2, 1                # update index of char in both token and dictionary word
        j cmploop                       # compare next letter
    
notEqual:                               # notEqual is intended to check whether the characters are different because they are different letters or there is only a case difference
        addi $s0, $s0, 32               # convert token character to its uppercase version
        addi $a1, $a1, 1                
        addi $a2, $a2, 1                # update index of char in both token and dictionary word
        beq $s0, $s1, cmploop           # if now the chars are the same, proceed to check next letters
        li $t9, 0                       # else set $t9 to 0
        jr $ra                          # go back to PC + 4
    
endOfString:
        slti $t9, $s1, 1                # if a corresponding letter in dictionary word is also 0, set $t9 to 1 as it means the words are the same
        jr $ra                          # go back to PC + 4
        
printCorrect:
        li $v0, 11                      # 
        lb $a0, tokens($s5)             # load a byte to print
        blez $a0, nextToken             # if it's zero, go to next token 
        syscall                         # 
        addi $s5, $s5, 1                # increment the index of character in token
        j printCorrect                  # go to print next character
        
nextToken:
        addi $t5, $t5, 1                # increment the index of token by one
        j tokenLoop                     # go back to tokenLoop to check another token
        
printWrong:
        li $v0, 11                      
        li $a0, 95                      
        syscall                         # print an underline
        
printWrongLoop:                         # same as printCorrect, but before going to next token also have to add another underline (in nextTokenWrong)
        li $v0, 11
        lb $a0, tokens($s5)
        blez $a0, nextTokenWrong        
        syscall
        addi $s5, $s5, 1
        j printWrongLoop
             
nextTokenWrong:
        li $v0, 11
        li $a0, 95                      
        syscall                         # print an underline
        addi $t5, $t5, 1                # increment the index of token by one
        j tokenLoop                     # go back to tokenLoop to check another token
                                                                  
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:     
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
