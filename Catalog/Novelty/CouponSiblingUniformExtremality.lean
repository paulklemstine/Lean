/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Uniform Extremality for Siblings of the Coupon Collector (the two-type case)

We study the following variant of the coupon-collector problem.  Coupons come in
`N` types and are drawn i.i.d. from a probability vector `p = (p_1, …, p_N)` on the
open simplex.  The *main collector* stops at the (random) time `T` at which every
type has appeared at least once.  Alongside the main collector there is a family of
*siblings*: in sibling `j`'s album (`j ≥ 2`) a type `i` counts as *filled* once it
has been drawn at least `j` times, and *empty* otherwise.  The random variable
`U_j^N` is the number of empty slots in sibling `j`'s album at the main collector's
completion time `T`, i.e. `U_j^N = #{ i : N_i(T) < j }` where `N_i(T)` is the number
of copies of type `i` seen by time `T`.

This file handles the base case `N = 2` **for every `j ≥ 2`**, with a fully
faithful probabilistic derivation.

## The two-type completion configuration

For `N = 2` the draw sequence up to completion is always a run of a single type
(say the *first* type), of some length `k ≥ 1`, followed by one copy of the other
type (the draw that completes the album).  Hence at completion one type has been
seen `k` times and the other exactly once.  Writing `a := p_1` and `1 - a := p_2`,
the length `k` of the leading run has probability mass

  `w a (k-1) = a^k (1-a) + (1-a)^k a`   (`k ≥ 1`).

This is a genuine probability mass function on `k ≥ 1` (`Σ = 1`, see
`CouponSibling.hasSum_wc`).  Since at completion the counts are `{k, 1}`, and
`j ≥ 2` forces the singleton to be empty, the number of empty slots equals
`U = 1 + 𝟙[k < j]`.  Therefore

  `E_p[U_j^2] = ∑_{k ≥ 1} w a (k-1) · (1 + 𝟙[k < j]) = 2 - a^j - (1-a)^j`.

The clean closed form `2 - a^j - (1-a)^j` (proved ∈ `CouponSibling.EU_eq`) makes
the extremality transparent: minimising `a^j + (1-a)^j` over the open interval
`(0,1)` is a strict-convexity problem whose unique minimiser is `a = 1/2`, the
uniform distribution.  This yields:

* `CouponSibling.EU_lt_uniform` — the uniform distribution is the **unique**
  maximiser of `E_p[U_j^2]`;
* `CouponSibling.EU_strictAntiOn` — `E_p[U_j^2]` is **strictly decreasing** as `a`
  moves away from `1/2` towards `1` (Schur-concavity / unimodality in the
  two-dimensional simplex).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `E_p[U_j^N]` is uniquely maximised at the uniform `p`
and is Schur-concave.  Bold sub-claim: for `N = 2` there is an *exact* elementary
closed form valid for all `j`.

Experiment (Experimenter): Combinatorial analysis of the two-type completion
configuration gives the leading-run pmf `w a (k-1) = a^k(1-a)+(1-a)^k a`.
Telescoping `Σ_{k=1}^{j-1} w` collapses the finite defect sum, yielding the
closed form `E_p[U_j^2] = 2 - a^j - (1-a)^j`.  Numerically verified against the
inclusion–exclusion formula `Σ_i Σ_{S} (-1)^{|S|} (p_i/(p_i+q_S))^j` and against
a direct simulation-style rational evaluation.

Analysis (Analyst): the closed form reduces the probabilistic extremality claim
to the strict convexity of `x ↦ x^j` on `[0,∞)` (Mathlib `strictConvexOn_pow`).
Uniform maximality is Jensen at `t = 1/2`; unimodality is the strict monotonicity
of `x^{j-1}` on the nonnegative reals.

Critique (Critic): the result is not vacuous — the pmf genuinely sums to one
(`hasSum_wc`), the expectation is a real `tsum`, and the extremum is strict with a
uniqueness clause.  Corner cases `a → 0, 1` are excluded because the *open* simplex
is the correct domain (a degenerate `p` never completes).

Synthesis (PI): the two-type story is complete for all `j`.  The general-`N`
closed form and its Schur-concavity are pursued in `CouponSiblingGeneralN` and
`FUTURE_DIRECTIONS`.
-- !-- end Lab Notes -- !--
-/

namespace CouponSibling

open scoped BigOperators
open Set

/-- Probability that the leading run of a single type has length `k + 1`
(`k ≥ 0`), for the two-type coupon collector with first-type probability `a`. -/
noncomputable def wc (a : ℝ) (k : ℕ) : ℝ := a ^ (k + 1) * (1 - a) + (1 - a) ^ (k + 1) * a

/-- The number of empty slots in sibling `j`'s album given a leading run of
length `k + 1`: always the completing singleton, plus the leading type when its
count `k + 1` is still below `j`. -/
noncomputable def Uempty (j k : ℕ) : ℝ := if k + 1 < j then 2 else 1

/-- The expected number of empty slots `E_p[U_j^2]`, as a genuine expectation
(a `tsum` of the mass function against the empty-slot count). -/
noncomputable def EU (a : ℝ) (j : ℕ) : ℝ := ∑' k, wc a k * Uempty j k

/-
The leading-run mass function is a genuine pmf: it sums to one on the open
simplex.
-/
lemma hasSum_wc {a : ℝ} (h0 : 0 < a) (h1 : a < 1) : HasSum (wc a) 1 := by
  convert HasSum.add ( HasSum.mul_left ( a * ( 1 - a ) ) ( hasSum_geometric_of_lt_one ( by linarith ) ( by linarith : a < 1 ) ) ) ( HasSum.mul_left ( a * ( 1 - a ) ) ( hasSum_geometric_of_lt_one ( by linarith ) ( by linarith : ( 1 - a ) < 1 ) ) ) using 1 ; ring_nf;
  · ext; unfold wc; ring;
  · grind

/-
Closed form for the expected number of empty slots: `2 - a^j - (1-a)^j`.
-/
lemma EU_eq {a : ℝ} (h0 : 0 < a) (h1 : a < 1) {j : ℕ} (hj : 2 ≤ j) :
    EU a j = 2 - a ^ j - (1 - a) ^ j := by
  -- A telescoping identity for the geometric-type finite sums.
  have tele : ∀ (c : ℝ) (m : ℕ), ∑ k ∈ Finset.range m, c ^ (k + 1) * (1 - c) = c - c ^ (m + 1) := by
    intro c m
    induction m with
    | zero => simp
    | succ n ih => rw [Finset.sum_range_succ, ih]; ring
  have hj1 : j - 1 + 1 = j := Nat.sub_add_cancel (by omega)
  have h_geo_series : ∑ k ∈ Finset.range (j - 1), wc a k = 1 - a ^ j - (1 - a) ^ j := by
    have h2 : ∀ k, wc a k = a ^ (k + 1) * (1 - a) + (1 - a) ^ (k + 1) * (1 - (1 - a)) := by
      intro k; unfold wc; ring
    simp only [h2, Finset.sum_add_distrib, tele, hj1]
    ring
  -- By definition of $Uempty$, we can split the sum into two parts.
  have h_split : ∑' k, wc a k * Uempty j k = ∑' k, wc a k + ∑' k, wc a k * (if k + 1 < j then 1 else 0) := by
    rw [ ← Summable.tsum_add ] ; congr ; ext k ; unfold Uempty ; split_ifs <;> ring;
    · exact HasSum.summable ( hasSum_wc h0 h1 );
    · rw [ ← summable_nat_add_iff j ];
      exact ⟨ _, hasSum_single 0 fun n hn => by rw [ if_neg ( by linarith ) ] ; ring ⟩;
  -- The second sum is finite and can be computed directly.
  have h_finite_sum : ∑' k, wc a k * (if k + 1 < j then 1 else 0) = ∑ k ∈ Finset.range (j - 1), wc a k := by
    rw [ tsum_eq_sum ];
    exacts [ Finset.sum_congr rfl fun x hx => by rw [ if_pos ( by linarith [ Finset.mem_range.mp hx, Nat.sub_add_cancel ( by linarith : 1 ≤ j ) ] ) ] ; ring, fun x hx => by rw [ if_neg ( by linarith [ Finset.mem_range.not.mp hx, Nat.sub_add_cancel ( by linarith : 1 ≤ j ) ] ) ] ; ring ];
  linarith! [ hasSum_wc h0 h1 |> HasSum.tsum_eq ]

/-
Symmetry under swapping the two types (`a ↔ 1 - a`).
-/
lemma EU_symm {a : ℝ} (h0 : 0 < a) (h1 : a < 1) {j : ℕ} (hj : 2 ≤ j) :
    EU a j = EU (1 - a) j := by
  rw [ EU_eq h0 h1 hj, EU_eq ( by linarith ) ( by linarith ) hj ] ; ring

/-
**Uniform extremality.** For every `j ≥ 2`, the uniform distribution
`a = 1/2` is the unique maximiser of `E_p[U_j^2]` on the open simplex.
-/
theorem EU_lt_uniform {a : ℝ} (h0 : 0 < a) (h1 : a < 1) (hne : a ≠ 1 / 2)
    {j : ℕ} (hj : 2 ≤ j) : EU a j < EU (1 / 2) j := by
  rw [ EU_eq h0 h1 hj ];
  -- By Jensen's inequality for the strictly convex function $x \mapsto x^j$, we have
  have h_jensen : (a ^ j + (1 - a) ^ j) / 2 > ((a + (1 - a)) / 2 : ℝ) ^ j := by
    have h_jensen : StrictConvexOn ℝ (Set.Ici 0) (fun x : ℝ => x ^ j) := by
      exact strictConvexOn_pow ( by linarith );
    have := h_jensen.2 ( show 0 ≤ a by linarith ) ( show 0 ≤ 1 - a by linarith );
    specialize this ( by contrapose! hne; linarith ) ( show 0 < ( 1 / 2 : ℝ ) by norm_num ) ( show 0 < ( 1 / 2 : ℝ ) by norm_num ) ( by norm_num ) ; norm_num at * ; ring_nf at * ; linarith;
  rw [ EU_eq ] <;> norm_num at *; all_goals linarith

/-
**Schur-concavity / unimodality.** For every `j ≥ 2`, `E_p[U_j^2]` is
strictly decreasing on `[1/2, 1)`, i.e. it strictly decreases along the ray from
the uniform vector towards the boundary.
-/
theorem EU_strictAntiOn {j : ℕ} (hj : 2 ≤ j) :
    StrictAntiOn (fun a => EU a j) (Set.Ico (1 / 2 : ℝ) 1) := by
  -- To prove strict monotonicity, we show that the derivative of $g(x) = x^j + (1-x)^j$ is positive on $(1/2, 1)$.
  have h_deriv_pos : ∀ x ∈ Set.Ioo (1 / 2 : ℝ) 1, deriv (fun x => x ^ j + (1 - x) ^ j) x > 0 := by
    intro x hx;
    erw [ deriv_add ] <;> norm_num [ sub_eq_add_neg ];
    · erw [ deriv_comp x ( show DifferentiableAt ℝ ( fun x => x ^ j ) _ from differentiableAt_pow _ ) ] <;> norm_num [ add_comm ];
      · exact mul_lt_mul_of_pos_left ( pow_lt_pow_left₀ ( by linarith [ hx.1, hx.2 ] ) ( by linarith [ hx.1, hx.2 ] ) ( Nat.sub_ne_zero_of_lt hj ) ) ( by positivity );
      · fun_prop;
    · exact DifferentiableAt.pow ( differentiableAt_id.neg.const_add _ ) _
  generalize_proofs at *; (
  -- By the Mean Value Theorem, since the derivative of $g(x)$ is positive on $(1/2, 1)$, $g(x)$ is strictly increasing on $[1/2, 1)$.
  have h_mvt : ∀ a b : ℝ, 1 / 2 ≤ a → a < b → b < 1 → (a ^ j + (1 - a) ^ j) < (b ^ j + (1 - b) ^ j) := by
    intros a b ha hb hb1
    have h_mvt : ∃ c ∈ Set.Ioo a b, deriv (fun x => x ^ j + (1 - x) ^ j) c = (b ^ j + (1 - b) ^ j - (a ^ j + (1 - a) ^ j)) / (b - a) := by
      apply_rules [ exists_deriv_eq_slope ];
      · fun_prop (disch := norm_num);
      · exact DifferentiableOn.add ( differentiableOn_pow _ ) ( DifferentiableOn.pow ( differentiableOn_id.const_sub _ ) _ )
    generalize_proofs at *; (
    obtain ⟨ c, hc₁, hc₂ ⟩ := h_mvt; have := h_deriv_pos c ⟨ by linarith [ hc₁.1 ], by linarith [ hc₁.2 ] ⟩ ; rw [ hc₂, gt_iff_lt ] at this; rw [ lt_div_iff₀ ] at this <;> linarith;)
  generalize_proofs at *; (
  intros a ha b hb hab; exact (by
  have := EU_eq ( show 0 < a by linarith [ ha.1 ] ) ( show a < 1 by linarith [ ha.2 ] ) hj; have := EU_eq ( show 0 < b by linarith [ hb.1 ] ) ( show b < 1 by linarith [ hb.2 ] ) hj; norm_num at * ; linarith [ h_mvt a b ha.1 hab hb.2 ] ;);))

end CouponSibling