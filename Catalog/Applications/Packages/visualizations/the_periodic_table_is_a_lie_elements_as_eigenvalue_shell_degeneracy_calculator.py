def shell_degeneracy(n: int) -> int:
    return 2 * n * n

def verify_by_sum(n: int) -> bool:
    return sum(2*l+1 for l in range(n)) == n*n