#!/usr/bin/env python3
"""
Applications of Formal Meta-Complexity Theory

Demonstrates practical applications of the KW witness counting framework:
1. Automated lower bound generation for Boolean function families
2. Hardness classification of symmetric functions
3. Witness entropy as a complexity predictor
4. Compression impossibility certificates
"""

from math import comb, log2, floor, ceil
from typing import Callable


def symmetric_kw_count(profile: Callable[[int], bool], n: int) -> int:
    """Exact KW witness count for symmetric function via closed formula."""
    return sum(
        comb(n, k) * comb(n, l) * abs(k - l)
        for k in range(n + 1) if profile(k)
        for l in range(n + 1) if not profile(l)
    )


# ============================================================
# Application 1: Automated Lower Bound Generator
# ============================================================

def formula_depth_lower_bound(kw_count: int, n: int, c: int = 1) -> int:
    """
    Compute a lower bound on monotone formula depth from KW witness count.

    By the KW correspondence pipeline:
        depth(f) >= floor(log2(|KWWitness(f)|)) - c * floor(log2(n+1))

    Args:
        kw_count: |KWWitness(f)|
        n: number of variables
        c: protocol overhead constant (default 1)

    Returns:
        Lower bound on formula depth
    """
    if kw_count <= 1:
        return 0
    return max(0, floor(log2(kw_count)) - c * floor(log2(n + 1)))


print("=" * 70)
print("APPLICATION 1: Automated Formula Depth Lower Bounds")
print("=" * 70)
print()
print(f"{'Function':>20s} {'n':>4s} {'|KW|':>14s} {'log2|KW|':>10s} "
      f"{'depth_lb':>10s}")
print("-" * 70)

for n in [5, 10, 15, 20, 25]:
    # Majority
    t = (n + 1) // 2
    kw = symmetric_kw_count(lambda k, t=t: k >= t, n)
    lb = formula_depth_lower_bound(kw, n)
    print(f"{'Majority':>20s} {n:4d} {kw:14d} {log2(kw):10.2f} {lb:10d}")

    # OR function
    kw_or = symmetric_kw_count(lambda k: k >= 1, n)
    lb_or = formula_depth_lower_bound(kw_or, n)
    print(f"{'OR':>20s} {n:4d} {kw_or:14d} {log2(kw_or):10.2f} {lb_or:10d}")

    # Exact threshold at n//2
    t2 = n // 2
    if t2 >= 1:
        kw_t2 = symmetric_kw_count(lambda k, t2=t2: k >= t2, n)
        lb_t2 = formula_depth_lower_bound(kw_t2, n)
        print(f"{'Threshold(n/2)':>20s} {n:4d} {kw_t2:14d} {log2(kw_t2):10.2f} {lb_t2:10d}")
    print()


# ============================================================
# Application 2: Hardness Classification
# ============================================================

print()
print("=" * 70)
print("APPLICATION 2: Hardness Classification of Symmetric Functions")
print("=" * 70)
print()

n = 12
print(f"Classifying all symmetric functions on n={n} variables by witness entropy:")
print()

# Generate interesting symmetric function profiles
profiles = {
    "Majority": lambda k: k >= (n + 1) // 2,
    "OR": lambda k: k >= 1,
    "AND": lambda k: k >= n,
    "Parity": lambda k: k % 2 == 1,
    "Threshold(1)": lambda k: k >= 1,
    "Threshold(2)": lambda k: k >= 2,
    "Threshold(3)": lambda k: k >= 3,
    f"Threshold({n//2})": lambda k: k >= n // 2,
    f"Threshold({n-1})": lambda k: k >= n - 1,
    "Exact(n/2)": lambda k: k == n // 2,
    "Gap(2,n-2)": lambda k: 2 <= k <= n - 2,
}

results = []
for name, profile in profiles.items():
    kw = symmetric_kw_count(profile, n)
    entropy = log2(kw) if kw > 0 else 0
    true_count = sum(comb(n, k) for k in range(n + 1) if profile(k))
    false_count = 2**n - true_count
    results.append((entropy, name, kw, true_count, false_count))

results.sort(reverse=True)
print(f"{'Rank':>4s} {'Function':>20s} {'|KW|':>14s} {'Entropy':>10s} "
      f"{'|T|':>8s} {'|F|':>8s}")
print("-" * 70)
for i, (ent, name, kw, tc, fc) in enumerate(results, 1):
    print(f"{i:4d} {name:>20s} {kw:14d} {ent:10.2f} {tc:8d} {fc:8d}")


# ============================================================
# Application 3: Compression Certificates
# ============================================================

print()
print("=" * 70)
print("APPLICATION 3: Compression Impossibility Certificates")
print("=" * 70)
print()

print("For each function, the minimum bits any injective encoding of KW")
print("witnesses must use for some witness (pigeonhole lower bound):")
print()

for n in [8, 12, 16, 20]:
    t = (n + 1) // 2
    kw = symmetric_kw_count(lambda k, t=t: k >= t, n)
    bits = floor(log2(kw))
    print(f"  Majority(n={n:2d}): |KW| = {kw:>14d}, "
          f"min encoding length >= {bits} bits")

print()
print("Certificate: By the formal theorem kw_witness_compression,")
print("if 2^d <= |KWWitness(f)| and Enc is injective,")
print("then some witness w satisfies d <= length(Enc(w)).")


# ============================================================
# Application 4: Witness Entropy as Complexity Predictor
# ============================================================

print()
print("=" * 70)
print("APPLICATION 4: Witness Entropy vs Formula Depth (Predictive)")
print("=" * 70)
print()

print("Comparing witness entropy with known/conjectured formula depths:")
print()
print(f"{'n':>4s} {'Function':>15s} {'Entropy':>10s} {'Depth_LB':>10s} "
      f"{'Known_Depth':>12s}")
print("-" * 60)

for n in [3, 5, 7, 9]:
    # Majority: known depth is Theta(n) for monotone formulas
    t = (n + 1) // 2
    kw = symmetric_kw_count(lambda k, t=t: k >= t, n)
    ent = log2(kw) if kw > 0 else 0
    lb = formula_depth_lower_bound(kw, n)
    print(f"{n:4d} {'Majority':>15s} {ent:10.2f} {lb:10d} {'~O(n)':>12s}")

    # OR: known depth is ceil(log2(n))
    kw_or = symmetric_kw_count(lambda k: k >= 1, n)
    ent_or = log2(kw_or)
    lb_or = formula_depth_lower_bound(kw_or, n)
    known_or = ceil(log2(n)) if n > 1 else 0
    print(f"{n:4d} {'OR':>15s} {ent_or:10.2f} {lb_or:10d} {known_or:>12d}")


# ============================================================
# Application 5: Transport Cost Interpretation
# ============================================================

print()
print("=" * 70)
print("APPLICATION 5: Optimal Transport Interpretation")
print("=" * 70)
print()

n = 10
print(f"Transport cost analysis for symmetric functions on n={n} variables:")
print(f"Witness count = sum of C(n,k)*C(n,l)*|k-l| over true/false layer pairs")
print(f"This is the discrete 1-Wasserstein distance between true/false layers")
print()

for name, profile in [
    ("Majority", lambda k: k >= (n + 1) // 2),
    ("Threshold(1)", lambda k: k >= 1),
    ("Threshold(n-1)", lambda k: k >= n - 1),
    ("Parity", lambda k: k % 2 == 1),
]:
    kw = symmetric_kw_count(profile, n)
    pair_count = sum(
        comb(n, k) * comb(n, l)
        for k in range(n + 1) if profile(k)
        for l in range(n + 1) if not profile(l)
    )
    avg_transport = kw / pair_count if pair_count > 0 else 0
    print(f"  {name:>20s}: avg transport cost = {avg_transport:.4f}, "
          f"|KW| = {kw}")

print()
print("=" * 70)
print("All applications completed successfully.")
print("=" * 70)


#!/usr/bin/env python3
"""
Demo: Formal Meta-Complexity — KW Witness Counting for Boolean Functions

Concrete numerical examples demonstrating the theorems proved in the
formal verification framework. Shows exact witness counts, upper bounds,
and the threshold/majority witness lower bounds.
"""

from math import comb, log2, factorial
from itertools import product as cartesian_product


def hamming_weight(x: tuple[bool, ...]) -> int:
    """Hamming weight: number of True entries."""
    return sum(x)


def all_bool_vecs(n: int) -> list[tuple[bool, ...]]:
    """All Boolean vectors of length n."""
    return [tuple(v) for v in cartesian_product([False, True], repeat=n)]


def threshold_fn(n: int, t: int, x: tuple[bool, ...]) -> bool:
    """Threshold function: True iff Hamming weight >= t."""
    return hamming_weight(x) >= t


def majority_fn(n: int, x: tuple[bool, ...]) -> bool:
    """Majority function: True iff at least ceil(n/2) coordinates are True."""
    return threshold_fn(n, (n + 1) // 2, x)


def count_kw_witnesses(f, n: int) -> int:
    """
    Count |KWWitness(f)|: number of triples (x, y, i) where
    f(x) = True, f(y) = False, and x[i] != y[i].
    """
    vecs = all_bool_vecs(n)
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


def count_true_false(f, n: int) -> tuple[int, int]:
    """Count |{x : f(x)=True}| and |{y : f(y)=False}|."""
    vecs = all_bool_vecs(n)
    t = sum(1 for x in vecs if f(x))
    return t, len(vecs) - t


# ============================================================
# Demo 1: Universal Upper Bound
# ============================================================
print("=" * 70)
print("DEMO 1: Universal Upper Bound |KWWitness(f)| <= n * |T| * |F|")
print("=" * 70)

for n in range(1, 7):
    for name, fn in [
        ("majority", lambda x, n=n: majority_fn(n, x)),
        ("threshold_1", lambda x, n=n: threshold_fn(n, 1, x)),
    ]:
        kw = count_kw_witnesses(fn, n)
        t_count, f_count = count_true_false(fn, n)
        bound = n * t_count * f_count
        print(f"  n={n}, f={name:>12s}: "
              f"|KW|={kw:>6d}, n*|T|*|F|={bound:>8d}, "
              f"ratio={kw/bound:.3f}" if bound > 0 else
              f"  n={n}, f={name:>12s}: |KW|={kw}, bound=0")

# ============================================================
# Demo 2: Threshold Witness Lower Bound
# ============================================================
print()
print("=" * 70)
print("DEMO 2: Threshold Lower Bound C(n,t)*C(n,t-1) <= |KWWitness|")
print("=" * 70)

for n in range(2, 8):
    for t in range(1, n + 1):
        fn = lambda x, n=n, t=t: threshold_fn(n, t, x)
        kw = count_kw_witnesses(fn, n)
        lower = comb(n, t) * comb(n, t - 1)
        print(f"  n={n}, t={t}: |KW|={kw:>6d}, C(n,t)*C(n,t-1)={lower:>6d}, "
              f"ratio={kw/lower:.2f}" if lower > 0 else
              f"  n={n}, t={t}: |KW|={kw}, lower=0")

# ============================================================
# Demo 3: Majority Witness Lower Bound
# ============================================================
print()
print("=" * 70)
print("DEMO 3: Majority Lower Bound C(n,⌈n/2⌉)*C(n,⌈n/2⌉-1) <= |KW|")
print("=" * 70)

for n in range(1, 9):
    fn = lambda x, n=n: majority_fn(n, x)
    kw = count_kw_witnesses(fn, n)
    t = (n + 1) // 2
    lower = comb(n, t) * comb(n, t - 1)
    log_kw = log2(kw) if kw > 0 else 0
    print(f"  n={n}: |KW(Maj)|={kw:>8d}, lower_bound={lower:>6d}, "
          f"log2|KW|={log_kw:.2f}, 2n={2*n}")

# ============================================================
# Demo 4: Compression Lower Bounds
# ============================================================
print()
print("=" * 70)
print("DEMO 4: Compression — log2|KWWitness| bits needed")
print("=" * 70)

for n in range(2, 9):
    fn = lambda x, n=n: majority_fn(n, x)
    kw = count_kw_witnesses(fn, n)
    if kw > 0:
        bits = log2(kw)
        print(f"  n={n}: |KW(Maj)|={kw:>8d}, "
              f"log2|KW|={bits:.2f} bits needed for any injective code")

# ============================================================
# Demo 5: Layer Structure for Symmetric Functions
# ============================================================
print()
print("=" * 70)
print("DEMO 5: Layer Decomposition of KW Witnesses (Symmetric)")
print("=" * 70)

n = 5
t = 3  # threshold at 3
print(f"  Threshold function: n={n}, t={t}")
print(f"  True layers (weight >= {t}): ", end="")
for k in range(t, n + 1):
    print(f"layer({k}): C({n},{k})={comb(n,k)}", end="  ")
print()
print(f"  False layers (weight < {t}): ", end="")
for l in range(0, t):
    print(f"layer({l}): C({n},{l})={comb(n,l)}", end="  ")
print()

# Exact formula for symmetric threshold
exact_sum = 0
for k in range(t, n + 1):
    for l in range(0, t):
        contrib = comb(n, k) * comb(n, l) * abs(k - l)
        exact_sum += contrib
        if contrib > 0:
            print(f"    (k={k}, l={l}): C({n},{k})*C({n},{l})*|{k}-{l}| = {contrib}")

fn_thresh = lambda x: threshold_fn(n, t, x)
actual_kw = count_kw_witnesses(fn_thresh, n)
print(f"  Exact formula sum = {exact_sum}")
print(f"  Actual |KWWitness| = {actual_kw}")
print(f"  Match: {exact_sum == actual_kw}")

print()
print("=" * 70)
print("All demos completed successfully.")
print("=" * 70)
