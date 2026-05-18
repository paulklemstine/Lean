import Mathlib

/-! # CatalogBuild.Logic.IdempotentProofComplexity

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 25
-/

noncomputable section

/-- An idempotent binary operation: f(x,x) = x -/
def IsIdempotentOp {α : Type*} (f : α → α → α) : Prop :=
  ∀ x, f x x = x

/-- [Section: # CatalogBuild.Logic.IdempotentProofComplexity
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 25] -/
theorem min_idempotent : IsIdempotentOp (min : ℕ → ℕ → ℕ) := by
  exact fun x => min_self x

/-- [Section: # CatalogBuild.Logic.IdempotentProofComplexity
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 25] -/
theorem max_idempotent : IsIdempotentOp (max : ℕ → ℕ → ℕ) := by
  exact fun x => max_self x

theorem gcd_idempotent : IsIdempotentOp (Nat.gcd) := by
  exact fun x => Nat.gcd_self x

theorem lcm_idempotent : IsIdempotentOp (Nat.lcm) := by
  exact fun x => Nat.lcm_self x

theorem and_idempotent : IsIdempotentOp (· && ·) := by
  exact fun x => by cases x <;> rfl;

theorem or_idempotent : IsIdempotentOp (· || ·) := by
  exact fun x => by cases x <;> rfl;

/-- Abstract proof system: a set of axioms, a combination rule, and a derivation relation -/
structure ProofSystem (Formula Proof : Type*) where
  axiomSet : Set Formula
  combine : Proof → Proof → Proof
  conclusion : Proof → Formula
  proofSize : Proof → ℕ
  proofWidth : Proof → ℕ

/-- A proof system is idempotent if its combination rule is idempotent -/
def ProofSystem.isIdempotent {F P : Type*} (ps : ProofSystem F P) : Prop :=
  IsIdempotentOp ps.combine

/-- A clause is a finite set of literals (integers: positive = variable, negative = negation) -/
abbrev Clause := Finset ℤ

/-- Width of a clause is its cardinality -/
def clauseWidth (c : Clause) : ℕ := c.card

/-- Resolution rule: resolve two clauses on a variable -/
def resolve (c1 c2 : Clause) (v : ℤ) (hv : v ∈ c1) (hnv : -v ∈ c2) : Clause :=
  (c1.erase v) ∪ (c2.erase (-v))

theorem resolve_width_bound (c1 c2 : Clause) (v : ℤ)
    (hv : v ∈ c1) (hnv : -v ∈ c2) :
    clauseWidth (resolve c1 c2 v hv hnv) ≤ clauseWidth c1 + clauseWidth c2 - 1 := by
      have h_card : (c1.erase v).card + (c2.erase (-v)).card ≤ c1.card + c2.card - 1 := by
        grind;
      exact le_trans ( Finset.card_union_le _ _ ) h_card

theorem weaken_clause (c : Clause) (l : ℤ) :
    c ⊆ insert l c := by
      exact Finset.subset_insert _ _

/-- An idempotent unary operation on a type -/
def IsIdempotentUnary {α : Type*} (f : α → α) : Prop :=
  f ∘ f = f

theorem idem_compose {α : Type*} (f g : α → α)
    (hf : f ∘ f = f) (hg : g ∘ g = g) (hfg : f ∘ g = g ∘ f) :
    (f ∘ g) ∘ (f ∘ g) = f ∘ g := by
      simp_all +decide [ funext_iff, Set.ext_iff ]

/-- Monotone real-valued interpolation between 0 and 1 -/
noncomputable def interpolate (t : ℝ) (a b : ℝ) : ℝ :=
  (1 - t) * a + t * b

theorem interpolate_zero (a b : ℝ) : interpolate 0 a b = a := by
  unfold interpolate; ring;

theorem interpolate_one (a b : ℝ) : interpolate 1 a b = b := by
  unfold interpolate; ring;

theorem interpolate_mono (a b : ℝ) (hab : a ≤ b) (s t : ℝ) (hst : s ≤ t)
    (hs : 0 ≤ s) (ht : t ≤ 1) :
    interpolate s a b ≤ interpolate t a b := by
      unfold interpolate; nlinarith;

/-- A binary operation satisfying absorption: f(x, f(x, y)) = f(x, y) -/
def IsAbsorbing {α : Type*} (f : α → α → α) : Prop :=
  ∀ x y, f x (f x y) = f x y

theorem min_absorbing : IsAbsorbing (min : ℕ → ℕ → ℕ) := by
  exact fun x y => by simp +decide [ min_assoc ] ;

theorem max_absorbing : IsAbsorbing (max : ℕ → ℕ → ℕ) := by
  exact fun x y => max_eq_right ( le_max_left _ _ )

theorem absorbing_self_fixed {α : Type*} (f : α → α → α)
    (habs : IsAbsorbing f) (x : α) : f x (f x x) = f x x := by
      exact habs x x

theorem idem_and_absorbing_consistent :
    IsIdempotentOp (min : ℕ → ℕ → ℕ) ∧ IsAbsorbing (min : ℕ → ℕ → ℕ) := by
      exact ⟨ min_idempotent, min_absorbing ⟩

end