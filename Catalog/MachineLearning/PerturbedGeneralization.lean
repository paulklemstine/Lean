/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Perturbation-Stable Generalization Bounds

This file is a **cross-domain bridge** in the `MachineLearning` catalog.  It
connects two previously disconnected threads:

* `MachineLearning/CompressionGeneralization.lean` — the Occam / compression
  generalization bound `occamBound R C n δ = R + sqrt ((C + log(1/δ))/(2n))`,
  governing how empirical risk plus description-length complexity controls the
  true risk; and
* the *Lipschitz perturbation-stability* theme (the subject of
  `MachineLearning/Stability.lean`), governing how the loss of a model changes
  under bounded input perturbations.

The synthesis is the **perturbation-stable Occam bound**

  `perturbedOccamBound R C L ρ n δ = occamBound (R + L·ρ) C n δ`,

which certifies the true risk of a model evaluated on data perturbed by up to
`ρ` in input space, when the loss is `L`-Lipschitz.  The single extra term `L·ρ`
is the entire price of adversarial robustness inside an otherwise unchanged
compression bound.

## Main results

* `lipschitz_perturbation_le`        — per-point: an `L`-Lipschitz loss rises by ≤ `L·ρ` under a ρ-perturbation
* `robust_empRisk_valid`             — dataset: the worst-case perturbed empirical risk ≤ `R + L·ρ`
* `perturbed_ge_clean`               — perturbation can only loosen the certificate
* `perturbed_gap_decomposition`      — the excess over `R` splits into robustness `L·ρ` + capacity penalty
* `perturbed_collapse`               — with no perturbation (`ρ=0`) or no sensitivity (`L=0`) the clean bound is recovered
* `perturbed_bound_tendsto`          — **consistency**: the bound → `R + L·ρ` as `n → ∞` (robustness is the irreducible floor)
* `perturbed_sample_complexity`      — inversion: `n ≥ (C+log(1/δ))/(2ε²)` ⟹ bound ≤ `R + L·ρ + ε`
* `perturbed_certificate`            — **the bridge**: the clean-data certificate + margin dominates the true perturbed bound
* `perturbed_overparam_invariance`   — the perturbed bound still ignores raw parameter count

## The key insight

Robustness and generalization are usually studied with disjoint machinery.  The
compression bound shows generalization is controlled by *description length*; the
Lipschitz analysis shows robustness is controlled by *the constant `L` and the
radius `ρ`*.  Composing them is exact and additive: the robust generalization
certificate is the clean Occam bound with its empirical-risk slot shifted by the
single scalar `L·ρ`.  Nothing else in the capacity penalty changes — in
particular `perturbed_overparam_invariance` shows robustness does **not**
reintroduce a dependence on parameter count.
-/
import Mathlib
import MachineLearning.CompressionGeneralization

open Real Filter Topology

noncomputable section

namespace PerturbedGen

open CompressionGen

/-! ## Definitions -/

/-- The **robust empirical risk**: the clean empirical risk `R` inflated by the
worst-case loss increase `L·ρ` produced by perturbing inputs by up to `ρ`
against an `L`-Lipschitz loss. -/
def robustEmpRisk (R L ρ : ℝ) : ℝ := R + L * ρ

/-- The **perturbation-stable Occam bound**: the compression generalization
bound evaluated at the robust empirical risk. -/
def perturbedOccamBound (R C L ρ : ℝ) (n : ℕ) (δ : ℝ) : ℝ :=
  occamBound (robustEmpRisk R L ρ) C n δ

/-! ## Lipschitz stability → robust empirical risk -/

-- !-- Per-point perturbation bound: an `L`-Lipschitz loss can grow by at most
-- `L·ρ` under any perturbation of radius `≤ ρ`; immediate from `dist_le_mul`. -- !--
/-- If the loss `ℓ` is `L`-Lipschitz, then perturbing the input within radius `ρ`
raises the loss by at most `L·ρ`. -/
theorem lipschitz_perturbation_le
    {X : Type*} [PseudoMetricSpace X] {ℓ : X → ℝ} {L : ℝ} (hL : 0 ≤ L)
    (hLip : LipschitzWith ⟨L, hL⟩ ℓ) {x y : X} {ρ : ℝ} (hxy : dist x y ≤ ρ) :
    ℓ y ≤ ℓ x + L * ρ := by
  have h := hLip.dist_le_mul x y
  simp only [Real.dist_eq, NNReal.coe_mk] at h
  have h3 : L * dist x y ≤ L * ρ := mul_le_mul_of_nonneg_left hxy hL
  have h4 : ℓ y - ℓ x ≤ |ℓ x - ℓ y| := by rw [abs_sub_comm]; exact le_abs_self _
  linarith

-- !-- Dataset-level robustness: averaging the per-point bound over a finite
-- training set shows the worst-case perturbed empirical risk is `≤ R + L·ρ`. -- !--
/-- The mean perturbed loss over a finite dataset is at most the mean clean loss
plus `L·ρ`.  This validates `robustEmpRisk` as a genuine upper bound on the
perturbed empirical risk. -/
theorem robust_empRisk_valid
    {X : Type*} [PseudoMetricSpace X] {ι : Type*} {ℓ : X → ℝ} {L ρ : ℝ}
    (hL : 0 ≤ L) (hLip : LipschitzWith ⟨L, hL⟩ ℓ)
    (s : Finset ι) (x y : ι → X)
    (hd : ∀ i ∈ s, dist (x i) (y i) ≤ ρ) :
    (∑ i ∈ s, ℓ (y i)) ≤ (∑ i ∈ s, ℓ (x i)) + s.card * (L * ρ) := by
  calc (∑ i ∈ s, ℓ (y i)) ≤ ∑ i ∈ s, (ℓ (x i) + L * ρ) :=
        Finset.sum_le_sum (fun i hi => lipschitz_perturbation_le hL hLip (hd i hi))
    _ = (∑ i ∈ s, ℓ (x i)) + s.card * (L * ρ) := by
        rw [Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul]

/-! ## Structure of the perturbed bound -/

-- !-- The robust empirical risk is monotone in `R`, hence the Occam bound is
-- too; perturbing can only loosen the certificate. -- !--
/-- Adding a nonnegative robustness budget `L·ρ` never tightens the bound. -/
theorem perturbed_ge_clean (R C L ρ : ℝ) (n : ℕ) (δ : ℝ) (h : 0 ≤ L * ρ) :
    occamBound R C n δ ≤ perturbedOccamBound R C L ρ n δ := by
  unfold perturbedOccamBound robustEmpRisk occamBound; linarith

-- !-- Unfolding the definitions, the excess of the perturbed bound over the
-- clean empirical risk `R` splits exactly into the robustness term `L·ρ` and the
-- capacity penalty `sqrt(...)`. -- !--
/-- The perturbed bound, measured against the clean empirical risk, decomposes
into a robustness term `L·ρ` plus the usual capacity penalty. -/
theorem perturbed_gap_decomposition (R C L ρ : ℝ) (n : ℕ) (δ : ℝ) :
    perturbedOccamBound R C L ρ n δ - R
      = L * ρ + Real.sqrt ((C + Real.log (1 / δ)) / (2 * n)) := by
  unfold perturbedOccamBound robustEmpRisk occamBound; ring

-- !-- With no perturbation (`ρ = 0`) or a perturbation-insensitive loss
-- (`L = 0`) the robustness term vanishes and the clean Occam bound is recovered. -- !--
/-- If either the radius `ρ` or the Lipschitz constant `L` is zero, the perturbed
bound collapses to the clean Occam bound. -/
theorem perturbed_collapse (R C L ρ : ℝ) (n : ℕ) (δ : ℝ) (h : L * ρ = 0) :
    perturbedOccamBound R C L ρ n δ = occamBound R C n δ := by
  unfold perturbedOccamBound robustEmpRisk; rw [h, add_zero]

/-! ## Consistency and sample complexity -/

-- !-- Generalizes `occam_gap_tendsto_zero`: the capacity penalty still vanishes,
-- so the perturbed bound converges to its irreducible robustness floor `R+L·ρ`. -- !--
/-- **Consistency.** With fixed complexity the perturbed bound converges, as the
sample size grows, to the robustness floor `R + L·ρ` (not to `R`). -/
theorem perturbed_bound_tendsto (R C L ρ δ : ℝ) :
    Tendsto (fun n : ℕ => perturbedOccamBound R C L ρ n δ) atTop
      (𝓝 (R + L * ρ)) := by
  have h := occam_gap_tendsto_zero (robustEmpRisk R L ρ) C δ
  have h2 := h.add (tendsto_const_nhds (x := robustEmpRisk R L ρ))
  rw [zero_add] at h2
  have hf : (fun n : ℕ => perturbedOccamBound R C L ρ n δ)
      = (fun n => (occamBound (robustEmpRisk R L ρ) C n δ - robustEmpRisk R L ρ)
          + robustEmpRisk R L ρ) := by
    funext n; unfold perturbedOccamBound; ring
  rw [hf]; simpa [robustEmpRisk] using h2

-- !-- Lab Notebook: perturbed_bound_tendsto -- !--
-- !-- Hypothesis: Under perturbation the generalization gap no longer vanishes;
--     it should converge to the irreducible robustness floor R + L·ρ. -- !--
-- !-- Result: Proved by reduction to the catalog's `occam_gap_tendsto_zero`:
--     the capacity penalty still → 0, so the bound → robustEmpRisk = R + L·ρ. -- !--
-- !-- Insight: Robustness changes the *limit* of the bound, not its *rate* of
--     convergence — a clean separation of the statistical (n) and adversarial
--     (L·ρ) axes that mirrors `memorization_gap_limit` in the catalog. -- !--
-- !-- Failure analysis: Adding the constant back required rewriting the function
--     as (gap + floor) via `funext`/`ring`; a naive `convert` left the limit
--     value unmatched until `simpa [robustEmpRisk]` unfolded R + L·ρ. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Inversion built on `occam_sample_complexity` applied at the robust
-- empirical risk: once `n` is large enough the penalty drops below `ε`. -- !--
/-- **Sample complexity.** Once `n ≥ (C+log(1/δ))/(2ε²)`, the perturbed bound is
within `ε` of the robustness floor `R + L·ρ`. -/
theorem perturbed_sample_complexity (R C L ρ δ ε : ℝ) (n : ℕ)
    (hε : 0 < ε) (hC : 0 ≤ C + Real.log (1 / δ))
    (hn : (C + Real.log (1 / δ)) / (2 * ε ^ 2) ≤ (n : ℝ)) :
    perturbedOccamBound R C L ρ n δ ≤ R + L * ρ + ε := by
  unfold perturbedOccamBound robustEmpRisk
  have := occam_sample_complexity (R + L * ρ) C δ ε n hε hC hn
  linarith

/-! ## The bridge: a robust certificate from clean data -/

-- !-- Monotonicity of `occamBound` in its empirical-risk slot, combined with
-- `robust_empRisk_valid`, shows the certificate computed on clean data plus the
-- robustness margin dominates the bound on any ρ-perturbed dataset. -- !--
/-- Monotonicity of the Occam bound in the empirical-risk argument. -/
theorem occam_mono_risk (R₁ R₂ C : ℝ) (n : ℕ) (δ : ℝ) (h : R₁ ≤ R₂) :
    occamBound R₁ C n δ ≤ occamBound R₂ C n δ := by
  unfold occamBound; linarith

/-- **The bridge theorem.** Let `R` be the clean mean empirical risk and `R'` the
mean risk on any dataset perturbed within radius `ρ`.  If the loss is
`L`-Lipschitz, then the Occam bound on the *perturbed* data is dominated by the
perturbation-stable bound built from the *clean* data — a robustness certificate
computable before any perturbation is seen. -/
theorem perturbed_certificate
    {X : Type*} [PseudoMetricSpace X] {ι : Type*} {ℓ : X → ℝ} {L ρ : ℝ}
    (hL : 0 ≤ L) (hLip : LipschitzWith ⟨L, hL⟩ ℓ)
    (s : Finset ι) (hs : s.Nonempty) (x y : ι → X)
    (hd : ∀ i ∈ s, dist (x i) (y i) ≤ ρ)
    (C : ℝ) (n : ℕ) (δ : ℝ) :
    occamBound ((∑ i ∈ s, ℓ (y i)) / s.card) C n δ
      ≤ perturbedOccamBound ((∑ i ∈ s, ℓ (x i)) / s.card) C L ρ n δ := by
  unfold perturbedOccamBound robustEmpRisk
  apply occam_mono_risk
  have hvalid : (∑ i ∈ s, ℓ (y i)) ≤ (∑ i ∈ s, ℓ (x i)) + s.card * (L * ρ) :=
    robust_empRisk_valid hL hLip s x y hd
  have hcard : (0:ℝ) < s.card := by exact_mod_cast Finset.card_pos.mpr hs
  rw [div_le_iff₀ hcard, add_mul, div_mul_cancel₀ _ (ne_of_gt hcard)]
  nlinarith [hvalid]

-- !-- Lab Notebook: perturbed_certificate -- !--
-- !-- Hypothesis: A robustness certificate computed purely on clean data should
--     upper-bound the Occam bound evaluated on any ρ-perturbed dataset. -- !--
-- !-- Result: Proved. `robust_empRisk_valid` (Lipschitz averaging) controls the
--     perturbed mean risk by `cleanMean + L·ρ`, and `occam_mono_risk`
--     (monotonicity of the bound in its risk slot) lifts this to the bounds. -- !--
-- !-- Insight: The two catalog threads compose multiplicatively-free: the only
--     coupling is the scalar `L·ρ` slotted into the empirical-risk argument, so
--     robustness costs exactly one additive term and nothing in the penalty. -- !--
-- !-- Failure analysis: A direct `gcongr`/`linarith` attack failed because the
--     mean-risk division must be cleared first (`div_le_iff₀` + `div_mul_cancel₀`)
--     before the linear robustness inequality can be applied. -- !--
-- !-- End Lab Notebook -- !--

/-! ## Overparameterization is preserved under perturbation -/

/-- The perturbed certified bound attached to a network. -/
def _root_.CompressionGen.Net.perturbedBound (net : Net) (L ρ : ℝ) (n : ℕ) (δ : ℝ) : ℝ :=
  perturbedOccamBound net.empRisk (net.bits * Real.log 2) L ρ n δ

-- !-- The robustness term `L·ρ` and complexity both depend only on description
-- length and risk, never on `params`; so the perturbed bound is param-invariant. -- !--
/-- **Overparameterization invariance survives robustness.** Two networks with
equal compressed description length and empirical risk receive identical
perturbed bounds, regardless of raw parameter count. -/
theorem perturbed_overparam_invariance (net₁ net₂ : Net) (L ρ : ℝ) (n : ℕ) (δ : ℝ)
    (hb : net₁.bits = net₂.bits) (he : net₁.empRisk = net₂.empRisk) :
    net₁.perturbedBound L ρ n δ = net₂.perturbedBound L ρ n δ := by
  unfold CompressionGen.Net.perturbedBound; rw [hb, he]

/-! ## Generalization: heterogeneous Lipschitz constants -/

-- !-- Heterogeneous generalization of `robust_empRisk_valid`: summing the
-- per-example perturbation bounds with their own constants `L i` and radii `ρ i`. -- !--
/-- **Heterogeneous Lipschitz robustness.** With per-example Lipschitz constants
`L i` and per-example radii `ρ i`, the worst-case perturbed empirical risk is
controlled by the *sum* `∑ L i · ρ i`, refining the uniform `L·ρ` bound of
`robust_empRisk_valid`.  (The boundary case `L i · ρ i` exceeding the per-example
margin, where a downstream classification certificate would become vacuous, is
discussed in `FUTURE_DIRECTIONS.md`.) -/
theorem robust_empRisk_heterogeneous
    {X : Type*} [PseudoMetricSpace X] {ι : Type*} {ℓ : X → ℝ}
    {L ρ : ι → ℝ} (hL : ∀ i, 0 ≤ L i)
    (hLip : ∀ i, LipschitzWith ⟨L i, hL i⟩ ℓ)
    (s : Finset ι) (x y : ι → X)
    (hd : ∀ i ∈ s, dist (x i) (y i) ≤ ρ i) :
    (∑ i ∈ s, ℓ (y i)) ≤ (∑ i ∈ s, ℓ (x i)) + ∑ i ∈ s, L i * ρ i := by
  calc (∑ i ∈ s, ℓ (y i)) ≤ ∑ i ∈ s, (ℓ (x i) + L i * ρ i) :=
        Finset.sum_le_sum (fun i hi => lipschitz_perturbation_le (hL i) (hLip i) (hd i hi))
    _ = (∑ i ∈ s, ℓ (x i)) + ∑ i ∈ s, L i * ρ i := by rw [Finset.sum_add_distrib]

end PerturbedGen

end