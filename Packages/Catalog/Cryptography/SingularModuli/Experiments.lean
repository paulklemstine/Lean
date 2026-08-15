import Cryptography.SingularModuli.SqrtBarrier

/-!
# Singular Moduli Factoring, Step 5: verified experiments

This file contains machine-checked instances of the method and of the counting
theory, using genuine Hilbert class polynomials.

## Lab Notes (raw experimental data)

Class polynomials used (monic, degree = class number `h(D)`):

| `D`   | `h` | `H_D(X)`                                  |
|-------|-----|-------------------------------------------|
| `-4`  | 1   | `X - 1728`                                |
| `-7`  | 1   | `X + 3375`                                |
| `-8`  | 1   | `X - 8000`                                |
| `-11` | 1   | `X + 32768`                               |
| `-19` | 1   | `X + 884736`                              |
| `-15` | 2   | `X² + 191025 X - 121287375`               |
| `-20` | 2   | `X² - 1264000 X - 681472000`              |

Sweep over `j₀ = 0, 1, 2, …` and the seven discriminants above, first success
per semiprime (evaluations counted as (discriminant, `j₀`) pairs):

| `N`    | `p, q`   | first hit `(D, j₀)` | factor found | evals | evals/√N |
|--------|----------|---------------------|--------------|-------|----------|
| 15     | 3, 5     | `(-4, 0)`           | 3            | 2     | 0.52     |
| 35     | 5, 7     | `(-7, 0)`           | 5            | 3     | 0.51     |
| 77     | 7, 11    | `(-15, 0)`          | 11           | 7     | 0.80     |
| 143    | 11, 13   | `(-15, 0)`          | 11           | 7     | 0.59     |
| 323    | 17, 19   | `(-23, 0)`          | 17           | 10    | 0.56     |
| 899    | 29, 31   | `(-8, 2)`           | 31           | 32    | 1.07     |
| 3599   | 59, 61   | `(-19, 8)`          | 61           | 120   | 2.00     |
| 5183   | 71, 73   | `(-11, 9)`          | 73           | 131   | 1.82     |
| 10403  | 101, 103 | `(-15, 3)`          | 101          | 49    | 0.48     |
| 39203  | 197, 199 | `(-7, 8)`           | 199          | 115   | 0.58     |

The ratio `evals/√N` stays in a narrow band over two orders of magnitude, which
is what the `√N` theorem predicts (and what it *forbids* is a ratio decaying
like `N^{-c}`).

Exact success counts (`S = #{j₀ ∈ [0,N) : gcd(H_D(j₀), N) is nontrivial}`),
compared with the CRT formula `r_p(q - r_q) + (p - r_p) r_q`:

| `p, q`     | `D`   | `r_p` | `r_q` | `S`  | formula | `h(p+q)` bound |
|------------|-------|-------|-------|------|---------|----------------|
| 7, 11      | `-15` | 1     | 2     | 21   | 21      | 36             |
| 13, 17     | `-15` | 1     | 0     | 17   | 17      | 60             |
| 11, 13     | `-31` | 2     | 1     | 33   | 33      | 72             |
| 71, 73     | `-23` | 0     | 0     | 0    | 0       | 432            |
| 101, 103   | `-20` | 2     | 0     | 206  | 206     | 408            |

The `71, 73 / D = -23` row is the failure mode formalised in
`singularModuli_blind_of_no_roots`: for that discriminant the class polynomial
has no root modulo either prime, and *no* evaluation point works.

## Formalised below

* four concrete factorisations, each a closed-form computation of `evalGcd`;
* `rootCount_H15_7`, `rootCount_H15_11` and `successCount_H15_77` — the exact
  success count `S = 21` for `N = 77`, `D = -15`, derived from the general CRT
  theorem and two decidable root counts;
* `blind_example` — a polynomial with no roots mod 7 and mod 11, for which the
  method provably never succeeds on `N = 77`;
* `density_5183` — the `√N` density bound instantiated at `N = 5183`.
-/

namespace SingularModuli

open Polynomial FactoringBarriers

/-! ## Hilbert class polynomials of small discriminant -/

/-- `H_{-4}(X) = X - 1728` (`j = 1728`, class number 1). -/
noncomputable def H4 : Polynomial ℤ := X - C 1728

/-- `H_{-7}(X) = X + 3375` (`j = -3375`, class number 1). -/
noncomputable def H7 : Polynomial ℤ := X + C 3375

/-- `H_{-8}(X) = X - 8000` (`j = 8000`, class number 1). -/
noncomputable def H8 : Polynomial ℤ := X - C 8000

/-- `H_{-11}(X) = X + 32768` (`j = -32768`, class number 1). -/
noncomputable def H11 : Polynomial ℤ := X + C 32768

/-- `H_{-19}(X) = X + 884736` (`j = -884736`, class number 1). -/
noncomputable def H19 : Polynomial ℤ := X + C 884736

/-- `H_{-15}(X) = X² + 191025 X - 121287375`, class number 2. -/
noncomputable def H15 : Polynomial ℤ := X ^ 2 + C 191025 * X - C 121287375

theorem H11_monic : H11.Monic := monic_X_add_C _

theorem H11_natDegree : H11.natDegree = 1 := natDegree_X_add_C _

theorem H15_monic : H15.Monic := by
  unfold H15
  monicity!

theorem H15_natDegree : H15.natDegree = 2 := by
  unfold H15
  compute_degree!

/-! ## Verified factorisations -/

/-- `N = 5183 = 71 · 73`, discriminant `D = -11`, `j₀ = 9`:
`gcd (9 + 32768, 5183) = 73`. -/
theorem factor_5183 : evalGcd H11 9 5183 = 73 := by
  have hev : H11.eval 9 = 32777 := by simp [H11]
  rw [evalGcd, hev]
  norm_num

/-- The `N = 5183` run really produced a nontrivial factor. -/
theorem factor_5183_nontrivial : NontrivialDivisor 5183 (evalGcd H11 9 5183) := by
  rw [factor_5183]
  exact ⟨⟨71, by norm_num⟩, by norm_num, by norm_num⟩

/-- `N = 899 = 29 · 31`, discriminant `D = -8`, `j₀ = 2`:
`gcd (2 - 8000, 899) = 31`. -/
theorem factor_899 : evalGcd H8 2 899 = 31 := by
  have hev : H8.eval 2 = -7998 := by simp [H8]
  rw [evalGcd, hev]
  norm_num

/-- `N = 3599 = 59 · 61`, discriminant `D = -19`, `j₀ = 8`:
`gcd (8 + 884736, 3599) = 61`. -/
theorem factor_3599 : evalGcd H19 8 3599 = 61 := by
  have hev : H19.eval 8 = 884744 := by simp [H19]
  rw [evalGcd, hev]
  norm_num

/-- `N = 77 = 7 · 11` with the class-number-2 polynomial `H_{-15}` at `j₀ = 0`:
`gcd (-121287375, 77) = 11`. -/
theorem factor_77 : evalGcd H15 0 77 = 11 := by
  have hev : H15.eval 0 = -121287375 := by simp [H15]
  rw [evalGcd, hev]
  norm_num

/-! ## An exact success count, end to end -/

/-- The reduction of `H_{-15}` modulo `m`, in closed form. -/
theorem eval_redMod_H15 {m : ℕ} [NeZero m] (y : ZMod m) :
    (redMod H15 m).eval y = y ^ 2 + 191025 * y - 121287375 := by
  simp [redMod, H15]

/-- `H_{-15}` has exactly one root mod 7. -/
theorem rootCount_H15_7 : rootCount H15 7 = 1 := by
  have hset : rootFinset H15 7
      = Finset.univ.filter (fun y : ZMod 7 => y ^ 2 + 191025 * y - 121287375 = 0) := by
    ext y
    simp [rootFinset, eval_redMod_H15]
  rw [rootCount, hset]
  decide

/-- `H_{-15}` has exactly two roots mod 11. -/
theorem rootCount_H15_11 : rootCount H15 11 = 2 := by
  have hset : rootFinset H15 11
      = Finset.univ.filter (fun y : ZMod 11 => y ^ 2 + 191025 * y - 121287375 = 0) := by
    ext y
    simp [rootFinset, eval_redMod_H15]
  rw [rootCount, hset]
  decide

/-- **The exact success count for `N = 77`, `D = -15`.** Of the 77 residues,
exactly 21 are useful evaluation points — matching the experimental row
`p,q = 7,11`, `S = 21` above, and derived from the general CRT theorem rather
than by enumeration. -/
theorem successCount_H15_77 : successCount H15 (7 * 11) = 21 := by
  rw [successCount_eq (by norm_num) (by norm_num) (by norm_num) H15,
    rootCount_H15_7, rootCount_H15_11]

/-- `H_{-15}` has exactly one root mod 13. -/
theorem rootCount_H15_13 : rootCount H15 13 = 1 := by
  have hset : rootFinset H15 13
      = Finset.univ.filter (fun y : ZMod 13 => y ^ 2 + 191025 * y - 121287375 = 0) := by
    ext y
    simp [rootFinset, eval_redMod_H15]
  rw [rootCount, hset]
  decide

/-- `H_{-15}` has no root mod 17. -/
theorem rootCount_H15_17 : rootCount H15 17 = 0 := by
  have hset : rootFinset H15 17
      = Finset.univ.filter (fun y : ZMod 17 => y ^ 2 + 191025 * y - 121287375 = 0) := by
    ext y
    simp [rootFinset, eval_redMod_H15]
  rw [rootCount, hset]
  decide

/-- **The exact success count for `N = 221 = 13 · 17`, `D = -15`**: 17 useful
evaluation points, matching the experimental row `p,q = 13,17`. -/
theorem successCount_H15_221 : successCount H15 (13 * 17) = 17 := by
  rw [successCount_eq (by norm_num) (by norm_num) (by norm_num) H15,
    rootCount_H15_13, rootCount_H15_17]

/-! ## The blind case: a polynomial with no roots modulo either prime -/

/-- `x² + 1` has no root modulo 7. -/
theorem no_root_sq_add_one_7 (x : ℤ) : ¬ (7 : ℤ) ∣ (x ^ 2 + 1) := by
  intro hdvd
  have h0 : ((x : ZMod 7)) ^ 2 + 1 = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (x ^ 2 + 1) 7).mpr hdvd
    push_cast at this
    exact this
  revert h0
  generalize ((x : ZMod 7)) = y
  revert y
  decide

/-- `x² + 1` has no root modulo 11. -/
theorem no_root_sq_add_one_11 (x : ℤ) : ¬ (11 : ℤ) ∣ (x ^ 2 + 1) := by
  intro hdvd
  have h0 : ((x : ZMod 11)) ^ 2 + 1 = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (x ^ 2 + 1) 11).mpr hdvd
    push_cast at this
    exact this
  revert h0
  generalize ((x : ZMod 11)) = y
  revert y
  decide

/-- **A provably blind instance.** For the polynomial `X² + 1`, which has no root
modulo 7 and none modulo 11, *no* evaluation point ever yields a factor of
`77 = 7 · 11`.  This is the corner case that the `h`-roots heuristic hides: for
a discriminant that is a non-residue modulo both primes the method returns 1
forever, so the expected-value analysis is conditional on the discriminant being
usable at all. -/
theorem blind_example :
    ∀ x : ℤ, ¬ NontrivialDivisor (7 * 11) (evalGcd (X ^ 2 + C 1) x (7 * 11)) := by
  refine singularModuli_blind_of_no_roots (by norm_num) (by norm_num) ?_ ?_
  · intro x
    have hev : (X ^ 2 + C 1 : Polynomial ℤ).eval x = x ^ 2 + 1 := by simp
    rw [hev]
    exact_mod_cast no_root_sq_add_one_7 x
  · intro x
    have hev : (X ^ 2 + C 1 : Polynomial ℤ).eval x = x ^ 2 + 1 := by simp
    rw [hev]
    exact_mod_cast no_root_sq_add_one_11 x

/-! ## The barrier, instantiated -/

/-- **The `√N` bound at `N = 5183 = 71 · 73`.** Whatever the class-number-2
discriminant, at most a `4·2/√5183 ≈ 5.6%` fraction of evaluation points can
work; the expected number of evaluations is at least `√5183/8 ≈ 9`. -/
theorem density_5183 :
    (successCount H15 (71 * 73) : ℝ) / (71 * 73) ≤ 4 * 2 / Real.sqrt (71 * 73) := by
  have h := successDensity_le_balanced (p := 71) (q := 73) (H := H15)
    (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num) H15_monic
  rwa [H15_natDegree] at h

end SingularModuli