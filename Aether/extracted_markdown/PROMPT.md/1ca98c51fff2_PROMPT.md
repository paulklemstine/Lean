## Assignment: **Conjecture:** Every formally certified Menon difference set yields a Hadamard matrix through the generic sign-matrix Gram theorem, and this mechanism is the first reusable certified bridge from abstract difference-set data to orthogonal matrix synthesis.

**Mode:** prove

Prove a new theorem that is structurally stronger than a one-off Menon instance: the Menon phenomenon should emerge as a corollary of the generic difference-set Gram formalism, not from ad hoc matrix manipulations.

### Precise target

The real target is not merely “find one Hadamard matrix of order 16,” but to certify a **factory theorem**:

> Any difference set with Menon parameters \(v = 4u^2\), \(k = 2u^2 - u\), \(\lambda = u^2 - u\) produces a \(\{\pm 1\}\)-matrix \(A\) of order \(v\) satisfying
> \[
> A A^\top = v I_v,
> \]
> hence a Hadamard matrix.

This is a breakthrough because it upgrades the current library from “difference sets imply some Gram identities” to a **certified orthogonal design compiler**. If formalized cleanly, it means Menon, Paley, and later Singer-derived constructions all become instances of one algebraic pipeline.

---

## Core theorem to formalize

### Mathematical statement

Let \(G\) be a finite group of cardinality \(v\), and let \(D \subseteq G\) be a difference set with parameters \((v,k,\lambda)\). Assume the Menon relation
\[
v = 4u^2,\qquad k = 2u^2 - u,\qquad \lambda = u^2 - u
\]
for some natural number \(u\). Let \(A\) be the sign matrix associated to \(D\), obtained from the incidence matrix by replacing membership with \(+1\) and non-membership with \(-1\). Then
\[
A A^\top = v I.
\]
Equivalently, \(A\) is Hadamard.

The key arithmetic identity hidden here is
\[
v - 4(k-\lambda) = 0,
\]
because for Menon parameters
\[
k-\lambda = u^2,\qquad v = 4u^2.
\]
Thus the generic Gram theorem should collapse exactly to the Hadamard identity.

---

## Lean 4 theorem signature target

You should aim for a theorem of essentially this shape, adapted to the exact existing names in Mathlib/catalog:

```lean
theorem menon_differenceSet_yields_hadamard
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (D : Finset G) (u v k λ : ℕ)
    (hDS : IsDifferenceSet D v k λ)
    (hv : v = 4 * u^2)
    (hk : k = 2 * u^2 - u)
    (hλ : λ = u^2 - u) :
    let A := differenceSetSignMatrix D
    A * A.transpose = (v : ℤ) • (1 : Matrix _ _ ℤ) := by
  ...
```

If the existing theorem `differenceSet_sign_gram` already has the more precise form

```lean
A * A.transpose = (v : R) • I + (v - 4 * (k - λ)) • J
```

then prove the stronger specialization theorem:

```lean
theorem menon_differenceSet_sign_gram_simplifies
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (D : Finset G) (u v k λ : ℕ)
    (hDS : IsDifferenceSet D v k λ)
    (hv : v = 4 * u^2)
    (hk : k = 2 * u^2 - u)
    (hλ : λ = u^2 - u) :
    let A := differenceSetSignMatrix D
    A * A.transpose = (v : ℤ) • (1 : Matrix _ _ ℤ) := by
  ...
```

And then package a concrete computational corollary for the first nontrivial Menon case:

```lean
theorem menon_16_6_2_hadamard
    (D : Finset (ZMod 16))
    (hD : IsDifferenceSet D 16 6 2) :
    let A := differenceSetSignMatrix D
    A * A.transpose = (16 : ℤ) • (1 : Matrix _ _ ℤ) := by
  ...
```

If a concrete certified Menon set in `ZMod 16` does not exist yet, then produce one in any abelian group of order 16 for which the construction is easiest to certify, e.g. `ZMod 4 × ZMod 4` or `(Fin 2 → ZMod 2) × (Fin 2 → ZMod 2)`.

---

## What to build on from the catalog

You should explicitly leverage:

- `differenceSet_sign_gram`
  - This is the engine. Do not reprove matrix orthogonality from scratch.
  - Extract its off-diagonal coefficient and show it vanishes under Menon arithmetic.

- Any existing `differenceSet_incidence_gram` or incidence-matrix theorem
  - Use this only if the sign theorem factors through incidence first.
  - Prefer the sign-level result if available; it is conceptually the right abstraction.

- Existing certified examples such as `singer_7_3_1`
  - Not because Singer is Menon, but because it demonstrates the intended API shape:
    certified finite combinatorial data should flow through a generic theorem into geometric/algebraic structure.

The philosophical objective is to prove that the infrastructure already knows more than we have asked of it.

---

## Proof strategy options

### Strategy A: Direct specialization of the generic sign Gram theorem
**Most promising.**

1. Apply `differenceSet_sign_gram` to obtain
   \[
   A A^\top = v I + (v - 4(k-\lambda)) J
   \]
   or its library equivalent.

2. Substitute the Menon parameter equalities `hv hk hλ`, reduce the scalar
   \[
   v - 4(k-\lambda)
   \]
   to zero by `ring`/`nlinarith`.

3. Simplify the `0 • J` term away and conclude
   \[
   A A^\top = v I.
   \]

**Why this is best:** it proves the strongest possible reusability claim: Menon Hadamards are not a separate construction, but a formal consequence of the universal difference-set orthogonality identity.

---

### Strategy B: Derive via incidence matrix and sign conversion
Useful if `differenceSet_sign_gram` is missing or awkward.

1. Start from `differenceSet_incidence_gram` to get the incidence matrix inner-product law.

2. Express the sign matrix as `A = 2B - J`, where `B` is the \(0/1\)-incidence matrix.

3. Expand
   \[
   (2B-J)(2B-J)^\top
   \]
   and substitute the incidence Gram relations plus the Menon arithmetic.

**Why it matters:** this gives a conceptual derivation from block designs to Hadamard matrices and may expose a more general theorem: symmetric BIBDs with \(v = 4(k-\lambda)\) yield Hadamards.

---

### Strategy C: Prove a broader symmetric-design criterion, then instantiate Menon
Potentially the most revolutionary.

1. First prove an abstract theorem:
   > If a symmetric \((v,k,\lambda)\)-design satisfies \(v = 4(k-\lambda)\), then its associated sign matrix is Hadamard.

2. Show that any Menon difference set produces a symmetric design with exactly these parameters.

3. Deduce the Menon theorem as a corollary.

**Why this is powerful:** it reframes Menon sets as one point in a larger certified design-theoretic landscape. This opens a route to a general formal classification program for orthogonal designs from combinatorial incidence data.

---

## Stronger theorem you should seriously attempt

Do not stop at the Menon parameter family if the algebra naturally generalizes. The real field-opening result is:

```lean
theorem differenceSet_hadamard_of_v_eq_four_mul_k_sub_lambda
    {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    (D : Finset G) (v k λ : ℕ)
    (hDS : IsDifferenceSet D v k λ)
    (hparam : v = 4 * (k - λ)) :
    let A := differenceSetSignMatrix D
    A * A.transpose = (v : ℤ) • (1 : Matrix _ _ ℤ) := by
  ...
```

Then Menon is the arithmetic corollary:

```lean
theorem menon_parameters_imply_v_eq_four_mul_k_sub_lambda
    (u : ℕ) :
    4 * u^2 = 4 * ((2 * u^2 - u) - (u^2 - u)) := by
  ring
```

This abstraction is mathematically cleaner and strategically superior. It says the true invariant is not “Menon-ness” but the orthogonality relation \(v = 4(k-\lambda)\).

---

## Cross-domain connections to exploit

### 1. Combinatorial design theory ↔ harmonic analysis
Difference sets are group-ring objects whose autocorrelation is flat. Hadamard matrices are discrete orthogonal transforms. Your theorem says:
- **flat two-level autocorrelation in a group**
- becomes
- **exact orthogonality of a sign transform matrix**.

This is the finite-algebraic shadow of spectral flatness, with obvious links to coding theory and compressed sensing.

### 2. Finite geometry ↔ operator algebra
The matrix identity \(A A^\top = vI\) is not just combinatorics; it is a finite-dimensional operator statement. This suggests a certified path from incidence geometry to structured orthogonal operators, potentially relevant to:
- equiangular line systems,
- conference matrices,
- association schemes,
- quantum information constructions.

### 3. Number theory ↔ formal design synthesis
Paley and Menon are usually treated as separate families. Your theorem should reveal they are both outputs of one certified machine:
- arithmetic input: difference set in a finite group,
- algebraic compiler: Gram theorem,
- analytic output: orthogonal sign matrix.

That is a genuine formal unification.

---

## Concrete subgoals

1. **Specialization theorem**
   - Prove the generic `v = 4 * (k - λ)` criterion.

2. **Menon arithmetic corollary**
   - Derive the criterion from Menon parameters.

3. **First explicit instance**
   - Either:
     - certify a concrete Menon difference set of parameters `(16,6,2)`, or
     - if construction overhead is too high, state the instance theorem assuming `IsDifferenceSet D 16 6 2` and then separately search for a native-decidable witness.

4. **Minimal matrix API overhead**
   - The assignment explicitly demands “no new matrix algebra lemmas required.”
   - Honor this if at all possible. If one tiny simplification lemma is unavoidable, isolate it and prove it once.

---

## Suggested Lean proof skeleton

The proof should look morally like:

```lean
  classical
  dsimp
  simpa [hv, hk, hλ, sub_eq_add_neg, pow_two] using
    differenceSet_sign_gram (D := D) (v := v) (k := k) (λ := λ) hDS
```

or, if arithmetic normalization is needed:

```lean
  have hzero : (v : ℤ) - 4 * ((k : ℤ) - (λ : ℤ)) = 0 := by
    subst hv; subst hk; subst hλ
    ring
  simpa [hzero] using differenceSet_sign_gram ...
```

If coercions are painful, prove a local arithmetic lemma over `ℤ` first.

---

## Why this would be a breakthrough

If successful, this result certifies a **Paley-Hadamard Design Factory** in a genuinely reusable sense:

- difference sets become machine-verifiable blueprints for orthogonal matrices;
- combinatorial parameter identities become exact spectral statements;
- formalized number-theoretic constructions can be exported automatically into matrix theory.

This is not a small extension. It is a shift from certifying isolated objects to certifying a **construction paradigm**.

A mathematician reading the final theorem should immediately see the next horizon:
- Menon and Paley are unified,
- Singer may feed projective-plane geometry,
- character sums, designs, and orthogonal operators are all living in one formal ecosystem.

That is exactly the sort of theorem that changes what formal mathematics is for.

---

## Application keywords

Hadamard matrices; Menon difference sets; symmetric designs; balanced incomplete block designs; Gram matrices; orthogonal sign matrices; finite harmonic analysis; autocorrelation flattening; combinatorial design synthesis; formalized finite geometry; certified spectral combinatorics; association schemes; coding theory; quantum information design; group-ring methods.

---

## Deliverables

1. The main Lean theorem specializing `differenceSet_sign_gram` to the condition `v = 4 * (k - λ)`.
2. The Menon-parameter corollary.
3. If feasible, a concrete `(16,6,2)` certified instance checked by `native_decide`.
4. Minimal or zero new matrix lemmas.
5. A structured `FUTURE_DIRECTIONS.md` containing **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - a concrete formal test,
   - a pass/fail criterion.

---

## Required FUTURE_DIRECTIONS hypotheses

At minimum, include hypotheses of the following caliber:

### Hypothesis A: Symmetric-design orthogonality criterion
**Conjecture:** Every certified symmetric design with \(v = 4(k-\lambda)\) yields a Hadamard matrix through the same sign-Gram specialization, independent of group structure.

**Test:** Formalize the theorem at the level of symmetric BIBDs rather than difference sets.

### Hypothesis B: Paley–Menon unification
**Conjecture:** The existing Paley constructions and future Menon constructions are both instances of a single theorem from two-level correlation identities in finite groups.

**Test:** Refactor both proofs to terminate in the same abstract sign-Gram lemma.

### Hypothesis C: Conference-matrix frontier
**Conjecture:** A nearby specialization of the incidence/sign Gram machinery yields conference matrices when the off-diagonal term is constant but nonzero.

**Test:** Identify the exact parameter relation and certify a smallest example.

### Hypothesis D: Projective-plane extraction from Singer data
**Conjecture:** The incidence Gram theorem already contains enough information to certify the full Fano plane axioms from `(7,3,1)` Singer data.

**Test:** Produce `IsProjectivePlaneIncidence (differenceSetIncidenceMatrix D)` from `IsDifferenceSet D 7 3 1`.

### Hypothesis E: Character-theoretic automation
**Conjecture:** A finite-field character API over arbitrary `GF(q)` can generate certified difference sets whose Gram identities automatically synthesize strongly regular graphs and Hadamard matrices.

**Test:** Implement the quadratic-character layer for one non-prime field and recover a Paley-type object.

Be bold: the theorem above is the seed of a certified design-to-operator correspondence. Prove it in a way that makes the next five theorems inevitable.

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
