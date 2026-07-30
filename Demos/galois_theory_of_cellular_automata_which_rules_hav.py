"""Numerical experiments for reversible elementary cellular automata."""
from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

Config = Tuple[int, ...]
REVERSIBLE_RULES: Tuple[int, ...] = (15, 51, 85, 170, 204, 240)


def local_output(rule: int, left: int, center: int, right: int) -> int:
    """Return the output bit indexed by 4*left + 2*center + right."""
    if not 0 <= rule < 256:
        raise ValueError("rule must lie between 0 and 255")
    return (rule >> (4 * left + 2 * center + right)) & 1


def configurations(n: int) -> List[Config]:
    """List every binary configuration on a nonempty cycle of length n."""
    if n <= 0:
        raise ValueError("cycle length must be positive")
    return list(product((0, 1), repeat=n))


def global_step(rule: int, state: Sequence[int]) -> Config:
    """Apply one synchronous elementary update with cyclic boundaries."""
    n = len(state)
    if n == 0:
        raise ValueError("state must be nonempty")
    return tuple(local_output(rule, state[(i - 1) % n], state[i], state[(i + 1) % n]) for i in range(n))


def is_bijective_on_cycle(rule: int, n: int) -> bool:
    """Test whether the global map permutes all 2**n configurations."""
    states = configurations(n)
    return len({global_step(rule, state) for state in states}) == len(states)


def rules_passing_lengths(lengths: Iterable[int]) -> List[int]:
    """Return rules bijective on every requested cycle length."""
    sizes = tuple(lengths)
    return [rule for rule in range(256) if all(is_bijective_on_cycle(rule, n) for n in sizes)]


def first_obstruction(rule: int, max_n: int = 4) -> int | None:
    """Return the first tested cycle length where bijectivity fails."""
    for n in range(1, max_n + 1):
        if not is_bijective_on_cycle(rule, n):
            return n
    return None


def collision(rule: int, n: int) -> Tuple[Config, Config, Config] | None:
    """Find two distinct states with the same image, if they exist."""
    seen: Dict[Config, Config] = {}
    for state in configurations(n):
        image = global_step(rule, state)
        if image in seen and seen[image] != state:
            return seen[image], state, image
        seen[image] = state
    return None


def verify_shift_complement_formulas(n: int = 7) -> bool:
    """Check the six structural formulas on all states of one cycle."""
    for x in configurations(n):
        left = tuple(x[(i - 1) % n] for i in range(n))
        right = tuple(x[(i + 1) % n] for i in range(n))
        comp = tuple(1 - bit for bit in x)
        if global_step(15, x) != tuple(1 - bit for bit in left): return False
        if global_step(51, x) != comp: return False
        if global_step(85, x) != tuple(1 - bit for bit in right): return False
        if global_step(170, x) != right: return False
        if global_step(204, x) != x: return False
        if global_step(240, x) != left: return False
    return True


def main() -> None:
    survivors = rules_passing_lengths(range(1, 5))
    print("Rules bijective on cycles 1, 2, 3, and 4:", survivors)
    print("Matches the six-rule classification:", tuple(survivors) == REVERSIBLE_RULES)
    print("Structural formulas pass on the 7-cycle:", verify_shift_complement_formulas())
    sample_rule = 30
    n = first_obstruction(sample_rule)
    print(f"First obstruction for rule {sample_rule}: cycle length {n}")
    if n is not None:
        print("Collision (past A, past B, shared future):", collision(sample_rule, n))
    print("Bijectivity table for the six survivors:")
    for rule in REVERSIBLE_RULES:
        print(rule, [is_bijective_on_cycle(rule, n) for n in range(1, 9)])


if __name__ == "__main__":
    main()
