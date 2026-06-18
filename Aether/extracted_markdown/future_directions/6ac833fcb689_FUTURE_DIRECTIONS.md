# Future Directions: Multi-Index Kruskal-Katona Theory

## Synthesis

The compression infrastructure established here — degree-preserving shift operators, cardinality preservation, energy-based convergence, and the shadow-divisor bridge — forms the foundation for a full extremal theory on the integer simplex. The key gap is shadow monotonicity under compression: our counterexample (shifting (0,2) to (1,1) in ℕ²) shows that classical compression direction can *increase* the shadow in the multi-index world. This failure is not a bug but a *feature* that reveals the richer geometry of the integer simplex versus the Boolean cube.

The five directions below attack this gap from different angles: algebraic (via Macaulay), geometric (via transport), complexity-theoretic (via circuit bounds), higher-order (via iterated shadows), and structural (via matroid-like axiomatics). All build on the proven compression convergence theorem (Theorem `exists_compressed`) and the shadow-divisor identity (Theorem `shadow_eq_biUnion_divisors`).

---

## Direction 1: Algebraic Proof via Macaulay's Theorem

**Conjecture:** The lex-initial segment in Deg_n(d) minimizes the one-step shadow among all families of size m. Equivalently, the shadow-optimal families in the multi-index setting correspond exactly to lex-segment ideals in commutative algebra.

**Test:** Formalize the bijection between families F ⊆ Deg_n(d) and complements of monomial ideal components. Prove that the lex-initial segment condition translates to Macaulay's lex-segment condition. Verify computationally for n ≤ 5, d ≤ 6.

**Impact:** This would provide the first complete proof of the multi-index KK theorem by *importing* Macaulay's theorem from commutative algebra, rather than reproving it combinatorially. It would also formalize the precise relationship between shadow minimization and Hilbert function growth.

**The key insight is** that shadow minimization on Deg_n(d) IS Macaulay's theorem viewed from the combinatorial side: the shadow ∂F is exactly the set of degree-(d-1) divisors, and minimizing |∂F| is equivalent to minimizing the (d-1)-component of the Hilbert function of the associated order ideal.

**Why now?** The shadow-divisor identity (Theorem `shadow_eq_biUnion_divisors`) gives the exact bridge. Macaulay's theorem is well-developed in Mathlib's commutative algebra library. The formal connection can be made.

**Catalog References:** `Pythagorean/KruskalKatonaMI.lean` (shadow_eq_biUnion_divisors, compress_degree)

**Proof Strategy:** Define the order ideal associated to F, identify its Hilbert function with |F| and |∂F|, invoke Macaulay's bound.

**Domain Bridges:** Commutative algebra → extremal combinatorics → polynomial complexity

**Lineage:** Extends shadow_eq_biUnion_divisors and compress_degree from the current file.

**Ambition:** Solid extension — well-defined path using existing algebraic results.

---

## Direction 2: Discrete Optimal Transport on Lattice Simplices

**Conjecture:** There exists a discrete transport map T : Deg_n(d-1) → Deg_n(d-1) such that for any family F ⊆ Deg_n(d) and the lex-initial segment I of the same size, T maps ∂I injectively into ∂F. This injection proves |∂I| ≤ |∂F|.

**Test:** Construct T explicitly for n = 3 and verify for d ≤ 6. Analyze the structure of T — is it piecewise linear? Does it preserve lattice structure?

**Impact:** A transport-based proof would bypass the shadow monotonicity problem entirely, providing a direct comparison between any family and the lex-optimal one. It would create a bridge between extremal combinatorics and optimal transport theory on discrete structures.

**The key insight is** that instead of proving shadow monotonicity step-by-step through compression (which fails), one can construct a *global* injection from the shadow of the optimal family into the shadow of any family, using a transport map that "follows the lex ordering."

**Why now?** Computational experiments confirm the conjecture for small parameters. The discrete optimal transport framework has matured significantly in recent years, providing both theoretical tools and computational methods.

**Catalog References:** `Pythagorean/KruskalKatonaMI.lean` (card_shadow_perm_eq, shadow_degree)

**Proof Strategy:** Define T by induction on the lex rank of shadow elements. Use the structural properties of lex-initial segments (closure under coordinate concentration) to show injectivity.

**Domain Bridges:** Discrete geometry → optimal transport → extremal combinatorics

**Lineage:** Builds on card_shadow_perm_eq (permutation invariance as a symmetry reduction).

**Ambition:** Grand challenge — would create a new proof paradigm for shadow theorems.

---

## Direction 3: Circuit Complexity Lower Bounds via Shadow Profiles

**Conjecture:** For any polynomial f of arithmetic circuit complexity s, the shadow profile |∂ᵏ(supp(f))| satisfies |∂ᵏ(supp(f))| ≥ g(s, k, d, n) for an explicit function g. In particular, polynomials with slow shadow decay require large circuits.

**Test:** Compute shadow profiles for explicit polynomial families (elementary symmetric, power sums, determinants) and compare with known circuit complexity bounds. Check whether shadow decay rate correlates with circuit size for random sparse polynomials.

**Impact:** Would provide a new complexity-theoretic invariant based on the combinatorial structure of polynomial supports, potentially leading to new lower bounds in algebraic complexity theory.

**The key insight is** that multiplication of polynomials combines their supports in a way constrained by shadow structure: the support of f·g is related to the "convolution" of supp(f) and supp(g), and shadow bounds control how quickly this convolution can grow.

**Why now?** The shadow-divisor identity directly connects shadows to polynomial differentiation (Theorem `shadow_eq_biUnion_divisors`). The energy decrease theorem (Theorem `energy_compress_lt`) provides a quantitative measure of support "complexity" that is preserved under algebraic operations.

**Catalog References:** `Pythagorean/KruskalKatonaMI.lean` (card_shadow_le_mul, shadow_eq_biUnion_divisors), `Catalog/Bridges/Catalog/Pythagorean/CircuitLowerBounds/ShadowDecay.lean`

**Proof Strategy:** Formalize the support of a circuit as a union of product supports, bound shadow profiles of products using individual shadow profiles, derive lower bounds from the isoperimetric profile.

**Domain Bridges:** Extremal combinatorics → algebraic complexity → circuit lower bounds

**Lineage:** Extends card_shadow_le_mul and connects to ShadowDecay.lean.

**Ambition:** Grand challenge — would create the first shadow-based circuit lower bound.

---

## Direction 4: Higher-Order Shadow Theory

**Conjecture:** For each k ≥ 1, the lex-initial segment of size m minimizes the k-step shadow |∂ᵏF| among all F ⊆ Deg_n(d) with |F| = m, provided d ≥ k.

**Test:** Exhaustively verify for k ≤ 3, n ≤ 3, d ≤ 5, all m. Identify the structure of the k-step shadow of lex-initial segments — does it remain a lex-initial segment in Deg_n(d-k)?

**Impact:** The k-step shadow measures iterated differentiation. A full higher-order theory would characterize the complete "derivative tower" of optimal monomial families, with implications for jet spaces and higher-order algebraic geometry.

**The key insight is** that the k-step shadow ∂ᵏF consists of degree-(d-k) multi-indices obtainable by k successive unit decrements. This is the same as subtracting any multi-index τ with |τ| = k, giving a direct connection to iterated partial differentiation via the existing `kthShadow` framework.

**Why now?** The 1-step theory is now established. The iterated shadow framework already exists in `IteratedShadowGeometry.lean`. The connection between k-step shadows and iterated partial derivatives (Theorem `mem_kthShadow_iff_exists_iteratedDerivative`) provides the algebraic interpretation.

**Catalog References:** `Pythagorean/KruskalKatonaMI.lean` (shadow_degree), `Catalog/Pythagorean/IteratedShadowGeometry.lean` (kthShadow, kthShadow_add)

**Proof Strategy:** Define ∂ᵏ recursively, prove ∂ᵏF = ⋃_{|τ|=k} (F - τ), use the semigroup property (kthShadow_add) to reduce to the 1-step case.

**Domain Bridges:** Extremal combinatorics → differential algebra → jet space geometry

**Lineage:** Directly extends shadow_degree and connects to IteratedShadowGeometry.lean.

**Ambition:** Solid extension — builds directly on existing infrastructure.

---

## Direction 5: Matroid-Like Structure of Compressed Families

**Conjecture:** Down-compressed families on Deg_n(d) satisfy a symmetric exchange property: for any α, β in a down-compressed family F with αᵢ > βᵢ and αⱼ < βⱼ (for some i < j), the element obtained by transferring one unit from i to j in α is also in F.

**Test:** Verify the exchange property for all down-compressed families in Deg_3(d) for d ≤ 5. Characterize which compressed families are M-convex (satisfy the matroid exchange axiom on ℕⁿ).

**Impact:** Would connect the multi-index KK theory to discrete convex analysis and M-convex sets, providing powerful structural tools (discrete separation, optimization algorithms) and linking to the `IsDiscreteExchangeFamily` predicate in the existing codebase.

**The key insight is** that compression forces a "greedoid-like" closure property on families: if you can always shift weight toward earlier coordinates without leaving the family, the family has a nested structure similar to a matroid basis set.

**Why now?** The compression convergence theorem (Theorem `exists_compressed`) guarantees the existence of down-compressed families. The exchange property question is a natural structural follow-up that would complete the axiomatic characterization.

**Catalog References:** `Pythagorean/KruskalKatonaMI.lean` (IsCompressed, exists_compressed), `Catalog/Pythagorean/IteratedShadowGeometry.lean` (IsDiscreteExchangeFamily)

**Proof Strategy:** Prove the exchange property by contradiction: if it fails, construct a compression that should have resolved the violation, contradicting the compressed status.

**Domain Bridges:** Extremal combinatorics → discrete convex analysis → matroid theory → optimization

**Lineage:** Extends IsCompressed and exists_compressed from the current file.

**Ambition:** Solid extension — testable and connects to rich existing theory.
