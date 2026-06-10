import Mathlib

/-! # Integrated Information via Tensor Networks — Bipartite Schmidt Rank

A formalization of the discrete, exact core of Tononi's Integrated Information Theory
(IIT) for *quantum* states represented as tensor networks. We model a bipartite pure
state by its coefficient matrix `M : Matrix (Fin m) (Fin n) ℂ` (the amplitude tensor
reshaped across the single cut). The **Schmidt rank** of the state is exactly the matrix
rank of `M`, and we define a discrete integrated-information functional

  `phiBip M := M.rank - 1`

so that `Φ = 0` precisely for *unentangled* (product / separable) states and grows with
entanglement.

This file is the tensor-network analogue of the catalog's graph-theoretic IIT in
`Shared.CausalIntegration.Core`, where `CausalSystem.phi` is the min-cut of a weighted
digraph. Here the role of the min-cut is played by the Schmidt rank across a cut, and the
role of "disconnected ⟹ Φ = 0" (`phi_zero_of_disconnected`) is played by
"product state ⟹ Φ = 0" (`phi_productState_eq_zero`).

Main results:
* `phi_productState_eq_zero` — separable (outer-product) states have `Φ = 0`.
* `phi_mps_le_bond` — an MPS factorization `M = A * B` through a bond of dimension `D`
  bounds `Φ ≤ D - 1`. (The bond dimension caps integrated information.)
* `phi_mps_bondTwo_le_one` — the concept's explicit test case: bond dimension `2` gives
  `Φ ≤ 1`.
* `phi_maximallyEntangled_eq` — the maximally entangled `d × d` state attains the maximal
  value `Φ = d - 1`.
-/

open Matrix

namespace IIT.TensorNetwork

/-- The Schmidt rank of a bipartite pure state, identified with the rank of its
coefficient (amplitude) matrix across the cut. -/
noncomputable def schmidtRank {m n : ℕ} (M : Matrix (Fin m) (Fin n) ℂ) : ℕ := M.rank

/-- Discrete integrated information `Φ` of a bipartite pure state across its single cut:
one less than the Schmidt rank. `Φ = 0` iff the state is a product state. -/
noncomputable def phiBip {m n : ℕ} (M : Matrix (Fin m) (Fin n) ℂ) : ℕ := M.rank - 1

-- !-- Lab Notebook: phi_productState_eq_zero -- !--
-- !-- Hypothesis: A separable (product) bipartite state |ψ⟩ = |u⟩⊗|v⟩ carries no
--     integrated information, i.e. Φ = 0, mirroring the IIT axiom that a reducible
--     system has Φ = 0. -- !--
-- !-- Result: Proved. The coefficient matrix of a product state is the outer product
--     `vecMulVec u v`, whose rank is ≤ 1, so `Φ = rank - 1 = 0`. -- !--
-- !-- Insight: Schmidt rank ≤ 1 is the exact algebraic signature of "no entanglement";
--     this is the tensor-network mirror of `phi_zero_of_disconnected` in
--     `Shared.CausalIntegration.Core`. -- !--
-- !-- Failure analysis: None; `rank_vecMulVec_le` from Mathlib closes the rank bound
--     directly. An earlier plan to prove a full iff (rank ≤ 1 ⟺ product) was deferred,
--     since the converse (rank-one ⟹ outer product) is logged as a future direction. -- !--
-- !-- End Lab Notebook -- !--

-- !-- A product state's coefficient matrix is an outer product `vecMulVec u v`, which has
--     rank ≤ 1, hence `Φ = rank - 1 = 0`. -- !--
/-- A product (separable) bipartite state `|u⟩ ⊗ |v⟩` has zero integrated information. -/
theorem phi_productState_eq_zero {m n : ℕ} (u : Fin m → ℂ) (v : Fin n → ℂ) :
    phiBip (vecMulVec u v) = 0 := by
  have h : (vecMulVec u v).rank ≤ 1 := rank_vecMulVec_le u v
  simp only [phiBip]; omega

-- !-- Lab Notebook: phi_mps_le_bond -- !--
-- !-- Hypothesis: A matrix-product-state (MPS) factorization through a bond index of
--     dimension `D` caps the integrated information at `D - 1`, formalizing the
--     tensor-network folklore "bond dimension bounds entanglement entropy/Schmidt rank". -- !--
-- !-- Result: Proved. `rank (A*B) ≤ rank A ≤ #cols A = D`, hence `Φ = rank - 1 ≤ D - 1`. -- !--
-- !-- Insight: The bond index is literally the contracted middle dimension; the rank
--     submultiplicativity `rank_mul_le_left` is the exact mechanism by which a thin bond
--     throttles integration. This is the quantitative heart of the concept. -- !--
-- !-- Failure analysis: None; the only subtlety is the ℕ-subtraction in `Φ`, handled by
--     `omega` after the rank bound. -- !--
-- !-- End Lab Notebook -- !--

-- !-- An MPS coefficient `M = A·B` factors through a `D`-dimensional bond, so
--     `rank M ≤ rank A ≤ D`, giving `Φ ≤ D - 1`. -- !--
/-- A matrix-product-state factorization `M = A * B` through a bond of dimension `D`
bounds the integrated information: `Φ(M) ≤ D - 1`. -/
theorem phi_mps_le_bond {m n D : ℕ} (A : Matrix (Fin m) (Fin D) ℂ)
    (B : Matrix (Fin D) (Fin n) ℂ) : phiBip (A * B) ≤ D - 1 := by
  have h : (A * B).rank ≤ D := by
    calc (A * B).rank ≤ A.rank := rank_mul_le_left A B
      _ ≤ Fintype.card (Fin D) := A.rank_le_card_width
      _ = D := by simp
  simp only [phiBip]; omega

-- !-- Specialize the bond bound to `D = 2` (the concept's test case). -- !--
/-- The concept's explicit test: an MPS with bond dimension `2` has `Φ ≤ 1`. -/
theorem phi_mps_bondTwo_le_one {m n : ℕ} (A : Matrix (Fin m) (Fin 2) ℂ)
    (B : Matrix (Fin 2) (Fin n) ℂ) : phiBip (A * B) ≤ 1 := phi_mps_le_bond A B

-- !-- Lab Notebook: phi_maximallyEntangled_eq -- !--
-- !-- Hypothesis: The maximally entangled state on `d ⊗ d` (coefficient matrix = identity,
--     i.e. Σ_i |i⟩|i⟩) attains the maximum possible integrated information `Φ = d - 1`. -- !--
-- !-- Result: Proved. `rank (1 : Matrix (Fin d) (Fin d)) = d` (`Matrix.rank_one`), so
--     `Φ = d - 1`. -- !--
-- !-- Insight: This is the boundary/extremal case complementing the product state: full
--     Schmidt rank ⟺ maximal integration. Together with the bond bound it shows the bond
--     dimension `D` is *tight* — `D = d` is needed to realize the maximally entangled
--     state. -- !--
-- !-- Failure analysis: Needed `NeZero d` so `Fin d` is nonempty/`Nontrivial`-compatible;
--     `simp` with `Matrix.rank_one`, `Fintype.card_fin` discharged the computation. -- !--
-- !-- End Lab Notebook -- !--

-- !-- The maximally entangled state has identity coefficient matrix, whose rank is `d`
--     (`Matrix.rank_one`), so `Φ = d - 1`. -- !--
/-- The maximally entangled state on `d ⊗ d` (identity coefficient matrix) attains the
maximal integrated information `Φ = d - 1`. -/
theorem phi_maximallyEntangled_eq {d : ℕ} [NeZero d] :
    phiBip (1 : Matrix (Fin d) (Fin d) ℂ) = d - 1 := by
  simp only [phiBip, Matrix.rank_one, Fintype.card_fin]

end IIT.TensorNetwork