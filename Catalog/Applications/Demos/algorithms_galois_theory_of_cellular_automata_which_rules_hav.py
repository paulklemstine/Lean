#!/usr/bin/env python3
"""
Algorithms for Reversible Cellular Automata Analysis
=====================================================
Type-hinted implementations of core algorithms.
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
import itertools


# ---------------------------------------------------------------------------
# Core CA Types and Functions
# ---------------------------------------------------------------------------

Config = List[bool]
LocalRule = Callable[[bool, bool, bool], bool]


def wolfram_to_rule(rule_number: int) -> LocalRule:
    """Convert Wolfram rule number (0-255) to local rule function.

    The Wolfram encoding maps each 3-bit neighborhood (a,b,c) to a
    single output bit. The neighborhood index is 4a + 2b + c.

    Args:
        rule_number: Integer in [0, 255].

    Returns:
        A function (Bool, Bool, Bool) -> Bool implementing the rule.
    """
    def rule(a: bool, b: bool, c: bool) -> bool:
        index = (int(a) << 2) | (int(b) << 1) | int(c)
        return bool((rule_number >> index) & 1)
    return rule


def rule_to_wolfram(f: LocalRule) -> int:
    """Convert a local rule function to its Wolfram number.

    Args:
        f: A function (Bool, Bool, Bool) -> Bool.

    Returns:
        Integer in [0, 255] encoding the rule.
    """
    number = 0
    for a in [False, True]:
        for b in [False, True]:
            for c in [False, True]:
                index = (int(a) << 2) | (int(b) << 1) | int(c)
                if f(a, b, c):
                    number |= (1 << index)
    return number


def apply_global_map(f: LocalRule, config: Config) -> Config:
    """Apply a CA rule to a cyclic configuration.

    Each cell's new value is computed from (left, center, right) neighbors
    with cyclic boundary conditions.

    Args:
        f: Local rule function.
        config: Configuration as list of bools.

    Returns:
        New configuration after one time step.

    Time complexity: O(n) where n = len(config).
    """
    n = len(config)
    return [f(config[(i - 1) % n], config[i], config[(i + 1) % n])
            for i in range(n)]


# ---------------------------------------------------------------------------
# Reversibility Testing
# ---------------------------------------------------------------------------

def test_injectivity(rule_number: int, n: int) -> bool:
    """Test if a rule's global map is injective on size-n configurations.

    Enumerates all 2^n configurations and checks for collisions.

    Args:
        rule_number: Wolfram rule number.
        n: Configuration size (positive integer).

    Returns:
        True if the global map is injective on size-n configs.

    Time complexity: O(n · 2^n).
    """
    f = wolfram_to_rule(rule_number)
    seen: Set[Tuple[bool, ...]] = set()
    for bits in itertools.product([False, True], repeat=n):
        result = tuple(apply_global_map(f, list(bits)))
        if result in seen:
            return False
        seen.add(result)
    return True


def classify_reversibility(max_test_size: int = 8) -> Tuple[List[int], List[int]]:
    """Classify all 256 elementary CA rules as reversible or not.

    A rule is classified as reversible if its global map is injective
    for all tested configuration sizes.

    Args:
        max_test_size: Maximum configuration size to test.

    Returns:
        (reversible_rules, non_reversible_rules) as sorted lists.
    """
    reversible: List[int] = []
    non_reversible: List[int] = []
    for r in range(256):
        if all(test_injectivity(r, n) for n in range(1, max_test_size + 1)):
            reversible.append(r)
        else:
            non_reversible.append(r)
    return reversible, non_reversible


def find_collision(rule_number: int, max_n: int = 12
                   ) -> Optional[Tuple[int, Config, Config, Config]]:
    """Find two distinct configurations that map to the same output.

    Args:
        rule_number: Wolfram rule number.
        max_n: Maximum configuration size to search.

    Returns:
        (n, config1, config2, shared_output) if collision found, else None.
    """
    f = wolfram_to_rule(rule_number)
    for n in range(1, max_n + 1):
        seen: Dict[Tuple[bool, ...], Config] = {}
        for bits in itertools.product([False, True], repeat=n):
            config = list(bits)
            result = tuple(apply_global_map(f, config))
            if result in seen:
                return (n, seen[result], config, list(result))
            seen[result] = config
    return None


# ---------------------------------------------------------------------------
# Dependency Analysis
# ---------------------------------------------------------------------------

def analyze_dependency(rule_number: int) -> Dict[str, bool]:
    """Determine which inputs a rule genuinely depends on.

    A rule depends on input position p if there exist values of the
    other inputs such that changing p changes the output.

    Args:
        rule_number: Wolfram rule number.

    Returns:
        Dict with keys 'left', 'center', 'right' (bool values).
    """
    f = wolfram_to_rule(rule_number)
    return {
        "left": any(f(False, b, c) != f(True, b, c)
                    for b in [False, True] for c in [False, True]),
        "center": any(f(a, False, c) != f(a, True, c)
                      for a in [False, True] for c in [False, True]),
        "right": any(f(a, b, False) != f(a, b, True)
                     for a in [False, True] for b in [False, True]),
    }


def is_single_dependency(rule_number: int) -> Optional[Tuple[str, str]]:
    """Check if a rule is single-dependent and identify its structure.

    Args:
        rule_number: Wolfram rule number.

    Returns:
        (position, transform_type) if single-dependent, None otherwise.
        position ∈ {'left', 'center', 'right'}
        transform_type ∈ {'identity', 'complement', 'const_false', 'const_true'}
    """
    deps = analyze_dependency(rule_number)
    dep_count = sum(deps.values())

    if dep_count > 1:
        return None

    f = wolfram_to_rule(rule_number)

    if dep_count == 0:
        # Constant rule
        val = f(False, False, False)
        return ("none", "const_true" if val else "const_false")

    if deps["left"]:
        pos = "left"
        t_false = f(False, False, False)
        t_true = f(True, False, False)
    elif deps["center"]:
        pos = "center"
        t_false = f(False, False, False)
        t_true = f(False, True, False)
    else:
        pos = "right"
        t_false = f(False, False, False)
        t_true = f(False, False, True)

    if t_false == False and t_true == True:
        transform = "identity"
    elif t_false == True and t_true == False:
        transform = "complement"
    elif t_false == t_true:
        transform = "const_true" if t_false else "const_false"
    else:
        transform = "identity"  # shouldn't reach here

    return (pos, transform)


# ---------------------------------------------------------------------------
# Group Operations
# ---------------------------------------------------------------------------

def compose_global_maps(rule1: int, rule2: int, n: int) -> Dict[Tuple[bool, ...], Tuple[bool, ...]]:
    """Compute the composition of two global maps on size-n configurations.

    Args:
        rule1: First rule to apply (outer).
        rule2: Second rule to apply (inner).
        n: Configuration size.

    Returns:
        Dict mapping input configs to output configs.
    """
    f1 = wolfram_to_rule(rule1)
    f2 = wolfram_to_rule(rule2)
    result = {}
    for bits in itertools.product([False, True], repeat=n):
        config = list(bits)
        intermediate = apply_global_map(f2, config)
        output = apply_global_map(f1, intermediate)
        result[bits] = tuple(output)
    return result


def compute_group_table(rules: List[int], n: int) -> Dict[Tuple[int, int], Optional[int]]:
    """Compute the multiplication table for global maps on size-n configs.

    For each pair of rules, checks if their composition equals the global
    map of some elementary rule.

    Args:
        rules: List of rule numbers.
        n: Configuration size.

    Returns:
        Dict mapping (r1, r2) to the rule number of their composition,
        or None if no elementary rule matches.
    """
    # Precompute all global maps
    maps: Dict[int, Dict[Tuple[bool, ...], Tuple[bool, ...]]] = {}
    for r in range(256):
        f = wolfram_to_rule(r)
        m = {}
        for bits in itertools.product([False, True], repeat=n):
            config = list(bits)
            m[bits] = tuple(apply_global_map(f, config))
        maps[r] = m

    table = {}
    for r1 in rules:
        for r2 in rules:
            comp = compose_global_maps(r1, r2, n)
            found = None
            for r in range(256):
                if maps[r] == comp:
                    found = r
                    break
            table[(r1, r2)] = found

    return table


# ---------------------------------------------------------------------------
# Inverse Construction
# ---------------------------------------------------------------------------

INVERSE_MAP = {
    204: 204,  # identity -> identity
    170: 240,  # right shift -> left shift
    240: 170,  # left shift -> right shift
    51: 51,    # complement -> complement
    85: 15,    # complement-right -> complement-left
    15: 85,    # complement-left -> complement-right
}


def get_inverse_rule(rule_number: int) -> Optional[int]:
    """Get the inverse rule for a reversible elementary CA.

    Args:
        rule_number: Must be one of {15, 51, 85, 170, 204, 240}.

    Returns:
        The rule number of the inverse, or None if not reversible.
    """
    return INVERSE_MAP.get(rule_number)


if __name__ == "__main__":
    # Quick demonstration
    rev, nonrev = classify_reversibility()
    print(f"Reversible rules: {rev}")
    print(f"Non-reversible rules: {len(nonrev)} rules")

    for r in rev:
        sd = is_single_dependency(r)
        inv = get_inverse_rule(r)
        print(f"  Rule {r}: {sd}, inverse = Rule {inv}")
