# dyninst配置文档
当前最新版本的dyninst均是以源码的形式进行安装，同时dyninst在编译过程中能自动识别32位系统还是64位系统，因此32位和64位系统下安装步骤一致。  
Dyninst网站地址：https://dyninst.org/, 在该网站中的download目录中可以获取最新版的dyninst源码的下载地址。  
以下内容包括两个部分，一是dyninst的安装及配置，二是测试用例，用以测试安装的dyninst能否运行。  

## 一、安装及配置步骤：
### 第一步：  
安装dyninst工作所需要的其他软件：  
`sudo apt-get install cmake libblkid-dev e2fslibs-dev libboost-all-dev libaudit-dev texlive-latex-base libelf-dev libdwarf-dev libiberty-dev`

### 第二步：  
安装dyninst，安装需要指定dyninst源码文件夹的路径，或者直接在该文件夹下打开终端进行cmake则可省略此项。-DCMAKE_INSTALL_PREFIX用于指定存放头文件，编译过程中生成的动态库，dyninst库文档等内容的文件夹。  
`cmake /dyninst源码文件夹的路径/ -DCMAKE_INSTALL_PREFIX=/存放安装后相关内容的文件夹路径/`  
比如我存放dyninst的文件夹路径是/home/zym/文档/dyninst-10.1.0，我希望存放安装后的相关内容的文件夹为/home/zym/文档/dyninst-10.1.0_install，因此我的安装命令为  
`cmake /home/zym/文档/dyninst-10.1.0 -DCMAKE_INSTALL_PREFIX=/home/zym/文档/dyninst-10.1.0_install`  
Make安装  
`make install`  
注意：在安装过程中可能会提示缺少相关的软件，则只需要安装提示的软件，继续执行安装即可。  

### 第三步：
将上一步骤中-DCMAKE_INSTALL_PREFIX项指定的文件夹中的include文件夹，lib文件夹中的内容分别复制到/usr/local/include，/usr/local/lib中。  
比如我的安装目录是/home/zym/文档/dyninst-10.1.0_install，则复制命令如下：  
```
cd -r /home/zym/文档/dyninst-10.1.0_install/include/* /usr/local/include/
cd -r /home/zym/文档/dyninst-10.1.0_install/lib/*  /usr/local/lib/
```

### 第四步：
配置
###### 1.设置运行环境
`vim ~/.bashrc`
在该.bashrc文件末尾添加
```
DYNINST_INCLUDE=/usr/local/include
DYNINST_LIB=/usr/local/lib
export DYNINSTAPI_RT_LIB=$DYNINST_LIB/libdyninstAPI_RT.so
```
###### 2.编辑/etc/sysctl.d/10-ptrace.conf中的kernel.yama.ptrace_scope，将其从值为1改成0  
  `vim /etc/sysctl.d/10-ptrace.conf `   
  `kernel.yama.ptrace_scope = 0`
###### 3.将dyninst共享库的位置加入标准路径中  
```
cd /etc
sudo gedit ld.so.conf
```
通常ld.so.conf文件中内容为“include /etc/ld.so.conf.d/*.conf”，将共享库文件的位置/usr/local/lib添加最后，保存之后关掉。
###### 4.终端中输入下面这句话更新一下共享库  
  `sudo ldconfig`
###### 5.重启电脑  

## 二、测试用例：
### Dyninst插装程序：
测试程序的作用是插入一个myCounter的int形式的全局变量，并将作用相当于myCounter=myCounter+1的语句插装当被插装的可执行文件的InterestingProcedure函数进入点，同时在main函数的退出点插装一条输出myCounter值的语句。达到的效果是通过myCounter变量记录InterestingProcedure函数的被调用次数，最后在main函数执行到结束时输出该调用次数。
```
//example.cpp
#include <stdio.h>
#include "BPatch.h"
#include "BPatch_addressSpace.h"
#include "BPatch_process.h"
#include "BPatch_binaryEdit.h"
#include "BPatch_point.h"
#include "BPatch_function.h"

using namespace std;
using namespace Dyninst;
// Create an instance of class BPatch
BPatch bpatch;
// Different ways to perform instrumentation
typedef enum {
	create,
	attach,
	open
} accessType_t;
// Attach, create, or open a file for rewriting
BPatch_addressSpace* startInstrumenting(accessType_t accessType, const char* name,int pid,const char* argv[]) {
	BPatch_addressSpace* handle = NULL;
	switch(accessType) {
		case create:
			handle = bpatch.processCreate(name, argv);
			if (!handle) { fprintf(stderr, "processCreate failed\n"); }
			break;
		case attach:
			handle = bpatch.processAttach(name, pid);
			if (!handle) { fprintf(stderr, "processAttach failed\n"); }
			break;
		case open:
		// Open the binary file and all dependencies
			handle = bpatch.openBinary(name, true);
			if (!handle) { fprintf(stderr, "openBinary failed\n"); }
			break;
	}
	return handle;
}
// Find a point at which to insert instrumentation
std::vector<BPatch_point*>* findPoint(BPatch_addressSpace* app,const char* name,BPatch_procedureLocation loc) {
	std::vector<BPatch_function*> functions;
	std::vector<BPatch_point*>* points;
	// Scan for functions named "name"
	BPatch_image* appImage = app->getImage();
	appImage->findFunction(name, functions);
	if (functions.size() == 0) {
		fprintf(stderr, "No function %s\n", name);
		return points;
	} else if (functions.size() > 1) {
		fprintf(stderr, "More than one %s; using the first one\n", name);
	}
	// Locate the relevant points
	points = functions[0]->findPoint(loc);
	return points;
}
// Create and insert an increment snippet
bool createAndInsertSnippet(BPatch_addressSpace* app,std::vector<BPatch_point*>* points) {
	BPatch_image* appImage = app->getImage();
	// Create an increment snippet
	BPatch_variableExpr* intCounter =
	app->malloc(*(appImage->findType("int")), "myCounter");
	BPatch_arithExpr addOne(BPatch_assign,*intCounter,BPatch_arithExpr(BPatch_plus,*intCounter,BPatch_constExpr(1)));
    // Insert the snippet
	if (!app->insertSnippet(addOne, *points)) {
		fprintf(stderr, "insertSnippet failed\n");
		return false;
	}
	return true;
}
// Create and insert a printf snippet
bool createAndInsertSnippet2(BPatch_addressSpace* app,std::vector<BPatch_point*>* points) {
	BPatch_image* appImage = app->getImage();
	// Create the printf function call snippet
	std::vector<BPatch_snippet*> printfArgs;
	BPatch_snippet* fmt =new BPatch_constExpr("InterestingProcedure called %d times\n");
	printfArgs.push_back(fmt);
	BPatch_variableExpr* var = appImage->findVariable("myCounter");
	if (!var) {
		fprintf(stderr, "Could not find 'myCounter' variable\n");
		return false;
	} else {
		printfArgs.push_back(var);
	}
	// Find the printf function
	std::vector<BPatch_function*> printfFuncs;
	appImage->findFunction("printf", printfFuncs);
	if (printfFuncs.size() == 0) {
		fprintf(stderr, "Could not find printf\n");
		return false;
	}
	// Construct a function call snippet
	BPatch_funcCallExpr printfCall(*(printfFuncs[0]), printfArgs);
	// Insert the snippet
	if (!app->insertSnippet(printfCall, *points)) {
		fprintf(stderr, "insertSnippet failed\n");
		return false;
	}
	return true;
}
void finishInstrumenting(BPatch_addressSpace* app, const char* newName)
{
	BPatch_process* appProc = dynamic_cast<BPatch_process*>(app);
	BPatch_binaryEdit* appBin = dynamic_cast<BPatch_binaryEdit*>(app);
	if (appProc) {
		if (!appProc->continueExecution()) {
			fprintf(stderr, "continueExecution failed\n");
		}
		while (!appProc->isTerminated()) {
			bpatch.waitForStatusChange();
		}
	} else if (appBin) {
		if (!appBin->writeFile(newName)) {
			fprintf(stderr, "writeFile failed\n");
		}
	}
}

int main(int argc, char * argv[]) {
	// Set up information about the program to be instrumented
	const char* progName = argv[1];
	int progPID = 42;
	const char* progArgv[] = {argv[1], "-h", NULL};
	accessType_t mode = create;
	// Create/attach/open a binary
	BPatch_addressSpace* app =
	startInstrumenting(mode, progName, progPID, progArgv);
	if (!app) {
		fprintf(stderr, "startInstrumenting failed\n");
		exit(1);
	}
	// Find the entry point for function InterestingProcedure
	const char* interestingFuncName = "InterestingProcedure";
	std::vector<BPatch_point*>* entryPoint =findPoint(app, interestingFuncName, BPatch_entry);
	if (!entryPoint || entryPoint->size() == 0) {
		fprintf(stderr, "No entry points for %s\n", interestingFuncName);
		exit(1);
	}
	// Create and insert instrumentation snippet
	if (!createAndInsertSnippet(app, entryPoint)) {
		fprintf(stderr, "createAndInsertSnippet failed\n");
		exit(1);
	}
	// Find the exit point of main
	std::vector<BPatch_point*>* exitPoint = findPoint(app, "main", BPatch_exit);  //no exits for main. so i change to InterestingProcedure
	if (!exitPoint || exitPoint->size() == 0) {
		fprintf(stderr, "No exit points for main\n");
		exit(1);
	}
	// Create and insert instrumentation snippet 2
	if (!createAndInsertSnippet2(app, exitPoint)) {
		fprintf(stderr, "createAndInsertSnippet2 failed\n");
		exit(1);
	}
	// Finish instrumentation
	const char* progName2 = "InterestingProgram-rewritten";
	finishInstrumenting(app, progName2);
}
```

### 被插装程序：
```
//InterestingProgram.c
#include<stdio.h>
#include<unistd.h>
void InterestingProcedure(){
     printf("this is a interesting program,pid is %d \n",getpid());
}
int main()
{
    //while(1){
    for(int i=0;i<5;i++){
       InterestingProcedure();
       sleep(5);
    }
return 0;
}
```

### Dynisnt插装程序的makefile：
```
# example.cpp的makefile
LIBS =  -L/usr/local/lib -ldyninstAPI  -lparseAPI -linstructionAPI -lsymtabAPI  -ldwarf  -lcommon -ldynElf -lboost_system
HEADERS = -I/usr/local/include
src = example.cpp 
tar = example

$(tar):$(src)
	g++ -std=c++0x -o $@ $^ $(LIBS) $(HEADERS)

.PRONY:
	clean
clean:
	 rm -rf $(tar)
```

#### 1. 进行测试
```
gcc -O0 InterestingProgram.c -o InterestingProgram
make
./example InterestingProgram
```
#### 2. 正确的测试结果
```
this is a interesting program, pid is 3289
this is a interesting program, pid is 3289
this is a interesting program, pid is 3289
this is a interesting program, pid is 3289
this is a interesting program, pid is 3289
InterestingProcedure called 5 times
```

