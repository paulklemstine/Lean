from dataclasses import dataclass
from typing import List, FrozenSet

Val = str

def neg(v: Val) -> Val:
    return {"T": "F", "F": "T", "B": "B", "N": "N"}[v]

def is_designated(v: Val) -> bool:
    return v in ("T", "B")

@dataclass
class Theory:
    truth: List[Val]
    sent_neg: List[int]
    provable: FrozenSet[int]

def audit_theory(t: Theory) -> dict:
    """Full soundness/consistency audit of a finite paraconsistent theory."""
    n = len(t.truth)
    coherent = all(t.truth[t.sent_neg[s]] == neg(t.truth[s]) for s in range(n))
    sound = all(is_designated(t.truth[s]) for s in t.provable)
    self_neg = [s for s in range(n) if t.sent_neg[s] == s]
    gluts = [s for s in range(n) if t.truth[s] == "B"]
    # explosion holds iff a provable glut forces every sentence designated
    explosion = any(
        s in t.provable and t.truth[s] == "B"
        and all(is_designated(t.truth[q]) for q in range(n))
        for s in self_neg)
    return {
        "coherent": coherent,
        "sound": sound,
        "self_negating": self_neg,
        "inconsistency_degree": len(gluts),
        "rejects_explosion": not explosion,
    }
