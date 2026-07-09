from math import isqrt

def is_square(n: int) -> bool:
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n

def brc_filter(v: int, k: int, lam: int) -> tuple[bool, str]:
    """Necessary-condition filter for a symmetric 2-(v,k,lambda) design."""
    if lam * (v - 1) != k * (k - 1):
        return False, "counting identity lambda(v-1)=k(k-1) fails"
    if not (0 < lam < k < v):
        return False, "parameter range 0 < lambda < k < v fails"
    order = k - lam
    if v % 2 == 0 and not is_square(order):
        return False, f"BRC: order {order} is not a perfect square -> no design"
    return True, "passes necessary conditions (BRC-admissible)"

if __name__ == "__main__":
    for u in (1, 2, 32):
        v_, k_, lam_ = 12*u*u+8*u+2, 6*u*u+u, 3*u*u-u
        print(f"u={u}: (v,k,lambda)=({v_},{k_},{lam_}) ->", brc_filter(v_, k_, lam_))
