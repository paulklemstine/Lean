## Assignment: Cross-pollination

Mode: **prove**

Prove genuinely new, non-trivial bridge theorems that force interaction between the currently isolated spectral, congruence, and polynomial/eigenvalue fragments in the catalog. Do not merely sharpen constants. The target is a structural theorem that transfers information from one domain into another.

Minimize `sorry`. If you introduce a definition, make it mathematically inevitable and reusable.

---

## Research Direction

The central mandate is **cross-domain rigidity**:

- spectral constraints on regular/Ihara-style graphs should produce arithmetic congruence consequences;
- congruence identities of squares and norms should obstruct or certify candidate eigenvalue configurations;
- polynomial root identities and low-degree characteristic relations should be tested as finite-dimensional shadows of graph spectra.

In particular, every theorem you prove in one direction should immediately be tested for implications in another. For example:

- a congruence obstruction may forbid an integer-valued eigenvalue tower;
- a trace/energy bound may limit the number of eigenvalues satisfying a modular square relation;
- a cubic polynomial identity like `eigenvalue_one_B2` may be reinterpreted as a certified spectral witness for a 3-step recurrence or adjacency-minimal polynomial phenomenon.

This is not a collection of separate exercises. It is the beginning of a **spectral arithmetic transfer theory**.

---

## Mathematical Framing

You already have the following verified ingredients:

1. `regular_graph_eigenvalue_bound`
   - file: `Algebra/Other/IharaZeta.lean`
   - a graph-theoretic spectral bound for regular graphs.

2. `spectral_energy_trace_bound`
   - file: `Algebra/SpectralArithmetic/Bridges.lean`
   - a certified bridge from a finite family of real eigenvalues to a trace/energy inequality.

3. `eigenvalue_one_B2`
   - file: `Algebra/AutoResearch/DeepOpenProblems.lean`
   - a concrete cubic identity at `1`.

4. `congruence_of_squares_zmod`
   - file: `Algebra/Core/ChimeraFactoring.lean`
   - modular square equality implies a constrained congruence relation.

5. `norm_congruence_bridge`
   - file: `Algebra/Core/OpenQuestions.lean`
   - a prime/norm congruence bridge for primes `p ≡ 3 mod 4`.

Your task is to build a theorem that uses at least **two** of these in a mathematically meaningful way, ideally three.

---

## Primary Target Theorem

Define and prove a theorem saying that if two integer-valued spectral parameters have the same square modulo `N`, then their spectral energy contribution differs by a controlled congruence-obstruction term. At minimum, formalize the absolute-difference divisibility statement; ideally, combine it with a trace/energy bound.

### Precise theorem statement

A highly promising first target is:

```lean
theorem int_sq_congruence_implies_dvd_prod_sum
    (N : ℕ) (a b : ℤ)
    (h : ((a : ZMod N) ^ 2 = (b : ZMod N) ^ 2)) :
    ((N : ℤ) ∣ (a - b) * (a + b))
```

This is elementary but nontrivial, reusable, and creates the exact algebraic hinge between modular square coincidences and spectral parameter collisions.

Then push to the spectral bridge theorem:

```lean
theorem spectral_pair_square_congruence_obstruction
    (N n : ℕ) (hn : 0 < n) (ev : Fin n → ℤ) (i j : Fin n)
    (h : (((ev i : ℤ) : ZMod N) ^ 2 = (((ev j : ℤ) : ZMod N) ^ 2))) :
    ((N : ℤ) ∣ (ev i - ev j) * (ev i + ev j))
```

This theorem says: **modular square collisions among integer eigenvalue candidates force exact integral divisibility relations**. It converts a residue-class coincidence into a rigid arithmetic certificate.

### Stronger bridge target

If you can define an integer-spectrum condition for a graph or spectral package, prove:

```lean
theorem spectral_energy_modular_collision_bound
    (N n : ℕ) (hn : 0 < n) (ev : Fin n → ℤ)
    (hpair : ∀ i j : Fin n,
      (((ev i : ℤ) : ZMod N) ^ 2 = (((ev j : ℤ) : ZMod N) ^ 2)) →
      ((N : ℤ) ∣ (ev i - ev j) * (ev i + ev j))) :
    True
```

This placeholder signature is intentionally weak as written; strengthen it into a real theorem by combining:
- the divisibility obstruction above,
- coercion to `ℝ`,
- `spectral_energy_trace_bound`.

A more ambitious concrete version would bound how many pairwise distinct integer eigenvalues can all occupy the same square class mod `N` under a fixed energy budget.

---

## Secondary Target Theorem: Prime `3 mod 4` obstruction

Use `norm_congruence_bridge` to show that for primes `p ≡ 3 mod 4`, a modular square coincidence plus a norm condition forces a sign collapse or divisibility obstruction. Even a clean special case would be valuable.

Suggested theorem shape:

```lean
theorem prime_three_mod_four_square_obstruction
    (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
    (a b : ℤ)
    (hsq : (((a : ℤ) : ZMod p) ^ 2 = (((b : ℤ) : ZMod p) ^ 2))) :
    ((p : ℤ) ∣ (a - b) * (a + b))
```

This may look similar to the primary theorem, but the prime `3 mod 4` hypothesis gives you leverage for stronger corollaries. The real goal is to derive consequences unavailable over general moduli.

Potential corollary target:

```lean
theorem prime_three_mod_four_no_nonsign_square_collision
    (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
    (a b : ZMod p)
    (h : a ^ 2 = b ^ 2) :
    a = b ∨ a = -b
```

If Mathlib already makes this easy in fields, use it as a lemma and then connect it back to integer lifts and divisibility. The breakthrough is not the field fact itself, but the **transfer back to integral spectral data**.

---

## Tertiary Target: Cubic spectral witness

Use `eigenvalue_one_B2` not as an isolated arithmetic curiosity, but as evidence for a low-degree annihilating polynomial pattern. Introduce a reusable predicate for a family of eigenvalues satisfying a cubic relation, then prove that the specific witness `1` satisfies it.

Suggested definition and theorem:

```lean
def satisfies_B2_poly (x : ℤ) : Prop :=
  x^3 - 5*x^2 + 5*x - 1 = 0

theorem satisfies_B2_poly_one : satisfies_B2_poly 1
```

Then seek a bridge theorem such as:

```lean
theorem B2_poly_factorization :
    ∀ x : ℤ, x^3 - 5*x^2 + 5*x - 1 = (x - 1) * (x^2 - 4*x + 1)
```

and, if useful over `ℝ`:

```lean
theorem B2_real_root_structure :
    ∀ x : ℝ, x^3 - 5*x^2 + 5*x - 1 = (x - 1) * (x^2 - 4*x + 1)
```

This creates a certified polynomial package that can later be connected to characteristic polynomials, transfer operators, or adjacency recurrences.

The revolutionary point: a verified low-degree spectral polynomial can become the seed of a **formalized spectral motive**, where graph eigenvalues, Hecke-like recurrences, and arithmetic congruences all satisfy common annihilators.

---

## Lean 4 Type Signatures to Target

At minimum, aim to implement some subset of the following exactly or with minor coercion adjustments:

```lean
theorem int_sq_congruence_implies_dvd_prod_sum
    (N : ℕ) (a b : ℤ)
    (h : ((a : ZMod N) ^ 2 = (b : ZMod N) ^ 2)) :
    ((N : ℤ) ∣ (a - b) * (a + b))
```

```lean
theorem spectral_pair_square_congruence_obstruction
    (N n : ℕ) (hn : 0 < n) (ev : Fin n → ℤ) (i j : Fin n)
    (h : (((ev i : ℤ) : ZMod N) ^ 2 = (((ev j : ℤ) : ZMod N) ^ 2))) :
    ((N : ℤ) ∣ (ev i - ev j) * (ev i + ev j))
```

```lean
def satisfies_B2_poly (x : ℤ) : Prop :=
  x^3 - 5*x^2 + 5*x - 1 = 0
```

```lean
theorem satisfies_B2_poly_one : satisfies_B2_poly 1
```

```lean
theorem B2_poly_factorization (x : ℤ) :
    x^3 - 5*x^2 + 5*x - 1 = (x - 1) * (x^2 - 4*x + 1)
```

If you can bridge to reals:

```lean
theorem spectral_energy_trace_bound_int_coe
    (n : ℕ) (hn : 0 < n) (ev : Fin n → ℤ) :
    -- formulate using (fun i => (ev i : ℝ))
    True
```

Replace `True` by an actual imported inequality once you inspect the precise statement of `spectral_energy_trace_bound`.

---

## Proof Strategy Architecture

### Strategy A: Direct algebraic transport through `ZMod` → divisibility
Most promising for the primary theorem.

1. From
   `((a : ZMod N)^2 = (b : ZMod N)^2)`,
   derive
   `((a - b : ℤ) : ZMod N) * ((a + b : ℤ) : ZMod N) = 0`
   by rewriting difference of squares.
2. Convert vanishing in `ZMod N` into divisibility by `N` in `ℤ`.
   This is the key bridge: look for standard lemmas relating integer casts to `ZMod` kernel/divisibility.
3. Package the result so it applies pointwise to spectral lists/functions `ev : Fin n → ℤ`.

Why this is strongest: it is robust, elementary, and creates a reusable arithmetic API for future spectral applications.

### Strategy B: Field-level sign classification for prime moduli, then lift
Best for the prime `3 mod 4` theorem.

1. Over `ZMod p` with `p` prime, use that
   `a^2 = b^2` implies `(a-b)(a+b)=0`.
2. Since `ZMod p` is a field, conclude `a = b ∨ a = -b`.
3. Lift this dichotomy to integer representatives and derive divisibility or norm consequences using `norm_congruence_bridge`.

Why this matters: it produces a much sharper theorem over prime moduli and connects modular spectral collisions to sign symmetry, suggesting a formal “modular folding” principle for spectra.

### Strategy C: Polynomial witness and energy compression
Best for the cubic direction.

1. Factor the cubic polynomial from `eigenvalue_one_B2`.
2. Interpret roots as admissible spectral values in a toy finite spectrum model.
3. Use `spectral_energy_trace_bound` to show that any spectrum constrained to these roots satisfies an explicit energy/tracial restriction.

Why this is visionary: it turns a single checked identity into a formalized prototype of low-degree spectral algebra, a stepping stone toward characteristic-polynomial rigidity results.

---

## Cross-Domain Connections

You must explicitly test each theorem for consequences in at least one other domain.

### 1. Spectral graph theory ↔ arithmetic congruence
`regular_graph_eigenvalue_bound` constrains eigenvalue size; your congruence theorems constrain eigenvalue residue classes. Together they suggest finite-search rigidity: only finitely many integer spectra can satisfy both a growth bound and modular square-collision pattern.

### 2. Trace/energy inequalities ↔ modular collisions
If many eigenvalues share the same square class modulo `N`, then pairwise products `(λ_i - λ_j)(λ_i + λ_j)` are all divisible by `N`. Combined with energy bounds, this could force concentration, sign pairing, or bounded multiplicity phenomena.

### 3. Polynomial identities ↔ adjacency/minimal polynomial theory
The cubic `x^3 - 5x^2 + 5x - 1` is not merely an arithmetic expression; it can be treated as a candidate annihilator for transfer operators, adjacency restrictions, or toy Hecke actions. Formalizing its factorization opens the door to verified minimal-polynomial arguments.

### 4. Number theory ↔ certified computation
The divisibility theorems can become exact computational certificates. If a proposed integer spectrum fails the modular obstruction, it is formally impossible. This is ideal for future automated theorem search and counterexample elimination.

---

## Why This Would Be a Breakthrough

A successful result here would establish the first layer of a **formal spectral arithmetic transfer principle** in Lean:

- modular congruence data on candidate eigenvalues becomes exact integral divisibility;
- graph-theoretic spectral bounds become arithmetic search constraints;
- low-degree polynomial identities become reusable spectral witnesses.

This is field-opening because it suggests a new style of formal mathematics: not isolated proofs in graph theory or number theory, but a verified infrastructure where **spectra, congruences, norms, and polynomial annihilators talk to each other**.

That opens several future programs:
- certified exclusion of impossible spectra for graph families;
- arithmetic filtering of automorphic or Ihara-style spectral candidates;
- machine-assisted discovery of spectral congruence laws;
- formalized “modular shadow” methods for operator spectra.

---

## Concrete Build Plan

1. Inspect the exact statements of:
   - `regular_graph_eigenvalue_bound`
   - `spectral_energy_trace_bound`
   - `congruence_of_squares_zmod`
   - `norm_congruence_bridge`

2. Prove the clean algebraic bridge theorem first:
   - `int_sq_congruence_implies_dvd_prod_sum`

3. Generalize it pointwise to finite spectral families:
   - `spectral_pair_square_congruence_obstruction`

4. Package the cubic identity:
   - `satisfies_B2_poly`
   - `satisfies_B2_poly_one`
   - `B2_poly_factorization`

5. Attempt one genuinely cross-domain corollary using a catalog theorem:
   - either combine modular collision with `spectral_energy_trace_bound`,
   - or combine prime-modulus obstruction with `norm_congruence_bridge`.

If one route stalls, pivot immediately to the other. Do not burn the cycle on a single brittle coercion battle.

---

## Lean Tactics / Technical Notes

- Expect coercion work between `ℕ`, `ℤ`, `ℝ`, and `ZMod N`.
- Search for lemmas about:
  - `sub_eq_add_neg`
  - `sq`
  - `pow_two`
  - `Int.coe_zmod_eq_zero_iff_dvd`
  - ring identities in `ZMod`
  - `by nlinarith`, `ring`, `norm_num`, `omega`
- For factorization theorems, `ring` or `ring_nf` should dispatch the algebra.
- For divisibility from equality in `ZMod`, identify the kernel-of-cast lemma early; that is the main technical bottleneck.

---

## Deliverables

Required:
- Lean 4 code with theorems above or strengthened variants.
- Minimal `sorry`.
- `FUTURE_DIRECTIONS.md`

Optional but encouraged:
- `ARTICLE.md`
- `RESEARCH_PAPER.md`
- a small experiment file enumerating integer spectral candidates under modular constraints.

---

## Required FUTURE_DIRECTIONS.md

Produce `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, each including:
1. a precise theorem statement,
2. a proposed Lean type signature,
3. 2 proof strategy ideas,
4. explicit cross-domain significance.

The next steps should be ambitious, for example:
- modular multiplicity bounds for integer spectra,
- characteristic-polynomial congruence obstructions for regular graphs,
- prime `3 mod 4` exclusion theorems for norm-generated eigenvalue sets,
- formalized finite-search classification of spectra under energy and congruence constraints.

---

## Application Keywords

spectral arithmetic, Ihara zeta, modular eigenvalue obstructions, congruence rigidity, energy-trace inequalities, integer spectra, finite fields, norm forms, characteristic polynomials, formal verification, graph spectra, arithmetic transfer, Lean 4, Mathlib, certified exclusion, spectral classification

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

Research domain: Algebra
Research mode: prove
