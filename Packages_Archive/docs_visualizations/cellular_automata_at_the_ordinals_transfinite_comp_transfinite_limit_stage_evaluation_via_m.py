"""Transfinite Limit-Stage Evaluation via Monotone Stabilization Detection.

Computes the omega-stage configuration of an inflationary Boolean cellular
automaton on a finite window, by detecting per-cell stabilization. Because an
inflationary rule makes each cell's history monotone (Theorem 4.2) and monotone
Boolean histories are eventually constant (Theorem 4.3), the omega-stage exists,
is unique (Theorem 4.4), and equals the windowed configuration at the first
finite stage by which every windowed cell has settled (the 'collapse').
"""
from __future__ import annotations
from typing import Callable, Dict, List, Optional

Config = Dict[int, bool]
LocalRule = Callable[[bool, bool, bool], bool]


def _step(rule: LocalRule, c: Config, lo: int, hi: int) -> Config:
    def read(m: int) -> bool:
        return c.get(m, False)
    return {n: rule(read(n - 1 if n > 0 else 0), read(n), read(n + 1))
            for n in range(lo, hi + 1)}


def omega_stage(rule: LocalRule, c0: Config, lo: int, hi: int,
                max_steps: int = 10_000) -> Optional[Config]:
    """Return the windowed omega-stage of an inflationary rule, or None if no
    stabilization is observed within `max_steps` (i.e. the rule is not
    inflationary on this orbit and the clean limit is undefined).

    Complexity: O(S * W) time where S is the stabilization stage and W the
    window width, with O(W) extra space.
    """
    cells: List[int] = list(range(lo, hi + 1))
    current: Config = {n: c0.get(n, False) for n in cells}
    for _ in range(max_steps):
        nxt = _step(rule, current, lo, hi)
        # Inflationary check on the window; a decrease means 'not settled here'.
        if any(current[n] and not nxt[n] for n in cells):
            # Non-monotone: the clean eventual-constancy limit may not exist.
            return None
        if all(nxt[n] == current[n] for n in cells):
            return current  # whole window has stabilized -> omega-stage
        current = nxt
    return None


if __name__ == "__main__":
    or_rule: LocalRule = lambda l, c, r: l or c or r
    lo, hi = -8, 8
    seed: Config = {0: True}
    omega = omega_stage(or_rule, seed, lo, hi)
    assert omega is not None
    row = "".join("#" if omega[n] else "." for n in range(lo, hi + 1))
    print("omega-stage of OR automaton from a single seed:")
    print("  " + row)
