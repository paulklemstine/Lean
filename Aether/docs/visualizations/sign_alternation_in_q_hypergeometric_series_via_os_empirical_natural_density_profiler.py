from typing import Callable, List, Tuple

def density_profile(indicator: Callable[[int], bool],
                    cutoffs: List[int]) -> List[Tuple[int, float]]:
    """Empirical density #{n < N : indicator(n)} / N for each N in cutoffs.
    A decaying profile is numerical evidence of natural density zero."""
    profile: List[Tuple[int, float]] = []
    for N in cutoffs:
        c = sum(1 for n in range(N) if indicator(n))
        profile.append((N, c / N if N else 0.0))
    return profile
