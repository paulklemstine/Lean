"""
Argumentation Framework Algorithms
===================================

Type-hinted implementations of the core algorithms from the
formalization of argumentation topology.
"""

from typing import Set, Dict, List, Tuple, Optional, FrozenSet
from itertools import combinations


class ArgFramework:
    """An argumentation framework AF = (A, R)."""

    def __init__(self, args: Set[str], attacks: Set[Tuple[str, str]]):
        self.args = args
        self.attacks = attacks
        self._attack_dict: Dict[str, Set[str]] = {a: set() for a in args}
        self._attacked_by: Dict[str, Set[str]] = {a: set() for a in args}
        for a, b in attacks:
            self._attack_dict[a].add(b)
            self._attacked_by[b].add(a)

    def is_conflict_free(self, S: FrozenSet[str]) -> bool:
        """Check if S is conflict-free (no internal attacks)."""
        for a in S:
            for b in S:
                if (a, b) in self.attacks:
                    return False
        return True

    def defends(self, S: FrozenSet[str], a: str) -> bool:
        """Check if S defends argument a."""
        for b in self._attacked_by.get(a, set()):
            if not any((c, b) in self.attacks for c in S):
                return False
        return True

    def is_admissible(self, S: FrozenSet[str]) -> bool:
        """Check if S is admissible (conflict-free + self-defending)."""
        if not self.is_conflict_free(S):
            return False
        return all(self.defends(S, a) for a in S)

    def defense_op(self, S: FrozenSet[str]) -> FrozenSet[str]:
        """The defense operator F(S) = {a | S defends a}."""
        return frozenset(a for a in self.args if self.defends(S, a))

    def grounded_extension(self) -> FrozenSet[str]:
        """Compute the grounded extension via iterated defense operator."""
        current: FrozenSet[str] = frozenset()
        while True:
            next_set = self.defense_op(current)
            if next_set == current:
                return current
            current = next_set

    def defense_chain(self, max_steps: Optional[int] = None) -> List[FrozenSet[str]]:
        """Compute the full defense chain until stabilization."""
        if max_steps is None:
            max_steps = len(self.args) + 1
        chain: List[FrozenSet[str]] = []
        current: FrozenSet[str] = frozenset()
        for _ in range(max_steps):
            current = self.defense_op(current)
            chain.append(current)
            if len(chain) >= 2 and chain[-1] == chain[-2]:
                break
        return chain

    def defense_depth(self, a: str) -> int:
        """Compute the defense depth of argument a.
        Returns -1 if a is not in the grounded extension."""
        chain = self.defense_chain()
        for i, layer in enumerate(chain):
            if a in layer:
                return i
        return -1

    def all_conflict_free_sets(self) -> List[FrozenSet[str]]:
        """Enumerate all conflict-free sets (the argumentation complex)."""
        result: List[FrozenSet[str]] = [frozenset()]
        args_list = sorted(self.args)
        for k in range(1, len(args_list) + 1):
            for combo in combinations(args_list, k):
                s = frozenset(combo)
                if self.is_conflict_free(s):
                    result.append(s)
        return result

    def preferred_extensions(self) -> List[FrozenSet[str]]:
        """Compute all preferred extensions (maximal admissible sets)."""
        admissible: List[FrozenSet[str]] = []
        args_list = sorted(self.args)
        for k in range(len(args_list), -1, -1):
            for combo in combinations(args_list, k):
                s = frozenset(combo)
                if self.is_admissible(s):
                    admissible.append(s)
        # Filter to maximal
        preferred: List[FrozenSet[str]] = []
        for s in admissible:
            if not any(s < t for t in admissible):
                if s not in preferred:
                    preferred.append(s)
        return preferred

    def stable_extensions(self) -> List[FrozenSet[str]]:
        """Compute all stable extensions."""
        result: List[FrozenSet[str]] = []
        args_list = sorted(self.args)
        for k in range(len(args_list), -1, -1):
            for combo in combinations(args_list, k):
                s = frozenset(combo)
                if not self.is_conflict_free(s):
                    continue
                # Check every outsider is attacked
                outside = self.args - s
                if all(any((c, a) in self.attacks for c in s) for a in outside):
                    result.append(s)
        return result

    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic of the conflict-free complex.
        χ = Σ (-1)^k · f_k where f_k = # faces of dimension k."""
        cf_sets = self.all_conflict_free_sets()
        chi = 0
        for s in cf_sets:
            if len(s) > 0:  # Exclude empty set for unreduced
                chi += (-1) ** (len(s) - 1)
        return chi

    def verify_euler_conjecture(self) -> Tuple[bool, Dict]:
        """Test the Euler characteristic conjecture:
        χ(K(AF)) = |preferred| - |grounded|."""
        chi = self.euler_characteristic()
        n_pref = len(self.preferred_extensions())
        g_size = len(self.grounded_extension())
        conjectured = n_pref - g_size
        return chi == conjectured, {
            'euler_char': chi,
            'n_preferred': n_pref,
            'grounded_size': g_size,
            'conjectured': conjectured,
            'match': chi == conjectured,
        }


def generate_random_af(n: int, p: float, seed: int = 42) -> ArgFramework:
    """Generate a random argumentation framework with n arguments and
    attack probability p."""
    import random
    random.seed(seed)
    args = {f"a{i}" for i in range(n)}
    attacks: Set[Tuple[str, str]] = set()
    for a in sorted(args):
        for b in sorted(args):
            if a != b and random.random() < p:
                attacks.add((a, b))
    return ArgFramework(args, attacks)
