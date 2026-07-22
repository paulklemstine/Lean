from typing import List


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b)
        n //= b
    return out


def digital_root_residue(b: int, n: int) -> int:
    """Residue of n modulo b-1 via casting out nines (digit-sum reduction).
    Correct because b == 1 (mod b-1), so n == sum of base-b digits (mod b-1)."""
    if b < 2:
        raise ValueError("base must be >= 2")
    if b == 2:
        return 0            # modulus b-1 == 1, every residue is 0
    m = b - 1
    r = sum(digits(b, n)) % m
    return r


def fang_pair_admissible(b: int, x: int, y: int) -> bool:
    """Necessary residue condition for (x,y) to be a fang pair:
       (x-1)(y-1) == 1 (mod b-1), computed via casting out nines."""
    m = b - 1
    rx = digital_root_residue(b, x)
    ry = digital_root_residue(b, y)
    return ((rx - 1) * (ry - 1)) % m == 1 % m
