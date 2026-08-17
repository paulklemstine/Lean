import Geometry.TaxicabCubicReps

/-!
# Unconditional witnesses: numbers with 3, 4, 5 and 6 cube representations

The scaling map of `Geometry.TaxicabCubicReps` multiplies a representation set by a cube
but never creates new representations (and `cube_core_conjecture_false` shows it is not
count-preserving in the other direction either). Genuine growth of the representation
count therefore has to be exhibited. Here we certify, unconditionally and by explicit
lattice points on the affine cubics, that a number with `n` representations exists for
`n ≤ 6`, and we combine these witnesses with the scaling injection to produce *infinitely
many* integers with `6` representations.

Finally `taxicab_six_bracket` contrasts the elementary shell bound `64 (n-1)³` with the
smallest known witness for `n = 6`: `13750` versus `2.4 · 10²²`. That gap of eighteen orders
of magnitude is the quantitative motivation for a super-polynomial growth conjecture.
-/

namespace Taxicab

open Finset

-- The witnesses below live on cubics of size up to `2.4 · 10²²`; unfolding the definition
-- of `cubeReps` (a filter over a box of that size) is never useful here and would make the
-- elaborator attempt an astronomically large computation.
attribute [local irreducible] Taxicab.cubeReps

/-! ### Generic cardinality helpers

These are stated for an abstract `Finset`, which also keeps the elaborator from trying to
evaluate the (astronomically large) index boxes of `cubeReps N` at the call sites. -/

private theorem card_ge_three {α : Type*} [DecidableEq α] {s : Finset α} {a b c : α}
    (ha : a ∈ s) (hb : b ∈ s) (hc : c ∈ s) (h : ({a, b, c} : Finset α).card = 3) :
    3 ≤ s.card := by
  have hsub : ({a, b, c} : Finset α) ⊆ s := by
    simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
    exact ⟨ha, hb, hc⟩
  rw [← h]
  exact Finset.card_le_card hsub

private theorem card_ge_four {α : Type*} [DecidableEq α] {s : Finset α} {a b c d : α}
    (ha : a ∈ s) (hb : b ∈ s) (hc : c ∈ s) (hd : d ∈ s)
    (h : ({a, b, c, d} : Finset α).card = 4) : 4 ≤ s.card := by
  have hsub : ({a, b, c, d} : Finset α) ⊆ s := by
    simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
    exact ⟨ha, hb, hc, hd⟩
  rw [← h]
  exact Finset.card_le_card hsub

private theorem card_ge_five {α : Type*} [DecidableEq α] {s : Finset α} {a b c d e : α}
    (ha : a ∈ s) (hb : b ∈ s) (hc : c ∈ s) (hd : d ∈ s) (he : e ∈ s)
    (h : ({a, b, c, d, e} : Finset α).card = 5) : 5 ≤ s.card := by
  have hsub : ({a, b, c, d, e} : Finset α) ⊆ s := by
    simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
    exact ⟨ha, hb, hc, hd, he⟩
  rw [← h]
  exact Finset.card_le_card hsub

private theorem card_ge_six {α : Type*} [DecidableEq α] {s : Finset α} {a b c d e f : α}
    (ha : a ∈ s) (hb : b ∈ s) (hc : c ∈ s) (hd : d ∈ s) (he : e ∈ s) (hf : f ∈ s)
    (h : ({a, b, c, d, e, f} : Finset α).card = 6) : 6 ≤ s.card := by
  have hsub : ({a, b, c, d, e, f} : Finset α) ⊆ s := by
    simp only [Finset.insert_subset_iff, Finset.singleton_subset_iff]
    exact ⟨ha, hb, hc, hd, he, hf⟩
  rw [← h]
  exact Finset.card_le_card hsub

/-! ### `Taxicab 3` -/

theorem mem_87539319_a : ((167, 436) : ℕ × ℕ) ∈ cubeReps 87539319 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_87539319_b : ((228, 423) : ℕ × ℕ) ∈ cubeReps 87539319 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_87539319_c : ((255, 414) : ℕ × ℕ) ∈ cubeReps 87539319 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

/-- `87539319 = 167³ + 436³ = 228³ + 423³ = 255³ + 414³`. -/
theorem three_reps_87539319 : 3 ≤ (cubeReps 87539319).card :=
  card_ge_three mem_87539319_a mem_87539319_b mem_87539319_c (by norm_num)

/-! ### `Taxicab 4` -/

theorem mem_6963472309248_a : ((2421, 19083) : ℕ × ℕ) ∈ cubeReps 6963472309248 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_6963472309248_b : ((5436, 18948) : ℕ × ℕ) ∈ cubeReps 6963472309248 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_6963472309248_c : ((10200, 18072) : ℕ × ℕ) ∈ cubeReps 6963472309248 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_6963472309248_d : ((13322, 16630) : ℕ × ℕ) ∈ cubeReps 6963472309248 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

/-- `6963472309248 = 2421³ + 19083³ = 5436³ + 18948³ = 10200³ + 18072³ = 13322³ + 16630³`. -/
theorem four_reps_6963472309248 : 4 ≤ (cubeReps 6963472309248).card :=
  card_ge_four mem_6963472309248_a mem_6963472309248_b mem_6963472309248_c
    mem_6963472309248_d (by norm_num)

/-! ### `Taxicab 5` -/

theorem mem_48988659276962496_a :
    ((38787, 365757) : ℕ × ℕ) ∈ cubeReps 48988659276962496 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_48988659276962496_b :
    ((107839, 362753) : ℕ × ℕ) ∈ cubeReps 48988659276962496 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_48988659276962496_c :
    ((205292, 342952) : ℕ × ℕ) ∈ cubeReps 48988659276962496 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_48988659276962496_d :
    ((221424, 336588) : ℕ × ℕ) ∈ cubeReps 48988659276962496 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_48988659276962496_e :
    ((231518, 331954) : ℕ × ℕ) ∈ cubeReps 48988659276962496 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

/-- `48988659276962496` is a sum of two positive cubes in five ways. -/
theorem five_reps_48988659276962496 : 5 ≤ (cubeReps 48988659276962496).card :=
  card_ge_five mem_48988659276962496_a mem_48988659276962496_b mem_48988659276962496_c
    mem_48988659276962496_d mem_48988659276962496_e (by norm_num)

/-! ### `Taxicab 6` -/

theorem mem_24153319581254312065344_a :
    ((582162, 28906206) : ℕ × ℕ) ∈ cubeReps 24153319581254312065344 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_24153319581254312065344_b :
    ((3064173, 28894803) : ℕ × ℕ) ∈ cubeReps 24153319581254312065344 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_24153319581254312065344_c :
    ((8519281, 28657487) : ℕ × ℕ) ∈ cubeReps 24153319581254312065344 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_24153319581254312065344_d :
    ((16218068, 27093208) : ℕ × ℕ) ∈ cubeReps 24153319581254312065344 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_24153319581254312065344_e :
    ((17492496, 26590452) : ℕ × ℕ) ∈ cubeReps 24153319581254312065344 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

theorem mem_24153319581254312065344_f :
    ((18289922, 26224366) : ℕ × ℕ) ∈ cubeReps 24153319581254312065344 := by
  rw [mem_cubeReps]; exact ⟨by norm_num, by norm_num, by norm_num⟩

/-- `24153319581254312065344` is a sum of two positive cubes in six ways. -/
theorem six_reps_24153319581254312065344 :
    6 ≤ (cubeReps 24153319581254312065344).card :=
  card_ge_six mem_24153319581254312065344_a mem_24153319581254312065344_b
    mem_24153319581254312065344_c mem_24153319581254312065344_d
    mem_24153319581254312065344_e mem_24153319581254312065344_f (by norm_num)

/-! ### Consequences -/

/-- Combining the witnesses with the cube-scaling injection: infinitely many integers have
at least six representations as a sum of two positive cubes. -/
theorem six_reps_infinitely_many (m : ℕ) (hm : 0 < m) :
    6 ≤ (cubeReps (m ^ 3 * 24153319581254312065344)).card :=
  le_trans six_reps_24153319581254312065344 (cubeReps_card_le_scaled hm)

/-- The family above is unbounded: beyond every bound there is a number with six
representations. -/
theorem six_reps_unbounded (B : ℕ) : ∃ N, B < N ∧ 6 ≤ (cubeReps N).card := by
  refine ⟨(B + 1) ^ 3 * 24153319581254312065344, ?_,
    six_reps_infinitely_many (B + 1) (by omega)⟩
  have h1 : B + 1 ≤ (B + 1) ^ 3 := Nat.le_self_pow (by norm_num) _
  have h2 : (B + 1) ^ 3 * 1 ≤ (B + 1) ^ 3 * 24153319581254312065344 :=
    Nat.mul_le_mul_left _ (by norm_num)
  omega

/-- **Bracketing the least number with six representations.** Every such number exceeds
`13750` (the elementary shell bound), while `24153319581254312065344` realises six
representations: the elementary floor is eighteen orders of magnitude below the witness. -/
theorem taxicab_six_bracket :
    (∀ N : ℕ, 6 ≤ (cubeReps N).card → 13750 ≤ N) ∧
      6 ≤ (cubeReps 24153319581254312065344).card := by
  refine ⟨fun N h => ?_, six_reps_24153319581254312065344⟩
  have hb := cubeReps_card_growth N 6 h
  norm_num at hb
  omega

end Taxicab