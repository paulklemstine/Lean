import Cryptography.NonabelianTypeChannel.Completeness

/-!
# Information calculus for the consolidated type-channel law (paper 116)

This file extends the finite Shannon calculus of `Cryptography.NonabelianTypeChannel.Entropy`
with the four tools the milestone needs and which the catalog did not yet contain:

* `entropy_comp_le` — **data processing for entropy**: a function of a readout carries no
  more entropy than the readout itself.
* `entropy_image_of_injOn`, `mutualInfo_image_of_injOn` — **transport**: an injective
  re-indexing of the sample space does not change any entropy or channel.
* `mutualInfo_congr_partition` — a channel depends only on the *partition* induced by the
  first readout, not on its labels.
* `entropy_pair_chain` — **the chain rule** `H(X, t) = H(t) + ∑_b p(b) H(X | t = b)`, and
  its consequence `mutualInfo_pair_chain`, the chain rule for batteries
  `I(c ; (T₁, T₂)) = I(c ; T₁) + I(c ; T₂ | T₁)` with `condMutualInfo_nonneg`.
-/

namespace TypeChannel

open Finset Real

variable {Ω α β γ : Type*} [DecidableEq α] [DecidableEq β] [DecidableEq γ]

section DataProcessing

variable {S : Finset Ω} {f : Ω → α}

/-- **Data processing for entropy.**  Post-processing a readout never increases entropy. -/
theorem entropy_comp_le (φ : α → β) :
    entropy S (fun w => φ (f w)) ≤ entropy S f := by
  have h1 : entropy S (fun w => φ (f w)) ≤ entropy S (pairObs (fun w => φ (f w)) f) :=
    entropy_le_entropy_pair_left
  have h2 : entropy S (pairObs (fun w => φ (f w)) f) = entropy S f := by
    have : pairObs (fun w => φ (f w)) f = fun w => (fun a => (φ a, a)) (f w) := rfl
    rw [this]
    exact entropy_comp_of_injOn (f := f) (φ := fun a => (φ a, a))
      (fun x _ y _ hxy => congrArg Prod.snd hxy)
  linarith

/-- The identity readout of a uniform sample space carries `log₂ |S|` bits. -/
theorem entropy_id_eq_logb_card [DecidableEq Ω] (hS : S.Nonempty) :
    entropy S (fun w => w) = logb 2 S.card := by
  rw [entropy_eq_logb_card_of_uniform_fibers (k := 1) hS one_pos]
  · simp
  · intro a ha
    obtain ⟨w, hw, rfl⟩ := mem_image.mp ha
    rw [Finset.card_eq_one]
    refine ⟨w, ?_⟩
    ext x
    simp only [fiber, mem_filter, mem_singleton]
    constructor
    · rintro ⟨_, h⟩; exact h
    · rintro rfl; exact ⟨hw, rfl⟩

/-- Every readout on a uniform sample space carries at most `log₂ |S|` bits. -/
theorem entropy_le_logb_card [DecidableEq Ω] (hS : S.Nonempty) (f : Ω → α) :
    entropy S f ≤ logb 2 S.card := by
  rw [← entropy_id_eq_logb_card hS]
  exact entropy_comp_le (S := S) (f := fun w => w) f

end DataProcessing

section Transport

variable {Ω' : Type*} [DecidableEq Ω'] {S : Finset Ω}

/-- **Transport of entropy.**  Re-indexing the sample space injectively preserves entropy. -/
theorem entropy_image_of_injOn {e : Ω → Ω'} (he : Set.InjOn e S) (f : Ω' → α) :
    entropy (S.image e) f = entropy S (fun w => f (e w)) := by
  have himg : (S.image e).image f = S.image (fun w => f (e w)) := by
    rw [Finset.image_image]; rfl
  have hcard : (S.image e).card = S.card := Finset.card_image_of_injOn he
  have hfib : ∀ a, (fiber (S.image e) f a).card = (fiber S (fun w => f (e w)) a).card := by
    intro a
    have : fiber (S.image e) f a = (fiber S (fun w => f (e w)) a).image e := by
      unfold fiber
      rw [Finset.filter_image]
    rw [this]
    exact Finset.card_image_of_injOn (fun x hx y hy hxy =>
      he (Finset.mem_coe.mpr (fiber_subset (Finset.mem_coe.mp hx)))
        (Finset.mem_coe.mpr (fiber_subset (Finset.mem_coe.mp hy))) hxy)
  unfold entropy prob
  rw [himg]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [hfib a, hcard]

/-- **Transport of channels.**  Re-indexing the sample space injectively preserves every
mutual information. -/
theorem mutualInfo_image_of_injOn {e : Ω → Ω'} (he : Set.InjOn e S) (f : Ω' → α)
    (g : Ω' → β) :
    mutualInfo (S.image e) f g = mutualInfo S (fun w => f (e w)) (fun w => g (e w)) := by
  unfold mutualInfo
  rw [entropy_image_of_injOn he f, entropy_image_of_injOn he g,
    entropy_image_of_injOn he (pairObs f g)]
  rfl

/-- Channels only see the readouts on the sample space. -/
theorem mutualInfo_congr {f f' : Ω → α} {g g' : Ω → β} (hf : ∀ w ∈ S, f w = f' w)
    (hg : ∀ w ∈ S, g w = g' w) : mutualInfo S f g = mutualInfo S f' g' := by
  unfold mutualInfo
  rw [entropy_congr hf, entropy_congr hg,
    entropy_congr (f := pairObs f g) (f' := pairObs f' g')
      (fun w hw => by unfold pairObs; rw [hf w hw, hg w hw])]

end Transport

section Partition

variable {S : Finset Ω}

/-- **Channels see partitions, not labels.**  Two readouts that induce the same partition
of the sample space have the same channel to every second readout. -/
theorem mutualInfo_congr_partition {c : Ω → α} {c' : Ω → γ} (g : Ω → β)
    (h : ∀ a ∈ S, ∀ b ∈ S, (c a = c b ↔ c' a = c' b)) :
    mutualInfo S c' g = mutualInfo S c g := by
  rcases S.eq_empty_or_nonempty with hS | ⟨w₀, hw₀⟩
  · subst hS; simp [mutualInfo, entropy]
  haveI : Nonempty Ω := ⟨w₀⟩
  classical
  set ψ : α → γ := fun k => c' (Function.invFunOn c (S : Set Ω) k) with hψ
  have hex : ∀ w ∈ S, ∃ a ∈ (S : Set Ω), c a = c w := fun w hw => ⟨w, hw, rfl⟩
  have hR : ∀ w ∈ S, c' w = ψ (c w) := by
    intro w hw
    have hmem := Function.invFunOn_mem (hex w hw)
    have heq := Function.invFunOn_eq (hex w hw)
    exact ((h _ hmem w hw).mp heq).symm
  have hinj : Set.InjOn ψ (S.image c : Finset α) := by
    intro x hx y hy hxy
    obtain ⟨a, ha, rfl⟩ := mem_image.mp (Finset.mem_coe.mp hx)
    obtain ⟨b, hb, rfl⟩ := mem_image.mp (Finset.mem_coe.mp hy)
    rw [← hR a ha, ← hR b hb] at hxy
    exact (h a ha b hb).mpr hxy
  exact residue_channel_eq_coset_channel S c g hR hinj

end Partition

section Chain

variable {S : Finset Ω} {X : Ω → α} {t : Ω → β}

/-- The joint law factors through the conditional law on a fibre. -/
lemma prob_pair_eq_mul {a : α} {b : β} (hb : b ∈ S.image t) :
    prob S (pairObs X t) (a, b) = prob S t b * prob (fiber S t b) X a := by
  have hfib : fiber S (pairObs X t) (a, b) = fiber (fiber S t b) X a := by
    ext w
    simp only [fiber, pairObs, mem_filter, Prod.mk.injEq]
    tauto
  obtain ⟨w, hw, rfl⟩ := mem_image.mp hb
  have hpos : 0 < (fiber S t (t w)).card :=
    Finset.card_pos.mpr ⟨w, mem_filter.mpr ⟨hw, rfl⟩⟩
  have hS : (S.card : ℝ) ≠ 0 := by
    have : 0 < S.card := Finset.card_pos.mpr ⟨w, hw⟩
    exact_mod_cast this.ne'
  unfold prob
  rw [hfib]
  have : ((fiber S t (t w)).card : ℝ) ≠ 0 := by exact_mod_cast hpos.ne'
  field_simp

/-- **The chain rule.**  `H(X, t) = H(t) + ∑_b p(t = b) · H(X | t = b)`. -/
theorem entropy_pair_chain (X : Ω → α) (t : Ω → β) :
    entropy S (pairObs X t) =
      entropy S t + ∑ b ∈ S.image t, prob S t b * entropy (fiber S t b) X := by
  rw [entropy_eq_sum_of_subset (image_pairObs_subset (S := S) (f := X) (g := t)),
    Finset.sum_product_right, entropy, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun b hb => ?_)
  obtain ⟨w, hw, hwb⟩ := mem_image.mp hb
  have hne : (fiber S t b).Nonempty := ⟨w, mem_filter.mpr ⟨hw, hwb⟩⟩
  have hsub : (fiber S t b).image X ⊆ S.image X :=
    Finset.image_subset_image fiber_subset
  have hp : 0 < prob S t b := prob_pos_of_mem hb
  rw [entropy_eq_sum_of_subset hsub, Finset.mul_sum]
  have hterm : ∀ a ∈ S.image X,
      -(prob S (pairObs X t) (a, b) * logb 2 (prob S (pairObs X t) (a, b)))
        = -(prob S t b * logb 2 (prob S t b)) * prob (fiber S t b) X a
          + prob S t b * -(prob (fiber S t b) X a * logb 2 (prob (fiber S t b) X a)) := by
    intro a _
    rw [prob_pair_eq_mul hb]
    rcases eq_or_lt_of_le (prob_nonneg (fiber S t b) X a) with hq | hq
    · rw [← hq]; ring
    · rw [Real.logb_mul hp.ne' hq.ne']; ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.mul_sum,
    sum_prob_of_subset hne hsub, mul_one]

/-- Conditional mutual information `I(f ; g | t) = ∑_b p(t = b) · I(f ; g | t = b)`. -/
noncomputable def condMutualInfo (S : Finset Ω) (f : Ω → α) (g : Ω → γ) (t : Ω → β) : ℝ :=
  ∑ b ∈ S.image t, prob S t b * mutualInfo (fiber S t b) f g

/-- Conditional mutual information is nonnegative (fibrewise Gibbs). -/
theorem condMutualInfo_nonneg (f : Ω → α) (g : Ω → γ) (t : Ω → β) :
    0 ≤ condMutualInfo S f g t := by
  refine Finset.sum_nonneg (fun b hb => ?_)
  obtain ⟨w, hw, hwb⟩ := mem_image.mp hb
  exact mul_nonneg (prob_nonneg _ _ _)
    (mutualInfo_nonneg ⟨w, mem_filter.mpr ⟨hw, hwb⟩⟩ f g)

/-- **Chain rule for batteries.**  Adding a second dial `T₂` to a dial `T₁` adds exactly the
conditional information `I(c ; T₂ | T₁)`:
`I(c ; (T₁, T₂)) = I(c ; T₁) + I(c ; T₂ | T₁)`. -/
theorem mutualInfo_pair_chain (c : Ω → α) (T₁ : Ω → β) (T₂ : Ω → γ) :
    mutualInfo S c (pairObs T₁ T₂) = mutualInfo S c T₁ + condMutualInfo S c T₂ T₁ := by
  have hA : entropy S (pairObs T₁ T₂) =
      entropy S T₁ + ∑ b ∈ S.image T₁, prob S T₁ b * entropy (fiber S T₁ b) T₂ := by
    rw [entropy_pair_swap]; exact entropy_pair_chain T₂ T₁
  have hB : entropy S (pairObs c (pairObs T₁ T₂)) =
      entropy S T₁ + ∑ b ∈ S.image T₁, prob S T₁ b *
        entropy (fiber S T₁ b) (pairObs c T₂) := by
    rw [← entropy_pair_chain (pairObs c T₂) T₁]
    have : pairObs (pairObs c T₂) T₁ =
        fun w => (fun x : α × β × γ => ((x.1, x.2.2), x.2.1)) (pairObs c (pairObs T₁ T₂) w) :=
      rfl
    rw [this]
    refine (entropy_comp_of_injOn (f := pairObs c (pairObs T₁ T₂))
      (φ := fun x : α × β × γ => ((x.1, x.2.2), x.2.1)) ?_).symm
    intro x _ y _ hxy
    simp only [Prod.mk.injEq] at hxy
    exact Prod.ext hxy.1.1 (Prod.ext hxy.2 hxy.1.2)
  have hC : entropy S (pairObs c T₁) =
      entropy S T₁ + ∑ b ∈ S.image T₁, prob S T₁ b * entropy (fiber S T₁ b) c :=
    entropy_pair_chain c T₁
  unfold condMutualInfo
  simp only [mutualInfo] at *
  rw [hA, hB, hC]
  simp only [mul_sub, mul_add, Finset.sum_sub_distrib, Finset.sum_add_distrib]
  ring

/-- **Batteries never lose information.**  `I(c ; T₁) ≤ I(c ; (T₁, T₂))`. -/
theorem mutualInfo_le_pair (c : Ω → α) (T₁ : Ω → β) (T₂ : Ω → γ) :
    mutualInfo S c T₁ ≤ mutualInfo S c (pairObs T₁ T₂) := by
  rw [mutualInfo_pair_chain]
  linarith [condMutualInfo_nonneg (S := S) c T₂ T₁]

end Chain

end TypeChannel