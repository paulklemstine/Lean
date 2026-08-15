/-
# The Noise-Floor Principle, Part VI: the minimax spectrum

Round-6 hypothesis closure, Phase A, cycle 3.

Parts I–V computed the noise floor of a *given* spectrum.  Here we solve the
adversarial problem: among all nonnegative spectra of prescribed total signal
energy `S` on `n` modes, which one is hardest to learn?

**Answer: the isotropic one.**  The floor is a concave, permutation-symmetric
functional of the spectrum, so it is maximised at the flat spectrum
`a i = S / n`, and the worst-case (minimax) irreducible risk is exactly

  `S b n / (S + n b)`  —  the harmonic combination of the signal energy `S`
                          and the saturation level `n b`.

Concretely: with little data (`n b ≫ S`) the minimax risk is `≈ S`, nothing is
learnable; with much data (`n b ≪ S`) it is `≈ n b`, one noise unit per mode.
The crossover is at `S = n b`, matching the per-mode threshold of Part II.

The engine is the *tangent-line trick* for the concave profile
`f x = x b /(x + b)`: `f x ≤ f c + f' c · (x - c)` with the exact remainder
`b² (x - c)² / ((c+b)² (x+b))`.

## Main results

* `tangent_bound`            — the tangent-line inequality with exact remainder
* `noiseFloor_le_flat`       — Jensen: no spectrum of energy `S` beats the flat one
* `noiseFloor_flat_value`    — the flat floor equals `S b n / (S + n b)`
* `isGreatest_noiseFloor_of_energy` — the minimax value, attained
* `minimax_le_min`           — the minimax risk is below both `S` and `n b`
* `effDim_sum_type`          — additivity of the effective dimension over a
                               direct sum of independent tasks
-/
import Mathlib
import MachineLearning.NoiseFloor.EffectiveDimension
import MachineLearning.NoiseFloor.NoiseFloorPrinciple

namespace Catalog.MachineLearning.NoiseFloor

open Finset

variable {ι : Type*} [Fintype ι]

section Tangent

/-- **Tangent-line bound with exact remainder.**  For the concave profile
`f x = x b / (x + b)` and any base point `c ≥ 0`,
`f x = f c + f' c (x - c) - b² (x-c)² / ((c+b)²(x+b))`. -/
lemma tangent_identity {x c b : ℝ} (hx : 0 ≤ x) (hc : 0 ≤ c) (hb : 0 < b) :
    c * b / (c + b) + b ^ 2 / (c + b) ^ 2 * (x - c) - x * b / (x + b)
      = b ^ 2 * (x - c) ^ 2 / ((c + b) ^ 2 * (x + b)) := by
  have h1 : 0 < c + b := by linarith
  have h2 : 0 < x + b := by linarith
  field_simp
  ring

/-- The tangent-line inequality: a concave profile lies below its tangents. -/
lemma tangent_bound {x c b : ℝ} (hx : 0 ≤ x) (hc : 0 ≤ c) (hb : 0 < b) :
    x * b / (x + b) ≤ c * b / (c + b) + b ^ 2 / (c + b) ^ 2 * (x - c) := by
  have h1 : 0 < c + b := by linarith
  have h2 : 0 < x + b := by linarith
  have hid := tangent_identity hx hc hb
  have hnn : 0 ≤ b ^ 2 * (x - c) ^ 2 / ((c + b) ^ 2 * (x + b)) := by positivity
  linarith

end Tangent

section Minimax

variable {a : ι → ℝ} {b S : ℝ}

/-- **Jensen for the noise floor.**  Among spectra of total energy `S`, the flat
spectrum maximises the floor. -/
theorem noiseFloor_le_flat [Nonempty ι] (ha : ∀ i, 0 ≤ a i) (hb : 0 < b)
    (hS : ∑ i, a i = S) :
    noiseFloor a b ≤ (Fintype.card ι : ℝ) * ((S / Fintype.card ι) * b /
      (S / Fintype.card ι + b)) := by
  have hcard : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  have hS0 : 0 ≤ S := hS ▸ Finset.sum_nonneg fun i _ => ha i
  set c : ℝ := S / (Fintype.card ι : ℝ) with hc
  have hc0 : 0 ≤ c := by positivity
  have hstep : noiseFloor a b
      ≤ ∑ _i : ι, (c * b / (c + b)) + b ^ 2 / (c + b) ^ 2 * (∑ i, a i - (Fintype.card ι : ℝ) * c) := by
    rw [noiseFloor_eq_sum]
    have := Finset.sum_le_sum
      (fun i (_ : i ∈ univ) => tangent_bound (ha i) hc0 hb (x := a i) (c := c))
    calc ∑ i, a i * b / (a i + b)
        ≤ ∑ i, (c * b / (c + b) + b ^ 2 / (c + b) ^ 2 * (a i - c)) := this
      _ = ∑ _i : ι, (c * b / (c + b))
            + b ^ 2 / (c + b) ^ 2 * (∑ i, a i - (Fintype.card ι : ℝ) * c) := by
          rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_sub_distrib,
            Finset.sum_const, nsmul_eq_mul, Finset.card_univ, Finset.sum_const,
            nsmul_eq_mul, Finset.card_univ]
  have hzero : ∑ i, a i - (Fintype.card ι : ℝ) * c = 0 := by
    rw [hS, hc]
    field_simp
    ring
  rw [hzero, mul_zero, add_zero, Finset.sum_const, nsmul_eq_mul, Finset.card_univ] at hstep
  exact hstep

/-- The flat spectrum of energy `S` realises the value `S b n / (S + n b)`. -/
theorem noiseFloor_flat_value [Nonempty ι] (hb : 0 < b) (hS0 : 0 ≤ S) :
    noiseFloor (fun _ : ι => S / (Fintype.card ι : ℝ)) b
      = S * b * (Fintype.card ι : ℝ) / (S + (Fintype.card ι : ℝ) * b) := by
  have hcard : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  have hden : 0 < S + (Fintype.card ι : ℝ) * b := by positivity
  rw [noiseFloor_eq_sum, Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
  have hd : S / (Fintype.card ι : ℝ) + b > 0 := by positivity
  field_simp

/-- **The minimax noise floor.**  `S b n / (S + n b)` is the greatest value the
noise floor can take on spectra of energy `S`, and it is attained (by the flat
spectrum).  Equivalently: the value of the game "adversary picks the signal of
energy `S`, learner picks the spectral filter" is `S b n / (S + n b)`. -/
theorem isGreatest_noiseFloor_of_energy [Nonempty ι] (hb : 0 < b) (hS0 : 0 ≤ S) :
    IsGreatest {r : ℝ | ∃ a : ι → ℝ, (∀ i, 0 ≤ a i) ∧ (∑ i, a i = S) ∧ noiseFloor a b = r}
      (S * b * (Fintype.card ι : ℝ) / (S + (Fintype.card ι : ℝ) * b)) := by
  have hcard : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  constructor
  · refine ⟨fun _ => S / (Fintype.card ι : ℝ), fun i => by positivity, ?_, ?_⟩
    · rw [Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
      field_simp
    · exact noiseFloor_flat_value hb hS0
  · rintro r ⟨a, ha, hsum, rfl⟩
    have h := noiseFloor_le_flat ha hb hsum
    have hval := noiseFloor_flat_value (ι := ι) hb hS0
    rw [noiseFloor_eq_sum, Finset.sum_const, nsmul_eq_mul, Finset.card_univ] at hval
    rw [← hval]
    exact h

/-- The minimax risk sits below both the "learn nothing" value `S` and the
saturation value `n b`; both regimes are visible in the harmonic form. -/
theorem minimax_le_min [Nonempty ι] (hb : 0 < b) (hS0 : 0 ≤ S) :
    S * b * (Fintype.card ι : ℝ) / (S + (Fintype.card ι : ℝ) * b)
      ≤ min S ((Fintype.card ι : ℝ) * b) := by
  have hcard : (0 : ℝ) < (Fintype.card ι : ℝ) := by exact_mod_cast Fintype.card_pos
  have hden : 0 < S + (Fintype.card ι : ℝ) * b := by positivity
  refine le_min ?_ ?_
  · rw [div_le_iff₀ hden]
    nlinarith [mul_nonneg hS0 hS0]
  · rw [div_le_iff₀ hden]
    nlinarith [mul_nonneg (mul_nonneg hcard.le hb.le) (mul_nonneg hcard.le hb.le)]

end Minimax

section DirectSum

/-- **Additivity over independent tasks.**  The effective dimension of a direct
sum of two independent spectra is the sum of the effective dimensions: the noise
floor is extensive. -/
theorem effDim_sum_type {κ : Type*} [Fintype κ] (a : ι → ℝ) (a' : κ → ℝ) (b : ℝ) :
    effDim (Sum.elim a a') b = effDim a b + effDim a' b := by
  simp only [effDim, Fintype.sum_sum_type, Sum.elim_inl, Sum.elim_inr]

/-- The noise floor is additive over independent tasks. -/
theorem noiseFloor_sum_type {κ : Type*} [Fintype κ] (a : ι → ℝ) (a' : κ → ℝ) (b : ℝ) :
    noiseFloor (Sum.elim a a') b = noiseFloor a b + noiseFloor a' b := by
  rw [noiseFloor, noiseFloor, noiseFloor, effDim_sum_type]
  ring

end DirectSum

end Catalog.MachineLearning.NoiseFloor