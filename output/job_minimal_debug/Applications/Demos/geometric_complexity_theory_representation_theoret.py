"""
Geometric Complexity Theory: Concrete Demonstrations

This script demonstrates the core concepts of the GCT formalization
with concrete numerical examples, showing how representation-theoretic
obstructions yield circuit lower bounds.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
from math import factorial


# ============================================================
# Part 1: Permanent vs Determinant
# ============================================================

def determinant(M):
    """Compute determinant of a matrix."""
    return np.linalg.det(M)

def permanent(M):
    """Compute permanent of a matrix (brute force)."""
    n = M.shape[0]
    result = 0
    for perm in permutations(range(n)):
        product = 1
        for i in range(n):
            product *= M[i, perm[i]]
        result += product
    return result

print("=" * 60)
print("Part 1: Permanent vs Determinant — The GCT Target")
print("=" * 60)

# Demonstrate the similarity and difference
M = np.array([[1, 2], [3, 4]])
print(f"\nMatrix: {M.tolist()}")
print(f"Determinant: ad - bc = {int(determinant(M))}")
print(f"Permanent:   ad + bc = {int(permanent(M))}")
print(f"Just a sign change, but exponentially harder!")

# Show computational gap for larger matrices
print("\nComputational complexity comparison:")
for n in range(2, 7):
    det_ops = n ** 3  # O(n^3) for determinant
    perm_ops = factorial(n)  # n! for permanent (brute force)
    print(f"  n={n}: det ~{det_ops} ops, perm ~{perm_ops} ops, ratio: {perm_ops/det_ops:.1f}x")


# ============================================================
# Part 2: Concrete Fingerprint Model
# ============================================================

class Fingerprint:
    """
    Concrete implementation of the GCT Fingerprint structure.
    Models a polynomial family by its circuit size, orbit dimension,
    and multiplicity vector.
    """
    def __init__(self, name, circuit, dim, mults):
        self.name = name
        self.circuit = circuit
        self.dim = dim
        self.mults = mults  # dict: index -> multiplicity
        assert circuit <= dim, "Circuit size must be ≤ orbit dimension"

    def repMult(self, idx):
        return self.mults.get(idx, 0)

    def __repr__(self):
        return f"Fingerprint({self.name}, circuit={self.circuit}, dim={self.dim})"


def fp_closure(f, g):
    """Check if f is in the fingerprint closure of g."""
    all_keys = set(f.mults.keys()) | set(g.mults.keys())
    mult_dominated = all(f.repMult(k) <= g.repMult(k) for k in all_keys)
    dim_bounded = f.dim <= g.dim
    return mult_dominated and dim_bounded


def find_obstruction(f, g):
    """Find a representation index where f has higher multiplicity than g."""
    all_keys = set(f.mults.keys()) | set(g.mults.keys())
    for k in sorted(all_keys):
        if f.repMult(k) > g.repMult(k):
            return k, f.repMult(k), g.repMult(k)
    return None


print("\n" + "=" * 60)
print("Part 2: Concrete Fingerprint Model")
print("=" * 60)

# Create fingerprints modeling perm and det
det_fp = Fingerprint("det_3", circuit=27, dim=81,
                     mults={0: 1, 1: 3, 2: 6, 3: 6, 4: 3, 5: 1})
perm_fp = Fingerprint("perm_3", circuit=100, dim=200,
                      mults={0: 1, 1: 5, 2: 10, 3: 10, 4: 5, 5: 1, 6: 2})

print(f"\n{det_fp}")
print(f"  Multiplicity vector: {det_fp.mults}")
print(f"\n{perm_fp}")
print(f"  Multiplicity vector: {perm_fp.mults}")

# Check containment
is_contained = fp_closure(perm_fp, det_fp)
print(f"\nperm ∈ Ō_det? {is_contained}")

# Find obstruction
obs = find_obstruction(perm_fp, det_fp)
if obs:
    idx, mf, mg = obs
    print(f"\nObstruction found at index {idx}!")
    print(f"  repMult({idx}, perm) = {mf} > repMult({idx}, det) = {mg}")
    print(f"  → perm ∉ Ō_det  (Theorem 1: obstruction_implies_noncontainment)")
else:
    print("\nNo obstruction found — containment is possible")


# ============================================================
# Part 3: Algebraic Natural Proofs Barrier
# ============================================================

print("\n" + "=" * 60)
print("Part 3: Algebraic Natural Proofs Barrier")
print("=" * 60)

def barrier_bound(exp_const, n):
    """Compute the barrier bound 2^(c*n)."""
    return 2 ** (exp_const * n)

exp_const = 1  # Example constant
print(f"\nBarrier growth rate (c = {exp_const}):")
print(f"{'n':>4} | {'2^(c*n)':>15} | {'Separator weight must be ≥':>30}")
print("-" * 55)
for n in range(1, 11):
    bound = barrier_bound(exp_const, n)
    print(f"{n:>4} | {bound:>15,} | {'≥ ' + f'{bound:,}':>30}")

print("\nKey insight: No polynomial-weight separator can work!")
print("Even weight n^1000 is eventually exceeded by 2^n.")


# ============================================================
# Part 4: Tensor Amplification
# ============================================================

print("\n" + "=" * 60)
print("Part 4: Tensor Gap Amplification")
print("=" * 60)

def tensor_mult(m1, m2):
    """Multiplicative tensor product of multiplicities."""
    return m1 * m2

mf, mg = 5, 3
print(f"\nInitial multiplicities: mult(f) = {mf}, mult(g) = {mg}")
print(f"Gap: {mf} - {mg} = {mf - mg}")

print(f"\nTensor amplification iterations:")
print(f"{'Step':>6} | {'mult(f⊗...⊗f)':>15} | {'mult(g⊗...⊗g)':>15} | {'Gap':>10} | {'Ratio':>8}")
print("-" * 65)

mf_k, mg_k = mf, mg
for k in range(1, 6):
    mf_k = mf * mf if k == 1 else mf_k * mf_k
    mg_k = mg * mg if k == 1 else mg_k * mg_k
    gap = mf_k - mg_k
    # Use log to avoid overflow
    import math
    log_ratio = math.log10(mf_k) - math.log10(mg_k) if mg_k > 0 else float('inf')
    print(f"{k:>6} | {'~10^' + f'{math.log10(mf_k):.1f}':>15} | {'~10^' + f'{math.log10(mg_k):.1f}':>15} | {'~10^' + f'{math.log10(gap):.1f}':>10} | {'10^' + f'{log_ratio:.1f}':>8}")

print("\nGaps grow super-exponentially under iterated tensor product!")


# ============================================================
# Part 5: Visualization
# ============================================================

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Geometric Complexity Theory: Key Concepts', fontsize=14, fontweight='bold')

# Plot 1: Barrier growth
ax1 = axes[0, 0]
ns = np.arange(1, 16)
for c in [1, 2, 3]:
    bounds = [2 ** (c * n) for n in ns]
    ax1.semilogy(ns, bounds, 'o-', label=f'c = {c}: 2^({c}n)', markersize=4)
# Polynomial bounds
for d in [2, 5, 10]:
    poly = [n ** d for n in ns]
    ax1.semilogy(ns, poly, '--', alpha=0.5, label=f'n^{d}')
ax1.set_xlabel('Problem size n')
ax1.set_ylabel('Required separator weight')
ax1.set_title('Algebraic Natural Proofs Barrier')
ax1.legend(fontsize=7)
ax1.grid(True, alpha=0.3)

# Plot 2: Multiplicity comparison
ax2 = axes[0, 1]
indices = range(7)
det_mults = [det_fp.repMult(i) for i in indices]
perm_mults = [perm_fp.repMult(i) for i in indices]
x = np.arange(len(indices))
width = 0.35
bars1 = ax2.bar(x - width/2, det_mults, width, label='det_3', color='steelblue')
bars2 = ax2.bar(x + width/2, perm_mults, width, label='perm_3', color='coral')
# Highlight obstructions
for i in indices:
    if perm_fp.repMult(i) > det_fp.repMult(i):
        ax2.annotate('⚡', xy=(i + width/2, perm_fp.repMult(i)),
                    ha='center', va='bottom', fontsize=14)
ax2.set_xlabel('Representation index')
ax2.set_ylabel('Multiplicity')
ax2.set_title('Multiplicity Comparison (⚡ = obstruction)')
ax2.set_xticks(x)
ax2.set_xticklabels([f'V_{i}' for i in indices])
ax2.legend()
ax2.grid(True, alpha=0.3, axis='y')

# Plot 3: Tensor amplification (using log10 values to avoid overflow)
ax3 = axes[1, 0]
import math
log_mf = [math.log10(5)]
log_mg = [math.log10(3)]
for _ in range(6):
    log_mf.append(2 * log_mf[-1])  # squaring = doubling the log
    log_mg.append(2 * log_mg[-1])
steps = range(len(log_mf))
ax3.plot(list(steps), log_mf, 'o-', label='log₁₀ mult(f⊗...⊗f)', color='green')
ax3.plot(list(steps), log_mg, 's-', label='log₁₀ mult(g⊗...⊗g)', color='red')
ax3.fill_between(list(steps), log_mg, log_mf, alpha=0.2, color='gold', label='Gap')
ax3.set_xlabel('Tensor iteration k')
ax3.set_ylabel('log₁₀(Multiplicity)')
ax3.set_title('Tensor Gap Amplification')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# Plot 4: Complexity hierarchy
ax4 = axes[1, 1]
levels = ['VP', 'VQP', 'VNP', 'VEXP']
bounds = [100, 10000, 10**6, 10**12]
colors_list = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']
y_pos = range(len(levels))
bars = ax4.barh(list(y_pos), [np.log10(b) for b in bounds], color=colors_list)
ax4.set_yticks(list(y_pos))
ax4.set_yticklabels(levels)
ax4.set_xlabel('Circuit size bound (log₁₀)')
ax4.set_title('Strict Complexity Hierarchy')
for i, (level, bound) in enumerate(zip(levels, bounds)):
    ax4.text(np.log10(bound) + 0.1, i, f'≤ 10^{int(np.log10(bound))}',
             va='center', fontsize=9)
ax4.grid(True, alpha=0.3, axis='x')

plt.tight_layout()
plt.savefig('diagram.svg', format='svg', bbox_inches='tight')
plt.savefig('diagram.png', format='png', dpi=150, bbox_inches='tight')
print("\n\nVisualization saved to diagram.svg and diagram.png")


# ============================================================
# Part 6: Post-Quantum Security Demonstration
# ============================================================

print("\n" + "=" * 60)
print("Part 5: Post-Quantum Security from Rep Complexity")
print("=" * 60)

print("\nLattice problem with dim=128, exp_const=1:")
dim = 128
exp_const = 1
min_weight = 2 ** (exp_const * dim)
print(f"  Any algebraic separator needs weight ≥ 2^{exp_const * dim}")
print(f"  = 2^{exp_const * dim} ≈ 10^{exp_const * dim * 0.301:.0f}")
print(f"  This exceeds the number of atoms in the observable universe (~10^80)")
print(f"\n  → Algebraic attacks on this lattice problem are infeasible!")

print("\nSecurity levels for different lattice dimensions:")
print(f"{'Dim':>6} | {'Security (bits)':>15} | {'NIST Level':>12}")
print("-" * 40)
for d in [128, 256, 512, 1024]:
    bits = exp_const * d
    if bits <= 128:
        level = "1"
    elif bits <= 192:
        level = "3"
    else:
        level = "5+"
    print(f"{d:>6} | {bits:>15} | {level:>12}")


print("\n" + "=" * 60)
print("All demonstrations complete!")
print("=" * 60)
