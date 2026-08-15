/-
# The Spectral Free-Witness: Heat-Kernel Order Recovery

This file gives a complete, self-contained formal proof of the mechanism behind the
"heat-kernel free witness": the multiplicative order `r = ord_N(b)` is recovered
*exactly* from a **single** heat-kernel (return-probability) value of a half-lazy
random walk on the cyclic group `Z/rZ` with **lacunary dyadic** generators
`{±2^t : 0 ≤ t ≤ M}`, after `n = 8 (M+1)^2` diffusion steps, where `2^M ≥ N`.

The chain of results proved here:

* `cdist_double` — the *doubling step*: as long as the circle distance
  `d(x) = min (x % r) (r - x % r)` is below `r/4`, doubling `x` doubles `d`.
* `exists_dyadic_quarter` — the **doubling lemma**: for every `x ≢ 0 (mod r)`
  there is a dyadic shift `t ≤ M` (`r ≤ 2^M`) with `2^t x mod r ∈ [r/4, 3r/4]`.
* `cos_nonpos_of_cdist`, `dyadicEigen_le` — the resulting **spectral gap**:
  every nontrivial character eigenvalue satisfies `λ_k ≤ 1 - 1/(M+1)`, hence the
  half-lazy eigenvalue satisfies `0 ≤ μ_k ≤ 1 - 1/(2(M+1))`.
* `heatReturn_lower`, `heatReturn_upper` — the heat kernel at the identity
  satisfies `1/r ≤ p_n(e) ≤ 1/r + (1 - 1/(2(M+1)))^n`.
* `beta_pow_le` — the mixing estimate at the empirically observed step count
  `n = 8(M+1)^2`: the error is at most `1/(4N²)`.
* `round_one_div_of_close` — the rounding step.
* `heat_kernel_order_recovery` — **main theorem**: `round (1 / p_n(e)) = r`.
* `heat_kernel_recovers_orderOf` — the arithmetic corollary for the
  multiplicative order of a unit `b ∈ (Z/NZ)ˣ`.

Everything is unconditional; no `sorry`, no `native_decide`.
-/

import Mathlib

namespace SpectralFreeWitness

open Finset Real

/-! ## 1. Circle distance and the doubling lemma -/

/-- The circle distance of `x` from `0` in `Z/rZ`, i.e. `min (x mod r) (r - x mod r)`. -/
def cdist (r x : ℕ) : ℕ := min (x % r) (r - x % r)

lemma cdist_pos_of_ne (r x : ℕ) (hr : 0 < r) (hx : x % r ≠ 0) : 0 < cdist r x := by
  have h : x % r < r := Nat.mod_lt _ hr
  simp only [cdist, lt_min_iff]
  omega

/-- Two-step reduction: the residue of `2x` in terms of the residue of `x`. -/
lemma two_mul_mod (r x : ℕ) : (2 * x) % r = (2 * (x % r)) % r := by
  simp [Nat.mul_mod]

/-- **Doubling step.** While the circle distance is below `r/4`, doubling the point
doubles the circle distance. -/
lemma cdist_double (r x : ℕ) (hr : 0 < r) (h4 : 4 * cdist r x < r) :
    cdist r (2 * x) = 2 * cdist r x := by
  have hlt : x % r < r := Nat.mod_lt _ hr
  have h2 : (2 * x) % r = (2 * (x % r)) % r := two_mul_mod r x
  by_cases hc : 2 * (x % r) < r
  · rw [Nat.mod_eq_of_lt hc] at h2
    simp only [cdist] at h4 ⊢
    omega
  · have h3 : (2 * (x % r)) % r = 2 * (x % r) - r := by
      rw [Nat.mod_eq_sub_mod (by omega)]
      exact Nat.mod_eq_of_lt (by omega)
    rw [h3] at h2
    simp only [cdist] at h4 ⊢
    omega

/-- Iterated doubling, as long as we stay below the quarter threshold. -/
lemma cdist_pow_two (r x M : ℕ) (hr : 0 < r) (hx : x % r ≠ 0)
    (hstay : ∀ t ≤ M, 4 * cdist r (2 ^ t * x) < r) :
    ∀ t ≤ M, cdist r (2 ^ t * x) = 2 ^ t * cdist r x := by
  intro t
  induction t with
  | zero => intro _; simp
  | succ n ih =>
      intro hn
      have hn' : n ≤ M := by omega
      have ihn := ih hn'
      have hpos : 0 < cdist r (2 ^ n * x) := by
        rw [ihn]
        exact Nat.mul_pos (pow_pos (by norm_num) n) (cdist_pos_of_ne r x hr hx)
      have hdb := cdist_double r (2 ^ n * x) hr (hstay n hn')
      have hrw : 2 ^ (n + 1) * x = 2 * (2 ^ n * x) := by ring
      rw [hrw, hdb, ihn]
      ring

/-- **The doubling lemma.** If `x ≢ 0 (mod r)` and `r ≤ 2^M`, then some lacunary
dyadic shift `2^t x`, `t ≤ M`, lands in the "far" arc `[r/4, 3r/4]` of the circle. -/
theorem exists_dyadic_quarter (r x M : ℕ) (hr : 0 < r) (hx : x % r ≠ 0) (hM : r ≤ 2 ^ M) :
    ∃ t ≤ M, r ≤ 4 * cdist r (2 ^ t * x) := by
  by_contra hcon
  push_neg at hcon
  have hstay : ∀ t ≤ M, 4 * cdist r (2 ^ t * x) < r := fun t ht => hcon t ht
  have hM' := cdist_pow_two r x M hr hx hstay M le_rfl
  have hpos := cdist_pos_of_ne r x hr hx
  have hlast := hstay M le_rfl
  rw [hM'] at hlast
  have hbig : 4 * 2 ^ M ≤ 4 * (2 ^ M * cdist r x) :=
    Nat.mul_le_mul_left _ (Nat.le_mul_of_pos_right _ hpos)
  omega

/-! ## 2. From the doubling lemma to a negative cosine -/

/-- If `x` lies in the far arc `[r/4, 3r/4]` then the character value has
nonpositive real part. -/
lemma cos_nonpos_of_cdist (r x : ℕ) (hr : 0 < r) (h : r ≤ 4 * cdist r x) :
    Real.cos (2 * π * (x : ℝ) / r) ≤ 0 := by
  have hlt : x % r < r := Nat.mod_lt _ hr
  have h1 : r ≤ 4 * (x % r) := by
    simp only [cdist] at h; omega
  have h2 : 4 * (x % r) ≤ 3 * r := by
    simp only [cdist] at h; omega
  have hx : (x : ℝ) = ((x % r : ℕ) : ℝ) + (r : ℝ) * ((x / r : ℕ) : ℝ) := by
    have hd : r * (x / r) + x % r = x := Nat.div_add_mod x r
    have hc : ((r * (x / r) + x % r : ℕ) : ℝ) = ((x : ℕ) : ℝ) := by rw [hd]
    push_cast at hc
    linarith
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  have hsplit : 2 * π * (x : ℝ) / r
      = 2 * π * ((x % r : ℕ) : ℝ) / r + ((x / r : ℕ) : ℝ) * (2 * π) := by
    rw [hx]; field_simp
  rw [hsplit, Real.cos_add_nat_mul_two_pi]
  have hpi := Real.pi_pos
  have hc1 : π / 2 ≤ 2 * π * ((x % r : ℕ) : ℝ) / r := by
    rw [le_div_iff₀ hr0]
    have hcast : (r : ℝ) ≤ 4 * ((x % r : ℕ) : ℝ) := by exact_mod_cast h1
    nlinarith
  have hc2 : 2 * π * ((x % r : ℕ) : ℝ) / r ≤ π + π / 2 := by
    rw [div_le_iff₀ hr0]
    have hcast : 4 * ((x % r : ℕ) : ℝ) ≤ 3 * (r : ℝ) := by exact_mod_cast h2
    nlinarith
  exact Real.cos_nonpos_of_pi_div_two_le_of_le hc1 hc2

/-! ## 3. Spectral data of the lacunary dyadic walk -/

/-- The character eigenvalue of the (non-lazy) lacunary dyadic walk on `Z/rZ`:
`λ_k = (1/(M+1)) ∑_{t=0}^{M} cos(2π k 2^t / r)`. -/
noncomputable def dyadicEigen (r M k : ℕ) : ℝ :=
  (∑ t ∈ range (M + 1), Real.cos (2 * π * ((k * 2 ^ t : ℕ) : ℝ) / r)) / (M + 1)

/-- The eigenvalue of the half-lazy walk `W = (I + P)/2`. -/
noncomputable def lazyEigen (r M k : ℕ) : ℝ := (1 + dyadicEigen r M k) / 2

/-- The heat kernel of the half-lazy walk at the identity after `n` steps,
`p_n(e) = (1/r) ∑_k μ_k^n`. -/
noncomputable def heatReturn (r M n : ℕ) : ℝ :=
  (∑ k ∈ range r, (lazyEigen r M k) ^ n) / r

lemma dyadicEigen_le_one (r M k : ℕ) : dyadicEigen r M k ≤ 1 := by
  have hsum : ∑ t ∈ range (M + 1), Real.cos (2 * π * ((k * 2 ^ t : ℕ) : ℝ) / r)
      ≤ (M : ℝ) + 1 := by
    calc ∑ t ∈ range (M + 1), Real.cos (2 * π * ((k * 2 ^ t : ℕ) : ℝ) / r)
        ≤ ∑ _t ∈ range (M + 1), (1 : ℝ) := Finset.sum_le_sum (fun i _ => Real.cos_le_one _)
      _ = (M : ℝ) + 1 := by simp
  have hpos : (0 : ℝ) < (M : ℝ) + 1 := by positivity
  rw [dyadicEigen, div_le_one hpos]
  exact hsum

lemma neg_one_le_dyadicEigen (r M k : ℕ) : -1 ≤ dyadicEigen r M k := by
  have hsum : -((M : ℝ) + 1)
      ≤ ∑ t ∈ range (M + 1), Real.cos (2 * π * ((k * 2 ^ t : ℕ) : ℝ) / r) := by
    calc -((M : ℝ) + 1) = ∑ _t ∈ range (M + 1), (-1 : ℝ) := by simp
      _ ≤ _ := Finset.sum_le_sum (fun i _ => Real.neg_one_le_cos _)
  have hpos : (0 : ℝ) < (M : ℝ) + 1 := by positivity
  rw [dyadicEigen, le_div_iff₀ hpos]
  linarith

/-- **Spectral gap.** For every nontrivial character `k ≢ 0 (mod r)` the dyadic
eigenvalue is at most `1 - 1/(M+1)`. -/
theorem dyadicEigen_le (r M k : ℕ) (hr : 0 < r) (hk : k % r ≠ 0) (hM : r ≤ 2 ^ M) :
    dyadicEigen r M k ≤ 1 - 1 / ((M : ℝ) + 1) := by
  obtain ⟨t₀, ht₀, hfar⟩ := exists_dyadic_quarter r k M hr hk hM
  have hmem : t₀ ∈ range (M + 1) := mem_range.mpr (by omega)
  set f : ℕ → ℝ := fun t => Real.cos (2 * π * ((k * 2 ^ t : ℕ) : ℝ) / r) with hf
  have hft₀ : f t₀ ≤ 0 := by
    have hcomm : (k * 2 ^ t₀ : ℕ) = 2 ^ t₀ * k := by ring
    have := cos_nonpos_of_cdist r (2 ^ t₀ * k) hr hfar
    rw [hf]
    simpa [hcomm] using this
  have hsplit : ∑ t ∈ range (M + 1), f t = f t₀ + ∑ t ∈ (range (M + 1)).erase t₀, f t :=
    (Finset.add_sum_erase _ _ hmem).symm
  have hrest : ∑ t ∈ (range (M + 1)).erase t₀, f t ≤ (M : ℝ) := by
    calc ∑ t ∈ (range (M + 1)).erase t₀, f t ≤ ∑ _t ∈ (range (M + 1)).erase t₀, (1 : ℝ) :=
          Finset.sum_le_sum (fun i _ => Real.cos_le_one _)
      _ = (((range (M + 1)).erase t₀).card : ℝ) := by simp
      _ = (M : ℝ) := by
          rw [Finset.card_erase_of_mem hmem, card_range, Nat.add_sub_cancel]
  have hsum : ∑ t ∈ range (M + 1), f t ≤ (M : ℝ) := by rw [hsplit]; linarith
  have hpos : (0 : ℝ) < (M : ℝ) + 1 := by positivity
  rw [dyadicEigen, div_le_iff₀ hpos]
  have hrhs : (1 - 1 / ((M : ℝ) + 1)) * ((M : ℝ) + 1) = (M : ℝ) := by
    field_simp
    ring
  rw [hrhs]
  exact hsum

lemma lazyEigen_nonneg (r M k : ℕ) : 0 ≤ lazyEigen r M k := by
  have := neg_one_le_dyadicEigen r M k
  rw [lazyEigen]; linarith

lemma lazyEigen_le_one (r M k : ℕ) : lazyEigen r M k ≤ 1 := by
  have := dyadicEigen_le_one r M k
  rw [lazyEigen]; linarith

/-- The half-lazy spectral gap: `μ_k ≤ 1 - 1/(2(M+1))` for `k ≢ 0`. -/
theorem lazyEigen_le (r M k : ℕ) (hr : 0 < r) (hk : k % r ≠ 0) (hM : r ≤ 2 ^ M) :
    lazyEigen r M k ≤ 1 - 1 / (2 * ((M : ℝ) + 1)) := by
  have h := dyadicEigen_le r M k hr hk hM
  have hkey : 1 / (2 * ((M : ℝ) + 1)) = (1 / ((M : ℝ) + 1)) / 2 := by
    rw [div_div, mul_comm]
  rw [lazyEigen, hkey]
  linarith

/-- The trivial character has eigenvalue `1`. -/
lemma lazyEigen_zero (r M : ℕ) : lazyEigen r M 0 = 1 := by
  have hcos : ∀ t ∈ range (M + 1), Real.cos (2 * π * ((0 * 2 ^ t : ℕ) : ℝ) / r) = 1 := by
    intro t _; norm_num
  have hpos : (0 : ℝ) < (M : ℝ) + 1 := by positivity
  have hd : dyadicEigen r M 0 = 1 := by
    rw [dyadicEigen, Finset.sum_congr rfl hcos]
    simp only [Finset.sum_const, card_range, nsmul_eq_mul, mul_one]
    rw [show ((M + 1 : ℕ) : ℝ) = (M : ℝ) + 1 by push_cast; ring]
    field_simp
  rw [lazyEigen, hd]
  norm_num

/-! ## 4. The heat kernel value at the identity -/

lemma heatReturn_lower (r M n : ℕ) (hr : 0 < r) : 1 / (r : ℝ) ≤ heatReturn r M n := by
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  have hmem : 0 ∈ range r := mem_range.mpr hr
  have hsplit : ∑ k ∈ range r, (lazyEigen r M k) ^ n
      = (lazyEigen r M 0) ^ n + ∑ k ∈ (range r).erase 0, (lazyEigen r M k) ^ n :=
    (Finset.add_sum_erase _ _ hmem).symm
  have hrest : 0 ≤ ∑ k ∈ (range r).erase 0, (lazyEigen r M k) ^ n :=
    Finset.sum_nonneg (fun i _ => pow_nonneg (lazyEigen_nonneg _ _ _) _)
  rw [heatReturn, le_div_iff₀ hr0, hsplit, lazyEigen_zero r M]
  simp only [one_pow]
  have hcancel : 1 / (r : ℝ) * r = 1 := by field_simp
  rw [hcancel]
  linarith

/-- The heat kernel exceeds `1/r` by at most `(1 - 1/(2(M+1)))^n`. -/
theorem heatReturn_upper (r M n : ℕ) (hr : 0 < r) (hM : r ≤ 2 ^ M) :
    heatReturn r M n ≤ 1 / (r : ℝ) + (1 - 1 / (2 * ((M : ℝ) + 1))) ^ n := by
  set β : ℝ := 1 - 1 / (2 * ((M : ℝ) + 1)) with hβ
  have hMpos : (0 : ℝ) < (M : ℝ) + 1 := by positivity
  have hβ0 : 0 ≤ β := by
    rw [hβ]
    have : 1 / (2 * ((M : ℝ) + 1)) ≤ 1 := by
      rw [div_le_one (by positivity)]
      nlinarith
    linarith
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  have hmem : 0 ∈ range r := mem_range.mpr hr
  have hsplit : ∑ k ∈ range r, (lazyEigen r M k) ^ n
      = (lazyEigen r M 0) ^ n + ∑ k ∈ (range r).erase 0, (lazyEigen r M k) ^ n :=
    (Finset.add_sum_erase _ _ hmem).symm
  have hrest : ∑ k ∈ (range r).erase 0, (lazyEigen r M k) ^ n ≤ ((r : ℝ) - 1) * β ^ n := by
    have hterm : ∀ k ∈ (range r).erase 0, (lazyEigen r M k) ^ n ≤ β ^ n := by
      intro k hk
      rw [Finset.mem_erase, mem_range] at hk
      have hkmod : k % r ≠ 0 := by
        rw [Nat.mod_eq_of_lt hk.2]; exact hk.1
      exact pow_le_pow_left₀ (lazyEigen_nonneg _ _ _) (lazyEigen_le r M k hr hkmod hM) n
    calc ∑ k ∈ (range r).erase 0, (lazyEigen r M k) ^ n
        ≤ ∑ _k ∈ (range r).erase 0, β ^ n := Finset.sum_le_sum hterm
      _ = (((range r).erase 0).card : ℝ) * β ^ n := by simp
      _ = ((r : ℝ) - 1) * β ^ n := by
          rw [Finset.card_erase_of_mem hmem, card_range]
          congr 1
          have h1 : (1 : ℕ) ≤ r := hr
          push_cast [Nat.cast_sub h1]
          ring
  have hβn : 0 ≤ β ^ n := pow_nonneg hβ0 n
  rw [heatReturn, div_le_iff₀ hr0, hsplit, lazyEigen_zero r M]
  simp only [one_pow]
  have hexp : (1 / (r : ℝ) + β ^ n) * r = 1 + (r : ℝ) * β ^ n := by field_simp
  rw [hexp]
  nlinarith

/-! ## 5. Mixing at `n = 8 (M+1)²` steps -/

/-- The quantitative mixing estimate: after `n = 8 (M+1)²` half-lazy steps the
spectral error is below `1/(4N²)`, for any `N ≤ 2^M`. -/
theorem beta_pow_le (N M : ℕ) (hN : 0 < N) (hM : N ≤ 2 ^ M) :
    (1 - 1 / (2 * ((M : ℝ) + 1))) ^ (8 * (M + 1) ^ 2) ≤ 1 / (4 * (N : ℝ) ^ 2) := by
  have hMnn : (0 : ℝ) ≤ (M : ℝ) := Nat.cast_nonneg M
  set D : ℝ := (M : ℝ) + 1 with hDdef
  have hD1 : (1 : ℝ) ≤ D := by rw [hDdef]; linarith
  have hD0 : (0 : ℝ) < D := by linarith
  have hδ1 : 1 / (2 * D) ≤ 1 := by
    rw [div_le_one (by positivity)]; linarith
  have h0 : 0 ≤ 1 - 1 / (2 * D) := by linarith
  -- Step 1: `1 - δ ≤ exp (-δ)`
  have hexp1 : 1 - 1 / (2 * D) ≤ Real.exp (-(1 / (2 * D))) := by
    have := Real.add_one_le_exp (-(1 / (2 * D)))
    linarith
  have hpow : (1 - 1 / (2 * D)) ^ (8 * (M + 1) ^ 2)
      ≤ (Real.exp (-(1 / (2 * D)))) ^ (8 * (M + 1) ^ 2) :=
    pow_le_pow_left₀ h0 hexp1 _
  -- Step 2: identify the exponent
  have hcast : ((8 * (M + 1) ^ 2 : ℕ) : ℝ) = 8 * D ^ 2 := by
    rw [hDdef]; push_cast; ring
  have hexp2 : (Real.exp (-(1 / (2 * D)))) ^ (8 * (M + 1) ^ 2) = Real.exp (-(4 * D)) := by
    rw [← Real.exp_nat_mul, hcast]
    congr 1
    field_simp
    ring
  -- Step 3: `4 N² ≤ exp (4 D)`
  have hNle : (N : ℝ) ≤ 2 ^ M := by exact_mod_cast hM
  have hN0 : (0 : ℝ) ≤ N := Nat.cast_nonneg N
  have hsq : (N : ℝ) ^ 2 ≤ ((2 : ℝ) ^ M) ^ 2 := by nlinarith [pow_pos (by norm_num : (0:ℝ) < 2) M]
  have e1 : ((2 : ℝ) ^ M) ^ 2 = 4 ^ M := by
    rw [← pow_mul, mul_comm, pow_mul]; norm_num
  have h4e : (4 : ℝ) ≤ Real.exp 4 := by
    have := Real.add_one_le_exp (4 : ℝ); linarith
  have e2 : (4 : ℝ) ^ M ≤ (Real.exp 4) ^ M := pow_le_pow_left₀ (by norm_num) h4e M
  have e3 : Real.exp (4 * D) = (Real.exp 4) ^ (M + 1) := by
    rw [← Real.exp_nat_mul]
    congr 1
    rw [hDdef]; push_cast; ring
  have hexpM : (0 : ℝ) < (Real.exp 4) ^ M := pow_pos (Real.exp_pos 4) M
  have h4N : 4 * (N : ℝ) ^ 2 ≤ Real.exp (4 * D) := by
    rw [e3, pow_succ]
    calc 4 * (N : ℝ) ^ 2 ≤ 4 * ((2 : ℝ) ^ M) ^ 2 := by linarith
      _ = 4 * (4 : ℝ) ^ M := by rw [e1]
      _ ≤ 4 * (Real.exp 4) ^ M := by linarith
      _ ≤ (Real.exp 4) ^ M * Real.exp 4 := by nlinarith
  -- Step 4: combine
  have hfin : Real.exp (-(4 * D)) ≤ 1 / (4 * (N : ℝ) ^ 2) := by
    rw [Real.exp_neg]
    rw [inv_eq_one_div]
    exact one_div_le_one_div_of_le (by positivity) h4N
  calc (1 - 1 / (2 * D)) ^ (8 * (M + 1) ^ 2)
      ≤ (Real.exp (-(1 / (2 * D)))) ^ (8 * (M + 1) ^ 2) := hpow
    _ = Real.exp (-(4 * D)) := hexp2
    _ ≤ 1 / (4 * (N : ℝ) ^ 2) := hfin

/-! ## 6. Rounding recovers the order exactly -/

/-- If `p` overestimates `1/r` by at most `ε` with `2r²ε < 1` then `round (1/p) = r`. -/
theorem round_one_div_of_close (r : ℕ) (p ε : ℝ) (hr : 0 < r) (hε : 0 ≤ ε)
    (h1 : 1 / (r : ℝ) ≤ p) (h2 : p ≤ 1 / (r : ℝ) + ε) (hb : 2 * (r : ℝ) ^ 2 * ε < 1) :
    round (1 / p) = (r : ℤ) := by
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  have hp : 0 < p := lt_of_lt_of_le (by positivity) h1
  have hrp : 1 ≤ p * r := (div_le_iff₀ hr0).mp h1
  have hup : 1 / p ≤ (r : ℝ) := by
    rw [div_le_iff₀ hp]
    nlinarith
  have hlow : (r : ℝ) - 1 / 2 < 1 / p := by
    rw [lt_div_iff₀ hp]
    have hp2 : p * r ≤ 1 + (r : ℝ) * ε := by
      have hrw : ((1 : ℝ) / r + ε) * r = 1 + r * ε := by field_simp
      nlinarith
    nlinarith
  rw [round_eq, Int.floor_eq_iff]
  constructor
  · push_cast; linarith
  · push_cast; linarith

/-! ## 7. Main theorem: heat-kernel order recovery -/

/-- **Heat-kernel order recovery.** Let `r ≤ N` be the order of the base and let
`M` satisfy `N ≤ 2^M` (e.g. `M = ⌊log₂ N⌋ + 1`). After `n = 8 (M+1)²` half-lazy
diffusion steps on the lacunary dyadic Cayley graph of `Z/rZ`, the *single* heat
kernel value at the identity determines `r` exactly:
`round (1 / p_n(e)) = r`. -/
theorem heat_kernel_order_recovery (N r M : ℕ) (hr : 0 < r) (hrN : r ≤ N) (hM : N ≤ 2 ^ M) :
    round (1 / heatReturn r M (8 * (M + 1) ^ 2)) = (r : ℤ) := by
  have hN : 0 < N := lt_of_lt_of_le hr hrN
  have hrM : r ≤ 2 ^ M := le_trans hrN hM
  have hlow := heatReturn_lower r M (8 * (M + 1) ^ 2) hr
  have hupp := heatReturn_upper r M (8 * (M + 1) ^ 2) hr hrM
  have hmix := beta_pow_le N M hN hM
  have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
  have hrN' : (r : ℝ) ≤ N := by exact_mod_cast hrN
  have hr0 : (0 : ℝ) < r := by exact_mod_cast hr
  set ε : ℝ := 1 / (4 * (N : ℝ) ^ 2) with hε
  have hεpos : 0 < ε := by rw [hε]; positivity
  refine round_one_div_of_close r _ ε hr hεpos.le hlow (le_trans hupp (by linarith)) ?_
  have hrw : 2 * (r : ℝ) ^ 2 * ε = (r : ℝ) ^ 2 / (2 * (N : ℝ) ^ 2) := by
    rw [hε]; field_simp; ring
  rw [hrw, div_lt_one (by positivity)]
  nlinarith

/-- Arithmetic corollary: the heat kernel of the dyadic walk built from the
multiplicative order of a unit `b ∈ (Z/NZ)ˣ` recovers that order. -/
theorem heat_kernel_recovers_orderOf (N : ℕ) [NeZero N] (b : (ZMod N)ˣ) (M : ℕ)
    (hM : N ≤ 2 ^ M) :
    round (1 / heatReturn (orderOf b) M (8 * (M + 1) ^ 2)) = (orderOf b : ℤ) := by
  haveI : Fintype (ZMod N) := ZMod.fintype N
  have hpos : 0 < orderOf b := orderOf_pos b
  have hle : orderOf b ≤ N := by
    have h1 : orderOf b ∣ Fintype.card (ZMod N)ˣ := orderOf_dvd_card
    have h2 : Fintype.card (ZMod N)ˣ = N.totient := ZMod.card_units_eq_totient N
    have h3 : N.totient ≤ N := Nat.totient_le N
    have h4 : 0 < N.totient := Nat.totient_pos.mpr (Nat.pos_of_ne_zero (NeZero.ne N))
    have h5 : orderOf b ≤ N.totient := by
      rw [← h2]
      exact Nat.le_of_dvd (by rw [h2]; exact h4) h1
    omega
  exact heat_kernel_order_recovery N (orderOf b) M hpos hle hM

end SpectralFreeWitness