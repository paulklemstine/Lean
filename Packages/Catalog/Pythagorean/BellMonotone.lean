import Pythagorean.KernelPatternsBell

/-!
# Strict monotonicity of the Bell numbers, by a pattern-extension injection

Mathlib defines `Nat.bell` by its binomial recursion and proves essentially nothing about
its growth.  Having identified `Nat.bell n` with the number of kernel patterns of length `n`
(`KernelPattern.card_patterns_eq_bell`), monotonicity becomes a combinatorial statement:
adjoining a new singleton block embeds the patterns of length `n` into those of length
`n + 1`, and the constant pattern is missed by that embedding.

Main results:

* `KernelPattern.extendPattern_mem_patterns` : the extension of a pattern is a pattern;
* `Nat.bell_lt_bell_succ` : `Nat.bell n < Nat.bell (n + 1)` for `n ≥ 1`;
* `Nat.bell_monotone` : `Nat.bell` is monotone;
* `Nat.le_bell` : `n ≤ Nat.bell n`.
-/

open Finset

namespace KernelPattern

variable {n : ℕ}

/-- Extend a pattern of length `n` by a new singleton block at the last coordinate. -/
def extendPattern (p : Fin n → Fin n) : Fin (n + 1) → Fin (n + 1) := fun i =>
  if h : i.val < n then (p ⟨i.val, h⟩).castSucc else Fin.last n

@[simp] theorem extendPattern_castSucc (p : Fin n → Fin n) (i : Fin n) :
    extendPattern p i.castSucc = (p i).castSucc := by
  simp [extendPattern, Fin.castSucc, Fin.is_lt]

@[simp] theorem extendPattern_last (p : Fin n → Fin n) :
    extendPattern p (Fin.last n) = Fin.last n := by
  simp [extendPattern]

theorem extendPattern_ne_last {p : Fin n → Fin n} (i : Fin n) :
    extendPattern p i.castSucc ≠ Fin.last n := by
  rw [extendPattern_castSucc]
  exact (Fin.castSucc_lt_last (p i)).ne

/-- The extension of a pattern is again a pattern. -/
theorem extendPattern_mem_patterns {p : Fin n → Fin n} (hp : p ∈ Patterns n) :
    extendPattern p ∈ Patterns (n + 1) := by
  have hcan : canon p = p := mem_patterns_iff.1 hp
  rw [mem_patterns_iff]
  funext i
  refine canon_eq_iff_least.2 ⟨?_, ?_⟩
  · rcases Fin.eq_castSucc_or_eq_last i with ⟨a, rfl⟩ | rfl
    · rw [extendPattern_castSucc, extendPattern_castSucc]
      congr 1
      have := canon_canon_apply p a
      rwa [hcan] at this
    · rw [extendPattern_last, extendPattern_last]
  · intro j hj
    rcases Fin.eq_castSucc_or_eq_last i with ⟨a, rfl⟩ | rfl
    · rcases Fin.eq_castSucc_or_eq_last j with ⟨b, rfl⟩ | rfl
      · rw [extendPattern_castSucc, extendPattern_castSucc] at hj
        have hpb : p b = p a := Fin.castSucc_injective n hj
        have hle : canon p a ≤ b := canon_le hpb
        rw [hcan] at hle
        rw [extendPattern_castSucc]
        exact Fin.castSucc_le_castSucc_iff.2 hle
      · rw [extendPattern_last, extendPattern_castSucc] at hj
        exact absurd hj.symm (Fin.castSucc_lt_last (p a)).ne
    · rcases Fin.eq_castSucc_or_eq_last j with ⟨b, rfl⟩ | rfl
      · rw [extendPattern_last, extendPattern_castSucc] at hj
        exact absurd hj (Fin.castSucc_lt_last (p b)).ne
      · rw [extendPattern_last]

theorem extendPattern_injective : Function.Injective (extendPattern (n := n)) := by
  intro p q hpq
  funext i
  have := congrFun hpq i.castSucc
  rw [extendPattern_castSucc, extendPattern_castSucc] at this
  exact Fin.castSucc_injective n this

/-- The constant pattern of length `n + 1` is not an extension: it sends the last
coordinate to `0`, not to itself. -/
theorem const_not_mem_image (hn : 1 ≤ n) :
    (fun _ => 0 : Fin (n + 1) → Fin (n + 1)) ∉ (Patterns n).image extendPattern := by
  intro hmem
  obtain ⟨p, -, hp⟩ := Finset.mem_image.1 hmem
  have h1 : extendPattern p (Fin.last n) = 0 := by rw [hp]
  rw [extendPattern_last] at h1
  have : (n : ℕ) = 0 := congrArg Fin.val h1
  omega

theorem const_mem_patterns (n : ℕ) :
    (fun _ => 0 : Fin (n + 1) → Fin (n + 1)) ∈ Patterns (n + 1) := by
  rw [mem_patterns_iff]
  funext i
  exact canon_eq_iff_least.2 ⟨rfl, fun j _ => Fin.zero_le _⟩

/-- Strict growth of the number of patterns. -/
theorem card_patterns_lt_card_patterns_succ (hn : 1 ≤ n) :
    (Patterns n).card < (Patterns (n + 1)).card := by
  have hsub : (Patterns n).image extendPattern ⊆ Patterns (n + 1) := by
    intro q hq
    obtain ⟨p, hp, rfl⟩ := Finset.mem_image.1 hq
    exact extendPattern_mem_patterns hp
  have hssub : (Patterns n).image extendPattern ⊂ Patterns (n + 1) :=
    Finset.ssubset_iff_of_subset hsub |>.2
      ⟨_, const_mem_patterns n, const_not_mem_image hn⟩
  have hcard : ((Patterns n).image extendPattern).card = (Patterns n).card :=
    Finset.card_image_of_injective _ extendPattern_injective
  calc (Patterns n).card = ((Patterns n).image extendPattern).card := hcard.symm
    _ < (Patterns (n + 1)).card := Finset.card_lt_card hssub

end KernelPattern

namespace Nat

/-- The Bell numbers are strictly increasing from `n = 1` on. -/
theorem bell_lt_bell_succ {n : ℕ} (hn : 1 ≤ n) : Nat.bell n < Nat.bell (n + 1) := by
  rw [← KernelPattern.card_patterns_eq_bell, ← KernelPattern.card_patterns_eq_bell]
  exact KernelPattern.card_patterns_lt_card_patterns_succ hn

theorem bell_le_bell_succ (n : ℕ) : Nat.bell n ≤ Nat.bell (n + 1) := by
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp
  · exact (bell_lt_bell_succ hn).le

theorem bell_monotone : Monotone Nat.bell :=
  monotone_nat_of_le_succ bell_le_bell_succ

/-- The Bell numbers grow at least linearly. -/
theorem le_bell (n : ℕ) : n ≤ Nat.bell n := by
  induction n with
  | zero => simp
  | succ m ih =>
      rcases Nat.eq_zero_or_pos m with rfl | hm
      · simp
      · have := bell_lt_bell_succ hm
        omega

/-- The Bell numbers are strictly monotone on `[1, ∞)`. -/
theorem bell_strictMonoOn : StrictMonoOn Nat.bell (Set.Ici 1) := by
  intro a ha b hb hab
  simp only [Set.mem_Ici] at ha hb
  induction b with
  | zero => omega
  | succ m ih =>
      rcases Nat.lt_or_ge a m with h | h
      · exact lt_trans (ih (by omega) (by omega)) (bell_lt_bell_succ (by omega))
      · have : a = m := by omega
        subst this
        exact bell_lt_bell_succ ha

end Nat