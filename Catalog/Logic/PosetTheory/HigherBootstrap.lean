import Mathlib

/-! # CatalogBuild.Logic.HigherBootstrap

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 15
-/

/-- Every ordinal is the strict sup of its predecessors:
p < o implies p + 1 ≤ o. -/
theorem ordinal_le_of_forall_lt (o : Ordinal) :
    ∀ p : Ordinal, p < o → p + 1 ≤ o := by
  intro p hp
  exact Order.succ_le_of_lt hp

/-- Transfinite induction: the ultimate bootstrap principle. To prove P holds for
all ordinals, it suffices to show P(α) assuming P(β) for all β < α.
Each step bootstraps from all previous steps. -/
theorem transfinite_bootstrap (P : Ordinal → Prop)
    (h : ∀ o : Ordinal, (∀ p : Ordinal, p < o → P p) → P o) :
    ∀ o : Ordinal, P o :=
  fun o => WellFoundedLT.fix h o

/-- Universe lifting: every type in a lower universe can be bootstrapped
into a higher universe -/
theorem universe_lift_exists (α : Type u) :
    ∃ _ : Type (u + 1), Nonempty (α ≃ ULift.{u+1} α) :=
  ⟨ULift.{u+1} α, ⟨Equiv.ulift.symm⟩⟩

/-- The powerset operation bootstraps a type into a fundamentally richer one
(Cantor's theorem in type-theoretic form) -/
theorem powerset_strictly_larger (α : Type*) [Nonempty α] :
    ¬ ∃ f : (α → Prop) → α, Function.Injective f := by
  rintro ⟨f, hf⟩
  set D : α → Prop := fun a => ∃ S : α → Prop, f S = a ∧ ¬S a
  have hFD : D (f D) ↔ ¬D (f D) := by grind
  grind

/-- Ackermann's function: a classic bootstrapped definition where each level
of the function bootstraps from the previous level -/
def ackermann : ℕ → ℕ → ℕ
  | 0, n => n + 1
  | m + 1, 0 => ackermann m 1
  | m + 1, n + 1 => ackermann m (ackermann (m + 1) n)

/-- Ackermann grows faster than its inputs: n < ackermann m n -/
theorem ackermann_growth (m n : ℕ) : n < ackermann m n := by
  induction' m with m ih generalizing n
  · simp [ackermann]
  · have h_ind : ∀ k, ackermann m k > k := ih
    induction' n with n ihn
    · unfold ackermann; linarith [h_ind 1]
    · have : ackermann (m + 1) (n + 1) = ackermann m (ackermann (m + 1) n) := by rw [ackermann]
      linarith [h_ind (ackermann (m + 1) n)]

/-- ackermann m is strictly increasing: ackermann m n < ackermann m (n + 1) -/
theorem ackermann_lt_succ : ∀ m n : ℕ, ackermann m n < ackermann m (n + 1) := by
  intro m
  induction m with
  | zero => intro n; simp [ackermann]
  | succ m ih =>
    have hm : StrictMono (ackermann m) := strictMono_nat_of_lt_succ ih
    intro n
    induction n with
    | zero => simp only [ackermann]; exact hm (ackermann_growth m 1)
    | succ n ihn => unfold ackermann; exact hm ihn

/-- Ackermann's function is strictly increasing in the second argument -/
theorem ackermann_strict_mono_right (m : ℕ) : StrictMono (ackermann m) :=
  strictMono_nat_of_lt_succ (ackermann_lt_succ m)

/-- Simple propositional formulas -/
inductive PropForm : Type where
  | var : ℕ → PropForm
  | false_ : PropForm
  | imp : PropForm → PropForm → PropForm

/-- Assignment of truth values to propositional variables -/
def PropValuation := ℕ → Bool

/-- Evaluate a formula under a valuation -/
def PropForm.eval (v : PropValuation) : PropForm → Bool
  | .var n => v n
  | .false_ => false
  | .imp p q => !(p.eval v) || q.eval v

/-- A formula is a tautology if true under all valuations -/
def PropForm.isTautology (φ : PropForm) : Prop :=
  ∀ v : PropValuation, φ.eval v = true

/-- Negation as syntactic sugar -/
def PropForm.not_ (φ : PropForm) : PropForm := .imp φ .false_

/-- Double negation elimination is a tautology: ¬¬p → p -/
theorem dne_is_tautology (n : ℕ) :
    PropForm.isTautology (.imp (.not_ (.not_ (.var n))) (.var n)) := by
  intro v; cases v n <;> simp [PropForm.eval, PropForm.not_]

/-- The identity is a tautology: p → p -/
theorem identity_is_tautology (n : ℕ) :
    PropForm.isTautology (.imp (.var n) (.var n)) := by
  intro v; simp [PropForm.eval]