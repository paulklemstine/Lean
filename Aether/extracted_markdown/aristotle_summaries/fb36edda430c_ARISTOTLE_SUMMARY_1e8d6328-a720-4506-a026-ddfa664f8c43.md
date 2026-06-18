# Summary of changes
I've written a comprehensive book about computation titled **"The Architecture of Computation"**, located in `lean4/Computation/`. The book consists of 15 chapters, 2 appendices, and a companion Lean 4 formalization file, all organized in a single directory.

## Structure

**`Book.md`** — Table of contents and preface

### Part I: Foundations
1. **What Is Computation?** — History from Euclid to Hilbert's Entscheidungsproblem, the Curry-Howard correspondence
2. **Finite Automata and Regular Languages** — DFAs, NFAs, subset construction, regular expressions, Kleene's theorem, pumping lemma, Myhill-Nerode theorem
3. **Context-Free Languages** — CFGs, parse trees, Chomsky normal form, pushdown automata, CFL pumping lemma, the Chomsky hierarchy
4. **The Lambda Calculus** — Church's formalism, β-reduction, Church encodings, the Y combinator, Church-Rosser theorem, simply typed lambda calculus, Curry-Howard correspondence
5. **Turing Machines** — Formal definition, configurations, recognizers vs deciders, multitape and nondeterministic TMs, the universal Turing machine
6. **The Church-Turing Thesis** — Convergence of formalizations, the thesis and its scope, challenges and alternatives

### Part II: The Landscape of Decidability
7. **Decidability and the Halting Problem** — Turing's diagonal argument, HALT is recognizable but undecidable, the complement of HALT
8. **Reducibility** — Many-one and Turing reducibility, reduction techniques, r.e.-completeness, degree structures
9. **Rice's Theorem** — Universal undecidability of language properties, implications for software verification, the Rice-Shapiro theorem
10. **The Arithmetic Hierarchy** — Σₙ/Πₙ sets, Post's theorem, the Turing jump, oracle machines, the analytical hierarchy

### Part III: Complexity and Beyond
11. **Time Complexity: P and NP** — Definitions, the Cook-Levin theorem, NP-completeness, the P vs NP question, the complexity zoo
12. **Space Complexity** — L, NL, PSPACE, Savitch's theorem, Immerman-Szelepcsényi theorem, PSPACE-completeness and games
13. **Interactive Proofs and Zero Knowledge** — IP = PSPACE, the sum-check protocol, zero-knowledge proofs, ZK-SNARKs, MIP* = RE
14. **Quantum Computation** — Qubits, quantum gates, Deutsch's algorithm, Shor's algorithm, Grover's algorithm, BQP, quantum error correction
15. **The Outer Shores** — Open problems (P vs NP, circuit complexity), Kolmogorov complexity, computational learning theory, computation and physics

### Appendices
- **Appendix A** — Notation and Lean 4 conventions
- **Appendix B** — Selected proofs and proof techniques

### Lean 4 Formalization (`Basic.lean`)
A fully verified Lean 4 file (compiles with no sorries) containing:
- `BookDFA` — DFA definition with `run`, `accepts`, `language`, `complement`, `product`, and `union_` constructions
- Theorems: `run_append`, `runFrom_nil`, `run_singleton`
- `BookRegExp` — Regular expression inductive type with `language` semantics
- `LambdaTerm` — Lambda calculus with de Bruijn indices, including combinators (I, K, S, ω, Ω), Church numerals, booleans, `size`, `freeVars`, and closedness proofs
- `BookTM` — Turing machine structure
- `cantor_no_surjection` — Formal proof of Cantor's diagonal theorem (the core of the halting problem argument)
- `nat_to_bool_not_surjective` — Uncountability of ℕ → Bool