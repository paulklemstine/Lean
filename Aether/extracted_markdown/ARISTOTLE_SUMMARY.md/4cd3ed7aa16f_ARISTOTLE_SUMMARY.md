# Summary of changes for run ca377267-d354-4a89-bc58-e749cf9b7477
## GL₃ Tropical Satake Uniqueness — Complete Formalization

### Formally Verified Mathematics (Lean 4)

**File: `Tropical/GL3TropicalSatake.lean`** (376 lines, fully verified, no sorry)

The Lean formalization establishes the GL₃ tropical Satake uniqueness theorem: a tropical function on the dominant chamber `{(a,b,c) ∈ ℤ³ | a ≥ b ≥ c}` is uniquely determined by its tropical convolutions with rank-1 Levi test functions.

#### Key Results (all machine-verified):

1. **`tconvDelta_injective`** — Core theorem: tropical convolution with *any* dominant delta function is injective. The proof reveals that the dominant cone is a sub-semigroup of (ℤ³, +), so every shift μ ↦ μ + α stays in the dominant chamber. Only uses axioms `propext` and `Quot.sound`.

2. **`gl3_tropical_satake_testFamily_injective`** — The three-test-function operator `f ↦ (f ⊛ δ_{τ₁}, f ⊛ δ_{τ₂}, f ⊛ δ_{τ₃})` is injective for any test family satisfying `IsRankOneLeviTest` and `IsCentralOrDetTest` predicates.

3. **`gl3_tropical_satake_testFamily_unique`** — Extensional uniqueness form: if two tropical functions agree on all three convolutions, they are equal.

4. **`weyl_tconv_triple_injective`** — For the Weyl-symmetrized convolution (taking max over S₃-orbits), the three fundamental coweight tests together determine f. This uses `sortTriple` to compute dominant representatives.

5. **`equal_test_convolutions_imply_equal_facet_valuations`** — Bridge theorem: equal test convolutions imply equal facet valuations.

6. **`shift_injective_general`** — Abstract generalization: for any abelian group, the shift map x ↦ x + a is injective.

#### Mathematical Insight

The formalization reveals that the dominant cone's semigroup property is the fundamental mechanism: since adding two dominant weights always yields a dominant weight, every delta function shift is reversible. This makes *any single* delta convolution injective — the three-test-function formulation adds geometric structure (facet valuations, Levi marginals) that connects to the representation-theoretic framework.

For the Weyl-symmetrized convolution, a single test is NOT sufficient in general (we include a GL₂ counterexample in the Python demo), but the central element ω₃ = (1,1,1) has a singleton S₃-orbit, making it still behave as a simple shift.

### Python Demos

**File: `Tropical/demos/tropical_satake_demo.py`** — Interactive demonstrations:
- Basic injectivity with concrete examples
- Recovery of f from its convolution (inverse operation)
- Weyl-symmetrized convolution computation
- GL₂ counterexample showing single Weyl test insufficiency
- Application scenarios (fingerprinting, crystal identification)

**Visualizations** (generated PNGs in `Tropical/demos/`):
- `dominant_chamber.png` — 3D view of the GL₃ dominant chamber
- `convolution_values.png` — How convolution shifts support
- `injectivity_diagram.png` — Schematic of the operator separation principle

### Research Paper

**File: `Tropical/paper.md`** — Complete mathematical paper including:
- Formal statement and proof of all results
- Discussion of the Weyl-symmetrized subtlety
- Scientific American-style explanation with crystal/photography analogy
- Connections to Berenstein-Zelevinsky polytopes, MV cycles, and tropical flag varieties
- Future directions (GL_n extension, Weyl-only version, algorithmic applications)