# Mode: prove

## Assignment: Langlands Program — Functoriality via Local Satake Data and Symmetric Power Transfer

Aristotle, do **not** aim for a vague “formalize automorphic representations” project. That is too diffuse for a breakthrough cycle. Instead, carve out a mathematically sharp and formally tractable **local-to-global prototype of functoriality**: build a Lean 4 theory of **unramified local Langlands data for `GL(2)`**, define **symmetric-square transfer on Satake parameters**, prove its structural invariants, and derive a **verified algorithm** that computes Euler factors and checks transfer identities prime-by-prime. This is not the full Langlands correspondence — it is something more valuable for this cycle: a rigorous, extensible **formal skeleton of functoriality** that can support future global automorphic theory.

The revolutionary point is this: if you can prove that the symmetric-square transfer is internally coherent, multiplicative on Euler factors, and spectrally stable under iteration bounds, then you create the first Lean-native bridge between:
- representation-theoretic parameter transfer,
- algebraic identities of local `L`-factors,
- and computational verification of functorial predictions.

That opens a new formal research program: **verified Langlands experimentation**.

---

## Precise Theorem Targets

You should introduce a new formal structure encoding unramified local `GL(2)` Langlands data by Satake parameters. Keep the design minimal but mathematically meaningful.

### Novel definitions required

Define a new structure such as:

```lean
structure UnramifiedGL2Satake where
  α : ℂ
  β : ℂ
```

Optionally extend with a central character constraint or temperedness predicate:

```lean
def UnramifiedGL2Satake.unitary (π : UnramifiedGL2Satake) : Prop :=
  Complex.abs π.α = 1 ∧ Complex.abs π.β = 1

def UnramifiedGL2Satake.centralCharacter (π : UnramifiedGL2Satake) : ℂ :=
  π.α * π.β
```

Define the symmetric square transfer to `GL(3)`:

```lean
def symmSquareTransfer (π : UnramifiedGL2Satake) : Fin 3 → ℂ
| 0 => π.α ^ 2
| 1 => π.α * π.β
| 2 => π.β ^ 2
```

Define local Euler factors as formal polynomials/rational functions. A tractable choice is the degree-`n` Euler polynomial
\[
P_\pi(T)=\prod_i (1-a_iT),
\]
with `a_i` the Satake parameters. For `GL(2)`:

```lean
def localEulerPolyGL2 (π : UnramifiedGL2Satake) : Polynomial ℂ :=
  (Polynomial.X - Polynomial.C π.α) * (Polynomial.X - Polynomial.C π.β)
```

or the more standard variable convention:

```lean
def localEulerFactorGL2 (π : UnramifiedGL2Satake) : Polynomial ℂ :=
  (1 - Polynomial.C π.α * Polynomial.X) *
  (1 - Polynomial.C π.β * Polynomial.X)
```

and similarly for the transferred `GL(3)` data.

---

## Core theorem 1: explicit symmetric-square Euler factor identity

This should be the flagship theorem.

### Mathematical statement
For every unramified `GL(2)` Satake parameter pair `(α,β)`, the local Euler factor of the symmetric-square transfer equals the cubic Euler factor with roots `α², αβ, β²`:
\[
L_p(\mathrm{Sym}^2\pi,T)^{-1}
=
(1-\alpha^2 T)(1-\alpha\beta T)(1-\beta^2 T).
\]

If you define the standard `GL(2)` Euler polynomial
\[
P_\pi(T)=(1-\alpha T)(1-\beta T),
\]
then the transferred polynomial is exactly:
\[
P_{\mathrm{Sym}^2 \pi}(T)
=(1-\alpha^2T)(1-\alpha\beta T)(1-\beta^2T).
\]

### Lean 4 target signature
A realistic signature is:

```lean
theorem localEulerFactor_symmSquare
    (π : UnramifiedGL2Satake) :
    localEulerFactorGL3FromTriple (symmSquareTransfer π) =
      (1 - Polynomial.C (π.α ^ 2) * Polynomial.X) *
      (1 - Polynomial.C (π.α * π.β) * Polynomial.X) *
      (1 - Polynomial.C (π.β ^ 2) * Polynomial.X) := by
```

If you define `localEulerFactorSymmSquare` directly, then:

```lean
theorem localEulerFactorSymmSquare_eq
    (π : UnramifiedGL2Satake) :
    localEulerFactorSymmSquare π =
      (1 - Polynomial.C (π.α ^ 2) * Polynomial.X) *
      (1 - Polynomial.C (π.α * π.β) * Polynomial.X) *
      (1 - Polynomial.C (π.β ^ 2) * Polynomial.X) := by
```

### Why this matters
This is the first nontrivial formal instance of **functorial transfer as a theorem about local factors**, not merely a definition. It is the Lean analogue of the most basic fingerprint of Langlands functoriality.

---

## Core theorem 2: coefficient formula linking transfer to Hecke data

Introduce Hecke-style coefficients:
\[
a_p(\pi)=\alpha+\beta,\qquad \omega_p(\pi)=\alpha\beta.
\]
Then prove the transferred cubic factor can be rewritten purely in terms of `a_p` and `ω_p`:
\[
(1-\alpha^2T)(1-\alpha\beta T)(1-\beta^2T)
=
1-(a_p^2-\omega_p)T + \omega_p(a_p^2-\omega_p)T^2 - \omega_p^3 T^3.
\]

This is the key compression theorem: transfer is encoded by classical Hecke data.

### Lean 4 target signature

```lean
def heckeTrace (π : UnramifiedGL2Satake) : ℂ := π.α + π.β
def heckeDet   (π : UnramifiedGL2Satake) : ℂ := π.α * π.β

theorem symmSquare_coeff_formula
    (π : UnramifiedGL2Satake) :
    localEulerFactorSymmSquare π =
      1
      - Polynomial.C (heckeTrace π ^ 2 - heckeDet π) * Polynomial.X
      + Polynomial.C ((heckeDet π) * (heckeTrace π ^ 2 - heckeDet π)) * Polynomial.X^2
      - Polynomial.C (heckeDet π ^ 3) * Polynomial.X^3 := by
```

You may need to adjust notation to polynomial constructors already in Mathlib. The exact normal form is less important than proving a genuine cubic coefficient identity.

### Why this matters
This theorem turns representation transfer into an **explicit algebraic compression law**, making the functorial lift computable from Hecke eigenvalue data. That is exactly the kind of statement that can support later modular-form and automorphic experiments.

---

## Core theorem 3: temperedness/unitarity is preserved by symmetric-square transfer

Assume `|α|=|β|=1`. Then the transferred parameters also have modulus `1`:
\[
|\alpha^2|=|\alpha\beta|=|\beta^2|=1.
\]

### Lean 4 target signature

```lean
theorem unitary_preserved_by_symmSquare
    (π : UnramifiedGL2Satake)
    (hπ : π.unitary) :
    Complex.abs (symmSquareTransfer π 0) = 1 ∧
    Complex.abs (symmSquareTransfer π 1) = 1 ∧
    Complex.abs (symmSquareTransfer π 2) = 1 := by
```

Or if you define a `UnitaryGL3Satake` predicate:

```lean
theorem symmSquareTransfer_unitary
    (π : UnramifiedGL2Satake)
    (hπ : π.unitary) :
    GL3SatakeUnitary (symmSquareTransfer π) := by
```

### Why this matters
This is a genuine structural compatibility theorem: functorial transfer preserves the spectral condition corresponding to temperedness in the unramified case. It is not cosmetic algebra; it is the first formal spectral sanity check of the transfer.

---

## Cross-domain theorem: spectral transfer stability and complexity of verification

You are required to connect this domain to another field. Do this in a way that is mathematically meaningful and uses catalog results.

Define a computational verifier that, given truncated prime-indexed Satake data, checks the symmetric-square Euler factor identity over a finite set. Then prove a nontrivial bound on repeated transfer verification complexity or spectral growth by leveraging:

- `spectral_transfer_iterate_bound`
- `circuit_lower_bound_from_obstruction`
- `depth_lower_bound_from_degree`
- `mulGates_lower_bound_from_degree`

### Suggested cross-domain theorem
Construct a polynomial map from Hecke data `(a, ω)` to symmetric-square coefficients, and prove its degree forces nontrivial algebraic circuit lower bounds for any exact symbolic evaluator in your model.

### Lean-style target signature
Something like:

```lean
def symmSquareCoeffMap : ℂ × ℂ → ℂ × ℂ × ℂ := ...

theorem symmSquareCoeffMap_degree_lower_bound
    (C : AlgCircuit ℂ 2) :
    -- formulate that any circuit computing the cubic coefficient map
    -- must satisfy a nontrivial depth or multiplication-gate lower bound
    ∃ d : ℕ, d ≤ 3 ∧ depth_lower_bound_from_degree C d ≤ circuitDepth C := by
```

If direct circuit semantics are too heavy, prove instead a transfer-growth theorem using `spectral_transfer_iterate_bound` for an iterated transfer operator on coefficient vectors.

### Why this matters
This is the “science fiction” move: **Langlands functoriality meets computational complexity**. If transfer maps have certified algebraic complexity, then formal Langlands computations become analyzable not only for correctness but for intrinsic complexity. That is a new research direction.

Application keywords: **Langlands program, functoriality, local factors, Satake parameters, Hecke eigenvalues, spectral transfer, algebraic circuit complexity, verified symbolic computation**.

---

## Stronger optional theorem: rigidity of transfer from Hecke trace and determinant

Prove that if two unramified `GL(2)` parameters have the same trace and determinant, then their symmetric-square Euler factors agree.

### Mathematical statement
If
\[
\alpha+\beta=\alpha'+\beta',\qquad \alpha\beta=\alpha'\beta',
\]
then
\[
L_p(\mathrm{Sym}^2\pi,T)=L_p(\mathrm{Sym}^2\pi',T).
\]

### Lean target
```lean
theorem symmSquare_well_defined_on_hecke_data
    (π σ : UnramifiedGL2Satake)
    (htr : heckeTrace π = heckeTrace σ)
    (hdet : heckeDet π = heckeDet σ) :
    localEulerFactorSymmSquare π = localEulerFactorSymmSquare σ := by
```

This theorem says the transfer descends to the coarse moduli of semisimple conjugacy classes. It is conceptually deep and formally accessible.

---

## Proof strategy architecture

You must pursue at least 2–3 serious proof routes and choose the best one per theorem.

### Strategy A: explicit polynomial algebra in `Polynomial ℂ`
Best for Theorems 1 and 2.

1. Define the Euler factors as products in `Polynomial ℂ`.
2. Expand using `ring_nf`, `simp`, `Polynomial` identities, and controlled `calc`.
3. Rewrite coefficients in terms of `α + β` and `α * β`.
4. Use multi-step algebraic normalization, not trivial reflexivity.

Why promising: it gives exact, machine-checkable coefficient formulas and naturally yields the Hecke-data compression theorem.

### Strategy B: root multiset / elementary symmetric polynomial approach
Best for theorem modularity and future generalization to `Symm^n`.

1. Package transferred Satake parameters as a finite family.
2. Identify Euler polynomial coefficients with elementary symmetric polynomials of roots.
3. Compute the elementary symmetric polynomials of `{α², αβ, β²}`.
4. Deduce coefficient formulas conceptually.

Why promising: this aligns with the conceptual content of Langlands transfer and scales toward higher symmetric powers. If Mathlib support is sufficient, this is the most elegant route.

### Strategy C: contradiction and rigidity route
Best for well-definedness and uniqueness theorems.

1. Assume transferred Euler factors differ.
2. Compare coefficients of the cubic polynomials.
3. Use the trace/determinant equalities to show every coefficient matches.
4. Derive contradiction via polynomial extensionality.

Why promising: this naturally uses `by_contra`, coefficient extraction, and multi-step `calc`, satisfying the depth requirement while proving a mathematically meaningful rigidity principle.

---

## Specific proof-tactic requirements to satisfy

Your file must contain **at least 3 theorems** with genuinely nontrivial proofs using several of:
- `induction`
- `rcases`
- `by_contra`
- `field_simp`
- multi-step `calc`
- coefficient comparison in polynomials
- extensionality (`ext`)
- case splits on `Fin 3`

Suggestions:
- Use `rcases hπ with ⟨hα, hβ⟩` in unitary preservation.
- Use `by_contra hneq` + coefficient extensionality in rigidity.
- Use `calc` chains to rewrite `|α*β|`, `|α^2|`, etc.
- If you define iterated symmetric-power coefficient recurrences, use induction on the iteration count.

---

## Building on catalog theorems

Even if the catalog is not directly Langlands-native, use it as a scaffold for a field-opening cross-connection.

1. **`spectral_transfer_iterate_bound`**  
   Build an abstract transfer operator on coefficient vectors of local Euler factors and prove an iterate bound for repeated transfer/composition. This gives a spectral-dynamical interpretation of functoriality.

2. **`depth_lower_bound_from_degree`** and **`mulGates_lower_bound_from_degree`**  
   The symmetric-square coefficient map has cubic output in the input parameters. Formalize this degree growth and derive lower bounds for exact symbolic circuits computing transfer data.

3. **`circuit_lower_bound_from_obstruction`**  
   Package a transfer map obstruction if needed: exact transfer evaluation cannot be represented below a certain complexity threshold in your circuit model.

This is not forced imitation — it is deliberate cross-pollination. The theorem should say that **functorial transfer has certified algebraic complexity**.

---

## Conjecture with testable prediction

State at least one falsifiable conjecture, and make the computational disproof criterion explicit.

### Conjecture: coefficient rigidity for higher symmetric powers
For every `n ≥ 2`, the unramified local Euler factor of `Symm^n(π)` is determined polynomially by the Hecke trace `a = α+β` and determinant `ω = αβ`, with total degree exactly `n+1` in the Euler polynomial variable and controlled algebraic degree in `(a,ω)`.

A testable finite version:
- For `n = 2,3,4`, implement explicit symbolic generation of Satake monomials.
- Compute the resulting Euler polynomial.
- Check whether all coefficients can be rewritten as polynomials in `a` and `ω`.
- A counterexample at `n=4` with symbolic or randomized complex substitutions would disprove an overstrong formulation.

Lean-adjacent statement:

```lean
conjecture higher_symm_power_hecke_polynomiality
    (n : ℕ) (h : 2 ≤ n) :
    ∃ P : Polynomial (ℂ × ℂ),
      encodesSymmPowerEulerFactor n P
```

You do not need to prove this now, but you **must** state it clearly and design a computational test in `demo.py`.

---

## Verified algorithm requirement

You must produce a verified computational method, not just theorems.

### Required algorithm
Implement an algorithm that:
1. accepts symbolic or numeric `α, β`,
2. computes the `GL(2)` Euler factor,
3. computes the symmetric-square transferred `GL(3)` Euler factor,
4. computes the coefficient form in terms of `a = α+β`, `ω = αβ`,
5. verifies equality,
6. optionally checks unitary preservation when `|α|=|β|=1`.

This should be backed by Lean theorems for correctness of the formulas.

Potential Lean-facing function:
```lean
def computeSymmSquareCoeffs (π : UnramifiedGL2Satake) : ℂ × ℂ × ℂ := ...
```

Correctness theorem:
```lean
theorem computeSymmSquareCoeffs_correct
    (π : UnramifiedGL2Satake) :
    encodesEulerCoeffs π (computeSymmSquareCoeffs π) := by
```

---

## demo.py requirements

Your `demo.py` must:
- allow interactive input of `(α, β)`,
- display the original and transferred Euler factors,
- display the Hecke-data coefficient formula,
- numerically test unitary preservation,
- run randomized examples,
- and include a finite test harness for the conjecture on higher symmetric powers (`n = 2,3,4`).

This is essential: the code should help generate the next conjectures.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **A structured `FUTURE_DIRECTIONS.md`** with **3–5 testable scientific hypotheses**, each a falsifiable conjecture with a clear computational or formal test.
2. **A `RESEARCH_PAPER.md`** that is a standalone scientific paper: motivation, definitions, theorem statements, proof ideas, significance, and next steps — understandable without reading the Lean files.
3. **An `ARTICLE.md`** in Scientific American style for broad readership, explaining what functoriality is, what was actually proved, and why verified mathematics matters.
4. **A verified algorithm or computational method** formalized in Lean and explained mathematically.
5. **A `demo.py`** demonstrating the result interactively.

---

## Application keywords

**Langlands program, functoriality, symmetric square lift, local Langlands, Satake parameters, Euler factors, Hecke eigenvalues, automorphic representations, spectral transfer, algebraic circuit complexity, verified symbolic computation, formalized number theory**

---

## Final execution directive

Produce a Lean 4 development with **at least 3 nontrivial theorems**, centered on the precise local functoriality prototype above. Minimize sorry by choosing definitions that let you prove genuine mathematics now. The target is not a toy: it is a **formal architecture for Langlands transfer**, explicit enough to compute, rigid enough to prove, and visionary enough to launch a new verified research program.

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

Research domain: Algebra
Research mode: prove
