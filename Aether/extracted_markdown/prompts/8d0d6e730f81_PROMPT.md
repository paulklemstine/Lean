Formalize the two-way independence model Markov basis theorem in a clean standalone Lean file, without unrelated material. Work in the domain of algebraic statistics, not tropical geometry or Pythagorean triples.

Target file: Catalog/Algebra/MarkovBases/TwoWay.lean

Problem statement:
Formalize contingency tables u : Fin m → Fin n → ℤ (or ℕ where appropriate), define row sums and column sums, define the fiber relation of having equal row and column margins, define the basic 2×2 move B(i,i',j,j') = e_{i,j'} + e_{i',j} - e_{i,j} - e_{i',j'} for distinct i ≠ i' and j ≠ j', and prove that these moves connect every nonnegative fiber of the two-way independence model.

Required scope:
1. Definitions:
   - integer tables on Fin m × Fin n
   - rowSum, colSum
   - SameMargins u v := equal row sums and equal column sums
   - a basicMove indexed by i,i',j,j' with the standard ±1 pattern
   - a one-step relation Step u v meaning v = u + basicMove(...) or v = u - basicMove(...), with side conditions ensuring all intermediate tables are nonnegative when working over fibers of nonnegative tables
2. Margin invariance:
   - prove basicMove_preserves_rowSums
   - prove basicMove_preserves_colSums
   - derive basicMove_preserves_margins / Step.preserve_margins
3. Combinatorial extraction lemma:
   - for unequal u,v with SameMargins u v, let d = u - v
   - prove there exist indices i,i',j,j' such that d i j > 0, d i j' < 0, d i' j < 0 (equivalently a sign-changing 2×2 rectangle suitable for a distance-reducing move). This is the crucial lemma; state it carefully and prove it cleanly.
4. Distance reduction:
   - define an ℓ¹ distance on tables, e.g. sum over all cells of Int.natAbs (u i j - v i j)
   - prove that if u ≠ v and SameMargins u v, one can choose an oriented basic move producing u' with SameMargins u' v, u' nonnegative, and dist u' v < dist u v
5. Main theorem:
   - prove by well-founded induction on dist u v that any two nonnegative equal-margin tables are connected by a finite sequence of basic 2×2 moves staying inside the nonnegative fiber
   - package the result as twoWay_fiber_connected

Implementation guidance:
- Keep the file self-contained and coherent. Do not paste in unrelated theorems.
- Prefer a constructive theorem returning an explicit finite list/chain of intermediate tables or the reflexive-transitive closure of Step.
- If full generality over arbitrary m,n causes edge-case overhead, assume [Fact (0 < m)] and [Fact (0 < n)] or even 2 ≤ m, 2 ≤ n where needed; make assumptions explicit.
- Use helper lemmas for finite sums on Fin m and Fin n. Keep all theorem statements complete and compilable.
- It is acceptable to first work over ℤ-valued tables for algebraic identities, then state the fiber-connectivity theorem for ℕ-valued/nonnegative tables via coercions or an explicit nonnegativity predicate.

Deliverable standard:
Produce one complete Lean file with full theorem statements and proofs, no sorrys, centered entirely on this theorem. The final artifact should be checkable as a genuine standalone formalization of the classical two-way Markov basis theorem.