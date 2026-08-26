/-
# Cycle 4: thin-shell counting under a thickness budget

Fix a radius `R`, a dimension `d` and a thickness budget `δ > 0`.  The equal-volume peeling of
`B(0,R) ⊆ ℝ^d` into `N` shells has spheres `shellRadius R d N k = R (1 - k/N)^{1/d}`
(`Catalog.Geometry.Peel`), and the `k`-th shell has thickness
`shellThickness R d N k = shellRadius R d N k - shellRadius R d N (k+1)`.

The attached catalog files (`Shared.ShellThicknessSharp`, `Shared.ShellThicknessRate`) pin the
*depth* of every sphere of the decomposition to the window `[R(k/N)/d, R(k/N)/(d(1-k/N))]`.
This file turns that sandwich into a statement about *individual shells* and then counts the
shells that violate the budget.

1. **Renormalisation.** `shellRadius_selfSimilar` : the tail `k, k+1, …, N` of a peeling of
   `B(0,R)` into `N` shells *is* the peeling of `B(0, r_k)` into `N - k` shells.  The whole
   two-sided theory of the outermost shell therefore transfers verbatim to every shell.

2. **A two-sided per-shell estimate.**
   `shellThickness_ge_uniform` : `R/(dN) ≤ thickness_k` for *every* `k < N` (a uniform lower
   bound: no shell is thinner than the average `R/(dN)` predicted by the `1/d` scaling);
   `shellThickness_le_of_succ_lt` : `thickness_k ≤ R/(d(N-k-1))`, the renormalised form of the
   catalog's `shell_thickness_le`.  So a shell can only be thick when it is close to the centre,
   which is the dichotomy the counting argument needs.

3. **Exact threshold.** `shellThickness_le_innermost` (via subadditivity of `x ↦ x^{1/d}`) shows
   the innermost shell is the thickest, and `shellThickness_innermost_eq` computes it exactly as
   `R N^{-1/d}`.  Hence `all_thin_iff_card` : *every* shell respects the budget **iff**
   `N ≥ (R/δ)^d`.  The number of shells needed is exactly exponential in the dimension, with
   base `R/δ` — the "exponentially many skins".

4. **Counting the offenders.** `thickCount_le` : uniformly in `N`,
   `#{k < N : thickness_k > δ} ≤ 1 + R/(dδ)`.  Note the shape: the count *decreases* with the
   dimension and grows like `1/δ`, not like `d log(R/δ)`.  The companion file
   `ShellThicknessBudgetSharp` proves this is sharp and refutes the `O(d log(R/δ))` conjecture.

## Lab notes (`R = 1`, floating point, see `ComputationalEvidence.md`)

`max_N #{thick shells}` for `δ = 0.01`: `d = 2 ↦ 50`, `d = 5 ↦ 20`, `d = 10 ↦ 10`; the
prediction `R/(dδ) = 100/d` is `50, 20, 10` — the bound of `thickCount_le` is attained exactly.
For `d = 2, δ = 0.01` the profile in `N` is `N = 10 ↦ 10`, `25 ↦ 25`, `50 ↦ 50`, `100 ↦ 25`,
`200 ↦ 13`, `400 ↦ 6`, `1000 ↦ 3`: all shells are thick until `N ≈ R/(2dδ)`, then the count
decays.  Smallest `N` with all shells thin: `d = 3, δ = 1/4 ↦ 64 = 4^3`; `d = 4, δ = 1/2 ↦ 16 =
2^4`, matching `all_thin_iff_card` on the nose.
-/
import Mathlib
import Shared.ShellThicknessSharp

namespace Catalog.Cryptography.ShellBudget

open Finset Catalog.Geometry.Peel Catalog.Shared.ShellSharp

/-- Thickness of the `k`-th shell of the equal-volume peeling. -/
noncomputable def shellThickness (R : ℝ) (d N k : ℕ) : ℝ :=
  shellRadius R d N k - shellRadius R d N (k + 1)

/-- Number of shells thicker than the budget `δ`. -/
noncomputable def thickCount (R : ℝ) (d N : ℕ) (δ : ℝ) : ℕ :=
  ((range N).filter (fun k => δ < shellThickness R d N k)).card

/-! ## Elementary rpow lemmas -/

lemma inv_natCast_le_one {d : ℕ} (hd : 0 < d) : ((d : ℝ)⁻¹) ≤ 1 := by
  have : (1 : ℝ) ≤ d := by exact_mod_cast hd
  exact inv_le_one_of_one_le₀ this

lemma rpow_inv_sub_ge {d : ℕ} (hd : 0 < d) {a b : ℝ} (ha : 0 < a) (ha1 : a ≤ 1)
    (hb0 : 0 ≤ b) (hba : b ≤ a) :
    (a - b) / d ≤ a ^ ((d : ℝ)⁻¹) - b ^ ((d : ℝ)⁻¹) := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set p : ℝ := (d : ℝ)⁻¹ with hp
  have hp0 : 0 < p := by rw [hp]; positivity
  have hp1 : p ≤ 1 := inv_natCast_le_one hd
  have ht0 : 0 ≤ b / a := by positivity
  have ht1 : b / a ≤ 1 := (div_le_one ha).2 hba
  have key := one_sub_rpow_inv_ge ht0 ht1 hd
  have hap : 0 < a ^ p := Real.rpow_pos_of_pos ha p
  have hdiv : (b / a) ^ p = b ^ p / a ^ p := Real.div_rpow hb0 ha.le p
  have h2 : a ^ p * ((1 - b / a) / d) ≤ a ^ p * (1 - (b / a) ^ p) :=
    mul_le_mul_of_nonneg_left key hap.le
  rw [hdiv] at h2
  have h3 : a ^ p * (1 - b ^ p / a ^ p) = a ^ p - b ^ p := by
    field_simp
  have h4 : a ≤ a ^ p := by
    calc a = a ^ (1 : ℝ) := (Real.rpow_one a).symm
      _ ≤ a ^ p := Real.rpow_le_rpow_of_exponent_ge ha ha1 hp1
  have hnn : 0 ≤ 1 - b / a := by linarith
  have h6 : a - b ≤ a ^ p * (1 - b / a) := by
    have hab : a * (1 - b / a) = a - b := by field_simp
    nlinarith [mul_le_mul_of_nonneg_right h4 hnn]
  calc (a - b) / d ≤ (a ^ p * (1 - b / a)) / d := by gcongr
    _ = a ^ p * ((1 - b / a) / d) := by ring
    _ ≤ a ^ p * (1 - b ^ p / a ^ p) := h2
    _ = a ^ p - b ^ p := h3

/-! ## Basic shape of the peeling -/

lemma shellRadius_le_self {R : ℝ} (hR : 0 ≤ R) (d N k : ℕ) : shellRadius R d N k ≤ R := by
  have hbase : max (0 : ℝ) (1 - (k : ℝ) / N) ≤ 1 := by
    refine max_le zero_le_one ?_
    have : (0 : ℝ) ≤ (k : ℝ) / N := by positivity
    linarith
  have h := Real.rpow_le_one (le_max_left _ _) hbase (by positivity : (0:ℝ) ≤ (d : ℝ)⁻¹)
  calc shellRadius R d N k = R * (max (0 : ℝ) (1 - (k : ℝ) / N)) ^ ((d : ℝ)⁻¹) := rfl
    _ ≤ R * 1 := by nlinarith
    _ = R := mul_one R

lemma shellRadius_eq' {R : ℝ} {d N k : ℕ} (hk : k ≤ N) (hN : 0 < N) :
    shellRadius R d N k = R * (((N : ℝ) - k) / N) ^ ((d : ℝ)⁻¹) := by
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hkN : (k : ℝ) ≤ N := by exact_mod_cast hk
  have h1 : 1 - (k : ℝ) / N = ((N : ℝ) - k) / N := by field_simp
  have h2 : (0 : ℝ) ≤ ((N : ℝ) - k) / N := div_nonneg (by linarith) hNpos.le
  rw [shellRadius, h1, max_eq_right h2]

lemma shellRadius_eq_zero_top {R : ℝ} {d N : ℕ} (hd : 0 < d) (hN : 0 < N) :
    shellRadius R d N N = 0 := by
  rw [shellRadius_eq' le_rfl hN]
  have hz : ((N : ℝ) - N) / N = 0 := by simp
  rw [hz, Real.zero_rpow (by positivity : ((d : ℝ)⁻¹) ≠ 0), mul_zero]

/-- **Renormalisation / self-similarity.**  The tail of an equal-volume peeling is again an
equal-volume peeling of the smaller ball. -/
theorem shellRadius_selfSimilar {R : ℝ} {d N k : ℕ} (hk : k < N) :
    shellRadius R d N (k + 1) = shellRadius (shellRadius R d N k) d (N - k) 1 := by
  have hN : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hkN : (k : ℝ) < N := by exact_mod_cast hk
  have hM : 0 < N - k := by omega
  have hMcast : ((N - k : ℕ) : ℝ) = (N : ℝ) - k := Nat.cast_sub hk.le
  have hMpos : (0 : ℝ) < (N : ℝ) - k := by linarith
  rw [shellRadius_eq' (by omega : k + 1 ≤ N) hN, shellRadius_eq' (by omega : k ≤ N) hN,
    shellRadius_eq' (by omega : 1 ≤ N - k) hM, hMcast]
  have hb1 : (0 : ℝ) ≤ ((N : ℝ) - k) / N := by positivity
  have hkN' : (k : ℝ) + 1 ≤ N := by exact_mod_cast hk
  have hb2 : (0 : ℝ) ≤ ((N : ℝ) - k - 1) / ((N : ℝ) - k) :=
    div_nonneg (by linarith) hMpos.le
  push_cast
  rw [mul_assoc, ← Real.mul_rpow hb1 hb2]
  congr 2
  field_simp
  ring

/-- Closed form of the thickness of the `k`-th shell. -/
lemma shellThickness_eq' {R : ℝ} {d N k : ℕ} (hk : k < N) :
    shellThickness R d N k
      = R * ((((N : ℝ) - k) / N) ^ ((d : ℝ)⁻¹) - (((N : ℝ) - k - 1) / N) ^ ((d : ℝ)⁻¹)) := by
  have hN : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
  rw [shellThickness, shellRadius_eq' hk.le hN, shellRadius_eq' (by omega : k + 1 ≤ N) hN]
  push_cast
  ring_nf

/-! ## Two-sided thickness bounds -/

/-- **Uniform lower bound.** Every shell of the peeling is at least `R/(dN)` thick. -/
theorem shellThickness_ge_uniform {R : ℝ} (hR : 0 ≤ R) {d N k : ℕ} (hd : 0 < d) (hk : k < N) :
    R / (d * N) ≤ shellThickness R d N k := by
  have hN : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hkN : (k : ℝ) + 1 ≤ N := by exact_mod_cast hk
  have hk0 : (0 : ℝ) ≤ k := Nat.cast_nonneg k
  set p : ℝ := (d : ℝ)⁻¹ with hp
  set a : ℝ := ((N : ℝ) - (k : ℝ)) / N with ha_def
  set b : ℝ := ((N : ℝ) - (k : ℝ) - 1) / N with hb_def
  have ha : 0 < a := div_pos (by linarith) hNpos
  have ha1 : a ≤ 1 := by rw [ha_def, div_le_one hNpos]; linarith
  have hb0 : 0 ≤ b := div_nonneg (by linarith) hNpos.le
  have hab : a - b = 1 / N := by rw [ha_def, hb_def]; field_simp; ring
  have hba : b ≤ a := by
    rw [← sub_nonneg, hab]; positivity
  have hthick : shellThickness R d N k = R * (a ^ p - b ^ p) := by
    rw [shellThickness, shellRadius_eq' hk.le hN, shellRadius_eq' (by omega : k + 1 ≤ N) hN,
      ha_def, hb_def, hp]
    push_cast
    ring_nf
  have hkey := rpow_inv_sub_ge hd ha ha1 hb0 hba
  have hfinal : R * ((a - b) / d) ≤ R * (a ^ p - b ^ p) :=
    mul_le_mul_of_nonneg_left hkey hR
  rw [hthick]
  refine le_trans (le_of_eq ?_) hfinal
  rw [hab]
  field_simp

/-- **Upper bound away from the centre.**  A shell whose index is at distance at least two
from the centre is thinner than `R / (d (N - k - 1))`. -/
theorem shellThickness_le_of_succ_lt {R : ℝ} (hR : 0 ≤ R) {d N k : ℕ} (hd : 0 < d)
    (hk : k + 1 < N) :
    shellThickness R d N k ≤ R / (d * ((N : ℝ) - k - 1)) := by
  have hkN : k < N := by omega
  have hM : 2 ≤ N - k := by omega
  have hrk : 0 ≤ shellRadius R d N k := shellRadius_nonneg hR d N k
  have h := shell_thickness_le d (N - k) hd hM hrk
  rw [← shellRadius_selfSimilar hkN] at h
  have hcast : ((N - k : ℕ) : ℝ) - 1 = (N : ℝ) - k - 1 := by
    rw [Nat.cast_sub hkN.le]
  rw [hcast] at h
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  have hden : (0 : ℝ) < (N : ℝ) - k - 1 := by
    have : (k : ℝ) + 1 < N := by exact_mod_cast hk
    linarith
  refine le_trans h ?_
  gcongr
  exact shellRadius_le_self hR d N k

/-- **The innermost shell is the thickest.** -/
theorem shellThickness_le_innermost {R : ℝ} (hR : 0 ≤ R) {d N k : ℕ} (hd : 0 < d) (hk : k < N) :
    shellThickness R d N k ≤ R * ((N : ℝ)⁻¹) ^ ((d : ℝ)⁻¹) := by
  have hN : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hkN : (k : ℝ) + 1 ≤ N := by exact_mod_cast hk
  have hk0 : (0 : ℝ) ≤ k := Nat.cast_nonneg k
  set p : ℝ := (d : ℝ)⁻¹ with hp
  have hp0 : (0 : ℝ) ≤ p := by rw [hp]; positivity
  have hp1 : p ≤ 1 := inv_natCast_le_one hd
  set a : ℝ := ((N : ℝ) - (k : ℝ)) / N with ha_def
  set b : ℝ := ((N : ℝ) - (k : ℝ) - 1) / N with hb_def
  have hb0 : 0 ≤ b := div_nonneg (by linarith) hNpos.le
  have hsplit : a = b + (N : ℝ)⁻¹ := by rw [ha_def, hb_def]; field_simp; ring
  have hsub : a ^ p ≤ b ^ p + ((N : ℝ)⁻¹) ^ p := by
    rw [hsplit]
    exact Real.rpow_add_le_add_rpow hb0 (by positivity) hp0 hp1
  have hthick : shellThickness R d N k = R * (a ^ p - b ^ p) := by
    rw [shellThickness, shellRadius_eq' hk.le hN, shellRadius_eq' (by omega : k + 1 ≤ N) hN,
      ha_def, hb_def, hp]
    push_cast
    ring_nf
  rw [hthick]
  have : a ^ p - b ^ p ≤ ((N : ℝ)⁻¹) ^ p := by linarith
  exact mul_le_mul_of_nonneg_left this hR

/-- The innermost shell has thickness exactly `R N^{-1/d}`. -/
theorem shellThickness_innermost_eq {R : ℝ} {d N : ℕ} (hd : 0 < d) (hN : 0 < N) :
    shellThickness R d N (N - 1) = R * ((N : ℝ)⁻¹) ^ ((d : ℝ)⁻¹) := by
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have h1 : N - 1 + 1 = N := by omega
  rw [shellThickness, h1, shellRadius_eq_zero_top hd hN, sub_zero,
    shellRadius_eq' (by omega : N - 1 ≤ N) hN]
  have hcast : ((N - 1 : ℕ) : ℝ) = (N : ℝ) - 1 := by
    rw [Nat.cast_sub hN, Nat.cast_one]
  rw [hcast]
  congr 2
  field_simp
  ring

/-! ## The exact thin-shell threshold -/

/-- **All shells respect the budget iff the innermost one does.** -/
theorem all_thin_iff {R δ : ℝ} (hR : 0 ≤ R) {d N : ℕ} (hd : 0 < d) (hN : 0 < N) :
    (∀ k < N, shellThickness R d N k ≤ δ) ↔ R * ((N : ℝ)⁻¹) ^ ((d : ℝ)⁻¹) ≤ δ := by
  constructor
  · intro h
    have := h (N - 1) (by omega)
    rwa [shellThickness_innermost_eq hd hN] at this
  · intro h k hk
    exact le_trans (shellThickness_le_innermost hR hd hk) h

/-- **The exact thin-shell threshold is `N ≥ (R/δ)^d`.**  The number of shells needed for a
budget `δ` grows *exponentially in the dimension*, with base `R/δ`. -/
theorem all_thin_iff_card {R δ : ℝ} (hR : 0 < R) (hδ : 0 < δ) {d N : ℕ} (hd : 0 < d)
    (hN : 0 < N) :
    (∀ k < N, shellThickness R d N k ≤ δ) ↔ (R / δ) ^ d ≤ (N : ℝ) := by
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hkey : (((N : ℝ)⁻¹) ^ ((d : ℝ)⁻¹)) ^ d = (N : ℝ)⁻¹ :=
    Real.rpow_inv_natCast_pow (by positivity) hd.ne'
  rw [all_thin_iff hR.le hd hN]
  rw [← pow_le_pow_iff_left₀ (by positivity) hδ.le hd.ne', mul_pow, hkey]
  rw [div_pow, div_le_iff₀ (by positivity : (0 : ℝ) < δ ^ d)]
  rw [mul_inv_le_iff₀ hNpos]
  constructor
  · intro h; linarith [h]
  · intro h; linarith [h]

/-! ## Counting the thick shells -/

/-- **The thick-shell count is at most `1 + R/(dδ)`, uniformly in `N`.** -/
theorem thickCount_le {R δ : ℝ} (hR : 0 ≤ R) (hδ : 0 < δ) {d N : ℕ} (hd : 0 < d) :
    (thickCount R d N δ : ℝ) ≤ 1 + R / (d * δ) := by
  have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
  set B : ℝ := R / (d * δ) with hB
  have hB0 : 0 ≤ B := by rw [hB]; positivity
  set c : ℕ := ⌊B⌋₊ + 1 with hc
  have hcB : B < (c : ℝ) := by rw [hc]; push_cast; exact Nat.lt_floor_add_one B
  have hcpos : (0 : ℝ) < (c : ℝ) := by rw [hc]; positivity
  have hsub : (range N).filter (fun k => δ < shellThickness R d N k) ⊆ Ico (N - c) N := by
    intro k hk
    rw [mem_filter, mem_range] at hk
    obtain ⟨hkN, hthick⟩ := hk
    rw [mem_Ico]
    refine ⟨?_, hkN⟩
    by_contra hlt
    push_neg at hlt
    have hk1 : k + 1 < N := by omega
    have hle := shellThickness_le_of_succ_lt hR hd hk1
    have hkc : k + c + 1 ≤ N := by omega
    have hcle : (c : ℝ) ≤ (N : ℝ) - k - 1 := by
      have h' : (k : ℝ) + (c : ℝ) + 1 ≤ (N : ℝ) := by exact_mod_cast hkc
      linarith
    have h2 : R / ((d : ℝ) * ((N : ℝ) - k - 1)) ≤ R / ((d : ℝ) * (c : ℝ)) :=
      div_le_div_of_nonneg_left hR (by positivity) (by nlinarith)
    have h3 : R / (d * (c : ℝ)) < δ := by
      rw [div_lt_iff₀ (by positivity)]
      have h4 : R < (c : ℝ) * (d * δ) := by
        have := (div_lt_iff₀ (by positivity : (0 : ℝ) < d * δ)).1 (by rw [hB] at hcB; exact hcB)
        linarith
      nlinarith
    linarith
  have hcard := card_le_card hsub
  rw [Nat.card_Ico] at hcard
  have hle : thickCount R d N δ ≤ c := le_trans hcard (by omega)
  calc (thickCount R d N δ : ℝ) ≤ (c : ℝ) := by exact_mod_cast hle
    _ = (⌊B⌋₊ : ℝ) + 1 := by rw [hc]; push_cast; ring
    _ ≤ B + 1 := by have := Nat.floor_le hB0; linarith
    _ = 1 + R / (d * δ) := by rw [hB]; ring

theorem thickCount_eq_of_all_thick {R δ : ℝ} {d N : ℕ}
    (h : ∀ k < N, δ < shellThickness R d N k) : thickCount R d N δ = N := by
  rw [thickCount, filter_true_of_mem (fun k hk => h k (mem_range.1 hk)), card_range]

end Catalog.Cryptography.ShellBudget