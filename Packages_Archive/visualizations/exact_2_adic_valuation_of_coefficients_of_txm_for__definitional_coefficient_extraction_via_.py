from typing import List

def thue_morse_sign(n: int) -> int:
    return -1 if (bin(n).count("1") & 1) else 1

def coefficients_by_convolution(m: int, length: int) -> List[int]:
    """Return t_m(0..length-1), the coefficients of T(x)^m, by m-fold
    Cauchy convolution of the Thue-Morse sign sequence. Complexity O(m*length^2)."""
    coeff: List[int] = [thue_morse_sign(n) for n in range(length)]
    res: List[int] = [1] + [0] * (length - 1)
    for _ in range(m):
        new: List[int] = [0] * length
        for i in range(length):
            ri = res[i]
            if ri == 0:
                continue
            for j in range(length - i):
                new[i + j] += ri * coeff[j]
        res = new
    return res
