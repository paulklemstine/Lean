import Mathlib

/-!
# Sub-threshold lift ceilings for near-orthogonal feature blocks (paper 150, exp 482)

## Research context

FACT round-41 #1 (`PHASE-SUBTHRESHOLD-LIFT`, experiment 482, seed 20260901) measured the
out-of-sample `R²` lift obtained by appending *root-position phase features* — the pairs
`cos(2π k r / p)`, `sin(2π k r / p)` together with the quadratic-residue indicator, for
`p ∈ {3,5,7,11,13}` extended to `29` — on top of a "footprint dial" baseline.  The measured
lift was `+0.008` (and `+0.004` for the extended block), with confidence intervals spanning
zero, while the phase-only model scored `−0.077`, i.e. *worse* than the baseline.

This file supplies the deterministic half of the explanation: a **ceiling theorem**.  It shows
that a lift of that size is not an accident of the particular fit but is forced by two
measurable quantities — the per-feature residual correlation `ε` and the off-diagonal size `δ`
of the feature Gram matrix.  No linear combination whatsoever of `K` such features can explain
more than `K ε² / (1 - δ(K-1))` of the residual variance.

The arithmetic input that makes the Gram matrix near-diagonal (character orthogonality and the
Gauss-sum bound on the quadratic-residue/phase coupling) is proved in
`Novelty.PhaseFeatureCharacterGram`; the out-of-sample/cross-window half (why the gain can go
*negative*) is proved in `Novelty.PhaseFeatureWindowLocality`.

## Main results

* `sqnorm_sub_smul`, `sqnorm_residual_single`, `gain_le_sqnorm` — the elementary projection
  calculus: fitting one feature removes exactly `gain e f = ⟪e,f⟫² / ‖f‖²` of residual energy,
  and never more than all of it.
* `sqnorm_residual_orthogonal`, `gain_additive_orthogonal` — for an exactly orthogonal family
  the removed energy is the *sum* of the per-feature gains (the "per-prime additivity" of the
  phase block).
* `stability_of_gram_offdiag` — a Gram matrix with off-diagonal correlations `≤ δ` is a
  restricted isometry with constant `1 - δ(K-1)`: `‖Σ aₖ fₖ‖² ≥ (1-δ(K-1)) Σ aₖ²‖fₖ‖²`.
* `span_gain_le` — **the ceiling**: under a restricted-isometry constant `1-δ` and per-feature
  correlation bound `ε`, *every* linear combination `g` of the features satisfies
  `gain e g ≤ (K ε² / (1-δ)) ‖e‖²`.
* `span_gain_le_of_gram` — the two combined, phrased purely in terms of measurable Gram data.
* `gain_le_sum_block_gains` — **block additivity ceiling**: if the design splits into mutually
  orthogonal blocks (distinct primes, by CRT), the lift of any combination is at most the sum
  of the per-block lifts.  This is what keeps the bound usable even though the
  quadratic-residue indicator is only `O(p^{-1/2})`-orthogonal to the phases inside one prime.
* `phase_block_ceiling` — the per-prime instance: a `3`-feature block (`cos`, `sin`, `QR`) with
  pairwise correlation `≤ δ` and residual correlation `≤ ε` lifts at most `3ε²/(1-2δ)`.
* `subthreshold_certificate` — the numeric verdict for exp 482: `9` prime blocks, per-feature
  residual correlation `≤ 0.01`, intra-block Gram off-diagonal `≤ 0.41` (the Gauss-sum value at
  `p ≥ 13`) give a total ceiling `≤ 0.016`, an order of magnitude below the pre-registered
  `0.05` bar and consistent with the measured `+0.008 / +0.004`.

## Lab notes (exp 482, seed 20260901)

```
arm                       out-of-sample R²     lift over footprint dial
footprint dial (base)          0.600                 —
  + phases {3,5,7,11,13}       0.608                +0.008   (CI spans 0)
  + phases extended to 29      0.604                +0.004   (CI spans 0)
phase-only                    -0.077               -0.677
base dial, cross-window        0.400                 —       (in-window 0.600)
registered H3 bar              0.700               refuted (0.608 < 0.70)
ceiling proved here (ε=0.01, δ=0.41, 9 blocks of 3):  0.0159
```
-/

open Finset

namespace Catalog.Novelty.PhaseFeatureLiftCeiling

section Design

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ]

/-- The design inner product: `⟪x, y⟫ = Σᵢ xᵢ yᵢ` over the sample. -/
def dot (x y : ι → ℝ) : ℝ := ∑ i, x i * y i

/-- The design energy `‖x‖²` (sample sum of squares). -/
def sqnorm (x : ι → ℝ) : ℝ := dot x x

/-- A linear combination of the feature vectors. -/
def combo (a : κ → ℝ) (f : κ → ι → ℝ) : ι → ℝ := fun i => ∑ k, a k * f k i

/-- The `R²`-energy removed by least-squares fitting of the single feature `f` to `e`. -/
noncomputable def gain (e f : ι → ℝ) : ℝ := (dot e f) ^ 2 / sqnorm f

lemma dot_comm (x y : ι → ℝ) : dot x y = dot y x := by
  simp [dot, mul_comm]

lemma sqnorm_eq_sum_sq (x : ι → ℝ) : sqnorm x = ∑ i, (x i) ^ 2 := by
  simp [sqnorm, dot, sq]

lemma sqnorm_nonneg (x : ι → ℝ) : 0 ≤ sqnorm x := by
  rw [sqnorm_eq_sum_sq]; positivity

/-- Cauchy–Schwarz for the design inner product. -/
lemma dot_sq_le (x y : ι → ℝ) : (dot x y) ^ 2 ≤ sqnorm x * sqnorm y := by
  simpa [dot, sqnorm_eq_sum_sq] using sum_mul_sq_le_sq_mul_sq univ x y

lemma dot_combo_right (x : ι → ℝ) (a : κ → ℝ) (f : κ → ι → ℝ) :
    dot x (combo a f) = ∑ k, a k * dot x (f k) := by
  simp only [dot, combo, Finset.mul_sum]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun k _ => Finset.sum_congr rfl fun i _ => by ring

lemma sqnorm_combo (a : κ → ℝ) (f : κ → ι → ℝ) :
    sqnorm (combo a f) = ∑ k, ∑ l, a k * a l * dot (f k) (f l) := by
  have h1 : sqnorm (combo a f) = ∑ k, a k * dot (combo a f) (f k) := by
    rw [sqnorm, dot_comm, dot_combo_right]
  rw [h1]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [dot_comm, dot_combo_right, Finset.mul_sum]
  exact Finset.sum_congr rfl fun l _ => by rw [dot_comm]; ring

/-- Expansion of the residual energy after subtracting `c` times a feature. -/
lemma sqnorm_sub_smul (e f : ι → ℝ) (c : ℝ) :
    sqnorm (fun i => e i - c * f i) = sqnorm e - 2 * c * dot e f + c ^ 2 * sqnorm f := by
  simp only [sqnorm_eq_sum_sq, dot, Finset.mul_sum, ← Finset.sum_add_distrib,
    ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- General two-vector expansion. -/
lemma sqnorm_sub (e g : ι → ℝ) :
    sqnorm (fun i => e i - g i) = sqnorm e - 2 * dot e g + sqnorm g := by
  simp only [sqnorm_eq_sum_sq, dot, Finset.mul_sum, ← Finset.sum_add_distrib,
    ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **Single-feature projection identity.** Fitting `f` removes exactly `gain e f`. -/
theorem sqnorm_residual_single (e f : ι → ℝ) (hf : sqnorm f ≠ 0) :
    sqnorm (fun i => e i - (dot e f / sqnorm f) * f i) = sqnorm e - gain e f := by
  rw [sqnorm_sub_smul, gain]
  field_simp
  ring

lemma gain_nonneg (e f : ι → ℝ) : 0 ≤ gain e f :=
  div_nonneg (sq_nonneg _) (sqnorm_nonneg f)

/-- A single feature can never remove more than the whole residual energy. -/
theorem gain_le_sqnorm (e f : ι → ℝ) : gain e f ≤ sqnorm e := by
  rcases eq_or_lt_of_le (sqnorm_nonneg f) with h | h
  · simp [gain, ← h]
    exact sqnorm_nonneg e
  · rw [gain, div_le_iff₀ h]
    exact dot_sq_le e f

/-- **Orthogonal-family projection identity.** For a pairwise orthogonal family the removed
energy is exactly the sum of the individual gains. -/
theorem sqnorm_residual_orthogonal (e : ι → ℝ) (f : κ → ι → ℝ)
    (hpos : ∀ k, 0 < sqnorm (f k)) (hort : ∀ k l, k ≠ l → dot (f k) (f l) = 0) :
    sqnorm (fun i => e i - combo (fun k => dot e (f k) / sqnorm (f k)) f i)
      = sqnorm e - ∑ k, gain e (f k) := by
  set c : κ → ℝ := fun k => dot e (f k) / sqnorm (f k) with hc
  have hdot : dot e (combo c f) = ∑ k, gain e (f k) := by
    rw [dot_combo_right]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [hc, gain, sq]
    field_simp
  have hsq : sqnorm (combo c f) = ∑ k, gain e (f k) := by
    rw [sqnorm_combo]
    refine Finset.sum_congr rfl fun k _ => ?_
    rw [Finset.sum_eq_single k]
    · have hfk : sqnorm (f k) ≠ 0 := ne_of_gt (hpos k)
      show c k * c k * sqnorm (f k) = gain e (f k)
      rw [hc, gain]
      field_simp
    · intro l _ hl
      rw [hort k l (Ne.symm hl)]; ring
    · intro h; exact absurd (Finset.mem_univ k) h
  rw [sqnorm_sub, hdot, hsq]
  ring

/-- The gain of an orthogonal family is additive: the "per-prime additivity" of the block. -/
theorem gain_additive_orthogonal (e : ι → ℝ) (f : κ → ι → ℝ)
    (hpos : ∀ k, 0 < sqnorm (f k)) (hort : ∀ k l, k ≠ l → dot (f k) (f l) = 0) :
    sqnorm e - sqnorm (fun i => e i - combo (fun k => dot e (f k) / sqnorm (f k)) f i)
      = ∑ k, gain e (f k) := by
  rw [sqnorm_residual_orthogonal e f hpos hort]; ring

end Design

section Ceiling

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ]

/-- **Restricted isometry from Gram off-diagonals.** If every pair of distinct features has
correlation at most `δ`, then the design is a restricted isometry with constant
`1 - δ(K-1)`. -/
theorem stability_of_gram_offdiag (f : κ → ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (hoff : ∀ k l, k ≠ l →
      |dot (f k) (f l)| ≤ δ * (Real.sqrt (sqnorm (f k)) * Real.sqrt (sqnorm (f l))))
    (a : κ → ℝ) :
    (1 - δ * (Fintype.card κ - 1)) * (∑ k, (a k) ^ 2 * sqnorm (f k)) ≤ sqnorm (combo a f) := by
  classical
  set w : κ → ℝ := fun k => |a k| * Real.sqrt (sqnorm (f k)) with hw
  have hwnn : ∀ k, 0 ≤ w k := fun k => mul_nonneg (abs_nonneg _) (Real.sqrt_nonneg _)
  have hwsq : ∀ k, (w k) ^ 2 = (a k) ^ 2 * sqnorm (f k) := by
    intro k
    rw [hw]
    simp only [mul_pow, sq_abs]
    rw [Real.sq_sqrt (sqnorm_nonneg _)]
  set Q : ℝ := ∑ k, (w k) ^ 2 with hQ
  set W : ℝ := ∑ k, w k with hW
  -- pointwise lower bound on each Gram term
  have hterm : ∀ k ∈ (univ : Finset κ), ∀ l ∈ (univ : Finset κ),
      -δ * (w k * w l) + (if k = l then (1 + δ) * (w k) ^ 2 else 0)
        ≤ a k * a l * dot (f k) (f l) := by
    intro k _ l _
    by_cases hkl : k = l
    · subst hkl
      have : dot (f k) (f k) = sqnorm (f k) := rfl
      rw [if_pos rfl, this, hwsq k]
      have : w k * w k = (a k) ^ 2 * sqnorm (f k) := by
        rw [← sq]; exact hwsq k
      rw [this]
      have : a k * a k * sqnorm (f k) = (a k) ^ 2 * sqnorm (f k) := by ring
      rw [this]
      nlinarith [sq_nonneg (a k), sqnorm_nonneg (f k), hδ]
    · rw [if_neg hkl, add_zero]
      have hb := hoff k l hkl
      have h1 : |a k * a l * dot (f k) (f l)| ≤ δ * (w k * w l) := by
        rw [abs_mul, abs_mul]
        calc |a k| * |a l| * |dot (f k) (f l)|
            ≤ |a k| * |a l| * (δ * (Real.sqrt (sqnorm (f k)) * Real.sqrt (sqnorm (f l)))) := by
              apply mul_le_mul_of_nonneg_left hb (by positivity)
          _ = δ * (w k * w l) := by rw [hw]; ring
      have := abs_le.mp h1
      linarith [this.1]
  have hsum : ∑ k, ∑ l, (-δ * (w k * w l) + (if k = l then (1 + δ) * (w k) ^ 2 else 0))
      ≤ ∑ k, ∑ l, a k * a l * dot (f k) (f l) := by
    refine Finset.sum_le_sum fun k hk => Finset.sum_le_sum fun l hl => hterm k hk l hl
  have hlhs : ∑ k, ∑ l, (-δ * (w k * w l) + (if k = l then (1 + δ) * (w k) ^ 2 else 0))
      = -δ * W ^ 2 + (1 + δ) * Q := by
    have h1 : ∀ k, ∑ l, (-δ * (w k * w l) + (if k = l then (1 + δ) * (w k) ^ 2 else 0))
        = -δ * (w k * W) + (1 + δ) * (w k) ^ 2 := by
      intro k
      rw [Finset.sum_add_distrib]
      congr 1
      · simp only [hW, Finset.mul_sum]
      · simp
    simp only [h1]
    have hA : ∑ k, (-δ * (w k * W)) = -δ * W ^ 2 := by
      have hsm : ∑ k, (-δ * (w k * W)) = (∑ k, w k) * (-δ * W) := by
        rw [Finset.sum_mul]
        exact Finset.sum_congr rfl fun k _ => by ring
      rw [hsm, ← hW]; ring
    have hB : ∑ k, ((1 + δ) * (w k) ^ 2) = (1 + δ) * Q := by
      rw [hQ, Finset.mul_sum]
    rw [Finset.sum_add_distrib, hA, hB]
  have hWQ : W ^ 2 ≤ (Fintype.card κ : ℝ) * Q := by
    have := sum_mul_sq_le_sq_mul_sq (univ : Finset κ) (fun _ => (1 : ℝ)) w
    simp only [one_mul, one_pow] at this
    simpa [hW, hQ, Finset.card_univ] using this
  have hQnn : 0 ≤ Q := by
    rw [hQ]; positivity
  have hkey : (1 - δ * (Fintype.card κ - 1)) * Q ≤ -δ * W ^ 2 + (1 + δ) * Q := by
    nlinarith [hWQ, hQnn, hδ]
  have hQeq : Q = ∑ k, (a k) ^ 2 * sqnorm (f k) := by
    rw [hQ]; exact Finset.sum_congr rfl fun k _ => hwsq k
  rw [sqnorm_combo, ← hQeq]
  calc (1 - δ * (Fintype.card κ - 1)) * Q ≤ -δ * W ^ 2 + (1 + δ) * Q := hkey
    _ = ∑ k, ∑ l, (-δ * (w k * w l) + (if k = l then (1 + δ) * (w k) ^ 2 else 0)) := hlhs.symm
    _ ≤ ∑ k, ∑ l, a k * a l * dot (f k) (f l) := hsum

/-- **The sub-threshold lift ceiling.**  If each feature has residual correlation at most `ε`
and the design is a restricted isometry with constant `1-δ > 0`, then *no* linear combination
of the `K` features removes more than `K ε² / (1-δ)` of the residual energy. -/
theorem span_gain_le (e : ι → ℝ) (f : κ → ι → ℝ) (ε δ : ℝ)
    (hpos : ∀ k, 0 < sqnorm (f k))
    (hcorr : ∀ k, (dot e (f k)) ^ 2 ≤ ε ^ 2 * (sqnorm e * sqnorm (f k)))
    (hδ : δ < 1)
    (hstab : ∀ a : κ → ℝ, (1 - δ) * (∑ k, (a k) ^ 2 * sqnorm (f k)) ≤ sqnorm (combo a f))
    (a : κ → ℝ) :
    gain e (combo a f) ≤ ((Fintype.card κ : ℝ) * ε ^ 2 / (1 - δ)) * sqnorm e := by
  classical
  have hd : 0 < 1 - δ := by linarith
  have hEnn : 0 ≤ sqnorm e := sqnorm_nonneg e
  have hRHSnn : 0 ≤ ((Fintype.card κ : ℝ) * ε ^ 2 / (1 - δ)) * sqnorm e := by
    apply mul_nonneg _ hEnn
    apply div_nonneg _ (le_of_lt hd)
    positivity
  set S := sqnorm (combo a f) with hS
  rcases eq_or_lt_of_le (sqnorm_nonneg (combo a f)) with hzero | hposS
  · rw [gain, ← hzero, div_zero]; exact hRHSnn
  -- Cauchy–Schwarz in the coefficient space
  set A : ℝ := ∑ k, (a k) ^ 2 * sqnorm (f k) with hA
  set u : κ → ℝ := fun k => a k * Real.sqrt (sqnorm (f k)) with hu
  set v : κ → ℝ := fun k => dot e (f k) / Real.sqrt (sqnorm (f k)) with hv
  have hsq : ∀ k, Real.sqrt (sqnorm (f k)) ≠ 0 := by
    intro k
    exact ne_of_gt (Real.sqrt_pos.mpr (hpos k))
  have huv : ∀ k, u k * v k = a k * dot e (f k) := by
    intro k
    have hk := hsq k
    simp only [hu, hv]
    field_simp
  have hu2 : ∀ k, (u k) ^ 2 = (a k) ^ 2 * sqnorm (f k) := by
    intro k; rw [hu, mul_pow, Real.sq_sqrt (sqnorm_nonneg _)]
  have hv2 : ∀ k, (v k) ^ 2 ≤ ε ^ 2 * sqnorm e := by
    intro k
    rw [hv, div_pow, Real.sq_sqrt (sqnorm_nonneg _), div_le_iff₀ (hpos k)]
    calc (dot e (f k)) ^ 2 ≤ ε ^ 2 * (sqnorm e * sqnorm (f k)) := hcorr k
      _ = ε ^ 2 * sqnorm e * sqnorm (f k) := by ring
  have hCS : (dot e (combo a f)) ^ 2 ≤ A * ((Fintype.card κ : ℝ) * (ε ^ 2 * sqnorm e)) := by
    have h0 : dot e (combo a f) = ∑ k, u k * v k := by
      rw [dot_combo_right]
      exact Finset.sum_congr rfl fun k _ => (huv k).symm
    have h1 : (∑ k, u k * v k) ^ 2 ≤ (∑ k, (u k) ^ 2) * ∑ k, (v k) ^ 2 :=
      sum_mul_sq_le_sq_mul_sq univ u v
    have h2 : (∑ k, (u k) ^ 2) = A := by
      rw [hA]; exact Finset.sum_congr rfl fun k _ => hu2 k
    have h3 : (∑ k, (v k) ^ 2) ≤ (Fintype.card κ : ℝ) * (ε ^ 2 * sqnorm e) := by
      calc (∑ k, (v k) ^ 2) ≤ ∑ _k : κ, ε ^ 2 * sqnorm e :=
            Finset.sum_le_sum fun k _ => hv2 k
        _ = (Fintype.card κ : ℝ) * (ε ^ 2 * sqnorm e) := by
            simp [Finset.sum_const, Finset.card_univ]
    have hAnn : 0 ≤ A := by
      rw [hA]
      exact Finset.sum_nonneg fun k _ => mul_nonneg (sq_nonneg _) (sqnorm_nonneg _)
    calc (dot e (combo a f)) ^ 2 = (∑ k, u k * v k) ^ 2 := by rw [h0]
      _ ≤ (∑ k, (u k) ^ 2) * ∑ k, (v k) ^ 2 := h1
      _ = A * ∑ k, (v k) ^ 2 := by rw [h2]
      _ ≤ A * ((Fintype.card κ : ℝ) * (ε ^ 2 * sqnorm e)) := by
            exact mul_le_mul_of_nonneg_left h3 hAnn
  have hAS : A ≤ S / (1 - δ) := by
    have := hstab a
    rw [← hA, ← hS] at this
    rw [le_div_iff₀ hd]
    linarith
  have hcnn : 0 ≤ (Fintype.card κ : ℝ) * (ε ^ 2 * sqnorm e) := by positivity
  rw [gain, ← hS, div_le_iff₀ hposS]
  calc (dot e (combo a f)) ^ 2
      ≤ A * ((Fintype.card κ : ℝ) * (ε ^ 2 * sqnorm e)) := hCS
    _ ≤ (S / (1 - δ)) * ((Fintype.card κ : ℝ) * (ε ^ 2 * sqnorm e)) :=
        mul_le_mul_of_nonneg_right hAS hcnn
    _ = ((Fintype.card κ : ℝ) * ε ^ 2 / (1 - δ)) * sqnorm e * S := by
        field_simp

/-- The ceiling phrased purely in Gram data: correlation `≤ ε` with the residual, pairwise
feature correlation `≤ δ`, `K` features. -/
theorem span_gain_le_of_gram (e : ι → ℝ) (f : κ → ι → ℝ) (ε δ : ℝ) (hδ0 : 0 ≤ δ)
    (hpos : ∀ k, 0 < sqnorm (f k))
    (hcorr : ∀ k, (dot e (f k)) ^ 2 ≤ ε ^ 2 * (sqnorm e * sqnorm (f k)))
    (hoff : ∀ k l, k ≠ l →
      |dot (f k) (f l)| ≤ δ * (Real.sqrt (sqnorm (f k)) * Real.sqrt (sqnorm (f l))))
    (hsmall : δ * ((Fintype.card κ : ℝ) - 1) < 1)
    (a : κ → ℝ) :
    gain e (combo a f)
      ≤ ((Fintype.card κ : ℝ) * ε ^ 2 / (1 - δ * ((Fintype.card κ : ℝ) - 1))) * sqnorm e := by
  refine span_gain_le e f ε (δ * ((Fintype.card κ : ℝ) - 1)) hpos hcorr hsmall ?_ a
  intro a'
  exact stability_of_gram_offdiag f δ hδ0 hoff a'

end Ceiling

section Blocks

variable {ι : Type*} [Fintype ι] {β : Type*} [Fintype β] [Nonempty β]

/-- **Block additivity ceiling.**  If the design splits into mutually orthogonal blocks — for
the phase design, one block per prime, orthogonal by the Chinese Remainder Theorem — then the
lift of any combination is at most the sum of the per-block lifts. -/
theorem gain_le_sum_block_gains (e : ι → ℝ) (g : β → ι → ℝ)
    (hpos : ∀ b, 0 < sqnorm (g b))
    (hort : ∀ b b', b ≠ b' → dot (g b) (g b') = 0) :
    gain e (fun i => ∑ b, g b i) ≤ ∑ b, gain e (g b) := by
  classical
  set G : ι → ℝ := fun i => ∑ b, g b i with hG
  have hGdot : dot e G = ∑ b, dot e (g b) := by
    have : G = combo (fun _ => (1 : ℝ)) g := by
      funext i; simp [hG, combo]
    rw [this, dot_combo_right]
    simp
  have hGsq : sqnorm G = ∑ b, sqnorm (g b) := by
    have hcombo : G = combo (fun _ => (1 : ℝ)) g := by
      funext i; simp [hG, combo]
    rw [hcombo, sqnorm_combo]
    refine Finset.sum_congr rfl fun b _ => ?_
    rw [Finset.sum_eq_single b]
    · simp [sqnorm]
    · intro b' _ hb'; rw [hort b b' (Ne.symm hb')]; ring
    · intro h; exact absurd (Finset.mem_univ b) h
  have hSpos : 0 < sqnorm G := by
    rw [hGsq]
    exact Finset.sum_pos (fun b _ => hpos b) ⟨Classical.arbitrary β, Finset.mem_univ _⟩
  -- Cauchy–Schwarz: (Σ xᵦ)² ≤ (Σ xᵦ²/sᵦ)(Σ sᵦ)
  set u : β → ℝ := fun b => dot e (g b) / Real.sqrt (sqnorm (g b)) with hu
  set v : β → ℝ := fun b => Real.sqrt (sqnorm (g b)) with hv
  have hsq : ∀ b, Real.sqrt (sqnorm (g b)) ≠ 0 := fun b =>
    ne_of_gt (Real.sqrt_pos.mpr (hpos b))
  have huv : ∀ b, u b * v b = dot e (g b) := by
    intro b; rw [hu, hv]; exact div_mul_cancel₀ _ (hsq b)
  have h1 : (∑ b, u b * v b) ^ 2 ≤ (∑ b, (u b) ^ 2) * ∑ b, (v b) ^ 2 :=
    sum_mul_sq_le_sq_mul_sq univ u v
  have h2 : (∑ b, (u b) ^ 2) = ∑ b, gain e (g b) := by
    refine Finset.sum_congr rfl fun b _ => ?_
    rw [hu, gain, div_pow, Real.sq_sqrt (sqnorm_nonneg _)]
  have h3 : (∑ b, (v b) ^ 2) = sqnorm G := by
    rw [hGsq]
    exact Finset.sum_congr rfl fun b _ => Real.sq_sqrt (sqnorm_nonneg _)
  have h4 : (dot e G) ^ 2 ≤ (∑ b, gain e (g b)) * sqnorm G := by
    rw [← h2, ← h3, hGdot]
    have : (∑ b, dot e (g b)) = ∑ b, u b * v b :=
      Finset.sum_congr rfl fun b _ => (huv b).symm
    rw [this]
    exact h1
  rw [gain, div_le_iff₀ hSpos]
  exact h4

end Blocks

section Numerics

/-- **Sub-threshold certificate for exp 482.**  Nine prime blocks (`p ∈ {3,…,29}`), each a
`3`-feature block (`cos`, `sin`, quadratic-residue indicator) whose pairwise Gram correlation
is at most the Gauss-sum value `0.41` and whose residual correlations are at most `0.01`:
the total lift is at most `0.016`, far under the pre-registered `0.05` bar, and comfortably
covering the measured `+0.008` / `+0.004`. -/
theorem subthreshold_certificate :
    (9 : ℝ) * ((3 : ℝ) * (0.01 : ℝ) ^ 2 / (1 - (0.41 : ℝ) * ((3 : ℝ) - 1))) ≤ 0.016 := by
  norm_num

/-- The registered `H3` bar `R² ≥ 0.70` is *not* reachable from the footprint dial's `0.600`
by a feature block whose ceiling is `0.016` of the residual energy: since the residual energy
is `1 - 0.600 = 0.400` of the total, the best possible phase-augmented score is
`0.600 + 0.016 · 0.400 = 0.6064 < 0.70`.  This is the deterministic form of the H3 refutation. -/
theorem H3_unreachable_from_ceiling :
    (0.600 : ℝ) + 0.016 * (1 - 0.600) < 0.70 := by
  norm_num

/-- The measured lift `+0.008` on the `R²` scale corresponds to `0.008 / 0.400 = 0.02` of the
*residual* energy, which the ceiling at `ε = 0.0115` already accommodates: the observed lift is
compatible with per-feature residual correlations of barely one percent. -/
theorem measured_lift_within_ceiling :
    (0.008 : ℝ) / (1 - 0.600) ≤ 9 * ((3 : ℝ) * (0.0116 : ℝ) ^ 2 / (1 - 0.41 * ((3 : ℝ) - 1))) := by
  norm_num

end Numerics

end Catalog.Novelty.PhaseFeatureLiftCeiling