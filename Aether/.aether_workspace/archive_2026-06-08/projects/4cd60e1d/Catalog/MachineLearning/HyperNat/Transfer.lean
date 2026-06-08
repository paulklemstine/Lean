/-
  # Transfer Principle for Quantifier-Free Arithmetic

  This file defines a simple language of arithmetic terms (constants, variable,
  addition, multiplication) and proves that any universally quantified identity
  over ℕ transfers automatically to HyperNat.
-/

import Mathlib
import Speculative.HyperNat.Basic

namespace HyperNat

/-! ## Arithmetic Terms -/

/-- A simple language of unary arithmetic terms over ℕ. -/
inductive ArithTerm where
  | const : ℕ → ArithTerm
  | var : ArithTerm
  | add : ArithTerm → ArithTerm → ArithTerm
  | mul : ArithTerm → ArithTerm → ArithTerm
  deriving Repr

namespace ArithTerm

/-- Evaluate an arithmetic term at a natural number. -/
def evalNat : ArithTerm → ℕ → ℕ
  | const k, _ => k
  | var, n => n
  | add t₁ t₂, n => t₁.evalNat n + t₂.evalNat n
  | mul t₁ t₂, n => t₁.evalNat n * t₂.evalNat n

/-- Evaluate an arithmetic term at a HyperNat by pointwise lifting. -/
noncomputable def evalHyper : ArithTerm → HyperNat → HyperNat
  | const k, _ => ofNat' k
  | var, x => x
  | add t₁ t₂, x => t₁.evalHyper x + t₂.evalHyper x
  | mul t₁ t₂, x => t₁.evalHyper x * t₂.evalHyper x

/-! ## Key Lemma: Pointwise evaluation agrees with lifted evaluation -/

/-- For any arithmetic term and sequence f, the pointwise evaluation of the term
    at each f(n) gives a sequence whose equivalence class equals evalHyper at [f]. -/
theorem evalHyper_repr (t : ArithTerm) (f : ℕ → ℕ) :
    t.evalHyper (⟦f⟧) = ⟦fun n => t.evalNat (f n)⟧ := by
  induction t with
  | const k => rfl
  | var => rfl
  | add t₁ t₂ ih₁ ih₂ =>
    simp only [evalHyper, evalNat, ih₁, ih₂]; rfl
  | mul t₁ t₂ ih₁ ih₂ =>
    simp only [evalHyper, evalNat, ih₁, ih₂]; rfl

/-! ## The Transfer Theorem -/

/-- **Transfer Theorem for Quantifier-Free Arithmetic Identities.**
    If two arithmetic terms agree on all natural numbers, then they agree
    on all hypernatural numbers. -/
theorem transfer_arith_eq (t₁ t₂ : ArithTerm)
    (h : ∀ n : ℕ, t₁.evalNat n = t₂.evalNat n) :
    ∀ x : HyperNat, t₁.evalHyper x = t₂.evalHyper x := by
  intro x
  induction x using Quotient.ind with
  | _ f =>
    rw [evalHyper_repr, evalHyper_repr]
    apply Quotient.sound
    exact ⟨0, fun n _ => h (f n)⟩

/-- Transfer theorem for inequalities. -/
theorem transfer_arith_le (t₁ t₂ : ArithTerm)
    (h : ∀ n : ℕ, t₁.evalNat n ≤ t₂.evalNat n) :
    ∀ x : HyperNat, le (t₁.evalHyper x) (t₂.evalHyper x) := by
  intro x
  induction x using Quotient.ind with
  | _ f =>
    rw [evalHyper_repr, evalHyper_repr]
    exact ⟨0, fun n _ => h (f n)⟩

end ArithTerm

/-! ## Multivariate Transfer -/

/-- A simple language of binary arithmetic terms (two variables). -/
inductive ArithTerm2 where
  | const : ℕ → ArithTerm2
  | var1 : ArithTerm2
  | var2 : ArithTerm2
  | add : ArithTerm2 → ArithTerm2 → ArithTerm2
  | mul : ArithTerm2 → ArithTerm2 → ArithTerm2
  deriving Repr

namespace ArithTerm2

def evalNat : ArithTerm2 → ℕ → ℕ → ℕ
  | const k, _, _ => k
  | var1, x, _ => x
  | var2, _, y => y
  | add t₁ t₂, x, y => t₁.evalNat x y + t₂.evalNat x y
  | mul t₁ t₂, x, y => t₁.evalNat x y * t₂.evalNat x y

noncomputable def evalHyper : ArithTerm2 → HyperNat → HyperNat → HyperNat
  | const k, _, _ => ofNat' k
  | var1, x, _ => x
  | var2, _, y => y
  | add t₁ t₂, x, y => t₁.evalHyper x y + t₂.evalHyper x y
  | mul t₁ t₂, x, y => t₁.evalHyper x y * t₂.evalHyper x y

theorem evalHyper_repr (t : ArithTerm2) (f g : ℕ → ℕ) :
    t.evalHyper (⟦f⟧) (⟦g⟧) = ⟦fun n => t.evalNat (f n) (g n)⟧ := by
  induction t with
  | const k => rfl
  | var1 => rfl
  | var2 => rfl
  | add t₁ t₂ ih₁ ih₂ =>
    simp only [evalHyper, evalNat, ih₁, ih₂]; rfl
  | mul t₁ t₂ ih₁ ih₂ =>
    simp only [evalHyper, evalNat, ih₁, ih₂]; rfl

/-- Transfer theorem for binary arithmetic identities. -/
theorem transfer_arith2_eq (t₁ t₂ : ArithTerm2)
    (h : ∀ x y : ℕ, t₁.evalNat x y = t₂.evalNat x y) :
    ∀ x y : HyperNat, t₁.evalHyper x y = t₂.evalHyper x y := by
  intro x y
  induction x using Quotient.ind with
  | _ f =>
    induction y using Quotient.ind with
    | _ g =>
      rw [evalHyper_repr, evalHyper_repr]
      apply Quotient.sound
      exact ⟨0, fun n _ => h (f n) (g n)⟩

end ArithTerm2

/-! ## Eventual Divisibility -/

/-- Eventual divisibility on sequences. -/
def EventuallyDvd (f g : ℕ → ℕ) : Prop :=
  ∃ N : ℕ, ∀ n, N ≤ n → f n ∣ g n

/-- Well-definedness of eventual divisibility under eventual equality. -/
theorem EventuallyDvd_resp {f₁ f₂ g₁ g₂ : ℕ → ℕ}
    (hf : EventuallyEq f₁ f₂) (hg : EventuallyEq g₁ g₂) :
    EventuallyDvd f₁ g₁ ↔ EventuallyDvd f₂ g₂ := by
  obtain ⟨Nf, hNf⟩ := hf
  obtain ⟨Ng, hNg⟩ := hg
  constructor
  · rintro ⟨N, hN⟩
    exact ⟨max (max Nf Ng) N, fun n hn => by
      rw [← hNf n (le_trans (le_max_left Nf Ng) (le_of_max_le_left hn)),
          ← hNg n (le_trans (le_max_right Nf Ng) (le_of_max_le_left hn))]
      exact hN n (le_of_max_le_right hn)⟩
  · rintro ⟨N, hN⟩
    exact ⟨max (max Nf Ng) N, fun n hn => by
      rw [hNf n (le_trans (le_max_left Nf Ng) (le_of_max_le_left hn)),
          hNg n (le_trans (le_max_right Nf Ng) (le_of_max_le_left hn))]
      exact hN n (le_of_max_le_right hn)⟩

/-- Divisibility on HyperNat, lifted from eventual divisibility. -/
def hdvd : HyperNat → HyperNat → Prop :=
  Quotient.lift₂ EventuallyDvd (fun _ _ _ _
    (hf : EventuallyEq _ _) (hg : EventuallyEq _ _) =>
      propext (EventuallyDvd_resp hf hg))

/-- If f(n) ∣ g(n) eventually, then [f] ∣ [g] in HyperNat. -/
theorem eventual_dvd_to_hyper_dvd {f g : ℕ → ℕ}
    (h : ∃ N, ∀ n, N ≤ n → f n ∣ g n) :
    hdvd (mk f) (mk g) := h

/-- Standard divisibility transfers to HyperNat. -/
theorem transfer_dvd_pointwise {f g : ℕ → ℕ}
    (h : ∀ n, f n ∣ g n) :
    hdvd (mk f) (mk g) :=
  ⟨0, fun n _ => h n⟩

end HyperNat