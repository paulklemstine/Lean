#!/usr/bin/env python3
"""
Algorithms for Equivariant Impossibility Detection
====================================================

Implements algorithms for:
1. Enumerating equivariant maps between finite G-sets
2. Detecting impossible equivariant tasks
3. Computing orbit decompositions and stabilizers
4. Testing the stabilizer criterion for task solvability

Complexity analysis:
- Equivariant map enumeration: O(|Y|^|orbits| · |G| · |X|) with orbit reduction
- Impossibility detection: Same as enumeration (exhaustive search)
- Orbit computation: O(|G| · |X|) via BFS
- Stabilizer computation: O(|G|) per point

Type hints and docstrings included throughout.
"""

from itertools import product
from typing import (Any, Callable, Dict, FrozenSet, List, Optional,
                    Set, Tuple)


# ============================================================
# Core data structures
# ============================================================

class GroupAction:
    """
    A finite group G acting on a finite set X.

    The group is represented by its elements, multiplication, identity,
    and inverse operations. The action is a function act: G × X → X
    satisfying act(e, x) = x and act(g, act(h, x)) = act(g*h, x).
    """

    def __init__(self, elements: List[Any], set_elements: List[Any],
                 action: Callable[[Any, Any], Any],
                 multiply: Callable[[Any, Any], Any],
                 identity: Any,
                 inverse: Callable[[Any], Any]):
        self.G: List[Any] = elements
        self.X: List[Any] = set_elements
        self.act = action
        self.mul = multiply
        self.e = identity
        self.inv = inverse

    def orbit(self, x: Any) -> FrozenSet[Any]:
        """Compute the orbit of x under the group action. O(|G|)."""
        return frozenset(self.act(g, x) for g in self.G)

    def orbits(self) -> List[FrozenSet[Any]]:
        """Compute all orbits. O(|G| · |X|)."""
        visited: Set[Any] = set()
        result = []
        for x in self.X:
            if x not in visited:
                orb = self.orbit(x)
                result.append(orb)
                visited |= orb
        return result

    def stabilizer(self, x: Any) -> List[Any]:
        """Compute Stab(x) = {g ∈ G : g·x = x}. O(|G|)."""
        return [g for g in self.G if self.act(g, x) == x]

    def is_free(self) -> bool:
        """Check if the action is free. O(|G| · |X|)."""
        for g in self.G:
            if g == self.e:
                continue
            for x in self.X:
                if self.act(g, x) == x:
                    return False
        return True

    def is_transitive(self) -> bool:
        """Check if the action is transitive. O(|G|)."""
        if not self.X:
            return True
        return len(self.orbit(self.X[0])) == len(self.X)

    def fixed_points(self) -> FrozenSet[Any]:
        """Compute Fix(G) = {x ∈ X : g·x = x ∀g}. O(|G| · |X|)."""
        return frozenset(
            x for x in self.X
            if all(self.act(g, x) == x for g in self.G)
        )

    def orbit_representatives(self) -> List[Any]:
        """Choose one representative per orbit. O(|G| · |X|)."""
        visited: Set[Any] = set()
        reps = []
        for x in self.X:
            if x not in visited:
                reps.append(x)
                visited |= self.orbit(x)
        return reps


# ============================================================
# Algorithm 1: Enumerate equivariant maps
# ============================================================

def enumerate_equivariant_maps(
    source: GroupAction, target: GroupAction,
    admissible: Optional[Callable[[Any], Set[Any]]] = None
) -> List[Dict[Any, Any]]:
    """
    Enumerate all equivariant maps f: X → Y satisfying:
      1. f(g·x) = g·f(x)  for all g ∈ G, x ∈ X
      2. f(x) ∈ admissible(x)  for all x ∈ X (if provided)

    Algorithm (orbit reduction):
      - Decompose X into orbits
      - For each orbit, choose a representative x₀
      - Try all admissible values y₀ for f(x₀)
      - Extend f equivariantly: f(g·x₀) = g·y₀
      - Verify consistency (well-definedness for stabilizer elements)

    Complexity: O(|Y|^k · |G| · |X|) where k = number of orbits.
    This is exponentially better than brute-force O(|Y|^|X|) when
    orbits are large.

    Args:
        source: Group action on the domain X
        target: Group action on the codomain Y
        admissible: Optional function x ↦ {admissible outputs at x}

    Returns:
        List of equivariant maps as dictionaries x → f(x)
    """
    if admissible is None:
        admissible = lambda x: set(target.X)

    # Compute orbit representatives
    reps = source.orbit_representatives()

    # For each representative, compute which y values are admissible
    # AND consistent with the stabilizer
    def admissible_at_rep(x0: Any) -> List[Any]:
        """Values y₀ that can serve as f(x₀)."""
        stab = source.stabilizer(x0)
        candidates = []
        for y0 in admissible(x0):
            # Check stabilizer consistency: for h ∈ Stab(x₀),
            # we need h·y₀ = y₀ (since f(h·x₀) = f(x₀) = y₀
            # and f(h·x₀) = h·f(x₀) = h·y₀)
            if all(target.act(h, y0) == y0 for h in stab):
                candidates.append(y0)
        return candidates

    # Build candidate sets per orbit
    orbit_candidates = [admissible_at_rep(r) for r in reps]

    # Enumerate all combinations
    solutions = []
    for combo in product(*orbit_candidates):
        f: Dict[Any, Any] = {}
        valid = True

        for x0, y0 in zip(reps, combo):
            # Extend equivariantly over the orbit of x0
            for g in source.G:
                gx = source.act(g, x0)
                gy = target.act(g, y0)

                if gx in f:
                    # Consistency check
                    if f[gx] != gy:
                        valid = False
                        break
                else:
                    f[gx] = gy

                    # Check admissibility
                    if f[gx] not in admissible(gx):
                        valid = False
                        break

            if not valid:
                break

        if valid and len(f) == len(source.X):
            solutions.append(f)

    return solutions


# ============================================================
# Algorithm 2: Detect impossible tasks
# ============================================================

def is_task_impossible(
    source: GroupAction, target: GroupAction,
    admissible: Callable[[Any], Set[Any]]
) -> Tuple[bool, Optional[str]]:
    """
    Determine whether an equivariant task is impossible.

    Returns (is_impossible, reason) where reason explains why.

    Algorithm:
      1. Check if any orbit representative has empty admissible set → immediate impossibility
      2. Check stabilizer compatibility for each representative
      3. If pre-checks pass, do full enumeration

    Complexity: O(|Y|^k · |G| · |X|) worst case, but early termination
    often much faster.
    """
    # Quick check: empty admissible set
    for x in source.X:
        if not admissible(x):
            return True, f"Empty admissible set at {x}"

    # Stabilizer check: for each orbit rep x₀, need ∃ y₀ ∈ adm(x₀)
    # with Stab(x₀) ⊆ Stab(y₀)
    reps = source.orbit_representatives()
    for x0 in reps:
        stab_x0 = source.stabilizer(x0)
        has_compatible = False
        for y0 in admissible(x0):
            if all(target.act(h, y0) == y0 for h in stab_x0):
                has_compatible = True
                break
        if not has_compatible:
            return True, (f"No stabilizer-compatible output at orbit rep {x0} "
                         f"(stabilizer has {len(stab_x0)} elements)")

    # Full enumeration
    solutions = enumerate_equivariant_maps(source, target, admissible)
    if not solutions:
        return True, "No equivariant map exists (exhaustive search)"
    return False, None


# ============================================================
# Algorithm 3: Impossibility witness search
# ============================================================

def find_impossible_tasks(
    action: GroupAction,
    max_admissible_size: Optional[int] = None
) -> List[Tuple[Callable, str]]:
    """
    Search for impossible equivariant tasks on a given G-set.

    Tries several canonical task types:
    1. Fixed-point task (outputs must be fixed points)
    2. Constant task (all outputs must equal)
    3. Singleton-orbit tasks (output in specific orbit)

    Returns list of (admissible_func, description) for impossible tasks.
    """
    impossible = []

    # Task 1: Fixed-point task
    fp = action.fixed_points()
    if action.X and not fp:
        impossible.append(
            (lambda x: set(), "Fixed-point task (no fixed points exist)")
        )

    # Task 2: Constant tasks (try each possible constant value)
    for c in action.X:
        adm = lambda x, c=c: {c}
        is_imp, reason = is_task_impossible(action, action, adm)
        if is_imp:
            impossible.append(
                (adm, f"Constant-value task (must output {c})")
            )

    return impossible


# ============================================================
# Algorithm 4: Classify tasks on cyclic groups
# ============================================================

def classify_cyclic_group_tasks(n: int) -> Dict[str, Any]:
    """
    Complete classification of equivariant self-tasks on C_n acting on Z/nZ.

    For C_n acting freely and transitively on itself:
    - Every equivariant self-map is a group translation x ↦ x + k (mod n)
    - There are exactly n equivariant self-maps
    - All are injective (bijective, in fact)
    - None are constant when n > 1

    Returns classification data.
    """
    G = list(range(n))
    X = list(range(n))
    action = GroupAction(
        elements=G, set_elements=X,
        action=lambda g, x: (g + x) % n,
        multiply=lambda g, h: (g + h) % n,
        identity=0,
        inverse=lambda g: (-g) % n
    )

    # Find all equivariant self-maps
    all_adm = lambda x: set(X)
    equi_maps = enumerate_equivariant_maps(action, action, all_adm)

    # Classify each map
    classifications = []
    for f in equi_maps:
        shift = f[0]  # f(0) determines the translation
        is_id = all(f[x] == x for x in X)
        is_const = len(set(f.values())) == 1
        is_inj = len(set(f.values())) == len(X)
        classifications.append({
            'map': f,
            'shift': shift,
            'is_identity': is_id,
            'is_constant': is_const,
            'is_injective': is_inj,
        })

    return {
        'n': n,
        'num_equivariant_maps': len(equi_maps),
        'all_injective': all(c['is_injective'] for c in classifications),
        'any_constant': any(c['is_constant'] for c in classifications),
        'is_free': action.is_free(),
        'is_transitive': action.is_transitive(),
        'maps': classifications,
        'impossible_tasks': find_impossible_tasks(action),
    }


# ============================================================
# Example usage
# ============================================================

def main():
    """Demonstrate the algorithms."""
    print("=" * 60)
    print("  Equivariant Impossibility — Algorithm Demonstrations")
    print("=" * 60)

    # Classify cyclic groups
    for n in [2, 3, 4, 5, 6]:
        result = classify_cyclic_group_tasks(n)
        print(f"\n--- C_{n} on Z/{n}Z ---")
        print(f"  Free: {result['is_free']}, Transitive: {result['is_transitive']}")
        print(f"  Equivariant self-maps: {result['num_equivariant_maps']}")
        print(f"  All injective: {result['all_injective']}")
        print(f"  Any constant: {result['any_constant']}")
        print(f"  Impossible tasks found: {len(result['impossible_tasks'])}")
        for _, desc in result['impossible_tasks']:
            print(f"    → {desc}")

    # Orbit-reduction speedup demonstration
    print("\n--- Orbit Reduction Speedup ---")
    for n in [3, 4, 5]:
        from itertools import permutations
        perms = [tuple(p) for p in permutations(range(n))]
        action = GroupAction(
            elements=perms, set_elements=list(range(n)),
            action=lambda g, x: g[x],
            multiply=lambda g, h: tuple(g[h[i]] for i in range(len(g))),
            identity=tuple(range(n)),
            inverse=lambda g: tuple(
                {v: k for k, v in enumerate(g)}[i] for i in range(len(g)))
        )
        orbits = action.orbits()
        print(f"  S_{n}: |G|={len(perms)}, |X|={n}, orbits={len(orbits)}")
        print(f"    Brute force: {n}^{n} = {n**n} candidates")
        print(f"    Orbit reduction: {n}^{len(orbits)} = {n**len(orbits)} candidates")
        equi = enumerate_equivariant_maps(action, action)
        print(f"    Actual equivariant self-maps: {len(equi)}")


if __name__ == "__main__":
    main()
