import Bridges.Ma1EffectivitySignBlind
import Bridges.Ma1EffectivityCeiling

/-!
# The MA-1 effectivity sweep: what the null proves, and what it leaves open

This file is the capstone of `Bridges.Ma1EffectivitySignBlind` (the readout is sign-blind,
its permutation control vacuous) and `Bridges.Ma1EffectivityCeiling` (a working criterion
must show up in `R²`, and a size covariate can reach a high `R²` for free).  It states the
two halves of the experiment-566 verdict as theorems about the same data structure: a
finite sample of moduli, each carrying a residue-class count field.

## What the null proves

`ma1_no_criterion_dichotomy` — from a recorded ceiling `R² ≤ ρ` for the class of *all*
functions of the L-mass feature `P` one gets, simultaneously:

* a **margin cap**: every threshold criterion on `P` separates the deviation field with
  margin obeying `4δ²n₁n₂/n ≤ ρ·TSS` — with `ρ = 0.0785` and a balanced split this is
  `δ ≤ 0.281` sample standard deviations; and
* **strict size dominance**: if the response is near-affine in the size covariate with a
  residual small enough that the size bound exceeds `ρ`, then the single size feature
  strictly beats the entire (arbitrarily nonlinear) L-mass class.

## What the null leaves open

`sweep_blind_to_alignment` and `exp566_signed_route_unconstrained` — reflecting the count
field of any subset of moduli along `a ↦ −a` leaves *every* recorded response value, and
therefore *every* fitted `R²` in *every* model class, exactly unchanged, while flipping the
sign of the signed character alignment of the reflected moduli.  Consequently, for a prime
modulus `p ≡ 3 (mod 4)`, **every** sign pattern of maximal alignments is compatible with
one and the same recorded data set.  The magnitude sweep therefore constrains the signed
character-alignment route not at all: this is the paper's SIGN-BLIND caveat, proved.
-/

namespace Ma1Effectivity

open Finset QRResidual

open scoped Classical

variable {ι : Type*} [Fintype ι] [Nonempty ι]
variable {κ : Type*} [Fintype κ] [Nonempty κ]

/-! ## The sample and its reflections -/

/-- The registered per-modulus response of the sweep: the normalised maximal deviation of
the residue-class count field of the modulus `i` from its expectation `E i`. -/
noncomputable def sweepResponse (c : ι → (κ → ℝ)) (E : ι → ℝ) : ι → ℝ :=
  fun i => maxDev (c i) (E i)

/-- Relabel the residue classes of each modulus by a permutation.  For `σ i = (a ↦ −a)`
this is the alignment-flipping reflection. -/
def reflect (c : ι → (κ → ℝ)) (σ : ι → Equiv.Perm κ) : ι → (κ → ℝ) := fun i => c i ∘ σ i

omit [Fintype ι] [Nonempty ι] in
theorem sweepResponse_reflect (c : ι → (κ → ℝ)) (σ : ι → Equiv.Perm κ) (E : ι → ℝ) :
    sweepResponse (reflect c σ) E = sweepResponse c E := by
  funext i
  exact maxDev_comp_perm (c i) (E i) (σ i)

omit [Nonempty ι] in
/-- **The sweep is blind to the sign of the alignment.**  Reflecting the count fields by
permutations under which the character weight is odd leaves the recorded response vector —
hence the fitted `R²` of *every* model class whatsoever — exactly unchanged, while flipping
the alignment of every modulus. -/
theorem sweep_blind_to_alignment (c : ι → (κ → ℝ)) (σ : ι → Equiv.Perm κ) (E : ι → ℝ)
    (w : κ → ℝ) (hw : ∀ (i : ι) (a : κ), w (σ i a) = -w a) :
    sweepResponse (reflect c σ) E = sweepResponse c E ∧
      (∀ S : Set (ι → ℝ), rsq (sweepResponse (reflect c σ) E) S = rsq (sweepResponse c E) S) ∧
      (∀ i, align (reflect c σ i) w = -align (c i) w) := by
  refine ⟨sweepResponse_reflect c σ E, fun S => ?_, fun i => ?_⟩
  · rw [sweepResponse_reflect c σ E]
  · exact align_comp_of_odd (σ i) w (hw i) (c i)

/-! ## The signed route is entirely unconstrained by the recorded data -/

variable (p : ℕ) [Fact p.Prime]

omit [Nonempty ι] in
/-- **Every sign pattern fits the same data.**  Fix a prime `p ≡ 3 (mod 4)` and any
prescribed pattern of signs `s : ι → Bool`.  There is a sample of count fields on the
residue classes mod `p` realising that pattern of maximal character alignments `±(p−1)`
whose recorded response vector — and therefore whose fitted `R²` in every model class — is
*identical* to that of the unreflected sample.

The recorded magnitude null of experiment 566 therefore places no constraint whatsoever on
the signed character-alignment route. -/
theorem exp566_signed_route_unconstrained (hp3 : p % 4 = 3) (E : ι → ℝ) (s : ι → Bool) :
    ∃ c : ι → (ZMod p → ℝ),
      sweepResponse c E = sweepResponse (fun i a => E i + chiR p a) E ∧
      (∀ S : Set (ι → ℝ),
        rsq (sweepResponse c E) S = rsq (sweepResponse (fun i a => E i + chiR p a) E) S) ∧
      (∀ i, align (c i) (chiR p) = if s i then ((p : ℝ) - 1) else -((p : ℝ) - 1)) := by
  have hp : p ≠ 2 := by omega
  have hodd : ∀ a : ZMod p, chiR p (negPerm p a) = -chiR p a := by
    intro a; simpa [negPerm] using chiR_comp_neg p hp3 a
  set base : ι → (ZMod p → ℝ) := fun i a => E i + chiR p a with hbase
  refine ⟨fun i => if s i then base i else base i ∘ negPerm p, ?_⟩
  have hresp : sweepResponse (fun i => if s i then base i else base i ∘ negPerm p) E
      = sweepResponse base E := by
    funext i
    by_cases hs : s i = true
    · simp only [sweepResponse, if_pos hs]
    · simp only [sweepResponse, if_neg hs]
      exact maxDev_comp_perm (base i) (E i) (negPerm p)
  refine ⟨hresp, fun S => by rw [hresp], fun i => ?_⟩
  by_cases hs : s i = true
  · simp only [if_pos hs]
    exact align_tilted_eq p hp (E i)
  · simp only [if_neg hs]
    rw [align_comp_of_odd (negPerm p) (chiR p) hodd (base i), align_tilted_eq p hp (E i)]

/-! ## The dichotomy: what a null `R²` does establish -/

/-- **The MA-1 effectivity dichotomy.**  Fix a sample with response `y`, candidate criterion
feature `P` (the L-mass), and size covariate `x` (`log m`).  Assume the recorded ceiling
`rsq y (measurableClass P) ≤ ρ` for the whole nonlinear class of the criterion feature, and
a near-affine size decomposition with residual energy at most `η`.  Then:

1. every threshold criterion on `P` with a two-sided margin `δ` obeys
   `4δ²n₁n₂/n ≤ ρ·TSS`;
2. as soon as the size bound `1 − η/(b²‖x̃‖²/2 − η)` exceeds `ρ`, the single size covariate
   strictly outperforms the entire class of functions of `P`.

This is the exact sense in which experiment 566 is an honest negative: the criterion route
is capped, and the observed explanatory power of the sweep lives in modulus size. -/
theorem ma1_no_criterion_dichotomy {y P x r : ι → ℝ} {b η ρ t μ δ : ℝ}
    (hhigh : ∀ i, t ≤ P i → μ + δ ≤ y i) (hlow : ∀ i, ¬ t ≤ P i → y i ≤ μ - δ)
    (hδ : 0 ≤ δ) (hS : (univ.filter fun i => t ≤ P i).Nonempty)
    (hSc : (univ.filter fun i => t ≤ P i)ᶜ.Nonempty) (htss : 0 < tss y)
    (hrsq : rsq y (measurableClass P) ≤ ρ)
    (hdecomp : ∀ i, y i - mean y = b * (x i - mean x) + r i)
    (hr : sqNorm r ≤ η)
    (hspread : 2 * η < b ^ 2 * sqNorm (x - fun _ => mean x)) :
    (4 * δ ^ 2 * ((univ.filter fun i => t ≤ P i).card : ℝ)
        * (((univ.filter fun i => t ≤ P i)ᶜ).card : ℝ) / (Fintype.card ι : ℝ)
      ≤ ρ * tss y) ∧
    (ρ < 1 - η / (b ^ 2 * sqNorm (x - fun _ => mean x) / 2 - η) →
      rsq y (measurableClass P) < rsq y (affineClass x)) := by
  refine ⟨criterion_margin_le_of_rsq hhigh hlow hδ hS hSc htss hrsq, fun hgap => ?_⟩
  have hsize := rsq_affine_ge_of_noise hdecomp hr hspread
  linarith

end Ma1Effectivity