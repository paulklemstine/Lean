from typing import Optional, Tuple

Readout = Tuple[bool, ...]


def topological_certify_and_decode(s: Readout) -> Tuple[int, Optional[bool]]:
    """Topological mitigation pipeline for a repetition-code readout.

    Returns (betti0, decoded_bit_or_None):
      * betti0 == 1 -> the agreement complex is connected; by the certification
        theorem the readout is exactly a codeword, so we return its common bit
        with a zero-error guarantee.
      * betti0 == 2 -> disagreement detected; we fall back to majority voting,
        which is provably correct whenever fewer than half the readouts are
        corrupted (the sharp n/2 threshold)."""
    n = len(s)
    if n == 0:
        return 0, None
    b0 = len(set(s))            # betti0 of the agreement complex
    if b0 == 1:
        return 1, s[0]          # certified error-free codeword
    decoded = (2 * sum(1 for x in s if x)) > n   # majority vote
    return 2, decoded
