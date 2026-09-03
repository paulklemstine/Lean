/-
# Exact subword complexity of the binomial argmax staircase

Continuation of `MachineLearning.SturmianArgmaxStaircase`, where it is shown that the
increment word `w α n = ⌊(n+2)α⌋ - ⌊(n+1)α⌋` of the binomial argmax staircase is a
balanced binary word with **at most** `L + 1` factors of each length `L`.

Here the matching lower bound is proved for irrational slope: the word has **exactly**
`L + 1` factors of length `L`, i.e. the argmax staircase word is Sturmian (after the
`+1` shift).  The two ingredients are

* a self-contained density statement for the orbit `{kα}` of an irrational rotation,
  deduced from Dirichlet's approximation theorem (`fract_nat_mul_mem_Ioo`);
* a purely combinatorial "all levels are attained" lemma for finite sets of reals
  (`exists_lt_filter_card_eq`).

## Main results

* `level_eq_card_filter` — the level statistic counts the rotation points below `{(m+1)α}`.
* `fract_nat_mul_mem_Ioo` — for irrational `α` the orbit `{kα}`, `k ≥ 1`, meets every
  nonempty open subinterval of `(0,1)`.
* `exists_level_eq` — for irrational `α` every level `v ≤ L` is attained.
* `factorSet_ncard_eq` — **exact complexity**: `p(L) = L + 1` for irrational slope.
* `binomial_argmax_word_sturmian` — the statement transported back to the binomial
  argmax staircase.
-/
import Mathlib
import MachineLearning.SturmianArgmaxStaircase

namespace Shared
namespace SturmianArgmax

open Shared.UnimodalArgmaxBracketing

variable {α : ℝ}

/-! ## The level statistic as a counting function -/

/-- One coordinate of the profile as an indicator: `⌊x + y⌋ - ⌊y⌋ = 1` exactly when the
fractional part of `y` has reached the threshold `1 - x`. -/
theorem floor_add_sub_floor_eq_ite {x y : ℝ} (hx0 : 0 ≤ x) (hx1 : x < 1) :
    ⌊x + y⌋ - ⌊y⌋ = if 1 - Int.fract y ≤ x then 1 else 0 := by
  have hy : x + y = ((⌊y⌋ : ℤ) : ℝ) + (x + Int.fract y) := by
    simp only [Int.fract]; ring
  have hf0 : (0 : ℝ) ≤ Int.fract y := Int.fract_nonneg y
  have hf1 : Int.fract y < 1 := Int.fract_lt_one y
  rw [hy, Int.floor_intCast_add]
  by_cases h : 1 - Int.fract y ≤ x
  · rw [if_pos h]
    have : ⌊x + Int.fract y⌋ = 1 := by
      rw [Int.floor_eq_iff]
      constructor <;> push_cast <;> linarith
    omega
  · rw [if_neg h]
    push_neg at h
    have : ⌊x + Int.fract y⌋ = 0 :=
      Int.floor_eq_zero_iff.2 (Set.mem_Ico.2 ⟨by linarith, by linarith⟩)
    omega

/-- **The level statistic is a counting function**: `level α L m` counts the indices
`j ≤ L` whose rotation threshold `1 - {jα}` has been passed by `{(m+1)α}`. -/
theorem level_eq_card_filter (α : ℝ) (L m : ℕ) :
    level α L m = (((Finset.range (L + 1)).filter
      (fun j : ℕ => 1 - Int.fract ((j : ℝ) * α) ≤ Int.fract (((m : ℝ) + 1) * α))).card : ℤ) := by
  have hterm : ∀ j ∈ Finset.range (L + 1),
      pref α m j - ⌊(j : ℝ) * α⌋
        = if 1 - Int.fract ((j : ℝ) * α) ≤ Int.fract (((m : ℝ) + 1) * α) then (1 : ℤ) else 0 := by
    intro j _
    rw [pref_eq_floor_fract]
    exact floor_add_sub_floor_eq_ite (Int.fract_nonneg _) (Int.fract_lt_one _)
  rw [level, Finset.sum_congr rfl hterm]
  simp [Finset.sum_boole]

/-! ## A combinatorial lemma: every count is realised -/

/-- For a finite set `T` of reals inside `(0, b)` and any `v ≤ #T` there is a point
`x ∈ (0, b) \ T` with exactly `v` elements of `T` below it. -/
theorem exists_lt_filter_card_eq :
    ∀ n : ℕ, ∀ T : Finset ℝ, T.card = n → ∀ v : ℕ, v ≤ T.card → ∀ b : ℝ, 0 < b →
      (∀ t ∈ T, 0 < t ∧ t < b) →
      ∃ x : ℝ, 0 < x ∧ x < b ∧ x ∉ T ∧ (T.filter (fun t : ℝ => t ≤ x)).card = v := by
  intro n
  induction n with
  | zero =>
      intro T hT v hv b hb _
      have hTe : T = ∅ := Finset.card_eq_zero.1 hT
      subst hTe
      simp at hv
      subst hv
      exact ⟨b / 2, by linarith, by linarith, by simp, by simp⟩
  | succ n ih =>
      intro T hT v hv b hb hbd
      have hne : T.Nonempty := Finset.card_pos.1 (by omega)
      set M := T.max' hne with hM
      have hMmem : M ∈ T := T.max'_mem hne
      have hMb := hbd M hMmem
      rcases eq_or_lt_of_le hv with heq | hlt
      · refine ⟨(M + b) / 2, by linarith [hMb.1, hMb.2], by linarith [hMb.2], ?_, ?_⟩
        · intro hmem
          have := T.le_max' _ hmem
          linarith [hMb.2]
        · have hfil : T.filter (fun t : ℝ => t ≤ (M + b) / 2) = T := by
            refine Finset.filter_true_of_mem fun t ht => ?_
            have := T.le_max' t ht
            linarith [hMb.2]
          rw [hfil, ← heq]
      · have hcard' : (T.erase M).card = n := by
          rw [Finset.card_erase_of_mem hMmem, hT]
          omega
        have hbd' : ∀ t ∈ T.erase M, 0 < t ∧ t < M := by
          intro t ht
          have htT : t ∈ T := Finset.mem_of_mem_erase ht
          exact ⟨(hbd t htT).1, lt_of_le_of_ne (T.le_max' t htT) (Finset.ne_of_mem_erase ht)⟩
        obtain ⟨x, hx0, hxM, hxT', hxcard⟩ := ih (T.erase M) hcard' v (by omega) M hMb.1 hbd'
        refine ⟨x, hx0, by linarith [hMb.2], ?_, ?_⟩
        · intro hmem
          rcases eq_or_ne x M with rfl | hxne
          · exact absurd rfl (ne_of_lt hxM)
          · exact hxT' (Finset.mem_erase.2 ⟨hxne, hmem⟩)
        · have hins : T = insert M (T.erase M) := (Finset.insert_erase hMmem).symm
          rw [hins, Finset.filter_insert, if_neg (by linarith), hxcard]

/-! ## Density of the irrational rotation orbit -/

/-- **Density of the orbit of an irrational rotation.**  For irrational `α` and any
nonempty open subinterval `(a,b)` of `(0,1)` there is a positive integer `k` with
`{kα} ∈ (a,b)`. -/
theorem fract_nat_mul_mem_Ioo (hα : Irrational α) {a b : ℝ} (ha : 0 ≤ a) (hab : a < b)
    (hb : b ≤ 1) :
    ∃ k : ℕ, 0 < k ∧ a < Int.fract ((k : ℝ) * α) ∧ Int.fract ((k : ℝ) * α) < b := by
  set x : ℝ := (a + b) / 2 with hx
  set ε : ℝ := (b - a) / 2 with hε
  have hεpos : 0 < ε := by rw [hε]; linarith
  have hx0 : 0 < x := by rw [hx]; linarith
  have hx1 : x < 1 := by rw [hx]; linarith
  obtain ⟨N, hN⟩ := exists_nat_gt (max (1 / ε) (1 / x))
  have hNpos : 0 < N := by
    have h1 : (0 : ℝ) < 1 / ε := by positivity
    have : (0 : ℝ) < (N : ℝ) := lt_of_lt_of_le h1 (le_trans (le_max_left _ _) hN.le)
    exact_mod_cast this
  have hδε : 1 / ((N : ℝ) + 1) < ε := by
    have h1 : 1 / ε < (N : ℝ) := lt_of_le_of_lt (le_max_left _ _) hN
    rw [div_lt_iff₀ (by positivity)]
    rw [div_lt_iff₀ hεpos] at h1
    linarith
  have hδx : 1 / ((N : ℝ) + 1) < x := by
    have h1 : 1 / x < (N : ℝ) := lt_of_le_of_lt (le_max_right _ _) hN
    rw [div_lt_iff₀ (by positivity)]
    rw [div_lt_iff₀ hx0] at h1
    linarith
  obtain ⟨m, hm0, hmN, hle⟩ := Real.exists_nat_abs_mul_sub_round_le α hNpos
  set r : ℤ := round ((m : ℝ) * α) with hr
  set θ : ℝ := (m : ℝ) * α - (r : ℝ) with hθ
  have hθabs : |θ| ≤ 1 / ((N : ℝ) + 1) := hle
  have hirr : Irrational ((m : ℝ) * α) := hα.natCast_mul (by omega)
  have hθne : θ ≠ 0 := by
    intro h0
    have : ((m : ℝ) * α) = (r : ℝ) := by rw [hθ] at h0; linarith
    exact hirr.ne_int r this
  have hfr : ∀ j : ℕ, ((j * m : ℕ) : ℝ) * α = ((j * r : ℤ) : ℝ) + (j : ℝ) * θ := by
    intro j
    rw [hθ]
    push_cast
    ring
  rcases lt_or_gt_of_ne hθne with hneg | hpos
  · -- `θ < 0`: the orbit sweeps downwards from `1`
    set φ : ℝ := -θ with hφ
    have hφpos : 0 < φ := by rw [hφ]; linarith
    have hφδ : φ ≤ 1 / ((N : ℝ) + 1) := le_trans (by rw [hφ]; exact neg_le_abs θ) hθabs
    have hquot : 0 < (1 - x) / φ := div_pos (by linarith) hφpos
    set j : ℕ := ⌈(1 - x) / φ⌉₊ with hj
    have hjpos : 0 < j := by rw [hj, Nat.lt_ceil]; exact_mod_cast hquot
    have hjlow : 1 - x ≤ (j : ℝ) * φ := by
      have h := Nat.le_ceil ((1 - x) / φ)
      rw [← hj, div_le_iff₀ hφpos] at h
      linarith
    have hjhigh : (j : ℝ) * φ < (1 - x) + φ := by
      have h := Nat.ceil_lt_add_one hquot.le
      rw [← hj] at h
      have h2 := mul_lt_mul_of_pos_right h hφpos
      rw [add_mul, div_mul_cancel₀ _ (ne_of_gt hφpos), one_mul] at h2
      linarith
    have hjφ1 : (j : ℝ) * φ < 1 := by linarith
    have hjφ0 : 0 < (j : ℝ) * φ := by positivity
    have hself : Int.fract ((j : ℝ) * φ) = (j : ℝ) * φ := Int.fract_eq_self.2 ⟨hjφ0.le, hjφ1⟩
    have hval : Int.fract (((j * m : ℕ) : ℝ) * α) = 1 - (j : ℝ) * φ := by
      rw [hfr j, Int.fract_intCast_add,
        show (j : ℝ) * θ = -((j : ℝ) * φ) from by rw [hφ]; ring,
        Int.fract_neg (by rw [hself]; linarith), hself]
    exact ⟨j * m, by positivity, by rw [hval]; linarith, by rw [hval]; linarith⟩
  · -- `θ > 0`: the orbit sweeps upwards from `0`
    have hθδ : θ ≤ 1 / ((N : ℝ) + 1) := le_trans (le_abs_self θ) hθabs
    have hquot : 1 < x / θ := by
      rw [lt_div_iff₀ hpos]
      have : θ < x := lt_of_le_of_lt hθδ hδx
      linarith
    set j : ℕ := ⌊x / θ⌋₊ with hj
    have hjpos : 0 < j := by
      have h : (1 : ℕ) ≤ ⌊x / θ⌋₊ := Nat.le_floor (by exact_mod_cast hquot.le)
      omega
    have hjlow : (j : ℝ) * θ ≤ x := by
      have h := Nat.floor_le (by positivity : (0 : ℝ) ≤ x / θ)
      rw [← hj, le_div_iff₀ hpos] at h
      linarith
    have hjhigh : x < ((j : ℝ) + 1) * θ := by
      have h := Nat.lt_floor_add_one (x / θ)
      rw [← hj] at h
      have h2 := mul_lt_mul_of_pos_right h hpos
      rw [div_mul_cancel₀ _ (ne_of_gt hpos)] at h2
      linarith
    have hjθ0 : 0 < (j : ℝ) * θ := by positivity
    have hself : Int.fract ((j : ℝ) * θ) = (j : ℝ) * θ :=
      Int.fract_eq_self.2 ⟨hjθ0.le, by linarith⟩
    have hval : Int.fract (((j * m : ℕ) : ℝ) * α) = (j : ℝ) * θ := by
      rw [hfr j, Int.fract_intCast_add, hself]
    exact ⟨j * m, by positivity, by rw [hval]; nlinarith, by rw [hval]; linarith⟩

/-! ## All levels are attained -/

/-- For irrational `α` the thresholds `1 - {jα}`, `1 ≤ j ≤ L`, are pairwise distinct
points of `(0,1)`. -/
theorem fract_nat_mul_injective (hα : Irrational α) :
    Function.Injective (fun j : ℕ => Int.fract ((j : ℝ) * α)) := by
  intro a b hab
  by_contra hne
  have hd : ((a : ℤ) - (b : ℤ)) ≠ 0 := by
    simp only [ne_eq, sub_eq_zero, Nat.cast_inj]
    exact hne
  have hirr : Irrational (((((a : ℤ) - (b : ℤ)) : ℤ) : ℝ) * α) := hα.intCast_mul hd
  refine hirr.ne_int (⌊(a : ℝ) * α⌋ - ⌊(b : ℝ) * α⌋) ?_
  have ha : Int.fract ((a : ℝ) * α) = (a : ℝ) * α - ((⌊(a : ℝ) * α⌋ : ℤ) : ℝ) := rfl
  have hb : Int.fract ((b : ℝ) * α) = (b : ℝ) * α - ((⌊(b : ℝ) * α⌋ : ℤ) : ℝ) := rfl
  simp only at hab
  rw [ha, hb] at hab
  have hexp : ((((a : ℤ) - (b : ℤ)) : ℤ) : ℝ) * α = (a : ℝ) * α - (b : ℝ) * α := by
    push_cast
    ring
  rw [hexp]
  push_cast
  linarith

/-- **Every level is attained.**  For irrational slope and every `v ≤ L` there is a
position of the staircase whose window of length `L` has level `v`. -/
theorem exists_level_eq (hα : Irrational α) (L : ℕ) {v : ℕ} (hv : v ≤ L) :
    ∃ m : ℕ, level α L m = (v : ℤ) := by
  classical
  set t : ℕ → ℝ := fun j => 1 - Int.fract ((j : ℝ) * α) with ht
  set T : Finset ℝ := (Finset.Icc 1 L).image t with hT
  have hfr_pos : ∀ j : ℕ, 1 ≤ j → 0 < Int.fract ((j : ℝ) * α) := by
    intro j hj
    rcases lt_or_eq_of_le (Int.fract_nonneg ((j : ℝ) * α)) with h | h
    · exact h
    · exfalso
      have hirr : Irrational ((j : ℝ) * α) := hα.natCast_mul (by omega)
      refine hirr.ne_int ⌊(j : ℝ) * α⌋ ?_
      have hfl : Int.fract ((j : ℝ) * α) = (j : ℝ) * α - ((⌊(j : ℝ) * α⌋ : ℤ) : ℝ) := rfl
      rw [hfl] at h
      linarith
  have hTbd : ∀ s ∈ T, 0 < s ∧ s < 1 := by
    intro s hs
    rw [hT, Finset.mem_image] at hs
    obtain ⟨j, hj, rfl⟩ := hs
    have hj1 : 1 ≤ j := (Finset.mem_Icc.1 hj).1
    have h1 : Int.fract ((j : ℝ) * α) < 1 := Int.fract_lt_one _
    have h0 := hfr_pos j hj1
    exact ⟨by simp only [ht]; linarith, by simp only [ht]; linarith⟩
  have hinj : Set.InjOn t ↑(Finset.Icc 1 L) := by
    intro a _ b _ hab
    have : Int.fract ((a : ℝ) * α) = Int.fract ((b : ℝ) * α) := by
      simp only [ht] at hab
      linarith
    exact fract_nat_mul_injective hα this
  have hTcard : T.card = L := by
    rw [hT, Finset.card_image_of_injOn hinj, Nat.card_Icc]
    omega
  obtain ⟨x, hx0, hx1, hxT, hxcard⟩ :=
    exists_lt_filter_card_eq T.card T rfl v (by omega) 1 one_pos hTbd
  obtain ⟨η, hηpos, hηsep⟩ : ∃ η : ℝ, 0 < η ∧ ∀ s ∈ T, η ≤ |s - x| := by
    rcases T.eq_empty_or_nonempty with hTe | hTne
    · exact ⟨1, one_pos, by simp [hTe]⟩
    · obtain ⟨s0, hs0, hmin⟩ := Finset.exists_min_image T (fun s => |s - x|) hTne
      refine ⟨|s0 - x|, ?_, hmin⟩
      rw [abs_pos, sub_ne_zero]
      intro h
      exact hxT (h ▸ hs0)
  obtain ⟨k, hk0, hka, hkb⟩ :=
    fract_nat_mul_mem_Ioo hα (a := max 0 (x - η)) (b := min 1 (x + η)) (le_max_left _ _)
      (lt_min (max_lt (by linarith : (0 : ℝ) < 1) (by linarith : x - η < 1))
        (max_lt (by linarith : (0 : ℝ) < x + η) (by linarith : x - η < x + η)))
      (min_le_left _ _)
  set y : ℝ := Int.fract ((k : ℝ) * α) with hy
  have hylt : y < 1 := lt_of_lt_of_le hkb (min_le_left _ _)
  have hyx : |y - x| < η := by
    have h1 : x - η < y := lt_of_le_of_lt (le_max_right _ _) hka
    have h2 : y < x + η := lt_of_lt_of_le hkb (min_le_right _ _)
    rw [abs_lt]
    exact ⟨by linarith, by linarith⟩
  have hswap : ∀ s ∈ T, (s ≤ y ↔ s ≤ x) := by
    intro s hs
    have hsep := hηsep s hs
    rw [abs_lt] at hyx
    constructor
    · intro h
      by_contra hcon
      push_neg at hcon
      rw [abs_of_nonneg (by linarith : (0:ℝ) ≤ s - x)] at hsep
      linarith
    · intro h
      by_contra hcon
      push_neg at hcon
      rw [abs_of_nonpos (by linarith : s - x ≤ 0)] at hsep
      linarith
  have hcount : ∀ z : ℝ, z < 1 →
      ((Finset.range (L + 1)).filter (fun j : ℕ => t j ≤ z)).card
        = (T.filter (fun s : ℝ => s ≤ z)).card := by
    intro z hz
    have h1 : (Finset.range (L + 1)).filter (fun j : ℕ => t j ≤ z)
        = (Finset.Icc 1 L).filter (fun j : ℕ => t j ≤ z) := by
      ext j
      simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Icc]
      constructor
      · rintro ⟨hj, hle⟩
        refine ⟨⟨?_, by omega⟩, hle⟩
        rcases Nat.eq_zero_or_pos j with rfl | hpos
        · exfalso
          simp only [ht, Nat.cast_zero, zero_mul, Int.fract_zero, sub_zero] at hle
          linarith
        · omega
      · rintro ⟨⟨hj1, hj2⟩, hle⟩
        exact ⟨by omega, hle⟩
    have hsub : Set.InjOn t ↑((Finset.Icc 1 L).filter (fun j : ℕ => t j ≤ z)) := by
      refine hinj.mono ?_
      intro a ha
      simp only [Finset.coe_filter, Set.mem_setOf_eq] at ha
      exact Finset.mem_coe.2 ha.1
    rw [h1, hT, Finset.filter_image, Finset.card_image_of_injOn hsub]
  refine ⟨k - 1, ?_⟩
  have hk1 : (((k - 1 : ℕ) : ℝ) + 1) = (k : ℝ) := by
    have h1 : (1 : ℕ) ≤ k := hk0
    have : ((k - 1 : ℕ) : ℝ) = (k : ℝ) - 1 := by
      rw [Nat.cast_sub h1]
      norm_num
    rw [this]
    ring
  rw [level_eq_card_filter, hk1, ← hy]
  have hfin : ((Finset.range (L + 1)).filter (fun j : ℕ => t j ≤ y)).card = v := by
    rw [hcount y hylt, Finset.filter_congr (fun s hs => by
      simpa using (hswap s hs))]
    exact hxcard
  simpa only [ht] using congrArg (fun n : ℕ => (n : ℤ)) hfin

/-! ## Exact complexity -/

theorem level_eq_of_factor_eq {α : ℝ} {L m m' : ℕ} (h : factor α m L = factor α m' L) :
    level α L m = level α L m' := by
  rw [level, level]
  refine Finset.sum_congr rfl fun j hj => ?_
  have hjL : j ≤ L := by simpa [Nat.lt_succ_iff] using Finset.mem_range.1 hj
  rw [← factor_partial_sum m hjL, ← factor_partial_sum m' hjL, h]

theorem factor_eq_of_level_eq {α : ℝ} {L m m' : ℕ} (h : level α L m = level α L m') :
    factor α m L = factor α m' L := by
  funext s
  by_cases hs : s < L
  · simp only [factor, if_pos hs]
    exact incWord_eq_of_level_eq h hs
  · simp [factor, hs]

/-- **Complexity from level attainment.**  If every level `v ≤ L` occurs, then the word
has exactly `L + 1` factors of length `L`. -/
theorem factorSet_ncard_eq_of_levels_attained {α : ℝ} {L : ℕ}
    (hatt : ∀ v : ℕ, v ≤ L → ∃ m : ℕ, level α L m = (v : ℤ)) :
    {w : ℕ → ℤ | ∃ m, w = factor α m L}.ncard = L + 1 := by
  classical
  choose mv hmv using fun v : Fin (L + 1) => hatt (v : ℕ) (Nat.lt_succ_iff.1 v.isLt)
  have hSeq : {w : ℕ → ℤ | ∃ m, w = factor α m L}
      = Set.range (fun v : Fin (L + 1) => factor α (mv v) L) := by
    ext w
    constructor
    · rintro ⟨m, rfl⟩
      have hb1 := level_nonneg α L m
      have hb2 := level_le α L m
      refine ⟨⟨(level α L m).toNat, by omega⟩, ?_⟩
      refine factor_eq_of_level_eq ?_
      rw [hmv ⟨(level α L m).toNat, by omega⟩]
      simp only [Int.toNat_of_nonneg hb1]
    · rintro ⟨v, rfl⟩
      exact ⟨mv v, rfl⟩
  have hinj : Function.Injective (fun v : Fin (L + 1) => factor α (mv v) L) := by
    intro v w hvw
    have := level_eq_of_factor_eq hvw
    rw [hmv v, hmv w] at this
    exact Fin.ext (by exact_mod_cast this)
  rw [hSeq, ← Set.image_univ, Set.ncard_image_of_injective _ hinj, Set.ncard_univ]
  simp

/-- **Exact subword complexity.**  For irrational slope the increment word of the argmax
staircase has exactly `L + 1` factors of length `L`: it is a Sturmian word. -/
theorem factorSet_ncard_eq (hα : Irrational α) (L : ℕ) :
    {w : ℕ → ℤ | ∃ m, w = factor α m L}.ncard = L + 1 :=
  factorSet_ncard_eq_of_levels_attained (fun _ hv => exists_level_eq hα L hv)

/-! ## Back to the binomial peaks -/

/-- **The argmax word of the binomial weights is Sturmian.**  For weights `p, q > 0`
whose slope `α = p/(p+q)` is irrational, the largest maximiser of row `n` is `⌊(n+1)α⌋`,
and the increment word of this staircase is balanced with exactly `L + 1` factors of each
length `L` — the defining combinatorics of a Sturmian word / circle rotation. -/
theorem binomial_argmax_word_sturmian {p q : ℝ} (hp : 0 < p) (hq : 0 < q)
    (hirr : Irrational (slope p q)) (L : ℕ) :
    (∀ n : ℕ, lastArgmax n (binomialWeight n p q) = (staircase (slope p q) n).toNat) ∧
      (∀ m m' : ℕ, |windowSum (slope p q) m L - windowSum (slope p q) m' L| ≤ 1) ∧
      {w : ℕ → ℤ | ∃ m, w = factor (slope p q) m L}.ncard = L + 1 :=
  ⟨fun _ => lastArgmax_eq_staircase hp hq,
    fun m m' => staircase_balanced (slope p q) m m' L,
    factorSet_ncard_eq hirr L⟩

/-- A concrete irrational slope: `√2 / (√2 + 1) = 2 - √2`. -/
theorem slope_sqrt_two_irrational : Irrational (slope (Real.sqrt 2) 1) := by
  have h2 : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
  have hs : Real.sqrt 2 + 1 ≠ 0 := by positivity
  have heq : slope (Real.sqrt 2) 1 = 2 - Real.sqrt 2 := by
    rw [slope]
    field_simp
    nlinarith [h2]
  rw [heq]
  simpa [sub_eq_add_neg] using irrational_sqrt_two.neg.intCast_add 2

/-- **A concrete Sturmian binomial peak word.**  For the weights `p = √2`, `q = 1` the
argmax staircase of the binomial weights is `⌊(n+1)(2 - √2)⌋` and its increment word has
exactly `L + 1` factors of length `L` for every `L`. -/
theorem binomial_argmax_word_sturmian_sqrt_two (L : ℕ) :
    (∀ n : ℕ, lastArgmax n (binomialWeight n (Real.sqrt 2) 1)
        = (staircase (slope (Real.sqrt 2) 1) n).toNat) ∧
      {w : ℕ → ℤ | ∃ m, w = factor (slope (Real.sqrt 2) 1) m L}.ncard = L + 1 := by
  have hp : (0 : ℝ) < Real.sqrt 2 := Real.sqrt_pos.2 (by norm_num)
  obtain ⟨h1, _, h3⟩ := binomial_argmax_word_sturmian hp one_pos slope_sqrt_two_irrational L
  exact ⟨h1, h3⟩

end SturmianArgmax
end Shared