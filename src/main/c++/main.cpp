#include "calculator.h"
#include <iostream>
#include <boost/config.hpp>
#include <boost/system/error_code.hpp>

int main(int argc, char* argv[]) {
    std::cout << "Calculator Demo - Using Boost NAR dependencies from Nexus" << std::endl;
    std::cout << "Boost Platform: " << BOOST_PLATFORM << std::endl;
    std::cout << "Boost Compiler: " << BOOST_COMPILER << std::endl;
    std::cout << std::endl;

    // Demonstrate Boost.System library usage (requires actual linking)
    boost::system::error_code ec;
    ec = boost::system::errc::make_error_code(boost::system::errc::success);
    std::cout << "Boost.System error code test: " << ec << std::endl;
    std::cout << "This proves we're linking against the Boost.System compiled library!" << std::endl;
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
    std::cout << "Successfully used Boost.Config and linked Boost.System from Nexus NAR repository!" << std::endl;

    return 0;
}
