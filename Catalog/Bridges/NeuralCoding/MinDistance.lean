/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.GraphTheory.Defs
import Bridges.ExtremalPoly
import Bridges.FiberRestriction
/-!
# Reed–Muller base distance bound

This file proves the Schwartz–Zippel zero-count bound and the resulting base-case
Reed–Muller Hamming-weight bound over arbitrary finite fields. It also imports the
construction proving the generalized upper bound.

The unrestricted generalized lower-bound declarations from the original source are
preserved below in comments because they are false for polynomial representatives:
a nonzero polynomial can evaluate to zero everywhere over a finite field. An exact
generalized Reed–Muller theorem requires a reduced-polynomial representation.

## Main results

- `GRM.schwartz_zippel_zero_bound`: the total-degree zero-count estimate.
- `GRM.hammingWeight_lower_bound_base`: the base distance bound for degree below `q`.
- `GRM.generalized_reedMuller_min_distance_upper`: an extremal polynomial construction.

## References

* Kasami, T., Lin, S., Peterson, W. (1968). New generalizations of Reed-Muller codes.
* Delsarte, Goethals, Mac Williams (1970). On generalized Reed-Muller codes.
-/

open MvPolynomial Finset BigOperators Fintype

namespace GRM

variable {𝔽 : Type*} [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]

/-! ### Schwartz–Zippel lower bound (base case) -/

/-
**Schwartz–Zippel zero count bound**: A nonzero polynomial of total degree ≤ d
    over 𝔽_q in n variables has at most d · q^(n-1) zeros.
-/
theorem schwartz_zippel_zero_bound
    (n : ℕ) (hn : 1 ≤ n) (d : ℕ)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hd : f.totalDegree ≤ d) :
    zeroCount f ≤ d * (card 𝔽) ^ (n - 1) := by
  -- Apply the Schwarz-Zippel lemma to the polynomial f.
  have h_schwarz_zippel : (Finset.univ.filter (fun x : Fin n → 𝔽 => MvPolynomial.eval x f = 0)).card ≤ f.totalDegree * Fintype.card 𝔽 ^ (n - 1) := by
    have := @MvPolynomial.schwartz_zippel_totalDegree;
    specialize @this 𝔽 _ _ _ n f hf Finset.univ;
    rcases n with ( _ | n ) <;> simp_all +decide [ Finset.card_univ, pow_succ, mul_assoc, mul_comm, mul_left_comm, div_le_iff₀ ];
    rw [ div_le_div_iff₀ ] at this <;> norm_cast at * <;> nlinarith [ show 0 < Fintype.card 𝔽 ^ n by exact pow_pos ( Fintype.card_pos ) _, show 0 < Fintype.card 𝔽 by exact Fintype.card_pos ];
  exact h_schwarz_zippel.trans ( Nat.mul_le_mul_right _ hd )

/-
**Reed–Muller lower bound (base case)**: For d < q, every nonzero polynomial
    of total degree ≤ d has weight ≥ (q-d) · q^(n-1).
-/
theorem hammingWeight_lower_bound_base
    (n : ℕ) (hn : 1 ≤ n) (d : ℕ) (hd : d < card 𝔽)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d) :
    (card 𝔽 - d) * (card 𝔽) ^ (n - 1) ≤ hammingWeight f := by
  -- By the Schwartz-Zippel lemma, the number of zeros of $f$ is at most $d \cdot q^{n-1}$.
  have h_zero_count : zeroCount f ≤ d * (Fintype.card 𝔽) ^ (n - 1) := by
    exact schwartz_zippel_zero_bound n hn d f hf hdeg
  rw [ hammingWeight_eq ];
  rw [ tsub_mul ];
  exact Nat.sub_le_sub_left h_zero_count _ |> le_trans ( by rw [ ← pow_succ', Nat.sub_add_cancel hn ] )

/-! ### Generalized lower bound by induction -/

/-
**Generalized Hamming weight lower bound** (strong induction version).
    For a nonzero polynomial of degree ≤ d in n variables, the weight is at least
    the Reed-Muller minimum weight function.

    This is proved by strong induction on (n, d), using the fiber restriction method.

    The base case a = 0 reduces to Schwartz-Zippel.
-/
theorem hammingWeight_lower_bound_a_zero
    (n : ℕ) (d : ℕ)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d)
    (hq : 1 < card 𝔽)
    (b : ℕ)
    (h_decomp : d = b)
    (hb : b < card 𝔽 - 1)
    (hn : 0 < n) :
    (card 𝔽 - b) * (card 𝔽) ^ (n - 1) ≤ hammingWeight f := by
  convert GRM.hammingWeight_lower_bound_base _ _ _ _ _ _ _ using 1;
  · exact hn;
  · exact lt_of_lt_of_le hb ( Nat.pred_le _ );
  · exact hf;
  · linarith

/-
The proposed induction theorem below is false for arbitrary multivariate polynomials:
over a finite field a nonzero polynomial can induce the zero evaluation word (for
example `X₀^q - X₀`).  A correct generalized Reed–Muller theorem must restrict to
reduced polynomials, with each variable degree below `q`.  The original declaration
is retained verbatim in this comment rather than silently weakened.

theorem hammingWeight_lower_bound_induction
    (n : ℕ) (d : ℕ)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d)
    (hq : 1 < card 𝔽)
    (a b : ℕ)
    (h_decomp : d = a * (card 𝔽 - 1) + b)
    (hb : b < card 𝔽 - 1)
    (ha : a < n) :
    (card 𝔽 - b) * (card 𝔽) ^ (n - 1 - a) ≤ hammingWeight f := by
  -- unproved placeholder in the original, false statement
-/

/-! ### Main Theorems -/

/-- **Generalized Reed–Muller upper bound**: existence of the extremal polynomial. -/
theorem generalized_reedMuller_min_distance_upper
    (n d a b : ℕ)
    (hq : 1 < card 𝔽)
    (h_decomp : d = a * (card 𝔽 - 1) + b)
    (hb : b < card 𝔽 - 1)
    (ha : a < n) :
    ∃ f : MvPolynomial (Fin n) 𝔽,
      f ≠ 0 ∧
      f.totalDegree ≤ d ∧
      hammingWeight f = (card 𝔽 - b) * (card 𝔽) ^ (n - 1 - a) :=
  extremal_poly_exists n d a b hq h_decomp hb ha

/-
The following three declarations depended on the false unrestricted lower bound.
They are preserved in this comment pending the corrected reduced-polynomial API.

/-- **Generalized Reed–Muller lower bound**: every nonzero polynomial of degree ≤ d
    has weight at least (q-b)·q^(n-1-a). -/
theorem generalized_reedMuller_min_distance_lower
    (n d a b : ℕ)
    (hq : 1 < card 𝔽)
    (h_decomp : d = a * (card 𝔽 - 1) + b)
    (hb : b < card 𝔽 - 1)
    (ha : a < n)
    (f : MvPolynomial (Fin n) 𝔽) (hf : f ≠ 0) (hdeg : f.totalDegree ≤ d) :
    (card 𝔽 - b) * (card 𝔽) ^ (n - 1 - a) ≤ hammingWeight f :=
  hammingWeight_lower_bound_induction n d f hf hdeg hq a b h_decomp hb ha

/-- **Exact minimum distance of generalized Reed–Muller codes.**
    For d = a(q-1) + b with 0 ≤ b < q-1 and a < n, the minimum Hamming weight
    among nonzero polynomials of degree ≤ d is exactly (q-b)·q^(n-1-a).

    **Extremal geometry**: The minimum is achieved by polynomials whose zero set
    is a union of affine fibers—coordinatewise vanishing in `a` coordinates and
    partial vanishing in one additional coordinate. This tensor-product structure
    is the finite-field analog of product-set extremizers in isoperimetry. -/
theorem generalized_reedMuller_min_distance
    (n d a b : ℕ)
    (hq : 1 < card 𝔽)
    (h_decomp : d = a * (card 𝔽 - 1) + b)
    (hb : b < card 𝔽 - 1)
    (ha : a < n) :
    (∀ f : MvPolynomial (Fin n) 𝔽, f ≠ 0 → f.totalDegree ≤ d →
      (card 𝔽 - b) * (card 𝔽) ^ (n - 1 - a) ≤ hammingWeight f) ∧
    (∃ f : MvPolynomial (Fin n) 𝔽, f ≠ 0 ∧ f.totalDegree ≤ d ∧
      hammingWeight f = (card 𝔽 - b) * (card 𝔽) ^ (n - 1 - a)) :=
  ⟨fun f hf hdeg => generalized_reedMuller_min_distance_lower n d a b hq h_decomp hb ha f hf hdeg,
   generalized_reedMuller_min_distance_upper n d a b hq h_decomp hb ha⟩

/-! ### Zero count formulation -/

/-- **Sharp zero-count theorem on finite affine space**: Among nonzero polynomials
    of total degree ≤ d = a(q-1)+b over 𝔽_q^n, the maximum number of zeros is
    q^n - (q-b)·q^(n-1-a). -/
theorem affine_zero_set_card_le
    (n d a b : ℕ)
    (hq : 1 < card 𝔽)
    (h_decomp : d = a * (card 𝔽 - 1) + b)
    (hb : b < card 𝔽 - 1)
    (ha : a < n)
    (f : MvPolynomial (Fin n) 𝔽)
    (hf : f ≠ 0)
    (hdeg : f.totalDegree ≤ d) :
    zeroCount f ≤ (card 𝔽) ^ n - (card 𝔽 - b) * (card 𝔽) ^ (n - 1 - a) := by
  have hw := generalized_reedMuller_min_distance_lower n d a b hq h_decomp hb ha f hf hdeg
  have htotal := hammingWeight_add_zeroCount f
  rw [card_fin_arrow] at htotal
  omega
-/

end GRM