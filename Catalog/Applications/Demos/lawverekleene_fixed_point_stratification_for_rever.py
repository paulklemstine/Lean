#!/usr/bin/env python3
"""
Kleene Fixed-Point Stratification: Numerical Demonstrations

This script demonstrates the Lawvere-Kleene fixed-point theorem for
guarded trace semantics with concrete numerical examples:

1. A simple monotone function on the unit interval lattice
2. A tropical (min-plus) shortest-path circuit
3. Stabilization/collapse detection on a finite lattice
4. Circuit feedback loop unrolling
5. Matrix equation via Kleene iteration

Each example shows the Kleene chain f^[n](⊥) converging to the
least fixed point, illustrating the theorems proved in Lean.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Callable, List, Tuple, Optional

# ─── Example 1: Scalar Kleene chain on [0, 1] ────────────────────────

def demo_scalar_kleene():
    """
    Demonstrate Kleene iteration for f(x) = (x + c) / 2 on [0, 1].
    The least fixed point is c.
    Starting from ⊥ = 0, the chain converges monotonically.
    """
    c = 0.6
    step = lambda x: (x + c) / 2.0

    N = 20
    chain = [0.0]
    for i in range(N):
        chain.append(step(chain[-1]))

    fixed_pt = c

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(range(N+1), chain, 'bo-', markersize=4, label='$f^{[n]}(\\bot)$')
    ax1.axhline(y=fixed_pt, color='r', linestyle='--', label=f'Fixed point = {fixed_pt}')
    ax1.set_xlabel('Iteration n')
    ax1.set_ylabel('Value')
    ax1.set_title(f'Kleene Chain: $f(x) = (x + {c})/2$')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    errors = [abs(x - fixed_pt) for x in chain]
    ax2.semilogy(range(N+1), errors, 'ro-', markersize=4)
    ax2.set_xlabel('Iteration n')
    ax2.set_ylabel('|$f^{[n]}(\\bot)$ - fixed point|')
    ax2.set_title('Exponential Convergence')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/kleene_scalar.png', dpi=150, bbox_inches='tight')
    plt.close()

    print("=" * 60)
    print("Example 1: Scalar Kleene Chain")
    print("=" * 60)
    print(f"Step function: f(x) = (x + {c}) / 2")
    print(f"Bottom element: ⊥ = 0")
    print(f"Exact fixed point: {fixed_pt}")
    print(f"\nKleene chain (first 10 terms):")
    for i in range(min(11, len(chain))):
        print(f"  f^[{i}](⊥) = {chain[i]:.10f}")
    print(f"\nMonotonicity verified: {all(chain[i] <= chain[i+1] + 1e-15 for i in range(len(chain)-1))}")
    print(f"Convergence to fixed point: |f^[{N}](⊥) - lfp| = {errors[-1]:.2e}")
    print()


# ─── Example 2: Tropical (min-plus) shortest path ───────────────────

def demo_tropical_shortest_path():
    """
    Demonstrate Kleene iteration for shortest-path computation
    in a tropical (min-plus) semiring. The Bellman-Ford iteration
    is exactly the Kleene chain in the tropical semiring.
    """
    INF = float('inf')
    W = np.array([
        [0,   3,   INF, 7  ],
        [INF, 0,   2,   INF],
        [INF, INF, 0,   1  ],
        [2,   INF, INF, 0  ],
    ])
    n = W.shape[0]
    source = 0

    def tropical_step(dist):
        new_dist = dist.copy()
        for v in range(n):
            for u in range(n):
                if dist[u] + W[u][v] < new_dist[v]:
                    new_dist[v] = dist[u] + W[u][v]
        return new_dist

    bot = np.full(n, INF)
    bot[source] = 0

    N = 6
    chains = [bot.copy()]
    for i in range(N):
        chains.append(tropical_step(chains[-1]))

    print("=" * 60)
    print("Example 2: Tropical Shortest-Path Circuit")
    print("=" * 60)
    print(f"Graph with {n} nodes, source = {source}")
    print(f"\nWeight matrix:")
    for i in range(n):
        row = ["  ∞" if W[i][j] == INF else f"{W[i][j]:3.0f}" for j in range(n)]
        print(f"  [{', '.join(row)}]")

    print(f"\nKleene chain (Bellman-Ford iterations):")
    for i, d in enumerate(chains):
        vals = [f"{x:5.1f}" if x < INF else "    ∞" for x in d]
        print(f"  Step {i}: [{', '.join(vals)}]")

    for i in range(1, len(chains)):
        if np.array_equal(chains[i], chains[i-1]):
            print(f"\n✓ STABILIZATION at step {i-1}!")
            print(f"  By the Collapse Theorem: trace = f^[{i-1}](⊥)")
            print(f"  Shortest distances: {chains[i-1]}")
            break

    fig, ax = plt.subplots(figsize=(10, 5))
    for node in range(n):
        dists = [c[node] if c[node] < INF else np.nan for c in chains]
        ax.plot(range(N+1), dists, 'o-', markersize=6, label=f'Node {node}')

    ax.set_xlabel('Bellman-Ford Iteration (= Kleene step)')
    ax.set_ylabel('Shortest distance from source')
    ax.set_title('Tropical Kleene Chain = Bellman-Ford Shortest Path')
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demos/tropical_shortest_path.png', dpi=150, bbox_inches='tight')
    plt.close()
    print()


# ─── Example 3: Finite lattice with exact stabilization ─────────────

def demo_finite_stabilization():
    """
    Demonstrate the Collapse Theorem on a finite powerset lattice.
    """
    n = 4

    def step(S: set) -> set:
        return S | {(x + 1) % n for x in S}

    bot = {0}
    chain = [bot]
    for i in range(10):
        chain.append(step(chain[-1]))

    print("=" * 60)
    print("Example 3: Finite Lattice Stabilization (Collapse Theorem)")
    print("=" * 60)
    print(f"Lattice: P({{0,...,{n-1}}}) ordered by ⊆")
    print(f"Step: S ↦ S ∪ {{(x+1) mod {n} | x ∈ S}}")
    print(f"Bottom: {{0}}")
    print(f"\nKleene chain:")

    stab_idx = None
    for i, S in enumerate(chain):
        marker = ""
        if i > 0 and chain[i] == chain[i-1] and stab_idx is None:
            stab_idx = i - 1
            marker = "  ← STABILIZED"
        print(f"  f^[{i}](⊥) = {sorted(S)}{marker}")

    if stab_idx is not None:
        print(f"\n✓ Collapse Theorem applies!")
        print(f"  The chain stabilizes at N = {stab_idx}")
        print(f"  Therefore: sSup(chain) = trace = f^[{stab_idx}](⊥) = {sorted(chain[stab_idx])}")

    fp = chain[stab_idx]
    print(f"\n  Verification: step(f^[{stab_idx}](⊥)) = {sorted(step(fp))}")
    print(f"  Fixed point: {step(fp) == fp}")
    print()

    fig, ax = plt.subplots(figsize=(8, 4))
    sizes = [len(S) for S in chain]
    ax.plot(range(len(chain)), sizes, 'gs-', markersize=8)
    if stab_idx is not None:
        ax.axvline(x=stab_idx, color='r', linestyle='--', label=f'Stabilization at N={stab_idx}')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|$f^{[n]}(\\bot)$|')
    ax.set_title('Powerset Lattice: Stabilization of Kleene Chain')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(len(chain)))
    plt.tight_layout()
    plt.savefig('demos/finite_stabilization.png', dpi=150, bbox_inches='tight')
    plt.close()


# ─── Example 4: Circuit feedback unrolling ───────────────────────────

def demo_circuit_feedback():
    """
    Demonstrate trace = sSup(unrollings) for a feedback circuit.
    output = input + delay(α · output), with α < 1.
    """
    alpha = 0.7
    input_signal = 1.0
    step = lambda x: input_signal + alpha * x

    N = 30
    chain = [0.0]
    for i in range(N):
        chain.append(step(chain[-1]))

    trace = input_signal / (1 - alpha)

    print("=" * 60)
    print("Example 4: Circuit Feedback Loop (Temporal Trace)")
    print("=" * 60)
    print(f"Circuit: output = input + delay(α · output)")
    print(f"  input = {input_signal}, α = {alpha}")
    print(f"  Step function: f(x) = {input_signal} + {alpha} · x")
    print(f"  Exact trace (fixed point): {input_signal} / (1 - {alpha}) = {trace:.6f}")
    print(f"\nUnrolling chain:")
    for i in range(min(10, N+1)):
        err = abs(chain[i] - trace)
        print(f"  unroll({i}) = {chain[i]:.8f}  (error = {err:.2e})")
    print(f"  ...")
    print(f"  unroll({N}) = {chain[N]:.8f}  (error = {abs(chain[N] - trace):.2e})")
    print(f"\nMonotonicity: {all(chain[i] <= chain[i+1] + 1e-15 for i in range(len(chain)-1))}")
    print(f"trace = sSup(unrollings) ✓ (converges to {trace:.6f})")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    geo_sums = [input_signal * (1 - alpha**k) / (1 - alpha) for k in range(N+1)]
    ax1.plot(range(N+1), chain, 'b.-', markersize=3, alpha=0.7, label='Unrolling $f^{[n]}(\\bot)$')
    ax1.plot(range(N+1), geo_sums, 'g--', alpha=0.5, label='Geometric sum')
    ax1.axhline(y=trace, color='r', linestyle='-', linewidth=2, label=f'Trace = {trace:.4f}')
    ax1.set_xlabel('Unrolling depth n')
    ax1.set_ylabel('Signal value')
    ax1.set_title(f'Circuit Feedback: trace = sSup(unrollings)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    errors = [abs(x - trace) for x in chain]
    ax2.semilogy(range(N+1), errors, 'r.-', markersize=3)
    ax2.set_xlabel('Unrolling depth n')
    ax2.set_ylabel('|unroll(n) - trace|')
    ax2.set_title(f'Convergence Rate (geometric, ratio = {alpha})')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/circuit_feedback.png', dpi=150, bbox_inches='tight')
    plt.close()
    print()


# ─── Example 5: Matrix trace as Kleene limit ────────────────────────

def demo_matrix_trace():
    """
    Demonstrate the Kleene fixed point for matrix equations.
    Solve X = AX + B where spectral radius of A < 1.
    """
    A = np.array([[0.2, 0.1],
                  [0.15, 0.3]])
    B = np.array([1.0, 0.5])

    step = lambda x: A @ x + B

    N = 25
    chain = [np.zeros(2)]
    for i in range(N):
        chain.append(step(chain[-1]))

    exact = np.linalg.solve(np.eye(2) - A, B)

    print("=" * 60)
    print("Example 5: Matrix Equation via Kleene Iteration")
    print("=" * 60)
    print(f"Solve X = AX + B")
    print(f"A = {A.tolist()}")
    print(f"B = {B.tolist()}")
    print(f"Spectral radius of A: {max(abs(np.linalg.eigvals(A))):.4f}")
    print(f"Exact solution: X = {exact}")
    print(f"\nKleene chain (first 8):")
    for i in range(min(8, N+1)):
        err = np.linalg.norm(chain[i] - exact)
        print(f"  X_{i} = [{chain[i][0]:.6f}, {chain[i][1]:.6f}]  (error = {err:.2e})")
    print(f"  X_{N} = [{chain[N][0]:.6f}, {chain[N][1]:.6f}]  (error = {np.linalg.norm(chain[N] - exact):.2e})")
    print()


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Lawvere-Kleene Fixed-Point Stratification              ║")
    print("║  Numerical Demonstrations                               ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_scalar_kleene()
    demo_tropical_shortest_path()
    demo_finite_stabilization()
    demo_circuit_feedback()
    demo_matrix_trace()

    print("═" * 60)
    print("All demonstrations complete.")
    print("Plots saved to demos/ directory.")
    print("═" * 60)
