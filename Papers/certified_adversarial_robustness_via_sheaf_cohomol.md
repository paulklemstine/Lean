# Computational Evidence — Certified Adversarial Robustness via Sheaf Cohomology

All checks were run with exact rational arithmetic (`ℚ`) to avoid floating-point
ambiguity.

## 1. Path nerve: `H¹ = 0` (gluing is always possible)

Take an overlap-discrepancy 1-cochain on the path nerve of 4 regions
(`g : Fin 3 → ℚ`):

```
g = [3, -1, 4]
```

The explicit primitive `f k = Σ_{j<k} g_j` (the discrete potential used in the
proof of `H1_path_vanishes`) evaluates to

```
f = [0, 3, 2, 6]
```

and its coboundary `(δ⁰ f) i = f(i+1) − f(i)` recovers `g` exactly:

```
δ⁰ f = [3, -1, 4] = g   ✓
```

So every prescribed discrepancy is a coboundary — there is no obstruction on a
tree-shaped cover.

## 2. Cyclic nerve: nonzero holonomy (`H¹ ≠ 0`)

For the loop nerve of `n+1` regions the holonomy of the unit cochain (constant
`1`) is the loop sum:

| regions `n+1` | 1 | 2 | 3 | 4 | 5 | 6 |
|---------------|---|---|---|---|---|---|
| holonomy `Σ 1`| 1 | 2 | 3 | 4 | 5 | 6 |

Every entry is nonzero, so by `cyclic_not_coboundary` the unit cochain is never a
coboundary: the cyclic coboundary map is not surjective, i.e. `H¹ ≠ 0`. This is
the cohomological signature flagged as an adversarial obstruction.

## 3. L∞ certificate sanity check

For weights `w = (2, -1)` and reference `x₀ = (1, 1)`:
`score = 2·1 + (−1)·1 = 1`, `‖w‖₁ = |2| + |−1| = 3`. The certified L∞ radius is
`|score| / ‖w‖₁ = 1/3`. Any perturbation with `‖Δ‖∞ ≤ r < 1/3` changes the score
by at most `3r < 1`, so the sign (= prediction) cannot flip — matching
`linf_certified_radius` / `certified_radius_lower_bound`.

## 4. Counterexample hunt

The converse direction "vulnerable ⟹ nonzero `H¹`" was tested and rejected: a
single region (trivial tree nerve, `H¹ = 0`) with margin `0` is vulnerable at the
boundary, yet its nerve cohomology vanishes. Hence cohomology governs *gluing*,
not the stalk margin — recorded as a boundary condition in the Lab Notes and as a
future direction.

## Scope

No OEIS/LMFDB lookup was needed: the holonomy sequence is simply `n+1`. The
evidence here is intentionally light; the substantive claims are the machine-
checked theorems in `Cohomology.lean`, `Certificate.lean`, and `Bridge.lean`.
