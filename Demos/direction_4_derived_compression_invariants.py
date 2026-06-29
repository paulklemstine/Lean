#!/usr/bin/env python3
"""
Applications of Derived Compression Invariants

Demonstrates real-world applications of the cohomological compression theory:
1. Data compression quality analysis
2. Distributed storage consistency detection
3. Multi-format media compression comparison
4. Network compression pipeline optimization
"""

from typing import List, Dict, Tuple
from algorithms import kappa1, kappa2, analyze_filtration, compression_spectrum


# ─── Application 1: Data Compression Quality ────────────────────────

def compression_quality_analysis():
    """Analyze compression quality across different data types.

    Uses κ¹ to detect where joint compression outperforms independent
    compression (non-additivity), analogous to mutual information.
    """
    print("=" * 60)
    print("APPLICATION 1: Compression Quality Analysis")
    print("=" * 60)

    # Simulated compression ratios for different data types
    data_types = {
        "JSON":     {"raw": 10000, "gzip": 2000, "brotli": 1500},
        "CSV":      {"raw": 8000,  "gzip": 1800, "brotli": 1200},
        "Images":   {"raw": 50000, "gzip": 48000, "brotli": 47000},
        "Logs":     {"raw": 20000, "gzip": 3000, "brotli": 2500},
        "Binary":   {"raw": 15000, "gzip": 14000, "brotli": 13500},
    }

    print("\n  Data type compression comparison (gzip):")
    print(f"  {'Type A':>10} {'Type B':>10} {'Joint':>8} {'κ¹':>6} {'Interpretation'}")
    print("  " + "-" * 55)

    types = list(data_types.keys())
    for i, tA in enumerate(types):
        for tB in types[i + 1:]:
            kA = data_types[tA]["gzip"]
            kB = data_types[tB]["gzip"]
            # Joint compression is typically better than sum (synergy)
            kJoint = int((kA + kB) * 0.85)  # 15% synergy
            k1 = kappa1(kA, kJoint, kB)
            interp = "high synergy" if k1 > 500 else "moderate" if k1 > 100 else "low"
            print(f"  {tA:>10} {tB:>10} {kJoint:>8} {k1:>6}  {interp}")


# ─── Application 2: Distributed Storage ─────────────────────────────

def distributed_storage_consistency():
    """Detect compression consistency issues in distributed storage.

    In a distributed system, data is split across nodes. κ¹ measures
    whether the total compressed size equals the sum of parts —
    nonzero κ¹ indicates "compression coupling" between shards.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Distributed Storage Consistency")
    print("=" * 60)

    # Simulate a 3-node distributed database
    nodes = {
        "Node A (West)": {"raw": 1000, "compressed": 400},
        "Node B (East)": {"raw": 1200, "compressed": 500},
        "Node C (EU)":   {"raw": 800,  "compressed": 350},
    }

    print("\n  Node compression status:")
    total_compressed = 0
    for name, data in nodes.items():
        ratio = data["compressed"] / data["raw"]
        print(f"    {name}: {data['raw']}MB → {data['compressed']}MB ({ratio:.1%})")
        total_compressed += data["compressed"]

    # Global joint compression
    global_compressed = 1100  # Better than sum due to cross-node dedup
    k1_global = kappa1(total_compressed, global_compressed,
                        total_compressed)  # Simplified

    compressed_vals = [d["compressed"] for d in nodes.values()]
    k1_AB = kappa1(compressed_vals[0], 750, compressed_vals[1])
    k1_BC = kappa1(compressed_vals[1], 700, compressed_vals[2])
    k1_AC = kappa1(compressed_vals[0], 600, compressed_vals[2])

    print(f"\n  Pairwise compression coupling (κ¹):")
    print(f"    Nodes A-B: κ¹ = {k1_AB} (joint compressed = 750MB)")
    print(f"    Nodes B-C: κ¹ = {k1_BC} (joint compressed = 700MB)")
    print(f"    Nodes A-C: κ¹ = {k1_AC} (joint compressed = 600MB)")

    # Interpretation
    max_coupling = max(k1_AB, k1_BC, k1_AC)
    print(f"\n  Maximum coupling: {max_coupling}MB")
    print(f"  → This indicates {max_coupling}MB of redundant data")
    print(f"    could be eliminated by cross-node deduplication")


# ─── Application 3: Compression Pipeline ────────────────────────────

def compression_pipeline_optimization():
    """Optimize a multi-stage compression pipeline using filtration theory.

    A pipeline: Raw → Stage 1 → Stage 2 → Stage 3 → Final
    Each stage's κ¹ tells us how much "extra" compression it achieves
    beyond what's expected from the graded pieces.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Compression Pipeline Optimization")
    print("=" * 60)

    # Pipeline stages
    levels = [10000, 6000, 3500, 2000, 1500]  # Size after each stage
    graded = [5000, 3000, 2000, 800]  # Expected compression at each stage

    stage_names = [
        "Raw → Dedup",
        "Dedup → Dictionary",
        "Dictionary → Entropy",
        "Entropy → Final"
    ]

    analysis = analyze_filtration(levels, graded)

    print(f"\n  Pipeline analysis:")
    print(f"  {'Stage':<25} {'In':>6} {'Out':>6} {'Expected':>9} {'κ¹':>5} {'Status'}")
    print("  " + "-" * 58)

    for i in range(analysis.n):
        status = "✓ optimal" if analysis.step_defects[i] == 0 else \
                 "△ room to improve" if analysis.step_defects[i] > 0 else \
                 "✗ underperforming"
        print(f"  {stage_names[i]:<25} {levels[i]:>6} {levels[i+1]:>6} "
              f"{graded[i]:>9} {analysis.step_defects[i]:>5}  {status}")

    print(f"\n  Total pipeline defect: {analysis.total_defect}")
    print(f"  Telescoping check: {analysis.telescoping_verified}")
    if analysis.total_defect > 0:
        print(f"  → {analysis.total_defect} units of compression potential remain")


# ─── Application 4: Multi-Format Comparison ─────────────────────────

def multiformat_comparison():
    """Compare compression across multiple formats using spectrum analysis."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Multi-Format Spectrum Analysis")
    print("=" * 60)

    formats = {
        "gzip":   [400, 500, 350, 600, 450],
        "brotli": [350, 420, 300, 550, 380],
        "zstd":   [370, 460, 320, 570, 410],
        "lz4":    [500, 600, 450, 700, 550],
    }

    for fmt, compressed in formats.items():
        spec = compression_spectrum(compressed)
        print(f"\n  {fmt.upper()} format:")
        print(f"    Compressed sizes: {compressed}")
        print(f"    Valid triples: {spec.valid_triples}, Split: {spec.split_triples}")
        print(f"    Max κ¹: {spec.max_defect}")
        print(f"    Additivity rate: {spec.split_triples/max(spec.valid_triples,1):.1%}")


# ─── Main ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  Derived Compression: Real-World Applications           ║")
    print("╚" + "═" * 58 + "╝")

    compression_quality_analysis()
    distributed_storage_consistency()
    compression_pipeline_optimization()
    multiformat_comparison()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Derived Compression Invariants — Interactive Demonstration

Computes κ⁰, κ¹, and κ² on finite compression systems, demonstrating:
1. Nonnegativity of κ¹ under subadditivity
2. Vanishing of κ¹ on split extensions
3. Universal vanishing of κ² (iterated defect)
4. Filtration telescoping identity
5. Split vs. non-split behavior
"""

from typing import List, Tuple, Dict, Optional
import itertools


# ─── Core definitions ───────────────────────────────────────────────

def kappa1(kA: int, kB: int, kQ: int) -> int:
    """First derived compression invariant κ¹ = κ(A) + κ(Q) - κ(B)."""
    return kA + kQ - kB


def kappa2(k0: int, k1: int, k2: int, k3: int, k4: int) -> int:
    """Second derived compression invariant κ².
    κ² = κ¹(e₁) + κ¹(e₂) - κ¹(composite)."""
    return kappa1(k0, k1, k2) + kappa1(k1, k3, k4) - kappa1(k0, k3, k2 + k4)


def total_filtration_defect(levels: List[int], graded: List[int]) -> int:
    """Total defect ∑ κ¹(Eᵢ) of a filtration."""
    n = len(graded)
    assert len(levels) == n + 1
    return sum(kappa1(levels[i], levels[i + 1], graded[i]) for i in range(n))


# ─── Finite compression system ──────────────────────────────────────

class CompressionSystem:
    """A finite compression system with objects having size and compressed size."""

    def __init__(self, sizes: List[int], compressed: List[int]):
        assert len(sizes) == len(compressed)
        assert all(c <= s for s, c in zip(sizes, compressed))
        self.n = len(sizes)
        self.sizes = sizes
        self.compressed = compressed

    def defect(self, i: int) -> int:
        """Compression defect of element i: size - compressed."""
        return self.sizes[i] - self.compressed[i]

    def kappa1_triple(self, iA: int, iB: int, iQ: int) -> Optional[int]:
        """κ¹ for a triple (A, B, Q), or None if subadditivity fails."""
        kA, kB, kQ = self.compressed[iA], self.compressed[iB], self.compressed[iQ]
        if kB <= kA + kQ:
            return kappa1(kA, kB, kQ)
        return None

    def all_valid_triples(self) -> List[Tuple[int, int, int, int]]:
        """All (iA, iB, iQ, κ¹) where subadditivity holds."""
        results = []
        for iA, iB, iQ in itertools.product(range(self.n), repeat=3):
            k = self.kappa1_triple(iA, iB, iQ)
            if k is not None:
                results.append((iA, iB, iQ, k))
        return results


# ─── Demonstrations ─────────────────────────────────────────────────

def demo_basic_kappa1():
    """Demonstrate κ¹ on simple examples."""
    print("=" * 60)
    print("DEMO 1: Basic κ¹ Computation")
    print("=" * 60)

    examples = [
        ("Split extension", 10, 15, 5),
        ("Non-split (subadditive)", 10, 12, 5),
        ("Maximally non-additive", 10, 1, 5),
        ("Symmetric test", 7, 10, 7),
    ]

    for name, kA, kB, kQ in examples:
        k1 = kappa1(kA, kB, kQ)
        is_sub = kB <= kA + kQ
        print(f"\n  {name}:")
        print(f"    κ(A)={kA}, κ(B)={kB}, κ(Q)={kQ}")
        print(f"    κ¹ = {kA} + {kQ} - {kB} = {k1}")
        print(f"    Subadditive: {is_sub} → κ¹ ≥ 0: {k1 >= 0}")
        if kB == kA + kQ:
            print(f"    ✓ Split (κ(B) = κ(A) + κ(Q)), so κ¹ = 0")


def demo_split_vanishing():
    """Demonstrate that κ¹ vanishes on split extensions."""
    print("\n" + "=" * 60)
    print("DEMO 2: Split Vanishing — κ¹ = 0 iff Additive")
    print("=" * 60)

    print("\n  Testing all (κA, κQ) pairs with κA, κQ ∈ {1..5}:")
    all_vanish = True
    for kA in range(1, 6):
        for kQ in range(1, 6):
            kB_split = kA + kQ  # split: κ(B) = κ(A) + κ(Q)
            k1 = kappa1(kA, kB_split, kQ)
            if k1 != 0:
                all_vanish = False
                print(f"    COUNTEREXAMPLE: κA={kA}, κQ={kQ}, κ¹={k1}")

    if all_vanish:
        print("    ✓ All split extensions have κ¹ = 0 (25/25 cases)")


def demo_kappa2_universal_vanishing():
    """Demonstrate that κ² vanishes universally."""
    print("\n" + "=" * 60)
    print("DEMO 3: Universal Vanishing of κ²")
    print("=" * 60)

    count = 0
    violations = 0
    for k0, k1, k2, k3, k4 in itertools.product(range(-3, 4), repeat=5):
        k2_val = kappa2(k0, k1, k2, k3, k4)
        count += 1
        if k2_val != 0:
            violations += 1
            print(f"    COUNTEREXAMPLE: ({k0},{k1},{k2},{k3},{k4}) → κ²={k2_val}")

    print(f"\n  Tested {count} quintuplets in [-3, 3]⁵")
    if violations == 0:
        print(f"  ✓ κ² = 0 in ALL cases — universal vanishing confirmed")
    else:
        print(f"  ✗ Found {violations} violations")


def demo_finite_system():
    """Demonstrate κ¹ on a concrete finite compression system."""
    print("\n" + "=" * 60)
    print("DEMO 4: Finite Compression System")
    print("=" * 60)

    sizes =      [100, 200, 150, 80,  300]
    compressed = [40,  90,  70,  35,  120]
    names = ["Text", "Image", "Audio", "Config", "Video"]

    sys = CompressionSystem(sizes, compressed)

    print("\n  Objects:")
    for i in range(sys.n):
        d = sys.defect(i)
        ratio = compressed[i] / sizes[i]
        print(f"    {names[i]:8s}: size={sizes[i]:3d}, compressed={compressed[i]:3d}, "
              f"defect={d:3d}, ratio={ratio:.2f}")

    print("\n  Extension data (subadditive triples) with κ¹ > 0:")
    triples = sys.all_valid_triples()
    nonzero = [(a, b, q, k) for a, b, q, k in triples if k > 0]
    for iA, iB, iQ, k1 in sorted(nonzero, key=lambda x: -x[3])[:10]:
        print(f"    {names[iA]:8s} → {names[iB]:8s} → {names[iQ]:8s}: κ¹ = {k1}")

    split_count = sum(1 for _, _, _, k in triples if k == 0)
    print(f"\n  Split triples (κ¹ = 0): {split_count}/{len(triples)}")
    print(f"  Non-split triples (κ¹ > 0): {len(triples) - split_count}/{len(triples)}")


def demo_filtration_telescoping():
    """Demonstrate the telescoping identity for filtrations."""
    print("\n" + "=" * 60)
    print("DEMO 5: Filtration Telescoping Identity")
    print("=" * 60)

    # Example: filtration with 4 levels
    levels = [5, 12, 18, 30]  # κ(F₀), κ(F₁), κ(F₂), κ(F₃)
    graded = [8, 9, 15]       # κ(gr₁), κ(gr₂), κ(gr₃)

    print(f"\n  Filtration levels:  {levels}")
    print(f"  Graded pieces:     {graded}")
    print(f"\n  Step defects:")

    total = total_filtration_defect(levels, graded)
    for i in range(len(graded)):
        k = kappa1(levels[i], levels[i + 1], graded[i])
        sub = levels[i + 1] <= levels[i] + graded[i]
        print(f"    Step {i}: κ¹ = κ(F{i}) + κ(gr{i}) - κ(F{i+1}) "
              f"= {levels[i]} + {graded[i]} - {levels[i+1]} = {k}  "
              f"(sub: {sub})")

    rhs = levels[0] + sum(graded) - levels[-1]
    print(f"\n  Total defect (sum): {total}")
    print(f"  Telescoping formula: κ(F₀) + Σκ(grᵢ) - κ(Fₙ) = "
          f"{levels[0]} + {sum(graded)} - {levels[-1]} = {rhs}")
    print(f"  ✓ Match: {total == rhs}")

    # Check subadditivity and nonnegativity
    all_sub = all(levels[i + 1] <= levels[i] + graded[i] for i in range(len(graded)))
    print(f"\n  All steps subadditive: {all_sub}")
    if all_sub:
        print(f"  → Total defect ≥ 0: {total >= 0} ✓")


def demo_conjecture_test():
    """Test the split-detection conjecture on small examples."""
    print("\n" + "=" * 60)
    print("DEMO 6: Split-Detection Conjecture Test")
    print("=" * 60)
    print("\n  Conjecture: κ¹(E) = 0 iff E is 'compression-split'")
    print("  (i.e., κ(B) = κ(A) + κ(Q))")

    count = 0
    forward_violations = 0
    backward_violations = 0

    for kA in range(0, 8):
        for kQ in range(0, 8):
            for kB in range(0, kA + kQ + 1):  # subadditive range
                k1 = kappa1(kA, kB, kQ)
                is_split = (kB == kA + kQ)
                count += 1
                if k1 == 0 and not is_split:
                    forward_violations += 1
                if is_split and k1 != 0:
                    backward_violations += 1

    print(f"\n  Tested {count} subadditive triples with κA, κQ ∈ [0,7]")
    print(f"  Forward violations (κ¹=0 but not split): {forward_violations}")
    print(f"  Backward violations (split but κ¹≠0):    {backward_violations}")
    if forward_violations == 0 and backward_violations == 0:
        print("  ✓ Conjecture CONFIRMED on all test cases")
    elif backward_violations == 0 and forward_violations > 0:
        print("  ✗ Backward direction holds, forward fails")
        print("    → κ¹ = 0 does NOT imply split")


def demo_euler_characteristic():
    """Demonstrate the Euler characteristic / defect duality."""
    print("\n" + "=" * 60)
    print("DEMO 7: Euler-Defect Duality")
    print("=" * 60)

    # Length-1 filtration
    for l0, l1, g0 in [(3, 8, 7), (5, 5, 0), (10, 15, 10), (0, 3, 5)]:
        total = kappa1(l0, l1, g0)
        formula = l0 + g0 - l1
        print(f"\n  F₀={l0}, F₁={l1}, gr₀={g0}")
        print(f"    totalDefect = {total}")
        print(f"    κ(F₀) + κ(gr₀) - κ(F₁) = {l0} + {g0} - {l1} = {formula}")
        print(f"    Match: {total == formula} ✓" if total == formula else f"    MISMATCH!")


if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  DERIVED COMPRESSION INVARIANTS — Interactive Demo       ║")
    print("║  Cohomological Obstruction Theory for Compression        ║")
    print("╚" + "═" * 58 + "╝")

    demo_basic_kappa1()
    demo_split_vanishing()
    demo_kappa2_universal_vanishing()
    demo_finite_system()
    demo_filtration_telescoping()
    demo_conjecture_test()
    demo_euler_characteristic()

    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)
