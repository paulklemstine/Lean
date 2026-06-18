## Assignment: Direction 1: Sharp Valuation-Sensitive Stability Bound

Prove a genuinely new arithmetic-topological stability theorem: **p-adic divisibility in interleaving maps should force a strictly sharper primewise persistence shift bound than ordinary δ-stability**. The ambition is not a cosmetic refinement of an existing constant; it is to expose a new mechanism by which valuation theory governs topological noise sensitivity.

This is a call to formalize the first rigorous bridge between **persistent homology stability** and **p-adic/arithmetic control data**. If true, this opens an arithmetic version of TDA in which primes are not passive bookkeeping devices but active geometric regulators of stability.

---

## Core Vision

The catalog already contains primewise torsion stability estimates such as:

- `Pythagorean/PrimewiseTorsionStability.lean`
  - `primeShiftBound_improved`
  - `primeShiftBound_improved_strict`

Your task is to go beyond “primewise tracking exists” and prove that **extra p-divisibility in the interleaving morphisms improves the stability modulus quantitatively**.

The conceptual leap is:

> ordinary interleaving theory measures how far filtrations are shifted in parameter space;
> valuation-sensitive interleaving should measure how much arithmetic damping occurs during transport,
> and this damping should reduce the effective primewise birth shift.

This is the arithmetic analogue of a renormalization phenomenon: divisibility by \(p^\nu\) suppresses instability at the prime \(p\).

---

## New Definitions to Introduce

You must define at least one genuinely new concept not already present in the catalog. The central candidate is:

### 1. `PadicControlledInterleaving`
A structure encoding that the forward/backward interleaving maps factor through multiplication by \(p^\nu\).

Informally, for filtrations \(F,G\), prime \(p\), integer \(\nu\), and defect \(\delta\), a p-controlled interleaving consists of maps
\[
\phi_t : F_t \to G_{t+\delta}, \qquad \psi_t : G_t \to F_{t+\delta}
\]
such that, on the relevant torsion layers or chain modules, each map factors as
\[
\phi_t = p^\nu \cdot \widetilde{\phi}_t, \qquad \psi_t = p^\nu \cdot \widetilde{\psi}_t.
\]

### 2. `valuationSensitiveShift`
A new numerical invariant extracting the best primewise stability modulus permitted by a p-controlled interleaving.

### 3. Optional stronger notion: `StrictPadicControlledInterleaving`
Require the factor maps \(\widetilde{\phi}_t,\widetilde{\psi}_t\) to satisfy injectivity or torsion-faithfulness conditions. This is likely necessary for the sharpest theorem.

These definitions should not be ad hoc wrappers: they should isolate a reusable concept likely to seed a new subfield, e.g. **arithmetic persistence stability**.

---

## Precise Theorem Targets

You need at least 3 substantial theorems. Here is the recommended theorem package.

### Theorem 1: Divisibility lowers the effective primewise shift
Let \(p\) be prime, \(\nu \in \mathbb{N}\), and let \(F,G\) be filtrations equipped with a p-controlled \(\delta\)-interleaving. Assume the factor maps preserve the relevant torsion birth structure and satisfy the same hypotheses needed in the catalog’s improved primewise shift theorem. Then the primewise stability modulus is bounded by the valuation-reduced defect:
\[
\varepsilon_p(F,G) \le \frac{\delta}{p^\nu}.
\]

This is the flagship theorem.

### Suggested Lean 4 theorem signature
Use a signature of the following shape, adapted to the actual catalog types:

```lean
theorem primeShiftBound_valuation_sensitive
  {p ν δ : ℕ}
  (hp : Nat.Prime p)
  {F G : FiltrationType}
  (hctrl : PadicControlledInterleaving p ν δ F G)
  (hinj : hctrl.FactorMapsInjective)
  :
  valuationSensitiveShift p F G ≤ δ / p ^ ν
```

If the catalog uses `ℝ`, `ℚ`, or `ENNReal` for shifts, replace the codomain accordingly, e.g.

```lean
theorem primeShiftBound_valuation_sensitive
  {p ν : ℕ} {δ : ℚ}
  (hp : Nat.Prime p)
  {F G : FiltrationType}
  (hctrl : PadicControlledInterleaving p ν δ F G)
  (hinj : hctrl.FactorMapsInjective)
  :
  primewiseShift p F G ≤ δ / (p ^ ν : ℚ)
```

If `δ` is not naturally an integer, define \(\nu = v_p(\delta)\) only when `δ` lies in a discrete arithmetic parameter space, or instead formulate the theorem with an explicit divisibility parameter `ν` attached to the maps rather than extracted from `δ`.

---

### Theorem 2: Strict improvement over the catalog bound
Show that valuation-sensitive control strictly improves the existing primewise bound whenever \(\nu > 0\) and \(\delta > 0\):
\[
\frac{\delta}{p^\nu} < \delta.
\]
Then deduce:
\[
\varepsilon_p(F,G) < \delta.
\]

This theorem matters because it certifies that the new theory is not merely a rephrasing of the old one: it yields a **provably sharper constant**.

### Suggested Lean 4 theorem signature

```lean
theorem primeShiftBound_valuation_sensitive_strict
  {p ν δ : ℕ}
  (hp : Nat.Prime p)
  (hν : 0 < ν)
  (hδ : 0 < δ)
  {F G : FiltrationType}
  (hctrl : PadicControlledInterleaving p ν δ F G)
  (hinj : hctrl.FactorMapsInjective)
  :
  valuationSensitiveShift p F G < δ
```

If your shift values live in `ℚ` or `ℝ`, use the corresponding inequalities and cast powers appropriately.

---

### Theorem 3: Monotonicity in valuation depth
If one has two control levels \(\nu_1 \le \nu_2\), then the valuation-sensitive bound improves monotonically:
\[
\frac{\delta}{p^{\nu_2}} \le \frac{\delta}{p^{\nu_1}}.
\]
Hence deeper p-divisibility implies at least as strong a stability estimate.

This theorem is mathematically essential because it turns the conjecture into a **hierarchy**: valuation depth becomes an ordered stability resource.

### Suggested Lean 4 theorem signature

```lean
theorem valuation_sensitive_bound_mono
  {p ν₁ ν₂ δ : ℕ}
  (hp : Nat.Prime p)
  (hν : ν₁ ≤ ν₂)
  :
  δ / p ^ ν₂ ≤ δ / p ^ ν₁
```

Or in a more structural form:

```lean
theorem valuationSensitiveShift_antitone_in_nu
  {p : ℕ} (hp : Nat.Prime p)
  {ν₁ ν₂ : ℕ} {δ : ℚ}
  (hν : ν₁ ≤ ν₂)
  {F G : FiltrationType}
  (h₁ : PadicControlledInterleaving p ν₁ δ F G)
  (h₂ : PadicControlledInterleaving p ν₂ δ F G)
  :
  δ / (p ^ ν₂ : ℚ) ≤ δ / (p ^ ν₁ : ℚ)
```

---

## Stronger Cross-Domain Theorem

You are required to include at least one theorem connecting to a different domain. Do not make this superficial. Here is the right bridge:

### Theorem 4: Valuation filtration induces an arithmetic energy dissipation inequality
Interpret \(p^\nu\)-divisibility as an arithmetic damping coefficient. Prove that if the interleaving maps factor through multiplication by \(p^\nu\), then an associated “torsion energy” or “birth defect mass” is nonincreasing under transport, with decay controlled by \(p^{-\nu}\).

For example, define a simple arithmetic energy functional on finite \(p\)-primary modules, such as the cardinality of the \(p\)-torsion birth set or a weighted valuation sum, and prove a contraction estimate:
\[
E_p(\phi(x)) \le p^{-\nu} E_p(x)
\]
or a discrete version suitable for the actual objects in the catalog.

This links:
- **TDA** with
- **p-adic analysis / arithmetic geometry**, and even
- **statistical physics / dissipation theory** via energy decay.

### Possible Lean 4 theorem signature

```lean
theorem torsionEnergy_contracts_under_padic_control
  {p ν : ℕ}
  (hp : Nat.Prime p)
  {M N : Type*} [AddCommMonoid M] [AddCommMonoid N]
  (E : N → ℚ)
  (f : M → N)
  (hf : FactorsThroughSMul p ν f)
  :
  ∀ x, E (f x) ≤ (1 / (p ^ ν : ℚ)) * E_reference x
```

You may need to create the correct algebraic hypotheses. The point is not this exact shape; the point is to prove a genuine bridge theorem, not just mention another field in prose.

---

## Recommended Formal Conjecture

State a falsifiable conjecture with explicit computational content.

### Conjecture
For filtrations over \(\mathbb{Z}/p^k\mathbb{Z}\) with p-controlled \(\delta\)-interleaving of depth \(\nu\), the optimal primewise shift equals the valuation-reduced defect:
\[
\varepsilon_p(F,G) = \frac{\delta}{p^\nu}
\]
whenever the factor maps are torsion-faithful and the persistence modules are indecomposable over the \(p\)-primary block.

This is stronger than the flagship theorem and could fail. Good: that makes it scientifically useful.

### Computational test
Construct explicit chain-level filtrations over \(\mathbb{Z}/p^k\mathbb{Z}\) for:
- \(k = 1,2,3\),
- \(p = 2,3,5\),
- \(\nu = 0,1,\dots,k\),

with interleaving matrices whose entries are divisible by \(p^\nu\). Compute:
1. the actual primewise shift,
2. the predicted bound \(\delta/p^\nu\),
3. whether equality holds.

A single counterexample falsifies the sharp-equality conjecture while leaving the inequality theorem intact.

---

## Proof Architecture: 3 Strategy Paths

You asked for 2–3 proof strategy steps; here are three serious paths. Pursue at least two in parallel until one closes.

### Strategy A: Factorization transport of the catalog proof
This is the most promising route.

1. **Locate the exact place** in `primeShiftBound_improved` / `primeShiftBound_improved_strict` where the shift constant \(\delta\) is introduced.
2. **Refactor the argument** so that every use of the interleaving map is replaced by a factorization through multiplication by \(p^\nu\).
3. **Extract the gain** by proving a lemma of the form: if a birth class is transported through a map divisible by \(p^\nu\), then its obstruction appears only after a reduced effective shift.

Why most promising:
- It leverages existing catalog infrastructure.
- It makes the new theorem a conceptual strengthening, not a disconnected artifact.
- It should produce the strongest compatibility with prior theorems.

Key sublemma:
```lean
theorem birthShift_of_factor_through_p_pow
  {p ν : ℕ} (hp : Nat.Prime p)
  {x y : ModuleType}
  (hfact : y = (p ^ ν) • x)
  (hinj : SomeInjectivityCondition)
  :
  birthShiftContribution p y ≤ birthShiftContribution p x / p ^ ν
```

Expect multi-step `calc`, `rcases`, and contradiction arguments here.

---

### Strategy B: Valuation filtration on morphisms
Define a valuation on interleaving morphisms by the largest \(\nu\) such that the map factors through multiplication by \(p^\nu\). Then prove that the primewise shift is antitone with respect to this morphism valuation.

1. Define a morphism valuation:
   \[
   v_p(\phi) := \sup\{\nu : \phi \text{ factors through } p^\nu\}.
   \]
2. Show that higher valuation means stronger annihilation or delay of p-primary birth obstructions.
3. Deduce the stability bound by comparing the interleaving defect with the morphism valuation.

Why promising:
- Conceptually cleaner.
- More reusable for later work in arithmetic sheaves, Iwasawa towers, and derived persistence.
- May reveal a category-theoretic formulation.

Risk:
- More setup.
- You may need extra algebraic infrastructure in Lean.

---

### Strategy C: Explicit matrix model over \(\mathbb{Z}/p^k\mathbb{Z}\)
Specialize first to finite modules with matrix presentations, prove the theorem there, and then lift to the abstract filtration theorem.

1. Model interleaving maps as matrices over `ZMod (p^k)`.
2. Prove that entrywise divisibility by \(p^\nu\) bounds the induced primewise birth displacement.
3. Lift from matrix modules to the catalog’s persistence objects.

Why useful:
- Excellent for `demo.py`.
- Gives falsifiable examples and possible counterexamples.
- Makes the arithmetic mechanism visible.

Why less promising as the main route:
- It may become too representation-dependent.
- General lifting can be technically awkward.

Still, this route is ideal for the algorithmic deliverable.

---

## Deep Proof Tactic Requirements

Your file must contain at least 3 theorems with nontrivial proof patterns. Target the following proof shapes:

- **Induction** on `ν` for monotonicity of `δ / p^ν` or factorization depth.
- **`rcases`** to unpack factorization data from `PadicControlledInterleaving`.
- **`by_contra`** to prove strict improvement: assume a class is born too early and derive contradiction with divisibility depth.
- **`field_simp`** if using `ℚ`/`ℝ` bounds involving \(1/p^\nu\).
- **multi-step `calc`** for chained inequalities comparing old and new stability constants.

Do not allow the main theorem to collapse to arithmetic simplification. The arithmetic should support the topology, not replace it.

---

## Cross-Domain Connections to Explicitly Develop

You must articulate and formalize at least one of these:

### 1. Arithmetic geometry
Interpret p-controlled interleavings as discrete analogues of maps with prescribed reduction behavior mod \(p^\nu\). This suggests a persistence theory sensitive to congruence depth, akin to how arithmetic geometers track degeneration prime by prime.

### 2. Iwasawa theory
As \(\nu\) grows, the filtration becomes increasingly p-adically damped. This resembles growth control in towers of \(p\)-primary modules. A theorem showing antitonicity in \(\nu\) is philosophically close to monotonic control along Iwasawa layers.

### 3. Statistical physics / dissipation
Divisibility depth acts like a damping coefficient. If you define a torsion energy functional and prove contraction, you have created an arithmetic analogue of energy decay under noisy evolution.

### 4. Error-correcting codes / information flow
A map divisible by \(p^\nu\) erases low-level p-primary information. This can be interpreted as a prime-specific channel attenuation. The resulting stability theorem resembles a data-processing inequality for arithmetic signal content.

---

## Application Keywords

Use these explicitly in your paper and article:

- arithmetic persistent homology
- p-adic stability
- valuation-sensitive interleaving
- primewise noise attenuation
- torsion-aware topological inference
- arithmetic TDA
- p-primary persistence
- divisibility-controlled transport
- Iwasawa-flavored persistence
- energy dissipation in discrete topology

---

## Suggested Lean 4 Scaffolding

Use names close to the following so the architecture is discoverable:

```lean
structure PadicControlledInterleaving
  (p ν : ℕ) (δ : α) (F G : FiltrationType) where
  toInterleaving : Interleaving δ F G
  forward_factor :
    ∀ t, ∃ f, toInterleaving.forward t = fun x => (p ^ ν) • f x
  backward_factor :
    ∀ t, ∃ g, toInterleaving.backward t = fun x => (p ^ ν) • g x

def valuationSensitiveShift
  (p : ℕ) (F G : FiltrationType) : α := ...

theorem valuation_sensitive_bound_mono ...
theorem primeShiftBound_valuation_sensitive ...
theorem primeShiftBound_valuation_sensitive_strict ...
theorem torsionEnergy_contracts_under_padic_control ...
```

If the catalog already has a notion of shift bound or birth set, integrate with it rather than duplicating it.

---

## Concrete File-Level Ambition

Build directly on:

- `Pythagorean/PrimewiseTorsionStability.lean`
  - especially `primeShiftBound_improved`
  - and `primeShiftBound_improved_strict`

Also inspect the lineage mentioned in the prompt:
- `pTorsionBirthSet_deltaClose`
- `primeShiftBound_improved_strict`

Your theorem should explicitly look like a **strict strengthening** of these, not a side lemma.

A good final theorem naming scheme:

```lean
primeShiftBound_valuation_sensitive
primeShiftBound_valuation_sensitive_strict
pTorsionBirthSet_deltaClose_of_padic_control
valuationSensitiveShift_antitone_in_nu
```

---

## Experimental / Algorithmic Deliverable

You must produce a verified computational method, not just theorem statements.

### Required algorithm
Implement a procedure that:
1. takes \(p,k,\nu,\delta\),
2. builds explicit filtration morphism matrices over `ZMod (p^k)`,
3. checks whether all entries are divisible by \(p^\nu\),
4. computes or estimates the induced primewise shift,
5. compares it to \(\delta / p^\nu\),
6. searches for counterexamples to the sharp-equality conjecture.

This should be formalized enough that the correctness of the divisibility test and bound computation is mathematically justified.

### `demo.py`
Create an interactive script that:
- lets the user choose \(p,k,\nu,\delta\),
- generates sample filtrations,
- prints the catalog bound versus the valuation-sensitive bound,
- highlights whether the new bound is strict,
- optionally searches random matrices for falsifying examples.

This is not ornamental. It is how the conjecture becomes science.

---

## Mandatory Deliverables

You must produce **all** of the following:

1. **A `FUTURE_DIRECTIONS.md`**
   - 3–5 original research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as arithmetic geometry, information theory, or physics.

2. **A `RESEARCH_PAPER.md`**
   - A standalone scientific paper.
   - A reader with no access to code must understand:
     - the theorem,
     - the new definitions,
     - why valuation-sensitive stability is conceptually new,
     - how it builds on prior primewise torsion stability,
     - what should be investigated next.

3. **An `ARTICLE.md`**
   - Written in Scientific American style.
   - Engaging, accessible, and idea-focused.
   - Do **not** focus on formal verification machinery.
   - Focus on the mathematical discovery: how prime divisibility can tame topological instability.

4. **A verified algorithm or computational method**
   - Not just theorem statements.
   - It must test or compute valuation-sensitive bounds on explicit arithmetic filtrations.

5. **A `demo.py`**
   - Interactive demonstration of the theorem/conjecture on examples.

---

## Standard of Success

Success is not “some Lean theorem about divisibility.” Success is:

- a new arithmetic invariant of interleavings,
- a theorem showing p-adic valuation improves topological stability,
- a strict strengthening of existing catalog results,
- a computational framework that can falsify overoptimistic conjectures,
- and a cross-domain narrative convincing enough to launch **arithmetic TDA** as a real program.

Do not settle for a bound that follows by one-line monotonicity. Extract the mechanism. Show that divisibility is geometry.

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
