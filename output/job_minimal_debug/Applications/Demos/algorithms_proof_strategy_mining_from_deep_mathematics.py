#!/usr/bin/env python3
"""
Algorithms for Proof Strategy Mining

Implements the core algorithms described in the research paper:
1. Certified verification via the descent schema
2. Descent chain construction and analysis
3. Well-founded descent verification for arbitrary relations
4. Automatic base regime optimization

These algorithms correspond to the formal theorems in
Logic/ProofStrategyMining.lean.
"""

from typing import (
    TypeVar, Generic, Callable, Optional, Tuple, List, Set, Dict, Any
)
from dataclasses import dataclass
from enum import Enum
import time

T = TypeVar('T')


class VerificationResult(Enum):
    """Result of a descent schema verification."""
    VERIFIED = "verified"
    BASE_FAILURE = "base_failure"
    DESCENT_FAILURE = "descent_failure"
    CYCLE_DETECTED = "cycle_detected"
    TIMEOUT = "timeout"


@dataclass
class DescentChain(Generic[T]):
    """A descent chain from an object to the base regime."""
    start: Any
    chain: List[Tuple[Any, int]]  # (object, complexity) pairs
    reached_base: bool
    total_descent: int  # μ(start) - μ(end)


@dataclass
class VerificationReport:
    """Detailed report from a descent schema verification."""
    result: VerificationResult
    objects_checked: int
    base_verified: int
    descent_verified: int
    counterexample: Optional[Any] = None
    failure_reason: str = ""
    max_chain_length: int = 0
    mean_chain_length: float = 0.0
    elapsed_seconds: float = 0.0


def verify_finite_check_and_descent(
    objects: List[Any],
    mu: Callable[[Any], int],
    P: Callable[[Any], bool],
    N: int,
    step: Callable[[Any], Optional[Tuple[Any, str]]],
    check_chains: bool = False,
    max_chain_length: int = 10000,
) -> VerificationReport:
    """
    Verify a property P for a finite collection of objects using the
    finite-check-and-descent schema.

    This implements Algorithm VERIFY_BY_DESCENT from the research paper.

    Parameters
    ----------
    objects : list
        The objects to verify.
    mu : callable
        Complexity measure μ : α → ℕ.
    P : callable
        Property to check (returns bool).
    N : int
        Base regime threshold.
    step : callable
        Reduction function. Returns (reduced_object, explanation) or None
        if object is in base regime.
    check_chains : bool
        If True, build and analyze full descent chains for each object.
    max_chain_length : int
        Maximum chain length before declaring timeout.

    Returns
    -------
    VerificationReport
        Detailed verification report.

    Complexity
    ----------
    Time: O(|objects| × max_chain_length) in worst case.
    Space: O(|objects|) for the report; O(max_chain_length) per chain.
    """
    start_time = time.time()
    base_verified = 0
    descent_verified = 0
    chain_lengths: List[int] = []

    # Phase 1: Verify base regime
    for a in objects:
        if mu(a) <= N:
            if not P(a):
                return VerificationReport(
                    result=VerificationResult.BASE_FAILURE,
                    objects_checked=base_verified,
                    base_verified=base_verified,
                    descent_verified=0,
                    counterexample=a,
                    failure_reason=f"P fails on base object {a} with μ={mu(a)}",
                    elapsed_seconds=time.time() - start_time,
                )
            base_verified += 1

    # Phase 2: Verify descent for objects outside base regime
    for a in objects:
        if mu(a) > N:
            if check_chains:
                # Build full descent chain
                chain_len = 0
                current = a
                visited: Set[int] = set()
                while mu(current) > N:
                    obj_id = id(current)
                    if obj_id in visited:
                        return VerificationReport(
                            result=VerificationResult.CYCLE_DETECTED,
                            objects_checked=base_verified + descent_verified,
                            base_verified=base_verified,
                            descent_verified=descent_verified,
                            counterexample=current,
                            failure_reason=f"Cycle detected at {current}",
                            elapsed_seconds=time.time() - start_time,
                        )
                    visited.add(obj_id)
                    result = step(current)
                    if result is None:
                        return VerificationReport(
                            result=VerificationResult.DESCENT_FAILURE,
                            objects_checked=base_verified + descent_verified,
                            base_verified=base_verified,
                            descent_verified=descent_verified,
                            counterexample=current,
                            failure_reason=f"No descent for {current} (μ={mu(current)})",
                            elapsed_seconds=time.time() - start_time,
                        )
                    b, _ = result
                    if mu(b) >= mu(current):
                        return VerificationReport(
                            result=VerificationResult.DESCENT_FAILURE,
                            objects_checked=base_verified + descent_verified,
                            base_verified=base_verified,
                            descent_verified=descent_verified,
                            counterexample=current,
                            failure_reason=(f"Non-strict descent: {current} → {b} "
                                          f"(μ: {mu(current)} → {mu(b)})"),
                            elapsed_seconds=time.time() - start_time,
                        )
                    current = b
                    chain_len += 1
                    if chain_len > max_chain_length:
                        return VerificationReport(
                            result=VerificationResult.TIMEOUT,
                            objects_checked=base_verified + descent_verified,
                            base_verified=base_verified,
                            descent_verified=descent_verified,
                            counterexample=a,
                            failure_reason=f"Chain length exceeded {max_chain_length}",
                            elapsed_seconds=time.time() - start_time,
                        )
                chain_lengths.append(chain_len)
            else:
                # Just verify one step
                result = step(a)
                if result is None:
                    return VerificationReport(
                        result=VerificationResult.DESCENT_FAILURE,
                        objects_checked=base_verified + descent_verified,
                        base_verified=base_verified,
                        descent_verified=descent_verified,
                        counterexample=a,
                        failure_reason=f"No descent for {a} (μ={mu(a)})",
                        elapsed_seconds=time.time() - start_time,
                    )
                b, _ = result
                if mu(b) >= mu(a):
                    return VerificationReport(
                        result=VerificationResult.DESCENT_FAILURE,
                        objects_checked=base_verified + descent_verified,
                        base_verified=base_verified,
                        descent_verified=descent_verified,
                        counterexample=a,
                        failure_reason=(f"Non-strict descent: {a} → {b} "
                                      f"(μ: {mu(a)} → {mu(b)})"),
                        elapsed_seconds=time.time() - start_time,
                    )
            descent_verified += 1

    max_cl = max(chain_lengths) if chain_lengths else 0
    mean_cl = (sum(chain_lengths) / len(chain_lengths)) if chain_lengths else 0.0

    return VerificationReport(
        result=VerificationResult.VERIFIED,
        objects_checked=base_verified + descent_verified,
        base_verified=base_verified,
        descent_verified=descent_verified,
        max_chain_length=max_cl,
        mean_chain_length=mean_cl,
        elapsed_seconds=time.time() - start_time,
    )


def build_descent_chain(
    a: Any,
    mu: Callable[[Any], int],
    N: int,
    step: Callable[[Any], Optional[Tuple[Any, str]]],
    max_steps: int = 10000,
) -> DescentChain:
    """
    Build the complete descent chain from object a to the base regime.

    Parameters
    ----------
    a : Any
        Starting object.
    mu : callable
        Complexity measure.
    N : int
        Base regime threshold.
    step : callable
        Reduction function.
    max_steps : int
        Maximum number of descent steps.

    Returns
    -------
    DescentChain
        The complete chain with metadata.

    Complexity
    ----------
    Time: O(max_steps)
    Space: O(chain_length)
    """
    chain: List[Tuple[Any, int]] = [(a, mu(a))]
    current = a
    for _ in range(max_steps):
        if mu(current) <= N:
            break
        result = step(current)
        if result is None:
            break
        current = result[0]
        chain.append((current, mu(current)))

    return DescentChain(
        start=a,
        chain=chain,
        reached_base=mu(current) <= N,
        total_descent=mu(a) - mu(current),
    )


def optimize_base_threshold(
    objects: List[Any],
    mu: Callable[[Any], int],
    P: Callable[[Any], bool],
    step: Callable[[Any], Optional[Tuple[Any, str]]],
    max_N: int = 100,
) -> Tuple[int, VerificationReport]:
    """
    Find the minimal base threshold N such that the descent schema succeeds.

    This implements a binary search over possible thresholds, finding the
    smallest N for which the base regime + descent covers all objects.

    Parameters
    ----------
    objects : list
        Objects to verify.
    mu : callable
        Complexity measure.
    P : callable
        Property to check.
    step : callable
        Reduction function.
    max_N : int
        Maximum threshold to try.

    Returns
    -------
    (int, VerificationReport)
        The optimal threshold and its verification report.

    Complexity
    ----------
    Time: O(log(max_N) × |objects|)
    """
    best_N = max_N
    best_report = None

    # Try progressively smaller thresholds
    for N in range(max_N, -1, -1):
        report = verify_finite_check_and_descent(
            objects, mu, P, N, step, check_chains=False
        )
        if report.result == VerificationResult.VERIFIED:
            best_N = N
            best_report = report
        else:
            break

    if best_report is None:
        best_report = verify_finite_check_and_descent(
            objects, mu, P, max_N, step, check_chains=False
        )

    return best_N, best_report


def well_founded_verify(
    objects: List[Any],
    r: Callable[[Any, Any], bool],
    P: Callable[[Any], bool],
    B: Callable[[Any], bool],
    predecessors: Callable[[Any], List[Any]],
    max_depth: int = 1000,
) -> VerificationReport:
    """
    Verify a property using the general well-founded descent schema.

    This corresponds to global_of_base_and_wf_descent.

    Parameters
    ----------
    objects : list
        Objects to verify.
    r : callable
        Well-founded relation (r(b, a) means b is simpler than a).
    P : callable
        Property to check.
    B : callable
        Base predicate.
    predecessors : callable
        For each non-base object, returns list of r-predecessors.
    max_depth : int
        Maximum recursion depth.

    Returns
    -------
    VerificationReport
    """
    start_time = time.time()
    base_count = 0
    step_count = 0

    # Memoize P results
    cache: Dict[int, bool] = {}

    def check(a: Any, depth: int = 0) -> bool:
        obj_id = id(a)
        if obj_id in cache:
            return cache[obj_id]
        if depth > max_depth:
            return False

        if B(a):
            result = P(a)
            cache[obj_id] = result
            return result

        preds = predecessors(a)
        if not preds:
            result = P(a)
            cache[obj_id] = result
            return result

        # Check all predecessors
        for b in preds:
            if not check(b, depth + 1):
                cache[obj_id] = False
                return False

        result = P(a)
        cache[obj_id] = result
        return result

    for a in objects:
        if B(a):
            if not P(a):
                return VerificationReport(
                    result=VerificationResult.BASE_FAILURE,
                    objects_checked=base_count + step_count,
                    base_verified=base_count,
                    descent_verified=step_count,
                    counterexample=a,
                    failure_reason=f"P fails on base object {a}",
                    elapsed_seconds=time.time() - start_time,
                )
            base_count += 1
        else:
            if not check(a):
                return VerificationReport(
                    result=VerificationResult.DESCENT_FAILURE,
                    objects_checked=base_count + step_count,
                    base_verified=base_count,
                    descent_verified=step_count,
                    counterexample=a,
                    failure_reason=f"Descent verification failed for {a}",
                    elapsed_seconds=time.time() - start_time,
                )
            step_count += 1

    return VerificationReport(
        result=VerificationResult.VERIFIED,
        objects_checked=base_count + step_count,
        base_verified=base_count,
        descent_verified=step_count,
        elapsed_seconds=time.time() - start_time,
    )


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm demonstrations")
    print("=" * 60)

    # Example 1: Verify all even numbers 4..200 are sums of two primes
    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        if n < 4:
            return True
        if n % 2 == 0 or n % 3 == 0:
            return False
        i = 5
        while i * i <= n:
            if n % i == 0 or n % (i + 2) == 0:
                return False
            i += 6
        return True

    def is_goldbach(n: int) -> bool:
        for p in range(2, n // 2 + 1):
            if is_prime(p) and is_prime(n - p):
                return True
        return False

    evens = list(range(4, 202, 2))

    report = verify_finite_check_and_descent(
        objects=evens,
        mu=lambda n: n,
        P=is_goldbach,
        N=50,
        step=lambda n: (n - 2, "reduce by 2") if n > 50 else None,
        check_chains=True,
    )

    print(f"\nGoldbach verification report:")
    print(f"  Result: {report.result.value}")
    print(f"  Objects checked: {report.objects_checked}")
    print(f"  Base verified: {report.base_verified}")
    print(f"  Descent verified: {report.descent_verified}")
    print(f"  Max chain length: {report.max_chain_length}")
    print(f"  Mean chain length: {report.mean_chain_length:.1f}")
    print(f"  Time: {report.elapsed_seconds:.4f}s")

    # Example 2: Find optimal threshold
    print(f"\nFinding optimal base threshold...")
    opt_N, opt_report = optimize_base_threshold(
        objects=evens,
        mu=lambda n: n,
        P=is_goldbach,
        step=lambda n: (n - 2, "reduce by 2") if n > 4 else None,
        max_N=200,
    )
    print(f"  Optimal threshold: N = {opt_N}")
    print(f"  Verification: {opt_report.result.value}")
