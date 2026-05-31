"""
Algorithms for Sierpiński Numbers and Covering Systems

Implements the key algorithms for:
1. Verifying covering systems
2. Constructing Sierpiński certificates
3. Chinese Remainder Theorem for covering consistency
"""

from typing import List, Tuple, Optional
from math import gcd, lcm
from functools import reduce


def is_covering_system(classes: List[Tuple[int, int]]) -> bool:
    """
    Verify that a list of (residue, modulus) pairs forms a covering system.
    A covering system covers every non-negative integer.
    """
    if not classes:
        return False
    L = reduce(lcm, [m for _, m in classes])
    for n in range(L):
        if not any(n % m == r % m for r, m in classes):
            return False
    return True


def covering_density(classes: List[Tuple[int, int]]) -> float:
    """Compute the density sum Σ(1/mᵢ) of a covering system."""
    return sum(1.0 / m for _, m in classes)


def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclidean algorithm: returns (g, x, y) with a*x + b*y = g."""
    if a == 0:
        return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x


def chinese_remainder_theorem(
    residues: List[int], moduli: List[int]
) -> Optional[Tuple[int, int]]:
    """Solve x ≡ rᵢ (mod mᵢ) using CRT. Returns (solution, combined_modulus)."""
    if len(residues) != len(moduli):
        raise ValueError("residues and moduli must have same length")
    x, M = 0, 1
    for r, m in zip(residues, moduli):
        g, u, _ = extended_gcd(M, m)
        if (r - x) % g != 0:
            return None
        new_M = M * m // g
        x = (x + M * ((r - x) // g) * u) % new_M
        M = new_M
    return x % M, M


def multiplicative_order(base: int, modulus: int) -> int:
    """Compute the multiplicative order of base modulo modulus."""
    if gcd(base, modulus) != 1:
        raise ValueError("base and modulus must be coprime")
    power = base % modulus
    order = 1
    while power != 1:
        power = (power * base) % modulus
        order += 1
    return order


def verify_sierpinski_certificate(
    k: int,
    classes: List[Tuple[int, int]],
    primes: List[int],
) -> Tuple[bool, List[str]]:
    """
    Verify a complete Sierpiński certificate.
    Checks covering, divisibility, and order conditions.
    """
    messages: List[str] = []
    valid = True

    if len(classes) != len(primes):
        messages.append("ERROR: classes and primes have different lengths")
        return False, messages

    if is_covering_system(classes):
        messages.append("✓ Classes form a covering system")
    else:
        messages.append("✗ Classes do NOT form a covering system")
        valid = False

    for i, ((r, m), p) in enumerate(zip(classes, primes)):
        is_prime = p > 1 and all(p % d != 0 for d in range(2, int(p**0.5) + 1))
        if not is_prime:
            messages.append(f"✗ {p} is not prime")
            valid = False
            continue

        val = (k * pow(2, r, p) + 1) % p
        if val == 0:
            messages.append(f"✓ {p} | {k}·2^{r} + 1")
        else:
            messages.append(f"✗ {p} does NOT divide {k}·2^{r} + 1 (rem {val})")
            valid = False

        ord_val = multiplicative_order(2, p)
        if m % ord_val == 0:
            messages.append(f"  ord_{p}(2) = {ord_val} divides modulus {m}")
        else:
            messages.append(f"✗ ord_{p}(2) = {ord_val} does NOT divide modulus {m}")
            valid = False

    return valid, messages


def find_covering_system_for_sierpinski(
    k: int, prime_candidates: List[int], max_modulus: int = 100
) -> Optional[Tuple[List[Tuple[int, int]], List[int]]]:
    """
    Attempt to find a covering system certificate for a candidate Sierpiński number.
    Uses a greedy algorithm to select congruence classes that cover all residues.
    """
    available: List[Tuple[int, int, int]] = []

    for p in prime_candidates:
        if gcd(k, p) != 1 or p <= 2:
            continue
        if gcd(2, p) != 1:
            continue
        ord_val = multiplicative_order(2, p)
        if ord_val > max_modulus:
            continue
        for r in range(ord_val):
            if (k * pow(2, r, p) + 1) % p == 0:
                available.append((r, ord_val, p))

    if not available:
        return None

    L = reduce(lcm, [m for _, m, _ in available])
    uncovered = set(range(L))
    chosen_classes: List[Tuple[int, int]] = []
    chosen_primes: List[int] = []

    while uncovered:
        best = None
        best_count = 0
        for r, m, p in available:
            count = sum(1 for n in uncovered if n % m == r)
            if count > best_count:
                best_count = count
                best = (r, m, p)
        if best is None or best_count == 0:
            return None
        r, m, p = best
        chosen_classes.append((r, m))
        chosen_primes.append(p)
        uncovered = {n for n in uncovered if n % m != r}

    return chosen_classes, chosen_primes


# The correct Selfridge covering system for 78557
SIERPINSKI_78557_CLASSES: List[Tuple[int, int]] = [
    (0, 2),   # n ≡ 0 (mod 2)  → p = 3
    (1, 4),   # n ≡ 1 (mod 4)  → p = 5
    (1, 3),   # n ≡ 1 (mod 3)  → p = 7
    (11, 12), # n ≡ 11 (mod 12) → p = 13
    (15, 18), # n ≡ 15 (mod 18) → p = 19
    (27, 36), # n ≡ 27 (mod 36) → p = 37
    (3, 9),   # n ≡ 3 (mod 9)  → p = 73
]

SIERPINSKI_78557_PRIMES: List[int] = [3, 5, 7, 13, 19, 37, 73]


if __name__ == "__main__":
    print("=== Sierpiński Certificate Verification for k = 78557 ===\n")
    valid, msgs = verify_sierpinski_certificate(
        78557, SIERPINSKI_78557_CLASSES, SIERPINSKI_78557_PRIMES
    )
    for msg in msgs:
        print(f"  {msg}")
    print(f"\nCertificate valid: {valid}")
    print(f"Covering density: {covering_density(SIERPINSKI_78557_CLASSES):.4f}")
