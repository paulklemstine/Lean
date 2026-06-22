from typing import Callable, Optional

def diagonal_cost(sec: Callable[[int], int], t: int) -> int:
    return 2 ** sec(t) + 2 ** t

def diagonal_defeats_top(sec: Callable[[int], int],
                         f: Callable[[int], int],
                         N: int = 64) -> Optional[int]:
    """Smallest t where the diagonal cost exceeds the candidate blow-up,
    witnessing that no candidate top T (with local data sec, blow-up f) works."""
    for t in range(N):
        if diagonal_cost(sec, t) > f(sec(t)):
            return t
    return None

if __name__ == '__main__':
    sec = lambda t: t // 2          # some local datum a candidate might expose
    f = lambda m: (m + 2) ** 3      # a candidate polynomial blow-up
    print('defeated at t =', diagonal_defeats_top(sec, f))
