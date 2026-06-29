"""
Algorithms for Ordinal Proof Refinement Systems (OrdinalPRS)

Type-hinted implementations of PRS simulation, stratified PRS dynamics,
and descent chain analysis.
"""

from dataclasses import dataclass
from typing import Callable, List, Tuple, Optional


@dataclass
class PRSResult:
    """Result of simulating a Proof Refinement System."""
    final_state: object
    steps: int
    energy_trace: List[int]
    terminal: bool


def simulate_prs(
    step: Callable[[object], object],
    terminal: Callable[[object], bool],
    energy: Callable[[object], int],
    initial_state: object,
    max_steps: Optional[int] = None,
) -> PRSResult:
    """
    Simulate a Proof Refinement System from an initial state.

    Args:
        step: State transition function.
        terminal: Predicate for terminal states.
        energy: Energy function (must decrease at non-terminal steps).
        initial_state: Starting state.
        max_steps: Optional safety bound (defaults to energy(initial_state) + 1).

    Returns:
        PRSResult with final state, step count, energy trace, and termination status.
    """
    s = initial_state
    bound = max_steps if max_steps is not None else energy(s) + 1
    trace = [energy(s)]

    for i in range(bound):
        if terminal(s):
            return PRSResult(final_state=s, steps=i, energy_trace=trace, terminal=True)
        s_next = step(s)
        e_next = energy(s_next)
        assert e_next < trace[-1], (
            f"Energy did not decrease at step {i}: {trace[-1]} -> {e_next}"
        )
        s = s_next
        trace.append(e_next)

    return PRSResult(
        final_state=s,
        steps=bound,
        energy_trace=trace,
        terminal=terminal(s),
    )


def countdown_prs(n: int) -> PRSResult:
    """Simulate the countdown PRS from state n."""
    return simulate_prs(
        step=lambda s: s - 1,
        terminal=lambda s: s == 0,
        energy=lambda s: s,
        initial_state=n,
    )


def euclid_prs(a: int, b: int) -> PRSResult:
    """Simulate the Euclidean algorithm PRS from state (a, b)."""
    return simulate_prs(
        step=lambda s: (s[0], 0) if s[1] == 0 else (s[1], s[0] % s[1]),
        terminal=lambda s: s[1] == 0,
        energy=lambda s: s[1],
        initial_state=(a, b),
    )


@dataclass
class StratifiedState:
    """State of a stratified PRS."""
    energies: List[int]  # energy[i] = energy at level i

    @property
    def total_energy(self) -> int:
        return sum(self.energies)

    @property
    def levels(self) -> int:
        return len(self.energies)

    def copy(self) -> "StratifiedState":
        return StratifiedState(energies=list(self.energies))


def stratified_step(
    state: StratifiedState,
    level: int,
    decrease: int,
    increase_below: Optional[List[int]] = None,
) -> StratifiedState:
    """
    Perform a stratified PRS step.

    Args:
        state: Current stratified state.
        level: Active level (energy decreases here).
        decrease: Amount of energy decrease at active level.
        increase_below: Optional list of increases at levels below active.
            Defaults to worst-case (each lower level gets +decrease).

    Returns:
        New StratifiedState after the step.
    """
    new_state = state.copy()
    new_state.energies[level] -= decrease

    if increase_below is None:
        # Worst case: each lower level increases by the full decrease
        for j in range(level):
            new_state.energies[j] += decrease
    else:
        for j, inc in enumerate(increase_below):
            if j < level:
                new_state.energies[j] += inc

    return new_state


def simulate_stratified_prs(
    initial_energies: List[int],
    strategy: Callable[[StratifiedState], Tuple[int, int]],
    max_steps: int = 10000,
) -> List[StratifiedState]:
    """
    Simulate a stratified PRS with a given strategy.

    Args:
        initial_energies: Energy at each level.
        strategy: Given state, returns (level, decrease) for next step.
        max_steps: Safety bound.

    Returns:
        List of states (trace).
    """
    state = StratifiedState(energies=list(initial_energies))
    trace = [state.copy()]

    for _ in range(max_steps):
        if all(e == 0 for e in state.energies):
            break
        level, decrease = strategy(state)
        if decrease <= 0 or level >= state.levels or state.energies[level] < decrease:
            break
        state = stratified_step(state, level, decrease)
        trace.append(state.copy())

    return trace


def descent_chain_max_length(start: int) -> int:
    """
    Compute the maximum length of a strict descent chain starting from `start`.
    By Theorem 3.1, this equals `start`.
    """
    return start


def verify_descent_chain(chain: List[int]) -> bool:
    """Verify that a sequence is a strict descent chain."""
    return all(chain[i + 1] < chain[i] for i in range(len(chain) - 1))


# ---- Hardy hierarchy functions (for future direction 5) ----

def hardy_omega(n: int) -> int:
    """H_ω(n) = 2n (Hardy function at ordinal ω)."""
    return 2 * n


def hardy_omega_sq(n: int) -> int:
    """H_{ω²}(n) ≈ n * 2^n (Hardy function at ordinal ω²).
    Approximation for small n."""
    return n * (2 ** n) if n > 0 else 0


def hardy_omega_cubed(n: int) -> int:
    """H_{ω³}(n) — grows as a tower of exponentials.
    Approximation for very small n."""
    if n == 0:
        return 0
    result = n
    for _ in range(n):
        result = result * (2 ** result)
        if result > 10**15:  # safety cap
            return result
    return result


if __name__ == "__main__":
    # Quick smoke test
    r = countdown_prs(10)
    assert r.steps == 10 and r.terminal
    print(f"Countdown(10): {r.steps} steps, energy trace: {r.energy_trace}")

    r = euclid_prs(252, 105)
    assert r.terminal
    print(f"Euclid(252,105): {r.steps} steps, final={r.final_state}, trace={r.energy_trace}")
