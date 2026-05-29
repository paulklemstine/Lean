"""
Algorithms: The Unreasonable Effectiveness of 163
===================================================
Algorithms derived from the mathematical theory of Heegner numbers.
"""

from typing import List, Tuple, Optional
import math


def sieve_of_eratosthenes(limit: int) -> List[int]:
    """Return all primes up to `limit` using the Sieve of Eratosthenes.

    Time: O(n log log n), Space: O(n)

    >>> sieve_of_eratosthenes(20)
    [2, 3, 5, 7, 11, 13, 17, 19]
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def is_prime(n: int) -> bool:
    """Deterministic primality test using trial division.

    Time: O(√n)
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def euler_polynomial_primality_test(n: int) -> bool:
    """Test if n² + n + 41 is prime using the Heegner non-divisibility theorem.

    ALGORITHM (based on our proved theorem euler_poly_no_small_prime_factor):
    1. Compute v = n² + n + 41
    2. If n < 40, then v < 41² = 1681, and by our theorem no prime ≤ 40
       divides v, so v must be prime. Return True immediately.
    3. For n ≥ 40, fall back to trial division.

    The theorem guarantees correctness for n < 40 without any division.

    Time: O(1) for n < 40, O(√(n²)) otherwise

    >>> all(euler_polynomial_primality_test(n) for n in range(40))
    True
    >>> euler_polynomial_primality_test(40)
    False
    """
    v = n * n + n + 41
    if n < 40:
        # By Theorem euler_poly_no_small_prime_factor + euler_poly_bound:
        # v < 41², and no prime ≤ 40 divides v, so v is prime.
        return True
    return is_prime(v)


def heegner_quadratic_form(x: int, y: int) -> int:
    """Evaluate the Heegner quadratic form Q(x,y) = x² + xy + 41y².

    This is the principal form of discriminant -163.
    By our theorem heegner_form_pos_def, Q(x,y) > 0 for (x,y) ≠ (0,0).

    >>> heegner_quadratic_form(0, 1)
    41
    >>> heegner_quadratic_form(1, 1)
    43
    >>> heegner_quadratic_form(1, 0)
    1
    """
    return x * x + x * y + 41 * y * y


def heegner_form_represents(n: int, search_radius: int = 100) -> Optional[Tuple[int, int]]:
    """Find (x, y) such that x² + xy + 41y² = n, if it exists within search_radius.

    By class number 1, every prime p that is a quadratic residue mod 163
    is representable by this form. This connects number theory to lattice geometry.

    Time: O(search_radius²)

    >>> heegner_form_represents(41)
    (0, 1)
    >>> heegner_form_represents(43)
    (1, 1)
    """
    for y in range(-search_radius, search_radius + 1):
        for x in range(-search_radius, search_radius + 1):
            if heegner_quadratic_form(x, y) == n:
                return (x, y)
    return None


def quadratic_residue_check(d: int, p: int) -> bool:
    """Check if -d is a quadratic residue mod p using Euler's criterion.

    This is the core arithmetic operation behind the non-divisibility theorem:
    if -163 is NOT a QR mod p, then p never divides n² + n + 41.

    Time: O(log p)

    >>> quadratic_residue_check(163, 2)
    False
    >>> quadratic_residue_check(163, 41)
    False
    """
    if p == 2:
        return (-d) % 2 == 0
    neg_d_mod_p = (-d) % p
    return pow(neg_d_mod_p, (p - 1) // 2, p) == 1


def heegner_prime_radius(d: int) -> int:
    """Compute the Heegner prime radius of d.

    For d ≡ 3 (mod 4), this counts consecutive primes from n=0
    in the polynomial n² + n + (d+1)/4.

    By our theory, for Heegner numbers d ∈ {43, 67, 163},
    the radius equals (d-3)/4.

    >>> heegner_prime_radius(163)
    40
    >>> heegner_prime_radius(67)
    16
    >>> heegner_prime_radius(43)
    10
    """
    if d % 4 != 3:
        return 0
    p = (d + 1) // 4
    radius = 0
    for n in range(10000):
        if is_prime(n * n + n + p):
            radius += 1
        else:
            break
    return radius


def find_euler_lucky_primes(limit: int = 100) -> List[int]:
    """Find all Euler lucky primes up to `limit`.

    An Euler lucky prime p satisfies: n² + n + p is prime for all 0 ≤ n ≤ p-2.

    >>> find_euler_lucky_primes(50)
    [2, 3, 5, 11, 17, 41]
    """
    result = []
    for p in range(2, limit + 1):
        if not is_prime(p):
            continue
        is_lucky = True
        for n in range(p - 1):
            if not is_prime(n * n + n + p):
                is_lucky = False
                break
        if is_lucky:
            result.append(p)
    return result


def near_integer_measure(d: int) -> float:
    """Measure how close e^(π√d) is to an integer.

    Returns |e^(π√d) - round(e^(π√d))|.

    Note: For large d (especially d=163), Python's float precision is
    insufficient to capture the true gap (≈ 7.5×10⁻¹³).

    >>> near_integer_measure(1) < 1  # e^π ≈ 23.14, not near-integer
    True
    """
    val = math.exp(math.pi * math.sqrt(d))
    return abs(val - round(val))


def discriminant_to_euler_prime(disc: int) -> Optional[int]:
    """Given a negative discriminant -d, compute the Euler polynomial coefficient.

    If d ≡ 3 (mod 4), returns p = (d+1)/4 (the coefficient in n² + n + p).

    >>> discriminant_to_euler_prime(163)
    41
    >>> discriminant_to_euler_prime(67)
    17
    >>> discriminant_to_euler_prime(43)
    11
    """
    if disc % 4 != 3:
        return None
    return (disc + 1) // 4


# ─── Main demonstration ───
if __name__ == "__main__":
    print("Euler Lucky Primes:", find_euler_lucky_primes(50))
    print("\nHeegner Prime Radii:")
    for d in [43, 67, 163]:
        print(f"  d={d}: radius={heegner_prime_radius(d)}, predicted={(d-3)//4}")

    print("\nPrimes represented by x² + xy + 41y²:")
    primes = sieve_of_eratosthenes(200)
    for p in primes[:20]:
        rep = heegner_form_represents(p, 50)
        if rep:
            x, y = rep
            print(f"  {p} = Q({x},{y}) = {x}² + {x}·{y} + 41·{y}² ✓")

    print("\nQuadratic residue check: is -163 a QR mod p?")
    for p in sieve_of_eratosthenes(40):
        qr = quadratic_residue_check(163, p)
        print(f"  p={p:2d}: {'YES' if qr else 'NO'} → {'p CAN divide' if qr else 'p CANNOT divide'} n²+n+41")
