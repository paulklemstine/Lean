## Assignment: Direction 3: Connecting to Razborov's Approximation Pairs — Certified Sandwich Families as a Strict Generalization

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction

**Conjecture:** Every Razborov-style approximation sandwich $(P^+, P^-)$ for a monotone function $f$ induces a certified sandwich family $S$ such that $S$ is complete up to the same size bound that the Razborov argument achieves. This establishes the certified sandwich family framework as a *strict generalization* of the classical approximation method.

**Test:** Take the specific approximation pair used in Razborov's clique lower bound for $n = 6, k = 3$. Extract the induced positive and negative witness sets. Check whether these witnesses form a complete sandwich family against all circuits of size $\leq s$ where $s$ is the Razborov bound.

**Impact:** Would show that the certified sandwich family framework *subsumes* the classical approximation method, establishing it as a strict generalization. Would also provide a recipe for converting existing lower bound proofs into certificates. Opens the door to *compositional* lower bound certificates: if two functions have certified sandwich families, their composition inherits one with bounded parameter loss.

---

### Novel Definition: CertifiedSandwichFamily

```lean
/-- A certified sandwich family for a monotone function f on n variables consists of:
    - positive witnesses: inputs where f = 1 that small circuits must fail to accept
    - negative witnesses: inputs where f = 0 that small circuits must fail to reject
    - completeness: every small circuit disagrees with f on at least one witness
    This generalizes Razborov's approximation pairs by making the witness structure explicit. -/
structure CertifiedSandwichFamily (n : ℕ) where
  positive_witnesses : Finset (BoolVec n)
  negative_witnesses : Finset (BoolVec n)
  size_bound : ℕ
  disjoint : ∀ x, x ∈ positive_witnesses → x ∉ negative_witnesses
  completeness : ∀ (c : MonotoneCircuit n), c.size ≤ size_bound →
    ∃ x ∈ positive_witnesses ∪ negative_witnesses, c.eval x ≠ f x
```

---

### Theorem 1: Approximation-to-Sandwich Extraction (Core Result)

```lean
/-- Every approximation sandwich induces a certified sandwich family with the same
    completeness bound. This is the key subsumption theorem. -/
theorem approximation_sandwich_induces_certified_family
    {n : ℕ} {f : BoolVec n → Bool} (as : ApproximationSandwich f)
    (hf : Monotone f)
    (h_disj : Disjoint as.P⁺ as.P⁻)
    (h_approx : ∀ (c : MonotoneCircuit n), c.size ≤ as.size_bound →
      (∃ x ∈ as.P⁺, c.eval x = false) ∨ (∃ x ∈ as.P⁻, c.eval x = true)) :
    ∃ (csf : CertifiedSandwichFamily n),
      csf.positive_witnesses = as.P⁺ ∧
      csf.negative_witnesses = as.P⁻ ∧
      csf.size_bound = as.size_bound ∧
      csf.completeness = sorry -- to be filled: follows from h_approx
```

**Proof Strategy A (Direct — RECOMMENDED):** Define the map `approximationToSandwich` by taking `P⁺` and `P⁻` as the witness sets. The completeness proof proceeds by case analysis on `h_approx`: if a small circuit `c` fails on `P⁺`, then `c.eval x ≠ f x` for some `x ∈ P⁺` (since `f = 1` on `P⁺` but `c.eval x = false`); similarly for `P⁻`. The disjointness condition ensures the family is well-formed. This is the most direct path and leverages the catalog's `approximation_sandwich_lower_bound` directly.

**Proof Strategy B (Via Karchmer-Wigderson Games):** Interpret the approximation sandwich as a strategy in the KW-game for `f`. The positive witnesses correspond to Alice's positions, negative to Bob's. Completeness of the sandwich family follows from the game-theoretic characterization: a small circuit would give a cheap protocol, contradicting the lower bound. This approach is more conceptual but requires building KW-game infrastructure.

**Proof Strategy C (Contrapositive/By-contradiction):** Assume a certified sandwich family extracted from `(P⁺, P⁻)` is *not* complete. Then some small circuit `c` agrees with `f` on all of `P⁺ ∪ P⁻`. But this contradicts the approximation hypothesis `h_approx`, since `c` must fail somewhere. This is essentially Strategy A reformulated, but the contrapositive framing may be cleaner in Lean.

---

### Theorem 2: Razborov Clique Sandwich Extraction (Concrete Instance)

```lean
/-- The specific approximation sandwich from Razborov's clique lower bound
    induces a complete certified sandwich family. -/
theorem clique_approx_induces_complete_sandwich
    {n k : ℕ} (hn : n ≥ 2 * k) (hk : k ≥ 3) :
    ∃ (csf : CertifiedSandwichFamily (choose n k)),
      csf.size_bound ≥ clique_razborov_bound n k ∧
      csf.completeness = sorry -- to be filled
```

where `clique_razborov_bound n k = 2^(k/2)` (up to polynomial factors in n).

**Proof Strategy:** Build on `clique_monotone_size_lower_bound_of_approximation` from the catalog. The key step is showing that the specific `CliqueApproxSandwich` constructed in `CliqueLowerBound.lean` satisfies the disjointness condition (positive instances are k-cliques, negative instances are (k-1)-colorings — these are disjoint by the pigeonhole principle on k-cliques in (k-1)-colorable graphs). Then apply Theorem 1.

---

### Theorem 3 (Cross-Domain): Sunflower-Sandwich Duality

```lean
/-- A sunflower-free family of minterms induces a certified sandwich family
    whose completeness bound is controlled by the sunflower lemma parameter.
    This connects combinatorial sunflower theory to circuit lower bound certificates. -/
theorem sunflower_free_induces_sandwich
    {n k r : ℕ} (F : Finset (Finset (Fin n)))
    (h_sunflower_free : ¬HasSunflower F r)
    (h_size : F.card > (r - 1)^k * n^k) :
    ∃ (csf : CertifiedSandwichFamily n),
      csf.size_bound ≥ F.card / ((r-1)^k) ∧
      sorry -- completeness follows from sunflower-free structure
```

**Cross-Domain Bridge:** The sunflower lemma (Erdős-Rado) is the engine behind Razborov's method. This theorem makes the connection explicit: sunflower-free families of minterms *are* certified sandwich families. This bridges:
- **Combinatorics**: Sunflower lemma, Ramsey-type arguments
- **Circuit complexity**: Monotone lower bounds via approximation
- **Logic**: The "approximation" is a form of logical abstraction — replacing precise computation with imprecise but structured computation

**Application Keywords:** `circuit-lower-bounds`, `certified-certificates`, `sunflower-lemma`, `monotone-complexity`, `razborov-method`, `KW-games`, `compositional-certificates`

---

### Falsifiable Conjecture with Computational Test

**Conjecture (Sandwich Composition):** If `f : BoolVec n → Bool` has a certified sandwich family with bound `s₁` and `g : BoolVec m → Bool` has a certified sandwich family with bound `s₂`, then `f ∘ g` has a certified sandwich family with bound `s₁ · s₂ / max(n, m)`.

**Test:** Compute certified sandwich families for `Clique(6,3)` and `Clique(10,4)`. Form the composition `Clique(6,3) ∘ Majority(5)`. Check computationally whether the product bound holds for all monotone circuits of size up to `s₁ · s₂ / 6`.

---

### Catalog References

- `Catalog/Computation/CircuitComplexity/Monotone/ApproximationMethod.lean` — `ApproximationSandwich`, `approximation_sandwich_lower_bound`
- `Catalog/Computation/CircuitComplexity/Monotone/CliqueLowerBound.lean` — `CliqueApproxSandwich`, `clique_monotone_size_lower_bound_of_approximation`

Build directly on these. The `ApproximationSandwich` structure already exists; `CertifiedSandwichFamily` is the novel generalization.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses — each falsifiable with a computational experiment.
(b) **RESEARCH_PAPER.md** — standalone scientific document explaining the subsumption theorem, its proof, and implications for compositional lower bounds.
(c) **ARTICLE.md** — Scientific American style: "Why Razborov's Method Was Always About Certificates."
(d) **Verified algorithm**: `approximationToSandwich` — a computable extraction function from approximation pairs to certified sandwich families.
(e) **demo.py** — takes a monotone function (specified by truth table), constructs an approximation sandwich if one exists, extracts the certified sandwich family, and verifies completeness by exhaustive circuit enumeration for small instances.

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
