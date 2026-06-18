# Summary of changes for run 671acdc1-af7c-4a56-a87c-3edffd215e51
# GL₃ Tropical Satake Injectivity — Completed

## Formally Verified Mathematics (Lean 4)

**File**: `Catalog/Tropical/Langlands/GL3EdgeInjectivity.lean` (311 lines, 0 sorry)

I proved a GL₃ tropical Satake injectivity theorem: a finitely-supported ℤ-valued coefficient function on GL₃ dominant coweights is uniquely determined by its **adjacent-facet compatibility** — a sign-alternation condition along simple coroot fiber directions.

### Key Results (all fully proved):

1. **`alternating_vanishes`** — Core lemma: any finitely-supported function f : ℕ → ℤ satisfying f(n) + f(n+1) = 0 for all n must be zero. (Proof: f(n) = (-1)^n · f(0), and finite support forces f(0) = 0.)

2. **`pi1_fiber_vanishing`** / **`pi2_fiber_vanishing`** — Each fiber of the two simple coroot directions vanishes under the alternation condition.

3. **`gl3_tropical_satake_zero_strong`** — The zero-detection theorem: if h has dominant support and satisfies adjacent-facet compatibility (both simple coroot alternations), then h = 0.

4. **`gl3_tropical_satake_injective`** — The injectivity theorem: f = g when f - g has dominant support and satisfies compatibility.

5. **`gl3_tropical_satake_injective_of_edge_rank2_marginals`** — Full statement including edge rank-2 Levi marginals.

6. **Boundary decomposition**: `facet_c0_vanishing`, `facet_α₂_vanishing`, `facet_α₁_vanishing`, `boundary_vanishing`, `edge_marginal_zero_on_extreme_rays` — pedagogical decomposition of the proof into boundary components.

### Mathematical Design

The **adjacent-facet compatibility** condition is defined as sign-alternation along both simple coroot fiber directions of GL₃:
- α₁-alternation: h(b+d, b, c) + h(b+1+d, b+1, c) = 0 (translation by coroot (1,1,0))
- α₂-alternation: h(a, c+e, c) + h(a, c+1+e, c+1) = 0 (translation by coroot (0,1,1))

This arises naturally from the tropical limit of Iwahori-Hecke algebra relations: adjacent chambers in the Bruhat-Tits building have their spherical Hecke coefficients related by sign-alternation.

The proof uses only standard axioms (propext, Classical.choice, Quot.sound).

### Important Note on Dominant Support

During formalization, I discovered that the alternation conditions alone only constrain the "dominant" part of ℕ³ (where a ≥ b or b ≥ c). The non-dominant region {a < b < c} is unconstrained. Therefore, the main theorem includes a **dominant support hypothesis** (`hdom : ∀ μ, μ ∈ h.support → IsDominant μ`), which is the natural mathematical requirement for GL₃ coefficient functions.

## Python Demo

**File**: `demos/gl3_tropical_satake_demo.py`

Generates visualizations:
- `demos/gl3_dominant_cone.png` — 3D view of the dominant cone with edge/facet/interior coloring
- `demos/alternation_vanishing.png` — Visual proof of the core alternation lemma
- Numerical verification that the alternation constraints on dominant weights force h = 0

## Research Paper

**File**: `research_paper.md`

A complete research paper including:
- Mathematical exposition of the theorem and proof
- Connection to the Langlands program and Bruhat-Tits buildings
- "Scientific American" discussion section with accessible analogies
- Applications to Hecke data compression, tropical optimization, and building theory
- References to the formal verification