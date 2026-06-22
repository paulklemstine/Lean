import Mathlib

/-!
# Langlands functoriality: the symmetric-square lift `Sym² : GL₂ ⤳ GL₃`

This file formalizes the *unramified* heart of the Gelbart–Jacquet symmetric-square
transfer from `GL(2)` to `GL(3)` at the level of Satake / Frobenius conjugacy
classes.

An unramified parameter of `GL₂` is a `2×2` matrix `A` (the Satake class); its
eigenvalues `{α, β}` are the Satake parameters and `tr A = a_p` is the Hecke
eigenvalue.  On the symmetric-square space `Sym²(std)` with ordered basis
`{x², xy, y²}` the induced `3×3` matrix is `sym2 A`.  We prove:

* `sym2_one`, `sym2_mul` — `Sym²` is a *representation*, i.e. a multiplicative
  map `GL₂(R) → GL₃(R)`.  This is the dual-group homomorphism underlying the
  functorial transfer.
* `sym2_diagonal` — on a diagonal (split) Satake class the transfer is
  `{α, β} ↦ {α², αβ, β²}`.
* `trace_sym2` — the Hecke-eigenvalue transfer `a_p ↦ a_p² − χ(p)`,
  `tr (Sym² A) = (tr A)² − det A`.
* `det_sym2` — the central-character transfer `det (Sym² A) = (det A)³`.
* `rankinSelberg_trace_decomp` — the local decomposition
  `π ⊗ π = Sym²π ⊞ ∧²π`, here `(tr A)² = tr (Sym² A) + det A`
  (the `∧²` part being the determinant / `GL₁` factor).

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The combinatorial content of `Sym²`-functoriality
GL₂→GL₃ is an explicit polynomial map of matrices that is (a) multiplicative
and (b) transports trace/determinant by `t ↦ t²−d`, `d ↦ d³`.
EXPERIMENT (Experimenter): defined `sym2` on `{x²,xy,y²}`, verified all
identities over ℚ on random integer matrices (see ComputationalEvidence.md),
then proved them over an arbitrary commutative ring.
ANALYSIS (Analyst): multiplicativity is the load-bearing fact — it is exactly
"`Sym²` is a representation of the dual group". Trace/det formulas are then the
Hecke-eigenvalue and central-character transfer laws. The `(tr A)² = tr Sym²A +
det A` identity is the local Rankin–Selberg / isobaric-sum decomposition.
CRITIQUE (Critic): results hold over any `CommRing`, not just ℂ, so they are not
artefacts of a particular field; `sym2_mul` is a genuine `3×3` matrix identity
(9 cubic polynomial identities), not a definitional rewrite.
SYNTHESIS (PI): these five theorems pin down the unramified GL₂→GL₃ transfer as
an algebraic homomorphism with explicit trace/determinant transport.
-- !-- end Lab Notes -- !--
-/

namespace Langlands.SymSquare

open Matrix

variable {R : Type*} [CommRing R]

/-- The symmetric square of a `2×2` matrix, as the `3×3` matrix of its induced
action on `Sym²` of the standard representation in the ordered basis
`{x², xy, y²}`.  For `A = !![a,b;c,d]` this is
`!![a², ab, b²; 2ac, ad+bc, 2bd; c², cd, d²]`. -/
def sym2 (A : Matrix (Fin 2) (Fin 2) R) : Matrix (Fin 3) (Fin 3) R :=
  !![ A 0 0 ^ 2,        A 0 0 * A 0 1,            A 0 1 ^ 2;
      2 * A 0 0 * A 1 0, A 0 0 * A 1 1 + A 0 1 * A 1 0, 2 * A 0 1 * A 1 1;
      A 1 0 ^ 2,        A 1 0 * A 1 1,            A 1 1 ^ 2 ]

/-
`Sym²` sends the identity to the identity.
-/
theorem sym2_one : sym2 (1 : Matrix (Fin 2) (Fin 2) R) = 1 := by
  -- Compute the symmetric square of the 2×2 identity entrywise and match the 3×3 identity.
  ext i j
  fin_cases i <;> fin_cases j <;> simp [sym2, Matrix.cons_val_zero]

/-
**Functoriality / representation property.** `Sym²` is multiplicative:
the dual-group homomorphism `GL₂ → GL₃` underlying the symmetric-square lift.
-/
theorem sym2_mul (A B : Matrix (Fin 2) (Fin 2) R) :
    sym2 (A * B) = sym2 A * sym2 B := by
  unfold sym2;
  simp +decide [ Fin.sum_univ_succ, Matrix.mul_apply ];
  grind

/-
**Satake-parameter transfer.** On a split (diagonal) Satake class
`diag(α, β)` the symmetric square is `diag(α², αβ, β²)`.
-/
theorem sym2_diagonal (a b : R) :
    sym2 (!![a, 0; 0, b]) = diagonal ![a ^ 2, a * b, b ^ 2] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp +decide [ sym2 ] ;

/-
**Hecke-eigenvalue transfer.** `tr (Sym² A) = (tr A)² − det A`,
i.e. the `Sym²` Hecke eigenvalue is `a_p² − χ(p)`.
-/
theorem trace_sym2 (A : Matrix (Fin 2) (Fin 2) R) :
    (sym2 A).trace = (A.trace) ^ 2 - A.det := by
  unfold sym2; simp +decide [ Matrix.trace_fin_two, Matrix.det_fin_two ] ; ring;

/-
**Central-character transfer.** `det (Sym² A) = (det A)³`.
-/
theorem det_sym2 (A : Matrix (Fin 2) (Fin 2) R) :
    (sym2 A).det = (A.det) ^ 3 := by
  simp +decide [ Matrix.det_fin_three, sym2 ];
  rw [ Matrix.det_fin_two ] ; ring

/-
**Local Rankin–Selberg decomposition** `π ⊗ π = Sym²π ⊞ ∧²π`, at the level
of Satake traces: `(tr A)² = tr (Sym² A) + det A`, the `∧²` (determinant /`GL₁`)
factor accounting for the difference.
-/
theorem rankinSelberg_trace_decomp (A : Matrix (Fin 2) (Fin 2) R) :
    (A.trace) ^ 2 = (sym2 A).trace + A.det := by
  rw [ trace_sym2 ] ; ring;

end Langlands.SymSquare