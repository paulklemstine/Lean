import Cryptography.ResidueDial.Core

/-!
# Multi-symbol dials: the hierarchy of caps `2r/(r+1)`

A binary dial splits the class space into two blocks (kept / rejected) and is
capped at `4/3`.  An `r`-symbol dial splits it into `r` blocks, scanned in some
order; the scan pays, for a target in the `i`-th block, everything up to and
including that block.  Its normalised cost is

  `prefixCost θ = Σ_i θ_i (θ_1 + … + θ_i)`.

Three facts are proved here.

* `two_mul_prefixCost` — the **order-free identity**
  `2 · prefixCost θ = (Σ θ)² + Σ θ²`.  In particular the cost does not depend on
  the order in which the blocks are scanned (`prefixCost_comp_perm`): there is
  no clever ordering to find, contrary to what one might expect from a
  rearrangement heuristic.
* `multiSpeedup_le_cap` — the **cap hierarchy**: for a dial with `r` blocks,
  `Speedup ≤ 2r/(r+1)`, attained exactly at uniform blocks
  (`multiSpeedup_uniform`).  At `r = 2` this is the `4/3` of `Core.lean`
  (`prefixCost_two_eq_dialCost`, `cap_two_eq_four_thirds`).
* `cap_lt_two`, `cap_tendsto_two` — the hierarchy is strictly below `2` and
  converges to it: the asked barrier `2` is the `r → ∞` limit of the
  multi-symbol caps, never a value.
-/

namespace ResidueDial

open Finset

/-- Normalised cost of a scan through `r` blocks of densities `θ`: a target in
block `i` costs the total density of blocks `1 … i`. -/
noncomputable def prefixCost {r : ℕ} (θ : Fin r → ℝ) : ℝ :=
  ∑ i, θ i * ∑ j ∈ univ.filter (fun j => j ≤ i), θ j

/-- Speedup of an `r`-block dial. -/
noncomputable def multiSpeedup {r : ℕ} (θ : Fin r → ℝ) : ℝ := 1 / prefixCost θ

/-- **The order-free identity.**  `2·prefixCost = (Σθ)² + Σθ²`. -/
theorem two_mul_prefixCost {r : ℕ} (θ : Fin r → ℝ) :
    2 * prefixCost θ = (∑ i, θ i) ^ 2 + ∑ i, (θ i) ^ 2 := by
  classical
  have hP : prefixCost θ = ∑ i, ∑ j, (if j ≤ i then θ i * θ j else 0) := by
    unfold prefixCost
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Finset.mul_sum, Finset.sum_filter]
  have hQ : ∑ i, ∑ j, (if i ≤ j then θ i * θ j else 0) = prefixCost θ := by
    rw [Finset.sum_comm, hP]
    refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
    by_cases h : j ≤ i <;> simp [h, mul_comm]
  have hpoint : ∀ i j : Fin r,
      (if j ≤ i then θ i * θ j else 0) + (if i ≤ j then θ i * θ j else 0)
        = θ i * θ j + (if i = j then θ i * θ j else 0) := by
    intro i j
    rcases lt_trichotomy i j with h | h | h
    · simp [not_le.mpr h, le_of_lt h, ne_of_lt h]
    · subst h; simp
    · simp [not_le.mpr h, le_of_lt h, ne_of_gt h]
  have hsum : 2 * prefixCost θ
      = ∑ i, ∑ j, (θ i * θ j + (if i = j then θ i * θ j else 0)) := by
    rw [two_mul]
    nth_rewrite 1 [hP]
    nth_rewrite 1 [← hQ]
    rw [← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun j _ => by linarith [hpoint i j]
  rw [hsum]
  have hinner : ∀ i : Fin r, ∑ j, (θ i * θ j + if i = j then θ i * θ j else 0)
      = θ i * (∑ j, θ j) + θ i ^ 2 := by
    intro i
    rw [Finset.sum_add_distrib, ← Finset.mul_sum,
      Finset.sum_ite_eq (univ : Finset (Fin r)) i (fun j => θ i * θ j)]
    simp [sq]
  rw [Finset.sum_congr rfl (fun i _ => hinner i), Finset.sum_add_distrib, ← Finset.sum_mul]
  ring

/-- The cost depends on the block densities only through `Σθ` and `Σθ²`, hence
is invariant under reordering the blocks: no scan order is better than
another. -/
theorem prefixCost_comp_perm {r : ℕ} (θ : Fin r → ℝ) (σ : Equiv.Perm (Fin r)) :
    prefixCost (θ ∘ σ) = prefixCost θ := by
  have h1 := two_mul_prefixCost (θ ∘ σ)
  have h2 := two_mul_prefixCost θ
  have hs : ∑ i, (θ ∘ σ) i = ∑ i, θ i := Equiv.sum_comp σ θ
  have hq : ∑ i, ((θ ∘ σ) i) ^ 2 = ∑ i, (θ i) ^ 2 := Equiv.sum_comp σ (fun x => (θ x) ^ 2)
  rw [hs, hq] at h1
  linarith

/-- With total density `1`, the cost is `(1 + Σθ²)/2`. -/
theorem prefixCost_of_sum_one {r : ℕ} {θ : Fin r → ℝ} (h : ∑ i, θ i = 1) :
    prefixCost θ = (1 + ∑ i, (θ i) ^ 2) / 2 := by
  have := two_mul_prefixCost θ
  rw [h] at this
  linarith

/-- **The cap hierarchy, cost form.**  An `r`-block dial cannot cost less than
`(r+1)/(2r)`. -/
theorem prefixCost_ge {r : ℕ} {θ : Fin r → ℝ} (hr : 0 < r) (h : ∑ i, θ i = 1) :
    ((r : ℝ) + 1) / (2 * r) ≤ prefixCost θ := by
  have hrR : (0:ℝ) < r := by exact_mod_cast hr
  have hcs : (∑ i, θ i) ^ 2 ≤ (r : ℝ) * ∑ i, (θ i) ^ 2 := by
    have := sq_sum_le_card_mul_sum_sq (s := (univ : Finset (Fin r))) (f := θ)
    simpa using this
  rw [h] at hcs
  have hq : (1:ℝ) / r ≤ ∑ i, (θ i) ^ 2 := by
    rw [div_le_iff₀ hrR]
    nlinarith
  rw [prefixCost_of_sum_one h, le_div_iff₀ (by norm_num : (0:ℝ) < 2), div_mul_eq_mul_div,
    div_le_iff₀ (by linarith : (0:ℝ) < 2 * r)]
  nlinarith

/-- **The cap hierarchy.**  An `r`-symbol dial buys at most `2r/(r+1)`. -/
theorem multiSpeedup_le_cap {r : ℕ} {θ : Fin r → ℝ} (hr : 0 < r) (h : ∑ i, θ i = 1) :
    multiSpeedup θ ≤ 2 * r / ((r : ℝ) + 1) := by
  have hrR : (0:ℝ) < r := by exact_mod_cast hr
  have hlow := prefixCost_ge hr h
  have hpos : 0 < prefixCost θ := lt_of_lt_of_le (by positivity) hlow
  have h2r : (0:ℝ) < 2 * r := by linarith
  have heq : 2 * (r:ℝ) * (((r:ℝ) + 1) / (2 * r)) = (r:ℝ) + 1 := by field_simp
  have h3 := mul_le_mul_of_nonneg_left hlow (le_of_lt h2r)
  rw [heq] at h3
  rw [multiSpeedup, div_le_div_iff₀ hpos (by linarith)]
  linarith

/-- Uniform blocks attain the cap exactly. -/
theorem multiSpeedup_uniform {r : ℕ} (hr : 0 < r) :
    multiSpeedup (fun _ : Fin r => (1 : ℝ) / r) = 2 * r / ((r : ℝ) + 1) := by
  have hrR : (0:ℝ) < r := by exact_mod_cast hr
  have hsum : ∑ _i : Fin r, (1 : ℝ) / r = 1 := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  have hsq : ∑ _i : Fin r, ((1 : ℝ) / r) ^ 2 = 1 / r := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  have hcost : prefixCost (fun _ : Fin r => (1 : ℝ) / r) = ((r : ℝ) + 1) / (2 * r) := by
    rw [prefixCost_of_sum_one hsum, hsq]
    field_simp
  rw [multiSpeedup, hcost, one_div_div]

/-- At `r = 2` the multi-symbol cost is exactly the binary law of `Core.lean`. -/
theorem prefixCost_two_eq_dialCost (t : ℝ) :
    prefixCost ![t, 1 - t] = dialCost t := by
  classical
  have h0 : (univ.filter (fun j : Fin 2 => j ≤ 0)) = {0} := by decide
  have h1 : (univ.filter (fun j : Fin 2 => j ≤ 1)) = {0, 1} := by decide
  rw [prefixCost, Fin.sum_univ_two, h0, h1, dialCost]
  simp
  ring

/-- …and the `r = 2` cap is the familiar `4/3`. -/
theorem cap_two_eq_four_thirds : 2 * (2 : ℝ) / ((2 : ℝ) + 1) = 4 / 3 := by norm_num

/-- The whole hierarchy stays strictly below the asked barrier `2`. -/
theorem cap_lt_two {r : ℕ} (hr : 0 < r) : 2 * (r : ℝ) / ((r : ℝ) + 1) < 2 := by
  have hrR : (0:ℝ) < r := by exact_mod_cast hr
  rw [div_lt_iff₀ (by linarith)]
  linarith

/-! ## Boundary: what would break the cap

The cap `2r/(r+1)` — and with it the `4/3` of `Core.lean` — is a statement about
*single-pass scans*: the dial reorders the blocks, but a block once scheduled is
paid for.  If instead the dial's answer lets the algorithm **skip** the blocks it
has ruled out, the cost is `Σ θ²` and the cap disappears: a balanced `r`-symbol
full reveal buys exactly `r`.  This is the precise boundary of the converse, and
it is where the barrier-`2` framing of the binary case comes from
(`revealSpeedup_binary_half`). -/

/-- Cost of a *full-reveal* dial: the answer names the target's block and the
algorithm scans that block only. -/
noncomputable def revealCost {r : ℕ} (θ : Fin r → ℝ) : ℝ := ∑ i, (θ i) ^ 2

/-- Full reveal is never worse than a single-pass scan. -/
theorem revealCost_le_prefixCost {r : ℕ} {θ : Fin r → ℝ} (hnn : ∀ i, 0 ≤ θ i)
    (h : ∑ i, θ i = 1) : revealCost θ ≤ prefixCost θ := by
  have hs : ∑ i, (θ i) ^ 2 ≤ (∑ i, θ i) ^ 2 :=
    Finset.sum_sq_le_sq_sum_of_nonneg fun i _ => hnn i
  rw [h, one_pow] at hs
  rw [revealCost, prefixCost_of_sum_one h]
  linarith

/-- A balanced `r`-symbol full reveal buys exactly `r`: without the single-pass
restriction there is no universal cap at all. -/
theorem revealSpeedup_uniform {r : ℕ} (hr : 0 < r) :
    1 / revealCost (fun _ : Fin r => (1 : ℝ) / r) = r := by
  have hrR : (0:ℝ) < r := by exact_mod_cast hr
  have hsq : revealCost (fun _ : Fin r => (1 : ℝ) / r) = 1 / r := by
    rw [revealCost, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    field_simp
  rw [hsq, one_div_one_div]

/-- In the binary case full reveal gives exactly the asked barrier `2` — the
source of the `4/3`-versus-`2` discrepancy, now located precisely in the
skip-versus-no-skip modelling choice. -/
theorem revealSpeedup_binary_half :
    1 / revealCost (fun _ : Fin 2 => (1 : ℝ) / 2) = 2 := by
  have := revealSpeedup_uniform (r := 2) (by norm_num)
  simpa using this

/-- …and converges to it: `2` is the limit of the multi-symbol caps, attained by
no dial with finitely many symbols. -/
theorem cap_tendsto_two :
    Filter.Tendsto (fun r : ℕ => 2 * (r : ℝ) / ((r : ℝ) + 1)) Filter.atTop (nhds 2) := by
  have h : ∀ r : ℕ, 2 * (r : ℝ) / ((r : ℝ) + 1) = 2 - 2 / ((r : ℝ) + 1) := by
    intro r
    have hr : ((r : ℝ) + 1) ≠ 0 := by positivity
    field_simp
    ring
  simp only [h]
  have h0 : Filter.Tendsto (fun r : ℕ => 1 / ((r : ℝ) + 1)) Filter.atTop (nhds 0) :=
    tendsto_one_div_add_atTop_nhds_zero_nat
  have h2 : Filter.Tendsto (fun r : ℕ => 2 / ((r : ℝ) + 1)) Filter.atTop (nhds 0) := by
    have := h0.const_mul (2:ℝ)
    simpa [mul_one_div] using this
  simpa using (tendsto_const_nhds (x := (2:ℝ)) (f := Filter.atTop (α := ℕ))).sub h2

end ResidueDial