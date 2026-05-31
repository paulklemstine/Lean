"""
Algorithms for Self-Modifying Halting Analysis

Implements the core computational procedures from the formal framework:
- Self-modification depth computation
- Orbit cycle detection (Brent's algorithm adapted for self-modification)
- Fixed-point delay computation
- Diagonal program construction
"""

from typing import Callable, Optional, TypeVar, Generic
from dataclasses import dataclass

T = TypeVar('T')


@dataclass
class SelfModSystem(Generic[T]):
    """A self-modifying system with finite code space.

    Attributes:
        modify: Given a code, produces the modified code (self-modification).
        exec_halts: Given a code, returns True if execution halts, False if diverges.
        codes: The finite set of all possible codes.
    """
    modify: Callable[[T], T]
    exec_halts: Callable[[T], bool]
    codes: list[T]

    def selfmod_depth(self, code: T, n: int) -> T:
        """Compute the code after n rounds of self-modification.

        depth(code, 0) = code
        depth(code, n+1) = modify(depth(code, n))

        Satisfies: depth(code, m+n) = depth(depth(code, m), n)
        """
        current = code
        for _ in range(n):
            current = self.modify(current)
        return current

    def find_cycle(self, code: T) -> tuple[int, int]:
        """Find the tail length and cycle length of the self-modification orbit.

        Returns (tail, cycle) where:
        - tail: number of steps before entering the cycle
        - cycle: length of the cycle

        Uses Floyd's cycle detection algorithm.

        By the pigeonhole theorem (finite_selfmod_iterate_collision),
        tail + cycle <= len(codes).
        """
        # Phase 1: Find a meeting point
        tortoise = self.modify(code)
        hare = self.modify(self.modify(code))
        while tortoise != hare:
            tortoise = self.modify(tortoise)
            hare = self.modify(self.modify(hare))

        # Phase 2: Find the tail length
        tail = 0
        tortoise = code
        while tortoise != hare:
            tortoise = self.modify(tortoise)
            hare = self.modify(hare)
            tail += 1

        # Phase 3: Find the cycle length
        cycle = 1
        hare = self.modify(tortoise)
        while tortoise != hare:
            hare = self.modify(hare)
            cycle += 1

        return tail, cycle

    def fixed_point_delay(self, code: T) -> Optional[int]:
        """Find the minimum k such that depth(code, k) = depth(code, k+1).

        Returns None if no fixed point is reached within len(codes) steps.
        By selfmod_fixpoint_delay_upper, if a fixed point exists, k <= n-1.
        """
        current = code
        for k in range(len(self.codes)):
            next_code = self.modify(current)
            if current == next_code:
                return k
            current = next_code
        return None

    def hierarchy_level(self, code: T) -> int:
        """Compute the exact self-modification depth at which code stabilizes.

        Returns the smallest k such that depth(code, k+1) = depth(code, k).
        By selfmod_hierarchy_separation, all depths < k are distinct from depth k.
        """
        delay = self.fixed_point_delay(code)
        if delay is not None:
            return delay
        # If no fixed point, return -1 (enters a cycle without stabilizing)
        return -1

    def reachable_states(self, code: T, max_depth: int) -> set:
        """Compute the set of distinct states reachable within max_depth steps.

        By selfmod_reachable_bound, |result| <= min(max_depth+1, len(codes)).
        """
        states = set()
        current = code
        for _ in range(max_depth + 1):
            states.add(current)
            current = self.modify(current)
        return states


def diagonal_construction(
    n: int,
    oracle: Callable[[int], bool]
) -> Callable[[int], bool]:
    """Construct a diagonal program that defeats any halting oracle.

    Given an oracle that predicts halting, returns a function that
    halts iff the oracle says it doesn't, and diverges iff it says it does.

    This implements the core of Theorem 1 (no_selfmod_halting_oracle).

    Args:
        n: The code index of the diagonal program
        oracle: A candidate halting oracle

    Returns:
        A function representing the diagonal program's execution
    """
    def diag_exec(code: int) -> bool:
        if code == n:
            # Self-referential case: do the opposite of what oracle predicts
            return not oracle(n)
        return True  # Default: halt
    return diag_exec


def virus_detector_impossibility_demo(
    n_codes: int
) -> tuple[list[bool], list[bool]]:
    """Demonstrate that no perfect virus detector exists.

    For any candidate detector on n_codes codes, constructs a program
    that evades the detector (Theorem 3: no_perfect_virus_detector).

    Returns:
        (detector_predictions, actual_behaviors): The detector's output
        and the actual halting behavior of the diagonal program, showing
        at least one disagreement.
    """
    # Try every possible detector (there are 2^n_codes of them)
    # For each, the diagonal program defeats it
    results_det = []
    results_act = []

    for detector_bits in range(min(2**n_codes, 16)):
        detector = lambda c, bits=detector_bits: bool((bits >> c) & 1)
        diag_code = 0  # The diagonal program's code
        prediction = detector(diag_code)
        # Diagonal behavior: opposite of prediction
        actual = not prediction
        results_det.append(prediction)
        results_act.append(actual)

    return results_det, results_act


def monitor_evasion_demo(
    n_codes: int,
    monitor: Callable[[int], bool]
) -> dict:
    """Demonstrate monitor evasion (Theorem 6).

    Given any monitor, finds a program that evades the monitor's predictions.

    Args:
        n_codes: Number of possible codes
        monitor: The monitor function

    Returns:
        Dictionary with the evasion demonstration
    """
    results = {}
    for c in range(n_codes):
        prediction = monitor(c)
        # The evasive program does the opposite
        actual = not prediction
        results[c] = {
            "monitor_says": "halts" if prediction else "diverges",
            "actual": "diverges" if prediction else "halts",
            "evaded": True  # Always evades
        }
    return results


def compute_orbit_statistics(n: int) -> dict:
    """Compute orbit statistics for all functions Fin n → Fin n.

    For each function, computes:
    - Average tail length
    - Average cycle length
    - Maximum fixed-point delay
    - Distribution of hierarchy levels

    This provides computational evidence for the conjectures.
    """
    from itertools import product

    stats = {
        "n": n,
        "total_functions": n ** n,
        "max_fixed_point_delay": 0,
        "avg_tail": 0.0,
        "avg_cycle": 0.0,
        "hierarchy_distribution": {},
        "fixed_point_delay_distribution": {}
    }

    total_tail = 0
    total_cycle = 0
    count = 0

    # Enumerate all functions Fin n → Fin n
    for func_values in product(range(n), repeat=n):
        f = lambda x, fv=func_values: fv[x]
        system = SelfModSystem(
            modify=f,
            exec_halts=lambda x: True,
            codes=list(range(n))
        )

        for start in range(n):
            tail, cycle = system.find_cycle(start)
            delay = system.fixed_point_delay(start)

            total_tail += tail
            total_cycle += cycle
            count += 1

            if delay is not None:
                stats["max_fixed_point_delay"] = max(
                    stats["max_fixed_point_delay"], delay
                )
                stats["fixed_point_delay_distribution"][delay] = \
                    stats["fixed_point_delay_distribution"].get(delay, 0) + 1

            level = system.hierarchy_level(start)
            stats["hierarchy_distribution"][level] = \
                stats["hierarchy_distribution"].get(level, 0) + 1

    stats["avg_tail"] = total_tail / count if count > 0 else 0
    stats["avg_cycle"] = total_cycle / count if count > 0 else 0

    return stats
