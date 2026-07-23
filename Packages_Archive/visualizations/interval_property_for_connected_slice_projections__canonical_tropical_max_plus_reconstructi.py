from typing import List, Sequence

Mode = Sequence[float]
Dictionary = Sequence[Mode]


def tight_coeff(f: Sequence[float], phi_k: Mode) -> float:
    """Largest t with t + phi_k <= f pointwise: min_x (f(x) - phi_k(x))."""
    return min(fx - pk for fx, pk in zip(f, phi_k))


def reconstruct(f: Sequence[float], phi: Dictionary) -> List[float]:
    """Max-plus biconjugate: max_k (tight_coeff_k + phi_k(x))."""
    coeffs: List[float] = [tight_coeff(f, m) for m in phi]
    n: int = len(f)
    return [max(coeffs[k] + phi[k][x] for k in range(len(phi))) for x in range(n)]


def discrepancy(f: Sequence[float], phi: Dictionary) -> float:
    """max_x (f(x) - reconstruct(x)); zero iff f is order-convex (Thm 2.12)."""
    rec: List[float] = reconstruct(f, phi)
    return max(fx - rx for fx, rx in zip(f, rec))


def is_order_convex(f: Sequence[float], phi: Dictionary, tol: float = 1e-9) -> bool:
    return discrepancy(f, phi) <= tol
