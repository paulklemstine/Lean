import Mathlib

/-!
# Direction 8: Category-Theoretic Idempotents — The Karoubi Envelope

An idempotent morphism e ∘ e = e can be split: e = ι ∘ r with r ∘ ι = id.
-/

open Function Set

/-
PROBLEM
Commuting idempotents compose to an idempotent.

PROVIDED SOLUTION
e₁(e₂(e₁(e₂ x))) = e₁(e₁(e₂(e₂ x))) by hcomm applied to e₂ x = e₁(e₂(e₂ x)) by h₁ = e₁(e₂ x) by h₂. Just rewrite with hcomm, h₁, h₂ in sequence.
-/
theorem idempotent_comp_closed' {α : Type*} (e₁ e₂ : α → α)
    (h₁ : ∀ x, e₁ (e₁ x) = e₁ x) (h₂ : ∀ x, e₂ (e₂ x) = e₂ x)
    (hcomm : ∀ x, e₁ (e₂ x) = e₂ (e₁ x)) :
    ∀ x, e₁ (e₂ (e₁ (e₂ x))) = e₁ (e₂ x) := by
      grind +ring

/-- e² = e in any monoid. -/
theorem idempotent_sq {M : Type*} [Monoid M] (e : M) (he : e * e = e) :
    e ^ 2 = e := by rw [sq, he]

/-
PROBLEM
eⁿ = e for n ≥ 1.

PROVIDED SOLUTION
Induction on n starting from 1. Base n=1: e^1 = e. Step: e^(n+1) = e^n * e = e * e = e by IH and he.
-/
theorem idempotent_pow' {M : Type*} [Monoid M] (e : M) (he : e * e = e)
    (n : ℕ) (hn : 1 ≤ n) : e ^ n = e := by
      induction hn <;> simp +decide [ *, pow_succ' ]

/-- The Karoubi envelope consists of idempotent elements. -/
structure KaroubiElement (M : Type*) [Monoid M] where
  idem : M
  idem_sq : idem * idem = idem

/-- Identity Karoubi element. -/
def KaroubiElement.one (M : Type*) [Monoid M] : KaroubiElement M :=
  ⟨1, mul_one 1⟩

/-
PROBLEM
Product of commuting idempotents is idempotent.

PROVIDED SOLUTION
In a CommMonoid: (a*b)*(a*b) = a*a*b*b = a*b using idem_sq for both. Use mul_comm and mul_assoc to rearrange, then a.idem_sq and b.idem_sq.
-/
theorem karoubi_compose' {M : Type*} [CommMonoid M]
    (a b : KaroubiElement M) :
    (a.idem * b.idem) * (a.idem * b.idem) = a.idem * b.idem := by
      -- Since $a$ and $b$ are idempotent, we have $a.idem * a.idem = a.idem$ and $b.idem * b.idem = b.idem$.
      have h_idem : a.idem * a.idem = a.idem ∧ b.idem * b.idem = b.idem := by
        exact ⟨ a.idem_sq, b.idem_sq ⟩;
      grind +ring

/-- Every idempotent decomposes the type. -/
theorem idempotent_decomp {α : Type*} (e : α → α) :
    ∀ x, (e x = x ∧ x ∈ range e) ∨ (e x ≠ x ∧ e x ∈ range e) := by
  intro x
  by_cases h : e x = x
  · left; exact ⟨h, ⟨x, h⟩⟩
  · right; exact ⟨h, ⟨x, rfl⟩⟩