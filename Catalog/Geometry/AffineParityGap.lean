/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Applications.AffineSubspaceStats.ExactProduct

/-!
# Affine subspace statistics in `𝔽₂ⁿ`: the parity bound is never attained

`Catalog/Applications/AffineSubspaceStats/AffineStats.lean` proves the *parity bound*
`P[|F ∩ A| odd] ≤ 1/2` for a uniformly random affine `d`-cube `F` in `𝔽₂ⁿ` (`d ≥ 1`),
shows that `1/2` is the correct limit as `n → ∞`, and verifies by a kernel computation that
for `n = d = 2` the maximum is `3/8 < 1/2`.

This file replaces that single finite check by a general theorem with an explicit rate.
The mechanism is a *degeneracy defect*: writing the affine `(d+1)`-cube as a pair of
parallel `d`-cubes based at `c` and `c + u`, the parity bound for a fixed remaining
direction tuple `w` reads `2 · #{(c,u)} ≤ 2^{2n}`, and equality forces the set of base
points with odd count to have size exactly `2^{n-1}`.  But whenever `w` is *linearly
dependent* the count `|cube ∩ A|` is even for **every** base point (the fibres of
`y ↦ ∑ yᵢ wᵢ` have even size), so those tuples contribute nothing at all.

## Main results

* `AffineParityGap.cnt_even_of_not_indep` : a degenerate direction tuple always gives an
  even intersection count.
* `AffineParityGap.oddSet_card_le_indep` : `2 · #oddSet ≤ (#independent tuples) · 2^{2n}`.
* `AffineParityGap.oddProb_le_indepRatio` : hence
  `P[|F ∩ A| odd] ≤ (1/2) · (#independent `(d)`-tuples) / 2^{nd}`.
* `AffineParityGap.oddProb_le_half_sub` : in particular, for cubes of dimension `≥ 2`,
  `P[|F ∩ A| odd] ≤ 1/2 - 2^{-(nd+1)}`, so
* `AffineParityGap.maxOddProb_lt_half` : `max_A P[|F ∩ A| odd] < 1/2` for **every** finite
  `n` and every cube dimension `≥ 2`.  This answers, in the cube model, the question of
  non-attainment left open by the single case `n = d = 2`.
* `AffineParityGap.oddProb_le_half_mul_prod` : the sharp form of the bound,
  `P[|F ∩ A| odd] ≤ (1/2) ∏_{i<d} (1 - 2^{i-n})` whenever `d ≤ n`.
* `AffineParityGap.flatProb_odd_le_half_sub` : the corresponding statement for `λ(d,s)`
  with `s` odd.
* `AffineParityGap.oddProb_eq_indepRatio_iff` : **the exact criterion for equality** — the
  bound is attained by `A` iff for every independent direction tuple exactly half of the
  base points give an odd count.

The bound is *sharp*: for `n = 2`, `d = 1` it gives `3/8`, the exact maximum of
`AffineStats.maxOddProb_dim2_lt_half`.  Three companion files exhibit the equality cases and
the failures:

* `Catalog/Geometry/AffineParityBent.lean` : `D = 2` and `n` even (bent sets);
* `Catalog/Geometry/AffineParityOdd.lean` : `D = 2` and `n` odd — equality is impossible;
* `Catalog/Geometry/AffineParitySingleton.lean`, `Catalog/Geometry/AffineParityTopDim.lean` :
  `D = n`, where the extremal sets are exactly the sets of odd cardinality.
-/

namespace AffineParityGap

open Finset AffineStats

variable {n d : ℕ}

section Degenerate

/-- The set of base points `c` for which the affine cube with directions `w` meets `A` in an
odd number of points. -/
def oddBase (A : Finset (Vec n)) (w : Fin d → Vec n) : Finset (Vec n) :=
  univ.filter fun c => ¬ (2 ∣ cnt A c w)

/-- If the directions `w` are linearly **dependent**, then the map `y ↦ ∑ yᵢwᵢ` is
`2^k`-to-one for some `k ≥ 1`, so every affine cube with these directions meets every set
`A` in an even number of points. -/
theorem cnt_even_of_not_indep (A : Finset (Vec n)) (c : Vec n) {w : Fin d → Vec n}
    (hw : ¬ Indep w) : 2 ∣ cnt A c w := by
  classical
  unfold Indep at hw
  push_neg at hw
  obtain ⟨y₀, hy₀, hsum⟩ := hw
  obtain ⟨i₀, hi₀⟩ := exists_coord_one hy₀
  have hstable : ∀ y : Fin d → ZMod 2, pt c w (y + y₀) = pt c w y := by
    intro y
    have hs : (∑ i, (y + y₀) i • w i) = (∑ i, y i • w i) + ∑ i, y₀ i • w i := by
      rw [← Finset.sum_add_distrib]
      exact Finset.sum_congr rfl fun i _ => by simp [add_smul]
    simp only [pt, hs, hsum, add_zero]
  set T : Finset (Fin d → ZMod 2) := univ.filter fun y => pt c w y ∈ A with hT
  have hcancel : ∀ y : Fin d → ZMod 2, y + y₀ + y₀ = y := by
    intro y; funext i; simp [add_assoc, CharTwo.add_self_eq_zero]
  have hbij : (T.filter fun y => y i₀ = 0).card = (T.filter fun y => y i₀ = 1).card := by
    refine Finset.card_nbij' (fun y => y + y₀) (fun y => y + y₀) ?_ ?_ ?_ ?_
    · intro y hy
      simp only [Finset.mem_coe, mem_filter, hT, mem_univ, true_and] at hy ⊢
      exact ⟨by rw [hstable]; exact hy.1, by simp [hy.2, hi₀]⟩
    · intro y hy
      simp only [Finset.mem_coe, mem_filter, hT, mem_univ, true_and] at hy ⊢
      refine ⟨by rw [hstable]; exact hy.1, ?_⟩
      have : y i₀ + y₀ i₀ = (0 : ZMod 2) := by rw [hy.2, hi₀]; decide
      simpa using this
    · intro y _; exact hcancel y
    · intro y _; exact hcancel y
  have hsplit := Finset.card_filter_add_card_filter_not (s := T) (p := fun y => y i₀ = 0)
  have hnot : (T.filter fun y => ¬ (y i₀ = 0)) = T.filter fun y => y i₀ = 1 := by
    refine Finset.filter_congr fun y _ => ?_
    constructor
    · intro h; revert h; generalize y i₀ = t; revert t; decide
    · intro h; rw [h]; decide
  rw [hnot, ← hbij] at hsplit
  have hcnt : cnt A c w = T.card := rfl
  exact ⟨(T.filter fun y => y i₀ = 0).card, by omega⟩

/-- For a degenerate direction tuple, no base point has an odd count. -/
lemma oddBase_eq_empty_of_not_indep (A : Finset (Vec n)) {w : Fin d → Vec n}
    (hw : ¬ Indep w) : oddBase A w = ∅ := by
  rw [oddBase, Finset.filter_eq_empty_iff]
  intro c _
  simpa [Nat.dvd_iff_mod_eq_zero] using cnt_even_of_not_indep A c hw

end Degenerate

section Counting

/-- The pair count appearing in the parity argument, evaluated exactly. -/
lemma card_pairs_eq (A : Finset (Vec n)) (w : Fin d → Vec n) :
    (univ.filter fun p : Vec n × Vec n =>
        ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card
      = 2 * ((oddBase A w).card * (2 ^ n - (oddBase A w).card)) := by
  classical
  have hset : (univ.filter fun p : Vec n × Vec n =>
      ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w)))
      = univ.filter fun p : Vec n × Vec n =>
          ¬ ((p.1 ∈ oddBase A w) ↔ (p.1 + p.2 ∈ oddBase A w)) := by
    refine Finset.filter_congr fun p _ => ?_
    simp only [oddBase, Finset.mem_filter, Finset.mem_univ, true_and]
    omega
  rw [hset, card_sym_diff_pairs]

/-- Decomposition of the odd-parameter set of a `(d+1)`-cube according to the last `d`
directions. -/
lemma oddSet_card_eq_sum (A : Finset (Vec n)) :
    (oddSet n (d + 1) A).card = ∑ w : Fin d → Vec n,
      (univ.filter fun p : Vec n × Vec n =>
        ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card := by
  classical
  set f : Vec n → Vec n → (Fin d → Vec n) → ℕ :=
    fun c a w => if ¬ (2 ∣ (cnt A c w + cnt A (c + a) w)) then 1 else 0 with hf
  have hL : (oddSet n (d + 1) A).card
      = ∑ c : Vec n, ∑ a : Vec n, ∑ w : Fin d → Vec n, f c a w := by
    simp only [oddSet, Finset.card_filter]
    rw [Fintype.sum_prod_type]
    refine Finset.sum_congr rfl ?_
    intro c _
    rw [← Fintype.sum_equiv (Fin.consEquiv (fun _ : Fin (d + 1) => Vec n))
        (fun q => if ¬ (2 ∣ cnt A c (Fin.cons q.1 q.2)) then 1 else 0)
        (fun v => if ¬ (2 ∣ cnt A c v) then 1 else 0) (fun q => by rfl)]
    rw [Fintype.sum_prod_type]
    refine Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun w _ => ?_))
    rw [cnt_succ]
    simp [hf]
  rw [hL]
  rw [show (∑ c : Vec n, ∑ a : Vec n, ∑ w : Fin d → Vec n, f c a w)
      = ∑ c : Vec n, ∑ w : Fin d → Vec n, ∑ a : Vec n, f c a w from
    Finset.sum_congr rfl (fun c _ => Finset.sum_comm)]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun w _ => ?_)
  rw [Finset.card_filter, Fintype.sum_prod_type]

/-- **The refined parity count.** Only linearly independent direction tuples can contribute
to an odd intersection count. -/
theorem oddSet_card_le_indep (A : Finset (Vec n)) :
    2 * (oddSet n (d + 1) A).card
      ≤ (univ.filter fun w : Fin d → Vec n => Indep w).card * 2 ^ (2 * n) := by
  classical
  rw [oddSet_card_eq_sum, Finset.mul_sum]
  have hterm : ∀ w : Fin d → Vec n,
      2 * (univ.filter fun p : Vec n × Vec n =>
          ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card
        ≤ if Indep w then 2 ^ (2 * n) else 0 := by
    intro w
    by_cases hw : Indep w
    · rw [if_pos hw]; exact key_pair_bound A w
    · rw [if_neg hw, card_pairs_eq, oddBase_eq_empty_of_not_indep A hw]
      simp
  refine le_trans (Finset.sum_le_sum fun w _ => hterm w) ?_
  rw [← Finset.sum_filter, Finset.sum_const, smul_eq_mul]

end Counting

section Bounds

/-- **The main bound.** The probability that a random affine `(d+1)`-cube meets `A` in an
odd number of points is at most half the fraction of linearly independent `d`-tuples. -/
theorem oddProb_le_indepRatio (A : Finset (Vec n)) :
    oddProb n (d + 1) A
      ≤ ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) / (2 * 2 ^ (n * d)) := by
  have h := oddSet_card_le_indep (n := n) (d := d) A
  have hQ : (2 : ℚ) * (oddSet n (d + 1) A).card
      ≤ ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) * 2 ^ (2 * n) := by
    exact_mod_cast h
  rw [oddProb, div_le_div_iff₀ (by positivity) (by positivity)]
  have hexp : (2 : ℚ) ^ (n * (d + 1 + 1)) = 2 ^ (n * d) * 2 ^ (2 * n) := by
    rw [← pow_add]; ring_nf
  rw [hexp]
  nlinarith [hQ, pow_pos (show (0:ℚ) < 2 by norm_num) (n * d),
    pow_pos (show (0:ℚ) < 2 by norm_num) (2 * n)]

/-- The zero tuple is never independent (in positive length). -/
lemma not_indep_zero (hd : 0 < d) : ¬ Indep (fun _ : Fin d => (0 : Vec n)) := by
  intro h
  have hy : (fun i : Fin d => if i = ⟨0, hd⟩ then (1 : ZMod 2) else 0) ≠ 0 := by
    intro hcon
    have := congrFun hcon ⟨0, hd⟩
    simp at this
  exact h _ hy (by simp)

/-- Hence there are at most `2^{nd} - 1` independent tuples. -/
lemma card_indep_le (hd : 0 < d) :
    (univ.filter fun w : Fin d → Vec n => Indep w).card ≤ 2 ^ (n * d) - 1 := by
  classical
  have hzero : (fun _ : Fin d => (0 : Vec n)) ∉ (univ.filter fun w : Fin d → Vec n => Indep w) := by
    simp [not_indep_zero (n := n) hd]
  have hsub : (univ.filter fun w : Fin d → Vec n => Indep w)
      ⊆ univ.erase (fun _ : Fin d => (0 : Vec n)) := by
    intro w hw
    refine Finset.mem_erase.2 ⟨?_, mem_univ _⟩
    rintro rfl
    exact hzero hw
  have hcard : (univ.erase (fun _ : Fin d => (0 : Vec n))).card = 2 ^ (n * d) - 1 := by
    rw [Finset.card_erase_of_mem (mem_univ _), Finset.card_univ]
    congr 1
    simp [← pow_mul]
  calc (univ.filter fun w : Fin d → Vec n => Indep w).card
      ≤ (univ.erase (fun _ : Fin d => (0 : Vec n))).card := Finset.card_le_card hsub
    _ = 2 ^ (n * d) - 1 := hcard

/-- **Strict parity bound with an explicit gap.** For cubes of dimension at least `2` the
parity bound `1/2` is never attained: for all `n` and all `d ≥ 1`,
`P[|F ∩ A| odd] ≤ 1/2 - 2^{-(nd+1)}`. -/
theorem oddProb_le_half_sub (A : Finset (Vec n)) (hd : 0 < d) :
    oddProb n (d + 1) A ≤ 1 / 2 - 1 / 2 ^ (n * d + 1) := by
  refine le_trans (oddProb_le_indepRatio A) ?_
  have hle : ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) ≤ 2 ^ (n * d) - 1 := by
    have h := card_indep_le (n := n) hd
    have h1 : (1 : ℕ) ≤ 2 ^ (n * d) := Nat.one_le_two_pow
    calc ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ)
        ≤ ((2 ^ (n * d) - 1 : ℕ) : ℚ) := by exact_mod_cast h
      _ = 2 ^ (n * d) - 1 := by push_cast [Nat.cast_sub h1]; ring
  have hpos : (0 : ℚ) < 2 ^ (n * d) := by positivity
  rw [div_le_iff₀ (by positivity)]
  have : (1 : ℚ) / 2 ^ (n * d + 1) = 1 / (2 * 2 ^ (n * d)) := by
    rw [pow_succ]; ring_nf
  rw [this]
  field_simp
  linarith [hle]

/-- **Non-attainment.** For every finite `n` and every cube dimension `≥ 2`, the maximum
over all `A ⊆ 𝔽₂ⁿ` of the odd-intersection probability is strictly below `1/2`. -/
theorem maxOddProb_lt_half (n d : ℕ) : maxOddProb n (d + 2) < 1 / 2 := by
  have hle : maxOddProb n (d + 2) ≤ 1 / 2 - 1 / 2 ^ (n * (d + 1) + 1) := by
    refine Finset.sup'_le _ _ fun A _ => ?_
    exact oddProb_le_half_sub (d := d + 1) A (Nat.succ_pos d)
  have hpos : (0 : ℚ) < 1 / 2 ^ (n * (d + 1) + 1) := by positivity
  linarith

/-- **`λ(d,s) < 1/2` for odd `s`, with an explicit gap**, for cubes of dimension `≥ 2`. -/
theorem flatProb_odd_le_half_sub (A : Finset (Vec n)) (hd : 0 < d) {s : ℕ} (hs : Odd s) :
    flatProb n (d + 1) A s ≤ 1 / 2 - 1 / 2 ^ (n * d + 1) := by
  refine le_trans ?_ (oddProb_le_half_sub A hd)
  have hsub : hitSet n (d + 1) A s ⊆ oddSet n (d + 1) A := by
    intro p hp
    simp only [hitSet, Finset.mem_filter, Finset.mem_univ, true_and] at hp
    simp only [oddSet, Finset.mem_filter, Finset.mem_univ, true_and, hp]
    rw [Nat.odd_iff] at hs
    omega
  have hcard : ((hitSet n (d + 1) A s).card : ℚ) ≤ (oddSet n (d + 1) A).card := by
    exact_mod_cast Finset.card_le_card hsub
  rw [flatProb, oddProb]
  gcongr

end Bounds

section Equality

/-- The strict form of the elementary inequality `4m(M-m) ≤ M²`. -/
lemma four_mul_mul_lt (M m : ℕ) (h : m ≤ M) (hne : 2 * m ≠ M) : 4 * (m * (M - m)) < M * M := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  simp only [Nat.add_sub_cancel_left]
  have hmk : (m : ℤ) ≠ (k : ℤ) := by
    intro hc
    exact hne (by omega)
  have h2 : ((m : ℤ) - k) ≠ 0 := sub_ne_zero_of_ne hmk
  have h3 : (0 : ℤ) < ((m : ℤ) - k) ^ 2 :=
    lt_of_le_of_ne (sq_nonneg _) (Ne.symm (pow_ne_zero 2 h2))
  zify
  nlinarith [h3]

/-- The number of base points with odd count never exceeds `2ⁿ`. -/
lemma card_oddBase_le (A : Finset (Vec n)) (w : Fin d → Vec n) :
    (oddBase A w).card ≤ 2 ^ n := by
  rw [← card_Vec n]
  exact Finset.card_le_univ _

/-- **Sufficiency for equality.**  If for every independent direction tuple exactly half of
the base points give an odd count, then the bound `oddProb_le_indepRatio` is attained. -/
theorem oddProb_eq_of_all_balanced (A : Finset (Vec n))
    (hbal : ∀ w : Fin d → Vec n, Indep w → 2 * (oddBase A w).card = 2 ^ n) :
    oddProb n (d + 1) A
      = ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) / (2 * 2 ^ (n * d)) := by
  classical
  have hterm : ∀ w : Fin d → Vec n,
      ((univ.filter fun p : Vec n × Vec n =>
        ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card : ℚ)
        = if Indep w then (2 : ℚ) ^ (2 * n) / 2 else 0 := by
    intro w
    rw [card_pairs_eq]
    by_cases hw : Indep w
    · rw [if_pos hw]
      have hcard := hbal w hw
      have hk : ((oddBase A w).card : ℚ) = 2 ^ n / 2 := by
        have h2 : (2 : ℚ) * (oddBase A w).card = 2 ^ n := by exact_mod_cast hcard
        linarith
      have hle : (oddBase A w).card ≤ 2 ^ n := card_oddBase_le A w
      have hcast : ((2 * ((oddBase A w).card * (2 ^ n - (oddBase A w).card)) : ℕ) : ℚ)
          = 2 * (((oddBase A w).card : ℚ) * ((2 : ℚ) ^ n - (oddBase A w).card)) := by
        push_cast [Nat.cast_sub hle]
        ring
      rw [hcast, hk, two_mul n, pow_add]
      ring
    · rw [if_neg hw, oddBase_eq_empty_of_not_indep A hw]
      simp
  have hsum : ((oddSet n (d + 1) A).card : ℚ)
      = ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) * ((2 : ℚ) ^ (2 * n) / 2) := by
    rw [oddSet_card_eq_sum]
    push_cast
    rw [Finset.sum_congr rfl fun w _ => hterm w, ← Finset.sum_filter, Finset.sum_const,
      nsmul_eq_mul]
  rw [oddProb, hsum, show n * (d + 1 + 1) = n * d + 2 * n from by ring, pow_add]
  have h1 : ((2 : ℚ) ^ (n * d)) ≠ 0 := by positivity
  have h2 : ((2 : ℚ) ^ (2 * n)) ≠ 0 := by positivity
  field_simp

/-- **Strict inequality off the balanced locus.** -/
theorem oddSet_card_lt_indep (A : Finset (Vec n)) {w₀ : Fin d → Vec n} (hw₀ : Indep w₀)
    (hne : 2 * (oddBase A w₀).card ≠ 2 ^ n) :
    2 * (oddSet n (d + 1) A).card
      < (univ.filter fun w : Fin d → Vec n => Indep w).card * 2 ^ (2 * n) := by
  classical
  rw [oddSet_card_eq_sum, Finset.mul_sum]
  have hle : ∀ w : Fin d → Vec n, w ∈ (univ : Finset (Fin d → Vec n)) →
      2 * (univ.filter fun p : Vec n × Vec n =>
          ¬ (2 ∣ (cnt A p.1 w + cnt A (p.1 + p.2) w))).card
        ≤ if Indep w then 2 ^ (2 * n) else 0 := by
    intro w _
    by_cases hw : Indep w
    · rw [if_pos hw]; exact key_pair_bound A w
    · rw [if_neg hw, card_pairs_eq, oddBase_eq_empty_of_not_indep A hw]
      simp
  have hlt : 2 * (univ.filter fun p : Vec n × Vec n =>
      ¬ (2 ∣ (cnt A p.1 w₀ + cnt A (p.1 + p.2) w₀))).card
      < if Indep w₀ then 2 ^ (2 * n) else 0 := by
    rw [if_pos hw₀, card_pairs_eq]
    have h := four_mul_mul_lt (2 ^ n) (oddBase A w₀).card (card_oddBase_le A w₀) hne
    calc 2 * (2 * ((oddBase A w₀).card * (2 ^ n - (oddBase A w₀).card)))
        = 4 * ((oddBase A w₀).card * (2 ^ n - (oddBase A w₀).card)) := by ring
      _ < 2 ^ n * 2 ^ n := h
      _ = 2 ^ (2 * n) := by rw [two_mul, pow_add]
  refine lt_of_lt_of_le (Finset.sum_lt_sum hle ⟨w₀, mem_univ _, hlt⟩) ?_
  rw [← Finset.sum_filter, Finset.sum_const, smul_eq_mul]

/-- **The exact criterion for equality in the refined parity bound.**  The upper bound
`oddProb_le_indepRatio` is attained by `A` if and only if, for every linearly independent
direction tuple `w`, exactly half of the base points `c` give an odd intersection count. -/
theorem oddProb_eq_indepRatio_iff (A : Finset (Vec n)) :
    oddProb n (d + 1) A
        = ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) / (2 * 2 ^ (n * d))
      ↔ ∀ w : Fin d → Vec n, Indep w → 2 * (oddBase A w).card = 2 ^ n := by
  refine ⟨fun heq w hw => ?_, oddProb_eq_of_all_balanced A⟩
  by_contra hne
  have hstrict := oddSet_card_lt_indep A hw hne
  have hQ : (2 : ℚ) * (oddSet n (d + 1) A).card
      < ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) * 2 ^ (2 * n) := by
    exact_mod_cast hstrict
  rw [oddProb] at heq
  have hpow : ((2 : ℚ) ^ (n * (d + 1 + 1))) = 2 ^ (n * d) * 2 ^ (2 * n) := by
    rw [← pow_add]; ring_nf
  rw [hpow] at heq
  have h1 : (0 : ℚ) < 2 ^ (n * d) := by positivity
  have h2 : (0 : ℚ) < 2 ^ (2 * n) := by positivity
  have hcard : ((oddSet n (d + 1) A).card : ℚ)
      = ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) * 2 ^ (2 * n) / 2 := by
    field_simp at heq
    linarith [heq]
  rw [hcard] at hQ
  linarith

end Equality

section Product

/-- The concrete independence predicate agrees with `LinearIndependent`. -/
lemma indep_iff_linearIndependent (w : Fin d → Vec n) :
    Indep w ↔ LinearIndependent (ZMod 2) w := by
  rw [Fintype.linearIndependent_iff]
  constructor
  · intro h g hg i
    by_contra hgi
    exact h g (fun hz => hgi (by rw [hz]; rfl)) hg
  · intro h y hy hsum
    exact hy (funext fun i => h y hsum i)

/-- The number of independent `d`-tuples in `𝔽₂ⁿ` is `∏_{i<d}(2ⁿ - 2^i)`. -/
theorem card_indep_eq_prod (hdn : d ≤ n) :
    (univ.filter fun w : Fin d → Vec n => Indep w).card
      = ∏ i : Fin d, (2 ^ n - 2 ^ (i : ℕ)) := by
  classical
  have hfr : Module.finrank (ZMod 2) (Vec n) = n := by simp [Vec]
  have hcard := card_linearIndependent (K := ZMod 2) (V := Vec n) (k := d)
    (by omega : d ≤ Module.finrank (ZMod 2) (Vec n))
  rw [hfr, ZMod.card] at hcard
  rw [show (univ.filter fun w : Fin d → Vec n => Indep w).card
      = Fintype.card {w : Fin d → Vec n // Indep w} from by
    rw [Fintype.card_subtype]]
  rw [← Nat.card_eq_fintype_card]
  rw [Nat.card_congr (Equiv.subtypeEquivRight (fun w => indep_iff_linearIndependent w))]
  exact hcard

/-- The fraction of independent tuples, in product form. -/
theorem indepRatio_eq_prod (hdn : d ≤ n) :
    ((univ.filter fun w : Fin d → Vec n => Indep w).card : ℚ) / (2 * 2 ^ (n * d))
      = (1 / 2) * ∏ i : Fin d, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ n) := by
  rw [card_indep_eq_prod hdn]
  have hprodcast : ((∏ i : Fin d, (2 ^ n - 2 ^ (i : ℕ)) : ℕ) : ℚ)
      = ∏ i : Fin d, ((2 : ℚ) ^ n - 2 ^ (i : ℕ)) := by
    rw [Nat.cast_prod]
    refine Finset.prod_congr rfl fun i _ => ?_
    have hle : (2 : ℕ) ^ (i : ℕ) ≤ 2 ^ n :=
      Nat.pow_le_pow_right (by norm_num) (le_trans (le_of_lt i.isLt) hdn)
    push_cast [Nat.cast_sub hle]
    ring
  have hsplit : ∏ i : Fin d, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ n)
      = (∏ i : Fin d, ((2 : ℚ) ^ n - 2 ^ (i : ℕ))) / 2 ^ (n * d) := by
    have h1 : ∀ i : Fin d, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ n)
        = ((2 : ℚ) ^ n - 2 ^ (i : ℕ)) / 2 ^ n := by
      intro i; field_simp
    rw [Finset.prod_congr rfl (fun i _ => h1 i), Finset.prod_div_distrib,
      Finset.prod_const, Finset.card_univ, Fintype.card_fin, ← pow_mul]
  rw [hprodcast, hsplit]
  ring

/-- **The sharp form of the parity bound.** For `d ≤ n`,
`P[|F ∩ A| odd] ≤ (1/2) ∏_{i<d} (1 - 2^{i-n})` for every `A ⊆ 𝔽₂ⁿ`.  For `n = 2, d = 1`
the right-hand side is `3/8`, exactly the maximum computed in
`AffineStats.maxOddProb_dim2_lt_half`. -/
theorem oddProb_le_half_mul_prod (A : Finset (Vec n)) (hdn : d ≤ n) :
    oddProb n (d + 1) A ≤ (1 / 2) * ∏ i : Fin d, (1 - (2 : ℚ) ^ (i : ℕ) / 2 ^ n) :=
  le_trans (oddProb_le_indepRatio A) (le_of_eq (indepRatio_eq_prod hdn))

end Product

end AffineParityGap