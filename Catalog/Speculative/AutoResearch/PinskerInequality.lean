import Mathlib

/-!
# The General Pinsker Inequality for Finite Distributions

This file proves the **general Pinsker inequality**

  `(1/2) · (∑ᵢ |p i − q i|)² ≤ KL(p ‖ q)`

for arbitrary (strictly positive, normalised) probability vectors `p, q` over a finite
type `ι`.  Equivalently `2 · TV(p,q)² ≤ KL(p ‖ q)`, where `TV = ½ ‖p − q‖₁`.

This **closes the open conjecture `klDiv_ge_half_tv_sq`** that was stated with `sorry`
in `Speculative.AutoResearch.FisherInformationMetric` (the Fisher/χ² sandwich file),
sharpening that file's *upper* sandwich `KL ≤ χ²` with the matching *lower* control by
the L¹ (total-variation) norm.  (The divergence `klDiv` is redefined here identically
to keep this file self-contained; `general_pinsker` is the missing lower bound.)

## Strategy (the two pillars)

1. **Bernoulli Pinsker** (`bernoulli_pinsker`): `2 (p−q)² ≤ KL(Ber p ‖ Ber q)`.
   Proved by the *factored-derivative* monotonicity argument: with
   `g q := klBer p q − 2 (p−q)²` one has the exact factorisation
   `g'(q) = (q − p) · (1 − 2q)² / (q (1 − q))`, whose sign is governed entirely by the
   sign of `q − p`.  Hence `g` is antitone on `(0,p]` and monotone on `[p,1)`, so it
   attains its minimum `g p = 0`.

2. **Log-sum (data-processing) inequality** (`log_sum_ineq`): obtained from Jensen's
   inequality applied to the convex function `x ↦ x log x` (`Real.convexOn_mul_log`).

The general inequality follows by *projecting onto the binary event*
`A = {i : q i ≤ p i}`: log-sum on `A` and on `Aᶜ` collapses `KL(p‖q)` below to the
Bernoulli divergence `klBer P_A Q_A`, and `P_A − Q_A` is exactly the total variation.

-- !-- Lab Notebook (file-level) -- !--
-- !-- Hypothesis: General Pinsker `2·TV² ≤ KL` reduces to the Bernoulli case via -- !--
-- !-- the data-processing inequality applied to the single optimal binary event. -- !--
-- !-- Result: Proved `bernoulli_pinsker`, `log_sum_ineq`, and the main -- !--
-- !-- `general_pinsker`, then back-filled `klDiv_ge_half_tv_sq`. -- !--
-- !-- Insight: The optimal event `A = {q ≤ p}` makes `P_A − Q_A = TV`, so the -- !--
-- !-- generic data-processing bound becomes TIGHT precisely at this event; the -- !--
-- !-- Bernoulli derivative factors through the perfect square `(1−2q)²`. -- !--
-- !-- Failure analysis: A termwise bound `2(pᵢ−qᵢ)² ≤ pᵢ log(pᵢ/qᵢ)` is FALSE; -- !--
-- !-- the inequality only holds after the L¹ aggregation, which is why the -- !--
-- !-- projection-to-binary step is essential rather than cosmetic. -- !--
-- !-- End Lab Notebook -- !--
-/

noncomputable section

open Finset Real

namespace PinskerInequality

/-- The **Kullback–Leibler divergence** of `p` from `q` (identical to
`FisherInformationMetric.klDiv`, restated to keep this file self-contained). -/
def klDiv {ι : Type*} [Fintype ι] (p q : ι → ℝ) : ℝ := ∑ i, p i * Real.log (p i / q i)

/-- The **Bernoulli (binary) Kullback–Leibler divergence**
`KL(Ber p ‖ Ber q) = p log(p/q) + (1−p) log((1−p)/(1−q))`. -/
def klBer (p q : ℝ) : ℝ :=
  p * Real.log (p / q) + (1 - p) * Real.log ((1 - p) / (1 - q))

/-! ## Section 1 — Bernoulli Pinsker inequality -/

-- !-- Proof sketch (derivative factorisation): for fixed `p`, the gap
-- `g q = klBer p q − 2(p−q)²` has derivative `(q−p)(1−2q)²/(q(1−q))`, so `g` decreases
-- on `(0,p]` and increases on `[p,1)`, giving `g q ≥ g p = 0`. -- !--

-- !-- Lab Notebook: bernoulli_pinsker -- !--
-- !-- Hypothesis: `2(p−q)² ≤ KL(Ber p ‖ Ber q)` holds for all `p,q ∈ (0,1)`. -- !--
-- !-- Result: Proved by reducing to `g q := klBer p q − 2(p−q)² ≥ 0`, where `g p = 0`. -- !--
-- !-- Insight: `g'(q) = (q−p)(1−2q)²/(q(1−q))` — the perfect square `(1−2q)²` makes -- !--
-- !-- the sign of `g'` equal to the sign of `q−p`, so `p` is the unique minimiser. -- !--
-- !-- Failure analysis: convexity of `g` in `q` fails (2nd derivative is not -- !--
-- !-- sign-definite); the monotonicity/MVT route via the factored 1st derivative -- !--
-- !-- is what works, after splitting `(0,1)` at the apex `q = p`. -- !--
-- !-- End Lab Notebook -- !--
set_option maxHeartbeats 1600000 in
/-- **Bernoulli Pinsker inequality.** For `p, q ∈ (0,1)`,
`2 (p − q)² ≤ KL(Ber p ‖ Ber q)`. -/
theorem bernoulli_pinsker {p q : ℝ} (hp0 : 0 < p) (hp1 : p < 1)
    (hq0 : 0 < q) (hq1 : q < 1) :
    2 * (p - q) ^ 2 ≤ klBer p q := by
  -- Define the function $g(x) = klBer p x - 2(p-x)^2$.
  set g : ℝ → ℝ := fun x => klBer p x - 2 * (p - x) ^ 2;
  -- Prove that $g(x)$ is non-negative by showing that its derivative is non-negative for $x \geq p$ and non-positive for $x \leq p$.
  have h_deriv_nonneg : ∀ x ∈ Set.Ioo p 1, 0 ≤ deriv g x := by
    intro x hx
    have h_deriv : deriv g x = (x - p) * (1 - 2 * x) ^ 2 / (x * (1 - x)) := by
      simp +zetaDelta at *;
      unfold klBer; norm_num [ mul_comm, sub_sq, mul_assoc, mul_left_comm, div_eq_mul_inv ] ; ring;
      refine' HasDerivAt.deriv _;
      convert HasDerivAt.add ( HasDerivAt.add ( HasDerivAt.add ( HasDerivAt.mul ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_id x ) ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( HasDerivAt.log ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_inv ( by linarith : x ≠ 0 ) ) ) _ ) ) ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( HasDerivAt.log ( HasDerivAt.add ( HasDerivAt.neg ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( HasDerivAt.inv ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) _ ) ) ) ( HasDerivAt.inv ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) _ ) ) _ ) ) ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_pow 2 x ) ( hasDerivAt_const _ _ ) ) ) ) ( HasDerivAt.log ( HasDerivAt.add ( HasDerivAt.neg ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( HasDerivAt.inv ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) _ ) ) ) ( HasDerivAt.inv ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) _ ) ) _ ) using 1 <;> norm_num [ show x ≠ 0 by linarith, show 1 - x ≠ 0 by linarith ] ; ring;
      · grind;
      · linarith;
      · nlinarith [ inv_mul_cancel₀ ( by linarith : ( 1 - x ) ≠ 0 ) ];
      · nlinarith [ inv_mul_cancel₀ ( by linarith : ( 1 - x ) ≠ 0 ) ];
    exact h_deriv.symm ▸ div_nonneg ( mul_nonneg ( by linarith [ hx.1 ] ) ( sq_nonneg _ ) ) ( mul_nonneg ( by linarith [ hx.1 ] ) ( by linarith [ hx.2 ] ) )
  have h_deriv_nonpos : ∀ x ∈ Set.Ioo 0 p, deriv g x ≤ 0 := by
    -- By definition of $g$, we know that its derivative is given by:
    have h_deriv : ∀ x ∈ Set.Ioo (0:ℝ) 1, deriv g x = (x - p) * (1 - 2*x)^2 / (x * (1 - x)) := by
      intro x hx; unfold g klBer; norm_num [ mul_comm p _, mul_assoc, mul_left_comm, hx.1.ne', hx.2.ne', ne_of_gt hx.1, ne_of_gt ( sub_pos.mpr hx.2 ) ] ; ring;
      convert HasDerivAt.deriv ( HasDerivAt.add ( HasDerivAt.add ( HasDerivAt.add ( HasDerivAt.mul ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_id' x ) ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( HasDerivAt.log ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_inv hx.1.ne' ) ) _ ) ) ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( HasDerivAt.log ( HasDerivAt.add ( HasDerivAt.neg ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( HasDerivAt.inv ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) _ ) ) ) ( HasDerivAt.inv ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) _ ) ) _ ) ) ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_pow 2 x ) ( hasDerivAt_const _ _ ) ) ) ) ( HasDerivAt.log ( HasDerivAt.add ( HasDerivAt.neg ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( HasDerivAt.inv ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) _ ) ) ) ( HasDerivAt.inv ( hasDerivAt_id' x |> HasDerivAt.const_sub _ ) _ ) ) _ ) ) using 1 <;> norm_num [ hx.1.ne', hx.2.ne', ne_of_gt ( show 0 < 1 - x from by linarith [ hx.2 ] ), ne_of_gt ( show 0 < x from by linarith [ hx.1 ] ) ] ; ring;
      · grind;
      · linarith;
      · nlinarith [ hx.1, hx.2, mul_inv_cancel₀ ( by linarith [ hx.1, hx.2 ] : ( 1 - x ) ≠ 0 ) ];
      · nlinarith [ hx.1, hx.2, mul_inv_cancel₀ ( by linarith [ hx.1, hx.2 ] : ( 1 - x ) ≠ 0 ) ];
    exact fun x hx => h_deriv x ⟨ hx.1, hx.2.trans hp1 ⟩ ▸ div_nonpos_of_nonpos_of_nonneg ( mul_nonpos_of_nonpos_of_nonneg ( sub_nonpos.2 hx.2.le ) ( sq_nonneg _ ) ) ( mul_nonneg hx.1.le ( sub_nonneg.2 ( hx.2.le.trans hp1.le ) ) );
  -- By the properties of the derivative, we know that $g(x)$ is non-decreasing on $[p, 1)$ and non-increasing on $(0, p]$.
  have h_monotone : ∀ x y : ℝ, p ≤ x → x < y → y < 1 → g x ≤ g y := by
    intros x y hx hy hxy
    have h_mean_val : ∃ c ∈ Set.Ioo x y, deriv g c = (g y - g x) / (y - x) := by
      apply_rules [ exists_deriv_eq_slope ];
      · refine' ContinuousOn.sub _ _;
        · refine' ContinuousOn.add _ _;
          · exact continuousOn_of_forall_continuousAt fun q hq => ContinuousAt.mul continuousAt_const <| ContinuousAt.log ( continuousAt_const.div continuousAt_id <| by linarith [ hq.1 ] ) <| by exact ne_of_gt <| div_pos hp0 <| by linarith [ hq.1 ] ;
          · exact continuousOn_of_forall_continuousAt fun q hq => ContinuousAt.mul continuousAt_const <| ContinuousAt.log ( ContinuousAt.div continuousAt_const ( continuousAt_const.sub continuousAt_id ) <| by linarith [ hq.1, hq.2 ] ) <| div_ne_zero ( by linarith ) <| by linarith [ hq.1, hq.2 ] ;
        · exact Continuous.continuousOn ( by continuity );
      · refine' DifferentiableOn.sub _ _;
        · refine' DifferentiableOn.add _ _;
          · exact DifferentiableOn.mul ( differentiableOn_const _ ) ( DifferentiableOn.log ( DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id ( by intro u hu; linarith [ hu.1 ] ) ) ( by intro u hu; exact ne_of_gt ( div_pos hp0 ( by linarith [ hu.1 ] ) ) ) );
          · exact DifferentiableOn.mul ( differentiableOn_const _ ) ( DifferentiableOn.log ( DifferentiableOn.div ( differentiableOn_const _ ) ( differentiableOn_id.const_sub _ ) ( by intro u hu; linarith [ hu.1, hu.2 ] ) ) ( by intro u hu; exact div_ne_zero ( by linarith [ hu.1, hu.2 ] ) ( by linarith [ hu.1, hu.2 ] ) ) );
        · exact DifferentiableOn.mul ( differentiableOn_const _ ) ( DifferentiableOn.pow ( differentiableOn_id.const_sub _ ) _ );
    obtain ⟨ c, ⟨ hxc, hcy ⟩, hcd ⟩ := h_mean_val; have := h_deriv_nonneg c ⟨ by linarith, by linarith ⟩ ; rw [ hcd, le_div_iff₀ ] at this <;> linarith;
  have h_antitone : ∀ x y : ℝ, 0 < x → x < y → y ≤ p → g y ≤ g x := by
    intros x y hx hy hp
    have h_mean_val : ∃ c ∈ Set.Ioo x y, deriv g c = (g y - g x) / (y - x) := by
      apply_rules [ exists_deriv_eq_slope ];
      · refine' ContinuousOn.sub _ _;
        · refine' ContinuousOn.add _ _;
          · exact continuousOn_of_forall_continuousAt fun q hq => ContinuousAt.mul continuousAt_const <| ContinuousAt.log ( continuousAt_const.div continuousAt_id <| by linarith [ hq.1 ] ) <| by exact ne_of_gt <| div_pos hp0 <| by linarith [ hq.1 ] ;
          · exact continuousOn_of_forall_continuousAt fun q hq => ContinuousAt.mul continuousAt_const <| ContinuousAt.log ( ContinuousAt.div continuousAt_const ( continuousAt_const.sub continuousAt_id ) <| by linarith [ hq.1, hq.2 ] ) <| div_ne_zero ( by linarith ) <| by linarith [ hq.1, hq.2 ] ;
        · exact Continuous.continuousOn ( by continuity );
      · refine' DifferentiableOn.sub _ _;
        · refine' DifferentiableOn.add _ _;
          · exact DifferentiableOn.mul ( differentiableOn_const _ ) ( DifferentiableOn.log ( DifferentiableOn.div ( differentiableOn_const _ ) differentiableOn_id ( by intro u hu; linarith [ hu.1 ] ) ) ( by intro u hu; exact ne_of_gt ( div_pos hp0 ( by linarith [ hu.1 ] ) ) ) );
          · exact DifferentiableOn.mul ( differentiableOn_const _ ) ( DifferentiableOn.log ( DifferentiableOn.div ( differentiableOn_const _ ) ( differentiableOn_id.const_sub _ ) ( by intro u hu; linarith [ hu.1, hu.2 ] ) ) ( by intro u hu; exact div_ne_zero ( by linarith [ hu.1, hu.2 ] ) ( by linarith [ hu.1, hu.2 ] ) ) );
        · exact DifferentiableOn.mul ( differentiableOn_const _ ) ( DifferentiableOn.pow ( differentiableOn_id.const_sub _ ) _ );
    obtain ⟨ c, ⟨ hxc, hcy ⟩, hcd ⟩ := h_mean_val; have := h_deriv_nonpos c ⟨ by linarith, by linarith ⟩ ; rw [ hcd, div_le_iff₀ ] at this <;> linarith;
  -- Since $g(p) = 0$, we have $g(q) \geq 0$ for all $q \in (0, 1)$.
  have h_g_nonneg : ∀ q ∈ Set.Ioo 0 1, g q ≥ g p := by
    grind;
  simp +zetaDelta at *;
  unfold klBer at *; norm_num at *; linarith [ h_g_nonneg q hq0 hq1 ] ;

/-! ## Section 2 — Log-sum (data-processing) inequality -/

-- !-- Proof sketch (Jensen): with weights `wᵢ = bᵢ/B` and points `xᵢ = aᵢ/bᵢ`, convexity
-- of `x ↦ x log x` gives `f(∑ wᵢxᵢ) ≤ ∑ wᵢ f(xᵢ)`, i.e. `(A/B)log(A/B) ≤ (1/B)∑ aᵢlog(aᵢ/bᵢ)`. -- !--

-- !-- Lab Notebook: log_sum_ineq -- !--
-- !-- Hypothesis: `(∑a)·log((∑a)/(∑b)) ≤ ∑ aᵢ log(aᵢ/bᵢ)` (the log-sum inequality). -- !--
-- !-- Result: Proved by Jensen applied to the convex `x ↦ x log x` with weights -- !--
-- !-- `bᵢ/B` and points `aᵢ/bᵢ`. -- !--
-- !-- Insight: This is exactly the data-processing inequality for KL under the -- !--
-- !-- coarse-graining that lumps a block of outcomes into a single one. -- !--
-- !-- Failure analysis: a termwise comparison fails; only the weighted-average -- !--
-- !-- (Jensen) form aggregates the slack correctly. -- !--
-- !-- End Lab Notebook -- !--
/-- **Log-sum inequality.** For nonnegative `a` and positive `b` on a finite set `s`
with `∑ a > 0`,
`(∑ a) · log((∑ a)/(∑ b)) ≤ ∑ aᵢ log(aᵢ/bᵢ)`. -/
theorem log_sum_ineq {ι : Type*} (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 < b i)
    (hA : 0 < ∑ i ∈ s, a i) :
    (∑ i ∈ s, a i) * Real.log ((∑ i ∈ s, a i) / (∑ i ∈ s, b i))
      ≤ ∑ i ∈ s, a i * Real.log (a i / b i) := by
  -- Let $B = \sum_{i \in s} b_i$ and $A = \sum_{i \in s} a_i$.
  set B := ∑ i ∈ s, b i
  set A := ∑ i ∈ s, a i;
  -- Apply Jensen's inequality to the convex function $f(x) = x \log x$ with weights $w_i = \frac{b_i}{B}$ and points $x_i = \frac{a_i}{b_i}$.
  have h_jensen : (∑ i ∈ s, (b i / B) * (a i / b i) * Real.log (a i / b i)) ≥ ((∑ i ∈ s, (b i / B) * (a i / b i))) * Real.log (∑ i ∈ s, (b i / B) * (a i / b i)) := by
    have h_jensen : ConvexOn ℝ (Set.Ici 0) (fun x => x * Real.log x) := by
      exact ( Real.convexOn_mul_log );
    have h_jensen : (∑ i ∈ s, (b i / B) * (fun x => x * Real.log x) (a i / b i)) ≥ (fun x => x * Real.log x) (∑ i ∈ s, (b i / B) * (a i / b i)) := by
      apply ConvexOn.map_sum_le h_jensen;
      · exact fun i hi => div_nonneg ( le_of_lt ( hb i hi ) ) ( Finset.sum_nonneg fun _ _ => le_of_lt ( hb _ ‹_› ) );
      · rw [ ← Finset.sum_div, div_self <| ne_of_gt <| Finset.sum_pos hb <| Finset.nonempty_of_ne_empty <| by rintro rfl; norm_num at hA ];
      · exact fun i hi => div_nonneg ( ha i hi ) ( le_of_lt ( hb i hi ) );
    simpa only [ mul_assoc ] using h_jensen;
  -- Simplify the terms inside the Jensen's inequality.
  have h_simplify : (∑ i ∈ s, (b i / B) * (a i / b i)) = A / B ∧ (∑ i ∈ s, (b i / B) * (a i / b i) * Real.log (a i / b i)) = (1 / B) * (∑ i ∈ s, a i * Real.log (a i / b i)) := by
    simp +decide [ div_eq_inv_mul, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ];
    simp +decide [ ← mul_assoc ];
    exact ⟨ by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_congr rfl fun i hi => by rw [ mul_inv_cancel₀ ( ne_of_gt ( hb i hi ) ) ] ; ring, Finset.sum_congr rfl fun i hi => by rw [ mul_inv_cancel_right₀ ( ne_of_gt ( hb i hi ) ) ] ⟩;
  by_cases hB : B = 0 <;> simp_all +decide [ div_eq_inv_mul, mul_assoc, mul_left_comm, mul_comm ];
  · exact absurd hB ( ne_of_gt ( Finset.sum_pos hb ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) ) );
  · nlinarith [ inv_pos.2 ( show 0 < B by exact lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => le_of_lt ( hb _ ‹_› ) ) ( Ne.symm hB ) ) ]

/-! ## Section 3 — The general Pinsker inequality -/

-- !-- Proof sketch (projection to binary event): split `KL` along `A = {q ≤ p}`; two
-- applications of `log_sum_ineq` give `KL ≥ klBer P_A Q_A`, then `bernoulli_pinsker`
-- gives `klBer P_A Q_A ≥ 2(P_A−Q_A)²`, and `P_A − Q_A = ½∑|pᵢ−qᵢ|`. -- !--

-- !-- Lab Notebook: general_pinsker -- !--
-- !-- Hypothesis: `(1/2)(∑|pᵢ−qᵢ|)² ≤ KL(p‖q)` for finite distributions. -- !--
-- !-- Result: Proved by projecting to the binary event `A = {q ≤ p}`, combining -- !--
-- !-- `log_sum_ineq` (twice) with `bernoulli_pinsker`. -- !--
-- !-- Insight: choosing the *optimal* event `A = {q ≤ p}` makes the generic -- !--
-- !-- data-processing bound tight, since `P_A − Q_A` equals the total variation. -- !--
-- !-- Failure analysis: the `TV = 0` degenerate branch (where `Aᶜ = ∅` forces -- !--
-- !-- `p = q`) must be split off first so that `0 < P_A, Q_A < 1` holds. -- !--
-- !-- End Lab Notebook -- !--
/-- **General Pinsker inequality.** For strictly positive normalised probability
vectors `p, q` on a finite type, `(1/2)(∑ |p i − q i|)² ≤ KL(p ‖ q)`. -/
theorem general_pinsker {ι : Type*} [Fintype ι] (p q : ι → ℝ)
    (hp : ∀ i, 0 < p i) (hq : ∀ i, 0 < q i)
    (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    (1 / 2) * (∑ i, |p i - q i|) ^ 2 ≤ klDiv p q := by
  -- Set A : Finset ι := Finset.univ.filter (fun i => q i ≤ p i). Let Ac = Aᶜ (the complement filter, i.e. filter (fun i => ¬ q i ≤ p i) = filter (fun i => p i < q i)).
  set A : Finset ι := Finset.univ.filter (fun i => q i ≤ p i)
  set Ac : Finset ι := Finset.univ.filter (fun i => ¬ q i ≤ p i) with hAc;
  by_cases h : ∑ i, |p i - q i| = 0 <;> simp_all +decide;
  · exact Finset.sum_nonneg fun i _ => mul_nonneg ( le_of_lt ( hp i ) ) ( Real.log_nonneg ( by rw [ le_div_iff₀ ( hq i ) ] ; linarith [ abs_le.mp ( Finset.single_le_sum ( fun i _ => abs_nonneg ( p i - q i ) ) ( Finset.mem_univ i ) ) ] ) );
  · -- From Step 3, we have 0 < PA < 1 and 0 < QA < 1.
    have hPA : 0 < ∑ i ∈ A, p i ∧ ∑ i ∈ A, p i < 1 := by
      have hPA_pos : 0 < ∑ i ∈ A, p i := by
        refine' Finset.sum_pos ( fun i hi => hp i ) _;
        contrapose! h; simp_all +decide [ Finset.ext_iff ] ;
        exact absurd ( Finset.sum_lt_sum_of_nonempty ( Finset.univ_nonempty_iff.mpr ⟨ Classical.choose ( show ∃ i, True from by
                                                                                                          cases isEmpty_or_nonempty ι <;> aesop ) ⟩ ) fun i _ => show p i < q i from lt_of_not_ge fun hi => h i <| Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hi ⟩ ) ( by simp +decide [ * ] )
      have hPA_lt_one : ∑ i ∈ A, p i < 1 := by
        have hPA_lt_one : ∑ i ∈ Ac, p i > 0 := by
          by_cases hAc_empty : Ac = ∅;
          · simp_all +decide [ Finset.ext_iff ];
            exact False.elim ( h ( Finset.sum_eq_zero fun i _ => abs_eq_zero.mpr ( sub_eq_zero.mpr ( le_antisymm ( by simpa [ * ] using Finset.single_le_sum ( fun a _ => sub_nonneg.mpr ( hAc a ) ) ( Finset.mem_univ i ) ) ( hAc i ) ) ) ) );
          · exact Finset.sum_pos ( fun i hi => hp i ) ( Finset.nonempty_of_ne_empty hAc_empty );
        have hPA_lt_one : ∑ i ∈ A, p i + ∑ i ∈ Ac, p i = 1 := by
          rw [ ← hps, Finset.sum_filter_add_sum_filter_not ];
        linarith
      exact ⟨hPA_pos, hPA_lt_one⟩
    have hQA : 0 < ∑ i ∈ A, q i ∧ ∑ i ∈ A, q i < 1 := by
      refine' ⟨ Finset.sum_pos ( fun i hi => hq i ) _, _ ⟩;
      · exact Finset.nonempty_of_ne_empty fun h' => by simp_all +decide ;
      · exact lt_of_le_of_lt ( Finset.sum_le_sum fun i hi => Finset.mem_filter.mp hi |>.2 ) hPA.2;
    -- From Step 4, we have klDiv p q ≥ klBer PA QA.
    have hklDiv_ge_klBer : klDiv p q ≥ klBer (∑ i ∈ A, p i) (∑ i ∈ A, q i) := by
      have hklDiv_ge_klBer : klDiv p q ≥ (∑ i ∈ A, p i) * Real.log ((∑ i ∈ A, p i) / (∑ i ∈ A, q i)) + (∑ i ∈ Ac, p i) * Real.log ((∑ i ∈ Ac, p i) / (∑ i ∈ Ac, q i)) := by
        have hklDiv_ge_klBer : (∑ i ∈ A, p i) * Real.log ((∑ i ∈ A, p i) / (∑ i ∈ A, q i)) ≤ ∑ i ∈ A, p i * Real.log (p i / q i) := by
          apply log_sum_ineq A p q (fun i hi => le_of_lt (hp i)) (fun i hi => hq i) hPA.left;
        have hklDiv_ge_klBer_Ac : (∑ i ∈ Ac, p i) * Real.log ((∑ i ∈ Ac, p i) / (∑ i ∈ Ac, q i)) ≤ ∑ i ∈ Ac, p i * Real.log (p i / q i) := by
          apply log_sum_ineq Ac p q (fun i hi => le_of_lt (hp i)) (fun i hi => hq i) (by
          contrapose! h;
          exact absurd h ( not_le_of_gt ( Finset.sum_pos ( fun i hi => hp i ) ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) ) ));
        refine' le_trans ( add_le_add hklDiv_ge_klBer hklDiv_ge_klBer_Ac ) _;
        rw [ Finset.sum_filter_add_sum_filter_not ];
        rfl;
      convert hklDiv_ge_klBer using 1;
      simp +decide [ klBer ];
      rw [ show ∑ i ∈ Ac, p i = 1 - ∑ i ∈ A, p i from eq_sub_of_add_eq' <| by rw [ ← hps, Finset.sum_filter_add_sum_filter_not ], show ∑ i ∈ Ac, q i = 1 - ∑ i ∈ A, q i from eq_sub_of_add_eq' <| by rw [ ← hqs, Finset.sum_filter_add_sum_filter_not ] ];
    -- From Step 5, we have klBer PA QA ≥ 2*(PA - QA)^2.
    have hklBer_ge_2PAQA : klBer (∑ i ∈ A, p i) (∑ i ∈ A, q i) ≥ 2 * ((∑ i ∈ A, p i) - (∑ i ∈ A, q i)) ^ 2 := by
      exact bernoulli_pinsker hPA.1 hPA.2 hQA.1 hQA.2;
    -- From Step 1, we have ∑ i, |p i - q i| = 2 * (PA - QA).
    have hsum_abs : ∑ i, |p i - q i| = 2 * ((∑ i ∈ A, p i) - (∑ i ∈ A, q i)) := by
      have hsum_abs : ∑ i, |p i - q i| = ∑ i ∈ A, (p i - q i) + ∑ i ∈ Ac, (q i - p i) := by
        rw [ Finset.sum_filter, Finset.sum_filter ] ; rw [ ← Finset.sum_add_distrib ] ; congr ; ext i ; split_ifs <;> cases abs_cases ( p i - q i ) <;> linarith;
      simp_all +decide;
      have hsum_abs : ∑ i ∈ A, p i + ∑ i ∈ Ac, p i = 1 ∧ ∑ i ∈ A, q i + ∑ i ∈ Ac, q i = 1 := by
        exact ⟨ by rw [ ← hps, Finset.sum_filter_add_sum_filter_not ], by rw [ ← hqs, Finset.sum_filter_add_sum_filter_not ] ⟩;
      grind;
    rw [ hsum_abs ] ; linarith

end PinskerInequality

end