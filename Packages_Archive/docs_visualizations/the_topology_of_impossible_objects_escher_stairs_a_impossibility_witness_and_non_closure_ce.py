from typing import List, Tuple


def find_impossibility_witness(t: List[float]
                               ) -> Tuple[bool, float, List[float]]:
    """
    Diagnose an additive figure. Returns a triple

        (realizable, holonomy_value, certificate)

    where `certificate` is the reconstructed global height field when the
    figure is realizable, and the running partial-sum defect vector
    (h[i] = sum of the first i increments) exhibiting the non-closure when it
    is impossible. In the impossible case the final defect equals the nonzero
    holonomy, an explicit witness that no global field can close the loop.

    Complexity: a single O(n) pass.
    """
    n = len(t)
    partial = [0.0] * n
    running = 0.0
    for i in range(n):
        partial[i] = running
        running += t[i]
    hol = running  # equals sum(t)
    realizable = abs(hol) <= 1e-12
    return realizable, hol, partial
