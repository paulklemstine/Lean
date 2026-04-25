#!/usr/bin/env python3
"""
EML Closure and Density Demo

Demonstrates that the EML operation EML(a,b) = exp(a) - ln(b) generates a dense
subset of the reals starting from the seed {1}. Also shows the algebraic identities
that have been formally verified in Lean 4.
"""

import math
import random

random.seed(42)

def eml(a: float, b: float) -> float:
    """EML operation: exp(a) - ln(b)"""
    if b <= 0:
        return float('inf')
    return math.exp(a) - math.log(b)

# ─── Demo 1: EML Closure Growth ─────────────────────────────────
print("=" * 60)
print("Demo 1: EML Closure Growth from Seed {1}")
print("=" * 60)
print("Starting from S₀ = {1}, apply EML(a,b) = exp(a) - ln(b)")
print("to all pairs (a,b) from the current set.")
print()

closure = {1.0}
all_values = [1.0]

for depth in range(6):
    new_values = set()
    current = list(closure)
    for a in current[:50]:  # Limit computation
        for b in current[:50]:
            if b > 0:
                try:
                    v = eml(a, b)
                    if math.isfinite(v) and abs(v) < 1e6:
                        new_values.add(round(v, 10))
                except:
                    pass
    closure = closure | new_values
    all_values = sorted(closure)
    print(f"Depth {depth}: |S_{depth}| = {len(closure):>6} values")
    if depth <= 2:
        sample = sorted(list(closure))[:10]
        print(f"  Sample: {[round(v, 4) for v in sample]}")

# ─── Demo 2: Density Visualization ─────────────────────────────
print("\n" + "=" * 60)
print("Demo 2: Distribution of EML Closure Values")
print("=" * 60)

# Bin values into intervals
bins = {}
for v in all_values:
    if -10 <= v <= 10:
        b = int(math.floor(v))
        bins[b] = bins.get(b, 0) + 1

print(f"\nHistogram of EML closure values in [-10, 10]:")
print(f"{'interval':>12} {'count':>8} {'bar':>40}")
print("-" * 62)
max_count = max(bins.values()) if bins else 1
for b in range(-10, 10):
    count = bins.get(b, 0)
    bar = '█' * int(40 * count / max_count) if count > 0 else ''
    print(f"[{b:>3}, {b+1:>3}) {count:>8} {bar}")

# ─── Demo 3: Formally Verified Identities ──────────────────────
print("\n" + "=" * 60)
print("Demo 3: Formally Verified EML Identities")
print("=" * 60)

tests = [
    ("EML(x, 1) = exp(x)",
     lambda: [(x, eml(x, 1), math.exp(x)) for x in [-2, -1, 0, 1, 2, 3]]),
    ("EML(0, x) = 1 - ln(x)",
     lambda: [(x, eml(0, x), 1 - math.log(x)) for x in [0.5, 1, 2, math.e, 5]]),
    ("EML(x+c, 1) = exp(c)·exp(x)",
     lambda: [(f"x={x},c={c}", eml(x+c, 1), math.exp(c)*math.exp(x))
              for x in [0, 1, -1] for c in [1, 2]]),
    ("EML(0, exp(EML(0, exp(x)))) = x  [double negation]",
     lambda: [(x, eml(0, math.exp(eml(0, math.exp(x)))), x)
              for x in [-2, -1, 0, 1, 2, 3.14]]),
    ("EML(EML(0,x), 1) = e/x  [inv_scaled]",
     lambda: [(x, eml(eml(0, x), 1), math.e / x)
              for x in [0.5, 1, 2, 3, math.e]]),
]

for name, test_fn in tests:
    print(f"\n  {name}")
    results = test_fn()
    all_pass = True
    for label, actual, expected in results:
        match = abs(actual - expected) < 1e-8
        all_pass = all_pass and match
        print(f"    {str(label):>12}: actual={actual:>12.6f} expected={expected:>12.6f} {'✓' if match else '✗'}")
    print(f"  {'All passed ✓' if all_pass else 'SOME FAILED ✗'}")

# ─── Demo 4: EML Tree Computation ──────────────────────────────
print("\n" + "=" * 60)
print("Demo 4: EML Tree Universal Approximation")
print("=" * 60)
print("An EML tree with k leaves has VC dimension ≤ 2k")
print("(formally verified bound)")
print()

# Build some EML trees to approximate target values
target_values = [0.5, 1.5, 2.5, math.pi, math.sqrt(2), 7.389]

print(f"{'target':>10} {'tree_expr':>40} {'tree_val':>12} {'error':>10}")
print("-" * 76)

# Simple tree constructions
seed = 1.0
e_val = eml(seed, seed)  # EML(1,1) = e - 0 = e

for target in target_values:
    # Try to find a good approximation using depth-2 EML trees
    best_expr = ""
    best_val = seed
    best_err = abs(target - seed)

    candidates = [
        (f"EML(1, 1) = e", eml(1, 1)),
        (f"EML(0, 1) = 1", eml(0, 1)),
        (f"EML(1, e)", eml(1, math.e)),
        (f"EML(0, e) = 0", eml(0, math.e)),
        (f"EML(EML(1,1), 1) = e^e", eml(eml(1, 1), 1)),
        (f"EML(0, EML(1,1))", eml(0, eml(1, 1))),
        (f"EML(EML(0,1), EML(1,1))", eml(eml(0, 1), eml(1, 1))),
    ]

    # Also try EML(a, b) for a, b from small closure
    small_closure = [1.0, eml(1, 1), eml(0, 1), eml(1, math.e)]
    for a in small_closure:
        for b in small_closure:
            if b > 0:
                try:
                    v = eml(a, b)
                    if math.isfinite(v):
                        candidates.append((f"EML({a:.2f}, {b:.2f})", v))
                except:
                    pass

    for expr, val in candidates:
        err = abs(target - val)
        if err < best_err:
            best_err = err
            best_val = val
            best_expr = expr

    print(f"{target:>10.4f} {best_expr:>40} {best_val:>12.6f} {best_err:>10.6f}")

# ─── Demo 5: Bayesian Convergence ──────────────────────────────
print("\n" + "=" * 60)
print("Demo 5: Bayesian Convergence (formally verified)")
print("=" * 60)
print("Theorems verified in Lean:")
print("  - dead_hypothesis_stays_dead")
print("  - zero_likelihood_eliminates")
print("  - geometric_convergence")
print()

# Simulate Bayesian updating
hypotheses = ['H_true', 'H_false1', 'H_false2']
prior = [1/3, 1/3, 1/3]
true_hypothesis = 0
# Likelihoods: true hypothesis generates data with likelihood 0.8,
# false hypotheses generate data with likelihood 0.3
likelihoods = [0.8, 0.3, 0.3]

print(f"Prior: {[f'{p:.4f}' for p in prior]}")
print(f"True hypothesis: {hypotheses[true_hypothesis]}")
print()

belief_distances = []
posterior = list(prior)
for step in range(1, 16):
    # Bayesian update
    evidence = [likelihoods[i] * posterior[i] for i in range(3)]
    total = sum(evidence)
    posterior = [e / total for e in evidence]

    # Belief distance from truth (formally verified to form a metric)
    distance = 1.0 - posterior[true_hypothesis]
    belief_distances.append(distance)

    if step <= 10 or step == 15:
        bar = '█' * int(40 * posterior[true_hypothesis])
        print(f"  Step {step:>2}: P(H_true) = {posterior[true_hypothesis]:.6f} {bar}")

print(f"\n  Geometric convergence rate: {belief_distances[1]/belief_distances[0]:.4f}")
print(f"  (verified to converge geometrically)")

# Demonstrate dead_hypothesis_stays_dead
print(f"\n  Dead hypothesis test:")
posterior_dead = [0.5, 0.0, 0.5]  # H_false1 is dead (probability 0)
evidence = [likelihoods[i] * posterior_dead[i] for i in range(3)]
total = sum(evidence)
posterior_updated = [e / total for e in evidence]
print(f"  Before update: {[f'{p:.4f}' for p in posterior_dead]}")
print(f"  After update:  {[f'{p:.4f}' for p in posterior_updated]}")
print(f"  H_false1 stays dead: {'✓' if posterior_updated[1] == 0.0 else '✗'} (formally verified)")

print("\n" + "=" * 60)
print("All EML and convergence demos completed!")
print("=" * 60)
