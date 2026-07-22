from typing import List

def divisors_gt_one(k: int) -> List[int]:
    return [d for d in range(2, k + 1) if k % d == 0]

def cyclotomic_divisibility(k: int, n: int) -> bool:
    """p_k = prod_{d|k, d>1} Phi_d, so p_k | (x^n - 1) iff every such Phi_d does,
    i.e. iff d | n for all d | k with d > 1 -- equivalently k | n.
    This function checks the divisor-by-divisor characterization directly."""
    return all(n % d == 0 for d in divisors_gt_one(k))

if __name__ == "__main__":
    for k in range(2, 8):
        for n in range(1, 20):
            assert cyclotomic_divisibility(k, n) == (n % k == 0)
    print("divisor-by-divisor characterization matches k | n")
