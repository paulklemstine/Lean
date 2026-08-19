"""
Numerical demonstrations for:

    Gaussian binomial coefficients over an arbitrary base,
    subgroup counts of finite groups,
    and the intermediate fields of a Hilbert class field.

Everything is self-contained: no imports beyond the standard library, exact
integer arithmetic throughout, and each section checks a theorem of the paper
against a brute-force computation wherever brute force is feasible.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1.  Gaussian binomial coefficients: the two definitions
# ---------------------------------------------------------------------------


def gauss_binom_quotient(q: int, n: int, k: int) -> int:
    """binom(n,k)_q by the defining quotient  prod(q^n - q^i) / prod(q^k - q^i).

    The theorem of the paper is that this division is exact for every q >= 2.
    We compute it as an exact integer division and let Python raise if it is
    not (it never is, for q >= 2).
    """
    num = 1
    den = 1
    for i in range(k):
        num *= q**n - q**i
        den *= q**k - q**i
    if num == 0:
        return 0
    if num % den != 0:
        raise ArithmeticError(f"non-exact division at q={q}, n={n}, k={k}")
    return num // den


def gauss_binom_pascal(q: int, n: int, k: int) -> int:
    """binom(n,k)_q by the q-Pascal recursion, computed row by row.

    row_{n+1}[0]   = 1
    row_{n+1}[k+1] = row_n[k] + q^{k+1} * row_n[k+1]
    """
    row: List[int] = [1]
    for _ in range(n):
        new = [1] + [
            row[j] + q ** (j + 1) * (row[j + 1] if j + 1 < len(row) else 0)
            for j in range(len(row))
        ]
        row = new
    return row[k] if k < len(row) else 0


def q_factorial(q: int, m: int) -> int:
    """[m]_q! = prod_{j<m} (q^{j+1} - 1)."""
    out = 1
    for j in range(m):
        out *= q ** (j + 1) - 1
    return out


def galois_number_sum(q: int, n: int) -> int:
    """G_q(n) = sum_{k<=n} binom(n,k)_q, by summing a q-Pascal row."""
    row: List[int] = [1]
    for _ in range(n):
        row = [1] + [
            row[j] + q ** (j + 1) * (row[j + 1] if j + 1 < len(row) else 0)
            for j in range(len(row))
        ]
    return sum(row)


def galois_number_recursion(q: int, n: int) -> int:
    """G_q(n) by the three-term recursion G(n+2) = 2G(n+1) + (q^{n+1}-1) G(n)."""
    if n == 0:
        return 1
    if n == 1:
        return 2
    prev, cur = 1, 2  # G(0), G(1)
    for m in range(n - 1):
        prev, cur = cur, 2 * cur + (q ** (m + 1) - 1) * prev
    return cur


# ---------------------------------------------------------------------------
# 2.  Brute-force subspace counting over a prime field
# ---------------------------------------------------------------------------


def subspaces_of_Fp_r(p: int, r: int) -> List[frozenset]:
    """All linear subspaces of (Z/p)^r, as frozensets of tuples (brute force)."""
    vectors = list(product(range(p), repeat=r))

    def span(gens: Sequence[Tuple[int, ...]]) -> frozenset:
        current = {tuple([0] * r)}
        changed = True
        while changed:
            changed = False
            for v in list(current):
                for g in gens:
                    for c in range(p):
                        w = tuple((v[i] + c * g[i]) % p for i in range(r))
                        if w not in current:
                            current.add(w)
                            changed = True
        return frozenset(current)

    found = {frozenset({tuple([0] * r)})}
    frontier = list(found)
    while frontier:
        new_frontier = []
        for S in frontier:
            for v in vectors:
                if v in S:
                    continue
                T = span(list(S) + [v])
                if T not in found:
                    found.add(T)
                    new_frontier.append(T)
        frontier = new_frontier
    return sorted(found, key=lambda S: (len(S), sorted(S)))


def dimension(p: int, S: Iterable[Tuple[int, ...]]) -> int:
    """dim W = log_p |W|."""
    size = len(set(S))
    d = 0
    while p**d < size:
        d += 1
    return d


# ---------------------------------------------------------------------------
# 3.  Subgroup counting for finite abelian groups
# ---------------------------------------------------------------------------


def divisor_count(n: int) -> int:
    """d(n), the number of positive divisors."""
    return sum(1 for d in range(1, n + 1) if n % d == 0)


def factorize(n: int) -> Dict[int, int]:
    """Prime factorisation of n as {p: exponent}."""
    out: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            out[d] = out.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        out[n] = out.get(n, 0) + 1
    return out


def subgroup_count_abelian(invariants: Sequence[int]) -> int:
    """Number of subgroups of  Z/n_1 x ... x Z/n_t,  for the cases covered by
    the paper: each primary component must be cyclic or elementary abelian.

    Strategy (multiplicativity over coprime primary components):
      * split every Z/n_i into its prime-power parts,
      * group the parts by prime p; if the p-part is a single cyclic Z/p^r,
        it contributes r+1 subgroups; if it is (Z/p)^r, it contributes the
        Galois number G_p(r),
      * multiply the contributions.
    """
    parts: Dict[int, List[int]] = {}
    for n in invariants:
        for p, e in factorize(n).items():
            parts.setdefault(p, []).append(e)
    total = 1
    for p, exps in parts.items():
        if len(exps) == 1:
            total *= exps[0] + 1                      # cyclic  Z/p^r
        elif all(e == 1 for e in exps):
            total *= galois_number_recursion(p, len(exps))   # (Z/p)^r
        else:
            raise NotImplementedError(
                f"p-component of type {sorted(exps, reverse=True)} at p={p} "
                "is neither cyclic nor elementary abelian"
            )
    return total


def brute_force_subgroup_count(invariants: Sequence[int]) -> int:
    """Brute-force number of subgroups of Z/n_1 x ... x Z/n_t (small groups)."""
    elements = list(product(*[range(n) for n in invariants]))

    def add(u: Tuple[int, ...], v: Tuple[int, ...]) -> Tuple[int, ...]:
        return tuple((u[i] + v[i]) % invariants[i] for i in range(len(invariants)))

    def closure(gens: Sequence[Tuple[int, ...]]) -> frozenset:
        zero = tuple([0] * len(invariants))
        cur = {zero}
        frontier = [zero]
        while frontier:
            nxt = []
            for x in frontier:
                for g in gens:
                    y = add(x, g)
                    if y not in cur:
                        cur.add(y)
                        nxt.append(y)
            frontier = nxt
        return frozenset(cur)

    zero = tuple([0] * len(invariants))
    found = {frozenset({zero})}
    frontier = list(found)
    while frontier:
        nxt = []
        for S in frontier:
            for v in elements:
                if v in S:
                    continue
                T = closure(list(S) + [v])
                if T not in found:
                    found.add(T)
                    nxt.append(T)
        frontier = nxt
    return len(found)


# ---------------------------------------------------------------------------
# 4.  Intermediate fields of a class field datum
# ---------------------------------------------------------------------------


def intermediate_field_degrees_elementary(p: int, r: int) -> List[Tuple[int, int]]:
    """For a class group (Z/p)^r: list of (degree over K, how many fields).

    A subspace of dimension j gives a field of degree p^{r-j}; setting
    k = r-j, the number of fields of degree p^k is binom(r, r-k)_p, which
    equals binom(r,k)_p by symmetry.
    """
    return [(p**k, gauss_binom_pascal(p, r, k)) for k in range(r + 1)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_exactness_and_pascal() -> None:
    print("=" * 74)
    print("1.  The defining quotient is an exact division, and equals q-Pascal")
    print("=" * 74)
    for q in (2, 3, 4, 6, 10):
        ok = all(
            gauss_binom_quotient(q, n, k) == gauss_binom_pascal(q, n, k)
            for n in range(9)
            for k in range(10)
        )
        print(f"  q = {q:2d}:  quotient == recursion for all n<=8, k<=9 :  {ok}")
    print()
    print("  Gaussian triangle for q = 2 (rows n = 0..6):")
    for n in range(7):
        row = [gauss_binom_pascal(2, n, k) for k in range(n + 1)]
        print("   " + " ".join(f"{x:6d}" for x in row))
    print()
    print("  Gaussian triangle for q = 4 (a NON-prime base; rows n = 0..4):")
    for n in range(5):
        row = [gauss_binom_pascal(4, n, k) for k in range(n + 1)]
        print("   " + " ".join(f"{x:8d}" for x in row))
    print()


def demo_symmetry_and_factorial() -> None:
    print("=" * 74)
    print("2.  Symmetry and the q-factorial identity, at arbitrary bases")
    print("=" * 74)
    for q in (2, 3, 4, 6, 9, 10):
        sym = all(
            gauss_binom_pascal(q, n, k) == gauss_binom_pascal(q, n, n - k)
            for n in range(9)
            for k in range(n + 1)
        )
        fac = all(
            q_factorial(q, k) * q_factorial(q, n - k) * gauss_binom_pascal(q, n, k)
            == q_factorial(q, n)
            for n in range(9)
            for k in range(n + 1)
        )
        print(f"  q = {q:2d}:  symmetry {sym},  [k]! [n-k]! binom = [n]!  {fac}")
    print()
    print("  Explicit non-prime checks:")
    print(f"    binom(2,1)_4 = {gauss_binom_quotient(4, 2, 1)}"
          f"  = binom(1,0)_4 + 4*binom(1,1)_4 = "
          f"{gauss_binom_pascal(4,1,0)} + 4*{gauss_binom_pascal(4,1,1)}")
    print(f"    binom(5,2)_6 = {gauss_binom_quotient(6, 5, 2)}"
          f" = binom(5,3)_6 = {gauss_binom_quotient(6, 5, 3)}")
    print(f"    binom(n,1)_q = 1+q+...+q^(n-1):  "
          f"binom(5,1)_3 = {gauss_binom_pascal(3,5,1)} = "
          f"{sum(3**i for i in range(5))}")
    print()


def demo_galois_numbers() -> None:
    print("=" * 74)
    print("3.  Galois numbers  G_q(n) = sum_k binom(n,k)_q")
    print("=" * 74)
    for q in (2, 3, 4, 5):
        by_sum = [galois_number_sum(q, n) for n in range(7)]
        by_rec = [galois_number_recursion(q, n) for n in range(7)]
        agree = by_sum == by_rec
        print(f"  q = {q}:  {by_sum}")
        print(f"          three-term recursion agrees: {agree}"
              f"   (G_q(2) = q+3 = {q+3}: {by_sum[2] == q + 3})")
    print()
    print("  q = 2 gives 1, 2, 5, 16, 67, 374, ... (subgroup counts of (Z/2)^n)")
    print("  q = 3 gives 1, 2, 6, 28, 212, ...")
    print(f"  G_3(4) from the recursion: 2*28 + (3^3-1)*6 = "
          f"{2*28 + (3**3 - 1)*6}  (= {galois_number_recursion(3,4)})")
    print(f"  G_4(3) = 1 + 21 + 21 + 1 = {galois_number_recursion(4,3)}"
          "   (a non-prime base)")
    print()


def demo_subspaces() -> None:
    print("=" * 74)
    print("4.  Brute-force subspace counts versus Gaussian binomials")
    print("=" * 74)
    for (p, r) in [(2, 1), (2, 2), (2, 3), (3, 2), (5, 2)]:
        subs = subspaces_of_Fp_r(p, r)
        by_dim: Dict[int, int] = {}
        for S in subs:
            by_dim[dimension(p, S)] = by_dim.get(dimension(p, S), 0) + 1
        predicted = {k: gauss_binom_pascal(p, r, k) for k in range(r + 1)}
        total_ok = len(subs) == galois_number_recursion(p, r)
        print(f"  (Z/{p})^{r}:  by dimension {dict(sorted(by_dim.items()))}"
              f"  predicted {predicted}")
        print(f"            total {len(subs)} = G_{p}({r}) = "
              f"{galois_number_recursion(p, r)} : {total_ok}")
    print()


def demo_subgroup_counts() -> None:
    print("=" * 74)
    print("5.  Subgroup counts of finite abelian groups, and the order-4")
    print("    and order-12 contrasts")
    print("=" * 74)
    cases: List[Tuple[str, List[int]]] = [
        ("Z/4",                 [4]),
        ("(Z/2)^2",             [2, 2]),
        ("Z/9",                 [9]),
        ("(Z/3)^2",             [3, 3]),
        ("Z/12",                [12]),
        ("(Z/2)^2 x Z/3",       [2, 2, 3]),
        ("Z/6",                 [6]),
        ("(Z/2)^3",             [2, 2, 2]),
    ]
    print(f"  {'group':<18}{'order':>7}{'formula':>10}{'brute force':>14}")
    for name, inv in cases:
        order = 1
        for n in inv:
            order *= n
        f = subgroup_count_abelian(inv)
        b = brute_force_subgroup_count(inv) if order <= 36 else None
        print(f"  {name:<18}{order:>7}{f:>10}"
              f"{(b if b is not None else '-'):>14}")
    print()
    print("  Two groups of order 4 with different subgroup counts: 3 vs 5.")
    print("  Two groups of order 12 with different subgroup counts: 6 vs 10.")
    print(f"  d(12) = {divisor_count(12)} confirms the cyclic count.")
    print("  At order p^2: cyclic gives 3, exponent-p gives p+3 -->",
          [(p, 3, p + 3) for p in (2, 3, 5, 7)])
    print()


def demo_intermediate_fields() -> None:
    print("=" * 74)
    print("6.  Intermediate fields of a Hilbert class field")
    print("=" * 74)
    print("  Class group cyclic of order n  -->  d(n) intermediate fields:")
    for n in (2, 4, 6, 12, 36):
        print(f"    n = {n:3d}:  {divisor_count(n)} fields, "
              f"degrees {[m for m in range(1, n+1) if n % m == 0]}")
    print()
    print("  Class group (Z/p)^r  -->  G_p(r) fields, binom(r,k)_p of degree p^k:")
    for (p, r) in [(2, 1), (2, 2), (2, 3), (3, 2), (2, 4)]:
        dist = intermediate_field_degrees_elementary(p, r)
        total = sum(c for _, c in dist)
        print(f"    (Z/{p})^{r}:  total {total} = G_{p}({r});  "
              + ", ".join(f"{c} of degree {d}" for d, c in dist))
    print()
    print("  Mixed class group (Z/p)^r x (Z/q)^s  -->  G_p(r) * G_q(s) fields:")
    for (p, r, q, s) in [(2, 2, 3, 1), (2, 1, 3, 1), (2, 3, 5, 1)]:
        gp = galois_number_recursion(p, r)
        gq = galois_number_recursion(q, s)
        print(f"    (Z/{p})^{r} x (Z/{q})^{s}:  {gp} * {gq} = {gp*gq} fields")
    print()
    print("  Headline instances:")
    print("    Klein four class group: 5 fields, degree multiset {1,2,2,2,4}")
    print("    Class group (Z/2)^3   : 16 fields, degrees 1,2,4,8 with "
          "multiplicities 1,7,7,1")
    print("    Class number 12       : 10 fields for (Z/2)^2 x Z/3, "
          "but only 6 for Z/12")
    print()


def main() -> None:
    demo_exactness_and_pascal()
    demo_symmetry_and_factorial()
    demo_galois_numbers()
    demo_subspaces()
    demo_subgroup_counts()
    demo_intermediate_fields()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
