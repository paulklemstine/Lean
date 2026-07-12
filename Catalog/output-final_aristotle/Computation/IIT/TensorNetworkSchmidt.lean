import Mathlib

/-! # Single-Cut Integrated Information of a Bipartite Pure State

For a bipartite pure state written through its coefficient matrix
`M : Matrix (Fin D) (Fin D) ℂ`, the **Schmidt rank** across the cut is exactly the
matrix rank of `M`, and the single-cut integrated information of Tononi's
Integrated Information Theory is one less than the Schmidt rank:

  `phiBip M := M.rank - 1`.

A product state has Schmidt rank `1` and hence `phiBip = 0` (no integration across
the cut), while a **maximally entangled** state — coefficient matrix the identity
`1 : Matrix (Fin D) (Fin D) ℂ` — has full Schmidt rank `D`, giving the maximal
single-cut value `phiBip = D - 1`.

## Main definitions and results

* `phiBip M` — single-cut integrated information `M.rank - 1`.
* `phi_maximallyEntangled_eq` — the maximally entangled identity coefficient
  matrix attains `phiBip = D - 1`.
* `phiBip_le_bond` — the Schmidt rank, hence `phiBip`, is capped by the bond
  dimension.
* `phiBip_eq_zero_of_rank_one` — a product state (Schmidt rank one) is reducible.
-/

open Matrix

namespace IIT.TensorNetwork

variable {D : ℕ}

/-- **Single-cut integrated information** of a bipartite pure state with
coefficient matrix `M`: one less than the Schmidt rank (`= M.rank`). -/
noncomputable def phiBip (M : Matrix (Fin D) (Fin D) ℂ) : ℕ := M.rank - 1

/-- The **maximally entangled** state, whose coefficient matrix is the identity,
has full Schmidt rank `D`, so its single-cut integrated information is `D - 1` —
the largest value available at bond dimension `D`. -/
theorem phi_maximallyEntangled_eq :
    phiBip (1 : Matrix (Fin D) (Fin D) ℂ) = D - 1 := by
  unfold phiBip
  rw [Matrix.rank_one, Fintype.card_fin]

/-- The Schmidt rank of a `D × D` coefficient matrix never exceeds the bond
dimension `D`, so the single-cut integrated information is capped by `D - 1`. -/
theorem phiBip_le_bond (M : Matrix (Fin D) (Fin D) ℂ) : phiBip M ≤ D - 1 := by
  unfold phiBip
  have h : M.rank ≤ D := by
    have := M.rank_le_card_width
    simpa using this
  omega

/-- A **product state** across the cut (Schmidt rank one) is reducible:
its single-cut integrated information vanishes. -/
theorem phiBip_eq_zero_of_rank_one {M : Matrix (Fin D) (Fin D) ℂ}
    (h : M.rank = 1) : phiBip M = 0 := by
  unfold phiBip
  omega

end IIT.TensorNetwork