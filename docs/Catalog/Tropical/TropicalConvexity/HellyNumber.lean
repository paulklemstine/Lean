import Mathlib

/-!
# The tropical Helly theorem: Helly number `d`, sharply

This file proves a tropical analogue of Helly's theorem and settles the
conjecture recorded in `Catalog/Tropical/TropicalAlgebra/HellyGeometry.lean`
(`TropicalHelly.tropicalHellyConjecture`, Helly number `≤ 2 * d`).

## Layout

1. **Tropical Cramer rule / dependence** (`TropicalDependence`).  Any `d + 1`
   vectors of `ℝ^d` are tropically dependent: with weights `lam k` given by the
   tropical determinant of the row-`k`-deleted minor, in every coordinate the
   maximum `max_k (lam k + A k i)` is attained at least twice
   (`trop_dependence_fin`).  The proof is the max-plus incarnation of "a matrix
   with two equal columns is singular": one duplicates column `i`, expands the
   optimal permutation weight à la Laplace, and swaps the two rows carrying the
   two copies of the column.
2. **Tropical Helly** (`TropicalHellyNumber`).  For a finite family of tropical
   cones in `ℝ^d` with `d ≥ 1`, `d`-wise intersection implies global
   intersection (`tropical_helly`), and the number `d` is optimal
   (`tropical_helly_number_sharp`).  Applications: locality of tropical linear
   feasibility (`tropical_feasibility_local`), the Helly criterion for
   difference-constraint systems (`diffConstraint_feasible_iff`), and a
   counterexample showing finiteness is essential
   (`tropical_helly_fails_for_infinite_families`).
3. **The previous cycle's conjecture** (`TropicalConvexHelly`).  For tropically
   convex (not necessarily scaling-invariant) subsets of `ℝ^d` the Helly number
   is exactly `d + 1` (`tropConvex_helly`, `tropConvex_helly_number_sharp`).
   Consequently the conjectured bound `2 * d` **holds for every `d ≥ 1`**
   (`tropicalHellyConjecture_holds`) and **fails for `d = 0`**
   (`tropicalHellyConjecture_zero`).

## Lab notes (exploratory `#eval` data behind the statements)

Running the Cramer construction over `ℚ`:

* `A = [[0,0],[1,3],[4,1]]` (3 points in `ℝ²`) gives `lam = [7,4,3]` and the
  column data `[(7,2),(7,2)]`: both column maxima are attained twice.
* `A = [[0,0,0],[3,1,4],[1,5,9],[2,6,5]]` gives `lam = [18,15,10,12]` and
  `[(18,2),(18,2),(19,2)]`.
* With only `d` rows the property fails: `[[0,0],[1,3]]` gives `[(1,2),(3,1)]`
  — a unique maximiser in the second column.  Hence `d + 1` rows are necessary,
  matching the sharpness theorems below.

See `ComputationalEvidence.md` for the full table.
-/

open Finset

namespace TropicalDependence

variable {d : ℕ}

/-- Max-plus (tropical) determinant of a square real matrix:
`tropDet M = max_σ ∑_r M r (σ r)`. -/
noncomputable def tropDet {m : ℕ} (M : Fin m → Fin m → ℝ) : ℝ :=
  univ.sup' univ_nonempty (fun σ : Equiv.Perm (Fin m) => ∑ r, M r (σ r))

/-- `A` with a dummy zero column prepended. -/
def augZero (A : Fin (d + 1) → Fin d → ℝ) (r c : Fin (d + 1)) : ℝ :=
  Fin.cases 0 (fun j => A r j) c

/-- `A` with its `i`-th column prepended (so the matrix has two equal columns). -/
def augCol (A : Fin (d + 1) → Fin d → ℝ) (i : Fin d) (r c : Fin (d + 1)) : ℝ :=
  Fin.cases (A r i) (fun j => A r j) c

lemma augZero_zero (A : Fin (d + 1) → Fin d → ℝ) (r : Fin (d + 1)) :
    augZero A r 0 = 0 := rfl

lemma augZero_succ (A : Fin (d + 1) → Fin d → ℝ) (r : Fin (d + 1)) (j : Fin d) :
    augZero A r j.succ = A r j := rfl

lemma augCol_zero (A : Fin (d + 1) → Fin d → ℝ) (i : Fin d) (r : Fin (d + 1)) :
    augCol A i r 0 = A r i := rfl

lemma augCol_succ (A : Fin (d + 1) → Fin d → ℝ) (i : Fin d) (r : Fin (d + 1)) (j : Fin d) :
    augCol A i r j.succ = A r j := rfl

/-- The augmented matrix with a duplicated column differs from the one with a
dummy zero column only in the first column. -/
lemma augCol_eq (A : Fin (d + 1) → Fin d → ℝ) (i : Fin d) (r c : Fin (d + 1)) :
    augCol A i r c = augZero A r c + (if c = 0 then A r i else 0) := by
  induction c using Fin.cases with
  | zero => simp [augCol_zero, augZero_zero]
  | succ j => simp [augCol_succ, augZero_succ, Fin.succ_ne_zero]

/-- Permutations sending `k` to `0` form a nonempty set. -/
lemma perm_filter_nonempty (k : Fin (d + 1)) :
    {π : Equiv.Perm (Fin (d + 1)) | π k = 0}.toFinset.Nonempty := by
  refine ⟨Equiv.swap k 0, ?_⟩
  simp

/-- The max-plus Cramer weight of row `k`: the tropical determinant of the minor
obtained by deleting row `k` (encoded as the best permutation weight among those
assigning the dummy column to row `k`). -/
noncomputable def cramerWeight (A : Fin (d + 1) → Fin d → ℝ) (k : Fin (d + 1)) : ℝ :=
  ({π : Equiv.Perm (Fin (d + 1)) | π k = 0}).toFinset.sup' (perm_filter_nonempty k)
    (fun π => ∑ r, augZero A r (π r))

lemma weight_le_cramerWeight (A : Fin (d + 1) → Fin d → ℝ) (π : Equiv.Perm (Fin (d + 1))) :
    (∑ r, augZero A r (π r)) ≤ cramerWeight A (π.symm 0) := by
  rw [cramerWeight]
  exact Finset.le_sup' (fun π : Equiv.Perm (Fin (d + 1)) => ∑ r, augZero A r (π r)) (by simp)

lemma exists_perm_eq_cramerWeight (A : Fin (d + 1) → Fin d → ℝ) (k : Fin (d + 1)) :
    ∃ π : Equiv.Perm (Fin (d + 1)), π k = 0 ∧ (∑ r, augZero A r (π r)) = cramerWeight A k := by
  obtain ⟨π, hπ, h⟩ := Finset.exists_mem_eq_sup' (perm_filter_nonempty k)
    (fun π => ∑ r, augZero A r (π r))
  simp only [Set.mem_toFinset, Set.mem_setOf_eq] at hπ
  exact ⟨π, hπ, h.symm⟩

/-- Laplace-type expansion: the weight of a permutation in the duplicated-column
matrix splits as the Cramer weight datum plus the entry in the duplicated column. -/
lemma sum_augCol (A : Fin (d + 1) → Fin d → ℝ) (i : Fin d) (π : Equiv.Perm (Fin (d + 1))) :
    (∑ r, augCol A i r (π r)) = (∑ r, augZero A r (π r)) + A (π.symm 0) i := by
  have h : ∀ r, augCol A i r (π r) = augZero A r (π r) + (if π r = 0 then A r i else 0) := by
    intro r; exact augCol_eq A i r (π r)
  simp only [h, Finset.sum_add_distrib]
  congr 1
  rw [Finset.sum_eq_single (π.symm 0)]
  · simp
  · intro b _ hb
    have : π b ≠ 0 := by
      intro hcon
      exact hb (by rw [← hcon, Equiv.symm_apply_apply])
    simp [this]
  · intro h; exact absurd (Finset.mem_univ _) h

/-- **Two equal columns ⇒ the optimal assignment can be modified.**  Swapping the
two rows that receive the two copies of column `i` does not change the weight. -/
lemma sum_augCol_swap (A : Fin (d + 1) → Fin d → ℝ) (i : Fin d)
    (π : Equiv.Perm (Fin (d + 1))) (a b : Fin (d + 1)) (ha : π a = 0) (hb : π b = i.succ) :
    (∑ r, augCol A i r (((Equiv.swap a b).trans π) r)) = ∑ r, augCol A i r (π r) := by
  have hab : a ≠ b := by
    intro h; rw [h, hb] at ha; exact (Fin.succ_ne_zero i) ha
  have hL : (∑ r, augCol A i r (((Equiv.swap a b).trans π) r))
      = ∑ r, augCol A i (Equiv.swap a b r) (π r) := by
    rw [← Equiv.sum_comp (Equiv.swap a b) (fun r => augCol A i (Equiv.swap a b r) (π r))]
    refine Finset.sum_congr rfl (fun r _ => ?_)
    simp [Equiv.trans_apply]
  rw [hL]
  have hsub : ({a, b} : Finset (Fin (d + 1))) ⊆ univ := Finset.subset_univ _
  rw [← Finset.sum_sdiff hsub (f := fun r => augCol A i (Equiv.swap a b r) (π r)),
      ← Finset.sum_sdiff hsub (f := fun r => augCol A i r (π r))]
  congr 1
  · refine Finset.sum_congr rfl (fun r hr => ?_)
    simp only [Finset.mem_sdiff, Finset.mem_insert, Finset.mem_singleton, not_or] at hr
    rw [Equiv.swap_apply_of_ne_of_ne hr.2.1 hr.2.2]
  · rw [Finset.sum_pair hab, Finset.sum_pair hab, Equiv.swap_apply_left,
      Equiv.swap_apply_right, ha, hb, augCol_zero, augCol_succ, augCol_zero, augCol_succ,
      add_comm]

lemma weight_le_cramerWeight' (A : Fin (d + 1) → Fin d → ℝ) (π : Equiv.Perm (Fin (d + 1)))
    (k : Fin (d + 1)) (h : π k = 0) :
    (∑ r, augZero A r (π r)) ≤ cramerWeight A k := by
  have h1 : π.symm 0 = k := by rw [← h, Equiv.symm_apply_apply]
  have := weight_le_cramerWeight A π
  rwa [h1] at this

/-- **Tropical Cramer / two-fold maximum.**  For every column `i` the maximum of
`cramerWeight A k + A k i` over the rows `k` is attained at (at least) two
distinct rows.  This is the max-plus incarnation of "a matrix with two equal
columns is singular". -/
theorem exists_two_argmax (A : Fin (d + 1) → Fin d → ℝ) (i : Fin d) :
    ∃ a b : Fin (d + 1), a ≠ b ∧
      (∀ k, cramerWeight A k + A k i ≤ cramerWeight A a + A a i) ∧
      cramerWeight A b + A b i = cramerWeight A a + A a i := by
  classical
  obtain ⟨π, -, hπ⟩ := Finset.exists_mem_eq_sup'
    (univ_nonempty (α := Equiv.Perm (Fin (d + 1)))) (fun π => ∑ r, augCol A i r (π r))
  have hπa : π (π.symm 0) = 0 := Equiv.apply_symm_apply π 0
  have hπb : π (π.symm i.succ) = i.succ := Equiv.apply_symm_apply π i.succ
  have hab : π.symm 0 ≠ π.symm i.succ := by
    intro h
    have h2 : (0 : Fin (d + 1)) = i.succ := by
      have := congrArg π h; rwa [hπa, hπb] at this
    exact (Fin.succ_ne_zero i) h2.symm
  -- Step 1: every row's Cramer value is bounded by the optimal permutation weight.
  have key1 : ∀ k, cramerWeight A k + A k i ≤ ∑ r, augCol A i r (π r) := by
    intro k
    obtain ⟨σ, hσk, hσ⟩ := exists_perm_eq_cramerWeight A k
    have hsym : σ.symm 0 = k := by rw [← hσk, Equiv.symm_apply_apply]
    have h1 : (∑ r, augCol A i r (σ r)) = cramerWeight A k + A k i := by
      rw [sum_augCol A i σ, hσ, hsym]
    rw [← h1, ← hπ]
    exact Finset.le_sup' (fun π => ∑ r, augCol A i r (π r)) (Finset.mem_univ σ)
  -- Step 2: the row receiving the duplicated column attains the bound.
  have hDa : (∑ r, augCol A i r (π r)) = cramerWeight A (π.symm 0) + A (π.symm 0) i := by
    refine le_antisymm ?_ (key1 _)
    rw [sum_augCol A i π]
    have := weight_le_cramerWeight A π
    linarith
  -- Step 3: swapping the two rows carrying the two equal columns gives a second maximiser.
  have hDb : (∑ r, augCol A i r (π r))
      = cramerWeight A (π.symm i.succ) + A (π.symm i.succ) i := by
    refine le_antisymm ?_ (key1 _)
    have hb0 : ((Equiv.swap (π.symm 0) (π.symm i.succ)).trans π) (π.symm i.succ) = 0 := by
      simp [Equiv.trans_apply, Equiv.swap_apply_right, hπa]
    have hsym : ((Equiv.swap (π.symm 0) (π.symm i.succ)).trans π).symm 0 = π.symm i.succ := by
      rw [Equiv.symm_apply_eq]; exact hb0.symm
    rw [← sum_augCol_swap A i π (π.symm 0) (π.symm i.succ) hπa hπb,
      sum_augCol A i ((Equiv.swap (π.symm 0) (π.symm i.succ)).trans π), hsym]
    have := weight_le_cramerWeight' A ((Equiv.swap (π.symm 0) (π.symm i.succ)).trans π) _ hb0
    linarith
  exact ⟨π.symm 0, π.symm i.succ, hab, fun k => by rw [← hDa]; exact key1 k,
    by rw [← hDb, ← hDa]⟩

/-- **Tropical dependence of `d + 1` vectors in `ℝ^d`.**  With the Cramer weights,
no row is ever the strict unique maximiser in any coordinate: for every
coordinate `i` and every row `k` some other row `j` does at least as well. -/
theorem trop_dependence_fin (A : Fin (d + 1) → Fin d → ℝ) (i : Fin d) (k : Fin (d + 1)) :
    ∃ j, j ≠ k ∧ cramerWeight A k + A k i ≤ cramerWeight A j + A j i := by
  obtain ⟨a, b, hab, hmax, hba⟩ := exists_two_argmax A i
  by_cases hk : k = a
  · refine ⟨b, ?_, ?_⟩
    · rw [hk]; exact fun h => hab h.symm
    · rw [hba]; exact hmax k
  · exact ⟨a, fun h => hk h.symm, hmax k⟩

end TropicalDependence

/-! ## Tropical cones and the tropical Helly theorem -/

namespace TropicalHellyNumber

open TropicalDependence

variable {d : ℕ}

/-- A **tropical cone** (max-plus submodule) of `ℝ^d`: a set closed under
arbitrary max-plus combinations `i ↦ max (s + x i) (t + y i)` of two of its
points.  Equivalently, a tropically convex subset of the tropical projective
torus. -/
def IsTropCone (S : Set (Fin d → ℝ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ s t : ℝ, (fun i => max (s + x i) (t + y i)) ∈ S

/-- Tropical cones are invariant under tropical scaling. -/
lemma IsTropCone.shift {S : Set (Fin d → ℝ)} (hS : IsTropCone S) {x : Fin d → ℝ}
    (hx : x ∈ S) (s : ℝ) : (fun i => s + x i) ∈ S := by
  simpa using hS x hx x hx s s

/-- Tropical cones are closed under finite max-plus combinations. -/
lemma IsTropCone.sup'_mem {ι : Type*} {S : Set (Fin d → ℝ)} (hS : IsTropCone S)
    (p : ι → Fin d → ℝ) (lam : ι → ℝ) {F : Finset ι} (hF : F.Nonempty)
    (hp : ∀ k ∈ F, p k ∈ S) :
    (fun i => F.sup' hF (fun k => lam k + p k i)) ∈ S := by
  revert hp
  induction hF using Finset.Nonempty.cons_induction with
  | singleton a =>
      intro hp
      simpa using hS.shift (hp a (by simp)) (lam a)
  | cons a F ha hF ih =>
      intro hp
      have hmem : (fun i => F.sup' hF (fun k => lam k + p k i)) ∈ S :=
        ih (fun k hk => hp k (by simp [hk]))
      have := hS (p a) (hp a (by simp)) _ hmem (lam a) 0
      simp only [zero_add] at this
      simpa [Finset.sup'_cons hF] using this

/-- Auxiliary induction: a family of at most `m` tropical cones whose
`d`-element subfamilies all intersect has a common point. -/
theorem tropical_helly_aux {ι : Type*} [DecidableEq ι] (hd : 0 < d)
    (C : ι → Set (Fin d → ℝ)) (hC : ∀ k, IsTropCone (C k)) :
    ∀ (m : ℕ) (F : Finset ι), F.card ≤ m →
      (∀ I ⊆ F, I.card ≤ d → ∃ x, ∀ k ∈ I, x ∈ C k) → ∃ x, ∀ k ∈ F, x ∈ C k := by
  intro m
  induction m with
  | zero =>
      intro F hcard h
      exact h F Finset.Subset.rfl (by omega)
  | succ m ih =>
      intro F hcard h
      by_cases hle : F.card ≤ d
      · exact h F Finset.Subset.rfl hle
      push_neg at hle
      -- for each index, a point in the intersection of all the *other* sets
      have hpt : ∀ k ∈ F, ∃ z, ∀ j ∈ F.erase k, z ∈ C j := by
        intro k hk
        refine ih (F.erase k) ?_ ?_
        · rw [Finset.card_erase_of_mem hk]; omega
        · exact fun I hI hIcard => h I (hI.trans (Finset.erase_subset _ _)) hIcard
      choose! y hy using hpt
      -- select `d + 1` of the indices
      obtain ⟨G, hGF, hGcard⟩ := Finset.exists_subset_card_eq (show d + 1 ≤ F.card by omega)
      set e := Finset.equivFinOfCardEq hGcard
      set p : Fin (d + 1) → ι := fun r => ((e.symm r : {a // a ∈ G}) : ι)
      have hpF : ∀ r, p r ∈ F := fun r => hGF (e.symm r).2
      have hpinj : Function.Injective p := by
        intro r r' hrr'
        have h1 : e.symm r = e.symm r' := Subtype.ext hrr'
        simpa using congrArg e h1
      set A : Fin (d + 1) → Fin d → ℝ := fun r => y (p r)
      refine ⟨fun i => Finset.univ.sup' Finset.univ_nonempty
        (fun r => cramerWeight A r + A r i), ?_⟩
      intro j hj
      by_cases hjG : ∃ r, p r = j
      · -- `j` is one of the selected indices: drop it using tropical dependence
        obtain ⟨r₀, rfl⟩ := hjG
        have hne : ((Finset.univ : Finset (Fin (d + 1))).erase r₀).Nonempty := by
          rw [← Finset.card_pos, Finset.card_erase_of_mem (Finset.mem_univ _)]
          simp only [Finset.card_univ, Fintype.card_fin]
          omega
        have heq : (fun i => Finset.univ.sup' Finset.univ_nonempty
              (fun r => cramerWeight A r + A r i))
            = (fun i => (Finset.univ.erase r₀).sup' hne
              (fun r => cramerWeight A r + A r i)) := by
          funext i
          refine le_antisymm (Finset.sup'_le _ _ (fun r _ => ?_)) ?_
          · by_cases hr : r = r₀
            · subst hr
              obtain ⟨r', hr', hle'⟩ := trop_dependence_fin A i r
              exact le_trans hle'
                (Finset.le_sup' (fun r => cramerWeight A r + A r i)
                  (Finset.mem_erase.mpr ⟨hr', Finset.mem_univ _⟩))
            · exact Finset.le_sup' (fun r => cramerWeight A r + A r i)
                (Finset.mem_erase.mpr ⟨hr, Finset.mem_univ _⟩)
          · exact Finset.sup'_mono _ (Finset.erase_subset _ _) hne
        rw [heq]
        refine (hC (p r₀)).sup'_mem A (cramerWeight A) hne (fun r hr => ?_)
        have hrne : p r₀ ≠ p r := fun hcon =>
          (Finset.mem_erase.mp hr).1 (hpinj hcon).symm
        exact hy (p r) (hpF r) (p r₀) (Finset.mem_erase.mpr ⟨hrne, hpF r₀⟩)
      · -- `j` was not selected: every chosen point already lies in `C j`
        push_neg at hjG
        refine (hC j).sup'_mem A (cramerWeight A) Finset.univ_nonempty (fun r _ => ?_)
        exact hy (p r) (hpF r) j (Finset.mem_erase.mpr ⟨fun hcon => hjG r hcon.symm, hj⟩)

/-- **Tropical Helly theorem (Helly number `d`).**  For a finite family of
tropical cones in `ℝ^d` (`d ≥ 1`), if every subfamily of at most `d` members has
a common point, then the whole family has a common point. -/
theorem tropical_helly {ι : Type*} (hd : 0 < d) (C : ι → Set (Fin d → ℝ))
    (hC : ∀ k, IsTropCone (C k)) (F : Finset ι)
    (hint : ∀ I ⊆ F, I.card ≤ d → ∃ x, ∀ k ∈ I, x ∈ C k) :
    ∃ x, ∀ k ∈ F, x ∈ C k := by
  classical
  exact tropical_helly_aux hd C hC F.card F le_rfl hint

/-- **Characterisation of nonempty intersection.**  A finite family of tropical
cones in `ℝ^d` has a common point *if and only if* each of its subfamilies of
size at most `d` has one.  Equivalently: an empty intersection is always
certified by at most `d` members of the family. -/
theorem tropical_helly_iff {ι : Type*} (hd : 0 < d) (C : ι → Set (Fin d → ℝ))
    (hC : ∀ k, IsTropCone (C k)) (F : Finset ι) :
    (∃ x, ∀ k ∈ F, x ∈ C k) ↔ ∀ I ⊆ F, I.card ≤ d → ∃ x, ∀ k ∈ I, x ∈ C k := by
  refine ⟨fun ⟨x, hx⟩ I hIF _ => ⟨x, fun k hk => hx k (hIF hk)⟩, ?_⟩
  exact tropical_helly hd C hC F

/-- Tropical Helly theorem for families indexed by `Fin n`. -/
theorem tropical_helly_fin {n : ℕ} (hd : 0 < d) (C : Fin n → Set (Fin d → ℝ))
    (hC : ∀ k, IsTropCone (C k))
    (hint : ∀ I : Finset (Fin n), I.card ≤ d → ∃ x, ∀ k ∈ I, x ∈ C k) :
    ∃ x, ∀ k, x ∈ C k := by
  classical
  obtain ⟨x, hx⟩ := tropical_helly hd C hC Finset.univ
    (fun I _ hI => hint I hI)
  exact ⟨x, fun k => hx k (Finset.mem_univ k)⟩

/-! ## Sharpness: the tropical Helly number is exactly `d` -/

/-- The extremal family witnessing sharpness: `hellyTightSet k` consists of the
points whose `k`-th coordinate is beaten (by at least `1`) by some other
coordinate. -/
def hellyTightSet (k : Fin d) : Set (Fin d → ℝ) := {x | ∃ j, j ≠ k ∧ x k + 1 ≤ x j}

/-- Each extremal set is a tropical cone. -/
theorem hellyTightSet_isTropCone (k : Fin d) : IsTropCone (hellyTightSet k) := by
  rintro x ⟨jx, hjx, hx⟩ y ⟨jy, hjy, hy⟩ s t
  rcases le_total (t + y k) (s + x k) with hcase | hcase
  · refine ⟨jx, hjx, ?_⟩
    have h1 : max (s + x k) (t + y k) = s + x k := max_eq_left hcase
    have h2 : s + x jx ≤ max (s + x jx) (t + y jx) := le_max_left _ _
    simp only [h1]
    linarith
  · refine ⟨jy, hjy, ?_⟩
    have h1 : max (s + x k) (t + y k) = t + y k := max_eq_right hcase
    have h2 : t + y jy ≤ max (s + x jy) (t + y jy) := le_max_right _ _
    simp only [h1]
    linarith

/-- The extremal family has empty total intersection. -/
theorem hellyTightSet_iInter_empty (hd : 0 < d) :
    ¬ ∃ x : Fin d → ℝ, ∀ k, x ∈ hellyTightSet k := by
  rintro ⟨x, hx⟩
  have hne : (Finset.univ : Finset (Fin d)).Nonempty := by
    rw [← Finset.card_pos, Finset.card_univ, Fintype.card_fin]; exact hd
  obtain ⟨k, -, hk⟩ := Finset.exists_mem_eq_sup' hne x
  obtain ⟨j, -, hj⟩ := hx k
  have : x j ≤ x k := by
    rw [← hk]; exact Finset.le_sup' x (Finset.mem_univ j)
  linarith

/-- Every proper subfamily of the extremal family has a common point. -/
theorem hellyTightSet_small_inter (I : Finset (Fin d)) (hI : I.card < d) :
    ∃ x : Fin d → ℝ, ∀ k ∈ I, x ∈ hellyTightSet k := by
  classical
  have hex : ∃ k₀ : Fin d, k₀ ∉ I := by
    by_contra hcon
    push_neg at hcon
    have : I = Finset.univ := Finset.eq_univ_of_forall hcon
    rw [this, Finset.card_univ, Fintype.card_fin] at hI
    exact lt_irrefl d hI
  obtain ⟨k₀, hk₀⟩ := hex
  refine ⟨fun j => if j = k₀ then 0 else -1, fun k hk => ⟨k₀, ?_, ?_⟩⟩
  · exact fun hcon => hk₀ (hcon ▸ hk)
  · have hkne : k ≠ k₀ := fun hcon => hk₀ (hcon ▸ hk)
    simp [hkne]

/-- **Sharpness of the tropical Helly number.**  For every `d ≥ 1` there is a
family of `d` tropical cones in `ℝ^d` such that every `d - 1` of them meet, yet
the whole family has empty intersection.  Together with `tropical_helly` this
shows the tropical Helly number of `ℝ^d` is exactly `d`. -/
theorem tropical_helly_number_sharp (hd : 0 < d) :
    ∃ C : Fin d → Set (Fin d → ℝ), (∀ k, IsTropCone (C k)) ∧
      (∀ I : Finset (Fin d), I.card ≤ d - 1 → ∃ x, ∀ k ∈ I, x ∈ C k) ∧
      ¬ ∃ x, ∀ k, x ∈ C k := by
  refine ⟨hellyTightSet, hellyTightSet_isTropCone, fun I hI => ?_,
    hellyTightSet_iInter_empty hd⟩
  exact hellyTightSet_small_inter I (by omega)

/-! ## Tropical linear programming: feasibility of max-plus inequality systems -/

/-- The solution set of a two-sided tropical linear inequality
`max_j (a j + x j) ≤ max_j (b j + x j)` in `d + 1` variables. -/
def tropHalfspace (a b : Fin (d + 1) → ℝ) : Set (Fin (d + 1) → ℝ) :=
  {x | Finset.univ.sup' Finset.univ_nonempty (fun j => a j + x j)
      ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => b j + x j)}

private lemma sup'_max_plus (c : Fin (d + 1) → ℝ) (x y : Fin (d + 1) → ℝ) (s t : ℝ) :
    Finset.univ.sup' Finset.univ_nonempty (fun j => c j + max (s + x j) (t + y j))
      = max (s + Finset.univ.sup' Finset.univ_nonempty (fun j => c j + x j))
        (t + Finset.univ.sup' Finset.univ_nonempty (fun j => c j + y j)) := by
  refine le_antisymm (Finset.sup'_le _ _ (fun j _ => ?_)) (max_le ?_ ?_)
  · rcases le_total (t + y j) (s + x j) with h | h
    · rw [max_eq_left h]
      refine le_trans ?_ (le_max_left _ _)
      have : c j + x j ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => c j + x j) :=
        Finset.le_sup' (fun j => c j + x j) (Finset.mem_univ j)
      linarith
    · rw [max_eq_right h]
      refine le_trans ?_ (le_max_right _ _)
      have : c j + y j ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => c j + y j) :=
        Finset.le_sup' (fun j => c j + y j) (Finset.mem_univ j)
      linarith
  · obtain ⟨j, -, hj⟩ := Finset.exists_mem_eq_sup'
      (Finset.univ_nonempty (α := Fin (d + 1))) (fun j => c j + x j)
    rw [hj]
    have : c j + max (s + x j) (t + y j)
        ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => c j + max (s + x j) (t + y j)) :=
      Finset.le_sup' (fun j => c j + max (s + x j) (t + y j)) (Finset.mem_univ j)
    have h2 : s + x j ≤ max (s + x j) (t + y j) := le_max_left _ _
    linarith
  · obtain ⟨j, -, hj⟩ := Finset.exists_mem_eq_sup'
      (Finset.univ_nonempty (α := Fin (d + 1))) (fun j => c j + y j)
    rw [hj]
    have : c j + max (s + x j) (t + y j)
        ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => c j + max (s + x j) (t + y j)) :=
      Finset.le_sup' (fun j => c j + max (s + x j) (t + y j)) (Finset.mem_univ j)
    have h2 : t + y j ≤ max (s + x j) (t + y j) := le_max_right _ _
    linarith

/-- Tropical halfspaces are tropical cones. -/
theorem tropHalfspace_isTropCone (a b : Fin (d + 1) → ℝ) :
    IsTropCone (tropHalfspace a b) := by
  intro x hx y hy s t
  simp only [tropHalfspace, Set.mem_setOf_eq] at hx hy ⊢
  rw [sup'_max_plus a x y s t, sup'_max_plus b x y s t]
  exact max_le_max (by linarith) (by linarith)

/-! ### Difference constraints: a graph-theoretic instance -/

/-- The solution set of a single difference constraint `x j ≤ w + x i`
(the edge relation of a shortest-path/scheduling system). -/
def diffConstraint (i j : Fin d) (w : ℝ) : Set (Fin d → ℝ) := {x | x j ≤ w + x i}

/-- Difference constraints cut out tropical cones. -/
theorem diffConstraint_isTropCone (i j : Fin d) (w : ℝ) :
    IsTropCone (diffConstraint i j w) := by
  intro x hx y hy s t
  simp only [diffConstraint, Set.mem_setOf_eq] at hx hy ⊢
  rcases le_total (t + y j) (s + x j) with h | h
  · rw [max_eq_left h]
    have h1 : s + x i ≤ max (s + x i) (t + y i) := le_max_left _ _
    linarith
  · rw [max_eq_right h]
    have h1 : t + y i ≤ max (s + x i) (t + y i) := le_max_right _ _
    linarith

/-- **Helly criterion for difference constraint systems (`d` variables).**
A finite system of constraints `x_{tgt k} - x_{src k} ≤ w k` is feasible exactly
when every `d` of the constraints are simultaneously feasible.  This is the
Helly-theoretic shadow of the negative-cycle criterion: a violated system always
contains a violated subsystem of at most `d` constraints (a simple cycle). -/
theorem diffConstraint_feasible_iff {n : ℕ} (hd : 0 < d)
    (src tgt : Fin n → Fin d) (w : Fin n → ℝ) :
    (∃ x, ∀ k, x ∈ diffConstraint (src k) (tgt k) (w k)) ↔
      ∀ I : Finset (Fin n), I.card ≤ d →
        ∃ x, ∀ k ∈ I, x ∈ diffConstraint (src k) (tgt k) (w k) := by
  constructor
  · rintro ⟨x, hx⟩ I _
    exact ⟨x, fun k _ => hx k⟩
  · intro hI
    exact tropical_helly_fin hd _
      (fun k => diffConstraint_isTropCone (src k) (tgt k) (w k)) hI

/-! ### Boundary of the theorem: finiteness is essential -/

/-- **Helly fails for infinite families of tropical cones.**  The nested
half-cones `{x : x₀ + k ≤ x₁}` in `ℝ²` are tropical cones, every finite
subfamily has a common point, and yet the whole family has none.  So the
finiteness hypothesis in `tropical_helly` cannot be dropped (no compactness is
available in the max-plus setting). -/
theorem tropical_helly_fails_for_infinite_families :
    ∃ C : ℕ → Set (Fin 2 → ℝ), (∀ k, IsTropCone (C k)) ∧
      (∀ F : Finset ℕ, ∃ x, ∀ k ∈ F, x ∈ C k) ∧ ¬ ∃ x, ∀ k, x ∈ C k := by
  classical
  refine ⟨fun k => {x : Fin 2 → ℝ | x 0 + k ≤ x 1}, ?_, ?_, ?_⟩
  · intro k x hx y hy s t
    simp only [Set.mem_setOf_eq] at hx hy ⊢
    rcases le_total (t + y 0) (s + x 0) with h | h
    · rw [max_eq_left h]
      have h1 : s + x 1 ≤ max (s + x 1) (t + y 1) := le_max_left _ _
      linarith
    · rw [max_eq_right h]
      have h1 : t + y 1 ≤ max (s + x 1) (t + y 1) := le_max_right _ _
      linarith
  · intro F
    refine ⟨fun i => if i = 0 then 0 else (F.sup id : ℕ), fun k hk => ?_⟩
    simp only [Set.mem_setOf_eq]
    norm_num
    exact_mod_cast Finset.le_sup (f := id) hk
  · rintro ⟨x, hx⟩
    obtain ⟨k, hk⟩ := exists_nat_gt (x 1 - x 0)
    have := hx k
    simp only [Set.mem_setOf_eq] at this
    linarith

/-- **Tropical linear feasibility is `(d+1)`-local.**  A finite system of
two-sided tropical linear inequalities in `d + 1` unknowns is solvable if and
only if every `d + 1` of its inequalities are simultaneously solvable.  This is
the max-plus analogue of the classical Helly-type criterion for linear
programming, and gives a polynomial-size infeasibility certificate. -/
theorem tropical_feasibility_local {n : ℕ} (a b : Fin n → Fin (d + 1) → ℝ) :
    (∃ x, ∀ k, x ∈ tropHalfspace (a k) (b k)) ↔
      ∀ I : Finset (Fin n), I.card ≤ d + 1 →
        ∃ x, ∀ k ∈ I, x ∈ tropHalfspace (a k) (b k) := by
  constructor
  · rintro ⟨x, hx⟩ I _
    exact ⟨x, fun k _ => hx k⟩
  · intro hI
    exact tropical_helly_fin (d := d + 1) (Nat.succ_pos d)
      (fun k => tropHalfspace (a k) (b k))
      (fun k => tropHalfspace_isTropCone (a k) (b k)) hI

end TropicalHellyNumber

/-! ## Resolution of the previous cycle's tropical Helly conjecture

The catalog file `Catalog/Tropical/TropicalAlgebra/HellyGeometry.lean` recorded
the conjecture that tropically convex subsets of `ℝ^d` have Helly number at most
`2 * d`.  We settle it: it is **false for `d = 0`** and **true for `d ≥ 1`**,
where in fact the sharp bound is `d + 1`. -/

namespace TropicalConvexHelly

open TropicalHellyNumber

variable {d : ℕ}

/-- Max-plus tropical convexity, exactly as in the catalog file
`HellyGeometry.lean` (`TropicalHelly.IsTropConvex`). -/
def IsTropConvex (S : Set (Fin d → ℝ)) : Prop :=
  ∀ x ∈ S, ∀ y ∈ S, ∀ t ≤ (0 : ℝ), (fun i => max (x i) (t + y i)) ∈ S

/-- The conjecture stated at the end of the catalog file `HellyGeometry.lean`. -/
def tropicalHellyConjecture (d : ℕ) : Prop :=
  ∀ n : ℕ, ∀ F : Fin n → Set (Fin d → ℝ),
    (∀ i, IsTropConvex (F i)) →
    (∀ I : Finset (Fin n), I.card ≤ 2 * d → ∃ x : Fin d → ℝ, ∀ i ∈ I, x ∈ F i) →
    ∃ x : Fin d → ℝ, ∀ i, x ∈ F i

/-- Chart projection `ℝ^{d+1} → ℝ^d` of the tropical projective torus. -/
def projDown (u : Fin (d + 1) → ℝ) : Fin d → ℝ := fun i => u i.castSucc - u (Fin.last d)

/-- Homogenisation: the tropical cone in `ℝ^{d+1}` generated by a tropically
convex subset of `ℝ^d`. -/
def coneLift (S : Set (Fin d → ℝ)) : Set (Fin (d + 1) → ℝ) := projDown ⁻¹' S

lemma projDown_snoc (x : Fin d → ℝ) : projDown (Fin.snoc x (0 : ℝ)) = x := by
  funext i
  simp [projDown]

lemma mem_coneLift_snoc {S : Set (Fin d → ℝ)} (x : Fin d → ℝ) :
    Fin.snoc x (0 : ℝ) ∈ coneLift S ↔ x ∈ S := by
  simp [coneLift, projDown_snoc]

/-- **Homogenisation turns tropical convexity into a tropical cone.** -/
theorem coneLift_isTropCone {S : Set (Fin d → ℝ)} (hS : IsTropConvex S) :
    IsTropCone (coneLift S) := by
  intro u hu v hv s t
  simp only [coneLift, Set.mem_preimage] at hu hv ⊢
  rcases le_total (t + v (Fin.last d)) (s + u (Fin.last d)) with hcase | hcase
  · have hkey : projDown (fun i => max (s + u i) (t + v i))
        = fun i => max (projDown u i)
            ((t + v (Fin.last d) - (s + u (Fin.last d))) + projDown v i) := by
      funext i
      simp only [projDown]
      rw [max_eq_left hcase]
      rcases le_total (t + v i.castSucc) (s + u i.castSucc) with h | h
      · rw [max_eq_left h, max_eq_left (by linarith)]; ring
      · rw [max_eq_right h, max_eq_right (by linarith)]; ring
    rw [hkey]
    exact hS _ hu _ hv _ (by linarith)
  · have hkey : projDown (fun i => max (s + u i) (t + v i))
        = fun i => max (projDown v i)
            ((s + u (Fin.last d) - (t + v (Fin.last d))) + projDown u i) := by
      funext i
      simp only [projDown]
      rw [max_eq_right hcase]
      rcases le_total (t + v i.castSucc) (s + u i.castSucc) with h | h
      · rw [max_eq_left h, max_eq_right (by linarith)]; ring
      · rw [max_eq_right h, max_eq_left (by linarith)]; ring
    rw [hkey]
    exact hS _ hv _ hu _ (by linarith)

/-- **Helly theorem for tropically convex subsets of `ℝ^d`, with Helly number
`d + 1`.**  This strictly strengthens the conjectured bound `2 * d`. -/
theorem tropConvex_helly {ι : Type*} (S : ι → Set (Fin d → ℝ))
    (hS : ∀ k, IsTropConvex (S k)) (F : Finset ι)
    (hint : ∀ I ⊆ F, I.card ≤ d + 1 → ∃ x, ∀ k ∈ I, x ∈ S k) :
    ∃ x, ∀ k ∈ F, x ∈ S k := by
  obtain ⟨u, hu⟩ := tropical_helly (d := d + 1) (Nat.succ_pos d)
    (fun k => coneLift (S k)) (fun k => coneLift_isTropCone (hS k)) F
    (by
      intro I hIF hI
      obtain ⟨x, hx⟩ := hint I hIF hI
      exact ⟨Fin.snoc x 0, fun k hk => (mem_coneLift_snoc x).mpr (hx k hk)⟩)
  exact ⟨projDown u, fun k hk => hu k hk⟩

/-- **The conjecture from the previous cycle holds for every `d ≥ 1`.** -/
theorem tropicalHellyConjecture_holds (hd : 0 < d) : tropicalHellyConjecture d := by
  intro n F hF hint
  obtain ⟨x, hx⟩ := tropConvex_helly F hF Finset.univ
    (fun I _ hI => hint I (by omega))
  exact ⟨x, fun k => hx k (Finset.mem_univ k)⟩

/-- **The conjecture from the previous cycle fails for `d = 0`.**  In the
degenerate `0`-dimensional space the hypothesis is vacuous (`2 * 0 = 0`), so the
empty set is a counterexample: no bound of the form `≤ 0` can force
nonemptiness. -/
theorem tropicalHellyConjecture_zero : ¬ tropicalHellyConjecture 0 := by
  intro h
  obtain ⟨x, hx⟩ := h 1 (fun _ => (∅ : Set (Fin 0 → ℝ)))
    (fun _ x hx => absurd hx (Set.notMem_empty x))
    (by
      intro I hI
      refine ⟨fun i => i.elim0, fun i hi => ?_⟩
      have : I = ∅ := Finset.card_eq_zero.mp (Nat.le_zero.mp hI)
      rw [this] at hi
      exact absurd hi (Finset.notMem_empty i))
  exact absurd (hx 0) (Set.notMem_empty x)

/-- **Characterisation of nonempty intersection for tropically convex sets.** -/
theorem tropConvex_helly_iff {ι : Type*} (S : ι → Set (Fin d → ℝ))
    (hS : ∀ k, IsTropConvex (S k)) (F : Finset ι) :
    (∃ x, ∀ k ∈ F, x ∈ S k) ↔ ∀ I ⊆ F, I.card ≤ d + 1 → ∃ x, ∀ k ∈ I, x ∈ S k := by
  refine ⟨fun ⟨x, hx⟩ I hIF _ => ⟨x, fun k hk => hx k (hIF hk)⟩, ?_⟩
  exact tropConvex_helly S hS F

/-! ### Sharpness of the bound `d + 1` for tropically convex sets -/

/-- The dehomogenised extremal family: `d + 1` tropically convex subsets of
`ℝ^d`. -/
def tightConvexSet (k : Fin (d + 1)) : Set (Fin d → ℝ) :=
  {x | Fin.snoc x (0 : ℝ) ∈ hellyTightSet k}

lemma snoc_max_plus (x y : Fin d → ℝ) {t : ℝ} (ht : t ≤ 0) :
    (Fin.snoc (fun i => max (x i) (t + y i)) (0 : ℝ) : Fin (d + 1) → ℝ)
      = fun j => max (0 + (Fin.snoc x (0 : ℝ) : Fin (d + 1) → ℝ) j)
          (t + (Fin.snoc y (0 : ℝ) : Fin (d + 1) → ℝ) j) := by
  funext j
  refine Fin.lastCases ?_ ?_ j
  · simp [max_eq_left ht]
  · intro i
    simp

theorem tightConvexSet_isTropConvex (k : Fin (d + 1)) :
    IsTropConvex (tightConvexSet k) := by
  intro x hx y hy t ht
  simp only [tightConvexSet, Set.mem_setOf_eq] at hx hy ⊢
  rw [snoc_max_plus x y ht]
  exact hellyTightSet_isTropCone k _ hx _ hy 0 t

theorem tightConvexSet_iInter_empty :
    ¬ ∃ x : Fin d → ℝ, ∀ k, x ∈ tightConvexSet k := by
  rintro ⟨x, hx⟩
  exact hellyTightSet_iInter_empty (Nat.succ_pos d) ⟨Fin.snoc x 0, hx⟩

theorem tightConvexSet_small_inter (I : Finset (Fin (d + 1))) (hI : I.card ≤ d) :
    ∃ x : Fin d → ℝ, ∀ k ∈ I, x ∈ tightConvexSet k := by
  obtain ⟨u, hu⟩ := hellyTightSet_small_inter I (by omega)
  refine ⟨projDown u, fun k hk => ?_⟩
  have hshift : Fin.snoc (projDown u) (0 : ℝ) = fun j => (-u (Fin.last d)) + u j := by
    funext j
    refine Fin.lastCases ?_ ?_ j
    · simp
    · intro i
      simp [projDown]
      ring
  simp only [tightConvexSet, Set.mem_setOf_eq, hshift]
  exact (hellyTightSet_isTropCone k).shift (hu k hk) _

/-- **Sharpness for tropically convex sets.**  There are `d + 1` tropically
convex subsets of `ℝ^d` any `d` of which meet, with empty total intersection.
Hence the Helly number of tropical convexity in `ℝ^d` is exactly `d + 1`, and
the conjectured bound `2 * d` is not sharp for `d ≥ 2`. -/
theorem tropConvex_helly_number_sharp :
    ∃ S : Fin (d + 1) → Set (Fin d → ℝ), (∀ k, IsTropConvex (S k)) ∧
      (∀ I : Finset (Fin (d + 1)), I.card ≤ d → ∃ x, ∀ k ∈ I, x ∈ S k) ∧
      ¬ ∃ x, ∀ k, x ∈ S k :=
  ⟨tightConvexSet, tightConvexSet_isTropConvex, tightConvexSet_small_inter,
    tightConvexSet_iInter_empty⟩

end TropicalConvexHelly