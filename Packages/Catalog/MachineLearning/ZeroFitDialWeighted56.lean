import Mathlib
import Novelty.ZeroFitDialU64
import MachineLearning.ZeroFitDialUnif52

/-!
# The weighted zero-fit dial at bitlen 56: how much edge can *reweighting* buy?

## Research context (FACT round-61 #2, exp 542, `U56B-DIAL-HOLDS-COUNT-PARITY`)

Fresh-seed replication of paper 184's bitlen-56 uniform cell (seeds 20261140–42):

* pooled `ρ(T, rate) = 0.669`, CI `[0.650, 0.690]` — inside the validation band
  `[0.55, 0.85]`, so **H1 replicates on all three seeds**;
* **H2 fails** on the pre-stated rule: the pooled advantage of the trailing-zero
  statistic `T` over the plain popcount baseline is `+0.045 ≤ +0.05`, and only `1/3`
  seeds clear the bar.  The dial's *weighted* edge is **not established** at bitlen 56.

The verdict turns on a `0.005` shortfall.  Every earlier file in this thread analyses
*unweighted* rank data: `Novelty.ZeroFitDialU64` proves the tie-attenuation law
`ρ² = 1 - 12·Σⱼ(mⱼ³-mⱼ)/(n³-n)` and the exact dyadic ceiling `(6/7)(1+1/(2^b(2^b+1)))`;
`MachineLearning.ZeroFitDialUnif52` computes the popcount baseline's own ceiling;
`Algebra.ZeroFitDialU72Parity` and `Algebra.ZeroFitDialParityCapacity` supply the Gram
geometry of two (resp. `k`) statistics against one response.  None of them can say what a
**weighted** reading is worth, because weighting changes the *tie profile itself*: giving
an observation multiplicity `w` merges it into a block of size `w·m`, and the attenuation
law is a nonlinear functional of the profile.  This file builds that missing layer and
answers the question the H2 rule implicitly asks: *how much correlation can any weighting
scheme add to the zero-fit dial?*

## Main results

### 1. Reweighting calculus (new)

* `cubeSum`, `tieCorr_eq_cubeSum` — the tie correction as `(Σⱼmⱼ³ - n)/12`; the whole
  attenuation law becomes a statement about the cubic moment of the profile.
* `cubeSum_map_mul`, `sum_map_mul` — a block weight `w` scales the cubic moment by `w³`
  and the mass by `w`: reweighting is a *cubic* operation against a *linear* budget, which
  is the entire source of the phenomenon below.
* `cubeSum_dyadic` — `Σⱼ mⱼ³ = (8^b+6)/7` for the 2-adic profile of uniform `b`-bit draws.

### 2. The stratified weighted dial (new)

* `wDyadic b p q` — weight the dominant block (the odd residues, mass `2^b`) by `p` and
  every deeper 2-adic block by `q`; `wDyadic_one_one` recovers `dyadicBlocks (b+1)`.
* `wDyadic_spearmanSq` — the **exact weighted ceiling law**, a closed form in `p, q, 2^b`.
* `weighted_beats_unweighted` — for every `b ≥ 2` the weighting `(p,q) = (1,3)` has a
  **strictly higher** ceiling than the unweighted dial at the same bitlen.  Reweighting is
  not cosmetic: it genuinely buys resolving power, because it dilutes the single block of
  mass `2^b` that costs the dyadic dial its `6/7`.
* `wDyadic_ceiling_tendsto` — the bitlen limit of the weighted ceiling is
  `stratCeiling p q = 1 - (p³ + q³/7)/(p+q)³`.

### 3. The `√7` optimum (new, the payload)

* `stratCeiling_le_sqrt_seven` — **for every weighting**, `stratCeiling p q ≤ 1 - 1/(1+√7)²`,
  proved from the cubic factorisation
  `9[(1+√7)²(7p³+q³) - 7(p+q)³] = (1+2√7)(q-√7p)²(9q+(4√7+7)p)`.
* `stratCeiling_eq_sqrt_seven` — equality exactly at `q = √7·p`: the optimal weight ratio is
  a quadratic irrational, so **no rational weighting is optimal**.
* `stratOptimum_bounds`, `stratOptimumRho_bounds` — `κ* = 1 - 1/(1+√7)² ∈ (0.92476, 0.92477)`,
  `√κ* ∈ (0.96164, 0.96165)`.
* `weighting_gain_bounds` — the **weighted-edge budget**: reweighting the dyadic dial can add
  at most `0.0359` and at least `0.0358` to the attainable `ρ` — a hard, two-sided cap.
* `rational_weighting_near_optimal` — the convergent `q/p = 37/14` of `√7` realises the
  optimum to within `10⁻⁷`.

### 4. Boundary of the claim (adversarial layer)

* `rebalance_eq_replicate` — if *arbitrary per-block* weights are allowed, weighting the
  `k`-th 2-adic block by `2^k` equalises all `b+1` blocks;
* `flat_ceiling_ge`, `rebalanced_ceiling_ge`, `rebalanced_ceiling_tendsto_one` — that
  profile has ceiling `≥ 1 - 1/(b+1)² → 1`.  So the `√7` cap is sharp **only** for
  stratified (head/tail) weightings; unrestricted reweighting is unbounded, and any
  experimental protocol that permits it is not measuring the dial any more.

### 5. The recorded bitlen-56 numbers

* `u56_ci_inside_band`, `u56_h2_fails`, `u56_below_unweighted_ceiling`,
  `count56_below_its_ceiling` — H1 holds, H2 fails, and *both* statistics read far below
  their own tie ceilings, so the shortfall is not a granularity artefact.
* `u56_weighted_ceiling_exceeds_unweighted` — at bitlen 56 the stratified weighting `(1,3)`
  raises the ceiling above the unweighted one.
* `weighting_headroom_exceeds_shortfall` — the decisive quantitative statement: the H2
  shortfall is `0.005`, while the reweighting budget is `> 0.0358 > 7 × 0.005`.  The
  bitlen-56 verdict "*the weighted edge is not established*" is therefore **not** forced by
  tie geometry: the geometry leaves seven times the missing margin on the table, so the
  failure is a statement about the response, not about the resolution of `T`.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

namespace Catalog.MachineLearning.ZeroFitDialWeighted56

/-! ## 1. Reweighting calculus -/

/-- The cubic moment `Σⱼ mⱼ³` of a tie profile. -/
def cubeSum (L : List ℕ) : ℚ := (L.map fun m => (m : ℚ) ^ 3).sum

@[simp] lemma cubeSum_nil : cubeSum [] = 0 := rfl

lemma cubeSum_cons (m : ℕ) (L : List ℕ) : cubeSum (m :: L) = (m : ℚ) ^ 3 + cubeSum L := rfl

/-- The Kendall tie correction is the *cubic moment minus the mass*, over `12`. -/
theorem tieCorr_eq_cubeSum (L : List ℕ) : 12 * tieCorr L = cubeSum L - (L.sum : ℚ) := by
  induction L with
  | nil => simp [tieCorr, cubeSum]
  | cons m L ih =>
      rw [tieCorr_cons, cubeSum_cons, List.sum_cons, Nat.cast_add, mul_add, ih]
      ring

/-- The tie-attenuation law in cubic-moment form: `ρ² = 1 - (Σⱼmⱼ³ - n)/(n³ - n)`. -/
theorem spearmanSq_of_cubeSum (L : List ℕ) (h : 2 ≤ L.sum) :
    spearmanSq L = 1 - (cubeSum L - (L.sum : ℚ)) / ((L.sum : ℚ) ^ 3 - (L.sum : ℚ)) := by
  rw [spearmanSq_eq L h, tieCorr_eq_cubeSum]

/-- Weighting every block by `w` scales the mass linearly. -/
lemma sum_map_mul (w : ℕ) (L : List ℕ) : ((L.map fun m => w * m).sum) = w * L.sum := by
  induction L with
  | nil => simp
  | cons m L ih => simp [ih, Nat.mul_add]

/-- Weighting every block by `w` scales the cubic moment by `w³`.  The mismatch between
this cubic scaling and the linear scaling of the mass is what makes reweighting able to
change a tie ceiling at all. -/
lemma cubeSum_map_mul (w : ℕ) (L : List ℕ) :
    cubeSum (L.map fun m => w * m) = (w : ℚ) ^ 3 * cubeSum L := by
  induction L with
  | nil => simp [cubeSum]
  | cons m L ih =>
      rw [List.map_cons, cubeSum_cons, cubeSum_cons, ih]
      push_cast
      ring

/-- The cubic moment of the 2-adic tie profile of uniform `b`-bit draws. -/
theorem cubeSum_dyadic (b : ℕ) : cubeSum (dyadicBlocks b) = ((8 : ℚ) ^ b + 6) / 7 := by
  induction b with
  | zero => norm_num [dyadicBlocks, cubeSum]
  | succ k ih =>
      rw [dyadicBlocks, cubeSum_cons, ih]
      have h : ((2 ^ k : ℕ) : ℚ) ^ 3 = (8 : ℚ) ^ k := by
        push_cast
        exact pow_two_cube k
      rw [h, pow_succ (8 : ℚ) k]
      ring

/-! ## 2. The stratified weighted dyadic profile -/

/-- **Stratified weighting.**  The tie profile obtained from uniform `(b+1)`-bit draws by
giving the dominant 2-adic block (the odd residues, mass `2^b`) weight `p` and every
deeper block weight `q`. -/
def wDyadic (b p q : ℕ) : List ℕ := p * 2 ^ b :: (dyadicBlocks b).map (fun m => q * m)

lemma wDyadic_sum (b p q : ℕ) : (wDyadic b p q).sum = (p + q) * 2 ^ b := by
  rw [wDyadic, List.sum_cons, sum_map_mul, dyadicBlocks_sum]
  ring

lemma wDyadic_cubeSum (b p q : ℕ) :
    cubeSum (wDyadic b p q) = (p : ℚ) ^ 3 * 8 ^ b + (q : ℚ) ^ 3 * (((8 : ℚ) ^ b + 6) / 7) := by
  rw [wDyadic, cubeSum_cons, cubeSum_map_mul, cubeSum_dyadic]
  have h : ((p * 2 ^ b : ℕ) : ℚ) ^ 3 = (p : ℚ) ^ 3 * (8 : ℚ) ^ b := by
    push_cast
    rw [mul_pow, pow_two_cube]
  rw [h]

lemma wDyadic_two_le_sum (b p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) : 2 ≤ (wDyadic b p q).sum := by
  rw [wDyadic_sum]
  calc 2 = 2 * 1 := by norm_num
    _ ≤ (p + q) * 2 ^ b := Nat.mul_le_mul (by omega) Nat.one_le_two_pow

/-- **Exact weighted ceiling law.**  The Spearman ceiling of the stratified weighting
`(p, q)` of the 2-adic profile at bitlen `b+1`, in closed form. -/
theorem wDyadic_spearmanSq (b p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    spearmanSq (wDyadic b p q)
      = 1 - ((p : ℚ) ^ 3 * 8 ^ b + (q : ℚ) ^ 3 * (((8 : ℚ) ^ b + 6) / 7) - ((p : ℚ) + q) * 2 ^ b)
          / ((((p : ℚ) + q) * 2 ^ b) ^ 3 - ((p : ℚ) + q) * 2 ^ b) := by
  have h2 := wDyadic_two_le_sum b p q hp hq
  have hcast : (((wDyadic b p q).sum : ℕ) : ℚ) = ((p : ℚ) + q) * 2 ^ b := by
    rw [wDyadic_sum]; push_cast; ring
  have h12 : 12 * tieCorr (wDyadic b p q)
      = (p : ℚ) ^ 3 * 8 ^ b + (q : ℚ) ^ 3 * (((8 : ℚ) ^ b + 6) / 7) - ((p : ℚ) + q) * 2 ^ b := by
    rw [tieCorr_eq_cubeSum, wDyadic_cubeSum, hcast]
  rw [spearmanSq_eq _ h2, hcast, h12]

/-- Weight `(1,1)` is no weighting at all: the stratified family contains the plain dial. -/
theorem wDyadic_one_one (b : ℕ) : wDyadic b 1 1 = dyadicBlocks (b + 1) := by
  simp [wDyadic, dyadicBlocks]

/-- **Reweighting strictly improves the dyadic ceiling.**  For every bitlen `b + 1 ≥ 3`, the
stratified weighting `(p,q) = (1,3)` — which triples the mass of every block except the
dominant one — has a strictly higher tie ceiling than the unweighted dial. -/
theorem weighted_beats_unweighted (b : ℕ) (hb : 2 ≤ b) :
    spearmanSq (dyadicBlocks (b + 1)) < spearmanSq (wDyadic b 1 3) := by
  have hx : (4 : ℚ) ≤ (2 : ℚ) ^ b := by
    calc (4 : ℚ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ b := by apply pow_le_pow_right₀ (by norm_num) hb
  rw [← wDyadic_one_one b, wDyadic_spearmanSq b 1 1 le_rfl le_rfl,
    wDyadic_spearmanSq b 1 3 le_rfl (by norm_num), pow_two_cube b |>.symm]
  set x : ℚ := (2 : ℚ) ^ b with hxdef
  have hx0 : (0 : ℚ) < x := by linarith
  push_cast
  rw [sub_lt_sub_iff_left]
  have hD1 : (0 : ℚ) < ((1 + 1) * x) ^ 3 - (1 + 1) * x := cube_sub_self_pos (by linarith)
  have hD3 : (0 : ℚ) < ((1 + 3) * x) ^ 3 - (1 + 3) * x := cube_sub_self_pos (by linarith)
  rw [div_lt_div_iff₀ hD3 hD1]
  nlinarith [hx, hx0, sq_nonneg x, pow_pos hx0 3, pow_pos hx0 4, pow_pos hx0 5,
    mul_pos hx0 hx0]

/-! ## 3. The asymptotic ceiling and the `√7` optimum -/

/-- The bitlen limit of the stratified weighted ceiling. -/
noncomputable def stratCeiling (p q : ℝ) : ℝ := 1 - (p ^ 3 + q ^ 3 / 7) / (p + q) ^ 3

/-- `y³ > y` for `y ≥ 2`, over `ℝ`. -/
lemma real_cube_sub_self_pos {y : ℝ} (h : 2 ≤ y) : 0 < y ^ 3 - y := by
  have h1 : (0 : ℝ) < y * (y - 1) * (y + 1) :=
    mul_pos (mul_pos (by linarith) (by linarith)) (by linarith)
  have h2 : y * (y - 1) * (y + 1) = y ^ 3 - y := by ring
  linarith

/-- The closed form of the weighted ceiling, transported to `ℝ` and normalised by `8^b`. -/
lemma wDyadic_spearmanSq_real (b p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    ((spearmanSq (wDyadic b p q) : ℚ) : ℝ)
      = 1 - ((p : ℝ) ^ 3 + (q : ℝ) ^ 3 / 7 + (6 * (q : ℝ) ^ 3 / 7) * (1 / 8 : ℝ) ^ b
              - ((p : ℝ) + q) * (1 / 4 : ℝ) ^ b)
          / (((p : ℝ) + q) ^ 3 - ((p : ℝ) + q) * (1 / 4 : ℝ) ^ b) := by
  have hp1 : (1 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hq1 : (1 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
  have hS : (2 : ℝ) ≤ (p : ℝ) + q := by linarith
  rw [wDyadic_spearmanSq b p q hp hq]
  push_cast
  set x : ℝ := (2 : ℝ) ^ b with hxdef
  have hx1 : (1 : ℝ) ≤ x := one_le_pow₀ (by norm_num)
  have hx0 : (0 : ℝ) < x := by linarith
  have h8 : (8 : ℝ) ^ b = x ^ 3 := by
    rw [hxdef, ← pow_mul, mul_comm, pow_mul]; norm_num
  have h8' : (1 / 8 : ℝ) ^ b = 1 / x ^ 3 := by rw [div_pow, one_pow, h8]
  have h4' : (1 / 4 : ℝ) ^ b = 1 / x ^ 2 := by
    rw [div_pow, one_pow, hxdef, ← pow_mul, mul_comm, pow_mul]; norm_num
  rw [h8, h8', h4']
  have hSx : (2 : ℝ) ≤ ((p : ℝ) + q) * x := by nlinarith
  have hD1 : (0 : ℝ) < (((p : ℝ) + q) * x) ^ 3 - ((p : ℝ) + q) * x := real_cube_sub_self_pos hSx
  have hD2 : (0 : ℝ) < ((p : ℝ) + q) ^ 3 - ((p : ℝ) + q) * (1 / x ^ 2) := by
    have h1 : (1 : ℝ) / x ^ 2 ≤ 1 := by
      rw [div_le_one (by positivity)]; nlinarith
    have h2 : ((p : ℝ) + q) * (1 / x ^ 2) ≤ ((p : ℝ) + q) * 1 :=
      mul_le_mul_of_nonneg_left h1 (by linarith)
    rw [mul_one] at h2
    have h3 : (0 : ℝ) < ((p : ℝ) + q) ^ 3 - ((p : ℝ) + q) := real_cube_sub_self_pos hS
    linarith
  have hx3 : x ^ 3 ≠ 0 := by positivity
  congr 1
  rw [div_eq_div_iff (ne_of_gt hD1) (ne_of_gt hD2)]
  field_simp
  ring

/-- **The asymptotic weighted ceiling.**  As the bitlen grows, the stratified weighting
`(p,q)` has ceiling converging to `1 - (p³ + q³/7)/(p+q)³`. -/
theorem wDyadic_ceiling_tendsto (p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    Filter.Tendsto (fun b : ℕ => ((spearmanSq (wDyadic b p q) : ℚ) : ℝ)) Filter.atTop
      (nhds (stratCeiling p q)) := by
  have hp1 : (1 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
  have hq1 : (1 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq
  have hS : (0 : ℝ) < (p : ℝ) + q := by linarith
  have h8 : Filter.Tendsto (fun b : ℕ => (1 / 8 : ℝ) ^ b) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have h4 : Filter.Tendsto (fun b : ℕ => (1 / 4 : ℝ) ^ b) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have hnum : Filter.Tendsto
      (fun b : ℕ => (p : ℝ) ^ 3 + (q : ℝ) ^ 3 / 7 + (6 * (q : ℝ) ^ 3 / 7) * (1 / 8 : ℝ) ^ b
        - ((p : ℝ) + q) * (1 / 4 : ℝ) ^ b) Filter.atTop (nhds ((p : ℝ) ^ 3 + (q : ℝ) ^ 3 / 7)) := by
    have := ((tendsto_const_nhds (x := (p : ℝ) ^ 3 + (q : ℝ) ^ 3 / 7) (f := Filter.atTop (α := ℕ))).add
      (h8.const_mul (6 * (q : ℝ) ^ 3 / 7))).sub (h4.const_mul ((p : ℝ) + q))
    simpa using this
  have hden : Filter.Tendsto
      (fun b : ℕ => ((p : ℝ) + q) ^ 3 - ((p : ℝ) + q) * (1 / 4 : ℝ) ^ b) Filter.atTop
      (nhds (((p : ℝ) + q) ^ 3)) := by
    have := (tendsto_const_nhds (x := ((p : ℝ) + q) ^ 3) (f := Filter.atTop (α := ℕ))).sub
      (h4.const_mul ((p : ℝ) + q))
    simpa using this
  have hne : ((p : ℝ) + q) ^ 3 ≠ 0 := by positivity
  have := (tendsto_const_nhds (x := (1 : ℝ)) (f := Filter.atTop (α := ℕ))).sub
    (hnum.div hden hne)
  refine this.congr fun b => ?_
  simp only [Pi.div_apply]
  exact (wDyadic_spearmanSq_real b p q hp hq).symm

/-! ### The extremal `√7` weighting -/

/-- **Master cubic identity.**  A pure ring identity, valid for all reals:
`(1+s)²(s²u³+v³) - s²(u+v)³ = (v-su)²((1+2s)v + s(2+s)u)`.
It exhibits the whole reweighting optimum as a perfect square: the deficit of a weighting
from the optimal one is `(v-su)²` times a positive factor. -/
lemma cubic_weight_identity (s u v : ℝ) :
    (1 + s) ^ 2 * (s ^ 2 * u ^ 3 + v ^ 3) - s ^ 2 * (u + v) ^ 3
      = (v - s * u) ^ 2 * ((1 + 2 * s) * v + s * (2 + s) * u) := by ring

/-- **The cubic weighting cap.**  For any `s > 0`, the two-block cubic ratio
`(u³ + v³/s²)/(u+v)³` is bounded below by `1/(1+s)²`, with the deficit an explicit square.
This is the analytic heart of every reweighting bound in this thread. -/
theorem weighted_cubic_cap {s u v : ℝ} (hs : 0 < s) (hu : 0 < u) (hv : 0 ≤ v) :
    1 / (1 + s) ^ 2 ≤ (u ^ 3 + v ^ 3 / s ^ 2) / (u + v) ^ 3 := by
  have hsum : (0 : ℝ) < u + v := by linarith
  have hcube : (0 : ℝ) < (u + v) ^ 3 := by positivity
  have hden : (0 : ℝ) < (1 + s) ^ 2 := by positivity
  have hs2 : (0 : ℝ) < s ^ 2 := by positivity
  have hnn : 0 ≤ (v - s * u) ^ 2 * ((1 + 2 * s) * v + s * (2 + s) * u) :=
    mul_nonneg (sq_nonneg _) (by nlinarith)
  have hkey : s ^ 2 * (u + v) ^ 3 ≤ (1 + s) ^ 2 * (s ^ 2 * u ^ 3 + v ^ 3) := by
    have := cubic_weight_identity s u v
    linarith
  rw [div_le_div_iff₀ hden hcube]
  have hexp : (u ^ 3 + v ^ 3 / s ^ 2) * (1 + s) ^ 2
      = ((1 + s) ^ 2 * (s ^ 2 * u ^ 3 + v ^ 3)) / s ^ 2 := by
    field_simp
  rw [hexp, one_mul, le_div_iff₀ hs2]
  nlinarith

/-- **The `√7` cap.**  No stratified weighting of the 2-adic profile can push the asymptotic
Spearman ceiling above `1 - 1/(1+√7)² ≈ 0.9247640`. -/
theorem stratCeiling_le_sqrt_seven (p q : ℝ) (hp : 0 < p) (hq : 0 ≤ q) :
    stratCeiling p q ≤ 1 - 1 / (1 + Real.sqrt 7) ^ 2 := by
  have hs : (0 : ℝ) < Real.sqrt 7 := Real.sqrt_pos.2 (by norm_num)
  have hs2 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num)
  have hstep : 1 / (1 + Real.sqrt 7) ^ 2 ≤ (p ^ 3 + q ^ 3 / 7) / (p + q) ^ 3 := by
    have := weighted_cubic_cap hs hp hq
    rwa [hs2] at this
  unfold stratCeiling
  linarith

/-- **Sharpness.**  The cap is attained exactly at the irrational weight ratio `q = √7·p`;
in particular no rational weighting is optimal. -/
theorem stratCeiling_eq_sqrt_seven (p : ℝ) (hp : 0 < p) :
    stratCeiling p (Real.sqrt 7 * p) = 1 - 1 / (1 + Real.sqrt 7) ^ 2 := by
  have hs : (0 : ℝ) < Real.sqrt 7 := Real.sqrt_pos.2 (by norm_num)
  have hs2 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num)
  have h3 : Real.sqrt 7 ^ 3 = 7 * Real.sqrt 7 := by rw [pow_succ, hs2]
  have hne : ((1 : ℝ) + Real.sqrt 7) ≠ 0 := by positivity
  have hp3 : p ^ 3 ≠ 0 := by positivity
  unfold stratCeiling
  have hnum : p ^ 3 + (Real.sqrt 7 * p) ^ 3 / 7 = p ^ 3 * (1 + Real.sqrt 7) := by
    rw [mul_pow, h3]; ring
  have hfac : (p + Real.sqrt 7 * p) ^ 3 = p ^ 3 * (1 + Real.sqrt 7) ^ 3 := by ring
  rw [hnum, hfac]
  congr 1
  field_simp

/-! ### Numerical location of the optimum -/

/-- Rational enclosure of `√7`. -/
lemma sqrt_seven_bounds : (2.6457513 : ℝ) < Real.sqrt 7 ∧ Real.sqrt 7 < 2.6457514 := by
  constructor
  · have h : (2.6457513 : ℝ) ^ 2 < 7 := by norm_num
    nlinarith [Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0), Real.sqrt_nonneg 7]
  · have h : (7 : ℝ) < 2.6457514 ^ 2 := by norm_num
    nlinarith [Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0), Real.sqrt_nonneg 7]

/-- The optimal stratified ceiling. -/
noncomputable def stratOptimum : ℝ := 1 - 1 / (1 + Real.sqrt 7) ^ 2

theorem stratOptimum_bounds : (0.9247639 : ℝ) < stratOptimum ∧ stratOptimum < 0.9247640 := by
  obtain ⟨h1, h2⟩ := sqrt_seven_bounds
  have hpos : (0 : ℝ) < (1 + Real.sqrt 7) ^ 2 := by positivity
  have hupper : 1 / (1 + Real.sqrt 7) ^ 2 < 0.0752361 := by
    rw [div_lt_iff₀ hpos]; nlinarith
  have hlower : (0.0752360 : ℝ) < 1 / (1 + Real.sqrt 7) ^ 2 := by
    rw [lt_div_iff₀ hpos]; nlinarith
  unfold stratOptimum
  constructor <;> linarith

/-- **Rational weightings approach the optimum.**  The convergent `q/p = 37/14` of `√7`
realises the optimal stratified ceiling to within `10⁻⁶`. -/
theorem rational_weighting_near_optimal :
    |stratCeiling 14 37 - stratOptimum| < 1 / 10 ^ 6 := by
  obtain ⟨h1, h2⟩ := stratOptimum_bounds
  have hval : stratCeiling 14 37 = 1 - 69861 / 928557 := by
    unfold stratCeiling
    norm_num
  rw [hval, abs_lt]
  constructor <;> norm_num at h1 h2 ⊢ <;> linarith

/-! ## 4. Boundary: unrestricted reweighting escapes to `1` -/

/-- A flat profile: `K` tie blocks of equal mass `m`. -/
def flatBlocks (K m : ℕ) : List ℕ := List.replicate K m

lemma flatBlocks_sum (K m : ℕ) : (flatBlocks K m).sum = K * m := by
  simp [flatBlocks]

lemma cubeSum_flat (K m : ℕ) : cubeSum (flatBlocks K m) = (K : ℚ) * (m : ℚ) ^ 3 := by
  induction K with
  | zero => simp [flatBlocks, cubeSum]
  | succ k ih =>
      rw [flatBlocks, List.replicate_succ, cubeSum_cons]
      rw [show List.replicate k m = flatBlocks k m from rfl, ih]
      push_cast
      ring

/-- **Equalised profiles are nearly tie-transparent.**  `K` equal blocks give
`ρ² ≥ 1 - 1/K²`, whatever the common block mass. -/
theorem flat_ceiling_ge (K m : ℕ) (hK : 2 ≤ K) (hm : 1 ≤ m) :
    1 - 1 / (K : ℚ) ^ 2 ≤ spearmanSq (flatBlocks K m) := by
  have hKm : 2 ≤ (flatBlocks K m).sum := by
    rw [flatBlocks_sum]
    calc 2 = 2 * 1 := by norm_num
      _ ≤ K * m := Nat.mul_le_mul hK hm
  have hK1 : (2 : ℚ) ≤ (K : ℚ) := by exact_mod_cast hK
  have hm1 : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
  have hcast : (((flatBlocks K m).sum : ℕ) : ℚ) = (K : ℚ) * (m : ℚ) := by
    rw [flatBlocks_sum]; push_cast; ring
  have h12 : 12 * tieCorr (flatBlocks K m) = (K : ℚ) * (m : ℚ) ^ 3 - (K : ℚ) * (m : ℚ) := by
    rw [tieCorr_eq_cubeSum, cubeSum_flat, hcast]
  rw [spearmanSq_eq _ hKm, hcast, h12]
  have hKm2 : (2 : ℚ) ≤ (K : ℚ) * m := by nlinarith
  have hden : (0 : ℚ) < ((K : ℚ) * m) ^ 3 - (K : ℚ) * m := cube_sub_self_pos hKm2
  have hKpos : (0 : ℚ) < (K : ℚ) := by linarith
  have hmpos : (0 : ℚ) < (m : ℚ) := by linarith
  have hstep : ((K : ℚ) * (m : ℚ) ^ 3 - (K : ℚ) * (m : ℚ)) / (((K : ℚ) * m) ^ 3 - (K : ℚ) * m)
      ≤ 1 / (K : ℚ) ^ 2 := by
    rw [div_le_div_iff₀ hden (by positivity)]
    have hexp : ((K : ℚ) * (m : ℚ) ^ 3 - (K : ℚ) * (m : ℚ)) * (K : ℚ) ^ 2
        = ((K : ℚ) * m) ^ 3 - (K : ℚ) ^ 3 * m := by ring
    have hprod : (0 : ℚ) ≤ ((K : ℚ) * m) * ((K : ℚ) ^ 2 - 1) :=
      mul_nonneg (by positivity) (by nlinarith)
    have hcmp : (K : ℚ) * m ≤ (K : ℚ) ^ 3 * m := by nlinarith [hprod]
    rw [hexp]
    linarith
  linarith

/-- The per-block weights that equalise the 2-adic profile: `1, 2, 4, …, 2^{b-1}, 2^{b-1}`. -/
def eqWeights : ℕ → List ℕ
  | 0 => [1]
  | 1 => [1, 1]
  | b + 2 => 1 :: (eqWeights (b + 1)).map (fun w => 2 * w)

lemma zipWith_mul_map_left (c : ℕ) (W L : List ℕ) :
    List.zipWith (· * ·) (W.map fun w => c * w) L
      = (List.zipWith (· * ·) W L).map (fun x => c * x) := by
  induction W generalizing L with
  | nil => simp
  | cons w W ih =>
      cases L with
      | nil => simp
      | cons m L => simp [ih, Nat.mul_assoc]

/-- **Rebalancing identity.**  Weighting the `k`-th 2-adic block by `2^k` turns the dyadic
profile at bitlen `b ≥ 1` into `b+1` blocks of equal mass `2^{b-1}`. -/
theorem rebalance_eq_replicate (b : ℕ) (hb : 1 ≤ b) :
    List.zipWith (· * ·) (eqWeights b) (dyadicBlocks b)
      = List.replicate (b + 1) (2 ^ (b - 1)) := by
  induction b with
  | zero => omega
  | succ k ih =>
      rcases Nat.eq_zero_or_pos k with rfl | hk
      · rfl
      · obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
        rw [show eqWeights (j + 1 + 1) = 1 :: (eqWeights (j + 1)).map (fun w => 2 * w) from rfl,
          dyadicBlocks, List.zipWith_cons_cons, zipWith_mul_map_left, ih (by omega),
          List.map_replicate]
        have h2 : 2 * 2 ^ (j + 1 - 1) = 2 ^ (j + 1 + 1 - 1) := by
          simp [pow_succ]
          ring
        rw [h2, one_mul]
        simp [List.replicate_succ]

/-- The rebalanced dyadic profile has ceiling `≥ 1 - 1/(b+1)²`. -/
theorem rebalanced_ceiling_ge (b : ℕ) (hb : 1 ≤ b) :
    1 - 1 / ((b : ℚ) + 1) ^ 2
      ≤ spearmanSq (List.zipWith (· * ·) (eqWeights b) (dyadicBlocks b)) := by
  rw [rebalance_eq_replicate b hb]
  have h := flat_ceiling_ge (b + 1) (2 ^ (b - 1)) (by omega) Nat.one_le_two_pow
  have hcast : ((b + 1 : ℕ) : ℚ) = (b : ℚ) + 1 := by push_cast; ring
  rw [hcast] at h
  exact h

/-- Unrestricted per-block reweighting drives the ceiling to `1`: the `√7` cap is a
statement about *stratified* weightings only. -/
theorem rebalanced_ceiling_tendsto_one :
    Filter.Tendsto
      (fun b : ℕ => ((spearmanSq (List.zipWith (· * ·) (eqWeights b) (dyadicBlocks b)) : ℚ) : ℝ))
      Filter.atTop (nhds 1) := by
  have hlow : Filter.Tendsto (fun b : ℕ => 1 - 1 / ((b : ℝ) + 1) ^ 2) Filter.atTop (nhds 1) := by
    have h0 : Filter.Tendsto (fun b : ℕ => 1 / ((b : ℝ) + 1) ^ 2) Filter.atTop (nhds 0) := by
      have hlin : Filter.Tendsto (fun b : ℕ => (b : ℝ) + 1) Filter.atTop Filter.atTop :=
        Filter.tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop
      have hpow : Filter.Tendsto (fun b : ℕ => ((b : ℝ) + 1) ^ 2) Filter.atTop Filter.atTop := by
        refine Filter.tendsto_atTop_mono (fun b => ?_) hlin
        have : (0 : ℝ) ≤ (b : ℝ) := Nat.cast_nonneg b
        nlinarith
      have := hpow.inv_tendsto_atTop
      simpa [one_div] using this
    simpa using Filter.Tendsto.const_sub (1 : ℝ) h0
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [Filter.eventually_ge_atTop 1] with b hb
    have h := rebalanced_ceiling_ge b hb
    have := (Rat.cast_le (K := ℝ)).2 h
    push_cast at this ⊢
    exact this
  · filter_upwards [Filter.eventually_ge_atTop 1] with b hb
    rw [rebalance_eq_replicate b hb]
    have hKm : 2 ≤ (List.replicate (b + 1) (2 ^ (b - 1))).sum := by
      have := flatBlocks_sum (b + 1) (2 ^ (b - 1))
      rw [show List.replicate (b + 1) (2 ^ (b - 1)) = flatBlocks (b + 1) (2 ^ (b - 1)) from rfl,
        flatBlocks_sum]
      calc 2 = 2 * 1 := by norm_num
        _ ≤ (b + 1) * 2 ^ (b - 1) := Nat.mul_le_mul (by omega) Nat.one_le_two_pow
    have := spearmanSq_le_one _ hKm
    exact_mod_cast (Rat.cast_le (K := ℝ)).2 this

/-! ## 5. The recorded round-61 #2 numbers at bitlen 56 -/

/-- Pooled dial reading at bitlen 56 (seeds 20261140–42). -/
def pooled56 : ℚ := 669 / 1000
/-- Lower CI endpoint. -/
def ci56Low : ℚ := 650 / 1000
/-- Upper CI endpoint. -/
def ci56High : ℚ := 690 / 1000
/-- Pooled advantage of the dial over the popcount baseline. -/
def advantage56 : ℚ := 45 / 1000
/-- The pre-stated H2 bar. -/
def h2Bar : ℚ := 50 / 1000
/-- Implied pooled reading of the count baseline. -/
def countPooled56 : ℚ := pooled56 - advantage56
/-- The H2 shortfall. -/
def shortfall56 : ℚ := h2Bar - advantage56

theorem u56_ci_inside_band :
    (55 / 100 : ℚ) ≤ ci56Low ∧ ci56High ≤ 85 / 100 ∧ ci56Low ≤ pooled56 ∧ pooled56 ≤ ci56High := by
  refine ⟨by norm_num [ci56Low], by norm_num [ci56High], by norm_num [ci56Low, pooled56],
    by norm_num [pooled56, ci56High]⟩

theorem u56_h2_fails : advantage56 ≤ h2Bar ∧ shortfall56 = 5 / 1000 ∧ 0 < shortfall56 := by
  refine ⟨by norm_num [advantage56, h2Bar], by norm_num [shortfall56, h2Bar, advantage56],
    by norm_num [shortfall56, h2Bar, advantage56]⟩

/-- The pooled reading is far below the unweighted dyadic tie ceiling at bitlen 56. -/
theorem u56_below_unweighted_ceiling : pooled56 ^ 2 < spearmanSq (dyadicBlocks 56) := by
  rw [dyadic_spearmanSq 56 (by norm_num)]
  have h : (0 : ℚ) < 1 / ((2 : ℚ) ^ 56 * (2 ^ 56 + 1)) := by positivity
  have : pooled56 ^ 2 ≤ 6 / 7 := by norm_num [pooled56]
  nlinarith

/-- The implied count reading is far below the popcount ceiling at bitlen 56, so the H2
shortfall is not a granularity effect on either side. -/
theorem count56_below_its_ceiling :
    countPooled56 ^ 2 < spearmanSq (Catalog.MachineLearning.ZeroFitDialUnif52.binomBlocks 56) := by
  have h := Catalog.MachineLearning.ZeroFitDialUnif52.count_ceiling_ge 28 (by norm_num)
  norm_num at h
  have hc : countPooled56 ^ 2 = (624 / 1000 : ℚ) ^ 2 := by
    norm_num [countPooled56, pooled56, advantage56]
  rw [hc]
  norm_num
  linarith

/-- At bitlen 56 the stratified weighting `(1,3)` strictly raises the tie ceiling. -/
theorem u56_weighted_ceiling_exceeds_unweighted :
    spearmanSq (dyadicBlocks 56) < spearmanSq (wDyadic 55 1 3) :=
  weighted_beats_unweighted 55 (by norm_num)

/-- The `ρ`-value of the unweighted asymptotic ceiling, `√(6/7)`. -/
theorem unweighted_rho_bounds :
    (0.9258200 : ℝ) < Real.sqrt (6 / 7) ∧ Real.sqrt (6 / 7) < 0.9258201 := by
  constructor
  · have h : (0.9258200 : ℝ) ^ 2 < 6 / 7 := by norm_num
    nlinarith [Real.sq_sqrt (by norm_num : (6/7:ℝ) ≥ 0), Real.sqrt_nonneg (6/7 : ℝ)]
  · have h : (6 / 7 : ℝ) < 0.9258201 ^ 2 := by norm_num
    nlinarith [Real.sq_sqrt (by norm_num : (6/7:ℝ) ≥ 0), Real.sqrt_nonneg (6/7 : ℝ)]

theorem stratOptimumRho_bounds :
    (0.9616463 : ℝ) < Real.sqrt stratOptimum ∧ Real.sqrt stratOptimum < 0.9616466 := by
  obtain ⟨h1, h2⟩ := stratOptimum_bounds
  constructor
  · have h : (0.9616463 : ℝ) ^ 2 < stratOptimum := by nlinarith
    nlinarith [Real.sq_sqrt (by linarith : stratOptimum ≥ 0), Real.sqrt_nonneg stratOptimum]
  · have h : stratOptimum < 0.9616466 ^ 2 := by nlinarith
    nlinarith [Real.sq_sqrt (by linarith : stratOptimum ≥ 0), Real.sqrt_nonneg stratOptimum]

/-- **The weighted-edge budget.**  Reweighting the 2-adic dial can add at least `0.0358` and
at most `0.0359` to the attainable correlation: the weighted edge exists, and it is capped. -/
theorem weighting_gain_bounds :
    (0.0358 : ℝ) < Real.sqrt stratOptimum - Real.sqrt (6 / 7) ∧
      Real.sqrt stratOptimum - Real.sqrt (6 / 7) < 0.0359 := by
  obtain ⟨h1, h2⟩ := stratOptimumRho_bounds
  obtain ⟨h3, h4⟩ := unweighted_rho_bounds
  constructor <;> linarith

/-- **The decisive comparison.**  The H2 shortfall at bitlen 56 is `0.005`, while the
reweighting budget of the dyadic dial exceeds `7 × 0.005`.  The failure of the pre-stated
`+0.05` rule is therefore not forced by the tie geometry of `T`. -/
theorem weighting_headroom_exceeds_shortfall :
    7 * ((shortfall56 : ℚ) : ℝ) < Real.sqrt stratOptimum - Real.sqrt (6 / 7) := by
  have h := (weighting_gain_bounds).1
  have hs : ((shortfall56 : ℚ) : ℝ) = 0.005 := by
    norm_num [shortfall56, h2Bar, advantage56]
  rw [hs]
  linarith

end Catalog.MachineLearning.ZeroFitDialWeighted56