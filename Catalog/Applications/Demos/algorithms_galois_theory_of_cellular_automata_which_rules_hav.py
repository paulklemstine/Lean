"""
Algorithms for Cellular Automata Reversibility Analysis

Type-hinted implementations of the core algorithms for analyzing reversible
dynamics of one-dimensional cellular automata.
"""

from typing import List, Tuple, Dict, Set, Callable, Optional
from itertools import product
import functools


def wolfram_rule_function(rule_number: int) -> Callable[[Tuple[int, int, int]], int]:
    """Convert a Wolfram rule number (0-255) to its local rule function.

    Args:
        rule_number: Integer 0-255 encoding the elementary CA rule.

    Returns:
        A function (a, b, c) -> {0, 1} giving the output for each neighborhood.
    """
    def local_rule(neighborhood: Tuple[int, int, int]) -> int:
        index = neighborhood[0] * 4 + neighborhood[1] * 2 + neighborhood[2]
        return (rule_number >> index) & 1
    return local_rule


def global_rule(rule_number: int, config: List[int]) -> List[int]:
    """Apply an elementary CA rule to a cyclic configuration.

    Args:
        rule_number: Wolfram rule number (0-255).
        config: Binary list representing a cyclic configuration.

    Returns:
        The next configuration after one time step.
    """
    n = len(config)
    f = wolfram_rule_function(rule_number)
    return [f((config[(i - 1) % n], config[i], config[(i + 1) % n])) for i in range(n)]


def is_reversible_on_period(rule_number: int, period: int) -> bool:
    """Check if a CA rule is reversible (bijective) on period-n configurations.

    Args:
        rule_number: Wolfram rule number.
        period: Size of the cyclic lattice.

    Returns:
        True if the global rule is a bijection on {0,1}^period.
    """
    configs = list(product([0, 1], repeat=period))
    images = set()
    for c in configs:
        img = tuple(global_rule(rule_number, list(c)))
        if img in images:
            return False
        images.add(img)
    return True


def find_reversible_ecas(period: int = 5) -> List[int]:
    """Find all elementary CA rules that are reversible on a given period.

    Args:
        period: Lattice size to test.

    Returns:
        List of rule numbers that are reversible on this period.
    """
    return [r for r in range(256) if is_reversible_on_period(r, period)]


def reversibility_spectrum(rule_number: int, max_period: int = 12) -> Dict[int, bool]:
    """Compute the reversibility spectrum of an elementary CA rule.

    The reversibility spectrum maps each period n to whether the rule
    is reversible on Z/nZ configurations.

    Args:
        rule_number: Wolfram rule number.
        max_period: Maximum period to test.

    Returns:
        Dictionary mapping period -> is_reversible.
    """
    return {n: is_reversible_on_period(rule_number, n)
            for n in range(1, max_period + 1)}


def garden_of_eden_count(rule_number: int, period: int) -> int:
    """Count Garden of Eden configurations (those with no preimage).

    Args:
        rule_number: Wolfram rule number.
        period: Lattice size.

    Returns:
        Number of configurations that are unreachable in one time step.
    """
    configs = list(product([0, 1], repeat=period))
    images = set()
    for c in configs:
        img = tuple(global_rule(rule_number, list(c)))
        images.add(img)
    total = 2 ** period
    return total - len(images)


def reversible_eca_group_structure(period: int) -> Dict[str, any]:
    """Analyze the group structure of reversible elementary CAs on period n.

    Returns:
        Dictionary with group information: elements, order, generators, etc.
    """
    # The 6 always-reversible ECAs
    reversible_rules = [15, 51, 85, 170, 204, 240]

    # Compute composition table (as permutations of configurations)
    configs = list(product([0, 1], repeat=period))
    config_to_idx = {c: i for i, c in enumerate(configs)}

    perms = {}
    for rule in reversible_rules:
        perm = []
        for c in configs:
            img = tuple(global_rule(rule, list(c)))
            perm.append(config_to_idx[img])
        perms[rule] = tuple(perm)

    # Identify generators
    identity_perm = tuple(range(len(configs)))
    shift_perm = perms[170]  # Left shift
    compl_perm = perms[51]   # Complement

    # Verify commutativity
    def compose_perms(p1: Tuple[int, ...], p2: Tuple[int, ...]) -> Tuple[int, ...]:
        return tuple(p1[p2[i]] for i in range(len(p1)))

    shift_then_compl = compose_perms(shift_perm, compl_perm)
    compl_then_shift = compose_perms(compl_perm, shift_perm)
    commutes = shift_then_compl == compl_then_shift

    # Compute order of shift
    current = shift_perm
    shift_order = 1
    while current != identity_perm:
        current = compose_perms(current, shift_perm)
        shift_order += 1

    return {
        "period": period,
        "num_configs": len(configs),
        "reversible_rules": reversible_rules,
        "shift_order": shift_order,
        "complement_order": 2,
        "shift_compl_commute": commutes,
        "group_order": 2 * shift_order,
        "group_structure": f"Z/{shift_order}Z × Z/2Z",
        "is_direct_product": commutes,
    }


def rule150_reversibility_test(max_period: int = 20) -> Dict[int, bool]:
    """Test the conjecture that Rule 150 is reversible iff 3 does not divide n.

    Rule 150: f(a,b,c) = a XOR b XOR c

    Returns:
        Dictionary mapping period -> (is_reversible, expected_reversible, match)
    """
    results = {}
    for n in range(1, max_period + 1):
        is_rev = is_reversible_on_period(150, n)
        expected = (n % 3 != 0)
        results[n] = {
            "is_reversible": is_rev,
            "expected": expected,
            "conjecture_holds": is_rev == expected
        }
    return results


def compute_goe_spectrum(rule_number: int, max_period: int = 10) -> Dict[int, float]:
    """Compute the normalized Garden of Eden count across periods.

    The GoE ratio = GoE_count / total_configs measures irreversibility.

    Args:
        rule_number: Wolfram rule number.
        max_period: Maximum period to test.

    Returns:
        Dictionary mapping period -> GoE ratio.
    """
    result = {}
    for n in range(1, max_period + 1):
        goe = garden_of_eden_count(rule_number, n)
        total = 2 ** n
        result[n] = goe / total
    return result
