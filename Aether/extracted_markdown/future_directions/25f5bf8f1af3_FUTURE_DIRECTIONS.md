# Future Directions: Double Scaling Limits in Wreath-Product Subgroup Pressure

## Synthesis

The theorems established in this work — subcritical irrelevance, per-copy pressure stability, and critical obstruction — form the foundation of a **critical-phenomena theory for finite group asymptotics**. They identify the exponent α_c = b/a as a sharp boundary between perturbatively irrelevant and relevant regimes of the wreath coupling. The five directions below extend this foundation along three axes: (1) making the envelope parameters explicit via representation theory, (2) computing the crossover profile that governs the marginal regime, and (3) exporting the scaling framework to random matrix theory and combinatorial optimization. Together, these directions would transform the current perturbative understanding into a complete universality theory for wreath-product families.

---

## Direction 1: Explicit Envelope from Clifford Theory

**Conjecture**: The polynomial defect envelope |Δ(k,m)| ≤ C·m^a/k^b has a = 1 and b = 1 for the symmetric group wreath product S_k ≀ S_m, with C computable from the irreducible representation count of S_k.

**The key insight is** that the imprimitive defect arises from subgroups with nontrivial projection to S_m, and Clifford theory gives an exact decomposition of such subgroups in terms of orbits on irreducible representations. The number of such orbits grows polynomially in m but is controlled by 1/k through the orbit-stabilizer theorem.

**Why now?** The subcritical irrelevance theorem (Theorem 1) is parametric in (a, b) — plugging in explicit values immediately yields a concrete critical exponent. The Clifford-theoretic machinery is available in Mathlib's representation theory library.

**Test**: Compute |Δ(k,m)| for k ∈ {3,4,5,6} and m ∈ {1,...,20} using GAP. Fit the polynomial model log|Δ| ~ a·log(m) - b·log(k) + const. If a ≈ 1 and b ≈ 1, the conjecture is supported.

**Impact**: Would give the first explicit critical exponent for a wreath-product universality transition.

**Catalog References**: `Pythagorean/WreathPerturbation.lean` (perturbative bounds), `Pythagorean/DoubleScalingLimit.lean` (threshold theorem).

**Proof Strategy**: Decompose subgroups by their projection to S_m. Use Clifford theory to count irreducible orbits. Bound the orbit count by m·(number of irreducibles of S_k). Use the asymptotic formula for the number of irreducibles of S_k (partition count p(k) ~ exp(π√(2k/3))/(4k√3)) to extract the k-dependence.

**Domain Bridges**: Algebraic combinatorics (partition counting), asymptotic representation theory.

**Lineage**: Extends `beta_wreath_eq_mul_beta_symm_plus_error` from O(1/k) to explicit polynomial envelope.

**Ambition**: Solid extension — directly provable from existing catalog + Clifford theory.

---

## Direction 2: Crossover Profile Computation

**Conjecture**: At the critical scaling m(k) ~ λ·k^{α_c}, the wreath defect converges to a nontrivial crossover profile F(λ) that is continuous, satisfies F(0) = 0, and is eventually nonzero.

**The key insight is** that the crossover profile F(λ) should be computable as a limit of partition-function ratios, analogous to finite-size scaling functions in statistical mechanics. For symmetric groups, the relevant partition functions are expressible in terms of Bell numbers and their wreath-product generalizations.

**Why now?** The formalized `CrossoverProfileConjecture` in `DoubleScalingLimit.lean` gives a precise target. Computational experiments with small k (3-8) can test convergence and shape of F(λ).

**Test**: For k = 5, 6, 7, 8, compute Δ(k, ⌊λk⌋) for λ ∈ {0.1, 0.2, ..., 5.0}. Plot against λ. If curves collapse to a single profile as k grows, the conjecture is supported. If they diverge, the critical exponent may be wrong.

**Impact**: Would establish the first explicit scaling function for a finite-group phase transition, opening connections to conformal field theory and exactly solvable models.

**Catalog References**: `Pythagorean/DoubleScalingLimit.lean` (CrossoverProfileConjecture), `Bridges/Catalog/Pythagorean/SubgroupUniversality.lean` (extensivity).

**Proof Strategy**: Express F(λ) as a limit using the exact formula for wreath-product subgroup counts. Use dominated convergence and monotonicity of subgroup pressure to establish convergence. Prove F is continuous by equicontinuity of the approximating sequence.

**Domain Bridges**: Statistical mechanics (finite-size scaling), analytic combinatorics (singularity analysis).

**Lineage**: Direct continuation of `wreath_defect_tendsto_zero_of_subcritical_nat` into the marginal regime.

**Ambition**: Grand challenge — requires new combinatorial identities and analytic techniques.

---

## Direction 3: Random Matrix Crossover Analogy

**Conjecture**: The wreath-product defect at critical scaling exhibits the same qualitative behavior as the GOE-GUE crossover in random matrix theory, with the coupling strength parameter playing the role of the symmetry-breaking field.

**The key insight is** that the direct product (S_k)^m corresponds to a block-diagonal ensemble (independent blocks), while the wreath product introduces inter-block coupling through S_m. The threshold theorem says this coupling is irrelevant below α_c — exactly as GOE perturbations are irrelevant below the Dyson critical coupling strength.

**Why now?** The `relevance_ratio_bounded_of_polynomial_envelope` theorem gives a precise "scaling dimension" for the perturbation, which can be compared to the crossover exponent in random matrix theory. The analogy is now backed by rigorous mathematics, not just heuristics.

**Test**: Compare the crossover profile F(λ) (Direction 2) with the Tracy-Widom crossover interpolation. If the functional forms match qualitatively (sigmoid-like transition), the analogy is deep. If they differ, the analogy is superficial.

**Impact**: Would establish a rigorous bridge between finite group asymptotics and random matrix universality, potentially allowing transfer of techniques in both directions.

**Catalog References**: `Pythagorean/DoubleScalingLimit.lean` (regime classification), `Bridges/Catalog/Pythagorean/SubgroupUniversality.lean` (exponent additivity as analog of level repulsion).

**Proof Strategy**: Define a coupling observable for the wreath product that matches the symmetry-breaking field in random matrix theory. Use moment methods to show that the first few moments of the coupling observable match the GOE-GUE crossover moments below threshold.

**Domain Bridges**: Random matrix theory, quantum chaos, number theory (via Montgomery-Odlyzko).

**Lineage**: Extends the statistical mechanics bridge from metaphor to theorem.

**Ambition**: Grand challenge — paradigm-shifting if successful.

---

## Direction 4: Higher-Order Wreath Products and Iterated Thresholds

**Conjecture**: For iterated wreath products S_k ≀ S_m ≀ S_n, there exists a **hierarchy of critical exponents** α_1, α_2 such that the first coupling becomes relevant at m ~ k^{α_1} and the second at n ~ k^{α_2}, with α_1 ≤ α_2.

**The key insight is** that each level of wreath product nesting introduces a new perturbation, and the threshold theorem should apply recursively. The hierarchy of thresholds would form a discrete analog of the renormalization group flow.

**Why now?** The proof architecture of `polynomial_bounds_force_threshold` is modular — it takes a polynomial envelope as input, regardless of its source. Applying it at each nesting level should give a cascade of thresholds.

**Test**: Compute subgroup counts for S_3 ≀ S_m ≀ S_n for small m, n. Check whether the double defect (deviation from the three-fold product prediction) exhibits a two-parameter threshold.

**Impact**: Would establish a complete renormalization group picture for wreath-product towers, directly analogous to block-spin renormalization in statistical mechanics.

**Catalog References**: `Pythagorean/DoubleScalingLimit.lean` (single-level threshold), `Pythagorean/WreathPerturbation.lean` (perturbative framework).

**Proof Strategy**: Induction on nesting depth. At each level, use the inner wreath product's pressure (already controlled by the previous threshold) as the base pressure, and apply the polynomial envelope framework to the next coupling.

**Domain Bridges**: Renormalization group theory, hierarchical models in probability.

**Lineage**: Natural generalization of the single-level threshold to iterated constructions.

**Ambition**: Solid extension — the proof infrastructure is already in place.

---

## Direction 5: Subgroup Pressure Phase Diagram for General Wreath Products G ≀ H

**Conjecture**: For general finite groups G, H, the critical exponent α_c(G,H) of the wreath product G ≀ H depends only on the asymptotic subgroup growth type of G and the representation theory of H, not on their detailed structure.

**The key insight is** that if α_c depends only on coarse invariants (growth type, representation dimension), then it is a **universal** quantity in the statistical mechanics sense — it classifies wreath products into universality classes based on their scaling behavior, not their algebraic details.

**Why now?** The formalized definitions (`AsymptoticallyIrrelevantAtExponent`, `SeparatesRegimes`, `PolynomialDefectEnvelope`) are already parametric in arbitrary functions betaSymm and betaW. Instantiating them for different group families is straightforward.

**Test**: Compute α_c for wreath products involving cyclic groups, dihedral groups, and alternating groups. If groups with the same subgroup growth type yield the same α_c, universality is confirmed.

**Impact**: Would establish a complete **classification theorem** for wreath-product universality classes, the group-theoretic analog of classifying phase transitions by their critical exponents.

**Catalog References**: `Pythagorean/DoubleScalingLimit.lean` (general framework), `Bridges/Catalog/Pythagorean/SubgroupUniversality.lean` (universality class definition).

**Proof Strategy**: Use the polynomial envelope framework with group-dependent constants. Show that the constants a, b depend only on the subgroup growth type by bounding them through index-distortion and orbit-counting arguments that are sensitive only to growth rates.

**Domain Bridges**: Geometric group theory (growth types), ergodic theory (entropy classification).

**Lineage**: Extends Direction 1 from symmetric groups to general groups.

**Ambition**: Grand challenge — would unify finite group classification with critical phenomena.
