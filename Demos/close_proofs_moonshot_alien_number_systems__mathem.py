"""
Numerical demonstration of unique representation of the Gaussian integers
in the complex base beta = i - 1  (Penney, 1965).

A Gaussian integer  z = a + b*i  (a, b integers) is represented by a finite
list of bits [d0, d1, d2, ...] read least-significant digit first, with value

        val = sum_j  d_j * beta^j ,     beta = i - 1,  d_j in {0, 1}.

Main facts demonstrated:
  * ENCODE / DECODE are mutual inverses on a large window of the lattice;
  * the representation is CANONICAL (no trailing zero) and UNIQUE;
  * the least-significant digit equals (Re + Im) mod 2 (parity recovery);
  * the naive termination measure fails: next(i) = 1 with equal norm;
  * exactly five nonzero points fail to strictly decrease the norm.

The code is self-contained and uses only the standard library.
"""

from __future__ import annotations

from typing import List, Tuple

# A Gaussian integer is a pair (Re, Im) of Python ints.
GaussInt = Tuple[int, int]

# The complex radix beta = i - 1.
BETA: GaussInt = (-1, 1)


# --------------------------------------------------------------------------
# Gaussian-integer arithmetic
# --------------------------------------------------------------------------
def gadd(z: GaussInt, w: GaussInt) -> GaussInt:
    """Add two Gaussian integers."""
    return (z[0] + w[0], z[1] + w[1])


def gmul(z: GaussInt, w: GaussInt) -> GaussInt:
    """Multiply two Gaussian integers: (a+bi)(c+di) = (ac-bd) + (ad+bc) i."""
    a, b = z
    c, d = w
    return (a * c - b * d, a * d + b * c)


def gnorm(z: GaussInt) -> int:
    """Gaussian norm N(z) = Re(z)^2 + Im(z)^2."""
    return z[0] * z[0] + z[1] * z[1]


# --------------------------------------------------------------------------
# The forced digit and the base-beta successor (division step)
# --------------------------------------------------------------------------
def forced_digit(z: GaussInt) -> int:
    """The forced least-significant digit: parity of Re + Im, in {0, 1}."""
    return (z[0] + z[1]) % 2


def next_gi(z: GaussInt) -> GaussInt:
    """The base-beta successor  next(z) = (z - d) / beta,  exact in Z[i].

    With a = Re(z) - d, b = Im(z), dividing by beta = i - 1 gives
        next(z) = ( (b - a)/2 , -(a + b)/2 ).
    """
    d = forced_digit(z)
    a = z[0] - d
    b = z[1]
    return ((b - a) // 2, -(a + b) // 2)


# --------------------------------------------------------------------------
# Encoding and decoding
# --------------------------------------------------------------------------
def encode(z: GaussInt) -> List[int]:
    """Return the canonical base-(i-1) bit list of z, least-significant first."""
    bits: List[int] = []
    while z != (0, 0):
        bits.append(forced_digit(z))
        z = next_gi(z)
    return bits


def decode(bits: List[int]) -> GaussInt:
    """Evaluate a bit list (least-significant first) in base beta = i - 1."""
    value: GaussInt = (0, 0)
    power: GaussInt = (1, 0)  # beta^0
    for d in bits:
        if d:
            value = gadd(value, power)
        power = gmul(power, BETA)
    return value


def is_canonical(bits: List[int]) -> bool:
    """A bit list is canonical iff it is empty or its top digit is nonzero."""
    return len(bits) == 0 or bits[-1] != 0


def bits_to_str(bits: List[int]) -> str:
    """Human-readable most-significant-first string of a bit list."""
    return "".join(str(d) for d in reversed(bits)) if bits else "(empty)"


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_roundtrip(radius: int = 12) -> None:
    """Verify encode/decode are inverse and canonical on a window of Z[i]."""
    print(f"[1] Round-trip + canonicity over |Re|,|Im| <= {radius} "
          f"({(2 * radius + 1) ** 2} points)")
    ok = True
    for a in range(-radius, radius + 1):
        for b in range(-radius, radius + 1):
            z = (a, b)
            bits = encode(z)
            if decode(bits) != z or not is_canonical(bits):
                ok = False
                print(f"    FAIL at {z}: bits={bits}")
    print("    all points encode/decode correctly and canonically"
          if ok else "    FAILURES DETECTED")


def demo_examples() -> None:
    """Show representations of a few landmark Gaussian integers."""
    print("[2] Landmark representations (most-significant digit first)")
    landmarks = [
        (0, 0), (1, 0), (0, 1), (0, -1), (-1, 0), (2, 3), (-5, 7),
    ]
    names = {
        (0, 0): "0", (1, 0): "1", (0, 1): "i", (0, -1): "-i",
        (-1, 0): "-1", (2, 3): "2+3i", (-5, 7): "-5+7i",
    }
    for z in landmarks:
        bits = encode(z)
        print(f"    {names[z]:>6} = {z!s:>9}  ->  {bits_to_str(bits):<12}"
              f"  (len {len(bits)}, decode {decode(bits)})")


def demo_parity_recovery(radius: int = 10) -> None:
    """The least-significant digit equals (Re + Im) mod 2."""
    print("[3] Parity recovery: LSB(z) == (Re + Im) mod 2")
    ok = True
    for a in range(-radius, radius + 1):
        for b in range(-radius, radius + 1):
            z = (a, b)
            bits = encode(z)
            lsb = bits[0] if bits else 0
            if lsb != (a + b) % 2:
                ok = False
                print(f"    FAIL at {z}")
    print("    parity recovery holds everywhere" if ok else "    FAILURES")


def demo_naive_measure_fails() -> None:
    """The naive 'norm strictly decreases each step' claim is false."""
    print("[4] Contrarian fact: the naive norm-decrease measure FAILS")
    z = (0, 1)  # i
    w = next_gi(z)
    print(f"    next(i) = next({z}) = {w},  N(i) = {gnorm(z)}, "
          f"N(next(i)) = {gnorm(w)}  ->  equal norm, no decrease!")


def demo_exceptional_points(radius: int = 60) -> None:
    """Enumerate all nonzero points where the norm fails to strictly decrease."""
    print(f"[5] Nonzero points with N(next(z)) >= N(z), searched over "
          f"|Re|,|Im| <= {radius}")
    bad = []
    for a in range(-radius, radius + 1):
        for b in range(-radius, radius + 1):
            z = (a, b)
            if z == (0, 0):
                continue
            if gnorm(next_gi(z)) >= gnorm(z):
                bad.append(z)
    print(f"    found {len(bad)} exceptional points: {bad}")
    expected = [(0, 1), (0, -1), (-1, 0), (-2, 1), (-2, -1)]
    print("    matches the predicted set {i, -i, -1, -2+i, -2-i}: "
          f"{sorted(bad) == sorted(expected)}")


def demo_uniqueness(radius: int = 8) -> None:
    """Distinct lattice points have distinct canonical representations."""
    print(f"[6] Injectivity: distinct z give distinct canonical strings "
          f"(|Re|,|Im| <= {radius})")
    seen = {}
    ok = True
    for a in range(-radius, radius + 1):
        for b in range(-radius, radius + 1):
            key = tuple(encode((a, b)))
            if key in seen:
                ok = False
                print(f"    COLLISION: {(a, b)} and {seen[key]}")
            seen[key] = (a, b)
    print("    all canonical strings are distinct" if ok else "    COLLISION")


if __name__ == "__main__":
    print("=" * 68)
    print("Base (i - 1): unique representation of the Gaussian integers")
    print("=" * 68)
    demo_roundtrip()
    print()
    demo_examples()
    print()
    demo_parity_recovery()
    print()
    demo_naive_measure_fails()
    print()
    demo_exceptional_points()
    print()
    demo_uniqueness()
    print()
    print("Done.")
