from __future__ import annotations
import math

def coh_time(hbar: float, energy: float, n: int) -> float:
    """Coherence time t(N) = hbar / (E * sqrt(N))."""
    return hbar / (energy * math.sqrt(n))

def crossover_tubulins(hbar: float, energy: float, t_target: float) -> float:
    """Smallest N above which t(N) < t_target, solved in closed form.

    From hbar/(E*sqrt(N)) = t_target we get N* = (hbar/(E*t_target))^2.
    O(1) time; the coherence-time map is strictly antitone so N* is unique.
    """
    return (hbar / (energy * t_target)) ** 2

def falls_below(hbar: float, energy: float, n: int, t_target: float) -> bool:
    """Whether an N-tubulin network already decoheres faster than t_target."""
    return coh_time(hbar, energy, n) < t_target
