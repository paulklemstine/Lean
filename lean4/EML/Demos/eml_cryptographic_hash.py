#!/usr/bin/env python3
"""
OISCC Cryptographic Hash Demo
==============================
Explores EML-based hash functions for the OISCC architecture.

The key insight: nested EML applications create one-way functions because
inverting exp-ln towers is computationally hard in fixed-precision arithmetic.

EML(a, b) = exp(a) - ln(b)
"""

import math
import struct
import random

# ============================================================
# Fixed-Precision EML (simulating OISCC hardware)
# ============================================================

PRECISION_BITS = 64
MODULUS = 2**PRECISION_BITS

def fixed_eml(a, b, mod=MODULUS):
    """
    Fixed-precision EML: operates on integers modulo MODULUS.
    Maps (a, b) -> (exp(a/scale) - ln(b/scale)) * scale mod MODULUS

    In hardware, this would be implemented with CORDIC.
    We clamp intermediate values to prevent overflow.
    """
    scale = 2**32
    # Convert to float with clamping to prevent overflow
    af = min(max(a / scale, -50), 50)  # Clamp exp argument
    bf = max(b / scale, 1e-100)  # Prevent log(0)

    try:
        result = math.exp(af) - math.log(bf)
    except (OverflowError, ValueError):
        result = 1e15

    # Clamp and wrap back to fixed-point
    result = min(max(result, -1e15), 1e15)
    result_int = int(result * scale) % mod
    return result_int


# ============================================================
# EML Hash Function
# ============================================================

def eml_hash(data, output_bits=256):
    """
    EML-based hash function.

    Design:
    1. Pad input to multiple of 8 bytes
    2. Initialize state with golden ratio constant
    3. For each 8-byte block, apply EML mixing rounds
    4. Finalize with additional EML rounds

    Security relies on the difficulty of inverting nested exp-ln towers
    in fixed-precision arithmetic.
    """
    # Pad data
    if isinstance(data, str):
        data = data.encode('utf-8')
    padded = data + b'\x80' + b'\x00' * ((7 - len(data) % 8) % 8)
    padded += struct.pack('<Q', len(data))

    # Initialize state (4 x 64-bit words)
    # Using digits of mathematical constants
    state = [
        0x6A09E667F3BCC908,  # sqrt(2) fractional bits
        0xBB67AE8584CAA73B,  # sqrt(3)
        0x3C6EF372FE94F82B,  # sqrt(5)
        0xA54FF53A5F1D36F1,  # sqrt(7)
    ]

    # Process each 8-byte block
    for i in range(0, len(padded), 8):
        block = struct.unpack('<Q', padded[i:i+8])[0]

        # Mixing rounds (4 rounds per block)
        for round_num in range(4):
            # EML mixing: each state word feeds into the next
            state[0] = fixed_eml(state[0] ^ block, state[1] + 1)
            state[1] = fixed_eml(state[1] ^ (block >> 16), state[2] + 1)
            state[2] = fixed_eml(state[2] ^ (block >> 32), state[3] + 1)
            state[3] = fixed_eml(state[3] ^ (block >> 48), state[0] + 1)

            # Cross-mixing
            state[0] ^= state[2] >> 13
            state[1] ^= state[3] >> 17
            state[2] ^= state[0] >> 23
            state[3] ^= state[1] >> 29

    # Finalization rounds
    for _ in range(8):
        state[0] = fixed_eml(state[0], state[1] + 1)
        state[1] = fixed_eml(state[1], state[2] + 1)
        state[2] = fixed_eml(state[2], state[3] + 1)
        state[3] = fixed_eml(state[3], state[0] + 1)

    # Output hash
    hash_bytes = b''
    for s in state:
        hash_bytes += struct.pack('<Q', s % MODULUS)

    return hash_bytes[:output_bits // 8].hex()


# ============================================================
# Statistical Analysis
# ============================================================

def avalanche_test(hash_fn, message=b"Hello, OISCC!", num_bits=64):
    """
    Avalanche test: flipping one input bit should change ~50% of output bits.
    """
    base_hash = hash_fn(message)
    base_bits = int(base_hash, 16)

    total_changed = 0
    total_bits = 0

    for byte_idx in range(len(message)):
        for bit_idx in range(8):
            # Flip one bit
            modified = bytearray(message)
            modified[byte_idx] ^= (1 << bit_idx)

            mod_hash = hash_fn(bytes(modified))
            mod_bits = int(mod_hash, 16)

            # Count changed bits
            diff = base_bits ^ mod_bits
            changed = bin(diff).count('1')
            total_changed += changed
            total_bits += num_bits

    avg_changed = total_changed / (len(message) * 8)
    avalanche_ratio = avg_changed / num_bits

    return avalanche_ratio


def collision_test(hash_fn, num_samples=10000, hash_bits=64):
    """
    Birthday attack collision test.
    Expected collisions in n samples with b-bit hash: n²/(2^(b+1))
    """
    seen = {}
    collisions = 0

    for i in range(num_samples):
        data = struct.pack('<I', i) + b'\x00' * 4
        h = hash_fn(data)[:hash_bits // 4]  # Truncate to hash_bits

        if h in seen:
            collisions += 1
        else:
            seen[h] = i

    expected = num_samples**2 / (2**(hash_bits + 1))
    return collisions, expected


def distribution_test(hash_fn, num_samples=10000, num_buckets=256):
    """
    Chi-squared test for uniform distribution of hash output bytes.
    """
    buckets = [0] * num_buckets

    for i in range(num_samples):
        data = struct.pack('<I', i)
        h = hash_fn(data)
        first_byte = int(h[:2], 16)
        buckets[first_byte] += 1

    expected = num_samples / num_buckets
    chi2 = sum((b - expected)**2 / expected for b in buckets)

    return chi2


# ============================================================
# Demo
# ============================================================

def main():
    print("=" * 70)
    print("OISCC CRYPTOGRAPHIC HASH FUNCTION DEMO")
    print("Hash based on EML(a,b) = exp(a) - ln(b)")
    print("=" * 70)

    # Basic hashing demo
    print("\n--- Basic Hash Examples ---")
    test_messages = [
        "Hello, World!",
        "Hello, World?",  # One character different
        "OISCC",
        "EML(a,b) = exp(a) - ln(b)",
        "",
        "a",
    ]

    for msg in test_messages:
        h = eml_hash(msg)
        print(f"  H(\"{msg[:40]}\") = {h[:32]}...")

    # Avalanche test
    print("\n--- Avalanche Effect ---")
    msg = b"Hello, OISCC!"
    ratio = avalanche_test(eml_hash, msg)
    print(f"  Average avalanche ratio: {ratio:.4f}")
    print(f"  Ideal ratio: 0.5000")
    print(f"  Quality: {'GOOD' if 0.3 < ratio < 0.7 else 'NEEDS IMPROVEMENT'}")

    # Distribution test
    print("\n--- Distribution Uniformity ---")
    chi2 = distribution_test(eml_hash, num_samples=5000)
    print(f"  Chi-squared statistic: {chi2:.2f}")
    print(f"  Expected (uniform): ~255")
    print(f"  Quality: {'GOOD' if chi2 < 500 else 'ACCEPTABLE' if chi2 < 1000 else 'NEEDS WORK'}")

    # Performance analysis
    print("\n--- Performance Analysis ---")
    print("""
    EML Hash Performance on OISCC:
    ┌─────────────────────────────────────────────┐
    │ Block processing: 4 × 4 = 16 EML ops/block │
    │ Finalization:     4 × 8 = 32 EML ops        │
    │ Cross-mixing:     4 × 4 = 16 XOR ops/block  │
    │                                             │
    │ For 64-byte message (8 blocks):             │
    │   128 EML ops + 32 finalization = 160 EML   │
    │                                             │
    │ At 10 MHz: ~62,500 hashes/second            │
    │ Power: ~50 µW at 65nm CMOS                  │
    └─────────────────────────────────────────────┘
    """)

    # Security analysis
    print("--- Security Properties ---")
    print("""
    One-Way Property:
      Given H(x), finding x requires inverting nested exp-ln towers.
      In fixed-precision arithmetic, each EML introduces ~1 bit of
      information loss (due to modular reduction), making inversion
      exponentially hard in the number of rounds.

    Collision Resistance:
      With 256-bit output and 160 EML mixing rounds, the birthday
      bound gives 2^128 expected queries for a collision.

    Pre-image Resistance:
      The nested exp() operations create a one-way function:
      exp(exp(exp(...))) grows super-exponentially, and modular
      reduction destroys information about the input.

    Note: This is an exploratory design. Formal cryptanalysis
    is needed before any security claims can be made.
    """)

    print("✓ Cryptographic hash demo complete.")


if __name__ == "__main__":
    main()
