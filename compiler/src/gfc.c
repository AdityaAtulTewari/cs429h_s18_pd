#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <setjmp.h>
#include <ctype.h>
#include <pthread.h>
static FILE *f;
static int loopcount = 0;
static char* input;
static char arg = 0;

uint64_t mstrtol(char* w, int i)
{
  uint64_t t = 0;
  for(register int j = 0; j< i; j++)
  {
    if(w[j] != '_')
    {
      t*=(uint64_t) 10;
      t+=(uint64_t) (w[j] - '0');
    }
  }
  return t;
}

pthread_t thread1;

/* Construction of the min heap*/

static int size = 0;

typedef struct Token token;

/* Kinds of tokens */
enum Kind
{
    LTE,
    GTE,
    GT,
    LT,
    ELSE,    // else
    MINUS,   // -
    END,     // <end of string>
    EQ,      // =
    EQEQ,    // ==
    ID,      // <identifier>
    IF,      // if
    INT,     // <integer value >
    LBRACE,  // {
    LEFT,    // (
    MUL,     // *
    NONE,    // <no valid token>
    PLUS,    // +
    PRINT,   // print
    RBRACE,  // }
    RIGHT,   // )
    SEMI,    // ;
    WHILE,   // while
    FUN      // functions
};
/* information about a token */
struct Token
{
  enum Kind kind;
  uint64_t value;
  int end;
  uint64_t* varpoint;
  char* start;
  token* next;
};

/* The symbol table */
//The table only exists to link items to their buckets then ceases to exist.
typedef struct TrieNode tn; struct TrieNode
{
  tn** childs;
  uint64_t* place;
};
tn* root = NULL;

static token** useful;
static token** min;
void assignMin()
{
  for(register int i = 0; i <size; i++)
  {
    if(*useful[i]->varpoint < *((*min)->varpoint))
    {
      min = &useful[i];
    }
  }
}
void addv(token* t)
{
  char c = 0;
  for(register int i = 0; i <size; i++)
  {
    if(useful[i]->varpoint == t->varpoint)
    {
      c = i + 1;
      break;
    }
  }
  if(c)
  {
    switch (c)
    {
      case '\1':
        fputs("%rbx", f);
        break;
      case '\2':
        fputs("%r15", f);
        break;
      case '\3':
        fputs("%r12", f);
        break;
      case '\4':
        fputs("%r13", f);
        break;
      case '\5':
        fputs("%r14", f);
        break;
      case '\6':
        fputs("%r11", f);
        break;
      case '\7':
        fputs("%r10", f);
        break;
      case '\10':
        fputs("%r9", f);
        break;
      case '\11':
        fputs("%r8", f);
        break;
      case '\12':
        fputs("%rcx", f);
        break;
      case '\13':
        fputs("%rdx", f);
        break;
    }
  }
  else
  {
    fputc('_', f);
    for(register int i = 0; i< t->end; i++)
    {
      fputc(t->start[i], f);
    }
  }
}
void addvar(token* t)
{
  fputc('_', f);
  for(register int i = 0; i < t->end; i++)
  {
    fputc(t->start[i], f);
  }
  fputc(':', f);
  fputc('\n',f);
  fputs("\t\t.quad 0\n", f);
}
void insertID(token* t)
{
  for(register int i = 0; i<size; i++)
  {
    if(t->varpoint == useful[i]->varpoint) return;
  }
  if(*t->varpoint == 0) return;
  else if(size < 11)
  {
    useful[size] = t;
    size++;
  }
  else if(*(*min)->varpoint > *t->varpoint)
  {
    *min = t;
    assignMin();
  }
}

void rinsert(token* t, int iter, tn* n)
{
  if(!t) return;
  if(!t->end) return;
  if(!n->childs){ n->childs = (tn**) calloc(sizeof(tn*), 36);}
  int i = 0;
  if(isdigit(t->start[iter])) i = 'z' + t->start[iter]- '0' - 'a'+1;
  else i = t->start[iter] - 'a';
  if(!n->childs[i])
  {
    n->childs[i] = (tn*) malloc(sizeof(tn));
    if(!n->childs[i]) printf("Malloc Failed\n");
    n->childs[i]->place = NULL;
  }
  if(t->end == iter + 1)
  {
    if(n->childs[i]->place == NULL) {n->childs[i]->place = & t->value; t->value = (uint64_t) -1;}
    t->varpoint = n->childs[i]->place;
    *t->varpoint = *t->varpoint +1;
    insertID(t);
    if(*t->varpoint == 1)
    {
      addvar(t);
      if(t->end == 4 && t->start[0] == 'a' && t->start[1] == 'r' && t->start[2] == 'g' && t->start[3] =='c') arg = 1;
    }
  }
  else rinsert(t, iter+1, n->childs[i]);
}

void insert(token* t)
{
  if(!t) return;
  if(!t->end) return;
  if(!root) {root =(tn*) malloc(sizeof(tn)); root->place = NULL;}
  if(!root->childs){ root->childs = (tn**) calloc(sizeof(tn*), 26);}
  if(!root->childs[t->start[0] - 'a']) {root->childs[t->start[0] - 'a'] = (tn*) malloc(sizeof(tn)); root->childs[t->start[0] - 'a']->place = NULL;}
  if(t->end == 1)
  {
    if( root->childs[t->start[0] - 'a']-> place == NULL)
    {
      root->childs[t->start[0] - 'a']-> place = & t->value;
      t->value = (uint64_t) -1;
    }
    t->varpoint = root->childs[t->start[0] - 'a']->place;
    *t->varpoint = *t->varpoint +1;
    insertID(t);
    if(*t->varpoint == 1) addvar(t);
  }
  else rinsert(t, 1, root->childs[t->start[0] - 'a']);
}

void hfreeun(tn* n)
{
  if(!n) return;
  if(n->childs)
  {
    for(int i = 0; i < 36; i++) hfreeun(n->childs[i]);
  }
  free(n);
  return;
}

void *freeun()
{
  if(!root) pthread_exit(NULL);
  if(root->childs) for(int i = 0; i< 26; i++) hfreeun(root->childs[i]);
  free(root);
  pthread_exit(NULL);
}

uint64_t get(token* id)
{
  if(id->kind == ID) return *id->varpoint;
  return id->value;
}


void set(token* id, uint64_t value)
{
  if(id->kind == ID)
  {
    *(id->varpoint) = value;
  }
  else id->value = value;
}

/* The current token */
static struct Token *current;

static jmp_buf escape;

enum Kind peek();

static char* remaining()
{
  return current->start;
}

static void error()
{
  printf("error at '%s'\n", remaining());
  longjmp(escape, 1);
}

enum Kind peek()
{
  return current->kind;
}

void consume()
{
  current = current->next;
}

token* getId(void)
{
  return current;
}

uint64_t getInt(void)
{
  return current->value;
}

uint64_t statement(int doit);
uint64_t expression(int doit);
void seq(int doit);

/* handle id, literals, and (...) */
uint64_t e1(int doit)
{
  if (peek() == LEFT)
  {
    consume();
    uint64_t v = expression(doit);
    if (peek() != RIGHT)
    {
      error();
    }
    consume();
    return v;
  }
  else if (peek() == INT)
  {
    uint64_t v = getInt();
    if(doit) fprintf(f, "\t\tmov $%lu, %%rsi\n", v);
    consume();
    return v;
  }
  else if (peek() == ID)
  {
    token * id = getId();
    if(doit) fputs("\t\tmov ", f);
    if(doit)
    {
      if(*id->varpoint) addv(id);
      else fputs("$0", f);
    }
    if(doit) fputs(", %rsi\n", f);
    consume();
    return get(id);
  }
  else if (peek() == FUN)
  {
    if(doit) fprintf(f, "\t\tlea x_%p, %%rsi\n", current);
    consume();
    uint64_t v = (uint64_t) current;
    statement(0);
    return v;
  }
  else
  {
    error();
    return 0;
  }
}

/* handle '*' */
uint64_t e2(int doit)
{
  uint64_t value = e1(doit);
  while (peek() == MUL)
  {
    if(doit) fputs("\t\tpush %rsi\n", f);
    consume();
    e1(doit);
    if(doit) fputs("\t\tpop %rax\n\t\timul %rax, %rsi\n", f);
  }
  return value;
}

/* handle '+' */
uint64_t e3(int doit)
{
  uint64_t value = e2(doit);
  if(peek() == PLUS)
  while (peek() == PLUS)
  {
    if(doit) fputs("\t\tpush %rsi\n", f);
    consume();
    e2(doit);
    if(doit) fputs("\t\tpop %rax\n\t\tadd %rax, %rsi\n", f);
  }
  else if(peek == MINUS)
  while (peek() == MINUS)
  {
    if(doit) fputs("\t\tpush %rsi\n", f);
    consume();
    e2(doit);
    if(doit) fputs("\t\tpush %rsi\n", f);
  }
  return value;
}

/* handle '==' */
uint64_t e4(int doit)
{
  uint64_t value = e3(doit);
  if(peek() == EQEQ)
  while (peek() == EQEQ)
  {
    consume();
    if(doit){fputs("\t\tpush %rsi\n", f);}
    e3(doit);
    if(doit)
    {
      fputs("\t\tpop %rax\n", f);
      fputs("\t\tcmp %rsi, %rax\n", f);
      fputs("\t\tmov $0, %rax\n", f);
      fputs("\t\tsete %al\n", f);
      fputs("\t\tmov %rax, %rsi\n", f);
    }
  }
  else if (peek() == LTE)
  while (peek() == LTE)
  {
    consume();
    if(doit){fputs("\t\tpush %rsi\n", f);}
    e3(doit);
    if(doit)
    {
      fputs("\t\tpop %rax\n", f);
      fputs("\t\tcmp %rsi, %rax\n", f);
      fputs("\t\tmov $0, %rax\n", f);
      fputs("\t\tsetle %al\n", f);
      fputs("\t\tmov %rax, %rsi\n", f);
    }
  }
  else if (peek() == GTE)
  while (peek() == GTE)
  {
    consume();
    if(doit){fputs("\t\tpush %rsi\n", f);}
    e3(doit);
    if(doit)
    {
      fputs("\t\tpop %rax\n", f);
      fputs("\t\tcmp %rsi, %rax\n", f);
      fputs("\t\tmov $0, %rax\n", f);
      fputs("\t\tsetge %al\n", f);
      fputs("\t\tmov %rax, %rsi\n", f);
    }
  }
  else if (peek() == LT)
  while (peek() == LT)
  {
    consume();
    if(doit){fputs("\t\tpush %rsi\n", f);}
    e3(doit);
    if(doit)
    {
      fputs("\t\tpop %rax\n", f);
      fputs("\t\tcmp %rsi, %rax\n", f);
      fputs("\t\tmov $0, %rax\n", f);
      fputs("\t\tsetl %al\n", f);
      fputs("\t\tmov %rax, %rsi\n", f);
    }
  }
  else if (peek() == GT)
  while (peek() == GT)
  {
    consume();
    if(doit){fputs("\t\tpush %rsi\n", f);}
    e3(doit);
    if(doit)
    {
      fputs("\t\tpop %rax\n", f);
      fputs("\t\tcmp %rsi, %rax\n", f);
      fputs("\t\tmov $0, %rax\n", f);
      fputs("\t\tsetg %al\n", f);
      fputs("\t\tmov %rax, %rsi\n", f);
    }
  }
  return value;
}

uint64_t expression(int doit)
{
  return e4(doit);
}

uint64_t statement(int doit)
{
  switch(peek())
  {
    case ID:
    {
      token* id = getId();
      consume();
      if (peek() == LEFT)
      {
        consume();
        if(peek() != RIGHT)
        {
          error();
        }
        if(doit && *id->varpoint)
        {
          consume();
          fputs("\t\tcall *", f);
          addv(id);
          fputs("\n",f);
        }
        else {consume();}
        return 1;
      }
      if (peek() != EQ) error();
      consume();
      expression(doit);
      if (doit && *id->varpoint)
      {
        fputs("\t\tmov %rsi, ", f);
        addv(id);
        fputs("\n", f);
      }
      if (peek() == SEMI) consume();
      return 1;
    }

    case LBRACE:
      consume();
      seq(doit);
      if (peek() != RBRACE) error();
      consume();
      return 1;
    case IF:
      consume();
      int counter = loopcount;
      if(doit) loopcount++;
      if(doit)fprintf(f, "if_%d:\n", counter);
      expression(doit);
      if(doit)fputs("\t\tcmp $0, %rsi\n", f);
      if(doit) fprintf(f, "\t\tjz e_%d\n", counter);
      statement(doit);
      if(doit) fprintf(f, "\t\tjmp c_%d\n", counter);
      if(peek() == SEMI) {error(); consume();}
      if(doit) fprintf(f, "e_%d:\n", counter);
      if(peek() == ELSE)
      {
        consume();
        statement(doit);
      }
      if(doit) fprintf(f, "c_%d:\n", counter);
      return 1;
    case WHILE:
    {
      if(doit)
      {
        counter = loopcount;
        loopcount++;
        fprintf(f, "w_%d:\n", counter);
        consume();
        expression(doit);
        fputs("\t\tcmp $0, %rsi\n", f);
        fprintf(f, "\t\tjz b_%d\n", counter);
        statement(doit);
        fprintf(f, "\t\tjmp w_%d\n", counter);
        fprintf(f, "b_%d:\n", counter);
      }
      else
      {
        consume();
        expression(doit);
        statement(doit);
      }
      return 1;
    }
    case PRINT:
      consume();
      if(doit)
      {
        expression(doit);
        fputs("\t\tcall print_f\n",f);
      }
      else expression(doit);
      return 1;
    case SEMI:
      error();
      consume();
      return 1;
    case FUN:
      if(doit) fprintf(f, "\t\tcall x_%p\n", current);
      consume();
      statement(0);
      return 1;
    default:
      return 0;
  }
}

void seq(int doit)
{
  while (statement(doit)) ;
}

void program(void)
{
  seq(1);
  if (peek() != END) error();
}

void tokenize(char* prog)
{
  useful = (token **) calloc(sizeof(token*), 11);
  min = useful;
  fputs("\t\t .data\n", f);
  if(prog == NULL) error();
  register int i = 0;
  token beforecurr = {NONE, 0, 4, 0, "argc", current};
  insert(&beforecurr);
  token* last = &beforecurr;
  register int j;
  while(prog[i] != '\0')
  {
    j = 1;
    last->next = (token*) malloc(sizeof(token));
    last = last->next;
    if(!i) current = last;
    while(isspace(prog[i]) || (!isprint(prog[i]) && prog[i]!= '\0')) i++;
    switch(prog[i])
    {
      case '\0':
        j =0;
        last->kind = END;
        break;
      case '(':
        last->kind = LEFT;
        break;
      case '{':
        last->kind = LBRACE;
        break;
      case ')':
        last->kind = RIGHT;
        break;
      case '}':
        last->kind = RBRACE;
        break;
      case ';':
        error();
        last->kind = SEMI;
        break;
      case '*':
        last->kind = MUL;
        break;
      case '+':
        last->kind = PLUS;
        break;
      case '-' :
        last->kind = MINUS;
        break;
      case '<':
        last->kind = LT;
        break;
      case '>':
        last->kind = GT;
        break;
      case '=':
        if(prog[i+1] == '=')
        {
          last->kind = EQEQ;
          j++;
        }
        else if(prog[i+1] == '>')
        {
          last->kind = GTE;
        }
        else if(prog[i+1] == '<')
        {
          last->kind = LTE;
        }
        else
        {
          last->kind = EQ;
        }
        break;
      default:
      {
        if(isdigit(prog[i]))
        {
          last->kind = INT;
          while(isdigit(prog[i+j]) || prog[i+j] == '_')
          {
            j++;
          }
          last->value = mstrtol(&prog[i], j);
        }
        else if(prog[i] == 'i' && prog[i+1] == 'f' && !isalnum(prog[i+2]))
        {
          j++;
          last->kind = IF;
        }
        else if(prog[i] == 'f' && prog[i+1] == 'u' && prog[i+2] == 'n' && !isalnum(prog[i+3]))
        {
          j+=2;
          last->kind = FUN;
        }
        else if(prog[i] == 'w' && prog[i+1] =='h' && prog[i+2] == 'i' && prog[i+3] == 'l' && prog[i+4] == 'e' && !isalnum(prog[i+5]))
        {
          j+=4;
          last->kind = WHILE;
        }
        else if(prog[i] == 'e' && prog[i+1] == 'l' && prog[i+2] == 's' && prog[i+3] == 'e' && !isalnum(prog[i+4]))
        {
          j+=3;
          last->kind = ELSE;
        }
        else if(prog[i] == 'p' && prog[i+1] == 'r' && prog[i+2] == 'i' && prog[i+3] == 'n' && prog[i+4] == 't' && !isalnum(prog[i+5]))
        {
          j+=4;
          last->kind = PRINT;
        }
        else if(isalpha(prog[i]))
        {
          if(isupper(prog[i])) error();
          //identifier case needs to add to the structure housing these features and then a pointer to the distinctive location should be mapped for each
          //specific variable
          while(isalnum(prog[i+j]))
          {
            if(isupper(prog[i+j])) error();
            j++;
          }
          last->kind = ID;
          last->value = 0;
        }
      }
    }
    last->start = &prog[i];
    i+=j;
    last->end = j;
    if(last->kind == ID) insert(last);
    last->next = NULL;
  }
  last->next = (token*)malloc(sizeof(token));
  last = last->next;
  last->kind = END;
  pthread_create(&thread1, NULL, freeun, NULL);
}

void functionize()
{
  fputs("\t\t.text\n", f);
  token* first = current;
  while(peek() != END)
  {
    if(peek() == FUN)
    {
      token* back = current;
      fprintf(f, "x_%p:\n", current);
      consume();
      statement(1);
      current = back;
      fputs("\t\tret\n", f);
    }
    current = current->next;
  }
  current = first;
}

int main(int argc, char** argv)
{
    if (argc != 2) {
        fprintf(stderr,"usage: %s <name>\n",argv[0]);
        exit(1);
    }

    char* name = argv[1];
    size_t len = strlen(name);

    size_t sLen = len+3;  // ".s" + 0
    char* sName = (char*) malloc(sLen);
    if (sName == 0) {
        perror("malloc");
        exit(1);
    }

    strncpy(sName,name,sLen);
    strncat(sName,".s",sLen);

    size_t fLen = len+5; // ".fun" + 0
    char* fName = (char*) malloc(fLen);
    if (sName == 0) {
        perror("malloc");
        exit(1);
    }
    strncpy(fName,name,fLen);
    strncat(fName,".fun",fLen);


  f = fopen(sName,"w");
  if (f == 0)
  {
    perror(sName);
    exit(1);
  }
  //Open file to read from
  FILE *fr = fopen(fName, "r");
  fseek(fr, 0, SEEK_END);
  int bufflen = ftell(fr);
  input = (char*) malloc(sizeof(char) * bufflen+1);
  fseek(fr, 0, SEEK_SET);
  fread(input, sizeof(char), bufflen+1, fr);
  input[bufflen] = '\0';
  //tokenize the input while building variable address locations
  tokenize(input);
  fclose(fr);
  //Add for_mat
  fputs("for_mat:\n\t\t.byte '%', 'l', 'u', 10, 0\n",f);
  //Second pass to build functions to be used
  functionize();

  //add the all important print_f function
  fputs("print_f:\n", f);
  fputs("\t\tmov $for_mat, %rdi\n", f);
  char* regi[11];
  regi[0] = "%rbx";
  regi[1] = "%r15";
  regi[2] = "%r12";
  regi[3] = "%r13";
  regi[4] = "%r14";
  regi[5] = "%r11";
  regi[6] = "%r10";
  regi[7] = "%r9";
  regi[8] = "%r8";
  regi[9] = "%rcx";
  regi[10] = "%rdx";
  fputs("\t\tmov $0, %rax\n", f);
  for(register int i = 5; i < size; i++)
  {
    fprintf(f, "\t\tmov %s,", regi[i]);
    fputc('_', f);
    for(register int j = 0; useful[i]->end >j; j++) fputc(useful[i]->start[j], f);
    fprintf(f, "\n");
  }
  fputs("\t\tcall printf\n", f);
  for(register int i = 5; i < size; i++)
  {
    fprintf(f, "\t\tmov ");
    fputc('_', f);
    for(register int j = 0; useful[i]->end >j; j++) fputc(useful[i]->start[j], f);
    fprintf(f, ", %s\n", regi[i]);
  }
  fputs("\t\tret\n", f);
  //run the builder on main finally
  fputs("\t\t.global main\n", f);
  fputs("main:\n", f);
  if(arg) fputs("\t\tmov %rdi, _argc\n", f);
  for(register int i = 0; i < size; i++)
  {
    fprintf(f, "\t\tmov ");
    fputc('_', f);
    for(register int j = 0; useful[i]->end >j; j++) fputc(useful[i]->start[j], f);
    fprintf(f, ", %s\n", regi[i]);
  }
  fputs("\t\t.extern printf\n", f);
  int x = setjmp(escape);
  if (x == 0) program();
  fputs("\t\tmov $0, %rax\n", f);
  fputs("\t\tret", f);
  fputs("\n", f);
  fclose(f);
  free(useful);
  size_t commandLen = len*2 + 1000;
  char* command = (char*) malloc(commandLen);

  snprintf(command,commandLen,"gcc -o %s %s",name,sName);

  int rc = system(command);
  if (rc != 0)
  {
    perror(command);
    exit(1);
  }

  return 0;
}
