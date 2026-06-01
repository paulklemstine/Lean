"""
Algorithms for Strange Loops and Self-Referential Systems

Type-hinted implementations of the key algorithms from the formalization.
"""

from typing import Callable, Optional, TypeVar, Generic, List, Tuple, Set, Dict
from dataclasses import dataclass
from enum import Enum

T = TypeVar('T')


class TruthValue(Enum):
    TRUE = "true"
    FALSE = "false"
    UNDECIDABLE = "undecidable"


@dataclass
class Sentence:
    """A sentence in a formal system, identified by index."""
    index: int
    name: str
    is_self_referential: bool = False
    depth: int = 0


@dataclass
class FormalSystem:
    """A formal system with sentences, provability, and truth predicates."""
    sentences: List[Sentence]
    provable: Callable[[Sentence], bool]
    true_: Callable[[Sentence], bool]

    def is_sound(self) -> bool:
        """Check soundness: all provable sentences are true."""
        return all(
            self.true_(s) for s in self.sentences if self.provable(s)
        )


def lawvere_fixed_point(
    phi: Callable[[int], Callable[[int], bool]],
    domain: List[int],
    g: Callable[[bool], bool]
) -> Optional[Tuple[int, bool]]:
    """
    Lawvere's Fixed-Point Theorem (computational version).

    Given phi: A -> (A -> B) and g: B -> B, find b such that g(b) = b.
    Returns (witness_index, fixed_point_value) or None.

    Algorithm:
    1. Define d(a) = g(phi(a)(a))  -- the diagonal
    2. Search for a0 such that phi(a0) = d
    3. Then phi(a0)(a0) = g(phi(a0)(a0)) is the fixed point
    """
    # Compute the diagonal function
    diag = {a: g(phi(a)(a)) for a in domain}

    # Search for a0 where phi(a0) agrees with diag on all of domain
    for a0 in domain:
        if all(phi(a0)(a) == diag[a] for a in domain):
            fixed = phi(a0)(a0)
            return (a0, fixed)

    return None


def diagonal_argument(
    encoding: Callable[[int], Callable[[int], bool]],
    n: int
) -> Callable[[int], bool]:
    """
    Cantor's diagonal argument: construct a predicate not in the range
    of the encoding function.

    Given encoding: N -> (N -> Bool), construct P such that
    for all i in [0,n), encoding(i) != P.
    """
    return lambda x: not encoding(x)(x) if x < n else False


def construct_goedel_sentence(
    provability: Callable[[int], bool],
    diag: Callable[[Callable[[int], bool], int], bool]
) -> int:
    """
    Construct the Gödel sentence for a system.

    The Gödel sentence G satisfies: True(G) <-> not Provable(G)
    We use the diagonal lemma to find G such that
    G's truth value equals not-provable(G).
    """
    # The predicate "not provable"
    not_provable = lambda s: not provability(s)
    # Apply diagonal to get the self-referential sentence
    # Returns the index of the Gödel sentence
    return diag(not_provable, 0)


class ProvabilityAlgebra:
    """
    A provability algebra over a finite set of sentences.

    Models the closure operator on sets of sentence indices,
    representing logical consequence.
    """

    def __init__(self, n: int, rules: List[Tuple[Set[int], int]]):
        """
        Initialize with n sentences and derivation rules.
        Each rule (premises, conclusion) says: if all premises are in S,
        then conclusion is in closure(S).
        """
        self.n = n
        self.rules = rules

    def closure(self, s: Set[int]) -> Set[int]:
        """Compute the closure of a set of sentences under the rules."""
        result = set(s)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in self.rules:
                if premises.issubset(result) and conclusion not in result:
                    result.add(conclusion)
                    changed = True
        return result

    def is_fixed_point(self, s: Set[int]) -> bool:
        """Check if s is a fixed point (complete theory)."""
        return self.closure(s) == s

    def least_fixed_point(self) -> Set[int]:
        """Compute the least fixed point starting from empty set."""
        return self.closure(set())

    def find_diagonal_sentence(self) -> Optional[int]:
        """
        Try to find a diagonal sentence: one whose membership in any
        fixed point is equivalent to its non-membership.
        Returns None if no such sentence exists.
        """
        lfp = self.least_fixed_point()
        for i in range(self.n):
            # Check if i is in exactly those fixed points where it "shouldn't" be
            in_lfp = i in lfp
            # A true diagonal sentence would cause a contradiction
            if in_lfp:
                # Test: remove i and see if closure adds it back
                test = lfp - {i}
                if i not in self.closure(test):
                    return i  # i is not forced by other sentences
        return None


class StrangeLoopDetector:
    """
    Detects strange loops in formal systems.

    A strange loop exists when:
    1. Level N contains a statement about Level N-1
    2. Level N-1 contains a statement that, when decoded, refers to Level N
    3. This creates a self-referential cycle
    """

    def __init__(self, levels: int):
        self.levels = levels
        self.references: Dict[int, List[Tuple[int, str]]] = {
            i: [] for i in range(levels)
        }

    def add_reference(self, from_level: int, to_level: int, description: str):
        """Record that from_level references to_level."""
        self.references[from_level].append((to_level, description))

    def find_loops(self) -> List[List[int]]:
        """Find all strange loops (cycles in the reference graph)."""
        loops = []
        for start in range(self.levels):
            self._dfs(start, [start], set(), loops)
        return loops

    def _dfs(self, node: int, path: List[int], visited: Set[int],
             loops: List[List[int]]):
        visited.add(node)
        for next_node, _ in self.references[node]:
            if next_node == path[0] and len(path) > 1:
                loops.append(list(path))
            elif next_node not in visited:
                self._dfs(next_node, path + [next_node], visited, loops)
        visited.discard(node)

    def classify_loop(self, loop: List[int]) -> str:
        """Classify a loop by its properties."""
        if len(loop) == 1:
            return "direct_self_reference"
        elif len(loop) == 2:
            return "mutual_reference"
        else:
            return f"tangled_hierarchy_depth_{len(loop)}"


def iterate_diagonal(
    diag: Callable[[Callable[[int], bool]], int],
    true_pred: Callable[[int], bool],
    provable: Callable[[int], bool],
    depth: int
) -> List[int]:
    """
    Iterate the diagonal operator to produce a hierarchy of
    self-referential sentences at increasing depths.

    Returns list of sentence indices at each depth.
    """
    sentences = []
    for d in range(depth):
        if d == 0:
            # Base: Gödel sentence G0 = diag(not_provable)
            s = diag(lambda x: not provable(x))
        else:
            # Inductive: G_{n+1} = diag(lambda s: s == G_n and true(s))
            prev = sentences[-1]
            s = diag(lambda x, p=prev: x == p and true_pred(x))
        sentences.append(s)
    return sentences


def self_reference_depth(
    sentence_id: int,
    references: Dict[int, List[int]],
    max_depth: int = 100
) -> int:
    """
    Compute the self-reference depth of a sentence.

    Depth 0: no self-reference
    Depth n+1: refers to sentences of depth n
    """
    if sentence_id not in references or not references[sentence_id]:
        return 0

    visited = set()
    depth = 0
    current = {sentence_id}

    while current and depth < max_depth:
        next_level = set()
        for s in current:
            if s in visited:
                continue
            visited.add(s)
            if s in references:
                for ref in references[s]:
                    if ref == sentence_id:
                        return depth + 1  # Found self-reference
                    next_level.add(ref)
        current = next_level
        depth += 1

    return 0  # No self-reference found within max_depth


def incompleteness_certificate(
    system: FormalSystem,
    goedel_idx: int
) -> Dict[str, any]:
    """
    Generate an incompleteness certificate for a formal system.

    Returns a dictionary with:
    - goedel_sentence: the index of the Gödel sentence
    - is_true: whether the Gödel sentence is true
    - is_provable: whether it's provable
    - is_sound: whether the system is sound
    - is_complete: whether it's complete (if sound, should be False)
    """
    g = system.sentences[goedel_idx]
    return {
        "goedel_sentence": goedel_idx,
        "is_true": system.true_(g),
        "is_provable": system.provable(g),
        "is_sound": system.is_sound(),
        "is_complete": all(
            system.provable(s) for s in system.sentences if system.true_(s)
        ),
        "incompleteness_witness": (
            system.true_(g) and not system.provable(g)
        )
    }
