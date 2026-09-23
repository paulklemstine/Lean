/-
# The type channel: a finite joint-distribution framework

This file sets up the information-theoretic core behind the "type-channel" program.

A Frobenius experiment attaches to each unramified prime `p` two observables:

* its **type** `T` (the factorization/cycle type of `Frob_p`, a class function on the
  Galois group `G`), and
* its **abelianization coset** `C` (the image of `Frob_p` in a finite abelian quotient
  `A` of `G`, which by class field theory is a function of `p mod m*`).

Under Chebotarev the pair `(T, C)` is distributed as the pair of observables of a
*uniform* element of `G`.  This file formalizes exactly that finite object: a joint
probability table `Joint ι κ` on types `ι` and cosets `κ`, its Shannon entropies in
bits, its mutual information, and the general laws

* `gap_eq`              : `H(T) - I(T;C) = H(T|C)` (the "gap" is the coset-conditioned
                          type entropy);
* `condEntropy_nonneg`  : `H(T|C) ≥ 0`;
* `mutualInfo_nonneg`   : `I(T;C) ≥ 0`;
* `mutualInfo_eq_Hcoset_of_determines` : **the abelianization law** — if the type
                          determines the coset then `I(T;C) = H(C)`, and hence the gap
                          is exactly `H(T) - H(C)`;
* `mutualInfo_eq_Htype_of_codetermines` : the dual law, used for cyclic groups where
                          the coset determines the type.

All entropies are measured in bits (natural logs divided by `log 2`).
-/
import Mathlib

open Finset Real

namespace TypeChannel

/-- A finite joint probability table on a type alphabet `ι` and a coset alphabet `κ`. -/
structure Joint (ι κ : Type) [Fintype ι] [Fintype κ] where
  /-- The joint probability mass of the pair `(t, c)`. -/
  p : ι → κ → ℝ
  nonneg : ∀ t c, 0 ≤ p t c
  total : ∑ t : ι, ∑ c : κ, p t c = 1

namespace Joint

variable {ι κ : Type} [Fintype ι] [Fintype κ] (J : Joint ι κ)

/-- Marginal distribution of the type observable. -/
def typeMarg (t : ι) : ℝ := ∑ c : κ, J.p t c

/-- Marginal distribution of the abelianization-coset observable. -/
def cosetMarg (c : κ) : ℝ := ∑ t : ι, J.p t c

/-- Shannon entropy in bits of the type marginal. -/
noncomputable def Htype : ℝ := (∑ t : ι, negMulLog (J.typeMarg t)) / Real.log 2

/-- Shannon entropy in bits of the coset marginal. -/
noncomputable def Hcoset : ℝ := (∑ c : κ, negMulLog (J.cosetMarg c)) / Real.log 2

/-- Joint Shannon entropy in bits. -/
noncomputable def Hjoint : ℝ := (∑ t : ι, ∑ c : κ, negMulLog (J.p t c)) / Real.log 2

/-- Mutual information `I(T;C) = H(T) + H(C) - H(T,C)`, in bits. -/
noncomputable def mutualInfo : ℝ := J.Htype + J.Hcoset - J.Hjoint

/-- Conditional entropy `H(T|C) = H(T,C) - H(C)`, in bits. -/
noncomputable def condTypeGivenCoset : ℝ := J.Hjoint - J.Hcoset

/-- Conditional entropy `H(C|T) = H(T,C) - H(T)`, in bits. -/
noncomputable def condCosetGivenType : ℝ := J.Hjoint - J.Htype

lemma typeMarg_nonneg (t : ι) : 0 ≤ J.typeMarg t :=
  Finset.sum_nonneg fun c _ => J.nonneg t c

lemma cosetMarg_nonneg (c : κ) : 0 ≤ J.cosetMarg c :=
  Finset.sum_nonneg fun t _ => J.nonneg t c

lemma le_typeMarg (t : ι) (c : κ) : J.p t c ≤ J.typeMarg t :=
  Finset.single_le_sum (f := fun c => J.p t c) (fun c _ => J.nonneg t c) (mem_univ c)

lemma le_cosetMarg (t : ι) (c : κ) : J.p t c ≤ J.cosetMarg c :=
  Finset.single_le_sum (f := fun t => J.p t c) (fun t _ => J.nonneg t c) (mem_univ t)

lemma sum_typeMarg : ∑ t : ι, J.typeMarg t = 1 := J.total

lemma sum_cosetMarg : ∑ c : κ, J.cosetMarg c = 1 := by
  simp only [cosetMarg]
  rw [Finset.sum_comm]
  exact J.total

/-- **The gap identity**: the shortfall of the mutual information below the type
entropy is exactly the coset-conditioned type entropy. -/
theorem gap_eq : J.Htype - J.mutualInfo = J.condTypeGivenCoset := by
  unfold mutualInfo condTypeGivenCoset; ring

/-- The swapped table, exchanging the roles of types and cosets. -/
def swap : Joint κ ι where
  p c t := J.p t c
  nonneg c t := J.nonneg t c
  total := by rw [Finset.sum_comm]; exact J.total

@[simp] lemma swap_typeMarg (c : κ) : J.swap.typeMarg c = J.cosetMarg c := rfl
@[simp] lemma swap_cosetMarg (t : ι) : J.swap.cosetMarg t = J.typeMarg t := rfl
@[simp] lemma swap_Htype : J.swap.Htype = J.Hcoset := rfl
@[simp] lemma swap_Hcoset : J.swap.Hcoset = J.Htype := rfl

@[simp] lemma swap_Hjoint : J.swap.Hjoint = J.Hjoint := by
  unfold Hjoint swap
  simp only []
  rw [Finset.sum_comm]

@[simp] lemma swap_mutualInfo : J.swap.mutualInfo = J.mutualInfo := by
  unfold mutualInfo; simp; ring

/-- Pointwise step for conditional-entropy nonnegativity: if `0 ≤ a ≤ b ≤ 1` then
`negMulLog a ≥ a * (-log b)`, i.e. the joint term dominates the marginal term. -/
lemma negMulLog_ge_of_le {a b : ℝ} (ha : 0 ≤ a) (hab : a ≤ b) :
    a * (-Real.log b) ≤ negMulLog a := by
  rcases eq_or_lt_of_le ha with h | h
  · simp [negMulLog, ← h]
  · have hb : 0 < b := lt_of_lt_of_le h hab
    have : Real.log a ≤ Real.log b := Real.log_le_log h hab
    have := mul_le_mul_of_nonneg_left this ha
    simp only [negMulLog]
    nlinarith

/-- **Conditional entropy is nonnegative**: `H(T|C) ≥ 0`. -/
theorem condEntropy_nonneg : 0 ≤ J.condTypeGivenCoset := by
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have key : ∑ c : κ, negMulLog (J.cosetMarg c) ≤ ∑ t : ι, ∑ c : κ, negMulLog (J.p t c) := by
    have expand : ∑ c : κ, negMulLog (J.cosetMarg c)
        = ∑ c : κ, ∑ t : ι, J.p t c * (-Real.log (J.cosetMarg c)) := by
      refine Finset.sum_congr rfl fun c _ => ?_
      rw [← Finset.sum_mul, show ∑ t : ι, J.p t c = J.cosetMarg c from rfl, negMulLog]
      ring
    rw [expand, Finset.sum_comm]
    refine Finset.sum_le_sum fun t _ => Finset.sum_le_sum fun c _ => ?_
    exact negMulLog_ge_of_le (J.nonneg t c) (J.le_cosetMarg t c)
  unfold condTypeGivenCoset Hjoint Hcoset
  rw [sub_nonneg, div_le_div_iff_of_pos_right hlog2]
  exact key

/-- `H(C|T) ≥ 0`. -/
theorem condCosetGivenType_nonneg : 0 ≤ J.condCosetGivenType := by
  have := J.swap.condEntropy_nonneg
  unfold condTypeGivenCoset at this
  unfold condCosetGivenType
  simpa using this

/-- `I(T;C) ≤ H(T)`. -/
theorem mutualInfo_le_Htype : J.mutualInfo ≤ J.Htype := by
  have := J.condEntropy_nonneg
  unfold condTypeGivenCoset at this
  unfold mutualInfo
  linarith

/-- `I(T;C) ≤ H(C)`. -/
theorem mutualInfo_le_Hcoset : J.mutualInfo ≤ J.Hcoset := by
  have := J.condCosetGivenType_nonneg
  unfold condCosetGivenType at this
  unfold mutualInfo
  linarith

/-- **Mutual information is nonnegative.**  Proved by the `log x ≤ x - 1` bound applied
to the likelihood ratio, summed over the support of the joint table. -/
theorem mutualInfo_nonneg : 0 ≤ J.mutualInfo := by
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  set S : Finset (ι × κ) := Finset.univ.filter (fun x => 0 < J.p x.1 x.2) with hS
  -- Sums over the support agree with sums over everything, for terms killed by `p = 0`.
  have hsupp : ∀ (f : ι → κ → ℝ), (∀ t c, J.p t c = 0 → f t c = 0) →
      ∑ x ∈ S, f x.1 x.2 = ∑ t : ι, ∑ c : κ, f t c := by
    intro f hf
    have hprod : ∑ t : ι, ∑ c : κ, f t c
        = ∑ x ∈ (Finset.univ : Finset (ι × κ)), f x.1 x.2 :=
      (Fintype.sum_prod_type (f := fun x : ι × κ => f x.1 x.2)).symm
    rw [hprod]
    refine Finset.sum_subset (Finset.subset_univ S) ?_
    intro x _ hx
    have hnp : ¬ (0 < J.p x.1 x.2) := by simpa [hS] using hx
    exact hf _ _ (le_antisymm (not_lt.1 hnp) (J.nonneg _ _))
  have e1 : ∑ t : ι, negMulLog (J.typeMarg t)
      = ∑ x ∈ S, J.p x.1 x.2 * (-Real.log (J.typeMarg x.1)) := by
    rw [hsupp (fun t c => J.p t c * (-Real.log (J.typeMarg t))) (by intro t c h; simp [h])]
    refine Finset.sum_congr rfl fun t _ => ?_
    rw [← Finset.sum_mul, show ∑ c : κ, J.p t c = J.typeMarg t from rfl, negMulLog]
    ring
  have e2 : ∑ c : κ, negMulLog (J.cosetMarg c)
      = ∑ x ∈ S, J.p x.1 x.2 * (-Real.log (J.cosetMarg x.2)) := by
    rw [hsupp (fun t c => J.p t c * (-Real.log (J.cosetMarg c))) (by intro t c h; simp [h]),
      Finset.sum_comm]
    refine Finset.sum_congr rfl fun c _ => ?_
    rw [← Finset.sum_mul, show ∑ t : ι, J.p t c = J.cosetMarg c from rfl, negMulLog]
    ring
  have e3 : ∑ t : ι, ∑ c : κ, negMulLog (J.p t c)
      = ∑ x ∈ S, negMulLog (J.p x.1 x.2) :=
    (hsupp (fun t c => negMulLog (J.p t c)) (by intro t c h; simp [h, negMulLog])).symm
  -- Express `I * log 2` as a sum of `p * log (p / (pT pC))` terms over the support.
  have hI : (J.Htype + J.Hcoset - J.Hjoint) * Real.log 2
      = ∑ x ∈ S, J.p x.1 x.2 *
          Real.log (J.p x.1 x.2 / (J.typeMarg x.1 * J.cosetMarg x.2)) := by
    unfold Htype Hcoset Hjoint
    rw [show (∑ t : ι, negMulLog (J.typeMarg t)) / Real.log 2
          + (∑ c : κ, negMulLog (J.cosetMarg c)) / Real.log 2
          - (∑ t : ι, ∑ c : κ, negMulLog (J.p t c)) / Real.log 2
        = ((∑ t : ι, negMulLog (J.typeMarg t)) + (∑ c : κ, negMulLog (J.cosetMarg c))
            - (∑ t : ι, ∑ c : κ, negMulLog (J.p t c))) / Real.log 2 from by ring,
      div_mul_cancel₀ _ (ne_of_gt hlog2), e1, e2, e3, ← Finset.sum_add_distrib,
      ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun x hx => ?_
    have hp : 0 < J.p x.1 x.2 := by simpa [hS] using hx
    have hT : 0 < J.typeMarg x.1 := lt_of_lt_of_le hp (J.le_typeMarg _ _)
    have hC : 0 < J.cosetMarg x.2 := lt_of_lt_of_le hp (J.le_cosetMarg _ _)
    rw [Real.log_div (ne_of_gt hp) (by positivity), Real.log_mul (ne_of_gt hT) (ne_of_gt hC),
      negMulLog]
    ring
  -- Each reciprocal-ratio term is bounded by `pT pC - p` via `log x ≤ x - 1`.
  have hbound : ∑ x ∈ S, J.p x.1 x.2 *
        Real.log (J.typeMarg x.1 * J.cosetMarg x.2 / J.p x.1 x.2) ≤ 0 := by
    have step : ∀ x ∈ S, J.p x.1 x.2 *
        Real.log (J.typeMarg x.1 * J.cosetMarg x.2 / J.p x.1 x.2)
        ≤ J.typeMarg x.1 * J.cosetMarg x.2 - J.p x.1 x.2 := by
      intro x hx
      have hp : 0 < J.p x.1 x.2 := by simpa [hS] using hx
      have hT : 0 < J.typeMarg x.1 := lt_of_lt_of_le hp (J.le_typeMarg _ _)
      have hC : 0 < J.cosetMarg x.2 := lt_of_lt_of_le hp (J.le_cosetMarg _ _)
      have hr : 0 < J.typeMarg x.1 * J.cosetMarg x.2 / J.p x.1 x.2 := by positivity
      have hlog := mul_le_mul_of_nonneg_left (Real.log_le_sub_one_of_pos hr) (le_of_lt hp)
      calc J.p x.1 x.2 * Real.log (J.typeMarg x.1 * J.cosetMarg x.2 / J.p x.1 x.2)
          ≤ J.p x.1 x.2 * (J.typeMarg x.1 * J.cosetMarg x.2 / J.p x.1 x.2 - 1) := hlog
        _ = J.typeMarg x.1 * J.cosetMarg x.2 - J.p x.1 x.2 := by field_simp
    refine le_trans (Finset.sum_le_sum step) ?_
    have h1 : ∑ x ∈ S, (J.typeMarg x.1 * J.cosetMarg x.2 - J.p x.1 x.2)
        = (∑ x ∈ S, J.typeMarg x.1 * J.cosetMarg x.2) - ∑ x ∈ S, J.p x.1 x.2 := by
      rw [Finset.sum_sub_distrib]
    have h2 : ∑ x ∈ S, J.p x.1 x.2 = 1 := by
      rw [hsupp (fun t c => J.p t c) (by intro t c h; exact h)]
      exact J.total
    have h3 : ∑ x ∈ S, J.typeMarg x.1 * J.cosetMarg x.2 ≤ 1 := by
      have hle : ∑ x ∈ S, J.typeMarg x.1 * J.cosetMarg x.2
          ≤ ∑ x ∈ (Finset.univ : Finset (ι × κ)), J.typeMarg x.1 * J.cosetMarg x.2 :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
          (fun x _ _ => mul_nonneg (J.typeMarg_nonneg _) (J.cosetMarg_nonneg _))
      refine le_trans hle (le_of_eq ?_)
      rw [Fintype.sum_prod_type]
      simp only [← Finset.mul_sum, J.sum_cosetMarg, mul_one]
      exact J.sum_typeMarg
    rw [h1, h2]; linarith
  have hneg : ∀ x ∈ S, J.p x.1 x.2 *
      Real.log (J.p x.1 x.2 / (J.typeMarg x.1 * J.cosetMarg x.2))
      = - (J.p x.1 x.2 * Real.log (J.typeMarg x.1 * J.cosetMarg x.2 / J.p x.1 x.2)) := by
    intro x hx
    have hp : 0 < J.p x.1 x.2 := by simpa [hS] using hx
    have hT : 0 < J.typeMarg x.1 := lt_of_lt_of_le hp (J.le_typeMarg _ _)
    have hC : 0 < J.cosetMarg x.2 := lt_of_lt_of_le hp (J.le_cosetMarg _ _)
    have hinv : J.p x.1 x.2 / (J.typeMarg x.1 * J.cosetMarg x.2)
        = (J.typeMarg x.1 * J.cosetMarg x.2 / J.p x.1 x.2)⁻¹ := by
      field_simp
    rw [hinv, Real.log_inv]
    ring
  have hfinal : (0:ℝ) ≤ (J.Htype + J.Hcoset - J.Hjoint) * Real.log 2 := by
    rw [hI, Finset.sum_congr rfl hneg, Finset.sum_neg_distrib]
    linarith [hbound]
  unfold mutualInfo
  nlinarith [hfinal, hlog2]

/-- If a nonnegative finite family is supported on at most one index, the sum of its
`negMulLog` values is the `negMulLog` of its sum. -/
lemma sum_negMulLog_of_subsingleton_support {α : Type} [Fintype α] (f : α → ℝ)
    (hf : ∀ a, 0 ≤ f a) (h : ∀ a b, 0 < f a → 0 < f b → a = b) :
    ∑ a : α, negMulLog (f a) = negMulLog (∑ a : α, f a) := by
  by_cases hall : ∀ a, f a = 0
  · simp [hall, negMulLog]
  · push_neg at hall
    obtain ⟨a₀, ha₀⟩ := hall
    have hpos : 0 < f a₀ := lt_of_le_of_ne (hf a₀) (Ne.symm ha₀)
    have hzero : ∀ a, a ≠ a₀ → f a = 0 := by
      intro a ha
      by_contra hne
      exact ha (h a a₀ (lt_of_le_of_ne (hf a) (Ne.symm hne)) hpos)
    rw [Finset.sum_eq_single a₀ (fun b _ hb => by simp [hzero b hb, negMulLog])
        (fun hb => absurd (mem_univ a₀) hb),
      Finset.sum_eq_single a₀ (fun b _ hb => hzero b hb) (fun hb => absurd (mem_univ a₀) hb)]

/-- **The abelianization law.**  If the type observable determines the coset observable
(each type occurs with a single coset), then the mutual information between them is
exactly the coset entropy, and the whole gap `H(T) - I` is the coset-conditioned type
entropy. -/
theorem mutualInfo_eq_Hcoset_of_determines
    (hdet : ∀ t c c', 0 < J.p t c → 0 < J.p t c' → c = c') :
    J.mutualInfo = J.Hcoset := by
  have hj : J.Hjoint = J.Htype := by
    unfold Hjoint Htype
    congr 1
    refine Finset.sum_congr rfl fun t _ => ?_
    exact sum_negMulLog_of_subsingleton_support (fun c => J.p t c) (fun c => J.nonneg t c)
      (fun c c' hc hc' => hdet t c c' hc hc')
  unfold mutualInfo
  rw [hj]; ring

/-- `negMulLog` of a product of nonnegative reals, with the convention `log 0 = 0`. -/
lemma negMulLog_mul {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) :
    negMulLog (x * y) = y * negMulLog x + x * negMulLog y := by
  rcases eq_or_lt_of_le hx with hx0 | hx0
  · simp [negMulLog, ← hx0]
  rcases eq_or_lt_of_le hy with hy0 | hy0
  · simp [negMulLog, ← hy0]
  simp only [negMulLog, Real.log_mul (ne_of_gt hx0) (ne_of_gt hy0)]
  ring

/-- **Independent observables carry no information about each other.** -/
theorem mutualInfo_eq_zero_of_indep
    (h : ∀ t c, J.p t c = J.typeMarg t * J.cosetMarg c) : J.mutualInfo = 0 := by
  have hjoint : J.Hjoint = J.Htype + J.Hcoset := by
    unfold Hjoint Htype Hcoset
    rw [← add_div]
    congr 1
    have expand : ∀ t : ι, ∑ c : κ, negMulLog (J.p t c)
        = negMulLog (J.typeMarg t) + J.typeMarg t * ∑ c : κ, negMulLog (J.cosetMarg c) := by
      intro t
      have step : ∀ c : κ, negMulLog (J.p t c)
          = J.cosetMarg c * negMulLog (J.typeMarg t)
            + J.typeMarg t * negMulLog (J.cosetMarg c) := by
        intro c
        rw [h t c, negMulLog_mul (J.typeMarg_nonneg t) (J.cosetMarg_nonneg c)]
      rw [Finset.sum_congr rfl fun c _ => step c, Finset.sum_add_distrib, ← Finset.sum_mul,
        ← Finset.mul_sum, J.sum_cosetMarg, one_mul]
    rw [Finset.sum_congr rfl fun t _ => expand t, Finset.sum_add_distrib, ← Finset.sum_mul,
      J.sum_typeMarg, one_mul]
  unfold mutualInfo
  rw [hjoint]; ring

/-- A uniform coset marginal has entropy `log₂` of the alphabet size. -/
theorem Hcoset_of_uniform [Nonempty κ]
    (h : ∀ c, J.cosetMarg c = 1 / Fintype.card κ) :
    J.Hcoset = Real.logb 2 (Fintype.card κ) := by
  have hN : (0:ℝ) < Fintype.card κ := by
    exact_mod_cast Fintype.card_pos_iff.mpr inferInstance
  have hterm : ∀ c : κ, negMulLog (J.cosetMarg c)
      = (1 / Fintype.card κ) * Real.log (Fintype.card κ) := by
    intro c
    rw [h c, negMulLog, Real.log_div one_ne_zero (ne_of_gt hN), Real.log_one]
    ring
  unfold Hcoset
  rw [Finset.sum_congr rfl fun c _ => hterm c]
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [Real.logb]
  field_simp

/-- The dual law: if the coset determines the type, the mutual information equals the
type entropy. -/
theorem mutualInfo_eq_Htype_of_codetermines
    (hdet : ∀ t t' c, 0 < J.p t c → 0 < J.p t' c → t = t') :
    J.mutualInfo = J.Htype := by
  have := J.swap.mutualInfo_eq_Hcoset_of_determines (by
    intro c t t' h h'
    exact hdet t t' c h h')
  rw [swap_mutualInfo, swap_Hcoset] at this
  exact this

end Joint

end TypeChannel