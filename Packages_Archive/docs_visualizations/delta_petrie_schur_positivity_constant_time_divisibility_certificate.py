def petrie_divides_xn_minus_1(k: int, n: int) -> bool:
    """Decide whether p_k = 1 + x + ... + x^{k-1} divides x^n - 1.

    By the Petrie divisibility criterion (k >= 2), this holds iff k | n,
    so a degree-n polynomial divisibility test collapses to O(1) integer work."""
    if k < 2:
        raise ValueError("criterion requires k >= 2")
    return n % k == 0

if __name__ == "__main__":
    assert petrie_divides_xn_minus_1(2, 4) is True
    assert petrie_divides_xn_minus_1(3, 4) is False
    print("certificate OK")
