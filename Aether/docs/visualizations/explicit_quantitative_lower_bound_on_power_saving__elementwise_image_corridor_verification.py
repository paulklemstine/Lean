from typing import Dict, Sequence


def degree(coeffs: Sequence[int]) -> int:
    for i, c in enumerate(coeffs):
        if c != 0:
            return len(coeffs) - 1 - i
    raise ValueError("zero polynomial")


def verify_corridor(coeffs: Sequence[int], A: Sequence[int]) -> Dict[str, float]:
    k: int = degree(coeffs)
    image: set = set()
    for a in A:
        v: int = 0
        for c in coeffs:
            v = v * a + c
        image.add(v)
    n: int = len(set(A))
    m: int = len(image)
    lower: float = n / k
    upper: float = float(n) ** (k - 1.0 / (k * k))
    return {"lower": lower, "image_size": m, "upper": upper,
            "holds": lower <= m <= upper + 1e-9}
