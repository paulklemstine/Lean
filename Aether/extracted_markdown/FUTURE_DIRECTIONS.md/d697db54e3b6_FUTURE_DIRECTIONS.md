# Future Directions: Iterated Shadow Geometry

## Synthesis

The iterated shadow theory established in this work creates a new bridge between algebraic differentiation, discrete convex geometry, and combinatorial Hodge theory. The central insight is that the support dynamics of polynomial differentiation are governed by a purely combinatorial shadow operator that forms a semigroup — and this semigroup structure opens multiple research frontiers simultaneously. The shadow profile (k ↦ |Sh_k(S)|) is a new polynomial invariant that encodes the entire derivative complexity hierarchy in a single sequence, and the Shadow Log-Concavity Conjecture suggests this invariant has deep structural properties linked to exchange axioms and Lorentzian geometry. Each direction below extends this core structure into a different mathematical domain, but they share a common thread: the shadow operator as a universal tool for tracking how combinatorial complexity decays under algebraic operations.

---

## Direction 1: Shadow Inequalities for Lorentzian Polynomials

**Conjecture:** If $f$ is a Lorentzian polynomial (in the sense of Brändén–Huh), then its support $S = \text{supp}(f)$ satisfies the shadow log-concavity inequality $|\text{Sh}_k(S)|^2 \geq |\text{Sh}_{k-1}(S)| \cdot |\text{Sh}_{k+1}(S)|$ for all admissible $k$.

**Test:** Implement the Lorentzian polynomial verification algorithm (checking that all second-order partial derivatives have alternating sign Hessians) for polynomials with supports drawn from matroid bases, products of simplices, and Schur polynomial supports up to $n = 8$ variables and degree $\leq 10$. Verify shadow log-concavity for each confirmed Lorentzian polynomial.

**The key insight is** that Lorentzian polynomials already satisfy coefficient-level log-concavity, and the shadow profile is a coarser invariant (support-level rather than coefficient-level), so the conjecture amounts to showing that log-concavity "descends" from coefficients to support sizes — a phenomenon that should follow from the coefficient transport formula if the descending factorial scalars are sufficiently well-behaved.

**Why now?** The coefficient transport formula (Theorem 3.1) provides the exact algebraic bridge between support-level and coefficient-level properties. Previous work on Lorentzian polynomials lacked this explicit multi-index transport law.

**Impact:** Would establish a new, elementary route to combinatorial log-concavity that bypasses Hodge theory.

**Catalog References:** `Pythagorean/IteratedShadowGeometry.lean` (coeff_iteratedPDeriv, descFactorial_prod_pos), `Bridges/Catalog/Speculative/AutoResearch/WeightedSupportShadow.lean` (coeff_pderiv_pderiv).

**Proof Strategy:** Use the coefficient transport formula to relate shadow sizes to sums of products of descending factorials weighted by coefficients. Apply the Cauchy–Schwarz inequality or FKG inequality on the resulting sums.

**Domain Bridges:** Lorentzian polynomial theory, algebraic combinatorics, Hodge theory.

**Lineage:** Extends Brändén–Huh (2020) from coefficient log-concavity to support-level log-concavity.

**Ambition:** Grand challenge — would unify support geometry with Lorentzian algebra.

---

## Direction 2: Tropical Differential Entropy via Newton Shadows

**Conjecture:** For a polynomial $f$ with Newton polytope $P$, define the **tropical shadow entropy** as $H_k = \log |\text{Sh}_k(\text{supp}(f))|$. Then $H_k$ is a concave function of $k$, and the derivative $\Delta H_k = H_{k+1} - H_k$ measures the information loss per differentiation step in the tropical sense.

**Test:** Compute $H_k$ for random sparse polynomials with supports drawn from lattice points of known polytopes (simplices, cubes, cross-polytopes, Birkhoff polytopes) up to dimension 6. Plot $H_k$ against $k$ and test concavity. Compare $\Delta H_k$ with the surface-to-volume ratio of the level-$k$ section of $P$.

**The key insight is** that the shadow operator is the discrete analogue of the Minkowski subtraction of a ball from a convex body, and entropy concavity would be the discrete analogue of the Brunn–Minkowski inequality.

**Why now?** The semigroup law (Theorem 3.5) provides the formal foundation for treating the shadow as a flow, which is the prerequisite for defining rates of change and entropy-like quantities.

**Impact:** Would create a new information-theoretic perspective on Newton polytopes, with applications to coding theory and optimization.

**Catalog References:** `Pythagorean/IteratedShadowGeometry.lean` (kthShadow_add, shadow_profile).

**Proof Strategy:** Use the semigroup law to express $H_{a+b}$ in terms of $H_a$ and $H_b$. Apply lattice-point counting estimates (Ehrhart theory) to bound shadow sizes in terms of polytope volumes.

**Domain Bridges:** Tropical geometry, information theory, convex geometry.

**Lineage:** New direction inspired by the semigroup structure.

**Ambition:** Solid extension — connects two established areas through a new invariant.

---

## Direction 3: Circuit Lower Bounds from Derivative Shadow Decay

**Conjecture:** If a polynomial $f$ of degree $d$ in $n$ variables is computed by an algebraic circuit of size $s$, then the shadow profile satisfies $|\text{Sh}_k(\text{supp}(f))| \leq s \cdot \binom{n+d-k}{n}$ for all $k$. Moreover, there exist explicit polynomials (e.g., the permanent) where the shadow profile decays much slower than any polynomial circuit output could allow.

**Test:** Compute shadow profiles for the permanent, determinant, and elementary symmetric polynomials in $n \leq 8$ variables. Compare decay rates. Identify polynomials where the shadow decay is anomalously slow relative to the circuit upper bound.

**The key insight is** that circuits can only produce polynomials with structured supports (outputs of bounded-depth composition of sparse operations), while the shadow profile of a "random" polynomial decays at the maximal rate. A separation between these rates would yield circuit lower bounds.

**Why now?** The exact shadow theorem reduces the derivative complexity of a polynomial to a purely combinatorial quantity (the shadow profile), which is much easier to bound than the algebraic quantity (the actual derivative).

**Impact:** Would provide a new approach to algebraic circuit lower bounds via support geometry.

**Catalog References:** `Pythagorean/IteratedShadowGeometry.lean` (mem_kthShadow_iff_exists_iteratedDerivative), `Bridges/Catalog/Pythagorean/SupportCompression.lean` (supportCompressedLeafCount_le_active_choose).

**Proof Strategy:** Use the shadow theorem to express derivative complexity as shadow size. Bound shadow sizes for circuit outputs using structural induction on circuit depth.

**Domain Bridges:** Algebraic complexity theory, circuit complexity, sparse polynomial identity testing.

**Lineage:** Extends the support compression results of SupportCompression.lean from quadratic to arbitrary order.

**Ambition:** Grand challenge — circuit lower bounds are a central open problem.

---

## Direction 4: Exchange-Axiom Characterization of Shadow Log-Concavity

**Conjecture:** The discrete exchange property (Definition 2.4) is *necessary and sufficient* for shadow log-concavity among homogeneous support sets. That is, a homogeneous support $S$ has log-concave shadow profile if and only if $S$ is a discrete exchange family.

**Test:** Systematically enumerate all subsets of $\{0,1\}^n$ of a fixed cardinality (representing multiaffine supports) for $n \leq 7$. For each, check both the exchange property and shadow log-concavity. Report any discrepancies.

**The key insight is** that the exchange property is the finite-set analogue of M-convexity, and M-convex sets are precisely the supports of matroid-theoretic objects. If the exchange property characterizes log-concavity, it would give a clean combinatorial criterion for when the shadow profile is well-behaved.

**Why now?** The computational experiments in this work test the conjecture in one direction (exchange ⟹ log-concavity) but not the converse. A systematic enumeration for small $n$ would resolve the question computationally for low dimensions.

**Impact:** Would provide the first purely combinatorial characterization of when shadow profiles are log-concave, without reference to polynomial coefficients.

**Catalog References:** `Pythagorean/IteratedShadowGeometry.lean` (IsDiscreteExchangeFamily, kthShadow), `Bridges/Catalog/Pythagorean/SupportCompression.lean` (nonzeroDerivativeLeafSet_eq_indep).

**Proof Strategy:** For necessity, construct explicit non-exchange supports with non-log-concave profiles. For sufficiency, use the exchange axiom to construct injection maps between shadow levels, proving the log-concavity inequality.

**Domain Bridges:** Matroid theory, discrete convex analysis, combinatorial optimization.

**Lineage:** Directly extends the exchange family definition and computational experiments from this work.

**Ambition:** Solid extension — would close a natural question opened by the conjecture.

---

## Direction 5: Shadow Processes for Partition Function Observables

**Conjecture:** For partition functions $Z = \sum_\sigma e^{-\beta H(\sigma)}$ written as multivariate polynomials in fugacity variables, the shadow profile $|\text{Sh}_k(\text{supp}(Z))|$ measures the number of observable occupation states remaining after $k$-th order differentiation (i.e., $k$-point correlation measurements). The shadow log-concavity conjecture then predicts a thermodynamic inequality: the information extractable from correlation functions decays in a controlled, log-concave fashion.

**Test:** Compute shadow profiles for the partition functions of: (a) the Ising model on small lattices ($n \leq 8$ spins), (b) the hard-core model on bipartite graphs, (c) the monomer-dimer model. Verify log-concavity of shadow profiles and compare with known phase-transition behavior.

**The key insight is** that differentiation of a partition function with respect to fugacity variables extracts correlation functions, and the shadow profile predicts which correlations are nonzero — providing a combinatorial skeleton for statistical mechanical observables.

**Why now?** The formal connection between polynomial differentiation and statistical mechanics is well established (Lee–Yang theory, Heilmann–Lieb theory), but the support-level perspective via shadows is new. The semigroup law provides the mathematical infrastructure for tracking multi-point correlations.

**Impact:** Would establish a bridge between discrete geometry and statistical physics, potentially providing new tools for proving correlation inequalities.

**Catalog References:** `Pythagorean/IteratedShadowGeometry.lean` (all main theorems).

**Proof Strategy:** Express partition function supports as matroid-like objects (e.g., for the hard-core model, the support is the set of independent sets). Apply the shadow theory to deduce properties of correlation functions.

**Domain Bridges:** Statistical physics, partition functions, correlation inequalities, lattice models.

**Lineage:** New interdisciplinary application of the shadow framework.

**Ambition:** Solid extension with potential for high impact in physics.
