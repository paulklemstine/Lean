
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

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: Formalize the Paley construction: for any prime power q ≡ 3 (mod 4), there exist
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Hadamard Matrix Theory in Lean 4

## 1. Paley Construction and Quadratic Residues

Formalize the Paley construction: for any prime power q ≡ 3 (mod 4), there exists a Hadamard matrix of order q + 1. This requires formalizing Jacobi matrices from quadratic residue characters over finite fields and proving the resulting conference matrix satisfies the Hadamard orthogonality condition.

The key insight is that the quadratic residue character χ of GF(q) naturally produces a conference matrix C with C·Cᵀ = (q-1)I + J, and the bordered matrix [1 jᵀ; j C+I] is Hadamard of order q+1.

Why now? Mathlib already has substantial finite field theory (`ZMod`, `legendreSym`, `quadraticChar`) and the Hadamard infrastructure (definitions, tensor closure, obstruction) is fully formalized in this project. The Paley construction would be the first non-power-of-two infinite family of Hadamard orders, dramatically expanding the set of proven Hadamard orders beyond the Sylvester family.

## 2. Hadamard Maximal Determinant Bound

Prove the full Hadamard bound: for any n×n matrix M with |M_{ij}| ≤ 1, we have |det M| ≤ n^(n/2), with equality if and only if M is a (real) Hadamard matrix. We already proved det(H)² = n^n for ±1 Hadamard matrices. The converse direction — that equality in the determinant bound forces the Hadamard orthogonality condition — would complete the characterization.

The key insight is that the AM-GM inequality applied to the Gram matrix eigenvalues gives det(MMᵀ) ≤ (tr(MMᵀ)/n)^n = n^n, with equality iff all eigenvalues are equal (i.e., MMᵀ = nI).

Why now? The forward direction (det² = n^n) is already proved in `Spectral.lean`. Formalizing the bound requires Mathlib's spectral theory for Hermitian matrices and eigenvalue inequalities, which are increasingly available.

## 3. Equivalence Classification for Small Orders

Formalize the classification of Hadamard equivalence classes for small orders. For n = 1, 2, 4, 8, there is exactly one equivalence class; for n = 12, there are exactly 1 class; for n = 16, there are exactly 5 inequivalent Hadamard matrices. Prove the uniqueness results for n ≤ 12 by exhaustive case analysis on normalized forms.

The key insight is that after normalization (first row and column all 1s), the remaining (n-1)×(n-1) submatrix has very constrained structure: its rows must be orthogonal ±1 vectors that are all orthogonal to the all-ones vector, and for small n this forces a unique solution up to equivalence.

Why now? The `HadamardEquivalent` relation and `IsNormalizedHadamard` are already defined. For n = 4, the proof is a finite computation; `native_decide` or `Decidable` instances could handle it. This would be the first verified classification result in Hadamard theory.

## 4. Hadamard–BIBD Bridge Theorem

Complete the bridge between Hadamard matrices and symmetric balanced incomplete block designs. We have the counting lemmas (row-pair intersection counts). The missing piece is constructing the actual BIBD: from a normalized Hadamard matrix of order 4t, extract the incidence matrix of a symmetric 2-(4t-1, 2t-1, t-1) design and verify all BIBD axioms.

The key insight is that the ±1 → {0,1} conversion of the non-trivial rows/columns of a normalized Hadamard matrix directly yields the incidence matrix, and the Hadamard orthogonality conditions translate exactly into the BIBD pair-counting condition.

Why now? The `SymmetricBIBD` structure and the `normalized_row_pair_ones` theorem (showing the intersection count is n/4) are already formalized in `Design.lean`. The construction of the actual BIBD instance is the natural next step.

## 5. Williamson Construction and Circulant Hadamard Matrices

Formalize the Williamson construction: given four symmetric circulant ±1 matrices A, B, C, D of order n satisfying AᵀA + BᵀB + CᵀC + DᵀD = 4nI, construct a Hadamard matrix of order 4n. This construction covers many orders not reachable by Sylvester or Paley alone.

The key insight is that the block matrix [[A B C D]; [-B A -D C]; [-C D A -B]; [-D -C B A]] is Hadamard whenever the Williamson equation holds, because the block structure ensures row orthogonality via the four-square identity.

Why now? The tensor product infrastructure (Kronecker product, `hadamardOrder'_mul`) provides the algebraic foundation. Formalizing circulant matrices and the Williamson equation would open the door to verifying Hadamard existence for specific orders like 12, 20, 28, 36 — filling gaps in the construction landscape beyond powers of two.

**Concept description**: # Future Directions: Hadamard Matrix Theory in Lean 4

## 1. Paley Construction and Quadratic Residues

Formalize the Paley construction: for any prime power q ≡ 3 (mod 4), there exists a Hadamard matrix of order q + 1. This requires formalizing Jacobi matrices from quadratic residue characters over finite fields and proving the resulting conference matrix satisfies the Hadamard orthogonality condition.

The key insight is that the quadratic residue character χ of GF(q) naturally produces a conference matrix C with C·Cᵀ = (q-1)I + J, and the bordered matrix [1 jᵀ; j C+I] is Hadamard of order q+1.

Why now? Mathlib already has substantial finite field theory (`ZMod`, `legendreSym`, `quadraticChar`) and the Hadamard infrastructure (definitions, tensor closure, obstruction) is fully formalized in this project. The Paley construction would be the first non-power-of-two infinite family of Hadamard orders, dramatically expanding the set of proven Hadamard orders beyond the Sylvester family.

## 2. Hadamard Maximal Determinant Bound

Prove the full Hadamard bound: for any n×n matrix M with |M_{ij}| ≤ 1, we have |det M| ≤ n^(n/2), with equality if and only if M is a (real) Hadamard matrix. We already proved det(H)² = n^n for ±1 Hadamard matrices. The converse direction — that equality in the determinant bound forces the Hadamard orthogonality condition — would complete the characterization.

The key insight is that the AM-GM inequality applied to the Gram matrix eigenvalues gives det(MMᵀ) ≤ (tr(MMᵀ)/n)^n = n^n, with equality iff all eigenvalues are equal (i.e., MMᵀ = nI).

Why now? The forward direction (det² = n^n) is already proved in `Spectral.lean`. Formalizing the bound requires Mathlib's spectral theory for Hermitian matrices and eigenvalue inequalities, which are increasingly available.

## 3. Equivalence Classification for Small Orders

Formalize the classification of Hadamard equivalence classes for small orders. For n = 1, 2, 4, 8, there is exactly one equivalence class; for n = 12, there are exactly 1 class; for n = 16, there are exactly 5 inequivalent Hadamard matrices. Prove the uniqueness results for n ≤ 12 by exhaustive case analysis on normalized forms.

The key insight is that after normalization (first row and column all 1s), the remaining (n-1)×(n-1) submatrix has very constrained structure: its rows must be orthogonal ±1 vectors that are all orthogonal to the all-ones vector, and for small n this forces a unique solution up to equivalence.

Why now? The `HadamardEquivalent` relation and `IsNormalizedHadamard` are already defined. For n = 4, the proof is a finite computation; `native_decide` or `Decidable` instances could handle it. This would be the first verified classification result in Hadamard theory.

## 4. Hadamard–BIBD Bridge Theorem

Complete the bridge between Hadamard matrices and symmetric balanced incomplete block designs. We have the counting lemmas (row-pair intersection counts). The missing piece is constructing the actual BIBD: from a normalized Hadamard matrix of order 4t, extract the incidence matrix of a symmetric 2-(4t-1, 2t-1, t-1) design and verify all BIBD axioms.

The key insight is that the ±1 → {0,1} conversion of the non-trivial rows/columns of a normalized Hadamard matrix directly yields the incidence matrix, and the Hadamard orthogonality conditions translate exactly into the BIBD pair-counting condition.

Why now? The `SymmetricBIBD` structure and the `normalized_row_pair_ones` theorem (showing the intersection count is n/4) are already formalized in `Design.lean`. The construction of the actual BIBD instance is the natural next step.

## 5. Williamson Construction and Circulant Hadamard Matrices

Formalize the Williamson construction: given four symmetric circulant ±1 matrices A, B, C, D of order n satisfying AᵀA + BᵀB + CᵀC + DᵀD = 4nI, construct a Hadamard matrix of order 4n. This construction covers many orders not reachable by Sylvester or Paley alone.

The key insight is that the block matrix [[A B C D]; [-B A -D C]; [-C D A -B]; [-D -C B A]] is Hadamard whenever the Williamson equation holds, because the block structure ensures row orthogonality via the four-square identity.

Why now? The tensor product infrastructure (Kronecker product, `hadamardOrder'_mul`) provides the algebraic foundation. Formalizing circulant matrices and the Williamson equation would open the door to verifying Hadamard existence for specific orders like 12, 20, 28, 36 — filling gaps in the construction landscape beyond powers of two.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Novelty
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
