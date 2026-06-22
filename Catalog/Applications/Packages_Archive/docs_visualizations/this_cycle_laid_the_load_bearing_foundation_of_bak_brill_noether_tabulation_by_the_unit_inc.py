def bn_number(g: int, r: int, d: int) -> int:
    """Brill-Noether number rho(g,r,d) = g - (r+1)(g - d + r)."""
    return g - (r + 1) * (g - d + r)

def bn_row(g: int, r: int, d0: int, length: int) -> list[int]:
    """Tabulate a degree-row of rho in O(1) per entry via the unit increment
    rho(g,r,d+1) = rho(g,r,d) + (r+1)."""
    row = [bn_number(g, r, d0)]
    for _ in range(length - 1):
        row.append(row[-1] + (r + 1))
    return row

def serre_dual(g: int, r: int, d: int) -> tuple[int, int, int]:
    """Serre involution (r,d) -> (g-1-d+r, 2g-2-d), under which rho is invariant."""
    return (g, g - 1 - d + r, 2 * g - 2 - d)
