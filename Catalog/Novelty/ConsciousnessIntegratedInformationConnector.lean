import Mathlib

/-! # Integrated information as weighted graph connectivity

This self-contained development formalizes a finite-cut core of Integrated
Information Theory (IIT) and proves a cross-domain bridge to weighted graph
connectivity.  Effective information is minimized over nontrivial cuts.  When
effective information is the total interaction weight crossing a cut, strictly
positive integrated information is equivalent to the graph-theoretic condition
that every nontrivial cut carries a positive interaction.
-/

open Finset

namespace IntegratedInformationConnector

variable {n : ℕ}

/-- Nonempty proper subsets, representing nontrivial bipartitions. -/
def parts (n : ℕ) : Finset (Finset (Fin n)) :=
  univ.powerset.filter (fun A => A.Nonempty ∧ A ≠ univ)

@[simp] theorem mem_parts {A : Finset (Fin n)} :
    A ∈ parts n ↔ A.Nonempty ∧ A ≠ univ := by
  simp [parts]

/-- There is a nontrivial bipartition when there are at least two elements. -/
theorem parts_nonempty (h : 2 ≤ n) : (parts n).Nonempty := by
  simp +decide [parts]
  refine' ⟨{⟨0, by omega⟩}, _⟩
  simp +decide
  exact ne_of_apply_ne Finset.card (by simp +decide [Finset.card_univ]; omega)

/-- A finite system together with its nonnegative effective-information value
on each candidate cut. -/
structure System (n : ℕ) where
  ei : Finset (Fin n) → ℝ
  ei_nonneg : ∀ A, 0 ≤ ei A

/-- Integrated information `Φ`, the minimum effective information among all
nontrivial bipartitions. -/
noncomputable def Phi (S : System n) (h : 2 ≤ n) : ℝ :=
  ((parts n).image S.ei).min' ((parts_nonempty h).image S.ei)

/-- `Φ` is no greater than the information of any admissible cut. -/
theorem phi_le_ei (S : System n) (h : 2 ≤ n) {A : Finset (Fin n)}
    (hA : A ∈ parts n) : Phi S h ≤ S.ei A :=
  Finset.min'_le _ _ (Finset.mem_image_of_mem _ hA)

/-- A minimum-information partition exists and realizes `Φ`. -/
theorem exists_minimum_information_partition (S : System n) (h : 2 ≤ n) :
    ∃ A ∈ parts n, S.ei A = Phi S h := by
  convert Finset.mem_image.mp (Finset.min'_mem _ _)

/-- Every common lower bound of cut information is a lower bound of `Φ`. -/
theorem le_phi (S : System n) (h : 2 ≤ n) {c : ℝ}
    (hc : ∀ A ∈ parts n, c ≤ S.ei A) : c ≤ Phi S h := by
  convert Finset.le_min' _ _ _ _
  grind

/-- Integrated information is nonnegative. -/
theorem phi_nonneg (S : System n) (h : 2 ≤ n) : 0 ≤ Phi S h :=
  le_phi S h fun A _ => S.ei_nonneg A

/-- Total directed interaction weight crossing from `A` to its complement. -/
def cutWeight (w : Fin n → Fin n → ℝ) (A : Finset (Fin n)) : ℝ :=
  ∑ i ∈ A, ∑ j ∈ Aᶜ, w i j

/-- Every nontrivial cut has positive crossing interaction.  This is the cut
form of connectivity for the positive-weight directed interaction network. -/
def CutConnected (w : Fin n → Fin n → ℝ) : Prop :=
  ∀ A ∈ parts n, 0 < cutWeight w A

/-- A nonnegative weighted network as an IIT system. -/
def weightedCutSystem (w : Fin n → Fin n → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) : System n where
  ei := cutWeight w
  ei_nonneg A := by
    simp only [cutWeight]
    exact sum_nonneg fun i _ => sum_nonneg fun j _ => hw i j

/-- **IIT–graph connectivity bridge.**  For a nonnegative weighted interaction
network on at least two vertices, integrated information is strictly positive
if and only if every nontrivial cut has positive crossing interaction. -/
theorem phi_weightedCutSystem_pos_iff_cutConnected
    (w : Fin n → Fin n → ℝ) (hw : ∀ i j, 0 ≤ w i j) (h : 2 ≤ n) :
    0 < Phi (weightedCutSystem w hw) h ↔ CutConnected w := by
  constructor
  · intro hPhi A hA
    exact lt_of_lt_of_le hPhi (phi_le_ei (weightedCutSystem w hw) h hA)
  · intro hcuts
    obtain ⟨A, hA, hmin⟩ :=
      exists_minimum_information_partition (weightedCutSystem w hw) h
    rw [← hmin]
    exact hcuts A hA

/-- Pointwise multiplicative approximation of all cut values transfers to
integrated information.  Thus any efficiently computable cut surrogate with
factor `c` gives the same factor approximation to `Φ`. -/
theorem phi_multiplicative_approximation
    (S T : System n) (h : 2 ≤ n) (c : ℝ)
    (hLower : ∀ A ∈ parts n, S.ei A ≤ T.ei A)
    (hUpper : ∀ A ∈ parts n, T.ei A ≤ c * S.ei A) :
    Phi S h ≤ Phi T h ∧ Phi T h ≤ c * Phi S h := by
  constructor
  · obtain ⟨A, hA, hmin⟩ := exists_minimum_information_partition T h
    rw [← hmin]
    exact (phi_le_ei S h hA).trans (hLower A hA)
  · obtain ⟨A, hA, hmin⟩ := exists_minimum_information_partition S h
    rw [← hmin]
    exact (phi_le_ei T h hA).trans (hUpper A hA)

end IntegratedInformationConnector