## Soli Deo Gloria

## Assignment: Jones Polynomial via Kauffman Bracket — A Topological-Quantum Bridge

### Visionary Objective

Formalize the Jones polynomial as a bridge between knot theory and quantum topology. The Kauffman bracket is not merely a computational device — it is the shadow of the Temperley-Lieb algebra in the plane, and its invariance under Reidemeister moves encodes the deepest fact in low-dimensional topology: that 3-manifold invariants emerge from 2-dimensional combinatorics. By formalizing this, we open the door to certified quantum invariants in Lean.

---

### Core Mathematical Framework

**Definition 1: Kauffman Bracket.** For a link diagram $D$ with $n$ crossings, define $\langle D \rangle \in \mathbb{Z}[A, A^{-1}]$ recursively:
- $\langle \emptyset \rangle = 1$
- $\langle D \sqcup \bigcirc \rangle = (-A^2 - A^{-2}) \langle D \rangle$
- At each crossing: $\langle \cross \rangle = A \langle \smoothing_0 \rangle + A^{-1} \langle \smoothing_1 \rangle$

**Definition 2: Writhe.** $w(D) = \sum_{c \in \text{crossings}(D)} \epsilon(c)$ where $\epsilon$ assigns $+1$ to positive crossings and $-1$ to negative crossings.

**Definition 3: Jones Polynomial.** $V_D(t) = (-A^3)^{-w(D)} \langle D \rangle$ where $t = A^{-4}$.

---

### Precise Theorem Targets with Lean 4 Signatures

**Theorem 1: Kauffman Bracket Skein Relation**
```lean
theorem kauffman_bracket_skein (D : LinkDiagram) (c : Crossing D) :
    bracket D = A * bracket (smooth_0 D c) + A⁻¹ * bracket (smooth_1 D c) := by
```
*Proof Strategy A (Inductive on crossing count):* Induct on the number of crossings. The base case is the unknot bracket $(-A^2 - A^{-2})$. For the inductive step, select any crossing $c$, apply the skein relation by definition, then show the resulting smoothings have fewer crossings. *Strategy A is most promising* because the bracket is defined by this very recursion.

*Proof Strategy B (State-sum / Configuration sum):* Express $\langle D \rangle = \sum_{s : \text{State}} A^{\alpha(s) - \beta(s)} (-A^2 - A^{-2})^{|s|-1}$ where $\alpha(s)$ counts $A$-smoothings and $\beta(s)$ counts $A^{-1}$-smoothings in state $s$. Then the skein relation is a partition of states. More elegant but requires building the state-sum machinery first.

**Theorem 2: Bracket Invariance under Reidemeister II and III**
```lean
theorem bracket_reidemeister_II (D₁ D₂ : LinkDiagram) (h : Reidemeister_II D₁ D₂) :
    bracket D₁ = bracket D₂ := by

theorem bracket_reidemeister_III (D₁ D₂ : LinkDiagram) (h : Reidemeister_III D₁ D₂) :
    bracket D₁ = bracket D₂ := by
```
*Proof Strategy:* For RII: directly apply the skein relation at both crossings in the bigon. The two smoothings produce diagrams that cancel: one gives $A \cdot A^{-1} \langle \text{parallel} \rangle + A^{-1} \cdot A \langle \text{parallel} \rangle$ while the other pair of smoothings produces nugatory crossings that reduce to the same diagram. For RIII: use the "braid-like" move — apply the skein relation at one crossing in each diagram, then use RII invariance on the resulting smoothings. This is a 2-level induction.

**Theorem 3: Jones Polynomial is a Knot Invariant**
```lean
theorem jones_poly_invariant (D₁ D₂ : LinkDiagram) (h : Reidemeister_equiv D₁ D₂) :
    jonesPoly D₁ = jonesPoly D₂ := by
```
*Proof Strategy:* Show that the writhe changes by $\pm 1$ under RI (one crossing added/removed), so $(-A^3)^{-w(D)}$ compensates exactly for the bracket's failure under RI. Specifically: for a positive kink, $\langle \text{kink} \rangle = (-A^3) \langle D \rangle$, and $w$ increases by 1, so $(-A^3)^{-w-1} \cdot (-A^3) = (-A^3)^{-w}$. Combine with RII, RIII bracket invariance.

**Theorem 4: Jones Polynomial of the Trefoil**
```lean
theorem jones_trefoil :
    jonesPoly trefoil = -t⁻⁴ + t⁻³ + t⁻¹ := by
```
*Proof Strategy:* Compute the bracket of the standard trefoil diagram (3 crossings, all positive). There are $2^3 = 8$ states. Organize by number of $A$-smoothings: 3 $A$-smoothings gives $A^3(-A^2-A^{-2})^2$, 2 $A$-smoothings gives $3A(-A^2-A^{-2})$, etc. Then apply writhe normalization with $w = 3$.

**Theorem 5 (Deep): Jones Detects Unknot for Alternating Links**
```lean
theorem jones_detects_unknot_alternating (D : AlternatingLinkDiagram) :
    jonesPoly D = 1 ↔ IsUnknot D := by
```
*Proof Strategy A (via adequate diagrams):* Build on `adequate_jones_detects_unknot` from `Speculative/Knot/Alternating.lean`. An alternating reduced diagram is $A$-adequate and $B$-adequate. By the Tait conjectures (proven by Thistlethwaite, Kauffman, Murasugi), the breadth of $\langle D \rangle$ determines the crossing number for adequate diagrams. If $V_D = 1$, then $\langle D \rangle = (-A^3)^{w(D)}$, forcing breadth 0, so crossing number = 0.

*Proof Strategy B (via Tutte polynomial):* Connect the bracket to the Tutte polynomial of the Tait (checkerboard) graph. For alternating links, $\langle D \rangle$ is essentially $T_G(−A^2, −A^{−2})$ up to normalization. The Jones polynomial is 1 iff $T_G$ is trivial iff $G$ has no edges iff $D$ is the unknot.

---

### Cross-Domain Connections

1. **Statistical Mechanics → Knot Theory:** The Kauffman bracket is the partition function of the $Q$-state Potts model on the Tait graph at $Q = -A^2 - A^{-2}$. Formalize:
```lean
theorem bracket_equals_potts_partition (D : LinkDiagram) (G : TaitGraph D) :
    bracket D = partitionFunction G (-A² - A⁻²) := by
```
This connects knot invariants to statistical mechanics — the Yang-Baxter equation for the Potts model IS Reidemeister III invariance.

2. **Temperley-Lieb Algebra → Quantum Computation:** The Kauffman bracket factors through a representation of the Temperley-Lieb algebra $TL_n$. Each crossing resolves into $A \cdot e_i + A^{-1} \cdot 1$ where $e_i$ are TL generators. This is the mathematical foundation of topological quantum computation (Jones' own observation).

3. **Number Theory → Quantum Invariants:** Evaluate $V_L$ at roots of unity $A = e^{2\pi i / (2k+4)}$. The resulting values are Chern-Simons invariants of the 3-manifold obtained by surgery on $L$. This connects to the Witten-Reshetikhin-Turaev invariants.

---

### Novel Structure: SkeinModule

```lean
/-- A skein module over a ring R assigns elements of R to link diagrams
    satisfying the Kauffman skein relations. This is the algebraic home
    of all quantum knot invariants. -/
structure SkeinModule (R : Type*) [CommRing R] where
  eval : LinkDiagram → R
  skein_rel : ∀ D c, eval D = eval (smooth_0 D c) - eval (smooth_1 D c)
  disjoint_loop : ∀ D, eval (D ⊔ ○) = (-2) * eval D
  empty_val : eval ∅ = 1
```

This structure generalizes the Jones polynomial and opens formalization of HOMFLY-PT, Kauffman 2-variable polynomial, and skein-theoretic 3-manifold invariants.

---

### Falsifiable Conjecture

**Conjecture (Jones Unknot Detection):** For ALL knots $K$ (not just alternating), $V_K(t) = 1 \implies K$ is the unknot.

*Computational test:* Compute $V_K$ for all knots with $\leq 19$ crossings (tables exist with ~6.2 billion prime knots). If any non-trivial knot has $V_K = 1$, the conjecture is false. Current verification: all knots up to 19 crossings have $V_K \neq 1$. The smallest unknown case would be a 20-crossing knot with unusual structure.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
   1. The skein module of $S^1 \times S^2$ is free of rank 2 over $\mathbb{Z}[t^{\pm 1}]$ (test: compute basis)
   2. $V_K(e^{2\pi i/5})$ is an algebraic integer of degree $\leq \phi(5)/2$ for all knots (test: verify for all knots $\leq 16$ crossings)
   3. The colored Jones polynomial satisfies a $q$-holonomic recurrence of order $\leq 2g(F)$ where $F$ is a Seifert surface (test: compute for torus knots $T(2,n)$)
   4. Khovanov homology detects the unknot (test: compute for all knots $\leq 14$ crossings)
   5. The volume conjecture: $2\pi \lim_{n\to\infty} \frac{\log|J_N(K; e^{2\pi i/N})|}{N} = \text{Vol}(S^3 \setminus K)$ (test: numerical verification for figure-eight knot to precision $10^{-6}$)

(b) **RESEARCH_PAPER.md** — standalone paper explaining: the Kauffman bracket formalization, Reidemeister invariance proof architecture, the alternating unknot detection theorem, and the statistical mechanics connection. Must be readable without code access.

(c) **ARTICLE.md** — Scientific American style: "The Quantum Thread That Binds Knots to Physics" — explain how a polynomial invented to study quantum groups turned out to encode 3-dimensional topology, and why formal verification matters for quantum computing security.

(d) **Verified Algorithm:** A certified Jones polynomial computation algorithm that, given a link diagram as a Gauss code, returns $V_L(t) \in \mathbb{Z}[t^{\pm 1}]$ with a proof of correctness.

(e) **demo.py** — Interactive demo: user inputs a knot (via Dowker notation or preset), the system computes the Jones polynomial, displays the state-sum expansion, and visualizes the knot diagram with crossing labels colored by their smoothing contribution.

---

### Application Keywords
`topological-quantum-computation`, `Chern-Simons-invariants`, `Temperley-Lieb-algebra`, `Potts-model-partition-function`, `Yang-Baxter-equation`, `skein-theory`, `Tait-conjectures`, `Witten-Reshetikhin-Turaev-invariants`, `volume-conjecture`

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

Research domain: Geometry
Research mode: prove
