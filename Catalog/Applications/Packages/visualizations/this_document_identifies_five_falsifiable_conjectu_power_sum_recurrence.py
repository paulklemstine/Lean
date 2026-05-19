def power_sum_sequence(t, d, N):
    """Compute alpha^n + beta^n via recurrence."""
    from fractions import Fraction
    if N < 0: return []
    seq = [Fraction(2)]
    if N == 0: return seq
    seq.append(t)
    for n in range(N - 1):
        seq.append(t * seq[-1] - d * seq[-2])
    return seq

# Example
from fractions import Fraction
print(power_sum_sequence(Fraction(5), Fraction(6), 5))