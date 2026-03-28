"""
Tropical Semiring Arithmetic
=============================

Implements the tropical max-plus semiring T = (ℝ ∪ {-∞}, ⊕, ⊗) where:
    a ⊕ b = max(a, b)      (tropical addition)
    a ⊗ b = a + b           (tropical multiplication)
    𝟘 = -∞                  (additive identity)
    𝟙 = 0                   (multiplicative identity)

Also implements the Maslov deformation family T_β parameterized by β > 0:
    a ⊕_β b = (1/β) log(e^{βa} + e^{βb})

    β → 0:   arithmetic mean (quantum regime)
    β = 1:   LogSumExp (machine learning regime)
    β → ∞:   max(a, b) (tropical regime)
"""

import numpy as np
from typing import Union

# Tropical zero (additive identity): -∞
TROP_NEG_INF = float('-inf')


class TropicalFloat:
    """A value in the tropical semiring T = (ℝ ∪ {-∞}, max, +).

    Supports tropical arithmetic with operator overloading:
        a + b  →  max(a, b)   (tropical addition)
        a * b  →  a + b       (tropical multiplication)
        a ** n →  n * a       (tropical power)

    Examples
    --------
    >>> a = TropicalFloat(3.0)
    >>> b = TropicalFloat(5.0)
    >>> a + b  # tropical add = max
    TropicalFloat(5.0)
    >>> a * b  # tropical mul = plus
    TropicalFloat(8.0)
    """

    def __init__(self, value: float = TROP_NEG_INF):
        self.value = float(value)

    def __repr__(self):
        if self.value == TROP_NEG_INF:
            return "TropicalFloat(-∞)"
        return f"TropicalFloat({self.value})"

    def __add__(self, other):
        """Tropical addition: max"""
        if isinstance(other, TropicalFloat):
            return TropicalFloat(max(self.value, other.value))
        return TropicalFloat(max(self.value, float(other)))

    def __radd__(self, other):
        return self.__add__(other)

    def __mul__(self, other):
        """Tropical multiplication: plus"""
        if isinstance(other, TropicalFloat):
            return TropicalFloat(self.value + other.value)
        return TropicalFloat(self.value + float(other))

    def __rmul__(self, other):
        return self.__mul__(other)

    def __pow__(self, n):
        """Tropical power: scalar multiplication"""
        return TropicalFloat(n * self.value)

    def __eq__(self, other):
        if isinstance(other, TropicalFloat):
            return self.value == other.value
        return self.value == float(other)

    def __lt__(self, other):
        if isinstance(other, TropicalFloat):
            return self.value < other.value
        return self.value < float(other)

    def __le__(self, other):
        if isinstance(other, TropicalFloat):
            return self.value <= other.value
        return self.value <= float(other)

    def __float__(self):
        return self.value

    def __hash__(self):
        return hash(self.value)

    @staticmethod
    def zero():
        """Tropical additive identity: -∞"""
        return TropicalFloat(TROP_NEG_INF)

    @staticmethod
    def one():
        """Tropical multiplicative identity: 0"""
        return TropicalFloat(0.0)


def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)"""
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b"""
    return a + b


def trop_zero() -> float:
    """Tropical additive identity: -∞"""
    return TROP_NEG_INF


def trop_one() -> float:
    """Tropical multiplicative identity: 0"""
    return 0.0


def logsumexp(a: Union[float, np.ndarray], b: Union[float, np.ndarray] = None,
              beta: float = 1.0) -> Union[float, np.ndarray]:
    """LogSumExp: the Maslov deformation of tropical addition.

    logsumexp_β(a, b) = (1/β) log(e^{βa} + e^{βb})

    If only a is given (as array), computes over all elements.
    """
    if b is None:
        # Reduce over array
        a = np.asarray(a, dtype=float)
        m = np.max(a)
        if np.isinf(m) and m < 0:
            return float('-inf')
        return m + np.log(np.sum(np.exp(beta * (a - m)))) / beta
    else:
        a, b = float(a), float(b)
        m = max(a, b)
        if np.isinf(m) and m < 0:
            return float('-inf')
        return m + np.log(np.exp(beta * (a - m)) + np.exp(beta * (b - m))) / beta


def maslov_add(a: float, b: float, beta: float = 1.0) -> float:
    """Maslov deformation of tropical addition.

    a ⊕_β b = (1/β) log(e^{βa} + e^{βb})

    Properties:
        β → 0:   (a + b) / 2     (arithmetic mean)
        β = 1:   log(e^a + e^b)  (LogSumExp)
        β → ∞:   max(a, b)       (tropical addition)
    """
    if beta > 100:
        return max(a, b)
    if beta < 0.01:
        return (a + b) / 2.0
    return logsumexp(a, b, beta)


def trop_matvec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: (A ⊗ x)_i = max_j(A_{ij} + x_j)

    This is the Bellman update / dynamic programming step.
    """
    m, n = A.shape
    assert x.shape == (n,), f"Shape mismatch: A is {A.shape}, x is {x.shape}"
    result = np.full(m, TROP_NEG_INF)
    for i in range(m):
        for j in range(n):
            val = A[i, j] + x[j]
            if val > result[i]:
                result[i] = val
    return result


def trop_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ik} = max_j(A_{ij} + B_{jk})"""
    m, p = A.shape
    p2, n = B.shape
    assert p == p2, f"Inner dimension mismatch: {p} vs {p2}"
    result = np.full((m, n), TROP_NEG_INF)
    for i in range(m):
        for k in range(n):
            for j in range(p):
                val = A[i, j] + B[j, k]
                if val > result[i, k]:
                    result[i, k] = val
    return result


def trop_outer_sum(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Tropical outer product (outer sum): C_{ij} = a_i + b_j"""
    return a[:, None] + b[None, :]
