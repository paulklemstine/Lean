from typing import List, Tuple


def riordan_coupled_recurrence(n_max: int) -> List[Tuple[int, int, int]]:
    """Compute (n, A(n), B(n)) for n = 0..n_max via the coupled Pascal system.

    A(n) = sum_{k=0}^{n} C(n+k, 2k)      (row sums; = fib(2n+1))
    B(n) = sum_{k=0}^{n} C(n+k, 2k+1)    (companion; = fib(2n))

    Recurrences (Lemmas pascalRiordanB_succ, pascalRiordanA_succ):
        B(n+1) = A(n) + B(n)
        A(n+1) = A(n) + B(n+1)
    with initial data A(0) = 1, B(0) = 0.

    Complexity: O(n_max) big-integer additions; O(1) extra state.
    """
    result: List[Tuple[int, int, int]] = []
    a, b = 1, 0
    result.append((0, a, b))
    for n in range(n_max):
        b = a + b      # B(n+1) = A(n) + B(n)
        a = a + b      # A(n+1) = A(n) + B(n+1)
        result.append((n + 1, a, b))
    return result
