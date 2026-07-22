from typing import Mapping

def extended_euler(data: Mapping[int, int]) -> int:
    """Evaluate finite graded multiplicities against the parity character."""
    return sum(value if degree % 2 == 0 else -value
               for degree, value in data.items())
