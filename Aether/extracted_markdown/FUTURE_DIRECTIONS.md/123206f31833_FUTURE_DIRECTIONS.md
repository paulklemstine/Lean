# Future Directions: Polynomial Width Theory for Certificate-Family Posets

## Synthesis

The polynomial width theorem established in this cycle opens a bridge between well-quasi-ordering theory and quantitative combinatorics. The profile method reduces antichain width analysis to lattice-point counting in bounded boxes, converting exponential finiteness guarantees into polynomial complexity bounds. The five directions below extend this bridge in complementary ways: Direction 1 sharpens the polynomial exponent using extremal set theory; Direction 2 attacks the profile-collision barrier that limits the current theorem's scope; Direction 3 imports generating-function technology for precise asymptotics; Direction 4 builds computational infrastructure for domain-specific applications; Direction 5 poses the grand challenge of a universal polynomial width theorem.

All directions build on the formally verified results in `Pythagorean/PolynomialWidth.lean` and the catalog infrastructure in `Pythagorean/CertificatePosetWQO.lean`.

---

## Direction 1: Sharp Exponent via Sperner-Type Bounds

**Conjecture:** For fixed certificate size bound *t*, the maximum profile-injective antichain in the bounded certificate family poset on Fin n has size Θ(n^{e(t)}) where e(t) = (t+1)² - 1 (the profile dimension minus one).

**Test:** Compute exact maximum profile-injective antichain sizes for n = 3, 4, 5, 6 and t = 1, 2, 3. Fit log(width) vs log(n) to extract the empirical exponent. Compare against (t+1)² - 1 and the crude bound 2t(t+1)².

**Impact:** A sharp exponent would convert the polynomial width theorem from a qualitative existence statement into a precise complexity classification. The exponent (t+1)² - 1 is predicted by analogy with the sharp Sperner theorem for products of chains, where the maximum antichain has size O(N^{m-1}) in [0,N]^m.

**Catalog References:**
- `Pythagorean/PolynomialWidth.lean`: `box_width_polynomial`, `polynomial_profile_width_bound`
- `Pythagorean/CertificatePosetWQO.lean`: `antichain_card_bound`

**Proof Strategy:** Prove the normalized matching property for the profile box under the sum-of-coordinates grading. Use Engel's theorem (the product of chains has the NMP) to show the maximum antichain equals the maximum rank-level size. Formalize the coefficient bound for (1+x+⋯+x^N)^m using generating functions.

**Domain Bridges:** Extremal combinatorics (Sperner theory, LYM inequality), enumerative combinatorics (generating function coefficients), statistical mechanics (density of states at entropy maximum)

**Lineage:** Extends `box_width_polynomial` from crude (N+1)^m to sharp O(N^{m-1}) bound.

**Ambition:** ★★★☆☆ (Moderate — requires formalizing the NMP, which is well-understood but infrastructure-heavy)

---

## Direction 2: Profile Collision Structure Theorem

**Conjecture:** For fixed t, the maximum number of pairwise incomparable bounded certificate families on Fin n sharing the same profile is bounded by a polynomial in n.

**Test:** For n = 2, 3, 4 and t = 1, 2, enumerate all bounded certificate families, compute profiles, and for each profile class, find the maximum antichain among families with that profile. Plot the maximum collision-antichain size vs n.

**Impact:** If true, this eliminates the profile-injectivity hypothesis from the main theorem, yielding an unconditional polynomial width bound. The combined bound would be poly(n) (profile-injective width) × poly(n) (collision width) = poly(n).

**Catalog References:**
- `Pythagorean/PolynomialWidth.lean`: `polynomial_profile_width_bound`, `achievableProfiles_upper_bound`
- `Pythagorean/CertificatePosetWQO.lean`: `profile_le_of_certificateFamilyLE`

**Proof Strategy:** Within a fixed profile class, families differ in which specific certificates they contain. Encode this as a collection of subsets of the universe with fixed size in each block. Apply the Bollobás set-pairs inequality or the Sauer-Shelah lemma to bound incomparable collections.

**Domain Bridges:** Extremal set theory (Bollobás lemma, Sauer-Shelah), VC dimension theory, model theory (types and independence)

**Lineage:** Directly extends `polynomial_profile_width_bound` by removing the injectivity hypothesis.

**Ambition:** ★★★★☆ (Hard — requires new structural insight about profile-collision antichains)

---

## Direction 3: Generating-Function Asymptotics for Profile Width

**Conjecture:** The maximum antichain size in the profile box is asymptotic to C(t) · n^{(t+1)²-1} / √n where C(t) is a computable constant, matching the local limit theorem prediction for the coefficient of (1+x+⋯+x^{n^{2t}})^{(t+1)²}.

**Test:** Compute exact maximum rank-level sizes for small profile dimensions and compare against the local limit theorem prediction (N+1)^m · (2π m N (N+2)/12)^{-1/2} evaluated at the central rank.

**Impact:** Provides precise asymptotics instead of polynomial order-of-magnitude bounds. The √n correction factor is scientifically interesting — it connects antichain width to the central limit theorem applied to lattice paths.

**Catalog References:**
- `Pythagorean/PolynomialWidth.lean`: `rankLevel`, `max_rank_bound`, `box_width_polynomial`

**Proof Strategy:** Express the rank-level size as a contour integral of (1+x+⋯+x^N)^m / x^{r+1}. Apply the saddle-point method to extract the leading asymptotic. Formalize the local limit theorem for integer-valued random variables.

**Domain Bridges:** Analytic combinatorics (generating functions, saddle-point method), probability theory (local CLT), statistical mechanics (partition function, density of states)

**Lineage:** Refines `box_width_polynomial` from O(N^m) to Θ(N^{m-1}/√N).

**Ambition:** ★★★★★ (Grand challenge — formalizing analytic combinatorics in Lean is largely uncharted)

---

## Direction 4: Domain-Specific Profile Analysis for Pythagorean Certificates

**Conjecture:** For the specific certificate families arising from Pythagorean triple obstructions, the profile collision rate is bounded by O(1) (constant number of families per profile), yielding an unconditional polynomial width bound.

**Test:** Implement the Pythagorean certificate framework using the catalog's sandwich definitions. Enumerate certificates for small cases (n ≤ 10) and measure empirical collision rates. Compare profile-injective antichain sizes against the polynomial bound.

**Impact:** Converts the abstract polynomial width theorem into a concrete algorithmic tool for Pythagorean obstruction search. If collision rates are empirically low, this validates the profile method for the motivating application.

**Catalog References:**
- `Pythagorean/PolynomialWidth.lean`: all main theorems
- `Pythagorean/CertificatePosetWQO.lean`: all definitions
- `Pythagorean/SandwichDefs.lean`: `CertifiedSandwichFamily`, `SandwichCompleteUpTo`

**Proof Strategy:** Analyze the specific structure of Pythagorean certificates — monotonicity of the coloring property, constraints from the triple structure. Show that the triple structure forces certificates in the same profile class to be highly correlated, limiting incomparability.

**Domain Bridges:** Number theory (Pythagorean triples), Ramsey theory (coloring obstructions), SAT solving (certificate extraction)

**Lineage:** Applies `polynomial_profile_width_bound` and `achievableProfiles_upper_bound` to the motivating domain.

**Ambition:** ★★☆☆☆ (Moderate — primarily computational, with focused theoretical analysis)

---

## Direction 5: Universal Polynomial Width Conjecture

**Conjecture (Grand Challenge):** For every fixed certificate size bound t, the width of the bounded certificate family poset on Fin n is O(n^{d(t)}) for some exponent d(t) — without the profile-injectivity hypothesis.

**Test:** For n = 2, 3, 4 and t = 1, 2, compute exact poset widths (via Dilworth's theorem / maximum matching). Compare against polynomial predictions. Any exponential-size antichain for fixed t would be a disproof.

**Impact:** This would be a landmark result in quantitative WQO theory. It would show that bounded certificate families have intrinsically polynomial obstruction complexity, converting the finite-basis theorem into a polynomial-time searchability theorem.

**Catalog References:**
- `Pythagorean/PolynomialWidth.lean`: `bounded_certificate_width_polynomial_exists`, `polynomial_beats_exponential`
- `Pythagorean/CertificatePosetWQO.lean`: `finite_antichain_of_bounded`, `bounded_certificate_family_wqo`

**Proof Strategy:** Combine Directions 1 and 2: use the sharp Sperner bound for the profile-injective component and the collision structure theorem for the profile-collision component. Alternatively, develop a direct Dilworth-type decomposition of the family poset into polynomially many chains.

**Domain Bridges:** Well-quasi-order theory, Ramsey theory, structural graph theory (Robertson-Seymour), computational complexity (parameterized complexity, obstruction sets)

**Lineage:** The culmination of the polynomial width program. Removes all hypotheses from `bounded_certificate_width_polynomial_exists`.

**Ambition:** ★★★★★ (Grand challenge — may require fundamentally new techniques)

---

## Summary Table

| Direction | Ambition | Dependencies | Key New Technique |
|-----------|----------|--------------|-------------------|
| 1. Sharp Exponent | ★★★☆☆ | Box width | Normalized matching property |
| 2. Collision Structure | ★★★★☆ | Profile width | Bollobás/Sauer-Shelah |
| 3. Generating Functions | ★★★★★ | Rank levels | Saddle-point method |
| 4. Pythagorean Application | ★★☆☆☆ | All results | Domain analysis |
| 5. Universal Polynomial Width | ★★★★★ | Directions 1+2 | Novel decomposition |
