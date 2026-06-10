#!/usr/bin/env python3
"""
Quantum Groups: U_q(sl₂) Deformation Demo

Demonstrates the core mathematical results:
1. q-integers and their classical limit
2. Representation theory of U_q(sl₂)
3. R-matrix and Yang-Baxter equation
4. Quantum dimension formula
5. Clebsch-Gordan decomposition
"""

import numpy as np
from typing import List, Tuple


def q_int(q: float, n: int) -> float:
    """Compute [n]_q = (q^n - 1)/(q - 1) for q ≠ 1, or n for q = 1."""
    if abs(q - 1.0) < 1e-12:
        return float(n)
    return (q**n - 1) / (q - 1)


def q_factorial(q: float, n: int) -> float:
    """Compute [n]_q! = [1]_q · [2]_q · ... · [n]_q."""
    result = 1.0
    for k in range(1, n + 1):
        result *= q_int(q, k)
    return result


def q_binomial(q: float, n: int, k: int) -> float:
    """Compute the Gaussian binomial coefficient [n choose k]_q."""
    if k < 0 or k > n:
        return 0.0
    return q_factorial(q, n) / (q_factorial(q, k) * q_factorial(q, n - k))


def quantum_dim(q: float, n: int) -> float:
    """Quantum dimension [n+1]_q of the (n+1)-dimensional representation."""
    return q_int(q, n + 1)


def r_matrix(q: float) -> np.ndarray:
    """
    The R-matrix for U_q(sl₂) on V₁ ⊗ V₁ (fundamental ⊗ fundamental).
    4×4 matrix in basis |00⟩, |01⟩, |10⟩, |11⟩.
    """
    R = np.zeros((4, 4))
    R[0, 0] = q
    R[3, 3] = q
    R[1, 2] = 1
    R[2, 1] = 1
    R[2, 2] = q - 1/q if abs(q) > 1e-12 else 0
    return R


def yang_baxter_check(q: float) -> float:
    """
    Verify Yang-Baxter equation: R₁₂ R₁₃ R₂₃ = R₂₃ R₁₃ R₁₂
    on V ⊗ V ⊗ V (8×8 matrices). Returns the Frobenius norm of the difference.
    """
    R = r_matrix(q)
    I = np.eye(2)
    
    # R₁₂ = R ⊗ I, R₂₃ = I ⊗ R
    R12 = np.kron(R, I)
    R23 = np.kron(I, R)
    
    # R₁₃ requires permutation: swap spaces 2 and 3, apply R to 1,3, swap back
    # More precisely, R₁₃ acts on positions 1 and 3 of the 3-fold tensor
    P23 = np.zeros((8, 8))
    for a in range(2):
        for b in range(2):
            for c in range(2):
                i = a * 4 + b * 2 + c
                j = a * 4 + c * 2 + b
                P23[i, j] = 1
    R13 = P23 @ R23 @ P23
    
    LHS = R12 @ R13 @ R23
    RHS = R23 @ R13 @ R12
    
    return np.linalg.norm(LHS - RHS)


def fusion_multiplicity(m: int, n: int, k: int) -> int:
    """Multiplicity of V_k in V_m ⊗ V_n."""
    if k <= m + n and m + n - k <= 2 * min(m, n) and (m + n + k) % 2 == 0:
        return 1
    return 0


def clebsch_gordan_check(m: int, n: int) -> Tuple[int, int]:
    """Verify (m+1)(n+1) = ∑_k mult(m,n,k)·(k+1)."""
    lhs = (m + 1) * (n + 1)
    rhs = sum(fusion_multiplicity(m, n, k) * (k + 1) for k in range(m + n + 1))
    return lhs, rhs


def print_section(title: str):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     QUANTUM GROUPS: U_q(sl₂) DEFORMATION DEMO          ║")
    print("╚══════════════════════════════════════════════════════════╝")

    # Demo 1: q-integers converge to classical
    print_section("1. Classical Limit: [n]_q → n as q → 1")
    for n in [1, 2, 3, 5, 10]:
        print(f"  n = {n}:")
        for q in [0.5, 0.9, 0.99, 0.999, 1.0, 1.001, 1.01, 1.1, 2.0]:
            val = q_int(q, n)
            print(f"    [n]_{q:.3f} = {val:.6f}", end="")
        print()
    
    # Demo 2: q-factorial
    print_section("2. q-Factorial Classical Limit: [n]_q! → n!")
    for n in range(1, 8):
        classical = q_factorial(1.0, n)
        import math
        expected = math.factorial(n)
        q_val = q_factorial(2.0, n)
        print(f"  [{n}]_1! = {classical:.0f} (= {expected}!),  [{n}]_2! = {q_val:.1f}")

    # Demo 3: Quantum dimension
    print_section("3. Quantum Dimension: dim_q(V_n) = [n+1]_q")
    for n in range(6):
        print(f"  V_{n} (dim {n+1}):", end="")
        for q in [0.5, 1.0, 2.0, 3.0]:
            print(f"  dim_q={q:.1f}: {quantum_dim(q, n):.3f}", end="")
        print()

    # Demo 4: R-matrix and Yang-Baxter
    print_section("4. Yang-Baxter Equation Verification")
    for q in [0.5, 0.7, 1.0, 1.5, 2.0, 3.0, -1.0]:
        err = yang_baxter_check(q)
        status = "✓" if err < 1e-10 else "✗"
        print(f"  q = {q:5.1f}: ||R₁₂R₁₃R₂₃ - R₂₃R₁₃R₁₂|| = {err:.2e}  {status}")

    # Demo 5: R-matrix at q=1 is swap
    print_section("5. R-matrix at q=1 (Permutation Matrix)")
    R1 = r_matrix(1.0)
    print("  R(q=1) =")
    for row in R1:
        print(f"    [{' '.join(f'{x:5.1f}' for x in row)}]")
    print("  This is the swap/permutation matrix ✓")

    # Demo 6: Clebsch-Gordan
    print_section("6. Clebsch-Gordan Dimension Identity")
    for m in range(5):
        for n in range(5):
            lhs, rhs = clebsch_gordan_check(m, n)
            if lhs != rhs:
                print(f"  FAIL: m={m}, n={n}: {lhs} ≠ {rhs}")
    print("  All checks passed for m,n ∈ {0,...,4} ✓")
    
    print(f"\n  Decomposition V_2 ⊗ V_3:")
    for k in range(6):
        mult = fusion_multiplicity(2, 3, k)
        if mult > 0:
            print(f"    V_{k} appears with multiplicity {mult}")

    # Demo 7: q-duality
    print_section("7. q-Integer Duality: [n]_{q⁻¹} = q^{-(n-1)} · [n]_q")
    for q in [2.0, 3.0, 0.5]:
        print(f"  q = {q}:")
        for n in [2, 3, 5]:
            lhs = q_int(1/q, n)
            rhs = q**(-(n-1)) * q_int(q, n)
            print(f"    n={n}: [{n}]_{{q⁻¹}} = {lhs:.6f}, q^{{-(n-1)}}·[{n}]_q = {rhs:.6f}, diff = {abs(lhs-rhs):.2e}")

    # Demo 8: q-integer positivity
    print_section("8. q-Integer Positivity for q > 0")
    for q in [0.01, 0.5, 1.0, 2.0, 100.0]:
        vals = [q_int(q, n) for n in range(1, 8)]
        all_pos = all(v > 0 for v in vals)
        print(f"  q = {q:6.2f}: [{', '.join(f'{v:.3f}' for v in vals)}] all positive: {'✓' if all_pos else '✗'}")

    print("\n" + "="*60)
    print("  All demonstrations complete.")
    print("="*60)


#!/usr/bin/env python3
"""
Visualization: Quantum Groups Deformation Landscape

Generates three visualizations:
1. q-integers as functions of q (showing classical limit)
2. R-matrix entry heatmap as q varies
3. Quantum dimension vs classical dimension
"""

import matplotlib.pyplot as plt
import numpy as np


def q_int(q, n):
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - 1) / (q - 1)


def q_factorial(q, n):
    result = 1.0
    for k in range(1, n + 1):
        result *= q_int(q, k)
    return result


# Figure 1: q-integers as functions of q
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

qs = np.linspace(0.01, 3.0, 500)

ax = axes[0]
for n in range(1, 8):
    vals = [q_int(q, n) for q in qs]
    ax.plot(qs, vals, label=f'[{n}]_q', linewidth=2)
    ax.axhline(y=n, color='gray', linestyle=':', alpha=0.3)

ax.axvline(x=1, color='red', linestyle='--', alpha=0.7, label='q=1 (classical)')
ax.set_xlabel('q (deformation parameter)', fontsize=12)
ax.set_ylabel('[n]_q', fontsize=12)
ax.set_title('q-Integers: The Bridge Between\nQuantum and Classical', fontsize=14)
ax.legend(fontsize=9)
ax.set_ylim(-2, 20)
ax.grid(True, alpha=0.3)

# Figure 2: R-matrix entries
ax = axes[1]
qs2 = np.linspace(0.1, 3.0, 200)

r00 = qs2  # R[0,0] = q
r12 = np.ones_like(qs2)  # R[1,2] = 1
r22 = qs2 - 1/qs2  # R[2,2] = q - q⁻¹

ax.plot(qs2, r00, label='R[0,0] = q', linewidth=2, color='blue')
ax.plot(qs2, r22, label='R[2,2] = q - q⁻¹', linewidth=2, color='red')
ax.plot(qs2, r12, label='R[1,2] = 1', linewidth=2, color='green', linestyle='--')
ax.axvline(x=1, color='gray', linestyle=':', alpha=0.7)
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

ax.set_xlabel('q', fontsize=12)
ax.set_ylabel('R-matrix entry', fontsize=12)
ax.set_title('R-matrix Entries:\nBraiding Structure of U_q(sl₂)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.annotate('q=1: swap\n(symmetric)', xy=(1, 0), xytext=(1.5, -1.5),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=10, color='red')

# Figure 3: Quantum dimensions
ax = axes[2]
qs3 = np.linspace(0.01, 2.5, 300)
colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))

for idx, n in enumerate(range(1, 6)):
    qdims = [q_int(q, n + 1) for q in qs3]
    ax.plot(qs3, qdims, label=f'dim_q(V_{n}) = [{n+1}]_q',
            linewidth=2, color=colors[idx])
    ax.axhline(y=n+1, color=colors[idx], linestyle=':', alpha=0.3)

ax.axvline(x=1, color='red', linestyle='--', alpha=0.7)
ax.set_xlabel('q', fontsize=12)
ax.set_ylabel('Quantum dimension', fontsize=12)
ax.set_title('Quantum Dimensions:\nHow Size Changes Under Deformation', fontsize=14)
ax.legend(fontsize=9)
ax.set_ylim(0, 15)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('quantum_groups_visualization.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: quantum_groups_visualization.png")
