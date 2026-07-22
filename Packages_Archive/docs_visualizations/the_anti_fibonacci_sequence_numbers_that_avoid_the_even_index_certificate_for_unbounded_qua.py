from dataclasses import dataclass

@dataclass(frozen=True)
class Witness:
    bound: int
    index: int
    discrepancy: int

def displayed(n: int) -> int:
    return 1 + n * (n - 1) // 2

def quarter_square(n: int) -> int:
    return n * n // 4

def construct_witness(bound: int) -> Witness:
    if bound < 0:
        raise ValueError("bound must be nonnegative")
    k = bound + 2
    n = 2 * k
    gap = displayed(n) - quarter_square(n)
    assert gap == k * (k - 1) + 1 and gap > bound
    return Witness(bound, n, gap)

if __name__ == "__main__":
    for c in (0, 1, 10, 100, 10_000):
        print(construct_witness(c))
