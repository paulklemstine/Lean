/-
# The NET-48 seed laws, derived from median equivariance

The attention-cost thread reports, at two context lengths, three-seed knee
distributions and three derived readings of them:

| context | knees `k*`      | product point `P = d·ctx/32` | ratios `k*/P`        | speed-ups `ctx/k*`      |
|---------|-----------------|------------------------------|----------------------|-------------------------|
| `1024`  | `{96,112,128}`  | `128`                        | `{3/4, 7/8, 1}`      | `{8, 64/7, 32/3}`       |
| `2048`  | `{160,224,256}` | `256`                        | `{5/8, 7/8, 1}`      | `{8, 64/7, 64/5}`       |

The empirical "7/8-median law" is the observation that the *median* of the ratio
column is `7/8` at both contexts.  This file derives the ratio column and the
speed-up column from the knee column by the equivariance theorems of
`MedianEquivariance`: dividing by `P` preserves order, dividing `ctx` by the knee
reverses it, and the median is equivariant for **both**.  Consequences proved here:

* `isMedian_ratios16` / `isMedian_ratios8` — the median ratio is `7/8` at both contexts
  (`median_ratio_law_unique`: `7/8` is the *only* constant making both rows agree);
* `isMedian_speedups16` — the median deployment speed-up is `ctx / median knee = 64/7`;
* `guaranteed_speedup16` — the guaranteed (worst-seed) speed-up is the image of the
  **largest** knee, `8×`, by order reversal — not of the smallest;
* `mean_has_no_ratio_law` — the *mean* satisfies no such two-context ratio law, so the
  law is genuinely about the median and not about "the centre" in a loose sense;
* `low_tail_strictly_widens`, `upper_edge_pinned` — the widening of the spread is entirely
  a low-tail phenomenon;
* `net48_stability_interval` and `informal_stability_claim_false` — the exact family of
  third-seed values that leave the median at `224` is the ray `x ≤ 224`, which *refutes*
  the informal claim that only values `≥ 256` move the centre (`x = 240` moves it).
-/
import Tropical.KneeMedian.TropicalNormalForm

namespace Catalog.Tropical.KneeMedian

open Multiset

/-! ## The measured data -/

/-- Three-seed knee distribution at `d = 4`, `ctx = 2048` (seeds 1, 2, 3). -/
def K16 : Multiset ℚ := {256, 224, 160}

/-- Three-seed knee distribution at `d = 4`, `ctx = 1024`. -/
def K8 : Multiset ℚ := {128, 112, 96}

/-- The product point `P = d·ctx/32` at `d = 4`, `ctx = 2048`. -/
def P16 : ℚ := 256

/-- The product point `P = d·ctx/32` at `d = 4`, `ctx = 1024`. -/
def P8 : ℚ := 128

theorem productPoint_16 : (4 * 2048 : ℚ) / 32 = P16 := by norm_num [P16]

theorem productPoint_8 : (4 * 1024 : ℚ) / 32 = P8 := by norm_num [P8]

/-! ## The medians -/

theorem isMedian_K16 : IsMedian 1 K16 224 := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

theorem isMedian_K8 : IsMedian 1 K8 112 := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

/-- The 7/8-median law at `ctx = 2048`. -/
theorem median_law_16 : (224 : ℚ) = 7 / 8 * P16 := by norm_num [P16]

/-- The 7/8-median law at `ctx = 1024`. -/
theorem median_law_8 : (112 : ℚ) = 7 / 8 * P8 := by norm_num [P8]

/-! ## Normalisation by the product point (an order-preserving change of units) -/

theorem isMedian_ratios16 : IsMedian 1 ({1, 7 / 8, 5 / 8} : Multiset ℚ) (7 / 8) := by
  have h := isMedian_K16.map_mono (fun x : ℚ => x / P16) (by
    intro x _ y _
    simp only [P16]
    constructor <;> intro h <;> linarith)
  have hmap : K16.map (fun x : ℚ => x / P16) = ({1, 7 / 8, 5 / 8} : Multiset ℚ) := by
    simp only [K16, P16, Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton]
    norm_num
  rw [hmap] at h
  have hval : (fun x : ℚ => x / P16) 224 = 7 / 8 := by norm_num [P16]
  rwa [hval] at h

theorem isMedian_ratios8 : IsMedian 1 ({1, 7 / 8, 3 / 4} : Multiset ℚ) (7 / 8) := by
  have h := isMedian_K8.map_mono (fun x : ℚ => x / P8) (by
    intro x _ y _
    simp only [P8]
    constructor <;> intro h <;> linarith)
  have hmap : K8.map (fun x : ℚ => x / P8) = ({1, 7 / 8, 3 / 4} : Multiset ℚ) := by
    simp only [K8, P8, Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton]
    norm_num
  rw [hmap] at h
  have hval : (fun x : ℚ => x / P8) 112 = 7 / 8 := by norm_num [P8]
  rwa [hval] at h

/-- `7/8` is the *unique* constant ratio reproducing both measured medians: the law has no
free parameter left. -/
theorem median_ratio_law_unique (a : ℚ) :
    (a * P8 = 112 ∧ a * P16 = 224) ↔ a = 7 / 8 := by
  constructor
  · rintro ⟨h1, -⟩
    rw [P8] at h1
    linarith
  · rintro rfl
    norm_num [P8, P16]

/-- The **mean** obeys no two-context ratio law: it is `7/8·P` at `ctx = 1024` but
`5/6·P` at `ctx = 2048`.  So the 7/8 law is specific to the median. -/
theorem mean_has_no_ratio_law :
    ¬ ∃ a : ℚ, a * P8 = (128 + 112 + 96) / 3 ∧ a * P16 = (256 + 224 + 160) / 3 := by
  rintro ⟨a, h1, h2⟩
  rw [P8] at h1
  rw [P16] at h2
  have ha : a = 7 / 8 := by linarith
  rw [ha] at h2
  norm_num at h2

/-! ## Deployment speed-ups (an order-reversing change of units) -/

/-- The three deployment speed-ups at `ctx = 2048` are `{8, 64/7, 64/5}`, and their median is
`64/7 = 2048/224 = ctx / median knee`.  This is the order-reversal equivariance of the median:
the median of the speed-ups is the speed-up of the median. -/
theorem isMedian_speedups16 : IsMedian 1 ({8, 64 / 7, 64 / 5} : Multiset ℚ) (64 / 7) := by
  have hpos : ∀ x ∈ K16, (0 : ℚ) < x := by decide
  have h := isMedian_K16.map_anti (fun x : ℚ => 2048 / x) (by
    intro x hx y hy
    have hx0 := hpos x hx
    have hy0 := hpos y hy
    exact div_le_div_iff_of_pos_left (by norm_num) hx0 hy0)
  have hmap : K16.map (fun x : ℚ => 2048 / x) = ({8, 64 / 7, 64 / 5} : Multiset ℚ) := by
    simp only [K16, Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton]
    norm_num
  rw [hmap] at h
  have hval : (fun x : ℚ => 2048 / x) 224 = 64 / 7 := by norm_num
  rwa [hval] at h

/-- The median speed-up is exactly `ctx` divided by the median knee, i.e. `2048 / (7/8 · P16)`. -/
theorem median_speedup_eq : (64 : ℚ) / 7 = 2048 / (7 / 8 * P16) := by norm_num [P16]

/-- The **guaranteed** speed-up is the image of the *largest* knee: order reversal sends the
maximum to the minimum, so the worst-case reading `8×` is governed by the seed with the
largest knee (the product point), not by the median. -/
theorem guaranteed_speedup16 :
    (8 : ℚ) ∈ K16.map (fun x : ℚ => 2048 / x) ∧
      ∀ z ∈ K16.map (fun x : ℚ => 2048 / x), (8 : ℚ) ≤ z := by
  have hpos : ∀ x ∈ K16, (0 : ℚ) < x := by decide
  have h := isLeast_map_of_isGreatest (s := K16) (M := 256) (fun x : ℚ => 2048 / x)
    (by
      intro x hx y hy
      have hx0 := hpos x hx
      have hy0 := hpos y hy
      exact div_le_div_iff_of_pos_left (by norm_num) hx0 hy0)
    (by decide) (by decide)
  have hval : (fun x : ℚ => 2048 / x) 256 = 8 := by norm_num
  rwa [hval] at h

/-- Every seed at `ctx = 2048` obeys the product-law upper bound `k* ≤ d·ctx/32`, hence every
seed deploys at at least `8×`. -/
theorem product_law_16 : ∀ x ∈ K16, x ≤ P16 := by decide

theorem product_law_8 : ∀ x ∈ K8, x ≤ P8 := by decide

theorem guaranteed_speedup_of_product_law : ∀ x ∈ K16, (8 : ℚ) ≤ 2048 / x := by
  intro x hx
  simp only [K16, Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
  rcases hx with rfl | rfl | rfl <;> norm_num

/-! ## Shape of the two distributions: a pinned upper edge and a sinking low tail -/

/-- The ratio profile `(min, median, max)` at the two contexts. -/
theorem ratio_profile_8 :
    ((96 : ℚ) / P8, (112 : ℚ) / P8, (128 : ℚ) / P8) = (3 / 4, 7 / 8, 1) := by
  norm_num [P8]

theorem ratio_profile_16 :
    ((160 : ℚ) / P16, (224 : ℚ) / P16, (256 : ℚ) / P16) = (5 / 8, 7 / 8, 1) := by
  norm_num [P16]

/-- The upper edge is pinned at the product point in both contexts. -/
theorem upper_edge_pinned : (128 : ℚ) / P8 = 1 ∧ (256 : ℚ) / P16 = 1 := by
  norm_num [P8, P16]

/-- The low tail strictly sinks with context, while the median ratio is unchanged: the entire
widening of the spread is a low-tail effect. -/
theorem low_tail_strictly_widens :
    (160 : ℚ) / P16 < (96 : ℚ) / P8 ∧ (224 : ℚ) / P16 = (112 : ℚ) / P8 := by
  norm_num [P8, P16]

/-- The normalised spread grows by exactly a factor `3/2` from `8×` to `16×`. -/
theorem spread_ratio :
    ((256 : ℚ) - 160) / P16 = 3 / 2 * (((128 : ℚ) - 96) / P8) := by
  norm_num [P8, P16]

/-! ## The stability interval of the reported median -/

/-- With the two other seeds at `224` and `256`, the third-seed values that keep the median at
`224` are **exactly** those `≤ 224`. -/
theorem net48_stability_interval (x : ℚ) : tropMed3 x 224 256 = 224 ↔ x ≤ 224 :=
  tropMed3_stable_iff (by norm_num) x

/-- The informal claim "only a third seed `≥ 256` would shift the median" is false:
`x = 240` lies strictly below `256` and already moves the centre to `240`. -/
theorem informal_stability_claim_false :
    (240 : ℚ) < 256 ∧ tropMed3 (240 : ℚ) 224 256 = 240 ∧ tropMed3 (240 : ℚ) 224 256 ≠ 224 := by
  refine ⟨by norm_num, ?_, ?_⟩ <;> norm_num [tropMed3]

/-- The reported family `{160, 192, 224}` does keep the median at `224`, and this is a
special case of the stability ray. -/
theorem reported_family_stable :
    tropMed3 (160 : ℚ) 224 256 = 224 ∧ tropMed3 (192 : ℚ) 224 256 = 224 ∧
      tropMed3 (224 : ℚ) 224 256 = 224 := by
  refine ⟨?_, ?_, ?_⟩ <;>
    exact (net48_stability_interval _).mpr (by norm_num)

end Catalog.Tropical.KneeMedian