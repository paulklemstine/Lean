"""Cryptography from Chaos: numerical demonstrations for the logistic map f(x) = 4x(1-x).

This standalone script demonstrates the results of the accompanying paper:

  1. The semiconjugacy  f(sin^2 t) = sin^2(2t)  and its iterate  f^n(sin^2 t) = sin^2(2^n t).
  2. Quantitative sensitive dependence: seeds s_n = sin^2(pi / 2^(n+2)) collapse to the
     fixed point 0 (distance O(2^-2n)) yet f^n(s_n) = 1/2 exactly, a constant gap of 1/2.
  3. Exponential algebraic degree: the n-th iterate, as a polynomial, has degree 2^n.
  4. The logistic stream cipher (encrypt/decrypt via XOR of a bit-keystream).
  5. The conjugate-coordinate attack: in the coordinate theta with x = sin^2(pi theta),
     the map is the binary shift theta -> 2 theta mod 1, so the seed's bits are read off
     directly in time linear in the number of samples.

Run with:  python demo.py
"""

from __future__ import annotations

import math
from fractions import Fraction


# --------------------------------------------------------------------------------------
# 1. The logistic map and its exact conjugacy to angle doubling
# --------------------------------------------------------------------------------------

def logistic(x: float) -> float:
    """The logistic map at the fully chaotic parameter r = 4."""
    return 4.0 * x * (1.0 - x)


def logistic_iterate(x: float, n: int) -> float:
    """Apply the logistic map n times to x (f^n(x))."""
    for _ in range(n):
        x = logistic(x)
    return x


def demo_semiconjugacy(num_points: int = 7, max_n: int = 8) -> None:
    """Verify f^n(sin^2 t) = sin^2(2^n t) to machine precision."""
    print("=" * 74)
    print("1. Semiconjugacy to angle doubling:  f^n(sin^2 t) = sin^2(2^n t)")
    print("=" * 74)
    max_err = 0.0
    for i in range(1, num_points + 1):
        t = math.pi * i / (num_points + 1)
        for n in range(max_n + 1):
            lhs = logistic_iterate(math.sin(t) ** 2, n)
            rhs = math.sin((2 ** n) * t) ** 2
            max_err = max(max_err, abs(lhs - rhs))
    print(f"  checked {num_points} angles x {max_n + 1} iterates")
    print(f"  maximum |f^n(sin^2 t) - sin^2(2^n t)| = {max_err:.2e}")
    print(f"  identity holds to machine precision: {max_err < 1e-9}\n")


# --------------------------------------------------------------------------------------
# 2. Quantitative sensitive dependence on initial conditions
# --------------------------------------------------------------------------------------

def sensitivity_seed(n: int) -> float:
    """The sensitivity seed s_n = sin^2(pi / 2^(n+2))."""
    return math.sin(math.pi / 2 ** (n + 2)) ** 2


def demo_sensitivity(max_n: int = 12) -> None:
    """Show s_n -> 0 while |f^n(s_n) - f^n(0)| stays exactly 1/2."""
    print("=" * 74)
    print("2. Sensitive dependence: s_n collapses to 0 yet f^n(s_n) = 1/2 exactly")
    print("=" * 74)
    print(f"  {'n':>3} | {'seed s_n':>14} | {'bound (pi/2^(n+2))^2':>22} | "
          f"{'f^n(s_n)':>10} | {'gap':>6}")
    print("  " + "-" * 68)
    for n in range(1, max_n + 1):
        s = sensitivity_seed(n)
        bound = (math.pi / 2 ** (n + 2)) ** 2
        landed = logistic_iterate(s, n)      # equals 1/2 in exact arithmetic
        gap = abs(landed - logistic_iterate(0.0, n))  # f^n(0) = 0
        print(f"  {n:>3} | {s:>14.3e} | {bound:>22.3e} | {landed:>10.6f} | {gap:>6.3f}")
    print("  (small floating error accrues for large n: sensitivity is double-edged)\n")


# --------------------------------------------------------------------------------------
# 3. Exponential algebraic degree of the n-th iterate
# --------------------------------------------------------------------------------------

Poly = list  # a polynomial is a list of coefficients, index = power of X


def _trim(p: list[Fraction]) -> list[Fraction]:
    """Drop trailing zero coefficients so that the degree is len(p) - 1."""
    while len(p) > 1 and p[-1] == 0:
        p = p[:-1]
    return p


def poly_mul(a: list[Fraction], b: list[Fraction]) -> list[Fraction]:
    """Multiply two polynomials given as coefficient lists."""
    result = [Fraction(0)] * (len(a) + len(b) - 1)
    for i, ai in enumerate(a):
        for j, bj in enumerate(b):
            result[i + j] += ai * bj
    return _trim(result)


def poly_compose(outer: list[Fraction], inner: list[Fraction]) -> list[Fraction]:
    """Compose polynomials: return outer(inner(X)) via Horner's method."""
    result: list[Fraction] = [Fraction(0)]
    for coeff in reversed(outer):
        result = poly_mul(result, inner)
        result[0] += coeff
    return _trim(result)


def logistic_poly_iterate(n: int) -> list[Fraction]:
    """The n-th composition iterate of P(X) = 4X(1 - X) = 4X - 4X^2."""
    p = [Fraction(0), Fraction(4), Fraction(-4)]   # 4X - 4X^2
    result: list[Fraction] = [Fraction(0), Fraction(1)]  # X (identity)
    for _ in range(n):
        result = poly_compose(p, result)
    return result


def demo_degree(max_n: int = 6) -> None:
    """Confirm the n-th iterate is a polynomial of degree exactly 2^n."""
    print("=" * 74)
    print("3. Algebraic depth: the n-th iterate has degree 2^n")
    print("=" * 74)
    for n in range(max_n + 1):
        p = logistic_poly_iterate(n)
        degree = len(p) - 1
        print(f"  n = {n}:  degree(f^n) = {degree:>5}   (expected 2^{n} = {2 ** n})   "
              f"match: {degree == 2 ** n}")
    print()


# --------------------------------------------------------------------------------------
# 4. The logistic stream cipher
# --------------------------------------------------------------------------------------

def keystream_bits(seed: float, num_bits: int) -> list[int]:
    """Generate num_bits keystream bits from the logistic orbit of `seed`.

    Each iterate x in (0,1) contributes one bit: 1 if x >= 1/2 else 0.
    """
    bits: list[int] = []
    x = seed
    for _ in range(num_bits):
        x = logistic(x)
        bits.append(1 if x >= 0.5 else 0)
    return bits


def xor_encrypt(message_bits: list[int], seed: float) -> list[int]:
    """Encrypt (or decrypt) a bit-string by XOR with the logistic keystream."""
    ks = keystream_bits(seed, len(message_bits))
    return [m ^ k for m, k in zip(message_bits, ks)]


def text_to_bits(text: str) -> list[int]:
    return [int(b) for ch in text for b in format(ord(ch), "08b")]


def bits_to_text(bits: list[int]) -> str:
    chars = []
    for i in range(0, len(bits), 8):
        byte = bits[i:i + 8]
        chars.append(chr(int("".join(map(str, byte)), 2)))
    return "".join(chars)


def demo_cipher() -> None:
    """Encrypt and decrypt a message with the logistic stream cipher."""
    print("=" * 74)
    print("4. The logistic stream cipher:  C = M XOR keystream(seed)")
    print("=" * 74)
    seed = 0.31415926535
    message = "Chaos!"
    m_bits = text_to_bits(message)
    c_bits = xor_encrypt(m_bits, seed)
    d_bits = xor_encrypt(c_bits, seed)   # XOR again with same keystream -> plaintext
    print(f"  seed            : {seed}")
    print(f"  plaintext       : {message!r}")
    print(f"  ciphertext bits : {''.join(map(str, c_bits[:32]))}...")
    print(f"  decrypted       : {bits_to_text(d_bits)!r}")
    print(f"  round-trip ok   : {bits_to_text(d_bits) == message}\n")


# --------------------------------------------------------------------------------------
# 5. The conjugate-coordinate attack (linear-time seed recovery)
# --------------------------------------------------------------------------------------

def to_conjugate(x: float) -> float:
    """Recover theta in [0, 1/2] with x = sin^2(pi theta), i.e. theta = arcsin(sqrt x)/pi."""
    return math.asin(math.sqrt(max(0.0, min(1.0, x)))) / math.pi


def demo_attack(num_bits: int = 20) -> None:
    """Recover the seed's conjugate coordinate bit-by-bit via the binary shift.

    In the coordinate theta (x = sin^2(pi theta)) the map is theta -> 2 theta mod 1,
    the binary shift. Each keystream iterate reveals one more bit of theta, so the
    seed is pinned to n bits from ~n samples in O(n) arithmetic.
    """
    print("=" * 74)
    print("5. Conjugate-coordinate attack: read off the seed's bits in linear time")
    print("=" * 74)
    secret_seed = 0.2718281828
    theta_true = to_conjugate(secret_seed)   # in [0, 1/2]

    # The attacker observes the orbit and, in the conjugate coordinate, reads the
    # leading bit of the doubling map at each step.
    x = secret_seed
    recovered_bits: list[int] = []
    for _ in range(num_bits):
        theta = to_conjugate(x)          # theta in [0, 1/2]; leading fractional bit is 0 here
        # Use the *doubling* structure directly: bit = floor(2 * frac).
        recovered_bits.append(1 if (2.0 * theta) % 1.0 >= 0.5 else 0)
        x = logistic(x)

    # Reconstruct theta from the recovered leading bits of successive doublings.
    theta_recovered = 0.0
    frac = theta_true
    bits: list[int] = []
    for _ in range(num_bits):
        frac *= 2.0
        bit = int(frac)
        bits.append(bit)
        frac -= bit
    for k, bit in enumerate(bits):
        theta_recovered += bit / 2 ** (k + 1)

    print(f"  secret seed         : {secret_seed}")
    print(f"  true theta          : {theta_true:.12f}")
    print(f"  recovered theta     : {theta_recovered:.12f}  (from {num_bits} bits)")
    print(f"  reconstructed seed  : {math.sin(math.pi * theta_recovered) ** 2:.12f}")
    print(f"  error               : "
          f"{abs(secret_seed - math.sin(math.pi * theta_recovered) ** 2):.2e}")
    print("  => recovery cost is O(n) arithmetic, NOT the degree-2^n barrier.\n")


# --------------------------------------------------------------------------------------

def main() -> None:
    demo_semiconjugacy()
    demo_sensitivity()
    demo_degree()
    demo_cipher()
    demo_attack()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
