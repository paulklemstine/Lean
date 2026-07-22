from math import log2

def erasure_cost(card_source: int) -> float:
    """Entropy (bits) released by erasing `card_source` states to a single state.

    Equals log2(card_source) - log2(1) = log2(card_source).
    Strictly positive when card_source >= 2 (Landauer's principle).
    """
    if card_source < 1:
        raise ValueError("source state space must be nonempty")
    return log2(card_source) - log2(1)
