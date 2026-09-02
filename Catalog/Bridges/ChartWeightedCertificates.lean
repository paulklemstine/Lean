/-
# Weighted (quasi-homogeneous) certificates for the chart calculus

`Bridges.ChartDownsetUnisolvence` proves that any *downset* of exponents is a uniqueness
set for the polynomials supported in it, and that sublevel sets of a weighted degree
`∑ wᵢaᵢ ≤ d` are downsets.  This file installs that theorem in the reflective calculus
`NExpr`:

* `ChartCalculus.NExpr.wdeg` — a syntactic weighted degree, computed from the expression
  tree exactly like the total degree but charging `w i` for the variable `xᵢ`;
* `ChartCalculus.NExpr.wsum_le_wdeg` — it really bounds the weighted degree of every
  exponent occurring in the integral denotation;
* `ChartCalculus.NExpr.WeightedCert` — the decidable check "the two expressions agree at
  the integer points of the weighted simplex", proved sound *and* complete in
  `ChartCalculus.NExpr.weightedCert_iff_toZ_eq`, and transported to every commutative ring
  by `ChartCalculus.NExpr.universal_of_weightedCert`;
* a worked identity `(a² + b)(a² − b) = a⁴ − b²` certified by `9` kernel-checked
  evaluations, where the total-degree simplex certificate of
  `Bridges.ChartSimplexCertificates` needs `15` and the box grid `25`.

The point is that weights let the certificate see sparsity: an expression that is
quasi-homogeneous for weights `w` has a much smaller node set than its total degree
suggests, and the saving is unbounded as the weights grow.
-/
import Bridges.ChartDownsetUnisolvence

open MvPolynomial

namespace ChartCalculus

namespace NExpr

variable {n : ℕ}

/-! ## The syntactic weighted degree -/

/-- The syntactic weighted-degree bound, charging weight `w i` for the variable `xᵢ`. -/
def wdeg (w : Fin n → ℕ) : NExpr n → ℕ
  | .var i => w i
  | .const _ => 0
  | .add a b => max (wdeg w a) (wdeg w b)
  | .mul a b => wdeg w a + wdeg w b
  | .neg a => wdeg w a

/-- The syntactic weighted degree bounds the weighted degree of every exponent vector
occurring in the denotation. -/
theorem wsum_le_wdeg (w : Fin n → ℕ) (e : NExpr n) :
    ∀ a ∈ e.toZ.support, wsum w a ≤ e.wdeg w := by
  classical
  induction e with
  | var i =>
      intro a ha
      rw [toZ, MvPolynomial.support_X, Finset.mem_singleton] at ha
      subst ha
      simp [wdeg, wsum_single]
  | const c =>
      intro a ha
      have hne := MvPolynomial.mem_support_iff.mp ha
      by_cases h : a = 0
      · simp [h, wdeg]
      · rw [toZ, MvPolynomial.coeff_C, if_neg (Ne.symm h)] at hne
        exact absurd rfl hne
  | add p q hp hq =>
      intro a ha
      rw [toZ] at ha
      rcases Finset.mem_union.mp (MvPolynomial.support_add ha) with h | h
      · exact le_trans (hp a h) (le_max_left _ _)
      · exact le_trans (hq a h) (le_max_right _ _)
  | mul p q hp hq =>
      intro a ha
      rw [toZ] at ha
      obtain ⟨b, hb, c, hc, hbc⟩ := Finset.mem_add.mp (MvPolynomial.support_mul _ _ ha)
      subst hbc
      rw [wsum_add]
      exact Nat.add_le_add (hp b hb) (hq c hc)
  | neg p hp =>
      intro a ha
      rw [toZ, MvPolynomial.support_neg] at ha
      exact hp a ha

/-! ## The weighted node set -/

/-- The weighted simplex `{a ∈ ℕⁿ : ∑ wᵢaᵢ ≤ d}` as a computable `Finset`. -/
def weightedTuples (n : ℕ) (w : Fin n → ℕ) (d : ℕ) : Finset (Fin n → ℕ) :=
  (Fintype.piFinset (fun _ : Fin n => Finset.range (d + 1))).filter (fun a => ∑ i, w i * a i ≤ d)

theorem mem_weightedTuples {w : Fin n → ℕ} {d : ℕ} {a : Fin n → ℕ} (hw : ∀ i, 1 ≤ w i) :
    a ∈ weightedTuples n w d ↔ ∑ i, w i * a i ≤ d := by
  rw [weightedTuples, Finset.mem_filter]
  refine ⟨fun h => h.2, fun h => ⟨Fintype.mem_piFinset.mpr (fun i => Finset.mem_range.mpr ?_), h⟩⟩
  have hle : w i * a i ≤ ∑ j, w j * a j :=
    Finset.single_le_sum (f := fun j => w j * a j) (fun j _ => Nat.zero_le _) (Finset.mem_univ i)
  have hai : a i ≤ w i * a i := Nat.le_mul_of_pos_left _ (hw i)
  omega

/-! ## The decidable weighted certificate -/

/-- The weighted certificate: agreement at the integer points of the weighted simplex. -/
def WeightedCert (w : Fin n → ℕ) (d : ℕ) (e₁ e₂ : NExpr n) : Prop :=
  ∀ a ∈ weightedTuples n w d,
    eval (fun i => ((a i : ℕ) : ℤ)) e₁ = eval (fun i => ((a i : ℕ) : ℤ)) e₂

instance (w : Fin n → ℕ) (d : ℕ) (e₁ e₂ : NExpr n) : Decidable (WeightedCert w d e₁ e₂) :=
  inferInstanceAs (Decidable (∀ a ∈ _, _))

/-- **Soundness and completeness of the weighted certificate.**  For expressions of
syntactic weighted degree at most `d`, agreement on the weighted simplex is *equivalent* to
denoting the same polynomial. -/
theorem weightedCert_iff_toZ_eq {w : Fin n → ℕ} {d : ℕ} (hw : ∀ i, 1 ≤ w i) (e₁ e₂ : NExpr n)
    (h₁ : e₁.wdeg w ≤ d) (h₂ : e₂.wdeg w ≤ d) :
    WeightedCert w d e₁ e₂ ↔ e₁.toZ = e₂.toZ := by
  constructor
  · intro hc
    refine eq_of_eval_eq_on_downset (K := ℤ) {a : Fin n →₀ ℕ | wsum w a ≤ d}
      (isLowerSet_wsumLE w d) e₁.toZ e₂.toZ (fun a ha => ?_) (fun a ha => ?_) (fun a ha => ?_)
    · exact le_trans (wsum_le_wdeg w e₁ a (by simpa using ha)) h₁
    · exact le_trans (wsum_le_wdeg w e₂ a (by simpa using ha)) h₂
    · have hmem : (fun i => a i) ∈ weightedTuples n w d :=
        (mem_weightedTuples hw).mpr ha
      rw [← eval_int, ← eval_int]
      exact hc _ hmem
  · intro h a _
    exact eval_eq_of_toZ_eq e₁ e₂ h _

/-- A verified weighted check certifies the identity in every commutative ring. -/
theorem universal_of_weightedCert {w : Fin n → ℕ} {d : ℕ} (hw : ∀ i, 1 ≤ w i) {e₁ e₂ : NExpr n}
    (h₁ : e₁.wdeg w ≤ d) (h₂ : e₂.wdeg w ≤ d) (hc : WeightedCert w d e₁ e₂)
    {R : Type*} [CommRing R] (x : Fin n → R) : e₁.eval x = e₂.eval x :=
  eval_eq_of_toZ_eq e₁ e₂ ((weightedCert_iff_toZ_eq hw e₁ e₂ h₁ h₂).mp hc) x

/-- Equality of denotations is decidable by the weighted check, for any weight vector with
positive entries. -/
def decEqToZ_weighted (w : Fin n → ℕ) (hw : ∀ i, 1 ≤ w i) (e₁ e₂ : NExpr n) :
    Decidable (e₁.toZ = e₂.toZ) :=
  decidable_of_iff (WeightedCert w (max (e₁.wdeg w) (e₂.wdeg w)) e₁ e₂)
    (weightedCert_iff_toZ_eq hw e₁ e₂ (le_max_left _ _) (le_max_right _ _))

/-! ## A worked quasi-homogeneous identity -/

/-- `(x² + y)(x² − y)`, of weighted degree `4` for the weights `w = (1, 2)`. -/
def quasiLHS : NExpr 2 :=
  .mul (.add (.mul (.var 0) (.var 0)) (.var 1))
       (.add (.mul (.var 0) (.var 0)) (.neg (.var 1)))

/-- `x⁴ − y²`, of weighted degree `4` for the weights `w = (1, 2)`. -/
def quasiRHS : NExpr 2 :=
  .add (.mul (.mul (.var 0) (.var 0)) (.mul (.var 0) (.var 0)))
       (.neg (.mul (.var 1) (.var 1)))

/-- The weighted simplex for `w = (1,2)`, `d = 4` has `9` points. -/
theorem card_weightedTuples_example : (weightedTuples 2 ![1, 2] 4).card = 9 := by decide

/-- The total-degree simplex for the same identity would need `15` points, and the box grid
`{0,…,4}²` would need `25`. -/
theorem card_simplexTuples_two_four : (simplexTuples 2 4).card = 15 := by
  rw [card_simplexTuples]
  decide

set_option maxRecDepth 40000 in
theorem quasi_weightedCert : WeightedCert ![1, 2] 4 quasiLHS quasiRHS := by decide

/-- The quasi-homogeneous identity `(a² + b)(a² − b) = a⁴ − b²` in an arbitrary commutative
ring, obtained from a check at the `9` points of the weighted simplex. -/
theorem quasi_identity {R : Type*} [CommRing R] (a b : R) :
    (a ^ 2 + b) * (a ^ 2 - b) = a ^ 4 - b ^ 2 := by
  have h := universal_of_weightedCert (w := ![1, 2]) (d := 4) (by decide)
    (e₁ := quasiLHS) (e₂ := quasiRHS) (by decide) (by decide) quasi_weightedCert (R := R) ![a, b]
  simp only [quasiLHS, quasiRHS, eval, Matrix.cons_val_zero, Matrix.cons_val_one] at h
  linear_combination h

end NExpr

end ChartCalculus