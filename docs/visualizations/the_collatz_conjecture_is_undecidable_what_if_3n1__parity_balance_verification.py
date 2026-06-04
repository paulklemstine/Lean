def verify_parity_balance(n: int) -> bool:
    odd, total = 0, 0
    current = n
    while current != 1:
        if current % 2 == 1:
            odd += 1
        current = current // 2 if current % 2 == 0 else 3 * current + 1
        total += 1
    return 3 * odd < 2 * total