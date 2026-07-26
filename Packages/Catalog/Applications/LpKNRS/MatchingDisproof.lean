/-
# The literal `C(n,2)/m` threshold of the KNRS `Lᵖ` relaxation is FALSE

## The claim under scrutiny

> For a graph `F` with `m` edges and `n` non-isolated vertices, if
> `p < C(n,2)/m`, there is a ρ-locally dense graphon `W` with
> `‖W_F‖_{Lᵖ} < ρ^{e(F)}`.

## The counterexample to the claim: the 2-edge matching `M₂`

Take `F = M₂`, the matching with two disjoint edges.  Then

* `n = 4` non-isolated vertices, `m = 2` edges, `e(F) = 2`;
* the claimed threshold is `C(4,2)/2 = 6/2 = 3`.

So the claim asserts that for **every** `p < 3` there is a ρ-locally dense
counterexample.  We disprove this:

* `matching_no_counterexample` : for **every** `p ≥ 1` — in particular for
  `p = 2 < 3` — and every ρ-locally dense nonnegative graphon `W`, we have
  `‖W_{M₂}‖_{Lᵖ} ≥ ρ² = ρ^{e(M₂)}`.  No counterexample exists on the whole
  interval `1 ≤ p < 3`, contradicting the claim.

The reason is that the matching functional *factorizes* over its two independent
edges: `‖W_{M₂}‖_{Lᵖ} = ‖W_{K₂}‖_{Lᵖ}²`, and for `p ≥ 1` the single-edge norm is
`≥ ρ` (power-mean inequality).  So the correct threshold is governed by the
single edge, giving `1`, not `3`.

## Sharpness: the correct threshold for `M₂` is exactly `1`

* `matching_counterexample_below_one` : for every `0 < p < 1` the explicit
  two-block graphon `blockW ρ` *is* a ρ-locally dense counterexample for `M₂`,
  with `‖W_{M₂}‖_{Lᵖ} < ρ²`.

Hence the true threshold for `M₂` is `p = 1`, dramatically smaller than the
conjectured `C(4,2)/2 = 3`.  More generally the value `(n - c)/m` (with `c` the
number of connected components) — equal to `1` for a matching — is the natural
threshold reachable by block constructions; see `FUTURE_DIRECTIONS.md`.

This file is self-contained: it only imports `Mathlib`.
-/
import Mathlib

open scoped BigOperators

namespace LpKNRS

/-- A finite symmetric weight kernel is **ρ-locally dense** if every subset `S`
of the `N` blocks spans total weight at least `ρ · |S|²`. -/
def LocallyDense (N : ℕ) (W : Fin N → Fin N → ℝ) (ρ : ℝ) : Prop :=
  ∀ S : Finset (Fin N), ρ * (S.card : ℝ) ^ 2 ≤ ∑ i ∈ S, ∑ j ∈ S, W i j

/-- `‖W_{K₂}‖_{Lᵖ}` to the power `p`: the uniform average of `Wᵖ` over all pairs. -/
noncomputable def edgeLpPow (N : ℕ) (W : Fin N → Fin N → ℝ) (p : ℝ) : ℝ :=
  (1 / (N : ℝ) ^ 2) * ∑ q : Fin N × Fin N, (W q.1 q.2) ^ p

/-- `‖W_{K₂}‖_{Lᵖ}` : the discrete `Lᵖ` norm of the single-edge kernel. -/
noncomputable def edgeLp (N : ℕ) (W : Fin N → Fin N → ℝ) (p : ℝ) : ℝ :=
  (edgeLpPow N W p) ^ (1 / p)

/-- `‖W_{M₂}‖_{Lᵖ}` to the power `p`: the uniform average, over all four
independent vertices `a, b, c, d`, of `W(a,b)ᵖ · W(c,d)ᵖ`.  This is the genuine
homomorphism-density (to the `p`) of the 2-edge matching. -/
noncomputable def homPowM2 (N : ℕ) (W : Fin N → Fin N → ℝ) (p : ℝ) : ℝ :=
  (1 / (N : ℝ) ^ 4) * ∑ a, ∑ b, ∑ c, ∑ d, (W a b) ^ p * (W c d) ^ p

/-- `‖W_{M₂}‖_{Lᵖ}` : the discrete `Lᵖ` norm of the 2-edge-matching kernel. -/
noncomputable def homLpM2 (N : ℕ) (W : Fin N → Fin N → ℝ) (p : ℝ) : ℝ :=
  (homPowM2 N W p) ^ (1 / p)

theorem edgeLpPow_nonneg {N : ℕ} {W : Fin N → Fin N → ℝ} {p : ℝ}
    (hW : ∀ i j, 0 ≤ W i j) : 0 ≤ edgeLpPow N W p := by
  rw [edgeLpPow]
  apply mul_nonneg (by positivity)
  apply Finset.sum_nonneg
  intro q _
  exact Real.rpow_nonneg (hW q.1 q.2) p

/-- Power-mean lower bound for the single edge (see `EdgeThreshold.lean`). -/
theorem edgeLp_ge_rho {N : ℕ} (hN : 0 < N) {W : Fin N → Fin N → ℝ} {ρ p : ℝ}
    (hW : ∀ i j, 0 ≤ W i j) (hp : 1 ≤ p) (hld : LocallyDense N W ρ) :
    ρ ≤ edgeLp N W p := by
  have hN' : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hNsq : (0 : ℝ) < (N : ℝ) ^ 2 := by positivity
  have huniv := hld Finset.univ
  have hcard : ((Finset.univ : Finset (Fin N)).card : ℝ) = (N : ℝ) := by simp
  rw [hcard] at huniv
  have hsum : (∑ i, ∑ j, W i j) = ∑ q : Fin N × Fin N, W q.1 q.2 := by
    rw [Fintype.sum_prod_type]
  rw [hsum] at huniv
  set S := ∑ q : Fin N × Fin N, W q.1 q.2 with hS
  have havg : ρ ≤ (1 / (N : ℝ) ^ 2) * S := by
    have h2 : ρ ≤ S / (N : ℝ) ^ 2 := by rw [le_div_iff₀ hNsq]; linarith [huniv]
    calc ρ ≤ S / (N : ℝ) ^ 2 := h2
      _ = (1 / (N : ℝ) ^ 2) * S := by ring
  have key := Real.arith_mean_le_rpow_mean (Finset.univ : Finset (Fin N × Fin N))
      (fun _ => (1 / (N : ℝ) ^ 2)) (fun q => W q.1 q.2)
      (by intro i _; positivity)
      (by simp [Finset.card_univ]; field_simp)
      (by intro q _; exact hW q.1 q.2) hp
  have e1 : (∑ q : Fin N × Fin N, (1 / (N : ℝ) ^ 2) * W q.1 q.2)
      = (1 / (N : ℝ) ^ 2) * S := by rw [← Finset.mul_sum]
  have e2 : (∑ q : Fin N × Fin N, (1 / (N : ℝ) ^ 2) * (W q.1 q.2) ^ p)
      = edgeLpPow N W p := by rw [edgeLpPow, ← Finset.mul_sum]
  rw [e1, e2] at key
  calc ρ ≤ (1 / (N : ℝ) ^ 2) * S := havg
    _ ≤ (edgeLpPow N W p) ^ (1 / p) := key
    _ = edgeLp N W p := rfl

/-- **Factorization of the matching functional.**  `‖W_{M₂}‖_{Lᵖ}ᵖ` equals the
square of the single-edge functional `‖W_{K₂}‖_{Lᵖ}ᵖ`, because the two edges of
`M₂` use disjoint vertices. -/
theorem homPowM2_eq {N : ℕ} (W : Fin N → Fin N → ℝ) (p : ℝ) :
    homPowM2 N W p = (edgeLpPow N W p) ^ 2 := by
  rw [homPowM2, edgeLpPow, Fintype.sum_prod_type]
  have hpull : (∑ a, ∑ b, ∑ c, ∑ d, (W a b) ^ p * (W c d) ^ p)
      = (∑ a, ∑ b, (W a b) ^ p) * (∑ c, ∑ d, (W c d) ^ p) := by
    simp_rw [← Finset.mul_sum, ← Finset.sum_mul]
  rw [hpull]; ring

/-- Consequently `‖W_{M₂}‖_{Lᵖ} = ‖W_{K₂}‖_{Lᵖ}²`. -/
theorem homLpM2_eq {N : ℕ} (W : Fin N → Fin N → ℝ) {p : ℝ}
    (hW : ∀ i j, 0 ≤ W i j) : homLpM2 N W p = (edgeLp N W p) ^ 2 := by
  rw [homLpM2, homPowM2_eq, edgeLp]
  rw [← Real.rpow_natCast (edgeLpPow N W p) 2,
      ← Real.rpow_natCast ((edgeLpPow N W p) ^ (1 / p)) 2,
      ← Real.rpow_mul (edgeLpPow_nonneg hW), ← Real.rpow_mul (edgeLpPow_nonneg hW)]
  ring_nf

/-- **Disproof of the literal `C(n,2)/m` threshold.**
For the 2-edge matching `M₂` (`n = 4`, `m = 2`, `e(F) = 2`) the conjecture would
require a ρ-locally dense counterexample for every `p < C(4,2)/2 = 3`.  But for
every `p ≥ 1` (e.g. `p = 2 < 3`) and every nonnegative ρ-locally dense graphon,
`‖W_{M₂}‖_{Lᵖ} ≥ ρ²`.  Hence **no** counterexample exists on `1 ≤ p < 3`,
refuting the claim. -/
theorem matching_no_counterexample {N : ℕ} (hN : 0 < N) {W : Fin N → Fin N → ℝ}
    {ρ p : ℝ} (hρ : 0 ≤ ρ) (hW : ∀ i j, 0 ≤ W i j) (hp : 1 ≤ p)
    (hld : LocallyDense N W ρ) : ρ ^ 2 ≤ homLpM2 N W p := by
  rw [homLpM2_eq W hW]
  have h := edgeLp_ge_rho hN hW hp hld
  nlinarith [h, hρ]

/-! ## Sharpness: a genuine counterexample for `p < 1` -/

/-- Two-block counterexample kernel: `2ρ` on the diagonal, `0` off-diagonal. -/
def blockW (ρ : ℝ) : Fin 2 → Fin 2 → ℝ := fun i j => if i = j then 2 * ρ else 0

theorem blockW_mem_Icc {ρ : ℝ} (hρ : 0 ≤ ρ) (hρ1 : 2 * ρ ≤ 1) (i j : Fin 2) :
    0 ≤ blockW ρ i j ∧ blockW ρ i j ≤ 1 := by
  unfold blockW
  split
  · exact ⟨by linarith, by linarith⟩
  · exact ⟨by norm_num, by norm_num⟩

theorem blockW_locallyDense {ρ : ℝ} (hρ : 0 ≤ ρ) : LocallyDense 2 (blockW ρ) ρ := by
  intro S
  have hval : (∑ i ∈ S, ∑ j ∈ S, blockW ρ i j) = 2 * ρ * (S.card : ℝ) := by
    have hinner : ∀ i ∈ S, (∑ j ∈ S, blockW ρ i j) = 2 * ρ := by
      intro i hi
      rw [Finset.sum_eq_single i]
      · simp [blockW]
      · intro b _ hb; simp [blockW, Ne.symm hb]
      · intro hni; exact absurd hi hni
    rw [Finset.sum_congr rfl hinner]; simp [mul_comm]
  rw [hval]
  have hc0 : (0 : ℝ) ≤ (S.card : ℝ) := Nat.cast_nonneg _
  have hcard2 : (S.card : ℝ) ≤ 2 := by
    have h := Finset.card_le_univ S
    have : S.card ≤ 2 := by simpa using h
    exact_mod_cast this
  nlinarith [mul_nonneg (mul_nonneg hρ hc0) (by linarith : (0 : ℝ) ≤ 2 - (S.card : ℝ))]

theorem blockW_edgeLpPow {ρ p : ℝ} (hp0 : 0 < p) :
    edgeLpPow 2 (blockW ρ) p = (1 / 2) * (2 * ρ) ^ p := by
  rw [edgeLpPow, Fintype.sum_prod_type, Fin.sum_univ_two, Fin.sum_univ_two,
      Fin.sum_univ_two]
  simp only [blockW]; norm_num
  rw [Real.zero_rpow (ne_of_gt hp0)]; ring

theorem blockW_edgeLp_lt {ρ p : ℝ} (hρ : 0 < ρ) (hp0 : 0 < p) (hp1 : p < 1) :
    edgeLp 2 (blockW ρ) p < ρ := by
  have hpow : edgeLpPow 2 (blockW ρ) p < ρ ^ p := by
    rw [blockW_edgeLpPow hp0]
    have h2 : (2 * ρ) ^ p = 2 ^ p * ρ ^ p := Real.mul_rpow (by norm_num) hρ.le
    rw [h2]
    have hρp : (0 : ℝ) < ρ ^ p := Real.rpow_pos_of_pos hρ p
    have h2p : (2 : ℝ) ^ p < 2 := by
      have : (2 : ℝ) ^ p < 2 ^ (1 : ℝ) :=
        Real.rpow_lt_rpow_left_iff (by norm_num : (1 : ℝ) < 2) |>.mpr hp1
      simpa using this
    nlinarith [hρp, h2p]
  have hnn : (0 : ℝ) ≤ edgeLpPow 2 (blockW ρ) p := by
    rw [blockW_edgeLpPow hp0]; positivity
  have hlt := Real.rpow_lt_rpow hnn hpow (by positivity : (0 : ℝ) < 1 / p)
  have heq : (ρ ^ p) ^ (1 / p) = ρ := by
    rw [← Real.rpow_mul hρ.le, mul_one_div, div_self (ne_of_gt hp0), Real.rpow_one]
  rw [heq] at hlt
  exact hlt

/-- **Genuine counterexample for `M₂` when `0 < p < 1`.**
The two-block graphon `blockW ρ` is ρ-locally dense, takes values in `[0,1]`, and
satisfies `‖W_{M₂}‖_{Lᵖ} < ρ² = ρ^{e(M₂)}`.  Thus the correct threshold for the
2-edge matching is exactly `p = 1`, far below the conjectured `C(4,2)/2 = 3`. -/
theorem matching_counterexample_below_one {ρ p : ℝ} (hρ : 0 < ρ) (hρ1 : 2 * ρ ≤ 1)
    (hp0 : 0 < p) (hp1 : p < 1) :
    LocallyDense 2 (blockW ρ) ρ ∧
    (∀ i j, 0 ≤ blockW ρ i j ∧ blockW ρ i j ≤ 1) ∧
    homLpM2 2 (blockW ρ) p < ρ ^ 2 := by
  refine ⟨blockW_locallyDense hρ.le, fun i j => blockW_mem_Icc hρ.le hρ1 i j, ?_⟩
  have hWnn : ∀ i j, 0 ≤ blockW ρ i j := fun i j => (blockW_mem_Icc hρ.le hρ1 i j).1
  rw [homLpM2_eq (blockW ρ) hWnn]
  have hlt := blockW_edgeLp_lt hρ hp0 hp1
  have hge : (0 : ℝ) ≤ edgeLp 2 (blockW ρ) p :=
    Real.rpow_nonneg (edgeLpPow_nonneg hWnn) _
  nlinarith [hlt, hge, hρ]

end LpKNRS