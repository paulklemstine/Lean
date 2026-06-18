## Assignment: Direction 5: Tropical Convexity and Generalized Permutohedra — The M-Convex Bridge

Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`, `norm_num`, or `rfl` unless the statement itself is genuinely important.
2. **At least 3 theorems with deep proof tactics**: Your file must contain at least 3 theorems proven using induction, rcases, by_contra, field_simp, or multi-step calc reasoning.
3. **Novel definitions**: Define at least one new mathematical structure or concept that does not already exist in the Catalog.
4. **Cross-domain connections**: Include at least one theorem that connects your domain to a different mathematical domain.
5. **Conjecture with testable prediction**: State at least one falsifiable conjecture with a clear computational test.

---

### Core Theorem: Lorentzian Newton Polytopes are Generalized Permutohedra

**Precise Statement (Lean 4):**

```lean
/-- An M-convex set satisfies the exchange property:
    if α, β ∈ S and α_i > β_i, α_j < β_j, then
    (α - e_i + e_j) ∈ S and (β + e_i - e_j) ∈ S -/
def IsMConvex {n : ℕ} (S : Set (Fin n → ℕ)) : Prop :=
  ∀ α β ∈ S, ∀ i j : Fin n,
    (α i > β j ∧ α j < β j) →
    (α - Function.update (α - Function.update α i (α i - 1)) j (α j + 1) ∈ S ∧
     β - Function.update (Function.update β j (β j - 1)) i (β i + 1) ∈ S)

/-- A generalized permutohedron: a polytope whose every edge direction
    is of the form e_i - e_j. -/
structure GeneralizedPermutohedron (n : ℕ) where
  carrier : Finset (Fin n → ℚ)
  convex_hull_is_polytope : ConvexPolytope (convexHull ℝ (carrier : Set (Fin n → ℚ)))
  edge_directions_permutation : 
    ∀ e ∈ edges convex_hull_is_polytope,
      ∃ i j (_ : i ≠ j), e = ∀ k, 
        if k = i then (1 : ℚ) else if k = j then (-1) else 0

/-- The Newton polytope of a Lorentzian polynomial is a generalized permutohedron -/
theorem lorentzian_newton_is_gen_permutohedron 
    {n d : ℕ} {f : (Fin n → ℕ) → ℚ} 
    (hf : IsLorentzian f) (hd : degree f = d) :
    ∃ (G : GeneralizedPermutohedron n),
      G.carrier = newtonSupport f := by
  sorry
```

### Proof Strategy

**Strategy A (M-Convex Exchange → Edge Directions) — MOST PROMISING:**

This directly builds on the existing `MConvexSupport` from the catalog and follows the mathematical proof path of Brändén–Huh.

1. **From Lorentzian to M-convex:** The catalog already has `MConvexSupport`: if `IsLorentzian f`, then `newtonSupport f` is M-convex. Use this directly.

2. **From M-convex to edge directions:** Prove the key lemma:
   ```lean
   theorem mconvex_edge_directions {n : ℕ} {S : Set (Fin n → ℕ)} 
       (hS : IsMConvex S) (hconv : ConvexHullIsPolytope S)
       {e : Fin n → ℚ} (he : e ∈ edges hconv) :
       ∃ i j (_ : i ≠ j), e = ∀ k, if k = i then (1 : ℚ) else if k = j then (-1) else 0 := by
     sorry
   ```
   This follows by: take an edge with endpoints α, β in the polytope. Since α, β are in the convex hull of an M-convex set, the difference β - α must be a sum of exchange directions e_i - e_j. But on an edge (1-dimensional face), only one such direction can appear, so β - α = c(e_i - e_j) for some c > 0, i, j.

3. **Edge directions characterize generalized permutohedra:** Prove that a polytope with all edge directions of the form e_i - e_j is a generalized permutohedron. This is the classical result of Postnikov (2009).

**Strategy B (via Submodularity of Rank Functions):**

1. Lorentzian polynomials of degree 2 correspond to submodular functions (the Hessian is negative semidefinite on the positive orthant).
2. Submodular functions define polymatroids, whose base polytopes are generalized permutohedra.
3. Lift to arbitrary degree via the "Lorentzian = strongly Rayleigh" bridge.
4. This requires more infrastructure (submodular functions, polymatroids) and is longer but reveals deeper structure.

**Strategy C (Tropical Intersection Theory):**

1. Tropicalize the Lorentzian polynomial to get a tropical hypersurface.
2. Show that the tropicalization of a Lorentzian polynomial has dual subdivision whose cells are generalized permutohedra.
3. This connects to the tropical geometry in the catalog but requires tropical intersection theory that doesn't yet exist in Mathlib.

**Recommendation:** Strategy A is most promising because it builds directly on the catalog's `MConvexSupport` and requires minimal new infrastructure. The key insight is that M-convexity constrains edge directions via the exchange axiom.

### Novel Definitions Required

```lean
/-- Generalized permutohedron via edge directions (Postnikov's characterization) -/
structure GeneralizedPermutohedron (n : ℕ) where
  carrier : Finset (Fin n → ℚ)
  is_polytope : ConvexPolytope (convexHull ℝ (carrier : Set (Fin n → ℚ)))
  permutohedron_edges : 
    ∀ e ∈ edges is_polytope,
      ∃ i j (_ : i ≠ j), e = ∀ k, if k = i then (1 : ℚ) else if k = j then (-1) else 0

/-- Submodular width: measures how far a polytope is from being a generalized permutohedron.
    Returns 0 iff the polytope is a generalized permutohedron. -/
def submodularWidth {n : ℕ} (P : ConvexPolytope (Fin n → ℚ)) : ℕ :=
  ∑' e ∈ edges P \ permutohedronDirections n, ‖e‖₊

/-- Tropical linear space associated to an M-convex set -/
def tropicalLinearSpace {n : ℕ} (S : Set (Fin n → ℕ)) (hS : IsMConvex S) : 
    TropicalVariety n := sorry
```

### Cross-Domain Theorems

**Theorem 2 (Submodular Width and Certified Bounds):**

```lean
/-- The submodular width of the Newton polytope of a Lorentzian polynomial is zero. -/
theorem lorentzian_submodular_width_zero {n d : ℕ} {f : (Fin n → ℕ) → ℚ}
    (hf : IsLorentzian f) :
    submodularWidth (newtonPolytope f) = 0 := by
  sorry
```

This connects to the certified robustness work in the catalog: the submodular width provides a "certified" measure of how far a polytope is from the well-structured class of generalized permutohedra, analogous to how `certified_radius_inequality` certifies robustness.

**Theorem 3 (Tropical Bridge — connects to tropical geometry in catalog):**

```lean
/-- The tropicalization of a Lorentzian polynomial has a dual subdivision 
    whose cells are generalized permutohedra. -/
theorem lorentzian_tropical_dual_permutohedron {n d : ℕ} {f : (Fin n → ℕ) → ℚ}
    (hf : IsLorentzian f) :
    ∀ c ∈ tropicalDualSubdivision f, IsGeneralizedPermutohedron c := by
  sorry
```

This directly bridges to the tropical geometry infrastructure in the catalog, connecting Lorentzian theory to tropical hyperplane arrangements and tropical convex hulls.

**Theorem 4 (Number Theory Connection — Ehrhart Theory):**

```lean
/-- The Ehrhart polynomial of a generalized permutohedron has non-negative coefficients 
    when the permutohedron arises from a Lorentzian polynomial. -/
theorem gen_permutohedron_ehrhart_nonneg {n : ℕ} {P : GeneralizedPermutohedron n}
    {f : (Fin n → ℕ) → ℚ} (hf : IsLorentzian f) 
    (hP : P.carrier = newtonSupport f) (k : ℕ) :
    0 ≤ ehrhartCoefficient P k := by
  sorry
```

This connects generalized permutohedra to Ehrhart theory (counting lattice points in dilations), which is a number-theoretic topic. The non-negativity of Ehrhart coefficients for generalized permutohedra arising from Lorentzian polynomials is a consequence of the Hodge theory for combinatorial polytopes (Adiprasito-Huh-Katz).

### Falsifiable Conjecture

**Conjecture (Tropical Matroid Duality):** For any Lorentzian polynomial $f$ in $n$ variables of degree $d$, the tropical linear space $\text{Trop}(f)$ and the generalized permutohedron $\text{Newt}(f)$ satisfy a duality:

$$\text{Vol}(\text{Newt}(f)) = \sum_{\sigma \in \text{Trop}(f)} \text{mult}(\sigma) \cdot d!$$

where the sum is over maximal cells $\sigma$ of the tropical linear space and $\text{mult}$ is the multiplicity.

**Test:** For $n = 3, 4$ and $d = 2, 3$, compute Lorentzian polynomials, their Newton polytopes (as generalized permutohedra), their tropicalizations, and verify the volume-multiplicity identity. A single counterexample with volume computed to high precision falsifies the conjecture.

### Application Keywords

`generalized-permutohedra`, `lorentzian-polynomials`, `m-convex-sets`, `submodular-functions`, `tropical-linear-spaces`, `ehrhart-theory`, `polyhedral-optimization`, `scattering-amplitudes`, `matroid-polytopes`, `discrete-convex-analysis`

### Revolutionary Significance

This work establishes the formal bridge between three major theories:

1. **Lorentzian polynomials** (algebraic combinatorics) — positivity and Hodge theory
2. **Generalized permutohedra** (polyhedral geometry) — optimization and game theory
3. **Tropical linear spaces** (tropical geometry) — valuation theory and mirror symmetry

The formalization of "Lorentzian ⇒ generalized permutohedron" opens the door to:
- **Certified optimization**: algorithms on generalized permutohedra have known complexity; knowing a polytope is generalized permutohedron certifies tractability of optimization problems.
- **Scattering amplitude geometry**: in quantum field theory, BCFW recursion produces amplitudes whose Newton polytopes are generalized permutohedra; this theorem provides the algebraic explanation via Lorentzian properties of the amplitude.
- **Submodular optimization**: connects to the vast literature on submodular function minimization, which is polynomial-time solvable precisely because of the generalized permutohedron structure.

### Mandatory Deliverables

(a) **FUTURE_DIRECTIONS.md** with 3-5 testable scientific hypotheses:
   - H1: The tropical linear space of a Lorentzian polynomial has rational vertex coordinates with denominator dividing $d!$
   - H2: The submodular width of any degree-2 Lorentzian Newton polytope is zero (testable by enumeration for $n \leq 6$)
   - H3: Generalized permutohedra arising from Lorentzian polynomials satisfy the "integer decomposition property" (IDP)
   - H4: The Ehrhart $h^*$-vector of such permutohedra is unimodal

(b) **RESEARCH_PAPER.md** — standalone document proving the Lorentzian-to-permutohedron bridge, explaining the M-convex exchange mechanism, and detailing the tropical duality conjecture.

(c) **ARTICLE.md** — Scientific American style piece: "Why the Geometry of Polynomials Reveals the Shape of Quantum Amplitudes" — accessible account connecting polynomial positivity, polyhedral geometry, and physics.

(d) **Verified algorithm**: An algorithm that, given a Lorentzian polynomial (as a coefficient map), computes its Newton polytope and verifies it is a generalized permutohedron by checking all edge directions.

(e) **demo.py**: Interactive demonstration that generates Lorentzian polynomials, computes their Newton polytopes, visualizes the generalized permutohedron structure, and verifies the edge direction property.

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
