## Assignment: P vs SPACE via Tropical Time-Space Tradeoffs

Mode: **discover** with a **prove** subgoal, but be ruthless about mathematical honesty. The stated “separate P from PSPACE” objective is almost certainly too strong for current formal methods and probably unreachable in ZFC-level complexity theory without radically new ideas. So do not posture. Instead, build a rigorous tropical complexity theory whose theorems would make an eventual separation *mathematically meaningful*. If the full separation claim collapses, pivot immediately to a **counterexample/refinement** theorem showing exactly which tropical invariants fail to imply `P ≠ PSPACE`.

Your mission is to create a formal min-plus framework for time-space tradeoffs of finite computations, prove sharp lower bounds inside that framework, and isolate a tropical spectral invariant that genuinely obstructs low-time simulation of high-space computations.

### Core Vision

The breakthrough is **not** to restate complexity folklore in Lean. The breakthrough is to define a tropical linear-algebraic avatar of computation where:

- configurations become vertices,
- local transitions induce a weighted min-plus matrix,
- bounded-space computations correspond to paths in a layered graph,
- simulation cost becomes a min-plus matrix power or closure,
- and “hardness of flattening space into time” becomes a theorem about tropical spectral growth, cycle means, or min-plus diameter.

If successful, this opens a new field: **tropical complexity theory**, connecting
computational complexity, min-plus algebra, automata, shortest paths, spectral graph theory, and even Hamilton–Jacobi / idempotent analysis.

### Precise Theorem Targets

Do **not** claim `P ≠ PSPACE` outright unless you can prove it. Instead target the following formally meaningful theorem package.

---

## Theorem Package A: Tropical simulation lower bound for bounded-space layered systems

Define a bounded-space deterministic computation abstractly as a family of finite transition systems indexed by input length, with at most polynomially many configurations and unit-cost transitions. For each input size `n`, let `Cfg n` be the finite type of configurations, and let `W n : Matrix (Cfg n) (Cfg n) ℝ∞` be the min-plus weight matrix with
- `0` on allowed one-step transitions,
- `⊤` on forbidden transitions.

Let `tropicalDist n k c d` be the `(c,d)` entry of `(W n)^[k]` in the min-plus semiring, interpreted as the minimum cost of a length-`k` simulation. Let `spaceBound : ℕ → ℕ` and `timeBound : ℕ → ℕ`.

You should aim to formalize and prove a theorem of the following shape:

```lean
theorem bounded_space_layered_lower_bound
  {Cfg : ℕ → Type}
  [∀ n, Fintype (Cfg n)] [∀ n, DecidableEq (Cfg n)]
  (W : ∀ n, Matrix (Cfg n) (Cfg n) ℝ∞)
  (s t : ∀ n, Cfg n)
  (spaceBound timeBound : ℕ → ℕ)
  (hcfg : ∀ n, Fintype.card (Cfg n) ≤ 2 ^ (spaceBound n))
  (hpolySpace : ∃ k C : ℕ, ∀ n, spaceBound n ≤ C * n ^ k)
  (hunit : ∀ n c d, W n c d = 0 ∨ W n c d = ⊤)
  (hreach : ∀ n, ∃ k ≤ timeBound n, ((W n) ^ k) (s n) (t n) = 0)
  :
  ∃ f : ℕ → ℕ, (∀ᶠ n in Filter.atTop, timeBound n ≤ f n) ∧
    ∀ g : ℕ → ℕ,
      (∀ᶠ n in Filter.atTop, g n < Nat.log2 (Fintype.card (Cfg n) + 1)) →
      ¬ (∀ᶠ n in Filter.atTop, ((W n) ^ (g n)) (s n) (t n) = 0)
```

This exact statement may need adjustment, but the content should be:

> If the configuration graph has exponentially many states in the space bound, then any simulation restricted to too few min-plus composition layers cannot realize the accepting path uniformly eventually.

This is a *layer-depth obstruction* theorem: a bounded-space computation cannot be compressed into too few tropical matrix multiplications.

A cleaner finite version may be easier and more powerful:

```lean
theorem tropical_layer_depth_lb
  {α : Type} [Fintype α] [DecidableEq α]
  (W : Matrix α α ℝ∞) (s t : α) (L : ℕ)
  (hunit : ∀ a b, W a b = 0 ∨ W a b = ⊤)
  (hdiam : ((W ^ L) s t = 0))
  (hno_shorter : ∀ k < L, (W ^ k) s t ≠ 0) :
  L ≤ Fintype.card α
```

and then a strengthened version under acyclicity / layeredness:

```lean
theorem tropical_layered_exact_depth
  {α : Type} [Fintype α] [DecidableEq α]
  (rank : α → ℕ)
  (W : Matrix α α ℝ∞) (s t : α) (L : ℕ)
  (hstep : ∀ a b, W a b = 0 → rank b = rank a + 1)
  (hs : rank s = 0)
  (ht : rank t = L)
  :
  ((W ^ L) s t = 0) ↔ ∃ p : Fin (L+1) → α, p 0 = s ∧ p ⟨L, Nat.lt_succ_self L⟩ = t
    ∧ ∀ i : Fin L, W (p i.castSucc) (p i.succ) = 0
```

This theorem is profound because it identifies tropical matrix powers with exact computation depth in layered state spaces. It is the right formal backbone for any later complexity interpretation.

---

## Theorem Package B: Tropical spectral obstruction

You referenced “tropical spectral gap.” Make that precise. In min-plus algebra, the natural spectral invariant is the **minimum cycle mean**. A “gap” can mean the difference between:
1. the minimum cycle mean reachable from the start and
2. the minimum cycle mean on accepting strongly connected components,
or between the first and second distinct cycle means.

Define a finite weighted digraph and let `μ(W)` be its minimum cycle mean. For layered acyclic systems `μ(W)` is trivial, so the right object is a **space-time tradeoff matrix** built from a compressed simulation operator. Then prove a theorem showing that a positive gap obstructs exact low-depth realization.

A realistic theorem target:

```lean
theorem positive_tropical_gap_obstructs_shortcut
  {α : Type} [Fintype α] [DecidableEq α]
  (W C : Matrix α α ℝ∞) (s t : α) (L : ℕ) (δ : ℝ)
  (hgap : tropicalSpectralGap W ≥ δ)
  (hδ : 0 < δ)
  (hrealize : (W ^ L) s t = 0)
  :
  ¬ ∃ k < L, (C ^ k) s t = 0 ∧ tropicalClosureDominates C W
```

This may require you to define:
- `tropicalSpectralGap : Matrix α α ℝ∞ → ℝ`
- `tropicalClosureDominates : Matrix α α ℝ∞ → Matrix α α ℝ∞ → Prop`

If spectral-gap formalization becomes too heavy, prove a combinatorial surrogate:

```lean
theorem bottleneck_rank_gap_obstructs_compression
  {α : Type} [Fintype α] [DecidableEq α]
  (rank : α → ℕ) (W : Matrix α α ℝ∞) (s t : α) (L B : ℕ)
  (hstep : ∀ a b, W a b = 0 → rank b = rank a + 1)
  (hbottleneck : ∀ i ≤ L, B ≤ Fintype.card {a : α // rank a = i})
  (hpath : (W ^ L) s t = 0) :
  ¬ ∃ k < Nat.log2 B, ∃ C, (C ^ k) s t = 0 ∧ tropicalClosureDominates C W
```

This says: if every intermediate layer is wide, then no logarithmically shallow tropical compression preserves reachability. That is a genuine time-space tradeoff theorem in min-plus language.

---

## Theorem Package C: Honest complexity-theoretic bridge theorem

You need one theorem explicitly linking the tropical framework to classical complexity classes, but in a way that is true and formalizable.

Target:

```lean
theorem polyspace_computation_encodes_as_tropical_reachability
  (M : TM2 Γ Λ) :
  ∃ p : ℕ → ℕ,
    IsPolynomial p ∧
    ∀ n,
      ∃ α : Type, Fintype α ∧ DecidableEq α ∧
      Fintype.card α ≤ 2 ^ (p n) ∧
      ∃ W : Matrix α α ℝ∞, 
        TM_accepts_in_space M n ↔ ∃ k, ((W ^ k) (startCfg n) (acceptCfg n) = 0)
```

Even if `TM2` infrastructure is incomplete in Mathlib, you can replace it with an abstract finite transition system representing a space-bounded machine. The point is to prove an **encoding theorem**:
> polynomial-space computation = tropical reachability in an exponentially large but finitely presented min-plus system.

This is already a conceptual bridge theorem. It opens the door to translating complexity lower bounds into tropical linear algebra.

---

## Most Promising Proof Strategies

### Strategy 1: Layered DAG semantics via exact path-length characterization
This is the strongest and most likely to succeed.

1. **Define a 0/∞ min-plus adjacency matrix** for a finite directed graph.
   Then show by induction on `k`:
   ```lean
   ((W ^ k) a b = 0) ↔ ∃ path of length exactly k from a to b
   ```
   in the min-plus semiring over `ℝ∞` or `WithTop ℕ`.

2. **Impose a rank/layer function** `rank : α → ℕ` with every legal edge increasing rank by `1`.
   Conclude that any path from `s` to `t` has length exactly `rank t - rank s`.

3. **Derive lower bounds**: if acceptance requires traversing `L` layers, then no shorter tropical power can realize acceptance.
   This yields exact depth lower bounds and an intrinsic tropical time-space tradeoff.

Why this is promising: it avoids hard spectral theory initially, uses finite combinatorics and matrix powers that Lean handles well, and still gives a nontrivial theorem with complexity significance.

### Strategy 2: Min-plus closure and shortest-path compression obstruction
This is more ambitious.

1. Define tropical matrix multiplication and closure semantics.
2. Show that any “compressed simulator” preserving zero-cost reachability induces a factorization or domination relation on the original transition matrix.
3. Use width/bottleneck arguments across layers to show low-depth factorization is impossible.

This is promising if you can leverage finite set cardinality, antichains, or cutwidth-like invariants. It could produce a theorem reminiscent of communication complexity lower bounds, but in min-plus algebra.

### Strategy 3: Tropical spectral/cycle-mean theory
This is the most visionary but riskiest.

1. Define cycle mean for finite weighted digraphs.
2. Prove basic lemmas relating powers `W^k` to asymptotic growth rate.
3. Introduce a “gap” invariant and show that if a simulator had too small depth, it would alter the cycle-mean profile, contradicting preservation.

This is likely harder in Lean because tropical spectral theory is not turnkey in Mathlib. Pursue it only after Strategy 1 yields a solid base theorem. If successful, it would be the field-opening result.

---

## How to Build on Catalog Theorems

The listed theorems are not obviously in the same domain, so use them as **structural motifs**, not cosmetic citations.

- `spectral_gap_lower_bound` and `spectral_gap_cf_bounds`:
  use them as precedent for defining and bounding a gap invariant formally. Mirror their style for statements of the form “gap is positive under explicit hypotheses.” If they already package finite spectral inequalities, adapt proof patterns and helper lemmas for positivity / coercions / inequalities.

- `spectral_moment_gap` and `spectral_gap_advantage`:
  likely useful as examples of how the codebase formalizes “gap” as a quantitative obstruction. Reuse naming conventions and theorem architecture to make your tropical spectral invariant fit the catalog’s existing grammar.

- `tropical_and_bound`:
  this is the strongest direct hint that tropical arithmetic infrastructure already exists somewhere in the codebase. Mine its imports and local lemmas. It may already expose min-plus order inequalities, coercions, or helper simp lemmas that make your matrix arguments tractable.

But be intellectually honest: if these theorems do not truly help, do not force them into the proof. Better to produce one authentic bridge lemma than ten fake references.

---

## Cross-Domain Connections You Must Exploit

1. **Automata / Formal Languages**  
   Tropical matrix powers are weighted automaton semantics. Your path-existence theorem is simultaneously a theorem about weighted automata over the min-plus semiring.

2. **Shortest Paths / Operations Research**  
   `W^k` computes exact-`k` path costs. This ties bounded-space computation to dynamic programming and Bellman-type recurrences.

3. **Spectral Graph Theory / Idempotent Analysis**  
   Tropical eigenvalues = minimum cycle means. This is the right language for asymptotic simulation cost and periodicity.

4. **Circuit Complexity**  
   Layer-depth lower bounds for tropical powers resemble depth lower bounds for monotone circuits and branching programs. Make this analogy explicit.

5. **Hamilton–Jacobi / Control Theory**  
   Min-plus linearity governs value functions in deterministic optimal control. A bounded-space machine becomes a discrete control system; acceptance is a terminal-value problem.

These are not decorative. They justify the claim that this work opens a field rather than a file.

---

## Application Keywords

tropical complexity theory, min-plus semiring, bounded-space computation, weighted automata, shortest-path semantics, dynamic programming, branching programs, circuit depth lower bounds, tropical spectral gap, minimum cycle mean, idempotent analysis, control-theoretic computation, formal complexity lower bounds, PSPACE encodings, layered graph obstruction

---

## Concrete Lean 4 Formalization Targets

Prioritize finite, exact, and combinatorial statements first.

### Definitions to implement
- `zeroInfMatrix` for 0/∞ transition matrices over `ℝ∞` or `WithTop ℕ`
- `HasEdge` / `legalStep`
- `ExactPathOfLength`
- `Layered` predicate:
  ```lean
  def Layered {α} (rank : α → ℕ) (W : Matrix α α ℝ∞) : Prop :=
    ∀ a b, W a b = 0 → rank b = rank a + 1
  ```
- optional:
  `tropicalClosureDominates`
  `minimumCycleMean`
  `tropicalSpectralGap`

### Foundational lemmas
- matrix-power/path equivalence for 0/∞ matrices
- monotonicity of reachability under matrix domination
- layered path length rigidity
- cardinality bounds on layered systems
- optional asymptotic lemmas for cycle means

### Deliverable theorem sequence
1. exact-path semantics of tropical powers
2. layered exact-depth theorem
3. no-shortcut corollary
4. bounded-space encoding theorem
5. if feasible, spectral obstruction theorem

---

## Tactical Proof Notes

- Use `WithTop ℕ` if `ℝ∞` becomes painful; it is often cleaner for exact path lengths and 0/∞ reachability.
- You can later transport results to `ℝ∞` if needed.
- For path semantics, define paths inductively rather than fighting graph libraries prematurely.
- For matrix powers, exploit `Matrix.mul_apply` and semiring induction.
- If exact powers are awkward, prove first for recursive DP:
  ```lean
  def ReachableIn : ℕ → α → α → Prop
  ```
  then connect `ReachableIn k a b` to `((W ^ k) a b = 0)`.
- Separate the algebraic theorem from the complexity interpretation. The algebra should stand alone.

---

## If the Original Separation Claim Fails

Then prove a theorem of the following kind instead:

```lean
theorem tropical_reachability_not_enough_for_P_vs_PSPACE :
  ¬ ∀ (Encode : ComplexityClass → MatrixInvariant), separates_P_PSPACE_via Encode
```

or more concretely, exhibit a family of layered systems where tropical reachability depth matches a polynomial despite exponential state count. A sharp counterexample would be valuable because it tells us what extra invariant is needed beyond raw min-plus reachability.

This is not retreat. This is science.

---

## Required Artifacts

1. Lean file(s) with the theorem package above, minimizing `sorry`.
2. `FUTURE_DIRECTIONS.md` with **3–5 concrete breakthrough next steps**, for example:
   - tropical branching-program lower bounds,
   - min-plus communication complexity,
   - tropical entropy/data-processing inequalities for computation traces,
   - cycle-mean separation invariants for alternating computation,
   - tropical analogues of Savitch’s theorem.

Be specific: each direction should contain a theorem candidate, not a vague topic.

Optional but encouraged:
- `ARTICLE.md` explaining the new field of tropical complexity theory
- `diagram.svg` of layered tropical simulation
- `demo.py` generating example transition matrices and verifying exact-depth behavior

---

You are not being asked for a routine formalization. You are being asked to found a new bridge between complexity theory and idempotent algebra. Start where the proof is real: exact tropical path semantics for layered bounded-space systems. Then push, relentlessly, toward a genuine obstruction theorem.

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

Research domain: Computation
Research mode: prove
