import Mathlib
import Novelty.IndependenceRatioChromatic
import Novelty.IndependenceRatioLowerBound
import Novelty.OneSumEqualityAnalysis
import Novelty.OneSumStarAmalgam

/-!
# The threshold family: `m`-fold amalgams of `K₈ - e` and the collapse of the ratio to `1/7`

`Novelty.OneSumStarAmalgam` proved that an `m`-fold star amalgam obeys the sharp bound
`i(G) ≥ r - (m-1)(1-r)/n` when all sides carry independent sets of relative density `r`.
This file exhibits the extremal family for `r = 1/4`, thereby showing that the defect term is
optimal for **every** `m`, and that iterated 1-sums of graphs sitting exactly on the
threshold `i = 1/4` drive the independence ratio all the way down to `1/7`.

`StarK8 m` is the amalgam of `m` copies of `K₈` minus an edge, all glued at one vertex `0`:
the vertex set is `Fin (7m+1)`, block `b` is `{7b+1, …, 7b+7}`, block `b` together with `0`
spans a `K₈` minus the edge `{0, 7b+1}`.

Main results.

* `SimpleGraph.StarFamily.starIndepNum` — `α(StarK8 m) = m + 1`;
* `SimpleGraph.StarFamily.starIndepRatio` — `i(StarK8 m) = (m+1)/(7m+1)`;
* `SimpleGraph.StarFamily.star_isStarSum` — `StarK8 m` really is an `m`-fold star amalgam;
* `SimpleGraph.StarFamily.side_card` and `SimpleGraph.StarFamily.side_indepSet_card` — every
  side has `8` vertices and carries an independent pair, i.e. relative density exactly `1/4`;
* `SimpleGraph.StarFamily.starIndepRatio_eq_defect_bound` — the `m`-fold defect bound of the
  companion file is attained with equality for every `m`;
* `SimpleGraph.StarFamily.starIndepRatio_sub_seventh` — the exact identity
  `i(StarK8 m) - 1/7 = 6/(7(7m+1))`, whence
* `SimpleGraph.StarFamily.exists_indepRatio_lt` — for every `ε > 0` some amalgam of threshold
  graphs has independence ratio below `1/7 + ε`, and
  `SimpleGraph.StarFamily.starIndepRatio_lt_quarter` — every amalgam with `m ≥ 2` parts is
  already below `1/4`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): iterating the two-part counterexample should be *cumulative*, not
merely repeatable: with `m` parts the ratio should be `(m+1)/(7m+1)`, decreasing to `1/7`.
Experiment (Experimenter): `α = m + 1` because an independent set meets each block in at most
one vertex (blocks are cliques) and may in addition contain the cut vertex; the extremal set
is `{0} ∪ {7b+1 : b < m}`, the cut vertex together with the non-neighbour in each block.
Numerically: `m = 1 : 2/8 = 1/4`, `m = 2 : 3/15 = 1/5`, `m = 3 : 4/22 = 2/11`,
`m = 10 : 11/71`, limit `1/7 ≈ 0.1428…`.
Analysis (Analyst): the identity `i - 1/7 = 6/(7(7m+1))` shows the convergence is exactly of
order `1/n`, i.e. the entire deficiency is carried by the single shared vertex.
Critique (Critic): `1/7` is *not* attained; the family is strictly above it for every finite
`m`, so the statement is an infimum statement, formalised as an explicit `ε`-approximation
rather than as an unattained minimum.
Synthesis (PI): "threshold" hypotheses of the form `i ≥ c` are never closed under
amalgamation; the only stable formulation is the colouring one.
-- !-- end Lab Notes -- !--
-/

open Finset

namespace SimpleGraph

namespace StarFamily

variable {m : ℕ}

/-- Adjacency of the `m`-fold amalgam of `K₈ - e`: blocks of seven vertices, each block
completed to a `K₈` by the cut vertex `0`, which misses the first vertex of each block. -/
def starAdj (m : ℕ) (x y : Fin (7 * m + 1)) : Prop :=
  x ≠ y ∧
    ((1 ≤ x.val ∧ 1 ≤ y.val ∧ (x.val - 1) / 7 = (y.val - 1) / 7) ∨
      (x.val = 0 ∧ 1 ≤ y.val ∧ (y.val - 1) % 7 ≠ 0) ∨
      (y.val = 0 ∧ 1 ≤ x.val ∧ (x.val - 1) % 7 ≠ 0))

/-- The `m`-fold amalgam of `K₈` minus an edge. -/
def StarK8 (m : ℕ) : SimpleGraph (Fin (7 * m + 1)) where
  Adj := starAdj m
  symm := by
    rintro x y ⟨hne, hc | hc | hc⟩
    · exact ⟨hne.symm, Or.inl ⟨hc.2.1, hc.1, hc.2.2.symm⟩⟩
    · exact ⟨hne.symm, Or.inr (Or.inr ⟨hc.1, hc.2.1, hc.2.2⟩)⟩
    · exact ⟨hne.symm, Or.inr (Or.inl ⟨hc.1, hc.2.1, hc.2.2⟩)⟩
  loopless := ⟨fun _ hx => hx.1 rfl⟩

theorem val_eq_zero_iff (x : Fin (7 * m + 1)) : x.val = 0 ↔ x = 0 := by
  constructor
  · intro h; exact Fin.ext (by simpa using h)
  · intro h; simp [h]

/-- Two distinct vertices in the same block are adjacent. -/
theorem adj_of_same_block {x y : Fin (7 * m + 1)} (hx : 1 ≤ x.val) (hy : 1 ≤ y.val)
    (hb : (x.val - 1) / 7 = (y.val - 1) / 7) (hne : x ≠ y) : (StarK8 m).Adj x y :=
  ⟨hne, Or.inl ⟨hx, hy, hb⟩⟩

/-- **The independence number of the `m`-fold amalgam is at most `m + 1`**: an independent set
meets every block at most once. -/
theorem card_le_of_indepSet {S : Finset (Fin (7 * m + 1))} (hS : (StarK8 m).IsIndepSet ↑S) :
    S.card ≤ m + 1 := by
  classical
  have hmap : ∀ x ∈ S.erase 0, (x.val - 1) / 7 ∈ Finset.range m := by
    intro x hx
    have hx0 : x ≠ 0 := Finset.ne_of_mem_erase hx
    have hv : 1 ≤ x.val := by
      by_contra hcon
      exact hx0 ((val_eq_zero_iff x).1 (by omega))
    have hlt := x.isLt
    simp only [Finset.mem_range]
    omega
  have hinj : Set.InjOn (fun x : Fin (7 * m + 1) => (x.val - 1) / 7) (S.erase 0) := by
    intro x hx y hy hxy
    simp only [Finset.coe_erase, Set.mem_diff, Finset.mem_coe, Set.mem_singleton_iff] at hx hy
    by_contra hne
    have hxv : 1 ≤ x.val := by
      by_contra hcon
      exact hx.2 ((val_eq_zero_iff x).1 (by omega))
    have hyv : 1 ≤ y.val := by
      by_contra hcon
      exact hy.2 ((val_eq_zero_iff y).1 (by omega))
    exact hS (Finset.mem_coe.2 hx.1) (Finset.mem_coe.2 hy.1) hne
      (adj_of_same_block hxv hyv hxy hne)
  have hcard := Finset.card_le_card_of_injOn (fun x : Fin (7 * m + 1) => (x.val - 1) / 7)
    (fun x hx => Finset.mem_coe.2 (hmap x (Finset.mem_coe.1 hx))) hinj
  rw [Finset.card_range] at hcard
  have hle : S.card ≤ (S.erase 0).card + 1 := by
    by_cases h0 : (0 : Fin (7 * m + 1)) ∈ S
    · rw [Finset.card_erase_of_mem h0]
      have : 1 ≤ S.card := Finset.card_pos.2 ⟨0, h0⟩
      omega
    · rw [Finset.erase_eq_of_notMem h0]; omega
  omega

/-- The extremal independent set: the cut vertex together with the first vertex of each block. -/
def maxIndep (m : ℕ) : Finset (Fin (7 * m + 1)) :=
  insert 0 ((Finset.univ : Finset (Fin m)).image
    (fun b => (⟨7 * b.val + 1, by have := b.isLt; omega⟩ : Fin (7 * m + 1))))

theorem maxIndep_card : (maxIndep m).card = m + 1 := by
  classical
  have hinj : Function.Injective
      (fun b : Fin m => (⟨7 * b.val + 1, by have := b.isLt; omega⟩ : Fin (7 * m + 1))) := by
    intro a b hab
    have : 7 * a.val + 1 = 7 * b.val + 1 := congrArg Fin.val hab
    exact Fin.ext (by omega)
  have hnot : (0 : Fin (7 * m + 1)) ∉ (Finset.univ : Finset (Fin m)).image
      (fun b => (⟨7 * b.val + 1, by have := b.isLt; omega⟩ : Fin (7 * m + 1))) := by
    simp only [Finset.mem_image, Finset.mem_univ, true_and, not_exists]
    intro b hb
    have : (0 : Fin (7 * m + 1)).val = 7 * b.val + 1 := congrArg Fin.val hb.symm
    simp at this
  rw [maxIndep, Finset.card_insert_of_notMem hnot,
    Finset.card_image_of_injective _ hinj, Finset.card_univ, Fintype.card_fin]

theorem maxIndep_isIndepSet : (StarK8 m).IsIndepSet ↑(maxIndep m) := by
  classical
  intro x hx y hy hne hadj
  simp only [maxIndep, Finset.coe_insert, Set.mem_insert_iff, Finset.coe_image,
    Finset.coe_univ, Set.image_univ, Set.mem_range] at hx hy
  obtain ⟨hxne, hcases⟩ := hadj
  rcases hx with rfl | ⟨a, rfl⟩ <;> rcases hy with rfl | ⟨b, rfl⟩
  · exact hne rfl
  · rcases hcases with hc | hc | hc
    · simp at hc
    · exact hc.2.2 (by simp [Nat.mul_mod_right])
    · simp at hc
  · rcases hcases with hc | hc | hc
    · simp at hc
    · simp at hc
    · exact hc.2.2 (by simp [Nat.mul_mod_right])
  · rcases hcases with hc | hc | hc
    · have hb : a.val = b.val := by
        have h : (7 * a.val + 1 - 1) / 7 = (7 * b.val + 1 - 1) / 7 := hc.2.2
        omega
      exact hne (by rw [Fin.mk.injEq]; omega)
    · have h0 : 7 * a.val + 1 = 0 := hc.1
      omega
    · have h0 : 7 * b.val + 1 = 0 := hc.1
      omega

/-- **The independence number of the `m`-fold amalgam is exactly `m + 1`.** -/
theorem starIndepNum : (StarK8 m).indepNum = m + 1 := by
  classical
  refine le_antisymm ?_ ?_
  · obtain ⟨S, hS, hcard⟩ := (StarK8 m).exists_isNIndepSet_indepNum
    exact hcard ▸ card_le_of_indepSet hS
  · have := maxIndep_isIndepSet (m := m) |>.card_le_indepNum
    rwa [maxIndep_card] at this

/-- **The independence ratio of the `m`-fold amalgam.** -/
theorem starIndepRatio : (StarK8 m).indepRatio = ((m : ℚ) + 1) / (7 * (m : ℚ) + 1) := by
  rw [SimpleGraph.indepRatio, starIndepNum]
  simp only [Fintype.card_fin]
  push_cast
  ring

/-- **The exact distance to `1/7`.**  The whole deficiency of the amalgam is carried by the
single shared vertex, and it decays like `1/n`. -/
theorem starIndepRatio_sub_seventh :
    (StarK8 m).indepRatio - (1 : ℚ) / 7 = 6 / (7 * (7 * (m : ℚ) + 1)) := by
  rw [starIndepRatio]
  have h7 : (7 : ℚ) * (m : ℚ) + 1 ≠ 0 := by positivity
  field_simp
  ring

/-- Every amalgam with at least two parts is strictly below the threshold `1/4`. -/
theorem starIndepRatio_lt_quarter (hm : 2 ≤ m) : (StarK8 m).indepRatio < (1 : ℚ) / 4 := by
  rw [starIndepRatio]
  have hm' : (2 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
  rw [div_lt_div_iff₀ (by positivity) (by norm_num)]
  linarith

/-- **Approximation of the infimum `1/7`.**  For every `ε > 0` there is an amalgam of
threshold graphs whose independence ratio is below `1/7 + ε`. -/
theorem exists_indepRatio_lt {ε : ℚ} (hε : 0 < ε) :
    ∃ m : ℕ, (StarK8 m).indepRatio < (1 : ℚ) / 7 + ε := by
  obtain ⟨m, hm⟩ := exists_nat_gt (6 / ε)
  refine ⟨m, ?_⟩
  have hmq : (0 : ℚ) ≤ (m : ℚ) := Nat.cast_nonneg m
  have hkey := starIndepRatio_sub_seventh (m := m)
  have hpos : (0 : ℚ) < 7 * (7 * (m : ℚ) + 1) := by positivity
  have hlt : 6 / (7 * (7 * (m : ℚ) + 1)) < ε := by
    rw [div_lt_iff₀ hpos]
    have h6 : 6 / ε < (m : ℚ) := hm
    have : 6 < ε * (m : ℚ) := by
      rw [div_lt_iff₀ hε] at h6
      linarith
    nlinarith
  linarith

section StarSum

variable (m)

/-- The `b`-th side: the cut vertex together with the `b`-th block. -/
def side (b : Fin m) : Set (Fin (7 * m + 1)) :=
  {x | x.val = 0 ∨ (1 ≤ x.val ∧ (x.val - 1) / 7 = b.val)}

/-- The `b`-th part: the edges of the amalgam inside the `b`-th side. -/
def part (b : Fin m) : SimpleGraph (Fin (7 * m + 1)) where
  Adj x y := (StarK8 m).Adj x y ∧ x ∈ side m b ∧ y ∈ side m b
  symm := by
    rintro x y ⟨hadj, hx, hy⟩
    exact ⟨hadj.symm, hy, hx⟩
  loopless := ⟨fun _ hx => hx.1.ne rfl⟩

variable {m}

theorem mem_side_zero (b : Fin m) : (0 : Fin (7 * m + 1)) ∈ side m b := Or.inl (by simp)

/-- **The amalgam is a star sum of its `m` parts.** -/
theorem star_isStarSum [NeZero m] : (StarK8 m).IsStarSum (part m) (side m) 0 where
  sup_eq := by
    ext x y
    simp only [SimpleGraph.iSup_adj]
    constructor
    · intro hadj
      obtain ⟨hne, hc | hc | hc⟩ := hadj
      · have hlt := x.isLt
        have hb : (x.val - 1) / 7 < m := by omega
        refine ⟨⟨(x.val - 1) / 7, hb⟩, ⟨hne, Or.inl hc⟩, Or.inr ⟨hc.1, rfl⟩,
          Or.inr ⟨hc.2.1, hc.2.2.symm⟩⟩
      · have hlt := y.isLt
        have hb : (y.val - 1) / 7 < m := by omega
        exact ⟨⟨(y.val - 1) / 7, hb⟩, ⟨hne, Or.inr (Or.inl hc)⟩, Or.inl hc.1,
          Or.inr ⟨hc.2.1, rfl⟩⟩
      · have hlt := x.isLt
        have hb : (x.val - 1) / 7 < m := by omega
        exact ⟨⟨(x.val - 1) / 7, hb⟩, ⟨hne, Or.inr (Or.inr hc)⟩, Or.inr ⟨hc.2.1, rfl⟩,
          Or.inl hc.1⟩
    · rintro ⟨b, hadj, -, -⟩
      exact hadj
  support := fun _ _ _ hxy => ⟨hxy.2.1, hxy.2.2⟩
  inter_eq := by
    intro i j hij
    ext x
    simp only [side, Set.mem_inter_iff, Set.mem_setOf_eq, Set.mem_singleton_iff]
    constructor
    · rintro ⟨hi | hi, hj | hj⟩
      · exact (val_eq_zero_iff x).1 hi
      · exact (val_eq_zero_iff x).1 hi
      · exact (val_eq_zero_iff x).1 hj
      · exact absurd (Fin.ext (hi.2.symm.trans hj.2)) hij
    · rintro rfl
      constructor
      · exact Or.inl (by simp)
      · exact Or.inl (by simp)
  cut_mem := mem_side_zero
  union_eq := by
    ext x
    simp only [Set.mem_iUnion, side, Set.mem_setOf_eq, Set.mem_univ, iff_true]
    have hm : 0 < m := Nat.pos_of_ne_zero (NeZero.ne m)
    by_cases hx : x.val = 0
    · exact ⟨⟨0, hm⟩, Or.inl hx⟩
    · have hlt := x.isLt
      have hb : (x.val - 1) / 7 < m := by omega
      exact ⟨⟨(x.val - 1) / 7, hb⟩, Or.inr ⟨by omega, rfl⟩⟩

instance decidablePredSide (b : Fin m) : DecidablePred (· ∈ side m b) := by
  intro x
  unfold side
  infer_instance

/-- The `b`-th side, as a `Finset`. -/
theorem side_eq_finset (b : Fin m) :
    (Finset.univ.filter (· ∈ side m b))
      = insert 0 ((Finset.univ : Finset (Fin 7)).image
          (fun j => (⟨7 * b.val + 1 + j.val, by
            have := b.isLt; have := j.isLt; omega⟩ : Fin (7 * m + 1)))) := by
  classical
  ext x
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert, Finset.mem_image,
    side, Set.mem_setOf_eq]
  constructor
  · rintro (hx | ⟨hx1, hx2⟩)
    · exact Or.inl ((val_eq_zero_iff x).1 hx)
    · refine Or.inr ⟨⟨x.val - 1 - 7 * b.val, by omega⟩, ?_⟩
      apply Fin.ext
      show 7 * b.val + 1 + (x.val - 1 - 7 * b.val) = x.val
      omega
  · rintro (rfl | ⟨j, rfl⟩)
    · exact Or.inl (by simp)
    · have hj := j.isLt
      refine Or.inr ⟨?_, ?_⟩
      · show 1 ≤ 7 * b.val + 1 + j.val
        omega
      · show (7 * b.val + 1 + j.val - 1) / 7 = b.val
        omega

/-- **Every side has exactly `8` vertices.** -/
theorem side_card (b : Fin m) : (Finset.univ.filter (· ∈ side m b)).card = 8 := by
  classical
  rw [side_eq_finset]
  have hinj : Set.InjOn
      (fun j : Fin 7 => (⟨7 * b.val + 1 + j.val, by
        have := b.isLt; have := j.isLt; omega⟩ : Fin (7 * m + 1)))
      (Finset.univ : Finset (Fin 7)) := by
    intro i _ j _ hij
    have : 7 * b.val + 1 + i.val = 7 * b.val + 1 + j.val := congrArg Fin.val hij
    exact Fin.ext (by omega)
  have hnot : (0 : Fin (7 * m + 1)) ∉ (Finset.univ : Finset (Fin 7)).image
      (fun j : Fin 7 => (⟨7 * b.val + 1 + j.val, by
        have := b.isLt; have := j.isLt; omega⟩ : Fin (7 * m + 1))) := by
    simp only [Finset.mem_image, Finset.mem_univ, true_and, not_exists]
    intro j hj
    have hval : (0 : Fin (7 * m + 1)).val = 7 * b.val + 1 + j.val := congrArg Fin.val hj.symm
    simp only [Fin.val_zero] at hval
    omega
  rw [Finset.card_insert_of_notMem hnot, Finset.card_image_of_injOn hinj, Finset.card_univ,
    Fintype.card_fin]

/-- Each side carries an independent pair (the cut vertex and the first vertex of the block),
i.e. relative density exactly `1/4 = 2/8`. -/
def sideIndep (b : Fin m) : Finset (Fin (7 * m + 1)) :=
  {0, ⟨7 * b.val + 1, by have := b.isLt; omega⟩}

theorem sideIndep_card (b : Fin m) : (sideIndep b).card = 2 := by
  classical
  rw [sideIndep, Finset.card_insert_of_notMem, Finset.card_singleton]
  simp only [Finset.mem_singleton]
  intro hcon
  have : (0 : Fin (7 * m + 1)).val = 7 * b.val + 1 := congrArg Fin.val hcon
  simp at this

theorem sideIndep_subset (b : Fin m) : ↑(sideIndep b) ⊆ side m b := by
  intro x hx
  simp only [sideIndep, Finset.coe_insert, Set.mem_insert_iff, Finset.coe_singleton,
    Set.mem_singleton_iff] at hx
  rcases hx with rfl | rfl
  · exact mem_side_zero b
  · refine Or.inr ⟨?_, ?_⟩
    · show 1 ≤ 7 * b.val + 1
      omega
    · show (7 * b.val + 1 - 1) / 7 = b.val
      omega

theorem sideIndep_isIndepSet (b : Fin m) : (part m b).IsIndepSet ↑(sideIndep b) := by
  classical
  intro x hx y hy hne hadj
  simp only [sideIndep, Finset.coe_insert, Set.mem_insert_iff, Finset.coe_singleton,
    Set.mem_singleton_iff] at hx hy
  obtain ⟨⟨-, hc | hc | hc⟩, -, -⟩ := hadj
  · rcases hx with rfl | rfl <;> rcases hy with rfl | rfl
    · exact hne rfl
    · simp at hc
    · simp at hc
    · exact hne rfl
  · rcases hy with rfl | rfl
    · simp at hc
    · exact hc.2.2 (by simp [Nat.mul_mod_right])
  · rcases hx with rfl | rfl
    · simp at hc
    · exact hc.2.2 (by simp [Nat.mul_mod_right])

/-- **The `m`-fold defect bound of the companion file is attained with equality.**  For the
threshold density `r = 1/4` the star-amalgam bound reads
`i(G) ≥ 1/4 - (m-1)(3/4)/(7m+1)`, and the family `StarK8 m` realises it exactly. -/
theorem starIndepRatio_eq_defect_bound (hm : 1 ≤ m) :
    (StarK8 m).indepRatio
      = (1 : ℚ) / 4 - ((m : ℚ) - 1) * (1 - (1 : ℚ) / 4) / (7 * (m : ℚ) + 1) := by
  rw [starIndepRatio]
  have h7 : (7 : ℚ) * (m : ℚ) + 1 ≠ 0 := by positivity
  field_simp
  ring

/-- The hypotheses of the companion bound are met with `r = 1/4`: the sides have `8` vertices
and carry independent sets of size `2`, and the sides cover the amalgam with the correct
multiplicity. -/
theorem side_cover [NeZero m] :
    ((Fintype.card (Fin (7 * m + 1)) : ℚ)) + ((Fintype.card (Fin m) - 1 : ℕ) : ℚ)
      = ∑ b : Fin m, ((Finset.univ.filter (· ∈ side m b)).card : ℚ) := by
  classical
  have hm : 1 ≤ m := Nat.one_le_iff_ne_zero.2 (NeZero.ne m)
  simp only [side_card, Fintype.card_fin, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  have : ((m - 1 : ℕ) : ℚ) = (m : ℚ) - 1 := by
    have : (1 : ℕ) ≤ m := hm
    push_cast [Nat.cast_sub this]
    ring
  rw [this]
  push_cast
  ring

/-- **Capstone: the `m`-fold defect bound is sharp for every `m`.**  The general star-amalgam
bound of `Novelty.OneSumStarAmalgam`, instantiated at the threshold density `r = 1/4`, is both
*valid* and *attained* by the family `StarK8 m`. -/
theorem star_defect_bound_sharp [NeZero m] :
    (1 : ℚ) / 4 - ((Fintype.card (Fin m) - 1 : ℕ) : ℚ) * (1 - (1 : ℚ) / 4)
        / (Fintype.card (Fin (7 * m + 1)) : ℚ) ≤ (StarK8 m).indepRatio ∧
      (StarK8 m).indepRatio
        = (1 : ℚ) / 4 - ((Fintype.card (Fin m) - 1 : ℕ) : ℚ) * (1 - (1 : ℚ) / 4)
            / (Fintype.card (Fin (7 * m + 1)) : ℚ) := by
  classical
  have hm : 0 < m := Nat.pos_of_ne_zero (NeZero.ne m)
  haveI : Nonempty (Fin m) := ⟨⟨0, hm⟩⟩
  have hvalue : (StarK8 m).indepRatio
      = (1 : ℚ) / 4 - ((Fintype.card (Fin m) - 1 : ℕ) : ℚ) * (1 - (1 : ℚ) / 4)
          / (Fintype.card (Fin (7 * m + 1)) : ℚ) := by
    rw [starIndepRatio]
    simp only [Fintype.card_fin]
    have hcast : ((m - 1 : ℕ) : ℚ) = (m : ℚ) - 1 := by
      have h1 : (1 : ℕ) ≤ m := hm
      push_cast [Nat.cast_sub h1]
      ring
    rw [hcast]
    have h7 : (7 : ℚ) * (m : ℚ) + 1 ≠ 0 := by positivity
    push_cast
    field_simp
    ring
  refine ⟨?_, hvalue⟩
  refine star_isStarSum.indepRatio_ge_of_sides (s := fun b => sideIndep b)
    (fun b => sideIndep_subset b) (fun b => sideIndep_isIndepSet b) (r := (1 : ℚ) / 4)
    (fun b => ?_) ?_ (by simp)
  · rw [side_card b, sideIndep_card b]
    norm_num
  · exact side_cover

end StarSum

end StarFamily

end SimpleGraph