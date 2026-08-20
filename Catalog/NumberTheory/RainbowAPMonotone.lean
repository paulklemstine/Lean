import Mathlib
import Catalog.Shared.RainbowAPSpectrumThreshold

/-!
# The full-spectrum transition is monotone: `spectrumThreshold` is a genuine threshold

The definition of `spectrumThreshold α` as an infimum only says that *some* length realises a
surjective majority.  Here we prove that the majority property is upward closed in the word
length, so that

  `2 * nonSurjCount α m < |α| ^ m  ↔  spectrumThreshold α ≤ m`,

i.e. the transition happens exactly once.  The combinatorial engine is the extension injection
`(a, f) ↦ Fin.snoc f a`, which shows `|α| · Surj(m) ≤ Surj(m+1)`.
-/

open Finset

namespace RainbowAP

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The surjective (full-spectrum) words of length `m`. -/
def surjSet (α : Type*) [Fintype α] [DecidableEq α] (m : ℕ) : Finset (Fin m → α) :=
  (univ : Finset (Fin m → α)).filter (fun f => missCount f = 0)

lemma mem_surjSet {m : ℕ} (f : Fin m → α) :
    f ∈ surjSet α m ↔ Function.Surjective f := by
  simp [surjSet, missCount_eq_zero_iff]

/-- Surjective and non-surjective words partition all words. -/
lemma card_surjSet_add_nonSurjCount (m : ℕ) :
    (surjSet α m).card + nonSurjCount α m = Fintype.card α ^ m := by
  have hpart := Finset.card_filter_add_card_filter_not
    (s := (univ : Finset (Fin m → α))) (p := fun f => missCount f = 0)
  have hneg : (univ : Finset (Fin m → α)).filter (fun f => ¬ (missCount f = 0))
      = nonSurjSet α m := by
    unfold nonSurjSet
    apply Finset.filter_congr
    intro f _
    simp [Nat.pos_iff_ne_zero]
  rw [hneg] at hpart
  have hcard : (univ : Finset (Fin m → α)).card = Fintype.card α ^ m := by
    simp [Finset.card_univ]
  rw [hcard] at hpart
  exact hpart

/-- **Extension injection**: appending any letter to a surjective word gives a surjective word,
so `|α| · Surj(m) ≤ Surj(m+1)`. -/
lemma card_mul_surjSet_le (m : ℕ) :
    Fintype.card α * (surjSet α m).card ≤ (surjSet α (m + 1)).card := by
  have hmap : ∀ p ∈ (univ : Finset α) ×ˢ surjSet α m,
      (fun p : α × (Fin m → α) => (Fin.snoc p.2 p.1 : Fin (m + 1) → α)) p
        ∈ surjSet α (m + 1) := by
    rintro ⟨a, f⟩ hp
    simp only [Finset.mem_product, Finset.mem_univ, true_and] at hp
    rw [mem_surjSet] at hp ⊢
    intro b
    obtain ⟨i, hi⟩ := hp b
    exact ⟨i.castSucc, by simpa [Fin.snoc_castSucc] using hi⟩
  have hinj : Set.InjOn (fun p : α × (Fin m → α) => (Fin.snoc p.2 p.1 : Fin (m + 1) → α))
      ((univ : Finset α) ×ˢ surjSet α m) := by
    rintro ⟨a, f⟩ _ ⟨b, g⟩ _ hfg
    simp only at hfg
    have hlast : a = b := by
      have := congrArg (fun w => w (Fin.last m)) hfg
      simpa [Fin.snoc_last] using this
    have hrest : f = g := by
      funext i
      have := congrArg (fun w => w i.castSucc) hfg
      simpa [Fin.snoc_castSucc] using this
    simp [hlast, hrest]
  have hinj' : Set.InjOn (fun p : α × (Fin m → α) => (Fin.snoc p.2 p.1 : Fin (m + 1) → α))
      ((univ ×ˢ surjSet α m : Finset (α × (Fin m → α)))) := by
    intro x hx y hy hxy
    exact hinj (by simpa using hx) (by simpa using hy) hxy
  have hcard := Finset.card_le_card_of_injOn _ hmap hinj'
  simpa [Finset.card_product, Finset.card_univ] using hcard

/-- The surjective majority property is preserved by increasing the word length by one. -/
lemma majority_step {m : ℕ} (hN : 1 ≤ Fintype.card α)
    (h : 2 * nonSurjCount α m < Fintype.card α ^ m) :
    2 * nonSurjCount α (m + 1) < Fintype.card α ^ (m + 1) := by
  have hm := card_surjSet_add_nonSurjCount (α := α) m
  have hm1 := card_surjSet_add_nonSurjCount (α := α) (m + 1)
  have hext := card_mul_surjSet_le (α := α) m
  have hpos : 0 < Fintype.card α := by omega
  have hgrow : Fintype.card α ^ (m + 1) = Fintype.card α * Fintype.card α ^ m := by ring
  have hhalf : Fintype.card α ^ m < 2 * (surjSet α m).card := by omega
  have h1 : Fintype.card α * (Fintype.card α ^ m)
      < Fintype.card α * (2 * (surjSet α m).card) := by
    exact mul_lt_mul_of_pos_left hhalf hpos
  have h2 : Fintype.card α * (2 * (surjSet α m).card)
      = 2 * (Fintype.card α * (surjSet α m).card) := by ring
  omega

/-- The surjective majority property is upward closed in the word length. -/
theorem majority_monotone (hN : 1 ≤ Fintype.card α) {m m' : ℕ} (hmm : m ≤ m')
    (h : 2 * nonSurjCount α m < Fintype.card α ^ m) :
    2 * nonSurjCount α m' < Fintype.card α ^ m' := by
  induction m' with
  | zero => simpa [Nat.le_zero.1 hmm] using h
  | succ n ih =>
      rcases Nat.lt_or_ge m (n + 1) with hlt | hge
      · exact majority_step hN (ih (by omega))
      · have : m = n + 1 := by omega
        simpa [this] using h

/-- **The threshold is a genuine phase transition.** -/
theorem majority_iff_threshold_le (hN : 2 ≤ Fintype.card α)
    (hne : {m | 2 * nonSurjCount α m < Fintype.card α ^ m}.Nonempty) (m : ℕ) :
    (2 * nonSurjCount α m < Fintype.card α ^ m) ↔ spectrumThreshold α ≤ m := by
  constructor
  · intro h
    exact spectrumThreshold_le_of_mem h
  · intro h
    exact majority_monotone (by omega) h (mem_of_spectrumThreshold hne)

end RainbowAP