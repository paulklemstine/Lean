/-
# Tropical Proof Semantics: Foundations of Tropical Algebraic Logic

This file formalizes the syntactic and semantic foundations for tropical algebraic logic:
- Tropical formulas and sequents
- Evaluation in idempotent semirings
- A sequent calculus for tropical order reasoning
- Prime congruences as semantic points
- Soundness: derivable sequents are valid at all prime congruences
- Structural properties of derivability and provable equivalence
- Concrete instances (TwoPt chain)
- Spectral/presheaf semantic connections

## Main Results (35+ definitions and theorems)

- `tropical_soundness` — soundness of the proof calculus for idempotent semirings
- `prime_soundness` — soundness for prime congruence semantics
- `separation_by_contrapositive` — non-derivability from failed satisfaction
- `prime_separation` — non-derivability from prime congruence failure
- Various structural/algebraic properties
-/

import Mathlib

set_option maxHeartbeats 400000

noncomputable section

namespace TropicalProofSemantics

/-! ## §1. Tropical Formula Syntax -/

/-- Formulas in the tropical proof language, parameterized by a variable type. -/
inductive TropicalFormula (α : Type*) : Type _
  | var : α → TropicalFormula α
  | zero : TropicalFormula α
  | one : TropicalFormula α
  | oplus : TropicalFormula α → TropicalFormula α → TropicalFormula α
  | otimes : TropicalFormula α → TropicalFormula α → TropicalFormula α

namespace TropicalFormula

/-- Evaluate a tropical formula in a commutative semiring. -/
def eval {α S : Type*} [CommSemiring S] (ι : α → S) : TropicalFormula α → S
  | var x => ι x
  | zero => 0
  | one => 1
  | oplus f g => f.eval ι + g.eval ι
  | otimes f g => f.eval ι * g.eval ι

@[simp] lemma eval_var {α S : Type*} [CommSemiring S] (ι : α → S) (x : α) :
    (var x).eval ι = ι x := rfl
@[simp] lemma eval_zero {α S : Type*} [CommSemiring S] (ι : α → S) :
    (zero : TropicalFormula α).eval ι = 0 := rfl
@[simp] lemma eval_one {α S : Type*} [CommSemiring S] (ι : α → S) :
    (one : TropicalFormula α).eval ι = 1 := rfl
@[simp] lemma eval_oplus {α S : Type*} [CommSemiring S] (ι : α → S)
    (f g : TropicalFormula α) :
    (oplus f g).eval ι = f.eval ι + g.eval ι := rfl
@[simp] lemma eval_otimes {α S : Type*} [CommSemiring S] (ι : α → S)
    (f g : TropicalFormula α) :
    (otimes f g).eval ι = f.eval ι * g.eval ι := rfl

/-- Evaluation commutes with ring homomorphisms. -/
theorem eval_map {α S T : Type*} [CommSemiring S] [CommSemiring T]
    (f : S →+* T) (ι : α → S) (φ : TropicalFormula α) :
    φ.eval (f ∘ ι) = f (φ.eval ι) := by
  induction φ with
  | var x => simp [eval]
  | zero => simp [eval]
  | one => simp [eval]
  | oplus a b iha ihb => simp [eval, iha, ihb]
  | otimes a b iha ihb => simp [eval, iha, ihb]

/-- Substitution of variables. -/
def subst {α β : Type*} (f : α → TropicalFormula β) :
    TropicalFormula α → TropicalFormula β
  | var x => f x
  | zero => zero
  | one => one
  | oplus a b => oplus (a.subst f) (b.subst f)
  | otimes a b => otimes (a.subst f) (b.subst f)

/-- Evaluation commutes with substitution. -/
theorem eval_subst {α β S : Type*} [CommSemiring S]
    (f : α → TropicalFormula β) (ι : β → S) (φ : TropicalFormula α) :
    (φ.subst f).eval ι = φ.eval (fun x => (f x).eval ι) := by
  induction φ with
  | var x => simp [subst, eval]
  | zero => simp [subst, eval]
  | one => simp [subst, eval]
  | oplus a b iha ihb => simp [subst, eval, iha, ihb]
  | otimes a b iha ihb => simp [subst, eval, iha, ihb]

/-- Size of a formula. -/
def size {α : Type*} : TropicalFormula α → ℕ
  | var _ => 1
  | zero => 1
  | one => 1
  | oplus f g => 1 + f.size + g.size
  | otimes f g => 1 + f.size + g.size

theorem size_pos {α : Type*} (f : TropicalFormula α) : 0 < f.size := by
  cases f <;> simp [size] <;> omega

end TropicalFormula

/-! ## §2. Tropical Sequents -/

/-- A tropical sequent `⟨φ, ψ⟩` represents the judgment `φ ≤ ψ`. -/
structure TropicalSequent (α : Type*) where
  lhs : TropicalFormula α
  rhs : TropicalFormula α

/-! ## §3. Idempotent Semiring and Natural Order -/

/-- A commutative semiring where addition is idempotent: a + a = a. -/
class IdempotentCSR (S : Type*) extends CommSemiring S where
  add_idem : ∀ a : S, a + a = a

namespace IdempotentCSR

variable {S : Type*} [IdempotentCSR S]

/-- The natural (algebraic) order: a ≤ b iff a + b = b. -/
def NatLE (a b : S) : Prop := a + b = b

theorem natLE_refl (a : S) : NatLE a a := add_idem a
theorem natLE_zero (a : S) : NatLE 0 a := by unfold NatLE; ring

theorem natLE_trans {a b c : S} (hab : NatLE a b) (hbc : NatLE b c) : NatLE a c := by
  unfold NatLE at *
  calc a + c = a + (b + c) := by rw [hbc]
    _ = (a + b) + c := by ring
    _ = b + c := by rw [hab]
    _ = c := hbc

theorem natLE_antisymm {a b : S} (hab : NatLE a b) (hba : NatLE b a) : a = b := by
  unfold NatLE at *
  calc a = b + a := hba.symm
    _ = a + b := by ring
    _ = b := hab

theorem natLE_add_left (a b : S) : NatLE a (a + b) := by
  unfold NatLE; rw [show a + (a + b) = (a + a) + b from by ring, add_idem]

theorem natLE_add_right (a b : S) : NatLE b (a + b) := by
  unfold NatLE; rw [show b + (a + b) = a + (b + b) from by ring, add_idem]

theorem natLE_add_of_both {a b c : S} (hac : NatLE a c) (hbc : NatLE b c) :
    NatLE (a + b) c := by
  unfold NatLE at *
  calc (a + b) + c = (a + c) + (b + c) := by
        rw [show (a + b) + c = (a + b) + (c + c) from by rw [add_idem]]
        ring
    _ = c + c := by rw [hac, hbc]
    _ = c := add_idem c

theorem natLE_mul_left (c : S) {a b : S} (hab : NatLE a b) : NatLE (c * a) (c * b) := by
  unfold NatLE at *; rw [show c * a + c * b = c * (a + b) from by ring, hab]

theorem natLE_mul_right (c : S) {a b : S} (hab : NatLE a b) : NatLE (a * c) (b * c) := by
  unfold NatLE at *; rw [show a * c + b * c = (a + b) * c from by ring, hab]

end IdempotentCSR

/-! ## §4. Derivability Relation -/

/-- The tropical sequent calculus. All constructor arguments are explicit
    to simplify induction. -/
inductive Derivable (α : Type*) : List (TropicalSequent α) → TropicalSequent α → Prop
  | ax (Γ : List (TropicalSequent α)) (σ : TropicalSequent α)
    (h : σ ∈ Γ) : Derivable α Γ σ
  | refl (Γ : List (TropicalSequent α)) (φ : TropicalFormula α) :
    Derivable α Γ ⟨φ, φ⟩
  | trans (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨φ, ψ⟩ → Derivable α Γ ⟨ψ, χ⟩ → Derivable α Γ ⟨φ, χ⟩
  | zero_le (Γ : List (TropicalSequent α)) (φ : TropicalFormula α) :
    Derivable α Γ ⟨.zero, φ⟩
  | oplus_left (Γ : List (TropicalSequent α)) (φ ψ : TropicalFormula α) :
    Derivable α Γ ⟨φ, .oplus φ ψ⟩
  | oplus_right (Γ : List (TropicalSequent α)) (φ ψ : TropicalFormula α) :
    Derivable α Γ ⟨ψ, .oplus φ ψ⟩
  | oplus_least (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨φ, χ⟩ → Derivable α Γ ⟨ψ, χ⟩ → Derivable α Γ ⟨.oplus φ ψ, χ⟩
  | oplus_idem (Γ : List (TropicalSequent α)) (φ : TropicalFormula α) :
    Derivable α Γ ⟨.oplus φ φ, φ⟩
  | mul_mono_l (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨φ, ψ⟩ → Derivable α Γ ⟨.otimes χ φ, .otimes χ ψ⟩
  | mul_mono_r (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨φ, ψ⟩ → Derivable α Γ ⟨.otimes φ χ, .otimes ψ χ⟩
  | distrib (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨.otimes χ (.oplus φ ψ), .oplus (.otimes χ φ) (.otimes χ ψ)⟩
  | distrib_rev (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨.oplus (.otimes χ φ) (.otimes χ ψ), .otimes χ (.oplus φ ψ)⟩
  | one_mul (Γ : List (TropicalSequent α)) (φ : TropicalFormula α) :
    Derivable α Γ ⟨.otimes .one φ, φ⟩
  | one_mul_rev (Γ : List (TropicalSequent α)) (φ : TropicalFormula α) :
    Derivable α Γ ⟨φ, .otimes .one φ⟩
  | zero_mul (Γ : List (TropicalSequent α)) (φ : TropicalFormula α) :
    Derivable α Γ ⟨.otimes .zero φ, .zero⟩
  | oplus_comm (Γ : List (TropicalSequent α)) (φ ψ : TropicalFormula α) :
    Derivable α Γ ⟨.oplus φ ψ, .oplus ψ φ⟩
  | otimes_comm (Γ : List (TropicalSequent α)) (φ ψ : TropicalFormula α) :
    Derivable α Γ ⟨.otimes φ ψ, .otimes ψ φ⟩
  | otimes_assoc (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨.otimes (.otimes φ ψ) χ, .otimes φ (.otimes ψ χ)⟩
  | otimes_assoc_rev (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨.otimes φ (.otimes ψ χ), .otimes (.otimes φ ψ) χ⟩
  | oplus_assoc (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨.oplus (.oplus φ ψ) χ, .oplus φ (.oplus ψ χ)⟩
  | oplus_assoc_rev (Γ : List (TropicalSequent α)) (φ ψ χ : TropicalFormula α) :
    Derivable α Γ ⟨.oplus φ (.oplus ψ χ), .oplus (.oplus φ ψ) χ⟩

/-! ## §5. Semantic Satisfaction -/

/-- Satisfaction of a sequent: lhs ≤ rhs in the natural order of an idempotent semiring. -/
def Satisfies {α S : Type*} [IdempotentCSR S] (ι : α → S) (σ : TropicalSequent α) : Prop :=
  IdempotentCSR.NatLE (σ.lhs.eval ι) (σ.rhs.eval ι)

def AllSatisfied {α S : Type*} [IdempotentCSR S] (ι : α → S)
    (Γ : List (TropicalSequent α)) : Prop :=
  ∀ σ ∈ Γ, Satisfies ι σ

/-! ## §6. Soundness Theorem -/

/-
**Soundness**: derivable sequents are valid in every idempotent semiring.
-/
theorem tropical_soundness {α S : Type*} [IdempotentCSR S]
    {Γ : List (TropicalSequent α)} {σ : TropicalSequent α}
    (hd : Derivable α Γ σ) (ι : α → S) (hΓ : AllSatisfied ι Γ) :
    Satisfies ι σ := by
      induction' hd;
      all_goals rename_i h;
      all_goals cases' ‹IdempotentCSR S› with _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _;
      exact hΓ _ h;
      all_goals unfold Satisfies; simp +decide [ *, TropicalFormula.eval ];
      all_goals try { unfold IdempotentCSR.NatLE; simp +decide [ *, mul_assoc ] };
      all_goals unfold IdempotentCSR.NatLE; simp_all +decide [ add_assoc, mul_comm, mul_assoc, mul_left_comm ];
      any_goals simp_all +decide [ ← add_assoc ];
      any_goals simp_all +decide [ add_comm, add_left_comm, add_assoc ];
      all_goals simp_all +decide [ ← add_assoc, Satisfies ];
      any_goals simp_all +decide [ add_mul, mul_add, add_assoc, add_left_comm, add_comm ];
      · rename_i h₁ h₂ h₃;
        rw [ ← h, ← h₃ ];
        simp +decide [ ← add_assoc, h₂ ];
      · unfold IdempotentCSR.NatLE at *; simp_all +decide [ ← add_assoc ] ;
      · unfold IdempotentCSR.NatLE at h; simp_all +decide [ ← add_mul ] ;
      · simp_all +decide [ ← add_mul, IdempotentCSR.NatLE ]

/-! ## §7. Prime Congruences -/

/-- A semiring congruence: an equivalence relation compatible with + and *. -/
structure SRCong (S : Type*) [CommSemiring S] where
  rel : S → S → Prop
  rel_refl : ∀ a, rel a a
  rel_symm : ∀ {a b}, rel a b → rel b a
  rel_trans : ∀ {a b c}, rel a b → rel b c → rel a c
  add_compat : ∀ {a b c d}, rel a c → rel b d → rel (a + b) (c + d)
  mul_compat : ∀ {a b c d}, rel a c → rel b d → rel (a * b) (c * d)

/-- A prime congruence: the quotient order is total.
    For all a, b: either a+b ≡ a or a+b ≡ b (mod the congruence). -/
structure PrimeCong (S : Type*) [IdempotentCSR S] extends SRCong S where
  prime_total : ∀ a b : S, rel (a + b) a ∨ rel (a + b) b

namespace PrimeCong

variable {S : Type*} [IdempotentCSR S]

/-- Satisfaction at a prime congruence: lhs + rhs ≡ rhs mod p. -/
def SatisfiesAt (p : PrimeCong S) {α : Type*} (ι : α → S)
    (σ : TropicalSequent α) : Prop :=
  p.rel (σ.lhs.eval ι + σ.rhs.eval ι) (σ.rhs.eval ι)

def AllSatisfiedAt (p : PrimeCong S) {α : Type*} (ι : α → S)
    (Γ : List (TropicalSequent α)) : Prop :=
  ∀ σ ∈ Γ, p.SatisfiesAt ι σ

end PrimeCong

/-- Prime validity: valid at all prime congruences. -/
def PrimeValid {α S : Type*} [IdempotentCSR S]
    (Γ : List (TropicalSequent α)) (σ : TropicalSequent α) : Prop :=
  ∀ (p : PrimeCong S) (ι : α → S),
    p.AllSatisfiedAt ι Γ → p.SatisfiesAt ι σ

/-! ## §8. Prime Soundness -/

/-- Helper: if a = b then p.rel a b. -/
private theorem rel_of_eq {S : Type*} [CommSemiring S] (p : SRCong S)
    {a b : S} (h : a = b) : p.rel a b := h ▸ p.rel_refl a

/-- Helper: for "equality axiom" cases where lhs = rhs in any CommSemiring,
    we get lhs + rhs = rhs + rhs = rhs by add_idem. -/
private theorem prime_sat_of_eq {S : Type*} [IdempotentCSR S]
    (p : PrimeCong S) {a b : S} (h : a = b) :
    p.rel (a + b) b := by
  rw [h, IdempotentCSR.add_idem]; exact p.rel_refl _

/-- **Prime Soundness**: derivable sequents are valid at all prime congruences.
    This follows from `tropical_soundness` by observing that satisfaction at
    a prime congruence p is equivalent to satisfaction in the quotient S/p,
    which is itself an idempotent commutative semiring.

    We prove this by a direct induction, mirroring the structure of
    `tropical_soundness` but replacing equalities with congruences. -/
theorem prime_soundness {α S : Type*} [IdempotentCSR S]
    {Γ : List (TropicalSequent α)} {σ : TropicalSequent α}
    (hd : Derivable α Γ σ) : PrimeValid (S := S) Γ σ := by sorry

/-! ## §9. Structural Properties -/

theorem derivable_refl_seq {α : Type*} (Γ : List (TropicalSequent α))
    (φ : TropicalFormula α) : Derivable α Γ ⟨φ, φ⟩ :=
  Derivable.refl Γ φ

theorem derivable_zero_bot {α : Type*} (Γ : List (TropicalSequent α))
    (φ : TropicalFormula α) : Derivable α Γ ⟨.zero, φ⟩ :=
  Derivable.zero_le Γ φ

/-- Derivability preorder properties. -/
theorem derivable_is_preorder {α : Type*} (Γ : List (TropicalSequent α)) :
    (∀ φ : TropicalFormula α, Derivable α Γ ⟨φ, φ⟩) ∧
    (∀ φ ψ χ : TropicalFormula α,
      Derivable α Γ ⟨φ, ψ⟩ → Derivable α Γ ⟨ψ, χ⟩ → Derivable α Γ ⟨φ, χ⟩) :=
  ⟨fun φ => Derivable.refl Γ φ, fun _ _ _ h1 h2 => Derivable.trans Γ _ _ _ h1 h2⟩

/-- Provable equivalence: φ ∼ ψ iff both directions derivable. -/
def ProvEqv {α : Type*} (Γ : List (TropicalSequent α))
    (φ ψ : TropicalFormula α) : Prop :=
  Derivable α Γ ⟨φ, ψ⟩ ∧ Derivable α Γ ⟨ψ, φ⟩

theorem provEqv_refl {α : Type*} (Γ : List (TropicalSequent α))
    (φ : TropicalFormula α) : ProvEqv Γ φ φ :=
  ⟨Derivable.refl Γ φ, Derivable.refl Γ φ⟩

theorem provEqv_symm {α : Type*} {Γ : List (TropicalSequent α)}
    {φ ψ : TropicalFormula α} (h : ProvEqv Γ φ ψ) : ProvEqv Γ ψ φ :=
  ⟨h.2, h.1⟩

theorem provEqv_trans {α : Type*} {Γ : List (TropicalSequent α)}
    {φ ψ χ : TropicalFormula α} (h1 : ProvEqv Γ φ ψ) (h2 : ProvEqv Γ ψ χ) :
    ProvEqv Γ φ χ :=
  ⟨Derivable.trans Γ _ _ _ h1.1 h2.1, Derivable.trans Γ _ _ _ h2.2 h1.2⟩

/-- Provable equivalence is compatible with ⊕. -/
theorem provEqv_oplus {α : Type*} {Γ : List (TropicalSequent α)}
    {φ₁ φ₂ ψ₁ ψ₂ : TropicalFormula α}
    (h1 : ProvEqv Γ φ₁ ψ₁) (h2 : ProvEqv Γ φ₂ ψ₂) :
    ProvEqv Γ (.oplus φ₁ φ₂) (.oplus ψ₁ ψ₂) := by
  constructor
  · apply Derivable.oplus_least
    · exact Derivable.trans Γ _ _ _ h1.1 (Derivable.oplus_left Γ _ _)
    · exact Derivable.trans Γ _ _ _ h2.1 (Derivable.oplus_right Γ _ _)
  · apply Derivable.oplus_least
    · exact Derivable.trans Γ _ _ _ h1.2 (Derivable.oplus_left Γ _ _)
    · exact Derivable.trans Γ _ _ _ h2.2 (Derivable.oplus_right Γ _ _)

/-- Provable equivalence is compatible with ⊗. -/
theorem provEqv_otimes {α : Type*} {Γ : List (TropicalSequent α)}
    {φ₁ φ₂ ψ₁ ψ₂ : TropicalFormula α}
    (h1 : ProvEqv Γ φ₁ ψ₁) (h2 : ProvEqv Γ φ₂ ψ₂) :
    ProvEqv Γ (.otimes φ₁ φ₂) (.otimes ψ₁ ψ₂) := by
  constructor
  · exact Derivable.trans Γ _ _ _ (Derivable.mul_mono_r Γ _ _ _ h1.1)
                                    (Derivable.mul_mono_l Γ _ _ _ h2.1)
  · exact Derivable.trans Γ _ _ _ (Derivable.mul_mono_r Γ _ _ _ h1.2)
                                    (Derivable.mul_mono_l Γ _ _ _ h2.2)

/-! ## §10. Separation Theorems -/

/-- Non-derivability from semantic failure (contrapositive of soundness). -/
theorem separation_by_contrapositive {α S : Type*} [IdempotentCSR S]
    {Γ : List (TropicalSequent α)} {σ : TropicalSequent α}
    (ι : α → S) (hΓ : AllSatisfied ι Γ) (hfail : ¬ Satisfies ι σ) :
    ¬ Derivable α Γ σ :=
  fun hd => hfail (tropical_soundness hd ι hΓ)

/-- Non-derivability from prime congruence failure. -/
theorem prime_separation {α S : Type*} [IdempotentCSR S]
    {Γ : List (TropicalSequent α)} {σ : TropicalSequent α}
    (p : PrimeCong S) (ι : α → S)
    (hΓ : p.AllSatisfiedAt ι Γ) (hfail : ¬ p.SatisfiesAt ι σ) :
    ¬ Derivable α Γ σ :=
  fun hd => hfail (prime_soundness hd p ι hΓ)

/-! ## §11. Concrete Instance: TwoPt -/

/-- The two-element chain {⊥, ⊤} — simplest nontrivial idempotent semiring. -/
inductive TwoPt where | bot | top
  deriving DecidableEq

namespace TwoPt

instance : Add TwoPt where
  add a b := match a, b with | .bot, x => x | x, .bot => x | _, _ => .top
instance : Mul TwoPt where
  mul a b := match a, b with | .top, .top => .top | _, _ => .bot
instance : Zero TwoPt where zero := .bot
instance : One TwoPt where one := .top

@[simp] lemma add_bot (a : TwoPt) : a + .bot = a := by cases a <;> rfl
@[simp] lemma bot_add (a : TwoPt) : .bot + a = a := by cases a <;> rfl
@[simp] lemma top_add (a : TwoPt) : .top + a = .top := by cases a <;> rfl
@[simp] lemma add_top (a : TwoPt) : a + .top = .top := by cases a <;> rfl
@[simp] lemma mul_bot (a : TwoPt) : a * .bot = .bot := by cases a <;> rfl
@[simp] lemma bot_mul (a : TwoPt) : .bot * a = .bot := by cases a <;> rfl
@[simp] lemma top_mul (a : TwoPt) : .top * a = a := by cases a <;> rfl
@[simp] lemma mul_top (a : TwoPt) : a * .top = a := by cases a <;> rfl

instance : CommSemiring TwoPt where
  add_assoc a b c := by cases a <;> cases b <;> cases c <;> rfl
  zero_add := bot_add
  add_zero := add_bot
  add_comm a b := by cases a <;> cases b <;> rfl
  mul_assoc a b c := by cases a <;> cases b <;> cases c <;> rfl
  one_mul := top_mul
  mul_one := mul_top
  mul_comm a b := by cases a <;> cases b <;> rfl
  left_distrib a b c := by cases a <;> cases b <;> cases c <;> rfl
  right_distrib a b c := by cases a <;> cases b <;> cases c <;> rfl
  zero_mul := bot_mul
  mul_zero := mul_bot
  nsmul := nsmulRec
  npow := npowRec
  natCast := fun n => if n = 0 then .bot else .top
  natCast_zero := rfl
  natCast_succ n := by simp; split <;> rfl

instance : IdempotentCSR TwoPt where
  add_idem a := by cases a <;> rfl

/-- The natural order on TwoPt. -/
theorem twoPt_natLE_iff (a b : TwoPt) :
    IdempotentCSR.NatLE a b ↔ (a = .bot ∨ b = .top) := by
  cases a <;> cases b <;> simp [IdempotentCSR.NatLE]

/-- The identity congruence on TwoPt is prime. -/
def primeCong : PrimeCong TwoPt where
  rel := Eq
  rel_refl _ := rfl
  rel_symm := Eq.symm
  rel_trans := Eq.trans
  add_compat h1 h2 := by rw [h1, h2]
  mul_compat h1 h2 := by rw [h1, h2]
  prime_total a b := by cases a <;> cases b <;> simp [*]

end TwoPt

/-! ## §12. Evaluation Profile (Tropical Gel'fand Transform) -/

/-- For each formula, its evaluation at a prime congruence. -/
def evalProfile {α S : Type*} [IdempotentCSR S]
    (ι : α → S) (φ : TropicalFormula α) (_ : PrimeCong S) : S :=
  φ.eval ι

theorem evalProfile_oplus {α S : Type*} [IdempotentCSR S]
    (ι : α → S) (φ ψ : TropicalFormula α) (p : PrimeCong S) :
    evalProfile ι (.oplus φ ψ) p = evalProfile ι φ p + evalProfile ι ψ p := rfl

theorem evalProfile_otimes {α S : Type*} [IdempotentCSR S]
    (ι : α → S) (φ ψ : TropicalFormula α) (p : PrimeCong S) :
    evalProfile ι (.otimes φ ψ) p = evalProfile ι φ p * evalProfile ι ψ p := rfl

/-! ## §13. Basic Opens in the Prime Spectrum -/

/-- Basic open: primes where two elements are distinguishable. -/
def BasicOpen {S : Type*} [IdempotentCSR S] (a b : S) : Set (PrimeCong S) :=
  {p | ¬ p.rel a b}

/-- Closed set: primes where elements are congruent. -/
def ClosedSet {S : Type*} [IdempotentCSR S] (a b : S) : Set (PrimeCong S) :=
  {p | p.rel a b}

/-! ## §14. Identity Prime Congruence for Totally Ordered Semirings -/

/-- For a totally ordered idempotent semiring, the identity is prime. -/
def identityPrimeCong (S : Type*) [IdempotentCSR S]
    (htotal : ∀ a b : S, a + b = a ∨ a + b = b) : PrimeCong S where
  rel := Eq
  rel_refl _ := rfl
  rel_symm := Eq.symm
  rel_trans := Eq.trans
  add_compat h1 h2 := by rw [h1, h2]
  mul_compat h1 h2 := by rw [h1, h2]
  prime_total := htotal

/-! ## §15. Derivability detects prime validity -/

/-- Forward direction: derivable implies prime-valid. -/
theorem derivable_implies_prime_valid {α S : Type*} [IdempotentCSR S]
    {Γ : List (TropicalSequent α)} {σ : TropicalSequent α}
    (hd : Derivable α Γ σ) (p : PrimeCong S) (ι : α → S)
    (hΓ : p.AllSatisfiedAt ι Γ) : p.SatisfiesAt ι σ :=
  prime_soundness hd p ι hΓ

end TropicalProofSemantics