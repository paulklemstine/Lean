from fractions import Fraction
import math

class ComputableReal:
    def __init__(self, seq, mod):
        self.seq = seq
        self.mod = mod
    def approx_at(self, n):
        return self.seq(self.mod(n))

def effective_limit(sequence, cauchy_mod):
    """Diagonal construction for effective Cauchy completion."""
    def diag(n):
        return sequence(cauchy_mod(n + 2)).approx_at(n + 2)
    return ComputableReal(seq=diag, mod=lambda n: n + 2)

# Example: approximate e via partial sums
def partial_exp(n):
    val = sum(Fraction(1, math.factorial(k)) for k in range(n + 1))
    return ComputableReal(seq=lambda _,v=val: v, mod=lambda _: 0)

limit = effective_limit(partial_exp, lambda n: n + 5)
for n in [5, 10, 15]:
    approx = float(limit.approx_at(n))
    print(f"Precision {n}: {approx:.15f} (error: {abs(approx - math.e):.2e})")
