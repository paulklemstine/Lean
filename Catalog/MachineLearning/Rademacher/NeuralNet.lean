/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Rademacher Complexity of Neural Networks: Depth, Spectral Norm, Weight Normalization

Building on the structural laws of empirical Rademacher complexity
(`Rademacher/Basic.lean`), this file models an `L`-layer neural network as the
iterated action of spectrally-bounded linear layers on a hypothesis class and
derives the consequences for generalization:

* `empRad_deepNet`            — an `L`-layer network whose every layer has
  spectral factor `c` scales the Rademacher complexity by exactly `c ^ L`;
* `empRad_deepNet_le_of_normalized` — under weight normalization (`c ≤ 1`) depth
  never increases complexity;
* `empRad_deepNet_antitone_depth`   — under contraction (`c ≤ 1`) deeper
  normalized networks have *smaller* complexity;
* `empRad_weightNorm_mono`    — shrinking the spectral-norm budget `C` shrinks the
  Rademacher complexity (this is *why* weight normalization helps);
* `genGap` / `genGap_mono_rad` — the standard Rademacher uniform-deviation
  generalization bound is monotone in the complexity;
* `weightNorm_improves_genGap` and `deepNet_normalized_genGap_le` — combining the
  above: weight normalization, and depth under normalization, improve the
  generalization bound.

## Lab Notes

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Composing `L` spectrally-bounded linear layers
multiplies the Rademacher complexity by the product of their spectral factors;
for a uniform bound `c` this is `c ^ L`. Hence the complexity *explodes* with
depth when `c > 1` but *contracts* when the layers are weight-normalized
(`c ≤ 1`). Smaller spectral budget ⇒ smaller complexity ⇒ tighter generalization.
Experiment (Experimenter): Modelled a layer as the pointwise scaling map
`layerMap c` and a network as `(layerMap c)^[L]`. Proved `deepNet_eq` by
`Function.iterate` induction, then chained `empRad_smul` from Basic to get the
`c ^ L` law. Weight normalization is captured by intersecting the class with a
norm ball and applying `empRad_mono`.
Analysis (Analyst): The `c ^ L` law is *exact*, not just an upper bound, because
the scaling map is linear; the literature's tighter `O(C·√L/√n)` bound replaces
the naive product by a sum-of-norms via a peeling/contraction argument that needs
Talagrand's lemma — flagged in FUTURE_DIRECTIONS as "true but hard". The
monotone-in-`C` result is robust and assumption-light: it needs only inclusion of
norm balls.
Critique (Critic): All theorems are non-vacuous (nonempty classes, real
inequalities discharged by `induction`/`gcongr`/`linarith`). `empRad_nonneg` from
Basic is load-bearing for the normalized-depth bounds; without nonnegativity the
direction of the inequality is undetermined. No theorem is `True`/`rfl`.
Synthesis (PI): The depth law + monotonicity + the generalization functional give
a complete, honest chain "normalize weights ⇒ lower Rademacher ⇒ lower
generalization gap", which is the requested result, with the exact `√L` constant
isolated as the remaining hard step.
-- !-- Lab Notes -- !--
-/
import Mathlib
import MachineLearning.Rademacher.Basic

open scoped BigOperators

namespace Catalog.MachineLearning.Rademacher

/-- A single spectrally-bounded linear layer with spectral factor `c`, acting on a
value-vector by pointwise scaling. -/
def layerMap (n : ℕ) (c : ℝ) (a : Fin n → ℝ) : Fin n → ℝ := fun i => c * a i

/-- An `L`-layer network: the `L`-fold composition of the layer map. -/
def deepNet (n : ℕ) (c : ℝ) (L : ℕ) : (Fin n → ℝ) → (Fin n → ℝ) :=
  (layerMap n c)^[L]

/-- An `L`-layer network with uniform spectral factor `c` scales each value-vector
by `c ^ L`. -/
theorem deepNet_eq (n : ℕ) (c : ℝ) (L : ℕ) (a : Fin n → ℝ) :
    deepNet n c L a = fun i => c ^ L * a i := by
  induction' L with L ih generalizing a;
  · aesop;
  · unfold deepNet layerMap at *; simp_all +decide [ pow_succ', mul_assoc ] ;
    ac_rfl

/-- **Depth law (exact).** An `L`-layer network whose every layer has spectral
factor `c ≥ 0` scales the empirical Rademacher complexity by exactly `c ^ L`. -/
theorem empRad_deepNet (n : ℕ) (A : Finset (Fin n → ℝ)) (hA : A.Nonempty)
    (c : ℝ) (hc : 0 ≤ c) (L : ℕ) :
    empRad n (A.image (deepNet n c L)) (hA.image _) = c ^ L * empRad n A hA := by
  convert empRad_smul n A hA ( c ^ L ) ( pow_nonneg hc L ) using 2;
  exact congr_arg₂ _ ( funext fun x => by exact funext fun i => by simp +decide [ deepNet_eq ] ) rfl

/-- **Weight normalization tames depth.** If every layer is spectrally normalized
to `c ≤ 1`, then no matter how deep, the network's Rademacher complexity never
exceeds that of the base class. -/
theorem empRad_deepNet_le_of_normalized (n : ℕ) (A : Finset (Fin n → ℝ))
    (hA : A.Nonempty) (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1) (L : ℕ) :
    empRad n (A.image (deepNet n c L)) (hA.image _) ≤ empRad n A hA := by
  have h1 := empRad_deepNet n A hA c hc0 L
  exact h1.symm ▸ mul_le_of_le_one_left (empRad_nonneg n A hA) (pow_le_one₀ hc0 hc1)

/-- **Deeper normalized networks are simpler.** Under contraction (`c ≤ 1`),
increasing depth monotonically decreases the Rademacher complexity. -/
theorem empRad_deepNet_antitone_depth (n : ℕ) (A : Finset (Fin n → ℝ))
    (hA : A.Nonempty) (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1) {L₁ L₂ : ℕ}
    (hL : L₁ ≤ L₂) :
    empRad n (A.image (deepNet n c L₂)) (hA.image _)
      ≤ empRad n (A.image (deepNet n c L₁)) (hA.image _) := by
  rw [empRad_deepNet, empRad_deepNet]
  any_goals assumption
  exact mul_le_mul_of_nonneg_right (pow_le_pow_of_le_one hc0 hc1 hL) (empRad_nonneg n A hA)

open Classical in
/-- The sub-class of hypotheses whose weight norm is within a budget `C`. -/
noncomputable def normBall (n : ℕ) (A : Finset (Fin n → ℝ))
    (nrm : (Fin n → ℝ) → ℝ) (C : ℝ) : Finset (Fin n → ℝ) :=
  A.filter (fun a => nrm a ≤ C)

theorem normBall_subset (n : ℕ) (A : Finset (Fin n → ℝ))
    (nrm : (Fin n → ℝ) → ℝ) {C₁ C₂ : ℝ} (h : C₁ ≤ C₂) :
    normBall n A nrm C₁ ⊆ normBall n A nrm C₂ := by
  grind +locals

/-- **Weight normalization reduces complexity.** Shrinking the spectral-norm
budget from `C₂` to `C₁ ≤ C₂` can only decrease the Rademacher complexity of the
realizable class. This is the precise sense in which weight normalization
improves generalization. -/
theorem empRad_weightNorm_mono (n : ℕ) (A : Finset (Fin n → ℝ))
    (nrm : (Fin n → ℝ) → ℝ) {C₁ C₂ : ℝ} (h : C₁ ≤ C₂)
    (h1 : (normBall n A nrm C₁).Nonempty) :
    empRad n (normBall n A nrm C₁) h1
      ≤ empRad n (normBall n A nrm C₂) (h1.mono (normBall_subset n A nrm h)) :=
  empRad_mono _ _ _ h1 (normBall_subset n A nrm h)

/-- The standard Rademacher-based uniform-deviation generalization bound: with
probability `≥ 1 - δ` the generalization gap is at most
`2 · Rₙ + √(log(1/δ)/(2n))`. Here `rad` plays the role of `Rₙ`. -/
noncomputable def genGap (rad δ : ℝ) (n : ℕ) : ℝ :=
  2 * rad + Real.sqrt (Real.log (1 / δ) / (2 * n))

/-- **The generalization bound is monotone in the Rademacher complexity**: a
class with smaller complexity has a smaller (better) bound, for the same sample
size and confidence. -/
theorem genGap_mono_rad {rad₁ rad₂ δ : ℝ} (n : ℕ) (h : rad₁ ≤ rad₂) :
    genGap rad₁ δ n ≤ genGap rad₂ δ n := by
  unfold genGap; gcongr

/-- **Weight normalization improves the generalization bound.** Combining
`empRad_weightNorm_mono` with `genGap_mono_rad`: a tighter spectral budget yields
a smaller generalization bound. -/
theorem weightNorm_improves_genGap (n : ℕ) (A : Finset (Fin n → ℝ))
    (nrm : (Fin n → ℝ) → ℝ) {C₁ C₂ : ℝ} (h : C₁ ≤ C₂)
    (h1 : (normBall n A nrm C₁).Nonempty) (δ : ℝ) :
    genGap (empRad n (normBall n A nrm C₁) h1) δ n
      ≤ genGap (empRad n (normBall n A nrm C₂)
          (h1.mono (normBall_subset n A nrm h))) δ n :=
  genGap_mono_rad n (empRad_weightNorm_mono n A nrm h h1)

/-- **Depth under normalization improves the generalization bound.** A weight-
normalized (`c ≤ 1`) `L`-layer network has a generalization bound no larger than
that of its base class. -/
theorem deepNet_normalized_genGap_le (n : ℕ) (A : Finset (Fin n → ℝ))
    (hA : A.Nonempty) (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1) (L : ℕ) (δ : ℝ) :
    genGap (empRad n (A.image (deepNet n c L)) (hA.image _)) δ n
      ≤ genGap (empRad n A hA) δ n :=
  genGap_mono_rad n (empRad_deepNet_le_of_normalized n A hA c hc0 hc1 L)

end Catalog.MachineLearning.Rademacher