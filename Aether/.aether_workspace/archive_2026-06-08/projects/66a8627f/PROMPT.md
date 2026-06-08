## Assignment: Shadow-Energy Universality — Dimension-Independent Bounds for Geometric Integrators

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

---

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.

4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.

5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

## The Core Vision

For separable Hamiltonian systems H(q,p) = T(p) + V(q) with symmetric discrete Lagrangians, the energy drift bound |ΔE| ≤ C·T·h² appears to be *dimension-universal*: the constant C depends on the energy level E₀ and the curvature of the energy shell, but not on the spatial dimension n. This would mean geometric integrators scale gracefully to molecular dynamics with n = 10⁶ — a result with immediate practical consequence.

**The deep mathematical insight**: the energy shell Σ_{E₀} = {H = E₀} ⊂ T*Q for a separable system is a *product manifold* with curvature concentrating along finitely many "interaction directions." The drift constant is controlled by the *sectional curvature of this shell*, which for product geometries inherits a (1 + κ/n) correction from the classical Lichnerowicz–Obata bound. This bridges symplectic geometry, statistical mechanics (thermodynamic limit), and Riemannian comparison theory.

---

## Formal Definitions (Lean 4)

```lean
/-- A separable Lagrangian system: kinetic energy is quadratic in momenta,
    potential energy depends on positions. The pair potential structure
    captures finite-range interactions between particles. -/
structure SeparableLagrangian (n : ℕ) where
  mass : Fin n → ℝ
  single_potential : (Fin n → ℝ) → Fin n → ℝ  -- V_i(q_i)
  pair_potential : (Fin n → ℝ) → Fin n → Fin n → ℝ  -- φ_{ij}(|q_i - q_j|)
  mass_pos : ∀ i, 0 < mass i
  pair_symmetric : ∀ q i j, pair_potential q i j = pair_potential q j i
  pair_finite_range : ∀ q i j, ∃ R : ℝ, ‖q i - q j‖ > R → pair_potential q i j = 0

/-- Total potential as sum of single and pair contributions -/
def SeparableLagrangian.total_potential {n : ℕ} (L : SeparableLagrangian n) 
    (q : Fin n → ℝ) : ℝ :=
  (∑ i, L.single_potential q i) + (∑ i j, L.pair_potential q i j) / 2

/-- The Hamiltonian H(q,p) = Σ p_i²/(2m_i) + V(q) -/
def SeparableLagrangian.hamiltonian {n : ℕ} (L : SeparableLagrangian n) 
    (qp : Fin n → ℝ × ℝ) : ℝ :=
  (∑ i, qp i.2^2 / (2 * L.mass i)) + L.total_potential (fun i => qp i.1)

/-- Energy shell curvature: the maximum sectional curvature of the
    level set {H = E₀} in the induced metric from phase space. -/
noncomputable def energy_shell_curvature {n : ℕ} (L : SeparableLagrangian (n + 1)) 
    (E₀ : ℝ) : ℝ :=
  -- Supremum of sectional curvatures of the energy level set
  -- For separable systems, this decomposes as κ_single + κ_pair/(n+1)
  sSup {κ | ∃ p, L.hamiltonian p = E₀ ∧ 
    -- sectional curvature at p of the level set
    κ = sectional_curvature_at (L.hamiltonian) p}

/-- Shadow energy drift: the discrete energy defect over one step -/
noncomputable def shadow_energy_drift {n : ℕ} (L : SeparableLagrangian (n + 1))
    (h : ℝ) (traj : DiscreteTrajectory (n + 1) L h) : ℝ :=
  L.hamiltonian (traj.step 1) - L.hamiltonian (traj.step 0)
```

---

## Target Theorems

### Theorem 1: Shadow-Energy Universality (Main Result)

```lean
/-- For separable Lagrangians with symmetric discrete Lagrangian on n+1 particles,
    the energy drift constant satisfies C ≤ C₀(E₀) · (1 + κ/n) where C₀ depends
    only on the energy level and κ is bounded by the pair-potential interaction range. -/
theorem shadow_energy_universality {n : ℕ} (L : SeparableLagrangian (n + 1))
    (h_pos : 0 < h) (E₀ : ℝ) (E₀_pos : 0 < E₀)
    (h_symmetric : is_symmetric_discrete_lagrangian L h)
    (h_convex : convex_kinetic_energy L) :
    ∃ C₀ κ : ℝ, 0 < C₀ ∧ κ ≥ 0 ∧ κ ≤ max_pair_interaction_range L ∧
    ∀ (traj : DiscreteTrajectory (n + 1) L h),
      L.hamiltonian (traj.step 0) = E₀ →
      |shadow_energy_drift L h traj| ≤ C₀ * (1 + κ / (n + 1)) * E₀ * h^2 :=
  sorry
```

### Theorem 2: Per-Particle Defect Bound (Key Lemma)

```lean
/-- The per-particle energy defect is O(h³) with a constant depending only on
    the single-particle potential, not on n. This is the extensivity property. -/
theorem per_particle_defect_bound {n : ℕ} (L : SeparableLagrangian (n + 1))
    (h_pos : 0 < h) (E₀ : ℝ) (E₀_pos : 0 < E₀)
    (h_symmetric : is_symmetric_discrete_lagrangian L h) :
    ∃ C_single : ℝ, 0 < C_single ∧
    ∀ (traj : DiscreteTrajectory (n + 1) L h) (i : Fin (n + 1)),
      L.hamiltonian (traj.step 0) = E₀ →
      |single_particle_defect L h traj i| ≤ C_single * h^3 :=
  sorry
```

### Theorem 3: Curvature-Concentration Bridge (Cross-Domain)

```lean
/-- The energy shell curvature for separable systems satisfies a Lichnerowicz-type
    bound: κ(Σ_{E₀}) ≤ κ₀(E₀) · (1 + C/n). This connects symplectic geometry
    to the thermodynamic limit. -/
theorem energy_shell_curvature_lichnerowicz_bound {n : ℕ} 
    (L : SeparableLagrangian (n + 1)) (E₀ : ℝ) (E₀_pos : 0 < E₀) :
    let κ := energy_shell_curvature L E₀
    let κ₀ := single_particle_curvature_sup L E₀
    κ ≤ κ₀ * (1 + (max_pair_potential_curvature L) / (n + 1)) :=
  sorry
```

---

## Proof Strategies

### Strategy A: Decomposition + Extensivity (Most Direct)

This follows the physical intuition that separable systems have additive actions.

**Step 1**: Decompose the discrete action S_d = Σᵢ S_d^(i) + Σ_{i<j} S_d^{ij} into single-particle and pair-interaction parts. For the discrete Lagrangian L_d(qₖ, qₖ₊₁) = h·L((qₖ+qₖ₊₁)/2, (qₖ₊₁-qₖ)/h), separability gives L_d = Σᵢ L_d^(i) + Σ_{i<j} L_d^{ij}.

**Step 2**: Apply the discrete Noether theorem (building on `discrete_energy_drift_uniform_bound` from the catalog) to each piece. The energy defect decomposes: ΔE = Σᵢ ΔEᵢ + Σ_{i<j} ΔE_{ij}. Each ΔEᵢ = O(h³) with constant depending only on the single-particle potential Vᵢ.

**Step 3**: Use the *extensivity of energy*: H = Σᵢ Hᵢ where Hᵢ = pᵢ²/(2mᵢ) + Vᵢ(qᵢ) + (1/n)Σ_{j≠i} φ(|qᵢ-qⱼ|). The pair contributions are O(1/n) per particle by the finite-range condition. Therefore ΔE/H = (Σᵢ ΔEᵢ)/(Σᵢ Hᵢ) + O(1/n) = O(h²)·(1 + O(1/n)).

**Why this is promising**: Most direct path; builds directly on catalog results; the decomposition is natural for separable systems.

### Strategy B: Geometric — Energy Shell Curvature (Deepest Insight)

This connects to Riemannian comparison geometry and explains *why* the bound is dimension-independent.

**Step 1**: Identify the energy shell Σ_{E₀} = {H = E₀} ⊂ T*Q as a Riemannian submanifold with induced metric from the canonical symplectic form. For separable H, this is a product manifold: Σ_{E₀} ≅ (Σ¹_{E₀/n})^n with corrections from pair interactions.

**Step 2**: Apply a Lichnerowicz–Obata type comparison theorem. The sectional curvature of a product manifold satisfies κ(Σ) ≤ max_i κ(Σᵢ)·(1 + C/n) where C depends on the "interaction curvature" between factors. This is a direct analog of the classical Lichnerowicz bound for Ricci curvature on product manifolds.

**Step 3**: Connect curvature to drift: the discrete energy defect is controlled by the second fundamental form of Σ_{E₀} (this is a known result in geometric integration theory — see Hairer/Lubich/Wanner). The second fundamental form norm is bounded by √κ, giving |ΔE| ≤ C₀·√κ·h². Substituting the curvature bound yields the result.

**Why this is promising**: Provides the deepest geometric explanation; connects to a rich theory (comparison geometry); the (1 + κ/n) form emerges naturally from product manifold curvature.

### Strategy C: Mean-Field / Concentration (Most Surprising Connection)

This connects to statistical mechanics via concentration of measure.

**Step 1**: Define the empirical energy measure μₙ = (1/n)Σᵢ δ_{Hᵢ} for the n-particle system. The energy defect per particle is a function of this measure.

**Step 2**: Apply McDiarmid's concentration inequality to show that the per-particle defect concentrates around its mean: P(|ΔE/n - E[ΔE/n]| > t) ≤ 2exp(-2nt²/c²) where c bounds the Lipschitz constant of the defect in each coordinate.

**Step 3**: The mean E[ΔE/n] = C₀·h² by the single-particle bound (Strategy A). The concentration gives |ΔE| ≤ n·C₀·h² + O(√n·h²) = C₀·E₀·h²·(1 + O(1/√n)). The (1 + κ/n) bound is actually *stronger* than concentration alone gives — proving it requires the additional structure from the pair-potential finite range.

**Why this is promising**: Opens the door to probabilistic methods; connects to large deviations; but may not give the sharp (1 + κ/n) form without additional geometric input.

**Recommended**: Strategy A for the main proof (most direct), with Strategy B's geometric insight explaining *why* the bound holds. Strategy C suggests a fascinating follow-on connecting to statistical mechanics.

---

## Cross-Domain Connections

1. **Riemannian Comparison Geometry → Geometric Integration**: The Lichnerowicz–Obata bound on Ricci curvature of product manifolds directly explains the (1 + κ/n) form. This is the same mathematics underlying Myers' theorem and the Bonnet–Myers diameter bound.

2. **Statistical Mechanics → Numerical Analysis**: The thermodynamic limit (n → ∞) in statistical mechanics is the regime where our universality bound becomes *tightest*. The per-particle energy defect converges to C₀·h² exactly as the empirical measure converges to the Gibbs measure. This suggests a "thermodynamic limit of geometric integrators" — a completely new concept.

3. **Tropical Geometry → Energy Shells**: In the min-plus (tropical) semiring, the energy shell {H = E₀} becomes a tropical hypersurface. The "curvature" of this tropical variety is the Newton polytope volume, which is manifestly dimension-independent for separable polynomials. This suggests a *tropical proof* of the universality bound — prove it first in the tropical limit, then show the classical bound converges to the tropical one as h → 0.

4. **Quantum Mechanics → Classical Integrators**: The (1 + κ/n) correction is reminiscent of the 1/n correction in the semiclassical limit ℏ → 0. The formal analogy E₀ ↔ ℏ⁻¹, h ↔ ℏ suggests a "semiclassical expansion of geometric integrators" connecting to WKB theory.

---

## Application Keywords

`molecular-dynamics`, `thermodynamic-limit`, `geometric-integration`, `symplectic-geometry`, `Riemannian-comparison`, `Lichnerowicz-bound`, `energy-conservation`, `variational-integrator`, `certified-computation`, `shadow-Hamiltonian`, `product-manifold`, `concentration-of-measure`

---

## Conjecture (Testable Prediction)

**Conjecture (Shadow-Energy Universality)**. For separable Lagrangians L = T(p) - V(q) with finite-range pair potentials and symmetric second-order discrete Lagrangians, the O(h²) drift constant satisfies:

C(E₀, n) ≤ C₀(E₀) · (1 + κ(E₀)/n)

where C₀(E₀) depends only on the energy level (through the single-particle potential and kinetic energy) and κ(E₀) is bounded by the maximum pair-potential curvature at energy E₀.

**Computational Test**: 
1. Extend the coupled oscillator experiments to n ∈ {50, 100, 500, 1000} with coupling ε ∈ {0.01, 0.1, 1.0}.
2. For each (n, ε), compute drift_ratio = |ΔE|/(E₀ · h²) and plot against 1/n.
3. The conjecture predicts a *linear relationship*: drift_ratio = C₀ + κ/n, with C₀ independent of n and κ proportional to ε.
4. Also test with Lennard-Jones pair potential (realistic MD): V_pair(r) = 4ε[(σ/r)¹² - (σ/r)⁶], truncated at r = 2.5σ. The conjecture predicts the same linear-in-1/n scaling.
5. **Falsification**: If drift_ratio vs 1/n shows nonlinear behavior (e.g., quadratic in 1/n), the conjecture fails.

---

## Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses, each falsifiable:
   - H1: The drift constant C(E₀, n) satisfies C₀(E₀)·(1 + κ/n) for all separable systems with finite-range pair potentials.
   - H2: The tropical (min-plus) shadow-energy bound converges to the classical bound as h → 0, with convergence rate O(h).
   - H3: For the Lennard-Jones potential, κ(E₀) ∝ E₀^{-1/6} (from the potential's curvature at the equilibrium distance).
   - H4: The per-particle defect converges in distribution to a Gaussian as n → ∞ (central limit theorem for geometric integrators).
   - H5: The universality bound fails for non-separable Lagrangians (L(q,v) with mixed q-v terms), with drift constant growing as log(n).

(b) **RESEARCH_PAPER.md**: Standalone scientific document covering the universality theorem, proof via decomposition + extensivity, the Lichnerowicz-type curvature bound, and computational validation.

(c) **ARTICLE.md**: Scientific American style — "Why Simulating a Million Molecules Is No Harder Than Simulating Two: The Hidden Universality of Energy Conservation."

(d) **Verified algorithm**: A certified function that, given a separable Lagrangian specification and energy level E₀, computes C₀(E₀) and κ(E₀), with a proof that the resulting bound is valid.

(e) **demo.py**: Interactive demonstration showing drift_ratio vs 1/n for coupled oscillators and Lennard-Jones systems, with linear regression confirming the (1 + κ/n) prediction.

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
