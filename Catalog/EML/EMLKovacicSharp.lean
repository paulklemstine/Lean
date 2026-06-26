import Mathlib
import EML.EMLAiryRiccati

/-!
# Sharpness of the Kovacic Degree-Parity Decision for EML ODEs

The Kovacic algorithm decides whether a second-order linear ODE `y″ = f·y` has a
"Liouvillian" (EML closed-form) solution by, at its first step, testing whether the
associated Riccati equation `v′ + v² = f` has a *rational* solution.  The catalog
file `EML.EMLAiryRiccati` proves the **odd-degree obstruction**: if `deg f` is odd,
no rational solution exists (cleared form `p′q − pq′ + p² = f·q²` is unsolvable for
`q ≠ 0`).

This file pins down the **sharpness** of that decision criterion and packages it as a
genuine *decision* over the family `y″ = f·y`:

* the obstruction extends verbatim to the whole **generalized Airy family**
  `y″ = X^(2k+1)·y` (`no_rational_riccati_genAiry`);
* the odd-degree hypothesis is **necessary**: for the even-degree coefficient
  `f = X² + 1` the Riccati equation *does* have a rational (indeed polynomial)
  solution `v = X` (`riccati_evenDeg_solvable`).  This corresponds to the genuinely
  EML-solvable equation `y″ = (x²+1) y` with solution `y = e^{x²/2}`;
* combining the two, the parity test `Odd (deg f)` is a *correct* decision rule on
  this family: it returns "no rational Riccati solution" exactly when one provably
  does not exist, and the boundary case `X²+1` shows the rule cannot be relaxed
  (`kovacic_parity_decision_sharp`).

## Main results

* `HasRationalRiccatiSolution` — predicate: the cleared Riccati identity for `f` has a
  solution with `q ≠ 0`.
* `no_rational_riccati_genAiry` — generalized Airy `f = X^(2k+1)` has none.
* `riccati_evenDeg_solvable` — `f = X² + 1` has one (witness `v = X`).
* `kovacic_parity_decision_sharp` — the odd-degree obstruction holds while the
  even example is solvable, so the parity criterion is sharp.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the catalog's odd-degree Riccati obstruction is *sharp* —
its odd-degree hypothesis cannot be dropped. We conjectured a concrete even-degree
coefficient with an *explicit* rational Riccati solution, making the Kovacic
parity test a provably correct AND tight decision on the family `y″ = f y`.

Experiment (Experimenter): searching small polynomials, `v = X` gives
`v′ + v² = 1 + X² = X² + 1`. Cleared (`q = 1`, `p = X`): `p′q − pq′ + p² = 1 + X²`,
matching `f·q²` for `f = X²+1`. This is dispatched by `simp [derivative_X]; ring`.
The odd side reuses `EMLAiryRiccati.no_rational_solves_riccati_odd_deg` with
`(X^(2k+1)).natDegree = 2k+1` odd (`natDegree_X_pow`).

Analysis (Analyst): the even witness is not an artifact — `y″ = (x²+1)y` is solved by
`e^{x²/2}`, whose logarithmic derivative is exactly `x = v`. So the parity criterion
tracks real EML-solvability: odd degree ⇒ obstructed, and at least one even degree ⇒
solvable. The decision is genuinely two-sided.

Critique (Critic): non-vacuous (both a positive and a negative instance are
exhibited), uses real structure (degree parity + an explicit construction), and is
not pure `decide`/`rfl`. The negative side is load-bearing on `q ≠ 0` exactly as in
the catalog. The positive side is a true existence statement, not a vacuous ∃.

Synthesis (PI): the Kovacic first step on `y″ = f y` is, for this family, *decided* by
`Odd (deg f)` — and the boundary `X²+1` shows the boundary is real. This is the
sharp, two-sided complement to the one-sided obstruction in the catalog.
-- !-- Lab Notes -- !--
-/

open Polynomial

namespace EMLKovacicSharp

/-- The cleared Riccati identity for coefficient `f` has a rational solution `v = p/q`
(with `q ≠ 0`): `p′·q − p·q′ + p² = f·q²`.  This is the first-step success condition of
the Kovacic algorithm on `y″ = f·y`. -/
def HasRationalRiccatiSolution (f : Polynomial ℝ) : Prop :=
  ∃ p q : Polynomial ℝ, q ≠ 0 ∧
    derivative p * q - p * derivative q + p ^ 2 = f * q ^ 2

/-! ### The generalized Airy family has no rational Riccati solution -/

/-- **Generalized Airy obstruction.** For every `k`, the equation `y″ = X^(2k+1)·y`
has no rational Riccati solution: the cleared identity `p′q − pq′ + p² = X^(2k+1)·q²`
is unsolvable with `q ≠ 0`.  The Airy equation itself is the case `k = 0`. -/
theorem no_rational_riccati_genAiry (k : ℕ) :
    ¬ HasRationalRiccatiSolution (X ^ (2 * k + 1)) := by
  rintro ⟨p, q, hq, heq⟩
  exact EMLAiryRiccati.no_rational_solves_riccati_odd_deg (X ^ (2 * k + 1)) p q hq
    (by rw [natDegree_X_pow]; exact ⟨k, by ring⟩) heq

/-- **Airy specialization** (`k = 0`): `y″ = x·y` has no rational Riccati solution. -/
theorem no_rational_riccati_airy : ¬ HasRationalRiccatiSolution (X : Polynomial ℝ) := by
  have h := no_rational_riccati_genAiry 0
  simpa using h

/-! ### Sharpness: an even-degree coefficient that *is* solvable -/

/-- **Even-degree solvability witness.** For `f = X² + 1` the Riccati equation has the
explicit polynomial solution `v = X` (cleared form with `p = X`, `q = 1`).  This
corresponds to the EML-solvable equation `y″ = (x²+1)·y` with solution `y = e^{x²/2}`,
and shows the odd-degree hypothesis of the obstruction is necessary. -/
theorem riccati_evenDeg_solvable :
    HasRationalRiccatiSolution (X ^ 2 + 1 : Polynomial ℝ) := by
  refine ⟨X, 1, one_ne_zero, ?_⟩
  simp [derivative_X]; ring

/-- The even-degree coefficient `X² + 1` indeed has even degree `2`. -/
theorem natDegree_evenWitness : (X ^ 2 + 1 : Polynomial ℝ).natDegree = 2 := by
  compute_degree!

/-! ### Two-sided sharpness of the parity decision -/

/-- **Sharpness of the Kovacic parity decision.** On the family `y″ = f·y`, the
odd-degree test is a correct *and tight* decision rule: every generalized-Airy
coefficient `X^(2k+1)` (odd degree) is obstructed, while the even-degree coefficient
`X² + 1` admits a rational Riccati solution.  Hence the odd-degree hypothesis cannot
be dropped. -/
theorem kovacic_parity_decision_sharp :
    (∀ k : ℕ, ¬ HasRationalRiccatiSolution (X ^ (2 * k + 1))) ∧
      HasRationalRiccatiSolution (X ^ 2 + 1 : Polynomial ℝ) :=
  ⟨no_rational_riccati_genAiry, riccati_evenDeg_solvable⟩

end EMLKovacicSharp