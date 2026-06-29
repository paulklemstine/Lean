from math import log2

def entropy(card: int) -> float:
    """H(S) = log2(|S|) bits for a finite state space with `card` states (card >= 1)."""
    if card < 1:
        raise ValueError("state space must be nonempty (card >= 1)")
    return log2(card)
