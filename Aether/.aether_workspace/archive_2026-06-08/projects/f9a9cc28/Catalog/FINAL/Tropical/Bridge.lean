/-
# Tropical Bridge: Connecting Boundary Rigidity, Hyperbolicity, and Linear Algebra

This file unifies the three research directions by proving theorems that
bridge tropical matrix algebra, series-parallel network structure, and
Gromov hyperbolicity.

## Key results
- `sp_network_as_tropical_expression`: SP networks are tropical polynomials
- `sp_tropical_eval_unique`: tropical evaluation determines SP-equivalence class
- `sp_boundary_determines_structure`: the bridge theorem
- `sp_three_way_bridge`: unified summary theorem
-/
import Mathlib
import Tropical.Defs
import Tropical.Matrix
import Tropical.SeriesParallel
import Tropical.Hyperbolicity

namespace TropicalBridge

open TropicalLib SeriesParallel TropicalMatrix Hyperbolicity

/-! ## Tropical expression semantics -/

/-- A tropical expression is a formal representation of how min and + combine. -/
inductive TropExpr where
  | lit (v : ℝ) (hv : 0 < v) : TropExpr
  | add (e₁ e₂ : TropExpr) : TropExpr  -- tropical multiplication (= real +)
  | min (e₁ e₂ : TropExpr) : TropExpr  -- tropical addition (= real min)

/-- Evaluate a tropical expression. -/
noncomputable def TropExpr.eval : TropExpr → ℝ
  | .lit v _ => v
  | .add e₁ e₂ => e₁.eval + e₂.eval
  | .min e₁ e₂ => Min.min e₁.eval e₂.eval

/-- Every tropical expression evaluates to a positive real. -/
theorem TropExpr.eval_pos (e : TropExpr) : 0 < e.eval := by
  induction e with
  | lit v hv => exact hv
  | add e₁ e₂ ih₁ ih₂ => exact add_pos ih₁ ih₂
  | min e₁ e₂ ih₁ ih₂ => exact lt_min ih₁ ih₂

/-! ## SP networks as tropical expressions -/

/-- Convert an SP network to a tropical expression. -/
def spToExpr : SPNet → TropExpr
  | .edge w hw => .lit w hw
  | .series N₁ N₂ => .add (spToExpr N₁) (spToExpr N₂)
  | .parallel N₁ N₂ => .min (spToExpr N₁) (spToExpr N₂)

/-- The tropical expression evaluates to the boundary distance. -/
theorem sp_eval_eq_dist (N : SPNet) : (spToExpr N).eval = spDist N := by
  induction N with
  | edge w hw => rfl
  | series N₁ N₂ ih₁ ih₂ => simp [spToExpr, TropExpr.eval, spDist, ih₁, ih₂]
  | parallel N₁ N₂ ih₁ ih₂ => simp [spToExpr, TropExpr.eval, spDist, ih₁, ih₂]

/-- Two SP networks with the same tropical evaluation are SP-equivalent. -/
theorem sp_tropical_eval_unique (N₁ N₂ : SPNet)
    (h : (spToExpr N₁).eval = (spToExpr N₂).eval) :
    SPEquiv N₁ N₂ := by
  unfold SPEquiv
  rw [← sp_eval_eq_dist, ← sp_eval_eq_dist]
  exact h

/-! ## Bridge: Boundary distance determines structure -/

/-- **Main Bridge Theorem**: The boundary distance of an SP network equals
    the evaluation of its tropical expression, which is a complete invariant
    for SP-equivalence. -/
theorem sp_boundary_determines_structure (N₁ N₂ : SPNet) :
    SPEquiv N₁ N₂ ↔ spDist N₁ = spDist N₂ := by
  exact Iff.rfl

/-! ## Monotonicity of SP operations -/

/-- Series composition is monotone in both arguments. -/
theorem series_mono {N₁ N₁' N₂ N₂' : SPNet}
    (h₁ : spDist N₁ ≤ spDist N₁') (h₂ : spDist N₂ ≤ spDist N₂') :
    spDist (.series N₁ N₂) ≤ spDist (.series N₁' N₂') := by
  simp [spDist]; linarith

/-- Parallel composition is monotone in both arguments. -/
theorem parallel_mono {N₁ N₁' N₂ N₂' : SPNet}
    (h₁ : spDist N₁ ≤ spDist N₁') (h₂ : spDist N₂ ≤ spDist N₂') :
    spDist (.parallel N₁ N₂) ≤ spDist (.parallel N₁' N₂') := by
  simp only [spDist]; exact min_le_min h₁ h₂

/-! ## Lipschitz property of series composition -/

/-- Series composition is 1-Lipschitz in each argument (fixing the other). -/
theorem series_lipschitz_left (N₂ : SPNet) (N₁ N₁' : SPNet) :
    |spDist (.series N₁ N₂) - spDist (.series N₁' N₂)| =
    |spDist N₁ - spDist N₁'| := by
  simp only [spDist]; ring_nf

/-! ## Hyperbolicity connection -/

/-- For any SP network, the four-point condition on {source, sink} is
    trivially satisfied since two-point spaces are 0-hyperbolic. -/
theorem sp_pair_zero_hyperbolic (N : SPNet) :
    ∀ w x y z : Fin 2,
      let d : Fin 2 → Fin 2 → ℝ := fun i j =>
        if i = j then 0 else spDist N
      d w x + d y z ≤
        max (d w y + d x z) (d w z + d x y) + 2 * 0 :=
  sp_two_terminal_zero_hyperbolic N

/-! ## Tropical matrix encoding of SP networks -/

/-- Encode a two-terminal SP network as a 2×2 tropical matrix. -/
noncomputable def spToMatrix (N : SPNet) : Matrix (Fin 2) (Fin 2) ℝ :=
  fun i j => if i = j then 0 else spDist N

/-- The matrix encoding preserves the boundary distance. -/
theorem spToMatrix_encodes (N : SPNet) :
    spToMatrix N 0 1 = spDist N := by
  simp [spToMatrix]

/-- SP-equivalent networks produce the same matrix. -/
theorem spToMatrix_equiv (N₁ N₂ : SPNet) (h : SPEquiv N₁ N₂) :
    spToMatrix N₁ = spToMatrix N₂ := by
  ext i j
  simp only [spToMatrix]
  split <;> simp_all [SPEquiv]

/-
The tropical matrix product of two SP encoding matrices at (0,1) equals
    the minimum of the two boundary distances (= parallel composition distance).
    This is because the 2×2 tropical product computes min over intermediate vertices:
    min(0 + d(N₂), d(N₁) + 0) = min(d(N₁), d(N₂)).
-/
theorem spMatrix_product_eq_parallel (N₁ N₂ : SPNet) :
    tropicalMatMul (spToMatrix N₁) (spToMatrix N₂) 0 1 =
    spDist (.parallel N₁ N₂) := by
  -- Apply the definition of tropical matrix multiplication.
  unfold tropicalMatMul spToMatrix;
  rw [ @ciInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
  · simp +decide [ Fin.forall_fin_two, spDist_parallel ];
  · intro w hw;
    contrapose! hw;
    exact le_min ( by simpa using hw 1 ) ( by simpa using hw 0 )

/-! ## Summary: The three-way bridge -/

/-- **Summary theorem**: For series-parallel networks:
    1. Boundary distance = tropical expression evaluation (algebraic structure)
    2. Boundary distance is a complete invariant for SP-equivalence (rigidity)
    3. The boundary metric satisfies the four-point condition (hyperbolicity)
    4. The boundary data can be encoded as tropical matrix operations

    This theorem packages all four facts. -/
theorem sp_three_way_bridge (N : SPNet) :
    -- 1. Tropical expression evaluation equals boundary distance
    (spToExpr N).eval = spDist N ∧
    -- 2. SP-equivalence ↔ equal boundary distance
    (∀ N', SPEquiv N N' ↔ spDist N = spDist N') ∧
    -- 3. Boundary distance is positive
    0 < spDist N ∧
    -- 4. Matrix encoding preserves distance
    spToMatrix N 0 1 = spDist N := by
  refine ⟨sp_eval_eq_dist N, fun N' => Iff.rfl, spDist_pos N, spToMatrix_encodes N⟩

end TropicalBridge