from math import gcd
from typing import Iterator

def collisions(limit: int) -> Iterator[dict[str, int | bool]]:
    """Generate cyclic–dihedral invariant collisions up to an order limit."""
    for n in range(3, limit // 2 + 1, 2):
        yield {"n": n, "order": 2 * n, "cyclic_exponent": 2 * n,
               "dihedral_exponent": n * 2 // gcd(n, 2),
               "cyclic_is_abelian": True, "dihedral_is_abelian": False,
               "cyclic_center_order": 2 * n, "dihedral_center_order": 1}

if __name__ == "__main__":
    for row in collisions(50):
        print(row)
