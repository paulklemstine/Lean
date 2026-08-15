"""
The splitting-type channel of a cyclic field: numerical demonstration.
======================================================================

For a prime f, the Galois group of Q(zeta_f)/Q is cyclic of order n = f - 1.
Writing the Frobenius of an unramified prime p as g^a for a fixed generator g,
the splitting type (residue degree) of p is

        T(a) = n / gcd(a, n),

and p factors into n / T(a) primes of degree T(a).  For a semiprime N = p q the
Frobenius exponents add, so the visible datum is c = (a + b) mod n while the
hidden datum is the unordered type pair {T(a), T(b)}.  The type-pair channel is

        I_pair(n) = H({T(a),T(b)}) - H({T(a),T(b)} | a + b).

This script verifies, by exact enumeration in exact rational/float arithmetic:

  1. the Euler-totient law for the type distribution, rate(d) = phi(d)/n;
  2. losslessness of the residue -> type channel and "thickening zero";
  3. the exact closed forms of I_pair for n = 2,3,4,5,6,8,9,10,12,15,16,27,32;
  4. the failure of the one-bit binary-fork cap for every even order >= 4;
  5. CRT additivity  I_pair(mn) = I_pair(m) + I_pair(n)  for coprime m, n;
  6. the prime closed form and the fact that I_pair(p) = 1 exactly at p = 2;
  7. the 2-adic ladder I_pair(2^k) = (4/3)(1 - 4^-k) and its 3-adic analogue;
  8. an ODD cyclic order above the cap, M = 300840735195, via additivity;
  9. lossiness of the binary root-count readout and of the split-count
     projection, both of which stay below one bit where the type does not.

Run with:  python3 demo.py
"""

from __future__ import annotations

from collections import Counter
from math import gcd, log2
from typing import Dict, Iterable, List, Tuple

Pair = Tuple[int, int]

# ----------------------------------------------------------------------------
# 1. Core arithmetic
# ----------------------------------------------------------------------------


def splitting_type(n: int, a: int) -> int:
    """The residue degree T(a) = n / gcd(a, n) of the exponent a in C_n."""
    return n // gcd(a, n)


def euler_phi(m: int) -> int:
    """Euler's totient function, by trial division."""
    result: int = m
    d: int = 2
    k: int = m
    while d * d <= k:
        if k % d == 0:
            while k % d == 0:
                k //= d
            result -= result // d
        d += 1
    if k > 1:
        result -= result // k
    return result


def divisors(n: int) -> List[int]:
    """All positive divisors of n, in increasing order."""
    small: List[int] = [d for d in range(1, int(n**0.5) + 1) if n % d == 0]
    large: List[int] = [n // d for d in reversed(small) if d * d != n]
    return small + large


# ----------------------------------------------------------------------------
# 2. Counting entropy
# ----------------------------------------------------------------------------


def entropy_of_counts(counts: Iterable[int]) -> float:
    """Shannon entropy in bits of the distribution proportional to `counts`."""
    cs: List[int] = [c for c in counts if c > 0]
    total: int = sum(cs)
    if total == 0:
        return 0.0
    return -sum((c / total) * log2(c / total) for c in cs)


def type_entropy(n: int) -> float:
    """H(T): entropy of the splitting type of a single prime."""
    return entropy_of_counts(Counter(splitting_type(n, a) for a in range(n)).values())


def type_entropy_totient_law(n: int) -> float:
    """H(T) computed from the Euler-totient law sum_{d|n} (phi(d)/n) log2(n/phi(d))."""
    return sum((euler_phi(d) / n) * log2(n / euler_phi(d)) for d in divisors(n))


# ----------------------------------------------------------------------------
# 3. The type-pair channel
# ----------------------------------------------------------------------------


def pair_channel_parts(n: int) -> Tuple[float, float, float]:
    """Return (H(pair), H(pair | N mod f), I_pair) by exact box enumeration."""
    types: List[int] = [splitting_type(n, a) for a in range(n)]
    joint: Counter = Counter()
    slices: Dict[int, Counter] = {c: Counter() for c in range(n)}
    for a in range(n):
        ta: int = types[a]
        for b in range(n):
            tb: int = types[b]
            tau: Pair = (min(ta, tb), max(ta, tb))
            joint[tau] += 1
            slices[(a + b) % n][tau] += 1
    h_pair: float = entropy_of_counts(joint.values())
    # every residue class has exactly n preimages, so the weights are uniform
    h_cond: float = sum(entropy_of_counts(s.values()) for s in slices.values()) / n
    return h_pair, h_cond, h_pair - h_cond


def I_pair(n: int) -> float:
    """The type-pair channel I({T(p),T(q)} ; N mod f) in bits."""
    return pair_channel_parts(n)[2]


def I_pair_prime_formula(p: int) -> float:
    """Closed form of I_pair at a prime cyclic order p (0 log 0 = 0 at p = 2)."""
    term_1: float = (p - 1) * (2 * p - 1) * log2(p - 1) / p**2 if p > 2 else 0.0
    term_2: float = (p - 1) * (p - 2) * log2(p - 2) / p**2 if p > 2 else 0.0
    return log2(p) - term_1 + term_2


def root_count_entropy(n: int) -> float:
    """H of the binary readout 'does the prime split completely?' (= H(1/n))."""
    return entropy_of_counts(
        Counter(1 if splitting_type(n, a) == 1 else 0 for a in range(n)).values()
    )


def split_count_channel(n: int) -> float:
    """I_s(n): the channel of the 3-state split-count projection s in {0,1,2}."""
    types: List[int] = [splitting_type(n, a) for a in range(n)]
    joint: Counter = Counter()
    slices: Dict[int, Counter] = {c: Counter() for c in range(n)}
    for a in range(n):
        for b in range(n):
            s: int = int(types[a] == 1) + int(types[b] == 1)
            joint[s] += 1
            slices[(a + b) % n][s] += 1
    h: float = entropy_of_counts(joint.values())
    h_cond: float = sum(entropy_of_counts(sl.values()) for sl in slices.values()) / n
    return h - h_cond


def residue_type_mutual_information(n: int, thickening: int = 1) -> float:
    """I(residue ; T) where the residue is observed modulo n * thickening."""
    joint: Counter = Counter()
    for a in range(n * thickening):
        joint[(a, splitting_type(n, a % n))] += 1
    h_x: float = log2(n * thickening)
    h_t: float = entropy_of_counts(
        Counter(splitting_type(n, a % n) for a in range(n * thickening)).values()
    )
    h_xt: float = entropy_of_counts(joint.values())
    return h_x + h_t - h_xt


# ----------------------------------------------------------------------------
# 4. Reporting helpers
# ----------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def close(x: float, y: float, tol: float = 1e-9) -> str:
    return "OK " if abs(x - y) < tol else "!! "


# ----------------------------------------------------------------------------
# 5. The demonstrations
# ----------------------------------------------------------------------------


def demo_totient_law() -> None:
    rule("1. The splitting type is totient-distributed:  rate(d) = phi(d)/n")
    for n in (2, 4, 6, 10, 12, 16):
        counts: Counter = Counter(splitting_type(n, a) for a in range(n))
        states: str = ", ".join(f"T={d}: {counts[d]}/{n}" for d in sorted(counts))
        direct: float = type_entropy(n)
        law: float = type_entropy_totient_law(n)
        print(f"  n = {n:2d} | {states}")
        print(
            f"         | H(T) = {direct:.6f}   totient law = {law:.6f}  "
            f"{close(direct, law)}"
        )


def demo_losslessness() -> None:
    rule("2. Residue -> type is lossless, and thickening the modulus adds nothing")
    for n in (4, 6, 12):
        h_t: float = type_entropy(n)
        for thick in (1, 2, 5):
            info: float = residue_type_mutual_information(n, thick)
            print(
                f"  n = {n:2d}, residue mod {n*thick:3d} : I(residue;T) = {info:.6f}"
                f"   H(T) = {h_t:.6f}  {close(info, h_t)}"
            )


def demo_exact_values() -> None:
    rule("3. Exact closed forms of the type-pair channel")
    L3, L5 = log2(3), log2(5)
    closed: Dict[int, Tuple[str, float]] = {
        2: ("1", 1.0),
        3: ("log2(3) - 10/9", L3 - 10 / 9),
        4: ("5/4", 5 / 4),
        5: ("log2(5) + (12/25) log2(3) - 72/25", L5 + 12 / 25 * L3 - 72 / 25),
        6: ("log2(3) - 1/9", L3 - 1 / 9),
        8: ("21/16", 21 / 16),
        9: ("(10/9) log2(3) - 100/81", 10 / 9 * L3 - 100 / 81),
        10: ("log2(5) + (12/25) log2(3) - 47/25", L5 + 12 / 25 * L3 - 47 / 25),
        12: ("log2(3) + 5/36", L3 + 5 / 36),
        15: ("(37/25) log2(3) + log2(5) - 898/225", 37 / 25 * L3 + L5 - 898 / 225),
        16: ("85/64", 85 / 64),
        27: ("(91/81) log2(3) - 910/729", 91 / 81 * L3 - 910 / 729),
        32: ("341/256", 341 / 256),
    }
    print(f"  {'n':>3} {'H(T)':>9} {'H(pair)':>9} {'H(pair|N)':>10} "
          f"{'I_pair':>9} {'closed form':>36} {'cap?':>6}")
    for n in sorted(closed):
        h_pair, h_cond, info = pair_channel_parts(n)
        name, value = closed[n]
        verdict: str = "ABOVE" if info > 1 + 1e-12 else ("AT" if abs(info - 1) < 1e-12 else "below")
        print(
            f"  {n:>3} {type_entropy(n):9.4f} {h_pair:9.4f} {h_cond:10.4f} "
            f"{info:9.6f} {name:>36} {verdict:>6}  {close(info, value)}"
        )


def demo_cap_failure() -> None:
    rule("4. The one-bit binary-fork cap fails for every even order >= 4")
    for n in (2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 32):
        info: float = I_pair(n)
        print(f"  I_pair({n:2d}) = {info:.6f}   {'>' if info > 1 else '='} 1 bit")
    print("\n  Richness of the divisor lattice, not size, governs the channel:")
    print(f"    n = 12 has {len(divisors(12))} divisors, I_pair = {I_pair(12):.6f}")
    print(f"    n = 16 has {len(divisors(16))} divisors, I_pair = {I_pair(16):.6f}")


def demo_crt_additivity() -> None:
    rule("5. CRT additivity:  I_pair(m n) = I_pair(m) + I_pair(n)  for coprime m, n")
    factorisations: List[Tuple[int, int]] = [
        (4, 3), (2, 5), (3, 5), (2, 7), (2, 9), (4, 5), (8, 3), (3, 7)
    ]
    for m, n in factorisations:
        lhs: float = I_pair(m * n)
        rhs: float = I_pair(m) + I_pair(n)
        print(
            f"  I_pair({m*n:3d}) = {lhs:.9f}   I_pair({m}) + I_pair({n}) = {rhs:.9f}"
            f"   {close(lhs, rhs)}"
        )
    print("\n  Doubling law  I_pair(2m) = I_pair(m) + 1  for odd m:")
    for m in (3, 5, 7, 9, 15):
        print(
            f"    I_pair({2*m:2d}) - I_pair({m:2d}) = {I_pair(2*m) - I_pair(m):.9f}"
            f"   {close(I_pair(2*m) - I_pair(m), 1.0)}"
        )


def demo_prime_formula() -> None:
    rule("6. The prime closed form, and the cap attained only at p = 2")
    print("     I_pair(p) = log2 p - (p-1)(2p-1) log2(p-1) / p^2"
          " + (p-1)(p-2) log2(p-2) / p^2")
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31):
        enumerated: float = I_pair(p)
        formula: float = I_pair_prime_formula(p)
        envelope: float = (log2(p) + 3 * p) / p**2
        print(
            f"  p = {p:2d} : enumerated {enumerated:.9f}   formula {formula:.9f}"
            f"   envelope {envelope:.6f}  {close(enumerated, formula)}"
        )
    print("\n  Only p = 2 reaches the cap; every odd prime order is strictly below,")
    print("  hence any order above one bit must be composite.")


def demo_ladders() -> None:
    rule("7. Geometric prime-power ladders")
    print("  2-adic:  I_pair(2^k) = (4/3)(1 - 4^-k),  increments 4^-k,  sup = 4/3")
    previous: float = 0.0
    for k in range(1, 6):
        value: float = I_pair(2**k)
        predicted: float = (4 / 3) * (1 - 4.0 ** (-k))
        print(
            f"    k = {k} : I_pair({2**k:2d}) = {value:.9f}  predicted {predicted:.9f}"
            f"  increment {value - previous:.9f}  {close(value, predicted)}"
        )
        previous = value
    print("\n  3-adic:  I_pair(3^k) = (1 - 9^-k) (9/8) I_pair(3)")
    base: float = I_pair(3)
    for k in range(1, 4):
        value = I_pair(3**k)
        predicted = (1 - 9.0 ** (-k)) * (9 / 8) * base
        print(
            f"    k = {k} : I_pair({3**k:2d}) = {value:.9f}  predicted {predicted:.9f}"
            f"  {close(value, predicted)}"
        )


def demo_odd_above_cap() -> None:
    rule("8. An ODD cyclic order above the cap (evenness is NOT the cause)")
    atoms: List[int] = [9, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    total: float = 0.0
    modulus: int = 1
    for atom in atoms:
        contribution: float = I_pair(atom)
        total += contribution
        modulus *= atom
        print(f"    + I_pair({atom:2d}) = {contribution:.9f}   running total {total:.9f}")
    print(f"\n  M = {modulus} (odd), I_pair(M) = {total:.9f} > 1 by CRT additivity.")
    print("  Direct enumeration would need about "
          f"{modulus**2:.3e} box entries; additivity needs ten small boxes.")


def demo_lossy_readouts() -> None:
    rule("9. Binary readouts are lossy: the type, not the root count, is complete")
    for n in (4, 6):
        h_nr: float = root_count_entropy(n)
        h_t: float = type_entropy(n)
        binary: float = -(1 / n) * log2(1 / n) - (1 - 1 / n) * log2(1 - 1 / n)
        print(
            f"  n = {n}: H(root count) = {h_nr:.6f} = H(1/{n}) = {binary:.6f}"
            f"  {close(h_nr, binary)}   vs H(T) = {h_t:.6f}"
        )
    print("\n  The split-count projection recovers only a small face of the channel:")
    for n in (4, 6):
        print(
            f"    n = {n}: I_s = {split_count_channel(n):.6f}  <  "
            f"I_pair = {I_pair(n):.6f}   (and I_s < 1 while I_pair > 1)"
        )
    print("\n  Which-factor wall: the unordered channel equals the ordered channel.")
    for n in (4, 6, 12):
        ordered_joint: Counter = Counter()
        ordered_slices: Dict[int, Counter] = {c: Counter() for c in range(n)}
        for a in range(n):
            for b in range(n):
                key: Pair = (splitting_type(n, a), splitting_type(n, b))
                ordered_joint[key] += 1
                ordered_slices[(a + b) % n][key] += 1
        ordered: float = entropy_of_counts(ordered_joint.values()) - sum(
            entropy_of_counts(s.values()) for s in ordered_slices.values()
        ) / n
        print(
            f"    n = {n:2d}: ordered {ordered:.9f}   unordered {I_pair(n):.9f}"
            f"   wall = {abs(ordered - I_pair(n)):.2e}"
        )


def main() -> None:
    print(__doc__)
    demo_totient_law()
    demo_losslessness()
    demo_exact_values()
    demo_cap_failure()
    demo_crt_additivity()
    demo_prime_formula()
    demo_ladders()
    demo_odd_above_cap()
    demo_lossy_readouts()
    rule("Summary")
    print("  The splitting type is a complete multi-state invariant with")
    print("  totient rates; its semiprime pair channel is additive over coprime")
    print("  factorisations, closed-form at prime atoms, geometric along")
    print("  prime-power ladders, and strictly above one bit on infinitely many")
    print("  cyclic orders -- including odd ones.  The one-bit cap was a law")
    print("  about two-state readouts, not about semiprimes.")


if __name__ == "__main__":
    main()
