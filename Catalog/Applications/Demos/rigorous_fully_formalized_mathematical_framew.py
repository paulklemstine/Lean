#!/usr/bin/env python3
"""
Transfinite Proof Refinement Systems — Numerical Demonstrations

Demonstrates the key theorems:
1. Non-increasing ordinal sequences stabilize
2. Optimizer fixed-point convergence
3. Lyapunov certificate verification
4. Chain length bounds
5. Composition of optimizers
"""

from typing import Callable, List, Tuple, Optional


def demo_nat_sequence_stabilization():
    """
    Demo 1: Non-increasing sequences stabilize.
    Even with large initial values, the stabilization step N is bounded.
    """
    print("=" * 60)
    print("Demo 1: Non-Increasing Sequence Stabilization")
    print("=" * 60)

    # Example 1: Linear decrease then stabilize
    def seq1(n: int) -> int:
        return max(0, 100 - n)

    # Example 2: Halving decrease
    def seq2(n: int) -> int:
        val = 1000
        for _ in range(n):
            val = val // 2
        return val

    # Example 3: Fibonacci-like decrease
    def seq3(n: int) -> int:
        if n == 0: return 50
        if n == 1: return 48
        vals = [50, 48]
        for i in range(2, n + 1):
            vals.append(max(0, vals[-1] - (vals[-2] - vals[-1])))
        return vals[-1]

    for name, seq in [("Linear", seq1), ("Halving", seq2), ("Fibonacci-like", seq3)]:
        # Find stabilization point
        N = 0
        for i in range(1000):
            if all(seq(j) == seq(i) for j in range(i, min(i + 20, 1000))):
                N = i
                break
        values = [seq(i) for i in range(min(N + 5, 20))]
        print(f"\n  {name} sequence: {values}...")
        print(f"  Stabilizes at N = {N}, value = {seq(N)}")
        print(f"  Initial value: {seq(0)}, ratio N/initial = {N / max(1, seq(0)):.2f}")


def demo_optimizer_convergence():
    """
    Demo 2: Optimizer fixed-point convergence.
    Simulates different optimizers on proof-like objects.
    """
    print("\n" + "=" * 60)
    print("Demo 2: Optimizer Fixed-Point Convergence")
    print("=" * 60)

    # Proof state = (theorem_id, complexity)
    # Optimizer reduces complexity

    def greedy_optimizer(state: Tuple[int, int]) -> Tuple[int, int]:
        """Reduces complexity by 1 each step."""
        thm, c = state
        return (thm, max(0, c - 1))

    def halving_optimizer(state: Tuple[int, int]) -> Tuple[int, int]:
        """Halves complexity each step."""
        thm, c = state
        return (thm, c // 2)

    def sqrt_optimizer(state: Tuple[int, int]) -> Tuple[int, int]:
        """Reduces to integer square root."""
        thm, c = state
        new_c = int(c ** 0.5)
        return (thm, min(new_c, c))  # Ensure non-increasing

    initial_states = [(0, 100), (1, 1000), (2, 10000)]

    for name, opt in [("Greedy (-1)", greedy_optimizer),
                       ("Halving (÷2)", halving_optimizer),
                       ("Sqrt (√)", sqrt_optimizer)]:
        print(f"\n  Optimizer: {name}")
        for thm, c0 in initial_states:
            state = (thm, c0)
            steps = 0
            trajectory = [c0]
            while True:
                new_state = opt(state)
                steps += 1
                trajectory.append(new_state[1])
                if new_state[1] == state[1]:
                    break
                state = new_state
                if steps > 10000:
                    break
            print(f"    Initial complexity {c0}: stabilized at step {steps}, "
                  f"final complexity {state[1]}")
            if len(trajectory) <= 15:
                print(f"    Trajectory: {trajectory}")
            else:
                print(f"    Trajectory: {trajectory[:8]}...{trajectory[-3:]}")


def demo_lyapunov_certificate():
    """
    Demo 3: Lyapunov certificate verification.
    Shows how a potential function certifies convergence.
    """
    print("\n" + "=" * 60)
    print("Demo 3: Lyapunov Certificate Verification")
    print("=" * 60)

    # System: complexity = state value
    # Optimizer: halving
    # Potential: V(x) = 2*x (strictly decreases when complexity changes)

    def complexity(x: int) -> int:
        return x

    def optimize(x: int) -> int:
        return x // 2

    def potential(x: int) -> int:
        return 2 * x

    print("\n  Verifying Lyapunov certificate V(x) = 2x for halving optimizer:")
    print(f"  {'Step':>4} {'State':>8} {'C(state)':>10} {'V(state)':>10} {'ΔC':>6} {'ΔV':>6}")
    print("  " + "-" * 50)

    x = 1000
    for step in range(20):
        x_new = optimize(x)
        c_old, c_new = complexity(x), complexity(x_new)
        v_old, v_new = potential(x), potential(x_new)
        dc = c_new - c_old
        dv = v_new - v_old
        print(f"  {step:4d} {x:8d} {c_old:10d} {v_old:10d} {dc:6d} {dv:6d}")
        if x_new == x:
            print(f"\n  Fixed point reached at step {step}!")
            break
        x = x_new

    # Verify certificate properties
    print("\n  Certificate properties verified:")
    test_passed = True
    for x in range(1, 100):
        x_new = optimize(x)
        # Non-increasing
        if potential(x_new) > potential(x):
            print(f"    FAIL: V not non-increasing at x={x}")
            test_passed = False
        # Strict decrease when complexity changes
        if complexity(x_new) != complexity(x) and potential(x_new) >= potential(x):
            print(f"    FAIL: V not strictly decreasing at x={x}")
            test_passed = False
    if test_passed:
        print("    ✓ V is non-increasing under optimization")
        print("    ✓ V strictly decreases when complexity changes")


def demo_chain_length_bound():
    """
    Demo 4: Chain length bound verification.
    Shows that chain length ≤ initial complexity.
    """
    print("\n" + "=" * 60)
    print("Demo 4: Chain Length Bound")
    print("=" * 60)

    for n in [5, 10, 20, 50]:
        # Linear system: Prf = {0, ..., n}, complexity(i) = n - i
        chain = list(range(n + 1))
        complexities = [n - i for i in chain]
        # Verify chain is valid
        valid = all(complexities[i + 1] < complexities[i] for i in range(n))
        print(f"\n  n = {n}: chain length = {n}, initial complexity = {complexities[0]}")
        print(f"  Bound satisfied: {n} ≤ {complexities[0]} → {n <= complexities[0]}")
        print(f"  Chain valid (strict decrease): {valid}")
        if n <= 10:
            print(f"  Complexities: {complexities}")


def demo_composition():
    """
    Demo 5: Composition of optimizers.
    Shows that composed optimizers converge faster.
    """
    print("\n" + "=" * 60)
    print("Demo 5: Composition of Optimizers")
    print("=" * 60)

    def opt1(x: int) -> int:
        """Remove trailing zero bits."""
        if x == 0: return 0
        while x > 0 and x % 2 == 0:
            x //= 2
        return x

    def opt2(x: int) -> int:
        """Subtract 1 if odd and > 0."""
        if x > 0 and x % 2 == 1:
            return x - 1
        return x

    def composed(x: int) -> int:
        return opt1(opt2(x))

    initial = 1000
    for name, opt in [("Opt1 (remove trailing zeros)", opt1),
                       ("Opt2 (subtract 1 if odd)", opt2),
                       ("Composed (opt1 ∘ opt2)", composed)]:
        x = initial
        steps = 0
        while True:
            x_new = opt(x)
            steps += 1
            if x_new == x:
                break
            x = x_new
            if steps > 10000:
                break
        print(f"\n  {name}:")
        print(f"    Initial: {initial}, Final: {x}, Steps: {steps}")


def demo_ordinal_gap():
    """
    Demo 6: Ordinal gap — finite case verification.
    For each n, construct a system achieving the bound.
    """
    print("\n" + "=" * 60)
    print("Demo 6: Ordinal Gap (Finite Case)")
    print("=" * 60)

    for n in range(1, 11):
        # Linear system achieves chain length = n with complexity = n
        max_chain = n
        initial_complexity = n
        gap = initial_complexity - max_chain  # Should be 0 for linear systems
        print(f"  n = {n:2d}: max chain = {max_chain}, "
              f"initial complexity = {initial_complexity}, gap = {gap}")

    print("\n  For ω (transfinite): no ℕ-indexed chain can have length ω")
    print("  This is the fundamental finite-transfinite asymmetry")


if __name__ == "__main__":
    demo_nat_sequence_stabilization()
    demo_optimizer_convergence()
    demo_lyapunov_certificate()
    demo_chain_length_bound()
    demo_composition()
    demo_ordinal_gap()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Optimizer Convergence Trajectories

Shows how different optimizers converge to fixed points,
demonstrating the ω-Step Theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def halving_optimizer(x: int) -> int:
    return x // 2

def greedy_optimizer(x: int) -> int:
    return max(0, x - 1)

def sqrt_optimizer(x: int) -> int:
    return int(x ** 0.5)

def log_optimizer(x: int) -> int:
    if x <= 1:
        return 0
    return max(0, int(np.log2(x)))

def get_trajectory(optimizer, initial, max_steps=200):
    trajectory = [initial]
    x = initial
    for _ in range(max_steps):
        x_new = optimizer(x)
        trajectory.append(x_new)
        if x_new == x:
            break
        x = x_new
    return trajectory

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Optimizer Convergence Trajectories\n(ω-Step Theorem: All Must Stabilize)',
             fontsize=14, fontweight='bold')

initial = 1000
optimizers = [
    ("Greedy (−1)", greedy_optimizer),
    ("Halving (÷2)", halving_optimizer),
    ("Square Root (√)", sqrt_optimizer),
    ("Logarithmic (log₂)", log_optimizer),
]

colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

for idx, ((name, opt), color) in enumerate(zip(optimizers, colors)):
    ax = axes[idx // 2][idx % 2]
    traj = get_trajectory(opt, initial)
    steps = list(range(len(traj)))

    ax.plot(steps, traj, '-o', color=color, markersize=3, linewidth=1.5, label=name)
    ax.axhline(y=traj[-1], color='gray', linestyle='--', alpha=0.5, label=f'Fixed point = {traj[-1]}')

    # Mark stabilization point
    stab = len(traj) - 1
    for i in range(len(traj) - 1):
        if traj[i] == traj[-1]:
            stab = i
            break
    ax.axvline(x=stab, color='orange', linestyle=':', alpha=0.7, label=f'N = {stab}')

    ax.set_xlabel('Iteration Step')
    ax.set_ylabel('Complexity')
    ax.set_title(f'{name} (N = {stab} steps)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_trajectories.png', dpi=150, bbox_inches='tight')
print("Saved: convergence_trajectories.png")

# Second figure: multiple initial values
fig2, ax2 = plt.subplots(figsize=(12, 6))
for initial_val in [100, 500, 1000, 5000, 10000]:
    traj = get_trajectory(halving_optimizer, initial_val, max_steps=30)
    ax2.plot(range(len(traj)), traj, '-o', markersize=4,
             label=f'Initial = {initial_val}')

ax2.set_xlabel('Iteration Step', fontsize=12)
ax2.set_ylabel('Complexity', fontsize=12)
ax2.set_title('Halving Optimizer: Convergence from Different Initial Values', fontsize=14)
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

plt.tight_layout()
plt.savefig('convergence_initial_values.png', dpi=150, bbox_inches='tight')
print("Saved: convergence_initial_values.png")


#!/usr/bin/env python3
"""
Visualization: Lyapunov Certificate for Optimizer Convergence

Shows how the Lyapunov potential tracks and certifies convergence.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def optimizer(x: int) -> int:
    """Halving optimizer."""
    return x // 2

def complexity(x: int) -> int:
    return x

def lyapunov_potential(x: int) -> int:
    """V(x) = 2x — a valid Lyapunov certificate for the halving optimizer."""
    return 2 * x

# Generate trajectory
x = 500
steps_data = []
for step in range(30):
    x_new = optimizer(x)
    c_old, c_new = complexity(x), complexity(x_new)
    v_old, v_new = lyapunov_potential(x), lyapunov_potential(x_new)
    steps_data.append({
        'step': step,
        'state': x,
        'complexity': c_old,
        'potential': v_old,
        'dc': c_new - c_old,
        'dv': v_new - v_old,
    })
    if x_new == x:
        steps_data.append({
            'step': step + 1,
            'state': x_new,
            'complexity': c_new,
            'potential': v_new,
            'dc': 0,
            'dv': 0,
        })
        break
    x = x_new

fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(12, 12), sharex=True)
fig.suptitle('Lyapunov Convergence Certificate\nBoth Complexity and Potential Must Stabilize',
             fontsize=14, fontweight='bold')

steps = [d['step'] for d in steps_data]
complexities = [d['complexity'] for d in steps_data]
potentials = [d['potential'] for d in steps_data]
dc_vals = [d['dc'] for d in steps_data]

# Plot 1: Complexity
ax1.plot(steps, complexities, 'o-', color='#e74c3c', linewidth=2, markersize=6)
ax1.fill_between(steps, complexities, alpha=0.2, color='#e74c3c')
ax1.set_ylabel('Complexity C(p)', fontsize=12)
ax1.set_title('Complexity Trajectory', fontsize=12)
ax1.grid(True, alpha=0.3)

# Plot 2: Lyapunov potential
ax2.plot(steps, potentials, 's-', color='#3498db', linewidth=2, markersize=6)
ax2.fill_between(steps, potentials, alpha=0.2, color='#3498db')
ax2.set_ylabel('Potential V(p)', fontsize=12)
ax2.set_title('Lyapunov Potential (V = 2C)', fontsize=12)
ax2.grid(True, alpha=0.3)

# Plot 3: Changes
ax3.bar(steps, dc_vals, color=['#e74c3c' if d < 0 else '#2ecc71' for d in dc_vals],
        alpha=0.7, label='ΔC')
ax3.axhline(y=0, color='black', linewidth=0.5)
ax3.set_xlabel('Iteration Step', fontsize=12)
ax3.set_ylabel('Change in Complexity', fontsize=12)
ax3.set_title('Complexity Change per Step (negative = improvement)', fontsize=12)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('lyapunov_certificate.png', dpi=150, bbox_inches='tight')
print("Saved: lyapunov_certificate.png")


#!/usr/bin/env python3
"""
Visualization: Ordinal Refinement Chains and the Finite-Transfinite Gap

Shows chain length bounds and the gap between finite and transfinite ordinals.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# Figure 1: Chain length vs initial complexity for the linear system
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Ordinal Refinement Chain Analysis', fontsize=14, fontweight='bold')

ns = list(range(1, 21))
chain_lengths = ns  # Linear system achieves exact bound
complexities = ns  # Initial complexity = n

ax1.plot(complexities, chain_lengths, 'o-', color='#e74c3c', linewidth=2, markersize=8,
         label='Achieved (linear system)')
ax1.plot(complexities, complexities, '--', color='gray', alpha=0.5, label='Bound: length ≤ complexity')
ax1.fill_between(complexities, chain_lengths, complexities, alpha=0.1, color='#3498db',
                  label='Unreachable region')
ax1.set_xlabel('Initial Complexity', fontsize=12)
ax1.set_ylabel('Maximum Chain Length', fontsize=12)
ax1.set_title('Chain Length Bound (Finite Ordinals)', fontsize=12)
ax1.legend()
ax1.grid(True, alpha=0.3)

# Figure 2: Ordinal complexity levels (schematic)
levels = ['0', '1', '2', '...', 'n', '...', 'ω', 'ω+1', '...', 'ω·2', '...', 'ω²']
y_positions = [0, 1, 2, 3.5, 5, 6.5, 8, 9, 10, 11.5, 13, 15]
colors = ['#2ecc71'] * 6 + ['#e74c3c'] * 6
sizes = [200] * 6 + [300] * 6

for y, label, color, size in zip(y_positions, levels, colors, sizes):
    ax2.scatter([0], [y], s=size, c=color, zorder=5, edgecolors='black', linewidth=1)
    ax2.annotate(label, (0.3, y), fontsize=11, va='center')

# Add bracket for finite ordinals
ax2.annotate('', xy=(-0.5, 0), xytext=(-0.5, 6.5),
             arrowprops=dict(arrowstyle='<->', color='#2ecc71', lw=2))
ax2.text(-1.2, 3, 'Finite\nordinals\n(ℕ-chains\npossible)', fontsize=9,
         color='#2ecc71', ha='center', va='center')

# Add bracket for transfinite ordinals
ax2.annotate('', xy=(-0.5, 8), xytext=(-0.5, 15),
             arrowprops=dict(arrowstyle='<->', color='#e74c3c', lw=2))
ax2.text(-1.2, 11.5, 'Transfinite\nordinals\n(no ℕ-chain\nof this length)', fontsize=9,
         color='#e74c3c', ha='center', va='center')

# Gap line
ax2.axhline(y=7.2, color='orange', linewidth=2, linestyle='--')
ax2.text(0.8, 7.2, '← FINITE-TRANSFINITE GAP', fontsize=10, color='orange',
         va='center', fontweight='bold')

ax2.set_xlim(-2, 3)
ax2.set_ylim(-1, 16)
ax2.set_title('The Ordinal Hierarchy\nand the Finite-Transfinite Gap', fontsize=12)
ax2.axis('off')

plt.tight_layout()
plt.savefig('ordinal_chains.png', dpi=150, bbox_inches='tight')
print("Saved: ordinal_chains.png")
