from typing import List, Tuple

Ranking = Tuple[int, ...]
Profile = List[Ranking]


def prefers(r: Ranking, a: int, b: int) -> bool:
    return r.index(a) < r.index(b)


def majority_beats(profile: Profile, a: int, b: int) -> bool:
    sa = sum(1 for r in profile if prefers(r, a, b))
    sb = sum(1 for r in profile if prefers(r, b, a))
    return sa > sb


def median_peak_winner(profile: Profile, n: int) -> int:
    """On a single-peaked profile with odd electorate, the median of the voters'
    peaks is the Condorcet winner. The peak is each voter's top-ranked alternative."""
    peaks = sorted(r[0] for r in profile)
    return peaks[len(peaks) // 2]


def is_condorcet_winner(profile: Profile, w: int, n: int) -> bool:
    """`w` beats every other alternative by majority."""
    return all(majority_beats(profile, w, b) for b in range(n) if b != w)
