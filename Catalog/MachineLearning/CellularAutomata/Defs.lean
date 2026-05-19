/-
  # Cellular Automata: Definitions

  Basic definitions for one-dimensional nearest-neighbor cellular automata,
  spacetime diagrams, column compatibility, and transfer matrices.
-/
import Mathlib

open Matrix Finset

/-! ## Cellular Automata Local Rules -/

/-- A nearest-neighbor CA local rule over alphabet α. -/
abbrev CARuleNN (α : Type*) := α → α → α → α

/-- Right-permutativity: for every a b, the map c ↦ f a b c is bijective. -/
def RightPermutative {α : Type*} (f : CARuleNN α) : Prop :=
  ∀ a b : α, Function.Bijective (fun c => f a b c)

/-- Left-permutativity: for every b c, the map a ↦ f a b c is bijective. -/
def LeftPermutative {α : Type*} (f : CARuleNN α) : Prop :=
  ∀ b c : α, Function.Bijective (fun a => f a b c)

/-! ## Spacetime Columns and Compatibility -/

/-- A height-h column: a function from time steps to alphabet values. -/
abbrev SpacetimeColumn (α : Type*) (h : ℕ) := Fin h → α

/-- Two columns c_left, c_mid are left-compatible with c_right under rule f
    if the CA rule is satisfied at the middle column for all time steps. -/
def ColumnTripleValid {α : Type*} (f : CARuleNN α) {h : ℕ}
    (c_left c_mid c_right : SpacetimeColumn α (h + 1)) : Prop :=
  ∀ t : Fin h, c_mid t.castSucc.succ = f (c_left t.castSucc) (c_mid t.castSucc) (c_right t.castSucc)

/-- The state for the transfer matrix: a pair of consecutive columns.
    The transition from state (c₁, c₂) to (c₂', c₃) requires c₂ = c₂'
    and ColumnTripleValid f c₁ c₂ c₃. -/
def TransferCompatible {α : Type*} [DecidableEq α] (f : CARuleNN α) {h : ℕ}
    (state1 state2 : SpacetimeColumn α (h + 1) × SpacetimeColumn α (h + 1)) : Prop :=
  state1.2 = state2.1 ∧ ColumnTripleValid f state1.1 state1.2 state2.2

/-! ## Adjacency Matrices for Relations -/

/-- The adjacency matrix of a decidable relation on a finite type.
    A i j = 1 if R i j, else 0. -/
noncomputable def adjMatrix {σ : Type*} [Fintype σ] [DecidableEq σ]
    (R : σ → σ → Prop) [DecidableRel R] : Matrix σ σ ℕ :=
  fun i j => if R i j then 1 else 0

/-! ## Cyclic Sequences (Closed Walks) -/

/-- A cyclic R-chain of length n is a function w : Fin n → σ such that
    R (w i) (w ((i+1) mod n)) for all i. -/
def IsCyclicChain {σ : Type*} (R : σ → σ → Prop) {n : ℕ} [NeZero n]
    (w : Fin n → σ) : Prop :=
  ∀ i : Fin n, R (w i) (w (i + 1))

/-- The type of cyclic R-chains of length n. -/
def CyclicChain (σ : Type*) (R : σ → σ → Prop) (n : ℕ) [NeZero n] : Type _ :=
  { w : Fin n → σ // IsCyclicChain R w }

instance {σ : Type*} [Fintype σ] [DecidableEq σ] (R : σ → σ → Prop) [DecidableRel R]
    (n : ℕ) [NeZero n] : Fintype (CyclicChain σ R n) := by
  unfold CyclicChain IsCyclicChain
  exact Subtype.fintype _

/-! ## Spacetime Diagram Counting -/

/-- Count of cyclic R-chains of length n. -/
noncomputable def cyclicChainCount (σ : Type*) [Fintype σ] [DecidableEq σ]
    (R : σ → σ → Prop) [DecidableRel R] (n : ℕ) [NeZero n] : ℕ :=
  Fintype.card (CyclicChain σ R n)

end