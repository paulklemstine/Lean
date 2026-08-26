import Mathlib
import Novelty.KVDecisionDissociation

/-!
# Selection interfaces carry precision requirements; content containers do not

This file formalises the *structural law* extracted in NET-95, the one that
explains why the weight axis and the cache-key axis behave so differently under
quantisation:

* weights and cache **values** are *content containers*: they are consumed by a
  convex (probability-weighted) average, so a `δ`-accurate quantiser perturbs the
  output by at most `δ`.  Degradation has a modulus of continuity in the
  quantiser step — it can only fall off smoothly, which is exactly the measured
  behaviour of the k-quant ladder from 6.6 down to 2.6 bpw
  (`Novelty.WeightQuantFloorLadder`).
* cache **keys** are a *selection interface*: they are consumed by an `argmax`.
  We prove that no modulus of continuity exists at all: for every `δ > 0` and
  every target error `C`, there is a score configuration and a `δ`-accurate
  quantiser whose top-1 decision flips and whose read-out error is exactly `C`.
  This is the wall that NET-92/93 measured between 8-bit and 5-bit keys.

The dissociation is therefore not empirical folklore but a theorem:
`content_smooth_selection_cliff`.

We build on `Novelty.KVDecisionDissociation`, reusing `IsStrictTop` (the top-1
decision) and `strictTop_of_margin` (the margin certificate), and add the
quantisation-theoretic layer:

* `content_error_le` / `content_error_sharp` — content error is exactly `Θ(δ)`.
* `selection_flip_at_every_precision` — selection error is `Θ(1)`, at every `δ`.
* `selection_has_no_modulus_of_continuity` — hence no bound `f(δ)` can exist.
* `selection_stable_at_bit_depth` / `selection_unstable_at_bit_depth` — the cliff
  is located at `b ≈ log₂(1/g)` where `g` is the top-1 margin: `b` bits are enough
  when `2 / 2 ^ b < g`, and are already too few when `g ≤ 1 / 2 ^ b`.
* `flips_le_small_margin_count` — the quantitative version over a whole sequence:
  the number of positions whose decision breaks is at most the number of
  positions whose margin is below `2 δ`.  The cliff is the margin distribution's
  cumulative mass, not a property of the bit width.
-/

namespace Catalog.Novelty.SelectionContentPrecision

open Finset Catalog.Novelty.KVDecisionDissociation

/-- A quantiser that is accurate to within `δ` everywhere. -/
def IsDeltaAccurate (q : ℝ → ℝ) (δ : ℝ) : Prop := ∀ x, |q x - x| ≤ δ

/-- A probability weight vector (the attention distribution). -/
def IsProb {n : ℕ} (p : Fin n → ℝ) : Prop := (∀ i, 0 ≤ p i) ∧ ∑ i, p i = 1

/-! ## 1. Content containers have a modulus of continuity -/

/-- **Content channels degrade smoothly.**  A probability-weighted read-out of
`δ`-quantised values moves by at most `δ`.  This is the whole reason weights and
cache values tolerate aggressive quantisation: the error bound is *linear* in the
quantiser step and vanishes with it. -/
theorem content_error_le {n : ℕ} (p v : Fin n → ℝ) (q : ℝ → ℝ) (δ : ℝ)
    (hp : IsProb p) (hq : IsDeltaAccurate q δ) :
    |dotP p (fun i => q (v i)) - dotP p v| ≤ δ := by
  obtain ⟨hpnn, hpsum⟩ := hp
  have hdiff : dotP p (fun i => q (v i)) - dotP p v = ∑ i, p i * (q (v i) - v i) := by
    simp [dotP, ← Finset.sum_sub_distrib, mul_sub]
  rw [hdiff]
  calc |∑ i, p i * (q (v i) - v i)| ≤ ∑ i, |p i * (q (v i) - v i)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, p i * δ := by
        refine Finset.sum_le_sum fun i _ => ?_
        rw [abs_mul, abs_of_nonneg (hpnn i)]
        exact mul_le_mul_of_nonneg_left (hq (v i)) (hpnn i)
    _ = δ := by rw [← Finset.sum_mul, hpsum, one_mul]

/-- The content bound is attained: `δ` is the exact modulus, not a loose bound. -/
theorem content_error_sharp (δ : ℝ) (hδ : 0 ≤ δ) :
    ∃ (p v : Fin 1 → ℝ) (q : ℝ → ℝ), IsProb p ∧ IsDeltaAccurate q δ ∧
      |dotP p (fun i => q (v i)) - dotP p v| = δ := by
  refine ⟨fun _ => 1, fun _ => 0, fun x => x + δ, ⟨fun _ => zero_le_one, by simp⟩,
    fun x => by simp [abs_of_nonneg hδ], ?_⟩
  simp [dotP, abs_of_nonneg hδ]

/-! ## 2. Selection interfaces have none -/

/-- **The selection cliff.**  For *every* quantiser step `δ > 0` and *every*
target error `C`, there is a two-way score configuration whose top-1 decision is
strict, a `δ`-accurate quantiser that flips that decision, and a value pair whose
read-out then differs by exactly `C`.  The output error of a selection interface
is therefore `Θ(1)`: it does not shrink with the quantiser step at all. -/
theorem selection_flip_at_every_precision (δ C : ℝ) (hδ : 0 < δ) (hC : 0 ≤ C) :
    ∃ (u val : Fin 2 → ℝ) (q : ℝ → ℝ),
      IsDeltaAccurate q δ ∧ IsStrictTop u 0 ∧ IsStrictTop (fun i => q (u i)) 1 ∧
        |val 1 - val 0| = C ∧ u 0 - u 1 ≤ δ := by
  refine ⟨![δ / 2, 0], ![0, C], fun x => if x ≤ δ / 4 then x + δ / 2 else x - δ / 2, ?_, ?_, ?_, ?_⟩
  · intro x
    by_cases hx : x ≤ δ / 4 <;> simp [hx] <;>
      rw [abs_of_nonneg (by linarith)] <;> linarith
  · intro j hj
    fin_cases j
    · exact absurd rfl hj
    · simpa using hδ
  · intro j hj
    fin_cases j
    · simp only [Matrix.cons_val_zero, Matrix.cons_val_one]
      have hle : (0:ℝ) ≤ δ / 4 := by linarith
      have hnot : ¬ (δ / 2 ≤ δ / 4) := by intro h; linarith
      simp [hle, hnot]
      linarith
    · exact absurd rfl hj
  · exact ⟨by simp [abs_of_nonneg hC], by simp; linarith⟩

/-- **No modulus of continuity for selection.**  Whatever error bound `f δ` one
proposes, at every precision `δ > 0` there is a configuration exceeding it.  So
no theorem of the form "selection error ≤ f(quantiser step)" can hold, in stark
contrast with `content_error_le`. -/
theorem selection_has_no_modulus_of_continuity (f : ℝ → ℝ) (δ : ℝ) (hδ : 0 < δ) :
    ∃ (u val : Fin 2 → ℝ) (q : ℝ → ℝ),
      IsDeltaAccurate q δ ∧ IsStrictTop u 0 ∧ IsStrictTop (fun i => q (u i)) 1 ∧
        f δ < |val 1 - val 0| := by
  obtain ⟨u, val, q, h1, h2, h3, h4, -⟩ :=
    selection_flip_at_every_precision δ (|f δ| + 1) hδ (by positivity)
  exact ⟨u, val, q, h1, h2, h3, by rw [h4]; linarith [le_abs_self (f δ)]⟩

/-- **The dissociation, in one statement.**  At any fixed quantiser step `δ > 0`:
content read-outs are perturbed by at most `δ`, while selection read-outs can be
perturbed by any prescribed amount `C`.  *Selection interfaces carry precision
requirements; content containers do not.* -/
theorem content_smooth_selection_cliff (δ C : ℝ) (hδ : 0 < δ) (hC : 0 ≤ C) :
    (∀ (n : ℕ) (p v : Fin n → ℝ) (q : ℝ → ℝ), IsProb p → IsDeltaAccurate q δ →
        |dotP p (fun i => q (v i)) - dotP p v| ≤ δ) ∧
      ∃ (u val : Fin 2 → ℝ) (q : ℝ → ℝ), IsDeltaAccurate q δ ∧ IsStrictTop u 0 ∧
        IsStrictTop (fun i => q (u i)) 1 ∧ |val 1 - val 0| = C := by
  refine ⟨fun n p v q hp hq => content_error_le p v q δ hp hq, ?_⟩
  obtain ⟨u, val, q, h1, h2, h3, h4, -⟩ := selection_flip_at_every_precision δ C hδ hC
  exact ⟨u, val, q, h1, h2, h3, h4⟩

/-! ## 3. Where the key cliff sits: the margin, not the bit width -/

/-- **Enough bits for selection.**  If the top-1 margin is `g` and a `b`-bit
quantiser is accurate to `1 / 2 ^ b`, then `2 / 2 ^ b < g` already guarantees the
decision survives.  The required depth is `b ≳ log₂(2/g)`: a property of the
margin distribution of the keys, not of the tensor being quantised. -/
theorem selection_stable_at_bit_depth {n : ℕ} (u : Fin n → ℝ) (i : Fin n) (b : ℕ)
    (q : ℝ → ℝ) (g : ℝ) (hq : IsDeltaAccurate q (1 / 2 ^ b))
    (hg : 2 / 2 ^ b < g) (hmargin : ∀ j, j ≠ i → g ≤ u i - u j) :
    IsStrictTop (fun j => q (u j)) i := by
  refine strictTop_of_margin u (fun j => q (u j)) i (1 / 2 ^ b) (fun j hj => ?_) (fun j => ?_)
  · have h := hmargin j hj
    have : (2 : ℝ) * (1 / 2 ^ b) = 2 / 2 ^ b := by ring
    linarith [hg, h, this ▸ (le_refl ((2:ℝ) * (1 / 2 ^ b)))]
  · rw [abs_sub_comm]
    exact hq (u j)

/-- **Too few bits for selection.**  Conversely, once the margin `g` drops to
`1 / 2 ^ b` or below, a `1 / 2 ^ b`-accurate quantiser can already destroy the
decision, with an arbitrarily large read-out error.  Together with
`selection_stable_at_bit_depth` this pins the cliff at `b ≈ log₂(1/g)`: it is a
*wall* (error `0` on one side, `Θ(1)` on the other), not a slope. -/
theorem selection_unstable_at_bit_depth (b : ℕ) (C : ℝ) (hC : 0 ≤ C) :
    ∃ (u val : Fin 2 → ℝ) (q : ℝ → ℝ),
      IsDeltaAccurate q (1 / 2 ^ b) ∧ IsStrictTop u 0 ∧
        IsStrictTop (fun i => q (u i)) 1 ∧ |val 1 - val 0| = C ∧
        u 0 - u 1 ≤ 1 / 2 ^ b :=
  selection_flip_at_every_precision (1 / 2 ^ b) C (by positivity) hC

/-! ## 4. How many decisions break: the margin distribution -/

open Classical in
/-- **The cliff is cumulative margin mass.**  Over a sequence of `L` attention
positions, the number of positions whose top-1 decision is destroyed by a
`ε`-accurate quantisation of the keys is at most the number of positions whose
top-1 margin is at most `2 ε`.  This is the quantitative form of the key cliff:
degradation tracks the margin CDF at `2 ε`, so it can jump from nothing to
everything over a single bit — exactly what the weight axis, which has no
selection step, cannot do. -/
theorem flips_le_small_margin_count {L n : ℕ} (u : Fin L → Fin n → ℝ) (i : Fin L → Fin n)
    (q : ℝ → ℝ) (eps : ℝ) (hq : IsDeltaAccurate q eps) :
    (Finset.univ.filter fun l => ¬ IsStrictTop (fun j => q (u l j)) (i l)).card ≤
      (Finset.univ.filter fun l => ∃ j, j ≠ i l ∧ u l (i l) - u l j ≤ 2 * eps).card := by
  refine Finset.card_le_card (fun l hl => ?_)
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hl ⊢
  by_contra hcon
  push_neg at hcon
  refine hl (strictTop_of_margin (u l) (fun j => q (u l j)) (i l) eps (fun j hj => ?_)
    (fun j => ?_))
  · have := hcon j hj
    linarith
  · rw [abs_sub_comm]
    exact hq (u l j)

end Catalog.Novelty.SelectionContentPrecision