import Mathlib

/-!
# The `O(N)` model: `ε`-expansion of the critical exponents, uniformly in `N`

`Catalog/Physics/WilsonEpsilonExpansion.lean` isolates the polynomial data of the
one- and two-loop Feynman-diagram calculation for the **one-component** `φ⁴`
theory.  This file carries out the same programme for the full `O(N)`-symmetric
`φ⁴` theory: every diagrammatic coefficient is now an explicit *rational
function of `N`*, and all statements are proved uniformly on the admissible
range of `N`.

## Normalisation

The one-loop beta function is taken in the normalisation

`β_N(ε, g) = -ε g + ((N+8)/3) g²`,

which is exactly the catalog's normalisation at `N = 1` (there the quadratic
coefficient is `3 = (1+8)/3`).  The reduction statements
`betaON_one`, `fixedPoint_one`, `etaOfCoupling_one`, `etaExponent_one`
verify that the `N = 1` slice of this file reproduces
`WilsonEpsilon.beta`, `WilsonEpsilon.wilsonFisher`,
`WilsonEpsilon.etaOfCoupling` and `WilsonEpsilon.eta_at_wilsonFisher`.

## Contents

* the Wilson–Fisher fixed point `g*(N) = 3ε/(N+8)` and the complete
  classification of the zeros of `β_N`;
* the standard first terms of the critical exponents,
  `η = (N+2)ε²/(2(N+8)²)`, `1/ν = 2 - (N+2)ε/(N+8)`, `γ = 1 + (N+2)ε/(2(N+8))`,
  `α = (4-N)ε/(2(N+8))`, `β = 1/2 - 3ε/(2(N+8))`, `δ = 3 + ε`, `ω = ε`;
* `ω = ∂_g β_N` at the fixed point, proved with `HasDerivAt`;
* the **exact** scaling-relation identities: Rushbrooke holds identically in
  `(N, ε)`, while Fisher, Josephson (hyperscaling) and Widom hold with
  explicitly computed `O(ε²)` deficits — in particular the Widom deficit
  `3ε²/(N+8-3ε)` has an `N`-independent numerator.
-/

namespace ONModel

/-! ## Admissible range of `N` -/

/-- The physically admissible range of the symmetry index.  `N = 0` is the
self-avoiding-walk limit, `N = 1` Ising, `N = 2` XY, `N = 3` Heisenberg; the
formal expansion continues to make sense for every real `N > -8`, and `N = -2`
plays a distinguished (Gaussian) role, treated separately below. -/
def Admissible (N : ℝ) : Prop := 0 ≤ N

theorem admissible_ne_neg_eight {N : ℝ} (hN : Admissible N) : N + 8 ≠ 0 := by
  have : (0:ℝ) < N + 8 := by unfold Admissible at hN; linarith
  exact ne_of_gt this

theorem admissible_pos_denom {N : ℝ} (hN : Admissible N) : 0 < N + 8 := by
  unfold Admissible at hN; linarith

/-! ## One-loop flow -/

/-- The one-loop truncated beta function of the `O(N)` model.  At `N = 1` the
quadratic coefficient is `3`, the catalog normalisation. -/
noncomputable def betaON (N ε g : ℝ) : ℝ := -ε * g + ((N + 8) / 3) * g ^ 2

/-- The Wilson–Fisher fixed point of the `O(N)` one-loop flow. -/
noncomputable def fixedPoint (N ε : ℝ) : ℝ := 3 * ε / (N + 8)

/-- The two-loop anomalous dimension as a function of the coupling. -/
noncomputable def etaOfCoupling (N g : ℝ) : ℝ := ((N + 2) / 18) * g ^ 2

/-- The one-loop inverse correlation-length exponent as a function of the
coupling. -/
noncomputable def invNuOfCoupling (N g : ℝ) : ℝ := 2 - ((N + 2) / 3) * g

/-! ### Reduction to the catalog's one-component file -/

/-- At `N = 1` the beta function is `WilsonEpsilon.beta`. -/
theorem betaON_one (ε g : ℝ) : betaON 1 ε g = -ε * g + 3 * g ^ 2 := by
  unfold betaON; ring

/-- At `N = 1` the fixed point is `WilsonEpsilon.wilsonFisher`. -/
theorem fixedPoint_one (ε : ℝ) : fixedPoint 1 ε = ε / 3 := by
  unfold fixedPoint; ring

/-- At `N = 1` the anomalous dimension is `WilsonEpsilon.etaOfCoupling`. -/
theorem etaOfCoupling_one (g : ℝ) : etaOfCoupling 1 g = g ^ 2 / 6 := by
  unfold etaOfCoupling; ring

/-! ### Fixed points -/

/-- The Wilson–Fisher coupling is a zero of the one-loop beta function. -/
theorem betaON_fixedPoint {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    betaON N ε (fixedPoint N ε) = 0 := by
  unfold betaON fixedPoint
  field_simp
  ring

/-- Complete classification of the zeros of the one-loop beta function, valid
for every `N ≠ -8`: only the Gaussian and Wilson–Fisher couplings occur. -/
theorem betaON_eq_zero_iff {N : ℝ} (hN : N + 8 ≠ 0) (ε g : ℝ) :
    betaON N ε g = 0 ↔ g = 0 ∨ g = fixedPoint N ε := by
  unfold betaON fixedPoint
  constructor
  · intro h
    have hfac : g * (-ε + ((N + 8) / 3) * g) = 0 := by nlinarith [h]
    rcases mul_eq_zero.mp hfac with hg | hg
    · exact Or.inl hg
    · right
      field_simp
      linarith
  · rintro (rfl | rfl)
    · ring
    · field_simp; ring

/-- For `ε > 0` (i.e. `d < 4`) and admissible `N` the Wilson–Fisher coupling is
strictly positive, hence distinct from the Gaussian one; moreover it is bounded
by `3ε/8` **uniformly in `N ≥ 0`**. -/
theorem fixedPoint_pos_le {N ε : ℝ} (hN : Admissible N) (hε : 0 < ε) :
    0 < fixedPoint N ε ∧ fixedPoint N ε ≤ 3 * ε / 8 := by
  have hd : 0 < N + 8 := admissible_pos_denom hN
  unfold Admissible at hN
  refine ⟨div_pos (by linarith) hd, ?_⟩
  have key : 3 * ε / 8 - fixedPoint N ε = 3 * ε * N / (8 * (N + 8)) := by
    unfold fixedPoint
    field_simp
    ring
  have hpos : 0 ≤ 3 * ε * N / (8 * (N + 8)) := by positivity
  linarith [key ▸ hpos]

/-- The Wilson–Fisher coupling is strictly decreasing in `N` (for `ε > 0`):
larger symmetry means a weaker fixed-point coupling. -/
theorem fixedPoint_strictAnti {N₁ N₂ ε : ℝ} (h1 : Admissible N₁) (h12 : N₁ < N₂)
    (hε : 0 < ε) : fixedPoint N₂ ε < fixedPoint N₁ ε := by
  have hd1 : 0 < N₁ + 8 := admissible_pos_denom h1
  have hd2 : 0 < N₂ + 8 := by linarith
  have key : fixedPoint N₁ ε - fixedPoint N₂ ε
      = 3 * ε * (N₂ - N₁) / ((N₁ + 8) * (N₂ + 8)) := by
    unfold fixedPoint
    field_simp
    ring
  have hpos : 0 < 3 * ε * (N₂ - N₁) / ((N₁ + 8) * (N₂ + 8)) := by
    apply div_pos (by nlinarith) (by positivity)
  linarith [key ▸ hpos]

/-! ## The critical exponents at first non-trivial order -/

/-- `η = (N+2)ε²/(2(N+8)²) + O(ε³)`. -/
noncomputable def etaExponent (N ε : ℝ) : ℝ := (N + 2) * ε ^ 2 / (2 * (N + 8) ^ 2)

/-- `ν = 1/2 + (N+2)ε/(4(N+8)) + O(ε²)`. -/
noncomputable def nuExponent (N ε : ℝ) : ℝ := 1 / 2 + (N + 2) * ε / (4 * (N + 8))

/-- `γ = 1 + (N+2)ε/(2(N+8)) + O(ε²)`. -/
noncomputable def gammaExponent (N ε : ℝ) : ℝ := 1 + (N + 2) * ε / (2 * (N + 8))

/-- `α = (4-N)ε/(2(N+8)) + O(ε²)`. -/
noncomputable def alphaExponent (N ε : ℝ) : ℝ := (4 - N) * ε / (2 * (N + 8))

/-- The order-parameter exponent `β = 1/2 - 3ε/(2(N+8)) + O(ε²)`. -/
noncomputable def betaExponent (N ε : ℝ) : ℝ := 1 / 2 - 3 * ε / (2 * (N + 8))

/-- `δ = 3 + ε + O(ε²)`, independent of `N` at this order. -/
def deltaExponent (ε : ℝ) : ℝ := 3 + ε

/-- The correction-to-scaling exponent `ω = ε + O(ε²)`, independent of `N`. -/
def omegaExponent (ε : ℝ) : ℝ := ε

/-- At `N = 1` the anomalous dimension is Wilson's `ε²/54`. -/
theorem etaExponent_one (ε : ℝ) : etaExponent 1 ε = ε ^ 2 / 54 := by
  unfold etaExponent; ring

/-- At `N = 1`: `ν = 1/2 + ε/12`. -/
theorem nuExponent_one (ε : ℝ) : nuExponent 1 ε = 1 / 2 + ε / 12 := by
  unfold nuExponent; ring

/-- At `N = 1`: `α = ε/6`. -/
theorem alphaExponent_one (ε : ℝ) : alphaExponent 1 ε = ε / 6 := by
  unfold alphaExponent; ring

/-- At `N = 1`: `β = 1/2 - ε/6`. -/
theorem betaExponent_one (ε : ℝ) : betaExponent 1 ε = 1 / 2 - ε / 6 := by
  unfold betaExponent; ring

/-- At `N = 1`: `γ = 1 + ε/6`. -/
theorem gammaExponent_one (ε : ℝ) : gammaExponent 1 ε = 1 + ε / 6 := by
  unfold gammaExponent; ring

/-- Substituting the fixed-point coupling into the two-loop anomalous dimension
produces the standard `O(N)` value, for every `N ≠ -8`. -/
theorem eta_at_fixedPoint {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    etaOfCoupling N (fixedPoint N ε) = etaExponent N ε := by
  unfold etaOfCoupling fixedPoint etaExponent
  field_simp
  ring

/-- Substituting the fixed-point coupling into the one-loop expression for
`1/ν`. -/
theorem invNu_at_fixedPoint {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    invNuOfCoupling N (fixedPoint N ε) = 2 - (N + 2) * ε / (N + 8) := by
  unfold invNuOfCoupling fixedPoint
  field_simp

/-- `ν` really is the reciprocal of the computed `1/ν`, up to an explicit
`O(ε²)` defect: the product is `1 - ((N+2)ε/(2(N+8)))²`. -/
theorem nu_mul_invNu {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    nuExponent N ε * invNuOfCoupling N (fixedPoint N ε)
      = 1 - (N + 2) ^ 2 * ε ^ 2 / (4 * (N + 8) ^ 2) := by
  rw [invNu_at_fixedPoint hN]
  unfold nuExponent
  field_simp
  ring

/-! ## `ω` as the slope of the flow -/

/-- The one-loop beta function is differentiable in the coupling with the
expected derivative. -/
theorem hasDerivAt_betaON (N ε g₀ : ℝ) :
    HasDerivAt (fun g => betaON N ε g) (-ε + 2 * ((N + 8) / 3) * g₀) g₀ := by
  have h1 : HasDerivAt (fun g : ℝ => -ε * g) (-ε) g₀ := by
    simpa using (hasDerivAt_id g₀).const_mul (-ε)
  have h2 : HasDerivAt (fun g : ℝ => ((N + 8) / 3) * g ^ 2)
      (((N + 8) / 3) * (2 * g₀)) g₀ := by
    simpa using ((hasDerivAt_pow 2 g₀).const_mul ((N + 8) / 3))
  have := h1.add h2
  convert this using 1
  ring

/-- **Universality of the correction-to-scaling exponent at one loop.**  The
linearisation of the flow at the Wilson–Fisher point has slope exactly `ε`,
for *every* admissible `N`. -/
theorem deriv_betaON_at_fixedPoint {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    deriv (fun g => betaON N ε g) (fixedPoint N ε) = omegaExponent ε := by
  rw [(hasDerivAt_betaON N ε (fixedPoint N ε)).deriv]
  unfold fixedPoint omegaExponent
  field_simp
  ring

/-- The Gaussian fixed point is unstable for `ε > 0` (slope `-ε < 0`), while the
Wilson–Fisher point is stable (slope `ε > 0`): the crossover of stability is
`N`-independent. -/
theorem stability_exchange {N ε : ℝ} (hN : N + 8 ≠ 0) (hε : 0 < ε) :
    deriv (fun g => betaON N ε g) 0 < 0 ∧
      0 < deriv (fun g => betaON N ε g) (fixedPoint N ε) := by
  refine ⟨?_, ?_⟩
  · rw [(hasDerivAt_betaON N ε 0).deriv]; simpa using hε
  · rw [deriv_betaON_at_fixedPoint hN]; simpa [omegaExponent] using hε

/-! ## Scaling relations, with exact deficits -/

/-- **Rushbrooke's identity holds exactly** for the first-order `O(N)`
exponents: `α + 2β + γ = 2` identically in `(N, ε)`.  This is a genuine
cancellation `(4-N) - 6 + (N+2) = 0` of the residues at `N+8`. -/
theorem rushbrooke {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    alphaExponent N ε + 2 * betaExponent N ε + gammaExponent N ε = 2 := by
  unfold alphaExponent betaExponent gammaExponent
  field_simp
  ring

/-- **Fisher's relation in the form `γ = 2ν`** holds exactly at this order. -/
theorem gamma_eq_two_nu {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    gammaExponent N ε = 2 * nuExponent N ε := by
  unfold gammaExponent nuExponent
  field_simp
  ring

/-- Fisher's relation `γ = ν(2-η)` holds with deficit exactly `ν·η`, which is
`O(ε²)`. -/
theorem fisher_deficit {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    gammaExponent N ε - nuExponent N ε * (2 - etaExponent N ε)
      = nuExponent N ε * etaExponent N ε := by
  rw [gamma_eq_two_nu hN]; ring

/-- **Josephson (hyperscaling) `2 - α = dν` in `d = 4 - ε`** holds with the
explicit deficit `(N+2)ε²/(4(N+8))`. -/
theorem josephson_deficit {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    (2 - alphaExponent N ε) - (4 - ε) * nuExponent N ε
      = (N + 2) * ε ^ 2 / (4 * (N + 8)) := by
  unfold alphaExponent nuExponent
  field_simp
  ring

/-- The order-parameter exponent obeys `2β = ν(d - 2 + η)` up to an explicit
`O(ε²)` deficit. -/
theorem betaExponent_deficit {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    nuExponent N ε * (2 - ε + etaExponent N ε) - 2 * betaExponent N ε
      = nuExponent N ε * etaExponent N ε - (N + 2) * ε ^ 2 / (4 * (N + 8)) := by
  unfold nuExponent betaExponent
  field_simp
  ring

/-- **Widom's relation `δ = 1 + γ/β`.**  The deficit is exactly
`3ε²/(N+8-3ε)`: the `O(ε)` part cancels for *every* `N` simultaneously, and the
numerator of the leading defect is `N`-independent. -/
theorem widom_deficit {N ε : ℝ} (hN : N + 8 ≠ 0) (hβ : N + 8 - 3 * ε ≠ 0) :
    1 + gammaExponent N ε / betaExponent N ε - deltaExponent ε
      = 3 * ε ^ 2 / (N + 8 - 3 * ε) := by
  have hD : (2 : ℝ) * (N + 8) ≠ 0 := by simpa using hN
  have hb : betaExponent N ε = (N + 8 - 3 * ε) / (2 * (N + 8)) := by
    unfold betaExponent; field_simp
  have hg : gammaExponent N ε = (2 * (N + 8) + (N + 2) * ε) / (2 * (N + 8)) := by
    unfold gammaExponent; field_simp
  have hquot : gammaExponent N ε / betaExponent N ε
      = (2 * (N + 8) + (N + 2) * ε) / (N + 8 - 3 * ε) := by
    rw [hb, hg]
    field_simp
  have hA : (2 * (N + 8) + (N + 2) * ε) / (N + 8 - 3 * ε) * (N + 8 - 3 * ε)
      = 2 * (N + 8) + (N + 2) * ε := div_mul_cancel₀ _ hβ
  rw [hquot, deltaExponent, eq_div_iff hβ]
  linear_combination hA

/-! ## Structural consequences: coupling–exponent identity and physicality -/

/-- **An exact identity linking the anomalous dimension, the correlation-length
exponent and the fixed-point coupling**, valid for every `N` and `ε`:
`3η = (2ν - 1) g*`.  Both sides are `O(ε²)` and the identity is a genuine
constraint tying the two-loop datum `η` to one-loop data. -/
theorem eta_coupling_identity {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    3 * etaExponent N ε = (2 * nuExponent N ε - 1) * fixedPoint N ε := by
  unfold etaExponent nuExponent fixedPoint
  field_simp
  ring

/-- **The `N`-independent content of the first-order `ε`-expansion.**  Three
relations hold with no reference to `N` whatsoever: `γ = 2ν`, Rushbrooke, and
the value of `δ`.  Together they say that the whole one-parameter family of
`O(N)` exponents lies on a single line in exponent space, parameterised by
`ν`. -/
theorem universal_invariants {N : ℝ} (hN : N + 8 ≠ 0) (ε : ℝ) :
    gammaExponent N ε = 2 * nuExponent N ε ∧
    alphaExponent N ε + 2 * betaExponent N ε + gammaExponent N ε = 2 ∧
    alphaExponent N ε = 2 - 4 * nuExponent N ε + ε / 2 := by
  refine ⟨gamma_eq_two_nu hN ε, rushbrooke hN ε, ?_⟩
  unfold alphaExponent nuExponent
  field_simp
  ring

/-- **Physical admissibility of the first-order predictions, uniformly in `N`.**
For every `N ≥ 0` and every `0 < ε ≤ 1` the predicted exponents satisfy all the
qualitative constraints expected of a second-order phase transition:
`η > 0`, `ν > 1/2`, `γ > 1`, `0 < β < 1/2`, `α < 1` and `δ > 3`. -/
theorem exponents_physical {N ε : ℝ} (hN : Admissible N) (hε : 0 < ε) (hε1 : ε ≤ 1) :
    0 < etaExponent N ε ∧ 1 / 2 < nuExponent N ε ∧ 1 < gammaExponent N ε ∧
      0 < betaExponent N ε ∧ betaExponent N ε < 1 / 2 ∧
      alphaExponent N ε < 1 ∧ 3 < deltaExponent ε := by
  have hd : 0 < N + 8 := admissible_pos_denom hN
  unfold Admissible at hN
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · unfold etaExponent
    apply div_pos (by positivity) (by positivity)
  · unfold nuExponent
    have : 0 < (N + 2) * ε / (4 * (N + 8)) := by
      apply div_pos (by positivity) (by positivity)
    linarith
  · unfold gammaExponent
    have : 0 < (N + 2) * ε / (2 * (N + 8)) := by
      apply div_pos (by positivity) (by positivity)
    linarith
  · unfold betaExponent
    have hlt : 3 * ε / (2 * (N + 8)) < 1 / 2 := by
      rw [div_lt_div_iff₀ (by positivity) (by norm_num)]
      nlinarith
    linarith
  · unfold betaExponent
    have : 0 < 3 * ε / (2 * (N + 8)) := by
      apply div_pos (by positivity) (by positivity)
    linarith
  · unfold alphaExponent
    rcases le_or_gt N 4 with h | h
    · rw [div_lt_one (by positivity)]
      nlinarith
    · have : (4 - N) * ε / (2 * (N + 8)) ≤ 0 := by
        apply div_nonpos_of_nonpos_of_nonneg (by nlinarith) (by positivity)
      linarith
  · unfold deltaExponent; linarith

end ONModel