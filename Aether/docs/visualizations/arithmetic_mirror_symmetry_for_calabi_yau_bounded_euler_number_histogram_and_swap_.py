from typing import Dict

def count_euler(e: int, bound: int) -> int:
    """Number of (h11, h21) in [0,bound]^2 with 2*(h11-h21) = e."""
    return sum(1 for a in range(bound + 1) for b in range(bound + 1)
               if 2 * (a - b) == e)

def euler_histogram(bound: int) -> Dict[int, int]:
    """Full Euler-number histogram of the bounded Hodge-diamond family."""
    hist: Dict[int, int] = {}
    for e in range(-2 * bound, 2 * bound + 1, 2):
        hist[e] = count_euler(e, bound)
    return hist

def histogram_is_symmetric(bound: int) -> bool:
    """Verify countEuler(e, B) == countEuler(-e, B) for all e (countEuler_neg)."""
    hist = euler_histogram(bound)
    return all(hist[e] == hist[-e] for e in hist)
