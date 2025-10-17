#include "calculator.h"
#include <iostream>

int main(int argc, char* argv[]) {
    std::cout << "Calculator Demo - Using Boost NAR dependencies from Nexus" << std::endl;
    std::cout << std::endl;

    Calculator calc;

    int result_add = calc.add(5, 3);
    std::cout << "5 + 3 = " << result_add << std::endl;

    int result_sub = calc.subtract(5, 3);
    std::cout << "5 - 3 = " << result_sub << std::endl;

    int result_mul = calc.multiply(5, 3);
    std::cout << "5 * 3 = " << result_mul << std::endl;

    double result_div = calc.divide(5, 3);
    std::cout << "5 / 3 = " << result_div << std::endl;

    std::cout << std::endl << "Calculator demo completed successfully!" << std::endl;
    std::cout << "Successfully linked against Boost libraries from Nexus!" << std::endl;

    return 0;
}
