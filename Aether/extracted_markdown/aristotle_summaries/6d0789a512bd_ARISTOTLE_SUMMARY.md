# Summary of changes for run d6e6eaaf-3f08-4427-9012-7e09e4715043
## Completed: Cryptographic Security Bounds for Alternating Permutation Networks

### Lean 4 Formalization (Deliverable 1)

**File:** `Catalog/Pythagorean/Crypto/AlternatingPermutationSecurity.lean`

All theorems are fully proved with **zero `sorry` statements** and verified with only standard axioms (propext, Classical.choice, Quot.sound). The file contains:

**6 major theorems, all machine-verified:**

1. **`tv_lower_bound_of_observable_bias`** — The conceptual hinge: any bounded observable with biased expectation yields a TV distance lower bound. Converts mixing-theory observables into cryptographic distinguishers. If |f| ≤ B and the expectation gap is ≥ δ, then TV ≥ δ/(2B).

2. **`tvDist_uniform_support_bound`** — Support-size security bound: if a distribution is supported on ≤ K elements out of N total, then TV from uniform ≥ 1 - K/N. For keyed networks: TV ≥ 1 - |K|/n!.

3. **`exists_heavy_point_of_tvDist_ge`** — Heavy-point certificate: TV ≥ ε implies ∃ a with μ(a) ≥ (1+ε)/N. A concrete entropy deficiency witness.

4. **`displacement_adj_swap_bound`** — Locality constraint: composing with swap(j, j+1) changes total displacement by at most 2. This limits how fast shallow networks can diffuse.

5. **`maxPointMass_lower_bound_of_tvDist`** — Min-entropy deficiency: TV ≥ ε implies max point mass ≥ (1+ε)/N, bridging to information theory.

6. **`alternating_network_tv_from_key_space`** — Main application: any keyed alternating network with key space K satisfies TV ≥ 1 - |K|/n!.

Plus formal definitions of alternating permutation networks, distribution predicates, total displacement, and a formally stated exponential decay conjecture.

### Popular Science Article (Deliverable 2)
**File:** `ARTICLE.md` — "The Scar That Shuffling Cannot Hide" (~2500 words). Magazine-quality article explaining how shallow permutation networks leave mathematically detectable fingerprints, with concrete analogies and no mention of formal verification.

### Research Paper (Deliverable 3)
**File:** `RESEARCH_PAPER.md` (~4000 words). Complete research paper with abstract, full theorem statements, proof sketches, computational experiments on S₈, the exponential decay conjecture, and references.

### Python Code (Deliverable 4)
- **`demo.py`** — Full interactive demonstration on n=8 with TV distance, displacement, support size, and min-entropy tracking across varying rounds T and swaps k. Generates plots.
- **`algorithms.py`** — Core algorithms: TV computation, observable distinguishers, heavy-point detection, min-entropy estimation, worst-case schedule search. With docstrings and examples.
- **`applications.py`** — Four real-world applications: cipher round analysis, key schedule adequacy, diffusion quality certification, side-channel constraints.
- **`viz_tv_decay.py`** — TV distance decay curves (linear and log scale)
- **`viz_displacement_heatmap.py`** — Displacement distribution evolution heatmap
- **`viz_security_landscape.py`** — 2D security landscape (TV vs rounds × swaps)
- **`interactive_network.html`** — Interactive HTML/JS simulator with wire visualization and displacement tracking

### Future Directions (Deliverable 5)
**File:** `FUTURE_DIRECTIONS.md` — 5 research directions with Synthesis section. Includes spectral gap computation (solid extension), exponential decay conjecture proof (grand challenge), SPN generalization (grand challenge), KPZ universality bridge (grand challenge), and computational complexity of distinguishing (solid extension).

### JSON Package (Deliverable 6)
**File:** `PACKAGE.json` — Complete bundled package with all content for web templating.