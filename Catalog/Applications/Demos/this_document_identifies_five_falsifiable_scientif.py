#!/usr/bin/env python3
"""
applications.py — Real-world applications of the KW witness counting theory.

Demonstrates connections to:
1. Communication complexity lower bounds
2. Circuit depth bounds (Karchmer-Wigderson theorem)
3. Information-theoretic analysis
4. Optimal transport on the Hamming cube
"""

from math import comb, log2, sqrt, pi
from algorithms import (
    kw_witness_count_symmetric,
    kw_witness_count_threshold,
    fiber_total,
    fiber_decomposition,
    boundary_contribution,
    witness_entropy,
)


# ─────────────────────────────────────────────────────────────
#  APPLICATION 1: Communication Complexity Lower Bounds
# ─────────────────────────────────────────────────────────────

def communication_lower_bound(n: int, profile: list[bool]) -> float:
    """Lower bound on communication complexity of f from KW witness count.
    
    The Karchmer-Wigderson theorem establishes that the communication
    complexity of the KW relation equals the formula depth of f.
    Any protocol must distinguish |KWWitness(f)| different witness triples,
    giving a lower bound of log₂(|KWWitness(f)| / max_output_density).
    
    A simpler bound: the number of distinct (x,y) pairs that appear
    as KW witnesses gives D(KW_f) ≥ log₂(|{(x,y) : ∃i, (x,y,i) ∈ KW}|).
    
    Here we compute the witness entropy log₂|KWWitness(f)| as a first measure.
    
    Args:
        n: Number of variables.
        profile: Boolean profile of the symmetric function.
    
    Returns:
        Lower bound on communication/formula complexity.
    """
    count = kw_witness_count_symmetric(n, profile)
    if count == 0:
        return 0.0
    # This is a rough lower bound; the true KW theorem gives exact formula depth
    return log2(count)


def compare_kw_bounds_with_trivial(n: int, t: int) -> dict:
    """Compare the KW witness entropy bound with trivial bounds.
    
    Trivial upper bound: formula depth ≤ n (a DNF/CNF has depth ≤ n).
    
    For threshold functions, the actual optimal formula depth is known 
    to be Θ(n) for fixed t/n ratio.
    
    Returns:
        Dictionary with various bounds.
    """
    kw_count = kw_witness_count_threshold(n, t)
    boundary_lb = boundary_contribution(n, t)
    
    return {
        "n": n,
        "t": t,
        "kw_witness_count": kw_count,
        "witness_entropy": log2(kw_count) if kw_count > 0 else 0,
        "boundary_lower_bound": boundary_lb,
        "boundary_entropy": log2(boundary_lb) if boundary_lb > 0 else 0,
        "trivial_upper_bound": n,
    }


# ─────────────────────────────────────────────────────────────
#  APPLICATION 2: Circuit Depth Analysis
# ─────────────────────────────────────────────────────────────

def formula_depth_bounds_threshold(n: int, t: int) -> dict:
    """Bounds on formula depth for threshold functions.
    
    The Karchmer-Wigderson theorem says:
        formula_depth(f) = D(KW_f)
    
    where D(KW_f) is the deterministic communication complexity of the KW relation.
    
    Our witness count gives:
        log₂|KWWitness(f)| as raw entropy measure.
    
    The actual communication complexity is bounded by:
        ⌈log₂(n)⌉ ≤ D(KW_{Thresh(n,t)}) ≤ n
    
    Our theory gives finer control via the fiber decomposition.
    """
    kw = kw_witness_count_threshold(n, t)
    return {
        "n": n,
        "t": t,
        "witness_count": kw,
        "witness_entropy": log2(kw) if kw > 0 else 0,
        "min_formula_depth": max(1, int(log2(n)) + 1) if n > 1 else 1,
        "max_formula_depth": n,
    }


# ─────────────────────────────────────────────────────────────
#  APPLICATION 3: Information-Theoretic Analysis
# ─────────────────────────────────────────────────────────────

def witness_distribution(n: int, profile: list[bool]) -> dict:
    """Compute the distribution of witnesses across weight-pair fibers.
    
    This reveals where the "complexity" of a Boolean function concentrates:
    - Functions with witnesses concentrated near the boundary are "easy"
    - Functions with witnesses spread across many fibers are "hard"
    
    Returns:
        Dictionary mapping (k,l) to fraction of total witnesses.
    """
    fibers = fiber_decomposition(n, profile)
    total = sum(d["total"] for d in fibers.values())
    if total == 0:
        return {}
    return {kl: d["total"] / total for kl, d in fibers.items()}


def witness_concentration_ratio(n: int, t: int) -> float:
    """Fraction of witnesses from the boundary layer (t, t-1) alone.
    
    A high ratio means the threshold function's complexity is dominated
    by its boundary, suggesting tight lower bounds from boundary analysis.
    """
    total = kw_witness_count_threshold(n, t)
    boundary = fiber_total(n, t, t - 1)
    return boundary / total if total > 0 else 0.0


# ─────────────────────────────────────────────────────────────
#  APPLICATION 4: Discrete Transport on the Hamming Cube
# ─────────────────────────────────────────────────────────────

def transport_cost(n: int, profile: list[bool]) -> int:
    """Interpret the witness count as a discrete transport cost.
    
    The KW witness formula has the structure:
        |KWWitness(f)| = Σ_{k,l} μ_T(k) * μ_F(l) * cost(k,l)
    
    where:
        μ_T(k) = C(n,k) if profile[k] = True
        μ_F(l) = C(n,l) if profile[l] = False
        cost(k,l) = (fiber contribution per pair)
    
    This is analogous to a discrete Wasserstein-1 cost between the
    "true" and "false" weight distributions, with a metric related to
    (but not equal to) |k-l|.
    """
    return kw_witness_count_symmetric(n, profile)


def wasserstein_comparison(n: int, t: int) -> dict:
    """Compare the KW witness cost with the discrete Wasserstein-1 cost.
    
    W₁ = Σ_{k≥t, l<t} C(n,k) * C(n,l) * |k-l|  (wrong formula!)
    KW = Σ_{k≥t, l<t} fiberTotal(n, k, l)         (correct formula!)
    
    The ratio KW/W₁ measures how much the full coordinate-level
    structure inflates the naive weight-distance cost.
    """
    kw = kw_witness_count_threshold(n, t)
    w1 = sum(
        comb(n, k) * comb(n, l) * abs(k - l)
        for k in range(t, n + 1)
        for l in range(t)
    )
    return {
        "n": n,
        "t": t,
        "kw_count": kw,
        "wasserstein_1": w1,
        "ratio": kw / w1 if w1 > 0 else float("inf"),
    }


# ─────────────────────────────────────────────────────────────
#  DEMONSTRATION
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF KW WITNESS COUNTING THEORY")
    print("=" * 70)
    
    # App 1: Communication bounds
    print("\n1. COMMUNICATION COMPLEXITY BOUNDS (Threshold functions)")
    print("-" * 60)
    print(f"{'n':>4} {'t':>4} {'|KW|':>12} {'Entropy':>8} {'Boundary':>10}")
    for n in [5, 10, 15, 20]:
        t = (n + 1) // 2
        bounds = compare_kw_bounds_with_trivial(n, t)
        print(f"{n:>4} {t:>4} {bounds['kw_witness_count']:>12} "
              f"{bounds['witness_entropy']:>8.2f} "
              f"{bounds['boundary_entropy']:>10.2f}")
    
    # App 2: Witness concentration
    print("\n2. BOUNDARY CONCENTRATION for Majority")
    print("-" * 60)
    print(f"{'n':>4} {'Boundary/Total':>16} {'Interpretation'}")
    for n in range(3, 16):
        t = (n + 1) // 2
        ratio = witness_concentration_ratio(n, t)
        interp = "boundary-dominated" if ratio > 0.5 else "spread across fibers"
        print(f"{n:>4} {ratio:>16.4f}    {interp}")
    
    # App 3: Transport comparison
    print("\n3. KW COUNT vs WASSERSTEIN-1 COST")
    print("-" * 60)
    print(f"{'n':>4} {'t':>4} {'KW':>12} {'W₁':>12} {'KW/W₁':>8}")
    for n in [3, 5, 7, 10, 15, 20]:
        t = (n + 1) // 2
        comp = wasserstein_comparison(n, t)
        print(f"{n:>4} {t:>4} {comp['kw_count']:>12} "
              f"{comp['wasserstein_1']:>12} {comp['ratio']:>8.4f}")
    
    # App 4: Fiber distribution heatmap (text)
    print("\n4. WITNESS DISTRIBUTION for Thresh(6, 3)")
    print("-" * 60)
    n = 6
    t = 3
    profile = [k >= t for k in range(n + 1)]
    dist = witness_distribution(n, profile)
    print(f"{'(k,l)':>8} {'Fraction':>10} {'Bar'}")
    for (k, l), frac in sorted(dist.items(), key=lambda x: -x[1]):
        bar = "█" * int(frac * 50)
        print(f"({k},{l}){' ' * max(0, 5 - len(f'({k},{l})'))} {frac:>10.4f}  {bar}")
    
    print("\n" + "=" * 70)
    print("All applications demonstrated.")


#!/usr/bin/env python3
"""
demo.py — Concrete numerical demonstrations of the KW Witness Counting Theory.

Shows the exact formulas for symmetric Boolean functions, threshold functions,
and validates against brute-force computation for small n.
"""

from math import comb
from itertools import product as cartprod


def hamming_weight(x: tuple[bool, ...]) -> int:
    """Number of True entries in a Boolean vector."""
    return sum(x)


def threshold_fn(n: int, t: int, x: tuple[bool, ...]) -> bool:
    """Threshold function: True iff hamming_weight(x) >= t."""
    return hamming_weight(x) >= t


def count_kw_witnesses_brute(n: int, f) -> int:
    """Brute-force count of KW witnesses (x, y, i) with f(x)=True, f(y)=False, x[i]!=y[i]."""
    vecs = list(cartprod([False, True], repeat=n))
    count = 0
    for x in vecs:
        if not f(x):
            continue
        for y in vecs:
            if f(y):
                continue
            for i in range(n):
                if x[i] != y[i]:
                    count += 1
    return count


def fiber_tf(n: int, k: int, l: int) -> int:
    """Per-fiber witness count from true->false orientation.
    Counts triples (x,y,i) with |x|=k, |y|=l, x_i=True, y_i=False."""
    if k == 0:
        return 0
    return n * comb(n - 1, k - 1) * comb(n - 1, l)


def fiber_ft(n: int, k: int, l: int) -> int:
    """Per-fiber witness count from false->true orientation.
    Counts triples (x,y,i) with |x|=k, |y|=l, x_i=False, y_i=True."""
    if l == 0:
        return 0
    return n * comb(n - 1, k) * comb(n - 1, l - 1)


def fiber_total(n: int, k: int, l: int) -> int:
    """Total per-fiber witness count."""
    return fiber_tf(n, k, l) + fiber_ft(n, k, l)


def kw_count_symmetric(n: int, profile: list[bool]) -> int:
    """Exact KW witness count for a symmetric function with given profile.
    
    profile[k] = True means f(x) = True when hamming_weight(x) = k.
    """
    assert len(profile) == n + 1
    total = 0
    for k in range(n + 1):
        for l in range(n + 1):
            if profile[k] and not profile[l]:
                total += fiber_total(n, k, l)
    return total


def kw_count_threshold(n: int, t: int) -> int:
    """Exact KW witness count for the threshold function Thresh(n, t)."""
    profile = [k >= t for k in range(n + 1)]
    return kw_count_symmetric(n, profile)


def conjectured_formula(n: int, t: int) -> int:
    """The WRONG formula: sum C(n,k)*C(n,l)*|k-l| (for comparison)."""
    total = 0
    for k in range(t, n + 1):
        for l in range(t):
            total += comb(n, k) * comb(n, l) * abs(k - l)
    return total


# ─────────────────────────────────────────────────────────────
#  DEMONSTRATION
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("KW WITNESS COUNTING THEORY — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)
    
    # 1. Validate exact formula against brute force
    print("\n1. VALIDATION: Exact formula vs brute-force count")
    print("-" * 50)
    print(f"{'n':>3} {'t':>3} {'Brute':>10} {'Formula':>10} {'Match':>7}")
    for n in range(1, 6):
        for t in range(1, n + 1):
            brute = count_kw_witnesses_brute(n, lambda x, n=n, t=t: threshold_fn(n, t, x))
            formula = kw_count_threshold(n, t)
            match = "✓" if brute == formula else "✗"
            print(f"{n:>3} {t:>3} {brute:>10} {formula:>10} {match:>7}")
    
    # 2. Counterexample to the conjectured formula
    print("\n2. COUNTEREXAMPLE: Conjectured vs correct formula")
    print("-" * 50)
    print(f"{'n':>3} {'t':>3} {'Conjectured':>12} {'Correct':>10} {'Equal':>7}")
    for n in range(1, 8):
        for t in [1, n // 2, (n + 1) // 2, n]:
            if t < 1 or t > n:
                continue
            conj = conjectured_formula(n, t)
            corr = kw_count_threshold(n, t)
            eq = "✓" if conj == corr else "✗ WRONG"
            print(f"{n:>3} {t:>3} {conj:>12} {corr:>10} {eq:>7}")
    
    # 3. Fiber decomposition for Thresh(3, 2)
    print("\n3. FIBER DECOMPOSITION: Thresh(3, 2)")
    print("-" * 50)
    n, t = 3, 2
    print(f"{'(k,l)':>8} {'TF':>8} {'FT':>8} {'Total':>8}")
    grand_total = 0
    for k in range(t, n + 1):
        for l in range(t):
            tf = fiber_tf(n, k, l)
            ft = fiber_ft(n, k, l)
            tot = fiber_total(n, k, l)
            grand_total += tot
            print(f"({k},{l}){' ' * (5 - len(f'({k},{l})'))} {tf:>8} {ft:>8} {tot:>8}")
    print(f"{'TOTAL':>8} {'':>8} {'':>8} {grand_total:>8}")
    
    # 4. Boundary layer lower bound
    print("\n4. BOUNDARY LAYER LOWER BOUND: C(n,t)*C(n,t-1)")
    print("-" * 50)
    print(f"{'n':>3} {'t':>3} {'C(n,t)*C(n,t-1)':>18} {'|KW(Thresh)|':>14} {'Ratio':>8}")
    for n in range(2, 12):
        t = (n + 1) // 2  # majority
        lb = comb(n, t) * comb(n, t - 1)
        total = kw_count_threshold(n, t)
        ratio = total / lb if lb > 0 else float('inf')
        print(f"{n:>3} {t:>3} {lb:>18} {total:>14} {ratio:>8.3f}")
    
    # 5. Growth rate of witness counts for majority
    print("\n5. MAJORITY FUNCTION WITNESS COUNTS")
    print("-" * 50)
    print(f"{'n':>3} {'|KW(Maj)|':>14} {'log2':>8} {'n*log2(n)':>10}")
    import math
    for n in range(1, 16):
        t = (n + 1) // 2
        w = kw_count_threshold(n, t)
        log2w = math.log2(w) if w > 0 else 0
        nlogn = n * math.log2(n) if n > 1 else 0
        print(f"{n:>3} {w:>14} {log2w:>8.2f} {nlogn:>10.2f}")
    
    # 6. Non-threshold symmetric function: parity
    print("\n6. NON-MONOTONE SYMMETRIC: Parity function")
    print("-" * 50)
    for n in range(1, 7):
        profile = [k % 2 == 1 for k in range(n + 1)]
        formula = kw_count_symmetric(n, profile)
        brute = count_kw_witnesses_brute(n, lambda x: hamming_weight(x) % 2 == 1)
        print(f"n={n}: |KW(Parity)| = {formula} (brute: {brute}, match: {'✓' if formula == brute else '✗'})")
    
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
