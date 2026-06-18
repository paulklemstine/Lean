# Summary of changes for run 809b7fb9-1748-4283-8f5c-4def225d1cb7
## Completed: Quadratic Shadow Theorem — Non-Multiaffine Extension of Support Compression

### Formally Verified Mathematics (Lean 4)

**File:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (237 lines, zero sorries)

I proved **8 theorems** with complete, machine-verified proofs, including 3 substantial flagship results:

1. **Coefficient Transport Formula** (`coeff_pderiv_single`, `coeff_pderiv_pderiv`): Explicit formulas showing that the coefficient of β in ∂ⱼ(∂ᵢf) equals coeff(β+eⱼ+eᵢ, f) times a product of natural numbers ≥ 1. This is the key technical engine.

2. **The Quadratic Shadow Theorem** (`nonzeroQuadLeafSet_eq_shadow`): For any polynomial over an integral domain of characteristic zero, the set of monomials appearing in any second partial derivative equals *exactly* the quadratic shadow of the Newton support. This is proved via `nonzeroQuadLeafSet_subset_shadow` (containment) and `shadow_subset_nonzeroQuadLeafSet` (reverse containment), with the key vanishing criterion `coeff_pderiv_pderiv_ne_zero_iff` as the bridge.

3. **Verified Algorithm** (`mem_computeQuadShadow_iff`): A computable algorithm `computeQuadShadow` that correctly computes the shadow from finite support data in O(|S|·n²) time.

4. **Monotonicity** (`quadShadow_mono`, `computeQuadShadow_mono`): Shadow is monotone under support inclusion — a complexity monotone.

**Key Mathematical Discovery:** Cancellation *never* occurs for individual second partial derivatives, because each output coefficient is a nonzero scalar multiple of exactly one input coefficient. Positivity of coefficients is NOT needed — the theorem holds universally over characteristic-zero domains. This is strictly stronger than what was initially expected.

### New Definitions Introduced
- `QuadraticShadow` — the set of exponents reachable by subtracting two basis vectors
- `NonzeroQuadLeafSet` — exponents appearing in some ∂ᵢ∂ⱼf  
- `computeQuadShadow` — verified computable algorithm
- `NewtonSupport` / `NewtonSupportFinset` — polynomial support as set/finset

### Deliverables Produced

| File | Description |
|------|-------------|
| `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` | Lean 4 proofs (zero sorries) |
| `ARTICLE.md` | Popular science article (~2500 words) |
| `RESEARCH_PAPER.md` | Full research paper with proofs, algorithms, experiments |
| `FUTURE_DIRECTIONS.md` | 5 structured future directions with conjectures |
| `demo.py` | Demonstration: constructs polynomials, verifies theorem, searches for counterexamples |
| `algorithms.py` | Verified algorithms with doctests |
| `applications.py` | Applications to optimization, physics, complexity |
| `viz_shadow_heatmap.py` | Matplotlib visualization of shadow multiplicity |
| `interactive_shadow.html` | Interactive HTML/JS shadow explorer |
| `PACKAGE.json` | Complete JSON data package for web templating |

### Connection to Catalog Results
The work explicitly extends `SupportCompression.nonzeroDerivativeLeafSet_eq_indep` from the multiaffine/matroid setting to general homogeneous polynomials, identifying that the obstruction (cancellation) is structurally impossible for individual derivatives. It also connects to `LorentzianMConvex.lean` by showing shadow structure is determined purely by support geometry.