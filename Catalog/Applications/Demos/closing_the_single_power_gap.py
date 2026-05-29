#!/usr/bin/env python3
"""
applications.py — Real-world applications of exchange descent complexity.

Demonstrates connections to:
1. Simplex method worst-case analysis
2. Local search algorithm design
3. Metastability detection in energy landscapes
4. Algorithm complexity certification
"""

from typing import List, Dict, Tuple
import math


# ─────────────────────────────────────────────────────────────────────
# Application 1: Simplex Method Analysis
# ─────────────────────────────────────────────────────────────────────

def simplex_pivot_family(n_vars: int, n_constraints: int):
    """Model a linear programming pivot sequence as an exchange family.
    
    Each state is a basic feasible solution (BFS), represented by a
    basis set. The measure is the objective value (discretized).
    Steps are simplex pivots that improve the objective.
    
    This is a simplified model — in practice, degeneracy and
    cycling prevention add complexity.
    """
    from itertools import combinations
    
    # States: all possible bases (subsets of size n_vars from n_constraints)
    total = n_vars + n_constraints
    bases = list(combinations(range(total), n_vars))
    
    # Assign measures based on lexicographic order (proxy for objective)
    sorted_bases = sorted(bases)
    measure = {b: i for i, b in enumerate(sorted_bases)}
    
    # Simplex pivots: swap one element in the basis
    def step_fn(b1, b2):
        s1, s2 = set(b1), set(b2)
        # Exactly one element swapped
        if len(s1 - s2) != 1 or len(s2 - s1) != 1:
            return False
        return measure[b2] < measure[b1]
    
    class SimplexFamily:
        def __init__(self):
            self.states = bases
            self.measure = measure
            self.step_fn = step_fn
            self.name = f"Simplex(vars={n_vars}, constr={n_constraints})"
            self._cache = {}
        
        def successors(self, x):
            return [y for y in self.states if self.step_fn(x, y)]
        
        def max_descent_from(self, x):
            if x in self._cache:
                return self._cache[x]
            succs = self.successors(x)
            result = 0 if not succs else 1 + max(
                self.max_descent_from(y) for y in succs)
            self._cache[x] = result
            return result
        
        def worst_descent_length(self):
            return max(self.max_descent_from(x) for x in self.states)
    
    return SimplexFamily()


# ─────────────────────────────────────────────────────────────────────
# Application 2: Local Search Complexity Bounds
# ─────────────────────────────────────────────────────────────────────

def local_search_bound(d: int, k: int) -> Dict:
    """Compute theoretical bounds on local search complexity.
    
    For a d-dimensional optimization problem with certificate depth k:
    - Upper bound: d^(d-k) (from certificate analysis)
    - Lower bound: d (from linear family)
    
    The gap between these bounds is the single-power gap.
    """
    upper = d ** max(0, d - k)
    lower = d  # From linear family construction
    
    # Practical estimate: geometric mean as heuristic
    if upper > 0 and lower > 0:
        practical_estimate = int(math.sqrt(upper * lower))
    else:
        practical_estimate = lower
    
    return {
        'dimension': d,
        'cert_depth': k,
        'upper_bound': upper,
        'lower_bound': lower,
        'gap_ratio': upper / lower if lower > 0 else float('inf'),
        'practical_estimate': practical_estimate,
    }


# ─────────────────────────────────────────────────────────────────────
# Application 3: Metastability Detection
# ─────────────────────────────────────────────────────────────────────

def detect_metastable_states(states: list, energy: dict,
                              transitions: dict,
                              threshold: float = 0.5) -> List:
    """Detect metastable states in an energy landscape.
    
    A state is metastable if its maximum descent chain length is
    significantly longer than its energy would suggest.
    
    Parameters:
        states: list of states
        energy: dict mapping state -> energy (natural number)
        transitions: dict mapping state -> list of lower-energy neighbors
        threshold: ratio threshold for metastability detection
    
    Returns:
        List of (state, descent_length, energy, ratio) for metastable states
    """
    cache = {}
    
    def max_descent(x):
        if x in cache:
            return cache[x]
        nbrs = transitions.get(x, [])
        result = 0 if not nbrs else 1 + max(max_descent(y) for y in nbrs)
        cache[x] = result
        return result
    
    metastable = []
    for x in states:
        dl = max_descent(x)
        e = energy[x]
        ratio = dl / e if e > 0 else 0
        if ratio > threshold:
            metastable.append({
                'state': x,
                'descent_length': dl,
                'energy': e,
                'ratio': ratio,
                'is_metastable': ratio > 1.0,
            })
    
    return sorted(metastable, key=lambda m: -m['ratio'])


# ─────────────────────────────────────────────────────────────────────
# Application 4: Algorithm Complexity Certification
# ─────────────────────────────────────────────────────────────────────

def certify_algorithm_complexity(d: int, measured_steps: List[int],
                                  k: int = 0) -> Dict:
    """Certify that an algorithm's observed complexity matches theory.
    
    Given observed step counts for different problem instances,
    determines whether the algorithm's complexity is consistent
    with the theoretical bounds for depth-k exchange families.
    
    Parameters:
        d: problem dimension
        measured_steps: list of observed step counts
        k: certificate depth of the algorithm
    
    Returns:
        Dict with certification results
    """
    upper_bound = d ** max(0, d - k)
    lower_bound = d
    
    max_observed = max(measured_steps) if measured_steps else 0
    avg_observed = sum(measured_steps) / len(measured_steps) if measured_steps else 0
    
    # Check if observations are consistent with bounds
    within_upper = all(s <= upper_bound for s in measured_steps)
    exceeds_lower = max_observed >= lower_bound
    
    # Estimate the effective exponent
    if d > 1 and max_observed > 0:
        effective_exponent = math.log(max_observed) / math.log(d)
    else:
        effective_exponent = 0
    
    return {
        'dimension': d,
        'cert_depth': k,
        'theoretical_upper': upper_bound,
        'theoretical_lower': lower_bound,
        'max_observed': max_observed,
        'avg_observed': avg_observed,
        'within_bounds': within_upper,
        'effective_exponent': effective_exponent,
        'predicted_exponent': d - k,
        'certification': 'PASS' if within_upper else 'FAIL',
    }


# ─────────────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Exchange Descent Complexity — Applications")
    print("=" * 60)
    
    # App 1: Simplex analysis (small instance)
    print("\n1. Simplex Method Analysis (small instance):")
    sf = simplex_pivot_family(2, 3)
    print(f"   {sf.name}")
    print(f"   States: {len(sf.states)}")
    print(f"   Worst-case pivots: {sf.worst_descent_length()}")
    
    # App 2: Local search bounds
    print("\n2. Local Search Complexity Bounds:")
    print(f"   {'d':>4} {'k':>4} {'Lower':>8} {'Upper':>14} {'Gap':>10}")
    print("   " + "-" * 45)
    for d in [5, 8, 10, 15]:
        for k in [0, 1, 2]:
            result = local_search_bound(d, k)
            print(f"   {d:>4} {k:>4} {result['lower_bound']:>8} "
                  f"{result['upper_bound']:>14} "
                  f"{result['gap_ratio']:>10.1f}")
    
    # App 3: Metastability detection
    print("\n3. Metastability Detection:")
    states = list(range(10))
    energy = {i: i for i in states}
    # Create a landscape with a metastable trap
    transitions = {
        9: [8, 7, 5],  # Many exits
        8: [7, 6],
        7: [6, 3],
        6: [5, 4],
        5: [4, 2],
        4: [3, 1],
        3: [2, 0],
        2: [1, 0],
        1: [0],
        0: [],
    }
    metastable = detect_metastable_states(states, energy, transitions)
    for m in metastable[:5]:
        print(f"   State {m['state']}: descent={m['descent_length']}, "
              f"energy={m['energy']}, ratio={m['ratio']:.2f}")
    
    # App 4: Complexity certification
    print("\n4. Algorithm Complexity Certification:")
    import random
    random.seed(42)
    for d in [5, 8, 10]:
        steps = [random.randint(1, d * 2) for _ in range(20)]
        cert = certify_algorithm_complexity(d, steps, k=1)
        print(f"   d={d}: max_obs={cert['max_observed']}, "
              f"upper={cert['theoretical_upper']}, "
              f"eff_exp={cert['effective_exponent']:.2f}, "
              f"pred_exp={cert['predicted_exponent']}, "
              f"cert={cert['certification']}")
    
    print("\nAll applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Exchange Descent Complexity: Single-Power Gap Investigation

This script constructs sample adversarial exchange families, computes
worst-case descent lengths for dimensions d = 4..20, and plots normalized
ratios against d^(d-k) and d^(d-k-1) to visually test the single-power
gap conjecture.
"""

import math
from collections import defaultdict

# ─────────────────────────────────────────────────────────────────────
# Core data structures
# ─────────────────────────────────────────────────────────────────────

class ExchangeFamily:
    """An exchange family with finite state space, measure, and step relation."""
    
    def __init__(self, states, measure, step_fn, name=""):
        """
        states: list of states
        measure: dict state -> int (natural number)
        step_fn: function(x, y) -> bool (whether x can step to y)
        """
        self.states = list(states)
        self.measure = measure
        self.step_fn = step_fn
        self.name = name
        self._max_descent_cache = {}
    
    def successors(self, x):
        """Return all states reachable from x in one step."""
        return [y for y in self.states if self.step_fn(x, y)]
    
    def max_descent_length(self, x):
        """Compute the maximum descent chain length starting from x."""
        if x in self._max_descent_cache:
            return self._max_descent_cache[x]
        succs = self.successors(x)
        if not succs:
            result = 0
        else:
            result = 1 + max(self.max_descent_length(y) for y in succs)
        self._max_descent_cache[x] = result
        return result
    
    def worst_descent_length(self):
        """Compute the worst-case (maximum) descent length over all states."""
        if not self.states:
            return 0
        return max(self.max_descent_length(x) for x in self.states)
    
    def count_paths(self, x, length):
        """Count the number of descent chains of exactly `length` steps from x."""
        if length == 0:
            return 1
        return sum(self.count_paths(y, length - 1) for y in self.successors(x))
    
    def total_path_count(self, length):
        """Total descent chains of given length across all starting states."""
        return sum(self.count_paths(x, length) for x in self.states)


# ─────────────────────────────────────────────────────────────────────
# Family constructors
# ─────────────────────────────────────────────────────────────────────

def linear_family(d):
    """Linear exchange family: state i can step to any j < i."""
    states = list(range(d + 1))
    measure = {i: i for i in states}
    return ExchangeFamily(states, measure, lambda x, y: y < x,
                          name=f"Linear(d={d})")

def complete_dag_family(d):
    """Complete DAG family: state i can step to any j < i.
    Same as linear but emphasizes full connectivity."""
    return linear_family(d)

def binary_tree_family(depth):
    """Binary tree descent: each node has two children with lower measure."""
    n = 2**(depth + 1) - 1
    states = list(range(n))
    measure = {}
    for i in range(n):
        # Level in tree (root = depth, leaves = 0)
        level = depth
        node = i
        while node > 0:
            node = (node - 1) // 2
            level -= 1
        # Actually compute level differently
        level = 0
        node = i
        while node > 0:
            node = (node - 1) // 2
            level += 1
        measure[i] = depth - level  # leaves have measure 0
    
    def step_fn(x, y):
        # x can step to its children
        left = 2 * x + 1
        right = 2 * x + 2
        return y == left or y == right
    
    return ExchangeFamily(states, measure, step_fn,
                          name=f"BinaryTree(depth={depth})")

def layered_family(d, k):
    """Layered family with certificate depth approximately k.
    
    States are tuples (layer, position) where layer goes from d down to 0.
    Certificate depth k means each step depends on k coordinates.
    More layers with fewer positions = deeper certificates.
    
    This is a key adversarial construction: we create d layers,
    each with branching factor proportional to d/k.
    """
    branch = max(2, d // max(1, k + 1))
    states = []
    for layer in range(d + 1):
        for pos in range(branch**min(layer, k + 1)):
            states.append((layer, pos))
    
    measure = {(l, p): l for (l, p) in states}
    
    def step_fn(x, y):
        lx, px = x
        ly, py = y
        if ly != lx - 1:
            return False
        # Can step to any position in the next layer
        return True
    
    return ExchangeFamily(states, measure, step_fn,
                          name=f"Layered(d={d}, k={k})")

def adversarial_family(d, k):
    """Adversarial exchange family designed to maximize descent length
    at certificate depth k.
    
    Construction: d layers, each step from layer i to layer i-1.
    At each layer, we have d^(min(i, k)) positions.
    Steps from (i, p) can go to any of d positions in layer i-1.
    """
    states = []
    positions_at = {}
    for layer in range(d + 1):
        n_pos = min(d ** min(layer, k + 1), 1000)  # cap for performance
        positions_at[layer] = n_pos
        for pos in range(n_pos):
            states.append((layer, pos))
    
    measure = {(l, p): l for (l, p) in states}
    
    def step_fn(x, y):
        lx, _ = x
        ly, _ = y
        return ly == lx - 1
    
    return ExchangeFamily(states, measure, step_fn,
                          name=f"Adversarial(d={d}, k={k})")


def product_family(F, G):
    """Product of two exchange families."""
    states = [(x, y) for x in F.states for y in G.states]
    measure = {(x, y): F.measure[x] + G.measure[y] for (x, y) in states}
    
    def step_fn(p, q):
        x1, y1 = p
        x2, y2 = q
        return (F.step_fn(x1, x2) and y1 == y2) or (x1 == x2 and G.step_fn(y1, y2))
    
    return ExchangeFamily(states, measure, step_fn,
                          name=f"Product({F.name}, {G.name})")


# ─────────────────────────────────────────────────────────────────────
# Computational experiments
# ─────────────────────────────────────────────────────────────────────

def experiment_linear_families():
    """Test worst-case descent for linear families."""
    print("=" * 70)
    print("Experiment 1: Linear Exchange Families")
    print("=" * 70)
    print(f"{'d':>4} {'WDL':>8} {'d^d':>12} {'d^(d-1)':>12} {'WDL/d^d':>10} {'WDL/d^(d-1)':>12}")
    print("-" * 70)
    
    for d in range(2, 16):
        F = linear_family(d)
        wdl = F.worst_descent_length()
        dd = d ** d if d > 0 else 1
        dd1 = d ** max(0, d - 1) if d > 0 else 1
        ratio_d = wdl / dd if dd > 0 else 0
        ratio_d1 = wdl / dd1 if dd1 > 0 else 0
        print(f"{d:>4} {wdl:>8} {dd:>12} {dd1:>12} {ratio_d:>10.6f} {ratio_d1:>12.6f}")
    print()

def experiment_product_amplification():
    """Verify product amplification: WDL(F×G) ≥ WDL(F) + WDL(G)."""
    print("=" * 70)
    print("Experiment 2: Product Chain Amplification")
    print("=" * 70)
    print(f"{'F':>15} {'G':>15} {'WDL(F)':>8} {'WDL(G)':>8} {'WDL(F×G)':>10} {'Sum':>6} {'≥Sum?':>6}")
    print("-" * 70)
    
    families = [linear_family(d) for d in range(2, 7)]
    
    for i in range(len(families)):
        for j in range(i, len(families)):
            F, G = families[i], families[j]
            wf = F.worst_descent_length()
            wg = G.worst_descent_length()
            PFG = product_family(F, G)
            wprod = PFG.worst_descent_length()
            check = "✓" if wprod >= wf + wg else "✗"
            print(f"{F.name:>15} {G.name:>15} {wf:>8} {wg:>8} {wprod:>10} {wf+wg:>6} {check:>6}")
    print()

def experiment_adversarial_scaling():
    """Test adversarial families for different depths k."""
    print("=" * 70)
    print("Experiment 3: Adversarial Families — Scaling Analysis")
    print("=" * 70)
    
    for k in range(3):
        print(f"\n--- Certificate depth k = {k} ---")
        print(f"{'d':>4} {'WDL':>8} {'d^(d-k)':>14} {'d^(d-k-1)':>14} {'WDL/d^(d-k)':>14} {'WDL/d^(d-k-1)':>14}")
        print("-" * 75)
        
        for d in range(max(k + 2, 4), 13):
            F = adversarial_family(d, k)
            wdl = F.worst_descent_length()
            exp1 = d ** max(0, d - k)
            exp2 = d ** max(0, d - k - 1)
            r1 = wdl / exp1 if exp1 > 0 else 0
            r2 = wdl / exp2 if exp2 > 0 else 0
            print(f"{d:>4} {wdl:>8} {exp1:>14} {exp2:>14} {r1:>14.8f} {r2:>14.8f}")
    print()

def experiment_path_counting():
    """Count descent paths and verify convolution bound for products."""
    print("=" * 70)
    print("Experiment 4: Descent Path Counting")
    print("=" * 70)
    
    F = linear_family(4)
    G = linear_family(3)
    PFG = product_family(F, G)
    
    print(f"\nF = {F.name}, G = {G.name}")
    print(f"WDL(F) = {F.worst_descent_length()}, WDL(G) = {G.worst_descent_length()}")
    print(f"WDL(F×G) = {PFG.worst_descent_length()}")
    
    print(f"\n{'Length':>8} {'Paths(F)':>10} {'Paths(G)':>10} {'Paths(F×G)':>12} {'Conv Bound':>12} {'≤Bound?':>8}")
    print("-" * 65)
    
    max_len = min(F.worst_descent_length() + G.worst_descent_length(), 7)
    for n in range(max_len + 1):
        pf = F.total_path_count(n)
        pg = G.total_path_count(n)
        pprod = PFG.total_path_count(n)
        
        # Convolution bound: sum over i of paths(F, i) * paths(G, n-i)
        conv = sum(F.total_path_count(i) * G.total_path_count(n - i)
                   for i in range(n + 1))
        
        check = "✓" if pprod <= conv else "✗"
        print(f"{n:>8} {pf:>10} {pg:>10} {pprod:>12} {conv:>12} {check:>8}")
    print()

def experiment_amplification_profile():
    """Compute certificate amplification profiles."""
    print("=" * 70)
    print("Experiment 5: Certificate Amplification Profiles")
    print("=" * 70)
    
    print(f"\n{'d':>4}", end="")
    for k in range(5):
        print(f"  {'k='+str(k):>8}", end="")
    print(f"  {'WDL':>8}")
    print("-" * 60)
    
    for d in range(3, 11):
        print(f"{d:>4}", end="")
        wdl = linear_family(d).worst_descent_length()
        for k in range(5):
            # For the linear family, certificate depth is always 1
            # (step depends on a single coordinate comparison)
            # The amplification profile at depth k is the WDL when k ≥ 1
            if k >= 1:
                profile_val = wdl
            else:
                # At depth 0, no certificates → profile = 0
                profile_val = 0
            print(f"  {profile_val:>8}", end="")
        print(f"  {wdl:>8}")
    print()

def experiment_iterated_product():
    """Demonstrate iterated product amplification."""
    print("=" * 70)
    print("Experiment 6: Iterated Product Amplification")
    print("=" * 70)
    
    base = linear_family(3)
    base_wdl = base.worst_descent_length()
    print(f"Base family: {base.name}, WDL = {base_wdl}")
    print(f"\n{'k copies':>10} {'Predicted':>10} {'Theory (k*WDL)':>15}")
    print("-" * 40)
    
    for k in range(1, 6):
        predicted = k * base_wdl
        print(f"{k:>10} {predicted:>10} {predicted:>15}")
    
    # Actually compute for small k
    print("\nDirect computation (small k):")
    current = base
    for k in range(1, 4):
        if k > 1:
            current = product_family(base, current)
        actual_wdl = current.worst_descent_length()
        theory_wdl = k * base_wdl
        print(f"  k={k}: actual WDL = {actual_wdl}, theory lower bound = {theory_wdl}, "
              f"matches = {'✓' if actual_wdl >= theory_wdl else '✗'}")
    print()


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Exchange Descent Complexity: Single-Power Gap Investigation       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    experiment_linear_families()
    experiment_product_amplification()
    experiment_adversarial_scaling()
    experiment_path_counting()
    experiment_amplification_profile()
    experiment_iterated_product()
    
    print("=" * 70)
    print("Summary")
    print("=" * 70)
    print("""
Key observations:
1. Linear families achieve WDL = d (trivially, since steps can go to any lower state).
2. Product amplification holds: WDL(F×G) ≥ WDL(F) + WDL(G).
3. Adversarial families with certificate depth k show WDL = d (the measure bound).
4. Path counts satisfy the convolution bound under products.
5. Iterated products amplify descent length linearly: k copies → k × WDL.

The single-power gap question asks whether there exist families where
the descent length grows as d^(d-k) rather than just polynomially in d.
Our experiments show that simple constructions achieve WDL = d (linear in d),
while the conjectured sharp bound would require WDL ~ d^(d-k) (superexponential).

This gap between the achievable (linear) and the conjectured bound
(superexponential) suggests that truly adversarial constructions require
much more sophisticated structure than naive layered families.
""")


#!/usr/bin/env python3
"""
Visualization: Certificate Amplification Profile

Visualizes the certificate amplification profile — the novel invariant
introduced in this work — showing how worst-case descent length depends
on certificate depth budget across different family dimensions.

Two panels:
1. Heatmap of amplification profile values across (d, k) pairs
2. Path count distribution showing partition function structure
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

# ─── Inline data computation ───

# Panel 1: Amplification profile heatmap
# For the linear family, the profile is: 0 at k=0, WDL=d for k≥1
# For adversarial constructions, the profile reveals more structure

d_range = list(range(3, 16))
k_range = list(range(0, 8))

# Create heatmap data: profile[d][k]
profile_data = []
for d in d_range:
    row = []
    for k in k_range:
        if k == 0:
            # No certificates: worst case is just the measure bound = d
            val = 0
        elif k <= d:
            # With k-dimensional certificates: WDL depends on family structure
            # For linear family: WDL = d regardless of k ≥ 1
            # Normalize by d^(d-k) to see the exponent gap
            val = d  # actual WDL
        else:
            val = d
        row.append(val)
    profile_data.append(row)

# Panel 2: Path count distribution for a specific family
class SimpleExchangeFamily:
    def __init__(self, d):
        self.d = d
        self.states = list(range(d + 1))
        self._pcache = {}
    
    def count_paths(self, x, length):
        key = (x, length)
        if key in self._pcache:
            return self._pcache[key]
        if length == 0:
            result = 1
        elif x == 0:
            result = 0
        else:
            # Linear family: can step to any j < x
            result = sum(self.count_paths(j, length - 1) for j in range(x))
        self._pcache[key] = result
        return result
    
    def total_paths(self, length):
        return sum(self.count_paths(x, length) for x in self.states)

# Compute path counts for different d values
path_data = {}
for d in [4, 6, 8, 10]:
    F = SimpleExchangeFamily(d)
    lengths = list(range(d + 1))
    counts = [F.total_paths(n) for n in lengths]
    path_data[d] = (lengths, counts)

# ─── Plotting ───

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle('Certificate Amplification Profile & Path Structure',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Heatmap
ax = axes[0]
# Normalize: show profile / d to see relative structure
norm_data = [[profile_data[i][j] / d_range[i] if d_range[i] > 0 else 0
              for j in range(len(k_range))]
             for i in range(len(d_range))]

im = ax.imshow(norm_data, aspect='auto', cmap='YlOrRd',
               interpolation='nearest', origin='lower')
ax.set_xticks(range(len(k_range)))
ax.set_xticklabels([str(k) for k in k_range])
ax.set_yticks(range(len(d_range)))
ax.set_yticklabels([str(d) for d in d_range])
ax.set_xlabel('Certificate Depth k', fontsize=12)
ax.set_ylabel('Dimension d', fontsize=12)
ax.set_title('Amplification Profile (normalized by d)', fontsize=12)
cbar = plt.colorbar(im, ax=ax)
cbar.set_label('Profile / d', fontsize=10)

# Annotate the k=0 column
for i in range(len(d_range)):
    ax.text(0, i, '0', ha='center', va='center', fontsize=8, color='white',
            fontweight='bold')

# Panel 2: Path count distribution
ax = axes[1]
colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
for (d, color) in zip([4, 6, 8, 10], colors):
    lengths, counts = path_data[d]
    # Only plot nonzero
    nonzero = [(l, c) for l, c in zip(lengths, counts) if c > 0]
    if nonzero:
        ls, cs = zip(*nonzero)
        ax.semilogy(ls, cs, 'o-', color=color, linewidth=2, markersize=5,
                    label=f'd={d}')

ax.set_xlabel('Chain Length n', fontsize=12)
ax.set_ylabel('Number of Descent Chains (log scale)', fontsize=12)
ax.set_title('Path Count Distribution (Linear Family)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_amplification.png', dpi=150, bbox_inches='tight')
print("Saved viz_amplification.png")


#!/usr/bin/env python3
"""
Visualization: Product Family Structure and Iterated Amplification

Shows:
1. How descent length grows under iterated products (linear amplification)
2. The gap between achieved WDL and conjectured bounds d^(d-k)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

# ─── Data computation ───

# Panel 1: Iterated product amplification
# For linear family with base WDL = L, k copies give WDL = k * L
base_wdls = [3, 4, 5]
k_range = list(range(1, 11))

amplified = {}
for L in base_wdls:
    amplified[L] = [k * L for k in k_range]

# Panel 2: Gap analysis
# Compare achieved WDL with theoretical bounds
d_range = list(range(3, 18))
gap_data = {}
for k in [0, 1, 2]:
    gap_data[k] = {
        'd': d_range,
        'achieved': [d for d in d_range],  # Linear family: WDL = d
        'upper': [d ** max(0, d - k) for d in d_range],
        'lower_conj': [d ** max(0, d - k - 1) for d in d_range],
    }

# ─── Plotting ───

fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle('Product Amplification & Single-Power Gap Analysis',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Iterated product
ax = axes[0]
colors = ['#e41a1c', '#377eb8', '#4daf4a']
markers = ['o', 's', '^']
for L, color, marker in zip(base_wdls, colors, markers):
    ax.plot(k_range, amplified[L], f'{marker}-', color=color,
            linewidth=2, markersize=6,
            label=f'Base WDL = {L}')
    # Add theory line
    ax.plot(k_range, [k * L for k in k_range], '--', color=color,
            alpha=0.5, linewidth=1)

ax.set_xlabel('Number of Product Copies k', fontsize=12)
ax.set_ylabel('Worst-Case Descent Length', fontsize=12)
ax.set_title('Iterated Product Amplification\n(WDL = k × base)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Gap analysis
ax = axes[1]
k_colors = {0: '#e41a1c', 1: '#377eb8', 2: '#4daf4a'}
for k in [0, 1, 2]:
    data = gap_data[k]
    # Plot log ratio: log(achieved) / log(upper)
    ratios = []
    for d, ach, up in zip(data['d'], data['achieved'], data['upper']):
        if d > 1 and ach > 0 and up > 0:
            # Effective exponent: log(WDL) / log(d)
            eff_exp = math.log(ach) / math.log(d)
            ratios.append(eff_exp)
        else:
            ratios.append(0)
    
    ax.plot(data['d'][:len(ratios)], ratios, 'o-',
            color=k_colors[k], linewidth=2, markersize=5,
            label=f'Effective exponent (k={k})')
    
    # Theoretical exponent d-k
    theory = [d - k for d in data['d']]
    ax.plot(data['d'], theory, '--', color=k_colors[k], alpha=0.4,
            linewidth=1.5)

ax.set_xlabel('Dimension d', fontsize=12)
ax.set_ylabel('Effective Exponent (log WDL / log d)', fontsize=12)
ax.set_title('Gap Analysis: Effective vs Conjectured Exponent\n'
             '(dashed = d−k conjecture)', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(bottom=0)

plt.tight_layout()
plt.savefig('viz_product_structure.png', dpi=150, bbox_inches='tight')
print("Saved viz_product_structure.png")


#!/usr/bin/env python3
"""
Visualization: Descent Complexity Scaling Analysis

Visualizes how worst-case descent length (WDL) compares to the theoretical
bounds d^(d-k) and d^(d-k-1) for different exchange family constructions.

Three panels:
1. WDL vs d for linear families (log scale)
2. Normalized ratios WDL/d^(d-k) for different k values
3. Product amplification: WDL(F×G) vs WDL(F) + WDL(G)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import math

# ─── Inline: Exchange family classes ───

class ExchangeFamily:
    def __init__(self, states, measure, step_fn, name=""):
        self.states = list(states)
        self.measure = measure
        self.step_fn = step_fn
        self.name = name
        self._cache = {}
    
    def successors(self, x):
        return [y for y in self.states if self.step_fn(x, y)]
    
    def max_descent_from(self, x):
        if x in self._cache:
            return self._cache[x]
        succs = self.successors(x)
        result = 0 if not succs else 1 + max(self.max_descent_from(y) for y in succs)
        self._cache[x] = result
        return result
    
    def worst_descent_length(self):
        return max(self.max_descent_from(x) for x in self.states) if self.states else 0

def linear_family(d):
    states = list(range(d + 1))
    return ExchangeFamily(states, {i: i for i in states},
                          lambda x, y: y < x, f"Linear(d={d})")

def chain_family(d):
    states = list(range(d + 1))
    return ExchangeFamily(states, {i: i for i in states},
                          lambda x, y: y == x - 1, f"Chain(d={d})")

def product_family(F, G):
    states = [(x, y) for x in F.states for y in G.states]
    measure = {(x, y): F.measure[x] + G.measure[y] for (x, y) in states}
    def step_fn(p, q):
        return (F.step_fn(p[0], q[0]) and p[1] == q[1]) or \
               (p[0] == q[0] and G.step_fn(p[1], q[1]))
    return ExchangeFamily(states, measure, step_fn, f"({F.name}×{G.name})")

# ─── Data collection ───

ds = list(range(2, 16))

# Panel 1: WDL comparison
wdl_linear = [linear_family(d).worst_descent_length() for d in ds]
wdl_chain = [chain_family(d).worst_descent_length() for d in ds]
d_pow_d = [d ** d for d in ds]
d_pow_d1 = [d ** max(0, d - 1) for d in ds]

# Panel 2: Normalized ratios for k = 0, 1, 2
ratios = {}
for k in [0, 1, 2]:
    ratios[k] = []
    for d in ds:
        wdl = d  # Linear family WDL = d
        denom = d ** max(0, d - k)
        ratios[k].append(wdl / denom if denom > 0 else 0)

# Panel 3: Product amplification
prod_data = []
for d1 in range(2, 7):
    for d2 in range(d1, 7):
        F = linear_family(d1)
        G = linear_family(d2)
        P = product_family(F, G)
        wf = F.worst_descent_length()
        wg = G.worst_descent_length()
        wp = P.worst_descent_length()
        prod_data.append((wf + wg, wp))

# ─── Plotting ───

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Exchange Descent Complexity: Scaling Analysis',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1
ax = axes[0]
ax.semilogy(ds, d_pow_d, 'r--', linewidth=2, label='$d^d$ (upper bound, k=0)')
ax.semilogy(ds, d_pow_d1, 'b--', linewidth=2, label='$d^{d-1}$ (lower bound?)')
ax.semilogy(ds, wdl_linear, 'ko-', linewidth=2, markersize=6,
            label='WDL (linear family)')
ax.semilogy(ds, wdl_chain, 'g^-', linewidth=1.5, markersize=5,
            label='WDL (chain family)')
ax.set_xlabel('Dimension d', fontsize=12)
ax.set_ylabel('Descent Length (log scale)', fontsize=12)
ax.set_title('Worst-Case Descent vs Bounds', fontsize=12)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel 2
ax = axes[1]
colors = ['#e41a1c', '#377eb8', '#4daf4a']
for k, color in zip([0, 1, 2], colors):
    ax.plot(ds, ratios[k], 'o-', color=color, linewidth=2,
            markersize=5, label=f'WDL / $d^{{d-{k}}}$  (k={k})')
ax.set_xlabel('Dimension d', fontsize=12)
ax.set_ylabel('Normalized Ratio', fontsize=12)
ax.set_title('Normalized Descent (→ 0 = gap exists)', fontsize=12)
ax.set_yscale('log')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 3
ax = axes[2]
sums = [p[0] for p in prod_data]
prods = [p[1] for p in prod_data]
max_val = max(max(sums), max(prods))
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='Equality line')
ax.scatter(sums, prods, c='#e41a1c', s=60, zorder=5,
           label='(WDL(F)+WDL(G), WDL(F×G))')
ax.set_xlabel('WDL(F) + WDL(G)', fontsize=12)
ax.set_ylabel('WDL(F × G)', fontsize=12)
ax.set_title('Product Amplification Theorem', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('viz_scaling.png', dpi=150, bbox_inches='tight')
print("Saved viz_scaling.png")
