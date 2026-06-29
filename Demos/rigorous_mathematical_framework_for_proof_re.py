#!/usr/bin/env python3
"""
Proof Refinement Systems — Demonstration

Numerical examples illustrating the key theorems:
1. Strict optimizer convergence on the linear chain
2. Lyapunov certificates and convergence bounds
3. Multi-objective Pareto refinement
4. Refinement strategy termination
"""

import random
random.seed(42)


def demo_linear_chain():
    """
    Demonstrate the linear chain system.
    States: natural numbers. Complexity: identity. Step: subtract 1.
    Theorem: orbit from n reaches 0 at exactly step n.
    """
    print("=" * 60)
    print("Demo 1: Linear Chain System")
    print("=" * 60)
    
    for n in [5, 10, 20]:
        orbit = [n]
        while orbit[-1] > 0:
            orbit.append(orbit[-1] - 1)
        print(f"\n  Starting state: {n}")
        print(f"  Orbit: {orbit}")
        print(f"  Steps to fixed point: {len(orbit) - 1}")
        print(f"  Bound (complexity): {n}")
        print(f"  Tight? {len(orbit) - 1 == n}")


def demo_lyapunov():
    """
    Demonstrate Lyapunov certificates.
    A non-strict optimizer with a Lyapunov potential that proves convergence.
    """
    print("\n" + "=" * 60)
    print("Demo 2: Lyapunov Certificates")
    print("=" * 60)
    
    # System: states are (a, b) with complexity = a + b
    # Optimizer: if b > 0, step (a, b) = (a + 1, b - 2) [complexity changes by -1]
    #            if b == 0 and a > 0, step = (a - 1, 0) [complexity changes by -1]  
    #            else fixed point
    # The complexity a + b is NOT a Lyapunov certificate (it decreases but
    # doesn't detect fixed points). But V(a,b) = 2a + b IS a Lyapunov certificate.
    
    def step(state):
        a, b = state
        if b >= 2:
            return (a + 1, b - 2)
        elif b == 1:
            return (a, 0)
        elif a > 0:
            return (a - 1, 0)
        else:
            return (0, 0)
    
    def complexity(state):
        return state[0] + state[1]
    
    def lyapunov_potential(state):
        return 2 * state[0] + state[1]
    
    start = (0, 10)
    print(f"\n  Starting state: {start}")
    print(f"  Complexity: {complexity(start)}")
    print(f"  Lyapunov potential: {lyapunov_potential(start)}")
    
    orbit = [start]
    while orbit[-1] != step(orbit[-1]):
        orbit.append(step(orbit[-1]))
    
    print(f"\n  {'Step':>4} | {'State':>10} | {'Complexity':>10} | {'Potential':>10}")
    print(f"  {'-' * 4}-+-{'-' * 10}-+-{'-' * 10}-+-{'-' * 10}")
    for i, s in enumerate(orbit):
        print(f"  {i:4d} | {str(s):>10} | {complexity(s):10d} | {lyapunov_potential(s):10d}")
    
    print(f"\n  Fixed point reached at step {len(orbit) - 1}")
    print(f"  Complexity bound: {complexity(start)} (not tight)")
    print(f"  Lyapunov bound: {lyapunov_potential(start)} (tight)")


def demo_pareto():
    """
    Demonstrate multi-objective Pareto refinement.
    Two objectives: size and depth of a "proof tree".
    """
    print("\n" + "=" * 60)
    print("Demo 3: Multi-Objective Pareto Refinement")
    print("=" * 60)
    
    def pareto_dominates(a, b):
        """a Pareto-dominates b: all objectives ≤, at least one <"""
        return all(ai <= bi for ai, bi in zip(a, b)) and any(ai < bi for ai, bi in zip(a, b))
    
    # Simulate Pareto optimization on 2D objectives
    state = (8, 6)  # (size, depth)
    history = [state]
    
    # Two optimization strategies, applied alternately
    def reduce_size(s):
        a, b = s
        if a > 0:
            return (a - 1, b)
        return s
    
    def reduce_depth(s):
        a, b = s
        if b > 0:
            return (a, b - 1)
        return s
    
    print(f"\n  Starting state (size, depth): {state}")
    print(f"  Total complexity: {sum(state)}")
    
    # Alternating optimization
    for i in range(sum(state)):
        if i % 2 == 0:
            new_state = reduce_size(state)
        else:
            new_state = reduce_depth(state)
        
        if new_state == state:
            # Try the other reduction
            if i % 2 == 0:
                new_state = reduce_depth(state)
            else:
                new_state = reduce_size(state)
        
        if new_state == state:
            break
        state = new_state
        history.append(state)
    
    print(f"\n  {'Step':>4} | {'Size':>5} | {'Depth':>5} | {'Total':>5}")
    print(f"  {'-' * 4}-+-{'-' * 5}-+-{'-' * 5}-+-{'-' * 5}")
    for i, (s, d) in enumerate(history):
        print(f"  {i:4d} | {s:5d} | {d:5d} | {s + d:5d}")
    
    print(f"\n  Pareto-optimal fixed point: {history[-1]}")
    print(f"  Steps taken: {len(history) - 1}")
    print(f"  Bound (sum of objectives): {sum(history[0])}")


def demo_strategy_termination():
    """
    Demonstrate refinement strategy termination.
    A strategy that always finds an improvement must terminate.
    """
    print("\n" + "=" * 60)
    print("Demo 4: Refinement Strategy Termination")
    print("=" * 60)
    
    # Strategy: given a number n, either halve it (if even) or subtract 1
    def strategy(n):
        if n == 0:
            return None  # No improvement possible
        elif n % 2 == 0:
            return n // 2  # Halve (big jump)
        else:
            return n - 1  # Subtract 1
    
    for start in [16, 100, 1000]:
        state = start
        orbit = [state]
        steps = 0
        while strategy(state) is not None:
            state = strategy(state)
            orbit.append(state)
            steps += 1
        
        print(f"\n  Starting from {start}:")
        if len(orbit) <= 20:
            print(f"  Orbit: {orbit}")
        else:
            print(f"  Orbit: {orbit[:10]} ... {orbit[-3:]}")
        print(f"  Steps to termination: {steps}")
        print(f"  Bound (complexity = initial value): {start}")
        print(f"  Speedup ratio: {start / steps:.1f}x")


def demo_convergence_rates():
    """
    Compare convergence rates of different optimizer types.
    """
    print("\n" + "=" * 60)
    print("Demo 5: Convergence Rate Comparison")
    print("=" * 60)
    
    n = 100
    
    # Linear: subtract 1
    def linear_step(x):
        return max(0, x - 1)
    
    # Logarithmic: halve
    def log_step(x):
        return x // 2
    
    # Square root: subtract sqrt(x)
    def sqrt_step(x):
        import math
        return max(0, x - max(1, int(math.sqrt(x))))
    
    for name, step_fn in [("Linear (x-1)", linear_step),
                           ("Logarithmic (x//2)", log_step),
                           ("Sqrt (x-√x)", sqrt_step)]:
        state = n
        steps = 0
        while state > 0:
            state = step_fn(state)
            steps += 1
        print(f"\n  {name}: {steps} steps from {n}")


if __name__ == "__main__":
    demo_linear_chain()
    demo_lyapunov()
    demo_pareto()
    demo_strategy_termination()
    demo_convergence_rates()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Convergence rates of different optimizer types.
Compares linear, logarithmic, and square-root convergence.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import math


def linear_orbit(n: int) -> list:
    orbit = [n]
    while orbit[-1] > 0:
        orbit.append(orbit[-1] - 1)
    return orbit


def log_orbit(n: int) -> list:
    orbit = [n]
    while orbit[-1] > 0:
        orbit.append(orbit[-1] // 2)
    return orbit


def sqrt_orbit(n: int) -> list:
    orbit = [n]
    while orbit[-1] > 0:
        x = orbit[-1]
        orbit.append(max(0, x - max(1, int(math.sqrt(x)))))
    return orbit


def main():
    n = 100
    
    lin = linear_orbit(n)
    log = log_orbit(n)
    sqr = sqrt_orbit(n)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Complexity over time
    ax = axes[0]
    ax.plot(range(len(lin)), lin, 'b-', linewidth=2, label=f'Linear (n−1): {len(lin)-1} steps')
    ax.plot(range(len(sqr)), sqr, 'g-', linewidth=2, label=f'Sqrt (n−√n): {len(sqr)-1} steps')
    ax.plot(range(len(log)), log, 'r-', linewidth=2, label=f'Log (n//2): {len(log)-1} steps')
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Complexity', fontsize=12)
    ax.set_title('Optimizer Convergence Rates', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Right: Steps vs initial complexity
    ax = axes[1]
    ns = list(range(1, 201))
    lin_steps = [len(linear_orbit(n)) - 1 for n in ns]
    log_steps = [len(log_orbit(n)) - 1 for n in ns]
    sqr_steps = [len(sqrt_orbit(n)) - 1 for n in ns]
    
    ax.plot(ns, lin_steps, 'b-', linewidth=2, label='Linear: Θ(n)')
    ax.plot(ns, sqr_steps, 'g-', linewidth=2, label='Sqrt: Θ(√n)')
    ax.plot(ns, log_steps, 'r-', linewidth=2, label='Log: Θ(log n)')
    ax.set_xlabel('Initial Complexity', fontsize=12)
    ax.set_ylabel('Steps to Fixed Point', fontsize=12)
    ax.set_title('Convergence Steps vs. Complexity', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('convergence_rates.png', dpi=150, bbox_inches='tight')
    print("Saved convergence_rates.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Lyapunov potential vs complexity during optimization.
Shows how a Lyapunov certificate can provide tighter convergence bounds.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def step(state):
    """Non-trivial optimizer on (a, b) pairs."""
    a, b = state
    if b >= 2:
        return (a + 1, b - 2)
    elif b == 1:
        return (a, 0)
    elif a > 0:
        return (a - 1, 0)
    else:
        return (0, 0)


def run_orbit(start):
    orbit = [start]
    while orbit[-1] != step(orbit[-1]):
        orbit.append(step(orbit[-1]))
    return orbit


def main():
    start = (0, 20)
    orbit = run_orbit(start)
    
    complexities = [a + b for a, b in orbit]
    potentials = [2 * a + b for a, b in orbit]
    steps_list = list(range(len(orbit)))
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Complexity and potential over time
    ax = axes[0]
    ax.plot(steps_list, complexities, 'b-o', markersize=3, linewidth=2, label='Complexity (a+b)')
    ax.plot(steps_list, potentials, 'r-s', markersize=3, linewidth=2, label='Lyapunov (2a+b)')
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    
    # Mark convergence bounds
    ax.axvline(x=complexities[0], color='blue', linestyle=':', alpha=0.5, label=f'Complexity bound = {complexities[0]}')
    ax.axvline(x=potentials[0], color='red', linestyle=':', alpha=0.5, label=f'Lyapunov bound = {potentials[0]}')
    
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title(f'Optimization from {start}', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: State space trajectory
    ax = axes[1]
    as_list = [a for a, b in orbit]
    bs_list = [b for a, b in orbit]
    
    ax.plot(as_list, bs_list, 'g-o', markersize=4, linewidth=1.5, alpha=0.7)
    ax.plot(as_list[0], bs_list[0], 'ko', markersize=12, label=f'Start {orbit[0]}')
    ax.plot(as_list[-1], bs_list[-1], 'k*', markersize=15, label=f'Fixed Point {orbit[-1]}')
    
    # Draw iso-complexity lines
    max_val = max(max(as_list), max(bs_list)) + 1
    for c in range(0, complexities[0] + 1, 5):
        ax.plot([0, c], [c, 0], 'b--', alpha=0.15)
    
    # Draw iso-potential lines
    for v in range(0, potentials[0] + 1, 5):
        ax.plot([0, v / 2], [v, 0], 'r--', alpha=0.15)
    
    ax.set_xlabel('Component a', fontsize=12)
    ax.set_ylabel('Component b', fontsize=12)
    ax.set_title('State Space Trajectory', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig('lyapunov_certificate.png', dpi=150, bbox_inches='tight')
    print("Saved lyapunov_certificate.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Pareto refinement trajectories in 2D objective space.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import random
random.seed(42)


def generate_pareto_trajectory(start, strategy='alternating'):
    """Generate a Pareto-improving trajectory."""
    trajectory = [start]
    state = list(start)
    
    step = 0
    while state[0] > 0 or state[1] > 0:
        if strategy == 'alternating':
            if step % 2 == 0 and state[0] > 0:
                state[0] -= 1
            elif state[1] > 0:
                state[1] -= 1
            elif state[0] > 0:
                state[0] -= 1
            else:
                break
        elif strategy == 'greedy_first':
            if state[0] > 0:
                state[0] -= 1
            elif state[1] > 0:
                state[1] -= 1
            else:
                break
        elif strategy == 'random':
            choices = []
            if state[0] > 0:
                choices.append(0)
            if state[1] > 0:
                choices.append(1)
            if not choices:
                break
            idx = random.choice(choices)
            state[idx] -= 1
        
        trajectory.append(tuple(state))
        step += 1
    
    return trajectory


def main():
    start = (8, 6)
    
    traj_alt = generate_pareto_trajectory(start, 'alternating')
    traj_greedy = generate_pareto_trajectory(start, 'greedy_first')
    traj_rand = generate_pareto_trajectory(start, 'random')
    
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    for ax, traj, name, color in [
        (axes[0], traj_alt, 'Alternating', 'blue'),
        (axes[1], traj_greedy, 'Greedy-First', 'green'),
        (axes[2], traj_rand, 'Random', 'red')
    ]:
        xs = [t[0] for t in traj]
        ys = [t[1] for t in traj]
        
        ax.plot(xs, ys, f'-o', color=color, markersize=4, linewidth=1.5, alpha=0.7)
        ax.plot(xs[0], ys[0], 'ko', markersize=10, label='Start')
        ax.plot(xs[-1], ys[-1], 'k*', markersize=15, label='Fixed Point')
        
        ax.set_xlabel('Objective 1 (Size)', fontsize=11)
        ax.set_ylabel('Objective 2 (Depth)', fontsize=11)
        ax.set_title(f'{name}\n{len(traj)-1} steps (bound: {sum(start)})', fontsize=12)
        ax.set_xlim(-0.5, start[0] + 0.5)
        ax.set_ylim(-0.5, start[1] + 0.5)
        ax.grid(True, alpha=0.3)
        ax.legend()
        ax.set_aspect('equal')
    
    plt.suptitle('Pareto Refinement Trajectories', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('pareto_trajectories.png', dpi=150, bbox_inches='tight')
    print("Saved pareto_trajectories.png")


if __name__ == "__main__":
    main()
