/-
# Is composition order a sufficient statistic?  Exact answers for the graded κ-law

## Research context (FACT round-95 #4, exp 606 KAPPA-SUFFICIENCY-SCALE)

Experiment 606 fits, at three bit-widths, a log smoothness rate against the
*composition order* `κ` (how many small primes divide the sampled value) and asks
three registered questions:

* **H1 / replication** — does the κ effect survive on fresh populations?
* **scale stability** — is the fitted slope `β_κ ≈ −0.35` the same at 72/96/128 bits?
* **sufficiency** — does the *identity* of the dividing primes (the full cell `S`)
  add anything beyond the *count* `κ = |S|`?

Reported: the slope is stable (−0.349 / −0.380 / −0.325, mutually overlapping CIs),
while sufficiency holds at 72 and 96 bits and **fails** at 128 bits
(identity increment `+0.0346` against a `0.02` bar).

This file formalises the underlying model — an additive per-prime log-rate
`Λ(S) = dial − ∑_{p ∈ S} w p` on the cell `S` — and proves exactly what each of the
three verdicts is measuring.  The arithmetic distribution of cells is supplied by
`Novelty.KappaCellPeriod` (exact, CRT-free, one-period counts), so no step of the
chain is heuristic.

## Main results

* `kappaSufficient_iff_constant_weights` — **the sufficiency dichotomy**: κ is a
  sufficient statistic for the log-rate *iff* the per-prime weight `w` is constant on
  the base.  In the additive model there is no intermediate regime: distinct weights
  are already detected at `κ = 1`.
* `logRate_eq_affine_of_const` / `weights_of_affine` — the graded law
  `Λ = dial − β·κ` holds **iff** `w ≡ β`, and then `β` and the dial are identified.
* `abs_identity_gap_le` — a sharp a priori bound on the identity increment: cells of
  equal order differ by at most `min(κ, |B| − κ) · (w_max − w_min)`;
  `identity_gap_singletons` attains the weight spread at `κ = 1`.
* `Emean_mul_sums`, `cov_logRate_kappa`, `variance_kappa`, `regression_slope` — for the
  product cell measure with marginals `q p` the **least-squares slope of the log-rate on
  κ** is exactly the `q(1−q)`-weighted mean of `−w`.  Hence
  `regression_slope_of_const`: a constant weight `β` forces the measured slope to be
  `−β` *at every scale, every base and every marginal profile* — the exact model content
  of `C3_SCALE_CONFIRMED` — while `slope_eq_weight_singleton` shows the slope conversely
  identifies the weight.
* `cellProb_eq_arith_density`, `arith_regression_slope` — the bridge: the product measure
  with `q p = 1/p` **is** the exact arithmetic distribution of cells over one period
  (`Novelty.KappaCellPeriod.cellFiber_density`), so the slope law is a statement about
  integers, not about a postulated population.
* `verdict_downward_closed`, `no_verdict_reversal`, `sufficiency_boundary_unique`,
  `verdict_iff_le_boundary`, `exp606_boundary_bracket`, `exp606_b72_forced` — the
  regime-boundary calculus: for a monotone identity increment the sufficiency verdict is
  downward closed in the scale (a TRUE/FALSE/TRUE pattern would falsify monotonicity),
  the crossing point is unique, the observed `0.0084 ≤ 0.02 < 0.0346` brackets it
  strictly inside `(96, 128]`, and the 72-bit TRUE verdict is *predicted*, not
  independent evidence.

-- !-- Lab Notes -- !--
-- HYPOTHESIS (cycle 1).  "κ sufficient" and "κ not sufficient" should be endpoints of a
--   graded scale, with the identity increment growing smoothly.
-- EXPERIMENT.  In the additive model the increment is *already* nonzero at κ = 1 as soon
--   as two weights differ (`identity_gap_singletons`), so gradedness cannot come from the
--   additive model itself: it must come from the *scale dependence of the weights*.  This
--   forced the two-layer formulation (weights `w`, marginals `q`, scale-indexed spread).
-- EXPERIMENT (numeric, exact rationals, B = {2,3,5}, q p = 1/p, w ≡ 0.35): total mass `1`,
--   `E κ = 31/30`, `Var κ = 569/900 = ∑ q(1−q)`, and the least-squares slope is `−7/20`
--   exactly — matching `Emean_kappa`, `variance_kappa` and `regression_slope_of_const`.
-- OUTCOME.  Sufficiency dichotomy, slope identification, the OLS slope formula and the
--   arithmetic bridge all proved; the empirical 3-point bracket re-derived by `norm_num`
--   from the paper's own numbers.
-- FAILURE ANALYSIS.  A first formulation measured the increment as an unconditional `sup`
--   over cells and produced the vacuous bound `|B|·spread`; conditioning on equal order and
--   using `|S \ T| = |T \ S| ≤ min(κ, |B| − κ)` gives the sharp constant.
-/
import Mathlib
import Novelty.KappaCellPeriod

open Finset

namespace Catalog.Novelty.KappaSufficiencyScale

open Catalog.Novelty.KappaCellPeriod

variable {B S T : Finset ℕ} {w q : ℕ → ℝ} {D β m Mx : ℝ} {p r : ℕ}

/-! ## 1. The additive cell model -/

/-- The modelled log smoothness rate of a cell `S`: a dial minus the per-prime
composition penalties. -/
def logRate (D : ℝ) (w : ℕ → ℝ) (S : Finset ℕ) : ℝ := D - ∑ p ∈ S, w p

/-- `κ` is a **sufficient statistic** for the log-rate on the base `B` when cells of equal
composition order always carry the same rate. -/
def KappaSufficient (B : Finset ℕ) (w : ℕ → ℝ) : Prop :=
  ∀ S ⊆ B, ∀ T ⊆ B, S.card = T.card → ∑ p ∈ S, w p = ∑ p ∈ T, w p

lemma logRate_eq_iff_sum_eq (D : ℝ) (w : ℕ → ℝ) (S T : Finset ℕ) :
    logRate D w S = logRate D w T ↔ ∑ p ∈ S, w p = ∑ p ∈ T, w p := by
  unfold logRate; constructor <;> intro h <;> linarith

/-- **The sufficiency dichotomy.**  Composition order summarises the whole cell exactly
when every small prime carries the same weight. -/
theorem kappaSufficient_iff_constant_weights :
    KappaSufficient B w ↔ ∀ p ∈ B, ∀ r ∈ B, w p = w r := by
  constructor
  · intro h p hp r hr
    have := h {p} (by simpa using hp) {r} (by simpa using hr) (by simp)
    simpa using this
  · intro h S hS T hT hcard
    rcases B.eq_empty_or_nonempty with hB | ⟨p₀, hp₀⟩
    · subst hB
      rw [Finset.subset_empty.1 hS, Finset.subset_empty.1 hT]
    · have key : ∀ U : Finset ℕ, U ⊆ B → ∑ p ∈ U, w p = U.card * w p₀ := by
        intro U hU
        rw [Finset.sum_congr rfl (fun p hp => h p (hU hp) p₀ hp₀)]
        simp [mul_comm]
      rw [key S hS, key T hT, hcard]

/-! ## 2. The graded law `Λ = dial − β·κ` -/

/-- Constant weights produce exactly the graded law of the paper. -/
theorem logRate_eq_affine_of_const (hconst : ∀ p ∈ B, w p = β) (hS : S ⊆ B) :
    logRate D w S = D - β * S.card := by
  unfold logRate
  rw [Finset.sum_congr rfl (fun p hp => hconst p (hS hp))]
  simp [mul_comm]

/-- Conversely the graded law identifies both the dial and every weight. -/
theorem weights_of_affine {C : ℝ} (h : ∀ S ⊆ B, logRate D w S = C - β * S.card) :
    C = D ∧ ∀ p ∈ B, w p = β := by
  have h0 := h ∅ (Finset.empty_subset _)
  simp only [logRate, Finset.sum_empty, Finset.card_empty, Nat.cast_zero, mul_zero,
    sub_zero] at h0
  refine ⟨h0.symm, fun p hp => ?_⟩
  have h1 := h {p} (by simpa using hp)
  simp only [logRate, Finset.sum_singleton, Finset.card_singleton, Nat.cast_one,
    mul_one] at h1
  linarith

/-- A constant-weight model is κ-sufficient. -/
theorem kappaSufficient_of_const (hconst : ∀ p ∈ B, w p = β) : KappaSufficient B w :=
  kappaSufficient_iff_constant_weights.2 fun p hp r hr => by
    rw [hconst p hp, hconst r hr]

/-! ## 3. The identity increment: how much can cell identity add beyond κ? -/

/-- **Bound on the identity increment.**  Two cells of the same composition order `κ` can
differ in log-rate by at most `min(κ, |B| − κ)` weight spreads. -/
theorem abs_identity_gap_le (hlo : ∀ p ∈ B, m ≤ w p) (hhi : ∀ p ∈ B, w p ≤ Mx)
    (hS : S ⊆ B) (hT : T ⊆ B) (hcard : S.card = T.card) :
    |logRate D w S - logRate D w T| ≤ (min S.card (B.card - S.card) : ℕ) * (Mx - m) := by
  classical
  rcases Finset.eq_empty_or_nonempty B with hB | ⟨p₀, hp₀⟩
  · -- degenerate base: both cells are empty and both sides vanish
    have hSe : S = ∅ := by rw [hB] at hS; exact Finset.subset_empty.1 hS
    have hTe : T = ∅ := by rw [hB] at hT; exact Finset.subset_empty.1 hT
    rw [hSe, hTe, hB]
    simp [logRate]
  have hspread : 0 ≤ Mx - m := by linarith [hlo p₀ hp₀, hhi p₀ hp₀]
  have hsplitS : ∑ p ∈ S ∩ T, w p + ∑ p ∈ S \ T, w p = ∑ p ∈ S, w p :=
    Finset.sum_inter_add_sum_diff S T w
  have hsplitT : ∑ p ∈ T ∩ S, w p + ∑ p ∈ T \ S, w p = ∑ p ∈ T, w p :=
    Finset.sum_inter_add_sum_diff T S w
  have hcomm : S ∩ T = T ∩ S := Finset.inter_comm _ _
  have hdiff : logRate D w S - logRate D w T = ∑ p ∈ T \ S, w p - ∑ p ∈ S \ T, w p := by
    unfold logRate
    rw [← hsplitS, ← hsplitT, hcomm]; ring
  have hcS : (S \ T).card + (S ∩ T).card = S.card := Finset.card_sdiff_add_card_inter S T
  have hcT : (T \ S).card + (T ∩ S).card = T.card := Finset.card_sdiff_add_card_inter T S
  have hjeq : (S \ T).card = (T \ S).card := by
    rw [hcomm] at hcS; omega
  have hj1 : (S \ T).card ≤ S.card := Finset.card_le_card Finset.sdiff_subset
  have hj2 : (S \ T).card ≤ B.card - S.card := by
    have h1 : (T \ S).card ≤ (B \ S).card :=
      Finset.card_le_card (Finset.sdiff_subset_sdiff hT (le_refl S))
    have h2 : (B \ S).card + S.card = B.card := Finset.card_sdiff_add_card_eq_card hS
    omega
  have hjmin : (S \ T).card ≤ min S.card (B.card - S.card) := le_min hj1 hj2
  have hcards : ((T \ S).card : ℝ) = ((S \ T).card : ℝ) := by rw [hjeq]
  have hub : ∑ p ∈ T \ S, w p ≤ ((S \ T).card : ℝ) * Mx := by
    have h : ∑ p ∈ T \ S, w p ≤ ∑ _p ∈ T \ S, Mx :=
      Finset.sum_le_sum (fun p hp => hhi p (hT (Finset.mem_sdiff.1 hp).1))
    rw [Finset.sum_const, nsmul_eq_mul, hcards] at h
    exact h
  have hlb : ((S \ T).card : ℝ) * m ≤ ∑ p ∈ T \ S, w p := by
    have h : ∑ _p ∈ T \ S, m ≤ ∑ p ∈ T \ S, w p :=
      Finset.sum_le_sum (fun p hp => hlo p (hT (Finset.mem_sdiff.1 hp).1))
    rw [Finset.sum_const, nsmul_eq_mul, hcards] at h
    exact h
  have hub' : ∑ p ∈ S \ T, w p ≤ ((S \ T).card : ℝ) * Mx := by
    have h : ∑ p ∈ S \ T, w p ≤ ∑ _p ∈ S \ T, Mx :=
      Finset.sum_le_sum (fun p hp => hhi p (hS (Finset.mem_sdiff.1 hp).1))
    rw [Finset.sum_const, nsmul_eq_mul] at h
    exact h
  have hlb' : ((S \ T).card : ℝ) * m ≤ ∑ p ∈ S \ T, w p := by
    have h : ∑ _p ∈ S \ T, m ≤ ∑ p ∈ S \ T, w p :=
      Finset.sum_le_sum (fun p hp => hlo p (hS (Finset.mem_sdiff.1 hp).1))
    rw [Finset.sum_const, nsmul_eq_mul] at h
    exact h
  have hjr : ((S \ T).card : ℝ) ≤ ((min S.card (B.card - S.card) : ℕ) : ℝ) := by
    exact_mod_cast hjmin
  rw [hdiff, abs_le]
  constructor
  · nlinarith
  · nlinarith

/-- Level `κ = 1` attains the weight spread: the identity increment between two singleton
cells is exactly the weight difference.  Hence κ-sufficiency fails as soon as two weights
differ, and the bound of `abs_identity_gap_le` is sharp at `κ = 1`. -/
theorem identity_gap_singletons (D : ℝ) (w : ℕ → ℝ) (p r : ℕ) :
    logRate D w {r} - logRate D w {p} = w p - w r := by
  simp only [logRate, Finset.sum_singleton]; ring

/-! ## 4. The product cell measure and the least-squares slope -/

/-- The product (independent-divisibility) measure on cells with marginals `q`. -/
def cellProb (B : Finset ℕ) (q : ℕ → ℝ) (S : Finset ℕ) : ℝ :=
  (∏ p ∈ S, q p) * ∏ p ∈ B \ S, (1 - q p)

/-- Expectation of a cell statistic under the product cell measure. -/
def Emean (B : Finset ℕ) (q : ℕ → ℝ) (f : Finset ℕ → ℝ) : ℝ :=
  ∑ S ∈ B.powerset, cellProb B q S * f S

/-- Indicator that the prime `p` lies in the cell. -/
def ind (p : ℕ) (S : Finset ℕ) : ℝ := if p ∈ S then 1 else 0

/-- **Marginals of the product cell measure.**  The mass of the cells containing a fixed
set `T` of primes is `∏_{p ∈ T} q p`. -/
theorem sum_cellProb_superset (hT : T ⊆ B) :
    ∑ S ∈ B.powerset.filter (fun S => T ⊆ S), cellProb B q S = ∏ p ∈ T, q p := by
  classical
  have hbij : ∑ S ∈ B.powerset.filter (fun S => T ⊆ S), cellProb B q S
      = ∑ R ∈ (B \ T).powerset, cellProb B q (T ∪ R) := by
    refine (Finset.sum_nbij' (i := fun R => T ∪ R) (j := fun S => S \ T) ?_ ?_ ?_ ?_ ?_).symm
    · intro R hR
      rw [Finset.mem_powerset] at hR
      simp only [Finset.mem_filter, Finset.mem_powerset]
      exact ⟨Finset.union_subset hT (hR.trans Finset.sdiff_subset), Finset.subset_union_left⟩
    · intro Sx hSx
      rw [Finset.mem_filter, Finset.mem_powerset] at hSx
      rw [Finset.mem_powerset]
      exact Finset.sdiff_subset_sdiff hSx.1 (le_refl T)
    · intro R hR
      rw [Finset.mem_powerset] at hR
      have hdisj : Disjoint T R :=
        Finset.disjoint_left.2 (fun a haT haR => (Finset.mem_sdiff.1 (hR haR)).2 haT)
      show (T ∪ R) \ T = R
      exact Finset.union_sdiff_cancel_left hdisj
    · intro Sx hSx
      rw [Finset.mem_filter] at hSx
      show T ∪ (Sx \ T) = Sx
      rw [Finset.union_comm, Finset.sdiff_union_of_subset hSx.2]
    · intro R _; rfl
  rw [hbij]
  have hterm : ∀ R ∈ (B \ T).powerset,
      cellProb B q (T ∪ R)
        = (∏ p ∈ T, q p) * ((∏ p ∈ R, q p) * ∏ p ∈ (B \ T) \ R, (1 - q p)) := by
    intro R hR
    rw [Finset.mem_powerset] at hR
    have hdisj : Disjoint T R :=
      Finset.disjoint_left.2 (fun a haT haR => (Finset.mem_sdiff.1 (hR haR)).2 haT)
    have h1 : ∏ p ∈ T ∪ R, q p = (∏ p ∈ T, q p) * ∏ p ∈ R, q p := Finset.prod_union hdisj
    have h2 : B \ (T ∪ R) = (B \ T) \ R := by
      ext a; simp only [Finset.mem_sdiff, Finset.mem_union, not_or]; tauto
    rw [cellProb, h1, h2]; ring
  rw [Finset.sum_congr rfl hterm, ← Finset.mul_sum]
  have hone : ∑ R ∈ (B \ T).powerset, (∏ p ∈ R, q p) * ∏ p ∈ (B \ T) \ R, (1 - q p) = 1 := by
    rw [← Finset.prod_add]; simp
  rw [hone, mul_one]

/-- The product cell measure is a probability distribution. -/
theorem sum_cellProb (B : Finset ℕ) (q : ℕ → ℝ) :
    ∑ S ∈ B.powerset, cellProb B q S = 1 := by
  classical
  simpa using sum_cellProb_superset (B := B) (T := (∅ : Finset ℕ)) (q := q)
    (Finset.empty_subset _)

lemma Emean_congr {f g : Finset ℕ → ℝ} (h : ∀ S ∈ B.powerset, f S = g S) :
    Emean B q f = Emean B q g :=
  Finset.sum_congr rfl (fun S hS => by rw [h S hS])

lemma Emean_const (B : Finset ℕ) (q : ℕ → ℝ) (c : ℝ) : Emean B q (fun _ => c) = c := by
  unfold Emean
  rw [← Finset.sum_mul, sum_cellProb, one_mul]

lemma Emean_finsetSum {ι : Type*} (I : Finset ι) (F : ι → Finset ℕ → ℝ) :
    Emean B q (fun S => ∑ i ∈ I, F i S) = ∑ i ∈ I, Emean B q (F i) := by
  unfold Emean
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]

lemma Emean_const_mul (c : ℝ) (f : Finset ℕ → ℝ) :
    Emean B q (fun S => c * f S) = c * Emean B q f := by
  unfold Emean
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl (fun S _ => by ring)

lemma Emean_sub (f g : Finset ℕ → ℝ) :
    Emean B q (fun S => f S - g S) = Emean B q f - Emean B q g := by
  unfold Emean
  rw [← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl (fun S _ => by ring)

/-- Pair marginals: `E[1_{p ∈ S} · 1_{r ∈ S}]`. -/
theorem Emean_indicator_pair (hp : p ∈ B) (hr : r ∈ B) :
    Emean B q (fun S => ind p S * ind r S) = if p = r then q p else q p * q r := by
  classical
  have hsub : ({p, r} : Finset ℕ) ⊆ B := by
    intro a ha
    rcases Finset.mem_insert.1 ha with rfl | ha
    · exact hp
    · rw [Finset.mem_singleton] at ha; subst ha; exact hr
  have hkey := sum_cellProb_superset (B := B) (T := ({p, r} : Finset ℕ)) (q := q) hsub
  have hfilter : B.powerset.filter (fun S => ({p, r} : Finset ℕ) ⊆ S)
      = B.powerset.filter (fun S => p ∈ S ∧ r ∈ S) := by
    refine Finset.filter_congr (fun S _ => ?_)
    constructor
    · intro h; exact ⟨h (by simp), h (by simp)⟩
    · rintro ⟨h1, h2⟩ a ha
      rcases Finset.mem_insert.1 ha with rfl | ha
      · exact h1
      · rw [Finset.mem_singleton] at ha; subst ha; exact h2
  rw [hfilter] at hkey
  have hEm : Emean B q (fun S => ind p S * ind r S)
      = ∑ S ∈ B.powerset.filter (fun S => p ∈ S ∧ r ∈ S), cellProb B q S := by
    rw [Emean, Finset.sum_filter]
    refine Finset.sum_congr rfl (fun S _ => ?_)
    by_cases h1 : p ∈ S <;> by_cases h2 : r ∈ S <;> simp [ind, h1, h2]
  rw [hEm, hkey]
  by_cases h : p = r
  · subst h; simp
  · rw [Finset.prod_pair h]; simp [h]

lemma Emean_ind (hp : p ∈ B) : Emean B q (ind p) = q p := by
  have h := Emean_indicator_pair (B := B) (q := q) hp hp
  have hfun : (fun S => ind p S * ind p S) = ind p := by
    funext S; by_cases hs : p ∈ S <;> simp [ind, hs]
  rw [hfun] at h
  simpa using h

lemma sum_eq_sum_ind (a : ℕ → ℝ) (hS : S ⊆ B) : ∑ p ∈ S, a p = ∑ p ∈ B, a p * ind p S := by
  classical
  simp only [ind, mul_ite, mul_one, mul_zero]
  rw [Finset.sum_ite_mem, Finset.inter_eq_right.2 hS]

/-- Expectation of an additive cell statistic. -/
theorem Emean_sum (a : ℕ → ℝ) :
    Emean B q (fun S => ∑ p ∈ S, a p) = ∑ p ∈ B, a p * q p := by
  classical
  rw [Emean_congr (g := fun S => ∑ p ∈ B, a p * ind p S)
      (fun S hS => sum_eq_sum_ind a (Finset.mem_powerset.1 hS))]
  rw [Emean_finsetSum]
  exact Finset.sum_congr rfl (fun p hp => by
    rw [show (fun S => a p * ind p S) = (fun S => a p * ind p S) from rfl,
      Emean_const_mul, Emean_ind hp])

/-- **The second-moment identity for the product cell measure.**  Products of additive cell
statistics decouple into the product of the means plus a diagonal Bernoulli variance term. -/
theorem Emean_mul_sums (a b : ℕ → ℝ) :
    Emean B q (fun S => (∑ p ∈ S, a p) * (∑ r ∈ S, b r))
      = (∑ p ∈ B, a p * q p) * (∑ r ∈ B, b r * q r)
        + ∑ p ∈ B, a p * b p * (q p * (1 - q p)) := by
  classical
  have step1 : Emean B q (fun S => (∑ p ∈ S, a p) * (∑ r ∈ S, b r))
      = ∑ p ∈ B, ∑ r ∈ B, a p * b r * (if p = r then q p else q p * q r) := by
    rw [Emean_congr (g := fun S => ∑ p ∈ B, ∑ r ∈ B, (a p * b r) * (ind p S * ind r S))
        (fun S hS => ?_)]
    · rw [Emean_finsetSum]
      refine Finset.sum_congr rfl (fun p hp => ?_)
      rw [Emean_finsetSum]
      refine Finset.sum_congr rfl (fun r hr => ?_)
      rw [Emean_const_mul, Emean_indicator_pair hp hr]
    · have hSB := Finset.mem_powerset.1 hS
      rw [sum_eq_sum_ind a hSB, sum_eq_sum_ind b hSB, Finset.sum_mul_sum]
      exact Finset.sum_congr rfl (fun p _ => Finset.sum_congr rfl (fun r _ => by ring))
  rw [step1]
  have hterm : ∀ p ∈ B, ∑ r ∈ B, a p * b r * (if p = r then q p else q p * q r)
      = (a p * q p) * (∑ r ∈ B, b r * q r) + a p * b p * (q p * (1 - q p)) := by
    intro p hp
    have hpt : ∀ r ∈ B, a p * b r * (if p = r then q p else q p * q r)
        = (a p * q p) * (b r * q r)
          + (if p = r then a p * b p * (q p * (1 - q p)) else 0) := by
      intro r _
      by_cases h : p = r
      · subst h
        have e1 : (if p = p then q p else q p * q p) = q p := if_pos rfl
        have e2 : (if p = p then a p * b p * (q p * (1 - q p)) else 0)
            = a p * b p * (q p * (1 - q p)) := if_pos rfl
        rw [e1, e2]; ring
      · rw [if_neg h, if_neg h]; ring
    rw [Finset.sum_congr rfl hpt, Finset.sum_add_distrib, ← Finset.mul_sum,
      Finset.sum_ite_eq B p (fun _ => a p * b p * (q p * (1 - q p))), if_pos hp]
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.sum_mul]

/-- Mean composition order under the product cell measure. -/
theorem Emean_kappa (B : Finset ℕ) (q : ℕ → ℝ) :
    Emean B q (fun S => (S.card : ℝ)) = ∑ p ∈ B, q p := by
  have hfun : ∀ S ∈ B.powerset, ((S.card : ℝ)) = ∑ _p ∈ S, (1 : ℝ) := by
    intro S _; simp
  rw [Emean_congr hfun, Emean_sum]
  exact Finset.sum_congr rfl (fun p _ => one_mul (q p))

/-- Mean log-rate under the product cell measure. -/
theorem Emean_logRate (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ) :
    Emean B q (logRate D w) = D - ∑ p ∈ B, w p * q p := by
  have hfun : ∀ S ∈ B.powerset, logRate D w S = (fun _ : Finset ℕ => D) S - (∑ p ∈ S, w p) := by
    intro S _; rfl
  rw [Emean_congr hfun, Emean_sub, Emean_const, Emean_sum]

/-- Covariance of two cell statistics under the product cell measure. -/
def cov (B : Finset ℕ) (q : ℕ → ℝ) (f g : Finset ℕ → ℝ) : ℝ :=
  Emean B q (fun S => f S * g S) - Emean B q f * Emean B q g

/-- **Variance of the composition order**: the sum of the Bernoulli variances. -/
theorem variance_kappa (B : Finset ℕ) (q : ℕ → ℝ) :
    cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ)) = ∑ p ∈ B, q p * (1 - q p) := by
  unfold cov
  have hfun : ∀ S ∈ B.powerset, ((S.card : ℝ)) * ((S.card : ℝ))
      = (∑ _p ∈ S, (1 : ℝ)) * (∑ _r ∈ S, (1 : ℝ)) := by
    intro S _; simp
  rw [Emean_congr hfun, Emean_mul_sums, Emean_kappa]
  have h1 : ∑ p ∈ B, (1 : ℝ) * q p = ∑ p ∈ B, q p :=
    Finset.sum_congr rfl (fun p _ => one_mul (q p))
  rw [h1]
  have h2 : ∑ p ∈ B, (1 : ℝ) * 1 * (q p * (1 - q p)) = ∑ p ∈ B, q p * (1 - q p) :=
    Finset.sum_congr rfl (fun p _ => by ring)
  rw [h2]; ring

/-- **Covariance of the log-rate with the composition order.** -/
theorem cov_logRate_kappa (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ) :
    cov B q (logRate D w) (fun S => (S.card : ℝ)) = -∑ p ∈ B, w p * (q p * (1 - q p)) := by
  unfold cov
  have hfun : ∀ S ∈ B.powerset, logRate D w S * ((S.card : ℝ))
      = D * (∑ _r ∈ S, (1 : ℝ)) - (∑ p ∈ S, w p) * (∑ _r ∈ S, (1 : ℝ)) := by
    intro S _
    simp only [logRate]
    simp
    ring
  rw [Emean_congr hfun,
    Emean_sub (f := fun S => D * (∑ _r ∈ S, (1 : ℝ)))
      (g := fun S => (∑ p ∈ S, w p) * (∑ _r ∈ S, (1 : ℝ))),
    Emean_const_mul, Emean_sum, Emean_mul_sums, Emean_logRate, Emean_kappa]
  have h1 : ∑ p ∈ B, (1 : ℝ) * q p = ∑ p ∈ B, q p :=
    Finset.sum_congr rfl (fun p _ => one_mul (q p))
  have h2 : ∑ p ∈ B, w p * 1 * (q p * (1 - q p)) = ∑ p ∈ B, w p * (q p * (1 - q p)) :=
    Finset.sum_congr rfl (fun p _ => by ring)
  rw [h1, h2]; ring

/-- The least-squares slope of the log-rate regressed on the composition order. -/
noncomputable def olsSlope (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ) : ℝ :=
  cov B q (logRate D w) (fun S => (S.card : ℝ))
    / cov B q (fun S => (S.card : ℝ)) (fun S => (S.card : ℝ))

/-- **The slope law.**  The measured slope is exactly the `q(1−q)`-weighted mean of `−w`. -/
theorem regression_slope (B : Finset ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ) :
    olsSlope B q D w
      = (-∑ p ∈ B, w p * (q p * (1 - q p))) / ∑ p ∈ B, q p * (1 - q p) := by
  unfold olsSlope
  rw [cov_logRate_kappa, variance_kappa]

/-- **Scale stability.**  If every small prime carries the same weight `β`, the measured
slope is `−β` — for *every* base, every marginal profile and hence every scale.  This is the
exact model content of the `C3_SCALE_CONFIRMED` verdict. -/
theorem regression_slope_of_const (hconst : ∀ p ∈ B, w p = β)
    (hden : ∑ p ∈ B, q p * (1 - q p) ≠ 0) : olsSlope B q D w = -β := by
  rw [regression_slope]
  have hnum : ∑ p ∈ B, w p * (q p * (1 - q p)) = β * ∑ p ∈ B, q p * (1 - q p) := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl (fun p hp => by rw [hconst p hp])
  rw [hnum]
  field_simp

/-- **The slope identifies the weight.**  Restricting the base to a single prime `p` with a
nondegenerate marginal, the measured slope is exactly `−w p`.  Together with
`regression_slope_of_const` this shows the slope is a faithful readout of the per-prime
composition penalty. -/
theorem slope_eq_weight_singleton (p : ℕ) (q : ℕ → ℝ) (D : ℝ) (w : ℕ → ℝ)
    (h0 : q p ≠ 0) (h1 : q p ≠ 1) : olsSlope {p} q D w = -w p := by
  rw [regression_slope]
  have hd : q p * (1 - q p) ≠ 0 := mul_ne_zero h0 (sub_ne_zero.2 (Ne.symm h1))
  simp only [Finset.sum_singleton]
  rw [neg_div, mul_div_assoc, div_self hd, mul_one]

/-! ## 5. The arithmetic bridge: cells of integers over one period -/

/-- **The model measure is the arithmetic one.**  With marginals `q p = 1/p` the product cell
measure is *exactly* the density of the cell `S` among the residues of one period
`∏_{p ∈ B} p`; the small-prime divisibility events are exactly independent. -/
theorem cellProb_eq_arith_density (hB : ∀ p ∈ B, Nat.Prime p) (hS : S ⊆ B) :
    cellProb B (fun p => 1 / (p : ℝ)) S
      = ((cellFiber B S).card : ℝ) / (period B : ℝ) :=
  (cellFiber_density hB hS).symm

/-- The Bernoulli variance sum of the arithmetic cell measure is positive on a nonempty
base of primes. -/
theorem arith_variance_pos (hB : ∀ p ∈ B, Nat.Prime p) (hne : B.Nonempty) :
    0 < ∑ p ∈ B, (1 / (p : ℝ)) * (1 - 1 / (p : ℝ)) := by
  refine Finset.sum_pos (fun p hp => ?_) hne
  have h2 : (2 : ℝ) ≤ (p : ℝ) := by exact_mod_cast (hB p hp).two_le
  have hp0 : (0 : ℝ) < p := by linarith
  have hhalf : 1 / (p : ℝ) ≤ 1 / 2 :=
    one_div_le_one_div_of_le (by norm_num) h2
  have h1 : 0 < 1 / (p : ℝ) := by positivity
  nlinarith

/-- **The slope law over the integers.**  For the exact arithmetic cell measure of a nonempty
prime base, a constant composition penalty `β` yields measured slope `−β`, independently of
the base — the arithmetic form of scale stability. -/
theorem arith_regression_slope (hB : ∀ p ∈ B, Nat.Prime p) (hne : B.Nonempty)
    (hconst : ∀ p ∈ B, w p = β) :
    olsSlope B (fun p => 1 / (p : ℝ)) D w = -β :=
  regression_slope_of_const hconst (ne_of_gt (arith_variance_pos hB hne))

/-! ## 6. The regime boundary of sufficiency -/

/-- The sufficiency verdict at a scale: the identity increment does not exceed the bar. -/
def SufficiencyVerdict (bar : ℝ) (increment : ℝ) : Prop := increment ≤ bar

/-- **The verdict is downward closed in the scale** when the identity increment is monotone:
sufficiency at a larger scale forces sufficiency at every smaller one. -/
theorem verdict_downward_closed {spr : ℝ → ℝ} (hmono : Monotone spr) {u₁ u₂ bar : ℝ}
    (h : u₁ ≤ u₂) (h2 : SufficiencyVerdict bar (spr u₂)) : SufficiencyVerdict bar (spr u₁) :=
  le_trans (hmono h) h2

/-- **Falsifiability.**  A TRUE / FALSE / TRUE verdict pattern across increasing scales is
impossible for a monotone increment: it would refute monotonicity outright. -/
theorem no_verdict_reversal {spr : ℝ → ℝ} (hmono : Monotone spr) {u₂ u₃ bar : ℝ}
    (h23 : u₂ ≤ u₃) (h2 : ¬ SufficiencyVerdict bar (spr u₂)) :
    ¬ SufficiencyVerdict bar (spr u₃) :=
  fun h3 => h2 (verdict_downward_closed hmono h23 h3)

/-- **The sufficiency boundary exists and is unique.**  A continuous, strictly increasing
identity increment that is below the bar at `a` and above it at `b` crosses the bar at exactly
one scale. -/
theorem sufficiency_boundary_unique {spr : ℝ → ℝ} (hcont : Continuous spr)
    (hstrict : StrictMono spr) {a b bar : ℝ} (hab : a ≤ b) (ha : spr a ≤ bar)
    (hb : bar < spr b) : ∃! u, u ∈ Set.Icc a b ∧ spr u = bar := by
  have hmem : bar ∈ Set.Icc (spr a) (spr b) := ⟨ha, le_of_lt hb⟩
  obtain ⟨u, hu, hval⟩ := intermediate_value_Icc hab hcont.continuousOn hmem
  refine ⟨u, ⟨hu, hval⟩, ?_⟩
  rintro v ⟨-, hv⟩
  exact hstrict.injective (hv.trans hval.symm)

/-- **The verdict is exactly "below the boundary".** -/
theorem verdict_iff_le_boundary {spr : ℝ → ℝ} (hstrict : StrictMono spr) {u₀ bar : ℝ}
    (h₀ : spr u₀ = bar) (u : ℝ) : SufficiencyVerdict bar (spr u) ↔ u ≤ u₀ := by
  unfold SufficiencyVerdict
  constructor
  · intro h
    by_contra hlt
    push_neg at hlt
    exact absurd (h₀ ▸ hstrict hlt) (not_lt.2 h)
  · intro h; rw [← h₀]; exact hstrict.monotone h

/-- **The exp-606 bracket.**  With the measured increments `0.0084` at 96 bits and `0.0346` at
128 bits and the pre-registered bar `0.02`, a continuous strictly increasing increment has a
unique sufficiency boundary, and it lies strictly inside `(96, 128]`. -/
theorem exp606_boundary_bracket {spr : ℝ → ℝ} (hcont : Continuous spr) (hstrict : StrictMono spr)
    (h96 : spr 96 = 0.0084) (h128 : spr 128 = 0.0346) :
    ∃! u, u ∈ Set.Ioc (96 : ℝ) 128 ∧ spr u = 0.02 := by
  have hab : (96 : ℝ) ≤ 128 := by norm_num
  have ha : spr 96 ≤ 0.02 := by rw [h96]; norm_num
  have hb : (0.02 : ℝ) < spr 128 := by rw [h128]; norm_num
  obtain ⟨u, ⟨humem, huval⟩, huniq⟩ := sufficiency_boundary_unique hcont hstrict hab ha hb
  have hgt : (96 : ℝ) < u := by
    by_contra hle
    push_neg at hle
    have := hstrict.monotone hle
    rw [huval, h96] at this
    norm_num at this
  refine ⟨u, ⟨⟨hgt, humem.2⟩, huval⟩, ?_⟩
  rintro v ⟨hv, hval⟩
  exact hstrict.injective (hval.trans huval.symm)

/-- **The 72-bit verdict was predicted, not independent evidence.**  For a monotone increment,
sufficiency at 96 bits already forces sufficiency at 72 bits; the observed `0.0071 ≤ 0.02` is a
consistency check on monotonicity rather than a third data point. -/
theorem exp606_b72_forced {spr : ℝ → ℝ} (hmono : Monotone spr) (h96 : spr 96 = 0.0084) :
    SufficiencyVerdict 0.02 (spr 72) := by
  refine verdict_downward_closed hmono (by norm_num : (72 : ℝ) ≤ 96) ?_
  unfold SufficiencyVerdict
  rw [h96]; norm_num

end Catalog.Novelty.KappaSufficiencyScale