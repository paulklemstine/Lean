#!/usr/bin/env python3
"""Numerical illustrations of finite-horizon shadowing bounds.

The calculations illustrate exact inequalities using Decimal arithmetic. They are
not substitutes for directed-rounding certificates for a particular processor.
"""

from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal, getcontext
from typing import Callable, Iterable, Sequence

getcontext().prec = 80
D = Decimal


@dataclass(frozen=True)
class AuditRow:
    """One row of a pseudo-orbit audit."""

    step: int
    reported: Decimal
    reference: Decimal
    discrepancy: Decimal
    local_defect: Decimal
    bound: Decimal


def geometric_bounds(delta: Decimal, lipschitz: Decimal, horizon: int) -> list[Decimal]:
    """Return B_0,...,B_horizon where B_(n+1)=delta+L B_n."""
    if delta < 0 or lipschitz < 0 or horizon < 0:
        raise ValueError("delta, lipschitz, and horizon must be nonnegative")
    bounds = [D(0)]
    for _ in range(horizon):
        bounds.append(delta + lipschitz * bounds[-1])
    return bounds


def logistic(x: Decimal) -> Decimal:
    """The parameter-four logistic map."""
    return D(4) * x * (D(1) - x)


def iterate(function: Callable[[Decimal], Decimal], x0: Decimal, horizon: int) -> list[Decimal]:
    """Iterate a Decimal-valued map from x0 through the requested horizon."""
    if horizon < 0:
        raise ValueError("horizon must be nonnegative")
    values = [x0]
    for _ in range(horizon):
        values.append(function(values[-1]))
    return values


def perturbed_orbit(
    function: Callable[[Decimal], Decimal],
    x0: Decimal,
    perturbations: Sequence[Decimal],
) -> list[Decimal]:
    """Generate x_(n+1)=f(x_n)+r_n for specified local perturbations."""
    values = [x0]
    for error in perturbations:
        values.append(function(values[-1]) + error)
    return values


def audit_orbit(
    function: Callable[[Decimal], Decimal],
    reported: Sequence[Decimal],
    lipschitz: Decimal,
) -> list[AuditRow]:
    """Audit local defects and compare with the same-start reference orbit."""
    if not reported:
        raise ValueError("reported orbit must be nonempty")
    if lipschitz < 0:
        raise ValueError("lipschitz must be nonnegative")
    defects = [abs(reported[n + 1] - function(reported[n])) for n in range(len(reported) - 1)]
    delta = max(defects, default=D(0))
    bounds = geometric_bounds(delta, lipschitz, len(reported) - 1)
    reference = iterate(function, reported[0], len(reported) - 1)
    rows: list[AuditRow] = []
    for n, (x, y) in enumerate(zip(reported, reference)):
        local = D(0) if n == 0 else defects[n - 1]
        rows.append(AuditRow(n, x, y, abs(x - y), local, bounds[n]))
    return rows


def logistic_required_delta(epsilon: Decimal, horizon: int) -> Decimal:
    """Largest delta certified by delta*(4^N-1) <= 3*epsilon."""
    if epsilon < 0 or horizon < 0:
        raise ValueError("epsilon and horizon must be nonnegative")
    if horizon == 0:
        return Decimal("Infinity")
    return D(3) * epsilon / (D(4) ** horizon - D(1))


def logistic_certified_horizon(delta: Decimal, epsilon: Decimal, cap: int = 100_000) -> int:
    """Largest N <= cap satisfying the logistic global precision certificate."""
    if delta < 0 or epsilon < 0 or cap < 0:
        raise ValueError("delta, epsilon, and cap must be nonnegative")
    if delta == 0:
        return cap
    horizon = 0
    power = D(1)
    while horizon < cap:
        candidate = power * D(4)
        if delta * (candidate - D(1)) > D(3) * epsilon:
            break
        power = candidate
        horizon += 1
    return horizon


def print_table(rows: Iterable[AuditRow], digits: int = 5) -> None:
    """Print a compact audit table."""
    print(f"{'n':>3} {'discrepancy':>16} {'local defect':>16} {'bound':>16}")
    for row in rows:
        print(
            f"{row.step:3d} {row.discrepancy:.{digits}E} "
            f"{row.local_defect:.{digits}E} {row.bound:.{digits}E}"
        )


def contraction_demo() -> None:
    """Show a perturbed contraction remaining below delta/(1-L)."""
    factor, delta, horizon = D("0.8"), D("1e-12"), 30
    function = lambda x: factor * x
    perturbations = [delta if n % 2 == 0 else -delta for n in range(horizon)]
    reported = perturbed_orbit(function, D("0.75"), perturbations)
    rows = audit_orbit(function, reported, factor)
    uniform = delta / (D(1) - factor)
    print("\nCONTRACTION: L=0.8, delta=1e-12")
    print_table(rows[:8])
    print(f"uniform theorem bound: {uniform:.5E}")
    assert all(row.discrepancy <= row.bound for row in rows)
    assert all(row.discrepancy <= uniform for row in rows)


def logistic_demo() -> None:
    """Show the factor-four certificate and its rapid growth."""
    delta, horizon = D("1e-16"), 12
    perturbations = [delta if n % 2 == 0 else -delta for n in range(horizon)]
    reported = perturbed_orbit(logistic, D("0.123456789"), perturbations)
    rows = audit_orbit(logistic, reported, D(4))
    print("\nLOGISTIC MAP: bounded injected local defects")
    print_table(rows)
    assert all(row.discrepancy <= row.bound for row in rows)
    epsilon = D("1e-10")
    certified = logistic_certified_horizon(delta, epsilon)
    print(f"largest certified N for delta={delta} and epsilon={epsilon}: {certified}")
    print(f"required delta at N=20: {logistic_required_delta(epsilon, 20):.5E}")
    assert certified == 10


def residual_demo() -> None:
    """Demonstrate a residual update with the certified factor 1+L."""
    residual_lipschitz = D("0.1")
    full_factor = D(1) + residual_lipschitz
    delta, horizon = D("1e-8"), 15
    function = lambda z: z + residual_lipschitz * z
    perturbations = [delta for _ in range(horizon)]
    reported = perturbed_orbit(function, D("0.2"), perturbations)
    rows = audit_orbit(function, reported, full_factor)
    print("\nRESIDUAL SYSTEM: F(z)=z+0.1z")
    print_table(rows[:10])
    assert all(row.discrepancy <= row.bound for row in rows)


def main() -> None:
    contraction_demo()
    logistic_demo()
    residual_demo()


if __name__ == "__main__":
    main()
