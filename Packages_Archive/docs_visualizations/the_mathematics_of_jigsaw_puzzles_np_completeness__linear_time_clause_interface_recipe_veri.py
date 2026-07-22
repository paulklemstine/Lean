from typing import Sequence, Tuple
Literal = Tuple[int, bool]
Formula = Sequence[Sequence[Literal]]
Assignment = Tuple[bool, ...]

def verify_recipe(assignment: Assignment, formula: Formula) -> bool:
    """Check every clause interface; O(L) time for L literal occurrences."""
    for clause in formula:
        active = False
        for variable, polarity in clause:
            value = assignment[variable] if variable < len(assignment) else False
            if value == polarity:
                active = True
                break
        if not active:
            return False
    return True
