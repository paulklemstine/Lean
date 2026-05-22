#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Approximate Tower Rigidity

Demonstrates practical applications of the tower rigidity theorem:
1. Neural network depth requirements for tower-like functions
2. Cryptographic proof-of-work depth guarantees
3. Learning theory sample complexity bounds
4. Numerical precision requirements for tower computation

All examples use the algorithms from the research paper.
"""

import math
from typing import List, Tuple, Dict


def iter_exp(n: int, x: float) -> float:
    """Compute iterExp(n, x) with overflow protection."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
            if result > 1e308:
                return float('inf')
        except OverflowError:
            return float('inf')
    return result


def approx_depth_bound(n: int, eps: float) -> int:
    """Certified depth lower bound: n - ceil(log2(log2(1/eps))) - 3."""
    if eps <= 0:
        return n
    if eps >= 0.5:
        return 0
    try:
        log_inv_eps = math.log2(1.0 / eps)
        if log_inv_eps <= 1:
            return max(0, n - 3)
        loglog = math.ceil(math.log2(log_inv_eps))
    except (ValueError, OverflowError):
        return 0
    return max(0, n - loglog - 3)


# ─────────────────────────────────────────────────────────────────────
# Application 1: Neural Network Depth Requirements
# ─────────────────────────────────────────────────────────────────────

def neural_network_depth_analysis(
    target_depth: int,
    precision_bits: int = 32
) -> Dict[str, any]:
    """Analyze minimum neural network depth to approximate a tower function.
    
    For networks with exponential activation functions, the tower rigidity
    theorem gives a lower bound on the number of layers needed.
    
    Args:
        target_depth: Depth of the target tower function.
        precision_bits: Floating-point precision (bits).
    
    Returns:
        Dictionary with analysis results.
    
    Example:
        >>> result = neural_network_depth_analysis(10, 32)
        >>> print(f"Minimum layers: {result['min_layers']}")
    """
    # Machine epsilon for the given precision
    machine_eps = 2.0 ** (-precision_bits)
    
    # Minimum depth from rigidity theorem
    min_depth = approx_depth_bound(target_depth, machine_eps)
    
    # Depth savings from approximation
    savings = target_depth - min_depth
    
    # Maximum achievable savings
    loglog = math.ceil(math.log2(math.log2(1.0 / machine_eps))) if machine_eps > 0 else 0
    
    return {
        'target_depth': target_depth,
        'precision_bits': precision_bits,
        'machine_epsilon': machine_eps,
        'min_layers': min_depth,
        'depth_savings': savings,
        'max_possible_savings': loglog + 3,
        'savings_percentage': (savings / target_depth * 100) if target_depth > 0 else 0
    }


# ─────────────────────────────────────────────────────────────────────
# Application 2: Cryptographic Proof-of-Work
# ─────────────────────────────────────────────────────────────────────

def proof_of_work_security(
    tower_depth: int,
    adversary_speedup: float = 2.0,
    target_time_seconds: float = 10.0
) -> Dict[str, any]:
    """Analyze security of tower-function-based proof-of-work.
    
    In a tower-based PoW system, a prover must sequentially compute
    iterExp(n, challenge). The rigidity theorem guarantees that no
    adversary can significantly reduce the sequential depth.
    
    Args:
        tower_depth: Depth of the required computation.
        adversary_speedup: Clock speed advantage of adversary.
        target_time_seconds: Target computation time for honest prover.
    
    Returns:
        Dictionary with security analysis.
    """
    # Even with perfect approximation (eps close to 0), the adversary
    # needs at least depth n - O(1) sequential steps
    
    # If adversary uses eps-approximation to save depth:
    # They save at most log2(log2(1/eps)) + 3 levels
    # But they need eps small enough for the verifier to accept
    
    # Assuming verifier checks with 64-bit precision
    verifier_eps = 2.0 ** (-53)  # double precision
    max_savings = approx_depth_bound(tower_depth, verifier_eps)
    adversary_min_depth = max_savings
    
    # Effective speedup from depth reduction
    if tower_depth > 0:
        depth_ratio = adversary_min_depth / tower_depth
        effective_time = target_time_seconds * depth_ratio / adversary_speedup
    else:
        depth_ratio = 1.0
        effective_time = target_time_seconds
    
    return {
        'tower_depth': tower_depth,
        'adversary_speedup': adversary_speedup,
        'target_time': target_time_seconds,
        'adversary_min_depth': adversary_min_depth,
        'depth_ratio': depth_ratio,
        'adversary_min_time': effective_time,
        'security_maintained': effective_time > target_time_seconds * 0.5
    }


# ─────────────────────────────────────────────────────────────────────
# Application 3: Learning Theory Sample Complexity
# ─────────────────────────────────────────────────────────────────────

def learning_sample_complexity(
    tower_depth: int,
    target_error: float,
    confidence: float = 0.95
) -> Dict[str, any]:
    """Estimate sample complexity for learning tower functions.
    
    The tower rigidity theorem implies that learning iterExp(n)
    to precision eps requires Omega(iterExp(n, 10) / eps) samples
    under the uniform distribution on [1, 10].
    
    Args:
        tower_depth: Depth of the tower function to learn.
        target_error: Target approximation error.
        confidence: Desired confidence level.
    
    Returns:
        Dictionary with sample complexity estimates.
    """
    # Value range on [1, 10]
    max_val = iter_exp(tower_depth, 10.0)
    min_val = iter_exp(tower_depth, 1.0)
    
    if max_val == float('inf') or min_val == float('inf'):
        sample_lower_bound = float('inf')
        log_samples = float('inf')
    else:
        # Lower bound: Omega(range / eps)
        value_range = max_val - min_val
        sample_lower_bound = value_range / target_error
        try:
            log_samples = math.log10(sample_lower_bound)
        except (ValueError, OverflowError):
            log_samples = float('inf')
    
    # Depth bound requirement
    min_depth = approx_depth_bound(tower_depth, target_error)
    
    return {
        'tower_depth': tower_depth,
        'target_error': target_error,
        'sample_lower_bound': sample_lower_bound,
        'log10_samples': log_samples,
        'min_model_depth': min_depth,
        'practical_note': (
            'INFEASIBLE' if sample_lower_bound == float('inf')
            else 'FEASIBLE' if log_samples < 10
            else 'CHALLENGING'
        )
    }


# ─────────────────────────────────────────────────────────────────────
# Application 4: Numerical Precision Requirements
# ─────────────────────────────────────────────────────────────────────

def precision_requirements(tower_depth: int) -> Dict[str, any]:
    """Analyze precision requirements for tower function computation.
    
    The tower rigidity theorem implies that computing iterExp(n)
    to k bits of relative precision requires sequential depth
    at least n - O(log(k)) - O(1).
    
    Args:
        tower_depth: Depth of the tower function.
    
    Returns:
        Dictionary with precision analysis.
    """
    precisions = [16, 32, 64, 128, 256, 1024]
    
    results = []
    for bits in precisions:
        eps = 2.0 ** (-bits)
        min_depth = approx_depth_bound(tower_depth, eps)
        savings = tower_depth - min_depth
        results.append({
            'precision_bits': bits,
            'epsilon': eps,
            'min_depth': min_depth,
            'depth_savings': savings
        })
    
    return {
        'tower_depth': tower_depth,
        'analysis': results,
        'insight': (
            f"For tower depth {tower_depth}, increasing precision from "
            f"16 to 1024 bits changes the minimum depth by at most "
            f"{results[0]['min_depth'] - results[-1]['min_depth']} levels."
        )
    }


# ─────────────────────────────────────────────────────────────────────
# Main: Run all applications
# ─────────────────────────────────────────────────────────────────────

def main():
    print("="*65)
    print("APPLICATIONS OF APPROXIMATE TOWER RIGIDITY")
    print("="*65)
    
    # Application 1: Neural Networks
    print("\n" + "─"*65)
    print("APPLICATION 1: Neural Network Depth Requirements")
    print("─"*65)
    print("\nQuestion: How many layers does a neural network need to")
    print("approximate a tower function of depth n?")
    print()
    
    for n in [5, 10, 20, 50]:
        result = neural_network_depth_analysis(n, 32)
        print(f"  Target depth {n:>3}, 32-bit precision:")
        print(f"    Minimum layers: {result['min_layers']}")
        print(f"    Depth savings:  {result['depth_savings']} "
              f"({result['savings_percentage']:.0f}%)")
    
    print(f"\n  → Insight: Approximation saves at most ~{3 + math.ceil(math.log2(32))}")
    print(f"    layers regardless of target depth. The tower hierarchy is rigid.")
    
    # Application 2: Cryptography
    print("\n" + "─"*65)
    print("APPLICATION 2: Cryptographic Proof-of-Work Security")
    print("─"*65)
    print("\nQuestion: Can an adversary speed up tower-based PoW")
    print("by computing an approximation instead?")
    print()
    
    for depth in [10, 20, 50]:
        result = proof_of_work_security(depth)
        print(f"  Tower depth {depth:>3}:")
        print(f"    Adversary minimum depth: {result['adversary_min_depth']}")
        print(f"    Depth preserved: {result['depth_ratio']:.1%}")
        print(f"    Security: {'✓ MAINTAINED' if result['security_maintained'] else '✗ BROKEN'}")
    
    # Application 3: Learning Theory
    print("\n" + "─"*65)
    print("APPLICATION 3: Learning Tower Functions")
    print("─"*65)
    print("\nQuestion: How many samples to learn iterExp(n) to error ε?")
    print()
    
    for n in [2, 3, 4, 5]:
        result = learning_sample_complexity(n, 1e-3)
        lb = result['sample_lower_bound']
        if lb < 1e15:
            print(f"  iterExp({n}), eps=10^-3: ≥ {lb:.2e} samples [{result['practical_note']}]")
        else:
            print(f"  iterExp({n}), eps=10^-3: ≥ 10^{result['log10_samples']:.0f} samples [{result['practical_note']}]")
    
    # Application 4: Precision
    print("\n" + "─"*65)
    print("APPLICATION 4: Precision Requirements")
    print("─"*65)
    print("\nQuestion: How does numerical precision affect depth needs?")
    print()
    
    result = precision_requirements(20)
    print(f"  Tower depth: {result['tower_depth']}")
    print(f"  {'Precision':>12} | {'Min Depth':>10} | {'Depth Savings':>14}")
    print(f"  {'-'*12}-+-{'-'*10}-+-{'-'*14}")
    for r in result['analysis']:
        print(f"  {r['precision_bits']:>9} bit | {r['min_depth']:>10} | {r['depth_savings']:>14}")
    print(f"\n  → {result['insight']}")
    
    print("\n" + "="*65)
    print("CONCLUSION: Tower functions resist approximation at every scale.")
    print("The log₂(log₂(1/ε)) depth savings is essentially negligible")
    print("compared to the tower depth, making towers among the most")
    print("computationally rigid mathematical objects known.")
    print("="*65)


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
demo.py — Interactive Visualization of Approximate Tower Rigidity

Demonstrates the key mathematical phenomena:
1. Tower function growth by level
2. The derivative cascade product
3. The depth bound as a function of epsilon
4. Approximation error surface (3D)

Requires: numpy, matplotlib
"""

import math
from typing import List, Tuple

try:
    import numpy as np
    import matplotlib.pyplot as plt
    from mpl_toolkits.mplot3d import Axes3D  # noqa: F401
    HAS_PLOTTING = True
except ImportError:
    HAS_PLOTTING = False


def iter_exp(n: int, x: float) -> float:
    """Compute iterExp(n, x) = exp(exp(...exp(x)...)) with n applications of exp.
    
    iterExp(0, x) = x
    iterExp(n+1, x) = exp(iterExp(n, x))
    
    Returns float('inf') if the result overflows.
    """
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
            if result > 1e300:
                return float('inf')
        except OverflowError:
            return float('inf')
    return result


def iter_exp_array(n: int, x: 'np.ndarray') -> 'np.ndarray':
    """Vectorized iterExp for numpy arrays, clipping at 1e300."""
    result = x.copy().astype(float)
    for _ in range(n):
        result = np.clip(np.exp(result), -1e300, 1e300)
    return result


def deriv_iter_exp(n: int, x: float) -> float:
    """Compute deriv(iterExp(n))(x) using the cascade product formula.
    
    deriv(iterExp(n))(x) = prod_{k=1}^{n} iterExp(k, x)
    """
    if n == 0:
        return 1.0
    product = 1.0
    for k in range(1, n + 1):
        val = iter_exp(k, x)
        if val == float('inf'):
            return float('inf')
        product *= val
        if product > 1e300:
            return float('inf')
    return product


def approx_depth_bound(n: int, eps: float) -> int:
    """Compute the certified depth lower bound.
    
    approxDepthBound(n, eps) = n - ceil(log2(log2(1/eps))) - 3
    Floored at 0.
    """
    if eps <= 0:
        return n
    try:
        log_inv_eps = math.log2(1.0 / eps)
        if log_inv_eps <= 0:
            return 0
        loglog = math.ceil(math.log2(log_inv_eps))
    except (ValueError, OverflowError):
        loglog = 0
    return max(0, n - loglog - 3)


def plot_tower_growth():
    """Plot 1: Tower function growth by level."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    x = np.linspace(0.1, 2.5, 300)
    
    colors = ['#2196F3', '#FF9800', '#4CAF50', '#E91E63', '#9C27B0']
    
    for n in range(5):
        y = iter_exp_array(n, x)
        y_clipped = np.clip(y, 0, 1e4)
        ax1.plot(x, y_clipped, color=colors[n], linewidth=2,
                label=f'iterExp({n}, x)')
    
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('iterExp(n, x)', fontsize=12)
    ax1.set_title('Tower Function Growth by Level', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 500)
    ax1.grid(True, alpha=0.3)
    
    # Log scale version
    for n in range(5):
        y = iter_exp_array(n, x)
        y_positive = np.maximum(y, 1e-10)
        ax2.plot(x, y_positive, color=colors[n], linewidth=2,
                label=f'iterExp({n}, x)')
    
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('iterExp(n, x) [log scale]', fontsize=12)
    ax2.set_title('Tower Function Growth (Log Scale)', fontsize=14)
    ax2.set_yscale('log')
    ax2.legend(fontsize=10)
    ax2.set_ylim(1e-1, 1e100)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('tower_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tower_growth.png")


def plot_derivative_cascade():
    """Plot 2: Derivative cascade verification."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    x_vals = np.linspace(0.5, 2.0, 100)
    
    # Numerical derivative vs cascade product
    for n in [1, 2, 3]:
        # Numerical derivative
        dx = 1e-7
        deriv_numerical = []
        cascade_product = []
        
        for x in x_vals:
            f_plus = iter_exp(n, x + dx)
            f_minus = iter_exp(n, x - dx)
            if f_plus < 1e300 and f_minus < 1e300:
                deriv_numerical.append((f_plus - f_minus) / (2 * dx))
            else:
                deriv_numerical.append(float('nan'))
            cascade_product.append(deriv_iter_exp(n, x))
        
        axes[0].plot(x_vals, deriv_numerical, '--', linewidth=2,
                    label=f'Numerical deriv, n={n}')
        axes[0].plot(x_vals, cascade_product, ':', linewidth=2,
                    label=f'Cascade product, n={n}')
    
    axes[0].set_xlabel('x', fontsize=12)
    axes[0].set_ylabel("deriv(iterExp(n))(x)", fontsize=12)
    axes[0].set_title('Derivative: Numerical vs Cascade Product', fontsize=14)
    axes[0].legend(fontsize=8)
    axes[0].set_yscale('log')
    axes[0].grid(True, alpha=0.3)
    
    # Derivative ratio (should be close to 1)
    for n in [1, 2, 3]:
        ratios = []
        for x in x_vals:
            dx = 1e-7
            f_plus = iter_exp(n, x + dx)
            f_minus = iter_exp(n, x - dx)
            num = (f_plus - f_minus) / (2 * dx) if f_plus < 1e300 else float('nan')
            cas = deriv_iter_exp(n, x)
            if cas > 0 and not math.isnan(num):
                ratios.append(num / cas)
            else:
                ratios.append(float('nan'))
        
        axes[1].plot(x_vals, ratios, linewidth=2, label=f'n={n}')
    
    axes[1].axhline(y=1.0, color='red', linestyle='--', alpha=0.5)
    axes[1].set_xlabel('x', fontsize=12)
    axes[1].set_ylabel('Ratio (numerical / cascade)', fontsize=12)
    axes[1].set_title('Cascade Product Accuracy', fontsize=14)
    axes[1].legend(fontsize=10)
    axes[1].set_ylim(0.999, 1.001)
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('derivative_cascade.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: derivative_cascade.png")


def plot_depth_bound():
    """Plot 3: Depth bound as function of epsilon."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    eps_values = np.logspace(-100, -1, 500)
    
    colors = ['#2196F3', '#FF9800', '#4CAF50', '#E91E63', '#9C27B0']
    
    for i, n in enumerate([5, 8, 10, 15, 20]):
        bounds = [approx_depth_bound(n, eps) for eps in eps_values]
        ax1.plot(-np.log10(eps_values), bounds, color=colors[i % len(colors)],
                linewidth=2, label=f'n={n}')
    
    ax1.set_xlabel('-log₁₀(ε)', fontsize=12)
    ax1.set_ylabel('Depth Lower Bound', fontsize=12)
    ax1.set_title('Depth Bound vs Precision', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Depth savings (n - bound) as function of epsilon
    for i, n in enumerate([10, 15, 20]):
        savings = [n - approx_depth_bound(n, eps) for eps in eps_values]
        ax2.plot(-np.log10(eps_values), savings, color=colors[i % len(colors)],
                linewidth=2, label=f'n={n}')
    
    # Overlay theoretical log₂(log₂(1/ε)) + 3
    loglog_theory = []
    for eps in eps_values:
        try:
            ll = math.log2(math.log2(1/eps))
            loglog_theory.append(math.ceil(ll) + 3)
        except (ValueError, OverflowError):
            loglog_theory.append(float('nan'))
    
    ax2.plot(-np.log10(eps_values), loglog_theory, 'k--', linewidth=2,
            alpha=0.7, label='⌈log₂(log₂(1/ε))⌉ + 3')
    
    ax2.set_xlabel('-log₁₀(ε)', fontsize=12)
    ax2.set_ylabel('Depth Savings (n - bound)', fontsize=12)
    ax2.set_title('Maximum Depth Saved by Approximation', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('depth_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: depth_bound.png")


def plot_error_surface():
    """Plot 4: 3D approximation error surface."""
    fig = plt.figure(figsize=(12, 8))
    ax = fig.add_subplot(111, projection='3d')
    
    # Depth deficit k vs -log10(epsilon)
    k_vals = np.arange(0, 12)
    log_eps_vals = np.linspace(1, 100, 50)
    
    K, LE = np.meshgrid(k_vals, log_eps_vals)
    
    # Theoretical bound: k can be saved iff k <= log2(log2(1/eps)) + 3
    # i.e., 1/eps >= 2^(2^(k-3))
    # i.e., -log10(eps) >= 2^(k-3) * log10(2)
    feasible = np.zeros_like(K, dtype=float)
    for i in range(len(log_eps_vals)):
        for j in range(len(k_vals)):
            k = k_vals[j]
            le = log_eps_vals[i]
            eps = 10**(-le)
            bound = approx_depth_bound(20, eps)  # n=20
            max_savings = 20 - bound
            if k <= max_savings:
                feasible[i, j] = 1.0  # Feasible
            else:
                feasible[i, j] = 0.0  # Infeasible
    
    surf = ax.plot_surface(K, LE, feasible, cmap='RdYlGn',
                          edgecolor='none', alpha=0.8)
    
    ax.set_xlabel('Depth Deficit k', fontsize=11)
    ax.set_ylabel('-log₁₀(ε)', fontsize=11)
    ax.set_zlabel('Feasibility', fontsize=11)
    ax.set_title('Approximation Feasibility Surface (n=20)\n'
                'Green=feasible, Red=infeasible', fontsize=13)
    
    plt.tight_layout()
    plt.savefig('error_surface.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: error_surface.png")


def print_numerical_table():
    """Print numerical verification table."""
    print("\n" + "="*70)
    print("NUMERICAL VERIFICATION TABLE")
    print("="*70)
    print(f"{'n':>4} {'eps':>12} {'log2log2(1/eps)':>16} {'Depth Bound':>12} {'Full Depth':>11}")
    print("-"*70)
    
    test_cases = [
        (4, 1e-3), (5, 1e-3), (5, 1e-6),
        (6, 1e-3), (6, 1e-6), (6, 1e-12),
        (10, 1e-3), (10, 1e-6), (10, 1e-12), (10, 1e-100),
        (15, 1e-6), (15, 1e-100),
        (20, 1e-6), (20, 1e-100),
    ]
    
    for n, eps in test_cases:
        try:
            ll = math.ceil(math.log2(math.log2(1/eps)))
        except (ValueError, OverflowError):
            ll = 0
        bound = approx_depth_bound(n, eps)
        print(f"{n:>4} {eps:>12.0e} {ll:>16} {bound:>12} {n:>11}")
    
    print("="*70)


def print_tower_values():
    """Print tower function values to show explosive growth."""
    print("\n" + "="*50)
    print("TOWER FUNCTION VALUES: iterExp(n, 1)")
    print("="*50)
    for n in range(8):
        val = iter_exp(n, 1.0)
        if val < 1e100:
            print(f"  iterExp({n}, 1) = {val:.6f}")
        else:
            print(f"  iterExp({n}, 1) = OVERFLOW (> 10^300)")
    
    print("\n" + "="*50)
    print("DERIVATIVE CASCADE VALUES: deriv(iterExp(n))(1)")
    print("="*50)
    for n in range(6):
        val = deriv_iter_exp(n, 1.0)
        if val < 1e100:
            print(f"  deriv(iterExp({n}))(1) = {val:.6f}")
        else:
            print(f"  deriv(iterExp({n}))(1) = OVERFLOW (> 10^300)")


def main():
    """Run all demonstrations."""
    print("="*60)
    print("APPROXIMATE TOWER RIGIDITY — DEMONSTRATION")
    print("="*60)
    
    print_tower_values()
    print_numerical_table()
    
    print("\nGenerating visualizations...")
    
    if HAS_PLOTTING:
        try:
            plot_tower_growth()
            plot_derivative_cascade()
            plot_depth_bound()
            plot_error_surface()
            print("\nAll plots saved successfully!")
        except Exception as e:
            print(f"\nPlot generation failed: {e}")
            print("Numerical results printed above.")
    else:
        print("\nNumpy/matplotlib not available. Numerical results printed above.")
    
    print("\n" + "="*60)
    print("KEY INSIGHT: The depth savings from approximation grow as")
    print("log₂(log₂(1/ε)) — agonizingly slowly. To save 5 levels,")
    print("you need accuracy of 1 part in 2^(2^5) = 4,294,967,296.")
    print("Tower functions are approximation-theoretically rigid.")
    print("="*60)


if __name__ == '__main__':
    main()
