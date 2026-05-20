/-
Copyright (c) 2025 Arithmetic Learning Theory Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Period Signatures for Analytic Differential Families

This file defines the core structures for **arithmetic learning theory for analytic operators**
and proves the main theorems establishing that period signatures form a well-behaved
complexity invariant.

## Main definitions

* `PeriodLayer` — qualitative solution type: algebraic, logarithmic, elliptic, hypergeometric
* `PeriodSignature` — coarse motivic/periodic signature for an analytic differential family
* `complexityExponent` — combined complexity functional
* `minWidthNeeded` — proxy for approximation architecture width
* `signatureLE` — componentwise partial order on signatures
* `AlgebraicODEFamily` — toy formalization of ODE families with algebraic data
* `GaugeEquivalent` — rational gauge equivalence of ODE families
* `IsSignatureExtension` — one family extends another's singularity structure
* `signatureWeight` — total weight of a list of period layers

## Main results

1. `complexityExponent_monotone` — monotonicity under componentwise ordering
2. `complexityExponent_strict_of_log_increase` — strict separation from log rank
3. `complexityExponent_strict_of_mono_increase` — strict separation from monodromy
4. `universality_strict_separation` — combined strict separation
5. `periodSignature_invariant_of_gaugeEquiv` — gauge invariance
6. `complexity_monotone_of_extension` — extension monotonicity
7. `minWidthNeeded_mono` / `minWidthNeeded_strict` — width monotonicity
8. `signatureWeight_mono_of_sublist` / `signatureWeight_lt_of_strict_sublist` — layer weights
9. `inferSignature_complexity_mono` — inference correctness
10. `algebraic_minimal_complexity` — algebraic families are simplest

## References

* Kontsevich–Zagier, "Periods" (2001)
* André, "Galois theory, motives and transcendental numbers" (2009)
-/
import Mathlib

namespace MotivicPeriod

/-! ### Period Layers -/

/-- Inductive classification of local solution behavior. -/
inductive PeriodLayer where
  | algebraic
  | logarithmic
  | elliptic
  | hypergeometric
  deriving DecidableEq, Repr

/-- Complexity weight assigned to each period layer. -/
def layerWeight : PeriodLayer → ℕ
  | .algebraic      => 1
  | .logarithmic    => 2
  | .elliptic       => 3
  | .hypergeometric => 4

/-- Total weight of a list of period layers. -/
def signatureWeight (L : List PeriodLayer) : ℕ :=
  (L.map layerWeight).sum

/-! ### Period Signature -/

/-- A coarse motivic/periodic signature for an analytic differential family. -/
structure PeriodSignature where
  algRank     : ℕ
  logRank     : ℕ
  singCount   : ℕ
  monoComplex : ℕ
  deriving DecidableEq, Repr

/-- Combined complexity exponent. -/
def complexityExponent (σ : PeriodSignature) : ℕ :=
  σ.algRank + 2 * σ.logRank + σ.singCount + σ.monoComplex

/-- Minimal approximation architecture width proxy. -/
def minWidthNeeded (σ : PeriodSignature) : ℕ :=
  σ.logRank + σ.monoComplex + 1

/-- Componentwise partial order on period signatures. -/
def signatureLE (σ τ : PeriodSignature) : Prop :=
  σ.algRank ≤ τ.algRank ∧
  σ.logRank ≤ τ.logRank ∧
  σ.singCount ≤ τ.singCount ∧
  σ.monoComplex ≤ τ.monoComplex

/-! ### ODE Families -/

/-- A toy formalization of analytic differential families with algebraic data. -/
structure AlgebraicODEFamily where
  param : Type
  singularSet : param → Finset ℚ
  signature : PeriodSignature

/-- Rational gauge equivalence of ODE families. -/
def GaugeEquivalent (F G : AlgebraicODEFamily) : Prop :=
  F.signature = G.signature

/-- A family G is a signature extension of F. -/
def IsSignatureExtension (F G : AlgebraicODEFamily) : Prop :=
  signatureLE F.signature G.signature

/-! ### Inference -/

/-- Infer a coarse period signature from symbolic data. -/
def inferSignature (numAlg : ℕ) (hasLogs : Bool) (singPts : ℕ) (monoRank : ℕ) :
    PeriodSignature where
  algRank := numAlg
  logRank := if hasLogs then max 1 monoRank else 0
  singCount := singPts
  monoComplex := monoRank

/-! ## Theorems -/

/-
The complexity exponent is monotone under componentwise signature ordering.
-/
theorem complexityExponent_monotone
    {σ τ : PeriodSignature}
    (h : signatureLE σ τ) :
    complexityExponent σ ≤ complexityExponent τ := by
  exact add_le_add ( add_le_add ( add_le_add h.1 ( Nat.mul_le_mul_left 2 h.2.1 ) ) h.2.2.1 ) h.2.2.2

/-
Strict increase in logarithmic rank forces strictly larger complexity exponent.
-/
theorem complexityExponent_strict_of_log_increase
    {σ τ : PeriodSignature}
    (hAlg : σ.algRank ≤ τ.algRank)
    (hSing : σ.singCount ≤ τ.singCount)
    (hMono : σ.monoComplex ≤ τ.monoComplex)
    (hLog : σ.logRank < τ.logRank) :
    complexityExponent σ < complexityExponent τ := by
  unfold complexityExponent; linarith;

/-
Strict increase in monodromy complexity forces strictly larger complexity exponent.
-/
theorem complexityExponent_strict_of_mono_increase
    {σ τ : PeriodSignature}
    (hAlg : σ.algRank ≤ τ.algRank)
    (hLog : σ.logRank ≤ τ.logRank)
    (hSing : σ.singCount ≤ τ.singCount)
    (hMono : σ.monoComplex < τ.monoComplex) :
    complexityExponent σ < complexityExponent τ := by
  unfold complexityExponent; linarith;

/-
Additional logarithmic or monodromy complexity forces strictly larger exponent.
-/
theorem universality_strict_separation
    {σ τ : PeriodSignature}
    (hAlg : σ.algRank ≤ τ.algRank)
    (hLog : σ.logRank ≤ τ.logRank)
    (hMono : σ.monoComplex ≤ τ.monoComplex)
    (hSing : σ.singCount ≤ τ.singCount)
    (hStrict : σ.logRank < τ.logRank ∨ σ.monoComplex < τ.monoComplex) :
    complexityExponent σ < complexityExponent τ := by
  rcases hStrict with h | h <;> [ exact complexityExponent_strict_of_log_increase hAlg hSing hMono h; exact complexityExponent_strict_of_mono_increase hAlg hLog hSing h ]

/-
Rational gauge-equivalent families have identical period signatures.
-/
theorem periodSignature_invariant_of_gaugeEquiv
    (F G : AlgebraicODEFamily)
    (hEq : GaugeEquivalent F G) :
    F.signature = G.signature := by
  exact hEq

/-
Signature extensions cannot decrease the complexity exponent.
-/
theorem complexity_monotone_of_extension
    {F G : AlgebraicODEFamily}
    (hExt : IsSignatureExtension F G) :
    complexityExponent F.signature ≤ complexityExponent G.signature := by
  exact complexityExponent_monotone hExt

/-
Families with more branching complexity require weakly larger approximation width.
-/
theorem minWidthNeeded_mono
    {σ τ : PeriodSignature}
    (hLog : σ.logRank ≤ τ.logRank)
    (hMono : σ.monoComplex ≤ τ.monoComplex) :
    minWidthNeeded σ ≤ minWidthNeeded τ := by
  exact Nat.add_le_add ( Nat.add_le_add hLog hMono ) le_rfl

/-
Strict increase in log or monodromy forces strictly wider architecture.
-/
theorem minWidthNeeded_strict
    {σ τ : PeriodSignature}
    (hLog : σ.logRank ≤ τ.logRank)
    (hMono : σ.monoComplex ≤ τ.monoComplex)
    (hStrict : σ.logRank < τ.logRank ∨ σ.monoComplex < τ.monoComplex) :
    minWidthNeeded σ < minWidthNeeded τ := by
  unfold minWidthNeeded; omega;

/-
Every period layer has positive weight.
-/
theorem layerWeight_pos (l : PeriodLayer) : 0 < layerWeight l := by
  cases l <;> decide

/-
Signature weight is monotone under the sublist relation.
-/
theorem signatureWeight_mono_of_sublist
    {L₁ L₂ : List PeriodLayer}
    (hsub : L₁.Sublist L₂) :
    signatureWeight L₁ ≤ signatureWeight L₂ := by
  convert List.Sublist.map _ hsub |> List.Sublist.sum_le_sum <| fun x => ?_;
  · infer_instance;
  · infer_instance;
  · exact fun _ => Nat.zero_le _

/-
Strict sublists have strictly smaller weight.
-/
theorem signatureWeight_lt_of_strict_sublist
    {L₁ L₂ : List PeriodLayer}
    (hsub : L₁.Sublist L₂)
    (hneq : L₁ ≠ L₂) :
    signatureWeight L₁ < signatureWeight L₂ := by
  induction' hsub with L₁ L₂ hsub hneq ih;
  · contradiction;
  · by_cases h : L₁ = L₂ <;> simp_all +decide [ signatureWeight ];
    · exact layerWeight_pos hsub;
    · exact lt_of_lt_of_le ih ( Nat.le_add_left _ _ );
  · simp_all +decide [ signatureWeight ]

/-
If raw symbolic data increases, the inferred complexity exponent does not decrease.
-/
theorem inferSignature_complexity_mono
    {a₁ a₂ : ℕ} {b₁ b₂ : Bool} {s₁ s₂ m₁ m₂ : ℕ}
    (ha : a₁ ≤ a₂) (hs : s₁ ≤ s₂) (hm : m₁ ≤ m₂)
    (hb : b₁ = false ∨ b₂ = true) :
    complexityExponent (inferSignature a₁ b₁ s₁ m₁) ≤
    complexityExponent (inferSignature a₂ b₂ s₂ m₂) := by
  grind +locals

/-
Purely algebraic signatures have minimal complexity in their stratum.
-/
theorem algebraic_minimal_complexity
    (n s : ℕ) (σ : PeriodSignature)
    (hAlg : σ.algRank = n) (hSing : σ.singCount = s) :
    complexityExponent ⟨n, 0, s, 0⟩ ≤ complexityExponent σ := by
  grind +locals

end MotivicPeriod