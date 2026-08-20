/-
# The Chebotarev geodesic theorem for a single non-split torus

Motivated by *"Chebotarev geodesic theorem: non-split case"*.  In the non-split (division
algebra) setting the closed geodesics of the quaternionic surface are indexed by the units of
the orders of the embedded quadratic fields — the **non-split tori** — and the length of the
geodesic attached to the `k`-th power of a fundamental unit `ε > 1` is `2k·log ε`.  Counting the
geodesics of one fixed torus of norm `≤ x` therefore amounts to counting the integers `k ≥ 1`
with `ε^{2k} ≤ x`, and a Chebotarev condition "the Frobenius class of the geodesic is `a`" for a
cyclic covering of degree `m` amounts to the congruence `k ≡ a (mod m)`.

Unlike the full spectral problem, *this* case is completely accessible, and we prove the
Chebotarev geodesic theorem for it **with the optimal exponent `0`** (bounded error) — a
strictly stronger statement than the paper's `25/36 + ε`, valid for a single torus:

* `torusCount_spec` : `{k ≥ 1 : ε^{2k} ≤ x} = Icc 1 (torusCount ε x)`, i.e. the counting
  function is exactly `⌊log x / (2 log ε)⌋`;
* `hasErrorExponent_torusCount` : the prime geodesic theorem for one torus with exponent `0`;
* `hasErrorExponent_torusClassCount` : **the Chebotarev geodesic theorem for one torus**:
  each residue class `a mod m` gets the density `1/m`, with bounded error, hence exponent `0`;
* `sum_torusClassCount` : the class counts add up to the total count (consistency of the
  Chebotarev statement with the prime geodesic theorem);
* `not_hasErrorExponent_torusCount_of_neg` and `optimalExponent_torusCount` : the exponent `0`
  is **optimal** — no negative exponent is admissible, because the fractional part of
  `log x / (2 log ε)` equals `1/2` along the sequence `x = ε^{2n+1}`;
* `hasErrorExponent_torusClassCount_25_36` : a fortiori the paper's exponent holds here.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic
import Catalog.Shared.ChebotarevGeodesicOptimal

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

/-! ## The counting function of one non-split torus -/

/-- The number of closed geodesics of the torus with fundamental unit `e > 1` and norm at most
`x`: the number of `k ≥ 1` with `e^{2k} ≤ x`, i.e. `⌊log x / (2 log e)⌋`. -/
noncomputable def torusCount (e x : ℝ) : ℕ := ⌊Real.log x / (2 * Real.log e)⌋₊

/-- The number of those geodesics whose Frobenius class in a cyclic covering of degree `m`
is `a`, i.e. the number of admissible `k` with `k ≡ a (mod m)`. -/
noncomputable def torusClassCount (e : ℝ) (m a : ℕ) (x : ℝ) : ℕ :=
  ((Finset.Icc 1 (torusCount e x)).filter (fun k => k % m = a % m)).card

section Basic

variable {e x : ℝ}

theorem log_pos_of_one_lt (he : 1 < e) : 0 < Real.log e := Real.log_pos he

theorem torusCount_main_nonneg (he : 1 < e) (hx : 1 ≤ x) :
    0 ≤ Real.log x / (2 * Real.log e) := by
  have h1 : 0 ≤ Real.log x := Real.log_nonneg hx
  have h2 : 0 < Real.log e := log_pos_of_one_lt he
  positivity

/-- `e^{2k} ≤ x` exactly for the `k` counted by `torusCount e x`. -/
theorem le_torusCount_iff (he : 1 < e) (hx : 1 ≤ x) (k : ℕ) :
    e ^ (2 * k) ≤ x ↔ k ≤ torusCount e x := by
  have he0 : 0 < e := lt_trans zero_lt_one he
  have hlog : 0 < Real.log e := log_pos_of_one_lt he
  have hx0 : 0 < x := lt_of_lt_of_le zero_lt_one hx
  have hpow : (0 : ℝ) < e ^ (2 * k) := pow_pos he0 _
  rw [torusCount, Nat.le_floor_iff (torusCount_main_nonneg he hx)]
  rw [← Real.log_le_log_iff hpow hx0, Real.log_pow]
  rw [le_div_iff₀ (by positivity)]
  constructor
  · intro h; push_cast at h ⊢; linarith
  · intro h; push_cast at h ⊢; linarith

/-- The set of geodesics of the torus with norm `≤ x` is exactly `Icc 1 (torusCount e x)`. -/
theorem torusCount_spec (he : 1 < e) (hx : 1 ≤ x) :
    {k : ℕ | 1 ≤ k ∧ e ^ (2 * k) ≤ x} = (Finset.Icc 1 (torusCount e x) : Finset ℕ) := by
  ext k
  simp only [Set.mem_setOf_eq, Finset.coe_Icc, Set.mem_Icc]
  exact and_congr_right fun _ => le_torusCount_iff he hx k

/-- A floor is within `1` of its argument. -/
theorem abs_floor_sub_le_one {y : ℝ} (hy : 0 ≤ y) : |(⌊y⌋₊ : ℝ) - y| ≤ 1 := by
  have h1 : (⌊y⌋₊ : ℝ) ≤ y := Nat.floor_le hy
  have h2 : y < (⌊y⌋₊ : ℝ) + 1 := Nat.lt_floor_add_one y
  rw [abs_le]
  constructor <;> linarith

/-- **The prime geodesic theorem for a single non-split torus, with the optimal exponent `0`.**
The number of geodesics of norm `≤ x` is `log x / (2 log ε) + O(1)`. -/
theorem hasErrorExponent_torusCount (he : 1 < e) :
    HasErrorExponent (fun x => (torusCount e x : ℝ))
      (fun x => Real.log x / (2 * Real.log e)) 0 := by
  intro ε hε
  refine ⟨1, one_pos, 1, le_refl 1, fun x hx => ?_⟩
  have hbound : |(torusCount e x : ℝ) - Real.log x / (2 * Real.log e)| ≤ 1 :=
    abs_floor_sub_le_one (torusCount_main_nonneg he hx)
  have hxe : (1 : ℝ) ≤ x ^ (0 + ε) := by
    rw [zero_add]
    exact Real.one_le_rpow hx hε.le
  linarith

end Basic

/-! ## Counting a residue class -/

/-- The number of integers in `[1, K]` in a fixed residue class mod `m` is `K/m + O(1)`. -/
theorem abs_card_residue_sub_le {m a K : ℕ} (hm : 0 < m) :
    |((((Finset.Icc 1 K).filter (fun k => k % m = a % m)).card : ℝ)) - (K : ℝ) / m| ≤ 3 := by
  classical
  -- relate `Icc 1 K` to `range (K+1)`
  have hrange : Finset.range (K + 1) = insert 0 (Finset.Icc 1 K) := by
    ext k
    simp only [Finset.mem_range, Finset.mem_insert, Finset.mem_Icc]
    omega
  have hnotmem : (0 : ℕ) ∉ Finset.Icc 1 K := by simp
  have hcount : ((Finset.range (K + 1)).filter (fun k => k % m = a % m)).card
      = ((Finset.Icc 1 K).filter (fun k => k % m = a % m)).card
        + (if 0 % m = a % m then 1 else 0) := by
    rw [hrange, Finset.filter_insert]
    by_cases h : 0 % m = a % m
    · rw [if_pos h, if_pos h, Finset.card_insert_of_notMem (by simp [hnotmem])]
    · rw [if_neg h, if_neg h, add_zero]
  -- Mathlib's exact count over `[0, K+1)`
  have hcnt : (K + 1).count (fun k => k ≡ a [MOD m])
      = (K + 1) / m + (if a % m < (K + 1) % m then 1 else 0) := Nat.count_modEq_card _ hm a
  have hcnt' : ((Finset.range (K + 1)).filter (fun k => k % m = a % m)).card
      = (K + 1) / m + (if a % m < (K + 1) % m then 1 else 0) := by
    rw [← hcnt, Nat.count_eq_card_filter_range]
    congr 1
  -- compare `(K+1)/m` (natural division) with `K/m` (real division)
  have hq : ((K + 1) / m : ℕ) * m + (K + 1) % m = K + 1 := Nat.div_add_mod' _ _
  have hr : (K + 1) % m < m := Nat.mod_lt _ hm
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hqR : (((K + 1) / m : ℕ) : ℝ) * m + (((K + 1) % m : ℕ) : ℝ) = (K : ℝ) + 1 := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) hq
  have hrR : (((K + 1) % m : ℕ) : ℝ) < m := by exact_mod_cast hr
  have hr0 : (0 : ℝ) ≤ (((K + 1) % m : ℕ) : ℝ) := Nat.cast_nonneg _
  have hqbound : |(((K + 1) / m : ℕ) : ℝ) - (K : ℝ) / m| ≤ 1 := by
    have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
    have hq1 : (K : ℝ) / m ≤ (((K + 1) / m : ℕ) : ℝ) + 1 := by
      rw [div_le_iff₀ hm0]; nlinarith
    have hq2 : (((K + 1) / m : ℕ) : ℝ) - 1 ≤ (K : ℝ) / m := by
      rw [le_div_iff₀ hm0]; nlinarith
    rw [abs_le]
    constructor <;> linarith
  -- assemble
  have hA : (((Finset.Icc 1 K).filter (fun k => k % m = a % m)).card : ℝ)
      = ((((Finset.range (K + 1)).filter (fun k => k % m = a % m)).card : ℝ))
        - (if 0 % m = a % m then (1 : ℝ) else 0) := by
    rw [hcount]
    push_cast
    split_ifs <;> ring
  rw [hA, hcnt']
  push_cast
  have hind1 : (0 : ℝ) ≤ (if a % m < (K + 1) % m then (1 : ℝ) else 0) := by positivity
  have hind1' : (if a % m < (K + 1) % m then (1 : ℝ) else 0) ≤ 1 := by split_ifs <;> norm_num
  have hind2 : (0 : ℝ) ≤ (if 0 % m = a % m then (1 : ℝ) else 0) := by positivity
  have hind2' : (if 0 % m = a % m then (1 : ℝ) else 0) ≤ 1 := by split_ifs <;> norm_num
  rw [abs_le] at hqbound ⊢
  constructor <;> [linarith [hqbound.1, hqbound.2]; linarith [hqbound.1, hqbound.2]]

/-! ## The Chebotarev geodesic theorem for one torus -/

/-- **Chebotarev geodesic theorem for a single non-split torus, with the optimal exponent `0`.**
In a cyclic covering of degree `m`, the geodesics of the torus with fundamental unit `ε > 1`
whose Frobenius is `a` have density exactly `1/m`, with a *bounded* error:

  `π_a(x) = (1/m)·(log x / (2 log ε)) + O(1)`.

This is the exponent `θ = 0`, far stronger than the general exponent `25/36 + ε`. -/
theorem hasErrorExponent_torusClassCount {e : ℝ} (he : 1 < e) {m : ℕ} (hm : 0 < m) (a : ℕ) :
    HasErrorExponent (fun x => (torusClassCount e m a x : ℝ))
      (fun x => (1 / m) * (Real.log x / (2 * Real.log e))) 0 := by
  intro ε hε
  refine ⟨4, by norm_num, 1, le_refl 1, fun x hx => ?_⟩
  set y : ℝ := Real.log x / (2 * Real.log e) with hy
  have hy0 : 0 ≤ y := torusCount_main_nonneg he hx
  set K : ℕ := torusCount e x with hK
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have h1 : |(torusClassCount e m a x : ℝ) - (K : ℝ) / m| ≤ 3 :=
    abs_card_residue_sub_le (a := a) hm
  have h2 : |(K : ℝ) - y| ≤ 1 := abs_floor_sub_le_one hy0
  have h3 : |(K : ℝ) / m - (1 / m) * y| ≤ 1 := by
    have e1 : (K : ℝ) / m - (1 / m) * y = ((K : ℝ) - y) / m := by ring
    rw [e1, abs_div, abs_of_pos hm0]
    calc |(K : ℝ) - y| / m ≤ 1 / m := by gcongr
      _ ≤ 1 := by
          rw [div_le_one hm0]; exact hm1
  have hxe : (1 : ℝ) ≤ x ^ (0 + ε) := by
    rw [zero_add]; exact Real.one_le_rpow hx hε.le
  have hsum : |(torusClassCount e m a x : ℝ) - (1 / m) * y| ≤ 4 := by
    calc |(torusClassCount e m a x : ℝ) - (1 / m) * y|
        ≤ |(torusClassCount e m a x : ℝ) - (K : ℝ) / m| + |(K : ℝ) / m - (1 / m) * y| := by
          exact abs_sub_le _ _ _
      _ ≤ 3 + 1 := add_le_add h1 h3
      _ = 4 := by norm_num
  nlinarith [hsum, hxe]

/-- The class counts sum to the total count: the Chebotarev statement for one torus is
consistent with the prime geodesic theorem for that torus. -/
theorem sum_torusClassCount (e : ℝ) {m : ℕ} (hm : 0 < m) (x : ℝ) :
    ∑ a ∈ Finset.range m, torusClassCount e m a x = torusCount e x := by
  classical
  have hmaps : Set.MapsTo (fun k : ℕ => k % m)
      ((Finset.Icc 1 (torusCount e x) : Finset ℕ) : Set ℕ)
      ((Finset.range m : Finset ℕ) : Set ℕ) := by
    intro k _
    simp only [Finset.coe_range, Set.mem_Iio]
    exact Nat.mod_lt _ hm
  have hcard := Finset.card_eq_sum_card_fiberwise (f := fun k : ℕ => k % m)
    (s := (Finset.Icc 1 (torusCount e x) : Finset ℕ)) (t := (Finset.range m : Finset ℕ)) hmaps
  have hIcc : (Finset.Icc 1 (torusCount e x)).card = torusCount e x := by
    rw [Nat.card_Icc]; omega
  rw [hIcc] at hcard
  rw [hcard]
  refine Finset.sum_congr rfl ?_
  intro a ha
  have ham : a % m = a := Nat.mod_eq_of_lt (Finset.mem_range.mp ha)
  simp only [torusClassCount, ham]

/-! ## A sharp Linnik-type bound for the least geodesic in a class -/

/-- **The least geodesic in a Frobenius class of a non-split torus.**  For a cyclic covering of
degree `m` every class `a` is already represented by a geodesic of norm at most `ε^{2m}`: the
exponent-`0` analogue of Linnik's theorem, with the *optimal* bound (the `m` powers
`ε^2, ε^4, …, ε^{2m}` realise all `m` residues exactly once). -/
theorem torusClassCount_pos_of_le {e : ℝ} (he : 1 < e) {m : ℕ} (hm : 0 < m) (a : ℕ) {x : ℝ}
    (hx : e ^ (2 * m) ≤ x) : 0 < torusClassCount e m a x := by
  classical
  have he1 : (1 : ℝ) ≤ e := he.le
  have hmod : a % m < m := Nat.mod_lt _ hm
  have hmodmod : (a % m) % m = a % m := Nat.mod_eq_of_lt hmod
  set k : ℕ := if a % m = 0 then m else a % m with hkdef
  have hk1 : 1 ≤ k := by
    simp only [hkdef]; split_ifs with h <;> omega
  have hkm : k ≤ m := by
    simp only [hkdef]; split_ifs with h <;> omega
  have hkmod : k % m = a % m := by
    simp only [hkdef]
    split_ifs with h
    · rw [Nat.mod_self, h]
    · exact hmodmod
  have hx1 : (1 : ℝ) ≤ x := le_trans (one_le_pow₀ he1) hx
  have hpow : e ^ (2 * k) ≤ x :=
    le_trans (pow_le_pow_right₀ he1 (by omega : 2 * k ≤ 2 * m)) hx
  have hkK : k ≤ torusCount e x := (le_torusCount_iff he hx1 k).mp hpow
  rw [torusClassCount, Finset.card_pos]
  exact ⟨k, by simp [Finset.mem_filter, Finset.mem_Icc, hk1, hkK, hkmod]⟩

/-! ## Equidistribution of the geodesics of one torus -/

/-- The torus counting function tends to infinity. -/
theorem tendsto_torusCount_atTop {e : ℝ} (he : 1 < e) :
    Tendsto (fun x => (torusCount e x : ℝ)) atTop atTop := by
  have hlog : 0 < Real.log e := log_pos_of_one_lt he
  have hy : Tendsto (fun x : ℝ => Real.log x / (2 * Real.log e) - 1) atTop atTop := by
    have h1 : Tendsto (fun x : ℝ => Real.log x / (2 * Real.log e)) atTop atTop :=
      Real.tendsto_log_atTop.atTop_div_const (by positivity)
    exact (Filter.tendsto_atTop_add_const_right atTop (-1 : ℝ) h1).congr (fun x => by ring)
  refine tendsto_atTop_mono' atTop ?_ hy
  filter_upwards [eventually_ge_atTop (1 : ℝ)] with x hx
  have h2 : Real.log x / (2 * Real.log e) < (torusCount e x : ℝ) + 1 :=
    Nat.lt_floor_add_one _
  linarith

/-- **Equidistribution.**  The proportion of the geodesics of a fixed non-split torus whose
Frobenius class in the cyclic covering of degree `m` equals `a` tends to `1/m`. -/
theorem tendsto_torusClassCount_ratio {e : ℝ} (he : 1 < e) {m : ℕ} (hm : 0 < m) (a : ℕ) :
    Tendsto (fun x => (torusClassCount e m a x : ℝ) / (torusCount e x : ℝ)) atTop
      (𝓝 (1 / m)) := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hK := tendsto_torusCount_atTop he
  have hzero : Tendsto (fun x => 3 / (torusCount e x : ℝ)) atTop (𝓝 0) :=
    hK.const_div_atTop 3
  have hbound : ∀ᶠ x in atTop,
      ‖(torusClassCount e m a x : ℝ) / (torusCount e x : ℝ) - 1 / m‖
        ≤ 3 / (torusCount e x : ℝ) := by
    filter_upwards [hK.eventually_gt_atTop 0] with x hx
    have hne : ((torusCount e x : ℝ)) ≠ 0 := ne_of_gt hx
    have hkey : |((torusClassCount e m a x : ℝ)) - (torusCount e x : ℝ) / m| ≤ 3 :=
      abs_card_residue_sub_le (a := a) hm
    have he1 : (torusClassCount e m a x : ℝ) / (torusCount e x : ℝ) - 1 / m
        = ((torusClassCount e m a x : ℝ) - (torusCount e x : ℝ) / m) / (torusCount e x : ℝ) := by
      field_simp
    rw [Real.norm_eq_abs, he1, abs_div, abs_of_pos hx]
    gcongr
  have hlim : Tendsto
      (fun x => (torusClassCount e m a x : ℝ) / (torusCount e x : ℝ) - 1 / m) atTop (𝓝 0) :=
    squeeze_zero_norm' hbound hzero
  have hsum := hlim.add (tendsto_const_nhds (x := (1 : ℝ) / m) (f := atTop))
  simpa using hsum

/-! ## Exact gaps, and finite families of tori -/

/-- **The geodesics of one torus form a geometric progression of ratio `ε^2`.**  Dilating the
norm bound by `ε^2` adds exactly one geodesic: an *exact* window statement, sharper than the
general `eventually_lt_of_window`. -/
theorem torusCount_mul_sq {e x : ℝ} (he : 1 < e) (hx : 1 ≤ x) :
    torusCount e (e ^ 2 * x) = torusCount e x + 1 := by
  have he0 : (0 : ℝ) < e := lt_trans zero_lt_one he
  have hlog : 0 < Real.log e := log_pos_of_one_lt he
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx
  have hlogmul : Real.log (e ^ 2 * x) = 2 * Real.log e + Real.log x := by
    rw [Real.log_mul (by positivity) (ne_of_gt hx0), Real.log_pow]
    push_cast; ring
  have hy : Real.log (e ^ 2 * x) / (2 * Real.log e)
      = Real.log x / (2 * Real.log e) + 1 := by
    rw [hlogmul]
    field_simp
    ring
  rw [torusCount, torusCount, hy, Nat.floor_add_one (torusCount_main_nonneg he hx)]

/-- Consequently the counting function of a torus is strictly increasing along the geometric
progression: every window `[x, ε²x]` contains a new geodesic, for **every** `x ≥ 1` (not just
eventually). -/
theorem torusCount_lt_mul_sq {e x : ℝ} (he : 1 < e) (hx : 1 ≤ x) :
    torusCount e x < torusCount e (e ^ 2 * x) := by
  rw [torusCount_mul_sq he hx]; omega

/-- **Finite superpositions of tori still have exponent `0`.**  A finite family of non-split
tori, each contributing its own Frobenius class in a covering of degree `m`, satisfies the
Chebotarev estimate with bounded error.  Any positive exponent (such as the paper's `25/36`)
must therefore come from the *infinitude* of the family of tori. -/
theorem hasErrorExponent_torusFamily {ι : Type*} (s : Finset ι) (e : ι → ℝ) {m : ℕ} (a : ι → ℕ)
    (he : ∀ i ∈ s, 1 < e i) (hm : 0 < m) :
    HasErrorExponent (fun x => ∑ i ∈ s, (torusClassCount (e i) m (a i) x : ℝ))
      (fun x => ∑ i ∈ s, (1 / m) * (Real.log x / (2 * Real.log (e i)))) 0 :=
  HasErrorExponent.sum s (fun i x => (torusClassCount (e i) m (a i) x : ℝ))
    (fun i x => (1 / m) * (Real.log x / (2 * Real.log (e i)))) 0
    fun i hi => hasErrorExponent_torusClassCount (he i hi) hm (a i)

/-! ## Optimality of the exponent `0` -/

/-- Along the sequence `x = e^{2n+1}` the error of the torus count is exactly `1/2`; hence no
*negative* error exponent is admissible: the exponent `0` is optimal. -/
theorem not_hasErrorExponent_torusCount_of_neg {e : ℝ} (he : 1 < e) {θ : ℝ} (hθ : θ < 0) :
    ¬ HasErrorExponent (fun x => (torusCount e x : ℝ))
        (fun x => Real.log x / (2 * Real.log e)) θ := by
  intro h
  have he0 : 0 < e := lt_trans zero_lt_one he
  have hlog : 0 < Real.log e := log_pos_of_one_lt he
  obtain ⟨C, hC, X, hX, hb⟩ := h (-θ / 2) (by linarith)
  have hexp : θ + -θ / 2 = θ / 2 := by ring
  -- the test sequence
  have hpow : Tendsto (fun n : ℕ => e ^ (2 * n + 1)) atTop atTop := by
    have h1 : Tendsto (fun n : ℕ => e ^ n) atTop atTop := tendsto_pow_atTop_atTop_of_one_lt he
    exact h1.comp (Filter.tendsto_atTop_atTop.mpr fun b => ⟨b, fun n hn => by omega⟩)
  have hneg : Tendsto (fun t : ℝ => t ^ (θ / 2)) atTop (𝓝 0) := by
    have : θ / 2 = -(-(θ / 2)) := by ring
    rw [this]
    exact tendsto_rpow_neg_atTop (by linarith)
  have hcomp : Tendsto (fun n : ℕ => C * (e ^ (2 * n + 1) : ℝ) ^ (θ / 2)) atTop (𝓝 0) := by
    have := (hneg.comp hpow)
    simpa using this.const_mul C
  have hev1 : ∀ᶠ n : ℕ in atTop, C * (e ^ (2 * n + 1) : ℝ) ^ (θ / 2) < 1 / 2 :=
    hcomp.eventually (gt_mem_nhds (by norm_num))
  have hev2 : ∀ᶠ n : ℕ in atTop, X ≤ (e ^ (2 * n + 1) : ℝ) :=
    hpow.eventually_ge_atTop X
  obtain ⟨n, hn1, hn2⟩ := (hev1.and hev2).exists
  -- at `x = e^{2n+1}` the main term is `n + 1/2` and the count is `n`
  set x : ℝ := e ^ (2 * n + 1) with hxdef
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hn2
  have hlogx : Real.log x = (2 * n + 1) * Real.log e := by
    rw [hxdef, Real.log_pow]; push_cast; ring
  have hmain : Real.log x / (2 * Real.log e) = (n : ℝ) + 1 / 2 := by
    rw [hlogx]
    field_simp
  have hcount : torusCount e x = n := by
    rw [torusCount, hmain]
    rw [Nat.floor_eq_iff (by positivity)]
    constructor
    · linarith
    · linarith
  have hbx : |(torusCount e x : ℝ) - Real.log x / (2 * Real.log e)| ≤ C * x ^ (θ / 2) := by
    have hb' := hb x hn2
    rwa [hexp] at hb'
  rw [hmain, hcount] at hbx
  have habs : |(n : ℝ) - ((n : ℝ) + 1 / 2)| = 1 / 2 := by
    rw [show (n : ℝ) - ((n : ℝ) + 1 / 2) = -(1 / 2) by ring, abs_neg, abs_of_pos (by norm_num)]
  rw [habs] at hbx
  linarith [hbx, hn1]

/-- The optimal error exponent of the torus counting function is exactly `0`. -/
theorem optimalExponent_torusCount {e : ℝ} (he : 1 < e) :
    optimalExponent (fun x => (torusCount e x : ℝ))
      (fun x => Real.log x / (2 * Real.log e)) = 0 := by
  have hmem : (0 : ℝ) ∈ exponentSet (fun x => (torusCount e x : ℝ))
      (fun x => Real.log x / (2 * Real.log e)) := hasErrorExponent_torusCount he
  have hbdd : BddBelow (exponentSet (fun x => (torusCount e x : ℝ))
      (fun x => Real.log x / (2 * Real.log e))) := by
    refine ⟨0, fun θ hθ => ?_⟩
    by_contra hlt
    exact not_hasErrorExponent_torusCount_of_neg he (lt_of_not_ge hlt) hθ
  refine le_antisymm (csInf_le hbdd hmem) ?_
  refine le_csInf ⟨0, hmem⟩ ?_
  intro θ hθ
  by_contra hlt
  exact not_hasErrorExponent_torusCount_of_neg he (lt_of_not_ge hlt) hθ

/-! ## A worked numerical example (`ε = 2`, `x = 100`, `m = 2`) -/

/-- With fundamental unit `ε = 2` there are exactly three geodesics of norm at most `100`,
namely `k = 1, 2, 3` (`2^2 = 4`, `2^4 = 16`, `2^6 = 64`, while `2^8 = 256 > 100`). -/
theorem torusCount_two_100 : torusCount 2 100 = 3 := by
  have h3 : 3 ≤ torusCount 2 100 :=
    (le_torusCount_iff (by norm_num) (by norm_num) 3).mp (by norm_num)
  have h4 : ¬ (4 ≤ torusCount 2 100) := by
    intro h
    have := (le_torusCount_iff (by norm_num) (by norm_num) 4).mpr h
    norm_num at this
  omega

/-- In the quadratic covering (`m = 2`) these three geodesics split as `1` even and `2` odd:
the densities `1/2` are only attained in the limit, the discrepancy being the `O(1)` error of
`hasErrorExponent_torusClassCount`. -/
theorem torusClassCount_two_100 :
    torusClassCount 2 2 0 100 = 1 ∧ torusClassCount 2 2 1 100 = 2 := by
  constructor <;> (rw [torusClassCount, torusCount_two_100]; decide)

/-- A fortiori, the torus satisfies the Chebotarev geodesic theorem with the paper's
exponent `25/36`. -/
theorem hasErrorExponent_torusClassCount_25_36 {e : ℝ} (he : 1 < e) {m : ℕ} (hm : 0 < m)
    (a : ℕ) :
    HasErrorExponent (fun x => (torusClassCount e m a x : ℝ))
      (fun x => (1 / m) * (Real.log x / (2 * Real.log e))) (25 / 36) :=
  (hasErrorExponent_torusClassCount he hm a).mono (by norm_num)

end ChebotarevGeodesic