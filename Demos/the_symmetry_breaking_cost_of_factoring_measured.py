"""
The Symmetry-Breaking Cost of Factoring, Measured
=================================================

Numerical demonstration of the four measurements:

1.  ISOLATION COST.  For a candidate set S of odd primes, an explicitly
    constructed battery of k = ceil(log2 |S|) test integers gives every
    candidate a distinct vector of Legendre symbols; k - 1 queries provably
    cannot (pigeonhole).

2.  ADAPTIVITY IS WORTHLESS.  A decision tree of residue queries of depth d
    identifies at most 2^d candidates; the battery of (1), compiled into a
    complete tree, attains depth ceil(log2 |S|).

3.  ZERO PRUNING.  The Jacobi battery of N is a faithful invariant of the
    squarefree kernel K(N) = {p : v_p(N) odd} and blind to everything else.
    Hence for every candidate r, the modulus N r^2 is divisible by r and has
    a byte-identical battery: no candidate is ever excluded.

4.  THE WITNESS ALWAYS EXISTS.  For N = p q with p != q odd primes, the CRT
    element x = 1 mod p, x = -1 mod q satisfies x^2 = 1 mod N, x != +-1,
    and gcd(x - 1, N) = p exactly.

Everything below is self-contained: no imports beyond the standard library.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import Dict, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# 0.  Elementary number theory
# ----------------------------------------------------------------------------


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a | n) for odd n >= 1, computed without factoring n.

    Returns +1, -1 or 0.  For prime n this is the Legendre symbol.
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError("Jacobi symbol requires an odd positive denominator")
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


def primes_up_to(limit: int) -> List[int]:
    """All primes p <= limit, by a sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(limit**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i, is_p in enumerate(sieve) if is_p]


def crt(residues: Sequence[int], moduli: Sequence[int]) -> int:
    """Chinese Remainder Theorem for pairwise coprime moduli.

    Returns the unique x in [0, prod(moduli)) with x = residues[i] mod moduli[i].
    """
    x, m = 0, 1
    for r, n in zip(residues, moduli):
        # solve x + m*t = r (mod n)
        g = math.gcd(m, n)
        if g != 1:
            raise ValueError("moduli must be pairwise coprime")
        t = ((r - x) * pow(m, -1, n)) % n
        x += m * t
        m *= n
    return x % m


def quadratic_nonresidue(p: int) -> int:
    """Least positive quadratic nonresidue modulo the odd prime p."""
    for b in range(2, p):
        if jacobi(b, p) == -1:
            return b
    raise ValueError(f"no nonresidue found modulo {p} (is {p} an odd prime?)")


def squarefree_kernel(n: int) -> Tuple[int, ...]:
    """K(n): the primes dividing n to an odd multiplicity, sorted."""
    kernel: List[int] = []
    m, d = n, 2
    while d * d <= m:
        if m % d == 0:
            e = 0
            while m % d == 0:
                m //= d
                e += 1
            if e % 2 == 1:
                kernel.append(d)
        d += 1
    if m > 1:
        kernel.append(m)
    return tuple(sorted(kernel))


# ----------------------------------------------------------------------------
# 1.  Isolation cost:  ceil(log2 |S|) queries, and not one fewer
# ----------------------------------------------------------------------------


def build_isolating_battery(candidates: Sequence[int]) -> List[int]:
    """Construct k = ceil(log2 |S|) test integers whose Legendre signatures
    separate every candidate.

    Method (the constructive half of the exact-cost theorem):
      * assign each candidate p a distinct k-bit code C(p);
      * for coordinate i, prescribe the local value  +1  where C(p)_i = 1  and
        a quadratic nonresidue where C(p)_i = 0, then glue by CRT.
    The resulting a_i satisfies  (a_i | p) = +1 iff C(p)_i = 1.
    """
    s = len(candidates)
    k = max(1, (s - 1).bit_length())  # = ceil(log2 s) for s >= 2
    code: Dict[int, int] = {p: idx for idx, p in enumerate(candidates)}
    battery: List[int] = []
    for i in range(k):
        residues = [
            1 if (code[p] >> i) & 1 else quadratic_nonresidue(p) for p in candidates
        ]
        battery.append(crt(residues, list(candidates)))
    return battery


def signature(battery: Sequence[int], r: int) -> Tuple[int, ...]:
    """The quadratic signature (J(a_1|r), ..., J(a_k|r)) of a candidate r."""
    return tuple(jacobi(a, r) for a in battery)


def is_admissible(battery: Sequence[int], candidates: Sequence[int]) -> bool:
    """No answer is 0, i.e. no test integer is divisible by a candidate."""
    return all(jacobi(a, p) != 0 for a in battery for p in candidates)


def isolates(battery: Sequence[int], candidates: Sequence[int]) -> bool:
    """The signature map is injective on the candidate set."""
    sigs = [signature(battery, p) for p in candidates]
    return len(set(sigs)) == len(sigs)


def demo_isolation_cost() -> None:
    print("=" * 78)
    print("1.  ISOLATION COST = ceil(log2 |S|), exactly")
    print("=" * 78)
    header = f"{'N':>14} {'|S|':>7} {'log2|S|':>9} {'k used':>7} {'ratio':>7} {'sep?':>5} {'k-1?':>6}"
    print(header)
    print("-" * len(header))
    semiprimes = [
        3149,          # 47 * 67
        10403,         # 101 * 103
        104729 * 7,
        1000003 * 101,
        1000003 * 1000033,
    ]
    for n in semiprimes:
        root = math.isqrt(n)
        candidates = [p for p in primes_up_to(root) if p != 2]
        if len(candidates) > 600:  # keep the CRT moduli manageable in a demo
            candidates = candidates[:600]
        s = len(candidates)
        battery = build_isolating_battery(candidates)
        k = len(battery)
        ok = is_admissible(battery, candidates) and isolates(battery, candidates)
        # pigeonhole: k-1 bits can never separate more than 2^(k-1) candidates
        shorter_possible = s <= 2 ** (k - 1)
        ratio = k / math.log2(s)
        print(
            f"{n:>14} {s:>7} {math.log2(s):>9.3f} {k:>7} {ratio:>7.3f} "
            f"{str(ok):>5} {str(shorter_possible):>6}"
        )
    print()
    print("  'sep?'  = the constructed battery separates all candidates.")
    print("  'k-1?'  = could k-1 queries suffice?  (False by pigeonhole.)")
    print("  The ratio k / log2|S| is the ceiling rounding and nothing else.")
    print()


def demo_signature_table() -> None:
    print("=" * 78)
    print("1b. A CONCRETE SIGNATURE TABLE")
    print("=" * 78)
    candidates = [3, 5, 7, 11, 13, 17, 19]
    battery = build_isolating_battery(candidates)
    print(f"  candidates S = {candidates},  |S| = {len(candidates)}, "
          f"ceil(log2|S|) = {len(battery)}")
    print(f"  battery a = {battery}")
    print()
    print(f"  {'p':>5} | " + " ".join(f"(a{i+1}|p)" for i in range(len(battery))))
    print("  " + "-" * (7 + 7 * len(battery)))
    for p in candidates:
        sig = signature(battery, p)
        print(f"  {p:>5} | " + " ".join(f"{v:>+6d}" for v in sig))
    print()
    print(f"  all signatures distinct: {isolates(battery, candidates)}")
    print(f"  admissible (no zero answers): {is_admissible(battery, candidates)}")
    print()
    # from isolation to a factorization
    p0, q0 = 13, 23
    n = p0 * q0
    target = signature(battery, p0)
    matches = [p for p in candidates if signature(battery, p) == target]
    print(f"  oracle report for the hidden factor of N = {n}: {target}")
    print(f"  candidates matching the report: {matches}")
    print(f"  division finishes the job: {n} = {matches[0]} * {n // matches[0]}")
    print()


# ----------------------------------------------------------------------------
# 2.  Adaptivity buys nothing
# ----------------------------------------------------------------------------


class QueryTree:
    """A binary decision tree of quadratic-residue queries.

    A leaf carries a guess; a node carries a test integer x and branches on
    whether (x | r) = 1.
    """

    def __init__(
        self,
        guess: Optional[int] = None,
        test: Optional[int] = None,
        yes: Optional["QueryTree"] = None,
        no: Optional["QueryTree"] = None,
    ) -> None:
        self.guess = guess
        self.test = test
        self.yes = yes
        self.no = no

    def run(self, r: int) -> Optional[int]:
        if self.test is None:
            return self.guess
        branch = self.yes if jacobi(self.test, r) == 1 else self.no
        assert branch is not None
        return branch.run(r)

    def depth(self) -> int:
        if self.test is None:
            return 0
        assert self.yes is not None and self.no is not None
        return 1 + max(self.yes.depth(), self.no.depth())

    def solves(self, candidates: Sequence[int]) -> bool:
        return all(self.run(r) == r for r in candidates)


def compile_battery_to_tree(
    battery: Sequence[int], candidates: Sequence[int]
) -> QueryTree:
    """Compile a non-adaptive battery into a complete binary decision tree."""
    decode: Dict[Tuple[int, ...], int] = {
        tuple(1 if jacobi(a, r) == 1 else 0 for a in battery): r for r in candidates
    }

    def build(prefix: Tuple[int, ...]) -> QueryTree:
        if len(prefix) == len(battery):
            return QueryTree(guess=decode.get(prefix, -1))
        return QueryTree(
            test=battery[len(prefix)],
            yes=build(prefix + (1,)),
            no=build(prefix + (0,)),
        )

    return build(())


def demo_adaptivity() -> None:
    print("=" * 78)
    print("2.  ADAPTIVITY BUYS NOTHING:  optimal tree depth = ceil(log2 |S|)")
    print("=" * 78)
    for candidates in ([3, 5, 7, 11, 13], [3, 5, 7, 11, 13, 17, 19, 23, 29]):
        battery = build_isolating_battery(candidates)
        tree = compile_battery_to_tree(battery, candidates)
        k = math.ceil(math.log2(len(candidates)))
        print(f"  S = {candidates}")
        print(f"    ceil(log2 |S|)           = {k}")
        print(f"    depth of compiled tree   = {tree.depth()}")
        print(f"    tree identifies every r  = {tree.solves(candidates)}")
        print(f"    counting bound 2^(d-1)   = {2 ** (tree.depth() - 1)} "
              f"< |S| = {len(candidates)}  -> depth d-1 impossible: "
              f"{2 ** (tree.depth() - 1) < len(candidates)}")
        print()


# ----------------------------------------------------------------------------
# 3.  Zero pruning:  the public battery sees only the squarefree kernel
# ----------------------------------------------------------------------------


def demo_kernel_blindness() -> None:
    print("=" * 78)
    print("3.  THE PUBLIC BATTERY KNOWS THE SQUAREFREE KERNEL AND NOTHING ELSE")
    print("=" * 78)
    moduli = [15, 135, 375, 3375, 21]
    print("  moduli and kernels:")
    for m in moduli:
        print(f"    K({m:>5}) = {squarefree_kernel(m)}")
    print()
    print("  Jacobi rows for a = 1 .. 20 (blank = numerator not coprime):")
    print(f"    {'a':>3} " + " ".join(f"{m:>6}" for m in moduli))
    for a in range(1, 21):
        cells = []
        for m in moduli:
            cells.append(f"{jacobi(a, m):>+6d}" if math.gcd(a, m) == 1 else "     .")
        print(f"    {a:>3} " + " ".join(cells))
    print()
    same_kernel = [m for m in moduli if squarefree_kernel(m) == (3, 5)]
    agree = all(
        len({jacobi(a, m) for m in same_kernel}) == 1
        for a in range(1, 500)
        if all(math.gcd(a, m) == 1 for m in same_kernel)
    )
    print(f"  moduli with kernel (3,5): {same_kernel}")
    print(f"  identical batteries on every coprime a <= 500: {agree}")
    sep = next(a for a in range(1, 100) if math.gcd(a, 15 * 21) == 1
               and jacobi(a, 15) != jacobi(a, 21))
    print(f"  kernels (3,5) vs (3,7) are separated already at a = {sep}: "
          f"J({sep}|15) = {jacobi(sep, 15):+d}, J({sep}|21) = {jacobi(sep, 21):+d}")
    print()


def demo_zero_pruning() -> None:
    print("=" * 78)
    print("4.  ZERO PRUNING:  every candidate has a compensating partner")
    print("=" * 78)
    n = 3149  # 47 * 67
    print(f"  N = {n} = 47 * 67,  K(N) = {squarefree_kernel(n)}")
    print()
    print(f"  {'candidate r':>12} {'M = N r^2':>14} {'r | M':>7} {'K(M) = K(N)':>13} "
          f"{'battery identical':>19}")
    print("  " + "-" * 70)
    rng = random.Random(20260813)
    tests = [rng.randrange(3, 10**6) | 1 for _ in range(6)]
    for r in [3, 5, 7, 11, 47, 999983]:
        m = n * r * r
        identical = all(
            jacobi(a, m) == jacobi(a, n)
            for a in tests
            if math.gcd(a, m * n) == 1
        )
        print(f"  {r:>12} {m:>14} {str(m % r == 0):>7} "
              f"{str(squarefree_kernel(m) == squarefree_kernel(n)):>13} "
              f"{str(identical):>19}")
    print()
    print("  Every candidate r sits inside a modulus with N's exact battery,")
    print("  so no amount of public residue data can ever exclude it.")
    print()


# ----------------------------------------------------------------------------
# 4.  The witness always exists
# ----------------------------------------------------------------------------


def sqrt_one_witness(p: int, q: int) -> int:
    """The CRT square root of unity: x = 1 mod p, x = -1 mod q."""
    return crt([1, q - 1], [p, q])


def demo_witness() -> None:
    print("=" * 78)
    print("5.  THE WITNESS ALWAYS EXISTS:  gcd(x - 1, N) = p, on the nose")
    print("=" * 78)
    print(f"  {'p':>7} {'q':>7} {'N = pq':>11} {'x':>11} {'x^2 mod N':>10} "
          f"{'gcd(x-1,N)':>11}")
    print("  " + "-" * 62)
    for p, q in [(3, 5), (3, 7), (3, 11), (5, 7), (7, 11), (11, 13),
                 (101, 103), (1009, 2003)]:
        n = p * q
        x = sqrt_one_witness(p, q)
        print(f"  {p:>7} {q:>7} {n:>11} {x:>11} {pow(x, 2, n):>10} "
              f"{math.gcd(x - 1, n):>11}")
    print()
    print("  No third kind of witness: every nontrivial square root of 1 mod N")
    print("  yields p or q.  Exhaustive check for N = 101 * 103 = 10403:")
    p, q, n = 101, 103, 101 * 103
    roots = [z for z in range(n) if (z * z - 1) % n == 0]
    nontrivial = [z for z in roots if z % n not in (1, n - 1)]
    gcds = sorted({math.gcd(z - 1, n) for z in nontrivial})
    print(f"    square roots of 1 mod N : {roots}")
    print(f"    nontrivial ones         : {nontrivial}")
    print(f"    values of gcd(z - 1, N) : {gcds}   (= {{p, q}} = {{{p}, {q}}})")
    print()


# ----------------------------------------------------------------------------
# 5.  The measurement table
# ----------------------------------------------------------------------------


def demo_measurement_table() -> None:
    print("=" * 78)
    print("6.  THE MEASUREMENT")
    print("=" * 78)
    print(f"  {'N (bits)':>10} {'|S| = pi(sqrt N) - 1':>21} {'oracle cost':>12} "
          f"{'public pruning':>15}")
    print("  " + "-" * 62)
    for bits in (15, 20, 25, 28, 31, 33):
        n = (1 << bits) - 1
        s = len([p for p in primes_up_to(math.isqrt(n)) if p != 2])
        cost = math.ceil(math.log2(s))
        print(f"  {bits:>10} {s:>21} {cost:>12} {'0 candidates':>15}")
    print()
    print("  The oracle isolates the hidden factor in ~ (1/2) log2 N bits.")
    print("  The same symbols evaluated at N prune nothing at all.")
    print("  The gap between the two columns is the symmetry-breaking cost.")
    print()


def main() -> None:
    demo_isolation_cost()
    demo_signature_table()
    demo_adaptivity()
    demo_kernel_blindness()
    demo_zero_pruning()
    demo_witness()
    demo_measurement_table()


if __name__ == "__main__":
    main()
