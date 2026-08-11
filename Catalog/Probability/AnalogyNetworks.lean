/-
# Networks of approximate analogies: chains, cycles, and semantic holonomy

`Probability/CopycatGroupoid.lean` established that ε-approximate structural
analogies compose with additive total variation defect and gave the two-step
holonomy bound.  This file passes from single arrows to **networks**: an arbitrary
finite chain of analogies with individually varying defects, and the holonomy of a
cycle in such a network.

Main results.

* `Network.chainAnalogy` : the composite of the first `k` arrows of a chain is an
  analogy with defect `∑_{i<k} ε i` — defects add along a path.
* `Network.network_transport_le` : hence depth-`d` truth probabilities are
  transported along the chain with error at most `1 - (1 - ∑_{i<k} ε i)^d`; the
  geometric modulus of the single-arrow theorem persists at network level, with the
  *sum* of the local defects as the effective one.
* `Network.loop_holonomy_bound` : for a cycle (`Ms k = Ms 0`) the semantic holonomy
  — the displacement of depth-`d` truth probabilities after traversing the loop — is
  at most `1 - (1 - ∑_{i<k} ε i)^d`.
* `Network.loop_holonomy_trivial` : a cycle of *exact* analogies has trivial
  holonomy; every modal observation returns to its original value.
* `Network.meaning_invariant_of_trivial_holonomy` : consequently any interpretation
  ("meaning") that factors through the modal theory of a world is globally
  well-defined around a cycle of exact analogies — the coherence statement the
  holonomy obstruction was designed to express.
* `Network.meaning_defect_bound` : the quantitative counterpart for a meaning given
  by a single modal observation of depth `d`.

Chains are indexed by `ℕ` with all structures on a common world type, which is the
form in which a finite network with a chosen cycle basis is traversed: each cycle of
the basis is a chain that closes up.
-/
import Probability.CopycatGroupoid

namespace Catalog.Probability.QuantitativeCopycat

open Finset

namespace Network

variable {ι S : Type*} [Fintype S]

/-- The composite of the first `k` arrows of a chain of approximate analogies is an
approximate analogy whose defect is the *sum* of the local defects. -/
def chainAnalogy (Ms : ℕ → PModalStructure ι S) (ε : ℕ → ℝ)
    (A : ∀ i, ApproxAnalogy (Ms i) (Ms (i + 1)) (ε i)) :
    ∀ k, ApproxAnalogy (Ms 0) (Ms k) (∑ i ∈ Finset.range k, ε i)
  | 0 => (ApproxAnalogy.refl (Ms 0)).mono (by simp)
  | k + 1 =>
      ((chainAnalogy Ms ε A k).comp (A k)).mono (by rw [Finset.sum_range_succ])

/-- **Transport along a network path.**  Depth-`d` truth probabilities are moved by
at most `1 - (1 - Σ ε)^d` along a chain of approximate analogies. -/
theorem network_transport_le (Ms : ℕ → PModalStructure ι S) (ε : ℕ → ℝ)
    (A : ∀ i, ApproxAnalogy (Ms i) (Ms (i + 1)) (ε i)) (hε : ∀ i, 0 ≤ ε i) (k : ℕ)
    (hsum : ∑ i ∈ Finset.range k, ε i ≤ 1) (φ : PForm ι) (s : S) :
    |(Ms 0).eval φ s - (Ms k).eval φ ((chainAnalogy Ms ε A k).toEquiv s)|
      ≤ 1 - (1 - ∑ i ∈ Finset.range k, ε i) ^ φ.depth :=
  (Ms 0).transport_le (Ms k)
    (Finset.sum_nonneg fun i _ => hε i) hsum (chainAnalogy Ms ε A k) φ s

/-- **Semantic holonomy of a cycle.**  Traversing a closed loop of approximate
analogies displaces the depth-`d` truth probability of every world by at most
`1 - (1 - Σ ε)^d`, the geometric accumulation of the total defect around the loop. -/
theorem loop_holonomy_bound (Ms : ℕ → PModalStructure ι S) (ε : ℕ → ℝ)
    (A : ∀ i, ApproxAnalogy (Ms i) (Ms (i + 1)) (ε i)) (hε : ∀ i, 0 ≤ ε i) (k : ℕ)
    (hsum : ∑ i ∈ Finset.range k, ε i ≤ 1) (hcyc : Ms k = Ms 0) (φ : PForm ι)
    (s : S) :
    |(Ms 0).eval φ s - (Ms 0).eval φ ((chainAnalogy Ms ε A k).toEquiv s)|
      ≤ 1 - (1 - ∑ i ∈ Finset.range k, ε i) ^ φ.depth := by
  have h := network_transport_le Ms ε A hε k hsum φ s
  have key : (Ms k).eval φ = (Ms 0).eval φ := by rw [hcyc]
  rwa [key] at h

/-- **Trivial holonomy for exact cycles.**  If every arrow of the loop is an exact
analogy then the loop preserves every modal observation. -/
theorem loop_holonomy_trivial (Ms : ℕ → PModalStructure ι S) (ε : ℕ → ℝ)
    (A : ∀ i, ApproxAnalogy (Ms i) (Ms (i + 1)) (ε i)) (hzero : ∀ i, ε i = 0) (k : ℕ)
    (hcyc : Ms k = Ms 0) (φ : PForm ι) (s : S) :
    (Ms 0).eval φ s = (Ms 0).eval φ ((chainAnalogy Ms ε A k).toEquiv s) := by
  have hs : ∑ i ∈ Finset.range k, ε i = 0 :=
    Finset.sum_eq_zero fun i _ => hzero i
  have h := loop_holonomy_bound Ms ε A (fun i => le_of_eq (hzero i).symm) k
    (by rw [hs]; norm_num) hcyc φ s
  have hb : 1 - (1 - ∑ i ∈ Finset.range k, ε i) ^ φ.depth = 0 := by
    rw [hs]; norm_num
  rw [hb] at h
  exact sub_eq_zero.1 (abs_eq_zero.1 (le_antisymm h (abs_nonneg _)))

/-- **Global coherence of meanings around an exact cycle.**  An interpretation that
factors through the modal theory of a world (i.e. assigns the same meaning to worlds
with identical modal observations) is transported consistently around any cycle of
exact analogies: the holonomy acts trivially on meanings. -/
theorem meaning_invariant_of_trivial_holonomy (Ms : ℕ → PModalStructure ι S)
    (ε : ℕ → ℝ) (A : ∀ i, ApproxAnalogy (Ms i) (Ms (i + 1)) (ε i))
    (hzero : ∀ i, ε i = 0) (k : ℕ) (hcyc : Ms k = Ms 0) (I : S → ℝ)
    (hI : ∀ s t, (∀ φ : PForm ι, (Ms 0).eval φ s = (Ms 0).eval φ t) → I s = I t)
    (s : S) : I s = I ((chainAnalogy Ms ε A k).toEquiv s) :=
  hI _ _ fun φ => loop_holonomy_trivial Ms ε A hzero k hcyc φ s

/-- Quantitative coherence: a meaning given by a modal observation of depth `d` is
ambiguous around a loop by at most `1 - (1 - Σ ε)^d`.  So the holonomy of a cycle
bounds the semantic ambiguity it creates. -/
theorem meaning_defect_bound (Ms : ℕ → PModalStructure ι S) (ε : ℕ → ℝ)
    (A : ∀ i, ApproxAnalogy (Ms i) (Ms (i + 1)) (ε i)) (hε : ∀ i, 0 ≤ ε i) (k : ℕ)
    (hsum : ∑ i ∈ Finset.range k, ε i ≤ 1) (hcyc : Ms k = Ms 0) (φ : PForm ι)
    (s : S) :
    |(Ms 0).eval φ s - (Ms 0).eval φ ((chainAnalogy Ms ε A k).toEquiv s)|
      ≤ (φ.depth : ℝ) * ∑ i ∈ Finset.range k, ε i := by
  refine le_trans (loop_holonomy_bound Ms ε A hε k hsum hcyc φ s) ?_
  exact one_sub_pow_le_depth_mul _ (by linarith) φ.depth

/-! ## A cycle with nontrivial holonomy

The bound above is not vacuous: a loop of two arrows with total defect `2ε` can move
a depth-`d` observation.  We record the extreme case `ε = 1`: two structures on
`Bool` whose composite loop swaps the worlds, so that a depth-one observation changes
by the full amount `1`. -/

/-- Both worlds move to `true`; the atom is true only at `true`. -/
def toTrue : PModalStructure Unit Bool where
  step _ t := if t then 1 else 0
  step_nonneg _ t := by cases t <;> norm_num
  step_sum s := by simp
  val _ s := if s then 1 else 0
  val_nonneg _ s := by cases s <;> norm_num
  val_le_one _ s := by cases s <;> norm_num

/-- Both worlds move to `false`; the atom is again true only at `true`. -/
def toFalse : PModalStructure Unit Bool where
  step _ t := if t then 0 else 1
  step_nonneg _ t := by cases t <;> norm_num
  step_sum s := by simp
  val _ s := if s then 1 else 0
  val_nonneg _ s := by cases s <;> norm_num
  val_le_one _ s := by cases s <;> norm_num

/-- The identity renaming is a `1`-approximate analogy between the two: the defect
is maximal, since the kernels are mutually singular. -/
def maxDefect : ApproxAnalogy toTrue toFalse 1 where
  toEquiv := Equiv.refl Bool
  atoms _ _ := rfl
  defect s := by simp [toTrue, toFalse]

/-- The reverse arrow. -/
def maxDefect' : ApproxAnalogy toFalse toTrue 1 where
  toEquiv := Equiv.refl Bool
  atoms _ _ := rfl
  defect s := by simp [toTrue, toFalse]

/-- The depth-one observation separates the two structures maximally: the atom holds
with probability `1` after one step in `toTrue` and with probability `0` in
`toFalse`.  Hence a loop of two arrows of defect `1` really does destroy all
information, showing that the holonomy bound cannot be improved at total defect
`1`. -/
theorem maximal_holonomy (s : Bool) :
    |toTrue.eval (.next (.atom ())) s - toFalse.eval (.next (.atom ())) s| = 1 := by
  have h1 : toTrue.eval (.next (.atom ())) s = 1 := by
    simp [toTrue, PModalStructure.eval]
  have h2 : toFalse.eval (.next (.atom ())) s = 0 := by
    simp [toFalse, PModalStructure.eval]
  rw [h1, h2]
  norm_num

end Network

end Catalog.Probability.QuantitativeCopycat