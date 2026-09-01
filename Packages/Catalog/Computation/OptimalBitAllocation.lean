import Mathlib

/-!
# Optimal bit allocation: why the sensitive block must get the extra bits

Third file of the NET-84 thread (self-contained; companions:
`TailAwareMixedPrecision.lean`, `TailUnitEpistasis.lean`).

`TailAwareMixedPrecision.lean` proves that in a non-expansive stack the *sensitivity
profile* `s i` (the product of downstream Lipschitz constants) is monotone increasing in
depth, so the tail carries the largest certified perturbation budget.  This file turns
that structural fact into a **quantitative precision-allocation law**.

Model.  A `b`-bit uniform quantizer on a weight block of dynamic range `R i` produces a
layer deviation `≈ R i * 2 ^ (-b i)`.  With sensitivity `s i`, the propagation theorem
of the companion file certifies an end-to-end error

`cost c b = ∑ i, c i * 2 ^ (-b i)`,  where `c i = s i * R i > 0`,

and a bit budget `∑ i, b i = B` (real-valued relaxation of the integer budget).

Main results.

* `cost_lower_bound` — for **every** allocation with budget `B`,
  `cost c b ≥ n * (∏ i, c i) ^ (1/n) * 2 ^ (-B/n)`; the geometric mean of the
  sensitivities is the fundamental obstruction.  Proof: weighted AM–GM.
* `bStar_sum_eq`, `cost_bStar` — the *water-filling* allocation
  `b* i = B/n + log₂ (c i) - (1/n) ∑ j log₂ (c j)` spends exactly the budget and
  attains the bound, so it is optimal (`bStar_optimal`).
* `bStar_sub_bStar` — the optimal bit gap between two blocks is exactly
  `log₂ (c i / c j)`: precision must be allocated **logarithmically in sensitivity**.
* `bStar_mono` / `tail_gets_more_bits` — consequently, in a non-expansive network,
  where sensitivity increases with depth, the optimal allocation gives the *tail* the
  most bits.  This is the NET-84 prescription ("keep `L22/L23` at high precision")
  derived from first principles rather than measured.
* `bStar_gap_of_ratio` — a two-block corollary: if the tail is `r` times more
  sensitive than the body, the optimum grants it exactly `log₂ r` extra bits; e.g. a
  `4×` more sensitive tail deserves exactly two extra bits.
-/

namespace BitAllocation

open Finset Real

variable {n : ℕ}

/-- Certified end-to-end error of a bit allocation `b` for blocks with
sensitivity-times-range coefficients `c`. -/
noncomputable def cost (c b : Fin n → ℝ) : ℝ := ∑ i, c i * (2 : ℝ) ^ (-b i)

/-- **Water-filling lower bound.**  No allocation of a fixed total bit budget can beat
`n · (geometric mean of the sensitivities) · 2 ^ (-B/n)`. -/
theorem cost_lower_bound (hn : 0 < n) (c b : Fin n → ℝ) (hc : ∀ i, 0 < c i)
    (B : ℝ) (hb : ∑ i, b i = B) :
    (n : ℝ) * (∏ i, c i) ^ ((1 : ℝ) / n) * (2 : ℝ) ^ (-B / n) ≤ cost c b := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  set z : Fin n → ℝ := fun i => c i * (2 : ℝ) ^ (-b i) with hz
  have hzpos : ∀ i, 0 < z i := fun i =>
    mul_pos (hc i) (Real.rpow_pos_of_pos (by norm_num) _)
  have hAM :=
    Real.geom_mean_le_arith_mean_weighted univ (fun _ => 1 / (n : ℝ)) z
      (fun i _ => by positivity)
      (by simp [Finset.card_univ]; field_simp)
      (fun i _ => (hzpos i).le)
  -- rewrite the geometric mean
  have hprod : ∏ i, z i = (∏ i, c i) * (2 : ℝ) ^ (-B) := by
    have h2 : ∏ i, (2 : ℝ) ^ (-b i) = (2 : ℝ) ^ (∑ i, -b i) := by
      rw [← Real.rpow_sum_of_pos (by norm_num)]
    have hnb : ∑ i, -b i = -B := by simp [hb]
    rw [Finset.prod_mul_distrib, h2, hnb]
  have hgeo : ∏ i, z i ^ ((1 : ℝ) / n)
      = (∏ i, c i) ^ ((1 : ℝ) / n) * (2 : ℝ) ^ (-B / n) := by
    rw [Real.finset_prod_rpow _ _ (fun i _ => (hzpos i).le), hprod,
      Real.mul_rpow (Finset.prod_nonneg fun i _ => (hc i).le)
        (Real.rpow_nonneg (by norm_num) _), ← Real.rpow_mul (by norm_num)]
    congr 2
    field_simp
  have hsum : ∑ i, (1 / (n : ℝ)) * z i = cost c b / n := by
    rw [← Finset.mul_sum]
    simp [cost, hz, div_eq_inv_mul]
  rw [hgeo, hsum] at hAM
  have hmul := mul_le_mul_of_nonneg_left hAM hn0.le
  have hcancel : (n : ℝ) * (cost c b / n) = cost c b := by field_simp
  rw [hcancel] at hmul
  calc (n : ℝ) * (∏ i, c i) ^ ((1 : ℝ) / n) * (2 : ℝ) ^ (-B / n)
      = (n : ℝ) * ((∏ i, c i) ^ ((1 : ℝ) / n) * (2 : ℝ) ^ (-B / n)) := by ring
    _ ≤ cost c b := hmul

/-- The water-filling (reverse water-filling) allocation: a uniform share of the budget
plus a correction logarithmic in the block's sensitivity. -/
noncomputable def bStar (c : Fin n → ℝ) (B : ℝ) : Fin n → ℝ :=
  fun i => B / n + logb 2 (c i) - (1 / n) * ∑ j, logb 2 (c j)

/-- The optimal bit gap between two blocks is `log₂` of their sensitivity ratio. -/
theorem bStar_sub_bStar (c : Fin n → ℝ) (B : ℝ) (i j : Fin n) :
    bStar c B i - bStar c B j = logb 2 (c i) - logb 2 (c j) := by
  unfold bStar; ring

/-- More sensitive blocks receive more bits. -/
theorem bStar_mono (c : Fin n → ℝ) (B : ℝ) {i j : Fin n} (hci : 0 < c i)
    (h : c i ≤ c j) : bStar c B i ≤ bStar c B j := by
  have := Real.logb_le_logb_of_le (b := 2) (by norm_num) hci h
  unfold bStar
  linarith

/-- **Tail-aware precision from first principles.**  If sensitivity increases with depth
— which `TailAwareMixedPrecision.sens_mono` proves for every non-expansive network —
then the optimal bit allocation increases with depth: the tail must be kept at the
highest precision. -/
theorem tail_gets_more_bits (c : Fin n → ℝ) (B : ℝ) (hc : ∀ i, 0 < c i)
    (hmono : ∀ i j : Fin n, i ≤ j → c i ≤ c j) {i j : Fin n} (hij : i ≤ j) :
    bStar c B i ≤ bStar c B j :=
  bStar_mono c B (hc i) (hmono i j hij)

/-- A block that is `r` times more sensitive deserves exactly `log₂ r` extra bits;
for `r = 4` that is exactly two bits (e.g. 4-bit body vs. 6-bit tail). -/
theorem bStar_gap_of_ratio (c : Fin n → ℝ) (B r : ℝ) (i j : Fin n)
    (hcj : 0 < c j) (hr : 0 < r) (h : c i = r * c j) :
    bStar c B i - bStar c B j = logb 2 r := by
  rw [bStar_sub_bStar, h, Real.logb_mul (ne_of_gt hr) (ne_of_gt hcj)]
  ring

/-- **Geometric sensitivity profile.**  In a non-expansive network with a constant
Lipschitz constant `lam < 1` the sensitivity of layer `k` is `lam ^ (n-1-k)`, so the
optimal allocation grants layer `j` exactly `(j - i) * log₂ (1/lam)` more bits than the
shallower layer `i`.  For a 24-layer stack with `lam = 0.9` the last layer deserves
`23 * log₂(1/0.9) ≈ 3.5` more bits than the first: tail-aware mixed precision is the
optimum, not a heuristic. -/
theorem bStar_gap_geometric (lam R B : ℝ) (hlam : 0 < lam) (hR : 0 < R)
    (i j : Fin n) (hij : (i : ℕ) ≤ (j : ℕ)) :
    bStar (fun k : Fin n => R * lam ^ (n - 1 - (k : ℕ))) B j
      - bStar (fun k : Fin n => R * lam ^ (n - 1 - (k : ℕ))) B i
      = ((j : ℕ) - (i : ℕ) : ℝ) * logb 2 (1 / lam) := by
  rw [bStar_sub_bStar,
    Real.logb_mul (by positivity) (by positivity),
    Real.logb_mul (by positivity) (by positivity),
    Real.logb_pow, Real.logb_pow, Real.logb_div (by norm_num) (by positivity)]
  have hj : (j : ℕ) < n := j.isLt
  have hkey : (n - 1 - (i : ℕ)) = (n - 1 - (j : ℕ)) + ((j : ℕ) - (i : ℕ)) := by omega
  rw [hkey, Nat.cast_add, Nat.cast_sub hij]
  simp
  ring

/-- The water-filling allocation spends exactly the budget. -/
theorem bStar_sum_eq (hn : 0 < n) (c : Fin n → ℝ) (B : ℝ) :
    ∑ i, bStar c B i = B := by
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  unfold bStar
  rw [Finset.sum_sub_distrib, Finset.sum_add_distrib]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  field_simp
  ring

/-- **The water-filling allocation attains the bound**, hence is optimal. -/
theorem cost_bStar (hn : 0 < n) (c : Fin n → ℝ) (hc : ∀ i, 0 < c i) (B : ℝ) :
    cost c (bStar c B) = (n : ℝ) * (∏ i, c i) ^ ((1 : ℝ) / n) * (2 : ℝ) ^ (-B / n) := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have hP : 0 < ∏ i, c i := Finset.prod_pos (fun i _ => hc i)
  have hlogsum : ∑ j, logb 2 (c j) = logb 2 (∏ i, c i) := by
    rw [Real.logb_prod]
    intro i _
    exact (hc i).ne'
  have hterm : ∀ i : Fin n, c i * (2 : ℝ) ^ (-(bStar c B i))
      = (∏ i, c i) ^ ((1 : ℝ) / n) * (2 : ℝ) ^ (-B / n) := by
    intro i
    have hsplit : -(bStar c B i)
        = (-B / n) + ((1 / (n : ℝ)) * logb 2 (∏ i, c i)) + (-(logb 2 (c i))) := by
      unfold bStar
      rw [hlogsum]
      ring
    rw [hsplit, Real.rpow_add (by norm_num), Real.rpow_add (by norm_num)]
    have h1 : (2 : ℝ) ^ (-(logb 2 (c i))) = (c i)⁻¹ := by
      rw [Real.rpow_neg (by norm_num), Real.rpow_logb (by norm_num) (by norm_num) (hc i)]
    have h2 : (2 : ℝ) ^ ((1 / (n : ℝ)) * logb 2 (∏ i, c i)) = (∏ i, c i) ^ ((1 : ℝ) / n) := by
      rw [mul_comm, Real.rpow_mul (by norm_num),
        Real.rpow_logb (by norm_num) (by norm_num) hP]
    rw [h1, h2]
    field_simp [(hc i).ne']
  unfold cost
  rw [Finset.sum_congr rfl (fun i _ => hterm i)]
  simp [Finset.card_univ, mul_assoc]

/-! ### Deployable (integer) allocations -/

lemma rpow_neg_floor_le (x : ℝ) : (2 : ℝ) ^ (-(⌊x⌋ : ℝ)) ≤ 2 * (2 : ℝ) ^ (-x) := by
  have h : (x : ℝ) - 1 < (⌊x⌋ : ℝ) := by exact_mod_cast Int.sub_one_lt_floor x
  have hmono : (2 : ℝ) ^ (-(⌊x⌋ : ℝ)) ≤ (2 : ℝ) ^ (-(x - 1)) :=
    Real.rpow_le_rpow_of_exponent_le (by norm_num) (by linarith)
  have hsplit : (2 : ℝ) ^ (-(x - 1)) = 2 * (2 : ℝ) ^ (-x) := by
    rw [show -(x - 1) = 1 + (-x) by ring, Real.rpow_add (by norm_num)]
    norm_num
  linarith [hsplit ▸ hmono]

/-- Rounding the water-filling allocation down to integers keeps it inside the budget. -/
theorem floor_bStar_within_budget (hn : 0 < n) (c : Fin n → ℝ) (B : ℝ) :
    ∑ i, ((⌊bStar c B i⌋ : ℤ) : ℝ) ≤ B := by
  have hsum : ∑ i, ((⌊bStar c B i⌋ : ℤ) : ℝ) ≤ ∑ i, bStar c B i :=
    Finset.sum_le_sum (fun i _ => Int.floor_le _)
  rwa [bStar_sum_eq hn c B] at hsum

/-- **Integer rounding costs at most a factor two.**  Hardware supports only integer bit
widths; flooring the optimal allocation stays within budget and at most doubles the
certified error. -/
theorem cost_floor_le_two_mul_opt (hn : 0 < n) (c : Fin n → ℝ) (hc : ∀ i, 0 < c i) (B : ℝ) :
    cost c (fun i => ((⌊bStar c B i⌋ : ℤ) : ℝ))
      ≤ 2 * ((n : ℝ) * (∏ i, c i) ^ ((1 : ℝ) / n) * (2 : ℝ) ^ (-B / n)) := by
  rw [← cost_bStar hn c hc B]
  unfold cost
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum (fun i _ => ?_)
  have h := rpow_neg_floor_le (bStar c B i)
  have hci := (hc i).le
  calc c i * (2 : ℝ) ^ (-((⌊bStar c B i⌋ : ℤ) : ℝ))
      ≤ c i * (2 * (2 : ℝ) ^ (-(bStar c B i))) := mul_le_mul_of_nonneg_left h hci
    _ = 2 * (c i * (2 : ℝ) ^ (-(bStar c B i))) := by ring

/-- Optimality of the water-filling allocation among all allocations of the same
budget. -/
theorem bStar_optimal (hn : 0 < n) (c b : Fin n → ℝ) (hc : ∀ i, 0 < c i) (B : ℝ)
    (hb : ∑ i, b i = B) : cost c (bStar c B) ≤ cost c b := by
  rw [cost_bStar hn c hc B]
  exact cost_lower_bound hn c b hc B hb

end BitAllocation