# Future Directions: Quadratic Shadow Theory

## Synthesis

The Quadratic Shadow Theorem establishes that second-derivative sparsity of a polynomial is completely determined by the lattice geometry of its Newton support, with no cancellation possible for individual partial derivatives over characteristic-zero domains. This opens a program of understanding derivative complexity through lattice-shadow projections. The five directions below extend this principle along three axes: (1) generalizing to higher-order and aggregated derivatives, where cancellation *does* become possible and structural conditions (Lorentzian, M-convex) must control it; (2) connecting shadow geometry to tropical and toric geometry, creating new invariants at the intersection of combinatorics and algebraic geometry; and (3) extracting computational complexity consequences, using shadow invariants as lower-bound certificates. Together, these directions transform support compression from a single theorem into a systematic theory bridging polynomial algebra, convex geometry, and complexity.

---

## Direction 1: k-th Order Shadow Theorem and Iterated Shadow Geometry

**Conjecture:** For any k ≥ 1 and any polynomial f over a domain of characteristic zero, the set of monomials appearing in some k-th partial derivative ∂_{i₁}···∂_{iₖ}f equals exactly the k-th shadow Shₖ(Supp(f)) = {β : ∃ α ∈ Supp(f), ∃ i₁,...,iₖ, α = β + e_{i₁} + ··· + e_{iₖ}}. Furthermore, the sequence of shadow sizes |Sh₁(S)| ≥ |Sh₂(S)| ≥ ··· ≥ |Shₐ(S)| forms a log-concave sequence when S is M-convex.

**Test:** Prove the k-th shadow theorem in Lean by induction on k, using the single-step coefficient transport formula. For the log-concavity conjecture, computationally test with M-convex supports (matroid basis supports) in up to 8 variables and degree 6. A disproof would be any M-convex S where |Shₖ(S)|² > |Shₖ₋₁(S)| · |Shₖ₊₁(S)| for some k.

**Impact:** This would establish a complete hierarchy of shadow invariants controlling all-order derivative complexity, with the log-concavity providing tight bounds on how fast derivative complexity decays. For Lorentzian polynomials, this would give a new proof route to the ultra-log-concavity of derivative norms.

**Catalog References:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (coeff_pderiv_single, coeff_pderiv_pderiv), `Catalog/Bridges/Catalog/Pythagorean/SupportCompression.lean` (nonzeroDerivativeLeafSet_eq_indep)

**Proof Strategy:** Induction on k. The base case k=2 is our main theorem. For the inductive step, apply the single-derivative coefficient formula to reduce the (k+1)-th shadow to the k-th shadow of a derivative, then use the inductive hypothesis. The log-concavity conjecture likely requires injection-based arguments or connections to matroid theory.

**Domain Bridges:** Connects to combinatorial commutative algebra (Hilbert function behavior), algebraic topology (Betti number sequences of toric varieties), and information theory (entropy of derivative distributions).

**Lineage:** Direct extension of the Quadratic Shadow Theorem, building on the coefficient transport lemma.

**Ambition:** Solid extension — the k-th shadow theorem should be provable within one cycle. The log-concavity conjecture is a grand challenge that may require new ideas from matroid theory.

---

## Direction 2: Anti-Cancellation for Aggregated Derivatives in Lorentzian Polynomials

**Conjecture:** For a Lorentzian polynomial f with M-convex support, the trace of the Hessian Σᵢ ∂²f/∂xᵢ² has nonzero coefficient at every β ∈ Sh₂(Supp(f)) that is reachable by subtracting 2eᵢ for some i from some support element. More ambitiously: for any positive linear combination Σ aᵢⱼ ∂ᵢ∂ⱼf with aᵢⱼ > 0, every shadow point remains nonzero.

**The key insight is** that Lorentzian polynomials satisfy a deep positivity condition: all coefficients have the same sign after appropriate normalization, and the M-convexity of the support provides "exchange paths" that prevent total cancellation across derivative contributions.

**Why now?** The individual derivative theorem removes cancellation entirely; the natural next step is understanding when partial cancellation (across derivatives, not within one) can occur. The Lorentzian condition is the most natural structural hypothesis preventing this.

**Test:** For each homogeneous polynomial f of degree d ≤ 6 in n ≤ 5 variables with M-convex support and positive coefficients, compute the Hessian trace Σᵢ ∂²f/∂xᵢ² and check if every shadow point (of the diagonal type) appears. A disproof would be a Lorentzian polynomial where cancellation in the aggregated trace eliminates a shadow point. Test at least 10,000 random positive-coefficient polynomials with M-convex support.

**Impact:** This would be the first theorem connecting Lorentzian positivity to aggregated derivative sparsity, opening a new chapter in the theory of Lorentzian polynomials beyond the multiaffine case.

**Catalog References:** `Catalog/Speculative/AutoResearch/LorentzianMConvex.lean` (IsMConvexExchangeNat, IsLorentzianQuadratic), `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (coeff_pderiv_pderiv_ne_zero_iff)

**Proof Strategy:** Strategy C from the original proposal. Use M-convex exchange to show that coefficient arrays along shadow fibers are sign-coherent, then prove that the weighted sum cannot vanish. May require new lemmas on the structure of M-convex polytope fibers.

**Domain Bridges:** Statistical physics (partition function susceptibilities never vanish for Lorentzian systems), optimization (Hessian of log-concave functions has guaranteed non-degeneracy), tropical geometry (tropical Hessian of a Lorentzian polynomial has full tropical rank).

**Lineage:** Builds on Direction 1's individual exactness and the Catalog's M-convexity results.

**Ambition:** Grand challenge — this would be a genuine advance in the theory of Lorentzian polynomials, requiring new ideas about the interaction of positivity and aggregation.

---

## Direction 3: Tropical Shadow and Newton Polytope Projections

**Conjecture:** The quadratic shadow Sh₂(S) equals the set of lattice points in the Minkowski difference Newt(S) ⊖ Δ₂ ∩ ℤⁿ, where Newt(S) is the convex hull and Δ₂ is the simplex of degree-2 exponents. Furthermore, this identification extends to a tropical analogue: the tropical second derivative of a tropical polynomial has support equal to the tropical shadow.

**The key insight is** that the shadow construction is secretly a lattice-point projection of the Newton polytope, and tropicalization preserves this projection structure.

**Why now?** Tropical geometry has matured to the point where tropical Hessians and tropical second derivatives are well-defined. The shadow theorem provides the missing link between the algebraic and tropical pictures.

**Test:** For 3-variable polynomials of degree ≤ 8, compute both Sh₂(S) and the lattice points of Newt(S) ⊖ Δ₂. These should agree when S is a lattice polytope (all lattice points present). For general S (sparse), Sh₂(S) should be contained in but not equal to the polytope lattice points. Find precise conditions for equality.

**Impact:** This would create a bridge between the algebraic shadow theorem and the geometric theory of Newton polytopes, enabling tools from convex geometry (volume, mixed volume, Ehrhart theory) to be applied to derivative complexity questions.

**Catalog References:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (QuadraticShadow, computeQuadShadow), any tropical geometry files in the Catalog

**Proof Strategy:** Strategy B from the original proposal. Define the Minkowski shadow as a convex body, characterize its lattice points, and show containment in both directions. The tropical direction requires defining tropical differentiation on tropical polynomial rings and showing it respects the shadow structure.

**Domain Bridges:** Toric geometry (toric varieties associated to shadow polytopes), algebraic statistics (log-linear models and sufficient statistics), geometric combinatorics (Ehrhart theory of shadow polytopes).

**Lineage:** Connects the algebraic shadow (this work) to the geometric program of Newton polytope theory (Gelfand-Kapranov-Zelevinsky).

**Ambition:** Grand challenge for the full tropical program; solid extension for the lattice-point characterization.

---

## Direction 4: Shadow Complexity as an Arithmetic Circuit Lower Bound

**Conjecture:** For any arithmetic circuit C computing all n² second partial derivatives of a polynomial f with support S, the circuit size |C| satisfies |C| ≥ |Sh₂(S)| / n². Furthermore, there exist polynomial families where this bound is tight, giving an optimal sparsity-based lower bound.

**The key insight is** that the shadow size is a lower bound on the number of distinct nonzero outputs any computation must produce, and sharing of intermediate results can reduce the work by at most an n² factor (from shared first-derivative computations).

**Why now?** Arithmetic circuit complexity has few general lower bounds beyond degree-based arguments. Support-based bounds represent a new paradigm, and the shadow theorem provides the first rigorous support-to-output complexity connection.

**Test:** Construct explicit polynomial families (e.g., sparse random, structured algebraic) where the shadow size grows superlinearly in the support size. Implement optimal Hessian computation algorithms and measure their complexity relative to the shadow bound. A disproof of tightness would be a family where every algorithm beats the bound by a super-constant factor.

**Impact:** New lower bound technique for arithmetic complexity based on Newton-polytope geometry rather than degree. Could resolve specific questions about optimal Hessian computation complexity.

**Catalog References:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (quadShadow_mono, computeQuadShadow_mono — monotonicity as complexity monotone)

**Proof Strategy:** Counting argument: any correct algorithm for computing all ∂ᵢ∂ⱼf must produce |Sh₂(S)| distinct nonzero values. Each arithmetic operation produces at most one new value. First-derivative sharing reduces redundancy by at most n². Formalize this as a lower bound on the number of additions and multiplications.

**Domain Bridges:** Algebraic complexity theory (VP vs VNP, depth reduction), automatic differentiation (optimal Jacobian accumulation), sparse linear algebra (Hessian compression).

**Lineage:** Builds on the algorithm correctness theorem and monotonicity results from this work.

**Ambition:** Solid extension for the basic counting lower bound; grand challenge for tightness and connections to VP vs VNP.

---

## Direction 5: Shadow Structure of Partition Functions and Phase Transitions

**Conjecture:** For partition functions Z = Σ_α e^{-βE(α)} x^α of lattice models, the shadow size |Sh₂(Supp(Z))| undergoes a phase transition at critical temperature: below criticality, the shadow is "small" (polynomial in the system size), while above criticality, it is "large" (exponential). This transition corresponds to the onset of long-range correlations.

**The key insight is** that the shadow of a partition function's support encodes exactly the second-order response modes (susceptibilities, correlations), and phase transitions are characterized by the divergence of these quantities — which requires a sudden increase in the number of active response modes.

**Why now?** The shadow theorem provides the first rigorous link between combinatorial support geometry and derivative-based thermodynamic quantities. This creates a new geometric approach to understanding phase transitions, complementing the traditional analytic (Yang-Lee) and probabilistic (Gibbs measure) approaches.

**Test:** Implement partition functions for the 2D Ising model on small lattices (up to 8×8). As temperature varies, track |Sh₂(Supp(Z))| and compare with known critical temperature T_c. Also test Potts models and dimer models. A disproof would be a model with known phase transition where the shadow size varies smoothly through the critical point.

**Impact:** Would establish a new connection between combinatorial geometry and statistical physics, providing a purely geometric signature of phase transitions without reference to free energy analyticity or correlation length divergence.

**Catalog References:** `Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (nonzeroQuadLeafSet_eq_shadow, shadowMultiplicity)

**Proof Strategy:** For specific lattice models, characterize the support of Z combinatorially (it corresponds to valid spin configurations). Show that at high temperature (large support), the shadow is exponential, while at low temperature (concentrated support around ground states), the shadow is polynomial. The transition should occur at the point where the support "percolates" in an appropriate lattice-theoretic sense.

**Domain Bridges:** Statistical mechanics (Lee-Yang theorem, correlation inequalities), combinatorics (counting lattice configurations), computational complexity (#P-hardness of partition functions).

**Lineage:** Connects the pure mathematical shadow theory to physical observables, extending the "partition function as polynomial" philosophy of Borcea-Brändén.

**Ambition:** Grand challenge — requires new ideas connecting lattice combinatorics to shadow geometry. Even partial results (specific models, asymptotic bounds) would be highly impactful.
