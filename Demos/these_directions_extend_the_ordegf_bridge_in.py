"""Carmichael's Fibonacci Primitive Divisor Theorem -- numerical demonstration.

A *primitive prime divisor* of the Fibonacci number F(n) is a prime p with
p | F(n) but p does not divide F(k) for any 0 < k < n.

Carmichael's theorem (1913): F(n) has a primitive prime divisor for every
index n outside the exceptional set {1, 2, 6, 12}.

This script reproduces, by direct computation, every ingredient of the verified
proof:

  * the strong-divisibility GCD identity  gcd(F(m), F(n)) = F(gcd(m, n));
  * the unconditional prime-index theorem (every prime factor of F(p) is
    primitive when p is prime);
  * the primitive-part stripping algorithm `prim_part` and its witness;
  * the exceptional set {1, 2, 6, 12} as the vanishing locus of the certificate;
  * a Lifting-the-Exponent spot check for the p-adic valuation of F(mk).

It is fully self-contained: only the Python standard library is used.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Fibonacci numbers
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """Return F(n) with F(0) = 0, F(1) = 1, F(n+2) = F(n+1) + F(n)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


# --------------------------------------------------------------------------- #
# Elementary number theory helpers (inlined, no external deps)
# --------------------------------------------------------------------------- #
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def min_prime_factor(n: int, trial_bound: int = 5_000_000) -> int:
    """Smallest prime factor of n >= 2.

    Trial division is capped at `trial_bound`; if no factor below the cap is
    found, n is returned (which is the correct primitive divisor whenever n is
    itself prime, the common case for primitive parts)."""
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n and d <= trial_bound:
        if n % d == 0:
            return d
        d += 2
    return n


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n >= 1 as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def proper_divisors(n: int) -> List[int]:
    """All d with 0 < d < n and d | n."""
    return [d for d in range(1, n) if n % d == 0]


def padic_val(p: int, n: int) -> int:
    """p-adic valuation v_p(n): largest e with p^e | n  (n >= 1)."""
    e = 0
    while n % p == 0:
        n //= p
        e += 1
    return e


# --------------------------------------------------------------------------- #
# The primitive-part certificate (mirrors the verified `primPart`)
# --------------------------------------------------------------------------- #
def strip_all(r: int, m: int) -> int:
    """Strip every prime shared between r and m by repeated gcd division."""
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def prim_part(n: int) -> int:
    """Primitive part of F(n): start from F(n) and strip every prime shared
    with F(d) for each proper divisor d of n."""
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all(r, fib(d))
    return r


def primitive_witness(n: int) -> Optional[int]:
    """Return an explicit primitive prime divisor of F(n) for n >= 3, or None
    if the certificate vanishes (n in {6, 12}, and trivially n in {1, 2})."""
    if n < 3:
        return None
    if is_prime(n):
        return min_prime_factor(fib(n))  # prime-index theorem
    pp = prim_part(n)
    if pp > 1:
        return min_prime_factor(pp)  # composite certificate
    return None


# --------------------------------------------------------------------------- #
# Entry point z(p): least m > 0 with p | F(m)
# --------------------------------------------------------------------------- #
def entry_point(p: int, bound: int = 100000) -> Optional[int]:
    """Smallest m > 0 with p | F(m)."""
    a, b = 0, 1
    for m in range(1, bound + 1):
        a, b = b, a + b
        if a % p == 0:
            return m
    return None


# --------------------------------------------------------------------------- #
# Direct (brute) primitivity check, for cross-validation
# --------------------------------------------------------------------------- #
def is_primitive_for(p: int, n: int) -> bool:
    """True iff p | F(n) and p does not divide F(k) for any 0 < k < n."""
    if fib(n) % p != 0:
        return False
    return all(fib(k) % p != 0 for k in range(1, n))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_factor_table(upto: int = 13) -> None:
    print("=" * 64)
    print("Fibonacci factorizations and the birth of new primes")
    print("=" * 64)
    seen: set[int] = set()
    for n in range(1, upto + 1):
        fn = fib(n)
        facs = factorize(fn) if fn > 1 else {}
        new = sorted(p for p in facs if p not in seen)
        seen |= set(facs)
        fac_str = (
            " * ".join(f"{p}^{e}" if e > 1 else f"{p}" for p, e in sorted(facs.items()))
            if facs else "1"
        )
        new_str = ", ".join(map(str, new)) if new else "(none -- exceptional!)"
        print(f"F({n:>2}) = {fn:>5} = {fac_str:<14}  new prime(s): {new_str}")
    print()


def demo_gcd_identity(pairs: List[Tuple[int, int]]) -> None:
    print("=" * 64)
    print("Strong divisibility:  gcd(F(m), F(n)) = F(gcd(m, n))")
    print("=" * 64)
    for m, n in pairs:
        lhs = gcd(fib(m), fib(n))
        rhs = fib(gcd(m, n))
        ok = "OK" if lhs == rhs else "MISMATCH"
        print(f"gcd(F({m}), F({n})) = {lhs:>4}   F(gcd({m},{n})) = F({gcd(m,n)}) = {rhs:>4}   [{ok}]")
    print()


def demo_prime_index_theorem(primes: List[int]) -> None:
    print("=" * 64)
    print("Prime-index theorem: EVERY prime factor of F(p) is primitive")
    print("=" * 64)
    for p in primes:
        fn = fib(p)
        facs = sorted(factorize(fn))
        checks = [(q, is_primitive_for(q, p)) for q in facs]
        all_prim = all(b for _, b in checks)
        detail = ", ".join(f"{q}:{'prim' if b else 'NOT'}" for q, b in checks)
        print(f"n={p:>2} (prime)  F(n)={fn:<6}  factors {detail}   all primitive: {all_prim}")
    print()


def demo_primitive_part(upto: int = 24) -> None:
    print("=" * 64)
    print("Primitive-part certificate and explicit witnesses, 3 <= n <= %d" % upto)
    print("=" * 64)
    for n in range(3, upto + 1):
        pp = prim_part(n)
        w = primitive_witness(n)
        kind = "prime " if is_prime(n) else "comp. "
        flag = "" if pp > 1 or is_prime(n) else "   <-- EXCEPTIONAL (no primitive divisor)"
        wstr = str(w) if w is not None else "none"
        print(f"n={n:>2} {kind} primPart={pp:<10} witness p={wstr:<6}{flag}")
    print()


def demo_exceptional_set() -> None:
    print("=" * 64)
    print("The exceptional set {1, 2, 6, 12}: certificate vanishes exactly here")
    print("=" * 64)
    for n in [1, 2, 6, 12]:
        fn = fib(n)
        pp = prim_part(n) if n >= 1 else 0
        has = any(is_primitive_for(p, n) for p in (factorize(fn) if fn > 1 else {}))
        print(f"F({n:>2}) = {fn:<4} primPart={pp:<3} has primitive divisor: {has}")
    print("Below: first indices >= 13 all DO have a primitive divisor:")
    for n in range(13, 19):
        print(f"  F({n}) primitive witness = {primitive_witness(n)}")
    print()


def demo_verification_range(lo: int = 13, hi: int = 300) -> None:
    print("=" * 64)
    print(f"Range certificate: for {lo} <= n <= {hi}, n prime OR primPart(n) > 1")
    print("=" * 64)
    failures = [n for n in range(lo, hi + 1) if not (is_prime(n) or prim_part(n) > 1)]
    print(f"checked {hi - lo + 1} indices; counterexamples: {failures if failures else 'NONE'}")
    # cross-check every witness is genuinely primitive
    bad = [n for n in range(lo, hi + 1)
           if (w := primitive_witness(n)) is None or not is_primitive_for(w, n)]
    print(f"witness cross-validation failures: {bad if bad else 'NONE'}")
    print()


def demo_entry_points(primes: List[int]) -> None:
    print("=" * 64)
    print("Entry points z(p) vs p +/- 1  (Conjecture: z(p) | p - (5|p))")
    print("=" * 64)
    for p in primes:
        if p == 5:
            continue
        z = entry_point(p)
        div_pm1 = "p-1" if z is not None and (p - 1) % z == 0 else (
            "p+1" if z is not None and (p + 1) % z == 0 else "NEITHER")
        print(f"p={p:>3}  z(p)={z!s:<4}  divides {div_pm1}")
    print()


def demo_lifting_the_exponent(p: int = 3, k_max: int = 8) -> None:
    print("=" * 64)
    print(f"Lifting the Exponent spot check for p={p}: "
          f"v_p(F(mk)) = v_p(F(m)) + v_p(k)")
    print("=" * 64)
    m = entry_point(p)
    assert m is not None
    vm = padic_val(p, fib(m))
    print(f"entry point z({p}) = m = {m},  v_{p}(F(m)) = {vm}")
    for k in range(1, k_max + 1):
        lhs = padic_val(p, fib(m * k))
        rhs = vm + padic_val(p, k)
        ok = "OK" if lhs == rhs else "MISMATCH"
        print(f"k={k:>2}  v_{p}(F({m*k})) = {lhs}   predicted {rhs}   [{ok}]")
    print()


def main() -> None:
    demo_factor_table(13)
    demo_gcd_identity([(12, 8), (15, 10), (9, 6), (14, 21)])
    demo_prime_index_theorem([3, 5, 7, 11, 13, 17, 19, 23])
    demo_primitive_part(24)
    demo_exceptional_set()
    demo_verification_range(13, 300)
    demo_entry_points([3, 7, 11, 13, 17, 19, 23, 29, 31, 37])
    demo_lifting_the_exponent(3, 8)
    demo_lifting_the_exponent(7, 6)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the package source files."""
from __future__ import annotations
import json
from pathlib import Path

HERE = Path(__file__).parent


def read(name: str) -> str:
    return (HERE / name).read_text(encoding="utf-8")


article = read("ARTICLE.md")
paper_md = read("RESEARCH_PAPER.md")
paper_tex = read("RESEARCH_PAPER.tex")
demo_py = read("demo.py")
lean_proofs = read("lean_proofs.txt")
interactive_html = read("interactive.html")
viz_entry = read("viz_entry_points.py")
viz_pp = read("viz_primitive_part.py")

FUTURE_DIRECTIONS = """# FUTURE DIRECTIONS — Fibonacci Primitive Divisors / Carmichael's Theorem

This cycle delivered a self-contained, `sorry`-free verification of Carmichael's
primitive-divisor theorem on the range `13 <= n <= 10000`, together with:

* `fib_primitive_divisor_prime` — an *unconditional* proof for all prime indices
  `n >= 3` (every prime factor of `F(n)` is primitive);
* the strong-divisibility identity `gcd(F(m), F(n)) = F(gcd(m,n))` underpinning the
  theory;
* sharpness: `F(n)` has no primitive prime divisor for `n in {1, 2, 6, 12}`, so
  `13` is the sharp threshold.

The genuinely open formalization target is the **unbounded composite tail**. The
conjectures below are stated so they can be transcribed almost verbatim into formal
statements and attacked in follow-up cycles.

---

## Conjecture 1 (PRIORITY): Fibonacci Lifting-the-Exponent

For an odd prime `p` whose Fibonacci entry point is `z(p) = m` (i.e. `m` is least
with `p | F(m)`), and any `k >= 1`:

    padicValNat p (Nat.fib (m * k)) = padicValNat p (Nat.fib m) + padicValNat p k.

**Why it matters.** This is the single missing analytic ingredient for the
unbounded tail. It controls exactly how much of `F(n)` is "imprimitive", and
combined with `F(n) >= phi^(n-2)` it forces a primitive factor for large `n`.

**Falsifiable test.** Check numerically for `p in {3,7,11,...}`, `k <= 20`; a single
counterexample refutes it. (None expected — this is classical, but unformalized.)

---

## Conjecture 2: Primitive part dominates the index

Define the Mobius-cyclotomic primitive part `Phi(n) = prod_{d | n} F(d)^mu(n/d)`
(a positive integer). Then for every `n >= 13`:

    Phi(n) > n.

**Why it matters.** `Phi(n) > 1` already implies a primitive prime divisor; the
strict bound `Phi(n) > n` is the clean inequality that removes the `native_decide`
range cap entirely and yields the full theorem for ALL `n >= 13` (prime or
composite) in one stroke.

**Falsifiable test.** Verify the bound first fails exactly inside `{1,2,6,12}`.

---

## Conjecture 3: Entry point divides `p - (5|p)`

For a prime `p != 5`, the Fibonacci entry point `z(p)` satisfies

    z(p) | (p - legendreSym p 5),   i.e. z(p) | p - 1  or  z(p) | p + 1,

according to whether `5` is a quadratic residue mod `p`.

**Why it matters.** This gives an *a priori* upper bound `z(p) <= p + 1`, the key
to proving that an imprimitive prime `p | F(n)` must satisfy `p | n` with
multiplicity one — the combinatorial half of the tail argument.

**Falsifiable test.** Tabulate `z(p)` vs `p +/- 1` for primes `p < 200`.

---

## Conjecture 4: Lucas-number analogue

The Lucas numbers `L(n)` (`L 0 = 2`, `L 1 = 1`, `L(n+2) = L(n+1)+L(n)`) have a
primitive prime divisor for every `n not in {1, 6}`.

**Why it matters.** Lucas and Fibonacci sequences share companion-matrix
eigenvalues; a uniform "Lucas-sequence primitive divisor" lemma would subsume both
and connect to the Bilu-Hanrot-Voutier classification of primitive divisors for all
Lucas and Lehmer sequences.
"""

# --------------------------------------------------------------------------- #
# Algorithms
# --------------------------------------------------------------------------- #
PRIMPART_CODE = '''from math import gcd
from typing import List


def fib(n: int) -> int:
    """F(0)=0, F(1)=1, F(n+2)=F(n+1)+F(n)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def proper_divisors(n: int) -> List[int]:
    """All d with 0 < d < n and d | n."""
    return [d for d in range(1, n) if n % d == 0]


def strip_all(r: int, m: int) -> int:
    """Repeatedly divide out gcd(r, m) until r and m are coprime."""
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def prim_part(n: int) -> int:
    """Primitive part of F(n): start from F(n) and strip every prime shared with
    F(d) for each proper divisor d of n.  Returns a divisor of F(n) coprime to
    every F(d); if it exceeds 1, its prime factors are all primitive for F(n)."""
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all(r, fib(d))
    return r
'''

WITNESS_CODE = '''from math import gcd
from typing import List, Optional


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def min_prime_factor(n: int, trial_bound: int = 5_000_000) -> int:
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n and d <= trial_bound:
        if n % d == 0:
            return d
        d += 2
    return n  # n is prime (or has no small factor)


def proper_divisors(n: int) -> List[int]:
    return [d for d in range(1, n) if n % d == 0]


def strip_all(r: int, m: int) -> int:
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def prim_part(n: int) -> int:
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all(r, fib(d))
    return r


def primitive_witness(n: int) -> Optional[int]:
    """Explicit primitive prime divisor of F(n) for n >= 3, via the two-pillar
    proof: the prime-index theorem for prime n, the primitive-part certificate
    otherwise.  Returns None exactly on the exceptional indices {6, 12}."""
    if n < 3:
        return None
    if is_prime(n):
        return min_prime_factor(fib(n))     # prime-index theorem
    pp = prim_part(n)
    if pp > 1:
        return min_prime_factor(pp)         # composite certificate
    return None
'''

ENTRYPOINT_CODE = '''from typing import Optional


def entry_point(p: int, bound: int = 100000) -> Optional[int]:
    """Fibonacci entry point z(p): least m > 0 with p | F(m).
    Streams F(m) mod-free (full integers) and returns the first hit."""
    a, b = 0, 1
    for m in range(1, bound + 1):
        a, b = b, a + b
        if a % p == 0:
            return m
    return None
'''

STRONGDIV_CODE = '''from math import gcd


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def check_strong_divisibility(m: int, n: int) -> bool:
    """Verify the foundational identity gcd(F(m), F(n)) = F(gcd(m, n))."""
    return gcd(fib(m), fib(n)) == fib(gcd(m, n))
'''

algorithms = [
    {
        "name": "PRIMPART: GCD-Stripping Primitive-Part Certificate",
        "description": (
            "Computes the primitive part of F(n) by removing, from F(n), every "
            "prime it shares with a proper-divisor Fibonacci number F(d). The result "
            "is a divisor of F(n) that is coprime to all such F(d); when it exceeds 1, "
            "the strong-divisibility identity gcd(F(m),F(n))=F(gcd(m,n)) guarantees its "
            "prime factors are primitive for F(n). Complexity: with D(n) proper divisors "
            "and O(n)-bit Fibonacci values, each gcd costs O(n^2/w) word operations "
            "(machine word w); the inner stripping loop iterates only a handful of times, "
            "so PRIMPART is polynomial in n. This is the engine of the verified composite "
            "case and the source of the exceptional set: primPart(6)=primPart(12)=1."
        ),
        "pseudocode": (
            "function PRIMPART(n):\n"
            "    r <- F(n)\n"
            "    for d in proper_divisors(n):          # 0 < d < n and d | n\n"
            "        m <- F(d)\n"
            "        if m > 1:\n"
            "            loop:\n"
            "                g <- gcd(r, m)\n"
            "                if g == 1: break\n"
            "                r <- r / g\n"
            "    return r                              # primPart(n) | F(n), coprime to each F(d)"
        ),
        "code": PRIMPART_CODE,
    },
    {
        "name": "WITNESS: Two-Pillar Primitive Prime Divisor Extraction",
        "description": (
            "Produces an explicit primitive prime divisor of F(n) for n >= 13 by "
            "dispatching on the index type. If n is prime, the unconditional prime-index "
            "theorem says every prime factor of F(n) is primitive, so the least prime "
            "factor of F(n) is returned. If n is composite, the PRIMPART certificate is "
            "computed and its least prime factor returned. The procedure returns None "
            "exactly on the exceptional indices {1, 2, 6, 12}, exhibiting Carmichael's "
            "sharp threshold operationally. Complexity is dominated by PRIMPART plus the "
            "final small-factor extraction."
        ),
        "pseudocode": (
            "function WITNESS(n):                      # n >= 13\n"
            "    if is_prime(n):\n"
            "        return min_prime_factor(F(n))     # prime-index theorem\n"
            "    pp <- PRIMPART(n)\n"
            "    assert pp > 1                         # range certificate guarantees this\n"
            "    return min_prime_factor(pp)           # composite certificate"
        ),
        "code": WITNESS_CODE,
    },
    {
        "name": "ENTRYPOINT: Fibonacci Apparition Rank z(p)",
        "description": (
            "Computes the Fibonacci entry point (rank of apparition) z(p): the least "
            "index m > 0 at which the prime p first divides a Fibonacci number. A prime "
            "p is primitive for F(n) precisely when z(p) = n, making the entry point the "
            "canonical reformulation of primitivity. The function streams the Fibonacci "
            "sequence and returns the first index whose value is divisible by p; it "
            "underpins the Lifting-the-Exponent program (Conjecture 1) and the envelope "
            "bound z(p) <= p + 1 (Conjecture 3)."
        ),
        "pseudocode": (
            "function ENTRYPOINT(p):\n"
            "    a, b <- 0, 1\n"
            "    for m in 1, 2, 3, ...:\n"
            "        a, b <- b, a + b                  # now a = F(m)\n"
            "        if a mod p == 0: return m"
        ),
        "code": ENTRYPOINT_CODE,
    },
    {
        "name": "STRONG-DIVISIBILITY CHECK: gcd(F(m),F(n)) = F(gcd(m,n))",
        "description": (
            "Validates the single algebraic identity on which the entire proof rests: "
            "Fibonacci numbers form a strong divisibility sequence, so the gcd of two "
            "Fibonacci values equals the Fibonacci of the gcd of their indices. From this, "
            "a prime dividing both F(n) and F(k) must divide F(gcd(n,k)) — the lever that "
            "reduces primitivity to a finite check over proper divisors. This routine "
            "confirms the identity for any pair (m, n)."
        ),
        "pseudocode": (
            "function CHECK_STRONG_DIVISIBILITY(m, n):\n"
            "    return gcd(F(m), F(n)) == F(gcd(m, n))"
        ),
        "code": STRONGDIV_CODE,
    },
]

demos = [
    {
        "name": "Birth of New Primes: Factorization Table and the Exceptional Set",
        "description": (
            "Tabulates F(1) through F(13), factoring each and highlighting the prime(s) "
            "making their first-ever appearance in the sequence. Reveals the primitive "
            "prime divisor born at almost every index, and pinpoints the failures at "
            "F(6)=8 and F(12)=144 where every prime is recycled. Also verifies the "
            "strong-divisibility identity on sample pairs and confirms, for prime indices, "
            "that EVERY prime factor of F(p) is primitive."
        ),
        "code": demo_py,
    },
    {
        "name": "Range Certificate and Lifting-the-Exponent Spot Checks",
        "description": (
            "Self-contained verification harness: confirms that for every 13 <= n <= 300, "
            "either n is prime or primPart(n) > 1 (so a primitive divisor exists), and "
            "cross-validates each extracted witness against a brute-force primitivity test. "
            "It then tabulates entry points z(p) against p +/- 1 and performs p-adic "
            "Lifting-the-Exponent spot checks v_p(F(mk)) = v_p(F(m)) + v_p(k) for p = 3, 7."
        ),
        "code": demo_py,
    },
]

visualizations = [
    {
        "name": "Primitive Part of F(n) and the Sharp Threshold n = 13",
        "description": (
            "Bar chart of log10(primPart(n)) for 1 <= n <= 60. Every bar is positive "
            "(certifying a primitive prime divisor) except at the four exceptional indices "
            "n in {1, 2, 6, 12}, where the bar vanishes. A vertical marker at n = 13 makes "
            "Carmichael's sharp threshold visually unmistakable."
        ),
        "code": viz_pp,
    },
    {
        "name": "Fibonacci Entry Points Within the Envelope z(p) <= p + 1",
        "description": (
            "Scatter plot of the entry point z(p) against the prime p for p < 200, bounded "
            "by the dashed lines y = p - 1 and y = p + 1. Points are coloured by whether "
            "z(p) divides p - 1 (5 a quadratic residue mod p) or p + 1 (non-residue), "
            "illustrating Conjecture 3 and the law z(p) | p - (5|p)."
        ),
        "code": viz_entry,
    },
]

interactive_demos = [
    {
        "title": "Fibonacci Primitive Divisor Explorer",
        "description": (
            "An interactive, dependency-free widget (pure client-side BigInt arithmetic). "
            "Drag the index slider to any n from 1 to 40 and watch F(n) get factored, its "
            "primitive part stripped step-by-step across the proper divisors, and an "
            "explicit primitive prime divisor extracted — with a clear red verdict at the "
            "four exceptional indices {1, 2, 6, 12}. A live 'birth log' marks each prime's "
            "first appearance in the sequence, turning Carmichael's theorem into something "
            "you can feel by moving a slider."
        ),
        "html": interactive_html,
    },
]

package = {
    "title": "Carmichael's Fibonacci Primitive Divisor Theorem: A Verified Bounded Proof",
    "domain": "Logic",
    "description": (
        "A machine-verified proof that every Fibonacci number F(n) with 13 <= n <= 10000 "
        "has a primitive prime divisor, built from an unconditional prime-index theorem and "
        "a verified GCD-stripping certificate for composite indices."
    ),
    "authors": ["Aristotle (Harmonic)"],
    "date": "2026-06-15",
    "key_results": [
        "Carmichael's theorem verified for all 13 <= n <= 10000: F(n) has a primitive prime divisor.",
        "Unconditional prime-index theorem: for every prime n >= 3, every prime factor of F(n) is primitive.",
        "A verified GCD 'strip the imprimitive part' algorithm (primPart) whose positivity certifies a primitive divisor.",
        "Sharpness: the exceptional set {1, 2, 6, 12} is exactly where the primitive-part certificate vanishes; 13 is the sharp threshold.",
        "Everything rests on the strong-divisibility identity gcd(F(m), F(n)) = F(gcd(m, n)).",
    ],
    "keywords": [
        "Fibonacci numbers", "primitive prime divisor", "Carmichael's theorem",
        "entry point", "strong divisibility sequence", "lifting the exponent",
        "formal verification", "number theory",
    ],
    "article": "ARTICLE.md",
    "research_paper": "RESEARCH_PAPER.md",
    "research_paper_tex": "RESEARCH_PAPER.tex",
    "demo": "demo.py",
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": visualizations,
    "interactive_demos": interactive_demos,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": demo_py,
        "primitive_part_viz": viz_pp,
        "entry_points_viz": viz_entry,
    },
    "lean_files": ["Catalog/Shared/CarmichaelProof.lean"],
    "article_text": article,
    "research_paper_text": paper_md,
    "research_paper_tex_text": paper_tex,
}

(HERE / "PACKAGE.json").write_text(
    json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8"
)
print("wrote PACKAGE.json")


"""Visualization: Fibonacci entry points z(p) against the envelope p +/- 1.

For each prime p != 5, the entry point z(p) (least m with p | F(m)) divides
p - (5|p), hence z(p) <= p + 1. This plot shows z(p) as a scatter against p,
with the lines y = p-1 and y = p+1 bounding it, and colours indicating whether
z(p) | p-1 (5 is a QR mod p) or z(p) | p+1.

Standalone: requires only matplotlib.
"""

from __future__ import annotations

from typing import List, Optional, Tuple
import matplotlib.pyplot as plt


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def entry_point(p: int, bound: int = 2000) -> Optional[int]:
    a, b = 0, 1
    for m in range(1, bound + 1):
        a, b = b, a + b
        if a % p == 0:
            return m
    return None


def main() -> None:
    primes: List[int] = [p for p in range(2, 200) if is_prime(p) and p != 5]
    ps, zs, colors = [], [], []
    for p in primes:
        z = entry_point(p)
        if z is None:
            continue
        ps.append(p)
        zs.append(z)
        colors.append("#06d6a0" if (p - 1) % z == 0 else "#ef476f")

    fig, ax = plt.subplots(figsize=(9, 6))
    xs = list(range(2, 200))
    ax.plot(xs, [x - 1 for x in xs], "--", color="#888", label="y = p - 1")
    ax.plot(xs, [x + 1 for x in xs], "--", color="#444", label="y = p + 1")
    ax.scatter(ps, zs, c=colors, s=42, edgecolors="k", linewidths=.4, zorder=3)
    ax.scatter([], [], c="#06d6a0", label="z(p) | p - 1  (5 is QR mod p)")
    ax.scatter([], [], c="#ef476f", label="z(p) | p + 1  (5 is non-residue)")
    ax.set_xlabel("prime p")
    ax.set_ylabel("Fibonacci entry point z(p)")
    ax.set_title("Fibonacci entry points stay within the envelope  z(p) <= p + 1")
    ax.legend(loc="upper left")
    ax.grid(True, alpha=.25)
    fig.tight_layout()
    fig.savefig("entry_points.png", dpi=150)
    print("wrote entry_points.png")


if __name__ == "__main__":
    main()


"""Visualization: the primitive part of F(n) and the exceptional set.

We plot log10(primPart(n)) against n for 1 <= n <= 60. Every bar is positive
(i.e. primPart(n) > 1, certifying a primitive prime divisor) EXCEPT at the four
exceptional indices n in {1, 2, 6, 12}, where primPart(n) = 1 (log = 0) and the
bar vanishes. The plot makes the sharp threshold n = 13 visually obvious.

Standalone: requires only matplotlib (and the standard library math.gcd).
"""

from __future__ import annotations

from math import gcd, log10
from typing import List
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def proper_divisors(n: int) -> List[int]:
    return [d for d in range(1, n) if n % d == 0]


def strip_all(r: int, m: int) -> int:
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def prim_part(n: int) -> int:
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all(r, fib(d))
    return r


def main() -> None:
    N = 60
    ns = list(range(1, N + 1))
    vals = [prim_part(n) for n in ns]
    heights = [log10(v) if v > 1 else 0.0 for v in vals]
    exceptional = {1, 2, 6, 12}
    colors = ["#ef476f" if n in exceptional else "#118ab2" for n in ns]

    fig, ax = plt.subplots(figsize=(11, 5.5))
    ax.bar(ns, heights, color=colors, edgecolor="k", linewidth=.3)
    ax.axvline(12.5, color="#ffd166", linestyle="--", linewidth=2,
               label="sharp threshold n = 13")
    ax.set_xlabel("index n")
    ax.set_ylabel("log10(primitive part of F(n))")
    ax.set_title("Primitive part of F(n): positive everywhere except n in {1, 2, 6, 12}")
    ax.bar([], [], color="#ef476f", label="exceptional (primPart = 1)")
    ax.bar([], [], color="#118ab2", label="has primitive divisor")
    ax.legend(loc="upper left")
    ax.grid(True, axis="y", alpha=.25)
    fig.tight_layout()
    fig.savefig("primitive_part.png", dpi=150)
    print("wrote primitive_part.png")


if __name__ == "__main__":
    main()
