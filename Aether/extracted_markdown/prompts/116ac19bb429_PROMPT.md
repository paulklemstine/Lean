Formalize a coherent Lean 4 development for ordinal-indexed cellular automata on the specific index space ω = ℕ, with a finite state alphabet and an explicit eventual-stabilization limit rule. Do not switch to unrelated logic or bilattice material. The deliverable must be a single self-contained, fully compiling Lean file with complete theorem statements and proofs, no placeholders, no theorem headers without bodies, and no copied material from unrelated domains.

Problem focus:
Build the smallest mathematically meaningful core of transfinite cellular automata that is actually provable in Lean. Avoid super-Turing or universality claims. Work only with configurations on ℕ and local rules of finite radius, preferably radius 1 for simplicity.

Required definitions:
1. A configuration type `Config σ := ℕ → σ`.
2. A local update rule of radius 1, e.g. `step : (σ → σ → σ → σ) → Config σ → Config σ`, with a clear boundary convention at cell 0.
3. A transfinite evolution schema indexed by ordinals, but only as far as can be justified by eventual stabilization. At successor stages use `step`; at a limit ordinal λ define `evolution λ n` to be the eventual constant value of the coordinate history `α ↦ evolution α n` for `α < λ`, provided such a value exists.
4. A precise predicate expressing eventual constancy of a coordinate history below a limit ordinal.

Main theorem targets:
A. Well-posed coordinatewise limit theorem:
   Prove that if for every coordinate `n` the history below a limit ordinal `λ` is eventually constant, then there exists a unique limit configuration at stage `λ`, defined coordinatewise by those eventual values.
B. Compatibility theorem:
   Show this limit configuration is uniquely characterized by the eventual-value property and is compatible with the successor dynamics already defined.
C. Concrete existence criterion:
   Specialize to `σ = Bool` with the pointwise order on configurations. For a monotone inflationary step operator `F : Config Bool → Config Bool` (or a concrete local boolean rule satisfying inflationarity), prove that the iterates from any initial configuration form an ascending chain and each coordinate stabilizes by stage ω; therefore the ω-stage limit configuration exists.
D. Optional concrete example:
   Give one explicit radius-1 boolean rule, such as `new n = old n ∨ old (n+1)` or another simple inflationary local rule with your chosen boundary convention, and prove the ω-limit exists from every initial configuration.

Proof strategy guidance:
- Keep the ordinal layer minimal. It is acceptable to formalize only what is needed for successor stages, limit ordinals, and eventual constancy.
- Prefer a construction where the limit configuration is introduced from a hypothesis of coordinatewise eventual constancy, rather than trying to define a total evolution for all ordinals and all rules.
- For the ω-stabilization result, use monotonicity/inflationarity to show each boolean coordinate yields a monotone sequence in a finite set, hence eventually constant.
- Favor precise lemmas about eventual constancy and uniqueness over ambitious global recursion principles.

Scope constraints:
- Stay entirely within transfinite cellular automata / ordinal-indexed dynamics.
- Do not introduce unrelated Belnap, paraconsistency, bilattice, or other logic developments.
- Do not claim general existence of transfinite evolution for arbitrary local rules unless fully proved.
- If a fully general ordinal-recursive definition is cumbersome, it is acceptable to define and prove theorems only for finite stages plus a single limit stage ω, provided the statements are mathematically clean and nontrivial.

Expected output quality:
- Complete Lean code only for the target development.
- Include docstrings/comments explaining the mathematical setup.
- Ensure theorem names match actual proved statements.
- The file should compile as a standalone contribution and clearly realize the original concept in a narrow, correct form.

If needed, prefer the even more conservative variant: formalize evolution through finite iterates plus the ω-limit under coordinatewise eventual stabilization, and prove uniqueness/existence there. That is better than an overambitious but incomplete ordinal development.