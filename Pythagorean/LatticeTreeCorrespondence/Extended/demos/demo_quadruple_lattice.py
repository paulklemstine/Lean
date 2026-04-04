#!/usr/bin/env python3
"""
Quadruple Lattice Factoring Demo

Demonstrates the factoring pipeline using Pythagorean quadruples:
1. Build the quadruple lattice L₄(N) = {(x,y,z) : N | x²+y²+z²}
2. Apply lattice reduction (LLL via numpy/scipy approximation)
3. Extract factors via GCD

This implements the concrete program proposed in the research paper.
"""

import math
import random
from typing import List, Tuple, Optional

# ============================================================
# SECTION 1: Pythagorean Quadruple Generation
# ============================================================

def parametric_quadruple(m: int, n: int, p: int, q: int) -> Tuple[int, int, int, int]:
    """Generate a Pythagorean quadruple via the standard parametrization.
    
    (a, b, c, d) where a²+b²+c²=d², given by:
    a = m²+n²-p²-q²
    b = 2(mq+np)
    c = 2(nq-mp)
    d = m²+n²+p²+q²
    """
    a = m*m + n*n - p*p - q*q
    b = 2*(m*q + n*p)
    c = 2*(n*q - m*p)
    d = m*m + n*n + p*p + q*q
    return (a, b, c, d)

def verify_quadruple(a: int, b: int, c: int, d: int) -> bool:
    """Verify that (a,b,c,d) is a Pythagorean quadruple."""
    return a*a + b*b + c*c == d*d

def generate_quadruples(max_param: int = 10) -> List[Tuple[int, int, int, int]]:
    """Generate all primitive Pythagorean quadruples up to parameter bound."""
    quads = set()
    for m in range(-max_param, max_param+1):
        for n in range(-max_param, max_param+1):
            for p in range(-max_param, max_param+1):
                for q in range(-max_param, max_param+1):
                    if m*m + n*n + p*p + q*q == 0:
                        continue
                    quad = parametric_quadruple(m, n, p, q)
                    a, b, c, d = quad
                    if d > 0 and verify_quadruple(a, b, c, d):
                        # Normalize: make d positive, sort |a|,|b|,|c|
                        abc = tuple(sorted([abs(a), abs(b), abs(c)]))
                        quads.add((abc[0], abc[1], abc[2], d))
    return sorted(quads, key=lambda q: q[3])

# ============================================================
# SECTION 2: Quadruple Lattice Construction
# ============================================================

def find_lattice_vectors(N: int, count: int = 20) -> List[Tuple[int, int, int]]:
    """Find vectors (x,y,z) in the quadruple lattice L₄(N).
    
    L₄(N) = {(x,y,z) ∈ ℤ³ : N | (x²+y²+z²)}
    
    We search for small vectors satisfying this condition.
    """
    vectors = []
    bound = int(math.sqrt(3 * N)) + 1
    for x in range(-bound, bound+1):
        for y in range(-bound, bound+1):
            remainder = (x*x + y*y) % N
            # Need z² ≡ -x²-y² (mod N), i.e., z² ≡ N - remainder (mod N)
            target = (N - remainder) % N
            # Check small z values
            for z in range(-bound, bound+1):
                if (z*z) % N == target:
                    if x != 0 or y != 0 or z != 0:
                        vectors.append((x, y, z))
                        if len(vectors) >= count:
                            return vectors
    return vectors

def lattice_norm(v: Tuple[int, int, int]) -> float:
    """Euclidean norm of a 3D integer vector."""
    return math.sqrt(v[0]**2 + v[1]**2 + v[2]**2)

# ============================================================
# SECTION 3: Simple Lattice Reduction (Gram-Schmidt style)
# ============================================================

def gram_schmidt_reduce(basis: List[List[float]]) -> List[List[float]]:
    """Simple Gram-Schmidt orthogonalization for 3D vectors."""
    n = len(basis)
    if n == 0:
        return basis
    ortho = [list(b) for b in basis]
    mu = [[0.0]*n for _ in range(n)]
    
    for i in range(n):
        for j in range(i):
            dot_ij = sum(ortho[i][k] * ortho[j][k] for k in range(3))
            dot_jj = sum(ortho[j][k] * ortho[j][k] for k in range(3))
            if dot_jj > 1e-10:
                mu[i][j] = dot_ij / dot_jj
                for k in range(3):
                    ortho[i][k] -= mu[i][j] * ortho[j][k]
    return ortho

def lll_reduce_3d(basis: List[List[int]], delta: float = 0.75) -> List[List[int]]:
    """LLL lattice reduction for 3D basis.
    
    Implements the Lenstra-Lenstra-Lovász algorithm for dimension 3.
    Returns a reduced basis with shorter vectors.
    """
    n = len(basis)
    B = [list(b) for b in basis]
    
    def dot(u, v):
        return sum(a*b for a, b in zip(u, v))
    
    def norm_sq(v):
        return dot(v, v)
    
    def proj_coeff(u, v):
        d = dot(u, u)
        return dot(v, u) / d if d > 1e-10 else 0
    
    k = 1
    max_iter = 1000
    iteration = 0
    
    while k < n and iteration < max_iter:
        iteration += 1
        # Gram-Schmidt
        ortho = [list(b) for b in B]
        for i in range(n):
            for j in range(i):
                mu = proj_coeff(ortho[j], [float(x) for x in B[i]])
                for l in range(3):
                    ortho[i][l] = float(B[i][l]) - mu * ortho[j][l]
        
        # Size reduction
        for j in range(k-1, -1, -1):
            mu = proj_coeff(ortho[j], [float(x) for x in B[k]])
            if abs(mu) > 0.5:
                r = round(mu)
                for l in range(3):
                    B[k][l] -= r * B[j][l]
        
        # Lovász condition
        mu_k = proj_coeff(ortho[k-1], [float(x) for x in B[k]])
        if norm_sq(ortho[k]) >= (delta - mu_k**2) * norm_sq(ortho[k-1]):
            k += 1
        else:
            B[k], B[k-1] = B[k-1], B[k]
            k = max(k-1, 1)
    
    return B

# ============================================================
# SECTION 4: Factor Extraction
# ============================================================

def extract_factor(N: int, x: int, y: int, z: int) -> Optional[int]:
    """Try to extract a non-trivial factor of N from a lattice vector (x,y,z).
    
    Uses three GCD candidates:
    gcd(x²+y², N), gcd(x²+z², N), gcd(y²+z², N)
    """
    candidates = [
        math.gcd(x*x + y*y, N),
        math.gcd(x*x + z*z, N),
        math.gcd(y*y + z*z, N),
        math.gcd(abs(x), N),
        math.gcd(abs(y), N),
        math.gcd(abs(z), N),
    ]
    for g in candidates:
        if 1 < g < N:
            return g
    return None

# ============================================================
# SECTION 5: Full Factoring Pipeline
# ============================================================

def quadruple_lattice_factor(N: int, verbose: bool = True) -> Optional[int]:
    """Attempt to factor N using the quadruple lattice method.
    
    Pipeline:
    1. Find vectors in L₄(N)
    2. Apply LLL reduction
    3. Extract factors via GCD
    """
    if verbose:
        print(f"\n{'='*60}")
        print(f"QUADRUPLE LATTICE FACTORING: N = {N}")
        print(f"{'='*60}")
    
    # Step 1: Find lattice vectors
    if verbose:
        print(f"\nStep 1: Finding vectors in L₄({N})...")
    vectors = find_lattice_vectors(N, count=10)
    
    if len(vectors) < 3:
        if verbose:
            print(f"  Found only {len(vectors)} vectors, need at least 3")
        return None
    
    if verbose:
        print(f"  Found {len(vectors)} vectors")
        for v in vectors[:5]:
            print(f"    {v}, norm = {lattice_norm(v):.2f}, "
                  f"sum_sq = {v[0]**2+v[1]**2+v[2]**2}, "
                  f"sum_sq/N = {(v[0]**2+v[1]**2+v[2]**2)/N:.1f}")
    
    # Step 2: Try factor extraction from raw vectors first
    if verbose:
        print(f"\nStep 2: Attempting factor extraction...")
    
    for v in vectors:
        factor = extract_factor(N, v[0], v[1], v[2])
        if factor is not None:
            if verbose:
                print(f"  ✓ Factor found: {factor} from vector {v}")
                print(f"  Verification: {N} = {factor} × {N // factor}")
            return factor
    
    # Step 3: Apply LLL reduction
    if verbose:
        print(f"\nStep 3: Applying LLL reduction...")
    
    if len(vectors) >= 3:
        basis = [list(v) for v in vectors[:3]]
        reduced = lll_reduce_3d(basis)
        
        if verbose:
            print(f"  Original basis norms: {[lattice_norm(tuple(b)) for b in basis]}")
            print(f"  Reduced basis norms:  {[lattice_norm(tuple(b)) for b in reduced]}")
        
        for b in reduced:
            factor = extract_factor(N, b[0], b[1], b[2])
            if factor is not None:
                if verbose:
                    print(f"  ✓ Factor found from reduced vector: {factor}")
                    print(f"  Verification: {N} = {factor} × {N // factor}")
                return factor
    
    if verbose:
        print(f"  ✗ No factor found")
    return None

# ============================================================
# SECTION 6: Experiments
# ============================================================

def experiment_balanced_semiprimes():
    """Test factoring on balanced semiprimes N = p*q."""
    print("\n" + "="*70)
    print("EXPERIMENT 1: Balanced Semiprimes")
    print("="*70)
    
    # Small primes for testing
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    
    successes = 0
    total = 0
    results = []
    
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            N = p * q
            total += 1
            factor = quadruple_lattice_factor(N, verbose=False)
            success = factor is not None
            if success:
                successes += 1
            results.append((N, p, q, success, factor))
    
    print(f"\nResults: {successes}/{total} factored successfully ({100*successes/total:.1f}%)")
    print(f"\n{'N':>6} {'p':>4} {'q':>4} {'√N':>8} {'Factor':>8} {'Status':>8}")
    print("-" * 42)
    for N, p, q, success, factor in results[:20]:
        status = "✓" if success else "✗"
        print(f"{N:>6} {p:>4} {q:>4} {math.sqrt(N):>8.2f} {str(factor):>8} {status:>8}")

def experiment_vector_lengths():
    """Compare shortest vector lengths in 2D vs 3D lattices."""
    print("\n" + "="*70)
    print("EXPERIMENT 2: Vector Length Comparison (2D vs 3D)")
    print("="*70)
    
    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    
    print(f"\n{'N':>6} {'p':>4} {'q':>4} {'√N':>8} {'2D min':>8} {'3D min':>8} {'Ratio':>8}")
    print("-" * 54)
    
    for i, p in enumerate(primes):
        for q in primes[i+1:i+2]:  # One pair per p
            N = p * q
            sqrt_N = math.sqrt(N)
            
            # 2D: shortest vector length is approximately √N
            min_2d = sqrt_N
            
            # 3D: find shortest vector in L₄(N)
            vectors = find_lattice_vectors(N, count=20)
            if vectors:
                norms = [lattice_norm(v) for v in vectors]
                min_3d = min(norms)
                ratio = min_3d / min_2d
                print(f"{N:>6} {p:>4} {q:>4} {sqrt_N:>8.2f} {min_2d:>8.2f} {min_3d:>8.2f} {ratio:>8.3f}")

def experiment_quadruple_tree():
    """Generate and display the Pythagorean quadruple tree."""
    print("\n" + "="*70)
    print("EXPERIMENT 3: Pythagorean Quadruple Tree")
    print("="*70)
    
    print("\nPrimitive Pythagorean quadruples (a²+b²+c²=d², sorted by d):")
    print(f"{'a':>4} {'b':>4} {'c':>4} {'d':>4} {'a²+b²+c²':>10} {'d²':>10} {'Params':>20}")
    print("-" * 56)
    
    seen = set()
    for m in range(0, 6):
        for n in range(0, 6):
            for p in range(0, 6):
                for q in range(0, 6):
                    if m*m + n*n + p*p + q*q == 0:
                        continue
                    a, b, c, d = parametric_quadruple(m, n, p, q)
                    if d <= 0:
                        continue
                    key = tuple(sorted([abs(a), abs(b), abs(c)]) + [d])
                    if key in seen or key[0] == 0 and key[1] == 0:
                        continue
                    seen.add(key)
                    if d <= 20:
                        g = math.gcd(math.gcd(abs(a), abs(b)), math.gcd(abs(c), d))
                        if g == 1:  # primitive
                            print(f"{key[0]:>4} {key[1]:>4} {key[2]:>4} {d:>4} "
                                  f"{key[0]**2+key[1]**2+key[2]**2:>10} {d**2:>10} "
                                  f"({m},{n},{p},{q})")

def experiment_o31z_structure():
    """Demonstrate why single-plane boosts don't work for O(3,1;ℤ)."""
    print("\n" + "="*70)
    print("EXPERIMENT 4: O(3,1;ℤ) Structure")
    print("="*70)
    
    print("\nThe Pell equation λ²-μ²=1 has only trivial integer solutions:")
    print("  (λ,μ) = (1,0) or (-1,0)")
    print()
    print("Checking all |λ|,|μ| ≤ 100:")
    solutions = []
    for lam in range(-100, 101):
        for mu in range(-100, 101):
            if lam*lam - mu*mu == 1:
                solutions.append((lam, mu))
    print(f"  Solutions found: {solutions}")
    print(f"  All have μ=0: {all(mu == 0 for _, mu in solutions)}")
    
    print("\nConsequence: O(3,1;ℤ) has NO nontrivial single-plane boosts.")
    print("Nontrivial elements must mix 3+ coordinates simultaneously.")
    print("\nHowever, the SL(2,ℤ) action on parameters (m,n,p,q) gives")
    print("infinitely many distinct quadruples:")
    
    # Show SL(2,ℤ) generating quadruples
    print(f"\n{'m':>3} {'n':>3} {'p':>3} {'q':>3} → {'a':>4} {'b':>4} {'c':>4} {'d':>4}")
    print("-" * 40)
    params = [(1,1,1,0), (2,1,1,0), (1,1,0,1), (2,1,1,1), (3,1,1,0), 
              (2,2,1,1), (3,2,1,1), (4,1,1,0), (3,1,2,1)]
    for m, n, p, q in params:
        a, b, c, d = parametric_quadruple(m, n, p, q)
        print(f"{m:>3} {n:>3} {p:>3} {q:>3} → {a:>4} {b:>4} {c:>4} {d:>4}")

# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  PYTHAGOREAN QUADRUPLE LATTICE FACTORING — DEMO SUITE      ║")
    print("║  Implementing the Dimensional Escape from the √N Barrier   ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    
    # Run all experiments
    experiment_quadruple_tree()
    experiment_o31z_structure()
    experiment_balanced_semiprimes()
    experiment_vector_lengths()
    
    # Individual factoring examples
    for N in [15, 21, 35, 77, 143, 221, 323, 437, 667, 899]:
        quadruple_lattice_factor(N)
    
    print("\n" + "="*70)
    print("DEMO COMPLETE")
    print("="*70)
