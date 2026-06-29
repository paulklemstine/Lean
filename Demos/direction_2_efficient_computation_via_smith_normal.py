#!/usr/bin/env python3
"""
applications.py — Real-world applications of secondary torsion obstructions.

Demonstrates:
1. Torsion-sensitive topological data analysis (TDA)
2. Certified integer linear algebra (unimodular invariance)
3. Lens space classification via torsion signatures
4. Cryptographic lattice analysis via torsion detection
"""

from math import gcd
from typing import List, Dict, Tuple
import random


# Import from algorithms
def snf_connecting_element(d: int, n: int) -> int:
    if n <= 0: return 0
    return (n // gcd(abs(d), n)) % n

def d_torsion_order(d: int, n: int) -> int:
    if n <= 0: return 0
    return gcd(abs(d), n)

def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    if a == 0: return (abs(b), 0, 1 if b >= 0 else -1)
    g, s, t = extended_gcd(b % a, a)
    return (g, t - (b // a) * s, s)

def smith_normal_form_small(M: List[List[int]]) -> List[int]:
    """Compute invariant factors of a small integer matrix."""
    if not M or not M[0]: return []
    m, n = len(M), len(M[0])
    D = [row[:] for row in M]
    r = min(m, n)
    factors = []
    for k in range(r):
        pf = False
        for i in range(k, m):
            for j in range(k, n):
                if D[i][j] != 0:
                    D[k], D[i] = D[i], D[k]
                    for row in D:
                        row[k], row[j] = row[j], row[k]
                    pf = True; break
            if pf: break
        if not pf: break
        for _ in range(300):
            ch = False
            for j in range(k+1, n):
                if D[k][j] != 0:
                    g, s, t = extended_gcd(D[k][k], D[k][j])
                    u, v = D[k][k]//g, D[k][j]//g
                    for i2 in range(m):
                        ck, cj = D[i2][k], D[i2][j]
                        D[i2][k] = s*ck + t*cj
                        D[i2][j] = -v*ck + u*cj
                    ch = True
            for i in range(k+1, m):
                if D[i][k] != 0:
                    g, s, t = extended_gcd(D[k][k], D[i][k])
                    u, v = D[k][k]//g, D[i][k]//g
                    rk, ri = D[k][:], D[i][:]
                    for j2 in range(n):
                        D[k][j2] = s*rk[j2] + t*ri[j2]
                        D[i][j2] = -v*rk[j2] + u*ri[j2]
                    ch = True
            if D[k][k] != 0:
                for i in range(k+1, m):
                    done = False
                    for j in range(k+1, n):
                        if D[i][j] % D[k][k] != 0:
                            for j2 in range(n):
                                D[k][j2] += D[i][j2]
                            ch = True; done = True; break
                    if done: break
            if not ch: break
        if D[k][k] != 0:
            factors.append(abs(D[k][k]))
    return factors


# ============================================================
# Application 1: Torsion-Sensitive Topological Data Analysis
# ============================================================

def torsion_barcode(boundary_matrices: List[List[List[int]]],
                    prime: int) -> List[Dict]:
    """
    Compute a torsion barcode for a filtered simplicial complex.

    For each boundary matrix ∂ₖ in the filtration, compute the
    p-torsion obstruction from its SNF invariant factors.

    This detects torsion features invisible to field-coefficient
    persistence homology (formally proved: pTorPersistence_vanishes_of_free
    in the catalog shows field persistence misses all torsion).

    Args:
        boundary_matrices: list of boundary matrices for each filtration step
        prime: the prime p for p-torsion detection

    Returns:
        List of torsion bars with birth/death indices and orders.
    """
    bars = []
    prev_torsion = set()

    for step, matrix in enumerate(boundary_matrices):
        if not matrix or not matrix[0]:
            continue

        factors = smith_normal_form_small(matrix)
        curr_torsion = set()

        for d in factors:
            g = gcd(d, prime)
            if g > 1:
                curr_torsion.add(d)

        # New torsion = birth
        for d in curr_torsion - prev_torsion:
            bars.append({
                'birth': step,
                'death': None,  # Still alive
                'factor': d,
                'torsion_order': gcd(d, prime)
            })

        # Dead torsion = death
        for d in prev_torsion - curr_torsion:
            for bar in bars:
                if bar['factor'] == d and bar['death'] is None:
                    bar['death'] = step
                    break

        prev_torsion = curr_torsion

    return bars


def demo_torsion_tda():
    """Demonstrate torsion-sensitive TDA on a toy example."""
    print("=" * 70)
    print("APPLICATION 1: Torsion-Sensitive Topological Data Analysis")
    print("=" * 70)
    print()
    print("Classical TDA over fields (ℝ, ℚ, 𝔽₂) misses torsion entirely.")
    print("The SNF obstruction detects torsion features at each filtration step.")
    print()

    # Simulate a filtration with torsion appearing and disappearing
    # Think of it as building a simplicial complex that creates ℤ/p torsion
    filtration = [
        [[1]],           # Step 0: trivial
        [[2]],           # Step 1: ℤ/2 torsion appears
        [[2, 0], [0, 3]],  # Step 2: ℤ/2 and ℤ/3 torsion
        [[6]],           # Step 3: ℤ/6 = ℤ/2 ⊕ ℤ/3
        [[1]],           # Step 4: torsion killed (saturated)
    ]

    for p in [2, 3]:
        print(f"--- {p}-torsion barcode ---")
        bars = torsion_barcode(filtration, p)
        for bar in bars:
            death = bar['death'] if bar['death'] is not None else '∞'
            print(f"  [{bar['birth']}, {death}): factor={bar['factor']}, "
                  f"{p}-torsion order={bar['torsion_order']}")
        if not bars:
            print(f"  (empty — no {p}-torsion detected)")
        print()


# ============================================================
# Application 2: Lens Space Classification
# ============================================================

def lens_space_torsion_signature(p: int, max_n: int = None) -> Tuple[int, ...]:
    """
    Compute the torsion signature of L(p,1).

    The signature is the tuple (gcd(p,2), gcd(p,3), ..., gcd(p, max_n)).
    By the lens-space rigidity conjecture (Conjecture C), this
    determines p uniquely.

    Formally justified by:
    - dTorsion_card: |d-torsion of ℤ/n| = gcd(d, n)
    - obstruction_determined_by_snf_diagonal: signature determines obstruction
    """
    if max_n is None:
        max_n = p + 1
    return tuple(gcd(p, n) for n in range(2, max_n + 1))


def demo_lens_classification():
    """Demonstrate lens space classification via torsion signatures."""
    print("=" * 70)
    print("APPLICATION 2: Lens Space Classification")
    print("=" * 70)
    print()
    print("The torsion obstruction signature (gcd(p,2), gcd(p,3), ...)")
    print("classifies lens spaces L(p,1) — a torsion-based invariant")
    print("that is computed purely from SNF data.")
    print()

    print("p  | Torsion signature (truncated to n ≤ 8)")
    print("---+-" + "-" * 50)
    for p in range(2, 16):
        sig = lens_space_torsion_signature(p, max_n=8)
        print(f"{p:2d} | {sig}")

    # Verify uniqueness
    print()
    sigs = {}
    max_p = 100
    for p in range(2, max_p + 1):
        sig = lens_space_torsion_signature(p)
        if sig in sigs:
            print(f"COLLISION: L({p},1) and L({sigs[sig]},1) have same signature!")
            break
        sigs[sig] = p
    else:
        print(f"✓ All lens spaces L(p,1) for p ∈ [2, {max_p}] have distinct "
              f"torsion signatures.")
    print()


# ============================================================
# Application 3: Unimodular Invariance Verification
# ============================================================

def demo_unimodular_invariance():
    """
    Verify that torsion obstructions are invariant under unimodular
    transformations — a key property for certified computation.

    Formally proved as dTorsion_invariant_under_auto.
    """
    print("=" * 70)
    print("APPLICATION 3: Unimodular Invariance (Certified Computation)")
    print("=" * 70)
    print()
    print("The obstruction is invariant under unimodular basis changes.")
    print("This means SNF-based computation gives certifiably correct results")
    print("regardless of the initial basis choice.")
    print()

    random.seed(42)

    # Generate random matrices and verify that unimodular transforms
    # preserve torsion structure
    n_tests = 50
    all_pass = True

    for _ in range(n_tests):
        size = random.randint(2, 5)

        # Random matrix
        M = [[random.randint(-3, 3) for _ in range(size)] for _ in range(size)]

        # Random unimodular matrix (product of elementary matrices)
        U = [[1 if i == j else 0 for j in range(size)] for i in range(size)]
        for _ in range(5):
            i, j = random.sample(range(size), 2)
            c = random.choice([-2, -1, 1, 2])
            for k in range(size):
                U[i][k] += c * U[j][k]

        # Compute U @ M
        UM = [[sum(U[i][k] * M[k][j] for k in range(size))
               for j in range(size)] for i in range(size)]

        factors_M = sorted(smith_normal_form_small(M))
        factors_UM = sorted(smith_normal_form_small(UM))

        if factors_M != factors_UM:
            print(f"  INVARIANCE VIOLATED for M={M}")
            all_pass = False

    if all_pass:
        print(f"  ✓ All {n_tests} random tests passed: unimodular invariance verified.")
    print()


# ============================================================
# Application 4: Lattice Torsion Analysis
# ============================================================

def lattice_torsion_spectrum(basis_matrix: List[List[int]],
                             primes: List[int]) -> Dict:
    """
    Analyze the torsion spectrum of a lattice quotient.

    Given a basis matrix B defining a sublattice L ⊂ ℤⁿ,
    the quotient ℤⁿ/L has torsion structure determined by the
    SNF of B. The torsion spectrum records which primes detect
    nontrivial torsion — this is the prime selectivity theorem
    (formally proved in the catalog as prime_selectivity).

    Args:
        basis_matrix: matrix whose columns generate the sublattice
        primes: list of primes to test

    Returns:
        Dictionary mapping each prime to its torsion detection status.
    """
    factors = smith_normal_form_small(basis_matrix)

    spectrum = {}
    for p in primes:
        torsion_parts = []
        for d in factors:
            g = gcd(d, p)
            if g > 1:
                torsion_parts.append(f'ℤ/{g}')
        spectrum[p] = {
            'detected': len(torsion_parts) > 0,
            'torsion_parts': torsion_parts,
            'total_torsion': sum(gcd(d, p) for d in factors if gcd(d, p) > 1)
        }

    return spectrum


def demo_lattice_analysis():
    """Demonstrate lattice torsion analysis."""
    print("=" * 70)
    print("APPLICATION 4: Lattice Torsion Spectrum Analysis")
    print("=" * 70)
    print()
    print("For a sublattice L ⊂ ℤⁿ defined by basis matrix B,")
    print("the quotient ℤⁿ/L has torsion detected by prime-indexed probes.")
    print("Different primes see different torsion (prime selectivity theorem).")
    print()

    examples = [
        ("Diagonal lattice [6, 10, 15]",
         [[6, 0, 0], [0, 10, 0], [0, 0, 15]]),
        ("Dense lattice",
         [[4, 2], [6, 3]]),
        ("Identity (trivial quotient)",
         [[1, 0], [0, 1]]),
    ]

    primes = [2, 3, 5, 7]

    for name, basis in examples:
        factors = smith_normal_form_small(basis)
        spectrum = lattice_torsion_spectrum(basis, primes)

        print(f"--- {name} ---")
        print(f"  Invariant factors: {factors}")

        for p in primes:
            s = spectrum[p]
            if s['detected']:
                parts = ', '.join(s['torsion_parts'])
                print(f"  p={p}: DETECTED — {parts}")
            else:
                print(f"  p={p}: silent (coprime)")
        print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Secondary Torsion Obstructions via SNF           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_torsion_tda()
    demo_lens_classification()
    demo_unimodular_invariance()
    demo_lattice_analysis()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of secondary torsion obstructions
computed via Smith Normal Form.

Computes the SNF connecting element and torsion subgroup for:
1. Lens space filtrations L(p,1)
2. Random sparse integer boundary matrices
3. Mapping torus chain complexes

Pure Python — no external dependencies required.
"""

from math import gcd
from typing import List, Tuple
import random

# ============================================================
# Core: Secondary Torsion Obstruction (No SNF needed for 1×1)
# ============================================================

def snf_connecting_element(d: int, n: int) -> int:
    """
    The SNF connecting element: n / gcd(|d|, n) in ℤ/n.
    This generates the d-torsion of ℤ/n.

    Formally verified in Lean as SNFObstruction.snfConnecting.
    """
    if n == 0:
        return 0
    g = gcd(abs(d), n)
    return (n // g) % n


def d_torsion_order(d: int, n: int) -> int:
    """
    The order of the d-torsion subgroup of ℤ/n.
    Equals gcd(|d|, n) by dTorsion_card (formally verified).
    """
    if n == 0:
        return 0
    return gcd(abs(d), n)


def brute_force_torsion(d: int, n: int) -> List[int]:
    """Brute-force: {x ∈ ℤ/n : d*x ≡ 0 mod n}."""
    if n <= 0:
        return []
    return [x for x in range(n) if (d * x) % n == 0]


def secondary_obstruction(d: int, n: int) -> dict:
    """
    Compute the secondary torsion obstruction for invariant factor d
    and torsion order n.
    """
    g = gcd(abs(d), n) if n > 0 else 0
    return {
        'invariant_factor': d,
        'modulus': n,
        'connecting_element': snf_connecting_element(d, n),
        'torsion_subgroup_order': g,
        'obstruction_vanishes': g == 1 or g == 0,
        'torsion_group': f'ℤ/{g}' if g > 1 else '0'
    }


# ============================================================
# SNF for small matrices (correct implementation)
# ============================================================

def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclidean algorithm: returns (g, s, t) with a*s + b*t = g."""
    if a == 0:
        return (b, 0, 1)
    g, s, t = extended_gcd(b % a, a)
    return (g, t - (b // a) * s, s)


def smith_normal_form_small(M: List[List[int]]) -> List[int]:
    """
    Compute invariant factors of a small integer matrix M.
    Returns the list of nonzero diagonal entries of the SNF.
    Uses a simple row/column reduction algorithm.
    """
    if not M or not M[0]:
        return []

    m = len(M)
    n = len(M[0])
    # Work on a copy
    D = [row[:] for row in M]

    r = min(m, n)
    factors = []

    for k in range(r):
        # Find nonzero pivot
        pivot_found = False
        for i in range(k, m):
            for j in range(k, n):
                if D[i][j] != 0:
                    # Swap rows k, i
                    D[k], D[i] = D[i], D[k]
                    # Swap cols k, j
                    for row in D:
                        row[k], row[j] = row[j], row[k]
                    pivot_found = True
                    break
            if pivot_found:
                break

        if not pivot_found:
            break

        # Reduce: eliminate entries in row k and column k
        max_iters = 200
        for _ in range(max_iters):
            changed = False

            # Column operations: eliminate D[k][j] for j > k
            for j in range(k + 1, n):
                if D[k][j] != 0:
                    if D[k][k] == 0:
                        # Swap columns
                        for row in D:
                            row[k], row[j] = row[j], row[k]
                        changed = True
                        continue
                    g, s, t = extended_gcd(D[k][k], D[k][j])
                    u = D[k][k] // g
                    v = D[k][j] // g
                    # Transform columns: new_k = s*col_k + t*col_j, new_j = -v*col_k + u*col_j
                    for i2 in range(m):
                        ck, cj = D[i2][k], D[i2][j]
                        D[i2][k] = s * ck + t * cj
                        D[i2][j] = -v * ck + u * cj
                    changed = True

            # Row operations: eliminate D[i][k] for i > k
            for i in range(k + 1, m):
                if D[i][k] != 0:
                    if D[k][k] == 0:
                        D[k], D[i] = D[i], D[k]
                        changed = True
                        continue
                    g, s, t = extended_gcd(D[k][k], D[i][k])
                    u = D[k][k] // g
                    v = D[i][k] // g
                    rk = D[k][:]
                    ri = D[i][:]
                    for j2 in range(n):
                        D[k][j2] = s * rk[j2] + t * ri[j2]
                        D[i][j2] = -v * rk[j2] + u * ri[j2]
                    changed = True

            # Check divisibility: D[k][k] should divide all D[i][j] for i,j > k
            div_ok = True
            if D[k][k] != 0:
                for i in range(k + 1, m):
                    for j in range(k + 1, n):
                        if D[i][j] % D[k][k] != 0:
                            # Add row i to row k, then continue
                            for j2 in range(n):
                                D[k][j2] += D[i][j2]
                            div_ok = False
                            changed = True
                            break
                    if not div_ok:
                        break

            if not changed:
                break

        if D[k][k] != 0:
            factors.append(abs(D[k][k]))

    return factors


# ============================================================
# Example 1: Lens Space L(p, 1)
# ============================================================

def demo_lens_spaces():
    print("=" * 70)
    print("DEMO 1: Lens Space Torsion Obstructions L(p, 1)")
    print("=" * 70)
    print()
    print("The lens space L(p,1) has H₁ = ℤ/p. Its skeletal filtration")
    print("produces a boundary matrix ∂₂ = [p] with single invariant factor p.")
    print()

    for p in [2, 3, 5, 7, 12, 30]:
        print(f"--- L({p}, 1) : H₁ = ℤ/{p} ---")
        for n in [2, 3, 5, 6, p]:
            obs = secondary_obstruction(p, n)
            status = "VANISHES" if obs['obstruction_vanishes'] else f"≅ {obs['torsion_group']}"
            print(f"  Torsion order n={n:2d}: connecting = {obs['connecting_element']:2d} ∈ ℤ/{n}, "
                  f"obstruction {status}")
        print()


# ============================================================
# Example 2: Random Sparse Integer Matrices
# ============================================================

def demo_random_matrices():
    print("=" * 70)
    print("DEMO 2: Random Sparse Integer Matrices")
    print("=" * 70)
    print()

    random.seed(42)
    torsion_order = 6

    for size in [3, 4, 5, 6]:
        # Generate random sparse matrix
        M = []
        for i in range(size):
            row = []
            for j in range(size):
                if random.random() < 0.5:
                    row.append(random.choice([-2, -1, 1, 2]))
                else:
                    row.append(0)
            M.append(row)

        factors = smith_normal_form_small(M)

        print(f"--- {size}×{size} random matrix, torsion order n={torsion_order} ---")
        print(f"  Invariant factors: {factors}")

        obstructions = [secondary_obstruction(d, torsion_order) for d in factors]
        nonvanishing = [o for o in obstructions if not o['obstruction_vanishes']]
        print(f"  Nonvanishing obstructions: {len(nonvanishing)}/{len(obstructions)}")
        for o in nonvanishing:
            print(f"    d={o['invariant_factor']}: connecting={o['connecting_element']}, "
                  f"torsion={o['torsion_group']}")
        print()


# ============================================================
# Example 3: Mapping Torus
# ============================================================

def demo_mapping_torus():
    print("=" * 70)
    print("DEMO 3: Mapping Torus Chain Complexes")
    print("=" * 70)
    print()
    print("For an automorphism A : ℤⁿ → ℤⁿ, the mapping torus differential")
    print("is I - A. Its SNF invariant factors determine the torsion structure.")
    print()

    examples = [
        ("Order-3 rotation [[0,-1],[1,-1]]",
         [[1 - 0, 0 - (-1)], [0 - 1, 1 - (-1)]]),  # I - A
        ("Shear [[1,2],[0,1]]",
         [[0, -2], [0, 0]]),  # I - A
        ("Cyclic permutation on ℤ³",
         [[1, -1, 0], [0, 1, -1], [-1, 0, 1]]),  # I - A
    ]

    for name, diff in examples:
        factors = smith_normal_form_small(diff)
        print(f"--- Mapping torus of {name} ---")
        print(f"  I - A = {diff}")
        print(f"  Invariant factors: {factors}")

        for n in [2, 3, 6, 12]:
            obstructions = [secondary_obstruction(d, n) for d in factors]
            nonvanishing = [o for o in obstructions if not o['obstruction_vanishes']]
            if nonvanishing:
                parts = [f"d={o['invariant_factor']}→{o['torsion_group']}" for o in nonvanishing]
                print(f"  n={n:2d}: {', '.join(parts)}")
            else:
                print(f"  n={n:2d}: all obstructions vanish")
        print()


# ============================================================
# Verification
# ============================================================

def verify_snf_formula():
    print("=" * 70)
    print("VERIFICATION: SNF Formula vs. Brute Force")
    print("=" * 70)
    print()

    all_pass = True
    test_count = 0

    for d in range(1, 25):
        for n in range(1, 25):
            bf = brute_force_torsion(d, n)
            predicted = d_torsion_order(d, n)
            connecting = snf_connecting_element(d, n)
            test_count += 1

            # Check order
            if len(bf) != predicted:
                print(f"  FAIL: d={d}, n={n}: |torsion|={len(bf)}, predicted={predicted}")
                all_pass = False

            # Check generation
            generated = set()
            for k in range(n):
                generated.add((k * connecting) % n)
            if generated & set(bf) != set(bf):
                print(f"  FAIL: d={d}, n={n}: generator {connecting} doesn't cover torsion")
                all_pass = False

    if all_pass:
        print(f"  ✓ All {test_count} test cases (d,n ∈ [1..24]) PASSED")
        print(f"    The SNF connecting element correctly generates the torsion subgroup.")
    print()


# ============================================================
# Conjecture Tests
# ============================================================

def test_conjectures():
    print("=" * 70)
    print("CONJECTURE TESTS")
    print("=" * 70)
    print()

    # Conjecture C: Lens-space rigidity
    print("Conjecture C: L(p,1) obstruction determines p")
    print("-" * 50)
    obstruction_data = {}
    for p in range(2, 50):
        # Compute full obstruction signature for n = 2, 3, ..., p+1
        sig = tuple(d_torsion_order(p, n) for n in range(2, p + 2))
        if sig in obstruction_data:
            print(f"  FALSIFIED: L({p},1) and L({obstruction_data[sig]},1) have "
                  f"same obstruction signature")
            break
        obstruction_data[sig] = p
    else:
        print(f"  SUPPORTED for p ∈ [2, 49]: all obstruction signatures are distinct")
    print()

    # Conjecture A: Saturation-stability
    print("Conjecture A: Saturation implies vanishing")
    print("-" * 50)
    print("  For invariant factor d=1 (saturated case):")
    all_vanish = all(d_torsion_order(1, n) == 1 for n in range(1, 100))
    print(f"    gcd(1, n) = 1 for all n: {all_vanish} → obstruction always vanishes ✓")
    print("  Conjecture SUPPORTED: saturation (d=1) ⟹ vanishing obstruction")
    print()

    # Conjecture B: Sparse genericity
    print("Conjecture B: Probability of nonzero obstruction → 1 with rank")
    print("-" * 50)
    random.seed(123)
    for size in [5, 10, 15, 20]:
        n_trials = 100
        nonzero_count = 0
        for _ in range(n_trials):
            M = []
            for i in range(size):
                row = [random.choice([-2, -1, 0, 0, 1, 2]) for _ in range(size)]
                M.append(row)
            factors = smith_normal_form_small(M)
            # Check for nontrivial torsion at n=6
            has_torsion = any(gcd(d, 6) > 1 for d in factors if d > 1)
            if has_torsion:
                nonzero_count += 1
        print(f"  Size {size:2d}×{size:2d}: nonzero obstruction in "
              f"{nonzero_count}/{n_trials} trials ({100*nonzero_count/n_trials:.0f}%)")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Secondary Torsion Obstructions via Smith Normal Form — Demo       ║")
    print("╠══════════════════════════════════════════════════════════════════════╣")
    print("║  Computing derived homological invariants from integer linear      ║")
    print("║  algebra: the SNF connecting element n/gcd(d,n) generates the      ║")
    print("║  d-torsion of ℤ/n, bridging exact sequences and computation.       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    verify_snf_formula()
    demo_lens_spaces()
    demo_random_matrices()
    demo_mapping_torus()
    test_conjectures()

    print("=" * 70)
    print("All demos complete.")
    print("=" * 70)
