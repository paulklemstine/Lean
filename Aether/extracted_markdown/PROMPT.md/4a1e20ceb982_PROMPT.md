Formalize a clean, coherent Lean 4 file developing only a minimal core theory of transfinite cellular automata limit stages on `ℕ`.

Requirements:

1. Scope and cleanliness
- Create a single self-contained file focused exclusively on transfinite cellular automata.
- Remove all unrelated material (graph theory, transreal arithmetic, walk counting, or any other pollution).
- The file must compile without `sorry`.
- Prefer a small number of fully proved lemmas over a broad but incomplete development.

2. Basic definitions
- Define `Config σ := ℕ → σ`.
- Define the one-step global update from a radius-1 local rule `f : σ → σ → σ → σ`.
- Use the boundary convention at `0` given by natural subtraction, so the left neighbor of `0` is again `0`.
- Keep these definitions elementary and explicit.

3. Eventual constancy below an ordinal
- Define a predicate expressing that a history `h : Ordinal → σ` is eventually constant with value `v` below `λ : Ordinal`. Use an explicit witness ordinal `β < λ` such that for all `γ` with `β ≤ γ` and `γ < λ`, one has `h γ = v`.
- Then define the coordinatewise version for `H : Ordinal → Config σ`.
- Avoid over-engineered abstractions; make the notion easy to use in proofs.

4. Main limit-stage construction
- Prove a theorem of the following form: if for every coordinate `n : ℕ` there exists `v : σ` such that the coordinate history `α ↦ H α n` is eventually constant with value `v` below `λ`, then there exists a configuration `c : Config σ` whose coordinates are exactly those eventual values.
- Prove uniqueness: if `c` and `d` both satisfy the same eventual-value characterization, then `c = d`.
- Package this as a clean `limit_exists_unique` theorem and add a usable characterization lemma for the constructed limit configuration.
- It is acceptable to construct the limit configuration noncomputably using choice if that makes the proof simple and robust.

5. Concrete `Bool` application at stage `ω`
- Define iterates of a global map `F : Config Bool → Config Bool` along `ℕ`.
- Assume `F` is inflationary pointwise: `∀ c n, c n ≤ F c n` under the usual order on `Bool`.
- Prove that for every initial configuration `c0` and every coordinate `n`, the sequence `k ↦ (F^[k]) c0 n` is monotone.
- Prove that every monotone sequence `ℕ → Bool` is eventually constant.
- Deduce that the coordinatewise histories of the iterate chain are eventually constant below `ω`, and therefore the `ω`-limit configuration exists.
- State and prove this as a theorem such as `omega_limit_exists`.

6. Optional CA-specific example
- If you include a cellular-automaton example, keep it very simple and fully proved.
- A good target is the Boolean local rule `f l c r := l || c || r`, showing the induced global step map is inflationary, and then instantiating `omega_limit_exists`.
- The result should be only existence of the `ω`-limit, not a full classification of that limit.

7. Proof style guidance
- Favor direct proofs and elementary lemmas.
- Avoid introducing a total ordinal recursion for all stages; that is broader than needed and risks partiality issues.
- Avoid any claims about arbitrary transfinite evolution being globally defined.
- The final file should read as a minimal, rigorous core theory: definitions, limit existence/uniqueness under eventual constancy, and the Boolean `ω`-stage application.

Suggested theorem inventory:
- `step` definition for local rules on `Config σ`
- `EventuallyConstBelow`
- existence of eventual values coordinatewise implies a `limitConfig`
- `limit_exists_unique`
- `limit_characterization`
- monotonicity of iterate chains under inflationary `F`
- monotone `Bool` sequence is eventually constant
- `omega_limit_exists`
- optionally `orRule_inflationary` and `orRule_omega_limit_exists`

The goal is not breadth; the goal is a polished, correct, minimal formalization of these precise statements.