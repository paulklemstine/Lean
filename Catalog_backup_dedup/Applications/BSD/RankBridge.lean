/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# BSD Research Cycle — The Rank Bridge: Analytic ↔ Algebraic

The Birch and Swinnerton-Dyer conjecture is the assertion that two a priori
unrelated integers coincide:

  * the **analytic rank** `ord_{s=1} L(E, s)` (the order of vanishing of the
    Hasse–Weil L-function at the central point), and
  * the **algebraic rank** `rank E(ℚ)` (the free rank of the Mordell–Weil group).

This file builds the bridge between the two halves developed in `LocalFactor.lean`
(the analytic input — Frobenius eigenvalues and the Hasse bound) and
`AnalyticRank.lean` (the order of vanishing).  Modelling the Mordell–Weil group as
`ℤ^r × T` with `T` the finite torsion subgroup, the central theorem is the
*qualitative BSD prediction*: under the rank equality, the central L-value vanishes
**iff** the curve has infinitely many rational points.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): BSD's rank equality has an immediate *qualitative*
  consequence that needs no leading-coefficient information — `L(E,1) = 0` iff
  `E(ℚ)` is infinite.  The algebraic side of this is pure finitely-generated
  abelian group theory: `ℤ^r × (finite)` is infinite iff `r ≥ 1`.
Experiment (Experimenter): prove `mordellWeil_infinite_iff` for `(Fin r → ℤ) × T`
  with `T` a finite nonempty type, then chain it with `analyticRank_pos_iff` from
  `AnalyticRank.lean` across the BSD equality `analyticRank = r`.
Analysis (Analyst): the `r = 0` direction needs the torsion `T` to be finite (else
  the product could be infinite from torsion); the `r ≥ 1` direction needs `T`
  nonempty (the point at infinity `O` guarantees this).  Both are exactly the
  honest hypotheses on a real Mordell–Weil group.
Critique (Critic): the bridge must not be vacuous — `AnalyticRank.modelL` realizes
  every analytic rank, so for each `r` there is a witness making both sides of the
  bridge non-degenerate.  We also verify the local consistency input
  (`hasse_point_count_pos`) drawn from `LocalFactor.hasse_bound`, so the file
  genuinely *uses* results from both companion modules.
Synthesis (PI): rank-equality ⟹ (central vanishing ⇔ infinitude of rational
  points), the cleanest falsifiable shadow of BSD, assembled from the local
  (Hasse) and global (order of vanishing) theories.
-/
import Mathlib
import Applications.BSD.LocalFactor
import Applications.BSD.AnalyticRank

namespace BSD.RankBridge

open BSD.AnalyticRank

/-- **Mordell–Weil infinitude criterion.**  A finitely generated abelian group of
the shape `ℤ^r × T`, with `T` a finite nonempty torsion part, is infinite **iff**
its free rank `r` is positive.  This is the algebraic content of "rank `> 0` ⇔
infinitely many rational points". -/
theorem mordellWeil_infinite_iff (r : ℕ) (T : Type) [Fintype T] [Nonempty T] :
    Infinite ((Fin r → ℤ) × T) ↔ 0 < r := by
  constructor
  · intro h
    by_contra hr
    push_neg at hr
    interval_cases r
    · have : Finite ((Fin 0 → ℤ) × T) := by infer_instance
      exact not_finite ((Fin 0 → ℤ) × T)
  · intro hr
    have hinf : Infinite (Fin r → ℤ) := by
      obtain ⟨i⟩ : Nonempty (Fin r) := Fin.pos_iff_nonempty.mp hr
      exact Infinite.of_injective (fun n : ℤ => Function.update (0 : Fin r → ℤ) i n)
        (fun a b hab => by have := congrFun hab i; simpa using this)
    exact Prod.infinite_of_left

/-- **Local consistency (uses `LocalFactor.hasse_bound`).**  At a prime `p > 1` of
good reduction, the Hasse bound forces the point count `#E(𝔽_p) = p + 1 - a_p` to be
strictly positive: the trace `a_p` can never overtake `p + 1`.  This guarantees the
local Euler factor never trivializes the global L-function. -/
theorem hasse_point_count_pos (a p : ℝ) (hp : 1 < p) (h : a ^ 2 ≤ 4 * p) :
    0 < p + 1 - a := by
  have hb : |a| ≤ 2 * Real.sqrt p := BSD.LocalFactor.hasse_bound a p (by linarith) h
  have ha : a ≤ 2 * Real.sqrt p := le_trans (le_abs_self a) hb
  have hsp : (0 : ℝ) ≤ p := by linarith
  have h1 : 1 < Real.sqrt p := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_lt_sqrt (by norm_num) hp
  nlinarith [Real.sq_sqrt hsp, Real.sqrt_nonneg p, sq_nonneg (Real.sqrt p - 1), h1]

/-- **The qualitative BSD bridge.**  Assume the Birch–Swinnerton-Dyer rank equality
`analyticRank L 1 = r`, where `r` is the free rank of the Mordell–Weil group
`E(ℚ) ≅ ℤ^r × T` (`T` the finite nonempty torsion subgroup).  Then the central
L-value vanishes **iff** `E(ℚ)` is infinite, i.e. iff `E` has infinitely many
rational points. -/
theorem bsd_central_vanishing_iff_infinite (L : ℂ → ℂ) (hL : AnalyticAt ℂ L 1)
    (hfin : analyticOrderAt L 1 ≠ ⊤) (r : ℕ) (T : Type) [Fintype T] [Nonempty T]
    (hbsd : analyticRank L 1 = r) :
    L 1 = 0 ↔ Infinite ((Fin r → ℤ) × T) := by
  rw [← analyticRank_pos_iff L 1 hL hfin, hbsd, mordellWeil_infinite_iff]

/-- **Rank-zero form of the bridge.**  Under the BSD rank equality, the central
value is nonzero iff the Mordell–Weil group is finite (algebraic rank `0`). -/
theorem bsd_nonvanishing_iff_finite (L : ℂ → ℂ) (hL : AnalyticAt ℂ L 1)
    (hfin : analyticOrderAt L 1 ≠ ⊤) (r : ℕ) (T : Type) [Fintype T] [Nonempty T]
    (hbsd : analyticRank L 1 = r) :
    L 1 ≠ 0 ↔ Finite ((Fin r → ℤ) × T) := by
  rw [Ne, bsd_central_vanishing_iff_infinite L hL hfin r T hbsd, not_infinite_iff_finite]

/-- **Non-vacuity of the bridge.**  For every target rank `r` and nonzero leading
coefficient `c`, the model L-function `(s-1)^r · c` satisfies the BSD rank equality
hypothesis with algebraic rank `r`, witnessing that the bridge applies to genuinely
distinct ranks rather than a single degenerate case. -/
theorem bridge_realized (r : ℕ) (c : ℂ) (hc : c ≠ 0) :
    analyticRank (modelL r c) 1 = r :=
  modelL_analyticRank r c hc

end BSD.RankBridge