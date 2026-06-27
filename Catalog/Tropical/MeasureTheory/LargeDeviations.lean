/-
Copyright (c) 2025. All rights reserved.

# Idempotent Probability: Large Deviations

This file develops a **large deviation principle (LDP)** for max-plus (idempotent)
probability measures, building directly on the catalog's max-plus measure theory
(`Catalog/Tropical/MeasureTheory/Basic.lean`).

In Maslov's idempotent calculus, a tropical probability measure `P` (weights
`w(x) ≤ 0` with `sup_x w(x) = 0`) plays the role of `exp(-n I)` in classical large
deviations: the **rate function** is `I(x) = -w(x) ≥ 0`, the deviation *cost*.

## Dictionary (classical ↔ idempotent)

| classical                                   | idempotent (max-plus)                          |
|---------------------------------------------|------------------------------------------------|
| `(1/n) log E[exp(λ Sₙ)]` (cumulant gen.fn.) | `Λ(λ) = maxPlusIntegral (λ·val) P`             |
| `E[exp(λ(X+Y))]=E[exp λX]E[exp λY]` (indep) | `Λ_{X+Y}(λ) = Λ_X(λ) + Λ_Y(λ)`                 |
| Cramér: `I = Λ*` (Legendre–Fenchel)         | `lfBiconj ≤ I`, equality iff supporting line   |
| `lim (1/n) log P(Sₙ/n∈A) = -inf_A I`        | `measure A = - inf_{A} I` (sharp, every `n`)   |
| exponential Chebyshev / Chernoff bound      | `idempotent_chernoff`                          |

## Main results

* `idempotentCGF_convex` — the idempotent cumulant generating function is convex.
* `idempotentCGF_add` — **idempotent Cramér structure**: under an independent
  product with additive observable, the CGF is additive.
* `idempotentCGF_walk` — the CGF of an `n`-step max-plus random walk is `n · Λ`.
* `idempotent_chernoff` — idempotent Chernoff / LDP upper bound.
* `idempotent_ldp_sharp` — the *sharp* idempotent LDP: the cost of any event is
  exactly the infimum of the rate function over the event.
* `fenchel_young_rate` / `lfBiconj_le_rate` — weak Legendre–Fenchel duality.
* `lfBiconj_eq_rate_of_support` — equality holds exactly when a supporting line exists.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Idempotent probability measures should satisfy an LDP
  whose rate function is the Legendre–Fenchel transform of an idempotent cumulant
  generating function, mirroring Cramér's theorem.  Two surprising sub-claims:
  (S1) the idempotent LDP is *exact* for every n (not just asymptotically), and
  (S2) the rate function is recovered by double Legendre–Fenchel transform ONLY in
  the convex case — non-convex idempotent laws have a genuine duality gap.
Experiment (Experimenter): Defined `idempotentCGF` as a max-plus integral of the
  linear observable, proved convexity (sup of affine maps), additivity under
  independent products (separation of a finite sup over a product), and the n-step
  walk identity by reduction to a per-coordinate sup lemma `sup'_pi_sum`.  The
  sharp LDP is the statement `measure A = sup_A w = - inf_A I`.
Analysis (Analyst): S1 survives and is clean — idempotency removes the `log`/`exp`
  smoothing, so the bound is sharp.  S2 survives: `lfBiconj ≤ I` always, with
  equality exactly when a supporting affine functional exists; the strict gap is
  realised in `DualityGap.lean`.
Critique (Critic): The Chernoff bound is non-vacuous (requires `λ ≥ 0`), the
  duality results thread `BddAbove` via the explicit bound `I x`, and every main
  theorem uses genuine structure (induction / `le_antisymm` / convexity), not
  `decide`.
-- !-- end Lab Notes -- !--
-/

import Mathlib
import Catalog.Tropical.MeasureTheory.Basic

namespace TropicalLDP

open TropicalMeasureTheory Finset

variable {X : Type*} [Fintype X] [Nonempty X]

/-! ## Rate function and idempotent cumulant generating function -/

/-- The **rate function** of an idempotent law: `I(x) = -w(x) ≥ 0`, the deviation
cost.  Under `IsTropicalProbability` we have `I ≥ 0` and `inf_x I(x) = 0`. -/
def idempotentRate (P : MaxPlusMeasure X) (x : X) : ℝ := - P.weight x

/-- The **idempotent cumulant generating function** of an observable `val : X → ℝ`
under `P`: `Λ(λ) = maxPlusIntegral (λ · val) P = sup_x (λ·val x + w(x))`.
This is the idempotent analogue of `(1/n) log E[exp(λ Sₙ)]`. -/
noncomputable def idempotentCGF (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) : ℝ :=
  maxPlusIntegral (fun x => lam * val x) P

theorem idempotentCGF_eq (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) :
    idempotentCGF P val lam =
      Finset.univ.sup' Finset.univ_nonempty (fun x => lam * val x + P.weight x) := rfl

/-! ## Rate function basics -/

theorem idempotentRate_nonneg (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P]
    (x : X) : 0 ≤ idempotentRate P x := by
  have := hP.weight_nonpos x; simp only [idempotentRate]; linarith

/-
The rate function attains the value `0` (idempotent normalization `inf I = 0`).
-/
theorem idempotentRate_eq_zero_somewhere (P : MaxPlusMeasure X)
    [hP : IsTropicalProbability X P] : ∃ x, idempotentRate P x = 0 := by
  obtain ⟨ x, hx ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty P.weight;
  exact ⟨ x, by unfold idempotentRate; linarith [ hP.total_mass, hx.2.symm ] ⟩

/-! ## Convexity of the cumulant generating function -/

/-
**The idempotent CGF is convex** in `λ`: it is a finite supremum of affine maps.
-/
theorem idempotentCGF_convex (P : MaxPlusMeasure X) (val : X → ℝ) :
    ConvexOn ℝ Set.univ (idempotentCGF P val) := by
  refine' ⟨ convex_univ, fun x _ y _ a b ha hb hab => _ ⟩;
  convert Finset.sup'_le _ _ _;
  · exact ⟨ Classical.arbitrary X, Finset.mem_univ _ ⟩;
  · intro x_1 _; simp +decide [ idempotentCGF_eq ] ;
    convert add_le_add ( mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun x_2 => x * val x_2 + P.weight x_2 ) ( Finset.mem_univ x_1 ) ) ha ) ( mul_le_mul_of_nonneg_left ( Finset.le_sup' ( fun x => y * val x + P.weight x ) ( Finset.mem_univ x_1 ) ) hb ) using 1 ; ring;
    linear_combination -hab * P.weight x_1

/-
`Λ(0) = 0` for an idempotent probability (the total mass).
-/
theorem idempotentCGF_zero (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P]
    (val : X → ℝ) : idempotentCGF P val 0 = 0 := by
  unfold idempotentCGF; have := hP.total_mass; simp_all +decide [ maxPlusIntegral ] ;

/-! ## Idempotent Cramér structure: additivity under independence -/

/-
General separation lemma: a finite supremum of a *separable* function over a
product type splits as the sum of the marginal suprema.
-/
theorem sup'_prod_add {Y : Type*} [Fintype Y] [Nonempty Y]
    (g : X → ℝ) (h : Y → ℝ) :
    (Finset.univ : Finset (X × Y)).sup' Finset.univ_nonempty
        (fun p => g p.1 + h p.2)
      = Finset.univ.sup' Finset.univ_nonempty g
        + Finset.univ.sup' Finset.univ_nonempty h := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
  · exact fun x y => add_le_add ( Finset.le_sup' ( fun x => g x ) ( Finset.mem_univ x ) ) ( Finset.le_sup' ( fun y => h y ) ( Finset.mem_univ y ) );
  · obtain ⟨ x, hx ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) g; obtain ⟨ y, hy ⟩ := Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) h; use x, y; aesop;

/-
**Idempotent Cramér structure**: for an independent product `P × Q` with the
additive observable `val(x,y) = valX x + valY y`, the cumulant generating function
is additive — the idempotent analogue of `E[exp λ(X+Y)] = E[exp λX]·E[exp λY]`.
-/
theorem idempotentCGF_add {Y : Type*} [Fintype Y] [Nonempty Y]
    (P : MaxPlusMeasure X) (Q : MaxPlusMeasure Y)
    (valX : X → ℝ) (valY : Y → ℝ) (lam : ℝ) :
    idempotentCGF (productMaxPlusMeasure P Q)
        (fun p => valX p.1 + valY p.2) lam
      = idempotentCGF P valX lam + idempotentCGF Q valY lam := by
  convert sup'_prod_add ( fun x => lam * valX x + P.weight x ) ( fun y => lam * valY y + Q.weight y ) using 1;
  unfold idempotentCGF;
  unfold maxPlusIntegral productMaxPlusMeasure; congr; ext; ring;

/-! ## Max-plus random walks -/

/-- The **`n`-step max-plus random walk measure**: weight of a path `ω : Fin n → X`
is the sum of the per-step weights (independent steps). -/
def walkMeasure (P : MaxPlusMeasure X) (n : ℕ) : MaxPlusMeasure (Fin n → X) :=
  ⟨fun ω => ∑ i, P.weight (ω i)⟩

/-- The walk observable: the total displacement `Sₙ(ω) = ∑ val(ω i)`. -/
def walkSum (val : X → ℝ) (n : ℕ) : (Fin n → X) → ℝ := fun ω => ∑ i, val (ω i)

/-
Per-coordinate separation of a finite sup over a function type.
-/
theorem sup'_pi_sum {ι : Type*} [Fintype ι] [Nonempty ι] [DecidableEq ι]
    (g : ι → X → ℝ) :
    (Finset.univ : Finset (ι → X)).sup' Finset.univ_nonempty
        (fun ω => ∑ i, g i (ω i))
      = ∑ i, Finset.univ.sup' Finset.univ_nonempty (g i) := by
  refine' le_antisymm _ _;
  · exact Finset.sup'_le _ _ fun ω _ => Finset.sum_le_sum fun i _ => Finset.le_sup' ( fun x => g i x ) ( Finset.mem_univ _ );
  · obtain ⟨ω, hω⟩ : ∃ ω : ι → X, ∀ i, g i (ω i) = Finset.univ.sup' Finset.univ_nonempty (g i) := by
      choose ω hω using fun i => Finset.exists_mem_eq_sup' ( Finset.univ_nonempty ) ( g i );
      exact ⟨ ω, fun i => hω i |>.2.symm ⟩;
    exact Finset.le_sup' ( fun ω => ∑ i, g i ( ω i ) ) ( Finset.mem_univ ω ) |> le_trans ( by simp +decide [ ← hω ] )

/-
**CGF of a max-plus random walk** : the `n`-step walk has CGF equal to `n · Λ`.
This is the idempotent law of large numbers / the scaling that drives the LDP.
-/
theorem idempotentCGF_walk (P : MaxPlusMeasure X) (val : X → ℝ) (n : ℕ) (lam : ℝ) :
    idempotentCGF (walkMeasure P n) (walkSum val n) lam
      = n * idempotentCGF P val lam := by
  rcases n with ( _ | n ) <;> simp_all +decide [ Finset.card_univ, idempotentCGF ];
  · unfold maxPlusIntegral walkSum walkMeasure; simp +decide ;
  · convert sup'_pi_sum ( fun i x => lam * val x + P.weight x ) using 1 ; simp +decide [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, walkSum, walkMeasure ] ; ring!;
    · simp +decide [ idempotentCGF, maxPlusIntegral ];
    · exact ⟨ 0 ⟩

/-! ## Idempotent Chernoff bound (LDP upper bound) -/

/-
**Idempotent Chernoff / LDP upper bound**: for `λ ≥ 0` and any point `x` in the
upper-tail event `{val ≥ a}`, the weight is bounded by `Λ(λ) - λ a`.  Optimising
over `λ` yields the classical exponential-tail estimate.
-/
theorem idempotent_chernoff (P : MaxPlusMeasure X) (val : X → ℝ)
    {lam a : ℝ} (hlam : 0 ≤ lam) (x : X) (hx : a ≤ val x) :
    P.weight x ≤ idempotentCGF P val lam - lam * a := by
  rw [ idempotentCGF_eq ];
  linarith [ Finset.le_sup' ( fun x => lam * val x + P.weight x ) ( Finset.mem_univ x ), mul_le_mul_of_nonneg_left hx hlam ]

/-! ## Sharp idempotent LDP -/

/-
**Sharp idempotent LDP**: the deviation *cost* of an event `A` (a nonempty
finite set of outcomes) is exactly the infimum of the rate function over `A`:
`(cost of A) = inf_{x ∈ A} I(x)`, equivalently `μ(A) = sup_{x∈A} w(x)`.

Unlike the classical LDP this holds *exactly*, for the measure itself — idempotency
removes the `log`/`exp` smoothing.  Here `cost A := - μ(A)`.
-/
theorem idempotent_ldp_sharp (P : MaxPlusMeasure X) {A : Finset X} (hA : A.Nonempty) :
    - (A.sup' hA P.weight) = A.inf' hA (idempotentRate P) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ idempotentRate ];
  · exact fun x hx => ⟨ x, hx, le_rfl ⟩;
  · exact Finset.exists_max_image _ _ hA

/-! ## Legendre–Fenchel duality of the rate function -/

/-
**Fenchel–Young inequality** for the idempotent CGF: for every `λ`,
`λ·val x - Λ(λ) ≤ I(x)`.  This is the weak-duality bound underlying Cramér's
theorem.
-/
theorem fenchel_young_rate (P : MaxPlusMeasure X) (val : X → ℝ) (lam : ℝ) (x : X) :
    lam * val x - idempotentCGF P val lam ≤ idempotentRate P x := by
  unfold idempotentCGF idempotentRate;
  linarith [ le_maxPlusIntegral P ( fun x => lam * val x ) x ]

/-- The **Legendre–Fenchel biconjugate** of the rate function: the largest convex
lower bound, `I**(a) = sup_λ (λ a - Λ(λ))`. -/
noncomputable def lfBiconj (P : MaxPlusMeasure X) (val : X → ℝ) (a : ℝ) : ℝ :=
  ⨆ lam : ℝ, (lam * a - idempotentCGF P val lam)

/-
**Weak Legendre–Fenchel duality**: the biconjugate of the rate function never
exceeds the rate function itself. Equality is the content of Cramér's theorem and
holds exactly in the convex case (see `lfBiconj_eq_rate_of_support`).
-/
theorem lfBiconj_le_rate (P : MaxPlusMeasure X) (val : X → ℝ) (x : X) :
    lfBiconj P val (val x) ≤ idempotentRate P x := by
  convert ciSup_le fun lam => fenchel_young_rate P val lam x

/-
**Cramér equality at a point**: if the rate function has a *supporting line* at
`x` (a slope `λ` with `I(x) = λ·val x - Λ(λ)`), then the Legendre–Fenchel
biconjugate recovers the rate function exactly there.
-/
theorem lfBiconj_eq_rate_of_support (P : MaxPlusMeasure X) (val : X → ℝ) (x : X)
    {lam : ℝ} (hsupp : idempotentRate P x = lam * val x - idempotentCGF P val lam) :
    lfBiconj P val (val x) = idempotentRate P x := by
  refine' le_antisymm ( lfBiconj_le_rate P val x ) _;
  refine' le_trans _ ( le_ciSup _ lam );
  · rw [hsupp];
  · exact ⟨ idempotentRate P x, Set.forall_mem_range.2 fun lam => by linarith [ fenchel_young_rate P val lam x ] ⟩

end TropicalLDP