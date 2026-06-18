## Assignment: Conjecture 1: MPS Min-Cut Principle

**Mode:** prove

Prove a genuinely new theorem package around the **Matrix Product State min-cut principle**, aiming not merely to verify a folklore tensor-network fact but to formalize a structural bridge between **quantum many-body entanglement**, **tensor rank theory**, and **graph/min-cut combinatorics**.

The target is a field-opening result: that for 1D tensor network states, the globally defined “integrated information rank” over all bipartitions is governed by the geometry of the chain itself, and therefore collapses to a **contiguous bottleneck invariant**. If successful, this becomes a rigorous theorem-schema for why one-dimensional quantum complexity is controlled by local cuts, and it opens the door to formal analogues for **tree tensor networks, PEPS obstructions, entanglement area laws, causal graphical models, and network coding lower bounds**.

---

## Core Mathematical Objective

Let `ψ : (Fin n → α) → 𝕜` be a finite pure state tensor on a chain of length `n`, over a field `𝕜`, with local alphabet/type `α` finite. For each nontrivial subset `S : Finset (Fin n)`, let `flatRank ψ S` denote the rank of the matricization/flattening of `ψ` across the bipartition `S | Sᶜ`. Define the integrated information rank

\[
\Phi^\#(\psi) := \min_{\varnothing \neq S \subsetneq \{0,\dots,n-1\}} \operatorname{flatRank}(\psi,S).
\]

For MPS states, conjecturally this minimum is always attained by a contiguous prefix cut.

### Precise breakthrough theorem to target

> **Theorem (MPS contiguous min-cut principle).**  
> Let `ψ` be a matrix product state on a line of length `n`, with bond dimensions `D₀, …, Dₙ` and open boundary conditions. Then for every nontrivial bipartition `S`,  
> \[
> \operatorname{flatRank}(\psi,S)\ \ge\ \min_{e \in \partial S}\, D_e,
> \]
> where `∂S` is the set of chain edges crossing the cut induced by `S`. Consequently,
> \[
> \Phi^\#(\psi) \ge \min_{1\le k < n} D_k.
> \]
> Moreover, if `ψ` is bond-generic (or brought into a suitable canonical form with full-rank transfer data), then equality holds:
> \[
> \Phi^\#(\psi)= \min_{1\le k<n}\operatorname{flatRank}(\psi,\{0,\dots,k-1\})
> = \min_{1\le k<n} D_k.
> \]

This is much stronger than the raw conjecture as stated: it identifies the true mechanism. The noncontiguous cut cannot do better because on a chain, every bipartition must cross at least one chain edge, and the MPS contraction structure funnels all inter-part correlations through those edge bonds.

---

## Lean 4 formalization target

You should introduce a clean abstraction rather than overcommitting to full physics notation. Formalize finite tensors and flattening rank for subset bipartitions, then a line-MPS structure with bond dimensions.

A plausible Lean 4 theorem signature to aim for is:

```lean
theorem mps_flatRank_ge_contiguousMinCut
  {𝕜 : Type*} [Field 𝕜]
  {n d : ℕ}
  (ψ : LineMPS 𝕜 n d)
  (S : Finset (Fin n))
  (hS1 : S.Nonempty)
  (hS2 : S.card < n) :
  contiguousMinCutRank ψ ≤ flatRank ψ.toTensor S
```

and then the main corollary

```lean
theorem mps_integratedInfo_eq_min_contiguous
  {𝕜 : Type*} [Field 𝕜]
  {n d : ℕ}
  (ψ : LineMPS 𝕜 n d)
  (hgeneric : BondGeneric ψ) :
  integratedInfoRank ψ.toTensor
    = contiguousMinCutRank ψ
```

If the full equality is too ambitious initially, prove the robust one-sided theorem first:

```lean
theorem mps_integratedInfo_ge_min_contiguous
  {𝕜 : Type*} [Field 𝕜]
  {n d : ℕ}
  (ψ : LineMPS 𝕜 n d) :
  contiguousMinCutRank ψ ≤ integratedInfoRank ψ.toTensor
```

and separately prove realizability on contiguous cuts:

```lean
theorem mps_prefix_flatRank_eq_bondDim
  {𝕜 : Type*} [Field 𝕜]
  {n d : ℕ}
  (ψ : LineMPS 𝕜 n d)
  (k : Fin (n - 1))
  (hcanon : LeftRightCanonicalAt ψ k) :
  flatRank ψ.toTensor (Finset.Icc 0 k |> ???) = ψ.bondDim (k.1 + 1)
```

You may need to adapt exact signatures to the available Mathlib tensor/matrix API, but the theorem statements must remain mathematically this precise.

---

## Novel definitions required

Define at least one genuinely new concept, and preferably several:

1. **`contiguousCut` / `isContiguousSubset`**  
   A subset of `Fin n` that is an interval/prefix/suffix in the chain order.

2. **`integratedInfoRank`**  
   The minimum flattening rank over all nontrivial bipartitions.

3. **`contiguousMinCutRank`**  
   The minimum flattening rank over contiguous prefix cuts only.

4. **`LineMPS`**  
   A mathematical structure encoding a 1D open-boundary matrix product state with local dimension and bond dimensions.

5. **`BondGeneric`** or **`CanonicalSaturated`**  
   A hypothesis ensuring flattening rank along a bond actually achieves the bond dimension.

These definitions are not cosmetic; they are the conceptual payload of the project.

---

## Minimum theorem package: at least 3 substantial theorems

Your file must contain at least **three** nontrivial theorems with real proof architecture. Suggested theorem suite:

### Theorem A: Noncontiguous cuts dominate a chain edge bottleneck
For any subset `S`, if `S` is nontrivial, then some chain edge crosses the cut, and the flattening rank is bounded below by the minimum bond dimension on crossing edges.

Possible Lean target:
```lean
theorem flatRank_ge_edge_bottleneck
  {𝕜 : Type*} [Field 𝕜]
  {n d : ℕ}
  (ψ : LineMPS 𝕜 n d)
  (S : Finset (Fin n))
  (hS1 : S.Nonempty)
  (hS2 : S.card < n) :
  edgeCutMinBond ψ S ≤ flatRank ψ.toTensor S
```

### Theorem B: Prefix cuts realize bond dimensions in canonical/generic form
For each internal bond `k`, the flattening rank across the prefix cut equals the bond dimension there.

Possible Lean target:
```lean
theorem prefix_flatRank_eq_bondDim
  {𝕜 : Type*} [Field 𝕜]
  {n d : ℕ}
  (ψ : LineMPS 𝕜 n d)
  (k : ℕ)
  (hk1 : 1 ≤ k)
  (hk2 : k < n)
  (hcanon : CanonicalSaturatedAt ψ k) :
  flatRank ψ.toTensor (prefixCut n k) = ψ.bondDim k
```

### Theorem C: Integrated information rank equals contiguous min-cut
Combine A and B to obtain the main theorem.

Possible Lean target:
```lean
theorem integratedInfoRank_eq_contiguousMinCutRank
  {𝕜 : Type*} [Field 𝕜]
  {n d : ℕ}
  (ψ : LineMPS 𝕜 n d)
  (hgen : BondGeneric ψ) :
  integratedInfoRank ψ.toTensor = contiguousMinCutRank ψ
```

### Optional Theorem D: Cross-domain graph reformulation
Show that for line tensor networks, integrated information rank coincides with a graph-theoretic min-cut capacity invariant.

```lean
theorem integratedInfoRank_eq_lineGraphMinCut
  {𝕜 : Type*} [Field 𝕜]
  {n d : ℕ}
  (ψ : LineMPS 𝕜 n d)
  (hgen : BondGeneric ψ) :
  integratedInfoRank ψ.toTensor = lineGraphMinCutCapacity ψ
```

This is the theorem that makes the result conceptually explosive: it reframes a quantum entanglement quantity as a combinatorial min-cut invariant.

---

## Proof strategy architecture

You must provide and pursue at least 2–3 proof routes. Do not rely on a single brittle tactic path.

### Strategy 1: Factorization-through-crossing-bonds approach
**Most promising.**

1. For a given bipartition `S`, explicitly refactor the MPS contraction into:
   - a left tensor block,
   - one or more crossing bond spaces,
   - a right tensor block.
2. Show the flattening matrix factors through the tensor product of crossing bond spaces.
3. Deduce rank inequalities from matrix factorization:
   \[
   \operatorname{rank}(AB) \le \min(\operatorname{rank}(A),\operatorname{rank}(B)),
   \]
   and hence the flattening rank cannot be smaller than the bottleneck rank once canonical saturation/genericity is imposed appropriately.
4. For contiguous prefix cuts, the factorization is exact across a single bond, giving equality with bond dimension under canonical hypotheses.

Why this is promising: it mirrors the actual tensor-network mechanism and should align best with Lean’s linear algebra API, because rank inequalities for compositions of linear maps are already natural to formalize.

### Strategy 2: Induction on chain length with cut-combinatorics
1. Prove a combinatorial lemma: every nontrivial subset of `Fin n` has at least one boundary edge, and noncontiguous subsets have at least two.
2. Induct on `n`, peeling off one site from either boundary.
3. Track how flattening rank behaves under adding/removing a terminal tensor and under reindexing subsets.
4. Show that any putative minimizing noncontiguous cut induces a smaller chain contradiction or reduces to a contiguous witness.

Why useful: this gives a structurally elegant theorem and naturally uses induction/`rcases`/case splits, satisfying the depth requirement. It may also expose stronger statements, e.g. noncontiguous cuts are “strictly more expensive” in generic settings.

### Strategy 3: Graphical calculus / transfer operator route
1. Encode the MPS as a path graph tensor network.
2. Interpret a bipartition flattening as a contraction map across cut edges.
3. Use a graph min-cut/max-flow style rank bound specialized to path graphs.
4. Deduce that the minimum over all cuts equals the minimum single-edge cut.

Why revolutionary: this directly links tensor networks to network coding and combinatorial optimization. If you can formalize even a weak version, it opens a new Lean-verified interface between quantum information and graph theory.

---

## Cross-domain connections you must exploit

This project must not remain isolated in tensor-network language. Build at least one theorem and one discussion thread connecting to another domain.

### 1. Quantum information ↔ graph theory
The path-graph structure of an MPS suggests a **min-cut principle** analogous to network flow. Formalize this relation where possible.

### 2. Tensor rank theory ↔ communication complexity
A flattening rank lower bound across a bipartition is a communication bottleneck. The theorem says that for 1D MPS, the hardest communication bottleneck is always contiguous. This is conceptually striking and worth stating explicitly.

### 3. Quantum many-body physics ↔ integrated information / complexity science
Your `integratedInfoRank` is an IIT-style global integration invariant, but the theorem shows that for 1D low-complexity quantum states, “global integration” reduces to local bond bottlenecks. This is a mathematically precise bridge between consciousness-inspired information measures and condensed matter tensor networks.

### 4. Algebraic complexity ↔ entanglement geometry
Flattening ranks are classical tools in algebraic complexity and secant geometry. The result says line-network tensors have an extremal rank geometry controlled by interval cuts. This suggests extensions to tree tensor networks and obstructions for PEPS.

---

## Concrete proof ingredients to look for in Mathlib

You mentioned existing verified theorems beginning with `reduction_ter...`; build on any available catalog results about:
- matrix rank under multiplication/composition,
- finite-dimensional linear maps,
- `Finset` subset combinatorics on `Fin n`,
- interval/prefix lemmas on finite ordered types,
- rank inequalities (`LinearMap.rank_comp_le*`, matrix rank bounds, etc.),
- reindexing equivalences for finite products/functions,
- tensor product or multilinear-map encodings, if available.

If full tensor-product infrastructure is cumbersome, encode a state as a function on `Fin n → Fin d` and define flattening as a matrix indexed by restrictions to `S` and `Sᶜ`. This is entirely respectable and may be the right Lean-native route.

---

## Computational falsifiability requirement

State and support the conjecture with a computational test that could refute it:

> **Falsifiable conjecture.** For every randomly generated open-boundary MPS over `ℚ` or `ℂ` with chain length `n ≤ 8` and bond dimensions in `{2,3,4,5}`, exhaustive enumeration of all nontrivial bipartitions yields
> \[
> \Phi^\#(\psi)=\min_{1\le k<n}\operatorname{flatRank}(\psi,\{0,\dots,k-1\}).
> \]
> A single counterexample with strictly smaller noncontiguous-cut rank falsifies the conjecture.

Strengthen this with a second testable prediction:

> **Generic strictness hypothesis.** For bond-generic MPS, every noncontiguous bipartition `S` satisfies
> \[
> \operatorname{flatRank}(\psi,S)\ge \max_{e\in \partial S} c_e
> \quad\text{or even}\quad
> \operatorname{flatRank}(\psi,S)\ge \prod_{e\in\partial S} D_e^{\text{eff}}
> \]
> in an appropriate effective-rank sense.
> Test numerically whether noncontiguous cuts are typically strictly larger than the best contiguous cut.

This is scientifically valuable even if the stronger form fails.

---

## Deliverables you must produce

You must produce **all** of the following:

1. **Lean file(s)** with the new definitions and at least 3 substantial theorem proofs, minimizing `sorry`.
2. **A verified algorithm or computational method** for:
   - constructing flattenings for arbitrary bipartitions,
   - computing `integratedInfoRank`,
   - computing contiguous-cut minima for MPS,
   - comparing them.
3. **`demo.py`** that interactively:
   - samples random MPS instances,
   - enumerates bipartitions,
   - computes all flattening ranks,
   - highlights whether the minimizer is contiguous,
   - reports any counterexample found.
4. **`FUTURE_DIRECTIONS.md`** with **3–5 falsifiable scientific hypotheses**, each with:
   - a precise statement,
   - a concrete computational or formal test,
   - what outcome would falsify it.
5. **`RESEARCH_PAPER.md`** as a standalone scientific paper:
   - full problem statement,
   - definitions,
   - theorem statements,
   - proof ideas,
   - significance,
   - limitations,
   - next questions.
6. **`ARTICLE.md`** in Scientific American style:
   - explain why a global quantum-information quantity collapsing to a local cut invariant is surprising,
   - relate it to quantum simulation, entanglement, and networks.

---

## Application keywords

Use and emphasize these throughout the writeup and paper:

**tensor networks, matrix product states, flattening rank, bipartition rank, min-cut principle, entanglement bottleneck, canonical form, transfer matrix, graph cut, network coding, communication complexity, integrated information, quantum many-body systems, algebraic complexity, finite-dimensional linear algebra, formal verification, Lean 4**

---

## What would make this revolutionary

If you prove the main theorem cleanly, you have formalized a principle that physicists use implicitly but rarely state in this exact optimization language:

- a global minimization over exponentially many bipartitions
- collapses to a linear scan over contiguous cuts
- because the tensor network geometry enforces a hidden min-cut law.

That is not a small extension. It is the beginning of a **verified calculus of entanglement bottlenecks**.

And the real prize is beyond MPS: once the line case is formalized, the next frontier is to ask whether tree tensor networks satisfy an analogous subtree-cut principle, and whether PEPS fail in precisely characterizable ways. That becomes a new formal research program at the interface of **quantum information, combinatorics, and theorem proving**.

Be bold: prove the strongest correct theorem you can, and if the full conjecture resists, isolate the exact genericity or canonical-form hypotheses under which it becomes true.

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

Research domain: Speculative
Research mode: prove
