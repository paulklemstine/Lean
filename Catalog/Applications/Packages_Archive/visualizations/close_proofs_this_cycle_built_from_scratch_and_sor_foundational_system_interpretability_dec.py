from dataclasses import dataclass

@dataclass(frozen=True)
class FoundationalSystem:
    name: str
    strength: int
    is_constructive: bool
    has_univalence: bool
    has_choice: bool

def interpretable_in(F: FoundationalSystem, G: FoundationalSystem) -> bool:
    return F.strength <= G.strength

def equiconsistent(F: FoundationalSystem, G: FoundationalSystem) -> bool:
    return F.strength == G.strength