from itertools import product
from typing import List, Optional, Tuple

Walk = List[Tuple[int, bool]]

def bundle_gainability(n: int, p: int) -> Optional[Tuple[int, ...]]:
    """
    Brute-force decision of Z/p-gainability of the contrabalanced bundle n*K_2.
    Every digon [(i,True),(j,False)] (i != j) must be UNBALANCED, i.e. have
    nonzero signed sum g[i]-g[j]. Returns a witnessing labelling or None.
    By Lemma A, a witness exists iff n <= p (the affine threshold).
    Complexity: O(p^n * n^2); used for verification on small instances.
    """
    digons: List[Walk] = [[(i, True), (j, False)]
                          for i in range(n) for j in range(n) if i != j]
    for g in product(range(p), repeat=n):
        if all((g[i] - g[j]) % p != 0 for c in digons for (i, _), (j, _) in [c]):
            return g
    return None
