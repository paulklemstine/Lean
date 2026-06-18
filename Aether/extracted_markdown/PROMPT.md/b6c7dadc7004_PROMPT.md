## Assignment: Direction 4: Efficient Sampling from Lorentzian Certificates — Spectral Gap, Log-Concavity, and Tropical Diameter

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

---

## The Core Vision

Lorentzian polynomials carry recursive certificate structures (derivative trees with Lorentzian signatures at every node). These certificates have been purely structural — used to *recognize* Lorentzian polynomials, not to *compute* with them. This project transforms certificates into **algorithmic engines**: the reversed Cauchy–Schwarz inequality, which certifies Lorentzianness, simultaneously certifies **rapid mixing** of a natural Markov chain. This bridges algebraic combinatorics, probability theory, and tropical geometry in a way that opens a new field: *algorithmic Lorentzian theory*.

---

## Novel Definitions (Required)

```lean
/-- A certificate tree for a recursively Lorentzian polynomial f records
    the sequence of partial derivatives and their Lorentzian signatures. -/
structure CertificateTree where
  poly : Polynomial (Fin n → ℚ)  -- the polynomial being certified
  degree : ℕ
  children : Fin degree → Option CertificateTree  -- derivative subtrees
  deriving Repr

/-- The certificate-guided Markov chain: at state α, move to β with
    probability proportional to the coefficient of x^β in ∂^α f,
    where ∂^α is the derivative specified by the certificate path to α. -/
def CertificateMarkovChain (f : Polynomial (Fin n → ℚ)) 
    (cert : CertificateTree) : MarkovChain (Fin n →ₙ ℕ) where
  transition α β := (certificateWeight f cert α β) / (certificateTotal f cert α)
  ...

/-- The tropical Newton subdivision induced by a Lorentzian certificate:
    each cell corresponds to a region where a particular monomial dominates
    the tropicalization of ∂^α f. -/
def TropicalCertificateSubdivision (f : Polynomial (Fin n → ℚ))
    (cert : CertificateTree) : TropicalSubdivision n d :=
  sorry  -- to be constructed from the certificate tree
```

---

## Theorem 1: Certificate-Guided Spectral Gap (Deep Proof — Induction + Calc)

```lean
/-- Given a degree-d recursively Lorentzian polynomial f in n variables
    with certificate tree cert, the certificate-guided Markov chain
    has spectral gap at least 1 / (C * n^d), where C is the certificate
    depth constant. -/
theorem certificate_spectral_gap_lower_bound 
    {n d : ℕ} {f : Polynomial (Fin n → ℚ)}
    (cert : CertificateTree) (hL : IsRecursivelyLorentzian f cert)
    (hdeg : f.totalDegree = d) :
    ∃ C : ℕ, C ≤ d * n ^ d ∧ 
      (certificateMarkovChain f cert).spectralGap ≥ 1 / (C : ℝ) := by
  sorry
```

**Proof Strategy A (Most Promising — Reversed Cauchy–Schwarz → Dirichlet Form):**
1. At each node of the certificate tree, `lorentzian_reversed_cauchy_schwarz` gives: for partial derivatives ∂ᵢf, ∂ⱼf of a Lorentzian polynomial, `⟨∂ᵢf, ∂ⱼf⟩² ≥ ⟨∂ᵢf, ∂ᵢf⟩ · ⟨∂ⱼf, ∂ⱼf⟩`. This *reversed* inequality is the key: it provides a **lower bound** on off-diagonal transition probabilities relative to diagonal ones.
2. Translate this to a bound on the Dirichlet form: `E(f,f) = Σ_α π(α) Σ_β P(α,β)(f(α) - f(β))²`. The reversed Cauchy–Schwarz ensures that each term in the sum is bounded below by a controlled fraction.
3. Induct on the certificate depth. Base case: degree 1 Lorentzian polynomials are linear, and the chain is a simple random walk on the simplex with known gap 1/n. Inductive step: the derivative tree decomposes the state space, and the gap at depth k is at least 1/(k · n^d) by the inductive hypothesis combined with the reversed Cauchy–Schwarz bound.

**Proof Strategy B (Alternative — Canonical Paths + Tropical Diameter):**
1. Define canonical paths between states using the certificate tree as a guide: path from α to β follows the unique path through the derivative tree.
2. Bound the congestion ratio using the tropical Newton subdivision: the congestion is at most the tropical diameter of the subdivision.
3. Apply the canonical paths bound on spectral gap: `gap ≥ 1/(ρ · d_max)`, where ρ is the congestion and d_max is the maximum path length.

---

## Theorem 2: Log-Concave Conditional Sampling (Deep Proof — By-Contra + Field_Simp)

```lean
/-- At each internal node of the certificate tree, the conditional
    distribution on the next variable, given the partial assignment,
    is ultra-log-concave. This enables rejection sampling with
    acceptance probability at least 1/d. -/
theorem certificate_conditional_ultra_log_concave
    {n d : ℕ} {f : Polynomial (Fin n → ℚ)}
    (cert : CertificateTree) (hL : IsRecursivelyLorentzian f cert)
    (node : CertificateTree) (hInternal : node.children.any (·.isSome)) :
    UltraLogConcave (certificateConditional f cert node) ∧
    certificateRejectionRate f cert node ≤ (1 - 1/d : ℝ) := by
  sorry
```

**Proof Strategy:**
1. By-contradiction: assume the conditional is not ultra-log-concave. Then there exist consecutive coefficients a_{k-1}, a_k, a_{k+1} with `a_k² < a_{k-1} · a_{k+1}`.
2. This violates the Lorentzian signature condition at this node: the Hessian of the restricted polynomial would have a positive off-diagonal eigenvalue, contradicting `IsRecursivelyLorentzian`.
3. For the rejection rate: use the fact that ultra-log-concave distributions on {0,...,d} have mode at ⌊(d·p)⌋ where p is the success probability, and the mass at the mode is at least 1/d by the log-concavity. Field_simp handles the arithmetic.

---

## Theorem 3: Cross-Domain — Tropical Certificate Diameter Bounds Mixing Time (Deep Proof — Induction + RCases)

```lean
/-- The mixing time of the certificate-guided chain is bounded by
    O(n^{d+1} · log n), where the exponent comes from the tropical
    diameter of the Newton subdivision induced by the certificate. -/
theorem tropical_diameter_bounds_mixing_time
    {n d : ℕ} {f : Polynomial (Fin n → ℚ)}
    (cert : CertificateTree) (hL : IsRecursivelyLorentzian f cert)
    (subdiv : TropicalCertificateSubdivision f cert) :
    ∃ C : ℝ, 
      (certificateMarkovChain f cert).mixingTime ≤ 
        C * (n : ℝ)^(d+1) * Real.log (n : ℝ) ∧
      C ≤ (tropicalDiameter subdiv) := by
  sorry
```

**Proof Strategy:**
1. RCases on the structure of the tropical subdivision: each cell is a tropical polytope of dimension at most d.
2. The tropical diameter of each cell bounds the maximum distance between states in that cell, which bounds the path length in the canonical paths construction.
3. By the canonical paths theorem: `τ_mix ≤ ρ · d_max · log(1/ε)`, where ρ is bounded by n^d (number of states per cell) and d_max is bounded by the tropical diameter.
4. The tropical diameter of a subdivision of the d-simplex in n variables is O(n^{d+1}), giving the claimed bound.

**Why this is cross-domain:** This connects tropical geometry (Newton subdivisions, tropical polytopes) to probability theory (Markov chain mixing) to combinatorics (matroid bases). The tropical diameter is a purely geometric quantity; the mixing time is a purely probabilistic quantity; the theorem says they are *computationally equivalent* for Lorentzian certificates.

---

## Theorem 4: Computational — Expected Sampling Time

```lean
/-- The expected time to produce one sample from the coefficient
    distribution of f using certificate-guided sampling is
    O(n^{d+1} · log n). -/
theorem certificate_sampling_expected_time
    {n d : ℕ} {f : Polynomial (Fin n → ℚ)}
    (cert : CertificateTree) (hL : IsRecursivelyLorentzian f cert)
    (hdeg : f.totalDegree = d) :
    ∃ C : ℝ, C ≤ d * n ^ d ∧
      𝔼[certificateSamplingTime f cert] ≤ C * (n : ℝ)^(d+1) * Real.log (n : ℝ) := by
  sorry
```

**Proof Strategy:** Compose the spectral gap bound (Theorem 1) with the rejection sampling efficiency (Theorem 2). The mixing time gives O(n^d · log n) steps to reach near-stationarity, each step requires O(n) work (computing conditional probabilities at a certificate node), and rejection sampling succeeds with probability ≥ 1/d at each attempt.

---

## Falsifiable Conjecture with Computational Test

**Conjecture (Certificate-Exchange Gap).** For every matroid M on n elements with rank r, the spectral gap of the certificate-guided chain is at least the spectral gap of the basis-exchange walk. That is, certificate-guided sampling is *never worse* than exchange walks.

**Computational Test:** Implement both chains for the uniform matroid U_{k,n}, the graphic matroid of K_n, and the Fano matroid PG(2,2). Compute empirical spectral gaps via eigenvalue estimation. A counterexample would be any matroid where the exchange walk gap exceeds the certificate chain gap by a factor > 1 + ε.

**Disproof protocol:** If found, this would show that certificate structure, while sufficient for recognition, does not always improve sampling — a structural limitation with deep implications for the algorithmic theory of Lorentzian polynomials.

---

## Catalog Integration

- **Builds on:** `IsRecursivelyLorentzian`, `lorentzian_reversed_cauchy_schwarz` from `Pythagorean/LorentzianRecognition.lean`
- **Key bridge:** The reversed Cauchy–Schwarz inequality is the *same* inequality that certifies Lorentzianness and certifies rapid mixing — it is both a structural and algorithmic certificate.
- **New structures:** `CertificateTree`, `CertificateMarkovChain`, `TropicalCertificateSubdivision` — none exist in the catalog.

---

## Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 directions. Each must include "The key insight is..." and "Why now?". At least one must bridge to a different domain (suggestion: quantum Hamiltonian simulation — Lorentzian certificates as ground-state preparation recipes for stoquastic Hamiltonians).

(b) **RESEARCH_PAPER.md** — standalone scientific document. A reader with no code access must understand: (1) what the certificate-guided Markov chain is, (2) why reversed Cauchy–Schwarz implies rapid mixing, (3) how tropical geometry controls mixing time, (4) what the computational experiments show.

(c) **ARTICLE.md** — Scientific American style. Focus on the *idea*: the same mathematical structure that tells you a polynomial is "well-behaved" (Lorentzian) simultaneously gives you an efficient algorithm for sampling from it. No formal verification language.

(d) **Verified algorithm:** `certificateSample` function with termination proof and expected-time bound.

(e) **demo.py:** Interactive demonstration showing certificate-guided sampling vs. basis-exchange walks for graphic matroids, with spectral gap estimation and mixing time visualization.

---

*Soli Deo Gloria*

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
