from math import gcd
from functools import reduce

def optimal_modulus(j: int, k: int, sample: int = 80) -> int:
    """Greatest modulus M with M | a^j - a^k for all integers a."""
    return reduce(gcd, (a ** j - a ** k for a in range(2, sample + 2)))

def sharpness_witness(j: int, k: int) -> int:
    """2^j - 2^k, the value at n=2 that certifies the modulus is greatest."""
    return 2 ** j - 2 ** k

if __name__ == '__main__':
    for (j, k) in [(7, 3), (5, 3), (9, 3), (11, 3), (13, 3)]:
        print(f'M_{{{j},{k}}} = {optimal_modulus(j, k):6d}'
              f'   witness 2^{j}-2^{k} = {sharpness_witness(j, k)}')
