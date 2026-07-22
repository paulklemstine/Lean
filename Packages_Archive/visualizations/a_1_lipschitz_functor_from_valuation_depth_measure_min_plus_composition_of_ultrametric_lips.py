from dataclasses import dataclass

@dataclass
class LipschitzData:
    """Ultrametric Lipschitz datum: an integer exponent; non-expansive iff >= 0."""
    exponent: int

    def is_non_expansive(self) -> bool:
        return self.exponent >= 0

def compose(f: LipschitzData, g: LipschitzData) -> LipschitzData:
    """Tropical (min-plus) composition: the composite exponent is the MINIMUM
    of the two exponents -- contractivity is preserved, never amplified."""
    return LipschitzData(min(f.exponent, g.exponent))

def iterate(f: LipschitzData, n: int) -> LipschitzData:
    """Compose f with itself n times. The exponent is invariant in n
    (iteration stability), in contrast to classical L^n blow-up. O(n) steps."""
    acc = f
    for _ in range(n):
        acc = compose(acc, f)
    return acc
