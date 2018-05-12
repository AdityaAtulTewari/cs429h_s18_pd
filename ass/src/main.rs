use std::env;
use std::rc::Rc;
use std::collections::HashMap;
use std::fs::File;
use std::io::prelude::*;
use std::cell::Cell;

/* Kinds of tokens */
#[derive(Clone, Eq, PartialEq, Debug)]
enum Kind
{
    ELSE,    // else
    END,     // <end of string>
    EQ,      // =
    EQEQ,    // ==
    ID(Rc<(Cell<u64>, Cell<usize>)>),      // <identifier>
    IF,      // if
    INT(u64),     // <integer value >
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
}

struct Import
{
  prog: Vec<Kind>,
  current: usize,
}

fn mstrtol(w: &Vec<char>, size:usize, i: usize)->u64
{
  let mut t:u64= 0;
  for j in 0..i
  {
    if w.len() > size + j
    {
      if w[(size + j)] != '_'
      {
        t*= 10;
        t+= w[(size + j)].to_digit(10).unwrap() as u64 ;
      }
    }
  }
  return t;
}
fn str(w: &Vec<char>, size: usize, i:usize)->String
{
  let mut v = String::new();
  for j in 0..i
  {
    if(w.len() > size +j) {v.push(w[size + j]);}
  }
  return v;
}

fn set(state: &mut Import, back: usize, v:&mut (u64, Option<usize>))
{
  let w = &mut state.prog[back];
  match *w
  {
    Kind::ID(ref mut id) =>
    {
      id.0.set(v.0);
      if v.1.is_some() {id.1.set(v.1.unwrap());}
    }
    _=> {panic!();}
  }
}

#[inline]
fn peek(state: &mut Import)->Kind
{
  return (&state.prog[state.current]).clone();
}
fn consume(state: &mut Import)
{
  state.current = state.current+ 1
}
#[inline]
fn getId(state: &mut Import)->usize
{
  return state.current;
}
/* Program Running */
fn e1(state: &mut Import)->(u64, Option<usize>)
{
  match peek(state)
  {
    Kind::LEFT=>
    {
      consume(state);
      let v = expression(state);
      if peek(state)!= Kind::RIGHT {panic!();}
      consume(state);
      return v;
    }
    Kind::INT(v)=>
    {
      consume(state);
      return (v, None);
    }
    Kind::ID(id)=>
    {
      consume(state);
      return (id.0.get(), Some(id.1.get()));
    }
    Kind::FUN=>
    {
      consume(state);
      let v = state.current;
      statement(false, state);
      return ((v as u64), Some(v));
    }
    _=> {panic!();}
  }
}

fn e2(state: &mut Import)->(u64, Option<usize>)
{
  let mut v = e1(state);
  while peek(state) == Kind::MUL
  {
    consume(state);
    v.0 = v.0 * e2(state).0;
  }
  return v;
}

fn e3(state: &mut Import)->(u64, Option<usize>)
{
  let mut v = e2(state);
  while peek(state) == Kind::PLUS
  {
    consume(state);
    v.0 = v.0 + e2(state).0;
  }
  return v;
}
fn e4(state: &mut Import)->(u64, Option<usize>)
{
  let mut v = e3(state);
  while peek(state) == Kind::EQEQ
  {
    consume(state);
    v.0 = if (v.0 == e3(state).0)== false {0} else {1};
  }
  return v;
}

fn expression(state: &mut Import)->(u64, Option<usize>)
{
  return e4(state);
}

fn statement(doit:bool, state: &mut Import)->bool
{
  match peek(state)
  {
    Kind::ID(id) =>
    {
      let back = getId(state);
      consume(state);
      match peek(state)
      {
        Kind::LEFT =>
        {
          consume(state);
          match peek(state)
          {
            Kind::RIGHT =>
            {
              if doit
              {
                state.current = id.1.get();
                statement(doit, state);
                state.current = back;
                consume(state);
                consume(state);
              }
            }
            _=>{panic!();}
          }
          consume(state);
          return true;
        }
        Kind::EQ =>
        {
          consume(state);
          let mut v = expression(state);
          if doit {set(state, back, &mut v);}
          return true;
        }
        _=> {panic!();}
      }
    }
    Kind::LBRACE =>
    {
      consume(state);
      seq(doit, state);
      match peek(state)
      {
        Kind::RBRACE =>
        {
          consume(state);
          return true;
        }
        _=> {panic!();}
      }
    }
    Kind::IF =>
    {
      consume(state);
      let t = expression(state).0;
      statement(doit && (t != 0), state);
      if peek(state) == Kind::ELSE {consume(state); statement(doit && (t==0), state);}
      return true;
    }
    Kind::WHILE =>
    {
      loop
      {
        let id = state.current.clone();
        consume(state);
        let t = expression(state).0;
        statement(doit && (t !=0), state);
        if doit && (t != 0){state.current = id;}
        else {break;}
      }
    }
    Kind::PRINT =>
    {
      consume(state);
      let a = expression(state);
      if doit {println!("{}", a.0);}
      return true;
    }
    Kind::SEMI => {panic!();}
    Kind::FUN => {consume(state); statement(false, state); return true;}
    _=>{return false;}
  }
  return true;
}

fn seq(doit: bool, state: &mut Import)
{
  while statement(doit, state) {;}
}

fn program(state: &mut Import)
{
  seq(true, state);
  if let Kind::END = state.prog[state.current] {;}
  else {panic!();}
}

/* Lexing and parsing */
fn tokenize(prog: Vec<char>) ->Vec<Kind>
{
  let mut i:usize = 0;
  let mut j:usize = 1;
  let size = prog.len();
  let mut symTable: HashMap<String,Rc<(Cell<u64>, Cell<usize>)>> = HashMap::new();
  let mut program: Vec<Kind> = Vec::new();
  while i < size
  {
    j = 1;
    while i < size && (prog[i] as char).is_whitespace(){i+=1;}
    if i >= size {break;}
    let mut kind = Kind::NONE;
    match prog[i] as char
    {
      '(' => {kind = Kind::LEFT;}
      '{' => {kind = Kind::LBRACE;}
      ')' => {kind = Kind::RIGHT;}
      '}' => {kind = Kind::RBRACE;}
      '*' => {kind = Kind::MUL;}
      '+' => {kind = Kind::PLUS;}
      '=' =>
      {
        if i+1 < size && (prog[i+1] as char) == '='
        {
          kind = Kind::EQEQ;
          j+=1;
        }
        else
        {
          kind = Kind::EQ;
        }
      }
      _ =>
      {
        if prog[i].is_digit(10)
        {
          while i+j < size && ((prog[i+j]).is_digit(10) || (prog[i+j] as char) == '_') {j+=1;}
          let int = mstrtol(&prog ,i, j);
          kind = Kind::INT(int);
        }
        else if prog[i] == 'i' && (i+1< size) && prog[i+1] == 'f' && (i+2 >= size || !prog[i+2].is_alphanumeric())
        {
          j+=1;
          kind = Kind::IF;
        }
        else if prog[i] == 'f' && i+1 < size && prog[i+1] == 'u' && i+2 <size &&  prog[i+2] == 'n' && (i+3>=size || !prog[i+3].is_alphanumeric())
        {
          j+=2;
          kind = Kind::FUN;
        }
        else if prog[i] == 'e' && i+1 < size && prog[i+1] == 'l' && i+2 <size &&  prog[i+2] == 's' && i+3 <size &&  prog[i+3] == 'e' && (i+4>=size || !prog[i+4].is_alphanumeric())
        {
          j+=3;
          kind = Kind::ELSE;
        }
        else if prog[i]=='w'&&i+1<size&&prog[i+1]=='h'&&i+2<size&&prog[i+2]=='i'&&i+3<size&&prog[i+3]=='l'&&i+4<size&&prog[i+4]=='e'&&(i+5>=size||!prog[i+5].is_alphanumeric())
        {
          j+=4;
          kind = Kind::WHILE;
        }
        else if prog[i]=='p'&&i+1<size&&prog[i+1]=='r'&&i+2<size&&prog[i+2]=='i'&&i+3<size&&prog[i+3]=='n'&&i+4<size&&prog[i+4]=='t'&&(i+5>=size||!prog[i+5].is_alphanumeric())
        {
          j+=4;
          kind = Kind::PRINT;
        }
        else if prog[i].is_alphabetic()
        {
          while i+j <size && prog[i+j].is_alphanumeric()
          {
            j+=1;
          }
          let s = & str(&prog, i, j);
          if symTable.get(s).is_none() {symTable.insert(s.clone(), Rc::new((Cell::new(0), Cell::new(0))));}
          match symTable.get(s)
          {
            Some(x)=> {kind = Kind::ID(x.clone());}
            None => {panic!();}
          }
        }
      }
    }
    i+=j;
    program.push(kind.clone());
  }
  program.push(Kind::END);
  return program;
}

fn interpret<'a>(progp: &String)
{
  let mut f = File::open(progp).expect("File Not Found");
  let mut blah = String::new();
  f.read_to_string(&mut blah).expect("something went wrong reading the file");
  let input = Vec::from(blah);
  let inputp: Vec<char> = input.iter().map(|&e| e as char).collect::<Vec<char>>();
  let mut prog = Import{prog: tokenize(inputp), current: 0};
  program(&mut prog);
}

fn main()
{
  let args: Vec<String> = env::args().collect();
  let ref blah = &args[1];
  interpret(blah);
}
