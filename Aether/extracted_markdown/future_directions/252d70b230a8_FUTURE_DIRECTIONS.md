# Future Directions: Arithmetic Persistence Theory

## Synthesis

The persistence zeta function multiplicativity results established in this cycle—coprime-support Euler product factorization, exact overlap correction, and obstruction localization—form the foundation of **arithmetic persistence theory**: a new interface between analytic number theory and topological data analysis. The core insight is that persistence invariants of filtered finite abelian groups decompose primewise, and this decomposition admits Euler product structure.

The directions below exploit this foundation in two ways: (1) extending the Euler product philosophy deeper into persistence theory (Directions 1-2, the grand challenges), and (2) building concrete computational and structural tools on the established theorems (Directions 3-5).

All directions are tied together by the **local-global principle**: global persistence invariants are controlled by local prime data, and the failure of exact factorization is localized at "bad" (shared) primes. This principle, once established for zeta functions, should propagate to L-functions, logarithmic derivatives, and asymptotic growth rates.

---

## Direction 1: Persistence L-Functions and Functional Equations

**Conjecture:** For any Dirichlet character χ modulo N, the *persistence L-function*
$$L(D, \chi, s) = \prod_{p \in S} \left(1 + \frac{\chi(p) \cdot \ell_p(D)}{p^s}\right)$$
satisfies a multiplicativity theorem under coprime support analogous to the persistence zeta, and admits a functional equation relating L(D, χ, s) to L(D, χ̄, k-s) for an appropriate weight k determined by the total barcode mass.

**Test:** Implement the persistence L-function computationally for all Dirichlet characters mod N ≤ 12 and all cyclic groups Z/nZ for n ≤ 120. Verify multiplicativity under disjoint support. Search for functional equation patterns by computing L(D, χ, s) / L(D, χ̄, k-s) for various k and testing whether the ratio stabilizes.

**Impact:** If a functional equation exists, it would provide the first bridge between persistence theory and automorphic forms, opening connections to the Langlands program.

**Catalog References:** `Catalog/Pythagorean/PersistenceZetaMultiplicativity.lean` (persistenceZeta_mul_of_coprime_support), `Catalog/Pythagorean/AdelicPersistentHomology.lean` (persistence_CRT_decomposition).

**Proof Strategy:** Define persistence L-functions in Lean as products over Finset with character values. The multiplicativity proof should follow the same Finset.prod_union argument. The functional equation requires new ideas—likely connecting barcode duality to character conjugation.

**Domain Bridges:** Analytic number theory → TDA, automorphic forms → persistence theory.

**Lineage:** Direct extension of persistence zeta multiplicativity (this cycle).

**Ambition:** Grand challenge — paradigm-shifting if functional equation is found.

---

## Direction 2: Thermodynamic Phase Transitions in Persistence Zeta

**Conjecture:** The persistence zeta function Z(D, s), viewed as a partition function with s as inverse temperature, exhibits a phase transition at a critical value s_c determined by the largest barcode length and smallest prime in the support. Specifically, define the "persistence free energy" f(D, s) = log Z(D, s). Then df/ds has a discontinuity or divergence at s_c = log(max ℓ_p) / log(min p).

**Test:** For families of arithmetic persistence data with growing barcode lengths (e.g., Z/(p^k)Z for increasing k), compute f(D, s) and df/ds numerically for s ∈ [0.1, 10] at fine resolution. Plot the results and identify non-analytic behavior.

**Impact:** Would establish persistence zeta as a genuine statistical-mechanical object, enabling the import of renormalization group techniques and universality results from physics into TDA.

**Catalog References:** `Catalog/Pythagorean/PersistenceZetaMultiplicativity.lean` (persistenceZeta_pos, persistenceZetaFactor_pos).

**Proof Strategy:** For finite products, the "phase transition" would be a crossover rather than a true singularity. To formalize, define a sequence of persistence data with growing support and show that the normalized free energy converges to a function with a kink. This requires Lean formalization of limits of finite products.

**Domain Bridges:** Statistical physics → TDA, partition functions → barcode invariants.

**Lineage:** Builds on the positivity and nonvanishing theorems established in this cycle.

**Ambition:** Grand challenge — connects physics and TDA in a testable way.

---

## Direction 3: Correction Factor Asymptotics and Decay Rate

**Conjecture:** For fixed arithmetic persistence data D₁, D₂ with shared support T = S₁ ∩ S₂, the correction factor satisfies
$$|C(D_1, D_2, s) - 1| \leq \frac{M}{p_{\min}^s}$$
where p_min is the smallest prime in T and M = ∑_{p ∈ T} ℓ₁(p)·ℓ₂(p).

More precisely, the leading term of C(s) - 1 as s → ∞ is
$$C(s) - 1 \sim -\frac{\ell_1(p_{\min}) \cdot \ell_2(p_{\min})}{p_{\min}^{2s}} + O(p_{\min}^{-3s}).$$

**Test:** Compute C(s) for all pairs of cyclic groups Z/nZ, n ≤ 60, for s = 1, ..., 20. Verify the upper bound and leading-term asymptotics. Check whether the bound is tight.

**Impact:** Provides quantitative control over the deviation from multiplicativity, enabling error bounds for approximate computations.

**Catalog References:** `Catalog/Pythagorean/PersistenceZetaMultiplicativity.lean` (overlapCorrection, overlapCorrection_eq_one_of_disjoint, persistenceZetaFactor_pos).

**Proof Strategy:** Expand each term of the correction product as 1 - ℓ₁ℓ₂/(p^s + ℓ₁)(p^s + ℓ₂). The product of (1 - εᵢ) for small εᵢ is approximately 1 - Σεᵢ. Formalize this using Finset.prod bounds and geometric series estimates.

**Domain Bridges:** Analytic number theory (asymptotic analysis) → TDA (approximation theory).

**Lineage:** Direct extension of the correction factor theorem.

**Ambition:** Solid extension — highly achievable, high utility.

---

## Direction 4: Multiplicativity for Short Exact Sequences

**Conjecture:** The persistence zeta multiplicativity extends from direct products to short exact sequences. Specifically, if 0 → G₁ → G → G₂ → 0 is a short exact sequence of filtered finite abelian groups with coprime orders |G₁| and |G₂|, then
$$Z(G, s) = Z(G_1, s) \cdot Z(G_2, s).$$

When orders are not coprime, an exact correction factor should again be expressible as a product over shared primes.

**Test:** Construct explicit short exact sequences of filtered cyclic groups (e.g., 0 → Z/3Z → Z/6Z → Z/2Z → 0) and verify the formula. Test with non-split extensions.

**Impact:** Extends the theory from products to the full category of filtered abelian groups, making persistence zeta a categorical invariant.

**Catalog References:** `Catalog/Pythagorean/AdelicPersistentHomology.lean` (persistence_CRT_decomposition, CRT_persistence_functorial), `Catalog/Pythagorean/PersistenceZetaMultiplicativity.lean` (persistenceZeta_mul_of_coprime_support).

**Proof Strategy:** For split extensions with coprime orders, this reduces to Theorem A. For non-split extensions, the barcode structure depends on the extension class. Use the classification of extensions of Z/mZ by Z/nZ and compute local barcode lengths explicitly.

**Domain Bridges:** Homological algebra → TDA, extension theory → persistence.

**Lineage:** Direct generalization of coprime-support multiplicativity.

**Ambition:** Solid extension — natural next step.

---

## Direction 5: Persistence von Mangoldt Function and Prime Counting

**Conjecture:** Define the *persistence von Mangoldt function* via the logarithmic derivative:
$$-\frac{Z'(D, s)}{Z(D, s)} = \sum_{p \in S} \frac{\ell_p \log p \cdot p^{-s}}{1 + \ell_p \cdot p^{-s}} = \sum_{n=1}^{\infty} \Lambda_D(n) \cdot n^{-s}$$
where Λ_D(n) is nonzero only at prime powers in the support. Then:
(a) Λ_D is supported on prime powers p^k for p ∈ S.
(b) ∑_{n ≤ x} Λ_D(n) ~ C · x for a constant C depending on S and ℓ.
(c) The multiplicativity of Z implies additivity of Λ under coprime products.

**Test:** Compute Λ_D(n) for n ≤ 1000 for Z/60Z (support {2, 3, 5}) and verify support and growth predictions. Check additivity: Λ_{D₁·D₂} = Λ_{D₁} + Λ_{D₂} when supports are disjoint.

**Impact:** Creates a persistence-theoretic analogue of the prime number theorem, the most central result in analytic number theory.

**Catalog References:** `Catalog/Pythagorean/PersistenceZetaMultiplicativity.lean` (persistenceZeta, persistenceZeta_mul_of_coprime_support).

**Proof Strategy:** The logarithmic derivative of a finite product is a finite sum. The support claim follows from the structure of each summand. The asymptotic claim requires partial summation (Abel summation) applied to the Dirichlet series. The additivity follows from log(Z₁ · Z₂) = log Z₁ + log Z₂ under multiplicativity.

**Domain Bridges:** Analytic number theory (prime counting) → TDA (barcode counting).

**Lineage:** Builds on all four main theorems of this cycle.

**Ambition:** Solid extension with grand-challenge potential — if the asymptotic analysis yields a "persistence prime number theorem."
