from typing import List

Matrix = List[List[float]]

class CompletenessOracle:
    """O(n^2) precompute, O(1) all-dimensions completeness queries."""
    def __init__(self, dmat: Matrix) -> None:
        n: int = len(dmat)
        self.t: float = (max(dmat[i][j] for i in range(n)
                             for j in range(i + 1, n)) if n > 1 else float('-inf'))

    def complete_at(self, eps: float) -> bool:
        """True iff Rips complex is complete at eps in every dimension."""
        return self.t <= eps
