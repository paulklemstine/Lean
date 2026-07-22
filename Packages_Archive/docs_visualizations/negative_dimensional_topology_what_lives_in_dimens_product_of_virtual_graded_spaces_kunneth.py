from collections import defaultdict
from typing import Dict

VSpace = Dict[int, int]


def product_space(x: VSpace, y: VSpace) -> VSpace:
    """Multiply virtual graded spaces via t^a * t^b = t^{a+b} (Kunneth).

    The Euler characteristic is multiplicative on the result:
    chi(product_space(x, y)) == chi(x) * chi(y). This convolution runs in
    O(|x| * |y|) integer operations.
    """
    out: Dict[int, int] = defaultdict(int)
    for da, ca in x.items():
        for db, cb in y.items():
            out[da + db] += ca * cb
    return {d: c for d, c in out.items() if c != 0}
