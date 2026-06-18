
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
