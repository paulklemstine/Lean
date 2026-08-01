import Mathlib
import EML.KolmogorovComplexityBound
import NumberTheory.EMLAlgebraicIndependence

/-!
# Conditional transcendence for a concrete EML number

This file uses the catalog's existing `EMLKolmogorov.ETerm` syntax.  It separates
what is presently unconditional (the number has an EML expression) from the exact
algebraic-independence consequence needed to prove transcendence.

The unconditional transcendence of `exp (exp 1) + log 2` is not known.  In
particular, it must not be presented as a consequence of Lindemann--Weierstrass:
that theorem does not control this sum.  `SchanuelConjecture` below is a finite,
family-based formulation of Schanuel's conjecture; the proved transcendence theorem
uses the indicated algebraic-independence specialization explicitly.
-/

noncomputable section

open scoped BigOperators

namespace EMLTranscendence

open EMLKolmogorov EMLKolmogorov.ETerm

/-- The concrete EML number requested in the mission. -/
def concreteValue : ℝ := Real.exp (Real.exp 1) + Real.log 2

/-- An existing catalog EML term denoting `exp (exp 1) + log 2` at input `1`.
No new expression language is introduced. -/
def concreteTerm : ETerm :=
  ETerm.add (ETerm.expOf (ETerm.expOf ETerm.var))
    (ETerm.logOf (ETerm.add ETerm.var ETerm.var))

/-- The concrete number is represented by the catalog's EML syntax. -/
theorem concreteTerm_eval : concreteTerm.eval 1 = concreteValue := by
  norm_num [concreteTerm, ETerm.eval, concreteValue]

/-- A finite-family formulation of Schanuel's conjecture over the complex numbers.
For every `ℚ`-linearly independent `n`-tuple, the family consisting of its entries
and their exponentials contains an algebraically independent `n`-subfamily.
This is a standard transcendence-degree-at-least-`n` formulation, expressed without
introducing a separate transcendence-degree API. -/
def SchanuelConjecture : Prop :=
  ∀ (n : ℕ) (z : Fin n → ℂ), LinearIndependent ℚ z →
    ∃ (s : Finset (Fin n ⊕ Fin n)), s.card = n ∧
      AlgebraicIndependent ℚ (fun i : s ↦
        Sum.elim z (fun j ↦ Complex.exp (z j)) i.1)

/-- The precise two-generator algebraic-independence specialization needed for the
concrete sum.  Establishing this specialization from `SchanuelConjecture` is the
remaining number-theoretic step, not an analytic or syntactic issue. -/
def ConcreteSchanuelSpecialization : Prop :=
  AlgebraicIndependent ℚ
    (fun b : Bool ↦ cond b (Real.log 2) (Real.exp (Real.exp 1)))

/-- Algebraic independence of two real numbers implies transcendence of their sum. -/
theorem transcendental_add_of_algebraicIndependent_bool
    {x y : ℝ} (h : AlgebraicIndependent ℚ (fun b : Bool ↦ cond b y x)) :
    Transcendental ℚ (x + y) := by
  rw [transcendental_iff]
  intro p hp
  let q : MvPolynomial Bool ℚ :=
    Polynomial.aeval (MvPolynomial.X false + MvPolynomial.X true) p
  have hcomp :
      (MvPolynomial.aeval (fun b : Bool ↦ cond b y x)).comp
          (Polynomial.aeval (R := ℚ)
            (MvPolynomial.X false + MvPolynomial.X true : MvPolynomial Bool ℚ)) =
        Polynomial.aeval (x + y) := by
    ext
    simp
  have hqeval : MvPolynomial.aeval (fun b : Bool ↦ cond b y x) q = 0 := by
    dsimp [q]
    rw [← AlgHom.comp_apply, hcomp]
    exact hp
  have hq : q = 0 := h.eq_zero_of_aeval_eq_zero q hqeval
  have hcomp' :
      (MvPolynomial.aeval
        (fun b : Bool ↦ cond b (0 : Polynomial ℚ) Polynomial.X)).comp
          (Polynomial.aeval (R := ℚ)
            (MvPolynomial.X false + MvPolynomial.X true : MvPolynomial Bool ℚ)) =
        AlgHom.id ℚ (Polynomial ℚ) := by
    ext
    simp
  have hretract := congrArg
    (MvPolynomial.aeval
      (fun b : Bool ↦ cond b (0 : Polynomial ℚ) Polynomial.X)) hq
  dsimp [q] at hretract
  rw [← AlgHom.comp_apply, hcomp'] at hretract
  simpa using hretract

/-- The requested concrete transcendence result under its exact Schanuel
specialization. -/
theorem concreteValue_transcendental
    (h : ConcreteSchanuelSpecialization) :
    Transcendental ℚ concreteValue := by
  unfold concreteValue
  exact transcendental_add_of_algebraicIndependent_bool h

/-- The formal Schanuel conjecture together with its concrete specialization yields
the requested result.  The second hypothesis deliberately records the currently
unformalized mathematical reduction from the general conjecture. -/
theorem concreteValue_transcendental_of_schanuel
    (hSC : SchanuelConjecture)
    (hspecial : SchanuelConjecture → ConcreteSchanuelSpecialization) :
    Transcendental ℚ concreteValue := by
  exact concreteValue_transcendental (hspecial hSC)

/-- EML numbers generated from `1`, using the existing catalog term language. -/
def EMLNumbers : Set ℝ := Set.range (fun t : ETerm ↦ t.eval 1)

/-- The intrinsic EL closure of `1`: membership in every set containing `1` and
closed under addition, multiplication, real exponential, and real logarithm. -/
def ELNumbers : Set ℝ := {x | ∀ S : Set ℝ,
  1 ∈ S →
  (∀ a ∈ S, ∀ b ∈ S, a + b ∈ S) →
  (∀ a ∈ S, ∀ b ∈ S, a * b ∈ S) →
  (∀ a ∈ S, Real.exp a ∈ S) →
  (∀ a ∈ S, Real.log a ∈ S) → x ∈ S}

lemma emlNumbers_one : (1 : ℝ) ∈ EMLNumbers := by
  exact ⟨ETerm.var, rfl⟩

lemma emlNumbers_add {a b : ℝ} (ha : a ∈ EMLNumbers) (hb : b ∈ EMLNumbers) :
    a + b ∈ EMLNumbers := by
  obtain ⟨ta, rfl⟩ := ha
  obtain ⟨tb, rfl⟩ := hb
  exact ⟨ETerm.add ta tb, rfl⟩

lemma emlNumbers_mul {a b : ℝ} (ha : a ∈ EMLNumbers) (hb : b ∈ EMLNumbers) :
    a * b ∈ EMLNumbers := by
  obtain ⟨ta, rfl⟩ := ha
  obtain ⟨tb, rfl⟩ := hb
  exact ⟨ETerm.mul ta tb, rfl⟩

lemma emlNumbers_exp {a : ℝ} (ha : a ∈ EMLNumbers) :
    Real.exp a ∈ EMLNumbers := by
  obtain ⟨ta, rfl⟩ := ha
  exact ⟨ETerm.expOf ta, rfl⟩

lemma emlNumbers_log {a : ℝ} (ha : a ∈ EMLNumbers) :
    Real.log a ∈ EMLNumbers := by
  obtain ⟨ta, rfl⟩ := ha
  exact ⟨ETerm.logOf ta, rfl⟩

/-- Every syntactically generated EML number belongs to the intrinsic EL closure. -/
theorem emlNumbers_subset_elNumbers : EMLNumbers ⊆ ELNumbers := by
  rintro x ⟨t, rfl⟩
  intro S hOne hAdd hMul hExp hLog
  induction t with
  | var => exact hOne
  | add a b ha hb => exact hAdd _ ha _ hb
  | mul a b ha hb => exact hMul _ ha _ hb
  | expOf a ha => exact hExp _ ha
  | logOf a ha => exact hLog _ ha

/-- Minimality of the intrinsic closure: every EL number has a catalog EML term. -/
theorem elNumbers_subset_emlNumbers : ELNumbers ⊆ EMLNumbers := by
  intro x hx
  exact hx EMLNumbers emlNumbers_one
    (fun _ ha _ hb ↦ emlNumbers_add ha hb)
    (fun _ ha _ hb ↦ emlNumbers_mul ha hb)
    (fun _ ha ↦ emlNumbers_exp ha)
    (fun _ ha ↦ emlNumbers_log ha)

/-- The catalog's syntactic EML numbers are exactly the intrinsically generated EL
numbers.  This closure theorem is unconditional. -/
theorem emlNumbers_eq_elNumbers : EMLNumbers = ELNumbers :=
  Set.Subset.antisymm emlNumbers_subset_elNumbers elNumbers_subset_emlNumbers

/-- Consequently Schanuel's conjecture implies equality of the EML and EL classes.
The proof records the stronger finding that this class equality is purely a closure
fact and does not require the conjecture. -/
theorem emlNumbers_eq_elNumbers_of_schanuel (_hSC : SchanuelConjecture) :
    EMLNumbers = ELNumbers :=
  emlNumbers_eq_elNumbers

end EMLTranscendence