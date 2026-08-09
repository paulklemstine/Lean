/-
# Sharp thresholds: the smallest number of each small multiplicity

Research cycle: *how early can a given multiplicity appear?*

The catalog records the classical specimens — `6` occurs three times, `10` occurs four
times, `120` occurs six times, `3003` occurs eight times — as **exact** multiplicity
computations (`Singmaster.mult_six`, `mult_ten`, `mult_120`, `mult_3003`).  What the
catalog does *not* record is that these specimens are the **first** ones: no smaller
number attains the same multiplicity.  This file proves the matching lower bounds, so
that each classical example is upgraded to a sharp threshold.

## Method

The engine is the parity decomposition `mult t = 2 + 2·#leftInt t + #centerOcc t`
(`Singmaster.mult_eq_two_add_two_mul_leftInt`) together with `centerOcc_card_le_one`.
A multiplicity of `6` therefore forces **two distinct left-interior occurrences**
`C(n,j) = C(m,k) = t` with `2 ≤ j`, `2 ≤ k`, `2j < n`, `2k < m`.  Distinct interior
occurrences have distinct columns (`Singmaster.row_unique`), so the larger column `k`
satisfies `k ≥ 3`, and unimodality of Pascal's rows
(`Singmaster.choose_le_choose_of_le_fold`) turns a large column into a large value:

* if `k ≥ 4` then `t ≥ C(9,4) = 126`;
* if `k = 3` then `j = 2`, so `t` is simultaneously of the form `C(m,3)` with `m ≥ 7`
  and `C(n,2)`; the three candidates `35, 56, 84` below `120` are not triangular, so
  `t ≥ 120`.

This is a genuine two-parameter descent, not a finite check: the value `120` is forced
by the *shape* of the two occurrences, and only three residual numbers are decided by
computation.

## Results

* `Catalog.Novelty.MinimalValues.six_le_t_of_three_le_mult` — `6` is the smallest number
  occurring at least three times;
* `Catalog.Novelty.MinimalValues.ten_le_t_of_four_le_mult` — `10` is the smallest number
  occurring at least four times;
* `Catalog.Novelty.MinimalValues.min_value_of_six_le_mult` — **`120` is the smallest
  number occurring at least six times**;
* `Catalog.Novelty.MinimalValues.min_value_of_eight_le_mult` — **`3003` is the smallest
  number occurring at least eight times**, obtained by pushing the same descent one level
  deeper (three interior columns instead of two);
* `Catalog.Novelty.MinimalValues.is_least_six` / `is_least_three` / `is_least_four` /
  `is_least_eight` — the packaged "least element" statements combining the bounds with the
  catalog's exact computations `mult_six`, `mult_ten`, `mult_120`, `mult_3003`.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterParity
import Combinatorics.SingmasterMaxBelowMillion
import Combinatorics.SingmasterExactCounts
import Combinatorics.SingmasterCentralBinomialExtended
import Novelty.SingmasterSmoothHierarchy

open Finset Singmaster

namespace Catalog.Novelty.MinimalValues

/-! ## The degenerate small values

`occ` is `irreducible` in the catalog, so the tiny multiplicities are recorded once here
by kernel evaluation of the (very small) search boxes. -/

unseal Singmaster.occ in
theorem mult_zero : mult 0 = 0 := by decide

unseal Singmaster.occ in
/-- `1` occurs three times inside the search box `[0,1]²`; the genuine multiplicity of
`1` is infinite, which is why every threshold statement below excludes it. -/
theorem mult_one : mult 1 = 3 := by decide

unseal Singmaster.occ in
theorem mult_seven : mult 7 = 2 := by decide

unseal Singmaster.occ in
theorem mult_eight : mult 8 = 2 := by decide

unseal Singmaster.occ in
theorem mult_nine : mult 9 = 2 := by decide

/-! ## Two interior occurrences force a large value -/

/-- A number carrying two left-interior occurrences in **distinct** columns `2 ≤ j < k`
is at least `120`.  The proof splits on `k ≥ 4` (unimodality already gives `t ≥ C(9,4)`)
and `k = 3` (then `t` must be both a tetrahedral-type number `C(m,3)`, `m ≥ 7`, and a
triangular number `C(n,2)`; the candidates `35, 56, 84` fail). -/
theorem large_of_two_interior {t n m j k : ℕ} (hj : 2 ≤ j) (hjk : j < k)
    (hkm : 2 * k < m) (hm : m.choose k = t) (hjn : 2 * j < n) (hn : n.choose j = t) :
    120 ≤ t := by
  by_contra hlt
  push_neg at hlt
  have hk3 : 3 ≤ k := by omega
  rcases Nat.lt_or_ge k 4 with hk4 | hk4
  · -- `k = 3`, hence `j = 2`
    have hk : k = 3 := by omega
    have hj2 : j = 2 := by omega
    subst hk; subst hj2
    have h10 : (10 : ℕ) ≤ t := by
      calc (10 : ℕ) = (5 : ℕ).choose 2 := by decide
        _ ≤ n.choose 2 := Nat.choose_le_choose 2 (by omega)
        _ = t := hn
    -- the row `m` is small
    have hm10 : m < 10 := by
      by_contra hcon
      push_neg at hcon
      have : (120 : ℕ) ≤ t := by
        calc (120 : ℕ) = (10 : ℕ).choose 3 := by decide
          _ ≤ m.choose 3 := Nat.choose_le_choose 3 hcon
          _ = t := hm
      omega
    have hnt : n ≤ t := row_le_of_choose_eq (by omega) (by omega) hn
    interval_cases m <;> simp only [Nat.choose] at hm <;> subst hm <;>
      (interval_cases n <;> revert hn <;> decide)
  · -- `k ≥ 4`: unimodality gives `C(9,4) ≤ C(m,4) ≤ C(m,k) = t`
    have hkm' : k ≤ m := by omega
    have h4 : (4 : ℕ) ≤ min k (m - k) := by omega
    have h1 : m.choose 4 ≤ m.choose k := choose_le_choose_of_le_fold hkm' h4
    have h9 : (9 : ℕ) ≤ m := by omega
    have h2 : (9 : ℕ).choose 4 ≤ m.choose 4 := Nat.choose_le_choose 4 h9
    have : (126 : ℕ) ≤ t := by
      calc (126 : ℕ) = (9 : ℕ).choose 4 := by decide
        _ ≤ m.choose 4 := h2
        _ ≤ m.choose k := h1
        _ = t := hm
    omega

/-! ## Extracting two interior occurrences from multiplicity six -/

/-- Multiplicity at least six produces two distinct left-interior occurrences. -/
theorem exists_two_interior {t : ℕ} (ht : 3 ≤ t) (hmul : 6 ≤ mult t) :
    ∃ n m j k : ℕ, 2 ≤ j ∧ j < k ∧ 2 * k < m ∧ m.choose k = t ∧
      2 * j < n ∧ n.choose j = t := by
  have hdec := mult_eq_two_add_two_mul_leftInt ht
  have hcen := centerOcc_card_le_one (t := t) (by omega)
  have hL : 1 < (leftInt t).card := by omega
  obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.mp hL
  obtain ⟨n₁, j₁⟩ := a
  obtain ⟨n₂, j₂⟩ := b
  rw [mem_leftInt (by omega)] at ha hb
  obtain ⟨⟨hjn₁, hc₁⟩, hlt₁, hj₁⟩ := ha
  obtain ⟨⟨hjn₂, hc₂⟩, hlt₂, hj₂⟩ := hb
  have hne : j₁ ≠ j₂ := by
    intro h
    subst h
    have : n₁ = n₂ := row_unique (by omega) hjn₁ hjn₂ (by rw [hc₁, hc₂])
    exact hab (by rw [this])
  rcases Nat.lt_or_ge j₁ j₂ with h | h
  · exact ⟨n₁, n₂, j₁, j₂, hj₁, h, hlt₂, hc₂, hlt₁, hc₁⟩
  · exact ⟨n₂, n₁, j₂, j₁, hj₂, by omega, hlt₁, hc₁, hlt₂, hc₂⟩

/-! ## The thresholds -/

/-- **`120` is the smallest number occurring at least six times in Pascal's triangle.**
(The small values `t ≤ 2` are handled directly: `mult 0 = 0`, `mult 1 = 3`,
`mult 2 = 1`.) -/
theorem min_value_of_six_le_mult {t : ℕ} (hmul : 6 ≤ mult t) : 120 ≤ t := by
  rcases Nat.lt_or_ge t 3 with ht | ht
  · interval_cases t
    · rw [mult_zero] at hmul; omega
    · rw [mult_one] at hmul; omega
    · rw [mult_two] at hmul; omega
  · obtain ⟨n, m, j, k, hj, hjk, hkm, hm, hjn, hn⟩ := exists_two_interior ht hmul
    exact large_of_two_interior hj hjk hkm hm hjn hn

/-- `120` really is a least element of `{t | 6 ≤ mult t}`. -/
theorem is_least_six : IsLeast {t : ℕ | 6 ≤ mult t} 120 :=
  ⟨by simp [Set.mem_setOf_eq, mult_120], fun _ h => min_value_of_six_le_mult h⟩

/-- `6` is the smallest number (other than `1`, whose row-boundary occurrences are
degenerate) occurring at least three times. -/
theorem six_le_t_of_three_le_mult {t : ℕ} (ht : 2 ≤ t) (hmul : 3 ≤ mult t) : 6 ≤ t := by
  by_contra hlt
  push_neg at hlt
  interval_cases t
  · rw [mult_two] at hmul; omega
  · rw [mult_three] at hmul; omega
  · rw [mult_four] at hmul; omega
  · rw [mult_five] at hmul; omega

/-- `6` is a least element of `{t | 2 ≤ t ∧ 3 ≤ mult t}`. -/
theorem is_least_three : IsLeast {t : ℕ | 2 ≤ t ∧ 3 ≤ mult t} 6 :=
  ⟨by simp [Set.mem_setOf_eq, mult_six], fun _ h => six_le_t_of_three_le_mult h.1 h.2⟩

/-- `10` is the smallest number occurring at least four times. -/
theorem ten_le_t_of_four_le_mult {t : ℕ} (hmul : 4 ≤ mult t) : 10 ≤ t := by
  by_contra hlt
  push_neg at hlt
  interval_cases t
  · rw [mult_zero] at hmul; omega
  · rw [mult_one] at hmul; omega
  · rw [mult_two] at hmul; omega
  · rw [mult_three] at hmul; omega
  · rw [mult_four] at hmul; omega
  · rw [mult_five] at hmul; omega
  · rw [mult_six] at hmul; omega
  · rw [mult_seven] at hmul; omega
  · rw [mult_eight] at hmul; omega
  · rw [mult_nine] at hmul; omega

/-- `10` really is a least element of `{t | 4 ≤ mult t}`. -/
theorem is_least_four : IsLeast {t : ℕ | 4 ≤ mult t} 10 :=
  ⟨by simp [Set.mem_setOf_eq, mult_ten], fun _ h => ten_le_t_of_four_le_mult h⟩

/-! ## The multiplicity-eight threshold: `3003`

Singmaster's celebrated specimen `3003 = C(3003,1) = C(78,2) = C(15,5) = C(14,6)` (and
their four mirror images) occurs eight times.  We show no smaller number does.  The
argument is the same descent, one level deeper: multiplicity `8` forces **three**
left-interior occurrences, hence (columns being distinct) a column `k ≥ 4` together with
a second column `2 ≤ j < k`.  Unimodality caps `k ≤ 6` and both rows by `78`, leaving a
small explicit box in which no coincidence `C(n,j) = C(m,k)` below `3003` exists. -/

/-- Three interior occurrences in strictly increasing columns; the largest column is
`≥ 4` because three distinct columns are all `≥ 2`. -/
theorem exists_three_columns {t : ℕ} (ht : 3 ≤ t) (hmul : 8 ≤ mult t) :
    ∃ n₁ n₂ m j₁ j₂ k : ℕ, 2 ≤ j₁ ∧ j₁ < j₂ ∧ j₂ < k ∧ 4 ≤ k ∧
      2 * j₁ < n₁ ∧ n₁.choose j₁ = t ∧ 2 * j₂ < n₂ ∧ n₂.choose j₂ = t ∧
      2 * k < m ∧ m.choose k = t := by
  classical
  have ht2 : 2 ≤ t := by omega
  have hdec := mult_eq_two_add_two_mul_leftInt ht
  have hcen := centerOcc_card_le_one ht2
  have hcard : 3 ≤ (leftInt t).card := by omega
  set S := (leftInt t).image Prod.snd with hS
  have hScard : (leftInt t).card = S.card :=
    (Finset.card_image_of_injOn (SmoothHierarchy.leftInt_col_injective ht2)).symm
  have hS3 : 3 ≤ S.card := by omega
  -- every column in `S` is an interior column carrying an occurrence of `t`
  have hocc : ∀ j ∈ S, 2 ≤ j ∧ ∃ n, 2 * j < n ∧ n.choose j = t := by
    intro j hj
    rw [hS, mem_image] at hj
    obtain ⟨⟨a, b⟩, hmem, rfl⟩ := hj
    rw [mem_leftInt ht2] at hmem
    exact ⟨hmem.2.2, a, hmem.2.1, hmem.1.2⟩
  have hne : S.Nonempty := Finset.card_pos.mp (by omega)
  set k := S.max' hne with hk
  have hkS : k ∈ S := S.max'_mem hne
  have hk4 : 4 ≤ k := by
    by_contra hcon
    push_neg at hcon
    have hsub : S ⊆ Finset.Icc 2 3 := by
      intro j hj
      exact Finset.mem_Icc.2 ⟨(hocc j hj).1, le_trans (S.le_max' j hj) (by omega)⟩
    have := Finset.card_le_card hsub
    rw [Nat.card_Icc] at this
    omega
  -- two further columns, both strictly below the maximal one
  have hT : 1 < (S.erase k).card := by
    rw [Finset.card_erase_of_mem hkS]
    omega
  obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.mp hT
  have haS : a ∈ S := Finset.mem_of_mem_erase ha
  have hbS : b ∈ S := Finset.mem_of_mem_erase hb
  have hak : a < k := lt_of_le_of_ne (S.le_max' a haS) (Finset.ne_of_mem_erase ha)
  have hbk : b < k := lt_of_le_of_ne (S.le_max' b hbS) (Finset.ne_of_mem_erase hb)
  obtain ⟨ha2, n₁, hn₁, hc₁⟩ := hocc a haS
  obtain ⟨hb2, n₂, hn₂, hc₂⟩ := hocc b hbS
  obtain ⟨_, m, hmk, hcm⟩ := hocc k hkS
  rcases Nat.lt_or_ge a b with hlt | hge
  · exact ⟨n₁, n₂, m, a, b, k, ha2, hlt, hbk, hk4, hn₁, hc₁, hn₂, hc₂, hmk, hcm⟩
  · have hba : b < a := lt_of_le_of_ne hge (fun h => hab (by omega))
    exact ⟨n₂, n₁, m, b, a, k, hb2, hba, hak, hk4, hn₂, hc₂, hn₁, hc₁, hmk, hcm⟩

set_option maxRecDepth 40000 in
/-- The residual finite search.  No value below `3003` carrying an occurrence in a
column `4 ≤ c` (necessarily with row `m ≤ 17`) carries two further interior occurrences
in strictly smaller columns (necessarily with rows `≤ 78`).  Both boxes are forced by
unimodality of Pascal's rows; the search is genuinely nontrivial — e.g. `210 = C(10,4) =
C(21,2)` does have one smaller column, and is excluded only by the *second* one. -/
theorem finite_check :
    ∀ m ∈ Finset.range 18, ∀ c ∈ Finset.range 7, 4 ≤ c → 2 * c < m → m.choose c < 3003 →
      ∀ n₁ ∈ Finset.range 79, ∀ j₁ ∈ Finset.range c, 2 ≤ j₁ → 2 * j₁ < n₁ →
        n₁.choose j₁ = m.choose c →
        ∀ n₂ ∈ Finset.range 79, ∀ j₂ ∈ Finset.range c, j₁ < j₂ → 2 * j₂ < n₂ →
          n₂.choose j₂ ≠ m.choose c := by
  decide

/-- **`3003` is the smallest number occurring at least eight times in Pascal's
triangle.**  Together with `Singmaster.mult_3003` this pins Singmaster's specimen as the
first number of multiplicity eight. -/
theorem min_value_of_eight_le_mult {t : ℕ} (hmul : 8 ≤ mult t) : 3003 ≤ t := by
  rcases Nat.lt_or_ge t 3 with ht | ht
  · interval_cases t
    · rw [mult_zero] at hmul; omega
    · rw [mult_one] at hmul; omega
    · rw [mult_two] at hmul; omega
  obtain ⟨n₁, n₂, m, j₁, j₂, k, hj₁, hj₁₂, hj₂k, hk4, hn₁, hc₁, hn₂, hc₂, hkm, hm⟩ :=
    exists_three_columns ht hmul
  by_contra hlt
  push_neg at hlt
  -- rows of interior occurrences in columns `≥ 2` are at most `78`
  have hrow : ∀ n j : ℕ, 2 ≤ j → 2 * j < n → n.choose j = t → n < 79 := by
    intro n j hj hjn hval
    by_contra hcon
    push_neg at hcon
    have h1 : n.choose 2 ≤ n.choose j := choose_two_le_choose hj (by omega)
    have h2 : (79 : ℕ).choose 2 ≤ n.choose 2 := Nat.choose_le_choose 2 hcon
    have : (3081 : ℕ) ≤ t := by
      calc (3081 : ℕ) = (79 : ℕ).choose 2 := by decide
        _ ≤ n.choose 2 := h2
        _ ≤ n.choose j := h1
        _ = t := hval
    omega
  -- the largest column is at most `6`
  have hk7 : k < 7 := by
    by_contra hcon
    push_neg at hcon
    have h1 : m.choose 7 ≤ m.choose k :=
      choose_le_choose_of_le_fold (by omega) (by omega)
    have h2 : (15 : ℕ).choose 7 ≤ m.choose 7 := Nat.choose_le_choose 7 (by omega)
    have : (6435 : ℕ) ≤ t := by
      calc (6435 : ℕ) = (15 : ℕ).choose 7 := by decide
        _ ≤ m.choose 7 := h2
        _ ≤ m.choose k := h1
        _ = t := hm
    omega
  -- and its row is at most `17`
  have hm18 : m < 18 := by
    by_contra hcon
    push_neg at hcon
    have h1 : m.choose 4 ≤ m.choose k :=
      choose_le_choose_of_le_fold (by omega) (by omega)
    have h2 : (18 : ℕ).choose 4 ≤ m.choose 4 := Nat.choose_le_choose 4 hcon
    have : (3060 : ℕ) ≤ t := by
      calc (3060 : ℕ) = (18 : ℕ).choose 4 := by decide
        _ ≤ m.choose 4 := h2
        _ ≤ m.choose k := h1
        _ = t := hm
    omega
  exact finite_check m (Finset.mem_range.2 hm18) k (Finset.mem_range.2 hk7) hk4 hkm
    (by rw [hm]; omega)
    n₁ (Finset.mem_range.2 (hrow n₁ j₁ hj₁ hn₁ hc₁)) j₁ (Finset.mem_range.2 (by omega))
    hj₁ hn₁ (by rw [hc₁, hm])
    n₂ (Finset.mem_range.2 (hrow n₂ j₂ (by omega) hn₂ hc₂)) j₂ (Finset.mem_range.2 hj₂k)
    hj₁₂ hn₂ (by rw [hc₂, hm])

/-- **The general growth threshold.**  A number of multiplicity at least `2m+2` is at
least `C(2m+3, m+1)`: multiplicity forces a wide column, and a wide interior column
forces a large value.  For `m = 1, 2, 3` this reads `t ≥ 10, 35, 126`; the sharp
thresholds proved above (`10`, `120`, `3003`) show how much room the general bound
leaves. -/
theorem value_ge_of_mult {t m : ℕ} (ht : 3 ≤ t) (hm : 1 ≤ m) (hmul : 2 * m + 2 ≤ mult t) :
    (2 * m + 3).choose (m + 1) ≤ t := by
  obtain ⟨n, k, hkn, hck, hlt, hkm⟩ :=
    SmoothHierarchy.exists_big_column_of_mult ht hm hmul
  calc (2 * m + 3).choose (m + 1) ≤ n.choose (m + 1) :=
        Nat.choose_le_choose (m + 1) (by omega)
    _ ≤ n.choose k := choose_le_choose_of_le_fold hkn (by omega)
    _ = t := hck

/-- `3003` really is a least element of `{t | 8 ≤ mult t}`. -/
theorem is_least_eight : IsLeast {t : ℕ | 8 ≤ mult t} 3003 :=
  ⟨by simp [Set.mem_setOf_eq, mult_3003], fun _ h => min_value_of_eight_le_mult h⟩

end Catalog.Novelty.MinimalValues