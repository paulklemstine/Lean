Soli Deo Gloria

## Assignment: Direction 3: Certified Expander Codes with Linear-Time Decoding

**Mode:** prove

Build a genuinely new formal theory of **certified expander codes from Cayley graphs**, not merely a repackaging of existing LDPC folklore. The target is to turn spectral/vertex-expansion certificates for finite classical groups into **provable coding-theoretic guarantees** and an **executable linear-time decoder**. The breakthrough is to make the passage

> certified group expansion ⟶ certified Tanner expansion ⟶ certified distance ⟶ certified linear-time decoding

fully explicit, quantitative, and reusable.

This is not an incremental coding exercise. If successful, it opens a uniform pathway from algebraic expansion certificates to algorithmically verified error-correcting codes, connecting finite group theory, spectral graph theory, combinatorics, and information theory.

---

## Core Vision

The central mathematical thesis is:

> A certified Cayley expander should not merely be a “good graph”; it should canonically generate a family of Tanner/expander codes whose **rate, distance, and peeling-decoder convergence** can all be proved from the same expansion certificate.

The existing catalog already contains the expansion-side ingredients:
- `Catalog/Algebra/ClassicalGroupExpanders.lean`
  - especially `expansion_neighbor_growth`
  - and `expansion_monotone_of_superset`
- `Catalog/Algebra/MatrixGroupGeneration.lean`
  - especially `span_orbit_eq_top_of_irreducible`

Your task is to build the coding-theoretic superstructure on top of these.

---

## Precise Theorem Targets

You should formalize at least one new file, for example:

- `Blueprint/ExpanderCodes/CertifiedCayleyCodes.lean`

and prove at least **3 substantial theorems** with nontrivial proofs.

### New definitions that must be introduced

You must define at least one genuinely new structure, such as a certified Tanner code package.

Suggested structure:

```lean
structure CertifiedTannerCode (α : Type _) [Fintype α] where
  G : SimpleGraph α
  left right : Finset α
  bipartition :
    Disjoint left right ∧ left ∪ right = Finset.univ
  localCodeDim : ℕ
  localCodeLen : ℕ
  checkNeighbors : α → Finset α
  uniqueNeighborConst : ℚ
  expansionConst : ℚ
  rateLower distanceLower : ℚ
```

or a more graph-local notion:

```lean
structure UniqueNeighborProperty
    {α : Type _} [Fintype α] (G : SimpleGraph α) (c : ℚ) : Prop where
  bound :
    ∀ s : Finset α, s.card ≤ Fintype.card α / 2 →
      c * s.card ≤
        ((s.biUnion fun v => G.neighborFinset v).filter
          (fun w => ((s.filter fun v => w ∈ G.neighborFinset v).card = 1))).card
```

Also define a decoding state / peeling step operator, e.g.

```lean
def peelStep
    {α : Type _} [Fintype α]
    (C : CertifiedTannerCode α) :
    Finset α → Finset α
```

This is essential: the project must include a **verified algorithm**, not just existential theorems.

---

## Exact theorem statements to target

You may refine the constants during formalization, but the following is the right level of precision.

### Theorem 1: Expansion implies unique-neighbor abundance

This is the combinatorial bridge theorem. For a bipartite graph arising from the double cover of a certified Cayley graph, small error sets must have many unique neighbors.

**Mathematical statement.**  
Let `G` be a finite `d`-regular bipartite graph with left part `L` and right part `R`. Assume that for every `S ⊆ L` with `|S| ≤ α |L|`, the neighborhood satisfies
\[
|N(S)| \ge (1+\varepsilon)|S|.
\]
Then the set `U(S)` of right-vertices adjacent to exactly one vertex of `S` satisfies
\[
|U(S)| \ge (2\varepsilon)\,|S|
\]
provided `d` and the normalization hypotheses are chosen so that the standard edge-counting argument closes.

**Lean-style target signature:**
```lean
theorem unique_neighbors_of_expansion
    {α : Type _} [Fintype α] [DecidableEq α]
    (C : CertifiedTannerCode α)
    (hreg : ∀ v, (C.checkNeighbors v).card = C.localCodeLen)
    (hexp :
      ∀ s : Finset α,
        s.card ≤ Fintype.card α / 2 →
        ((s.biUnion C.checkNeighbors).card : ℚ) ≥
          (1 + C.expansionConst) * s.card) :
    ∀ s : Finset α,
      s.card ≤ Fintype.card α / 2 →
      ∃ u : Finset α,
        u ⊆ s.biUnion C.checkNeighbors ∧
        ((u.card : ℚ) ≥ 2 * C.expansionConst * s.card)
```

You may need a more precise definition of `u` as the unique-neighbor set; that is preferable.

**Why this matters.**  
This is the point where a group-expansion certificate becomes a decoding certificate. Without this theorem, the code is just “inspired by expanders.” With it, the code is algorithmically controlled.

---

### Theorem 2: Unique-neighbor abundance implies linear progress of peeling decoding

This is the dynamical theorem. The decoder must shrink the error set by a constant factor each round.

**Mathematical statement.**  
Suppose a Tanner code has the unique-neighbor property:
for every error set `E` of size at most `τN`, at least `β|E|` check nodes are unique neighbors. If each such check identifies a correctable local inconsistency, then one round of peeling/bit-flipping produces an error set `E'` with
\[
|E'| \le (1-\gamma)|E|
\]
for some `γ > 0` depending only on `β` and the local correction threshold. Hence after `O(log N)` rounds the error is eliminated.

**Lean-style target signature:**
```lean
theorem peelStep_strict_contraction
    {α : Type _} [Fintype α] [DecidableEq α]
    (C : CertifiedTannerCode α)
    (γ : ℚ)
    (hγ : 0 < γ)
    (hunique :
      ∀ e : Finset α,
        e.card ≤ Fintype.card α / 2 →
        ((uniqueNeighbors C e).card : ℚ) ≥ γ * e.card) :
    ∀ e : Finset α,
      e.card ≤ Fintype.card α / 2 →
      (peelStep C e).card < e.card
```

A stronger and better version is quantitative:

```lean
theorem peelStep_card_bound
    {α : Type _} [Fintype α] [DecidableEq α]
    (C : CertifiedTannerCode α)
    (γ : ℚ)
    (hγ0 : 0 < γ) (hγ1 : γ ≤ 1)
    (hunique :
      ∀ e : Finset α,
        e.card ≤ Fintype.card α / 2 →
        ((uniqueNeighbors C e).card : ℚ) ≥ γ * e.card) :
    ∀ e : Finset α,
      e.card ≤ Fintype.card α / 2 →
      (((peelStep C e).card : ℚ) ≤ (1 - γ) * e.card)
```

**Why this matters.**  
This theorem upgrades static expansion into algorithmic convergence. It is the formal heart of linear-time decoding.

---

### Theorem 3: Iterated peeling gives logarithmic rounds and linear-time decoding

This is the algorithmic theorem. The previous theorem shows one-step contraction; now derive global runtime.

**Mathematical statement.**  
If each peeling step costs `O(N)` operations and reduces the error set by a fixed multiplicative factor `1-γ`, then exact decoding from any error pattern of size at most `τN` terminates in at most
\[
\left\lceil \frac{\log N}{-\log(1-\gamma)} \right\rceil
\]
rounds, with total work `O(N)` if the per-edge accounting is amortized, or `O(N log N)` in the naïve version. You should strive to verify at least the logarithmic-round bound and then implement an amortized linear-time version in `demo.py`.

**Lean-style target signature:**
```lean
theorem peel_iterate_terminates_logRounds
    {α : Type _} [Fintype α] [DecidableEq α]
    (C : CertifiedTannerCode α)
    (γ : ℚ)
    (hγ0 : 0 < γ) (hγ1 : γ < 1)
    (e : Finset α)
    (hcontract :
      ∀ s : Finset α,
        s.card ≤ Fintype.card α / 2 →
        (((peelStep C s).card : ℚ) ≤ (1 - γ) * s.card)) :
    ∃ k : ℕ,
      k ≤ Nat.ceil (Real.log (Fintype.card α) / (-Real.log (1 - γ))) ∧
      (iteratePeel C k e).card = 0
```

If `Real.log` is too heavy for a first pass, prove a discrete substitute:
there exists `k = O(Fintype.card α)` or `k = O(log (e.card + 1))` such that the decoder terminates. But aim for the logarithmic statement.

**Why this matters.**  
This is where “expander code” becomes “certified decoding algorithm.”

---

### Theorem 4: Cayley expansion induces Tanner-code distance lower bound

This is the coding theorem. Show positive relative distance inherited from expansion.

**Mathematical statement.**  
For a Tanner code built from the bipartite double cover of a certified Cayley graph and a fixed local code of relative distance `δ₀`, there exists `δ > 0` depending only on the expansion constant and `δ₀` such that every nonzero codeword has weight at least `δN`.

**Lean-style target signature:**
```lean
theorem distance_lower_bound_of_cayley_expansion
    {α : Type _} [Fintype α] [DecidableEq α]
    (C : CertifiedTannerCode α)
    (δ₀ ε : ℚ)
    (hδ₀ : 0 < δ₀) (hε : 0 < ε)
    (hlocal : C.localRelativeDistance = δ₀)
    (hexpanded : C.expansionConst = ε) :
    ∃ δ : ℚ, 0 < δ ∧
      ∀ w : Finset α, isCodeword C w → w.Nonempty →
        ((δ : ℚ) * Fintype.card α ≤ w.card)
```

You may need to define `isCodeword`. That is good and expected.

**Why this matters.**  
Rate and distance are the coding-theoretic currency. This theorem shows the group certificate has coding content, not just graph-theoretic content.

---

### Theorem 5: Orbit-spanning generators give nondegenerate parity-check families

Use the catalog theorem `span_orbit_eq_top_of_irreducible` to show that parity checks generated from group orbits are not trapped in a proper subspace.

**Mathematical statement.**  
If a group action on a finite-dimensional vector space is irreducible, then the orbit of any nonzero seed parity-check vector spans the full check space. Hence the resulting family of local constraints is globally nondegenerate.

**Lean-style target signature:**
```lean
theorem parityCheck_span_of_irreducible_orbit
    {K V G : Type _}
    [Field K] [AddCommGroup V] [Module K V]
    [Group G] [DistribMulAction G V]
    [FiniteDimensional K V]
    (v : V)
    (hv : v ≠ 0)
    (hirr : IsIrreducible K G V) :
    Submodule.span K (Set.range fun g : G => g • v) = ⊤
```

If the exact theorem already exists in the catalog, do not duplicate it; instead, build a corollary that explicitly interprets it as a code-construction theorem.

**Why this matters.**  
This is the algebraic mechanism ensuring that group symmetry genuinely generates rich constraint systems.

---

## Lean 4 formalization guidance

You asked for precise theorem statements with Lean signatures. The exact signatures may need adaptation, but keep the following principles:

1. Use `Finset` for executable combinatorics.
2. Use `Fintype.card` for global size bounds.
3. Use `SimpleGraph` or an explicit bipartite graph record.
4. Separate:
   - graph expansion hypotheses,
   - codeword/local constraint definitions,
   - decoder state transition,
   - runtime/termination theorem.

A useful decomposition is:

```lean
structure BipartiteGraph (L R : Type _) [Fintype L] [Fintype R] where
  adj : L → R → Prop
  decAdj : DecidableRel adj

def neighL (B : BipartiteGraph L R) (s : Finset L) : Finset R := ...
def uniqueNeighL (B : BipartiteGraph L R) (s : Finset L) : Finset R := ...

structure LocalLinearCode (q : Type _) [Field q] where
  len : ℕ
  dim : ℕ
  checks : Finset (Fin q → q) -- or a matrix-based encoding
  relDist : ℚ

structure TannerCodeData ... where
  graph : BipartiteGraph L R
  local : LocalLinearCode q
  ...
```

This decomposition will make the algorithm and theorems modular.

---

## Proof strategy architecture

You must include 2–3 viable proof pathways and explain which is most promising.

### Strategy A: Pure combinatorial edge counting from expansion
1. Define the unique-neighbor set `U(S)` and the multiply-covered neighbor set `M(S)`.
2. Double count edges from `S` to `N(S)`:
   \[
   d|S| = \sum_{v \in U(S)} 1 + \sum_{v \in M(S)} \deg_S(v).
   \]
3. Since each `v ∈ M(S)` contributes at least `2`, derive
   \[
   d|S| \ge |U(S)| + 2|M(S)| = 2|N(S)| - |U(S)|.
   \]
4. Rearranging with the expansion lower bound on `|N(S)|` gives a lower bound on `|U(S)|`.

**Why promising:** This is the cleanest formal route. It uses only finite counting, `Finset.card`, disjoint unions, and inequalities. It should be robust in Lean with `calc`, `nlinarith`, and careful cardinality lemmas.

---

### Strategy B: Spectral-to-vertex route via certified Cayley expansion
1. Start from the certified spectral or neighbor-growth theorem in `ClassicalGroupExpanders.lean`.
2. Pass from Cayley graph expansion to bipartite double-cover expansion.
3. Transfer expansion to the Tanner graph and then invoke Strategy A as a black box.

**Why promising:** This gives the true “certified Cayley graph” theorem, rather than merely an abstract graph theorem. It uses the catalog exactly as intended. This is likely the most scientifically important route.

**Why harder:** The double-cover formalization and transfer lemmas may require more setup.

---

### Strategy C: Potential-function analysis of decoding
1. Define a potential function `Φ(E) = |E|`.
2. Show each peeling step identifies a family of locally inconsistent checks whose corrections decrease `Φ`.
3. Prove geometric decay:
   \[
   Φ(E_{t+1}) \le (1-\gamma) Φ(E_t).
   \]
4. Deduce logarithmic rounds by induction on `t`.

**Why promising:** This is the best route for the algorithmic theorem. It naturally produces executable code and complexity statements.

**Most promising overall:**  
Use **Strategy B + Strategy A + Strategy C** in sequence:
- B to get expansion from the catalog,
- A to convert expansion into unique-neighbor abundance,
- C to prove decoding convergence.

That is the field-opening architecture.

---

## Cross-domain connections you must make explicit

At least one theorem and the paper narrative must connect coding theory to another domain.

### 1. Finite group theory + information theory
Certified Cayley graphs on `Sp_{2n}(𝔽_q)` or `GL₂(𝔽_p)` become explicit communication primitives. The spectral gap of a group action is reinterpreted as a robustness margin for information transmission.

### 2. Representation theory + parity-check generation
Use `span_orbit_eq_top_of_irreducible` to show that irreducible group orbits generate globally expressive parity-check systems. This reframes parity-check design as an orbit-spanning problem in representation theory.

### 3. Statistical physics + decoding dynamics
The peeling/bit-flipping decoder can be described as a discrete energy descent process on a sparse constraint system. The contraction theorem resembles a zero-temperature Glauber dynamics argument: expansion forbids metastable trapped states below a threshold.

### 4. Geometry of classical groups + explicit constructions
The conjectural `Sp_{2n}(𝔽_q)` family links symplectic geometry over finite fields to explicit good codes. This is a striking bridge: symmetries preserving bilinear forms become mechanisms for fault tolerance.

Include at least one formal theorem or definition that makes one of these bridges concrete.

---

## Conjecture with testable prediction

State and isolate a falsifiable conjecture.

### Conjecture: Certified Cayley-vs-random finite-length advantage
For the Tanner codes built from certified Cayley graphs of `GL₂(𝔽_p)` with the same block length and rate as a random regular LDPC baseline, there exists a moderate noise regime `η ∈ [η₁, η₂]` such that the certified Cayley code has strictly smaller block error probability under peeling/bit-flipping decoding.

A concrete formal wrapper can be non-axiomatic, e.g. as a `def`/`theorem?` placeholder in comments or markdown, but it must include:

- tested primes `p = 3, 5, 7, 11`,
- BSC and AWGN channels,
- measured failure rate curves,
- criterion for refutation:
  if no tested prime/rate pair exhibits a lower empirical failure rate in the prescribed regime, the conjecture is false in its current form.

This is scientifically important because it makes the project experimentally falsifiable, not just theoretically aspirational.

---

## Required implementation and algorithmic deliverables

You must produce all of the following.

### 1. Verified algorithm / computational method
Implement a concrete decoder:
- Sipser–Spielman bit-flipping, or
- Zémor-style iterative decoding, or
- a simplified peeling decoder on the Tanner graph.

It must be connected to the formal definitions. Even if the full asymptotic runtime proof remains abstract, the algorithm itself must be executable and validated on examples.

### 2. `demo.py`
This must:
- construct Cayley graphs for `GL₂(𝔽_p)` for `p = 3, 5, 7, 11`,
- build the bipartite double cover / Tanner graph,
- instantiate a local code,
- run the decoder on BSC and AWGN corruption,
- plot or print failure rates vs noise,
- compare against a standard LDPC code of similar length/rate.

The demo should make the falsifiable conjecture genuinely testable.

---

## Suggested theorem dependency graph

1. Define bipartite/Tanner structures and unique-neighbor sets.
2. Prove counting lemmas for neighborhood decomposition.
3. Import expansion bounds from `ClassicalGroupExpanders.lean`.
4. Derive unique-neighbor abundance.
5. Define codewords and decoder step.
6. Prove one-step contraction.
7. Prove iterative convergence / round bound.
8. Use `span_orbit_eq_top_of_irreducible` to prove orbit-generated nondegeneracy.
9. State and test the `GL₂(𝔽_p)` conjecture experimentally.

This dependency graph is ideal because each theorem feeds the next, producing a coherent research artifact rather than isolated lemmas.

---

## Tactics and proof style requirements

Mandatory:
- At least 3 theorems must use substantial proof structure such as:
  - `induction`
  - `rcases`
  - `by_contra`
  - `field_simp`
  - multi-step `calc`
- Avoid trivial closure by `native_decide`, `decide`, `norm_num`, `rfl` unless the statement itself is profound.
- Minimize `sorry`; if one remains, isolate it to the hardest asymptotic bridge rather than the core combinatorics.

The most likely nontrivial tactic profile:
- `rcases` for decomposition of neighborhood types,
- `calc` for cardinality inequalities,
- `by_contra` for proving strict decoder progress,
- induction on iteration count for logarithmic-round convergence.

---

## Catalog building blocks and how to use them

### `Catalog/Algebra/ClassicalGroupExpanders.lean`
Use:
- `expansion_neighbor_growth`
  - as the source of explicit lower bounds on neighborhood size for small vertex sets;
  - this should be the direct hypothesis feeding the unique-neighbor theorem.
- `expansion_monotone_of_superset`
  - to move from certified generating sets to enlarged generating/check neighborhoods without losing expansion control.

### `Catalog/Algebra/MatrixGroupGeneration.lean`
Use:
- `span_orbit_eq_top_of_irreducible`
  - to prove that orbit-generated parity-check templates span the full intended check space;
  - interpret this as a theorem preventing degeneracy of the generated code family.

Do not merely cite these. Build the new coding statements explicitly from them.

---

## Revolutionary significance

If you complete this direction well, the result is not “another expander code formalization.” It is the beginning of a new synthesis:

- **Group certificates become code certificates.**
- **Representation-theoretic irreducibility becomes parity-check richness.**
- **Spectral/vertex expansion becomes algorithmic decodability.**

This opens several fields at once:
- explicit algebraic coding theory from classical groups,
- certified moderate-block-length communication design,
- symmetry-based decoder analysis,
- a new interface between finite group expansion and information theory.

It also creates a platform for follow-on work:
- quantum LDPC analogues from symplectic groups,
- list decoding and soft decoding on certified Cayley complexes,
- derandomized code design using representation theory,
- finite-length performance theory for algebraically generated sparse codes.

---

## Application keywords

Certified expander codes; Cayley graphs; Tanner codes; LDPC; Sipser–Spielman decoding; Zémor decoding; unique-neighbor expansion; spectral gap; finite classical groups; `Sp_{2n}(𝔽_q)`; `GL₂(𝔽_p)`; representation theory; orbit spanning; parity-check matrices; linear-time decoding; moderate block length; BSC; AWGN; explicit constructions; information theory; sparse graph codes; combinatorial decoding; statistical physics of decoding; quantum LDPC inspiration.

---

## Mandatory deliverables

You must produce ALL of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial proved theorems described above.
2. **A verified algorithm or computational method** implementing the decoder.
3. **`demo.py`** demonstrating the construction and decoding experiments interactively.
4. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - define the code construction,
   - state the main theorems clearly,
   - explain why certified Cayley expansion matters,
   - include the conjecture and experimental findings,
   - discuss limitations and next questions.
5. **`ARTICLE.md`** in Scientific American style:
   - explain how symmetry and expansion create reliable communication,
   - focus on the ideas and significance,
   - do **not** focus on formal verification machinery.
6. **`FUTURE_DIRECTIONS.md`** with 3–5 original research directions.
   - Each direction must include the exact sentences:
     - **“The key insight is...”**
     - **“Why now?”**
   - At least one direction must bridge to a different domain, such as quantum codes, statistical mechanics, or arithmetic combinatorics.

The objective is not to formalize a known theorem in isolation. The objective is to found a reusable theory of **certified algebraic expander codes with provable decoding dynamics**.

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
