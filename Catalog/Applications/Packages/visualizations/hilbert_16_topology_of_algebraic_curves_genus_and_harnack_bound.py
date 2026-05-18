def genus(d: int) -> int:
    """Genus of smooth projective plane curve of degree d."""
    if d < 2:
        return 0
    return (d - 1) * (d - 2) // 2

def harnack_bound(d: int) -> int:
    """Maximum ovals for a smooth real plane curve of degree d."""
    return genus(d) + 1

# Examples
for d in range(1, 9):
    print(f'degree {d}: genus={genus(d)}, Harnack={harnack_bound(d)}')