#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 2: CHAOS-BASED CRYPTOGRAPHIC KEY GENERATION               ║
║  ────────────────────────────────────────────────────────────    ║
║  Uses coupled Lorenz and Rössler attractors to generate          ║
║  cryptographic key streams. The sensitive dependence on initial  ║
║  conditions provides the trapdoor: knowing the key (initial      ║
║  conditions) allows reproduction, but without it, the stream    ║
║  is indistinguishable from random.                              ║
║                                                                  ║
║  Includes entropy analysis, NIST-style randomness tests, and    ║
║  avalanche effect demonstration.                                 ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np
import hashlib
from collections import Counter

# ── Chaotic Systems ────────────────────────────────────────────
class LorenzCipher:
    """Lorenz system as a continuous key stream generator."""

    def __init__(self, key: bytes, sigma=10.0, rho=28.0, beta=8.0/3.0):
        # Derive initial conditions from key via SHA-256
        h = hashlib.sha256(key).digest()
        # Map 32 bytes to 3 initial conditions in [-20, 20]
        self.x = (h[0] + h[1] * 256) / 65535.0 * 40 - 20
        self.y = (h[2] + h[3] * 256) / 65535.0 * 40 - 20
        self.z = (h[4] + h[5] * 256) / 65535.0 * 40 - 20
        self.sigma = sigma + (h[6] / 255.0) * 0.1  # Slight parameter perturbation
        self.rho = rho + (h[7] / 255.0) * 0.1
        self.beta = beta + (h[8] / 255.0) * 0.01
        self.dt = 0.005
        # Transient: skip initial convergence to attractor
        for _ in range(5000):
            self._step()

    def _step(self):
        dx = self.sigma * (self.y - self.x)
        dy = self.x * (self.rho - self.z) - self.y
        dz = self.x * self.y - self.beta * self.z
        self.x += dx * self.dt
        self.y += dy * self.dt
        self.z += dz * self.dt

    def generate_byte(self):
        """Generate one pseudorandom byte from chaotic dynamics."""
        self._step()
        # Extract bits from the mantissa of x, y, z
        # Use the least significant bits of the floating point representation
        xbits = int(abs(self.x * 1e10)) & 0x07  # 3 bits from x
        ybits = int(abs(self.y * 1e10)) & 0x07  # 3 bits from y
        zbits = int(abs(self.z * 1e10)) & 0x03  # 2 bits from z
        return (xbits << 5) | (ybits << 2) | zbits

    def generate_stream(self, n_bytes):
        """Generate n bytes of key stream."""
        return bytes([self.generate_byte() for _ in range(n_bytes)])


class RosslerCipher:
    """Rössler system as secondary key stream (for double encryption)."""

    def __init__(self, key: bytes, a=0.2, b=0.2, c=5.7):
        h = hashlib.sha256(key + b'rossler').digest()
        self.x = (h[0] + h[1] * 256) / 65535.0 * 10 - 5
        self.y = (h[2] + h[3] * 256) / 65535.0 * 10 - 5
        self.z = (h[4] + h[5] * 256) / 65535.0 * 10 - 5
        self.a, self.b, self.c = a, b, c
        self.dt = 0.01
        for _ in range(3000):
            self._step()

    def _step(self):
        dx = -self.y - self.z
        dy = self.x + self.a * self.y
        dz = self.b + self.z * (self.x - self.c)
        self.x += dx * self.dt
        self.y += dy * self.dt
        self.z += dz * self.dt

    def generate_byte(self):
        self._step()
        xbits = int(abs(self.x * 1e8)) & 0x0F
        ybits = int(abs(self.y * 1e8)) & 0x0F
        return (xbits << 4) | ybits

    def generate_stream(self, n_bytes):
        return bytes([self.generate_byte() for _ in range(n_bytes)])


# ── Encryption / Decryption ────────────────────────────────────
def chaos_encrypt(plaintext: bytes, key: bytes) -> bytes:
    """Double-chaos encryption: Lorenz XOR then Rössler XOR."""
    lorenz = LorenzCipher(key)
    rossler = RosslerCipher(key)
    stream1 = lorenz.generate_stream(len(plaintext))
    stream2 = rossler.generate_stream(len(plaintext))
    return bytes([p ^ s1 ^ s2 for p, s1, s2 in zip(plaintext, stream1, stream2)])

def chaos_decrypt(ciphertext: bytes, key: bytes) -> bytes:
    """Decryption is identical to encryption (XOR is self-inverse)."""
    return chaos_encrypt(ciphertext, key)  # XOR is its own inverse


# ── Statistical Tests ──────────────────────────────────────────
def entropy_per_byte(data: bytes) -> float:
    """Shannon entropy in bits per byte (max = 8.0)."""
    counts = Counter(data)
    total = len(data)
    entropy = 0.0
    for count in counts.values():
        p = count / total
        if p > 0:
            entropy -= p * np.log2(p)
    return entropy

def frequency_test(data: bytes) -> dict:
    """Monobit frequency test (NIST SP 800-22 style)."""
    bits = ''.join(format(b, '08b') for b in data)
    n = len(bits)
    s = sum(1 if b == '1' else -1 for b in bits)
    s_obs = abs(s) / np.sqrt(n)
    # For truly random: s_obs should be < 2.0 (roughly)
    return {"s_obs": s_obs, "pass": s_obs < 2.0, "n_bits": n}

def runs_test(data: bytes) -> dict:
    """Runs test: checks oscillation between 0s and 1s."""
    bits = ''.join(format(b, '08b') for b in data)
    n = len(bits)
    ones = bits.count('1')
    pi = ones / n

    if abs(pi - 0.5) >= 2 / np.sqrt(n):
        return {"pass": False, "reason": "frequency prerequisite failed"}

    runs = 1
    for i in range(1, n):
        if bits[i] != bits[i-1]:
            runs += 1

    expected = 2 * n * pi * (1 - pi) + 1
    variance = 2 * n * pi * (1 - pi)  # Simplified
    if variance > 0:
        z = (runs - expected) / np.sqrt(variance)
    else:
        z = 0

    return {"runs": runs, "expected": expected, "z_score": z, "pass": abs(z) < 2.0}

def avalanche_test(key: bytes, n_bytes=1000) -> float:
    """Avalanche effect: flip 1 bit of key, measure output change."""
    stream1 = LorenzCipher(key).generate_stream(n_bytes)

    # Flip one bit of the key
    key2 = bytearray(key)
    key2[0] ^= 0x01
    stream2 = LorenzCipher(bytes(key2)).generate_stream(n_bytes)

    # Count differing bits
    diff_bits = sum(bin(a ^ b).count('1') for a, b in zip(stream1, stream2))
    total_bits = n_bytes * 8
    return diff_bits / total_bits  # Should be ~0.5 for good avalanche


# ── Main Demo ──────────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  CHAOS-BASED CRYPTOGRAPHIC KEY GENERATION")
    print("=" * 65)

    key = b"MetaOracleSecretKey2025!"

    # ── Encryption Demo ────────────────────────────────────────
    plaintext = b"The quick brown fox jumps over the lazy dog. " * 10
    print(f"\n  Plaintext ({len(plaintext)} bytes):")
    print(f"    {plaintext[:60]}...")

    ciphertext = chaos_encrypt(plaintext, key)
    print(f"\n  Ciphertext (hex, first 60 chars):")
    print(f"    {ciphertext[:30].hex()}")

    decrypted = chaos_decrypt(ciphertext, key)
    print(f"\n  Decrypted:")
    print(f"    {decrypted[:60]}...")
    assert decrypted == plaintext, "DECRYPTION FAILED!"
    print(f"    ✓ Decryption verified correct")

    # Wrong key
    wrong_decrypt = chaos_decrypt(ciphertext, b"WrongKey!")
    match_bytes = sum(1 for a, b in zip(wrong_decrypt, plaintext) if a == b)
    print(f"\n  Wrong key decryption match: {match_bytes}/{len(plaintext)} bytes "
          f"({match_bytes/len(plaintext)*100:.1f}%)")

    # ── Key Stream Analysis ────────────────────────────────────
    print("\n" + "─" * 65)
    print("  KEY STREAM STATISTICAL ANALYSIS")
    print("─" * 65)

    stream_size = 10000
    lorenz_stream = LorenzCipher(key).generate_stream(stream_size)
    rossler_stream = RosslerCipher(key).generate_stream(stream_size)

    for name, stream in [("Lorenz", lorenz_stream), ("Rössler", rossler_stream)]:
        print(f"\n  {name} Stream ({stream_size} bytes):")
        ent = entropy_per_byte(stream)
        freq = frequency_test(stream)
        runs = runs_test(stream)
        print(f"    Entropy:        {ent:.4f} bits/byte (ideal: 8.0)")
        print(f"    Frequency test: {'PASS' if freq['pass'] else 'FAIL'} "
              f"(s_obs={freq['s_obs']:.4f})")
        print(f"    Runs test:      {'PASS' if runs['pass'] else 'FAIL'} "
              f"(z={runs.get('z_score', 0):.4f})")

    # ── Avalanche Effect ───────────────────────────────────────
    print("\n" + "─" * 65)
    print("  AVALANCHE EFFECT (1-bit key change)")
    print("─" * 65)

    for i in range(5):
        test_key = f"TestKey{i}".encode()
        avalanche = avalanche_test(test_key)
        bar = "█" * int(avalanche * 50) + "░" * (50 - int(avalanche * 50))
        print(f"    Key {i}: {avalanche:.4f} [{bar}] (ideal: 0.5000)")

    # ── Lyapunov Exponent Estimation ───────────────────────────
    print("\n" + "─" * 65)
    print("  LYAPUNOV EXPONENT ESTIMATION")
    print("─" * 65)

    # Estimate maximum Lyapunov exponent by tracking divergence
    eps = 1e-10
    cipher1 = LorenzCipher(key)
    # Create slightly perturbed copy
    cipher2 = LorenzCipher(key)
    cipher2.x += eps

    divergences = []
    for _ in range(1000):
        cipher1._step()
        cipher2._step()
        dist = np.sqrt((cipher1.x - cipher2.x)**2 +
                       (cipher1.y - cipher2.y)**2 +
                       (cipher1.z - cipher2.z)**2)
        if dist > 0:
            divergences.append(np.log(dist / eps))

    if divergences:
        lyap = np.mean(divergences[-500:]) / (500 * cipher1.dt)
        print(f"    Estimated λ_max: {lyap:.4f}")
        print(f"    Positive λ confirms chaotic regime ✓" if lyap > 0 else
              f"    ⚠ Non-positive λ suggests non-chaotic regime")

    # ── Byte Distribution Visualization (ASCII) ───────────────
    print("\n" + "─" * 65)
    print("  BYTE VALUE DISTRIBUTION (Lorenz stream)")
    print("─" * 65)
    counts = Counter(lorenz_stream)
    max_count = max(counts.values())
    # Show 16 buckets of 16 values each
    for bucket in range(16):
        bucket_count = sum(counts.get(i, 0) for i in range(bucket*16, (bucket+1)*16))
        bar_len = int(bucket_count / max(1, stream_size) * 200)
        bar = "█" * bar_len
        print(f"    [{bucket*16:3d}-{(bucket+1)*16-1:3d}]: {bar} {bucket_count}")

    print("\n" + "=" * 65)
    print("  ★ Chaos-based encryption operational")
    print("=" * 65)


if __name__ == "__main__":
    main()
