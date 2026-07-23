from typing import List, Tuple

Word = Tuple[str, ...]

def left_divisors(b: Word) -> List[Word]:
    """All left-divisors of a word in the free monoid = its initial segments.

    By Lemma 4.2 these are exactly the prefixes; by Theorem 4.4 there are len(b)+1
    of them, certifying finitariness of the prefix partial order.
    """
    return [tuple(b[:k]) for k in range(len(b) + 1)]
