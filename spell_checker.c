/***********************************************************************
* File       : <spell_checker.c>
*
* Author     : <Siavash Katebzadeh>
*
* Description:
*
* Date       : 08/10/18
*
***********************************************************************/
// ==========================================================================
// Spell checker
// ==========================================================================
// Marks misspelled words in a sentence according to a dictionary

// Inf2C-CS Coursework 1. Task B/C
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2018

#include <stdio.h>


// maximum size of input file
#define MAX_INPUT_SIZE 2048
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 10000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 20

int read_char() { return getchar(); }
int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(int c)     { putchar(c); }
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
char dictionary_file_name[] = "dictionary.txt";
// input file name
char input_file_name[] = "input.txt";
// content of input file
char content[MAX_INPUT_SIZE + 1];
// valid punctuation marks
char punctuations[] = ",.!?";
// tokens of input file
char tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
// number of tokens in input file
int tokens_number = 0;
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////

// You can define your global variables here!

char dictionary2D[MAX_DICTIONARY_WORDS][MAX_WORD_SIZE + 1];
int control[MAX_INPUT_SIZE + 1];

// Task B

//helper function to make comparing strings simpler when going through dictionary
int compareStr(char a[], char b[]) {
  int i = 0;

  while (a[i] != '\0') {
    if (a[i] != b[i] && (a[i] + 32) != b[i])
    return 0;
    i++;
  }

  if (b[i] == '\0')
  return 1;
  return 0;
}

void spell_checker() {
  // TODO Please implement me!

  //converting 1D dictionary array into 2D array of words
  int dict_token_idx = 0;                                                 //index of word in 2D array of words
  int i;                                                                  //index of character in dictionary
  int dict_token_c_idx = 0;                                               //index of letter in a current word in 2D array of words

  for(i = 0; 1; i++) {
  	if(dictionary[i]!='\n'){                                              //if we don't reach a newline yet, keep adding letter to word at index n in 2D array
  		dictionary2D[dict_token_idx][dict_token_c_idx++] = dictionary[i];
  	}
  	else{
  		dictionary2D[dict_token_idx][dict_token_c_idx++]='\0';              //if a newline is found, we add zero to the end of the word
  		dict_token_idx++;                                                   //increment n so we can add another word to 2D array
  		dict_token_c_idx = 0;
  	}
  	if(dictionary[i]=='\0')
  		break;
  }

  //initializing control array with all zeros. then, if a token at given position is correct, it will be updated to 1
  for(i = 0; i < tokens_number; i++) {
    control[i] = 0;
  }

  int j;

  //if the word is found in dictionary, 0 is changed to 1 in control array at the corresponding position
  for (i = 0; i < tokens_number; i++) {
    for(j = 0; j < dict_token_idx; j++) {
      if(compareStr(tokens[i], dictionary2D[j])) {
        control[i] = 1;
        break;
      }
    }
  }
  return;
}

// Task B
void output_tokens() {
  // TODO Please implement me!
  int i;
  //check if the token is alphabetic, if yes also check if it is in the dictionary, if not - print it with dashes at both sides. If the token is non-alpha,
  //simply print it without performing any further checks
  for(i = 0; i < tokens_number; i++) {
    char c = tokens[i][0];
    if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {
      if(control[i]) {
        printf("%s", tokens[i]);
      }
      else {
        printf("_%s_", tokens[i]);
      }
    }
    else {
      printf("%s", tokens[i]);
    }
  }
  printf("\n");
  return;
}

//---------------------------------------------------------------------------
// Tokenizer function
// Split content into tokens
//---------------------------------------------------------------------------
void tokenizer(){
  char c;

  // index of content
  int c_idx = 0;
  c = content[c_idx];
  do {

    // end of content
    if(c == '\0'){
      break;
    }

    // if the token starts with an alphabetic character
    if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {

      int token_c_idx = 0;
      // copy till see any non-alphabetic character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with one of punctuation marks
    } else if(c == ',' || c == '.' || c == '!' || c == '?') {

      int token_c_idx = 0;
      // copy till see any non-punctuation mark character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ',' || c == '.' || c == '!' || c == '?');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with space
    } else if(c == ' ') {

      int token_c_idx = 0;
      // copy till see any non-space character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ' ');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;
    }
  } while(1);


}
//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{


  /////////////Reading dictionary and input files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;

  // open input file
  FILE *input_file = fopen(input_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the input file failed
  if(input_file == NULL){
    print_string("Error in opening input file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }

  // reading the input file
  do {
    c_input = fgetc(input_file);
    // indicates the the of file
    if(feof(input_file)) {
      content[idx] = '\0';
      break;
    }

    content[idx] = c_input;

    if(c_input == '\n'){
      content[idx] = '\0';
    }

    idx += 1;

  } while (1);

  // closing the input file
  fclose(input_file);

  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }

    dictionary[idx] = c_input;
    idx += 1;
  } while (1);

  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ////////////////////////////////////////////////////////////////

  tokenizer();

  spell_checker();

  output_tokens();


  return 0;
}
