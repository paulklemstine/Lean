## Assignment: Timeline

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

### Research Direction
| Quarter | Direction | Milestone |
|:---|:---|:---|
| Q1 | Direction 1 | Product test formalization on `{1,2,3}^L` |
| Q1–Q2 | Direction 2 | Tensor power spectral transfer lemma |
| Q2 | Direction 5 | Apollonian spectral gap computation |
| Q2–Q3 | Direction 3 | Hypercontractivity for `K₃` noise operator |
| Q3 | Direction 4 | Extractor construction and min-entropy bounds |
| Q4 | Integration | Unified arithmetic pseudorandomness library |

### Mathematical Framing
This program should be treated as a single architecture for **arithmetic pseudorandomness via finite-state spectral analysis**. The conceptual spine is:

1. formalize the discrete product space `{1,2,3}^L` as a ternary analogue of the Boolean cube,
2. transfer one-coordinate spectral information to tensor powers,
3. turn this into hypercontractive smoothing on the complete graph `K₃`,
4. leverage smoothing to certify extraction/min-entropy amplification,
5. connect the abstract spectral language to an arithmetic object with genuine geometric flavor, namely Apollonian dynamics.

The breakthrough target is not “yet another finite Markov-chain estimate,” but a **Lean-certified bridge between spectral graph theory, additive combinatorics, extractor theory, and arithmetic dynamics**.

### Existing Verified Theorems
Build explicitly on:
1. `tensor_gap_bound` : theorem `tensor_gap_bound (Δ₁ Δ₂ : ℝ) : ...`
   - file: `Algebra/SpectralLens/Robustness.lean`
   - use this as the seed mechanism for proving that one-step contraction parameters compose under product/tensor constructions.
2. `smooth_density_min_gap` : theorem `smooth_density_min_gap (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) : ...`
   - file: `Algebra/AutoResearch/DeepOpenProblems.lean`
   - use this as an arithmetic positivity/separation certificate when translating combinatorial flattening into explicit lower-gap statements.
3. `spectral_gap_nonneg` : theorem `spectral_gap_nonneg (g : SpectralGap) : g.width ≥ 0 := by ...`
   - file: `Algebra/IntegerEnergy/GravitomagneticFrontiers.lean`
   - use this to eliminate sign pathologies in all later estimates.
4. `spectral_gap_condition` : theorem `spectral_gap_condition (ev_max ev_min gap : ℝ) : ...`
   - file: `Algebra/SpectralArithmetic/Bridges.lean`
   - use this to package eigenvalue inequalities into reusable hypotheses.
5. `montgomery_spectral_gap_certifies_robustness` : theorem `montgomery_spectral_gap_certifies_robustness : ...`
   - file: `Algebra/SpectralLens/Core.lean`
   - this is the prototype for turning spectral information into a certified pseudorandomness/robustness statement.

### Cold-Start Priority
Because there are no previous completed cycles, do **two things in parallel**:

- **Track A, closure:** if you locate priority `sorry`s around `CarmichaelComposite` or `Fib_gcd_identity`, clear them quickly to improve the global library.
- **Track B, breakthrough:** focus the main effort on the theorem package below, which is the real research payload.

---

# Mode: prove

## Central Theorem Package

### Theorem 1: Tensor-power spectral transfer on the ternary cube
Formalize the ternary product state space and prove that a one-coordinate mean-zero contraction transfers to the full product operator with dimension-free control.

#### Precise mathematical statement
Let `T : ℝ^3 → ℝ^3` be a self-adjoint Markov operator preserving constants, with second eigenvalue bounded by `ρ` in absolute value, `0 ≤ ρ ≤ 1`. Let `T_L` be the `L`-fold tensor power acting on functions `f : (Fin L → Fin 3) → ℝ`. Then for every mean-zero `f`,
\[
\|T_L f\|_2 \le ρ \|f\|_2.
\]
Equivalently: the spectral gap of the product operator is at least the one-coordinate gap.

This is the formal hinge on which hypercontractivity and extraction can turn.

#### Lean 4 target signature
A plausible Lean target, using finite functions and Euclidean norms, is:

```lean
theorem ternary_tensor_power_L2_contraction
  (L : ℕ)
  (T : Matrix (Fin 3) (Fin 3) ℝ)
  (hmarkov : IsMarkovKernel T)
  (hsymm : Tᵀ = T)
  (ρ : ℝ)
  (hρ : 0 ≤ ρ ∧ ρ ≤ 1)
  (hconst : T.mulVec (fun _ => (1 : ℝ)) = fun _ => (1 : ℝ))
  (hspec :
    ∀ v : (Fin 3 → ℝ),
      (∑ i, v i) = 0 →
      ‖T.mulVec v‖ ≤ ρ * ‖v‖) :
  ∀ f : ((Fin L → Fin 3) → ℝ),
    (∑ x, f x) = 0 →
    ‖tensorPowerOp L T f‖ ≤ ρ * ‖f‖
```

If this exact signature is too ambitious for existing infrastructure, first define a finite-dimensional inner-product-space wrapper specialized to `Fin n → ℝ`.

#### Why this is a breakthrough
This theorem is the formal spectral backbone of the entire timeline. Once certified in Lean, it becomes a reusable engine for:
- product tests on ternary alphabets,
- dimension-free mixing bounds,
- noise sensitivity and hypercontractivity,
- extractor analysis on non-Boolean domains.

It opens the door to a **formal theory of high-dimensional pseudorandomness beyond the Boolean cube**.

---

### Theorem 2: Hypercontractive inequality for the `K₃` noise operator
Define the canonical noise operator on the 3-point space and prove a sharp or near-sharp `2 → 4` inequality on the product space.

#### Precise mathematical statement
Let `N_ρ` be the ternary noise operator on `{1,2,3}^L` that keeps a coordinate with probability `ρ` and resamples uniformly with probability `1-ρ`. Then there exists an explicit threshold `ρ₀ ≤ 1/√3` (or stronger, if you can prove it) such that for all `L` and all functions `f : {1,2,3}^L → ℝ`,
\[
\|N_ρ f\|_4 \le \|f\|_2 \quad \text{for all } 0 \le ρ \le ρ₀.
\]

Even a certified non-sharp constant with complete proof is valuable, but push toward the optimal threshold.

#### Lean 4 target signature
```lean
theorem K3_noise_two_to_four_hypercontractive
  (L : ℕ) (ρ : ℝ)
  (hρ : 0 ≤ ρ)
  (hρbound : ρ ≤ (1 / Real.sqrt 3))
  (f : (Fin L → Fin 3) → ℝ) :
  lpNorm 4 (ternaryNoiseOp L ρ f) ≤ lpNorm 2 f
```

If `lpNorm` on finite spaces is inconvenient, define
```lean
def finLpNorm (p : ℝ) (f : α → ℝ) : ℝ := ...
```
for `Fintype α`.

#### Why this is a breakthrough
This would be a genuine formal analogue of Bonami–Beckner theory on a non-Boolean product space. It would create a new certified toolkit for:
- small-set expansion on ternary spaces,
- influence theory outside the cube,
- quantitative pseudorandomness for 3-ary encodings,
- entropy flattening arguments in extractor constructions.

This is not a routine port; it is the birth of a **Lean-native harmonic analysis on finite non-binary product spaces**.

---

### Theorem 3: Spectral extraction from ternary smoothing
Use the hypercontractive package to derive a min-entropy/extractor theorem.

#### Precise mathematical statement
Construct an explicit function
\[
\mathrm{Ext}_L : \{1,2,3\}^L \to \{0,1\}^m
\]
for some `m = m(L,k)` such that if `X` is a source on `{1,2,3}^L` with min-entropy at least `k`, then
\[
\|\mathrm{Ext}_L(X) - U_m\|_{\mathrm{TV}} \le \varepsilon
\]
for explicit parameters derived from the spectral/hypercontractive bounds.

A first target may be a one-bit extractor with nontrivial entropy threshold; a stronger target is a multi-bit extractor via block decomposition.

#### Lean 4 target signature
A realistic first theorem:

```lean
theorem ternary_one_bit_extractor_tv_bound
  (L : ℕ)
  (Ext : (Fin L → Fin 3) → Bool)
  (k : ℝ)
  (ε : ℝ)
  (hε : 0 ≤ ε)
  (hExt_spec : IsSpectralOneBitExtractor L Ext k ε) :
  ∀ μ : PMF (Fin L → Fin 3),
    minEntropy μ ≥ k →
    totalVariationDist (μ.map Ext) (uniformPMF Bool) ≤ ε
```

Then strengthen by constructing `Ext` explicitly.

#### Why this is a breakthrough
This would connect certified finite harmonic analysis to certified randomness extraction. The field-opening implication is a **formal pseudorandomness pipeline**:
spectral gap ⇒ hypercontractivity ⇒ entropy smoothing ⇒ extraction.

This has downstream relevance to derandomization, coding theory, and hardness amplification.

---

### Theorem 4: Arithmetic-dynamical spectral gap for Apollonian transitions
Model a finite quotient or finite truncation of an Apollonian-type transition graph and prove a positive spectral gap certificate.

#### Precise mathematical statement
Let `G_N` be a finite graph obtained from Apollonian orbit transitions modulo `N` or within a bounded curvature truncation. Prove that the normalized adjacency operator has nontrivial spectral gap:
\[
\lambda_2(G_N) \le 1 - \delta
\]
for some explicit `\delta > 0` in a nontrivial family of cases.

A weaker but still meaningful target is a Lean-certified computational theorem:
for explicitly constructed small `N`, the operator norm on the orthogonal complement of constants is strictly less than 1.

#### Lean 4 target signature
```lean
theorem apollonian_finite_quotient_spectral_gap
  (N : ℕ)
  (hN : 2 ≤ N)
  (G : SimpleGraph (ApollonianState N))
  (hreg : IsRegularOfDegree G d)
  (δ : ℝ)
  (hδ : 0 < δ)
  (hspec : secondEigenvalueBound G (1 - δ)) :
  spectralGap G ≥ δ
```

If quotient-level arithmetic dynamics is too large for one cycle, prove instead a concrete finite-instance theorem with explicit matrices.

#### Why this is a breakthrough
This is the arithmetic anchor that prevents the project from floating away into abstract analysis. A certified spectral gap for Apollonian dynamics would connect:
- expander heuristics,
- thin groups,
- arithmetic orbits,
- formalized spectral computation.

This is exactly the kind of cross-pollination that can open a new formalized subfield: **certified arithmetic dynamics via spectral methods**.

---

## Proof Strategy Architecture

### Strategy A: Eigenbasis / Fourier-on-`K₃` decomposition
Most promising for Theorems 1 and 2.

1. Diagonalize the one-coordinate operator on `Fin 3 → ℝ` into constants plus a 2-dimensional mean-zero eigenspace.
2. Build the product basis on `(Fin L → Fin 3) → ℝ` by tensoring coordinate eigenfunctions.
3. Show the product operator acts diagonally with eigenvalues given by products of coordinate eigenvalues; deduce the `L²` contraction and then the `2 → 4` estimate by levelwise expansion.

Why promising:
- finite-dimensional and exact,
- naturally compatible with Lean’s matrix library,
- gives explicit formulas rather than soft inequalities,
- scales to later influence theory.

### Strategy B: Dirichlet form / semigroup interpolation
Most promising for a robust, reusable library.

1. Define the Dirichlet form associated to the `K₃` noise operator and prove tensorization of entropy or energy.
2. Derive a logarithmic Sobolev or Nash-type inequality on the base 3-point chain.
3. Tensorize to the full product and integrate the differential inequality to obtain hypercontractivity.

Why promising:
- conceptually deep and extensible,
- better suited for future generalization to arbitrary finite alphabets,
- creates reusable formal infrastructure for Markov semigroups and entropy methods.

Why it may be harder:
- requires more analysis infrastructure in Lean,
- norm interpolation and entropy formalization can be technically heavy.

### Strategy C: Combinatorial moment method
Especially useful if sharp hypercontractivity is out of reach.

1. Expand `‖N_ρ f‖_4^4` as a finite sum over quadruples.
2. Use coordinate independence and orthogonality relations on the ternary basis to annihilate mixed terms.
3. Bound surviving terms by `‖f‖_2^4` with an explicit admissible `ρ`.

Why useful:
- can yield a non-sharp but formalizable theorem quickly,
- avoids full semigroup machinery,
- may be ideal for a first certified `2 → 4` inequality.

Recommended order:
- **Start with Strategy A for Theorem 1.**
- Use **Strategy C** to get an initial hypercontractive theorem.
- Then revisit with **Strategy B** if you want the conceptual crown jewel.

---

## How to Use the Catalog Theorems
Do not cite the catalog passively; absorb it into the architecture.

- Use `tensor_gap_bound` as the first bridge from one-coordinate contraction to product contraction. If its statement is abstract, instantiate it with the `K₃` operator and show the product theorem is a concrete corollary.
- Use `spectral_gap_condition` to turn explicit eigenvalue computations into packaged gap hypotheses.
- Use `spectral_gap_nonneg` to simplify all inequalities involving gap widths and avoid duplicated positivity arguments.
- Use `montgomery_spectral_gap_certifies_robustness` as a model for converting a gap theorem into a pseudorandomness/extractor guarantee.
- Use `smooth_density_min_gap` when an arithmetic lower bound is needed in the Apollonian or extractor layer, especially when converting a density statement into a certified nondegeneracy/gap estimate.

---

## Cross-Domain Connections
You must explicitly connect the work to at least one neighboring domain in the statements, documentation, or examples.

1. **Additive combinatorics**
   - Hypercontractivity on `{1,2,3}^L` is a finite-state smoothing principle.
   - This is morally parallel to flattening inequalities and sum-product phenomena.

2. **Theoretical computer science**
   - Product tests, noise stability, and extractor bounds are core pseudorandomness technology.
   - A Lean-certified ternary framework could support PCP-style tests or hardness amplification on non-Boolean alphabets.

3. **Arithmetic dynamics / thin groups**
   - Apollonian transitions provide a nontrivial arithmetic system where spectral gap controls orbit equidistribution heuristics.
   - This links finite harmonic analysis with number-theoretic expansion.

4. **Information theory**
   - Hypercontractivity is an entropy contraction principle in disguise.
   - Extraction theorems can be reframed as certified information dissipation under noise.

5. **Statistical mechanics**
   - The `K₃` product chain is a three-state spin system at infinite temperature with noise.
   - Spectral/hypercontractive control parallels mixing and decay of correlations.

Application keywords:
**hypercontractivity, spectral gap, tensorization, extractor, min-entropy, pseudorandomness, finite Markov chain, Apollonian packing, arithmetic dynamics, additive combinatorics, noise stability, formal verification**

---

## Concrete Lean Build Plan

### Phase 1: Base-space infrastructure
Define and prove:
- `ternaryUnif : PMF (Fin 3)`
- mean-zero subspace for `Fin 3 → ℝ`
- `IsMarkovKernel` helper lemmas for `3 × 3` matrices
- `tensorPowerOp` on finite product spaces
- finite `L²` and `L⁴` norms on `Fintype`

### Phase 2: Product spectral theorem
Prove:
- constants are fixed by the operator,
- orthogonal decomposition into constant and mean-zero parts,
- tensor eigenbasis lemma,
- `ternary_tensor_power_L2_contraction`.

### Phase 3: Hypercontractive theorem
Prove one of:
- sharp `ρ ≤ 1 / sqrt 3`,
- or a weaker explicit constant sufficient for extraction.
A fully formal weaker theorem is better than an unformalized optimal theorem.

### Phase 4: Extraction theorem
Define:
- collision/min-entropy for finite PMFs,
- total variation distance,
- a spectral extractor predicate.
Then prove a one-bit extractor theorem from your smoothing inequality.

### Phase 5: Arithmetic bridge
Choose one:
- finite quotient Apollonian graph modulo small `N`,
- or a truncation with explicit adjacency matrix.
Compute/prove a positive gap certificate and connect it to the general spectral machinery.

---

## Minimal Theorem Bundle for This Cycle
If time is limited, deliver at least the following:

1. `ternary_tensor_power_L2_contraction`
2. a nontrivial `K₃` hypercontractive theorem with explicit constant
3. one theorem converting spectral smoothing into a total variation or min-entropy bound
4. one arithmetic example certifying a spectral gap for a concrete finite graph inspired by Apollonian transitions

That bundle already constitutes a new formal research direction.

---

## Documentation Requirement
Produce a structured `FUTURE_DIRECTIONS.md` with **3–5 concrete, breakthrough-level next steps**, each containing:
- exact theorem target,
- why it matters,
- required new definitions,
- likely proof strategy,
- dependency on this cycle’s results.

Suggested future directions include:
1. sharp Beckner inequality for `q`-ary product spaces,
2. influence/KKL theory on `{1,2,3}^L`,
3. inverse theorems for ternary noise stability,
4. certified extractor families with explicit output length,
5. expansion in thin arithmetic group quotients via reusable spectral interfaces.

---

## Team Directive
Create a research team with explicit roles:

- **Spectral Architect**: designs the tensor/eigenbasis framework.
- **Lean Integrator**: builds reusable finite-norm and matrix infrastructure.
- **Pseudorandomness Analyst**: translates hypercontractivity into extraction statements.
- **Arithmetic Scout**: constructs finite Apollonian transition graphs and spectral certificates.
- **Verification Auditor**: minimizes `sorry`, checks theorem reuse, and writes clean API lemmas.

Run the cycle iteratively:
1. brainstorm conjectures,
2. test on small finite instances,
3. formalize the strongest surviving statement,
4. update the library,
5. record next conjectures in `FUTURE_DIRECTIONS.md`.

Required: Lean 4 proofs, minimized `sorry`, concrete definitions, cross-domain impact, and a genuine attempt at a field-opening spectral pseudorandomness library.

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
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

**Team Directive**: Create a team to conduct research, brainstorm hypotheses,
run experiments, validate data, update knowledge base and iterate forever.
Each future direction should be specific enough for a team to pick up and
pursue with clear hypotheses, proof strategies, and cross-domain connections.

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
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Algebra
Research mode: prove
