Soli Deo Gloria

## Assignment: Quantum Error Correction Bounds Beyond the Catalog

**Mode:** prove

You are not being asked to re-prove known inequalities in isolation. You are being asked to turn the existing verified Singleton/Hamming infrastructure into a **structural theory of quantum code feasibility and topological optimality**. The breakthrough target is to formalize not just bounds, but the **geometry of when bounds can simultaneously hold, fail, or force degeneracy/topology**.

The catalog already contains certified versions of:
- `quantum_singleton_bound` for stabilizer parameters
- `binary_quantum_hamming_bound` for nondegenerate binary quantum codes
- `quantum_singleton_bound` for toric-code style lattice parameters

Your mission is to synthesize these into a new layer of theory that answers:

> **When do the known bounds jointly forbid a code, force degeneracy, or certify topological asymptotics?**

That is a qualitatively stronger contribution than “another proof of the Singleton bound.” It begins to look like a **feasibility theory for quantum code design**, with immediate implications for stabilizer search, topological quantum computing, and asymptotic coding heuristics.

---

## Core Breakthrough Objective

Define a new notion of **bound-feasible quantum parameters** and prove that the interaction of the Singleton and Hamming bounds creates a sharp obstruction region. Then connect this obstruction theory to topological code families, especially toric-style codes, showing that geometric constructions sit on a provable tradeoff frontier.

This opens a field-facing direction: a **formally verified design calculus for quantum codes**, where one can algorithmically filter impossible parameter regimes before attempting construction.

---

## New Definitions You Must Introduce

At least one genuinely new concept is mandatory. Introduce these:

### 1. Joint bound feasibility
A parameter tuple is jointly feasible with respect to known universal bounds if it satisfies both Singleton and Hamming admissibility inequalities.

Suggested Lean-facing structure:
```lean
structure QuantumCodeProfile where
  n : ℕ
  k : ℕ
  d : ℕ
  deriving DecidableEq, Repr

def singletonAdmissible (p : QuantumCodeProfile) : Prop :=
  p.k + 2 * (p.d - 1) ≤ p.n

def hammingRadius (p : QuantumCodeProfile) : ℕ :=
  (p.d - 1) / 2

def hammingAdmissibleBinary (p : QuantumCodeProfile) : Prop :=
  ∑ i in Finset.range (p.hammingRadius + 1), (Nat.choose p.n i) * 3^i ≤ 2^(p.n - p.k)

def jointlyBoundFeasible (p : QuantumCodeProfile) : Prop :=
  singletonAdmissible p ∧ hammingAdmissibleBinary p
```

### 2. Bound-forced degeneracy
A parameter tuple is **degeneracy-forcing** if it satisfies Singleton admissibility but violates the nondegenerate Hamming bound. This captures a mathematically meaningful obstruction: any code realizing such parameters cannot be nondegenerate.

```lean
def degeneracyForcing (p : QuantumCodeProfile) : Prop :=
  singletonAdmissible p ∧ ¬ hammingAdmissibleBinary p
```

This is conceptually new and scientifically important: it extracts a theorem from the gap between two classical bounds.

### 3. Topological asymptotic family
Introduce a simple abstract family for topological codes:
```lean
structure QuantumCodeFamily where
  n : ℕ → ℕ
  k : ℕ → ℕ
  d : ℕ → ℕ
```

Then define a rate-distance product:
```lean
def rate (F : QuantumCodeFamily) (L : ℕ) : ℚ :=
  (F.k L : ℚ) / (F.n L : ℚ)

def relDist (F : QuantumCodeFamily) (L : ℕ) : ℚ :=
  (F.d L : ℚ) / (F.n L : ℚ)
```

You need not solve asymptotic coding theory in full generality; instead prove rigorous finite inequalities and then derive asymptotic corollaries for toric-style families already present in the catalog.

---

## Precise Theorem Targets

You must prove **at least 3 nontrivial theorems**, and they should be architected around the following statements.

### Theorem 1: Hamming violation forces degeneracy
This is the cleanest new theorem enabled by the catalog.

**Mathematical statement**
For any binary quantum code parameters `p`, if the Singleton bound holds but the binary quantum Hamming inequality fails, then no realization of `p` can be nondegenerate.

In words: **the gap between universal admissibility and sphere-packing admissibility is exactly a degeneracy-forcing region**.

**Suggested Lean 4 signature**
```lean
theorem hamming_violation_forces_degeneracy
    (p : CodeParams)
    (hs : p.singletonValid)
    (hhfail : ¬ (
      ∑ i in Finset.range (((p.d - 1) / 2) + 1), (Nat.choose p.n i) * 3^i ≤ 2^(p.n - p.k)
    )) :
    ¬ NondegenerateCode p
```

If `CodeParams` already packages the Hamming radius or validity assumptions differently, adapt the signature to the actual catalog API. The essential logical shape must remain:
```lean
¬ HammingAdmissible → ¬ NondegenerateCode
```
by contrapositive from `binary_quantum_hamming_bound`.

**Why this is a breakthrough**
This theorem upgrades a one-way bound into a **structural classification principle**. It tells you not just that some nondegenerate code cannot exist, but that any hypothetical realization must exploit degeneracy. That is a meaningful design theorem for quantum fault tolerance.

---

### Theorem 2: Joint feasibility region implies an explicit upper bound on correctable radius
Combine Singleton and Hamming constraints into a derived quantitative tradeoff.

**Mathematical statement**
For any jointly bound-feasible profile `(n,k,d)`, the correctable radius `t = ⌊(d-1)/2⌋` satisfies an explicit upper bound depending on `n-k`, obtained from the Hamming sphere-packing inequality. At minimum, prove a monotone consequence such as:
- if `jointlyBoundFeasible p`, then `t ≤ n - k`
or a stronger inequality derived from the first nontrivial summand:
- since `1 + 3n ≤ 2^(n-k)` whenever `t ≥ 1`, conclude a logarithmic obstruction.

A robust formal target is:

**Suggested Lean 4 signature**
```lean
theorem jointly_feasible_radius_bound
    (p : QuantumCodeProfile)
    (hjoint : jointlyBoundFeasible p)
    (ht : 1 ≤ hammingRadius p) :
    1 + 3 * p.n ≤ 2^(p.n - p.k)
```

This follows because the Hamming sum contains at least the `i=0` and `i=1` terms whenever radius ≥ 1.

Then derive a corollary:

```lean
theorem jointly_feasible_distance_log_obstruction
    (p : QuantumCodeProfile)
    (hjoint : jointlyBoundFeasible p)
    (hd : 3 ≤ p.d) :
    1 + 3 * p.n ≤ 2^(p.n - p.k)
```

**Why this matters**
This theorem turns the abstract Hamming bound into a **fast computable obstruction certificate**. It is algorithmically valuable because one can reject parameter regimes using only a tiny prefix of the sphere-packing sum. This is exactly the kind of verified pruning principle that can drive code search.

---

### Theorem 3: Toric/topological codes satisfy a geometric rate-distance tradeoff
Use the toric-code theorem in the catalog to derive a finite tradeoff theorem in normalized form.

For toric-style codes, the known parameter pattern is morally `[[2L^2, 2, L]]` (depending on the formalization). Use the catalog’s toric `quantum_singleton_bound` to prove a normalized statement such as:

**Mathematical statement**
For toric-family parameters, the product of rate and relative distance decays at least on the order of `1/n`, and in particular cannot simultaneously stay bounded away from zero. This formalizes a key topological tradeoff.

**Suggested Lean 4 signature**
```lean
theorem toric_rate_relDist_product_bound
    (L : ℕ) (hL : 1 ≤ L) :
    ((2 : ℚ) / (2 * L^2)) * ((L : ℚ) / (2 * L^2))
      ≤ (1 : ℚ) / L^2
```

If the toric code parameters are already defined in the catalog, formulate the theorem directly in terms of those definitions instead of hardcoding formulas.

A stronger and more conceptual version:
```lean
theorem toric_family_not_asymptotically_good
    (L : ℕ) (hL : 1 ≤ L) :
    ((toricK L : ℚ) / toricN L) * ((toricD L : ℚ) / toricN L) ≤ (1 : ℚ) / L^2
```

**Why this is important**
This creates a verified bridge between **quantum coding theory and topological order**: topology gives robustness, but geometric locality constrains asymptotic efficiency. This is one of the central ideas in topological quantum computing.

---

## Optional Fourth Theorem: Singleton equality implies maximal encoded dimension
If you can access or define a suitable profile notion, prove a rigidity statement for MDS-like quantum parameters.

**Suggested statement**
```lean
theorem singleton_equality_characterizes_maximal_k
    (p : QuantumCodeProfile)
    (h : p.k + 2 * (p.d - 1) = p.n) :
    p.k = p.n - 2 * (p.d - 1)
```

This looks simple algebraically, but make it part of a larger theorem package about extremal profiles. On its own it is too weak; as part of an “extremal parameter” namespace it becomes useful infrastructure for later constructions.

---

## Proof Strategy Architecture

You must not give Aristotle a single narrow route. Here are three viable approaches.

### Strategy A: Contrapositive extraction from catalog bounds
**Most promising for Theorem 1.**
1. Import the certified `binary_quantum_hamming_bound`.
2. Assume `NondegenerateCode p`.
3. Apply the catalog theorem to obtain the Hamming inequality, contradicting `hhfail`.
4. Conclude `¬ NondegenerateCode p` by `by_contra` or direct implication.

Why promising: this is structurally clean, uses existing trusted results, and turns a one-way theorem into a new classification theorem with minimal API friction.

### Strategy B: Prefix-of-sum lower bounds for sphere packing
**Best for Theorem 2.**
1. Unfold `hammingAdmissibleBinary`.
2. Observe that if `hammingRadius p ≥ 1`, then indices `0` and `1` are in the range.
3. Bound the full sum below by the first two summands:
   \[
   \sum_{i=0}^{t} \binom{n}{i}3^i \ge 1 + 3n.
   \]
4. Combine with Hamming admissibility to derive
   \[
   1 + 3n \le 2^{n-k}.
   \]

Why promising: this creates a nontrivial, computationally effective corollary from the hard combinatorial inequality. It also naturally uses `calc`, `Finset.sum_le_sum`, `Nat.choose`, and induction or combinatorial lemmas.

### Strategy C: Rational normalization and asymptotic reinterpretation
**Best for Theorem 3.**
1. Extract toric code parameter formulas or bounds from the toric file.
2. Rewrite them in normalized variables `k/n` and `d/n`.
3. Prove explicit rational inequalities by algebraic manipulation (`field_simp`, `nlinarith`, `ring_nf` where appropriate, but not for trivialities).
4. Interpret the result as a finite-size topological tradeoff.

Why promising: it yields the cross-domain theorem linking coding and topology, and it produces a language future papers can build on.

---

## Required Deep Proof Tactics

Your file must include at least 3 theorems whose proofs genuinely use nontrivial tactics such as:
- `by_contra`
- `rcases`
- `induction` on radius / lattice size / summation range
- `field_simp`
- multi-step `calc`
- explicit finite-sum decomposition with `Finset`
- arithmetic contradiction arguments using derived inequalities

Do **not** satisfy the assignment with tautological rewrites or theorem aliases.

---

## Cross-Domain Connection Requirement

You must include at least one theorem connecting quantum coding to a different domain. The strongest available bridge here is:

### Quantum coding + topology
Formalize that toric/topological code families obey geometric efficiency limitations. This is not just “physics flavor”; it is a theorem about how **surface geometry constrains information density**.

If feasible, add a second bridge:

### Quantum coding + combinatorics
The Hamming bound is a sphere-packing theorem in the discrete Pauli error metric. Make that explicit in the prose and in at least one definition/lemma. For example, define a “Pauli ball volume lower bound” from the first two shell terms and prove it is monotone in radius.

Suggested helper:
```lean
def pauliBallPrefixVolume (n t : ℕ) : ℕ :=
  ∑ i in Finset.range (t + 1), (Nat.choose n i) * 3^i
```

Then prove:
```lean
theorem pauliBallPrefixVolume_monotone_in_t
    (n : ℕ) :
    Monotone (pauliBallPrefixVolume n)
```

This is a genuine combinatorics theorem with coding-theoretic meaning.

---

## Conjecture With Testable Prediction

You must state at least one falsifiable conjecture and provide a computational test in `demo.py`.

### Recommended conjecture
**Conjecture (degeneracy frontier).**
For fixed `n` and `k`, among profiles satisfying the Singleton bound, the smallest `d` at which the nondegenerate Hamming bound fails is also the onset of all currently known optimal stabilizer constructions requiring degeneracy.

A more Lean-friendly finite version:
```lean
conjecture degeneracy_frontier_conjecture :
  ∀ n k : ℕ, ∃ d₀ : ℕ,
    (∀ d < d₀, singletonAdmissible ⟨n,k,d⟩ → hammingAdmissibleBinary ⟨n,k,d⟩) ∧
    (∀ d ≥ d₀, singletonAdmissible ⟨n,k,d⟩ → ¬ hammingAdmissibleBinary ⟨n,k,d⟩ → True)
```

This is intentionally falsifiable: brute-force parameter sweeps can search for threshold irregularity. If the conjecture is false, that is scientifically valuable and should be documented.

A sharper computational prediction:
- For small `n ≤ 25`, the set of `(n,k,d)` with `degeneracyForcing` is upward closed in `d` for fixed `(n,k)`.

That is very testable in Python.

---

## Lean 4 Formalization Targets

You should aim to produce a new file such as:
- `FINAL/Physics/Quantum/BoundFeasibility.lean`
or, if working outside FINAL first:
- `Physics/Quantum/BoundFeasibility.lean`

### Suggested theorem declarations
```lean
structure QuantumCodeProfile where
  n : ℕ
  k : ℕ
  d : ℕ
  deriving DecidableEq, Repr

def singletonAdmissible (p : QuantumCodeProfile) : Prop :=
  p.k + 2 * (p.d - 1) ≤ p.n

def hammingRadius (p : QuantumCodeProfile) : ℕ :=
  (p.d - 1) / 2

def hammingAdmissibleBinary (p : QuantumCodeProfile) : Prop :=
  ∑ i in Finset.range (hammingRadius p + 1), (Nat.choose p.n i) * 3^i ≤ 2^(p.n - p.k)

def jointlyBoundFeasible (p : QuantumCodeProfile) : Prop :=
  singletonAdmissible p ∧ hammingAdmissibleBinary p

def degeneracyForcing (p : QuantumCodeProfile) : Prop :=
  singletonAdmissible p ∧ ¬ hammingAdmissibleBinary p

theorem hamming_violation_forces_degeneracy
    (p : CodeParams)
    (hhfail : ¬ (
      ∑ i in Finset.range (((p.d - 1) / 2) + 1), (Nat.choose p.n i) * 3^i ≤ 2^(p.n - p.k)
    )) :
    ¬ NondegenerateCode p := by
  -- use binary_quantum_hamming_bound contrapositively

theorem jointly_feasible_radius_bound
    (p : QuantumCodeProfile)
    (hjoint : jointlyBoundFeasible p)
    (ht : 1 ≤ hammingRadius p) :
    1 + 3 * p.n ≤ 2^(p.n - p.k) := by
  -- compare the full Hamming sum with i=0 and i=1 terms

def pauliBallPrefixVolume (n t : ℕ) : ℕ :=
  ∑ i in Finset.range (t + 1), (Nat.choose n i) * 3^i

theorem pauliBallPrefixVolume_monotone_in_t
    (n : ℕ) :
    Monotone (pauliBallPrefixVolume n) := by
  -- finite-range inclusion / sum of nonnegative terms

theorem toric_rate_relDist_product_bound
    (L : ℕ) (hL : 1 ≤ L) :
    ((2 : ℚ) / (2 * L^2)) * ((L : ℚ) / (2 * L^2)) ≤ (1 : ℚ) / L^2 := by
  -- rational inequality
```

Adapt these signatures to the exact names and structures in:
- `FINAL/Physics/PauliClosureFoundations.lean`
- `FINAL/Physics/StabilizerBounds.lean`
- `FINAL/Physics/ToricCode.lean`

Be explicit in comments about which imported theorem is being leveraged.

---

## How to Build on the Catalog Theorems

1. **From `binary_quantum_hamming_bound`**  
   Use it as a contrapositive engine. It already says nondegenerate codes satisfy a sphere-packing inequality. Your innovation is to convert this into a **degeneracy detector**.

2. **From `quantum_singleton_bound` in stabilizer files**  
   Use it to define universal admissibility. This allows you to classify profiles into:
   - impossible by Singleton,
   - possible for degenerate-only candidates,
   - jointly feasible under known bounds.

3. **From `quantum_singleton_bound` in toric files**  
   Use it to derive geometric efficiency limitations for topological constructions, ideally in normalized rate-distance language.

The breakthrough is not the imported theorem itself; it is the **new layer of synthesis**.

---

## Deliverables You Must Produce

You must produce **all** of the following:

### 1. Lean development
A Lean file with:
- at least 3 substantive theorem proofs
- at least 1 novel definition/structure
- minimized `sorry`
- explicit imports and comments indicating catalog dependencies

### 2. Verified algorithm or computational method
Implement a certified or semi-certified parameter filter:
- input: `(n,k,d)`
- output: whether the profile is
  - Singleton-forbidden,
  - degeneracy-forcing,
  - jointly bound-feasible,
  - undecided by these bounds

This can be formalized in Lean as a classifier function plus correctness lemmas, or partly in Python with Lean-verified mathematical core.

### 3. `demo.py`
Interactive or script-based demonstration that:
- scans small parameter ranges
- highlights the degeneracy-forcing region
- tests the conjecture about threshold/upward-closure behavior
- optionally plots feasible vs forbidden profiles

### 4. `RESEARCH_PAPER.md`
A standalone scientific document explaining:
- the new definitions
- theorems and proofs at a mathematical level
- why “degeneracy-forcing” is a meaningful concept
- implications for stabilizer search and topological codes
- next open problems

This paper must make sense without reading the code.

### 5. `ARTICLE.md`
Write this in **Scientific American style**:
- explain why quantum error correction needs bounds
- explain the surprising idea that some parameter regimes do not merely fail, but **force a different mechanism** (degeneracy)
- explain the topology connection
- do **not** focus on formal verification machinery

### 6. `FUTURE_DIRECTIONS.md`
Include 3–5 original research directions. Each one must include:
- a sentence beginning **“The key insight is…”**
- a sentence beginning **“Why now?”**
- at least one direction must bridge to a different domain

Possible directions include:
- quantum LDPC obstruction landscapes
- holographic/topological code tradeoffs
- combinatorial geometry of Pauli spheres
- statistical mechanics interpretation of degeneracy frontiers
- complexity-theoretic hardness of deciding bound-feasibility

---

## Application Keywords

Use these in your prose, theorem commentary, or paper metadata where natural:

**quantum error correction, stabilizer codes, nondegenerate codes, degeneracy, sphere packing, Pauli metric, quantum Singleton bound, quantum Hamming bound, topological quantum computing, toric code, asymptotic tradeoffs, code feasibility, lattice topology, discrete geometry, combinatorics, fault tolerance**

---

## Final Charge

Do not settle for “the Hamming bound again.” The real target is a **new mathematical layer**:

- a theory of **bound-feasible quantum parameters**
- a theorem that **Hamming failure forces degeneracy**
- a verified **parameter-classification algorithm**
- a bridge from **combinatorial coding bounds to topological code limitations**

If you succeed, you will have created a formal seed for a new research program: **obstruction geometry for quantum code design**.

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
    "visualizations": [ { "name": "...", "code": "# matplotlib or plotly script, self-contained", "description": "What this visualizes" } ],
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

Research domain: Physics
Research mode: prove
