## Assignment: Combinatorial dimension argument

**Mode:** prove

Prove a genuinely new polynomial-method theorem in Lean 4 that bypasses tensors and slice-rank formalism entirely, while still delivering the cap-set exponential bound mechanism. The conceptual goal is to formalize the **dimension-theoretic heart** of Ellenberg–Gijswijt: on a cap set, low-degree polynomial interpolation behaves as if point evaluations were independent, and this forces a cardinality bound by counting monomials.

This is not an incremental exercise. If you can isolate and certify the linear-independence/interpolation principle in Mathlib, you create a reusable engine for:
- progression-free bounds over finite fields,
- rank lower bounds in algebraic complexity,
- finite-field uncertainty principles,
- and eventually formal slice-rank arguments without introducing tensors at the foundation.

---

## Core Breakthrough Target

Let \( \mathbb{F}_3^n \) be the ambient space. Let \(A \subseteq \mathbb{F}_3^n\) be a cap set, i.e.
\[
\forall x,y,z \in A,\quad x+y+z=0 \implies x=y=z.
\]
Define \(V_d\) to be the space of functions on \( \mathbb{F}_3^n \) represented by polynomials in \(n\) variables with individual degree \(\le 2\) and total degree \(\le d\).

The key theorem to formalize is:

> **Restricted low-degree interpolation on cap sets.**  
> If \(A \subseteq \mathbb{F}_3^n\) is cap and \(d = \lfloor 2n/3 \rfloor\), then the family of restricted delta functions
> \[
> \{\mathbf 1_{\{a\}}|_A : a \in A\}
> \]
> lies in the image of the restriction map \(V_d \to (A \to \mathbb{F}_3)\), and is linearly independent. Hence
> \[
> |A| \le \dim V_d.
> \]

The point is not merely to prove linear independence of literal indicator functions as functions on \(A\) — that part is trivial. The breakthrough is to prove that **each point-mass on a cap set is realized by a low-degree polynomial**, so that the entire coordinate basis of \( \mathbb{F}_3^A \) injects into the low-degree polynomial space. This is the exact dimension argument that replaces tensors.

---

## Precise Theorem Statements

You should aim for a hierarchy of theorems, from structural to numerical.

### Theorem 1: Polynomial realization of point masses on a cap set
For \(a \in A\), define
\[
\delta_a(x)=
\begin{cases}
1 & x=a\\
0 & x\in A,\ x\neq a.
\end{cases}
\]
Prove there exists a polynomial of total degree \(\le 2n/3\) (or the correct rounded bound obtained from the argument) whose restriction to \(A\) is \(\delta_a\).

A Lean-facing type signature should look approximately like:

```lean
theorem exists_low_degree_indicator_on_cap
  (n : ℕ)
  (A : Finset ((Fin n) → ZMod 3))
  (hcap :
    ∀ x ∈ A, ∀ y ∈ A, ∀ z ∈ A,
      x + y + z = 0 → x = y ∧ y = z)
  (a : (Fin n) → ZMod 3)
  (ha : a ∈ A) :
  ∃ p : MvPolynomial (Fin n) (ZMod 3),
    p.totalDegree ≤ (2 * n) / 3 ∧
    ∀ x, x ∈ A →
      MvPolynomial.eval x p = if x = a then 1 else 0
```

This signature may need adaptation depending on available Mathlib lemmas for:
- `totalDegree`,
- evaluation into `ZMod 3`,
- and finite-function indexing by `Fin n → ZMod 3`.

If total degree infrastructure is awkward, a staged theorem with an explicit monomial-support predicate is acceptable.

---

### Theorem 2: Injectivity of restriction from low-degree polynomials to functions on a cap set basis
Prove that the restriction map contains all point masses on \(A\), hence is surjective onto `(A → ZMod 3)` in a suitable finite-set function model, and therefore
\[
|A| \le \dim V_{\lfloor 2n/3\rfloor}.
\]

Lean-facing version:

```lean
theorem card_capset_le_low_degree_dim
  (n : ℕ)
  (A : Finset ((Fin n) → ZMod 3))
  (hcap :
    ∀ x ∈ A, ∀ y ∈ A, ∀ z ∈ A,
      x + y + z = 0 → x = y ∧ y = z) :
  A.card ≤
    Fintype.card {m : (Fin n →₀ ℕ) //
      (∀ i, m i ≤ 2) ∧ m.sum (fun _ e => e) ≤ (2 * n) / 3}
```

This theorem identifies the dimension with the number of admissible monomials. If vector-space dimension is easier to express abstractly, prove first that cardinality is bounded by the number of reduced monomials of degree \(\le 2n/3\), then separately identify that number with the dimension of the reduced polynomial space.

---

### Theorem 3: Exponential cap-set bound via monomial counting
Once the dimension theorem is in place, prove a numerical upper bound:
\[
|A| \le \sum_{k=0}^{\lfloor 2n/3\rfloor}
[x^k](1+x+x^2)^n.
\]

Lean-facing form:

```lean
theorem card_capset_le_monomial_count
  (n : ℕ)
  (A : Finset ((Fin n) → ZMod 3))
  (hcap :
    ∀ x ∈ A, ∀ y ∈ A, ∀ z ∈ A,
      x + y + z = 0 → x = y ∧ y = z) :
  A.card ≤
    ∑ k in Finset.range ((2 * n) / 3 + 1),
      Nat.card {m : (Fin n →₀ ℕ) //
        (∀ i, m i ≤ 2) ∧ m.sum (fun _ e => e) = k}
```

A later strengthening can target the standard asymptotic constant \(c^n\) with \(c<3\), but the first formal breakthrough is the exact combinatorial count.

---

## Mathematical Architecture

The decisive idea is to formalize the **CLP/Ellenberg–Gijswijt interpolation lemma** in a finite-field-reduced polynomial algebra.

### Recommended formal setup
Work with:
- points as `Fin n → ZMod 3`,
- polynomials as `MvPolynomial (Fin n) (ZMod 3)`,
- reduced monomials with exponents in `{0,1,2}` since functions on `ZMod 3` are represented modulo `X_i^3 - X_i`.

You will likely want an intermediate definition of the reduced low-degree space:
```lean
def ReducedMonomial (n d : ℕ) :=
  {m : (Fin n →₀ ℕ) // (∀ i, m i ≤ 2) ∧ m.sum (fun _ e => e) ≤ d}
```
and then define the span of corresponding monomials.

This avoids fighting general dimension theory too early and lets you count a concrete basis.

---

## Proof Strategy Paths

### Strategy A: Direct reduced-polynomial interpolation on cap sets
This is the most promising route.

1. **Construct reduced separator polynomials.**  
   For each \(a \in A\), build a polynomial depending on the cap-set property that vanishes on all \(x \in A \setminus \{a\}\) and equals \(1\) at \(a\). The standard trick is to exploit the absence of nontrivial 3-term progressions so that certain bilinear or quadratic forms distinguish \(a\) from the rest of \(A\).

2. **Control total degree by the cap-set decomposition argument.**  
   Show the separator can be chosen in reduced form and degree at most \(2n/3\), or derive it from a polynomial of degree \(\le 2n\) and then use the CLP degree-splitting lemma to compress one side to \(\le 2n/3\).

3. **Conclude dimension bound by counting reduced monomials.**  
   Once every delta function lies in the image of restriction, the restriction map is surjective onto functions on \(A\), so `A.card ≤ dim V_d`. Then count monomials.

**Why this is best:** it isolates the genuinely reusable theorem: low-degree interpolation on progression-free sets. It gives the cleanest API for later generalization to \( \mathbb{F}_p^n \).

---

### Strategy B: Matrix-rank reformulation of polynomial method
This route is more linear-algebraic and may be easier to organize in Lean.

1. Define a matrix \(M\) indexed by \(A \times A\), where entries come from evaluating a carefully chosen low-degree polynomial \(P(-2a-b)\) or equivalent CLP kernel.
2. Use the cap-set condition to show \(M\) is diagonal (or supported only on the diagonal).
3. Express \(M\) as a sum of rank-one pieces indexed by monomials of degree \(\le 2n/3\), giving
   \[
   \operatorname{rank}(M) \le \#\{\text{reduced monomials of degree }\le 2n/3\}.
   \]
   Since \(M\) is diagonal with nonzero diagonal, \(\operatorname{rank}(M)=|A|\).

**Why it matters:** this is the nearest tensor-free shadow of slice rank. It creates infrastructure directly relevant to algebraic complexity and communication complexity.

**Risk:** matrix decompositions over `MvPolynomial` evaluations may be heavier than direct interpolation.

---

### Strategy C: Function-algebra quotient approach
This is conceptually elegant and potentially powerful for future finite-field additive combinatorics.

1. Formalize the quotient algebra of polynomial functions on `((Fin n) → ZMod 3)` by relations \(X_i^3=X_i\).
2. Show reduced monomials form a basis of this function algebra.
3. Prove that for cap sets, evaluation on \(A\) of the low-degree filtered piece is surjective.

**Why it is revolutionary:** it sets up a full finite-field function-algebra formalism in Lean, useful far beyond cap sets.

**Risk:** quotient algebra basis formalization is more infrastructure-heavy.

---

## Key Supporting Lemmas to Target First

You should not jump directly to the final theorem. Build the following sequence.

### 1. Reduced monomial basis lemma
Show every function on \( \mathbb{F}_3^n \) is represented by a unique reduced polynomial with exponents at most 2 in each variable.

Possible Lean target:
```lean
theorem exists_unique_reduced_repr
  (f : ((Fin n) → ZMod 3) → ZMod 3) :
  ∃! p : MvPolynomial (Fin n) (ZMod 3),
    (∀ i, p.degrees i ≤ 2) ∧
    ∀ x, MvPolynomial.eval x p = f x
```
This exact signature may be too ambitious initially; a finite-support/basis version is acceptable.

### 2. Monomial count equals dimension
Identify the dimension of the reduced degree-≤d space with the number of reduced monomials of degree ≤ d.

### 3. Cap-set kernel lemma
Construct the polynomial/kernel whose support on \(A^3\) is diagonal:
\[
x+y+z=0 \text{ on } A \implies x=y=z.
\]
This is the exact place where the cap-set hypothesis enters.

### 4. Degree splitting lemma
Formalize the combinatorial statement that every reduced monomial of total degree at most \(2n\) appearing in the CLP kernel has at least one of the grouped variable blocks of degree at most \(2n/3\). This is the combinatorial engine behind the rank bound.

---

## Cross-Domain Connections

Do not treat this as isolated additive combinatorics. Explicitly structure the development so the same machinery can power the following.

### Algebraic complexity
The matrix-rank decomposition route is a finite precursor to slice-rank and tensor-rank arguments. A robust Lean API for:
- low-degree decomposition,
- rank bounds from structured monomial support,
- and finite-field evaluation matrices

would directly support future formal lower bounds in arithmetic circuit complexity and matrix multiplication barriers.

### Communication complexity
Diagonal-support kernels with low-complexity decompositions model multiparty communication tensors. Your decomposition lemmas can become certified lower-bound tools for number-on-the-forehead communication problems.

### Quantum information
Reduced polynomial decompositions over finite fields resemble stabilizer-phase function expansions. There is a speculative but real bridge to:
- discrete Wigner/stabilizer formalisms,
- entanglement rank witnesses,
- and code-state distinguishability over finite alphabets.

A bold bridge theorem later could connect low-degree finite-field kernels to rank constraints on tensors arising in quantum contextuality or stabilizer codes.

### Coding theory
Cap sets in \( \mathbb{F}_3^n \) are tightly linked to locally constrained codes and forbidden configuration problems. The interpolation theorem may become a general-purpose engine for upper-bounding codes avoiding specified additive patterns.

---

## How to Build on Catalog Theorems

The current verified catalog is not directly in additive combinatorics, but that is an opportunity: create a **bridge layer** rather than forcing irrelevant reuse.

- `maslov_matrix_lower` suggests existing infrastructure for matrix inequalities and may inspire a matrix-rank packaging of the CLP kernel decomposition. Use its style as a model for proving lower/upper bounds via structured matrices.
- `quantum_singleton_bound` and `quantum_hamming_bound_5_1_3` indicate there is already some finite-field/coding-theory machinery in the repository. Inspect whether there are existing lemmas on `ZMod p`, finite-dimensional spaces, or cardinality bounds over finite alphabets that can be repurposed.
- `depth_complexity_tradeoff_bounded` and `cech_complexity_bound` suggest the project values cross-domain theorem statements. Package your cap-set theorem as foundational infrastructure for future complexity and quantum applications, not merely a one-off combinatorics result.

If no direct lemma reuse is possible, that is acceptable — but the theorem statement and API should be designed so future bridge theorems become natural.

---

## Concrete Lean Design Guidance

### Suggested definitions
- `IsCapSet (A : Finset ((Fin n) → ZMod 3)) : Prop`
- `ReducedMonomial n d`
- `LowDegReducedPoly n d := {p : MvPolynomial (Fin n) (ZMod 3) // ... }`
- `restrictTo (A : Finset α) : ...`

### Suggested theorem packaging
1. Structural interpolation theorem.
2. Cardinality ≤ dimension theorem.
3. Dimension = monomial-count theorem.
4. Numerical cap-set bound.

This modularization is essential. The first theorem is the real breakthrough; the others are corollaries.

---

## Application Keywords
cap set, polynomial method, Ellenberg–Gijswijt, Croot–Lev–Pach, finite fields, additive combinatorics, reduced polynomial basis, monomial counting, rank method, slice-rank precursor, algebraic complexity, communication complexity, coding theory, quantum information, formalized mathematics, Lean 4, Mathlib

---

## Deliverables

1. Formalize the main theorem hierarchy above in Lean 4.
2. Minimize `sorry`; if a deep combinatorial lemma must temporarily remain, isolate it behind the cleanest possible statement.
3. Include module-level documentation explaining the mathematical strategy and why it bypasses tensors.
4. Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - extension from \( \mathbb{F}_3^n \) to \( \mathbb{F}_p^n \),
   - formal CLP/Ellenberg–Gijswijt matrix decomposition,
   - progression-free bounds for other linear configurations,
   - finite-field function-algebra quotient infrastructure,
   - bridges to communication complexity or stabilizer-code rank bounds.

The ambition here is to turn one of the most beautiful polynomial-method arguments in modern combinatorics into a reusable formal engine that opens an entire frontier.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Physics
Research mode: prove
