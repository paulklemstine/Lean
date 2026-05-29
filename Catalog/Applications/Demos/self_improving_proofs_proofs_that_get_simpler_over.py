#!/usr/bin/env python3
"""
Proof Dynamics: Applications

Demonstrates real-world applications of proof dynamics theory:
1. Proof compression for theorem databases
2. Proof complexity benchmarking
3. Automated proof simplification pipeline
4. Cross-domain energy analysis
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional
import time


# ── Self-contained definitions (no local imports) ──────────────

class TheoremLabel(Enum):
    IrrationalSqrt2 = auto()
    EvenPlusEvenEven = auto()
    DvdTrans = auto()
    ParityLemma = auto()
    Commutativity = auto()
    Associativity = auto()

@dataclass
class ProofSketch:
    pass

@dataclass
class Axiom(ProofSketch):
    label: TheoremLabel

@dataclass
class Lemma(ProofSketch):
    label: TheoremLabel
    sub: ProofSketch

@dataclass
class Trans(ProofSketch):
    left: ProofSketch
    right: ProofSketch

@dataclass
class Cases(ProofSketch):
    left: ProofSketch
    right: ProofSketch

@dataclass
class Redundant(ProofSketch):
    inner: ProofSketch

@dataclass
class Duplicate(ProofSketch):
    inner: ProofSketch


def size(p):
    if isinstance(p, Axiom): return 1
    if isinstance(p, Lemma): return 1 + size(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + size(p.left) + size(p.right)
    if isinstance(p, (Redundant, Duplicate)): return 1 + size(p.inner)
    raise TypeError

def depth(p):
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + depth(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + max(depth(p.left), depth(p.right))
    if isinstance(p, (Redundant, Duplicate)): return 1 + depth(p.inner)
    raise TypeError

def lemma_count(p):
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + lemma_count(p.sub)
    if isinstance(p, (Trans, Cases)): return lemma_count(p.left) + lemma_count(p.right)
    if isinstance(p, (Redundant, Duplicate)): return lemma_count(p.inner)
    raise TypeError

def score(p):
    return size(p) + depth(p) + lemma_count(p)

def sem(p):
    if isinstance(p, Axiom): return p.label
    if isinstance(p, Lemma): return p.label
    if isinstance(p, Trans): return sem(p.left)
    if isinstance(p, Cases): return sem(p.left)
    if isinstance(p, (Redundant, Duplicate)): return sem(p.inner)
    raise TypeError

def step_once(p):
    if isinstance(p, Redundant): return p.inner
    if isinstance(p, Duplicate): return p.inner
    if isinstance(p, Lemma):
        if isinstance(p.sub, Redundant): return Lemma(p.label, p.sub.inner)
        if isinstance(p.sub, Axiom): return Axiom(p.label)
        s = step_once(p.sub)
        return Lemma(p.label, s) if s is not None else None
    if isinstance(p, Trans):
        s = step_once(p.left)
        if s: return Trans(s, p.right)
        s = step_once(p.right)
        if s: return Trans(p.left, s)
        return None
    if isinstance(p, Cases):
        s = step_once(p.left)
        if s: return Cases(s, p.right)
        s = step_once(p.right)
        if s: return Cases(p.left, s)
        return None
    return None

def normalize(p):
    steps = 0
    while True:
        nxt = step_once(p)
        if nxt is None: return p, steps
        p = nxt; steps += 1


# ────────────────────────────────────────────────────────────────
# APPLICATION 1: Proof Compression for Theorem Databases
# ────────────────────────────────────────────────────────────────

def app_compression():
    """Simulate proof compression on a theorem database."""
    print("=" * 60)
    print("APPLICATION 1: Proof Compression for Theorem Databases")
    print("=" * 60)

    # Simulate a database of proof sketches with varying redundancy
    database = {
        "Theorem A (sqrt2)": Redundant(Redundant(Duplicate(
            Lemma(TheoremLabel.IrrationalSqrt2,
                Redundant(Axiom(TheoremLabel.EvenPlusEvenEven)))))),
        "Theorem B (parity)": Duplicate(
            Lemma(TheoremLabel.ParityLemma,
                Redundant(Redundant(Axiom(TheoremLabel.Commutativity))))),
        "Theorem C (divisibility)": Trans(
            Redundant(Axiom(TheoremLabel.DvdTrans)),
            Duplicate(Redundant(Axiom(TheoremLabel.Associativity)))),
        "Theorem D (clean)": Axiom(TheoremLabel.Commutativity),
    }

    total_before = 0
    total_after = 0

    for name, sketch in database.items():
        before = score(sketch)
        nf, steps = normalize(sketch)
        after = score(nf)
        ratio = (1 - after/before) * 100 if before > 0 else 0
        total_before += before
        total_after += after
        print(f"\n  {name}:")
        print(f"    Before: score={before}, size={size(sketch)}")
        print(f"    After:  score={after}, size={size(nf)}")
        print(f"    Compression: {ratio:.0f}% reduction in {steps} steps")
        print(f"    Semantics: {sem(sketch).name} → {sem(nf).name} "
              f"({'✓' if sem(sketch) == sem(nf) else '✗'})")

    overall = (1 - total_after/total_before) * 100
    print(f"\n  Overall database compression: {overall:.0f}%")
    print(f"  Total score: {total_before} → {total_after}")


# ────────────────────────────────────────────────────────────────
# APPLICATION 2: Proof Complexity Benchmarking
# ────────────────────────────────────────────────────────────────

def app_benchmarking():
    """Benchmark normalization performance on synthetic proof sketches."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Proof Complexity Benchmarking")
    print("=" * 60)

    def make_deep_chain(n: int) -> ProofSketch:
        """Create a chain of n Redundant wrappers around an Axiom."""
        p = Axiom(TheoremLabel.ParityLemma)
        for _ in range(n):
            p = Redundant(p)
        return p

    def make_bushy_tree(n: int) -> ProofSketch:
        """Create a balanced binary tree of depth n with redundant leaves."""
        if n == 0:
            return Redundant(Axiom(TheoremLabel.DvdTrans))
        left = make_bushy_tree(n - 1)
        right = make_bushy_tree(n - 1)
        return Trans(left, right)

    print("\n  Linear chains (depth n):")
    print(f"  {'n':>5} {'initial':>8} {'final':>6} {'steps':>6} {'time_ms':>8}")
    for n in [5, 10, 20, 50, 100]:
        p = make_deep_chain(n)
        t0 = time.perf_counter()
        nf, steps = normalize(p)
        dt = (time.perf_counter() - t0) * 1000
        print(f"  {n:5d} {score(p):8d} {score(nf):6d} {steps:6d} {dt:8.2f}")

    print("\n  Bushy trees (depth n):")
    print(f"  {'n':>5} {'initial':>8} {'final':>6} {'steps':>6} {'time_ms':>8}")
    for n in [2, 3, 4, 5, 6]:
        p = make_bushy_tree(n)
        t0 = time.perf_counter()
        nf, steps = normalize(p)
        dt = (time.perf_counter() - t0) * 1000
        print(f"  {n:5d} {score(p):8d} {score(nf):6d} {steps:6d} {dt:8.2f}")


# ────────────────────────────────────────────────────────────────
# APPLICATION 3: Proof Simplification Pipeline
# ────────────────────────────────────────────────────────────────

def app_pipeline():
    """Demonstrate an automated proof simplification pipeline."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Automated Proof Simplification Pipeline")
    print("=" * 60)

    # Input: a messy proof with multiple layers of redundancy
    raw_proof = Lemma(TheoremLabel.IrrationalSqrt2,
        Trans(
            Redundant(Lemma(TheoremLabel.EvenPlusEvenEven,
                Duplicate(Axiom(TheoremLabel.ParityLemma)))),
            Cases(
                Duplicate(Axiom(TheoremLabel.DvdTrans)),
                Redundant(Redundant(Axiom(TheoremLabel.Commutativity)))
            )
        ))

    print(f"\n  Input proof: score={score(raw_proof)}, "
          f"size={size(raw_proof)}, depth={depth(raw_proof)}")

    # Run pipeline: normalize step by step
    current = raw_proof
    step_num = 0
    print(f"\n  Pipeline trace:")
    while True:
        print(f"    [{step_num}] score={score(current):3d}, "
              f"depth={depth(current):2d}, lemmas={lemma_count(current)}")
        nxt = step_once(current)
        if nxt is None:
            break
        current = nxt
        step_num += 1

    print(f"\n  Output: score={score(current)}, "
          f"size={size(current)}, depth={depth(current)}")
    print(f"  Semantic check: {sem(raw_proof).name} = {sem(current).name} "
          f"({'✓' if sem(raw_proof) == sem(current) else '✗'})")


# ────────────────────────────────────────────────────────────────
# APPLICATION 4: Cross-Domain Energy Analysis
# ────────────────────────────────────────────────────────────────

def app_energy_analysis():
    """Analyze proof refinement as discrete energy dissipation."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Cross-Domain Energy Analysis")
    print("=" * 60)

    sketch = Redundant(Duplicate(Redundant(Duplicate(
        Lemma(TheoremLabel.IrrationalSqrt2,
            Redundant(Axiom(TheoremLabel.EvenPlusEvenEven)))))))

    chain = [sketch]
    current = sketch
    while True:
        nxt = step_once(current)
        if nxt is None: break
        chain.append(nxt); current = nxt

    scores = [score(p) for p in chain]
    drops = [scores[i] - scores[i+1] for i in range(len(scores)-1)]

    print(f"\n  Energy trajectory: {' → '.join(map(str, scores))}")
    print(f"  Energy drops:     {drops}")
    print(f"  Total dissipated: {scores[0] - scores[-1]}")
    print(f"  Average drop:     {sum(drops)/len(drops):.1f}")
    print(f"  Max single drop:  {max(drops)}")
    print(f"  Min single drop:  {min(drops)}")

    # Verify Lyapunov property
    monotone = all(d > 0 for d in drops)
    print(f"\n  Strict Lyapunov property: {'✓' if monotone else '✗'}")
    print(f"  No periodic orbits:      {'✓' if monotone else '✗'}")

    # Thermodynamic analogy
    print(f"\n  Thermodynamic interpretation:")
    print(f"    Initial energy (hot state):  {scores[0]}")
    print(f"    Ground state energy:         {scores[-1]}")
    print(f"    Cooling steps:               {len(drops)}")
    print(f"    Entropy production:          "
          f"{sum(drops)} units (irreversible)")


# ────────────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    app_compression()
    app_benchmarking()
    app_pipeline()
    app_energy_analysis()
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Proof Dynamics: Interactive Demo

Demonstrates the core concepts of proof dynamics:
- Constructing proof sketches as trees
- Computing multi-dimensional complexity measures
- Applying refinement steps that preserve semantics
- Visualizing refinement chains and energy descent
- Testing the normal-form uniqueness conjecture

Run: python demo.py
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum, auto
from typing import Optional


# ────────────────────────────────────────────────────────────────
# Theorem Labels
# ────────────────────────────────────────────────────────────────

class TheoremLabel(Enum):
    IrrationalSqrt2 = auto()
    EvenPlusEvenEven = auto()
    DvdTrans = auto()
    ParityLemma = auto()

    def __repr__(self):
        return self.name


# ────────────────────────────────────────────────────────────────
# Proof Sketch — Inductive Tree
# ────────────────────────────────────────────────────────────────

@dataclass
class ProofSketch:
    """Abstract base for proof sketch nodes."""
    pass

@dataclass
class Axiom(ProofSketch):
    label: TheoremLabel
    def __repr__(self): return f"Axiom({self.label!r})"

@dataclass
class Lemma(ProofSketch):
    label: TheoremLabel
    sub: ProofSketch
    def __repr__(self): return f"Lemma({self.label!r}, {self.sub!r})"

@dataclass
class Trans(ProofSketch):
    left: ProofSketch
    right: ProofSketch
    def __repr__(self): return f"Trans({self.left!r}, {self.right!r})"

@dataclass
class Cases(ProofSketch):
    left: ProofSketch
    right: ProofSketch
    def __repr__(self): return f"Cases({self.left!r}, {self.right!r})"

@dataclass
class Redundant(ProofSketch):
    inner: ProofSketch
    def __repr__(self): return f"Redundant({self.inner!r})"

@dataclass
class Duplicate(ProofSketch):
    inner: ProofSketch
    def __repr__(self): return f"Duplicate({self.inner!r})"


# ────────────────────────────────────────────────────────────────
# Complexity Measures
# ────────────────────────────────────────────────────────────────

def size(p: ProofSketch) -> int:
    if isinstance(p, Axiom): return 1
    if isinstance(p, Lemma): return 1 + size(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + size(p.left) + size(p.right)
    if isinstance(p, (Redundant, Duplicate)): return 1 + size(p.inner)
    raise TypeError

def depth(p: ProofSketch) -> int:
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + depth(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + max(depth(p.left), depth(p.right))
    if isinstance(p, (Redundant, Duplicate)): return 1 + depth(p.inner)
    raise TypeError

def lemma_count(p: ProofSketch) -> int:
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + lemma_count(p.sub)
    if isinstance(p, (Trans, Cases)): return lemma_count(p.left) + lemma_count(p.right)
    if isinstance(p, (Redundant, Duplicate)): return lemma_count(p.inner)
    raise TypeError

def complexity(p: ProofSketch) -> tuple[int, int, int]:
    return (size(p), depth(p), lemma_count(p))

def score(p: ProofSketch) -> int:
    s, d, l = complexity(p)
    return s + d + l

def sem(p: ProofSketch) -> TheoremLabel:
    if isinstance(p, Axiom): return p.label
    if isinstance(p, Lemma): return p.label
    if isinstance(p, Trans): return sem(p.left)
    if isinstance(p, Cases): return sem(p.left)
    if isinstance(p, Redundant): return sem(p.inner)
    if isinstance(p, Duplicate): return sem(p.inner)
    raise TypeError


# ────────────────────────────────────────────────────────────────
# Refinement Steps
# ────────────────────────────────────────────────────────────────

def step_once(p: ProofSketch) -> Optional[ProofSketch]:
    """Apply one greedy refinement step, or return None if normal form."""
    if isinstance(p, Redundant):
        return p.inner
    if isinstance(p, Duplicate):
        return p.inner
    if isinstance(p, Lemma):
        if isinstance(p.sub, Redundant):
            return Lemma(p.label, p.sub.inner)
        if isinstance(p.sub, Axiom):
            return Axiom(p.label)
        sub_step = step_once(p.sub)
        if sub_step is not None:
            return Lemma(p.label, sub_step)
        return None
    if isinstance(p, Trans):
        left_step = step_once(p.left)
        if left_step is not None:
            return Trans(left_step, p.right)
        right_step = step_once(p.right)
        if right_step is not None:
            return Trans(p.left, right_step)
        return None
    if isinstance(p, Cases):
        left_step = step_once(p.left)
        if left_step is not None:
            return Cases(left_step, p.right)
        right_step = step_once(p.right)
        if right_step is not None:
            return Cases(p.left, right_step)
        return None
    return None  # Axiom: normal form


def normalize(p: ProofSketch) -> ProofSketch:
    """Greedily normalize by iterating step_once until fixpoint."""
    current = p
    while True:
        next_p = step_once(current)
        if next_p is None:
            return current
        current = next_p


def refinement_chain(p: ProofSketch) -> list[ProofSketch]:
    """Compute the full refinement chain from p to normal form."""
    chain = [p]
    current = p
    while True:
        next_p = step_once(current)
        if next_p is None:
            return chain
        chain.append(next_p)
        current = next_p


# ────────────────────────────────────────────────────────────────
# Demo: √2 Irrationality Proof Sketch Refinement
# ────────────────────────────────────────────────────────────────

def demo_sqrt2():
    print("=" * 60)
    print("DEMO 1: Refinement of √2 Irrationality Proof Sketch")
    print("=" * 60)

    # Construct a bloated proof sketch
    bloated = Redundant(Duplicate(Redundant(
        Lemma(TheoremLabel.IrrationalSqrt2,
            Trans(
                Redundant(Axiom(TheoremLabel.EvenPlusEvenEven)),
                Duplicate(Axiom(TheoremLabel.DvdTrans))
            ))
    )))

    print(f"\nInitial sketch: {bloated}")
    print(f"  Complexity: size={size(bloated)}, depth={depth(bloated)}, "
          f"lemmas={lemma_count(bloated)}")
    print(f"  Score: {score(bloated)}")
    print(f"  Semantics: {sem(bloated)}")

    chain = refinement_chain(bloated)
    print(f"\nRefinement chain ({len(chain)} steps):")
    for i, p in enumerate(chain):
        print(f"  Step {i}: score={score(p):3d}  sem={sem(p)!r:25s}  {p}")

    nf = chain[-1]
    print(f"\nNormal form: {nf}")
    print(f"  Score: {score(nf)}")
    print(f"  Semantics preserved: {sem(bloated) == sem(nf)}")
    print(f"  Is normal form: {step_once(nf) is None}")


# ────────────────────────────────────────────────────────────────
# Demo: Energy Descent Visualization
# ────────────────────────────────────────────────────────────────

def demo_energy_descent():
    print("\n" + "=" * 60)
    print("DEMO 2: Energy Descent Along Refinement Trajectories")
    print("=" * 60)

    sketches = [
        ("Deeply nested",
         Redundant(Redundant(Redundant(Redundant(
             Axiom(TheoremLabel.ParityLemma)))))),
        ("Duplicated chain",
         Duplicate(Duplicate(Duplicate(
             Axiom(TheoremLabel.DvdTrans))))),
        ("Mixed bloat",
         Lemma(TheoremLabel.EvenPlusEvenEven,
             Redundant(Duplicate(
                 Lemma(TheoremLabel.DvdTrans,
                     Axiom(TheoremLabel.ParityLemma)))))),
    ]

    for name, sketch in sketches:
        chain = refinement_chain(sketch)
        scores = [score(p) for p in chain]
        print(f"\n  {name}:")
        print(f"    Energy trajectory: {' → '.join(map(str, scores))}")
        print(f"    Total energy dissipated: {scores[0] - scores[-1]}")
        print(f"    Steps to normal form: {len(chain) - 1}")
        # Verify strict descent
        for i in range(len(scores) - 1):
            assert scores[i] > scores[i+1], "Energy must strictly decrease!"
        print(f"    ✓ Strict energy descent verified (discrete Lyapunov)")


# ────────────────────────────────────────────────────────────────
# Demo: Normal-Form Uniqueness Conjecture Test
# ────────────────────────────────────────────────────────────────

def generate_sketches(max_depth: int, labels: list[TheoremLabel]) -> list[ProofSketch]:
    """Generate all proof sketches up to given depth."""
    if max_depth == 0:
        return [Axiom(l) for l in labels]

    smaller = generate_sketches(max_depth - 1, labels)
    result = list(smaller)

    for p in smaller:
        result.append(Redundant(p))
        result.append(Duplicate(p))
        for l in labels:
            result.append(Lemma(l, p))

    for p1 in smaller:
        for p2 in smaller:
            result.append(Trans(p1, p2))
            result.append(Cases(p1, p2))

    return result


def sketch_to_tuple(p: ProofSketch) -> tuple:
    """Convert sketch to hashable tuple for comparison."""
    if isinstance(p, Axiom): return ('A', p.label)
    if isinstance(p, Lemma): return ('L', p.label, sketch_to_tuple(p.sub))
    if isinstance(p, Trans): return ('T', sketch_to_tuple(p.left), sketch_to_tuple(p.right))
    if isinstance(p, Cases): return ('C', sketch_to_tuple(p.left), sketch_to_tuple(p.right))
    if isinstance(p, Redundant): return ('R', sketch_to_tuple(p.inner))
    if isinstance(p, Duplicate): return ('D', sketch_to_tuple(p.inner))
    raise TypeError


def demo_uniqueness_conjecture():
    print("\n" + "=" * 60)
    print("DEMO 3: Normal-Form Uniqueness Conjecture Test")
    print("=" * 60)

    labels = [TheoremLabel.IrrationalSqrt2, TheoremLabel.EvenPlusEvenEven]

    for max_d in range(1, 4):
        sketches = generate_sketches(max_d, labels)
        # Group by semantics
        groups: dict[TheoremLabel, set] = {}
        for p in sketches:
            nf = normalize(p)
            nf_key = sketch_to_tuple(nf)
            s = sem(p)
            if s not in groups:
                groups[s] = set()
            groups[s].add(nf_key)

        print(f"\n  Depth ≤ {max_d}: {len(sketches)} sketches generated")
        unique = True
        for label, nfs in groups.items():
            print(f"    {label!r}: {len(nfs)} distinct normal form(s)")
            if len(nfs) > 1:
                unique = False
        if unique:
            print(f"    ✓ Uniqueness conjecture holds at depth ≤ {max_d}")
        else:
            print(f"    ✗ Uniqueness conjecture FAILS at depth ≤ {max_d}")
            print(f"      (This is expected: Trans/Cases create distinct normal forms)")


# ────────────────────────────────────────────────────────────────
# Demo: Lexicographic vs Scalar Score
# ────────────────────────────────────────────────────────────────

def demo_lex_vs_scalar():
    print("\n" + "=" * 60)
    print("DEMO 4: Lexicographic vs Scalar Complexity")
    print("=" * 60)

    c1 = (2, 0, 1)  # score = 3
    c2 = (1, 1, 1)  # score = 3

    print(f"\n  c₁ = {c1}, score = {sum(c1)}")
    print(f"  c₂ = {c2}, score = {sum(c2)}")
    print(f"  Scores equal: {sum(c1) == sum(c2)}")
    print(f"  c₂ <_lex c₁: {c2[0] < c1[0]} (length {c2[0]} < {c1[0]})")
    print(f"\n  → Lexicographic order detects simplification that")
    print(f"    scalar score misses! This is the separation theorem.")


# ────────────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║          PROOF DYNAMICS — Interactive Demo              ║")
    print("║   A Formal Theory of Proof Descent & Normal Forms      ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_sqrt2()
    demo_energy_descent()
    demo_lex_vs_scalar()
    demo_uniqueness_conjecture()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Complexity Space and Lexicographic vs Scalar Order

Illustrates the three-dimensional complexity space (length, depth, lemmaCount)
and shows how lexicographic ordering provides finer discrimination than
scalar score. Points with equal scalar score but different lex ordering
are highlighted — this is the separation theorem in action.
"""

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np


# ── Generate complexity points ──────────────────────────────────

# All complexity triples with score ≤ 8
points = []
for l in range(9):
    for d in range(9 - l):
        for lc in range(9 - l - d):
            points.append((l, d, lc))

points = np.array(points)
scores = points.sum(axis=1)

# ── Create figure ───────────────────────────────────────────────

fig = plt.figure(figsize=(16, 6))

# Panel 1: 3D scatter colored by score
ax1 = fig.add_subplot(121, projection='3d')
sc = ax1.scatter(points[:, 0], points[:, 1], points[:, 2],
                  c=scores, cmap='viridis', s=40, alpha=0.7,
                  edgecolors='black', linewidth=0.3)
plt.colorbar(sc, ax=ax1, label='Scalar Score', shrink=0.6)
ax1.set_xlabel('Length')
ax1.set_ylabel('Depth')
ax1.set_zlabel('Lemma Count')
ax1.set_title('Complexity Space\n(colored by scalar score)', fontsize=13,
              fontweight='bold')

# Highlight the separation pair
c1 = np.array([2, 0, 1])
c2 = np.array([1, 1, 1])
ax1.scatter(*c1, color='red', s=200, marker='*', zorder=5,
            edgecolors='black', linewidth=1.5)
ax1.scatter(*c2, color='blue', s=200, marker='*', zorder=5,
            edgecolors='black', linewidth=1.5)
# Draw arrow from c1 to c2
ax1.plot([c1[0], c2[0]], [c1[1], c2[1]], [c1[2], c2[2]],
         'r--', linewidth=2, alpha=0.8)
ax1.text(c1[0]+0.2, c1[1]-0.3, c1[2]+0.3, 'c₁=(2,0,1)\nscore=3',
         fontsize=8, color='red')
ax1.text(c2[0]-0.5, c2[1]+0.3, c2[2]+0.3, 'c₂=(1,1,1)\nscore=3',
         fontsize=8, color='blue')

# Panel 2: 2D projection showing iso-score lines
ax2 = fig.add_subplot(122)

# Plot iso-score curves
for s in range(1, 9):
    iso_points = points[scores == s]
    if len(iso_points) > 0:
        ax2.scatter(iso_points[:, 0], iso_points[:, 1],
                    s=30 + 5*s, alpha=0.5, label=f'score={s}' if s <= 5 else None)

# Highlight separation pair
ax2.scatter(2, 0, color='red', s=200, marker='*', zorder=5,
            edgecolors='black', linewidth=1.5)
ax2.scatter(1, 1, color='blue', s=200, marker='*', zorder=5,
            edgecolors='black', linewidth=1.5)
ax2.annotate('c₁=(2,0,1)', (2, 0), textcoords="offset points",
             xytext=(10, -15), fontsize=10, color='red', fontweight='bold')
ax2.annotate('c₂=(1,1,1)', (1, 1), textcoords="offset points",
             xytext=(10, 10), fontsize=10, color='blue', fontweight='bold')

# Draw arrow showing lex direction
ax2.annotate('', xy=(1, 1), xytext=(2, 0),
             arrowprops=dict(arrowstyle='->', color='purple', lw=2))
ax2.text(1.7, 0.7, 'Lex\ndescent', fontsize=9, color='purple',
         ha='center', fontweight='bold')

ax2.set_xlabel('Length', fontsize=13)
ax2.set_ylabel('Depth', fontsize=13)
ax2.set_title('Iso-Score Manifolds\n(same score, different lex order)',
              fontsize=13, fontweight='bold')
ax2.legend(fontsize=8, loc='upper right')
ax2.grid(True, alpha=0.3)

# Add text box explaining the separation theorem
textstr = ('Separation Theorem:\n'
           'c₁ and c₂ have equal score (3)\n'
           'but c₂ <_lex c₁\n'
           '→ Lex order detects finer\n'
           '   simplification structure')
props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
ax2.text(0.02, 0.98, textstr, transform=ax2.transAxes, fontsize=9,
         verticalalignment='top', bbox=props)

plt.tight_layout()
plt.savefig('viz_complexity_space.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_space.png")


#!/usr/bin/env python3
"""
Visualization: Proof Energy Landscape

Visualizes the energy descent along proof refinement trajectories,
showing how complexity monotonically decreases like a physical system
cooling to its ground state. Multiple proof sketches are shown as
separate trajectories converging toward minimal-energy normal forms.

This demonstrates the discrete Lyapunov theorem: no periodic orbits
exist because energy strictly decreases at each refinement step.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass
from typing import Optional


# ── Self-contained proof sketch implementation ────────────────

class TheoremLabel(Enum):
    IrrationalSqrt2 = auto()
    EvenPlusEvenEven = auto()
    DvdTrans = auto()
    ParityLemma = auto()

@dataclass
class ProofSketch: pass

@dataclass
class Axiom(ProofSketch):
    label: TheoremLabel

@dataclass
class Lemma(ProofSketch):
    label: TheoremLabel
    sub: ProofSketch

@dataclass
class Trans(ProofSketch):
    left: ProofSketch
    right: ProofSketch

@dataclass
class Cases(ProofSketch):
    left: ProofSketch
    right: ProofSketch

@dataclass
class Redundant(ProofSketch):
    inner: ProofSketch

@dataclass
class Duplicate(ProofSketch):
    inner: ProofSketch

def size(p):
    if isinstance(p, Axiom): return 1
    if isinstance(p, Lemma): return 1 + size(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + size(p.left) + size(p.right)
    if isinstance(p, (Redundant, Duplicate)): return 1 + size(p.inner)

def depth(p):
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + depth(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + max(depth(p.left), depth(p.right))
    if isinstance(p, (Redundant, Duplicate)): return 1 + depth(p.inner)

def lemma_count(p):
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + lemma_count(p.sub)
    if isinstance(p, (Trans, Cases)): return lemma_count(p.left) + lemma_count(p.right)
    if isinstance(p, (Redundant, Duplicate)): return lemma_count(p.inner)

def score(p): return size(p) + depth(p) + lemma_count(p)

def step_once(p):
    if isinstance(p, Redundant): return p.inner
    if isinstance(p, Duplicate): return p.inner
    if isinstance(p, Lemma):
        if isinstance(p.sub, Redundant): return Lemma(p.label, p.sub.inner)
        if isinstance(p.sub, Axiom): return Axiom(p.label)
        s = step_once(p.sub)
        return Lemma(p.label, s) if s else None
    if isinstance(p, Trans):
        s = step_once(p.left)
        if s: return Trans(s, p.right)
        s = step_once(p.right)
        return Trans(p.left, s) if s else None
    if isinstance(p, Cases):
        s = step_once(p.left)
        if s: return Cases(s, p.right)
        s = step_once(p.right)
        return Cases(p.left, s) if s else None
    return None

def get_scores(p):
    scores = [score(p)]
    while True:
        nxt = step_once(p)
        if nxt is None: return scores
        p = nxt
        scores.append(score(p))


# ── Build trajectories ───────────────────────────────────────

trajectories = {
    "√2 bloated": Redundant(Duplicate(Redundant(
        Lemma(TheoremLabel.IrrationalSqrt2,
            Trans(Redundant(Axiom(TheoremLabel.EvenPlusEvenEven)),
                  Duplicate(Axiom(TheoremLabel.DvdTrans))))))),
    "Deep nesting": Redundant(Redundant(Redundant(Redundant(
        Redundant(Axiom(TheoremLabel.ParityLemma)))))),
    "Duplicate chain": Duplicate(Duplicate(Duplicate(
        Axiom(TheoremLabel.DvdTrans)))),
    "Mixed": Lemma(TheoremLabel.EvenPlusEvenEven,
        Redundant(Duplicate(
            Lemma(TheoremLabel.DvdTrans,
                Axiom(TheoremLabel.ParityLemma))))),
}


# ── Create figure ─────────────────────────────────────────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

# Left panel: Energy trajectories
for (name, sketch), color in zip(trajectories.items(), colors):
    scores = get_scores(sketch)
    steps = list(range(len(scores)))
    ax1.plot(steps, scores, 'o-', color=color, linewidth=2,
             markersize=8, label=name, alpha=0.85)
    # Mark normal form (ground state)
    ax1.plot(steps[-1], scores[-1], 's', color=color,
             markersize=12, markeredgecolor='black', markeredgewidth=1.5,
             zorder=5)

ax1.set_xlabel('Refinement Step', fontsize=13)
ax1.set_ylabel('Energy (Complexity Score)', fontsize=13)
ax1.set_title('Energy Descent: Proof Refinement Trajectories', fontsize=14,
              fontweight='bold')
ax1.legend(fontsize=10, loc='upper right')
ax1.grid(True, alpha=0.3)
ax1.set_ylim(bottom=0)

# Annotate ground state region
ax1.axhspan(0, 2, color='#2ecc71', alpha=0.1)
ax1.text(0.5, 1.5, 'Ground States\n(Normal Forms)', fontsize=9,
         ha='center', style='italic', color='#27ae60')

# Right panel: Energy drops per step (bar chart)
ax2_data = []
for (name, sketch), color in zip(trajectories.items(), colors):
    scores = get_scores(sketch)
    drops = [scores[i] - scores[i+1] for i in range(len(scores)-1)]
    ax2_data.append((name, drops, color))

max_steps = max(len(d[1]) for d in ax2_data)
bar_width = 0.2
for idx, (name, drops, color) in enumerate(ax2_data):
    x = np.arange(len(drops)) + idx * bar_width
    ax2.bar(x, drops, bar_width, color=color, alpha=0.7,
            label=name, edgecolor='black', linewidth=0.5)

ax2.set_xlabel('Step Index', fontsize=13)
ax2.set_ylabel('Energy Drop (ΔE)', fontsize=13)
ax2.set_title('Energy Dissipation per Step', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3, axis='y')

# Annotate: all drops > 0 ⟹ Lyapunov
ax2.text(0.98, 0.95, 'All ΔE > 0 ⟹ Lyapunov\n(no periodic orbits)',
         transform=ax2.transAxes, fontsize=9, ha='right', va='top',
         style='italic', color='#c0392b',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='#fadbd8', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Proof Refinement Tree

Shows the tree structure of a proof sketch before and after normalization,
with nodes colored by type. Demonstrates how refinement strips away
redundant and duplicate wrappers while preserving the essential structure.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from enum import Enum, auto
from dataclasses import dataclass


# ── Self-contained proof sketch types ────────────────────────

class TheoremLabel(Enum):
    IrrationalSqrt2 = auto()
    EvenPlusEvenEven = auto()
    DvdTrans = auto()
    ParityLemma = auto()

@dataclass
class ProofSketch: pass
@dataclass
class Axiom(ProofSketch):
    label: TheoremLabel
@dataclass
class Lemma(ProofSketch):
    label: TheoremLabel
    sub: ProofSketch
@dataclass
class Trans(ProofSketch):
    left: ProofSketch
    right: ProofSketch
@dataclass
class Cases(ProofSketch):
    left: ProofSketch
    right: ProofSketch
@dataclass
class Redundant(ProofSketch):
    inner: ProofSketch
@dataclass
class Duplicate(ProofSketch):
    inner: ProofSketch

def step_once(p):
    if isinstance(p, Redundant): return p.inner
    if isinstance(p, Duplicate): return p.inner
    if isinstance(p, Lemma):
        if isinstance(p.sub, Redundant): return Lemma(p.label, p.sub.inner)
        if isinstance(p.sub, Axiom): return Axiom(p.label)
        s = step_once(p.sub)
        return Lemma(p.label, s) if s else None
    if isinstance(p, Trans):
        s = step_once(p.left)
        if s: return Trans(s, p.right)
        s = step_once(p.right)
        return Trans(p.left, s) if s else None
    if isinstance(p, Cases):
        s = step_once(p.left)
        if s: return Cases(s, p.right)
        s = step_once(p.right)
        return Cases(p.left, s) if s else None
    return None

def normalize(p):
    while True:
        nxt = step_once(p)
        if nxt is None: return p
        p = nxt

def score(p):
    if isinstance(p, Axiom): return 1
    if isinstance(p, Lemma): return 2 + score(p.sub) + 1
    if isinstance(p, (Trans, Cases)): return 1 + score(p.left) + score(p.right) + 1 + max(
        _depth(p.left), _depth(p.right))
    if isinstance(p, (Redundant, Duplicate)): return 2 + score(p.inner)

def _depth(p):
    if isinstance(p, Axiom): return 0
    if isinstance(p, Lemma): return 1 + _depth(p.sub)
    if isinstance(p, (Trans, Cases)): return 1 + max(_depth(p.left), _depth(p.right))
    if isinstance(p, (Redundant, Duplicate)): return 1 + _depth(p.inner)


# ── Tree layout algorithm ────────────────────────────────────

NODE_COLORS = {
    'Axiom': '#2ecc71',
    'Lemma': '#3498db',
    'Trans': '#f39c12',
    'Cases': '#9b59b6',
    'Redundant': '#e74c3c',
    'Duplicate': '#e67e22',
}

def node_type(p):
    return type(p).__name__

def node_label(p):
    if isinstance(p, Axiom): return f"Ax\n{p.label.name[:6]}"
    if isinstance(p, Lemma): return f"Lem\n{p.label.name[:6]}"
    if isinstance(p, Trans): return "Trans"
    if isinstance(p, Cases): return "Cases"
    if isinstance(p, Redundant): return "Redun."
    if isinstance(p, Duplicate): return "Dupl."
    return "?"

def children(p):
    if isinstance(p, Axiom): return []
    if isinstance(p, Lemma): return [p.sub]
    if isinstance(p, (Trans, Cases)): return [p.left, p.right]
    if isinstance(p, (Redundant, Duplicate)): return [p.inner]
    return []

def layout_tree(p, x=0, y=0, dx=1.0, positions=None, edges=None, node_id=None):
    """Compute positions for tree nodes."""
    if positions is None: positions = {}
    if edges is None: edges = []
    if node_id is None: node_id = [0]

    my_id = node_id[0]
    node_id[0] += 1
    positions[my_id] = (x, y, p)

    kids = children(p)
    if not kids:
        return positions, edges

    n = len(kids)
    start_x = x - dx * (n - 1) / 2
    for i, child in enumerate(kids):
        child_id = node_id[0]
        edges.append((my_id, child_id))
        layout_tree(child, start_x + i * dx, y - 1.2, dx * 0.5,
                     positions, edges, node_id)

    return positions, edges


def draw_tree(ax, p, title=""):
    """Draw a proof sketch tree on the given axes."""
    positions, edges = layout_tree(p)

    # Draw edges
    for parent_id, child_id in edges:
        px, py, _ = positions[parent_id]
        cx, cy, _ = positions[child_id]
        ax.plot([px, cx], [py, cy], 'k-', linewidth=1.5, alpha=0.4)

    # Draw nodes
    for nid, (x, y, node) in positions.items():
        nt = node_type(node)
        color = NODE_COLORS.get(nt, '#bdc3c7')
        circle = plt.Circle((x, y), 0.35, color=color, ec='black',
                             linewidth=1.5, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y, node_label(node), ha='center', va='center',
                fontsize=7, fontweight='bold', zorder=4)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')


# ── Create visualization ─────────────────────────────────────

# Example proof sketch
original = Redundant(Duplicate(
    Lemma(TheoremLabel.IrrationalSqrt2,
        Trans(
            Redundant(Axiom(TheoremLabel.EvenPlusEvenEven)),
            Duplicate(Axiom(TheoremLabel.DvdTrans))
        ))))

normalized = normalize(original)

fig, axes = plt.subplots(1, 2, figsize=(14, 7))

draw_tree(axes[0], original, "Before Refinement\n(bloated, score=16)")
axes[0].set_xlim(-3, 3)
axes[0].set_ylim(-6.5, 1)

draw_tree(axes[1], normalized, "After Refinement\n(normal form, score=7)")
axes[1].set_xlim(-3, 3)
axes[1].set_ylim(-6.5, 1)

# Add arrow between panels
fig.patches.append(mpatches.FancyArrowPatch(
    (0.48, 0.5), (0.52, 0.5),
    transform=fig.transFigure,
    arrowstyle='->', mutation_scale=30,
    color='#c0392b', linewidth=3))

fig.text(0.5, 0.55, 'Normalize', ha='center', fontsize=14,
         fontweight='bold', color='#c0392b', transform=fig.transFigure)

# Legend
legend_patches = [mpatches.Patch(color=c, label=n)
                  for n, c in NODE_COLORS.items()]
fig.legend(handles=legend_patches, loc='lower center', ncol=6,
           fontsize=10, framealpha=0.9)

plt.suptitle('Proof Tree Simplification via Refinement Dynamics',
             fontsize=15, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0.08, 1, 0.95])
plt.savefig('viz_refinement_tree.png', dpi=150, bbox_inches='tight')
print("Saved viz_refinement_tree.png")
