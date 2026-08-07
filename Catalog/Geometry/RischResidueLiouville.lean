/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Applications.EML.RischAlgorithm

/-!
# Residues, Liouville obstructions, and the Risch differential equation

This file advances the normalized Risch development of
`Catalog/Applications/EML/RischAlgorithm.lean` in three independent directions.

* **Split rational denominators (Conjecture 4).**  For a rational function
  `p(x) / ∏_{a ∈ s} (x - a)` with `s` a finite set of rational poles and
  `deg p < |s|`, Lagrange interpolation produces the partial-fraction expansion
  with coefficients the simple-pole residues `p(a) / ∏_{b ≠ a} (a - b)`.  The
  resulting `EMLRisch.RationalNormalForm` feeds the catalog's certified Risch
  procedure, and the produced primitive is a rational combination of logarithms
  of affine factors whose coefficients are *exactly* the residues.  Uniqueness
  of those coefficients is proved separately (`residue_coefficients_unique`),
  which is the "up to permutation and deletion of zero pieces" part of
  Conjecture 1 in the split case.

* **A genuine Liouville obstruction.**  `no_rational_primitive_of_simple_pole`
  shows that `c / (x - a)` with `c ≠ 0` has *no* rational-function
  antiderivative, so the logarithmic pieces produced by the residue criterion are
  unavoidable: the catalog's `Expr.log` constructor is not redundant.  The proof
  is algebraic (an `(X - a)`-adic valuation argument on the Wronskian identity
  `(X - a) * (P'Q - PQ') = c Q²`), not analytic.

* **The first-order Risch differential equation (Conjecture 3, forward half).**
  `risch_de_poly_solvable` solves `q' + a q = p` in `ℚ[X]` for every `a ≠ 0`,
  which is exactly the Risch differential equation attached to the exponential
  extension `ℚ(x, exp(a x))`.  Consequently every `p(x) exp(a x)` has an
  elementary antiderivative in the catalog's EML syntax
  (`exp_poly_has_EML_primitive`), strictly extending the catalog's
  `ExponentialPiece`, which only handles constant `p`.
-/

noncomputable section

open Polynomial EMLDifferentialClosure

namespace RischResidue

/-! ## Polynomials inside the catalog expression language -/

private lemma sum_list_range (f : ℕ → ℝ) (n : ℕ) :
    ((List.range n).map f).sum = ∑ i ∈ Finset.range n, f i := by
  induction n with
  | zero => simp
  | succ n ih => simp [List.range_succ, Finset.sum_range_succ, ih]

/-- A rational polynomial, written in the catalog's EML expression syntax. -/
def polyExpr (p : ℚ[X]) : EMLRisch.Expr :=
  EMLRisch.sumExpr ((List.range (p.natDegree + 1)).map
    fun i => EMLRisch.Expr.qsmul (p.coeff i) (EMLRisch.Expr.npow .var i))

@[simp] theorem eval_polyExpr (p : ℚ[X]) (x : ℝ) :
    Expr.eval (polyExpr p) x = aeval x p := by
  rw [polyExpr, EMLRisch.eval_sumExpr, List.map_map, sum_list_range, aeval_eq_sum_range]
  refine Finset.sum_congr rfl fun i _ => ?_
  simp [Function.comp, Rat.smul_def, Expr.eval]

/-! ## Residues of a rational function with split rational denominator -/

/-- The residue of `p(x) / ∏_{b ∈ s} (x - b)` at the simple pole `a ∈ s`. -/
def residue (s : Finset ℚ) (p : ℚ[X]) (a : ℚ) : ℚ :=
  p.eval a / ∏ b ∈ s.erase a, (a - b)

/-- Lagrange interpolation rewrites a low-degree numerator as the residue-weighted
sum of the cofactors of the split denominator. -/
theorem numerator_eq_residue_sum (s : Finset ℚ) (p : ℚ[X]) (hdeg : p.degree < s.card) :
    p = ∑ a ∈ s, C (residue s p a) * ∏ b ∈ s.erase a, (X - C b) := by
  have h := Lagrange.eq_interpolate (v := id) (s := s) (f := p) (Set.injOn_id _) hdeg
  rw [Lagrange.interpolate_eq_sum] at h
  simpa [residue] using h

/-- Dividing a residue-weighted cofactor sum by the split denominator gives the
partial-fraction shape. -/
theorem cofactor_sum_div (s : Finset ℚ) (c : ℚ → ℝ) {x : ℝ}
    (hx : ∀ a ∈ s, x ≠ (a : ℝ)) :
    (∑ a ∈ s, c a * ∏ b ∈ s.erase a, (x - (b : ℝ))) / ∏ a ∈ s, (x - (a : ℝ))
      = ∑ a ∈ s, c a / (x - (a : ℝ)) := by
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl fun a ha => ?_
  have hprod : ∏ b ∈ s, (x - (b : ℝ)) = (x - (a : ℝ)) * ∏ b ∈ s.erase a, (x - (b : ℝ)) :=
    (Finset.mul_prod_erase s _ ha).symm
  have hne : ∏ b ∈ s.erase a, (x - (b : ℝ)) ≠ 0 := by
    refine Finset.prod_ne_zero_iff.mpr fun b hb => ?_
    exact sub_ne_zero.mpr (hx b (Finset.mem_of_mem_erase hb))
  have hxa : x - (a : ℝ) ≠ 0 := sub_ne_zero.mpr (hx a ha)
  rw [hprod]
  field_simp

/-- **Partial fractions over a split rational denominator.**  Away from the poles the
rational function equals the sum of its simple-pole residue terms. -/
theorem partialFraction_eval (s : Finset ℚ) (p : ℚ[X]) (hdeg : p.degree < s.card) {x : ℝ}
    (hx : ∀ a ∈ s, x ≠ (a : ℝ)) :
    (aeval x p) / ∏ a ∈ s, (x - (a : ℝ)) = ∑ a ∈ s, (residue s p a : ℝ) / (x - (a : ℝ)) := by
  have key : (aeval x p : ℝ)
      = ∑ a ∈ s, (residue s p a : ℝ) * ∏ b ∈ s.erase a, (x - (b : ℝ)) := by
    conv_lhs => rw [numerator_eq_residue_sum s p hdeg]
    simp
  rw [key, cofactor_sum_div s _ hx]

/-- **The residue sum is the subleading coefficient.**  For a split denominator with `n`
distinct poles, the residues of `p / ∏ (x - a)` add up to the coefficient of `x^{n-1}` in
`p`; in particular they sum to zero exactly when `deg p ≤ n - 2`. -/
theorem residue_sum (s : Finset ℚ) (p : ℚ[X]) (hdeg : p.degree < s.card) :
    ∑ a ∈ s, residue s p a = p.coeff (s.card - 1) := by
  have h := congrArg (fun r : ℚ[X] => r.coeff (s.card - 1))
    (numerator_eq_residue_sum s p hdeg)
  simp only [Polynomial.finset_sum_coeff, Polynomial.coeff_C_mul] at h
  rw [h]
  refine Finset.sum_congr rfl fun a ha => ?_
  have hm : (∏ b ∈ s.erase a, (X - C b) : ℚ[X]).Monic :=
    monic_prod_of_monic _ _ fun b _ => monic_X_sub_C b
  have hd : (∏ b ∈ s.erase a, (X - C b) : ℚ[X]).natDegree = s.card - 1 := by
    rw [Polynomial.natDegree_prod _ _ (fun b _ => X_sub_C_ne_zero b)]
    simp [Finset.card_erase_of_mem ha]
  rw [← hd, hm.coeff_natDegree, mul_one]

/-! ## Uniqueness of the logarithmic coefficients -/

/-- **Uniqueness of residues.**  Two sums of simple-pole terms over the same finite pole
set that agree at every regular real point have equal coefficients.  Together with
`partialFraction_eval` this says the logarithmic coefficients of the antiderivative are
exactly the residues, with no freedom of choice. -/
theorem residue_coefficients_unique (s : Finset ℚ) (c d : ℚ → ℚ)
    (h : ∀ x : ℝ, (∀ a ∈ s, x ≠ (a : ℝ)) →
      ∑ a ∈ s, (c a : ℝ) / (x - (a : ℝ)) = ∑ a ∈ s, (d a : ℝ) / (x - (a : ℝ))) :
    ∀ a ∈ s, c a = d a := by
  set e : ℚ → ℚ := fun a => c a - d a with he
  set P : ℚ[X] := ∑ a ∈ s, C (e a) * ∏ b ∈ s.erase a, (X - C b) with hP
  have hPzero : P = 0 := by
    have hmap : P.map (algebraMap ℚ ℝ) = 0 := by
      refine Polynomial.eq_zero_of_infinite_isRoot _ ?_
      have hsub : ((↑) '' (s : Set ℚ))ᶜ ⊆ {x : ℝ | (P.map (algebraMap ℚ ℝ)).IsRoot x} := by
        intro x hxmem
        have hx : ∀ a ∈ s, x ≠ (a : ℝ) := by
          intro a ha hxa
          exact hxmem ⟨a, ha, hxa.symm⟩
        have h0 : ∑ a ∈ s, (e a : ℝ) / (x - (a : ℝ)) = 0 := by
          have h1 := h x hx
          have h2 : ∑ a ∈ s, ((c a : ℝ) / (x - (a : ℝ)) - (d a : ℝ) / (x - (a : ℝ))) = 0 := by
            rw [Finset.sum_sub_distrib, h1, sub_self]
          rw [← h2]
          refine Finset.sum_congr rfl fun a _ => ?_
          simp only [he]
          push_cast
          ring
        have hD : (∏ a ∈ s, (x - (a : ℝ))) ≠ 0 := by
          refine Finset.prod_ne_zero_iff.mpr fun b hb => sub_ne_zero.mpr (hx b hb)
        have hN : (∑ a ∈ s, (e a : ℝ) * ∏ b ∈ s.erase a, (x - (b : ℝ))) = 0 := by
          have hcof := cofactor_sum_div s (fun a => (e a : ℝ)) hx
          rw [h0] at hcof
          exact (div_eq_zero_iff.mp hcof).resolve_right hD
        simp only [Set.mem_setOf_eq, Polynomial.IsRoot.def, Polynomial.eval_map,
          ← Polynomial.aeval_def, hP]
        simpa using hN
      exact Set.Infinite.mono hsub
        (Set.Finite.infinite_compl ((s : Set ℚ).toFinite.image _))
    exact (Polynomial.map_eq_zero_iff (algebraMap ℚ ℝ).injective).mp hmap
  intro a ha
  have hev : P.eval a = e a * ∏ b ∈ s.erase a, (a - b) := by
    rw [hP]
    rw [Polynomial.eval_finset_sum]
    rw [Finset.sum_eq_single a]
    · simp [Polynomial.eval_prod]
    · intro b hb hba
      have : ∃ z ∈ s.erase b, (a : ℚ) - z = 0 :=
        ⟨a, Finset.mem_erase.mpr ⟨Ne.symm hba, ha⟩, by ring⟩
      obtain ⟨z, hz, hz0⟩ := this
      simp only [Polynomial.eval_mul, Polynomial.eval_prod, Polynomial.eval_sub,
        Polynomial.eval_X, Polynomial.eval_C]
      rw [Finset.prod_eq_zero hz hz0, mul_zero]
    · intro hna; exact absurd ha hna
  have hne : (∏ b ∈ s.erase a, (a - b)) ≠ 0 := by
    refine Finset.prod_ne_zero_iff.mpr fun b hb => ?_
    exact sub_ne_zero.mpr (Finset.ne_of_mem_erase hb).symm
  have : e a = 0 := by
    have := hev
    rw [hPzero] at this
    simp only [Polynomial.eval_zero] at this
    exact (mul_eq_zero.mp this.symm).resolve_right hne
  simp only [he] at this
  linarith [this]

/-! ## The certified split-denominator antiderivative -/

/-- The rational normal form of `p(x) / ∏_{a ∈ s} (x - a)`: only simple poles, with the
residues as coefficients. -/
def splitForm (s : Finset ℚ) (p : ℚ[X]) : EMLRisch.RationalNormalForm where
  polynomial := []
  simplePoles := s.toList.map fun a => ⟨residue s p a, a⟩
  higherPoles := []

theorem splitForm_regularAt (s : Finset ℚ) (p : ℚ[X]) {x : ℝ}
    (hx : ∀ a ∈ s, x ≠ (a : ℝ)) : (splitForm s p).toNormalForm.RegularAt x := by
  constructor
  · intro q hq
    simp only [EMLRisch.RationalNormalForm.toNormalForm, splitForm, List.mem_map] at hq
    obtain ⟨a, ha, rfl⟩ := hq
    exact hx a (Finset.mem_toList.mp ha)
  · intro q hq
    simp [EMLRisch.RationalNormalForm.toNormalForm, splitForm] at hq

theorem splitForm_integrand_eval (s : Finset ℚ) (p : ℚ[X]) (hdeg : p.degree < s.card)
    {x : ℝ} (hx : ∀ a ∈ s, x ≠ (a : ℝ)) :
    Expr.eval (splitForm s p).toNormalForm.integrand x
      = (aeval x p) / ∏ a ∈ s, (x - (a : ℝ)) := by
  rw [partialFraction_eval s p hdeg hx]
  simp only [EMLRisch.NormalForm.integrand, EMLRisch.RationalNormalForm.toNormalForm,
    splitForm, List.map_nil, List.nil_append, List.append_nil, EMLRisch.eval_sumExpr,
    List.map_map]
  rw [← Finset.sum_map_toList s (fun a => (residue s p a : ℝ) / (x - (a : ℝ)))]
  congr 1

/-- **Conjecture 4, certified.**  A rational function whose denominator splits into
rational linear factors is integrated by the catalog Risch procedure, and the
antiderivative is a combination of logarithms of the affine factors whose coefficients
are the simple-pole residues. -/
theorem split_denominator_risch (s : Finset ℚ) (p : ℚ[X]) (hdeg : p.degree < s.card) :
    IsEML (Expr.eval (EMLRisch.risch (splitForm s p).toNormalForm)) ∧
    ∀ x : ℝ, (∀ a ∈ s, x ≠ (a : ℝ)) →
      HasDerivAt (Expr.eval (EMLRisch.risch (splitForm s p).toNormalForm))
        ((aeval x p) / ∏ a ∈ s, (x - (a : ℝ))) x := by
  refine ⟨⟨_, rfl⟩, fun x hx => ?_⟩
  have := EMLRisch.risch_sound (splitForm s p).toNormalForm (splitForm_regularAt s p hx)
  rwa [splitForm_integrand_eval s p hdeg hx] at this

/-- The produced primitive is literally `∑ residue * log (x - a)`. -/
theorem split_denominator_primitive_eval (s : Finset ℚ) (p : ℚ[X]) (x : ℝ) :
    Expr.eval (EMLRisch.risch (splitForm s p).toNormalForm) x
      = ∑ a ∈ s, (residue s p a : ℝ) * Real.log (x - (a : ℝ)) := by
  rw [← Finset.sum_map_toList s (fun a => (residue s p a : ℝ) * Real.log (x - (a : ℝ)))]
  simp only [EMLRisch.risch, EMLRisch.RationalNormalForm.toNormalForm, splitForm,
    EMLRisch.algebraicPart, EMLRisch.logarithmicPart, EMLRisch.rationalPolePart,
    EMLRisch.exponentialPart, List.map_nil, EMLRisch.eval_sumExpr, List.map_map,
    List.map_cons, List.sum_cons, List.sum_nil, zero_add, add_zero]
  congr 1

/-! ## The logarithms are unavoidable: a Liouville obstruction -/

/-- The Wronskian identity forced on a hypothetical rational primitive of `c / (x - a)`. -/
theorem wronskian_identity_of_primitive (P Q : ℝ[X]) (a c : ℝ) (hQ : Q ≠ 0)
    (h : ∀ x : ℝ, a < x → Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => P.eval y / Q.eval y) (c / (x - a)) x) :
    (X - C a) * (derivative P * Q - P * derivative Q) = C c * Q ^ 2 := by
  have hzero : (X - C a) * (derivative P * Q - P * derivative Q) - C c * Q ^ 2 = 0 := by
    refine Polynomial.eq_zero_of_infinite_isRoot _ (Set.Infinite.mono ?_
      ((Set.Ioi_infinite a).diff (Polynomial.finite_setOf_isRoot hQ)))
    rintro x ⟨hx, hQx⟩
    have hQx' : Q.eval x ≠ 0 := hQx
    have hd := (P.hasDerivAt x).div (Q.hasDerivAt x) hQx'
    have heq := (h x hx hQx').unique hd
    have hx0 : x - a ≠ 0 := sub_ne_zero.mpr (ne_of_gt hx)
    simp only [Set.mem_setOf_eq, IsRoot.def, eval_sub, eval_mul, eval_X, eval_C, eval_pow]
    field_simp at heq ⊢
    linarith [heq]
  exact sub_eq_zero.mp hzero

/-- The Wronskian identity `(X - a) * (P'Q - P Q') = c Q²` has no coprime solution when
`c ≠ 0`: an `(X - a)`-adic valuation argument at the pole. -/
theorem no_coprime_wronskian_solution (P Q : ℝ[X]) (a c : ℝ) (hc : c ≠ 0) (hQ : Q ≠ 0)
    (hco : IsCoprime P Q)
    (hid : (X - C a) * (derivative P * Q - P * derivative Q) = C c * Q ^ 2) : False := by
  have hprime := Polynomial.prime_X_sub_C a
  have hXQ2 : (X - C a : ℝ[X]) ∣ C c * Q ^ 2 := ⟨_, hid.symm⟩
  have hXQ : (X - C a : ℝ[X]) ∣ Q := by
    rcases hprime.dvd_mul.mp hXQ2 with hcc | hpow
    · exact absurd (isUnit_of_dvd_unit hcc
        ((Polynomial.isUnit_C).mpr (isUnit_iff_ne_zero.mpr hc))) hprime.not_unit
    · exact hprime.dvd_of_dvd_pow hpow
  set k := Q.rootMultiplicity a with hk
  have hkpos : 0 < k := by
    rw [hk, Polynomial.rootMultiplicity_pos hQ]
    simpa [Polynomial.IsRoot, Polynomial.dvd_iff_isRoot] using hXQ
  obtain ⟨j, hj⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  set R := Q /ₘ (X - C a) ^ k with hR
  have hQeq : Q = (X - C a) ^ (j + 1) * R := by
    have := Polynomial.pow_mul_divByMonic_rootMultiplicity_eq Q a
    rw [← hk, ← hR] at this
    simpa [hj] using this.symm
  have hR0 : R.eval a ≠ 0 := Polynomial.eval_divByMonic_pow_rootMultiplicity_ne_zero a hQ
  set U : ℝ[X] := derivative P * (X - C a) * R - C ((j : ℝ) + 1) * P * R
      - P * (X - C a) * derivative R with hU
  have hkey : ((X - C a : ℝ[X])) ^ (j + 1) * U
      = (X - C a) ^ (j + 1) * (C c * (X - C a) ^ (j + 1) * R ^ 2) := by
    have h1 : (X - C a) * (derivative P * Q - P * derivative Q) = (X - C a) ^ (j + 1) * U := by
      rw [hQeq, hU]
      simp only [derivative_mul, derivative_pow, derivative_sub, derivative_X, derivative_C,
        sub_zero, mul_one, Nat.add_sub_cancel]
      push_cast
      ring
    have h2 : C c * Q ^ 2 = (X - C a) ^ (j + 1) * (C c * (X - C a) ^ (j + 1) * R ^ 2) := by
      rw [hQeq]; ring
    rw [← h1, ← h2, hid]
  have hXne : ((X - C a : ℝ[X])) ^ (j + 1) ≠ 0 := pow_ne_zero _ (Polynomial.X_sub_C_ne_zero a)
  have hU' : U = C c * (X - C a) ^ (j + 1) * R ^ 2 := mul_left_cancel₀ hXne hkey
  have h := congrArg (Polynomial.eval a) hU'
  rw [hU] at h
  simp only [eval_sub, eval_mul, eval_X, eval_C, eval_pow, sub_self, mul_zero, zero_mul,
    zero_sub, zero_pow (Nat.succ_ne_zero j)] at h
  have hj1 : (0 : ℝ) < (j : ℝ) + 1 := by positivity
  have hP0 : P.eval a = 0 := by
    rcases mul_eq_zero.mp (by nlinarith [h] : (P.eval a) * (R.eval a) = 0) with h' | h'
    · exact h'
    · exact absurd h' hR0
  have hXP : (X - C a : ℝ[X]) ∣ P := (Polynomial.dvd_iff_isRoot).mpr hP0
  exact hprime.not_unit (hco.isUnit_of_dvd' hXP hXQ)

/-- **A simple pole with nonzero residue has no rational primitive.**  Hence the
logarithmic part produced by the residue criterion cannot be replaced by any rational
function: the catalog's `Expr.log` constructor is genuinely needed. -/
theorem no_rational_primitive_of_simple_pole (P Q : ℝ[X]) (a c : ℝ) (hc : c ≠ 0) (hQ : Q ≠ 0)
    (hco : IsCoprime P Q)
    (h : ∀ x : ℝ, a < x → Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => P.eval y / Q.eval y) (c / (x - a)) x) : False :=
  no_coprime_wronskian_solution P Q a c hc hQ hco (wronskian_identity_of_primitive P Q a c hQ h)

/-- The classical special case: `1 / x` is not the derivative of a rational function. -/
theorem no_rational_primitive_of_inv (P Q : ℝ[X]) (hQ : Q ≠ 0) (hco : IsCoprime P Q)
    (h : ∀ x : ℝ, 0 < x → Q.eval x ≠ 0 →
      HasDerivAt (fun y : ℝ => P.eval y / Q.eval y) (1 / x) x) : False := by
  refine no_rational_primitive_of_simple_pole P Q 0 1 one_ne_zero hQ hco ?_
  intro x hx hQx
  simpa using h x hx hQx

/-! ## The first-order Risch differential equation over one exponential extension -/

/-- **Risch differential equation.**  For `a ≠ 0` the operator `q ↦ q' + a q` is onto
`ℚ[X]`; this is the polynomial part of the exponential Risch step. -/
theorem risch_de_poly_solvable (a : ℚ) (ha : a ≠ 0) (p : ℚ[X]) :
    ∃ q : ℚ[X], derivative q + C a * q = p := by
  suffices H : ∀ n : ℕ, ∀ p : ℚ[X], p.natDegree ≤ n → ∃ q : ℚ[X], derivative q + C a * q = p from
    H p.natDegree p le_rfl
  intro n
  induction n with
  | zero =>
    intro p hp
    obtain ⟨c, rfl⟩ : ∃ c, p = C c := ⟨p.coeff 0, Polynomial.eq_C_of_natDegree_le_zero hp⟩
    refine ⟨C (c / a), ?_⟩
    rw [derivative_C, zero_add, ← C_mul]
    congr 1
    field_simp
  | succ n ih =>
    intro p hp
    set c := p.coeff (n + 1) with hc
    set q0 : ℚ[X] := C (c / a) * X ^ (n + 1) with hq0def
    have hq0 : derivative q0 + C a * q0 = C (c / a * (n + 1)) * X ^ n + C c * X ^ (n + 1) := by
      rw [hq0def]
      simp only [derivative_mul, derivative_C, zero_mul, zero_add, derivative_X_pow,
        Nat.add_sub_cancel, ← C_mul, ← mul_assoc]
      congr 2
      · push_cast; ring
      · field_simp
    set r := p - (derivative q0 + C a * q0) with hrdef
    have hr : r.natDegree ≤ n := by
      rw [Polynomial.natDegree_le_iff_coeff_eq_zero]
      intro m hm
      rw [hrdef, hq0]
      simp only [coeff_sub, coeff_add, coeff_C_mul, coeff_X_pow]
      rcases eq_or_lt_of_le (Nat.succ_le_of_lt hm) with h | h
      · simp [← h, hc]
      · have hpm : p.coeff m = 0 := Polynomial.coeff_eq_zero_of_natDegree_lt (lt_of_le_of_lt hp h)
        have h1 : m ≠ n + 1 := by omega
        have h2 : m ≠ n := by omega
        simp [hpm, h1, h2]
    obtain ⟨q1, hq1⟩ := ih r hr
    refine ⟨q0 + q1, ?_⟩
    rw [derivative_add, mul_add]
    rw [hrdef] at hq1
    linear_combination hq1

/-- The homogeneous Risch differential equation `d' + a d = 0` has only the trivial
polynomial solution when `a ≠ 0`. -/
theorem risch_de_homogeneous_trivial (a : ℚ) (ha : a ≠ 0) (d : ℚ[X])
    (h : derivative d + C a * d = 0) : d = 0 := by
  by_contra hd
  set n := d.natDegree with hn
  have hc := congrArg (fun r : ℚ[X] => r.coeff n) h
  simp only [coeff_add, coeff_derivative, coeff_C_mul, coeff_zero] at hc
  have h1 : d.coeff (n + 1) = 0 := Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)
  have h2 : d.coeff n ≠ 0 := Polynomial.leadingCoeff_ne_zero.mpr hd
  rw [h1, zero_mul, zero_add] at hc
  exact h2 ((mul_eq_zero.mp hc).resolve_left ha)

/-- **The Risch differential equation has a unique polynomial solution.**  The
normalization produced by the exponential Risch step is therefore canonical. -/
theorem risch_de_poly_unique (a : ℚ) (ha : a ≠ 0) (p : ℚ[X]) :
    ∃! q : ℚ[X], derivative q + C a * q = p := by
  obtain ⟨q, hq⟩ := risch_de_poly_solvable a ha p
  refine ⟨q, hq, fun q' hq' => ?_⟩
  have hdiff : derivative (q' - q) + C a * (q' - q) = 0 := by
    rw [derivative_sub, mul_sub]
    linear_combination hq' - hq
  have := risch_de_homogeneous_trivial a ha _ hdiff
  linear_combination this

/-- The catalog EML expression `q(x) exp(a x)`. -/
def expPolyExpr (q : ℚ[X]) (a : ℚ) : EMLRisch.Expr :=
  .mul (polyExpr q) (.exp (EMLRisch.Expr.qsmul a .var))

@[simp] theorem eval_expPolyExpr (q : ℚ[X]) (a : ℚ) (x : ℝ) :
    Expr.eval (expPolyExpr q a) x = (aeval x q) * Real.exp ((a : ℝ) * x) := by
  simp [expPolyExpr, Expr.eval, EMLRisch.Expr.qsmul]

/-- **Conjecture 3, constructive forward half.**  Every `p(x) exp(a x)` with `a ≠ 0`
rational has an elementary antiderivative inside the catalog EML language, namely
`q(x) exp(a x)` for the solution `q` of the Risch differential equation. -/
theorem exp_poly_has_EML_primitive (a : ℚ) (ha : a ≠ 0) (p : ℚ[X]) :
    ∃ F : EMLRisch.Expr, IsEML (Expr.eval F) ∧
      ∀ x : ℝ, HasDerivAt (Expr.eval F) ((aeval x p) * Real.exp ((a : ℝ) * x)) x := by
  obtain ⟨q, hq⟩ := risch_de_poly_solvable a ha p
  refine ⟨expPolyExpr q a, ⟨_, rfl⟩, fun x => ?_⟩
  have hfun : Expr.eval (expPolyExpr q a) = fun y : ℝ => (aeval y q) * Real.exp ((a : ℝ) * y) :=
    funext fun y => eval_expPolyExpr q a y
  rw [hfun]
  set Q : ℝ[X] := q.map (algebraMap ℚ ℝ) with hQ
  have hQe : ∀ y : ℝ, (aeval y q : ℝ) = Q.eval y := by
    intro y; simp [hQ, aeval_def, eval_map]
  have hd : (derivative Q).eval x = (aeval x (derivative q) : ℝ) := by
    simp [hQ, Polynomial.derivative_map, aeval_def, eval_map]
  have hp : (aeval x p : ℝ) = aeval x (derivative q) + (a : ℝ) * aeval x q := by
    rw [← hq]; simp
  have h1 : HasDerivAt (fun y : ℝ => Q.eval y) ((derivative Q).eval x) x := Q.hasDerivAt x
  have h2 : HasDerivAt (fun y : ℝ => Real.exp ((a : ℝ) * y))
      (Real.exp ((a : ℝ) * x) * (a : ℝ)) x := by
    simpa using ((hasDerivAt_id x).const_mul (a : ℝ)).exp
  have h3 := h1.mul h2
  simp only [hQe]
  convert h3 using 1
  rw [hp, hd, hQe x]
  ring

end RischResidue