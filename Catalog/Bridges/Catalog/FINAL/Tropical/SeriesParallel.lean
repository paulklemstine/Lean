/-
# Series-Parallel Networks and Boundary Rigidity

This file formalizes two-terminal series-parallel (SP) networks, their boundary
distance (shortest-path metric between terminals), and proves that SP-equivalence
preserves boundary distance.

## Mathematical content

A two-terminal series-parallel network is built inductively:
- **Base**: a single edge with positive weight w
- **Series**: connect two networks end-to-end (distances add)
- **Parallel**: connect two networks between the same terminals (distances take min)

The boundary distance is computed recursively and is precisely a tropical
polynomial evaluation: series = tropical multiplication, parallel = tropical addition.

## Key results
- `spDist_series`: distance of series composition is sum of distances
- `spDist_parallel`: distance of parallel composition is min of distances
- `sp_canonical_reduce`: every SP network reduces to a single equivalent edge
- `sp_boundary_rigid`: boundary rigidity theorem
-/
import Mathlib
import Tropical.Defs

open TropicalLib

namespace SeriesParallel

/-! ## Inductive definition of two-terminal SP networks -/

/-- A two-terminal series-parallel network. -/
inductive SPNet where
  | edge (w : ℝ) (hw : 0 < w) : SPNet
  | series (N₁ N₂ : SPNet) : SPNet
  | parallel (N₁ N₂ : SPNet) : SPNet

/-! ## Boundary distance -/

/-- The boundary distance of an SP network. -/
noncomputable def spDist : SPNet → ℝ
  | .edge w _ => w
  | .series N₁ N₂ => spDist N₁ + spDist N₂
  | .parallel N₁ N₂ => min (spDist N₁) (spDist N₂)

/-
Boundary distance is always positive.
-/
theorem spDist_pos (N : SPNet) : 0 < spDist N := by
  induction N with
  | edge w hw => exact hw
  | series N₁ N₂ ih₁ ih₂ => exact add_pos ih₁ ih₂
  | parallel N₁ N₂ ih₁ ih₂ => exact lt_min ih₁ ih₂

theorem spDist_series (N₁ N₂ : SPNet) :
    spDist (.series N₁ N₂) = spDist N₁ + spDist N₂ := rfl

theorem spDist_parallel (N₁ N₂ : SPNet) :
    spDist (.parallel N₁ N₂) = min (spDist N₁) (spDist N₂) := rfl

/-! ## Tropical interpretation -/

theorem spDist_tropical_series (N₁ N₂ : SPNet) :
    spDist (.series N₁ N₂) = tropicalMul (spDist N₁) (spDist N₂) := by
  simp [spDist, tropicalMul]

theorem spDist_tropical_parallel (N₁ N₂ : SPNet) :
    spDist (.parallel N₁ N₂) = tropicalAdd (spDist N₁) (spDist N₂) := by
  simp [spDist, tropicalAdd]

/-! ## SP-equivalence -/

/-- Two SP networks are SP-equivalent if they have the same boundary distance. -/
def SPEquiv (N₁ N₂ : SPNet) : Prop := spDist N₁ = spDist N₂

theorem spEquiv_refl (N : SPNet) : SPEquiv N N := rfl
theorem spEquiv_symm {N₁ N₂ : SPNet} (h : SPEquiv N₁ N₂) : SPEquiv N₂ N₁ := h.symm
theorem spEquiv_trans {N₁ N₂ N₃ : SPNet} (h₁ : SPEquiv N₁ N₂) (h₂ : SPEquiv N₂ N₃) :
    SPEquiv N₁ N₃ := Eq.trans h₁ h₂

/-! ## Reduction rules -/

theorem series_edge_reduce (w₁ w₂ : ℝ) (hw₁ : 0 < w₁) (hw₂ : 0 < w₂) :
    SPEquiv (.series (.edge w₁ hw₁) (.edge w₂ hw₂))
            (.edge (w₁ + w₂) (by linarith)) := by
  simp [SPEquiv, spDist]

theorem parallel_edge_reduce (w₁ w₂ : ℝ) (hw₁ : 0 < w₁) (hw₂ : 0 < w₂) :
    SPEquiv (.parallel (.edge w₁ hw₁) (.edge w₂ hw₂))
            (.edge (min w₁ w₂) (by exact lt_min hw₁ hw₂)) := by
  simp [SPEquiv, spDist]

theorem series_congr {N₁ N₁' N₂ N₂' : SPNet}
    (h₁ : SPEquiv N₁ N₁') (h₂ : SPEquiv N₂ N₂') :
    SPEquiv (.series N₁ N₂) (.series N₁' N₂') := by
  unfold SPEquiv at *; simp [spDist, h₁, h₂]

theorem parallel_congr {N₁ N₁' N₂ N₂' : SPNet}
    (h₁ : SPEquiv N₁ N₁') (h₂ : SPEquiv N₂ N₂') :
    SPEquiv (.parallel N₁ N₂) (.parallel N₁' N₂') := by
  unfold SPEquiv at *; simp [spDist, h₁, h₂]

/-! ## Canonical reduced form -/

/-
Every SP network reduces to a single edge with the same boundary distance.
-/
theorem sp_canonical_reduce (N : SPNet) :
    ∃ w : ℝ, ∃ hw : 0 < w, SPEquiv N (.edge w hw) := by
  exact ⟨ spDist N, spDist_pos N, rfl ⟩

/-! ## Boundary rigidity -/

/-- Boundary rigidity for two-terminal SP networks. -/
theorem sp_boundary_rigid (N₁ N₂ : SPNet) (h : spDist N₁ = spDist N₂) :
    SPEquiv N₁ N₂ := h

theorem sp_equiv_implies_same_dist (N₁ N₂ : SPNet) (h : SPEquiv N₁ N₂) :
    spDist N₁ = spDist N₂ := h

/-! ## Algebraic laws -/

theorem series_assoc (N₁ N₂ N₃ : SPNet) :
    SPEquiv (.series (.series N₁ N₂) N₃) (.series N₁ (.series N₂ N₃)) := by
  simp [SPEquiv, spDist, add_assoc]

theorem parallel_assoc (N₁ N₂ N₃ : SPNet) :
    SPEquiv (.parallel (.parallel N₁ N₂) N₃) (.parallel N₁ (.parallel N₂ N₃)) := by
  simp [SPEquiv, spDist, min_assoc]

theorem parallel_comm (N₁ N₂ : SPNet) :
    SPEquiv (.parallel N₁ N₂) (.parallel N₂ N₁) := by
  simp [SPEquiv, spDist, min_comm]

theorem series_comm (N₁ N₂ : SPNet) :
    SPEquiv (.series N₁ N₂) (.series N₂ N₁) := by
  simp [SPEquiv, spDist, add_comm]

theorem parallel_idem (N : SPNet) :
    SPEquiv (.parallel N N) N := by
  simp [SPEquiv, spDist]

/-- Distributivity: series over parallel (left). -/
theorem series_parallel_distrib_left (N₁ N₂ N₃ : SPNet) :
    spDist (.series N₁ (.parallel N₂ N₃)) =
    min (spDist (.series N₁ N₂)) (spDist (.series N₁ N₃)) := by
  simp [spDist, min_add_add_left]

/-- Distributivity: series over parallel (right). -/
theorem series_parallel_distrib_right (N₁ N₂ N₃ : SPNet) :
    spDist (.series (.parallel N₁ N₂) N₃) =
    min (spDist (.series N₁ N₃)) (spDist (.series N₂ N₃)) := by
  simp [spDist, min_add_add_right]

/-! ## Depth and size -/

def spDepth : SPNet → ℕ
  | .edge _ _ => 0
  | .series N₁ N₂ => max (spDepth N₁) (spDepth N₂) + 1
  | .parallel N₁ N₂ => max (spDepth N₁) (spDepth N₂) + 1

def spSize : SPNet → ℕ
  | .edge _ _ => 1
  | .series N₁ N₂ => spSize N₁ + spSize N₂
  | .parallel N₁ N₂ => spSize N₁ + spSize N₂

noncomputable def spMaxWeight : SPNet → ℝ
  | .edge w _ => w
  | .series N₁ N₂ => max (spMaxWeight N₁) (spMaxWeight N₂)
  | .parallel N₁ N₂ => max (spMaxWeight N₁) (spMaxWeight N₂)

noncomputable def spMinWeight : SPNet → ℝ
  | .edge w _ => w
  | .series N₁ N₂ => min (spMinWeight N₁) (spMinWeight N₂)
  | .parallel N₁ N₂ => min (spMinWeight N₁) (spMinWeight N₂)

theorem spMinWeight_pos (N : SPNet) : 0 < spMinWeight N := by
  induction N <;> simp_all +decide [ spMinWeight ]

end SeriesParallel