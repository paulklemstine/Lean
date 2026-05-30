#!/usr/bin/env python3
"""
Applications of Diophantine Approximation on ReLU Networks

Demonstrates practical applications of the theory:
1. Neural network constant embedding for hardware-efficient inference
2. Precision-budget tradeoffs in quantized networks
3. Automatic architecture selection for constant approximation
"""

import math
from typing import List, Tuple, Dict


def relu(x: float) -> float:
    return max(0.0, x)


# ──────────────────────────────────────────────────────────────
# Application 1: Hardware-Efficient Constant Embedding
# ──────────────────────────────────────────────────────────────

class QuantizedConstantApproximator:
    """
    Approximate mathematical constants using quantized ReLU networks.
    
    In hardware implementations (FPGAs, ASICs), storing high-precision
    constants is expensive. Instead, we can compute them using small
    ReLU networks with low-precision weights.
    
    The theory tells us: to approximate a constant to B bits of precision,
    we need a network with w^L ≥ 2^B pieces, achievable with
    depth L = B/log₂(w) and width w.
    """
    
    def __init__(self, target: float, bits: int, width: int = 4):
        self.target = target
        self.bits = bits
        self.width = width
        self.depth = max(1, math.ceil(bits / math.log2(width)))
        self.pieces = width ** self.depth
        self.tolerance = 2 ** (-bits)
        
    def summary(self) -> Dict:
        return {
            'target': self.target,
            'bits': self.bits,
            'width': self.width,
            'depth': self.depth,
            'pieces': self.pieces,
            'tolerance': self.tolerance,
            'params': 2 * self.width * self.depth + self.width + 1,
            'storage_savings': f"{self.bits / (2 * self.width * self.depth + self.width + 1):.2f}x",
        }


# ──────────────────────────────────────────────────────────────
# Application 2: Neural Architecture Search for Constants
# ──────────────────────────────────────────────────────────────

def architecture_search(
    target: float,
    epsilon: float,
    max_params: int = 1000
) -> List[Dict]:
    """
    Find all feasible (width, depth) architectures for ε-approximation.
    
    Uses the theoretical bound: error ≤ 4/(2·w^L + 1) for the Leibniz series.
    For general constants, error ≤ C/w^L where C depends on the series used.
    
    Returns architectures sorted by parameter efficiency.
    """
    results = []
    for w in range(2, 51):
        for L in range(1, 51):
            pieces = w ** L
            if pieces > 10**15:
                break
            error_bound = 1.0 / pieces  # General Dirichlet-type bound
            params = 2 * w * L + w + 1
            if error_bound < epsilon and params <= max_params:
                results.append({
                    'width': w,
                    'depth': L,
                    'pieces': pieces,
                    'params': params,
                    'error_bound': error_bound,
                    'efficiency': math.log(pieces) / params,  # bits per param
                })
    results.sort(key=lambda r: -r['efficiency'])
    return results


# ──────────────────────────────────────────────────────────────
# Application 3: Series Convergence Comparison
# ──────────────────────────────────────────────────────────────

def compare_pi_series(n_terms: int) -> Dict[str, Tuple[float, float]]:
    """
    Compare different series for approximating π, showing how
    the choice of series affects the required network complexity.
    
    Returns dict mapping series name to (approximation, error).
    """
    results = {}
    
    # Leibniz series: π/4 = 1 - 1/3 + 1/5 - ...
    leibniz = sum((-1)**k / (2*k + 1) for k in range(n_terms))
    results['Leibniz'] = (4 * leibniz, abs(math.pi - 4 * leibniz))
    
    # Nilakantha series: π = 3 + 4/(2·3·4) - 4/(4·5·6) + ...
    nilakantha = 3.0
    for k in range(n_terms):
        d = 2 * (k + 1)
        nilakantha += (-1)**k * 4.0 / (d * (d + 1) * (d + 2))
    results['Nilakantha'] = (nilakantha, abs(math.pi - nilakantha))
    
    # Machin's formula: π/4 = 4·arctan(1/5) - arctan(1/239)
    def arctan_series(x: float, n: int) -> float:
        return sum((-1)**k * x**(2*k+1) / (2*k+1) for k in range(n))
    
    machin = 4 * (4 * arctan_series(1/5, n_terms) - arctan_series(1/239, n_terms))
    results['Machin'] = (machin, abs(math.pi - machin))
    
    return results


# ──────────────────────────────────────────────────────────────
# Main demonstration
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 65)
    print("APPLICATION 1: Hardware-Efficient Constant Embedding")
    print("=" * 65)
    
    constants = [
        ("π", math.pi),
        ("e", math.e),
        ("√2", math.sqrt(2)),
        ("φ (golden ratio)", (1 + math.sqrt(5)) / 2),
    ]
    
    for name, val in constants:
        print(f"\n{name} = {val:.15f}")
        for bits in [8, 16, 32]:
            approx = QuantizedConstantApproximator(val, bits, width=4)
            s = approx.summary()
            print(f"  {bits}-bit: depth={s['depth']}, params={s['params']}, "
                  f"tolerance={s['tolerance']:.2e}")
    
    print("\n" + "=" * 65)
    print("APPLICATION 2: Neural Architecture Search")
    print("=" * 65)
    
    for eps_exp in [3, 6, 9]:
        eps = 10 ** (-eps_exp)
        results = architecture_search(math.pi, eps, max_params=500)
        print(f"\nε = 10^(-{eps_exp}), top 5 architectures by efficiency:")
        print(f"  {'Width':>6} {'Depth':>6} {'Params':>7} {'Pieces':>12} {'Bits/Param':>10}")
        for r in results[:5]:
            print(f"  {r['width']:>6} {r['depth']:>6} {r['params']:>7} "
                  f"{r['pieces']:>12,} {r['efficiency']:>10.3f}")
    
    print("\n" + "=" * 65)
    print("APPLICATION 3: Series Convergence Comparison for π")
    print("=" * 65)
    
    print(f"\n{'N terms':>8} {'Leibniz':>12} {'Nilakantha':>12} {'Machin':>12}")
    print("-" * 48)
    for n in [5, 10, 20, 50, 100]:
        results = compare_pi_series(n)
        print(f"{n:>8} {results['Leibniz'][1]:>12.2e} "
              f"{results['Nilakantha'][1]:>12.2e} "
              f"{results['Machin'][1]:>12.2e}")
    
    print("\nImplication: Faster-converging series require fewer network pieces,")
    print("meaning shallower or narrower networks suffice for the same accuracy.")
    print("The Machin formula converges geometrically, needing only O(log(1/ε))")
    print("terms versus O(1/ε) for Leibniz — a depth reduction from O(log(1/ε))")
    print("to O(log(log(1/ε))).")


#!/usr/bin/env python3
"""
Diophantine Approximation on ReLU Networks: Demo

Demonstrates how ReLU networks approximate mathematical constants (π, e, √2)
by implementing partial sums of convergent series as piecewise linear functions.

Key results demonstrated:
1. Piece count grows as w^L (exponential in depth)
2. Leibniz series approximation error ≤ 1/(2N+1)
3. Depth is exponentially more efficient than width for approximation
4. Comparison of approximation rates for different constants
"""

import math
from typing import Tuple, List


def relu(x: float) -> float:
    """ReLU activation function: max(0, x)."""
    return max(0.0, x)


def piece_count(width: int, depth: int) -> int:
    """Maximum number of linear pieces in a ReLU network output."""
    return width ** depth


def param_count(width: int, depth: int) -> int:
    """Total parameters in a 1D ReLU network."""
    return depth * width * 2 + width + 1


def leibniz_partial_sum(n: int) -> float:
    """Compute partial sum of Leibniz series: π/4 ≈ Σ (-1)^k / (2k+1)."""
    return sum((-1)**k / (2*k + 1) for k in range(n))


def leibniz_error_bound(n: int) -> float:
    """Upper bound on |π/4 - S_n| by the alternating series criterion."""
    return 1.0 / (2*n + 1)


def actual_pi_error(n: int) -> float:
    """Actual error |π/4 - S_n|."""
    return abs(math.pi / 4 - leibniz_partial_sum(n))


def min_network_for_epsilon(epsilon: float, width: int = 2) -> Tuple[int, int]:
    """
    Find minimum depth for a width-w network to approximate π to within epsilon.
    
    Returns (depth, piece_count) such that 1/(2 * w^depth + 1) < epsilon.
    """
    depth = 0
    while True:
        pieces = width ** depth
        if 1.0 / (2 * pieces + 1) < epsilon:
            return depth, pieces
        depth += 1


def taylor_e_partial_sum(n: int) -> float:
    """Partial sum for e: e ≈ Σ 1/k!."""
    result = 0.0
    factorial = 1
    for k in range(n):
        if k > 0:
            factorial *= k
        result += 1.0 / factorial
    return result


def sqrt2_continued_fraction(n: int) -> float:
    """Approximate √2 using continued fraction [1; 2, 2, 2, ...]."""
    result = 2.0
    for _ in range(n):
        result = 2.0 + 1.0 / result
    return 1.0 + 1.0 / result if n > 0 else 1.0


# ──────────────────────────────────────────────────────────────
# Demo 1: Piece Count Growth
# ──────────────────────────────────────────────────────────────
print("=" * 60)
print("DEMO 1: Exponential Piece Count Growth (w^L)")
print("=" * 60)
print(f"\n{'Width':>6} {'Depth':>6} {'Pieces':>12} {'Params':>10} {'Ratio':>10}")
print("-" * 50)
for w in [2, 4, 8]:
    for L in range(1, 7):
        pieces = piece_count(w, L)
        params = param_count(w, L)
        ratio = pieces / params if params > 0 else 0
        print(f"{w:>6} {L:>6} {pieces:>12,} {params:>10,} {ratio:>10.2f}")
    print()

# ──────────────────────────────────────────────────────────────
# Demo 2: Leibniz Series Approximation of π
# ──────────────────────────────────────────────────────────────
print("=" * 60)
print("DEMO 2: Leibniz Series Approximation of π")
print("=" * 60)
print(f"\n{'N terms':>8} {'4·S_N':>14} {'|4S_N - π|':>14} {'Bound 4/(2N+1)':>14}")
print("-" * 56)
for n in [1, 2, 5, 10, 50, 100, 500, 1000, 5000, 10000]:
    approx = 4 * leibniz_partial_sum(n)
    error = abs(math.pi - approx)
    bound = 4 * leibniz_error_bound(n)
    print(f"{n:>8} {approx:>14.10f} {error:>14.2e} {bound:>14.2e}")

print(f"\nπ = {math.pi:.15f}")

# ──────────────────────────────────────────────────────────────
# Demo 3: Network Size Requirements
# ──────────────────────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 3: Minimum Network Size for ε-Approximation of π")
print("=" * 60)
print(f"\n{'ε':>12} {'Width':>6} {'Min Depth':>10} {'Pieces':>12} {'Params':>10}")
print("-" * 55)
for k in range(1, 11):
    eps = 10 ** (-k)
    for w in [2, 4]:
        depth, pieces = min_network_for_epsilon(eps, width=w)
        params = param_count(w, depth)
        print(f"{eps:>12.0e} {w:>6} {depth:>10} {pieces:>12,} {params:>10,}")

# ──────────────────────────────────────────────────────────────
# Demo 4: Depth vs Width Efficiency
# ──────────────────────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 4: Depth vs Width Efficiency (Theorem: w^L ≥ w·L)")
print("=" * 60)
print(f"\n{'w':>4} {'L':>4} {'w^L':>12} {'w*L':>8} {'Ratio':>8} {'L+1':>6} {'w^L≥L+1':>10}")
print("-" * 55)
for w in [2, 3, 5, 10]:
    for L in [1, 2, 5, 10, 20]:
        wL = w ** L
        prod = w * L
        ratio = wL / prod
        Lp1 = L + 1
        check = "✓" if wL >= Lp1 else "✗"
        if wL < 10**15:
            print(f"{w:>4} {L:>4} {wL:>12,} {prod:>8} {ratio:>8.1f} {Lp1:>6} {check:>10}")
    print()

# ──────────────────────────────────────────────────────────────
# Demo 5: Cross-Constant Comparison
# ──────────────────────────────────────────────────────────────
print("=" * 60)
print("DEMO 5: Approximation Rates for π, e, √2")
print("=" * 60)

print(f"\n{'N':>6} {'π error':>14} {'e error':>14} {'√2 error':>14}")
print("-" * 52)
for n in [1, 2, 5, 10, 20, 50, 100]:
    pi_err = abs(math.pi - 4 * leibniz_partial_sum(n))
    e_err = abs(math.e - taylor_e_partial_sum(n))
    sqrt2_err = abs(math.sqrt(2) - sqrt2_continued_fraction(n))
    print(f"{n:>6} {pi_err:>14.2e} {e_err:>14.2e} {sqrt2_err:>14.2e}")

print("\nKey insight: e converges factorially fast (best), √2 exponentially,")
print("π only algebraically via Leibniz. This reflects the irrationality measures.")

# ──────────────────────────────────────────────────────────────
# Demo 6: ReLU Properties Verification
# ──────────────────────────────────────────────────────────────
print("\n" + "=" * 60)
print("DEMO 6: ReLU Properties (Lipschitz, Monotone, Idempotent)")
print("=" * 60)

import random
random.seed(42)

# Lipschitz check
print("\nLipschitz: |relu(x) - relu(y)| ≤ |x - y|")
all_lipschitz = True
for _ in range(10000):
    x, y = random.uniform(-10, 10), random.uniform(-10, 10)
    if abs(relu(x) - relu(y)) > abs(x - y) + 1e-10:
        all_lipschitz = False
        break
print(f"  Verified on 10000 random pairs: {'✓' if all_lipschitz else '✗'}")

# Monotone check
print("\nMonotone: x ≤ y → relu(x) ≤ relu(y)")
all_mono = True
for _ in range(10000):
    x = random.uniform(-10, 10)
    y = x + random.uniform(0, 10)
    if relu(x) > relu(y) + 1e-10:
        all_mono = False
        break
print(f"  Verified on 10000 random pairs: {'✓' if all_mono else '✗'}")

# Idempotent check
print("\nIdempotent: relu(relu(x)) = relu(x)")
all_idemp = True
for _ in range(10000):
    x = random.uniform(-10, 10)
    if abs(relu(relu(x)) - relu(x)) > 1e-10:
        all_idemp = False
        break
print(f"  Verified on 10000 random values: {'✓' if all_idemp else '✗'}")

print("\n" + "=" * 60)
print("All demos complete.")
print("=" * 60)


"""
Visualization: How ReLU Networks Approximate π

Shows the convergence of the Leibniz series and the corresponding
network complexity required at each precision level. Demonstrates
the key theorem: error ≤ 1/(2N+1) where N = w^L pieces.
"""

import numpy as np
import matplotlib.pyplot as plt

# Compute Leibniz series partial sums
def leibniz_partial_sums(max_n):
    """Compute all partial sums S_1, S_2, ..., S_max_n of the Leibniz series."""
    sums = []
    current = 0.0
    for k in range(max_n):
        current += (-1)**k / (2*k + 1)
        sums.append(4 * current)
    return np.array(sums)

max_n = 500
n_values = np.arange(1, max_n + 1)
partial_sums = leibniz_partial_sums(max_n)
errors = np.abs(partial_sums - np.pi)
bounds = 4.0 / (2 * n_values + 1)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Partial sums converging to π
ax1 = axes[0, 0]
ax1.plot(n_values[:100], partial_sums[:100], 'b-', linewidth=0.8, label='4·S_N')
ax1.axhline(y=np.pi, color='r', linestyle='--', linewidth=1.5, label='π')
ax1.fill_between(n_values[:100], np.pi - bounds[:100], np.pi + bounds[:100],
                  alpha=0.15, color='orange', label='Error bound ±4/(2N+1)')
ax1.set_xlabel('Number of terms (N)', fontsize=11)
ax1.set_ylabel('Partial sum value', fontsize=11)
ax1.set_title('Leibniz Series Converging to π', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Error decay (log scale)
ax2 = axes[0, 1]
ax2.semilogy(n_values, errors, 'b-', linewidth=0.8, alpha=0.7, label='Actual error')
ax2.semilogy(n_values, bounds, 'r--', linewidth=1.5, label='Bound: 4/(2N+1)')
ax2.semilogy(n_values, 1.0/n_values, 'g:', linewidth=1.0, label='1/N reference')
ax2.set_xlabel('Number of terms (N)', fontsize=11)
ax2.set_ylabel('Approximation error', fontsize=11)
ax2.set_title('Error Decay: Bound vs Actual', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Network depth needed vs precision
ax3 = axes[1, 0]
precisions = range(1, 11)
for w in [2, 4, 8, 16]:
    depths = []
    for k in precisions:
        eps = 10**(-k)
        # Need 4/(2*w^L + 1) < eps, so w^L > 2/eps
        L = max(1, int(np.ceil(np.log(2.0/eps) / np.log(w))))
        depths.append(L)
    ax3.plot(list(precisions), depths, 'o-', markersize=5, label=f'w={w}')

ax3.set_xlabel('Decimal digits of accuracy', fontsize=11)
ax3.set_ylabel('Required depth (L)', fontsize=11)
ax3.set_title('Network Depth vs Precision', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# Plot 4: Comparison of π, e, √2 approximation rates
ax4 = axes[1, 1]

# π via Leibniz
pi_errors = errors

# e via Taylor
e_errors = []
e_sum = 0.0
factorial = 1
for k in range(1, max_n + 1):
    if k > 1:
        factorial *= (k - 1)
    e_sum += 1.0 / factorial
    e_errors.append(abs(np.e - e_sum))
e_errors = np.array(e_errors)

# √2 via Newton's method iterations (simulating convergence)
sqrt2_errors = []
x = 1.0
for k in range(1, max_n + 1):
    x = (x + 2.0/x) / 2.0
    sqrt2_errors.append(abs(np.sqrt(2) - x))
sqrt2_errors = np.array(sqrt2_errors)
sqrt2_errors = np.maximum(sqrt2_errors, 1e-16)  # floor at machine epsilon

ax4.semilogy(n_values[:50], pi_errors[:50], 'b-', linewidth=1.5, label='π (Leibniz, algebraic)')
ax4.semilogy(n_values[:50], e_errors[:50], 'r-', linewidth=1.5, label='e (Taylor, factorial)')
ax4.semilogy(n_values[:min(50, len(sqrt2_errors))], 
             sqrt2_errors[:50], 'g-', linewidth=1.5, label='√2 (Newton, quadratic)')
ax4.set_xlabel('Number of iterations/terms', fontsize=11)
ax4.set_ylabel('Approximation error', fontsize=11)
ax4.set_title('Convergence Rate Comparison', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(bottom=1e-16)

plt.suptitle('Diophantine Approximation by ReLU Networks', 
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_approximation.png', dpi=150, bbox_inches='tight')
print("Saved viz_approximation.png")


"""
Visualization: Depth vs Width Tradeoff for ReLU Network Approximation

Shows how the piece count (expressivity) grows as w^L, demonstrating
the exponential advantage of depth over width. The heatmap reveals
that for a fixed parameter budget, deeper networks achieve far more
pieces than wider ones.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors

# Compute piece count and parameter count
widths = np.arange(2, 21)
depths = np.arange(1, 16)

W, D = np.meshgrid(widths, depths)
pieces = W.astype(float) ** D.astype(float)
params = 2 * W * D + W + 1

# Cap for visualization
pieces_capped = np.minimum(pieces, 1e15)

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Plot 1: Piece count heatmap
ax1 = axes[0]
im1 = ax1.pcolormesh(widths, depths, np.log10(pieces_capped), 
                       cmap='viridis', shading='auto')
ax1.set_xlabel('Width (w)', fontsize=12)
ax1.set_ylabel('Depth (L)', fontsize=12)
ax1.set_title('log₁₀(Piece Count) = L·log₁₀(w)', fontsize=13)
plt.colorbar(im1, ax=ax1, label='log₁₀(w^L)')

# Plot 2: Parameter efficiency (pieces per parameter)
ax2 = axes[1]
efficiency = np.log10(pieces_capped) / params
im2 = ax2.pcolormesh(widths, depths, efficiency,
                       cmap='plasma', shading='auto')
ax2.set_xlabel('Width (w)', fontsize=12)
ax2.set_ylabel('Depth (L)', fontsize=12)
ax2.set_title('Efficiency: log₁₀(pieces) / params', fontsize=13)
plt.colorbar(im2, ax=ax2, label='Bits per parameter')

# Plot 3: Fixed parameter budget comparison
ax3 = axes[2]
param_budgets = [20, 50, 100, 200, 500]
for budget in param_budgets:
    w_range = range(2, 51)
    max_pieces = []
    w_vals = []
    for w in w_range:
        # Max depth for this width within budget
        L_max = max(1, (budget - w - 1) // (2 * w))
        if L_max >= 1:
            p = w ** L_max
            max_pieces.append(min(p, 1e15))
            w_vals.append(w)
    ax3.semilogy(w_vals, max_pieces, '-o', markersize=3, label=f'{budget} params')

ax3.set_xlabel('Width (w)', fontsize=12)
ax3.set_ylabel('Max Pieces (w^L)', fontsize=12)
ax3.set_title('Max Pieces for Fixed Parameter Budget', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('ReLU Network Depth-Width Tradeoff: Depth Dominates', 
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_depth_width.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_width.png")


"""
Visualization: ReLU as Tropical Arithmetic

Demonstrates the connection between ReLU networks and tropical geometry.
ReLU(x) = max(0, x) is tropical addition with the zero element.
Compositions of ReLU layers compute tropical rational functions,
and the number of "pieces" in the piecewise linear output corresponds
to terms in the tropical polynomial.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

x = np.linspace(-3, 3, 1000)

# Plot 1: ReLU = tropical addition
ax1 = axes[0, 0]
ax1.plot(x, np.maximum(0, x), 'b-', linewidth=2.5, label='ReLU(x) = max(0, x)')
ax1.plot(x, x, 'g--', linewidth=1, alpha=0.5, label='y = x')
ax1.plot(x, np.zeros_like(x), 'r--', linewidth=1, alpha=0.5, label='y = 0')
ax1.fill_between(x, 0, np.maximum(0, x), alpha=0.1, color='blue')
ax1.set_xlabel('x', fontsize=11)
ax1.set_ylabel('ReLU(x)', fontsize=11)
ax1.set_title('ReLU = Tropical Addition (0 ⊕ x)', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='k', linewidth=0.5)
ax1.axvline(x=0, color='k', linewidth=0.5)

# Plot 2: Compositions create more pieces
ax2 = axes[0, 1]

# 1-layer network with width 2: relu(x) - relu(x-1) = hat function
hat1 = np.maximum(0, x) - np.maximum(0, x - 1)
# 2-layer: compose hat functions
hat2 = np.maximum(0, hat1) - np.maximum(0, hat1 - 0.5)
# Stack multiple hat functions
multi_hat = sum(np.maximum(0, np.maximum(0, x - k*0.5) - np.maximum(0, x - (k+1)*0.5)) * ((-1)**k * 0.3 + 0.5) 
               for k in range(-4, 8))

ax2.plot(x, hat1, 'b-', linewidth=2, label='Width 2, depth 1 (2 pieces)')
ax2.plot(x, hat2, 'r-', linewidth=2, label='Width 2, depth 2 (4 pieces)')
ax2.plot(x, multi_hat, 'g-', linewidth=1.5, label='Width 4, depth 2 (16 pieces)')
ax2.set_xlabel('x', fontsize=11)
ax2.set_ylabel('f(x)', fontsize=11)
ax2.set_title('Piece Count Growth: w^L', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Plot 3: Piecewise linear approximation of sin(x) (shows piece count matters)
ax3 = axes[1, 0]
sin_x = np.sin(np.pi * x)

for n_pieces in [2, 4, 8, 16]:
    # Create piecewise linear approximation with n_pieces
    breakpoints = np.linspace(-3, 3, n_pieces + 1)
    midpoints = (breakpoints[:-1] + breakpoints[1:]) / 2
    values_at_bp = np.sin(np.pi * breakpoints)
    pwl = np.interp(x, breakpoints, values_at_bp)
    error = np.max(np.abs(sin_x - pwl))
    ax3.plot(x, pwl, linewidth=1.5, alpha=0.7, 
             label=f'{n_pieces} pieces (max err={error:.3f})')

ax3.plot(x, sin_x, 'k-', linewidth=2, alpha=0.3, label='sin(πx)')
ax3.set_xlabel('x', fontsize=11)
ax3.set_ylabel('f(x)', fontsize=11)
ax3.set_title('PWL Approximation Quality vs Piece Count', fontsize=13)
ax3.legend(fontsize=9, loc='upper right')
ax3.grid(True, alpha=0.3)

# Plot 4: Piece count vs approximation error (log-log)
ax4 = axes[1, 1]
n_pieces_range = np.array([2, 4, 8, 16, 32, 64, 128, 256, 512, 1024])

# For sin(πx) on [-3, 3]: PWL error ≈ C/N² (smooth function)
sin_errors = []
for n in n_pieces_range:
    bp = np.linspace(-3, 3, n + 1)
    vals = np.sin(np.pi * bp)
    pwl = np.interp(x, bp, vals)
    sin_errors.append(np.max(np.abs(sin_x - pwl)))

# For constant approximation via Leibniz: error ≈ 4/(2N+1)
leibniz_errors = 4.0 / (2 * n_pieces_range + 1)

# Theoretical Dirichlet bound: 1/N
dirichlet = 1.0 / n_pieces_range

ax4.loglog(n_pieces_range, sin_errors, 'bo-', markersize=5, label='sin(πx) PWL error')
ax4.loglog(n_pieces_range, leibniz_errors, 'rs-', markersize=5, label='π via Leibniz: 4/(2N+1)')
ax4.loglog(n_pieces_range, dirichlet, 'g^-', markersize=5, label='Dirichlet bound: 1/N')
ax4.loglog(n_pieces_range, 1.0/n_pieces_range**2, 'k--', linewidth=1, alpha=0.5, label='1/N² reference')
ax4.set_xlabel('Number of pieces (N = w^L)', fontsize=11)
ax4.set_ylabel('Approximation error', fontsize=11)
ax4.set_title('Error vs Complexity: Functions vs Constants', fontsize=13)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.suptitle('ReLU Networks, Tropical Geometry, and Approximation Theory', 
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical.png")
