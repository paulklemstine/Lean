from typing import Dict, Tuple

def gaussian_triangle(N: int) -> Dict[Tuple[int, int], list]:
    """Compute classSize(n,k,.) for all 0<=k<=n<=N via the q-Pascal recurrence.

    Recurrence (condition on the last letter): appending a 1 adds 0 inversions,
    appending a 0 adds k inversions (one per existing one). Hence
        row(n+1,k)[i] = row(n,k-1)[i] + row(n,k)[i-k].
    Returns a dict mapping (n,k) to the coefficient list of [n choose k]_q.
    """
    rows: Dict[Tuple[int, int], list] = {}
    for n in range(N + 1):
        for k in range(n + 1):
            if n == 0:
                rows[(0, 0)] = [1]
                continue
            if k == 0 or k == n:
                rows[(n, k)] = [1]
                continue
            prev_left = rows[(n - 1, k - 1)]    # last letter 1: +0 inversions
            prev_down = rows[(n - 1, k)]        # last letter 0: +k inversions
            length = k * (n - k) + 1
            row = [0] * length
            for i, c in enumerate(prev_left):
                row[i] += c
            for i, c in enumerate(prev_down):
                row[i + k] += c
            rows[(n, k)] = row
    return rows
