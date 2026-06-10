#!/usr/bin/env python3
"""
Berggren–Hecke Spectral Reconstruction: Applications

Real-world applications of the spectral reconstruction theory:
1. Arithmetic signal processing on Pythagorean triple spaces
2. Hidden period detection in tree-structured data
3. Compressed representation of tree-periodic functions
"""

import numpy as np
from itertools import product
from typing import Dict, List, Tuple

from algorithms import (
    berggren_eval_matrix, generate_berggren_tree, HeckeAlgebra,
    detect_branch_period, certified_reconstruction, factor_through_quotient,
    compute_residue_classes, group_by_residue
)


# ============================================================
# Application 1: Arithmetic Signal Processing
# ============================================================

def arithmetic_signal_processing():
    """
    Demonstrate arithmetic signal processing on the Berggren tree.

    We define signals that encode arithmetic properties of Pythagorean
    triples (e.g., parity of legs, primality of hypotenuse) and show
    that the Hecke averaging operator reveals global statistical
    properties of these arithmetic signals.
    """
    print("=" * 60)
    print("Application 1: Arithmetic Signal Processing")
    print("=" * 60)

    max_depth = 4
    tree = generate_berggren_tree(max_depth)

    # Signal 1: Parity signal — is the first leg odd?
    parity_signal = {}
    for w, t in tree.items():
        parity_signal[w] = 1.0 if int(t[0]) % 2 == 1 else 0.0

    # Analyze by depth
    for depth in range(max_depth + 1):
        words = [w for w in tree if len(w) == depth]
        if not words:
            continue
        vals = [parity_signal[w] for w in words]
        print(f"  Depth {depth}: {len(words)} triples, "
              f"fraction with odd first leg: {np.mean(vals):.4f}")

    # Signal 2: Hypotenuse divisibility by small primes
    print("\n  Hypotenuse divisibility analysis:")
    for p in [5, 13, 17, 29]:
        divisible = sum(1 for w, t in tree.items() if int(t[2]) % p == 0)
        print(f"  Divisible by {p}: {divisible}/{len(tree)} = "
              f"{divisible/len(tree):.4f}")

    # Signal 3: Leg ratio signal
    print("\n  Leg ratio analysis (a/c) by depth:")
    for depth in range(max_depth + 1):
        words = [w for w in tree if len(w) == depth]
        if not words:
            continue
        ratios = [float(tree[w][0]) / float(tree[w][2]) for w in words]
        print(f"  Depth {depth}: mean a/c = {np.mean(ratios):.4f}, "
              f"std = {np.std(ratios):.4f}")


# ============================================================
# Application 2: Hidden Period Detection in Tree Data
# ============================================================

def hidden_period_detection():
    """
    Detect hidden periodic structure in tree-indexed data.

    This simulates a scenario where data is indexed by a tree
    (e.g., hierarchical database entries, decision tree paths)
    and we want to discover if the data has a periodic pattern
    in the tree coordinates.
    """
    print("\n" + "=" * 60)
    print("Application 2: Hidden Period Detection")
    print("=" * 60)

    n = 5  # Tree depth
    states = list(product(range(3), repeat=n))

    # Create a hidden periodic signal with noise
    true_period = 3
    np.random.seed(42)
    quotient_vals = {p: np.random.randn()
                     for p in product(range(3), repeat=true_period)}

    # Clean signal
    clean_signal = np.array([quotient_vals[s[:true_period]] for s in states])

    # Add varying levels of noise
    print(f"\n  True period: {true_period}")
    print(f"  State space size: 3^{n} = {3**n}")
    print(f"  Quotient size: 3^{true_period} = {3**true_period}")

    for noise_level in [0.0, 0.01, 0.1, 0.5, 1.0]:
        noisy_signal = clean_signal + noise_level * np.random.randn(len(states))
        detected = detect_branch_period(noisy_signal, n)
        print(f"\n  Noise level {noise_level:.2f}:")
        print(f"    Detected period: {detected} "
              f"({'correct' if detected == true_period else 'incorrect'})")

        # Reconstruction quality
        if detected <= n:
            recon = factor_through_quotient(noisy_signal, n, detected)
            errors = []
            for i, s in enumerate(states):
                prefix = s[:detected]
                errors.append(abs(noisy_signal[i] - recon[prefix]))
            print(f"    Max reconstruction error: {max(errors):.6f}")
            print(f"    Mean reconstruction error: {np.mean(errors):.6f}")


# ============================================================
# Application 3: Compressed Representation
# ============================================================

def compressed_representation():
    """
    Use branch periodicity for compressed representation of
    tree-structured data.

    When a signal on 3^n states is p-periodic (p < n), we can
    store it using only 3^p values — an exponential compression.
    """
    print("\n" + "=" * 60)
    print("Application 3: Compressed Signal Representation")
    print("=" * 60)

    print("\n  Compression ratios for periodic signals:")
    print(f"  {'n':>4} {'p':>4} {'Full size':>12} {'Compressed':>12} {'Ratio':>8}")
    print("  " + "-" * 44)

    for n in range(2, 8):
        for p in range(1, n):
            full_size = 3 ** n
            compressed_size = 3 ** p
            ratio = full_size / compressed_size
            print(f"  {n:4d} {p:4d} {full_size:12d} {compressed_size:12d} "
                  f"{ratio:8.1f}x")

    # Demonstrate with concrete data
    print("\n  Concrete example: n=6, p=2")
    n, p = 6, 2
    states = list(product(range(3), repeat=n))
    np.random.seed(0)
    quotient_vals = {pr: np.random.randn()
                     for pr in product(range(3), repeat=p)}
    signal = np.array([quotient_vals[s[:p]] for s in states])

    # Certified reconstruction
    moments_dict = {s: signal[i] for i, s in enumerate(states)}
    result = certified_reconstruction(moments_dict, n)
    cert = result['certificate']

    print(f"  Full signal size: {3**n} values")
    print(f"  Compressed size: {3**p} values")
    print(f"  Compression ratio: {cert['compression_ratio']:.0f}x")
    print(f"  Reconstruction exact: {cert['reconstruction_exact']}")
    print(f"  Storage savings: {(1 - 3**p / 3**n) * 100:.2f}%")


# ============================================================
# Application 4: Residue-Class Analysis of Pythagorean Triples
# ============================================================

def residue_analysis():
    """
    Analyze the residue class structure of Berggren tree triples.

    This reveals number-theoretic patterns in how Pythagorean triples
    distribute across congruence classes.
    """
    print("\n" + "=" * 60)
    print("Application 4: Residue Class Analysis")
    print("=" * 60)

    max_depth = 5

    for K in [4, 8, 12, 24]:
        residues = compute_residue_classes(max_depth, K)
        groups = group_by_residue(residues)

        print(f"\n  Modulus K = {K}:")
        print(f"    Total triples (depth ≤ {max_depth}): {len(residues)}")
        print(f"    Distinct residue classes: {len(groups)}")

        # Show distribution
        sizes = sorted(len(v) for v in groups.values())
        print(f"    Class sizes: min={sizes[0]}, max={sizes[-1]}, "
              f"median={sizes[len(sizes)//2]}")

        # Show most common classes
        sorted_groups = sorted(groups.items(), key=lambda x: -len(x[1]))
        print(f"    Most common classes:")
        for cls, words in sorted_groups[:3]:
            print(f"      {cls}: {len(words)} triples")


# ============================================================
# Application 5: Hecke Operator Spectral Analysis
# ============================================================

def hecke_spectral_analysis():
    """
    Analyze the spectral properties of the Hecke operator on
    small state spaces.
    """
    print("\n" + "=" * 60)
    print("Application 5: Hecke Operator Spectral Analysis")
    print("=" * 60)

    for n in range(1, 4):
        H = HeckeAlgebra(n)
        print(f"\n  n = {n}: state space (Z/3Z)^{n}, size = {H.num_states}")

        # Build the Hecke matrix
        hecke_matrix = np.zeros((H.num_states, H.num_states))
        for i, w in enumerate(H.states):
            for v in H.states:
                wv = H.add_words(w, v)
                j = H.state_index[wv]
                hecke_matrix[i, j] += 1.0

        # Eigenvalues
        eigenvalues = np.linalg.eigvals(hecke_matrix)
        eigenvalues = sorted(eigenvalues.real, reverse=True)

        print(f"  Hecke matrix eigenvalues: "
              f"{[round(e, 4) for e in eigenvalues[:5]]}")
        print(f"  Rank: {np.linalg.matrix_rank(hecke_matrix)}")
        print(f"  Trace: {np.trace(hecke_matrix):.0f} "
              f"(= {H.num_states} = 3^{n})")

        # Verify: all translation matrices commute
        n_tests = min(H.num_states ** 2, 100)
        max_comm = 0
        for i in range(min(H.num_states, 10)):
            for j in range(min(H.num_states, 10)):
                comm = H.verify_commutativity(H.states[i], H.states[j])
                max_comm = max(max_comm, comm)
        print(f"  Max commutator norm: {max_comm:.2e}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Berggren–Hecke Spectral Reconstruction: Applications")
    print("=" * 55)

    arithmetic_signal_processing()
    hidden_period_detection()
    compressed_representation()
    residue_analysis()
    hecke_spectral_analysis()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETED SUCCESSFULLY")
    print("=" * 60)


#!/usr/bin/env python3
"""
Berggren–Hecke Spectral Reconstruction: Concrete Demonstrations

This module demonstrates the key theorems of the Berggren–Hecke spectral
reconstruction theory with concrete numerical examples.
"""

import numpy as np
from itertools import product
from typing import Tuple, List, Dict

# ============================================================
# Section 1: Berggren Tree Generation
# ============================================================

def berggren_child(i: int, triple: Tuple[int, int, int]) -> Tuple[int, int, int]:
    """Apply the i-th Berggren matrix to a Pythagorean triple."""
    a, b, c = triple
    if i == 0:
        return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    elif i == 1:
        return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    else:
        return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def berggren_eval(word: List[int]) -> Tuple[int, int, int]:
    """Evaluate a Berggren word to get the corresponding Pythagorean triple."""
    t = (3, 4, 5)
    for i in reversed(word):
        t = berggren_child(i, t)
    return t

def is_pythagorean(triple: Tuple[int, int, int]) -> bool:
    """Check if a triple is Pythagorean."""
    a, b, c = triple
    return a**2 + b**2 == c**2

# ============================================================
# Section 2: Concrete Verification of Pythagorean Preservation
# ============================================================

def demo_pythagorean_preservation():
    """Verify that all Berggren tree vertices are Pythagorean triples."""
    print("=" * 60)
    print("DEMO 1: Pythagorean Preservation on the Berggren Tree")
    print("=" * 60)

    print(f"\nRoot: (3, 4, 5), Pythagorean: {is_pythagorean((3,4,5))}")
    print(f"  3² + 4² = {3**2 + 4**2} = 5² = {5**2}")

    # Generate depth-1 children
    print("\nDepth 1 children:")
    children_1 = []
    for i in range(3):
        t = berggren_eval([i])
        children_1.append(t)
        a, b, c = t
        print(f"  Child {i}: {t}, Pythagorean: {is_pythagorean(t)}")
        print(f"    {a}² + {b}² = {a**2 + b**2} = {c}² = {c**2}")

    # Generate depth-2 children
    print("\nDepth 2 children (first 9):")
    count = 0
    for w in product(range(3), repeat=2):
        t = berggren_eval(list(w))
        assert is_pythagorean(t), f"Not Pythagorean: {t}"
        print(f"  Word {list(w)}: {t}")
        count += 1

    # Verify all depth-3 triples
    all_ok = True
    depth3_count = 0
    for w in product(range(3), repeat=3):
        t = berggren_eval(list(w))
        if not is_pythagorean(t):
            all_ok = False
            break
        depth3_count += 1
    print(f"\nAll {depth3_count} depth-3 triples are Pythagorean: {all_ok}")

# ============================================================
# Section 3: Residue Class Stability
# ============================================================

def demo_residue_stability():
    """Demonstrate that residue classes are stable under Berggren child maps."""
    print("\n" + "=" * 60)
    print("DEMO 2: Residue Class Stability")
    print("=" * 60)

    K = 12
    print(f"\nModulus K = {K}")
    print(f"Root residue: {tuple(x % K for x in (3, 4, 5))}")

    # Show that children with same parent residue have same child residue
    print(f"\nDepth 1 residues mod {K}:")
    for i in range(3):
        t = berggren_eval([i])
        r = tuple(x % K for x in t)
        print(f"  Child {i}: triple={t}, residue mod {K} = {r}")

    print(f"\nDepth 2 residues mod {K}:")
    for w in product(range(3), repeat=2):
        t = berggren_eval(list(w))
        r = tuple(x % K for x in t)
        print(f"  Word {list(w)}: residue = {r}")

# ============================================================
# Section 4: Translation Operators and Commutativity
# ============================================================

def demo_translation_operators():
    """Demonstrate commutativity of translation operators on word state space."""
    print("\n" + "=" * 60)
    print("DEMO 3: Commutative Translation Operators")
    print("=" * 60)

    n = 2  # Word length
    states = list(product(range(3), repeat=n))
    num_states = len(states)
    print(f"\nWord state space: (Z/3Z)^{n}, size = {num_states}")

    # Define a test signal
    signal = {s: float(hash(s) % 100) / 100 for s in states}

    def translate(v, f):
        """Translate signal f by vector v (mod 3 addition)."""
        return {tuple((si + vi) % 3 for si, vi in zip(s, v)): f[s]
                for s in states}

    # Test commutativity: T_v1(T_v2(f)) = T_v2(T_v1(f))
    v1 = (1, 0)
    v2 = (0, 2)
    t1_then_t2 = translate(v1, translate(v2, signal))
    t2_then_t1 = translate(v2, translate(v1, signal))

    print(f"\nTranslation vectors: v1={v1}, v2={v2}")
    print(f"T_v1(T_v2(f)) == T_v2(T_v1(f)): {t1_then_t2 == t2_then_t1}")

    # Verify for all pairs
    all_commute = True
    test_count = 0
    for v1 in states:
        for v2 in states:
            t12 = translate(v1, translate(v2, signal))
            t21 = translate(v2, translate(v1, signal))
            if t12 != t21:
                all_commute = False
                break
            test_count += 1
    print(f"All {test_count} translation pairs commute: {all_commute}")

    # Verify order 3
    v = (1, 2)
    f_orig = signal.copy()
    f_t = translate(v, translate(v, translate(v, signal)))
    print(f"\nT_v^3(f) == f for v={v}: {f_t == f_orig}")

# ============================================================
# Section 5: Moment Map and Signal Reconstruction
# ============================================================

def demo_moment_reconstruction():
    """Demonstrate that moments with point indicators reconstruct signals."""
    print("\n" + "=" * 60)
    print("DEMO 4: Moment-Based Signal Reconstruction")
    print("=" * 60)

    n = 2
    states = list(product(range(3), repeat=n))

    # Create a random signal
    np.random.seed(42)
    signal = {s: np.random.randn() for s in states}

    # Compute moments against point indicators
    moments = {}
    for v in states:
        # moment(f, delta_v) = sum_w f(w) * delta_v(w) = f(v)
        m = sum(signal[w] * (1.0 if w == v else 0.0) for w in states)
        moments[v] = m

    # Verify reconstruction
    print(f"\nWord state space: (Z/3Z)^{n}")
    print(f"Original signal values:")
    for s in states:
        print(f"  f{s} = {signal[s]:.6f}")

    print(f"\nReconstructed from moments:")
    max_err = 0
    for s in states:
        err = abs(moments[s] - signal[s])
        max_err = max(max_err, err)
        print(f"  moment(f, δ_{s}) = {moments[s]:.6f} (error: {err:.2e})")

    print(f"\nMaximum reconstruction error: {max_err:.2e}")
    print(f"Perfect reconstruction: {max_err < 1e-15}")

# ============================================================
# Section 6: Branch-Periodic Signal Factorization
# ============================================================

def demo_branch_periodic():
    """Demonstrate that periodic signals factor through a quotient."""
    print("\n" + "=" * 60)
    print("DEMO 5: Branch-Periodic Signal Factorization")
    print("=" * 60)

    n = 4  # Word length
    p = 2  # Period

    # Create a p-periodic signal (depends only on first p coordinates)
    np.random.seed(123)
    quotient_values = {}
    for prefix in product(range(3), repeat=p):
        quotient_values[prefix] = np.random.randn()

    # The full signal
    signal = {}
    for w in product(range(3), repeat=n):
        prefix = w[:p]
        signal[w] = quotient_values[prefix]

    print(f"\nWord length n={n}, period p={p}")
    print(f"Full state space size: 3^{n} = {3**n}")
    print(f"Quotient space size: 3^{p} = {3**p}")
    print(f"\nQuotient values:")
    for prefix, val in quotient_values.items():
        print(f"  g{prefix} = {val:.6f}")

    # Verify factorization
    print(f"\nVerifying f(w) = g(w[:p]) for all w:")
    all_match = True
    for w in product(range(3), repeat=n):
        if signal[w] != quotient_values[w[:p]]:
            all_match = False
            break
    print(f"  All {3**n} values factor through prefix: {all_match}")

    # Moment reconstruction still works
    states = list(product(range(3), repeat=n))
    moments = {}
    for v in states:
        m = sum(signal[w] * (1.0 if w == v else 0.0) for w in states)
        moments[v] = m

    max_err = max(abs(moments[s] - signal[s]) for s in states)
    print(f"  Moment reconstruction error: {max_err:.2e}")

# ============================================================
# Section 7: Hecke Averaging Operator
# ============================================================

def demo_hecke_operator():
    """Demonstrate the Hecke averaging operator and its properties."""
    print("\n" + "=" * 60)
    print("DEMO 6: Hecke Averaging Operator")
    print("=" * 60)

    n = 2
    states = list(product(range(3), repeat=n))

    # Define a signal
    np.random.seed(99)
    f = {s: np.random.randn() for s in states}

    # Apply Hecke operator: (Hf)(w) = sum_v f(w + v)
    def hecke(signal):
        result = {}
        for w in states:
            result[w] = sum(signal[tuple((wi + vi) % 3 for wi, vi in zip(w, v))]
                           for v in states)
        return result

    Hf = hecke(f)
    print(f"\nWord state space: (Z/3Z)^{n}, size = {len(states)}")
    print(f"\nOriginal signal and Hecke-averaged signal:")
    total_mass = sum(f[s] for s in states)
    for s in states[:5]:
        print(f"  f{s} = {f[s]:.4f},  (Hf){s} = {Hf[s]:.4f}")

    # Verify: H sends any signal to a constant (= total mass at each point)
    hecke_values = set(round(v, 10) for v in Hf.values())
    print(f"\nHecke output is constant: {len(hecke_values) == 1}")
    print(f"Constant value = total mass = {total_mass:.4f}")

    # Verify H commutes with translation
    v = (1, 2)
    def translate(v, signal):
        return {tuple((si + vi) % 3 for si, vi in zip(s, v)): signal[s]
                for s in states}

    H_T = hecke(translate(v, f))
    T_H = translate(v, hecke(f))
    commute_ok = all(abs(H_T[s] - T_H[s]) < 1e-12 for s in states)
    print(f"\nH commutes with T_v for v={v}: {commute_ok}")

# ============================================================
# Section 8: Full Berggren Tree Visualization Data
# ============================================================

def demo_berggren_tree():
    """Generate the Berggren tree structure for visualization."""
    print("\n" + "=" * 60)
    print("DEMO 7: Berggren Tree Structure")
    print("=" * 60)

    max_depth = 3
    print(f"\nBerggren tree to depth {max_depth}:")
    print(f"Root: (3, 4, 5)")

    tree = {(): (3, 4, 5)}
    for depth in range(1, max_depth + 1):
        for w in product(range(3), repeat=depth):
            t = berggren_eval(list(w))
            tree[w] = t

    # Print tree
    for depth in range(max_depth + 1):
        words = [w for w in tree if len(w) == depth]
        print(f"\n  Depth {depth} ({len(words)} triples):")
        for w in sorted(words):
            a, b, c = tree[w]
            print(f"    word={list(w) if w else '[]'}: ({a}, {b}, {c})"
                  f"  hyp={c}")

    # Statistics
    all_triples = list(tree.values())
    print(f"\n  Total triples: {len(all_triples)}")
    print(f"  All Pythagorean: {all(is_pythagorean(t) for t in all_triples)}")
    hyps = sorted(set(t[2] for t in all_triples))
    print(f"  Hypotenuses: {hyps[:10]}...")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_pythagorean_preservation()
    demo_residue_stability()
    demo_translation_operators()
    demo_moment_reconstruction()
    demo_branch_periodic()
    demo_hecke_operator()
    demo_berggren_tree()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETED SUCCESSFULLY")
    print("=" * 60)


#!/usr/bin/env python3
"""Generate the PACKAGE.json file with all embedded content."""

import json
import base64
from pathlib import Path

# Read markdown files
article = Path('/workspace/request-project/ARTICLE.md').read_text()
research_paper = Path('/workspace/request-project/RESEARCH_PAPER.md').read_text()
future_directions = Path('/workspace/request-project/FUTURE_DIRECTIONS.md').read_text()

# Read code files
demo_code = Path('/workspace/request-project/demo.py').read_text()
algorithms_code = Path('/workspace/request-project/algorithms.py').read_text()
applications_code = Path('/workspace/request-project/applications.py').read_text()
lean_code = Path('/workspace/request-project/Bridges/BerggrenHeckeSpectral.lean').read_text()

# Read visualization images as base64
visualizations = []
for name, filename in [
    ("Berggren Tree Structure", "berggren_tree.png"),
    ("Operator Commutativity & Eigenvalues", "operator_commutativity.png"),
    ("Moment-Based Signal Reconstruction", "moment_reconstruction.png"),
    ("Branch-Period Detection", "period_detection.png"),
    ("Residue Classes & Hypotenuse Growth", "residue_classes.png"),
]:
    filepath = Path(f'/workspace/request-project/{filename}')
    if filepath.exists():
        with open(filepath, 'rb') as f:
            data = base64.b64encode(f.read()).decode('utf-8')
        visualizations.append({
            "name": name,
            "data": f"data:image/png;base64,{data}"
        })

# Build package
package = {
    "title": "Berggren–Hecke Spectral Reconstruction on the Pythagorean Tree",
    "domain": "Algebra–Geometry–Computation Bridge",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Berggren–Hecke Spectral Reconstruction Demo",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Berggren Tree Evaluation",
            "pseudocode": "Input: word w = [i1, ..., ik] over {0,1,2}\nOutput: Pythagorean triple (a,b,c)\n\nt ← (3, 4, 5)\nfor j = k down to 1:\n  t ← B_{i_j} · t\nreturn t",
            "code": algorithms_code
        },
        {
            "name": "Certified Signal Reconstruction",
            "pseudocode": "Input: moments {⟨f, δ_v⟩ : v ∈ (Z/3Z)^n}\nOutput: signal f, period p, certificate\n\n1. Reconstruct: f(v) ← ⟨f, δ_v⟩ for all v\n2. For p = 1 to n:\n     if f is p-periodic: break\n3. Factor: g ← f ∘ trunc_p^{-1}\n4. Verify: check f = g ∘ trunc_p\n5. Return (f, p, g, certificate)",
            "code": algorithms_code
        }
    ],
    "visualizations": visualizations,
    "lean_proofs": lean_code
}

# Write JSON
with open('/workspace/request-project/PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated: {len(json.dumps(package))} bytes")
print(f"  Visualizations: {len(visualizations)}")
print(f"  Demos: {len(package['demos'])}")
print(f"  Algorithms: {len(package['algorithms'])}")


#!/usr/bin/env python3
"""
Berggren–Hecke Spectral Reconstruction: Visualizations

Generates publication-quality figures for the research paper and article.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import product
import base64
from io import BytesIO

# Import from our algorithms
from algorithms import (
    berggren_eval_matrix, generate_berggren_tree, HeckeAlgebra,
    detect_branch_period, certified_reconstruction
)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def visualize_berggren_tree():
    """Visualize the Berggren tree structure."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    tree = generate_berggren_tree(3)

    # Position nodes
    positions = {}
    labels = {}

    # Root
    positions[()] = (7, 7)
    labels[()] = "(3,4,5)"

    # Layout depth by depth
    depth_y = {0: 7, 1: 5, 2: 3, 3: 1}

    for depth in range(1, 4):
        words = sorted([w for w in tree if len(w) == depth])
        n_words = len(words)
        width = 13
        for idx, w in enumerate(words):
            x = 0.5 + width * idx / max(n_words - 1, 1)
            positions[w] = (x, depth_y[depth])
            t = tree[w]
            labels[w] = f"({t[0]},{t[1]},{t[2]})"

    # Draw edges
    for w in tree:
        if len(w) > 0:
            parent = w[:-1]
            if parent in positions and w in positions:
                x1, y1 = positions[parent]
                x2, y2 = positions[w]
                colors = ['#e74c3c', '#2ecc71', '#3498db']
                ax.plot([x1, x2], [y1, y2], '-', color=colors[w[-1]],
                       linewidth=1.5, alpha=0.7)

    # Draw nodes
    for w, (x, y) in positions.items():
        t = tree[w]
        # Color by whether hypotenuse is prime
        circle = plt.Circle((x, y), 0.3, fill=True,
                           facecolor='#ecf0f1', edgecolor='#2c3e50',
                           linewidth=1.5, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y, labels[w], ha='center', va='center',
               fontsize=5, fontweight='bold', zorder=4)

    # Legend
    ax.plot([], [], '-', color='#e74c3c', linewidth=2, label='B₁ (child 0)')
    ax.plot([], [], '-', color='#2ecc71', linewidth=2, label='B₂ (child 1)')
    ax.plot([], [], '-', color='#3498db', linewidth=2, label='B₃ (child 2)')
    ax.legend(loc='upper right', fontsize=10)

    ax.set_xlim(-0.5, 14)
    ax.set_ylim(0, 8)
    ax.set_title('The Berggren Tree of Primitive Pythagorean Triples',
                fontsize=14, fontweight='bold')
    ax.set_ylabel('Depth', fontsize=12)
    ax.set_yticks([7, 5, 3, 1])
    ax.set_yticklabels(['0', '1', '2', '3'])
    ax.set_xticks([])
    ax.set_aspect('equal')

    fig.tight_layout()
    fig.savefig('/workspace/request-project/berggren_tree.png', dpi=150,
                bbox_inches='tight')
    return fig_to_base64(fig)


def visualize_operator_commutativity():
    """Visualize commutator norms for the translation operator algebra."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: commutator matrix for n=2
    n = 2
    H = HeckeAlgebra(n)
    states = H.states

    # Compute all pairwise commutator norms
    comm_matrix = np.zeros((len(states), len(states)))
    for i, v1 in enumerate(states):
        for j, v2 in enumerate(states):
            comm_matrix[i, j] = H.verify_commutativity(v1, v2)

    im = axes[0].imshow(comm_matrix, cmap='RdYlGn_r', interpolation='nearest',
                        vmin=0, vmax=max(comm_matrix.max(), 1e-15))
    axes[0].set_title(f'Commutator Norms ‖[T_v₁, T_v₂]‖\n(Z/3Z)² state space',
                     fontsize=11, fontweight='bold')
    axes[0].set_xlabel('Translation v₂')
    axes[0].set_ylabel('Translation v₁')
    tick_labels = [str(s) for s in states]
    axes[0].set_xticks(range(len(states)))
    axes[0].set_xticklabels(tick_labels, rotation=45, fontsize=6)
    axes[0].set_yticks(range(len(states)))
    axes[0].set_yticklabels(tick_labels, fontsize=6)
    plt.colorbar(im, ax=axes[0], label='‖commutator‖')

    # Right: eigenvalues of translation operators
    n = 2
    H2 = HeckeAlgebra(n)
    eigenvalues = {}
    for v in H2.states:
        M = H2.translation_matrix(v)
        evals = np.linalg.eigvals(M)
        eigenvalues[v] = sorted(evals, key=lambda x: (x.real, x.imag))

    ax = axes[1]
    colors = plt.cm.tab10(np.linspace(0, 1, len(H2.states)))
    for idx, (v, evals) in enumerate(eigenvalues.items()):
        for ev in evals:
            ax.plot(ev.real, ev.imag, 'o', color=colors[idx],
                   markersize=6, alpha=0.7)

    # Draw unit circle
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3, linewidth=0.5)

    ax.set_title('Eigenvalues of Translation Operators\non (Z/3Z)²',
                fontsize=11, fontweight='bold')
    ax.set_xlabel('Re(λ)')
    ax.set_ylabel('Im(λ)')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/operator_commutativity.png', dpi=150,
                bbox_inches='tight')
    return fig_to_base64(fig)


def visualize_moment_reconstruction():
    """Visualize signal reconstruction from moments."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    n = 3
    states = list(product(range(3), repeat=n))
    np.random.seed(42)

    # Create a signal
    signal = np.random.randn(len(states))

    # Compute moments (= signal values for point indicators)
    moments = signal.copy()

    # Reconstruct
    reconstructed = moments.copy()

    # Plot 1: Original signal
    axes[0].bar(range(len(states)), signal, color='#3498db', alpha=0.8)
    axes[0].set_title('Original Signal f', fontsize=11, fontweight='bold')
    axes[0].set_xlabel('Word state index')
    axes[0].set_ylabel('f(w)')

    # Plot 2: Moments
    axes[1].bar(range(len(states)), moments, color='#e74c3c', alpha=0.8)
    axes[1].set_title('Character Moments ⟨f, δᵥ⟩', fontsize=11, fontweight='bold')
    axes[1].set_xlabel('Character index')
    axes[1].set_ylabel('moment value')

    # Plot 3: Reconstruction error
    error = np.abs(signal - reconstructed)
    axes[2].bar(range(len(states)), error, color='#2ecc71', alpha=0.8)
    axes[2].set_title('Reconstruction Error |f - f̂|', fontsize=11, fontweight='bold')
    axes[2].set_xlabel('Word state index')
    axes[2].set_ylabel('|error|')
    axes[2].set_ylim(0, max(error.max(), 1e-16) * 1.5)

    fig.suptitle('Signal Reconstruction via Point-Character Moments on (Z/3Z)³',
                fontsize=13, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/moment_reconstruction.png', dpi=150,
                bbox_inches='tight')
    return fig_to_base64(fig)


def visualize_period_detection():
    """Visualize period detection for branch-periodic signals."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    n = 4
    states = list(product(range(3), repeat=n))
    np.random.seed(123)

    periods_to_test = [1, 2, 3, 4]

    for ax_idx, p in enumerate(periods_to_test):
        ax = axes[ax_idx // 2][ax_idx % 2]

        # Create p-periodic signal
        quotient_vals = {pr: np.random.randn()
                        for pr in product(range(3), repeat=p)}
        signal = np.array([quotient_vals[s[:p]] for s in states])

        # Detect period
        detected = detect_branch_period(signal, n)

        # Color bars by prefix class
        colors_map = {}
        color_list = plt.cm.Set3(np.linspace(0, 1, 3**p))
        for idx, prefix in enumerate(product(range(3), repeat=p)):
            colors_map[prefix] = color_list[idx % len(color_list)]

        bar_colors = [colors_map[s[:p]] for s in states]

        ax.bar(range(len(states)), signal, color=bar_colors, alpha=0.8,
               edgecolor='gray', linewidth=0.3)
        ax.set_title(f'Period p={p} signal (detected: {detected})',
                    fontsize=10, fontweight='bold')
        ax.set_xlabel('Word state index')
        ax.set_ylabel('f(w)')

        # Mark period boundaries
        for i in range(0, len(states), 3**(n-p)):
            ax.axvline(i - 0.5, color='red', linewidth=0.5, alpha=0.3)

    fig.suptitle('Branch-Period Detection on (Z/3Z)⁴',
                fontsize=13, fontweight='bold')
    fig.tight_layout()
    fig.savefig('/workspace/request-project/period_detection.png', dpi=150,
                bbox_inches='tight')
    return fig_to_base64(fig)


def visualize_residue_classes():
    """Visualize residue class structure of the Berggren tree."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: residue classes mod 4
    K = 4
    tree = generate_berggren_tree(4)
    residues = {}
    for w, t in tree.items():
        residues[w] = tuple(int(x) % K for x in t)

    # Count residue classes at each depth
    depth_classes = {}
    for depth in range(5):
        words = [w for w in tree if len(w) == depth]
        classes = set()
        for w in words:
            classes.add(residues[w])
        depth_classes[depth] = len(classes)

    ax = axes[0]
    depths = list(depth_classes.keys())
    counts = list(depth_classes.values())
    ax.bar(depths, counts, color='#9b59b6', alpha=0.8)
    ax.set_xlabel('Tree Depth')
    ax.set_ylabel('Number of Distinct Residue Classes')
    ax.set_title(f'Residue Class Diversity mod {K}',
                fontsize=11, fontweight='bold')
    ax.set_xticks(depths)

    # Right: hypotenuse growth
    ax = axes[1]
    for child_idx, label, color in [(0, 'B₁', '#e74c3c'),
                                     (1, 'B₂', '#2ecc71'),
                                     (2, 'B₃', '#3498db')]:
        hyps = []
        word = []
        for d in range(8):
            t = berggren_eval_matrix(word)
            hyps.append(int(t[2]))
            word.append(child_idx)
        ax.semilogy(range(len(hyps)), hyps, 'o-', color=color,
                   label=label, markersize=5)

    ax.set_xlabel('Depth')
    ax.set_ylabel('Hypotenuse c (log scale)')
    ax.set_title('Hypotenuse Growth Along Pure Branches',
                fontsize=11, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/residue_classes.png', dpi=150,
                bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    b1 = visualize_berggren_tree()
    print(f"  berggren_tree.png ({len(b1)} bytes base64)")

    b2 = visualize_operator_commutativity()
    print(f"  operator_commutativity.png ({len(b2)} bytes base64)")

    b3 = visualize_moment_reconstruction()
    print(f"  moment_reconstruction.png ({len(b3)} bytes base64)")

    b4 = visualize_period_detection()
    print(f"  period_detection.png ({len(b4)} bytes base64)")

    b5 = visualize_residue_classes()
    print(f"  residue_classes.png ({len(b5)} bytes base64)")

    print("\nAll visualizations generated successfully!")
