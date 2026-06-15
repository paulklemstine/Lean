/-
# The Boltzmann Bridge II — Higher-Dimensional Persistent Homology on Simplicial Complexes

This file extends the catalog's 0-dimensional persistence machinery (cf.
`Catalog/Applications/PoincareData/SimplicialComplex.lean`, which formalizes
`AbstractSimplicialComplex`, the Vietoris–Rips construction, and `vr_mono`) to a
general **filtration calculus** on abstract simplicial complexes, suitable for
persistent homology in arbitrary dimension.

The core idea of persistent homology is that a finite metric/weighted data set
gives rise to a one-parameter *nested family* of simplicial complexes (a
filtration), and the topological features that persist across a wide range of
the parameter encode the true shape of the data.  Here we develop the abstract
backbone of that theory:

* a **sublevel-set filtration** attached to any monotone weight function on
  simplices, together with the proof that each sublevel set is a genuine
  abstract simplicial complex and that the family is nested (monotone);
* the **Vietoris–Rips filtration** as the canonical example, recovered as the
  sublevel filtration of the *diameter* weight, with an explicit
  characterization of the *birth time* of a simplex (the persistence-theoretic
  heart of the construction);
* the **Euler characteristic of the full simplex**, proved via the alternating
  binomial identity — the simplest nonzero higher-dimensional invariant, and the
  combinatorial shadow of the contractibility of a simplex.

## Main results

* `Filtration.sublevelComplex` — sublevel set of a monotone weight is an ASC
* `Filtration.sublevel_mono` — the sublevel family is nested in the parameter
* `vr_mem_iff_diam_le` — VR complex = sublevel set of the diameter weight
* `vr_mono` — the Vietoris–Rips filtration is nested in the scale
* `euler_char_full_simplex` — Euler characteristic of the full (n−1)-simplex is 1
-/
import Mathlib

open Finset BigOperators

namespace BoltzmannBridge

/-! ## Abstract simplicial complexes -/

/-- An abstract simplicial complex on a vertex type `α`: a downward-closed
family of finite subsets (faces). -/
structure ASC (α : Type*) where
  faces : Set (Finset α)
  empty_mem : ∅ ∈ faces
  down_closed : ∀ {σ τ : Finset α}, σ ∈ faces → τ ⊆ σ → τ ∈ faces

namespace ASC

variable {α : Type*}

/-- Containment of complexes: `K ⊑ L` means every face of `K` is a face of `L`. -/
def Sub (K L : ASC α) : Prop := K.faces ⊆ L.faces

end ASC

/-! ## Sublevel-set filtrations from a monotone weight -/

/-- A monotone weight function on finite subsets: a "filtration value" assigning
each simplex the scale at which it is born.  Monotonicity (a face is born no
later than any simplex containing it) is exactly what makes the sublevel sets
downward closed. -/
structure Filtration (α : Type*) where
  weight : Finset α → ℝ
  weight_empty : weight ∅ ≤ 0
  weight_mono : ∀ {σ τ : Finset α}, σ ⊆ τ → weight σ ≤ weight τ

namespace Filtration

variable {α : Type*}

/-- The set of simplices alive at scale `t`. -/
def sublevelFaces (F : Filtration α) (t : ℝ) : Set (Finset α) :=
  {σ | F.weight σ ≤ t}

/-- A simplex belongs to the scale-`t` sublevel complex iff its weight is `≤ t`. -/
@[simp] theorem mem_sublevelFaces (F : Filtration α) (t : ℝ) (σ : Finset α) :
    σ ∈ F.sublevelFaces t ↔ F.weight σ ≤ t := Iff.rfl

-- !-- The empty face is born by `t ≥ 0` and `weight ∅ ≤ 0`; downward closure is
-- !-- immediate from `weight_mono`: a subface has no larger weight. -- !--
/-- The sublevel set of a monotone weight at scale `t` is an abstract simplicial
complex (provided `t ≥ 0`, so the empty simplex is born). -/
def sublevelComplex (F : Filtration α) (t : ℝ) (ht : 0 ≤ t) : ASC α where
  faces := F.sublevelFaces t
  empty_mem := by
    exact le_trans F.weight_empty ht
  down_closed := by
    exact fun { σ τ } hσ hτσ => F.weight_mono hτσ |> le_trans <| hσ

-- !-- A simplex of weight `≤ t₁ ≤ t₂` still has weight `≤ t₂`; pure transitivity. -- !--
/-- **Filtration monotonicity.**  The sublevel family is nested in the scale
parameter: increasing the scale can only add simplices. -/
theorem sublevel_mono (F : Filtration α) {t₁ t₂ : ℝ} (h : t₁ ≤ t₂) :
    F.sublevelFaces t₁ ⊆ F.sublevelFaces t₂ := by
  exact fun x hx => le_trans hx.out h

end Filtration

/-! ## The Vietoris–Rips filtration -/

section VR

variable {α : Type*} [PseudoMetricSpace α]

/-- The **diameter weight** of a finite simplex: the largest pairwise distance
among its vertices, or `0` when there are no pairs (the empty simplex and
singletons). -/
noncomputable def diamWeight (σ : Finset α) : ℝ :=
  (insert (0 : ℝ) ((σ ×ˢ σ).image (fun p => dist p.1 p.2))).sup' (insert_nonempty _ _) id

-- !-- Empty product gives `sup' {0} = 0`; monotonicity holds since `σ ⊆ τ` makes
-- !-- every pairwise distance of `σ` one of the distances summed over `τ`. -- !--
/-- The diameter weight, packaged as a `Filtration`. -/
noncomputable def diamFiltration : Filtration α where
  weight := diamWeight
  weight_empty := by
    unfold diamWeight; simp +decide ;
  weight_mono := by
    intro σ τ hστ
    unfold diamWeight
    apply Finset.sup'_le
    intro x hx
    have h_dist : x ∈ insert (0 : ℝ) ((τ ×ˢ τ).image (fun p => dist p.1 p.2)) := by
      simp +zetaDelta at *;
      exact hx.imp id fun ⟨ a, b, h, hx ⟩ => ⟨ a, b, ⟨ hστ h.1, hστ h.2 ⟩, hx ⟩
    exact (by
    exact Finset.le_sup' ( fun p => id p ) h_dist)

/-- The Vietoris–Rips faces at scale `ε`: simplices of diameter `≤ ε`. -/
def VRfaces (ε : ℝ) : Set (Finset α) :=
  {σ | ∀ x ∈ σ, ∀ y ∈ σ, dist x y ≤ ε}

/-- **A simplex is a VR face at scale `ε` iff every pairwise distance is `≤ ε`.**
Recorded for use as a simp lemma. -/
@[simp] theorem mem_VRfaces (ε : ℝ) (σ : Finset α) :
    σ ∈ VRfaces ε ↔ ∀ x ∈ σ, ∀ y ∈ σ, dist x y ≤ ε := Iff.rfl

-- !-- Every pairwise distance `≤ ε₁ ≤ ε₂`, so a face survives the larger scale. -- !--
/-- **VR monotonicity** (re-proved at this level of generality). -/
theorem vr_mono {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    (VRfaces ε₁ : Set (Finset α)) ⊆ VRfaces ε₂ := by
  exact fun σ hσ x hx y hy => le_trans ( hσ x hx y hy ) h

-- !-- A singleton's only pair is `(x, x)` with `dist x x = 0 ≤ ε`. -- !--
/-- Singletons are VR faces at every nonnegative scale. -/
theorem vr_singleton_mem {ε : ℝ} (hε : 0 ≤ ε) (x : α) :
    ({x} : Finset α) ∈ VRfaces ε := by
  intro y hy z hz; aesop;

-- !-- `diamWeight σ ≤ ε` unfolds, via `Finset.sup'_le_iff`, to: `0 ≤ ε` and every
-- !-- pairwise distance `≤ ε` — exactly the VR membership condition. -- !--
/-- **VR = sublevel set of the diameter weight.**  This identifies the geometric
Vietoris–Rips filtration with the abstract sublevel filtration, the bridge
between the metric and combinatorial pictures of persistence. -/
theorem vr_mem_iff_diam_le (ε : ℝ) (σ : Finset α) (hε : 0 ≤ ε) :
    σ ∈ VRfaces ε ↔ diamWeight σ ≤ ε := by
  unfold VRfaces diamWeight;
  simp +decide [ Finset.sup'_le_iff ];
  grind

end VR

/-! ## Euler characteristic of the full simplex -/

-- !-- From `∑_{m=0}^{n} (-1)^m C(n,m) = 0` (the alternating binomial identity for
-- !-- `n ≥ 1`), split off the `m=0` term and reindex to get the value `1`. -- !--
/-- **Euler characteristic of the full (n−1)-simplex.**  Summing the contribution
`(-1)^(k-1)` of each `k`-dimensional face (there are `C(n,k)` faces with `k`
vertices) over all nonempty faces of the full simplex on `n` vertices gives `1`.
This is the combinatorial shadow of the contractibility of a simplex, and the
basic nonzero invariant of higher-dimensional persistent homology. -/
theorem euler_char_full_simplex (n : ℕ) (hn : 1 ≤ n) :
    ∑ k ∈ Finset.Icc 1 n, ((-1 : ℤ)) ^ (k - 1) * (n.choose k : ℤ) = 1 := by
  have := @Int.alternating_sum_range_choose n;
  erw [ Finset.sum_Ico_eq_sub _ _ ] <;> norm_num [ this, Finset.sum_range_succ' ];
  simp_all +decide [ Finset.sum_range_succ', pow_succ', mul_comm ];
  bv_omega

end BoltzmannBridge