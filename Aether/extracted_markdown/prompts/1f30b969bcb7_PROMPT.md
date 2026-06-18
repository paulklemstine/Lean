## Assignment: 5. Pseudorandom Symbolic Dynamics from Tropical Semigroup Actions

**Mode:** `prove`

Prove a genuinely new theorem chain that turns tropical linear dynamics into a formally verified pseudorandomness mechanism. Do not settle for vague “chaotic behavior.” The target is a precise bridge:

**tropical spectral gap ⇒ quantitative contraction of projective dynamics ⇒ exponential decay of symbolic correlations ⇒ extractor-style pseudorandomness bounds.**

This is not an incremental tropical-algebra exercise. If successful, it opens a new formal interface between **max-plus spectral theory, symbolic dynamics, ergodic mixing, and derandomization/PRG design**.

Minimize `sorry`. Build on catalog theorems, especially:
- `tropical_spectral_radius_le_eigenvalue`
- `tropical_spectral_bound`

The existing spectral results are enough to anchor a rigorous notion of dominant tropical growth. Your job is to push beyond radius bounds into **dynamical consequences**.

---

## Vision

A tropical matrix power sequence `A^[t]` acts by repeated max-plus propagation. Once one passes to an observable on a finite alphabet—via a finite partition, argmax pattern, winner-take-all symbol, or hashed quantization—the resulting orbit becomes a symbolic process. The breakthrough is to prove that a **strict tropical spectral gap** forces the memory of initial conditions to die exponentially fast, so finite symbolic windows become nearly independent of the seed.

This would amount to a new formal paradigm:

- tropical semigroup actions as deterministic entropy amplifiers,
- spectral gap as a derandomization resource,
- symbolic dynamics as the extraction layer.

If Aristotle can formalize even a first nontrivial instance of this pipeline in Lean, it creates a foundation for:
- tropical PRGs,
- deterministic samplers from algebraic dynamics,
- certified mixing for max-plus control systems,
- a tropical version of the “expander/mixing implies extractor” philosophy.

---

## Core Theorem Target

You should **replace the placeholder “I”** with a theorem of the following shape.

### Primary theorem statement, mathematically

Fix a finite state space `α`, a tropical transition kernel `A : α → α → ℝ`, and an observable `obs : (α → ℝ) → β` into a finite alphabet `β`. Let `x₀ : α → ℝ` be an initial tropical state and define the orbit
\[
x_{t+1}(i) = \max_{j} (A\, i\, j + x_t(j)).
\]
Let `y_t = obs x_t`.

Assume:

1. `A` has a unique dominant tropical eigenvalue `λ₁`,
2. every other cycle mean is at most `λ₂`,
3. `λ₂ < λ₁` (tropical spectral gap),
4. `obs` is stable under additive constants and depends only on projective class / argmax pattern / a finite partition thereof.

Then there exist constants `C > 0`, `ρ ∈ (0,1)` depending only on `A` and `obs` such that for all seeds `x₀,x₀'` and all `t`,
\[
\Pr[y_t(x₀)\neq y_t(x₀')] \le C \rho^t,
\]
or in a deterministic finite-partition formulation,
\[
d_{\mathrm{TV}}(\mathcal{L}(y_{t:t+k}\mid x₀),\mathcal{L}(y_{t:t+k}\mid x₀')) \le C_k \rho^t.
\]

Since we may not yet have a measure-theoretic symbolic-dynamics stack in the catalog, the **first formal milestone** should be a deterministic finite-window stabilization theorem implying pseudorandomness against bounded observers.

---

## Lean-friendly first theorem

Start with a theorem that avoids probability and proves **eventual symbolic coalescence with exponential tail bound encoded as a finite disagreement estimate**.

### Suggested definitions to introduce

- `tropical_mat_vec_mul`
- `orbit : ℕ → (α → ℝ)`
- `projective_distance : (α → ℝ) → (α → ℝ) → ℝ`
- `argmaxSymbol : (α → ℝ) → Finset α` or a single symbol under a tie-breaking rule
- `symbolicTrace : ℕ → β`
- `has_tropical_spectral_gap : Prop`

A practical first gap notion in Lean can be packaged abstractly if a full cycle-mean formalization is too large for one cycle:
```lean
def has_tropical_spectral_gap {α : Type*} [Fintype α] (A : α → α → ℝ) : Prop :=
  ∃ λ₁ λ₂ : ℝ, λ₂ < λ₁ ∧
    tropical_dominant_eigenvalue A λ₁ ∧
    tropical_second_growth_bound A λ₂
```
You may define `tropical_dominant_eigenvalue` and `tropical_second_growth_bound` in the weakest useful way that supports the theorem.

### Precise Lean 4 theorem target

A realistic formal target is:

```lean
theorem tropical_spectral_gap_eventual_symbolic_stability
  {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  (A : α → α → ℝ)
  (obs : (α → ℝ) → β)
  (x₀ x₀' : α → ℝ)
  (hgap : has_tropical_spectral_gap A)
  (hobs_proj : projective_invariant obs)
  (hobs_stable : observable_lipschitz_on_projective_classes obs A) :
  ∃ C ρ : ℝ, 0 < C ∧ 0 < ρ ∧ ρ < 1 ∧
    ∀ t : ℕ,
      symbolic_disagreement obs A x₀ x₀' t ≤ C * ρ ^ t
```

If `symbolic_disagreement` is too ambitious, use the simpler discrete version:
```lean
theorem tropical_spectral_gap_eventual_symbol_equality
  {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  (A : α → α → ℝ)
  (obs : (α → ℝ) → β)
  (x₀ x₀' : α → ℝ)
  (hgap : has_tropical_spectral_gap A)
  (hobs : projective_invariant obs) :
  ∃ N : ℕ, ∀ t ≥ N, orbitSymbol A obs x₀ t = orbitSymbol A obs x₀' t
```

This theorem is already nontrivial and field-opening if proved from a genuine gap hypothesis rather than by finite pigeonhole arguments.

---

## Stronger second theorem: mixing/extraction interface

Once the first theorem is in place, push to a finite-window extractor statement.

### Mathematical statement

For a symbolic trace `y_t`, define a `k`-window
\[
Y_{t,k} = (y_t,\dots,y_{t+k-1}).
\]
Prove that if the orbit is exponentially projectively contracting, then for any two seeds:
\[
\mathbf{1}[Y_{t,k}(x₀)\neq Y_{t,k}(x₀')] \le C_k \rho^t.
\]
Equivalently, all length-`k` cylinder events become seed-insensitive exponentially fast.

### Lean target
```lean
theorem tropical_gap_implies_window_extraction
  {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  (A : α → α → ℝ)
  (obs : (α → ℝ) → β)
  (k : ℕ)
  (x₀ x₀' : α → ℝ)
  (hgap : has_tropical_spectral_gap A)
  (hobs : projective_invariant obs) :
  ∃ C ρ : ℝ, 0 < C ∧ 0 < ρ ∧ ρ < 1 ∧
    ∀ t : ℕ,
      window_disagreement A obs k x₀ x₀' t ≤ C * ρ ^ t
```

This is the theorem that starts to look like a deterministic extractor / PRG guarantee.

---

## Third theorem: equivalence architecture

The ambitious theorem is a one-directional equivalence chain, with the reverse implication only if genuinely supportable.

### Theorem target
```lean
theorem tropical_spectral_gap_implies_mixing_and_extraction
  {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  (A : α → α → ℝ)
  (obs : (α → ℝ) → β)
  (hgap : has_tropical_spectral_gap A)
  (hobs : projective_invariant obs) :
  tropical_mixing A obs ∧ good_extractor A obs
```

Do **not** fake the reverse implication unless you can formalize a robust notion of “all non-dominant cycle means are strictly smaller.” Better to prove the strongest forward implication cleanly than claim a false equivalence.

---

## How to build on the catalog theorems

### 1. `tropical_spectral_radius_le_eigenvalue`
Use this to anchor the dominant growth rate. Even if the theorem is only an inequality, it lets you control orbit growth from above by an eigenvalue candidate. The key idea is to normalize by subtracting the top linear growth:
\[
\tilde x_t := x_t - t\lambda_1.
\]
Then the top mode remains bounded while subdominant modes decay relative to it.

### 2. `tropical_spectral_bound`
This likely provides a finite-dimensional growth estimate for matrix powers / tropical iterates. Use it to show:
- orbit coordinates grow at most linearly with slope `λ₁`,
- subdominant channels have a smaller asymptotic slope `λ₂`,
- hence the projective spread contracts at rate roughly `(\lambda₂ - \lambda₁)t`, which becomes exponential after discretized symbolic observation.

This is the bridge from spectral control to symbolic stabilization.

### 3. `tropical_mirror_theorem`
This is algebraically trivial, but in Lean it may help normalize `max`-expressions and simplify tropical identities appearing in the orbit recursion.

The other catalog theorems are less directly relevant; do not force them in. The mission is conceptual coherence, not name-dropping.

---

## Proof strategy architecture

### Strategy A: Projective contraction via dominant eigenspace
**Most promising.**

1. Define tropical orbit recursion and normalize by dominant growth `t * λ₁`.
2. Show that under a strict gap, every normalized orbit approaches the dominant projective eigenspace; equivalently, differences between two seeds become additive constants plus exponentially decaying error.
3. Since `obs` is projective-invariant, additive constants vanish, so the symbolic outputs eventually agree, with a quantitative disagreement bound.

Why this is strongest:
- It avoids building a full measure-theoretic dynamical system.
- It directly converts spectral information into a symbolic conclusion.
- It aligns best with Lean’s strengths: finite combinatorics, inequalities, recursive estimates.

### Strategy B: Finite automaton / eventual periodicity of argmax patterns
1. Encode each iterate by its argmax pattern or critical graph pattern.
2. Prove that strict spectral gap forces eventual entry into the critical class of the dominant eigenvalue.
3. Deduce eventual periodicity or stabilization of symbolic windows, hence seed-insensitivity.

Why useful:
- More combinatorial and discrete.
- Potentially easier if formalizing full projective metric machinery becomes cumbersome.

Risk:
- May only yield eventual stability, not a clean exponential quantitative rate.

### Strategy C: Correlation decay through symbolic dynamics
1. Define the shift system generated by `obs ∘ orbit`.
2. Prove that tropical spectral gap implies a Lasota–Yorke-style contraction on finite cylinder observables, or at least on Hamming/Lipschitz observables on windows.
3. Deduce extraction bounds from decay of correlations.

Why visionary:
- This is closest to the ergodic-theory/PRG thesis.
- It opens the door to entropy and information-theoretic tropical dynamics.

Risk:
- Heavy infrastructure; likely better as a second-cycle extension after Strategy A succeeds.

**Recommendation:** Execute **Strategy A first**, then package its consequences in the language of mixing/extraction.

---

## Concrete implementation scaffolding in Lean

You should introduce a minimal but extensible API.

### Tropical orbit
```lean
def tropical_mat_vec_mul {α : Type*} [Fintype α]
    (A : α → α → ℝ) (x : α → ℝ) : α → ℝ :=
  fun i => Finset.univ.sup fun j => A i j + x j
```
If `Finset.sup` over `ℝ` is awkward, use `sSup` on the finite image set or work in `WithBot ℝ` if needed. But because `α` is finite and nonempty, this should be manageable.

```lean
def orbit {α : Type*} [Fintype α]
    (A : α → α → ℝ) (x₀ : α → ℝ) : ℕ → (α → ℝ)
  | 0 => x₀
  | t+1 => tropical_mat_vec_mul A (orbit A x₀ t)
```

### Symbolic observation
```lean
def orbitSymbol {α β : Type*} [Fintype α]
    (A : α → α → ℝ) (obs : (α → ℝ) → β) (x₀ : α → ℝ) (t : ℕ) : β :=
  obs (orbit A x₀ t)
```

### Projective invariance
```lean
def projective_invariant {α β : Type*}
    (obs : (α → ℝ) → β) : Prop :=
  ∀ (x : α → ℝ) (c : ℝ), obs (fun i => x i + c) = obs x
```

### Disagreement indicator
```lean
def symbolic_disagreement {α β : Type*} [Fintype α] [DecidableEq β]
    (obs : (α → ℝ) → β) (A : α → α → ℝ)
    (x₀ x₀' : α → ℝ) (t : ℕ) : ℝ :=
  if orbitSymbol A obs x₀ t = orbitSymbol A obs x₀' t then 0 else 1
```

This keeps the theorem quantitative without introducing probability too early.

---

## Mathematical subtleties you must handle honestly

1. **What exactly is the “second tropical eigenvalue”?**  
   In max-plus algebra, this is often better interpreted via cycle means outside the critical graph, not naive algebraic multiplicity. If full formalization is too large, define a workable abstract hypothesis `tropical_second_growth_bound A λ₂`.

2. **Exponential vs linear decay.**  
   Tropical growth rates are naturally linear in time at the level of logarithms. The exponential bound in pseudorandomness emerges only after passing to a symbolic disagreement or normalized metric. Be explicit about this conversion.

3. **Need for projective quotient.**  
   Tropical dynamics are invariant under adding constants. Any observable that ignores this quotient can destroy the theorem. So insist on projective-invariant observables.

4. **Generic observables may fail.**  
   You may need to formalize the theorem first for:
   - unique argmax symbol,
   - lexicographically tie-broken argmax,
   - partition by order type / winner pattern.  
   This is acceptable and still powerful.

5. **Mixing is delicate in deterministic systems.**  
   Since the process is deterministic for fixed seed, “mixing” should first mean **loss of dependence on initial seed** or **cylinder stabilization across seeds**, not measure-theoretic Bernoulli mixing. Build the deterministic theorem first.

---

## Cross-domain connections you should explicitly exploit

### 1. Ergodic theory
Treat the symbolic trace as a subshift generated by a deterministic semigroup action. Spectral gap should imply asymptotic collapse of distinct seed trajectories into the same cylinder structure. This is a tropical analogue of transfer-operator contraction.

### 2. Derandomization and extractor theory
The statement “finite windows become seed-insensitive exponentially fast” is a deterministic extractor principle. It suggests tropical dynamics as a source of **structured pseudorandom generators**.

### 3. Automata / formal languages
Argmax-pattern dynamics can be encoded as a finite automaton. Spectral gap may imply eventual synchronization, connecting to Černý-style synchronization phenomena and symbolic coding.

### 4. Control theory
Max-plus linear systems model timed event systems. A mixing/stability theorem would imply robust forgetting of initialization in scheduling networks and asynchronous systems.

### 5. Information theory
If symbolic windows stabilize across seeds, one gets a tropical form of **information dissipation**: mutual information between seed and output window decays. This is an opening toward tropical data-processing inequalities.

### 6. Complexity theory
If the orbit map is efficiently computable and the symbolic trace has certified extraction, this suggests a new algebraic route to PRG constructions from deterministic dynamics.

---

## What would count as a breakthrough here

A theorem of the form

> strict tropical spectral gap + projective observable  
> ⇒ exponentially decaying symbolic disagreement across seeds

would already be a new conceptual object: a **spectral theory of pseudorandomness for tropical dynamics**.

It would open at least four research programs:
1. tropical expanders and PRGs,
2. entropy and information inequalities in max-plus systems,
3. symbolic coding of tropical semigroup actions,
4. certified initialization-forgetting in discrete event systems.

This is exactly the kind of result that makes mathematicians say: “I did not expect tropical spectral theory to speak to derandomization.”

---

## Tactical theorem decomposition

Prove in this order:

### Lemma 1: Additive equivariance
```lean
theorem orbit_add_constant
  {α : Type*} [Fintype α]
  (A : α → α → ℝ) (x : α → ℝ) (c : ℝ) :
  ∀ t, orbit A (fun i => x i + c) t = fun i => orbit A x t i + c
```

This is fundamental and should be easy by induction.

### Lemma 2: Dominant growth normalization
Formalize that under `hgap`, normalized iterates `orbit A x t i - t * λ₁` remain in a bounded tube around a dominant eigenvector class.

### Lemma 3: Seed contraction modulo constants
Show there exist `C, ρ` such that
```lean
∃ c_t : ℕ → ℝ, ∀ t i,
  |orbit A x₀ t i - orbit A x₀' t i - c_t t| ≤ C * ρ ^ t
```

This is the real engine.

### Lemma 4: Observable stability
If `obs` is projective-invariant and locally constant away from tie hyperplanes, then the previous estimate implies eventual equality of symbols.

### Theorem 5: Window extraction
Lift pointwise symbol equality/disagreement to windows of length `k`.

This decomposition is clean, modular, and realistic for Lean.

---

## If full spectral-gap formalization is too large

Then prove a **conditional meta-theorem** parameterized by a contraction hypothesis:

```lean
def exponentially_projectively_contracting
  (A : α → α → ℝ) : Prop := ...

theorem projective_contraction_implies_symbolic_extraction
  ...
```

Then separately prove that a usable version of `has_tropical_spectral_gap A` implies this contraction in a special class:
- `α = Fin n`,
- irreducible matrices,
- unique critical cycle,
- or 2×2 / 3×3 matrices.

A sharp special-case theorem is far better than a vague universal claim.

---

## Application keywords

`tropical dynamics`, `max-plus algebra`, `symbolic dynamics`, `ergodic theory`, `spectral gap`, `mixing`, `decay of correlations`, `derandomization`, `pseudorandom generators`, `extractors`, `finite automata`, `control theory`, `information dissipation`, `projective contraction`, `discrete event systems`, `formal verification`

---

## Deliverables

1. A Lean file proving at least one substantial theorem from the chain above.
2. Definitions for tropical orbit, projective invariance, and symbolic trace.
3. Minimal supporting lemmas for additive equivariance and contraction modulo constants.
4. Clear comments stating where catalog theorems are used.
5. **A `FUTURE_DIRECTIONS.md` file with 3–5 concrete breakthrough next steps**, for example:
   - formalize tropical mutual information decay from symbolic stabilization,
   - prove a tropical data-processing inequality,
   - construct explicit tropical PRGs with seed length / stretch guarantees,
   - classify observables yielding Bernoulli-type symbolic factors,
   - connect tropical critical graph structure to synchronization thresholds.

Be bold. The target is not “some dynamics theorem in tropical algebra.” The target is the birth of a **formal tropical theory of pseudorandomness**.

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
