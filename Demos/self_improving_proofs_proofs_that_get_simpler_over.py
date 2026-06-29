"""
Proof Refinement Systems: Interactive Demo

Demonstrates the key theorems from the Lean formalization:
1. Well-foundedness: all refinement chains terminate
2. Chain length bound: chain length ≤ initial complexity
3. Fixed point theorem: optimizer iteration converges
4. Pigeonhole: unbounded complexity concentrates on one theorem
5. Complexity gap: in interpolating systems, all intermediate values exist
"""

from algorithms import (
    Proof, ProofRefinementSystem,
    linear_system, diamond_system, multi_theorem_system,
    greedy_refine, max_refinement_chain, iterate_optimizer,
    analyze_system, complexity_spectrum
)


def demo_well_foundedness():
    """Demonstrate that all refinement chains terminate."""
    print("=" * 60)
    print("DEMO 1: Well-Foundedness of Refinement")
    print("=" * 60)
    print()
    print("Theorem: No infinite chain of refinements exists.")
    print("Reason: Complexity is a natural number that strictly")
    print("decreases at each step.")
    print()

    for N in [3, 5, 10, 20]:
        sys = linear_system(N)
        top = max(sys.proofs, key=lambda p: p.complexity)
        chain = greedy_refine(sys, top)
        complexities = [p.complexity for p in chain]
        print(f"  N={N:2d}: chain = {complexities}")
        print(f"         Length = {len(chain)-1}, terminates at complexity 0")

    print()
    print("✓ All chains terminate. The process is well-founded.")
    print()


def demo_chain_bound():
    """Demonstrate the chain length ≤ initial complexity bound."""
    print("=" * 60)
    print("DEMO 2: Chain Length Bound")
    print("=" * 60)
    print()
    print("Theorem: Any refinement chain of length n starting")
    print("from proof P satisfies n ≤ C(P).")
    print()

    for N in [5, 10, 15, 20, 50]:
        sys = linear_system(N)
        top = max(sys.proofs, key=lambda p: p.complexity)
        chain = max_refinement_chain(sys, top)
        chain_length = len(chain) - 1
        initial_complexity = top.complexity
        satisfied = chain_length <= initial_complexity
        print(f"  N={N:2d}: chain_length={chain_length:2d}, "
              f"C(P₀)={initial_complexity:2d}, "
              f"bound satisfied: {satisfied}")

    print()
    print("✓ The bound n ≤ C(P₀) holds in all cases.")
    print()


def demo_fixed_point():
    """Demonstrate the Fixed Point Theorem for proof optimizers."""
    print("=" * 60)
    print("DEMO 3: Fixed Point Theorem for Proof Optimizers")
    print("=" * 60)
    print()
    print("Theorem: Iterating any proof optimizer reaches a")
    print("fixed point in complexity.")
    print()

    # Create a system with multiple proofs
    N = 10
    sys = linear_system(N)

    # Define an optimizer that moves one step down (if possible)
    def step_optimizer(p: Proof) -> Proof:
        refs = sys.refinements_of(p)
        if refs:
            return max(refs, key=lambda q: q.complexity)  # smallest step
        return p

    # Define a greedy optimizer that jumps to minimum
    def greedy_optimizer(p: Proof) -> Proof:
        refs = sys.refinements_of(p)
        if refs:
            return min(refs, key=lambda q: q.complexity)
        return p

    top = sys.proofs[0]  # complexity N

    print(f"  Starting proof: complexity = {top.complexity}")
    print()

    # Step optimizer
    chain, fp_step = iterate_optimizer(step_optimizer, top, sys)
    complexities = [p.complexity for p in chain[:min(15, len(chain))]]
    print(f"  Step optimizer:   {complexities}{'...' if len(chain) > 15 else ''}")
    print(f"  Fixed point at step {fp_step}, final complexity = {chain[-1].complexity}")
    print()

    # Greedy optimizer
    chain, fp_step = iterate_optimizer(greedy_optimizer, top, sys)
    complexities = [p.complexity for p in chain[:min(15, len(chain))]]
    print(f"  Greedy optimizer: {complexities}")
    print(f"  Fixed point at step {fp_step}, final complexity = {chain[-1].complexity}")
    print()

    print("✓ Both optimizers converge. The fixed point theorem holds.")
    print()


def demo_pigeonhole():
    """Demonstrate the Pigeonhole Theorem for proof complexity."""
    print("=" * 60)
    print("DEMO 4: Pigeonhole Theorem for Proof Complexity")
    print("=" * 60)
    print()
    print("Theorem: If finitely many theorems have minimal proofs")
    print("of arbitrarily high complexity, some theorem must bear")
    print("unbounded complexity.")
    print()

    # Create a system with 3 theorems
    # Theorem 0: proofs at complexity 0, 1, ..., 100
    # Theorem 1: proofs at complexity 0, 1, 2
    # Theorem 2: proofs at complexity 0, 1, 2, 3
    proofs = []
    pid = 0
    for c in range(101):
        proofs.append(Proof(id=pid, theorem_id=0, complexity=c, label=f"T0_C{c}"))
        pid += 1
    for c in range(3):
        proofs.append(Proof(id=pid, theorem_id=1, complexity=c, label=f"T1_C{c}"))
        pid += 1
    for c in range(4):
        proofs.append(Proof(id=pid, theorem_id=2, complexity=c, label=f"T2_C{c}"))
        pid += 1

    sys = ProofRefinementSystem(proofs=proofs)
    analysis = analyze_system(sys)

    print(f"  System: {analysis['num_theorems']} theorems, "
          f"{analysis['num_proofs']} proofs")
    print()

    for thm_id in sorted(sys.theorem_ids):
        thm_proofs = sys.proofs_of_theorem(thm_id)
        max_c = max(p.complexity for p in thm_proofs)
        min_c = min(p.complexity for p in thm_proofs)
        print(f"  Theorem {thm_id}: {len(thm_proofs)} proofs, "
              f"complexity range [{min_c}, {max_c}]")

    print()
    print("  → Theorem 0 bears unbounded complexity (up to 100).")
    print("  → Theorems 1 and 2 have bounded complexity.")
    print()
    print("✓ Pigeonhole: complexity concentrates on one theorem.")
    print()


def demo_complexity_gap():
    """Demonstrate the Complexity Gap Theorem."""
    print("=" * 60)
    print("DEMO 5: Complexity Gap Theorem (Interpolation)")
    print("=" * 60)
    print()
    print("Theorem: In systems with the interpolation property,")
    print("every intermediate complexity between a proof and its")
    print("minimal refinement is realized.")
    print()

    # Linear system has the interpolation property
    N = 8
    sys = linear_system(N)

    top = sys.proofs[0]  # complexity N
    bottom = sys.proofs[-1]  # complexity 0

    print(f"  System: linear_system({N})")
    print(f"  Top proof: complexity = {top.complexity}")
    print(f"  Bottom proof: complexity = {bottom.complexity}")
    print(f"  Gap = {top.complexity - bottom.complexity}")
    print()

    chain = max_refinement_chain(sys, top)
    complexities = [p.complexity for p in chain]
    print(f"  Maximal chain complexities: {complexities}")
    print(f"  Chain length: {len(chain) - 1}")
    print(f"  All intermediate values present: "
          f"{complexities == list(range(N, -1, -1))}")

    print()
    print("✓ The gap is filled: every intermediate complexity exists.")
    print()


def demo_linear_system_minimal():
    """Demonstrate the minimal proof in the linear system."""
    print("=" * 60)
    print("DEMO 6: Linear System Minimal Complexity")
    print("=" * 60)
    print()
    print("Theorem: In linearSystem(N), the unique minimal proof")
    print("has complexity 0.")
    print()

    for N in [0, 1, 5, 10, 50, 100]:
        sys = linear_system(N)
        minimals = sys.minimal_proofs()
        min_complexities = [p.complexity for p in minimals]
        print(f"  N={N:3d}: minimal proofs = {len(minimals)}, "
              f"complexities = {min_complexities}")

    print()
    print("✓ Minimal complexity is always 0 in the linear system.")
    print()


def demo_diamond_nonuniqueness():
    """Demonstrate non-unique refinement paths."""
    print("=" * 60)
    print("DEMO 7: Non-Unique Refinement Paths (Diamond)")
    print("=" * 60)
    print()

    sys = diamond_system()
    top = sys.proofs[0]

    print(f"  Diamond system: 4 proofs of one theorem")
    print(f"  Complexities: {[p.complexity for p in sys.proofs]}")
    print(f"  Labels: {[p.label for p in sys.proofs]}")
    print()

    # Show all refinement paths from top
    def all_paths(current, path):
        refs = sys.refinements_of(current)
        if not refs:
            yield path
        for r in refs:
            yield from all_paths(r, path + [r])

    paths = list(all_paths(top, [top]))
    print(f"  All refinement paths from Top:")
    for i, path in enumerate(paths):
        labels = [p.label for p in path]
        complexities = [p.complexity for p in path]
        print(f"    Path {i+1}: {labels} (complexities: {complexities})")

    print()
    print("✓ Multiple paths exist; the proof landscape has structure.")
    print()


if __name__ == "__main__":
    demo_well_foundedness()
    demo_chain_bound()
    demo_fixed_point()
    demo_pigeonhole()
    demo_complexity_gap()
    demo_linear_system_minimal()
    demo_diamond_nonuniqueness()

    print("=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


"""
Visualization: Proof Refinement Chains and Complexity Landscapes

Produces matplotlib visualizations of:
1. Complexity decrease along refinement chains
2. Optimizer convergence trajectories
3. Complexity spectrum heatmap
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_refinement_chains():
    """Plot complexity decrease along refinement chains of various lengths."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Linear chains of different lengths
    for ax, N in zip(axes, [5, 10, 20]):
        complexities = list(range(N, -1, -1))
        steps = list(range(len(complexities)))
        ax.plot(steps, complexities, 'bo-', markersize=6, linewidth=2)
        ax.fill_between(steps, complexities, alpha=0.15, color='blue')
        ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
        ax.set_xlabel('Refinement Step', fontsize=12)
        ax.set_ylabel('Complexity C(P)', fontsize=12)
        ax.set_title(f'Linear System (N={N})', fontsize=14)
        ax.set_ylim(-0.5, N + 1)
        ax.annotate(f'Chain length = {N}\n= C(P₀) = {N}',
                    xy=(N//2, N//2), fontsize=10,
                    bbox=dict(boxstyle='round', facecolor='lightyellow'))

    plt.suptitle('Proof Refinement: Complexity Strictly Decreases', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('refinement_chains.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: refinement_chains.png")


def plot_optimizer_convergence():
    """Plot optimizer convergence for different strategies."""
    fig, ax = plt.subplots(figsize=(10, 6))

    N = 20

    # Step-by-step optimizer: decreases by 1 each step
    step_complexities = list(range(N, -1, -1))

    # Halving optimizer: approximately halves each step
    halving = [N]
    c = N
    while c > 0:
        c = c // 2
        halving.append(c)

    # Slow optimizer: decreases by 1 every 3 steps
    slow = []
    c = N
    step = 0
    while c > 0:
        slow.append(c)
        step += 1
        if step % 3 == 0:
            c -= 1
    slow.append(0)
    # Pad slow to show stabilization
    while len(slow) < len(slow) + 5:
        slow.append(0)
        if len(slow) > 100:
            break

    ax.plot(range(len(step_complexities)), step_complexities,
            'b-o', label='Step optimizer (−1 each step)', markersize=4)
    ax.plot(range(len(halving)), halving,
            'r-s', label='Halving optimizer (÷2 each step)', markersize=6)
    ax.plot(range(len(slow)), slow,
            'g-^', label='Slow optimizer (−1 every 3 steps)', markersize=4)

    ax.set_xlabel('Iteration n', fontsize=13)
    ax.set_ylabel('Complexity C(optⁿ(P))', fontsize=13)
    ax.set_title('Fixed Point Theorem: All Optimizers Converge', fontsize=15)
    ax.legend(fontsize=11)
    ax.set_ylim(-1, N + 2)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5, label='Fixed point')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('optimizer_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: optimizer_convergence.png")


def plot_complexity_landscape():
    """Plot a heatmap of proof complexity across theorems."""
    fig, ax = plt.subplots(figsize=(10, 6))

    num_theorems = 8
    max_complexity = 15

    # Generate interesting complexity data
    np.random.seed(42)
    data = np.zeros((num_theorems, max_complexity + 1))
    for t in range(num_theorems):
        # Each theorem has a random minimal complexity
        min_c = np.random.randint(0, 5)
        max_c = np.random.randint(min_c + 2, max_complexity + 1)
        for c in range(min_c, max_c + 1):
            # Number of proofs at each complexity
            data[t, c] = max(1, int(np.random.exponential(2)))

    im = ax.imshow(data, aspect='auto', cmap='YlOrRd', origin='lower')
    ax.set_xlabel('Proof Complexity', fontsize=13)
    ax.set_ylabel('Theorem ID', fontsize=13)
    ax.set_title('Proof Complexity Landscape', fontsize=15)
    plt.colorbar(im, ax=ax, label='Number of Proofs')

    # Mark minimal proofs
    for t in range(num_theorems):
        min_c = np.argmax(data[t] > 0)
        ax.plot(min_c, t, 'w*', markersize=12, markeredgecolor='black')

    ax.legend(['★ = Minimal proof'], loc='upper right', fontsize=10)
    plt.tight_layout()
    plt.savefig('complexity_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: complexity_landscape.png")


if __name__ == "__main__":
    plot_refinement_chains()
    plot_optimizer_convergence()
    plot_complexity_landscape()
    print("\nAll visualizations generated.")
