import numpy as np

def tropical_growth_analysis(A, x, T=20):
    """Analyze growth rate of tropical linear iterates."""
    rho = np.max(A)
    current = x.copy()
    sup_x = np.max(x)
    print(f'Spectral bound rho = {rho:.4f}')
    for t in range(T):
        actual = np.max(current)
        bound = sup_x + t * rho
        print(f't={t:2d}: sup={actual:8.3f}, bound={bound:8.3f}, gap={bound-actual:8.3f}')
        current = np.array([np.max(A[i] + current) for i in range(len(A))])

# Example
np.random.seed(42)
A = np.random.randn(5, 5)
x = np.zeros(5)
tropical_growth_analysis(A, x, T=10)