## Assignment: Direction 1: Kan Composition and Groupoid Structure

**Mode:** `prove`

Build a genuine higher-path composition calculus on top of the cubical core, not merely a path carrier. The target is to turn the existing interval/path primitives into the first formally verified approximation of an internal fundamental groupoid with explicit 2-path witnesses for the coherence laws.

You should work directly from the catalog foundations in:

- `Logic/CubicalCore.lean`
  - especially `PathOver`, `reflPath`, `cubical_funext`
- any existing interval/affine interpolation lemmas nearby, especially anything analogous to `affine_path_interpolates`

The goal is not to restate standard homotopy folklore, but to **certify a compositional higher-structure** in Lean 4 with enough concrete computational content that it can drive experiments and future formal higher category theory.

---

## Core Vision

For a cubical interval with connections (min/max structure), define path concatenation and path reversal, then prove that the path space carries **groupoid laws up to higher paths**, i.e. not by judgmental equality but by explicit 2-paths. This is the mathematically correct and conceptually revolutionary target: strict associativity is false for ordinary path concatenation, but associativity up to coherent reparametrization is the beginning of ∞-groupoid structure.

This opens a bridge between:

- **Topology:** fundamental groupoids and homotopies
- **Category theory:** weak composition and coherence
- **Type theory / HoTT:** identity types as path objects
- **Physics:** path composition as sequential evolution / parallel transport along worldlines
- **Computer verification:** executable homotopy witnesses and numerical tests of reparametrization laws

If completed cleanly, this becomes a seed crystal for formal Kan composition, internal higher categories, and eventually machine-checked synthetic homotopy theory in Lean.

---

## Precise Theorem Targets

You should introduce at least one genuinely new structure, for example a structure encoding composable endpoint-fixed paths together with 2-path equivalence under endpoint-preserving reparametrization.

A plausible new definition:

```lean
structure EndpointFixedHomotopy
    {X : Type u} [TopologicalSpace X]
    {x y : X} (p q : Path x y) where
  hom : C(I × I, X)
  source : ∀ t : I, hom (t, 0) = p t
  target : ∀ t : I, hom (t, 1) = q t
  left   : ∀ s : I, hom (0, s) = x
  right  : ∀ s : I, hom (1, s) = y
```

or, if `Path` is represented cubically in the catalog, adapt this to the actual `PathOver`/interval API. If continuity infrastructure is difficult, define a cubical analogue first and then derive the topological version.

### Theorem 1: Path composition exists and preserves endpoints

For composable paths `p : Path x y` and `q : Path y z`, define concatenation by piecewise-linear rescaling.

**Mathematical statement:**
For every type/space `X` and points `x y z : X`, there exists a path
\[
\mathsf{comp}(p,q) : \mathrm{Path}(x,z)
\]
given by
\[
(\mathsf{comp}(p,q))(t)=
\begin{cases}
p(2t) & t \le 1/2,\\
q(2t-1) & t \ge 1/2.
\end{cases}
\]

**Lean 4 target signature** (adapt to actual interval API):
```lean
def Path.comp {X : Type u} [TopologicalSpace X]
    {x y z : X} (p : Path x y) (q : Path y z) : Path x z
```

**Key theorem:**
```lean
theorem Path.comp_apply_left
    {X : Type u} [TopologicalSpace X]
    {x y z : X} (p : Path x y) (q : Path y z) :
    ∀ t, (t : ℝ) ≤ (1/2 : ℝ) →
      Path.comp p q t = p ⟨2 * t, by sorry⟩
```
and similarly a right-half formula, plus endpoint lemmas:
```lean
theorem Path.comp_source
    {X : Type u} [TopologicalSpace X]
    {x y z : X} (p : Path x y) (q : Path y z) :
    Path.comp p q 0 = x

theorem Path.comp_target
    {X : Type u} [TopologicalSpace X]
    {x y z : X} (p : Path x y) (q : Path y z) :
    Path.comp p q 1 = z
```

This theorem matters because it upgrades “paths exist” to “paths compose,” the first nontrivial categorical operation.

---

### Theorem 2: Left and right unit laws hold up to explicit 2-paths

Strictly, `refl ≫ p = p` is false for standard concatenation; the correct theorem is existence of an endpoint-fixed homotopy induced by a linear reparametrization.

**Mathematical statement:**
For every path `p : Path x y`, there are endpoint-fixed homotopies
\[
\mathrm{refl}_x \cdot p \simeq p,
\qquad
p \cdot \mathrm{refl}_y \simeq p.
\]

**Lean 4 target signatures:**
```lean
theorem Path.comp_refl_left_homotopic
    {X : Type u} [TopologicalSpace X]
    {x y : X} (p : Path x y) :
    EndpointFixedHomotopy (Path.comp (Path.refl x) p) p

theorem Path.comp_refl_right_homotopic
    {X : Type u} [TopologicalSpace X]
    {x y : X} (p : Path x y) :
    EndpointFixedHomotopy (Path.comp p (Path.refl y)) p
```

A more cubical theorem, closer to the catalog, would be even better:
```lean
theorem comp_refl_left_PathOver
    ... :
    PathOver (fun i => Path x y) (Path.comp (reflPath x) p) p
```

These theorems are the first coherence laws: the path space is not a strict category, but a weak one.

---

### Theorem 3: Associativity holds up to a 2-path

This is the breakthrough theorem. For paths `p : Path w x`, `q : Path x y`, `r : Path y z`, prove:
\[
((p \cdot q)\cdot r) \simeq (p \cdot (q \cdot r))
\]
by an explicit endpoint-fixed homotopy coming from a piecewise-linear reparametrization of the interval.

**Lean 4 target signature:**
```lean
theorem Path.comp_assoc_homotopic
    {X : Type u} [TopologicalSpace X]
    {w x y z : X}
    (p : Path w x) (q : Path x y) (r : Path y z) :
    EndpointFixedHomotopy
      (Path.comp (Path.comp p q) r)
      (Path.comp p (Path.comp q r))
```

This should not be a shallow proof. The proof should explicitly analyze the three interval subregions and construct a 2-parameter map realizing the reassociation.

This theorem is the gateway from path algebra to weak higher algebra.

---

### Theorem 4: Inverses exist up to homotopy

Define path reversal:
```lean
def Path.symm {X : Type u} [TopologicalSpace X]
    {x y : X} (p : Path x y) : Path y x
```
and prove:
```lean
theorem Path.comp_symm_left_homotopic
    {X : Type u} [TopologicalSpace X]
    {x y : X} (p : Path x y) :
    EndpointFixedHomotopy (Path.comp (Path.symm p) p) (Path.refl y)

theorem Path.comp_symm_right_homotopic
    {X : Type u} [TopologicalSpace X]
    {x y : X} (p : Path x y) :
    EndpointFixedHomotopy (Path.comp p (Path.symm p)) (Path.refl x)
```

These are the actual groupoid inverse laws. They connect directly to the fundamental groupoid and to gauge-theoretic “go out and return” path cancellation.

---

### Theorem 5: Cross-domain theorem — transport is functorial up to higher path

You must include at least one theorem bridging to a different domain. The strongest option is to connect path composition to **parallel transport / dependent transport**.

If the cubical core has transport or `PathOver`-based dependent action, prove a theorem of the form:

```lean
theorem PathOver.transport_comp_homotopic
    {X : Type u} {A : X → Type v}
    {x y z : X} (p : Path x y) (q : Path y z) :
    EndpointFixedHomotopy
      (transport A (Path.comp p q))
      ((transport A q) ∘ (transport A p))
```

If full transport is too heavy, use a function-action theorem:
```lean
theorem map_comp_preserves_concat
    {X Y : Type u} [TopologicalSpace X] [TopologicalSpace Y]
    {x y z : X} (f : C(X, Y))
    (p : Path x y) (q : Path y z) :
    EndpointFixedHomotopy
      (Path.map f (Path.comp p q))
      (Path.comp (Path.map f p) (Path.map f q))
```

This is the cross-domain hinge:
- topology ↔ category theory via functoriality,
- topology ↔ physics via transport along concatenated trajectories,
- topology ↔ dependent type theory via transport composition.

---

## Proof Strategy Architecture

You must present and pursue at least 2–3 proof routes, with a clear judgment about which is most promising.

### Strategy A: Direct piecewise interval analysis
1. Define `Path.comp` using `Set.piecewise` or explicit `if h : (t : ℝ) ≤ 1/2 then ... else ...`.
2. Prove endpoint and continuity obligations by interval case splits, using `rcases` on the subtype point of `I`, and `field_simp`/linear arithmetic to verify rescaled parameters remain in `[0,1]`.
3. Construct the unit and associativity 2-paths by explicit formulas on `I × I`, then prove boundary conditions by multi-step `calc` chains.

**Why promising:** This is closest to the computational test and gives executable formulas for `demo.py`. It also forces concrete proof artifacts rather than abstract existence.

### Strategy B: Cubical reparametrization calculus
1. Build a small API of endpoint-preserving affine self-maps of the interval.
2. Show that reparametrization of a path by such maps yields endpoint-fixed homotopic paths.
3. Express `refl ⋅ p`, `p ⋅ refl`, and both associativity bracketings as reparametrizations of a common canonical 3-segment path; derive the laws by functoriality of reparametrization.

**Why promising:** This is probably the most elegant and scalable route. Once the reparametrization API exists, many coherence laws become reusable lemmas instead of ad hoc case splits.

### Strategy C: PathOver / dependent coherence route
1. Formalize concatenation first in cubical terms using `PathOver`.
2. Use `cubical_funext` to reduce higher-path equalities to pointwise path equalities.
3. Build coherence proofs as higher-dimensional cubes rather than topological homotopies.

**Why promising:** Best aligned with future internal ∞-groupoid work.  
**Why risky:** More abstract and dependent on how expressive the catalog’s cubical core already is.

### Recommended route
Start with **Strategy A** to get the concrete theorem and executable algorithm, then refactor toward **Strategy B** for conceptual compression. Use **Strategy C** only where the catalog already supports it naturally.

---

## Required Deep Proof Features

Your Lean file must contain **at least 3 substantial theorems** whose proofs genuinely use nontrivial tactics and structure, e.g.

- `induction` over interval partitions / path constructors if available
- `rcases` on subtype interval elements and case disjunctions
- `by_contra` to discharge impossible interval inequalities
- `field_simp` for affine reparametrization identities
- multi-step `calc` blocks for endpoint and coherence equalities

Avoid toy statements whose proof is just simplification. The theorem should remain mathematically meaningful even if the proof is hard.

---

## New Definitions You Should Introduce

At least one novel structure is mandatory. Strong candidates:

1. `EndpointFixedHomotopy p q`
   - endpoint-preserving 2-path between paths

2. `PathReparam`
   - endpoint-preserving interval self-map with monotonicity/continuity
```lean
structure PathReparam where
  toFun : I → I
  continuous_toFun : Continuous toFun
  map_zero : toFun 0 = 0
  map_one : toFun 1 = 1
  monotone' : Monotone toFun
```

3. `WeakPathGroupoid X`
   - objects = points of `X`
   - morphisms = paths
   - equality of morphisms = endpoint-fixed homotopy

Even if you do not complete full quotienting, defining the pre-groupoid structure is already a major conceptual step.

---

## Computational/Algorithmic Deliverable

You must not stop at theorem statements. Produce a verified computational method for sampling and checking the coherence laws on concrete paths in `ℝ`.

### Algorithm target
Implement a path sampler for piecewise-linear paths `p : [0,1] → ℝ`, define:
- concatenation,
- reversal,
- unit path,
- numerical witness of reparametrization homotopy.

Then computationally test:
1. endpoint preservation,
2. left/right unit up to sampled reparametrization,
3. associativity up to sampled reparametrization,
4. inverse cancellation up to sampled homotopy.

This algorithm should be mirrored conceptually by the formal definitions.

### `demo.py`
Run 100 random piecewise-linear paths with 1000 sample points each, and report:
- max endpoint error,
- max associativity discrepancy under the proposed homotopy,
- histograms/plots for representative examples.

The demo should be interactive if possible: allow users to choose 2 or 3 paths and visualize both bracketings plus the homotopy interpolation.

---

## Testable Scientific Hypotheses for FUTURE_DIRECTIONS.md

You must include **3–5 falsifiable hypotheses**. At least one should be computationally testable immediately. Examples:

1. **Hypothesis: canonical reparametrization suffices.**  
   Every unit/associativity witness for piecewise-linear concatenation on `ℝ^n` can be represented by a piecewise-affine endpoint-fixed homotopy with at most 4 breakpoints in the time variable.  
   **Test:** brute-force search over breakpoint templates for random path triples.

2. **Hypothesis: cubical connections reduce coherence complexity.**  
   In the presence of min/max connections on the interval, the number of separate boundary lemmas needed for associativity can be reduced by at least 50% compared to raw piecewise proofs.  
   **Test:** compare theorem dependency graphs and lemma counts in two formalizations.

3. **Hypothesis: transport coherence numerically predicts formal simplicity.**  
   Spaces/families where transport along concatenation is numerically close to strict composition admit shorter formal proofs of `transport_comp_homotopic`.  
   **Test:** compare proof term sizes across examples.

4. **Hypothesis: weak path groupoid quotients recover classical invariants.**  
   Quotienting paths by endpoint-fixed homotopy in simple spaces (`S¹`, graphs, punctured plane) reproduces known fundamental groupoid data.  
   **Test:** computationally classify sampled loops and compare to expected algebraic invariants.

5. **Hypothesis: piecewise-linear coherence scales to higher cubes.**  
   The same affine reparametrization technology extends from 2-path associators to 3-path pentagon witnesses.  
   **Test:** attempt automated construction of sampled pentagon fillers.

---

## Cross-Domain Connections You Must Explicitly Exploit

Do not merely mention them; build one theorem or algorithm around at least one of these.

### 1. Category Theory
Path composition up to 2-path is the prototype of weak composition. Your associator theorem is a low-dimensional shadow of bicategorical coherence.

### 2. Physics
Interpret `Path.comp p q` as sequential motion and `Path.symm p` as time reversal. The inverse laws model cancellation of a trajectory followed by its reverse, analogous to trivial holonomy along backtracking paths.

### 3. Dependent Type Theory
`PathOver` and transport along paths are the internal language of fibrations. A transport-composition theorem would be a decisive bridge from cubical path objects to semantics of dependent types.

### 4. Topological Data Analysis / Robotics
Path concatenation and homotopy witnesses are directly relevant to motion planning: two route-plans compose weakly, and reassociation matters for modular planners. This gives a computationally meaningful audience for the theorem.

---

## Application Keywords

Use these explicitly in the paper and metadata:

- higher groupoid
- cubical type theory
- Kan composition
- path concatenation
- endpoint-fixed homotopy
- weak associativity
- reparametrization invariance
- PathOver
- transport coherence
- parallel transport
- motion planning
- homotopy verification
- formal topology
- Lean 4
- Mathlib

---

## Deliverables You Must Produce

You must produce **all** of the following:

1. **Lean development**
   - at least 3 deep theorems
   - at least 1 novel definition
   - minimal `sorry`
   - explicit use of catalog foundations

2. **`FUTURE_DIRECTIONS.md`**
   - 3–5 falsifiable scientific hypotheses
   - each with a concrete computational or formal test

3. **`RESEARCH_PAPER.md`**
   - standalone scientific document
   - explains definitions, main theorems, proof ideas, significance, and next steps
   - readable without the codebase

4. **`ARTICLE.md`**
   - Scientific American style
   - explain why “paths form a groupoid only up to higher paths” is a profound idea
   - connect to topology, logic, and physics

5. **Verified algorithm / computational method**
   - numerical checker for endpoint/unit/associativity/inverse coherence
   - conceptually aligned with formal definitions

6. **`demo.py`**
   - interactive demonstration of path concatenation and homotopies
   - random test generation for 100 paths, 1000 sample points
   - visualization of associativity reparametrization

---

## Standard of Success

Success is not “we defined concatenation.” Success is:

- a concrete formal path composition operation,
- explicit 2-path witnesses for unit and associativity,
- at least one inverse law,
- at least one bridge theorem to transport/functoriality/physics,
- executable experiments validating the geometry,
- and a research narrative showing this is the first step toward internal verified ∞-groupoids.

Push toward a result that a homotopy theorist, type theorist, and formal methods researcher would all recognize as the beginning of a new formal bridge.

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
