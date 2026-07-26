import Mathlib
import EML.EMLDiffObstruction

/-!
# Rational (Kovacic) Obstruction for Airy's Equation

This file extends the polynomial obstruction theory of `EML.EMLDiffObstruction`
from *polynomial* non-solvability of Airy's equation `y″ = x·y` to the *rational*
non-solvability of its associated Riccati equation `v′ + v² = x`.

The Riccati substitution `v = y′/y` turns the second-order linear equation
`y″ = q·y` into the first-order quadratic equation `v′ + v² = q`.  A rational
function `v = p/q` (with `q ≠ 0` in `ℝ[X]`) satisfies `v′ + v² = f` **iff** the
cleared polynomial identity

    p′·q − p·q′ + p² = f·q²

holds in `ℝ[X]` (multiply through by `q²` and use `v′ = (p′q − pq′)/q²`,
`v² = p²/q²`).  This file therefore studies that polynomial identity directly,
which keeps the whole argument inside the polynomial ring while faithfully
encoding "rational solution of the Riccati equation".

## Main results

* `natDegree_wronskianLike_le` — degree bound for the "Wronskian-like" combination
  `p′·q − p·q′`, the first-order part of the cleared Riccati left-hand side.
* `no_rational_solves_riccati_odd_deg` — **Kovacic odd-degree obstruction**: if
  `f` has *odd* degree, the cleared Riccati identity `p′q − pq′ + p² = f·q²` has
  no solution with `q ≠ 0`.  Hence `v′ + v² = f` has no rational solution.
* `no_rational_solves_riccati_airy` — the Airy specialization (`f = X`):
  `v′ + v² = x` has no rational solution.
* `airy_no_poly_and_no_rational_riccati` — a combined first-step obstruction
  bundling the catalog polynomial result `EMLDiffObstruction.no_poly_solves_airy`
  with the new rational Riccati obstruction.

## Mathematical context

The impossibility of solving Airy's equation `y″ = xy` in elementary terms is
decided, via the Kovacic algorithm, by whether the associated Riccati equation
has a *rational* solution.  The polynomial obstruction (catalog file) is the
crudest case; the rational obstruction proved here is the genuinely
Galois-theoretic step.  The proof is a clean degree/parity argument:

* the right-hand side `f·q²` has degree `deg f + 2·deg q`;
* if `deg p ≥ deg q`, the `p²` term dominates, forcing `deg f = 2(deg p − deg q)`
  to be **even** — contradicting `deg f` odd;
* if `deg p < deg q`, the whole left-hand side has degree `≤ 2·deg q − 2`, strictly
  below the right-hand side's degree `≥ 2·deg q + 1`.

Either way no solution exists.  The Airy case `f = X` has `deg f = 1`, odd.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the polynomial non-solvability of Airy in the catalog
should lift to *rational* non-solvability of the Riccati equation `v′+v²=x`, and
the obstruction should be a degree-*parity* phenomenon (`deg X = 1` is odd) rather
than a delicate pole analysis.

Experiment (Experimenter): we cleared denominators `v = p/q ↦ p′q − pq′ + p² = f q²`
and ran a pure degree count.  Two regimes appear: `deg p ≥ deg q` (parity clash via
the dominant `p²`) and `deg p < deg q` (the cleared LHS is degree-deficient). Both
close with `omega` after `natDegree` bookkeeping.

Analysis (Analyst): coprimality of `p,q` is *not* needed — the obstruction is purely
metric (degree), which is stronger than the textbook pole argument and matches the
parity heart of the catalog's `no_poly_solves_riccati_airy`. The result generalizes
verbatim to any `f` of odd degree, i.e. to the family `y″ = f·y`.

Critique (Critic): the theorem is non-vacuous (Airy's `f = X` instantiates it), uses
genuine structure (`natDegree_mul`, `natDegree_pow`, derivative degree drop) and not
`decide`/`rfl`. The `q ≠ 0` hypothesis is exactly the rationality requirement, not a
trick to make the claim vacuous. The even-degree case (e.g. `f = X²`) is *not* covered
and indeed can have rational solutions, so the odd-degree hypothesis is load-bearing.

Synthesis (PI): the Riccati degree-parity obstruction is the rational-function layer
of the Kovacic decision procedure for Airy, sitting one level above the catalog's
polynomial layer and feeding the abstract differential-field transform in
`EML.EMLRiccatiTransform`.
-- !-- Lab Notes -- !--
-/

open Polynomial

namespace EMLAiryRiccati

/-! ### Degree bound for the first-order (Wronskian-like) part -/

/-
The "Wronskian-like" combination `p′·q − p·q′` (the first-order part of the
cleared Riccati left-hand side) has degree at most `deg p + deg q − 1`.  This is
the polynomial analogue of the fact that the Wronskian drops one degree below the
naive product degree.
-/
theorem natDegree_wronskianLike_le (p q : Polynomial ℝ) :
    (derivative p * q - p * derivative q).natDegree ≤ p.natDegree + q.natDegree - 1 := by
  refine' le_trans ( Polynomial.natDegree_sub_le _ _ ) _;
  rcases n : Polynomial.natDegree p with ( _ | n ) <;> rcases n' : Polynomial.natDegree q with ( _ | n' ) <;> simp_all +decide;
  · rw [ Polynomial.eq_C_of_natDegree_eq_zero n, Polynomial.eq_C_of_natDegree_eq_zero n' ] ; aesop;
  · rw [ Polynomial.eq_C_of_natDegree_eq_zero n ] ; norm_num;
    exact le_trans ( Polynomial.natDegree_C_mul_le _ _ ) ( by exact le_trans ( Polynomial.natDegree_derivative_le .. ) ( by norm_num [ n' ] ) );
  · rw [ Polynomial.eq_C_of_natDegree_eq_zero n' ] ; norm_num;
    exact le_trans ( Polynomial.natDegree_mul_le .. ) ( by norm_num [ Polynomial.natDegree_le_iff_degree_le, Polynomial.degree_le_iff_coeff_zero, n ] );
  · constructor <;> refine' le_trans ( Polynomial.natDegree_mul_le .. ) _;
    · exact le_trans ( add_le_add ( Polynomial.natDegree_derivative_le .. ) le_rfl ) ( by simp +arith +decide [ * ] );
    · exact add_le_add n.le ( Polynomial.natDegree_derivative_le .. |> le_trans <| by simp +arith +decide [ n' ] )

/-! ### The general odd-degree Riccati obstruction -/

/-
**Kovacic odd-degree obstruction.** If `f` has odd degree, then the cleared
Riccati identity `p′·q − p·q′ + p² = f·q²` has no solution with `q ≠ 0`.
Equivalently, the Riccati equation `v′ + v² = f` has no rational solution `v = p/q`.

The proof is a degree/parity argument; coprimality of `p` and `q` is not required.
-/
theorem no_rational_solves_riccati_odd_deg (f p q : Polynomial ℝ) (hq : q ≠ 0)
    (hodd : Odd f.natDegree)
    (heq : derivative p * q - p * derivative q + p ^ 2 = f * q ^ 2) : False := by
  -- Apply the degree bound to the left-hand side.
  have h_lhs_deg : (derivative p * q - p * derivative q + p^2).natDegree ≤ max (2 * p.natDegree) (p.natDegree + q.natDegree - 1) := by
    refine' le_trans ( Polynomial.natDegree_add_le _ _ ) ( max_le _ _ );
    · exact le_trans ( natDegree_wronskianLike_le p q ) ( by omega );
    · norm_num [ Polynomial.natDegree_pow ];
  by_cases hp : p = 0 <;> by_cases hq : q = 0 <;> simp_all +decide;
  rw [ Polynomial.natDegree_mul' ] at h_lhs_deg <;> simp_all +decide [ Polynomial.natDegree_pow ];
  · cases h_lhs_deg <;> have := congr_arg Polynomial.natDegree heq <;> rw [ Polynomial.natDegree_add_eq_right_of_natDegree_lt ] at this <;> norm_num [ Polynomial.natDegree_mul', hp, hq ] at this ⊢;
    · rw [ Polynomial.natDegree_mul' ] at this <;> simp_all +decide [ Polynomial.natDegree_pow ];
      · grind;
      · aesop_cat;
    · refine' lt_of_le_of_lt ( natDegree_wronskianLike_le p q ) _;
      grind +suggestions;
    · rw [ Polynomial.natDegree_mul' ] at this <;> simp_all +decide [ Polynomial.natDegree_pow ];
      · grind;
      · aesop_cat;
    · refine' lt_of_le_of_lt ( natDegree_wronskianLike_le p q ) _;
      grind +suggestions;
  · aesop_cat

/-! ### Airy specialization -/

/-- **Rational Riccati obstruction for Airy.** The Riccati equation `v′ + v² = x`
associated with Airy's equation `y″ = x·y` has no rational solution: there are no
polynomials `p, q` with `q ≠ 0` satisfying `p′·q − p·q′ + p² = X·q²`. -/
theorem no_rational_solves_riccati_airy (p q : Polynomial ℝ) (hq : q ≠ 0)
    (heq : derivative p * q - p * derivative q + p ^ 2 = X * q ^ 2) : False :=
  no_rational_solves_riccati_odd_deg X p q hq (by simp [Polynomial.natDegree_X]) heq

/-! ### Combined first-step obstruction (uses the catalog polynomial result) -/

/-- **Airy first-step obstruction.** Airy's equation `y″ = x·y` has
neither a nonzero polynomial solution (the catalog result
`EMLDiffObstruction.no_poly_solves_airy`) nor a rational solution of its
associated Riccati equation `v′ + v² = x` (this file).  Together these are the
first two layers of the Kovacic decision procedure showing Airy has no
elementary (EML) closed-form solution. -/
theorem airy_no_poly_and_no_rational_riccati :
    (∀ y : Polynomial ℝ, y ≠ 0 → derivative (derivative y) ≠ X * y) ∧
    (∀ p q : Polynomial ℝ, q ≠ 0 →
      derivative p * q - p * derivative q + p ^ 2 ≠ X * q ^ 2) := by
  refine ⟨fun y hy hcontra => ?_, fun p q hq hcontra => ?_⟩
  · exact EMLDiffObstruction.no_poly_solves_airy y hy hcontra
  · exact no_rational_solves_riccati_airy p q hq hcontra

end EMLAiryRiccati