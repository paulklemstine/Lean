# Future Directions: Non-Abelian Arithmetic Phase Classification

## Synthesis

The Arithmetic Phase Classification Theorem establishes abelianization as the complete invariant for prime-torsion detection through abelian probes of finite groups. This opens five natural research directions, organized in two tiers:

1. **Grand challenges** that probe the boundary between abelian and non-abelian arithmetic structure, potentially revealing entirely new invariants.
2. **Concrete extensions** that deepen and broaden the current theory, building directly on the formal machinery already established.

All five directions are connected by a single organizing question: *How much of a finite group's arithmetic structure is captured by successively richer linearized approximations?* The Phase Classification Theorem answers this for the first approximation (abelianization = H₁). The directions below explore higher levels of the hierarchy.

---

## Direction 1: Schur Multiplier Phase Detection

**Conjecture:** *For any finite group G, the set of primes in the "non-abelian regime" (dividing |[G,G]| but not |G^ab|) is exactly captured by the Schur multiplier H₂(G, ℤ). Specifically:*

$$\text{Profile}_2(G) := \{p \text{ prime} \mid p \mid |H_2(G, \mathbb{Z})|\} = \{p \text{ prime} \mid p \mid |G|, p \notin \text{Profile}(G)\}$$

*where Profile(G) is the arithmetic phase profile from the abelianization.*

**Test:** Compute H₂(G, ℤ) for groups S₃, A₄, Q₈, S₄, A₅ and verify the prime-factor relationship. The Schur multiplier is known for many groups:
- H₂(S₃, ℤ) = ℤ/2 → primes {2} (but 2 is already in Profile(S₃), so this refines rather than extends)
- H₂(A₅, ℤ) = ℤ/2 → primes {2}, but |A₅| has factors {2,3,5}, so primes {3,5} would NOT be in Profile₂
- This would disprove the conjecture as stated.

A refined version: Profile₂ captures *some but not all* non-abelian primes. The exact characterization requires studying the LHS spectral sequence.

**Impact:** If true (even in refined form), this would establish a two-level arithmetic hierarchy: abelianization captures H₁-visible primes, Schur multiplier captures H₂-visible primes. This would be the first step toward a complete "arithmetic filtration" of finite group torsion.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean` — `primePhaseVisible_iff_hasPTorsion_abelianization`
- `Pythagorean/ArithmeticPhaseClassification.lean` — `torsion_invisible_wrong_characteristic`

**Proof Strategy:** Use the Lyndon-Hochschild-Serre spectral sequence for the extension 1 → [G,G] → G → G^ab → 1. The E₂ page relates H_p(G^ab, H_q([G,G], ℤ)) to H_{p+q}(G, ℤ). Analyze the differentials to determine which primes survive to H₂.

**Domain Bridges:** Homological algebra, algebraic K-theory, representation stability.

**Lineage:** Extends Theorem A to the next derived level.

**Ambition:** Grand challenge — requires developing new formal infrastructure for group homology.

---

## Direction 2: Prime-Power Torsion Refinement

**Conjecture:** *The arithmetic phase profile can be refined to a "torsion spectrum" that tracks not just which primes appear but with what multiplicity. For any finite group G and prime p:*

$$\text{torsionMultiplicity}(G, p) = v_p(|G^{ab}|)$$

*where v_p denotes the p-adic valuation. Moreover, this multiplicity is preserved under abelianization isomorphism and decomposes additively under products.*

**Test:**
- S₃: v₂(|G^ab|) = v₂(2) = 1. Direct check: G^ab = ℤ/2, maximal 2-power order is 2¹.
- Q₈: v₂(|G^ab|) = v₂(4) = 2. Direct check: G^ab = ℤ/2 × ℤ/2, but maximal 2-power order is still 2¹. This would disprove the naive multiplicity = v_p conjecture!
- Refined version: The torsion spectrum should track the *invariant factor decomposition* of G^ab, not just the p-adic valuation of the order.

**Impact:** Would produce a finer invariant that distinguishes groups the phase profile cannot (e.g., groups with G^ab ≅ ℤ/4 vs G^ab ≅ ℤ/2 × ℤ/2).

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean` — `HasPTorsion_ZMod_iff_dvd`
- `Pythagorean/ArithmeticPhaseClassification.lean` — `hasPTorsion_prod_iff`

**Proof Strategy:** Use the Fundamental Theorem of Finitely Generated Abelian Groups (available in Mathlib as `Module.equiv_directSum_of_isTorsion`) to decompose G^ab into cyclic factors. Track the p-primary components explicitly.

**Domain Bridges:** Number theory (p-adic analysis), algebraic topology (homology with coefficients).

**Lineage:** Directly refines the current profile definition.

**Ambition:** Solid extension — builds directly on established formal infrastructure.

---

## Direction 3: Phase Classification for Profinite Groups

**Conjecture:** *The Arithmetic Phase Classification Theorem extends to profinite groups G = lim G/N (inverse limit over normal open subgroups). The arithmetic phase profile of G equals the union of profiles of all finite quotients:*

$$\text{Profile}(G) = \bigcup_{N \trianglelefteq_o G} \text{Profile}(G/N)$$

*Moreover, if G is the absolute Galois group Gal(K̄/K) for a number field K, then Profile(G) is determined by the ramification data of K.*

**Test:**
- ℤ̂ (profinite completion of ℤ): Profile should be all primes, since ℤ̂^ab = ℤ̂ has p-torsion quotients for all p.
- Gal(Q̄/Q): By class field theory, the abelianization is related to the idele class group. The profile should include all primes.
- A non-trivial test: the pro-p completion of a free group. The abelianization is ℤₚ^n, and the profile should be {p}.

**Impact:** Would connect the arithmetic phase classification to algebraic number theory and the Langlands program, potentially providing a new perspective on ramification theory.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean` — `primePhaseVisible_iff_hasPTorsion_abelianization`
- `Pythagorean/ArithmeticPhaseClassification.lean` — `arithmeticPhaseProfile_eq_of_abelianization_equiv`

**Proof Strategy:** Use the continuity of abelianization for profinite groups: Ab(lim G/N) = lim Ab(G/N). The profile then follows from a compactness argument on the inverse system.

**Domain Bridges:** Algebraic number theory, class field theory, Iwasawa theory.

**Lineage:** Generalizes the finite group theory to the profinite setting.

**Ambition:** Grand challenge — requires significant formal infrastructure for profinite groups.

---

## Direction 4: Functorial Phase Maps and Natural Transformations

**Conjecture:** *The arithmetic phase profile defines a functor from the category of finite groups (with surjective homomorphisms) to the poset of finite subsets of primes (ordered by inclusion). Moreover, this functor factors through the abelianization functor:*

$$\text{FinGrp}^{\text{surj}} \xrightarrow{\text{Ab}} \text{FinAbGrp} \xrightarrow{\text{TorsProfile}} \mathcal{P}_{\text{fin}}(\text{Primes})$$

*and the second functor preserves finite products (converting them to unions).*

**Test:**
- Verify functoriality: if f : G →→ H is surjective, then Profile(H) ⊆ Profile(G). This follows because Ab(H) is a quotient of Ab(G), and quotients can only lose torsion.
- Verify the product preservation: Profile(G × H) = Profile(G) ∪ Profile(H) is already Theorem C.
- Check behavior on short exact sequences: for 1 → N → G → Q → 1, what is the relationship between Profile(G), Profile(N), and Profile(Q)?

**Impact:** Would establish the arithmetic phase profile as a proper algebraic invariant with clean categorical properties, suitable for systematic computation.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean` — all main theorems
- `Pythagorean/ArithmeticPhaseClassification.lean` — `abelianizationProdEquiv`

**Proof Strategy:** The functoriality of abelianization is well-established. The key new ingredient is showing that the torsion profile functor from finite abelian groups to sets of primes is well-defined and preserves products. This follows from the product torsion decomposition theorem.

**Domain Bridges:** Category theory, algebraic K-theory, homological algebra.

**Lineage:** Categorifies the main theorems.

**Ambition:** Solid extension — largely follows from existing results with categorical packaging.

---

## Direction 5: Computational Detection of Non-Abelian Anomalies

**Conjecture:** *For every finite group G, the "non-abelian anomaly set"*

$$\text{Anomaly}(G) := \{p \text{ prime} \mid p \mid |G|, p \notin \text{Profile}(G)\}$$

*is non-empty if and only if G is non-abelian. Moreover, |Anomaly(G)| ≥ 1 whenever [G,G] ≠ 1, and Anomaly(G) grows (in some average sense) with the "non-abelian complexity" of G.*

**Test:**
- S₃: |G| = 6, Profile = {2}, so Anomaly = {3}. Non-empty, confirming non-abelianity. ✓
- A₄: |G| = 12, Profile = {3}, so Anomaly = {2}. ✓
- Q₈: |G| = 8, Profile = {2}, so Anomaly = ∅? Wait: |G| = 8 has only prime factor 2, and Profile = {2}. So Anomaly = ∅! But Q₈ is non-abelian.
- This disproves the conjecture as stated! Q₈ is non-abelian but has no anomalous primes.

**Refined conjecture:** Anomaly(G) = ∅ does not imply G is abelian. The correct condition is: Anomaly(G) is non-empty if and only if [G,G] has a prime factor not dividing |G^ab|. More precisely: Anomaly(G) = prime_factors(|[G,G]|) \ prime_factors(|G^ab|).

For Q₈: |[G,G]| = 2, |G^ab| = 4, so prime_factors({2}) \ prime_factors({2}) = ∅. The refined conjecture holds.

For S₃: |[G,G]| = 3, |G^ab| = 2, so {3} \ {2} = {3}. ✓

**Test the refined conjecture computationally** for all groups of order ≤ 30.

**Impact:** Would provide a quantitative measure of "non-abelian complexity" that complements the qualitative Phase Classification Theorem.

**Catalog References:**
- `Pythagorean/ArithmeticPhaseClassification.lean` — `arithmeticPhaseProfile_eq_abelianization_profile`
- `Pythagorean/ArithmeticPhaseClassification.lean` — `torsion_invisible_wrong_characteristic`

**Proof Strategy:** The refined conjecture follows directly from |G| = |G^ab| · |[G,G]| and prime factorization. The interesting content is in the computational survey and in understanding which groups maximize |Anomaly|.

**Domain Bridges:** Computational group theory, group classification, complexity theory.

**Lineage:** Computational exploration of the theorem's consequences.

**Ambition:** Solid extension with falsifiable computational predictions.
