#include "calculator.h"
#include <log4cplus/logger.h>
#include <log4cplus/loggingmacros.h>
#include <log4cplus/configurator.h>
#include <iostream>

int main(int argc, char* argv[]) {
    // Initialize log4cplus (from NAR dependency)
    log4cplus::initialize();
    log4cplus::BasicConfigurator config;
    config.configure();

    log4cplus::Logger logger = log4cplus::Logger::getInstance(LOG4CPLUS_TEXT("main"));

    Calculator calc;

    LOG4CPLUS_INFO(logger, LOG4CPLUS_TEXT("Calculator Demo (C++11) - Using log4cplus from NAR"));

    int result_add = calc.add(5, 3);
    LOG4CPLUS_INFO(logger, LOG4CPLUS_TEXT("5 + 3 = ") << result_add);
    std::cout << "5 + 3 = " << result_add << std::endl;

    int result_sub = calc.subtract(5, 3);
    LOG4CPLUS_INFO(logger, LOG4CPLUS_TEXT("5 - 3 = ") << result_sub);
    std::cout << "5 - 3 = " << result_sub << std::endl;

    int result_mul = calc.multiply(5, 3);
    LOG4CPLUS_INFO(logger, LOG4CPLUS_TEXT("5 * 3 = ") << result_mul);
    std::cout << "5 * 3 = " << result_mul << std::endl;

    double result_div = calc.divide(5, 3);
    LOG4CPLUS_INFO(logger, LOG4CPLUS_TEXT("5 / 3 = ") << result_div);
    std::cout << "5 / 3 = " << result_div << std::endl;

    LOG4CPLUS_INFO(logger, LOG4CPLUS_TEXT("Calculator demo completed successfully"));

    return 0;
}
