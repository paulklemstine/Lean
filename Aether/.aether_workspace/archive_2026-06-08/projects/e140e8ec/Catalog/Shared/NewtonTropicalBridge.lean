/-
# Newton–Tropical Bridge

A formally verified pathway connecting polynomial coefficient valuations
(the Newton valuation profile) through tropical polynomial evaluation
to divisibility certificates.

## Main Results

* `ultrametric_finset_sum` — The ultrametric inequality extends from pairs to arbitrary
  finite sums: v(∑ᵢ fᵢ) ≥ minᵢ v(fᵢ).
* `newton_tropical_bridge` — The Root–Valuation Bridge Theorem: for any ultrametric
  valuation v and polynomial with coefficients aᵢ evaluated at point a,
  v(f(a)) ≥ T_f(v(a)) where T_f is the tropical evaluation.
* `tropEval_eq_of_certificate` — When one term strictly dominates all others in the
  Newton profile, the tropical evaluation equals the dominant term's contribution.
* `divisibility_depth_certificate` — Application to integer divisibility.
* `tropEval_concave` — The tropical evaluation is concave (infimum of affine functions).
-/
import Mathlib

open Finset BigOperators

/-! ## Ultrametric Valuations -/

/-- An ultrametric function on a commutative ring, taking values in ℝ.
    This models the additive valuation v where v(xy) = v(x) + v(y) and
    v(x+y) ≥ min(v(x), v(y)). -/
structure UltrametricFn (R : Type*) [CommRing R] where
  /-- The valuation function -/
  toFun : R → ℝ
  /-- Multiplicativity: v(x·y) = v(x) + v(y) -/
  map_mul : ∀ x y : R, toFun (x * y) = toFun x + toFun y
  /-- Ultrametric inequality: v(x+y) ≥ min(v(x), v(y)) -/
  map_add_le : ∀ x y : R, toFun (x + y) ≥ min (toFun x) (toFun y)

namespace UltrametricFn

variable {R : Type*} [CommRing R] (v : UltrametricFn R)

instance : CoeFun (UltrametricFn R) (fun _ => R → ℝ) := ⟨toFun⟩

@[simp] lemma coe_apply (x : R) : v.toFun x = v x := rfl

/-
v(x^n) = n * v(x), the power rule for ultrametric valuations.
    Proved by induction using the multiplicativity axiom.
-/
theorem map_pow (x : R) (n : ℕ) : v (x ^ n) = n * v x := by
  have := v.map_mul 1 0; simp_all +decide ;
  have := v.map_mul 0; simp_all +decide [ pow_succ' ] ;

end UltrametricFn

/-! ## Tropical Evaluation -/

/-- A Newton profile of degree n: the sequence of coefficient valuations
    (v(a₀), v(a₁), ..., v(aₙ)). This is the data that determines the
    Newton polygon of the polynomial. -/
def NewtonProfile (n : ℕ) := Fin (n + 1) → ℝ

/-- The tropical term: the value profile(i) + i · t, representing the
    tropical evaluation of the i-th monomial at point t. -/
noncomputable def tropTerm {n : ℕ} (profile : NewtonProfile n) (t : ℝ)
    (i : Fin (n + 1)) : ℝ :=
  profile i + (↑(i : ℕ) : ℝ) * t

/-- Tropical evaluation of a Newton profile at a point t ∈ ℝ.
    T_f(t) = min_{i=0}^{n} (profile(i) + i · t)
    This computes the lower envelope of the Newton polygon. -/
noncomputable def tropEval {n : ℕ} (profile : NewtonProfile n) (t : ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty (tropTerm profile t)

/-! ## The Ultrametric Sum Inequality -/

/-
The ultrametric inequality extends from pairs to arbitrary finite sums:
    v(∑ᵢ∈s fᵢ) ≥ inf'ᵢ∈s v(fᵢ).
    Proved by induction on the finite set.
-/
theorem ultrametric_finset_sum {R : Type*} [CommRing R] (v : UltrametricFn R)
    {ι : Type*} {s : Finset ι} (hs : s.Nonempty) (f : ι → R) :
    v (∑ i ∈ s, f i) ≥ s.inf' hs (fun i => v (f i)) := by
      induction' hs using Finset.Nonempty.cons_induction with i s hi ih;
      · simp +decide;
      · simp_all +decide [ Finset.inf'_cons ];
        have := v.map_add_le ( f s ) ( ∑ i ∈ hi, f i );
        grind

/-! ## The Newton–Tropical Bridge Theorem -/

/-
**The Root–Valuation Bridge Theorem.**
    For any ultrametric valuation v and polynomial f = ∑ aᵢ xⁱ evaluated at a,
    the valuation of f(a) is bounded below by the tropical evaluation of the
    Newton profile at v(a):
      v(f(a)) ≥ T_f(v(a))
    where T_f(t) = min_i(v(aᵢ) + i·t).

    This theorem bridges classical algebra (polynomial evaluation) with
    tropical geometry (the Newton polygon / lower envelope).
-/
theorem newton_tropical_bridge {R : Type*} [CommRing R] (v : UltrametricFn R)
    {n : ℕ} (coeffs : Fin (n + 1) → R) (a : R) :
    v (∑ i : Fin (n + 1), coeffs i * a ^ (i : ℕ)) ≥
    tropEval (fun i => v (coeffs i)) (v a) := by
      -- Apply the ultrametric inequality to the sum.
      have h_ultrametric : v (∑ i : Fin (n + 1), coeffs i * a ^ i.val) ≥ Finset.univ.inf' Finset.univ_nonempty (fun i => v (coeffs i * a ^ i.val)) := by
        convert ultrametric_finset_sum v _ _;
      refine' le_trans _ h_ultrametric;
      simp +decide [ tropEval, tropTerm, Finset.inf'_le ];
      intro i; use i; simp +decide [ v.map_pow, v.map_mul ] ;

/-! ## Slope Certificates -/

/-- A slope certificate asserts that a particular index k achieves the unique
    minimum in the tropical evaluation, with a gap of at least δ > 0 from
    all other terms. -/
structure SlopeCertificate {n : ℕ} (profile : NewtonProfile n) (t : ℝ) where
  /-- The index achieving the minimum -/
  dominant : Fin (n + 1)
  /-- The gap between the dominant term and all others -/
  gap : ℝ
  /-- The gap is strictly positive -/
  gap_pos : gap > 0
  /-- The dominant term achieves the minimum -/
  is_min : ∀ j : Fin (n + 1), tropTerm profile t dominant ≤ tropTerm profile t j
  /-- All other terms are at least gap larger -/
  strict_gap : ∀ j : Fin (n + 1), j ≠ dominant →
    tropTerm profile t j ≥ tropTerm profile t dominant + gap

/-
The tropical evaluation equals the value at the dominant index when a
    slope certificate exists.
-/
theorem tropEval_eq_of_certificate {n : ℕ} (profile : NewtonProfile n) (t : ℝ)
    (cert : SlopeCertificate profile t) :
    tropEval profile t = tropTerm profile t cert.dominant := by
      refine' le_antisymm ( Finset.inf'_le _ ( Finset.mem_univ _ ) ) _;
      exact Finset.le_inf' _ _ fun i _ => cert.is_min i

/-! ## Divisibility Depth Certificates -/

/-
A p-adic divisibility certificate: given that all tropical terms are ≥ k,
    the bridge theorem yields v(f(a)) ≥ k, meaning p^k divides f(a).
-/
theorem divisibility_depth_certificate {R : Type*} [CommRing R] (v : UltrametricFn R)
    {n : ℕ} (coeffs : Fin (n + 1) → R) (a : R) (k : ℝ)
    (h_bound : ∀ i : Fin (n + 1), v (coeffs i) + (↑(i : ℕ) : ℝ) * v a ≥ k) :
    v (∑ i : Fin (n + 1), coeffs i * a ^ (i : ℕ)) ≥ k := by
      refine' le_trans _ ( newton_tropical_bridge v coeffs a );
      exact Finset.le_inf' _ _ fun i _ => h_bound i

/-! ## Newton Polygon Convexity -/

/-
The tropical evaluation function t ↦ T_f(t) is concave (being the infimum
    of a family of affine functions). This is the formal statement that the
    Newton polygon's lower envelope is a concave piecewise-linear function.
-/
theorem tropEval_concave {n : ℕ} (profile : NewtonProfile n)
    (t₁ t₂ : ℝ) (w₁ w₂ : ℝ) (hw₁ : 0 ≤ w₁) (hw₂ : 0 ≤ w₂) (hw : w₁ + w₂ = 1) :
    tropEval profile (w₁ * t₁ + w₂ * t₂) ≥
    w₁ * tropEval profile t₁ + w₂ * tropEval profile t₂ := by
      refine' le_trans _ ( Finset.le_inf' _ _ _ );
      convert le_rfl;
      intro i hi; convert add_le_add ( mul_le_mul_of_nonneg_left ( Finset.inf'_le _ hi ) hw₁ ) ( mul_le_mul_of_nonneg_left ( Finset.inf'_le _ hi ) hw₂ ) using 1 ; ring;
      unfold tropTerm; rw [ ← eq_sub_iff_add_eq' ] at hw; subst hw; ring;

/-! ## Tropical Evaluation Bounds -/

/-
For a Newton profile with values in [0, B] and evaluation point t ∈ [0, B],
    the tropical evaluation is bounded above by (n+1)·B.
-/
theorem tropical_evaluation_upper_bound {n : ℕ} (profile : NewtonProfile n)
    (B : ℝ) (hB : 0 ≤ B)
    (h_bounded : ∀ i : Fin (n + 1), 0 ≤ profile i ∧ profile i ≤ B)
    (t : ℝ) (_ht : 0 ≤ t) (_htB : t ≤ B) :
    tropEval profile t ≤ (↑(n + 1) : ℝ) * B := by
      refine' le_trans ( Finset.inf'_le _ <| Finset.mem_univ 0 ) _;
      norm_num [ tropTerm ] ; nlinarith [ h_bounded 0 ]

/-
The tropical evaluation at t=0 equals the minimum coefficient valuation.
-/
theorem tropEval_at_zero {n : ℕ} (profile : NewtonProfile n) :
    tropEval profile 0 = Finset.univ.inf' Finset.univ_nonempty profile := by
      simp [tropEval, tropTerm]

/-
Tropical evaluation is monotone in each profile entry:
    if every coefficient valuation increases, so does the tropical evaluation.
-/
theorem tropEval_mono {n : ℕ} (p q : NewtonProfile n)
    (h : ∀ i, p i ≤ q i) (t : ℝ) (_ht : 0 ≤ t) :
    tropEval p t ≤ tropEval q t := by
      simp_all +decide [ tropEval ];
      exact fun i => ⟨ i, by unfold tropTerm; nlinarith [ h i ] ⟩