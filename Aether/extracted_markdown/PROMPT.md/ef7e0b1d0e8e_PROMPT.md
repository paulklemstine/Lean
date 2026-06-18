## Soli Deo Gloria

## Assignment: Tropical Kepler Orbits — Establishing the Tropical-Celestial Bridge

### The Grand Vision

We establish the first rigorous correspondence between tropical geometry and celestial mechanics: the tropicalization of Kepler's orbit equation yields piecewise-linear orbits whose combinatorial topology classifies classical orbit types. This creates **tropical celestial mechanics** — a field where orbit computation replaces floating-point arithmetic with exact min-plus algebra, Newton polygons replace phase portraits, and p-adic valuations encode arithmetic orbital invariants. This is not incremental tropical algebra; it is a new bridge between algebraic geometry and dynamical systems.

---

### Core Mathematical Framework

**Definition 1 (Tropical Valuation on Orbital Parameters)**. For base t > 1 and x ∈ ℝ⁺, define:
```
v_t(x) := -log_t(x)
```
The Maslov dequantization limit t → ∞ sends (ℝ⁺, +, ×) → (Trop(ℝ), min, +).

**Definition 2 (Tropical Kepler Conic)**. The Kepler conic in Cartesian coordinates:
```
K(e,p)(x,y) := (1 - e²)x² + 2epx + y² - e²p²
```
Under valuation v, tropicalizes to:
```
Trop(K)(X,Y) := min(v(1-e²) + 2X, v(2ep) + X, 2Y, v(e²p²))
```
The **tropical Kepler orbit** is the corner locus C(K) = {(X,Y) ∈ ℝ² : min achieved by ≥ 2 terms}.

**Definition 3 (Tropical Eccentricity)**. Define:
```
e_⊕ := max(0, v(1-e²)/2)
```
This vanishes precisely when e = 1 (parabolic degeneration removes the x² term from the Newton polygon).

---

### Precise Theorem Statements with Lean 4 Signatures

**Theorem 1 (Tropical Kepler Orbit is Balanced Piecewise-Linear Graph)**.
The corner locus of Trop(K(e,p)) is a balanced rational graph in the sense of Mikhalkin — the weighted edge directions sum to zero at every vertex, and each edge has rational slope determined by the Newton polygon of K.

```lean
theorem tropical_kepler_orbit_balanced (e p : ℝ) (he : 0 < e) (he1 : e < 1) (hp : 0 < p) :
    IsBalancedRationalGraph (tropicalKeplerConic e p) := by
  sorry
```

**Theorem 2 (Tropical Eccentricity Parabolic Degeneration)**.
The tropical eccentricity e_⊕ = 0 if and only if e = 1, corresponding to the collapse of the Newton polygon from a triangle (3 vertices) to a segment (the x² term vanishes, removing vertex (2,0)).

```lean
theorem tropical_eccentricity_parabolic_iff (e : ℝ) (he : 0 ≤ e) :
    tropicalEccentricity e = 0 ↔ e = 1 := by
  sorry
```

**Theorem 3 (Tropical Orbit Type Invariance Under Scaling)**.
Scaling both orbital parameters (e, p) → (λe, λp) with λ > 0 preserves the combinatorial type of the tropical Kepler orbit (vertex count and edge directions), since the Newton polygon is unchanged and the valuation vector is shifted by a constant.

```lean
theorem tropical_orbit_type_scaling_invariant (e p λ : ℝ) 
    (he : 0 < e) (hp : 0 < p) (hλ : 0 < λ) :
    CombinatorialType (tropicalKeplerConic e p) = 
    CombinatorialType (tropicalKeplerConic (λ * e) (λ * p)) := by
  sorry
```

**Theorem 4 (Tropical Vis-Viva Identity — Cross-Domain: Mechanics ↔ Tropical Algebra)**.
The classical vis-viva equation v² = μ(2/r - 1/a) tropicalizes to:
```
2·v_⊕(v) = v_⊕(μ) + min(v_⊕(2/r), v_⊕(1/a))
```
In the min-plus semiring, this reads: v_⊕(v) = (v_⊕(μ)/2) ⊕ min(-v_⊕(r), -v_⊕(a)), where ⊕ denotes tropical addition (min). This is the **tropical energy conservation law**.

```lean
theorem tropical_vis_viva (μ a r v : ℝ) 
    (hμ : 0 < μ) (ha : 0 < a) (hr : 0 < r) (hv : 0 < v)
    (hvis : v^2 = μ * (2/r - 1/a)) :
    2 * tropicalVal v = tropicalVal μ + min (tropicalVal (2/r)) (tropicalVal (1/a)) := by
  sorry
```

**Theorem 5 (Cross-Domain: p-adic Orbital Period Valuation — Number Theory ↔ Celestial Mechanics)**.
For prime p and rational orbital parameters (a, μ) ∈ ℚ⁺, the p-adic valuation of the Kepler period T = 2πa^(3/2)/√μ satisfies:
```
v_p(T) = -3·v_p(a)/2 - v_p(μ)/2 + v_p(2π)
```
The p-adic tropical orbit's vertex valuations encode this arithmetic invariant: the depth of each vertex in the tropical curve determines the p-adic order of the corresponding orbital parameter.

```lean
theorem padic_orbital_period_valuation (p : ℕ) [hp : Fact p.Prime] (a μ : ℚ) 
    (ha : 0 < a) (hμ : 0 < μ) :
    padicValRat p (2 * Real.pi * a^(3/2) / Real.sqrt μ) = 
    padicValRat p (2 * Real.pi) - (3 : ℤ) * padicValRat p a / 2 - padicValRat p μ / 2 := by
  sorry
```

---

### Proof Strategies

**Strategy A: Newton Polygon Duality (MOST PROMISING)**

1. Compute the Newton polygon Newt(K(e,p)) of K(e,p) = (1-e²)x² + 2epx + y² - e²p². For e < 1, all four monomials are present: the convex hull of {(2,0), (1,0), (0,2), (0,0)} is a triangle (since (1,0) lies on the edge from (0,0) to (2,0)). For e = 1, the x² coefficient vanishes, collapsing the polygon to a segment plus point.

2. Apply the **Fundamental Theorem of Tropical Geometry** (Mikhalkin): the tropical curve Trop(V(K)) is the corner locus of Trop(K), which is dual to the subdivision of Newt(K) induced by the lower convex hull of the lifted points {(i,j, v(aᵢⱼ))}.

3. The vertex count of the tropical curve equals the number of 2-dimensional cells in the subdivision. For a generic valuation vector (no three lifted points coplanar), this equals the number of interior lattice points plus boundary triangles — a direct combinatorial computation.

4. **Why most promising**: This reduces the entire problem to computing the lower convex hull of 4 points in ℝ³, which is a finite algorithm. The balanced condition follows from the balancing theorem for tropical curves, which is a direct consequence of the duality with regular subdivisions.

**Strategy B: Direct Corner Locus Enumeration**

1. Write Trop(K)(X,Y) = min(T₁, T₂, T₃, T₄) where T₁ = a₁ + 2X, T₂ = a₂ + X, T₃ = 2Y, T₄ = a₄, with a₁ = v(1-e²), a₂ = v(2ep), a₄ = v(e²p²).

2. The corner locus decomposes into 6 potential edge types (pairs of terms being equal and minimal): {T₁=T₂}, {T₁=T₃}, {T₁=T₄}, {T₂=T₃}, {T₂=T₄}, {T₃=T₄}.

3. Vertices are triple intersections: solve Tᵢ = Tⱼ = Tₖ and verify Tᵢ ≤ Tₗ for the remaining term. There are 4 choose 3 = 4 potential vertices.

4. Filter by feasibility conditions. The actual vertex count depends on the relative magnitudes of a₁, a₂, a₄.

5. **Advantage**: Completely constructive, amenable to computational verification in demo.py. **Disadvantage**: Requires careful case analysis; the combinatorial structure is clearer from Strategy A.

**Strategy C: Amoeba Convergence (For Asymptotic Results)**

1. Define the amoeba A_t = {(log_t|x|, log_t|y|) : K(e,p)(x,y) = 0} for base t.

2. By the Ergodic Theorem of Tropical Geometry (Forsberg-Passare-Tsikh), A_t → Trop(V(K)) in the Hausdorff metric as t → ∞.

3. For large finite t, compute A_t numerically and extract the tropical limit's combinatorial type.

4. **Advantage**: Connects to the deep theory of amoebas and Ronkin functions. **Disadvantage**: Requires topology/analysis infrastructure not yet in Mathlib; the convergence is non-constructive for the vertex count.

**Recommended approach**: Prove Theorem 1 via Strategy A (Newton polygon duality), Theorem 2 via Strategy B (direct computation), Theorems 3–5 via algebraic manipulation of the tropical semiring axioms.

---

### Catalog Building Blocks

From `Pythagorean/BinetOrbit.lean`:
- **`kepler_orbit_is`**: The orbit equation r(θ) = p/(1+e·cos(θ)). Extend by tropicalizing the RHS: Trop(r)(Θ) = min(v(p), min(0, v(e) + Trop(cos)(Θ))). The tropical cosine Trop(cos)(Θ) is the piecewise-linear function max(-|Θ|, -|Θ-π|, -|Θ+π|) (tropicalization of the Chebyshev recurrence).

From `Pythagorean/OrbitClassification.lean`:
- **Orbit type classification** (ellipse/parabola/hyperbola by eccentricity): Prove that the tropical vertex count gives the same classification. The key: the Newton polygon collapses when e = 1, reducing the vertex count, and this collapse is detected by e_⊕ = 0.

---

### Falsifiable Conjecture with Computational Test

**Conjecture (Tropical Kepler Vertex Formula)**. For the tropicalization of K(e,p) with 0 < e < 1, p > 0, and base t = 10⁶, the tropical curve has exactly:
- **3 vertices** when v_t(1-e²) ≤ min(v_t(2ep), v_t(e²p²)) - i.e., the x² term's valuation is small enough that the lifted point (2,0, v(1-e²)) lies on the lower convex hull
- **4 vertices** when v_t(1-e²) > min(v_t(2ep), v_t(e²p²)) - the x² term lifts above the lower hull, creating an additional subdivision cell

**Test**: For 10⁴ random (e, p) pairs with 0 < e < 1, 0.1 < p < 10:
1. Compute the lower convex hull of {(2,0, v_t(1-e²)), (1,0, v_t(2ep)), (0,2, 0), (0,0, v_t(e²p²))} in ℝ³
2. Count the 2-dimensional faces → vertex count of the tropical curve
3. Verify against the formula above
4. Any counterexample falsifies the conjecture

---

### Cross-Domain Connections & Application Keywords

1. **Tropical Geometry ↔ Celestial Mechanics**: Tropicalization replaces transcendental orbit equations with exact piecewise-linear algebra. *Keywords: tropical astrodynamics, piecewise-linear orbit determination, min-plus Kepler equation, tropical Lambert solver*

2. **Algebraic Geometry ↔ Dynamical Systems**: The Newton polygon of the orbit equation determines the tropical orbit structure, providing a combinatorial fingerprint of the dynamics. *Keywords: Newton polygon phase portrait, tropical integrable systems, combinatorial Hamiltonian mechanics, tropical action-angle variables*

3. **p-adic Number Theory ↔ Orbital Mechanics**: The p-adic tropical orbit encodes arithmetic properties of orbital parameters — the p-adic valuation of the period is read off from vertex depths. *Keywords: p-adic celestial mechanics, arithmetic orbital invariants, adelic orbit theory, p-adic Lagrange points*

4. **Information Theory ↔ Tropical Mechanics**: The tropical vis-viva equation suggests a tropical entropy functional for orbit ensembles, connecting to tropical information geometry. *Keywords: tropical statistical mechanics, orbit entropy, tropical thermodynamic limit, tropical Boltzmann distribution*

5. **Quantum Computing ↔ Tropical Orbits**: The piecewise-linear structure of tropical orbits admits efficient quantum circuit representations via tropical quantum gates. *Keywords: tropical quantum computation, piecewise-linear Hamiltonian simulation, tropical quantum advantage*

---

### Novel Definitions Required

```lean
-- Tropical valuation on positive reals (non-Archimedean)
noncomputable def tropicalVal (base : ℝ) (hbase : 1 < base) (x : ℝ) : WithTop ℝ

-- Tropical polynomial in two variables (piecewise-linear function ℝ² → ℝ)
structure TropicalPoly₂ where
  terms : Finset (ℕ × ℕ × ℝ)  -- (i, j, coefficient valuation)
  hnonempty : terms.Nonempty

-- Corner locus of a tropical polynomial (the tropical curve)
def cornerLocus (f : TropicalPoly₂) : Set (ℝ × ℝ)

-- Tropical Kepler conic polynomial
noncomputable def tropicalKeplerConic (e p : ℝ) : TropicalPoly₂

-- Tropical eccentricity
noncomputable def tropicalEccentricity (e : ℝ) : ℝ := max 0 (tropicalVal 10 (1 - e^2) / 2)

-- Combinatorial type of a tropical curve (vertex count + edge directions)
structure CombinatorialType where
  vertexCount : ℕ
  edgeDirections : Finset (ℤ × ℤ)

-- Balanced rational graph (Mikhalkin's condition)
def IsBalancedRationalGraph (f : TropicalPoly₂) : Prop

-- p-adic tropical orbit
noncomputable def padicTropicalOrbit (p : ℕ) [Fact p.Prime] (e a : ℚ) : TropicalPoly₂
```

---

### Why This Is a Breakthrough

This work establishes the **tropical-celestial correspondence**: a dictionary between classical orbital mechanics and tropical geometry that:

1. **Replaces transcendental with combinatorial**: Orbit equations involving cos, sin, √ become min, +, |·| — exact, no floating-point error
2. **Provides Newton polygon orbit classification**: The combinatorial type of the tropical curve classifies the orbit (analogous to how the Newton polygon classifies singularities)
3. **Opens p-adic celestial mechanics**: Arithmetic properties of orbital parameters become geometric features of the p-adic tropical orbit
4. **Enables tropical perturbation theory**: Structural stability of tropical orbits reduces to checking that perturbations preserve the Newton polygon subdivision — a finite check
5. **Suggests tropical Hamiltonian mechanics**: The min-plus structure naturally replaces the symplectic structure, with the tropical vis-viva as the conserved "tropical energy"

This is the creation of a new field at the intersection of three major areas (tropical geometry, celestial mechanics, number theory), not an incremental extension of any one of them.

---

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 5 testable scientific hypotheses:
1. *Tropical Kepler Vertex Formula*: Vertex count = 3 + δ(v(1-e²) > min(v(2ep), v(e²p²))) — test by 10⁴ random parameter pairs
2. *Tropical Structural Stability*: Perturbations preserving the Newton polygon subdivision preserve the tropical orbit type — test by random perturbation experiments with Hausdorff distance
3. *p-adic Period Valuation*: v_p(T) is determined by vertex depths of the p-adic tropical orbit — test for primes p < 1000
4. *Tropical Three-Body*: The tropicalization of the restricted three-body problem's Jacobi integral yields a tropical curve whose genus equals the number of Lagrange points (5) — test by computing the tropicalization
5. *Tropical KAM*: Tropical quasi-periodic orbits on tropical tori are structurally stable under tropical perturbations — test by numerical tropical integration with random kicks

(b) **RESEARCH_PAPER.md** — standalone scientific document covering: tropicalization procedure, vertex count classification theorem, tropical vis-viva identity, p-adic Kepler connection, computational verification, implications for computational astrodynamics

(c) **ARTICLE.md** — Scientific American style: "When Planets Go Tropical: How Piecewise-Linear Geometry Replaces Calculus in the Heavens" — the crystalline polyhedra of tropical orbits, Newton polygons as celestial fingerprints, min-plus navigation for spacecraft

(d) **Verified Algorithm**: Constructive procedure computing tropical Kepler orbit (vertex positions, edge slopes, balanced weights) from (e, p, v) with certified correctness proof

(e) **demo.py**: Interactive visualization of classical vs. tropical orbits, amoeba-to-tropical convergence, vertex count parameter space, p-adic tropical orbits for various primes

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
