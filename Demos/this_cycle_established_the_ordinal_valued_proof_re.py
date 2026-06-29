"""
Demo: Ordinal Proof Refinement Systems (OrdinalPRS)

Numerical examples demonstrating the PRS framework:
1. Countdown PRS
2. Euclidean algorithm PRS
3. Stratified PRS dynamics
4. Descent chain analysis
5. Hardy hierarchy comparison
"""

from algorithms import (
    countdown_prs,
    euclid_prs,
    simulate_stratified_prs,
    StratifiedState,
    verify_descent_chain,
    hardy_omega,
    hardy_omega_sq,
)


def demo_countdown():
    """Demonstrate the countdown PRS."""
    print("=" * 60)
    print("DEMO 1: Countdown PRS")
    print("=" * 60)
    for n in [5, 10, 20]:
        result = countdown_prs(n)
        print(f"  Countdown({n}): {result.steps} steps, "
              f"energy: {result.energy_trace[0]} → {result.energy_trace[-1]}")
    print()


def demo_euclid():
    """Demonstrate the Euclidean algorithm PRS."""
    print("=" * 60)
    print("DEMO 2: Euclidean Algorithm PRS")
    print("=" * 60)
    test_cases = [(252, 105), (1071, 462), (48, 18), (100, 37), (987, 610)]
    for a, b in test_cases:
        result = euclid_prs(a, b)
        print(f"  gcd({a}, {b}): {result.steps} steps "
              f"(energy bound: {b}), "
              f"result = {result.final_state[0]}, "
              f"energy trace: {result.energy_trace}")
    print()


def demo_stratified():
    """Demonstrate stratified PRS dynamics."""
    print("=" * 60)
    print("DEMO 3: Stratified PRS (3 levels)")
    print("=" * 60)

    # Strategy: always work at the highest non-zero level, decrease by 1
    def highest_first(state: StratifiedState):
        for level in range(state.levels - 1, -1, -1):
            if state.energies[level] > 0:
                return (level, 1)
        return (0, 0)

    initial = [3, 2, 1]  # level 0=3, level 1=2, level 2=1
    trace = simulate_stratified_prs(initial, highest_first)

    print(f"  Initial energies: {initial}")
    print(f"  Total steps: {len(trace) - 1}")
    for i, state in enumerate(trace[:15]):
        print(f"    Step {i}: energies = {state.energies}, total = {state.total_energy}")
    if len(trace) > 15:
        print(f"    ... ({len(trace) - 15} more steps)")
        print(f"    Final: energies = {trace[-1].energies}, total = {trace[-1].total_energy}")
    print()


def demo_descent_chains():
    """Demonstrate descent chain length bounds."""
    print("=" * 60)
    print("DEMO 4: Descent Chain Analysis")
    print("=" * 60)

    # Generate maximal descent chains
    for start in [5, 10, 20]:
        chain = list(range(start, -1, -1))  # start, start-1, ..., 0
        valid = verify_descent_chain(chain)
        print(f"  Chain from {start}: length = {len(chain) - 1}, "
              f"bound = {start}, valid = {valid}")

    # Non-maximal chain (skipping values)
    chain = [10, 7, 3, 1, 0]
    valid = verify_descent_chain(chain)
    print(f"  Sparse chain from 10: {chain}, length = {len(chain) - 1}, "
          f"bound = 10, valid = {valid}")
    print()


def demo_hardy():
    """Compare stratified PRS step counts with Hardy hierarchy."""
    print("=" * 60)
    print("DEMO 5: Hardy Hierarchy Comparison")
    print("=" * 60)

    def highest_first(state: StratifiedState):
        for level in range(state.levels - 1, -1, -1):
            if state.energies[level] > 0:
                return (level, 1)
        return (0, 0)

    print("  M | L=1 steps | H_ω(M) | L=2 steps | H_{ω²}(M)")
    print("  " + "-" * 55)
    for M in range(1, 8):
        trace1 = simulate_stratified_prs([M], highest_first)
        trace2 = simulate_stratified_prs([M, M], highest_first)
        steps1 = len(trace1) - 1
        steps2 = len(trace2) - 1
        h_omega = hardy_omega(M)
        h_omega_sq = hardy_omega_sq(M)
        print(f"  {M} | {steps1:>9} | {h_omega:>6} | {steps2:>9} | {h_omega_sq:>10}")
    print()


def demo_prs_conjecture():
    """Test the tight PRS bound conjecture on Fin(n+1)."""
    print("=" * 60)
    print("DEMO 6: Tight PRS Bound Conjecture Test")
    print("=" * 60)

    # For each n, construct a PRS on {0, ..., n} where state k
    # steps to k-1, terminal at 0. This is the countdown PRS.
    # The conjecture says worst case is n steps.
    for n in range(1, 16):
        result = countdown_prs(n)
        bound_met = result.steps <= n
        print(f"  Fin({n+1}): worst case = {result.steps} steps, "
              f"bound = {n}, satisfied = {bound_met}")
    print()


if __name__ == "__main__":
    demo_countdown()
    demo_euclid()
    demo_stratified()
    demo_descent_chains()
    demo_hardy()
    demo_prs_conjecture()


"""
Visualization: PRS Energy Traces

Plots energy descent traces for various Proof Refinement Systems,
demonstrating the guaranteed termination property.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def simulate_countdown(n):
    """Simulate countdown PRS, return energy trace."""
    trace = []
    s = n
    while s > 0:
        trace.append(s)
        s -= 1
    trace.append(0)
    return trace


def simulate_euclid(a, b):
    """Simulate Euclidean algorithm PRS, return energy trace."""
    trace = [b]
    while b > 0:
        a, b = b, a % b
        trace.append(b)
    return trace


def simulate_halving(n):
    """Simulate halving PRS, return energy trace."""
    trace = [n]
    while n > 0:
        n = n // 2
        trace.append(n)
    return trace


def main():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("Proof Refinement Systems: Energy Descent Traces",
                 fontsize=14, fontweight='bold')

    # Plot 1: Countdown PRS
    ax = axes[0, 0]
    for n in [5, 10, 15, 20]:
        trace = simulate_countdown(n)
        ax.plot(trace, marker='o', markersize=3, label=f'n={n}')
    ax.set_xlabel('Step')
    ax.set_ylabel('Energy')
    ax.set_title('Countdown PRS')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 2: Euclidean Algorithm PRS
    ax = axes[0, 1]
    test_cases = [(252, 105), (1071, 462), (987, 610), (100, 37)]
    for a, b in test_cases:
        trace = simulate_euclid(a, b)
        ax.plot(trace, marker='o', markersize=3, label=f'gcd({a},{b})')
    ax.set_xlabel('Step')
    ax.set_ylabel('Energy (second component)')
    ax.set_title('Euclidean Algorithm PRS')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Plot 3: Halving PRS
    ax = axes[1, 0]
    for n in [100, 200, 500, 1000]:
        trace = simulate_halving(n)
        ax.plot(trace, marker='o', markersize=3, label=f'n={n}')
    ax.set_xlabel('Step')
    ax.set_ylabel('Energy')
    ax.set_title('Halving PRS (log-like descent)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Energy bound vs actual steps
    ax = axes[1, 1]
    ns = list(range(10, 200, 5))
    bounds = ns  # energy bound = initial state for countdown
    actual_euclid = []
    for n in ns:
        trace = simulate_euclid(n * 3, n)
        actual_euclid.append(len(trace) - 1)

    ax.plot(ns, bounds, 'r--', linewidth=2, label='Energy bound')
    ax.plot(ns, actual_euclid, 'b-', linewidth=1, label='Actual steps (Euclid)')
    ax.fill_between(ns, actual_euclid, bounds, alpha=0.2, color='green',
                     label='Slack')
    ax.set_xlabel('Initial energy')
    ax.set_ylabel('Steps')
    ax.set_title('Bound vs Actual Steps')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('prs_energy_traces.png', dpi=150, bbox_inches='tight')
    print("Saved prs_energy_traces.png")


if __name__ == "__main__":
    main()


"""
Visualization: Stratified PRS Energy Dynamics

Plots the evolution of energy at each level during stratified PRS simulation,
showing how energy cascades from higher to lower levels.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def simulate_stratified(initial_energies, max_steps=500):
    """
    Simulate a stratified PRS with highest-level-first strategy.
    Each step at level k decreases energy[k] by 1 and increases
    energy[j] by 1 for all j < k (worst case).

    Returns list of energy vectors.
    """
    L = len(initial_energies)
    energies = list(initial_energies)
    trace = [list(energies)]

    for _ in range(max_steps):
        if all(e == 0 for e in energies):
            break
        # Find highest non-zero level
        level = -1
        for k in range(L - 1, -1, -1):
            if energies[k] > 0:
                level = k
                break
        if level < 0:
            break
        # Perform step
        energies[level] -= 1
        for j in range(level):
            energies[j] += 1
        trace.append(list(energies))

    return trace


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Stratified PRS: Energy Cascade Dynamics",
                 fontsize=14, fontweight='bold')

    configs = [
        ([5], "1 Level (trivial)"),
        ([3, 3], "2 Levels: [3, 3]"),
        ([2, 2, 2], "3 Levels: [2, 2, 2]"),
        ([1, 1, 1, 1], "4 Levels: [1, 1, 1, 1]"),
    ]

    for idx, (init, title) in enumerate(configs):
        ax = axes[idx // 2, idx % 2]
        trace = simulate_stratified(init)
        L = len(init)
        steps = range(len(trace))

        for level in range(L):
            values = [t[level] for t in trace]
            ax.plot(steps, values, marker='.', markersize=2,
                    label=f'Level {level}', linewidth=1.5)

        totals = [sum(t) for t in trace]
        ax.plot(steps, totals, 'k--', linewidth=1, alpha=0.5, label='Total')

        ax.set_xlabel('Step')
        ax.set_ylabel('Energy')
        ax.set_title(f'{title} — {len(trace)-1} steps')
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('stratified_prs_dynamics.png', dpi=150, bbox_inches='tight')
    print("Saved stratified_prs_dynamics.png")


if __name__ == "__main__":
    main()
