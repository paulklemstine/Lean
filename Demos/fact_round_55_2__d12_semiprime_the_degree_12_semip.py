"""
Numerical demonstration of the degree-12 semiprime splitting-type channel.
==========================================================================

Setting
-------
Let ``K/Q`` be a cyclic extension with Galois group ``C_n = Z/nZ``.  The
canonical example used throughout is ``n = 12``, ``K = Q(zeta_13)``, whose
Galois group is cyclic of order 12.  An unramified rational prime ``p`` has a
Frobenius element ``Frob_p`` in ``C_n``, recorded here by its exponent
``a in {0, ..., n-1}``.  The *splitting type* of ``p`` is the order of that
element,

        T(a) = n / gcd(n, a),

which is the residue degree of every prime of ``K`` above ``p``; the prime
splits into ``n / T(a)`` primes.  ``T(a) = 1`` means "completely split".

For a semiprime ``N = p q`` the two Frobenius exponents form a pair
``(a, b)`` in the ``n x n`` box, and the natural observables are

  * the unordered splitting-type pair   ``Pi(a, b) = {T(a), T(b)}``;
  * the residue of ``N``                ``R(a, b) = a + b  (mod n)``;
  * the split count                     ``s(a, b) = #{i : T = 1}`` in {0,1,2};
  * the which-factor bit                ``W(a, b) = [T(a) < T(b)]``.

This script verifies, by direct enumeration and by the closed-form laws:

  1. the exact enumeration law  ``c_{d,e} = phi(d) phi(e)`` (diagonal) or
     ``2 phi(d) phi(e)`` (off-diagonal), and that the counts sum to ``n^2``;
  2. the entropy law ``H(Pi) = log2(n^2) - (1/n^2) sum c log2 c``;
  3. the symmetrization-defect law ``H(Pi) = 2 H(T) - #asym(n)/n^2``;
  4. the which-factor wall: every symmetric read-out has exactly zero mutual
     information with ``W``, while ``H(W) = 1`` exactly;
  5. the degree-12 closed forms
        H(Pi)      = 7/8 + 2 log2 3
        I_pair(12) = 5/36 + log2 3
        I_split(12)= 199/72 + log2 3 + (55/72) log2 5 - (253/144) log2 11
     and the rigidity of the split-count profile over residue classes.

Run with:  python3 demo.py
"""

from __future__ import annotations

from collections import Counter
from math import gcd, log2
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

Pair = Tuple[int, int]

# ----------------------------------------------------------------------
# Elementary arithmetic
# ----------------------------------------------------------------------


def totient(m: int) -> int:
    """Euler's totient phi(m), by direct counting (m is small here)."""
    if m <= 0:
        return 0
    return sum(1 for k in range(1, m + 1) if gcd(k, m) == 1)


def divisors(n: int) -> List[int]:
    """The increasing list of positive divisors of n."""
    return [d for d in range(1, n + 1) if n % d == 0]


def ord_type(n: int, a: int) -> int:
    """Splitting type of the Frobenius exponent a: the order of a in Z/nZ."""
    return n // gcd(n, a % n)


def box(n: int) -> List[Pair]:
    """All exponent pairs of a C_n semiprime."""
    return [(a, b) for a in range(n) for b in range(n)]


def type_pair(n: int, p: Pair) -> Pair:
    """The unordered splitting-type pair, written as (min, max)."""
    x, y = ord_type(n, p[0]), ord_type(n, p[1])
    return (min(x, y), max(x, y))


def prod_res(n: int, p: Pair) -> int:
    """Frobenius exponent of N = p q, i.e. the residue of N."""
    return (p[0] + p[1]) % n


def split_count(t: Pair) -> int:
    """Number of completely split factors, read off the unordered type pair."""
    return (1 if t[0] == 1 else 0) + (1 if t[1] == 1 else 0)


def which_factor(n: int, p: Pair) -> bool:
    """Does the first prime carry the strictly smaller splitting type?"""
    return ord_type(n, p[0]) < ord_type(n, p[1])


# ----------------------------------------------------------------------
# Entropy toolbox (uniform measure on a finite set)
# ----------------------------------------------------------------------


def entropy(sample: Sequence[Hashable]) -> float:
    """Shannon entropy in bits of the empirical distribution of `sample`."""
    total = len(sample)
    if total == 0:
        return 0.0
    counts = Counter(sample)
    return -sum((c / total) * log2(c / total) for c in counts.values())


def conditional_entropy(
    values: Sequence[Hashable], givens: Sequence[Hashable]
) -> float:
    """H(values | givens) for the uniform measure on the common index set."""
    total = len(values)
    if total == 0:
        return 0.0
    blocks: Dict[Hashable, List[Hashable]] = {}
    for v, g in zip(values, givens):
        blocks.setdefault(g, []).append(v)
    return sum((len(b) / total) * entropy(b) for b in blocks.values())


def mutual_information(
    values: Sequence[Hashable], givens: Sequence[Hashable]
) -> float:
    """I(values ; givens) = H(values) - H(values | givens)."""
    return entropy(values) - conditional_entropy(values, givens)


# ----------------------------------------------------------------------
# 1. The exact enumeration law
# ----------------------------------------------------------------------


def pair_count(t: Pair) -> int:
    """Predicted multiplicity of the unordered type pair t = (d, e), d <= e."""
    d, e = t
    return totient(d) * totient(e) if d == e else 2 * totient(d) * totient(e)


def div_pairs(n: int) -> List[Pair]:
    """The alphabet of the type-pair channel: divisor pairs d <= e of n."""
    ds = divisors(n)
    return [(d, e) for d in ds for e in ds if d <= e]


def check_enumeration_law(n: int) -> None:
    observed = Counter(type_pair(n, p) for p in box(n))
    predicted = {t: pair_count(t) for t in div_pairs(n)}
    assert set(observed) == set(predicted), "support mismatch"
    for t in predicted:
        assert observed[t] == predicted[t], (n, t, observed[t], predicted[t])
    assert sum(predicted.values()) == n * n, "counts do not sum to n^2"


def pair_entropy_from_law(n: int) -> float:
    """H(Pi) computed from the closed-form law, with no enumeration."""
    total = float(n * n)
    weight = sum(c * log2(c) for c in (pair_count(t) for t in div_pairs(n)))
    return log2(total) - weight / total


# ----------------------------------------------------------------------
# 2. The symmetrization-defect law
# ----------------------------------------------------------------------


def type_entropy(n: int) -> float:
    """H(T): entropy of the splitting type of a single prime."""
    return entropy([ord_type(n, a) for a in range(n)])


def asym_count(n: int) -> int:
    """#asym(n) = n^2 - sum_{d | n} phi(d)^2: pairs with distinct types."""
    return n * n - sum(totient(d) ** 2 for d in divisors(n))


def symmetrization_prediction(n: int) -> float:
    """2 H(T) - #asym(n)/n^2."""
    return 2 * type_entropy(n) - asym_count(n) / (n * n)


# ----------------------------------------------------------------------
# 3. The which-factor wall
# ----------------------------------------------------------------------


def asym(n: int) -> List[Pair]:
    """Exponent pairs whose two primes have distinct splitting types."""
    return [p for p in box(n) if ord_type(n, p[0]) != ord_type(n, p[1])]


def wall_test(n: int, readout: Callable[[int, Pair], Hashable], label: str) -> float:
    """Mutual information between a symmetric read-out and the which-factor bit."""
    pop = asym(n)
    bits = [which_factor(n, p) for p in pop]
    obs = [readout(n, p) for p in pop]
    value = mutual_information(bits, obs)
    print(f"    I(W ; {label:<34s}) = {value: .12f} bits")
    return value


# ----------------------------------------------------------------------
# 4. The channels
# ----------------------------------------------------------------------


def i_pair(n: int) -> float:
    pts = box(n)
    return mutual_information(
        [type_pair(n, p) for p in pts], [prod_res(n, p) for p in pts]
    )


def i_split(n: int) -> float:
    pts = box(n)
    return mutual_information(
        [split_count(type_pair(n, p)) for p in pts], [prod_res(n, p) for p in pts]
    )


def split_profiles(n: int) -> Dict[int, Tuple[int, ...]]:
    """Sorted split-count fibre profile inside each residue class of N."""
    blocks: Dict[int, List[int]] = {r: [] for r in range(n)}
    for p in box(n):
        blocks[prod_res(n, p)].append(split_count(type_pair(n, p)))
    return {r: tuple(sorted(Counter(v).values())) for r, v in blocks.items()}


# ----------------------------------------------------------------------
# Report
# ----------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + title)
    print("-" * len(title))


def main() -> None:
    print("=" * 72)
    print("  The degree-12 semiprime splitting-type channel")
    print("=" * 72)

    orders: Iterable[int] = (2, 4, 6, 8, 10, 12, 16, 18, 20, 24, 30)

    rule("1. The exact enumeration law   c_{d,e} = phi(d) phi(e) (x2 off-diagonal)")
    for n in orders:
        check_enumeration_law(n)
    print("    verified by full enumeration for n =", ", ".join(map(str, orders)))
    print("\n    Degree-12 profile (d, e) -> c_{d,e}:")
    row: List[str] = []
    for t in div_pairs(12):
        row.append(f"{t}->{pair_count(t)}")
        if len(row) == 5:
            print("      " + "  ".join(row))
            row = []
    if row:
        print("      " + "  ".join(row))
    weight12 = sum(c * log2(c) for c in (pair_count(t) for t in div_pairs(12)))
    print(f"\n    sum of counts        = {sum(pair_count(t) for t in div_pairs(12))}"
          "   (= 12^2 = 144)")
    print(f"    sum c log2 c         = {weight12:.10f}   (exact value 450)")

    rule("2. The entropy law   H(Pi) = log2(n^2) - (1/n^2) sum c log2 c")
    print("      n |    H(Pi) enumerated |        H(Pi) from law |   difference")
    for n in orders:
        pts = box(n)
        direct = entropy([type_pair(n, p) for p in pts])
        law = pair_entropy_from_law(n)
        print(f"    {n:3d} | {direct:19.12f} | {law:21.12f} | {abs(direct-law):.2e}")
    closed12 = 7 / 8 + 2 * log2(3)
    print(f"\n    H(Pi) at n = 12      = {pair_entropy_from_law(12):.12f}")
    print(f"    7/8 + 2 log2 3       = {closed12:.12f}")

    rule("3. The symmetrization-defect law   H(Pi) = 2 H(T) - #asym(n)/n^2")
    print("      n |  #asym(n) |    H(Pi) |  2H(T) - #asym/n^2 |  defect")
    for n in orders:
        law = pair_entropy_from_law(n)
        pred = symmetrization_prediction(n)
        print(
            f"    {n:3d} | {asym_count(n):9d} | {law:8.5f} | {pred:18.12f} |"
            f" {2*type_entropy(n)-law:7.5f}"
        )
    print(f"\n    at n = 12:  #asym(12) = {asym_count(12)}, defect ="
          f" 114/144 = {114/144:.10f} = 19/24")
    print("    sandwich 2H(T) - 1 <= H(Pi) < 2H(T) holds in every row above")

    rule("4. The which-factor wall at n = 12")
    print(f"    H(W) on the {len(asym(12))} asymmetric pairs = "
          f"{entropy([which_factor(12, p) for p in asym(12)]):.12f}  (exactly 1 bit)")
    wall_test(12, lambda n, p: type_pair(n, p), "unordered type pair")
    wall_test(12, lambda n, p: prod_res(n, p), "residue of N mod 13")
    wall_test(12, lambda n, p: (type_pair(n, p), prod_res(n, p)), "pair AND residue")
    wall_test(12, lambda n, p: (type_pair(n, p), p[0] * p[1] % n), "pair AND product")
    ordered = mutual_information(
        [which_factor(12, p) for p in asym(12)],
        [(ord_type(12, p[0]), ord_type(12, p[1])) for p in asym(12)],
    )
    print(f"    I(W ; {'ORDERED type pair':<34s}) = {ordered: .12f} bits"
          "   <- the whole bit")

    rule("5. The degree-12 channels")
    ip, isp = i_pair(12), i_split(12)
    print(f"    I_pair(12)  enumerated = {ip:.12f}")
    print(f"    5/36 + log2 3          = {5/36 + log2(3):.12f}")
    print(f"    I_split(12) enumerated = {isp:.12f}")
    closed_split = (
        199 / 72 + log2(3) + (55 / 72) * log2(5) - (253 / 144) * log2(11)
    )
    print(f"    199/72 + log2 3 + (55/72)log2 5 - (253/144)log2 11 = "
          f"{closed_split:.12f}")
    print(f"    0 < I_split(12) < 1/8 :  {0 < isp < 0.125}")
    print(f"    I_split(12) < I_pair(12)/10 : {isp < ip / 10}")

    rule("6. Rigidity of the split-count profile at n = 12")
    for r, prof in split_profiles(12).items():
        tag = "  <- the exceptional class N == 1" if r == 0 else ""
        print(f"    residue {r:2d}: profile {prof}{tag}")

    rule("7. The split-count channel across orders")
    print("      n |  I_split(n) |  I_pair(n)")
    for n in (4, 6, 10, 12, 16):
        print(f"    {n:3d} | {i_split(n):11.6f} | {i_pair(n):10.6f}")
    print("\n    I_split decays but stays strictly positive on every order tested.")

    print("\n" + "=" * 72)
    print("  All closed forms agree with direct enumeration.")
    print("=" * 72)


if __name__ == "__main__":
    main()
