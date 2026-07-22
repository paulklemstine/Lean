from math import comb

def crowded_centre_certificate(code_size: int, n: int, q: int, r: int, t: int) -> int:
    """Markov upper bound floor(|C|*|B_r(0)|/t) on the number of centres z with
    |C n B_r(z)| >= t (Lean: card_bad_centres_le).

    A certificate computable in O(r) without touching the q^n centres.
    """
    volume: int = sum(comb(n, i) * (q - 1) ** i for i in range(r + 1))
    return (code_size * volume) // t
