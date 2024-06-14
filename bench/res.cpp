#include <iostream>
#include <chrono>

int main() {
    typedef std::chrono::high_resolution_clock Clock;
    typedef std::chrono::nanoseconds nanoseconds;

    // Calculate the duration of one tick of the clock in nanoseconds
    auto resolution = std::chrono::duration_cast<nanoseconds>(Clock::duration(1)).count();

    std::cout << "Resolution of high_resolution_clock: " << resolution << " nanoseconds" << std::endl;

    return 0;
}
