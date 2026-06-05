#!/usr/bin/env python3
"""
EML Spectral Algebra — Algorithms

Type-hinted implementations of the core algorithms from the EML Spectral Algebra theory.
"""
from typing import List, Tuple, Callable, Union
import math

# ── Type Definitions ─────────────────────────────────────────────────

Op = Union[
    Tuple[str],                    # ('exp',) or ('log',)
    Tuple[str, float, float],     # ('affine', a, b)
]
Chain = List[Op]

class EMLChannel:
    """A single KA term: (x,y) ↦ Φ(ψ₁(x) + ψ₂(y))."""
    def __init__(self, psi1: Chain, psi2: Chain, phi: Chain):
        self.psi1 = psi1
        self.psi2 = psi2
        self.phi = phi

    def eval(self, x: float, y: float) -> float:
        return eval_chain(self.phi, eval_chain(self.psi1, x) + eval_chain(self.psi2, y))

    def depth(self) -> int:
        return chain_depth(self.psi1) + chain_depth(self.psi2) + chain_depth(self.phi)

class EMLSpectrum:
    """A multi-channel decomposition: f(x,y) = Σ channel_q(x,y)."""
    def __init__(self, channels: List[EMLChannel]):
        self.channels = channels

    @property
    def width(self) -> int:
        return len(self.channels)

    def eval(self, x: float, y: float) -> float:
        return sum(ch.eval(x, y) for ch in self.channels)

    def max_depth(self) -> int:
        return max((ch.depth() for ch in self.channels), default=0)

    def add(self, other: 'EMLSpectrum') -> 'EMLSpectrum':
        """Sum of spectra: f+g decomposition."""
        return EMLSpectrum(self.channels + other.channels)

    def scale(self, c: float) -> 'EMLSpectrum':
        """Scale all channels by constant c."""
        return EMLSpectrum([
            EMLChannel(ch.psi1, ch.psi2, [('affine', c, 0)] + ch.phi)
            for ch in self.channels
        ])

# ── Core Algorithms ──────────────────────────────────────────────────

def eval_chain(chain: Chain, x: float) -> float:
    """Evaluate an EML chain at x (right-to-left composition).

    Algorithm:
        result ← x
        for each op in chain (reversed):
            result ← op(result)
        return result

    Complexity: O(|chain|)
    """
    result = x
    for op in reversed(chain):
        if op[0] == 'exp':
            result = math.exp(result)
        elif op[0] == 'log':
            if result <= 0:
                raise ValueError(f"log of non-positive value {result}")
            result = math.log(result)
        elif op[0] == 'affine':
            result = op[1] * result + op[2]
    return result

def chain_depth(chain: Chain) -> int:
    """Count non-affine operations in a chain.

    Algorithm: count exp and log operations.
    """
    return sum(1 for op in chain if op[0] in ('exp', 'log'))

def scaled_log(a: float) -> Chain:
    """Chain for x ↦ a·log(x)."""
    return [('affine', a, 0), ('log',)]

# ── Canonical Channels ───────────────────────────────────────────────

def multiplication_channel() -> EMLChannel:
    """x·y = exp(log(x) + log(y)). Width 1, depth 3."""
    return EMLChannel([('log',)], [('log',)], [('exp',)])

def division_channel() -> EMLChannel:
    """x/y = exp(log(x) - log(y)). Width 1, depth 3."""
    return EMLChannel([('log',)], [('affine', -1, 0), ('log',)], [('exp',)])

def monomial_channel(a: int, b: int) -> EMLChannel:
    """x^a · y^b = exp(a·log(x) + b·log(y)). Width 1, depth 3."""
    return EMLChannel(scaled_log(a), scaled_log(b), [('exp',)])

def geometric_mean_channel() -> EMLChannel:
    """√(xy) = exp(½(log(x) + log(y))). Width 1, depth 3."""
    return EMLChannel(scaled_log(0.5), scaled_log(0.5), [('exp',)])

def addition_spectrum() -> EMLSpectrum:
    """x + y = exp(log(x) + 0) + exp(0 + log(y)). Width 2, depth 2."""
    zero = [('affine', 0, 0)]
    return EMLSpectrum([
        EMLChannel([('log',)], zero, [('exp',)]),
        EMLChannel(zero, [('log',)], [('exp',)]),
    ])

def power_sum_spectrum(r: float) -> EMLSpectrum:
    """x^r + y^r. Width 2, depth 3."""
    zero = [('affine', 0, 0)]
    return EMLSpectrum([
        EMLChannel(scaled_log(r), zero, [('exp',)]),
        EMLChannel(zero, scaled_log(r), [('exp',)]),
    ])

# ── Polynomial Decomposition Algorithm ───────────────────────────────

def polynomial_spectrum(
    coeffs: List[float],
    exp_a: List[int],
    exp_b: List[int]
) -> EMLSpectrum:
    """Decompose polynomial Σ c_i · x^{a_i} · y^{b_i} into EML spectrum.

    Algorithm:
        For each monomial c_i · x^{a_i} · y^{b_i}:
            Create channel with:
                ψ₁ = a_i · log(x)
                ψ₂ = b_i · log(y)
                Φ  = c_i · exp(·)
        Return spectrum of all channels.

    Width: len(coeffs) (= number of monomials)
    Depth: 3 per channel (1 log + 1 log + 1 exp + affine)

    Pseudocode:
        INPUT: coefficients c[], exponents a[], b[]
        channels ← []
        FOR i = 1 TO M:
            ψ₁ ← [affine(a[i], 0), log]
            ψ₂ ← [affine(b[i], 0), log]
            Φ  ← [affine(c[i], 0), exp]
            channels.append(Channel(ψ₁, ψ₂, Φ))
        RETURN Spectrum(channels)
    """
    channels = []
    for c, a, b in zip(coeffs, exp_a, exp_b):
        ch = EMLChannel(
            psi1=scaled_log(a),
            psi2=scaled_log(b),
            phi=[('affine', c, 0), ('exp',)]
        )
        channels.append(ch)
    return EMLSpectrum(channels)

# ── Tropical Degeneration ────────────────────────────────────────────

def log_sum_exp(a: float, b: float) -> float:
    """Numerically stable log(exp(a) + exp(b))."""
    m = max(a, b)
    return m + math.log(math.exp(a - m) + math.exp(b - m))

def tropical_approx(a: float, b: float, t: float) -> float:
    """Tropical approximation: (1/t)·log(exp(ta) + exp(tb)) → max(a,b)."""
    return log_sum_exp(t * a, t * b) / t

# ── Fenchel-Young Bound ──────────────────────────────────────────────

def fenchel_young_gap(x: float, s: float) -> float:
    """Compute the Fenchel-Young gap: exp(x) + s·log(s) - s - x·s ≥ 0."""
    return math.exp(x) + s * math.log(s) - s - x * s

# ── Spectral Width Analysis ──────────────────────────────────────────

def analyze_spectral_width(
    f: Callable[[float, float], float],
    spectrum: EMLSpectrum,
    test_points: List[Tuple[float, float]],
) -> dict:
    """Analyze the accuracy of a spectral decomposition.

    Returns dict with max_error, mean_error, width, max_depth.
    """
    errors = []
    for x, y in test_points:
        err = abs(spectrum.eval(x, y) - f(x, y))
        errors.append(err)
    return {
        'width': spectrum.width,
        'max_depth': spectrum.max_depth(),
        'max_error': max(errors),
        'mean_error': sum(errors) / len(errors),
        'num_points': len(test_points),
    }


if __name__ == '__main__':
    # Quick test
    mul = multiplication_channel()
    assert abs(mul.eval(2, 3) - 6) < 1e-10
    add = addition_spectrum()
    assert abs(add.eval(2, 3) - 5) < 1e-10
    poly = polynomial_spectrum([3, 2, -1], [2, 1, 2], [1, 3, 2])
    assert abs(poly.eval(2, 3) - (3*4*3 + 2*2*27 - 4*9)) < 1e-8
    print("All algorithm tests passed!")
