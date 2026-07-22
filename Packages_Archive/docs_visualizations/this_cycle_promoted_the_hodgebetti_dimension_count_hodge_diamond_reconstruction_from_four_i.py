from dataclasses import dataclass

@dataclass(frozen=True)
class CY4:
    h11: int
    h21: int
    h31: int
    h22: int

    def diamond(self, p: int, q: int) -> int:
        """Hodge diamond entry h^{p,q} on the support 0 <= p, q <= 4."""
        table = {
            (0, 0): 1, (4, 4): 1, (0, 4): 1, (4, 0): 1,
            (1, 1): self.h11, (3, 3): self.h11,
            (3, 1): self.h31, (1, 3): self.h31,
            (2, 2): self.h22,
            (2, 1): self.h21, (1, 2): self.h21,
            (2, 3): self.h21, (3, 2): self.h21,
        }
        return table.get((p, q), 0)
