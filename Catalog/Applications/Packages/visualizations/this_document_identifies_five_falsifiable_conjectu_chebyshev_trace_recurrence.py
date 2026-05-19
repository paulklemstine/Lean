def chebyshev_trace_sequence(t, d, N):
    """Compute trace sequence P(0)..P(N) via Chebyshev recurrence."""
    from fractions import Fraction
    if N < 0: return []
    seq = [Fraction(1)]
    if N == 0: return seq
    seq.append(t)
    for n in range(N - 1):
        seq.append(t * seq[-1] - d * seq[-2])
    return seq

# Example
from fractions import Fraction
print(chebyshev_trace_sequence(Fraction(5), Fraction(6), 5))