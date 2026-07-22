from typing import Iterable, List, Tuple
Support = Tuple[bool, bool]

def audit_support(values: Iterable[Support]) -> List[Tuple[Support, Support, bool, bool]]:
    output: List[Tuple[Support, Support, bool, bool]] = []
    for positive, negative in values:
        value = (positive, negative)
        output.append((value, (negative, positive), positive, positive and negative))
    return output
