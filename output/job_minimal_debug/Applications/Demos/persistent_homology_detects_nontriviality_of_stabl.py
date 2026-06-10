#!/usr/bin/env python3
"""
Applications of Persistent Stable Homotopy Detection
=====================================================

Demonstrates real-world applications of persistent Betti number analysis
for filtered chain complexes arising from flow-type models.

Applications:
1. Detecting delayed cancellation patterns in Morse-theoretic models
2. Prime-sensitive persistence as a topological fingerprint
3. Spectral sequence survival analysis
4. Automated invariant computation for parameterized families
"""

import numpy as np
from typing import List, Dict, Tuple


# ============================================================
# Core implementations (self-contained)
# ============================================================

class FilteredChainComplex:
    def __init__(self, gen0_filts, gen1_filts, diff):
        self.gen0_filts = gen0_filts
        self.gen1_filts = gen1_filts
        self.diff = np.array(diff)
        self.gen0 = len(gen0_filts)
        self.gen1 = len(gen1_filts)
        self.max_filt = max(gen0_filts + gen1_filts) if gen0_filts + gen1_filts else 0

    @property
    def euler_char(self):
        return self.gen0 - self.gen1

    def restricted_diff(self, f):
        result = np.zeros_like(self.diff)
        for i in range(self.gen0):
            for j in range(self.gen1):
                if self.gen0_filts[i] <= f and self.gen1_filts[j] <= f:
                    result[i, j] = self.diff[i, j]
        return result

    def num_gen0_at_filt(self, f):
        return sum(1 for x in self.gen0_filts if x <= f)


def rank_mod_p(matrix, p):
    m, n = matrix.shape
    if m == 0 or n == 0:
        return 0
    mat = matrix.astype(int) % p
    rank = 0
    for col in range(n):
        pivot_row = None
        for row in range(rank, m):
            if mat[row, col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        mat[[rank, pivot_row]] = mat[[pivot_row, rank]]
        inv = pow(int(mat[rank, col]), p - 2, p)
        for row in range(m):
            if row != rank and mat[row, col] % p != 0:
                factor = (mat[row, col] * inv) % p
                mat[row] = (mat[row] - factor * mat[rank]) % p
        rank += 1
    return rank


def persistent_betti(C, p, i, j):
    """β₀^{i,j} via image-subspace intersection."""
    if i > j:
        return 0
    d_j = C.restricted_diff(j)
    gen0_at_i = [k for k in range(C.gen0) if C.gen0_filts[k] <= i]
    dim_V = len(gen0_at_i)
    if dim_V == 0:
        return 0
    V = np.zeros((C.gen0, dim_V), dtype=int)
    for idx, k in enumerate(gen0_at_i):
        V[k, idx] = 1
    combined = np.hstack([d_j, V])
    rank_A = rank_mod_p(d_j, p)
    rank_AB = rank_mod_p(combined, p)
    dim_intersection = rank_A + dim_V - rank_AB
    return dim_V - dim_intersection


def betti_table(C, p):
    F = C.max_filt
    table = {}
    for i in range(F + 1):
        for j in range(i, F + 1):
            table[(i, j)] = persistent_betti(C, p, i, j)
    return table


def interval_multiplicities(bt, max_filt):
    def beta(i, j):
        if i < 0 or j < 0 or i > j:
            return 0
        return bt.get((i, j), 0)
    mults = {}
    for b in range(max_filt + 1):
        for d in range(b + 1, max_filt + 2):
            mu = beta(b, d-1) - beta(b-1, d-1) - beta(b, d) + beta(b-1, d)
            if mu != 0:
                mults[(b, d)] = mu
        mu_inf = beta(b, max_filt) - beta(b-1, max_filt)
        if mu_inf != 0:
            mults[(b, float('inf'))] = mu_inf
    return mults


# ============================================================
# Application 1: Morse-theoretic delayed cancellation detection
# ============================================================

def app_morse_cancellation():
    """Detect delayed cancellation patterns in Morse-theoretic models.

    In Morse theory, critical points create and destroy homology classes.
    When two critical points cancel, the resulting bar in the barcode has
    length proportional to the action difference. We model this with
    filtered chain complexes where filtration = action value.
    """
    print("=" * 70)
    print("APPLICATION 1: Morse-Theoretic Delayed Cancellation Detection")
    print("=" * 70)

    # Model: a Morse function on a surface with critical points
    # at varying action values, with specific cancellation patterns
    print("\nScenario: Morse function on a torus-like space")
    print("Critical points at action values 0, 1, 2, 3, 4")
    print("Cancellation pattern: delayed vs. immediate\n")

    # Immediate cancellation model
    immediate = FilteredChainComplex(
        gen0_filts=[0, 1, 2, 3, 4],
        gen1_filts=[1, 2, 3, 4],
        diff=np.array([
            [-1,  0,  0,  0],
            [ 1, -1,  0,  0],
            [ 0,  1, -1,  0],
            [ 0,  0,  1, -1],
            [ 0,  0,  0,  1],
        ])
    )

    # Delayed cancellation model: same ranks but different timing
    delayed = FilteredChainComplex(
        gen0_filts=[0, 1, 2, 3, 4],
        gen1_filts=[2, 3, 4, 4],
        diff=np.array([
            [-1,  0,  0,  0],
            [ 1,  0,  0,  0],
            [ 0, -1,  0,  0],
            [ 0,  1, -1,  0],
            [ 0,  0,  1,  1],
        ])
    )

    for label, cx in [("Immediate", immediate), ("Delayed", delayed)]:
        bt = betti_table(cx, 2)
        mults = interval_multiplicities(bt, cx.max_filt)
        print(f"  {label} model:")
        print(f"    Euler char: {cx.euler_char}")
        print(f"    Barcode (mod 2):")
        for iv, m in sorted(mults.items(), key=lambda x: (x[0][0], x[0][1] if x[0][1] != float('inf') else 9999)):
            d_str = "∞" if iv[1] == float('inf') else str(iv[1])
            print(f"      [{iv[0]}, {d_str}) × {m}")
        max_len = max((iv[1] - iv[0] for iv, m in mults.items() if iv[1] != float('inf')), default=0)
        print(f"    Max finite bar length: {max_len}")
        print()


# ============================================================
# Application 2: Topological fingerprinting
# ============================================================

def app_fingerprinting():
    """Use primewise persistence profiles as topological fingerprints.

    Different primes can detect different features of the same complex,
    analogous to how different wavelengths reveal different structures
    in spectroscopy.
    """
    print("=" * 70)
    print("APPLICATION 2: Primewise Topological Fingerprinting")
    print("=" * 70)

    # Complex with coefficients 6 = 2 × 3
    # Different primes see different cancellation structure
    print("\nComplex with torsion-sensitive differential:")
    print("  d(e₁) = 6(b-a), d(e₂) = 10(c-a)")
    print("  6 = 2×3, 10 = 2×5\n")

    cx = FilteredChainComplex(
        gen0_filts=[0, 1, 2],
        gen1_filts=[2, 2],
        diff=np.array([[-6, -10], [6, 0], [0, 10]])
    )

    fingerprint = {}
    for p in [2, 3, 5, 7, 11]:
        bt = betti_table(cx, p)
        mults = interval_multiplicities(bt, cx.max_filt)
        fingerprint[p] = mults
        finite_bars = [(iv, m) for iv, m in mults.items() if iv[1] != float('inf')]
        inf_bars = [(iv, m) for iv, m in mults.items() if iv[1] == float('inf')]
        print(f"  p = {p}:")
        print(f"    Finite bars: {len(finite_bars)}, Infinite bars: {len(inf_bars)}")
        print(f"    β₀^{{1,2}} = {bt.get((1,2), 0)}")

    print("\n  Key observation:")
    print("  - Mod 2: both differentials vanish → more surviving classes")
    print("  - Mod 3: the 6-coefficient vanishes → partial cancellation")
    print("  - Mod 5: the 10-coefficient vanishes → different partial cancellation")
    print("  - Mod 7, 11: full cancellation pattern visible")


# ============================================================
# Application 3: Spectral sequence survival analysis
# ============================================================

def app_spectral_sequence():
    """Relate bar lengths to spectral sequence page survival.

    A class that survives from filtration i to filtration j in persistence
    corresponds to surviving through (j - i) pages of the associated
    spectral sequence. Long bars = late-page survivors.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Spectral Sequence Survival Analysis")
    print("=" * 70)

    print("\nComparing bar length distributions across ladder models:")
    print("Each ladder model of depth k creates a k-page spectral sequence\n")

    for k in range(1, 8):
        gen0_filts = list(range(k + 1))
        gen1_filts = list(range(1, k + 1))
        diff = np.zeros((k + 1, k), dtype=int)
        for j in range(k):
            diff[0, j] = -1
            diff[j + 1, j] = 1

        L = FilteredChainComplex(gen0_filts, gen1_filts, diff)
        bt = betti_table(L, 2)
        mults = interval_multiplicities(bt, L.max_filt)

        # Compute survival distribution
        finite = [(iv[1] - iv[0], m) for iv, m in mults.items() if iv[1] != float('inf')]
        infinite = sum(m for iv, m in mults.items() if iv[1] == float('inf'))

        # Page-of-death distribution
        page_deaths = {}
        for length, mult in finite:
            page_deaths[length] = page_deaths.get(length, 0) + mult

        print(f"  k={k}: ", end="")
        print(f"Finite bars: {sum(m for _, m in finite)}, ", end="")
        print(f"Infinite: {infinite}, ", end="")
        print(f"Deaths by page: {dict(sorted(page_deaths.items()))}")


# ============================================================
# Application 4: Automated invariant computation
# ============================================================

def app_automated():
    """Automated computation of persistence invariants for families.

    Compute and compare persistence profiles across a parameterized
    family, detecting qualitative transitions.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Automated Family Analysis")
    print("=" * 70)

    print("\nDiamond family: parameterized by coefficient a")
    print("d(e) = a·b - c, with generators at filtrations 0,1,2\n")

    for a in range(1, 8):
        cx = FilteredChainComplex(
            gen0_filts=[0, 1, 2],
            gen1_filts=[2],
            diff=np.array([[-1], [a], [-a+1]])
        )

        results = {}
        for p in [2, 3, 5, 7]:
            bt = betti_table(cx, p)
            results[p] = bt.get((1, 2), 0)

        print(f"  a={a}: β₀^{{1,2}} mod p = {results}")
        # Check which primes see different behavior
        if len(set(results.values())) > 1:
            print(f"         ↑ Prime-dependent! Some primes see the coefficient.")


if __name__ == "__main__":
    app_morse_cancellation()
    app_fingerprinting()
    app_spectral_sequence()
    app_automated()


#!/usr/bin/env python3
"""
Demo: Persistent Stable Homotopy Detection
===========================================

Demonstrates persistence separation: complexes with identical coarse
invariants but different persistent Betti numbers.

Usage:
    python demo.py          # Run with default parameters
    python demo.py --k 10   # Explore ladder family up to depth 10
"""

import sys
import numpy as np
from typing import List, Tuple, Dict


# ============================================================
# Self-contained implementations
# ============================================================

class FilteredChainComplex:
    """A finite filtered 2-term chain complex C₁ →d→ C₀ over ℤ."""
    def __init__(self, gen0_filts, gen1_filts, diff):
        self.gen0_filts = gen0_filts
        self.gen1_filts = gen1_filts
        self.diff = np.array(diff)
        self.gen0 = len(gen0_filts)
        self.gen1 = len(gen1_filts)
        self.max_filt = max(gen0_filts + gen1_filts) if gen0_filts + gen1_filts else 0

    @property
    def euler_char(self):
        return self.gen0 - self.gen1

    def restricted_diff(self, f):
        result = np.zeros_like(self.diff)
        for i in range(self.gen0):
            for j in range(self.gen1):
                if self.gen0_filts[i] <= f and self.gen1_filts[j] <= f:
                    result[i, j] = self.diff[i, j]
        return result

    def num_gen0_at_filt(self, f):
        return sum(1 for x in self.gen0_filts if x <= f)


def rank_mod_p(matrix, p):
    """Rank of integer matrix mod p via Gaussian elimination over 𝔽_p."""
    m, n = matrix.shape
    if m == 0 or n == 0:
        return 0
    mat = matrix.astype(int) % p
    rank = 0
    for col in range(n):
        pivot_row = None
        for row in range(rank, m):
            if mat[row, col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        mat[[rank, pivot_row]] = mat[[pivot_row, rank]]
        inv = pow(int(mat[rank, col]), p - 2, p)
        for row in range(m):
            if row != rank and mat[row, col] % p != 0:
                factor = (mat[row, col] * inv) % p
                mat[row] = (mat[row] - factor * mat[rank]) % p
        rank += 1
    return rank


def compute_persistent_betti(C, p, i, j):
    """Compute β₀^{i,j} over 𝔽_p using image-subspace intersection.

    β₀^{i,j} = dim(C₀^{≤i}) - dim(im(d|_{≤j}) ∩ span(gen0 at filt ≤ i))

    where dim(A ∩ B) = rank(A) + rank(B) - rank([A | B]).
    """
    if i > j:
        return 0

    d_j = C.restricted_diff(j)

    # Subspace V = span of gen0 at filt ≤ i (identity columns)
    gen0_at_i = [k for k in range(C.gen0) if C.gen0_filts[k] <= i]
    dim_V = len(gen0_at_i)
    if dim_V == 0:
        return 0

    V = np.zeros((C.gen0, dim_V), dtype=int)
    for idx, k in enumerate(gen0_at_i):
        V[k, idx] = 1

    # dim(im(d_j) ∩ V) = rank(d_j) + rank(V) - rank([d_j | V])
    combined = np.hstack([d_j, V])
    rank_A = rank_mod_p(d_j, p)
    rank_B = dim_V
    rank_AB = rank_mod_p(combined, p)
    dim_intersection = rank_A + rank_B - rank_AB

    return dim_V - dim_intersection


def compute_betti_table(C, p):
    F = C.max_filt
    table = {}
    for i in range(F + 1):
        for j in range(i, F + 1):
            table[(i, j)] = compute_persistent_betti(C, p, i, j)
    return table


def interval_multiplicities(betti_table, max_filt):
    def beta(i, j):
        if i < 0 or j < 0 or i > j:
            return 0
        return betti_table.get((i, j), 0)

    mults = {}
    for b in range(max_filt + 1):
        for d in range(b + 1, max_filt + 2):
            mu = beta(b, d-1) - beta(b-1, d-1) - beta(b, d) + beta(b-1, d)
            if mu != 0:
                mults[(b, d)] = mu
        mu_inf = beta(b, max_filt) - beta(b-1, max_filt)
        if mu_inf != 0:
            mults[(b, float('inf'))] = mu_inf
    return mults


# ============================================================
# Example constructions
# ============================================================

def example_C():
    """d(e) = b - a: kills the filtration-1 class."""
    return FilteredChainComplex([0, 1, 2], [2], [[-1], [1], [0]])

def example_D():
    """d(e) = c - a: kills the filtration-2 class."""
    return FilteredChainComplex([0, 1, 2], [2], [[-1], [0], [1]])

def ladder_model(k):
    """Ladder flow model of depth k."""
    gen0_filts = list(range(k + 1))
    gen1_filts = list(range(1, k + 1))
    diff = np.zeros((k + 1, k), dtype=int)
    for j in range(k):
        diff[0, j] = -1
        diff[j + 1, j] = 1
    return FilteredChainComplex(gen0_filts, gen1_filts, diff)


# ============================================================
# Demos
# ============================================================

def demo_separation():
    print("=" * 70)
    print("DEMO 1: Persistence Separates Coarse-Equivalent Complexes")
    print("=" * 70)

    C = example_C()
    D = example_D()

    print("\n--- Complex C: d(e) = b - a ---")
    print(f"  Degree-0 generators: a(filt=0), b(filt=1), c(filt=2)")
    print(f"  Degree-1 generators: e(filt=2)")
    print(f"  Differential: d(e) = -a + b = b - a")

    print("\n--- Complex D: d(e) = c - a ---")
    print(f"  Degree-0 generators: a(filt=0), b(filt=1), c(filt=2)")
    print(f"  Degree-1 generators: e(filt=2)")
    print(f"  Differential: d(e) = -a + c = c - a")

    print("\n--- Coarse Invariants (IDENTICAL) ---")
    print(f"  Graded ranks: C=({C.gen0},{C.gen1}), D=({D.gen0},{D.gen1})")
    print(f"  Euler char:   C={C.euler_char}, D={D.euler_char}")
    for f in range(3):
        print(f"  Gen0 at filt≤{f}: C={C.num_gen0_at_filt(f)}, D={D.num_gen0_at_filt(f)}")

    print("\n--- Persistent Betti Tables ---")
    primes = [2, 3, 5]
    for p in primes:
        table_C = compute_betti_table(C, p)
        table_D = compute_betti_table(D, p)
        print(f"\n  Prime p = {p}:")
        print(f"  {'(i,j)':<10} {'β₀(C)':<10} {'β₀(D)':<10} {'DIFF?'}")
        print(f"  {'-'*45}")
        for i in range(3):
            for j in range(i, 3):
                bc = table_C[(i, j)]
                bd = table_D[(i, j)]
                marker = " ◀ SEPARATING" if bc != bd else ""
                print(f"  ({i},{j})      {bc:<10} {bd:<10}{marker}")

    print("\n--- Barcode Decomposition (mod 2) ---")
    for label, cx in [("C", C), ("D", D)]:
        table = compute_betti_table(cx, 2)
        mults = interval_multiplicities(table, cx.max_filt)
        print(f"\n  Complex {label}:")
        for interval, mult in sorted(mults.items(), key=lambda x: (x[0][0], x[0][1] if x[0][1] != float('inf') else 9999)):
            d_str = "∞" if interval[1] == float('inf') else str(interval[1])
            print(f"    [{interval[0]}, {d_str}) × {mult}")

    print("\n--- KEY FINDING ---")
    bc = compute_persistent_betti(C, 2, 1, 2)
    bd = compute_persistent_betti(D, 2, 1, 2)
    print(f"  β₀^{{1,2}}(C) = {bc}")
    print(f"  β₀^{{1,2}}(D) = {bd}")
    if bc != bd:
        print(f"  ✓ Persistence SEPARATES despite identical coarse invariants!")
    else:
        print(f"  Same (try a different prime).")


def demo_ladder_family(max_k=5):
    print("\n" + "=" * 70)
    print("DEMO 2: Ladder Flow Model Family")
    print("=" * 70)

    print("\nThe ladder model of depth k has:")
    print("  - k+1 degree-0 generators (filtrations 0,1,...,k)")
    print("  - k degree-1 generators (filtrations 1,2,...,k)")
    print("  - d(eⱼ) = g_{j+1} - g₀ for each j")
    print("  - Euler characteristic always = 1")

    for k in range(1, max_k + 1):
        L = ladder_model(k)
        print(f"\n--- Ladder k={k} ---")
        print(f"  Generators: ({L.gen0} in deg 0, {L.gen1} in deg 1)")
        print(f"  Euler char: {L.euler_char}")

        table = compute_betti_table(L, 2)
        mults = interval_multiplicities(table, L.max_filt)

        print(f"  Barcode (mod 2):")
        for interval, mult in sorted(mults.items(), key=lambda x: (x[0][0], x[0][1] if x[0][1] != float('inf') else 9999)):
            d_str = "∞" if interval[1] == float('inf') else str(interval[1])
            print(f"    [{interval[0]}, {d_str}) × {mult}")

    # Growth analysis
    print("\n--- Persistent Complexity Growth ---")
    print(f"{'k':<5} {'#Bars':<8} {'Max β₀^{{0,f}}':<15} {'β₀^{{0,k}}':}")
    for k in range(1, max_k + 1):
        L = ladder_model(k)
        table = compute_betti_table(L, 2)
        mults = interval_multiplicities(table, L.max_filt)
        bar_count = sum(abs(v) for v in mults.values())
        max_beta = max(table.values()) if table else 0
        beta_0k = table.get((0, k), 0)
        print(f"{k:<5} {bar_count:<8} {max_beta:<15} {beta_0k}")


def demo_primewise():
    print("\n" + "=" * 70)
    print("DEMO 3: Primewise Sensitivity")
    print("=" * 70)

    # Torsion-sensitive complex: d(e₁)=2(b-a), d(e₂)=3(c-a)
    E = FilteredChainComplex(
        gen0_filts=[0, 1, 2],
        gen1_filts=[2, 2],
        diff=np.array([[-2, -3], [2, 0], [0, 3]])
    )

    print("\n--- Complex E: d(e₁) = 2(b-a), d(e₂) = 3(c-a) ---")
    print("  Coefficients 2 and 3 create prime-dependent behavior.\n")

    for p in [2, 3, 5, 7]:
        table = compute_betti_table(E, p)
        print(f"  Mod {p}: β₀ table = ", end="")
        print({k: v for k, v in sorted(table.items())})


def demo_comparison():
    print("\n" + "=" * 70)
    print("DEMO 4: Ladder vs Trivially-Filtered Complexes")
    print("=" * 70)

    for k in [2, 3, 4]:
        L = ladder_model(k)
        T = FilteredChainComplex(
            gen0_filts=[0] * (k + 1),
            gen1_filts=[0] * k,
            diff=L.diff.copy()
        )

        table_L = compute_betti_table(L, 2)
        table_T = compute_betti_table(T, 2)

        print(f"\n--- k = {k} ---")
        print(f"  Same ranks: ({L.gen0},{L.gen1}), Same Euler char: {L.euler_char}")
        differs = any(table_L.get(k2) != table_T.get(k2) for k2 in set(list(table_L) + list(table_T)))
        print(f"  Persistent Betti tables differ: {differs}")
        if differs:
            for key in sorted(set(list(table_L.keys()) + list(table_T.keys()))):
                vl = table_L.get(key, '-')
                vt = table_T.get(key, '-')
                if vl != vt:
                    print(f"    β₀^{key}: Ladder={vl}, Trivial={vt}")


if __name__ == "__main__":
    max_k = 5
    if "--k" in sys.argv:
        idx = sys.argv.index("--k")
        if idx + 1 < len(sys.argv):
            max_k = int(sys.argv[idx + 1])

    demo_separation()
    demo_ladder_family(max_k)
    demo_primewise()
    demo_comparison()

    print("\n" + "=" * 70)
    print("CONCLUSION")
    print("=" * 70)
    print("""
Persistent Betti numbers detect filtration-geometric information
invisible to coarse chain invariants. The key mechanism is that
different differentials can produce the same total homology but
different patterns of delayed cancellation across filtration levels.

This opens a computational window into stable homotopy phenomena
through filtered algebraic models.
""")


"""
Visualization: Barcode Comparison of Separation Examples
========================================================
Visualizes the barcodes of complexes C and D side by side,
highlighting the separating persistent Betti number β₀^{1,2}.

Complex C: d(e) = b - a  (kills filt-1 class)
Complex D: d(e) = c - a  (kills filt-2 class)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


# Self-contained implementations
class FilteredChainComplex:
    def __init__(self, gen0_filts, gen1_filts, diff):
        self.gen0_filts = gen0_filts
        self.gen1_filts = gen1_filts
        self.diff = np.array(diff)
        self.gen0 = len(gen0_filts)
        self.gen1 = len(gen1_filts)
        self.max_filt = max(gen0_filts + gen1_filts) if gen0_filts + gen1_filts else 0

    def restricted_diff(self, f):
        result = np.zeros_like(self.diff)
        for i in range(self.gen0):
            for j in range(self.gen1):
                if self.gen0_filts[i] <= f and self.gen1_filts[j] <= f:
                    result[i, j] = self.diff[i, j]
        return result

    def num_gen0_at_filt(self, f):
        return sum(1 for x in self.gen0_filts if x <= f)


def rank_mod_p(matrix, p):
    m, n = matrix.shape
    if m == 0 or n == 0:
        return 0
    mat = matrix.astype(int) % p
    rank = 0
    for col in range(n):
        pivot_row = None
        for row in range(rank, m):
            if mat[row, col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        mat[[rank, pivot_row]] = mat[[pivot_row, rank]]
        inv = pow(int(mat[rank, col]), p - 2, p)
        for row in range(m):
            if row != rank and mat[row, col] % p != 0:
                factor = (mat[row, col] * inv) % p
                mat[row] = (mat[row] - factor * mat[rank]) % p
        rank += 1
    return rank


def persistent_betti(C, p, i, j):
    if i > j:
        return 0
    d_j = C.restricted_diff(j)
    gen0_at_i = [k for k in range(C.gen0) if C.gen0_filts[k] <= i]
    dim_V = len(gen0_at_i)
    if dim_V == 0:
        return 0
    V = np.zeros((C.gen0, dim_V), dtype=int)
    for idx, k in enumerate(gen0_at_i):
        V[k, idx] = 1
    combined = np.hstack([d_j, V])
    rank_A = rank_mod_p(d_j, p)
    rank_AB = rank_mod_p(combined, p)
    return dim_V - (rank_A + dim_V - rank_AB)


def betti_table(C, p):
    F = C.max_filt
    table = {}
    for i in range(F + 1):
        for j in range(i, F + 1):
            table[(i, j)] = persistent_betti(C, p, i, j)
    return table


def interval_mults(bt, max_filt):
    def beta(i, j):
        if i < 0 or j < 0 or i > j:
            return 0
        return bt.get((i, j), 0)
    mults = {}
    for b in range(max_filt + 1):
        for d in range(b + 1, max_filt + 2):
            mu = beta(b, d-1) - beta(b-1, d-1) - beta(b, d) + beta(b-1, d)
            if mu != 0:
                mults[(b, d)] = mu
        mu_inf = beta(b, max_filt) - beta(b-1, max_filt)
        if mu_inf != 0:
            mults[(b, 'inf')] = mu_inf
    return mults


# Create examples
C = FilteredChainComplex([0, 1, 2], [2], [[-1], [1], [0]])
D = FilteredChainComplex([0, 1, 2], [2], [[-1], [0], [1]])

p = 2
bt_C = betti_table(C, p)
bt_D = betti_table(D, p)
mults_C = interval_mults(bt_C, C.max_filt)
mults_D = interval_mults(bt_D, D.max_filt)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Barcode of C
ax = axes[0, 0]
ax.set_title("Complex C: d(e) = b − a\n(kills filt-1 class)", fontsize=12, fontweight='bold')
colors_C = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0']
y = 0
bars_C = sorted(mults_C.items(), key=lambda x: (x[0][0], 0 if x[0][1] == 'inf' else -x[0][1]))
for (b, d), mult in bars_C:
    for _ in range(abs(mult)):
        if d == 'inf':
            ax.barh(y, 3.5 - b, left=b, height=0.6, color=colors_C[y % len(colors_C)], alpha=0.8)
            ax.plot(3.5, y, '>', markersize=10, color=colors_C[y % len(colors_C)])
        else:
            ax.barh(y, d - b, left=b, height=0.6, color=colors_C[y % len(colors_C)], alpha=0.8)
        ax.text(b + 0.05, y + 0.05, f"[{b},{d})", fontsize=8, va='center')
        y += 1
ax.set_xlabel("Filtration level")
ax.set_ylabel("Bar index")
ax.set_xlim(-0.2, 4)
ax.set_yticks(range(y))
ax.grid(axis='x', alpha=0.3)

# Panel 2: Barcode of D
ax = axes[0, 1]
ax.set_title("Complex D: d(e) = c − a\n(kills filt-2 class)", fontsize=12, fontweight='bold')
colors_D = ['#E91E63', '#00BCD4', '#FF5722', '#673AB7']
y = 0
bars_D = sorted(mults_D.items(), key=lambda x: (x[0][0], 0 if x[0][1] == 'inf' else -x[0][1]))
for (b, d), mult in bars_D:
    for _ in range(abs(mult)):
        if d == 'inf':
            ax.barh(y, 3.5 - b, left=b, height=0.6, color=colors_D[y % len(colors_D)], alpha=0.8)
            ax.plot(3.5, y, '>', markersize=10, color=colors_D[y % len(colors_D)])
        else:
            ax.barh(y, d - b, left=b, height=0.6, color=colors_D[y % len(colors_D)], alpha=0.8)
        ax.text(b + 0.05, y + 0.05, f"[{b},{d})", fontsize=8, va='center')
        y += 1
ax.set_xlabel("Filtration level")
ax.set_ylabel("Bar index")
ax.set_xlim(-0.2, 4)
ax.set_yticks(range(y))
ax.grid(axis='x', alpha=0.3)

# Panel 3: Persistent Betti table comparison
ax = axes[1, 0]
ax.set_title("Persistent Betti Numbers β₀^{i,j} (mod 2)", fontsize=12, fontweight='bold')

F = 2
cell_data = []
cell_colors = []
for i in range(F + 1):
    row = []
    row_colors = []
    for j in range(F + 1):
        if j >= i:
            bc = bt_C[(i, j)]
            bd = bt_D[(i, j)]
            row.append(f"C:{bc} D:{bd}")
            if bc != bd:
                row_colors.append('#FFCDD2')  # red highlight
            else:
                row_colors.append('#E8F5E9')  # green
        else:
            row.append("")
            row_colors.append('white')
    cell_data.append(row)
    cell_colors.append(row_colors)

table = ax.table(cellText=cell_data, cellColours=cell_colors,
                  rowLabels=[f"i={i}" for i in range(F+1)],
                  colLabels=[f"j={j}" for j in range(F+1)],
                  loc='center', cellLoc='center')
table.auto_set_font_size(False)
table.set_fontsize(11)
table.scale(1.2, 1.8)
ax.axis('off')
ax.text(0.5, -0.05, "Red = SEPARATING pair", ha='center', transform=ax.transAxes,
        fontsize=10, color='red', fontweight='bold')

# Panel 4: Schematic of the complexes
ax = axes[1, 1]
ax.set_title("Filtration Structure Schematic", fontsize=12, fontweight='bold')

# Draw filtration levels
for f in range(3):
    ax.axvline(f, color='gray', linestyle='--', alpha=0.3)
    ax.text(f, -0.8, f"f={f}", ha='center', fontsize=10)

# Complex C generators
ax.plot(0, 2, 'o', markersize=15, color='#2196F3', zorder=5)
ax.text(0, 2.4, 'a', ha='center', fontsize=12, fontweight='bold')
ax.plot(1, 2, 'o', markersize=15, color='#4CAF50', zorder=5)
ax.text(1, 2.4, 'b', ha='center', fontsize=12, fontweight='bold')
ax.plot(2, 2, 'o', markersize=15, color='#FF9800', zorder=5)
ax.text(2, 2.4, 'c', ha='center', fontsize=12, fontweight='bold')
ax.plot(2, 3.5, 's', markersize=12, color='#F44336', zorder=5)
ax.text(2, 3.9, 'e', ha='center', fontsize=12, fontweight='bold')

# C differential arrows
ax.annotate('', xy=(0, 2.2), xytext=(1.9, 3.3),
            arrowprops=dict(arrowstyle='->', color='#F44336', lw=2))
ax.annotate('', xy=(1, 2.2), xytext=(1.9, 3.3),
            arrowprops=dict(arrowstyle='->', color='#F44336', lw=2))
ax.text(0.5, 3.0, 'd(e)=b−a', fontsize=9, color='#F44336', rotation=0)

ax.text(1, 4.5, 'Complex C', ha='center', fontsize=13, fontweight='bold', color='#1565C0')

ax.set_xlim(-0.5, 2.5)
ax.set_ylim(-1, 5)
ax.axis('off')

plt.tight_layout()
plt.savefig('barcode_comparison.png', dpi=150, bbox_inches='tight')
print("Saved barcode_comparison.png")


"""
Visualization: Ladder Family Persistent Complexity Growth
=========================================================
Shows how the barcode complexity of the ladder flow model family
grows with the depth parameter k, demonstrating that persistent
invariants capture increasingly rich structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# Self-contained implementations
class FilteredChainComplex:
    def __init__(self, gen0_filts, gen1_filts, diff):
        self.gen0_filts = gen0_filts
        self.gen1_filts = gen1_filts
        self.diff = np.array(diff)
        self.gen0 = len(gen0_filts)
        self.gen1 = len(gen1_filts)
        self.max_filt = max(gen0_filts + gen1_filts) if gen0_filts + gen1_filts else 0

    def restricted_diff(self, f):
        result = np.zeros_like(self.diff)
        for i in range(self.gen0):
            for j in range(self.gen1):
                if self.gen0_filts[i] <= f and self.gen1_filts[j] <= f:
                    result[i, j] = self.diff[i, j]
        return result

    def num_gen0_at_filt(self, f):
        return sum(1 for x in self.gen0_filts if x <= f)


def rank_mod_p(matrix, p):
    m, n = matrix.shape
    if m == 0 or n == 0:
        return 0
    mat = matrix.astype(int) % p
    rank = 0
    for col in range(n):
        pivot_row = None
        for row in range(rank, m):
            if mat[row, col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        mat[[rank, pivot_row]] = mat[[pivot_row, rank]]
        inv = pow(int(mat[rank, col]), p - 2, p)
        for row in range(m):
            if row != rank and mat[row, col] % p != 0:
                factor = (mat[row, col] * inv) % p
                mat[row] = (mat[row] - factor * mat[rank]) % p
        rank += 1
    return rank


def persistent_betti(C, p, i, j):
    if i > j:
        return 0
    d_j = C.restricted_diff(j)
    gen0_at_i = [k for k in range(C.gen0) if C.gen0_filts[k] <= i]
    dim_V = len(gen0_at_i)
    if dim_V == 0:
        return 0
    V = np.zeros((C.gen0, dim_V), dtype=int)
    for idx, k in enumerate(gen0_at_i):
        V[k, idx] = 1
    combined = np.hstack([d_j, V])
    rank_A = rank_mod_p(d_j, p)
    rank_AB = rank_mod_p(combined, p)
    return dim_V - (rank_A + dim_V - rank_AB)


def betti_table(C, p):
    F = C.max_filt
    table = {}
    for i in range(F + 1):
        for j in range(i, F + 1):
            table[(i, j)] = persistent_betti(C, p, i, j)
    return table


def interval_mults(bt, max_filt):
    def beta(i, j):
        if i < 0 or j < 0 or i > j:
            return 0
        return bt.get((i, j), 0)
    mults = {}
    for b in range(max_filt + 1):
        for d in range(b + 1, max_filt + 2):
            mu = beta(b, d-1) - beta(b-1, d-1) - beta(b, d) + beta(b-1, d)
            if mu != 0:
                mults[(b, d)] = mu
        mu_inf = beta(b, max_filt) - beta(b-1, max_filt)
        if mu_inf != 0:
            mults[(b, 'inf')] = mu_inf
    return mults


def ladder_model(k):
    gen0_filts = list(range(k + 1))
    gen1_filts = list(range(1, k + 1))
    diff = np.zeros((k + 1, k), dtype=int)
    for j in range(k):
        diff[0, j] = -1
        diff[j + 1, j] = 1
    return FilteredChainComplex(gen0_filts, gen1_filts, diff)


# Compute data
max_k = 10
ks = list(range(1, max_k + 1))
bar_counts = []
betti_entries = []
max_betti_vals = []

for k in ks:
    L = ladder_model(k)
    bt = betti_table(L, 2)
    mults = interval_mults(bt, L.max_filt)
    bar_counts.append(sum(abs(v) for v in mults.values()))
    betti_entries.append(len(bt))
    max_betti_vals.append(max(bt.values()) if bt else 0)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Bar count growth
ax = axes[0, 0]
ax.plot(ks, bar_counts, 'o-', color='#2196F3', linewidth=2, markersize=8)
ax.set_xlabel("Ladder depth k", fontsize=12)
ax.set_ylabel("Total bar count", fontsize=12)
ax.set_title("Barcode Complexity Growth", fontsize=13, fontweight='bold')
ax.grid(alpha=0.3)

# Panel 2: Betti table size
ax = axes[0, 1]
ax.plot(ks, betti_entries, 's-', color='#4CAF50', linewidth=2, markersize=8)
ax.set_xlabel("Ladder depth k", fontsize=12)
ax.set_ylabel("# Persistent Betti entries", fontsize=12)
ax.set_title("Persistent Betti Table Size", fontsize=13, fontweight='bold')
ax.grid(alpha=0.3)

# Panel 3: Barcode diagrams for k=1,2,3,4
ax = axes[1, 0]
ax.set_title("Barcodes for Ladder Models (mod 2)", fontsize=13, fontweight='bold')
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
y_offset = 0
labels_done = set()
for idx, k in enumerate([1, 2, 3, 4]):
    L = ladder_model(k)
    bt = betti_table(L, 2)
    mults = interval_mults(bt, L.max_filt)

    label = f"k={k}"
    first = True
    for (b, d), mult in sorted(mults.items(), key=lambda x: (x[0][0], 0 if x[0][1] == 'inf' else -x[0][1])):
        for _ in range(abs(mult)):
            if d == 'inf':
                ax.barh(y_offset, 6 - b, left=b, height=0.5,
                        color=colors[idx], alpha=0.7,
                        label=label if first else None)
                ax.plot(6, y_offset, '>', markersize=8, color=colors[idx])
            else:
                ax.barh(y_offset, d - b, left=b, height=0.5,
                        color=colors[idx], alpha=0.7,
                        label=label if first else None)
            first = False
            y_offset += 1
    y_offset += 0.5  # gap between k values

ax.set_xlabel("Filtration level", fontsize=12)
ax.set_ylabel("Bar index", fontsize=12)
ax.legend(loc='upper right')
ax.grid(axis='x', alpha=0.3)

# Panel 4: Persistent Betti heatmap for k=5
ax = axes[1, 1]
k = 5
L = ladder_model(k)
bt = betti_table(L, 2)
F = L.max_filt

heatmap_data = np.full((F + 1, F + 1), np.nan)
for (i, j), v in bt.items():
    heatmap_data[i, j] = v

im = ax.imshow(heatmap_data, cmap='YlOrRd', aspect='auto', origin='upper')
for i in range(F + 1):
    for j in range(F + 1):
        if not np.isnan(heatmap_data[i, j]):
            ax.text(j, i, str(int(heatmap_data[i, j])),
                    ha='center', va='center', fontsize=9, fontweight='bold')

ax.set_xlabel("j (filtration death)", fontsize=12)
ax.set_ylabel("i (filtration birth)", fontsize=12)
ax.set_title(f"β₀^{{i,j}} Heatmap (k={k}, mod 2)", fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label="Persistent Betti number")

plt.tight_layout()
plt.savefig('ladder_growth.png', dpi=150, bbox_inches='tight')
print("Saved ladder_growth.png")


"""
Visualization: Primewise Persistence Profile Heatmap
=====================================================
Shows how different primes p reveal different persistent Betti
numbers for a torsion-sensitive filtered chain complex.

This visualizes the "primewise barcode profile" — the central new
invariant introduced in this work.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# Self-contained implementations
class FilteredChainComplex:
    def __init__(self, gen0_filts, gen1_filts, diff):
        self.gen0_filts = gen0_filts
        self.gen1_filts = gen1_filts
        self.diff = np.array(diff)
        self.gen0 = len(gen0_filts)
        self.gen1 = len(gen1_filts)
        self.max_filt = max(gen0_filts + gen1_filts) if gen0_filts + gen1_filts else 0

    def restricted_diff(self, f):
        result = np.zeros_like(self.diff)
        for i in range(self.gen0):
            for j in range(self.gen1):
                if self.gen0_filts[i] <= f and self.gen1_filts[j] <= f:
                    result[i, j] = self.diff[i, j]
        return result

    def num_gen0_at_filt(self, f):
        return sum(1 for x in self.gen0_filts if x <= f)


def rank_mod_p(matrix, p):
    m, n = matrix.shape
    if m == 0 or n == 0:
        return 0
    mat = matrix.astype(int) % p
    rank = 0
    for col in range(n):
        pivot_row = None
        for row in range(rank, m):
            if mat[row, col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        mat[[rank, pivot_row]] = mat[[pivot_row, rank]]
        inv = pow(int(mat[rank, col]), p - 2, p)
        for row in range(m):
            if row != rank and mat[row, col] % p != 0:
                factor = (mat[row, col] * inv) % p
                mat[row] = (mat[row] - factor * mat[rank]) % p
        rank += 1
    return rank


def persistent_betti(C, p, i, j):
    if i > j:
        return 0
    d_j = C.restricted_diff(j)
    gen0_at_i = [k for k in range(C.gen0) if C.gen0_filts[k] <= i]
    dim_V = len(gen0_at_i)
    if dim_V == 0:
        return 0
    V = np.zeros((C.gen0, dim_V), dtype=int)
    for idx, k in enumerate(gen0_at_i):
        V[k, idx] = 1
    combined = np.hstack([d_j, V])
    rank_A = rank_mod_p(d_j, p)
    rank_AB = rank_mod_p(combined, p)
    return dim_V - (rank_A + dim_V - rank_AB)


def betti_table(C, p):
    F = C.max_filt
    table = {}
    for i in range(F + 1):
        for j in range(i, F + 1):
            table[(i, j)] = persistent_betti(C, p, i, j)
    return table


# Create torsion-sensitive complex
# d(e₁) = 6(b-a) = (2·3)(b-a), d(e₂) = 10(c-a) = (2·5)(c-a), d(e₃) = 15(d-a) = (3·5)(d-a)
C = FilteredChainComplex(
    gen0_filts=[0, 1, 2, 3],
    gen1_filts=[3, 3, 3],
    diff=np.array([
        [-6, -10, -15],
        [ 6,   0,   0],
        [ 0,  10,   0],
        [ 0,   0,  15]
    ])
)

primes = [2, 3, 5, 7, 11, 13]
F = C.max_filt

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle("Primewise Persistence Profile: β₀^{i,j} across primes\n"
             "d(e₁)=6(b−a), d(e₂)=10(c−a), d(e₃)=15(d−a)",
             fontsize=14, fontweight='bold')

for idx, p in enumerate(primes):
    ax = axes[idx // 3, idx % 3]
    bt = betti_table(C, p)

    heatmap = np.full((F + 1, F + 1), np.nan)
    for (i, j), v in bt.items():
        heatmap[i, j] = v

    im = ax.imshow(heatmap, cmap='Blues', aspect='auto', origin='upper',
                   vmin=0, vmax=max(bt.values()) if bt else 1)
    for i in range(F + 1):
        for j in range(F + 1):
            if not np.isnan(heatmap[i, j]):
                ax.text(j, i, str(int(heatmap[i, j])),
                        ha='center', va='center', fontsize=12, fontweight='bold',
                        color='white' if heatmap[i, j] > max(bt.values())/2 else 'black')

    ax.set_xlabel("j", fontsize=11)
    ax.set_ylabel("i", fontsize=11)
    ax.set_title(f"p = {p}", fontsize=13, fontweight='bold',
                 color='#D32F2F' if p in [2, 3, 5] else '#1976D2')
    ax.set_xticks(range(F + 1))
    ax.set_yticks(range(F + 1))

# Add explanation
fig.text(0.5, 0.02,
         "Red titles: primes dividing the coefficients (6=2·3, 10=2·5, 15=3·5). "
         "Each prime reveals a different persistence pattern.",
         ha='center', fontsize=11, style='italic')

plt.tight_layout(rect=[0, 0.04, 1, 0.94])
plt.savefig('primewise_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved primewise_heatmap.png")
