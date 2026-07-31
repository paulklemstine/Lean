import Mathlib

/-!
# Negabinary: unique finite representations of all integers

This file proves that evaluation in radix `-2` gives a bijection between canonical
finite bit strings and the integers. Digits are stored least-significant first.
-/

namespace Negabinary

/-- The integer represented by a least-significant-first list of bits in base `-2`. -/
def value : List Bool → ℤ
  | [] => 0
  | b :: bs => (if b then 1 else 0) - 2 * value bs

/-- A representation is canonical when it has no zero in its most-significant place. -/
def Canonical (l : List Bool) : Prop := l.getLast? ≠ some false

/-- The forced least-significant bit of an integer. -/
def bit (z : ℤ) : Bool := decide (z % 2 = 1)

/-- The integer value, either zero or one, of the forced bit. -/
def digit (z : ℤ) : ℤ := if bit z then 1 else 0

/-- The quotient remaining after removing the forced digit and dividing by `-2`. -/
def next (z : ℤ) : ℤ := -((z - digit z) / 2)

@[simp] theorem value_nil : value [] = 0 := rfl

@[simp] theorem value_cons (b : Bool) (bs : List Bool) :
    value (b :: bs) = (if b then 1 else 0) - 2 * value bs := rfl

@[simp] theorem canonical_nil : Canonical [] := by
  simp [Canonical]

theorem canonical_tail {b : Bool} {bs : List Bool} (h : Canonical (b :: bs)) :
    Canonical bs := by
  cases bs with
  | nil => exact canonical_nil
  | cons c cs =>
    simp [Canonical] at h ⊢
    exact h

/-- The chosen digit is exactly the Euclidean residue modulo two. -/
theorem digit_eq_emod (z : ℤ) : digit z = z % 2 := by
  unfold digit bit
  have : z % 2 = 0 ∨ z % 2 = 1 := by omega
  rcases this with h | h <;> simp [h]

/-- Removing the chosen digit leaves an even integer. -/
theorem two_dvd_sub_digit (z : ℤ) : 2 ∣ z - digit z := by
  rw [digit_eq_emod]
  omega

/-- One negabinary division step reconstructs the original integer. -/
theorem reconstruct (z : ℤ) : digit z - 2 * next z = z := by
  simp [next]
  have h : 2 * ((z - digit z) / 2) = z - digit z := by
    exact Int.mul_ediv_cancel' (two_dvd_sub_digit z)
  linarith

/-- Except at zero and the one exceptional point `-1`, one negabinary division
step strictly decreases absolute value. (Indeed `next (-1) = 1`.) -/
theorem natAbs_next_lt (z : ℤ) (hz : z ≠ 0) (hneg : z ≠ -1) :
    (next z).natAbs < z.natAbs := by
  have hrec := reconstruct z
  rw [digit_eq_emod] at hrec
  omega

/-- The parity of a represented integer recovers its first bit. -/
theorem value_cons_emod (b : Bool) (bs : List Bool) :
    value (b :: bs) % 2 = if b then 1 else 0 := by
  simp [value_cons]
  cases b <;> rfl

/-- A canonical representation of zero is necessarily empty. -/
theorem canonical_value_eq_zero {l : List Bool} (hc : Canonical l)
    (hv : value l = 0) : l = [] := by
  induction l with
  | nil => rfl
  | cons b bs ih =>
    simp [value_cons] at hv
    cases b with
    | true =>
      simp at hv
      omega
    | false =>
      simp at hv
      have hcan : Canonical bs := canonical_tail hc
      have hbs : bs = [] := ih hcan hv
      simp [hbs, Canonical] at hc

/-- Canonical negabinary evaluation is injective. -/
theorem value_injective {l₁ l₂ : List Bool} (h₁ : Canonical l₁)
    (h₂ : Canonical l₂) (hv : value l₁ = value l₂) : l₁ = l₂ := by
  induction l₁ generalizing l₂ with
  | nil => exact (canonical_value_eq_zero h₂ hv.symm).symm
  | cons b₁ bs₁ ih =>
    cases l₂ with
    | nil => cases canonical_value_eq_zero h₁ hv
    | cons b₂ bs₂ =>
      have hb : b₁ = b₂ := by
        have := value_cons_emod b₁ bs₁
        have := value_cons_emod b₂ bs₂
        simp [hv] at *
        cases b₁ <;> cases b₂ <;> trivial
      have hc1 : Canonical bs₁ := canonical_tail h₁
      have hc2 : Canonical bs₂ := canonical_tail h₂
      have hv' : value bs₁ = value bs₂ := by
        simp [value_cons] at hv
        simp [hb] at hv
        omega
      have htails : bs₁ = bs₂ := ih hc1 hc2 hv'
      rw [hb, htails]

/-- Every integer has a canonical negabinary representation. -/
theorem exists_canonical (z : ℤ) :
    ∃ l : List Bool, Canonical l ∧ value l = z := by
  by_cases hz : z = 0
  · exact ⟨[], canonical_nil, hz.symm⟩
  · -- z ≠ 0: use strong induction on natAbs z
    have aux : ∀ m : ℕ, ∀ w : ℤ, w.natAbs = m → ¬w = 0 → ∃ l, Canonical l ∧ value l = w := fun m =>
      Nat.strongRecOn m fun n ih w hw hw0 => by
        by_cases hneg : w = -1
        · -- Case w = -1: bit (-1) = true, next (-1) = 1
          refine ⟨[true, true], ?_, ?_⟩
          · simp [Canonical]
          · -- value [true, true] = 1 - 2*1 = -1
            norm_num [value]
            rw [hneg.symm]
        · -- Case w ≠ -1: natAbs (next w) < natAbs w
          have hlt : (next w).natAbs < n := by rw [← hw]; exact natAbs_next_lt w hw0 hneg
          by_cases hnext : next w = 0
          · -- next w = 0 means w = 1, so bit w = true
            refine ⟨[true], ?_, ?_⟩
            · simp [Canonical]
            · simp [value]
              have hw1 : w = 1 := by
                have hrecon := reconstruct w
                simp [hnext] at hrecon
                have : digit w = 0 ∨ digit w = 1 := by
                  unfold digit bit
                  split <;> simp
                cases this with
                | inl h => exact (hw0 (hrecon.symm.trans h)).elim
                | inr h => exact hrecon.symm.trans h
              rw [hw1]
          · -- next w ≠ 0: use IH
            obtain ⟨l, hcan, hv⟩ := ih (next w).natAbs hlt (next w) rfl hnext
            refine ⟨bit w :: l, ?_, ?_⟩
            · -- Show bit w :: l is canonical
              cases l with
              | nil => simp [value] at hv; exact absurd hv.symm hnext
              | cons x xs =>
                simp [Canonical] at hcan ⊢
                exact hcan
            · -- Show value (bit w :: l) = w
              simp [value_cons, hv]
              have : (if bit w = true then (1 : ℤ) else 0) = digit w := by
                unfold digit bit
                split <;> simp
              rw [this]
              exact reconstruct w
    exact aux _ _ rfl hz

/-- **Unique negabinary representation theorem.** Every integer is represented by
exactly one canonical finite bit list in base `-2`. -/
theorem unique_representation (z : ℤ) :
    ∃! l : List Bool, Canonical l ∧ value l = z := by
  obtain ⟨l, hc, hv⟩ := exists_canonical z
  refine ⟨l, ⟨hc, hv⟩, ?_⟩
  rintro y ⟨hyc, hyv⟩
  exact value_injective hyc hc (hyv.trans hv.symm)

/-- Evaluation is a bijection from canonical bit lists to the integers. -/
noncomputable def canonicalEquivInt : {l : List Bool // Canonical l} ≃ ℤ :=
  Equiv.ofBijective (fun l => value l.1) ⟨by
    intro x y h
    apply Subtype.ext
    exact value_injective x.2 y.2 h, by
    intro z
    obtain ⟨l, hc, hv⟩ := exists_canonical z
    exact ⟨⟨l, hc⟩, hv⟩⟩

/-- Negabinary representation is stable under one radix-extension step. -/
theorem exists_canonical_cons (z : ℤ) :
    ∃ l : List Bool, Canonical l ∧ value (bit z :: l) = z := by
  obtain ⟨l, hc, hv⟩ := exists_canonical (next z)
  refine ⟨l, hc, ?_⟩
  simp [value_cons, hv]
  have hd : (if bit z then (1 : ℤ) else 0) = digit z := rfl
  rw [hd]
  exact reconstruct z

/-- Computational witnesses for small positive and negative integers. -/
example : value [true, true, false, true] = (-9 : ℤ) := by norm_num [value]
example : value [false, true, true] = (2 : ℤ) := by norm_num [value]
example : value [true, true, true, false, true] = (19 : ℤ) := by norm_num [value]

end Negabinary