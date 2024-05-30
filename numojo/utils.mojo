# Copyright Timothy H. Keitt 2024
# Adapted from https://prng.di.unimi.it/
# https://github.com/keittlab/numojo


@always_inline
fn rotate_left[k: UInt64](x: UInt64) -> UInt64:
    """Performs bitwise rotation of a 64-bit integer."""
    constrained[k < 64, "Invalid rotation"]()
    return x << k | x >> 64 - k
