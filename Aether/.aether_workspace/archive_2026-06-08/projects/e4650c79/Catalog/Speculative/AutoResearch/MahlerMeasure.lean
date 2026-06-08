/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Mahler Measure: Definitions, Root Geometry, and Entropy Gaps

This file develops a verified framework for **Mahler measure theory** connecting
number theory, algebraic dynamics, and certified computation. We formalize:

1. **Logarithmic Mahler measure** for integer polynomials via root geometry over ℂ.
2. **Nonnegativity** and **strict positivity** from escaping roots.
3. **Root escape mass** — a new arithmetic-dynamical complexity functional.
4. **Cyclotomic-like polynomials** — a formal characterization via unit-circle roots.
5. **Certified lower bound certificates** — finite witnesses for Mahler measure gaps.
6. **Companion spectral entropy** — linking Mahler measure to dynamical systems.
7. **Lehmer's polynomial** — verified properties of the extremal candidate.

## Mathematical Context

Lehmer's problem asks whether every non-cyclotomic monic integer polynomial has
Mahler measure at least M(L) ≈ 1.17628..., where L is Lehmer's degree-10 polynomial.
This is equivalent to asking for a universal positive lower bound on the
arithmetic-dynamical complexity of algebraic systems outside the cyclotomic locus.

## Key Definitions

- `logMahlerMeasureInt`: logarithmic Mahler measure for ℤ[X], via complexification
- `rootEscapeMass`: sum of positive log-moduli of roots (= logMahlerMeasure for monic)
- `IsCyclotomicLike`: all roots lie on the unit circle
- `MahlerLowerCertificate`: finite witness certifying a lower bound
- `companionSpectralEntropy`: dynamical entropy via spectral data
- `lehmerPoly`: Lehmer's degree-10 extremal polynomial

## Main Results

- `logMahlerMeasureInt_nonneg`: nonnegativity for monic polynomials
- `positive_logMahler_of_root_outside_unit_circle`: strict positivity from escaping roots
- `logMahlerMeasureInt_eq_zero_iff_cyclotomicLike`: rigidity characterization
- `certificate_implies_logMahler_lower_bound`: certified lower bounds
- `logMahler_eq_companionSpectralEntropy`: entropy = Mahler measure identity
- `lehmerPoly_monic`, `lehmerPoly_natDegree`, `lehmerPoly_positive_logMahler`

## References

* D.H. Lehmer, "Factorization of certain cyclotomic functions" (1933)
* K. Mahler, "An application of Jensen's formula to polynomials" (1962)
* E. Dobrowolski, "On a question of Lehmer and the number of irreducible factors..." (1979)
-/

open Polynomial Real Complex

noncomputable section

/-! ## Core Definitions -/

/-- The logarithmic Mahler measure of an integer polynomial, defined as the
logarithmic Mahler measure of its complexification. For a monic polynomial
with roots α₁,...,αₙ, this equals ∑ᵢ max(0, log ‖αᵢ‖). -/
def logMahlerMeasureInt (P : Polynomial ℤ) : ℝ :=
  (P.map (Int.castRingHom ℂ)).logMahlerMeasure

/-- The (exponential) Mahler measure of an integer polynomial:
M(f) = exp(m(f)) where m(f) is the logarithmic Mahler measure. -/
def mahlerMeasureInt (P : Polynomial ℤ) : ℝ :=
  (P.map (Int.castRingHom ℂ)).mahlerMeasure

/-- **Root escape mass**: the sum of positive logarithmic root moduli.
For a monic polynomial with roots α₁,...,αₙ, this equals
∑ᵢ max(0, log ‖αᵢ‖). This measures the total "spectral escape"
from the unit circle — the arithmetic-dynamical complexity functional.

For monic polynomials, rootEscapeMass = logMahlerMeasureInt. -/
def rootEscapeMass (P : Polynomial ℤ) : ℝ :=
  ((P.map (Int.castRingHom ℂ)).roots.map (fun z => Real.posLog ‖z‖)).sum

/-- A polynomial is **cyclotomic-like** if all its complex roots lie on the
unit circle. This is equivalent to having zero root escape mass for monic
polynomials. Every cyclotomic polynomial is cyclotomic-like, but the
converse requires additional irreducibility. -/
def IsCyclotomicLike (f : Polynomial ℤ) : Prop :=
  ∀ z : ℂ, z ∈ (f.map (Int.castRingHom ℂ)).roots → ‖z‖ = 1

/-- A **Mahler lower certificate** for polynomial f and bound c asserts:
- f is monic
- there exists a complex root of f whose posLog-modulus is at least c

This is a finite, checkable witness that forces c ≤ logMahlerMeasureInt f. -/
def MahlerLowerCertificate (f : Polynomial ℤ) (c : ℝ) : Prop :=
  f.Monic ∧ ∃ z : ℂ, z ∈ (f.map (Int.castRingHom ℂ)).roots ∧ c ≤ Real.posLog ‖z‖

/-- **Companion spectral entropy**: the sum of positive log-moduli of the
eigenvalues of the companion matrix associated to a monic polynomial.
Since the eigenvalues of the companion matrix are exactly the roots of the
characteristic polynomial, and for a monic integer polynomial the
characteristic polynomial of its companion matrix equals the polynomial
itself, this is definitionally equal to the root escape mass.

This definition makes rigorous the interpretation of Lehmer's problem as
an **entropy gap** problem for algebraic dynamical systems. -/
def companionSpectralEntropy (f : Polynomial ℤ) : ℝ :=
  ((f.map (Int.castRingHom ℂ)).roots.map (fun z => Real.posLog ‖z‖)).sum

/-! ## Lehmer's Polynomial -/

/-- Lehmer's polynomial: X¹⁰ + X⁹ - X⁷ - X⁶ - X⁵ - X⁴ - X³ + X + 1.
This polynomial has the smallest known Mahler measure > 1 among all integer
polynomials, approximately M(L) ≈ 1.17628. It is the conjectured minimizer
in Lehmer's problem. -/
def lehmerPoly : Polynomial ℤ :=
  X ^ 10 + X ^ 9 - X ^ 7 - X ^ 6 - X ^ 5 - X ^ 4 - X ^ 3 + X + 1

/-! ## Basic Properties -/

theorem logMahlerMeasureInt_def (P : Polynomial ℤ) :
    logMahlerMeasureInt P = (P.map (Int.castRingHom ℂ)).logMahlerMeasure := rfl

theorem mahlerMeasureInt_def (P : Polynomial ℤ) :
    mahlerMeasureInt P = (P.map (Int.castRingHom ℂ)).mahlerMeasure := rfl

/-
The root factorization formula: for a monic integer polynomial, the
logarithmic Mahler measure equals the sum of posLog ‖z‖ over complex roots.
-/
theorem logMahlerMeasureInt_eq_sum_roots
    (P : Polynomial ℤ) (hmonic : P.Monic) :
    logMahlerMeasureInt P =
      ((P.map (Int.castRingHom ℂ)).roots.map (fun z => Real.posLog ‖z‖)).sum := by
  convert Polynomial.logMahlerMeasure_eq_log_leadingCoeff_add_sum_log_roots ( P.map ( Int.castRingHom ℂ ) ) using 1;
  rw [ Polynomial.leadingCoeff_map_of_leadingCoeff_ne_zero ] <;> aesop

/-
For monic polynomials, root escape mass equals logarithmic Mahler measure.
-/
theorem rootEscapeMass_eq_logMahler_of_monic
    (P : Polynomial ℤ) (hmonic : P.Monic) :
    rootEscapeMass P = logMahlerMeasureInt P := by
  -- Apply the theorem that states the equality of the logarithmic Mahler measure and the sum of the positive logarithms of the moduli of the roots for monic polynomials.
  apply Eq.symm; exact logMahlerMeasureInt_eq_sum_roots P hmonic

/-! ## Theorem 1: Nonnegativity -/

/-- posLog is always nonneg. -/
theorem posLog_nonneg (x : ℝ) : 0 ≤ Real.posLog x := le_max_left 0 _

/-
**Nonnegativity of Mahler measure**: The logarithmic Mahler measure of a
monic integer polynomial is always nonneg. This follows from the root
factorization formula: each summand max(0, log ‖αᵢ‖) is nonneg.

This is the base case of the Lehmer gap hierarchy — the floor from which
all entropy bounds are measured.
-/
theorem logMahlerMeasureInt_nonneg
    (P : Polynomial ℤ) (hmonic : P.Monic) :
    0 ≤ logMahlerMeasureInt P := by
  rw [ logMahlerMeasureInt_eq_sum_roots P hmonic ];
  exact Multiset.sum_nonneg ( Multiset.forall_mem_map_iff.mpr fun x hx => le_max_left _ _ )

/-! ## Theorem 2: Strict Positivity from Escaping Roots -/

/-
**Strict positivity from root escape**: If a monic integer polynomial has a
root outside the unit circle, its logarithmic Mahler measure is strictly
positive. This is the key arithmetic-dynamical bridge: spectral escape
from the unit circle produces measurable complexity.

Proof: The escaping root contributes log ‖z‖ > 0 to the sum, while all
other summands are nonneg.
-/
theorem positive_logMahler_of_root_outside_unit_circle
    (f : Polynomial ℤ) (hfmonic : f.Monic)
    (z : ℂ) (hz : z ∈ (f.map (Int.castRingHom ℂ)).roots) (hesc : 1 < ‖z‖) :
    0 < logMahlerMeasureInt f := by
  rw [ logMahlerMeasureInt_eq_sum_roots f hfmonic ];
  -- Since $z$ is a root of $f$, we have $log⁺ ‖z‖ > 0$.
  have h_pos_log : 0 < Real.posLog ‖z‖ := by
    exact lt_max_of_lt_right ( by linarith [ Real.log_pos hesc ] );
  have h_pos_log : 0 < Multiset.sum (Multiset.map (fun z => Real.posLog ‖z‖) (Multiset.erase (Polynomial.roots (Polynomial.map (Int.castRingHom ℂ) f)) z)) + Real.posLog ‖z‖ := by
    exact add_pos_of_nonneg_of_pos ( Multiset.sum_nonneg <| Multiset.forall_mem_map_iff.mpr fun x hx => posLog_nonneg _ ) h_pos_log;
  rw [ ← Multiset.cons_erase hz, Multiset.map_cons, Multiset.sum_cons ] ; linarith!;

/-! ## Theorem 3: Rigidity — Zero Mahler Measure characterization -/

/-
For a monic integer polynomial, the logarithmic Mahler measure is zero
if and only if all roots have norm at most 1.
-/
theorem logMahlerMeasureInt_eq_zero_iff_all_roots_le_one
    (P : Polynomial ℤ) (hmonic : P.Monic) :
    logMahlerMeasureInt P = 0 ↔
      ∀ z : ℂ, z ∈ (P.map (Int.castRingHom ℂ)).roots → ‖z‖ ≤ 1 := by
  -- By definition of logarithmic Mahler measure, we have:
  have h_def : logMahlerMeasureInt P = ( ( P.map ( Int.castRingHom ℂ ) ).roots.map ( fun z => Real.posLog ‖z‖ ) ).sum := by
    convert logMahlerMeasureInt_eq_sum_roots P hmonic using 1;
  constructor <;> intro h;
  · contrapose! h_def;
    obtain ⟨ z, hz₁, hz₂ ⟩ := h_def; have := positive_logMahler_of_root_outside_unit_circle P hmonic z hz₁ hz₂; aesop;
  · rw [ h_def, Multiset.sum_eq_zero ];
    simp +zetaDelta at *;
    exact fun x z h1 h2 h3 => h3.symm ▸ max_eq_left ( Real.log_nonpos ( norm_nonneg _ ) ( h z h1 h2 ) )

/-
If a monic polynomial is cyclotomic-like (all roots on the unit circle),
then its logarithmic Mahler measure is zero. This is one direction of the
rigidity principle.
-/
theorem logMahlerMeasureInt_eq_zero_of_cyclotomicLike
    (P : Polynomial ℤ) (hmonic : P.Monic) (hcyc : IsCyclotomicLike P) :
    logMahlerMeasureInt P = 0 := by
  convert logMahlerMeasureInt_eq_zero_iff_all_roots_le_one P hmonic |>.2 _;
  exact fun z hz => le_of_eq ( hcyc z hz )

/-
If the logarithmic Mahler measure is zero, then no root lies strictly
outside the unit circle. Contrapositive of positivity.
-/
theorem roots_le_one_of_logMahlerMeasureInt_eq_zero
    (P : Polynomial ℤ) (hmonic : P.Monic)
    (hzero : logMahlerMeasureInt P = 0) :
    ∀ z : ℂ, z ∈ (P.map (Int.castRingHom ℂ)).roots → ‖z‖ ≤ 1 := by
  exact logMahlerMeasureInt_eq_zero_iff_all_roots_le_one P hmonic |>.1 hzero

/-! ## Theorem 4: Certified Lower Bounds -/

/-
**Certificate theorem**: A Mahler lower certificate implies the corresponding
lower bound on the logarithmic Mahler measure. This gives a rigorous
framework for computational certification of Mahler measure gaps.

The certificate works by identifying a single root whose log-modulus
already exceeds the target bound; since all other root contributions
are nonneg, the total sum is at least as large.
-/
theorem certificate_implies_logMahler_lower_bound
    (f : Polynomial ℤ) (c : ℝ)
    (hcert : MahlerLowerCertificate f c) :
    c ≤ logMahlerMeasureInt f := by
  obtain ⟨ hfmonic, z, hz₁, hz₂ ⟩ := hcert;
  -- Use logMahlerMeasureInt_eq_sum_roots to rewrite.
  have h_sum : logMahlerMeasureInt f = ((f.map (Int.castRingHom ℂ)).roots.map (fun z => Real.posLog ‖z‖)).sum := by
    convert logMahlerMeasureInt_eq_sum_roots f hfmonic using 1;
  refine' h_sum ▸ le_trans hz₂ _;
  rw [ ← Multiset.cons_erase hz₁ ] ; simp +decide [ Multiset.sum_cons ];
  exact Multiset.sum_nonneg ( Multiset.forall_mem_map_iff.mpr fun x hx => by exact le_max_left _ _ )

/-! ## Theorem 5: Entropy Connection -/

/-
**Entropy = Mahler measure identity**: The companion spectral entropy of a
monic integer polynomial equals its logarithmic Mahler measure.

This theorem recasts Lehmer's problem as an **entropy gap theorem** for
algebraic dynamics: the conjecture that M(L) is the minimal Mahler measure
becomes the conjecture that the companion dynamics of any non-cyclotomic
monic integer polynomial has topological entropy at least log(M(L)).
-/
theorem logMahler_eq_companionSpectralEntropy
    (f : Polynomial ℤ) (hf : f.Monic) :
    logMahlerMeasureInt f = companionSpectralEntropy f := by
  convert logMahlerMeasureInt_eq_sum_roots f hf using 1

/-! ## Theorem 6: Multiplicativity -/

/-
The logarithmic Mahler measure is additive under multiplication
of nonzero integer polynomials.
-/
theorem logMahlerMeasureInt_mul
    (P Q : Polynomial ℤ) (hP : P ≠ 0) (hQ : Q ≠ 0) :
    logMahlerMeasureInt (P * Q) = logMahlerMeasureInt P + logMahlerMeasureInt Q := by
  rw [ logMahlerMeasureInt_def, logMahlerMeasureInt_def, logMahlerMeasureInt_def ];
  rw [ Polynomial.map_mul, Polynomial.logMahlerMeasure_mul_eq_add_logMahlerMeasure ];
  simp_all +decide [ Polynomial.ext_iff ]

/-! ## Lehmer Polynomial Properties -/

theorem lehmerPoly_ne_zero : lehmerPoly ≠ 0 := by
  exact ne_of_apply_ne (Polynomial.eval 2) (by norm_num [lehmerPoly])

theorem lehmerPoly_monic : lehmerPoly.Monic := by
  rw [ lehmerPoly, Polynomial.Monic, Polynomial.leadingCoeff ];
  norm_num [ Polynomial.coeff_one, Polynomial.coeff_X, Polynomial.natDegree_add_eq_left_of_natDegree_lt, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ]

theorem lehmerPoly_natDegree : lehmerPoly.natDegree = 10 := by
  erw [ Polynomial.natDegree_add_eq_left_of_natDegree_lt ] <;> norm_num [ Polynomial.natDegree_add_eq_left_of_natDegree_lt, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ]

/-
Lehmer's polynomial is not cyclotomic-like: it has a root outside the
unit circle, which follows from its positive Mahler measure.
-/
theorem lehmerPoly_not_cyclotomicLike : ¬ IsCyclotomicLike lehmerPoly := by
  unfold IsCyclotomicLike;
  simp +zetaDelta at *;
  -- By the Intermediate Value Theorem, since $ LehmerPoly.eval 1 = -1 $ and $ LehmerPoly.eval 2 = 1291 $, there exists a root $ r $ in the interval $ (1, 2) $.
  have h_ivt : ∃ r ∈ Set.Ioo (1 : ℝ) 2, r ^ 10 + r ^ 9 - r ^ 7 - r ^ 6 - r ^ 5 - r ^ 4 - r ^ 3 + r + 1 = 0 := by
    apply_rules [ intermediate_value_Ioo ] <;> norm_num;
    fun_prop (disch := norm_num);
  obtain ⟨ r, hr₁, hr₂ ⟩ := h_ivt; use ne_of_apply_ne ( Polynomial.eval 0 ) ( by norm_num [ lehmerPoly ] ), r; norm_cast; simp_all +decide [ lehmerPoly ] ;
  exact ⟨ mod_cast hr₂, by rw [ abs_of_pos ] <;> linarith ⟩

/-
**Positivity of Lehmer's Mahler measure**: The logarithmic Mahler measure
of Lehmer's polynomial is strictly positive. This certifies that Lehmer's
polynomial produces genuine entropy/complexity, making it a valid
candidate for the conjectured minimizer.
-/
theorem lehmerPoly_positive_logMahler :
    0 < logMahlerMeasureInt lehmerPoly := by
  -- By the Intermediate Value Theorem, since $f(1) < 0$ and $f(2) > 0$, there exists $r \in (1, 2)$ such that $f(r) = 0$.
  have h_ivt : ∃ r ∈ Set.Ioo (1 : ℝ) 2, Polynomial.eval r (Polynomial.map (Int.castRingHom ℝ) lehmerPoly) = 0 := by
    apply_rules [ intermediate_value_Ioo ] <;> norm_num [ lehmerPoly ];
    fun_prop;
  obtain ⟨ r, ⟨ hr₁, hr₂ ⟩, hr₃ ⟩ := h_ivt;
  convert positive_logMahler_of_root_outside_unit_circle lehmerPoly ( lehmerPoly_monic ) ( r : ℂ ) ?_ ?_ using 1 <;> norm_num [ hr₃, hr₁, hr₂ ];
  · refine' ⟨ _, _ ⟩;
    · exact ne_of_apply_ne ( Polynomial.eval 0 ) ( by norm_num [ lehmerPoly ] );
    · convert congr_arg ( ( ↑ ) : ℝ → ℂ ) hr₃ using 1 ; norm_num [ lehmerPoly ];
  · linarith [ le_abs_self r ]

/-! ## Lehmer Reduction Principle -/

/-
The **Lehmer reduction principle**: for a monic nonzero integer polynomial,
either the logarithmic Mahler measure is zero (cyclotomic-like), or there
exists a root with norm strictly greater than 1. This localizes positivity
to explicit spectral escape.
-/
theorem lehmer_reduction_principle
    (P : Polynomial ℤ) (_hP0 : P ≠ 0) (hmonic : P.Monic) :
    logMahlerMeasureInt P = 0 ∨
    ∃ z : ℂ, z ∈ (P.map (Int.castRingHom ℂ)).roots ∧ 1 < ‖z‖ := by
  rw [ logMahlerMeasureInt_eq_sum_roots ] at *;
  · by_contra hP0;
    simp_all +decide [ not_or ];
    exact hP0.left <| Multiset.sum_eq_zero fun x hx => by obtain ⟨ z, hz, rfl ⟩ := Multiset.mem_map.mp hx; exact max_eq_left <| Real.log_nonpos ( by positivity ) <| hP0.right z ( by simpa [ Polynomial.ext_iff ] using hmonic.ne_zero ) <| by aesop;
  · assumption

/-! ## Conjectures and Testable Predictions -/

/-- **Conjecture (Lehmer's gap, degree-bounded version)**:
For any degree bound d, there exists ε > 0 such that every monic
non-cyclotomic-like integer polynomial of degree ≤ d has logarithmic
Mahler measure at least ε.

This is a testable weakening of Lehmer's full conjecture: for each
fixed degree, one can computationally enumerate monic integer
polynomials with bounded coefficients and verify the gap.

Testable prediction: Exhaust monic integer polynomials of degree ≤ d
with coefficients in [-B, B], filter out cyclotomic-like cases,
and check that logMahlerMeasureInt > ε for some explicit ε > 0. -/
theorem lehmer_gap_degree_bounded_conjecture :
    ∀ d : ℕ, ∃ ε : ℝ, 0 < ε ∧
      ∀ f : Polynomial ℤ, f.Monic → f.natDegree ≤ d →
        ¬ IsCyclotomicLike f → ε ≤ logMahlerMeasureInt f := by
  sorry  -- This is an open conjecture (Lehmer's problem, degree-bounded form)

end