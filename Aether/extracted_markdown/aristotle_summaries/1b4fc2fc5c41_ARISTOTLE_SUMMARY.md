# Summary of changes for run 5ebb9336-20c6-4f0d-8fa4-e30737de3f36
## GL₃ Tropical Satake: Finite Generation from Edge and Levi Data

### Completed deliverables

#### 1. Lean 4 Formalization (`Tropical/GL3SatakeFiniteGen.lean`)
A complete, sorry-free formalization (319 lines, 17 theorems) proving that functions on the GL₃ dominant chamber ℕ × ℕ are uniquely determined by edge restrictions and Levi convolution profiles. Key results:

- **Core shift lemmas**: Convolution with δ_{(1,0)} shifts the first coordinate: `(f * δ_{(1,0)})(a+1, b) = f(a, b)`, and similarly for the second coordinate. These are the propagation identities.

- **Vanishing lemma** (`zero_of_zero_edges_and_zero_levi`): If a function has zero edges and zero Levi profiles, it vanishes identically.

- **Interior recovery** (`interior_value_determined_by_edge_and_levi`): Every interior value f(a,b) is determined by edge data and Levi convolution profiles.

- **Main injectivity** (`edge_levi_data_injective`): A function is uniquely determined by its edge restrictions (edge01, edge10) and Levi convolution profiles (tconv f leviLeftGen, tconv f leviRightGen).

- **Existence-uniqueness** (`exists_unique_of_compatible_edge_levi_data`): Compatible edge-Levi data extends uniquely to a chamber function.

- **Round-trip** (`reconstruct_ofFun_eq`): Extracting edge-Levi data then reconstructing recovers the original function.

- **Supporting lemmas**: Depth induction principle for ℕ × ℕ, finite support from depth bounds, linearity of convolution, compatibility of extracted data.

All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

#### 2. Python Demo (`demos/gl3_tropical_satake_demo.py`)
Five computational demonstrations:
- Verification of shift properties with concrete functions
- Injectivity demonstration: perfect reconstruction from Levi profiles
- All five compatibility conditions verified numerically
- Depth induction and finite support visualization
- Two publication-quality figures saved to `demos/`

#### 3. Research Paper (`paper/gl3_tropical_satake_finite_generation.md`)
A complete mathematical paper including:
- Formal statement and proof of all main results
- A "Scientific American"-style discussion explaining the result via a Sudoku analogy
- Connections to higher-rank (GL_n) generalizations
- Applications to algorithmic reconstruction, data compression, tropical Kazhdan-Lusztig theory, and signal processing

### Mathematical content

The core mechanism is elegantly simple: convolution with a delta function at a simple coroot acts as a coordinate shift in the monoid algebra ℤ[ℕ × ℕ]. This means the left Levi profile `f * δ_{(1,0)}` is literally f shifted by one lattice step, so reading off shifted values immediately recovers f. The edge-Levi data system is complete and overdetermined — each Levi profile alone suffices, with edges providing redundancy for robustness. The compatibility conditions (5 conditions in the `EdgeLeviData.Compatible` structure) characterize exactly which data tuples arise from actual chamber functions.