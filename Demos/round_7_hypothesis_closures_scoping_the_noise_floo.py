#!/usr/bin/env python3
"""
Numerical demonstrations of four structural closures for semiprimes N = p*q.

Every routine below is self-contained (standard library only) and verifies,
on explicit numbers, one of the theorems:

  1. AGREEMENT COLLAPSE
       |{a in (Z/NZ)^x : (a|p) = (a|q)}| = phi(N)/2 exactly,
       and that set equals the Jacobi level set {a : J(a|N) = +1}.

  2. ZERO-DIVISOR GRAPH
       The zero-divisor graph of Z/NZ is the complete bipartite graph
       K_{q-1, p-1}: |V| = p + q - 2, edges exactly across wings,
       deg(x) + 1 is always a prime factor of N, and gcd(x, N) is a
       nontrivial factor for every single vertex x (the circularity).

  3. NOISE FLOOR AND THE CORRELATED RHO SAMPLER
       Uniform hit density (p+q-2)/N <= 2/min(p,q), bounded below by
       about 2/sqrt(N); by contrast the rho walk x -> x^2 + 1 has a
       guaranteed factor-bearing pair within its first p+1 iterates
       (pigeonhole, no randomness), at aggregation cost C(p+1,2) >= p.

  4. DIGIT-LATTICE NON-ISOLATION
       The carry commutator C = [[0,1],[-1,0]] lies in the kernel of the
       digit functional for every base, so every factorization target has a
       non-rank-one companion solution of the same digit value at squared
       distance at most 8 -- uniformly in N.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import gcd, isqrt
from typing import Dict, Iterator, List, Sequence, Tuple


# --------------------------------------------------------------------------
# Elementary number theory
# --------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate for demo sizes)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
    return True


def euler_phi_semiprime(p: int, q: int) -> int:
    """phi(pq) = (p-1)(q-1) for distinct primes p != q."""
    return (p - 1) * (q - 1)


def legendre_symbol(a: int, p: int) -> int:
    """Legendre symbol (a|p) for an odd prime p, by Euler's criterion."""
    a %= p
    if a == 0:
        return 0
    t = pow(a, (p - 1) // 2, p)
    return 1 if t == 1 else -1


def jacobi_symbol(a: int, n: int) -> int:
    """Jacobi symbol J(a|n) for odd n >= 1, computed from n alone (no factors)."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("Jacobi symbol requires an odd positive modulus")
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


def units_mod(n: int) -> List[int]:
    """The units of Z/nZ, as representatives in [1, n)."""
    return [a for a in range(1, n) if gcd(a, n) == 1]


# --------------------------------------------------------------------------
# 1. AGREEMENT COLLAPSE
# --------------------------------------------------------------------------


def agreement_set(p: int, q: int) -> List[int]:
    """{a in (Z/pqZ)^x : (a|p) = (a|q)} as a sorted list of representatives."""
    n = p * q
    return [a for a in units_mod(n) if legendre_symbol(a, p) == legendre_symbol(a, q)]


def jacobi_level_set(p: int, q: int) -> List[int]:
    """{a in (Z/NZ)^x : J(a|N) = +1}, computed from N alone."""
    n = p * q
    return [a for a in units_mod(n) if jacobi_symbol(a, n) == 1]


def demo_agreement(pairs: Sequence[Tuple[int, int]]) -> None:
    print("=" * 74)
    print("1. AGREEMENT COLLAPSE:  2|A(N)| = phi(N),  and  A(N) = {J(a|N) = +1}")
    print("=" * 74)
    print(f"{'p':>5} {'q':>5} {'N':>8} {'|A(N)|':>8} {'phi(N)/2':>9} {'= Jacobi set?':>15}")
    for p, q in pairs:
        assert is_prime(p) and is_prime(q) and p != q and p != 2
        a_set = agreement_set(p, q)
        j_set = jacobi_level_set(p, q)
        half_phi = euler_phi_semiprime(p, q) // 2
        assert len(a_set) == half_phi, "agreement count must be phi(N)/2"
        assert a_set == j_set, "agreement set must be the Jacobi level set"
        print(f"{p:>5} {q:>5} {p*q:>8} {len(a_set):>8} {half_phi:>9} {'yes':>15}")
    print("\nThe count depends only on phi(N), and membership is decidable from N")
    print("alone by the Jacobi symbol: the aggregate carries no extra information.\n")


def demo_flipping_unit(p: int, q: int) -> None:
    """Exhibit the CRT witness u with (u|p) = -1, (u|q) = +1 driving the pairing."""
    n = p * q
    u = next(a for a in units_mod(n)
             if legendre_symbol(a, p) == -1 and legendre_symbol(a, q) == 1)
    a_set = set(agreement_set(p, q))
    images = {(a * u) % n for a in a_set}
    complement = set(units_mod(n)) - a_set
    assert images == complement, "multiplication by u must swap A(N) and its complement"
    print(f"   flipping unit for N = {p}*{q} = {n}:  u = {u}"
          f"   (u mod p = {u % p}, u mod q = {u % q})")
    print(f"   u maps A(N) bijectively onto its complement: "
          f"{len(a_set)} <-> {len(complement)}\n")


# --------------------------------------------------------------------------
# 2. THE ZERO-DIVISOR GRAPH
# --------------------------------------------------------------------------


def zd_vertices(n: int) -> List[int]:
    """Nonzero zero-divisors of Z/nZ: 0 < x < n with gcd(x, n) > 1."""
    return [x for x in range(1, n) if gcd(x, n) != 1]


def zd_adjacency(n: int, vertices: Sequence[int]) -> Dict[int, List[int]]:
    """Adjacency lists: x ~ y iff x != y and n | x*y."""
    return {x: [y for y in vertices if y != x and (x * y) % n == 0] for x in vertices}


def demo_zero_divisor_graph(p: int, q: int) -> None:
    n = p * q
    verts = zd_vertices(n)
    wing_p = [x for x in verts if x % p == 0]
    wing_q = [x for x in verts if x % q == 0]
    adj = zd_adjacency(n, verts)

    assert len(verts) == p + q - 2
    assert len(wing_p) == q - 1 and len(wing_q) == p - 1
    assert not (set(wing_p) & set(wing_q))

    # complete bipartite: edge iff opposite wings
    for x, y in combinations(verts, 2):
        cross = (x % p == 0) != (y % p == 0)
        assert (y in adj[x]) == cross

    # degrees and circularity
    for x in verts:
        d = len(adj[x])
        assert d + 1 in (p, q) and n % (d + 1) == 0
        assert gcd(x, n) in (p, q)

    print("=" * 74)
    print("2. ZERO-DIVISOR GRAPH of Z/NZ  is  K_{q-1, p-1}")
    print("=" * 74)
    print(f"   N = {p} * {q} = {n}")
    print(f"   |V| = {len(verts)} = p + q - 2 = {p + q - 2}   (trace witness: p+q = {p+q})")
    print(f"   p-wing (multiples of {p}): {wing_p}   size {len(wing_p)} = q - 1")
    print(f"   q-wing (multiples of {q}): {wing_q}   size {len(wing_q)} = p - 1")
    example = verts[0]
    print(f"   degree of vertex {example}: {len(adj[example])}"
          f"  ->  {len(adj[example]) + 1} divides N")
    print(f"   circularity: gcd({example}, N) = {gcd(example, n)}"
          f"  -- one vertex already gives a factor")
    s = len(verts) + 2
    disc = isqrt(s * s - 4 * n)
    print(f"   roots of X^2 - {s}X + {n}:  {(s - disc)//2} and {(s + disc)//2}\n")


# --------------------------------------------------------------------------
# 3. NOISE FLOOR AND THE CORRELATED RHO SAMPLER
# --------------------------------------------------------------------------


def hit_density(p: int, q: int) -> float:
    """Probability that a single uniform draw from [1,N) exposes a factor."""
    return (p + q - 2) / (p * q)


def demo_noise_floor(pairs: Sequence[Tuple[int, int]]) -> None:
    print("=" * 74)
    print("3a. ATOMIC UNIFORM NOISE FLOOR:  delta(N) = (p+q-2)/N <= 2/min(p,q)")
    print("=" * 74)
    print(f"{'p':>7} {'q':>7} {'N':>11} {'delta(N)':>12} {'2/min(p,q)':>12} {'2/sqrt(N)':>12}")
    for p, q in pairs:
        d = hit_density(p, q)
        upper = 2 / min(p, q)
        floor = 2 / (p * q) ** 0.5
        assert d <= upper + 1e-15
        assert (p + q) ** 2 >= 4 * p * q
        assert d >= floor - 2 / (p * q)
        print(f"{p:>7} {q:>7} {p*q:>11} {d:>12.3e} {upper:>12.3e} {floor:>12.3e}")
    print("\nThe density is smallest exactly when p = q (balanced semiprimes):")
    print("(p+q)^2 - 4pq = (p-q)^2 >= 0, with equality iff p = q.\n")


def rho_iterates(x0: int, n: int, steps: int) -> List[int]:
    """Iterates of the static rho map x -> x^2 + 1 reduced mod n."""
    out = [x0 % n]
    for _ in range(steps):
        out.append((out[-1] * out[-1] + 1) % n)
    return out


def demo_rho_collision(p: int, q: int, x0: int = 2) -> None:
    n = p * q
    xs = rho_iterates(x0, n, p + 1)

    # Reduction-compatibility: the mod-N walk covers the mod-p walk.
    ys = rho_iterates(x0, p, p + 1)
    assert [x % p for x in xs] == ys

    # Pigeonhole: a collision mod p among the first p+1 iterates.
    collision = None
    for i, j in combinations(range(p + 1), 2):
        if (xs[j] - xs[i]) % p == 0:
            collision = (i, j)
            break
    assert collision is not None, "pigeonhole guarantees a collision mod p"

    # Extraction: a one-sided collision returns the factor exactly.
    extracted = None
    for i, j in combinations(range(p + 1), 2):
        g = gcd(abs(xs[j] - xs[i]), n)
        if 1 < g < n:
            extracted = (i, j, g)
            break

    print("=" * 74)
    print("3b. CORRELATED RHO SAMPLER:  guaranteed collision, priced by aggregation")
    print("=" * 74)
    print(f"   N = {p} * {q} = {n},  walk x -> x^2 + 1,  x0 = {x0}")
    print(f"   first iterates mod N: {xs[:8]} ...")
    print(f"   the same walk mod p : {ys[:8]} ...   (reduction-compatibility)")
    i, j = collision
    print(f"   pigeonhole collision at (i, j) = ({i}, {j}) <= p = {p}: "
          f"p divides x_j - x_i")
    if extracted:
        i, j, g = extracted
        print(f"   extraction: gcd(x_{j} - x_{i}, N) = {g}  (a nontrivial factor)")
    pairs_needed = (p + 1) * p // 2
    print(f"   aggregation cost: C(p+1, 2) = {pairs_needed} >= p = {p} "
          f"gcds -- at least trial division")
    print("\n   Density is NOT the obstruction for correlated samples; cost is.\n")


# --------------------------------------------------------------------------
# 4. DIGIT-LATTICE NON-ISOLATION
# --------------------------------------------------------------------------

Matrix2 = Tuple[Tuple[int, int], Tuple[int, int]]

CARRY_COMMUTATOR: Matrix2 = ((0, 1), (-1, 0))


def digit_val(b: int, w: Matrix2) -> int:
    """The digit functional Phi_b(w) = sum_{i,j} w_ij b^{i+j}."""
    return sum(w[i][j] * b ** (i + j) for i in range(2) for j in range(2))


def rank_one(u: Tuple[int, int], v: Tuple[int, int]) -> Matrix2:
    """The rank-one target u (x) v with entries u_i v_j."""
    return ((u[0] * v[0], u[0] * v[1]), (u[1] * v[0], u[1] * v[1]))


def det2(w: Matrix2) -> int:
    return w[0][0] * w[1][1] - w[0][1] * w[1][0]


def sq_norm(w: Matrix2) -> int:
    return sum(w[i][j] ** 2 for i in range(2) for j in range(2))


def add_scaled(w: Matrix2, c: int, m: Matrix2) -> Matrix2:
    return tuple(tuple(w[i][j] + c * m[i][j] for j in range(2)) for i in range(2))  # type: ignore[return-value]


def spurious_companion(u: Tuple[int, int], v: Tuple[int, int]) -> Tuple[Matrix2, int]:
    """A same-value, nonzero-determinant lattice point near the target u (x) v."""
    d = u[0] * v[1] - u[1] * v[0]
    c = 1 if d + 1 != 0 else 2
    return add_scaled(rank_one(u, v), c, CARRY_COMMUTATOR), c


def digits_base(x: int, b: int) -> Tuple[int, int]:
    return (x % b, x // b)


def demo_digit_lattice(b: int, factor_pairs: Sequence[Tuple[int, int]]) -> None:
    print("=" * 74)
    print(f"4. DIGIT LATTICE (base {b}): the target is never isolated")
    print("=" * 74)
    assert digit_val(b, CARRY_COMMUTATOR) == 0
    assert sq_norm(CARRY_COMMUTATOR) == 2
    print(f"   carry commutator C = {CARRY_COMMUTATOR}: "
          f"Phi_b(C) = {digit_val(b, CARRY_COMMUTATOR)}, ||C||^2 = {sq_norm(CARRY_COMMUTATOR)}")
    print(f"{'p':>5} {'q':>5} {'N':>7} {'Phi(target)':>12} {'Phi(spurious)':>14}"
          f" {'det':>6} {'dist^2':>7} {'||target||^2':>13}")
    for p, q in factor_pairs:
        u, v = digits_base(p, b), digits_base(q, b)
        target = rank_one(u, v)
        assert digit_val(b, target) == p * q
        assert det2(target) == 0
        w, c = spurious_companion(u, v)
        dist = sq_norm(add_scaled(w, -1, target))
        assert digit_val(b, w) == digit_val(b, target)
        assert det2(w) != 0
        assert dist <= 8
        print(f"{p:>5} {q:>5} {p*q:>7} {digit_val(b, target):>12} {digit_val(b, w):>14}"
              f" {det2(w):>6} {dist:>7} {sq_norm(target):>13}")
    print("\n   The impostor stays at squared distance <= 8 while the target's own")
    print("   norm grows with the digits: short-vector search cannot separate them.\n")


# --------------------------------------------------------------------------
# 5. THE TROPICAL CORNER
# --------------------------------------------------------------------------


def demo_tropical_corner(pairs: Sequence[Tuple[int, int]]) -> None:
    print("=" * 74)
    print("5. TROPICAL CORNER: every divisor pair straddles sqrt(N)")
    print("=" * 74)
    print(f"{'p':>7} {'q':>7} {'N':>11} {'log2 p':>9} {'log2 N / 2':>11} {'log2 q':>9}")
    for p, q in pairs:
        lo, hi = min(p, q), max(p, q)
        n = p * q
        assert lo * lo <= n <= hi * hi
        assert (lo.bit_length() - 1) + (hi.bit_length() - 1) <= n.bit_length() - 1
        print(f"{lo:>7} {hi:>7} {n:>11} {lo.bit_length()-1:>9}"
              f" {(n.bit_length()-1)/2:>11.1f} {hi.bit_length()-1:>9}")
    print("\n   In min-plus coordinates the hyperbola xy = N is a line whose corner")
    print("   sits at sqrt(N); the noise floor 2/sqrt(N) is that corner.\n")


# --------------------------------------------------------------------------
# main
# --------------------------------------------------------------------------


def main() -> None:
    small_pairs: List[Tuple[int, int]] = [(3, 5), (3, 7), (5, 7), (5, 11), (7, 11), (11, 13)]
    big_pairs: List[Tuple[int, int]] = [
        (3, 65537), (101, 103), (1009, 1013), (10007, 10009), (65521, 65537)
    ]

    demo_agreement(small_pairs)
    demo_flipping_unit(5, 7)
    demo_zero_divisor_graph(5, 7)
    demo_zero_divisor_graph(7, 11)
    demo_noise_floor(small_pairs + big_pairs)
    demo_rho_collision(11, 13)
    demo_rho_collision(23, 29)
    demo_digit_lattice(10, [(11, 13), (23, 29), (37, 41), (59, 97)])
    demo_digit_lattice(16, [(19, 23), (101, 103), (211, 251)])
    demo_tropical_corner(small_pairs + big_pairs)

    print("=" * 74)
    print("All assertions passed: every closure verified on explicit numbers.")
    print("=" * 74)


if __name__ == "__main__":
    main()
