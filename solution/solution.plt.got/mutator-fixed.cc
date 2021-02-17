/*
   目前插装的保存版，
   内容：
   //1. 使用一个boolean变量retStatus来标识ret是否发生，ret发生，则将retStatus=true，callagter位置处理后，则retStatus=false
   //使用场景：（ret的当前地址，callafter点出的当前地址）共同构成了ret的（源地址，目标地址）对，但是在callafter点处，可能由于跳转到此处，因此如果在
   //callafter点处仅仅插装输出当前地址，则跳转到此处也会导致该插装语句的执行，即输出多余的地址。
   //在ret点的处理
   //	returnStatus=true；
   //在callAfter点的处理：
   //	（1）判断returnStatus==true,true则是ret到此处，而非跳转到此处，因此可以输出当前地址作为ret的目标地址令，returnStatus=false；
   //   (2) false则得出是其他方式到此处，则当前地址不用输出.


   //2. 对于.plt.got段的函数不会被识别为动态库中的函数的处理.因为该函数通过getName()获得的函数名为targ+十六进制首地址的形式，
   //   因此获取该函数的首地址， 将首地址转换为十六进制字符串，若该字符串是函数名的子串，则说明是.plt.got段的动态库中的函数
 */
#include <stdio.h>
#include <string.h>

#include "BPatch.h"
#include "BPatch_addressSpace.h"
#include "BPatch_binaryEdit.h"
#include "BPatch_point.h"
#include "BPatch_function.h"
#include "BPatch_flowGraph.h"

#include "Instruction.h"
#include "Operand.h"

#define BUFLEN 512
#define OUTCHANNEL stdout

using namespace std;
using namespace Dyninst;
using namespace InstructionAPI;

BPatch bpatch;

vector<string> compiler_build_in = {
        "_start",
        " __libc_start_main",
        "__libc_init_first",
        "__libc_csu_init",
        "__libc_csu_fini",
        "_init",
        "__x86.get_pc_thunk.ax",
        "__x86.get_pc_thunk.bx",
        "__x86.get_pc_thunk.cx",
        "__x86.get_pc_thunk.dx",
        "__gmon_start__ ",
        "frame_dummy",
        "__do_global_dtors_aux",
        "__do_global_ctors_aux",
        "register_tm_clones",
        "deregister_tm_clones",
        "_exit",
        "__call_tls_dtors",
        "_fini",
        "__stat",
        "__fstat",
        "__plt_dispatcher",
        "__divsc3",
        "__mulsc3",
        "stat64",
        "fstat64",
        "lstat64",
        "fstatat64",
        "atexit",
        "_dl_relocate_static_pie"
};

enum InsType
{
        IJUMP,
        ICALL,
        DCALL,
        RET,
        NONE
};

bool is_compiler_build_in(string candidate_name)
{
        for (auto it = compiler_build_in.begin(); it != compiler_build_in.end(); it++)
        {
                if (candidate_name == *it)
                        return true;
        }
        return false;
}

void findFunctionEntries(BPatch_image *appImage, vector<BPatch_function *> *funcs)
{
        vector<BPatch_module *> *allModule = appImage->getModules();
        vector<BPatch_module *> useModules;
        for (auto mm = allModule->begin(); mm != allModule->end(); mm++)
        {
                if (!(*mm)->isSharedLib())
                {
                        useModules.push_back(*mm);
                }
        }
        if (useModules.size() == 0)
        {
                fprintf(OUTCHANNEL, "All modules are dynamic.\n");
                return;
        }

        funcs->clear(); //->erase(funcs->begin(),funcs->end());//clear the original func list.
        for (auto pos = useModules.begin(); pos != useModules.end(); pos++)
        {
                vector<BPatch_function *> *tmpFuncs = (*pos)->getProcedures();
                funcs->insert(funcs->end(), tmpFuncs->begin(), tmpFuncs->end());
        }

        char buffer[BUFLEN];
        vector<BPatch_function *>::iterator it = funcs->begin();
        while (it != funcs->end())
        {
                string func_name = (*it)->getName(buffer, BUFLEN);
                //fprintf(OUTCHANNEL, "%s\n",(*it)->getName(buffer, BUFLEN));
                if (is_compiler_build_in(func_name))
                {
                        it = funcs->erase(it);
                }
                else
                        it++;
        }
        // for(auto it=funcs->begin(); it!=funcs->end(); it++){
        //   fprintf(OUTCHANNEL, "%s\n", (*it)->getName(buffer, BUFLEN));
        // }
        return;
}

InsType classifyInstruction(Instruction insn)
{
        Operation op = insn.getOperation();
        //printf("%s\n", op.format().c_str());
        string op_str = op.format();
        if (op_str == "jmp")
        {
                vector<Operand> operands;
                insn.getOperands(operands);

                if (!strncmp(operands.at(0).format(Arch_x86_64).c_str(), "0x", 2) && strstr(operands.at(0).format(Arch_x86_64).c_str(), "\%rip") != NULL)
                {
                        // direct jump to offset
                }
                else if (!strncmp(operands.at(0).format(Arch_x86_64).c_str(), "\%r", 2))
                {
                        return IJUMP;
                }
                else
                {
                        fprintf(OUTCHANNEL, "%s, weird jump! \n", operands.at(0).format(Arch_x86_64).c_str());
                }
        }
        if (op_str == "call")
        {
                vector<Operand> operands;
                insn.getOperands(operands);

                if (!strncmp(operands.at(0).format(Arch_x86_64).c_str(), "0x", 2) && strstr(operands.at(0).format(Arch_x86_64).c_str(), "\%rip") != NULL)
                {
                        return DCALL;
                }
                else if (!strncmp(operands.at(0).format(Arch_x86_64).c_str(), "\%r", 2))
                {
                        // for(auto iter=operands.begin(); iter!=operands.end(); iter++) {
                        //         fprintf(OUTCHANNEL, "%s, ", (*iter).format(Arch_x86_64).c_str());
                        // }
                        // printf("\n");
                        return ICALL;
                }
                else
                {
                        fprintf(OUTCHANNEL, "%s, weird call! \n", operands.at(0).format(Arch_x86_64).c_str());
                }
        }
        if (op_str == "ret near" || op_str == "ret")
        {
                return RET;
        }
        return NONE;
}

bool get_points(BPatch_image *appImage, vector<BPatch_point *> *iJmps, vector<BPatch_point *> *iCalls,
                vector<BPatch_point *> *callAfters, vector<BPatch_point *> *rets)
{

        vector<BPatch_function *> funcs;
        findFunctionEntries(appImage, &funcs);

        for (auto pf = funcs.begin(); pf != funcs.end(); pf++)
        {
                vector<BPatch_point *> *call_sites = (*pf)->findPoint(BPatch_subroutine);
                vector<Address> dCallAddresses;

                //first find all direct calls to other local functions.
                for (auto pp = call_sites->begin(); pp != call_sites->end(); pp++)
                {
                        BPatch_point *tmp_site = *pp;
                        if (!tmp_site->isDynamic())
                        {
                                BPatch_function *tmp_callee = tmp_site->getCalledFunction();

                                if (tmp_callee != NULL && !tmp_callee->isSharedLib())
                                {
                                        //2. 对于.plt.got段的函数不会被识别为动态库中的函数的处理.因为该函数通过getName()获得的函数名为targ+十六进制首地址的形式，
                                        //   因此获取该函数的首地址， 将首地址转换为十六进制字符串，若该字符串是函数名的子串，则说明是.plt.got段的动态库中的函数
                                        int callee_addr = (Address)tmp_callee->getBaseAddr();
                                        char callee_addr_buf[20] = {0};
                                        //转为16进制字符串
                                        sprintf(callee_addr_buf, "%x", callee_addr);
                                        char funcName[50];
                                        strcpy(funcName, tmp_callee->getName().c_str());
                                        if(!strstr(funcName, callee_addr_buf)) {
                                                dCallAddresses.push_back((Address)(tmp_site->getAddress()));
                                                // printf("%s %x %s\n",funcName, callee_addr, buf);
                                        }

                                }
                        }
                }
                // for(vector<Address>::iterator it=dCallAddresses.begin(); it!=dCallAddresses.end(); it++) {
                //         fprintf(OUTCHANNEL, "0x%lx, ", (*it));
                // }
                // fprintf(OUTCHANNEL, "\n");

                BPatch_flowGraph *cfg = (*pf)->getCFG();

                set<BPatch_basicBlock *> basicblocks;
                cfg->getAllBasicBlocks(basicblocks);
                for (auto bb = basicblocks.begin(); bb != basicblocks.end(); bb++)
                {
                        vector<Instruction> insns;
                        (*bb)->getInstructions(insns);
                        Instruction lastinsn = insns[insns.size() - 1];

                        InsType ins_type = classifyInstruction(lastinsn);

                        if (ins_type != NONE)
                        {
                                Address addr = (Address)((*bb)->findExitPoint()->getAddress());

                                vector<BPatch_point *> tmp_points;
                                if (!appImage->findPoints(addr, tmp_points))
                                {
                                        fprintf(OUTCHANNEL, "Fail to get patch point from exit address of bb.\n");
                                }

                                vector<BPatch_point *> call_after_points;
                                Address call_after_addr;
                                switch (ins_type)
                                {
                                case IJUMP:
                                        iJmps->insert(iJmps->end(), tmp_points.begin(), tmp_points.end());
                                        break;
                                case ICALL:
                                        iCalls->insert(iCalls->end(), tmp_points.begin(), tmp_points.end());

                                        call_after_addr = addr + (Address)(lastinsn.size());
                                        call_after_points.clear();
                                        if (!appImage->findPoints(call_after_addr, call_after_points))
                                        {
                                                fprintf(OUTCHANNEL, "At 0x%lx: Fail to buid call-after point of indirect call 0x%lx.\n", call_after_addr, addr);
                                        }
                                        callAfters->insert(callAfters->end(), call_after_points.begin(), call_after_points.end());
                                        break;
                                case DCALL:
                                        if (find(dCallAddresses.begin(), dCallAddresses.end(), addr) != dCallAddresses.end())
                                        {
                                                call_after_addr = addr + (Address)(lastinsn.size());
                                                call_after_points.clear();
                                                if (!appImage->findPoints(call_after_addr, call_after_points))
                                                {
                                                        fprintf(OUTCHANNEL, "At 0x%lx: Fail to build call-after point of direct call 0x%lx.\n", call_after_addr, addr);
                                                }
                                                callAfters->insert(callAfters->end(), call_after_points.begin(), call_after_points.end());
                                        }
                                        break;
                                case RET:
                                        rets->insert(rets->end(), tmp_points.begin(), tmp_points.end());
                                        break;
                                }
                        }
                }
        }
        return true;
}

void display_for_sanity_check(vector<BPatch_point *> points, const char *type)
{
        for (auto iter = points.begin(); iter != points.end(); iter++)
        {
                fprintf(OUTCHANNEL, "%s:0x%lx\n", type, (Address)(*iter)->getAddress());
        }
}

/*
   //Insert print("0x%lx", addr) at "addr" in each address of "points"
   bool createAndInsertLocalAddrPrinting(BPatch_addressSpace* app, vector<BPatch_point*> points) {
   BPatch_image* appImage = app->getImage();
   vector<BPatch_snippet*> printfArgs;
   BPatch_snippet *fmt = new BPatch_constExpr("At.\n");
   printfArgs.push_back(fmt);
   //BPatch_snippet *eae = new BPatch_effectiveAddressExpr();
   //printfArgs.push_back(eae);

   vector<BPatch_function *> printfFuncs;
   appImage->findFunction("printf", printfFuncs);
   if (printfFuncs.size() == 0) {
   fprintf(OUTCHANNEL, "Could not find printf\n");
   return false;
   }
   BPatch_funcCallExpr printfCall(*(printfFuncs[0]), printfArgs);

   if (!app->insertSnippet(printfCall, points, BPatch_lastSnippet)) {
   fprintf(OUTCHANNEL, "insert local addr printing snippet failed.\n");
   return false;
   }
   return true;
   }
 */

// Find a point at function "name"
vector<BPatch_point *> *find_point_of_func(BPatch_image *appImage, const char *name, BPatch_procedureLocation loc)
{
        vector<BPatch_function *> functions;
        vector<BPatch_point *> *points;
        // Scan for functions named "name"
        appImage->findFunction(name, functions);
        if (functions.size() == 0)
        {
                fprintf(OUTCHANNEL, "No function %s\n", name);
                return points;
        }
        // Locate the relevant points
        points = functions[0]->findPoint(loc);
        if (points == NULL)
        {
                fprintf(OUTCHANNEL, "No wanted point for function %s\n", name);
        }
        return points;
}

/* @ entry of main:
   FILE *outFile=fopen(path_name, "wb+");*/
bool createAndInsertFopen(BPatch_addressSpace *app, char *path_name)
{
        BPatch_image *appImage = app->getImage();
        /*******************************/
        BPatch_type *FILEPtr = bpatch.createPointer("FILEPtr", appImage->findType("FILE"));
        BPatch_variableExpr *filePointer = app->malloc(*(appImage->findType("FILEPtr")), "outFile");

        vector<BPatch_function *> fopenFuncs;
        appImage->findFunction("fopen", fopenFuncs);
        if (fopenFuncs.size() == 0)
        {
                fprintf(OUTCHANNEL, "error: Could not find <fopen>\n");
                return false;
        }
        vector<BPatch_snippet *> fopenArgs;
        BPatch_snippet *param1 = new BPatch_constExpr(path_name);
        BPatch_snippet *param2 = new BPatch_constExpr("wt+");
        fopenArgs.push_back(param1);
        fopenArgs.push_back(param2);
        BPatch_funcCallExpr fopenCall(*(fopenFuncs[0]), fopenArgs);
        BPatch_arithExpr fileAssign(BPatch_assign, *filePointer, fopenCall);
        /*******************************/
        vector<BPatch_point *> *entryPoint = find_point_of_func(appImage, "main", BPatch_entry);
        if (!app->insertSnippet(fileAssign, *entryPoint))
        {
                fprintf(OUTCHANNEL, "error: Fail to insert <fopen>\n");
                return false;
        }
        return true;
}

/* @ exit of main:
   fclose(outFile);*/
bool createAndInsertFclose(BPatch_addressSpace *app)
{
        BPatch_image *appImage = app->getImage();
        /**********************************/
        vector<BPatch_function *> fcloseFuncs;
        appImage->findFunction("fclose", fcloseFuncs);
        if (fcloseFuncs.size() == 0)
        {
                fprintf(OUTCHANNEL, "error: Could not find <fclose>\n");
                return false;
        }
        vector<BPatch_snippet *> fcloseArgs;
        BPatch_variableExpr *var = appImage->findVariable("outFile");
        if (!var)
        {
                fprintf(OUTCHANNEL, "Could not find 'outFile' variable\n");
                return false;
        }
        else
        {
                fcloseArgs.push_back(var);
        }
        BPatch_funcCallExpr fcloseCall(*(fcloseFuncs[0]), fcloseArgs);
        /**********************************/

        vector<BPatch_point *> *exitpoint = find_point_of_func(appImage, "main", BPatch_exit);
        if (!app->insertSnippet(fcloseCall, *exitpoint, BPatch_lastSnippet))
        {
                fprintf(OUTCHANNEL, "error: Fail to insert fclose call\n");
                return false;
        }
        return true;
}

bool createAndInsertInitialization(BPatch_addressSpace *app)
{
        BPatch_image *appImage = app->getImage();

        // int addrsCube[0..519];
        BPatch_type *intArray = bpatch.createArray("intArray", appImage->findType("int"), 0, 520); //设置为256个地址对，即512个int形式，稍微给大点520
        BPatch_variableExpr *dynAddrsCube = app->malloc(*(appImage->findType("intArray")), "addrsCube");

        /* int *beginPtr;
           int *endPtr;
           int *currentPtr; */
        BPatch_type *intPtr = bpatch.createPointer("intPtr", appImage->findType("int"));
        BPatch_variableExpr *beginPtr = app->malloc(*(appImage->findType("intPtr")), "beginPtr");
        BPatch_variableExpr *endPtr = app->malloc(*(appImage->findType("intPtr")), "endPtr");
        BPatch_variableExpr *currentPtr = app->malloc(*(appImage->findType("intPtr")), "currentPtr");

        //beginPtr = &addrsCube[0];
        BPatch_snippet *firstElem = new BPatch_arithExpr(BPatch_ref, *dynAddrsCube, BPatch_constExpr(0));
        BPatch_snippet *beginPtrInit = new BPatch_arithExpr(BPatch_assign, *beginPtr, BPatch_arithExpr(BPatch_addr, *firstElem));

        //endPtr = &addrsCube[511];
        BPatch_snippet *lastElem = new BPatch_arithExpr(BPatch_ref, *dynAddrsCube, BPatch_constExpr(511));
        BPatch_snippet *endPtrInit = new BPatch_arithExpr(BPatch_assign, *endPtr, BPatch_arithExpr(BPatch_addr, *lastElem));

        //currentPtr = beginPtr;
        BPatch_snippet *currentPtrInit = new BPatch_arithExpr(BPatch_assign, *currentPtr, *beginPtr);

        //bool retStatus = false;
        BPatch_variableExpr *retStatus = app->malloc(*(appImage->findType("boolean")), "retStatus");
        BPatch_snippet *retStatusInit = new BPatch_arithExpr(BPatch_assign, *retStatus, BPatch_constExpr(false));

        vector<BPatch_snippet *> items;
        items.push_back(beginPtrInit);
        items.push_back(endPtrInit);
        items.push_back(currentPtrInit);
        items.push_back(retStatusInit);
        BPatch_sequence allItems(items);

        vector<BPatch_point *> *points = find_point_of_func(appImage, "main", BPatch_entry);
        if (points->size() != 0 && !app->insertSnippet(allItems, *points, BPatch_lastSnippet))
        {
                fprintf(OUTCHANNEL, "error: Fail to insert array and pointer initialization.\n");
                return false;
        }
        return true;
}

/* if(currentPtr > endPtr){
   fwrite(beginPtr, 1, currentPtr-beginPtr, outFile);
   currentPtr = beginPtr;
   }*/
BPatch_snippet *arrayFullSaveInFile(BPatch_image *appImage)
{
        BPatch_variableExpr *beginPtr = appImage->findVariable("beginPtr");
        BPatch_variableExpr *endPtr = appImage->findVariable("endPtr");
        BPatch_variableExpr *currentPtr = appImage->findVariable("currentPtr");

        //Find the fwrite function
        BPatch_snippet *fwriteCall;
        vector<BPatch_function *> fwriteFuncs;
        appImage->findFunction("fwrite", fwriteFuncs);
        if (fwriteFuncs.size() == 0)
        {
                fprintf(OUTCHANNEL, "error:Could not find <fwrite>\n");
                fwriteCall = NULL;
        }
        else
        {
                //fwrite(beginPtr, 1, currentPtr-beginPtr, outFile);
                vector<BPatch_snippet *> fwriteArgs;
                fwriteArgs.push_back(beginPtr);
                fwriteArgs.push_back(new BPatch_constExpr(1));
                fwriteArgs.push_back(new BPatch_arithExpr(BPatch_minus, *currentPtr, *beginPtr));
                fwriteArgs.push_back(appImage->findVariable("outFile"));
                fwriteCall = new BPatch_funcCallExpr(*(fwriteFuncs[0]), fwriteArgs);
        }

        //currentPtr = beginPtr;
        BPatch_snippet *restoreCurrentPtr = new BPatch_arithExpr(BPatch_assign, *currentPtr, *beginPtr);

        vector<BPatch_snippet *> prvItems;
        if (fwriteCall != NULL)
                prvItems.push_back(fwriteCall);
        prvItems.push_back(restoreCurrentPtr);
        BPatch_sequence prvAllItems(prvItems);

        // currentPtr > endPtr
        BPatch_boolExpr conditional(BPatch_ge, *currentPtr, *endPtr);

        return new BPatch_ifExpr(conditional, prvAllItems);
}

// Save current address to array, dump to file if array is full.
bool createAndInsertCurrentAddrStore(BPatch_addressSpace *app, vector<BPatch_point *> &points)
{
        BPatch_image *appImage = app->getImage();

        // *currentPtr = BPatch_originalAddressExpr();
        BPatch_variableExpr *currentPtr = appImage->findVariable("currentPtr");
        BPatch_snippet *oriAddr = new BPatch_arithExpr(BPatch_assign, BPatch_arithExpr(BPatch_deref, *currentPtr), BPatch_originalAddressExpr());

        // currentPtr = currentPtr + 4;
        BPatch_snippet *currentPtrAddone = new BPatch_arithExpr(BPatch_assign, *currentPtr, BPatch_arithExpr(BPatch_plus, *currentPtr, BPatch_constExpr(4)));

        BPatch_snippet *isArrayFull = arrayFullSaveInFile(appImage);

        vector<BPatch_snippet *> items;
        items.push_back(oriAddr);
        items.push_back(currentPtrAddone);
        items.push_back(isArrayFull);
        BPatch_sequence allItems(items);

        if (points.size() != 0 && !app->insertSnippet(allItems, points, BPatch_lastSnippet))
        {
                fprintf(OUTCHANNEL, "error: storing current address failed!\n");
                return false;
        }
        return true;
}

// Save target address to array, dump to file if array is full.
bool createAndInsertTargetAddrStore(BPatch_addressSpace *app, vector<BPatch_point *> &points)
{
        BPatch_image *appImage = app->getImage();

        // *currentPtr = BPatch_dynamicTargetExpr()
        BPatch_variableExpr *currentPtr = appImage->findVariable("currentPtr");
        BPatch_snippet *targetAddr = new BPatch_arithExpr(BPatch_assign, BPatch_arithExpr(BPatch_deref, *currentPtr), BPatch_dynamicTargetExpr());

        // currentPtr = currentPtr + 4;
        BPatch_snippet *currentPtrAddone = new BPatch_arithExpr(BPatch_assign, *currentPtr, BPatch_arithExpr(BPatch_plus, *currentPtr, BPatch_constExpr(4)));

        BPatch_snippet *isArrayFull = arrayFullSaveInFile(appImage);

        vector<BPatch_snippet *> items;
        items.push_back(targetAddr);
        items.push_back(currentPtrAddone);
        items.push_back(isArrayFull);
        BPatch_sequence allItems(items);

        if (points.size() != 0 && !app->insertSnippet(allItems, points, BPatch_lastSnippet))
        {
                fprintf(OUTCHANNEL, "error: storing target address failed!\n");
                return false;
        }
        return true;
}

bool createAndInsertDynamicEdges(BPatch_addressSpace *app, vector<BPatch_point *> &points)
{
        BPatch_image *appImage = app->getImage();

        // *currentPtr = BPatch_originalAddressExpr();
        BPatch_variableExpr *currentPtr = appImage->findVariable("currentPtr");
        BPatch_snippet *oriAddr = new BPatch_arithExpr(BPatch_assign, BPatch_arithExpr(BPatch_deref, *currentPtr), BPatch_originalAddressExpr());

        // currentPtr = currentPtr + 4;
        BPatch_snippet *currentPtrAddone = new BPatch_arithExpr(BPatch_assign, *currentPtr, BPatch_arithExpr(BPatch_plus, *currentPtr, BPatch_constExpr(4)));

        // *currentPtr = BPatch_dynamicTargetExpr()
        BPatch_snippet *targetAddr = new BPatch_arithExpr(BPatch_assign, BPatch_arithExpr(BPatch_deref, *currentPtr), BPatch_dynamicTargetExpr());

        BPatch_snippet *isArrayFull = arrayFullSaveInFile(appImage);

        vector<BPatch_snippet *> items;
        items.push_back(oriAddr);
        items.push_back(currentPtrAddone);
        items.push_back(targetAddr);
        items.push_back(currentPtrAddone);
        items.push_back(isArrayFull);
        BPatch_sequence allItems(items);

        if (points.size() != 0 && !app->insertSnippet(allItems, points, BPatch_lastSnippet))
        {
                fprintf(OUTCHANNEL, "error: storing current address failed!\n");
                return false;
        }
        return true;
}

//在ret处只获取当前地址，ret的目标地址通过在callafter处的当前地址获得，使用了retStatus变量标识是否是从ret到的callafter点，在ret点做两件事：
// 1.输出当前的地址作为ret的起始地址，存储到数组中，currentPtr移动到下一个存储位置
// 2.将retstatus=true
bool createAndInsertForRet(BPatch_addressSpace *app, vector<BPatch_point *> &points)
{
        BPatch_image *appImage = app->getImage();

        // 1.输出当前的地址作为ret的起始地址，存储到数组中，
        // *currentPtr = BPatch_originalAddressExpr();
        BPatch_variableExpr *currentPtr = appImage->findVariable("currentPtr");
        BPatch_snippet *oriAddr = new BPatch_arithExpr(BPatch_assign, BPatch_arithExpr(BPatch_deref, *currentPtr), BPatch_originalAddressExpr());

        //currentPtr移动到下一个存储位置
        // currentPtr = currentPtr + 4;
        BPatch_snippet *currentPtrAddone = new BPatch_arithExpr(BPatch_assign, *currentPtr, BPatch_arithExpr(BPatch_plus, *currentPtr, BPatch_constExpr(4)));

        //2.将retstatus=true
        BPatch_variableExpr *retStatus = appImage->findVariable("retStatus");
        BPatch_snippet *retStatusChange = new BPatch_arithExpr(BPatch_assign, *retStatus, BPatch_constExpr(true));

        vector<BPatch_snippet *> items;
        items.push_back(oriAddr);
        items.push_back(currentPtrAddone);
        items.push_back(retStatusChange);
        BPatch_sequence allItems(items);

        if (points.size() != 0 && !app->insertSnippet(allItems, points, BPatch_lastSnippet))
        {
                fprintf(OUTCHANNEL, "error: storing current address failed!\n");
                return false;
        }
        return true;
}

//对call after的点进行插装，获取当前地址作为ret的目标地址，需要先判断retstatus==true是否成立，成立则此时是从ret处到的callafter点，则需要做三件事情：
// 1.输出当前的地址作为ret的目标地址，存储到数组中，currentPtr移动到下一个存储位置
// 2.将retstatus=false
// 3.判断数组是否满，满则输出到文件
bool createAndInsertForCallAfter(BPatch_addressSpace *app, vector<BPatch_point *> &points)
{
        BPatch_image *appImage = app->getImage();
        //0. 判断retstatus==true是否成立
        BPatch_variableExpr *retStatus = appImage->findVariable("retStatus");
        BPatch_boolExpr condition(BPatch_eq, *retStatus, BPatch_constExpr(true));

        // 1.输出当前的地址作为ret的目标地址，存储到数组中，
        // *currentPtr = BPatch_originalAddressExpr();
        BPatch_variableExpr *currentPtr = appImage->findVariable("currentPtr");
        BPatch_snippet *oriAddr = new BPatch_arithExpr(BPatch_assign, BPatch_arithExpr(BPatch_deref, *currentPtr), BPatch_originalAddressExpr());

        // currentPtr移动到下一个存储位置
        // currentPtr = currentPtr + 4;
        BPatch_snippet *currentPtrAddone = new BPatch_arithExpr(BPatch_assign, *currentPtr, BPatch_arithExpr(BPatch_plus, *currentPtr, BPatch_constExpr(4)));

        // 2.将retstatus=false
        BPatch_snippet *retStatusRestore = new BPatch_arithExpr(BPatch_assign, *retStatus, BPatch_constExpr(false));

        // 3.判断数组是否满，满则输出到文件
        BPatch_snippet *isArrayFull = arrayFullSaveInFile(appImage);

        vector<BPatch_snippet *> items;
        items.push_back(oriAddr);
        items.push_back(currentPtrAddone);
        items.push_back(retStatusRestore);
        items.push_back(isArrayFull);
        BPatch_sequence thenbody(items);

        BPatch_ifExpr getRetDest(condition, thenbody);

        if (points.size() != 0 && !app->insertSnippet(getRetDest, points, BPatch_lastSnippet))
        {
                fprintf(OUTCHANNEL, "error: storing current address failed!\n");
                return false;
        }
        return true;
}

// Dump the rest content of array to file at the exit of main.
bool createAndInsertDumpMainExit(BPatch_addressSpace *app)
{
        BPatch_image *appImage = app->getImage();

        BPatch_variableExpr *beginPtr = appImage->findVariable("beginPtr");
        BPatch_variableExpr *currentPtr = appImage->findVariable("currentPtr");

        BPatch_snippet *fwriteCall;
        vector<BPatch_function *> fwriteFuncs;
        appImage->findFunction("fwrite", fwriteFuncs);
        if (fwriteFuncs.size() == 0)
        {
                fprintf(OUTCHANNEL, "error:Could not find <fwrite>\n");
                fwriteCall = NULL;
        }
        else
        {
                //fwrite(beginPtr, 1, currentPtr-beginPtr, outFile);
                vector<BPatch_snippet *> fwriteArgs;
                fwriteArgs.push_back(beginPtr);
                fwriteArgs.push_back(new BPatch_constExpr(1));
                fwriteArgs.push_back(new BPatch_arithExpr(BPatch_minus, *currentPtr, *beginPtr));
                fwriteArgs.push_back(appImage->findVariable("outFile"));
                fwriteCall = new BPatch_funcCallExpr(*(fwriteFuncs[0]), fwriteArgs);
        }

        vector<BPatch_snippet *> items;
        if (fwriteCall != NULL)
                items.push_back(fwriteCall);
        BPatch_sequence allItems(items);

        //store the ret point of main function
        vector<BPatch_point *> *mainRetPoints = find_point_of_func(appImage, "main", BPatch_exit);
        // printf("get the main func exit address:\n");
        // for(auto pp = mainRetPoints->begin(); pp != mainRetPoints->end(); pp++) {
        //         BPatch_point* apoint = *pp;
        //         printf("0x%x ", (Address)apoint->getAddress());
        // }

        if (mainRetPoints->size() != 0 && !app->insertSnippet(allItems, *mainRetPoints, BPatch_lastSnippet))
        {
                fprintf(OUTCHANNEL, "error: Fail to dump array at returns of main!\n");
                return false;
        }
        return true;
}

int main(int argc, char **argv)
{

        if (argc != 3)
        {
                fprintf(OUTCHANNEL, "Usage: mutator [mutatee_path] [mutatee_out_path]");
                return 0;
        }
        // Set up information about the program to be instrumented
        const char *mutatee_path = argv[1];
        // open mutatee
        BPatch_addressSpace *app = bpatch.openBinary(mutatee_path, true);
        if (!app)
        {
                fprintf(OUTCHANNEL, "openBinary failed\n");
                exit(1);
        }
        BPatch_image *appImage = app->getImage();

        bpatch.setTrampRecursive(true);
        bpatch.setSaveFPR(false);

        vector<BPatch_point *> iJmps;
        vector<BPatch_point *> iCalls;
        vector<BPatch_point *> callAfters;
        vector<BPatch_point *> rets;
        get_points(appImage, &iJmps, &iCalls, &callAfters, &rets);

        display_for_sanity_check(iJmps, "IJMP");
        display_for_sanity_check(iCalls, "ICALL");
        display_for_sanity_check(rets, "RET");
        display_for_sanity_check(callAfters, "CALLAFTER");

        // Create and insert instrumentation snippet
        // if (!createAndInsertLocalAddrPrinting(app, iJmps)) {
        //         fprintf(OUTCHANNEL, "createAndInsertLocalAddrPrinting failed\n");
        //         exit(1);
        // }
        //
        char addr_file_path[BUFLEN];
        strcpy(addr_file_path, argv[2]);
        strcat(addr_file_path, "-re");
        if (!createAndInsertFopen(app, addr_file_path))
        {
                fprintf(OUTCHANNEL, "createAndInsertFopen failed\n");
                exit(1);
        } else {
                fprintf(OUTCHANNEL, "createAndInsertFopen successed\n");
        }
        if (!createAndInsertInitialization(app))
        {
                fprintf(OUTCHANNEL, "createAndInsertInitialization failed\n");
                exit(1);
        }else {
                fprintf(OUTCHANNEL, "createAndInsertInitialization successed\n");
        }
        /*****************************************************************/
        /* depreciated:
           if(!createAndInsertCurrentAddrStore(app, rets)) {
                 fprintf(OUTCHANNEL, "createAndInsertCurrentAddrStore failed\n");
                 exit(1);
           }
           if(!createAndInsertTargetAddrStore(app, rets)) {
                 fprintf(OUTCHANNEL, "createAndInsertTargetAddrStore failed\n");
                 exit(1);
           }

           if(!createAndInsertCurrentAddrStore(app, iJmps)) {
                 fprintf(OUTCHANNEL, "createAndInsertCurrentAddrStore failed\n");
                 exit(1);
           }
           if(!createAndInsertTargetAddrStore(app, iJmps)) {
                 fprintf(OUTCHANNEL, "createAndInsertTargetAddrStore failed\n");
                 exit(1);
           }

           if(!createAndInsertCurrentAddrStore(app, iCalls)) {
                 fprintf(OUTCHANNEL, "createAndInsertCurrentAddrStore failed\n");
                 exit(1);
           }
           if(!createAndInsertTargetAddrStore(app, iCalls)) {
                 fprintf(OUTCHANNEL, "createAndInsertTargetAddrStore failed\n");
                 exit(1);
           }
         */

        if (!createAndInsertDynamicEdges(app, iJmps))
        {
                fprintf(OUTCHANNEL, "createAndInsertDynamicEdges for ijumps failed\n");
                exit(1);
        }else {
                fprintf(OUTCHANNEL, "ijumps successed\n");
        }
        if (!createAndInsertDynamicEdges(app, iCalls))
        {
                fprintf(OUTCHANNEL, "createAndInsertDynamicEdges for icalls failed\n");
                exit(1);
        }else {
                fprintf(OUTCHANNEL, "icalls successed\n");
        }
        if (!createAndInsertForRet(app, rets))
        {
                fprintf(OUTCHANNEL, "createAndInsert for returns failed\n");
                exit(1);
        }else {
                fprintf(OUTCHANNEL, "returns successed\n");
        }
        if (!createAndInsertForCallAfter(app, callAfters))
        {
                fprintf(OUTCHANNEL, "createAndInsert for callafters failed\n");
                exit(1);
        }else {
                fprintf(OUTCHANNEL, "callafters successed\n");
        }

        /*****************************************************************/
        //dump array should be ahead of fclose.
        if (!createAndInsertDumpMainExit(app))
        {
                fprintf(OUTCHANNEL, "createAndInsertDumpMainExit failed\n");
                exit(1);
        }
        if (!createAndInsertFclose(app))
        {
                fprintf(OUTCHANNEL, "createAndInsertFclose failed\n");
                exit(1);
        }

        // Finish instrumentation
        const char *mutatee_out_path = argv[2];
        BPatch_binaryEdit *appBin = dynamic_cast<BPatch_binaryEdit *>(app);
        if (appBin)
        {
                if (!appBin->writeFile(mutatee_out_path))
                {
                        fprintf(OUTCHANNEL, "write binary failed\n");
                }
        }
}
