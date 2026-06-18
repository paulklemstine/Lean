Develop a self-contained Lean 4 formalization of a mathematically precise subset of the original transfinite cellular automata idea. Do not attempt to prove that a Rule 110 analog on ω² is universal or super-Turing, and do not mix in unrelated bilattice/paraconsistency material. Instead, build a complete theory of ordinal-indexed cellular automata with transfinite time evolution that is actually provable in Lean.

Concretely, work with a finite state type `σ` (start with `Bool` if needed) and a fixed index type given by an ordinal-shaped set that is easy to handle in Lean, such as `Nat`, `WithTop Nat`, or another concrete well-ordered type that models an initial ordinal segment like ω or ω+1. Define configurations as functions from cells to states. Define a local update rule using only finitely many neighboring cells; for example, radius-1 rules on `Nat` or on `WithTop Nat` with a convention for boundary cells. Then define transfinite-time evolution `step : Time -> Config -> Config` by transfinite recursion: successor stages use the local rule, and limit stages use a coordinatewise limit rule that is chosen to be mathematically tractable, such as 'if the state at a cell is eventually constant below the limit, take that eventual value; otherwise use a default value'.

Your goals are:
1. Give precise definitions of configurations, local rules, successor evolution, and limit evolution.
2. Prove the evolution is well-defined by transfinite/well-founded recursion on the chosen time type.
3. Prove basic structural lemmas: extensionality, locality, and agreement on finite windows implies agreement after one step on the corresponding shrunken/expanded window.
4. Prove at least one genuinely nontrivial theorem for a specific rule. Good targets include:
   - a nilpotent rule whose evolution reaches the zero configuration after bounded time,
   - a monotone rule with monotone evolution under pointwise order,
   - preservation of finite support or a bound on support growth,
   - eventual stabilization at each cell for a simple monotone rule, making the limit rule meaningful.
5. If feasible, define an embedding of ordinary CA on `Nat` into the ordinal-indexed setting on `WithTop Nat` or similar, and prove compatibility of one-step evolution on the embedded part.

Important constraints:
- Prefer a complete, coherent file with full theorem statements and proofs over ambitious theorem headers.
- Avoid claims about ITTM equivalence, super-Turing power, universality, or ω² unless you can fully formalize them. Those are out of scope for this cycle.
- The final development should read as a standalone mathematical story: definitions, examples, main theorem(s), and proof sketches mirrored by actual Lean proofs.

Suggested theorem shape: define a simple monotone Boolean rule on `WithTop Nat`, prove by induction that finite-support initial configurations remain eventually zero beyond a linearly growing frontier, deduce each coordinate is eventually constant, and then prove the transfinite limit configuration is well-defined and agrees with the eventual-value rule.

Deliver a polished file focused only on ordinal/transfinite cellular automata. No placeholders, no unrelated imports, no theorem-name graveyard.