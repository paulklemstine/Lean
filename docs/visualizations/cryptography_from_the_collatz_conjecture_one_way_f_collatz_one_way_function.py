def collatz_owf(a: int, n: int) -> int:
    result = n
    for _ in range(a):
        if result % 2 == 0:
            result = result // 2
        else:
            result = 3 * result + 1
    return result