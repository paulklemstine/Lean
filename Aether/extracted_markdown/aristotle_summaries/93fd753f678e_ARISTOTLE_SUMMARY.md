# Summary of changes for run 3a1dfd31-07f6-41d3-b441-f7e86bd0a5a8
Created `Catalog/Applications/ProofDAG/Chains.lean`, a small, self-contained, fully checked theorem package about chains in a finite acyclic proof DAG.

Note on context: there was no pre-existing `Applications/ProofDAG/Reachability` file or `proofDepth` definition in the project to reuse, so the file establishes the minimal depth theory it needs from scratch (kept narrow, in line with the request).

Setup (matching the requested framework):
- Finite vertex type `V` with `[Fintype V] [DecidableEq V]` and an edge relation `R : V → V → Prop`.
- `Acyclic R`: the transitive closure of `R` is irreflexive (no vertex is its own strict ancestor).
- `proofDepth R v`: the number of strict ancestors of `v` (vertices `u` with `Relation.TransGen R u v`) — the canonical depth attached to a finite dependency relation.

Chain definition (as requested, in the `Fin (n+1)` formulation): `IsChain R (c : Fin (n+1) → V)` means `∀ i : Fin n, R (c i.castSucc) (c i.succ)`. A docstring explains why this is preferable to the partial `ℕ → V` form (length is explicit in the type, no out-of-range index bookkeeping, and it plugs directly into `Fin.strictMono_iff_lt_succ` and `Fintype.card_le_of_injective`).

Core results proved:
- `proofDepth_lt_of_rel`: depth monotonicity along an edge — `Acyclic R → R u v → proofDepth R u < proofDepth R v`.
- `chain_strictMono_depth`: depth is strictly increasing along a chain (`StrictMono (fun i => proofDepth R (c i))`).
- `chain_injective`: any `IsChain` is injective.
- `chain_card_le`: `n + 1 ≤ Fintype.card V`.
- `chain_length_lt_card`: the sharp bound `n < Fintype.card V`.

The speculative "scale-free" conjecture is not discussed or formalized. The requested `[DecidableEq V]` is kept in the setup (to match the request) but `omit`ed for the proofs, which do not need it, keeping the statements maximally general; this is documented in the file.

Verification: the file builds with `lake env lean` with no errors or warnings, contains no `sorry`/`admit`, and the main theorems depend only on the standard axioms `propext`, `Classical.choice`, and `Quot.sound`.