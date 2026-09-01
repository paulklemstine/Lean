import Probability.NET89MassDominanceRigidity

/-!
# NET-89, cycle 7: inside the block — the `±b` window collapses to an exact value

Cycle 2 proved that the block size of the NET-89 protocol (~500-character blocks) is a
*gauge* parameter: at block-aligned budgets it is invisible, and it can move the knee by at
most one block on either side (`kstar_mixBlock_bracket`).  Direction **D3** asked whether
that residual window is real or an artefact of only ever evaluating at aligned budgets.

It is an artefact.  This cycle computes the blocked head mass at an *arbitrary* budget:

* `headMass_mixBlock_first_half` and `headMass_mixBlock_second_half` — the master
  identities.  Inside the first half of a block pair the mixture accumulates keys of the
  first domain only, on top of matched prefixes of both; inside the second half it
  accumulates keys of the second domain only, on top of a *complete* extra block of the
  first.  The head mass is therefore piecewise "one domain at a time", which is exactly
  the linear intra-block growth D3 predicted.
* `retained_mixBlock_first_half` / `retained_mixBlock_second_half` — the same statement for
  the retained-mass curve, with the denominator supplied by the aligned identity.
* `kstar_mixBlock_exact_first_half` / `kstar_mixBlock_exact_second_half` — **the exact
  knee.**  Two component-level inequalities, one failing and one passing, determine the
  blocked knee to a single integer; no bracket remains.  This resolves D3.
* `kstar_mixBlock_upper_sharp` — as a by-product the aligned upper bound improves from
  `2Q + 2b` to `2Q + b - (Q mod b)`, halving the quantisation error the protocol has to
  tolerate.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 7):
 (H1) The blocked head mass at an arbitrary budget is a two-regime closed form: one
      domain at a time.                                                      [BOLD]
 (H2) Hence the knee is exact, not bracketed: the `±b` window of cycle 2 is an
      artefact of aligned sampling.                                          [BOLD]
 (H3) The aligned upper bound improves to `2Q + b - (Q mod b)`.

Experimenter: H1–H3 formalised below, zero sorries.  The exact-knee theorems take their
two inequalities in terms of the *component* head masses, so they can be evaluated from a
domain-wise attention table without ever building the mixed context.

Analyst: the two regimes explain why cycle 2 could only get a bracket.  The blocked curve
is *not* a rescaling of the pooled curve away from block boundaries — inside a half-block
only one domain contributes — so aligned sampling genuinely loses information, and the
lost information is precisely the intra-block crossing point recovered here.

Critic: the exact-knee theorems have real content because their hypotheses are strict on
one side; a knee reported without checking the failing inequality is a bracket, not a
value, which is the honest reading of cycle 2.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v : ℕ → ℝ} {τ : ℝ} {b n q r : ℕ}

/-! ## 1. Which key of which domain sits at a given index -/

lemma mixBlock_first (hb : 0 < b) {i : ℕ} (hi : i < b) :
    mixBlock b u v (2 * b * q + i) = u (b * q + i) := by
  have hrw : 2 * b * q + i = b * (2 * q) + i := by ring
  have h1 : (2 * b * q + i) / b = 2 * q := by
    rw [hrw, Nat.mul_add_div hb, Nat.div_eq_of_lt hi, Nat.add_zero]
  have h2 : (2 * b * q + i) % b = i := by
    rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt hi]
  have h3 : (2 * q) % 2 = 0 := by omega
  have h4 : (2 * q) / 2 = q := by omega
  simp [mixBlock, h1, h2, h3, h4]

lemma mixBlock_second (hb : 0 < b) {i : ℕ} (hi : i < b) :
    mixBlock b u v (2 * b * q + b + i) = v (b * q + i) := by
  have hrw : 2 * b * q + b + i = b * (2 * q + 1) + i := by ring
  have h1 : (2 * b * q + b + i) / b = 2 * q + 1 := by
    rw [hrw, Nat.mul_add_div hb, Nat.div_eq_of_lt hi, Nat.add_zero]
  have h2 : (2 * b * q + b + i) % b = i := by
    rw [hrw, Nat.mul_add_mod, Nat.mod_eq_of_lt hi]
  have h3 : (2 * q + 1) % 2 = 1 := by omega
  have h4 : (2 * q + 1) / 2 = q := by omega
  simp [mixBlock, h1, h2, h3, h4]

/-! ## 2. The master identities at arbitrary budgets -/

/-- **First half of a block pair.**  Only the first domain accumulates. -/
lemma headMass_mixBlock_first_half (hb : 0 < b) (hr : r ≤ b) (u v : ℕ → ℝ) (q : ℕ) :
    headMass (mixBlock b u v) (2 * b * q + r) = headMass u (b * q + r) + headMass v (b * q) := by
  induction r with
  | zero => simpa using headMass_mixBlock hb u v q
  | succ m ih =>
      have hm : m < b := by omega
      have e1 : 2 * b * q + (m + 1) = (2 * b * q + m) + 1 := by ring
      have e2 : headMass (mixBlock b u v) ((2 * b * q + m) + 1)
          = headMass (mixBlock b u v) (2 * b * q + m) + mixBlock b u v (2 * b * q + m) := by
        simp [headMass, Finset.sum_range_succ]
      have e3 : headMass u (b * q + (m + 1)) = headMass u (b * q + m) + u (b * q + m) := by
        have : b * q + (m + 1) = (b * q + m) + 1 := by ring
        rw [this]
        simp [headMass, Finset.sum_range_succ]
      rw [e1, e2, ih (by omega), mixBlock_first hb hm, e3]
      ring

/-- **Second half of a block pair.**  The first domain has contributed a full extra block;
only the second domain now accumulates. -/
lemma headMass_mixBlock_second_half (hb : 0 < b) (hr : r ≤ b) (u v : ℕ → ℝ) (q : ℕ) :
    headMass (mixBlock b u v) (2 * b * q + b + r)
      = headMass u (b * q + b) + headMass v (b * q + r) := by
  induction r with
  | zero => simpa using headMass_mixBlock_first_half hb le_rfl u v q
  | succ m ih =>
      have hm : m < b := by omega
      have e1 : 2 * b * q + b + (m + 1) = (2 * b * q + b + m) + 1 := by ring
      have e2 : headMass (mixBlock b u v) ((2 * b * q + b + m) + 1)
          = headMass (mixBlock b u v) (2 * b * q + b + m)
            + mixBlock b u v (2 * b * q + b + m) := by
        simp [headMass, Finset.sum_range_succ]
      have e3 : headMass v (b * q + (m + 1)) = headMass v (b * q + m) + v (b * q + m) := by
        have : b * q + (m + 1) = (b * q + m) + 1 := by ring
        rw [this]
        simp [headMass, Finset.sum_range_succ]
      rw [e1, e2, ih (by omega), mixBlock_second hb hm, e3]
      ring

/-! ## 3. The retained-mass curve inside a block -/

lemma mixBlock_budget_le (hq : q < n) (hr : r ≤ b) :
    2 * b * q + b + r ≤ 2 * b * n := by
  have h1 : 2 * b * (q + 1) ≤ 2 * b * n := Nat.mul_le_mul_left _ hq
  have h2 : 2 * b * (q + 1) = 2 * b * q + 2 * b := by ring
  omega

lemma retained_mixBlock_first_half (hb : 0 < b) (hq : q < n) (hr : r ≤ b) :
    retained (mixBlock b u v) (2 * b * n) (2 * b * q + r)
      = (headMass u (b * q + r) + headMass v (b * q))
        / (headMass u (b * n) + headMass v (b * n)) := by
  have hle : 2 * b * q + r ≤ 2 * b * n := by
    have := mixBlock_budget_le (b := b) (q := q) (n := n) (r := r) hq hr
    omega
  rw [retained, min_eq_left hle, headMass_mixBlock_first_half hb hr,
    headMass_mixBlock hb]

lemma retained_mixBlock_second_half (hb : 0 < b) (hq : q < n) (hr : r ≤ b) :
    retained (mixBlock b u v) (2 * b * n) (2 * b * q + b + r)
      = (headMass u (b * q + b) + headMass v (b * q + r))
        / (headMass u (b * n) + headMass v (b * n)) := by
  rw [retained, min_eq_left (mixBlock_budget_le hq hr),
    headMass_mixBlock_second_half hb hr, headMass_mixBlock hb]

/-! ## 4. The exact blocked knee — direction D3 resolved -/

/-- **Exact knee, first half of a block pair.**  Two inequalities in the *component* head
masses — one failing, one passing — determine the blocked knee exactly.  No bracket
remains: the `±b` window of cycle 2 was an artefact of block-aligned sampling. -/
theorem kstar_mixBlock_exact_first_half (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hb : 0 < b) (hq : q < n) (hr1 : 1 ≤ r) (hr : r ≤ b) (hτ : τ ≤ 1)
    (hfail : (headMass u (b * q + r - 1) + headMass v (b * q))
        / (headMass u (b * n) + headMass v (b * n)) < τ)
    (hpass : τ ≤ (headMass u (b * q + r) + headMass v (b * q))
        / (headMass u (b * n) + headMass v (b * n))) :
    kstar (mixBlock b u v) (2 * b * n) τ = 2 * b * q + r := by
  have hbp : ∀ i, 0 < mixBlock b u v i := mixBlock_pos hu hv b
  have hn : 0 < 2 * b * n := by
    have h : 0 < b * n := Nat.mul_pos hb (by omega)
    have e : 2 * b * n = 2 * (b * n) := by ring
    omega
  have e : 2 * b * q + (r - 1) + 1 = 2 * b * q + r := by omega
  have hf : retained (mixBlock b u v) (2 * b * n) (2 * b * q + (r - 1)) < τ := by
    rw [retained_mixBlock_first_half hb hq (by omega)]
    have : b * q + (r - 1) = b * q + r - 1 := by omega
    rw [this]
    exact hfail
  have hp : τ ≤ retained (mixBlock b u v) (2 * b * n) (2 * b * q + (r - 1) + 1) := by
    rw [e, retained_mixBlock_first_half hb hq hr]
    exact hpass
  rw [kstar_eq_of_fail_pass hbp hn hτ hf hp, e]

/-- **Exact knee, second half of a block pair.**  The mirror statement, with a complete
extra block of the first domain already in place. -/
theorem kstar_mixBlock_exact_second_half (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hb : 0 < b) (hq : q < n) (hr1 : 1 ≤ r) (hr : r ≤ b) (hτ : τ ≤ 1)
    (hfail : (headMass u (b * q + b) + headMass v (b * q + r - 1))
        / (headMass u (b * n) + headMass v (b * n)) < τ)
    (hpass : τ ≤ (headMass u (b * q + b) + headMass v (b * q + r))
        / (headMass u (b * n) + headMass v (b * n))) :
    kstar (mixBlock b u v) (2 * b * n) τ = 2 * b * q + b + r := by
  have hbp : ∀ i, 0 < mixBlock b u v i := mixBlock_pos hu hv b
  have hn : 0 < 2 * b * n := by
    have h : 0 < b * n := Nat.mul_pos hb (by omega)
    have e : 2 * b * n = 2 * (b * n) := by ring
    omega
  have e : 2 * b * q + b + (r - 1) + 1 = 2 * b * q + b + r := by omega
  have hf : retained (mixBlock b u v) (2 * b * n) (2 * b * q + b + (r - 1)) < τ := by
    rw [retained_mixBlock_second_half hb hq (by omega)]
    have : b * q + (r - 1) = b * q + r - 1 := by omega
    rw [this]
    exact hfail
  have hp : τ ≤ retained (mixBlock b u v) (2 * b * n) (2 * b * q + b + (r - 1) + 1) := by
    rw [e, retained_mixBlock_second_half hb hq hr]
    exact hpass
  rw [kstar_eq_of_fail_pass hbp hn hτ hf hp, e]

/-! ## 5. A sharper aligned upper bound -/

/-- **The quantisation error halves.**  Cycle 2's upper bound `2Q + 2b` improves to
`2Q + b - (Q mod b)`: the blocked knee never overshoots the doubled pooled knee by a full
block once the block-local offset of the pooled knee is taken into account. -/
theorem kstar_mixBlock_upper_sharp (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hb : 0 < b)
    (hn : 0 < n) (hτ : τ ≤ 1) (hQ : kstar (pool 1 1 u v) (b * n) τ < b * n) :
    kstar (mixBlock b u v) (2 * b * n) τ
      ≤ 2 * kstar (pool 1 1 u v) (b * n) τ + b - kstar (pool 1 1 u v) (b * n) τ % b := by
  have hpp : ∀ i, 0 < pool 1 1 u v i := pool_pos one_pos one_pos hu hv
  have hbn : 0 < b * n := Nat.mul_pos hb hn
  set Q := kstar (pool 1 1 u v) (b * n) τ with hQdef
  set s := Q % b with hs
  set q := Q / b with hq
  have hdm : b * q + s = Q := Nat.div_add_mod Q b
  have hsb : s < b := Nat.mod_lt _ hb
  have hqn : q < n := by
    have h1 : b * q ≤ Q := by omega
    have h2 : b * q < b * n := by omega
    exact lt_of_mul_lt_mul_left h2 (Nat.zero_le b)
  -- the pooled knee passes the gate
  have hpool : τ ≤ (headMass u Q + headMass v Q) / (headMass u (b * n) + headMass v (b * n)) := by
    have h := gate_le_retained_kstar hpp hbn hτ
    rw [retained, min_eq_left hQ.le, headMass_pool, headMass_pool] at h
    simpa using h
  -- the blocked mixture passes at budget `2bq + b + s`
  have hmono : headMass u Q ≤ headMass u (b * q + b) := by
    refine headMass_mono hu ?_
    omega
  have hD : 0 < headMass u (b * n) + headMass v (b * n) := by
    have := headMass_pos hu hbn
    have := headMass_pos hv hbn
    linarith
  have hpass : τ ≤ retained (mixBlock b u v) (2 * b * n) (2 * b * q + b + s) := by
    rw [retained_mixBlock_second_half hb hqn hsb.le]
    refine le_trans hpool ?_
    refine div_le_div_of_nonneg_right ?_ hD.le
    have hvq : headMass v Q = headMass v (b * q + s) := by rw [hdm]
    rw [hvq] at *
    linarith
  have hle := kstar_le_of_pass hpass
  have e : 2 * b * q = 2 * (b * q) := by ring
  omega

end Catalog.Probability.NET89MixedDomainKnee