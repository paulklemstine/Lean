
from itertools import combinations
from typing import FrozenSet, List, Tuple, Callable, Set

Subset = FrozenSet[int]
ClosureOp = Callable[[Subset], Subset]

def make_closure_from_rules(universe: set, rules: List[Tuple[set, int]]) -> ClosureOp:
    def closure(s: Subset) -> Subset:
        current = set(s)
        changed = True
        while changed:
            changed = False
            for premises, conclusion in rules:
                if premises <= current and conclusion not in current:
                    current.add(conclusion)
                    changed = True
        return frozenset(current)
    return closure

def find_closed_theories(C: ClosureOp, universe: set) -> List[Subset]:
    closed = []
    for r in range(len(universe) + 1):
        for combo in combinations(universe, r):
            s = frozenset(combo)
            if C(s) == s:
                closed.append(s)
    return sorted(closed, key=lambda s: (len(s), sorted(s)))

def is_prime_closed(T: Subset, C: ClosureOp, closed_theories: List[Subset]) -> bool:
    if C(T) != T:
        return False
    for A in closed_theories:
        for B in closed_theories:
            if (A & B) <= T and not (A <= T or B <= T):
                return False
    return True

def reconstruct_closure(primes: List[Subset], universe: set) -> ClosureOp:
    def closure(gamma: Subset) -> Subset:
        containing = [P for P in primes if gamma <= P]
        if not containing:
            return frozenset(universe)
        return frozenset.intersection(*containing)
    return closure

# Example
universe = {0, 1, 2}
C = make_closure_from_rules(universe, [])  # identity closure
closed = find_closed_theories(C, universe)
primes = [T for T in closed if is_prime_closed(T, C, closed)]
print(f"Closed theories: {[sorted(t) for t in closed]}")
print(f"Prime theories: {[sorted(p) for p in primes]}")

# Verify reconstruction
C_recon = reconstruct_closure(primes, universe)
for r in range(len(universe)+1):
    for combo in combinations(universe, r):
        s = frozenset(combo)
        assert C(s) == C_recon(s), f"Mismatch at {sorted(s)}"
print("Reconstruction verified!")
