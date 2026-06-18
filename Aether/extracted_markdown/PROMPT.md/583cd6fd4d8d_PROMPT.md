## Assignment: Prove a breakthrough theorem in quantitative Jacobian reduction theory

This cycle should not merely sharpen constants. It should identify a *structural law* governing tame inversion complexity and nilpotence compression, and formalize it in Lean 4 with enough precision that the result becomes a reusable platform for future attacks on the Jacobian Conjecture.

You should target one flagship theorem and one supporting theorem, both genuinely non-trivial, both explicitly connected to existing catalog lemmas, and both designed to minimize `sorry` by reducing the hard geometry to compositional algebra already present in the library.

---

# Research Direction
# Future Directions: Falsifiable Hypotheses in Quantitative Jacobian Reduction Theory

This document presents two high-value, falsifiable hypotheses emerging from our formal results on nilpotence detection, degree bounds, and complexity measures for polynomial maps. The goal is not to “explore” them, but to *resolve a decisive special case* in Lean.

---

## Flagship Target — Hypothesis 1: Sharpness of the Tame Inverse Degree Bound

### Visionary theorem statement

The known upper bound
\[
\deg(F^{-1}) \le (\deg F)^{n-1}
\]
for polynomial automorphisms is one of the central quantitative invariants in affine algebraic geometry. A formal proof that this bound is *attained by an explicit tame family in every dimension* would do more than settle a sharpness question: it would establish a canonical extremal model for inversion complexity, analogous to extremizers in analysis or worst-case instances in complexity theory.

The right theorem is not existential-by-search. It is an explicit family theorem.

### Precise mathematical statement

Let \(k\) be a field of characteristic zero. For every \(n \ge 2\) and \(d \ge 2\), define the triangular polynomial automorphism
\[
F_{n,d}(x_1,\dots,x_n)
=
(x_1 + x_2^d,\; x_2 + x_3^d,\; \dots,\; x_{n-1} + x_n^d,\; x_n).
\]
Then:
1. \(F_{n,d}\) is a tame polynomial automorphism;
2. \(\deg(F_{n,d}) = d\);
3. \(\deg(F_{n,d}^{-1}) = d^{\,n-1}\).

This is the extremal sharpness theorem for the tame inverse degree bound.

### Suggested Lean 4 theorem signature

You will likely need to adapt exact namespaces/types to the existing Jacobian files, but the target should look as close as possible to:

```lean
theorem triangular_extremal_inverse_degree
    {k : Type*} [Field k] [CharZero k]
    (n d : ℕ) (hn : 2 ≤ n) (hd : 2 ≤ d) :
    let F := JacobianConjecture.triangularChain k n d
    in JacobianConjecture.IsTameAutomorphism F
       ∧ JacobianConjecture.polyMapDegree F = d
       ∧ JacobianConjecture.polyMapDegree (JacobianConjecture.polyEquivSymm F) = d ^ (n - 1)
```

If the library does not yet package polynomial automorphisms as a `PolyEquiv`, then formulate the theorem using the existing forward map, inverse map, and left/right inverse certificates:

```lean
theorem triangular_chain_degree_sharp
    {k : Type*} [Field k] [CharZero k]
    (n d : ℕ) (hn : 2 ≤ n) (hd : 2 ≤ d) :
    let F := JacobianConjecture.triangularChainMap k n d
    let G := JacobianConjecture.triangularChainInv k n d
    in JacobianConjecture.IsInversePair F G
       ∧ JacobianConjecture.polyMapDegree F = d
       ∧ JacobianConjecture.polyMapDegree G = d ^ (n - 1)
```

### Why this is a breakthrough

A formal extremal family would convert a soft asymptotic upper bound into a *certified exact complexity law*. This gives a benchmark object for:
- worst-case inversion complexity,
- algorithmic lower bounds for symbolic inversion,
- quantitative reduction steps in Jacobian-type arguments,
- testing future “improved bounds” by immediate counterexample.

This is not an incremental extension. It identifies the canonical “hard tame automorphism” in all dimensions.

### Build directly on catalog theorems

Use existing degree-control lemmas as the engine:
- `JacobianConjecture.polyMapDegree`
- `JacobianConjecture.totalDegree_bind₁_le`
- triangular / elementary constructions in `Catalog/Algebra/Jacobian/Triangular.lean`

The key move is to turn the upper-bound machinery into an *exactness proof* by exhibiting a monomial in the inverse with coefficient \( \pm 1 \) and degree exactly \(d^{n-1}\).

### Proof architecture: three viable strategies

#### Strategy A: Explicit recursive inverse expansion — most promising
1. Define \(G_{n,d} = F_{n,d}^{-1}\) recursively:
   \[
   x_n = y_n,\quad
   x_{n-1} = y_{n-1} - y_n^d,\quad
   x_{n-2} = y_{n-2} - (y_{n-1} - y_n^d)^d,\ \dots
   \]
2. Prove by downward induction that the \(i\)-th inverse coordinate has degree \(d^{n-i}\).
3. Conclude that the maximum degree is attained in the first coordinate, hence
   \[
   \deg(F_{n,d}^{-1}) = d^{n-1}.
   \]

Why most promising: it aligns perfectly with Lean’s strengths—recursive definitions, induction on coordinates, and degree estimates via substitution lemmas.

#### Strategy B: Degree propagation through nested substitution
1. Prove a general lemma: if \(P\) has top monomial \(X_j^m\) and you substitute into \(X_j\) a polynomial of exact degree \(e\) with nonzero top pure-power term, then the resulting degree is exactly \(me\).
2. Apply this iteratively along the triangular chain.
3. Deduce exact degree growth without fully expanding the inverse.

Why valuable: this yields a reusable theorem for future quantitative composition arguments, not just this family.

#### Strategy C: Weighted-degree / valuation method
1. Introduce a weight vector \(w_i = d^{n-i}\).
2. Show the inverse coordinates are adapted to this weight filtration and that the leading weighted term survives.
3. Derive exact ordinary degree from the weighted leading term.

Why interesting: this opens the door to tropical and Newton-polytope interpretations of inversion complexity.

---

## Supporting Target — Hypothesis 2: Nilpotence Index Compression for Triangular Cubic Keller-Type Maps

The original hypothesis (“all cubic Keller maps satisfy nilpotence index \(\le \lceil n/2\rceil+1\)”) is ambitious and may be false in full generality. Do not overreach. Instead, carve out a decisive structural subclass where compression can actually be proved and used as a formal testbed.

### Precise theorem statement

For strictly upper-triangular homogeneous cubic maps
\[
H(x_1,\dots,x_n)
=
(H_1(x_2,\dots,x_n),\, H_2(x_3,\dots,x_n),\, \dots,\, H_{n-1}(x_n),\, 0),
\]
the Jacobian matrix \(JH\) is strictly upper triangular, hence nilpotent of index at most \(n\). But for the chain-type subclass where each \(H_i\) depends only on \(x_{i+1}\), one has a stronger bound:
\[
(JH)^2 = 0.
\]

This is a genuine compression theorem: a nontrivial subclass of cubic homogeneous maps has nilpotence index independent of dimension.

### Suggested Lean 4 type signature

```lean
theorem jacobian_sq_zero_of_chain_cubic
    {k : Type*} [Field k] [CharZero k]
    (n : ℕ)
    (H : JacobianConjecture.ChainCubicMap k n) :
    (JacobianConjecture.jacobianMatrix H) ^ 2 = 0
```

Or, if the chain subclass is not yet packaged:

```lean
theorem jacobian_sq_zero_of_upper_chain_dependency
    {k : Type*} [Field k] [CharZero k]
    {n : ℕ} (H : (Fin n → MvPolynomial (Fin n) k))
    (hhom : JacobianConjecture.IsHomogeneousMap H 3)
    (hdep : JacobianConjecture.IsChainDependent H)
    (hlast : H (Fin.last _) = 0) :
    (JacobianConjecture.jacobianMatrix H) ^ 2 = 0
```

### Why this matters

This theorem would provide a formal laboratory for “nilpotence compression” phenomena. It does not solve the cubic homogeneous Jacobian Conjecture, but it creates the first certified class where Jacobian nilpotence is dramatically smaller than the ambient dimension. That is exactly the kind of rigid subclass from which real structure theorems grow.

### Proof architecture

#### Strategy A: Support-of-entries argument — most direct
1. Show each nonzero entry of \(JH\) can only occur in column \(i+1\) of row \(i\).
2. Therefore no composable two-step path exists in matrix multiplication.
3. Conclude every entry of \((JH)^2\) vanishes.

#### Strategy B: Directed graph interpretation
1. Associate to \(JH\) a dependency digraph on variables.
2. Chain dependence gives a graph with no directed path of length \(2\).
3. Matrix square vanishes because length-2 walks control entries of \(JH^2\).

This graph language is powerful and may generalize to “nilpotence index = longest dependency path + 1”.

#### Strategy C: Differential operator factorization
1. Express each row of \(JH\) as a scalar multiple of a single coordinate derivation.
2. Show successive derivations annihilate because supports are disjoint in the chain pattern.
3. Infer \(JH^2 = 0\).

This route is conceptually rich and links to differential algebra.

---

## Cross-domain connections you should explicitly exploit

### 1. Complexity theory
The extremal tame family is a worst-case instance for symbolic inversion algorithms. Formalizing exact inverse degree growth gives a lower-complexity witness analogous to hard instances in arithmetic circuit complexity.

### 2. Tropical / Newton polytope geometry
The inverse degree explosion is really Newton-polytope propagation under nested substitution. If you can isolate the leading monomial mechanism, this can later be tropicalized into a max-plus growth law.

### 3. Dynamical systems
Triangular automorphisms are discrete-time shear flows. Exact inverse degree is a complexity invariant of time reversal. Nilpotence compression corresponds to finite-step annihilation of infinitesimal coupling.

### 4. Noncommutative / graph-theoretic algebra
The Jacobian support graph controls nilpotence index. Formalizing this could open a path from polynomial automorphisms to quiver nilpotence criteria.

### 5. Program verification
A certified extremal family is a benchmark for proof-producing computer algebra systems that manipulate polynomial maps and inverses.

---

## Concrete implementation blueprint in Lean

### Phase 1: Define the extremal triangular chain family
Create or extend a file near:
- `Catalog/Algebra/Jacobian/Triangular.lean`

with explicit definitions of:
- forward triangular chain map,
- inverse triangular chain map,
- proof they compose to identity,
- proof of tameness via composition of elementary automorphisms.

### Phase 2: Prove exact forward degree
This should be easy: each coordinate has degree at most \(d\), and one coordinate has degree exactly \(d\).

### Phase 3: Prove exact inverse degree
The hard step. Recommended route:
- define inverse coordinates recursively,
- prove exact degree of each coordinate by induction,
- isolate a surviving pure-power monomial in the first coordinate.

You will probably need a lemma of the form:
```lean
theorem degree_subst_pure_power_exact
    ...
```
saying exact degree multiplies under substitution into a pure power when the leading term survives.

### Phase 4: Formalize the chain-cubic nilpotence subclass
Define a dependency predicate that is actually usable in proofs:
```lean
def IsChainDependent (H : Fin n → MvPolynomial (Fin n) k) : Prop := ...
```
Then prove support restrictions on partial derivatives, and from there matrix-square-zero.

---

## Most promising theorem package

If time is limited, prioritize this pair:

1. `triangular_extremal_inverse_degree`
2. `jacobian_sq_zero_of_chain_cubic`

Together they create a new paradigm:
- exact inversion complexity on the automorphism side,
- exact nilpotence compression on the Jacobian side.

That pairing is scientifically stronger than proving either theorem alone.

---

## Refutation discipline

If the fully general nilpotence compression conjecture appears false or inaccessible, do not bury that. Produce either:
- a counterexample search framework, or
- a formally proved maximal subclass where compression holds.

A clean counterexample to the over-optimistic global conjecture would itself be valuable. Clearing false universals is part of real progress.

---

## Application keywords

`Jacobian Conjecture`, `polynomial automorphisms`, `tame automorphism`, `inverse degree complexity`, `triangular maps`, `nilpotent Jacobian`, `cubic homogeneous maps`, `Newton polytope`, `tropicalization`, `arithmetic circuit complexity`, `dependency graph`, `formal verification`, `Lean 4`, `Mathlib`

---

## Deliverables

1. A Lean file proving the flagship theorem with minimal `sorry`.
2. A Lean file proving the chain-cubic nilpotence compression theorem.
3. Any supporting lemmas on exact degree under substitution, composition, or monomial survival.
4. A short note documenting which existing catalog theorems were reused and how.

---

## Required FUTURE_DIRECTIONS.md

You must also produce a structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable hypotheses**, each with:
- a precise conjecture,
- a proposed Lean formalization target,
- an explicit computational or proof test,
- a clear refutation criterion.

At least three hypotheses should be of the following flavor:

1. **Dependency-path nilpotence law**  
   Conjecture that if the Jacobian dependency digraph of a polynomial map has longest directed path length \(L\), then \((JH)^{L+1}=0\).  
   Test: formalize graph extraction and verify on triangular/chain subclasses.  
   Refutation: produce a map whose dependency graph has longest path \(L\) but \((JH)^{L+1} \neq 0\).

2. **Newton-polytope inversion law**  
   Conjecture that for triangular tame automorphisms, inverse degree equals the maximal tropical weight propagated along the substitution DAG.  
   Test: compute on the explicit family \(F_{n,d}\).  
   Refutation: exhibit a triangular map where tropical propagation overestimates true inverse degree.

3. **Arithmetic-complexity lower bound**  
   Conjecture that any straight-line program computing the first coordinate of \(F_{n,d}^{-1}\) requires multiplicative depth at least \(n-1\).  
   Test: compare with recursive construction.  
   Refutation: explicit lower-depth circuit.

4. **Rigidity of extremizers**  
   Conjecture that any tame automorphism attaining \(\deg(F^{-1}) = (\deg F)^{n-1}\) is, after affine changes of coordinates, equivalent to an iterated triangular chain.  
   Test: classify low-dimensional cases \(n=2,3\).  
   Refutation: produce a non-equivalent extremizer.

5. **Quadratic Keller compression in sparse support classes**  
   Conjecture that sparse-support homogeneous Keller maps with at most one outgoing dependency per variable satisfy \( (JH)^2 = 0 \).  
   Test: formalize support sparsity and prove on examples.  
   Refutation: explicit sparse map with nonzero square.

Make those hypotheses sharp enough that the next cycle can attack one immediately.

Be bold: the goal is to turn quantitative Jacobian theory from a collection of bounds into a *formal science of extremizers, dependency graphs, and inversion complexity*.

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
