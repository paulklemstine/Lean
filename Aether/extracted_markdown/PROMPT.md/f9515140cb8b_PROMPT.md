Finish the partial file `Catalog/Applications/ProofDAG/ChainBound.lean` by proving the missing finite-cardinality bounds for chains in finite acyclic proof DAGs. Stay entirely within the Applications/ProofDAG theme and do not introduce unrelated algebraic material.

Work with the existing setup if possible:
- `Acyclic (R : V → V → Prop) := WellFounded R`
- `IsChain R c` for `c : Fin (n+1) → V`
- the existing lemmas `IsChain.transGen` and/or `IsChain.injective` if they can be repaired cleanly.

Your concrete target is to produce a compiling file with no `sorry` and no unfinished declarations, proving at minimum:
1. `IsChain.card_succ_le` : if `Fintype V` and `hc : IsChain R c` and `hacy : Acyclic R`, then `n + 1 ≤ Fintype.card V`.
2. `IsChain.lt_card` : under the same hypotheses, `n < Fintype.card V`.

Recommended proof strategy:
- First ensure you have a usable injectivity theorem `IsChain.injective` for `c : Fin (n+1) → V` under `Acyclic R`.
- Then use `Fintype.card_le_of_injective` applied to `c` to obtain `Fintype.card (Fin (n+1)) ≤ Fintype.card V`.
- Rewrite `Fintype.card (Fin (n+1)) = n+1` and conclude `n+1 ≤ Fintype.card V`.
- Derive `n < Fintype.card V` via `Nat.lt_of_lt_of_le (Nat.lt_succ_self n)` or an equivalent arithmetic step.

Important implementation advice:
- The previous attempt failed inside `IsChain.transGen` with a brittle `Fin.induction` proof. If repairing that lemma is cumbersome, simplify. You may replace the transitive-closure proof with a more library-friendly lemma about subchains or reachable consecutive segments, as long as it suffices to prove injectivity.
- Prefer standard Mathlib lemmas over hand-rolled index manipulations.
- If a direct proof of injectivity is easier than going through the current `transGen`, take that route.
- Keep the development small and self-contained: definitions, one or two structural lemmas, injectivity, then the cardinality bounds.

Deliverable requirements:
- A complete Lean file at `Catalog/Applications/ProofDAG/ChainBound.lean`.
- No `sorry`, no unfinished theorems.
- The final statements should clearly express the finite bound on chain length in a finite acyclic proof DAG.

If you need to adjust theorem names or statement quantifier order slightly for Lean ergonomics, do so, but preserve the mathematical content above.