import math

def optimal_sample_size(q: int, c: int, kl: float, epsilon: float) -> int:
    """Compute minimum sample size for generalization at accuracy epsilon."""
    effective_rate = q + c + kl
    return math.ceil(effective_rate / epsilon ** 2)

# Example
print(f'Minimum samples for (q=10, c=5, kl=3.0, eps=0.1): {optimal_sample_size(10, 5, 3.0, 0.1)}')
print(f'Minimum samples for (q=10, c=5, kl=3.0, eps=0.05): {optimal_sample_size(10, 5, 3.0, 0.05)}')