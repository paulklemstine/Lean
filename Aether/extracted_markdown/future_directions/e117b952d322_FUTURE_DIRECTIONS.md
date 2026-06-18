# Future Directions: Lorentzian Stability of Partition Functions

## Synthesis

The results in this work establish a quantitative bridge between the algebraic theory of Lorentzian polynomials and the robustness of Ising partition functions under coupling noise. The key technical achievement — proving that gapped Lorentzian signature of the coupling matrix is preserved under ε/(2n²) entrywise perturbations, with explicit free energy bounds — opens multiple research fronts. The 1/n² perturbation scale, while sufficient, is likely not sharp (the catalog's sharp Cauchy-Schwarz bound suggests 1/n is achievable). The covariance form identity connecting susceptibility to Lorentzian geometry creates a two-way bridge: algebraic results import into physics, and physical intuitions export into combinatorics. The following directions exploit this bridge in increasingly ambitious ways.

---

## Direction 1: Sharp Perturbation Scale via Cauchy-Schwarz Improvement

**Conjecture:** For the coupling perturbation problem, the safe entrywise perturbation scale can be improved from ε/(2n²) to ε/(2n) by using the sharp quadratic form bound from `LorentzianSharpStability.lean`.

**Test:** Prove that the sharp Cauchy-Schwarz inequality |Q_E(v)| ≤ n·B·‖v‖² (Theorem `quadFormBound_of_entry_bound_sharp` from the catalog) directly implies certified_robustness_preserves_signature with tolerance ε/(2n) instead of ε/(2n²). Computationally, verify that for complete graphs K_n with n up to 20, the empirical threshold for signature destruction scales as Θ(1/n) rather than Θ(1/n²).

**Impact:** An n-fold improvement in the certified safe perturbation scale. For a 100-spin system, this increases the tolerance from ~5×10⁻⁵ε to ~5×10⁻³ε, making the certificate practically useful for real materials.

The key insight is that the existing proof in `IsingPartitionStability.lean` uses the n² quadratic form bound (`quadFormBound_of_entry_bound`) while the sharp catalog result achieves n. Replacing one lemma propagates through the entire robustness chain.

Why now? The sharp bound `quadFormBound_of_entry_bound_sharp` is already proved in `Catalog/Pythagorean/LorentzianSharpStability.lean`. The only barrier is connecting the two files, which requires a straightforward import and substitution.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` — `quadFormBound_of_entry_bound_sharp`, `stability_law_sharp`

**Proof Strategy:** Import the sharp bound, substitute it in the proof of `certified_robustness_preserves_signature`, and propagate the improved constant through `combined_robustness`.

**Domain Bridges:** Numerical linear algebra (operator norm bounds), experimental physics (measurement tolerance)

**Lineage:** Direct improvement of Theorem 3.8 in this work

**Ambition:** Solid extension — straightforward but impactful

---

## Direction 2: Lee-Yang Zero Stability Under Coupling Noise

**Conjecture:** If the coupling matrix of an Ising model has gapped Lorentzian signature, then the Lee-Yang zeros of the partition function (viewed as a polynomial in e^{βh}) are stable under coupling perturbations: each zero moves by at most O(βn²δ) in the complex plane.

**Test:** For K_n models with n ∈ {4, 6, 8, 10}, compute the Lee-Yang zeros of Z(e^{βh}) before and after coupling perturbation. Plot zero displacement vs δ and verify O(βn²δ) scaling. Test whether the zeros remain on the unit circle (Lee-Yang theorem) under small perturbations.

**Impact:** Would connect three deep mathematical threads: Lorentzian polynomials, Lee-Yang theory, and perturbation theory of polynomial roots. A rigorous Lee-Yang zero stability theorem would have immediate implications for the theory of phase transitions in disordered systems.

The key insight is that Lee-Yang zeros are roots of a univariate specialization of the partition polynomial, and Lorentzian structure constrains root locations via the half-plane property. Perturbation of coefficients (which our coupling perturbation induces) should yield controlled root movement by Rouché-type arguments.

Why now? The covariance form identity (Theorem 3.6) provides the precise relationship between coupling perturbation and coefficient perturbation of the partition polynomial. The log-Lipschitz bound (Theorem 3.4) gives the quantitative control needed for Rouché's theorem.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` — spectral stability results; `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — `reversed_cauchy_schwarz_of_gapped`

**Proof Strategy:** Express the partition function as a univariate polynomial in z = e^{βh}. Use the log-Lipschitz bound to control coefficient perturbation. Apply Rouché's theorem on appropriate contours to bound zero displacement.

**Domain Bridges:** Complex analysis (Rouché's theorem), phase transition theory (Lee-Yang circle theorem), random matrix theory

**Lineage:** Extension of Theorems 3.4 and 3.6

**Ambition:** Grand challenge — would unify three major mathematical frameworks

---

## Direction 3: Lorentzian Control of Glauber Dynamics Mixing

**Conjecture:** For Ising models whose coupling matrix has gapped Lorentzian signature with margin ε, the mixing time of Glauber dynamics is O(n log n / ε), and this bound is stable under ε/(2n²) coupling perturbations.

**Test:** Simulate Glauber dynamics on K_n for n ∈ {8, 12, 16, 20} with varying spectral gaps (by rescaling J). Measure empirical mixing times and compare to the predicted n log n / ε scaling. Perturb couplings and verify mixing time stability.

**Impact:** Would establish Lorentzian structure as a sufficient condition for rapid mixing, paralleling the role of log-concavity for continuous distributions. This directly bridges algebraic combinatorics (Lorentzian polynomials) with the theory of Markov chain Monte Carlo sampling.

The key insight is that the gapped Lorentzian signature implies the Gibbs measure satisfies a Poincaré inequality, which in turn controls the spectral gap of the Glauber dynamics generator. The perturbation stability of the spectral gap (our Theorem 3.8) should propagate to mixing time stability.

Why now? Recent work on modified log-Sobolev inequalities for discrete distributions [CLV21] provides the technical framework. Our covariance bound (Theorem 3.7) gives the missing ingredient: quantitative control of the Gibbs measure's correlation structure under perturbation.

**Catalog References:** `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — `strong_concavity_on_orthogonal_complement`, `tangent_strong_concavity_of_gapped`

**Proof Strategy:** Establish a Poincaré inequality from the gapped signature. Use the perturbation stability theorem to show the Poincaré constant is stable. Derive mixing time bounds from the stable Poincaré inequality.

**Domain Bridges:** Markov chain theory, sampling algorithms, optimization (simulated annealing)

**Lineage:** Extension of Theorems 3.7 and 3.8

**Ambition:** Grand challenge — would connect algebraic geometry to computational complexity

---

## Direction 4: Extension to Potts Models and Determinantal Spin Systems

**Conjecture:** The robustness theory extends to q-state Potts models with q > 2, where the coupling matrix is replaced by a higher-order interaction tensor, and the Lorentzian condition generalizes to a multi-linear signature condition.

**Test:** Formalize the 3-state Potts partition function. For small systems (n ≤ 6), compute the partition function under coupling perturbation and verify log-Lipschitz bounds with the appropriate scaling (expected: βn²(q-1)δ for q states).

**Impact:** Would extend the Lorentzian robustness framework beyond the binary Ising case to the much richer world of multi-state spin systems, covering applications in image segmentation, community detection, and protein folding.

The key insight is that the Potts partition function can be expressed in terms of a generating polynomial in q variables per site (one per state), and the Lorentzian condition on this higher-dimensional polynomial should control stability via the same spectral gap mechanism.

Why now? The Lorentzian polynomial theory already encompasses multivariate polynomials of arbitrary degree. The challenge is formulating the appropriate "gapped signature" condition for the higher-order case and proving the analogous quadratic form bounds.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` — general n-dimensional bounds; `Catalog/Speculative/AutoResearch/LorentzianStability.lean` — multi-leaf stability

**Proof Strategy:** Define the Potts partition function as a sum over q^n configurations. Prove energy bounds by extending spinVal to q states. Apply the existing quadratic form machinery to the enlarged coupling structure.

**Domain Bridges:** Computer vision (Potts model for segmentation), network science (community detection), biophysics (protein modeling)

**Lineage:** Generalization of all theorems in this work

**Ambition:** Solid extension — technically demanding but conceptually straightforward

---

## Direction 5: Tropical and Entropy Analogues of Partition Function Stability

**Conjecture:** The log-Lipschitz bound has a tropical (zero-temperature) limit: as β → ∞, the free energy stability bound β·n²·δ → n²·δ applied to the ground state energy, and the Lorentzian condition on J controls the stability of the ground state degeneracy structure.

**Test:** For K_n with n ∈ {4, 6, 8}, compute the ground state energy and its perturbation sensitivity. Compare to the tropical limit of the partition function bounds. Investigate whether the spectral gap of J predicts the stability of ground state spin glass order parameters.

**Impact:** Would connect partition function robustness to tropical geometry (the "β → ∞" limit of statistical mechanics), opening applications in combinatorial optimization where ground state energy is the objective function.

The key insight is that the tropical limit of log Z is the maximum energy over configurations, and the tropical limit of the Lorentzian condition is a condition on the Newton polytope of the partition polynomial. The stability of this tropical structure under coupling noise is a question about the sensitivity of linear programming over the Boolean hypercube.

Why now? Tropical geometry has recently been connected to Lorentzian polynomials through the theory of M-convexity [Mur03]. Our quantitative perturbation bounds provide the missing analytical ingredient to make this connection rigorous.

**Catalog References:** `Catalog/Pythagorean/LorentzianSharpStability.lean` — `sharp_bound_tight` (tightness of bounds)

**Proof Strategy:** Take the β → ∞ limit of Theorem 3.4. Analyze the limiting behavior of the covariance form. Connect to tropical semiring operations.

**Domain Bridges:** Combinatorial optimization (MAX-CUT, spin glass), tropical geometry, information theory (entropy methods)

**Lineage:** Asymptotic limit of Theorems 3.4 and 3.9

**Ambition:** Solid extension with grand challenge aspects — connects to multiple deep theories
