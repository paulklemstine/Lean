## Assignment: Certified Hamiltonian Reduction and the Kepler Orbit Theorem

### Vision

The Noether theorems in our catalog establish that symmetries yield conservation laws. But the *real* power of Noether's principle lies deeper: conserved quantities don't just constrain motion — they **reduce the phase space**, transforming intractable problems into solvable ones. This is the Marsden-Weinstein reduction: a functor from Hamiltonian systems with symmetry to lower-dimensional Hamiltonian systems without symmetry. For the Kepler problem, this reduction is a dramatic collapse: from 6 dimensions to 1, from a coupled nonlinear system to a quadrature. The resulting orbit equation — `r(θ) = p/(1 + e cos θ)` — is not just a solution; it is a **certificate** that the reduction preserves all dynamical information.

We will prove the first certified Marsden-Weinstein reduction in formal mathematics, establish the Binet equation as a bridge between nonlinear and linear dynamics, and derive the Kepler orbit equation as a verified conic section. This completes the arc: symmetry → conservation → reduction → solution.

---

### Main Theorem: The Kepler Orbit Equation

```lean
/-- The effective potential for a central force problem with angular momentum magnitude l.
    This is the key object in the Marsden-Weinstein reduction of rotationally symmetric systems:
    it encodes the centrifugal barrier l²/(2mr²) and the gravitational well -k/r. -/
def effectivePotential (m k l r : ℝ) : ℝ := l^2 / (2 * m * r^2) - k / r

/-- The semi-latus rectum of a Kepler orbit, determined by angular momentum. -/
def semiLatusRectum (m k l : ℝ) : ℝ := l^2 / (m * k)

/-- The eccentricity of a Kepler orbit, determined by energy and angular momentum.
    This is the fundamental bridge quantity: e² = 1 + 2El²/(mk²) connects
    the dynamical invariant E to the geometric invariant e. -/
def keplerEccentricity (m k E l : ℝ) : ℝ :=
  Real.sqrt (1 + 2 * E * l^2 / (m * k^2))

/-- The Binet equation: under the substitution u(θ) = 1/r(θ), the nonlinear
    radial equation of the Kepler problem transforms into the linear ODE
    d²u/dθ² + u = mk/l². This is the key algebraic miracle that makes
    the Kepler problem exactly solvable. -/
theorem binet_equation_kepler {m k l : ℝ} (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    -- For any C¹ function r : ℝ → ℝ satisfying the reduced radial equation
    -- m r̈ = l²/(mr³) - k/r² with angular momentum |L| = l,
    -- the Binet transform u(θ) = 1/r(θ) satisfies u'' + u = mk/l²
    ...

/-- The Kepler orbit equation: the solution of the Binet equation yields
    a conic section r(θ) = p/(1 + e cos(θ - θ₀)) where p = l²/(mk) is
    the semi-latus rectum and e = √(1 + 2El²/(mk²)) is the eccentricity.
    This is the certified output of the Marsden-Weinstein reduction pipeline. -/
theorem kepler_orbit_is_conic {m k E l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) (hE : E < 0) :
    -- Any solution of the Kepler equations with energy E and |L| = l
    -- has orbit r(θ) = p/(1 + e cos(θ - θ₀)) for some phase θ₀,
    -- where p = semiLatusRectum m k l and e = keplerEccentricity m k E l
    ...

/-- The eccentricity-energy-angular momentum relation:
    e² = 1 + 2El²/(mk²) is the fundamental identity connecting
    dynamical invariants (E, l) to geometric invariants (e). -/
theorem eccentricity_energy_relation {m k E l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) (hE : E < 0) :
    (keplerEccentricity m k E l)^2 = 1 + 2 * E * l^2 / (m * k^2) := by
  unfold keplerEccentricity
  -- squaring removes the sqrt
  ...
```

---

### Supporting Theorems (Deep Proofs Required)

**Theorem 1: Effective Potential Has Unique Minimum** — The centrifugal barrier and gravitational well create a unique stable orbit radius.

```lean
/-- The effective potential has a unique global minimum at r* = l²/(mk),
    with V_eff(r*) = -mk²/(2l²). This is the orbit of circular motion. -/
theorem effective_potential_unique_minimum {m k l : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    let r_star := l^2 / (m * k)
    let V_min := -m * k^2 / (2 * l^2)
    r_star > 0 ∧
    effectivePotential m k l r_star = V_min ∧
    ∀ r, r > 0 → r ≠ r_star → effectivePotential m k l r > V_min := by
  -- Requires calculus: derivative V_eff'(r) = -l²/(mr³) + k/r² = 0 iff r = l²/(mk)
  -- Second derivative test: V_eff''(r*) = 3l²/(m(r*)⁴) - 2k/(r*)³ > 0
  intro r hr hr_ne
  -- Multi-step calc with field_simp and positivity
  ...
```

**Theorem 2: Orbit Classification by Energy Sign** — The topology of the energy level set determines the orbit type.

```lean
/-- The sign of energy determines the orbit type via the eccentricity:
    E < 0 ⟹ e < 1 (ellipse), E = 0 ⟹ e = 1 (parabola), E > 0 ⟹ e > 1 (hyperbola).
    This is the dynamical analogue of the discriminant classification of conic sections. -/
theorem orbit_type_by_energy {m k l E : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    (E < 0 ↔ keplerEccentricity m k E l < 1) ∧
    (E = 0 ↔ keplerEccentricity m k E l = 1) ∧
    (E > 0 ↔ keplerEccentricity m k E l > 1) := by
  -- Key algebraic identity: e² - 1 = 2El²/(mk²)
  -- The sign of e² - 1 is determined by the sign of E
  constructor
  · -- E < 0 ↔ e < 1: since e² = 1 + 2El²/(mk²) and l²/(mk²) > 0
    ...
  · constructor
    · -- E = 0 ↔ e = 1: direct substitution
      ...
    · -- E > 0 ↔ e > 1: dual of first case
      ...
```

**Theorem 3: Radial Energy Conservation** — The reduction from 6D to 1D preserves the Hamiltonian structure.

```lean
/-- The reduced radial dynamics conserves energy with the effective potential.
    This is the certified output of the Marsden-Weinstein reduction:
    ½mṙ² + V_eff(r, l) = E, where V_eff encodes both the gravitational
    potential and the centrifugal barrier from angular momentum conservation. -/
theorem radial_energy_conservation {m k l E : ℝ}
    (hm : m > 0) (hk : k > 0) (hl : l > 0) :
    -- Along any trajectory of the Kepler problem with |L| = l,
    -- the radial motion satisfies ½m(dr/dt)² + V_eff(r, l) = E
    -- This follows from H = p²/(2m) - k/r and L = r × p with |L| = l
    ...
```

---

### Novel Definitions

```lean
/-- The Marsden-Weinstein reduction data for a Hamiltonian system with symmetry.
    This structure encapsulates the passage from a 2n-dimensional phase space
    with k-dimensional symmetry to a (2n - 2k)-dimensional reduced phase space.
    The reduced_hamiltonian encodes all dynamics of the original system
    on the level set of conserved quantities. -/
structure MarsdenWeinsteinReduction where
  original_dim : ℕ          -- 2n, dimension of original phase space
  symmetry_dim : ℕ           -- k, dimension of symmetry group
  reduced_dim : ℕ            -- 2n - 2k, dimension of reduced phase space
  momentum_map_components : ℕ  -- number of independent conserved quantities
  reduced_hamiltonian : ℝ → ℝ → ℝ  -- H_red : (q_red, p_red) → ℝ
  -- Certificate: the reduced dynamics project to the original dynamics
  h_reduced_dim : reduced_dim = original_dim - 2 * symmetry_dim

/-- The Binet transform: the miraculous substitution u = 1/r that
    linearizes the Kepler problem. Maps orbit equations r(θ) → u(θ) = 1/r(θ). -/
def binetTransform (r : ℝ → ℝ) : ℝ → ℝ := fun θ => 1 / r θ

/-- The orbit type classification, indexed by the sign of energy. -/
inductive OrbitType where
  | elliptic    -- E < 0: bound orbits, e < 1
  | parabolic   -- E = 0: marginally unbound, e = 1
  | hyperbolic  -- E > 0: unbound orbits, e > 1
  deriving Repr, BEq
```

---

### Proof Strategies

**Strategy A: Direct Binet Computation (RECOMMENDED)**

This is the most promising for formalization because it reduces the entire proof to algebraic manipulation after a clean change of variables.

*Step 1*: From `angular_momentum_conserved_of_central_force` and `energy_conserved` in the catalog, derive the reduced radial equation `m r̈ = l²/(mr³) - k/r²`. This is a `calc` block using the definition of angular momentum `L = mr²θ̇` to eliminate `θ̇`.

*Step 2*: Apply the Binet substitution `u = 1/r`. Compute `du/dθ = -ṙ/(r²θ̇) = -mṙ/l` and `d²u/dθ² = -mr̈/(lθ̇)`. Substitute the radial equation to get `d²u/dθ² + u = mk/l²`. This is the **Binet equation**: a *linear* ODE where the original was nonlinear.

*Step 3*: The Binet equation `u'' + u = mk/l²` has general solution `u(θ) = mk/l² + C cos(θ - θ₀)`. Inverting: `r(θ) = l²/(mk + Cl²cos(θ-θ₀)/1) = p/(1 + e cos(θ-θ₀))` where `p = l²/(mk)` and `e = Cl²/(mk)`.

*Step 4*: Determine `C` from energy: at periapsis `ṙ = 0`, so `E = V_eff(r_min)`. Algebraic manipulation yields `C = mke/l²`, giving `e² = 1 + 2El²/(mk²)`.

**Strategy B: Hamilton-Jacobi Separation**

Use the Hamilton-Jacobi equation with action-angle variables. The generating function `S(r, θ, α₁, α₂)` separates into radial and angular parts. The orbit equation emerges from `∂S/∂E = const`. This is mathematically elegant but requires formalizing the Hamilton-Jacobi PDE, which is harder than the Binet approach.

**Strategy C: Symplectic Quotient Construction**

Formalize the Marsden-Weinstein reduction as a symplectic quotient: the SO(3)-action on `T*R³` has momentum map `μ = L`, and `μ⁻¹(l)/SO(2)` carries a reduced symplectic structure. This is the deepest approach but requires significant symplectic geometry infrastructure not yet in Mathlib. Use Strategy A for the main results and Strategy C as motivation.

---

### Cross-Domain Connections

**1. Symplectic Geometry ↔ Algebraic Geometry (Conic Sections)**

The orbit equation `r = p/(1 + e cos θ)` is a conic section in polar coordinates. In Cartesian coordinates: `(1-e²)x² + 2epx + y² = e²p²`. The discriminant `Δ = e² - 1 = 2El²/(mk²)` is the bridge: the *dynamical* invariant `E` determines the *algebraic* type of the orbit. **The orbit type is a topological invariant of the energy level set**: for `E < 0`, the level set `{H = E}` is diffeomorphic to `S¹ × ℝ` (bound orbits); for `E > 0`, it is `ℝ²` (unbound). The conic section classification is the shadow of this topology in configuration space.

**2. Classical Mechanics ↔ Representation Theory (Hidden SO(4) Symmetry)**

The Kepler problem possesses a *hidden symmetry* beyond SO(3): the Laplace-Runge-Lenz vector `A = p × L - mkq̂` is conserved. Together, `L` and `A` generate an SO(4) action for `E < 0` (or SO(3,1) for `E > 0`). This explains *superintegrability*: 5 independent conserved quantities for 3 degrees of freedom. The SO(4) ≅ SU(2) × SU(2)/ℤ₂ representation theory predicts the hydrogen atom's energy levels `E_n = -mk²/(2n²ℏ²)` — a direct bridge from classical reduction to quantum spectroscopy. **The eccentricity vector `A` points to periapsis with magnitude `e·mk`**, encoding the orbit shape in a single vector.

**3. Hamiltonian Reduction ↔ Tropical Geometry**

The tropicalization of the orbit equation `r(θ) = p/(1 + e cos θ)` under `v(x) = -λ log|x|` as `λ → 0⁺` yields piecewise-linear curves: **tropical conic sections**. The tropical eccentricity `e_⊕ = v(e)` determines the tropical orbit type, just as the classical eccentricity determines the classical type. This connects to the catalog's `TropicalDegreeRobustness.lean`: the tropical Kepler problem has orbits that are tropical quadrics, and the tropical discriminant classifies them. **The tropical limit of the Binet equation is a tropical linear ODE**, solvable by tropical algebra.

**4. Integrability ↔ Information Theory**

A Hamiltonian system with `n` DOF is Liouville integrable iff it has `n` independent conserved quantities in involution. The Marsden-Weinstein reduction is a **lossless compression algorithm**: it reduces dimensionality without losing dynamical information. The integrability condition is the Hamiltonian analogue of the source coding theorem: the system is "compressible to quadrature" iff it has sufficient symmetry. The Kolmogorov-Sinai entropy of the reduced system is zero — all information is in the initial conditions, not in the dynamics.

---

### Conjecture: The Tropical Kepler Problem

**Conjecture (Tropical Kepler Orbits)**: The tropicalization of the Kepler orbit equation `r(θ) = p/(1 + e cos θ)` under the valuation `v(x) = -log_t(|x|)` as `t → ∞` yields a piecewise-linear orbit in the `(log r, θ)`-plane. Specifically:

1. For `E < 0` (elliptical): the tropical orbit is a tropical ellipse — a hexagonal curve with 6 vertices.
2. The tropical eccentricity is `e_⊕ = max(0, v(1-e²)/2)`.
3. The tropical orbit equation is `r_⊕(θ) = min(p_⊕, e_⊕ + |θ|_⊕)` where `|·|_⊕` is the tropical absolute value.

**Test**: Compute tropical orbits for 100 random `(E, l)` pairs with `E < 0`. Verify that each tropical orbit has exactly 6 vertices (for the tropical ellipse) and that the vertex positions match the tropicalization of the classical orbit. Compare with the tropicalization of the Cartesian conic section equation `(1-e²)x² + 2epx + y² = e²p²`.

---

### Application Keywords

`hamiltonian-reduction`, `marsden-weinstein`, `kepler-problem`, `binet-equation`, `conic-sections`, `effective-potential`, `symplectic-quotient`, `hidden-symmetry`, `laplace-runge-lenz`, `superintegrability`, `tropical-mechanics`, `orbit-certification`, `integrable-systems`, `noether-reduction`, `binet-transform`

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable hypotheses:
1. *Laplace-Runge-Lenz conservation*: Prove `dA/dt = 0` for `A = p × L - mkq̂` along Kepler trajectories. Test: verify numerically for 1000 random initial conditions.
2. *SO(4) hidden symmetry explains hydrogen degeneracy*: The SO(4) Casimir `C = L² + A²/(mk)²` takes values `(nℏ)²`, giving `E_n = -mk²/(2n²ℏ²)`. Test: compute Casimir eigenvalues and verify against hydrogen spectrum.
3. *Tropical Kepler orbits are tropical conic sections*: Tropical orbits have predictable vertex structure (6 for ellipse, 4 for parabola). Test: compute 100 tropical orbits and count vertices.
4. *Reduction commutes with Hamiltonian flow*: The Marsden-Weinstein reduction diagram commutes (projection of flow = flow of projection). Test: compute a Kepler trajectory, project to reduced space, and verify it matches the reduced trajectory.
5. *Eccentricity vector points to periapsis*: The LRL vector `A` has magnitude `e·mk` and direction toward closest approach. Test: verify numerically that `A/|A| = q̂_min` for 100 orbits.

(b) **RESEARCH_PAPER.md**: "Certified Hamiltonian Reduction: From Noether Symmetries to Kepler Orbits via the Binet Transform" — presenting the effective potential theorem, the Binet equation, and the orbit equation as verified conic sections, with full proofs and the SO(4) hidden symmetry connection.

(c) **ARTICLE.md**: "The Universe on a Diet: How Symmetry Shrinks Space Itself" — an accessible account of how rotational symmetry reduces the 6D Kepler problem to a 1D problem solvable by quadrature, and how a hidden symmetry (SO(4)) explains why the solar system is predictable.

(d) **Verified algorithm**: A certified procedure `kepler_orbit_params(m, k, E, l) → (p, e, a, T)` computing semi-latus rectum, eccentricity, semi-major axis, and period from dynamical invariants, with verified error bounds proving `e² = 1 + 2El²/(mk²)`.

(e) **demo.py**: Interactive visualization showing: (i) 3D Kepler trajectory in phase space, (ii) the level set `{H = E, |L| = l}` being quotiented by SO(2), (iii) the reduced 2D dynamics on the `(r, p_r)` plane with effective potential, (iv) the conic section orbit `r(θ) = p/(1 + e cos θ)`, (v) a slider for `(E, l)` that dynamically updates orbit type and shows the tropical limit.

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
