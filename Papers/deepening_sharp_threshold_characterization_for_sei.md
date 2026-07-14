# Computational evidence — Seidel energy of `K_{m,n}` under two-edge deletion

All quantities below are exact, taken from the closed forms **proved** in
`SeidelEnergyTwoDeletions.lean`. Let `N = m + n`.

* Base graph `K_{m,n}` (proved `seidelEnergy_Kmn`): Seidel energy `E₀ = 2(N-1)`.
* `K_{m,n}` minus **two independent (vertex-disjoint) cross edges** (proved
  `Sddel2_energy`, valid for `m,n ≥ 2`, `N ≥ 5`): Seidel energy
  `E₂ = N + √((N+2)² - 32)`.

For reference, `K_{m,n}` minus a **single** cross edge (sibling file
`SeidelEnergyDeletion.lean`): `E₁ = (N-2) + √((N-2)(N+6))`.

## Small-case table (exact)

| `(m,n)` | `N` | `E₀ = 2(N-1)` | `E₁` (one edge) | `E₂ = N + √((N+2)²-32)` | `E₂ - E₀` |
|---------|-----|---------------|-----------------|--------------------------|-----------|
| `(2,3)` | 5   | 8             | `3 + √55 ≈ 10.416` | `5 + √17 ≈ 9.123`     | `> 0`     |
| `(2,4)` | 6   | 10            | `4 + √48 ≈ 10.928` | `6 + √32 ≈ 11.657`    | `> 0`     |
| `(3,3)` | 6   | 10            | `4 + √48 ≈ 10.928` | `6 + √32 ≈ 11.657`    | `> 0`     |
| `(2,5)` | 7   | 12            | `5 + √65 ≈ 13.062` | `7 + √49 = 14`        | `= 2`     |
| `(3,4)` | 7   | 12            | `5 + √65 ≈ 13.062` | `7 + √49 = 14`        | `= 2`     |
| `(4,4)` | 8   | 14            | `6 + √84 ≈ 15.165` | `8 + √68 ≈ 16.246`    | `> 0`     |
| `(3,5)` | 8   | 14            | `6 + √84 ≈ 15.165` | `8 + √68 ≈ 16.246`    | `> 0`     |

A pleasant exact point: at `N = 7` the discriminant `(N+2)² - 32 = 49` is a
perfect square, so `E₂ = 14` exactly for `K_{2,5}` and `K_{3,4}`.

## The threshold question (the point of the deepening)

The single-edge increase `E₁ > E₀` is equivalent to `N ≥ 4` (a genuinely sharp
threshold, refuting the "both parts `≥ 3`" conjecture already for `K_{2,2}`).

For **two independent edges** the analogous inequality `E₂ > E₀` reduces to
`√((N+2)² - 32) > N - 2`, i.e. (squaring, both sides positive for `N ≥ 5`) to
`(N+2)² - 32 > (N-2)²`, i.e. `8N - 32 > 0`, i.e. `N > 4`. Since two disjoint
cross edges only exist when `m,n ≥ 2` (hence `N ≥ 4`) and the non-degenerate
regime is `N ≥ 5`, the inequality holds for **every** admissible `(m,n)`:

> There is *no threshold obstruction* for the two-edge deletion — the Seidel
> energy strictly increases whenever two vertex-disjoint edges can be removed.

This is exactly `seidel_two_deletions_increase`.

## Counterexample hunt

We searched for admissible `(m,n)` (`m,n ≥ 2`, `N ≥ 5`) with `E₂ ≤ E₀`. The
algebraic reduction above shows the surplus is
`E₂ - E₀ = (N - 2)·(√((N+2)²-32)/(N-2) - 1) > 0` for all `N ≥ 5`, so **no
counterexample exists**; the formal proof `seidel_two_deletions_increase`
certifies this for all `m,n`.

## OEIS

The integer base energies `2(N-1)` are just the even numbers; no nontrivial
sequence arises. The interesting content is the analytic surplus, not an integer
sequence, so no OEIS entry is relevant.
