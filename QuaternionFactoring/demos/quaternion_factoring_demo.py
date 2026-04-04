#!/usr/bin/env python3
"""
Quaternion Factoring Demo
=========================

Demonstrates how quaternion norm multiplicativity connects to integer factoring.

Key ideas:
1. Every positive integer N can be written as a sum of four squares (Lagrange)
2. The norm of a quaternion product equals the product of norms
3. Therefore factoring N ↔ decomposing a quaternion of norm N into prime-norm factors
4. We build lattice L₄(N) and use LLL reduction to find short vectors
5. GCD extraction from short vectors yields factors

Usage:
    python quaternion_factoring_demo.py
"""

import math
import random
from functools import reduce
from typing import List, Tuple, Optional

# ============================================================
# Part 1: Integer Quaternions
# ============================================================

class IntQuaternion:
    """Integer quaternion a + bi + cj + dk."""

    def __init__(self, a: int, b: int = 0, c: int = 0, d: int = 0):
        self.a, self.b, self.c, self.d = a, b, c, d

    def norm(self) -> int:
        return self.a**2 + self.b**2 + self.c**2 + self.d**2

    def __mul__(self, other: 'IntQuaternion') -> 'IntQuaternion':
        return IntQuaternion(
            self.a*other.a - self.b*other.b - self.c*other.c - self.d*other.d,
            self.a*other.b + self.b*other.a + self.c*other.d - self.d*other.c,
            self.a*other.c - self.b*other.d + self.c*other.a + self.d*other.b,
            self.a*other.d + self.b*other.c - self.c*other.b + self.d*other.a
        )

    def conj(self) -> 'IntQuaternion':
        return IntQuaternion(self.a, -self.b, -self.c, -self.d)

    def __repr__(self):
        parts = []
        if self.a: parts.append(str(self.a))
        if self.b: parts.append(f"{self.b}i")
        if self.c: parts.append(f"{self.c}j")
        if self.d: parts.append(f"{self.d}k")
        return " + ".join(parts) if parts else "0"

    def __eq__(self, other):
        return (self.a, self.b, self.c, self.d) == (other.a, other.b, other.c, other.d)


def verify_norm_multiplicativity(q1: IntQuaternion, q2: IntQuaternion) -> bool:
    """Verify that N(q1 * q2) = N(q1) * N(q2)."""
    product = q1 * q2
    return product.norm() == q1.norm() * q2.norm()


# ============================================================
# Part 2: Four-Square Decomposition (Lagrange)
# ============================================================

def four_square_decomposition(n: int) -> Tuple[int, int, int, int]:
    """Find a, b, c, d such that a² + b² + c² + d² = n.
    Uses a simple brute-force search for small n."""
    if n == 0:
        return (0, 0, 0, 0)
    for a in range(int(math.isqrt(n)) + 1):
        for b in range(int(math.isqrt(n - a*a)) + 1):
            for c in range(int(math.isqrt(n - a*a - b*b)) + 1):
                d_sq = n - a*a - b*b - c*c
                if d_sq >= 0:
                    d = int(math.isqrt(d_sq))
                    if d*d == d_sq:
                        return (a, b, c, d)
    raise ValueError(f"No four-square decomposition found for {n}")


def three_square_decomposition(n: int) -> Optional[Tuple[int, int, int]]:
    """Find a, b, c such that a² + b² + c² = n, or None if impossible.
    By Legendre's theorem, impossible iff n = 4^a(8b+7)."""
    # Check Legendre condition
    m = n
    while m % 4 == 0:
        m //= 4
    if m % 8 == 7:
        return None

    for a in range(int(math.isqrt(n)) + 1):
        for b in range(int(math.isqrt(n - a*a)) + 1):
            c_sq = n - a*a - b*b
            if c_sq >= 0:
                c = int(math.isqrt(c_sq))
                if c*c == c_sq:
                    return (a, b, c)
    return None


# ============================================================
# Part 3: Pythagorean Quadruples from Parameters
# ============================================================

def quadruple_from_params(m: int, n: int, p: int, q: int) -> Tuple[int, int, int, int]:
    """Generate a Pythagorean quadruple from parameters (m, n, p, q).
    Returns (a, b, c, d) with a² + b² + c² = d²."""
    a = m*m + n*n - p*p - q*q
    b = 2*(m*q + n*p)
    c = 2*(n*q - m*p)
    d = m*m + n*n + p*p + q*q
    return (a, b, c, d)


def verify_quadruple(a: int, b: int, c: int, d: int) -> bool:
    """Verify a² + b² + c² = d²."""
    return a*a + b*b + c*c == d*d


# ============================================================
# Part 4: Lattice Construction and LLL
# ============================================================

def build_quadruple_lattice(N: int, dim: int = 3) -> List[List[int]]:
    """Build a lattice basis for L₄(N) = {(x,y,z) : x²+y²+z² ≡ 0 mod N}.
    Uses a structured basis construction."""
    # Simple basis: use identity scaled by N, plus structured vectors
    basis = []

    # Find a solution to x² + y² + z² ≡ 0 (mod N)
    solutions = []
    limit = min(int(math.isqrt(N)) + 1, 200)
    for x in range(limit):
        for y in range(limit):
            for z in range(1, limit):
                if (x*x + y*y + z*z) % N == 0:
                    solutions.append((x, y, z))
                    if len(solutions) >= dim:
                        break
            if len(solutions) >= dim:
                break
        if len(solutions) >= dim:
            break

    if not solutions:
        # Fallback: use the trivial lattice
        return [[N, 0, 0], [0, N, 0], [0, 0, N]]

    # Build basis from solutions and N-multiples
    basis = []
    for sol in solutions[:dim]:
        basis.append(list(sol))

    # Add N-scaled identity vectors to fill dimension
    while len(basis) < dim:
        v = [0] * dim
        v[len(basis)] = N
        basis.append(v)

    return basis[:dim]


def lll_reduce(basis: List[List[int]], delta: float = 0.99) -> List[List[int]]:
    """Simple LLL lattice reduction (Lenstra-Lenstra-Lovász).
    Returns a reduced basis with short vectors."""
    n = len(basis)
    if n == 0:
        return basis

    B = [list(v) for v in basis]  # Copy
    dim = len(B[0])

    def dot(u, v):
        return sum(a*b for a, b in zip(u, v))

    def proj_coeff(u, v):
        d = dot(u, u)
        return dot(v, u) / d if d != 0 else 0

    def sub_proj(v, u, mu):
        return [v[i] - mu * u[i] for i in range(len(v))]

    # Gram-Schmidt
    def gram_schmidt(B):
        n = len(B)
        Q = [list(b) for b in B]
        mu = [[0.0]*n for _ in range(n)]
        for i in range(n):
            for j in range(i):
                mu[i][j] = proj_coeff(Q[j], B[i])
                Q[i] = sub_proj(Q[i], Q[j], mu[i][j])
        return Q, mu

    k = 1
    while k < n:
        Q, mu = gram_schmidt(B)

        # Size reduction
        for j in range(k-1, -1, -1):
            if abs(mu[k][j]) > 0.5:
                r = round(mu[k][j])
                B[k] = [B[k][i] - r * B[j][i] for i in range(dim)]
                Q, mu = gram_schmidt(B)

        # Lovász condition
        lhs = dot(Q[k], Q[k])
        rhs = (delta - mu[k][k-1]**2) * dot(Q[k-1], Q[k-1])

        if lhs >= rhs:
            k += 1
        else:
            B[k], B[k-1] = B[k-1], B[k]
            k = max(k-1, 1)

    # Convert back to int
    return [[round(x) for x in v] for v in B]


def vector_norm(v: List[int]) -> float:
    return math.sqrt(sum(x*x for x in v))


# ============================================================
# Part 5: Factor Extraction
# ============================================================

def extract_factor(N: int, vectors: List[List[int]]) -> Optional[int]:
    """Try to extract a factor of N from short lattice vectors."""
    candidates = set()

    for v in vectors:
        # Sum of squares
        s = sum(x*x for x in v)
        if s > 0:
            candidates.add(s)
            # Try GCD
            g = math.gcd(s, N)
            if 1 < g < N:
                return g

        # Pairwise sums of squares
        for i in range(len(v)):
            for j in range(i+1, len(v)):
                s2 = v[i]**2 + v[j]**2
                if s2 > 0:
                    g = math.gcd(s2, N)
                    if 1 < g < N:
                        return g

        # Individual coordinates
        for x in v:
            if x != 0:
                g = math.gcd(abs(x), N)
                if 1 < g < N:
                    return g

    # Try linear combinations
    for i in range(len(vectors)):
        for j in range(i+1, len(vectors)):
            for a in range(-2, 3):
                for b in range(-2, 3):
                    if a == 0 and b == 0:
                        continue
                    combo = [a*vectors[i][k] + b*vectors[j][k] for k in range(len(vectors[0]))]
                    s = sum(x*x for x in combo)
                    if s > 0:
                        g = math.gcd(s, N)
                        if 1 < g < N:
                            return g

    return None


# ============================================================
# Part 6: Full Quaternion Factoring Pipeline
# ============================================================

def quaternion_factor(N: int, verbose: bool = True) -> Optional[int]:
    """Attempt to factor N using the quaternion/quadruple lattice method."""
    if N < 4:
        return None

    if verbose:
        print(f"\n{'='*60}")
        print(f"Quaternion Factoring: N = {N}")
        print(f"{'='*60}")

    # Step 1: Build the lattice
    basis = build_quadruple_lattice(N)
    if verbose:
        print(f"\nStep 1: Lattice basis constructed (dim={len(basis)})")
        for i, v in enumerate(basis):
            print(f"  b_{i} = {v}  (norm = {vector_norm(v):.2f})")

    # Step 2: LLL reduction
    reduced = lll_reduce(basis)
    if verbose:
        print(f"\nStep 2: LLL-reduced basis:")
        for i, v in enumerate(reduced):
            print(f"  b_{i} = {v}  (norm = {vector_norm(v):.2f})")

    shortest = min(vector_norm(v) for v in reduced if any(x != 0 for x in v))
    sqrt_N = math.sqrt(N)
    if verbose:
        print(f"\n  Shortest vector norm: {shortest:.4f}")
        print(f"  √N = {sqrt_N:.4f}")
        print(f"  Ratio: {shortest/sqrt_N:.4f}")

    # Step 3: Factor extraction
    factor = extract_factor(N, reduced)
    if verbose:
        if factor:
            print(f"\nStep 3: Factor found! {N} = {factor} × {N//factor}")
        else:
            print(f"\nStep 3: No factor extracted from this basis.")

    return factor


# ============================================================
# Part 7: Experiments
# ============================================================

def generate_semiprime(bits: int) -> Tuple[int, int, int]:
    """Generate a random semiprime N = p * q of approximately `bits` bits."""
    half = bits // 2
    while True:
        p = random.randrange(2**(half-1), 2**half)
        q = random.randrange(2**(half-1), 2**half)
        if p != q and all(p % i != 0 for i in range(2, min(p, 100))) and \
           all(q % i != 0 for i in range(2, min(q, 100))):
            # Simple primality check for small numbers
            if isprime(p) and isprime(q):
                return p * q, p, q


def isprime(n: int) -> bool:
    """Simple primality test."""
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i+2) == 0:
            return False
        i += 6
    return True


def run_experiments():
    """Run the main experimental suite."""
    print("=" * 70)
    print("QUATERNION FACTORING: EXPERIMENTAL SUITE")
    print("=" * 70)

    # Experiment 1: Norm multiplicativity verification
    print("\n" + "─"*70)
    print("Experiment 1: Verify Norm Multiplicativity")
    print("─"*70)
    for _ in range(5):
        q1 = IntQuaternion(random.randint(-10, 10), random.randint(-10, 10),
                           random.randint(-10, 10), random.randint(-10, 10))
        q2 = IntQuaternion(random.randint(-10, 10), random.randint(-10, 10),
                           random.randint(-10, 10), random.randint(-10, 10))
        ok = verify_norm_multiplicativity(q1, q2)
        print(f"  N({q1}) = {q1.norm()}, N({q2}) = {q2.norm()}, "
              f"N(q1·q2) = {(q1*q2).norm()}, multiplicative: {ok}")

    # Experiment 2: Four-square decompositions
    print("\n" + "─"*70)
    print("Experiment 2: Four-Square Decompositions (Lagrange)")
    print("─"*70)
    for n in [7, 15, 23, 42, 100, 143, 255]:
        a, b, c, d = four_square_decomposition(n)
        print(f"  {n} = {a}² + {b}² + {c}² + {d}² = {a*a + b*b + c*c + d*d}")

    # Experiment 3: Pythagorean quadruples from parameters
    print("\n" + "─"*70)
    print("Experiment 3: Pythagorean Quadruples from Parameters")
    print("─"*70)
    params = [(1, 1, 1, 0), (2, 1, 0, 1), (1, 2, 1, 1), (3, 1, 2, 1), (2, 3, 1, 2)]
    for m, n, p, q in params:
        a, b, c, d = quadruple_from_params(m, n, p, q)
        valid = verify_quadruple(a, b, c, d)
        print(f"  ({m},{n},{p},{q}) → ({a},{b},{c},{d}), "
              f"check: {a}²+{b}²+{c}² = {a*a+b*b+c*c}, {d}² = {d*d}, valid: {valid}")

    # Experiment 4: Three-square representability
    print("\n" + "─"*70)
    print("Experiment 4: Three-Square Representability (Legendre)")
    print("─"*70)
    representable = 0
    total = 1000
    for n in range(1, total + 1):
        result = three_square_decomposition(n)
        if result is not None:
            representable += 1
    print(f"  {representable}/{total} integers in [1, {total}] are sums of three squares")
    print(f"  (Expected: ~{total * 5 // 6} by Legendre's theorem)")

    # Experiment 5: Quaternion factoring on small semiprimes
    print("\n" + "─"*70)
    print("Experiment 5: Quaternion Factoring on Semiprimes")
    print("─"*70)
    semiprimes = [
        (15, 3, 5), (21, 3, 7), (35, 5, 7), (77, 7, 11),
        (91, 7, 13), (143, 11, 13), (221, 13, 17), (323, 17, 19),
        (437, 19, 23), (667, 23, 29), (899, 29, 31), (1147, 31, 37),
    ]

    successes = 0
    for N, p, q in semiprimes:
        factor = quaternion_factor(N, verbose=False)
        ok = factor is not None and (N % factor == 0)
        if ok:
            successes += 1
        status = f"✓ {factor} × {N//factor}" if ok else "✗ failed"
        print(f"  N = {N:5d} = {p} × {q:3d}  →  {status}")

    print(f"\n  Success rate: {successes}/{len(semiprimes)} ({100*successes/len(semiprimes):.1f}%)")

    # Experiment 6: Scaling analysis
    print("\n" + "─"*70)
    print("Experiment 6: Shortest Vector Scaling Analysis")
    print("─"*70)
    print(f"  {'N':>10s}  {'||v_min||':>10s}  {'√N':>10s}  {'N^(1/3)':>10s}  {'ratio':>8s}  {'α_est':>6s}")
    for bits in range(4, 16):
        N_vals = []
        norms = []
        for _ in range(20):
            # Generate random odd composite
            while True:
                p = random.choice([x for x in range(2**(bits//2-1), 2**(bits//2)) if isprime(x)])
                q = random.choice([x for x in range(2**(bits//2-1), 2**(bits//2)) if isprime(x)])
                if p != q:
                    break
            N = p * q
            basis = build_quadruple_lattice(N)
            reduced = lll_reduce(basis)
            nz = [vector_norm(v) for v in reduced if any(x != 0 for x in v)]
            if nz:
                norms.append(min(nz))
                N_vals.append(N)

        if norms:
            avg_norm = sum(norms) / len(norms)
            avg_N = sum(N_vals) / len(N_vals)
            sqrt_N = math.sqrt(avg_N)
            cbrt_N = avg_N ** (1/3)
            ratio = avg_norm / sqrt_N
            alpha = math.log(avg_norm) / math.log(avg_N) if avg_N > 1 else 0
            print(f"  {avg_N:10.0f}  {avg_norm:10.2f}  {sqrt_N:10.2f}  {cbrt_N:10.2f}  {ratio:8.4f}  {alpha:6.3f}")

    # Experiment 7: Quaternion decomposition of composites
    print("\n" + "─"*70)
    print("Experiment 7: Quaternion Decomposition of Composites")
    print("─"*70)
    for N in [15, 35, 77, 143]:
        a1, b1, c1, d1 = four_square_decomposition(N)
        q_N = IntQuaternion(a1, b1, c1, d1)
        print(f"  N = {N}: quaternion ({a1}, {b1}, {c1}, {d1}), norm = {q_N.norm()}")

        # Find factor decompositions
        for p in range(2, N):
            if N % p == 0:
                q_val = N // p
                try:
                    ap, bp, cp, dp = four_square_decomposition(p)
                    aq, bq, cq, dq = four_square_decomposition(q_val)
                    qp = IntQuaternion(ap, bp, cp, dp)
                    qq = IntQuaternion(aq, bq, cq, dq)
                    prod = qp * qq
                    print(f"    {N} = {p}×{q_val}: "
                          f"q_p=({ap},{bp},{cp},{dp}) [norm={qp.norm()}] × "
                          f"q_q=({aq},{bq},{cq},{dq}) [norm={qq.norm()}] = "
                          f"({prod.a},{prod.b},{prod.c},{prod.d}) [norm={prod.norm()}]")
                except:
                    pass
                break

    print("\n" + "="*70)
    print("ALL EXPERIMENTS COMPLETE")
    print("="*70)


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    random.seed(42)
    run_experiments()
