use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::collections::HashMap;

//This will assemble the project
fn assemble(prog: Vec<Line>)
{
  match peek(state)
  {
    Line::ID(id) =>
    {
      let back = getId(state);
      consume(state);
      match peek(state)
      {
        Line::LEFT =>
        {
          consume(state);
          match peek(state)
          {
            Line::RIGHT =>
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
        Line::EQ =>
        {
          consume(state);
          let mut v = expression(state);
          if doit {set(state, back, &mut v);}
          return true;
        }
        _=> {panic!();}
      }
    }
    Line::LBRACE =>
    {
      consume(state);
      seq(doit, state);
      match peek(state)
      {
        Line::RBRACE =>
        {
          consume(state);
          return true;
        }
        _=> {panic!();}
      }
    }
    Line::IF =>
    {
      consume(state);
      let t = expression(state).0;
      statement(doit && (t != 0), state);
      if peek(state) == Line::ELSE {consume(state); statement(doit && (t==0), state);}
      return true;
    }
    Line::WHILE =>
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
    Line::PRINT =>
    {
      consume(state);
      let a = expression(state);
      if doit {println!("{}", a.0);}
      return true;
    }
    Line::SEMI => {panic!();}
    Line::FUN => {consume(state); statement(false, state); return true;}
    _=>{return false;}
  }
  return true;
}
#[derive(Clone)]
enum Line
{
  NONE,
  DATAM,
  TEXTM,
  MOH(u8, u8),
  RET,
  SET(u8),
  LAB(String),
  ADD(u8,u8),
  SUB(u8,u8),
  MUL(u8,u8),
  JZZ(u8, String),
  JMP(u8,String),
  PUS(u8),
  POP(u8)
}

//do the translation
fn translate(asm: &Vec<&str>, progp: &String)
{
  let output:Vec<Line> = Vec::new();
  for line in asm.iter()
  {
    let inputp:Vec<u8> = Vec::from(*line);
    let input: Vec<char> = input.iter().map(|&e| e as char).collect::<Vec<char>>();
  let mut i:usize = 0;
  let mut j:usize = 1;
  let size = input.len();
    while i < size
    {
    j = 1;
    while i < size && (prog[i] as char).is_whitespace(){i+=1;}
    if i >= size {break;}
    let mut kind = Line::NONE;
    match prog[i] as char
    {
      '.' => {kind = Line::LEFT;}
      '{' => {kind = Line::LBRACE;}
      ')' => {kind = Line::RIGHT;}
      '}' => {kind = Line::RBRACE;}
      '*' => {kind = Line::MUL;}
      '+' => {kind = Line::PLUS;}
      '=' =>
      {
        if i+1 < size && (prog[i+1] as char) == '='
        {
          kind = Line::EQEQ;
          j+=1;
        }
        else
        {
          kind = Line::EQ;
        }
      }
      _ =>
      {
        if prog[i].is_digit(10)
        {
          while i+j < size && ((prog[i+j]).is_digit(10) || (prog[i+j] as char) == '_') {j+=1;}
          let int = mstrtol(&prog ,i, j);
          kind = Line::INT(int);
        }
        else if prog[i] == 'i' && (i+1< size) && prog[i+1] == 'f' && (i+2 >= size || !prog[i+2].is_alphanumeric())
        {
          j+=1;
          kind = Line::IF;
        }
        else if prog[i] == 'f' && i+1 < size && prog[i+1] == 'u' && i+2 <size &&  prog[i+2] == 'n' && (i+3>=size || !prog[i+3].is_alphanumeric())
        {
          j+=2;
          kind = Line::FUN;
        }
        else if prog[i] == 'e' && i+1 < size && prog[i+1] == 'l' && i+2 <size &&  prog[i+2] == 's' && i+3 <size &&  prog[i+3] == 'e' && (i+4>=size || !prog[i+4].is_alphanumeric())
        {
          j+=3;
          kind = Line::ELSE;
        }
        else if prog[i]=='w'&&i+1<size&&prog[i+1]=='h'&&i+2<size&&prog[i+2]=='i'&&i+3<size&&prog[i+3]=='l'&&i+4<size&&prog[i+4]=='e'&&(i+5>=size||!prog[i+5].is_alphanumeric())
        {
          j+=4;
          kind = Line::WHILE;
        }
        else if prog[i]=='p'&&i+1<size&&prog[i+1]=='r'&&i+2<size&&prog[i+2]=='i'&&i+3<size&&prog[i+3]=='n'&&i+4<size&&prog[i+4]=='t'&&(i+5>=size||!prog[i+5].is_alphanumeric())
        {
          j+=4;
          kind = Line::PRINT;
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
            Some(x)=> {kind = Line::ID(x.clone());}
            None => {panic!();}
          }
        }
      }
    }
    i+=j;
    program.push(kind.clone());
  }
  program.push(Line::END);
  return program;
  }
}

fn interpret(progp: &String)
{
  let mut f = File::open(progp).expect("File Not Found");
  let mut blah = String::new();
  f.read_to_string(&mut blah).expect("something went wrong reading the file");
  let input:Vec<&str> = blah.split('\n').collect();

  translate(&input, progp);
}

fn main()
{
  let args: Vec<String> = env::args().collect();
  let ref blah = &args[1];
  interpret(blah);
}
