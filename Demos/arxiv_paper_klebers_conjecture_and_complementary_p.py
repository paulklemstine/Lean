"""
Complementary products of monomial symmetric functions: numerical demonstrations.

This self-contained script demonstrates, by exact rational computation, the results
concerning the quadratic-statistic mechanism behind Kleber's splitting phenomenon:

  Q(d) = sum_i d_i^2,      Q(u + v) = Q(u) + Q(v) + 2 <u, v>,

so that the Q-minimal monomials of a product m_alpha * m_beta are exactly those whose
part multiset is the multiset union alpha U beta.

Demonstrations included:

  1. The exact defect identity for Q, and the equality case (disjoint supports).
  2. Expansion of products m_alpha * m_beta in the monomial basis, showing that the
     Q-minimal term is m_{alpha U beta} with a positive splitting count.
  3. Linear independence (by exact rank) of families of products with pairwise
     distinct multiset unions.
  4. The one-row case: p_k p_{n-k}, 0 <= k <= n//2, is independent unconditionally.
  5. Power-sum monomials with distinct exponent multisets are independent.
  6. Sharpness: with too few variables independence fails (m_(1)m_(1) = m_(2) * 1);
     with a union collision independence can still hold (m_(a,b)*1 vs m_(a)m_(b)).
  7. The genuine collision (3,1)+(2,2) = (5,3) = (3,2)+(2,1) with equal unions,
     and the union-class structure of all componentwise splittings of a partition.

Only the Python standard library is used; all arithmetic is exact (Fraction / int).
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations, product
from typing import Dict, Iterable, List, Sequence, Tuple

Exp = Tuple[int, ...]          # exponent vector in N variables
Partition = Tuple[int, ...]    # weakly decreasing tuple of positive parts


# ---------------------------------------------------------------------------
# Basic combinatorics of exponent vectors
# ---------------------------------------------------------------------------

def qstat(d: Sequence[int]) -> int:
    """The quadratic statistic Q(d) = sum_i d_i^2."""
    return sum(x * x for x in d)


def dotp(u: Sequence[int], v: Sequence[int]) -> int:
    """The inner product <u, v> = sum_i u_i v_i."""
    return sum(a * b for a, b in zip(u, v))


def parts(d: Sequence[int]) -> Partition:
    """The multiset of nonzero entries of d, as a weakly decreasing tuple."""
    return tuple(sorted((x for x in d if x != 0), reverse=True))


def union(alpha: Sequence[int], beta: Sequence[int]) -> Partition:
    """The multiset union alpha U beta: all positive parts of both, pooled."""
    return tuple(sorted(list(parts(alpha)) + list(parts(beta)), reverse=True))


def support(d: Sequence[int]) -> int:
    """Number of nonzero entries."""
    return sum(1 for x in d if x != 0)


def orbit(d: Sequence[int]) -> List[Exp]:
    """All distinct rearrangements of the exponent vector d."""
    return sorted(set(permutations(d)))


def embed(lam: Sequence[int], n_vars: int) -> Exp:
    """Pad a partition to an exponent vector in n_vars variables."""
    if len(lam) > n_vars:
        raise ValueError(f"partition {lam} does not fit into {n_vars} variables")
    return tuple(list(lam) + [0] * (n_vars - len(lam)))


# ---------------------------------------------------------------------------
# Monomial symmetric polynomials and their products
# ---------------------------------------------------------------------------

def msym(lam: Sequence[int], n_vars: int) -> Dict[Exp, int]:
    """m_lambda in n_vars variables, as a dict {exponent vector: coefficient}."""
    return {w: 1 for w in orbit(embed(parts(lam), n_vars))}


def poly_mul(f: Dict[Exp, int], g: Dict[Exp, int]) -> Dict[Exp, int]:
    """Multiply two polynomials given as exponent-vector dictionaries."""
    out: Dict[Exp, int] = {}
    for u, cu in f.items():
        for v, cv in g.items():
            w = tuple(a + b for a, b in zip(u, v))
            out[w] = out.get(w, 0) + cu * cv
    return {w: c for w, c in out.items() if c != 0}


def monomial_expansion(f: Dict[Exp, int]) -> Dict[Partition, int]:
    """Expand a symmetric polynomial in the monomial basis {m_mu}."""
    out: Dict[Partition, int] = {}
    for w, c in f.items():
        mu = parts(w)
        if mu in out:
            continue
        out[mu] = c
    return {mu: c for mu, c in out.items() if c != 0}


def product_expansion(alpha: Sequence[int], beta: Sequence[int],
                      n_vars: int) -> Dict[Partition, int]:
    """Expand m_alpha * m_beta in the monomial basis."""
    return monomial_expansion(poly_mul(msym(alpha, n_vars), msym(beta, n_vars)))


def psum(k: int, n_vars: int) -> Dict[Exp, int]:
    """The power sum p_k = sum_j x_j^k in n_vars variables."""
    return msym((k,), n_vars)


# ---------------------------------------------------------------------------
# Exact rank over the rationals
# ---------------------------------------------------------------------------

def exact_rank(rows: List[List[Fraction]]) -> int:
    """Rank of a rational matrix by exact Gaussian elimination."""
    mat = [list(r) for r in rows]
    n_rows = len(mat)
    n_cols = len(mat[0]) if n_rows else 0
    rank = 0
    for col in range(n_cols):
        pivot = None
        for r in range(rank, n_rows):
            if mat[r][col] != 0:
                pivot = r
                break
        if pivot is None:
            continue
        mat[rank], mat[pivot] = mat[pivot], mat[rank]
        pv = mat[rank][col]
        mat[rank] = [x / pv for x in mat[rank]]
        for r in range(n_rows):
            if r != rank and mat[r][col] != 0:
                factor = mat[r][col]
                mat[r] = [x - factor * y for x, y in zip(mat[r], mat[rank])]
        rank += 1
        if rank == n_rows:
            break
    return rank


def independence_rank(polys: List[Dict[Exp, int]]) -> Tuple[int, int]:
    """Return (rank, number of polynomials) for a list of polynomials."""
    columns = sorted({w for p in polys for w in p})
    index = {w: j for j, w in enumerate(columns)}
    rows = [[Fraction(0)] * len(columns) for _ in polys]
    for i, p in enumerate(polys):
        for w, c in p.items():
            rows[i][index[w]] = Fraction(c)
    return exact_rank(rows), len(polys)


# ---------------------------------------------------------------------------
# Componentwise splittings of a partition
# ---------------------------------------------------------------------------

def is_partition(d: Sequence[int]) -> bool:
    """True if d is weakly decreasing (a partition, possibly with trailing zeros)."""
    return all(d[i] >= d[i + 1] for i in range(len(d) - 1))


def componentwise_splittings(theta: Sequence[int]) -> List[Tuple[Partition, Partition]]:
    """All unordered componentwise splittings alpha + beta = theta with alpha, beta
    themselves partitions (weakly decreasing), listed once per unordered pair."""
    seen = set()
    out: List[Tuple[Partition, Partition]] = []
    for alpha in product(*[range(t + 1) for t in theta]):
        beta = tuple(t - a for t, a in zip(theta, alpha))
        if not (is_partition(alpha) and is_partition(beta)):
            continue
        key = tuple(sorted([parts(alpha), parts(beta)]))
        if key in seen:
            continue
        seen.add(key)
        out.append((alpha, beta))
    return out


def union_classes(theta: Sequence[int]) -> Dict[Partition, List[Tuple[Partition, Partition]]]:
    """Group the unordered componentwise splittings of theta by multiset union."""
    classes: Dict[Partition, List[Tuple[Partition, Partition]]] = {}
    for alpha, beta in componentwise_splittings(theta):
        classes.setdefault(union(alpha, beta), []).append((alpha, beta))
    return classes


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_quadratic_identity() -> None:
    print("=" * 78)
    print("1. The defect identity  Q(u+v) = Q(u) + Q(v) + 2<u,v>")
    print("=" * 78)
    samples = [((3, 1, 0, 0), (0, 0, 2, 2)),
               ((3, 1, 0, 0), (2, 2, 0, 0)),
               ((4, 0, 0, 0), (4, 0, 0, 0))]
    for u, v in samples:
        w = tuple(a + b for a, b in zip(u, v))
        disjoint = dotp(u, v) == 0
        assert qstat(w) == qstat(u) + qstat(v) + 2 * dotp(u, v)
        print(f"  u={u}  v={v}")
        print(f"    Q(u)={qstat(u):3d}  Q(v)={qstat(v):3d}  <u,v>={dotp(u,v):3d}"
              f"  Q(u+v)={qstat(w):3d}   disjoint supports: {disjoint}")
        if disjoint:
            assert parts(w) == union(u, v)
            print(f"    equality case: parts(u+v) = {parts(w)} = union {union(u, v)}")
    print()


def demo_product_expansion() -> None:
    print("=" * 78)
    print("2. Products in the monomial basis; the Q-minimal term is m_{alpha U beta}")
    print("=" * 78)
    cases = [((3, 1), (2, 2)), ((3, 2), (2, 1)), ((2,), (2,)), ((2, 1), (1,))]
    for alpha, beta in cases:
        n_vars = len(parts(alpha)) + len(parts(beta))
        exp = product_expansion(alpha, beta, n_vars)
        u = union(alpha, beta)
        qmin = min(qstat(mu) for mu in exp)
        print(f"  m_{alpha} * m_{beta}   (in {n_vars} variables), union = {u}")
        for mu in sorted(exp, key=lambda m: (qstat(m), m)):
            marker = "   <-- Q-minimal" if qstat(mu) == qmin else ""
            print(f"      {exp[mu]:4d} * m_{str(mu):<14} Q = {qstat(mu):3d}{marker}")
        minimal = [mu for mu in exp if qstat(mu) == qmin]
        assert minimal == [u], (minimal, u)
        assert exp[u] > 0
        print(f"      -> Q-minimal shape is exactly the union {u},"
              f" with positive count {exp[u]}")
    print()


def demo_distinct_unions_independence() -> None:
    print("=" * 78)
    print("3. Distinct multiset unions => linear independence (exact rank)")
    print("=" * 78)
    # A family of componentwise splittings of theta = (4,2) with distinct unions.
    theta = (4, 2)
    classes = union_classes(theta)
    family = [pairs[0] for _, pairs in sorted(classes.items())]
    n_vars = max(support(a) + support(b) for a, b in family)
    polys = [poly_mul(msym(a, n_vars), msym(b, n_vars)) for a, b in family]
    rank, count = independence_rank(polys)
    print(f"  theta = {theta}: one representative per union class, {count} products,"
          f" {n_vars} variables")
    for a, b in family:
        print(f"      m_{parts(a)} * m_{parts(b)}    union {union(a, b)}")
    print(f"  rank = {rank} of {count}  ->  independent: {rank == count}")
    assert rank == count
    print()


def demo_one_row() -> None:
    print("=" * 78)
    print("4. The one-row case: p_k p_{n-k}, 0 <= k <= n//2, is independent")
    print("=" * 78)
    for n in range(1, 9):
        n_vars = 2
        polys = []
        unions = []
        for k in range(n // 2 + 1):
            a = (k,) if k > 0 else ()
            b = (n - k,) if n - k > 0 else ()
            polys.append(poly_mul(msym(a, n_vars), msym(b, n_vars)))
            unions.append(union(embed(a, n_vars), embed(b, n_vars)))
        rank, count = independence_rank(polys)
        assert len(set(unions)) == count, "unions must be pairwise distinct"
        assert rank == count
        print(f"  n = {n}: {count} products p_k p_(n-k), unions all distinct,"
              f" rank {rank}/{count}")
    print()


def demo_power_sum_monomials() -> None:
    print("=" * 78)
    print("5. Power-sum monomials with distinct exponent multisets are independent")
    print("=" * 78)
    families = [((1, 1, 1), (1, 2), (3,)), ((2, 2), (1, 3), (4,)), ((1, 1, 2), (2, 2), (1, 3))]
    for fam in families:
        n_vars = max(len(f) for f in fam)
        polys = []
        for exps in fam:
            p = {tuple([0] * n_vars): 1}
            for k in exps:
                p = poly_mul(p, psum(k, n_vars))
            polys.append(p)
        rank, count = independence_rank(polys)
        names = "  ".join("p_" + "p_".join(str(k) for k in f) for f in fam)
        assert rank == count
        print(f"  {names}   ({n_vars} variables): rank {rank}/{count}")
    print()


def demo_sharpness() -> None:
    print("=" * 78)
    print("6. Sharpness of the two hypotheses")
    print("=" * 78)
    # (a) Too few variables: independence fails even with distinct unions.
    n_vars = 1
    p1 = poly_mul(msym((1,), n_vars), msym((1,), n_vars))
    p2 = poly_mul(msym((2,), n_vars), msym((), n_vars))
    rank, count = independence_rank([p1, p2])
    print(f"  (a) one variable: unions {union((1,), (1,))} vs {union((2,), ())} are distinct,")
    print(f"      but m_(1)m_(1) = {p1} and m_(2)*1 = {p2}: rank {rank}/{count}"
          f"  ->  dependent: {rank < count}")
    assert p1 == p2 and rank == 1

    # (b) A union collision that is nevertheless independent.
    for a, b in [(2, 2), (3, 1), (5, 2)]:
        n_vars = 2
        q1 = poly_mul(msym((a, b), n_vars), msym((), n_vars))
        q2 = poly_mul(msym((a,), n_vars), msym((b,), n_vars))
        u1 = union(embed(parts((a, b)), n_vars), (0, 0))
        u2 = union(embed((a,), n_vars), embed((b,), n_vars))
        rank, count = independence_rank([q1, q2])
        exp2 = monomial_expansion(q2)
        assert u1 == u2 and rank == count
        print(f"  (b) a={a}, b={b}: identical unions {u1}, yet")
        print(f"      m_({a},{b})*1 vs m_({a})m_({b}) = "
              + " + ".join(f"{c}*m_{mu}" for mu, c in
                           sorted(exp2.items(), key=lambda t: (qstat(t[0]), t[0])))
              + f"   rank {rank}/{count}")
        print(f"      separating monomial x_1^{a + b} lies one Q-level up:"
              f" Q = {(a + b) ** 2} > {a * a + b * b}")
    print()


def demo_collision_five_three() -> None:
    print("=" * 78)
    print("7. The genuine collision at theta = (5,3), and union-class structure")
    print("=" * 78)
    a1, b1 = (3, 1), (2, 2)
    a2, b2 = (3, 2), (2, 1)
    assert tuple(x + y for x, y in zip(a1, b1)) == (5, 3)
    assert tuple(x + y for x, y in zip(a2, b2)) == (5, 3)
    assert union(a1, b1) == union(a2, b2)
    print(f"  {a1} + {b1} = (5,3) = {a2} + {b2}")
    print(f"  unions:  {union(a1, b1)}  =  {union(a2, b2)}   (a genuine collision)")
    n_vars = 4
    polys = [poly_mul(msym(a1, n_vars), msym(b1, n_vars)),
             poly_mul(msym(a2, n_vars), msym(b2, n_vars))]
    rank, count = independence_rank(polys)
    print(f"  the two products are nevertheless independent: rank {rank}/{count}"
          f"  (separation happens above the Q-minimal layer)")
    assert rank == count

    # the explicit separating monomial x_1^4 x_2^4
    w = (4, 4, 0, 0)
    c1, c2 = polys[0].get(w, 0), polys[1].get(w, 0)
    print(f"  separating monomial x^{w}: coefficient {c1} in the first product,"
          f" {c2} in the second")
    assert c1 == 0 and c2 > 0
    print(f"  Q(4,4) = {qstat(w)} > {qstat((3, 2, 2, 1))} = Q(3,2,2,1):"
          f" two merge layers above the bottom")
    assert qstat(w) > qstat((3, 2, 2, 1))

    print("\n  Union-class structure of componentwise splittings:")
    for theta in [(3,), (4,), (2, 2), (3, 2), (4, 2), (5, 3)]:
        classes = union_classes(theta)
        sizes = sorted((len(v) for v in classes.values()), reverse=True)
        n_split = sum(sizes)
        print(f"    theta = {str(theta):8} splittings {n_split:3d}"
              f"   union classes {len(classes):3d}   class sizes {sizes}")

    print("\n  Full independence check within each union class (Conjecture 1, small cases):")
    for theta in [(2, 2), (3, 2), (4, 2), (5, 3)]:
        ok = True
        for _, pairs in union_classes(theta).items():
            if len(pairs) < 2:
                continue
            n_vars = max(support(a) + support(b) for a, b in pairs)
            polys = [poly_mul(msym(a, n_vars), msym(b, n_vars)) for a, b in pairs]
            rank, count = independence_rank(polys)
            ok = ok and (rank == count)
        print(f"    theta = {str(theta):8} all union classes independent: {ok}")
        assert ok

    print("\n  Full componentwise splitting independence (all splittings at once):")
    for theta in [(2, 2), (3, 2), (4, 2), (5, 3)]:
        pairs = componentwise_splittings(theta)
        n_vars = max(support(a) + support(b) for a, b in pairs)
        polys = [poly_mul(msym(a, n_vars), msym(b, n_vars)) for a, b in pairs]
        rank, count = independence_rank(polys)
        print(f"    theta = {str(theta):8} rank {rank}/{count}"
              f"   independent: {rank == count}")
        assert rank == count
    print()


def kleber_pairs(r: int, c: int) -> List[Tuple[Partition, Partition]]:
    """Unordered rectangular-complement pairs inside the rectangle (c^r):
    lambda subset of (c^r), with lambda^vee_i = c - lambda_{r+1-i}."""
    seen = set()
    out: List[Tuple[Partition, Partition]] = []
    for lam in product(*[range(c + 1) for _ in range(r)]):
        if not is_partition(lam):
            continue
        comp = tuple(c - lam[r - 1 - i] for i in range(r))
        key = tuple(sorted([parts(lam), parts(comp)]))
        if key in seen:
            continue
        seen.add(key)
        out.append((lam, comp))
    return out


def demo_rectangles() -> None:
    print("=" * 78)
    print("8. Rectangular complements: the Kleber family m_lambda m_(lambda^vee)")
    print("=" * 78)
    for r, c in [(1, 3), (2, 2), (2, 3), (3, 2)]:
        pairs = kleber_pairs(r, c)
        classes: Dict[Partition, int] = {}
        for a, b in pairs:
            u = union(a, b)
            classes[u] = classes.get(u, 0) + 1
        n_vars = 2 * r
        polys = [poly_mul(msym(a, n_vars), msym(b, n_vars)) for a, b in pairs]
        rank, count = independence_rank(polys)
        collisions = sorted(u for u, k in classes.items() if k > 1)
        print(f"  rectangle ({c}^{r}): {count} complementary pairs,"
              f" {len(classes)} union classes, {n_vars} variables")
        for a, b in pairs:
            print(f"      m_{parts(a)} * m_{parts(b)}    union {union(a, b)}")
        print(f"      union collisions: {collisions if collisions else 'none'}")
        print(f"      rank {rank}/{count}  ->  independent: {rank == count}")
        assert rank == count
    print()


def main() -> None:
    print()
    print("Complementary products of monomial symmetric functions")
    print("Numerical demonstrations of the quadratic-statistic mechanism")
    print()
    demo_quadratic_identity()
    demo_product_expansion()
    demo_distinct_unions_independence()
    demo_one_row()
    demo_power_sum_monomials()
    demo_sharpness()
    demo_collision_five_three()
    demo_rectangles()
    print("All demonstrations completed; every assertion verified exactly.")


if __name__ == "__main__":
    main()
