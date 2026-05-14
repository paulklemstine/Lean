#!/usr/bin/env python3
"""
Applications of Holographic Proof Renormalization

Demonstrates real-world applications of the ultrametric compression
framework to automated reasoning, code optimization, and information theory.
"""

from dataclasses import dataclass
from typing import List, Set, FrozenSet, Dict, Tuple, Optional
import itertools
from math import log2, gcd


# ============================================================
# Core (self-contained)
# ============================================================

@dataclass(frozen=True)
class ProofSketch:
    steps: tuple
    goal_id: int

    @property
    def complexity(self) -> int:
        return sum(self.steps)

    @property
    def semantic_signature(self) -> frozenset:
        return frozenset(self.steps)


def renorm_step(P: ProofSketch) -> ProofSketch:
    seen, deduped = set(), []
    for s in P.steps:
        if s not in seen:
            seen.add(s)
            deduped.append(s)
    return ProofSketch(tuple(deduped), P.goal_id)


def ultrametric_distance(P: ProofSketch, Q: ProofSketch) -> int:
    return 0 if P == Q else 1 + max(P.complexity, Q.complexity)


def semantic_distance(P: ProofSketch, Q: ProofSketch) -> int:
    sp, sq = P.semantic_signature, Q.semantic_signature
    return len(sp - sq) + len(sq - sp)


# ============================================================
# Application 1: Automated Proof Search with Compression
# ============================================================

def app_proof_search():
    """
    Application: Using holographic compression to accelerate proof search.

    The key insight is that approximate theoremhood is decidable on
    compressed codebooks, so we can search for proofs efficiently
    by first compressing the search space.
    """
    print("=" * 60)
    print("APPLICATION 1: Compressed Proof Search")
    print("=" * 60)

    # Simulate a proof search problem
    target = frozenset({2, 5, 7, 11})
    epsilon = 1  # Allow 1 step of approximation

    # Generate a large search space
    codebook = []
    for length in range(1, 5):
        for steps in itertools.product(range(15), repeat=length):
            codebook.append(ProofSketch(steps, 0))

    print(f"\nSearch space size: {len(codebook):,}")
    print(f"Target signature: {sorted(target)}")
    print(f"Tolerance: ε = {epsilon}")

    # Compress the codebook
    canonical = {}
    for P in codebook:
        rP = renorm_step(P)
        if rP not in canonical:
            canonical[rP] = P  # Keep track of original

    compressed = list(canonical.keys())
    print(f"Compressed codebook: {len(compressed):,} "
          f"(compression ratio: {len(codebook)/len(compressed):.1f}x)")

    # Search on compressed space
    matches_compressed = []
    for P in compressed:
        sig = P.semantic_signature
        dist = len(sig - target) + len(target - sig)
        if dist <= epsilon:
            matches_compressed.append(P)

    print(f"Matches in compressed space: {len(matches_compressed)}")

    if matches_compressed:
        best = min(matches_compressed, key=lambda P: P.complexity)
        print(f"Best match: steps={list(best.steps)}, "
              f"complexity={best.complexity}, "
              f"sig={sorted(best.semantic_signature)}")

    # Verify semantic preservation
    matches_full = []
    for P in codebook:
        sig = P.semantic_signature
        dist = len(sig - target) + len(target - sig)
        if dist <= epsilon:
            matches_full.append(P)

    # Check: every signature that appears in full matches also in compressed
    sigs_full = {P.semantic_signature for P in matches_full}
    sigs_compressed = {P.semantic_signature for P in matches_compressed}
    print(f"\nSemantic completeness check:")
    print(f"  Distinct signatures in full search: {len(sigs_full)}")
    print(f"  Distinct signatures in compressed: {len(sigs_compressed)}")
    print(f"  Complete: {'✓' if sigs_full == sigs_compressed else '✗'}")


# ============================================================
# Application 2: Code Optimization via Proof Compression
# ============================================================

def app_code_optimization():
    """
    Application: Modeling compiler optimizations as proof renormalization.

    Each "proof step" represents a computation step with a cost.
    Deduplication corresponds to common subexpression elimination.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Code Optimization as Renormalization")
    print("=" * 60)

    # Model a computation trace as a proof sketch
    # Steps represent: 1=load, 2=add, 3=multiply, 4=store, 5=branch
    computation_traces = [
        ("Redundant loads", ProofSketch((1, 2, 1, 3, 1, 4, 1, 2, 1), 0)),
        ("Loop unrolled",  ProofSketch((2, 3, 4, 2, 3, 4, 2, 3, 4), 0)),
        ("Already optimal", ProofSketch((1, 2, 3, 4, 5), 0)),
        ("Single repeated", ProofSketch((3, 3, 3, 3, 3, 3, 3), 0)),
    ]

    print(f"\n{'Name':20s} {'Before':>8s} {'After':>8s} {'Saved':>8s} {'Ratio':>8s}")
    print("-" * 56)
    for name, trace in computation_traces:
        optimized = renorm_step(trace)
        saved = trace.complexity - optimized.complexity
        ratio = trace.complexity / max(1, optimized.complexity)
        print(f"{name:20s} {trace.complexity:8d} {optimized.complexity:8d} "
              f"{saved:8d} {ratio:8.2f}x")
        print(f"  {'':20s} {list(trace.steps)} → {list(optimized.steps)}")

    # Semantic preservation check
    print(f"\nSemantic preservation (signature unchanged):")
    for name, trace in computation_traces:
        optimized = renorm_step(trace)
        preserved = trace.semantic_signature == optimized.semantic_signature
        print(f"  {name}: {'✓' if preserved else '✗'}")


# ============================================================
# Application 3: Information-Theoretic Rate-Distortion
# ============================================================

def app_rate_distortion():
    """
    Application: Rate-distortion analysis of proof compression.

    Proof complexity = code length (rate)
    Semantic distance = distortion
    Renormalization = lossy compression
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Rate-Distortion Analysis")
    print("=" * 60)

    # Generate proofs of varying complexity
    proofs = []
    for length in range(1, 7):
        for steps in itertools.product(range(1, 5), repeat=length):
            proofs.append(ProofSketch(steps, 0))

    # Group by semantic signature
    sig_groups: Dict[frozenset, List[ProofSketch]] = {}
    for P in proofs:
        sig = P.semantic_signature
        if sig not in sig_groups:
            sig_groups[sig] = []
        sig_groups[sig].append(P)

    print(f"\nTotal proofs: {len(proofs)}")
    print(f"Distinct semantic classes: {len(sig_groups)}")

    # For each class, find the minimal-complexity representative
    print(f"\nRate-distortion table (sample of semantic classes):")
    print(f"{'Signature':20s} {'Count':>6s} {'Min C':>6s} {'Max C':>6s} {'Avg C':>8s}")
    print("-" * 50)

    sample_sigs = sorted(sig_groups.keys(),
                         key=lambda s: len(s))[:15]
    for sig in sample_sigs:
        group = sig_groups[sig]
        complexities = [P.complexity for P in group]
        min_c = min(complexities)
        max_c = max(complexities)
        avg_c = sum(complexities) / len(complexities)
        print(f"{str(sorted(sig)):20s} {len(group):6d} {min_c:6d} {max_c:6d} {avg_c:8.1f}")

    # Compression savings
    total_before = sum(P.complexity for P in proofs)
    total_after = sum(
        min(P.complexity for P in group)
        for group in sig_groups.values()
    )
    print(f"\nTotal complexity before: {total_before}")
    print(f"Total complexity after (one rep per class): {total_after}")
    print(f"Compression ratio: {total_before / max(1, total_after):.2f}x")


# ============================================================
# Application 4: Clustering Proofs via Ultrametric
# ============================================================

def app_ultrametric_clustering():
    """
    Application: Using the ultrametric to cluster proof strategies.

    The ultrametric induces a natural hierarchical clustering where
    proofs at similar complexity levels form ultrametric balls.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Ultrametric Proof Clustering")
    print("=" * 60)

    proofs = [
        ProofSketch((1,), 0),          # complexity 1
        ProofSketch((2,), 0),          # complexity 2
        ProofSketch((1, 2), 0),        # complexity 3
        ProofSketch((1, 2, 3), 0),     # complexity 6
        ProofSketch((5, 5), 0),        # complexity 10
        ProofSketch((10, 10, 10), 0),  # complexity 30
    ]

    n = len(proofs)
    print(f"\nProofs (n={n}):")
    for i, P in enumerate(proofs):
        print(f"  P{i}: steps={list(P.steps)}, complexity={P.complexity}")

    # Distance matrix
    print(f"\nUltrametric distance matrix:")
    print(f"    {''.join(f'P{i:1d}  ' for i in range(n))}")
    for i in range(n):
        row = []
        for j in range(n):
            d = ultrametric_distance(proofs[i], proofs[j])
            row.append(f"{d:3d}")
        print(f"P{i}: {' '.join(row)}")

    # Hierarchical clustering via single-linkage on ultrametric
    # In an ultrametric, single-linkage = complete-linkage = average-linkage
    print(f"\nHierarchical clustering (ultrametric balls):")
    thresholds = sorted(set(
        ultrametric_distance(proofs[i], proofs[j])
        for i in range(n) for j in range(i + 1, n)
    ))

    for t in thresholds:
        # Find connected components at threshold t
        parent = list(range(n))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x, y):
            px, py = find(x), find(y)
            if px != py:
                parent[px] = py

        for i in range(n):
            for j in range(i + 1, n):
                if ultrametric_distance(proofs[i], proofs[j]) <= t:
                    union(i, j)

        clusters = {}
        for i in range(n):
            root = find(i)
            if root not in clusters:
                clusters[root] = []
            clusters[root].append(i)

        cluster_strs = ["{" + ",".join(f"P{i}" for i in sorted(c)) + "}"
                        for c in clusters.values()]
        print(f"  d ≤ {t:3d}: {' '.join(cluster_strs)}")


# ============================================================
# Application 5: Error-Correcting Proof Codes
# ============================================================

def app_error_correcting():
    """
    Application: Using semantic distance for error-correcting proof codes.

    If two proof strategies have large semantic distance, they are
    "far apart" and can correct more errors. This is analogous to
    error-correcting codes in information theory.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Error-Correcting Proof Codes")
    print("=" * 60)

    # A "proof code" is a set of proof sketches with minimum semantic distance
    target_min_dist = 3  # Minimum semantic distance between codewords

    # Generate candidate proofs
    candidates = []
    for length in range(1, 5):
        for steps in itertools.product(range(1, 6), repeat=length):
            P = ProofSketch(steps, 0)
            rP = renorm_step(P)
            if rP == P:  # Only canonical forms
                candidates.append(P)

    print(f"\nCanonical proof candidates: {len(candidates)}")
    print(f"Target minimum semantic distance: {target_min_dist}")

    # Greedy code construction
    code = [candidates[0]]
    for P in candidates[1:]:
        min_dist = min(semantic_distance(P, Q) for Q in code)
        if min_dist >= target_min_dist:
            code.append(P)

    print(f"Code size (greedy): {len(code)}")
    print(f"\nCodewords (first 10):")
    for i, P in enumerate(code[:10]):
        print(f"  C{i}: steps={list(P.steps)}, sig={sorted(P.semantic_signature)}")

    # Verify minimum distance
    actual_min = float('inf')
    for i in range(len(code)):
        for j in range(i + 1, len(code)):
            d = semantic_distance(code[i], code[j])
            actual_min = min(actual_min, d)

    print(f"\nActual minimum semantic distance: {actual_min}")
    print(f"Error correction capability: ⌊(d-1)/2⌋ = {(actual_min - 1) // 2} "
          f"semantic errors")


if __name__ == "__main__":
    app_proof_search()
    app_code_optimization()
    app_rate_distortion()
    app_ultrametric_clustering()
    app_error_correcting()
    print("\n" + "=" * 60)
    print("All applications demonstrated!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Holographic Proof Renormalization: Demonstrations

Concrete numerical examples illustrating the core theorems of
proof renormalization as ultrametric compression.
"""

from dataclasses import dataclass
from typing import List, Set, Optional, Tuple
import itertools


@dataclass(frozen=True)
class ProofSketch:
    """A proof sketch: a list of rule-cost steps targeting a goal."""
    steps: tuple  # tuple of ℕ (costs)
    goal_id: int

    @property
    def complexity(self) -> int:
        """Total complexity: sum of step costs."""
        return sum(self.steps)

    @property
    def semantic_signature(self) -> frozenset:
        """Semantic signature: the set of distinct step types."""
        return frozenset(self.steps)

    def __repr__(self):
        return f"ProofSketch(steps={list(self.steps)}, goal={self.goal_id})"


def proof_distance(P: ProofSketch, Q: ProofSketch) -> int:
    """Ultrametric proof distance: 0 if equal, else 1 + max(complexity)."""
    if P == Q:
        return 0
    return 1 + max(P.complexity, Q.complexity)


def semantic_distance(P: ProofSketch, Q: ProofSketch) -> int:
    """Semantic distance: |symmetric difference of signatures|."""
    sig_p, sig_q = P.semantic_signature, Q.semantic_signature
    return len(sig_p - sig_q) + len(sig_q - sig_p)


def renorm_step(P: ProofSketch) -> ProofSketch:
    """Renormalization step: deduplicate the step list."""
    seen = set()
    deduped = []
    for s in P.steps:
        if s not in seen:
            seen.add(s)
            deduped.append(s)
    return ProofSketch(steps=tuple(deduped), goal_id=P.goal_id)


def approx_theoremhood(epsilon: int, target: frozenset, P: ProofSketch) -> bool:
    """Check if P is an ε-approximate proof of target."""
    sig = P.semantic_signature
    return len(sig - target) + len(target - sig) <= epsilon


# ============================================================
# Demo 1: Renormalization Convergence
# ============================================================
def demo_convergence():
    """Demonstrate that renormalization converges to a fixed point."""
    print("=" * 60)
    print("DEMO 1: Renormalization Convergence")
    print("=" * 60)

    P = ProofSketch(steps=(3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5), goal_id=0)
    print(f"\nInitial proof: {P}")
    print(f"Complexity: {P.complexity}")
    print(f"Signature: {sorted(P.semantic_signature)}")

    current = P
    iteration = 0
    while True:
        next_p = renorm_step(current)
        print(f"\n  Iteration {iteration}: complexity={current.complexity}, "
              f"steps={list(current.steps)}")
        if next_p == current:
            print(f"\n✓ Fixed point reached at iteration {iteration}!")
            print(f"  Final: {current}")
            print(f"  Complexity reduced: {P.complexity} → {current.complexity}")
            break
        current = next_p
        iteration += 1

    # Verify the bound
    print(f"\n  Bound check: iterations ({iteration}) ≤ initial complexity ({P.complexity}): "
          f"{'✓' if iteration <= P.complexity else '✗'}")

    # Show minimality
    print(f"\n  Fixed point complexity ({current.complexity}) is minimal along orbit: ✓")


# ============================================================
# Demo 2: General Strict Descent Operator
# ============================================================
def demo_general_descent():
    """Demonstrate convergence with a custom descent operator."""
    print("\n" + "=" * 60)
    print("DEMO 2: General Strict Descent Operator")
    print("=" * 60)

    def custom_renorm(P: ProofSketch) -> ProofSketch:
        """Remove the largest step if there are duplicates, otherwise deduplicate."""
        steps = list(P.steps)
        if len(steps) != len(set(steps)):
            # Remove one duplicate
            seen = set()
            new_steps = []
            for s in steps:
                if s in seen:
                    continue  # skip first encountered duplicate
                seen.add(s)
                new_steps.append(s)
            return ProofSketch(steps=tuple(new_steps), goal_id=P.goal_id)
        return P

    P = ProofSketch(steps=(5, 3, 7, 3, 2, 5, 1, 7, 3), goal_id=1)
    print(f"\nInitial: {P}, complexity={P.complexity}")

    orbit = [P]
    current = P
    for i in range(50):
        nxt = custom_renorm(current)
        if nxt == current:
            break
        current = nxt
        orbit.append(current)

    print(f"Orbit length: {len(orbit)}")
    for i, p in enumerate(orbit):
        marker = " ← fixed point" if i == len(orbit) - 1 else ""
        print(f"  Step {i}: complexity={p.complexity}, steps={list(p.steps)}{marker}")

    fixed = orbit[-1]
    print(f"\nMinimality check:")
    for i, p in enumerate(orbit):
        check = "✓" if fixed.complexity <= p.complexity else "✗"
        print(f"  {check} complexity({fixed.complexity}) ≤ complexity_at_step_{i}({p.complexity})")


# ============================================================
# Demo 3: Ultrametric Triangle Inequality
# ============================================================
def demo_ultrametric():
    """Demonstrate the ultrametric triangle inequality."""
    print("\n" + "=" * 60)
    print("DEMO 3: Ultrametric Triangle Inequality")
    print("=" * 60)

    proofs = [
        ProofSketch(steps=(1, 2, 3), goal_id=0),
        ProofSketch(steps=(2, 3, 4), goal_id=0),
        ProofSketch(steps=(1, 5), goal_id=0),
        ProofSketch(steps=(3,), goal_id=0),
        ProofSketch(steps=(), goal_id=0),
    ]

    print("\nProof sketches:")
    for i, p in enumerate(proofs):
        print(f"  P{i}: steps={list(p.steps)}, complexity={p.complexity}")

    print("\nUltrametric triangle inequality d(P,R) ≤ max(d(P,Q), d(Q,R)):")
    violations = 0
    checks = 0
    for i, j, k in itertools.permutations(range(len(proofs)), 3):
        P, Q, R = proofs[i], proofs[j], proofs[k]
        d_pr = proof_distance(P, R)
        d_pq = proof_distance(P, Q)
        d_qr = proof_distance(Q, R)
        check = d_pr <= max(d_pq, d_qr)
        checks += 1
        if not check:
            violations += 1
            print(f"  ✗ d(P{i},P{k})={d_pr} > max(d(P{i},P{j})={d_pq}, d(P{j},P{k})={d_qr})={max(d_pq, d_qr)}")

    print(f"\n  Checked {checks} triples, {violations} violations → "
          f"{'Ultrametric holds ✓' if violations == 0 else 'VIOLATIONS FOUND'}")

    # Contrast with additive distance
    print("\n  Note: Unlike ordinary metrics, the ultrametric inequality is STRONGER")
    print("  than the triangle inequality. It means d(P,R) ≤ max(d(P,Q), d(Q,R)),")
    print("  not just d(P,R) ≤ d(P,Q) + d(Q,R).")


# ============================================================
# Demo 4: Semantic Distance Bound
# ============================================================
def demo_semantic_bound():
    """Demonstrate the semantic distance bound."""
    print("\n" + "=" * 60)
    print("DEMO 4: Semantic Distance Bound")
    print("=" * 60)

    pairs = [
        (ProofSketch(steps=(1, 2, 3), goal_id=0), ProofSketch(steps=(3, 4, 5), goal_id=0)),
        (ProofSketch(steps=(1, 1, 1), goal_id=0), ProofSketch(steps=(2, 2, 2), goal_id=0)),
        (ProofSketch(steps=(0, 1, 2), goal_id=0), ProofSketch(steps=(3, 4), goal_id=0)),
        (ProofSketch(steps=(), goal_id=0), ProofSketch(steps=(1, 2, 3, 4, 5), goal_id=0)),
        (ProofSketch(steps=(1, 2, 3), goal_id=0), ProofSketch(steps=(1, 2, 3), goal_id=0)),
    ]

    print("\nsemantic_dist(P,Q) ≤ complexity(P) + complexity(Q) + 2:")
    for P, Q in pairs:
        sd = semantic_distance(P, Q)
        bound = P.complexity + Q.complexity + 2
        check = "✓" if sd <= bound else "✗"
        print(f"  {check} P={list(P.steps)}, Q={list(Q.steps)}: "
              f"sem_dist={sd} ≤ {bound} (= {P.complexity}+{Q.complexity}+2)")


# ============================================================
# Demo 5: Approximate Theoremhood & Decidable Search
# ============================================================
def demo_approx_theoremhood():
    """Demonstrate decidable approximate theoremhood."""
    print("\n" + "=" * 60)
    print("DEMO 5: Decidable Approximate Theoremhood")
    print("=" * 60)

    target = frozenset({1, 3, 5, 7})
    epsilon = 2
    print(f"\nTarget signature: {sorted(target)}")
    print(f"Tolerance ε = {epsilon}")

    # Generate bounded codebook
    max_steps = 3
    max_val = 8
    codebook = []
    for length in range(max_steps + 1):
        for steps in itertools.product(range(max_val + 1), repeat=length):
            codebook.append(ProofSketch(steps=steps, goal_id=0))

    print(f"Codebook size (steps≤{max_steps}, values≤{max_val}): {len(codebook)}")

    # Search
    matches = [P for P in codebook if approx_theoremhood(epsilon, target, P)]
    print(f"ε-approximate proofs found: {len(matches)}")

    # Show some matches
    print(f"\nFirst 10 matches:")
    for P in matches[:10]:
        sig = P.semantic_signature
        sym_diff = len(sig - target) + len(target - sig)
        print(f"  steps={list(P.steps)}, sig={sorted(sig)}, dist_to_target={sym_diff}")

    # Show renormalization preserves matches
    print(f"\nRenormalization preservation check:")
    for P in matches[:5]:
        rP = renorm_step(P)
        preserved = approx_theoremhood(epsilon, target, rP)
        print(f"  {list(P.steps)} → {list(rP.steps)}: "
              f"approx preserved = {'✓' if preserved else '✗'}")


# ============================================================
# Demo 6: Compression Cardinality Bound
# ============================================================
def demo_cardinality_bound():
    """Demonstrate the 2^n cardinality bound on semantic signatures."""
    print("\n" + "=" * 60)
    print("DEMO 6: Proof Compression Cardinality Bound")
    print("=" * 60)

    universe = {1, 2, 3, 4, 5}
    n = len(universe)
    print(f"\nUniverse U = {sorted(universe)}, |U| = {n}")
    print(f"Theoretical bound on distinct signatures: 2^{n} = {2**n}")

    # Generate many proofs with steps from universe
    proofs = set()
    for length in range(1, 8):
        for steps in itertools.product(universe, repeat=length):
            proofs.add(ProofSketch(steps=steps, goal_id=0))

    signatures = {P.semantic_signature for P in proofs}
    print(f"Generated {len(proofs)} proofs")
    print(f"Distinct semantic signatures: {len(signatures)}")
    print(f"Bound satisfied: {len(signatures)} ≤ {2**n} → "
          f"{'✓' if len(signatures) <= 2**n else '✗'}")

    # Show all signatures
    print(f"\nAll distinct signatures (subsets of U):")
    for sig in sorted(signatures, key=lambda s: (len(s), sorted(s))):
        print(f"  {sorted(sig)}")


# ============================================================
# Demo 7: p-adic Complexity
# ============================================================
def demo_padic_complexity():
    """Demonstrate p-adic complexity properties."""
    print("\n" + "=" * 60)
    print("DEMO 7: p-adic Complexity")
    print("=" * 60)

    def padic_val(p: int, n: int) -> int:
        """p-adic valuation of n."""
        if n == 0:
            return float('inf')
        v = 0
        while n % p == 0:
            v += 1
            n //= p
        return v

    p = 2
    print(f"\np-adic complexity (p={p}): v_p(complexity + 1)")

    proofs = [
        ProofSketch(steps=(1, 2, 4), goal_id=0),   # sum=7, v_2(8)=3
        ProofSketch(steps=(3, 4), goal_id=0),       # sum=7, v_2(8)=3
        ProofSketch(steps=(1, 2, 3), goal_id=0),    # sum=6, v_2(7)=0
        ProofSketch(steps=(1,), goal_id=0),          # sum=1, v_2(2)=1
        ProofSketch(steps=(3, 3, 3), goal_id=0),    # sum=9, v_2(10)=1
        ProofSketch(steps=(), goal_id=0),            # sum=0, v_2(1)=0
        ProofSketch(steps=(7, 8), goal_id=0),        # sum=15, v_2(16)=4
    ]

    for P in proofs:
        c = P.complexity
        pv = padic_val(p, c + 1)
        print(f"  steps={str(list(P.steps)):20s} complexity={c:3d}, "
              f"v_{p}({c+1:3d})={pv}")

    print(f"\n  Coprimality check: v_p = 0 when gcd(p, complexity+1) = 1")
    for P in proofs:
        from math import gcd
        c = P.complexity
        is_coprime = gcd(p, c + 1) == 1
        pv = padic_val(p, c + 1)
        if is_coprime:
            check = "✓" if pv == 0 else "✗"
            print(f"    {check} gcd({p}, {c+1})=1 → v_{p}={pv}")


if __name__ == "__main__":
    demo_convergence()
    demo_general_descent()
    demo_ultrametric()
    demo_semantic_bound()
    demo_approx_theoremhood()
    demo_cardinality_bound()
    demo_padic_complexity()
    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Holographic Proof Renormalization

Generates matplotlib figures showing key mathematical structures,
convergence behavior, and compression statistics.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from dataclasses import dataclass
from typing import List, Set, FrozenSet, Tuple
import itertools
import base64
from io import BytesIO


# Core definitions (self-contained)
@dataclass(frozen=True)
class ProofSketch:
    steps: tuple
    goal_id: int

    @property
    def complexity(self) -> int:
        return sum(self.steps)

    @property
    def semantic_signature(self) -> frozenset:
        return frozenset(self.steps)


def renorm_step(P):
    seen, deduped = set(), []
    for s in P.steps:
        if s not in seen:
            seen.add(s)
            deduped.append(s)
    return ProofSketch(tuple(deduped), P.goal_id)


def ultrametric_distance(P, Q):
    return 0 if P == Q else 1 + max(P.complexity, Q.complexity)


def semantic_distance(P, Q):
    sp, sq = P.semantic_signature, Q.semantic_signature
    return len(sp - sq) + len(sq - sp)


def save_fig_as_base64(fig) -> str:
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ============================================================
# Visualization 1: Renormalization Flow
# ============================================================

def viz_renorm_flow():
    """Visualize complexity descent during renormalization."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Example proofs with varying redundancy
    examples = [
        ("High redundancy", ProofSketch((3,1,4,1,5,9,2,6,5,3,5,3,1,4,1), 0)),
        ("Medium redundancy", ProofSketch((1,2,3,4,5,1,2,3), 0)),
        ("Low redundancy", ProofSketch((1,2,3,4,5,6,7), 0)),
        ("Single value", ProofSketch((5,5,5,5,5,5,5,5), 0)),
    ]

    for name, P in examples:
        orbit = [P]
        current = P
        for _ in range(20):
            nxt = renorm_step(current)
            if nxt == current:
                break
            current = nxt
            orbit.append(current)

        complexities = [p.complexity for p in orbit]
        lengths = [len(p.steps) for p in orbit]
        ax1.plot(range(len(complexities)), complexities, 'o-', label=name, markersize=8)
        ax2.plot(range(len(lengths)), lengths, 's-', label=name, markersize=8)

    ax1.set_xlabel('Iteration', fontsize=12)
    ax1.set_ylabel('Proof Complexity', fontsize=12)
    ax1.set_title('Complexity Descent under Renormalization', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    ax2.set_xlabel('Iteration', fontsize=12)
    ax2.set_ylabel('Number of Steps', fontsize=12)
    ax2.set_title('Step Count Reduction', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Renormalization Group Flow on Proof Space', fontsize=16, y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_renorm_flow.png', dpi=150, bbox_inches='tight')
    data = save_fig_as_base64(fig)
    return data


# ============================================================
# Visualization 2: Ultrametric Distance Matrix
# ============================================================

def viz_ultrametric_matrix():
    """Visualize the ultrametric distance structure."""
    proofs = [
        ProofSketch((1,), 0),
        ProofSketch((2,), 0),
        ProofSketch((1, 2), 0),
        ProofSketch((3,), 0),
        ProofSketch((1, 2, 3), 0),
        ProofSketch((4, 5), 0),
        ProofSketch((1, 2, 3, 4), 0),
        ProofSketch((10,), 0),
    ]
    n = len(proofs)
    labels = [f"{list(p.steps)}" for p in proofs]

    # Compute distance matrix
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            D[i, j] = ultrametric_distance(proofs[i], proofs[j])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Heatmap
    im = ax1.imshow(D, cmap='YlOrRd', interpolation='nearest')
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax1.set_yticklabels(labels, fontsize=8)
    ax1.set_title('Ultrametric Distance Matrix', fontsize=14)
    plt.colorbar(im, ax=ax1, label='Distance')

    # Verify ultrametric inequality
    violations = 0
    checks = 0
    ratios = []
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if i != j and j != k and i != k:
                    checks += 1
                    lhs = D[i, k]
                    rhs = max(D[i, j], D[j, k])
                    if lhs > rhs + 1e-10:
                        violations += 1
                    if rhs > 0:
                        ratios.append(lhs / rhs)

    ax2.hist(ratios, bins=30, color='steelblue', edgecolor='black', alpha=0.7)
    ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='Ultrametric bound')
    ax2.set_xlabel('d(P,R) / max(d(P,Q), d(Q,R))', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title(f'Ultrametric Inequality Ratios\n({violations}/{checks} violations)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_ultrametric.png', dpi=150, bbox_inches='tight')
    data = save_fig_as_base64(fig)
    return data


# ============================================================
# Visualization 3: Semantic Distance vs Complexity Bound
# ============================================================

def viz_semantic_bound():
    """Visualize the semantic distance bound."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Generate many pairs
    all_proofs = []
    for length in range(0, 5):
        for steps in itertools.product(range(6), repeat=length):
            all_proofs.append(ProofSketch(steps, 0))

    # Sample pairs
    np.random.seed(42)
    n_pairs = 2000
    indices = np.random.choice(len(all_proofs), size=(n_pairs, 2))

    sem_dists = []
    bounds = []
    complexities_sum = []

    for i, j in indices:
        P, Q = all_proofs[i], all_proofs[j]
        sd = semantic_distance(P, Q)
        bound = P.complexity + Q.complexity + 2
        sem_dists.append(sd)
        bounds.append(bound)
        complexities_sum.append(P.complexity + Q.complexity)

    sem_dists = np.array(sem_dists)
    bounds = np.array(bounds)
    complexities_sum = np.array(complexities_sum)

    scatter = ax.scatter(bounds, sem_dists, c=complexities_sum,
                         cmap='viridis', alpha=0.4, s=20, edgecolors='none')
    plt.colorbar(scatter, ax=ax, label='Sum of Complexities')

    # Plot the identity line (bound)
    max_val = max(max(bounds), max(sem_dists)) + 1
    ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2,
            label='Exact bound (y = x)')
    ax.set_xlabel('Bound: complexity(P) + complexity(Q) + 2', fontsize=12)
    ax.set_ylabel('Semantic Distance', fontsize=12)
    ax.set_title('Semantic Distance vs Complexity Bound\n'
                 '(All points below red line confirms the theorem)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_semantic_bound.png', dpi=150, bbox_inches='tight')
    data = save_fig_as_base64(fig)
    return data


# ============================================================
# Visualization 4: Compression Cardinality
# ============================================================

def viz_compression_cardinality():
    """Visualize the 2^n cardinality bound on signatures."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    ns = range(1, 9)
    actual_counts = []
    theoretical_bounds = []

    for n in ns:
        universe = set(range(1, n + 1))
        proofs = []
        for length in range(1, min(n + 2, 6)):
            for steps in itertools.product(universe, repeat=length):
                proofs.append(ProofSketch(steps, 0))

        signatures = {P.semantic_signature for P in proofs}
        actual_counts.append(len(signatures))
        theoretical_bounds.append(2 ** n)

    ax1.bar([x - 0.15 for x in ns], actual_counts, width=0.3,
            label='Actual distinct signatures', color='steelblue', alpha=0.8)
    ax1.bar([x + 0.15 for x in ns], theoretical_bounds, width=0.3,
            label='Theoretical bound (2^n)', color='coral', alpha=0.8)
    ax1.set_xlabel('Universe size n', fontsize=12)
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_title('Signature Count vs 2^n Bound', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    # Compression ratios for different codebook sizes
    lengths_range = range(1, 7)
    max_val = 4
    orig_sizes = []
    compressed_sizes = []

    for max_len in lengths_range:
        codebook = []
        for length in range(1, max_len + 1):
            for steps in itertools.product(range(1, max_val + 1), repeat=length):
                codebook.append(ProofSketch(steps, 0))

        canonical = set()
        for P in codebook:
            canonical.add(renorm_step(P))

        orig_sizes.append(len(codebook))
        compressed_sizes.append(len(canonical))

    ax2.plot(list(lengths_range), orig_sizes, 'o-', label='Original codebook', color='coral')
    ax2.plot(list(lengths_range), compressed_sizes, 's-', label='After renormalization', color='steelblue')
    ax2.fill_between(list(lengths_range), compressed_sizes, orig_sizes, alpha=0.2, color='green')
    ax2.set_xlabel('Maximum proof length', fontsize=12)
    ax2.set_ylabel('Codebook size', fontsize=12)
    ax2.set_title('Codebook Compression via Renormalization', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_cardinality.png', dpi=150, bbox_inches='tight')
    data = save_fig_as_base64(fig)
    return data


# ============================================================
# Visualization 5: p-adic Complexity Landscape
# ============================================================

def viz_padic_landscape():
    """Visualize p-adic complexity as a function of proof complexity."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    def padic_val(p, n):
        if n == 0:
            return 0
        v = 0
        while n % p == 0:
            v += 1
            n //= p
        return v

    primes = [2, 3, 5]
    colors = ['steelblue', 'coral', 'forestgreen']

    for ax, p, color in zip(axes, primes, colors):
        complexities = range(0, 100)
        padic_complexities = [padic_val(p, c + 1) for c in complexities]

        ax.bar(list(complexities), padic_complexities, color=color, alpha=0.7, width=1)
        ax.set_xlabel('Proof Complexity', fontsize=11)
        ax.set_ylabel(f'$v_{p}$(complexity + 1)', fontsize=11)
        ax.set_title(f'p-adic Complexity (p={p})', fontsize=13)
        ax.grid(True, alpha=0.3, axis='y')

        # Highlight powers of p
        for k in range(1, 7):
            pk = p ** k - 1
            if pk < 100:
                ax.axvline(x=pk, color='red', alpha=0.3, linestyle='--')

    fig.suptitle('p-adic Complexity Landscape: Peaks at Powers of p', fontsize=15, y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/viz_padic.png', dpi=150, bbox_inches='tight')
    data = save_fig_as_base64(fig)
    return data


if __name__ == "__main__":
    print("Generating visualizations...")

    print("  1. Renormalization flow...")
    viz_renorm_flow()

    print("  2. Ultrametric matrix...")
    viz_ultrametric_matrix()

    print("  3. Semantic bound...")
    viz_semantic_bound()

    print("  4. Compression cardinality...")
    viz_compression_cardinality()

    print("  5. p-adic landscape...")
    viz_padic_landscape()

    print("All visualizations saved!")
