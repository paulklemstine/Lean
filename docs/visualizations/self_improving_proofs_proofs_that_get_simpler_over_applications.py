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
