#!/usr/bin/env python3
"""
Algorithms for Tropical Memory Compression Algebra

Type-hinted implementations of the key algorithms from the research:
1. Memory spectrum computation
2. Cascade product construction
3. Idempotent power detection
4. Tropical capacity valuation
5. Congruence class enumeration
"""
from typing import TypeVar, Generic, Callable, Dict, Set, List, Tuple, Optional
from dataclasses import dataclass
import math

S = TypeVar('S')  # State type
A = TypeVar('A')  # Alphabet type


@dataclass
class FiniteMonoid(Generic[S]):
    """A finite monoid: set of elements with associative binary operation and identity."""
    elements: Set[S]
    op: Callable[[S, S], S]
    identity: S

    def power(self, s: S, n: int) -> S:
        """Compute s^n in the monoid."""
        result = self.identity
        for _ in range(n):
            result = self.op(result, s)
        return result


@dataclass
class MemorySystemSpec(Generic[A, S]):
    """Specification of a memory system: alphabet, monoid, and generator images."""
    alphabet: Set[A]
    monoid: FiniteMonoid[S]
    generator_images: Dict[A, S]

    def encode(self, word: List[A]) -> S:
        """Encode a word via the monoid homomorphism."""
        result = self.monoid.identity
        for symbol in word:
            result = self.monoid.op(result, self.generator_images[symbol])
        return result


# =============================================================================
# Algorithm 1: Memory Spectrum Computation
# =============================================================================

def compute_memory_spectrum(
    mem: MemorySystemSpec,
    max_depth: int
) -> List[int]:
    """
    Compute the cumulative memory spectrum.

    spectrum[k] = |{φ(w) : |w| ≤ k}| = number of distinct states reachable
    by words of length at most k.

    Time complexity: O(max_depth × |S| × |alphabet|)

    Returns:
        List of spectrum values [spectrum(0), spectrum(1), ..., spectrum(max_depth)]
    """
    reachable: Set = {mem.monoid.identity}
    frontier: Set = {mem.monoid.identity}
    spectrum: List[int] = [1]  # spectrum(0) = 1 (identity only)

    for depth in range(1, max_depth + 1):
        new_frontier: Set = set()
        for s in frontier:
            for a in mem.alphabet:
                t = mem.monoid.op(s, mem.generator_images[a])
                if t not in reachable:
                    reachable.add(t)
                    new_frontier.add(t)
        frontier = new_frontier
        spectrum.append(len(reachable))

    return spectrum


# =============================================================================
# Algorithm 2: Cascade Product Construction
# =============================================================================

def cascade_product(
    mem1: MemorySystemSpec,
    mem2: MemorySystemSpec
) -> MemorySystemSpec[any, Tuple]:
    """
    Construct the cascade (parallel) product of two memory systems.

    The cascade product has state space S₁ × S₂ and encodes each word w as
    (φ₁(w), φ₂(w)).

    Precondition: mem1.alphabet == mem2.alphabet

    Time complexity: O(|S₁| × |S₂|) for construction
    """
    assert mem1.alphabet == mem2.alphabet, "Alphabets must match"

    product_elements: Set[Tuple] = {
        (s, t)
        for s in mem1.monoid.elements
        for t in mem2.monoid.elements
    }

    def product_op(a: Tuple, b: Tuple) -> Tuple:
        return (mem1.monoid.op(a[0], b[0]), mem2.monoid.op(a[1], b[1]))

    product_identity = (mem1.monoid.identity, mem2.monoid.identity)

    product_generators = {
        a: (mem1.generator_images[a], mem2.generator_images[a])
        for a in mem1.alphabet
    }

    return MemorySystemSpec(
        alphabet=mem1.alphabet,
        monoid=FiniteMonoid(product_elements, product_op, product_identity),
        generator_images=product_generators
    )


# =============================================================================
# Algorithm 3: Idempotent Power Detection
# =============================================================================

def find_idempotent_power(
    monoid: FiniteMonoid[S],
    s: S
) -> int:
    """
    Find the smallest n > 0 such that s^(2n) = s^n in the monoid.

    This witnesses that s^n is an idempotent (s^n · s^n = s^n).

    By the pigeonhole principle, this always terminates for finite monoids
    with n ≤ |S|².

    Time complexity: O(|S|²)

    Returns:
        The smallest positive n such that s^(2n) = s^n
    """
    m = len(monoid.elements)

    # Compute all powers and check the idempotent condition
    for n in range(1, m * m + 2):
        s_n = monoid.power(s, n)
        s_2n = monoid.power(s, 2 * n)
        if s_2n == s_n:
            return n

    raise RuntimeError(f"No idempotent power found within {m*m+1} steps")


# =============================================================================
# Algorithm 4: Tropical Capacity Valuation
# =============================================================================

def tropical_capacity(mem: MemorySystemSpec, max_depth: int = 100) -> float:
    """
    Compute the tropical capacity valuation v(φ) = log₂|image(φ)|.

    This is the tropical valuation on memory systems: it satisfies
    subadditivity under cascade products and monotonicity under morphisms.

    Returns:
        log₂ of the number of reachable states
    """
    image = compute_reachable_set(mem, max_depth)
    return math.log2(len(image)) if len(image) > 0 else float('-inf')


def compute_reachable_set(mem: MemorySystemSpec, max_depth: int = 100) -> Set:
    """Compute the full reachable set of a memory system."""
    reachable: Set = {mem.monoid.identity}
    frontier: Set = {mem.monoid.identity}

    for _ in range(max_depth):
        new_frontier: Set = set()
        for s in frontier:
            for a in mem.alphabet:
                t = mem.monoid.op(s, mem.generator_images[a])
                if t not in reachable:
                    reachable.add(t)
                    new_frontier.add(t)
        frontier = new_frontier
        if not frontier:
            break

    return reachable


def verify_tropical_subadditivity(
    mem1: MemorySystemSpec,
    mem2: MemorySystemSpec
) -> Tuple[float, float, float, bool]:
    """
    Verify the tropical subadditivity law:
        v(φ₁ × φ₂) ≤ v(φ₁) + v(φ₂)

    Returns:
        (v1, v2, v_cascade, subadditivity_holds)
    """
    v1 = tropical_capacity(mem1)
    v2 = tropical_capacity(mem2)
    casc = cascade_product(mem1, mem2)
    vc = tropical_capacity(casc)

    return (v1, v2, vc, vc <= v1 + v2 + 1e-10)


# =============================================================================
# Algorithm 5: Congruence Class Enumeration
# =============================================================================

def enumerate_congruence_classes(
    mem: MemorySystemSpec,
    max_word_length: int = 5
) -> Dict[any, List[str]]:
    """
    Enumerate congruence classes of a memory system up to a given word length.

    Two words w₁, w₂ are in the same congruence class iff φ(w₁) = φ(w₂).

    Returns:
        Dict mapping each reachable state to the list of words mapping to it
    """
    from itertools import product as cartprod

    alpha_list = sorted(mem.alphabet)
    classes: Dict[any, List[str]] = {}

    # Empty word
    state = mem.monoid.identity
    classes.setdefault(state, []).append('ε')

    for length in range(1, max_word_length + 1):
        for w in cartprod(alpha_list, repeat=length):
            word_list = list(w)
            state = mem.encode(word_list)
            word_str = ''.join(str(s) for s in w)
            classes.setdefault(state, []).append(word_str)

    return classes


# =============================================================================
# Algorithm 6: Spectrum Stabilization Detection
# =============================================================================

def detect_stabilization(spectrum: List[int]) -> Optional[int]:
    """
    Detect the stabilization depth of a memory spectrum.

    Returns the smallest k such that spectrum[k] = spectrum[k+1] = ... = spectrum[-1],
    or None if the spectrum hasn't stabilized within the computed range.
    """
    if len(spectrum) < 2:
        return None

    final_value = spectrum[-1]

    # Find first index where the value reaches the final value
    for k in range(len(spectrum)):
        if spectrum[k] == final_value:
            # Verify stabilization
            if all(spectrum[j] == final_value for j in range(k, len(spectrum))):
                return k

    return None


# =============================================================================
# Helper: Create common memory systems
# =============================================================================

def cyclic_memory(n: int, gen_a: int = 1, gen_b: int = 1) -> MemorySystemSpec[str, int]:
    """Create a memory system over Z/nZ with two generators."""
    monoid = FiniteMonoid(
        elements=set(range(n)),
        op=lambda a, b: (a + b) % n,
        identity=0
    )
    return MemorySystemSpec(
        alphabet={'a', 'b'},
        monoid=monoid,
        generator_images={'a': gen_a % n, 'b': gen_b % n}
    )


def symmetric_group_memory(n: int = 3) -> MemorySystemSpec[str, Tuple]:
    """Create a memory system over S_n with transposition generators."""
    from itertools import permutations

    perms = set(permutations(range(n)))

    def compose(p: Tuple, q: Tuple) -> Tuple:
        return tuple(p[q[i]] for i in range(n))

    identity = tuple(range(n))

    # Generators: (0 1) and (0 1 2 ... n-1)
    swap = list(range(n))
    swap[0], swap[1] = swap[1], swap[0]
    swap = tuple(swap)

    cycle = tuple((i + 1) % n for i in range(n))

    monoid = FiniteMonoid(perms, compose, identity)
    return MemorySystemSpec(
        alphabet={'a', 'b'},
        monoid=monoid,
        generator_images={'a': swap, 'b': cycle}
    )


# =============================================================================
# Main: Run all algorithms on example systems
# =============================================================================

if __name__ == "__main__":
    print("Tropical Memory Compression Algebra - Algorithm Suite")
    print("=" * 60)

    # Create example systems
    mem_z4 = cyclic_memory(4, gen_a=1, gen_b=2)
    mem_z6 = cyclic_memory(6, gen_a=1, gen_b=2)
    mem_s3 = symmetric_group_memory(3)

    systems = [("Z/4Z", mem_z4), ("Z/6Z", mem_z6), ("S₃", mem_s3)]

    for name, mem in systems:
        print(f"\n--- {name} ---")

        # Spectrum
        spec = compute_memory_spectrum(mem, 8)
        stab = detect_stabilization(spec)
        print(f"Spectrum: {spec}")
        print(f"Stabilization depth: {stab}")

        # Tropical capacity
        v = tropical_capacity(mem)
        print(f"Tropical capacity: {v:.3f} bits")

        # Idempotent power
        for symbol in sorted(mem.alphabet):
            n = find_idempotent_power(mem.monoid, mem.generator_images[symbol])
            print(f"Idempotent power of φ({symbol}): n={n}")

    # Cascade product demo
    print("\n--- Cascade Z/3Z × Z/4Z ---")
    mem_z3 = cyclic_memory(3, gen_a=1, gen_b=2)
    mem_z4 = cyclic_memory(4, gen_a=1, gen_b=3)
    v1, v2, vc, holds = verify_tropical_subadditivity(mem_z3, mem_z4)
    print(f"v(Z/3Z) = {v1:.3f}, v(Z/4Z) = {v2:.3f}, v(cascade) = {vc:.3f}")
    print(f"Subadditivity: {vc:.3f} ≤ {v1+v2:.3f}? {holds}")
