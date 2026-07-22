from __future__ import annotations
from dataclasses import dataclass
from typing import Sequence


@dataclass(frozen=True)
class EpsilonSeries:
    """Coefficients c[0] + c[1] epsilon + ... in canonical order."""
    coefficients: tuple[float, ...]

    def standard_part(self) -> float:
        return self.coefficients[0] if self.coefficients else 0.0


def visible_support(weights: Sequence[EpsilonSeries]) -> list[int]:
    """Return indices whose normalized weights have positive standard part."""
    return [index for index, weight in enumerate(weights)
            if weight.standard_part() > 0.0]
