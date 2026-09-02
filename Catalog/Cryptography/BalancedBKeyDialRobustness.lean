import Mathlib
import Novelty.ZeroFitDialU64

/-!
# BALANCED-BKEY: the zero-fit `T`-dial is robust across the whole bitlen × cap envelope

## Research context (FACT round-54 #1, exp 523, `BALANCED-BKEY`)

Experiment 523 (`exp523_balanced_bkey.py`, seeds `20261100 + bitlen`) sweeps two knobs at
once — the bit length `b` of the drawn key and the *cap* `u` of the trailing-zero statistic
`T_u(x) = min(v₂(x), u)` — and records, at **every** cell of the grid,

* `Spearman(T, rate) ≥ 0.53`, and
* an advantage of `T` over the *bare count* (the `u = 1` statistic, i.e. bare parity)
  of `0.10 – 0.15`.

The reported verdict is `DIAL-ROBUST`: "no cliff, no breakdown, no convention artifact".
This file supplies the mathematics of that verdict, on top of the tie-attenuation calculus
of `Novelty.ZeroFitDialU64`.

## Main results

* `capBlocks`, `capBlocks_sum`, `tieCorr_capBlocks` — the tie profile of the capped
  trailing-zero statistic `T_u` on `{0,…,2^b-1}` and its exact Kendall correction.
* `capped_ceiling_factorisation` — the **separation law**: for `u ≤ b`, `1 ≤ b`,
  `ρ²(b,u) = (6/7)·(1 - 8^{-u})·(1 + 1/(4^b - 1))`.  The two knobs enter as *independent
  factors*: a cap factor and a bitlen factor.
* `ceiling_table_rank_one` — hence the whole `bitlen × u` ceiling table is **rank one**:
  `ρ²(b,u)·ρ²(b',u') = ρ²(b,u')·ρ²(b',u)`.  There is literally no interaction term, which is
  the exact mathematical meaning of "no cell-specific cliff".
* `capped_ceiling_strict_mono_u`, `capped_ceiling_strict_anti_b`,
  `bitlen_movement_small` — monotonicity in each knob and the quantitative statement that
  moving the bitlen can shift the ceiling by less than `4^{-b}·2`, *uniformly in `u`*.
* `mass_fraction_floor`, `mass_fraction_cliff_edge` — the **mass-fraction floor law**: a modal
  class of relative size `a < 1` still leaves `ρ² > 1 - a²`, so the recorded `0.53` floor survives
  any modal mass up to `84.7%`; the cliff is located in the window `0.848 – 0.937`.
* `balanced_no_cliff`, `balanced_no_cliff_real` — the **distribution-free floor law**: for an
  arbitrary tie profile in which no single value carries more than half of the sample
  ("balanced"), `ρ² > 3/4`, hence `ρ > 0.866 > 0.53`.  No bitlen, no cap, no draw law enters.
  `capped_cell_floor` specialises this to every cell of the recorded envelope.
* `majority_block_cliff_example` — sharpness: drop the balance hypothesis and the floor fails
  (`ρ < 0.53` already for the profile `[15,1]`).
* `tieCorr_merge_le`, `spearmanSq_merge_le`, `capBlocks_merge_last` — the **coarsening law**:
  merging two tie classes can only lower the ceiling, and lowering the cap by one is exactly
  such a merge.  This is the structural reason why `T` beats the bare count.
* `gap_ceiling_lower`, `gap_ceiling_upper_real`, `recorded_gap_forces_slack` — the **gap
  law**: the tie-resolution advantage of `T_u` (`u ≥ 2`) over the bare count is at least
  `0.09` in `ρ²`, but **less than `0.07` in `ρ`** at every cell.  The recorded advantage of
  `0.10 – 0.15` therefore cannot be a pure tie-resolution effect: it forces the bare-count
  reading to sit at least `0.03` below its own ceiling.

## The scientific payload

Robustness, made precise, is *separability*: the ceiling factorises over the two knobs
(`capped_ceiling_factorisation`), so the table has no interaction (`ceiling_table_rank_one`),
and the floor that guarantees `≥ 0.53` is not a property of the dyadic law at all but of any
balanced statistic (`balanced_no_cliff`).  The one place where the recorded numbers exceed
what the theory allows is the size of the `T`-versus-count advantage
(`recorded_gap_forces_slack`): tie granularity buys at most `0.062`, so the recorded
`0.10 – 0.15` must come from the response coupling, not from the resolution of `T`.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

namespace Catalog.Cryptography.BalancedBKeyDialRobustness

/-! ## 1. The capped trailing-zero profile -/

/-- Tie profile of the **capped** trailing-zero statistic `T_u(x) = min(v₂(x), u)` on
`{0,…,2^b-1}`: blocks `2^(b-1), 2^(b-2), …, 2^(b-u)` (the keys with exactly `k < u` trailing
zeros) followed by the top block `2^(b-u)` (all keys divisible by `2^u`). -/
def capBlocks : ℕ → ℕ → List ℕ
  | 0, b => [2 ^ b]
  | _ + 1, 0 => [1]
  | u + 1, b + 1 => 2 ^ b :: capBlocks u b

@[simp] lemma capBlocks_zero (b : ℕ) : capBlocks 0 b = [2 ^ b] := rfl

@[simp] lemma capBlocks_succ_succ (u b : ℕ) :
    capBlocks (u + 1) (b + 1) = 2 ^ b :: capBlocks u b := rfl

/-- At the maximal cap the profile is the full dyadic one of `Novelty.ZeroFitDialU64`. -/
theorem capBlocks_self (b : ℕ) : capBlocks b b = dyadicBlocks b := by
  induction b with
  | zero => rfl
  | succ k ih => rw [capBlocks_succ_succ, dyadicBlocks, ih]

/-- The capped profile always accounts for all `2^b` keys. -/
theorem capBlocks_sum (u r : ℕ) : (capBlocks u (u + r)).sum = 2 ^ (u + r) := by
  induction u generalizing r with
  | zero => simp
  | succ k ih =>
      have hb : k + 1 + r = (k + r) + 1 := by omega
      rw [hb, capBlocks_succ_succ, List.sum_cons, ih r, pow_succ]
      ring

lemma capBlocks_sum' {u b : ℕ} (h : u ≤ b) : (capBlocks u b).sum = 2 ^ b := by
  obtain ⟨r, rfl⟩ := Nat.exists_eq_add_of_le h
  exact capBlocks_sum u r

/-- The Kendall correction of a one-block profile. -/
lemma tieCorr_singleton (m : ℕ) : 12 * tieCorr [m] = (m : ℚ) ^ 3 - m := by
  simp [tieCorr]; ring

/-- **Exact Kendall correction of the capped profile.** -/
theorem tieCorr_capBlocks (u r : ℕ) :
    12 * tieCorr (capBlocks u (u + r)) = ((8 : ℚ) ^ (u + r) + 6 * 8 ^ r) / 7 - 2 ^ (u + r) := by
  induction u generalizing r with
  | zero =>
      have hz : capBlocks 0 (0 + r) = [2 ^ r] := by rw [Nat.zero_add, capBlocks_zero]
      rw [hz, tieCorr_singleton]
      simp only [Nat.cast_pow, Nat.cast_ofNat, Nat.zero_add]
      rw [pow_two_cube r]
      ring
  | succ k ih =>
      have hb : k + 1 + r = (k + r) + 1 := by omega
      rw [hb, capBlocks_succ_succ, tieCorr_cons, mul_add, ih r]
      push_cast
      rw [pow_two_cube (k + r), pow_succ (8 : ℚ) (k + r), pow_succ (2 : ℚ) (k + r)]
      ring

/-! ## 2. The separation law: the two knobs enter as independent factors -/

lemma two_pow_ge_two {b : ℕ} (hb : 1 ≤ b) : (2 : ℚ) ≤ (2 : ℚ) ^ b := by
  calc (2 : ℚ) = 2 ^ 1 := (pow_one 2).symm
    _ ≤ 2 ^ b := pow_le_pow_right₀ (by norm_num) hb

lemma two_le_capBlocks_sum {u b : ℕ} (hb : 1 ≤ b) (hub : u ≤ b) :
    2 ≤ (capBlocks u b).sum := by
  rw [capBlocks_sum' hub]
  calc 2 = 2 ^ 1 := rfl
    _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb

/-- **Separation law (main result).**  The exact tie ceiling of the capped trailing-zero dial
factorises into a *cap factor* `1 - 8^{-u}` and a *bitlen factor* `1 + 1/(4^b - 1)`:
`ρ²(b,u) = (6/7)·(1 - 8^{-u})·(1 + 1/(4^b-1))`.
The two experimental knobs do not interact. -/
theorem capped_ceiling_factorisation {u b : ℕ} (hb : 1 ≤ b) (hub : u ≤ b) :
    spearmanSq (capBlocks u b)
      = 6 / 7 * (1 - (1 / 8 : ℚ) ^ u) * (1 + 1 / ((4 : ℚ) ^ b - 1)) := by
  obtain ⟨r, rfl⟩ := Nat.exists_eq_add_of_le hub
  have h2 : 2 ≤ (capBlocks u (u + r)).sum := two_le_capBlocks_sum hb (by omega)
  have hcast : (((capBlocks u (u + r)).sum : ℕ) : ℚ) = (2 : ℚ) ^ (u + r) := by
    rw [capBlocks_sum u r]; push_cast; ring
  rw [spearmanSq_eq _ h2, hcast, tieCorr_capBlocks u r]
  set x : ℚ := (2 : ℚ) ^ (u + r) with hx
  have hx2 : (2 : ℚ) ≤ x := two_pow_ge_two (by omega)
  have hcube : (8 : ℚ) ^ (u + r) = x ^ 3 := (pow_two_cube (u + r)).symm
  have hsq : (4 : ℚ) ^ (u + r) = x ^ 2 := by
    rw [hx, ← pow_mul, mul_comm, pow_mul]; norm_num
  have hpow8 : (8 : ℚ) ^ r = x ^ 3 * (1 / 8 : ℚ) ^ u := by
    have h8 : (8 : ℚ) ^ (u + r) = 8 ^ u * 8 ^ r := pow_add 8 u r
    have hu0 : ((8 : ℚ) ^ u) ≠ 0 := by positivity
    rw [← hcube, h8, div_pow, one_pow]
    field_simp
  rw [hcube, hsq, hpow8]
  have hxpos : (0 : ℚ) < x := by linarith
  have h1 : x ^ 2 - 1 ≠ 0 := by nlinarith
  have h2' : x ^ 3 - x ≠ 0 := by nlinarith
  field_simp
  ring

/-- Consistency with `Novelty.ZeroFitDialU64`: at the maximal cap `u = b` the separation law
reproduces the exact dyadic ceiling `(6/7)(1 + 1/(2^b(2^b+1)))`. -/
theorem capped_ceiling_at_full_cap {b : ℕ} (hb : 1 ≤ b) :
    spearmanSq (capBlocks b b) = 6 / 7 * (1 + 1 / ((2 : ℚ) ^ b * (2 ^ b + 1))) := by
  rw [capBlocks_self b, dyadic_spearmanSq b hb]

/-! ## 3. No interaction: the ceiling table is rank one -/

/-- The cap factor of the separation law. -/
def capFactor (u : ℕ) : ℚ := 6 / 7 * (1 - (1 / 8 : ℚ) ^ u)

/-- The bitlen factor of the separation law. -/
def bitFactor (b : ℕ) : ℚ := 1 + 1 / ((4 : ℚ) ^ b - 1)

lemma capped_ceiling_eq {u b : ℕ} (hb : 1 ≤ b) (hub : u ≤ b) :
    spearmanSq (capBlocks u b) = capFactor u * bitFactor b := by
  rw [capped_ceiling_factorisation hb hub, capFactor, bitFactor]

lemma bitFactor_pos {b : ℕ} (hb : 1 ≤ b) : 0 < bitFactor b := by
  have h4 : (4 : ℚ) ^ 1 ≤ (4 : ℚ) ^ b := pow_le_pow_right₀ (by norm_num) hb
  rw [pow_one] at h4
  have : (0 : ℚ) < (4 : ℚ) ^ b - 1 := by linarith
  rw [bitFactor]
  positivity

lemma bitFactor_gt_one {b : ℕ} (hb : 1 ≤ b) : 1 < bitFactor b := by
  have h4 : (4 : ℚ) ^ 1 ≤ (4 : ℚ) ^ b := pow_le_pow_right₀ (by norm_num) hb
  rw [pow_one] at h4
  have hpos : (0 : ℚ) < (4 : ℚ) ^ b - 1 := by linarith
  have : (0 : ℚ) < 1 / ((4 : ℚ) ^ b - 1) := by positivity
  rw [bitFactor]; linarith

lemma capFactor_pos {u : ℕ} (hu : 1 ≤ u) : 0 < capFactor u := by
  have h : (1 / 8 : ℚ) ^ u ≤ (1 / 8 : ℚ) ^ 1 :=
    pow_le_pow_of_le_one (by norm_num) (by norm_num) hu
  rw [pow_one] at h
  rw [capFactor]; linarith

lemma capFactor_lt {u : ℕ} : capFactor u ≤ 6 / 7 := by
  have : (0 : ℚ) ≤ (1 / 8 : ℚ) ^ u := by positivity
  rw [capFactor]; linarith

/-- **No-interaction (rank-one) law.**  The `bitlen × cap` table of tie ceilings satisfies the
vanishing `2 × 2` determinant identity: the ceiling is a product of a row function and a
column function, so no cell can behave differently from what its row and column dictate.
This is the precise sense in which the recorded envelope has "no cliff". -/
theorem ceiling_table_rank_one {u u' b b' : ℕ} (hb : 1 ≤ b) (hb' : 1 ≤ b')
    (h1 : u ≤ b) (h2 : u ≤ b') (h3 : u' ≤ b) (h4 : u' ≤ b') :
    spearmanSq (capBlocks u b) * spearmanSq (capBlocks u' b')
      = spearmanSq (capBlocks u' b) * spearmanSq (capBlocks u b') := by
  rw [capped_ceiling_eq hb h1, capped_ceiling_eq hb' h4, capped_ceiling_eq hb h3,
    capped_ceiling_eq hb' h2]
  ring

/-- The ceiling is strictly increasing in the cap `u`: more resolution, higher ceiling. -/
theorem capped_ceiling_strict_mono_u {u u' b : ℕ} (hb : 1 ≤ b) (huu : u < u') (hub : u' ≤ b) :
    spearmanSq (capBlocks u b) < spearmanSq (capBlocks u' b) := by
  rw [capped_ceiling_eq hb (le_of_lt (lt_of_lt_of_le huu hub)), capped_ceiling_eq hb hub]
  have hlt : (1 / 8 : ℚ) ^ u' < (1 / 8 : ℚ) ^ u :=
    pow_lt_pow_right_of_lt_one₀ (by norm_num) (by norm_num) huu
  have hcap : capFactor u < capFactor u' := by
    rw [capFactor, capFactor]; linarith
  have := bitFactor_pos hb
  exact mul_lt_mul_of_pos_right hcap this

/-- The ceiling is strictly decreasing in the bitlen `b` (for any active cap `u ≥ 1`). -/
theorem capped_ceiling_strict_anti_b {u b b' : ℕ} (hu : 1 ≤ u) (hb : 1 ≤ b) (hbb : b < b')
    (hub : u ≤ b) :
    spearmanSq (capBlocks u b') < spearmanSq (capBlocks u b) := by
  have hb' : 1 ≤ b' := le_trans hb (le_of_lt hbb)
  rw [capped_ceiling_eq hb hub, capped_ceiling_eq hb' (le_trans hub (le_of_lt hbb))]
  have h4b : (4 : ℚ) ^ 1 ≤ (4 : ℚ) ^ b := pow_le_pow_right₀ (by norm_num) hb
  rw [pow_one] at h4b
  have hlt : (4 : ℚ) ^ b < (4 : ℚ) ^ b' := pow_lt_pow_right₀ (by norm_num) hbb
  have hpos : (0 : ℚ) < (4 : ℚ) ^ b - 1 := by linarith
  have hinv : 1 / ((4 : ℚ) ^ b' - 1) < 1 / ((4 : ℚ) ^ b - 1) :=
    one_div_lt_one_div_of_lt hpos (by linarith)
  have hbf : bitFactor b' < bitFactor b := by rw [bitFactor, bitFactor]; linarith
  exact mul_lt_mul_of_pos_left hbf (capFactor_pos hu)

/-- **Uniform bitlen insensitivity.**  Moving the bitlen from `b` to any larger `b'` changes the
ceiling by less than `2·4^{-b}` — and the bound does not depend on the cap `u`.  At the recorded
bitlens this is astronomically smaller than the `0.10`-scale effects the experiment reports. -/
theorem bitlen_movement_small {u b b' : ℕ} (hb : 1 ≤ b) (hbb : b ≤ b') (hub : u ≤ b) :
    spearmanSq (capBlocks u b) - spearmanSq (capBlocks u b') < 2 / (4 : ℚ) ^ b := by
  have hb' : 1 ≤ b' := le_trans hb hbb
  rw [capped_ceiling_eq hb hub, capped_ceiling_eq hb' (le_trans hub hbb)]
  have h4b : (4 : ℚ) ^ 1 ≤ (4 : ℚ) ^ b := pow_le_pow_right₀ (by norm_num) hb
  rw [pow_one] at h4b
  have hle : (4 : ℚ) ^ b ≤ (4 : ℚ) ^ b' := pow_le_pow_right₀ (by norm_num) hbb
  have hposb : (0 : ℚ) < (4 : ℚ) ^ b - 1 := by linarith
  have hposb' : (0 : ℚ) < (4 : ℚ) ^ b' - 1 := by linarith
  have hinv : 1 / ((4 : ℚ) ^ b' - 1) ≤ 1 / ((4 : ℚ) ^ b - 1) := by
    apply one_div_le_one_div_of_le hposb; linarith
  have hcap0 : 0 ≤ capFactor u := by
    have : (1 / 8 : ℚ) ^ u ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
    rw [capFactor]; linarith
  have hdiff : capFactor u * bitFactor b - capFactor u * bitFactor b'
      ≤ 6 / 7 * (1 / ((4 : ℚ) ^ b - 1)) := by
    have hstep : capFactor u * (bitFactor b - bitFactor b')
        ≤ capFactor u * (1 / ((4 : ℚ) ^ b - 1)) := by
      apply mul_le_mul_of_nonneg_left _ hcap0
      rw [bitFactor, bitFactor]
      have : (0 : ℚ) < 1 / ((4 : ℚ) ^ b' - 1) := by positivity
      linarith
    have hstep2 : capFactor u * (1 / ((4 : ℚ) ^ b - 1)) ≤ 6 / 7 * (1 / ((4 : ℚ) ^ b - 1)) := by
      have : (0 : ℚ) ≤ 1 / ((4 : ℚ) ^ b - 1) := by positivity
      exact mul_le_mul_of_nonneg_right capFactor_lt this
    nlinarith
  have hfinal : 6 / 7 * (1 / ((4 : ℚ) ^ b - 1)) < 2 / (4 : ℚ) ^ b := by
    have hp : (0 : ℚ) < (4 : ℚ) ^ b := by positivity
    rw [mul_one_div, div_lt_div_iff₀ hposb hp]
    linarith
  linarith

/-! ## 4. The distribution-free floor: a balanced statistic can never fall off a cliff -/

/-- The Kendall correction rewritten as `Σ m³ - n`. -/
lemma twelve_tieCorr_eq (L : List ℕ) :
    12 * tieCorr L = (L.map fun m : ℕ => ((m : ℚ) ^ 3)).sum - (L.sum : ℚ) := by
  induction L with
  | nil => simp [tieCorr]
  | cons m L ih =>
      rw [tieCorr_cons, mul_add, ih]
      simp only [List.map_cons, List.sum_cons, Nat.cast_add]
      ring

/-- Sum of cubes is controlled by the largest block: `Σ m³ ≤ M²·n`. -/
lemma sum_cubes_le (L : List ℕ) (M : ℚ) (h0 : 0 ≤ M) (hM : ∀ m ∈ L, (m : ℚ) ≤ M) :
    (L.map fun m : ℕ => ((m : ℚ) ^ 3)).sum ≤ M ^ 2 * (L.sum : ℚ) := by
  induction L with
  | nil => simp
  | cons m L ih =>
      have hm : (m : ℚ) ≤ M := hM m (List.mem_cons_self ..)
      have hm0 : (0 : ℚ) ≤ (m : ℚ) := by positivity
      have hrest := ih fun x hx => hM x (List.mem_cons_of_mem _ hx)
      have hsq : ((m : ℚ)) ^ 2 ≤ M ^ 2 := by nlinarith
      have hcube : ((m : ℚ)) ^ 3 ≤ M ^ 2 * (m : ℚ) := by nlinarith
      simp only [List.map_cons, List.sum_cons, Nat.cast_add]
      nlinarith

/-- **Mass-fraction floor law.**  If no value of the tied statistic carries more than a fraction
`a < 1` of the sample, the tie ceiling satisfies `ρ² > 1 - a²`.  Nothing else about the
statistic, the bitlen, the cap or the draw law enters. -/
theorem mass_fraction_floor (L : List ℕ) (a : ℚ) (h2 : 2 ≤ L.sum) (ha0 : 0 ≤ a) (ha1 : a < 1)
    (hM : ∀ m ∈ L, (m : ℚ) ≤ a * (L.sum : ℚ)) :
    1 - a ^ 2 < spearmanSq L := by
  set n : ℚ := (L.sum : ℚ) with hn
  have hn2 : (2 : ℚ) ≤ n := by rw [hn]; exact_mod_cast h2
  have hden : (0 : ℚ) < n ^ 3 - n := cube_sub_self_pos hn2
  have hcubes : (L.map fun m : ℕ => ((m : ℚ) ^ 3)).sum ≤ (a * n) ^ 2 * n :=
    sum_cubes_le L (a * n) (by positivity) hM
  have h12 : 12 * tieCorr L ≤ a ^ 2 * n ^ 3 - n := by
    rw [twelve_tieCorr_eq L, ← hn]
    nlinarith
  have hstep : 12 * tieCorr L / (n ^ 3 - n) ≤ (a ^ 2 * n ^ 3 - n) / (n ^ 3 - n) :=
    div_le_div_of_nonneg_right h12 hden.le
  have hnpos : (0 : ℚ) < n := by linarith
  have hasq : a ^ 2 < 1 := by nlinarith
  have hshrink : a ^ 2 * n < n := by nlinarith
  have hlt : (a ^ 2 * n ^ 3 - n) / (n ^ 3 - n) < a ^ 2 := by
    rw [div_lt_iff₀ hden]
    nlinarith
  rw [spearmanSq_eq L h2, ← hn]
  linarith

/-- **Distribution-free floor law (no cliff).**  If no value of the tied statistic carries more
than half of the sample — the *balance* condition, which holds for the trailing-zero statistic
with any active cap at any bitlen, and indeed for any balanced key law — then the tie ceiling
satisfies `ρ² > 3/4`.  No bitlen, no cap and no draw law enters the statement. -/
theorem balanced_no_cliff (L : List ℕ) (h2 : 2 ≤ L.sum) (hhalf : ∀ m ∈ L, 2 * m ≤ L.sum) :
    3 / 4 < spearmanSq L := by
  have hM : ∀ m ∈ L, (m : ℚ) ≤ (1 / 2 : ℚ) * (L.sum : ℚ) := by
    intro m hm
    have hnat := hhalf m hm
    have hcast : (2 : ℚ) * (m : ℚ) ≤ ((L.sum : ℕ) : ℚ) := by exact_mod_cast hnat
    linarith
  have := mass_fraction_floor L (1 / 2) h2 (by norm_num) (by norm_num) hM
  norm_num at this
  linarith

/-- The real-valued form: a balanced statistic reads at most `ρ ≤ 1` but its ceiling is never
below `√(3/4) = 0.866…`, in particular never below the recorded floor `0.53`. -/
theorem balanced_no_cliff_real (L : List ℕ) (h2 : 2 ≤ L.sum) (hhalf : ∀ m ∈ L, 2 * m ≤ L.sum) :
    (53 : ℝ) / 100 < spearman L ∧ (866 : ℝ) / 1000 < spearman L := by
  have hq : (3 : ℝ) / 4 < ((spearmanSq L : ℚ) : ℝ) := by
    have hrat := balanced_no_cliff L h2 hhalf
    have hcast : (((3 : ℚ) / 4 : ℚ) : ℝ) < ((spearmanSq L : ℚ) : ℝ) := by exact_mod_cast hrat
    simpa using hcast
  rw [spearman_eq_sqrt L h2]
  constructor
  · rw [show ((53 : ℝ) / 100) = Real.sqrt ((53 / 100) ^ 2) by
      rw [Real.sqrt_sq (by norm_num)]
    ]
    apply Real.sqrt_lt_sqrt (by positivity)
    nlinarith
  · rw [show ((866 : ℝ) / 1000) = Real.sqrt ((866 / 1000) ^ 2) by
      rw [Real.sqrt_sq (by norm_num)]
    ]
    apply Real.sqrt_lt_sqrt (by positivity)
    nlinarith

/-- Every block of an actively capped profile is at most half of the sample. -/
lemma capBlocks_block_le (k r : ℕ) :
    ∀ m ∈ capBlocks (k + 1) (k + 1 + r), 2 * m ≤ 2 ^ (k + 1 + r) := by
  induction k generalizing r with
  | zero =>
      intro m hm
      have hr : 0 + 1 + r = r + 1 := by omega
      rw [hr, capBlocks_succ_succ, capBlocks_zero] at hm
      have hmv : m = 2 ^ r := by
        rcases List.mem_cons.1 hm with rfl | hm'
        · rfl
        · simpa using hm'
      subst hmv
      rw [hr, pow_succ]
      omega
  | succ j ih =>
      intro m hm
      have hb : j + 1 + 1 + r = (j + 1 + r) + 1 := by omega
      rw [hb, capBlocks_succ_succ] at hm
      have hmono : (2 : ℕ) ^ (j + 1 + r) ≤ 2 ^ (j + 1 + 1 + r) :=
        Nat.pow_le_pow_right (by norm_num) (by omega)
      rcases List.mem_cons.1 hm with rfl | hm'
      · rw [hb, pow_succ]; omega
      · have hrec := ih r m hm'
        omega

/-- Every cell of the recorded `bitlen × cap` envelope is balanced: with an active cap the
largest tie class is the odd keys, exactly half of the sample. -/
theorem capBlocks_balanced {u b : ℕ} (hu : 1 ≤ u) (hub : u ≤ b) :
    ∀ m ∈ capBlocks u b, 2 * m ≤ (capBlocks u b).sum := by
  obtain ⟨k, rfl⟩ : ∃ k, u = k + 1 := ⟨u - 1, by omega⟩
  obtain ⟨r, rfl⟩ := Nat.exists_eq_add_of_le hub
  intro m hm
  rw [capBlocks_sum' (by omega)]
  exact capBlocks_block_le k r m hm

/-- **Every cell clears the recorded floor.**  At every bitlen `b`, every active cap
`1 ≤ u ≤ b`, the tie ceiling exceeds `0.866`, hence a fortiori the recorded floor `0.53`.
There is no `(b,u)` at which tie structure could produce a breakdown. -/
theorem capped_cell_floor {u b : ℕ} (hu : 1 ≤ u) (hub : u ≤ b) :
    (53 : ℝ) / 100 < spearman (capBlocks u b) := by
  have hb : 1 ≤ b := le_trans hu hub
  exact (balanced_no_cliff_real _ (two_le_capBlocks_sum hb hub) (capBlocks_balanced hu hub)).1

/-- **Sharpness of the balance hypothesis.**  Drop it and the floor genuinely fails: the profile
`[15,1]` (one value carrying `15/16` of the mass) has ceiling `ρ² = 3/17 < 0.53²`.  So the
"no cliff" phenomenon is exactly the balance of the trailing-zero statistic, not a soft
universal fact. -/
theorem majority_block_cliff_example :
    spearmanSq [15, 1] = 3 / 17 ∧ spearmanSq [15, 1] < (53 / 100 : ℚ) ^ 2 := by
  have hsum : ([15, 1] : List ℕ).sum = 16 := by decide
  have h2 : 2 ≤ ([15, 1] : List ℕ).sum := by rw [hsum]; norm_num
  have hval : spearmanSq [15, 1] = 3 / 17 := by
    rw [spearmanSq_eq _ h2, hsum]
    norm_num [tieCorr]
  exact ⟨hval, by rw [hval]; norm_num⟩

/-- **Cliff edge.**  The floor law degrades gracefully: as long as the modal class carries at most
`84.7%` of the sample, the ceiling still clears the recorded floor `0.53`.  Together with
`majority_block_cliff_example` (a modal class of `93.75%` reading `0.42`) this locates the cliff
in the narrow window `0.848 – 0.937` of modal mass. -/
theorem mass_fraction_cliff_edge (L : List ℕ) (a : ℚ) (h2 : 2 ≤ L.sum) (ha0 : 0 ≤ a)
    (ha : a ≤ 847 / 1000) (hM : ∀ m ∈ L, (m : ℚ) ≤ a * (L.sum : ℚ)) :
    (53 : ℝ) / 100 < spearman L := by
  have hfloor := mass_fraction_floor L a h2 ha0 (by linarith) hM
  have hrat : (2825 / 10000 : ℚ) < spearmanSq L := by nlinarith
  have hq : (2825 : ℝ) / 10000 < ((spearmanSq L : ℚ) : ℝ) := by
    have hc : (((2825 : ℚ) / 10000 : ℚ) : ℝ) < ((spearmanSq L : ℚ) : ℝ) := by exact_mod_cast hrat
    push_cast at hc
    linarith
  rw [spearman_eq_sqrt L h2]
  rw [show ((53 : ℝ) / 100) = Real.sqrt ((53 / 100) ^ 2) by rw [Real.sqrt_sq (by norm_num)]]
  apply Real.sqrt_lt_sqrt (by positivity)
  nlinarith

/-! ## 5. Why `T` beats the bare count: the coarsening law, and how big the gap can be -/

lemma tieCorr_append (X Y : List ℕ) : tieCorr (X ++ Y) = tieCorr X + tieCorr Y := by
  induction X with
  | nil => simp [tieCorr]
  | cons m X ih => rw [List.cons_append, tieCorr_cons, ih, tieCorr_cons]; ring

/-- Merging two tie classes never decreases the Kendall correction. -/
lemma tieCorr_pair_le (a c : ℕ) :
    ((a : ℚ) ^ 3 - a) / 12 + ((c : ℚ) ^ 3 - c) / 12 ≤ (((a + c : ℕ) : ℚ) ^ 3 - (a + c : ℕ)) / 12 := by
  have ha : (0 : ℚ) ≤ (a : ℚ) := by positivity
  have hc : (0 : ℚ) ≤ (c : ℚ) := by positivity
  push_cast
  nlinarith [mul_nonneg (mul_nonneg ha ha) hc, mul_nonneg (mul_nonneg ha hc) hc]

/-- **Coarsening law (tie side).**  Merging two adjacent tie classes increases the Kendall tie
correction. -/
theorem tieCorr_merge_le (A B : List ℕ) (a c : ℕ) :
    tieCorr (A ++ a :: c :: B) ≤ tieCorr (A ++ (a + c) :: B) := by
  rw [tieCorr_append, tieCorr_append, tieCorr_cons, tieCorr_cons, tieCorr_cons]
  have := tieCorr_pair_le a c
  linarith

lemma merge_sum_eq (A B : List ℕ) (a c : ℕ) :
    (A ++ (a + c) :: B).sum = (A ++ a :: c :: B).sum := by
  simp [List.sum_append]
  omega

/-- **Coarsening law (ceiling side).**  Merging two adjacent tie classes can only *lower* the
attainable Spearman ceiling.  This is the structural reason a finer zero-count statistic beats
a coarser one: the bare count is a coarsening of `T`. -/
theorem spearmanSq_merge_le (A B : List ℕ) (a c : ℕ) (h2 : 2 ≤ (A ++ a :: c :: B).sum) :
    spearmanSq (A ++ (a + c) :: B) ≤ spearmanSq (A ++ a :: c :: B) := by
  have hsum := merge_sum_eq A B a c
  have h2' : 2 ≤ (A ++ (a + c) :: B).sum := by rw [hsum]; exact h2
  have hn : (2 : ℚ) ≤ ((A ++ a :: c :: B).sum : ℚ) := by exact_mod_cast h2
  have hden : (0 : ℚ) < ((A ++ a :: c :: B).sum : ℚ) ^ 3 - ((A ++ a :: c :: B).sum : ℚ) :=
    cube_sub_self_pos hn
  have hcast : (((A ++ (a + c) :: B).sum : ℕ) : ℚ) = (((A ++ a :: c :: B).sum : ℕ) : ℚ) := by
    rw [hsum]
  rw [spearmanSq_eq _ h2', spearmanSq_eq _ h2, hcast]
  have hmono := tieCorr_merge_le A B a c
  set n : ℚ := (((A ++ a :: c :: B).sum : ℕ) : ℚ) with hnq
  have hdiv : 12 * tieCorr (A ++ a :: c :: B) / (n ^ 3 - n)
      ≤ 12 * tieCorr (A ++ (a + c) :: B) / (n ^ 3 - n) :=
    div_le_div_of_nonneg_right (by linarith) hden.le
  linarith

/-- Lowering the cap by one is *exactly* a merge of the last two tie classes: the keys with
`v₂ = u` and the keys with `v₂ > u` are fused into one class. -/
theorem capBlocks_merge_last (u r : ℕ) :
    ∃ A : List ℕ, capBlocks (u + 1) (u + 1 + r) = A ++ [2 ^ r, 2 ^ r] ∧
      capBlocks u (u + 1 + r) = A ++ [2 ^ r + 2 ^ r] := by
  induction u generalizing r with
  | zero =>
      refine ⟨[], ?_, ?_⟩
      · have hr : 0 + 1 + r = r + 1 := by omega
        rw [hr, capBlocks_succ_succ, capBlocks_zero]
        simp
      · have hr : 0 + 1 + r = r + 1 := by omega
        rw [hr, capBlocks_zero]
        simp [pow_succ]
        omega
  | succ k ih =>
      obtain ⟨A, hA1, hA2⟩ := ih r
      refine ⟨2 ^ (k + 1 + r) :: A, ?_, ?_⟩
      · have hb : k + 1 + 1 + r = (k + 1 + r) + 1 := by omega
        rw [hb, capBlocks_succ_succ, hA1, List.cons_append]
      · have hb : k + 1 + 1 + r = (k + 1 + r) + 1 := by omega
        rw [hb, capBlocks_succ_succ, hA2, List.cons_append]

/-- **`T` beats the bare count, structurally.**  Without touching the closed form: the cap-`u`
profile is a one-step refinement of the cap-`(u-1)` profile, so its ceiling is at least as high. -/
theorem capped_ceiling_mono_merge (u r : ℕ) :
    spearmanSq (capBlocks u (u + 1 + r)) ≤ spearmanSq (capBlocks (u + 1) (u + 1 + r)) := by
  obtain ⟨A, hA1, hA2⟩ := capBlocks_merge_last u r
  have h2 : 2 ≤ (capBlocks (u + 1) (u + 1 + r)).sum := by
    rw [capBlocks_sum' (by omega)]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ (u + 1 + r) := Nat.pow_le_pow_right (by norm_num) (by omega)
  rw [hA1, hA2]
  rw [hA1] at h2
  exact spearmanSq_merge_le A [] (2 ^ r) (2 ^ r) (by simpa using h2)

/-- **Gap law, lower half.**  With any cap `u ≥ 2` the dial's ceiling exceeds the bare-count
(`u = 1`, parity) ceiling by at least `3/32 = 0.09375` in `ρ²`. -/
theorem gap_ceiling_lower {u b : ℕ} (hu : 2 ≤ u) (hub : u ≤ b) :
    3 / 32 ≤ spearmanSq (capBlocks u b) - spearmanSq (capBlocks 1 b) := by
  have hb : 1 ≤ b := le_trans (by omega) hub
  rw [capped_ceiling_eq hb hub, capped_ceiling_eq hb (by omega)]
  have hpow : (1 / 8 : ℚ) ^ u ≤ (1 / 8 : ℚ) ^ 2 :=
    pow_le_pow_of_le_one (by norm_num) (by norm_num) hu
  have hbf : 1 ≤ bitFactor b := le_of_lt (bitFactor_gt_one hb)
  have h64 : (1 / 8 : ℚ) ^ u ≤ 1 / 64 := by simpa using hpow
  have hcap : 3 / 32 ≤ capFactor u - capFactor 1 := by
    simp only [capFactor, pow_one]
    linarith
  have hcap0 : 0 ≤ capFactor u - capFactor 1 := by linarith
  nlinarith

/-- **Gap law, upper half.**  At *every* cell of the envelope the tie-resolution advantage of the
capped dial over the bare count is smaller than `0.07` in `ρ` — no matter how large the cap. -/
theorem gap_ceiling_upper_real {u b : ℕ} (hu : 1 ≤ u) (hub : u ≤ b) :
    spearman (capBlocks u b) - spearman (capBlocks 1 b) < 7 / 100 := by
  have hb : 1 ≤ b := le_trans hu hub
  rcases eq_or_lt_of_le hb with hb1 | hb2
  · -- degenerate cell `b = 1`, where the only active cap is `u = 1`
    have hu1 : u = 1 := by omega
    subst hu1
    have : b = 1 := hb1.symm
    subst this
    simp
  · have hb2' : 2 ≤ b := hb2
    have hsum : 2 ≤ (capBlocks u b).sum := two_le_capBlocks_sum hb hub
    have hsum1 : 2 ≤ (capBlocks 1 b).sum := two_le_capBlocks_sum hb (by omega)
    -- rational bounds on the two ceilings
    have hY : 3 / 4 ≤ spearmanSq (capBlocks 1 b) := by
      rw [capped_ceiling_eq hb (by omega)]
      have hbf : 1 ≤ bitFactor b := le_of_lt (bitFactor_gt_one hb)
      have hc : capFactor 1 = 3 / 4 := by rw [capFactor]; norm_num
      rw [hc]; linarith
    have hbfle : bitFactor b ≤ 16 / 15 := by
      have h4 : (4 : ℚ) ^ 2 ≤ (4 : ℚ) ^ b := pow_le_pow_right₀ (by norm_num) hb2'
      norm_num at h4
      have hpos : (0 : ℚ) < (4 : ℚ) ^ b - 1 := by linarith
      have : 1 / ((4 : ℚ) ^ b - 1) ≤ 1 / 15 := by
        apply div_le_div_of_nonneg_left (by norm_num) (by norm_num) (by linarith)
      rw [bitFactor]; linarith
    have hXY : spearmanSq (capBlocks u b) - spearmanSq (capBlocks 1 b) ≤ 4 / 35 := by
      rw [capped_ceiling_eq hb hub, capped_ceiling_eq hb (by omega)]
      have hpow : (0 : ℚ) ≤ (1 / 8 : ℚ) ^ u := by positivity
      have hcapdiff : capFactor u - capFactor 1 ≤ 3 / 28 := by
        simp only [capFactor, pow_one]
        linarith
      have hbf0 : 0 < bitFactor b := bitFactor_pos hb
      have hcapdiff0 : 0 ≤ capFactor u - capFactor 1 := by
        have hmono : (1 / 8 : ℚ) ^ u ≤ (1 / 8 : ℚ) ^ 1 :=
          pow_le_pow_of_le_one (by norm_num) (by norm_num) hu
        have h8 : (1 / 8 : ℚ) ^ u ≤ 1 / 8 := by simpa using hmono
        simp only [capFactor, pow_one]
        linarith
      have : (capFactor u - capFactor 1) * bitFactor b ≤ (3 / 28) * (16 / 15) := by
        apply mul_le_mul hcapdiff hbfle (le_of_lt hbf0) (by norm_num)
      nlinarith
    -- pass to real square roots
    set X : ℝ := ((spearmanSq (capBlocks u b) : ℚ) : ℝ) with hX
    set Y : ℝ := ((spearmanSq (capBlocks 1 b) : ℚ) : ℝ) with hYdef
    have hYr : (3 : ℝ) / 4 ≤ Y := by
      have hc : (((3 : ℚ) / 4 : ℚ) : ℝ) ≤ ((spearmanSq (capBlocks 1 b) : ℚ) : ℝ) := by
        exact_mod_cast hY
      rw [hYdef]
      push_cast at hc
      linarith
    have hXYr : X - Y ≤ 4 / 35 := by
      rw [hX, hYdef]
      have : ((spearmanSq (capBlocks u b) - spearmanSq (capBlocks 1 b) : ℚ) : ℝ)
          ≤ ((4 / 35 : ℚ) : ℝ) := by exact_mod_cast hXY
      push_cast at this
      linarith
    have hY0 : (0 : ℝ) ≤ Y := by linarith
    have hsY : (866 : ℝ) / 1000 ≤ Real.sqrt Y := by
      rw [Real.le_sqrt (by norm_num) hY0]
      nlinarith
    have hpos : (0 : ℝ) < Real.sqrt Y + 7 / 100 := by linarith
    have hlt : X < (Real.sqrt Y + 7 / 100) ^ 2 := by
      have hsq : Real.sqrt Y ^ 2 = Y := Real.sq_sqrt hY0
      nlinarith
    have := (Real.sqrt_lt' hpos).2 hlt
    rw [spearman_eq_sqrt _ hsum, spearman_eq_sqrt _ hsum1, ← hX, ← hYdef]
    linarith

/-- **The recorded advantage needs slack.**  The experiment reports `T` beating the bare count by
at least `0.10`.  Since tie resolution can buy less than `0.07`, the bare-count reading must sit
at least `0.03` below its own tie ceiling: the recorded advantage is *not* a granularity
artefact of `T`. -/
theorem recorded_gap_forces_slack {u b : ℕ} (hu : 1 ≤ u) (hub : u ≤ b) (rT rC : ℝ)
    (hrT : rT ≤ spearman (capBlocks u b)) (hgap : 1 / 10 ≤ rT - rC) :
    3 / 100 ≤ spearman (capBlocks 1 b) - rC := by
  have h := gap_ceiling_upper_real hu hub
  linarith

/-! ## 6. Arithmetic bridge: the capped profile really is the 2-adic block census -/

/-- The top tie class of the capped statistic: the keys below `2^b` divisible by `2^u`. -/
def cappedTopBlock (b u : ℕ) : Finset ℕ := (range (2 ^ b)).filter fun x => 2 ^ u ∣ x

/-- **Top-block cardinality.**  Exactly `2^(b-u)` of the keys below `2^b` have at least `u`
trailing binary zeros. -/
theorem card_cappedTopBlock (b u : ℕ) (h : u ≤ b) :
    (cappedTopBlock b u).card = 2 ^ (b - u) := by
  have hpu : 0 < 2 ^ u := pow_pos (by norm_num) u
  have himg : cappedTopBlock b u = (range (2 ^ (b - u))).image fun m => 2 ^ u * m := by
    ext x
    simp only [cappedTopBlock, mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hx, m, rfl⟩
      refine ⟨m, ?_, rfl⟩
      have hb : b = u + (b - u) := by omega
      rw [hb, pow_add] at hx
      exact lt_of_mul_lt_mul_left hx (Nat.zero_le _)
    · rintro ⟨m, hm, rfl⟩
      refine ⟨?_, ⟨m, rfl⟩⟩
      have hb : b = u + (b - u) := by omega
      rw [hb, pow_add]
      exact mul_lt_mul_of_pos_left hm hpu
  rw [himg, card_image_of_injective _ ?_, card_range]
  intro a c hac
  exact Nat.eq_of_mul_eq_mul_left hpu hac

/-- The capped profile in closed form: `2^(b-1), …, 2^(b-u)` followed by the top block. -/
theorem capBlocks_eq_pow_profile (u b : ℕ) (h : u ≤ b) :
    capBlocks u b = ((List.range u).map fun k => 2 ^ (b - 1 - k)) ++ [2 ^ (b - u)] := by
  induction u generalizing b with
  | zero => simp
  | succ k ih =>
      obtain ⟨c, rfl⟩ : ∃ c, b = c + 1 := ⟨b - 1, by omega⟩
      rw [capBlocks_succ_succ, ih c (by omega), List.range_succ_eq_map, List.map_cons,
        List.map_map, List.cons_append]
      simp only [Nat.succ_sub_one, Nat.sub_zero]
      have hfun : ((fun a : ℕ => 2 ^ (c - a)) ∘ Nat.succ) = (fun j : ℕ => 2 ^ (c - 1 - j)) := by
        funext j
        simp only [Function.comp_apply]
        congr 1
        omega
      have hlast : c + 1 - (k + 1) = c - k := by omega
      rw [hfun, hlast]

/-- **Arithmetic bridge.**  The tie profile used throughout this file is literally the census of
2-adic blocks of the key space `{0,…,2^b-1}` under the capped statistic `T_u = min(v₂, u)`. -/
theorem capBlocks_eq_valuation_census (u b : ℕ) (h : u ≤ b) :
    capBlocks u b
      = ((List.range u).map fun k => (twoAdicBlock b k).card) ++ [(cappedTopBlock b u).card] := by
  have hcard : ∀ k ∈ List.range u, (twoAdicBlock b k).card = 2 ^ (b - 1 - k) := by
    intro k hk
    exact card_two_adic_block b k (lt_of_lt_of_le (List.mem_range.1 hk) h)
  rw [List.map_congr_left hcard, card_cappedTopBlock b u h]
  exact capBlocks_eq_pow_profile u b h

/-! ## 7. The recorded round-54 numbers, checked against the theory -/

/-- The recorded universal floor of exp 523: `Spearman(T, rate) ≥ 0.53` at every cell. -/
def recFloor : ℚ := 53 / 100

/-- The recorded advantage of `T` over the bare count: `0.10 – 0.15`. -/
def recGapLow : ℚ := 10 / 100
def recGapHigh : ℚ := 15 / 100

/-- The validation band used across the dial programme. -/
def bandLow : ℚ := 55 / 100
def bandHigh : ℚ := 85 / 100

/-- The recorded floor is *below* the validation band floor by exactly `0.02`, and both lie
strictly below the universal tie-ceiling floor `0.866`. -/
theorem recorded_floor_position :
    recFloor < bandLow ∧ bandLow - recFloor = 2 / 100 ∧ bandHigh < 866 / 1000 := by
  refine ⟨by norm_num [recFloor, bandLow], by norm_num [recFloor, bandLow], by
    norm_num [bandHigh]⟩

/-- **Floor claim verified structurally.**  At every cell `1 ≤ u ≤ b` of the recorded envelope the
tie ceiling stays strictly above the recorded floor `0.53` — with room to spare (`0.866`).  A
reading below `0.53` therefore can never be blamed on tie granularity. -/
theorem recorded_floor_never_blocked {u b : ℕ} (hu : 1 ≤ u) (hub : u ≤ b) :
    ((recFloor : ℚ) : ℝ) < spearman (capBlocks u b) := by
  have h := capped_cell_floor hu hub
  rw [recFloor]
  push_cast
  linarith

/-- **Gap claim exceeds tie capacity.**  The recorded advantage band `[0.10, 0.15]` lies strictly
above the largest tie-resolution advantage available at any cell. -/
theorem recorded_gap_above_tie_capacity {u b : ℕ} (hu : 1 ≤ u) (hub : u ≤ b) :
    spearman (capBlocks u b) - spearman (capBlocks 1 b) < ((recGapLow : ℚ) : ℝ) ∧
      spearman (capBlocks u b) - spearman (capBlocks 1 b) < ((recGapHigh : ℚ) : ℝ) := by
  have h := gap_ceiling_upper_real hu hub
  constructor
  · rw [recGapLow]; push_cast; linarith
  · rw [recGapHigh]; push_cast; linarith

/-- Two sample cells of the envelope, evaluated exactly:
`ρ²(8,2) = (6/7)(63/64)(65536/65535)` and `ρ²(8,1) = (3/4)(65536/65535)`. -/
theorem sample_cells_exact :
    spearmanSq (capBlocks 2 8) = 6 / 7 * (1 - (1 / 8 : ℚ) ^ 2) * (1 + 1 / ((4 : ℚ) ^ 8 - 1)) ∧
      spearmanSq (capBlocks 1 8) = 6 / 7 * (1 - (1 / 8 : ℚ)) * (1 + 1 / ((4 : ℚ) ^ 8 - 1)) := by
  refine ⟨capped_ceiling_factorisation (by norm_num) (by norm_num), ?_⟩
  have h := capped_ceiling_factorisation (u := 1) (b := 8) (by norm_num) (by norm_num)
  rw [h, pow_one]

/-!
## Lab notes (exp 523, `exp523_balanced_bkey.py`, seeds `20261100 + bitlen`)

Recorded verdict `DIAL-ROBUST`:

* `Spearman(T, rate) ≥ 0.53` at every tested `bitlen × u` cell;
* `T` beats the bare count by `0.10 – 0.15`;
* no cliff, no breakdown, no convention artefact.

Exact tie ceilings `ρ(b,u) = √((6/7)(1-8^{-u})(1+1/(4^b-1)))` computed from
`capped_ceiling_factorisation` (exact rational arithmetic, then rounded):

| b \\ u | 1 | 2 | 3 | 4 | 6 | 8 |
|---|---|---|---|---|---|---|
| 8  | 0.866032 | 0.918566 | 0.924923 | 0.925714 | 0.925825 | 0.925827 |
| 16 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| 32 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| 44 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| 52 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| 64 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |

Observations, all of them theorems above:

* every entry exceeds `0.866` — far above the recorded floor `0.53`
  (`capped_cell_floor`, `recorded_floor_never_blocked`), and the floor survives *any* balanced
  draw law, not just the dyadic one (`balanced_no_cliff`);
* the columns are proportional to each other and so are the rows: the table is rank one
  (`ceiling_table_rank_one`).  Movement along a column is below `10^{-5}` already at `b = 8` and
  below `2·4^{-b}` in general (`bitlen_movement_small`);
* the largest column-to-column movement is `u = 1 → u = ∞`, worth
  `0.925820 - 0.866025 = 0.059795` — below the `0.07` bound of `gap_ceiling_upper_real` and
  well below the recorded advantage band `[0.10, 0.15]` (`recorded_gap_above_tie_capacity`);
* sample gaps: `b = 8, u = 2` gives `0.052534`; `b = 16, u = 8` gives `0.059795`.

Sanity checks in exact `ℚ` while developing the file:

| profile | `ρ²` from `spearmanSq_eq` | source |
|---|---|---|
| `capBlocks 0 3 = [8]` | `0` | one block carries everything |
| `capBlocks 1 3 = [4,4]` | `48/63 = 16/21` | `(3/4)(1+1/63)` |
| `capBlocks 2 3 = [4,2,2]` | `0.857… = 54/63` | `(6/7)(63/64)(64/63)` |
| `capBlocks 3 3 = dyadicBlocks 3` | `(6/7)(1+1/72)` | `capped_ceiling_at_full_cap` |
| `[15,1]` | `3/17 = 0.1765` | the majority-block cliff |

The last row is the boundary case: a single class carrying `15/16` of the mass reads below
`0.53`, which is exactly why the balance hypothesis in `balanced_no_cliff` cannot be dropped
(`majority_block_cliff_example`).
-/

end Catalog.Cryptography.BalancedBKeyDialRobustness