/-
  # Idempotent Stone Completeness — Concrete Examples

  This file provides concrete instances and demonstrations:
  1. Derivation examples for the positive modal logic
  2. Soundness applied to specific formulas
  3. Product embedding illustration (Theorem 1)
-/
import Bridges.IdempotentStone.Completeness

namespace IdempotentStone

/-! ## §1. Derivation Examples -/

/-- A simple formula: x ∨ x. -/
def exFormula1 : PMF (Fin 1) := .disj (.var 0) (.var 0)

/-- The derivation x ∨ x ≤ x. -/
example : Derives exFormula1 (.var 0 : PMF (Fin 1)) :=
  Derives.disj_idem _

/-- □(x ∨ y) ≤ □x ∨ □y is derivable. -/
example : Derives (.box (.disj (.var 0) (.var 1)) : PMF (Fin 2))
    (.disj (.box (.var 0)) (.box (.var 1))) :=
  Derives.box_disj _ _

/-- x ≤ □x is derivable (inflationary). -/
example : Derives (.var 0 : PMF (Fin 1)) (.box (.var 0)) :=
  Derives.box_inflate _

/-- □□x ≤ □x is derivable (idempotent). -/
example : Derives (.box (.box (.var 0)) : PMF (Fin 1)) (.box (.var 0)) :=
  Derives.box_idem _

/-- ⊥ ≤ φ is derivable for any φ. -/
example : Derives (.bot : PMF (Fin 1)) (.box (.var 0)) :=
  Derives.bot_elim _

/-- □x ∧ □y ≤ □(x ∧ y) (nucleus law) is derivable. -/
example : Derives (.conj (.box (.var 0)) (.box (.var 1)) : PMF (Fin 2))
    (.box (.conj (.var 0) (.var 1))) :=
  Derives.box_mul _ _

/-- Monotonicity: if φ ≤ ψ and φ' ≤ ψ', then φ ∧ φ' ≤ ψ ∧ ψ'. -/
example : Derives (.conj (.var 0) (.var 1) : PMF (Fin 2))
    (.conj (.box (.var 0)) (.box (.var 1))) :=
  Derives.conj_mono (Derives.box_inflate _) (Derives.box_inflate _)

/-- Composed derivation: x ∧ y ≤ □(x ∧ y) via nucleus law. -/
example : Derives (.conj (.var 0) (.var 1) : PMF (Fin 2))
    (.box (.conj (.var 0) (.var 1))) :=
  Derives.trans
    (Derives.conj_mono (Derives.box_inflate _) (Derives.box_inflate _))
    (Derives.box_mul _ _)

/-! ## §2. Soundness Applied -/

/-- Soundness: x ∨ x ≤ x holds in all models. -/
theorem disj_idem_sound
    {S : Type*} [IdempCSR S] (cn : ClosureNucleus S) (v : Fin 1 → S) :
    IdempCSR.natLE (eval cn v exFormula1) (eval cn v (.var 0)) :=
  soundness cn (Derives.disj_idem _) v

/-- Soundness: x ≤ □x holds in all models. -/
theorem inflate_sound
    {S : Type*} [IdempCSR S] (cn : ClosureNucleus S) (v : Fin 1 → S) :
    IdempCSR.natLE (eval cn v (.var 0)) (eval cn v (.box (.var 0))) :=
  soundness cn (Derives.box_inflate _) v

/-! ## §3. Product Embedding (Theorem 1) -/

/-- The product evaluation map: sends x to the tuple of its congruence classes. -/
def productEvalMap {S : Type*} [IdempCSR S] (cn : ClosureNucleus S)
    (x : S) (P : PrimeClosureCong S cn) : Set S :=
  P.toClosureCong.cls x

/-- Injectivity on closed elements (restating Theorem 1). -/
theorem productMap_injective_closed
    {S : Type*} [IdempCSR S] (cn : ClosureNucleus S)
    (sep : PrimeSeparation S cn)
    {a b : S} (ha : cn.IsClosed a) (hb : cn.IsClosed b)
    (h : ∀ P : PrimeClosureCong S cn,
      productEvalMap cn a P = productEvalMap cn b P) :
    a = b := by
  apply separation_injective cn sep a b ha hb
  intro P
  have hset := h P
  simp [productEvalMap, ClosureCong.cls] at hset
  have : a ∈ {y | P.r b y} := hset ▸ P.r_refl a
  exact P.r_symm this

/-! ## §4. Algebraic Identities as Derivations -/

/-- □□φ = □φ (both directions derivable). -/
theorem box_idem_equiv (φ : PMF α) :
    Derives (.box φ) (.box (.box φ)) ∧
    Derives (.box (.box φ)) (.box φ) :=
  ⟨Derives.box_inflate (.box φ), Derives.box_idem φ⟩

/-- □(φ ∨ ψ) = □φ ∨ □ψ (both directions derivable). -/
theorem box_disj_equiv (φ ψ : PMF α) :
    Derives (.box (.disj φ ψ)) (.disj (.box φ) (.box ψ)) ∧
    Derives (.disj (.box φ) (.box ψ)) (.box (.disj φ ψ)) :=
  ⟨Derives.box_disj φ ψ, Derives.disj_box φ ψ⟩

/-- φ ∧ (ψ ∨ χ) = (φ ∧ ψ) ∨ (φ ∧ χ) (both directions). -/
theorem distrib_equiv (φ ψ χ : PMF α) :
    Derives (.conj φ (.disj ψ χ)) (.disj (.conj φ ψ) (.conj φ χ)) ∧
    Derives (.disj (.conj φ ψ) (.conj φ χ)) (.conj φ (.disj ψ χ)) :=
  ⟨Derives.distrib φ ψ χ, Derives.distrib' φ ψ χ⟩

/-- φ ∧ ⊤ = φ (both directions). -/
theorem conj_top_equiv (φ : PMF α) :
    Derives (.conj φ .top) φ ∧ Derives φ (.conj φ .top) :=
  ⟨Derives.conj_unit_r φ, Derives.conj_unit_r' φ⟩

/-! ## §5. Composition Patterns -/

/-- Derived rule: □φ ∨ □φ ≤ □φ (box commutes with idempotency). -/
theorem box_disj_self (φ : PMF α) :
    Derives (.disj (.box φ) (.box φ)) (.box φ) :=
  Derives.disj_idem _

/-- Derived rule: □⊥ ≤ □⊥ ∧ □⊤ ≤ □(⊥ ∧ ⊤) ≤ □⊥. -/
theorem box_nucleus_chain :
    Derives (.conj (.box (.bot : PMF α)) (.box .top)) (.box .bot) :=
  Derives.trans (Derives.box_mul .bot .top)
    (Derives.box_mono (Derives.trans (Derives.conj_comm .bot .top) (Derives.conj_zero .top)))

end IdempotentStone