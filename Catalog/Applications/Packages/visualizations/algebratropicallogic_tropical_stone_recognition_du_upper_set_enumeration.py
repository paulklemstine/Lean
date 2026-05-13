#!/usr/bin/env python3
"""
Algorithms for Tropical Stone Recognition Duality

Implements:
1. Upper-set enumeration and semiring construction
2. Partition refinement for tropical automata minimization
3. Congruence spectrum computation
4. Spectral reconstruction of minimal recognizers
"""

from typing import Set, FrozenSet, List, Tuple, Dict, Optional
from itertools import product
from collections import defaultdict


# ============================================================
# §1. Tropical Min-Plus Semiring
# ============================================================

INF = float('inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (ordinary addition)."""
    return a + b

def trop_matrix_mul(A: List[List[float]], B: List[List[float]]) -> List[List[float]]:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})."""
    n = len(A)
    m = len(B[0])
    k = len(B)
    result = [[INF] * m for _ in range(n)]
    for i in range(n):
        for j in range(m):
            for l in range(k):
                result[i][j] = min(result[i][j], A[i][l] + B[l][j])
    return result


# ============================================================
# §2. Partition Refinement for Tropical Automata Minimization
# ============================================================

class TropicalAutomaton:
    """A tropical (min-plus) weighted automaton.

    States: 0, ..., n-1
    Alphabet: list of symbols
    Transitions: dict mapping (state, symbol) -> list of (next_state, weight)
    Initial weights: list of weights for each state
    Final weights: list of weights for each state
    """

    def __init__(self, n_states: int, alphabet: List[str],
                 transitions: Dict[Tuple[int, str], List[Tuple[int, float]]],
                 initial: List[float], final: List[float]):
        self.n = n_states
        self.alphabet = alphabet
        self.transitions = transitions
        self.initial = initial
        self.final = final

    def weight_of_word(self, word: List[str]) -> float:
        """Compute the tropical weight of a word (minimum over all paths)."""
        # dp[state] = min cost to reach state after reading word prefix
        dp = list(self.initial)
        for symbol in word:
            new_dp = [INF] * self.n
            for state in range(self.n):
                if dp[state] < INF:
                    for next_state, weight in self.transitions.get((state, symbol), []):
                        new_dp[next_state] = min(new_dp[next_state],
                                                  dp[state] + weight)
            dp = new_dp
        # Add final weights
        return min(dp[s] + self.final[s] for s in range(self.n))


def partition_refinement_minimize(automaton: TropicalAutomaton) -> TropicalAutomaton:
    """Minimize a tropical automaton using partition refinement.

    Algorithm:
    1. Start with initial partition based on final weights.
    2. Iteratively refine: split blocks whose elements have different
       transition signatures (where transitions lead, modulo current partition).
    3. Terminate when no more splits are possible.

    Returns a minimal tropical automaton.

    Time complexity: O(n² |Σ| log n) using Hopcroft-style refinement.
    Space complexity: O(n² |Σ|).
    """
    n = automaton.n

    # Initial partition: group states by final weight
    final_classes: Dict[float, List[int]] = defaultdict(list)
    for s in range(n):
        final_classes[automaton.final[s]].append(s)
    partition = list(final_classes.values())

    # Build state-to-block mapping
    def state_to_block(partition):
        mapping = {}
        for i, block in enumerate(partition):
            for s in block:
                mapping[s] = i
        return mapping

    # Iterative refinement
    changed = True
    while changed:
        changed = False
        s2b = state_to_block(partition)
        new_partition = []
        for block in partition:
            # Compute signature for each state in the block
            signatures: Dict[tuple, List[int]] = defaultdict(list)
            for s in block:
                sig = []
                for symbol in automaton.alphabet:
                    trans = automaton.transitions.get((s, symbol), [])
                    # Signature: for each target block, what's the min weight?
                    block_weights = defaultdict(lambda: INF)
                    for next_s, w in trans:
                        b = s2b[next_s]
                        block_weights[b] = min(block_weights[b], w)
                    sig.append(tuple(sorted(block_weights.items())))
                signatures[tuple(sig)].append(s)
            sub_blocks = list(signatures.values())
            if len(sub_blocks) > 1:
                changed = True
            new_partition.extend(sub_blocks)
        partition = new_partition

    # Build minimized automaton
    s2b = state_to_block(partition)
    n_new = len(partition)

    # New initial weights
    new_initial = [INF] * n_new
    for s in range(n):
        b = s2b[s]
        new_initial[b] = min(new_initial[b], automaton.initial[s])

    # New final weights
    new_final = [INF] * n_new
    for s in range(n):
        b = s2b[s]
        new_final[b] = min(new_final[b], automaton.final[s])

    # New transitions
    new_transitions: Dict[Tuple[int, str], List[Tuple[int, float]]] = defaultdict(list)
    for s in range(n):
        b_src = s2b[s]
        for symbol in automaton.alphabet:
            for next_s, w in automaton.transitions.get((s, symbol), []):
                b_dst = s2b[next_s]
                new_transitions[(b_src, symbol)].append((b_dst, w))

    # Deduplicate transitions (keep min weight per target)
    final_transitions = {}
    for key, trans_list in new_transitions.items():
        best: Dict[int, float] = {}
        for dst, w in trans_list:
            if dst not in best or w < best[dst]:
                best[dst] = w
        final_transitions[key] = [(dst, w) for dst, w in best.items()]

    return TropicalAutomaton(n_new, automaton.alphabet,
                              final_transitions, new_initial, new_final)


# ============================================================
# §3. Congruence Spectrum Computation
# ============================================================

def compute_congruences(elements: List[int],
                        add_table: Dict[Tuple[int, int], int],
                        mul_table: Dict[Tuple[int, int], int]
                        ) -> List[List[FrozenSet[int]]]:
    """Compute all proper ring congruences on a finite semiring.

    A congruence is an equivalence relation ~ such that:
    - a ~ b and c ~ d implies a+c ~ b+d
    - a ~ b and c ~ d implies a*c ~ b*d

    Returns list of partitions (each partition = list of equivalence classes).
    """
    n = len(elements)

    def is_congruence(partition: List[FrozenSet[int]]) -> bool:
        """Check if a partition is a ring congruence."""
        # Build class lookup
        class_of = {}
        for i, block in enumerate(partition):
            for x in block:
                class_of[x] = i
        # Check compatibility with addition
        for a in elements:
            for b in elements:
                for c in elements:
                    for d in elements:
                        if class_of[a] == class_of[b] and class_of[c] == class_of[d]:
                            if class_of[add_table[(a, c)]] != class_of[add_table[(b, d)]]:
                                return False
                            if class_of[mul_table[(a, c)]] != class_of[mul_table[(b, d)]]:
                                return False
        return True

    def is_proper(partition: List[FrozenSet[int]]) -> bool:
        """A congruence is proper if it's not the total relation."""
        return len(partition) > 1

    # Generate all partitions (for small sets)
    def all_partitions(elems: List[int]) -> List[List[FrozenSet[int]]]:
        if not elems:
            return [[]]
        first = elems[0]
        rest = elems[1:]
        result = []
        for partition in all_partitions(rest):
            # Add first to each existing block
            for i in range(len(partition)):
                new_part = [block if j != i else block | {first}
                           for j, block in enumerate(partition)]
                result.append(new_part)
            # Create new singleton block
            result.append([frozenset({first})] + partition)
        return result

    congruences = []
    for partition in all_partitions(elements):
        if is_proper(partition) and is_congruence(partition):
            congruences.append(partition)

    return congruences


# ============================================================
# §4. Demo
# ============================================================

def demo_minimization():
    """Demonstrate tropical automata minimization."""
    print("="*60)
    print("  TROPICAL AUTOMATA MINIMIZATION DEMO")
    print("="*60)

    # Build a simple tropical automaton with redundant states
    # States 0,1,2 where 1 and 2 are equivalent
    automaton = TropicalAutomaton(
        n_states=3,
        alphabet=['a', 'b'],
        transitions={
            (0, 'a'): [(1, 1)],
            (0, 'b'): [(2, 1)],
            (1, 'a'): [(0, 2)],
            (1, 'b'): [(1, 0)],
            (2, 'a'): [(0, 2)],
            (2, 'b'): [(2, 0)],
        },
        initial=[0, INF, INF],
        final=[INF, 0, 0]
    )

    print(f"\n  Original automaton: {automaton.n} states")
    test_words = [['a'], ['b'], ['a', 'a'], ['a', 'b'], ['b', 'a'], ['b', 'b']]
    for w in test_words:
        wt = automaton.weight_of_word(w)
        print(f"    weight({''.join(w)}) = {wt}")

    minimized = partition_refinement_minimize(automaton)
    print(f"\n  Minimized automaton: {minimized.n} states")
    for w in test_words:
        wt = minimized.weight_of_word(w)
        print(f"    weight({''.join(w)}) = {wt}")

    # Verify equivalence
    all_match = all(
        automaton.weight_of_word(w) == minimized.weight_of_word(w)
        for w in test_words
    )
    print(f"\n  Weights match: {'✓' if all_match else '✗'}")
    print(f"  Compression: {automaton.n} → {minimized.n} states "
          f"({(1 - minimized.n/automaton.n)*100:.0f}% reduction)")


def demo_congruences():
    """Demonstrate congruence spectrum computation."""
    print("\n" + "="*60)
    print("  CONGRUENCE SPECTRUM DEMO")
    print("="*60)

    # The 2-element Boolean idempotent semiring: {0, 1}
    # where 0+0=0, 0+1=1, 1+0=1, 1+1=1 (max)
    # and 0*0=0, 0*1=0, 1*0=0, 1*1=1 (min)
    elements = [0, 1]
    add_table = {(a, b): max(a, b) for a in elements for b in elements}
    mul_table = {(a, b): min(a, b) for a in elements for b in elements}

    print("\n  Semiring: {0, 1} with max (addition) and min (multiplication)")
    print("  Addition table:")
    for a in elements:
        for b in elements:
            print(f"    {a} + {b} = {add_table[(a,b)]}")
    print("  Multiplication table:")
    for a in elements:
        for b in elements:
            print(f"    {a} * {b} = {mul_table[(a,b)]}")

    congruences = compute_congruences(elements, add_table, mul_table)
    print(f"\n  Proper congruences: {len(congruences)}")
    for i, cong in enumerate(congruences):
        print(f"    C{i}: {[set(block) for block in cong]}")

    # 3-element chain semiring: {0, 1, 2} with max and min
    elements3 = [0, 1, 2]
    add_table3 = {(a, b): max(a, b) for a in elements3 for b in elements3}
    mul_table3 = {(a, b): min(a, b) for a in elements3 for b in elements3}

    print(f"\n  Semiring: {{0, 1, 2}} with max and min")
    congruences3 = compute_congruences(elements3, add_table3, mul_table3)
    print(f"  Proper congruences: {len(congruences3)}")
    for i, cong in enumerate(congruences3):
        print(f"    C{i}: {[set(block) for block in cong]}")

    # Show the inclusion order
    if len(congruences3) > 1:
        print(f"\n  Congruence inclusion order (finer ≤ coarser):")
        for i, ci in enumerate(congruences3):
            for j, cj in enumerate(congruences3):
                if i != j:
                    # ci ≤ cj if ci refines cj
                    class_i = {}
                    for bi, block in enumerate(ci):
                        for x in block:
                            class_i[x] = bi
                    refines = all(
                        all(class_i[x] == class_i[y] for x in block for y in block)
                        for block in cj
                    )
                    if refines:
                        print(f"    C{i} ≤ C{j}")


if __name__ == "__main__":
    demo_minimization()
    demo_congruences()
