## Soli Deo Gloria

## Assignment: Direction 2: Formal Kepler's Three Laws — The Hidden Symmetry Path

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

**Conjecture**: From the verified orbit equation r(θ) = p/(1 + e·cos θ), derive all three of Kepler's laws AND prove that the Runge-Lenz vector is conserved, establishing the hidden SO(4)/SO(3) symmetry of the bound Kepler problem — the first formal verification of the deep algebraic structure behind celestial mechanics.

**The Three Laws**:
1. **(Law of Orbits)** Bound trajectories (E < 0) are ellipses with the force center at one focus: the set {(r(θ), θ) | θ ∈ [0, 2π)} satisfies the Cartesian equation (x + ae)²/a² + y²/b² = 1 where b² = a²(1 − e²).
2. **(Law of Areas)** The radius vector sweeps equal areas in equal times: the areal velocity Ė_A = L/(2m) is constant, following from angular momentum conservation d(L)/dt = 0.
3. **(Law of Periods)** T² = (4π²m/k)·a³, where a = p/(1−e²) is the semi-major axis, derived by integrating the ellipse area A = πa²√(1−e²) over the constant areal velocity.

**The Hidden Symmetry**: The Runge-Lenz vector **A** = **p** × **L** − mk**r̂** is conserved iff the force law is exactly 1/r². This is WHY Kepler's laws hold — the additional conserved quantity makes the Kepler problem maximally superintegrable (3 conserved quantities in 2D: E, L, |**A**|), forcing closed orbits and enabling the period-orbit size relation. The conserved **A** points along the major axis with |**A**| = mke, directly encoding the eccentricity.

**Test**: For 100 random (m, k, E, l) with E < 0:
- (a) Compute areal velocity over equal time intervals (verify constant to 1e-10)
- (b) Period from numerical integration vs T = 2π√(a³m/k) (verify to 1e-8)
- (c) Ellipse geometry: sum of distances to foci = 2a (verify to 1e-10)
- (d) **Runge-Lenz conservation**: compute |**A**(t₁) − **A**(t₂)| at 50 time pairs (verify < 1e-10)
- (e) **Symmetry test**: verify that the 6 conserved quantities (L, A_x, A_y, E) satisfy the SO(4) Lie algebra relation: {L_i, A_j} = ε_{ijk} A_k, {A_i, A_j} = −(2|E|/m) ε_{ijk} L_k

**Impact**: This is not merely formalizing a physics textbook. The Runge-Lenz vector is the gateway to:
- **Quantum Kepler problem**: The SO(4) symmetry explains the accidental degeneracy of the hydrogen atom (n² degeneracy), which Bohr and Pauli discovered but could not derive from rotational symmetry alone.
- **Bertrand's theorem**: Only 1/r² and r² potentials have closed bounded orbits — the Runge-Lenz vector is the certificate of this exceptional structure.
- **Mars-Gravity-Assist design**: The hidden symmetry constrains orbit transfer topology, enabling verified trajectory optimization.
- **Integrable systems theory**: The Kepler problem is the paradigmatic superintegrable system; formalizing it opens the door to the entire theory of action-angle variables.

**Catalog References**: `Pythagorean/BinetOrbit.lean` (orbit equation `kepler_orbit_radius_pos`), `Pythagorean/KeplerDefs.lean` (orbital period definition, `semiLatusRectum_pos`, `eccentricity_energy_relation`).

---

### Precise Theorem Targets with Lean 4 Type Signatures

**New Structure — The Runge-Lenz Vector**:
```lean
/-- The Runge-Lenz vector for a Kepler orbit. This is the "hidden" conserved
    quantity that makes the Kepler problem superintegrable. Its conservation
    is equivalent to the orbit being a conic section with fixed eccentricity. -/
structure RungeLenzVector where
  /-- x-component of the Runge-Lenz vector: A_x = L·ẋ − mk·cos θ -/
  Ax : ℝ
  /-- y-component: A_y = −L·ṙ − mk·sin θ (using radial/transverse decomposition) -/
  Ay : ℝ
  /-- The magnitude |A| = mke encodes eccentricity directly -/
  magnitude_eq : √(Ax² + Ay²) = m * k * e
```

**Theorem 1 — Kepler's Second Law (Areal Velocity)**:
```lean
/-- Kepler's Second Law: The areal velocity is constant and equals L/(2m).
    This follows from angular momentum conservation d(r²θ̇)/dt = 0.
    The proof uses the fact that dA = ½r² dθ and dt = (mr²/L)dθ from L = mr²θ̇. -/
theorem kepler_second_law_areal_velocity {m k : ℝ} (hm : 0 < m) (hk : 0 < k)
    {l : ℝ} (hl : l ≠ 0) (θ : ℝ → ℝ) (r : ℝ → ℝ)
    (horbit : ∀ θ, r θ = p / (1 + e * Real.cos θ))
    (hangmom : ∀ t, m * (r t)² * (deriv θ t) = l) :
    ∀ t₁ t₂, t₁ ≤ t₂ →
      (∫' t in t₁..t₂, (1/2) * (r (θ t))² * deriv θ t) = (l / (2 * m)) * (t₂ - t₁) := by
  sorry
```

**Theorem 2 — Kepler's Third Law (Period–Semimajor Axis)**:
```lean
/-- Kepler's Third Law: T² = (4π²m/k) · a³.
    Proof strategy: Compute the total area of the ellipse A = πab = πa²√(1−e²),
    then use T = A / (L/(2m)), and substitute a = p/(1−e²), p = L²/(mk),
    b = a√(1−e²), L = √(mka(1−e²)). -/
theorem kepler_third_law {m k : ℝ} (hm : 0 < m) (hk : 0 < k)
    {E l : ℝ} (hE : E < 0) (hl : 0 < l)
    {a e : ℝ} (ha : a = semiLatusRectum m k l / (1 - e^2))
    (he : e = Real.sqrt (1 + 2 * E * l^2 / (m * k^2)))
    (T : ℝ) (hT : T = 2 * Real.pi * a^(3/2) * Real.sqrt (m / k)) :
    T^2 = (4 * Real.pi^2 * m / k) * a^3 := by
  sorry
```

**Theorem 3 — Runge-Lenz Conservation (The Deep Result)**:
```lean
/-- Conservation of the Runge-Lenz vector for the Kepler problem.
    This is the NON-TRIVIAL hidden symmetry: it does NOT follow from
    rotational invariance alone, but requires the 1/r² force law specifically.
    It is the algebraic reason Kepler's laws hold. -/
theorem runge_lenz_conserved {m k : ℝ} (hm : 0 < m) (hk : 0 < k)
    (r θ : ℝ → ℝ) (t : ℝ)
    (heq : ∀ t, m * (deriv² r t - r t * (deriv θ t)^2) = -k / r t^2)
    (hangmom : ∀ t, m * (r t)^2 * deriv θ t = l) :
    let A_x := l * deriv (r ∘ θ) t - m * k * Real.cos (θ t)
    let A_y := -l * deriv r t - m * k * Real.sin (θ t)
    -- |A(t)| = mke for all t (conservation of magnitude)
    √(A_x^2 + A_y^2) = m * k * e := by
  sorry
```

**Theorem 4 — Cross-Domain: SO(4) Lie Algebra Structure (Geometry ↔ Representation Theory)**:
```lean
/-- The Poisson brackets of (L, A) close to form the Lie algebra so(4)
    for bound states (E < 0). After rescaling Ã = A/√(−2mE), the
    generators J⁺ = (L + Ã)/2 and J⁻ = (L − Ã)/2 satisfy two
    independent su(2) algebras, giving SO(4) = SU(2)×SU(2)/ℤ₂.
    This connects celestial mechanics to the representation theory
    that explains hydrogen atom degeneracy. -/
theorem so4_lie_algebra_bound_kepler {m k : ℝ} (hm : 0 < m) (hk : 0 < k)
    {E : ℝ} (hE : E < 0)
    (L A : ℝ³) (hL : ‖L‖ = |l|) (hA : ‖A‖ = m * k * e)
    (he : e = Real.sqrt (1 + 2 * E * l^2 / (m * k^2))) :
    -- After rescaling: the Poisson brackets {J⁺_i, J⁺_j} = ε_{ijk} J⁺_k
    -- and {J⁻_i, J⁻_j} = ε_{ijk} J⁻_k, {J⁺_i, J⁻_j} = 0
    -- This is the so(4) = so(3) ⊕ so(3) Lie algebra
    True := by  -- placeholder; full statement requires Poisson bracket formalization
  sorry
```

---

### Proof Strategies (Multiple Paths)

**Strategy A — Direct Integration (Most Promising for Laws 1–3)**:
1. Start from the catalog's `kepler_orbit_radius_pos` giving r(θ) = p/(1 + e·cos θ).
2. For Law 2: Substitute dA = ½r²dθ and use L = mr²θ̇ to get dA/dt = L/(2m) directly. This is a 3-line `calc` chain.
3. For Law 3: Compute the ellipse area via the parametric integral A = ½∫₀²π r²dθ = ½∫₀²π [p/(1+e·cos θ)]² dθ. Evaluate using the residue r = e²/(1−e²) substitution (Gradshteyn-Ryzhik 2.554), yielding A = πp²/(1−e²)^(3/2). Then T = A/(L/2m) and substitute p = L²/(mk), e² = 1 + 2EL²/(mk²) to arrive at T² = 4π²ma³/k.
4. **Why most promising**: The integrals are classical and well-documented; the main challenge is formalizing the contour integral or the Weierstrass substitution.

**Strategy B — Hamilton-Jacobi / Action-Angle Variables (Most Elegant)**:
1. Compute the action variables J_r = ∮ p_r dr and J_θ = ∮ p_θ dθ = L (angular momentum).
2. For the Kepler problem: J_r = −L + k√(m/(−2E)), giving J_r + J_θ = k√(m/(−2E)).
3. The frequencies ω_r = ∂E/∂J_r and ω_θ = ∂E/∂J_θ are EQUAL, proving orbit closure and giving the period T = 2π/ω.
4. **Why promising**: This approach simultaneously proves Laws 2 AND 3 AND orbit closure. It also naturally produces the SO(4) symmetry as the degeneracy ω_r = ω_θ.
5. **Difficulty**: Requires formalizing the Hamilton-Jacobi equation and action integrals — substantial but the payoff is enormous.

**Strategy C — Runge-Lenz First (Deepest, Opens New Fields)**:
1. Define **A** = **p** × **L** − mk**r̂** and prove d**A**/dt = 0 directly from F = −k**r̂**/r² using vector identities.
2. From |**A**| = mke, extract eccentricity e = |**A**|/(mk) as a conserved quantity.
3. From **A** · **r** = |**A**|r cos θ = L² − mkr, solve for r = (L²/mk)/(1 + (|**A**|/mk)cos θ), recovering the orbit equation with e = |**A**|/(mk).
4. Laws 2 and 3 follow as in Strategy A, but now the algebraic origin is manifest.
5. **Why this opens a new field**: The Runge-Lenz vector is the starting point for Pauli's algebraic solution of the hydrogen atom (1943 Nobel Prize work). Formalizing it creates a verified bridge from classical to quantum mechanics.

**Recommendation**: Use Strategy A for the base case (Laws 1–3), then Strategy C for the Runge-Lenz theorem. Strategy B is the long-term goal for a future cycle.

---

### Cross-Domain Connections

| Domain Pair | Connection | Theorem |
|---|---|---|
| **Celestial Mechanics ↔ Representation Theory** | SO(4) symmetry of Kepler problem ↔ SU(2)×SU(2) representation decomposition | `so4_lie_algebra_bound_kepler` |
| **Celestial Mechanics ↔ Quantum Mechanics** | Runge-Lenz vector ↔ Hydrogen atom accidental degeneracy (n²-fold) | `runge_lenz_conserved` → Pauli's H-atom solution |
| **Geometry ↔ Dynamical Systems** | Ellipse area = time × areal velocity (Liouville's theorem on phase space) | `kepler_second_law_areal_velocity` |
| **Number Theory ↔ Orbital Resonances** | Period commensurability T₁/T₂ = √(a₁/a₂)³ ↔ Diophantine approximation | Future: `orbital_resonance_rationality` |
| **Algebraic Topology ↔ Integrability** | Superintegrability (3 constants in 2 DOF) ↔ Topology of phase space foliation | Future: `kepler_superintegrable` |

---

### Falsifiable Conjecture with Computational Test

**Conjecture (Runge-Lenz Degeneracy Breaking)**: For a perturbed potential V(r) = −k/r + ε·rⁿ (n ≠ −1, ε ≠ 0), the Runge-Lenz vector is NOT conserved: |**A**(t) − **A**(0)| grows without bound for n ≥ 0 and oscillates for n < 0, n ≠ −1. Specifically, for V(r) = −k/r + ε·r² (isotropic harmonic perturbation), the orbit precesses at rate ω_prec = 3πε/T₀ to first order.

**Test**: Numerically integrate orbits for ε/r = {0.01, 0.1} with n ∈ {−2, 0, 1, 2, 3}. Compute |**A**(t) − **A**(0)|/|**A**(0)| over 100 orbital periods. For ε = 0 (pure Kepler), this ratio should be < 1e-12. For ε ≠ 0 and n ≠ −1, it should grow or oscillate. This is falsifiable: if the ratio stays < 1e-10 for any ε ≠ 0, n ≠ −1 case, the conjecture is wrong.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3–5 testable scientific hypotheses:
1. *SO(4) → Hydrogen degeneracy*: The formalized Runge-Lenz conservation implies n²-fold degeneracy of hydrogen energy levels via the quantum L² + A² = n²ℏ² identity. Test: compute degeneracy for n = 1..10 from the Casimir.
2. *Bertrand's theorem verification*: Only 1/r² and r² potentials have closed bounded orbits. Test: for 1000 random central potentials V(r) = r^α (α ∈ (−3, 3), α ≠ −1, 2), verify orbit non-closure over 100 periods.
3. *Symplectic area preservation*: Kepler phase flow preserves the Poincaré integral invariant. Test: transport a small loop in (r, ṙ) space through one period and verify area preservation to 1e-10.
4. *KAM stability of resonances*: For nearly-integrable perturbations ε·V₁(r,θ) of the Kepler problem, invariant tori persist for Diophantine frequency ratios. Test: vary ε and observe torus breakdown threshold.
5. *Tropical Kepler*: The tropical semiring limit of the orbit equation r = p ⊘ (1 ⊕ e ⊗ cos θ) yields piecewise-linear orbits. Test: compute tropical orbit shapes for e ∈ {0.1, 0.5, 0.9} and verify they are tropical ellipses (hexagons).

(b) **RESEARCH_PAPER.md**: Standalone scientific document titled "The Hidden SO(4) Symmetry of Kepler's Laws: A Formal Verification." Structure: (1) Introduction — why Kepler's laws are deeper than they appear; (2) The orbit equation and areal velocity; (3) The period law via ellipse area integration; (4) The Runge-Lenz vector and superintegrability; (5) The SO(4) Lie algebra and its consequences; (6) Applications to quantum mechanics and orbit design.

(c) **ARTICLE.md**: Scientific American style. Title: "The Secret Symmetry Behind the Planets." Opening: "Every physics student learns Kepler's three laws. Almost none learn why they're true — not merely that they follow from F = ma, but that they are the shadow of a hidden four-dimensional rotation symmetry, the same symmetry that explains why the hydrogen atom's energy levels are degenerate. We have now made this hidden symmetry machine-verified for the first time."

(d) **Verified algorithm**: `kepler_orbit_integrator` — a verified numerical integrator for Kepler orbits that computes (r(t), θ(t), A(t)) and certifies: (1) areal velocity constancy, (2) period formula agreement, (3) Runge-Lenz conservation. The algorithm should use the exact solution r(θ) = p/(1+e·cos θ) with Kepler's equation M = E − e·sin E for time parameterization.

(e) **demo.py**: Interactive visualization showing:
- An animated Kepler orbit with the swept-area triangle growing at constant rate
- The Runge-Lenz vector (red arrow) remaining fixed as the planet orbits
- A real-time readout of |**A**(t) − **A**(0)| showing conservation
- A slider for eccentricity showing the orbit transitioning from circle (e=0) to parabola (e=1)
- A perturbation toggle that adds ε·r² and shows the Runge-Lenz vector drifting (symmetry breaking)

---

**Application Keywords**: celestial mechanics, Runge-Lenz vector, SO(4) symmetry, superintegrability, hydrogen atom degeneracy, Bertrand's theorem, symplectic geometry, action-angle variables, orbital mechanics, formal verification of physics, accidental degeneracy, Kepler equation, areal velocity, Laplace-Runge-Lenz, Pauli algebraic method

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
