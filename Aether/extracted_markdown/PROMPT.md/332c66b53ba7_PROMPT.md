## Soli Deo Gloria

## Assignment: Quantum Circuit Certification from GL₂ Spectral Gaps — The Diamond Norm Meets the Cayley Graph

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test that could disprove it.

---

## The Vision

The classical spectral gap of a Cayley walk on GL₂(𝔽_q) is not merely a mixing rate for a Markov chain — it is a **quantum information resource**. It deterministically certifies that a specific, explicitly constructed quantum channel scrambles quantum information at a provably optimal rate. This bridges three worlds: **representation theory of finite groups**, **quantum information theory**, and **computational complexity**. The result is not a probabilistic guarantee about random circuits — it is a *deterministic* certification that specific algebraic structure implies quantum scrambling.

---

## Precise Theorem Statements with Lean 4 Type Signatures

### Definition 1: GL₂ Quantum Channel from a Certified Pair

```lean
/-- The adjoint action channel: Ad(U)(ρ) = U ρ U†, represented as a linear map on matrices -/
def adjointActionChannel {n : ℕ} (U : Matrix (Fin n) (Fin n) ℂ) :
    Matrix (Fin n) (Fin n) ℂ →ₗ[ℂ] Matrix (Fin n) (Fin n) ℂ :=
  LinearMap.mk' (fun ρ => U * ρ * U.conjTranspose) sorry -- multiplication bilinearity

/-- The GL₂ quantum channel from a certified pair (g, h).
    Φ(ρ) = (1/4)(U_g ρ U_g† + U_{g⁻¹} ρ U_{g⁻¹}† + U_h ρ U_h† + U_{h⁻¹} ρ U_{h⁻¹}†) -/
noncomputable def gl2QuantumChannel (q : ℕ) [Fact (q.Prime)] 
    (g h : GL₂ (ZMod q)) (cert : CertifiedPair g h) :
    Matrix (Fin (q^2)) (Fin (q^2)) ℂ →ₗ[ℂ] Matrix (Fin (q^2)) (Fin (q^2)) ℂ :=
  LinearMap.mk' (fun ρ =>
    (1/4 : ℂ) • (adjointActionChannel (unitaryRep q g) ρ 
      + adjointActionChannel (unitaryRep q g⁻¹) ρ
      + adjointActionChannel (unitaryRep q h) ρ 
      + adjointActionChannel (unitaryRep q h⁻¹) ρ)) sorry
```

### Definition 2: Haar Twirl Channel (Finite Group Average)

```lean
/-- The G-twirl (Haar average for finite group): Φ_Haar(ρ) = (1/|G|) Σ_{g∈G} U_g ρ U_g† -/
noncomputable def haarTwirlChannel (q : ℕ) [Fact (q.Prime)] :
    Matrix (Fin (q^2)) (Fin (q^2)) ℂ →ₗ[ℂ] Matrix (Fin (q^2)) (Fin (q^2)) ℂ :=
  LinearMap.mk' (fun ρ =>
    (1 / (Fintype.card (GL₂ (ZMod q)) : ℂ)) • 
      ∑ g : GL₂ (ZMod q), adjointActionChannel (unitaryRep q g) ρ) sorry
```

### Definition 3: Frobenius-Norm Contraction Coefficient

```lean
/-- The contraction coefficient of a linear map w.r.t. Frobenius norm on traceless operators -/
noncomputable def contractionCoefficient {n : ℕ} 
    (Φ : Matrix (Fin n) (Fin n) ℂ →ₗ[ℂ] Matrix (Fin n) (Fin n) ℂ) : ℝ :=
  sInf {r : ℝ | ∃ X : Matrix (Fin n) (Fin n) ℂ, X.trace = 0 ∧ X ≠ 0 ∧ 
    ‖Φ X‖_F ≤ r * ‖X‖_F}
```

### Theorem 1: Spectral Gap Bounds Quantum Channel Contraction (REPRESENTATION-THEORETIC)

This is the foundational bridge theorem. It states that the classical spectral gap of the Cayley walk operator on GL₂(𝔽_q) directly controls the contraction rate of the quantum channel on traceless operators. The proof requires decomposing the operator space End(ℂ^{q²}) into isotypic components under the GL₂(𝔽_q) action and showing that the eigenvalues of Φ on each non-trivial component match the eigenvalues of the classical walk operator on the corresponding representation.

```lean
/-- The spectral gap of the certified Cayley walk bounds the contraction of the 
    quantum channel on traceless operators in Frobenius norm. 
    This is the key representation-theoretic bridge. -/
theorem spectral_gap_bounds_quantum_contraction 
    (q : ℕ) [Fact (q.Prime)] (hq : 2 < q)
    (g h : GL₂ (ZMod q)) (cert : CertifiedPair g h)
    (Δ : ℝ) (hΔ : cert.spectralGap ≥ Δ) (hΔ_pos : 0 < Δ)
    -- The contraction coefficient of the quantum channel is at most 1 - Δ
    -- i.e., for any traceless X: ‖Φ(X)‖_F ≤ (1 - Δ) · ‖X‖_F
    (X : Matrix (Fin (q^2)) (Fin (q^2)) ℂ) (hX : X.trace = 0) :
    ‖(gl2QuantumChannel q g h cert) X‖_F ≤ (1 - Δ) * ‖X‖_F := by
  sorry
```

**Proof Strategy A (Most Promising — Representation-Theoretic Decomposition):**
1. Decompose End(ℂ^{q²}) = ℂ·I ⊕ sl_{q²}(ℂ) as a GL₂(𝔽_q)-module, where sl_{q²}(ℂ) is the traceless subspace.
2. Further decompose sl_{q²}(ℂ) = ⊕_π m_π · V_π into isotypic components for irreducible representations π of GL₂(𝔽_q).
3. Show that the eigenvalues of Φ restricted to the isotypic component V_π equal the eigenvalues of the classical walk operator M_S = (1/|S|) Σ_{s∈S} ρ_π(s) on the representation π.
4. Apply the certified spectral gap bound: for all non-trivial π, the largest eigenvalue of M_S on V_π is at most 1 - Δ.
5. Conclude by orthogonality of isotypic components and the Pythagorean property of the Frobenius norm.

**Proof Strategy B (Combinatorial — Direct Eigenvalue Matching):**
1. Show that for any irreducible representation π, the matrix element ⟨v, Φ(X)⟩ = (1/4) Σ_{s∈S} ⟨v, U_s X U_s†⟩ equals the walk operator eigenvalue on π times ⟨v, X⟩, when v and X lie in the same isotypic component.
2. Use Schur orthogonality to show cross-component terms vanish.
3. Apply the spectral gap bound component-wise and sum.

**Why Strategy A is preferred:** It gives the sharpest bound because it exploits the full isotypic decomposition. Strategy B requires more granular control over matrix elements and may lose constants.

### Theorem 2: Certified Design Depth (QUANTUM INFORMATION THEORETIC)

This is the main application theorem. It converts the contraction bound into a concrete statement about approximate unitary 2-designs, which are the quantum information primitive for scrambling, decoupling, and error correction.

```lean
/-- For a certified pair (g, h) in GL₂(𝔽_q), the t-fold quantum channel 
    converges to the Haar twirl exponentially fast.
    Specifically, the Frobenius-norm distance satisfies:
    ‖Φ^t - Φ_Haar‖ ≤ C(q) · (1 - Δ)^t
    where C(q) = √(q⁴ - 1) comes from the dimension of the traceless subspace. -/
theorem certified_design_depth_frobenius
    (q : ℕ) [Fact (q.Prime)] (hq : 2 < q)
    (g h : GL₂ (ZMod q)) (cert : CertifiedPair g h)
    (Δ : ℝ) (hΔ : cert.spectralGap ≥ Δ) (hΔ_pos : 0 < Δ)
    (t : ℕ) :
    ‖((gl2QuantumChannel q g h cert)^[t] - haarTwirlChannel q)‖ ≤ 
      Real.sqrt (q^4 - 1) * (1 - Δ)^t := by
  sorry
```

**Proof Strategy:**
1. Note that the Haar twirl Φ_Haar is the projection onto the trivial isotypic component (scalar multiples of identity) in the decomposition of End(ℂ^{q²}).
2. Therefore Φ^t - Φ_Haar acts as zero on the trivial component and as (eigenvalue_π)^t on each non-trivial isotypic component V_π.
3. The operator norm (from Frobenius norm) is the maximum over non-trivial π of |eigenvalue_π|^t.
4. By Theorem 1, each eigenvalue_π ≤ 1 - Δ, so the norm is at most (1 - Δ)^t.
5. The dimension factor √(q⁴ - 1) comes from bounding the initial distance of a worst-case traceless operator.

### Theorem 3: Cross-Domain — Spectral Gap Implies Entangling Capacity (QUANTUM ↔ INFORMATION THEORY)

This connects the algebraic spectral gap to a genuinely quantum information-theoretic quantity: the ability of the channel to create entanglement between subsystems. A channel with zero spectral gap (reducible Cayley graph) cannot create entanglement efficiently; a channel with large spectral gap can.

```lean
/-- The entangling capacity of the GL₂ quantum channel is lower-bounded by the 
    spectral gap. If we split ℂ^{q²} = ℂ^q ⊗ ℂ^q (via the natural tensor structure 
    from the representation), then the channel maps separable states toward 
    maximally entangled states at a rate controlled by Δ.
    
    Cross-domain connection: This bridges representation theory (spectral gaps) 
    to quantum information theory (entanglement generation). -/
theorem spectral_gap_lower_bounds_entangling_capacity
    (q : ℕ) [Fact (q.Prime)] (hq : 2 < q)
    (g h : GL₂ (ZMod q)) (cert : CertifiedPair g h)
    (Δ : ℝ) (hΔ : cert.spectralGap ≥ Δ) (hΔ_pos : 0 < Δ)
    -- For any separable input ρ = ρ_A ⊗ ρ_B, the output after t steps 
    -- has entanglement entropy at least Δ · t / (2 log q) (up to constants)
    (ρ_A : Matrix (Fin q) (Fin q) ℂ) (ρ_B : Matrix (Fin q) (Fin q) ℂ)
    (hρA : ρ_A.IsDensityMatrix) (hρB : ρ_B.IsDensityMatrix)
    (t : ℕ) :
    entanglementEntropy (gl2QuantumChannel q g h cert)^[t] (ρ_A ⊗ₘ ρ_B) ≥
      Δ * t / (2 * Real.log q) - 1 := by
  sorry
```

**Proof Strategy:**
1. Use the fact that the Haar twirl maps any input to the maximally mixed state on the commutant of GL₂(𝔽_q), which for the natural representation on ℂ^{q²} ≅ ℂ^q ⊗ ℂ^q has high entanglement entropy.
2. The convergence rate from Theorem 2 controls how fast we approach this maximally entangled output.
3. Translate the Frobenius-norm convergence to entanglement entropy convergence using Fannes-type inequalities (continuity of entropy).
4. The spectral gap Δ directly enters as the rate parameter.

### Theorem 4: Quantum Channel is Unital and Trace-Preserving (ALGEBRAIC IDENTITY)

```lean
/-- The GL₂ quantum channel is unital (maps identity to identity) and 
    trace-preserving. These are the defining properties of a quantum channel
    in the Heisenberg and Schrödinger pictures respectively. -/
theorem gl2_channel_unital_trace_preserving
    (q : ℕ) [Fact (q.Prime)] 
    (g h : GL₂ (ZMod q)) (cert : CertifiedPair g h) :
    (gl2QuantumChannel q g h cert) 1 = 1 ∧
    ∀ ρ, (gl2QuantumChannel q g h cert ρ).trace = ρ.trace := by
  sorry
```

**Proof:** Unital: U_g · I · U_g† = U_g · U_g† = I. Sum four identity matrices, divide by 4, get I. Trace-preserving: trace is cyclic, so trace(U ρ U†) = trace(U† U ρ) = trace(ρ). Each term preserves trace, hence the average does.

---

## Conjecture with Testable Prediction

### Conjecture: Optimal Spectral Gap for Quantum Advantage

**Statement**: For any prime q ≥ 5, there exists a certified pair (g, h) in GL₂(𝔽_q) whose spectral gap Δ satisfies:
$$\Delta \geq \frac{1}{2\sqrt{q}}$$

This would imply quantum channels that achieve ε-approximate unitary 2-designs in O(√q · log(q/ε)) applications, which is **sub-linear in the dimension q²** — a quantum speedup over generic random circuits requiring O(q² log(q/ε)) applications.

**Computational Test**: For q = 5, 7, 11, 13, enumerate all certified pairs from the catalog, compute their spectral gaps (eigenvalues of the walk operator on each irreducible representation), and check whether any achieves Δ ≥ 1/(2√q). The conjecture is falsified if no certified pair in GL₂(𝔽_q) achieves this bound for some q.

**Why this matters**: If true, this would be the first deterministic construction of quantum circuits that scramble faster than the generic O(dim²) bound, with direct implications for quantum error correction overhead and quantum cryptography key rates.

### Conjecture: Ramanujan Pairs are Optimal Quantum Scramblers

**Statement**: If (g, h) is a Ramanujan certified pair (i.e., the Cayley graph Γ(GL₂(𝔽_q), {g, g⁻¹, h, h⁻¹}) is a Ramanujan graph), then the associated quantum channel achieves the **optimal** scrambling rate among all 4-generator channels on GL₂(𝔽_q), in the sense that no other certified pair (g', h') can achieve a smaller design depth.

**Computational Test**: For q = 7, compare the design depth of the Ramanujan pair from the catalog against all other certified pairs. Compute the diamond-norm distance after t = 1, 2, ..., 20 steps and verify that the Ramanujan pair achieves the smallest depth for each target ε.

---

## Revolutionary Significance

### What Field This Opens
**Deterministic Quantum Information Theory**: Current quantum information relies heavily on probabilistic arguments — "a random circuit will, with high probability, be a good scrambler." This work replaces "with high probability" with "certifiably," opening the field of **algebraic quantum information** where group-theoretic structure replaces randomness.

### Applications Enabled
1. **Quantum Error Correction**: Certified scrambling circuits are the building blocks of efficient quantum error-correcting codes. The spectral gap directly determines the code distance and the threshold for fault tolerance.
2. **Quantum Cryptography**: Quantum key distribution protocols require that eavesdroppers cannot distinguish channel outputs from random. Certified 2-designs provide this guarantee deterministically, improving key rates.
3. **Black Hole Physics (Hayden-Preskill)**: The fast scrambling conjecture states that black holes scramble quantum information in time O(log N) where N is the number of degrees of freedom. Our O(q log q) rate for GL₂(𝔽_q) circuits (where N = q²) is O(√N log N) — not quite fast scrambling, but the first *deterministic* bound, opening the question of whether algebraic structure can achieve O(log N).

### Follow-on Work Made Possible
1. **GL_n Quantum Channels**: Extend from GL₂ to GL_n, where the richer representation theory (principal series, discrete series, cuspidal representations) may yield faster scrambling rates.
2. **Quantum LDPC Codes from Cayley Graphs**: Use the spectral gap certification to construct quantum LDPC codes with provable minimum distance.
3. **Tropical Quantum Information**: Connect the tropical eigenvalue theory from the catalog to quantum channel capacity, where the tropical spectral gap replaces the classical one.

---

## Mandatory Deliverables

You MUST produce ALL of:

(a) **FUTURE_DIRECTIONS.md** with 3-5 research directions — each must include "The key insight is..." and "Why now?" sentences. At least one direction must bridge to a different domain (suggestion: number theory / automorphic forms ↔ quantum circuit complexity via the trace formula).

(b) **RESEARCH_PAPER.md** — a STANDALONE scientific document. Someone reading ONLY this paper must understand: (1) the representation-theoretic bridge between classical spectral gaps and quantum channel contraction, (2) the certified design depth theorem and its proof via isotypic decomposition, (3) the entangling capacity bound, and (4) what to investigate next. Include the Ramanujan conjecture and its implications.

(c) **ARTICLE.md** in Scientific American style — engaging, accessible. TABOO: Do NOT focus on formal verification or machine verification. Write about the IDEAS: how the algebra of finite groups becomes a quantum information resource, how certification replaces randomness, and what this means for quantum computing.

(d) **A verified algorithm**: Implement the spectral-gap-to-design-depth pipeline as a computable function that takes a certified pair and returns the design depth bound. This should be an `unsafeCompute` or `noncomputable` definition with explicit computational content.

(e) **demo.py** that: (1) constructs the quantum channel for q = 5 from a certified pair, (2) computes the eigenvalue decomposition of the walk operator on each irreducible representation, (3) plots the diamond-norm distance vs. iteration count, (4) verifies the O(q log(q/ε)) convergence rate, and (5) compares against the Ramanujan pair conjecture.

---

## Catalog Integration

Build directly on:
- `Catalog/Pythagorean/GL2SpectralDecomposition.lean` — `certified_gl2_mixing_bound` gives the classical spectral gap bound; `quantum_mixing_decay` provides the exponential decay framework
- The representation-theoretic infrastructure for GL₂(𝔽_q) already in the catalog
- The `CertifiedPair` structure and its properties

The new definitions (`gl2QuantumChannel`, `haarTwirlChannel`, `contractionCoefficient`, `IsDensityMatrix`) and the theorems connecting them to the existing spectral gap infrastructure constitute the novel contribution.

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
