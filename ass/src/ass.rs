use std::env;
use std::fs::File;
use std::io::prelude::*;
use std::collections::HashMap;

fn translate(asm: &Vec<&str>, progp: &String)
{
  for line in asm.iter()
  {

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
