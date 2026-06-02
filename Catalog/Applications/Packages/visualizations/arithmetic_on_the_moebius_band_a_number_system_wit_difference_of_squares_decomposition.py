def difference_of_squares(n: int) -> tuple[int, int] | None:
    if n % 4 == 2 or n % 4 == -2:
        return None
    if n % 2 != 0:
        a = (n + 1) // 2
        b = (n - 1) // 2
        return (a, b)
    else:
        m = n // 4
        return (m + 1, m - 1)