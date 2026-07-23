def is_p_position(m: int, r: int, misere: bool = True) -> bool:
    """O(1) closed-form P-position test.

    misere: r is a P-position iff r ≡ 1 (mod m+1).
    normal: r is a P-position iff r ≡ 0 (mod m+1).
    """
    target = 1 if misere else 0
    return r % (m + 1) == target
