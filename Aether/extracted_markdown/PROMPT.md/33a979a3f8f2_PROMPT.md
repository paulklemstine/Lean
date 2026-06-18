## Assignment: Direction 2: Universality for General Semidirect Products

Prove a genuinely new universality theorem for generation thresholds in semidirect products, elevating the wreath-product phenomenon into a structural principle about permutation complexity, subgroup growth, and probabilistic generation.

This must not be a cosmetic generalization. The goal is to isolate the exact abstract mechanism by which the acting group contributes only lower-order entropy, while the base direct power \(G^m\) dictates the leading term. If successful, this would convert a family-specific phase transition into a theorem schema for broad classes of permutation and linear actions.

Build explicitly on:
- `Pythagorean/WreathPhaseTransition.lean`
- `Pythagorean/WreathPerturbation.lean`

especially the abstractions behind:
- `WreathPressureData`
- `PressureSubcriticalInM`
- `WreathPressureSystem`

Your task is to identify what in those files is truly wreath-specific and what is secretly semidirect-universal.

## Core Vision

For finite groups \(G\), the direct power \(G^m\) carries an extensive “generation pressure” proportional to \(m\). A semidirect product \(G^m \rtimes H_m\) should inherit the same first-order threshold whenever the action of \(H_m\) on coordinates is sufficiently low-complexity. The acting group may reorganize coordinates, but unless it creates exponentially many subgroup types or exponentially many orbit patterns, it should not alter the leading asymptotic generation law.

The breakthrough is to prove that **bounded orbit complexity implies threshold universality**:
\[
P(G^m \rtimes H_m)=m\cdot P(G)+o(m),
\]
for a robust class of actions \(H_m \curvearrowright \{1,\dots,m\}\).

This would open a new field-level program: **probabilistic generation under controlled symmetry complexity**.

---

## Precise Theorem Targets

You must formalize at least one new abstract structure capturing bounded orbit complexity and at least 3 substantial theorems.

### New definition (mandatory novelty)

Define a new structure encoding the complexity of a family of actions:

```lean
structure OrbitComplexityFamily where
  H : ℕ → Type*
  instGroup : ∀ m, Group (H m)
  act : ∀ m, MulAction (H m) (Fin m)
  orbit_count_bound :
    ∃ C d : ℕ, ∀ m k : ℕ,
      Fintype.card (Quotient (MulAction.orbitRel (H m) (Fin k → Fin m))) ≤ C * (m+1)^d * (k+1)^d
```

If this exact formulation is technically awkward, replace it by an equivalent polynomial bound on orbit counts of \(k\)-tuples, but the concept must be genuinely new and mathematically meaningful. You may want a more flexible variant using existence of a polynomial \(p(k,m)\), or a logarithmic entropy condition.

Also define an abstract pressure package extending the wreath one, for example:

```lean
structure SemidirectPressureData (G : Type*) [Group G] where
  P : ℝ
  base_additivity : ∀ m : ℕ, ...
  product_maximal_control : ...
  exotic_maximal_count : ...
```

Do not merely rename existing wreath structures; isolate the semidirect mechanism.

---

## Main Universality Theorem

A precise asymptotic theorem should be the centerpiece. One possible Lean-facing form:

```lean
theorem semidirect_pressure_universality
  (G : Type*) [Finite G] [Group G]
  (F : OrbitComplexityFamily)
  (P0 : SemidirectPressureData G)
  (hsubcritical : ∀ ε > 0, ∃ M, ∀ m ≥ M,
    pressure (SemidirectProduct (G := Fin m → G) (F.H m)) ≤ m * P0.P + ε * m)
  (hsupercritical : ∀ ε > 0, ∃ M, ∀ m ≥ M,
    m * P0.P - ε * m ≤ pressure (SemidirectProduct (G := Fin m → G) (F.H m))) :
  Filter.Tendsto
    (fun m : ℕ => pressure (SemidirectProduct (G := Fin m → G) (F.H m)) - m * P0.P)
    Filter.atTop
    (nhds 0)
```

If exact convergence to \(0\) is too strong for the current formal infrastructure, prove an asymptotic sandwich theorem of the form

```lean
theorem semidirect_pressure_linear_asymptotic
  ...
  : ∀ ε > 0, ∃ M, ∀ m ≥ M,
      |pressure (SemidirectProduct (G := Fin m → G) (F.H m)) - m * P0.P| ≤ ε * m
```

This is already field-opening if done at a genuine level of abstraction.

### Mathematical statement

For every finite group \(G\), every family \(H_m \leq \mathrm{Sym}(m)\) with polynomially bounded orbit complexity on \(k\)-tuples, and every semidirect product
\[
\Gamma_m := G^m \rtimes H_m,
\]
if the maximal subgroup classes induced by the action admit polynomial multiplicity bounds and non-product maximal subgroups have index growth subexponential in \(m\), then
\[
P(\Gamma_m) = m P(G) + o(m).
\]

You must make the hypotheses precise enough that the theorem is nontrivial and checkable in examples.

---

## Required Supporting Theorems

You need at least 3 deep theorems with real proof architecture. Here are the recommended targets.

### Theorem 1: Polynomial orbit complexity implies polynomial subgroup-class complexity

```lean
theorem bounded_orbit_complexity_controls_maximal_classes
  (F : OrbitComplexityFamily)
  (hmax : ... ) :
  ∃ d : ℕ, ∀ m : ℕ,
    numberOfExoticMaximalClasses (SemidirectProduct (G := Fin m → G) (F.H m))
      ≤ (m + 1)^d
```

Interpretation: bounded orbit complexity prevents an exponential explosion in conjugacy classes of maximal subgroups not coming from coordinatewise product structure.

This is one of the conceptual bridges: orbit equivalence data from permutation group theory controls subgroup statistics relevant to probabilistic generation.

### Theorem 2: Base pressure dominates semidirect pressure

```lean
theorem semidirect_pressure_upper_bound
  (G : Type*) [Finite G] [Group G]
  (F : OrbitComplexityFamily)
  (P0 : SemidirectPressureData G) :
  ∀ ε > 0, ∃ M, ∀ m ≥ M,
    pressure (SemidirectProduct (G := Fin m → G) (F.H m))
      ≤ m * P0.P + ε * m
```

This theorem should use decomposition over maximal subgroup families and show that the acting symmetry contributes only lower-order logarithmic/polynomial terms.

### Theorem 3: Product lower bound survives semidirect perturbation

```lean
theorem semidirect_pressure_lower_bound
  (G : Type*) [Finite G] [Group G]
  (F : OrbitComplexityFamily) :
  ∀ ε > 0, ∃ M, ∀ m ≥ M,
    m * pressureBase G - ε * m
      ≤ pressure (SemidirectProduct (G := Fin m → G) (F.H m))
```

This should be derived by embedding/extending generating obstructions from \(G^m\) into the semidirect product and proving that the symmetry action cannot eliminate the extensive base obstruction.

### Theorem 4: Universality for a concrete family

You must instantiate the abstract theorem in at least one major example, ideally more.

#### Wreath products
```lean
theorem wreath_family_has_bounded_orbit_complexity
  (k : ℕ) :
  HasBoundedOrbitComplexity (fun m => Equiv.Perm (Fin m)) -- or the appropriate wreath-action family
```

Then recover the existing theorem as a corollary of the abstract framework, not as a separate ad hoc argument.

#### Affine groups
For \(\mathbb{F}_q^n \rtimes \mathrm{GL}_n(\mathbb{F}_q)\), if full formalization over finite fields is too heavy, prove a finite-type surrogate theorem capturing the orbit-complexity mechanism of the linear action on coordinates/subspaces.

#### Lamplighter groups
For \((\mathbb Z/2)^n \rtimes \mathbb Z/n\), prove cyclic shift actions satisfy bounded orbit complexity and derive the first-order threshold law.

---

## Lean 4 Type Signatures to Aim For

These signatures are aspirational but should guide the formalization.

```lean
structure HasBoundedOrbitComplexity
  {ι : ℕ → Type*} (H : ∀ m, Type*) [∀ m, Group (H m)] [∀ m, MulAction (H m) (ι m)] : Prop where
  poly_orbit_bound :
    ∃ C d : ℕ, ∀ m k : ℕ,
      Fintype.card (Quotient (MulAction.orbitRel (H m) (Fin k → ι m))) ≤ C * (m+1)^d * (k+1)^d
```

```lean
def SemidirectFamily (G : Type*) [Group G] (H : ℕ → Type*) [∀ m, Group (H m)] :=
  ∀ m : ℕ, SemidirectProduct (Fin m → G) (H m)
```

```lean
theorem pressure_sublinear_action_correction
  (G : Type*) [Finite G] [Group G]
  (H : ℕ → Type*) [∀ m, Group (H m)]
  [∀ m, MulAction (H m) (Fin m)]
  (hH : HasBoundedOrbitComplexity H) :
  ∀ ε > 0, ∃ M, ∀ m ≥ M,
    |pressure ((SemidirectFamily G H) m) - m * pressureBase G| ≤ ε * m
```

```lean
theorem lamplighter_universality
  (G : Type*) [Finite G] [Group G] :
  ∀ ε > 0, ∃ M, ∀ m ≥ M,
    |pressure (SemidirectProduct (Fin m → G) (ZMod m)) - m * pressureBase G| ≤ ε * m
```

```lean
theorem wreath_universality_from_abstract
  (G K : Type*) [Finite G] [Group G] [Finite K] [Group K] :
  ∀ ε > 0, ∃ M, ∀ m ≥ M,
    |pressure (SemidirectProduct (Fin m → G) (Equiv.Perm (Fin m))) - m * pressureBase G| ≤ ε * m
```

If `SemidirectProduct` from Mathlib does not directly fit the action-on-functions model, define the action explicitly and package the resulting group. The abstraction matters more than the exact imported name.

---

## Proof Architecture: 3 Viable Strategies

You must explicitly pursue at least one of these and comment on why it is most promising.

### Strategy A: Maximal-subgroup entropy decomposition
1. Decompose failure of random generation by maximal subgroup type:
   - product-type subgroups inherited from \(G^m\),
   - diagonal/imprimitive subgroups induced by coordinate identifications,
   - action-induced exotic subgroups coming from \(H_m\).
2. Use the existing wreath pressure machinery as a template to show product-type terms contribute \(mP(G)\).
3. Prove orbit complexity bounds force the number of exotic classes to be polynomial in \(m\), hence their total pressure contribution is \(o(m)\).

Why promising: this most directly generalizes the catalog proofs and lets you reuse pressure decomposition lemmas already stabilized in the wreath files.

### Strategy B: Large deviations / entropy comparison
1. Model generation failure as a union of structured rare events on coordinates.
2. Show the base \(G^m\) contributes an extensive rate function \(mP(G)\).
3. Prove the action of \(H_m\) only changes the combinatorial multiplicity of bad events by polynomial factors under bounded orbit complexity.

Why promising: conceptually cleaner and more universal; it may expose a reusable “symmetry does not change first-order entropy” principle that could later migrate to dynamical systems, coding theory, and statistical mechanics.

### Strategy C: Orbit-equivalence compression
1. Associate to each maximal obstruction a finite coordinate pattern or tuple orbit.
2. Compress obstructions modulo \(H_m\)-orbit equivalence.
3. Show polynomially many orbit types imply subextensive obstruction complexity, yielding the same asymptotic threshold.

Why promising: this creates the clearest bridge to ergodic theory and orbit equivalence, and may be the best route for lamplighter/cyclic actions where subgroup geometry is naturally combinatorial.

**Most promising overall:** Strategy A first, Strategy C second. Strategy A is closest to the existing catalog theorems and should produce the fastest rigorous breakthrough. Strategy C is the conceptual upgrade that could later unify the whole theory with orbit-equivalence methods.

---

## Cross-Domain Connections (mandatory)

Include at least one theorem or formal discussion connecting this work to another domain.

### Bridge 1: Geometric group theory
Bounded orbit complexity is a finite analogue of low-complexity orbit equivalence relations. Prove or formulate a theorem showing that polynomial orbit growth of tuple spaces implies polynomial growth in obstruction types for generation. This reframes generation thresholds as a coarse geometric invariant of the action.

### Bridge 2: Ergodic theory / symbolic dynamics
Interpret \(G^m\) as a finite product system and \(H_m\) as a symmetry group acting on coordinate observables. The theorem says: symmetries with subexponential pattern complexity do not change first-order generation entropy. This suggests an analogue of entropy invariance under low-complexity factor rearrangements.

Possible formal theorem statement:
```lean
theorem orbit_complexity_gives_subextensive_entropy_correction
  ...
```

### Bridge 3: Operator algebras / crossed products
Semidirect products are finite shadows of crossed products. The theorem suggests that for low-complexity actions, the crossed-product symmetry modifies only lower-order counting statistics. Even a precise finite-group analogue here would be a powerful conceptual bridge.

### Bridge 4: Additive combinatorics / coding theory
The action \(H_m\) compresses coordinate patterns into orbit classes, exactly as code automorphism groups compress error patterns. Universality here hints that automorphism groups of polynomial orbit complexity do not alter first-order decoding thresholds. Even if only discussed in `FUTURE_DIRECTIONS.md`, this bridge is valuable.

---

## Concrete Instantiations to Pursue

### 1. Wreath products \(S_k \wr S_m\)
Recover the existing result from the abstract theorem. This is essential: it validates that your abstraction is the correct one.

### 2. Lamplighter family \((\mathbb Z/2)^m \rtimes \mathbb Z/m\)
This is especially attractive because cyclic actions have very explicit orbit combinatorics. You may be able to prove polynomial bounds on tuple orbits by Burnside-style counting or direct period decomposition.

### 3. Affine-linear family
For \(\mathbb F_q^n \rtimes \mathrm{GL}_n(\mathbb F_q)\), if the exact pressure framework is too ambitious, formalize at least the orbit-complexity side: prove that \( \mathrm{GL}_n(\mathbb F_q)\)-orbits of \(k\)-tuples are controlled by rank data, giving a polynomial/exponential-in-\(k\) but subextensive-in-\(n\) classification. This would be a major step toward the affine universality theorem.

---

## Conjecture with Testable Prediction (mandatory)

State a falsifiable conjecture and provide a computational test in `demo.py`.

### Conjecture
For every fixed finite group \(G\) and every family \(H_m \curvearrowright \{1,\dots,m\}\) with polynomial tuple-orbit complexity, there exists \(C_G > 0\) such that
\[
\left|P(G^m \rtimes H_m) - mP(G)\right| \le C_G \log(m+1)
\]
for all sufficiently large \(m\).

This is stronger than \(o(m)\) and is absolutely falsifiable.

### Testable prediction
For the lamplighter family and small base groups \(G\) (e.g. \(C_2, S_3, D_8\)), numerical estimates of pressure up to moderate \(m\) should fit
\[
P(G^m \rtimes \mathbb Z/m) - mP(G) = O(\log m).
\]

Your `demo.py` should:
- enumerate or estimate relevant subgroup obstructions for small \(m\),
- compute empirical pressure corrections,
- compare linear, logarithmic, and square-root fits,
- print whether data supports or weakens the conjecture.

A disproof is scientifically valuable.

---

## Expected Deep Proof Tactics

Your file must contain at least 3 theorems whose proofs materially use tools like:
- induction on tuple length / subgroup complexity,
- `rcases` decomposition of subgroup cases,
- `by_contra` to force lower bounds from obstruction survival,
- `field_simp` if rational generating probabilities or pressure expressions appear,
- multi-step `calc` chains for asymptotic inequalities.

Do not hide the substance behind automation. The proofs should reveal mechanism.

---

## Suggested Formal Development Order

1. Extract from the wreath files the minimal pressure interface actually used.
2. Define `HasBoundedOrbitComplexity` or `OrbitComplexityFamily`.
3. Prove orbit-count lemmas for cyclic and symmetric actions.
4. Define semidirect obstruction classes and prove polynomial counting bounds.
5. Establish upper/lower pressure bounds.
6. Derive the asymptotic universality theorem.
7. Recover wreath products abstractly.
8. Add lamplighter instantiation.
9. If feasible, formalize a linear-action lemma toward affine groups.

---

## Revolutionary Significance

If you succeed, the result says that first-order generation thresholds are **thermodynamic invariants of the base group**, stable under a vast class of low-complexity semidirect symmetries. That is not a refinement of wreath-product theory; it is the beginning of a new principle connecting:
- probabilistic generation,
- subgroup growth,
- permutation orbit complexity,
- entropy methods,
- and semidirect/crossed-product symmetry.

This opens immediate next-stage programs:
- classify actions by threshold universality class,
- relate orbit complexity to subgroup zeta functions,
- import entropy ideas from ergodic theory,
- test analogous principles in profinite and locally compact groups,
- and connect generation thresholds to automorphism-compressed coding models.

Application keywords:
**probabilistic generation, semidirect products, subgroup growth, orbit complexity, entropy, geometric group theory, ergodic theory, crossed products, lamplighter groups, affine groups, wreath products, universality, large deviations, coding symmetry**

---

## Mandatory Deliverables

You must produce all of the following:

### 1. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each direction must contain the exact sentences:
- “The key insight is ...”
- “Why now?”

At least one direction must bridge to a different domain, such as ergodic theory, coding theory, or operator algebras.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper explaining:
- the abstract semidirect universality theorem,
- the bounded orbit complexity concept,
- the proof architecture,
- the concrete examples,
- the conjecture and computational evidence,
- and what this opens next.

A reader with no access to the code must be able to understand the discovery.

### 3. `ARTICLE.md`
Write in Scientific American style for a broad audience. Explain the mathematics and why it matters. Do **not** focus on formal verification or theorem proving machinery. Focus on the idea that symmetry can reshuffle complexity without changing first-order generative thresholds.

### 4. Verified algorithm / computational method
Provide a verified procedure that, given finite action data for \(H_m \curvearrowright \{1,\dots,m\}\), computes or upper-bounds tuple-orbit complexity and converts it into a pressure correction estimate.

### 5. `demo.py`
Interactive demonstration that:
- tests orbit complexity on explicit families,
- estimates pressure corrections numerically,
- compares asymptotic fits,
- and probes the falsifiable \(O(\log m)\) conjecture.

Minimize sorry. Prove real theorems. Push beyond the wreath case and make universality a theorem schema, not a slogan.

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
- **Visualization scripts** — Produce up to 3 self-contained Python scripts
  that visually illustrate the core mathematical concepts discovered. Use
  matplotlib for static plots (heatmaps, curves, surfaces) or plotly for
  interactive charts. Available libraries: numpy, matplotlib, plotly.
  If using matplotlib, the script must call plt.savefig() — the system
  captures the output as a PNG. If using plotly, assign the figure to a
  variable named `fig` — the system captures fig.to_html(). Each script
  must include a comment header explaining what it visualizes and why.
  **CRITICAL: Each visualization script MUST be a single, fully self-contained
  file. Do NOT import from any local modules (algorithms.py, demo.py, etc.).
  Instead, inline all needed functions and classes directly in the script.
  The browser runtime (Pyodide) has no access to local .py files.**
- **Interactive HTML demos** — Produce up to 3 self-contained HTML snippets
  (with inline CSS/JS, no external dependencies) that demonstrate the
  mathematical concepts interactively — sliders, animations, dynamic SVG,
  or canvas drawing. Each demo must be a complete <div> fragment that
  works when inserted into a page. No <html>, <head>, or <body> tags —
  just the content div with its inline styles and scripts.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Every research cycle MUST produce a
FUTURE_DIRECTIONS.md that identifies 3-5 specific, testable scientific
hypotheses, including 1-2 grand_challenge paradigm-shifting conjectures
and 2-3 solid extensions building directly on Catalog theorems.
MUST begin with a ## Synthesis section tying all directions together.
Each direction must use the structured format with explicit fields:
**Conjecture**, **Test**, **Impact**, **Catalog References**,
**Proof Strategy**, **Domain Bridges**, **Lineage**, **Ambition**.
Reference specific Catalog theorems by file path. Every hypothesis
must be daring enough to matter and specific enough to fail.


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
    "visualizations": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files. Inline all needed functions directly.", "description": "What this visualizes" } ],
    "interactive_demos": [ { "name": "...", "html": "<div>...</div>", "description": "What this demonstrates" } ],
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

Research domain: Pythagorean
Research mode: prove
