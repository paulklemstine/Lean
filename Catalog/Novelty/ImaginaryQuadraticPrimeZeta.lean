import Mathlib
import Catalog.Novelty.PrimeZetaAbscissa

/-!
# The prime-ideal zeta function of an imaginary quadratic field (the Gaussian case)

This file develops the elementary, fully rigorous core behind the
(physically/number-theoretically motivated) **prime zeta function of an
imaginary quadratic field with class number one**, taking the Gaussian field
`K = ℚ(i)` (discriminant `-4`, class number `1`) as the running model.

For a number field `K` the *prime-ideal zeta function* is
`P_K(s) = ∑_{𝔭 prime ideal} N(𝔭)^{-s}`.  For `K = ℚ(i)` the splitting of a
rational prime `p` in the Gaussian integers `ℤ[i]` is governed by `p mod 4`:

* `p = 2` is **ramified**: one prime ideal of norm `2`              (term `2^{-s}`);
* `p ≡ 1 (mod 4)` is **split**: two prime ideals of norm `p`       (term `2·p^{-s}`);
* `p ≡ 3 (mod 4)` is **inert**: one prime ideal of norm `p²`       (term `p^{-2s}`).

We package this as the single Dirichlet series `gaussPrimeZeta`.

## Main results

* `gaussPrimeZeta_summable` — convergence for every `s > 1` (upper abscissa `≤ 1`),
  using the genuine degree-two structure (the factor `2` on split primes and the
  `p^{-2s}` inert terms).
* `gaussPrimeZeta_not_summable_of_le_half` — divergence for every `s ≤ 1/2`
  (lower abscissa `≥ 1/2`), forced by the *inert* primes of norm `p²`.
* `gaussPrimeZeta_pos` — strict positivity in the region of convergence.
* `gaussPrimeZeta_le_two_primeZeta` — a quantitative bridge to the rational
  prime zeta function `primeZeta` of `Catalog.Novelty.PrimeZetaAbscissa`:
  `P_{ℚ(i)}(s) ≤ 2·P(s)` for `s > 1`.

The sharp statement that the abscissa is *exactly* `1` (and the conjectural
natural boundary along the imaginary axis) is discussed in `FUTURE_DIRECTIONS.md`;
it requires positive Dirichlet density of the split primes `p ≡ 1 (mod 4)`,
which is genuinely deeper than the elementary comparison estimates proved here.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "The prime-ideal zeta of an imaginary quadratic field
should have the same abscissa `1` as the rational prime zeta, but the *floor* of
its convergence is set by the inert primes (norm `p²`), which alone already force
divergence up to `s = 1/2`."
Experiment (Experimenter): Modelled `ℚ(i)` faithfully by the `p mod 4` splitting
and reduced every estimate to two pointwise bounds: `p^{-2s} ≤ term ≤ 2·p^{-s}`
(for `s ≥ 0`), then fed them to `Summable.of_nonneg_of_le` against the rational
prime zeta series from the catalog file.
Analysis (Analyst): The upper bound `term ≤ 2 p^{-s}` gives convergence for
`s > 1` unconditionally; the lower bound `term ≥ p^{-2s}` gives divergence for
`s ≤ 1/2` unconditionally.  The remaining window `(1/2, 1]` is exactly where the
*split* primes must be shown to have positive density — true (Dirichlet) but not
elementary, hence left as a conjecture.
Critique (Critic): Verified the series is not vacuous (the prime `2` gives a
strictly positive term), that the divergence uses an honest inert lower bound and
not a degenerate empty sum, and that the bridge genuinely consumes the catalog
lemma `primeZeta_summable_iff`.
Synthesis (PI): The two-sided abscissa bracket `[1/2, 1]` cleanly isolates the
inert contribution (the unconditional floor) from the split contribution (the
conjectural ceiling and natural-boundary phenomenon).
-/

open scoped BigOperators

namespace ImaginaryQuadraticPrimeZeta

/-- The per-prime term of the Gaussian prime-ideal zeta function, encoding the
`p mod 4` splitting law in `ℤ[i]`. -/
noncomputable def gaussTerm (s : ℝ) (p : Nat.Primes) : ℝ :=
  if (p : ℕ) = 2 then (2 : ℝ) ^ (-s)
  else if (p : ℕ) % 4 = 1 then 2 * (p : ℝ) ^ (-s)
  else (p : ℝ) ^ (-(2 * s))

/-- The **Gaussian prime-ideal zeta function**
`P_{ℚ(i)}(s) = ∑_{𝔭} N(𝔭)^{-s}`, organised over the rational primes below `𝔭`. -/
noncomputable def gaussPrimeZeta (s : ℝ) : ℝ := ∑' p : Nat.Primes, gaussTerm s p

/-
Every term of the Gaussian prime-ideal zeta series is nonnegative.
-/
theorem gaussTerm_nonneg (s : ℝ) (p : Nat.Primes) : 0 ≤ gaussTerm s p := by
  unfold gaussTerm; split_ifs <;> positivity;

/-
Pointwise upper bound: each term is at most `2 · p^{-s}` (for `s ≥ 0`).
-/
theorem gaussTerm_le (s : ℝ) (hs : 0 ≤ s) (p : Nat.Primes) :
    gaussTerm s p ≤ 2 * (p : ℝ) ^ (-s) := by
  unfold gaussTerm; split_ifs;
  · norm_num [ ‹_› ];
    exact le_mul_of_one_le_left ( by positivity ) ( by norm_num );
  · norm_num;
  · exact le_trans ( Real.rpow_le_rpow_of_exponent_le ( mod_cast p.2.one_lt.le ) ( by linarith ) ) ( le_mul_of_one_le_left ( by positivity ) ( by norm_num ) )

/-
Pointwise lower bound: each term is at least `p^{-2s}` (for `s ≥ 0`),
the contribution of an inert prime of norm `p²`.
-/
theorem gaussTerm_ge (s : ℝ) (hs : 0 ≤ s) (p : Nat.Primes) :
    (p : ℝ) ^ (-(2 * s)) ≤ gaussTerm s p := by
  unfold gaussTerm; split_ifs;
  · norm_num [ ‹_› ];
    linarith;
  · exact le_trans ( Real.rpow_le_rpow_of_exponent_le ( mod_cast p.2.one_lt.le ) ( by linarith : - ( 2 * s ) ≤ -s ) ) ( le_mul_of_one_le_left ( Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) ( by norm_num ) );
  · norm_num

/-
**Convergence (upper abscissa `≤ 1`).** The Gaussian prime-ideal zeta series
converges absolutely for every `s > 1`.
-/
theorem gaussPrimeZeta_summable {s : ℝ} (hs : 1 < s) :
    Summable (fun p : Nat.Primes => gaussTerm s p) := by
  refine' .of_nonneg_of_le ( fun p => gaussTerm_nonneg s p ) ( fun p => gaussTerm_le s ( by linarith ) p ) _;
  convert Summable.mul_left 2 ( primeZeta_summable_iff s |>.2 hs ) using 1

/-
**Divergence (lower abscissa `≥ 1/2`).** For `s ≤ 1/2` the Gaussian
prime-ideal zeta series diverges: the inert primes of norm `p²` already prevent
convergence.
-/
theorem gaussPrimeZeta_not_summable_of_le_half {s : ℝ} (hs0 : 0 ≤ s) (hs : s ≤ 1 / 2) :
    ¬ Summable (fun p : Nat.Primes => gaussTerm s p) := by
  -- By comparison, it suffices to show that the series $\sum_{p \text{ prime}} p^{-2s}$ diverges.
  suffices h_div : ¬ Summable (fun p : Nat.Primes => (p : ℝ) ^ (-(2 * s))) by
    exact fun h => h_div <| h.of_nonneg_of_le ( fun p => Real.rpow_nonneg ( Nat.cast_nonneg _ ) _ ) fun p => gaussTerm_ge s hs0 p;
  convert primeZeta_not_summable_of_le_one _;
  linarith

/-
In its region of convergence the Gaussian prime-ideal zeta function is
strictly positive (the ramified prime `2` contributes a positive term).
-/
theorem gaussPrimeZeta_pos {s : ℝ} (hs : 1 < s) : 0 < gaussPrimeZeta s := by
  refine' lt_of_lt_of_le _ ( Summable.le_tsum _ ⟨ 2, Nat.prime_two ⟩ fun p _ => gaussTerm_nonneg s p );
  · exact Real.rpow_pos_of_pos zero_lt_two _;
  · exact gaussPrimeZeta_summable hs

/-
**Bridge to the rational prime zeta function.** For `s > 1` the Gaussian
prime-ideal zeta is dominated by twice the rational prime zeta function
`primeZeta` of `Catalog.Novelty.PrimeZetaAbscissa`.
-/
theorem gaussPrimeZeta_le_two_primeZeta {s : ℝ} (hs : 1 < s) :
    gaussPrimeZeta s ≤ 2 * primeZeta s := by
  unfold gaussPrimeZeta primeZeta;
  rw [ ← tsum_mul_left ] ; exact Summable.tsum_le_tsum ( fun p => gaussTerm_le s ( by linarith ) p ) ( gaussPrimeZeta_summable hs ) ( Summable.mul_left _ <| by simpa using @primeZeta_summable_iff s |>.2 hs ) ;

end ImaginaryQuadraticPrimeZeta