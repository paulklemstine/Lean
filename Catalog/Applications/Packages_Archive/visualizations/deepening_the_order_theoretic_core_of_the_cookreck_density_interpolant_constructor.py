from typing import Callable, Tuple


def density_interpolant(k: int, c: int = 3
                        ) -> Tuple[Callable[[int], int], int, int]:
    """interPowSys k: upper rate on even n, lower rate on odd n."""
    assert k >= 1
    def size(n: int) -> int:
        return 2 ** (n ** (k + 1)) if n % 2 == 0 else 2 ** (n ** k)
    return size, 2 * (c + 2), 2 * (c + 2) + 1
