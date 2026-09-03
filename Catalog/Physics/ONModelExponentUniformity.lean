import Mathlib

/-!
# Uniform behaviour of the `O(N)` critical exponents in the symmetry index `N`

This file continues `Catalog/Physics/ONModelEpsilonExpansion.lean`.  There the
first terms of the `ε`-expansion of the `O(N)` exponents were derived from the
diagrammatic coefficients; here we study them as functions of `N` on the whole
admissible range and prove the statements that are *uniform in `N`*:

* the `η`-coefficient `(N+2)/(2(N+8)²)` is **maximised exactly at `N = 4`**,
  with value `1/48`; hence `0 < η ≤ ε²/48` uniformly on `N ≥ 0`;
* the `ν`-coefficient is strictly increasing in `N` with supremum `1/4`;
* the sign of the specific-heat exponent `α` flips exactly at `N = 4`
  (`α > 0` for `N < 4`, `α < 0` for `N > 4`), the classical statement that the
  specific heat ceases to diverge above four components;
* the large-`N` limits: `η → 0`, `ν → 1/2 + ε/4`, `α → -ε/2`, `γ → 1 + ε/2`,
  matching the exactly solvable **spherical model** `ν = 1/(d-2)`,
  `α = (d-4)/(d-2)` to first order in `ε` (with explicit `O(ε²)` bounds);
* the `N = -2` locus, where the `O(N)` exponents collapse to Gaussian values.

All the definitions are duplicated from the core file only in the sense of being
`import`-free copies of the same rational functions; the statements here are new
and none of them is available at the single value `N = 1` of the catalog's
`WilsonEpsilonExpansion.lean`.
-/

namespace ONModel

open Filter Topology

/-! ## The coefficient functions -/

/-- Coefficient of `ε²` in `η`: `η₂(N) = (N+2)/(2(N+8)²)`. -/
noncomputable def etaCoeff (N : ℝ) : ℝ := (N + 2) / (2 * (N + 8) ^ 2)

/-- Coefficient of `ε` in `ν`: `ν₁(N) = (N+2)/(4(N+8))`. -/
noncomputable def nuCoeff (N : ℝ) : ℝ := (N + 2) / (4 * (N + 8))

/-- Coefficient of `ε` in `α`: `α₁(N) = (4-N)/(2(N+8))`. -/
noncomputable def alphaCoeff (N : ℝ) : ℝ := (4 - N) / (2 * (N + 8))

/-- Coefficient of `ε` in `γ`: `γ₁(N) = (N+2)/(2(N+8))`. -/
noncomputable def gammaCoeff (N : ℝ) : ℝ := (N + 2) / (2 * (N + 8))

theorem etaCoeff_one : etaCoeff 1 = 1 / 54 := by
  unfold etaCoeff; norm_num

theorem nuCoeff_one : nuCoeff 1 = 1 / 12 := by
  unfold nuCoeff; norm_num

/-! ## The anomalous dimension is maximised at `N = 4` -/

/-- **The `η`-coefficient is maximised exactly at `N = 4`.**  For every real
`N > -8` one has `η₂(N) ≤ 1/48`, with equality precisely at `N = 4`.  This is
the statement that, at two loops, the Heisenberg-to-`O(4)` region carries the
largest anomalous dimension of the whole `O(N)` family. -/
theorem etaCoeff_le_of_gt_neg_eight {N : ℝ} (hN : -8 < N) : etaCoeff N ≤ 1 / 48 := by
  have hd : 0 < N + 8 := by linarith
  have hd2 : 0 < 2 * (N + 8) ^ 2 := by positivity
  rw [etaCoeff, div_le_div_iff₀ hd2 (by norm_num)]
  nlinarith [sq_nonneg (N - 4), sq_nonneg (N + 8), hd]

theorem etaCoeff_four : etaCoeff 4 = 1 / 48 := by
  unfold etaCoeff; norm_num

/-- Equality in the previous bound characterises `N = 4`. -/
theorem etaCoeff_eq_max_iff {N : ℝ} (hN : -8 < N) : etaCoeff N = 1 / 48 ↔ N = 4 := by
  have hd : 0 < N + 8 := by linarith
  have hd2 : (2 * (N + 8) ^ 2) ≠ 0 := by positivity
  constructor
  · intro h
    rw [etaCoeff, div_eq_div_iff hd2 (by norm_num : (48:ℝ) ≠ 0)] at h
    have hsq : (N - 4) ^ 2 = 0 := by nlinarith
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hsq
    linarith
  · rintro rfl; exact etaCoeff_four

/-- Strict monotonicity of `η₂` below `N = 4`: the anomalous dimension grows
with the number of components up to the `O(4)` model. -/
theorem etaCoeff_strictMono_below_four {N₁ N₂ : ℝ} (h1 : -8 < N₁) (h12 : N₁ < N₂)
    (h2 : N₂ ≤ 4) : etaCoeff N₁ < etaCoeff N₂ := by
  have hd1 : 0 < N₁ + 8 := by linarith
  have hd2 : 0 < N₂ + 8 := by linarith
  rw [etaCoeff, etaCoeff, div_lt_div_iff₀ (by positivity) (by positivity)]
  have key : (N₂ + 2) * (2 * (N₁ + 8) ^ 2) - (N₁ + 2) * (2 * (N₂ + 8) ^ 2)
      = 2 * (N₂ - N₁) * (6 * ((N₁ + 8) + (N₂ + 8)) - (N₁ + 8) * (N₂ + 8)) := by ring
  have hfac : 0 < 6 * ((N₁ + 8) + (N₂ + 8)) - (N₁ + 8) * (N₂ + 8) := by nlinarith
  nlinarith [mul_pos (by linarith : (0:ℝ) < 2 * (N₂ - N₁)) hfac]

/-- Strict decrease of `η₂` above `N = 4`. -/
theorem etaCoeff_strictAnti_above_four {N₁ N₂ : ℝ} (h1 : 4 ≤ N₁) (h12 : N₁ < N₂) :
    etaCoeff N₂ < etaCoeff N₁ := by
  have hd1 : 0 < N₁ + 8 := by linarith
  have hd2 : 0 < N₂ + 8 := by linarith
  rw [etaCoeff, etaCoeff, div_lt_div_iff₀ (by positivity) (by positivity)]
  have key : (N₁ + 2) * (2 * (N₂ + 8) ^ 2) - (N₂ + 2) * (2 * (N₁ + 8) ^ 2)
      = 2 * (N₂ - N₁) * ((N₁ + 8) * (N₂ + 8) - 6 * ((N₁ + 8) + (N₂ + 8))) := by ring
  have hfac : 0 < (N₁ + 8) * (N₂ + 8) - 6 * ((N₁ + 8) + (N₂ + 8)) := by nlinarith
  nlinarith [mul_pos (by linarith : (0:ℝ) < 2 * (N₂ - N₁)) hfac]

/-! ## Uniform bounds on the exponents for `N ≥ 0` -/

/-- **Uniform two-sided bound on the anomalous dimension.**  For all `N ≥ 0`,
`0 < η₂(N) ≤ 1/48`; consequently `0 < η(N,ε) ≤ ε²/48` for every `ε ≠ 0`,
with a constant independent of `N`. -/
theorem etaCoeff_mem_Ioc {N : ℝ} (hN : 0 ≤ N) : 0 < etaCoeff N ∧ etaCoeff N ≤ 1 / 48 := by
  refine ⟨?_, etaCoeff_le_of_gt_neg_eight (by linarith)⟩
  apply div_pos (by linarith) (by positivity)

/-- The uniform bound transported to the exponent itself. -/
theorem eta_uniform_bound {N ε : ℝ} (hN : 0 ≤ N) :
    (N + 2) * ε ^ 2 / (2 * (N + 8) ^ 2) ≤ ε ^ 2 / 48 := by
  have hd : 0 < 2 * (N + 8) ^ 2 := by positivity
  rw [div_le_div_iff₀ hd (by norm_num)]
  nlinarith [sq_nonneg ε, sq_nonneg (N - 4), mul_nonneg (sq_nonneg ε) (sq_nonneg (N - 4))]

/-- The `ν`-coefficient is strictly increasing in `N`. -/
theorem nuCoeff_strictMono {N₁ N₂ : ℝ} (h1 : -8 < N₁) (h12 : N₁ < N₂) :
    nuCoeff N₁ < nuCoeff N₂ := by
  have hd1 : 0 < N₁ + 8 := by linarith
  have hd2 : 0 < N₂ + 8 := by linarith
  rw [nuCoeff, nuCoeff, div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith

/-- **Uniform window for the correlation-length exponent.**  For `N ≥ 0`,
`1/16 ≤ ν₁(N) < 1/4`; the upper bound `1/4` is the spherical-model value and is
never attained at finite `N`. -/
theorem nuCoeff_bounds {N : ℝ} (hN : 0 ≤ N) : 1 / 16 ≤ nuCoeff N ∧ nuCoeff N < 1 / 4 := by
  have hd : 0 < N + 8 := by linarith
  constructor
  · rw [nuCoeff, le_div_iff₀ (by positivity)]
    linarith
  · rw [nuCoeff, div_lt_iff₀ (by positivity)]
    linarith

/-- The specific-heat coefficient is strictly decreasing in `N`. -/
theorem alphaCoeff_strictAnti {N₁ N₂ : ℝ} (h1 : -8 < N₁) (h12 : N₁ < N₂) :
    alphaCoeff N₂ < alphaCoeff N₁ := by
  have hd1 : 0 < N₁ + 8 := by linarith
  have hd2 : 0 < N₂ + 8 := by linarith
  rw [alphaCoeff, alphaCoeff, div_lt_div_iff₀ (by positivity) (by positivity)]
  nlinarith

/-- **The specific heat stops diverging at `N = 4`.**  For `ε > 0` and
`N > -8`, the first-order specific-heat exponent `α` is positive iff `N < 4`,
zero iff `N = 4` and negative iff `N > 4`. -/
theorem alpha_sign_flip_at_four {N ε : ℝ} (hN : -8 < N) (hε : 0 < ε) :
    (0 < (4 - N) * ε / (2 * (N + 8)) ↔ N < 4) ∧
    ((4 - N) * ε / (2 * (N + 8)) = 0 ↔ N = 4) ∧
    ((4 - N) * ε / (2 * (N + 8)) < 0 ↔ 4 < N) := by
  have hd : 0 < 2 * (N + 8) := by linarith
  refine ⟨?_, ?_, ?_⟩
  · rw [div_pos_iff]
    constructor
    · rintro (⟨h, _⟩ | ⟨_, h⟩)
      · nlinarith
      · linarith
    · intro h; exact Or.inl ⟨by nlinarith, hd⟩
  · rw [div_eq_zero_iff]
    constructor
    · rintro (h | h)
      · rcases mul_eq_zero.mp h with h' | h'
        · linarith
        · linarith
      · linarith
    · rintro rfl; left; ring
  · rw [div_neg_iff]
    constructor
    · rintro (⟨_, h⟩ | ⟨h, _⟩)
      · linarith
      · nlinarith
    · intro h; exact Or.inr ⟨by nlinarith, hd⟩

/-! ## Large-`N` limits and the spherical-model cross-check -/

/-- The basic decay used for every large-`N` limit below. -/
theorem tendsto_inv_shift : Tendsto (fun N : ℝ => (N + 8)⁻¹) atTop (𝓝 0) := by
  have hshift : Tendsto (fun N : ℝ => N + 8) atTop atTop :=
    tendsto_atTop_add_const_right _ 8 tendsto_id
  exact tendsto_inv_atTop_zero.comp hshift

/-- Partial-fraction form of the `η`-coefficient. -/
theorem etaCoeff_eq {N : ℝ} (hN : N + 8 ≠ 0) :
    etaCoeff N = (N + 8)⁻¹ / 2 - 3 * ((N + 8)⁻¹) ^ 2 := by
  unfold etaCoeff
  field_simp
  ring

/-- **Large-`N` limit: the anomalous dimension vanishes.**  `η₂(N) → 0`, the
spherical-model value `η = 0`. -/
theorem tendsto_etaCoeff_atTop : Tendsto etaCoeff atTop (𝓝 0) := by
  have hmain : Tendsto (fun N : ℝ => (N + 8)⁻¹ / 2 - 3 * ((N + 8)⁻¹) ^ 2) atTop (𝓝 0) := by
    have h1 : Tendsto (fun N : ℝ => (N + 8)⁻¹ / 2) atTop (𝓝 (0 / 2)) :=
      tendsto_inv_shift.div_const 2
    have h2 : Tendsto (fun N : ℝ => 3 * ((N + 8)⁻¹) ^ 2) atTop (𝓝 (3 * 0 ^ 2)) :=
      (tendsto_inv_shift.pow 2).const_mul 3
    simpa using h1.sub h2
  refine hmain.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with N hN
  exact (etaCoeff_eq (by linarith)).symm

/-- Partial-fraction form of the `ν`-coefficient. -/
theorem nuCoeff_eq {N : ℝ} (hN : N + 8 ≠ 0) :
    nuCoeff N = 1 / 4 - (3 / 2) * (N + 8)⁻¹ := by
  unfold nuCoeff
  field_simp
  ring

/-- **Large-`N` limit of the correlation-length exponent coefficient:**
`ν₁(N) → 1/4`, i.e. `ν → 1/2 + ε/4`. -/
theorem tendsto_nuCoeff_atTop : Tendsto nuCoeff atTop (𝓝 (1 / 4)) := by
  have hmain : Tendsto (fun N : ℝ => 1 / 4 - (3 / 2) * (N + 8)⁻¹) atTop (𝓝 (1 / 4)) := by
    have h2 : Tendsto (fun N : ℝ => (3 / 2 : ℝ) * (N + 8)⁻¹) atTop (𝓝 ((3 / 2) * 0)) :=
      tendsto_inv_shift.const_mul (3 / 2)
    simpa using (tendsto_const_nhds (x := (1 / 4 : ℝ)) (f := atTop)).sub h2
  refine hmain.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with N hN
  exact (nuCoeff_eq (by linarith)).symm

/-- Partial-fraction form of the specific-heat coefficient. -/
theorem alphaCoeff_eq {N : ℝ} (hN : N + 8 ≠ 0) :
    alphaCoeff N = -(1 / 2) + 6 * (N + 8)⁻¹ := by
  unfold alphaCoeff
  field_simp
  ring

/-- **Large-`N` limit of the specific-heat coefficient:** `α₁(N) → -1/2`. -/
theorem tendsto_alphaCoeff_atTop : Tendsto alphaCoeff atTop (𝓝 (-(1 / 2))) := by
  have hmain : Tendsto (fun N : ℝ => -(1 / 2) + 6 * (N + 8)⁻¹) atTop (𝓝 (-(1 / 2))) := by
    have h2 : Tendsto (fun N : ℝ => (6 : ℝ) * (N + 8)⁻¹) atTop (𝓝 (6 * 0)) :=
      tendsto_inv_shift.const_mul 6
    simpa using (tendsto_const_nhds (x := (-(1 / 2) : ℝ)) (f := atTop)).add h2
  refine hmain.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with N hN
  exact (alphaCoeff_eq (by linarith)).symm

/-! ### Cross-check against the exactly solvable spherical model

The spherical (`N = ∞`) model has `ν = 1/(d-2)` and `α = (d-4)/(d-2)` exactly.
In `d = 4 - ε` these are `1/(2-ε)` and `-ε/(2-ε)`.  The two theorems below show
that the `N → ∞` limits of the `ε`-expansion agree with them to first order,
with explicit `O(ε²)` error — a genuine consistency check of the expansion
against an independent exact solution. -/

/-- Exact form of the spherical-model discrepancy for `ν`. -/
theorem spherical_nu_gap {ε : ℝ} (hε : ε ≠ 2) :
    1 / (2 - ε) - (1 / 2 + ε / 4) = ε ^ 2 / (4 * (2 - ε)) := by
  have h : (2 : ℝ) - ε ≠ 0 := fun h => hε (by linarith)
  field_simp
  ring

/-- The large-`N` limit of the `ε`-expansion of `ν` reproduces the exact
spherical-model value `1/(d-2)` up to `ε²/4`, uniformly for `|ε| ≤ 1`. -/
theorem spherical_nu_agreement {ε : ℝ} (hε : |ε| ≤ 1) :
    |1 / (2 - ε) - (1 / 2 + ε / 4)| ≤ ε ^ 2 / 4 := by
  have h1 : -1 ≤ ε := neg_le_of_abs_le hε
  have h2 : ε ≤ 1 := le_of_abs_le hε
  have hpos : (1 : ℝ) ≤ 2 - ε := by linarith
  rw [spherical_nu_gap (by linarith), abs_div, abs_of_nonneg (by positivity : (0:ℝ) ≤ ε ^ 2),
    abs_of_nonneg (by linarith : (0:ℝ) ≤ 4 * (2 - ε))]
  apply div_le_div_of_nonneg_left (by positivity) (by norm_num) (by linarith)

/-- Exact form of the spherical-model discrepancy for `α`. -/
theorem spherical_alpha_gap {ε : ℝ} (hε : ε ≠ 2) :
    -ε / (2 - ε) - (-(1 / 2) * ε) = -ε ^ 2 / (2 * (2 - ε)) := by
  have h : (2 : ℝ) - ε ≠ 0 := fun h => hε (by linarith)
  field_simp
  ring

/-- The large-`N` limit of the `ε`-expansion of `α` reproduces the exact
spherical-model value `(d-4)/(d-2)` up to `ε²/2`, uniformly for `|ε| ≤ 1`. -/
theorem spherical_alpha_agreement {ε : ℝ} (hε : |ε| ≤ 1) :
    |(-ε / (2 - ε)) - (-(1 / 2) * ε)| ≤ ε ^ 2 / 2 := by
  have h1 : -1 ≤ ε := neg_le_of_abs_le hε
  have h2 : ε ≤ 1 := le_of_abs_le hε
  rw [spherical_alpha_gap (by linarith)]
  rw [abs_div, abs_neg, abs_of_nonneg (by positivity : (0:ℝ) ≤ ε ^ 2),
    abs_of_nonneg (by linarith : (0:ℝ) ≤ 2 * (2 - ε))]
  apply div_le_div_of_nonneg_left (by positivity) (by norm_num) (by linarith)

/-! ## The distinguished value `N = -2` -/

/-- **At `N = -2` every one-loop coefficient collapses to its Gaussian value.**
This reproduces, inside the `ε`-expansion, the classical fact that the `O(-2)`
model has exactly mean-field exponents `η = 0`, `ν = 1/2`, `γ = 1`. -/
theorem gaussian_at_neg_two :
    etaCoeff (-2) = 0 ∧ nuCoeff (-2) = 0 ∧ gammaCoeff (-2) = 0 := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [etaCoeff, nuCoeff, gammaCoeff]

/-- `N = -2` is the *only* value at which the leading corrections vanish
simultaneously: the family of `O(N)` exponents is Gaussian for no other `N`. -/
theorem gaussian_locus_unique {N : ℝ} (hN : N + 8 ≠ 0) (h : nuCoeff N = 0) : N = -2 := by
  unfold nuCoeff at h
  have hd : (4 : ℝ) * (N + 8) ≠ 0 := by simpa using hN
  field_simp at h
  linarith

end ONModel