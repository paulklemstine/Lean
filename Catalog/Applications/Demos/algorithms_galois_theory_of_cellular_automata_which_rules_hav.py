"""
Algorithms for Cellular Automata Reversibility Analysis

Type-hinted implementations of the core algorithms for analyzing
reversible cellular automata and computing reversibility groups.
"""

from typing import List, Tuple, Dict, Set, Callable
from itertools import product as cartesian_product
from functools import reduce


def wolfram_rule(rule_number: int) -> Callable[[Tuple[int, int, int]], int]:
    """Convert a Wolfram rule number (0-255) to a local rule function.

    Args:
        rule_number: Integer 0-255 encoding the elementary CA rule.

    Returns:
        A function mapping (left, center, right) -> new_center.
    """
    def local_rule(neighborhood: Tuple[int, int, int]) -> int:
        index = neighborhood[0] * 4 + neighborhood[1] * 2 + neighborhood[2]
        return (rule_number >> index) & 1
    return local_rule


def apply_ca_periodic(rule: Callable[[Tuple[int, int, int]], int],
                      config: List[int]) -> List[int]:
    """Apply an elementary CA rule to a periodic configuration.

    Args:
        rule: Local rule function (left, center, right) -> new_value.
        config: List of 0s and 1s representing the periodic configuration.

    Returns:
        New configuration after one step.
    """
    n = len(config)
    return [rule((config[(i - 1) % n], config[i], config[(i + 1) % n]))
            for i in range(n)]


def is_reversible_on_period(rule_number: int, period: int) -> bool:
    """Check if a CA rule is reversible (bijective) on configurations of given period.

    Args:
        rule_number: Wolfram rule number (0-255).
        period: Period of the configuration space.

    Returns:
        True if the global map is a bijection on {0,1}^period.
    """
    rule = wolfram_rule(rule_number)
    configs = list(cartesian_product([0, 1], repeat=period))
    images = set()
    for config in configs:
        image = tuple(apply_ca_periodic(rule, list(config)))
        if image in images:
            return False
        images.add(image)
    return len(images) == len(configs)


def find_reversible_rules(period: int, max_rule: int = 256) -> List[int]:
    """Find all reversible elementary CA rules for a given period.

    Args:
        period: Period of the configuration space.
        max_rule: Maximum rule number to check (default 256 for elementary CAs).

    Returns:
        List of rule numbers that are reversible on the given period.
    """
    return [r for r in range(max_rule) if is_reversible_on_period(r, period)]


def compute_permutation(rule_number: int, period: int) -> Dict[Tuple[int, ...], Tuple[int, ...]]:
    """Compute the permutation induced by a reversible CA rule.

    Args:
        rule_number: Wolfram rule number.
        period: Period of the configuration space.

    Returns:
        Dictionary mapping each configuration to its image.
    """
    rule = wolfram_rule(rule_number)
    configs = list(cartesian_product([0, 1], repeat=period))
    return {config: tuple(apply_ca_periodic(rule, list(config)))
            for config in configs}


def permutation_to_cycles(perm: Dict) -> List[List]:
    """Decompose a permutation into disjoint cycles.

    Args:
        perm: Dictionary mapping elements to their images.

    Returns:
        List of cycles, each cycle is a list of elements.
    """
    visited: Set = set()
    cycles: List[List] = []
    for start in perm:
        if start in visited:
            continue
        cycle = []
        current = start
        while current not in visited:
            visited.add(current)
            cycle.append(current)
            current = perm[current]
        if len(cycle) > 1:
            cycles.append(cycle)
    return cycles


def shift_permutation(period: int) -> Dict[Tuple[int, ...], Tuple[int, ...]]:
    """Compute the shift permutation on {0,1}^period.

    The shift sends configuration c to the configuration where c[i] -> c[(i+1) % n].

    Args:
        period: Period of the configuration space.

    Returns:
        Dictionary mapping each configuration to its shifted version.
    """
    configs = list(cartesian_product([0, 1], repeat=period))
    return {config: tuple(config[(i + 1) % period] for i in range(period))
            for config in configs}


def centralizer_size_from_cycle_type(cycle_type: Dict[int, int], total: int) -> int:
    """Compute the size of the centralizer of a permutation from its cycle type.

    For a permutation with cycle type (1^a1, 2^a2, ..., k^ak), the centralizer
    in S_n has order ∏_i (i^ai * ai!).

    Args:
        cycle_type: Dictionary mapping cycle length to multiplicity.
        total: Total number of elements (for fixed points).

    Returns:
        Order of the centralizer.
    """
    import math
    result = 1
    for length, count in cycle_type.items():
        result *= (length ** count) * math.factorial(count)
    return result


def compute_shift_cycle_type(period: int) -> Dict[int, int]:
    """Compute the cycle type of the shift on {0,1}^period.

    Args:
        period: Period of the configuration space.

    Returns:
        Dictionary mapping cycle length to multiplicity.
    """
    perm = shift_permutation(period)
    cycles = permutation_to_cycles(perm)
    cycle_type: Dict[int, int] = {}

    # Count fixed points
    fixed = sum(1 for k, v in perm.items() if k == v)
    if fixed > 0:
        cycle_type[1] = fixed

    for cycle in cycles:
        length = len(cycle)
        cycle_type[length] = cycle_type.get(length, 0) + 1

    return cycle_type


def compose_permutations(perm1: Dict, perm2: Dict) -> Dict:
    """Compose two permutations: (perm1 ∘ perm2)(x) = perm1(perm2(x)).

    Args:
        perm1: First permutation (applied second).
        perm2: Second permutation (applied first).

    Returns:
        Composed permutation.
    """
    return {k: perm1[v] for k, v in perm2.items()}


def generate_group(generators: List[Dict], elements: List) -> List[Dict]:
    """Generate a group from a set of permutation generators using BFS.

    Args:
        generators: List of permutations (as dictionaries).
        elements: List of all elements being permuted.

    Returns:
        List of all group elements (permutations).
    """
    identity = {e: e for e in elements}
    group = {tuple(sorted(identity.items())): identity}
    queue = list(generators)

    for gen in generators:
        key = tuple(sorted(gen.items()))
        if key not in group:
            group[key] = gen

    changed = True
    while changed:
        changed = False
        current = list(group.values())
        for g in current:
            for gen in generators:
                product = compose_permutations(g, gen)
                key = tuple(sorted(product.items()))
                if key not in group:
                    group[key] = product
                    changed = True
                product2 = compose_permutations(gen, g)
                key2 = tuple(sorted(product2.items()))
                if key2 not in group:
                    group[key2] = product2
                    changed = True

    return list(group.values())


if __name__ == "__main__":
    # Example usage
    print("=== Reversible Elementary CA Rules ===")
    for period in [3, 4, 5, 6, 7]:
        rev_rules = find_reversible_rules(period)
        print(f"Period {period}: {len(rev_rules)} reversible rules: {rev_rules}")

    print("\n=== Shift Cycle Types ===")
    for period in [3, 4, 5, 6]:
        ct = compute_shift_cycle_type(period)
        total = 2 ** period
        csize = centralizer_size_from_cycle_type(ct, total)
        print(f"Period {period}: cycle type = {ct}, "
              f"centralizer size = {csize}, "
              f"fraction of S_{total} = {csize}/{total}! ≈ {csize/reduce(lambda a,b: a*b, range(1,total+1)):.2e}")
