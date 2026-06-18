## Soli Deo Gloria

## Assignment: Optimal Certificate Search via SAT/LP Reduction — Structural Hypergraph Theory Meets Circuit Lower Bounds

### Core Conjecture (Precise Statement)

**Conjecture (Structured Transversal Tractability).** Let $\mathcal{H}_{n,s}$ denote the circuit-refutation hypergraph for triangle detection on $n$ vertices with circuit size bound $s$. The minimum transversal $\tau(\mathcal{H}_{n,s})$ can be computed in time $O(2^{n^{O(1)}} \cdot \mathrm{poly}(|\mathcal{H}_{n,s}|))$ via reduction to weighted SAT with monotone clause structure.

**Lean 4 Type Signature Target:**
```lean
-- The circuit-refutation hypergraph: vertices are sandwich certificates,
-- hyperedges are minimal refutation sets for each circuit
structure CircuitRefutationHypergraph where
  n : ℕ          -- number of vertices
  s : ℕ          -- circuit size bound
  certificates : Finset (SandwichCertificate n)
  circuits : Finset (MonotoneCircuit n s)
  refutation_edges : MonotoneCircuit n s → Finset (Finset (SandwichCertificate n))
  -- Each edge is a minimal set of certificates that jointly refute the circuit
  edge_minimal : ∀ C ∈ circuits, ∀ e ∈ refutation_edges C, ∀ c ∈ e, 
    ¬(e \ {c}) ⊆ ⋃ C' ∈ circuits, refutation_edges C'
  -- Monotonicity: if C₁ ⊂ C₂ (subcircuit), then refutation_edges C₂ ⊆ refutation_edges C₁
  monotone_structure : ∀ C₁ C₂ ∈ circuits, C₁ ⊂ C₂ → 
    refutation_edges C₂ ⊆ refutation_edges C₁

/-- Minimum transversal of the circuit-refutation hypergraph -/
def minTransversal (H : CircuitRefutationHypergraph) : ℕ :=
  sInf { t | ∃ (T : Finset (SandwichCertificate H.n)), 
    T.card = t ∧ ∀ C ∈ H.circuits, ∃ e ∈ H.refutation_edges C, e ⊆ T }

/-- The SAT encoding reduces transversal computation to SAT with monotone structure -/
theorem sat_encoding_correct (H : CircuitRefutationHypergraph) :
    ∃ (φ : CNFFormula) (w : Assignment → ℕ),
    φ.isMonotone ∧
    φ.clause_count ≤ H.circuits.card ∧
    (∀ σ, satisfies σ φ → (decodeAssignment σ).card ≥ minTransversal H) ∧
    (∃ σ, satisfies σ φ ∧ (decodeAssignment σ).card = minTransversal H) ∧
    -- The key structural property: monotone clauses permit FPT algorithms
    φ.max_clause_size ≤ maxRefutationSetSize H := by
  sorry
```

### Deep Proof Strategies (Three Paths)

**Strategy A: Sunflower Decomposition + Branching (Most Promising)**

The circuit-refutation hypergraph $\mathcal{H}_{n,s}$ has bounded edge size (each refutation set has size $\leq s$, the circuit size bound) and monotone structure. By the Sunflower Lemma (Erdős–Rado), if $|\mathcal{H}| > s! \cdot k^s$, there exists a sunflower of size $k+1$. The monotonicity constraint means overlapping sunflowers can be pruned without losing optimality, yielding an FPT algorithm parameterized by the transversal size $\tau$.

*Why most promising:* The sunflower approach exploits the *specific* structure of circuit-refutation hypergraphs (monotonicity + bounded edge size), not just generic SAT. This is the same insight that powers the recent breakthrough FPT algorithms for $d$-Hitting Set (Cygan et al., FPT book §7.2), but monotonicity gives us an additional pruning power that general hypergraphs lack.

**Strategy B: LP Integrality Gap Exploitation**

The standard LP relaxation of minimum hitting set on $\mathcal{H}_{n,s}$ has integrality gap at most $O(\ln d)$ for general $d$-uniform hypergraphs. **Conjecture:** For monotone circuit-refutation hypergraphs, the integrality gap is at most $2$ (matching the result for interval hypergraphs). This would follow from showing that the dual packing LP has the consecutive-ones property after appropriate column ordering induced by the circuit partial order.

*Why risky but high-reward:* If the gap is indeed $\leq 2$, greedy is near-optimal and the entire SAT approach is unnecessary — but this would itself be a major structural theorem about circuit lower bound certificates.

**Strategy C: Tropical Geometry Bridge (Cross-Domain)**

Each sandwich certificate defines a tropical halfspace in the parameter space $\mathbb{T}^s$ of circuit coefficients. The minimum transversal is the minimum number of tropical halfspaces whose intersection contains all "triangle-detecting" circuits. This is equivalent to finding the tropical rank of the certificate matrix, connecting to tropical determinantal complexity.

```lean
/-- Bridge theorem: transversal number equals tropical covering number -/
theorem transversal_tropical_rank (H : CircuitRefutationHypergraph) :
    minTransversal H = tropicalCoveringNumber (certificateMatrix H) := by
  sorry
```

### Theorems to Prove (Deep, Non-Trivial)

**Theorem 1: Monotone Refutation Structure (Induction on circuit depth)**
```lean
theorem refutation_monotonicity (n s : ℕ) (C₁ C₂ : MonotoneCircuit n s) 
    (h_depth : C₁.depth < C₂.depth) (h_sub : C₁ ⊂ C₂) :
    ∀ e ∈ (CircuitRefutationHypergraph.refutation_edges default C₂),
      ∃ e' ∈ (CircuitRefutationHypergraph.refutation_edges default C₁), e' ⊆ e := by
  induction C₂.depth generalizing C₁ C₂
  -- Key: deeper circuits have *fewer* refutation requirements (they're harder to refute)
  sorry
```

**Theorem 2: Sunflower Pruning Preserves Optimality (By contradiction + minimality)**
```lean
theorem sunflower_pruning_optimal (H : CircuitRefutationHypergraph) {k : ℕ}
    (hk : H.certificates.card > (H.s)! * k^H.s) :
    ∃ (petal : SandwichCertificate H.n), 
      minTransversal H = minTransversal (H \ {petal}) := by
  by_contra h
  -- If removing any petal increases transversal, every petal is essential,
  -- but then we have k+1 disjoint essential elements, contradicting 
  -- the bounded edge size
  sorry
```

**Theorem 3: Cross-Domain — Tropical Transversal = Min Tropical Rank (Calc reasoning)**
```lean
theorem tropical_transversal_rank_eq (H : CircuitRefutationHypergraph) :
    minTransversal H = sInf { r | ∃ (M : Matrix (Fin r) (Fin H.s) TropicalNum),
      tropicalRank M ≥ minTransversal H ∧ 
      ∀ i, ∃ C ∈ H.circuits, tropicalHalfspace (M.row i) separates C } := by
  calc minTransversal H 
      = _ := by rw [transversal_as_covering H]
    _ = _ := by exact covering_as_tropical_arrangement H
    _ = _ := by exact tropical_rank_minimality H
  sorry
```

### Novel Structure: WeightedMonotoneSAT

```lean
/-- A SAT formula where each clause is monotone (all positive literals) 
    and clauses are ordered by a partial order consistent with implication -/
structure WeightedMonotoneSAT where
  variables : Finset ℕ
  clauses : Finset (Finset ℕ)  -- each clause is a set of positive variables
  weight : ℕ → ℕ               -- weight function on variables
  -- Partial order on clauses: C₁ ≤ C₂ iff C₁ ⊆ C₂
  -- This captures the monotone circuit refutation structure
  clause_order : PartialOrder (Finset ℕ)
  consistent : ∀ C₁ C₂ ∈ clauses, C₁ ⊆ C₂ → @LE.le _ clause_order.le C₁ C₂

/-- Minimum weight satisfying assignment for monotone SAT -/
def minWeightSat (φ : WeightedMonotoneSAT) : ℕ :=
  sInf { w | ∃ σ, satisfiesMonotone σ φ ∧ (σ.weight φ.weight) = w }
```

### Falsifiable Conjecture with Computational Test

**Conjecture (Bounded Integrality Gap for Circuit-Refutation Hypergraphs):**
For all $n \geq 3$ and $s \geq 1$, the LP integrality gap of the minimum hitting set relaxation on $\mathcal{H}_{n,s}$ is at most $2$.

**Computational Test:**
```python
# test_integrality_gap.py
def test_integrality_gap(n_max=7, s_max=12):
    """If gap > 2 found, conjecture is falsified."""
    for n in range(3, n_max + 1):
        for s in range(1, s_max + 1):
            H = build_circuit_refutation_hypergraph(n, s)
            lp_val = solve_lp_relaxation(H)
            ip_val = solve_integer_program(H)
            gap = ip_val / lp_val if lp_val > 0 else float('inf')
            if gap > 2.0 + 1e-9:
                print(f"COUNTEREXAMPLE: n={n}, s={s}, gap={gap:.4f}")
                return False
    return True  # Conjecture survives
```

If the gap exceeds 2 for any instance, the LP approach (Strategy B) fails and we must rely on sunflower branching (Strategy A). If the gap is always $\leq 2$, it reveals deep structure in circuit lower bound certificates that would transform the field.

### Revolutionary Significance

This work would establish that **circuit lower bound discovery is a structured optimization problem**, not an art. The monotone SAT reduction means:

1. **Automated lower bound discovery**: SAT solvers can find optimal certificate families, potentially yielding the first computationally discovered circuit lower bounds for $n > 10$.
2. **Tropical geometry of circuits**: The tropical rank connection (Theorem 3) opens a new field — tropical circuit complexity — linking min-plus algebra to Boolean circuit theory.
3. **Phase transitions in certificate complexity**: The SAT instance has a clause-to-variable ratio; if it exhibits a phase transition (like random $k$-SAT), there are regimes where certificates are easy vs. impossible to find, predicting where circuit lower bounds are tractable.

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
   - H1: Integrality gap $\leq 2$ for circuit-refutation hypergraphs (test: ILP vs LP for $n \leq 8$)
   - H2: Sunflower pruning reduces search space by $\geq 90\%$ for $n \geq 6$ (test: count branches with/without pruning)
   - H3: Tropical rank equals transversal number (test: compute both for $n \leq 5$)
   - H4: Phase transition at clause-to-variable ratio $\approx 4.2$ (test: SAT solver runtime distribution)
   - H5: Greedy is within factor 2 of optimal for all $n \leq 20$ (test: compare greedy vs ILP)

(b) **RESEARCH_PAPER.md**: Standalone paper proving the SAT reduction, the monotone structure theorem, and the tropical rank bridge. Must include complexity analysis showing the $O(2^{\mathrm{poly}(n)})$ bound.

(c) **ARTICLE.md**: "How SAT Solvers Could Discover the Next Circuit Lower Bound" — explain the pipeline from circuit to SAT instance to certificate, accessible to CS undergraduates.

(d) **Verified algorithm**: `monotoneSatTransversal` — a verified Lean function that takes a `CircuitRefutationHypergraph` and returns the minimum transversal, with a proof of correctness and complexity bound.

(e) **demo.py**: Interactive demo that builds circuit-refutation hypergraphs for small $n$, encodes them as SAT instances, solves with a SAT solver (pysat), and visualizes the optimal certificate family as a tropical hyperplane arrangement.

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
