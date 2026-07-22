from __future__ import annotations

def or_energy(hbar: float, t: float) -> float:
    """Self-energy for collapse time t:  E = hbar / t."""
    return hbar / t

def or_time(hbar: float, energy: float) -> float:
    """Collapse time for self-energy E:  t = hbar / E."""
    return hbar / energy

def reciprocity_solve(hbar: float, *, energy: float | None = None,
                      time: float | None = None) -> tuple[float, float]:
    """Given exactly one of {energy, time} and hbar, return (E, t) with E*t=hbar.

    Verifies involutivity: recovering the given quantity round-trips exactly.
    """
    if (energy is None) == (time is None):
        raise ValueError("supply exactly one of energy, time")
    if time is not None:
        e = or_energy(hbar, time)
        assert abs(or_time(hbar, e) - time) <= 1e-12 * abs(time)
        return e, time
    t = or_time(hbar, energy)          # type: ignore[arg-type]
    assert abs(or_energy(hbar, t) - energy) <= 1e-12 * abs(energy)
    return energy, t                   # type: ignore[return-value]
