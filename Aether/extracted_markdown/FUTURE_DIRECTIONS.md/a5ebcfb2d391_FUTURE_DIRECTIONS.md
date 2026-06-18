# Future Directions: Tropical T-Duality and Mirror Symmetry

## Direction 1: Multi-Dimensional Tropical Torus Fibrations and SYZ Duality

**Hypothesis:** The one-dimensional tropical Legendre duality extends to a certified multi-dimensional duality on polyhedral fans in ℝⁿ, providing a formal tropical version of the SYZ mirror symmetry conjecture.

**Proof Strategy:**
1. Define `tropPotentialPL` over `Fin n → ℝ` with affine functions `c i + ⟨m i, x⟩`.
2. Define the dual potential via `inf_i(c i - ⟨p, m i⟩)`.
3. Prove the multi-dimensional Fenchel-Moreau inequality.
4. Define tropical torus fibrations as projections from polyhedral complexes and prove fiber-wise duality.

**Key Lemmas to Formalize:**
- `Finset.inf'` over `Fin n → ℝ` with inner product evaluation
- Polyhedral fan structure from tropical potentials
- Fiber-wise Legendre transform on tropical affine manifolds

**Cross-Domain Connections:**
- Toric geometry: moment polytopes as tropical potentials
- Symplectic geometry: Lagrangian fibrations as tropical duals
- Algebraic geometry: Newton polytope duality as tropical mirror

**Estimated Complexity:** Medium-high. The linear algebra infrastructure exists in Mathlib; the main challenge is managing polyhedral combinatorics.

---

## Direction 2: Full Fenchel-Moreau Theorem for Tropical Convex Functions

**Hypothesis:** For finite piecewise-linear *convex* potentials, the biconjugate inequality $f^{\circ\circ} \leq f$ becomes an equality: $f^{\circ\circ} = f$.

**Proof Strategy:**
1. Define tropical convexity: $f$ is tropically convex iff $f = \Phi_A$ for some $(c, m)$ with $m$ injective (distinct slopes).
2. Prove that the Fenchel conjugate of a tropically convex function is tropically convex.
3. Prove involutivity: $f^{\circ\circ}(x) = f(x)$ for all $x$ when $f$ is tropically convex and the evaluation set $S$ contains all slopes.

**Key Lemmas:**
- `tropFenchelConj_of_convex_is_convex`
- `tropBiconj_eq_of_convex`
- Connection to classical Fenchel-Moreau theorem via tropicalization

**Cross-Domain Connections:**
- Convex optimization: strong duality in linear programming
- Information theory: rate-distortion duality
- Economic theory: Legendre-Fenchel duality in utility theory

**Estimated Complexity:** Medium. The key insight is that for piecewise-linear functions with distinct slopes, the Legendre transform permutes the branch data.

---

## Direction 3: Tropical Discriminants and Wall-Crossing Formulae

**Hypothesis:** Corner locus transitions under parameter variation correspond to tropical discriminant loci, and the combinatorial changes in the corner structure encode wall-crossing invariants.

**Proof Strategy:**
1. Define parameterized tropical potentials $\Phi_{A,t}(x) = \inf_i(c_i(t) + m_i x)$ with $c_i : \mathbb{R} \to \mathbb{R}$ smooth.
2. Define the tropical discriminant as the set of parameters $t$ where the corner locus topology changes.
3. Prove that the discriminant is a piecewise-linear set in parameter space.
4. Define wall-crossing invariants as differences in minimizer multiplicities across the discriminant.

**Key Lemmas:**
- `corner_locus_topology_change_iff_discriminant`
- `discriminant_is_piecewise_linear`
- `wall_crossing_count` and additivity

**Cross-Domain Connections:**
- Enumerative geometry: tropical curve counts via corner loci
- Stability conditions: wall-crossing in Bridgeland stability
- Singularity theory: A-D-E classification via tropical degenerations

**Estimated Complexity:** High. Requires formalizing the topology of piecewise-linear sets and their bifurcation theory.

---

## Direction 4: Tropicalized Partition Functions and Free Energy Duality

**Hypothesis:** The tropical limit of string partition functions yields a min-plus free energy, and T-duality becomes an exact identity between tropicalized partition functions.

**Proof Strategy:**
1. Define the tropical partition function: $Z_{\text{trop}}(\beta) = \inf_{n,w} E(R, n, w)$ for finite spectrum.
2. Prove that $Z_{\text{trop}}(\beta, R) = Z_{\text{trop}}(\beta, 1/R)$ under charge swap.
3. Connect to the soft-tropical partition function $Z_\varepsilon = -\varepsilon \log \sum_i e^{-E_i/\varepsilon}$ and prove convergence as $\varepsilon \to 0$.
4. Prove free energy duality: $F_{\text{trop}}(R) = F_{\text{trop}}(1/R)$.

**Key Lemmas:**
- `tropicalPathIntegral_tdual_invariant`
- `softTropical_convergence` (from TropicalFeynman.lean)
- `freeEnergy_duality`

**Cross-Domain Connections:**
- Statistical mechanics: Legendre transform between entropy and free energy
- Information theory: tropical rate-distortion as partition function
- Machine learning: tropical loss landscapes and their dualities

**Estimated Complexity:** Medium. The finite case is combinatorial; the convergence proof requires epsilon-delta analysis.

---

## Direction 5: Tropical Enumerative Geometry via Certified Corner Counting

**Hypothesis:** Tropical curve counts — the number of tropical curves of a given degree and genus passing through prescribed points — can be computed and certified via corner locus enumeration in higher-dimensional tropical potentials.

**Proof Strategy:**
1. Define tropical curves in ℝ² as balanced weighted graphs with prescribed slopes.
2. Encode tropical curve counting as a corner multiplicity computation.
3. Prove Mikhalkin's correspondence theorem in the simplest case (degree 1 rational curves in ℝ²).
4. Implement and certify a tropical curve counting algorithm.

**Key Lemmas:**
- `tropical_curve_is_corner_locus` (in 2D)
- `corner_multiplicity_eq_tropical_weight`
- `tropical_curve_count_eq_algebraic` (Mikhalkin correspondence)

**Cross-Domain Connections:**
- Algebraic geometry: Gromov-Witten invariants
- Combinatorics: lattice path enumeration
- Mathematical physics: topological string amplitudes

**Estimated Complexity:** Very high. Mikhalkin's correspondence theorem is a deep result; even the simplest cases require substantial formalization effort.

---

## Implementation Priority

| Priority | Direction | Estimated Effort | Expected Impact |
|----------|-----------|-----------------|-----------------|
| 1 | Direction 2 (Fenchel-Moreau equality) | Medium | High — completes mirror symmetry story |
| 2 | Direction 1 (Multi-dimensional SYZ) | Medium-High | Very High — opens toric geometry bridge |
| 3 | Direction 4 (Partition function duality) | Medium | High — connects to physics |
| 4 | Direction 3 (Wall-crossing) | High | Very High — new territory |
| 5 | Direction 5 (Enumerative geometry) | Very High | Breakthrough — certified curve counts |

---

## Team Research Directives

Each direction should be pursued by a team that:
1. **States precise conjectures** as Lean theorem signatures with `sorry`.
2. **Validates computationally** using Python/NumPy before attempting formal proofs.
3. **Decomposes aggressively** — each direction should generate 5-15 independent helper lemmas.
4. **Cross-references** with existing Mathlib infrastructure using `lean_local_search`.
5. **Documents** with detailed module docstrings connecting the formalism to the physics/geometry.
6. **Iterates** — each proved lemma should suggest new conjectures and extensions.

The tropical T-duality skeleton is now certified. The next step is to grow it into a full tropical mirror symmetry framework, connecting string-theoretic dualities to certified combinatorial geometry.
