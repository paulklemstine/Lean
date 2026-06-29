from typing import List

def lattice_path_count_dp(m: int, n: int) -> int:
    """Number of E/N lattice paths from (0,0) to (m,n) via Pascal DP."""
    table: List[List[int]] = [[1] * (n + 1) for _ in range(m + 1)]
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            table[i][j] = table[i - 1][j] + table[i][j - 1]
    return table[m][n]
