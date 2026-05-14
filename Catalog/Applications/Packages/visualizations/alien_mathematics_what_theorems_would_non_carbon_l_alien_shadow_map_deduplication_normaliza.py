def alien_shadow(exponents):
    """Order-preserving deduplication — the normalization invisible to idempotent civilizations."""
    seen = set()
    result = []
    for i in exponents:
        if i not in seen:
            seen.add(i)
            result.append(i)
    return result

# Example
print(alien_shadow([0, 1, 0, 1, 1]))  # [0, 1]
print(alien_shadow([3, 1, 4, 1, 5, 9, 2, 6, 5]))  # [3, 1, 4, 5, 9, 2, 6]