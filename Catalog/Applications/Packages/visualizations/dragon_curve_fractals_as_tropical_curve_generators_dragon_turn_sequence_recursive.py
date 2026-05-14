def dragon_turns_recursive(n: int) -> list[bool]:
    """Generate the Heighway dragon turn sequence at iteration n.
    True = right turn, False = left turn.
    Complexity: O(2^n) time and space."""
    if n == 0:
        return []
    prev = dragon_turns_recursive(n - 1)
    return prev + [True] + [not b for b in reversed(prev)]

# Example
for n in range(6):
    t = dragon_turns_recursive(n)
    s = ''.join('R' if b else 'L' for b in t)
    print(f"T({n}) = {s if s else '(empty)'} (length {len(t)})")