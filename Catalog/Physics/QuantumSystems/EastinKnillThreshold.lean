import Mathlib

/-!
# The Eastin–Knill Theorem and the Fault-Tolerance Threshold

This file formalizes two pillars of fault-tolerant quantum computation as clean,
self-contained mathematical statements.

## Part I — The fault-tolerance threshold theorem (sharp trichotomy)

Under code concatenation a distance-`3` fault-tolerant gadget transforms a physical
error rate `p` into a level-`1` error rate `c·p²` (quadratic error suppression),
where `c` is the number of malignant fault pairs.  Iterating `L` levels gives the
recursion `p_{n+1} = c·p_n²`.  Writing the *rescaled* rate `q_n = c·p_n`, the
recursion linearizes to `q_{n+1} = q_n²`, hence `q_n = q_0^{2^n}` — a doubly
exponential law.  This yields the **threshold** `p_th = 1/c`:

* below threshold (`c·p < 1`): the logical error rate collapses to `0`;
* at threshold (`c·p = 1`): it is frozen at the fixed point `1/c`;
* above threshold (`c·p > 1`): it blows up to `+∞`.

The constant `c ≈ 100` for the surface code with depolarizing noise gives the
celebrated `p_th ≈ 1%` figure (`threshold_one_percent`).

## Part II — The Eastin–Knill theorem (abstract group-theoretic core)

The transversal logical gates of any quantum code form a *finite* group `T`.
Universality requires generating a dense (in particular infinite) subgroup of the
logical unitary group.  A finite group cannot exhaust an infinite ambient group,
so transversal gates are never universal: `eastin_knill_not_universal`.

## Main results

* `errorRate_rescaled` — `c · p_n = (c·p)^{2^n}` (the doubly-exponential law)
* `errorRate_closed_form` — `p_n = (1/c)·(c·p)^{2^n}`
* `errorRate_subthreshold_tendsto_zero` — below threshold the error rate → 0
* `errorRate_at_threshold_const` — at threshold the error rate is constant `1/c`
* `errorRate_superthreshold_tendsto_top` — above threshold the error rate → ∞
* `threshold_one_percent` — `c = 100 ⇒ p_th = 0.01`
* `eastin_knill_not_universal` — finite transversal gate group ≠ whole unitary group
-/

open Filter Topology

namespace Physics.EastinKnillThreshold

/-! ## Part I: The fault-tolerance threshold -/

/-- Level-`n` logical error rate under code concatenation, defined by the
quadratic error-suppression recursion `p_{n+1} = c · p_n²` with physical rate
`p_0 = p`.  Here `c` is the number of malignant fault locations per gadget. -/
noncomputable def errorRate (c p : ℝ) : ℕ → ℝ
  | 0 => p
  | n + 1 => c * (errorRate c p n) ^ 2

/-- The fault-tolerance threshold `p_th = 1/c`. -/
noncomputable def threshold (c : ℝ) : ℝ := 1 / c

@[simp] lemma errorRate_zero (c p : ℝ) : errorRate c p 0 = p := rfl

@[simp] lemma errorRate_succ (c p : ℝ) (n : ℕ) :
    errorRate c p (n + 1) = c * (errorRate c p n) ^ 2 := rfl

/-
!-- The rescaled rate q_n = c·p_n satisfies q_{n+1} = q_n², so q_n = q_0^{2^n};
prove by induction using pow_mul / sq. -- !--

**Doubly-exponential law.** The rescaled error rate `q_n = c·p_n` obeys
`q_n = q_0^{2^n}`: `c · p_n = (c · p)^{2^n}`.
-/
theorem errorRate_rescaled (c p : ℝ) (n : ℕ) :
    c * errorRate c p n = (c * p) ^ (2 ^ n) := by
  induction n <;> simp_all +decide [ pow_succ, pow_mul ];
  grobner

/-
!-- Divide the rescaled law by c (c ≠ 0). -- !--

**Closed form.** `p_n = (1/c) · (c·p)^{2^n}` for `c ≠ 0`.
-/
theorem errorRate_closed_form (c p : ℝ) (hc : c ≠ 0) (n : ℕ) :
    errorRate c p n = (1 / c) * (c * p) ^ (2 ^ n) := by
  rw [ ← errorRate_rescaled ] ; ring_nf ; aesop;

/-
!-- Below threshold q := c·p ∈ [0,1); q^{2^n} → 0 since 2^n → ∞; scale by 1/c. -- !--

**Sub-threshold collapse.** If `0 ≤ p`, `0 < c` and `c·p < 1` (i.e.
`p < p_th = 1/c`), then the logical error rate converges to `0`.
-/
theorem errorRate_subthreshold_tendsto_zero (c p : ℝ) (hc : 0 < c) (hp : 0 ≤ p)
    (hlt : c * p < 1) :
    Tendsto (errorRate c p) atTop (𝓝 0) := by
  convert Tendsto.const_mul ( 1 / c ) ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by positivity ) hlt |> Filter.Tendsto.comp <| tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) using 2 ; norm_num [ errorRate_closed_form _ _ hc.ne', mul_div_cancel_left₀ ];
  ring

/-
!-- At threshold q = 1, q^{2^n} = 1, so p_n = 1/c for all n; via closed form. -- !--

**Critical fixed point.** At threshold (`c·p = 1`) the error rate is frozen
at `1/c` for every level.
-/
theorem errorRate_at_threshold_const (c p : ℝ) (hc : c ≠ 0) (heq : c * p = 1)
    (n : ℕ) : errorRate c p n = 1 / c := by
  convert errorRate_closed_form c p hc n using 1 ; norm_num [ heq ]

/-
!-- Above threshold q := c·p > 1; q^{2^n} → ∞ and 1/c > 0, so p_n → ∞. -- !--

**Super-threshold blow-up.** If `0 < c` and `c·p > 1` (i.e. `p > p_th`), the
logical error rate diverges to `+∞`.
-/
theorem errorRate_superthreshold_tendsto_top (c p : ℝ) (hc : 0 < c)
    (hgt : 1 < c * p) :
    Tendsto (errorRate c p) atTop atTop := by
  -- By the closed form, we have $p_n = (1/c) * (c * p)^{2^n}$.
  have h_closed_form : ∀ n, errorRate c p n = (1 / c) * (c * p) ^ (2 ^ n) := by
    exact fun n => errorRate_closed_form c p hc.ne' n;
  rw [ show errorRate c p = _ from funext h_closed_form ] ; exact Filter.Tendsto.const_mul_atTop ( by positivity ) ( tendsto_pow_atTop_atTop_of_one_lt hgt |> Filter.Tendsto.comp <| tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) ;

/-
!-- threshold 100 = 1/100 = 0.01 by norm_num. -- !--

**The ~1% surface-code threshold.** With the surface-code malignant-pair
count `c = 100`, the fault-tolerance threshold is exactly `1%`.
-/
theorem threshold_one_percent : threshold 100 = 0.01 := by
  unfold threshold; norm_num;

/-! ## Part II: The Eastin–Knill theorem -/

/-
!-- If T were all of G then G would be finite (image of a finite set), contradicting
Infinite G; hence T ≠ univ. -- !--

**Eastin–Knill (abstract core).** In an infinite logical-unitary group `G`, a
*finite* group `T` of transversal gates can never be the whole group.  Since a
universal gate set must generate all of `G`, transversal gates are not universal.
-/
theorem eastin_knill_not_universal {G : Type*} [Group G] [Infinite G]
    (T : Subgroup G) (hT : (T : Set G).Finite) : (T : Set G) ≠ Set.univ := by
  exact fun h => hT.not_infinite <| h ▸ Set.infinite_univ

/-
**Corollary.** No finite transversal gate group contains a universal generating
set: if `T` is finite then its carrier is a proper subset of an infinite `G`.
-/
theorem eastin_knill_proper {G : Type*} [Group G] [Infinite G]
    (T : Subgroup G) (hT : (T : Set G).Finite) : (T : Set G) ⊂ Set.univ := by
  exact ⟨ Set.subset_univ _, fun h => by exact hT.not_infinite <| Set.infinite_univ.mono h ⟩

end Physics.EastinKnillThreshold