import Logic.PosetTheory.TemporalGL

/-!
# Verified boundaries for temporal provability

This file builds on `TemporalGL.TempFrame` and `GLPLogic.MFormula`.  It isolates two
facts relevant to the proposed temporal extension.

First, on reflexive temporal frames the proposed interaction formula
`□A → □□◇ₜA` factors through the ordinary GL axiom `4`, `□A → □□A`, followed by
`A → ◇ₜA`.  Thus this formula by itself does not witness a strict extension of GL.
Second, the claimed paradox splits into two inequivalent readings: losing an
established proof is refutable, while gaining a proof later is satisfiable.  These
results do not assert the requested arithmetical completeness theorem for PA.
-/

namespace TemporalProofLogic

open TemporalGL

variable {W α : Type*}

/-- A temporal formula language extending ordinary modal formulas by global and
future operators. -/
inductive Formula (α : Type*) where
  | atom : α → Formula α
  | bot : Formula α
  | imp : Formula α → Formula α → Formula α
  | box : Formula α → Formula α
  | glob : Formula α → Formula α
  | fut : Formula α → Formula α
  deriving DecidableEq

namespace Formula

/-- Negation in the implication/bottom basis. -/
def neg (A : Formula α) : Formula α := .imp A .bot

/-- The proposed temporal interaction formula `□A → □□◇ₜA`. -/
def tgl (A : Formula α) : Formula α := .imp (.box A) (.box (.box (.fut A)))

end Formula

/-- Kripke semantics on the catalog's temporal GL frames. -/
def Forces (F : TempFrame) (V : α → F.W → Prop) : F.W → Formula α → Prop
  | w, .atom a => V a w
  | _, .bot => False
  | w, .imp A B => Forces F V w A → Forces F V w B
  | w, .box A => Box F.R (fun v => Forces F V v A) w
  | w, .glob A => Glob F.T (fun v => Forces F V v A) w
  | w, .fut A => Fut F.T (fun v => Forces F V v A) w

/-- The formula-level proposed TGL axiom is sound on every catalog temporal frame. -/
theorem tgl_formula_sound (F : TempFrame) (V : α → F.W → Prop)
    (A : Formula α) (w : F.W) : Forces F V w (Formula.tgl A) := by
  intro h
  exact tgl_axiom_sound F (fun v => Forces F V v A) w h

/-- The temporal interaction principle needs only transitivity of proof accessibility
and reflexivity of time; neither converse well-foundedness nor temporal compatibility
is used. -/
theorem tgl_of_four_and_time_reflexivity
    (R T : W → W → Prop) (hR : Transitive R) (hT : Reflexive T)
    (A : W → Prop) (w : W) (hA : Box R A w) :
    Box R (Box R (Fut T A)) w := by
  intro v hwv u hvu
  exact ⟨u, hT u, hA u (hR hwv hvu)⟩

/-- Explicit factorization: ordinary axiom `4` supplies `□□A`, and temporal
reflexivity maps its innermost `A` to `◇ₜA`. -/
theorem tgl_factors_through_four (F : TempFrame) (A : F.W → Prop) (w : F.W)
    (hA : Box F.R A w) :
    (Box F.R (Box F.R A) w) ∧ Box F.R (Box F.R (Fut F.T A)) w := by
  refine ⟨four_box_sound F A w hA, ?_⟩
  intro v hwv u hvu
  exact ⟨u, F.T_refl u, hA u (F.R_trans hwv hvu)⟩

/-- Persistence rules out losing a proof at any specified later stage. -/
theorem no_proof_loss_at_later_stage (F : TempFrame) (A : F.W → Prop)
    {today tomorrow : F.W} (ht : F.T today tomorrow) :
    ¬ (Box F.R A today ∧ ¬ Box F.R A tomorrow) := by
  rintro ⟨hnow, hlater⟩
  exact hlater (provability_persists F A today hnow tomorrow ht)

/-- In contrast, gaining a proof later is realizable.  Therefore the non-self-
referential reading “provable tomorrow but not today” is not refutable by these
semantics. -/
theorem proof_gain_is_satisfiable :
    ∃ (F : TempFrame) (A : F.W → Prop) (today tomorrow : F.W),
      F.T today tomorrow ∧ ¬ Box F.R A today ∧ Box F.R A tomorrow :=
  tomorrow_not_today_satisfiable

end TemporalProofLogic