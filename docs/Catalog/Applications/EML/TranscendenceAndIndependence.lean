import Mathlib
import Bridges.PosetTheory.EMLInterpolation

/-!
# EML numbers: transcendence and algebraic independence

This file builds on the catalog's `EMLExpr` syntax.  It isolates the fragment whose
constants are rational, and the exp--log subfragment in which multiplication nodes
are absent.  Their values at `0` are called respectively EML and EL numbers.

The conjectural input is stated as `EMLSchanuel`: its first clause is the algebraic
independence prediction needed by the concrete depth-two example, while its second
clause is the functional multiplication-elimination prediction.  Keeping these as
fields makes every use of conjectural mathematics explicit.

No unconditional transcendence claim is made for
`exp (exp 1) + log 2`: that assertion is currently beyond known transcendence
methods.  We prove it from the stated algebraic-independence clause, and prove the
EML/EL equality from the elimination clause.
-/

noncomputable section

open scoped BigOperators

namespace EMLTranscendence

/-- EML expressions all of whose constants come from `ℚ`. -/
inductive RationalEML : EMLExpr → Prop
  | const (q : ℚ) : RationalEML (.const (q : ℝ))
  | var : RationalEML .var
  | exp {e} : RationalEML e → RationalEML (.exp e)
  | log {e} : RationalEML e → RationalEML (.log e)
  | add {e₁ e₂} : RationalEML e₁ → RationalEML e₂ → RationalEML (.add e₁ e₂)
  | mul {e₁ e₂} : RationalEML e₁ → RationalEML e₂ → RationalEML (.mul e₁ e₂)

/-- The rational exp--log fragment: the same catalog syntax, without multiplication nodes. -/
inductive RationalEL : EMLExpr → Prop
  | const (q : ℚ) : RationalEL (.const (q : ℝ))
  | var : RationalEL .var
  | exp {e} : RationalEL e → RationalEL (.exp e)
  | log {e} : RationalEL e → RationalEL (.log e)
  | add {e₁ e₂} : RationalEL e₁ → RationalEL e₂ → RationalEL (.add e₁ e₂)

/-- Values of closed rational EML expressions (the distinguished variable is set to `0`). -/
def EMLNumbers : Set ℝ :=
  {x | ∃ e : EMLExpr, RationalEML e ∧ e.eval 0 = x}

/-- Values of closed rational EL expressions (the distinguished variable is set to `0`). -/
def ELNumbers : Set ℝ :=
  {x | ∃ e : EMLExpr, RationalEL e ∧ e.eval 0 = x}

/-- Every rational EL expression is, in particular, a rational EML expression. -/
theorem RationalEL.toRationalEML {e : EMLExpr} (h : RationalEL e) : RationalEML e := by
  induction h with
  | const q => exact RationalEML.const q
  | var => exact RationalEML.var
  | exp _ ih => exact RationalEML.exp ih
  | log _ ih => exact RationalEML.log ih
  | add _ _ ih₁ ih₂ => exact RationalEML.add ih₁ ih₂

/-- The EL numbers form a subclass of the EML numbers. -/
theorem elNumbers_subset_emlNumbers : ELNumbers ⊆ EMLNumbers := by
  rintro x ⟨e, he, rfl⟩
  exact ⟨e, he.toRationalEML, rfl⟩

/-- The concrete catalog expression `exp(exp(1)) + log(2)`. -/
def expExpOneAddLogTwoExpr : EMLExpr :=
  .add (.exp (.exp (.const ((1 : ℚ) : ℝ)))) (.log (.const ((2 : ℚ) : ℝ)))

/-- Evaluation of the concrete EML expression. -/
theorem expExpOneAddLogTwoExpr_eval :
    expExpOneAddLogTwoExpr.eval 0 = Real.exp (Real.exp 1) + Real.log 2 := by
  simp [expExpOneAddLogTwoExpr, EMLExpr.eval]

/-- The concrete number is represented by a rational EML expression. -/
theorem expExpOneAddLogTwo_mem_emlNumbers :
    Real.exp (Real.exp 1) + Real.log 2 ∈ EMLNumbers := by
  refine ⟨expExpOneAddLogTwoExpr, ?_, expExpOneAddLogTwoExpr_eval⟩
  exact RationalEML.add
    (RationalEML.exp (RationalEML.exp (RationalEML.const 1)))
    (RationalEML.log (RationalEML.const 2))

/-- The two generators occurring in the concrete transcendence assertion. -/
def concreteGenerators : Bool → ℝ :=
  fun b => cond b (Real.log 2) (Real.exp (Real.exp 1))

/-- Classical Schanuel conjecture over the real numbers: a finite
`ℚ`-linearly-independent family `z` should generate, together with its coordinatewise
exponentials, a field of transcendence degree at least the size of the family. -/
def SchanuelConjecture : Prop :=
  ∀ (n : ℕ) (z : Fin n → ℝ), LinearIndependent ℚ z →
    (n : Cardinal) ≤ Algebra.trdeg ℚ
      (FractionRing (Algebra.adjoin ℚ
        (Set.range z ∪ Set.range (fun i => Real.exp (z i)))))

/-- Functional EML strengthening of Schanuel's conjecture used in this development.

Besides the classical conjecture, it records two explicit predictions for the
catalog language.  `concrete_independence` is the algebraic-independence statement
needed by the depth-two example.  `multiplication_elimination` says that every
rational EML expression has an extensionally equivalent rational EL expression.
The extra fields are stated separately rather than incorrectly claiming that their
nontrivial derivation from classical Schanuel has already been formalized. -/
structure EMLSchanuel : Prop where
  schanuel : SchanuelConjecture
  concrete_independence : AlgebraicIndependent ℚ concreteGenerators
  multiplication_elimination :
    ∀ e : EMLExpr, RationalEML e →
      ∃ f : EMLExpr, RationalEL f ∧ ∀ x : ℝ, f.eval x = e.eval x

/-- Algebraic independence of two elements forces their sum to be transcendental. -/
theorem transcendental_add_of_algebraicIndependent_bool
    {x y : ℝ} (h : AlgebraicIndependent ℚ (fun b : Bool => cond b y x)) :
    Transcendental ℚ (x + y) := by
  rw [transcendental_iff]
  intro p hp
  let q : MvPolynomial Bool ℚ :=
    Polynomial.aeval (MvPolynomial.X false + MvPolynomial.X true) p
  have hcomp :
      (MvPolynomial.aeval (fun b : Bool => cond b y x)).comp
          (Polynomial.aeval (R := ℚ)
            (MvPolynomial.X false + MvPolynomial.X true : MvPolynomial Bool ℚ)) =
        Polynomial.aeval (x + y) := by
    ext
    simp
  have hqeval : MvPolynomial.aeval (fun b : Bool => cond b y x) q = 0 := by
    dsimp [q]
    rw [← AlgHom.comp_apply, hcomp]
    exact hp
  have hq : q = 0 := h.eq_zero_of_aeval_eq_zero q hqeval
  have hcomp' :
      (MvPolynomial.aeval (fun b : Bool => cond b (0 : Polynomial ℚ) Polynomial.X)).comp
          (Polynomial.aeval (R := ℚ)
            (MvPolynomial.X false + MvPolynomial.X true : MvPolynomial Bool ℚ)) =
        AlgHom.id ℚ (Polynomial ℚ) := by
    ext
    simp
  have hretract := congrArg
    (MvPolynomial.aeval (fun b : Bool => cond b (0 : Polynomial ℚ) Polynomial.X)) hq
  dsimp [q] at hretract
  rw [← AlgHom.comp_apply, hcomp'] at hretract
  simpa using hretract

/-- **Conditional concrete result.**  Under the EML Schanuel conjecture,
`exp(exp(1)) + log(2)` is transcendental over `ℚ`. -/
theorem expExpOneAddLogTwo_transcendental (hSC : EMLSchanuel) :
    Transcendental ℚ (Real.exp (Real.exp 1) + Real.log 2) := by
  apply transcendental_add_of_algebraicIndependent_bool
  simpa [concreteGenerators] using hSC.concrete_independence

/-- The multiplication-elimination clause gives the difficult inclusion from
EML numbers to EL numbers. -/
theorem emlNumbers_subset_elNumbers (hSC : EMLSchanuel) :
    EMLNumbers ⊆ ELNumbers := by
  rintro x ⟨e, he, rfl⟩
  obtain ⟨f, hf, hfe⟩ := hSC.multiplication_elimination e he
  exact ⟨f, hf, hfe 0⟩

/-- **Conditional class equality.**  Under the functional EML Schanuel conjecture,
the class of rational EML numbers equals the class of rational EL numbers. -/
theorem emlNumbers_eq_elNumbers (hSC : EMLSchanuel) :
    EMLNumbers = ELNumbers := by
  apply Set.Subset.antisymm
  · exact emlNumbers_subset_elNumbers hSC
  · exact elNumbers_subset_emlNumbers

end EMLTranscendence