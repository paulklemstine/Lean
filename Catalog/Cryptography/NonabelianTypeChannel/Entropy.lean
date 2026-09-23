import Mathlib

/-!
# A finite Shannon channel calculus for splitting statistics

This file develops, from scratch, the small amount of information theory needed to
state and prove the **type-channel law**: for a number field with Galois group `G`,
the mutual information between the residue class of a prime and its splitting type
is exactly the mutual information between the splitting type and the coset of the
Frobenius element modulo the derived subgroup (the *abelianization content*).

Everything here is finite and uniform: the sample space is a `Finset Ω`, every point
has weight `1 / |S|`, and observables are arbitrary functions `f : Ω → α`.  This is
precisely the Chebotarev picture: Frobenius is equidistributed over the group, so the
statistics of a splitting channel are the statistics of a uniform group element.

## Main definitions

* `TypeChannel.prob S f a` — the probability that the observable `f` reads `a`.
* `TypeChannel.entropy S f` — Shannon entropy `H(f)` in bits.
* `TypeChannel.condEntropy S g f` — conditional entropy `H(g | f)`.
* `TypeChannel.mutualInfo S f g` — mutual information `I(f ; g)`.

## Main results

* `TypeChannel.entropy_nonneg`, `TypeChannel.condEntropy_nonneg` — positivity.
* `TypeChannel.mutualInfo_nonneg` — Gibbs' inequality, via `log x ≤ x - 1`.
* `TypeChannel.mutualInfo_le_left` / `_right` — the **cap**: a channel never carries
  more than the entropy of either of its two readouts.
* `TypeChannel.mutualInfo_eq_left_of_factors` — if one readout is a function of the
  other, the channel is *complete*: `I = H(f)`.
* `TypeChannel.entropy_comp_of_injOn`, `TypeChannel.mutualInfo_comp_left` — relabelling
  invariance: an injective recoding of a readout changes nothing.
* `TypeChannel.entropy_eq_logb_card_of_uniform_fibers` — a balanced readout with `m`
  values carries exactly `log₂ m` bits.
* `TypeChannel.entropy_eq_sumList` — the evaluation interface used for concrete groups.
-/

namespace TypeChannel

open Finset Real

variable {Ω α β : Type*} [DecidableEq α] [DecidableEq β]

/-- The fibre of the observable `f` over the value `a`, inside the sample space `S`. -/
def fiber (S : Finset Ω) (f : Ω → α) (a : α) : Finset Ω := S.filter (fun w => f w = a)

/-- The probability that `f` reads `a`, for a uniform point of `S`. -/
noncomputable def prob (S : Finset Ω) (f : Ω → α) (a : α) : ℝ :=
  (fiber S f a).card / S.card

/-- Shannon entropy of the observable `f`, in bits. -/
noncomputable def entropy (S : Finset Ω) (f : Ω → α) : ℝ :=
  ∑ a ∈ S.image f, -(prob S f a * logb 2 (prob S f a))

/-- The joint observable. -/
def pairObs (f : Ω → α) (g : Ω → β) : Ω → α × β := fun w => (f w, g w)

/-- Conditional entropy `H(g | f) = H(f, g) - H(f)`. -/
noncomputable def condEntropy (S : Finset Ω) (g : Ω → β) (f : Ω → α) : ℝ :=
  entropy S (pairObs f g) - entropy S f

/-- Mutual information `I(f ; g) = H(f) + H(g) - H(f, g)`, in bits. -/
noncomputable def mutualInfo (S : Finset Ω) (f : Ω → α) (g : Ω → β) : ℝ :=
  entropy S f + entropy S g - entropy S (pairObs f g)

section Basic

variable {S : Finset Ω} {f : Ω → α} {g : Ω → β} {a : α}

lemma fiber_subset : fiber S f a ⊆ S := filter_subset _ _

lemma prob_nonneg (S : Finset Ω) (f : Ω → α) (a : α) : 0 ≤ prob S f a := by
  unfold prob; positivity

lemma prob_le_one (S : Finset Ω) (f : Ω → α) (a : α) : prob S f a ≤ 1 := by
  unfold prob
  rcases S.eq_empty_or_nonempty with rfl | hS
  · simp [fiber]
  · rw [div_le_one (by exact_mod_cast card_pos.mpr hS)]
    exact_mod_cast card_le_card fiber_subset

lemma prob_eq_zero_of_not_mem (h : a ∉ S.image f) : prob S f a = 0 := by
  have hfib : fiber S f a = ∅ := by
    rw [fiber, Finset.filter_eq_empty_iff]
    intro w hw hfa
    exact h (mem_image.mpr ⟨w, hw, hfa⟩)
  simp [prob, hfib]

lemma prob_pos_of_mem (h : a ∈ S.image f) : 0 < prob S f a := by
  obtain ⟨w, hw, rfl⟩ := mem_image.mp h
  have hne : (fiber S f (f w)).Nonempty := ⟨w, mem_filter.mpr ⟨hw, rfl⟩⟩
  have hS : (0:ℝ) < S.card := by exact_mod_cast card_pos.mpr ⟨w, hw⟩
  have hc : (0:ℝ) < (fiber S f (f w)).card := by exact_mod_cast card_pos.mpr hne
  exact div_pos hc hS

/-- Entropy may be summed over any finite set of values covering the image. -/
lemma entropy_eq_sum_of_subset {A : Finset α} (h : S.image f ⊆ A) :
    entropy S f = ∑ a ∈ A, -(prob S f a * logb 2 (prob S f a)) := by
  refine Finset.sum_subset h ?_
  intro a _ ha
  rw [prob_eq_zero_of_not_mem ha]
  simp

/-- The probabilities of an observable sum to one. -/
lemma sum_prob (hS : S.Nonempty) : ∑ a ∈ S.image f, prob S f a = 1 := by
  have hcard : (0:ℝ) < S.card := by exact_mod_cast card_pos.mpr hS
  unfold prob
  rw [← Finset.sum_div, div_eq_one_iff_eq (ne_of_gt hcard)]
  rw [Finset.card_eq_sum_card_image f S]
  push_cast
  rfl

lemma sum_prob_of_subset {A : Finset α} (hS : S.Nonempty) (h : S.image f ⊆ A) :
    ∑ a ∈ A, prob S f a = 1 := by
  rw [← sum_prob (f := f) hS]
  refine (Finset.sum_subset h ?_).symm
  intro a _ ha
  exact prob_eq_zero_of_not_mem ha

lemma entropy_nonneg (S : Finset Ω) (f : Ω → α) : 0 ≤ entropy S f := by
  refine Finset.sum_nonneg ?_
  intro a _
  have h0 : 0 ≤ prob S f a := prob_nonneg _ _ _
  have h1 : prob S f a ≤ 1 := prob_le_one _ _ _
  have : logb 2 (prob S f a) ≤ 0 := Real.logb_nonpos (by norm_num) h0 h1
  nlinarith

/-- Entropy only depends on the restriction of the observable to the sample space. -/
lemma entropy_congr {f f' : Ω → α} (h : ∀ w ∈ S, f w = f' w) :
    entropy S f = entropy S f' := by
  have himg : S.image f = S.image f' := Finset.image_congr h
  have hfib : ∀ a, fiber S f a = fiber S f' a := by
    intro a
    unfold fiber
    exact Finset.filter_congr (fun w hw => by rw [h w hw])
  unfold entropy prob
  rw [himg]
  simp_rw [hfib]

/-- The entropy of a constant readout is zero. -/
lemma entropy_const (S : Finset Ω) (a : α) : entropy S (fun _ => a) = 0 := by
  rcases S.eq_empty_or_nonempty with rfl | hS
  · simp [entropy]
  · obtain ⟨w₀, hw₀⟩ := hS
    have hS : S.Nonempty := ⟨w₀, hw₀⟩
    have himg : S.image (fun _ => a) = {a} := by
      ext x
      simp only [Finset.mem_image, Finset.mem_singleton]
      exact ⟨by rintro ⟨u, _, rfl⟩; rfl, by rintro rfl; exact ⟨w₀, hw₀, rfl⟩⟩
    have hfib : fiber S (fun _ => a) a = S := by
      unfold fiber; simp
    have hcard : (0:ℝ) < S.card := by exact_mod_cast card_pos.mpr hS
    unfold entropy
    rw [himg]
    simp [prob, hfib, div_self (ne_of_gt hcard)]

/-- Relabelling a readout injectively does not change its entropy. -/
lemma entropy_comp_of_injOn {φ : α → β} (h : Set.InjOn φ (S.image f : Finset α)) :
    entropy S (fun w => φ (f w)) = entropy S f := by
  have himg : S.image (fun w => φ (f w)) = (S.image f).image φ := by
    rw [Finset.image_image]; rfl
  have hfib : ∀ a ∈ S.image f, fiber S (fun w => φ (f w)) (φ a) = fiber S f a := by
    intro a ha
    unfold fiber
    refine Finset.filter_congr (fun w hw => ?_)
    constructor
    · intro hh
      exact h (Finset.mem_coe.mpr (mem_image_of_mem f hw)) (Finset.mem_coe.mpr ha) hh
    · intro hh; exact congrArg φ hh
  unfold entropy
  rw [himg, Finset.sum_image (fun x hx y hy hxy =>
    h (Finset.mem_coe.mpr hx) (Finset.mem_coe.mpr hy) hxy)]
  refine Finset.sum_congr rfl (fun a ha => ?_)
  unfold prob
  rw [hfib a ha]

/-- A balanced readout with `m` distinct values carries exactly `log₂ m` bits. -/
lemma entropy_eq_logb_card_of_uniform_fibers {k : ℕ} (hS : S.Nonempty) (hk : 0 < k)
    (h : ∀ a ∈ S.image f, (fiber S f a).card = k) :
    entropy S f = logb 2 (S.image f).card := by
  set m := (S.image f).card with hm
  have hmpos : 0 < m := by
    rw [hm, Finset.card_pos]
    exact hS.image f
  have hcard : S.card = k * m := by
    have h0 := Finset.card_eq_sum_card_image f S
    have h1 : ∀ b ∈ S.image f, (S.filter (fun a => f a = b)).card = k := fun b hb => h b hb
    rw [h0, Finset.sum_congr rfl h1, Finset.sum_const, smul_eq_mul, mul_comm, hm]
  have hprob : ∀ a ∈ S.image f, prob S f a = ((m : ℝ))⁻¹ := by
    intro a ha
    unfold prob
    rw [h a ha, hcard]
    push_cast
    rw [mul_comm]
    field_simp
  unfold entropy
  rw [Finset.sum_congr rfl (fun a ha => by rw [hprob a ha])]
  rw [Finset.sum_const, ← hm, nsmul_eq_mul, Real.logb_inv]
  have hmne : (m:ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hmpos.ne'
  field_simp

end Basic

section Joint

variable {S : Finset Ω} {f : Ω → α} {g : Ω → β}

lemma image_pairObs_subset : S.image (pairObs f g) ⊆ S.image f ×ˢ S.image g := by
  intro x hx
  obtain ⟨w, hw, rfl⟩ := mem_image.mp hx
  exact mem_product.mpr ⟨mem_image_of_mem _ hw, mem_image_of_mem _ hw⟩

lemma fiber_pair_eq (a : α) (b : β) :
    fiber S (pairObs f g) (a, b) = (fiber S f a).filter (fun w => g w = b) := by
  unfold fiber pairObs
  rw [Finset.filter_filter]
  apply Finset.filter_congr
  intro w _
  simp [Prod.ext_iff]

/-- Marginalising the joint distribution over the second coordinate. -/
lemma sum_prob_pair_right (a : α) :
    ∑ b ∈ S.image g, prob S (pairObs f g) (a, b) = prob S f a := by
  unfold prob
  rw [← Finset.sum_div]
  congr 1
  have hmaps : Set.MapsTo g (fiber S f a : Set Ω) (S.image g : Set β) := by
    intro w hw
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe]
    exact ⟨w, fiber_subset (by exact_mod_cast hw), rfl⟩
  have := Finset.card_eq_sum_card_fiberwise hmaps
  rw [this]
  push_cast
  exact Finset.sum_congr rfl (fun b _ => by rw [fiber_pair_eq])

lemma sum_prob_pair_left (b : β) :
    ∑ a ∈ S.image f, prob S (pairObs f g) (a, b) = prob S g b := by
  have hfibswap : ∀ a, fiber S (pairObs f g) (a, b) = fiber S (pairObs g f) (b, a) := by
    intro a
    unfold fiber pairObs
    refine Finset.filter_congr (fun w _ => ?_)
    constructor
    · intro hh; rw [Prod.ext_iff] at hh ⊢; exact ⟨hh.2, hh.1⟩
    · intro hh; rw [Prod.ext_iff] at hh ⊢; exact ⟨hh.2, hh.1⟩
  have hswap : ∀ a, prob S (pairObs f g) (a, b) = prob S (pairObs g f) (b, a) := by
    intro a; unfold prob; rw [hfibswap a]
  simp_rw [hswap]
  exact sum_prob_pair_right (f := g) (g := f) b

private lemma neg_mul_logb_mono {p q : ℝ} (hp : 0 ≤ p) (hq : 0 < q) (hpq : p ≤ q) :
    -(p * logb 2 q) ≤ -(p * logb 2 p) := by
  rcases eq_or_lt_of_le hp with h | h
  · simp [← h]
  · have hle : logb 2 p ≤ logb 2 q := (Real.logb_le_logb (by norm_num) h hq).mpr hpq
    nlinarith

lemma prob_pair_le_left (a : α) (b : β) : prob S (pairObs f g) (a, b) ≤ prob S f a := by
  have hle : ((fiber S (pairObs f g) (a, b)).card : ℝ) ≤ ((fiber S f a).card : ℝ) := by
    exact_mod_cast Finset.card_le_card
      (by rw [fiber_pair_eq]; exact Finset.filter_subset _ _)
  unfold prob
  rw [div_eq_mul_inv, div_eq_mul_inv]
  exact mul_le_mul_of_nonneg_right hle (by positivity)

/-- Conditioning cannot increase entropy below the marginal: `H(f,g) ≥ H(f)`. -/
lemma entropy_le_entropy_pair_left : entropy S f ≤ entropy S (pairObs f g) := by
  rw [entropy_eq_sum_of_subset (image_pairObs_subset (f := f) (g := g)),
    Finset.sum_product]
  rw [entropy]
  refine Finset.sum_le_sum (fun a ha => ?_)
  have hpa : 0 < prob S f a := prob_pos_of_mem ha
  have hterm : ∀ b ∈ S.image g,
      -(prob S (pairObs f g) (a, b) * logb 2 (prob S f a))
        ≤ -(prob S (pairObs f g) (a, b) * logb 2 (prob S (pairObs f g) (a, b))) := by
    intro b _
    exact neg_mul_logb_mono (prob_nonneg _ _ _) hpa (prob_pair_le_left a b)
  calc -(prob S f a * logb 2 (prob S f a))
      = ∑ b ∈ S.image g, -(prob S (pairObs f g) (a, b) * logb 2 (prob S f a)) := by
        have h1 : ∀ b : β, -(prob S (pairObs f g) (a, b) * logb 2 (prob S f a))
            = (-(logb 2 (prob S f a))) * prob S (pairObs f g) (a, b) := by
          intro b; ring
        simp_rw [h1]
        rw [← Finset.mul_sum, sum_prob_pair_right]
        ring
    _ ≤ ∑ b ∈ S.image g, -(prob S (pairObs f g) (a, b) *
          logb 2 (prob S (pairObs f g) (a, b))) := Finset.sum_le_sum hterm

lemma entropy_pair_swap : entropy S (pairObs f g) = entropy S (pairObs g f) := by
  have : (fun w => Prod.swap (pairObs g f w)) = pairObs f g := rfl
  rw [← this]
  exact entropy_comp_of_injOn (fun x _ y _ hxy => Prod.swap_injective hxy)

lemma entropy_le_entropy_pair_right : entropy S g ≤ entropy S (pairObs f g) := by
  rw [entropy_pair_swap]
  exact entropy_le_entropy_pair_left

lemma condEntropy_nonneg (S : Finset Ω) (g : Ω → β) (f : Ω → α) :
    0 ≤ condEntropy S g f :=
  sub_nonneg.mpr entropy_le_entropy_pair_left

lemma mutualInfo_eq_sub_condEntropy (S : Finset Ω) (f : Ω → α) (g : Ω → β) :
    mutualInfo S f g = entropy S g - condEntropy S g f := by
  unfold mutualInfo condEntropy; ring

/-- **The cap.**  A channel never carries more than the entropy of its input readout. -/
lemma mutualInfo_le_left (S : Finset Ω) (f : Ω → α) (g : Ω → β) :
    mutualInfo S f g ≤ entropy S f := by
  have := entropy_le_entropy_pair_right (S := S) (f := f) (g := g)
  unfold mutualInfo; linarith

lemma mutualInfo_le_right (S : Finset Ω) (f : Ω → α) (g : Ω → β) :
    mutualInfo S f g ≤ entropy S g := by
  have := entropy_le_entropy_pair_left (S := S) (f := f) (g := g)
  unfold mutualInfo; linarith

lemma mutualInfo_comm (S : Finset Ω) (f : Ω → α) (g : Ω → β) :
    mutualInfo S f g = mutualInfo S g f := by
  unfold mutualInfo
  rw [entropy_pair_swap]
  ring

/-- The pointwise form of Gibbs' inequality, from `log x ≤ x - 1`. -/
private lemma gibbs_pointwise {p u v : ℝ} (hp : 0 ≤ p) (hu : 0 < u) (hv : 0 < v) :
    -(p * logb 2 p - p * logb 2 u - p * logb 2 v) ≤ (u * v - p) / Real.log 2 := by
  have hL : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rcases eq_or_lt_of_le hp with h | hppos
  · have huv : 0 ≤ u * v := by positivity
    simp only [← h]
    simp only [zero_mul, sub_zero, sub_self, neg_zero]
    positivity
  · have hlog : Real.log (u * v / p) ≤ u * v / p - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    have huvp : Real.log (u * v / p) = Real.log u + Real.log v - Real.log p := by
      rw [Real.log_div (by positivity) (ne_of_gt hppos),
        Real.log_mul (ne_of_gt hu) (ne_of_gt hv)]
    rw [huvp] at hlog
    have h3 : u * v / p - 1 = (u * v - p) / p := by field_simp
    rw [h3] at hlog
    have hmul : p * (Real.log u + Real.log v - Real.log p) ≤ u * v - p := by
      have h4 := mul_le_mul_of_nonneg_left hlog (le_of_lt hppos)
      have h5 : p * ((u * v - p) / p) = u * v - p := by field_simp
      rwa [h5] at h4
    have hLHS : -(p * logb 2 p - p * logb 2 u - p * logb 2 v)
        = (p * (Real.log u + Real.log v - Real.log p)) / Real.log 2 := by
      simp only [Real.logb]
      field_simp
      ring
    rw [hLHS]
    gcongr

/-- **Gibbs.** Mutual information is nonnegative. -/
lemma mutualInfo_nonneg (hS : S.Nonempty) (f : Ω → α) (g : Ω → β) :
    0 ≤ mutualInfo S f g := by
  have hL : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  set D := S.image f ×ˢ S.image g with hD
  set P : α × β → ℝ := fun x => prob S (pairObs f g) x with hP
  have hHp : entropy S (pairObs f g) = ∑ x ∈ D, -(P x * logb 2 (P x)) :=
    entropy_eq_sum_of_subset image_pairObs_subset
  have hHf : entropy S f = ∑ x ∈ D, -(P x * logb 2 (prob S f x.1)) := by
    rw [entropy, hD, Finset.sum_product]
    refine Finset.sum_congr rfl (fun a _ => ?_)
    have h1 : ∀ b : β, -(P (a, b) * logb 2 (prob S f a))
        = (-(logb 2 (prob S f a))) * P (a, b) := fun b => by ring
    simp_rw [h1]
    rw [← Finset.mul_sum, hP, sum_prob_pair_right]
    ring
  have hHg : entropy S g = ∑ x ∈ D, -(P x * logb 2 (prob S g x.2)) := by
    rw [entropy, hD, Finset.sum_product_right]
    refine Finset.sum_congr rfl (fun b _ => ?_)
    have h1 : ∀ a : α, -(P (a, b) * logb 2 (prob S g b))
        = (-(logb 2 (prob S g b))) * P (a, b) := fun a => by ring
    simp_rw [h1]
    rw [← Finset.mul_sum, hP, sum_prob_pair_left]
    ring
  have hsumP : ∑ x ∈ D, P x = 1 := sum_prob_of_subset hS image_pairObs_subset
  have hsumQ : ∑ x ∈ D, prob S f x.1 * prob S g x.2 = 1 := by
    rw [hD, Finset.sum_product]
    simp_rw [← Finset.mul_sum]
    rw [sum_prob (f := g) hS]
    simp_rw [mul_one]
    exact sum_prob (f := f) hS
  have hbound : ∀ x ∈ D,
      -(P x * logb 2 (P x) - P x * logb 2 (prob S f x.1) - P x * logb 2 (prob S g x.2))
        ≤ (prob S f x.1 * prob S g x.2 - P x) / Real.log 2 := by
    intro x hx
    rw [hD, Finset.mem_product] at hx
    exact gibbs_pointwise (prob_nonneg _ _ _) (prob_pos_of_mem hx.1) (prob_pos_of_mem hx.2)
  have hsum_bound : ∑ x ∈ D,
      -(P x * logb 2 (P x) - P x * logb 2 (prob S f x.1) - P x * logb 2 (prob S g x.2)) ≤ 0 := by
    calc ∑ x ∈ D, -(P x * logb 2 (P x) - P x * logb 2 (prob S f x.1)
            - P x * logb 2 (prob S g x.2))
        ≤ ∑ x ∈ D, (prob S f x.1 * prob S g x.2 - P x) / Real.log 2 :=
          Finset.sum_le_sum hbound
      _ = 0 := by
          rw [← Finset.sum_div, Finset.sum_sub_distrib, hsumP, hsumQ]
          simp
  have hrw : mutualInfo S f g
      = ∑ x ∈ D, (P x * logb 2 (P x) - P x * logb 2 (prob S f x.1)
          - P x * logb 2 (prob S g x.2)) := by
    rw [mutualInfo, hHf, hHg, hHp]
    rw [← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun x _ => by ring)
  rw [hrw]
  have hneg : ∑ x ∈ D, -(P x * logb 2 (P x) - P x * logb 2 (prob S f x.1)
      - P x * logb 2 (prob S g x.2))
      = -∑ x ∈ D, (P x * logb 2 (P x) - P x * logb 2 (prob S f x.1)
          - P x * logb 2 (prob S g x.2)) := by
    rw [← Finset.sum_neg_distrib]
  rw [hneg] at hsum_bound
  linarith

/-- A constant readout carries no information. -/
lemma mutualInfo_eq_zero_of_const {a : α} (h : ∀ w ∈ S, f w = a) :
    mutualInfo S f g = 0 := by
  have h1 : entropy S f = 0 := by
    rw [entropy_congr h]; exact entropy_const S a
  have h2 : entropy S (pairObs f g) = entropy S g := by
    have hc : ∀ w ∈ S, pairObs f g w = (a, g w) := by
      intro w hw; unfold pairObs; rw [h w hw]
    rw [entropy_congr hc]
    exact entropy_comp_of_injOn (φ := fun b => (a, b))
      (fun x _ y _ hxy => by simpa using congrArg Prod.snd hxy)
  unfold mutualInfo
  rw [h1, h2]; ring

/-- **Completeness.** If the readout `f` is a function of the readout `g`, then the
channel between them carries all of `H(f)`. -/
lemma mutualInfo_eq_left_of_factors {φ : β → α} (h : ∀ w ∈ S, f w = φ (g w)) :
    mutualInfo S f g = entropy S f := by
  have h2 : entropy S (pairObs f g) = entropy S g := by
    have hc : ∀ w ∈ S, pairObs f g w = (φ (g w), g w) := by
      intro w hw; unfold pairObs; rw [h w hw]
    rw [entropy_congr hc]
    exact entropy_comp_of_injOn (φ := fun b => (φ b, b))
      (fun x _ y _ hxy => by simpa using congrArg Prod.snd hxy)
  unfold mutualInfo
  rw [h2]; ring

/-- Relabelling the first readout injectively does not change the channel. -/
lemma mutualInfo_comp_left {γ : Type*} [DecidableEq γ] {φ : α → γ}
    (h : Set.InjOn φ (S.image f : Finset α)) :
    mutualInfo S (fun w => φ (f w)) g = mutualInfo S f g := by
  have h1 : entropy S (fun w => φ (f w)) = entropy S f := entropy_comp_of_injOn h
  have h2 : entropy S (pairObs (fun w => φ (f w)) g) = entropy S (pairObs f g) := by
    have : (fun w => (Prod.map φ id) (pairObs f g w)) = pairObs (fun w => φ (f w)) g := rfl
    rw [← this]
    refine entropy_comp_of_injOn ?_
    intro x hx y hy hxy
    have hx' : x.1 ∈ S.image f := by
      have := image_pairObs_subset (f := f) (g := g) (Finset.mem_coe.mp hx)
      exact (mem_product.mp this).1
    have hy' : y.1 ∈ S.image f := by
      have := image_pairObs_subset (f := f) (g := g) (Finset.mem_coe.mp hy)
      exact (mem_product.mp this).1
    have h1' : φ x.1 = φ y.1 := by simpa using congrArg Prod.fst hxy
    have h2' : x.2 = y.2 := by simpa using congrArg Prod.snd hxy
    exact Prod.ext (h (Finset.mem_coe.mpr hx') (Finset.mem_coe.mpr hy') h1') h2'
  unfold mutualInfo
  rw [h1, h2]

end Joint

section Evaluation

variable {S : Finset Ω} {f : Ω → α}

/-- Evaluation interface: entropy from an explicit list of values and fibre counts. -/
lemma entropy_eq_sumList {A : List α} {L : List ℕ} (hnd : A.Nodup)
    (hcov : ∀ w ∈ S, f w ∈ A)
    (hc : A.map (fun a => (fiber S f a).card) = L) :
    entropy S f =
      (L.map (fun c : ℕ => -(((c : ℝ) / S.card) * logb 2 ((c : ℝ) / S.card)))).sum := by
  have hsub : S.image f ⊆ A.toFinset := by
    intro a ha
    obtain ⟨w, hw, rfl⟩ := mem_image.mp ha
    exact List.mem_toFinset.mpr (hcov w hw)
  rw [entropy_eq_sum_of_subset hsub, List.sum_toFinset _ hnd, ← hc, List.map_map]
  rfl

end Evaluation

end TypeChannel