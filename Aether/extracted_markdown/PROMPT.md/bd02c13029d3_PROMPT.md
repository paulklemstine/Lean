Soli Deo Gloria

## Assignment: Direction 2 — Universality of Phase Transition Critical Exponents

**Mode:** `prove` + `discover`

You are not being asked for an incremental refinement of subgroup pressure. You are being asked to carve out a mathematically new bridge between **finite group generation**, **statistical mechanics**, and **limit laws**. The target is not merely to compute more examples, but to identify and formalize a **universality mechanism**: a theorem showing that once subgroup contributions become weakly dependent or exactly additive under products, the singular behavior of generation probability is governed by a small number of structural parameters rather than microscopic subgroup data.

The revolutionary possibility here is that finite group generation has an honest **critical-phenomena layer**: order parameters, susceptibilities, scaling windows, and exponents. If you can formalize even the first nontrivial universality theorem in Lean, it opens a field. It would let future work import ideas from renormalization, concentration of measure, random generation, arithmetic statistics, and representation growth into a common language.

Build explicitly on:

- `Pythagorean/SubgroupPressure.lean` — pressure bounds and factorization/additivity infrastructure.
- `Algebra/SymmGroupGen/Basic.lean` — concrete generation facts for symmetric groups.

Your job is to prove **new theorems**, define at least one genuinely new concept, and produce a verified computational framework that tests the universality conjecture across families.

---

## Core Vision

The informal conjecture says:

> For natural families of finite groups with a parameterized subgroup ensemble, the generation probability near a critical point behaves like a power law
> \[
> P_{\mathrm{gen}}(G_n;t) \asymp A(G_n)\, |\Phi_{G_n}(t)|^\beta
> \]
> where the exponent \(\beta\) depends only on coarse structural data, not on subgroup-level details.

This is too ambitious to attack head-on in full generality. So the correct breakthrough is to isolate a **formal universality class** where the exponent can actually be proved, then demonstrate that important group families lie in or near that class.

The most promising first target is the product world, where the catalog already suggests exact factorization of pressure and additive free energy. In statistical mechanics, exact additivity is where universality first becomes mathematically visible.

---

## New Definitions You Must Introduce

You must define at least one new concept not already present in the catalog. I recommend introducing all three below.

### 1. Critical profile
A normalized function measuring singular decay near a critical parameter.

```lean
def CriticalProfile (α : Type*) := α → ℝ
```

For a family indexed by `ι`, define a profile \(f_i : \mathbb R \to \mathbb R\) with critical point \(t_c(i)\), and say it has exponent \(\beta\) if
\[
\lim_{t \to t_c(i)} \frac{\log |f_i(t)|}{\log |t-t_c(i)|} = \beta.
\]

You may want a finite-difference / asymptotic surrogate formalizable without full measure-theoretic asymptotics.

### 2. Universality class for subgroup thermodynamics
A structure encoding the data needed for exponent comparison.

```lean
structure SubgroupUniversalityClass (ι : Type*) where
  G        : ι → Type*
  instFin  : ∀ i, Fintype (G i)
  instGroup : ∀ i, Group (G i)
  pressure : ι → ℝ → ℝ
  crit     : ι → ℝ
  orderParam : ι → ℝ → ℝ
  exponentCandidate : ℝ
  factorizationLaw :
    Prop
  regularityLaw :
    Prop
```

This is intentionally broad. The point is to package the exact assumptions under which exponent preservation can be proved.

### 3. Log-slope critical exponent
A concrete, computable substitute for asymptotic power law.

```lean
def logSlopeAt (f : ℝ → ℝ) (tc h : ℝ) : ℝ :=
  (Real.log (|f (tc + h)|) - Real.log (|f tc| + 1)) / Real.log |h|
```

Or better, avoid singularity at `f tc = 0` by defining a shifted profile. The key is to have a notion that supports exact inequalities and computational estimation.

---

## Precise Theorem Targets

You must prove at least **3 substantial theorems**. The following are the right targets.

---

### Theorem 1: Additivity forces exponent preservation under direct products

This should be your flagship theorem.

#### Mathematical statement
Suppose two group families \(G_n, H_n\) have order parameters \(M_G(n,t)\), \(M_H(n,t)\) that vanish at criticality and satisfy two-sided power bounds near critical points with the **same exponent** \(\beta>0\):
\[
c_1 |t-t_c|^\beta \le M_G(n,t) \le C_1 |t-t_c|^\beta,\qquad
c_2 |t-t_c|^\beta \le M_H(n,t) \le C_2 |t-t_c|^\beta.
\]
If the combined family \(K_n = G_n \times H_n\) satisfies multiplicative generation law
\[
M_K(n,t)=M_G(n,t)\, M_H(n,t),
\]
then
\[
M_K(n,t) \asymp |t-t_c|^{2\beta}.
\]
Equivalently, the critical exponent is additive under exact product factorization.

This is already nontrivial and mathematically meaningful: it says universality classes compose in a rigid way.

#### Lean-oriented type signature
A robust formalizable version is:

```lean
theorem exponent_mul_of_two_sided_bounds
    {f g : ℝ → ℝ} {tc β : ℝ}
    (hβ : 0 < β)
    (hf_low : ∃ c > 0, ∀ᶠ x in 𝓝[≠] tc, c * |x - tc| ^ β ≤ |f x|)
    (hf_up  : ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |f x| ≤ C * |x - tc| ^ β)
    (hg_low : ∃ c > 0, ∀ᶠ x in 𝓝[≠] tc, c * |x - tc| ^ β ≤ |g x|)
    (hg_up  : ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |g x| ≤ C * |x - tc| ^ β) :
    ∃ c C > 0,
      ∀ᶠ x in 𝓝[≠] tc,
        c * |x - tc| ^ (2 * β) ≤ |(f x) * (g x)| ∧
        |(f x) * (g x)| ≤ C * |x - tc| ^ (2 * β)
```

If `^ β` over reals is awkward, use `Real.rpow`:

```lean
theorem exponent_mul_of_two_sided_bounds_rpow
    {f g : ℝ → ℝ} {tc β : ℝ}
    (hβ : 0 < β)
    ...
    : ∃ c C > 0,
      ∀ᶠ x in 𝓝[≠] tc,
        c * |x - tc| ^ β * |x - tc| ^ β ≤ |f x * g x| ∧
        |f x * g x| ≤ C * |x - tc| ^ β * |x - tc| ^ β
```

You can then derive the exponent-additivity corollary separately.

#### Why this is a breakthrough
This theorem turns subgroup thermodynamics from a heuristic analogy into a mathematically rigid scaling law. It says: once exact product factorization exists, critical behavior is not arbitrary. That is the first genuine universality theorem in this area.

---

### Theorem 2: Free-energy additivity implies susceptibility additivity

The next theorem should connect to physics, not just asymptotics.

#### Mathematical statement
Let \(F_G(t)\), \(F_H(t)\) be free energies with
\[
F_{G \times H}(t)=F_G(t)+F_H(t).
\]
If susceptibilities are defined as derivatives or second finite differences,
\[
\chi_G(t)=F_G''(t), \qquad \chi_H(t)=F_H''(t),
\]
then
\[
\chi_{G\times H}(t)=\chi_G(t)+\chi_H(t).
\]

If full differentiability is cumbersome, prove a discrete version using symmetric second differences:
\[
\Delta_h^2 F(t)=F(t+h)-2F(t)+F(t-h).
\]
Then exact additivity is immediate but not trivial if you formulate and use it in a structured way over pressure/free-energy objects.

#### Lean-oriented type signature
A finite-difference version is ideal:

```lean
def secondDiff (f : ℝ → ℝ) (t h : ℝ) : ℝ :=
  f (t + h) - 2 * f t + f (t - h)

theorem secondDiff_add
    (f g : ℝ → ℝ) :
    secondDiff (fun t => f t + g t) = fun t h => secondDiff f t h + secondDiff g t h
```

Then specialize to subgroup free energy:

```lean
theorem susceptibility_add_of_freeEnergy_add
    {FG FH FK : ℝ → ℝ}
    (hadd : FK = fun t => FG t + FH t) :
    ∀ t h, secondDiff FK t h = secondDiff FG t h + secondDiff FH t h
```

A stronger theorem, closer to the research goal:

```lean
theorem divergence_bound_of_additive_susceptibility
    {χG χH χK : ℝ → ℝ} {tc γ : ℝ}
    (hK : ∀ t, χK t = χG t + χH t)
    (hG : ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |χG x| ≤ C * |x - tc|^(-γ))
    (hH : ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |χH x| ≤ C * |x - tc|^(-γ)) :
    ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |χK x| ≤ C * |x - tc|^(-γ)
```

#### Why this matters
In statistical mechanics, exponents are not only about order parameters; they are about response functions. This theorem says subgroup pressure formalism has a genuine analogue of susceptibility scaling. That opens the door to a dictionary:
- generation probability ↔ order parameter
- free energy ↔ log partition object
- subgroup fluctuation ↔ susceptibility

That dictionary is the field-opening insight.

---

### Theorem 3: Symmetric-product families exhibit exact scaling windows

You need one theorem tied concretely to catalog group families.

Let \(G_m = S_k^m\), direct product of \(m\) copies of a fixed symmetric group \(S_k\). If a generation observable factors across coordinates, then the free energy per factor stabilizes:
\[
\frac{1}{m}\log P_{\mathrm{gen}}(S_k^m;t)
=
\log P_{\mathrm{gen}}(S_k;t).
\]
Or with pressure \(P\),
\[
\Pi(S_k^m;t)=m\,\Pi(S_k;t).
\]

This is the finite-group analogue of extensivity.

#### Lean-oriented type signature
Abstract the product law first:

```lean
theorem freeEnergy_directPower
    (F : ℕ → ℝ → ℝ)
    (hzero : ∀ t, F 0 t = 0)
    (hstep : ∀ m t, F (m + 1) t = F m t + F 1 t) :
    ∀ m t, F m t = m * F 1 t
```

This theorem is deep enough if proved by induction with careful coercions and `calc`.

Then derive a pressure law for direct powers:

```lean
theorem pressure_directPower_linear
    (Π : ℕ → ℝ → ℝ)
    (hzero : ∀ t, Π 0 t = 0)
    (hprod : ∀ m t, Π (m + 1) t = Π m t + Π 1 t) :
    ∀ m t, Π m t = (m : ℝ) * Π 1 t
```

If you can instantiate `Π` using actual subgroup pressure on `S_k^m`, even better. If not, state clearly that this theorem formalizes the exact extensivity mechanism required by the catalog factorization theorem.

#### Why this matters
This gives a rigorous scaling window model where exponent extraction is not heuristic fitting but a theorem about linear thermodynamic limit. It is the finite-group counterpart of the passage from microscopic partition function to intensive free energy.

---

## Cross-Domain Theorem Requirement

You must include at least one theorem connecting this domain to another mathematical domain. The strongest and most natural bridge here is to **probability / concentration** or **convex analysis**.

### Recommended cross-domain theorem: log-convexity from Hölder-type interpolation
If generation probability or pressure is multiplicative over independent factors, then the corresponding partition-like function often becomes log-convex in the parameter.

#### Mathematical statement
For positive functions \(Z_1,Z_2\), if \(Z(t)=Z_1(t)Z_2(t)\), then \(\log Z\) is additive. If each \(\log Z_i\) is convex, then \(\log Z\) is convex. Therefore product families inherit thermodynamic stability inequalities.

#### Lean-oriented type signature
A manageable version:

```lean
theorem convexOn_add
    {f g : ℝ → ℝ} {s : Set ℝ}
    (hf : ConvexOn ℝ s f)
    (hg : ConvexOn ℝ s g) :
    ConvexOn ℝ s (fun x => f x + g x)
```

Then use it for free energy:

```lean
theorem convex_freeEnergy_of_product_family
    {FG FH FK : ℝ → ℝ} {s : Set ℝ}
    (hadd : FK = fun t => FG t + FH t)
    (hFG : ConvexOn ℝ s FG)
    (hFH : ConvexOn ℝ s FH) :
    ConvexOn ℝ s FK
```

This is a genuine bridge:
- group generation / subgroup pressure
- convex analysis / thermodynamic stability

You should explicitly frame this as a theorem connecting algebraic generation phenomena to analytic structure.

---

## Conjecture With Testable Prediction

You must state a falsifiable conjecture, with a computational protocol that could fail.

### Conjecture: exponent rigidity for direct-power universality classes
Fix a finite group \(G\) with nontrivial subgroup thermodynamics and define \(G^{(m)} = G^m\). Suppose the order parameter \(M_m(t)\) factors multiplicatively:
\[
M_m(t)=M_1(t)^m.
\]
Then the effective log-slope exponent satisfies
\[
\beta_{\mathrm{eff}}(m)=m\,\beta_{\mathrm{eff}}(1)
\]
throughout the scaling window.

In Lean-friendly language, conjecture that the finite-difference log-slope of the direct-power family is exactly multiplied by `m` whenever the observable factors exactly.

This is falsifiable: if the fitted slope for `S_k^m`, `GL_n(𝔽_q)` block-product analogues, or candidate semidirect-product families fails linearity, the conjecture is false.

### Computational test
For each family:
- compute or estimate the generation observable \(M(t)\),
- compute `logSlopeAt` over a shrinking mesh around the numerically detected critical point,
- fit the slope,
- compare:
  - across `S_k^m`,
  - across `GL_n(𝔽_q)` with fixed `q`, varying `n`,
  - across `PSL₂(p)` with varying primes `p`.

A single robust deviation from predicted linearity is evidence against the conjecture.

---

## Proof Strategy Architecture

You must not give one proof hint. You must execute a multi-path program.

### Strategy A: Exact product-factorization route
**Most promising.**
1. Use the catalog product/additivity theorems from `Pythagorean/SubgroupPressure.lean` to isolate exact multiplicative or additive laws for the relevant observable.
2. Prove general analytic lemmas: two-sided power bounds are preserved under multiplication; finite differences are additive under sum; convexity is preserved under addition.
3. Transfer these lemmas to direct products and direct powers of finite groups, especially `S_k^m`.

**Why this is strongest:** exact factorization is the rare setting where universality can be proved rather than guessed. It gives theorem-level results now.

### Strategy B: Scaling-window / finite-difference renormalization route
1. Define a finite-difference susceptibility and finite-scale exponent estimator that avoids measure-theoretic limits.
2. Prove exact recursion under product decomposition:
   \[
   F_{m+1}=F_m+F_1.
   \]
3. Derive linearity of finite-scale exponents and second-difference response functions.

**Why this is valuable:** it yields a verified algorithm, is computationally testable, and avoids delicate differentiability assumptions.

### Strategy C: Concentration / CLT-inspired route
1. Model subgroup pressure of a product family as a sum of coordinate contributions.
2. Prove deterministic variance-additivity or second-moment bounds for the finite-difference response.
3. Use this to justify why coarse exponents depend only on additive structure, not microscopic details.

**Why this is visionary but riskier:** it gets closest to the universality narrative from physics, but may require probabilistic infrastructure not yet convenient in Lean. Use it for conjectures and computational guidance, not as the primary proof path.

---

## Lean 4 Implementation Guidance

You must include theorem statements with substantial proof content. Avoid toy statements.

### Suggested file
Create something like:

`Pythagorean/SubgroupUniversality.lean`

### Suggested theorem inventory
At minimum:
1. `exponent_mul_of_two_sided_bounds`
2. `secondDiff_add` and/or `susceptibility_add_of_freeEnergy_add`
3. `freeEnergy_directPower` or `pressure_directPower_linear`
4. one cross-domain theorem such as `convex_freeEnergy_of_product_family`

### Proof-style requirements
At least 3 theorems must use nontrivial tactics and structure:
- induction for direct-power extensivity,
- `rcases` for unpacking two-sided bounds,
- `by_contra` for positivity/nonvanishing sublemmas if needed,
- `field_simp` if rational finite-difference expressions appear,
- multi-step `calc` blocks for exponent manipulations.

Do not let the file devolve into trivial simplifications.

---

## Application Keywords

Include these explicitly in the paper and code comments:

**Application keywords:** critical phenomena, universality class, finite group generation, subgroup pressure, free energy, susceptibility, scaling window, direct product, symmetric groups, linear response, convexity, concentration of measure, renormalization heuristic, asymptotic exponent estimation, algebraic statistical mechanics.

---

## Why This Could Open a Field

If successful, this project does more than prove a few lemmas. It creates the first formal framework where one can ask:
- Which finite group families share a universality class?
- Do semidirect products alter exponents the way relevant perturbations alter critical behavior in physics?
- Is there a finite-group analogue of mean-field theory?
- Can random generation thresholds in simple groups be classified by thermodynamic scaling data?

That is a new research program, not a variant.

---

## Mandatory Deliverables

You must produce **ALL** of the following.

### 1. `FUTURE_DIRECTIONS.md`
Include **3–5 original research directions**, each written as real mathematical prose, each containing:
- the sentence **“The key insight is...”**
- the sentence **“Why now?”**
At least one direction must bridge to a different domain, such as:
- representation theory,
- arithmetic statistics,
- random matrix theory,
- information theory,
- probability / concentration.

### 2. `RESEARCH_PAPER.md`
A standalone scientific paper that someone can read **without access to the code**. It must explain:
- the mathematical problem,
- the exact new definitions,
- the main theorems,
- why they are nontrivial,
- how they connect finite groups to critical phenomena,
- computational evidence and conjectures,
- what should be attacked next.

### 3. `ARTICLE.md`
Write this in **Scientific American** style:
- engaging,
- conceptually vivid,
- focused on the mathematics and significance,
- **do not focus on formal verification machinery**,
- explain why phase transitions in group generation are surprising and profound.

### 4. A verified algorithm or computational method
Not just theorem statements. You must provide a verified computational procedure for:
- estimating finite-scale critical exponents from sampled observables,
- or computing second-difference susceptibility,
- or testing exponent additivity in direct-product families.

This should be mathematically specified and supported by proven correctness lemmas.

### 5. `demo.py`
An interactive demonstration that:
- samples or imports observable data for `S_k^m`, `GL_n(𝔽_q)`, `PSL₂(p)` when feasible,
- computes effective exponents,
- plots scaling behavior near candidate critical points,
- compares slopes across families,
- highlights possible universality or counterexamples.

The demo must be capable of disproving the conjecture if the data do not fit.

---

## Final Tactical Instruction

Be bold but disciplined. Do **not** try to formalize all of renormalization group theory. Prove the first theorems that make universality mathematically unavoidable in the exact-factorization regime. If you can show that:
- direct-product subgroup thermodynamics has rigid exponent arithmetic,
- response functions add,
- convexity and stability transfer across product families,
- and effective exponents can be computed and tested,

then you will have created the seed of a new algebraic theory of critical phenomena.

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
