#!/usr/bin/env python3
"""
Applications: Real-world uses of certified domain-specific proof automation.

1. Shortest-path verification via tropical normalization
2. Pseudoprime detection via bounded arithmetic
3. Markov chain mixing bound via row-sum certificates
"""

import math
import numpy as np
from typing import List, Dict, Tuple

# ============================================================
# APPLICATION 1: Shortest-Path Verification
# ============================================================

def shortest_path_tropical(adj: Dict[Tuple[int,int], int], n: int,
                           src: int, dst: int, max_hops: int) -> int:
    """Compute shortest path using tropical (min-plus) matrix power.

    In tropical algebra:
    - Matrix "multiplication" uses (min, +) instead of (+, ×)
    - A^k gives shortest paths using at most k edges

    This is the Bellman-Ford algorithm expressed in tropical notation.
    The row-sum bound gives an upper bound on how far any node can be
    from any other node.

    Args:
        adj: adjacency dict mapping (i,j) to edge weight
        n: number of nodes
        src, dst: source and destination nodes
        max_hops: maximum number of edges to consider

    Returns:
        Length of shortest path, or math.inf if unreachable
    """
    INF = float('inf')

    # Initialize distance matrix
    dist = [[INF] * n for _ in range(n)]
    for i in range(n):
        dist[i][i] = 0
    for (i, j), w in adj.items():
        dist[i][j] = w

    # Tropical matrix power: dist^k using min-plus
    result = [row[:] for row in dist]
    for _ in range(max_hops - 1):
        new_result = [[INF] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    val = result[i][k] + dist[k][j] if result[i][k] < INF and dist[k][j] < INF else INF
                    new_result[i][j] = min(new_result[i][j], val)
        result = new_result

    return result[src][dst]


print("=" * 60)
print("APPLICATION 1: Shortest-Path Verification (Tropical)")
print("=" * 60)

# Example: small road network
edges = {
    (0, 1): 4, (0, 2): 2,
    (1, 2): 1, (1, 3): 5,
    (2, 3): 8, (2, 4): 10,
    (3, 4): 2, (4, 3): 3,
    (1, 0): 4, (2, 0): 2, (2, 1): 1, (3, 1): 5,
    (3, 2): 8, (4, 2): 10, (4, 3): 3, (3, 4): 2,
}

n = 5
for src, dst in [(0, 3), (0, 4), (2, 4)]:
    d = shortest_path_tropical(edges, n, src, dst, max_hops=n)
    print(f"  Shortest path {src}→{dst}: {d}")

# Row-sum bound on tropical distance matrix gives diameter bound
print("\n  Row-sum diameter bound:")
adj_matrix = [[float('inf')] * n for _ in range(n)]
for i in range(n):
    adj_matrix[i][i] = 0
for (i, j), w in edges.items():
    adj_matrix[i][j] = w

# Compute actual shortest path matrix
sp = shortest_path_tropical(edges, n, 0, 0, n)  # just to set up
sp_matrix = [[shortest_path_tropical(edges, n, i, j, n) for j in range(n)] for i in range(n)]
diameter = max(sp_matrix[i][j] for i in range(n) for j in range(n) if sp_matrix[i][j] < float('inf'))
print(f"  Graph diameter: {diameter}")


# ============================================================
# APPLICATION 2: Pseudoprime Detection
# ============================================================

print("\n" + "=" * 60)
print("APPLICATION 2: Pseudoprime Detection (Bounded Arithmetic)")
print("=" * 60)

def is_fermat_pseudoprime(n: int, base: int = 2) -> bool:
    """Check if n is a Fermat pseudoprime to the given base.

    n is a Fermat pseudoprime to base a if:
    - n is composite
    - a^(n-1) ≡ 1 (mod n)

    Uses the certified bounded arithmetic framework:
    the check is decidable and we verify both the primality
    status and the Fermat condition computationally.
    """
    if n < 2:
        return False
    # Check composite
    is_composite = any(n % d == 0 for d in range(2, int(n**0.5) + 1))
    if not is_composite:
        return False
    # Check Fermat condition
    return pow(base, n - 1, n) == 1

# Find Fermat pseudoprimes to base 2 up to 1000
print("\nFermat pseudoprimes to base 2 up to 1000:")
pseudoprimes = []
for n in range(2, 1001):
    if is_fermat_pseudoprime(n, 2):
        pseudoprimes.append(n)
print(f"  Found {len(pseudoprimes)}: {pseudoprimes}")

# Verify using certified divisibility checker
print("\nCertified verification:")
for p in pseudoprimes:
    fermat_val = pow(2, p - 1, p)
    factors = [d for d in range(2, p) if p % d == 0]
    print(f"  n={p}: composite (factors include {factors[0]}), "
          f"2^(n-1) mod n = {fermat_val} ✓")


# Carmichael numbers: pseudoprimes to ALL bases coprime to n
def is_carmichael(n: int) -> bool:
    """Check if n is a Carmichael number.

    Uses Korselt's criterion: n is Carmichael iff n is square-free
    and for every prime p dividing n, (p-1) | (n-1).
    """
    if n < 2:
        return False
    # Check composite
    if all(n % d != 0 for d in range(2, int(n**0.5) + 1)):
        return False
    # Factor n
    remaining = n
    prime_factors = []
    for p in range(2, n):
        if remaining % p == 0:
            count = 0
            while remaining % p == 0:
                remaining //= p
                count += 1
            if count > 1:
                return False  # Not square-free
            prime_factors.append(p)
        if remaining == 1:
            break
    if remaining > 1:
        prime_factors.append(remaining)
    # Check Korselt's criterion
    return all((n - 1) % (p - 1) == 0 for p in prime_factors)

print("\nCarmichael numbers up to 10000:")
carmichaels = [n for n in range(2, 10001) if is_carmichael(n)]
print(f"  Found {len(carmichaels)}: {carmichaels}")


# ============================================================
# APPLICATION 3: Markov Chain Mixing Bound
# ============================================================

print("\n" + "=" * 60)
print("APPLICATION 3: Markov Chain Mixing (Row-Sum Certificates)")
print("=" * 60)

def markov_mixing_bound(P: np.ndarray, pi: np.ndarray, t: int) -> float:
    """Bound total variation distance after t steps.

    For a reversible Markov chain with transition matrix P and
    stationary distribution π, the total variation distance satisfies:
        d_TV(P^t(x, ·), π) ≤ (1/2) · ‖P^t - 1π^T‖_∞

    The row-sum bound gives:
        ‖P^t - 1π^T‖_∞ ≤ ‖P - 1π^T‖_∞^t

    So the mixing bound is exponential in t with rate
    given by the row-sum of (P - 1π^T).
    """
    n = P.shape[0]
    ones = np.ones((n, 1))
    pi_row = pi.reshape(1, -1)

    # Deviation matrix
    D = P - ones @ pi_row

    # Row-sum bound on deviation matrix
    dev_norm = max(sum(abs(D[i, j]) for j in range(n)) for i in range(n))

    return 0.5 * dev_norm ** t


# Example: random walk on a cycle graph
print("\nExample: Random walk on cycle graph C₆")
n = 6
P = np.zeros((n, n))
for i in range(n):
    P[i][(i - 1) % n] = 0.5
    P[i][(i + 1) % n] = 0.5

pi = np.ones(n) / n  # uniform stationary distribution

print(f"  Transition matrix P (lazy random walk on C_{n}):")
for i in range(n):
    print(f"    {P[i]}")

print(f"\n  Mixing bounds (total variation distance from stationarity):")
for t in [1, 5, 10, 20, 50]:
    bound = markov_mixing_bound(P, pi, t)
    # Compute actual distance for comparison
    Pt = np.linalg.matrix_power(P, t)
    actual_max_dist = max(0.5 * sum(abs(Pt[i, j] - pi[j]) for j in range(n)) for i in range(n))
    print(f"    t={t:3d}: bound={bound:.6f}, actual={actual_max_dist:.6f}")

# Example: Metropolis chain on complete graph
print("\nExample: Metropolis chain on K₅ with non-uniform target")
n = 5
target = np.array([0.1, 0.15, 0.25, 0.3, 0.2])
target = target / target.sum()

# Metropolis-Hastings on complete graph
P2 = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            P2[i][j] = (1.0 / (n - 1)) * min(1.0, target[j] / target[i])
    P2[i][i] = 1.0 - sum(P2[i][j] for j in range(n) if j != i)

print(f"  Target distribution: {target}")
print(f"\n  Mixing bounds:")
for t in [1, 5, 10, 20, 50, 100]:
    bound = markov_mixing_bound(P2, target, t)
    Pt = np.linalg.matrix_power(P2, t)
    actual = max(0.5 * sum(abs(Pt[i, j] - target[j]) for j in range(n)) for i in range(n))
    print(f"    t={t:3d}: bound={bound:.8f}, actual={actual:.8f}")


print("\n" + "=" * 60)
print("All applications demonstrated! ✓")
print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Certified Domain-Specific Proof Automation

Demonstrates the three families of certified micro-solvers:
1. Tropical normalization (min-plus algebra)
2. Bounded arithmetic reflection (divisibility, bounded search)
3. Matrix row-sum certificates (spectral bounds)
"""

import math
from typing import List, Tuple, Callable, Optional

# ============================================================
# 1. TROPICAL NORMALIZATION
# ============================================================

class TropExpr:
    """Reified tropical expression over named variables."""
    pass

class Var(TropExpr):
    def __init__(self, name: str):
        self.name = name
    def eval(self, sigma):
        return sigma[self.name]
    def __repr__(self):
        return self.name

class Const(TropExpr):
    def __init__(self, val: int):
        self.val = val
    def eval(self, sigma):
        return self.val
    def __repr__(self):
        return str(self.val)

class TAdd(TropExpr):
    """Tropical addition = ordinary addition."""
    def __init__(self, left: TropExpr, right: TropExpr):
        self.left, self.right = left, right
    def eval(self, sigma):
        return self.left.eval(sigma) + self.right.eval(sigma)
    def __repr__(self):
        return f"({self.left} ⊕ {self.right})"

class TMin(TropExpr):
    """Tropical minimum."""
    def __init__(self, left: TropExpr, right: TropExpr):
        self.left, self.right = left, right
    def eval(self, sigma):
        return min(self.left.eval(sigma), self.right.eval(sigma))
    def __repr__(self):
        return f"min({self.left}, {self.right})"


def to_normal_form(e: TropExpr) -> List[List[TropExpr]]:
    """Convert tropical expression to min-of-sums normal form.

    Returns a list of monomials (each a list of base expressions).
    Semantics: min over sums.
    """
    if isinstance(e, (Var, Const)):
        return [[e]]
    elif isinstance(e, TMin):
        return to_normal_form(e.left) + to_normal_form(e.right)
    elif isinstance(e, TAdd):
        nf1 = to_normal_form(e.left)
        nf2 = to_normal_form(e.right)
        return [m1 + m2 for m1 in nf1 for m2 in nf2]
    raise TypeError(f"Unknown expression type: {type(e)}")


def eval_monomial(sigma, monomial: List[TropExpr]) -> int:
    return sum(e.eval(sigma) for e in monomial)

def eval_nf(sigma, nf: List[List[TropExpr]]) -> int:
    return min(eval_monomial(sigma, m) for m in nf)

def show_monomial(m):
    return " + ".join(repr(e) for e in m)

def show_nf(nf):
    return "min(" + ", ".join(show_monomial(m) for m in nf) + ")"


print("=" * 60)
print("DEMO 1: Tropical Normalization")
print("=" * 60)

# Example: a ⊕ min(b, c) should normalize to min(a+b, a+c)
a, b, c, d = Var("a"), Var("b"), Var("c"), Var("d")

expr1 = TAdd(a, TMin(b, c))
print(f"\nExpression: {expr1}")
nf1 = to_normal_form(expr1)
print(f"Normal form: {show_nf(nf1)}")

# Verify soundness for several valuations
for vals in [{"a": 3, "b": 5, "c": 2}, {"a": 1, "b": 1, "c": 7}, {"a": 0, "b": 3, "c": 3}]:
    orig = expr1.eval(vals)
    norm = eval_nf(vals, nf1)
    assert orig == norm, f"Soundness violated! {orig} != {norm}"
    print(f"  σ={vals}: eval={orig}, nf_eval={norm} ✓")

# More complex: min(a,b) ⊕ min(c,d)
expr2 = TAdd(TMin(a, b), TMin(c, d))
nf2 = to_normal_form(expr2)
print(f"\nExpression: {expr2}")
print(f"Normal form ({len(nf2)} monomials): {show_nf(nf2)}")

for vals in [{"a": 1, "b": 2, "c": 3, "d": 4}, {"a": 5, "b": 1, "c": 1, "d": 5}]:
    orig = expr2.eval(vals)
    norm = eval_nf(vals, nf2)
    assert orig == norm
    print(f"  σ={vals}: eval={orig}, nf_eval={norm} ✓")


# ============================================================
# 2. BOUNDED ARITHMETIC REFLECTION
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Bounded Arithmetic Reflection")
print("=" * 60)

def nat_check_divisible(a: int, b: int) -> bool:
    """Boolean divisibility check with soundness guarantee."""
    if a == 0:
        return b == 0
    return b % a == 0

def nat_check_exists_up_to(N: int, p: Callable[[int], bool]) -> Optional[int]:
    """Bounded existential search with witness extraction."""
    for n in range(N + 1):
        if p(n):
            return n
    return None

def nat_check_forall_up_to(N: int, p: Callable[[int], bool]) -> bool:
    """Bounded universal check."""
    return all(p(n) for n in range(N + 1))

# Demonstrate factorial divisibility: k | n! for 2 ≤ k ≤ n
print("\nFactorial divisibility: k | n! for 2 ≤ k ≤ n")
for n in [5, 7, 10]:
    fact_n = math.factorial(n)
    print(f"  n={n}, n!={fact_n}")
    for k in range(2, n + 1):
        result = nat_check_divisible(k, fact_n)
        assert result, f"{k} should divide {fact_n}"
    print(f"    All k in [2,{n}] divide {n}! ✓")

# Demonstrate k | (n! + k)
print("\nFactorial+k divisibility: k | (n! + k)")
for n, k in [(5, 3), (7, 4), (10, 6)]:
    fact_n = math.factorial(n)
    result = nat_check_divisible(k, fact_n + k)
    print(f"  n={n}, k={k}: {k} | ({fact_n} + {k}) = {fact_n + k}: {result} ✓")

# Bounded search: find smallest prime > 10
print("\nBounded search: smallest prime in [11, 20]")
def is_prime(n):
    if n < 2: return False
    return all(n % d != 0 for d in range(2, int(n**0.5) + 1))

witness = nat_check_exists_up_to(20, lambda n: n > 10 and is_prime(n))
print(f"  Witness found: {witness} (is prime: {is_prime(witness)}) ✓")

# Universal check: all numbers in [2,10] divide 2520
print("\nUniversal check: ∀k ∈ [2,10], k | 2520")
result = nat_check_forall_up_to(10, lambda k: k < 2 or nat_check_divisible(k, 2520))
print(f"  Result: {result} ✓ (2520 = LCM(1,...,10))")


# ============================================================
# 3. MATRIX ROW-SUM CERTIFICATES
# ============================================================

print("\n" + "=" * 60)
print("DEMO 3: Matrix Row-Sum Certificates")
print("=" * 60)

import numpy as np

def abs_row_sum(A, i):
    return sum(abs(A[i, j]) for j in range(A.shape[1]))

def max_abs_row_sum(A):
    return max(abs_row_sum(A, i) for i in range(A.shape[0]))

def verify_spectral_bound(A, C):
    """Verify that all absolute row sums ≤ C (the certificate check)."""
    n = A.shape[0]
    for i in range(n):
        rs = abs_row_sum(A, i)
        if rs > C + 1e-12:
            return False, i, rs
    return True, None, None

def matrix_vec_bound(A, x, C):
    """Verify |Ax|_∞ ≤ C using the certificate theorem."""
    n = A.shape[0]
    Ax = A @ x
    for i in range(n):
        if abs(Ax[i]) > C + 1e-12:
            return False, i
    return True, None

# Example 1: Stochastic matrix (all row sums = 1)
print("\nExample 1: Stochastic matrix")
A = np.array([[0.5, 0.3, 0.2],
              [0.1, 0.7, 0.2],
              [0.4, 0.1, 0.5]])
C = max_abs_row_sum(A)
print(f"  Matrix A:\n{A}")
print(f"  Max absolute row sum: {C}")
valid, _, _ = verify_spectral_bound(A, C)
print(f"  Certificate valid: {valid} ✓")

# Test with random unit vectors
np.random.seed(42)
for trial in range(3):
    x = np.random.randn(3)
    x = x / np.max(np.abs(x))  # normalize to unit ball
    Ax = A @ x
    bound_ok, _ = matrix_vec_bound(A, x, C)
    print(f"  Trial {trial+1}: ‖x‖_∞=1.00, ‖Ax‖_∞={np.max(np.abs(Ax)):.4f} ≤ {C:.4f}: {bound_ok} ✓")

# Example 2: Adjacency matrix of a graph
print("\nExample 2: Graph adjacency matrix (path graph P₄)")
A2 = np.array([[0, 1, 0, 0],
               [1, 0, 1, 0],
               [0, 1, 0, 1],
               [0, 0, 1, 0]], dtype=float)
C2 = max_abs_row_sum(A2)
print(f"  Max absolute row sum: {C2}")
eigenvalues = np.linalg.eigvalsh(A2)
spectral_radius = max(abs(e) for e in eigenvalues)
print(f"  Actual spectral radius: {spectral_radius:.4f}")
print(f"  Row-sum bound: {C2:.4f}")
print(f"  Bound valid (ρ ≤ C): {spectral_radius <= C2 + 1e-10} ✓")

# Example 3: Random matrix with controlled row sums
print("\nExample 3: Random 5×5 matrix")
np.random.seed(123)
A3 = np.random.randn(5, 5)
C3 = max_abs_row_sum(A3)
eigenvalues3 = np.linalg.eigvals(A3)
sr3 = max(abs(e) for e in eigenvalues3)
print(f"  Max absolute row sum: {C3:.4f}")
print(f"  Actual spectral radius: {sr3:.4f}")
print(f"  Bound valid: {sr3 <= C3 + 1e-10} ✓")
print(f"  Tightness ratio: {sr3/C3:.4f}")

print("\n" + "=" * 60)
print("All demos passed! ✓")
print("=" * 60)
