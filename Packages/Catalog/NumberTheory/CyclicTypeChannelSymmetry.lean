/-
# The which-factor wall is exactly zero

A semiprime `N = p q` presents its two prime factors symmetrically: nothing in
`N mod f` can say *which* factor carries which splitting type.  Experimentally
the "which-factor" information was measured at `0.0001` bits, i.e. zero.

This file proves that it is **exactly** zero, in complete generality:  for any
sample set carrying an involution `σ` which swaps the two components of the
read-out and fixes the conditioning variable, forgetting the order of the two
components changes both the entropy and the conditional entropy by *the same*
amount, namely the probability of an off-diagonal pair.  Consequently the
mutual information of the unordered read-out equals that of the ordered one.

The entropies themselves are genuinely different (the ordered pair carries
strictly more entropy whenever off-diagonal pairs occur); it is only the
*channel* that is insensitive to the ordering.
-/
import Catalog.Shared.CyclicTypeChannelProduct

namespace CyclicTypeChannel

open Finset

section Symmetrization

variable {α β : Type*} [LinearOrder β]

/-- Forget the order of an ordered pair. -/
def symPair (z : β × β) : β × β := (min z.1 z.2, max z.1 z.2)

/-- Two ordered pairs have the same unordered shadow exactly when they agree, or
agree after a swap. -/
theorem symPair_eq_iff (z w : β × β) :
    symPair z = symPair w ↔ z = w ∨ z = (w.2, w.1) := by
  obtain ⟨z1, z2⟩ := z
  obtain ⟨w1, w2⟩ := w
  simp only [symPair, Prod.mk.injEq]
  constructor
  · rintro ⟨h1, h2⟩
    rcases le_total z1 z2 with hz | hz <;> rcases le_total w1 w2 with hw | hw <;>
      simp only [min_eq_left, min_eq_right, max_eq_left, max_eq_right, hz, hw] at h1 h2 <;>
      subst h1 <;> subst h2 <;> simp
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact ⟨rfl, rfl⟩
    · exact ⟨min_comm _ _, max_comm _ _⟩

variable [DecidableEq β] {s : Finset α} {g : α → β × β} {σ : α → α}

omit [LinearOrder β] in
/-- The swapped fibre has the same size as the fibre: the involution `σ` maps one
onto the other. -/
theorem card_swap_fiber (hσs : ∀ a ∈ s, σ a ∈ s) (hσσ : ∀ a ∈ s, σ (σ a) = a)
    (hgσ : ∀ a ∈ s, g (σ a) = ((g a).2, (g a).1)) (a : α) :
    (#{x ∈ s | g x = ((g a).2, (g a).1)}) = #{x ∈ s | g x = g a} := by
  classical
  refine Finset.card_bij' (fun x _ => σ x) (fun x _ => σ x) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [mem_filter] at hx ⊢
    refine ⟨hσs x hx.1, ?_⟩
    rw [hgσ x hx.1, hx.2]
  · intro x hx
    simp only [mem_filter] at hx ⊢
    refine ⟨hσs x hx.1, ?_⟩
    rw [hgσ x hx.1, hx.2]
  · intro x hx
    exact hσσ x (mem_of_mem_filter x hx)
  · intro x hx
    exact hσσ x (mem_of_mem_filter x hx)

/-- The unordered fibre is the union of the fibre and its swap. -/
theorem card_symPair_fiber (hσs : ∀ a ∈ s, σ a ∈ s) (hσσ : ∀ a ∈ s, σ (σ a) = a)
    (hgσ : ∀ a ∈ s, g (σ a) = ((g a).2, (g a).1)) (a : α) :
    (#{x ∈ s | (symPair ∘ g) x = (symPair ∘ g) a})
      = (if (g a).1 = (g a).2 then 1 else 2) * #{x ∈ s | g x = g a} := by
  classical
  have hsplit : {x ∈ s | (symPair ∘ g) x = (symPair ∘ g) a}
      = {x ∈ s | g x = g a} ∪ {x ∈ s | g x = ((g a).2, (g a).1)} := by
    ext x
    simp only [mem_filter, mem_union, Function.comp_apply]
    constructor
    · rintro ⟨hx, hsx⟩
      rcases (symPair_eq_iff _ _).1 hsx with h | h
      · exact Or.inl ⟨hx, h⟩
      · exact Or.inr ⟨hx, h⟩
    · rintro (⟨hx, h⟩ | ⟨hx, h⟩)
      · exact ⟨hx, by rw [h]⟩
      · exact ⟨hx, (symPair_eq_iff _ _).2 (Or.inr h)⟩
  by_cases hd : (g a).1 = (g a).2
  · have heq : {x ∈ s | g x = ((g a).2, (g a).1)} = {x ∈ s | g x = g a} := by
      have : ((g a).2, (g a).1) = g a := Prod.ext_iff.2 ⟨hd.symm, hd⟩
      rw [this]
    rw [hsplit, heq, Finset.union_self, if_pos hd, one_mul]
  · have hdisj : Disjoint ({x ∈ s | g x = g a}) ({x ∈ s | g x = ((g a).2, (g a).1)}) := by
      rw [Finset.disjoint_left]
      intro x hx hx'
      simp only [mem_filter] at hx hx'
      rw [hx.2] at hx'
      exact hd (congrArg Prod.fst hx'.2)
    rw [hsplit, Finset.card_union_of_disjoint hdisj,
      card_swap_fiber hσs hσσ hgσ a, if_neg hd]
    ring

/-- **The entropy defect of forgetting the order.**  Passing from the ordered to
the unordered read-out costs exactly the probability of an off-diagonal pair:
each unordered off-diagonal value merges two equally likely ordered values. -/
theorem uEnt_symPair (hσs : ∀ a ∈ s, σ a ∈ s) (hσσ : ∀ a ∈ s, σ (σ a) = a)
    (hgσ : ∀ a ∈ s, g (σ a) = ((g a).2, (g a).1)) :
    uEnt s (symPair ∘ g) = uEnt s g - (#{a ∈ s | (g a).1 ≠ (g a).2} : ℝ) / s.card := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hterm : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | (symPair ∘ g) x = (symPair ∘ g) a} : ℝ)
      = Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) + (if (g a).1 ≠ (g a).2 then (1 : ℝ) else 0) := by
    intro a ha
    have hpos : (0 : ℝ) < (#{x ∈ s | g x = g a} : ℝ) := by exact_mod_cast fiber_card_pos ha
    have hcard := card_symPair_fiber hσs hσσ hgσ a
    by_cases hd : (g a).1 = (g a).2
    · rw [hcard, if_pos hd, if_neg (by simpa using hd)]
      simp
    · rw [hcard, if_neg hd, if_pos hd]
      push_cast
      rw [Real.logb_mul (by norm_num) (ne_of_gt hpos),
        Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
      ring
  have hcount : ∑ a ∈ s, (if (g a).1 ≠ (g a).2 then (1 : ℝ) else 0)
      = (#{a ∈ s | (g a).1 ≠ (g a).2} : ℝ) := by
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const_zero, nsmul_eq_mul, mul_one, add_zero]
  rw [uEnt, uEnt, Finset.sum_congr rfl hterm, Finset.sum_add_distrib, hcount]
  field_simp
  ring

/-- **The conditional entropy defect is the same.**  If the involution also fixes
the conditioning variable, conditioning does not change the cost of forgetting
the order. -/
theorem condEnt_symPair {γ : Type*} [DecidableEq γ] {k : α → γ} (hσs : ∀ a ∈ s, σ a ∈ s)
    (hσσ : ∀ a ∈ s, σ (σ a) = a) (hgσ : ∀ a ∈ s, g (σ a) = ((g a).2, (g a).1))
    (hkσ : ∀ a ∈ s, k (σ a) = k a) :
    condEnt s (symPair ∘ g) k = condEnt s g k - (#{a ∈ s | (g a).1 ≠ (g a).2} : ℝ) / s.card := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [condEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hterm : ∀ c ∈ s.image k,
      ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} (symPair ∘ g)
      = ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} g
        - (#{a ∈ ({x ∈ s | k x = c} : Finset α) | (g a).1 ≠ (g a).2} : ℝ) / s.card := by
    intro c hc
    have hne : ({x ∈ s | k x = c}).Nonempty := by
      obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
      exact ⟨a, by simp [ha]⟩
    have hNc : (0 : ℝ) < (#{x ∈ s | k x = c} : ℝ) := by exact_mod_cast card_pos.2 hne
    have h1 : ∀ a ∈ ({x ∈ s | k x = c} : Finset α), σ a ∈ ({x ∈ s | k x = c} : Finset α) := by
      intro a ha
      simp only [mem_filter] at ha ⊢
      exact ⟨hσs a ha.1, by rw [hkσ a ha.1, ha.2]⟩
    have h2 : ∀ a ∈ ({x ∈ s | k x = c} : Finset α), σ (σ a) = a :=
      fun a ha => hσσ a (mem_of_mem_filter a ha)
    have h3 : ∀ a ∈ ({x ∈ s | k x = c} : Finset α), g (σ a) = ((g a).2, (g a).1) :=
      fun a ha => hgσ a (mem_of_mem_filter a ha)
    rw [uEnt_symPair h1 h2 h3]
    field_simp
  rw [condEnt, Finset.sum_congr rfl hterm, Finset.sum_sub_distrib, ← condEnt, ← Finset.sum_div]
  congr 1
  congr 1
  have hfil : ∀ c, {a ∈ ({x ∈ s | k x = c} : Finset α) | (g a).1 ≠ (g a).2}
      = {x ∈ ({a ∈ s | (g a).1 ≠ (g a).2} : Finset α) | k x = c} := by
    intro c
    ext x
    simp only [mem_filter]
    tauto
  have hfib := Finset.card_eq_sum_card_fiberwise
    (f := k) (s := ({a ∈ s | (g a).1 ≠ (g a).2} : Finset α)) (t := s.image k)
    (fun x hx => mem_image_of_mem k (mem_of_mem_filter x hx))
  rw [show ∑ c ∈ s.image k, ((#{a ∈ ({x ∈ s | k x = c} : Finset α) | (g a).1 ≠ (g a).2} : ℕ) : ℝ)
      = ∑ c ∈ s.image k, ((#{x ∈ ({a ∈ s | (g a).1 ≠ (g a).2} : Finset α) | k x = c} : ℕ) : ℝ) from
    Finset.sum_congr rfl fun c _ => by rw [hfil c]]
  exact_mod_cast hfib.symm

/-- **The which-factor wall is exactly zero.**  Forgetting which of the two
components carries which value costs the same entropy with or without knowing
the conditioning variable, so the *channel* is unchanged. -/
theorem mutInfo_symPair {γ : Type*} [DecidableEq γ] {k : α → γ} (hσs : ∀ a ∈ s, σ a ∈ s)
    (hσσ : ∀ a ∈ s, σ (σ a) = a) (hgσ : ∀ a ∈ s, g (σ a) = ((g a).2, (g a).1))
    (hkσ : ∀ a ∈ s, k (σ a) = k a) :
    mutInfo s (symPair ∘ g) k = mutInfo s g k := by
  rw [mutInfo, mutInfo, uEnt_symPair hσs hσσ hgσ, condEnt_symPair hσs hσσ hgσ hkσ]
  ring

end Symmetrization

end CyclicTypeChannel