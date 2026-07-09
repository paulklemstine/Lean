from math import factorial
from typing import List, Tuple

Partition = Tuple[int, ...]


def hook_length_dimension(part: Partition, n: int) -> int:
    """Hook-length formula: dimension f^lambda of the irreducible representation
    of S_n indexed by the partition lambda = number of standard Young tableaux
    of shape lambda. Satisfies sum_{lambda |- n} (f^lambda)^2 = n!."""
    rows: List[int] = list(part)
    cols: List[int] = ([sum(1 for r in rows if r > c) for c in range(rows[0])]
                       if rows else [])
    prod_hooks = 1
    for i, row_len in enumerate(rows):
        for j in range(row_len):
            arm = row_len - j - 1
            leg = cols[j] - i - 1
            prod_hooks *= (arm + leg + 1)
    return factorial(n) // prod_hooks
