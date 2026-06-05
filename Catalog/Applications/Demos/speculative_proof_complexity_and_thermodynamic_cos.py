#!/usr/bin/env python3
"""
Thermodynamic Cost of Proof — Numerical Demonstrations

Demonstrates the key results from the formalized theory connecting
proof complexity to Landauer's principle.
"""

import math

# Physical constants
k_B = 1.380649e-23  # Boltzmann constant (J/K)
T_room = 300        # Room temperature (K)
kT_room = k_B * T_room


def proof_cost(n: int, temperature: float = T_room, alphabet_size: int = 2) -> float:
    """Minimum thermodynamic cost of a proof of length n.
    
    cost(π) = n · kT · ln(b)
    """
    return n * k_B * temperature * math.log(alphabet_size)


def landauer_capacity(energy_budget: float, temperature: float = T_room,
                      alphabet_size: int = 2) -> tuple[int, int]:
    """Maximum proof length and theorem count within energy budget.
    
    Returns (max_length, max_theorems).
    """
    cost_per_bit = k_B * temperature * math.log(alphabet_size)
    max_length = int(energy_budget / cost_per_bit)
    max_theorems = 2 * alphabet_size ** max_length
    return max_length, max_theorems


def search_verification_gap(alphabet: int, max_len: int, verif_len: int) -> dict:
    """Compute the search-verification energy gap.
    
    Returns dictionary with gap exponent, search cost ratio, and energy ratio.
    """
    gap_exp = max_len - verif_len - 1
    search_cost_lower = alphabet ** gap_exp
    verif_cost = verif_len  # in units of kT·ln(b)
    search_cost = gap_exp   # in units of kT·ln(b)
    return {
        'gap_exponent': gap_exp,
        'search_steps_lower_bound': search_cost_lower,
        'verification_energy_bits': verif_cost,
        'search_energy_bits': search_cost,
        'energy_ratio': search_cost / verif_cost if verif_cost > 0 else float('inf'),
    }


def incompressible_fraction(alphabet: int, length: int) -> float:
    """Fraction of strings of length n that are incompressible.
    
    At least (b-1)/b of strings of length n are incompressible.
    """
    return (alphabet - 1) / alphabet


def meta_proof_blowup(alphabet: int, n: int) -> float:
    """Ratio of meta-proof space to proof space.
    
    Meta-proof space = b^(b^n), proof space = b^n.
    Returns log_b ratio = b^n - n.
    """
    return alphabet ** n - n


# ============================================================
# DEMONSTRATIONS
# ============================================================

print("=" * 60)
print("THERMODYNAMIC COST OF PROOF — DEMONSTRATIONS")
print("=" * 60)

# Demo 1: Basic proof costs
print("\n--- Demo 1: Proof Costs at Room Temperature (300K) ---")
for n in [10, 100, 1000, 10000]:
    cost_joules = proof_cost(n)
    print(f"  Proof of {n:>5} bits: {cost_joules:.4e} J "
          f"({cost_joules / 1.602e-19:.2f} eV)")

# Demo 2: Landauer capacity
print("\n--- Demo 2: Landauer Capacity Bounds ---")
print("  How many theorems can be proved within energy budget E?")
for e_label, e_joules in [("1 eV", 1.602e-19), ("1 keV", 1.602e-16),
                           ("1 J", 1.0), ("1 kWh", 3.6e6)]:
    cost_per_bit = k_B * T_room * math.log(2)
    max_len = int(e_joules / cost_per_bit)
    print(f"  E = {e_label:>6}: max proof length ≈ {max_len} bits, "
          f"max theorems ≈ 2^{max_len + 1}")

# Demo 3: Search-verification gap
print("\n--- Demo 3: Search-Verification Energy Gap ---")
for n, k in [(100, 10), (1000, 100), (10000, 1000)]:
    gap = search_verification_gap(2, n, k)
    print(f"  n={n:>5}, k={k:>4}: gap exponent = {gap['gap_exponent']}, "
          f"energy ratio = {gap['energy_ratio']:.1f}x")

# Demo 4: Incompressibility
print("\n--- Demo 4: Incompressible Fraction ---")
for b in [2, 3, 10, 256]:
    frac = incompressible_fraction(b, 100)
    print(f"  Alphabet size {b:>3}: {frac:.4f} of strings are incompressible "
          f"({frac*100:.1f}%)")

# Demo 5: Geometric capacity bound verification
print("\n--- Demo 5: Geometric Capacity Bound Verification ---")
print("  Verifying Σᵢ₌₀ⁿ bⁱ ≤ 2·bⁿ for small values:")
for b in [2, 3, 5]:
    for n in [1, 3, 5, 8]:
        actual_sum = sum(b**i for i in range(n + 1))
        bound = 2 * b**n
        tight = actual_sum / bound
        print(f"  b={b}, n={n:>2}: sum={actual_sum:>10}, 2·bⁿ={bound:>10}, "
              f"ratio={tight:.4f}")

# Demo 6: Computability barrier
print("\n--- Demo 6: Computability Barrier ---")
print("  For fixed proof length f, how many statements lack short proofs?")
for b, f, n in [(2, 10, 20), (2, 50, 100), (2, 100, 200)]:
    # Use logarithmic computation to avoid huge numbers
    log_ratio = (f + 1 - n) * math.log2(b)
    frac = max(0.0, 1 - 2 ** log_ratio)
    print(f"  b={b}, f={f:>3}, n={n:>3}: "
          f"2·b^f / b^n = 2^{f+1-n}, "
          f"uncovered fraction = {frac:.10f}")

# Demo 7: Meta-proof blowup
print("\n--- Demo 7: Meta-Proof Space Blowup ---")
for b, n in [(2, 3), (2, 5), (2, 10)]:
    proof_space = b**n
    meta_space_log = b**n  # log_b of meta space
    print(f"  b={b}, n={n:>2}: proof space = 2^{n}, "
          f"meta-proof space = 2^(2^{n}) = 2^{proof_space}")

# Demo 8: Proof cost additivity
print("\n--- Demo 8: Proof Cost Additivity ---")
for m, n in [(50, 80), (100, 200), (1000, 500)]:
    cost_m = proof_cost(m)
    cost_n = proof_cost(n)
    cost_sum = proof_cost(m + n)
    print(f"  cost({m}) + cost({n}) = {cost_m + cost_n:.4e} J, "
          f"cost({m+n}) = {cost_sum:.4e} J, "
          f"match: {abs(cost_m + cost_n - cost_sum) < 1e-30}")

print("\n" + "=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Thermodynamic Proof Cost Landscape

Generates plots showing the key relationships between proof length,
thermodynamic cost, and search-verification gaps.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def proof_cost_joules(n: float, T: float = 300.0, b: int = 2) -> float:
    """Minimum thermodynamic cost of a proof of length n."""
    k_B = 1.380649e-23
    return n * k_B * T * math.log(b)


def geometric_bound(b: int, n: int) -> int:
    """Upper bound 2*b^n on strings of length <= n."""
    return 2 * b ** n


def actual_sum(b: int, n: int) -> int:
    """Exact count of strings of length <= n."""
    return sum(b ** i for i in range(n + 1))


# --- Plot 1: Proof Cost vs Length ---
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

ns = np.arange(1, 501)
costs = [proof_cost_joules(n) for n in ns]
costs_ev = [c / 1.602e-19 for c in costs]

ax = axes[0, 0]
ax.plot(ns, costs_ev, 'b-', linewidth=2)
ax.set_xlabel('Proof Length (bits)', fontsize=12)
ax.set_ylabel('Minimum Cost (eV)', fontsize=12)
ax.set_title('Thermodynamic Proof Cost (T = 300K, binary)', fontsize=13)
ax.grid(True, alpha=0.3)
ax.annotate('Each bit costs kT·ln(2) ≈ 0.018 eV',
            xy=(250, proof_cost_joules(250) / 1.602e-19),
            fontsize=10, ha='center')

# --- Plot 2: Capacity Bound Tightness ---
ax = axes[0, 1]
ns_small = list(range(1, 16))
for b in [2, 3, 5]:
    ratios = [actual_sum(b, n) / geometric_bound(b, n) for n in ns_small]
    ax.plot(ns_small, ratios, 'o-', label=f'b = {b}', markersize=4)

ax.axhline(y=1.0, color='r', linestyle='--', alpha=0.5, label='Bound = 2·bⁿ')
ax.set_xlabel('Maximum Proof Length n', fontsize=12)
ax.set_ylabel('Actual / Bound', fontsize=12)
ax.set_title('Geometric Capacity Bound Tightness', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0.4, 1.05)

# --- Plot 3: Search-Verification Gap ---
ax = axes[1, 0]
n_vals = list(range(20, 201, 10))
for k_frac in [0.1, 0.2, 0.3, 0.5]:
    gaps = [n - int(k_frac * n) - 1 for n in n_vals]
    ax.semilogy(n_vals, [2**g for g in gaps], '-', linewidth=2,
                label=f'k/n = {k_frac}')

ax.set_xlabel('Search Space Exponent n', fontsize=12)
ax.set_ylabel('Energy Gap Factor (2^gap)', fontsize=12)
ax.set_title('Search-Verification Energy Gap (b = 2)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# --- Plot 4: Hierarchy & Meta-Proof Blowup ---
ax = axes[1, 1]
ks = list(range(1, 11))
for b in [2, 3, 5]:
    hierarchy_gaps = [(b - 1) * b**k for k in ks]
    ax.semilogy(ks, hierarchy_gaps, 's-', label=f'Hierarchy gap (b={b})', markersize=5)

ax.set_xlabel('Hierarchy Level k', fontsize=12)
ax.set_ylabel('Gap Size (b-1)·bᵏ', fontsize=12)
ax.set_title('Proof Complexity Hierarchy Gap', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('proof_cost_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: proof_cost_landscape.png")
plt.close()


# --- Standalone Plot: Computability Barrier ---
fig, ax = plt.subplots(figsize=(10, 6))

n_range = list(range(5, 31))
for b_val in [2, 3, 5]:
    for f_val in [3, 5, 10]:
        if f_val + 2 <= max(n_range):
            uncovered = []
            ns_valid = []
            for n in n_range:
                if f_val + 2 <= n:
                    frac = 1 - 2 * b_val**f_val / b_val**n
                    uncovered.append(max(0, frac))
                    ns_valid.append(n)
            if ns_valid and b_val == 2:
                ax.plot(ns_valid, uncovered, '-', linewidth=2,
                        label=f'b={b_val}, f={f_val}')

ax.set_xlabel('Statement Length n', fontsize=12)
ax.set_ylabel('Fraction Without Short Proofs', fontsize=12)
ax.set_title('Computability Barrier: Fraction of Statements Lacking Short Proofs', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

plt.tight_layout()
plt.savefig('computability_barrier.png', dpi=150, bbox_inches='tight')
print("Saved: computability_barrier.png")
plt.close()
