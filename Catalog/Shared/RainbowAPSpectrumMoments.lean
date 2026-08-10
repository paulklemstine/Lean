import Mathlib

open Finset

namespace RainbowAP

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The set of colours of `α` that are missed by the word `f : Fin m → α`. -/
def missing {m : ℕ} (f : Fin m → α) : Finset α :=
  univ.filter (fun a => ∀ x, f x ≠ a)

/-- The number of colours missed by the word `f`. -/
def missCount {m : ℕ} (f : Fin m → α) : ℕ := (missing f).card

lemma mem_missing {m : ℕ} (f : Fin m → α) (a : α) :
    a ∈ missing f ↔ ∀ x, f x ≠ a := by
  simp [missing]

lemma missCount_eq_zero_iff {m : ℕ} (f : Fin m → α) :
    missCount f = 0 ↔ Function.Surjective f := by
  constructor
  · intro h a
    by_contra hc
    push_neg at hc
    have hmem : a ∈ missing f := (mem_missing f a).2 (fun x hx => hc x hx)
    rw [missCount, Finset.card_eq_zero] at h
    rw [h] at hmem
    simp at hmem
  · intro h
    rw [missCount, Finset.card_eq_zero]
    ext a
    simp only [mem_missing, Finset.notMem_empty, iff_false, not_forall, not_not]
    obtain ⟨x, hx⟩ := h a
    exact ⟨x, hx⟩

/-- Words over `α` of length `m` avoiding one fixed letter. -/
lemma card_avoid_one (m : ℕ) (a : α) :
    (univ.filter (fun f : Fin m → α => ∀ x, f x ≠ a)).card
      = (Fintype.card α - 1) ^ m := by
  have h : (univ.filter (fun f : Fin m → α => ∀ x, f x ≠ a))
      = Fintype.piFinset (fun _ : Fin m => univ.erase a) := by
    ext f
    simp [Fintype.mem_piFinset]
  rw [h, Fintype.card_piFinset]
  simp [Finset.card_erase_of_mem]

/-- Words over `α` of length `m` avoiding two fixed distinct letters. -/
lemma card_avoid_two (m : ℕ) (a b : α) (hab : a ≠ b) :
    (univ.filter (fun f : Fin m → α => (∀ x, f x ≠ a) ∧ (∀ x, f x ≠ b))).card
      = (Fintype.card α - 2) ^ m := by
  have h1 : (univ.filter (fun f : Fin m → α => (∀ x, f x ≠ a) ∧ (∀ x, f x ≠ b)))
      = Fintype.piFinset (fun _ : Fin m => (univ.erase a).erase b) := by
    ext f
    simp only [Fintype.mem_piFinset, Finset.mem_filter, Finset.mem_univ, true_and,
      Finset.mem_erase, forall_and]
    tauto
  have h2 : ((univ.erase a).erase b).card = Fintype.card α - 2 := by
    rw [Finset.card_erase_of_mem (by simp [hab.symm]), Finset.card_erase_of_mem (by simp)]
    simp [Finset.card_univ]
    omega
  rw [h1, Fintype.card_piFinset]
  simp [h2]

lemma missCount_eq_sum {m : ℕ} (f : Fin m → α) :
    missCount f = ∑ a : α, (if (∀ x, f x ≠ a) then 1 else 0) := by
  rw [missCount, missing, Finset.card_filter]

/-- **First moment identity**: summing the number of missed colours over all words. -/
lemma sum_missCount (m : ℕ) :
    ∑ f : Fin m → α, missCount f = Fintype.card α * (Fintype.card α - 1) ^ m := by
  simp_rw [missCount_eq_sum]
  rw [Finset.sum_comm]
  have h : ∀ a : α, (∑ f : Fin m → α, (if (∀ x, f x ≠ a) then 1 else 0))
      = (Fintype.card α - 1) ^ m := by
    intro a
    rw [← Finset.card_filter, card_avoid_one]
  rw [Finset.sum_congr rfl (fun a _ => h a)]
  simp [Finset.card_univ]

/-- **Second moment identity**: summing the square of the number of missed colours. -/
lemma sum_missCount_sq (m : ℕ) :
    ∑ f : Fin m → α, (missCount f) ^ 2
      = Fintype.card α * (Fintype.card α - 1) ^ m
        + Fintype.card α * (Fintype.card α - 1) * (Fintype.card α - 2) ^ m := by
  have key : ∀ f : Fin m → α, (missCount f) ^ 2
      = ∑ a : α, ∑ b : α, (if ((∀ x, f x ≠ a) ∧ (∀ x, f x ≠ b)) then 1 else 0) := by
    intro f
    rw [sq, missCount_eq_sum, Finset.sum_mul_sum]
    refine Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun b _ => ?_))
    by_cases ha : (∀ x, f x ≠ a) <;> by_cases hb : (∀ x, f x ≠ b) <;> simp [ha, hb]
  simp_rw [key]
  have swap : (∑ f : Fin m → α, ∑ a : α, ∑ b : α,
        (if ((∀ x, f x ≠ a) ∧ (∀ x, f x ≠ b)) then 1 else 0))
      = ∑ a : α, ∑ b : α, ∑ f : Fin m → α,
        (if ((∀ x, f x ≠ a) ∧ (∀ x, f x ≠ b)) then 1 else 0) := by
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl (fun a _ => Finset.sum_comm)
  rw [swap]
  have step : ∀ a : α, (∑ b : α, ∑ f : Fin m → α,
      (if ((∀ x, f x ≠ a) ∧ (∀ x, f x ≠ b)) then 1 else 0))
      = (Fintype.card α - 1) ^ m + (Fintype.card α - 1) * (Fintype.card α - 2) ^ m := by
    intro a
    have hdiag : (∑ f : Fin m → α, (if ((∀ x, f x ≠ a) ∧ (∀ x, f x ≠ a)) then 1 else 0))
        = (Fintype.card α - 1) ^ m := by
      rw [← Finset.card_filter, ← card_avoid_one m a]
      congr 1
      ext f
      simp [and_self]
    have hoff : ∀ b : α, b ≠ a → (∑ f : Fin m → α,
        (if ((∀ x, f x ≠ a) ∧ (∀ x, f x ≠ b)) then 1 else 0))
        = (Fintype.card α - 2) ^ m := by
      intro b hb
      rw [← Finset.card_filter, card_avoid_two m a b (Ne.symm hb)]
    rw [← Finset.sum_erase_add _ _ (Finset.mem_univ a), hdiag]
    rw [Finset.sum_congr rfl (fun b hb => hoff b (Finset.mem_erase.1 hb).1)]
    rw [Finset.sum_const, Finset.card_erase_of_mem (Finset.mem_univ a)]
    simp [Finset.card_univ, add_comm]
  rw [Finset.sum_congr rfl (fun a _ => step a)]
  simp [Finset.card_univ, mul_add, mul_assoc]

end RainbowAP