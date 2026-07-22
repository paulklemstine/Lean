from typing import Sequence

def apply_complete_graph_script(
    divisor: Sequence[int], script: Sequence[int]
) -> list[int]:
    if len(divisor) != len(script):
        raise ValueError("length mismatch")
    n = len(divisor)
    total = sum(script)
    result = [divisor[i] - n * script[i] + total for i in range(n)]
    assert sum(result) == sum(divisor)
    return result
