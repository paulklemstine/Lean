def transfer_exponent(n: int, k: int) -> int:
    """Compute E(n,k) = k*n - k*(k-1)//2."""
    return k * n - k * (k - 1) // 2

# Example
print(transfer_exponent(4, 2))  # 7
print(transfer_exponent(6, 3))  # 15