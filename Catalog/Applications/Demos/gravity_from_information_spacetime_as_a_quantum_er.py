"""
Gravitational Code Geometry: Demonstration Script

Demonstrates the Einstein Decomposition Theorem and related concepts
using concrete numerical examples on small finite sets.
"""
import itertools
from typing import Callable, Dict, FrozenSet, List, Tuple

# Type aliases
SetFn = Callable[[FrozenSet[int]], float]

def powerset(ground: set) -> List[FrozenSet[int]]:
    """Return all subsets of ground as frozensets."""
    result = []
    items = sorted(ground)
    for r in range(len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(frozenset(combo))
    return result

def defect(f: SetFn, X: FrozenSet[int], Y: FrozenSet[int]) -> float:
    """Compute the syndrome defect (discrete curvature)."""
    return f(X) + f(Y) - f(X & Y) - f(X | Y)

def is_modular(f: SetFn, ground: set, tol: float = 1e-10) -> bool:
    """Check if f is modular on the powerset of ground."""
    subsets = powerset(ground)
    for X in subsets:
        for Y in subsets:
            if abs(defect(f, X, Y)) > tol:
                return False
    return True

def is_submodular(f: SetFn, ground: set, tol: float = 1e-10) -> bool:
    """Check if f is submodular on the powerset of ground."""
    subsets = powerset(ground)
    for X in subsets:
        for Y in subsets:
            if defect(f, X, Y) < -tol:
                return False
    return True

def mutual_info(f: SetFn, X: FrozenSet[int], Y: FrozenSet[int]) -> float:
    """Compute mutual information I(X:Y)."""
    return f(X) + f(Y) - f(X | Y)

def tripartite_info(f: SetFn, X: FrozenSet[int], Y: FrozenSet[int], Z: FrozenSet[int]) -> float:
    """Compute tripartite information I_3(X,Y,Z)."""
    return (f(X) + f(Y) + f(Z)
            - f(X | Y) - f(X | Z) - f(Y | Z)
            + f(X | Y | Z))

def verify_einstein_decomposition(S: SetFn, T: SetFn, L: SetFn, ground: set) -> Dict:
    """Verify the Einstein decomposition S = T + L with L modular."""
    subsets = powerset(ground)
    
    # Check decomposition S = T + L
    decomp_ok = True
    max_decomp_error = 0.0
    for X in subsets:
        err = abs(S(X) - T(X) - L(X))
        max_decomp_error = max(max_decomp_error, err)
        if err > 1e-10:
            decomp_ok = False
    
    # Check L is modular
    l_modular = is_modular(L, ground)
    
    # Check Einstein equation: defect(S) = defect(T)
    einstein_ok = True
    max_einstein_error = 0.0
    for X in subsets:
        for Y in subsets:
            err = abs(defect(S, X, Y) - defect(T, X, Y))
            max_einstein_error = max(max_einstein_error, err)
            if err > 1e-10:
                einstein_ok = False
    
    return {
        "decomposition_holds": decomp_ok,
        "max_decomposition_error": max_decomp_error,
        "vacuum_modular": l_modular,
        "einstein_equation_holds": einstein_ok,
        "max_einstein_error": max_einstein_error,
        "S_submodular": is_submodular(S, ground),
        "T_submodular": is_submodular(T, ground),
    }

# ============================================================
# Example 1: Cardinality Spacetime
# S(X) = |X|^2, T(X) = |X|^2 - |X|, L(X) = |X|
# ============================================================
print("=" * 60)
print("EXAMPLE 1: Cardinality Spacetime")
print("S(X) = |X|², T(X) = |X|² - |X|, L(X) = |X|")
print("=" * 60)

ground = {1, 2, 3, 4}

S_card = lambda X: len(X) ** 2
T_card = lambda X: len(X) ** 2 - len(X)
L_card = lambda X: len(X)

result = verify_einstein_decomposition(S_card, T_card, L_card, ground)
for k, v in result.items():
    print(f"  {k}: {v}")

# Show some defects
print("\nCurvature values (defect):")
for a, b in [(frozenset({1}), frozenset({2})),
             (frozenset({1, 2}), frozenset({3, 4})),
             (frozenset({1}), frozenset({1, 2, 3}))]:
    d = defect(S_card, a, b)
    print(f"  defect(S, {set(a)}, {set(b)}) = {d}")
    print(f"  defect(T, {set(a)}, {set(b)}) = {defect(T_card, a, b)}")

# ============================================================
# Example 2: Flat Spacetime
# S(X) = L(X) = |X|, T(X) = 0
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 2: Flat Spacetime (L = cardinality, T = 0)")
print("=" * 60)

S_flat = lambda X: len(X)
T_flat = lambda X: 0
L_flat = lambda X: len(X)

result = verify_einstein_decomposition(S_flat, T_flat, L_flat, ground)
for k, v in result.items():
    print(f"  {k}: {v}")

# ============================================================
# Example 3: Mutual Information and Binding Energy
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 3: Mutual Information (Binding Energy)")
print("=" * 60)

A = frozenset({1, 2})
B = frozenset({3, 4})
C = frozenset({1})

print(f"  I(A:B) = {mutual_info(S_card, A, B):.2f}  (A={set(A)}, B={set(B)})")
print(f"  I(A:C) = {mutual_info(S_card, A, C):.2f}  (A={set(A)}, C={set(C)})")
print(f"  I_3(A,B,C) = {tripartite_info(S_card, A, B, C):.2f}")

print("\n  For flat spacetime:")
print(f"  I(A:B) = {mutual_info(S_flat, A, B):.2f}")

# ============================================================
# Example 4: Conjecture Test - Modular Approximation
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 4: Modular Approximation Quality")
print("=" * 60)

import random
random.seed(42)

def random_submodular(ground: set) -> SetFn:
    """Generate a random submodular function using weight of max coverage."""
    weights = {i: random.random() for i in ground}
    def f(X: FrozenSet[int]) -> float:
        if not X:
            return 0.0
        return sum(weights[i] for i in X) ** 0.5  # concave composition → submodular
    return f

for trial in range(3):
    f = random_submodular(ground)
    assert is_submodular(f, ground), "Generated function is not submodular!"
    
    # Best modular approximation: L(X) = sum of f({i}) for i in X
    def L_approx(X: FrozenSet[int], _f=f) -> float:
        return sum(_f(frozenset({i})) for i in X)
    
    T_approx = lambda X, _f=f, _L=L_approx: _f(X) - _L(X)
    
    result = verify_einstein_decomposition(f, T_approx, L_approx, ground)
    max_defect = max(abs(defect(f, X, Y)) 
                     for X in powerset(ground) for Y in powerset(ground))
    print(f"  Trial {trial + 1}: L modular = {result['vacuum_modular']}, "
          f"Einstein OK = {result['einstein_equation_holds']}, "
          f"max |defect| = {max_defect:.4f}")

# ============================================================
# Example 5: Pure Matter vs Mixed Spacetime
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 5: Pure Matter vs Mixed")
print("=" * 60)

# Pure matter: S = T, L = 0
print("Pure matter (L=0):")
T_pure = lambda X: len(X) ** 2
L_zero = lambda X: 0
result = verify_einstein_decomposition(T_pure, T_pure, L_zero, ground)
print(f"  Einstein OK: {result['einstein_equation_holds']}")
print(f"  Total curvature = {sum(defect(T_pure, X, Y) for X in powerset(ground) for Y in powerset(ground)):.2f}")

# Mixed: S = |X|^2 + |X|
print("\nMixed (L = |X|):")
S_mixed = lambda X: len(X) ** 2 + len(X)
result = verify_einstein_decomposition(S_mixed, T_pure, L_card, ground)
print(f"  Einstein OK: {result['einstein_equation_holds']}")

print("\n" + "=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


"""
Visualization: Curvature Heatmap for Code Spacetimes

Generates a heatmap of syndrome defect (curvature) values
for all pairs of subsets of a ground set.
"""
import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import FrozenSet, List


def powerset(ground: set) -> List[FrozenSet[int]]:
    items = sorted(ground)
    result = []
    for r in range(len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(frozenset(combo))
    return result


def defect(f, X: FrozenSet[int], Y: FrozenSet[int]) -> float:
    return f(X) + f(Y) - f(X & Y) - f(X | Y)


def set_label(s: FrozenSet[int]) -> str:
    if not s:
        return "∅"
    return "{" + ",".join(str(x) for x in sorted(s)) + "}"


def plot_curvature_heatmap(ground: set, S, title: str, filename: str):
    subsets = powerset(ground)
    n = len(subsets)
    matrix = np.zeros((n, n))
    
    for i, X in enumerate(subsets):
        for j, Y in enumerate(subsets):
            matrix[i, j] = defect(S, X, Y)
    
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    im = ax.imshow(matrix, cmap='RdYlBu_r', aspect='equal')
    
    labels = [set_label(s) for s in subsets]
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=7)
    ax.set_yticklabels(labels, fontsize=7)
    
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_xlabel("Region Y", fontsize=11)
    ax.set_ylabel("Region X", fontsize=11)
    
    cbar = plt.colorbar(im, ax=ax, label='Defect (Curvature)')
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {filename}")


# Generate plots
ground = {1, 2, 3}

# Cardinality spacetime: S(X) = |X|^2
S_card = lambda X: len(X) ** 2
plot_curvature_heatmap(ground, S_card, 
    "Curvature Heatmap: S(X) = |X|² (Cardinality Spacetime)",
    "curvature_cardinality.png")

# Flat spacetime: S(X) = |X|
S_flat = lambda X: float(len(X))
plot_curvature_heatmap(ground, S_flat,
    "Curvature Heatmap: S(X) = |X| (Flat Spacetime)",
    "curvature_flat.png")

# Submodular: S(X) = sqrt(|X|)
import math
S_sqrt = lambda X: math.sqrt(len(X))
plot_curvature_heatmap(ground, S_sqrt,
    "Curvature Heatmap: S(X) = √|X| (Square Root Spacetime)",
    "curvature_sqrt.png")

print("\nAll curvature heatmaps generated.")


"""
Visualization: Einstein Decomposition S = T + L

Shows how entropy decomposes into matter (T) and vacuum (L) components
for different spacetime models.
"""
import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import FrozenSet, List


def powerset(ground: set) -> List[FrozenSet[int]]:
    items = sorted(ground)
    result = []
    for r in range(len(items) + 1):
        for combo in itertools.combinations(items, r):
            result.append(frozenset(combo))
    return result


def set_label(s: FrozenSet[int]) -> str:
    if not s:
        return "∅"
    return "{" + ",".join(str(x) for x in sorted(s)) + "}"


def plot_decomposition(ground: set, S, T, L, title: str, filename: str):
    subsets = powerset(ground)
    n = len(subsets)
    
    s_vals = [S(X) for X in subsets]
    t_vals = [T(X) for X in subsets]
    l_vals = [L(X) for X in subsets]
    
    labels = [set_label(s) for s in subsets]
    x = np.arange(n)
    width = 0.25
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 10))
    
    # Top: Bar chart of S, T, L
    ax1 = axes[0]
    ax1.bar(x - width, s_vals, width, label='S (total entropy)', color='#2196F3', alpha=0.8)
    ax1.bar(x, t_vals, width, label='T (matter)', color='#F44336', alpha=0.8)
    ax1.bar(x + width, l_vals, width, label='L (vacuum)', color='#4CAF50', alpha=0.8)
    ax1.set_xticks(x)
    ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=7)
    ax1.set_ylabel('Value', fontsize=11)
    ax1.set_title(f'{title}\nEinstein Decomposition: S = T + L', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(axis='y', alpha=0.3)
    
    # Bottom: Stacked bar showing T + L = S
    ax2 = axes[1]
    ax2.bar(x, l_vals, width=0.6, label='L (vacuum/flat)', color='#4CAF50', alpha=0.8)
    ax2.bar(x, t_vals, width=0.6, bottom=l_vals, label='T (matter/curved)', color='#F44336', alpha=0.8)
    ax2.scatter(x, s_vals, color='blue', zorder=5, s=30, label='S (total)')
    ax2.set_xticks(x)
    ax2.set_xticklabels(labels, rotation=45, ha='right', fontsize=7)
    ax2.set_ylabel('Value', fontsize=11)
    ax2.set_title('Stacked Decomposition: S = T + L', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {filename}")


# Generate plots
ground = {1, 2, 3, 4}

# Cardinality spacetime
S1 = lambda X: len(X) ** 2
T1 = lambda X: len(X) ** 2 - len(X)
L1 = lambda X: float(len(X))
plot_decomposition(ground, S1, T1, L1,
    "Cardinality Spacetime: S(X) = |X|²",
    "decomposition_cardinality.png")

# Logarithmic spacetime: S(X) = |X| * log(1 + |X|)
import math
S2 = lambda X: len(X) * math.log(1 + len(X)) if X else 0.0
L2 = lambda X: float(len(X)) * math.log(2) if X else 0.0
T2 = lambda X: S2(X) - L2(X)
plot_decomposition(ground, S2, T2, L2,
    "Logarithmic Spacetime: S(X) = |X|·log(1+|X|)",
    "decomposition_logarithmic.png")

print("\nAll decomposition plots generated.")
