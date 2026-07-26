/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Universe Codes and Weak Univalence

This file constructs a small universe of codes for finite types and proves a
**weak univalence principle**: equivalence of interpretations implies equality of
normalized codes.

## Main definitions

- `UCode` — Inductive codes for finite types
- `El` — Interpretation function mapping codes to types
- `card` — Cardinality function on codes
- `canonical` — Canonical representative code for each natural number
- `normalize` — Normalization of codes to canonical form

## Main results

- `card_canonical` — The cardinality of a canonical code equals its index
- `normalize_idempotent` — Normalization is idempotent
- `canonical_injective` — Canonical codes are injective
- `fintypeEl` — Every interpreted code is a `Fintype`
- `decidableEqEl` — Every interpreted code has decidable equality
- `card_eq_fintype_card` — `card` agrees with `Fintype.card`
- `El_normalize_equiv` — A code's interpretation is equivalent to its normalization's
- `equiv_implies_card_eq` — Equivalent types have equal cardinality
- `weak_univalence_normalized` — Equivalent normal forms are equal codes
-/

namespace CubicalSemantics

-- Inline PathOver for self-containedness (main definition is in Basic.lean)
private def PathOverLocal (A : Type v) (a₀ a₁ : A) : Type v :=
  { p : Bool → A // p false = a₀ ∧ p true = a₁ }

/-- Codes for a small universe of finite types. -/
inductive UCode : Type where
  | zero : UCode
  | one  : UCode
  | bool : UCode
  | sum  : UCode → UCode → UCode
  | prod : UCode → UCode → UCode
  deriving DecidableEq, Repr

/-- Interpretation of universe codes as Lean types. -/
def El : UCode → Type
  | .zero     => Empty
  | .one      => Unit
  | .bool     => Bool
  | .sum a b  => El a ⊕ El b
  | .prod a b => El a × El b

/-- Cardinality of a universe code. -/
def card : UCode → ℕ
  | .zero     => 0
  | .one      => 1
  | .bool     => 2
  | .sum a b  => card a + card b
  | .prod a b => card a * card b

/-- Canonical code for a given natural number. -/
def canonical : ℕ → UCode
  | 0     => .zero
  | 1     => .one
  | n + 2 => .sum .one (canonical (n + 1))

/-- Normalize a code to canonical form. -/
def normalize (c : UCode) : UCode := canonical (card c)

/-- Rank of a code. -/
def codeRank : UCode → ℕ
  | .zero     => 0
  | .one      => 0
  | .bool     => 0
  | .sum a b  => max (codeRank a) (codeRank b) + 1
  | .prod a b => max (codeRank a) (codeRank b) + 1

/-! ### Cardinality of canonical codes -/

theorem card_canonical (n : ℕ) : card (canonical n) = n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
  exact show card ( .sum .one ( canonical ( n + 1 ) ) ) = n + 2 from by { rw [ show card ( .sum .one ( canonical ( n + 1 ) ) ) = card .one + card ( canonical ( n + 1 ) ) by rfl ] ; simp +arith +decide [ ih _ le_rfl ] }

/-! ### Normalization properties -/

theorem normalize_idempotent (c : UCode) : normalize (normalize c) = normalize c := by
  -- By definition of `normalize`, we have `normalize (normalize c) = canonical (card (canonical (card c)))`.
  simp [normalize, card_canonical]

theorem canonical_injective : Function.Injective canonical := by
  exact fun n m h => by simpa [ card_canonical ] using congr_arg card h;

/-! ### Fintype and DecidableEq instances for El -/

noncomputable instance fintypeEl : (c : UCode) → Fintype (El c)
  | .zero => (inferInstance : Fintype Empty)
  | .one => (inferInstance : Fintype Unit)
  | .bool => (inferInstance : Fintype Bool)
  | .sum a b => @instFintypeSum _ _ (fintypeEl a) (fintypeEl b)
  | .prod a b => @instFintypeProd _ _ (fintypeEl a) (fintypeEl b)

instance decidableEqEl : (c : UCode) → DecidableEq (El c)
  | .zero => (inferInstance : DecidableEq Empty)
  | .one => (inferInstance : DecidableEq Unit)
  | .bool => (inferInstance : DecidableEq Bool)
  | .sum a b => @instDecidableEqSum _ _ (decidableEqEl a) (decidableEqEl b)
  | .prod a b => @instDecidableEqProd _ _ (decidableEqEl a) (decidableEqEl b)

/-! ### Cardinality agreement -/

theorem card_eq_fintype_card (c : UCode) : card c = Fintype.card (El c) := by
  -- Apply induction on c.
  induction' c using UCode.recOn with a b a b ih_a ih_b;
  · rfl;
  · rfl;
  · rfl;
  · convert congr_arg₂ ( · + · ) a b using 1;
    convert Fintype.card_sum;
  · exact show card ih_a * card ih_b = Fintype.card ( El ih_a × El ih_b ) from by rw [ Fintype.card_prod, ‹card ih_a = Fintype.card ( El ih_a ) ›, ‹card ih_b = Fintype.card ( El ih_b ) › ] ;

/-! ### Equivalences -/

noncomputable def El_normalize_equiv (c : UCode) : El c ≃ El (normalize c) :=
  Fintype.equivOfCardEq (by
    have h1 := card_eq_fintype_card c
    have h2 := card_eq_fintype_card (normalize c)
    have h3 : card (normalize c) = card c := by simp [normalize, card_canonical]
    omega)

theorem equiv_implies_card_eq {a b : UCode} (h : Nonempty (El a ≃ El b)) :
    card a = card b := by
  exact card_eq_fintype_card a ▸ card_eq_fintype_card b ▸ Fintype.card_congr h.some

theorem weak_univalence_normalized
    {a b : UCode}
    (h : Nonempty (El a ≃ El b))
    (ha : normalize a = a)
    (hb : normalize b = b) :
    a = b := by
  exact ha.symm.trans ( congrArg canonical ( equiv_implies_card_eq h ) ) |> Eq.trans <| hb

def weak_univalence_path
    {a b : UCode}
    (h : Nonempty (El a ≃ El b)) :
    PathOverLocal UCode (normalize a) (normalize b) :=
  have heq : normalize a = normalize b := by
    simp only [normalize]
    exact congrArg canonical (equiv_implies_card_eq h)
  ⟨fun b => if b then normalize _ else normalize _,
   rfl, heq⟩

end CubicalSemantics