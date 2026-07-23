from __future__ import annotations
from typing import Dict, List, Optional, Tuple

# Reuses Poly / eval_xy from the evaluation algorithm.
Poly = Dict[tuple, int]


def separating_witness(
    battery: List[Dict[int, Poly]],
    F: Poly,
    G: Poly,
    eval_xy,
) -> Optional[int]:
    """Return the index of a substitution in `battery` whose contraction keeps
    F and G apart, or None if every guess glues them.

    This is the operational core of the (Finite) Evaluation Separation Property:
    a genuine distinction must be witnessed by at least one concrete evaluation
    (Definition 6.1 / 7.1)."""
    for i, phi in enumerate(battery):
        if eval_xy(phi, F) != eval_xy(phi, G):
            return i
    return None


def battery_separates_all(
    battery: List[Dict[int, Poly]],
    pairs: List[Tuple[Poly, Poly]],
    eval_xy,
) -> bool:
    """Check the finite-witness condition on a list of pairs that the true
    elimination keeps apart: every such pair is separated by some guess."""
    return all(
        separating_witness(battery, F, G, eval_xy) is not None
        for (F, G) in pairs
    )
