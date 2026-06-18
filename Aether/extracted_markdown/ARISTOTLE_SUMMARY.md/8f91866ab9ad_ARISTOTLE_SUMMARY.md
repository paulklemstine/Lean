# Summary of changes for run 3d9e3ae1-15e6-42c6-b9cc-9ee1c0b8844b
## Completed: Tight Lorentzian Stability Radii for Uniform Matroid Families

### Formally Verified Mathematics (Lean 4)

**File: `Catalog/Pythagorean/LorentzianStabilityRadii.lean`** — 329 lines, **zero sorries**, builds cleanly with only standard axioms (propext, Classical.choice, Quot.sound).

#### New Definition
- **`LorentzianSpectralMargin`**: A structure capturing the minimum normalized spectral distance from a quadratic leaf Hessian to the boundary of Lorentzian signature, with fields for the number of variables, leaf gap, stability radius, and proofs of positivity.

#### 12 Fully Proved Theorems

1. **`leaf_quadform_decomposition`** — The fundamental algebraic identity: Q_{J−I}(v) = (∑vᵢ)² − ∑vᵢ², connecting Lorentzian structure to symmetric function theory and spectral graph theory.

2. **`leaf_gapped_signature`** — The leaf Hessian has gapped Lorentzian signature with gap exactly 1, witnessed by the all-ones direction.

3. **`leaf_hessian_two_eigenvalue_form`** — J − I = −I + J decomposition (complete graph adjacency matrix = rank-one + scalar).

4. **`stability_lower_bound`** — Any perturbation E with quadratic form bound δ < 1 preserves Lorentzian signature.

5. **`instability_witness`** — For m ≥ 2 and t > 1, an explicit diagonal perturbation breaks Lorentzianity. This is the *upper bound* matching the lower bound.

6. **`entry_bound_stability`** — Entry-wise bound: if |E_{ij}| ≤ 1/m², Lorentzianity is preserved. Uses Cauchy–Schwarz to bridge coefficient norms to quadratic form bounds.

7. **`residual_gap_degradation`** — Graceful degradation: gap(H + E) ≥ 1 − δ.

8. **`strong_concavity_on_complement`** — Strong concavity certificate for optimization applications.

9. **`leaf_perm_invariance`** — All quadratic leaves are permutation-equivalent (symmetry reduction).

10. **`quadform_positive_on_ones`** — Q(1⃗) = m(m−1), the explicit positive eigenvalue.

11. **`gapped_implies_lorentzian`** — Gapped signature implies basic Lorentzian signature.

12. **`perturbation_preserves_gap`** — The general perturbation theorem: gap ε + bound δ < ε → residual gap ε − δ.

### Other Deliverables

- **`ARTICLE.md`** — 2500-word popular science article explaining the spectral mechanism of Lorentzian stability through accessible analogies (crystal resonance, guitar tuning, phase transitions).

- **`RESEARCH_PAPER.md`** — Comprehensive 5000-word research paper with abstract, full theorem statements, proof sketches, algorithms with pseudocode, computational experiments, cross-domain connections (spectral graph theory, symmetric functions, optimization, statistical physics), and references.

- **`FUTURE_DIRECTIONS.md`** — 5 structured research directions with synthesis, conjectures, tests, and domain bridges: (1) graphic matroid stability via Kirchhoff Hessians, (2) asymptotic stability in dense regimes, (3) tropical Lorentzian stability, (4) certified computational library, (5) phase transitions and universality.

- **`demo.py`** — Interactive demo letting users input (n,r), displaying the canonical leaf Hessian, spectral data, stability radii, and running instability searches.

- **`algorithms.py`** — Core algorithms with full docstrings: leaf_hessian construction, eigengap computation, stability radius calculation, empirical binary search, and uniform matroid table generation.

- **`applications.py`** — Applications to certified sampling, combinatorial optimization, spectral graph theory, and phase transition analysis.

- **`viz_spectral_gap.py`**, **`viz_stability_heatmap.py`**, **`viz_quadform_decomposition.py`** — Three matplotlib visualization scripts.

- **`interactive_demo.html`** — Interactive HTML/JS demo with sliders for exploring the eigenvalue phase transition.

- **`PACKAGE.json`** — Complete JSON data package bundling all artifacts for web templating.