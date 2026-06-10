#!/usr/bin/env python3
"""
Version Space Entropy — Applications

Demonstrates real-world applications of the version-space entropy theory:
  1. Active learning with entropy-guided queries
  2. Sample complexity estimation for concept classes
  3. Teaching dimension analysis
  4. Concept class comparison via compression rates
"""

import math
import itertools
import random
from typing import List, Tuple, Set, Dict


# ───────────────────────────────────────────────────────────────────
# Core utilities (self-contained)
# ───────────────────────────────────────────────────────────────────

def version_space(H: Set[tuple], D: List[Tuple[int, int]]) -> Set[tuple]:
    return {h for h in H if all(h[x] == y for x, y in D)}

def entropy(V: Set[tuple]) -> float:
    return math.log2(len(V)) if len(V) > 0 else 0.0

def restrict(V: Set[tuple], x: int, y: int) -> Set[tuple]:
    return {h for h in V if h[x] == y}

def threshold_functions(n: int) -> Set[tuple]:
    return {tuple(1 if x >= t else 0 for x in range(n)) for t in range(n + 1)}

def all_functions(d: int, l: int) -> Set[tuple]:
    return set(itertools.product(range(l), repeat=d))

def conjunction_functions(n: int) -> Set[tuple]:
    domain_size = 2 ** n
    H = set()
    for mask in range(2 ** n):
        h = tuple(1 if (x & mask) == mask else 0 for x in range(domain_size))
        H.add(h)
    return H


# ───────────────────────────────────────────────────────────────────
# Application 1: Active Learning with Entropy-Guided Queries
# ───────────────────────────────────────────────────────────────────

def active_learning_demo():
    """Compare random vs entropy-guided query strategies."""
    print("=" * 70)
    print("APPLICATION 1: Active Learning — Random vs Entropy-Guided")
    print("=" * 70)
    print()

    random.seed(42)
    n = 6
    H = threshold_functions(n)
    target = tuple(1 if x >= 3 else 0 for x in range(n))

    print(f"Task: Identify threshold on {{0,...,{n-1}}}")
    print(f"|H| = {len(H)}, target threshold = 3")
    print()

    # Random querying
    V_random = H.copy()
    random_order = list(range(n))
    random.shuffle(random_order)
    random_steps = 0
    for x in random_order:
        V_random = restrict(V_random, x, target[x])
        random_steps += 1
        if len(V_random) == 1:
            break

    # Entropy-guided (binary search)
    V_guided = H.copy()
    guided_steps = 0
    queried = set()
    while len(V_guided) > 1:
        best_x = None
        best_score = -1
        for x in range(n):
            if x in queried:
                continue
            sizes = []
            for y in [0, 1]:
                fiber = restrict(V_guided, x, y)
                if len(fiber) > 0:
                    sizes.append(len(fiber))
            if sizes:
                score = min(sizes)  # maximize minimum fiber
                if score > best_score:
                    best_score = score
                    best_x = x
        if best_x is None:
            break
        queried.add(best_x)
        V_guided = restrict(V_guided, best_x, target[best_x])
        guided_steps += 1

    print(f"Random querying: {random_steps} queries to identify target")
    print(f"Entropy-guided:  {guided_steps} queries to identify target")
    print(f"Information-theoretic minimum: ⌈log₂({len(H)})⌉ = {math.ceil(math.log2(len(H)))}")
    print()


# ───────────────────────────────────────────────────────────────────
# Application 2: Sample Complexity Estimation
# ───────────────────────────────────────────────────────────────────

def sample_complexity_demo():
    """Estimate sample complexity from entropy bounds."""
    print("=" * 70)
    print("APPLICATION 2: Sample Complexity Bounds from Entropy Theory")
    print("=" * 70)
    print()

    concept_classes = {
        "Thresholds(8)": (threshold_functions(8), 8, 2),
        "Conjunctions(3)": (conjunction_functions(3), 8, 2),
        "All binary(4)": (all_functions(4, 2), 4, 2),
        "Ternary(3)": (all_functions(3, 3), 3, 3),
    }

    print(f"{'Class':>20}  {'|H|':>6}  {'|Y|':>4}  {'Entropy':>8}  "
          f"{'Lower bound':>12}  {'Empirical':>10}")
    print("-" * 75)

    for name, (H, domain_size, label_size) in concept_classes.items():
        initial_entropy = entropy(H)
        log2_Y = math.log2(label_size)

        # Lower bound from entropy theory
        lower_bound = initial_entropy / log2_Y if log2_Y > 0 else float('inf')

        # Empirical: average over random targets
        random.seed(123)
        trials = min(50, len(H))
        H_list = list(H)
        total_steps = 0

        for trial in range(trials):
            target = H_list[trial % len(H_list)]
            V = H.copy()
            steps = 0
            instances = list(range(domain_size))
            random.shuffle(instances)

            for x in instances:
                if len(V) <= 1:
                    break
                V = restrict(V, x, target[x])
                steps += 1

            total_steps += steps

        avg_steps = total_steps / trials

        print(f"{name:>20}  {len(H):>6}  {label_size:>4}  {initial_entropy:>8.2f}  "
              f"{lower_bound:>12.2f}  {avg_steps:>10.2f}")

    print()
    print("→ Lower bound = initial_entropy / log₂|Y| (from the proven theorem)")
    print()


# ───────────────────────────────────────────────────────────────────
# Application 3: Teaching Dimension Analysis
# ───────────────────────────────────────────────────────────────────

def teaching_dimension_demo():
    """Compute teaching dimension and compare with entropy bounds."""
    print("=" * 70)
    print("APPLICATION 3: Teaching Dimension via Entropy Analysis")
    print("=" * 70)
    print()

    for n in range(3, 7):
        H = threshold_functions(n)

        # Teaching dimension: min examples to uniquely identify each hypothesis
        max_td = 0
        for target in H:
            best_size = n  # worst case
            # Try all subsets of examples
            domain = list(range(n))
            for k in range(1, n + 1):
                found = False
                for subset in itertools.combinations(domain, k):
                    D = [(x, target[x]) for x in subset]
                    V = version_space(H, D)
                    if len(V) == 1:
                        best_size = k
                        found = True
                        break
                if found:
                    break
            max_td = max(max_td, best_size)

        entropy_bound = math.ceil(entropy(H) / math.log2(2))

        print(f"  Thresholds(n={n}): |H|={len(H):>4}, "
              f"teaching dim = {max_td}, "
              f"entropy bound = {entropy_bound}, "
              f"log₂|H| = {entropy(H):.2f}")

    print()


# ───────────────────────────────────────────────────────────────────
# Application 4: Concept Class Comparison
# ───────────────────────────────────────────────────────────────────

def compression_rate_comparison():
    """Compare semantic compression rates across concept classes."""
    print("=" * 70)
    print("APPLICATION 4: Semantic Compression Rate Comparison")
    print("=" * 70)
    print()

    random.seed(42)

    classes = [
        ("Thresholds(6)", threshold_functions(6), 6, 2),
        ("Conjunctions(3)", conjunction_functions(3), 8, 2),
    ]

    for name, H, domain_size, label_size in classes:
        print(f"\n{name}: |H| = {len(H)}, |X| = {domain_size}, |Y| = {label_size}")

        # Compute average compression rate over random targets
        H_list = list(H)
        trials = min(20, len(H))

        all_rates = []
        for t in range(trials):
            target = H_list[t]
            V = H.copy()

            instances = list(range(domain_size))
            random.shuffle(instances)

            rates = []
            for x in instances:
                if len(V) <= 1:
                    break
                prev_entropy = entropy(V)
                V = restrict(V, x, target[x])
                curr_entropy = entropy(V)
                drop = prev_entropy - curr_entropy
                rates.append(drop)

            if rates:
                all_rates.append(sum(rates) / len(rates))

        avg_rate = sum(all_rates) / len(all_rates) if all_rates else 0
        log2_Y = math.log2(label_size)

        print(f"  Average compression rate: {avg_rate:.4f} bits/sample")
        print(f"  Theoretical maximum:      {log2_Y:.4f} bits/sample (log₂|Y|)")
        print(f"  Efficiency:               {avg_rate/log2_Y*100:.1f}%")

    print()


# ───────────────────────────────────────────────────────────────────
# Main
# ───────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   VERSION SPACE ENTROPY — Applications                         ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    active_learning_demo()
    sample_complexity_demo()
    teaching_dimension_demo()
    compression_rate_comparison()

    print("=" * 70)
    print("All applications complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Version Space Entropy — Interactive Demo

Demonstrates the formal theorems from VersionSpaceEntropy.lean with concrete
finite concept classes over Boolean domains. Shows:
  1. Version-space construction and entropy computation
  2. Entropy collapse under labeled observations
  3. The corrected per-sample entropy bound (existential, not universal)
  4. Counterexample search for the naive log₂|X| bound
  5. Coding-theoretic pattern bound verification
"""

import math
import itertools
from typing import List, Tuple, Dict, Set, Callable, Optional


# ───────────────────────────────────────────────────────────────────
# Core Definitions (matching the Lean formalization)
# ───────────────────────────────────────────────────────────────────

def version_space_entropy(V: Set[tuple]) -> float:
    """log₂(|V|) — semantic entropy of the version space under uniform posterior."""
    if len(V) == 0:
        return 0.0
    return math.log2(len(V))


def restrict_at(V: Set[tuple], x: int, y: int, domain_size: int) -> Set[tuple]:
    """Filter V to hypotheses h with h(x) = y."""
    return {h for h in V if h[x] == y}


def version_space(H: Set[tuple], D: List[Tuple[int, int]]) -> Set[tuple]:
    """Hypotheses in H consistent with all labeled examples in D."""
    return {h for h in H if all(h[x] == y for x, y in D)}


def query_pattern(xs: List[int], h: tuple) -> tuple:
    """Label sequence produced by hypothesis h on instances xs."""
    return tuple(h[x] for x in xs)


# ───────────────────────────────────────────────────────────────────
# Concept Class Generators
# ───────────────────────────────────────────────────────────────────

def all_functions(domain_size: int, label_size: int) -> Set[tuple]:
    """All functions from {0,...,domain_size-1} to {0,...,label_size-1}."""
    return set(itertools.product(range(label_size), repeat=domain_size))


def threshold_functions(n: int) -> Set[tuple]:
    """Threshold functions on {0,...,n-1}: h_t(x) = 1 if x >= t, for t in {0,...,n}.
    Returns binary-labeled hypotheses as tuples."""
    H = set()
    for t in range(n + 1):
        h = tuple(1 if x >= t else 0 for x in range(n))
        H.add(h)
    return H


def conjunction_functions(n: int) -> Set[tuple]:
    """Conjunction functions over n Boolean variables.
    Each subset S ⊆ {0,...,n-1} defines h_S(x) = ∧_{i∈S} x_i.
    Domain is {0,1}^n represented as indices 0..2^n-1."""
    domain_size = 2 ** n
    H = set()
    for mask in range(2 ** n):  # each subset S
        h = []
        for x in range(domain_size):
            # x is an n-bit vector; check if all bits in mask are set in x
            h.append(1 if (x & mask) == mask else 0)
        H.add(tuple(h))
    return H


# ───────────────────────────────────────────────────────────────────
# Demo 1: Version Space Entropy Collapse
# ───────────────────────────────────────────────────────────────────

def demo_entropy_collapse():
    """Stream labeled examples and watch version-space entropy decrease."""
    print("=" * 70)
    print("DEMO 1: Version Space Entropy Collapse")
    print("=" * 70)
    print()

    n = 4  # domain size
    H = all_functions(n, 2)  # all binary functions on 4 elements
    print(f"Domain size |X| = {n}")
    print(f"Label size |Y| = 2")
    print(f"Full hypothesis class |H| = {len(H)}")
    print(f"Initial entropy = {version_space_entropy(H):.4f} bits")
    print()

    # Target hypothesis
    target = (1, 0, 1, 0)
    print(f"Target hypothesis: {target}")
    print()

    # Stream examples
    V = H.copy()
    examples = [(0, 1), (1, 0), (2, 1), (3, 0)]

    print(f"{'Step':>4}  {'Example':>12}  {'|V|':>8}  {'Entropy':>10}  {'Drop':>8}  {'Bound':>8}")
    print("-" * 60)

    prev_entropy = version_space_entropy(V)
    print(f"{'init':>4}  {'':>12}  {len(V):>8}  {prev_entropy:>10.4f}  {'':>8}  {'':>8}")

    log2_Y = math.log2(2)
    for i, (x, y) in enumerate(examples):
        V = restrict_at(V, x, y, n)
        curr_entropy = version_space_entropy(V)
        drop = prev_entropy - curr_entropy
        print(f"{i+1:>4}  {f'h({x})={y}':>12}  {len(V):>8}  {curr_entropy:>10.4f}  {drop:>8.4f}  {log2_Y:>8.4f}")
        prev_entropy = curr_entropy

    print()
    print(f"Final version space: {V}")
    print()


# ───────────────────────────────────────────────────────────────────
# Demo 2: Corrected Per-Sample Bound (Existential)
# ───────────────────────────────────────────────────────────────────

def demo_corrected_bound():
    """Show that the universal bound fails but the existential bound holds."""
    print("=" * 70)
    print("DEMO 2: Corrected Per-Sample Entropy Bound")
    print("=" * 70)
    print()

    n = 3  # domain size
    label_size = 3
    H = all_functions(n, label_size)

    # Pick a version space that creates asymmetric fibers
    V = set(list(H)[:10])  # arbitrary 10 hypotheses
    x = 0  # query instance

    print(f"|V| = {len(V)}, |Y| = {label_size}, log₂|Y| = {math.log2(label_size):.4f}")
    print()

    # Compute fibers
    fibers = {}
    for y in range(label_size):
        fiber = restrict_at(V, x, y, n)
        fibers[y] = fiber

    print("Fiber decomposition at x=0:")
    max_fiber_y = None
    max_fiber_size = 0
    for y, fiber in fibers.items():
        size = len(fiber)
        if size > 0:
            drop = version_space_entropy(V) - version_space_entropy(fiber)
        else:
            drop = float('inf')
        exceeds = "⚠ EXCEEDS" if drop > math.log2(label_size) + 1e-10 else "✓ OK"
        print(f"  y={y}: |fiber| = {size:>3}, entropy drop = {drop:>8.4f}  {exceeds}")
        if size > max_fiber_size:
            max_fiber_size = size
            max_fiber_y = y

    print()
    if max_fiber_y is not None:
        best_drop = version_space_entropy(V) - version_space_entropy(fibers[max_fiber_y])
        print(f"Best label (largest fiber): y={max_fiber_y}, drop = {best_drop:.4f} ≤ log₂|Y| = {math.log2(label_size):.4f}")
        print(f"→ Existential bound HOLDS (as proven in Lean)")
    print()


# ───────────────────────────────────────────────────────────────────
# Demo 3: Counterexample Search for log₂|X| Bound
# ───────────────────────────────────────────────────────────────────

def demo_counterexample_search():
    """Search for cases where per-sample entropy drop exceeds log₂|X|
    but respects log₂|Y|."""
    print("=" * 70)
    print("DEMO 3: Counterexample Search — log₂|X| vs log₂|Y|")
    print("=" * 70)
    print()

    found_counterexample = False

    for domain_size in range(2, 5):
        for label_size in range(2, 6):
            if label_size <= domain_size:
                continue  # Only interesting when |Y| > |X|

            H = all_functions(domain_size, label_size)
            log2_X = math.log2(domain_size)
            log2_Y = math.log2(label_size)

            # Try various version spaces
            H_list = list(H)
            for vs_size in [max(5, label_size + 1), min(20, len(H))]:
                if vs_size > len(H):
                    continue
                V = set(H_list[:vs_size])

                for x in range(domain_size):
                    for y in range(label_size):
                        fiber = restrict_at(V, x, y, domain_size)
                        if len(fiber) == 0:
                            continue
                        drop = version_space_entropy(V) - version_space_entropy(fiber)

                        if drop > log2_X + 1e-10:
                            found_counterexample = True
                            exceeds_Y = drop > log2_Y + 1e-10
                            print(f"  |X|={domain_size}, |Y|={label_size}, |V|={len(V)}")
                            print(f"  x={x}, y={y}: drop={drop:.4f}")
                            print(f"  log₂|X| = {log2_X:.4f} — EXCEEDED ✗")
                            print(f"  log₂|Y| = {log2_Y:.4f} — {'EXCEEDED ✗' if exceeds_Y else 'respects ✓'}")
                            print()
                            if not exceeds_Y:
                                print("  → The log₂|Y| bound is correct; log₂|X| is wrong!")
                                print()
                                return  # One counterexample suffices

    if not found_counterexample:
        print("No counterexample found in search range.")
    print()


# ───────────────────────────────────────────────────────────────────
# Demo 4: Pattern Classes Bound
# ───────────────────────────────────────────────────────────────────

def demo_pattern_classes():
    """Verify the coding-theoretic bound: distinct patterns ≤ |Y|^k."""
    print("=" * 70)
    print("DEMO 4: Coding-Theoretic Pattern Bound")
    print("=" * 70)
    print()

    n = 5
    label_size = 2
    H = threshold_functions(n)

    print(f"Threshold functions on {{0,...,{n-1}}}, |H| = {len(H)}")
    print()

    for k in range(1, n + 1):
        # Use first k instances as query sequence
        xs = list(range(k))
        patterns = {query_pattern(xs, h) for h in H}
        bound = label_size ** k

        print(f"  k={k}: distinct patterns = {len(patterns):>4}, "
              f"|Y|^k = {bound:>4}, "
              f"ratio = {len(patterns)/bound:.4f}")

    print()
    print("→ Pattern count never exceeds |Y|^k (as proven in Lean)")
    print()


# ───────────────────────────────────────────────────────────────────
# Demo 5: Threshold Functions — Optimal Querying
# ───────────────────────────────────────────────────────────────────

def demo_threshold_optimal():
    """Show binary-search querying achieves exactly 1 bit per sample
    for threshold functions."""
    print("=" * 70)
    print("DEMO 5: Threshold Functions — Binary Search Optimality")
    print("=" * 70)
    print()

    n = 16
    H = threshold_functions(n)
    target_t = 7  # threshold at 7
    target = tuple(1 if x >= target_t else 0 for x in range(n))

    print(f"Domain size n = {n}")
    print(f"|H| = {len(H)} (thresholds 0..{n})")
    print(f"Target threshold: t = {target_t}")
    print()

    V = H.copy()
    step = 0

    print(f"{'Step':>4}  {'Query':>8}  {'Label':>6}  {'|V|':>6}  {'Entropy':>10}  {'Drop':>8}")
    print("-" * 55)

    prev_entropy = version_space_entropy(V)
    print(f"{'init':>4}  {'':>8}  {'':>6}  {len(V):>6}  {prev_entropy:>10.4f}")

    # Binary search
    lo, hi = 0, n
    while len(V) > 1 and lo < hi:
        mid = (lo + hi) // 2
        label = target[mid]
        V = restrict_at(V, mid, label, n)
        curr_entropy = version_space_entropy(V)
        drop = prev_entropy - curr_entropy
        step += 1
        print(f"{step:>4}  {f'x={mid}':>8}  {label:>6}  {len(V):>6}  {curr_entropy:>10.4f}  {drop:>8.4f}")
        prev_entropy = curr_entropy

        if label == 1:
            hi = mid
        else:
            lo = mid + 1

    print()
    print(f"Identified target in {step} queries (≈ log₂({n+1}) = {math.log2(n+1):.2f})")
    print(f"Average drop per query: {math.log2(n+1)/step:.4f} bits")
    print()


# ───────────────────────────────────────────────────────────────────
# Demo 6: Statistical Mechanics — Partition Function Collapse
# ───────────────────────────────────────────────────────────────────

def demo_stat_mech():
    """Visualize version-space cardinality as a partition function."""
    print("=" * 70)
    print("DEMO 6: Statistical Mechanics — Partition Function Z(D)")
    print("=" * 70)
    print()

    import random
    random.seed(42)

    n = 6
    H = all_functions(n, 2)
    target = tuple(random.choice([0, 1]) for _ in range(n))

    print(f"|X| = {n}, |Y| = 2, |H| = {len(H)}")
    print(f"Target: {target}")
    print()

    V = H.copy()
    examples = list(range(n))
    random.shuffle(examples)

    print(f"{'m':>3}  {'Z(D_m)':>10}  {'log₂Z':>10}  {'bar':>40}")
    print("-" * 65)

    max_bar = 40
    initial_entropy = version_space_entropy(V)

    for m in range(n + 1):
        z = len(V)
        entropy = version_space_entropy(V)
        bar_len = int(max_bar * entropy / initial_entropy) if initial_entropy > 0 else 0
        bar = "█" * bar_len
        print(f"{m:>3}  {z:>10}  {entropy:>10.4f}  {bar}")

        if m < n:
            x = examples[m]
            y = target[x]
            V = restrict_at(V, x, y, n)

    print()
    print("→ Z(D) decreases monotonically (partition_function_mono in Lean)")
    print()


# ───────────────────────────────────────────────────────────────────
# Main
# ───────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║   VERSION SPACE ENTROPY — Interactive Demonstration            ║")
    print("║   Bridging Learning Theory, Information Theory, and            ║")
    print("║   Statistical Mechanics                                        ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_entropy_collapse()
    demo_corrected_bound()
    demo_counterexample_search()
    demo_pattern_classes()
    demo_threshold_optimal()
    demo_stat_mech()

    print("=" * 70)
    print("All demos complete.")
    print("=" * 70)
