import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.HolographicCyclicInequality

/-!
# A calculus of holographic entropy inequalities

Monogamy of mutual information and the five-party cyclic inequality were each
proved by exhibiting a Boolean recombination rule for minimal surfaces.  This
file isolates the mechanism as a single structure and a single theorem, turning
"find a holographic entropy inequality" into "find a contraction map".

A `ContractionMap k m` is a map `χ : Bool^k → Bool^m` that does not increase
Hamming distance.  Given `k` boundary regions `A i` and `m` boundary regions
`B j` whose boundary indicator patterns are related by `χ`, the theorem
`entropy_le_of_contraction` yields

`∑ j S(B j) ≤ ∑ i S(A i)`.

Subadditivity, strong subadditivity and monogamy are all recovered as
instances (`subadditive_of_contraction`, `ssa_of_contraction`,
`mmi_of_contraction`), and `entropy_cyclic5` of
`Novelty.HolographicCyclicInequality` is the instance attached to the cyclic
rule `cyc`.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V]

/-- A contraction map: a Boolean map that does not increase Hamming distance.
Each one encodes a holographic entropy inequality. -/
structure ContractionMap (k m : ℕ) where
  /-- The underlying Boolean recombination rule. -/
  toFun : (Fin k → Bool) → (Fin m → Bool)
  /-- Hamming contraction. -/
  contract : ∀ a b : Fin k → Bool,
    ∑ j, sepBit (toFun a j) (toFun b j) ≤ ∑ i, sepBit (a i) (b i)

variable [DecidableEq V]

/-- **The contraction principle.**  If the boundary patterns of `m` regions
`B j` arise from the boundary patterns of `k` regions `A i` through a
contraction map, then the total entropy of the `B`'s is at most the total
entropy of the `A`'s. -/
theorem entropy_le_of_contraction {k m : ℕ} (M : HoloModel V)
    (A : Fin k → Region V) (B : Fin m → Region V) (χ : ContractionMap k m)
    (hcompat : ∀ v, M.bdry v = true → ∀ j, χ.toFun (fun i => A i v) j = B j v) :
    ∑ j, entropy M (B j) ≤ ∑ i, entropy M (A i) := by
  choose F hF hFval using fun i => exists_minimal_surface M (A i)
  set G : Fin m → Region V := fun j v => χ.toFun (fun i => F i v) j with hG
  have hadm : ∀ j, Admissible M (B j) (G j) := by
    intro j v hv
    show χ.toFun (fun i => F i v) j = B j v
    have : (fun i => F i v) = fun i => A i v := funext fun i => hF i v hv
    rw [this]
    exact hcompat v hv j
  have hcut : ∑ j, cutWeight M.toBulkGraph (G j) ≤ ∑ i, cutWeight M.toBulkGraph (F i) :=
    cutWeight_comb M.toBulkGraph F G (fun u v _ => χ.contract _ _)
  calc ∑ j, entropy M (B j) ≤ ∑ j, cutWeight M.toBulkGraph (G j) :=
        Finset.sum_le_sum fun j _ => entropy_le_of_admissible (hadm j)
    _ ≤ ∑ i, cutWeight M.toBulkGraph (F i) := hcut
    _ = ∑ i, entropy M (A i) := (Finset.sum_congr rfl fun i _ => (hFval i).symm)

/-! ## The classical inequalities as contraction maps -/

/-- Intersection-union: the contraction map behind subadditivity and strong
subadditivity. -/
def interUnionMap : ContractionMap 2 2 where
  toFun a := ![a 0 && a 1, a 0 || a 1]
  contract a b := by
    simp only [Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
    exact sepBit_submodular (a 0) (a 1) (b 0) (b 1)

/-- The minority/union map behind monogamy of mutual information. -/
def minorityMap : ContractionMap 3 4 where
  toFun a := ![a 0 && a 1 && !(a 2), a 0 && a 2 && !(a 1), a 1 && a 2 && !(a 0),
    a 0 || a 1 || a 2]
  contract a b := by
    simp only [Fin.sum_univ_three, Fin.sum_univ_four, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons,
      Matrix.cons_val_three]
    exact sepBit_mmi (a 0) (a 1) (a 2) (b 0) (b 1) (b 2)

/-- The cyclic rule of `Novelty.HolographicCyclicInequality` is a contraction
map from five regions to six. -/
def cyclicMap : ContractionMap 5 6 where
  toFun a := ![cyc (a 0) (a 1) (a 2) (a 3) (a 4), cyc (a 1) (a 2) (a 3) (a 4) (a 0),
    cyc (a 2) (a 3) (a 4) (a 0) (a 1), cyc (a 3) (a 4) (a 0) (a 1) (a 2),
    cyc (a 4) (a 0) (a 1) (a 2) (a 3), a 0 || a 1 || a 2 || a 3 || a 4]
  contract a b := by
    simp only [Fin.sum_univ_five, Fin.sum_univ_six, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons,
      Matrix.cons_val_three, Matrix.cons_val_four]
    exact sepBit_cyclic5 (a 0) (a 1) (a 2) (a 3) (a 4) (b 0) (b 1) (b 2) (b 3) (b 4)

/-- Subadditivity, derived from `interUnionMap`. -/
theorem subadditive_of_contraction (M : HoloModel V) (A B : Region V) :
    entropy M (fun v => A v && B v) + entropy M (fun v => A v || B v)
      ≤ entropy M A + entropy M B := by
  have h := entropy_le_of_contraction M ![A, B]
    ![fun v => A v && B v, fun v => A v || B v] interUnionMap
    (by
      intro v _ j
      fin_cases j <;> simp [interUnionMap])
  simpa [Fin.sum_univ_two] using h

/-- Strong subadditivity, derived from `interUnionMap`. -/
theorem ssa_of_contraction (M : HoloModel V) (A B C : Region V)
    (hAC : ∀ v, A v = true → C v = false) :
    entropy M B + entropy M (fun v => A v || B v || C v)
      ≤ entropy M (fun v => A v || B v) + entropy M (fun v => B v || C v) := by
  have h := entropy_le_of_contraction M
    ![fun v => A v || B v, fun v => B v || C v]
    ![B, fun v => A v || B v || C v] interUnionMap
    (by
      intro v _ j
      have hA := hAC v
      fin_cases j <;>
        simp only [interUnionMap, Matrix.cons_val_zero, Matrix.cons_val_one] <;>
        cases hA' : A v <;> cases hB' : B v <;> cases hC' : C v <;> simp_all)
  simpa [Fin.sum_univ_two] using h

/-- Monogamy of mutual information, derived from `minorityMap`. -/
theorem mmi_of_contraction (M : HoloModel V) (A B C : Region V)
    (hAB : ∀ v, A v = true → B v = false)
    (hBC : ∀ v, B v = true → C v = false)
    (hAC : ∀ v, A v = true → C v = false) :
    entropy M A + entropy M B + entropy M C
        + entropy M (fun v => A v || B v || C v)
      ≤ entropy M (fun v => A v || B v) + entropy M (fun v => B v || C v)
        + entropy M (fun v => A v || C v) := by
  have h := entropy_le_of_contraction M
    ![fun v => A v || B v, fun v => B v || C v, fun v => A v || C v]
    ![B, A, C, fun v => A v || B v || C v] minorityMap
    (by
      intro v _ j
      have h1 := hAB v
      have h2 := hBC v
      have h3 := hAC v
      fin_cases j <;>
        simp only [minorityMap, Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons] <;>
        cases hA' : A v <;> cases hB' : B v <;> cases hC' : C v <;> simp_all)
  simp only [Fin.sum_univ_three, Fin.sum_univ_four, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons,
    Matrix.cons_val_three] at h
  linarith

end EmergentGeometry