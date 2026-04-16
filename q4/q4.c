#include <stdio.h>
#include <dlfcn.h> //library which helps which accessing shared libraries at runtime
#include <string.h>

int main() {

    char op[6];
    int num1, num2;

    while (scanf("%s %d %d", op, &num1, &num2) == 3) { //loop exits when scanf hits EOF instead of blocking forever

        char libname[16] = "./lib"; // ./ signifies current directory
        strcat(libname, op);
        strcat(libname, ".so");

        void *lib = dlopen(libname, RTLD_LAZY);
        //when an so is called,it may reference functions/variables corresponding to actual memory addresses, RTLD_LAZY does this only when these func/variables are called

        int (*fn)(int, int) = dlsym(lib, op); //searches for op inside the lib and returns the function pointer

        printf("%d\n", fn(num1, num2));

        dlclose(lib);  // unload immediately to stay under memory limit
    }
}
//compile with the -ldl tag