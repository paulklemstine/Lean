## Assignment: Bifurcation analysis of periodic tropical-Life dynamics on variable tori

**Mode**: prove

Prove genuinely new structural theorems about how periodic orbits of the tropical Life map change with torus dimensions. The goal is not to enumerate examples, but to formalize a **bifurcation theory for finite tropical cellular dynamics**: sharp monotonicity, divisibility-lifting, and critical-size phenomena for periodic points.

### Core objects to define in Lean

You should first make the periodic-point locus precise.

```lean
def PeriodicVariety (m n p : ℕ) : Set (Config m n) :=
  {c | (tropicalLifeStep^[p]) c = c}

def MinimalPeriod (m n : ℕ) (c : Config m n) (p : ℕ) : Prop :=
  0 < p ∧ (tropicalLifeStep^[p]) c = c ∧
    ∀ q, 0 < q → q < p → (tropicalLifeStep^[q]) c ≠ c
```

If `Config m n` is not yet a bundled finite torus configuration type, define it in the most algebraically useful way available in your development, ideally as a function on `Fin m × Fin n` into the tropical state space.

---

## Breakthrough theorem targets

### Theorem A: Divisibility lifting of periodic points along torus coverings

This should be the first major theorem. It is conceptually clean, highly reusable, and the foundation for bifurcation analysis.

**Mathematical statement**: if one torus covers another by coordinate reduction modulo divisibility, then every periodic orbit on the smaller torus lifts to a periodic orbit of the same period on the larger torus via pullback. Consequently, the set of realized periods is monotone under divisibility of torus sizes.

A strong formal target is:

```lean
def pullbackConfig
    {m n M N : ℕ}
    (hm : m ∣ M) (hn : n ∣ N) :
    Config m n → Config M N :=
  sorry

theorem tropicalLifeStep_pullback
    {m n M N : ℕ}
    (hm : m ∣ M) (hn : n ∣ N)
    (c : Config m n) :
    tropicalLifeStep (pullbackConfig hm hn c) =
      pullbackConfig hm hn (tropicalLifeStep c) := by
  sorry

theorem periodic_lifts_along_cover
    {m n M N p : ℕ}
    (hm : m ∣ M) (hn : n ∣ N) :
    Set.MapsTo (pullbackConfig hm hn) (PeriodicVariety m n p) (PeriodicVariety M N p) := by
  sorry
```

A sharper existential corollary:

```lean
theorem exists_periodic_of_exists_periodic_of_dvd
    {m n M N p : ℕ}
    (hm : m ∣ M) (hn : n ∣ N)
    (h : (PeriodicVariety m n p).Nonempty) :
    (PeriodicVariety M N p).Nonempty := by
  sorry
```

**Why this is a breakthrough**: this turns periodic orbit existence into an **arithmetic geometry of torus sizes**. The parameter space `(m,n)` becomes partially ordered by divisibility, and periodic dynamics acquires a functorial structure. This is the finite tropical analogue of lifting periodic points along covering maps in topological dynamics.

---

### Theorem B: Period collapse and minimal-period divisibility under iteration

You need a theorem relating exact period and fixed points of iterates. This gives the algebra of bifurcations.

```lean
theorem minimalPeriod_dvd_of_iterate_fix
    {m n : ℕ} {c : Config m n} {p q : ℕ}
    (hp : MinimalPeriod m n c p)
    (hq : 0 < q)
    (hfix : (tropicalLifeStep^[q]) c = c) :
    p ∣ q := by
  sorry
```

and then:

```lean
theorem fixed_of_multiple_period
    {m n p k : ℕ} {c : Config m n}
    (hp : (tropicalLifeStep^[p]) c = c) :
    (tropicalLifeStep^[p * k]) c = c := by
  sorry
```

This theorem is mathematically elementary in dynamical systems, but in Lean it becomes a critical organizing lemma: all later bifurcation theorems should reduce to divisibility arguments on periods.

**Why this matters**: once formalized, this lets you stratify `PeriodicVariety m n p` by exact period and define “birth” versus “aliasing” of orbits when sizes vary. Without this theorem, the geometry of periodic loci remains blurry.

---

### Theorem C: Birth sizes and critical-size bifurcation set

Define the first torus sizes at which a period appears. This is the real conceptual leap.

For square tori, define:

```lean
def PeriodAppearsAt (p L : ℕ) : Prop :=
  (PeriodicVariety L L p).Nonempty

def CriticalSize (p L : ℕ) : Prop :=
  PeriodAppearsAt p L ∧
  ∀ K, 0 < K → K < L → ¬ PeriodAppearsAt p K
```

Then prove a nontrivial structural theorem such as:

```lean
theorem upward_closed_period_appearance
    {p L M : ℕ}
    (hLM : L ∣ M)
    (h : PeriodAppearsAt p L) :
    PeriodAppearsAt p M := by
  sorry
```

and, if possible, the existence of a minimal appearance size under a nonemptiness assumption:

```lean
theorem exists_criticalSize_of_exists_periodic
    {p : ℕ}
    (h : ∃ L > 0, PeriodAppearsAt p L) :
    ∃ L, CriticalSize p L := by
  sorry
```

This is a finite well-ordering argument, but it upgrades the subject from “periodic points exist” to a **bifurcation invariant**: the first scale at which a period can be born.

**Why this is revolutionary**: it introduces a rigorous analogue of a bifurcation diagram where the parameter is not a real scalar but **arithmetic torus size**. This is an entirely different species of bifurcation theory, closer to arithmetic dynamics and symbolic dynamics than to smooth ODEs.

---

## Stronger geometry target, if the map is tropical-linear / piecewise tropical-linear

If your `tropicalLifeStep` is defined via min-plus/max-plus local rules, try to prove that `PeriodicVariety m n p` is cut out by finitely many tropical equalities or piecewise-linear constraints. Even a weak theorem would be important:

```lean
theorem periodicVariety_finite
    (m n p : ℕ) :
    Set.Finite (PeriodicVariety m n p) := by
  sorry
```

This should hold immediately if `Config m n` is finite. But do not stop there: reinterpret finiteness as the discrete shadow of a tropical variety, and isolate the exact combinatorial complexity of periodic loci.

If state values range over a finite type:
```lean
theorem periodicVariety_card_le
    (m n p : ℕ) :
    Nat.card (PeriodicVariety m n p) ≤ Nat.card (Config m n) := by
  sorry
```

Then seek period-counting functions:
```lean
def periodSpectrum (L : ℕ) : Set ℕ := {p | (PeriodicVariety L L p).Nonempty}
```
and prove monotonicity under divisibility:
```lean
theorem periodSpectrum_mono
    {L M : ℕ}
    (h : L ∣ M) :
    periodSpectrum L ⊆ periodSpectrum M := by
  sorry
```

---

## Lean 4 formalization guidance

A likely workable signature pattern is:

```lean
def Config (m n : ℕ) := Fin m → Fin n → State
```

or curried product form. Then define the torus-cover pullback using modular reduction induced by divisibility witnesses. The key technical point is to construct maps
`Fin M → Fin m` and `Fin N → Fin n`
from `m ∣ M`, `n ∣ N`, probably via `%` and proof that the result lies in bounds.

If neighborhood rules are translation-invariant modulo torus coordinates, then `tropicalLifeStep_pullback` should follow from a coordinatewise computation. This is the theorem to architect carefully: once you have commutation with pullback, all periodic lifting statements become one-line iterate arguments.

---

## Proof strategy architecture

### Strategy 1: Covering-map functoriality via coordinate reduction
1. Define `pullbackConfig hm hn` by composing a small-torus configuration with the reduction maps `Fin M → Fin m`, `Fin N → Fin n`.
2. Prove the local update rule commutes with reduction, using translation-invariance of the tropical Life neighborhood stencil.
3. Upgrade from one-step commutation to iterate commutation, then derive periodic-point lifting and period-spectrum monotonicity.

**Why this is most promising**: it extracts the entire bifurcation theory from one structural symmetry theorem. It is categorical and scalable.

---

### Strategy 2: Orbit-theoretic proof using equivariance under torus translations
1. Formalize the torus translation action on `Config m n`.
2. Prove `tropicalLifeStep` is equivariant under this action.
3. Realize lifted configurations as those constant on fibers of the covering map, then show this invariant subspace is preserved by dynamics and conjugate to the smaller torus system.

**Why this is deeper**: it reveals the correct dynamical mechanism—periodic orbit lifting occurs because the larger torus contains a translation-invariant factor isomorphic to the smaller one. This is closer to symbolic dynamics and topological factors.

---

### Strategy 3: Exact-period stratification by iterate algebra
1. First prove general lemmas about iterates of any function on a finite type: minimal period divides every return time.
2. Specialize to `tropicalLifeStep`.
3. Use finite-well-ordering on sizes to define and prove existence of critical birth sizes.

**Why this is useful**: even if the covering-map theorem becomes technically messy, this strategy still gives a meaningful bifurcation framework through exact periods and minimality.

---

## Cross-domain connections you should exploit explicitly

- **Arithmetic dynamics**: torus size acts like an arithmetic parameter; divisibility-lifting parallels reduction and lifting phenomena in periodic point theory over finite fields.
- **Symbolic dynamics**: the covering/lifting theorem is a finite analogue of factor maps and subshifts of finite type; exact period stratification resembles Artin–Mazur zeta bookkeeping.
- **Tropical geometry**: `PeriodicVariety m n p` should be treated as a tropical fixed-point locus, even if currently discrete. This opens the door to tropical moduli of periodic configurations.
- **Combinatorics on finite groups**: `Fin m × Fin n` is a finite abelian group; periodic orbit birth is governed by subgroup/factor structure.
- **Hyperbolic dynamics / horseshoe analogy**: if period spectra become rich and upward-closed in arithmetic directions, you are seeing a combinatorial shadow of entropy generation.
- **Computation theory**: if dual-rail Turing completeness is later established, then bifurcation in torus size becomes a complexity-theoretic phase transition in available computation space.

---

## How to build on catalog theorems

The injected catalog is thin and partially placeholder, so do not force artificial dependence. But do use the verified logic-gate direction as conceptual fuel:

- `xor_key_bijective` suggests formal comfort with bijections and reversible encodings; use this mindset when defining torus-cover pullbacks and invariant subspaces.
- `tropical_add_not_cancellative` is a reminder that tropical algebra behaves nonclassically; do not over-import linear intuitions. Prefer equivariance and order-theoretic arguments over cancellation.
- The oracle/gate theorems suggest the automaton already supports nontrivial local computation. This makes period-birth theorems more significant: changing torus size may literally change computational universality classes.

If possible, create a reusable lemma library for iterates:
```lean
theorem Function.iterate_fix_of_fix {α} (f : α → α) {x} (h : f x = x) (n : ℕ) :
    (f^[n]) x = x := by ...
```
and its period-divisibility companions.

---

## What would count as a field-opening result here

Do not settle for “there exists a periodic point on some torus.” The field-opening result is:

> **Periodic orbit appearance is organized by arithmetic covering structure, exact periods admit a divisibility calculus, and each realizable period has a critical birth size.**

That package would create the first rigorous bifurcation framework for tropical Life on finite tori. It would enable:
- period-spectrum classification,
- entropy-growth conjectures,
- arithmetic bifurcation diagrams,
- factor-map and universality analysis,
- eventually a tropical dynamical zeta function.

---

## Deliverables

1. Formal definitions:
   - `PeriodicVariety`
   - `MinimalPeriod`
   - `PeriodAppearsAt`
   - `CriticalSize`
   - `periodSpectrum`
   - `pullbackConfig`

2. At least **one major theorem** fully proved with minimal sorry:
   - preferably `tropicalLifeStep_pullback` + `periodic_lifts_along_cover`,
   - or failing that, `minimalPeriod_dvd_of_iterate_fix` + `exists_criticalSize_of_exists_periodic`.

3. Supporting lemmas about iterates, exact periods, and monotonicity.

4. A structured `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - define a tropical Artin–Mazur zeta function for `periodSpectrum`,
   - classify eventually periodic factor subshifts arising from torus coverings,
   - prove entropy lower bounds from period growth,
   - connect dual-rail computational universality to unbounded period spectra,
   - tropicalize Smale-style horseshoe mechanisms via finite factor embeddings.

## Application keywords
tropical dynamics, bifurcation theory, periodic orbits, finite torus, arithmetic dynamics, symbolic dynamics, exact period, covering maps, tropical geometry, cellular automata, entropy, dynamical zeta functions, computational universality

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

Research domain: Tropical
Research mode: prove
