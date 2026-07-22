from typing import List, Optional

Val = str
VALUES = ("T", "F", "B", "N")

def neg(v: Val) -> Val:
    return {"T": "F", "F": "T", "B": "B", "N": "N"}[v]

def is_designated(v: Val) -> bool:
    return v in ("T", "B")

def forced_value_of_self_negating(designated: bool) -> Optional[Val]:
    """Given that a coherent theory asserts a self-negating sentence, return the
    unique value it must take. If it must be designated (sound), the answer is the
    glut 'B'; otherwise the gap 'N' is the only other fixed point."""
    fixed: List[Val] = [v for v in VALUES if neg(v) == v]           # [B, N]
    candidates = [v for v in fixed if is_designated(v) == designated]
    return candidates[0] if len(candidates) == 1 else None

def classical_has_sound_liar() -> bool:
    """Two-valued check: is there a boolean fixed point of negation?"""
    return any((not b) == b for b in (True, False))
