#include <iostream>
#include <Eigen/Dense>
#include <chrono>

const int reps = 1e6;

/*  Written in 2015 by Sebastiano Vigna (vigna@acm.org)

To the extent possible under law, the author has dedicated all copyright
and related and neighboring rights to this software to the public domain
worldwide. This software is distributed without any warranty.

See <http://creativecommons.org/publicdomain/zero/1.0/>. */

#include <stdint.h>

/* This is a fixed-increment version of Java 8's SplittableRandom generator
   See http://dx.doi.org/10.1145/2714064.2660195 and
   http://docs.oracle.com/javase/8/docs/api/java/util/SplittableRandom.html

   It is a very fast generator passing BigCrush, and it can be useful if
   for some reason you absolutely want 64 bits of state. */

static uint64_t x; /* The state can be seeded with any value. */

uint64_t next()
{
        uint64_t z = (x += 0x9e3779b97f4a7c15);
        z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
        z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
        return z ^ (z >> 31);
}

int main()
{
        {
                // Define two 3x3 matrices
                Eigen::Matrix2d matA;
                Eigen::Matrix2d matB;
                Eigen::Matrix2d matC;

                std::chrono::duration<double> duration(0);

                for (int i = 0; i != 2; ++i)
                {
                        for (int j = 0; j != 2; ++j)
                        {
                                matA(i, j) = next();
                                matB(i, j) = next();
                        }
                }
                auto start = std::chrono::high_resolution_clock::now();
                for (int rep = 0; rep != reps; ++rep)
                {
                        matC = matA * matB;
                }
                auto end = std::chrono::high_resolution_clock::now();
                duration = end - start;

                auto tm = duration.count() / reps * 1e9;

                // Output the result and the time taken
                std::cout << "Time taken for " << reps << " 2x2 multiplications: " << tm << " nanoseconds" << std::endl;
        }

        {
                // Define two 3x3 matrices
                Eigen::Matrix3d matA;
                Eigen::Matrix3d matB;
                Eigen::Matrix3d matC;

                std::chrono::duration<double> duration(0);

                for (int rep = 0; rep != reps; ++rep)
                {
                        for (int i = 0; i != 3; ++i)
                        {
                                for (int j = 0; j != 3; ++j)
                                {
                                        matA(i, j) = next();
                                        matB(i, j) = next();
                                }
                        }
                        auto start = std::chrono::high_resolution_clock::now();
                        matC = matA * matB;
                        auto end = std::chrono::high_resolution_clock::now();
                        duration += end - start;
                }

                auto tm = duration.count() / reps * 1e9;

                // Output the result and the time taken
                std::cout << "Time taken for " << reps << " 3x3 multiplications: " << tm << " nanoseconds" << std::endl;
        }

        {
                // Define two 3x3 matrices
                Eigen::Matrix4d matA;
                Eigen::Matrix4d matB;
                Eigen::Matrix4d matC;

                std::chrono::duration<double> duration(0);

                for (int rep = 0; rep != reps; ++rep)
                {
                        for (int i = 0; i != 4; ++i)
                        {
                                for (int j = 0; j != 4; ++j)
                                {
                                        matA(i, j) = next();
                                        matB(i, j) = next();
                                }
                        }
                        auto start = std::chrono::high_resolution_clock::now();
                        matC = matA * matB;
                        auto end = std::chrono::high_resolution_clock::now();
                        duration += end - start;
                }

                auto tm = duration.count() / reps * 1e9;

                // Output the result and the time taken
                std::cout << "Time taken for " << reps << " 4x4 multiplications: " << tm << " nanoseconds" << std::endl;
        }

        {
                // Define two 3x3 matrices
                Eigen::Matrix<double, 8, 8> matA;
                Eigen::Matrix<double, 8, 8> matB;
                Eigen::Matrix<double, 8, 8> matC;

                std::chrono::duration<double> duration(0);

                for (int rep = 0; rep != reps; ++rep)
                {
                        for (int i = 0; i != 8; ++i)
                        {
                                for (int j = 0; j != 8; ++j)
                                {
                                        matA(i, j) = next();
                                        matB(i, j) = next();
                                }
                        }
                        auto start = std::chrono::high_resolution_clock::now();
                        matC = matA * matB;
                        auto end = std::chrono::high_resolution_clock::now();
                        duration += end - start;
                }

                auto tm = duration.count() / reps * 1e9;

                // Output the result and the time taken
                std::cout << "Time taken for " << reps << " 8x8 multiplications: " << tm << " nanoseconds" << std::endl;
        }

        {
                // Define two 3x3 matrices
                Eigen::Matrix<double, 16, 16> matA;
                Eigen::Matrix<double, 16, 16> matB;
                Eigen::Matrix<double, 16, 16> matC;

                std::chrono::duration<double> duration(0);

                for (int i = 0; i != 16; ++i)
                {
                        for (int j = 0; j != 16; ++j)
                        {
                                matA(i, j) = next();
                                matB(i, j) = next();
                        }
                }
                auto start = std::chrono::high_resolution_clock::now();
                for (int rep = 0; rep != reps; ++rep)
                {
                        matC = matA * matB;
                }
                auto end = std::chrono::high_resolution_clock::now();
                duration = end - start;

                auto tm = duration.count() / reps * 1e9;

                // Output the result and the time taken
                std::cout << "Time taken for " << reps << " 16x16 multiplications: " << tm << " nanoseconds" << std::endl;
        }

        return 0;
}
