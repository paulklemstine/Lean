/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Taylor / Maclaurin Calculus of Combinatorial Species

This file extends the *differential* dictionary established in
`Catalog/Applications/CombinatorialSpecies.lean` (the bridges `egf_derivative`,
`EGF_derivativeSpecies`, `egf_injective`) from the *first* derivative to the **full Taylor
tower** of higher derivatives of a combinatorial species.

Iterating Joyal's derivative species `F′[n] = F[n+1]` gives the `k`-th derivative
`F^{(k)}[n] = F[n+k]` — "a structure on `n` labels with `k` extra ghost points".  Evaluating
the tower "at the origin" `n = 0` recovers the counting sequence one coefficient at a time:
`F^{(k)}[0] = F[k]`.  On the analytic side this is intertwined with the `k`-fold formal
derivative `derivativeFun^[k]` of the EGF, and the constant term of that `k`-fold derivative
recovers the *un-normalised* counting number `F[k]` (no factorial) — the species-theoretic
**Maclaurin reconstruction**.

## Main results
* `egf_seqDeriv_iterate`        — `k`-fold shift of a sequence ↔ `k`-fold formal derivative.
* `coeffSeq_iterate_derivative` — `F^{(k)}[n] = F[n+k]` at the level of counting sequences.
* `taylor_coeffSeq`             — `F^{(k)}[0] = F[k]` (Taylor evaluation at the origin).
* `EGF_iterate_derivative`      — `(F^{(k)}).EGF = derivativeFun^[k] (F.EGF)`.
* `species_maclaurin`           — `coeff₀ (derivativeFun^[k] (F.EGF)) = F[k]` (reconstruction).
-/
import Mathlib
import Catalog.Applications.CombinatorialSpecies

open scoped BigOperators
open PowerSeries Finset

namespace CombinatorialSpecies

noncomputable section

/-
-- !-- Lab Notebook -- !--
Hypothesis: The first-order differential bridge `egf_derivative` / `EGF_derivativeSpecies`
  should iterate to a *Taylor tower*: the `k`-fold shift `a ↦ a(·+k)` is intertwined with
  `derivativeFun^[k]`, the `k`-fold derivative species `F^{(k)}[n] = F[n+k]` has EGF
  `derivativeFun^[k] (F.EGF)`, and evaluation at `n=0` should reconstruct the counting
  sequence `F^{(k)}[0] = F[k]`.

Result: All five theorems proved with no `sorry`.  The two combinatorial facts
  (`coeffSeq_iterate_derivative`, `taylor_coeffSeq`) and the two analytic facts
  (`egf_seqDeriv_iterate`, `EGF_iterate_derivative`) are clean inductions whose inductive
  step is a *single* application of the already-proved `k=1` bridge.  The cross-bridge
  `species_maclaurin` then extracts `F[k]` as the constant term of the `k`-fold derivative.

Insight: The "Taylor coefficient extraction" identity
  `coeff₀ (derivativeFun^[k] (egf a)) = a k`
  is striking: the exponential normalisation `/n!` of the EGF exactly cancels the `k!` that
  an ordinary Maclaurin expansion would introduce, so the *un-normalised* species count `F[k]`
  is read off directly.  This is why the EGF — not the ordinary GF — is the natural transform
  for the differential calculus of species.

Failure analysis: The naïve induction `induction k` fails because the inductive step needs the
  hypothesis at a *shifted* argument (`shift a` for sequences, `n+1` for the cardinality).  The
  fix is `generalizing a` / `generalizing n`, combined with the two flavours of iterate-unfolding
  (`Function.iterate_succ_apply` peels from the inside, `iterate_succ_apply'` from the outside);
  choosing the matching one for each side keeps the rewrites defeq-clean.
-/

/-! ### The Taylor tower at the level of counting sequences -/

-- !-- Induction on `k` generalizing `a`: the step rewrites `a(n+(k+1))` as `(shift a)(n+k)`,
--     applies the IH to `shift a`, then `egf_derivative` + `Function.iterate_succ_apply`. -- !--
/-- **`k`-fold derivative bridge for sequences.** Shifting a counting sequence by `k`
corresponds to the `k`-fold formal derivative of its EGF. -/
theorem egf_seqDeriv_iterate (a : ℕ → ℚ) (k : ℕ) :
    egf (fun n => a (n + k)) = derivativeFun^[k] (egf a) := by
  induction' k with k ih generalizing a <;>
    simp_all +decide [Function.iterate_succ_apply]
  convert ih (fun n => a (n + 1)) using 1
  rw [← egf_derivative]

-- !-- Induction on `k` generalizing `n`; the step uses `Function.iterate_succ_apply'` to expose
--     the outer `derivative`, then `coeffSeq_derivative` and the IH at `n+1`. -- !--
/-- **The `k`-th derivative species counts `F[n+k]`.** Iterating `Species.derivative` adds `k`
ghost points: `F^{(k)}[n]` has the same cardinality as `F[n+k]`. -/
theorem coeffSeq_iterate_derivative (F : Species) (k n : ℕ) :
    (Species.derivative^[k] F).coeffSeq n = F.coeffSeq (n + k) := by
  induction' k with k ih generalizing n <;>
    simp_all +arith +decide [Function.iterate_succ_apply']

-- !-- Specialise `coeffSeq_iterate_derivative` at `n = 0` and simplify `0 + k = k`. -- !--
/-- **Taylor evaluation at the origin.** The `k`-th derivative species evaluated on the empty
label set recovers the `k`-th counting coefficient: `F^{(k)}[0] = F[k]`. -/
theorem taylor_coeffSeq (F : Species) (k : ℕ) :
    (Species.derivative^[k] F).coeffSeq 0 = F.coeffSeq k := by
  convert coeffSeq_iterate_derivative F k 0 using 1
  norm_num

/-! ### The Taylor tower at the level of EGFs -/

-- !-- Induction on `k`; the step rewrites both sides with `Function.iterate_succ_apply'` and
--     applies `EGF_derivativeSpecies` to the outer derivative, then the IH. -- !--
/-- **EGF of the `k`-th derivative species.** `(F^{(k)}).EGF = derivativeFun^[k] (F.EGF)`. -/
theorem EGF_iterate_derivative (F : Species) (k : ℕ) :
    (Species.derivative^[k] F).EGF = derivativeFun^[k] (F.EGF) := by
  induction' k with k ih
  · rfl
  · convert EGF_derivativeSpecies (Species.derivative^[k] F) using 1
    · rw [Function.iterate_succ_apply']
    · rw [Function.iterate_succ_apply', ih]

-- !-- `coeff₀ (derivativeFun^[k] (F.EGF)) = coeff₀ ((F^{(k)}).EGF) = (F^{(k)})[0]/0! = F[k]`,
--     using `EGF_iterate_derivative`, `coeff_egf`, and `taylor_coeffSeq`. -- !--
/-- **Maclaurin reconstruction of a species.** The constant term of the `k`-fold formal
derivative of the EGF recovers the *un-normalised* counting number `F[k]` — the exponential
normalisation cancels the factorial of an ordinary Taylor expansion. -/
theorem species_maclaurin (F : Species) (k : ℕ) :
    PowerSeries.coeff (R := ℚ) 0 (derivativeFun^[k] (F.EGF)) = (F.coeffSeq k : ℚ) := by
  have h_deriv : PowerSeries.coeff (R := ℚ) 0 (derivativeFun^[k] F.EGF)
      = PowerSeries.coeff (R := ℚ) 0 ((Species.derivative^[k] F).EGF) := by
    rw [EGF_iterate_derivative]
  convert h_deriv using 1
  exact taylor_coeffSeq F k ▸ by simp +decide [Species.EGF]

end

end CombinatorialSpecies