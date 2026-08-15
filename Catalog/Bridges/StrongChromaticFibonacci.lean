import Bridges.StrongChromaticBipartite
import Bridges.RiordanRowSumFibonacci
/-!
# Bridge: the strong chromatic index of Fibonacci-sized complete bipartite graphs

This file is the mandated **cross-domain bridge**. It combines, non-trivially,
results from two different catalog domains:

* **Combinatorics** — `Catalog/Combinatorics/StrongChromaticBipartite.lean`:
  the tightness theorem `completeBipartite_strongChromaticIndex`, i.e.
  `χ'_s(K_{m,n}) = Δ_A · Δ_B = m · n`, together with the degree computations
  `maxDegA_complete`, `maxDegB_complete`.
* **Novelty / Fibonacci–Riordan thread** —
  `Catalog/Novelty/RiordanRowSumFibonacci.lean`: the steep-diagonal row-sum
  identity `pascalRiordanA_eq_fib`, `∑_{k} C(n+k, 2k) = fib(2n+1)`.

The new connection: when the two partite sets of a *complete* bipartite graph
have sizes equal to Riordan row sums `A(a) = ∑_k C(a+k,2k)` and
`A(b) = ∑_k C(b+k,2k)`, the strong chromatic index — a graph-colouring invariant
— is exactly the product of the odd-indexed Fibonacci numbers `fib(2a+1)·fib(2b+1)`.
Thus an extremal value of a colouring invariant is identified with a product of
steep-diagonal binomial sums.

-- !-- Lab Notes -- !--
-- !-- Bridge Mandate (v16b): files used —
--     Domain 1 (Combinatorics): Catalog/Combinatorics/StrongChromaticBipartite.lean
--       (completeBipartite_strongChromaticIndex, maxDegA_complete, maxDegB_complete).
--     Domain 2 (Novelty): Catalog/Novelty/RiordanRowSumFibonacci.lean
--       (pascalRiordanA, pascalRiordanA_eq_fib). -- !--
-- !-- Hypothesis: For complete bipartite graphs whose part sizes are Riordan
--     row sums, χ'_s factors as a product of Fibonacci numbers. -- !--
-- !-- Experiment: Instantiated K_{m,n} with m = A(a), n = A(b) over `Fin`,
--     supplied positivity (A(a) ≥ 1, the k=0 term C(a,0)=1) to get the required
--     `Nonempty`/`NeZero` instances, then chained the combinatorics equality
--     with the Riordan identity. -- !--
-- !-- Analysis: The bridge is genuine: neither factor is available without the
--     graph-colouring side (the χ'_s value) AND the number-theoretic side (the
--     binomial-to-Fibonacci collapse). Removing either import breaks the result. -- !--
-- !-- Critique: Positivity of the row sums is essential — for an empty part the
--     complete-bipartite degree formula degenerates. Established
--     `0 < pascalRiordanA a` to rule this out. -- !--
-- !-- Synthesis: A colouring invariant of an explicit graph family equals a
--     product of catalogued combinatorial sums, linking the two threads. -- !--
-/

namespace StrongChromaticFibonacci

open StrongChromaticBipartite RiordanRowSumFibonacci

/-- The Riordan row sum is strictly positive: the `k = 0` term contributes
`C(a, 0) = 1`. -/
theorem pascalRiordanA_pos (a : ℕ) : 0 < pascalRiordanA a := by
  rw [(pascalRiordan_pair a).1]
  exact Nat.fib_pos.mpr (by omega)

/-- `Fin (pascalRiordanA a)` is nonempty, since the row sum is positive. -/
instance instNeZeroPascalRiordanA (a : ℕ) : NeZero (pascalRiordanA a) :=
  ⟨(pascalRiordanA_pos a).ne'⟩

/-- **Bridge theorem.** The strong chromatic index of the complete bipartite
graph whose partite sets have sizes `A(a) = ∑_k C(a+k,2k)` and `A(b)` equals
`fib(2a+1) · fib(2b+1)`.

This identifies an extremal graph-colouring invariant (Combinatorics domain) with
a product of odd-indexed Fibonacci numbers via the Riordan steep-diagonal
identity (Novelty domain). -/
theorem strongChromaticIndex_riordan_complete_bipartite (a b : ℕ) :
    strongChromaticIndex
        (completeAdj (Fin (pascalRiordanA a)) (Fin (pascalRiordanA b)))
      = ((Nat.fib (2 * a + 1) * Nat.fib (2 * b + 1) : ℕ) : ℕ∞) := by
  haveI : Nonempty (Fin (pascalRiordanA a)) := ⟨⟨0, pascalRiordanA_pos a⟩⟩
  haveI : Nonempty (Fin (pascalRiordanA b)) := ⟨⟨0, pascalRiordanA_pos b⟩⟩
  rw [completeBipartite_strongChromaticIndex, maxDegA_complete, maxDegB_complete]
  rw [Fintype.card_fin, Fintype.card_fin, mul_comm,
    (pascalRiordan_pair a).1, (pascalRiordan_pair b).1]

/-- Restated purely in terms of the Riordan binomial row sums: the strong
chromatic index equals the product of the two steep-diagonal binomial sums
`(∑_k C(a+k,2k)) · (∑_k C(b+k,2k))`. -/
theorem strongChromaticIndex_riordan_binomial (a b : ℕ) :
    strongChromaticIndex
        (completeAdj (Fin (pascalRiordanA a)) (Fin (pascalRiordanA b)))
      = (((∑ k ∈ Finset.range (a + 1), Nat.choose (a + k) (2 * k)) *
          (∑ k ∈ Finset.range (b + 1), Nat.choose (b + k) (2 * k)) : ℕ) : ℕ∞) := by
  rw [strongChromaticIndex_riordan_complete_bipartite, pascalRiordanA_eq_fib a,
    pascalRiordanA_eq_fib b]

end StrongChromaticFibonacci