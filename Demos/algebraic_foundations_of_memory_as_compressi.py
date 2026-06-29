#!/usr/bin/env python3
"""
Demo: Tropical Memory Compression Algebra

Demonstrates the key results of the memory algebra theory:
1. Memory systems as monoid homomorphisms
2. Cascade products and capacity bounds
3. Memory spectrum computation
4. Idempotent stabilization
"""
from typing import Callable

# =============================================================================
# Core: Memory System as Monoid Homomorphism
# =============================================================================

class MemorySystem:
    """A memory system over a finite alphabet with finite state monoid.

    The monoid is represented as (states, op, identity) where:
    - states: set of state labels
    - op: binary operation (state, state) -> state
    - identity: identity element
    - generator_images: dict mapping each alphabet symbol to its image in the monoid
    """

    def __init__(self, states: set, op: Callable, identity, generator_images: dict):
        self.states = states
        self.op = op
        self.identity = identity
        self.generator_images = generator_images
        self.alphabet = set(generator_images.keys())

    def encode(self, word: list):
        """Encode a word (list of symbols) to a state via the homomorphism."""
        result = self.identity
        for symbol in word:
            result = self.op(result, self.generator_images[symbol])
        return result

    def memory_image(self, max_depth: int = 10) -> set:
        """Compute the reachable states up to a given depth."""
        reachable = {self.identity}
        frontier = {self.identity}
        for _ in range(max_depth):
            new_frontier = set()
            for s in frontier:
                for a in self.alphabet:
                    t = self.op(s, self.generator_images[a])
                    if t not in reachable:
                        reachable.add(t)
                        new_frontier.add(t)
            frontier = new_frontier
            if not frontier:
                break
        return reachable

    def spectrum(self, max_depth: int) -> list:
        """Compute the memory spectrum: |reachable states at depth ≤ k| for k=0,...,max_depth."""
        reachable = {self.identity}
        frontier = {self.identity}
        spec = [1]  # spectrum(0) = 1
        for _ in range(max_depth):
            new_frontier = set()
            for s in frontier:
                for a in self.alphabet:
                    t = self.op(s, self.generator_images[a])
                    if t not in reachable:
                        reachable.add(t)
                        new_frontier.add(t)
            frontier = new_frontier
            spec.append(len(reachable))
        return spec

    def find_idempotent_power(self, symbol) -> int:
        """Find smallest n > 0 such that encode(symbol^(2n)) = encode(symbol^n)."""
        s = self.generator_images[symbol]
        powers = [self.identity]
        current = self.identity
        for n in range(1, len(self.states) * 2 + 2):
            current = self.op(current, s)
            powers.append(current)
            # Check if s^(2n) = s^n
            s_2n = current
            for _ in range(n):
                s_2n = self.op(s_2n, s)
            if s_2n == powers[n]:
                return n
        raise RuntimeError("No idempotent power found (shouldn't happen for finite monoid)")


def cascade_product(mem1: MemorySystem, mem2: MemorySystem) -> MemorySystem:
    """Compute the cascade (parallel) product of two memory systems."""
    assert mem1.alphabet == mem2.alphabet
    states = {(s, t) for s in mem1.states for t in mem2.states}
    op = lambda a, b: (mem1.op(a[0], b[0]), mem2.op(a[1], b[1]))
    identity = (mem1.identity, mem2.identity)
    gen_images = {a: (mem1.generator_images[a], mem2.generator_images[a])
                  for a in mem1.alphabet}
    return MemorySystem(states, op, identity, gen_images)


# =============================================================================
# Example Memory Systems
# =============================================================================

def make_cyclic_memory(n: int, alphabet: dict) -> MemorySystem:
    """Memory system with state space Z/nZ."""
    states = set(range(n))
    op = lambda a, b: (a + b) % n
    return MemorySystem(states, op, 0, alphabet)


def make_boolean_memory(f: Callable) -> MemorySystem:
    """Memory system with state space {0, 1} and boolean operation f."""
    states = {0, 1}
    return MemorySystem(states, f, 0, {'a': 1, 'b': 0})


# =============================================================================
# Demonstrations
# =============================================================================

def demo_compression_theorem():
    """Demonstrate that finite memory systems are necessarily lossy."""
    print("=" * 60)
    print("DEMO 1: Memory Compression Theorem")
    print("=" * 60)
    print()
    print("A memory system φ: FreeMonoid({a,b}) → Z/4Z")
    print("with φ(a) = 1, φ(b) = 2.")
    print()

    mem = make_cyclic_memory(4, {'a': 1, 'b': 2})

    # Show collisions
    words_by_state = {}
    for length in range(4):
        from itertools import product as cartprod
        for w in cartprod('ab', repeat=length):
            w_list = list(w)
            state = mem.encode(w_list)
            words_by_state.setdefault(state, []).append(''.join(w) if w else 'ε')

    print("State | Words mapping to it")
    print("-" * 40)
    for state in sorted(words_by_state.keys()):
        words = words_by_state[state][:5]
        suffix = "..." if len(words_by_state[state]) > 5 else ""
        print(f"  {state}   | {', '.join(words)}{suffix}")

    print()
    print(f"Total states: {len(mem.states)}")
    print(f"Total words (length ≤ 3): {sum(len(v) for v in words_by_state.values())}")
    print(f"→ Lossy: {sum(len(v) for v in words_by_state.values())} words → {len(words_by_state)} states")
    print()


def demo_cascade_product():
    """Demonstrate cascade product and capacity bounds."""
    print("=" * 60)
    print("DEMO 2: Cascade Product & Tropical Capacity")
    print("=" * 60)
    print()

    mem1 = make_cyclic_memory(3, {'a': 1, 'b': 2})
    mem2 = make_cyclic_memory(4, {'a': 1, 'b': 3})
    cascade = cascade_product(mem1, mem2)

    img1 = mem1.memory_image()
    img2 = mem2.memory_image()
    img_cascade = cascade.memory_image()

    print(f"Memory system 1 (Z/3Z): |image| = {len(img1)}")
    print(f"Memory system 2 (Z/4Z): |image| = {len(img2)}")
    print(f"Cascade product:         |image| = {len(img_cascade)}")
    print()
    print(f"Lower bound: max(|img1|, |img2|) = {max(len(img1), len(img2))}")
    print(f"Upper bound: |img1| × |img2|     = {len(img1) * len(img2)}")
    print(f"Actual:                            = {len(img_cascade)}")
    print()
    print(f"Tropical subadditivity check:")
    import math
    v1 = math.log2(len(img1)) if len(img1) > 0 else 0
    v2 = math.log2(len(img2)) if len(img2) > 0 else 0
    vc = math.log2(len(img_cascade)) if len(img_cascade) > 0 else 0
    print(f"  log|R₁| = {v1:.2f}")
    print(f"  log|R₂| = {v2:.2f}")
    print(f"  log|R₁₂| = {vc:.2f}")
    print(f"  log|R₁| + log|R₂| = {v1+v2:.2f}")
    print(f"  Subadditivity holds: {vc <= v1 + v2 + 1e-10}")
    print()


def demo_memory_spectrum():
    """Demonstrate the memory spectrum."""
    print("=" * 60)
    print("DEMO 3: Memory Spectrum")
    print("=" * 60)
    print()

    systems = [
        ("Z/4Z (a→1, b→2)", make_cyclic_memory(4, {'a': 1, 'b': 2})),
        ("Z/6Z (a→1, b→2)", make_cyclic_memory(6, {'a': 1, 'b': 2})),
        ("Z/5Z (a→1, b→3)", make_cyclic_memory(5, {'a': 1, 'b': 3})),
    ]

    for name, mem in systems:
        spec = mem.spectrum(8)
        print(f"{name}:")
        print(f"  Spectrum: {spec}")
        # Find stabilization depth
        stab = 0
        for i in range(1, len(spec)):
            if spec[i] > spec[i-1]:
                stab = i
        print(f"  Stabilization depth: {stab}")
        print(f"  Final value: {spec[-1]} (= |image|)")
        print()


def demo_idempotent_stabilization():
    """Demonstrate idempotent stabilization."""
    print("=" * 60)
    print("DEMO 4: Idempotent Stabilization")
    print("=" * 60)
    print()

    systems = [
        ("Z/4Z", make_cyclic_memory(4, {'a': 1, 'b': 2})),
        ("Z/6Z", make_cyclic_memory(6, {'a': 1, 'b': 3})),
        ("Z/5Z", make_cyclic_memory(5, {'a': 1, 'b': 2})),
    ]

    for name, mem in systems:
        for symbol in sorted(mem.alphabet):
            n = mem.find_idempotent_power(symbol)
            s_n = mem.encode([symbol] * n)
            s_2n = mem.encode([symbol] * (2 * n))
            print(f"{name}, symbol '{symbol}': n={n}, φ({symbol}^{n})={s_n}, "
                  f"φ({symbol}^{2*n})={s_2n}, equal={s_n == s_2n}")
    print()


def demo_congruence_classes():
    """Demonstrate the congruence structure of information loss."""
    print("=" * 60)
    print("DEMO 5: Congruence Classes (Information Loss Structure)")
    print("=" * 60)
    print()

    mem = make_cyclic_memory(3, {'a': 1, 'b': 2})
    print("Memory system: Z/3Z with φ(a)=1, φ(b)=2")
    print()

    from itertools import product as cartprod
    classes = {}
    for length in range(5):
        for w in cartprod('ab', repeat=length):
            word = ''.join(w) if w else 'ε'
            state = mem.encode(list(w))
            classes.setdefault(state, []).append(word)

    print("Congruence classes (state → representative words):")
    for state in sorted(classes.keys()):
        words = classes[state][:8]
        suffix = f" ... ({len(classes[state])} total)" if len(classes[state]) > 8 else ""
        print(f"  [{state}]: {', '.join(words)}{suffix}")
    print()
    print("Key property: if x ≡ y (mod congruence), then xz ≡ yz for all z.")
    print("This is verified by the algebraic structure of Con.ker.")
    print()


if __name__ == "__main__":
    demo_compression_theorem()
    demo_cascade_product()
    demo_memory_spectrum()
    demo_idempotent_stabilization()
    demo_congruence_classes()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Memory Spectrum and Tropical Capacity

Produces plots showing:
1. Memory spectrum growth curves for different memory systems
2. Tropical capacity comparison under cascade products
3. Congruence class size distribution
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import product as cartprod
import math


def cyclic_monoid_op(n):
    return lambda a, b: (a + b) % n


def compute_spectrum(n, gen_images, max_depth=12):
    """Compute memory spectrum for Z/nZ with given generator images."""
    op = cyclic_monoid_op(n)
    reachable = {0}
    frontier = {0}
    spec = [1]
    for _ in range(max_depth):
        new_frontier = set()
        for s in frontier:
            for g in gen_images.values():
                t = op(s, g)
                if t not in reachable:
                    reachable.add(t)
                    new_frontier.add(t)
        frontier = new_frontier
        spec.append(len(reachable))
    return spec


def compute_cascade_spectrum(n1, n2, gens1, gens2, max_depth=12):
    """Compute spectrum for cascade product of two cyclic memory systems."""
    op1 = cyclic_monoid_op(n1)
    op2 = cyclic_monoid_op(n2)
    reachable = {(0, 0)}
    frontier = {(0, 0)}
    spec = [1]
    alphabet = set(gens1.keys())
    for _ in range(max_depth):
        new_frontier = set()
        for (s1, s2) in frontier:
            for a in alphabet:
                t = (op1(s1, gens1[a]), op2(s2, gens2[a]))
                if t not in reachable:
                    reachable.add(t)
                    new_frontier.add(t)
        frontier = new_frontier
        spec.append(len(reachable))
    return spec


def encode_word(word, gen_images, n):
    op = cyclic_monoid_op(n)
    result = 0
    for c in word:
        result = op(result, gen_images[c])
    return result


def plot_memory_spectra():
    """Plot spectrum curves for different memory systems."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Different moduli
    ax = axes[0]
    systems = [
        (4, {'a': 1, 'b': 2}, 'Z/4Z'),
        (6, {'a': 1, 'b': 2}, 'Z/6Z'),
        (8, {'a': 1, 'b': 3}, 'Z/8Z'),
        (12, {'a': 1, 'b': 5}, 'Z/12Z'),
    ]
    for n, gens, label in systems:
        spec = compute_spectrum(n, gens, 15)
        ax.plot(range(len(spec)), spec, 'o-', label=label, markersize=4)
    ax.set_xlabel('Depth k')
    ax.set_ylabel('|spectrum(k)|')
    ax.set_title('Memory Spectrum: Cyclic Groups')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Cascade product vs components
    ax = axes[1]
    n1, gens1 = 3, {'a': 1, 'b': 2}
    n2, gens2 = 5, {'a': 1, 'b': 3}
    spec1 = compute_spectrum(n1, gens1, 10)
    spec2 = compute_spectrum(n2, gens2, 10)
    spec_cascade = compute_cascade_spectrum(n1, n2, gens1, gens2, 10)
    spec_product = [s1 * s2 for s1, s2 in zip(spec1, spec2)]

    ax.plot(range(len(spec1)), spec1, 's-', label='Z/3Z', markersize=4)
    ax.plot(range(len(spec2)), spec2, 'D-', label='Z/5Z', markersize=4)
    ax.plot(range(len(spec_cascade)), spec_cascade, 'o-', label='Cascade', markersize=5)
    ax.plot(range(len(spec_product)), spec_product, '^--', label='Product bound',
            markersize=4, alpha=0.6)
    ax.set_xlabel('Depth k')
    ax.set_ylabel('|spectrum(k)|')
    ax.set_title('Cascade Capacity Bounds')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Tropical capacity (log scale)
    ax = axes[2]
    moduli = range(2, 25)
    capacities = []
    for n in moduli:
        spec = compute_spectrum(n, {'a': 1, 'b': 1}, 20)
        cap = math.log2(max(spec)) if max(spec) > 0 else 0
        capacities.append(cap)

    capacities_coprime = []
    for n in moduli:
        # Choose b coprime to n for full coverage
        from math import gcd
        b = next((b for b in range(2, n+1) if gcd(b, n) == 1), 1)
        spec = compute_spectrum(n, {'a': 1, 'b': b}, 20)
        cap = math.log2(max(spec)) if max(spec) > 0 else 0
        capacities_coprime.append(cap)

    ax.plot(list(moduli), capacities, 'o-', label='φ(b)=1', markersize=4)
    ax.plot(list(moduli), capacities_coprime, 's-', label='φ(b) coprime', markersize=4)
    ax.plot(list(moduli), [math.log2(n) for n in moduli], '--', color='gray',
            label='log₂(n)', alpha=0.6)
    ax.set_xlabel('State space size n')
    ax.set_ylabel('Tropical capacity (bits)')
    ax.set_title('Tropical Capacity vs State Space')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('memory_spectrum_plots.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: memory_spectrum_plots.png")


def plot_congruence_distribution():
    """Plot the distribution of congruence class sizes."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: Class sizes for different systems
    ax = axes[0]
    max_len = 6
    systems = [
        (4, {'a': 1, 'b': 2}, 'Z/4Z'),
        (3, {'a': 1, 'b': 2}, 'Z/3Z'),
        (6, {'a': 1, 'b': 5}, 'Z/6Z'),
    ]

    bar_width = 0.25
    for idx, (n, gens, label) in enumerate(systems):
        classes = {}
        for length in range(max_len + 1):
            for w in cartprod('ab', repeat=length):
                state = encode_word(w, gens, n)
                classes[state] = classes.get(state, 0) + 1
        sizes = sorted(classes.values(), reverse=True)
        x = np.arange(len(sizes))
        ax.bar(x + idx * bar_width, sizes, bar_width, label=label, alpha=0.8)

    ax.set_xlabel('Congruence class index')
    ax.set_ylabel('Class size (words of length ≤ {})'.format(max_len))
    ax.set_title('Congruence Class Size Distribution')
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 2: Forgetting ratio over depth
    ax = axes[1]
    systems2 = [
        (4, {'a': 1, 'b': 2}, 'Z/4Z'),
        (6, {'a': 1, 'b': 2}, 'Z/6Z'),
        (8, {'a': 1, 'b': 3}, 'Z/8Z'),
    ]

    for n, gens, label in systems2:
        spec = compute_spectrum(n, gens, 12)
        # Total words at each depth: sum_{i=0}^{k} 2^i = 2^{k+1} - 1
        total_words = [sum(2**i for i in range(k+1)) for k in range(len(spec))]
        # Compression ratio: total_words / spectrum
        ratios = [tw / sp if sp > 0 else 0 for tw, sp in zip(total_words, spec)]
        ax.plot(range(len(ratios)), ratios, 'o-', label=label, markersize=4)

    ax.set_xlabel('Depth k')
    ax.set_ylabel('Compression ratio (words/states)')
    ax.set_title('Information Loss Growth')
    ax.set_yscale('log')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('congruence_distribution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: congruence_distribution.png")


if __name__ == "__main__":
    plot_memory_spectra()
    plot_congruence_distribution()
    print("All visualizations generated.")
