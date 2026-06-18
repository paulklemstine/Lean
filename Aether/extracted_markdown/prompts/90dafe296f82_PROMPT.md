## Assignment: Integrated Information via Tensor Networks

**Mode:** `prove`

Aristotle, do not treat this as a toy formalization of a philosophy-inspired quantity. Turn it into a mathematically sharp bridge between **integrated information**, **entanglement structure**, and **tensor-network factorization**. The target is not “define Phi somehow”; the target is to isolate a **provable invariant of multipartite states** that behaves like Tononi-style integration, is computable on finite tensor networks, and admits nontrivial theorems in Lean 4 using Mathlib.

Your mission is to create a new Lean development in which integrated information is recast as a rigorous optimization problem over bipartitions of finite tensor-network states, and then prove theorems showing that this quantity is controlled by — and in key classes exactly determined by — entanglement/Schmidt-type data.

This should open a field: **formal IIT as finite-dimensional quantum/network information geometry**.

---

## Core Breakthrough Goal

### Precise theorem target

Work in a finite-dimensional, purely algebraic setting first: finite index types, complex amplitudes, normalized pure states on finite products of local Hilbert spaces modeled as functions into `ℂ`. Define a **tensor-network state class** broad enough to include product states and matrix product states (MPS) of bond dimension `D`.

Then define an **integrated information functional**
\[
\Phi(\psi) := \min_{\substack{A \subsetneq I\\A\neq \varnothing}}
I_\psi(A : A^c),
\]
where `I_ψ(A : Aᶜ)` is a finite-dimensional pure-state mutual-information surrogate across the bipartition. For pure states, the mathematically clean surrogate is:
- either twice the entanglement entropy if entropy is available,
- or, more Lean-friendly, a **rank/log-rank surrogate** based on the Schmidt rank or matrix flattening rank.

The most promising formal target is the **rank-based integrated information**
\[
\Phi_{\mathrm{rank}}(\psi) := \min_{A \subsetneq I,\; A\neq \varnothing} \log \operatorname{rank}(\mathrm{Flat}_A(\psi)),
\]
or without logarithms if logs are annoying in Lean:
\[
\Phi^\#(\psi) := \min_{A \subsetneq I,\; A\neq \varnothing} \operatorname{rank}(\mathrm{Flat}_A(\psi)).
\]

This is not a compromise — it is the correct algebraic skeleton of IIT in tensor-network language.

---

## Exact formalization target with Lean-style signatures

You should introduce a new definition of bipartition flattening rank for finite tensor states. A plausible Lean 4 architecture is:

```lean
def TensorState (ι : Type _) [Fintype ι] (d : ι → ℕ) :=
  ((∀ i, Fin (d i)) → ℂ)

def Bipartition (ι : Type _) [Fintype ι] :=
  {A : Finset ι // A.Nonempty ∧ A.card < Fintype.card ι}

def flatten
  {ι : Type _} [DecidableEq ι] [Fintype ι]
  (d : ι → ℕ) (A : Finset ι) :
  TensorState ι d → Matrix
    ((∀ i : {j // j ∈ A}, Fin (d i.1)))
    ((∀ i : {j // j ∉ A}, Fin (d i.1)))
    ℂ := ...

def schmidtRank
  {ι : Type _} [DecidableEq ι] [Fintype ι]
  (d : ι → ℕ) (A : Finset ι) (ψ : TensorState ι d) : ℕ := ...

def integratedInfoRank
  {ι : Type _} [DecidableEq ι] [Fintype ι]
  (d : ι → ℕ) (ψ : TensorState ι d) : ℕ := ...
```

If matrix rank over `ℂ` is easier than a true Schmidt decomposition, use flattening matrix rank directly. If needed, define:

```lean
def integratedInfoMinRank
  {ι : Type _} [DecidableEq ι] [Fintype ι]
  (d : ι → ℕ) (ψ : TensorState ι d) : ℕ :=
  sInf {r | ∃ A : Finset ι, A.Nonempty ∧ A.card < Fintype.card ι ∧
    Matrix.rank (flatten d A ψ) = r}
```

A more computable finite version via `Finset.inf'` is probably better.

---

## Theorems you should prove

You must prove **at least 3 substantial theorems**, all with multi-step arguments. The minimum target package is the following:

### Theorem 1: Product states have zero integrated information
This should generalize the existing catalog theorem `product_state_zero_tangle`.

**Mathematical statement**
For any nontrivial multipartite product state `ψ = ⊗ i, ψ_i`, the integrated information rank surrogate is minimal across every nontrivial bipartition; in normalized/log form, `Φ = 0`, and in rank form, `Φ# = 1`.

**Lean-style target**
```lean
theorem integratedInfoRank_product_eq_one
  {ι : Type _} [DecidableEq ι] [Fintype ι] [Nonempty ι]
  (d : ι → ℕ)
  (ψloc : ∀ i, Fin (d i) → ℂ)
  (hcard : 1 < Fintype.card ι) :
  integratedInfoRank d (tensorProductState d ψloc) = 1
```

or in zero-normalized version:

```lean
theorem integratedInfo_log_product_eq_zero
  {ι : Type _} [DecidableEq ι] [Fintype ι] [Nonempty ι]
  (d : ι → ℕ)
  (ψloc : ∀ i, Fin (d i) → ℂ)
  (hcard : 1 < Fintype.card ι) :
  integratedInfoLogRank d (tensorProductState d ψloc) = 0
```

**Why this matters**
This is the formal IIT axiom: mere aggregation is not integration. It upgrades `product_state_zero_tangle` into a multipartite network invariant.

**Catalog leverage**
Build explicitly on:
- `product_state_zero_tangle`
- `dimension_tensor_product`

Use `dimension_tensor_product` to justify the flattening dimensions and the factorization shape of the matrix representing a product state.

---

### Theorem 2: Bipartition rank is bounded by tensor-network bond dimension
For an MPS/tensor-chain state of bond dimension `D`, every cut rank is at most `D`; therefore integrated information is at most `D` (or `log D` in log form).

**Mathematical statement**
If `ψ` is represented by a chain tensor network with internal bond dimensions bounded by `D`, then for every interval cut `A = {0,...,k}`, the flattening rank across `A | Aᶜ` is at most `D`. Consequently,
\[
\Phi^\#(\psi) \le D.
\]

**Lean-style target**
```lean
theorem mps_cut_rank_le_bondDim
  (n d D : ℕ)
  (ψ : TensorState (Fin n) (fun _ => d))
  (hMPS : IsMPSOfBondDim ψ D) :
  ∀ k : Fin (n - 1),
    Matrix.rank (flatten (fun _ : Fin n => d) (Finset.range (k.1 + 1)) ψ) ≤ D
```

and deduce:

```lean
theorem integratedInfoRank_le_bondDim
  (n d D : ℕ)
  (ψ : TensorState (Fin n) (fun _ => d))
  (hMPS : IsMPSOfBondDim ψ D)
  (hn : 2 ≤ n) :
  integratedInfoRank (fun _ : Fin n => d) ψ ≤ D
```

**Why this matters**
This is the first rigorous theorem connecting IIT-style integration to **tensor-network complexity**. It says integration is not mysterious; it is constrained by the network’s internal communication bandwidth.

**Cross-domain significance**
This links:
- consciousness theory / IIT,
- quantum many-body physics,
- communication complexity,
- categorical tensor network semantics.

---

### Theorem 3: Bond-dimension-2 MPS with a full-rank cut has integrated information exactly 2
This is your first exact nontrivial computation theorem.

**Mathematical statement**
If `ψ` is an MPS of bond dimension `2`, and there exists a cut whose flattening matrix has rank `2`, while every nontrivial cut has rank at least `2`, then
\[
\Phi^\#(\psi) = 2.
\]
In log-rank normalization, `Φ = log 2`.

This theorem is the formal backbone of the computational test requested in the brief.

**Lean-style target**
```lean
theorem integratedInfoRank_eq_two_of_bondDimTwo
  (n d : ℕ)
  (ψ : TensorState (Fin n) (fun _ => d))
  (hMPS : IsMPSOfBondDim ψ 2)
  (hn : 2 ≤ n)
  (hupper : integratedInfoRank (fun _ : Fin n => d) ψ ≤ 2)
  (hlower : 2 ≤ integratedInfoRank (fun _ : Fin n => d) ψ) :
  integratedInfoRank (fun _ : Fin n => d) ψ = 2
```

A stronger and better theorem is:

```lean
theorem integratedInfoRank_eq_minCutRank
  (n d : ℕ)
  (ψ : TensorState (Fin n) (fun _ => d))
  (hMPS : IsMPSOfBondDim ψ 2)
  (hn : 2 ≤ n) :
  integratedInfoRank (fun _ : Fin n => d) ψ =
    ((Finset.range (n - 1)).inf' ?hne
      (fun k => Matrix.rank (flatten (fun _ : Fin n => d) (Finset.range (k + 1)) ψ)))
```

and then derive the exact value `2` under a full-rank hypothesis on each cut.

**Why this matters**
This is the first theorem that turns the conjectural slogan “Phi equals minimal mutual information cut” into a **certified finite-dimensional exact statement** for a broad and important tensor-network class.

---

## Strong optional theorem if you can reach it

### Theorem 4: Additivity/subadditivity under tensor product of independent networks
For states `ψ` on `ι` and `φ` on `κ`, define their external tensor product. Then prove either:
- `integratedInfoRank (ψ ⊗ φ) = min (integratedInfoRank ψ) (integratedInfoRank φ)` for rank-surrogate under disconnected system bipartitions, or
- a subadditivity inequality, depending on your exact definition.

A realistic target:

```lean
theorem integratedInfoRank_tensor_prod_le
  ...
  : integratedInfoRank dχη (tensorProdState ψ φ) ≤
      min (integratedInfoRank dψ ψ) (integratedInfoRank dφ φ)
```

This would be a genuine cross-domain bridge to compositional semantics and network science.

---

## Most promising proof architecture

### Strategy A: Flattening-rank formalism via matrices over `ℂ`  — **most promising**
This is likely the best route in Lean.

1. **Encode tensor states as finite functions** and define flattening along a bipartition as a matrix by reindexing coordinates into row/column blocks.
2. **Define integrated information as finite infimum of matrix ranks** over nontrivial bipartitions.
3. Prove:
   - product states flatten to outer-product/rank-1 matrices;
   - MPS flatten through the bond space, giving rank bounded by bond dimension;
   - exactness for bond dimension 2 follows from lower and upper rank bounds.

Why this is best:
- Mathlib already handles finite types, matrices, rank, linear maps, finite sums.
- Avoids analytic quantum entropy machinery.
- Gives a computable invariant immediately.

Key proof moves:
- `rcases` on bipartitions and MPS witnesses,
- induction on chain length for MPS factorization,
- `calc` chains for rank inequalities through linear factorization,
- possibly `by_contra` for lower-bound exactness arguments.

---

### Strategy B: Linear-map factorization / Schmidt-rank formalism
Instead of matrices, treat each bipartition flattening as a linear map
\[
\mathcal{H}_A \to \mathcal{H}_{A^c}
\]
and define `schmidtRank` as `Module.finrank` of the image.

1. Build the flattening as a linear map.
2. Use factorization through the bond space of dimension `D`.
3. Conclude image finrank ≤ `D`.

Why it is attractive:
- Conceptually cleaner and closer to quantum information.
- Might make exact “rank = Schmidt rank” statements cleaner.

Why it is riskier:
- More setup in Lean for finite-dimensional complex vector spaces and image finrank lemmas.

---

### Strategy C: Tensor-category semantics first, matrix semantics second
Define a syntax/semantics for chain tensor networks as compositional diagrams, prove a generic theorem that any cut factors through the internal bond object, then instantiate in finite-dimensional complex vector spaces.

This is the most visionary route, but probably too ambitious for one cycle unless the dynamic context already contains categorical tensor infrastructure.

Best use of this strategy:
- as a conceptual section in `RESEARCH_PAPER.md`,
- with a smaller Lean kernel proving the matrix instantiation.

---

## Required new definitions

You must define at least one genuinely new concept not already in the catalog. Recommended definitions:

1. **`integratedInfoRank`**  
   Finite minimum of flattening ranks over nontrivial bipartitions.

2. **`IsMPSOfBondDim`**  
   A finite witness structure encoding that a state is representable as a chain tensor network with internal bond dimension `D`.

3. **`CutRankProfile`**  
   The function assigning each cut its flattening rank:
   ```lean
   def cutRankProfile ... : Fin (n - 1) → ℕ := ...
   ```

4. **`RankIntegrated` / `PhiFaithful`**  
   A predicate saying a state has positive integrated information:
   ```lean
   def PhiFaithful ... (ψ : TensorState ι d) : Prop :=
     1 < integratedInfoRank d ψ
   ```

This last predicate is mathematically interesting: it formalizes “the state is not decomposable across any nontrivial cut.”

---

## Cross-domain theorem requirement

You must include at least one theorem connecting this domain to another mathematical domain.

### Recommended cross-domain theorem: coding-theoretic bound on integrated information
Use `quantum_singleton_bound` and/or `binary_quantum_hamming_bound` as inspiration to connect code distance / encoded dimension with integrated information of code states or stabilizer tensor networks.

A realistic theorem statement:

**Informal:** If a tensor-network state realizes an encoded stabilizer state with bond dimension `D`, then its integrated information rank is bounded above by a coding-theoretic quantity derived from the number of logical qubits.

**Lean-style aspiration**
```lean
theorem integratedInfoRank_le_codeDimension
  (p : StabilizerCodeParams)
  (hv : p.singletonValid)
  (ψ : TensorState (Fin p.n) (fun _ => 2))
  (henc : IsEncodedByStabilizerCode ψ p) :
  integratedInfoRank (fun _ : Fin p.n => 2) ψ ≤ 2 ^ p.k
```

Even if you cannot complete the full stabilizer theorem, prove a simpler bridge:
- `dimension_tensor_product` implies flattening ambient dimensions,
- hence `integratedInfoRank d ψ ≤ min(dimLeft, dimRight)`.

This is already a cross-domain bridge between tensor networks and finite-dimensional linear algebra / information complexity.

### Simpler guaranteed cross-domain theorem
```lean
theorem integratedInfoRank_le_min_side_dimension
  {ι : Type _} [DecidableEq ι] [Fintype ι]
  (d : ι → ℕ) (A : Finset ι) (ψ : TensorState ι d) :
  Matrix.rank (flatten d A ψ) ≤
    min
      (∏ i : {j // j ∈ A}, d i.1)
      (∏ i : {j // j ∉ A}, d i.1)
```

This connects IIT to **dimension theory / combinatorial geometry of finite products**.

---

## Conjecture with testable prediction

You must state at least one falsifiable conjecture with a concrete computational disproof criterion.

### Primary conjecture
**Conjecture (MPS min-cut Phi principle).**  
For every normalized finite MPS state `ψ` on a chain, the integrated information log-rank equals the minimal log Schmidt rank across contiguous cuts:
\[
\Phi(\psi) = \min_{1 \le k < n} \log \operatorname{rank}(\mathrm{Flat}_k(\psi)).
\]

**Computational test:**  
Enumerate or randomly generate bond-dimension-2 MPS tensors with small local dimension (e.g. `d = 2`, `n = 4,5`), compute all cut flattening ranks numerically in Python, and search for a counterexample where:
- the formally defined `integratedInfoRank` differs from
- the minimum contiguous-cut rank.

A single mismatch falsifies the conjecture.

### Stronger falsifiable conjecture
**Conjecture (IIT–area law bridge).**  
For translation-invariant injective MPS, `integratedInfoRank` stabilizes to the transfer-matrix rank and is independent of chain length once `n ≥ n₀(D)`.

**Disproof criterion:**  
Generate injective bond-dimension-`D` MPS for increasing `n`; if `integratedInfoRank` changes after the proposed threshold, the conjecture is false.

---

## Concrete proof tasks and tactics

Your Lean file must contain at least 3 deep proofs using nontrivial tactics. Here is a good distribution:

1. **Product theorem**
   - use `rcases` on bipartitions,
   - derive explicit factorization of `flatten`,
   - use multi-step `calc` and rank-one arguments.

2. **MPS upper-bound theorem**
   - induction on chain length or recursive decomposition of the network,
   - factor flattening through bond space,
   - use rank inequalities.

3. **Exactness theorem for bond dimension 2**
   - lower bound by contradiction (`by_contra`) or via a “no rank-1 cut” predicate,
   - combine with upper bound in a final `linarith`/`omega`-style arithmetic close if appropriate.

Possible useful tactics:
- `induction' n with n ih`
- `rcases hMPS with ⟨..., hcontract⟩`
- `have hfac : flatten ... = A ⬝ B := ...`
- `calc Matrix.rank (flatten ...) ≤ Matrix.rank A := Matrix.rank_mul_le_left _ _`
- `field_simp` only if scalar normalization introduces denominators
- `by_contra hlt`
- structured `simp` on finite products and `Finset.range`

Do not let the file degrade into definitional unfolding plus `simp`; the proofs must reveal the mathematics.

---

## Suggested file-level architecture

Create a focused new file, for example:

`FINAL/Physics/IntegratedInformationTensorNetworks.lean`

Suggested sections:
1. Finite tensor states and bipartitions
2. Flattenings and cut rank
3. Definition of integrated information rank
4. Product-state vanishing theorem
5. MPS bond-dimension upper bound
6. Exact bond-dimension-2 theorem
7. Cross-domain dimension/code bound
8. Conjectures and computational interface

---

## How to use the catalog theorems

### `product_state_zero_tangle`
Do not merely cite it. Use it as a sanity-check bridge:
- your new invariant should imply vanishing tangle for product states,
- or at least be consistent with it.
In `RESEARCH_PAPER.md`, explicitly explain that your theorem is a multipartite rank-theoretic extension of this certified entanglement-vanishing principle.

### `dimension_tensor_product`
This should be a core lemma in your formal pipeline:
- identify dimensions of left/right Hilbert spaces after bipartition,
- derive ambient matrix sizes for flattenings,
- prove rank upper bounds from side dimensions.

### `quantum_singleton_bound`
Use it as conceptual evidence that global quantum resources obey sharp structural bounds. Even a partial bridge theorem is valuable: integrated information of code states cannot exceed encoded channel capacity / logical dimension in the chosen model.

---

## Revolutionary significance

If you pull this off, you will have done something genuinely new:

- turned a controversial consciousness quantity into a **precise algebraic invariant**;
- connected IIT to **tensor-network complexity**, making it computable and structurally constrained;
- opened a route to **formal consciousness-adjacent science** without handwaving;
- created a framework where one can ask whether integration obeys area laws, code bounds, renormalization principles, or categorical composition rules.

This is not a niche formalization. It creates a mathematical language for comparing:
- entanglement structure,
- network compressibility,
- functional integration,
- and possibly emergent complexity.

---

## Application keywords

Integrated Information Theory, tensor networks, matrix product states, Schmidt rank, mutual information surrogate, finite-dimensional quantum information, entanglement structure, bond dimension, cut rank, tensor categories, stabilizer codes, many-body physics, consciousness quantification, compositional semantics, communication complexity.

---

## Mandatory deliverables

You must produce **all** of the following:

1. **Lean file** with at least 3 nontrivial theorems and minimized sorry usage.
2. **`FUTURE_DIRECTIONS.md`** containing **3–5 falsifiable scientific hypotheses**, each with:
   - a precise conjecture,
   - a clear computational or formal test,
   - an explicit disproof criterion.
3. **`RESEARCH_PAPER.md`** as a **standalone scientific paper**:
   - define the invariant,
   - state the main theorems,
   - explain proof ideas,
   - describe significance and limitations,
   - give next-step research questions.
4. **`ARTICLE.md`** in **Scientific American style**:
   - accessible narrative,
   - why tensor networks and integration matter,
   - what was actually proved,
   - why this could matter beyond mathematics.
5. **A verified algorithm or computational method**:
   - an executable procedure to compute `integratedInfoRank` for small finite states/MPS,
   - formally linked to the definition whenever feasible.
6. **`demo.py`**:
   - generate small bond-dimension-2 MPS examples,
   - compute cut-rank profiles,
   - test the main conjecture numerically,
   - print or visualize counterexample search results.

Do not settle for a decorative definition. Build the invariant, prove structural theorems, and make it computable. The right outcome is a new research program: **formal integrated information as tensor-network min-cut geometry**.

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

Research domain: Physics
Research mode: prove
