from __future__ import annotations

def power_of_two_period_witness(threshold: int, period: int) -> tuple[int, int]:
    if threshold < 0 or period <= 0:
        raise ValueError("invalid certificate")
    power = 1
    while power <= max(threshold, period):
        power *= 2
    return power, power + period
