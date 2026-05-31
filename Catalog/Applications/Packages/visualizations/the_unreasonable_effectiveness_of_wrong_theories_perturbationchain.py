"""
Algorithms for Theory Perturbation and Effectiveness Analysis

Implements the mathematical framework from the formal Lean proofs:
- PerturbationChain: geometric decay correction sequences
- TheoryDefect: error distribution analysis
- Theory comparison and optimal truncation
"""

from typing import List, Tuple, Callable, Optional
import math


class PerturbationChain:
    """A sequence of corrections with geometrically decaying magnitudes.
    
    Models the structure T_true ≈ T₀ + ε·T₁ + ε²·T₂ + ...
    where each correction is bounded by |c_{k+1}| ≤ r·|c_k|.
    """
    
    def __init__(self, corrections: List[float], ratio: float):
        """Initialize a perturbation chain.
        
        Args:
            corrections: List of correction magnitudes
            ratio: Geometric decay ratio (must satisfy |ratio| < 1)
        
        Raises:
            ValueError: If |ratio| >= 1
        """
        if abs(ratio) >= 1:
            raise ValueError(f"|ratio| = {abs(ratio)} must be < 1")
        self.corrections = corrections
        self.ratio = ratio
    
    def partial_sum(self, n: int) -> float:
        """Compute the partial sum of corrections up to order n."""
        return sum(self.corrections[:n])
    
    def tail_bound(self, n: int) -> float:
        """Upper bound on remaining error after n terms.
        
        Implements Theorem 3.4: Σ_{k≥n} |c_k| ≤ |c₀|·|r|^n / (1 - |r|)
        """
        if not self.corrections:
            return 0.0
        c0 = abs(self.corrections[0])
        r = abs(self.ratio)
        if r == 0:
            return 0.0
        return c0 * r ** n / (1 - r)
    
    def optimal_truncation(self, target_accuracy: float) -> int:
        """Minimum number of terms for target accuracy.
        
        Finds smallest N such that tail_bound(N) ≤ target_accuracy.
        """
        if not self.corrections or target_accuracy <= 0:
            return len(self.corrections)
        c0 = abs(self.corrections[0])
        r = abs(self.ratio)
        if r == 0:
            return 1
        # Solve: c0 * r^N / (1 - r) ≤ target
        # r^N ≤ target * (1 - r) / c0
        rhs = target_accuracy * (1 - r) / c0
        if rhs >= 1:
            return 0
        if rhs <= 0:
            return len(self.corrections)
        return math.ceil(math.log(rhs) / math.log(r))
    
    def verify_geometric_decay(self) -> bool:
        """Check that corrections satisfy geometric decay property."""
        r = abs(self.ratio)
        for k in range(len(self.corrections) - 1):
            if abs(self.corrections[k + 1]) > r * abs(self.corrections[k]) + 1e-12:
                return False
        return True


class TheoryDefect:
    """Measures the error distribution of a theory across phenomena.
    
    Captures both magnitude and structure of wrongness.
    """
    
    def __init__(self, predictions: List[float], truth: List[float]):
        """Initialize theory defect from predictions and ground truth.
        
        Args:
            predictions: Theory's predictions on each phenomenon
            truth: Ground truth values
        
        Raises:
            ValueError: If lengths don't match
        """
        if len(predictions) != len(truth):
            raise ValueError("Predictions and truth must have same length")
        self.predictions = predictions
        self.truth = truth
        self.n = len(predictions)
    
    def pointwise_error(self, i: int) -> float:
        """Absolute error at phenomenon i."""
        return abs(self.predictions[i] - self.truth[i])
    
    def squared_errors(self) -> List[float]:
        """Squared error at each phenomenon."""
        return [(p - t) ** 2 for p, t in zip(self.predictions, self.truth)]
    
    def total_squared_error(self) -> float:
        """Total squared error across all phenomena."""
        return sum(self.squared_errors())
    
    def mean_squared_error(self) -> float:
        """Mean squared error."""
        if self.n == 0:
            return 0.0
        return self.total_squared_error() / self.n
    
    def effectiveness_domain(self, threshold: float) -> List[int]:
        """Phenomena where squared error is at most threshold.
        
        By Theorem 3.5, if MSE ≤ ε, this is guaranteed non-empty.
        By Theorem 3.6, this has size ≥ n/2 when threshold = 2·MSE.
        """
        errs = self.squared_errors()
        return [i for i, e in enumerate(errs) if e <= threshold]
    
    def concentration_ratio(self) -> float:
        """Ratio of max error to mean error.
        
        High concentration → errors focused on few phenomena.
        Low concentration → errors spread uniformly.
        """
        errs = self.squared_errors()
        if not errs:
            return 0.0
        mean_err = sum(errs) / len(errs)
        if mean_err == 0:
            return 0.0
        return max(errs) / mean_err


def compare_theories(
    theory_a: TheoryDefect,
    theory_b: TheoryDefect
) -> Tuple[List[int], List[int], List[int]]:
    """Compare two theories, finding where each is superior.
    
    Implements the wrong_theory_local_superiority theorem:
    even if A has lower total error, B can be better on specific phenomena.
    
    Returns:
        Tuple of (domain_A, domain_B, ties) where each is a list of
        phenomenon indices where that theory is superior.
    """
    n = theory_a.n
    errs_a = theory_a.squared_errors()
    errs_b = theory_b.squared_errors()
    
    domain_a: List[int] = []
    domain_b: List[int] = []
    ties: List[int] = []
    
    for i in range(n):
        if errs_a[i] < errs_b[i]:
            domain_a.append(i)
        elif errs_b[i] < errs_a[i]:
            domain_b.append(i)
        else:
            ties.append(i)
    
    return domain_a, domain_b, ties


def perturbation_convergence_demo(
    base_value: float,
    ratio: float,
    n_terms: int = 20
) -> List[Tuple[int, float, float]]:
    """Demonstrate perturbation series convergence.
    
    Creates a geometric perturbation chain and shows convergence
    of partial sums with error bounds.
    
    Returns:
        List of (n_terms, partial_sum, error_bound) tuples
    """
    corrections = [base_value * ratio ** k for k in range(n_terms)]
    chain = PerturbationChain(corrections, ratio)
    
    results = []
    for n in range(1, n_terms + 1):
        ps = chain.partial_sum(n)
        eb = chain.tail_bound(n)
        results.append((n, ps, eb))
    
    return results


def half_domain_verification(
    predictions: List[float],
    truth: List[float]
) -> Tuple[float, int, int, bool]:
    """Verify the half-domain theorem for given predictions.
    
    Returns:
        Tuple of (mse, effective_count, n, theorem_holds)
        where effective_count is the number of phenomena with
        squared error ≤ 2·MSE, and theorem_holds checks if
        effective_count ≥ n/2.
    """
    defect = TheoryDefect(predictions, truth)
    mse = defect.mean_squared_error()
    effective = defect.effectiveness_domain(2 * mse)
    n = defect.n
    holds = len(effective) * 2 >= n
    return mse, len(effective), n, holds
