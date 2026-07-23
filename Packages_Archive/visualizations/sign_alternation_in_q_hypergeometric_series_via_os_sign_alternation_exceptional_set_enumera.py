from typing import List, Sequence

def alternation_exceptions(a: Sequence[float]) -> List[int]:
    """Return indices n with a[n]*a[n+1] >= 0, i.e. where strict alternation fails.
    Runs in O(N) time and O(|E|) extra space."""
    return [n for n in range(len(a) - 1) if a[n] * a[n + 1] >= 0.0]
