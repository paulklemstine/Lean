/-
# Weighted Verification Fibers: the Chain Rule and the Jensen Defect of the Space–Heat Chain

## Where this sits in the thread

The thread "Proof Complexity and Thermodynamic Cost" has, so far, produced

* `Novelty/ThermodynamicsOfProof.lean` — `imageCard`, `erasedBits`, `landauerCost`;
* `Computation/ReversibleVerificationFrontier.lean` — the sharp frontier
  `reversible_history_iff` and the memory–dissipation inequality
  `erasedBits f ≤ log₂ (maxFiber f)`;
* `Computation/FiberEntropyFrontier.lean` — the refined chain
  `erasedBits f ≤ condEntropy f ≤ log₂ (maxFiber f)` for **uniformly distributed** inputs,
  with equality throughout for regular verifiers and both inequalities strict for
  `![0,0,1] : Fin 3 → Fin 2`;
* `Computation/PrefixFreeThermoCoding.lean` and `Computation/KraftConverse.lean` — Kraft,
  Shannon and Landauer for prefix-free proof descriptions.

Future direction **B′** of the previous cycle conjectured that the uniform chain is the
shadow of an *identity* valid for an arbitrary input distribution: that the expected history
capacity of a verifier is the conditional entropy `H(x ∣ f x) = H(p) − H(f_*p)`, and that the
slack in `erasedBits f ≤ condEntropy f` is exactly the Jensen defect
`log₂ |im f| − H(f_*p)` of the fiber-size distribution.  This file proves that conjecture.

## Main results

* `condEntropyW` — the weighted expected history capacity `−∑ₓ p x · log₂ (p x / (f_*p)(f x))`.
* `condEntropyW_chain_rule` — **the chain rule** `H(x ∣ f x) = H(p) − H(f_*p)`, an identity
  for every non-negative weight `p` (no normalisation needed).
* `condEntropyW_nonneg`, `condEntropyW_le_logb_maxFiber` — the weighted form of the two
  ends of the frontier: the expected capacity is non-negative and never exceeds the
  worst-case capacity `log₂ (maxFiber f)`, for *every* input distribution.
* `condEntropyW_uniform` — the uniform specialisation is exactly `FiberEntropy.condEntropy`.
* `jensen_defect_identity` — **the conjectured identity**
  `condEntropy f − erasedBits f = log₂ (imageCard f) − H(f_*(unif))`;
  the left-hand side is the slack of the previous cycle's inequality, the right-hand side is
  the Jensen defect of the fiber-size distribution against the uniform distribution on the
  image.
* `jensen_defect_nonneg` and `erasedBits_le_condEntropy'` — the defect is non-negative
  (maximum-entropy bound), which re-derives the previous cycle's inequality *with its exact
  error term*.
* `jensen_defect_eq_zero_of_regular`, `regular_pushforward_unif` — the defect vanishes on
  regular verifiers, matching `FiberEntropy.regular_verifier_chain_eq`.
* `jensen_defect_collapse32_pos` — the defect is strictly positive for `![0,0,1]`, so the
  identity has content.
* `landauer_weighted_chain`, `landauer_defect_decomposition` — the thermodynamic reading at
  fixed temperature: dissipated heat plus the Landauer cost of the defect is exactly the
  Landauer cost of the expected history capacity.
* `condEntropy_prodMap`, `erasedBits_prodMap`, `jensenDefect_prodMap` — **extensivity**: all
  three quantities of the chain are additive over independent verifiers, so the whole
  space–heat accounting is an extensive thermodynamic bookkeeping.

## Method note (v19 loop)

Hypothesis (Stage 1): the two inequalities of the uniform chain have different characters —
one is an *identity in disguise* (a chain rule), the other a genuine maximum-entropy bound.
Experiment (Stage 2): formalise the weighted conditional entropy and compute.
Analysis (Stage 3): confirmed.  `erasedBits ≤ condEntropy` is a chain rule plus a
maximum-entropy bound, and the two contributions can be separated exactly.
Critique (Stage 4): the chain rule needs no normalisation and no positivity, only
non-negativity, and the degenerate fibers (weight `0`) are handled explicitly rather than
excluded, so the statement has no hidden support hypotheses.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof
import Computation.PrefixFreeThermoCoding
import Computation.ReversibleVerificationFrontier
import Computation.FiberEntropyFrontier

open Finset Real ThermoProof ReversibleFrontier

namespace WeightedFiberEntropy

/-! ## A maximum-entropy lemma for arbitrary non-negative weights -/

/-- Pointwise Gibbs estimate `t · (log c − log t) ≤ c − t` for `t, c > 0`. -/
private lemma gibbs_term {t c : ℝ} (ht : 0 < t) (hc : 0 < c) :
    t * (Real.log c - Real.log t) ≤ c - t := by
  have h1 : Real.log (c / t) ≤ c / t - 1 := Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div (ne_of_gt hc) (ne_of_gt ht)] at h1
  have h2 := mul_le_mul_of_nonneg_left h1 ht.le
  have h3 : t * (c / t - 1) = c - t := by field_simp
  linarith [h2, h3.le, h3.ge]

/-- **Maximum-entropy bound for unnormalised weights.**  For any non-negative weight `q` on a
finite set `s` with total mass `S = ∑ q`, the unnormalised Shannon entropy
`−∑ q x · log₂ (q x / S)` is at most `S · log₂ |s|`.

No positivity or normalisation hypothesis is needed: vanishing weights contribute nothing on
either side (Lean's `logb 2 0 = 0`), and total mass `0` forces both sides to vanish. -/
theorem neg_weighted_logb_le {γ : Type*} (s : Finset γ) (q : γ → ℝ) (hq : ∀ x ∈ s, 0 ≤ q x) :
    -∑ x ∈ s, q x * Real.logb 2 (q x / (∑ y ∈ s, q y))
      ≤ (∑ y ∈ s, q y) * Real.logb 2 s.card := by
  set S : ℝ := ∑ y ∈ s, q y with hSdef
  have hS0 : 0 ≤ S := Finset.sum_nonneg hq
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rcases eq_or_lt_of_le hS0 with hS | hS
  · -- total mass zero: every weight vanishes
    have hz : ∑ y ∈ s, q y = 0 := by rw [← hSdef]; exact hS.symm
    have hzero : ∀ x ∈ s, q x = 0 := (Finset.sum_eq_zero_iff_of_nonneg hq).1 hz
    have h1 : ∑ x ∈ s, q x * Real.logb 2 (q x / S) = 0 :=
      Finset.sum_eq_zero fun x hx => by rw [hzero x hx]; ring
    rw [h1, ← hS]
    simp
  · -- positive total mass
    have hsne : s.Nonempty := by
      by_contra h
      rw [Finset.not_nonempty_iff_eq_empty] at h
      rw [hSdef, h] at hS; simp at hS
    have hcard : (0 : ℝ) < (s.card : ℝ) := by
      exact_mod_cast Finset.card_pos.2 hsne
    set c : ℝ := S / (s.card : ℝ) with hc
    have hcpos : 0 < c := by positivity
    -- Gibbs, term by term
    have hkey : ∀ x ∈ s, q x * (Real.log c - Real.log (q x)) ≤ c - q x := by
      intro x hx
      rcases eq_or_lt_of_le (hq x hx) with h0 | hpos
      · simp [← h0, hcpos.le]
      · exact gibbs_term hpos hcpos
    have hsum := Finset.sum_le_sum hkey
    have hL : ∑ x ∈ s, q x * (Real.log c - Real.log (q x))
        = S * Real.log c - ∑ x ∈ s, q x * Real.log (q x) := by
      rw [Finset.sum_congr rfl (fun x _ => by ring :
        ∀ x ∈ s, q x * (Real.log c - Real.log (q x))
          = q x * Real.log c - q x * Real.log (q x)),
        Finset.sum_sub_distrib, ← Finset.sum_mul, ← hSdef]
    have hcS : (s.card : ℝ) * c = S := by rw [hc]; field_simp
    have hR : ∑ x ∈ s, (c - q x) = 0 := by
      rw [Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul, ← hSdef, hcS, sub_self]
    rw [hL, hR] at hsum
    have hlogc : Real.log c = Real.log S - Real.log (s.card : ℝ) := by
      rw [hc, Real.log_div (ne_of_gt hS) (ne_of_gt hcard)]
    -- rewrite the left-hand side in terms of natural logarithms
    have hterm : ∀ x ∈ s, q x * Real.logb 2 (q x / S)
        = (q x * Real.log (q x) - q x * Real.log S) / Real.log 2 := by
      intro x hx
      rcases eq_or_lt_of_le (hq x hx) with h0 | hpos
      · simp [← h0]
      · rw [Real.logb, Real.log_div (ne_of_gt hpos) (ne_of_gt hS)]
        ring
    have hLHS : ∑ x ∈ s, q x * Real.logb 2 (q x / S)
        = ((∑ x ∈ s, q x * Real.log (q x)) - S * Real.log S) / Real.log 2 := by
      rw [Finset.sum_congr rfl hterm, ← Finset.sum_div]
      congr 1
      rw [Finset.sum_sub_distrib, ← Finset.sum_mul, ← hSdef]
    have key : -((∑ x ∈ s, q x * Real.log (q x)) - S * Real.log S)
        ≤ S * Real.log (s.card : ℝ) := by
      have h : S * Real.log c ≤ ∑ x ∈ s, q x * Real.log (q x) := by linarith
      rw [hlogc] at h
      nlinarith [h]
    have h2 : S * Real.logb 2 (s.card : ℝ)
        = (S * Real.log (s.card : ℝ)) / Real.log 2 := by
      rw [Real.logb]; ring
    rw [hLHS, h2, ← neg_div]
    exact div_le_div_of_nonneg_right key hlog2.le

/-! ## The weighted expected history capacity -/

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

/-- The **pushforward** of an input weight along a verifier: the weight the verifier assigns
to each of its outputs. -/
noncomputable def pushforward (f : α → β) (p : α → ℝ) : β → ℝ :=
  fun b => ∑ x ∈ fiber f b, p x

omit [Fintype β] in
@[simp] lemma mem_fiber_self (f : α → β) (x : α) : x ∈ fiber f (f x) := by simp

omit [Fintype β] in
lemma pushforward_nonneg {f : α → β} {p : α → ℝ} (hp : ∀ x, 0 ≤ p x) (b : β) :
    0 ≤ pushforward f p b :=
  Finset.sum_nonneg fun x _ => hp x

omit [Fintype β] in
lemma le_pushforward {f : α → β} {p : α → ℝ} (hp : ∀ x, 0 ≤ p x) (x : α) :
    p x ≤ pushforward f p (f x) :=
  Finset.single_le_sum (f := p) (fun y _ => hp y) (mem_fiber_self f x)

/-- Fiberwise regrouping of a sum over the input space. -/
lemma sum_fiberwise (f : α → β) (g : α → ℝ) :
    ∑ b : β, ∑ x ∈ fiber f b, g x = ∑ x, g x :=
  Finset.sum_fiberwise_of_maps_to (fun x _ => Finset.mem_univ (f x)) g

lemma sum_pushforward (f : α → β) (p : α → ℝ) :
    ∑ b : β, pushforward f p b = ∑ x, p x := sum_fiberwise f p

/-- The **weighted expected history capacity** of a verifier: the conditional entropy
`H(x ∣ f x)` of the input given the verifier's output. -/
noncomputable def condEntropyW (f : α → β) (p : α → ℝ) : ℝ :=
  -∑ x, p x * Real.logb 2 (p x / pushforward f p (f x))

/-! ## The chain rule -/

/-- **Chain rule for verification fibers.**  For every non-negative input weight,
`H(x ∣ f x) = H(p) − H(f_*p)`: the expected history capacity is *exactly* the entropy lost
in passing from the input distribution to the output distribution.  This is an identity, not
an inequality, and it needs no normalisation of `p`. -/
theorem condEntropyW_chain_rule (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x) :
    condEntropyW f p
      = PrefixFreeThermo.entropy p - PrefixFreeThermo.entropy (pushforward f p) := by
  classical
  -- split each summand
  have hsplit : ∀ x : α, p x * Real.logb 2 (p x / pushforward f p (f x))
      = p x * Real.logb 2 (p x) - p x * Real.logb 2 (pushforward f p (f x)) := by
    intro x
    rcases eq_or_lt_of_le (hp x) with h0 | hpos
    · simp [← h0]
    · have hb : 0 < pushforward f p (f x) := lt_of_lt_of_le hpos (le_pushforward hp x)
      rw [Real.logb_div (ne_of_gt hpos) (ne_of_gt hb)]
      ring
  -- regroup the second half fiberwise
  have hpush : ∑ x, p x * Real.logb 2 (pushforward f p (f x))
      = ∑ b : β, pushforward f p b * Real.logb 2 (pushforward f p b) := by
    rw [← sum_fiberwise f (fun x => p x * Real.logb 2 (pushforward f p (f x)))]
    refine Finset.sum_congr rfl ?_
    intro b _
    have hrw : ∀ x ∈ fiber f b, p x * Real.logb 2 (pushforward f p (f x))
        = p x * Real.logb 2 (pushforward f p b) := by
      intro x hx
      rw [mem_fiber.1 hx]
    rw [Finset.sum_congr rfl hrw, ← Finset.sum_mul]
    rfl
  rw [condEntropyW, Finset.sum_congr rfl (fun x _ => hsplit x), Finset.sum_sub_distrib,
    hpush, PrefixFreeThermo.entropy, PrefixFreeThermo.entropy]
  ring

/-! ## The two ends of the frontier, for arbitrary inputs -/

omit [Fintype β] in
/-- The weighted expected history capacity is non-negative. -/
theorem condEntropyW_nonneg (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x) :
    0 ≤ condEntropyW f p := by
  rw [condEntropyW, neg_nonneg]
  refine Finset.sum_nonpos ?_
  intro x _
  rcases eq_or_lt_of_le (hp x) with h0 | hpos
  · simp [← h0]
  · have hb : 0 < pushforward f p (f x) := lt_of_lt_of_le hpos (le_pushforward hp x)
    have hle : p x / pushforward f p (f x) ≤ 1 :=
      (div_le_one hb).2 (le_pushforward hp x)
    have : Real.logb 2 (p x / pushforward f p (f x)) ≤ 0 :=
      Real.logb_nonpos (by norm_num) (by positivity) hle
    exact mul_nonpos_of_nonneg_of_nonpos (hp x) this

/-- **Worst-case capacity dominates expected capacity, for every input distribution.**  This
is the weighted form of `FiberEntropy.condEntropy_le_logb_maxFiber`, and hence of the sharp
frontier `ReversibleFrontier.reversible_history_iff`. -/
theorem condEntropyW_le_logb_maxFiber [Nonempty α] (f : α → β) (p : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) (hsum : ∑ x, p x = 1) :
    condEntropyW f p ≤ Real.logb 2 (maxFiber f) := by
  classical
  have hM : (0 : ℝ) < (maxFiber f : ℝ) := by
    have := maxFiber_pos f
    exact_mod_cast this
  -- decompose the conditional entropy fiberwise
  have hdec : condEntropyW f p
      = ∑ b : β, -∑ x ∈ fiber f b, p x * Real.logb 2 (p x / pushforward f p b) := by
    rw [condEntropyW, ← sum_fiberwise f (fun x => p x * Real.logb 2 (p x / pushforward f p (f x))),
      ← Finset.sum_neg_distrib]
    refine Finset.sum_congr rfl ?_
    intro b _
    congr 1
    refine Finset.sum_congr rfl ?_
    intro x hx
    rw [mem_fiber.1 hx]
  have hbound : ∀ b : β,
      -∑ x ∈ fiber f b, p x * Real.logb 2 (p x / pushforward f p b)
        ≤ pushforward f p b * Real.logb 2 (maxFiber f) := by
    intro b
    have h1 := neg_weighted_logb_le (fiber f b) p (fun x _ => hp x)
    have hS : ∑ y ∈ fiber f b, p y = pushforward f p b := rfl
    rw [hS] at h1
    refine h1.trans ?_
    refine mul_le_mul_of_nonneg_left ?_ (pushforward_nonneg hp b)
    rcases Nat.eq_zero_or_pos (fiber f b).card with h | h
    · rw [h]; simpa using (Real.logb_nonneg (by norm_num) (by exact_mod_cast maxFiber_pos f))
    · have h1' : (0 : ℝ) < ((fiber f b).card : ℝ) := by exact_mod_cast h
      have h2 : ((fiber f b).card : ℝ) ≤ (maxFiber f : ℝ) := by
        exact_mod_cast card_fiber_le_maxFiber f b
      exact (Real.logb_le_logb (b := 2) (by norm_num) h1' hM).2 h2
  calc condEntropyW f p
      = ∑ b : β, -∑ x ∈ fiber f b, p x * Real.logb 2 (p x / pushforward f p b) := hdec
    _ ≤ ∑ b : β, pushforward f p b * Real.logb 2 (maxFiber f) :=
        Finset.sum_le_sum fun b _ => hbound b
    _ = Real.logb 2 (maxFiber f) := by
        rw [← Finset.sum_mul, sum_pushforward, hsum, one_mul]

/-! ## The uniform specialisation -/

/-- The uniform input distribution. -/
noncomputable def unif (α : Type*) [Fintype α] : α → ℝ := fun _ => 1 / (Fintype.card α : ℝ)

lemma unif_nonneg (α : Type*) [Fintype α] : ∀ x : α, 0 ≤ unif α x := by
  intro x; unfold unif; positivity

lemma sum_unif (α : Type*) [Fintype α] [Nonempty α] : ∑ x : α, unif α x = 1 := by
  have hN : (0 : ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast this
  simp only [unif]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

omit [Fintype β] in
lemma pushforward_unif (f : α → β) (b : β) :
    pushforward f (unif α) b = ((fiber f b).card : ℝ) / (Fintype.card α : ℝ) := by
  simp only [pushforward, unif]
  rw [Finset.sum_const, nsmul_eq_mul]
  ring

lemma entropy_unif [Nonempty α] :
    PrefixFreeThermo.entropy (unif α) = Real.logb 2 (Fintype.card α) := by
  have hN : (0 : ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast this
  simp only [PrefixFreeThermo.entropy, unif]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, one_div, Real.logb_inv]
  field_simp

/-- The uniform specialisation of the weighted capacity is the previous cycle's
`FiberEntropy.condEntropy`. -/
theorem condEntropyW_unif [Nonempty α] (f : α → β) :
    condEntropyW f (unif α) = FiberEntropy.condEntropy f := by
  classical
  have hN : (0 : ℝ) < (Fintype.card α : ℝ) := by
    have : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast this
  rw [condEntropyW_chain_rule f _ (unif_nonneg α), entropy_unif, PrefixFreeThermo.entropy,
    FiberEntropy.condEntropy]
  have hterm : ∀ b : β, pushforward f (unif α) b * Real.logb 2 (pushforward f (unif α) b)
      = (((fiber f b).card : ℝ) * Real.logb 2 ((fiber f b).card)) / (Fintype.card α : ℝ)
        - (((fiber f b).card : ℝ) / (Fintype.card α : ℝ)) * Real.logb 2 (Fintype.card α) := by
    intro b
    rw [pushforward_unif]
    rcases Nat.eq_zero_or_pos (fiber f b).card with h | h
    · rw [h]; simp
    · have h1 : (0 : ℝ) < ((fiber f b).card : ℝ) := by exact_mod_cast h
      rw [Real.logb_div (ne_of_gt h1) (ne_of_gt hN)]
      field_simp
  have hsum2 : ∑ b : β, ((fiber f b).card : ℝ) / (Fintype.card α : ℝ)
        * Real.logb 2 (Fintype.card α) = Real.logb 2 (Fintype.card α) := by
    rw [← Finset.sum_mul, ← Finset.sum_div, FiberEntropy.sum_card_fiber_real]
    field_simp
  rw [Finset.sum_congr rfl (fun b _ => hterm b), Finset.sum_sub_distrib, ← Finset.sum_div,
    hsum2]
  ring

/-! ## The Jensen defect -/

/-- The **Jensen defect** of a verifier: the gap between the worst-case output entropy
`log₂ |im f|` and the actual entropy of the fiber-size distribution. -/
noncomputable def jensenDefect (f : α → β) : ℝ :=
  Real.logb 2 (imageCard f) - PrefixFreeThermo.entropy (pushforward f (unif α))

/-- **The conjectured identity (future direction B′).**  The slack of the previous cycle's
inequality `erasedBits f ≤ condEntropy f` is *exactly* the Jensen defect of the fiber-size
distribution against the uniform distribution on the image. -/
theorem jensen_defect_identity [Nonempty α] (f : α → β) :
    FiberEntropy.condEntropy f - erasedBits f = jensenDefect f := by
  rw [← condEntropyW_unif f, condEntropyW_chain_rule f _ (unif_nonneg α), entropy_unif,
    erasedBits, jensenDefect]
  ring

omit [Fintype β] in
/-- The pushforward of the uniform distribution vanishes outside the image. -/
lemma pushforward_unif_eq_zero_of_notMem_image {f : α → β} {b : β}
    (hb : b ∉ Finset.univ.image f) : pushforward f (unif α) b = 0 := by
  have hempty : fiber f b = ∅ := by
    rw [Finset.eq_empty_iff_forall_notMem]
    intro x hx
    rw [mem_fiber] at hx
    exact hb (by rw [← hx]; exact Finset.mem_image_of_mem f (Finset.mem_univ x))
  rw [pushforward_unif, hempty]
  simp

/-- **The defect is non-negative** — the maximum-entropy bound for the output distribution.
Combined with `jensen_defect_identity` this re-derives
`FiberEntropy.erasedBits_le_condEntropy` *with its exact error term*. -/
theorem jensen_defect_nonneg [Nonempty α] (f : α → β) : 0 ≤ jensenDefect f := by
  classical
  have hqnn : ∀ b : β, 0 ≤ pushforward f (unif α) b :=
    fun b => pushforward_nonneg (unif_nonneg α) b
  -- restrict all sums to the image
  have hmass : ∑ b ∈ ((Finset.univ : Finset α).image f), pushforward f (unif α) b = 1 := by
    have h : ∑ b ∈ ((Finset.univ : Finset α).image f), pushforward f (unif α) b
        = ∑ b : β, pushforward f (unif α) b := by
      refine Finset.sum_subset (Finset.subset_univ _) ?_
      intro b _ hb
      exact pushforward_unif_eq_zero_of_notMem_image hb
    rw [h, sum_pushforward, sum_unif]
  have hent : PrefixFreeThermo.entropy (pushforward f (unif α))
      = -∑ b ∈ ((Finset.univ : Finset α).image f),
          pushforward f (unif α) b * Real.logb 2 (pushforward f (unif α) b) := by
    rw [PrefixFreeThermo.entropy]
    congr 1
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro b _ hb
    rw [pushforward_unif_eq_zero_of_notMem_image hb]
    simp
  have hmax := neg_weighted_logb_le ((Finset.univ : Finset α).image f)
    (pushforward f (unif α)) (fun b _ => hqnn b)
  rw [hmass] at hmax
  simp only [div_one, one_mul] at hmax
  have hIc : ((((Finset.univ : Finset α).image f).card : ℕ) : ℝ) = (imageCard f : ℝ) := rfl
  rw [hIc] at hmax
  rw [jensenDefect, hent, sub_nonneg]
  exact hmax

/-- Re-derivation of the previous cycle's inequality from the chain rule and the
maximum-entropy bound, now with an exact error term. -/
theorem erasedBits_le_condEntropy' [Nonempty α] (f : α → β) :
    erasedBits f ≤ FiberEntropy.condEntropy f := by
  have h := jensen_defect_identity f
  have h2 := jensen_defect_nonneg f
  linarith

/-! ## Vanishing of the defect: regular verifiers -/

/-- For a regular verifier the output distribution is uniform on the image. -/
theorem regular_pushforward_unif [Nonempty α] {f : α → β} (hreg : FiberEntropy.Regular f)
    {b : β} (hb : b ∈ Finset.univ.image f) :
    pushforward f (unif α) b = 1 / (imageCard f : ℝ) := by
  have hI : (0 : ℝ) < (imageCard f : ℝ) := by
    have := imageCard_pos f
    exact_mod_cast this
  have hM : (0 : ℝ) < (maxFiber f : ℝ) := by
    have := maxFiber_pos f
    exact_mod_cast this
  have hfac := FiberEntropy.card_eq_of_regular hreg
  rw [pushforward_unif, hreg b hb, hfac]
  field_simp

/-- **The defect vanishes exactly where the previous cycle found equality.** -/
theorem jensen_defect_eq_zero_of_regular [Nonempty α] {f : α → β}
    (hreg : FiberEntropy.Regular f) : jensenDefect f = 0 := by
  classical
  have hI : (0 : ℝ) < (imageCard f : ℝ) := by
    have := imageCard_pos f
    exact_mod_cast this
  have hent : PrefixFreeThermo.entropy (pushforward f (unif α)) = Real.logb 2 (imageCard f) := by
    rw [PrefixFreeThermo.entropy]
    have hrestrict : ∑ b : β, pushforward f (unif α) b * Real.logb 2 (pushforward f (unif α) b)
        = ∑ b ∈ Finset.univ.image f,
            pushforward f (unif α) b * Real.logb 2 (pushforward f (unif α) b) := by
      refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
      intro b _ hb
      rw [pushforward_unif_eq_zero_of_notMem_image hb]
      simp
    have hIc : (((Finset.univ.image f).card : ℕ) : ℝ) = (imageCard f : ℝ) := rfl
    rw [hrestrict,
      Finset.sum_congr rfl (fun b hb => by rw [regular_pushforward_unif hreg hb]),
      Finset.sum_const, nsmul_eq_mul, hIc, one_div, Real.logb_inv]
    field_simp
  rw [jensenDefect, hent, sub_self]

/-! ## Strictness: the defect is a genuinely new quantity -/

/-- For the collapsing verifier `![0,0,1] : Fin 3 → Fin 2` the Jensen defect is strictly
positive, so `jensen_defect_identity` does not merely restate an equality. -/
theorem jensen_defect_collapse32_pos : 0 < jensenDefect FiberEntropy.collapse32 := by
  have h := jensen_defect_identity FiberEntropy.collapse32
  have hstrict := FiberEntropy.strict_refinement_example.1
  linarith

/-! ## Thermodynamic reading -/

/-- **The weighted Landauer chain.**  At fixed temperature the heat associated with the
expected history capacity of *any* input distribution lies between zero and the Landauer
cost of the worst-case capacity. -/
theorem landauer_weighted_chain [Nonempty α] (f : α → β) (p : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) (hsum : ∑ x, p x = 1) {kB T : ℝ} (hk : 0 ≤ kB) (hT : 0 ≤ T) :
    0 ≤ landauerCost (condEntropyW f p) kB T ∧
      landauerCost (condEntropyW f p) kB T
        ≤ landauerCost (Real.logb 2 (maxFiber f)) kB T := by
  have hfac : (0 : ℝ) ≤ kB * T * Real.log 2 := by
    have : (0 : ℝ) ≤ Real.log 2 := (Real.log_pos (by norm_num)).le
    positivity
  refine ⟨?_, ?_⟩
  · unfold landauerCost
    exact mul_nonneg (condEntropyW_nonneg f p hp) hfac
  · unfold landauerCost
    exact mul_le_mul_of_nonneg_right (condEntropyW_le_logb_maxFiber f p hp hsum) hfac

/-- **The exact thermodynamic accounting.**  For uniform inputs the Landauer heat actually
dissipated plus the Landauer cost of the Jensen defect equals the Landauer cost of the
expected history capacity: the defect is precisely the physically retained (not dissipated)
part of the fiber information. -/
theorem landauer_defect_decomposition [Nonempty α] (f : α → β) (kB T : ℝ) :
    landauerCost (erasedBits f) kB T + landauerCost (jensenDefect f) kB T
      = landauerCost (FiberEntropy.condEntropy f) kB T := by
  have h := jensen_defect_identity f
  unfold landauerCost
  rw [← h]
  ring

/-! ## Extensivity: independent verifiers -/

section Product

variable {α₁ α₂ β₁ β₂ : Type*} [Fintype α₁] [Fintype α₂] [Fintype β₁] [Fintype β₂]
  [DecidableEq β₁] [DecidableEq β₂]

omit [Fintype β₁] [Fintype β₂] in
/-- The fibers of a product verifier are the products of the fibers. -/
lemma fiber_prodMap (f : α₁ → β₁) (g : α₂ → β₂) (b : β₁ × β₂) :
    fiber (Prod.map f g) b = (fiber f b.1) ×ˢ (fiber g b.2) := by
  ext x
  simp [mem_fiber, Finset.mem_product, Prod.ext_iff, Prod.map]

omit [Fintype β₁] [Fintype β₂] in
lemma card_fiber_prodMap (f : α₁ → β₁) (g : α₂ → β₂) (b : β₁ × β₂) :
    (fiber (Prod.map f g) b).card = (fiber f b.1).card * (fiber g b.2).card := by
  rw [fiber_prodMap, Finset.card_product]

omit [Fintype β₁] [Fintype β₂] in
lemma image_prodMap (f : α₁ → β₁) (g : α₂ → β₂) :
    (Finset.univ : Finset (α₁ × α₂)).image (Prod.map f g)
      = ((Finset.univ : Finset α₁).image f) ×ˢ ((Finset.univ : Finset α₂).image g) := by
  ext b
  constructor
  · rintro hb
    obtain ⟨x, -, rfl⟩ := Finset.mem_image.1 hb
    exact Finset.mem_product.2
      ⟨Finset.mem_image_of_mem f (Finset.mem_univ x.1),
       Finset.mem_image_of_mem g (Finset.mem_univ x.2)⟩
  · intro hb
    obtain ⟨h1, h2⟩ := Finset.mem_product.1 hb
    obtain ⟨x₁, -, hx₁⟩ := Finset.mem_image.1 h1
    obtain ⟨x₂, -, hx₂⟩ := Finset.mem_image.1 h2
    exact Finset.mem_image.2 ⟨(x₁, x₂), Finset.mem_univ _, by simp [Prod.map, hx₁, hx₂]⟩

omit [Fintype β₁] [Fintype β₂] in
lemma imageCard_prodMap (f : α₁ → β₁) (g : α₂ → β₂) :
    imageCard (Prod.map f g) = imageCard f * imageCard g := by
  rw [imageCard, imageCard, imageCard, image_prodMap, Finset.card_product]

/-- **Extensivity of the expected history capacity.**  Two verifiers run on independent
inputs need exactly the sum of their history capacities: `H(x ∣ f x)` is additive over
products. -/
theorem condEntropy_prodMap [Nonempty α₁] [Nonempty α₂] (f : α₁ → β₁) (g : α₂ → β₂) :
    FiberEntropy.condEntropy (Prod.map f g)
      = FiberEntropy.condEntropy f + FiberEntropy.condEntropy g := by
  classical
  have hN₁ : (0 : ℝ) < (Fintype.card α₁ : ℝ) := by
    have : 0 < Fintype.card α₁ := Fintype.card_pos
    exact_mod_cast this
  have hN₂ : (0 : ℝ) < (Fintype.card α₂ : ℝ) := by
    have : 0 < Fintype.card α₂ := Fintype.card_pos
    exact_mod_cast this
  have hterm : ∀ b : β₁ × β₂,
      ((fiber (Prod.map f g) b).card : ℝ) * Real.logb 2 ((fiber (Prod.map f g) b).card)
        = ((fiber f b.1).card : ℝ) * Real.logb 2 ((fiber f b.1).card)
            * ((fiber g b.2).card : ℝ)
          + ((fiber f b.1).card : ℝ)
            * (((fiber g b.2).card : ℝ) * Real.logb 2 ((fiber g b.2).card)) := by
    intro b
    rw [card_fiber_prodMap]
    rcases Nat.eq_zero_or_pos (fiber f b.1).card with h1 | h1
    · rw [h1]; simp
    rcases Nat.eq_zero_or_pos (fiber g b.2).card with h2 | h2
    · rw [h2]; simp
    have h1' : (0 : ℝ) < ((fiber f b.1).card : ℝ) := by exact_mod_cast h1
    have h2' : (0 : ℝ) < ((fiber g b.2).card : ℝ) := by exact_mod_cast h2
    push_cast
    rw [Real.logb_mul (ne_of_gt h1') (ne_of_gt h2')]
    ring
  rw [FiberEntropy.condEntropy, FiberEntropy.condEntropy, FiberEntropy.condEntropy,
    Fintype.card_prod]
  rw [Finset.sum_congr rfl (fun b _ => hterm b), Fintype.sum_prod_type]
  have hsplit : ∀ b₁ : β₁,
      ∑ b₂ : β₂, (((fiber f b₁).card : ℝ) * Real.logb 2 ((fiber f b₁).card)
          * ((fiber g b₂).card : ℝ)
        + ((fiber f b₁).card : ℝ)
          * (((fiber g b₂).card : ℝ) * Real.logb 2 ((fiber g b₂).card)))
      = ((fiber f b₁).card : ℝ) * Real.logb 2 ((fiber f b₁).card) * (Fintype.card α₂ : ℝ)
        + ((fiber f b₁).card : ℝ)
          * (∑ b₂ : β₂, ((fiber g b₂).card : ℝ) * Real.logb 2 ((fiber g b₂).card)) := by
    intro b₁
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum,
      FiberEntropy.sum_card_fiber_real]
  rw [Finset.sum_congr rfl (fun b₁ _ => hsplit b₁), Finset.sum_add_distrib, ← Finset.sum_mul,
    ← Finset.sum_mul, FiberEntropy.sum_card_fiber_real]
  push_cast
  field_simp

omit [Fintype β₁] [Fintype β₂] in
/-- **Extensivity of the dissipated bits.** -/
theorem erasedBits_prodMap [Nonempty α₁] [Nonempty α₂] (f : α₁ → β₁) (g : α₂ → β₂) :
    erasedBits (Prod.map f g) = erasedBits f + erasedBits g := by
  have hN₁ : (0 : ℝ) < (Fintype.card α₁ : ℝ) := by
    have : 0 < Fintype.card α₁ := Fintype.card_pos
    exact_mod_cast this
  have hN₂ : (0 : ℝ) < (Fintype.card α₂ : ℝ) := by
    have : 0 < Fintype.card α₂ := Fintype.card_pos
    exact_mod_cast this
  have hI₁ : (0 : ℝ) < (imageCard f : ℝ) := by
    have := imageCard_pos f
    exact_mod_cast this
  have hI₂ : (0 : ℝ) < (imageCard g : ℝ) := by
    have := imageCard_pos g
    exact_mod_cast this
  rw [erasedBits, erasedBits, erasedBits, imageCard_prodMap, Fintype.card_prod]
  push_cast
  rw [Real.logb_mul (ne_of_gt hN₁) (ne_of_gt hN₂),
    Real.logb_mul (ne_of_gt hI₁) (ne_of_gt hI₂)]
  ring

/-- **The Jensen defect is extensive.**  Physically: the part of the fiber information that
is *retained* rather than dissipated adds up over independent verifiers, exactly like the
dissipated part.  Together with `jensen_defect_nonneg` this makes the whole space–heat chain
an extensive thermodynamic accounting. -/
theorem jensenDefect_prodMap [Nonempty α₁] [Nonempty α₂] (f : α₁ → β₁) (g : α₂ → β₂) :
    jensenDefect (Prod.map f g) = jensenDefect f + jensenDefect g := by
  have h := jensen_defect_identity (Prod.map f g)
  have h1 := jensen_defect_identity f
  have h2 := jensen_defect_identity g
  have hc := condEntropy_prodMap f g
  have he := erasedBits_prodMap f g
  linarith

end Product

end WeightedFiberEntropy