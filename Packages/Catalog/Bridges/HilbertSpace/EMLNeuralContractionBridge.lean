import Mathlib
import EML.FixedPointConvergence
import EML.PosetTheory.FixedPointConcreteInstance
import MachineLearning.ResNetLipschitz
/-!
# Bridge: EML Fixed-Point Contraction ↔ ResNet Residual-Block Lipschitz Growth

This file connects **two different catalog domains**:

* `EML/FixedPointConvergence.lean` and `EML/FixedPointConcreteInstance.lean`
  (domain **EML**): the EML single operator `f(x) = exp(a)·log(b·x + c)` is a
  `ρ`-contraction on an invariant interval `[lo, hi]`
  (`EMLIterOp.lipschitz_of_deriv_bound`, bundled in `EMLContractionData`), with an
  explicit instance `concreteEML` (`ρ = 1/30`).

* `MachineLearning/ResNetLipschitz.lean` (domain **MachineLearning**): residual
  ("skip") connections grow Lipschitz constants *additively* not
  multiplicatively — `resnet_block_lipschitz` gives `‖(x+gx)-(y+gy)‖ ≤ (1+L)‖x-y‖`
  for an `L`-Lipschitz `g`, and `bernoulli_resnet` gives the depth bound
  `(1+L)^K ≥ 1 + K·L`.

**New connection.** ResNet's additive law requires a *globally* Lipschitz
residual `g`, but the EML operator is only contractive on its invariant interval.
We bridge the two by **clamping**: the projection `clamp lo hi x = min hi (max lo x)`
is `1`-Lipschitz and lands in `[lo, hi]`, so the clamped EML map
`g(x) = f(clamp lo hi x)` is globally `ρ`-Lipschitz. Feeding this into the
ResNet machinery turns the EML contraction into a certified **EML residual
network layer**: a single block is `(1+ρ)`-Lipschitz and a depth-`K` stack obeys
the Bernoulli growth `(1+ρ)^K ≥ 1 + K·ρ`. This makes the EML fixed-point operator
a legitimate, depth-stable ResNet residual, with the contraction ratio `ρ` of the
fixed-point theorem doubling as the residual block's Lipschitz budget.

## Main results

* `EMLNeuralContractionBridge.clampedEML_global_lipschitz` — the clamped EML map
  is globally `ρ`-Lipschitz (uses `EMLIterOp.lipschitz_of_deriv_bound`).
* `EMLNeuralContractionBridge.eml_residual_block_lipschitz` — an EML residual
  block is `(1+ρ)`-Lipschitz (uses `ResNetLipschitz.resnet_block_lipschitz`).
* `EMLNeuralContractionBridge.eml_residual_network_certified` — the packaged
  cross-domain statement: residual-block additivity + Bernoulli depth growth +
  the contraction regime `0 ≤ ρ < 1`.
* `EMLNeuralContractionBridge.concrete_eml_residual_certified` — non-vacuity via
  the concrete `ρ = 1/30` instance.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The EML contraction ratio `ρ` of the fixed-point
theorem is *the same object* as a ResNet residual block's Lipschitz budget, so an
EML operator can be dropped in as a residual layer and inherit ResNet's
depth-stability (additive, not multiplicative, growth). The obstruction — EML is
only contractive on an interval — should dissolve under clamping.

Experiment (Experimenter): Define `clamp lo hi x = min hi (max lo x)`. Prove
(i) `clamp x ∈ [lo, hi]` and (ii) `|clamp x − clamp y| ≤ |x − y|` (each of `min`,
`max` is `1`-Lipschitz). Compose with `EMLIterOp.lipschitz_of_deriv_bound` (EML
domain) to get the global bound `|g x − g y| ≤ ρ·|x − y|` for `g = f∘clamp`. Then
`ResNetLipschitz.resnet_block_lipschitz` (ML domain) yields the `(1+ρ)` block
bound and `ResNetLipschitz.bernoulli_resnet` the `(1+ρ)^K ≥ 1+Kρ` depth bound.
Reconcile `ℝ`'s `‖·‖` with `|·|` via `Real.norm_eq_abs`.

Analysis (Analyst): The decisive structural fact is that clamping is the *unique*
piece of glue: it is the `1`-Lipschitz retraction onto the invariant set, so it
costs nothing in the Lipschitz budget (factor `1`) while globalizing the EML
bound. The interface between domains is again a single scalar inequality
(`0 ≤ ρ`, plus `ρ < 1` for the contraction regime). Everything analytic (the
ratio `ρ`) is EML; everything depth-structural (additive composition, Bernoulli)
is ML.

Critique (Critic): Is the clamp a cheat that changes the dynamics? No — on the
invariant interval `clamp = id`, so the residual block agrees with the genuine
EML residual exactly where the iteration lives; clamping only tames the map
outside, which is precisely what a deployed layer needs. Is it vacuous?
`concrete_eml_residual_certified` instantiates everything at `ρ = 1/30` from the
verified `concreteEML`, so the class is inhabited by a real `exp`-`log` operator.

Synthesis (PI): The EML fixed-point operator is a certified ResNet residual
layer: one block is `(1+ρ)`-Lipschitz, depth-`K` growth is the polynomial-floor
`(1+ρ)^K ≥ 1+Kρ`, and `ρ` is exactly the fixed-point contraction ratio. EML
dynamics and residual-network depth stability are two faces of one constant.
-- !-- Lab Notes -- !--
-/

noncomputable section

open Real Set

namespace EMLNeuralContractionBridge

open EMLIterOp ResNetLipschitz

/-- Projection (clamp) onto the closed interval `[lo, hi]`: `min hi (max lo x)`. -/
def clamp (lo hi x : ℝ) : ℝ := min hi (max lo x)

/-
The clamp lands in `[lo, hi]` whenever `lo ≤ hi`.
-/
theorem clamp_mem_Icc {lo hi : ℝ} (h : lo ≤ hi) (x : ℝ) :
    clamp lo hi x ∈ Icc lo hi := by
  exact ⟨ le_min h ( le_max_left _ _ ), min_le_left _ _ ⟩

/-
The clamp is `1`-Lipschitz: `|clamp x − clamp y| ≤ |x − y|`.
-/
theorem clamp_lipschitz (lo hi x y : ℝ) :
    |clamp lo hi x - clamp lo hi y| ≤ |x - y| := by
  unfold clamp;
  cases max_cases lo x <;> cases max_cases lo y <;> cases min_cases hi ( max lo x ) <;> cases min_cases hi ( max lo y ) <;> cases abs_cases ( x - y ) <;> cases abs_cases ( min hi ( max lo x ) - min hi ( max lo y ) ) <;> linarith

/-
**The clamped EML map is globally `ρ`-Lipschitz.** Composing the EML
operator with the `1`-Lipschitz clamp onto its invariant interval globalizes the
interval contraction bound `EMLIterOp.lipschitz_of_deriv_bound`.
-/
theorem clampedEML_global_lipschitz (D : EMLContractionData) (x y : ℝ) :
    |EMLIterOp D.a D.b D.c (clamp D.lo D.hi x) -
        EMLIterOp D.a D.b D.c (clamp D.lo D.hi y)| ≤ D.rho * |x - y| := by
  refine' le_trans _ ( mul_le_mul_of_nonneg_left ( clamp_lipschitz _ _ _ _ ) ( D.rho_nonneg ) );
  exact EMLIterOp.lipschitz_of_deriv_bound D.a D.b D.c D.lo D.hi D.rho D.lo_lt_hi D.arg_pos D.deriv_bound _ ( clamp_mem_Icc D.lo_lt_hi.le _ ) _ ( clamp_mem_Icc D.lo_lt_hi.le _ )

/-
**An EML residual block is `(1+ρ)`-Lipschitz.** Combining the global
contraction bound of the clamped EML map (EML domain) with the additive
residual-connection law `ResNetLipschitz.resnet_block_lipschitz` (MachineLearning
domain).
-/
theorem eml_residual_block_lipschitz (D : EMLContractionData) (x y : ℝ) :
    ‖(x + EMLIterOp D.a D.b D.c (clamp D.lo D.hi x)) -
        (y + EMLIterOp D.a D.b D.c (clamp D.lo D.hi y))‖ ≤ (1 + D.rho) * ‖x - y‖ := by
  -- Let $g(z) = EMLIterOp D.a D.b D.c (clamp D.lo D.hi z)$.
  set g : ℝ → ℝ := fun z => EMLIterOp D.a D.b D.c (clamp D.lo D.hi z);
  have h_lip : ∀ x y : ℝ, ‖g x - g y‖ ≤ D.rho * ‖x - y‖ := by
    convert clampedEML_global_lipschitz D using 1;
  convert ResNetLipschitz.resnet_block_lipschitz g D.rho _ h_lip x y using 1;
  exact D.rho_nonneg

/-
**Certified EML residual network (cross-domain headline).** For any EML
contraction datum `D`, the clamped EML residual block is `(1+ρ)`-Lipschitz, a
depth-`K` stack obeys the Bernoulli growth floor `(1+ρ)^K ≥ 1 + K·ρ`, and `ρ`
lies in the contraction regime `[0,1)`. This identifies the EML fixed-point
contraction ratio with a depth-stable ResNet residual Lipschitz budget.
-/
theorem eml_residual_network_certified (D : EMLContractionData) :
    (∀ x y : ℝ,
        ‖(x + EMLIterOp D.a D.b D.c (clamp D.lo D.hi x)) -
            (y + EMLIterOp D.a D.b D.c (clamp D.lo D.hi y))‖ ≤ (1 + D.rho) * ‖x - y‖) ∧
      (∀ K : ℕ, 1 + (K : ℝ) * D.rho ≤ (1 + D.rho) ^ K) ∧
      (0 ≤ D.rho ∧ D.rho < 1) := by
  refine' ⟨ _, _, D.rho_nonneg, D.rho_lt_one ⟩;
  · exact eml_residual_block_lipschitz D;
  · exact fun K => one_add_mul_le_pow ( by linarith [ D.rho_nonneg ] ) _

/-
**Non-vacuity.** The concrete EML operator `f(x) = exp(1)·log(x + 100)` on
`[0,20]` yields a certified EML residual layer with budget `ρ = 1/30`: each block
is `(1 + 1/30)`-Lipschitz and depth-`K` growth obeys `(1+1/30)^K ≥ 1 + K/30`.
-/
theorem concrete_eml_residual_certified :
    (∀ x y : ℝ,
        ‖(x + EMLIterOp 1 1 100 (clamp 0 20 x)) -
            (y + EMLIterOp 1 1 100 (clamp 0 20 y))‖ ≤ (1 + 1 / 30) * ‖x - y‖) ∧
      (∀ K : ℕ, 1 + (K : ℝ) * (1 / 30) ≤ (1 + 1 / 30) ^ K) := by
  refine' ⟨ _, _ ⟩;
  · convert eml_residual_block_lipschitz concreteEML using 1;
  · exact fun K => one_add_mul_le_pow ( by norm_num ) _

end EMLNeuralContractionBridge

end