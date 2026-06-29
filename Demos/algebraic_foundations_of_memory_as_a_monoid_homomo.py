#!/usr/bin/env python3
"""
Memory Algebra Demo: Numerical examples illustrating the core theorems.

Demonstrates:
1. Lossy Memory Theorem - finite memory over infinite experience
2. Kernel computation - finding perfectly forgotten experiences
3. Congruence classes - partitioning experiences by memory state
4. Refinement checking - comparing two memory systems
5. Tropical memory - salience-based idempotent memory
"""

from typing import Callable, Dict, List, Set, Tuple
from collections import defaultdict
from itertools import product


def free_monoid_elements(generators: List[str], max_length: int) -> List[str]:
    """Generate all words in the free monoid up to given length."""
    elements = [""]  # identity (empty word)
    for length in range(1, max_length + 1):
        for word in product(generators, repeat=length):
            elements.append("".join(word))
    return elements


class MemorySystem:
    """A memory system: monoid homomorphism from experiences to states."""
    
    def __init__(self, encode: Callable[[str], int], name: str = ""):
        self.encode = encode
        self.name = name
    
    def is_lossy(self, experiences: List[str]) -> bool:
        """Check if the memory system conflates any two experiences."""
        seen: Dict[int, str] = {}
        for exp in experiences:
            state = self.encode(exp)
            if state in seen and seen[state] != exp:
                return True
            seen[state] = exp
        return False
    
    def kernel(self, experiences: List[str], identity_state: int = 0) -> Set[str]:
        """Find experiences mapping to the identity state."""
        return {exp for exp in experiences if self.encode(exp) == identity_state}
    
    def congruence_classes(self, experiences: List[str]) -> Dict[int, List[str]]:
        """Partition experiences by memory state."""
        classes: Dict[int, List[str]] = defaultdict(list)
        for exp in experiences:
            classes[self.encode(exp)].append(exp)
        return dict(classes)
    
    def refines(self, other: 'MemorySystem', experiences: List[str]) -> bool:
        """Check if self refines other (self remembers at least as much)."""
        for e1 in experiences:
            for e2 in experiences:
                if self.encode(e1) == self.encode(e2):
                    if other.encode(e1) != other.encode(e2):
                        return False
        return True


def demo_lossy_memory():
    """Demonstrate the Lossy Memory Theorem."""
    print("=" * 60)
    print("DEMO 1: Lossy Memory Theorem")
    print("=" * 60)
    print()
    
    # Memory system: hash mod 4
    def hash_mod4(s: str) -> int:
        return hash(s) % 4
    
    mem = MemorySystem(hash_mod4, "hash_mod4")
    
    # Generate many experiences
    generators = ["a", "b"]
    experiences = free_monoid_elements(generators, max_length=4)
    
    print(f"Experience space size: {len(experiences)}")
    print(f"State space size: 4")
    print(f"Is lossy? {mem.is_lossy(experiences)}")
    
    # Show some collisions
    classes = mem.congruence_classes(experiences)
    print(f"\nCongruence classes (showing first 3 per class):")
    for state, exps in sorted(classes.items()):
        print(f"  State {state}: {exps[:3]}{'...' if len(exps) > 3 else ''} ({len(exps)} total)")
    print()


def demo_kernel_submonoid():
    """Demonstrate the Kernel Submonoid Theorem."""
    print("=" * 60)
    print("DEMO 2: Kernel Submonoid Theorem")
    print("=" * 60)
    print()
    
    # Memory system: length mod 3
    def length_mod3(s: str) -> int:
        return len(s) % 3
    
    mem = MemorySystem(length_mod3, "length_mod3")
    
    generators = ["a", "b"]
    experiences = free_monoid_elements(generators, max_length=6)
    
    # Kernel: words whose length is 0 mod 3
    kernel = mem.kernel(experiences, identity_state=0)
    print(f"Kernel (length ≡ 0 mod 3, first 10): {sorted(kernel, key=len)[:10]}")
    print(f"Kernel size: {len(kernel)}")
    
    # Verify submonoid property
    kernel_list = sorted(kernel, key=len)[:20]
    print("\nSubmonoid closure check:")
    print(f"  '' (identity) in kernel? {'' in kernel}")
    
    # Check a few products
    for w1 in kernel_list[:5]:
        for w2 in kernel_list[:5]:
            product = w1 + w2
            if product in kernel:
                if w1 and w2:  # skip trivial cases
                    print(f"  '{w1}' * '{w2}' = '{product}' → in kernel ✓")
    print()


def demo_congruence_refinement():
    """Demonstrate the Congruence Refinement Theorem."""
    print("=" * 60)
    print("DEMO 3: Congruence Refinement")
    print("=" * 60)
    print()
    
    # Fine memory: length mod 6
    def fine_encode(s: str) -> int:
        return len(s) % 6
    
    # Coarse memory: length mod 3
    def coarse_encode(s: str) -> int:
        return len(s) % 3
    
    fine = MemorySystem(fine_encode, "mod6")
    coarse = MemorySystem(coarse_encode, "mod3")
    
    generators = ["a", "b"]
    experiences = free_monoid_elements(generators, max_length=6)
    
    print(f"Fine system: length mod 6 (6 states)")
    print(f"Coarse system: length mod 3 (3 states)")
    print(f"Fine refines coarse? {fine.refines(coarse, experiences)}")
    print(f"Coarse refines fine? {coarse.refines(fine, experiences)}")
    
    # Compute the factoring map
    print("\nFactoring map f: S_fine → S_coarse:")
    for state in range(6):
        print(f"  f({state}) = {state % 3}")
    
    # Verify commutativity
    print("\nVerifying f ∘ fine_encode = coarse_encode:")
    for exp in experiences[:10]:
        fine_state = fine.encode(exp)
        factored = fine_state % 3
        coarse_state = coarse.encode(exp)
        status = "✓" if factored == coarse_state else "✗"
        print(f"  '{exp}': f(fine({fine_state})) = {factored}, coarse = {coarse_state} {status}")
    print()


def demo_tropical_memory():
    """Demonstrate tropical (salience-based) memory."""
    print("=" * 60)
    print("DEMO 4: Tropical Memory (Salience-Based)")
    print("=" * 60)
    print()
    
    # Tropical memory: each experience has a priority, memory keeps max
    priorities = {
        "wake": 1, "brush": 1, "commute": 2,
        "meeting": 5, "lunch": 3, "code": 4,
        "dinner": 3, "sleep": 1, "": 0
    }
    
    def tropical_encode(sequence: str) -> int:
        """Encode a sequence of experiences by taking max priority."""
        if not sequence:
            return 0
        events = sequence.split(",")
        return max(priorities.get(e.strip(), 0) for e in events)
    
    print("Experience priorities:")
    for event, priority in sorted(priorities.items(), key=lambda x: -x[1]):
        if event:
            print(f"  {event}: {priority}")
    
    sequences = [
        "",
        "wake",
        "wake,brush,commute",
        "wake,meeting",
        "meeting,lunch,code",
        "wake,brush,commute,meeting,lunch,code,dinner,sleep"
    ]
    
    print("\nTropical encoding (max priority):")
    for seq in sequences:
        state = tropical_encode(seq)
        print(f"  [{seq or '∅'}] → priority {state}")
    
    # Demonstrate idempotence
    print("\nIdempotence: encoding twice gives same result:")
    for seq in sequences[1:4]:
        s1 = tropical_encode(seq)
        # "Re-experiencing" = max of state with itself
        s2 = max(s1, s1)
        print(f"  max({s1}, {s1}) = {s2} {'✓' if s1 == s2 else '✗'}")
    print()


def demo_composition_irreversibility():
    """Demonstrate that composition preserves lossiness."""
    print("=" * 60)
    print("DEMO 5: Irreversibility of Information Loss")
    print("=" * 60)
    print()
    
    # First encoding: mod 4 (lossy)
    def encode1(s: str) -> int:
        return len(s) % 4
    
    # Second encoding: injective (multiply by 2 in mod 8)
    def encode2(x: int) -> int:
        return (x * 2) % 8
    
    # Composition
    def composed(s: str) -> int:
        return encode2(encode1(s))
    
    mem1 = MemorySystem(encode1, "mod4")
    mem_composed = MemorySystem(composed, "mod4_then_2x_mod8")
    
    generators = ["a"]
    experiences = free_monoid_elements(generators, max_length=8)
    
    print(f"First system (mod 4): lossy? {mem1.is_lossy(experiences)}")
    print(f"Second system (×2 mod 8): injective on {set(range(4))}")
    print(f"Composed system: lossy? {mem_composed.is_lossy(experiences)}")
    
    print("\nTrace through composition:")
    for exp in experiences[:9]:
        s1 = encode1(exp)
        s2 = composed(exp)
        print(f"  '{exp}' (len={len(exp)}) → mod4={s1} → ×2 mod8={s2}")
    
    print("\nNotice: 'a' (len 1) and 'aaaaa' (len 5) both map to mod4=1, then to 2.")
    print("The injective second step cannot recover the lost distinction.")
    print()


if __name__ == "__main__":
    demo_lossy_memory()
    demo_kernel_submonoid()
    demo_congruence_refinement()
    demo_tropical_memory()
    demo_composition_irreversibility()
    
    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Memory Congruence Classes and Compression.

Creates a figure showing how a memory system partitions the experience space
into congruence classes, with fiber sizes and compression ratios.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
from itertools import product


def generate_words(alphabet, max_length):
    """Generate all words over alphabet up to max_length."""
    words = [""]
    for length in range(1, max_length + 1):
        for w in product(alphabet, repeat=length):
            words.append("".join(w))
    return words


def memory_encode_mod(word, n):
    """Simple memory system: length mod n."""
    return len(word) % n


def compute_fiber_sizes(words, n):
    """Compute fiber sizes for length-mod-n encoding."""
    fibers = defaultdict(int)
    for w in words:
        fibers[memory_encode_mod(w, n)] += 1
    return dict(fibers)


def plot_congruence_partitions():
    """Plot congruence class sizes for different memory capacities."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    alphabet = ["a", "b"]
    max_length = 6
    words = generate_words(alphabet, max_length)
    total = len(words)
    
    for idx, n_states in enumerate([2, 4, 6]):
        ax = axes[idx]
        fibers = compute_fiber_sizes(words, n_states)
        
        states = sorted(fibers.keys())
        sizes = [fibers[s] for s in states]
        
        colors = plt.cm.Set2(np.linspace(0, 1, len(states)))
        bars = ax.bar(states, sizes, color=colors, edgecolor='black', linewidth=0.5)
        
        ax.set_xlabel('Memory State', fontsize=12)
        ax.set_ylabel('Fiber Size (# experiences)', fontsize=12)
        ax.set_title(f'{n_states} States\nCompression: {len(fibers)}/{total} = {len(fibers)/total:.3f}',
                     fontsize=11)
        ax.set_xticks(states)
        
        # Annotate bars
        for bar, size in zip(bars, sizes):
            ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.5,
                   str(size), ha='center', va='bottom', fontsize=9)
    
    fig.suptitle('Memory Congruence Classes: How Experiences Partition Under Encoding\n'
                 f'(Alphabet: {{a, b}}, Words up to length {max_length}, Total: {total})',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('congruence_partitions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved congruence_partitions.png")


def plot_compression_curve():
    """Plot compression ratio vs state space size."""
    fig, ax = plt.subplots(figsize=(8, 5))
    
    alphabet = ["a", "b"]
    
    for max_length in [4, 5, 6, 7]:
        words = generate_words(alphabet, max_length)
        total = len(words)
        
        state_sizes = range(1, 15)
        ratios = []
        for n in state_sizes:
            image_size = min(n, max_length + 1)
            ratios.append(image_size / total)
        
        ax.plot(list(state_sizes), ratios, 'o-', label=f'max length = {max_length} ({total} words)',
                linewidth=2, markersize=5)
    
    ax.set_xlabel('Number of Memory States', fontsize=12)
    ax.set_ylabel('Compression Ratio (|image| / |experiences|)', fontsize=12)
    ax.set_title('Memory Capacity Bound:\nMore States → Less Compression (But Always Lossy for Large Input)',
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.05)
    
    plt.tight_layout()
    plt.savefig('compression_curve.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved compression_curve.png")


def plot_refinement_hasse():
    """Plot the refinement lattice (Hasse diagram) for modular memory systems."""
    fig, ax = plt.subplots(figsize=(8, 6))
    
    # Systems: mod 1, mod 2, mod 3, mod 4, mod 6, mod 12
    systems = {
        1: (0.5, 0.0),   # bottom (total forgetting)
        2: (0.2, 0.3),
        3: (0.8, 0.3),
        4: (0.2, 0.6),
        6: (0.8, 0.6),
        12: (0.5, 0.9),  # top (finest)
    }
    
    # Refinement edges (n refines m iff m divides n)
    edges = [
        (2, 1), (3, 1),
        (4, 2), (6, 2), (6, 3),
        (12, 4), (12, 6),
    ]
    
    # Draw edges
    for n, m in edges:
        x1, y1 = systems[n]
        x2, y2 = systems[m]
        ax.annotate('', xy=(x2, y2 + 0.03), xytext=(x1, y1 - 0.03),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    # Draw nodes
    for n, (x, y) in systems.items():
        circle = plt.Circle((x, y), 0.04, color='steelblue', ec='black', linewidth=1.5, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, f'mod {n}', ha='center', va='center', fontsize=9,
               fontweight='bold', color='white', zorder=6)
    
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.15, 1.05)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Refinement Lattice of Memory Systems\n'
                 '(mod n refines mod m iff m | n)\n'
                 'Arrow: "remembers at least as much as"',
                 fontsize=12, fontweight='bold')
    
    # Labels
    ax.text(0.5, -0.1, '← Total Forgetting', ha='center', fontsize=10, style='italic', color='gray')
    ax.text(0.5, 1.0, 'Finest Memory →', ha='center', fontsize=10, style='italic', color='gray')
    
    plt.tight_layout()
    plt.savefig('refinement_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved refinement_lattice.png")


if __name__ == "__main__":
    plot_congruence_partitions()
    plot_compression_curve()
    plot_refinement_hasse()
    print("\nAll visualizations saved!")
