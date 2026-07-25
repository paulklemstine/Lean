import Mathlib
import Catalog.Novelty.PrimeZetaAbscissa
import Catalog.Novelty.ImaginaryQuadraticPrimeZeta

/-!
# Abscissa bracket for a general imaginary quadratic prime-ideal zeta function

This file abstracts the Gaussian computation of
`Catalog.Novelty.ImaginaryQuadraticPrimeZeta` to an **arbitrary** imaginary
quadratic field `K` with class number one.  The arithmetic of such a field is
encoded by its *splitting data* at each rational prime `p`:

* `deg1` is the number of degree-one prime ideals above `p` (each of norm `p`);
  it satisfies `deg1 p ≤ 2`.
* `inert` is the number of degree-two (inert) prime ideals above `p` (each of
  norm `p²`); it satisfies `inert p ≤ 1`.

Since every rational prime has at least one prime ideal above it, the splitting
data always satisfies `1 ≤ deg1 p + inert p`.  The associated prime-ideal zeta
function is `P_K(s) = ∑_p (deg1 p)·p^{-s} + (inert p)·p^{-2s}`.

## Main results

* `primeIdealZetaG_summable` — convergence for `s > 1` (degree-two structure).
* `primeIdealZetaG_not_summable_of_le_half` — divergence for `s ≤ 1/2`, forced by
  the unavoidable prime ideals of norm `≤ p²`.
* `primeIdealZetaG_not_summable_nonpos` — divergence on the whole half-line
  `s ≤ 0`; in particular at `s = -1`, the formal "sum/product of all prime
  ideals" point, the bare series has no value: **no regularization can come from
  the series itself**.
* `gaussTerm_eq_primeIdealZetaGTerm` and `gaussPrimeZeta_eq_primeIdealZetaG` —
  the Gaussian field `ℚ(i)` of the companion file is the instance of this general
  framework with the explicit `p mod 4` splitting data.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "The abscissa bracket `[1/2, 1]` and the `s ≤ 0`
regularization obstruction are *structural*: they depend only on `deg1 ≤ 2`,
`inert ≤ 1`, and `deg1 + inert ≥ 1`, not on the specific field."
Experiment (Experimenter): Replaced the `ℚ(i)`-specific `gaussTerm` by the
two-parameter family `primeIdealZetaGTerm deg1 inert` and re-derived the same
pointwise sandwich `p^{-2s} ≤ term ≤ 2·p^{-s} + p^{-2s}`; the previous file is
recovered by `gaussTerm_eq_primeIdealZetaGTerm`.
Analysis (Analyst): The convergence floor `1/2` is set by the *inert* norm-`p²`
ideals; the regularization obstruction at `s ≤ 0` is set by the fact that for
`s ≤ 0` every term is `≥ 1`, so the series cannot even tend to `0`.  Both are
field-independent.
Critique (Critic): Checked that the `s ≤ 0` divergence does not secretly assume
convergence anywhere, that the lower bound uses the honest hypothesis
`1 ≤ deg1 p + inert p`, and that the bridge lemmas are definitional matches (no
hidden re-proof of the catalog results).
Synthesis (PI): The only field-dependent ingredient left is the *sharp* abscissa
`1`, which needs positive density of split primes — exactly the Dirichlet-density
input flagged for the natural-boundary conjecture in `FUTURE_DIRECTIONS.md`.
-/

open scoped BigOperators

namespace ImaginaryQuadraticPrimeZeta

/-- The per-prime term of the prime-ideal zeta function of an imaginary quadratic
field with splitting data `(deg1, inert)`: `deg1 p` ideals of norm `p` and
`inert p` ideals of norm `p²`. -/
noncomputable def primeIdealZetaGTerm (deg1 inert : Nat.Primes → ℕ) (s : ℝ)
    (p : Nat.Primes) : ℝ :=
  (deg1 p : ℝ) * (p : ℝ) ^ (-s) + (inert p : ℝ) * (p : ℝ) ^ (-(2 * s))

/-- The general imaginary quadratic prime-ideal zeta function. -/
noncomputable def primeIdealZetaG (deg1 inert : Nat.Primes → ℕ) (s : ℝ) : ℝ :=
  ∑' p : Nat.Primes, primeIdealZetaGTerm deg1 inert s p

/-
Each term of the general prime-ideal zeta series is nonnegative.
-/
theorem primeIdealZetaGTerm_nonneg (deg1 inert : Nat.Primes → ℕ) (s : ℝ)
    (p : Nat.Primes) : 0 ≤ primeIdealZetaGTerm deg1 inert s p := by
  exact add_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) ) ( mul_nonneg ( Nat.cast_nonneg _ ) ( Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) )

/-
**Convergence (upper abscissa `≤ 1`).** For splitting data bounded by the
degree (`deg1 ≤ 2`, `inert ≤ 1`) the general prime-ideal zeta series converges
absolutely for every `s > 1`.
-/
theorem primeIdealZetaG_summable {deg1 inert : Nat.Primes → ℕ}
    (hd : ∀ p, deg1 p ≤ 2) (hi : ∀ p, inert p ≤ 1) {s : ℝ} (hs : 1 < s) :
    Summable (fun p : Nat.Primes => primeIdealZetaGTerm deg1 inert s p) := by
  refine' Summable.of_nonneg_of_le _ _ _;
  use fun p => 2 * ( p : ℝ ) ^ ( -s ) + ( p : ℝ ) ^ ( - ( 2 * s ) );
  · exact fun p => primeIdealZetaGTerm_nonneg deg1 inert s p;
  · exact fun p => add_le_add ( mul_le_mul_of_nonneg_right ( mod_cast hd p ) ( Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) ) ( mul_le_of_le_one_left ( Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) ( mod_cast hi p ) );
  · refine' Summable.add _ _;
    · exact Summable.mul_left _ <| by simpa using primeZeta_summable_iff s |>.2 hs;
    · exact_mod_cast ( Nat.Primes.summable_rpow.mpr ( by linarith ) )

/-
**Divergence (lower abscissa `≥ 1/2`).** Whenever every rational prime has at
least one prime ideal above it (`1 ≤ deg1 p + inert p`), the series diverges for
all `s ≤ 1/2`.
-/
theorem primeIdealZetaG_not_summable_of_le_half {deg1 inert : Nat.Primes → ℕ}
    (hpos : ∀ p, 1 ≤ deg1 p + inert p) {s : ℝ} (hs0 : 0 ≤ s) (hs : s ≤ 1 / 2) :
    ¬ Summable (fun p : Nat.Primes => primeIdealZetaGTerm deg1 inert s p) := by
  -- Since `s ≤ 1/2`, we have `-(2*s) ≥ -1`.
  have h_exp : ∀ p : Nat.Primes, (p : ℝ) ^ (-(2 * s)) ≤ primeIdealZetaGTerm deg1 inert s p := by
    intro p
    have h_pow : (p : ℝ) ^ (-(2 * s)) ≤ (deg1 p : ℝ) * (p : ℝ) ^ (-s) + (inert p : ℝ) * (p : ℝ) ^ (-(2 * s)) := by
      have h_lower_bound : (deg1 p : ℝ) * (p : ℝ) ^ (-s) + (inert p : ℝ) * (p : ℝ) ^ (-(2 * s)) ≥ (deg1 p + inert p : ℝ) * (p : ℝ) ^ (-(2 * s)) := by
        rw [ add_mul ];
        exact add_le_add ( mul_le_mul_of_nonneg_left ( Real.rpow_le_rpow_of_exponent_le ( mod_cast p.2.one_lt.le ) ( by linarith ) ) ( Nat.cast_nonneg _ ) ) le_rfl;
      exact le_trans ( le_mul_of_one_le_left ( by positivity ) ( mod_cast hpos p ) ) h_lower_bound
    exact h_pow;
  -- By comparison, if the term series were summable, the smaller nonneg series `(p)^(-(2*s))` would be summable too.
  by_contra h_contra
  have h_summable : Summable (fun p : Nat.Primes => (p : ℝ) ^ (-(2 * s))) := by
    exact Summable.of_nonneg_of_le ( fun p => Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) h_exp h_contra;
  have := @Nat.Primes.summable_rpow;
  exact absurd ( this.mp h_summable ) ( by linarith )

/-
**Regularization obstruction.** For `s ≤ 0` (in particular at `s = -1`, the
formal "sum of all prime ideals" point) every term is `≥ 1`, so the bare series
diverges: no value at `s = -1` can come from the series itself.
-/
theorem primeIdealZetaG_not_summable_nonpos {deg1 inert : Nat.Primes → ℕ}
    (hpos : ∀ p, 1 ≤ deg1 p + inert p) {s : ℝ} (hs : s ≤ 0) :
    ¬ Summable (fun p : Nat.Primes => primeIdealZetaGTerm deg1 inert s p) := by
  by_contra h_contra;
  convert h_contra.tendsto_cofinite_zero.eventually ( gt_mem_nhds zero_lt_one ) using 1;
  simp +zetaDelta at *;
  exact Set.infinite_univ.mono fun p _ => show 1 ≤ primeIdealZetaGTerm deg1 inert s p from by unfold primeIdealZetaGTerm; nlinarith [ show ( p : ℝ ) ^ ( -s ) ≥ 1 from Real.one_le_rpow ( mod_cast p.2.one_lt.le ) ( by linarith ), show ( p : ℝ ) ^ ( - ( 2 * s ) ) ≥ 1 from Real.one_le_rpow ( mod_cast p.2.one_lt.le ) ( by linarith ), show ( deg1 p : ℝ ) + inert p ≥ 1 by exact_mod_cast hpos p ] ;

/-- The Gaussian splitting data: number of degree-one prime ideals of `ℤ[i]`. -/
def gaussDeg1 (p : Nat.Primes) : ℕ :=
  if (p : ℕ) = 2 then 1 else if (p : ℕ) % 4 = 1 then 2 else 0

/-- The Gaussian splitting data: number of inert (norm `p²`) prime ideals. -/
def gaussInert (p : Nat.Primes) : ℕ :=
  if (p : ℕ) = 2 then 0 else if (p : ℕ) % 4 = 1 then 0 else 1

/-
**Bridge to `ℚ(i)`.** The Gaussian term of the companion file is exactly the
general term for the Gaussian splitting data.
-/
theorem gaussTerm_eq_primeIdealZetaGTerm (s : ℝ) (p : Nat.Primes) :
    gaussTerm s p = primeIdealZetaGTerm gaussDeg1 gaussInert s p := by
  unfold gaussTerm primeIdealZetaGTerm gaussDeg1 gaussInert
  split_ifs with h <;> push_cast <;>
    first
      | (rw [show ((p : ℕ) : ℝ) = 2 from by exact_mod_cast h]; ring)
      | ring

/-
**Bridge to `ℚ(i)`.** The Gaussian prime-ideal zeta function is the instance
of the general framework with the explicit `p mod 4` splitting data.
-/
theorem gaussPrimeZeta_eq_primeIdealZetaG (s : ℝ) :
    gaussPrimeZeta s = primeIdealZetaG gaussDeg1 gaussInert s := by
  exact tsum_congr fun p => gaussTerm_eq_primeIdealZetaGTerm s p

/-
The Gaussian splitting data satisfies the structural hypotheses: every prime
has at least one prime ideal above it.
-/
theorem gauss_splitting_pos (p : Nat.Primes) : 1 ≤ gaussDeg1 p + gaussInert p := by
  unfold gaussDeg1 gaussInert; split_ifs <;> norm_num;

end ImaginaryQuadraticPrimeZeta