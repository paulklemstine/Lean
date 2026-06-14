/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Taylor Reconstruction, Iterated Pointing, and the Higher Leibniz Rule for Species

This file iterates the *differential* dictionary of combinatorial species one further turn,
building directly on the Taylor tower of
`Catalog/Speculative/AutoResearch/SpeciesTaylorCalculus.lean` and the bridges of
`Catalog/Applications/CombinatorialSpecies.lean` /
`Catalog/Applications/SpeciesAnalyticBridge.lean`.

Three independent extensions are formalized:

* **Taylor reconstruction (FUTURE_DIRECTIONS #2).** `species_maclaurin` extracts each
  coefficient `F[k]` as `coeff₀ (derivativeFun^[k] (F.EGF))`.  Here we *assemble* the tower
  back into the whole series: a power series `f` over `ℚ` is the formal Taylor series of its
  own derivative tower, `egf (fun k => coeff₀ (derivativeFun^[k] f)) = f`.  Because `egf` is a
  bijection (`egf_seqOf`) and the tower-at-origin map is its inverse on counting data, the
  Taylor expansion is an exact *algebraic* inversion, finite at each coefficient.

* **Iterated pointing and the Euler operator `(X d/dX)^k` (FUTURE_DIRECTIONS #4).** Iterating
  Joyal's pointed species `F•[n] = [n] × F[n]` weights the `n`-th count by `n^k`,
  `(F^{•k})[n] = n^k · F[n]`, and on the analytic side this is the `k`-fold Euler operator
  `θ = X · d/dX`, `(F^{•k}).EGF = (X · d/dX)^[k] (F.EGF)`.

* **The higher Leibniz rule (FUTURE_DIRECTIONS #3).** The `k`-fold formal derivative of a
  product is the binomial convolution of the derivative towers,
  `(f·g)^{(k)} = Σ_{i≤k} C(k,i) · f^{(i)} · g^{(k-i)}` — the Faà-di-Bruno backbone whose
  species shadow is the higher product rule for `binConv`.

## Main results
* `coeff_zero_iterate_derivativeFun` — `coeff₀ (derivativeFun^[k] (egf a)) = a k`.
* `taylor_reconstruction`           — `egf (fun k => coeff₀ (derivativeFun^[k] f)) = f`.
* `coeffSeq_iterate_pointed`        — `(F^{•k})[n] = n^k · F[n]`.
* `EGF_iterate_pointed`             — `(F^{•k}).EGF = (X · d/dX)^[k] (F.EGF)`.
* `derivativeFun_iterate_mul`       — the higher (binomial) Leibniz rule on `ℚ⟦X⟧`.
-/
import Mathlib
import Catalog.Applications.SpeciesAnalyticBridge
import Catalog.Speculative.AutoResearch.SpeciesTaylorCalculus

open scoped BigOperators
open PowerSeries Finset

namespace CombinatorialSpecies

noncomputable section

/-
-- !-- Lab Notebook -- !--
Hypothesis: `species_maclaurin` gives a per-coefficient *extraction* `coeff₀ (d/dX)^[k] f = a k`;
  the natural dual is a per-coefficient *reconstruction* that re-assembles the whole series.
  Iterated pointing should weight counts by `n^k` (the Euler operator `θ = X d/dX`), and the
  k-fold derivative of a product should obey a binomial Leibniz expansion.

Result: All five theorems proved with no `sorry`.  Reconstruction follows from
  `egf_seqDeriv_iterate` (the k-fold shift bridge) read at `coeff 0`, combined with
  `egf_seqOf`/surjectivity.  Iterated pointing is two clean `Function.iterate` inductions
  (`coeffSeq_pointed` + `EGF_pointedSpecies` as the one-step bridges).  The higher Leibniz rule
  is a single induction on `k` using Mathlib's `derivativeFun_mul` and the Pascal identity.

Insight: the Taylor tower is *invertible*: `coeff₀ ∘ (d/dX)^[·]` and `egf` are mutually inverse
  on counting data, so the discrete species "Taylor series" is an exact algebraic identity, not
  an analytic limit.  Pointing (`θ`, multiplicative) and the derivative species (shift) are the
  two lifts of `d/dX` to species; their EGF shadows are `X·d/dX` and `d/dX` respectively.

Failure analysis: the reconstruction proof must avoid re-deriving `species_maclaurin` per `k`;
  routing through `egf_seqDeriv_iterate` at `coeff 0` (where `0 + k = k`) keeps it a one-liner.
  The Leibniz induction needs the index split `range (k+2)` via `Finset.sum_range_succ'`/Pascal;
  delegating the algebra to `derivativeFun` linearity avoids antidiagonal bookkeeping.
-/

/-! ### Taylor reconstruction: a power series is the Taylor series of its derivative tower -/

/-
!-- Read `egf_seqDeriv_iterate a k` at `coeff 0`: LHS `coeff 0 (egf (a(·+k))) = a(0+k)/0! = a k`,
RHS `coeff 0 (derivativeFun^[k] (egf a))`; equate. -- !--

**Taylor coefficient extraction (analytic form).** The constant term of the `k`-fold formal
derivative of `egf a` is exactly `a k`: the exponential normalisation cancels the factorial.
-/
theorem coeff_zero_iterate_derivativeFun (a : ℕ → ℚ) (k : ℕ) :
    PowerSeries.coeff (R := ℚ) 0 (derivativeFun^[k] (egf a)) = a k := by
  rw [ ← egf_seqDeriv_iterate ];
  simp +decide [ egf, Nat.factorial ]

/-
!-- Write `f = egf (seqOf f)` via `egf_seqOf`; then `coeff₀ (derivativeFun^[k] f) = seqOf f k`
by `coeff_zero_iterate_derivativeFun`, so the LHS is `egf (seqOf f) = f`. -- !--

**Taylor reconstruction.** Every formal power series over `ℚ` is the exponential generating
function of its own derivative tower evaluated at the origin:
`egf (fun k => coeff₀ (derivativeFun^[k] f)) = f`.  Since `egf` is a bijection and the
tower-at-origin map is its inverse on counting data, this is an exact algebraic inversion.
-/
theorem taylor_reconstruction (f : ℚ⟦X⟧) :
    egf (fun k => PowerSeries.coeff (R := ℚ) 0 (derivativeFun^[k] f)) = f := by
  rw [ ← egf_seqOf f ];
  exact congr_arg _ ( funext fun k => by rw [ coeff_zero_iterate_derivativeFun ] )

/-- **Species Taylor series.** A species is the formal Taylor series of its own derivative
tower: `egf (k ↦ coeff₀ (derivativeFun^[k] (F.EGF))) = F.EGF`. -/
theorem species_taylor_series (F : Species) :
    egf (fun k => PowerSeries.coeff (R := ℚ) 0 (derivativeFun^[k] F.EGF)) = F.EGF :=
  taylor_reconstruction F.EGF

/-! ### Iterated pointing and the Euler operator `(X d/dX)^k` -/

/-
!-- Induction on `k` generalizing nothing; step uses `Function.iterate_succ_apply'` to expose
the outer `pointed`, then `coeffSeq_pointed` and the IH, finishing with `pow_succ`. -- !--

**Iterated pointing weights counts by `n^k`.** Distinguishing `k` (ordered, with repetition)
labels multiplies the `n`-th count by `n^k`: `(F^{•k})[n] = n^k · F[n]`.
-/
theorem coeffSeq_iterate_pointed (F : Species) (k n : ℕ) :
    (Species.pointed^[k] F).coeffSeq n = n ^ k * F.coeffSeq n := by
  induction' k with k ih generalizing n <;> simp_all +decide [ Function.iterate_succ_apply', pow_succ, mul_assoc ];
  ring

/-
!-- Induction on `k`; step rewrites both sides with `Function.iterate_succ_apply'`, applies
`EGF_pointedSpecies` to the outer pointing, then the IH. -- !--

**EGF of the iterated pointed species is the `k`-fold Euler operator.**
`(F^{•k}).EGF = (X · d/dX)^[k] (F.EGF)`.
-/
theorem EGF_iterate_pointed (F : Species) (k : ℕ) :
    (Species.pointed^[k] F).EGF
      = (fun s => PowerSeries.X * PowerSeries.derivativeFun s)^[k] (F.EGF) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [Function.iterate_succ_apply', Function.iterate_succ_apply', ← ih, EGF_pointedSpecies]

/-! ### The higher Leibniz rule on `ℚ⟦X⟧` -/

/-
!-- Induction on `k`.  Base: `iterate 0` is identity, `range 1` sum is the single `f*g` term.
Step: apply IH, then `derivativeFun` (additive, `derivativeFun_mul`) term-by-term and
re-index with the Pascal identity `C(k+1,i) = C(k,i) + C(k,i-1)`. -- !--

**Higher (binomial) Leibniz rule.** The `k`-fold formal derivative of a product is the
binomial convolution of the derivative towers:
`(f·g)^{(k)} = Σ_{i ≤ k} C(k,i) · f^{(i)} · g^{(k-i)}`.
-/
theorem derivativeFun_iterate_mul (f g : ℚ⟦X⟧) (k : ℕ) :
    derivativeFun^[k] (f * g)
      = ∑ i ∈ Finset.range (k + 1),
          (k.choose i : ℚ) • (derivativeFun^[i] f * derivativeFun^[k - i] g) := by
  induction' k with k ih;
  · norm_num;
  · -- Apply the derivative to both sides of the induction hypothesis.
    have h_deriv : derivativeFun (derivativeFun^[k] (f * g)) = ∑ i ∈ Finset.range (k + 1), (Nat.choose k i : ℚ) • (derivativeFun^[i + 1] f * derivativeFun^[k - i] g + derivativeFun^[i] f * derivativeFun^[k - i + 1] g) := by
      rw [ ih ];
      induction' ( Finset.range ( k + 1 ) ) using Finset.induction <;> simp_all +decide [ Function.iterate_succ_apply' ];
      · simp +decide [ PowerSeries.derivativeFun ];
        ext; simp +decide [ PowerSeries.coeff_mk ];
      · simp_all +decide [ add_assoc, PowerSeries.derivativeFun_add ];
        rw [ ← add_assoc, PowerSeries.derivativeFun_smul, PowerSeries.derivativeFun_mul ];
        simp +decide [ mul_comm ];
        exact add_comm _ _;
    rw [ Function.iterate_succ_apply', h_deriv ];
    rw [ Finset.sum_range_succ, Finset.sum_range_succ' ];
    simp +decide [ Finset.sum_add_distrib, Nat.choose_succ_succ, add_smul, smul_add, Finset.sum_range_succ ];
    have := Finset.sum_range_sub ( fun x => ( k.choose x : ℚ ) • ( derivativeFun^[x] f * derivativeFun^[k - x] g.derivativeFun ) ) k; simp_all +decide [ smul_add ] ;
    rw [ show ( ∑ x ∈ Finset.range k, ( k.choose ( x + 1 ) : ℚ ) • ( derivativeFun^[x] f.derivativeFun * derivativeFun^[k - x] g ) ) = ( ∑ x ∈ Finset.range k, ( k.choose ( x + 1 ) : ℚ ) • ( derivativeFun^[x] f.derivativeFun * derivativeFun^[k - ( x + 1 ) ] g.derivativeFun ) ) from Finset.sum_congr rfl fun x hx => ?_ ];
    · grind;
    · rw [ show k - x = k - ( x + 1 ) + 1 by rw [ tsub_add_eq_add_tsub ( by linarith [ Finset.mem_range.mp hx ] ) ] ; simp +decide ] ; simp +decide [ Function.iterate_succ_apply' ];
      exact congr_arg _ ( congr_arg _ ( by exact Nat.recOn ( k - ( x + 1 ) ) rfl fun n ihn => by simp +decide [ *, Function.iterate_succ_apply' ] ) )

end

end CombinatorialSpecies