## Assignment: Holographic Primes: The Prime Number AdS/CFT Correspondence

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

The AdS/CFT correspondence says that a gravitational theory in the bulk of anti-de Sitter space is equivalent to a conformal field theory on the boundary. What if prime numbers have a holographic dual? Define the **prime hologram**: for each prime p, define its 'boundary' as the ring Z/pZ and its 'bulk' as the p-adic field Q_p. The central conjecture is that the Riemann zeta function ζ(s) = ∏_p (1 − p^{−s})^{−1} is the holographic partition function: the product over primes (boundary) encodes the same information as the completed zeta function Ξ(s) (bulk). The functional equation Ξ(s) = Ξ(1−s) is the holographic duality: bulk physics at depth s equals boundary physics at depth 1−s. The prime counting function π(x) ~ x/log(x) is the bulk volume, while the Chebyshev function θ(x) = Σ_{p≤x} log(p) is the boundary area. The AdS/CFT dictionary: bulk gravity mode at depth s ↔ boundary CFT operator of dimension 1−s. The Riemann Hypothesis is equivalent to a holographic stability condition — zeros on the critical line means the bulk geometry is stable against perturbations.

### Precise Theorem Statements with Lean 4 Type Signatures

**Definition: HolographicPartitionFunction** — The prime partition function, a product over primes interpreted as a boundary CFT partition function:

```lean
/-- The prime partition function Z(β) = ∏_p (1 - p^(-β))⁻¹
    This is the boundary partition function in the prime hologram.
    For β > 1, this equals the Riemann zeta function ζ(β). -/
def primePartition (β : ℝ) : ℝ :=
  ∏' p : {p : ℕ // Nat.Prime p}, (1 - (p : ℝ)^(-β))⁻¹
```

**Definition: CompletedZeta** — The completed zeta function, interpreted as the bulk partition function:

```lean
/-- The completed zeta function Ξ(s), the bulk partition function.
    Holographic duality states: Ξ(s) = Ξ(1 - s). -/
noncomputable def completedZeta (s : ℂ) : ℂ :=
  s * (s - 1) * (π : ℂ)^(-s/2) * Gamma (s/2) * riemannZeta s
```

**Definition: ChebyshevTheta** — The Chebyshev function, interpreted as the boundary area in the hologram:

```lean
/-- The Chebyshev function θ(x) = Σ_{p ≤ x} log(p)
    This is the boundary area; the bulk volume is x itself. -/
noncomputable def chebyshevTheta (x : ℝ) : ℝ :=
  ∑ p in Finset.filter Nat.Prime (Finset.range (Int.floor x).toNat + 1),
    if (p : ℝ) ≤ x then Real.log p else 0
```

**Theorem 1 (Holographic Factorization)** — The Euler product is the holographic factorization of the global partition function into local (prime) factors:

```lean
/-- The Euler product as holographic factorization:
    The global zeta function (bulk) factorizes as a product over primes (boundary).
    This is the number-theoretic analog of how a bulk partition function
    factorizes into boundary CFT data. -/
theorem euler_product_holographic (s : ℂ) (hs : 1 < s.re) :
    riemannZeta s = ∏' p : {p : ℕ // Nat.Prime p},
      (1 - (p : ℂ)^(-s))⁻¹ := by
  sorry -- Strategy A below
```

**Theorem 2 (Holographic Duality / Functional Equation)** — The completed zeta function satisfies Ξ(s) = Ξ(1−s), the holographic duality:

```lean
/-- The functional equation as holographic duality:
    The bulk partition function at depth s equals the boundary
    partition function at depth 1 - s. This is the prime-theoretic
    AdS/CFT correspondence. -/
theorem holographic_duality (s : ℂ) :
    completedZeta s = completedZeta (1 - s) := by
  sorry -- Strategy B below
```

**Theorem 3 (Volume-Area Correspondence)** — The Chebyshev bound θ(x) < 2x is a weak holographic volume-area correspondence:

```lean
/-- Chebyshev's bound as weak holographic volume-area correspondence:
    The boundary area θ(x) is bounded by a constant times the bulk volume x.
    This is the first step toward the full PNT: θ(x) ~ x. -/
theorem chebyshev_volume_area_bound (x : ℝ) (hx : 1 ≤ x) :
    chebyshevTheta x ≤ 2 * x := by
  sorry -- Strategy C below
```

**Theorem 4 (Cross-Domain: Tropical-Prime Holography)** — The tropicalization of the prime partition function relates to min-plus algebra over primes:

```lean
/-- Tropical holographic correspondence:
    The tropicalization (min-plus) of the prime partition function
    encodes the prime gap structure. This connects number theory
    to tropical geometry. -/
theorem tropical_prime_holography (β : ℝ) (hβ : 1 < β) :
    (∏' p : {p : ℕ // Nat.Prime p}, (1 - (p : ℝ)^(-β))⁻¹) ≤
    Real.exp (∑' p : {p : ℕ // Nat.Prime p}, (p : ℝ)^(-β)) := by
  sorry -- Uses the inequality log(1-x)⁻¹ ≤ x + x² for small x,
        -- then tropical analysis
```

**Conjecture (Holographic Stability / Riemann Hypothesis)**:

```lean
/-- The Riemann Hypothesis as holographic stability:
    All non-trivial zeros of ζ(s) lie on the critical line Re(s) = 1/2.
    In holographic terms: the bulk geometry is stable against perturbations.
    Equivalently: the Mertens function satisfies |M(x)| < C * x^(1/2 + ε). -/
conjecture holographic_stability :
    ∀ s : ℂ, riemannZeta s = 0 → s.re = 1/2 ∨ s = 0 ∨ s = 1
```

### Proof Strategies

**Strategy A (Euler Product via Unique Factorization — for Theorem 1)**:
The key insight is that unique factorization of integers IS the holographic principle: every global object (integer n) decomposes uniquely into local data (prime powers). The proof proceeds:
1. Expand the finite product ∏_{p≤N} (1 − p^{−s})^{−1} as a sum Σ_{n∈S(N)} n^{−s} where S(N) is the set of integers whose prime factors are all ≤ N (use the geometric series and distributivity).
2. Show that S(N) → ℕ\{0} as N → ∞ (every integer has finitely many prime factors).
3. Conclude by absolute convergence for Re(s) > 1.
*This strategy is most promising because it directly reveals the holographic structure: the product over primes (boundary) reconstructs the sum over integers (bulk) via the fundamental theorem of arithmetic.*

**Strategy B (Functional Equation via Poisson Summation — for Theorem 2)**:
The theta function θ(t) = Σ_n e^{−πn²t} satisfies the modular transformation θ(1/t) = t^{1/2} θ(t), which is the "bulk-boundary" map. The proof proceeds:
1. Define the theta function and establish its modular transformation via Poisson summation (this IS the holographic duality at the level of theta functions).
2. Express ζ(s) in terms of θ via the Mellin transform: π^{−s/2}Γ(s/2)ζ(s) = ∫₀^∞ (θ(t) − 1)/2 · t^{s/2−1} dt.
3. Split the integral at t = 1 and apply the modular transformation to obtain the functional equation.
*This strategy is most promising because Poisson summation is the analytic incarnation of holography: it relates a function on the "bulk" (R) to its Fourier dual on the "boundary" (R/Z).*

**Strategy C (Chebyshev Bound via Combinatorial Identities — for Theorem 3)**:
Chebyshev's insight is that binomial coefficients encode prime distribution. The proof proceeds:
1. Establish that the product of primes in (n, 2n] divides C(2n, n) = (2n)!/(n!)².
2. Use the bound C(2n, n) ≤ 4ⁿ (from C(2n,n) < Σ_k C(2n,k) = 2^{2n}).
3. Take logarithms to obtain θ(2n) − θ(n) ≤ n log 4, then telescope to get θ(x) < 2x.
*This strategy is most promising because it is elementary (no complex analysis) and directly reveals the "volume-area" relationship: the boundary area (θ) is bounded by a constant times the bulk volume (x).*

### Cross-Domain Connections

1. **Number Theory + Quantum Physics (AdS/CFT)**: The functional equation Ξ(s) = Ξ(1−s) is the number-theoretic analog of the AdS/CFT correspondence. The "bulk" (completed zeta at depth s) equals the "boundary" (completed zeta at depth 1−s). The critical line Re(s) = 1/2 is the "event horizon" — the surface where bulk and boundary data are in perfect balance.

2. **Number Theory + Tropical Geometry**: The tropicalization of the prime partition function Z(β) = ∏_p (1 − e^{−β log p})^{−1} under the min-plus semiring yields a piecewise-linear function whose corner locus encodes the prime gaps. This connects to tropical hypersurface arrangements and the Newton polygon of the zeta function.

3. **Number Theory + Information Theory**: The fundamental theorem of arithmetic says every integer n = ∏_p p^{a_p} has a unique "code" (a_2, a_3, a_5, …). This is an error-correcting code: the primes form a "basis" for the multiplicative monoid of positive integers. The zeta function is the "partition function" of this code, and the Riemann Hypothesis is a statement about the code's "capacity" (the critical line is the Shannon limit).

4. **Number Theory + Quantum Chaos**: The Montgomery-Dyson observation that the pair correlation of zeta zeros matches the GUE ensemble means that the "bulk quantum gravity" (zeros of ζ) has the same spectral statistics as a random matrix ensemble (the "boundary CFT"). This is the most direct physical manifestation of prime holography.

### Application Keywords

Holographic duality, prime number theory, AdS/CFT correspondence, Riemann zeta function, functional equation, Euler product, Chebyshev function, prime partition function, quantum chaos, random matrix theory, GUE ensemble, tropical geometry, min-plus algebra, local-global principle, Hasse principle, error-correcting codes, statistical mechanics, Bose-Einstein statistics, Mellin transform, Poisson summation, theta functions, modular forms, critical line, Riemann Hypothesis, Mertens function, prime gaps, p-adic analysis, Iwasawa theory, quantum gravity, spectral theory

### Testable Prediction

**Conjecture: Tropical Prime Gap Holography**. Define the "tropical zeta function" ζ_ троп(s) = min_p {s · log(p) − log(1 − p^{−s})}. Then ζ_ троп(s) has a "phase transition" at s = 1 (the pole of ζ), and the corner locus of ζ_ троп encodes the prime gaps in the same way that the critical line of ζ(s) encodes the Riemann zeros. **Computational test**: For s = 1 + ε with ε small, compute ζ_ троп(1+ε) and verify that it approaches log(ε) as ε → 0⁺, mirroring the pole of ζ(s) at s = 1. Further, compute the "tropical zeros" (points where ζ_ троп has a corner) and verify they occur at s = log(p_{n+1})/log(p_n) for consecutive primes p_n, p_{n+1}.

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions — each must include "The key insight is..." and "Why now?" sentences. At least one direction must bridge to a different domain. Write as original prose, not templates.

(b) **RESEARCH_PAPER.md** that is a STANDALONE scientific document — someone reading ONLY this paper (no access to the code) must understand what was discovered, why it matters, and what to investigate next.

(c) **ARTICLE.md** written in Scientific American style — engaging, accessible, explaining the discovery to a broad audience. TABOO: Do NOT focus on formal verification or machine verification — write about the ideas and their significance, not the verification machinery.

(d) A verified algorithm or computational method (not just a theorem statement) — e.g., an algorithm that computes the prime partition function Z(β) and verifies the holographic duality numerically for finite truncations.

(e) **demo.py** that demonstrates the result interactively — compute Z(β) for various β, verify the functional equation Ξ(s) = Ξ(1−s) numerically, and visualize the "prime hologram" (bulk vs. boundary data).

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

Research domain: Speculative
Research mode: prove
