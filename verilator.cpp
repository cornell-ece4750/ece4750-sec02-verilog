
#include <verilated.h>

#include "verilated_fst_c.h"
#include "Vtop.h"
#include <iostream>
#include <fstream>
#include "svdpi.h"
#include "Vtop__Dpi.h"



vluint64_t main_time = 0;
double sc_time_stamp() {
    return main_time;  // Note does conversion to real, to match SystemC
}
long tests;
long passed;
long failed;
std::string pass_failed;

void pass (){
    passed++;
    tests++;
    pass_failed+='+';
}
void fail (){
    failed++;
    tests++;
    pass_failed+='-';
}
int main(int argc, char** argv, char** env) {

    bool timming = false;
    bool coverage = false;
    bool waves = false;
    bool all = false;
    bool trace = false;
    std::string outname = "";
    for(int i =1; i<argc; i++){
        
            if (strcmp(argv[i], "--all") == 0) // This is your parameter name
            {                 
                all=true;    // Set flag
            }

            if (strcmp(argv[i], "--waves") == 0) // This is your parameter name
            {                 
                waves=true;    // Set flag
            }

            if (strcmp(argv[i], "--coverage") == 0) // This is your parameter name
            {                 
                coverage=true;    // Set flag
            }

            if (strcmp(argv[i], "--timming") == 0) // This is your parameter name
            {                 
                timming=true;    // Set flag
            }
            if (strcmp(argv[i], "--outname") == 0) // This is your parameter name
            {                 
                if(i+1<argc) outname = std::string(argv[i+1]) + ".";
            }

            if (strcmp(argv[i], "--trace") == 0) // This is your parameter name
            {                 
                trace=true;    // Set flag
            }
    }
    if(all){
        waves=true; 
        coverage=true;
        timming=true;
    }

    Verilated::debug(0);
    Verilated::randReset(2);
    Verilated::traceEverOn(true);
    Verilated::commandArgs(argc, argv);
    Verilated::mkdir("logs");
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->traceEverOn(true);
    Vtop* top = new Vtop{contextp.get(), "TOP"};  // Or use a const unique_ptr, or the VL_UNIQUE_PTR wrapper
      //svSetScope (svGetScopeFromName("Vtop.v"));
    VerilatedFstC* tfp = new VerilatedFstC;
    Verilated::traceEverOn(true);
    if(waves){
        top->trace(tfp, 99);  // Trace 99 levels of hierarchy
        Verilated::mkdir("waves");
        tfp->open((std::string("waves/")+outname +"waves.fst").c_str());
    }
    const int nchars = 512;
     const int nwords = nchars/4;

    uint32_t words[nwords];
    words[0] = nchars-1;
    //uint32_t* trace_str = (svBitVecVal*) malloc(5000* sizeof(svBitVecVal));
    
  
    
    top->clk = 0;
    top->linetrace =0;
    while (!Verilated::gotFinish()) {
        main_time+=1;
        top->clk = !top->clk;
        //top->reset = (main_time < 10) ? 1 : 0;
        if (main_time < 5) {
            // Zero coverage if still early in reset, otherwise toggles there may
            // falsely indicate a signal is covered   
            if(coverage){
                VerilatedCov::zero();
            }
        }else if (main_time==5 && trace){top->linetrace=1;}
        top->eval();

        if(waves){
            tfp->dump (main_time);
        }
        words[0] = nchars-1;

    }

    top->final();

    //  Coverage analysis (since test passed)

    if(coverage){
        Verilated::mkdir("logs");
        VerilatedCov::write((std::string("logs/")+outname +"coverage.dat").c_str());
    }

    if(waves){
        tfp->close();
    }
    printf("Passed %ld of %ld test\n",passed,tests);
    std::cout<<pass_failed<<"\n";
    Verilated::mkdir("results");
    std::ofstream results;
    results.open ((std::string("results/")+outname+"txt"));
    results<<pass_failed<<"\n";
    results.close();
    delete top;
    top = NULL;
    exit(0);
}