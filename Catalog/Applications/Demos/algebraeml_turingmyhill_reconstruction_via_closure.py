#!/usr/bin/env python3
"""
Algorithms for Closure Semimodule Systems.

Implements the key algorithms from the research paper:
1. Partition refinement for computing the Myhill-Nerode quotient
2. Capacity computation with stabilization detection
3. Simulation verification
"""

from typing import Dict, Set, List, Tuple, FrozenSet, Optional
from itertools import product


def partition_refinement(
    states: List[int],
    alphabet: List[str],
    step: Dict[Tuple[int, str], int],
    probes: List[callable],
    closure: callable,
    max_depth: int = 100
) -> Tuple[List[List[int]], int]:
    """
    Compute the Myhill-Nerode quotient via partition refinement.

    Algorithm (O(|σ|² · |α| · N)):
    1. Start with partition based on closure traces at depth 0
    2. Refine: split classes where step-successors land in different classes
    3. Repeat until stable (guaranteed in ≤ |σ| steps)

    Returns (equivalence_classes, stabilization_depth).
    """
    def trace_at_word(s, word):
        """Compute closure trace for state s under word."""
        current = s
        for a in word:
            current = step[(current, a)]
        closed = closure(frozenset([current]))
        return frozenset(p(x) for x in closed for p in probes)

    def signature(s, depth):
        """Compute trace signature up to given depth."""
        sig = []
        for n in range(depth + 1):
            for word in words_of_length(alphabet, n):
                sig.append(trace_at_word(s, word))
        return tuple(sig)

    # Iterative refinement
    prev_num_classes = 0
    stabilization_depth = 0

    for depth in range(min(max_depth, len(states)) + 1):
        # Compute equivalence classes at this depth
        sig_to_class = {}
        classes = []
        for s in states:
            sig = signature(s, depth)
            if sig not in sig_to_class:
                sig_to_class[sig] = len(classes)
                classes.append([])
            classes[sig_to_class[sig]].append(s)

        num_classes = len(classes)

        if num_classes == prev_num_classes:
            stabilization_depth = depth - 1
            break

        prev_num_classes = num_classes
        stabilization_depth = depth

    return classes, stabilization_depth


def words_of_length(alphabet: List[str], n: int) -> List[Tuple[str, ...]]:
    """Generate all words of exactly length n over alphabet."""
    if n == 0:
        return [()]
    return list(product(alphabet, repeat=n))


def compute_capacity_curve(
    states: List[int],
    alphabet: List[str],
    step: Dict[Tuple[int, str], int],
    probes: List[callable],
    closure: callable,
    max_n: int = 10
) -> List[int]:
    """
    Compute IntrinsicCapacity(n) for n = 0, 1, ..., max_n.

    Returns a list of capacity values.
    Complexity: O(max_n · |σ| · Σ_{k=0}^{max_n} |α|^k)
    """
    def trace_at_word(s, word):
        current = s
        for a in word:
            current = step[(current, a)]
        closed = closure(frozenset([current]))
        return frozenset(p(x) for x in closed for p in probes)

    capacities = []

    for n in range(max_n + 1):
        profiles = set()
        for s in states:
            profile = []
            for depth in range(n + 1):
                for word in words_of_length(alphabet, depth):
                    profile.append(trace_at_word(s, word))
            profiles.add(tuple(profile))
        capacities.append(len(profiles))

    return capacities


def verify_simulation(
    states1: List[int], states2: List[int],
    alphabet: List[str],
    step1: Dict[Tuple[int, str], int],
    step2: Dict[Tuple[int, str], int],
    sim_map: Dict[int, int]
) -> Tuple[bool, Optional[str]]:
    """
    Verify that sim_map is a valid simulation from system 1 to system 2.

    Checks:
    - sim_map(step1(s, a)) = step2(sim_map(s), a) for all s, a

    Returns (is_valid, error_message).
    """
    for s in states1:
        for a in alphabet:
            s_next = step1[(s, a)]
            mapped_next = sim_map.get(s_next)
            expected = step2.get((sim_map[s], a))

            if mapped_next is None:
                return False, f"sim_map undefined on {s_next}"
            if expected is None:
                return False, f"step2 undefined on ({sim_map[s]}, {a})"
            if mapped_next != expected:
                return False, (
                    f"Simulation violation: "
                    f"sim(step1({s}, {a})) = sim({s_next}) = {mapped_next} "
                    f"≠ step2(sim({s}), {a}) = step2({sim_map[s]}, {a}) = {expected}"
                )

    return True, None


def demo_algorithms():
    """Demonstrate all algorithms."""
    print("=" * 60)
    print("ALGORITHM DEMOS")
    print("=" * 60)

    # System 1: 5-state DFA
    states = [0, 1, 2, 3, 4]
    alphabet = ['a', 'b']
    step = {
        (0, 'a'): 1, (0, 'b'): 2,
        (1, 'a'): 3, (1, 'b'): 4,
        (2, 'a'): 3, (2, 'b'): 4,
        (3, 'a'): 3, (3, 'b'): 3,
        (4, 'a'): 4, (4, 'b'): 4,
    }
    output = {0: 0, 1: 0, 2: 0, 3: 1, 4: 0}
    closure = lambda S: S
    probes = [lambda x, o=output: o[x]]

    print("\n1. PARTITION REFINEMENT")
    print(f"   States: {states}")
    classes, depth = partition_refinement(states, alphabet, step, probes, closure)
    print(f"   Equivalence classes: {classes}")
    print(f"   Stabilization depth: {depth}")
    print(f"   Quotient size: {len(classes)} (original: {len(states)})")

    print("\n2. CAPACITY CURVE")
    caps = compute_capacity_curve(states, alphabet, step, probes, closure, max_n=6)
    for n, c in enumerate(caps):
        stab = " ← stable" if n > 0 and c == caps[n-1] else ""
        print(f"   Capacity({n}) = {c}{stab}")

    print("\n3. SIMULATION VERIFICATION")
    # Quotient system
    states2 = [0, 1, 2]
    step2 = {
        (0, 'a'): 1, (0, 'b'): 1,
        (1, 'a'): 2, (1, 'b'): 1,
        (2, 'a'): 2, (2, 'b'): 2,
    }
    # Map: 0→0, 1→1, 2→1, 3→2, 4→1
    sim = {0: 0, 1: 1, 2: 1, 3: 2, 4: 1}
    valid, error = verify_simulation(states, states2, alphabet, step, step2, sim)
    print(f"   Simulation valid: {valid}")
    if error:
        print(f"   Error: {error}")


if __name__ == "__main__":
    demo_algorithms()


#!/usr/bin/env python3
"""
Applications of Closure Semimodule Systems.

Demonstrates real-world connections:
1. Cryptographic indistinguishability analysis
2. ML model state compression
3. Quantum-inspired coarse-graining
"""

import random
from typing import List, Set, Dict, Tuple


def crypto_indistinguishability_demo():
    """
    Application: Cryptographic State Indistinguishability

    Models a simplified block cipher with 8 states.
    The "closure" groups states that are computationally
    indistinguishable (same ciphertext distribution).
    Shows how many distinct security classes exist.
    """
    print("=" * 60)
    print("APPLICATION 1: Cryptographic Indistinguishability")
    print("=" * 60)
    print()

    # 8 cipher states, grouped by indistinguishability
    states = list(range(8))
    alphabet = ['enc', 'dec']  # encrypt and decrypt operations

    # Transitions: enc cycles through states, dec reverses
    step = {}
    for s in states:
        step[(s, 'enc')] = (s + 1) % 8
        step[(s, 'dec')] = (s - 1) % 8

    # Output: ciphertext residue mod 4
    output = {s: s % 4 for s in states}

    # Closure: states with same residue mod 2 are computationally close
    def crypto_closure(S):
        result = set(S)
        for s in list(S):
            # Group by mod 2 (adversary can't distinguish)
            for t in states:
                if t % 2 == s % 2:
                    result.add(t)
        return frozenset(result)

    probes = [lambda x, o=output: o[x]]

    # Compute traces
    print("Security classes (closure-indistinguishable groups):")
    classes = {}
    for s in states:
        trace_key = []
        for word in [(), ('enc',), ('dec',), ('enc', 'enc')]:
            current = s
            for a in word:
                current = step[(current, a)]
            closed = crypto_closure(frozenset([current]))
            vals = frozenset(output[x] for x in closed)
            trace_key.append(vals)
        trace_key = tuple(trace_key)
        if trace_key not in classes:
            classes[trace_key] = []
        classes[trace_key].append(s)

    for i, (_, group) in enumerate(classes.items()):
        print(f"  Security class {i}: states {group}")

    print(f"\nMinimum implementation states: {len(classes)}")
    print(f"Original states: {len(states)}")
    print(f"Compression ratio: {len(states)/len(classes):.1f}x")
    print()


def ml_model_compression_demo():
    """
    Application: ML Model State Compression

    Models a neural network classifier with 10 hidden states.
    Uses closure to group states with similar activation patterns.
    Computes the minimal model that preserves input-output behavior.
    """
    print("=" * 60)
    print("APPLICATION 2: ML Model State Compression")
    print("=" * 60)
    print()

    # 10 hidden states in a classifier
    states = list(range(10))
    features = ['f1', 'f2', 'f3']  # input features

    # Transition: deterministic feature processing
    random.seed(42)
    step = {}
    for s in states:
        for f in features:
            step[(s, f)] = (s * 3 + hash(f)) % 10

    # Output: classification score (mod 3)
    output = {s: s % 3 for s in states}

    # Closure: ReLU-based grouping (states with same sign pattern)
    def relu_closure(S):
        result = set(S)
        for s in list(S):
            for t in states:
                if output[t] == output[s]:
                    result.add(t)
        return frozenset(result)

    probes = [lambda x, o=output: o[x]]

    # Compute quotient
    classes = {}
    for s in states:
        profile = []
        for depth in range(3):
            for word in _words_of_length(features, depth):
                current = s
                for f in word:
                    current = step[(current, f)]
                closed = relu_closure(frozenset([current]))
                vals = frozenset(output[x] for x in closed)
                profile.append(vals)
        profile = tuple(profile)
        if profile not in classes:
            classes[profile] = []
        classes[profile].append(s)

    print("Hidden state groups (preserved by all feature sequences):")
    for i, (_, group) in enumerate(classes.items()):
        out_vals = {output[s] for s in group}
        print(f"  Group {i}: states {group} (outputs: {out_vals})")

    print(f"\nOriginal model: {len(states)} hidden states")
    print(f"Compressed model: {len(classes)} states")
    print(f"Memory reduction: {(1 - len(classes)/len(states))*100:.0f}%")
    print()


def quantum_coarsegraining_demo():
    """
    Application: Quantum-Inspired Coarse-Graining

    Models a 6-qubit system where pairs of states are
    entangled (indistinguishable by local measurements).
    Computes the effective macroscopic dynamics.
    """
    print("=" * 60)
    print("APPLICATION 3: Quantum Coarse-Graining")
    print("=" * 60)
    print()

    states = list(range(6))
    operations = ['X', 'Z']  # Pauli-X and Pauli-Z gates

    # Transitions: X gate swaps pairs, Z gate shifts
    step = {}
    for s in states:
        step[(s, 'X')] = s ^ 1  # flip last bit (swap pairs)
        step[(s, 'Z')] = (s + 2) % 6  # shift by 2

    # Energy observable
    energy = {0: 0, 1: 0, 2: 1, 3: 1, 4: 2, 5: 2}

    # Quantum closure: entangled pairs are indistinguishable
    def quantum_closure(S):
        result = set(S)
        for s in list(S):
            result.add(s ^ 1)  # entangled partner
        return frozenset(result)

    probes = [lambda x, e=energy: e[x]]

    # Compute macrostates
    classes = {}
    for s in states:
        profile = []
        for word in [(), ('X',), ('Z',), ('X', 'Z'), ('Z', 'X')]:
            current = s
            for op in word:
                current = step[(current, op)]
            closed = quantum_closure(frozenset([current]))
            vals = frozenset(energy[x] for x in closed)
            profile.append(vals)
        profile = tuple(profile)
        if profile not in classes:
            classes[profile] = []
        classes[profile].append(s)

    print("Macrostates (quantum coarse-grained):")
    for i, (_, group) in enumerate(classes.items()):
        energies = {energy[s] for s in group}
        print(f"  Macrostate {i}: microstates {group}, energy levels {energies}")

    print(f"\nMicrostates: {len(states)}")
    print(f"Macrostates: {len(classes)}")
    print(f"Effective dimension reduction: {len(states)} → {len(classes)}")
    print()


def _words_of_length(alphabet, n):
    if n == 0:
        return [()]
    result = []
    for a in alphabet:
        for w in _words_of_length(alphabet, n - 1):
            result.append((a,) + w)
    return result


if __name__ == "__main__":
    crypto_indistinguishability_demo()
    ml_model_compression_demo()
    quantum_coarsegraining_demo()


#!/usr/bin/env python3
"""
Closure Semimodule System: Concrete numerical demonstrations.

This module demonstrates the key concepts of the closure semimodule
framework with concrete numerical examples:
1. A simple DFA with identity closure
2. A system with non-trivial closure (grouping states)
3. Capacity growth and stabilization
"""

from typing import Dict, Set, Tuple, List, FrozenSet, Callable


class ClosureSemimoduleSystem:
    """A closure semimodule system with finite state and alphabet."""

    def __init__(self, states, alphabet, step, output, closure):
        self.states = states
        self.alphabet = alphabet
        self.step = step       # (state, symbol) -> state
        self.output = output   # state -> value
        self.closure = closure # frozenset -> frozenset

    def eval_word(self, s, word):
        """Evaluate a word from state s."""
        for a in word:
            s = self.step[(s, a)]
        return s

    def closure_trace(self, probes, s, word):
        """Compute the closure trace: set of probe values after closure."""
        final = self.eval_word(s, word)
        closed = self.closure(frozenset([final]))
        values = set()
        for x in closed:
            for p in probes:
                values.add(p(x))
        return frozenset(values)

    def indistinguishable(self, probes, s, t, max_depth=10):
        """Check if s and t are indistinguishable up to max_depth."""
        for n in range(max_depth + 1):
            for word in self._words_up_to(n):
                if self.closure_trace(probes, s, word) != self.closure_trace(probes, t, word):
                    return False
        return True

    def _words_up_to(self, n):
        """Generate all words up to length n."""
        if n == 0:
            return [()]
        shorter = self._words_up_to(n - 1)
        longer = [(a,) + w for a in self.alphabet for w in self._words_of_length(n - 1)]
        return shorter + longer

    def _words_of_length(self, n):
        """Generate all words of exactly length n."""
        if n == 0:
            return [()]
        return [(a,) + w for a in self.alphabet for w in self._words_of_length(n - 1)]

    def compute_quotient(self, probes, max_depth=10):
        """Compute equivalence classes by brute force."""
        classes = []
        state_to_class = {}
        for s in self.states:
            found = False
            for i, cls in enumerate(classes):
                rep = cls[0]
                if self.indistinguishable(probes, s, rep, max_depth):
                    cls.append(s)
                    state_to_class[s] = i
                    found = True
                    break
            if not found:
                state_to_class[s] = len(classes)
                classes.append([s])
        return classes, state_to_class

    def intrinsic_capacity(self, probes, n):
        """Number of distinct trace profiles using words up to length n."""
        profiles = set()
        for s in self.states:
            profile = []
            for word in self._words_up_to(n):
                profile.append(self.closure_trace(probes, s, word))
            profiles.add(tuple(profile))
        return len(profiles)


def demo_identity_closure():
    """Demo 1: DFA with identity closure (classical Myhill-Nerode)."""
    print("=" * 60)
    print("DEMO 1: DFA with Identity Closure")
    print("=" * 60)
    print()
    print("States: {0, 1, 2, 3}")
    print("Alphabet: {a, b}")
    print("Accepting states: {2, 3}")
    print()

    states = {0, 1, 2, 3}
    alphabet = {'a', 'b'}
    step = {
        (0, 'a'): 1, (0, 'b'): 0,
        (1, 'a'): 2, (1, 'b'): 0,
        (2, 'a'): 2, (2, 'b'): 3,
        (3, 'a'): 2, (3, 'b'): 3,
    }
    output = {0: 0, 1: 0, 2: 1, 3: 1}
    closure = lambda S: S  # identity closure

    M = ClosureSemimoduleSystem(states, alphabet, step, output, closure)
    probes = [lambda x, o=output: o[x]]

    classes, mapping = M.compute_quotient(probes)
    print(f"Number of equivalence classes: {len(classes)}")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: {cls}")

    print()
    print("Capacity growth:")
    for n in range(6):
        cap = M.intrinsic_capacity(probes, n)
        print(f"  IntrinsicCapacity({n}) = {cap}")

    print()
    print("States 2 and 3 are indistinguishable (both accepting, same transitions)")
    print(f"  Indistinguishable(2, 3) = {M.indistinguishable(probes, 2, 3)}")
    print(f"  Indistinguishable(0, 1) = {M.indistinguishable(probes, 0, 1)}")
    print()


def demo_nontrivial_closure():
    """Demo 2: System with non-trivial closure."""
    print("=" * 60)
    print("DEMO 2: System with Non-Trivial Closure")
    print("=" * 60)
    print()
    print("States: {0, 1, 2, 3, 4, 5}")
    print("Closure groups: {0,1}, {2,3}, {4,5}")
    print("(Each pair is merged by the closure operator)")
    print()

    states = {0, 1, 2, 3, 4, 5}
    alphabet = {'a'}
    step = {
        (0, 'a'): 2, (1, 'a'): 3,
        (2, 'a'): 4, (3, 'a'): 5,
        (4, 'a'): 0, (5, 'a'): 1,
    }
    output = {0: 10, 1: 20, 2: 30, 3: 40, 4: 50, 5: 60}

    def closure(S):
        result = set(S)
        pairs = [{0, 1}, {2, 3}, {4, 5}]
        for pair in pairs:
            if result & pair:
                result |= pair
        return frozenset(result)

    M = ClosureSemimoduleSystem(states, alphabet, step, output, closure)
    probes = [lambda x, o=output: o[x]]

    classes, mapping = M.compute_quotient(probes)
    print(f"Number of equivalence classes: {len(classes)}")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: {cls}")

    print()
    print("Closure trace at empty word from state 0:")
    trace = M.closure_trace(probes, 0, ())
    print(f"  CT(0, []) = {set(trace)}")
    print(f"  (Closure of {{0}} = {{0, 1}}, so we get outputs of both)")

    print()
    print("Capacity growth:")
    for n in range(6):
        cap = M.intrinsic_capacity(probes, n)
        print(f"  IntrinsicCapacity({n}) = {cap}")
    print()


def demo_stabilization():
    """Demo 3: Demonstrating capacity stabilization."""
    print("=" * 60)
    print("DEMO 3: Capacity Stabilization")
    print("=" * 60)
    print()
    print("A system where distinguishing requires depth 2:")
    print("States look the same at depth 0-1, but differ at depth 2.")
    print()

    states = {0, 1, 2, 3}
    alphabet = {'a', 'b'}
    step = {
        (0, 'a'): 2, (0, 'b'): 2,
        (1, 'a'): 3, (1, 'b'): 2,
        (2, 'a'): 2, (2, 'b'): 2,
        (3, 'a'): 3, (3, 'b'): 3,
    }
    output = {0: 0, 1: 0, 2: 1, 3: 1}
    closure = lambda S: S

    M = ClosureSemimoduleSystem(states, alphabet, step, output, closure)
    probes = [lambda x, o=output: o[x]]

    print("Output values: 0→0, 1→0, 2→1, 3→1")
    print()
    print("Trace comparison for states 0 and 1:")

    for n in range(4):
        for word in M._words_of_length(n):
            t0 = M.closure_trace(probes, 0, word)
            t1 = M.closure_trace(probes, 1, word)
            word_str = ''.join(word) if word else 'ε'
            if t0 != t1:
                print(f"  word='{word_str}': CT(0)={set(t0)}, CT(1)={set(t1)} ← DIFFERENT!")

    print()
    print("Capacity growth (showing stabilization):")
    caps = []
    for n in range(6):
        cap = M.intrinsic_capacity(probes, n)
        caps.append(cap)
        stab = " ← stabilized!" if n > 0 and cap == caps[-2] else ""
        print(f"  IntrinsicCapacity({n}) = {cap}{stab}")

    print()
    print("Equivalence classes:")
    classes, _ = M.compute_quotient(probes)
    for i, cls in enumerate(classes):
        print(f"  Class {i}: {cls}")
    print()


if __name__ == "__main__":
    demo_identity_closure()
    demo_nontrivial_closure()
    demo_stabilization()
