# Computational evidence — Round-7 closures (Tropical catalog)

All data below was produced with `#eval` in Lean 4 (Mathlib v4.28.0) inside this
project's toolchain, before the corresponding theorems were formalised. Each
block states the conjecture it tests and the observed values.

## 1. AGREEMENT: `A(N) = #{a ∈ (ℤ/NZ)ˣ : (a/p) = (a/q)}`

Conjecture: `A(N) = φ(N)/2`, and the agreement set coincides with the level set
`J(a|N) = 1` of the Jacobi symbol.

Columns: `(N, A(N), #{a : (a/p)(a/q) = 1}, φ(N)/2)`

```
[(15, 4, 4, 4), (21, 6, 6, 6), (35, 12, 12, 12),
 (77, 30, 30, 30), (143, 60, 60, 60), (221, 96, 96, 96)]
```

Both refutation points hold on every sample: the count is exactly `φ(N)/2`
(so it is a function of `N` alone), and the agreement set is exactly the
`N`-computable quadratic-character level set. Formalised in
`Catalog/Tropical/Round7AgreementCharacter.lean`
(`agree_card_two_mul`, `mem_agree_iff_jacobiSym`).

## 2. ZDG: nonzero zero divisors of `ℤ/NZ`

Conjecture: `|V| = p + q - 2`.

Columns: `(N, |V| measured, p + q - 2)`

```
[(15, 6, 6), (21, 8, 8), (35, 10, 10), (77, 16, 16),
 (143, 22, 22), (221, 28, 28), (10403, 202, 202)]
```

Exact agreement in all cases, including the balanced semiprime
`10403 = 101 · 103`, where the vertex density is `202/10403 ≈ 0.0194`, close to
the balanced noise floor `2/√N ≈ 0.0196`. Formalised in
`Catalog/Tropical/Round7ZeroDivisorGraph.lean` (`card_vertices`,
`atomic_uniform_success_le`, `noise_floor_lower`).

## 3. STATICRHO: collision index of the static rho walk `x ↦ x² + 1`, seed 2

Conjecture: a collision modulo `p` occurs among the first `p + 1` iterates, and
the gcd of the corresponding difference with `N` returns `p`.

Columns: `(p, q, first colliding pair (i, j))`, then `(N, gcd extracted)`

```
[(5, 7, some (0, 3)), (7, 11, some (1, 2)), (11, 13, some (2, 4)),
 (13, 17, some (0, 4)), (101, 103, some (8, 17))]

[(35, some 5), (77, some 7), (143, some 11), (221, some 13), (10403, some 101)]
```

Every collision occurred well inside the `p + 1` pigeonhole bound (e.g. `j = 17`
for `p = 101`), and every extraction returned the smaller prime — the
correlated-sample "escape" from the density floor is real, and is exactly the
known rho method. Formalised in `Catalog/Tropical/Round7RhoNoiseFloor.lean`
(`exists_collision_mod_p`, `gcd_extract_of_dvd_sub`,
`rho_collision_extracts_factor`).

## 4. DIGITLATTICE: the carry commutator

No search was necessary here: the vector `w = [[0,1],[-1,0]]` satisfies
`Σ w_ij b^{i+j} = b - b = 0` identically in the base `b`, has squared norm `2`,
and has nonzero determinant. Its existence is what makes every factorisation
target non-isolated in the relaxed solution set. This is proved outright (for
all `b` and all targets) in `Catalog/Tropical/Round7DigitLattice.lean`
(`commutator_digitVal`, `exists_spurious_solution`), so no sampling was needed.

## 5. Counterexample hunt

* AGREEMENT with `p = q` (not a semiprime, but the boundary case): `A(p²)`
  degenerates — the two characters coincide and agreement is total. This is why
  the formal statement carries `p ≠ q`; and the odd-prime hypothesis `p ≠ 2` is
  needed because `quadraticChar (ZMod 2)` is trivial on units. The theorem is
  stated with exactly these two hypotheses and no more.
* Noise-floor lower bound `(p+q)² ≥ 4N`: equality is attained iff `p = q`
  (`trace_sq_eq_iff`), so no unbalanced semiprime sits at the floor.
* Degrees: the search over the samples above found no vertex whose degree + 1
  failed to divide `N`, consistent with `factor_recovery_from_degrees`.
