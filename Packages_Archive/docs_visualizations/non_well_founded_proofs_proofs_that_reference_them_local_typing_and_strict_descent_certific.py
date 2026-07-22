from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, List, Literal

@dataclass(frozen=True)
class Step:
    kind: Literal["assumption", "implication"]
    context: tuple[str, ...]
    conclusion: str
    child: str | None
    rank: int

def validate(steps: Dict[str, Step]) -> List[str]:
    errors: List[str] = []
    for name, step in steps.items():
        if step.kind == "assumption" and step.conclusion not in step.context:
            errors.append(f"{name}: unavailable assumption")
        if step.kind == "implication":
            if step.child not in steps:
                errors.append(f"{name}: missing child")
            elif steps[step.child].rank >= step.rank:
                errors.append(f"{name}: rank fails to decrease")
    return errors

if __name__ == "__main__":
    graph = {"root": Step("implication", (), "P -> P", "leaf", 1),
             "leaf": Step("assumption", ("P",), "P", None, 0)}
    print(validate(graph))
