def gcs_step(n: int, m: int, a: list[int], b: list[int]) -> int:
    r = n % m
    return (a[r] * n + b[r]) // m