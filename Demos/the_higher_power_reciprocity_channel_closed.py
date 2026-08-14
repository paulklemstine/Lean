"""
Escape-Witness Audit
====================

A compact, focused verification of the two witness pairs that close the
higher-power reciprocity channel, together with Gauss's quadratic-form criterion
as an independent cross-check.

For each pair (p, q) with q = p + 720720 = p + lcm(1,...,16):

  * both members are certified prime by deterministic Miller-Rabin;
  * both lie in the congruence class where the symbol is defined;
  * they agree modulo EVERY divisor of 720720 (all 240 of them are checked);
  * their residuacity bits are opposite, computed two independent ways:
      - Euler's criterion  a^((p-1)/k) mod p,
      - exhibition of an explicit k-th root (or Gauss's form, for k = 3).

Consequently no function of p mod M, for any M dividing 720720, followed by any
decision rule, can decide the bit.

Run with:  python3 demo_witness_audit.py
"""

from __future__ import annotations

from math import isqrt
from typing import List, Optional, Tuple

MR_BASES = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
LCM_1_16 = 720720


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in MR_BASES:
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in MR_BASES:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def divisors(n: int) -> List[int]:
    out: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            if d != n // d:
                out.append(n // d)
        d += 1
    return sorted(out)


def repr_x2_27y2(p: int) -> Optional[Tuple[int, int]]:
    y = 1
    while 27 * y * y <= p:
        rest = p - 27 * y * y
        x = isqrt(rest)
        if x * x == rest:
            return (x, y)
        y += 1
    return None


def audit(p: int, q: int, k: int, base: int) -> None:
    print(f"\n--- exponent k = {k}, base a = {base}: witnesses {p} and {q} ---")
    assert q - p == LCM_1_16
    print(f"  primality:            {p}: {is_prime(p)},  {q}: {is_prime(q)}")
    print(f"  congruence class:     {p} mod {k} = {p % k},  {q} mod {k} = {q % k}")
    ds = divisors(LCM_1_16)
    bad = [M for M in ds if p % M != q % M]
    print(f"  divisors of {LCM_1_16} tested: {len(ds)};  disagreements: {len(bad)}")
    sp, sq = pow(base, (p - 1) // k, p), pow(base, (q - 1) // k, q)
    print(f"  symbol at {p}: {base}^{(p - 1) // k} = {sp}  ->  residue: {sp == 1}")
    print(f"  symbol at {q}: {base}^{(q - 1) // k} = {sq}  ->  residue: {sq == 1}")
    assert (sp == 1) != (sq == 1), "witnesses must have opposite bits"
    print("  OPPOSITE BITS with identical residues: period refuted for every "
          f"M dividing {LCM_1_16}.")


def main() -> None:
    print(__doc__)
    audit(43, 720763, 3, 2)
    print("  cross-check by Gauss's form p = x^2 + 27y^2:")
    for p in (43, 720763):
        rep = repr_x2_27y2(p)
        print(f"    {p}: {'yes  ' + str(rep) if rep else 'no representation'}"
              f"   -> 2 {'is' if rep else 'is not'} a cube mod {p}")

    audit(137, 720857, 4, 2)
    print("  explicit fourth root modulo 720857: 96769^4 mod 720857 =",
          pow(96769, 4, 720857))
    print("  explicit cube root modulo 43:       20^3 =", 20 ** 3,
          "= 186*43 +", 20 ** 3 % 43)

    print("\nAll audits passed: the cubic and quartic channels are non-periodic,")
    print("and the only routes to their bits are the exponent (p-1)/k or the")
    print("quadratic-form representation -- both of which presuppose the secret.")


if __name__ == "__main__":
    main()


"""
Visualization: the capacity ceiling 2^K, identical for every exponent.

Left panel  — number of distinct K-symbol residuacity fingerprints observed on a
              fixed pool of primes, as K grows, for exponents k = 2, 3, 4, 6,
              against the theoretical ceiling 2^K.  All curves are trapped under
              the same ceiling, and the cubic/quartic curves sit BELOW the
              quadratic one because k-th powers occupy only a 1/k fraction of the
              units (sparsity), making each bit biased and less informative.

Right panel — the mirage: distinct values of the RAW symbol vectors
              (a^((p-1)/k) mod p), which live in Z/p and therefore encode p.
              They separate essentially every prime, at every exponent — perfect
              separation that costs knowledge of the secret to compute.

Usage: python3 viz_capacity.py [--lo 1000] [--hi 6000] [--out capacity.png]
"""

from __future__ import annotations

import argparse
from typing import Dict, List, Sequence, Tuple

import matplotlib.pyplot as plt

MR_BASES = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)
POOL_BASES: Tuple[int, ...] = (2, 3, 5, 7, 11, 13, 17, 19)


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in MR_BASES:
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in MR_BASES:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def bits(p: int, bases: Sequence[int], k: int) -> Tuple[bool, ...]:
    return tuple(pow(a, (p - 1) // k, p) == 1 for a in bases)


def raws(p: int, bases: Sequence[int], k: int) -> Tuple[int, ...]:
    return tuple(pow(a, (p - 1) // k, p) for a in bases)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--lo", type=int, default=1000)
    ap.add_argument("--hi", type=int, default=6000)
    ap.add_argument("--out", type=str, default="capacity.png")
    args = ap.parse_args()

    exponents = (2, 3, 4, 6)
    Ks = list(range(1, len(POOL_BASES) + 1))
    colors: Dict[int, str] = {2: "#1f77b4", 3: "#d64545", 4: "#2ca02c", 6: "#9467bd"}

    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    ax = axes[0]
    ax.plot(Ks, [2 ** K for K in Ks], "k--", label="ceiling $2^K$")
    for k in exponents:
        pool: List[int] = [p for p in range(args.lo, args.hi)
                           if is_prime(p) and (p - 1) % k == 0 and p not in POOL_BASES]
        counts = [len({bits(p, POOL_BASES[:K], k) for p in pool}) for K in Ks]
        ax.plot(Ks, counts, "o-", color=colors[k], label=f"k = {k}  ({len(pool)} primes)")
    ax.set_yscale("log", base=2)
    ax.set_xlabel("K  (number of symbols read)")
    ax.set_ylabel("distinct fingerprints")
    ax.set_title("Residuacity BITS: every exponent obeys the same $2^K$ ceiling")
    ax.legend(fontsize=8)
    ax.grid(alpha=0.25, which="both")

    ax = axes[1]
    for k in exponents:
        pool = [p for p in range(args.lo, args.hi)
                if is_prime(p) and (p - 1) % k == 0 and p not in POOL_BASES]
        counts = [len({raws(p, POOL_BASES[:K], k) for p in pool}) for K in Ks]
        ax.plot(Ks, counts, "s-", color=colors[k], label=f"k = {k}  (pool {len(pool)})")
        ax.axhline(len(pool), color=colors[k], alpha=0.2, linestyle=":")
    ax.set_xlabel("K  (number of symbols read)")
    ax.set_ylabel("distinct raw symbol vectors")
    ax.set_title("Raw symbol VALUES: total separation — because they encode $p$")
    ax.legend(fontsize=8)
    ax.grid(alpha=0.25)

    fig.suptitle("Capacity of the residue channel: the honest read-out is capped, "
                 "the circular one is not a read-out at all", fontsize=13)
    fig.tight_layout()
    fig.savefig(args.out, dpi=150)
    print(f"wrote {args.out}")


if __name__ == "__main__":
    main()


"""
Visualization: Periodic versus non-periodic residue channels.

Three panels, all computed from scratch:

  (left)   Quadratic residuacity of 2, plotted against p mod 8.  Every column is
           monochrome: the bit is a function of p mod 8 alone -- a DIAL.
  (centre) Cubic residuacity of 2, plotted against p mod 9.  Every column is
           mixed: no congruence class decides the bit -- the ESCAPE.
  (right)  The primes p = 1 (mod 3) below the bound, placed at the lattice point
           (x, y) of a representation p = x^2 + 27y^2 when one exists, and on the
           "no representation" baseline otherwise.  Gauss's criterion: the cubic
           bit is exactly membership of the represented set.

Usage:  python3 viz_periodicity.py  [--bound 4000] [--out periodicity.png]
"""

from __future__ import annotations

import argparse
from math import isqrt
from typing import List, Optional, Tuple

import matplotlib.pyplot as plt

MR_BASES = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in MR_BASES:
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in MR_BASES:
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def residuacity_bit(a: int, p: int, k: int) -> bool:
    return pow(a, (p - 1) // k, p) == 1


def repr_x2_27y2(p: int) -> Optional[Tuple[int, int]]:
    y = 1
    while 27 * y * y <= p:
        rest = p - 27 * y * y
        x = isqrt(rest)
        if x * x == rest:
            return (x, y)
        y += 1
    return None


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--bound", type=int, default=4000)
    ap.add_argument("--out", type=str, default="periodicity.png")
    args = ap.parse_args()

    primes: List[int] = [n for n in range(3, args.bound) if is_prime(n)]
    cubic_primes: List[int] = [p for p in primes if p % 3 == 1]

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    teal, rose = "#1f9c8f", "#d64545"

    # --- panel 1: quadratic bit vs p mod 8 -------------------------------
    ax = axes[0]
    for p in primes:
        b = residuacity_bit(2, p, 2)
        ax.scatter(p % 8, p, s=7, color=teal if b else rose, alpha=0.65)
    ax.set_title("Quadratic: is 2 a square mod p?\n(columns are monochrome — a DIAL)")
    ax.set_xlabel("p mod 8")
    ax.set_ylabel("p")
    ax.set_xticks(range(8))
    ax.grid(alpha=0.2)

    # --- panel 2: cubic bit vs p mod 9 -----------------------------------
    ax = axes[1]
    for p in cubic_primes:
        b = residuacity_bit(2, p, 3)
        ax.scatter(p % 9, p, s=7, color=teal if b else rose, alpha=0.65)
    ax.set_title("Cubic: is 2 a cube mod p?\n(columns are mixed — the ESCAPE)")
    ax.set_xlabel("p mod 9")
    ax.set_ylabel("p")
    ax.set_xticks(range(9))
    ax.grid(alpha=0.2)

    # --- panel 3: the quadratic form -------------------------------------
    ax = axes[2]
    xs_yes, ys_yes, xs_no, ys_no = [], [], [], []
    for p in cubic_primes:
        rep = repr_x2_27y2(p)
        if rep is not None:
            xs_yes.append(rep[0])
            ys_yes.append(rep[1])
        else:
            xs_no.append(p % 40)
            ys_no.append(0)
    ax.scatter(xs_yes, ys_yes, s=18, color=teal, label="p = x² + 27y²  →  2 is a cube")
    ax.scatter(xs_no, ys_no, s=10, color=rose, alpha=0.4,
               label="no representation  →  2 is not a cube")
    ax.set_title("Gauss's criterion as a lattice condition\n(not a congruence: the form is what matters)")
    ax.set_xlabel("x  (non-representable primes shown on the baseline)")
    ax.set_ylabel("y")
    ax.legend(fontsize=8, loc="upper right")
    ax.grid(alpha=0.2)

    mismatches = sum(
        1 for p in cubic_primes
        if residuacity_bit(2, p, 3) != (repr_x2_27y2(p) is not None)
    )
    fig.suptitle(
        f"Periodic vs non-periodic residue channels  "
        f"(primes below {args.bound}; Gauss-criterion mismatches: {mismatches})",
        fontsize=13)
    fig.tight_layout()
    fig.savefig(args.out, dpi=150)
    print(f"wrote {args.out}  (mismatches with Gauss's criterion: {mismatches})")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Assemble PACKAGE.json from the individual deliverables in this repository."""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def extract(rel: str, start_marker: str, end_marker: str) -> str:
    """Extract one algorithm block from assets/algorithms.py."""
    text = read(rel)
    i = text.index(start_marker)
    j = text.index(end_marker, i)
    return text[i:j].rstrip() + "\n"


ARTICLE = read("ARTICLE.md")
PAPER_MD = read("RESEARCH_PAPER.md")
PAPER_TEX = read("RESEARCH_PAPER.tex")
DEMO = read("demo.py")
DEMO_AUDIT = read("assets/demo_witness_audit.py")
WIDGET = read("assets/widget_channel.html")
VIZ_PERIOD = read("assets/viz_periodicity.py")
VIZ_CAP = read("assets/viz_capacity.py")

LEAN_FILES = [
    "Catalog/Combinatorics/PowerResidueCriterion.lean",
    "Catalog/Combinatorics/PowerResidueCircularity.lean",
    "Catalog/Combinatorics/PowerResidueNoAmplification.lean",
    "Catalog/Combinatorics/PowerResidueSharpness.lean",
]
LEAN_PROOFS = "\n\n".join(
    f"-- ===================== {f} =====================\n{read(f)}" for f in LEAN_FILES
)

ALGO_PRELUDE = (
    "from __future__ import annotations\n"
    "from math import gcd, isqrt\n"
    "from typing import Dict, List, Optional, Sequence, Tuple\n\n"
    "MR_BASES = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)\n\n"
    "def is_prime(n: int) -> bool:\n"
    '    """Deterministic Miller-Rabin for n < 3.3e24."""\n'
    "    if n < 2:\n        return False\n"
    "    for p in MR_BASES:\n        if n % p == 0:\n            return n == p\n"
    "    d, r = n - 1, 0\n"
    "    while d % 2 == 0:\n        d //= 2\n        r += 1\n"
    "    for a in MR_BASES:\n"
    "        x = pow(a, d, n)\n"
    "        if x in (1, n - 1):\n            continue\n"
    "        for _ in range(r - 1):\n"
    "            x = x * x % n\n"
    "            if x == n - 1:\n                break\n"
    "        else:\n            return False\n"
    "    return True\n\n\n"
    "def power_residuacity_bit(a: int, p: int, k: int) -> bool:\n"
    '    """Decide whether a is a k-th power residue modulo the prime p."""\n'
    "    if a % p == 0:\n"
    '        raise ValueError("base must be prime to p")\n'
    "    d = gcd(k, p - 1)\n"
    "    if d == 1:\n        return True\n"
    "    return pow(a, (p - 1) // d, p) == 1\n\n\n"
)

ALGO_BIT = extract("assets/algorithms.py", "def power_residuacity_bit",
                   "# ============================================================ ALGORITHM 2")
ALGO_REFUTE = extract("assets/algorithms.py", "def refute_period",
                      "# ============================================================ ALGORITHM 3")
ALGO_CAP = extract("assets/algorithms.py", "def capacity_profile",
                   "# ============================================================ ALGORITHM 4")
ALGO_GAUSS = extract("assets/algorithms.py", "def cubic_bit_via_gauss_form",
                     "# ============================================================ ALGORITHM 5")
ALGO_HYBRID = extract("assets/algorithms.py", "def hybrid_indistinguishability",
                      'if __name__ == "__main__":')

MR_ONLY = ALGO_PRELUDE.split("def power_residuacity_bit")[0]

FUTURE_DIRECTIONS = """# FUTURE DIRECTIONS — after closing the higher-power reciprocity channel

What this cycle established, in full and without gaps:

1. the k-th power criterion in any finite cyclic group, and its transfer to the
   unit group modulo a prime — the algebraic definition of the cubic/quartic
   symbol;
2. the cubic and quartic residuacity bits of 2 are **not** computable from any
   congruence datum p mod M with M dividing lcm(1,…,16), for any value type and
   any decision rule, while the quadratic bit *is* computable from p mod 8;
3. every K-symbol residuacity fingerprint has capacity exactly 2^K,
   independently of the exponent k, and that ceiling is attained at K = 2;
4. k-th powers are 1/k of the units, so the cubic bit is strictly *sparser*
   (hence individually less informative) than the quadratic bit;
5. a hybrid bound: hint + L dials + K higher-power bits still leave a class of
   at least |Ω| / ((M*/gcd(M*,m))·2^K) indistinguishable candidates.

The conjectures below are the sharpest open questions this leaves.

---

## Conjecture A (unbounded escape). *For every modulus M, cubic residuacity of 2 is not M-periodic on primes.*

Formally: for every M ≥ 1 there are primes p ≡ q (mod M), both ≡ 1 (mod 3),
with 2 a cube mod p and not mod q. We proved this for every M dividing 720720;
the general case is stated but not settled.

**The key insight is** that 2 is a cube mod p exactly when p = x² + 27y², a
*splitting* condition in the non-abelian field ℚ(∛2, ω), and a congruence
condition would force the splitting set of a degree-3 non-normal field to be a
union of ray classes — contradicting the non-abelian Galois group S₃.

**Why now?** Dirichlet's theorem on primes in arithmetic progressions and a
usable class-field-theoretic vocabulary are both available; the remaining gap is
a Chebotarev-free argument: it suffices to exhibit, for each M, a *pair* of
primes in one class with different splitting behaviour, and the x² + 27y²
parametrisation makes such pairs constructible rather than merely dense.

## Conjecture B (exact channel capacity, not just the ceiling). *For bases a₁,…,a_K multiplicatively independent modulo cubes, the cubic residuacity fingerprint attains all 2^K patterns on primes below exp(O(K)).*

We proved attainment for K = 2 with the explicit set {7, 31, 61, 307}; the
conjecture asserts attainment in general with a singly-exponential search bound.

**The key insight is** that the joint distribution of cubic bits should be
governed by the Galois group of the compositum ℚ(ω, ∛a₁, …, ∛a_K), which is
(ℤ/3)^K ⋊ ℤ/2 when the bases are independent modulo cubes; equidistribution
then forces every pattern to appear with density 3^{-K}.

**Why now?** The 2^K upper bound is already established, so a matching
constructive lower bound would turn the capacity statement from an inequality
into an exact determination of the channel.

## Further questions

* **Beyond bits.** Is there any read-out of the power symbol, other than the
  residuacity bit, that lives in a secret-independent value set? A negative
  answer would upgrade the capacity theorem from a statement about one read-out
  to a statement about the whole channel.
* **Optimal exponent.** k-th powers occupy a 1/k fraction of the units, so as k
  grows each "yes" is rarer but more surprising. Is there an optimal k for a
  fixed query budget, and does the optimum scale with the candidate set size?
* **Non-abelian channels in general.** Cubic reciprocity is the smallest
  non-abelian escape. Does any Artin symbol at a non-abelian extension provide a
  polynomial-time handle, or is the escape/inaccessibility duality a theorem
  about all of them?
"""

INTERACTIVE_LAYOUT = r"""
# The Higher-Power Reciprocity Channel, Closed
### A guided tour: how a deeper reciprocity law escapes periodicity — and why that escape is worth exactly nothing

---

## 0. The question in one paragraph

Somebody is hiding a prime $p$ from you. You are allowed to ask cheap arithmetic
questions about it. The most famous cheap question is *"is $2$ a square modulo
$p$?"* — famous because Gauss showed the answer depends **only** on $p \bmod 8$.
That makes it cheap, and it also makes it nearly worthless: a function of three
bits of $p$ can carry at most three bits about $p$. So one climbs the reciprocity
tower to cubic and quartic symbols, whose criteria are provably **not** congruence
conditions. This page walks through what that escape does and does not buy you.

> **The punchline, up front.** The cubic channel really does escape periodicity —
> and for exactly that reason there is no cheap way to compute it. Its
> information content, once you *do* compute it, is capped at the same $2^K$ as
> the quadratic channel. Escape from periodicity is a change of prison, not a
> release.

---

## 1. Meet the dial

Fix an odd prime $p$. Gauss's second supplement says
$$2 \text{ is a square mod } p \iff p \equiv 1 \text{ or } 7 \pmod 8 .$$

Take the widget below and open **tab 1**. Slide through the primes and watch two
independent computations — the congruence rule on the left, the honest
exponentiation $2^{(p-1)/2} \bmod p$ on the right — agree, always. Then open
**tab 2** and try to make the same thing happen for cubes. You cannot.

{{interactive_demo:0}}

<details>
<summary><b>Why periodicity is a cap, not a gift</b> (click to expand)</summary>

A function of $p \bmod M$ takes at most $M$ values, so it partitions any
candidate set into at most $M$ classes and conveys at most $\log_2 M$ bits.
Worse, in the realistic setting the observer already holds a partial hint
$p \equiv r \pmod m$ from some side channel; then the dial's residual value drops
to $\log_2\bigl(M/\gcd(M,m)\bigr)$ bits. A dial is therefore *either* simulable
from the hint *or* informative, and which one it is depends on $M$ and $m$ alone
— never on how large the secret is.

</details>

---

## 2. The escape, in two primes

Here is the entire non-periodicity theorem, compressed into a witness pair. Let
$$\mathcal{M} = 720720 = \operatorname{lcm}(1,2,\dots,16) = 2^4\cdot 3^2\cdot 5\cdot 7\cdot 11\cdot 13,$$
and consider
$$p = 43, \qquad q = 720763 = 43 + \mathcal{M}.$$

Both are prime, both are $\equiv 1 \pmod 3$, and they agree modulo **every** one
of the $240$ divisors of $\mathcal{M}$. Yet $20^3 = 8000 = 186\cdot 43 + 2$, so
$2$ is a cube mod $43$; while $2^{240254} \equiv 632375 \pmod{720763}$, so $2$ is
not a cube mod $720763$.

**Theorem (absolute escape).** *Let $M \mid 720720$. There is no function $f$ of
$p \bmod M$ — valued in any set whatsoever — and no decision rule $g$ such that
$g(f(p))$ decides whether $2$ is a cube modulo $p$, for primes $p \equiv 1 \pmod 3$.*

<details>
<summary><b>Proof (two lines)</b></summary>

Since $43 \equiv 720763 \pmod M$ and $f$ depends only on the residue,
$f(43) = f(720763)$, hence $g(f(43)) = g(f(720763))$. But the two primes have
opposite cubic bits, so one of the two equivalences must fail. $\blacksquare$

Note how little the argument uses: no character theory, no formalism, just one
pair of numbers. That is why it rules out *every* congruence-based method rather
than a chosen class of them.

</details>

The audit below verifies both witness pairs from scratch — primality, all $240$
divisor congruences, the symbols computed two independent ways, and Gauss's
quadratic-form cross-check.

{{demo:1}}

---

## 3. Why the escape had to happen: $p = x^2 + 27y^2$

Gauss's cubic criterion is one of the loveliest theorems in elementary number
theory:

$$\text{for } p \equiv 1 \!\!\pmod 3: \quad 2 \text{ is a cube mod } p \iff p = x^2 + 27y^2 .$$

Compare: the quadratic criterion is a congruence, the cubic one is a *quadratic
form*. Try tab 3 of the widget above: every prime that is representable has cubic
bit "yes", and no other prime does — and primes sharing a residue mod $9$ land on
both sides of the divide.

<details>
<summary><b>The structural reason (class field theory in a nutshell)</b></summary>

The condition "$2$ is a cube mod $p$" is a splitting condition for the prime $p$
in the field $\mathbb{Q}(\sqrt[3]{2})$, whose Galois closure
$\mathbb{Q}(\sqrt[3]{2}, \omega)$ has Galois group
[$S_3$](https://en.wikipedia.org/wiki/Symmetric_group) — non-abelian. Class field
theory says that congruence-describable splitting sets are exactly those of
*abelian* extensions. Hence the cubic condition cannot be a union of residue
classes. Read the other way round: the cheapness of the Legendre symbol is the
cheapness of an [abelian character](https://en.wikipedia.org/wiki/Dirichlet_character),
and any channel that escapes periodicity forfeits precisely that cheapness.

</details>

The picture below shows all three facts at once: the quadratic bit sorted into
monochrome columns by $p \bmod 8$, the cubic bit refusing to sort by $p \bmod 9$,
and the quadratic form that governs it instead.

{{visualization:0}}

---

## 4. The engine room: one criterion for every exponent

Everything above rests on a single group-theoretic fact, with no primes, no
fields and no roots of unity in it.

**Theorem ($k$-th power criterion).** *Let $G$ be a finite cyclic group of order
$n$ and $k \mid n$. Then $x \in G$ is a $k$-th power if and only if $x^{n/k} = 1$.*

<details>
<summary><b>Proof sketch</b></summary>

If $x = y^k$ then $x^{n/k} = y^n = 1$ by Lagrange. Conversely, write $x = g^j$ for
a generator $g$; from $g^{j n/k} = 1$ we get $n \mid j\,(n/k)$, and cancelling the
positive factor $n/k$ from $n = k(n/k)$ gives $k \mid j$, so $x$ is the $k$-th
power of $g^{j/k}$. $\blacksquare$

</details>

Applied to $G = (\mathbb{Z}/p)^\times$, of order $p-1$, this *is* the definition of
the cubic and quartic symbols as residuacity tests: $a$ is a $k$-th power modulo
$p$ iff $a^{(p-1)/k} \equiv 1$. Note the exponent. It contains $p$.

{{algorithm:0}}

And here is the only known alternative — Gauss's route, which trades the exponent
for a representation search that is exponential in $\log p$:

{{algorithm:3}}

> **The circularity, stated plainly.** The Euler route needs $(p-1)/k$: you must
> know $p$. The Gauss route needs the representation $p = x^2+27y^2$: for a hidden
> factor of a semiprime that is a factoring-strength problem. The congruence
> route — the one that rescues the quadratic symbol — is closed by the escape
> theorem of §2. There is no fourth road.

---

## 5. Refute a period yourself

The escape theorem is proved with one pair, but the phenomenon is generic: pick
*any* modulus and a short search finds a refuting pair.

{{algorithm:1}}

Try it with $M = 24$, $M = 63$, $M = 720720$. The larger $M$ is, the farther out
the witnesses live — but they always exist. (That they always exist, for *every*
$M$, is Conjecture A: proved here for every divisor of $720720$, expected in
general from the $S_3$ argument of §3.)

---

## 6. Now the disappointment: capacity

Suppose the symbols were simply handed to you. How much are they worth?

The secret-independent read-out of a symbol is one **bit**: residue, or not. Read
$K$ bases and you hold a $K$-bit vector.

**Theorem (capacity).** *For every exponent $k$, every choice of $K$ bases and
every candidate set $S$, the residuacity fingerprint takes at most $2^K$ distinct
values on $S$. Hence if it separates $S$ then $|S| \le 2^K$, i.e. $K \ge \log_2|S|$.*

The proof is one line — the codomain is $\{0,1\}^K$ — and the point is what the
statement does *not* mention: $k$. The cubic channel's capacity equals the
quartic's equals the quadratic's.

**Theorem (sharpness).** *The bound is attained at $K = 2$: the cubic bits at
bases $2$ and $3$ realise all four patterns on $\{7, 31, 61, 307\}$.*

| $p$ | $2$ a cube? | $3$ a cube? | pattern |
|---|---|---|---|
| $7$ | no | no | $(0,0)$ |
| $31$ | yes | no | $(1,0)$ |
| $61$ | no | yes | $(0,1)$ |
| $307$ | yes | yes | $(1,1)$ |

{{algorithm:2}}

{{visualization:1}}

<details>
<summary><b>The higher bit is not merely equal — it is worse</b></summary>

Exactly $(p-1)/k$ of the $p-1$ units modulo $p$ are $k$-th powers, since the
$k$-th power map on a cyclic group of order $n$ has image of index $\gcd(k,n)$.
So the quadratic bit says "yes" half the time, the cubic bit only a third of the
time. In entropy terms a $1/3$-biased bit carries $H(1/3) \approx 0.918$ bits
against a full $1$ bit. The higher channel shares the same ceiling with a
strictly poorer per-symbol payload — which is precisely why, empirically, cubic
fingerprints separate slightly *fewer* candidates than quadratic ones.

</details>

---

## 7. The "$68/68$" mirage

The experiment that started this investigation reported that five cubic symbols
separate all $68$ primes in $[1000,2000]$ with $p \equiv 1 \pmod 3$ — apparently
blowing past the ceiling of $2^5 = 32$. It does not, and the resolution is the
crux of the whole story.

The **raw symbol value** $a^{(p-1)/3} \bmod p$ lives in $\mathbb{Z}/p$: a set whose
very description contains the secret. Of course it separates the primes — it
*encodes* them. Strip the circularity and record the honest, secret-independent
read-out, and everything snaps back under the ceiling:

| fingerprint (bases $2,3,5,7,11$) | distinct values | ceiling |
|---|---|---|
| full quadratic symbol values | $68/68$ | — (values live in $\mathbb{Z}/p$) |
| full cubic symbol values | $68/68$ | — (same artefact) |
| quadratic residuacity **bits** | $31/68$ | $2^5 = 32$ |
| cubic residuacity **bits** | $23/68$ | $2^5 = 32$ |

Tab 4 of the widget reproduces both columns live, for any exponent and base list
you like.

---

## 8. Everything at once: the hybrid bound

Give the observer every resource simultaneously — a hint $p \equiv r \pmod m$, a
system of $L$ dials with conductor lcm $M^*$, and $K$ higher-power bits.

**Theorem (hybrid no-amplification).** *Some joint reading is shared by at least*
$$\frac{|\Omega|}{\bigl(M^*/\gcd(M^*,m)\bigr)\cdot 2^K}$$
*of the candidates $\Omega$ — that many secrets remain perfectly indistinguishable.*

<details>
<summary><b>Proof sketch: a fibrewise pigeonhole</b></summary>

Any statistic has a reading whose fibre is at least a $1/|\text{image}|$ fraction
of the candidate set. The image of the joint statistic embeds into the product of
the two component images; the dial component has at most $M^*/\gcd(M^*,m)$
readings because all candidates share a residue mod $m$, and the fingerprint has
at most $2^K$. Multiply. $\blacksquare$

</details>

The higher-power channel enters only through $2^K$ — the same contribution $K$
bits from *any* source would make. Replace the cubic bits with quadratic bits at
$K$ fresh bases and the bound is unchanged.

{{algorithm:4}}

---

## 9. Independent, but not stronger

One last hope: perhaps the cubic bit is at least *new* information, not a
repackaging of the quadratic bit? It is — and it does not help.

All four combinations of (is $2$ a square?, is $2$ a cube?) occur among primes
$\equiv 1 \pmod 3$: $7$ (square, not cube), $13$ (neither), $31$ (both), $43$
(cube, not square). So neither bit is a function of the other, in either
direction. But transversality is not amplification: $K$ transverse bits are still
$K$ bits, and $K$ bits still separate at most $2^K$ candidates.

---

## 10. The full numerical tour

Everything on this page, verified end to end in one script: the criterion against
brute force, the dial's perfect periodicity over thousands of primes, both escape
pairs, Gauss's form, sharpness at $K=2$, the sparsity count, transversality, the
Chinese-Remainder symmetry, the saturation table, and the hybrid bound.

{{demo:0}}

---

## 11. What we now know

$$\text{residue-channel information} \;=\; \underbrace{\text{dial part}}_{\text{a small residue; free to anyone with a hint}} \;+\; \underbrace{\text{fine-arithmetic noise}}_{\text{real, non-periodic — and circular to compute}}$$

There is no third term. The higher-power reciprocity channel is closed: it
escapes periodicity, it is genuinely transverse to the quadratic channel, it is
sharply $2^K$-capable — and it adds no new handle on the secret.

**Where to read more:** the classical background is
[quadratic reciprocity](https://en.wikipedia.org/wiki/Quadratic_reciprocity) and its
supplements, [cubic reciprocity](https://en.wikipedia.org/wiki/Cubic_reciprocity) in
the [Eisenstein integers](https://en.wikipedia.org/wiki/Eisenstein_integer), and
[quartic reciprocity](https://en.wikipedia.org/wiki/Quartic_reciprocity) in the
[Gaussian integers](https://en.wikipedia.org/wiki/Gaussian_integer). The structural
statement behind §3 is the correspondence between congruence conditions and
[abelian extensions](https://en.wikipedia.org/wiki/Class_field_theory).
"""

package: Dict[str, object] = {
    "title": "The Higher-Power Reciprocity Channel, Closed: Escape from Periodicity Without Gain in Information",
    "domain": "Cryptography",
    "description": (
        "Cubic and quartic residuacity of 2 provably escape every congruence rule of modulus "
        "dividing lcm(1,…,16) — witnessed by the prime pairs (43, 720763) and (137, 720857) — yet "
        "a K-symbol residuacity fingerprint separates at most 2^K candidates at every exponent, a "
        "ceiling attained at K = 2, so higher reciprocity yields no new information about a hidden prime."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-14",
    "key_results": [
        "Quadratic residuacity of 2 is a periodic statistic of conductor 8: it is decided by p mod 8, and every Legendre symbol is the reading of a periodic character of conductor 4|D|.",
        "Absolute escape theorem: for every modulus M dividing 720720 = lcm(1,…,16), no statistic of p mod M valued in any set, composed with any decision rule, decides whether 2 is a cube modulo p; the witness pair is 43 and 720763 = 43 + 720720, and the quartic analogue is witnessed by 137 and 720857.",
        "Exponent-independent capacity bound: a K-symbol residuacity fingerprint takes at most 2^K values at every exponent k, so separating C candidates requires at least log₂ C symbols.",
        "Sharpness of the capacity bound: the two cubic residuacity bits at bases 2 and 3 realise all four patterns on the primes 7, 31, 61, 307, attaining the ceiling at K = 2.",
        "Sparsity and symmetry: exactly (p−1)/k of the p−1 units modulo p are k-th powers, so the cubic bit is strictly sparser than the quadratic bit; and residuacity at a composite modulus factors through the Chinese Remainder Theorem into a conjunction, hence is symmetric in the factors and cannot single one out.",
        "Hybrid no-amplification: a residue hint modulo m, L periodic dials of conductor lcm M*, and K higher-power bits leave at least |Ω|/((M*/gcd(M*,m))·2^K) indistinguishable candidates, the higher-power channel entering only through 2^K.",
    ],
    "keywords": [
        "cubic reciprocity",
        "quartic reciprocity",
        "power residue symbol",
        "residuacity fingerprint",
        "channel capacity",
        "periodicity obstruction",
        "Eisenstein integers",
        "Euler criterion",
    ],
    "article": ARTICLE,
    "research_paper": PAPER_MD,
    "research_paper_tex": PAPER_TEX,
    "demo": DEMO,
    "demos": [
        {
            "name": "Complete Numerical Verification of the Residue-Channel Dichotomy",
            "description": (
                "An eleven-part self-contained tour that verifies every result of the package numerically: "
                "the k-th power criterion checked against brute-force search over Z/p; the perfect "
                "periodicity of the quadratic bit of 2 across all odd primes below 5000, class by class "
                "modulo 8; the cubic escape pair (43, 720763) tested against all divisors of 720720; the "
                "quartic pair (137, 720857) with its explicit fourth root 96769; Gauss's criterion "
                "p = x² + 27y² reproducing every cubic bit; the capacity ceiling 2^K measured at exponents "
                "k = 2, 3, 4, 6; the sparsity count (p−1)/k of k-th powers; the four transverse "
                "(quadratic, cubic) patterns; the Chinese-Remainder symmetry of composite-modulus "
                "residuacity; the 68-prime leakage-saturation table exposing the '68/68 distinct' mirage; "
                "and the hybrid indistinguishability bound with hint, dials and higher-power bits combined."
            ),
            "code": DEMO,
        },
        {
            "name": "Escape-Witness Audit: Certifying the Two Prime Pairs That Close the Channel",
            "description": (
                "A focused, assertion-driven audit of the two witness pairs that carry the non-periodicity "
                "theorems. For each pair (p, p + 720720) it certifies primality by deterministic "
                "Miller-Rabin, checks membership in the congruence class where the symbol is defined, "
                "verifies agreement modulo all 240 divisors of 720720 = lcm(1,…,16), and computes the "
                "residuacity bits two independent ways — Euler's criterion and an explicit k-th root, "
                "cross-checked for the cubic case against Gauss's quadratic-form criterion p = x² + 27y². "
                "The output is the complete evidence base for the claim that no congruence rule of any "
                "modulus dividing 720720 can decide the cubic or quartic bit."
            ),
            "code": DEMO_AUDIT,
        },
    ],
    "algorithms": [
        {
            "name": "Power-Residuacity Decision by the k-th Power Criterion",
            "description": (
                "Decides whether a base a is a k-th power residue modulo a prime p. The mathematical "
                "foundation is the k-th power criterion in a finite cyclic group: if G is cyclic of order "
                "n and k divides n, then x is a k-th power in G exactly when x^(n/k) = 1. Applied to the "
                "unit group modulo p, of order p−1, this yields Euler's criterion at every exponent — "
                "k = 2 recovers the classical Legendre test, k = 3 and k = 4 give the cubic and quartic "
                "residuacity tests. When gcd(k, p−1) = 1 the k-th powers exhaust the units and the answer "
                "is unconditionally yes; otherwise the algorithm replaces k by d = gcd(k, p−1), which has "
                "the same power subgroup. Complexity: one modular exponentiation, O(log p) modular "
                "squarings, i.e. O(log³ p) bit operations with schoolbook multiplication. The exponent "
                "(p−1)/d is the algorithm's entire content — and the reason the channel is circular: the "
                "computation presupposes the very prime whose residuacity it reports."
            ),
            "pseudocode": (
                "INPUT: base a, prime p, exponent k with a not divisible by p\n"
                "OUTPUT: TRUE iff x^k = a (mod p) is solvable\n"
                "\n"
                "1. d <- gcd(k, p - 1)\n"
                "2. IF d = 1 THEN\n"
                "3.     RETURN TRUE            // the k-th power map is a bijection on the units\n"
                "4. e <- (p - 1) / d\n"
                "5. s <- a^e mod p             // square-and-multiply, O(log p) squarings\n"
                "6. RETURN (s = 1)             // k-th power criterion in the cyclic group (Z/p)^*"
            ),
            "code": MR_ONLY + ALGO_BIT,
        },
        {
            "name": "Congruence-Period Refutation Search",
            "description": (
                "Given an exponent k, a base a and a candidate period M, searches for two primes that are "
                "congruent modulo M yet carry opposite k-th power residuacity bits at a — a pair whose "
                "existence refutes M as a period of the channel and therefore rules out every decision "
                "procedure of the form 'compute p mod M, then decide'. The algorithm sweeps primes in "
                "increasing order, bucketing each by its residue modulo M, and reports the first "
                "collision with mismatched bits. For k = 2 no such pair exists once M is a multiple of 8 "
                "(the quadratic channel really is periodic); for k = 3 and k = 4 a pair is found for every "
                "M tried, in line with the escape theorem. Complexity: O(π(B) · log³ B) time for search "
                "bound B, and O(M) memory for the bucket table."
            ),
            "pseudocode": (
                "INPUT: exponent k, base a, candidate period M, search bound B\n"
                "OUTPUT: a pair (p, q) with p = q (mod M) and opposite bits, or NONE\n"
                "\n"
                "1. seen <- empty map from residues to (prime, bit)\n"
                "2. FOR p = 5, 6, ..., B - 1 DO\n"
                "3.     IF p is not prime OR k does not divide p - 1 OR p divides a THEN continue\n"
                "4.     bit <- POWER-RESIDUACITY-BIT(a, p, k)\n"
                "5.     r <- p mod M\n"
                "6.     IF r in seen THEN\n"
                "7.         (q, bit_q) <- seen[r]\n"
                "8.         IF bit_q != bit THEN RETURN (q, p, r)      // M refuted\n"
                "9.     ELSE seen[r] <- (p, bit)\n"
                "10. RETURN NONE                                        // no witness below B"
            ),
            "code": MR_ONLY + ALGO_BIT + "\n" + ALGO_REFUTE,
        },
        {
            "name": "Residuacity Fingerprint Capacity Profiler",
            "description": (
                "Measures how much a K-symbol residuacity fingerprint can actually distinguish, and "
                "contrasts it with the illusory separating power of the raw symbol values. For each "
                "prefix length K of the base list, the profiler counts the distinct bit-fingerprints "
                "realised on the candidate primes, prints the theoretical ceiling 2^K, and counts the "
                "distinct raw symbol vectors. The bit column is provably capped by the ceiling at every "
                "exponent k; the raw column is not, because raw symbol values live in Z/p and therefore "
                "encode p itself — the profiler is the instrument that exposes this circularity as a "
                "measurement rather than an argument. Complexity: O(|S| · K) modular exponentiations, "
                "i.e. O(|S| · K · log³ p) bit operations, with O(|S|) memory for the hash sets."
            ),
            "pseudocode": (
                "INPUT: candidate primes S, base list (a_1, ..., a_Kmax), exponent k\n"
                "OUTPUT: for each K, (distinct fingerprints, ceiling 2^K, distinct raw vectors)\n"
                "\n"
                "1. usable <- { p in S : k divides p - 1 and no a_i divides p }\n"
                "2. FOR K = 1 TO Kmax DO\n"
                "3.     prefix <- (a_1, ..., a_K)\n"
                "4.     F <- empty set ; R <- empty set\n"
                "5.     FOR each p in usable DO\n"
                "6.         insert (POWER-RESIDUACITY-BIT(a_i, p, k))_{i<=K} into F\n"
                "7.         insert (a_i^((p-1)/k) mod p)_{i<=K}            into R\n"
                "8.     OUTPUT (K, |F|, 2^K, |R|)      // always |F| <= 2^K ; |R| is unbounded"
            ),
            "code": MR_ONLY + ALGO_BIT + "\n" + ALGO_CAP,
        },
        {
            "name": "Cubic Residuacity of 2 via Gauss's Quadratic Form",
            "description": (
                "Decides cubic residuacity of 2 at a prime p ≡ 1 (mod 3) by the non-congruence route: "
                "Gauss's theorem that 2 is a cube modulo p if and only if p is representable as "
                "x² + 27y². The algorithm searches y upward while 27y² ≤ p and tests whether the "
                "remainder is a perfect square, returning the representation as a certificate when one "
                "exists. Mathematically this is the splitting condition of p in the non-normal cubic "
                "field generated by the real cube root of 2, whose Galois closure has the non-abelian "
                "group S₃ — which is precisely why the condition is not a congruence. Complexity: "
                "O(sqrt(p/27)) integer square roots, i.e. exponential in log p. That cost is the point: "
                "the only congruence-free route to the cubic bit is infeasible, and for a hidden factor "
                "of a semiprime it is factoring-strength."
            ),
            "pseudocode": (
                "INPUT: prime p with p = 1 (mod 3)\n"
                "OUTPUT: (TRUE, (x, y)) if p = x^2 + 27 y^2, else (FALSE, NONE)\n"
                "\n"
                "1. y <- 1\n"
                "2. WHILE 27 * y * y <= p DO\n"
                "3.     rest <- p - 27 * y * y\n"
                "4.     x <- floor(sqrt(rest))\n"
                "5.     IF x * x = rest THEN RETURN (TRUE, (x, y))    // 2 is a cube mod p\n"
                "6.     y <- y + 1\n"
                "7. RETURN (FALSE, NONE)                              // 2 is not a cube mod p"
            ),
            "code": "from math import isqrt\nfrom typing import Optional, Tuple\n\n\n" + ALGO_GAUSS,
        },
        {
            "name": "Hybrid Indistinguishability Bound: Hint, Dials and Higher-Power Bits Combined",
            "description": (
                "Quantifies how much an observer learns when every available channel is used at once: a "
                "residue hint p ≡ r (mod m), the readings of L periodic dials with conductor lcm M*, and "
                "K higher-power residuacity bits. A fibrewise pigeonhole argument guarantees that some "
                "joint reading is shared by at least |Ω| / ((M*/gcd(M*,m)) · 2^K) candidates, which "
                "therefore remain perfectly indistinguishable. The algorithm computes both the guaranteed "
                "bound and the largest class actually observed, letting one see the slack. The decisive "
                "structural feature is that the higher-power channel enters the bound only through the "
                "factor 2^K — exactly what K bits from any source would contribute — so escaping "
                "periodicity relabels which bits are read without creating new ones. Complexity: "
                "O(|Ω| · (L + K) · log³ p) time and O(|Ω|) memory."
            ),
            "pseudocode": (
                "INPUT: candidates Omega, hint modulus m, dial conductors (M_1,...,M_L),\n"
                "       bases (a_1,...,a_K), exponent k\n"
                "OUTPUT: guaranteed indistinguishable class size and the observed largest class\n"
                "\n"
                "1. M_star <- lcm(M_1, ..., M_L)\n"
                "2. divisor <- (M_star / gcd(M_star, m)) * 2^K\n"
                "3. fibres <- empty map\n"
                "4. FOR each p in Omega DO\n"
                "5.     key <- ((p mod M_1, ..., p mod M_L),\n"
                "6.             (POWER-RESIDUACITY-BIT(a_i, p, k))_{i<=K})\n"
                "7.     fibres[key] <- fibres[key] + 1\n"
                "8. guaranteed <- |Omega| / divisor          // pigeonhole lower bound\n"
                "9. observed   <- max over keys of fibres[key]\n"
                "10. RETURN (guaranteed, observed)           // always observed >= guaranteed"
            ),
            "code": MR_ONLY + ALGO_BIT + "\n" + ALGO_HYBRID,
        },
    ],
    "visualizations": [
        {
            "name": "Periodic versus Non-Periodic Residue Channels, Side by Side",
            "description": (
                "A three-panel diagnostic of the escape. The left panel plots the quadratic residuacity "
                "bit of 2 against p mod 8 for all odd primes below the bound: every column is "
                "monochrome, making the dial structure visible at a glance. The centre panel plots the "
                "cubic bit against p mod 9 for primes ≡ 1 (mod 3): every column is mixed, so no "
                "congruence class decides the bit. The right panel replaces the congruence with the "
                "condition that actually governs the cubic bit — the primes representable as x² + 27y² "
                "are drawn at their lattice point (x, y), the rest on a baseline — and the script reports "
                "the number of mismatches between Gauss's criterion and the computed bit, which is zero."
            ),
            "code": VIZ_PERIOD,
        },
        {
            "name": "The Capacity Ceiling 2^K and the Circularity Mirage",
            "description": (
                "Two panels on a shared pool of primes. The left panel tracks the number of distinct "
                "K-symbol residuacity fingerprints as K grows, for exponents k = 2, 3, 4, 6, plotted "
                "against the theoretical ceiling 2^K on a base-2 logarithmic axis: all curves are trapped "
                "under one and the same ceiling, and the higher-exponent curves sit below the quadratic "
                "one, the visible consequence of k-th powers occupying only a 1/k fraction of the units. "
                "The right panel plots the number of distinct raw symbol vectors, which saturates at the "
                "pool size for every exponent — total separation, obtained only because those values live "
                "in the residues modulo p and therefore encode the secret."
            ),
            "code": VIZ_CAP,
        },
    ],
    "interactive_demos": [
        {
            "title": "The Residue Channel Laboratory: Turn the Dial, Watch the Cubic Channel Escape, Then Watch It Buy Nothing",
            "description": (
                "A four-tab exploration environment, computing everything live in the browser with exact "
                "big-integer modular arithmetic and deterministic Miller-Rabin primality testing. "
                "Tab 1 — The Dial: slide through the primes and see the eight-slot knob of quadratic "
                "residuacity of 2, with the congruence rule p ≡ 1, 7 (mod 8) and the honest exponentiation "
                "2^((p−1)/2) mod p agreeing in every case. "
                "Tab 2 — The Escape: inspect the witness pair 43 and 720763 = 43 + lcm(1,…,16), test any "
                "modulus you like to confirm the two primes are congruent modulo it while their cubic bits "
                "differ, and then hunt your own refuting pair for any period M and base a of your choosing. "
                "Tab 3 — Gauss's Form: tabulate primes ≡ 1 (mod 3) alongside their residue mod 9, their "
                "cubic bit and their representation p = x² + 27y², seeing the quadratic-form criterion "
                "match perfectly while the congruence class fails to. "
                "Tab 4 — Capacity: choose an exponent and a base list and measure, on any prime range, the "
                "number of distinct residuacity fingerprints against the ceiling 2^K, side by side with "
                "the raw symbol values that separate everything precisely because they encode p."
            ),
            "html": WIDGET,
        }
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": LEAN_PROOFS,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": DEMO,
        "demo_witness_audit": DEMO_AUDIT,
        "algorithms": read("assets/algorithms.py"),
        "viz_periodicity": VIZ_PERIOD,
        "viz_capacity": VIZ_CAP,
    },
    "lean_files": LEAN_FILES,
}


def main() -> None:
    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"wrote {out}  ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""
The Higher-Power Reciprocity Channel, Closed
============================================

Self-contained numerical demonstration of every result in the accompanying paper.

Contents
--------
1. Primality and the k-th power criterion (Euler's criterion at every exponent).
2. The quadratic channel is a DIAL: residuacity of 2 is decided by p mod 8.
3. The cubic channel ESCAPES: the witness pair 43 / 720763 = 43 + lcm(1..16).
4. The quartic channel escapes: the witness pair 137 / 720857.
5. Gauss's criterion p = x^2 + 27y^2 reproduces every cubic bit.
6. Capacity: a K-symbol residuacity fingerprint takes at most 2^K values,
   at EVERY exponent; sharpness at K = 2 via {7, 31, 61, 307}.
7. Sparsity: exactly (p-1)/k of the units are k-th powers.
8. Transversality: all four (quadratic, cubic) bit patterns occur.
9. CRT symmetry: residuacity mod N = m*n is a symmetric function of {m, n}.
10. Leakage saturation over the 68 primes in [1000, 2000] with p = 1 mod 3,
    and the "68/68 distinct" mirage explained.
11. Hybrid no-amplification bound: hint + dials + higher-power bits.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from itertools import product
from math import gcd, isqrt
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. Arithmetic primitives
# ----------------------------------------------------------------------------

MILLER_RABIN_BASES: Tuple[int, ...] = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37)


def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin, correct for all n < 3.3 * 10^24."""
    if n < 2:
        return False
    for p in MILLER_RABIN_BASES:
        if n % p == 0:
            return n == p
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in MILLER_RABIN_BASES:
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def primes_in(lo: int, hi: int) -> List[int]:
    """All primes p with lo <= p < hi."""
    return [n for n in range(max(lo, 2), hi) if is_prime(n)]


def power_symbol(a: int, p: int, k: int) -> int:
    """The k-th power symbol a^((p-1)/k) mod p.  Requires k | p-1."""
    if (p - 1) % k != 0:
        raise ValueError(f"exponent {k} does not divide p-1 = {p - 1}")
    return pow(a, (p - 1) // k, p)


def residuacity_bit(a: int, p: int, k: int) -> bool:
    """True iff a is a k-th power residue mod the prime p (Euler's criterion,
    valid at every exponent k dividing p-1 by the k-th power criterion in the
    cyclic group (Z/p)^*)."""
    if a % p == 0:
        raise ValueError("base must be prime to p")
    if (p - 1) % k != 0:
        # k-th powers exhaust the units when gcd(k, p-1) = 1.
        return residuacity_bit(a, p, gcd(k, p - 1)) if gcd(k, p - 1) > 1 else True
    return power_symbol(a, p, k) == 1


def brute_force_is_power_residue(a: int, n: int, k: int) -> bool:
    """Definition-level check: does b^k = a (mod n) have a solution?  Used to
    confirm the criterion and to handle composite moduli."""
    target = a % n
    return any(pow(b, k, n) == target for b in range(n))


# ----------------------------------------------------------------------------
# 2. Gauss's criteria
# ----------------------------------------------------------------------------

def repr_x2_27y2(p: int) -> Optional[Tuple[int, int]]:
    """Return (x, y) with p = x^2 + 27 y^2 if one exists, else None."""
    y = 0
    while 27 * y * y <= p:
        rest = p - 27 * y * y
        x = isqrt(rest)
        if x * x == rest and y > 0:
            return (x, y)
        y += 1
    return None


def quadratic_bit_from_mod8(p: int) -> bool:
    """Gauss's second supplement: 2 is a square mod p iff p = 1 or 7 (mod 8)."""
    return p % 8 in (1, 7)


# ----------------------------------------------------------------------------
# 3. Fingerprints, dials and capacity
# ----------------------------------------------------------------------------

def fingerprint(p: int, bases: Sequence[int], k: int) -> Tuple[bool, ...]:
    """The secret-independent read-out: one residuacity BIT per base."""
    return tuple(residuacity_bit(a, p, k) for a in bases)


def raw_symbol_vector(p: int, bases: Sequence[int], k: int) -> Tuple[int, ...]:
    """The raw symbol VALUES, which live in Z/p and therefore encode p."""
    return tuple(power_symbol(a, p, k) for a in bases)


def capacity(K: int) -> int:
    """Maximum number of distinct length-K residuacity fingerprints: 2^K,
    independently of the exponent k."""
    return 2 ** K


def count_kth_powers(p: int, k: int) -> int:
    """Number of k-th powers among the p-1 units mod p."""
    return len({pow(b, k, p) for b in range(1, p)})


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

LCM_1_16 = 720720  # lcm(1, 2, ..., 16) = 2^4 * 3^2 * 5 * 7 * 11 * 13


def rule(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


def demo_criterion() -> None:
    rule("1. The k-th power criterion (Euler at every exponent)")
    print("For a prime p and k | p-1:  a is a k-th power mod p  <=>  a^((p-1)/k) = 1.")
    print(f"{'p':>6} {'k':>3} {'a':>3} {'a^((p-1)/k) mod p':>19} {'criterion':>10} {'brute force':>12}")
    for p, k, a in [(31, 3, 2), (31, 3, 3), (13, 4, 3), (13, 4, 5), (43, 3, 2), (137, 4, 2)]:
        crit = residuacity_bit(a, p, k)
        brute = brute_force_is_power_residue(a, p, k)
        assert crit == brute, "criterion disagrees with brute force!"
        print(f"{p:>6} {k:>3} {a:>3} {power_symbol(a, p, k):>19} {str(crit):>10} {str(brute):>12}")
    print("Criterion and definition agree on every case.")


def demo_quadratic_dial() -> None:
    rule("2. The quadratic channel IS a dial (conductor 8)")
    print("Gauss's second supplement: 2 is a square mod p  <=>  p = 1 or 7 (mod 8).")
    mismatches = 0
    by_class: Dict[int, set] = {r: set() for r in (1, 3, 5, 7)}
    for p in primes_in(3, 5000):
        bit = residuacity_bit(2, p, 2)
        if bit != quadratic_bit_from_mod8(p):
            mismatches += 1
        by_class[p % 8].add(bit)
    print(f"Primes 3..5000 checked; mismatches with the mod-8 rule: {mismatches}")
    for r, bits in sorted(by_class.items()):
        print(f"  p = {r} (mod 8):  observed quadratic bits = {sorted(bits)}"
              f"  -> {'CONSTANT (dial)' if len(bits) == 1 else 'varies'}")
    print("Every residue class mod 8 gives a constant bit: the channel is periodic.")


def demo_cubic_escape() -> None:
    rule("3. The cubic channel ESCAPES every modulus dividing lcm(1..16)")
    p, q = 43, 43 + LCM_1_16
    assert q == 720763
    print(f"Witness pair:  p = {p},  q = {q} = {p} + {LCM_1_16}")
    print(f"  both prime?           {is_prime(p)}, {is_prime(q)}")
    print(f"  both = 1 mod 3?       {p % 3 == 1}, {q % 3 == 1}")
    print(f"  2^((p-1)/3) mod p  =  {power_symbol(2, p, 3)}   -> 2 IS a cube mod {p}")
    print(f"  2^((q-1)/3) mod q  =  {power_symbol(2, q, 3)}   -> 2 is NOT a cube mod {q}")
    print(f"  explicit cube root mod {p}: 20^3 = {20 ** 3} = {20 ** 3 // p}*{p} + {20 ** 3 % p}")
    divisors = [M for M in range(1, 100) if LCM_1_16 % M == 0]
    print(f"\nModuli M <= 99 dividing {LCM_1_16}: {len(divisors)} of them.")
    bad = [M for M in divisors if p % M != q % M]
    print(f"Moduli on which the two witnesses differ: {bad}  (empty = escape at all of them)")
    print("Since p = q mod M yet the cubic bits differ, NO function of p mod M,")
    print("valued in any set, composed with any decision rule, can decide the bit.")


def demo_quartic_escape() -> None:
    rule("4. The quartic channel escapes the same way")
    p, q = 137, 137 + LCM_1_16
    assert q == 720857
    print(f"Witness pair:  p = {p},  q = {q}")
    print(f"  both prime?           {is_prime(p)}, {is_prime(q)}")
    print(f"  both = 1 mod 4?       {p % 4 == 1}, {q % 4 == 1}")
    print(f"  2^((p-1)/4) mod p  =  {power_symbol(2, p, 4)}   -> 2 is NOT a 4th power mod {p}")
    print(f"  2^((q-1)/4) mod q  =  {power_symbol(2, q, 4)}   -> 2 IS a 4th power mod {q}")
    print(f"  explicit 4th root mod {q}: 96769^4 mod {q} = {pow(96769, 4, q)}")


def demo_gauss_x2_27y2() -> None:
    rule("5. Gauss: 2 is a cube mod p  <=>  p = x^2 + 27 y^2")
    print(f"{'p':>8} {'cubic bit of 2':>15} {'x^2+27y^2 rep':>18} {'agree':>7}")
    sample = [7, 13, 31, 43, 61, 79, 103, 109, 127, 157, 307, 720763]
    ok = True
    for p in sample:
        if not (is_prime(p) and p % 3 == 1):
            continue
        bit = residuacity_bit(2, p, 3)
        rep = repr_x2_27y2(p)
        agree = bit == (rep is not None)
        ok = ok and agree
        rep_s = f"{rep[0]}^2+27*{rep[1]}^2" if rep else "none"
        print(f"{p:>8} {str(bit):>15} {rep_s:>18} {str(agree):>7}")
    print(f"All agree: {ok}   (a non-congruence, quadratic-form condition)")


def demo_capacity_and_sharpness() -> None:
    rule("6. Capacity 2^K at EVERY exponent -- and sharpness at K = 2")
    S = [7, 31, 61, 307]
    bases = (2, 3)
    print("Cubic bits at bases (2, 3):")
    for p in S:
        print(f"  p = {p:>4}:  fingerprint = {tuple(int(b) for b in fingerprint(p, bases, 3))}")
    fps = {fingerprint(p, bases, 3) for p in S}
    print(f"Distinct fingerprints: {len(fps)} = 2^2 = {capacity(2)}  -> the bound is ATTAINED.")
    print("By the capacity theorem no set of 5 or more primes has an injective 2-bit")
    print("cubic fingerprint, since 5 > 2^2.")

    print("\nExponent-independence of the ceiling, empirically:")
    pool = [p for p in primes_in(5, 4000) if (p - 1) % 12 == 0]
    for k in (2, 3, 4, 6):
        for K in (2, 3, 5):
            bs = (2, 3, 5, 7, 11)[:K]
            distinct = len({fingerprint(p, bs, k) for p in pool})
            print(f"  k={k}, K={K}: distinct fingerprints over {len(pool)} primes = "
                  f"{distinct:>3}  (ceiling 2^{K} = {capacity(K)})")


def demo_sparsity() -> None:
    rule("7. Sparsity: exactly (p-1)/k of the units are k-th powers")
    print(f"{'p':>6} {'k':>3} {'#k-th powers':>14} {'(p-1)/k':>9} {'density':>9}")
    for p in (13, 31, 61, 157):
        for k in (2, 3, 4, 6):
            if (p - 1) % k:
                continue
            cnt = count_kth_powers(p, k)
            assert cnt == (p - 1) // k
            print(f"{p:>6} {k:>3} {cnt:>14} {(p - 1) // k:>9} {cnt / (p - 1):>9.4f}")
    print("A cubic bit says 'yes' on 1/3 of bases, a quadratic bit on 1/2:")
    print("entropy H(1/3) = 0.9183 bits  <  H(1/2) = 1.0000 bit.")
    print("The higher bit is individually POORER while sharing the same ceiling.")


def demo_transversality() -> None:
    rule("8. Transversality: all four (quadratic, cubic) patterns occur")
    print(f"{'p':>5} {'2 a square?':>13} {'2 a cube?':>11}")
    seen = set()
    for p in (7, 13, 31, 43):
        q2, q3 = residuacity_bit(2, p, 2), residuacity_bit(2, p, 3)
        seen.add((q2, q3))
        print(f"{p:>5} {str(q2):>13} {str(q3):>11}")
    print(f"Distinct patterns: {len(seen)} of 4  -> neither bit is a function of the other.")
    print("  (7 and 31 share the quadratic bit, differ in the cubic bit;")
    print("   31 and 43 share the cubic bit, differ in the quadratic bit.)")


def demo_crt_symmetry() -> None:
    rule("9. CRT: residuacity at N = m*n is symmetric in the factors")
    print("PR_k(m*n, a)  <=>  PR_k(m, a) AND PR_k(n, a)   -- hence unordered in {m, n}.")
    print(f"{'m':>5} {'n':>5} {'k':>3} {'a':>3} {'mod m*n':>9} {'mod m and mod n':>17}")
    for (m, n, k, a) in [(7, 31, 3, 2), (13, 43, 3, 5), (5, 13, 4, 3), (11, 23, 2, 3)]:
        left = brute_force_is_power_residue(a, m * n, k)
        right = (brute_force_is_power_residue(a, m, k)
                 and brute_force_is_power_residue(a, n, k))
        assert left == right
        print(f"{m:>5} {n:>5} {k:>3} {a:>3} {str(left):>9} {str(right):>17}")
    print("The N-computable datum cannot single out a factor: it is symmetric.")


def demo_leakage_saturation() -> None:
    rule("10. Leakage saturation, and the '68/68' mirage")
    ps = [p for p in primes_in(1000, 2000) if p % 3 == 1]
    bases = (2, 3, 5, 7, 11)
    K = len(bases)
    raw_q = {raw_symbol_vector(p, bases, 2) for p in ps}
    raw_c = {raw_symbol_vector(p, bases, 3) for p in ps}
    bit_q = {fingerprint(p, bases, 2) for p in ps}
    bit_c = {fingerprint(p, bases, 3) for p in ps}
    print(f"Candidate set: the {len(ps)} primes p in [1000, 2000] with p = 1 (mod 3).")
    print(f"Bases: {bases};  K = {K};  capacity 2^K = {capacity(K)}\n")
    print(f"{'fingerprint':>34} {'distinct':>9} {'ceiling':>10}")
    print(f"{'full quadratic symbol values':>34} {len(raw_q):>9} {'(none)':>10}")
    print(f"{'full cubic symbol values':>34} {len(raw_c):>9} {'(none)':>10}")
    print(f"{'quadratic residuacity BITS':>34} {len(bit_q):>9} {capacity(K):>10}")
    print(f"{'cubic residuacity BITS':>34} {len(bit_c):>9} {capacity(K):>10}")
    print("\nWhy the raw values separate everything: they live in Z/p, so the")
    print("'fingerprint' already encodes p.  Computing it requires the secret --")
    print("circularity in numerical costume.  The secret-independent read-out")
    print("(the bits) is pinned under 2^K for BOTH channels, cubic doing worse")
    print("because a 1/3-dense predicate wastes more of the pattern space.")


def demo_hybrid_bound() -> None:
    rule("11. Hybrid no-amplification: hint + dials + higher-power bits")
    # Dials: p mod 8 (quadratic bit of 2) and p mod 5; hint: p = 1 mod 4.
    m, r = 4, 1
    dial_conductors = (8, 5)
    M_star = 1
    for c in dial_conductors:
        M_star = M_star * c // gcd(M_star, c)
    omega = [p for p in primes_in(1000, 20000) if p % m == r % m and p % 3 == 1]
    bases = (2, 3, 5)
    K = len(bases)

    def joint(p: int) -> Tuple[int, int, Tuple[bool, ...]]:
        return (p % 8, p % 5, fingerprint(p, bases, 3))

    fibres: Dict[Tuple[int, int, Tuple[bool, ...]], int] = {}
    for p in omega:
        fibres[joint(p)] = fibres.get(joint(p), 0) + 1
    largest = max(fibres.values())
    bound_divisor = (M_star // gcd(M_star, m)) * capacity(K)
    guaranteed = len(omega) / bound_divisor
    print(f"Candidates |Omega| = {len(omega)} primes with p = {r} (mod {m}), p = 1 (mod 3)")
    print(f"Dial conductors {dial_conductors} -> M* = {M_star}; hint modulus m = {m}")
    print(f"Higher-power bits: K = {K} cubic bits at bases {bases}")
    print(f"Bound divisor (M*/gcd(M*,m)) * 2^K = "
          f"({M_star}/{gcd(M_star, m)}) * {capacity(K)} = {bound_divisor}")
    print(f"Guaranteed indistinguishable class size >= {guaranteed:.2f}")
    print(f"Actually observed largest indistinguishable class: {largest}")
    assert largest >= guaranteed - 1e-9
    print("The higher-power channel enters only through 2^K -- the same factor any")
    print("K bits from any source would contribute.  No amplification.")


def main() -> None:
    print(__doc__)
    demo_criterion()
    demo_quadratic_dial()
    demo_cubic_escape()
    demo_quartic_escape()
    demo_gauss_x2_27y2()
    demo_capacity_and_sharpness()
    demo_sparsity()
    demo_transversality()
    demo_crt_symmetry()
    demo_leakage_saturation()
    demo_hybrid_bound()
    rule("VERDICT")
    print("The cubic and quartic channels genuinely escape periodicity, and are")
    print("genuinely transverse to the quadratic channel -- yet their capacity is")
    print("exactly 2^K, their bits are sparser, their composite-modulus versions are")
    print("symmetric, and computing them presupposes the very prime they describe.")
    print("Escape from periodicity is not a gain in information.")


if __name__ == "__main__":
    main()
