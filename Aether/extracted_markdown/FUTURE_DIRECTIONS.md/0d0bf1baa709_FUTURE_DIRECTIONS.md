# Future Directions: M-Convexity Closure Under Differentiation

## Synthesis

The closure of M-convex support under partial differentiation — formally proved via the identification of differentiation with matroid contraction — opens a systematic bridge between polynomial calculus and discrete convex analysis. The five directions below exploit this bridge in increasing levels of ambition: the first two extend the algebraic-combinatorial framework directly, while the latter three reach toward connections with Hodge theory, tropical geometry, and statistical physics. All directions share the structural motif that *analytic operations on generating polynomials correspond to combinatorial operations on matroidal supports*, and each direction tests a specific prediction of this correspondence.

---

## Direction 1: Deletion-Contraction Duality for Polynomial Supports

**Conjecture:** Define *support deletion* as D_i(S) := {m ∈ S : m_i = 0} (the restriction to vectors with zero i-th coordinate). If S satisfies the exchange property, then D_i(S) satisfies the exchange property, and there is a formal deletion-contraction recurrence for a support-level Tutte polynomial that encodes the contraction hierarchy.

**Test:** Formalize support deletion in Lean. Check the exchange property computationally for all deletions of M-convex subsets of the degree-≤6 simplex on ≤5 variables. Formalize the Tutte-type recurrence and verify it for uniform matroids and graphic matroids.

**Impact:** This would complete the matroid-theoretic toolkit at the support level, enabling inductive proofs via deletion-contraction for any polynomial invariant that factors through the support. Combined with the contraction theorem, it would give a full minor theory for M-convex polynomial supports.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (contraction theorem), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (exchange definition).

**Proof Strategy:** Direct case analysis, analogous to the contraction proof. For deletion, the key is that removing vectors with m_i = 0 preserves exchange because the exchange witnesses either both have m_i = 0 (and hence remain) or the situation reduces to a previously handled case.

**Domain Bridges:** Matroid theory ↔ algebraic combinatorics ↔ knot theory (via Tutte–Jones connections).

**Lineage:** Extends the contraction theorem to a full minor framework.

**Ambition:** Solid extension — the conjecture is very likely true and fills an obvious gap.

**The key insight is** that deletion corresponds to evaluation (setting xᵢ = 0) while contraction corresponds to differentiation, and both preserve the matroidal skeleton.

**Why now?** The contraction half is formally proved. The deletion half should follow by similar techniques, and together they would complete the combinatorial dictionary.

---

## Direction 2: Valuated M-Convexity and Coefficient Transport

**Conjecture:** Define a *valuated exchange property* that tracks not just support membership but coefficient values: for α, β ∈ supp(p) with αᵢ > βᵢ, the exchange witness j satisfies a quantitative bound relating the coefficients of the four involved monomials. This valuated exchange should be preserved under differentiation (with appropriate rescaling).

**Test:** Formalize a valuated exchange predicate. Test it on the basis-generating polynomials of uniform matroids with explicit coefficient weights. Prove or disprove preservation for the simplest nontrivial case (n=3, d=2).

**Impact:** This would bridge from combinatorial support (boolean membership) to analytic coefficient behavior (quantitative inequalities), connecting the support-level theorem to log-concavity and ultra-log-concavity of coefficients along rays.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (coeff_pderiv_eq), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Lorentzian signature).

**Proof Strategy:** Use the coefficient formula [∂p/∂xᵢ]_m = (mᵢ+1)·[p]_{m+eᵢ} to transport coefficient inequalities. The (mᵢ+1) factor creates a predictable rescaling that should preserve the valuated exchange up to this factor.

**Domain Bridges:** Discrete convex analysis (Murota's valuated matroids) ↔ algebraic geometry (intersection theory) ↔ combinatorial optimization (submodular function minimization).

**Lineage:** Deepens the contraction theorem from topology (support) to geometry (valuated support).

**Ambition:** Solid extension — the coefficient formula makes the rescaling explicit.

**The key insight is** that the coefficient of the derivative at m is a simple multiplicative transform of the coefficient at m+eᵢ, so quantitative exchange bounds should transport with controlled distortion.

**Why now?** The coefficient formula is formally proved, and the qualitative (support-level) result is established. The quantitative upgrade is the natural next step.

---

## Direction 3: Hodge-Theoretic Interpretation of Exchange Depth

**Conjecture:** The *exchange depth* of a polynomial p — the maximum total order of mixed differentiation that preserves nonempty M-convex support — equals the minimum over all coordinates of min_{m ∈ supp(p)} m_i, which is the "inner radius" of the Newton polytope. Furthermore, this quantity has a Hodge-theoretic interpretation as the dimension of a certain positive cone in the cohomology of the associated toric variety.

**Test:** Compute exchange depth for all homogeneous supports of degree ≤ 8 on ≤ 4 variables. Compare with the inner radius. Formalize the inner radius computation in Lean and prove the equality for the full simplex (where both equal d/n rounded down).

**Impact:** This would connect the combinatorial derivative hierarchy to the geometry of Newton polytopes and the algebra of toric varieties, opening a route to machine-verified Hodge-theoretic inequalities.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (exchangeWidth, mixedPDeriv), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Hessian signature).

**Proof Strategy:** For the full simplex, the inner radius is ⌊d/n⌋ and the exchange depth is exactly d (every contraction reduces degree by 1 until the support is a single point). For general M-convex sets, the conjecture may need refinement. Start with a computational census and refine the conjecture based on data.

**Domain Bridges:** Algebraic combinatorics ↔ algebraic geometry (toric varieties) ↔ Hodge theory (mixed Hodge structures).

**Lineage:** Extends exchange width monotonicity to a structural invariant with geometric meaning.

**Ambition:** Grand challenge — the Hodge interpretation is speculative and would require significant new formal infrastructure.

**The key insight is** that exchange depth measures the "thickness" of the M-convex set in a direction that corresponds to the depth of the derivative tower, and this thickness should be computable from the Newton polytope alone.

**Why now?** The exchange width machinery is formalized and the monotonicity theorem is proved. The geometric interpretation is the natural question to ask next.

---

## Direction 4: Tropical Contraction and Support Truncation

**Conjecture:** Under tropicalization (replacing + with max and × with +), the contraction operation on polynomial supports corresponds to a *tropical truncation* of the Newton polytope: the operation that removes a face of the polytope and re-indexes the remaining lattice points. This tropical truncation preserves the "tropical M-convexity" (the tropical analog of the exchange property).

**Test:** Implement tropical polynomial operations in Python. Compute tropical supports for degree-≤5 polynomials in ≤4 variables. Verify that tropical contraction = support contraction for these cases. Formalize the tropical exchange property and prove it coincides with the classical one for integer-valued tropical polynomials.

**Impact:** This would connect the derivative/contraction theorem to tropical geometry, the fastest-growing interface between combinatorics and algebraic geometry. It would position the M-convexity closure result as a shadow of a deeper tropical-geometric principle.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (SupportContraction), `Catalog/Tropical/` (tropical geometry files if present).

**Proof Strategy:** Establish a formal tropicalization functor that sends MvPolynomial ℝ to tropical polynomials, and show it commutes with contraction. The M-convexity preservation would then follow from the classical result.

**Domain Bridges:** Discrete convex analysis ↔ tropical geometry ↔ algebraic geometry (Berkovich spaces, non-Archimedean geometry).

**Lineage:** Extends the contraction theorem to the tropical world.

**Ambition:** Grand challenge — tropical formalization in Lean is still nascent.

**The key insight is** that support sets are Newton polytopes, contraction acts on lattice points, and tropical geometry provides the natural language for operations on Newton polytopes.

**Why now?** Tropical geometry has reached maturity as a mathematical theory, and its connections to M-convexity via valuated matroids are well-established informally. Formalization would be pioneering.

---

## Direction 5: Negative Dependence Preservation Under Conditioning

**Conjecture:** If a probability distribution μ on {0,1}ⁿ is *strongly Rayleigh* (its generating polynomial is stable), then for any element i, the conditional distribution μ(·|i ∈ S) is again strongly Rayleigh. At the support level, this reduces to our contraction theorem. At the coefficient level, it requires preserving the stability (zero-free half-plane) property, which should follow from the Borcea-Brändén theory.

**Test:** For determinantal point processes (DPPs) with kernel matrices of rank ≤ 5 on ≤ 8 elements, compute the generating polynomial, verify stability, differentiate, and verify stability again. Formalize the connection between conditioning and differentiation for DPPs.

**Impact:** This would provide a formal bridge from algebraic combinatorics to statistical physics and machine learning (DPPs are widely used for diversity-promoting sampling). It would certify that the negative dependence properties that make DPPs useful survive conditioning — a fact used informally in every DPP application.

**Catalog References:** `Pythagorean/MConvexDifferentiation.lean` (pderiv closure), `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` (Lorentzian/stable connection).

**Proof Strategy:** Use the Borcea-Brändén characterization: a polynomial is stable iff it has nonneg coefficients and its support satisfies exchange (for homogeneous polynomials, this is equivalent to Lorentzianity). Differentiation preserves nonnegativity (proved) and exchange (proved), hence stability.

**Domain Bridges:** Combinatorics (matroid theory) ↔ probability (DPPs, negative dependence) ↔ statistical physics (partition functions) ↔ machine learning (diversity sampling).

**Lineage:** Applies the contraction theorem to the most impactful application domain.

**Ambition:** Solid extension with grand-challenge framing — the individual steps are provable, but the full formalization of the stable polynomial ↔ negative dependence connection would be a major formal verification milestone.

**The key insight is** that differentiation = conditioning at the algebraic level, and our contraction theorem provides the combinatorial layer of the preservation argument. The analytic layer (coefficient positivity) is already proved.

**Why now?** DPPs are increasingly important in machine learning, and practitioners rely on negative dependence preservation without formal guarantees. A machine-checked proof would provide certifiable guarantees for algorithmic applications.
