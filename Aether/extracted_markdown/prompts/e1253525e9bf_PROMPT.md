
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **lean files (count chosen by the Plan)**
2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
- NO `ARTICLE.md`
- NO `RESEARCH_PAPER.md`
- NO `demo.py` / `algorithms.py`
- NO HTML widgets
- NO `PACKAGE.json`
- NO prose for human readers (except FUTURE_DIRECTIONS.md)

### WHY THIS NARROW:
The Lean 4 file IS the deliverable. A self-contained Lean file with
3-5 world-class theorems is worth more than 30K characters of prose
about trivial results. Focus 100% of your compute on the math.
If your work is genuinely world-class, the packaging step is dispatched
automatically and cheaply.


## Concept

**Title**: The current formalization handles 0-dimensional persistence on discrete state sp
**Domain**: Physics
**Mathematical framing**: # Future Directions: The Boltzmann Bridge

## 1. Higher-Dimensional Persistent Homology on Simplicial Complexes

The current formalization handles 0-dimensional persistence on discrete state spaces, where each point is an independent component. The natural next step is to formalize simplicial complexes (Vietoris-Rips or Čech) built from an energy function's sublevel sets and prove that the total persistence in all homological dimensions is stable under perturbation. The key insight is that the interleaving theorem we proved for rank functions should generalize to an algebraic interleaving of persistence modules, yielding a bottleneck stability theorem for barcodes. Why now? Mathlib's developing simplicial complex infrastructure (via `SimplicialComplex` and `AbstractSimplicialComplex`) provides the combinatorial foundation, and our rank function stability serves as the base case of an inductive argument over skeleta.

## 2. Logarithmic Entropy from Total Persistence via Normalization

The total persistence `∑(M - f(x))` captures the "spread" of an energy landscape, but the Boltzmann entropy `S = k log W` is logarithmic. A testable conjecture: for energy functions on `Fin n` taking values in `{0, 1, ..., K}`, define the *persistence entropy* as `log(totalPersistence f K / K)`. Then for the uniform distribution (constant energy), persistence entropy equals `log n - log K`, while for a delta function (one ground state), it equals `log((n-1)K/K) = log(n-1)`. The key insight is that the ratio `totalPersistence / range` acts as an "effective number of states," and its logarithm should approximate Boltzmann entropy up to a correction term involving the energy variance. Why now? Our `totalPersistence_eq` identity provides the algebraic foundation, and `totalPersistence_eq_zero_iff` characterizes the degenerate case, giving boundary conditions for any entropy approximation.

## 3. Phase Transitions as Discontinuities in the Rank Function

For parametric families of energy functions `E_β(x) = β · E(x)` (inverse temperature scaling), the rank function `t ↦ |{x : E_β(x) ≤ t}|` undergoes qualitative changes at critical values of β. Conjecture: a thermodynamic phase transition at inverse temperature β_c corresponds to a discontinuity in the derivative of the integrated rank function `∫ rankFunction(E_β, t) dt` with respect to β. The key insight is that this integral equals the total persistence (by our identity `totalPersistence_eq`), so phase transitions manifest as non-analyticities of total persistence as a function of the coupling constant. Why now? The interleaving theorem shows that small changes in β produce controlled changes in the rank function, so discontinuities in the derivative require genuinely singular behavior — exactly what characterizes phase transitions.

## 4. Wasserstein Stability for Energy Filtrations

Our rank function stability shows that ε-close energy functions produce ε-interleaved rank functions. A stronger conjecture: the Wasserstein-1 distance between the "persistence measures" (empirical measures on bar endpoints) of two ε-close energy functions is bounded by `n · ε`, where n is the cardinality of the state space. The key insight is that each element contributes one bar whose endpoints shift by at most ε under an ε-perturbation, and the Wasserstein distance decomposes as a sum over individual bar displacements. Why now? This would give quantitative thermodynamic stability: small perturbations to a Hamiltonian produce proportionally small changes in the entropy, with the proportionality constant being the number of microstates.

## 5. Categorical Persistence via Functorial Filtrations

The sublevel set construction `t ↦ sublevelFinset f t` is a functor from `(ℝ, ≤)` to `(Finset α, ⊆)`. Our monotonicity theorem is precisely the functoriality condition. Conjecture: this functor lifts to a persistence module over a field k (via free vector space construction), and the total persistence equals the trace of the "birth-to-death" operator on this module. The key insight is that the rank function is the dimension function of the persistence module, and our stability theorem becomes the algebraic stability theorem for persistence modules. Why now? Formalizing this categorical perspective would connect the concrete Finset-based approach to the abstract algebraic theory, enabling transfer of deep results (decomposition theorems, structure theorems for persistence modules) to the thermodynamic setting.

**Concept description**: # Future Directions: The Boltzmann Bridge

## 1. Higher-Dimensional Persistent Homology on Simplicial Complexes

The current formalization handles 0-dimensional persistence on discrete state spaces, where each point is an independent component. The natural next step is to formalize simplicial complexes (Vietoris-Rips or Čech) built from an energy function's sublevel sets and prove that the total persistence in all homological dimensions is stable under perturbation. The key insight is that the interleaving theorem we proved for rank functions should generalize to an algebraic interleaving of persistence modules, yielding a bottleneck stability theorem for barcodes. Why now? Mathlib's developing simplicial complex infrastructure (via `SimplicialComplex` and `AbstractSimplicialComplex`) provides the combinatorial foundation, and our rank function stability serves as the base case of an inductive argument over skeleta.

## 2. Logarithmic Entropy from Total Persistence via Normalization

The total persistence `∑(M - f(x))` captures the "spread" of an energy landscape, but the Boltzmann entropy `S = k log W` is logarithmic. A testable conjecture: for energy functions on `Fin n` taking values in `{0, 1, ..., K}`, define the *persistence entropy* as `log(totalPersistence f K / K)`. Then for the uniform distribution (constant energy), persistence entropy equals `log n - log K`, while for a delta function (one ground state), it equals `log((n-1)K/K) = log(n-1)`. The key insight is that the ratio `totalPersistence / range` acts as an "effective number of states," and its logarithm should approximate Boltzmann entropy up to a correction term involving the energy variance. Why now? Our `totalPersistence_eq` identity provides the algebraic foundation, and `totalPersistence_eq_zero_iff` characterizes the degenerate case, giving boundary conditions for any entropy approximation.

## 3. Phase Transitions as Discontinuities in the Rank Function

For parametric families of energy functions `E_β(x) = β · E(x)` (inverse temperature scaling), the rank function `t ↦ |{x : E_β(x) ≤ t}|` undergoes qualitative changes at critical values of β. Conjecture: a thermodynamic phase transition at inverse temperature β_c corresponds to a discontinuity in the derivative of the integrated rank function `∫ rankFunction(E_β, t) dt` with respect to β. The key insight is that this integral equals the total persistence (by our identity `totalPersistence_eq`), so phase transitions manifest as non-analyticities of total persistence as a function of the coupling constant. Why now? The interleaving theorem shows that small changes in β produce controlled changes in the rank function, so discontinuities in the derivative require genuinely singular behavior — exactly what characterizes phase transitions.

## 4. Wasserstein Stability for Energy Filtrations

Our rank function stability shows that ε-close energy functions produce ε-interleaved rank functions. A stronger conjecture: the Wasserstein-1 distance between the "persistence measures" (empirical measures on bar endpoints) of two ε-close energy functions is bounded by `n · ε`, where n is the cardinality of the state space. The key insight is that each element contributes one bar whose endpoints shift by at most ε under an ε-perturbation, and the Wasserstein distance decomposes as a sum over individual bar displacements. Why now? This would give quantitative thermodynamic stability: small perturbations to a Hamiltonian produce proportionally small changes in the entropy, with the proportionality constant being the number of microstates.

## 5. Categorical Persistence via Functorial Filtrations

The sublevel set construction `t ↦ sublevelFinset f t` is a functor from `(ℝ, ≤)` to `(Finset α, ⊆)`. Our monotonicity theorem is precisely the functoriality condition. Conjecture: this functor lifts to a persistence module over a field k (via free vector space construction), and the total persistence equals the trace of the "birth-to-death" operator on this module. The key insight is that the rank function is the dimension function of the persistence module, and our stability theorem becomes the algebraic stability theorem for persistence modules. Why now? Formalizing this categorical perspective would connect the concrete Finset-based approach to the abstract algebraic theory, enabling transfer of deep results (decomposition theorems, structure theorems for persistence modules) to the thermodynamic setting.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Physics
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
