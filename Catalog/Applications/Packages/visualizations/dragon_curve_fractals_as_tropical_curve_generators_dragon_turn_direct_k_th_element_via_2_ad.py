def two_adic_valuation(k: int) -> int:
    if k == 0:
        return float('inf')
    v = 0
    while k % 2 == 0:
        v += 1
        k //= 2
    return v

def dragon_turn_direct(k: int) -> bool:
    """Compute the k-th dragon turn (0-indexed) directly.
    Complexity: O(log k) per query."""
    m = k + 1
    v = two_adic_valuation(m)
    odd_part = m >> v
    return (odd_part % 4) == 1

# Verify against recursive method
def dragon_turns_recursive(n):
    if n == 0: return []
    prev = dragon_turns_recursive(n - 1)
    return prev + [True] + [not b for b in reversed(prev)]

for n in range(8):
    recursive = dragon_turns_recursive(n)
    direct = [dragon_turn_direct(k) for k in range(2**n - 1)]
    assert recursive == direct, f"Mismatch at n={n}"
    print(f"n={n}: recursive == direct ✓ (length {len(recursive)})")