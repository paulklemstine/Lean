import Algebra.GracefulTrees

/-!
# Graceful labelings of stars

Stars form a basic infinite family of caterpillars.  This file proves directly that the
complete bipartite graph `K_{1,n}` is graceful.
-/

open Finset SimpleGraph
open GracefulTrees

namespace GracefulTrees

/-- Label the centre of `K_{1,n}` by zero and its leaves by `1,…,n`. -/
def starLabel (n : ℕ) : Unit ⊕ Fin n → ℕ
  | .inl _ => 0
  | .inr i => i.1 + 1

/-- The centre-and-leaves labeling is injective. -/
theorem starLabel_injective (n : ℕ) : Function.Injective (starLabel n) := by
  intro x y h
  cases x with
  | inl x =>
      cases y with
      | inl y => simp
      | inr y => simp [starLabel] at h
  | inr x =>
      cases y with
      | inl y => simp [starLabel] at h
      | inr y =>
          simp only [starLabel] at h
          exact congrArg Sum.inr (Fin.ext (by omega))

/-- Every star label lies in `0,…,n`. -/
theorem starLabel_le (n : ℕ) (v : Unit ⊕ Fin n) : starLabel n v ≤ n := by
  cases v <;> simp [starLabel]

/-- Every star `K_{1,n}` is graceful. -/
theorem starGraph_isGraceful (n : ℕ) :
    IsGraceful (completeBipartiteGraph Unit (Fin n)) n (starLabel n) := by
  refine ⟨starLabel_injective n, starLabel_le n, ?_, ?_⟩
  · intro u v huv
    rw [completeBipartiteGraph_adj] at huv
    rcases huv with huv | huv
    · cases u with
      | inl u =>
          cases v with
          | inl v => simp at huv
          | inr v =>
              simp only [starLabel, Nat.dist_zero_left, Finset.mem_Icc]
              omega
      | inr u => simp at huv
    · cases u with
      | inl u => simp at huv
      | inr u =>
          cases v with
          | inl v =>
              simp only [starLabel, Nat.dist_zero_right, Finset.mem_Icc]
              omega
          | inr v => simp at huv
  · intro d hd
    rw [Finset.mem_Icc] at hd
    let i : Fin n := ⟨d - 1, by omega⟩
    refine ⟨Sum.inl (), Sum.inr i, ?_, ?_⟩
    · simp [completeBipartiteGraph_adj]
    · simp only [starLabel, Nat.dist_zero_left]
      simp [i]
      omega

/-- Every star admits a graceful labeling. -/
theorem starGraph_hasGracefulLabeling (n : ℕ) :
    HasGracefulLabeling (completeBipartiteGraph Unit (Fin n)) n :=
  ⟨starLabel n, starGraph_isGraceful n⟩

end GracefulTrees