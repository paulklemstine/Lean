from typing import List


def eulerian_table(n_max: int) -> List[List[int]]:
    """Return E[n][k] = <n,k> for 0 <= k <= n <= n_max via the triangle
    recurrence <n,k> = (k+1)<n-1,k> + (n-k)<n-1,k-1>.  Time O(n_max^2)."""
    table: List[List[int]] = [[1]]
    for n in range(1, n_max + 1):
        prev = table[n - 1]
        row: List[int] = [0] * (n + 1)
        row[0] = 1
        for k in range(1, n + 1):
            left = prev[k] if k < len(prev) else 0
            right = prev[k - 1] if k - 1 < len(prev) else 0
            row[k] = (k + 1) * left + (n - k) * right
        table.append(row)
    return table
