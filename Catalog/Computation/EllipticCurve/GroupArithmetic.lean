import Mathlib
import Computation.EllipticCurve.HasseBound

/-!
# Group arithmetic of elliptic curves over finite fields

This file develops, in a strict and non-circular dependency order, basic facts about the additive
group `E(𝔽_q) = WeierstrassCurve.Affine.Point W` of nonsingular affine points of a Weierstrass
curve `W` over a finite field `F`.  Mathlib already provides the `AddCommGroup` instance (with
associativity proved); we build on top of it.

* **Step 1 (finiteness).** `E(𝔽_q)` is finite, via an explicit injection into `Option (F × F)`.
* **Step 2 (scalar multiplication).** Elementary `ℕ`-scalar-multiplication identities that follow
  purely from the `AddCommGroup` axioms — crucially *without* any reference to `#E`.
* **Step 3 (Lagrange).** The order of every point divides `Nat.card E(𝔽_q)`, by Mathlib's general
  `addOrderOf_dvd_natCard`; hence `(Nat.card E(𝔽_q)) • P = 0`.
* **Step 4 (Hasse connection).** The integer trace bound of `HasseBound.lean` implies the analytic
  bound `|Nat.card E(𝔽_q) - (q + 1)| ≤ 2 √q`.

The four steps are stated and proved strictly in order: each only uses Mathlib and earlier steps.
-/

namespace Computation.EllipticCurve

open WeierstrassCurve.Affine

/-! ## Step 1: Finiteness (no group-theoretic dependencies) -/

section Finiteness

variable {F : Type*} [Field F]

/-- Explicit map from nonsingular affine points to `Option (F × F)`: the point at infinity goes to
`none`, and an affine point `(x, y)` goes to `some (x, y)`. -/
def toOptionPair (W : WeierstrassCurve.Affine F) : W.Point → Option (F × F)
  | .zero => none
  | .some (x := x) (y := y) _ => some (x, y)

/-- The map `toOptionPair` is injective (using proof irrelevance of the nonsingularity witness). -/
lemma toOptionPair_injective (W : WeierstrassCurve.Affine F) :
    Function.Injective (toOptionPair W) := by
  intro P Q; cases P <;> cases Q <;> simp_all +decide [toOptionPair]

/-- **Step 1 (Fintype).** The group of nonsingular affine points over a finite field is a
`Fintype`, via the injection `toOptionPair` into `Option (F × F)`. -/
noncomputable instance instFintypePoint [Fintype F] {W : WeierstrassCurve.Affine F} :
    Fintype W.Point :=
  Fintype.ofInjective (toOptionPair W) (toOptionPair_injective W)

/-- **Step 1 (Finite).** Consequently `E(𝔽_q)` is finite. -/
instance instFinitePoint [Fintype F] {W : WeierstrassCurve.Affine F} : Finite W.Point :=
  Finite.of_injective (toOptionPair W) (toOptionPair_injective W)

end Finiteness

/-! ## Step 2: Scalar multiplication facts (using ONLY `AddCommGroup`, NOT `#E`) -/

section ScalarMultiplication

variable {F : Type*} [Field F] [DecidableEq F] {W : WeierstrassCurve.Affine F}

/-- `(0 : ℕ) • P = 0`. -/
lemma nsmul_zero (P : W.Point) : (0 : ℕ) • P = 0 := zero_nsmul P

/-- `(1 : ℕ) • P = P`. -/
lemma nsmul_one (P : W.Point) : (1 : ℕ) • P = P := one_nsmul P

/-- **Double-and-add correctness.** Doubling a point `k` times computes `2 ^ k • P`. -/
lemma repeated_double_eq (P : W.Point) (k : ℕ) :
    (2 ^ k : ℕ) • P = (fun Q => Q + Q)^[k] P := by
  induction k <;> simp_all +decide [pow_succ', Function.iterate_succ_apply']
  simp_all +decide [two_mul, add_smul]

/-- `(m + n) • P = m • P + n • P`. -/
lemma nsmul_add_comm (m n : ℕ) (P : W.Point) : (m + n) • P = m • P + n • P :=
  add_nsmul P m n

end ScalarMultiplication

/-! ## Step 3: Lagrange for `E(𝔽_q)` (using Mathlib's general theorem) -/

section Lagrange

variable {F : Type*} [Field F] [DecidableEq F] {W : WeierstrassCurve.Affine F}

/-- **Lagrange.** The additive order of any point divides `Nat.card E(𝔽_q)`. -/
lemma ec_addOrderOf_dvd_card (P : W.Point) : addOrderOf P ∣ Nat.card W.Point :=
  addOrderOf_dvd_natCard P

/-- Consequently `(Nat.card E(𝔽_q)) • P = 0`. -/
lemma ec_card_nsmul_eq_zero (P : W.Point) : (Nat.card W.Point) • P = 0 :=
  addOrderOf_dvd_iff_nsmul_eq_zero.mp (ec_addOrderOf_dvd_card P)

end Lagrange

/-! ## Step 4: Hasse bound connection -/

section Hasse

variable {F : Type*} [Field F] [Fintype F] {W : WeierstrassCurve.Affine F}

/-- **Step 4.** With `q = #F`, the integer trace bound from `HasseBound.lean`
(`HasseTraceBound q (Nat.card E(𝔽_q))`) implies the analytic Hasse bound
`|Nat.card E(𝔽_q) - (q + 1)| ≤ 2 √q`. -/
theorem ec_hasse_bound
    (htrace : HasseTraceBound (Fintype.card F) (Nat.card W.Point)) :
    |(Nat.card W.Point : ℝ) - ((Fintype.card F : ℝ) + 1)| ≤ 2 * Real.sqrt (Fintype.card F) :=
  abs_sub_le_of_hasseTraceBound _ _ htrace

end Hasse

end Computation.EllipticCurve