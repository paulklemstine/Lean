from itertools import product
from typing import List, Tuple

Word = Tuple[int, ...]

def generate_linear_code(gen: List[Word]) -> List[Word]:
    """Enumerate the 2^k codewords of the binary linear code spanned by `gen`.

    gen : list of k generator rows, each a length-n tuple of bits.
    Returns the sorted list of distinct codewords a*G (a in F2^k).
    Complexity: O(2^k * k * n).
    """
    k = len(gen)
    n = len(gen[0])
    code = set()
    for a in product((0, 1), repeat=k):
        word = tuple(
            sum(a[i] * gen[i][j] for i in range(k)) % 2 for j in range(n)
        )
        code.add(word)
    return sorted(code)
