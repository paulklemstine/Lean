def cyc_count_closed_form(b: int, d: int, n: int) -> int:
    """
    Exact count of digit d in the first n terms of the cyclic stream
    cyc_b(k) = k mod b, via the congruence-counting identity:
        countDigit(cyc_b, d, n) = n // b + [d < n % b].
    Runs in O(1).
    """
    return n // b + (1 if d < n % b else 0)

def cyc_discrepancy(b: int, d: int, n: int) -> float:
    """|countDigit(cyc_b, d, n) - n/b|, provably <= 1 for all n (O(1) discrepancy)."""
    return abs(cyc_count_closed_form(b, d, n) - n / b)
