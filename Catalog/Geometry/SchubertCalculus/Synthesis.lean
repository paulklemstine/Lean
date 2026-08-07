/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.FlagVariety
import Geometry.SchubertCalculus.Pieri

/-!
# Schubert calculus VI: synthesis — geometry meets the combinatorics

This file ties together the two halves of the development:

* the *geometric* side (`Flags`, `Duality`, `GeneralFlags`): complete flags, jump sets,
  transversality, and the duality theorem for a pair of flags in general position;
* the *combinatorial* side (`QBinomial`, `Pieri`): cell dimensions, the Gaussian binomial
  Poincaré polynomial, and the reversal involution.

Main results:

* `SchubertCalculus.jumpSet_G_eq_revSet` : the second jump datum of a transverse subspace is
  the combinatorial reversal `revSet` of the first;
* `SchubertCalculus.dimCell_add_dimCell_dual` : **the complementary codimension identity.**
  For a transverse `k`-dimensional subspace, the dimensions of the two Schubert cells it
  belongs to add up to `k (n - k) = dim Gr(k, n)`.  This is the numerical reason a
  complementary pair of Schubert conditions cuts out a *finite* (indeed single-point) set;
* `SchubertCalculus.ncard_transverse_eq_poincare_one` : the number of transverse
  `k`-dimensional subspaces is the Poincaré polynomial of `Gr(k, n)` evaluated at `q = 1`,
  i.e. the Euler characteristic of the Grassmannian;
* `SchubertCalculus.dimCell_jumpSet_opposite_part` : each member of the second flag lies in the
  *top* Schubert cell of the first, of the maximal dimension `k (n - k) = dim Gr(k, n)` — the
  precise sense in which the two flags are in general position;
* `SchubertCalculus.dimCell_permSet` / `SchubertCalculus.dimCell_jumpSet_flagOfPerm` : for the
  transverse flag attached to a permutation `w`, the Schubert cell dimension at level `k` is
  the number of inversions of `w` crossing that level — the geometric dimension datum of the
  flag variety is the inversion statistic of the symmetric group.
-/

namespace SchubertCalculus

open Module Submodule Finset

variable {K V : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]
variable {n : ℕ} {F G : CompleteFlag K V n}

/-- The jump datum of the transverse subspace `W_S` for the second flag is the reversal of
`S`.  (`rev n s = n - 1 - s` is the order-reversing involution of `{0, …, n-1}`.) -/
theorem jumpSet_G_eq_revSet (hFG : Opposite F G) (S : Finset ℕ) (hS : S ⊆ Finset.range n) :
    G.jumpSet ((S.sup (line F G) : Submodule K V)) = revSet n S := by
  rw [jumpSet_G_sup_lines hFG S hS]
  rfl

/-- **The complementary codimension identity.**  For a subspace transverse to a pair of flags
in general position, the two Schubert cells containing it (one for each flag) have dimensions
adding up to `k (n - k)`, the dimension of the Grassmannian.  Equivalently, the two Schubert
conditions have complementary codimension. -/
theorem dimCell_add_dimCell_dual (hFG : Opposite F G) {W : Submodule K V} {k : ℕ}
    (hW : IsTransverseFlags F G W) (hk : finrank K W = k) :
    dimCell n (F.jumpSet W) + dimCell n (G.jumpSet W) = k * (n - k) := by
  set S : Finset ℕ := F.jumpSet W with hSdef
  have hS : S ⊆ Finset.range n := F.jumpSet_subset W
  have hcard : S.card = k := by rw [hSdef, F.card_jumpSet W, hk]
  have hWeq : W = (S.sup (line F G) : Submodule K V) := transverse_eq_sup_lines hFG hW
  have hG : G.jumpSet W = revSet n S := by
    rw [hWeq]; exact jumpSet_G_eq_revSet hFG S hS
  have hrev : dimCell n (revSet n S) = k * (n - k) - dimCell n S := dimCell_revSet hS hcard
  have hle : dimCell n S ≤ k * (n - k) := dimCell_le hS hcard
  rw [hG, hrev]
  omega

/-- **Euler characteristic.**  The number of `k`-dimensional subspaces transverse to a pair of
flags in general position equals the Poincaré polynomial of `Gr(k, n)` at `q = 1`; every
Schubert cell contributes exactly one transverse point. -/
theorem ncard_transverse_eq_poincare_one (hFG : Opposite F G) (k : ℕ) :
    {W : Submodule K V | IsTransverseFlags F G W ∧ finrank K W = k}.ncard
      = poincare ℕ k n 1 := by
  rw [ncard_transverse_eq_choose hFG k, poincare_one, Nat.cast_id]

/-- For the Grassmannian of lines in `4`-space, the transverse subspaces for a pair of flags
in general position number `6`, matching the Poincaré polynomial `[4 choose 2]_q` at `q = 1`
(the six Schubert cells of `Gr(2,4)`). -/
theorem ncard_transverse_two_four (hFG : Opposite F G) (hn : n = 4) :
    {W : Submodule K V | IsTransverseFlags F G W ∧ finrank K W = 2}.ncard = 6 := by
  rw [ncard_transverse_eq_choose hFG 2, hn]
  decide

/-- The staircase jump set `{n-k, …, n-1}` indexes the top Schubert cell of `Gr(k, n)`. -/
theorem dimCell_Ico {n k : ℕ} (hk : k ≤ n) :
    dimCell n (Finset.Ico (n - k) n) = k * (n - k) := by
  classical
  have hcompl : Finset.range n \ Finset.Ico (n - k) n = Finset.range (n - k) := by
    ext b
    simp only [Finset.mem_sdiff, Finset.mem_range, Finset.mem_Ico, not_and, not_lt]
    omega
  have hterm : ∀ a ∈ Finset.Ico (n - k) n,
      ((Finset.range (n - k)).filter fun b => b < a).card = n - k := by
    intro a ha
    have ha' := Finset.mem_Ico.mp ha
    rw [Finset.filter_true_of_mem (fun b hb => by
      have := Finset.mem_range.mp hb; omega), Finset.card_range]
  rw [dimCell, hcompl, Finset.sum_congr rfl hterm, Finset.sum_const, Nat.card_Ico,
    smul_eq_mul]
  congr 1
  omega

/-- **The two flags are in general position, cell by cell.**  Each member `G_k` of the second
flag lies in the top Schubert cell of the first flag, whose dimension `k (n - k)` is the whole
dimension of `Gr(k, n)`.  Combined with `dimCell_add_dimCell_dual` this says that `G_k` lies
in the *smallest* cell of its own flag, as it must. -/
theorem dimCell_jumpSet_opposite_part (hFG : Opposite F G) {k : ℕ} (hk : k ≤ n) :
    dimCell n (F.jumpSet (G.part k)) = k * (n - k) := by
  have hG : G.part k = (flagOfPerm hFG Fin.revPerm).part k := by rw [flagOfPerm_revPerm hFG]
  rw [hG, jumpSet_flagOfPerm hFG _ hk, permSet_revPerm hk, dimCell_Ico hk]

/-! ### Concrete instances over `ℚ⁴` -/

/-- In `ℚ⁴`, the planes transverse to the standard pair of opposite coordinate flags number
exactly `6`. -/
theorem ncard_transverse_planes_rat_four :
    {W : Submodule ℚ (Fin 4 → ℚ) |
      IsTransverseFlags (stdFlag ℚ 4) (oppFlag ℚ 4) W ∧ finrank ℚ W = 2}.ncard = 6 := by
  rw [ncard_transverse_eq_choose opposite_stdFlag_oppFlag 2]
  decide

/-- In `ℚ⁴`, the complete flags transverse to the standard pair of opposite coordinate flags
number exactly `24 = 4!`. -/
theorem ncard_transverse_flags_rat_four :
    {H : CompleteFlag ℚ (Fin 4 → ℚ) 4 |
      IsTransverseFlag (stdFlag ℚ 4) (oppFlag ℚ 4) H}.ncard = 24 := by
  rw [ncard_transverse_flags_eq_factorial opposite_stdFlag_oppFlag]
  decide

/-! ### Cell dimensions of the flag of a permutation -/

/-- The number of inversions of `w` that *cross* the level `k`: pairs `j < k ≤ m` with
`w m < w j`. -/
def crossInv {n : ℕ} (w : Equiv.Perm (Fin n)) (k : ℕ) : ℕ :=
  (Finset.univ.filter fun p : Fin n × Fin n =>
    (p.1 : ℕ) < k ∧ k ≤ (p.2 : ℕ) ∧ ((w p.2 : Fin n) : ℕ) < ((w p.1 : Fin n) : ℕ)).card

lemma crossInv_eq_sum {n : ℕ} (w : Equiv.Perm (Fin n)) (k : ℕ) :
    crossInv w k = ∑ j ∈ Finset.univ.filter (fun j : Fin n => (j : ℕ) < k),
      (Finset.univ.filter fun m : Fin n =>
        k ≤ (m : ℕ) ∧ ((w m : Fin n) : ℕ) < ((w j : Fin n) : ℕ)).card := by
  classical
  rw [crossInv, Finset.card_filter, ← Finset.univ_product_univ, Finset.sum_product,
    Finset.sum_filter]
  refine Finset.sum_congr rfl fun j _ => ?_
  by_cases hj : (j : ℕ) < k
  · simp only [hj, true_and, if_true, Finset.card_filter]
  · simp [hj]

/-- **Cell dimension of a Bruhat flag.**  The `k`-th member of the flag attached to a
permutation `w` lies in the Schubert cell of dimension equal to the number of inversions of
`w` crossing level `k`.  This identifies the geometric dimension datum of the flag variety
with the classical inversion statistic of the symmetric group. -/
theorem dimCell_permSet {n : ℕ} (w : Equiv.Perm (Fin n)) (k : ℕ) :
    dimCell n (permSet w k) = crossInv w k := by
  classical
  have hinj : Function.Injective fun j : Fin n => ((w j : Fin n) : ℕ) :=
    fun a b h => w.injective (Fin.val_injective h)
  have h1 : dimCell n (permSet w k)
      = ∑ j ∈ Finset.univ.filter (fun j : Fin n => (j : ℕ) < k),
          ((Finset.range n \ permSet w k).filter fun b => b < ((w j : Fin n) : ℕ)).card := by
    rw [dimCell]
    exact Finset.sum_image fun a _ b _ h => hinj h
  rw [h1, crossInv_eq_sum]
  refine Finset.sum_congr rfl fun j _ => ?_
  have hset : ((Finset.range n \ permSet w k).filter fun b => b < ((w j : Fin n) : ℕ))
      = (Finset.univ.filter fun m : Fin n =>
          k ≤ (m : ℕ) ∧ ((w m : Fin n) : ℕ) < ((w j : Fin n) : ℕ)).image
            fun m => ((w m : Fin n) : ℕ) := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_sdiff, Finset.mem_range, Finset.mem_image,
      Finset.mem_univ, true_and]
    constructor
    · rintro ⟨⟨hxn, hxS⟩, hxlt⟩
      refine ⟨w.symm ⟨x, hxn⟩, ⟨?_, ?_⟩, by simp⟩
      · by_contra hlt
        exact hxS ((mem_permSet w k x).mpr ⟨w.symm ⟨x, hxn⟩, by omega, by simp⟩)
      · simpa using hxlt
    · rintro ⟨m, ⟨hkm, hmlt⟩, rfl⟩
      refine ⟨⟨(w m).isLt, ?_⟩, hmlt⟩
      intro hmem
      obtain ⟨a, ha, hae⟩ := (mem_permSet w k _).mp hmem
      have : a = m := w.injective (Fin.val_injective hae)
      omega
  rw [hset, Finset.card_image_of_injective _ hinj]

/-- **Bruhat cells of the flag variety, geometrically.**  For the transverse flag attached to
a permutation `w`, the `k`-th member lies in the Schubert cell of `Gr(k, n)` whose dimension
is the number of inversions of `w` crossing level `k`. -/
theorem dimCell_jumpSet_flagOfPerm (hFG : Opposite F G) (w : Equiv.Perm (Fin n)) {k : ℕ}
    (hk : k ≤ n) : dimCell n (F.jumpSet ((flagOfPerm hFG w).part k)) = crossInv w k := by
  rw [jumpSet_flagOfPerm hFG w hk, dimCell_permSet w k]

end SchubertCalculus