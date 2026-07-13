/-
# The `Lᵖ` relaxation of the KNRS conjecture: the single-edge threshold is sharp

## Background

A *graphon* is a symmetric measurable kernel `W : [0,1]² → [0,1]`.  It is
*ρ-locally dense* if every measurable set `S` spans density at least `ρ`, i.e.
`∫_{S×S} W ≥ ρ · |S|²`.  The Kohayakawa–Nagle–Rödl–Schacht (KNRS) conjecture
(2010) predicts that ρ-locally dense host graphs contain at least the "random"
count `ρ^{e(F)}` of copies of any fixed graph `F`.

An `Lᵖ` *relaxation* asks the weaker/stronger question of whether the `Lᵖ` norm
of the `F`-density kernel can dip below `ρ^{e(F)}`.  The mathematical framing of
this mission is the claim:

> For a graph `F` with `m` edges and `n` non-isolated vertices, if
> `p < C(n,2)/m`, there is a ρ-locally dense graphon `W` with
> `‖W_F‖_{Lᵖ} < ρ^{e(F)}`.

## What this file establishes (the single-edge case)

We work in the finite (step-graphon / weighted-graph) model on `Fin N` with the
uniform measure — this is the standard discretization of graphons and keeps every
integral a finite sum, so the statements are completely rigorous.

For the single edge `F = K₂` we have `n = 2`, `m = 1`, `e(F) = 1` and the claimed
threshold is `C(2,2)/1 = 1`.  We prove that this threshold is **exactly sharp**:

* `edgeLp_ge_rho` : for `p ≥ 1`, **no** counterexample exists — every ρ-locally
  dense nonnegative kernel satisfies `‖W‖_{Lᵖ} ≥ ρ`.  (Power-mean inequality.)
* `blockW_edgeLp_lt` : for `0 < p < 1`, a counterexample **does** exist — the
  explicit two-block kernel `blockW ρ` (value `2ρ` on the diagonal blocks, `0`
  off-diagonal) is ρ-locally dense, takes values in `[0,1]`, yet has
  `‖W‖_{Lᵖ} < ρ`.

Hence for the single edge the conjecture is true and its threshold `p < 1` is
sharp.  (In `MatchingDisproof.lean` we show that the *literal* `C(n,2)/m` formula
is nevertheless false for larger `F`, e.g. the 2-edge matching.)

This file is self-contained: it only imports `Mathlib`.
-/
import Mathlib

open scoped BigOperators

namespace LpKNRS

/-- A finite symmetric weight kernel `W : Fin N → Fin N → ℝ` (a step graphon on
`N` equal blocks) is **ρ-locally dense** if every subset `S` of the `N` blocks
spans total weight at least `ρ · |S|²`. -/
def LocallyDense (N : ℕ) (W : Fin N → Fin N → ℝ) (ρ : ℝ) : Prop :=
  ∀ S : Finset (Fin N), ρ * (S.card : ℝ) ^ 2 ≤ ∑ i ∈ S, ∑ j ∈ S, W i j

/-- `‖W_{K₂}‖_{Lᵖ}` to the power `p`: the uniform average of `Wᵖ` over all pairs.
This is exactly `(1/N²)·∑_{i,j} W(i,j)ᵖ`, the discrete `Lᵖ`-norm-to-the-`p` of the
edge kernel. -/
noncomputable def edgeLpPow (N : ℕ) (W : Fin N → Fin N → ℝ) (p : ℝ) : ℝ :=
  (1 / (N : ℝ) ^ 2) * ∑ q : Fin N × Fin N, (W q.1 q.2) ^ p

/-- `‖W_{K₂}‖_{Lᵖ}` : the discrete `Lᵖ` norm of the single-edge kernel. -/
noncomputable def edgeLp (N : ℕ) (W : Fin N → Fin N → ℝ) (p : ℝ) : ℝ :=
  (edgeLpPow N W p) ^ (1 / p)

theorem edgeLpPow_nonneg {N : ℕ} {W : Fin N → Fin N → ℝ} {p : ℝ}
    (hW : ∀ i j, 0 ≤ W i j) : 0 ≤ edgeLpPow N W p := by
  rw [edgeLpPow]
  apply mul_nonneg (by positivity)
  apply Finset.sum_nonneg
  intro q _
  exact Real.rpow_nonneg (hW q.1 q.2) p

/-- **No counterexample for `p ≥ 1` (single edge).**
For every `p ≥ 1`, every nonnegative ρ-locally dense kernel `W` has
`‖W_{K₂}‖_{Lᵖ} ≥ ρ`.  In particular the `Lᵖ` relaxation of KNRS *cannot* fail for
the single edge once `p ≥ 1 = C(2,2)/1`.

Proof: local density on the whole vertex set gives `ρ ≤ average of W`, and the
power-mean inequality gives `average of W ≤ (average of Wᵖ)^{1/p} = ‖W‖_{Lᵖ}`. -/
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

/-! ## The explicit counterexample for `p < 1`

The two-block kernel on `Fin 2`: value `2ρ` on the two diagonal blocks and `0`
off-diagonal. -/

/-- Two-block counterexample kernel: `2ρ` on the diagonal, `0` off-diagonal. -/
def blockW (ρ : ℝ) : Fin 2 → Fin 2 → ℝ := fun i j => if i = j then 2 * ρ else 0

/-- `blockW ρ` is a genuine graphon: all its values lie in `[0,1]`, provided
`0 ≤ ρ` and `2ρ ≤ 1`. -/
theorem blockW_mem_Icc {ρ : ℝ} (hρ : 0 ≤ ρ) (hρ1 : 2 * ρ ≤ 1) (i j : Fin 2) :
    0 ≤ blockW ρ i j ∧ blockW ρ i j ≤ 1 := by
  unfold blockW
  split
  · exact ⟨by linarith, by linarith⟩
  · exact ⟨by norm_num, by norm_num⟩

/-- `blockW ρ` is ρ-locally dense. -/
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

/-- The `Lᵖ`-power of the two-block kernel: `(1/2)·(2ρ)ᵖ`. -/
theorem blockW_edgeLpPow {ρ p : ℝ} (hp0 : 0 < p) :
    edgeLpPow 2 (blockW ρ) p = (1 / 2) * (2 * ρ) ^ p := by
  rw [edgeLpPow, Fintype.sum_prod_type, Fin.sum_univ_two, Fin.sum_univ_two,
      Fin.sum_univ_two]
  simp only [blockW]; norm_num
  rw [Real.zero_rpow (ne_of_gt hp0)]; ring

/-- **Counterexample for `0 < p < 1` (single edge).**
The two-block graphon `blockW ρ` is ρ-locally dense, takes values in `[0,1]`, yet
`‖W_{K₂}‖_{Lᵖ} < ρ = ρ^{e(K₂)}`.  So below the threshold the `Lᵖ` relaxation of
KNRS genuinely fails for the single edge. -/
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

/-- **The single-edge threshold is sharp.**  Combining the two directions:
for `0 < ρ` with `2ρ ≤ 1`,

* for every `p ≥ 1` there is *no* ρ-locally dense counterexample, while
* for every `0 < p < 1` the explicit `blockW ρ` *is* a ρ-locally dense
  counterexample.

Thus the exact threshold for the single edge is `p = 1 = C(2,2)/1`. -/
theorem single_edge_threshold_sharp {ρ : ℝ} (hρ : 0 < ρ) (hρ1 : 2 * ρ ≤ 1) :
    (∀ (p : ℝ), 1 ≤ p → ∀ {N : ℕ}, 0 < N → ∀ {W : Fin N → Fin N → ℝ},
        (∀ i j, 0 ≤ W i j) → LocallyDense N W ρ → ρ ≤ edgeLp N W p) ∧
    (∀ (p : ℝ), 0 < p → p < 1 →
        LocallyDense 2 (blockW ρ) ρ ∧
        (∀ i j, 0 ≤ blockW ρ i j ∧ blockW ρ i j ≤ 1) ∧
        edgeLp 2 (blockW ρ) p < ρ) := by
  refine ⟨?_, ?_⟩
  · intro p hp N hN W hW hld
    exact edgeLp_ge_rho hN hW hp hld
  · intro p hp0 hp1
    exact ⟨blockW_locallyDense hρ.le, blockW_mem_Icc hρ.le hρ1,
      blockW_edgeLp_lt hρ hp0 hp1⟩

end LpKNRS