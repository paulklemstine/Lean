/-
  # Idempotent Stone Completeness via Closure Nuclei and Tropical Kripke Spectra
  ## Part 2: Positive Modal Logic — Syntax, Semantics, and Soundness
-/
import Bridges.IdempotentStone.Basic

namespace IdempotentStone

/-! ## §1. Positive Modal Formulas -/

/-- Positive modal formulas over a variable type α. -/
inductive PMF (α : Type*)
  | var : α → PMF α
  | top : PMF α
  | bot : PMF α
  | conj : PMF α → PMF α → PMF α
  | disj : PMF α → PMF α → PMF α
  | box : PMF α → PMF α
  deriving DecidableEq

/-! ## §2. Semantic Evaluation -/

/-- Evaluate a formula in an idempotent semiring with closure nucleus. -/
def eval {S : Type*} [IdempCSR S] (cn : ClosureNucleus S)
    (v : α → S) : PMF α → S
  | .var a => v a
  | .top => 1
  | .bot => 0
  | .conj φ ψ => eval cn v φ * eval cn v ψ
  | .disj φ ψ => eval cn v φ + eval cn v ψ
  | .box φ => cn.c (eval cn v φ)

/-! ## §3. Stalk Semantics -/

/-- A formula is valid in stalk P. -/
def ValidInStalk {S : Type*} [IdempCSR S] {cn : ClosureNucleus S}
    (P : PrimeClosureCong S cn) (φ : PMF α) : Prop :=
  ∀ v : α → S, P.identifies (eval cn v φ) 1

/-- A formula is valid in all stalks. -/
def ValidInAllStalks {S : Type*} [IdempCSR S] (cn : ClosureNucleus S)
    (φ : PMF α) : Prop :=
  ∀ P : PrimeClosureCong S cn, ValidInStalk P φ

/-! ## §4. Derivability Relation -/

/-- Derivability for positive modal/tropical logic.
    `Derives φ ψ` means φ ≤ ψ in the algebraic order. -/
inductive Derives : PMF α → PMF α → Prop
  | refl (φ) : Derives φ φ
  | trans {φ ψ χ} : Derives φ ψ → Derives ψ χ → Derives φ χ
  | disj_left (φ ψ) : Derives φ (.disj φ ψ)
  | disj_right (φ ψ) : Derives ψ (.disj φ ψ)
  | disj_elim {φ ψ χ} : Derives φ χ → Derives ψ χ → Derives (.disj φ ψ) χ
  | disj_idem (φ) : Derives (.disj φ φ) φ
  | bot_elim (φ) : Derives .bot φ
  | conj_comm (φ ψ) : Derives (.conj φ ψ) (.conj ψ φ)
  | conj_unit_r (φ) : Derives (.conj φ .top) φ
  | conj_unit_r' (φ) : Derives φ (.conj φ .top)
  | conj_zero (φ) : Derives (.conj φ .bot) .bot
  | distrib (φ ψ χ) :
      Derives (.conj φ (.disj ψ χ)) (.disj (.conj φ ψ) (.conj φ χ))
  | distrib' (φ ψ χ) :
      Derives (.disj (.conj φ ψ) (.conj φ χ)) (.conj φ (.disj ψ χ))
  | conj_mono {φ φ' ψ ψ'} :
      Derives φ φ' → Derives ψ ψ' → Derives (.conj φ ψ) (.conj φ' ψ')
  | box_mono {φ ψ} : Derives φ ψ → Derives (.box φ) (.box ψ)
  | box_inflate (φ) : Derives φ (.box φ)
  | box_idem (φ) : Derives (.box (.box φ)) (.box φ)
  | box_disj (φ ψ) :
      Derives (.box (.disj φ ψ)) (.disj (.box φ) (.box ψ))
  | disj_box (φ ψ) :
      Derives (.disj (.box φ) (.box ψ)) (.box (.disj φ ψ))
  | box_mul (φ ψ) :
      Derives (.conj (.box φ) (.box ψ)) (.box (.conj φ ψ))

/-! ## §5. Soundness Theorem -/

section Soundness

variable {α : Type*} {S : Type*} [IdempCSR S] (cn : ClosureNucleus S)

/-- Helper: multiplication is monotone in both arguments. -/
private theorem mul_natLE_mono
    {a b c d : S} (h1 : IdempCSR.natLE a b) (h2 : IdempCSR.natLE c d) :
    IdempCSR.natLE (a * c) (b * d) :=
  IdempCSR.natLE_trans _ _ _
    (IdempCSR.mul_natLE_mul_right a b c h1)
    (IdempCSR.mul_natLE_mul_left c d b h2)

/-- The evaluation function respects the natLE ordering. -/
private theorem eval_natLE_of_derives (v : α → S) {φ ψ : PMF α}
    (h : Derives φ ψ) : IdempCSR.natLE (eval cn v φ) (eval cn v ψ) := by
  induction h with
  | refl _ => exact IdempCSR.natLE_refl _
  | trans _ _ ih1 ih2 => exact IdempCSR.natLE_trans _ _ _ ih1 ih2
  | disj_left _ _ => exact IdempCSR.add_natLE_right _ _
  | disj_right _ _ => exact IdempCSR.add_natLE_left _ _
  | disj_elim _ _ ih1 ih2 => exact IdempCSR.add_is_join _ _ _ ih1 ih2
  | disj_idem φ =>
    -- Goal: natLE (a + a) a, i.e., (a+a)+a = a
    have h := IdempCSR.add_idem (eval cn v φ)
    show (eval cn v φ + eval cn v φ) + eval cn v φ = eval cn v φ
    rw [h, h]
  | bot_elim _ => exact IdempCSR.zero_natLE _
  | conj_comm φ ψ =>
    show eval cn v φ * eval cn v ψ + eval cn v ψ * eval cn v φ =
      eval cn v ψ * eval cn v φ
    rw [mul_comm (eval cn v φ)]; exact IdempCSR.add_idem _
  | conj_unit_r φ =>
    show eval cn v φ * 1 + eval cn v φ = eval cn v φ
    rw [mul_one]; exact IdempCSR.add_idem _
  | conj_unit_r' φ =>
    show eval cn v φ + eval cn v φ * 1 = eval cn v φ * 1
    rw [mul_one]; exact IdempCSR.add_idem _
  | conj_zero φ =>
    show eval cn v φ * 0 + 0 = 0
    rw [mul_zero, zero_add]
  | distrib φ ψ χ =>
    show eval cn v φ * (eval cn v ψ + eval cn v χ) +
      (eval cn v φ * eval cn v ψ + eval cn v φ * eval cn v χ) =
      eval cn v φ * eval cn v ψ + eval cn v φ * eval cn v χ
    rw [mul_add]; exact IdempCSR.add_idem _
  | distrib' φ ψ χ =>
    show (eval cn v φ * eval cn v ψ + eval cn v φ * eval cn v χ) +
      eval cn v φ * (eval cn v ψ + eval cn v χ) =
      eval cn v φ * (eval cn v ψ + eval cn v χ)
    rw [mul_add]; exact IdempCSR.add_idem _
  | conj_mono _ _ ih1 ih2 => exact mul_natLE_mono ih1 ih2
  | box_mono _ ih => exact cn.mono _ _ ih
  | box_inflate _ => exact cn.le_c _
  | box_idem φ =>
    show cn.c (cn.c (eval cn v φ)) + cn.c (eval cn v φ) = cn.c (eval cn v φ)
    rw [cn.idem]; exact IdempCSR.add_idem _
  | box_disj φ ψ =>
    show cn.c (eval cn v φ + eval cn v ψ) +
      (cn.c (eval cn v φ) + cn.c (eval cn v ψ)) =
      cn.c (eval cn v φ) + cn.c (eval cn v ψ)
    rw [cn.map_add]; exact IdempCSR.add_idem _
  | disj_box φ ψ =>
    show (cn.c (eval cn v φ) + cn.c (eval cn v ψ)) +
      cn.c (eval cn v φ + eval cn v ψ) =
      cn.c (eval cn v φ + eval cn v ψ)
    rw [cn.map_add]; exact IdempCSR.add_idem _
  | box_mul _ _ => exact cn.mul_le _ _

/-- **Soundness (Theorem 2, forward direction)**:
    Every derivable entailment holds in all idempotent semiring models. -/
theorem soundness {φ ψ : PMF α} (h : Derives φ ψ) :
    ∀ v : α → S, IdempCSR.natLE (eval cn v φ) (eval cn v ψ) :=
  fun v => eval_natLE_of_derives cn v h

/-- **Soundness for stalk semantics**: derivable entailments
    are respected by prime congruences. -/
theorem stalk_soundness {φ ψ : PMF α}
    (h : Derives φ ψ) (P : PrimeClosureCong S cn) (v : α → S) :
    P.identifies (eval cn v φ + eval cn v ψ)
                 (eval cn v ψ) := by
  have hle := eval_natLE_of_derives cn v h
  simp [IdempCSR.natLE] at hle
  rw [hle]; exact P.r_refl _

end Soundness

end IdempotentStone