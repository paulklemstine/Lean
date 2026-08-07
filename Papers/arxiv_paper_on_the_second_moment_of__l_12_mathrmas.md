# Computational evidence

All numbers below were produced by evaluating rational-arithmetic models inside Lean 4
(`#eval`, exact `ℚ` arithmetic — no floating point).  They were used to test the criteria
before formalising them, and to check the sharpness claims that appear in the docstrings of
`Catalog/Novelty/AsaiMomentApplications.lean`.

The abstract objects tested are the ones the formalisation uses:

* the **Gram matrix** `G(m,n) = ∑_f λ_f(m) · conj(λ_f(n))` of a finite family of eigenvalue
  systems (in the paper: the Hecke eigenvalues of the Asai lifts `As(f)`);
* the **large sieve constant** `C`, i.e. the smallest constant with
  `∑_f |∑_{n<N} a_n λ_f(n)|² ≤ C ∑_{n<N} |a_n|²`;
* the **trivial constant** `∑_{f,n} |λ_f(n)|²` obtained from Cauchy–Schwarz with no
  cancellation.

## Experiment 1 — exactly orthogonal system (Walsh/Hadamard rows, `N = 4`, 4 forms)

`λ_f(n) = H(f,n) ∈ {±1}`, the `4 × 4` Hadamard system.

| quantity | value |
|---|---|
| Gram matrix `G(m,n)` | `4·δ_{m,n}` (computed: diagonal `4`, all off-diagonal `0`) |
| constant from `largeSieve_of_diagonal_gram` | `D = 4` |
| trivial constant `∑_{f,n}|λ_f(n)|²` | `16` |
| observed `∑_f |∑_n a_n λ_f(n)|²` at `a = (1,1,1,1)`, `‖a‖² = 4` | `16`, ratio `= 4` |
| observed ratio at `a = (1,0,0,0)`, `‖a‖² = 1` | `4` |

**Reading.**  The criterion's constant `4` is attained (ratio `4` at two different test
vectors), and the saving over the trivial constant is a factor `16/4 = 4 = N`.  This is the
numerical shadow of `AsaiLargeSieve.largeSieve_gain`, which proves
`(D + eN)·(N/4) ≤ trivial constant` in general.

## Experiment 2 — periodic system (`q = 2`, `N = 4`, two characters)

`λ_f(n) = (-1)^{f n}` for `f ∈ {0,1}`.

| quantity | value |
|---|---|
| Gram matrix | `G(m,n) = 2` if `m ≡ n (mod 2)`, else `0` (computed on all 16 pairs) |
| `D = max |G(m,n)|` | `2` |
| bound of `largeSieve_of_periodic_gram`, `D·(N/q + 1)` | `6` |
| bound of `largeSieve_of_periodic_gram_dvd` (uses `q ∣ N`), `D·(N/q)` | `4` |
| observed `∑_f |∑_n a_n λ_f(n)|² / ‖a‖²` at `a = (1,0,1,0)` | `8/2 = 4` |
| trivial constant | `8` |

**Reading.**  The extremal ratio is exactly `4`, so the sharpened divisible-case constant
`D·(N/q) = 4` is **attained** and cannot be lowered, while the general constant
`D·(N/q + 1) = 6` loses a factor `3/2` here.  This experiment is what motivated proving the
sharpened statement `AsaiLargeSieve.largeSieve_of_periodic_gram_dvd` in addition to the
general one, and it also confirms that the `+1` is a genuine artefact of the counting bound
`card_congruence_class_le` rather than of the analysis.

## Counterexample hunt

* *Is a large sieve constant automatically nonnegative?*  No: with `N = 0` every `C` (even
  negative) is admissible, since both sides vanish.  This is why the duality theorems carry
  the hypothesis `0 ≤ C`, and why the flagship second-moment theorem assumes `1 ≤ N`
  (positivity of `D + eN` is then *derived*, in
  `AsaiSecondMoment.quasiOrthogonal_const_nonneg`).
* *Can quasi-orthogonality hold with a negative error `e`?*  Only when `N = 0`; for `N ≥ 1`
  the definition forces `e ≥ 0` (a norm is bounded by `e`).  This case split is exactly the
  first branch of the proof of `largeSieve_of_quasiOrthogonal`.
* *Is the diagonal of the character Gram matrix equal to `φ(q)`?*  Not always: at non-unit
  residues every character vanishes, so the diagonal entry is `0`.  The formal statement is
  therefore an inequality (`gram_dirichlet_diag_le`), which is what the large sieve needs.

## No OEIS entry

No integer sequence is attached to the objects studied here (the data are matrices of
correlation sums depending on continuous parameters), so no OEIS search was applicable.

## Second cycle: evidence for the sharpened criteria

Both experiments of this cycle are recorded as Lean theorems, so they are machine-checked
rather than merely evaluated.

* *Is the ceiling count `⌈N/q⌉` attained?*  Yes.  For `N = 5`, `q = 2` the class of `0` in
  `[0,5)` is `{0,2,4}`, of size `3 = ⌈5/2⌉`; this is
  `AsaiLargeSieve.card_congruence_class_ceil_attained`, proved by `decide`.  Consequently the
  counting step of the periodic criterion cannot be improved, and the constant
  `D · ⌈N/q⌉` of `largeSieve_of_periodic_gram_ceil` is the best that this route gives.
* *Is the removal of one factor `J` for spectrally separated blocks real, or an artefact?*
  Real.  With `N = J = 2`, unit weights, the two coordinate blocks and an orthonormal system
  (`D = 1`, `e = 0`) the true second moment is `2`, the disjoint bound
  `C · ∑_j |w j|²‖A j‖²` is `2` (equality) and the flagship bound `J²·C·B` is `4`.  This is
  `AsaiSecondMoment.secondMoment_disjoint_attained`.
* *Counterexample hunt for the disjointness hypothesis.*  Without disjointness the identity
  `∑_n |∑_j w j A j n|² = ∑_j |w j|²∑_n |A j n|²` fails: taking `J = 2`, `N = 1`,
  `w = (1,1)`, `A 0 0 = A 1 0 = 1` gives `4` on the left and `2` on the right.  This is why
  the block-index function `b` appears as an explicit hypothesis of
  `sum_normSq_aggregate_of_disjoint` and of every theorem depending on it.

## Third cycle: evidence for the overlap, optimality and Schur-gap results

Again every experiment below is recorded as a machine-checked Lean theorem rather than as an
informal computation.

* *Does the overlap multiplicity really interpolate between `1` and `J`?*  Yes, and both ends
  are attained.  With `N = 1`, `J = 2`, unit weights, both blocks equal to `1` and a single
  form with `λ = 1`, the overlap is `r = 2 = J`, the true second moment is `‖1+1‖² = 4`, and
  the bound `C · r · ∑_j |w j|²‖A j‖²` is `1 · 2 · 2 = 4`: equality
  (`AsaiSecondMoment.secondMoment_overlap_attained`).  At the other end `r = 1` reproduces the
  spectrally separated bound exactly (`secondMoment_overlap_of_disjoint`).  Numerically, for
  `r < J` the new bound `r·J·C·B` is smaller than the flagship `J²·C·B` by the factor `J/r`
  (`secondMoment_overlap_lt_flagship`).
* *Is `D · ⌈N/q⌉` really the optimal periodic constant, or only the best our criterion gives?*
  Optimal.  For the extremal family `resFamily q D` the indicator of the class of `0` has
  mass `k = #{n < N : q ∣ n} ≥ ⌈N/q⌉` and quadratic form `D k²`, forcing `C ≥ D k`
  (`AsaiLargeSieve.le_of_largeSieve_resFamily`).  Example: `q = 2`, `N = 5`, `D = 1` gives
  `k = 3`, quadratic form `9`, mass `3`, hence `C ≥ 3 = 1 · ⌈5/2⌉`, matching the upper bound.
* *Counterexample hunt for the Schur comparison `K_Schur ≤ 2·C_opt`.*  Found.  Take the single
  form with eigenvalues `v = (1, ε, …, ε)`, `ε = 1/m`, `m³` copies of `ε`, so `N = m³ + 1`.
  Then `C_opt = ‖v‖₂² = 1 + m` while the Schur row at `m = 0` is `‖v‖_∞‖v‖₁ = 1 + m²`:

  | `m` | `N` | `C_opt` | `K_Schur` | `K_Schur / C_opt` |
  |----:|----:|--------:|----------:|------------------:|
  |  2  |   9 |       3 |         5 |              1.67 |
  |  4  |  65 |       5 |        17 |              3.40 |
  | 10  |1001 |      11 |       101 |              9.18 |
  | 100 |10⁶+1|     101 |     10001 |             99.02 |

  The ratio is unbounded, so no constant-factor Schur comparison exists
  (`AsaiLargeSieve.schur_row_gap_unbounded`); the second row already refutes the *conjectured*
  constant `2`, since there `K_Schur = 17 > 10 = 2·C_opt`.  The Gram matrix here is `v vᵀ`, Hermitian positive
  semidefinite, so positivity is not the missing hypothesis — diagonal dominance is, and under
  it the constant `2` is proved (`schur_row_le_two_mul_largeSieve_of_dominant`).
* *What replaces the refuted comparison?*  The exponent `1/2`.  For the same rank-one family
  with `ε = 1/m` but only `m²` copies of `ε` (so `N = m² + 1`), the large sieve constant is
  `C = 2` and the Schur row is `1 + m ≥ √N`, i.e. `K_Schur ≥ (√N/2)·C`
  (`AsaiLargeSieve.schur_row_sqrt_attained`); and in the opposite direction every family
  satisfies `K_Schur ≤ √N · C` (`AsaiLargeSieve.schur_row_le_sqrt_mul_largeSieve`).  So the
  ratio `K_Schur / C_opt` lives in `[1, √N]` and both ends are attained up to a factor `2`.

  | `m` | `N = m²+1` | `C` | `K_Schur = 1+m` | `√N` |
  |----:|-----------:|----:|----------------:|-----:|
  |  2  |          5 |   2 |               3 | 2.24 |
  |  5  |         26 |   2 |               6 | 5.10 |
  | 10  |        101 |   2 |              11 |10.05 |
* *Is the factor `r` in the overlap bound real for `1 < r < J`?*  Yes.  Take `N = 1`, `J = 4`,
  unit weights, `c 0 = 1` and active set `act 0 = {0,1}`, so `r = 2`: the aggregated
  coefficient is `2`, the second moment of an orthonormal system (`D = 1`, `e = 0`) is `4`,
  the sum of blockwise masses is `2`, and `D·r·2 = 4` — equality.  The general statement is
  `AsaiSecondMoment.secondMoment_aligned_order`, which pins the second moment between `D/2`
  and `3D/2` times `r·∑_j ‖A j‖²` whenever `2eN ≤ D`.
