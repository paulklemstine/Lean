## Assignment: **prove**

### Title
**Paley Type II over finite fields, generic difference-set Gram identities, and certified strongly regular extraction**

Prove a cluster of new theorems that turns the current Paley/Hadamard line into a reusable formal factory. The goal is not merely to certify isolated matrices, but to build the finite-field, difference-set, and graph-theoretic infrastructure that makes Hadamard constructions compositional in Lean 4.

---

## Central Breakthrough Target

The real breakthrough is to formalize **Paley Type II over arbitrary finite fields `𝔽_q` with `q ≡ 1 [MOD 4]`**, not just prime fields, and to do so through a **generic difference-set convolution theorem** that also produces **strongly regular graph / tournament certificates**. If you succeed, Lean will gain a formal bridge:

- **finite field character theory**
- **difference sets**
- **Hadamard matrices**
- **strongly regular graphs**
- **spectral combinatorics**

This is a field-opening platform, not a one-off construction.

---

## Theorem Cluster to Formalize

### Theorem A: Paley Type II Hadamard theorem over `𝔽_q`

Let `q` be a prime power with `q ≡ 1 (mod 4)`. Let `χ : 𝔽_q → ℤ` be the quadratic character extended by `χ 0 = 0`, and let `Q` be the Jacobsthal matrix indexed by `𝔽_q ⊕ Unit`, or equivalently the standard Paley Type II conference matrix of order `q+1`. Define the doubled block matrix
\[
H = \begin{pmatrix}
Q + I & Q - I\\
Q - I & -(Q + I)
\end{pmatrix}.
\]
Then
\[
H H^\top = 2(q+1) I,
\]
so `H` is a Hadamard matrix of order `2(q+1)`.

### Lean 4 target signature (suggested)
```lean
theorem paley_typeII_hadamard
  {q : ℕ}
  [Fact q.PrimePower]
  (hq1 : q % 4 = 1)
  :
  ∃ (α : Type) (_ : Fintype α) (_ : DecidableEq α)
    (H : Matrix (Sum α α) (Sum α α) ℤ),
    Fintype.card α = q + 1 ∧
    H ⬝ Hᵀ = (2 * (q + 1) : ℤ) • (1 : Matrix (Sum α α) (Sum α α) ℤ)
```

A more structured version, if you introduce a `HadamardMatrix` predicate:
```lean
theorem exists_paley_typeII_hadamard
  {q : ℕ}
  [Fact q.PrimePower]
  (hq1 : q % 4 = 1) :
  ∃ n, n = 2 * (q + 1) ∧ ∃ H : Matrix (Fin n) (Fin n) ℤ, IsHadamard H
```

If you manage to model the Jacobsthal/conference matrix directly over a finite field type `K`:
```lean
theorem paley_typeII_block_gram
  (K : Type) [Field K] [Fintype K]
  (hcard : Fintype.card K % 4 = 1)
  (Q : Matrix (Option K) (Option K) ℤ)
  (hQ : IsPaleyTypeIIConferenceMatrix K Q) :
  let A := Q + 1
  let B := Q - 1
  let H := Matrix.fromBlocks A B B (-A)
  H ⬝ Hᵀ = (2 * (Fintype.card K + 1) : ℤ) • (1 : Matrix (Option (Sum K PUnit)) (Option (Sum K PUnit)) ℤ)
```

The exact index type can be adjusted. The key is that the theorem be genuinely over non-prime finite fields.

---

### Theorem B: Generic difference-set Gram identity

Let `G` be a finite abelian group of order `v`, and let `D ⊆ G` be a `(v,k,λ)` difference set. Define the `0/1` incidence matrix
\[
M_{g,h} = 1 \iff g-h \in D.
\]
Define the corresponding `±1` matrix
\[
A_{g,h} =
\begin{cases}
1 & \text{if } g-h \in D,\\
-1 & \text{otherwise}.
\end{cases}
\]
Then there are exact formulas for `M Mᵀ` and `A Aᵀ`, with the latter reducing to the Jacobsthal/Paley Gram identity in the Paley case.

The combinatorially canonical formula for the incidence matrix is:
\[
M M^\top = (k-\lambda) I + \lambda J.
\]
From this, if `A = 2M - J`, then
\[
A A^\top = 4(k-\lambda) I + (v - 4(k-\lambda)) J
\]
after simplification using the difference-set identities. In the skew/Paley normalization this specializes to the familiar conference/Jacobsthal relations.

### Lean 4 target signature (suggested)
```lean
theorem differenceSet_incidence_gram
  {G : Type} [AddCommGroup G] [Fintype G] [DecidableEq G]
  (D : Finset G) (v k λ : ℕ)
  (hD : IsDifferenceSet D v k λ) :
  let M : Matrix G G ℤ := differenceSetIncidenceMatrix D
  M ⬝ Mᵀ =
    ((k - λ : ℤ)) • (1 : Matrix G G ℤ) +
    (λ : ℤ) • (Matrix.of fun _ _ => (1 : ℤ))
```

and for the sign matrix:
```lean
theorem differenceSet_sign_gram
  {G : Type} [AddCommGroup G] [Fintype G] [DecidableEq G]
  (D : Finset G) (v k λ : ℕ)
  (hD : IsDifferenceSet D v k λ) :
  let A : Matrix G G ℤ := differenceSetSignMatrix D
  ∃ a b : ℤ,
    A ⬝ Aᵀ = a • (1 : Matrix G G ℤ) + b • (Matrix.of fun _ _ => (1 : ℤ))
```

A sharper theorem, if you derive the exact coefficients:
```lean
theorem differenceSet_sign_gram_explicit
  {G : Type} [AddCommGroup G] [Fintype G] [DecidableEq G]
  (D : Finset G) (v k λ : ℕ)
  (hD : IsDifferenceSet D v k λ) :
  let A : Matrix G G ℤ := differenceSetSignMatrix D
  A ⬝ Aᵀ =
    (4 * (k - λ) : ℤ) • (1 : Matrix G G ℤ) +
    ((Fintype.card G - 4 * (k - λ) : ℤ)) • (Matrix.of fun _ _ => (1 : ℤ))
```

This theorem is the reusable engine. Once proved, Paley, Singer, Menon, and McFarland become instantiations.

---

### Theorem C: Strongly regular / doubly regular extraction from Paley data

For `p ≡ 3 (mod 4)`, the Paley sign matrix on `𝔽_p` yields a doubly regular tournament. For `q ≡ 1 (mod 4)`, the symmetric Paley graph is strongly regular with parameters
\[
\left(q,\frac{q-1}{2},\frac{q-5}{4},\frac{q-1}{4}\right).
\]

The graph-side theorem should not be a postscript; it is the spectral shadow of the same matrix identities. This is how you convert combinatorial number theory into certified spectral graph theory.

### Lean 4 target signatures (suggested)
For the graph case:
```lean
theorem paleyGraph_isSRG
  (K : Type) [Field K] [Fintype K] [DecidableEq K]
  (hq1 : Fintype.card K % 4 = 1) :
  IsStronglyRegularGraph
    (paleyGraph K)
    (Fintype.card K)
    ((Fintype.card K - 1) / 2)
    ((Fintype.card K - 5) / 4)
    ((Fintype.card K - 1) / 4)
```

For the tournament case:
```lean
theorem paleyTournament_isDRT
  (K : Type) [Field K] [Fintype K] [DecidableEq K]
  (hq3 : Fintype.card K % 4 = 3) :
  IsDoublyRegularTournament
    (paleyTournament K)
    (Fintype.card K)
    ((Fintype.card K - 1) / 2)
```

If the graph API is not yet present, state these first as adjacency-matrix identities:
```lean
theorem paley_adjacency_quadratic_relation
  (K : Type) [Field K] [Fintype K] [DecidableEq K]
  (hq1 : Fintype.card K % 4 = 1) :
  let A := paleyAdjacencyMatrix K
  A ⬝ A =
    (((Fintype.card K - 1) / 4 : ℤ)) • (1 : Matrix K K ℤ) +
    (((Fintype.card K - 5) / 4 : ℤ)) • A +
    (((Fintype.card K - 1) / 4 : ℤ)) • ((Matrix.of fun _ _ => (1 : ℤ)) - 1 - A)
```

---

## Why this is a breakthrough

A formal proof of Paley Type II for `q = p^m`, especially `q = 9`, crosses a real boundary. Prime-field residue arguments are now classical. But once you formalize the non-prime finite-field case, Lean acquires a certified interface between:

- multiplicative character sums over arbitrary finite fields,
- combinatorial design theory,
- conference/Hadamard matrix synthesis,
- and spectral graph constructions.

That is a new formal ecosystem. It opens a **certified Hadamard–Design Factory** where one can algorithmically instantiate difference sets into matrices and graphs with machine-checked parameters.

This would enable:

- certified existence results for infinite families of Hadamard matrices,
- formal pipelines from finite fields to strongly regular graphs,
- mechanized design-theoretic searches with proof-producing output,
- eventual formal links to coding theory, compressed sensing, and pseudorandomness.

---

## Critical concrete tests

You should explicitly pass the following tests:

1. **`q = 5` Paley Type II**: certify a Hadamard matrix of order `12`.
2. **`q = 9` Paley Type II**: certify a Hadamard matrix of order `20`.
   - This is the decisive test because it forces non-prime finite fields.
3. **Singer example in `ZMod 7` with `D = {1,2,4}`**:
   - verify the generic difference-set incidence Gram identity.
4. **Paley graph / tournament extraction**:
   - derive regularity and quadratic adjacency relations from the same matrix package.

The `q = 9` target is the hinge theorem. If this works cleanly, the finite-field abstraction is real.

---

## Proof architecture: 3 viable strategies

### Strategy A: Purely combinatorial difference-set first, then instantiate Paley
**Most promising overall.**

1. Define `IsDifferenceSet D v k λ` in a way that counts representations of each nonzero `g` as `d₁ - d₂`.
2. Prove the universal matrix-convolution theorem:
   - entries of `M Mᵀ` count intersections / differences,
   - diagonal gives `k`,
   - off-diagonal gives `λ`.
3. Deduce the sign-matrix Gram formula by setting `A = 2M - J`.
4. Show Paley residue sets in `𝔽_q` satisfy the required difference-set parameters.
5. Recover Jacobsthal, conference, Hadamard, and strongly regular identities as corollaries.

**Why strongest:** this turns Paley from a bespoke number-theoretic proof into one instance of a general certified combinatorial machine. It also minimizes future duplication.

---

### Strategy B: Character-sum route over finite fields
**Most conceptually elegant, and likely necessary for the non-prime field residue theorem.**

1. Define the quadratic character `χ` on `Kˣ`, extended by `χ 0 = 0`.
2. Prove the key orthogonality/correlation identity:
   \[
   \sum_{x \in K} \chi(x-a)\chi(x-b)=
   \begin{cases}
   q-1 & a=b,\\
   -1 & a\neq b.
   \end{cases}
   \]
3. Convert this directly into the Jacobsthal Gram identity for `Q`.
4. Deduce the conference identity for the Type II matrix and then the Hadamard block identity.

**Why important:** this is the shortest path to the exact finite-field Paley theorem, especially for `q = 9`. It also builds reusable character infrastructure for future Gauss/Jacobi sum formalization.

---

### Strategy C: Explicit finite model for `GF(9)` plus abstraction extraction
**Best fallback if Mathlib finite-field APIs are incomplete.**

1. Realize `GF(9)` concretely as `F := (ZMod 3)[X] / (X^2 + 1)` or another irreducible quotient.
2. Compute the square classes explicitly and build the Jacobsthal matrix by brute-force finite enumeration.
3. Prove the matrix identities by computation for `q = 9`.
4. Abstract the proof ingredients into lemmas suggesting the general theorem.

**Why useful:** even if the general theorem stalls on API limitations, a certified `q = 9` construction is a decisive stress-test and exposes the exact missing lemmas.

---

## Recommended route

Do **A + B in tandem**:

- use **Strategy A** to establish the generic difference-set matrix algebra;
- use **Strategy B** to prove the Paley residue set is a difference set in `𝔽_q`.

This division of labor is mathematically clean:
- combinatorics handles the matrix identities,
- finite-field character theory handles the parameter certification.

Then use `q = 9` as the stress-test for the finite-field side.

---

## Building blocks to seek in Mathlib / catalog

Build aggressively on any existing results for:

- `Matrix.fromBlocks`, block multiplication, transpose identities,
- `Matrix.mul_apply`, `Matrix.ext`,
- `Fintype.card`, finite sums over fields/groups,
- `ZMod p`, `FiniteField`, `GaloisField`,
- character-like homomorphisms on finite groups if available,
- graph adjacency matrix APIs if present,
- any catalog theorems already proving Paley Type I / Jacobsthal identities over `ZMod p`.

If the catalog already contains a certified Jacobsthal Gram identity over prime fields, do **not** reprove it from scratch. Generalize the proof interface:
- isolate the exact lemma that used primality instead of prime-power cardinality,
- replace residue-counting with quadratic character orthogonality over finite fields,
- lift the matrix result to the generic difference-set theorem.

In particular, if there is already a theorem analogous to:
```lean
theorem jacobsthal_mul_transpose_eq ...
```
then your move is to refactor it through a new abstraction:
```lean
theorem signMatrix_of_differenceSet_mul_transpose ...
```
and derive the old theorem as a specialization.

That is how you turn a catalog result into a platform theorem.

---

## Key mathematical insight to exploit

The real hidden structure is that all three hypotheses are manifestations of the same identity in the group algebra `ℤ[G]`:

\[
D D^{(-1)} = k \cdot e + \lambda \sum_{g \neq e} g
\]

for a difference set `D`. Matrix identities are just regular-representation shadows of this convolution law. Paley’s construction then arises because the quadratic residues in `𝔽_q` form a difference set (or skew difference set/tournament object depending on `q mod 4`), and strongly regular graphs arise because the adjacency operator satisfies a quadratic relation derived from the same convolution identity.

This is the conceptual unification you should formalize.

---

## Cross-domain connections

This project naturally connects to:

- **spectral graph theory**: strongly regular graphs via adjacency quadratic identities;
- **coding theory**: Hadamard matrices and two-weight codes;
- **compressed sensing / deterministic RIP heuristics**: Paley matrices and pseudorandom frames;
- **finite geometry**: Singer difference sets, projective planes, symmetric BIBDs;
- **representation theory**: group algebra and character orthogonality;
- **analytic number theory**: quadratic character sums over finite fields;
- **quantum information**: Hadamard/conference matrices as structured orthogonal designs;
- **pseudorandomness**: Paley graphs as canonical quasirandom objects.

The strongest scientific narrative is that Lean can certify the passage from **number-theoretic character sums** to **spectral expanders / design matrices**.

---

## Implementation milestones

### Milestone 1: Generic difference-set infrastructure
- Define `IsDifferenceSet`.
- Define incidence/sign matrices.
- Prove `M Mᵀ = (k-λ)I + λJ`.
- Prove the corresponding sign-matrix Gram formula.

### Milestone 2: Finite-field quadratic character package
- Define square/non-square predicate over finite fields.
- Define quadratic character if not already available.
- Prove the basic correlation identity.
- Derive Paley difference-set parameters.

### Milestone 3: Paley Type II block theorem
- Define conference matrix `Q`.
- Prove `Q Qᵀ = q I - J` or the appropriate normalized identity.
- Prove the block matrix Hadamard identity.

### Milestone 4: Certified examples
- `q = 5`, order `12`.
- `q = 9`, order `20`.
- Singer `(7,3,1)`.

### Milestone 5: Graph extraction
- Define Paley graph/tournament adjacency matrices.
- Prove regularity.
- Prove quadratic adjacency/eigenvalue relations.

---

## Obstacle quantification request

You must explicitly quantify the finite-field API gap:

- What is missing for `GaloisField` / arbitrary finite fields?
- Do you need:
  - a quadratic character definition?
  - a theorem that `Kˣ` is cyclic?
  - square-count lemmas?
  - additive/multiplicative character sum lemmas?
- How many core lemmas must be added before `q = 9` becomes clean?

Do not leave this vague. Produce an explicit dependency list.

---

## Deliverables

1. A Lean file proving at least one of the main general theorems above.
2. Certified concrete examples for `q = 5` and `q = 9`.
3. A theorem statement and proof route for the generic difference-set Gram identity.
4. A graph-theoretic extraction theorem or adjacency-matrix identity.
5. Minimal `sorry` count, with each remaining `sorry` isolated behind a named API-gap lemma.

---

## FUTURE_DIRECTIONS.md requirement

You must produce a structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
- a precise conjecture,
- a concrete Lean/formal test,
- a pass/fail criterion,
- and a statement of what new mathematics becomes accessible if true.

Suggested hypotheses to include:

1. **Menon lift hypothesis**  
   Every formally certified Menon difference set yields a Hadamard matrix through the generic sign-matrix theorem, with no new matrix algebra lemmas required.  
   **Test:** instantiate on the smallest nontrivial Menon parameter set.

2. **Singer-to-projective-plane hypothesis**  
   The generic difference-set package is sufficient to derive the incidence axioms of a finite projective plane from Singer data in Lean.  
   **Test:** certify the Fano plane from the `(7,3,1)` Singer set.

3. **Finite-field character abstraction hypothesis**  
   A single quadratic-character API over arbitrary finite fields suffices to derive both Paley graph and Paley Type II Hadamard families.  
   **Test:** same core lemmas prove `q = 9` Hadamard and `q = 13` strongly regular graph identities.

4. **Spectral transfer hypothesis**  
   Every certified difference-set sign matrix yields a certified two-eigenvalue or three-eigenvalue adjacency operator after an explicit normalization.  
   **Test:** instantiate on Paley and Singer examples.

5. **Kronecker coverage hypothesis**  
   Combining Paley Type II certification with existing Kronecker closure raises formally certified Hadamard-order coverage beyond a specified threshold up to `N = 10,000`.  
   **Test:** write an executable checker that enumerates certified orders.

---

## Application keywords

**Hadamard matrices, Paley Type II, finite fields, Galois fields, quadratic character, Jacobsthal matrix, difference sets, symmetric designs, strongly regular graphs, Paley graphs, doubly regular tournaments, spectral graph theory, group algebra, character sums, combinatorial design theory, conference matrices, certified combinatorics, formalized finite geometry, pseudorandomness, coding theory**

### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  Show the math working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses. Each direction must be a falsifiable claim or conjecture that
can be proved, disproved, or tested — not a vague "we could explore X."
Format: "Conjecture: [precise statement]. Test: [what would confirm or
refute it]. Impact: [what this would enable if true]." Every hypothesis
should be daring enough to matter and specific enough to fail.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Speculative
Research mode: prove
