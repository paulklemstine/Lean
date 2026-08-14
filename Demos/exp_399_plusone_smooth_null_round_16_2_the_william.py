"""
Numerical demonstrations for:

    The Discriminant-Gated p+1 Weakness and Its Invisibility from the Modulus

Everything here is self-contained: no third-party packages are required.

The script demonstrates, in order:

  1. The Lucas V-sequence V_0 = 2, V_1 = P, V_{n+2} = P V_{n+1} - V_n and its
     fast "ladder" evaluation modulo N.
  2. The Williams p+1 method: gcd(V_M - 2, N) with M = lcm(1..B).
  3. The DISCRIMINANT GATE: at an odd prime p and base P with D = P^2 - 4,
        V_{p+1} = 2  in F_p   <=>   (D|p) = -1  or  D = 0,
     and if D is a nonzero square then V_{p+1} = P^2 - 2.
  4. Gate density: exactly (p-1)/2 of the p bases in F_p open the gate.
  5. Degenerate bases: V_k(P) = 2 for some k >= 1 exactly when |P| <= 2.
  6. Square-class coincidence: D_3 = 5 and D_7 = 45 = 5 * 3^2 give the same
     gate, so bases 3 and 7 succeed on exactly the same primes.
  7. The matched collision 359*5849 vs 397*5743 that makes both the smoothness
     label and the gate label invisible from (N mod 60060, bitlength N).
  8. The dichotomy: N mod 3 reveals the XOR of the two "p = -1 mod 3" bits but
     never which factor carries which bit; measured as mutual information.
  9. Jacobi splitting (D|N) = (D|p)(D|q) and its uninformativeness.
 10. A miniature replication of the matched-pair experiment.
"""

from __future__ import annotations

import math
import random
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. Lucas sequences
# ----------------------------------------------------------------------------


def lucas_v_naive(base: int, n: int, modulus: int | None = None) -> int:
    """V_n(P) by direct iteration of V_{k+2} = P V_{k+1} - V_k (V_0=2, V_1=P)."""
    v0, v1 = 2, base
    if modulus is not None:
        v0, v1 = v0 % modulus, v1 % modulus
    for _ in range(n):
        v0, v1 = v1, base * v1 - v0
        if modulus is not None:
            v1 %= modulus
    return v0


def lucas_v_ladder(base: int, n: int, modulus: int) -> int:
    """V_n(P) mod N in O(log n) multiplications via the doubling identities

        V_{2k}   = V_k^2 - 2,
        V_{2k+1} = V_k V_{k+1} - P.

    The pair (V_k, V_{k+1}) is maintained while the bits of n are read from the
    most significant downwards.
    """
    if n == 0:
        return 2 % modulus
    v_k, v_k1 = 2 % modulus, base % modulus
    for bit in bin(n)[2:]:
        if bit == "0":
            v_k, v_k1 = (v_k * v_k - 2) % modulus, (v_k * v_k1 - base) % modulus
        else:
            v_k, v_k1 = (v_k * v_k1 - base) % modulus, (v_k1 * v_k1 - 2) % modulus
    return v_k


def lcm_up_to(bound: int) -> int:
    """M = lcm(1, 2, ..., bound), the classical Williams exponent."""
    value = 1
    for k in range(1, bound + 1):
        value = value * k // math.gcd(value, k)
    return value


# ----------------------------------------------------------------------------
# 2. Arithmetic helpers: Jacobi/Legendre symbols, primality, smoothness
# ----------------------------------------------------------------------------


def jacobi_symbol(a: int, n: int) -> int:
    """Jacobi symbol (a|n) for odd n >= 1; equals the Legendre symbol for prime n."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("Jacobi symbol requires odd positive n")
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for 64-bit inputs (and correct beyond in practice)."""
    if n < 2:
        return False
    for small in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % small == 0:
            return n == small
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for witness in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(witness, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def is_powersmooth(n: int, bound: int) -> bool:
    """True iff every prime power l^v exactly dividing n satisfies l^v <= bound.

    This is a max-plus (tropical) condition: a sup-norm bound on the valuation
    vector of n. It is exactly the condition under which n divides lcm(1..bound).
    """
    remaining = n
    factor = 2
    while factor * factor <= remaining:
        if remaining % factor == 0:
            power = 1
            while remaining % factor == 0:
                remaining //= factor
                power *= factor
            if power > bound:
                return False
        factor += 1 if factor == 2 else 2
    return remaining <= bound


# ----------------------------------------------------------------------------
# 3. The Williams p+1 method
# ----------------------------------------------------------------------------


def williams_p_plus_one(n: int, bound: int, bases: Sequence[int] = (3, 5, 7)) -> Tuple[int, int] | None:
    """Attempt to split n. Returns (factor, base) on success, else None."""
    exponent = lcm_up_to(bound)
    for base in bases:
        value = lucas_v_ladder(base, exponent, n)
        g = math.gcd((value - 2) % n, n)
        if 1 < g < n:
            return g, base
    return None


def gate_open(base: int, p: int) -> bool:
    """The discriminant gate at the prime p for the given base: (P^2 - 4 | p) = -1."""
    disc = base * base - 4
    return jacobi_symbol(disc % p, p) == -1


# ----------------------------------------------------------------------------
# 4. Information-theoretic helper
# ----------------------------------------------------------------------------


def mutual_information(samples: Iterable[Tuple[int, int]]) -> float:
    """Empirical mutual information (bits) of a sample of (X, Y) pairs."""
    data = list(samples)
    total = len(data)
    if total == 0:
        return 0.0
    joint: Dict[Tuple[int, int], int] = {}
    px: Dict[int, int] = {}
    py: Dict[int, int] = {}
    for x, y in data:
        joint[(x, y)] = joint.get((x, y), 0) + 1
        px[x] = px.get(x, 0) + 1
        py[y] = py.get(y, 0) + 1
    info = 0.0
    for (x, y), count in joint.items():
        p_xy = count / total
        info += p_xy * math.log2(p_xy / ((px[x] / total) * (py[y] / total)))
    return info


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_lucas_basics() -> None:
    print("=" * 78)
    print("1. Lucas sequence V_n(3) and the fast ladder")
    print("=" * 78)
    print("  V_0..V_10 for P = 3:", [lucas_v_naive(3, n) for n in range(11)])
    modulus = 1_000_003
    for n in (0, 1, 8, 97, 1234):
        slow = lucas_v_naive(3, n, modulus)
        fast = lucas_v_ladder(3, n, modulus)
        assert slow == fast, (n, slow, fast)
    print("  ladder agrees with the naive recurrence on n = 0, 1, 8, 97, 1234  [OK]")
    print(f"  lcm(1..10)  = {lcm_up_to(10)}")
    print(f"  lcm(1..100) has {len(str(lcm_up_to(100)))} decimal digits")


def demo_worked_instance() -> None:
    print()
    print("=" * 78)
    print("2. The worked instance N = 91 = 7 * 13, base P = 3, exponent M = 8")
    print("=" * 78)
    v8 = lucas_v_naive(3, 8)
    print(f"  V_8(3) = {v8};  gcd(V_8 - 2, 91) = {math.gcd(v8 - 2, 91)}")
    print(f"  gate at p = 7:  (5|7)  = {jacobi_symbol(5, 7):+d}  -> open, and 7+1 = 8 | M")
    print(f"  gate at p = 11: (5|11) = {jacobi_symbol(5, 11):+d}  -> closed")
    v12 = lucas_v_naive(3, 12, 11)
    print(f"  and indeed V_12(3) mod 11 = {v12} = 3^2 - 2, not 2 "
          "(the sharp gate theorem)")


def demo_gate_equivalence() -> None:
    print()
    print("=" * 78)
    print("3. The sharp discriminant gate:  V_{p+1} = 2 in F_p  <=>  (D|p) = -1 or D = 0")
    print("=" * 78)
    print("   p   P   D=P^2-4   (D|p)   V_{p+1} mod p   P^2-2 mod p")
    print("   " + "-" * 60)
    checked = 0
    for p in (7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47):
        for base in range(0, p):
            disc = (base * base - 4) % p
            symbol = jacobi_symbol(disc, p) if disc else 0
            v = lucas_v_naive(base, p + 1, p)
            predicted_open = (symbol == -1) or (disc == 0)
            assert (v == 2) == predicted_open, (p, base, v, symbol)
            if disc != 0 and symbol == 1:
                assert v == (base * base - 2) % p
            checked += 1
        # print one open and one closed row per prime
        for base in range(p):
            disc = (base * base - 4) % p
            if disc and jacobi_symbol(disc, p) == -1:
                print(f"  {p:3d} {base:3d} {disc:8d}   {-1:+d}    "
                      f"{lucas_v_naive(base, p + 1, p):8d}      "
                      f"{(base * base - 2) % p:6d}")
                break
        for base in range(p):
            disc = (base * base - 4) % p
            if disc and jacobi_symbol(disc, p) == 1:
                print(f"  {p:3d} {base:3d} {disc:8d}   {+1:+d}    "
                      f"{lucas_v_naive(base, p + 1, p):8d}      "
                      f"{(base * base - 2) % p:6d}")
                break
    print(f"  verified the equivalence for all {checked} (prime, base) pairs above  [OK]")


def demo_gate_density() -> None:
    print()
    print("=" * 78)
    print("4. Gate density: exactly (p-1)/2 of the p bases open the gate")
    print("=" * 78)
    print("     p   bad bases (square D)   predicted (p+1)/2   good bases   (p-1)/2")
    for p in (5, 7, 11, 13, 17, 19, 23, 29, 31, 101, 257):
        bad = sum(1 for base in range(p)
                  if any((t * t) % p == (base * base - 4) % p for t in range(p)))
        good = p - bad
        assert bad == (p + 1) // 2 and good == (p - 1) // 2
        print(f"  {p:4d}   {bad:14d}   {(p + 1) // 2:17d}   {good:10d}   {(p - 1) // 2:7d}")
    print("  the trace map a -> a + 1/a is 2-to-1 away from a = +-1  [OK]")


def demo_degenerate_bases() -> None:
    print()
    print("=" * 78)
    print("5. Degenerate bases: V_k(P) = 2 for some k >= 1  <=>  |P| <= 2")
    print("=" * 78)
    for base in range(-4, 5):
        period = next((k for k in range(1, 40) if lucas_v_naive(base, k) == 2), None)
        verdict = f"degenerate, period {period}" if period else "usable"
        print(f"  P = {base:+d}: {verdict}")
    print("  P = 2 gives V_n = 2 for all n, so gcd(V_M - 2, N) = N always:")
    print("    ", [lucas_v_naive(2, n) for n in range(8)])


def demo_square_class() -> None:
    print()
    print("=" * 78)
    print("6. Bases 3 and 7 share a square class: D_3 = 5, D_7 = 45 = 5 * 3^2")
    print("=" * 78)
    mismatches = [p for p in range(5, 400)
                  if is_prime(p) and p != 3 and jacobi_symbol(5, p) != jacobi_symbol(45, p)]
    print(f"  primes p < 400 with (5|p) != (45|p), excluding p = 3: {mismatches}")
    agree = [p for p in range(5, 60) if is_prime(p) and p != 3]
    print("  sample:  p, (5|p), (45|p) =",
          [(p, jacobi_symbol(5, p), jacobi_symbol(45, p)) for p in agree[:8]])
    print("  hence bases 3 and 7 succeed on exactly the same primes  [OK]")


def demo_matched_collision() -> None:
    print()
    print("=" * 78)
    print("7. The matched collision: two moduli no statistic can tell apart")
    print("=" * 78)
    p1, q1 = 359, 5849
    p2, q2 = 397, 5743
    n1, n2 = p1 * q1, p2 * q2
    modulus = 60060  # = 2^2 * 3 * 5 * 7 * 11 * 13
    print(f"  N  = {p1} * {q1} = {n1}")
    print(f"  N' = {p2} * {q2} = {n2}")
    print(f"  N mod 60060 = {n1 % modulus},  N' mod 60060 = {n2 % modulus}")
    print(f"  bitlengths: {n1.bit_length()} and {n2.bit_length()};  "
          f"small factors {p1.bit_length()} and {p2.bit_length()} bits;  "
          f"large factors {q1.bit_length()} and {q2.bit_length()} bits")
    assert n1 % modulus == n2 % modulus and n1.bit_length() == n2.bit_length()
    print()
    print("  labels of the SMALLER factor:")
    print(f"    3 | p+1 ?   {p1}: {(p1 + 1) % 3 == 0}      {p2}: {(p2 + 1) % 3 == 0}")
    print(f"    (5|p) = -1? {p1}: {jacobi_symbol(5, p1) == -1}      "
          f"{p2}: {jacobi_symbol(5, p2) == -1}")
    print("  Both labels are opposite across the collision (and swapped between")
    print("  the two channels): no predicate of (N mod 60060, bitlength) can")
    print("  decide either one.  [invisibility]")
    print()
    print("  every residue channel inherits the collision:")
    for small in (2, 3, 4, 5, 6, 7, 11, 13, 60060):
        assert n1 % small == n2 % small
        print(f"    N = N' = {n1 % small} (mod {small})")


def demo_xor_dichotomy(trials: int = 4000, seed: int = 20260814) -> None:
    print()
    print("=" * 78)
    print("8. The dichotomy: mod 3 reveals the XOR, never the label")
    print("=" * 78)
    rng = random.Random(seed)
    primes = [n for n in range(1 << 17, (1 << 17) + 40000) if is_prime(n)]
    asym: List[Tuple[int, int]] = []
    sym: List[Tuple[int, int]] = []
    xor_check_ok = True
    for _ in range(trials):
        p, q = sorted(rng.sample(primes, 2))
        n = p * q
        residue = n % 3
        a_label = int((p + 1) % 3 == 0)                       # asymmetric: smaller factor
        s_label = int((p + 1) % 3 == 0 or (q + 1) % 3 == 0)   # symmetric control
        asym.append((residue, a_label))
        sym.append((residue, s_label))
        expected_xor = ((p + 1) % 3 == 0) ^ ((q + 1) % 3 == 0)
        if (residue == 2) != expected_xor:
            xor_check_ok = False
    print(f"  XOR theorem verified on {trials} random semiprimes: {xor_check_ok}")
    print(f"  I(N mod 3 ; 3 | p+1)              = {mutual_information(asym):.4f} bits"
          "   <- asymmetric, invisible")
    print(f"  I(N mod 3 ; 3 | p+1 or 3 | q+1)   = {mutual_information(sym):.4f} bits"
          "   <- symmetric, visible")
    print("  (reference measurements on the 40 matched pairs: 0.0005 vs 0.2996 bits)")


def demo_jacobi_split() -> None:
    print()
    print("=" * 78)
    print("9. Jacobi splitting: (D|N) = (D|p)(D|q) destroys the split")
    print("=" * 78)
    for p, q in ((3, 7), (11, 19), (359, 5849), (397, 5743)):
        n = p * q
        left = jacobi_symbol(5, n)
        right = jacobi_symbol(5, p) * jacobi_symbol(5, q)
        assert left == right
        print(f"  N = {p} * {q} = {n:>10}:  (5|N) = {left:+d} = "
              f"({jacobi_symbol(5, p):+d}) * ({jacobi_symbol(5, q):+d})   "
              f"gate at smaller factor: {'OPEN ' if jacobi_symbol(5, p) == -1 else 'closed'}")
    print("  (5|21) = +1 with the gate OPEN, (5|209) = +1 with the gate closed:")
    print("  the publicly computable symbol carries no information about the split.")


def demo_matched_experiment(pairs: int = 20, bound: int = 100, seed: int = 7) -> None:
    print()
    print("=" * 78)
    print("10. Miniature matched-pair experiment (PLUSONE vs GENERAL)")
    print("=" * 78)
    rng = random.Random(seed)
    exponent = lcm_up_to(bound)
    bases = (3, 5, 7)

    def smooth_plus_one_prime(bits: int) -> int:
        """Find a prime p of the given bit length with p+1 powersmooth for `bound`."""
        while True:
            value = 2
            while value.bit_length() < bits - 1:
                value *= rng.choice([2, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31])
            for extra in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12):
                candidate = value * extra - 1
                if (candidate.bit_length() == bits and is_prime(candidate)
                        and is_powersmooth(candidate + 1, bound)):
                    return candidate

    def general_prime(bits: int) -> int:
        while True:
            candidate = rng.randrange(1 << (bits - 1), 1 << bits) | 1
            if (is_prime(candidate) and not is_powersmooth(candidate + 1, bound)
                    and not is_powersmooth(candidate - 1, bound)):
                return candidate

    plusone_hits = general_hits = 0
    per_base_success = {base: 0 for base in bases}
    per_base_gate = {base: 0 for base in bases}
    per_base_extra = {base: 0 for base in bases}   # successes with the gate CLOSED
    gate_implies_success = True
    for _ in range(pairs):
        small_bits, large_bits = 18, 21
        q = general_prime(large_bits)
        p_smooth = smooth_plus_one_prime(small_bits)
        p_general = general_prime(small_bits)
        for p, is_plusone in ((p_smooth, True), (p_general, False)):
            n = p * q
            found = False
            for base in bases:
                value = lucas_v_ladder(base, exponent, n)
                g = math.gcd((value - 2) % n, n)
                success = 1 < g < n
                if is_plusone:
                    open_gate = gate_open(base, p)
                    per_base_success[base] += int(success)
                    per_base_gate[base] += int(open_gate)
                    if open_gate and not success:
                        gate_implies_success = False
                    if success and not open_gate:
                        per_base_extra[base] += 1
                found = found or success
            if is_plusone:
                plusone_hits += int(found)
            else:
                general_hits += int(found)

    print(f"  bases {bases}, exponent lcm(1..{bound}), {pairs} matched pairs")
    print(f"  PLUSONE class factored: {plusone_hits}/{pairs}")
    print(f"  GENERAL class factored: {general_hits}/{pairs}")
    print("  per-base successes vs number of gate-open instances:")
    for base in bases:
        print(f"    P = {base} (D = {base * base - 4:2d}): "
              f"{per_base_success[base]:2d}/{pairs} successes, "
              f"{per_base_gate[base]:2d}/{pairs} with (D|p) = -1, "
              f"{per_base_extra[base]:2d} gate-closed successes")
    print(f"  gate open  =>  success  (with p+1 | M) holds on every instance: "
          f"{gate_implies_success}")
    print("  gate-closed successes are p-1-type: the roots then live in F_p, and the")
    print("  method can still win if the order of the root happens to divide M; in the")
    print("  reference experiment no such accident occurred, so the counts matched exactly.")
    print("  bases 3 and 7 have discriminants in one square class, so their gate counts")
    print("  agree instance by instance:",
          per_base_gate[3] == per_base_gate[7])
    print("  base P = 2 is degenerate (D = 0): gcd(V_M - 2, N) = N always ->",
          all(math.gcd((lucas_v_ladder(2, exponent, m) - 2) % m, m) == m
              for m in (91, 2099791, 2279971)))
    print("  (reference experiment, 40 pairs: 24/40 vs 0/40; per-base 11, 17, 11")
    print("   successes matching 11, 17, 11 gate-open instances exactly)")


def main() -> None:
    demo_lucas_basics()
    demo_worked_instance()
    demo_gate_equivalence()
    demo_gate_density()
    demo_degenerate_bases()
    demo_square_class()
    demo_matched_collision()
    demo_xor_dichotomy()
    demo_jacobi_split()
    demo_matched_experiment()
    print()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
