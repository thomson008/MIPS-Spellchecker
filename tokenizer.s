
#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
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
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL       


# You can add your data here!

tokens:                 .space 411849
        
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
        sb   $0,  content($t0)                                                     

        li   $v0, 16                    # system call for close file                
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)                        
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

# You can add your code here!
        
        li $t0, 0                       # int c_idx = 0;
        lb $a0, content($t0)            # c = content[c_idx];
        li $t4, 0                       # tokens_number = 0;
TOKENIZER:
        blez $a0, BREAK                 #if (c == '\0'){break;}
        jal checkType                   # jump to check the type of char
        blez $t2, addAlpha              # if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z')
        li $s7, 1
        beq $t2, $s7, addPunct          # else if(c == ',' || c == '.' || c == '!' || c == '?')
        li $s7, 2
        beq $t2, $s7, addSpace          # else if(c == ' ')
        
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
        lb $a0 ,content($t0)            # c = content[c_idx];
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
        li $s7, 1
        beq $t1, $s7, noAlpha           # c is not alphabetic
        li $t2, 0                       # c is alphabetic, so set $t2 to 0 (would be 1 for punctuation and 2 for space, just a convention)
        jr $ra                          # go back to PC + 4 value stored in $ra
        
noAlpha:
        slti $t1, $a0, 64               # if (c > 64)
        blez $t1, space                 # c is not a punctutation mark
        slti $t1, $a0, 33               # if (c < 33)
        li $s7, 1
        beq $t1, $s7, space               # c is not a punctuation mark
        li $t2, 1                       # 1 means punctuation mark
        jr $ra                          # go back to PC + 4 value stored in $ra
        
space:
        li $t2, 2                       # 2 means space
        jr $ra                          # go back to PC + 4 value stored in $ra
        
BREAK: 
        li $t3, 0                       # token_c_idx = 0;
        li $t5, 0                       # token index = 0
PRINT:
        li $s0, 201                    
        mult $t5, $s0                   # calculate the addres at which to store new char by
        mflo $s1                        # multiplying the tokens number with token size and adding the current token_c_idx
        add $s0, $s1, $t3               # $s0 is now the offset from the addres of tokens
        lb $a0, tokens($s0)             # byte from that address is loaded into $a0
        blez $a0, addNewLine            # if the byte is 0, siginifying the end of the token, add new line
        li $v0, 11                      # else, print the character represented by the byte
        syscall
        addi $t3, $t3, 1                # token_c_idx += 1;
        j PRINT

addNewLine:   
        li $t3, 0                       # token_c_idx = 0;
        addi $t5, $t5, 1                # token_c_idx += 1;
        beq $t5, $t4, main_end          # if all the tokens are already printed, terminate 
        li $v0, 11                      # print a newline
        lb $a0, newline
        syscall
        
        j PRINT
        

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:    
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
