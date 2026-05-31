def collatz_iter(k, n):
    result = n
    for _ in range(k):
        result = result // 2 if result % 2 == 0 else 3 * result + 1
    return result