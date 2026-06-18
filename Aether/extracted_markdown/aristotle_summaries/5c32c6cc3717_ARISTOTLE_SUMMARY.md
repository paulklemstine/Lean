# Summary of changes for run ec64ae6a-4cd1-41a1-a475-e2e1e222d2b2
## Completed: Axiomatic Oracle Hierarchies Framework

### Key Discovery
During formalization, I discovered that the **naïve axiomatization** of oracle hierarchies — expansion (S ⊆ J(S)) plus unrestricted nontriviality (∀ S, ∃ x ∈ J(S), x ∉ S) — is **unsatisfiable for any type**. Applying nontriviality to the universal set yields x ∉ univ, which is impossible. This is proved as `naive_jump_always_empty` in the Lean file. I then developed two corrected frameworks and proved the complete structural theory.

### Lean Proofs (`Computation/OracleHierarchy.lean`)
All 28 definitions and theorems are sorry-free and build cleanly. Key results:

1. **`naive_jump_always_empty`** — The naïve axioms are vacuous (no axioms needed!)
2. **`StrictExpander`** — Corrected abstraction on preorders (a < J(a))
3. **`iterExpand_strictMono`** — The iterated jump is strictly monotone
4. **`expander_no_fixed_point`** — No fixed points exist
5. **`expander_requires_infinite`** — No strict expander on finite partial orders
6. **`natSuccExpander` + `natSucc_iter`** — Concrete instance: Nat.succ produces iter(0, n) = n
7. **`SetJumpOperator`** — Corrected set-theoretic jump (nontriviality for proper subsets only)
8. **`setjump_information_gap`** — Higher levels contain genuinely new information
9. **`limit_strictly_contains`** — The ω-th level strictly exceeds every finite level
10. **`accidental_not_implies_essential`** — The essential-accidental gap is strict (concrete witness: enum(n,x) = x < n, S = ℕ)
11. **`composeSetJump`** — Jump operators compose

### Novel Definitions
- `StrictExpander` — Abstract jump on preorders (new, not in Catalog)
- `SetJumpOperator` — Corrected set-theoretic jump with restricted nontriviality
- `AccidentallyComputable` / `EssentiallyComputable` — Formalization of pointwise vs. uniform matching

### Falsifiable Conjecture
The limit oracle C_J(S) = ⋃_n J^n(S) satisfies closure axioms (extensive, monotone, idempotent) iff J(univ) = univ. Testable by constructing SetJumpOperators where the limit does/doesn't reach univ.

### Deliverables
- **`Computation/OracleHierarchy.lean`** — 266 lines, 28 definitions/theorems, zero sorry
- **`ARTICLE.md`** — Scientific American-style article on the infinite staircase of knowledge
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, proofs, algorithms, references
- **`FUTURE_DIRECTIONS.md`** — 5 research directions including ordinal extension and PH instantiation
- **`PACKAGE.json`** — Complete package with 2 interactive HTML demos
- **`demo.py`** — Numerical demonstrations of all key concepts
- **`algorithms.py`** — Type-hinted implementations of core algorithms
- **`visualize_oracle_chain.py`** — Matplotlib visualization script