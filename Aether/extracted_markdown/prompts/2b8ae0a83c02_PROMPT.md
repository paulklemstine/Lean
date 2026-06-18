## Assignment: Quantitative Data Processing Inequality for CRYSTALS-Kyber Compression — From Abstract DPI to NIST-Verified Post-Quantum Security

### The Grand Challenge

The Data Processing Inequality (DPI) gives a *qualitative* guarantee: compression cannot increase distinguishing advantage. But for CRYSTALS-Kyber — the NIST-standardized post-quantum KEM where q = 3329 (prime) and d ∈ {2¹⁰, 2¹¹} — we need a *quantitative* contraction bound. This is the missing link between abstract information theory and concrete cryptographic engineering. No one has formally verified this bound for actual NIST parameters.

### Novel Mathematical Structure

Define a **FiberContraction** that captures how a deterministic map between finite rings compresses distinguishability through its fiber geometry:

```lean
/-- A fiber contraction certificate for a map f : α → β between finite types,
    recording the fiber size distribution and proving a contraction bound on
    decision advantage for smooth distributions. -/
structure FiberContraction (α β : Type*) [Fintype α] [Fintype β] (f : α → β) where
  fiber_sizes : β → ℕ
  fiber_card : ∀ y, Finset.card (Finset.filter (fun x => f x = y) Finset.univ) = fiber_sizes y
  fiber_balance : ∀ y, fiber_sizes y ∈ {Fintype.card α / Fintype.card β, 
                                          Fintype.card α / Fintype.card β + 1}
  num_large_fibers : ℕ
  large_fiber_count : num_large_fibers = Fintype.card α % Fintype.card β
  smooth_contraction : ∀ (χ ν : PMF α) (L : ℝ),
    (∀ x, χ x ≤ L / Fintype.card α) →
    (∀ x, ν x = 1 / Fintype.card α) →
    decisionAdvantage (PMF.map f χ) (PMF.map f ν) ≤
      (Fintype.card β / Fintype.card α : ℝ) * L * decisionAdvantage χ ν
```

This structure simultaneously encodes: (1) the **Beatty sequence** structure of modular rounding fibers, (2) the **exact enumeration** of large vs. small fibers, and (3) the **smooth contraction bound** that trades distribution smoothness for contraction strength.

### Core Theorems (Lean 4 Signatures)

**Theorem 1: Kyber Fiber Structure** — *The modular rounding map creates an irregular partition governed by the remainder q mod d.*

```lean
theorem kyber_compress_fiber_structure (q d : ℕ) (h_prime : Prime q) 
    (h_coprime : Nat.gcd q d = 1) (y : ZMod d) :
    Finset.card (Finset.filter (fun x => kyber_compress q d x = y) Finset.univ) = 
      if (y.val : ℕ) < q % d then q / d + 1 else q / d := by
  sorry
```

*Proof Strategy A (Direct modular arithmetic):* Decompose Z/qZ into intervals of length ⌊q/d⌋ or ⌈q/d⌉. The rounding map sends each interval to a single output. The number of "long" intervals equals q mod d by the division algorithm. Since q = 3329 is prime and d is a power of 2, gcd(q,d) = 1, ensuring the intervals are well-distributed (no "clumping" of long intervals). This is essentially a Beatty sequence partition: the sequence {⌊nq/d⌋ mod d} for n = 0, ..., d-1 partitions Z/dZ into the fiber representatives.

*Proof Strategy B (Group-theoretic via coset structure):* View compress: Z/qZ → Z/dZ as a composition of the natural map Z/qZ → Z/(q mod d)Z with a "staircase" function. The fibers form a "quasi-coset" decomposition where the group structure of Z/qZ (a field since q is prime) ensures uniform fiber distribution. Use `ZMod.eq_mul_inv_mod` and the field structure to characterize fibers.

*Strategy A is preferred:* It directly connects to the Beatty sequence literature and generalizes to non-prime q via the same interval decomposition.

**Theorem 2: Smooth Contraction Bound** — *For distributions that are L-smooth (bounded PMF), the decision advantage contracts by a factor proportional to the compression ratio times the smoothness parameter.*

```lean
theorem kyber_smooth_contraction (q d k : ℕ) (χ : PMF (ZMod q)^(Fin k))
    (L : ℝ) (hL : 0 < L)
    (h_smooth : ∀ x, χ x ≤ L / (q : ℝ)^k) :
    decisionAdvantage (PMF.map (compress_vec q d k) χ) 
                     (PMF.map (compress_vec q d k) (PMF.uniformOfFintype (ZMod q)^(Fin k)))
    ≤ (d / q : ℝ)^k * L * decisionAdvantage χ (PMF.uniformOfFintype (ZMod q)^(Fin k)) := by
  sorry
```

*Proof Strategy A (Fiber-by-fiber TV decomposition):* Write TV(compress_* χ, compress_* uniform) = (1/2)∑_y |∑_{x ∈ f⁻¹(y)} (χ(x) - 1/q^k)|. Within each fiber of size s ≈ (q/d)^k, apply the smoothness bound: each summand |χ(x) - 1/q^k| ≤ (L-1)/q^k. The fiber sum is at most s·(L-1)/q^k ≈ (L-1)·(d/q)^k. Summing over d^k fibers gives total ≤ (L-1)·(d/q)^k. Compare with TV(χ, uniform) ≥ (L-1)/q^k · |support(χ)| to extract the ratio.

*Proof Strategy B (Rényi divergence contraction):* First prove that for L-smooth χ, the Rényi divergence D₂(χ || uniform) ≤ log(L). Then prove that the compression map contracts Rényi divergence by a factor of (d/q)^k via the fiber structure. Finally, connect Rényi divergence to TV distance using the inequality TV ≤ √(D₂/2). This gives a bound of √(L·(d/q)^k/2), which is weaker than Strategy A for small L but stronger for large L. *Strategy A is preferred* for the tight bound.

*Proof Strategy C (Coupling + birthday paradox):* Construct an optimal coupling (X,Y) with X ~ χ and Y ~ uniform. The compression sends this to (f(X), f(Y)). Bound P(f(X) ≠ f(Y)) ≤ P(X ≠ Y) · max_fiber_overlap_ratio. The max fiber overlap ratio is (⌈q/d⌉)/(q) ≈ 1/d, giving the (d/q)^k factor in dimension k. This is elegant but requires developing the coupling framework; use as a fallback if Strategy A encounters difficulties.

**Theorem 3: Kyber Parameter Verification** — *The concrete NIST parameters satisfy the fiber structure and yield explicit contraction bounds.*

```lean
theorem kyber_params_fiber_contraction : 
    let q := 3329; let d₁ := 1024; let d₂ := 2048
    -- d₁ = 2^10 (Kyber-768 compression)
    -- d₂ = 2^11 (Kyber-1024 compression)
    -- 3329 mod 1024 = 257, so 257 fibers of size 4, 767 fibers of size 3
    -- 3329 mod 2048 = 1281, so 1281 fibers of size 2, 767 fibers of size 1
    (q % d₁ = 257) ∧ (q % d₂ = 1281) ∧
    (d₁ : ℝ) / q ≤ 1024/3329 ∧ (d₂ : ℝ) / q ≤ 2048/3329 := by
  sorry
```

### Cross-Domain Connections

1. **Number Theory ↔ Cryptography:** The fiber structure of modular rounding is precisely a **Beatty sequence** partition. The classical theorem that {⌊nα⌋ : n ∈ ℕ} and {⌊nβ⌋ : n ∈ ℕ} partition ℕ when 1/α + 1/β = 1 (Rayleigh theorem) governs the fiber size distribution. For Kyber with q prime and d = 2^n, the Beatty parameter α = q/d is irrational, ensuring the "large" and "small" fibers are optimally interspersed — this is why Kyber chose q = 3329 (a prime near a power of 2, with specific modular properties).

2. **Information Theory ↔ Tropical Geometry:** The contraction ratio (d/q)^k is the **tropical product** of per-coordinate contraction ratios. Viewing the compression map through tropical algebra (min-plus semiring), the fiber structure becomes a tropical hyperplane arrangement, and the contraction bound becomes a tropical distance inequality. This connects `Catalog/Tropical/` results to cryptographic compression.

3. **Additive Combinatorics ↔ Post-Quantum Security:** The Cauchy-Davenport theorem bounds the size of sumsets in Z/qZ. For the Kyber compression, the "fibers" of compress(a + b) are controlled by the sumset structure of the fibers of compress(a) and compress(b). This gives a **sumset contraction** bound: |compress(A) + compress(B)| ≥ min(d, |A| + |B| - 1) when gcd(q,d) = 1, connecting to the security of the public key compression.

4. **Statistical Mechanics ↔ Lattice Cryptography:** The smoothness parameter L in Theorem 2 is analogous to the **inverse temperature** β = 1/σ² in a Boltzmann distribution. The contraction bound L·(d/q)^k corresponds to the **free energy cost** of constraining a system to a coarse-grained lattice. The "phase transition" at L = (q/d)^k corresponds to the threshold where compression destroys all distinguishability.

### Testable Conjecture (Falsifiable)

**Conjecture (Sharp Gaussian Contraction):** For the discrete Gaussian distribution D_{Z,q,σ} on Z/qZ with parameter σ, the contraction ratio under Kyber compression satisfies:

```
decisionAdvantage(compress_* D_{Z,q,σ}, compress_* U(Z/qZ)) 
    ≤ (d/q) · (σ√(2π)/q) · (1 + O(1/q))
```

with the bound achieved asymptotically as σ → √(q/(2π)) (the "critical smoothness" where the Gaussian becomes nearly uniform).

**Computational Test:** For q = 3329, d = 1024, σ ∈ {1, 2, 3, ..., 30}:
1. Compute the exact decision advantage before and after compression by enumerating the PMF.
2. Plot the contraction ratio as a function of σ.
3. Verify that the ratio approaches (d/q) as σ increases past √(q/(2π)) ≈ 23.
4. Check that the ratio exceeds (d/q) for small σ (this would falsify the unqualified conjecture and confirm the need for the smoothness parameter L).

**Falsification criterion:** If the contraction ratio exceeds (d/q) · L for any L-smooth distribution with L ≤ q, the conjecture is false and the bound must be revised.

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
   - H1: The Beatty sequence structure of Kyber compression fibers is optimal (minimizes worst-case contraction ratio) among all maps Z/qZ → Z/dZ with the same fiber size distribution.
   - H2: For Module-LWE noise with covariance Σ, the contraction ratio is (d/q)^k · √(det(Σ)) · C where C is a universal constant.
   - H3: The Rényi divergence of order α contracts by a factor of (d/q)^{k(α-1)} under k-dimensional Kyber compression.
   - H4: Replacing q = 3329 with any prime p > 2d with gcd(p, d) = 1 preserves the (d/p)^k contraction bound up to a (1 + O(1/p)) factor.
   - H5: The contraction bound is tight: there exist smooth distributions achieving contraction ratio within a factor of 2 of (d/q)^k · L.

(b) **RESEARCH_PAPER.md** — A standalone document proving the fiber structure theorem, the smooth contraction bound, and the Kyber parameter verification. Must include the coupling argument, the Beatty sequence connection, and computational verification of the contraction ratio for σ ∈ {1, ..., 30}.

(c) **ARTICLE.md** — "How a 1000-Year-Old Number Theory Result Secures Post-Quantum Cryptography" — explain how Beatty sequences (studied since Rayleigh, 1894) govern the security of the NIST post-quantum standard, and why the fact that 3329 is prime matters for your encrypted messages.

(d) **Verified Algorithm:** A certified computation of the fiber structure and contraction bound for all three Kyber parameter sets (Kyber-512, Kyber-768, Kyber-1024), with the fiber enumeration verified against the Beatty sequence formula.

(e) **demo.py** — Interactive visualization showing: (1) the fiber structure of compress: Z/3329Z → Z/1024Z as a histogram of fiber sizes, (2) the contraction ratio as a function of the smoothness parameter L, (3) the decision advantage before/after compression for discrete Gaussians with varying σ, and (4) comparison of the theoretical bound with the empirically computed contraction ratio.

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
