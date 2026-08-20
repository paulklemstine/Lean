/-
# Additivity of the counting channel over independent products

The exact values of the cyclic type-pair channel obey an unexpected law:
for coprime cyclic orders the information is *additive*,
`I_pair (m * n) = I_pair m + I_pair n`.

This file proves the structural reason.  In the counting-entropy framework of
`Shared.CyclicTypeChannel` we show that entropy, conditional entropy and mutual
information are **exactly additive over cartesian products** of the underlying
sample sets when both the read-out and the conditioning variable act
coordinatewise.  Together with the transport lemmas (invariance of the channel
under a relabelling of the sample set and under an injective recoding of the
read-out) this turns the Chinese Remainder Theorem into an additivity law for
the splitting-type channel.
-/
import Catalog.Shared.CyclicTypeChannel

namespace CyclicTypeChannel

open Finset

variable {α α' β β' γ γ' : Type*}

/-! ## 1. Fibres of a coordinatewise read-out -/

section Product

variable {α₁ α₂ β₁ β₂ γ₁ γ₂ : Type*}

/-- The fibre of a coordinatewise read-out over a product set is the product of
the two fibres. -/
lemma filter_prod_eq [DecidableEq β₁] [DecidableEq β₂]
    (s₁ : Finset α₁) (s₂ : Finset α₂) (g₁ : α₁ → β₁) (g₂ : α₂ → β₂) (v₁ : β₁) (v₂ : β₂) :
    {x ∈ s₁ ×ˢ s₂ | (g₁ x.1, g₂ x.2) = (v₁, v₂)}
      = {x ∈ s₁ | g₁ x = v₁} ×ˢ {x ∈ s₂ | g₂ x = v₂} := by
  ext ⟨u, v⟩
  simp only [mem_filter, mem_product, Prod.mk.injEq]
  tauto

lemma card_filter_prod [DecidableEq β₁] [DecidableEq β₂]
    (s₁ : Finset α₁) (s₂ : Finset α₂) (g₁ : α₁ → β₁) (g₂ : α₂ → β₂) (v₁ : β₁) (v₂ : β₂) :
    (#{x ∈ s₁ ×ˢ s₂ | (g₁ x.1, g₂ x.2) = (v₁, v₂)})
      = (#{x ∈ s₁ | g₁ x = v₁}) * (#{x ∈ s₂ | g₂ x = v₂}) := by
  rw [filter_prod_eq, card_product]

/-- **Additivity of entropy over independent products.** -/
theorem uEnt_prod [DecidableEq β₁] [DecidableEq β₂] {s₁ : Finset α₁} {s₂ : Finset α₂}
    (h₁ : s₁.Nonempty) (h₂ : s₂.Nonempty) (g₁ : α₁ → β₁) (g₂ : α₂ → β₂) :
    uEnt (s₁ ×ˢ s₂) (fun x => (g₁ x.1, g₂ x.2)) = uEnt s₁ g₁ + uEnt s₂ g₂ := by
  classical
  have hc₁ : (0 : ℝ) < s₁.card := by exact_mod_cast card_pos.2 h₁
  have hc₂ : (0 : ℝ) < s₂.card := by exact_mod_cast card_pos.2 h₂
  have hsum : ∑ x ∈ s₁ ×ˢ s₂,
        Real.logb 2 (#{y ∈ s₁ ×ˢ s₂ | (g₁ y.1, g₂ y.2) = (g₁ x.1, g₂ x.2)} : ℝ)
      = (s₂.card : ℝ) * (∑ a ∈ s₁, Real.logb 2 (#{x ∈ s₁ | g₁ x = g₁ a} : ℝ))
        + (s₁.card : ℝ) * (∑ b ∈ s₂, Real.logb 2 (#{x ∈ s₂ | g₂ x = g₂ b} : ℝ)) := by
    rw [Finset.sum_product]
    have hterm : ∀ a ∈ s₁, ∑ b ∈ s₂,
        Real.logb 2 (#{y ∈ s₁ ×ˢ s₂ | (g₁ y.1, g₂ y.2) = (g₁ a, g₂ b)} : ℝ)
        = (s₂.card : ℝ) * Real.logb 2 (#{x ∈ s₁ | g₁ x = g₁ a} : ℝ)
          + ∑ b ∈ s₂, Real.logb 2 (#{x ∈ s₂ | g₂ x = g₂ b} : ℝ) := by
      intro a ha
      have : ∀ b ∈ s₂,
          Real.logb 2 (#{y ∈ s₁ ×ˢ s₂ | (g₁ y.1, g₂ y.2) = (g₁ a, g₂ b)} : ℝ)
          = Real.logb 2 (#{x ∈ s₁ | g₁ x = g₁ a} : ℝ)
            + Real.logb 2 (#{x ∈ s₂ | g₂ x = g₂ b} : ℝ) := by
        intro b hb
        have hp₁ : (0 : ℝ) < (#{x ∈ s₁ | g₁ x = g₁ a} : ℝ) := by
          exact_mod_cast fiber_card_pos ha
        have hp₂ : (0 : ℝ) < (#{x ∈ s₂ | g₂ x = g₂ b} : ℝ) := by
          exact_mod_cast fiber_card_pos hb
        rw [show ((#{y ∈ s₁ ×ˢ s₂ | (g₁ y.1, g₂ y.2) = (g₁ a, g₂ b)} : ℕ) : ℝ)
            = ((#{x ∈ s₁ | g₁ x = g₁ a} : ℕ) : ℝ) * ((#{x ∈ s₂ | g₂ x = g₂ b} : ℕ) : ℝ) from by
          exact_mod_cast congrArg (Nat.cast (R := ℝ)) (card_filter_prod s₁ s₂ g₁ g₂ _ _),
          Real.logb_mul (ne_of_gt hp₁) (ne_of_gt hp₂)]
      rw [Finset.sum_congr rfl this, Finset.sum_add_distrib, Finset.sum_const, nsmul_eq_mul]
    rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.mul_sum,
      Finset.sum_const, nsmul_eq_mul]
  rw [uEnt, uEnt, uEnt, hsum, card_product]
  push_cast
  rw [Real.logb_mul (ne_of_gt hc₁) (ne_of_gt hc₂)]
  field_simp
  ring

/-- The image of a coordinatewise read-out over a product is the product of the
images. -/
lemma image_prod_eq [DecidableEq β₁] [DecidableEq β₂]
    (s₁ : Finset α₁) (s₂ : Finset α₂) (g₁ : α₁ → β₁) (g₂ : α₂ → β₂) :
    (s₁ ×ˢ s₂).image (fun x => (g₁ x.1, g₂ x.2)) = (s₁.image g₁) ×ˢ (s₂.image g₂) := by
  ext ⟨v₁, v₂⟩
  simp only [mem_image, mem_product, Prod.mk.injEq, Prod.exists]
  constructor
  · rintro ⟨a, b, ⟨ha, hb⟩, h1, h2⟩
    exact ⟨⟨a, ha, h1⟩, ⟨b, hb, h2⟩⟩
  · rintro ⟨⟨a, ha, h1⟩, b, hb, h2⟩
    exact ⟨a, b, ⟨ha, hb⟩, h1, h2⟩

/-- **Additivity of conditional entropy over independent products.** -/
theorem condEnt_prod [DecidableEq β₁] [DecidableEq β₂] [DecidableEq γ₁] [DecidableEq γ₂]
    {s₁ : Finset α₁} {s₂ : Finset α₂} (h₁ : s₁.Nonempty) (h₂ : s₂.Nonempty)
    (g₁ : α₁ → β₁) (g₂ : α₂ → β₂) (k₁ : α₁ → γ₁) (k₂ : α₂ → γ₂) :
    condEnt (s₁ ×ˢ s₂) (fun x => (g₁ x.1, g₂ x.2)) (fun x => (k₁ x.1, k₂ x.2))
      = condEnt s₁ g₁ k₁ + condEnt s₂ g₂ k₂ := by
  classical
  have hc₁ : (0 : ℝ) < s₁.card := by exact_mod_cast card_pos.2 h₁
  have hc₂ : (0 : ℝ) < s₂.card := by exact_mod_cast card_pos.2 h₂
  have hmass₁ : ∑ c ∈ s₁.image k₁, ((#{x ∈ s₁ | k₁ x = c} : ℝ) / s₁.card) = 1 := by
    rw [← Finset.sum_div]
    rw [show ∑ c ∈ s₁.image k₁, ((#{x ∈ s₁ | k₁ x = c} : ℕ) : ℝ) = (s₁.card : ℝ) from by
      exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s₁ k₁)]
    exact div_self (ne_of_gt hc₁)
  have hmass₂ : ∑ c ∈ s₂.image k₂, ((#{x ∈ s₂ | k₂ x = c} : ℝ) / s₂.card) = 1 := by
    rw [← Finset.sum_div]
    rw [show ∑ c ∈ s₂.image k₂, ((#{x ∈ s₂ | k₂ x = c} : ℕ) : ℝ) = (s₂.card : ℝ) from by
      exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s₂ k₂)]
    exact div_self (ne_of_gt hc₂)
  rw [condEnt, image_prod_eq, Finset.sum_product]
  have hterm : ∀ c₁ ∈ s₁.image k₁, ∑ c₂ ∈ s₂.image k₂,
      ((#{x ∈ s₁ ×ˢ s₂ | (k₁ x.1, k₂ x.2) = (c₁, c₂)} : ℝ) / ((s₁ ×ˢ s₂).card)) *
        uEnt {x ∈ s₁ ×ˢ s₂ | (k₁ x.1, k₂ x.2) = (c₁, c₂)} (fun x => (g₁ x.1, g₂ x.2))
      = ((#{x ∈ s₁ | k₁ x = c₁} : ℝ) / s₁.card) * uEnt {x ∈ s₁ | k₁ x = c₁} g₁
        + ((#{x ∈ s₁ | k₁ x = c₁} : ℝ) / s₁.card) * condEnt s₂ g₂ k₂ := by
    intro c₁ hc
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
    have hne₁ : ({x ∈ s₁ | k₁ x = k₁ a}).Nonempty := ⟨a, by simp [ha]⟩
    have hstep : ∀ c₂ ∈ s₂.image k₂,
        ((#{x ∈ s₁ ×ˢ s₂ | (k₁ x.1, k₂ x.2) = (k₁ a, c₂)} : ℝ) / ((s₁ ×ˢ s₂).card)) *
          uEnt {x ∈ s₁ ×ˢ s₂ | (k₁ x.1, k₂ x.2) = (k₁ a, c₂)} (fun x => (g₁ x.1, g₂ x.2))
        = ((#{x ∈ s₁ | k₁ x = k₁ a} : ℝ) / s₁.card) *
            (((#{x ∈ s₂ | k₂ x = c₂} : ℝ) / s₂.card) *
              (uEnt {x ∈ s₁ | k₁ x = k₁ a} g₁ + uEnt {x ∈ s₂ | k₂ x = c₂} g₂)) := by
      intro c₂ hc₂'
      obtain ⟨b, hb, rfl⟩ := mem_image.1 hc₂'
      have hne₂ : ({x ∈ s₂ | k₂ x = k₂ b}).Nonempty := ⟨b, by simp [hb]⟩
      rw [filter_prod_eq, uEnt_prod hne₁ hne₂, card_product, card_product]
      push_cast
      field_simp
    rw [Finset.sum_congr rfl hstep, ← Finset.mul_sum]
    have : ∑ c₂ ∈ s₂.image k₂, ((#{x ∈ s₂ | k₂ x = c₂} : ℝ) / s₂.card) *
        (uEnt {x ∈ s₁ | k₁ x = k₁ a} g₁ + uEnt {x ∈ s₂ | k₂ x = c₂} g₂)
        = uEnt {x ∈ s₁ | k₁ x = k₁ a} g₁ + condEnt s₂ g₂ k₂ := by
      rw [condEnt]
      have hexp : ∀ c₂ ∈ s₂.image k₂, ((#{x ∈ s₂ | k₂ x = c₂} : ℝ) / s₂.card) *
          (uEnt {x ∈ s₁ | k₁ x = k₁ a} g₁ + uEnt {x ∈ s₂ | k₂ x = c₂} g₂)
          = ((#{x ∈ s₂ | k₂ x = c₂} : ℝ) / s₂.card) * uEnt {x ∈ s₁ | k₁ x = k₁ a} g₁
            + ((#{x ∈ s₂ | k₂ x = c₂} : ℝ) / s₂.card) * uEnt {x ∈ s₂ | k₂ x = c₂} g₂ := by
        intro c₂ _; ring
      rw [Finset.sum_congr rfl hexp, Finset.sum_add_distrib, ← Finset.sum_mul, hmass₂, one_mul]
    rw [this]
    ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.sum_mul, hmass₁, one_mul]
  simp only [condEnt]

/-- **Additivity of the channel over independent products.**  If the read-out
and the conditioning variable both act coordinatewise on a product sample set,
the mutual information is the sum of the two component informations. -/
theorem mutInfo_prod [DecidableEq β₁] [DecidableEq β₂] [DecidableEq γ₁] [DecidableEq γ₂]
    {s₁ : Finset α₁} {s₂ : Finset α₂} (h₁ : s₁.Nonempty) (h₂ : s₂.Nonempty)
    (g₁ : α₁ → β₁) (g₂ : α₂ → β₂) (k₁ : α₁ → γ₁) (k₂ : α₂ → γ₂) :
    mutInfo (s₁ ×ˢ s₂) (fun x => (g₁ x.1, g₂ x.2)) (fun x => (k₁ x.1, k₂ x.2))
      = mutInfo s₁ g₁ k₁ + mutInfo s₂ g₂ k₂ := by
  rw [mutInfo, mutInfo, mutInfo, uEnt_prod h₁ h₂, condEnt_prod h₁ h₂]
  ring

end Product

/-! ## 2. Transport: relabelling the sample set and recoding the read-out -/

section Transport

variable [DecidableEq β] [DecidableEq γ]

/-- Entropy only depends on the values the read-out takes on the sample set. -/
theorem uEnt_congr {s : Finset α} {g g' : α → β} (h : ∀ a ∈ s, g a = g' a) :
    uEnt s g = uEnt s g' := by
  have hfil : ∀ a ∈ s, {x ∈ s | g x = g a} = {x ∈ s | g' x = g' a} := by
    intro a ha
    ext x
    simp only [mem_filter]
    constructor
    · rintro ⟨hx, hgx⟩; exact ⟨hx, by rw [← h x hx, ← h a ha, hgx]⟩
    · rintro ⟨hx, hgx⟩; exact ⟨hx, by rw [h x hx, h a ha, hgx]⟩
  rw [uEnt, uEnt]
  congr 1
  congr 1
  exact Finset.sum_congr rfl fun a ha => by rw [hfil a ha]

/-- Conditional entropy only depends on the values of the read-out on the
sample set. -/
theorem condEnt_congr {s : Finset α} {g g' : α → β} {k : α → γ} (h : ∀ a ∈ s, g a = g' a) :
    condEnt s g k = condEnt s g' k :=
  Finset.sum_congr rfl fun c _ => by
    rw [uEnt_congr (fun a ha => h a (mem_of_mem_filter a ha))]

/-- Conditional entropy only depends on the values of the conditioning variable
on the sample set. -/
theorem condEnt_congr_cond {s : Finset α} {g : α → β} {k k' : α → γ} (h : ∀ a ∈ s, k a = k' a) :
    condEnt s g k = condEnt s g k' := by
  have himg : s.image k = s.image k' := Finset.image_congr h
  rw [condEnt, condEnt, himg]
  refine Finset.sum_congr rfl fun c _ => ?_
  have : {x ∈ s | k x = c} = {x ∈ s | k' x = c} := by
    apply Finset.filter_congr
    intro x hx
    rw [h x hx]
  rw [this]

/-- The channel only depends on the values of the two variables on the sample
set. -/
theorem mutInfo_congr {s : Finset α} {g g' : α → β} {k k' : α → γ} (h : ∀ a ∈ s, g a = g' a)
    (h' : ∀ a ∈ s, k a = k' a) : mutInfo s g k = mutInfo s g' k' := by
  rw [mutInfo, mutInfo, uEnt_congr h, condEnt_congr h, condEnt_congr_cond h']

/-- Entropy only depends on the read-out through the partition it induces, so an
injective recoding of the values changes nothing. -/
theorem uEnt_comp_injOn [DecidableEq β'] {s : Finset α} {g : α → β} {f : β → β'}
    (hf : Set.InjOn f (g '' s)) : uEnt s (f ∘ g) = uEnt s g := by
  classical
  have hfib : ∀ a ∈ s, {x ∈ s | (f ∘ g) x = (f ∘ g) a} = {x ∈ s | g x = g a} := by
    intro a ha
    ext x
    simp only [mem_filter, Function.comp_apply]
    constructor
    · rintro ⟨hx, hfx⟩
      exact ⟨hx, hf ⟨x, hx, rfl⟩ ⟨a, ha, rfl⟩ hfx⟩
    · rintro ⟨hx, hgx⟩
      exact ⟨hx, by rw [hgx]⟩
  rw [uEnt, uEnt]
  congr 1
  congr 1
  exact Finset.sum_congr rfl fun a ha => by rw [hfib a ha]

/-- Conditional entropy is unchanged by an injective recoding of the read-out. -/
theorem condEnt_comp_injOn [DecidableEq β'] {s : Finset α} {g : α → β} {k : α → γ} {f : β → β'}
    (hf : Set.InjOn f (g '' s)) : condEnt s (f ∘ g) k = condEnt s g k := by
  classical
  refine Finset.sum_congr rfl fun c _ => ?_
  have hsub : ({x ∈ s | k x = c} : Finset α) ⊆ s := filter_subset _ _
  have : Set.InjOn f (g '' ({x ∈ s | k x = c} : Finset α)) := by
    refine hf.mono ?_
    exact Set.image_mono (by exact_mod_cast hsub)
  rw [uEnt_comp_injOn this]

/-- Conditional entropy is unchanged by an injective recoding of the
conditioning variable. -/
theorem condEnt_cond_injOn [DecidableEq γ'] {s : Finset α} {g : α → β} {k : α → γ} {f : γ → γ'}
    (hf : Set.InjOn f (k '' s)) : condEnt s g (f ∘ k) = condEnt s g k := by
  classical
  rw [condEnt, condEnt, ← Finset.image_image]
  rw [Finset.sum_image (by
    intro x hx y hy hxy
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hx
    obtain ⟨b, hb, rfl⟩ := mem_image.1 hy
    exact hf ⟨a, ha, rfl⟩ ⟨b, hb, rfl⟩ hxy)]
  refine Finset.sum_congr rfl fun c hc => ?_
  obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
  have hfib : {x ∈ s | (f ∘ k) x = f (k a)} = {x ∈ s | k x = k a} := by
    ext x
    simp only [mem_filter, Function.comp_apply]
    exact ⟨fun h => ⟨h.1, hf ⟨x, h.1, rfl⟩ ⟨a, ha, rfl⟩ h.2⟩, fun h => ⟨h.1, by rw [h.2]⟩⟩
  rw [hfib]

/-- The channel is unchanged by injective recodings of either variable. -/
theorem mutInfo_comp_injOn [DecidableEq β'] [DecidableEq γ'] {s : Finset α} {g : α → β}
    {k : α → γ} {f : β → β'} {e : γ → γ'} (hf : Set.InjOn f (g '' s))
    (he : Set.InjOn e (k '' s)) : mutInfo s (f ∘ g) (e ∘ k) = mutInfo s g k := by
  rw [mutInfo, uEnt_comp_injOn hf, condEnt_comp_injOn hf, condEnt_cond_injOn he, mutInfo]

/-- Relabelling the sample set along an injection leaves the entropy unchanged. -/
theorem uEnt_map {s : Finset α} (e : α ↪ α') (g : α' → β) :
    uEnt (s.map e) g = uEnt s (g ∘ e) := by
  classical
  have hfib : ∀ a ∈ s, (#{x ∈ s.map e | g x = g (e a)}) = #{x ∈ s | (g ∘ e) x = (g ∘ e) a} := by
    intro a _
    rw [Finset.filter_map]
    exact Finset.card_map _
  rw [uEnt, uEnt, Finset.card_map]
  congr 1
  congr 1
  rw [Finset.sum_map]
  refine Finset.sum_congr rfl fun a ha => ?_
  have h := hfib a ha
  simp only [Function.comp_apply] at h ⊢
  rw [h]

/-- Relabelling the sample set along an injection leaves the conditional entropy
unchanged. -/
theorem condEnt_map {s : Finset α} (e : α ↪ α') (g : α' → β) (k : α' → γ) :
    condEnt (s.map e) g k = condEnt s (g ∘ e) (k ∘ e) := by
  classical
  have himg : (s.map e).image k = s.image (k ∘ e) := by
    ext c
    simp only [mem_image, mem_map, Function.comp_apply]
    constructor
    · rintro ⟨x, ⟨a, ha, rfl⟩, rfl⟩; exact ⟨a, ha, rfl⟩
    · rintro ⟨a, ha, rfl⟩; exact ⟨e a, ⟨a, ha, rfl⟩, rfl⟩
  rw [condEnt, condEnt, himg, Finset.card_map]
  refine Finset.sum_congr rfl fun c _ => ?_
  have hfil : {x ∈ s.map e | k x = c} = ({x ∈ s | (k ∘ e) x = c}).map e := by
    rw [Finset.filter_map]
    rfl
  rw [hfil, Finset.card_map, uEnt_map]

/-- The channel is invariant under a relabelling of the sample set. -/
theorem mutInfo_map {s : Finset α} (e : α ↪ α') (g : α' → β) (k : α' → γ) :
    mutInfo (s.map e) g k = mutInfo s (g ∘ e) (k ∘ e) := by
  rw [mutInfo, mutInfo, uEnt_map, condEnt_map]

/-- Entropy is invariant under any relabelling of the sample set which is
injective *on that set*. -/
theorem uEnt_image_injOn [DecidableEq α'] {s : Finset α} {i : α → α'} (hi : Set.InjOn i s)
    (g : α' → β) : uEnt (s.image i) g = uEnt s (g ∘ i) := by
  classical
  have hsub : ∀ (t : Finset α), t ⊆ s → Set.InjOn i t := by
    intro t ht
    exact hi.mono (by exact_mod_cast ht)
  have hfib : ∀ a ∈ s, {x ∈ s.image i | g x = g (i a)}
      = ({x ∈ s | (g ∘ i) x = (g ∘ i) a}).image i := by
    intro a _
    ext y
    simp only [mem_filter, mem_image, Function.comp_apply]
    constructor
    · rintro ⟨⟨x, hx, rfl⟩, hgy⟩; exact ⟨x, ⟨hx, hgy⟩, rfl⟩
    · rintro ⟨x, ⟨hx, hgx⟩, rfl⟩; exact ⟨⟨x, hx, rfl⟩, hgx⟩
  rw [uEnt, uEnt, Finset.card_image_of_injOn hi]
  congr 1
  congr 1
  rw [Finset.sum_image (fun x hx y hy hxy => hi hx hy hxy)]
  refine Finset.sum_congr rfl fun a ha => ?_
  rw [hfib a ha, Finset.card_image_of_injOn (hsub _ (filter_subset _ _))]

/-- Conditional entropy is invariant under a relabelling of the sample set which
is injective on that set. -/
theorem condEnt_image_injOn [DecidableEq α'] {s : Finset α} {i : α → α'} (hi : Set.InjOn i s)
    (g : α' → β) (k : α' → γ) : condEnt (s.image i) g k = condEnt s (g ∘ i) (k ∘ i) := by
  classical
  have hsub : ∀ (t : Finset α), t ⊆ s → Set.InjOn i t := by
    intro t ht
    exact hi.mono (by exact_mod_cast ht)
  rw [condEnt, condEnt, Finset.image_image, Finset.card_image_of_injOn hi]
  refine Finset.sum_congr rfl fun c _ => ?_
  have hfib : {x ∈ s.image i | k x = c} = ({x ∈ s | (k ∘ i) x = c}).image i := by
    ext y
    simp only [mem_filter, mem_image, Function.comp_apply]
    constructor
    · rintro ⟨⟨x, hx, rfl⟩, hky⟩; exact ⟨x, ⟨hx, hky⟩, rfl⟩
    · rintro ⟨x, ⟨hx, hkx⟩, rfl⟩; exact ⟨⟨x, hx, rfl⟩, hkx⟩
  rw [hfib, Finset.card_image_of_injOn (hsub _ (filter_subset _ _)),
    uEnt_image_injOn (hsub _ (filter_subset _ _))]

/-- **The channel is invariant under a relabelling of the sample set.** -/
theorem mutInfo_image_injOn [DecidableEq α'] {s : Finset α} {i : α → α'} (hi : Set.InjOn i s)
    (g : α' → β) (k : α' → γ) : mutInfo (s.image i) g k = mutInfo s (g ∘ i) (k ∘ i) := by
  rw [mutInfo, mutInfo, uEnt_image_injOn hi, condEnt_image_injOn hi]

end Transport

end CyclicTypeChannel