
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

**Title**: Belnap's FOUR₂ is the smallest non-trivial paraconsistent bilattice. A natural g
**Domain**: Geometry
**Mathematical framing**: # Future Directions: Dream Logic and Paraconsistent Reasoning

## 1. N-valued Paraconsistent Lattices and Their Topological Duals

Belnap's FOUR₂ is the smallest non-trivial paraconsistent bilattice. A natural generalization is the family of 2^n-valued bilattices arising from n independent "information sources," each contributing a classical truth value. The key insight is that these n-source bilattices are isomorphic to products of 2-element lattices, and their consistent fragments should correspond to (n-1)-dimensional simplicial complexes rather than pretopological spaces. Why now? The formalization of FOUR₂ as a `DistribLattice` in this work provides the template for a `Fintype`-parametric construction, and Mathlib's existing simplicial complex API could immediately support the topological side.

Conjecture: For n ≥ 3, the consistent fragment of the 2^n-valued bilattice has a pretopological closure whose iterated application stabilizes in exactly ⌈log₂ n⌉ steps (the "dream depth" of the logic).

## 2. Paraconsistent Fixed Points and Non-Monotone Induction

Classical fixed-point theorems (Knaster-Tarski, Kleene) rely on monotonicity of the operator. Our `nonmonotonicity` theorem shows that consistent credulous consequence is non-monotone, but it still has fixed points — they are just not unique or lattice-theoretic. The key insight is that the set of "stable extensions" of a paraconsistent knowledge base (analogous to Reiter's stable extensions in default logic) can be characterized as the fixed points of a non-monotone operator on the powerset of Belnap valuations, and these form an antichain in the subset ordering. Why now? Mathlib has extensive fixed-point infrastructure (`OrderHom.lfp`, `OrderHom.gfp`) that could be adapted to characterize the structure of these non-monotone fixed points via Zorn's lemma applied to consistent chains.

Conjecture: For any finite knowledge base over Belnap valuations, the number of maximal consistent extensions is either 0 or at least 2 (there is no unique consistent extension when contradictions are present).

## 3. Categorical Semantics: Paraconsistent Topoi

A topos is a category whose internal logic is intuitionistic. Our work shows that paraconsistent logics break explosion, which is valid in any topos. The key insight is that replacing the subobject classifier Ω (a Heyting algebra) with a "paraconsistent classifier" (a De Morgan algebra that is NOT a Heyting algebra) should yield a category where the internal logic is paraconsistent — a "paraconsistent topos." The existence of such categories would give a categorical foundation for dream-like reasoning. Why now? Mathlib has extensive topos infrastructure, and our `Belnap` type with its `DistribLattice` and `neg` involution provides a concrete candidate for the non-Heyting classifier.

Conjecture: There exists a finitely complete category with a Belnap-valued subobject classifier that satisfies all topos axioms except the requirement that Ω be a Heyting algebra, and whose internal logic validates `p ∧ ¬p ≠ ⊥` for some internal proposition p.

## 4. Metric Dream Spaces and Convergence of Belief Revision

Our pretopology `graphPretopology` is non-idempotent, meaning iterated closure discovers new elements. This suggests a natural metric: the "dream distance" d(x, S) = min{n | x ∈ cl^n(S)} measures how many reasoning steps are needed to reach conclusion x from premises S. The key insight is that this dream distance satisfies a weakened triangle inequality (d(x, S) ≤ d(x, cl(S)) + 1 rather than d(x, S) ≤ d(x, T) + d(T, S)) and defines a quasi-metric space whose Cauchy sequences correspond to convergent belief revision processes. Why now? The formalized `graphPretopology` and `graph_not_topology` provide a concrete playground, and Mathlib's `PseudoMetricSpace` infrastructure could be leveraged to study convergence properties.

Conjecture: For any extensive monotone closure operator cl on a countable set, the dream distance defines a quasi-metric whose completion is a compact topological space (the "dream compactification"), and cl is idempotent if and only if the dream distance takes values in {0, 1, ∞}.

## 5. Computational Complexity of Paraconsistent Reasoning

The `consistentlyTrue` predicate asks whether a consistent valuation exists satisfying given constraints — this is a constraint satisfaction problem. The key insight is that the four-valued structure of Belnap makes this problem intermediate between 2-SAT (polynomial) and 3-SAT (NP-complete): checking whether a knowledge base has ANY satisfying Belnap valuation is polynomial (just take the join of all constraints), but checking whether it has a CONSISTENT satisfying valuation is NP-complete (it reduces to NAE-SAT). Why now? The formalization of `satisfiesKB` and `consistentlyTrue` provides the definitional infrastructure, and Lean 4's computational reduction capabilities could enable verified complexity-theoretic reductions.

Conjecture: The problem "given a finite knowledge base kb and variable x, is consistentlyTrue kb x?" is NP-complete, and remains NP-complete even when restricted to knowledge bases where each variable appears in at most 3 constraints.

**Concept description**: # Future Directions: Dream Logic and Paraconsistent Reasoning

## 1. N-valued Paraconsistent Lattices and Their Topological Duals

Belnap's FOUR₂ is the smallest non-trivial paraconsistent bilattice. A natural generalization is the family of 2^n-valued bilattices arising from n independent "information sources," each contributing a classical truth value. The key insight is that these n-source bilattices are isomorphic to products of 2-element lattices, and their consistent fragments should correspond to (n-1)-dimensional simplicial complexes rather than pretopological spaces. Why now? The formalization of FOUR₂ as a `DistribLattice` in this work provides the template for a `Fintype`-parametric construction, and Mathlib's existing simplicial complex API could immediately support the topological side.

Conjecture: For n ≥ 3, the consistent fragment of the 2^n-valued bilattice has a pretopological closure whose iterated application stabilizes in exactly ⌈log₂ n⌉ steps (the "dream depth" of the logic).

## 2. Paraconsistent Fixed Points and Non-Monotone Induction

Classical fixed-point theorems (Knaster-Tarski, Kleene) rely on monotonicity of the operator. Our `nonmonotonicity` theorem shows that consistent credulous consequence is non-monotone, but it still has fixed points — they are just not unique or lattice-theoretic. The key insight is that the set of "stable extensions" of a paraconsistent knowledge base (analogous to Reiter's stable extensions in default logic) can be characterized as the fixed points of a non-monotone operator on the powerset of Belnap valuations, and these form an antichain in the subset ordering. Why now? Mathlib has extensive fixed-point infrastructure (`OrderHom.lfp`, `OrderHom.gfp`) that could be adapted to characterize the structure of these non-monotone fixed points via Zorn's lemma applied to consistent chains.

Conjecture: For any finite knowledge base over Belnap valuations, the number of maximal consistent extensions is either 0 or at least 2 (there is no unique consistent extension when contradictions are present).

## 3. Categorical Semantics: Paraconsistent Topoi

A topos is a category whose internal logic is intuitionistic. Our work shows that paraconsistent logics break explosion, which is valid in any topos. The key insight is that replacing the subobject classifier Ω (a Heyting algebra) with a "paraconsistent classifier" (a De Morgan algebra that is NOT a Heyting algebra) should yield a category where the internal logic is paraconsistent — a "paraconsistent topos." The existence of such categories would give a categorical foundation for dream-like reasoning. Why now? Mathlib has extensive topos infrastructure, and our `Belnap` type with its `DistribLattice` and `neg` involution provides a concrete candidate for the non-Heyting classifier.

Conjecture: There exists a finitely complete category with a Belnap-valued subobject classifier that satisfies all topos axioms except the requirement that Ω be a Heyting algebra, and whose internal logic validates `p ∧ ¬p ≠ ⊥` for some internal proposition p.

## 4. Metric Dream Spaces and Convergence of Belief Revision

Our pretopology `graphPretopology` is non-idempotent, meaning iterated closure discovers new elements. This suggests a natural metric: the "dream distance" d(x, S) = min{n | x ∈ cl^n(S)} measures how many reasoning steps are needed to reach conclusion x from premises S. The key insight is that this dream distance satisfies a weakened triangle inequality (d(x, S) ≤ d(x, cl(S)) + 1 rather than d(x, S) ≤ d(x, T) + d(T, S)) and defines a quasi-metric space whose Cauchy sequences correspond to convergent belief revision processes. Why now? The formalized `graphPretopology` and `graph_not_topology` provide a concrete playground, and Mathlib's `PseudoMetricSpace` infrastructure could be leveraged to study convergence properties.

Conjecture: For any extensive monotone closure operator cl on a countable set, the dream distance defines a quasi-metric whose completion is a compact topological space (the "dream compactification"), and cl is idempotent if and only if the dream distance takes values in {0, 1, ∞}.

## 5. Computational Complexity of Paraconsistent Reasoning

The `consistentlyTrue` predicate asks whether a consistent valuation exists satisfying given constraints — this is a constraint satisfaction problem. The key insight is that the four-valued structure of Belnap makes this problem intermediate between 2-SAT (polynomial) and 3-SAT (NP-complete): checking whether a knowledge base has ANY satisfying Belnap valuation is polynomial (just take the join of all constraints), but checking whether it has a CONSISTENT satisfying valuation is NP-complete (it reduces to NAE-SAT). Why now? The formalization of `satisfiesKB` and `consistentlyTrue` provides the definitional infrastructure, and Lean 4's computational reduction capabilities could enable verified complexity-theoretic reductions.

Conjecture: The problem "given a finite knowledge base kb and variable x, is consistentlyTrue kb x?" is NP-complete, and remains NP-complete even when restricted to knowledge bases where each variable appears in at most 3 constraints.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Geometry
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
