#!/usr/bin/env python3
"""
Applications of Tropical Smoothness Score Theory

Demonstrates real-world applications of the tropical cryptanalysis framework:
1. Factor base optimization via defect analysis
2. Sieve interval selection using tropical energy landscape
3. Large-prime strategy guided by defect thresholds
"""

import math
from collections import Counter, defaultdict
from typing import List, Dict, Tuple
from algorithms import (
    TropicalScorer, MinPlusMatrix, tropical_sieve,
    sieve_of_eratosthenes, factorize, p_adic_valuation
)


def application_factor_base_optimization():
    """
    Use tropical score defects to optimize factor base selection.
    
    Key insight: The average defect over a sieve interval measures
    how well the factor base "covers" the smooth number landscape.
    Smaller average defect → more smooth relations → faster factoring.
    """
    print("=" * 70)
    print("APPLICATION 1: Factor Base Optimization via Defect Analysis")
    print("=" * 70)
    
    N = 100003  # A semiprime
    base = int(math.isqrt(N)) + 1
    interval = 500
    
    # Try different factor base sizes
    for B in [10, 20, 30, 50, 80]:
        fb = sieve_of_eratosthenes(B)
        scorer = TropicalScorer(fb)
        
        defects = []
        smooth_count = 0
        for i in range(-interval, interval + 1):
            x = base + i
            Q = x * x - N
            if Q <= 0:
                continue
            sd = scorer.score_defect(Q)
            defects.append(sd)
            if sd < 1e-10:
                smooth_count += 1
        
        avg_defect = sum(defects) / len(defects)
        min_defect = min(defects)
        
        print(f"\n  B = {B:>3}, |P| = {len(fb):>2} primes")
        print(f"    Average defect: {avg_defect:.4f}")
        print(f"    Min defect:     {min_defect:.4f}")
        print(f"    Smooth count:   {smooth_count}")
        print(f"    Smooth rate:    {smooth_count/len(defects)*100:.2f}%")
        print(f"    Work (R×B):     {len(defects) * len(fb)}")
    print()


def application_large_prime_strategy():
    """
    Use tropical defect thresholds for large-prime relation strategies.
    
    Theorem: If n has exactly one prime factor q outside P, then
    scoreDefect(n) = log(q). So we accept candidates with
    defect ≤ log(B') where B' is the large-prime bound.
    """
    print("=" * 70)
    print("APPLICATION 2: Large-Prime Strategy via Defect Thresholds")
    print("=" * 70)
    
    N = 50021  # Semiprime
    fb = sieve_of_eratosthenes(30)
    base = int(math.isqrt(N)) + 1
    scorer = TropicalScorer(fb)
    
    # Analyze defect distribution
    defect_categories = defaultdict(list)
    
    for i in range(-300, 301):
        x = base + i
        Q = x * x - N
        if Q <= 0:
            continue
        
        sd = scorer.score_defect(Q)
        
        # Classify by defect
        if sd < 1e-10:
            defect_categories["smooth"].append((x, Q, sd))
        else:
            # Check if residual is prime
            residual = Q
            for p in fb:
                while residual % p == 0:
                    residual //= p
            
            if residual == 1:
                defect_categories["smooth"].append((x, Q, sd))
            elif all(residual % d != 0 for d in range(2, int(residual**0.5) + 1)) and residual > 1:
                if residual <= 100:
                    defect_categories["small-large-prime"].append((x, Q, sd, residual))
                elif residual <= 1000:
                    defect_categories["medium-large-prime"].append((x, Q, sd, residual))
                else:
                    defect_categories["large-large-prime"].append((x, Q, sd, residual))
            else:
                defect_categories["multi-factor"].append((x, Q, sd))
    
    print(f"\n  N = {N}, Factor base = primes ≤ 30")
    print(f"\n  Defect Distribution:")
    print(f"    Smooth (defect = 0):              {len(defect_categories['smooth'])}")
    print(f"    One small large prime (q ≤ 100):  {len(defect_categories['small-large-prime'])}")
    print(f"    One medium large prime (q ≤ 1000):{len(defect_categories['medium-large-prime'])}")
    print(f"    One large large prime (q > 1000): {len(defect_categories['large-large-prime'])}")
    print(f"    Multi-factor residual:            {len(defect_categories['multi-factor'])}")
    
    if defect_categories["small-large-prime"]:
        print(f"\n  Example one-large-prime relations:")
        for x, Q, sd, q in defect_categories["small-large-prime"][:5]:
            print(f"    x={x}, Q={Q}, defect={sd:.4f}, log(q)=log({q})={math.log(q):.4f}, match={abs(sd-math.log(q))<0.01}")
    print()


def application_tropical_shortest_paths():
    """
    Demonstrate the connection between min-plus matrix powers
    and shortest paths in a sieve relation graph.
    """
    print("=" * 70)
    print("APPLICATION 3: Shortest Paths in Relation Graph")
    print("=" * 70)
    
    # Create a small relation graph
    # Nodes are sieve positions, edges connect positions sharing a large prime
    n = 6
    INF = float('inf')
    
    # Edge weights = shared large prime log values
    edges = {
        (0, 1): math.log(37),   # positions 0,1 share large prime 37
        (1, 2): math.log(41),   # positions 1,2 share large prime 41
        (2, 3): math.log(43),   # positions 2,3 share large prime 43
        (0, 4): math.log(47),   # positions 0,4 share large prime 47
        (4, 5): math.log(53),   # positions 4,5 share large prime 53
        (3, 5): math.log(59),   # positions 3,5 share large prime 59
    }
    
    # Make symmetric
    sym_edges = {}
    for (i, j), w in edges.items():
        sym_edges[(i, j)] = w
        sym_edges[(j, i)] = w
    
    G = MinPlusMatrix.from_graph(sym_edges, n)
    
    print(f"\n  Relation graph with {n} sieve positions")
    print(f"  Edge weights = log(shared large prime)")
    print(f"\n  Adjacency matrix (min-plus):")
    print(f"  {G}")
    
    # Compute shortest paths via repeated squaring
    G2 = G @ G
    G3 = G2 @ G
    
    print(f"\n  After min-plus squaring (2-step shortest paths):")
    print(f"  {G2}")
    
    print(f"\n  Interpretation: entry (i,j) gives the minimum total")
    print(f"  log-weight to compose a relation chain from position i to j.")
    print(f"  Zero diagonal entries = self-relations (always available).")
    print()


def application_energy_statistics():
    """
    Compute tropical "energy" statistics over sieve intervals.
    Connects to the statistical mechanics interpretation.
    """
    print("=" * 70)
    print("APPLICATION 4: Tropical Energy Statistics")  
    print("=" * 70)
    
    N = 200003
    fb = sieve_of_eratosthenes(50)
    base = int(math.isqrt(N)) + 1
    scorer = TropicalScorer(fb)
    
    # Collect defect (energy) data
    energies = []
    for i in range(-1000, 1001):
        x = base + i
        Q = x * x - N
        if Q <= 0:
            continue
        energies.append(scorer.score_defect(Q))
    
    # Statistics
    ground_state = sum(1 for e in energies if e < 1e-10)
    low_energy = sum(1 for e in energies if 0 < e < 5)
    high_energy = sum(1 for e in energies if e >= 5)
    
    avg_energy = sum(energies) / len(energies)
    
    print(f"\n  N = {N}, Factor base = primes ≤ 50")
    print(f"  Sieve interval: 2001 positions")
    print(f"\n  Energy Distribution:")
    print(f"    Ground state (E = 0, smooth):      {ground_state:>5} ({ground_state/len(energies)*100:.1f}%)")
    print(f"    Low energy (0 < E < 5):            {low_energy:>5} ({low_energy/len(energies)*100:.1f}%)")
    print(f"    High energy (E ≥ 5):               {high_energy:>5} ({high_energy/len(energies)*100:.1f}%)")
    print(f"    Average energy:                    {avg_energy:.4f}")
    
    # Histogram
    bins = [0, 0.5, 1, 2, 3, 5, 8, 12, 20, float('inf')]
    print(f"\n  Energy Histogram:")
    for i in range(len(bins) - 1):
        count = sum(1 for e in energies if bins[i] <= e < bins[i+1])
        bar = "█" * (count // 5)
        label = f"[{bins[i]:.1f}, {bins[i+1]:.1f})" if bins[i+1] != float('inf') else f"[{bins[i]:.1f}, ∞)"
        print(f"    {label:>14}: {count:>5} {bar}")
    print()


if __name__ == "__main__":
    application_factor_base_optimization()
    application_large_prime_strategy()
    application_tropical_shortest_paths()
    application_energy_statistics()


#!/usr/bin/env python3
"""
Tropical Quadratic Sieve Shadow: Demonstrations

Demonstrates the core theorems connecting smoothness detection
to tropical (min-plus) score defects.
"""

import math
from collections import Counter
from typing import List, Dict, Tuple


def factorize(n: int) -> Counter:
    """Return prime factorization of n as a Counter {prime: exponent}."""
    if n <= 1:
        return Counter()
    factors = Counter()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] += 1
            n //= d
        d += 1
    if n > 1:
        factors[n] += 1
    return factors


def tropical_score(n: int, factor_base: List[int]) -> float:
    """
    Compute the tropical score: sum of v_p(n) * log(p) for p in factor_base.
    This is the "explained" portion of log(n) by the factor base.
    """
    if n <= 0:
        return float('-inf')
    facts = factorize(n)
    return sum(facts.get(p, 0) * math.log(p) for p in factor_base)


def score_defect(n: int, factor_base: List[int]) -> float:
    """
    Compute the score defect: log(n) - tropical_score(n, factor_base).
    Theorem C.1: This is always >= 0.
    Theorem C.2: This is 0 iff n is smooth over the factor base.
    """
    if n <= 0:
        return float('inf')
    return math.log(n) - tropical_score(n, factor_base)


def is_smooth(n: int, factor_base: List[int]) -> bool:
    """Check if n is smooth over the factor base (all prime factors in FB)."""
    if n <= 1:
        return True
    temp = n
    for p in factor_base:
        while temp % p == 0:
            temp //= p
    return temp == 1


def demo_theorem_a():
    """
    Demonstrate Theorem A: factor base log score = log(product of p^v_p(n)).
    """
    print("=" * 70)
    print("THEOREM A: Factor Base Log Score = Log(Product of p^v_p(n))")
    print("=" * 70)
    
    factor_base = [2, 3, 5, 7, 11, 13]
    test_numbers = [360, 1000, 2310, 720, 13860, 17, 97]
    
    for n in test_numbers:
        facts = factorize(n)
        
        # LHS: sum of v_p(n) * log(p)
        lhs = sum(facts.get(p, 0) * math.log(p) for p in factor_base)
        
        # RHS: log(product of p^v_p(n))
        product = 1
        for p in factor_base:
            product *= p ** facts.get(p, 0)
        rhs = math.log(product) if product > 0 else 0
        
        smooth = is_smooth(n, factor_base)
        
        print(f"\n  n = {n}")
        print(f"    Factorization: {dict(facts)}")
        print(f"    LHS (sum v_p * log p) = {lhs:.6f}")
        print(f"    RHS (log prod p^v_p)  = {rhs:.6f}")
        print(f"    Equal: {abs(lhs - rhs) < 1e-10}")
        if smooth:
            print(f"    P-smooth: YES → score = log({n}) = {math.log(n):.6f} ✓")
        else:
            print(f"    P-smooth: NO  → score {lhs:.6f} < log({n}) = {math.log(n):.6f}")
    print()


def demo_theorem_c():
    """
    Demonstrate Theorem C: scoreDefect = 0 iff P-smooth.
    """
    print("=" * 70)
    print("THEOREM C: Score Defect = 0 ⟺ P-smooth")
    print("=" * 70)
    
    factor_base = [2, 3, 5, 7]
    print(f"\n  Factor base P = {factor_base}")
    print(f"  {'n':>8} | {'log(n)':>10} | {'score':>10} | {'defect':>10} | {'smooth':>6} | defect=0?")
    print(f"  {'-'*8} | {'-'*10} | {'-'*10} | {'-'*10} | {'-'*6} | {'-'*9}")
    
    for n in range(2, 51):
        ts = tropical_score(n, factor_base)
        sd = score_defect(n, factor_base)
        smooth = is_smooth(n, factor_base)
        defect_zero = abs(sd) < 1e-10
        
        marker = "✓" if (smooth == defect_zero) else "✗"
        print(f"  {n:>8} | {math.log(n):>10.6f} | {ts:>10.6f} | {sd:>10.6f} | {str(smooth):>6} | {str(defect_zero):>6}  {marker}")
    print()


def demo_quadratic_sieve_scoring():
    """
    Demonstrate the tropical scoring of a quadratic sieve polynomial.
    Q(x) = x^2 - N for N to be factored.
    """
    print("=" * 70)
    print("QUADRATIC SIEVE: Tropical Scoring of Q(x) = x² - N")
    print("=" * 70)
    
    N = 1073  # = 29 × 37
    M = 50    # sieve interval [-M, M] around sqrt(N)
    base = int(math.isqrt(N)) + 1
    factor_base = [2, 3, 5, 7, 11, 13]
    
    print(f"\n  N = {N}")
    print(f"  sqrt(N) ≈ {math.sqrt(N):.2f}, base = {base}")
    print(f"  Factor base = {factor_base}")
    print(f"\n  Sieve interval: x ∈ [{base - M}, {base + M}]")
    print(f"\n  {'x':>5} | {'Q(x)':>8} | {'score':>10} | {'log|Q|':>10} | {'defect':>10} | smooth?")
    print(f"  {'-'*5} | {'-'*8} | {'-'*10} | {'-'*10} | {'-'*10} | {'-'*7}")
    
    smooth_count = 0
    for i in range(-M, M + 1):
        x = base + i
        Q = x * x - N
        if Q <= 0:
            continue
        
        ts = tropical_score(Q, factor_base)
        logQ = math.log(Q)
        sd = score_defect(Q, factor_base)
        smooth = is_smooth(Q, factor_base)
        
        if smooth or sd < 3.0:  # Show smooth and near-smooth
            marker = "★ SMOOTH" if smooth else f"(defect = log {int(round(math.exp(sd)))})" if sd > 0.01 else ""
            print(f"  {x:>5} | {Q:>8} | {ts:>10.4f} | {logQ:>10.4f} | {sd:>10.4f} | {marker}")
            if smooth:
                smooth_count += 1
    
    print(f"\n  Found {smooth_count} smooth relations (defect = 0)")
    print()


def demo_min_plus_matrix():
    """
    Demonstrate min-plus matrix multiplication and its associativity.
    """
    print("=" * 70)
    print("MIN-PLUS MATRIX MULTIPLICATION: Associativity Demo")
    print("=" * 70)
    
    INF = float('inf')
    
    def min_plus_mul(A, B):
        n = len(A)
        C = [[INF] * n for _ in range(n)]
        for i in range(n):
            for k in range(n):
                for j in range(n):
                    C[i][k] = min(C[i][k], A[i][j] + B[j][k])
        return C
    
    def matrix_eq(A, B, tol=1e-10):
        n = len(A)
        for i in range(n):
            for j in range(n):
                if abs(A[i][j] - B[i][j]) > tol and not (A[i][j] == INF and B[i][j] == INF):
                    return False
        return True
    
    def print_matrix(M, name):
        print(f"  {name}:")
        for row in M:
            print(f"    [{', '.join(f'{x:4.0f}' if x != INF else ' INF' for x in row)}]")
    
    # Example: shortest path interpretation
    # Vertices represent sieve positions, edges represent valuation connections
    A = [[0, 3, INF, 7],
         [INF, 0, 2, INF],
         [5, INF, 0, 1],
         [INF, INF, INF, 0]]
    
    B = [[0, INF, 4, INF],
         [2, 0, INF, 3],
         [INF, INF, 0, INF],
         [INF, 1, INF, 0]]
    
    C = [[0, 6, INF, INF],
         [INF, 0, 1, INF],
         [3, INF, 0, 2],
         [INF, INF, 4, 0]]
    
    print_matrix(A, "A")
    print_matrix(B, "B")
    print_matrix(C, "C")
    
    AB = min_plus_mul(A, B)
    AB_C = min_plus_mul(AB, C)
    
    BC = min_plus_mul(B, C)
    A_BC = min_plus_mul(A, BC)
    
    print(f"\n  (A ⊗ B) ⊗ C:")
    print_matrix(AB_C, "(A⊗B)⊗C")
    print(f"\n  A ⊗ (B ⊗ C):")
    print_matrix(A_BC, "A⊗(B⊗C)")
    
    print(f"\n  Associativity verified: {matrix_eq(AB_C, A_BC)}")
    print()


def demo_defect_landscape():
    """
    Show the defect landscape: how score defect varies across sieve positions.
    """
    print("=" * 70)
    print("SCORE DEFECT LANDSCAPE: Tropical Energy Surface")
    print("=" * 70)
    
    factor_base = [2, 3, 5, 7, 11]
    N = 2041  # = 13 × 157
    base = int(math.isqrt(N)) + 1
    
    print(f"\n  N = {N}, Factor base = {factor_base}")
    print(f"  Defect = 0: ground state (smooth)")
    print(f"  Defect > 0: excited state (non-smooth)\n")
    
    defects = []
    for i in range(-30, 31):
        x = base + i
        Q = x * x - N
        if Q <= 0:
            continue
        sd = score_defect(Q, factor_base)
        defects.append((x, Q, sd, is_smooth(Q, factor_base)))
    
    # ASCII visualization
    max_defect = max(d[2] for d in defects if d[2] < 20)
    width = 50
    
    for x, Q, sd, smooth in defects:
        bar_len = int(min(sd, max_defect) / max_defect * width) if max_defect > 0 else 0
        bar = "█" * bar_len
        marker = " ★" if smooth else ""
        if sd < 0.01:
            print(f"  x={x:>4} Q={Q:>6} |{marker} GROUND STATE (smooth)")
        else:
            print(f"  x={x:>4} Q={Q:>6} |{bar}{marker}")
    print()


def demo_idempotent_boundary():
    """
    Demonstrate the boundary theorem: idempotent + inverses = trivial.
    """
    print("=" * 70)
    print("BOUNDARY THEOREM: Why Tropical Can't Do Everything")
    print("=" * 70)
    
    print("""
  The idempotent boundary theorem states:
  
    If (G, +) is an additive group where a + a = a for all a,
    then G = {0}.
  
  This means:
  - Tropical algebra (where min(a,a) = a, i.e., idempotent "addition")
    CANNOT have nontrivial inverses.
  - The GF(2) linear algebra stage of QS requires additive inverses
    (since GF(2) = {0,1} with 1+1=0, not 1+1=1).
  - Therefore: tropical framework covers SCORING but not SOLVING.
  
  This is not a bug — it's a feature:
  - Tropical front-end: candidate generation (O(R·B) scoring)  
  - Classical back-end: relation verification and Gaussian elimination
  
  The hybrid architecture is the real insight.
    """)


if __name__ == "__main__":
    demo_theorem_a()
    demo_theorem_c()
    demo_quadratic_sieve_scoring()
    demo_min_plus_matrix()
    demo_defect_landscape()
    demo_idempotent_boundary()


#!/usr/bin/env python3
"""
Tropical Quadratic Sieve: Visualizations

Generates publication-quality figures illustrating the tropical
smoothness score theory.
"""

import math
import base64
import io
from collections import Counter
from typing import List

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np


def factorize(n):
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = 1
    return factors


def p_adic_val(n, p):
    v = 0
    while n > 0 and n % p == 0:
        v += 1
        n //= p
    return v


def tropical_score(n, fb):
    if n <= 0:
        return 0
    return sum(p_adic_val(n, p) * math.log(p) for p in fb)


def score_defect(n, fb):
    if n <= 0:
        return float('inf')
    return math.log(n) - tropical_score(n, fb)


def is_smooth(n, fb):
    return abs(score_defect(n, fb)) < 1e-10


def sieve_primes(limit):
    if limit < 2:
        return []
    s = [True] * (limit + 1)
    s[0] = s[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if s[i]:
            for j in range(i*i, limit + 1, i):
                s[j] = False
    return [i for i in range(2, limit + 1) if s[i]]


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_defect_landscape():
    """Score defect landscape over a sieve interval."""
    N = 2041
    fb = [2, 3, 5, 7, 11]
    base = int(math.isqrt(N)) + 1
    
    xs, defects, colors = [], [], []
    for i in range(-60, 61):
        x = base + i
        Q = x * x - N
        if Q <= 0:
            continue
        sd = score_defect(Q, fb)
        xs.append(x)
        defects.append(min(sd, 15))
        colors.append('gold' if sd < 1e-10 else 'steelblue')
    
    fig, ax = plt.subplots(figsize=(12, 5))
    ax.bar(xs, defects, color=colors, width=0.8, edgecolor='none', alpha=0.85)
    ax.axhline(y=0, color='red', linewidth=1.5, linestyle='--', label='Ground state (smooth)')
    ax.set_xlabel('Sieve position x', fontsize=13)
    ax.set_ylabel('Score defect δ_P(Q(x))', fontsize=13)
    ax.set_title(f'Tropical Score Defect Landscape: Q(x) = x² − {N}, P = {{{", ".join(map(str, fb))}}}', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(-0.5, 16)
    
    # Annotate smooth values
    for x, d in zip(xs, defects):
        if d < 1e-10:
            Q = x * x - N
            ax.annotate(f'{Q}', (x, 0.3), fontsize=7, ha='center', rotation=90, color='darkred')
    
    fig.tight_layout()
    return fig


def viz_score_comparison():
    """Compare tropical score vs log(n) for various n."""
    fb = [2, 3, 5, 7, 11, 13]
    
    ns = list(range(2, 201))
    scores = [tropical_score(n, fb) for n in ns]
    logs = [math.log(n) for n in ns]
    smooth_mask = [is_smooth(n, fb) for n in ns]
    
    fig, ax = plt.subplots(figsize=(12, 6))
    
    # Plot log(n)
    ax.plot(ns, logs, 'k-', linewidth=2, label='log(n)', alpha=0.7)
    
    # Plot tropical scores
    smooth_ns = [n for n, s in zip(ns, smooth_mask) if s]
    smooth_scores = [sc for sc, s in zip(scores, smooth_mask) if s]
    nonsmooth_ns = [n for n, s in zip(ns, smooth_mask) if not s]
    nonsmooth_scores = [sc for sc, s in zip(scores, smooth_mask) if not s]
    
    ax.scatter(nonsmooth_ns, nonsmooth_scores, c='steelblue', s=15, alpha=0.5, label='Non-smooth (defect > 0)')
    ax.scatter(smooth_ns, smooth_scores, c='gold', s=40, zorder=5, edgecolors='darkred', linewidth=0.5, label='Smooth (defect = 0)')
    
    ax.set_xlabel('n', fontsize=13)
    ax.set_ylabel('Score', fontsize=13)
    ax.set_title(f'Tropical Score vs log(n): Factor base P = {{{", ".join(map(str, fb))}}}', fontsize=14)
    ax.legend(fontsize=11, loc='lower right')
    
    fig.tight_layout()
    return fig


def viz_defect_histogram():
    """Histogram of score defects over a sieve interval."""
    N = 100003
    fb = sieve_primes(50)
    base = int(math.isqrt(N)) + 1
    
    defects = []
    for i in range(-500, 501):
        x = base + i
        Q = x * x - N
        if Q <= 0:
            continue
        defects.append(score_defect(Q, fb))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Separate zero defects
    zero_count = sum(1 for d in defects if d < 0.1)
    nonzero = [d for d in defects if d >= 0.1]
    
    ax.hist(nonzero, bins=40, color='steelblue', alpha=0.7, edgecolor='navy', linewidth=0.5)
    ax.axvline(x=0, color='red', linewidth=2, linestyle='--')
    
    # Add annotation for smooth count
    ax.annotate(f'{zero_count} smooth values\n(defect = 0)',
                xy=(0.5, 0.9), xycoords='axes fraction',
                fontsize=12, color='darkred',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='darkred'))
    
    ax.set_xlabel('Score defect δ_P(Q(x))', fontsize=13)
    ax.set_ylabel('Count', fontsize=13)
    ax.set_title(f'Distribution of Tropical Score Defects\nN = {N}, P = primes ≤ 50, interval = 1001 positions', fontsize=14)
    
    fig.tight_layout()
    return fig


def viz_smoothness_rate():
    """Smoothness rate as factor base grows."""
    N = 50021
    base = int(math.isqrt(N)) + 1
    interval = 300
    
    bounds = list(range(5, 101, 5))
    rates = []
    fb_sizes = []
    
    for B in bounds:
        fb = sieve_primes(B)
        fb_sizes.append(len(fb))
        smooth = 0
        total = 0
        for i in range(-interval, interval + 1):
            x = base + i
            Q = x * x - N
            if Q <= 0:
                continue
            total += 1
            if is_smooth(Q, fb):
                smooth += 1
        rates.append(smooth / total * 100 if total > 0 else 0)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.plot(bounds, rates, 'o-', color='steelblue', linewidth=2, markersize=6)
    ax1.set_xlabel('Factor base bound B', fontsize=13)
    ax1.set_ylabel('Smoothness rate (%)', fontsize=13)
    ax1.set_title('Smooth Relation Yield vs Factor Base Size', fontsize=14)
    ax1.grid(True, alpha=0.3)
    
    # Work vs yield tradeoff
    work = [fb_sizes[i] * (2 * interval + 1) for i in range(len(bounds))]
    ax2.plot([w/1000 for w in work], rates, 'o-', color='darkred', linewidth=2, markersize=6)
    ax2.set_xlabel('Work (thousands of tropical operations)', fontsize=13)
    ax2.set_ylabel('Smoothness rate (%)', fontsize=13)
    ax2.set_title('Efficiency: Yield per Unit of Tropical Work', fontsize=14)
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    return fig


def viz_valuation_vectors():
    """Visualize valuation vectors as a heatmap."""
    fb = [2, 3, 5, 7, 11]
    N = 1073
    base = int(math.isqrt(N)) + 1
    
    positions = []
    vectors = []
    Q_values = []
    smooth_flags = []
    
    for i in range(-20, 21):
        x = base + i
        Q = x * x - N
        if Q <= 0 or Q > 10000:
            continue
        vec = [p_adic_val(Q, p) for p in fb]
        if sum(vec) > 0:  # At least some factor base divisibility
            positions.append(x)
            vectors.append(vec)
            Q_values.append(Q)
            smooth_flags.append(is_smooth(Q, fb))
    
    if not vectors:
        return None
    
    data = np.array(vectors)
    
    fig, ax = plt.subplots(figsize=(10, max(6, len(positions) * 0.3)))
    
    im = ax.imshow(data, aspect='auto', cmap='YlOrRd', interpolation='nearest')
    
    ax.set_xticks(range(len(fb)))
    ax.set_xticklabels([f'v_{p}' for p in fb], fontsize=12)
    ax.set_yticks(range(len(positions)))
    labels = []
    for i, (x, Q, s) in enumerate(zip(positions, Q_values, smooth_flags)):
        marker = " ★" if s else ""
        labels.append(f"x={x}, Q={Q}{marker}")
    ax.set_yticklabels(labels, fontsize=9)
    
    ax.set_xlabel('Prime valuations', fontsize=13)
    ax.set_title(f'Valuation Vectors: Q(x) = x² − {N}', fontsize=14)
    
    plt.colorbar(im, ax=ax, label='Valuation v_p(Q(x))')
    fig.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and return as base64 data URIs."""
    results = {}
    
    print("Generating defect landscape...")
    fig = viz_defect_landscape()
    results['defect_landscape'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/defect_landscape.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating score comparison...")
    fig = viz_score_comparison()
    results['score_comparison'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/score_comparison.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating defect histogram...")
    fig = viz_defect_histogram()
    results['defect_histogram'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/defect_histogram.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating smoothness rate...")
    fig = viz_smoothness_rate()
    results['smoothness_rate'] = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/smoothness_rate.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    
    print("Generating valuation vectors...")
    fig = viz_valuation_vectors()
    if fig:
        results['valuation_vectors'] = fig_to_base64(fig)
        fig.savefig('/workspace/request-project/valuation_vectors.png', dpi=150, bbox_inches='tight')
        plt.close(fig)
    
    return results


if __name__ == "__main__":
    results = generate_all_visualizations()
    print(f"\nGenerated {len(results)} visualizations")
    for name in results:
        print(f"  - {name}: {len(results[name])} chars")
