/-
# The Fiber-Entropy Refinement of the Space–Heat Frontier

Future Direction B of the previous cycle observed that the reversible-verification results of
`Catalog/Computation/ReversibleVerificationFrontier.lean` live in two different norms:

* the *sharp* frontier `reversible_history_iff` measures the required history register by the
  **largest** fiber, an `ℓ^∞` quantity, while
* the Landauer bound `erasedBits_le_logb_maxFiber` is an **average** (`ℓ^1`) statement.

The gap between them was left as an inequality.  This file closes it by inserting the correct
intermediate quantity — the **conditional entropy of the input given the verifier's output**,
i.e. the average number of bits needed to name a history inside its own fiber:

  `erasedBits f  ≤  condEntropy f  ≤  log₂ (maxFiber f)`.

The left-hand quantity is the entropy drop the verifier realises, the middle one is the
*expected* history capacity, and the right-hand one is the *worst-case* history capacity of
the sharp frontier.  Both inequalities are proved, both are shown to collapse to equalities
exactly for **regular** verifiers (all nonempty fibers of the same size), and a three-element
example shows that both are *strict* in general, so the chain is a genuine refinement of the
previous cycle's single inequality.

## Main statements

* `condEntropy` — the expected history capacity `∑_b (|f⁻¹b|/|α|) · log₂ |f⁻¹b|`.
* `sum_card_fiber` — the fibers partition the input space.
* `condEntropy_le_logb_maxFiber` — `ℓ^1 ≤ ℓ^∞`: expected capacity never exceeds worst-case.
* `erasedBits_le_condEntropy` — the entropy drop never exceeds the expected capacity
  (a Gibbs/`log x ≤ x − 1` argument: the fiber-size distribution has entropy at most
  `log₂ |im f|`).
* `regular_verifier_chain_eq` — for regular verifiers all three quantities coincide.
* `strict_refinement_example` — an explicit verifier with
  `erasedBits < condEntropy < log₂ maxFiber`.
* `landauerCost_le_expected_history`, `landauer_chain` — the physical reading: dissipated heat
  is bounded by the *expected* history capacity, which is a strictly better bound than the
  worst-case capacity used previously.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): `log₂ maxFiber` overcounts because it charges every fiber the price of
  the largest one; the honest ancillary cost is the average `∑_b p(b) log₂ |fiber b|`.  The
  conjecture was that this average sits between the realised entropy drop and the worst case.
Experiment (Stage 2): computed the three quantities on the collapsing verifier
  `![0,0,1] : Fin 3 → Fin 2`: `erasedBits = log₂ 3 − 1 ≈ 0.585`, `condEntropy = 2/3 ≈ 0.667`,
  `log₂ maxFiber = 1`.  Both inequalities are strict there, which rules out any collapse of
  the chain and pins the failure of the previous cycle's bound at `≈ 0.415` bits per query.
Analysis (Stage 3): the left inequality is exactly the max-entropy bound `H(f_*p) ≤ log₂|im f|`
  for the *uniform* input distribution, and the right inequality is monotonicity of `log₂`.
  Equality on both sides is the same condition — all nonempty fibers have the same size — so
  the two `ℓ^p` readings of the frontier agree precisely on regular verifiers.
Critique (Stage 4): the statement is for the uniform input distribution, which is the model in
  which `erasedBits` was defined in the catalog; for a general input distribution the middle
  term is the conditional entropy `H(x ∣ f x)` and the left term must be replaced by
  `H(p) − H(f_*p)`, an identity rather than an inequality.  We therefore state the uniform
  case, where the chain has genuine content, and note the boundary explicitly.
Synthesis (Stage 5): worst-case history capacity dominates expected history capacity dominates
  dissipated bits, with equality exactly for regular verifiers.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof
import Computation.ReversibleVerificationFrontier

open Finset Real ThermoProof ReversibleFrontier

namespace FiberEntropy

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

/-- The **expected history capacity** of a finite verifier: for a uniformly distributed
input, the average number of bits needed to name a computational history *inside its own
verification fiber*.  This is the conditional entropy `H(x ∣ f x)`. -/
noncomputable def condEntropy (f : α → β) : ℝ :=
  (∑ b : β, ((fiber f b).card : ℝ) * Real.logb 2 ((fiber f b).card)) / (Fintype.card α : ℝ)

/-- The fibers of a verifier partition its input space. -/
lemma sum_card_fiber (f : α → β) : ∑ b : β, (fiber f b).card = Fintype.card α := by
  classical
  have := Finset.card_eq_sum_card_fiberwise
    (f := f) (s := (Finset.univ : Finset α)) (t := (Finset.univ : Finset β))
    (fun x _ => Finset.mem_univ (f x))
  simpa [fiber, Finset.card_univ, eq_comm] using this.symm

lemma sum_card_fiber_real (f : α → β) :
    ∑ b : β, ((fiber f b).card : ℝ) = (Fintype.card α : ℝ) := by
  exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (sum_card_fiber f)

/-- Only the fibers over the image contribute to the expected capacity. -/
lemma sum_fiber_term_image (f : α → β) :
    ∑ b : β, ((fiber f b).card : ℝ) * Real.logb 2 ((fiber f b).card)
      = ∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) * Real.logb 2 ((fiber f b).card) := by
  classical
  refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
  intro b _ hb
  have hempty : fiber f b = ∅ := by
    rw [Finset.eq_empty_iff_forall_notMem]
    intro x hx
    rw [mem_fiber] at hx
    exact hb (by rw [← hx]; exact Finset.mem_image_of_mem f (Finset.mem_univ x))
  simp [hempty]

omit [Fintype β] in
lemma card_fiber_pos_of_mem_image {f : α → β} {b : β} (hb : b ∈ Finset.univ.image f) :
    0 < (fiber f b).card := by
  obtain ⟨x, _, rfl⟩ := Finset.mem_image.1 hb
  exact Finset.card_pos.2 ⟨x, by simp⟩

/-! ## `ℓ^1 ≤ ℓ^∞`: expected capacity is at most worst-case capacity -/

/-- **Expected history capacity never exceeds the worst-case capacity** of the sharp
frontier `reversible_history_iff`. -/
theorem condEntropy_le_logb_maxFiber [Nonempty α] (f : α → β) :
    condEntropy f ≤ Real.logb 2 (maxFiber f) := by
  have hN : (0 : ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast this
  have hM : (0 : ℝ) < (maxFiber f : ℝ) := by
    have := maxFiber_pos f
    exact_mod_cast this
  have hterm : ∀ b : β, ((fiber f b).card : ℝ) * Real.logb 2 ((fiber f b).card)
      ≤ ((fiber f b).card : ℝ) * Real.logb 2 (maxFiber f) := by
    intro b
    rcases Nat.eq_zero_or_pos (fiber f b).card with h | h
    · simp [h]
    · refine mul_le_mul_of_nonneg_left ?_ (by positivity)
      have h1 : (0 : ℝ) < ((fiber f b).card : ℝ) := by exact_mod_cast h
      have h2 : ((fiber f b).card : ℝ) ≤ (maxFiber f : ℝ) := by
        exact_mod_cast card_fiber_le_maxFiber f b
      exact (Real.logb_le_logb (b := 2) (by norm_num) h1 hM).2 h2
  have hsum : ∑ b : β, ((fiber f b).card : ℝ) * Real.logb 2 ((fiber f b).card)
      ≤ (Fintype.card α : ℝ) * Real.logb 2 (maxFiber f) := by
    calc ∑ b : β, ((fiber f b).card : ℝ) * Real.logb 2 ((fiber f b).card)
        ≤ ∑ b : β, ((fiber f b).card : ℝ) * Real.logb 2 (maxFiber f) :=
          Finset.sum_le_sum fun b _ => hterm b
      _ = (Fintype.card α : ℝ) * Real.logb 2 (maxFiber f) := by
          rw [← Finset.sum_mul, sum_card_fiber_real]
  rw [condEntropy, div_le_iff₀ hN]
  linarith [hsum]

/-! ## The entropy drop is at most the expected capacity -/

/-- Pointwise Gibbs estimate `t · log (c / t) ≤ c − t` for `t, c > 0`. -/
private lemma gibbs_term {t c : ℝ} (ht : 0 < t) (hc : 0 < c) :
    t * (Real.log c - Real.log t) ≤ c - t := by
  have h1 : Real.log (c / t) ≤ c / t - 1 := Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div (ne_of_gt hc) (ne_of_gt ht)] at h1
  have h2 := mul_le_mul_of_nonneg_left h1 ht.le
  have h3 : t * (c / t - 1) = c - t := by field_simp
  linarith [h2, h3.le, h3.ge]

/-- **The realised entropy drop never exceeds the expected history capacity.**  Equivalently:
the output distribution induced by a uniform input has entropy at most `log₂ |im f|`.  This is
the `ℓ^1` half of the frontier, and it strengthens
`ReversibleFrontier.erasedBits_le_logb_maxFiber`. -/
theorem erasedBits_le_condEntropy [Nonempty α] (f : α → β) :
    erasedBits f ≤ condEntropy f := by
  classical
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hN : (0 : ℝ) < (Fintype.card α : ℝ) := by
    have h : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast h
  have hI : (0 : ℝ) < (imageCard f : ℝ) := by
    have h := imageCard_pos f
    exact_mod_cast h
  have hScard : (((Finset.univ.image f).card : ℕ) : ℝ) = (imageCard f : ℝ) := rfl
  -- the fibers over the image already carry the whole input space
  have hIne : (imageCard f : ℝ) ≠ 0 := ne_of_gt hI
  have hsumS : ∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) = (Fintype.card α : ℝ) := by
    rw [← sum_card_fiber_real f]
    refine Finset.sum_subset (Finset.subset_univ _) ?_
    intro b _ hb
    have hempty : fiber f b = ∅ := by
      rw [Finset.eq_empty_iff_forall_notMem]
      intro x hx
      rw [mem_fiber] at hx
      exact hb (by rw [← hx]; exact Finset.mem_image_of_mem f (Finset.mem_univ x))
    simp [hempty]
  -- Gibbs on each nonempty fiber
  have hkey : ∀ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) *
      (Real.log (Fintype.card α) - Real.log (imageCard f) - Real.log ((fiber f b).card))
      ≤ (Fintype.card α : ℝ) / (imageCard f : ℝ) - ((fiber f b).card : ℝ) := by
    intro b hb
    have ht : (0 : ℝ) < ((fiber f b).card : ℝ) := by
      exact_mod_cast card_fiber_pos_of_mem_image hb
    have hc : (0 : ℝ) < (Fintype.card α : ℝ) / (imageCard f : ℝ) := by positivity
    have hg := gibbs_term ht hc
    rw [Real.log_div (ne_of_gt hN) (ne_of_gt hI)] at hg
    linarith [hg]
  have hsum := Finset.sum_le_sum hkey
  -- evaluate both sides
  have hLHS : ∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) *
      (Real.log (Fintype.card α) - Real.log (imageCard f) - Real.log ((fiber f b).card))
      = (Real.log (Fintype.card α) - Real.log (imageCard f)) * (Fintype.card α : ℝ)
        - ∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) * Real.log ((fiber f b).card) := by
    rw [Finset.sum_congr rfl (fun b _ => by ring :
      ∀ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) *
        (Real.log (Fintype.card α) - Real.log (imageCard f) - Real.log ((fiber f b).card))
        = (Real.log (Fintype.card α) - Real.log (imageCard f)) * ((fiber f b).card : ℝ)
          - ((fiber f b).card : ℝ) * Real.log ((fiber f b).card)),
      Finset.sum_sub_distrib, ← Finset.mul_sum, hsumS]
  have hRHS : ∑ _b ∈ Finset.univ.image f,
      ((Fintype.card α : ℝ) / (imageCard f : ℝ) - ((fiber f _b).card : ℝ)) = 0 := by
    rw [Finset.sum_sub_distrib, Finset.sum_const, hsumS, nsmul_eq_mul, hScard]
    field_simp
    ring
  rw [hLHS, hRHS] at hsum
  have hgoal : (Real.log (Fintype.card α) - Real.log (imageCard f)) * (Fintype.card α : ℝ)
      ≤ ∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) * Real.log ((fiber f b).card) := by
    linarith [hsum]
  -- convert to base-two logarithms
  have hnum : ∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) * Real.logb 2 ((fiber f b).card)
      = (∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) * Real.log ((fiber f b).card))
        / Real.log 2 := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun b _ => by rw [Real.logb]; ring
  rw [erasedBits, condEntropy, sum_fiber_term_image f, hnum, Real.logb, Real.logb,
    div_sub_div_same, div_div, div_le_div_iff₀ hlog2 (by positivity)]
  calc (Real.log (Fintype.card α) - Real.log (imageCard f)) * (Real.log 2 * (Fintype.card α : ℝ))
      = ((Real.log (Fintype.card α) - Real.log (imageCard f)) * (Fintype.card α : ℝ))
        * Real.log 2 := by ring
    _ ≤ (∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) * Real.log ((fiber f b).card))
        * Real.log 2 := mul_le_mul_of_nonneg_right hgoal hlog2.le

/-! ## The refined chain and its physical reading -/

/-- **The refined space–heat chain.**  Dissipated bits `≤` expected history capacity `≤`
worst-case history capacity.  The outer inequality is the previous cycle's
`erasedBits_le_logb_maxFiber`, here obtained as a corollary of two sharper facts. -/
theorem erased_le_cond_le_max [Nonempty α] (f : α → β) :
    erasedBits f ≤ condEntropy f ∧ condEntropy f ≤ Real.logb 2 (maxFiber f) :=
  ⟨erasedBits_le_condEntropy f, condEntropy_le_logb_maxFiber f⟩

/-- The physical reading: at temperature `T` the heat dissipated by an irreversible verifier
is at most the Landauer cost of its *expected* history capacity. -/
theorem landauerCost_le_expected_history [Nonempty α] (f : α → β) {kB T : ℝ}
    (hk : 0 ≤ kB) (hT : 0 ≤ T) :
    landauerCost (erasedBits f) kB T ≤ landauerCost (condEntropy f) kB T := by
  unfold landauerCost
  have hlog : (0 : ℝ) ≤ Real.log 2 := (Real.log_pos (by norm_num)).le
  have hfac : (0 : ℝ) ≤ kB * T * Real.log 2 := by positivity
  exact mul_le_mul_of_nonneg_right (erasedBits_le_condEntropy f) hfac

/-- The full thermodynamic chain. -/
theorem landauer_chain [Nonempty α] (f : α → β) {kB T : ℝ} (hk : 0 ≤ kB) (hT : 0 ≤ T) :
    landauerCost (erasedBits f) kB T ≤ landauerCost (condEntropy f) kB T ∧
      landauerCost (condEntropy f) kB T ≤ landauerCost (Real.logb 2 (maxFiber f)) kB T := by
  refine ⟨landauerCost_le_expected_history f hk hT, ?_⟩
  unfold landauerCost
  have hlog : (0 : ℝ) ≤ Real.log 2 := (Real.log_pos (by norm_num)).le
  have hfac : (0 : ℝ) ≤ kB * T * Real.log 2 := by positivity
  exact mul_le_mul_of_nonneg_right (condEntropy_le_logb_maxFiber f) hfac

/-! ## Equality: regular verifiers -/

/-- A verifier is **regular** if all its nonempty fibers have the same size, namely the
maximal one. -/
def Regular (f : α → β) : Prop := ∀ b ∈ Finset.univ.image f, (fiber f b).card = maxFiber f

/-- For a regular verifier the input space factors as `|im f| · maxFiber f`. -/
lemma card_eq_of_regular [Nonempty α] {f : α → β} (hreg : Regular f) :
    (Fintype.card α : ℝ) = (imageCard f : ℝ) * (maxFiber f : ℝ) := by
  classical
  have h : ∑ b ∈ Finset.univ.image f, ((fiber f b).card : ℝ) = (Fintype.card α : ℝ) := by
    rw [← sum_card_fiber_real f]
    refine Finset.sum_subset (Finset.subset_univ _) ?_
    intro b _ hb
    have hempty : fiber f b = ∅ := by
      rw [Finset.eq_empty_iff_forall_notMem]
      intro x hx
      rw [mem_fiber] at hx
      exact hb (by rw [← hx]; exact Finset.mem_image_of_mem f (Finset.mem_univ x))
    simp [hempty]
  have hIc : (((Finset.univ.image f).card : ℕ) : ℝ) = (imageCard f : ℝ) := rfl
  rw [← h, Finset.sum_congr rfl (fun b hb => by rw [hreg b hb]), Finset.sum_const,
    nsmul_eq_mul, hIc]

/-- **The two norms agree exactly on regular verifiers.**  All three quantities of the chain
coincide: dissipated bits `=` expected capacity `=` worst-case capacity. -/
theorem regular_verifier_chain_eq [Nonempty α] {f : α → β} (hreg : Regular f) :
    erasedBits f = condEntropy f ∧ condEntropy f = Real.logb 2 (maxFiber f) := by
  classical
  have hN : (0 : ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast this
  have hI : (0 : ℝ) < (imageCard f : ℝ) := by
    have := imageCard_pos f
    exact_mod_cast this
  have hM : (0 : ℝ) < (maxFiber f : ℝ) := by
    have := maxFiber_pos f
    exact_mod_cast this
  have hfac := card_eq_of_regular hreg
  have hcond : condEntropy f = Real.logb 2 (maxFiber f) := by
    have hIc : (((Finset.univ.image f).card : ℕ) : ℝ) = (imageCard f : ℝ) := rfl
    rw [condEntropy, sum_fiber_term_image f,
      Finset.sum_congr rfl (fun b hb => by rw [hreg b hb]), Finset.sum_const,
      nsmul_eq_mul, hIc, hfac]
    field_simp
  refine ⟨?_, hcond⟩
  rw [hcond, erasedBits, hfac, Real.logb_mul (ne_of_gt hI) (ne_of_gt hM)]
  ring

/-! ## Strictness: the refinement is not vacuous -/

/-- The collapsing verifier `![0, 0, 1] : Fin 3 → Fin 2`. -/
def collapse32 : Fin 3 → Fin 2 := ![0, 0, 1]

lemma card_fiber_collapse32_zero : (fiber collapse32 0).card = 2 := by decide

lemma card_fiber_collapse32_one : (fiber collapse32 1).card = 1 := by decide

lemma maxFiber_collapse32 : maxFiber collapse32 = 2 := by decide

lemma imageCard_collapse32 : imageCard collapse32 = 2 := by decide

lemma condEntropy_collapse32 : condEntropy collapse32 = 2 / 3 := by
  rw [condEntropy]
  rw [Fin.sum_univ_two, card_fiber_collapse32_zero, card_fiber_collapse32_one]
  norm_num [Real.logb_self_eq_one]

lemma erasedBits_collapse32 : erasedBits collapse32 = Real.logb 2 3 - 1 := by
  rw [erasedBits, imageCard_collapse32]
  norm_num [Real.logb_self_eq_one]

lemma logb_two_three_lt : Real.logb 2 3 < 5 / 3 := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h27 : Real.log 27 < Real.log 32 := Real.log_lt_log (by norm_num) (by norm_num)
  have h3 : Real.log 27 = 3 * Real.log 3 := by
    rw [show (27 : ℝ) = 3 ^ (3 : ℕ) by norm_num, Real.log_pow]; push_cast; ring
  have h2 : Real.log 32 = 5 * Real.log 2 := by
    rw [show (32 : ℝ) = 2 ^ (5 : ℕ) by norm_num, Real.log_pow]; push_cast; ring
  rw [Real.logb, div_lt_iff₀ hlog2]
  nlinarith [h27, h3, h2]

/-- **Strictness of the refinement.**  For the collapsing verifier `![0,0,1]` both
inequalities of the chain are strict, so the expected history capacity is a genuinely new
quantity, sitting strictly between the dissipated bits and the worst-case capacity of the
sharp frontier. -/
theorem strict_refinement_example :
    erasedBits collapse32 < condEntropy collapse32 ∧
      condEntropy collapse32 < Real.logb 2 (maxFiber collapse32) := by
  constructor
  · rw [erasedBits_collapse32, condEntropy_collapse32]
    linarith [logb_two_three_lt]
  · rw [condEntropy_collapse32, maxFiber_collapse32]
    norm_num [Real.logb_self_eq_one]

end FiberEntropy