import Mathlib
import Shared.CyclicTypeChannelNonneg
import Probability.D5TypeChannelCore

/-!
# The ramified type channel: fibre log-sums (FACT round-36 #1, paper 128)

Infrastructure for `RAMIFIED-CONTRIBUTION-IS-NEGLIGIBLE`.  We rewrite the counting
entropies of `Shared.CyclicTypeChannel` through the *fibre log-sum*
`Λ(s, g) = ∑_{a ∈ s} log₂ |g⁻¹(g a) ∩ s|`:

* `card_mul_mutInfo` — `N · I(g ; k) = N log₂ N - Λ(g) - Λ(k) + Λ(k, g)`;
* `lam_union_ge`, `lam_union_le` — for a disjoint union `U ∪ R` (unramified ∪ ramified),
  the *fibre defect* `Λ_{U∪R} - Λ_U - Λ_R` lies in `[0, |R| (log₂ N + 1 / log 2)]`.

The upper estimate uses the elementary `log(1 + x) ≤ x` on the unramified part, grouped
along the fibres of `g` (`sum_ratio_le`), and the trivial cap `log₂ N` on the ramified part.
-/

namespace Catalog.Probability.RamifiedTypeChannel

open Finset CyclicTypeChannel

variable {α β γ : Type*}

/-- The fibre log-sum `Λ(s, g) = ∑_{a ∈ s} log₂ |g⁻¹(g a) ∩ s|`. -/
noncomputable def lam [DecidableEq β] (s : Finset α) (g : α → β) : ℝ :=
  ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)

section Lam

variable [DecidableEq β] [DecidableEq γ]

lemma uEnt_eq_lam (s : Finset α) (g : α → β) :
    uEnt s g = Real.logb 2 s.card - lam s g / s.card := rfl

lemma lam_nonneg (s : Finset α) (g : α → β) : 0 ≤ lam s g := by
  refine Finset.sum_nonneg fun a ha => Real.logb_nonneg (by norm_num) ?_
  exact_mod_cast fiber_card_pos ha

/-- The fibre log-sum of a paired read-out, as a double sum over the joint count array. -/
lemma lam_pair (s : Finset α) (g : α → β) (k : α → γ) :
    lam s (fun x => (k x, g x)) = ∑ c ∈ s.image k, ∑ v ∈ s.image g,
      (#{x ∈ s | k x = c ∧ g x = v} : ℝ) * Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ) := by
  have hf : ∀ p : γ × β, #{x ∈ s | (k x, g x) = p} = #{x ∈ s | k x = p.1 ∧ g x = p.2} := by
    intro p
    congr 1
    exact Finset.filter_congr fun x _ => Prod.ext_iff
  rw [lam, sum_logb_fiber]
  simp only [hf]
  rw [← Finset.sum_product (f := fun p : γ × β =>
    (#{x ∈ s | k x = p.1 ∧ g x = p.2} : ℝ) * Real.logb 2 (#{x ∈ s | k x = p.1 ∧ g x = p.2} : ℝ))]
  refine Finset.sum_subset ?_ ?_
  · intro p hp
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hp
    exact mem_product.2 ⟨mem_image_of_mem k ha, mem_image_of_mem g ha⟩
  · intro p _ hp
    have hemp : {x ∈ s | k x = p.1 ∧ g x = p.2} = ∅ := by
      rw [Finset.filter_eq_empty_iff]
      intro x hx hxp
      exact hp (mem_image.2 ⟨x, hx, Prod.ext hxp.1 hxp.2⟩)
    rw [hemp]
    simp

lemma condEnt_eq_lam (s : Finset α) (g : α → β) (k : α → γ) :
    condEnt s g k = (lam s k - lam s (fun x => (k x, g x))) / s.card := by
  rw [condEnt_eq_joint, lam_pair, lam, sum_logb_fiber, sub_div, Finset.sum_div, Finset.sum_div,
    ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun c _ => ?_
  ring

lemma card_mul_mutInfo (s : Finset α) (g : α → β) (k : α → γ) :
    (s.card : ℝ) * mutInfo s g k = s.card * Real.logb 2 s.card - lam s g - lam s k
      + lam s (fun x => (k x, g x)) := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [lam]
  have hN : (s.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.2 hs).ne'
  rw [mutInfo, uEnt_eq_lam, condEnt_eq_lam]
  field_simp
  ring

lemma lam_union_ge [DecidableEq α] {U R : Finset α} (h : Disjoint U R) (g : α → β) :
    lam U g + lam R g ≤ lam (U ∪ R) g := by
  rw [lam, lam, lam, sum_union h]
  refine add_le_add (Finset.sum_le_sum fun a ha => ?_) (Finset.sum_le_sum fun a ha => ?_)
  · refine Real.logb_le_logb_of_le (by norm_num) (by exact_mod_cast fiber_card_pos ha) ?_
    exact_mod_cast card_le_card (filter_subset_filter _ subset_union_left)
  · refine Real.logb_le_logb_of_le (by norm_num) (by exact_mod_cast fiber_card_pos ha) ?_
    exact_mod_cast card_le_card (filter_subset_filter _ subset_union_right)

/-- Elementary estimate `log₂ (u + r) ≤ log₂ u + r / (u log 2)`. -/
lemma logb_add_le {u r : ℝ} (hu : 0 < u) (hr : 0 ≤ r) :
    Real.logb 2 (u + r) ≤ Real.logb 2 u + r / u / Real.log 2 := by
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hur : 0 < u + r := by linarith
  have key : Real.log (u + r) ≤ Real.log u + r / u := by
    have h1 := Real.log_le_sub_one_of_pos (div_pos hur hu)
    rw [Real.log_div hur.ne' hu.ne'] at h1
    have : (u + r) / u - 1 = r / u := by field_simp; ring
    linarith
  rw [Real.logb, Real.logb, ← add_div]
  exact div_le_div_of_nonneg_right key hl2.le

/-- Summing the ratio of the `R`-fibre to the `U`-fibre over `U` costs at most `|R|`. -/
lemma sum_ratio_le [DecidableEq α] (U R : Finset α) (g : α → β) :
    ∑ a ∈ U, (#{x ∈ R | g x = g a} : ℝ) / #{x ∈ U | g x = g a} ≤ R.card := by
  rw [Finset.sum_comp (fun v => (#{x ∈ R | g x = v} : ℝ) / #{x ∈ U | g x = v}) g]
  have h1 : ∑ v ∈ U.image g, #{a ∈ U | g a = v} •
      ((#{x ∈ R | g x = v} : ℝ) / #{x ∈ U | g x = v}) = ∑ v ∈ U.image g, (#{x ∈ R | g x = v} : ℝ) := by
    refine Finset.sum_congr rfl fun v hv => ?_
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hv
    have hpos : (0 : ℝ) < #{x ∈ U | g x = g a} := by exact_mod_cast fiber_card_pos ha
    rw [nsmul_eq_mul]
    field_simp
  rw [h1]
  have h2 : ∑ v ∈ U.image g, #{x ∈ R | g x = v} ≤ R.card := by
    rw [← Finset.card_biUnion]
    · exact card_le_card (Finset.biUnion_subset.2 fun v _ => filter_subset _ _)
    · intro v _ w _ hvw
      exact Finset.disjoint_filter.2 fun x _ h1 h2 => hvw (h1.symm.trans h2)
  exact_mod_cast h2

lemma lam_union_le [DecidableEq α] {U R : Finset α} (h : Disjoint U R) (g : α → β) :
    lam (U ∪ R) g ≤ lam U g + lam R g
      + R.card * (Real.logb 2 (U ∪ R).card + 1 / Real.log 2) := by
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  rw [lam, lam, lam, sum_union h]
  -- unramified part
  have hU : ∑ a ∈ U, Real.logb 2 (#{x ∈ U ∪ R | g x = g a} : ℝ)
      ≤ ∑ a ∈ U, Real.logb 2 (#{x ∈ U | g x = g a} : ℝ) + R.card / Real.log 2 := by
    have hpt : ∀ a ∈ U, Real.logb 2 (#{x ∈ U ∪ R | g x = g a} : ℝ)
        ≤ Real.logb 2 (#{x ∈ U | g x = g a} : ℝ)
          + ((#{x ∈ R | g x = g a} : ℝ) / #{x ∈ U | g x = g a}) / Real.log 2 := by
      intro a ha
      have hc : #{x ∈ U ∪ R | g x = g a} = #{x ∈ U | g x = g a} + #{x ∈ R | g x = g a} := by
        rw [filter_union, card_union_of_disjoint (disjoint_filter_filter h)]
      rw [hc, Nat.cast_add]
      exact logb_add_le (by exact_mod_cast fiber_card_pos ha) (by positivity)
    refine (Finset.sum_le_sum hpt).trans ?_
    rw [Finset.sum_add_distrib, ← Finset.sum_div]
    gcongr
    exact sum_ratio_le U R g
  -- ramified part
  have hR : ∑ a ∈ R, Real.logb 2 (#{x ∈ U ∪ R | g x = g a} : ℝ)
      ≤ ∑ a ∈ R, Real.logb 2 (#{x ∈ R | g x = g a} : ℝ)
        + R.card * Real.logb 2 (U ∪ R).card := by
    have hpt : ∀ a ∈ R, Real.logb 2 (#{x ∈ U ∪ R | g x = g a} : ℝ)
        ≤ Real.logb 2 (#{x ∈ R | g x = g a} : ℝ) + Real.logb 2 (U ∪ R).card := by
      intro a ha
      have h1 : 0 ≤ Real.logb 2 (#{x ∈ R | g x = g a} : ℝ) :=
        Real.logb_nonneg (by norm_num) (by exact_mod_cast fiber_card_pos ha)
      have h2 : Real.logb 2 (#{x ∈ U ∪ R | g x = g a} : ℝ) ≤ Real.logb 2 (U ∪ R).card :=
        Real.logb_le_logb_of_le (by norm_num)
          (by exact_mod_cast fiber_card_pos (mem_union_right U ha))
          (by exact_mod_cast card_filter_le _ _)
      linarith
    refine (Finset.sum_le_sum hpt).trans ?_
    rw [Finset.sum_add_distrib, sum_const, nsmul_eq_mul]
  have : (R.card : ℝ) * (Real.logb 2 (U ∪ R).card + 1 / Real.log 2)
      = R.card * Real.logb 2 (U ∪ R).card + R.card / Real.log 2 := by ring
  linarith

end Lam

end Catalog.Probability.RamifiedTypeChannel