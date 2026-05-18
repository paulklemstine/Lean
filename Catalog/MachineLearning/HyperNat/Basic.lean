/-
  # HyperNat: Nonstandard Natural Numbers via Eventual Equivalence

  This file constructs a concrete nonstandard extension of ℕ by taking the
  quotient of sequences ℕ → ℕ by the relation of eventual equality.
-/

import Mathlib

namespace HyperNat

/-! ## Section 1: Eventual Equivalence -/

/-- Two sequences are eventually equal if they agree from some point onward. -/
def EventuallyEq (f g : ℕ → ℕ) : Prop :=
  ∃ N : ℕ, ∀ n, N ≤ n → f n = g n

theorem EventuallyEq_refl (f : ℕ → ℕ) : EventuallyEq f f :=
  ⟨0, fun _ _ => rfl⟩

theorem EventuallyEq_symm {f g : ℕ → ℕ} (h : EventuallyEq f g) : EventuallyEq g f := by
  obtain ⟨N, hN⟩ := h
  exact ⟨N, fun n hn => (hN n hn).symm⟩

theorem EventuallyEq_trans {f g h : ℕ → ℕ} (hfg : EventuallyEq f g)
    (hgh : EventuallyEq g h) : EventuallyEq f h := by
  obtain ⟨N₁, hN₁⟩ := hfg
  obtain ⟨N₂, hN₂⟩ := hgh
  exact ⟨max N₁ N₂, fun n hn =>
    (hN₁ n (le_of_max_le_left hn)).trans (hN₂ n (le_of_max_le_right hn))⟩

/-- The setoid of eventual equality on ℕ-valued sequences. -/
instance eventualSetoid : Setoid (ℕ → ℕ) where
  r := EventuallyEq
  iseqv := ⟨EventuallyEq_refl, fun h => EventuallyEq_symm h, fun h1 h2 => EventuallyEq_trans h1 h2⟩

/-! ## Section 2: The HyperNat Type -/

/-- The type of hypernatural numbers: equivalence classes of sequences ℕ → ℕ
    under eventual equality. -/
def _root_.HyperNat : Type := Quotient HyperNat.eventualSetoid

end HyperNat

namespace HyperNat

/-! ## Section 3: Arithmetic Operations -/

/-- Well-definedness of pointwise addition under eventual equality. -/
theorem EventuallyEq_add {f₁ f₂ g₁ g₂ : ℕ → ℕ}
    (hf : EventuallyEq f₁ f₂) (hg : EventuallyEq g₁ g₂) :
    EventuallyEq (fun n => f₁ n + g₁ n) (fun n => f₂ n + g₂ n) := by
  obtain ⟨N₁, hN₁⟩ := hf
  obtain ⟨N₂, hN₂⟩ := hg
  exact ⟨max N₁ N₂, fun n hn => by
    simp [hN₁ n (le_of_max_le_left hn), hN₂ n (le_of_max_le_right hn)]⟩

/-- Well-definedness of pointwise multiplication under eventual equality. -/
theorem EventuallyEq_mul {f₁ f₂ g₁ g₂ : ℕ → ℕ}
    (hf : EventuallyEq f₁ f₂) (hg : EventuallyEq g₁ g₂) :
    EventuallyEq (fun n => f₁ n * g₁ n) (fun n => f₂ n * g₂ n) := by
  obtain ⟨N₁, hN₁⟩ := hf
  obtain ⟨N₂, hN₂⟩ := hg
  exact ⟨max N₁ N₂, fun n hn => by
    simp [hN₁ n (le_of_max_le_left hn), hN₂ n (le_of_max_le_right hn)]⟩

noncomputable instance : Zero HyperNat := ⟨Quotient.mk _ (fun _ => 0)⟩
noncomputable instance : One HyperNat := ⟨Quotient.mk _ (fun _ => 1)⟩

noncomputable instance : Add HyperNat where
  add := Quotient.lift₂ (fun f g => Quotient.mk _ (fun n => f n + g n))
    (fun _ _ _ _ (hf : EventuallyEq _ _) (hg : EventuallyEq _ _) =>
      Quotient.sound (EventuallyEq_add hf hg))

noncomputable instance : Mul HyperNat where
  mul := Quotient.lift₂ (fun f g => Quotient.mk _ (fun n => f n * g n))
    (fun _ _ _ _ (hf : EventuallyEq _ _) (hg : EventuallyEq _ _) =>
      Quotient.sound (EventuallyEq_mul hf hg))

/-- Embed a standard natural number as a constant sequence. -/
def ofNat' (k : ℕ) : HyperNat := Quotient.mk _ (fun _ => k)

/-- The canonical infinite element: the class of the identity sequence. -/
def omega : HyperNat := Quotient.mk _ id

/-- Mk notation for constructing HyperNat from a sequence. -/
def mk (f : ℕ → ℕ) : HyperNat := Quotient.mk _ f

/-! ## Section 4: Eventual Ordering -/

/-- Eventual less-than-or-equal: f ≤ g eventually. -/
def EventuallyLE (f g : ℕ → ℕ) : Prop :=
  ∃ N : ℕ, ∀ n, N ≤ n → f n ≤ g n

/-- Well-definedness of eventual ≤ under eventual equality. -/
theorem EventuallyLE_resp {f₁ f₂ g₁ g₂ : ℕ → ℕ}
    (hf : EventuallyEq f₁ f₂) (hg : EventuallyEq g₁ g₂) :
    EventuallyLE f₁ g₁ ↔ EventuallyLE f₂ g₂ := by
  constructor
  · rintro ⟨N₃, hN₃⟩
    obtain ⟨N₁, hN₁⟩ := hf
    obtain ⟨N₂, hN₂⟩ := hg
    exact ⟨max (max N₁ N₂) N₃, fun n hn => by
      rw [← hN₁ n (le_trans (le_max_left N₁ N₂) (le_of_max_le_left hn)),
          ← hN₂ n (le_trans (le_max_right N₁ N₂) (le_of_max_le_left hn))]
      exact hN₃ n (le_of_max_le_right hn)⟩
  · rintro ⟨N₃, hN₃⟩
    obtain ⟨N₁, hN₁⟩ := hf
    obtain ⟨N₂, hN₂⟩ := hg
    exact ⟨max (max N₁ N₂) N₃, fun n hn => by
      rw [hN₁ n (le_trans (le_max_left N₁ N₂) (le_of_max_le_left hn)),
          hN₂ n (le_trans (le_max_right N₁ N₂) (le_of_max_le_left hn))]
      exact hN₃ n (le_of_max_le_right hn)⟩

/-- The eventual ordering on HyperNat, well-defined on quotient. -/
def le : HyperNat → HyperNat → Prop :=
  Quotient.lift₂ EventuallyLE (fun _ _ _ _
    (hf : EventuallyEq _ _) (hg : EventuallyEq _ _) =>
      propext (EventuallyLE_resp hf hg))

/-! ## Section 5: Non-Archimedean Property -/

/-- Every standard natural is eventually ≤ omega. -/
theorem ofNat_le_omega (k : ℕ) : le (ofNat' k) omega :=
  ⟨k, fun _ hn => hn⟩

/-- omega is not eventually ≤ any standard natural: the non-Archimedean theorem. -/
theorem not_omega_le_ofNat (k : ℕ) : ¬ le omega (ofNat' k) := by
  intro ⟨N, hN⟩
  have := hN (N + k + 1) (by omega)
  simp [id] at this

/-! ## Section 6: Basic Algebraic Properties -/

theorem add_comm' (a b : HyperNat) : a + b = b + a := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun n _ => Nat.add_comm _ _⟩

theorem add_assoc' (a b c : HyperNat) : a + b + c = a + (b + c) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun n _ => Nat.add_assoc _ _ _⟩

theorem mul_comm' (a b : HyperNat) : a * b = b * a := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun n _ => Nat.mul_comm _ _⟩

theorem mul_assoc' (a b c : HyperNat) : a * b * c = a * (b * c) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun n _ => Nat.mul_assoc _ _ _⟩

theorem zero_add' (a : HyperNat) : (0 : HyperNat) + a = a := by
  induction a using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun n _ => Nat.zero_add _⟩

theorem add_zero' (a : HyperNat) : a + (0 : HyperNat) = a := by
  rw [add_comm']; exact zero_add' a

theorem one_mul' (a : HyperNat) : (1 : HyperNat) * a = a := by
  induction a using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun n _ => Nat.one_mul _⟩

theorem mul_one' (a : HyperNat) : a * (1 : HyperNat) = a := by
  rw [mul_comm']; exact one_mul' a

theorem zero_mul' (a : HyperNat) : (0 : HyperNat) * a = 0 := by
  induction a using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun _ _ => Nat.zero_mul _⟩

theorem left_distrib' (a b c : HyperNat) : a * (b + c) = a * b + a * c := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun n _ => Nat.left_distrib _ _ _⟩

theorem right_distrib' (a b c : HyperNat) : (a + b) * c = a * c + b * c := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  induction c using Quotient.ind
  apply Quotient.sound
  exact ⟨0, fun n _ => Nat.right_distrib _ _ _⟩

/-! ## Section 7: Nontriviality -/

/-- omega is not equal to any standard natural. -/
theorem omega_ne_ofNat (k : ℕ) : omega ≠ ofNat' k := by
  intro h
  have : le omega (ofNat' k) := by
    rw [h]; exact ⟨0, fun n _ => Nat.le_refl _⟩
  exact not_omega_le_ofNat k this

/-- Zero is not one in HyperNat. -/
theorem zero_ne_one' : (0 : HyperNat) ≠ 1 := by
  intro h
  have : EventuallyEq (fun _ => 0) (fun _ => 1) := Quotient.exact h
  obtain ⟨N, hN⟩ := this
  have := hN N (Nat.le_refl _)
  simp at this

/-- omega + 1 ≠ omega: infinite elements are distinguishable. -/
theorem omega_add_one_ne_omega : omega + ofNat' 1 ≠ omega := by
  intro h
  have : EventuallyEq (fun n => n + 1) (fun n => n) := by
    have := Quotient.exact h
    exact this
  obtain ⟨N, hN⟩ := this
  have := hN N (Nat.le_refl _)
  simp at this

/-- omega * 2 ≠ omega. -/
theorem omega_mul_two_ne_omega : omega * ofNat' 2 ≠ omega := by
  intro h
  have : EventuallyEq (fun n => n * 2) id := Quotient.exact h
  obtain ⟨N, hN⟩ := this
  have := hN (N + 1) (by omega)
  simp [id] at this

end HyperNat