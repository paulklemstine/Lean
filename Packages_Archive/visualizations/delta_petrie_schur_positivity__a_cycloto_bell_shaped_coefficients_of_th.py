import matplotlib.pyplot as plt
from typing import List

def petrie_coefficients(k: int, N: int) -> List[int]:
    coeffs = [1]
    for _ in range(N):
        conv = [0] * (len(coeffs) + k - 1)
        for i, c in enumerate(coeffs):
            for j in range(k):
                conv[i + j] += c
        coeffs = conv
    return coeffs

def plot_coefficients(k: int = 5, N: int = 8) -> None:
    """Bar chart of c(k,N,n): a discrete bell shape summing to k^N."""
    c = petrie_coefficients(k, N)
    plt.figure(figsize=(8, 4))
    plt.bar(range(len(c)), c, color='steelblue')
    plt.xlabel('n (digit sum)'); plt.ylabel('c(k,N,n)')
    plt.title(f'Coefficients of P({k},{N};x) = p_{k}^{N}  (sum = {k}^{N} = {k**N})')
    plt.savefig('petrie_coefficients.png', dpi=120, bbox_inches='tight')

if __name__ == "__main__":
    plot_coefficients()
