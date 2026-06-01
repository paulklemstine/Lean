"""
Memory Algebra: Demonstration

Numerical examples illustrating the Lossy Memory Theorem,
kernel pair submonoid, tropical forgetting, and capacity bounds.
"""

from algorithms import (
    MemorySystem, TropicalMemoryValuation,
    make_modular_memory, verify_kernel_submonoid,
    collision_detection_algorithm
)


def demo_lossy_memory():
    """Demonstrate the Lossy Memory Theorem with concrete examples."""
    print("=" * 60)
    print("DEMO 1: The Lossy Memory Theorem")
    print("=" * 60)
    
    # Z/3Z memory with binary alphabet
    mem = make_modular_memory(k=2, n=3)
    print(f"\nMemory system: Z/{mem.num_states}Z with alphabet size {mem.alphabet_size}")
    print(f"Generator images: {mem.generator_images}")
    
    # Find collision
    w1, w2 = collision_detection_algorithm(mem)
    print(f"\nCollision found!")
    print(f"  Word 1: {w1} -> state {mem.encode(w1)}")
    print(f"  Word 2: {w2} -> state {mem.encode(w2)}")
    print(f"  These are distinct words with identical memory states.")
    
    # Show periodicity
    print(f"\nPeriodicity of powers of generator 0:")
    for i in range(mem.num_states + 2):
        word = [0] * i
        print(f"  0^{i} = {word} -> state {mem.encode(word)}")


def demo_kernel_submonoid():
    """Demonstrate the Information Loss Submonoid Theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: The Information Loss Submonoid")
    print("=" * 60)
    
    mem = make_modular_memory(k=2, n=2)
    print(f"\nMemory system: Z/2Z (parity) with binary alphabet")
    
    # Show some kernel pairs
    pairs = mem.kernel_pair_sample(max_length=3)
    print(f"\nKernel pairs (confused word pairs):")
    for w1, w2 in pairs[:8]:
        print(f"  ({w1}, {w2}) -> both map to state {mem.encode(w1)}")
    
    # Verify submonoid closure
    is_submonoid = verify_kernel_submonoid(mem, max_length=3)
    print(f"\nKernel pair is closed under concatenation: {is_submonoid}")
    
    # Show a specific composition
    if len(pairs) >= 2:
        (a, b), (c, d) = pairs[0], pairs[1]
        print(f"\nComposition example:")
        print(f"  ({a}, {b}) confused, ({c}, {d}) confused")
        print(f"  ({a}+{c}, {b}+{d}) = ({a+c}, {b+d})")
        print(f"  encode({a+c}) = {mem.encode(a+c)}")
        print(f"  encode({b+d}) = {mem.encode(b+d)}")
        print(f"  Also confused: {mem.encode(a+c) == mem.encode(b+d)}")


def demo_tropical_forgetting():
    """Demonstrate tropical memory valuation and forgettability."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Memory Valuation")
    print("=" * 60)
    
    # Cost: symbol 0 costs 1.0, symbol 1 costs 2.5
    val = TropicalMemoryValuation(costs=[1.0, 2.5], threshold=5.0)
    print(f"\nCosts: {val.costs}")
    print(f"Threshold: {val.threshold}")
    
    # Show some words and their costs
    test_words = [
        [], [0], [1], [0, 0, 0], [1, 1],
        [0, 0, 0, 0, 0], [1, 1, 1], [0, 1, 0, 1]
    ]
    
    print(f"\nWord costs and forgettability:")
    for w in test_words:
        cost = val.stream_cost(w)
        forgettable = val.is_forgettable(w)
        status = "FORGETTABLE" if forgettable else "memorable"
        print(f"  {str(w):20s} cost={cost:5.1f}  {status}")
    
    # Show monotonicity: forgettable stays forgettable
    print(f"\nMonotonicity demonstration:")
    w = [1, 1]  # cost = 5.0, forgettable
    print(f"  {w} is forgettable (cost={val.stream_cost(w)})")
    for ext in [[0], [1], [0, 0]]:
        extended = w + ext
        print(f"  {w}+{ext} = {extended}, cost={val.stream_cost(extended)}, "
              f"forgettable={val.is_forgettable(extended)}")
    
    # Enumerate memorable words
    memorable = val.memorable_words(alphabet_size=2, max_length=4)
    print(f"\nMemorable words (up to length 4): {len(memorable)} total")
    for w in memorable[:15]:
        print(f"  {w} (cost={val.stream_cost(w):.1f})")


def demo_capacity_bounds():
    """Demonstrate memory capacity bounds and discrimination counts."""
    print("\n" + "=" * 60)
    print("DEMO 4: Memory Capacity Bounds")
    print("=" * 60)
    
    for n in [2, 3, 4, 5]:
        mem = make_modular_memory(k=2, n=n)
        print(f"\nZ/{n}Z memory (k=2, n={n}):")
        for L in range(1, 6):
            disc = mem.discrimination_count(L)
            total = 2 ** L
            print(f"  Length {L}: {disc}/{total} words distinguishable "
                  f"(bound: {min(total, n)}, ratio: {disc/total:.3f})")


def demo_optimal_forgetting_conjecture():
    """Test the Optimal Forgetting Conjecture computationally."""
    print("\n" + "=" * 60)
    print("DEMO 5: Optimal Forgetting Conjecture Test")
    print("=" * 60)
    
    print("\nConjecture: max distinguishable length-L words = min(k^L, n)")
    print("\nTesting with modular arithmetic memory systems:")
    
    for k in [2, 3]:
        for n in [2, 3, 4]:
            mem = make_modular_memory(k, n)
            print(f"\n  k={k}, n={n} (Z/{n}Z):")
            for L in range(1, 5):
                disc = mem.discrimination_count(L)
                predicted = min(k ** L, n)
                match = "✓" if disc == predicted else "✗"
                print(f"    L={L}: disc={disc}, predicted={predicted} {match}")


if __name__ == "__main__":
    demo_lossy_memory()
    demo_kernel_submonoid()
    demo_tropical_forgetting()
    demo_capacity_bounds()
    demo_optimal_forgetting_conjecture()


"""
Visualization: Memory System Discrimination Decay

Shows how the fraction of distinguishable words decays
exponentially as word length increases, for various memory sizes.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as cart_product


def make_modular_memory_encode(k, n):
    """Encode function for Z/nZ memory with k generators."""
    def encode(word):
        state = 0
        for a in word:
            state = (state + (a % n)) % n
        return state
    return encode


def discrimination_count(encode, k, length):
    """Count distinct encodings of words of given length."""
    states = set()
    for word in cart_product(range(k), repeat=length):
        states.add(encode(list(word)))
    return len(states)


def plot_discrimination_decay():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    k = 2
    max_L = 8
    
    # Left: absolute discrimination count
    ax = axes[0]
    for n in [2, 3, 4, 5, 8]:
        encode = make_modular_memory_encode(k, n)
        Ls = list(range(1, max_L + 1))
        counts = [discrimination_count(encode, k, L) for L in Ls]
        ax.plot(Ls, counts, 'o-', label=f'|M|={n}', linewidth=2, markersize=6)
    
    # Plot k^L for reference
    Ls = list(range(1, max_L + 1))
    ax.plot(Ls, [k**L for L in Ls], 'k--', label=f'k^L (total)', linewidth=1.5, alpha=0.5)
    
    ax.set_xlabel('Word Length L', fontsize=12)
    ax.set_ylabel('Distinguishable Words', fontsize=12)
    ax.set_title('Memory Discrimination vs Word Length', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    # Right: discrimination ratio
    ax = axes[1]
    for n in [2, 3, 4, 5, 8]:
        encode = make_modular_memory_encode(k, n)
        Ls = list(range(1, max_L + 1))
        ratios = [discrimination_count(encode, k, L) / k**L for L in Ls]
        ax.plot(Ls, ratios, 'o-', label=f'|M|={n}', linewidth=2, markersize=6)
    
    ax.set_xlabel('Word Length L', fontsize=12)
    ax.set_ylabel('Fraction Distinguishable', fontsize=12)
    ax.set_title('Discrimination Ratio (approaches 0)', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    
    plt.tight_layout()
    plt.savefig('memory_discrimination_decay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: memory_discrimination_decay.png")


def plot_tropical_forgetting():
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    costs = [1.0, 2.5]
    threshold = 5.0
    k = 2
    max_L = 6
    
    # Count memorable words at each length
    Ls = list(range(0, max_L + 1))
    memorable_counts = []
    total_counts = []
    
    for L in Ls:
        memorable = 0
        total = k ** L if L > 0 else 1
        for word in cart_product(range(k), repeat=L):
            cost = sum(costs[a] for a in word)
            if cost < threshold:
                memorable += 1
        memorable_counts.append(memorable)
        total_counts.append(total)
    
    ax.bar([l - 0.2 for l in Ls], total_counts, width=0.4, label='Total words',
           color='lightcoral', alpha=0.7)
    ax.bar([l + 0.2 for l in Ls], memorable_counts, width=0.4, label='Memorable words',
           color='steelblue', alpha=0.7)
    
    ax.set_xlabel('Word Length L', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Tropical Forgetting (costs={costs}, threshold={threshold})', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xticks(Ls)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('tropical_forgetting.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_forgetting.png")


def plot_kernel_growth():
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    
    k = 2
    max_L = 7
    
    for n in [2, 3, 4]:
        encode = make_modular_memory_encode(k, n)
        Ls = list(range(1, max_L + 1))
        kernel_sizes = []
        
        for L in Ls:
            # Count pairs in kernel at length L
            words = list(cart_product(range(k), repeat=L))
            groups = {}
            for w in words:
                s = encode(list(w))
                if s not in groups:
                    groups[s] = 0
                groups[s] += 1
            # Kernel size = sum of C(g, 2) for each group
            kernel_size = sum(c * (c - 1) // 2 for c in groups.values())
            kernel_sizes.append(kernel_size)
        
        ax.plot(Ls, kernel_sizes, 'o-', label=f'|M|={n}', linewidth=2, markersize=6)
    
    ax.set_xlabel('Word Length L', fontsize=12)
    ax.set_ylabel('Kernel Pair Size (collision count)', fontsize=12)
    ax.set_title('Information Loss Growth: Kernel Pair Size vs Length', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('kernel_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: kernel_growth.png")


if __name__ == "__main__":
    plot_discrimination_decay()
    plot_tropical_forgetting()
    plot_kernel_growth()
