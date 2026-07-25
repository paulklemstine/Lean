# Computational evidence

## Small cases

In Rydberg units the first four bound levels are

| principal number `n` | `-1/n²` |
|---:|---:|
| 1 | -1 |
| 2 | -1/4 |
| 3 | -1/9 |
| 4 | -1/16 |

These exact calculations are machine-checked by `first_four_bound_energies` in
`HydrogenSpectralConnector.lean`.  They increase and remain negative, consistent
with convergence to the ionization threshold zero; the universal monotonicity
and convergence claims are also proved there.

For orbital angular momentum, allowed `Δl = ±1` transitions alternate parity:
`0 → 1 → 2 → 3`.  A two-step path returns to the initial parity, while a
three-step path changes it.  The theorem `dipole_walk_parity` proves this for
every finite path, not merely these examples.

## OEIS search

The shell degeneracies `1, 4, 9, 16, ...` are the square numbers, OEIS A000290.
The present connector focuses on transition-graph parity rather than reproving
the standard shell-degeneracy sum.

## Counterexample hunt

Potential edge cases are `l = 0`, equal endpoints, and walks that backtrack.
The condition `Δl = ±1` excludes equal-`l` edges, including `0 → 0`; backtracking
gives an even closed walk and is correctly permitted.  No odd closed walk can
occur, as proved by `no_odd_closed_dipole_walk`.

## Table of path parity

| number of dipole steps | endpoint parity relation |
|---:|:---|
| 0 | same |
| 1 | different |
| 2 | same |
| 3 | different |
| `k` | different exactly when `k` is odd |
