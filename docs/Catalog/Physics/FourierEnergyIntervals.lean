/-
# The third family: arithmetic intervals — the *minimal-doubling* regime

`Catalog.Physics.FourierEnergyFamilies` exhibits two families (the parabola in `(ZMod p)²`
and the radius-one Hamming ball in `𝔽₂ⁿ`) on which the covering bound
`FourierAdd.card_support_rep_ge` beats pigeonhole.  Both live at the *maximal-doubling*
end of the spectrum: they are Sidon sets, `|A + A| ≍ |A|²`, and the gain over pigeonhole
is a whole power of `|A|`.

This file supplies the opposite extreme.  The interval `I_k = {0, 1, …, k−1} ⊆ ZMod n`
(with `2k ≤ n`, so that no wraparound occurs) is the canonical set of *minimal* doubling:
`|I_k + I_k| = 2k − 1`, the Freiman/Cauchy–Davenport extremal configuration.  A priori
one might expect the second-moment bound to be useless here — the gain over pigeonhole is
only a constant factor.  It is not: we compute the additive energy exactly,

  `Ẽ(I_k, I_k) = k(2k² + 1)/3`,

hence (via `FourierEnergy.fourierEnergy_eq`) the nonprincipal Fourier energy

  `E = n·k(2k² + 1)/3 − k⁴`,

and the covering bound collapses to the closed form `3k³/(2k² + 1)`.  This is `> k`
for every `k ≥ 2`, and it tends to `(3/2)k` while the truth is `2k − 1`; so on intervals
the bound is **within a factor `4/3` of optimal, uniformly in `k`** — a better relative
accuracy than the factor `3/2` obtained in exponent two, and worse than the factor
`1 + 1/(2k)` obtained on Sidon sets.

Main results:

* `FourierEnergy.card_discreteInterval` : `|I_k| = k`.
* `FourierEnergy.rep_discreteInterval` : the exact representation function
  `r(c) = min(k, c.val + 1) − (c.val + 1 − k)` (the discrete triangle / tent function).
* `FourierEnergy.addEnergy_discreteInterval` : `3 Ẽ(I_k, I_k) = k(2k² + 1)`.
* `FourierEnergy.fourierEnergy_discreteInterval` : `3E = n k(2k²+1) − 3k⁴`.
* `FourierEnergy.fourierBound_discreteInterval` : the bound equals `3k³/(2k²+1)`.
* `FourierEnergy.discreteInterval_beats_pigeonhole` : strictly beats pigeonhole for `k ≥ 2`.
* `FourierEnergy.card_add_discreteInterval` : `|I_k + I_k| = 2k − 1` exactly.
* `FourierEnergy.discreteInterval_bound_within_four_thirds` : `3|I_k + I_k| ≤ 4 ·` bound.
* `FourierEnergy.discreteInterval_bound_lt_card_add` : the bound is never tight here.
-/

import Mathlib
import Catalog.Physics.FourierEnergyBound

open Finset FourierFA FourierAdd
open scoped Pointwise

namespace FourierEnergy

/-! ## Sums of squares -/

/-- The classical square-pyramidal identity, in the `ℕ`-friendly form
`6 ∑_{j < k} j² + 6k² = k(k+1)(2k+1)`. -/
theorem six_mul_sum_range_sq (k : ℕ) :
    6 * (∑ j ∈ range k, j ^ 2) + 6 * k ^ 2 = k * (k + 1) * (2 * k + 1) := by
  induction k with
  | zero => simp
  | succ m ih =>
      rw [Finset.sum_range_succ]
      ring_nf
      ring_nf at ih
      omega

/-! ## Casting `ℕ` into `ZMod n` -/

variable {n : ℕ} [NeZero n]

omit [NeZero n] in
/-- Below the modulus, the canonical map `ℕ → ZMod n` is injective. -/
theorem natCast_inj_of_lt {a b : ℕ} (ha : a < n) (hb : b < n) (h : (a : ZMod n) = (b : ZMod n)) :
    a = b := by
  rw [← ZMod.val_natCast_of_lt ha, ← ZMod.val_natCast_of_lt hb, h]

/-- Summing a function of `ZMod.val` over `ZMod n` is summing over `range n`. -/
theorem sum_zmod_val (g : ℕ → ℕ) : ∑ c : ZMod n, g c.val = ∑ m ∈ range n, g m := by
  refine Finset.sum_nbij' (i := fun c => ZMod.val c) (j := fun m => (m : ZMod n)) ?_ ?_ ?_ ?_ ?_
  · intro a _; simpa using ZMod.val_lt a
  · intro a _; simp
  · intro a _; simp [ZMod.natCast_val]
  · intro a ha; simp only [mem_range] at ha; simp [ZMod.val_natCast_of_lt ha]
  · intro a _; rfl

/-! ## The interval -/

/-- The arithmetic interval `{0, 1, …, k−1}` inside `ZMod n`. -/
def discreteInterval (n k : ℕ) : Finset (ZMod n) :=
  Finset.image (fun i : ℕ => (i : ZMod n)) (range k)

omit [NeZero n] in
theorem mem_discreteInterval {k : ℕ} {x : ZMod n} :
    x ∈ discreteInterval n k ↔ ∃ i, i < k ∧ (i : ZMod n) = x := by
  simp [discreteInterval]

omit [NeZero n] in
theorem discreteInterval_nonempty {k : ℕ} (hk : 0 < k) : (discreteInterval n k).Nonempty :=
  ⟨(0 : ℕ), mem_discreteInterval.2 ⟨0, hk, rfl⟩⟩

omit [NeZero n] in
/-- The interval has exactly `k` elements (no wraparound). -/
theorem card_discreteInterval {k : ℕ} (hk : k ≤ n) : (discreteInterval n k).card = k := by
  have hinj : Set.InjOn (fun i : ℕ => (i : ZMod n)) (range k) := by
    intro a ha b hb h
    simp only [Finset.coe_range, Set.mem_Iio] at ha hb
    exact natCast_inj_of_lt (lt_of_lt_of_le ha hk) (lt_of_lt_of_le hb hk) h
  rw [discreteInterval, Finset.card_image_of_injOn hinj, Finset.card_range]

/-! ## The representation function is the discrete tent -/

/-- **The exact representation function of an interval.**  With `m = c.val`,
`r_{I,I}(c) = min(k, m+1) − (m+1−k)`, i.e. the tent function `1, 2, …, k, k−1, …, 1`
supported on `{0, …, 2k−2}`. -/
theorem rep_discreteInterval {k : ℕ} (h2k : 2 * k ≤ n) (c : ZMod n) :
    rep (discreteInterval n k) (discreteInterval n k) c
      = min k (c.val + 1) - (c.val + 1 - k) := by
  classical
  have hcn : c.val < n := ZMod.val_lt c
  have hcast : ((c.val : ℕ) : ZMod n) = c := by simp [ZMod.natCast_val]
  have hbij : ((range k).filter (fun a => a ≤ c.val ∧ c.val - a < k)).card
      = rep (discreteInterval n k) (discreteInterval n k) c := by
    rw [rep]
    refine Finset.card_bij (fun a _ => (a : ZMod n)) ?_ ?_ ?_
    · intro a ha
      simp only [Finset.mem_filter, Finset.mem_range] at ha
      obtain ⟨hak, hale, hsub⟩ := ha
      refine Finset.mem_filter.2 ⟨mem_discreteInterval.2 ⟨a, hak, rfl⟩, ?_⟩
      have : c - (a : ZMod n) = ((c.val - a : ℕ) : ZMod n) := by
        rw [Nat.cast_sub hale, hcast]
      rw [this]
      exact mem_discreteInterval.2 ⟨c.val - a, hsub, rfl⟩
    · intro a ha b hb h
      simp only [Finset.mem_filter, Finset.mem_range] at ha hb
      exact natCast_inj_of_lt (by omega) (by omega) h
    · intro y hy
      rw [Finset.mem_filter] at hy
      obtain ⟨a, hak, rfl⟩ := mem_discreteInterval.1 hy.1
      obtain ⟨b, hbk, hb⟩ := mem_discreteInterval.1 hy.2
      have hsum : ((a + b : ℕ) : ZMod n) = ((c.val : ℕ) : ZMod n) := by
        push_cast
        rw [hb, hcast]; abel
      have : a + b = c.val := natCast_inj_of_lt (by omega) hcn hsum
      exact ⟨a, Finset.mem_filter.2 ⟨Finset.mem_range.2 hak, by omega, by omega⟩, rfl⟩
  rw [← hbij]
  have hset : (range k).filter (fun a => a ≤ c.val ∧ c.val - a < k)
      = Finset.Ico (c.val + 1 - k) (min k (c.val + 1)) := by
    ext a
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico, lt_min_iff]
    omega
  rw [hset, Nat.card_Ico]

/-! ## The additive energy of an interval -/

/-- **The additive energy of an interval**: `3 Ẽ(I_k, I_k) = k(2k² + 1)`.
Equivalently `Ẽ = k(2k²+1)/3`, the sum of squares of the tent function. -/
theorem addEnergy_discreteInterval {k : ℕ} (h2k : 2 * k ≤ n) :
    3 * addEnergy (discreteInterval n k) (discreteInterval n k) = k * (2 * k ^ 2 + 1) := by
  set f : ℕ → ℕ := fun m => (min k (m + 1) - (m + 1 - k)) ^ 2 with hf
  have hrep : addEnergy (discreteInterval n k) (discreteInterval n k)
      = ∑ m ∈ range n, f m := by
    rw [addEnergy]
    rw [show (∑ c : ZMod n, rep (discreteInterval n k) (discreteInterval n k) c ^ 2)
        = ∑ c : ZMod n, f c.val from
      Finset.sum_congr rfl fun c _ => by rw [rep_discreteInterval h2k c]]
    exact sum_zmod_val f
  have hzero : ∑ m ∈ range n, f m = ∑ m ∈ range (2 * k), f m := by
    refine (Finset.sum_subset ?_ ?_).symm
    · intro x hx
      simp only [Finset.mem_range] at hx ⊢
      omega
    · intro m _ hm
      simp only [Finset.mem_range, not_lt] at hm
      simp only [hf]
      have h0 : min k (m + 1) - (m + 1 - k) = 0 := by omega
      rw [h0]
      simp
  have hsplit : ∑ m ∈ range (2 * k), f m
      = (∑ m ∈ range k, f m) + ∑ i ∈ range k, f (k + i) := by
    rw [show 2 * k = k + k by ring, Finset.sum_range_add]
  have hlow : ∑ m ∈ range k, f m = ∑ m ∈ range k, (m + 1) ^ 2 := by
    refine Finset.sum_congr rfl fun m hm => ?_
    simp only [Finset.mem_range] at hm
    simp only [hf]
    have h1 : min k (m + 1) - (m + 1 - k) = m + 1 := by omega
    rw [h1]
  have hlow2 : ∑ m ∈ range k, (m + 1) ^ 2 = (∑ j ∈ range k, j ^ 2) + k ^ 2 := by
    have h1 : ∑ j ∈ range (k + 1), j ^ 2 = (∑ m ∈ range k, (m + 1) ^ 2) + 0 ^ 2 :=
      Finset.sum_range_succ' (fun j => j ^ 2) k
    have h2 : ∑ j ∈ range (k + 1), j ^ 2 = (∑ j ∈ range k, j ^ 2) + k ^ 2 :=
      Finset.sum_range_succ _ _
    omega
  have hhigh : ∑ i ∈ range k, f (k + i) = ∑ j ∈ range k, j ^ 2 := by
    rw [← Finset.sum_range_reflect (fun j => j ^ 2) k]
    refine Finset.sum_congr rfl fun i hi => ?_
    simp only [Finset.mem_range] at hi
    simp only [hf]
    have h1 : min k (k + i + 1) - (k + i + 1 - k) = k - 1 - i := by omega
    rw [h1]
  have hS := six_mul_sum_range_sq k
  rw [hrep, hzero, hsplit, hlow, hlow2, hhigh]
  nlinarith [hS, Nat.zero_le k]

/-- The additive energy of an interval, over the reals. -/
theorem addEnergy_discreteInterval_real {k : ℕ} (h2k : 2 * k ≤ n) :
    (addEnergy (discreteInterval n k) (discreteInterval n k) : ℝ)
      = (k : ℝ) * (2 * (k : ℝ) ^ 2 + 1) / 3 := by
  have h := addEnergy_discreteInterval (n := n) h2k
  have : ((3 * addEnergy (discreteInterval n k) (discreteInterval n k) : ℕ) : ℝ)
      = ((k * (2 * k ^ 2 + 1) : ℕ) : ℝ) := by exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) h
  push_cast at this
  linarith

/-! ## The Fourier energy and the covering bound -/

/-- **The nonprincipal Fourier energy of an interval**: `3E = n k(2k²+1) − 3k⁴`. -/
theorem fourierEnergy_discreteInterval {k : ℕ} (h2k : 2 * k ≤ n) (hk : k ≤ n) :
    3 * fourierEnergy (discreteInterval n k) (discreteInterval n k)
      = (n : ℝ) * ((k : ℝ) * (2 * (k : ℝ) ^ 2 + 1)) - 3 * (k : ℝ) ^ 4 := by
  rw [fourierEnergy_eq, addEnergy_discreteInterval_real h2k, card_discreteInterval hk,
    ZMod.card n]
  ring

/-- **The covering bound for an interval** equals `3k³/(2k² + 1)`. -/
theorem fourierBound_discreteInterval {k : ℕ} (h2k : 2 * k ≤ n) (hk0 : 0 < k) :
    fourierBound (discreteInterval n k) (discreteInterval n k)
      = 3 * (k : ℝ) ^ 3 / (2 * (k : ℝ) ^ 2 + 1) := by
  have hkn : k ≤ n := by omega
  have hA : (discreteInterval n k).Nonempty := discreteInterval_nonempty hk0
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk0
  rw [fourierBound_eq_addEnergy_ratio _ _ hA hA, addEnergy_discreteInterval_real h2k,
    card_discreteInterval hkn]
  rw [div_div_eq_mul_div, div_eq_div_iff (by nlinarith) (by nlinarith)]
  ring

/-- **Intervals beat pigeonhole**, strictly, for every `k ≥ 2`: the covering bound returns
`3k³/(2k²+1) > k`.  This is remarkable because intervals are the *minimal-doubling*
configuration, where no power gain over pigeonhole is possible at all. -/
theorem discreteInterval_beats_pigeonhole {k : ℕ} (h2k : 2 * k ≤ n) (hk : 2 ≤ k) :
    ((max (discreteInterval n k).card (discreteInterval n k).card : ℕ) : ℝ)
      < fourierBound (discreteInterval n k) (discreteInterval n k) := by
  have hkn : k ≤ n := by omega
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  rw [max_self, card_discreteInterval hkn, fourierBound_discreteInterval h2k (by omega),
    lt_div_iff₀ (by nlinarith)]
  nlinarith [sq_nonneg ((k : ℝ) - 1), sq_nonneg ((k : ℝ) + 1)]

/-- The covering bound for an interval is at least `(3/2)k − 1`, versus the pigeonhole
value `k`: a genuine constant-factor gain in the minimal-doubling regime. -/
theorem discreteInterval_bound_three_halves {k : ℕ} (h2k : 2 * k ≤ n) (hk0 : 0 < k) :
    3 * (k : ℝ) / 2 - 1 ≤ fourierBound (discreteInterval n k) (discreteInterval n k) := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk0
  rw [fourierBound_discreteInterval h2k hk0, le_div_iff₀ (by nlinarith)]
  nlinarith [sq_nonneg ((k : ℝ) - 1), sq_nonneg ((k : ℝ) - 2), mul_pos (by linarith : (0:ℝ) < (k:ℝ)) (by linarith : (0:ℝ) < (k:ℝ))]

/-! ## The exact sumset, and the accuracy of the bound -/

omit [NeZero n] in
/-- **The sumset of an interval is an interval**: `I_k + I_k = I_{2k−1}`.  No wraparound
hypothesis is needed for this set identity. -/
theorem add_discreteInterval {k : ℕ} :
    discreteInterval n k + discreteInterval n k = discreteInterval n (2 * k - 1) := by
  ext c
  constructor
  · intro hc
    obtain ⟨x, hx, y, hy, rfl⟩ := Finset.mem_add.1 hc
    obtain ⟨a, hak, rfl⟩ := mem_discreteInterval.1 hx
    obtain ⟨b, hbk, rfl⟩ := mem_discreteInterval.1 hy
    exact mem_discreteInterval.2 ⟨a + b, by omega, by push_cast; ring⟩
  · intro hc
    obtain ⟨m, hm, rfl⟩ := mem_discreteInterval.1 hc
    have hk0 : 0 < k := by omega
    refine Finset.mem_add.2 ⟨((min m (k - 1) : ℕ) : ZMod n),
      mem_discreteInterval.2 ⟨min m (k - 1), by omega, rfl⟩,
      ((m - min m (k - 1) : ℕ) : ZMod n),
      mem_discreteInterval.2 ⟨m - min m (k - 1), by omega, rfl⟩, ?_⟩
    rw [← Nat.cast_add]
    congr 1
    omega

omit [NeZero n] in
/-- **The exact sumset size of an interval**: `|I_k + I_k| = 2k − 1`, the Freiman
minimum. -/
theorem card_add_discreteInterval {k : ℕ} (h2k : 2 * k ≤ n) :
    (discreteInterval n k + discreteInterval n k).card = 2 * k - 1 := by
  rw [add_discreteInterval, card_discreteInterval (by omega)]

/-- **The bound is within a factor `4/3` on intervals**, uniformly in `k`: the true sumset
size `2k − 1` never exceeds `(4/3)` times the covering bound `3k³/(2k²+1)`.  Compare
`sidon_bound_sharp` (factor `1 + 1/(2k)`, asymptotically exact) and
`sidon2_bound_within_three_halves` (factor `3/2`). -/
theorem discreteInterval_bound_within_four_thirds {k : ℕ} (h2k : 2 * k ≤ n) (hk0 : 0 < k) :
    3 * ((discreteInterval n k + discreteInterval n k).card : ℝ)
      ≤ 4 * fourierBound (discreteInterval n k) (discreteInterval n k) := by
  have hkR : (1 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk0
  have hcard : ((discreteInterval n k + discreteInterval n k).card : ℝ) = 2 * (k : ℝ) - 1 := by
    rw [card_add_discreteInterval h2k]
    have : (1 : ℕ) ≤ 2 * k := by omega
    push_cast [Nat.cast_sub this]
    ring
  rw [hcard, fourierBound_discreteInterval h2k hk0, ← sub_nonneg]
  have hden : (0 : ℝ) < 2 * (k : ℝ) ^ 2 + 1 := by nlinarith
  rw [div_eq_mul_inv, ← mul_assoc]
  rw [show (4 : ℝ) * (3 * (k : ℝ) ^ 3) * (2 * (k : ℝ) ^ 2 + 1)⁻¹
      - 3 * (2 * (k : ℝ) - 1)
      = (4 * (3 * (k : ℝ) ^ 3) - 3 * (2 * (k : ℝ) - 1) * (2 * (k : ℝ) ^ 2 + 1))
        * (2 * (k : ℝ) ^ 2 + 1)⁻¹ by field_simp]
  refine mul_nonneg ?_ (by positivity)
  nlinarith [sq_nonneg ((k : ℝ) - 1), sq_nonneg (k : ℝ)]

/-- **The bound is never tight on intervals**: for `k ≥ 2` the covering bound
`3k³/(2k²+1)` is strictly below the true sumset size `2k − 1`.  Combined with
`discreteInterval_bound_within_four_thirds` this pins the accuracy of the bound on the
minimal-doubling family into the window `[3/4, 1)`. -/
theorem discreteInterval_bound_lt_card_add {k : ℕ} (h2k : 2 * k ≤ n) (hk : 2 ≤ k) :
    fourierBound (discreteInterval n k) (discreteInterval n k)
      < ((discreteInterval n k + discreteInterval n k).card : ℝ) := by
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hcard : ((discreteInterval n k + discreteInterval n k).card : ℝ) = 2 * (k : ℝ) - 1 := by
    rw [card_add_discreteInterval h2k]
    have h1 : (1 : ℕ) ≤ 2 * k := by omega
    push_cast [Nat.cast_sub h1]
    ring
  rw [hcard, fourierBound_discreteInterval h2k (by omega), div_lt_iff₀ (by nlinarith)]
  nlinarith [sq_nonneg ((k : ℝ) - 1), sq_nonneg ((k : ℝ) - 2)]

/-- The resulting sumset lower bound, direct from the covering inequality: for `k ≥ 2`
an interval satisfies `|I_k + I_k| > k`, i.e. intervals are never "no-gain" sets. -/
theorem card_add_discreteInterval_gt {k : ℕ} (h2k : 2 * k ≤ n) (hk : 2 ≤ k) :
    ((discreteInterval n k).card : ℝ)
      < ((discreteInterval n k + discreteInterval n k).card : ℝ) := by
  have hA : (discreteInterval n k).Nonempty := discreteInterval_nonempty (by omega)
  have h1 := discreteInterval_beats_pigeonhole h2k hk
  rw [max_self] at h1
  have h2 : fourierBound (discreteInterval n k) (discreteInterval n k)
      ≤ ((discreteInterval n k + discreteInterval n k).card : ℝ) := by
    rw [fourierBound_eq_addEnergy_ratio _ _ hA hA]
    exact card_add_ge_addEnergy_ratio _ _ hA hA
  linarith

end FourierEnergy