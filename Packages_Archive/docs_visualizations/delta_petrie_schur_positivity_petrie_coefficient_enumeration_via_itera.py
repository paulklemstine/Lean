from typing import List

def petrie_coefficients(k: int, N: int) -> List[int]:
    """Coefficients c(k,N,n) of P(k,N;x) = (1 + x + ... + x^{k-1})^N
    via iterated convolution. Complexity O(N^2 k)."""
    coeffs: List[int] = [1]
    block: List[int] = [1] * k
    for _ in range(N):
        conv = [0] * (len(coeffs) + k - 1)
        for i, c in enumerate(coeffs):
            for j in range(k):
                conv[i + j] += c * block[j]
        coeffs = conv
    return coeffs

if __name__ == "__main__":
    c = petrie_coefficients(3, 4)
    assert sum(c) == 3 ** 4
    print(c, "sum =", sum(c))
