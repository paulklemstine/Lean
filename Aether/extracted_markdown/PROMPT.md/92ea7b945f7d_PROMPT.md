## Soli Deo Gloria

## Assignment: Direction 3: Arithmetic Statistics of Graph Jacobians

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important. If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog. Check the catalog references to confirm novelty.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain (e.g., number theory + tropical geometry, algebra + physics).

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

### Research Direction

**Conjecture**: The distribution of invariant factors of the graph Jacobian, over the ensemble of random Erdős-Rényi graphs $G(n, p)$, converges to the Cohen-Lenstra distribution as $n \to \infty$ for appropriate scaling of $p$.

**The key insight is** that the SNF correspondence converts the question about tropical-harmonic structure into a question about random integer matrices, where powerful tools from random matrix theory and arithmetic statistics apply.

**Why now?** The catalog already contains a Cohen-Lenstra module (`Catalog/Pythagorean/CohenLenstra/`) and the new SNF correspondence provides the bridge needed to connect graph Jacobian computations to Cohen-Lenstra predictions.

**Test**: Generate 10,000 random graphs $G(n, 1/2)$ for $n = 10, 20, 50, 100$. Compute the distribution of the largest invariant factor $d_1$ (the exponent of the critical group). Compare with the Cohen-Lenstra prediction $\Pr[p^k \mid d_1] = \prod_{i=1}^k (1 - p^{-i})^{-1}$ for primes $p$.

**Impact**: This would establish a new bridge between combinatorial probability and number-theoretic statistics, showing that the "random" behavior of graph invariants mirrors the "random" behavior of ideal class groups.

---

### Precise Theorem Targets

#### Theorem 1: SNF-Jacobian Isomorphism (Foundation Theorem)

The graph Jacobian (sandpile group) of a connected graph is isomorphic to the direct sum of cyclic groups determined by the invariant factors of the reduced Laplacian's Smith Normal Form.

```lean
theorem snf_jacobian_isomorphism
    {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [G.Connected] [DecidableRel G.Adj]
    (h_card : Fintype.card V ≥ 2)
    (L_reduced : Matrix (Fin (Fintype.card V - 1)) (Fin (Fintype.card V - 1)) ℤ)
    (h_L : L_reduced = reducedLaplacian G)
    (snf : SmithNFData L_reduced)
    (h_pos : ∀ i, 0 < snf.invariantFactors i) :
    GradedMonoid.mk (Jac G) ≃*
      DirectSum (Fin (Fintype.card V - 2))
        (fun i => ZMod snf.invariantFactors i) := by
  sorry
```

This is the **structural bridge**: it proves that the arithmetic content of the Jacobian is entirely encoded in the SNF invariant factors. Without this, the Cohen-Lenstra connection is merely an analogy; with it, it becomes a theorem transfer.

#### Theorem 2: Cohen-Lenstra Moment Identity for p-Divisibility

For a prime $p$ and the Cohen-Lenstra distribution on finite abelian $p$-groups, the probability that $p^k$ divides the group order equals $\prod_{i=1}^{k}(1-p^{-i})^{-1}$.

```lean
theorem cohen_lenstra_p_divisibility_moment
    (p : ℕ) (hp : Nat.Prime p) (hp_odd : p ≠ 2) (k : ℕ) :
    (∑ G : FinAbelianPGroup p, 
      cohenLenstraWeight p G * 
        if (p : ℕ) ^ k ∣ Fintype.card G then (1 : ℝ) else 0) =
    ∏ i in Finset.range k, (1 - (1 : ℝ) / p ^ (i + 1))⁻¹ := by
  sorry
```

This is the **computational heart**: it gives the exact moment formula against which empirical graph Jacobian data must be compared. The proof requires summing over the classification of finite abelian $p$-groups and using the partition function identity for $\prod(1-p^{-i})^{-1}$.

#### Theorem 3: Cross-Domain Bridge — Tropical Laplacian Determines Arithmetic Statistics

The tropical Laplacian of a graph, viewed as a min-plus matrix, determines the same invariant factors as the classical Laplacian, establishing a functorial correspondence between tropical-harmonic structures and arithmetic group structures.

```lean
theorem tropical_arithmetic_correspondence
    {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [G.Connected] [DecidableRel G.Adj]
    (tL : TropicalMatrix V)
    (h_tL : tropicalLaplacian G tL)
    (snf_classical : SmithNFData (reducedLaplacian G))
    (snf_tropical : SmithNFData (tropicalToClassical tL)) :
    snf_classical.invariantFactors = snf_tropical.invariantFactors := by
  sorry
```

This is the **paradigm shift**: it proves that tropical geometry and arithmetic statistics are not merely analogous but literally compute the same invariants through different lenses. The tropical view reveals the combinatorial skeleton; the arithmetic view reveals the group-theoretic flesh.

---

### Novel Definition: `ArithmeticSandpileStructure`

```lean
/-- An ArithmeticSandpileStructure packages the graph-theoretic,
    tropical-geometric, and arithmetic-statistical data of a graph's
    Jacobian into a unified structure. This is the "Rosetta stone" that
    makes the Cohen-Lenstra connection explicit. -/
structure ArithmeticSandpileStructure (V : Type*) [Fintype V] [DecidableEq V] where
  graph : SimpleGraph V
  [connected : graph.Connected]
  [dec_adj : DecidableRel graph.Adj]
  reduced_laplacian : Matrix (Fin (Fintype.card V - 1)) (Fin (Fintype.card V - 1)) ℤ
  snf_data : SmithNFData reduced_laplacian
  jacobian_group : FinVecAbelianGroup (Fintype.card V - 2)
  p_primary_decomposition : ∀ p : ℕ, Nat.Prime p → 
    DirectSum.FinEquiv p (pSylow p jacobian_group)
  cohen_lenstra_weight : ∀ p : ℕ, Nat.Prime p → ℝ
  h_weight : ∀ p hp, cohen_lenstra_weight p hp = 
    1 / (Fintype.card (Aut (pSylow p jacobian_group)) : ℝ) /
      (Fintype.card (pSylow p jacobian_group) : ℝ)
```

This structure does not exist in the catalog. It simultaneously encodes: (1) the combinatorial graph data, (2) the tropical Laplacian via SNF, (3) the arithmetic group structure, and (4) the Cohen-Lenstra statistical weight. It is the formal vessel for the conjecture.

---

### Proof Strategies (Three Paths)

**Strategy A: Direct Moment Computation (Most Concrete)**
1. For $G(n, 1/2)$, the reduced Laplacian entries are sums of Bernoulli random variables (diagonal entries are $\text{Binomial}(n-1, 1/2)$, off-diagonal entries are $-\text{Bernoulli}(1/2)$).
2. Compute $\mathbb{E}[\#\{g \in \text{Jac}(G) : p^k | \text{ord}(g)\}]$ by counting solutions to $p^k \cdot g = 0$ in the cokernel.
3. Use the SNF structure: $p^k | d_i$ for all $i$ iff $p^k$ divides every invariant factor. The probability that $p^k | d_i$ for the $i$-th factor depends on the rank profile of the Laplacian mod $p^k$.
4. Apply the moment method: if the $p^k$-divisibility moments converge to the Cohen-Lenstra moments, and the moment problem is determinate for the Cohen-Lenstra distribution, then the distributions converge.
5. **Key lemma needed**: `rank_profile_probability` — the probability that the reduced Laplacian of $G(n,1/2)$ has rank profile $(r_1, \ldots, r_k)$ mod $p^k$ converges to the Cohen-Lenstra prediction.
6. **Difficulty**: Moderate. The moment computation is explicit but requires careful handling of dependencies in the Laplacian entries.

**Strategy B: Wood's Random Matrix Transfer (Most Promising)**
1. Wood (2017, "The distribution of the number of subgroups of the finite abelian group $\mathbb{Z}/p^{\alpha_1} \times \cdots \times \mathbb{Z}/p^{\alpha_r}$") proved that the cokernel of a uniform random $n \times n$ matrix over $\mathbb{Z}/p^k\mathbb{Z}$ follows the Cohen-Lenstra distribution as $n \to \infty$.
2. The reduced Laplacian of $G(n, p)$ is NOT a uniform random matrix — its entries are correlated (diagonal = negative sum of off-diagonal row entries).
3. **Key insight**: The row-sum constraint is a single linear condition per row. For $n$ large, this removes only $O(n)$ degrees of freedom from the $O(n^2)$ total, so the cokernel distribution should be unaffected in the limit.
4. Formalize this as: `laplacian_conditioning_negligible` — the conditional distribution of the reduced Laplacian given the row-sum constraints converges to the unconditional distribution of a random integer matrix in the appropriate sense.
5. Apply Wood's theorem to conclude.
6. **Why most promising**: Wood's theorem gives the conclusion for free once we show the Laplacian conditioning is negligible. This is a "soft analysis" step rather than a hard combinatorial computation. The conditioning argument is well-understood in random matrix theory (it is analogous to showing that a random symmetric matrix has the same spectral distribution as a non-symmetric one).

**Strategy C: Tropical-Geometric Bridge (Most Novel)**
1. The tropical Laplacian encodes the same information as the classical Laplacian but through min-plus algebra.
2. The tropical SNF (computed via tropical determinant theory) gives the same invariant factors.
3. Use the tropical structure to define a "tropical random matrix ensemble" where the entries are tropical random variables (i.e., elements of $\mathbb{R} \cup \{\infty\}$ with the min-plus semiring structure).
4. Show that the tropical ensemble's SNF statistics match the classical ensemble's statistics by the correspondence theorem.
5. This opens a new field: **tropical arithmetic statistics**, where the tools of tropical geometry (tropical intersection theory, tropical Hodge theory) can be brought to bear on number-theoretic questions.
6. **Risk**: The theory of random tropical matrices is completely undeveloped. This is high-risk, high-reward.

**Recommendation**: Strategy B is most promising because it reduces the problem to a known theorem (Wood's result) plus a well-understood type of argument (conditioning is negligible). Strategy A is a solid backup. Strategy C should be pursued as a *conjectural framework* and formalized as a definition/conjecture pair.

---

### Cross-Domain Connections

1. **Combinatorial Probability ↔ Number Theory**: The Erdős-Rényi model meets Cohen-Lenstra heuristics. Random graphs produce the same group-theoretic statistics as random number fields. This suggests a *universality principle*: the Cohen-Lenstra distribution is the "Gaussian" of finite abelian $p$-group statistics — it appears whenever you average over a sufficiently rich random structure.

2. **Random Matrix Theory ↔ Tropical Geometry**: The Laplacian matrix lives in two worlds simultaneously. As a classical matrix over $\mathbb{Z}$, it participates in random matrix theory. As a tropical matrix over the min-plus semiring, it participates in tropical geometry. The SNF is the invariant that bridges both worlds. This is analogous to how the Riemann zeta function bridges analytic number theory and random matrix theory (Montgomery-Dyson coincidence).

3. **Statistical Mechanics ↔ Arithmetic Statistics**: The partition function $\prod_{i=1}^{\infty}(1-p^{-i})^{-1}$ that appears in Cohen-Lenstra is exactly the partition function of a bosonic system with energy levels $\log p, 2\log p, 3\log p, \ldots$ at temperature $1$. The graph Jacobian conjecture says that random graphs are in the same "universality class" as this bosonic system. This connects to the work of Cohen-Lenstra-Martinet on heuristics for class groups, which can be reinterpreted as statements about equilibrium distributions in number-theoretic statistical mechanics.

4. **Cryptography ↔ Graph Theory**: The hardness of computing the structure of $\text{Jac}(G)$ for large graphs (related to the discrete logarithm problem in finite abelian groups) has implications for cryptographic protocols based on graph isomorphisms. If the Jacobian structure is "typically Cohen-Lenstra," then random graphs typically have Jacobians with the same cryptographic properties as random ideal class groups.

---

### Application Keywords

`Cohen-Lenstra heuristics`, `random matrix theory`, `Smith normal form`, `graph Jacobian`, `sandpile group`, `Erdős-Rényi`, `moment method`, `tropical Laplacian`, `finite abelian groups`, `arithmetic statistics`, `universality`, `partition functions`, `p-primary decomposition`, `random integer matrices`, `Wood's theorem`, `critical group`, `abelian sandpile model`

---

### Conjecture with Testable Prediction

**Conjecture (Cohen-Lenstra for Graph Jacobians)**: For any odd prime $p$ and any $k \geq 1$,

$$\lim_{n \to \infty} \Pr_{G \sim G(n, 1/2)}\left[p^k \mid |\text{Jac}(G)|\right] = \prod_{i=1}^{k}(1 - p^{-i})^{-1}$$

**Computational test (falsifiable)**:
```python
# demo.py
import numpy as np
from scipy.linalg import svdvals
import networkx as nx
from collections import Counter

def graph_jacobian_invariant_factors(G):
    """Compute invariant factors of Jac(G) via SNF of reduced Laplacian."""
    L = nx.laplacian_matrix(G).toarray().astype(int)
    # Remove last row and column to get reduced Laplacian
    n = L.shape[0]
    L_red = L[:n-1, :n-1]
    # Compute SNF using sympy
    from sympy import Matrix
    M = Matrix(L_red)
    # The Smith Normal Form diagonal gives invariant factors
    # Use elementary divisor computation
    snf = M.smith_normal_form()
    diag = [snf[i,i] for i in range(min(snf.rows, snf.cols))]
    return [d for d in diag if d > 0]

def cohen_lenstra_prediction(p, k):
    """Cohen-Lenstra prediction: Pr[p^k | |G|] for random finite abelian p-group."""
    product = 1.0
    for i in range(1, k+1):
        product *= 1.0 / (1.0 - p**(-i))
    return product

def test_conjecture(n_values, p_values, k_values, num_samples=10000):
    """Test the Cohen-Lenstra conjecture for graph Jacobians."""
    results = {}
    for n in n_values:
        for p in p_values:
            for k in k_values:
                count = 0
                for _ in range(num_samples):
                    G = nx.erdos_renyi_graph(n, 0.5)
                    if nx.is_connected(G):
                        factors = graph_jacobian_invariant_factors(G)
                        jac_order = 1
                        for f in factors:
                            jac_order *= f
                        if (p ** k) > 0 and jac_order % (p ** k) == 0:
                            count += 1
                empirical = count / num_samples
                predicted = cohen_lenstra_prediction(p, k)
                results[(n, p, k)] = {
                    'empirical': empirical,
                    'predicted': predicted,
                    'error': abs(empirical - predicted)
                }
                print(f"n={n}, p={p}, k={k}: empirical={empirical:.4f}, "
                      f"predicted={predicted:.4f}, error={abs(empirical-predicted):.4f}")
    return results

# Run test
results = test_conjecture(
    n_values=[10, 20, 50],
    p_values=[3, 5, 7],
    k_values=[1, 2],
    num_samples=5000
)
```

**Falsification criterion**: If for any odd prime $p$ and $k \geq 1$, the empirical probability $\Pr[p^k \mid |\text{Jac}(G(n,1/2))|]$ does not converge toward the Cohen-Lenstra prediction as $n$ increases (say, the error does not decrease for $n = 50, 100, 200$), the conjecture is false.

---

### Catalog References

- `Catalog/Pythagorean/TropicalBridge/SNFCorrespondence.lean` — `SmithNFData.invariantFactors` (the SNF bridge)
- `Catalog/Pythagorean/CohenLenstra/Defs.lean` — Cohen-Lenstra distributions and weights
- Build on these to construct the `ArithmeticSandpileStructure` and prove the moment identity.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 research directions. Each must include "The key insight is..." and "Why now?" At least one must bridge to a different domain.

(b) **RESEARCH_PAPER.md** — standalone scientific document. Someone reading ONLY this paper must understand what was discovered, why it matters, and what to investigate next.

(c) **ARTICLE.md** — Scientific American style. Engaging, accessible. **TABOO**: Do NOT focus on formal verification or machine verification — write about the ideas and their significance.

(d) **Verified algorithm or computational method** (not just a theorem statement): provide a certified algorithm for computing the Cohen-Lenstra moments from SNF data, or for sampling the Jacobian distribution of random graphs.

(e) **demo.py** that demonstrates the result interactively — the falsification test above, plus visualization of convergence.

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
