# Future Directions: Artin's Conjecture on Primitive Roots

## Synthesis

This research cycle established the complete algebraic foundation for Artin's conjecture on primitive roots: the existence of primitive roots for all primes, the efficient test criterion, the counting formula φ(p−1), the safe prime theorem, and the generator-order equivalence. These 15 verified theorems form a coherent theory that bridges finite group theory (cyclic groups, order theory) with number theory (primes, totient function, modular arithmetic).

The most promising cross-domain connection is between the **safe prime primitive root theorem** and **cryptographic group theory** in the Catalog. The safe prime result shows that the primitive root test simplifies dramatically when p−1 = 2q for q prime — requiring only two checks instead of checking all prime divisors of p−1. This directly connects to the Berggren-Lorentz structures in `Cryptography/BerggrenDiophantineLattice.lean` and `Cryptography/BerggrenGroupoidOrbit.lean`, where group-theoretic primitives underpin security assumptions. Formalizing the connection between primitive root density and cryptographic group selection would yield theorems with both mathematical depth and practical significance.

The highest breakthrough potential lies in **Direction 1**: formalizing Dirichlet's theorem on primes in arithmetic progressions. This is the single missing piece that would unlock a formal proof of Hooley's conditional result under GRH, and it connects to analytic number theory infrastructure that would benefit many other formalization efforts.

---

### Direction 1: Formalize Dirichlet's Theorem on Primes in Arithmetic Progressions

**Conjecture**: For coprime integers a and n, the set {p prime : p ≡ a (mod n)} is infinite, and has natural density 1/φ(n) among all primes.

**Test**: Formalize the statement in Lean 4 and prove it for small cases (n = 2, 3, 4). For n = 4, this requires showing infinitely many primes ≡ 1 (mod 4) and infinitely many ≡ 3 (mod 4). The n = 4, a = 3 case can be proved elementarily using Euclid-style arguments: if p₁, ..., pₖ are all primes ≡ 3 (mod 4), then 4p₁···pₖ − 1 ≡ 3 (mod 4) and must have a prime factor ≡ 3 (mod 4) not in the list.

**Impact**: Dirichlet's theorem is a prerequisite for Hooley's conditional proof of Artin's conjecture. Its formalization would immediately enable the formalization of: (1) the density version of Artin's conjecture under GRH, (2) Linnik's theorem on the least prime in an arithmetic progression, and (3) the Chebotarev density theorem (with additional algebraic number theory infrastructure).

**Catalog References**: `Algebra/ArtinPrimitiveRoot.lean` (this cycle's primitive root theory), `Algebra/DeepOpenProblems.lean` (related open problems infrastructure)

**Proof Strategy**: 
- *Step 1*: Define Dirichlet characters χ : (ℤ/nℤ)ˣ → ℂ as group homomorphisms. Mathlib has `MulChar` and `ZMod.MulChar`.
- *Step 2*: Define Dirichlet L-functions L(s, χ) = Σ χ(n)/nˢ for Re(s) > 1.
- *Step 3*: Prove L(1, χ) ≠ 0 for non-principal characters (the hardest step — requires separate arguments for real and complex characters).
- *Step 4*: Use the orthogonality relations to extract the prime counting function for a specific residue class.
- *Key prerequisite*: Mathlib's `Analysis.LSeries` and complex analysis infrastructure.

**Domain Bridges**: NumberTheory <-> Analysis, Algebra <-> ComplexAnalysis

**Lineage**: Builds on `exists_primitive_root`, `order_dvd_prime_minus_one`, and the primitive root test criterion from this cycle. Extends the density results toward quantitative Artin theory.

**Ambition**: grand_challenge

---

### Direction 2: Safe Prime Infinitude and Cryptographic Primitive Root Selection

**Conjecture**: There exist infinitely many safe primes p = 2q + 1 where q is prime. More specifically, the number of safe primes up to N is asymptotically C₂ · N / (log N)² where C₂ ≈ 1.32 is twice the twin prime constant.

**Test**: Verify computationally that the safe prime count up to 10⁸ matches the predicted asymptotic C₂ · N/(log N)² within 5%. Formally prove that for any safe prime p = 2q + 1 with q ≥ 3, the number of primitive roots mod p is exactly q − 1 = (p − 3)/2. This is a strengthening of our safe prime theorem: count the elements satisfying the two conditions.

**Impact**: If infinitely many safe primes exist, then combined with the `safe_prime_primroot` theorem, we get an unconditional proof that every non-square a with |a| ≥ 2 is a primitive root modulo infinitely many primes — resolving Artin's conjecture. The safe prime infinitude is expected to follow from the Bunyakovsky/Bateman-Horn conjectures but remains unproven.

**Catalog References**: `Algebra/ArtinPrimitiveRoot.lean` (`safe_prime_primroot`), `Cryptography/BerggrenDiophantineLattice.lean` (group-theoretic primitives), `Cryptography/BerggrenFingerprintRigidity.lean` (algebraic rigidity)

**Proof Strategy**:
- *Step 1*: Define safe primes formally: `def IsSafePrime (p : ℕ) : Prop := Nat.Prime p ∧ Nat.Prime ((p-1)/2) ∧ p ≥ 5`.
- *Step 2*: Prove the counting formula: for safe prime p, #{primitive roots mod p} = (p-3)/2.
- *Step 3*: Formalize the Bateman-Horn conjecture for the polynomial pair (n, 2n+1) and derive the safe prime density prediction.
- *Step 4*: Prove that safe prime infinitude + safe_prime_primroot ⟹ Artin's conjecture for all a ≠ ±1 with |a| ≥ 2 and a not a perfect square.

**Domain Bridges**: NumberTheory <-> Cryptography, Algebra <-> AnalyticNumberTheory

**Lineage**: Directly extends `safe_prime_primroot` from this cycle. Connects to the Berggren cryptographic infrastructure in the Catalog.

**Ambition**: grand_challenge

---

### Direction 3: Artin Constant Convergence and Effective Bounds

**Conjecture**: The infinite product C_Artin = ∏_q (1 − 1/(q(q−1))) converges absolutely, and for the partial product P(Q) = ∏_{q ≤ Q} (1 − 1/(q(q−1))), we have |P(Q) − C_Artin| ≤ 1/Q.

**Test**: Compute P(Q) for Q = 10², 10³, 10⁴, 10⁵ and verify the error bound |P(Q) − C_Artin| ≤ 1/Q. The true Artin constant is known to 100+ decimal places: C_Artin = 0.3739558136192022880547280543...

**Impact**: A formal convergence proof would establish the Artin constant as a well-defined real number in Lean, enabling formal statements of the quantitative Artin conjecture. Effective error bounds would connect to computational number theory and provide certified numerical approximations.

**Catalog References**: `Algebra/ArtinPrimitiveRoot.lean` (`artinConstant` definition), `EML/EMLv17Core.lean` (infinite product techniques)

**Proof Strategy**:
- *Step 1*: Show 0 < 1 − 1/(q(q−1)) < 1 for all primes q.
- *Step 2*: Take logarithms: log C_Artin = Σ_q log(1 − 1/(q(q−1))).
- *Step 3*: Use |log(1−x)| ≤ 2x for 0 < x < 1/2 to bound the tail.
- *Step 4*: The tail Σ_{q>Q} 1/(q(q−1)) ≤ Σ_{n>Q} 1/(n(n−1)) = 1/Q by telescoping.
- *Key tool*: Mathlib's `HasProd` and `Summable` for infinite products/series.

**Domain Bridges**: NumberTheory <-> Analysis, Algebra <-> RealAnalysis

**Lineage**: Extends the `artinConstant` definition from this cycle. Connects to EML infinite product techniques.

**Ambition**: extension

---

### Direction 4: Primitive Root Distribution in Arithmetic Progressions

**Conjecture**: For a fixed Artin candidate a, the set of primes p where a is a primitive root is equidistributed among residue classes modulo any fixed integer m coprime to a. More precisely, for coprime a, m with m ≥ 2:

lim_{N→∞} #{p ≤ N : a prim. root mod p, p ≡ b (mod m)} / #{p ≤ N : a prim. root mod p} = 1/φ(m)

for each b coprime to m.

**Test**: For a = 2 and m = 3, compute the distribution of primitive-root primes among residues 1 and 2 mod 3. The conjecture predicts 50% in each class. Verify computationally for primes up to 10⁶.

**Impact**: This equidistribution result would show that primitive root primes have no systematic bias toward particular residue classes, strengthening the heuristic that they behave like a "random" subset of primes with density C_Artin.

**Catalog References**: `Algebra/ArtinPrimitiveRoot.lean` (artinSet), `Algebra/DeepOpenProblems.lean`

**Proof Strategy**:
- *Step 1*: Formalize the statement using `Nat.Mpl.density` or a custom density notion.
- *Step 2*: Use the Chebotarev density theorem (conditional on its formalization) applied to the splitting field of x^n − a over ℚ(ζ_m).
- *Step 3*: Show that the relevant Galois group acts transitively on residue classes.
- *Prerequisite*: Formalized Chebotarev density theorem.

**Domain Bridges**: NumberTheory <-> AlgebraicNumberTheory, Algebra <-> GaloisTheory

**Lineage**: Extends the density analysis from this cycle's `primitive_root_density_pos` and `artinSet` definitions.

**Ambition**: extension

---

### Direction 5: Generalized Artin Conjecture for Composite Moduli

**Conjecture**: For a composite modulus n, define a to be a "generalized primitive root" if ord_n(a) = λ(n), where λ is the Carmichael function. For any non-square a ≠ ±1, there should exist infinitely many n (not necessarily prime) for which a is a generalized primitive root.

**Test**: For a = 2, compute all n ≤ 10⁴ where ord_n(2) = λ(n). Count them and compare to the density predicted by a product formula analogous to the Artin constant but over prime powers.

**Impact**: This extends Artin's conjecture beyond primes to all moduli, connecting to the Carmichael function theory and potentially to the `CarmichaelComposite` formalization mentioned in the catalog. The composite case reveals additional structure: n must avoid prime power factors p^k where the multiplicative group (ℤ/p^k ℤ)ˣ has "extra" cyclic factors.

**Catalog References**: `Algebra/ArtinPrimitiveRoot.lean`, the CarmichaelComposite formalization target mentioned in project priorities

**Proof Strategy**:
- *Step 1*: Define the Carmichael function λ(n) = lcm of λ(p^k) over prime power factors.
- *Step 2*: Characterize when ord_n(a) = λ(n): this requires a to be a primitive root mod each prime power p^k || n, adjusted for the Carmichael vs. Euler totient discrepancy.
- *Step 3*: Prove the density formula for the composite case.
- *Step 4*: Connect to the CarmichaelComposite infrastructure for Carmichael numbers.

**Domain Bridges**: NumberTheory <-> Algebra, Computation <-> Cryptography

**Lineage**: Extends the prime-modulus theory from this cycle to composite moduli. Connects to the CarmichaelComposite formalization target.

**Ambition**: extension
