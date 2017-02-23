#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <sstream>
#include <map>
#include <algorithm>
#include <bitset>
using namespace std;

typedef std::map<string, string> BasePairMap;

int main () {

  BasePairMap m;
  m["ADD"]    ="010000";
  m["SUB"]    ="010001";
  m["AND"]    ="010010";
  m["OR"]     ="010011";
  m["NOR"]    ="010100";
  m["ADDI"]   ="000001";
  m["SUBI"]   ="000010";
  m["ANDI"]   ="000011";
  m["ORI"]    ="000100";
  m["SHL"]    ="000101";
  m["SHR"]    ="000110";
  m["LW"]     ="000111";
  m["SW"]     ="001000";
  m["BLT"]    ="001001";
  m["BEQ"]    ="001010";
  m["BNE"]    ="001011";
  m["JMP"]    ="001100";
  m["HAL"]    ="111111";
  string line;
  std::string opcode,Rd,Rs,Rt,func,str,offset;
  std::string::size_type sz;

  ifstream myfile ("code.txt");
  ofstream output ("output.txt");
  output<<"memory_initialization_radix=16;"<<endl<<"memory_initialization_vector="<<endl;
  if (myfile.is_open())
  {
    while (! myfile.eof() )
    {
      getline (myfile,line);

      vector<std::string> internal;
      string tok;
      stringstream ss(line);

      if(line == "HAL"){
        output << m.find(line)->second;
        output << bitset<26>(0)<<";"<<endl;
      }
      else{
            while(getline(ss,tok,' ')){
              internal.push_back(tok);
            }
            
            stringstream registers(internal.back());
            internal.pop_back();
            opcode= internal.back();
            internal.pop_back();
            while(getline(registers,tok,',')){
              internal.push_back(tok);
            }

            if(opcode == "ADD" || opcode == "SUB" || opcode == "AND" || opcode == "OR" || opcode == "NOR")
            {
              output << bitset<6>(0);
              func= opcode;

              Rs= internal.back();
              Rs.erase(Rs.begin()+0);
              internal.pop_back();

              Rt=internal.back();
              Rt.erase(Rt.begin()+0);
              internal.pop_back();

              Rd= internal.back();
              Rd.erase(Rd.begin()+0);
              internal.pop_back();

              output << bitset<5>(std::stoi(Rs,&sz));
              output << bitset<5>(std::stoi(Rt,&sz));
              output << bitset<5>(std::stoi(Rd,&sz));
              output << bitset<5>(0);
              output << m.find(func)->second<<","<<endl;
            }
            else if(opcode == "JMP")
            {
              output << m.find(opcode)->second;
              output << bitset<26>(std::stoi(internal.back(),&sz))<<","<<endl;
              internal.pop_back();
            }
            else if (opcode == "LW" || opcode == "SW")
            {
              /* load and store code */
              output << m.find(opcode)->second;
              stringstream ll(internal.back());
              internal.pop_back();
              while(getline(ll,tok,'('))
              {
                internal.push_back(tok);
              }
              Rs=internal.back();
              int Rs_size=Rs.size()-2;
              Rs.erase(Rs.begin()+0);
              Rs.erase(Rs.begin()+Rs_size);
              internal.pop_back();
              output << bitset<5>(std::stoi(Rs,&sz));

              offset=internal.back();
              internal.pop_back();

              Rt=internal.back();
              internal.pop_back();
              Rt.erase(Rt.begin()+0);
              output << bitset<5>(std::stoi(Rt,&sz));

              output << bitset<16>(std::stoi(offset,&sz))<<","<<endl;
            }
            else
            {
              /* all immediate type instructions */
              output << m.find(opcode)->second;

              offset=internal.back();
              internal.pop_back();

              Rs= internal.back();
              Rs.erase(Rs.begin()+0);
              internal.pop_back();

              Rt=internal.back();
              Rt.erase(Rt.begin()+0);
              internal.pop_back();

              output << bitset<5>(std::stoi(Rs,&sz));
              output << bitset<5>(std::stoi(Rt,&sz));
              output << bitset<16>(std::stoi(offset,&sz))<<","<<endl;
            }
      }

      }
    myfile.close();
    output.close();
  }

  else cout << "Unable to open file"; 

  return 0;
}

