"""Algorithm 1 — Minimal Signed-Order (Residue-Degree) Evaluation."""

from __future__ import annotations

from math import gcd


def residue_degree(a: int, modulus: int) -> int:
    """Least k >= 1 with a**k congruent to +1 or -1 modulo `modulus`.

    For a prime p coprime to the conductor f this is the residue degree of p in
    the real cyclotomic field of conductor f, i.e. the order of the Frobenius
    class of p in the quotient of the unit group by {+-1}.

    Raises ValueError if `a` is not a unit modulo `modulus`.
    """
    if gcd(a % modulus, modulus) != 1:
        raise ValueError(f"{a} is not a unit modulo {modulus}")
    x = a % modulus
    for k in range(1, modulus + 1):
        if x == 1 % modulus or x == (modulus - 1) % modulus:
            return k
        x = (x * a) % modulus
    raise RuntimeError("unreachable for a unit")


def carmichael_bound(modulus: int) -> int:
    """Exponent of the unit group: an upper bound on every residue degree."""
    exponent = 1
    for a in range(1, modulus):
        if gcd(a, modulus) != 1:
            continue
        k, x = 1, a
        while x != 1 % modulus:
            x = (x * a) % modulus
            k += 1
        exponent = exponent * k // gcd(exponent, k)
    return exponent


if __name__ == "__main__":
    for a in (1, 13, 3, 5, 11, 55):
        print(f"T({a:>2} mod 56) = {residue_degree(a, 56)}")
    print("exponent of the unit group mod 56 =", carmichael_bound(56))


"""Algorithm 2 — Type Census with Chebotarev Density Reconciliation."""

from __future__ import annotations

from collections import Counter
from fractions import Fraction
from itertools import product
from math import gcd
from typing import Dict, List, Tuple


def residue_degree(a: int, modulus: int) -> int:
    """Least k >= 1 with a**k congruent to +-1 modulo `modulus`."""
    x = a % modulus
    for k in range(1, modulus + 1):
        if x == 1 % modulus or x == (modulus - 1) % modulus:
            return k
        x = (x * a) % modulus
    raise ValueError(f"{a} is not a unit modulo {modulus}")


def type_census(modulus: int) -> Dict[int, int]:
    """Number of reduced residues of each type, as a sorted dictionary."""
    units = [a for a in range(modulus) if gcd(a, modulus) == 1]
    return dict(sorted(Counter(residue_degree(a, modulus) for a in units).items()))


def type_densities(modulus: int) -> Dict[int, Fraction]:
    """Exact rational density of each type among the reduced residues."""
    census = type_census(modulus)
    total = sum(census.values())
    return {t: Fraction(c, total) for t, c in census.items()}


def order_profile(cyclic_factors: List[int]) -> Dict[int, int]:
    """Number of elements of each order in the product of the given cyclic groups."""
    profile: Counter = Counter()
    for coords in product(*[range(n) for n in cyclic_factors]):
        order = 1
        for x, n in zip(coords, cyclic_factors):
            oi = n // gcd(x, n)
            order = order * oi // gcd(order, oi)
        profile[order] += 1
    return dict(sorted(profile.items()))


def chebotarev_reconciliation(modulus: int,
                              cyclic_factors: List[int]) -> Tuple[bool, Dict[int, Tuple[int, int]]]:
    """Check that #{residues of type d} equals 2 * #{group elements of order d}.

    Returns a flag and, for each type, the pair (residue count, group count).
    """
    census = type_census(modulus)
    profile = order_profile(cyclic_factors)
    keys = sorted(set(census) | set(profile))
    table = {d: (census.get(d, 0), profile.get(d, 0)) for d in keys}
    ok = all(n == 2 * m for n, m in table.values())
    return ok, table


if __name__ == "__main__":
    print("census mod 56  :", type_census(56))
    print("densities      :", {t: str(d) for t, d in type_densities(56).items()})
    ok, table = chebotarev_reconciliation(56, [6, 2])
    print("Chebotarev match against C6 x C2 :", ok)
    for d, (n, m) in table.items():
        print(f"   type {d}: {n} residues,  {m} group elements of that order")


"""Algorithm 3 — Frobenius Orbit Decomposition and the e*f*g Splitting Law."""

from __future__ import annotations

from itertools import product
from math import gcd
from typing import Dict, List, Sequence, Tuple

Element = Tuple[int, ...]


def group_elements(cyclic_factors: Sequence[int]) -> List[Element]:
    """All elements of the product of cyclic groups, as coordinate tuples."""
    return [tuple(c) for c in product(*[range(n) for n in cyclic_factors])]


def translate(x: Element, g: Element, cyclic_factors: Sequence[int]) -> Element:
    """The group operation: coordinatewise addition modulo each factor."""
    return tuple((xi + gi) % n for xi, gi, n in zip(x, g, cyclic_factors))


def frobenius_orbits(g: Element,
                     cyclic_factors: Sequence[int]) -> List[List[Element]]:
    """Partition the group into orbits of translation by g."""
    seen: set = set()
    orbits: List[List[Element]] = []
    for x in group_elements(cyclic_factors):
        if x in seen:
            continue
        orbit: List[Element] = []
        y = x
        while y not in seen:
            seen.add(y)
            orbit.append(y)
            y = translate(y, g, cyclic_factors)
        orbits.append(orbit)
    return orbits


def element_order(g: Element, cyclic_factors: Sequence[int]) -> int:
    """Order of g: the lcm of the orders of its coordinates."""
    order = 1
    for x, n in zip(g, cyclic_factors):
        oi = n // gcd(x, n)
        order = order * oi // gcd(order, oi)
    return order


def splitting_shape(g: Element,
                    cyclic_factors: Sequence[int]) -> Tuple[int, int, bool]:
    """Return (f, g_count, purity): orbit length, orbit count, all-equal-length flag."""
    orbits = frobenius_orbits(g, cyclic_factors)
    f = element_order(g, cyclic_factors)
    purity = all(len(o) == f for o in orbits)
    return f, len(orbits), purity


def shape_table(cyclic_factors: Sequence[int]) -> Dict[Tuple[int, int], int]:
    """How many Frobenius classes realise each splitting shape (f, g)."""
    table: Dict[Tuple[int, int], int] = {}
    for g in group_elements(cyclic_factors):
        f, count, pure = splitting_shape(g, cyclic_factors)
        assert pure, "orbit purity failed"
        assert f * count == len(group_elements(cyclic_factors)), "e*f*g law failed"
        table[(f, count)] = table.get((f, count), 0) + 1
    return dict(sorted(table.items()))


if __name__ == "__main__":
    factors = [6, 2]
    print("splitting shapes (f, g) -> number of Frobenius classes, for C6 x C2")
    for (f, g), n in shape_table(factors).items():
        print(f"   (f, g) = ({f:>2}, {g:>2})   f*g = {f * g:>2}   realised by {n} classes")
    print("\norbits of translation by (1, 0):")
    for orbit in frobenius_orbits((1, 0), factors):
        print("   " + " -> ".join(str(x) for x in orbit))


"""Algorithm 4 — Order-Profile Entropy Discriminator for Abelian Groups."""

from __future__ import annotations

import math
from collections import Counter
from itertools import product
from typing import Dict, List, Tuple


def partitions(n: int, largest: int | None = None) -> List[List[int]]:
    """All partitions of n, each written in weakly decreasing order."""
    if largest is None:
        largest = n
    if n == 0:
        return [[]]
    out: List[List[int]] = []
    for k in range(min(n, largest), 0, -1):
        for rest in partitions(n - k, k):
            out.append([k] + rest)
    return out


def factorize(n: int) -> Dict[int, int]:
    """Prime factorisation of n as a dictionary prime -> exponent."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def abelian_groups(n: int) -> List[List[int]]:
    """Every abelian group of order n, as a list of cyclic prime-power factors."""
    groups: List[List[int]] = [[]]
    for p, e in factorize(n).items():
        extended: List[List[int]] = []
        for part in partitions(e):
            block = [p**k for k in part]
            extended.extend(g + block for g in groups)
        groups = extended
    return groups


def invariant_factor_name(cyclic_factors: List[int]) -> str:
    """Canonical name C_{d1} x ... x C_{dk} with d1 | d2 | ... | dk."""
    by_prime: Dict[int, List[int]] = {}
    for q in cyclic_factors:
        p = next(iter(factorize(q)))
        by_prime.setdefault(p, []).append(q)
    for p in by_prime:
        by_prime[p].sort(reverse=True)
    width = max((len(v) for v in by_prime.values()), default=0)
    invariants: List[int] = []
    for i in range(width):
        d = 1
        for qs in by_prime.values():
            if i < len(qs):
                d *= qs[i]
        invariants.append(d)
    invariants.sort()
    return " x ".join(f"C{d}" for d in invariants) if invariants else "C1"


def order_profile(cyclic_factors: List[int]) -> Dict[int, int]:
    """Number of elements of each order."""
    profile: Counter = Counter()
    for coords in product(*[range(n) for n in cyclic_factors]):
        order = 1
        for x, n in zip(coords, cyclic_factors):
            oi = n // math.gcd(x, n)
            order = order * oi // math.gcd(order, oi)
        profile[order] += 1
    return dict(sorted(profile.items()))


def profile_entropy(profile: Dict[int, int]) -> float:
    """Shannon entropy, in bits, of the order of a uniformly random element."""
    total = sum(profile.values())
    return -sum((c / total) * math.log2(c / total) for c in profile.values() if c)


def identify_group(order: int, measured_entropy: float,
                   tolerance: float = 1e-6) -> List[str]:
    """Names of the abelian groups of the given order matching a measured entropy."""
    hits: List[str] = []
    for g in abelian_groups(order):
        if abs(profile_entropy(order_profile(g)) - measured_entropy) < tolerance:
            hits.append(invariant_factor_name(g))
    return hits


def discriminating_orders(limit: int) -> Tuple[List[int], List[int]]:
    """Orders up to `limit` where the invariant does, and does not, separate."""
    separated, collided = [], []
    for n in range(2, limit + 1):
        values = [round(profile_entropy(order_profile(g)), 9) for g in abelian_groups(n)]
        (separated if len(set(values)) == len(values) else collided).append(n)
    return separated, collided


if __name__ == "__main__":
    measured = 4 / 3 + math.log2(3) / 4
    print(f"measured entropy {measured:.6f} bits at degree 12")
    for g in abelian_groups(12):
        name = invariant_factor_name(g)
        h = profile_entropy(order_profile(g))
        verdict = "MATCH" if abs(h - measured) < 1e-9 else "excluded"
        print(f"   {name:12s} H = {h:.6f}   {verdict}")
    print("identified:", identify_group(12, measured))
    sep, col = discriminating_orders(30)
    print(f"orders up to 30 where the invariant separates: {sep}")
    print(f"orders where two abelian groups collide      : {col}")


"""Algorithm 5 — Conductor Selection by Prescribed Degree and Cyclicity."""

from __future__ import annotations

from math import gcd
from typing import Dict, List, NamedTuple


class ConductorRecord(NamedTuple):
    conductor: int
    totient: int
    degree: int
    exponent: int
    cyclic: bool
    duplicate_of: int | None


def residue_degree(a: int, modulus: int) -> int:
    """Least k >= 1 with a**k congruent to +-1 modulo `modulus`."""
    x = a % modulus
    for k in range(1, modulus + 1):
        if x == 1 % modulus or x == (modulus - 1) % modulus:
            return k
        x = (x * a) % modulus
    raise ValueError(f"{a} is not a unit modulo {modulus}")


def analyse_conductor(f: int) -> ConductorRecord:
    """Degree, exponent and cyclicity of the symmetry group of the real field."""
    units = [a for a in range(f) if gcd(a, f) == 1]
    degree = len({min(a, f - a) for a in units})
    exponent = 1
    for a in units:
        k = residue_degree(a, f)
        exponent = exponent * k // gcd(exponent, k)
    duplicate = f // 2 if (f % 4 == 2 and f > 2) else None
    return ConductorRecord(f, len(units), degree, exponent,
                           exponent == degree, duplicate)


def candidates_of_degree(n: int, search_limit: int | None = None) -> List[ConductorRecord]:
    """Every conductor whose real field has the prescribed degree n."""
    if search_limit is None:
        search_limit = 8 * n * n + 16
    out: List[ConductorRecord] = []
    for f in range(3, search_limit):
        units = sum(1 for a in range(f) if gcd(a, f) == 1)
        if units == 2 * n:
            out.append(analyse_conductor(f))
    return out


def select_first_noncyclic(n: int) -> ConductorRecord | None:
    """The smallest conductor of degree n whose symmetry group is not cyclic."""
    for record in candidates_of_degree(n):
        if not record.cyclic:
            return record
    return None


if __name__ == "__main__":
    records = candidates_of_degree(12)
    print(f"{'f':>4} {'phi(f)':>7} {'degree':>7} {'exponent':>9} {'cyclic':>7}  note")
    for r in records:
        note = f"same field as f = {r.duplicate_of}" if r.duplicate_of else ""
        print(f"{r.conductor:>4} {r.totient:>7} {r.degree:>7} {r.exponent:>9} "
              f"{('yes' if r.cyclic else 'NO'):>7}  {note}")
    chosen = select_first_noncyclic(12)
    print(f"\nselected conductor: {chosen.conductor if chosen else None}")
    counts: Dict[bool, int] = {True: 0, False: 0}
    for r in records:
        counts[r.cyclic] += 1
    print(f"cyclic candidates: {counts[True]}, non-cyclic candidates: {counts[False]}")


"""Assemble PACKAGE.json from the individual artefacts in this project."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict, List

ROOT = pathlib.Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES: List[str] = [
    "Catalog/Pythagorean/Degree12Composite.lean",
    "Catalog/Pythagorean/Degree12CompositeGalois.lean",
    "Catalog/Pythagorean/Degree12CompositeEntropy.lean",
    "Catalog/Pythagorean/Degree12CompositeFrobenius.lean",
    "Catalog/Pythagorean/Degree12CompositeSeparation.lean",
    "Catalog/Pythagorean/Degree12AxiomCheck.lean",
]

FUTURE_DIRECTIONS = """# Future directions — after the degree-12 composite rung

## What this cycle established

Formally, with zero gaps:

1. [Q(ζ₅₆) : Q] = 24, the involution attached to −1 has order 2, and the fixed field
   Q(ζ₅₆)⁺ has degree exactly **12**.
2. Gal(Q(ζ₅₆)⁺/Q) ≅ C₆ × C₂ as an explicit isomorphism, built from the basis
   3, 13, −1 of (ZMod 56)ˣ ≅ C₆ × C₂ × C₂, and the group is **not cyclic**: the first
   composite-order, non-cyclic rung.
3. Type densities {1/12, 1/4, 1/6, 1/2} and their identification with the order
   statistics of C₆ × C₂ (the Chebotarev match).
4. Full pinning as a *theorem about deterministic channels*: I(X ; φ(X)) = H(φ(X)) for
   any finite sample set and any channel, with gap identically 0; and the exact value
   H(T) = 4/3 + (log₂3)/4, bracketed 1.7295 < H < 1.7296.
5. Orbit purity and the efg law in a general finite abelian group, specialised to
   1 · f · g = 12 with the four shapes (1,12), (2,6), (3,4), (6,2).
6. The semiprime pair law #{(u,v) : T(uv) = t} = |S| · #{w : T w = t} for any
   translation-invariant sample set, hence identical prime and semiprime profiles.
7. **New this cycle**: the order-profile entropy *separates* the two abelian groups of
   order 12 — H(C₁₂) = 5/6 + log₂3 > 2 > 4/3 + (log₂3)/4 = H(C₆ × C₂) — so the single
   measured number 1.7296 certifies non-cyclicity.

## Conjectures for the next cycle

### 1. Entropy Injectivity for Abelian Galois Rungs

**Conjecture.** For abelian groups A, B of the same order n ≤ 100, the order-profile
entropies agree iff A ≅ B; i.e. the type entropy is a complete invariant of the
isomorphism class in that range.

*The key insight is* that the order profile of an abelian group is the multiset
{φ(d) · (#cyclic factors admitting order d)}, and the entropy is a ℚ-linear
combination of log₂ p over the primes p ∣ n, whose coefficients are ℚ-independent
unless the profiles coincide — so linear independence of {log₂ p} over ℚ
(Baker/Lindemann-type input, or elementary unique factorisation for rational
combinations) converts an analytic coincidence into a combinatorial one.

*Why now?* This cycle showed the invariant is *not* vacuous at n = 12, the first place
where two abelian groups exist; the general statement is exactly the assertion that the
ladder's measured number determines the rung.

### 2. Universal Pinning Functor for Deterministic Arithmetic Channels

**Conjecture.** For every modulus m, every {±1}-stable channel T : (ZMod m)ˣ → ℕ
factoring through (ZMod m)ˣ/{±1} satisfies I = H(T) and
H(T) ≤ log₂ (number of divisors of the exponent), with equality iff T is the order
function of an elementary abelian group.

*The key insight is* that the pinning identity is forced by determinism alone, while
the upper bound is the uniform-distribution bound over the possible types; equality
demands maximal spread of the order profile, which is exactly the elementary abelian
situation.

### 3. Higher rungs and non-abelian analogues

The orbit-purity and pair laws hold in any finite abelian group, so they transfer
unchanged to every conductor. Extending the entropy invariant beyond the abelian case
requires replacing "order of the Frobenius element" by "conjugacy class of the
Frobenius", with the class-profile entropy as the natural candidate invariant.

### 4. Effective versions

How many primes are needed before the empirical type entropy is provably within ε of
the exact value? Effective Chebotarev bounds would turn the entropic certificate of
non-cyclicity into a finite, verifiable computation over an explicit prime range.
"""


def lean_source() -> str:
    chunks = []
    for rel in LEAN_FILES:
        chunks.append(f"-- ===== {rel} =====\n\n" + read(ROOT / rel).rstrip() + "\n")
    return "\n\n".join(chunks)


def build() -> Dict[str, Any]:
    demo_main = read(ROOT / "demo.py")
    demo_exact = read(ASSETS / "demo_channel.py")

    algorithms = [
        {
            "name": "Minimal Signed-Order (Residue-Degree) Evaluation",
            "description": (
                "Computes the type T(a) = min{k >= 1 : a^k = +-1 mod m} of a reduced "
                "residue. For a prime p coprime to the conductor f this is precisely the "
                "residue degree of p in the real cyclotomic field of conductor f, i.e. the "
                "order of the Frobenius class of p in the quotient of the unit group by "
                "{+-1}. The algorithm walks the cyclic sequence a, a^2, a^3, ... modulo m "
                "and halts at the first power equal to +1 or -1; termination is guaranteed "
                "because a^lambda(m) = 1, where lambda is the Carmichael function (the "
                "exponent of the unit group), so at most lambda(m) iterations occur. Each "
                "iteration is one modular multiplication, giving O(lambda(m) log^2 m) bit "
                "operations; for m = 56 the exponent is 6, so at most six multiplications "
                "are performed. This routine is the atomic step of every other computation "
                "in the pipeline."
            ),
            "pseudocode": (
                "function RESIDUE-DEGREE(a, m):\n"
                "    require gcd(a mod m, m) = 1              # a must be a unit\n"
                "    x <- a mod m\n"
                "    for k = 1, 2, 3, ... , m:\n"
                "        if x = 1 mod m or x = m - 1 mod m:\n"
                "            return k                          # least signed order\n"
                "        x <- (x * a) mod m\n"
                "    error 'unreachable for a unit'\n"
                "\n"
                "function CARMICHAEL-BOUND(m):\n"
                "    e <- 1\n"
                "    for each unit a modulo m:\n"
                "        k <- multiplicative order of a modulo m\n"
                "        e <- lcm(e, k)\n"
                "    return e                                  # exponent of the unit group"
            ),
            "code": read(ASSETS / "algo1_resdeg.py"),
        },
        {
            "name": "Type Census with Chebotarev Density Reconciliation",
            "description": (
                "Tabulates how many reduced residues modulo m carry each type, converts the "
                "counts into exact rational densities, and reconciles them against the order "
                "statistics of a candidate Galois group presented as a product of cyclic "
                "factors. The reconciliation checks the identity #{a : T(a) = d} = "
                "2 * #{g : ord(g) = d}, the factor 2 arising because each group element lifts "
                "to the two residues +-a. At conductor 56 the census is (2, 6, 4, 12) out of "
                "24, i.e. densities 1/12, 1/4, 1/6, 1/2, matching the order profile "
                "(1, 3, 2, 6) of C6 x C2. Complexity: O(m * lambda(m)) modular operations for "
                "the census and O(|A| * log |A|) for the group profile; both are negligible at "
                "this scale. All arithmetic is exact — densities are rationals, never floats — "
                "so the match is a verified identity rather than a numerical coincidence."
            ),
            "pseudocode": (
                "function TYPE-CENSUS(m):\n"
                "    census <- empty map\n"
                "    for a = 0 .. m-1 with gcd(a, m) = 1:\n"
                "        d <- RESIDUE-DEGREE(a, m)\n"
                "        census[d] <- census[d] + 1\n"
                "    return census\n"
                "\n"
                "function ORDER-PROFILE(n_1, ..., n_r):\n"
                "    profile <- empty map\n"
                "    for each (x_1, ..., x_r) in Z/n_1 x ... x Z/n_r:\n"
                "        d <- lcm over i of (n_i / gcd(x_i, n_i))\n"
                "        profile[d] <- profile[d] + 1\n"
                "    return profile\n"
                "\n"
                "function CHEBOTAREV-RECONCILIATION(m, n_1, ..., n_r):\n"
                "    census  <- TYPE-CENSUS(m)\n"
                "    profile <- ORDER-PROFILE(n_1, ..., n_r)\n"
                "    return for every d:  census[d] = 2 * profile[d]"
            ),
            "code": read(ASSETS / "algo2_census.py"),
        },
        {
            "name": "Frobenius Orbit Decomposition and the Splitting Law e*f*g = n",
            "description": (
                "Decomposes a finite abelian group into the orbits of translation by a fixed "
                "element g — the action of the Frobenius symmetry on the cosets of the field — "
                "and certifies the two structural facts that make the type census meaningful. "
                "First, orbit purity: every orbit has exactly ord(g) elements, independently of "
                "its base point, because each orbit is a coset of the cyclic subgroup generated "
                "by g. Second, the classical decomposition law: the number of orbits times the "
                "common orbit length equals the group order, which for an unramified prime "
                "(e = 1) is exactly e * f * g = n with f the residue degree and g the number of "
                "primes lying above. The routine visits each element once, so the cost is O(|A|) "
                "group operations and O(|A|) memory. At conductor 56 it returns the four "
                "admissible shapes (f, g) = (1,12), (2,6), (3,4), (6,2), realised by 1, 3, 2 and "
                "6 Frobenius classes respectively."
            ),
            "pseudocode": (
                "function FROBENIUS-ORBITS(g, (n_1, ..., n_r)):\n"
                "    seen <- empty set;  orbits <- empty list\n"
                "    for each x in the group:\n"
                "        if x in seen: continue\n"
                "        orbit <- empty list;  y <- x\n"
                "        while y not in seen:\n"
                "            insert y into seen;  append y to orbit\n"
                "            y <- y + g                      # coordinatewise, modulo each n_i\n"
                "        append orbit to orbits\n"
                "    return orbits\n"
                "\n"
                "function SPLITTING-SHAPE(g, factors):\n"
                "    orbits <- FROBENIUS-ORBITS(g, factors)\n"
                "    f <- ord(g) = lcm over i of (n_i / gcd(g_i, n_i))\n"
                "    assert every orbit has length f          # orbit purity\n"
                "    assert f * |orbits| = |A|                # the e*f*g law with e = 1\n"
                "    return (f, |orbits|)"
            ),
            "code": read(ASSETS / "algo3_orbits.py"),
        },
        {
            "name": "Order-Profile Entropy Discriminator for Abelian Groups",
            "description": (
                "Enumerates every abelian group of a given order via partitions of the prime "
                "exponents, rewrites each in canonical invariant-factor form C_{d1} x ... x "
                "C_{dk} with d1 | ... | dk, computes its order profile and the Shannon entropy "
                "of that profile, and reports which candidates are compatible with a measured "
                "entropy. This is the inference step of the whole pipeline: a single real "
                "number measured from prime remainders is matched against a finite table of "
                "group invariants. At order 12 the table has two rows, H(C12) = 5/6 + log2 3 = "
                "2.41830... and H(C6 x C2) = 4/3 + (log2 3)/4 = 1.72957..., which straddle the "
                "threshold 2, so a measurement below 2 bits identifies the group uniquely. The "
                "enumeration costs O(p(e_1) * ... * p(e_k)) group constructions, where p is the "
                "partition function, and each profile costs O(n log n) operations. A companion "
                "routine sweeps all orders up to a limit and reports whether any two abelian "
                "groups of equal order share the invariant — up to order 30 none do."
            ),
            "pseudocode": (
                "function ABELIAN-GROUPS(n):\n"
                "    groups <- [ [] ]\n"
                "    for each prime power p^e || n:\n"
                "        groups <- { g ++ [p^k : k in part] : g in groups, part in partitions(e) }\n"
                "    return groups\n"
                "\n"
                "function PROFILE-ENTROPY(factors):\n"
                "    profile <- ORDER-PROFILE(factors);  N <- sum of profile\n"
                "    return - sum over d of (profile[d]/N) * log2(profile[d]/N)\n"
                "\n"
                "function IDENTIFY-GROUP(n, H_measured, tol):\n"
                "    matches <- empty list\n"
                "    for each A in ABELIAN-GROUPS(n):\n"
                "        if |PROFILE-ENTROPY(A) - H_measured| < tol:\n"
                "            append INVARIANT-FACTOR-NAME(A) to matches\n"
                "    return matches          # a single entry means the group is determined"
            ),
            "code": read(ASSETS / "algo4_discriminator.py"),
        },
        {
            "name": "Conductor Selection by Prescribed Degree and Cyclicity",
            "description": (
                "Implements the pre-stated selection rule that singles out conductor 56 from "
                "its competitors. For a target degree n the routine enumerates every conductor f "
                "with phi(f) = 2n, computes the degree of the real subfield as the number of "
                "+-classes of reduced residues, computes the exponent of the corresponding "
                "symmetry group as the lcm of all types, flags whether that group is cyclic "
                "(exponent equal to degree), and marks the conductors f = 2m with m odd that "
                "define the same field as m. At n = 12 it reproduces the full list of ten "
                "candidates 35, 39, 45, 52, 56, 70, 72, 78, 84, 90, finds that exactly three of "
                "them (56, 72, 84) have non-cyclic symmetry group C6 x C2, and selects the "
                "smallest, f = 56. Complexity is O(f * lambda(f)) per conductor, dominated by "
                "the type computations."
            ),
            "pseudocode": (
                "function ANALYSE-CONDUCTOR(f):\n"
                "    U <- { a in [0, f) : gcd(a, f) = 1 }\n"
                "    degree   <- |{ min(a, f - a) : a in U }|          # the +- classes\n"
                "    exponent <- lcm over a in U of RESIDUE-DEGREE(a, f)\n"
                "    cyclic   <- (exponent = degree)\n"
                "    return (f, |U|, degree, exponent, cyclic)\n"
                "\n"
                "function SELECT-FIRST-NONCYCLIC(n):\n"
                "    for f = 3, 4, 5, ... while phi(f) <= 2n or f <= bound:\n"
                "        if phi(f) = 2n:\n"
                "            record <- ANALYSE-CONDUCTOR(f)\n"
                "            if not record.cyclic: return f\n"
                "    return none"
            ),
            "code": read(ASSETS / "algo5_conductor.py"),
        },
    ]

    demos = [
        {
            "name": "End-to-End Demonstration of the Degree-12 Rung at Conductor 56",
            "description": (
                "A single self-contained script that reproduces every quantitative claim about "
                "the real cyclotomic field of conductor 56. It (1) verifies that the reduced "
                "residues mod 56 form a group of order 24 and exponent 6 with basis {3, 13, -1}, "
                "so the unit group is C6 x C2 x C2 and its quotient by {+-1} is the order-12 "
                "group C6 x C2; (2) tabulates the type census (2, 6, 4, 12) and matches the "
                "densities 1/12, 1/4, 1/6, 1/2 against the order statistics of C6 x C2; "
                "(3) computes the exact entropy H(T) = 4/3 + (log2 3)/4 = 1.729574 bits, the "
                "input entropy log2 24, the mutual information, the vanishing pinning gap and "
                "the residual uncertainty H(X|T); (4) repeats the measurement on the 17982 "
                "primes below 200000, comparing empirical densities to the Chebotarev "
                "predictions and running a label-shuffling significance test; (5) decomposes "
                "the Frobenius orbits, verifying orbit purity and the four splitting shapes "
                "(1,12), (2,6), (3,4), (6,2); (6) enumerates all 576 ordered pairs of residues "
                "to verify the semiprime law #{(u,v) : T(uv)=t} = 24 * #{w : T(w)=t}; "
                "(7) contrasts H(C12) = 2.418296 with H(C6 x C2) = 1.729574 across the "
                "threshold 2; and (8) prints the conductor-selection table showing that 56 is "
                "the smallest of the ten conductors with phi(f) = 24 whose degree-12 symmetry "
                "group fails to be cyclic. Runs in under a second with no dependencies."
            ),
            "code": demo_main,
        },
        {
            "name": "Exact-Arithmetic Certification of the Entropy Statements",
            "description": (
                "A floating-point-free verification of every entropy claim. Each entropy in this "
                "work has the shape a + b * log2(3) with a, b rational, so the script represents "
                "it symbolically as an exact pair of rationals and manipulates it algebraically. "
                "It then: computes the type census of the 24 reduced residues exactly; evaluates "
                "H(T) symbolically and checks the closed form 4/3 + (1/4) log2 3; certifies the "
                "bracket 84/53 < log2 3 < 233/147 by comparing the integers 2^84 with 3^53 and "
                "3^147 with 2^233, with no analysis and no rounding; deduces the rigorous "
                "numerical bracket 1.7295 < H(T) < 1.7296; computes the order-profile entropies "
                "of C12 and C6 x C2 symbolically and certifies H(C12) > 2 > H(C6 x C2); checks "
                "that the arithmetic channel and the group channel produce the identical "
                "symbolic value; and finally evaluates the mutual information term by term to "
                "confirm I(X;T) - H(T) = 0 as an exact identity rather than a numerical "
                "near-miss. Every step is an assertion, so the script fails loudly if any claim "
                "were false."
            ),
            "code": demo_exact,
        },
    ]

    visualizations = [
        {
            "name": "Convergence of Prime Type Densities and the Entropic Certificate",
            "description": (
                "A two-panel figure computed from the primes below 300000. The left panel traces "
                "the running frequency of each type T(p) = min{k >= 1 : p^k = +-1 mod 56} against "
                "the number of primes used, with the exact Chebotarev densities 1/12, 1/4, 1/6, "
                "1/2 drawn as dashed targets; all four curves lock onto their targets within a "
                "few thousandths. The right panel overlays the running empirical entropy H(T) and "
                "the running empirical mutual information I(p mod 56 ; T) — they coincide "
                "exactly, which is the vanishing pinning gap in visual form — together with the "
                "exact value 4/3 + (log2 3)/4 = 1.7296, the separation threshold 2, and the "
                "entropy 2.4183 of the cyclic group C12 that the measurement excludes."
            ),
            "code": read(ASSETS / "viz_convergence.py"),
        },
        {
            "name": "The Order-Profile Entropy as an Isomorphism Invariant",
            "description": (
                "A three-panel figure explaining why one number suffices. Panel A places the "
                "order profiles of the two abelian groups of order 12 side by side: C12 spreads "
                "its elements over six distinct orders with multiplicities 1,1,2,2,2,4, while "
                "C6 x C2 uses only four orders with multiplicities 1,3,2,6. Panel B puts the two "
                "resulting entropies on a single axis with the threshold 2 between them, and "
                "marks the value measured from prime remainders mod 56. Panel C computes the "
                "invariant for every abelian group of every order up to 24 and labels the "
                "multi-group orders, showing that no two abelian groups of the same order share "
                "a value in that range — evidence for the conjecture that the invariant is "
                "complete."
            ),
            "code": read(ASSETS / "viz_separation.py"),
        },
    ]

    interactive = [
        {
            "title": "The Conductor Laboratory — build the field, colour the residues, weigh the entropy",
            "description": (
                "A single-page, dependency-free laboratory that computes everything live in the "
                "browser. Choose a conductor f and the widget builds the reduced residues modulo "
                "f, colours each one by its type T(a) = min{k >= 1 : a^k = +-1} (revealing at a "
                "glance that a and -a always agree, which is why the type descends to the real "
                "field's symmetry group), tabulates the type census with exact densities and "
                "per-symbol bit contributions, and reports the output entropy H(T), the input "
                "entropy log2 phi(f), the mutual information, the identically vanishing pinning "
                "gap, the residual uncertainty and the channel efficiency. It then enumerates "
                "every abelian group of the corresponding degree, computes each one's "
                "order-profile entropy, and places them all on a shared axis beside the measured "
                "value — so the reader watches the measurement eliminate candidates in real time. "
                "Two further sections let the reader select a Frobenius class and see its "
                "translation orbits drawn explicitly (all of equal length, with f * g = degree "
                "displayed), and verify the semiprime pair law by brute-force enumeration over "
                "all phi(f)^2 ordered pairs. Selecting f = 56 shows 1.729574 bits and the "
                "non-cyclic group C6 x C2; switching to f = 35 shows 2.418296 bits and the cyclic "
                "group C12, making the separation theorem tangible. Progressive-disclosure panels "
                "hold the proofs of the pinning theorem and the separation bound."
            ),
            "html": read(ASSETS / "widget.html"),
        },
    ]

    return {
        "title": "Full Pinning at Degree 12: The Type Channel of the Real Cyclotomic Field "
                 "of Conductor 56 and the Entropic Detection of Non-Cyclicity",
        "domain": "Pythagorean",
        "description": (
            "The real cyclotomic field of conductor 56 has degree 12 with Galois group "
            "C6 x C2, the first composite-order non-cyclic rung of the abelian ladder; its "
            "prime splitting types form a deterministic channel of exactly "
            "4/3 + (log2 3)/4 = 1.7296 bits, and that single number lies below the threshold 2 "
            "that no cyclic group of order 12 can cross, so it certifies non-cyclicity."
        ),
        "authors": ["Aristotle"],
        "date": "2026-09-02",
        "key_results": [
            "The maximal real subfield of the 56th cyclotomic field has degree exactly 12 over "
            "the rationals, and its Galois group is the non-cyclic abelian group C6 x C2, "
            "exhibited explicitly through the basis 3, 13, -1 of the unit group modulo 56.",
            "The splitting type of an unramified prime, defined as the least k with p^k congruent "
            "to plus or minus 1 modulo 56, equals the order of its Frobenius class, and the four "
            "type densities 1/12, 1/4, 1/6, 1/2 coincide with the order statistics of C6 x C2 "
            "(the Chebotarev match).",
            "Full pinning: for any finite sample set and any deterministic channel the mutual "
            "information between a uniform input and its image equals the output entropy, so the "
            "pinning gap vanishes identically; at conductor 56 the transmitted information is "
            "exactly 4/3 + (log2 3)/4 bits, rigorously bracketed between 1.7295 and 1.7296, while "
            "the residual uncertainty 5/3 + (3/4) log2 3 stays strictly positive.",
            "Orbit purity and the decomposition law: translation orbits in a finite abelian group "
            "all have length equal to the order of the translating element, giving f times g "
            "equal to 12 with exactly the four shapes (1,12), (2,6), (3,4) and (6,2); and the "
            "translation-invariant pair law shows a product of two primes reproduces the prime "
            "type profile exactly, transmitting the same 1.7296 bits.",
            "Entropy separation at order twelve: the order-profile entropy of the cyclic group is "
            "5/6 + log2 3, exceeding 2, while that of C6 x C2 is 4/3 + (log2 3)/4, below 2, so a "
            "single measured real number certifies that the Galois group is not cyclic.",
        ],
        "keywords": [
            "real cyclotomic field",
            "residue degree",
            "Frobenius class",
            "Chebotarev density",
            "Shannon entropy",
            "mutual information",
            "abelian Galois group",
            "order profile",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": demo_main,
        "demos": demos,
        "algorithms": algorithms,
        "visualizations": visualizations,
        "interactive_demos": interactive,
        "interactive_layout": read(ASSETS / "interactive_layout.md"),
        "lean_proofs": lean_source(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo_main},
        "lean_files": LEAN_FILES,
    }


if __name__ == "__main__":
    package = build()
    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


"""
Exact-arithmetic verification of the entropy statements at conductor 56.

Nothing here is estimated. Each entropy is a rational number plus a rational
multiple of log2(3), so it is represented symbolically as a pair
(a, b) meaning  a + b * log2(3)  with a, b exact rationals. The script then:

  1. computes the type distribution of the 24 reduced residues mod 56 exactly;
  2. evaluates H(T) symbolically and checks it equals 4/3 + (1/4) log2 3;
  3. certifies the bracket 84/53 < log2 3 < 233/147 by exact integer comparison
     of 2**84 vs 3**53 and 3**147 vs 2**233 -- no floating point involved;
  4. deduces the rigorous numerical bracket 1.7295 < H(T) < 1.7296;
  5. computes the order-profile entropies of the two abelian groups of order 12
     symbolically and certifies H(C12) > 2 > H(C6 x C2);
  6. verifies the deterministic-channel identity I(X;T) = H(T) exactly, as a
     statement about counts rather than floats.

Run:  python3 demo_channel.py
"""

from __future__ import annotations

import math
from collections import Counter
from fractions import Fraction
from typing import Dict, List, Tuple

# A symbolic value a + b*log2(3), with a, b exact rationals.
Sym = Tuple[Fraction, Fraction]

LOG2_3_LOWER = Fraction(84, 53)
LOG2_3_UPPER = Fraction(233, 147)


def sym_add(x: Sym, y: Sym) -> Sym:
    return (x[0] + y[0], x[1] + y[1])


def sym_scale(c: Fraction, x: Sym) -> Sym:
    return (c * x[0], c * x[1])


def sym_str(x: Sym) -> str:
    a, b = x
    if b == 0:
        return f"{a}"
    return f"{a} + ({b}) * log2(3)"


def sym_bounds(x: Sym) -> Tuple[Fraction, Fraction]:
    """Rigorous rational lower and upper bounds for a + b*log2(3)."""
    a, b = x
    if b >= 0:
        return a + b * LOG2_3_LOWER, a + b * LOG2_3_UPPER
    return a + b * LOG2_3_UPPER, a + b * LOG2_3_LOWER


def sym_float(x: Sym) -> float:
    return float(x[0]) + float(x[1]) * math.log2(3)


def log2_sym(n: int) -> Sym:
    """log2(n) as a + b*log2(3) for n of the form 2^i * 3^j."""
    a = Fraction(0)
    b = Fraction(0)
    while n % 2 == 0:
        n //= 2
        a += 1
    while n % 3 == 0:
        n //= 3
        b += 1
    if n != 1:
        raise ValueError("only 3-smooth integers are representable here")
    return (a, b)


def entropy_sym(counts: Dict[int, int]) -> Sym:
    """Shannon entropy of a distribution whose probabilities are 1/x with x 3-smooth."""
    total = sum(counts.values())
    acc: Sym = (Fraction(0), Fraction(0))
    for c in counts.values():
        if c == 0:
            continue
        p = Fraction(c, total)
        # term = p * log2(1/p);  1/p must be 3-smooth
        inv = Fraction(1) / p
        if inv.denominator != 1:
            raise ValueError("probability is not the reciprocal of an integer")
        acc = sym_add(acc, sym_scale(p, log2_sym(inv.numerator)))
    return acc


def res_deg(a: int, m: int = 56) -> int:
    a %= m
    x = a
    for k in range(1, m + 1):
        if x == 1 or x == m - 1:
            return k
        x = (x * a) % m
    raise ValueError("not a unit")


def units(m: int) -> List[int]:
    return [a for a in range(m) if math.gcd(a, m) == 1]


def order_profile(factors: List[int]) -> Dict[int, int]:
    from itertools import product
    prof: Counter = Counter()
    for coords in product(*[range(n) for n in factors]):
        o = 1
        for x, n in zip(coords, factors):
            oi = n // math.gcd(x, n)
            o = o * oi // math.gcd(o, oi)
        prof[o] += 1
    return dict(sorted(prof.items()))


def main() -> None:
    print("STEP 1 — exact type census mod 56")
    counts = Counter(res_deg(a) for a in units(56))
    counts = dict(sorted(counts.items()))
    print(f"  counts {counts}, total {sum(counts.values())}")
    print("  densities " + ", ".join(f"T={t}: {Fraction(c, 24)}" for t, c in counts.items()))

    print("\nSTEP 2 — symbolic entropy of the type channel")
    H = entropy_sym(counts)
    print(f"  H(T) = {sym_str(H)}")
    assert H == (Fraction(4, 3), Fraction(1, 4)), "closed form mismatch"
    print("  matches the closed form 4/3 + (1/4) log2 3 : OK")

    print("\nSTEP 3 — certifying the bracket for log2 3 with exact integers")
    assert 2**84 < 3**53, "lower bracket fails"
    assert 3**147 < 2**233, "upper bracket fails"
    print(f"  2^84 < 3^53      : {2**84 < 3**53}   =>  log2 3 > 84/53  = {float(LOG2_3_LOWER):.8f}")
    print(f"  3^147 < 2^233    : {3**147 < 2**233}   =>  log2 3 < 233/147 = {float(LOG2_3_UPPER):.8f}")

    print("\nSTEP 4 — rigorous numerical bracket for H(T)")
    lo, hi = sym_bounds(H)
    print(f"  {float(lo):.7f} < H(T) < {float(hi):.7f}")
    assert lo > Fraction(17295, 10000) and hi < Fraction(17296, 10000)
    print("  hence 1.7295 < H(T) < 1.7296, i.e. H(T) = 1.7296 bits to four places : OK")

    print("\nSTEP 5 — order-profile entropies of the two abelian groups of order 12")
    for name, factors in (("C12", [12]), ("C6 x C2", [6, 2])):
        prof = order_profile(factors)
        Hg = entropy_sym(prof)
        lo_g, hi_g = sym_bounds(Hg)
        print(f"  {name:8s} profile {prof}")
        print(f"           H = {sym_str(Hg)} = {sym_float(Hg):.6f}   "
              f"bracket ({float(lo_g):.5f}, {float(hi_g):.5f})")
    H12 = entropy_sym(order_profile([12]))
    H62 = entropy_sym(order_profile([6, 2]))
    assert sym_bounds(H12)[0] > 2, "C12 should exceed 2 bits"
    assert sym_bounds(H62)[1] < 2, "C6 x C2 should fall below 2 bits"
    assert H62 == H, "the arithmetic channel and the group channel must agree"
    print("  certified: H(C12) > 2 > H(C6 x C2), and the arithmetic channel equals")
    print("  the group channel exactly, so 1.7296 bits rules out the cyclic group.")

    print("\nSTEP 6 — the deterministic-channel identity, exactly")
    # I(X;T) = sum over (x,t) of p(x,t) log2( p(x,t) / (p(x) p(t)) ).
    # For a deterministic channel p(x,t) = 1/24 on the graph, p(x) = 1/24, so each
    # term is (1/24) * log2(1 / p(t)); summing groups into H(T) exactly.
    total = 24
    I: Sym = (Fraction(0), Fraction(0))
    for a in units(56):
        t = res_deg(a)
        p_t = Fraction(counts[t], total)
        I = sym_add(I, sym_scale(Fraction(1, total), log2_sym((1 / p_t).numerator)))
    print(f"  I(X;T) = {sym_str(I)}")
    assert I == H, "mutual information must equal the output entropy"
    print("  I(X;T) - H(T) = 0 exactly : full pinning, with no floating-point slack.")

    print("\nAll exact checks passed.")


if __name__ == "__main__":
    main()


"""
Visualization: convergence of prime type statistics at conductor 56.

Left panel  -- the running frequency of each type T(p) = min{k >= 1 : p^k = +-1 mod 56}
               among the primes p <= N, plotted against N, with the exact Chebotarev
               densities 1/12, 1/4, 1/6, 1/2 drawn as horizontal targets.
Right panel -- the running Shannon entropy of the empirical type distribution and the
               running mutual information I(p mod 56 ; T), together with the exact value
               H(T) = 4/3 + (log2 3)/4 = 1.7295739... and the separation threshold 2,
               above which the cyclic group C12 would have to live.

The picture makes two points at once: the type densities converge to the order statistics
of C6 x C2, and the entropy curve settles below 2 -- the entropic certificate that the
Galois group of the degree-12 real cyclotomic field of conductor 56 is not cyclic.

Requires: matplotlib, numpy.  Run:  python3 viz_convergence.py
"""

from __future__ import annotations

import math
from collections import Counter
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt

MODULUS = 56
EXACT_H = 4 / 3 + math.log2(3) / 4
TARGETS: Dict[int, float] = {1: 1 / 12, 2: 1 / 4, 3: 1 / 6, 6: 1 / 2}
COLORS: Dict[int, str] = {1: "#e8a33d", 2: "#3d7fe8", 3: "#33b56e", 6: "#8a5fe0"}


def primes_up_to(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, int(n**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i in range(n + 1) if sieve[i]]


def res_deg(a: int, m: int = MODULUS) -> int:
    a %= m
    x = a
    for k in range(1, m + 1):
        if x == 1 or x == m - 1:
            return k
        x = (x * a) % m
    raise ValueError("not a unit")


def entropy(counts: Dict[int, int]) -> float:
    total = sum(counts.values())
    return -sum((c / total) * math.log2(c / total) for c in counts.values() if c)


def mutual_information(joint: Counter, n: int) -> float:
    px: Counter = Counter()
    py: Counter = Counter()
    for (x, y), c in joint.items():
        px[x] += c
        py[y] += c
    return sum((c / n) * math.log2((c / n) / ((px[x] / n) * (py[y] / n)))
               for (x, y), c in joint.items())


def run(limit: int = 300_000) -> Tuple[plt.Figure, plt.Axes]:
    ps = [p for p in primes_up_to(limit) if p not in (2, 7)]
    running: Counter = Counter()
    joint: Counter = Counter()
    xs: List[int] = []
    freqs: Dict[int, List[float]] = {t: [] for t in TARGETS}
    hs: List[float] = []
    mis: List[float] = []
    for i, p in enumerate(ps, start=1):
        t = res_deg(p)
        running[t] += 1
        joint[(p % MODULUS, t)] += 1
        if i % 25 == 0 or i == len(ps):
            xs.append(i)
            for tt in TARGETS:
                freqs[tt].append(running[tt] / i)
            hs.append(entropy(dict(running)))
            mis.append(mutual_information(joint, i))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    for t in sorted(TARGETS):
        ax1.plot(xs, freqs[t], color=COLORS[t], lw=1.4, label=f"type {t}")
        ax1.axhline(TARGETS[t], color=COLORS[t], ls="--", lw=1, alpha=0.6)
    ax1.set_xscale("log")
    ax1.set_xlabel("number of primes used")
    ax1.set_ylabel("empirical density")
    ax1.set_title("Type densities converge to 1/12, 1/4, 1/6, 1/2\n"
                  "(the order statistics of $C_6\\times C_2$)")
    ax1.legend(loc="center right", fontsize=9)
    ax1.grid(alpha=0.2)

    ax2.plot(xs, hs, color="#1b3a6b", lw=1.6, label="empirical $H(T)$")
    ax2.plot(xs, mis, color="#d1495b", lw=1.0, ls=":", label="empirical $I(p \\, \\mathrm{mod}\\, 56 ; T)$")
    ax2.axhline(EXACT_H, color="#2a9d8f", lw=1.4, ls="--",
                label=f"exact $4/3+(\\log_2 3)/4 = {EXACT_H:.4f}$")
    ax2.axhline(2.0, color="#8d99ae", lw=1.2, ls="-.",
                label="separation threshold 2")
    ax2.axhline(5 / 6 + math.log2(3), color="#9d4edd", lw=1.0, alpha=0.7,
                label=f"$H(C_{{12}}) = {5/6 + math.log2(3):.4f}$ (excluded)")
    ax2.set_xscale("log")
    ax2.set_ylim(1.5, 2.6)
    ax2.set_xlabel("number of primes used")
    ax2.set_ylabel("bits")
    ax2.set_title("Entropy of the type channel: pinned, and below 2")
    ax2.legend(loc="upper right", fontsize=8)
    ax2.grid(alpha=0.2)

    fig.suptitle("Conductor 56: prime types, Chebotarev densities and the entropic "
                 "certificate of non-cyclicity", fontsize=12)
    fig.tight_layout()
    return fig, (ax1, ax2)


if __name__ == "__main__":
    figure, _ = run()
    figure.savefig("type_convergence.png", dpi=150)
    print("wrote type_convergence.png")


"""
Visualization: the order-profile entropy as a discriminating invariant.

Panel A -- the order profiles of the two abelian groups of order 12 side by side:
           C12 spreads its 12 elements over six distinct orders (1,2,3,4,6,12) with
           multiplicities 1,1,2,2,2,4, while C6 x C2 uses only four orders (1,2,3,6)
           with multiplicities 1,3,2,6.
Panel B -- the resulting entropies on a single axis, with the threshold 2 between them:
           H(C12) = 5/6 + log2 3 = 2.41830...  >  2  >  1.72957... = 4/3 + (log2 3)/4
           = H(C6 x C2), the value measured from prime remainders mod 56.
Panel C -- the same invariant computed for every abelian group of every order up to 24,
           showing how often the invariant already separates the groups of a given order.

Requires: matplotlib.  Run:  python3 viz_separation.py
"""

from __future__ import annotations

import math
from collections import Counter
from itertools import product
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt


def partitions(n: int, largest: int | None = None) -> List[List[int]]:
    if largest is None:
        largest = n
    if n == 0:
        return [[]]
    out: List[List[int]] = []
    for k in range(min(n, largest), 0, -1):
        for rest in partitions(n - k, k):
            out.append([k] + rest)
    return out


def factorize(n: int) -> Dict[int, int]:
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def abelian_groups(n: int) -> List[List[int]]:
    """All abelian groups of order n, as lists of cyclic prime-power factors."""
    groups: List[List[int]] = [[]]
    for p, e in factorize(n).items():
        new: List[List[int]] = []
        for part in partitions(e):
            factors = [p**k for k in part]
            new.extend(g + factors for g in groups)
        groups = new
    return groups


def invariant_factor_name(factors: List[int]) -> str:
    by_prime: Dict[int, List[int]] = {}
    for q in factors:
        p = next(iter(factorize(q)))
        by_prime.setdefault(p, []).append(q)
    for p in by_prime:
        by_prime[p].sort(reverse=True)
    width = max((len(v) for v in by_prime.values()), default=0)
    inv: List[int] = []
    for i in range(width):
        d = 1
        for p, qs in by_prime.items():
            if i < len(qs):
                d *= qs[i]
        inv.append(d)
    inv.sort()
    return " x ".join(f"C{d}" for d in inv) if inv else "C1"


def order_profile(factors: List[int]) -> Dict[int, int]:
    prof: Counter = Counter()
    for coords in product(*[range(m) for m in factors]):
        order = 1
        for x, m in zip(coords, factors):
            o = m // math.gcd(x, m)
            order = order * o // math.gcd(order, o)
        prof[order] += 1
    return dict(sorted(prof.items()))


def profile_entropy(prof: Dict[int, int]) -> float:
    total = sum(prof.values())
    return -sum((c / total) * math.log2(c / total) for c in prof.values() if c)


def run() -> plt.Figure:
    fig = plt.figure(figsize=(13, 8.5))
    gs = fig.add_gridspec(2, 2, height_ratios=[1.0, 1.1], hspace=0.42, wspace=0.28)

    # --- Panel A: the two profiles at order 12 -------------------------------
    axA = fig.add_subplot(gs[0, 0])
    groups12 = [(invariant_factor_name(g), order_profile(g)) for g in abelian_groups(12)]
    orders = sorted({d for _, prof in groups12 for d in prof})
    width = 0.38
    for i, (name, prof) in enumerate(groups12):
        xs = [j + (i - 0.5) * width for j in range(len(orders))]
        ys = [prof.get(d, 0) for d in orders]
        axA.bar(xs, ys, width=width, label=f"{name}   H = {profile_entropy(prof):.4f}",
                color=["#d1495b", "#2a9d8f"][i], alpha=0.9)
    axA.set_xticks(range(len(orders)))
    axA.set_xticklabels(orders)
    axA.set_xlabel("element order $d$")
    axA.set_ylabel("number of elements")
    axA.set_title("A.  Order profiles of the two abelian groups of order 12")
    axA.legend(fontsize=9)
    axA.grid(alpha=0.2, axis="y")

    # --- Panel B: the separation axis ---------------------------------------
    axB = fig.add_subplot(gs[0, 1])
    h_cyc = 5 / 6 + math.log2(3)
    h_non = 4 / 3 + math.log2(3) / 4
    axB.hlines(0, 1.5, 2.7, color="#333", lw=1.5)
    axB.vlines(2.0, -0.25, 0.25, color="#8d99ae", lw=2, linestyles="-.")
    axB.plot([h_non], [0], "o", ms=14, color="#2a9d8f")
    axB.plot([h_cyc], [0], "o", ms=14, color="#d1495b")
    axB.annotate(f"$C_6\\times C_2$\n$4/3+(\\log_2 3)/4 = {h_non:.5f}$",
                 (h_non, 0), textcoords="offset points", xytext=(-10, 52),
                 ha="center", fontsize=10, color="#2a9d8f")
    axB.annotate(f"$C_{{12}}$\n$5/6+\\log_2 3 = {h_cyc:.5f}$",
                 (h_cyc, 0), textcoords="offset points", xytext=(0, -48),
                 ha="center", fontsize=10, color="#d1495b")
    axB.annotate("threshold 2", (2.0, 0), textcoords="offset points", xytext=(0, 20),
                 ha="center", fontsize=9, color="#8d99ae")
    axB.annotate("measured from prime\nremainders mod 56", (h_non, 0),
                 textcoords="offset points", xytext=(-70, -46), ha="center",
                 fontsize=9, color="#444",
                 arrowprops=dict(arrowstyle="->", color="#888", lw=1))
    axB.set_xlim(1.5, 2.7)
    axB.set_ylim(-0.9, 0.9)
    axB.set_yticks([])
    axB.set_xlabel("order-profile entropy (bits)")
    axB.set_title("B.  A single number decides the isomorphism class")

    # --- Panel C: the invariant across small orders --------------------------
    axC = fig.add_subplot(gs[1, :])
    xs: List[float] = []
    ys: List[float] = []
    labels: List[Tuple[float, float, str]] = []
    separated: List[int] = []
    collided: List[int] = []
    for n in range(2, 25):
        ents = []
        for g in abelian_groups(n):
            prof = order_profile(g)
            h = profile_entropy(prof)
            ents.append(h)
            xs.append(n)
            ys.append(h)
            if len(abelian_groups(n)) > 1:
                labels.append((n, h, invariant_factor_name(g)))
        rounded = [round(e, 9) for e in ents]
        if len(set(rounded)) == len(rounded):
            separated.append(n)
        else:
            collided.append(n)
    axC.scatter(xs, ys, s=42, color="#1b3a6b", alpha=0.75, zorder=3)
    for n, h, name in labels:
        axC.annotate(name, (n, h), textcoords="offset points", xytext=(6, -3),
                     fontsize=7, color="#555")
    axC.scatter([12], [4 / 3 + math.log2(3) / 4], s=170, facecolors="none",
                edgecolors="#2a9d8f", lw=2.2, zorder=4,
                label="the conductor-56 rung")
    axC.set_xticks(range(2, 25))
    axC.set_xlabel("group order $n$")
    axC.set_ylabel("order-profile entropy (bits)")
    collision_note = ("no two abelian groups of the same order share a value"
                      if not collided else f"orders with a collision: {collided}")
    axC.set_title("C.  The invariant for every abelian group of order at most 24 — "
                  + collision_note)
    axC.grid(alpha=0.2)
    axC.legend(fontsize=9, loc="upper left")

    fig.suptitle("The order-profile entropy as an isomorphism invariant", fontsize=13)
    return fig


if __name__ == "__main__":
    figure = run()
    figure.savefig("entropy_separation.png", dpi=150, bbox_inches="tight")
    print("wrote entropy_separation.png")


"""
Degree-12 rung of the abelian ladder: the real cyclotomic field of conductor 56.

This self-contained script demonstrates, numerically, every result of the
accompanying paper:

  1.  The reduced residues mod 56 form a group of order phi(56) = 24, isomorphic
      to C6 x C2 x C2 with basis {3, 13, -1}.
  2.  Quotienting by {+-1} gives the Galois group G+ of the real cyclotomic field
      Q(zeta_56)^+ = Q(zeta_56 + zeta_56^{-1}), of order 12 and isomorphic to
      C6 x C2 -- an abelian group of composite order that is NOT cyclic.
  3.  The "type" (residue degree) T(a) = min{k >= 1 : a^k = +-1 mod 56} takes the
      values 1, 2, 3, 6 with densities 1/12, 1/4, 1/6, 1/2, matching exactly the
      order statistics of C6 x C2 (Chebotarev match).
  4.  Full pinning: I(a mod 56 ; T) = H(T) = 4/3 + (log2 3)/4 = 1.72957... bits,
      with pinning gap identically zero, while H(a mod 56 | T) > 0.
  5.  Orbit purity and the efg law: every Frobenius orbit on the 12 cosets has
      length f = T(p), and f * g = 12 with (f,g) in {(1,12),(2,6),(3,4),(6,2)}.
  6.  The semiprime pair law: #{(u,v) : T(uv) = t} = 24 * #{w : T(w) = t}, so the
      product of two primes carries exactly the same 1.72957 bits.
  7.  Entropy separation at order 12: H(C12) = 5/6 + log2 3 = 2.41830... > 2 >
      1.72957... = H(C6 x C2), so the single measured number certifies
      non-cyclicity.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from collections import Counter
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple

MODULUS: int = 56
DEGREE: int = 12  # [Q(zeta_56)^+ : Q]

# --------------------------------------------------------------------------- #
# 1. The reduced residues mod 56
# --------------------------------------------------------------------------- #


def reduced_residues(m: int) -> List[int]:
    """All a in [0, m) with gcd(a, m) = 1 -- the unit group of Z/mZ."""
    return [a for a in range(m) if math.gcd(a, m) == 1]


def multiplicative_order(a: int, m: int) -> int:
    """Least k >= 1 with a^k = 1 (mod m)."""
    k, x = 1, a % m
    while x != 1 % m:
        x = (x * a) % m
        k += 1
    return k


def group_exponent(m: int) -> int:
    """lcm of the orders of all units mod m."""
    e = 1
    for a in reduced_residues(m):
        e = e * multiplicative_order(a, m) // math.gcd(e, multiplicative_order(a, m))
    return e


# --------------------------------------------------------------------------- #
# 2. The type (residue degree) channel
# --------------------------------------------------------------------------- #


def res_deg(a: int, m: int = MODULUS) -> int:
    """Type of a: least k >= 1 with a^k = +-1 (mod m).

    For a prime p not dividing m this is the residue degree of p in the real
    cyclotomic field Q(zeta_m)^+, i.e. the order of the Frobenius class of p in
    G+ = (Z/mZ)^* / {+-1}.
    """
    a %= m
    x = a
    for k in range(1, m + 1):
        if x == 1 % m or x == (m - 1) % m:
            return k
        x = (x * a) % m
    raise ValueError(f"{a} is not a unit mod {m}")


def type_profile(m: int = MODULUS) -> Dict[int, int]:
    """Counts of each type among the reduced residues mod m."""
    return dict(sorted(Counter(res_deg(a, m) for a in reduced_residues(m)).items()))


# --------------------------------------------------------------------------- #
# 3. The basis 3, 13, -1 of (Z/56)^*
# --------------------------------------------------------------------------- #


def basis_map(i: int, j: int, k: int, m: int = MODULUS) -> int:
    """(i, j, k) in C6 x C2 x C2  |-->  3^i * 13^j * (-1)^k mod m."""
    return (pow(3, i, m) * pow(13, j, m) * pow(-1, k, m)) % m


def check_basis(m: int = MODULUS) -> Tuple[bool, bool]:
    """Injectivity and surjectivity of the basis map onto the reduced residues."""
    values = [basis_map(i, j, k, m) for i in range(6) for j in range(2) for k in range(2)]
    injective = len(set(values)) == len(values)
    onto = set(values) == set(reduced_residues(m))
    return injective, onto


def cls(i: int, j: int, m: int = MODULUS) -> int:
    """The C6 x C2 part of the basis: (i, j) |-> 3^i * 13^j mod m."""
    return (pow(3, i, m) * pow(13, j, m)) % m


# --------------------------------------------------------------------------- #
# 4. Finite information calculus
# --------------------------------------------------------------------------- #


def shannon_entropy(counts: Iterable[int]) -> float:
    """Shannon entropy, in bits, of the empirical distribution given by counts."""
    cs = [c for c in counts if c > 0]
    total = sum(cs)
    return -sum((c / total) * math.log2(c / total) for c in cs)


def mutual_information(pairs: Sequence[Tuple[int, int]]) -> float:
    """I(X ; Y) in bits for a finite sample of (x, y) pairs."""
    n = len(pairs)
    px = Counter(x for x, _ in pairs)
    py = Counter(y for _, y in pairs)
    pxy = Counter(pairs)
    total = 0.0
    for (x, y), c in pxy.items():
        total += (c / n) * math.log2((c / n) / ((px[x] / n) * (py[y] / n)))
    return total


# --------------------------------------------------------------------------- #
# 5. Abelian group order profiles
# --------------------------------------------------------------------------- #


def order_profile_cyclic(n: int) -> Dict[int, int]:
    """Counts of element orders in the cyclic group C_n."""
    return dict(sorted(Counter(n // math.gcd(x, n) for x in range(n)).items()))


def order_profile_c6xc2() -> Dict[int, int]:
    """Counts of element orders in C6 x C2."""
    def order(i: int, j: int) -> int:
        oi = 6 // math.gcd(i, 6) if i else 1
        oj = 2 // math.gcd(j, 2) if j else 1
        return oi * oj // math.gcd(oi, oj)

    return dict(sorted(Counter(order(i, j) for i in range(6) for j in range(2)).items()))


# --------------------------------------------------------------------------- #
# 6. Frobenius orbits and the efg law
# --------------------------------------------------------------------------- #


def frobenius_orbits(g: Tuple[int, int]) -> List[List[Tuple[int, int]]]:
    """Orbits of translation by g on C6 x C2 (the 12 cosets of Q(zeta_56)^+)."""
    elements = [(i, j) for i in range(6) for j in range(2)]
    seen: set = set()
    orbits: List[List[Tuple[int, int]]] = []
    for x in elements:
        if x in seen:
            continue
        orbit, y = [], x
        while y not in seen:
            seen.add(y)
            orbit.append(y)
            y = ((y[0] + g[0]) % 6, (y[1] + g[1]) % 2)
        orbits.append(orbit)
    return orbits


# --------------------------------------------------------------------------- #
# 7. Primes
# --------------------------------------------------------------------------- #


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, int(n**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i in range(n + 1) if sieve[i]]


def permutation_test(pairs: Sequence[Tuple[int, int]], trials: int = 2000,
                     seed: int = 20261060) -> Tuple[float, float, float]:
    """Label-shuffling test for the residue -> type channel.

    Returns (observed I, mean of shuffled I, z-score).
    """
    rng = random.Random(seed)
    observed = mutual_information(pairs)
    xs = [x for x, _ in pairs]
    ys = [y for _, y in pairs]
    null: List[float] = []
    for _ in range(trials):
        rng.shuffle(ys)
        null.append(mutual_information(list(zip(xs, ys))))
    mu = sum(null) / len(null)
    var = sum((v - mu) ** 2 for v in null) / len(null)
    sigma = math.sqrt(var) if var > 0 else 0.0
    z = (observed - mu) / sigma if sigma > 0 else float("inf")
    return observed, mu, z


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #


def demo_unit_group() -> None:
    print("=" * 72)
    print("1.  The unit group mod 56 and the basis {3, 13, -1}")
    print("=" * 72)
    units = reduced_residues(MODULUS)
    print(f"  #(Z/56)^*            = {len(units)}   (= phi(56) = 24)")
    print(f"  exponent             = {group_exponent(MODULUS)}   (so a^6 = 1 for every unit)")
    print(f"  ord(3) = {multiplicative_order(3, MODULUS)},  "
          f"ord(13) = {multiplicative_order(13, MODULUS)},  "
          f"ord(-1) = {multiplicative_order(55, MODULUS)}")
    inj, onto = check_basis()
    print(f"  (i,j,k) -> 3^i 13^j (-1)^k  injective: {inj},  onto the units: {onto}")
    print("  => (Z/56)^* = C6 x C2 x C2, and G+ = (Z/56)^*/{+-1} = C6 x C2, order 12.")
    print()


def demo_type_densities() -> None:
    print("=" * 72)
    print("2.  Type densities and the Chebotarev match")
    print("=" * 72)
    prof = type_profile()
    print("   type t   #residues   density   #elements of order t in C6 x C2")
    for t, c in prof.items():
        print(f"     {t:>2}       {c:>3}       {str(Fraction(c, 24)):>5}"
              f"                {order_profile_c6xc2()[t]:>3}")
    print(f"  total = {sum(prof.values())} = 24;  "
          f"count(t) = 2 * #{{g in C6 x C2 : ord(g) = t}} for every t: "
          f"{all(prof[t] == 2 * order_profile_c6xc2()[t] for t in prof)}")
    print()


def demo_entropy() -> None:
    print("=" * 72)
    print("3.  Full pinning: I(a mod 56 ; T) = H(T), gap 0")
    print("=" * 72)
    units = reduced_residues(MODULUS)
    pairs = [(a, res_deg(a)) for a in units]
    h_out = shannon_entropy(Counter(t for _, t in pairs).values())
    h_in = math.log2(len(units))
    info = mutual_information(pairs)
    closed = 4 / 3 + math.log2(3) / 4
    print(f"  H(X)   = log2 24                = {h_in:.6f} bits")
    print(f"  H(T)   = 4/3 + (log2 3)/4       = {h_out:.6f}  (closed form {closed:.6f})")
    print(f"  I(X;T)                          = {info:.6f} bits")
    print(f"  pinning gap H(T) - I(X;T)       = {abs(h_out - info):.3e}  (exactly 0)")
    print(f"  H(X|T) = 5/3 + (3/4) log2 3     = {h_in - h_out:.6f} bits  (channel is lossy)")
    print(f"  rounded to four decimals: H(T) = {h_out:.4f} bits")
    print()


def demo_pinning_on_primes(limit: int = 200000) -> None:
    print("=" * 72)
    print(f"4.  The same on actual primes below {limit}")
    print("=" * 72)
    ps = [p for p in primes_up_to(limit) if p not in (2, 7)]
    pairs = [(p % MODULUS, res_deg(p)) for p in ps]
    h_out = shannon_entropy(Counter(t for _, t in pairs).values())
    info = mutual_information(pairs)
    print(f"  primes used                     : {len(ps)}")
    emp = Counter(t for _, t in pairs)
    print("   type t   empirical density   Chebotarev density")
    for t in (1, 2, 3, 6):
        print(f"     {t:>2}          {emp[t]/len(ps):.5f}              "
              f"{float(Fraction(type_profile()[t], 24)):.5f}")
    print(f"  H(T) empirical                  = {h_out:.6f} bits")
    print(f"  I(p mod 56 ; T) empirical       = {info:.6f} bits")
    print(f"  gap                             = {abs(h_out - info):.3e}")
    obs, mu, z = permutation_test(pairs[:4000], trials=400)
    print(f"  label-shuffling test on a sample: I_obs = {obs:.4f}, "
          f"I_null = {mu:.4f}, z = {z:.1f}")
    print()


def demo_efg() -> None:
    print("=" * 72)
    print("5.  Orbit purity and the efg law  (e = 1, f * g = 12)")
    print("=" * 72)
    print("   Frobenius class g   f = orbit length   g = #orbits   f * g")
    seen = set()
    for i in range(6):
        for j in range(2):
            orbits = frobenius_orbits((i, j))
            f = len(orbits[0])
            pure = all(len(o) == f for o in orbits)
            assert pure, "orbits are not all the same length"
            assert f == res_deg(cls(i, j)), "orbit length differs from the type"
            key = (f, len(orbits))
            if key not in seen:
                seen.add(key)
            print(f"      ({i},{j})                {f:>2}               "
                  f"{len(orbits):>2}          {f * len(orbits):>2}")
    print(f"  distinct splitting shapes (f, g): {sorted(seen)}")
    print()


def demo_semiprimes() -> None:
    print("=" * 72)
    print("6.  The semiprime pair channel")
    print("=" * 72)
    units = reduced_residues(MODULUS)
    pair_counts: Counter = Counter()
    for u in units:
        for v in units:
            pair_counts[res_deg(u * v)] += 1
    single = type_profile()
    print("   type t   #pairs (u,v) with T(uv)=t   24 * #{w : T(w)=t}")
    for t in sorted(single):
        print(f"     {t:>2}              {pair_counts[t]:>4}                      "
              f"{24 * single[t]:>4}")
    print(f"  exact enumeration law holds: "
          f"{all(pair_counts[t] == 24 * single[t] for t in single)}")
    h_pair = shannon_entropy(pair_counts.values())
    print(f"  H(T on semiprimes) = {h_pair:.6f} bits = H(T on primes)")
    print()


def demo_separation() -> None:
    print("=" * 72)
    print("7.  Entropy separates the two abelian groups of order 12")
    print("=" * 72)
    p12 = order_profile_cyclic(12)
    p62 = order_profile_c6xc2()
    h12 = shannon_entropy(p12.values())
    h62 = shannon_entropy(p62.values())
    print(f"  C12     order profile {p12}")
    print(f"          H = 5/6 + log2 3        = {h12:.6f} bits  (> 2)")
    print(f"  C6xC2   order profile {p62}")
    print(f"          H = 4/3 + (log2 3)/4    = {h62:.6f} bits  (< 2)")
    print(f"  separation |H(C12) - H(C6xC2)|  = {abs(h12 - h62):.6f} bits")
    print("  A measured value below 2 bits is impossible for C12: the number")
    print("  1.7296 alone certifies that the Galois group is non-cyclic.")
    print()


def demo_selection_rule() -> None:
    print("=" * 72)
    print("8.  Why conductor 56?  The ten conductors with phi(f) = 24")
    print("=" * 72)
    print("    f    phi(f)   deg Q(zeta_f)^+   exponent of G+   cyclic?   note")
    for f in range(3, 200):
        if len(reduced_residues(f)) != 24:
            continue
        units = reduced_residues(f)
        deg = len({min(a, f - a) for a in units})
        exponent = 1
        for a in units:
            o = res_deg(a, f)
            exponent = exponent * o // math.gcd(exponent, o)
        cyclic = exponent == deg
        note = f"same field as f = {f // 2}" if f % 4 == 2 else ""
        print(f"   {f:>3}     24          {deg:>2}               {exponent:>2}"
              f"            {'yes' if cyclic else 'NO'}      {note}")
    print("  Ten conductors satisfy phi(f) = 24; conductor 56 is the smallest whose")
    print("  degree-12 real Galois group fails to be cyclic.")
    print()


def main() -> None:
    demo_unit_group()
    demo_type_densities()
    demo_entropy()
    demo_pinning_on_primes()
    demo_efg()
    demo_semiprimes()
    demo_separation()
    demo_selection_rule()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
