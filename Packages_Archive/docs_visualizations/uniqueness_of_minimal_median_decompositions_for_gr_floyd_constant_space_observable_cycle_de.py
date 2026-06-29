from typing import Callable, Tuple

def floyd_label_cycle(
    f: Callable[[int], int],
    x: int,
    label: Callable[[int], int],
) -> Tuple[int, int]:
    """Constant-space detection on the eventually-periodic label sequence
    i -> label(f^[i](x)). Returns (mu, lam): pre-period length and period.
    O(mu + lam) time, O(1) extra space."""
    slow, fast = f(x), f(f(x))
    while label(slow) != label(fast):
        slow, fast = f(slow), f(fast)
    mu = 0
    slow = x
    while label(slow) != label(fast):
        slow, fast = f(slow), f(fast)
        mu += 1
    lam = 1
    fast = f(slow)
    while label(slow) != label(fast):
        fast = f(fast)
        lam += 1
    return mu, lam
