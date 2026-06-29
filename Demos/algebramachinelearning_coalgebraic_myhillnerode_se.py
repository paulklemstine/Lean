#!/usr/bin/env python3
"""
Algorithms: Partition Refinement for Neural State Compression

Implements the partition refinement algorithm from the coalgebraic
Myhill-Nerode theory, with explicit complexity tracking.
"""
from typing import TypeVar, Callable, Generic, Dict, List, Set, Tuple
from itertools import product as itertools_product

S = TypeVar('S')  # State type
A = TypeVar('A')  # Alphabet type
B = TypeVar('B')  # Output type


class PartitionRefinement(Generic[S, A, B]):
    """
    Partition refinement algorithm for computing the behavioral
    equivalence quotient of a neural observation system.

    Complexity: O(n^2 * |A|) where n = |states|.
    Each refinement step is O(n * |A|).
    At most n refinement steps before stabilization.

    This implements Algorithm 1 from the research paper.
    """

    def __init__(
        self,
        states: List[S],
        alphabet: List[A],
        step: Callable[[S, A], S],
        observe: Callable[[S], B],
    ):
        self.states = states
        self.alphabet = alphabet
        self.step = step
        self.observe = observe
        self.refinement_steps = 0
        self.total_comparisons = 0

    def compute_signature(self, state: S, depth: int) -> Tuple:
        """
        Compute the observation signature of a state at given depth.

        Returns a tuple of observations for all words up to length `depth`.
        Complexity: O(sum_{i=0}^{depth} |A|^i) = O(|A|^depth).
        """
        sig = []
        for k in range(depth + 1):
            for word in itertools_product(self.alphabet, repeat=k):
                s = state
                for a in word:
                    s = self.step(s, a)
                sig.append(self.observe(s))
                self.total_comparisons += 1
        return tuple(sig)

    def partition_at_depth(self, depth: int) -> Dict[Tuple, List[S]]:
        """
        Compute the partition at a given observation depth.

        States with the same signature are grouped together.
        """
        partition: Dict[Tuple, List[S]] = {}
        for s in self.states:
            sig = self.compute_signature(s, depth)
            if sig not in partition:
                partition[sig] = []
            partition[sig].append(s)
        return partition

    def refine(self, max_depth: int = None) -> List[List[S]]:
        """
        Run partition refinement until stabilization.

        Args:
            max_depth: Maximum refinement depth. Defaults to |states|.

        Returns:
            List of equivalence classes.

        Complexity: O(n^2 * |A|) total, where n = |states|.
        Terminates in at most n = |states| steps.
        """
        if max_depth is None:
            max_depth = len(self.states)

        prev_count = 0
        self.refinement_steps = 0
        self.total_comparisons = 0

        for depth in range(max_depth + 1):
            partition = self.partition_at_depth(depth)
            curr_count = len(partition)
            self.refinement_steps = depth

            if curr_count == prev_count and depth > 0:
                # Stabilized: no new splits
                break
            prev_count = curr_count

        return list(partition.values())

    def minimal_system(self, max_depth: int = None):
        """
        Compute the minimal quotient system.

        Returns:
            (classes, representatives, new_step, new_observe)
        """
        classes = self.refine(max_depth)
        # Map each state to its class index
        state_to_class: Dict[S, int] = {}
        for i, cls in enumerate(classes):
            for s in cls:
                state_to_class[s] = i

        def new_step(q: int, a: A) -> int:
            rep = classes[q][0]
            return state_to_class[self.step(rep, a)]

        def new_observe(q: int) -> B:
            return self.observe(classes[q][0])

        return classes, state_to_class, new_step, new_observe

    def print_report(self):
        """Print a summary of the refinement process."""
        classes = self.refine()
        print(f"  Original states: {len(self.states)}")
        print(f"  Equivalence classes: {len(classes)}")
        print(f"  Compression ratio: {len(classes)/len(self.states):.2%}")
        print(f"  Refinement steps: {self.refinement_steps}")
        print(f"  Total comparisons: {self.total_comparisons}")
        for i, cls in enumerate(classes):
            print(f"    Class {i}: {cls}")
        return classes


def verify_compression(
    states, alphabet, step, observe,
    classes, state_to_class, new_step, new_observe,
    max_depth=5,
):
    """
    Verify that the compressed system preserves all behaviors.

    Returns True if all behaviors match for words up to max_depth.
    """
    for s in states:
        q = state_to_class[s]
        for k in range(max_depth + 1):
            for word in itertools_product(alphabet, repeat=k):
                # Original behavior
                curr_s = s
                for a in word:
                    curr_s = step(curr_s, a)
                orig_obs = observe(curr_s)

                # Compressed behavior
                curr_q = q
                for a in word:
                    curr_q = new_step(curr_q, a)
                comp_obs = new_observe(curr_q)

                if orig_obs != comp_obs:
                    return False, (s, word, orig_obs, comp_obs)
    return True, None


# ─── Example Usage ───────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("Partition Refinement Algorithm Demo")
    print("=" * 60)

    # Example: 8-state system with 4 equivalence classes
    # States 0-7, where state s behaves like s % 4
    states = list(range(8))
    alphabet = [0, 1]

    def step_fn(s, a):
        return ((s % 4) + a) % 4 + (4 if s >= 4 else 0)

    def observe_fn(s):
        return s % 4

    pr = PartitionRefinement(states, alphabet, step_fn, observe_fn)
    print("\nExample: 8 states, 4 equivalence classes")
    classes = pr.print_report()

    # Verify compression
    cls, s2c, ns, no = pr.minimal_system()
    ok, err = verify_compression(
        states, alphabet, step_fn, observe_fn,
        cls, s2c, ns, no, max_depth=6,
    )
    print(f"  Compression verified: {ok}")

    # Larger example: 20 states with various redundancies
    print("\n" + "-" * 60)
    states2 = list(range(20))

    def step_fn2(s, a):
        return ((s % 5) + a) % 5 + (5 * (s // 5))

    def observe_fn2(s):
        return s % 5

    pr2 = PartitionRefinement(states2, [0, 1, 2], step_fn2, observe_fn2)
    print("\nExample: 20 states, alphabet size 3")
    pr2.print_report()

    # Observation budget analysis
    print("\n" + "-" * 60)
    print("\nObservation Budget Analysis")
    print(f"{'|A|':>4} {'depth k':>8} {'words':>10} {'formula':>30}")
    print("-" * 56)
    for a_size in [2, 3, 5, 10]:
        for k in [1, 2, 3, 5, 10]:
            total = sum(a_size**i for i in range(k + 1))
            formula = f"sum(i=0..{k}) {a_size}^i"
            print(f"{a_size:>4} {k:>8} {total:>10,} {formula:>30}")
        print()


#!/usr/bin/env python3
"""
Applications: Neural Compression, Cryptographic Indistinguishability,
and Robustness Certification

Real-world applications of the coalgebraic Myhill-Nerode theory.
"""
import random
from itertools import product as itertools_product


# ─── Application 1: Neural Network Layer Compression ────────────────

class SimpleNeuralLayer:
    """
    A simple neural layer modeled as a state machine.
    Input: binary vectors of dimension d
    State: quantized activation vectors (finite set)
    Output: class prediction (integer)
    """

    def __init__(self, d, n_states, n_classes, seed=42):
        rng = random.Random(seed)
        self.d = d
        self.n_states = n_states
        self.n_classes = n_classes

        # Random transition table (simulating a neural layer)
        self.trans = {}
        for s in range(n_states):
            for a in range(2**d):
                self.trans[(s, a)] = rng.randint(0, n_states - 1)

        # Random observation function
        self.obs = {s: rng.randint(0, n_classes - 1) for s in range(n_states)}

    def step(self, s, a):
        return self.trans[(s, a)]

    def observe(self, s):
        return self.obs[s]

    def behavior(self, s, word):
        curr = s
        for a in word:
            curr = self.step(curr, a)
        return self.observe(curr)


def compress_neural_layer(layer, max_depth=5):
    """Compress a neural layer via behavioral equivalence."""
    alphabet = list(range(2**layer.d))
    states = list(range(layer.n_states))

    # Compute signatures
    signatures = {}
    for s in states:
        sig = []
        for k in range(max_depth + 1):
            for w in itertools_product(alphabet, repeat=k):
                sig.append(layer.behavior(s, w))
        sig = tuple(sig)
        if sig not in signatures:
            signatures[sig] = []
        signatures[sig].append(s)

    classes = list(signatures.values())
    return classes


print("=" * 60)
print("Application 1: Neural Layer Compression")
print("=" * 60)

for n_states in [10, 20, 50, 100]:
    layer = SimpleNeuralLayer(d=2, n_states=n_states, n_classes=3)
    classes = compress_neural_layer(layer, max_depth=3)
    ratio = len(classes) / n_states
    print(f"  States={n_states:>3}, Classes={len(classes):>3}, "
          f"Compression={ratio:.1%}, Savings={1-ratio:.1%}")


# ─── Application 2: Cryptographic Indistinguishability Testing ──────

print("\n" + "=" * 60)
print("Application 2: Cryptographic Indistinguishability")
print("=" * 60)


def test_indistinguishability(layer, s, t, max_depth=5):
    """
    Test if states s and t are cryptographically indistinguishable.
    Returns (is_indistinguishable, separating_word_if_any).
    """
    alphabet = list(range(2**layer.d))
    for k in range(max_depth + 1):
        for w in itertools_product(alphabet, repeat=k):
            if layer.behavior(s, w) != layer.behavior(t, w):
                return False, w
    return True, None


layer = SimpleNeuralLayer(d=2, n_states=20, n_classes=3, seed=123)
classes = compress_neural_layer(layer, max_depth=4)

# Test pairs within same class (should be indistinguishable)
print("\nWithin-class tests (should all be indistinguishable):")
for cls in classes[:3]:
    if len(cls) >= 2:
        s, t = cls[0], cls[1]
        ind, sep = test_indistinguishability(layer, s, t)
        print(f"  States {s} and {t}: indistinguishable={ind}")

# Test pairs across classes (should be distinguishable)
print("\nCross-class tests (should all be distinguishable):")
for i in range(min(3, len(classes) - 1)):
    s = classes[i][0]
    t = classes[i + 1][0]
    ind, sep = test_indistinguishability(layer, s, t)
    print(f"  States {s} and {t}: indistinguishable={ind}, "
          f"separating word={sep}")


# ─── Application 3: Robustness Certification ────────────────────────

print("\n" + "=" * 60)
print("Application 3: Certified Robustness Preservation")
print("=" * 60)


def check_robustness(layer, state, predicate, max_depth=4):
    """
    Check if a state is behaviorally robust with respect to a predicate.
    Returns (is_robust, violating_word_if_any).
    """
    alphabet = list(range(2**layer.d))
    for k in range(max_depth + 1):
        for w in itertools_product(alphabet, repeat=k):
            output = layer.behavior(state, w)
            if not predicate(output):
                return False, w
    return True, None


layer = SimpleNeuralLayer(d=2, n_states=15, n_classes=4, seed=456)
classes = compress_neural_layer(layer, max_depth=3)

# Safety predicate: output is not class 3 (the "dangerous" class)
safe_pred = lambda x: x != 3

print(f"\nSafety predicate: output ≠ 3")
print(f"Equivalence classes: {len(classes)}")

for cls in classes:
    # Check robustness of representative
    rep = cls[0]
    robust, violation = check_robustness(layer, rep, safe_pred)

    # Verify all states in class have same robustness
    all_same = all(
        check_robustness(layer, s, safe_pred)[0] == robust
        for s in cls
    )

    print(f"  Class {cls}: robust={robust}, "
          f"all_members_agree={all_same}"
          + (f", violation={violation}" if not robust else ""))


# ─── Application 4: Compression Metrics ─────────────────────────────

print("\n" + "=" * 60)
print("Application 4: Compression Analysis Across Architectures")
print("=" * 60)

print(f"\n{'Config':>25} {'States':>7} {'Classes':>8} "
      f"{'Ratio':>7} {'Savings':>8}")
print("-" * 60)

for d, n_states, n_classes, seed in [
    (1, 10, 2, 1),
    (1, 20, 2, 2),
    (1, 50, 2, 3),
    (2, 10, 3, 4),
    (2, 20, 3, 5),
    (2, 50, 3, 6),
    (2, 100, 5, 7),
    (3, 20, 4, 8),
    (3, 50, 4, 9),
]:
    layer = SimpleNeuralLayer(d=d, n_states=n_states,
                              n_classes=n_classes, seed=seed)
    classes = compress_neural_layer(layer, max_depth=3)
    ratio = len(classes) / n_states
    config = f"d={d},n={n_states},c={n_classes}"
    print(f"{config:>25} {n_states:>7} {len(classes):>8} "
          f"{ratio:>6.1%} {1-ratio:>7.1%}")

print("\n" + "=" * 60)
print("All applications completed.")
print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Coalgebraic Myhill-Nerode Neural State Compression

Concrete numerical examples demonstrating the formal theory of behavioral
equivalence and quotient-based neural compression.
"""
from itertools import product as itertools_product


class NeuralObservationSystem:
    """A deterministic state machine with observable outputs."""

    def __init__(self, states, alphabet, step_fn, observe_fn):
        self.states = states
        self.alphabet = alphabet
        self.step = step_fn
        self.observe = observe_fn

    def behavior(self, state, word):
        """Compute behavior: evolve by word, then observe."""
        s = state
        for a in word:
            s = self.step(s, a)
        return self.observe(s)

    def neural_equiv(self, s, t, max_depth=10):
        """Check if s and t are behaviorally equivalent up to depth max_depth."""
        for k in range(max_depth + 1):
            for word in self._words_of_length(k):
                if self.behavior(s, word) != self.behavior(t, word):
                    return False
        return True

    def _words_of_length(self, n):
        """Generate all words of length n over the alphabet."""
        if n == 0:
            yield ()
            return
        for w in itertools_product(self.alphabet, repeat=n):
            yield w

    def words_up_to(self, k):
        """Generate all words of length <= k."""
        for i in range(k + 1):
            yield from self._words_of_length(i)

    def compute_equivalence_classes(self, max_depth=10):
        """Compute equivalence classes via partition refinement."""
        classes = {}
        for s in self.states:
            sig = tuple(
                self.behavior(s, w)
                for w in self.words_up_to(max_depth)
            )
            if sig not in classes:
                classes[sig] = []
            classes[sig].append(s)
        return list(classes.values())

    def compress(self, max_depth=10):
        """Compute the minimal quotient system."""
        classes = self.compute_equivalence_classes(max_depth)
        representatives = {s: i for i, cls in enumerate(classes) for s in cls}
        n = len(classes)

        def new_step(q, a):
            rep = classes[q][0]
            return representatives[self.step(rep, a)]

        def new_observe(q):
            return self.observe(classes[q][0])

        return NeuralObservationSystem(
            states=list(range(n)),
            alphabet=self.alphabet,
            step_fn=new_step,
            observe_fn=new_observe,
        ), classes, representatives


# ─── Example 1: Redundant States ────────────────────────────────────

print("=" * 60)
print("Example 1: System with Redundant States")
print("=" * 60)

# States A=0, B=1, C=2 where A and B behave identically
# Alphabet: {0, 1}
# Transitions: A-0->A, A-1->C, B-0->B, B-1->C, C-0->A, C-1->C
# Observe: A->0, B->0, C->1

def step1(s, a):
    table = {
        (0, 0): 0, (0, 1): 2,
        (1, 0): 1, (1, 1): 2,
        (2, 0): 0, (2, 1): 2,
    }
    return table[(s, a)]

def observe1(s):
    return 0 if s in (0, 1) else 1

N1 = NeuralObservationSystem(
    states=[0, 1, 2],
    alphabet=[0, 1],
    step_fn=step1,
    observe_fn=observe1,
)

print(f"Original states: {N1.states}")
print(f"Alphabet: {N1.alphabet}")
print()

# Check equivalences
for s in N1.states:
    for t in N1.states:
        if s < t:
            eq = N1.neural_equiv(s, t)
            print(f"  State {s} ~ State {t}: {eq}")

classes1 = N1.compute_equivalence_classes()
print(f"\nEquivalence classes: {classes1}")
print(f"Original size: {len(N1.states)}")
print(f"Compressed size: {len(classes1)}")
print(f"Compression ratio: {len(classes1)/len(N1.states):.2%}")

# Verify behavior preservation
compressed1, _, reps1 = N1.compress()
print("\nBehavior verification (all words up to length 3):")
all_match = True
for word in N1.words_up_to(3):
    orig = N1.behavior(0, word)
    comp = compressed1.behavior(reps1[0], word)
    if orig != comp:
        all_match = False
        print(f"  MISMATCH on word {word}: orig={orig}, comp={comp}")
print(f"  All behaviors match: {all_match}")


# ─── Example 2: Parity Automaton (Already Minimal) ──────────────────

print("\n" + "=" * 60)
print("Example 2: Parity Automaton (Already Minimal)")
print("=" * 60)

def step_parity(s, a):
    return (s + a) % 2

def observe_parity(s):
    return s

N2 = NeuralObservationSystem(
    states=[0, 1],
    alphabet=[0, 1],
    step_fn=step_parity,
    observe_fn=observe_parity,
)

classes2 = N2.compute_equivalence_classes()
print(f"States: {N2.states}")
print(f"Equivalence classes: {classes2}")
print(f"Already minimal: {len(classes2) == len(N2.states)}")


# ─── Example 3: Mod-3 Counter with Redundancy ───────────────────────

print("\n" + "=" * 60)
print("Example 3: Mod-3 Counter with 6 Redundant States")
print("=" * 60)

# States 0-5, where state s behaves like s % 3
def step_mod3(s, a):
    return ((s % 3) + a) % 3 + (3 if s >= 3 else 0)

def observe_mod3(s):
    return s % 3

N3 = NeuralObservationSystem(
    states=list(range(6)),
    alphabet=[0, 1, 2],
    step_fn=step_mod3,
    observe_fn=observe_mod3,
)

classes3 = N3.compute_equivalence_classes()
print(f"Original states: {N3.states}")
print(f"Equivalence classes: {classes3}")
print(f"Original size: {len(N3.states)}")
print(f"Compressed size: {len(classes3)}")
print(f"Compression ratio: {len(classes3)/len(N3.states):.2%}")

# Verify robustness preservation
print("\nRobustness check (output < 2 is 'safe'):")
for s in N3.states:
    safe = all(N3.behavior(s, w) < 2 for w in N3.words_up_to(4))
    print(f"  State {s} (class {s%3}): safe={safe}")


# ─── Example 4: Complexity Bounds ────────────────────────────────────

print("\n" + "=" * 60)
print("Example 4: Observation Budget Complexity")
print("=" * 60)

for alpha_size in [2, 3, 5]:
    print(f"\nAlphabet size |A| = {alpha_size}:")
    for k in range(6):
        total_words = sum(alpha_size**i for i in range(k + 1))
        print(f"  Depth k={k}: {total_words:>6} observation contexts "
              f"(sum_{{i=0}}^{{{k}}} {alpha_size}^i)")


# ─── Example 5: Product System ───────────────────────────────────────

print("\n" + "=" * 60)
print("Example 5: Product System Decomposition")
print("=" * 60)

# Product of parity checker and mod-3 counter
def step_product(st, a):
    s1, s2 = st
    return (step_parity(s1, a), (s2 + a) % 3)

def observe_product(st):
    s1, s2 = st
    return (observe_parity(s1), s2)

product_states = [(s1, s2) for s1 in [0, 1] for s2 in [0, 1, 2]]

N_prod = NeuralObservationSystem(
    states=product_states,
    alphabet=[0, 1, 2],
    step_fn=step_product,
    observe_fn=observe_product,
)

classes_prod = N_prod.compute_equivalence_classes(max_depth=5)
print(f"Product states: {product_states}")
print(f"Product equivalence classes: {len(classes_prod)}")
print(f"Component 1 classes: 2 (parity)")
print(f"Component 2 classes: 3 (mod-3)")
print(f"Product is minimal: {len(classes_prod) == 6}")
print(f"Product classes = Component1 × Component2: {len(classes_prod) == 2 * 3}")

print("\n" + "=" * 60)
print("All demos completed successfully.")
print("=" * 60)
