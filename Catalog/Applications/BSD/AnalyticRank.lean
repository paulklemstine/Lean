/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# BSD Research Cycle — The Analytic Rank and the Order of Vanishing

The *analytic rank* of an elliptic curve `E / ℚ` is the order of vanishing of its
Hasse–Weil L-function `L(E, s)` at the central point `s = 1`:

  `rank_an(E) := ord_{s=1} L(E, s)`.

The Birch and Swinnerton-Dyer conjecture asserts that this analytic rank equals the
algebraic (Mordell–Weil) rank.  This file isolates the *analytic* half of that
statement: it formalizes the order of vanishing through Mathlib's `analyticOrderAt`,
proves the structural facts an L-function rank must satisfy (rank `0` ⇔ non-vanishing
central value, leading-term factorization, additivity under products), and exhibits a
non-vacuous model whose analytic rank is an arbitrary prescribed integer `r`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the analytic rank is governed entirely by the local
  Taylor data of `L` at `s = 1`; in particular `rank = 0` should be *exactly* the
  non-vanishing of `L(1)`, and ranks should add under products of L-functions
  (the Artin/Rankin–Selberg formalism, and the splitting of L-functions under
  isogeny/products of abelian varieties).
Experiment (Experimenter): adopt `analyticRank L s₀ := analyticOrderNatAt L s₀`.
  Model curve: `L(s) = (s - 1)^r · c` with `c ≠ 0`.  Goal: prove its analytic rank
  is `r`, i.e. the framework actually computes nontrivial orders of vanishing.
Analysis (Analyst): the natural-number rank requires the order to be finite
  (`analyticOrderAt ≠ ⊤`, i.e. `L` not locally zero).  Without this hypothesis the
  `rank = 0 ⇔ L(1) ≠ 0` equivalence fails because `toNat ⊤ = 0`.  This is the
  formal shadow of the analytic-continuation hypothesis in BSD.
Critique (Critic): `analyticRank` must not be vacuous.  The model theorem
  `modelL_analyticRank` certifies that every value `r : ℕ` is realized, so the
  definition is genuinely surjective onto `ℕ` and not secretly constant.
Synthesis (PI): rank-zero detection, leading-term factorization, and additivity
  package the analytic side of BSD; the bridge to the algebraic rank is taken up in
  `RankBridge.lean`.
-/
import Mathlib

namespace BSD.AnalyticRank

open Filter Topology

/-- The **analytic rank** of an L-function `L` at the central point `s₀`: the order
of vanishing of `L` at `s₀`, as a natural number.  For the BSD L-function one takes
`s₀ = 1`. -/
noncomputable def analyticRank (L : ℂ → ℂ) (s₀ : ℂ) : ℕ := analyticOrderNatAt L s₀

/-- **Rank-zero detection.**  When `L` is analytic at `s₀` and does not vanish
identically near `s₀`, the analytic rank is `0` iff the central value `L(s₀)` is
nonzero.  This is the analytic side of "rank `0` ⇔ `L(E, 1) ≠ 0`". -/
theorem analyticRank_eq_zero_iff (L : ℂ → ℂ) (s₀ : ℂ) (hL : AnalyticAt ℂ L s₀)
    (hfin : analyticOrderAt L s₀ ≠ ⊤) :
    analyticRank L s₀ = 0 ↔ L s₀ ≠ 0 := by
  unfold analyticRank analyticOrderNatAt
  rw [ENat.toNat_eq_zero, analyticOrderAt_eq_zero]
  simp only [hfin, or_false]
  constructor
  · rintro (h | h)
    · exact absurd hL h
    · exact h
  · intro h; exact Or.inr h

/-- **Positive-rank detection.**  Under the same hypotheses, the analytic rank is
positive iff the central value vanishes — the precise statement "`L(E, 1) = 0` ⇔
analytic rank `≥ 1`", which BSD links to infinitely many rational points. -/
theorem analyticRank_pos_iff (L : ℂ → ℂ) (s₀ : ℂ) (hL : AnalyticAt ℂ L s₀)
    (hfin : analyticOrderAt L s₀ ≠ ⊤) :
    0 < analyticRank L s₀ ↔ L s₀ = 0 := by
  rw [Nat.pos_iff_ne_zero, Ne, analyticRank_eq_zero_iff L s₀ hL hfin, not_not]

/-- **Leading-term factorization.**  An L-function of analytic rank `r` factors
locally as `L(s) = (s - s₀)^r · g(s)` with `g` analytic and `g(s₀) ≠ 0`.  The
nonzero value `g(s₀)` is the *leading Taylor coefficient* whose value the full BSD
formula predicts in terms of the regulator, `Ш`, and the Tamagawa numbers. -/
theorem analyticRank_factorization (L : ℂ → ℂ) (s₀ : ℂ) (hL : AnalyticAt ℂ L s₀)
    (hfin : analyticOrderAt L s₀ ≠ ⊤) :
    ∃ g : ℂ → ℂ, AnalyticAt ℂ g s₀ ∧ g s₀ ≠ 0 ∧
      ∀ᶠ z in 𝓝 s₀, L z = (z - s₀) ^ (analyticRank L s₀) • g z :=
  (hL.analyticOrderNatAt_eq_iff hfin (n := analyticRank L s₀)).mp rfl

/-- **Additivity of analytic rank under products.**  The analytic rank of a product
of L-functions is the sum of the analytic ranks.  This is the rank statement behind
the Artin formalism: the L-function of a product of abelian varieties (or an
isogeny-split Jacobian) is a product of L-functions, and analytic ranks add. -/
theorem analyticRank_mul (f g : ℂ → ℂ) (s₀ : ℂ) (hf : AnalyticAt ℂ f s₀)
    (hg : AnalyticAt ℂ g s₀) (hffin : analyticOrderAt f s₀ ≠ ⊤)
    (hgfin : analyticOrderAt g s₀ ≠ ⊤) :
    analyticRank (f * g) s₀ = analyticRank f s₀ + analyticRank g s₀ := by
  unfold analyticRank
  exact analyticOrderNatAt_mul hf hg hffin hgfin

/-- A model L-function `L(s) = (s - 1)^r · c` with prescribed order of vanishing `r`
and nonzero leading coefficient `c` at the central point `s = 1`. -/
noncomputable def modelL (r : ℕ) (c : ℂ) : ℂ → ℂ := fun s => (s - 1) ^ r * c

/-- The model L-function is analytic everywhere, in particular at the central point. -/
theorem modelL_analyticAt (r : ℕ) (c : ℂ) : AnalyticAt ℂ (modelL r c) 1 := by
  apply AnalyticAt.mul
  · exact (analyticAt_id.sub analyticAt_const).pow r
  · exact analyticAt_const

/-- **Realizability of every analytic rank.**  The model curve with leading
coefficient `c ≠ 0` has analytic rank exactly `r`.  Hence the analytic-rank
invariant is genuinely surjective onto `ℕ` — it is not secretly constant or trivial,
answering the Critic's vacuity concern. -/
theorem modelL_analyticRank (r : ℕ) (c : ℂ) (hc : c ≠ 0) :
    analyticRank (modelL r c) 1 = r := by
  have hord : analyticOrderAt (modelL r c) 1 = (r : ℕ∞) := by
    rw [(modelL_analyticAt r c).analyticOrderAt_eq_natCast]
    exact ⟨fun _ => c, analyticAt_const, hc,
      Eventually.of_forall (fun z => by simp [modelL, smul_eq_mul])⟩
  unfold analyticRank analyticOrderNatAt
  rw [hord]
  simp

/-- The central value of the rank-`r` model (with nonzero leading coefficient)
vanishes precisely when `r ≥ 1`, matching `analyticRank_pos_iff` on an explicit
family. -/
theorem modelL_central_value (r : ℕ) (c : ℂ) (hc : c ≠ 0) :
    modelL r c 1 = 0 ↔ 0 < r := by
  unfold modelL
  rw [sub_self]
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos r with hr | hr
    · rw [hr, pow_zero, one_mul] at h; exact absurd h hc
    · exact hr
  · intro hr
    rw [zero_pow (Nat.pos_iff_ne_zero.mp hr), zero_mul]

end BSD.AnalyticRank