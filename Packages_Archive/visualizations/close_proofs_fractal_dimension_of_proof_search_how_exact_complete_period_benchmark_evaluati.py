from __future__ import annotations
from fractions import Fraction
from typing import TypedDict

class Benchmark(TypedDict):
    depth: int
    free_count: int
    viable_prefixes: int
    dimension: Fraction

def benchmark(p: int, q: int, k: int) -> Benchmark:
    if q < 1 or k < 1 or p < 0 or p > q:
        raise ValueError("invalid parameters")
    f = p * k
    return {"depth": q*k, "free_count": f, "viable_prefixes": 1 << f,
            "dimension": Fraction(p, q)}

if __name__ == "__main__":
    print(benchmark(2, 3, 4))
