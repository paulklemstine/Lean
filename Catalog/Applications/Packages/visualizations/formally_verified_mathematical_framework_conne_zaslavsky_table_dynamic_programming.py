def zaslavsky_table(max_m: int, max_n: int) -> list:
    table = [[1]*(max_n+1) for _ in range(max_m+1)]
    for m in range(max_m):
        for n in range(max_n):
            table[m+1][n+1] = table[m][n+1] + table[m][n]
    return table