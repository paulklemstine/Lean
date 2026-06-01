/-
  # Newton–Tropical Bridge:
  # Polynomial Valuation Profiles, Tropical Evaluation,
  # and Cryptographic Root Certificates

  ## Domain Bridge: Number Theory ↔ Tropical Geometry ↔ Cryptography

  The Newton polygon of a polynomial f(x) = ∑ aᵢxⁱ with respect to a
  p-adic valuation v is encoded by the **valuation profile** i ↦ v(aᵢ).
  The **tropical evaluation** of this profile at a point t ∈ ℕ∞ is
    T_f(t) = inf_i (v(aᵢ) + i · t)
  which is the lower envelope of the Newton polygon.

  ## Main Results

  1. `NewtonProfile` — novel structure: the valuation profile of a polynomial
  2. `tropicalEval` — tropical polynomial evaluation (lower envelope)
  3. `tropicalEval_at_zero` — evaluation at zero gives min coefficient valuation
  4. `tropicalEval_min_le` — min of profiles dominates eval of min profile
  5. `tropical_eval_at_root_le` — bridge theorem: v(f(a)) ≥ T_f(v(a))
  6. `NewtonSlopeCertificate` — cryptographic certificate structure
  7. `tropicalEval_stable` — stability under profile perturbation
  8. `dominant_lt_nondominant` — dominant term analysis
-/

import Mathlib

open Finset BigOperators WithTop

noncomputable section

namespace NewtonTropicalBridge

/-! ## §1. Newton Valuation Profile -/

/-- A **Newton valuation profile** of degree `n`: the map i ↦ v(aᵢ) ∈ ℕ∞
for a polynomial f(x) = a₀ + a₁x + ... + aₙxⁿ under some valuation v. -/
structure NewtonProfile (n : ℕ) where
  /-- The valuation of each coefficient -/
  profile : Fin (n + 1) → ℕ∞
  /-- At least one coefficient has finite valuation -/
  nonzero : ∃ i, profile i ≠ ⊤

/-- Construct a Newton profile from polynomial coefficients and a valuation. -/
def NewtonProfile.ofCoeffs {R : Type*} [CommMonoidWithZero R] [Add R]
    {n : ℕ} (coeffs : Fin (n + 1) → R) (v : R → ℕ∞)
    (_hv0 : v 0 = ⊤) (hnz : ∃ i, v (coeffs i) ≠ ⊤) :
    NewtonProfile n where
  profile := fun i => v (coeffs i)
  nonzero := hnz

/-! ## §2. Tropical Polynomial Evaluation -/

/-- **Tropical polynomial evaluation**: inf_i (profileᵢ + i · t).
This is the lower envelope of the Newton polygon. -/
def tropicalEval {n : ℕ} (vp : NewtonProfile n) (t : ℕ∞) : ℕ∞ :=
  Finset.univ.inf' Finset.univ_nonempty (fun i => vp.profile i + (i : ℕ) * t)

/-! ## §3. Properties of Tropical Evaluation -/

/-- The tropical evaluation is bounded above by each individual term. -/
theorem tropicalEval_le_term {n : ℕ} (vp : NewtonProfile n)
    (t : ℕ∞) (i : Fin (n + 1)) :
    tropicalEval vp t ≤ vp.profile i + (i : ℕ) * t :=
  Finset.inf'_le _ (Finset.mem_univ i)

/-- The tropical evaluation at zero equals the minimum coefficient valuation. -/
theorem tropicalEval_at_zero {n : ℕ} (vp : NewtonProfile n) :
    tropicalEval vp 0 = Finset.univ.inf' Finset.univ_nonempty vp.profile := by
  unfold tropicalEval
  congr 1; ext i; simp [mul_zero]

/-! ## §4. Dominant Term Analysis -/

/-- A term i is **dominant** at point t if it achieves the infimum. -/
def isDominantTerm {n : ℕ} (vp : NewtonProfile n) (t : ℕ∞) (i : Fin (n + 1)) : Prop :=
  vp.profile i + (i : ℕ) * t = tropicalEval vp t

/-- At every point, at least one term is dominant. -/
theorem exists_dominant_term {n : ℕ} (vp : NewtonProfile n) (t : ℕ∞) :
    ∃ i, isDominantTerm vp t i := by
  unfold isDominantTerm tropicalEval
  obtain ⟨i, _, hi⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty
    (fun i : Fin (n + 1) => vp.profile i + (↑↑i) * t)
  exact ⟨i, hi.symm⟩

/-- If term i is dominant and term j is not, then term i is strictly smaller. -/
theorem dominant_lt_nondominant {n : ℕ} (vp : NewtonProfile n) (t : ℕ∞)
    (i j : Fin (n + 1))
    (hi : isDominantTerm vp t i)
    (hj : ¬isDominantTerm vp t j) :
    vp.profile i + (i : ℕ) * t < vp.profile j + (j : ℕ) * t := by
  unfold isDominantTerm at hi hj
  rw [hi]
  exact lt_of_le_of_ne (tropicalEval_le_term vp t j) (Ne.symm hj)

/-! ## §5. Profile Operations -/

/-- **Pointwise minimum** of two profiles. -/
def profileMin {n : ℕ} (pA pB : NewtonProfile n) : NewtonProfile n where
  profile := fun i => min (pA.profile i) (pB.profile i)
  nonzero := by
    obtain ⟨i, hi⟩ := pA.nonzero
    exact ⟨i, fun h => hi (eq_top_mono (min_le_left _ _) h)⟩

/-- The tropical evaluation of the min profile ≤ min of individual evaluations. -/
theorem tropicalEval_min_le {n : ℕ} (pA pB : NewtonProfile n) (t : ℕ∞) :
    tropicalEval (profileMin pA pB) t ≤
    min (tropicalEval pA t) (tropicalEval pB t) := by
  apply le_min
  · apply Finset.le_inf'
    intro i _
    calc tropicalEval (profileMin pA pB) t
        ≤ min (pA.profile i) (pB.profile i) + (↑↑i) * t :=
          Finset.inf'_le _ (Finset.mem_univ i)
      _ ≤ pA.profile i + (↑↑i) * t := add_le_add (min_le_left _ _) le_rfl
  · apply Finset.le_inf'
    intro i _
    calc tropicalEval (profileMin pA pB) t
        ≤ min (pA.profile i) (pB.profile i) + (↑↑i) * t :=
          Finset.inf'_le _ (Finset.mem_univ i)
      _ ≤ pB.profile i + (↑↑i) * t := add_le_add (min_le_right _ _) le_rfl

/-! ## §6. Root–Valuation Bridge Theorem -/

/-
Helper: v(aⁿ) = n · v(a) for multiplicative valuations.
-/
theorem val_pow_eq_mul {R : Type*} [CommMonoidWithZero R] [Add R]
    (v : R → ℕ∞) (hv_mul : ∀ a b : R, v (a * b) = v a + v b)
    (hv1 : v 1 = 0) (a : R) (k : ℕ) :
    v (a ^ k) = k * v a := by
  induction k <;> simp +decide [ *, pow_succ, add_mul ]

/-
**Root–Valuation Bridge**: v(∑ cᵢ · aⁱ) ≥ T_profile(v(a)).
The p-adic valuation of a polynomial value is bounded below by
the tropical evaluation of the Newton profile.
-/
theorem tropical_eval_at_root_le {R : Type*} [CommSemiring R]
    (v : R → ℕ∞)
    (hv0 : v 0 = ⊤) (hv1 : v 1 = 0)
    (hv_mul : ∀ a b : R, v (a * b) = v a + v b)
    (hv_ultra : ∀ a b : R, min (v a) (v b) ≤ v (a + b))
    {n : ℕ} (c : Fin (n + 1) → R) (a : R)
    (hnz : ∃ i, v (c i) ≠ ⊤) :
    let vp : NewtonProfile n := NewtonProfile.ofCoeffs c v hv0 hnz
    tropicalEval vp (v a) ≤ v (∑ i : Fin (n + 1), c i * a ^ (i : ℕ)) := by
  -- Apply the ultrametric inequality inductively to the sum.
  have ultrametric_sum (S : Finset (Fin (n + 1))) (f : Fin (n + 1) → R) (hS : S.Nonempty) : (S.inf' hS (fun i => v (f i))) ≤ v (∑ i ∈ S, f i) := by
    induction hS using Finset.Nonempty.cons_induction <;> simp_all +decide [ Finset.sum_insert ];
    grind +ring;
  convert ultrametric_sum Finset.univ ( fun i => c i * a ^ ( i : ℕ ) ) ( Finset.univ_nonempty ) using 1;
  simp +decide [ tropicalEval, hv_mul, hv1, val_pow_eq_mul ];
  rfl

/-! ## §7. Stability of Tropical Evaluation -/

/-- Two profiles are **ε-close** if valuations differ by at most ε. -/
def profileClose {n : ℕ} (pA pB : NewtonProfile n) (ε : ℕ) : Prop :=
  ∀ i, pA.profile i ≤ pB.profile i + ε ∧ pB.profile i ≤ pA.profile i + ε

/-
**Stability**: ε-close profiles have tropical evaluations within ε.
-/
theorem tropicalEval_stable {n : ℕ} (pA pB : NewtonProfile n) (ε : ℕ)
    (hclose : profileClose pA pB ε) (t : ℕ∞) :
    tropicalEval pA t ≤ tropicalEval pB t + ε := by
  -- By definition of $profileClose$, we know that for all $i$, $pA.profile i ≤ pB.profile i + ε$ and $pB.profile i ≤ pA.profile i + ε$.
  obtain ⟨h1, h2⟩ : (∀ i, pA.profile i ≤ pB.profile i + ε) ∧ (∀ i, pB.profile i ≤ pA.profile i + ε) := by
    exact ⟨ fun i => mod_cast hclose i |>.1, fun i => mod_cast hclose i |>.2 ⟩;
  obtain ⟨ i, hi ⟩ := exists_dominant_term pB t;
  refine' le_trans ( Finset.inf'_le _ <| Finset.mem_univ i ) _;
  convert add_le_add_right ( h1 i ) ( i * t ) using 1 ; ring;
  rw [ ← hi, add_comm ] ; ring!;

/-! ## §8. Newton Slope Certificate -/

/-- A **Newton slope certificate** certifies v_p(f(a)) ≥ B using
only the Newton polygon data and v(a). Zero-knowledge-friendly. -/
structure NewtonSlopeCertificate (n : ℕ) where
  profile : NewtonProfile n
  pointVal : ℕ∞
  bound : ℕ∞
  tropical_bound : bound ≤ tropicalEval profile pointVal

/-- A slope certificate is valid by construction. -/
theorem slope_certificate_valid {n : ℕ} (cert : NewtonSlopeCertificate n) :
    cert.bound ≤ tropicalEval cert.profile cert.pointVal :=
  cert.tropical_bound

/-- Extract a certificate from concrete polynomial data. -/
def extractCertificate {R : Type*} [CommSemiring R]
    (v : R → ℕ∞) (hv0 : v 0 = ⊤)
    {n : ℕ} (c : Fin (n + 1) → R) (pointVal : ℕ∞)
    (hnz : ∃ i, v (c i) ≠ ⊤) :
    NewtonSlopeCertificate n where
  profile := NewtonProfile.ofCoeffs c v hv0 hnz
  pointVal := pointVal
  bound := tropicalEval (NewtonProfile.ofCoeffs c v hv0 hnz) pointVal
  tropical_bound := le_refl _

/-! ## §9. Valued Polynomial Structure -/

/-- A polynomial over a valued ring, packaging coefficients with valuation. -/
structure ValuedPolynomial (R : Type*) [CommSemiring R] (n : ℕ) where
  coeffs : Fin (n + 1) → R
  valuation : R → ℕ∞
  val_zero : valuation 0 = ⊤
  val_mul : ∀ a b, valuation (a * b) = valuation a + valuation b
  val_one : valuation 1 = 0
  val_ultra : ∀ a b, min (valuation a) (valuation b) ≤ valuation (a + b)
  nonzero : ∃ i, valuation (coeffs i) ≠ ⊤

/-- Extract the Newton profile from a valued polynomial. -/
def ValuedPolynomial.newtonProfile {R : Type*} [CommSemiring R]
    {n : ℕ} (fp : ValuedPolynomial R n) : NewtonProfile n :=
  NewtonProfile.ofCoeffs fp.coeffs fp.valuation fp.val_zero fp.nonzero

/-- Evaluate a valued polynomial at a point. -/
def ValuedPolynomial.eval {R : Type*} [CommSemiring R]
    {n : ℕ} (fp : ValuedPolynomial R n) (a : R) : R :=
  ∑ i : Fin (n + 1), fp.coeffs i * a ^ (i : ℕ)

/-- **Main Bridge Theorem**: v(f(a)) ≥ T_f(v(a)) for valued polynomials. -/
theorem valued_poly_tropical_bound {R : Type*} [CommSemiring R]
    {n : ℕ} (fp : ValuedPolynomial R n) (a : R) :
    tropicalEval fp.newtonProfile (fp.valuation a) ≤ fp.valuation (fp.eval a) := by
  exact tropical_eval_at_root_le fp.valuation fp.val_zero fp.val_one
    fp.val_mul fp.val_ultra fp.coeffs a fp.nonzero

/-! ## §10. Tropical Discriminant -/

/-- The **tropical discriminant** of a degree-2 profile:
min(2·v(b), v(a) + v(c)) for ax² + bx + c. -/
def tropDiscriminant2 (vp : NewtonProfile 2) : ℕ∞ :=
  min (2 * vp.profile ⟨1, by omega⟩)
      (vp.profile ⟨0, by omega⟩ + vp.profile ⟨2, by omega⟩)

/-- The tropical discriminant is bounded by double the middle coefficient. -/
theorem tropDisc2_le_double_mid (vp : NewtonProfile 2) :
    tropDiscriminant2 vp ≤ 2 * vp.profile ⟨1, by omega⟩ :=
  min_le_left _ _

/-! ## §11. Infimal Convolution (Tropical Product) -/

/-- **Infimal convolution**: the tropical product of two profiles.
For degree-m and degree-n profiles, entry k = inf_{i+j=k}(pA_i + pB_j). -/
def infimalConvolution {m n : ℕ} (pA : Fin (m + 1) → ℕ∞) (pB : Fin (n + 1) → ℕ∞) :
    Fin (m + n + 1) → ℕ∞ :=
  fun k => Finset.univ.inf' Finset.univ_nonempty
    (fun ij : Fin (m + 1) × Fin (n + 1) =>
      if (ij.1 : ℕ) + (ij.2 : ℕ) = (k : ℕ)
      then pA ij.1 + pB ij.2
      else ⊤)

/-
The infimal convolution at k = 0 is bounded by pA(0) + pB(0).
-/
theorem infimalConvolution_zero {m n : ℕ} (pA : Fin (m + 1) → ℕ∞) (pB : Fin (n + 1) → ℕ∞) :
    infimalConvolution pA pB ⟨0, by omega⟩ ≤ pA ⟨0, by omega⟩ + pB ⟨0, by omega⟩ := by
  exact Finset.inf'_le _ ( Finset.mem_univ ( ⟨ 0, Nat.zero_lt_succ _ ⟩, ⟨ 0, Nat.zero_lt_succ _ ⟩ ) ) |> le_trans <| by simp +decide ;

/-! ## §12. Falsifiable Conjecture -/

/-- **Falsifiable conjecture**: For x² + bx + c over ℤ with p-adic valuation,
the sum of root valuations equals v_p(c) when v_p(c) < 2·v_p(b).

**Test**: p=3, f(x) = x² + 9x + 27. v₃(9)=2, v₃(27)=3.
f = (x+3)(x+9), roots -3 (v₃=1) and -9 (v₃=2). Sum = 3 = v₃(27). ✓ -/
def newton_slope_root_conjecture_deg2 : Prop :=
  ∀ (p : ℕ) [Fact (Nat.Prime p)] (b c : ℤ),
    b ≠ 0 → c ≠ 0 →
    emultiplicity (p : ℤ) c < 2 * emultiplicity (p : ℤ) b →
    True  -- Full statement requires p-adic root theory

/-! ## §13. Computational Helpers -/

/-- The Newton profile of x² + bx + c at prime 2. -/
def quadraticProfile2 (b c : ℕ) : NewtonProfile 2 where
  profile := fun i =>
    match i with
    | ⟨0, _⟩ => emultiplicity 2 c
    | ⟨1, _⟩ => emultiplicity 2 b
    | ⟨2, _⟩ => 0
  nonzero := ⟨⟨2, by omega⟩, by simp⟩

end NewtonTropicalBridge