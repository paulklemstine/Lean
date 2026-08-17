/-
# The three double coverings of the torus

The torus is a `K(ℤ², 1)`.  This file determines all of its connected double coverings by
purely group-theoretic means, using the classification machinery of the covering thread:

* every subgroup of index two of `ℤ²` contains `2ℤ²`, hence is pulled back from an
  index-two subgroup of `ℤ²/2ℤ² ≅ V` (the Klein four group);
* the Klein four group has exactly three index-two subgroups
  (`klein_three_double_coverings`), so the torus has exactly three double coverings
  (`torus_index_two_eq`, `torus_three_double_coverings`);
* index-two subgroups are normal, so the three coverings are pairwise non-isomorphic
  (`index_two_gEquiv_iff_eq`);
* nevertheless all three total spaces are again tori (`torus_covers_are_tori`): the three
  subgroups are the images of the injective endomorphisms of `ℤ²` with matrices
  `[[1,0],[0,2]]`, `[[2,0],[0,1]]` and `[[1,1],[1,-1]]`, so each is isomorphic to `ℤ²`.

The last two points together give the sharpest possible form of the failure of π₁ as an
invariant of coverings over a familiar space: the torus has three genuinely different
connected double coverings, and the total space of each one is a torus.
-/
import Mathlib
import Bridges.FundamentalGroupCoveringGalois
import Bridges.FundamentalGroupCoveringExamples
import Bridges.FundamentalGroupCoveringConjugacy
import Bridges.FundamentalGroupCoveringTwistedPair

open CategoryTheory MulAction

namespace FundamentalGroupCovering

/-- The fundamental group of the torus. -/
abbrev Torus : Type := Multiplicative (ℤ × ℤ)

/-- Reduction of both coordinates modulo two, `ℤ² → V`. -/
def red : Torus →* V :=
  MonoidHom.mk' (fun x => (Multiplicative.ofAdd (((Multiplicative.toAdd x).1 : ZMod 2)),
      Multiplicative.ofAdd (((Multiplicative.toAdd x).2 : ZMod 2)))) (by
    intro a b
    have h1 : ((((Multiplicative.toAdd a).1 + (Multiplicative.toAdd b).1 : ℤ)) : ZMod 2)
        = ((Multiplicative.toAdd a).1 : ZMod 2) + ((Multiplicative.toAdd b).1 : ZMod 2) := by
      push_cast; ring
    have h2 : ((((Multiplicative.toAdd a).2 + (Multiplicative.toAdd b).2 : ℤ)) : ZMod 2)
        = ((Multiplicative.toAdd a).2 : ZMod 2) + ((Multiplicative.toAdd b).2 : ZMod 2) := by
      push_cast; ring
    apply Prod.ext <;> simp [Prod.fst_add, Prod.snd_add, h1, h2])

theorem red_apply (x : Torus) :
    red x = (Multiplicative.ofAdd (((Multiplicative.toAdd x).1 : ZMod 2)),
      Multiplicative.ofAdd (((Multiplicative.toAdd x).2 : ZMod 2))) := rfl

theorem red_surjective : Function.Surjective red := by
  rintro ⟨a, b⟩
  obtain ⟨m, hm⟩ := ZMod.intCast_surjective (n := 2) (Multiplicative.toAdd a)
  obtain ⟨n, hn⟩ := ZMod.intCast_surjective (n := 2) (Multiplicative.toAdd b)
  refine ⟨Multiplicative.ofAdd ((m, n) : ℤ × ℤ), ?_⟩
  rw [red_apply]
  apply Prod.ext
  · show Multiplicative.ofAdd ((m : ZMod 2)) = a
    rw [hm]; rfl
  · show Multiplicative.ofAdd ((n : ZMod 2)) = b
    rw [hn]; rfl

/-- The kernel of the reduction map consists of squares, so it is contained in every
subgroup of index two. -/
theorem ker_red_le_of_index_two {H : Subgroup Torus} (h : H.index = 2) : red.ker ≤ H := by
  intro x hx
  have hx' : red x = 1 := hx
  rw [red_apply] at hx'
  have h1 : (((Multiplicative.toAdd x).1 : ZMod 2)) = 0 := by
    have := congrArg Prod.fst hx'
    exact this
  have h2 : (((Multiplicative.toAdd x).2 : ZMod 2)) = 0 := by
    have := congrArg Prod.snd hx'
    exact this
  obtain ⟨m, hm⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 2).mp h1
  obtain ⟨n, hn⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 2).mp h2
  have : x = (Multiplicative.ofAdd ((m, n) : ℤ × ℤ)) ^ 2 := by
    have hx2 : Multiplicative.toAdd x = ((2 * m, 2 * n) : ℤ × ℤ) := by
      apply Prod.ext <;> simp [hm, hn]
    apply Multiplicative.toAdd.injective
    rw [hx2]
    show ((2 * m, 2 * n) : ℤ × ℤ) = (2 : ℕ) • ((m, n) : ℤ × ℤ)
    apply Prod.ext <;> simp
  rw [this]
  exact Subgroup.sq_mem_of_index_two h _

/-! ## The three subgroups -/

/-- The subgroup of `ℤ²` with even second coordinate. -/
def TorusEvenSnd : Subgroup Torus := Subgroup.comap red Hfst

/-- The subgroup of `ℤ²` with even first coordinate. -/
def TorusEvenFst : Subgroup Torus := Subgroup.comap red Hsnd

/-- The subgroup of `ℤ²` with even coordinate sum. -/
def TorusEvenSum : Subgroup Torus := Subgroup.comap red Hdiag

theorem index_TorusEvenSnd : TorusEvenSnd.index = 2 := by
  rw [TorusEvenSnd, Subgroup.index_comap_of_surjective _ red_surjective, index_Hfst]

theorem index_TorusEvenFst : TorusEvenFst.index = 2 := by
  rw [TorusEvenFst, Subgroup.index_comap_of_surjective _ red_surjective, index_Hsnd]

theorem index_TorusEvenSum : TorusEvenSum.index = 2 := by
  rw [TorusEvenSum, Subgroup.index_comap_of_surjective _ red_surjective, index_Hdiag]

/-- **Every subgroup of index two of `ℤ²` is one of the three.** -/
theorem torus_index_two_eq {H : Subgroup Torus} (h : H.index = 2) :
    H = TorusEvenSnd ∨ H = TorusEvenFst ∨ H = TorusEvenSum := by
  have hker : red.ker ≤ H := ker_red_le_of_index_two h
  have hH : Subgroup.comap red (Subgroup.map red H) = H := Subgroup.comap_map_eq_self hker
  have hidx : (Subgroup.map red H).index = 2 := by
    have := Subgroup.index_comap_of_surjective (Subgroup.map red H) red_surjective
    rw [hH, h] at this
    exact this.symm
  rcases index_two_eq_of_klein hidx with hk | hk | hk
  · left
    rw [TorusEvenSnd, ← hk, hH]
  · right; left
    rw [TorusEvenFst, ← hk, hH]
  · right; right
    rw [TorusEvenSum, ← hk, hH]

theorem torus_subgroups_distinct :
    TorusEvenSnd ≠ TorusEvenFst ∧ TorusEvenSnd ≠ TorusEvenSum ∧
      TorusEvenFst ≠ TorusEvenSum := by
  have key : ∀ K L : Subgroup V, K ≠ L →
      Subgroup.comap red K ≠ Subgroup.comap red L := by
    intro K L hKL hcontra
    apply hKL
    have h1 := Subgroup.map_comap_eq_self_of_surjective red_surjective K
    have h2 := Subgroup.map_comap_eq_self_of_surjective red_surjective L
    rw [← h1, ← h2, hcontra]
  exact ⟨key _ _ Hfst_ne_Hsnd, key _ _ Hfst_ne_Hdiag, key _ _ Hsnd_ne_Hdiag⟩

/-! ## The three coverings are pairwise non-isomorphic -/

theorem torus_coverings_pairwise_non_isomorphic :
    ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusEvenSnd) (Torus ⧸ TorusEvenFst)) ∧
      ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusEvenSnd) (Torus ⧸ TorusEvenSum)) ∧
      ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusEvenFst) (Torus ⧸ TorusEvenSum)) := by
  obtain ⟨h12, h13, h23⟩ := torus_subgroups_distinct
  refine ⟨?_, ?_, ?_⟩
  · rw [index_two_gEquiv_iff_eq index_TorusEvenSnd]
    exact fun h => h12 h.symm
  · rw [index_two_gEquiv_iff_eq index_TorusEvenSnd]
    exact fun h => h13 h.symm
  · rw [index_two_gEquiv_iff_eq index_TorusEvenFst]
    exact fun h => h23 h.symm

/-! ## All three total spaces are tori -/

/-- An endomorphism of `ℤ²` given by an integer matrix. -/
def torusHom (a b c d : ℤ) : Torus →* Torus :=
  MonoidHom.mk' (fun x => Multiplicative.ofAdd
      ((a * (Multiplicative.toAdd x).1 + b * (Multiplicative.toAdd x).2,
        c * (Multiplicative.toAdd x).1 + d * (Multiplicative.toAdd x).2) : ℤ × ℤ)) (by
    intro x y
    apply Multiplicative.toAdd.injective
    apply Prod.ext <;> simp [Prod.fst_add, Prod.snd_add] <;> ring)

theorem torusHom_apply (a b c d : ℤ) (m n : ℤ) :
    torusHom a b c d (Multiplicative.ofAdd ((m, n) : ℤ × ℤ))
      = Multiplicative.ofAdd ((a * m + b * n, c * m + d * n) : ℤ × ℤ) := rfl

theorem torusHom_injective {a b c d : ℤ} (h : a * d - b * c ≠ 0) :
    Function.Injective (torusHom a b c d) := by
  rw [injective_iff_map_eq_one]
  rintro x hx
  set m := (Multiplicative.toAdd x).1 with hm
  set n := (Multiplicative.toAdd x).2 with hn
  have h1 : a * m + b * n = 0 := congrArg Prod.fst (congrArg Multiplicative.toAdd hx)
  have h2 : c * m + d * n = 0 := congrArg Prod.snd (congrArg Multiplicative.toAdd hx)
  have hmm : (a * d - b * c) * m = 0 := by linear_combination d * h1 - b * h2
  have hnn : (a * d - b * c) * n = 0 := by linear_combination a * h2 - c * h1
  have hm0 : m = 0 := by
    rcases mul_eq_zero.mp hmm with h' | h'
    · exact absurd h' h
    · exact h'
  have hn0 : n = 0 := by
    rcases mul_eq_zero.mp hnn with h' | h'
    · exact absurd h' h
    · exact h'
  apply Multiplicative.toAdd.injective
  apply Prod.ext
  · exact hm0
  · exact hn0

theorem range_torusHom_EvenSnd : (torusHom 1 0 0 2).range = TorusEvenSnd := by
  ext x
  constructor
  · rintro ⟨y, rfl⟩
    show red (torusHom 1 0 0 2 y) ∈ Hfst
    rw [mem_Hfst_iff, red_apply]
    show Multiplicative.ofAdd (((0 * (Multiplicative.toAdd y).1
      + 2 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 2)) = 1
    have h2 : ((2 : ZMod 2)) = 0 := by decide
    have : ((0 * (Multiplicative.toAdd y).1 + 2 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 2)
        = 0 := by push_cast; rw [h2]; ring
    rw [this]; rfl
  · intro hx
    have hx' : Multiplicative.ofAdd (((Multiplicative.toAdd x).2 : ZMod 2)) = (1 : C2) := by
      have := (mem_Hfst_iff (red x)).mp hx
      rw [red_apply] at this
      exact this
    have h0 : (((Multiplicative.toAdd x).2 : ZMod 2)) = 0 := hx'
    obtain ⟨k, hk⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 2).mp h0
    refine ⟨Multiplicative.ofAdd (((Multiplicative.toAdd x).1, k) : ℤ × ℤ), ?_⟩
    apply Multiplicative.toAdd.injective
    apply Prod.ext
    · show 1 * (Multiplicative.toAdd x).1 + 0 * k = (Multiplicative.toAdd x).1
      ring
    · show 0 * (Multiplicative.toAdd x).1 + 2 * k = (Multiplicative.toAdd x).2
      rw [hk]; ring

theorem range_torusHom_EvenFst : (torusHom 2 0 0 1).range = TorusEvenFst := by
  ext x
  constructor
  · rintro ⟨y, rfl⟩
    show red (torusHom 2 0 0 1 y) ∈ Hsnd
    rw [mem_Hsnd_iff, red_apply]
    show Multiplicative.ofAdd (((2 * (Multiplicative.toAdd y).1
      + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 2)) = 1
    have h2 : ((2 : ZMod 2)) = 0 := by decide
    have : ((2 * (Multiplicative.toAdd y).1 + 0 * (Multiplicative.toAdd y).2 : ℤ) : ZMod 2)
        = 0 := by push_cast; rw [h2]; ring
    rw [this]; rfl
  · intro hx
    have hx' : Multiplicative.ofAdd (((Multiplicative.toAdd x).1 : ZMod 2)) = (1 : C2) := by
      have := (mem_Hsnd_iff (red x)).mp hx
      rw [red_apply] at this
      exact this
    have h0 : (((Multiplicative.toAdd x).1 : ZMod 2)) = 0 := hx'
    obtain ⟨k, hk⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 2).mp h0
    refine ⟨Multiplicative.ofAdd ((k, (Multiplicative.toAdd x).2) : ℤ × ℤ), ?_⟩
    apply Multiplicative.toAdd.injective
    apply Prod.ext
    · show 2 * k + 0 * (Multiplicative.toAdd x).2 = (Multiplicative.toAdd x).1
      rw [hk]; ring
    · show 0 * k + 1 * (Multiplicative.toAdd x).2 = (Multiplicative.toAdd x).2
      ring

theorem range_torusHom_EvenSum : (torusHom 1 1 1 (-1)).range = TorusEvenSum := by
  ext x
  constructor
  · rintro ⟨y, rfl⟩
    show red (torusHom 1 1 1 (-1) y) ∈ Hdiag
    rw [mem_Hdiag_iff, red_apply]
    set m := (Multiplicative.toAdd y).1
    set n := (Multiplicative.toAdd y).2
    show Multiplicative.ofAdd (((1 * m + 1 * n : ℤ) : ZMod 2)) *
      Multiplicative.ofAdd (((1 * m + (-1) * n : ℤ) : ZMod 2)) = 1
    have : (((1 * m + 1 * n : ℤ) : ZMod 2)) + (((1 * m + (-1) * n : ℤ) : ZMod 2)) = 0 := by
      push_cast
      ring_nf
      have h2 : ((2 : ZMod 2)) = 0 := by decide
      rw [show (m : ZMod 2) * 2 = 2 * (m : ZMod 2) by ring, h2]
      ring
    exact this
  · intro hx
    have hx' : Multiplicative.ofAdd (((Multiplicative.toAdd x).1 : ZMod 2)) *
        Multiplicative.ofAdd (((Multiplicative.toAdd x).2 : ZMod 2)) = (1 : C2) := by
      have := (mem_Hdiag_iff (red x)).mp hx
      rw [red_apply] at this
      exact this
    have h0 : (((Multiplicative.toAdd x).1 : ZMod 2)) + (((Multiplicative.toAdd x).2 : ZMod 2))
        = 0 := hx'
    have hsum : (((Multiplicative.toAdd x).1 + (Multiplicative.toAdd x).2 : ℤ) : ZMod 2) = 0 := by
      push_cast
      exact h0
    obtain ⟨k, hk⟩ := (ZMod.intCast_zmod_eq_zero_iff_dvd _ 2).mp hsum
    refine ⟨Multiplicative.ofAdd ((k, (Multiplicative.toAdd x).1 - k) : ℤ × ℤ), ?_⟩
    apply Multiplicative.toAdd.injective
    apply Prod.ext
    · show 1 * k + 1 * ((Multiplicative.toAdd x).1 - k) = (Multiplicative.toAdd x).1
      ring
    · show 1 * k + (-1) * ((Multiplicative.toAdd x).1 - k) = (Multiplicative.toAdd x).2
      have : (Multiplicative.toAdd x).1 + (Multiplicative.toAdd x).2 = 2 * k := hk
      linarith

/-- **All three double coverings of the torus are tori.** -/
theorem torus_covers_are_tori :
    Nonempty (Torus ≃* TorusEvenSnd) ∧ Nonempty (Torus ≃* TorusEvenFst) ∧
      Nonempty (Torus ≃* TorusEvenSum) := by
  refine ⟨⟨?_⟩, ⟨?_⟩, ⟨?_⟩⟩
  · exact (MonoidHom.ofInjective (torusHom_injective (a := 1) (b := 0) (c := 0) (d := 2)
      (by norm_num))).trans (MulEquiv.subgroupCongr range_torusHom_EvenSnd)
  · exact (MonoidHom.ofInjective (torusHom_injective (a := 2) (b := 0) (c := 0) (d := 1)
      (by norm_num))).trans (MulEquiv.subgroupCongr range_torusHom_EvenFst)
  · exact (MonoidHom.ofInjective (torusHom_injective (a := 1) (b := 1) (c := 1) (d := -1)
      (by norm_num))).trans (MulEquiv.subgroupCongr range_torusHom_EvenSum)

/-- **The torus has exactly three connected double coverings, and all three total spaces
are tori.**  Hence over the torus the fundamental group of the total space carries *no*
information at all about which double covering one has: all three coverings have the same
number of sheets and homotopy equivalent (indeed homeomorphic) total spaces, and yet no
two of them are isomorphic as coverings. -/
theorem torus_three_double_coverings :
    (TorusEvenSnd.index = 2 ∧ TorusEvenFst.index = 2 ∧ TorusEvenSum.index = 2) ∧
      (∀ H : Subgroup Torus, H.index = 2 →
        H = TorusEvenSnd ∨ H = TorusEvenFst ∨ H = TorusEvenSum) ∧
      (¬ Nonempty (GEquiv Torus (Torus ⧸ TorusEvenSnd) (Torus ⧸ TorusEvenFst)) ∧
        ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusEvenSnd) (Torus ⧸ TorusEvenSum)) ∧
        ¬ Nonempty (GEquiv Torus (Torus ⧸ TorusEvenFst) (Torus ⧸ TorusEvenSum))) ∧
      (Nonempty (Torus ≃* TorusEvenSnd) ∧ Nonempty (Torus ≃* TorusEvenFst) ∧
        Nonempty (Torus ≃* TorusEvenSum)) :=
  ⟨⟨index_TorusEvenSnd, index_TorusEvenFst, index_TorusEvenSum⟩,
    fun _ h => torus_index_two_eq h, torus_coverings_pairwise_non_isomorphic,
    torus_covers_are_tori⟩

end FundamentalGroupCovering