/-
# The Fiber-Entropy Law: equality holds exactly on fiberwise-uniform laws

## Where this sits in the thread

The thread "Thermodynamics of Mathematical Proof" has so far produced

* `Novelty/ThermodynamicsOfProof.lean` — `imageCard`, `erasedBits`, `landauerCost`;
* `Computation/ReversibleVerificationFrontier.lean` — the sharp reversibility frontier and
  `erasedBits f ≤ log₂ (maxFiber f)`;
* `Computation/FiberEntropyFrontier.lean` — the *uniform* chain
  `erasedBits f ≤ condEntropy f ≤ log₂ (maxFiber f)`;
* `Computation/WeightedFiberEntropy.lean` — the weighted conditional entropy
  `condEntropyW f p`, its chain rule `H(x ∣ f x) = H(p) − H(f_*p)`, and the two ends
  of the frontier for an arbitrary input law.

All of those bound the dissipated information by *worst-case* or *image-counting* data.
Future Direction 1 of the previous cycle asked for the exact law relating the minimal
expected irreversible work of a normalization map to the **expected logarithm of the
normalization-fiber size**:

> the minimum expected irreversible work of normalization equals the expected logarithm of
> the fiber size precisely when the conditional law is uniform on each fiber; otherwise the
> fiber logarithm is a strict upper bound on the Shannon entropy destroyed.

This file proves exactly that, as an `iff`, for every finite terminating normalization map
and every non-negative weight on proof terms.

## Main results

* `expectedLogFiber` — the expected logarithm of the normalization-fiber size,
  `∑ₓ p x · log₂ |f⁻¹(f x)|`; `expectedLogFiber_eq_sum_pushforward` regroups it fiberwise.
* `neg_weighted_logb_eq_iff` — the sharp equality case of the maximum-entropy bound for
  arbitrary non-negative unnormalised weights: the unnormalised Shannon entropy of `q` on a
  finite set `s` equals `(∑ q) · log₂ |s|` **iff** `q` is constant on `s` (equal to the
  average `(∑ q)/|s|`).  Degenerate cases (`s = ∅`, total mass `0`) are included.
* `condEntropyW_le_expectedLogFiber` — the fiber logarithm is an upper bound on the entropy
  destroyed, for every non-negative input law.
* `fiber_entropy_law` — **the law**: equality holds *iff* the input law is constant on every
  fiber, i.e. iff the conditional law is uniform on each fiber.
* `fiber_entropy_strict` — the strict form: any fiberwise non-uniformity makes the fiber
  logarithm a *strict* over-estimate of the destroyed entropy.
* `landauer_fiber_law`, `landauer_fiber_strict` — the same statements in physical units:
  the Landauer work of the fiber-counting bound is attained exactly on fiberwise-uniform
  laws and is strictly wasteful otherwise.
* `condEntropy_eq_expectedLogFiber_unif` — the uniform input law always attains the bound,
  which recovers (and explains) the uniform theory of `FiberEntropyFrontier`.
* `expectedLogFiber_biased32`, `condEntropyW_biased32`, `biased32_gap_pos` — an explicit
  three-term calculus with the biased law `(1/2, 1/4, 1/4)`, where the two quantities are
  `3/4` and `(3/4)·log₂ 3 − 1/2`, so the gap is exactly `5/4 − (3/4)·log₂ 3 > 0`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the inequality `H(x ∣ f x) ≤ E[log₂ |fiber|]` should be an equality
  precisely on fiberwise-uniform laws, because `H(x ∣ f x) = ∑_b P(b) · H(q_b)` where `q_b`
  is the conditional law inside the fiber, and `H(q_b) ≤ log₂ |F_b|` with the classical
  maximum-entropy equality case.
Experiment (Stage 2): the crux is the equality case of Gibbs' inequality for *unnormalised*
  weights, where zero weights must be handled explicitly.  With `t = 0` the Gibbs term
  `t (log c − log t) = 0` is *strictly* below `c − t = c > 0`, so a vanishing weight inside a
  fiber of positive mass already destroys equality — which is the correct behaviour: such a
  law is not uniform on its fiber.
Experiment (Stage 2, numeric): on `![0,0,1] : Fin 3 → Fin 2` with `p = (1/2, 1/4, 1/4)`,
  `E[log₂ |fiber|] = 3/4 = 0.75` while `H(x ∣ f x) = (3/4)log₂ 3 − 1/2 ≈ 0.68872`, a gap of
  `≈ 0.06128` bits; with `p` uniform both equal `2/3`.
Analysis (Stage 3): the law is a genuine two-sided statement, not a bound: the fiber-counting
  heuristic "one pays `log₂ |fiber|` per normalization step" is *exactly* right for uniform
  conditional laws and *always strictly pessimistic* otherwise.  Structurally, the defect is
  the sum over fibers of the entropy deficits `log₂|F_b| − H(q_b)`.
Critique (Stage 4): no normalisation hypothesis is used anywhere (only `0 ≤ p`), so the law
  applies to sub-probability laws and to unnormalised multiplicity counts alike; the
  degenerate fibers of mass `0` are treated, not excluded, and the equality criterion
  `∀ x y, f x = f y → p x = p y` is stated without reference to the support.
Synthesis (Stage 5): fiber counting is thermodynamically exact iff the proof law is
  fiberwise uniform.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof
import Computation.PrefixFreeThermoCoding
import Computation.ReversibleVerificationFrontier
import Computation.FiberEntropyFrontier
import Computation.WeightedFiberEntropy

open Finset Real ThermoProof ReversibleFrontier WeightedFiberEntropy

namespace FiberUniformity

/-! ## The equality case of Gibbs' inequality for unnormalised weights -/

/-- Pointwise Gibbs estimate, allowing a vanishing weight. -/
private lemma gibbs_le {t c : ℝ} (ht : 0 ≤ t) (hc : 0 < c) :
    t * (Real.log c - Real.log t) ≤ c - t := by
  rcases eq_or_lt_of_le ht with h0 | hpos
  · simp [← h0, hc.le]
  · have h1 : Real.log (c / t) ≤ c / t - 1 := Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_div (ne_of_gt hc) (ne_of_gt hpos)] at h1
    have h2 := mul_le_mul_of_nonneg_left h1 hpos.le
    have h3 : t * (c / t - 1) = c - t := by field_simp
    linarith [h2, h3.le, h3.ge]

/-- **Equality case of the pointwise Gibbs estimate.**  For a positive reference value `c`,
`t (log c − log t) = c − t` holds precisely at `t = c`; in particular a vanishing weight is
strictly Gibbs-suboptimal. -/
private lemma gibbs_eq_iff {t c : ℝ} (ht : 0 ≤ t) (hc : 0 < c) :
    t * (Real.log c - Real.log t) = c - t ↔ t = c := by
  constructor
  · intro h
    rcases eq_or_lt_of_le ht with h0 | hpos
    · rw [← h0] at h; simp at h; exact absurd h.symm (ne_of_gt hc)
    · by_contra hne
      have hct : c / t ≠ 1 := by
        intro hct
        exact hne ((div_eq_one_iff_eq (ne_of_gt hpos)).1 hct).symm
      have h1 : Real.log (c / t) < c / t - 1 :=
        Real.log_lt_sub_one_of_pos (by positivity) hct
      rw [Real.log_div (ne_of_gt hc) (ne_of_gt hpos)] at h1
      have h2 := mul_lt_mul_of_pos_left h1 hpos
      have h3 : t * (c / t - 1) = c - t := by field_simp
      rw [h3] at h2
      linarith
  · intro h; subst h; ring

/-- **Sharp maximum-entropy bound for unnormalised weights.**  For a non-negative weight `q`
on a finite set `s`, the unnormalised Shannon entropy `−∑ q x · log₂ (q x / ∑ q)` equals its
maximum `(∑ q) · log₂ |s|` **iff** `q` is constant on `s`, equal to the average.

No normalisation, positivity, or non-emptiness hypothesis is needed; the empty set and the
zero weight are genuine (degenerate) instances. -/
theorem neg_weighted_logb_eq_iff {γ : Type*} (s : Finset γ) (q : γ → ℝ)
    (hq : ∀ x ∈ s, 0 ≤ q x) :
    -∑ x ∈ s, q x * Real.logb 2 (q x / (∑ y ∈ s, q y))
        = (∑ y ∈ s, q y) * Real.logb 2 s.card
      ↔ ∀ x ∈ s, q x = (∑ y ∈ s, q y) / (s.card : ℝ) := by
  classical
  set S : ℝ := ∑ y ∈ s, q y with hSdef
  have hS0 : 0 ≤ S := Finset.sum_nonneg hq
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rcases eq_or_lt_of_le hS0 with hS | hS
  · -- total mass zero: every weight vanishes and both sides are `0`
    have hz : ∀ x ∈ s, q x = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg hq).1 (by rw [← hSdef]; exact hS.symm)
    have hzero : ∑ x ∈ s, q x * Real.logb 2 (q x / S) = 0 :=
      Finset.sum_eq_zero fun x hx => by rw [hz x hx]; ring
    constructor
    · intro _ x hx; rw [hz x hx, ← hS]; simp
    · intro _; rw [hzero, ← hS]; simp
  · -- positive total mass
    have hsne : s.Nonempty := by
      by_contra h
      rw [Finset.not_nonempty_iff_eq_empty] at h
      rw [hSdef, h] at hS; simp at hS
    have hN : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast Finset.card_pos.2 hsne
    set c : ℝ := S / (s.card : ℝ) with hc
    have hcpos : 0 < c := by positivity
    have hcS : (s.card : ℝ) * c = S := by rw [hc]; field_simp
    -- termwise Gibbs comparison
    have hle : ∀ x ∈ s, q x * (Real.log c - Real.log (q x)) ≤ c - q x :=
      fun x hx => gibbs_le (hq x hx) hcpos
    have hiff := Finset.sum_eq_sum_iff_of_le hle
    have hA : ∑ x ∈ s, q x * (Real.log c - Real.log (q x))
        = S * Real.log c - ∑ x ∈ s, q x * Real.log (q x) := by
      rw [Finset.sum_congr rfl (fun x _ => by ring :
        ∀ x ∈ s, q x * (Real.log c - Real.log (q x))
          = q x * Real.log c - q x * Real.log (q x)),
        Finset.sum_sub_distrib, ← Finset.sum_mul, ← hSdef]
    have hB : ∑ x ∈ s, (c - q x) = 0 := by
      rw [Finset.sum_sub_distrib, Finset.sum_const, nsmul_eq_mul, ← hSdef, hcS, sub_self]
    -- rewrite the entropy in natural logarithms
    have hterm : ∀ x ∈ s, q x * Real.logb 2 (q x / S)
        = (q x * Real.log (q x) - q x * Real.log S) / Real.log 2 := by
      intro x hx
      rcases eq_or_lt_of_le (hq x hx) with h0 | hpos
      · simp [← h0]
      · rw [Real.logb, Real.log_div (ne_of_gt hpos) (ne_of_gt hS)]; ring
    have hLHS : -∑ x ∈ s, q x * Real.logb 2 (q x / S)
        = (S * Real.log S - ∑ x ∈ s, q x * Real.log (q x)) / Real.log 2 := by
      rw [Finset.sum_congr rfl hterm, ← Finset.sum_div, ← neg_div]
      congr 1
      rw [Finset.sum_sub_distrib, ← Finset.sum_mul, ← hSdef]
      ring
    have hRHS : S * Real.logb 2 (s.card : ℝ) = (S * Real.log (s.card : ℝ)) / Real.log 2 := by
      rw [Real.logb]; ring
    have hlogc : Real.log c = Real.log S - Real.log (s.card : ℝ) := by
      rw [hc, Real.log_div (ne_of_gt hS) (ne_of_gt hN)]
    rw [hLHS, hRHS, div_left_inj' (ne_of_gt hlog2)]
    constructor
    · intro h
      have hzeroA : ∑ x ∈ s, q x * (Real.log c - Real.log (q x)) = ∑ x ∈ s, (c - q x) := by
        rw [hA, hB, hlogc]; linarith
      intro x hx
      exact (gibbs_eq_iff (hq x hx) hcpos).1 (hiff.1 hzeroA x hx)
    · intro h
      have hzeroA : ∑ x ∈ s, q x * (Real.log c - Real.log (q x)) = ∑ x ∈ s, (c - q x) :=
        hiff.2 fun x hx => (gibbs_eq_iff (hq x hx) hcpos).2 (h x hx)
      rw [hA, hB] at hzeroA
      rw [hlogc] at hzeroA
      linarith

/-! ## The expected logarithm of the normalization fiber -/

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

/-- The **expected logarithm of the normalization-fiber size**: the naive fiber-counting
estimate of the information destroyed by a many-to-one normalization map. -/
noncomputable def expectedLogFiber (f : α → β) (p : α → ℝ) : ℝ :=
  ∑ x, p x * Real.logb 2 ((fiber f (f x)).card)

/-- Fiberwise regrouping of the fiber-counting estimate. -/
lemma expectedLogFiber_eq_sum_pushforward (f : α → β) (p : α → ℝ) :
    expectedLogFiber f p = ∑ b : β, pushforward f p b * Real.logb 2 ((fiber f b).card) := by
  classical
  rw [expectedLogFiber, ← sum_fiberwise f (fun x => p x * Real.logb 2 ((fiber f (f x)).card))]
  refine Finset.sum_congr rfl ?_
  intro b _
  have hrw : ∀ x ∈ fiber f b, p x * Real.logb 2 ((fiber f (f x)).card)
      = p x * Real.logb 2 ((fiber f b).card) := fun x hx => by rw [mem_fiber.1 hx]
  rw [Finset.sum_congr rfl hrw, ← Finset.sum_mul]
  rfl

/-- Fiberwise decomposition of the conditional entropy. -/
lemma condEntropyW_eq_sum_fiber (f : α → β) (p : α → ℝ) :
    condEntropyW f p
      = ∑ b : β, -∑ x ∈ fiber f b, p x * Real.logb 2 (p x / pushforward f p b) := by
  classical
  rw [condEntropyW,
    ← sum_fiberwise f (fun x => p x * Real.logb 2 (p x / pushforward f p (f x))),
    ← Finset.sum_neg_distrib]
  refine Finset.sum_congr rfl ?_
  intro b _
  congr 1
  exact Finset.sum_congr rfl fun x hx => by rw [mem_fiber.1 hx]

/-- **Fiber counting bounds the destroyed entropy.**  For every non-negative law on proof
terms, the Shannon entropy destroyed by normalization is at most the expected logarithm of
the normalization-fiber size. -/
theorem condEntropyW_le_expectedLogFiber (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x) :
    condEntropyW f p ≤ expectedLogFiber f p := by
  classical
  rw [condEntropyW_eq_sum_fiber, expectedLogFiber_eq_sum_pushforward]
  refine Finset.sum_le_sum ?_
  intro b _
  have h := neg_weighted_logb_le (fiber f b) p (fun x _ => hp x)
  have hS : ∑ y ∈ fiber f b, p y = pushforward f p b := rfl
  rwa [hS] at h

/-! ## The law -/

/-- **The fiber-entropy law.**  For a finite terminating normalization map `f` and any
non-negative law `p` on proof terms, the entropy destroyed by normalization equals the
expected logarithm of the normalization-fiber size **iff** `p` is constant on each fiber of
`f`, i.e. iff the conditional law is uniform on every normalization fiber. -/
theorem fiber_entropy_law (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x) :
    condEntropyW f p = expectedLogFiber f p ↔ ∀ x y, f x = f y → p x = p y := by
  classical
  have hle : ∀ b ∈ (Finset.univ : Finset β),
      -∑ x ∈ fiber f b, p x * Real.logb 2 (p x / pushforward f p b)
        ≤ pushforward f p b * Real.logb 2 ((fiber f b).card) := by
    intro b _
    have h := neg_weighted_logb_le (fiber f b) p (fun x _ => hp x)
    have hS : ∑ y ∈ fiber f b, p y = pushforward f p b := rfl
    rwa [hS] at h
  rw [condEntropyW_eq_sum_fiber, expectedLogFiber_eq_sum_pushforward,
    Finset.sum_eq_sum_iff_of_le hle]
  constructor
  · -- fiberwise equality forces fiberwise constancy
    intro h x y hxy
    have hb := h (f x) (Finset.mem_univ _)
    have hS : ∑ z ∈ fiber f (f x), p z = pushforward f p (f x) := rfl
    have hb' : -∑ z ∈ fiber f (f x), p z * Real.logb 2 (p z / (∑ w ∈ fiber f (f x), p w))
        = (∑ w ∈ fiber f (f x), p w) * Real.logb 2 ((fiber f (f x)).card) := by
      rw [hS]; exact hb
    have hconst := (neg_weighted_logb_eq_iff (fiber f (f x)) p (fun z _ => hp z)).1 hb'
    have hx : x ∈ fiber f (f x) := by simp
    have hy : y ∈ fiber f (f x) := by rw [mem_fiber]; exact hxy.symm
    rw [hconst x hx, hconst y hy]
  · -- fiberwise constancy gives equality in every fiber
    intro h b _
    have hS : ∑ y ∈ fiber f b, p y = pushforward f p b := rfl
    have hconst : ∀ x ∈ fiber f b, p x = (∑ y ∈ fiber f b, p y) / ((fiber f b).card : ℝ) := by
      intro x hx
      have hcard : (0 : ℝ) < ((fiber f b).card : ℝ) := by
        exact_mod_cast Finset.card_pos.2 ⟨x, hx⟩
      have hsum : ∑ y ∈ fiber f b, p y = ((fiber f b).card : ℝ) * p x := by
        rw [Finset.sum_congr rfl (fun y hy => h y x (by rw [mem_fiber.1 hy, mem_fiber.1 hx])),
          Finset.sum_const, nsmul_eq_mul]
      rw [hsum]; field_simp
    have := (neg_weighted_logb_eq_iff (fiber f b) p (fun z _ => hp z)).2 hconst
    rwa [hS] at this

/-- **Strict form of the law.**  Any fiberwise non-uniformity of the proof law makes the
fiber-counting estimate a *strict* over-estimate of the destroyed entropy. -/
theorem fiber_entropy_strict (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x)
    (hne : ∃ x y, f x = f y ∧ p x ≠ p y) :
    condEntropyW f p < expectedLogFiber f p := by
  refine lt_of_le_of_ne (condEntropyW_le_expectedLogFiber f p hp) ?_
  intro heq
  obtain ⟨x, y, hxy, hpxy⟩ := hne
  exact hpxy ((fiber_entropy_law f p hp).1 heq x y hxy)

/-! ## Physical reading -/

/-- **Landauer form of the law.**  At any temperature, the minimum expected irreversible work
of normalization equals the Landauer work of the expected fiber logarithm exactly on
fiberwise-uniform laws. -/
theorem landauer_fiber_law (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x) {kB T : ℝ}
    (hkB : 0 < kB) (hT : 0 < T) :
    landauerCost (condEntropyW f p) kB T = landauerCost (expectedLogFiber f p) kB T
      ↔ ∀ x y, f x = f y → p x = p y := by
  have hfac : (0 : ℝ) < kB * T * Real.log 2 := by
    have : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    positivity
  rw [landauerCost, landauerCost, mul_left_inj' (ne_of_gt hfac)]
  exact fiber_entropy_law f p hp

/-- The strict Landauer form: fiberwise non-uniformity makes fiber counting strictly
over-charge the normalization. -/
theorem landauer_fiber_strict (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x)
    (hne : ∃ x y, f x = f y ∧ p x ≠ p y) {kB T : ℝ} (hkB : 0 < kB) (hT : 0 < T) :
    landauerCost (condEntropyW f p) kB T < landauerCost (expectedLogFiber f p) kB T := by
  have hfac : (0 : ℝ) < kB * T * Real.log 2 := by
    have : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    positivity
  exact mul_lt_mul_of_pos_right (fiber_entropy_strict f p hp hne) hfac

/-! ## The uniform law always attains the bound -/

/-- The uniform law on proof terms is fiberwise uniform, hence attains the fiber-counting
bound: this is the structural reason the uniform theory of `FiberEntropyFrontier` is exact. -/
theorem condEntropyW_unif_eq_expectedLogFiber [Nonempty α] (f : α → β) :
    condEntropyW f (unif α) = expectedLogFiber f (unif α) :=
  (fiber_entropy_law f (unif α) (unif_nonneg α)).2 fun _ _ _ => rfl

/-- Consequently the uniform conditional entropy of `FiberEntropyFrontier` *is* the expected
fiber logarithm. -/
theorem condEntropy_eq_expectedLogFiber_unif [Nonempty α] (f : α → β) :
    FiberEntropy.condEntropy f = expectedLogFiber f (unif α) := by
  rw [← condEntropyW_unif f, condEntropyW_unif_eq_expectedLogFiber f]

/-! ## An explicit strict instance -/

/-- The biased law `(1/2, 1/4, 1/4)` on the three proof terms of `Fin 3`. -/
noncomputable def biased32 : Fin 3 → ℝ := fun i => if i = 0 then 1/2 else 1/4

lemma biased32_zero : biased32 0 = 1/2 := by norm_num [biased32]

lemma biased32_one : biased32 1 = 1/4 := by norm_num [biased32]

lemma biased32_two : biased32 2 = 1/4 := by
  rw [biased32, if_neg (by decide : ¬((2 : Fin 3) = 0))]

lemma biased32_nonneg : ∀ x, 0 ≤ biased32 x := by
  intro x; fin_cases x <;> norm_num [biased32]

lemma biased32_sum : ∑ x, biased32 x = 1 := by
  rw [Fin.sum_univ_three, biased32_zero, biased32_one, biased32_two]; norm_num

lemma pushforward_biased32_zero :
    pushforward FiberEntropy.collapse32 biased32 0 = 3 / 4 := by
  have hfib : fiber FiberEntropy.collapse32 (0 : Fin 2) = {0, 1} := by decide
  rw [pushforward, hfib, Finset.sum_pair (by decide), biased32_zero, biased32_one]
  norm_num

lemma pushforward_biased32_one :
    pushforward FiberEntropy.collapse32 biased32 1 = 1 / 4 := by
  have hfib : fiber FiberEntropy.collapse32 (1 : Fin 2) = {2} := by decide
  rw [pushforward, hfib, Finset.sum_singleton, biased32_two]

/-- The fiber-counting estimate for the biased law is exactly `3/4` bits. -/
theorem expectedLogFiber_biased32 :
    expectedLogFiber FiberEntropy.collapse32 biased32 = 3 / 4 := by
  have h0 : (fiber FiberEntropy.collapse32 (FiberEntropy.collapse32 0)).card = 2 := by decide
  have h1 : (fiber FiberEntropy.collapse32 (FiberEntropy.collapse32 1)).card = 2 := by decide
  have h2 : (fiber FiberEntropy.collapse32 (FiberEntropy.collapse32 2)).card = 1 := by decide
  rw [expectedLogFiber, Fin.sum_univ_three, h0, h1, h2, biased32_zero, biased32_one,
    biased32_two]
  norm_num [Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]

/-- The entropy actually destroyed on the biased law is `(3/4)·log₂ 3 − 1/2`. -/
theorem condEntropyW_biased32 :
    condEntropyW FiberEntropy.collapse32 biased32 = (3 / 4) * Real.logb 2 3 - 1 / 2 := by
  have e0 : FiberEntropy.collapse32 0 = 0 := rfl
  have e1 : FiberEntropy.collapse32 1 = 0 := rfl
  have e2 : FiberEntropy.collapse32 2 = 1 := rfl
  rw [condEntropyW, Fin.sum_univ_three, e0, e1, e2,
    pushforward_biased32_zero, pushforward_biased32_one]
  rw [biased32_zero, biased32_one, biased32_two]
  have d1 : (1 / 2 : ℝ) / (3 / 4) = 2 / 3 := by norm_num
  have d2 : (1 / 4 : ℝ) / (3 / 4) = 1 / 3 := by norm_num
  have d3 : (1 / 4 : ℝ) / (1 / 4) = 1 := by norm_num
  rw [d1, d2, d3, Real.logb_one]
  have h23 : Real.logb 2 (2 / 3) = 1 - Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num),
      Real.logb_self_eq_one (by norm_num : (1:ℝ) < 2)]
  have h13 : Real.logb 2 (1 / 3 : ℝ) = -Real.logb 2 3 := by
    rw [Real.logb_div (by norm_num) (by norm_num), Real.logb_one]; ring
  rw [h23, h13]
  ring

/-- **The gap is strictly positive**: on the biased law the fiber logarithm over-charges the
normalization by exactly `5/4 − (3/4)·log₂ 3 ≈ 0.0613` bits. -/
theorem biased32_gap_pos :
    condEntropyW FiberEntropy.collapse32 biased32
      < expectedLogFiber FiberEntropy.collapse32 biased32 := by
  rw [condEntropyW_biased32, expectedLogFiber_biased32]
  linarith [FiberEntropy.logb_two_three_lt]

/-- The same strictness obtained structurally from the law, with no numerics: the biased law
is not constant on the fiber `{0, 1}`. -/
theorem biased32_strict_from_law :
    condEntropyW FiberEntropy.collapse32 biased32
      < expectedLogFiber FiberEntropy.collapse32 biased32 :=
  fiber_entropy_strict _ _ biased32_nonneg
    ⟨0, 1, rfl, by rw [biased32_zero, biased32_one]; norm_num⟩

end FiberUniformity