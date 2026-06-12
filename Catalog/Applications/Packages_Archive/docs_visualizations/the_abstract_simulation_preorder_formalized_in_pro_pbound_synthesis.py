from typing import Callable, Iterable, Optional

Proof = tuple[str, int]

def combine_pbounds(witnesses: list[tuple[int, int]]) -> tuple[int, int]:
    """Join witness = (sum c_i, max k_i)."""
    c = sum(c_i for c_i, _ in witnesses)
    k = max(k_i for _, k_i in witnesses)
    return c, k

def _best(proofs: Iterable[Proof], f: str) -> Optional[int]:
    sizes = [s for c, s in proofs if c == f]
    return min(sizes) if sizes else None

def is_pbounded(proofs: list[Proof], cx: Callable[[str], int],
                c: int, k: int) -> bool:
    for f in {c0 for c0, _ in proofs}:
        s = _best(proofs, f)
        assert s is not None
        if s > c * (cx(f) + 1) ** k:
            return False
    return True
