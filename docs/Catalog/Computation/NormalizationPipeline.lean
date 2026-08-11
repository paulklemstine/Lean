/-
# Normalization Pipelines: entropy is exactly additive, fiber counting is not

## Where this sits in the thread

`Computation/FiberUniformityLaw.lean` (this cycle) proved the **fiber-entropy law**: the
entropy destroyed by a normalization map equals the expected logarithm of the fiber size
exactly on fiberwise-uniform laws.  That is a statement about a *single* normalization step.
This file asks what happens along a *pipeline* `α → β → γ` of two normalizations, and finds a
sharp dichotomy.

* The **conditional entropy is exactly additive** along a pipeline
  (`condEntropyW_comp`), for every non-negative law: the thermodynamic cost of normalizing in
  two stages is the cost of the first stage plus the cost of the second stage run on the
  pushed-forward law.  There is no correction term.
* The **fiber-counting estimate is only subadditive, and only for uniform laws**
  (`expectedLogFiber_comp_le_unif`), with an exact equality criterion
  (`expectedLogFiber_comp_eq_unif_iff`), and it **fails outright** for general laws
  (`expectedLogFiber_not_subadditive`): a three-term calculus with a skewed law makes the
  two-stage fiber count *strictly smaller* than the honest one-stage fiber count.

So the fiber-counting heuristic, which the fiber-entropy law shows to be exact per step under
uniformity, is not even an upper bound once steps are composed and the law is skewed.  This
is a structural failure, not a statistical one.

## Main results

* `pushforward_comp` — normalization pushforwards compose: `(g ∘ f)_* = g_* ∘ f_*`.
* `condEntropyW_comp` — **the pipeline chain rule**
  `H(x ∣ g(f x)) = H(x ∣ f x) + H(f x ∣ g(f x))`, valid for every non-negative law.
* `expectedLogFiber_comp_le_unif` — **subadditivity of fiber counting for uniform laws**,
  obtained from the chain rule together with the fiber-entropy law.
* `expectedLogFiber_comp_eq_unif_iff` — equality holds **iff** all `f`-fibers lying over one
  `g`-fiber have the same size.
* `expectedLogFiber_not_subadditive` — **the counterexample**: for
  `f = ![0,1,1] : Fin 3 → Fin 2`, `g : Fin 2 → Fin 1` the total collapse and the skewed law
  `(4/5, 1/10, 1/10)`, the two-stage estimate is `6/5` while the one-stage estimate is
  `log₂ 3 ≈ 1.585`.
* `pipeline_dichotomy` — the two statements side by side on the counterexample: the entropy
  accounting is additive there, the fiber accounting is not even subadditive.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): both the conditional entropy and the fiber-counting estimate should be
  additive along pipelines, since both were shown to agree on single uniform steps.
Experiment (Stage 2): the entropy half is immediate from `condEntropyW_chain_rule` once
  `pushforward_comp` is available.  The fiber half was tested numerically first:
  with `f`-fiber sizes `(n_b)` over a common `g`-fiber and pushed weights `(P(b))`, the
  required inequality is `log₂ (∑_b n_b) ≤ (∑_b P(b) log₂ n_b)/(∑_b P(b)) + log₂ m`, which
  fails as soon as `P` concentrates on a *small* `f`-fiber sitting next to a large one.
Experiment (Stage 2, numeric): `n = (1, 2)`, `m = 2`, `P = (4/5, 1/5)` gives left-hand side
  `log₂ 3 = 1.58496` and right-hand side `1/5 + 1 = 1.2`.  The gap `0.38496` is realised by
  the explicit `Fin 3 → Fin 2 → Fin 1` pipeline of this file.
Analysis (Stage 3): the failure is exactly the failure of the fiber-entropy law's hypothesis
  one level up — `f_*p` need not be constant on `g`-fibers even when `p` is constant on
  `f`-fibers, and the fiber count of the composite is the *sum* of the `f`-fiber sizes, an
  `ℓ¹` quantity, while the two-stage estimate is a weighted geometric mean.  Under a uniform
  law the two effects cancel exactly, which is why the uniform statement survives.
Critique (Stage 4): the counterexample uses a fully supported law (`4/5, 1/10, 1/10`), not a
  point mass, so it is not an artefact of degenerate weights; and the equality criterion for
  the uniform case is stated as an `iff`, so the boundary is exact.
Synthesis (Stage 5): entropy composes, multiplicity does not.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof
import Computation.PrefixFreeThermoCoding
import Computation.ReversibleVerificationFrontier
import Computation.FiberEntropyFrontier
import Computation.WeightedFiberEntropy
import Computation.FiberUniformityLaw

open Finset Real ThermoProof ReversibleFrontier WeightedFiberEntropy FiberUniformity

namespace NormalizationPipeline

variable {α β γ : Type*} [Fintype α] [Fintype β] [Fintype γ]
  [DecidableEq β] [DecidableEq γ]

/-! ## Pushforwards compose -/

omit [Fintype γ] in
/-- Normalization pushforwards compose: running the pipeline is the same as running the two
stages in turn. -/
theorem pushforward_comp (f : α → β) (g : β → γ) (p : α → ℝ) :
    pushforward (fun x => g (f x)) p = pushforward g (pushforward f p) := by
  classical
  funext c
  have hmaps : ∀ x ∈ fiber (fun x => g (f x)) c, f x ∈ fiber g c := by
    intro x hx
    rw [mem_fiber] at hx ⊢
    exact hx
  have hsplit := Finset.sum_fiberwise_of_maps_to hmaps p
  have hinner : ∀ b ∈ fiber g c,
      {x ∈ fiber (fun x => g (f x)) c | f x = b} = fiber f b := by
    intro b hb
    ext x
    simp only [Finset.mem_filter, mem_fiber]
    constructor
    · rintro ⟨-, h⟩; exact h
    · intro h
      refine ⟨?_, h⟩
      rw [h]; exact mem_fiber.1 hb
  rw [pushforward, ← hsplit, Finset.sum_congr rfl (fun b hb => by rw [hinner b hb])]
  rfl

/-! ## The pipeline chain rule -/

/-- **The pipeline chain rule.**  The entropy destroyed by a two-stage normalization is
exactly the entropy destroyed by the first stage plus the entropy destroyed by the second
stage acting on the pushed-forward law.  This holds for every non-negative law, with no
correction term. -/
theorem condEntropyW_comp (f : α → β) (g : β → γ) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x) :
    condEntropyW (fun x => g (f x)) p
      = condEntropyW f p + condEntropyW g (pushforward f p) := by
  have h1 := condEntropyW_chain_rule (fun x => g (f x)) p hp
  have h2 := condEntropyW_chain_rule f p hp
  have h3 := condEntropyW_chain_rule g (pushforward f p) (pushforward_nonneg hp)
  rw [h1, h2, h3, pushforward_comp f g p]
  ring

/-! ## Fiber counting: subadditive for uniform laws -/

/-- **Subadditivity of the fiber-counting estimate under a uniform law.**  A direct
consequence of the pipeline chain rule and the fiber-entropy law: the uniform law is
fiberwise uniform for both `f` and `g ∘ f`, so both of those estimates are exact, while the
second stage is only bounded. -/
theorem expectedLogFiber_comp_le_unif [Nonempty α] (f : α → β) (g : β → γ) :
    expectedLogFiber (fun x => g (f x)) (unif α)
      ≤ expectedLogFiber f (unif α) + expectedLogFiber g (pushforward f (unif α)) := by
  have hcomp : condEntropyW (fun x => g (f x)) (unif α)
      = condEntropyW f (unif α) + condEntropyW g (pushforward f (unif α)) :=
    condEntropyW_comp f g (unif α) (unif_nonneg α)
  have e1 : condEntropyW (fun x => g (f x)) (unif α)
      = expectedLogFiber (fun x => g (f x)) (unif α) :=
    condEntropyW_unif_eq_expectedLogFiber _
  have e2 : condEntropyW f (unif α) = expectedLogFiber f (unif α) :=
    condEntropyW_unif_eq_expectedLogFiber _
  have e3 : condEntropyW g (pushforward f (unif α))
      ≤ expectedLogFiber g (pushforward f (unif α)) :=
    condEntropyW_le_expectedLogFiber g _ (pushforward_nonneg (unif_nonneg α))
  rw [e1, e2] at hcomp
  linarith

/-- **The exact equality criterion.**  Under a uniform law the two-stage fiber count agrees
with the one-stage fiber count exactly when all `f`-fibers lying over a common `g`-fiber have
the same size. -/
theorem expectedLogFiber_comp_eq_unif_iff [Nonempty α] (f : α → β) (g : β → γ) :
    expectedLogFiber (fun x => g (f x)) (unif α)
        = expectedLogFiber f (unif α) + expectedLogFiber g (pushforward f (unif α))
      ↔ ∀ b b', g b = g b' → (fiber f b).card = (fiber f b').card := by
  have hN : (0 : ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast this
  have hcomp : condEntropyW (fun x => g (f x)) (unif α)
      = condEntropyW f (unif α) + condEntropyW g (pushforward f (unif α)) :=
    condEntropyW_comp f g (unif α) (unif_nonneg α)
  have e1 : condEntropyW (fun x => g (f x)) (unif α)
      = expectedLogFiber (fun x => g (f x)) (unif α) :=
    condEntropyW_unif_eq_expectedLogFiber _
  have e2 : condEntropyW f (unif α) = expectedLogFiber f (unif α) :=
    condEntropyW_unif_eq_expectedLogFiber _
  rw [e1, e2] at hcomp
  have hlaw := fiber_entropy_law g (pushforward f (unif α))
    (pushforward_nonneg (unif_nonneg α))
  constructor
  · intro heq b b' hbb
    have hstage : condEntropyW g (pushforward f (unif α))
        = expectedLogFiber g (pushforward f (unif α)) := by linarith
    have := hlaw.1 hstage b b' hbb
    rw [pushforward_unif, pushforward_unif] at this
    have hcards : ((fiber f b).card : ℝ) = ((fiber f b').card : ℝ) := by
      field_simp at this
      exact this
    exact_mod_cast hcards
  · intro hcards
    have hstage : condEntropyW g (pushforward f (unif α))
        = expectedLogFiber g (pushforward f (unif α)) := by
      refine hlaw.2 ?_
      intro b b' hbb
      rw [pushforward_unif, pushforward_unif, hcards b b' hbb]
    linarith

/-! ## Fiber counting is not even subadditive for general laws -/

/-- The first stage: a normalization with fibers of sizes `1` and `2`. -/
def fex : Fin 3 → Fin 2 := ![0, 1, 1]

/-- The second stage: a total collapse. -/
def gex : Fin 2 → Fin 1 := fun _ => 0

/-- A skewed, fully supported law on the three proof terms. -/
noncomputable def pex : Fin 3 → ℝ := fun i => if i = 0 then 4/5 else 1/10

lemma pex_zero : pex 0 = 4/5 := by norm_num [pex]

lemma pex_one : pex 1 = 1/10 := by norm_num [pex]

lemma pex_two : pex 2 = 1/10 := by
  rw [pex, if_neg (by decide : ¬((2 : Fin 3) = 0))]

lemma pex_nonneg : ∀ x, 0 ≤ pex x := by
  intro x; fin_cases x <;> norm_num [pex]

lemma logb_two_three_gt : (6 : ℝ)/5 < Real.logb 2 3 := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log 64 < Real.log 243 := Real.log_lt_log (by norm_num) (by norm_num)
  have h2 : Real.log 64 = 6 * Real.log 2 := by
    rw [show (64 : ℝ) = 2 ^ (6 : ℕ) by norm_num, Real.log_pow]; push_cast; ring
  have h3 : Real.log 243 = 5 * Real.log 3 := by
    rw [show (243 : ℝ) = 3 ^ (5 : ℕ) by norm_num, Real.log_pow]; push_cast; ring
  rw [Real.logb, lt_div_iff₀ hlog2]
  nlinarith

lemma card_fiber_comp_ex (x : Fin 3) :
    (fiber (fun y => gex (fex y)) (gex (fex x))).card = 3 := by
  fin_cases x <;> decide

lemma expectedLogFiber_comp_ex :
    expectedLogFiber (fun y => gex (fex y)) pex = Real.logb 2 3 := by
  rw [expectedLogFiber, Fin.sum_univ_three, card_fiber_comp_ex 0, card_fiber_comp_ex 1,
    card_fiber_comp_ex 2, pex_zero, pex_one, pex_two]
  push_cast
  ring

lemma expectedLogFiber_fex : expectedLogFiber fex pex = 1/5 := by
  have h0 : (fiber fex (fex 0)).card = 1 := by decide
  have h1 : (fiber fex (fex 1)).card = 2 := by decide
  have h2 : (fiber fex (fex 2)).card = 2 := by decide
  rw [expectedLogFiber, Fin.sum_univ_three, h0, h1, h2, pex_zero, pex_one, pex_two]
  norm_num [Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]

lemma expectedLogFiber_gex : expectedLogFiber gex (pushforward fex pex) = 1 := by
  have hf0 : fiber fex (0 : Fin 2) = {0} := by decide
  have hf1 : fiber fex (1 : Fin 2) = {1, 2} := by decide
  have hp0 : pushforward fex pex 0 = 4/5 := by
    rw [pushforward, hf0, Finset.sum_singleton, pex_zero]
  have hp1 : pushforward fex pex 1 = 1/5 := by
    rw [pushforward, hf1, Finset.sum_pair (by decide), pex_one, pex_two]
    norm_num
  have hg0 : (fiber gex (gex 0)).card = 2 := by decide
  have hg1 : (fiber gex (gex 1)).card = 2 := by decide
  rw [expectedLogFiber, Fin.sum_univ_two, hg0, hg1, hp0, hp1]
  norm_num [Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]

/-- **The fiber-counting estimate is not subadditive along a normalization pipeline.**  With
a skewed (but fully supported) law, the two-stage estimate `6/5` is *strictly smaller* than
the honest one-stage estimate `log₂ 3`, so the naive multiplicity accounting under-reports
the cost of a pipeline.  Contrast `expectedLogFiber_comp_le_unif`, where the uniform law
makes the inequality go the other way. -/
theorem expectedLogFiber_not_subadditive :
    expectedLogFiber fex pex + expectedLogFiber gex (pushforward fex pex)
      < expectedLogFiber (fun y => gex (fex y)) pex := by
  rw [expectedLogFiber_fex, expectedLogFiber_gex, expectedLogFiber_comp_ex]
  linarith [logb_two_three_gt]

/-- **The dichotomy.**  On the very same pipeline and the very same law, the entropy
accounting is exactly additive while the fiber-counting accounting is not even subadditive. -/
theorem pipeline_dichotomy :
    condEntropyW (fun y => gex (fex y)) pex
        = condEntropyW fex pex + condEntropyW gex (pushforward fex pex) ∧
      expectedLogFiber fex pex + expectedLogFiber gex (pushforward fex pex)
        < expectedLogFiber (fun y => gex (fex y)) pex :=
  ⟨condEntropyW_comp fex gex pex pex_nonneg, expectedLogFiber_not_subadditive⟩

end NormalizationPipeline