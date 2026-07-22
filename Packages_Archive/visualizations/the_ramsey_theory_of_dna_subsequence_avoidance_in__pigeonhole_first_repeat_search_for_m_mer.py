from typing import Dict, Optional, Sequence, Tuple

def first_repeated_mer(seq: Sequence[int], m: int, q: int) -> Optional[Tuple[int, int]]:
    """Return the (earliest, later) window positions of the first repeated
    m-mer over a q-symbol alphabet, or None. Guaranteed to succeed within
    q**m + 1 windows by the pigeonhole threshold."""
    seen: Dict[Tuple[int, ...], int] = {}
    windows = len(seq) - m + 1
    for i in range(windows):
        block = tuple(seq[i + j] for j in range(m))
        if block in seen:
            return seen[block], i
        seen[block] = i
    return None
