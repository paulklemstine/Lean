from __future__ import annotations
import itertools
from typing import Callable, Optional

Proof = tuple

def shorter_proof_count(n: int) -> int:
    """Total number of proofs of length < n: sum_{k<n} 2^k = 2^n - 1."""
    return (1 << n) - 1

def find_incompressibility_collision(
    n: int, compressor: Callable[[Proof], object]
) -> Optional[tuple[Proof, Proof]]:
    """Return two length-n proofs the compressor maps to the same shorter proof.

    Guaranteed to exist by no_universal_proof_compressor, since the image lives
    among only 2^n - 1 shorter proofs while there are 2^n inputs.
    Complexity: O(2^n) time and space.
    """
    seen: dict[object, Proof] = {}
    for x in itertools.product((0, 1), repeat=n):
        y = compressor(x)
        if y in seen:
            return (seen[y], x)
        seen[y] = x
    return None
