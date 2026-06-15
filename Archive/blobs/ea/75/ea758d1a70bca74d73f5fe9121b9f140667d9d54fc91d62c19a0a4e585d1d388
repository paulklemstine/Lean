
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

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

**Title**: The natural next step is to construct the simplicial chain complex from our `ASC
**Domain**: Logic
**Mathematical framing**: # Future Directions: Clique Complex Theory in Lean 4

## 1. Simplicial Chain Complexes and Homology Groups

The natural next step is to construct the simplicial chain complex from our `ASC'` type. The k-th chain group C_k is the free abelian group on oriented k-simplices (ordered (k+1)-tuples of vertices spanning a face), and the boundary operator ∂_k : C_k → C_{k-1} is defined by the alternating sum of face deletions: ∂_k[v_0, ..., v_k] = Σᵢ (-1)^i [v_0, ..., v̂ᵢ, ..., v_k].

The key insight is that Mathlib's `FreeAbelianGroup` and `HomologicalComplex` provide the algebraic scaffolding — what's missing is the combinatorial construction of ∂ from our face data, and the proof that ∂² = 0 (which follows from the double-alternating-sign cancellation). Our `ASC'.link` and `ASC'.down_closed` already encode exactly the face-deletion structure needed.

Why now? The `cliqueComplex'` construction and `link` operator are formalized and compiled. The boundary map is a concrete linear map on free abelian groups, and ∂² = 0 is a finite combinatorial identity — no deep analysis is needed, only careful bookkeeping of signs and indices.

## 2. Flag Complex Characterization (Converse Direction)

We proved that every clique complex satisfies the flag property (`cliqueComplex_isFlag`). The converse — that every flag complex IS the clique complex of its 1-skeleton — would complete the characterization theorem: K is a flag complex ⟺ K = Δ(Skel₁(K)).

The key insight is that the forward direction (our theorem) shows Δ(G) ⊆ K for any flag complex K with 1-skeleton G, while the converse direction K ⊆ Δ(G) requires showing that if σ is a face of K, then all 2-element subsets of σ are faces (by downward closure), hence all pairs are 1-skeleton-adjacent, and by the flag property σ ∈ Δ(Skel₁(K)). The proof is a one-line appeal to downward closure.

Why now? Both `oneSkeletonGraph` and `isFlag` are defined and the forward direction compiles. The converse is a straightforward application of `down_closed` and the definitions.

## 3. Persistent Homology via Vietoris-Rips Filtrations

Our `vietorisRips_mono` theorem establishes that the Vietoris-Rips complex is monotone in the scale parameter ε, giving a filtration VR(X, ε₁) ⊆ VR(X, ε₂) ⊆ ⋯ for ε₁ ≤ ε₂. Combined with the chain complex construction from Direction 1, this would yield a filtered chain complex whose persistent homology captures topological features at multiple scales.

The key insight is that once ∂ is defined and ∂² = 0 is proved, the persistent homology module is simply the diagram of homology groups H_k(VR(X, εᵢ)) connected by the maps induced by inclusion. Mathlib's `CategoryTheory.Functor` framework can model this as a functor from (ℝ, ≤) to abelian groups.

Why now? The filtration monotonicity is proven. The remaining gap is the chain complex construction (Direction 1), after which persistent homology follows by functoriality.

## 4. Turán-Type Bounds on f-Vectors of Clique Complexes

Our `ASC.fVector_le_choose` gives f_k ≤ C(n, k+1), tight only for complete graphs. For graphs with bounded clique number ω(G) ≤ r, we have f_k = 0 for all k ≥ r. The natural question is: what is the maximum f_k over all n-vertex graphs with ω(G) ≤ r? The answer should be given by the Turán graph T(n, r).

The key insight is that `cliqueComplex_face_card_le_of_cliqueFree` already gives the vanishing result (f_k = 0 for k ≥ r when G is (r+1)-clique-free). The extremal question — showing that the Turán graph maximizes f_k subject to ω ≤ r — requires connecting our clique complex f-vector to Turán's theorem, which has partial Mathlib support.

Why now? The face-card bound and clique-free dimension bound are proven. The Turán graph is a concrete, constructible object, and its face counts are computable binomial expressions.

## 5. Nerve Lemma and Good Cover Theorem

The nerve of a finite open cover {U_i} is the simplicial complex whose faces are the subsets I with ∩_{i ∈ I} U_i ≠ ∅. The Nerve Lemma states that if the cover is "good" (all non-empty intersections are contractible), then the nerve is homotopy-equivalent to the union ∪ U_i.

The key insight is that the clique complex Δ(G) is itself the nerve of the cover of the edge set by maximal cliques. Formalizing this perspective would connect our combinatorial ASC definitions to the topological homotopy type, establishing that clique complexes are not just combinatorial objects but carry genuine topological information via the nerve construction.

Why now? Our `ASC'` type with its `link` and `isFlag` infrastructure provides the combinatorial skeleton. The nerve construction is a concrete functor from covers to simplicial complexes, and its formalization would be the first verified nerve lemma in Lean 4.

**Concept description**: # Future Directions: Clique Complex Theory in Lean 4

## 1. Simplicial Chain Complexes and Homology Groups

The natural next step is to construct the simplicial chain complex from our `ASC'` type. The k-th chain group C_k is the free abelian group on oriented k-simplices (ordered (k+1)-tuples of vertices spanning a face), and the boundary operator ∂_k : C_k → C_{k-1} is defined by the alternating sum of face deletions: ∂_k[v_0, ..., v_k] = Σᵢ (-1)^i [v_0, ..., v̂ᵢ, ..., v_k].

The key insight is that Mathlib's `FreeAbelianGroup` and `HomologicalComplex` provide the algebraic scaffolding — what's missing is the combinatorial construction of ∂ from our face data, and the proof that ∂² = 0 (which follows from the double-alternating-sign cancellation). Our `ASC'.link` and `ASC'.down_closed` already encode exactly the face-deletion structure needed.

Why now? The `cliqueComplex'` construction and `link` operator are formalized and compiled. The boundary map is a concrete linear map on free abelian groups, and ∂² = 0 is a finite combinatorial identity — no deep analysis is needed, only careful bookkeeping of signs and indices.

## 2. Flag Complex Characterization (Converse Direction)

We proved that every clique complex satisfies the flag property (`cliqueComplex_isFlag`). The converse — that every flag complex IS the clique complex of its 1-skeleton — would complete the characterization theorem: K is a flag complex ⟺ K = Δ(Skel₁(K)).

The key insight is that the forward direction (our theorem) shows Δ(G) ⊆ K for any flag complex K with 1-skeleton G, while the converse direction K ⊆ Δ(G) requires showing that if σ is a face of K, then all 2-element subsets of σ are faces (by downward closure), hence all pairs are 1-skeleton-adjacent, and by the flag property σ ∈ Δ(Skel₁(K)). The proof is a one-line appeal to downward closure.

Why now? Both `oneSkeletonGraph` and `isFlag` are defined and the forward direction compiles. The converse is a straightforward application of `down_closed` and the definitions.

## 3. Persistent Homology via Vietoris-Rips Filtrations

Our `vietorisRips_mono` theorem establishes that the Vietoris-Rips complex is monotone in the scale parameter ε, giving a filtration VR(X, ε₁) ⊆ VR(X, ε₂) ⊆ ⋯ for ε₁ ≤ ε₂. Combined with the chain complex construction from Direction 1, this would yield a filtered chain complex whose persistent homology captures topological features at multiple scales.

The key insight is that once ∂ is defined and ∂² = 0 is proved, the persistent homology module is simply the diagram of homology groups H_k(VR(X, εᵢ)) connected by the maps induced by inclusion. Mathlib's `CategoryTheory.Functor` framework can model this as a functor from (ℝ, ≤) to abelian groups.

Why now? The filtration monotonicity is proven. The remaining gap is the chain complex construction (Direction 1), after which persistent homology follows by functoriality.

## 4. Turán-Type Bounds on f-Vectors of Clique Complexes

Our `ASC.fVector_le_choose` gives f_k ≤ C(n, k+1), tight only for complete graphs. For graphs with bounded clique number ω(G) ≤ r, we have f_k = 0 for all k ≥ r. The natural question is: what is the maximum f_k over all n-vertex graphs with ω(G) ≤ r? The answer should be given by the Turán graph T(n, r).

The key insight is that `cliqueComplex_face_card_le_of_cliqueFree` already gives the vanishing result (f_k = 0 for k ≥ r when G is (r+1)-clique-free). The extremal question — showing that the Turán graph maximizes f_k subject to ω ≤ r — requires connecting our clique complex f-vector to Turán's theorem, which has partial Mathlib support.

Why now? The face-card bound and clique-free dimension bound are proven. The Turán graph is a concrete, constructible object, and its face counts are computable binomial expressions.

## 5. Nerve Lemma and Good Cover Theorem

The nerve of a finite open cover {U_i} is the simplicial complex whose faces are the subsets I with ∩_{i ∈ I} U_i ≠ ∅. The Nerve Lemma states that if the cover is "good" (all non-empty intersections are contractible), then the nerve is homotopy-equivalent to the union ∪ U_i.

The key insight is that the clique complex Δ(G) is itself the nerve of the cover of the edge set by maximal cliques. Formalizing this perspective would connect our combinatorial ASC definitions to the topological homotopy type, establishing that clique complexes are not just combinatorial objects but carry genuine topological information via the nerve construction.

Why now? Our `ASC'` type with its `link` and `isFlag` infrastructure provides the combinatorial skeleton. The nerve construction is a concrete functor from covers to simplicial complexes, and its formalization would be the first verified nerve lemma in Lean 4.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Logic
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v8 Depth Requirements -- Research Team Protocol

You are leading a research team. Your team has different roles:
- The **Hypothesizer** generates bold, falsifiable conjectures
- The **Experimenter** proves or disproves them in Lean 4
- The **Analyst** examines what survived, what failed, and WHY
- The **Critic** searches for weaknesses, constructs counterexamples,
  and identifies where proofs might break down. A well-constructed
  counterexample is as valuable as a proof.
- The **Synthesist** upgrades the knowledge base and writes the
  FUTURE_DIRECTIONS.md that seeds the next cycle

You run this loop: **Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate**.
Each cycle is not a one-shot task. It is one iteration of an infinite
research process. Your notes (FUTURE_DIRECTIONS.md, Lab Notebooks,
proof sketches) determine whether the next team builds on your work
or starts over.

**Take good notes.** A cycle without useful notes is a wasted cycle.

### STEP 1: THEOREM DECLARATIONS (required -- before any code)

List every theorem you intend to prove or investigate. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `hypothesis` | `conjecture` | `proved` | `proved_with_lemma_sorry` | `disproved`
- **Why it matters**: One sentence on what this result would mean if true,
  and what it would teach us if false

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective -- proved -- constructive inverse -- confirms decidability of Nat x Nat
2. `cantorPairing_injective`: Cantor pairing is injective -- proved -- diagonal argument -- confirms invertibility
3. `cantorPairing_bijection`: Cantor pairing is a bijection -- proved_with_lemma_sorry -- follows from 1+2 -- completing the characterization

Use `hypothesis` for statements you are not yet sure you can prove but
want to investigate. Use `conjecture` for statements you believe are true
but cannot prove in this cycle. Use `disproved` for statements where you
found a counterexample. Use `proved` for statements with complete Lean
proofs. Use `proved_with_lemma_sorry` when the main proof is complete but
one or more supporting lemmas use `sorry`.

### STEP 2: EXPERIMENT (prove or disprove in Lean 4)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its
status to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it is deferred

**Disproofs count.** If a hypothesis is false, prove its negation or
construct an explicit counterexample. A well-constructed counterexample
is as valuable as a proof. Change the status to `disproved` and state
the counterexample clearly.

### STEP 3: CRITIQUE (find the weaknesses)

For your best theorem, the Critic must:
- Identify the strongest assumption that could be weakened
- Construct a boundary case: where does the result break down?
- If possible, state a `conjecture` for the generalized version and
  explain what would need to change in the proof

This is NOT optional. A theorem without a critique is incomplete.

### STEP 4: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` -- unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures, generalizations, and boundary cases.

### STEP 5: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### STEP 6: TAKE GOOD NOTES (first-class deliverables)

Your notes determine what the next research team investigates. They are NOT
an afterthought. They are your most important output after the proofs themselves.

**6a. Lab Notebook** (in each .lean file, as `-- !-- Lab Notebook -- !--` blocks):

For each major theorem, include a Lab Notebook comment block:
```lean
-- !-- Lab Notebook: cantorPairing_bijection -- !--
-- !-- Hypothesis: Cantor pairing is bijective because both surjective and injective -- !--
-- !-- Result: Proved via composition of surjective and injective proofs -- !--
-- !-- Insight: The constructive inverse of surjectivity is key; diagonal argument handles injectivity -- !--
-- !-- Failure analysis: Initial attempt to prove bijection directly failed; decomposition into surjective+injective was necessary -- !--
-- !-- End Lab Notebook -- !--
```

**6b. FUTURE_DIRECTIONS.md** (MANDATORY — your output WILL BE REJECTED if missing):

You MUST produce a FUTURE_DIRECTIONS.md file with this EXACT structure.
Copy the section headers below verbatim. Do NOT use freeform prose.

## Synthesis

[2-3 paragraphs: what did this cycle discover? What failed and why? What
structural insight emerged? Tie the directions together into a narrative.]

## Results Summary

[For EACH theorem: name, status (proved/conjecture/disproved), one-sentence
significance. Format as a bullet list:]

- `theoremName`: status — one-sentence significance

## Research Directions

### Direction 1: [Concise title]
**Hypothesis**: A precise, falsifiable mathematical statement.
**Test**: What experiment (proof/disproof/computation) would confirm or refute it.
**Why now**: What from THIS cycle makes this tractable.
**If true**: What new territory this opens.
**If false**: What the failure teaches us.

[Repeat for 3-5 directions]

IMPORTANT: The ## Synthesis and ## Results Summary sections are NOT optional.
If your FUTURE_DIRECTIONS.md is missing either section, it will be treated as
incomplete and the next research team will have no context to build on your work.

### STEP 7: Generalization loop

For your BEST theorem, attempt one level of generalization:
- State a stronger version (can use sorry if proving would take too long)
- Identify the boundary: where does the result break down?
- If the generalization is itself interesting, mark it as a `conjecture`
  in your theorem declarations and explain it in FUTURE_DIRECTIONS.md

### Output format

Your output must include:
1. `.lean` files with proofs and Lab Notebook blocks (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with Synthesis, Results Summary, and 3-5 research
   directions (structured as in Step 6b)

Both are required. A cycle with proofs but no Lab Notebook or
FUTURE_DIRECTIONS.md is a cycle where the next team starts from scratch.
Take good notes.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
