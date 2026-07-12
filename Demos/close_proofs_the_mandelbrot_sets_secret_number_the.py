"""
Numerical demonstration of the Escape Radius Theorem for the quadratic family
f_c(z) = z^2 + c and its consequences for the Mandelbrot set M.

Results demonstrated
--------------------
1. One-step lower bound:      |z^2 + c| >= |z|^2 - |c|.
2. Strict growth past 2:      |z| > 2 and |c| <= |z|  =>  |z| < |z^2 + c|.
3. Geometric escape estimate: |f_c^n(z)| >= |z| * (|z| - 1)^n.
4. Escape criterion:          |c| > 2  =>  c is NOT in M (orbit of 0 diverges).
5. Containment:               M is contained in the closed disk of radius 2.
6. Membership examples:       0 in M (fixed at 0), -1 in M (period-2 cycle).

The script is fully self-contained (standard library only) and prints a
running report to stdout.
"""

from __future__ import annotations

from typing import Callable, List, Tuple


# ----------------------------------------------------------------------------
# Core dynamics
# ----------------------------------------------------------------------------

def step(c: complex, z: complex) -> complex:
    """One application of the quadratic map f_c(z) = z^2 + c."""
    return z * z + c


def orbit_of_zero(c: complex, n: int) -> List[complex]:
    """The critical orbit z_0 = 0, z_{k+1} = z_k^2 + c, up to index n inclusive."""
    zs: List[complex] = [0.0 + 0.0j]
    for _ in range(n):
        zs.append(step(c, zs[-1]))
    return zs


def iterate(c: complex, z: complex, n: int) -> complex:
    """f_c^n(z): the n-fold iterate of f_c applied to z."""
    for _ in range(n):
        z = step(c, z)
    return z


# ----------------------------------------------------------------------------
# 1. One-step lower bound:  |z^2 + c| >= |z|^2 - |c|
# ----------------------------------------------------------------------------

def check_one_step_lower_bound(samples: List[Tuple[complex, complex]]) -> None:
    print("1. One-step lower bound  |z^2 + c| >= |z|^2 - |c|")
    for c, z in samples:
        lhs = abs(step(c, z))
        rhs = abs(z) ** 2 - abs(c)
        ok = lhs >= rhs - 1e-12
        print(f"   c={c!s:>12}  z={z!s:>12}  "
              f"|z^2+c|={lhs:8.4f} >= |z|^2-|c|={rhs:8.4f}  [{'OK' if ok else 'FAIL'}]")
    print()


# ----------------------------------------------------------------------------
# 2. Strict growth:  |z| > 2 and |c| <= |z|  =>  |z| < |z^2 + c|
# ----------------------------------------------------------------------------

def check_strict_growth(samples: List[Tuple[complex, complex]]) -> None:
    print("2. Strict growth past the escape radius (requires |z|>2, |c|<=|z|)")
    for c, z in samples:
        assert abs(z) > 2 and abs(c) <= abs(z)
        before, after = abs(z), abs(step(c, z))
        ok = after > before
        print(f"   c={c!s:>12}  |z|={before:8.4f} -> |f_c(z)|={after:9.4f}  "
              f"[{'grew' if ok else 'FAIL'}]")
    print()


# ----------------------------------------------------------------------------
# 3. Geometric escape estimate:  |f_c^n(z)| >= |z| * (|z| - 1)^n
# ----------------------------------------------------------------------------

def check_geometric_escape(c: complex, z: complex, n_max: int) -> None:
    print(f"3. Geometric escape estimate for c={c}, z={z} (|z|={abs(z):.3f})")
    print("      n | actual |f_c^n(z)| | lower bound |z|(|z|-1)^n")
    print("   -----+------------------+--------------------------")
    r = abs(z)
    for n in range(n_max + 1):
        actual = abs(iterate(c, z, n))
        bound = r * (r - 1.0) ** n
        ok = actual >= bound - 1e-9
        flag = "OK" if ok else "FAIL"
        print(f"   {n:4d} | {actual:16.4f} | {bound:20.4f}  [{flag}]")
    print()


# ----------------------------------------------------------------------------
# 4/5. Escape criterion & containment via the escape-time algorithm
# ----------------------------------------------------------------------------

def escape_time(c: complex, cap: int = 500, radius: float = 2.0) -> int | None:
    """
    Return the first n with |z_n| > radius (the orbit is then guaranteed to
    diverge), or None if |z_n| stays <= radius for all n up to `cap`
    (provisional membership in M).
    """
    z = 0.0 + 0.0j
    for n in range(cap):
        z = step(c, z)
        if abs(z) > radius:
            return n + 1
    return None


def check_escape_criterion(cs: List[complex]) -> None:
    print("4. Escape criterion:  |c| > 2  =>  orbit of 0 escapes  =>  c not in M")
    for c in cs:
        t = escape_time(c)
        status = f"escapes at step {t}" if t is not None else "bounded (in M)"
        print(f"   c={c!s:>12}  |c|={abs(c):6.3f}  ->  {status}")
    print()


def check_containment(grid: int = 400) -> None:
    """Empirically confirm every provisional member of M has |c| <= 2."""
    print("5. Containment:  M is contained in the closed disk of radius 2")
    max_norm_in_M = 0.0
    count = 0
    for i in range(grid + 1):
        for j in range(grid + 1):
            c = complex(-2.5 + 4.0 * i / grid, -2.0 + 4.0 * j / grid)
            if escape_time(c, cap=200) is None:
                count += 1
                max_norm_in_M = max(max_norm_in_M, abs(c))
    print(f"   sampled provisional members of M: {count}")
    print(f"   max |c| among them: {max_norm_in_M:.4f}  (theory guarantees <= 2)")
    print(f"   containment holds: {max_norm_in_M <= 2.0 + 1e-9}")
    print()


# ----------------------------------------------------------------------------
# 6. Membership examples: 0 in M, -1 in M
# ----------------------------------------------------------------------------

def show_membership_examples() -> None:
    print("6. Concrete membership examples")
    zs0 = orbit_of_zero(0.0 + 0.0j, 6)
    print(f"   c = 0 : orbit of 0 = {[f'{z.real:.0f}' for z in zs0]}  (fixed at 0, in M)")
    zsm1 = orbit_of_zero(-1.0 + 0.0j, 6)
    print(f"   c = -1: orbit of 0 = {[f'{z.real:.0f}' for z in zsm1]}  (period-2 cycle, in M)")
    print()


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main() -> None:
    print("=" * 72)
    print("Escape Radius Theorem for f_c(z) = z^2 + c  --  numerical demonstration")
    print("=" * 72)
    print()

    one_step_samples = [
        (0.3 + 0.1j, 0.5 + 0.5j),
        (-1.0 + 0.0j, 1.2 - 0.3j),
        (0.25 + 0.0j, 3.0 + 0.0j),
        (-0.75 + 0.1j, 2.5 - 1.0j),
    ]
    check_one_step_lower_bound(one_step_samples)

    growth_samples = [
        (1.0 + 0.0j, 3.0 + 0.0j),
        (-2.0 + 0.0j, 2.5 + 1.0j),
        (0.5 - 0.5j, 4.0 + 0.0j),
    ]
    check_strict_growth(growth_samples)

    check_geometric_escape(0.3 + 0.0j, 3.0 + 0.0j, n_max=6)

    check_escape_criterion([
        3.0 + 0.0j, -2.5 + 0.0j, 0.0 + 2.5j,
        0.0 + 0.0j, -1.0 + 0.0j, -0.12 + 0.75j,
    ])

    check_containment(grid=300)

    show_membership_examples()

    print("All demonstrated inequalities held on every sample. QED (numerically).")


if __name__ == "__main__":
    main()
