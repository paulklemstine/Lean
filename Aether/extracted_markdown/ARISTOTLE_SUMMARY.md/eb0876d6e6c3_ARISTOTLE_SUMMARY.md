# Summary of changes for run 050a6eef-98bf-4c24-9fe8-244b5ab76996
## GL₃ Tropical Satake Finite Presentation — Complete Formalization

### Formally Verified Mathematics (Lean 4)

**File:** `Tropical/GL3Presentation/Basic.lean` (469 lines, zero `sorry`, clean build)

All 11 theorems are fully proved with only standard axioms (propext, Classical.choice, Quot.sound):

#### Core Definitions
- `DomWeightGL3 = ℕ × ℕ` — dominant coweights as pairs (a,b) ↔ partition (a+b, b, 0)
- `pieriObs1`, `pieriObs2` — the two GL₃ Pieri convolution operators with concrete formulas from the Pieri rule for V and ∧²V
- `ObservablePackage` — bundles edge data (e₁, e₂) and Pieri profiles (c₁, c₂) with support conditions
- `Compatible` — 8 explicit local compatibility conditions (boundary consistency, base vanishing, tropical rhombus relations)

#### Key Theorems Proved

1. **`determined_by_pieriObs2`** — The ω₂-Pieri profile uniquely determines any function (no support assumption needed). This is the key structural fact: the GL₃ ω₂-Pieri rule has exactly one predecessor per coweight, making it a shift operator.

2. **`finite_determinacy_GL3`** — Functions with bounded support and matching observables (edges + both Pieri profiles) are equal.

3. **`abstract_determinacy`** — General injectivity theorem from the *triangular recovery property*, proved by strong induction on height a+b. This abstract framework is designed for higher-rank generalizations.

4. **`gl3_triangular_recovery`** — The GL₃ Pieri operators satisfy the triangular recovery property.

5. **`finite_realization_GL3`** — Every compatible observable package is realized by a bounded-support function, constructed explicitly as f(a,b) = c₂(a, b+1).

6. **`observableImage_eq_compatible`** — The image of the observable map equals the set of compatible packages (the finite presentation statement).

7. **`obsMap_injective`** / **`obsMap_injOn`** — The observable map is injective.

8. **`bounded_GL3_tropSatake_equiv_compatibleObservables`** — The complete bijection `{f // HasBoxSupport N f} ≃ {O // Compatible N O}` preserving edge data.

9. **`support_antidiagonal_finite`**, **`boxSupport_finite`** — Support finiteness results.

#### Mathematical Insight

The key discovery formalized here is that for GL₃, the Pieri rule for the second fundamental representation ∧²V has exactly **one predecessor** per dominant coweight (because adding a vertical strip of size 2 to a partition with λ₃ = 0 has only one valid placement). This makes the ω₂-Pieri convolution a simple shift operator, which trivially determines all function values. The ω₁-Pieri convolution (which has up to 2 predecessors, involving a tropical minimum) provides additional consistency conditions — the "tropical rhombus relations" — that characterize which observable packages are realizable. This is a rank-2 phenomenon; for GL_n with n ≥ 4, intermediate fundamental representations have multiple predecessors, making recovery genuinely harder.

### Python Demos

**File:** `demos/gl3_tropical_presentation_demo.py`

Interactive demonstration with 4 generated visualizations:
- `demos/lattice.png` — The GL₃ dominant coweight lattice with edges highlighted
- `demos/pieri_predecessors.png` — Side-by-side comparison of ω₁ (2 predecessors) vs ω₂ (1 predecessor) Pieri structures
- `demos/recovery.png` — Visual proof of function recovery from the ω₂-Pieri profile
- `demos/tropical_rhombus.png` — The tropical rhombus inequality at interior points

Plus textual demos of the shift property, finite determinacy, compatibility conditions, and dimension counting.

### Research Paper

**File:** `research/tropical_gl3_presentation.md`

Complete mathematical paper with:
- Full statement and proof sketch of all main results
- Representation-theoretic background (Pieri rules for GL₃)
- Discussion of the rank-2 simplification and why it fails in higher rank
- Scientific American-style discussion section explaining the results via analogy (CT scan reconstruction)
- Connections to tropical geometry, crystal bases, and neural networks
- Future directions for GL_n generalization, other root systems, and q-deformation
- Applications to tropical optimization, representation-theoretic computations, and tropical curve counting