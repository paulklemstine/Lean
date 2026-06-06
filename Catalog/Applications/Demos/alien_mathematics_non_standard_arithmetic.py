#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Numerical Demonstrations

Demonstrates key concepts from the formalized theory of non-standard
natural numbers via ultrapowers, including:
- Ultrafilter properties and U-large sets
- Existence of infinite elements
- The overspill principle
- Transfer of arithmetic properties
- Descending chains from infinite elements
"""

import random
from typing import Callable, List, Set, Tuple
from fractions import Fraction

# =============================================================================
# Demo 1: Simulating a Free Ultrafilter
# =============================================================================

def demo_free_ultrafilter():
    """
    Simulate a free ultrafilter on ℕ using a probabilistic model.
    
    A true free ultrafilter is non-constructive (requires AC), but we can
    approximate one by deciding membership based on density: a set S is
    "U-large" if its natural density exceeds 1/2.
    
    This approximation captures the key property: finite sets are small,
    cofinite sets are large.
    """
    print("=" * 60)
    print("Demo 1: Simulating a Free Ultrafilter")
    print("=" * 60)
    
    N = 10000  # simulation universe
    
    # Check various sets
    test_sets = {
        "Even numbers": lambda i: i % 2 == 0,
        "Odd numbers": lambda i: i % 2 == 1,
        "Multiples of 3": lambda i: i % 3 == 0,
        "Numbers > 100": lambda i: i > 100,
        "{0, 1, ..., 50}": lambda i: i <= 50,
        "Primes < 1000": lambda i: is_prime(i) and i < 1000,
        "All of ℕ": lambda i: True,
        "Empty set": lambda i: False,
    }
    
    for name, pred in test_sets.items():
        count = sum(1 for i in range(N) if pred(i))
        density = count / N
        is_large = density > 0.5
        print(f"  {name:30s}  density={density:.4f}  U-large: {is_large}")
    
    # Key property: finite sets are always small
    finite_set = set(range(100))
    density = len(finite_set) / N
    print(f"\n  Finite set {{0,...,99}}:       density={density:.4f}  → SMALL (as expected)")
    print(f"  Its complement:              density={1-density:.4f}  → LARGE (free ultrafilter property)")

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

# =============================================================================
# Demo 2: Infinite Elements in the Ultrapower
# =============================================================================

def demo_infinite_elements():
    """
    Demonstrate that the identity sequence (0, 1, 2, 3, ...) represents
    an "infinite" element in the ultrapower — it exceeds every standard n.
    """
    print("\n" + "=" * 60)
    print("Demo 2: Infinite Elements in the Ultrapower")
    print("=" * 60)
    
    N = 10000
    identity = list(range(N))  # the identity sequence
    
    for standard_n in [10, 100, 1000, 5000]:
        exceeds = sum(1 for i in range(N) if identity[i] > standard_n)
        fraction = exceeds / N
        print(f"  {{i | id(i) > {standard_n:5d}}} has {exceeds:5d}/{N} = {fraction:.4f} of indices")
        print(f"    → {'U-large (cofinite complement)' if fraction > 0.5 else 'NOT U-large'}")
    
    # Compare with a constant sequence (standard element)
    constant_42 = [42] * N
    for standard_n in [10, 100]:
        exceeds = sum(1 for i in range(N) if constant_42[i] > standard_n)
        fraction = exceeds / N
        print(f"  {{i | const_42(i) > {standard_n:3d}}} has {exceeds:5d}/{N} = {fraction:.4f}")
        print(f"    → {('U-large' if fraction > 0.5 else 'NOT U-large')} (standard element)")

# =============================================================================
# Demo 3: The Overspill Principle
# =============================================================================

def demo_overspill():
    """
    Demonstrate the overspill principle: if P(n) holds for all standard n,
    then {i | ∀ k ≤ i, P(k)} = ℕ (trivially U-large).
    
    More interesting: demonstrate with a property that holds "up to a point"
    and see where overspill fails.
    """
    print("\n" + "=" * 60)
    print("Demo 3: The Overspill Principle")
    print("=" * 60)
    
    N = 10000
    
    # Property 1: "k < 100" — holds for all k < 100, fails at k = 100
    print("\n  Property P(k) = 'k < 100':")
    for threshold in [50, 99, 100, 200]:
        count = sum(1 for i in range(N) if all(k < 100 for k in range(min(threshold, i+1))))
        # Actually: {i | ∀ k ≤ i, k < 100} = {0, 1, ..., 98}
        overspill_set = sum(1 for i in range(N) if i < 100)
        frac = overspill_set / N
        print(f"    {{i | ∀ k ≤ i, k < 100}} has {overspill_set} elements → density {frac:.4f}")
        break  # same for all thresholds
    
    # Property 2: "k is not prime or k < 1000" — demonstrates overspill failure
    print("\n  Property P(k) = 'True' (holds for all k):")
    overspill_set = N  # {i | ∀ k ≤ i, True} = ℕ
    print(f"    {{i | ∀ k ≤ i, True}} = all of ℕ → density 1.0")
    print(f"    → OVERSPILL SUCCEEDS: the set is all of ℕ")
    
    # Property 3: Bertrand's postulate
    print("\n  Property P(k) = 'Bertrand: ∃ prime p with k < p ≤ 2k' (for k ≥ 1):")
    failures = []
    for k in range(1, 1001):
        has_prime = any(is_prime(p) for p in range(k + 1, 2 * k + 1))
        if not has_prime:
            failures.append(k)
    print(f"    Failures in [1, 1000]: {failures if failures else 'NONE'}")
    print(f"    → Bertrand holds for all standard k, overspills to non-standard!")

# =============================================================================
# Demo 4: Transfer of Algebraic Properties
# =============================================================================

def demo_transfer():
    """
    Demonstrate that algebraic identities transfer to the ultrapower.
    Since they hold pointwise for ALL indices, the relevant sets are all of ℕ.
    """
    print("\n" + "=" * 60)
    print("Demo 4: Transfer of Algebraic Properties")
    print("=" * 60)
    
    N = 100
    random.seed(42)
    
    f = [random.randint(0, 1000) for _ in range(N)]
    g = [random.randint(0, 1000) for _ in range(N)]
    h = [random.randint(0, 1000) for _ in range(N)]
    
    # Check commutativity
    comm_add = sum(1 for i in range(N) if f[i] + g[i] == g[i] + f[i])
    comm_mul = sum(1 for i in range(N) if f[i] * g[i] == g[i] * f[i])
    assoc = sum(1 for i in range(N) if (f[i] + g[i]) + h[i] == f[i] + (g[i] + h[i]))
    distrib = sum(1 for i in range(N) if f[i] * (g[i] + h[i]) == f[i] * g[i] + f[i] * h[i])
    
    print(f"  Add commutativity: {comm_add}/{N} indices agree  → {'TRANSFERS' if comm_add == N else 'FAILS'}")
    print(f"  Mul commutativity: {comm_mul}/{N} indices agree  → {'TRANSFERS' if comm_mul == N else 'FAILS'}")
    print(f"  Add associativity: {assoc}/{N} indices agree  → {'TRANSFERS' if assoc == N else 'FAILS'}")
    print(f"  Distributivity:    {distrib}/{N} indices agree  → {'TRANSFERS' if distrib == N else 'FAILS'}")
    
    # Zero product property
    print("\n  Zero-product property (integral domain):")
    for _ in range(5):
        a = random.randint(0, 10)
        b = random.randint(0, 10)
        if a * b == 0:
            print(f"    {a} × {b} = 0 → a=0: {a==0}, b=0: {b==0}, a=0 or b=0: {a==0 or b==0}")

# =============================================================================
# Demo 5: Descending Chains and Well-Ordering Failure
# =============================================================================

def demo_descending_chain():
    """
    Demonstrate descending chains from an infinite element.
    Starting from [id], compute [id]-1, [id]-2, ..., [id]-k
    and show each step is strictly decreasing on a U-large set.
    """
    print("\n" + "=" * 60)
    print("Demo 5: Descending Chains (Well-Ordering Failure)")
    print("=" * 60)
    
    N = 10000
    
    print(f"\n  Starting from the infinite element [id] = (0, 1, 2, 3, ...)")
    print(f"  Computing [id] - k for k = 0, 1, 2, ..., 20:")
    print(f"  (Using ℕ subtraction: n - k = max(n - k, 0))")
    
    for k in range(0, 21, 5):
        # [id] - k: the sequence (max(0, 0-k), max(0, 1-k), ..., max(0, (N-1)-k))
        seq = [max(0, i - k) for i in range(N)]
        
        if k > 0:
            prev_seq = [max(0, i - (k-1)) for i in range(N)]
            strictly_less = sum(1 for i in range(N) if seq[i] < prev_seq[i])
            frac = strictly_less / N
            print(f"    [id]-{k:2d} < [id]-{k-1:2d}: {strictly_less}/{N} = {frac:.4f} "
                  f"{'→ U-LARGE (descent continues)' if frac > 0.5 else ''}")
        else:
            print(f"    [id]-{k:2d}: first 10 values = {seq[:10]}...")
    
    print(f"\n  In standard ℕ, any descending chain must terminate at 0.")
    print(f"  In *ℕ, starting from [id], we can descend indefinitely!")

# =============================================================================
# Demo 6: Ultrafilter Limits
# =============================================================================

def demo_ultrafilter_limits():
    """
    Demonstrate ultrafilter limits for bounded sequences.
    Using a density-based approximation of a free ultrafilter.
    """
    print("\n" + "=" * 60)
    print("Demo 6: Ultrafilter Limits (Stone-Čech Bridge)")
    print("=" * 60)
    
    N = 100000
    
    sequences = {
        "1/(n+1)": lambda n: Fraction(1, n + 1),
        "n/(n+1)": lambda n: Fraction(n, n + 1),
        "(-1)^n * 1/(n+1) + 1/2": lambda n: Fraction((-1)**n, n + 1) + Fraction(1, 2),
    }
    
    for name, seq_fn in sequences.items():
        # Compute approximate ultrafilter limit as the "density limit"
        # For a free ultrafilter concentrating on large indices, this is the
        # ordinary limit when it exists
        tail_avg = sum(float(seq_fn(n)) for n in range(N - 1000, N)) / 1000
        print(f"\n  Sequence f(n) = {name}:")
        print(f"    First 5 values: {[float(seq_fn(n)) for n in range(5)]}")
        print(f"    Tail average (last 1000): {tail_avg:.6f}")
        print(f"    → Ultrafilter limit ≈ {tail_avg:.6f}")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  NON-STANDARD ARITHMETIC: Numerical Demonstrations     ║")
    print("║  Exploring *ℕ = ℕ^ℕ/U — Numbers Beyond Infinity       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_free_ultrafilter()
    demo_infinite_elements()
    demo_overspill()
    demo_transfer()
    demo_descending_chain()
    demo_ultrafilter_limits()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("See ARTICLE.md for the full story and RESEARCH_PAPER.md for details.")


#!/usr/bin/env python3
"""
Visualization: Non-Standard Arithmetic Ultrapower Structure

Creates plots showing:
1. U-large sets and the free ultrafilter property
2. Infinite elements dominating all standard naturals
3. Descending chains from infinite elements
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def plot_ularge_sets():
    """Plot the density of various sets under a free ultrafilter approximation."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    N = 1000
    indices = np.arange(N)
    
    # Panel 1: Finite vs cofinite sets
    ax = axes[0]
    finite_sizes = list(range(0, N, 10))
    densities = [s / N for s in finite_sizes]
    ax.plot(finite_sizes, densities, 'b-', linewidth=2, label='Density of {0,...,k}')
    ax.axhline(y=0.5, color='r', linestyle='--', alpha=0.7, label='U-large threshold')
    ax.fill_between(finite_sizes, 0.5, 1, alpha=0.1, color='green', label='U-large region')
    ax.fill_between(finite_sizes, 0, 0.5, alpha=0.1, color='red', label='U-small region')
    ax.set_xlabel('Set size k')
    ax.set_ylabel('Density')
    ax.set_title('Finite Sets are U-small')
    ax.legend(fontsize=8)
    
    # Panel 2: Cofinite sets are U-large
    ax = axes[1]
    ax.plot(finite_sizes, [1 - d for d in densities], 'g-', linewidth=2, label='Density of {k+1,...,N}')
    ax.axhline(y=0.5, color='r', linestyle='--', alpha=0.7, label='U-large threshold')
    ax.fill_between(finite_sizes, 0.5, 1, alpha=0.1, color='green')
    ax.fill_between(finite_sizes, 0, 0.5, alpha=0.1, color='red')
    ax.set_xlabel('Complement starting point k')
    ax.set_ylabel('Density')
    ax.set_title('Cofinite Sets are U-large')
    ax.legend(fontsize=8)
    
    # Panel 3: The ultrafilter prime property
    ax = axes[2]
    even_density = [sum(1 for i in range(n+1) if i % 2 == 0) / (n+1) for n in range(N)]
    odd_density = [sum(1 for i in range(n+1) if i % 2 == 1) / (n+1) for n in range(N)]
    ax.plot(range(N), even_density, 'b-', alpha=0.7, linewidth=1, label='Even numbers')
    ax.plot(range(N), odd_density, 'r-', alpha=0.7, linewidth=1, label='Odd numbers')
    ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.7)
    ax.set_xlabel('Universe size')
    ax.set_ylabel('Density')
    ax.set_title('Ultrafilter Must Choose: Even OR Odd')
    ax.legend(fontsize=8)
    ax.set_ylim(0.4, 0.6)
    
    plt.tight_layout()
    plt.savefig('viz_ularge_sets.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_ularge_sets.png")


def plot_infinite_element():
    """Visualize the infinite element [id] dominating all standard naturals."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    N = 200
    indices = np.arange(N)
    
    # Panel 1: Identity vs constant sequences
    ax = axes[0]
    ax.plot(indices, indices, 'b-', linewidth=2, label='[id] = (0,1,2,...)')
    for c in [10, 50, 100, 150]:
        ax.axhline(y=c, color='red', linestyle='--', alpha=0.5, linewidth=1)
        ax.text(5, c + 3, f'std({c})', color='red', fontsize=8)
    
    ax.fill_between(indices, indices, 200, alpha=0.05, color='blue')
    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.set_title('Infinite Element [id] vs Standard Elements')
    ax.legend(fontsize=10)
    ax.set_ylim(0, 200)
    
    # Panel 2: Fraction of indices where [id] > n, for various n
    ax = axes[1]
    standard_values = list(range(0, N))
    fractions = [(N - n - 1) / N for n in standard_values]
    ax.plot(standard_values, fractions, 'b-', linewidth=2)
    ax.axhline(y=0.5, color='r', linestyle='--', alpha=0.7, label='U-large threshold')
    ax.fill_between(standard_values, 0.5, [max(f, 0.5) for f in fractions], alpha=0.2, color='green', label='U-large (id > n)')
    ax.set_xlabel('Standard bound n')
    ax.set_ylabel('Fraction of indices where id(i) > n')
    ax.set_title('Density of {i | id(i) > n}')
    ax.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig('viz_infinite_element.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_infinite_element.png")


def plot_descending_chain():
    """Visualize descending chains from infinite elements."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    N = 100
    indices = np.arange(N)
    
    # Panel 1: The chain [id], [id]-1, [id]-2, ...
    ax = axes[0]
    colors = plt.cm.viridis(np.linspace(0, 0.8, 11))
    for k in range(0, 11, 2):
        chain_k = np.maximum(indices - k, 0)
        ax.plot(indices, chain_k, color=colors[k], linewidth=1.5, label=f'[id]−{k}')
    ax.set_xlabel('Index i')
    ax.set_ylabel('Value')
    ax.set_title('Descending Chain from [id]')
    ax.legend(fontsize=8, loc='upper left')
    
    # Panel 2: For each step, density of strict descent
    ax = axes[1]
    steps = list(range(1, 51))
    descent_densities = []
    for k in steps:
        chain_prev = np.maximum(indices - (k - 1), 0)
        chain_curr = np.maximum(indices - k, 0)
        strictly_less = np.sum(chain_curr < chain_prev)
        descent_densities.append(strictly_less / N)
    
    ax.plot(steps, descent_densities, 'b-', linewidth=2)
    ax.axhline(y=0.5, color='r', linestyle='--', alpha=0.7, label='U-large threshold')
    ax.fill_between(steps, 0.5, descent_densities, alpha=0.2, color='green', label='U-large descent')
    ax.set_xlabel('Step k')
    ax.set_ylabel('Density of strict descent')
    ax.set_title('Descending Chain: Each Step is U-large')
    ax.legend(fontsize=10)
    ax.set_ylim(0, 1.05)
    
    plt.tight_layout()
    plt.savefig('viz_descending_chain.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_descending_chain.png")


if __name__ == "__main__":
    plot_ularge_sets()
    plot_infinite_element()
    plot_descending_chain()
    print("All visualizations generated.")
