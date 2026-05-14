DIR = {0: (1,0), 1: (0,1), 2: (-1,0), 3: (0,-1)}

def dragon_path(n: int) -> list[tuple[int,int]]:
    """Generate dragon curve lattice path. Returns 2^n + 1 vertices."""
    # Generate turns
    def turns(n):
        if n == 0: return []
        prev = turns(n-1)
        return prev + [True] + [not b for b in reversed(prev)]
    
    t = turns(n)
    x, y, d = 0, 0, 0
    path = [(x, y)]
    for turn in t:
        dx, dy = DIR[d]
        x, y = x + dx, y + dy
        path.append((x, y))
        d = (d + 3) % 4 if turn else (d + 1) % 4
    dx, dy = DIR[d]
    path.append((x + dx, y + dy))
    return path

# Verify path lengths
for n in range(10):
    p = dragon_path(n)
    expected = 2**n + 1
    assert len(p) == expected
    print(f"n={n}: path length = {len(p)} = 2^{n}+1 ✓")