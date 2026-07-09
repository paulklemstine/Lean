from typing import List, Tuple


def stabilization_index(profile: List[int]) -> Tuple[int, int]:
    """Given an antitone N-valued rank profile, return (N, stable_value) where
    profile[m] == stable_value for all m >= N.  Mirrors the proof of
    antitone_nat_eventually_const: the least value is attained, and from its first
    occurrence onward the sequence is constant."""
    assert all(profile[i + 1] <= profile[i] for i in range(len(profile) - 1)), \
        "profile must be antitone"
    stable = profile[-1]
    N = next(m for m in range(len(profile)) if all(v == stable for v in profile[m:]))
    return N, stable
