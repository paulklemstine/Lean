/-
# Cycle 5: what the conjectured `d log(R/δ)` really measures

The two conjectures of this mission were refuted in `Cryptography.ShellThicknessBudgetSharp`:
the thick-shell count is `Θ(R/(dδ))`, not `O(d log(R/δ))`, and the thin threshold is `(R/δ)^d`,
not `(1 - δ/R)^{-d}`.  This file explains *where* the quantity `d log(R/δ)` does occur, and
records the remaining elementary structure of the counting function.

* `thin_threshold_log_bounds` : the logarithm of the least admissible number of shells is
  `d log(R/δ)` up to an additive `log 2`.  So the conjectured expression is exactly the **bit
  cost of indexing** a peeling that respects the budget — a `d log₂(R/δ) + O(1)`-bit index —
  and not the number of shells that violate it.  `thin_threshold_bitcost` states the base-2
  form used in the cryptographic reading (a shell index is a key of that many bits).

* `thickCount_antitone` : the count is antitone in the budget, as it must be.

* `thickCount_eq_zero_of_large` : once `N ≥ (R/δ)^d` no shell is thick — the peeling has
  collapsed onto the boundary sphere.  Together with `thickCount_le` this is the sharp form of
  "exponentially many skins, boundedly many thick layers".

* `thickCount_eq_iff` : an exact criterion — the count equals `m` iff the shell at inner index
  `m` is thick and the next one outwards is thin.  This is the two-inequality reduction that the
  quantitative bounds of `ShellThicknessBudgetDecay` then estimate.

* `shellThickness_dim_one`, `thickCount_dim_one` : in dimension one the peeling is uniform and
  the count is the all-or-nothing function `N · [δ < R/N]`, showing that the dichotomy proved
  in `ShellThicknessBudgetStructure` is attained.

## Lab notes

Numerical check at `R = 1`, `δ = 1/8`, so `R/δ = 8`:

| `d` | `⌈8^d⌉` | `log(⌈8^d⌉)` | `d log 8` | gap |
|-----|---------|--------------|-----------|-----|
| 1   | 8       | 2.0794       | 2.0794    | 0   |
| 2   | 64      | 4.1589       | 4.1589    | 0   |
| 3   | 512     | 6.2383       | 6.2383    | 0   |

The gap is `0` whenever `(R/δ)^d` is an integer and is at most `log 2 ≈ 0.693` in general
(attained in the limit `(R/δ)^d ↓ 1`).
-/
import Cryptography.ShellThicknessBudgetStructure

namespace Catalog.Cryptography.ShellBudget

open Finset Catalog.Geometry.Peel Catalog.Shared.ShellSharp

/-! ## The bit cost of a budget-respecting peeling -/

/-- **`d log(R/δ)` is the logarithm of the thin threshold.**  The least `N` for which every
shell of the equal-volume peeling is thinner than `δ` is `max 1 ⌈(R/δ)^d⌉`, and its logarithm
equals `d log(R/δ)` up to an additive `log 2`. -/
theorem thin_threshold_log_bounds {R δ : ℝ} (hδ : 0 < δ) (hδR : δ ≤ R) (d : ℕ) :
    (d : ℝ) * Real.log (R / δ) ≤ Real.log ((max 1 ⌈(R / δ) ^ d⌉₊ : ℕ) : ℝ) ∧
      Real.log ((max 1 ⌈(R / δ) ^ d⌉₊ : ℕ) : ℝ) ≤ (d : ℝ) * Real.log (R / δ) + Real.log 2 := by
  have hq1 : (1 : ℝ) ≤ R / δ := (one_le_div hδ).2 hδR
  set x : ℝ := (R / δ) ^ d with hx_def
  have hx1 : (1 : ℝ) ≤ x := one_le_pow₀ hq1
  have hx0 : (0 : ℝ) < x := lt_of_lt_of_le zero_lt_one hx1
  have hceil1 : 1 ≤ ⌈x⌉₊ := by
    have : (1 : ℝ) ≤ (⌈x⌉₊ : ℝ) := le_trans hx1 (Nat.le_ceil x)
    exact_mod_cast this
  have hmax : max 1 ⌈x⌉₊ = ⌈x⌉₊ := max_eq_right hceil1
  have hlogx : Real.log x = (d : ℝ) * Real.log (R / δ) := by
    rw [hx_def, Real.log_pow]
  rw [hmax]
  constructor
  · rw [← hlogx]
    exact Real.log_le_log hx0 (Nat.le_ceil x)
  · have hub : (⌈x⌉₊ : ℝ) ≤ 2 * x := by
      have h1 : (⌈x⌉₊ : ℝ) < x + 1 := Nat.ceil_lt_add_one hx0.le
      linarith
    calc Real.log ((⌈x⌉₊ : ℕ) : ℝ) ≤ Real.log (2 * x) :=
          Real.log_le_log (by positivity) hub
      _ = Real.log 2 + Real.log x := Real.log_mul (by norm_num) hx0.ne'
      _ = (d : ℝ) * Real.log (R / δ) + Real.log 2 := by rw [hlogx]; ring

/-- **Bit-cost form.**  Indexing the shells of a budget-respecting peeling costs
`d log₂(R/δ) + O(1)` bits: this is the cryptographic content of the expression `d log(R/δ)`
appearing in the (false) counting conjecture. -/
theorem thin_threshold_bitcost {R δ : ℝ} (hδ : 0 < δ) (hδR : δ ≤ R) (d : ℕ) :
    (d : ℝ) * Real.logb 2 (R / δ) ≤ Real.logb 2 ((max 1 ⌈(R / δ) ^ d⌉₊ : ℕ) : ℝ) ∧
      Real.logb 2 ((max 1 ⌈(R / δ) ^ d⌉₊ : ℕ) : ℝ) ≤ (d : ℝ) * Real.logb 2 (R / δ) + 1 := by
  obtain ⟨h1, h2⟩ := thin_threshold_log_bounds hδ hδR d
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have key : ∀ a b : ℝ, a ≤ b → a / Real.log 2 ≤ b / Real.log 2 := by
    intro a b hab
    rw [div_eq_mul_inv, div_eq_mul_inv]
    exact mul_le_mul_of_nonneg_right hab (inv_nonneg.2 hlog2.le)
  constructor
  · have hrw : (d : ℝ) * Real.logb 2 (R / δ) = ((d : ℝ) * Real.log (R / δ)) / Real.log 2 := by
      rw [Real.logb]; ring
    rw [hrw, Real.logb]
    exact key _ _ h1
  · have hrw : (d : ℝ) * Real.logb 2 (R / δ) + 1
        = ((d : ℝ) * Real.log (R / δ) + Real.log 2) / Real.log 2 := by
      rw [Real.logb]; field_simp
    rw [hrw, Real.logb]
    exact key _ _ h2

/-! ## Elementary structure of the counting function -/

/-- The thick-shell count is antitone in the budget. -/
theorem thickCount_antitone {R : ℝ} {d N : ℕ} {δ₁ δ₂ : ℝ} (h : δ₁ ≤ δ₂) :
    thickCount R d N δ₂ ≤ thickCount R d N δ₁ := by
  refine Finset.card_le_card ?_
  intro k hk
  simp only [Finset.mem_filter, Finset.mem_range] at hk ⊢
  exact ⟨hk.1, lt_of_le_of_lt h hk.2⟩

/-- **Collapse onto the boundary sphere.**  As soon as the peeling has at least `(R/δ)^d`
shells, none of them violates the budget. -/
theorem thickCount_eq_zero_of_large {R δ : ℝ} (hR : 0 < R) (hδ : 0 < δ) {d N : ℕ} (hd : 0 < d)
    (hN : 0 < N) (hcard : (R / δ) ^ d ≤ N) : thickCount R d N δ = 0 := by
  have hthin := (all_thin_iff_card hR hδ hd hN).2 hcard
  rw [thickCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  intro k hk
  rw [Finset.mem_range] at hk
  exact not_lt.2 (hthin k hk)

/-- **Exact criterion for the thick-shell count.**  Because the thick shells form a terminal
block, the count equals `m` precisely when the shell at inner index `m` is thick and the next
one out is not: two inequalities decide the whole count. -/
theorem thickCount_eq_iff {R δ : ℝ} (hR : 0 ≤ R) {d N m : ℕ} (hd : 0 < d) (hm : m ≤ N) :
    thickCount R d N δ = m ↔
      ((0 < m → δ < shellThickness R d N (N - m)) ∧
        (m < N → shellThickness R d N (N - m - 1) ≤ δ)) := by
  obtain ⟨k₀, hk₀N, hiff, hcard⟩ := exists_thick_threshold hR hd (δ := δ) (N := N)
  constructor
  · intro hEq
    have hk₀ : k₀ = N - m := by omega
    refine ⟨fun hm0 => ?_, fun hmN => ?_⟩
    · exact (hiff (N - m) (by omega)).2 (by omega)
    · exact not_lt.1 fun hthick => by
        have := (hiff (N - m - 1) (by omega)).1 hthick
        omega
  · rintro ⟨h1, h2⟩
    have hge : m ≤ N - k₀ := by
      rcases Nat.eq_zero_or_pos m with hm0 | hm0
      · omega
      · have := (hiff (N - m) (by omega)).1 (h1 hm0)
        omega
    have hle : N - k₀ ≤ m := by
      rcases Nat.lt_or_ge m N with hmN | hmN
      · have hnot : ¬ (δ < shellThickness R d N (N - m - 1)) := not_lt.2 (h2 hmN)
        have : ¬ (k₀ ≤ N - m - 1) := fun hle => hnot ((hiff (N - m - 1) (by omega)).2 hle)
        omega
      · omega
    omega

/-! ## Dimension one: the dichotomy is attained -/

/-- In dimension one the peeling is uniform: every shell has thickness `R/N`. -/
theorem shellThickness_dim_one {R : ℝ} {N k : ℕ} (hk : k < N) :
    shellThickness R 1 N k = R / N := by
  have hN : 0 < N := lt_of_le_of_lt (Nat.zero_le k) hk
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  rw [shellThickness_eq' hk]
  simp only [Nat.cast_one, inv_one, Real.rpow_one]
  field_simp
  ring

/-- **Dimension one is all-or-nothing.**  Either every shell is thick or none is; this shows the
terminal-block dichotomy of `exists_thick_threshold` is attained at both extremes. -/
theorem thickCount_dim_one {R δ : ℝ} (N : ℕ) :
    thickCount R 1 N δ = if δ < R / N then N else 0 := by
  rw [thickCount]
  by_cases h : δ < R / N
  · rw [if_pos h, Finset.filter_true_of_mem, Finset.card_range]
    intro k hk
    rw [Finset.mem_range] at hk
    rwa [shellThickness_dim_one hk]
  · rw [if_neg h, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    intro k hk
    rw [Finset.mem_range] at hk
    rwa [shellThickness_dim_one hk]

end Catalog.Cryptography.ShellBudget