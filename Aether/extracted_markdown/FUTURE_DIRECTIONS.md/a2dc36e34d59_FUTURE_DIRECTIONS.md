# Future Directions: Taxicab Number Theory

## Synthesis

This research cycle established a rigorous formal foundation for taxicab number theory, producing machine-verified proofs of key structural results and numerical verifications. The most significant theoretical finding is the **Same-Sum Uniqueness Theorem**: the pair-sum a + b is a complete invariant for cube representations a³ + b³ = n, meaning the cube representation signature Sig(n) = {a + b : a³ + b³ = n} uniquely encodes all decompositions. This connects the combinatorial problem of counting representations to the algebraic structure of factored forms (a+b)(a²-ab+b²).

The **cubic lower bound** k³ < Ta(k) provides a provable growth floor via pigeonhole, but the actual growth is dramatically faster (Ta(4)/4³ ≈ 10⁸). The gap between our proven lower bound and empirical growth rates presents the clearest opportunity for breakthrough. The most promising cross-domain connection is to **elliptic curve theory**: the equation x³ + y³ = n defines an elliptic curve whose rank governs the supply of rational points, and hence (after scaling) the number of integer cube representations. Connecting the formal taxicab framework to Mathlib's elliptic curve library could unlock existence proofs for Ta(k) for all k.

The cycle also revealed that the existence of Ta(k) for all k is genuinely hard — it cannot be proven by simple scaling or product arguments (Fermat's Last Theorem blocks the most natural constructions). This makes the existential direction a true grand challenge requiring either elliptic curve machinery or novel combinatorial arguments.

---

### Direction 1: Taxicab Existence via Elliptic Curves

**Conjecture**: For every positive integer k, there exists a positive integer n such that n can be expressed as a sum of two positive cubes in at least k distinct ways (i.e., Ta(k) exists for all k).

**Test**: Formalize the following argument in Lean: (1) For n = 2 (i.e., the curve x³ + y³ = 2), the elliptic curve has rank ≥ 1 over ℚ. (2) A rank-1 curve has infinitely many rational points. (3) Infinitely many rational points on x³ + y³ = 2 yield, after clearing denominators, arbitrarily many integer representations of 2·d⁶ as a sum of two cubes (for appropriate scaling factors d). Verify step (1) computationally by exhibiting a point of infinite order.

**Impact**: If proved, this settles a fundamental question in additive number theory and demonstrates that formal methods can handle deep existence theorems. If the elliptic curve approach fails in Lean due to missing Mathlib infrastructure, this maps out exactly what elliptic curve theory needs formalization.

**Catalog References**: `Cryptography/BerggrenDiophantineLattice.lean` (Diophantine structure), `FINAL/Pythagorean/PythagoreanPairing.lean` (sum-of-squares analogy via `fermat_sum_two_squares_1mod4`)

**Proof Strategy**: 
1. Define the elliptic curve E: y² = x³ - 432 (the Weierstrass form of X³ + Y³ = 1).
2. Show that (−7, 13) is a rational point of infinite order (verify 2P ≠ O, 3P ≠ O).
3. Use the group law to generate arbitrarily many distinct rational points.
4. Map back to sum-of-cubes representations via the standard birational equivalence.
5. Clear denominators to get integer representations of a scaled number.

**Domain Bridges**: Number Theory ↔ Algebraic Geometry ↔ Formal Methods

**Lineage**: Builds on `hardy_ramanujan_1729`, `same_sum_implies_same_pair`, and `taxicab_scale` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Tight Growth Rate Bounds for Taxicab Numbers

**Conjecture**: There exist constants C > 0 and α > 1 such that Ta(k) ≥ α^(k²) for all sufficiently large k. Specifically, Ta(k) ≥ 2^(k²/4) for k ≥ 3.

**Test**: 
1. Verify computationally for k = 2, 3, 4, 5 (known values).
2. Formalize the argument: if n has k cube representations, each pair-sum sᵢ = aᵢ + bᵢ is distinct (by Same-Sum Uniqueness). Since n = sᵢ(sᵢ² - 3aᵢbᵢ), the pair-sums are roots of a degree-k polynomial in s related to n. The discriminant constraints should yield super-exponential growth.

**Impact**: Would provide the first provable super-polynomial lower bound on taxicab numbers, significantly improving the cubic bound k³ < Ta(k) from this cycle.

**Catalog References**: `Pythagorean/TaxicabNumbers.lean` (`taxicab_cubic_lower_bound`, `distinct_reps_different_sums`)

**Proof Strategy**:
1. From n = s(s² - 3p) with s = a+b and p = ab, derive that distinct pair-sums sᵢ satisfy sᵢ | n and sᵢ² - 3pᵢ = n/sᵢ.
2. Show the pair-sums are bounded: 2 ≤ sᵢ ≤ n^(1/3)·2^(1/3) (from a ≤ b and a³ + b³ = n).
3. Use the constraint that all sᵢ divide n to bound the number of divisors in range, connecting to divisor function estimates.
4. Invert to get lower bounds on n in terms of k.

**Domain Bridges**: Analytic Number Theory ↔ Divisor Theory ↔ Formal Verification

**Lineage**: Extends `taxicab_cubic_lower_bound` and `distinct_reps_different_sums`.

**Ambition**: grand_challenge

---

### Direction 3: Cabtaxi Numbers and Signed Cube Sums

**Conjecture**: Define Cabtaxi(k) as the smallest positive integer expressible as a sum of two cubes (allowing negative cubes) in at least k distinct ways. Then Cabtaxi(k) exists for all k, and Cabtaxi(k) < Ta(k) for k ≥ 2.

**Test**: Verify Cabtaxi(2) = 91 (since 91 = 3³ + 4³ = 6³ + (−5)³) and Cabtaxi(3) = 728 (= 6³ + (−2)³ = 8³ + (−4)³ = 9³ + (−1)³ = 12³ + (−10)³). Formalize the signed cube representation structure and prove the comparison Cabtaxi(k) ≤ Ta(k).

**Impact**: Opens a parallel theory with richer structure (signed representations are more abundant). The existence problem for Cabtaxi numbers is easier than for taxicab numbers, potentially providing a stepping stone to the grand challenge.

**Catalog References**: `Pythagorean/TaxicabNumbers.lean` (adapt `CubeRep` to allow negative values)

**Proof Strategy**:
1. Define `SignedCubeRep` allowing a, b to be any nonzero integers with |a| ≤ |b|.
2. Verify Cabtaxi(2) = 91 and Cabtaxi(3) = 728 by exhibiting representations.
3. Prove Cabtaxi(k) ≤ Ta(k) by showing every positive cube representation is also a signed representation.
4. Prove existence of Cabtaxi(k) for all k using the richer supply of signed representations.

**Domain Bridges**: Additive Number Theory ↔ Diophantine Equations ↔ Combinatorics

**Lineage**: Direct extension of `CubeRep`, `IsTaxicab`, `same_sum_implies_same_pair`.

**Ambition**: extension

---

### Direction 4: Signature Structure and Modular Arithmetic

**Conjecture**: For any taxicab number n with τ(n) ≥ 2, the elements of the cube representation signature Sig(n) are all congruent modulo 6. That is, for any two pair-sums s₁, s₂ ∈ Sig(n), we have s₁ ≡ s₂ (mod 6).

**Test**: 
- Sig(1729) = {13, 19}: 13 ≡ 1 (mod 6), 19 ≡ 1 (mod 6). ✓
- Sig(87539319) = {603, 651, 669}: 603 ≡ 3 (mod 6), 651 ≡ 3 (mod 6), 669 ≡ 3 (mod 6). ✓
- Sig(6963472309248) = {21504, 24384, 28272, 29952}: all ≡ 0 (mod 6). ✓
- Check for counterexamples among all two-way taxicab numbers below 10⁸.

**Impact**: If true, this reveals a hidden modular constraint on taxicab decompositions that could drastically reduce search spaces. If false, the counterexample would reveal interesting arithmetic structure. Either way, this is a concrete, testable prediction with immediate algorithmic applications.

**Catalog References**: `Pythagorean/TaxicabNumbers.lean` (`CubeRepSignature`, `distinct_reps_different_sums`)

**Proof Strategy**:
1. From a³ + b³ = n and the factorization n = (a+b)(a²-ab+b²), analyze a+b mod 6.
2. Note that a³ ≡ a (mod 6) for all a, so a³ + b³ ≡ a + b (mod 6). Hence all pair-sums s = a+b satisfy s ≡ n (mod 6).
3. This means all pair-sums ARE congruent mod 6 — they all equal n mod 6!
4. Formalize this using `Int.emod_emod_of_dvd`.

**Domain Bridges**: Modular Arithmetic ↔ Taxicab Theory ↔ Algorithm Design

**Lineage**: Extends `CubeRepSignature` and `sum_cubes_factor`.

**Ambition**: extension

---

### Direction 5: Computational Search for Ta(5) and Ta(6) Certificates

**Conjecture**: Compact certificates for Ta(5) = 48,988,659,276,962,496 and Ta(6) = 24,153,319,581,254,312,065,344 can be formally verified in Lean using the `CubeRep` framework from this cycle.

**Test**: Exhibit all 5 (resp. 6) cube representations as `CubeRep` structures and verify the `IsTaxicab` property. The key challenge is that `norm_num` must handle arithmetic on 16+ digit numbers.

**Impact**: Would extend the formal verification frontier for taxicab numbers from Ta(4) to Ta(6), providing the most complete machine-verified dataset of taxicab values.

**Catalog References**: `Pythagorean/TaxicabNumbers.lean` (`taxicab4_verified`, `IsTaxicab`)

**Proof Strategy**:
1. Look up known representations of Ta(5) and Ta(6) from the mathematical literature.
2. Create `CubeRep` structures for each representation, using `norm_num` for the equality proofs.
3. If `norm_num` times out on very large numbers, use `native_decide` or manual arithmetic lemmas.
4. Package into `IsTaxicab` witnesses following the pattern of `taxicab4_verified`.

**Domain Bridges**: Computational Number Theory ↔ Formal Verification ↔ Large-Scale Arithmetic

**Lineage**: Extends `taxicab4_verified`.

**Ambition**: extension
