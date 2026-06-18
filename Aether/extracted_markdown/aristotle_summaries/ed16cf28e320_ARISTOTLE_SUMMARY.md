# Summary of changes for run 7242ca8b-e98b-47f9-9658-0a015aa1530c
## Lorentzian Berggren Geometry — Complete Formalization

### Lean 4 Formalization (Zero Sorries)

Created two fully verified Lean 4 files with **145 declarations** (82 theorems + definitions in Core, 63 in Duality), **zero sorry statements**, across **869 lines**:

**`Pythagorean/LorentzianBerggren/Core.lean`** — Core definitions and foundational theorems:
- 12 definitions: `MinkowskiQuadraticForm`, `MinkowskiMetric`, `BerggrenGenerator`, `BerggrenWord`, `berggrenMatrix`, `evalBerggrenWord`, `rootTriple`, `hypotenuse`, `hyperbolicWeight`, `MinkowskiBilinearForm`, `LorentzianDisplacement`, `BerggrenDepth`
- Key proved theorems:
  - **Minkowski form preservation**: Each Berggren generator preserves Q(a,b,c) = a²+b²-c² (both via metric equation MᵀJM=J and via direct quadratic form computation)
  - **Determinants**: det(M₁) = det(M₃) = 1, det(M₂) = -1 (correcting a common misconception)
  - **Spectral classification**: M₁, M₃ are unipotent ((M-I)³=0); M₂ is hyperbolic with eigenvalue -1 and eigenvector (-1,1,0), satisfying Cayley-Hamilton M₂³ - 5M₂² - 5M₂ + I = 0
  - **Eigenvalue identities**: (3+2√2)(3-2√2) = 1, bounds 0 < 3-2√2 < 1 < 3+2√2, growth rate 5 < 3+2√2 < 6
  - **Hypotenuse formulas** for each generator, with growth bounds (M₂ gives 3c < c' < 7c)
  - **Word evaluation**: append distributes, metric preservation by induction, light cone preservation

**`Pythagorean/LorentzianBerggren/Duality.lean`** — Advanced structural theory:
- Definitions: `swapMatrix`, `M₁_inv`, `M₂_inv`, `M₃_inv`
- Key proved theorems:
  - **Component formulas** for all 6 components of Mᵢ·v
  - **Complete trace product table**: all 9 pairwise generator traces computed
  - **Determinant of words**: det(evalBerggrenWord w) = (-1)^(hyperbolic weight)
  - **M₂ branch analysis**: hypotenuse sequence 5→29→169→985, exponential growth
  - **Action faithfulness**: depth-1 and depth-2 injectivity (all 3 and 9 words produce distinct triples)
  - **Parabolic symmetry**: M₃ = S·M₁·S under coordinate swap, M₂ is swap-invariant
  - **Inverse matrices**: verified M₁⁻¹, M₂⁻¹, M₃⁻¹ with descent from first-generation triples
  - **Pythagorean ↔ light cone characterization** (bidirectional)

### Supporting Materials
- **`demo.py`**: Python demo with numerical verification of all key results, generating 3 plots
- **`diagram.svg`**: SVG visualization of the light cone, Berggren tree, and cross-domain bridges
- **`RESEARCH_REPORT.md`**: Formal mathematical paper covering all results
- **`DISCUSSION.md`**: Scientific American-style accessible article (~1500 words)
- **`FUTURE_DIRECTIONS.md`**: 5 ranked breakthrough opportunities with proof strategies

### Proof Techniques Used
`native_decide` (matrix computation), `ring`/`ring!` (algebra), `linarith`/`nlinarith` (inequalities), `omega` (integer arithmetic), `norm_num` (numerics), `simp` (simplification), `cases`/`fin_cases` (exhaustive case analysis), `induction` (word properties), `norm_cast` (coercion), `positivity` (positivity goals)