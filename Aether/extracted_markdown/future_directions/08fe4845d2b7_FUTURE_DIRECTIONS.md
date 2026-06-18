# Future Directions: Stochastic Galois Theory

## Synthesis

This cycle established the formal foundations of stochastic Galois theory over finite fields: counting monic polynomials, bounding roots via Schwartz-Zippel, computing evaluation fibers, characterizing quadratic splitting via discriminants, and proving density convergence. The central discovery is that the combinatorics of polynomial factorization over F_p mirrors the cycle-type statistics of the symmetric group S_n, with convergence rate O(1/p).

The most promising cross-domain connection is between **polynomial factorization patterns** and **random permutation statistics**. The splitting profile of a polynomial over F_p is literally a cycle type of the Frobenius permutation, and as p → ∞, these cycle types become equidistributed. This connects finite field algebra (Galois theory) to combinatorics (symmetric group theory) and probability (random permutations). The fiber-counting machinery we developed (`root_fiber_card`) provides the quantitative backbone for these density calculations.

The highest-breakthrough-potential direction is **Direction 1**: formalizing the necklace/Möbius formula for irreducible polynomial counts. This would connect our counting infrastructure to multiplicative number theory (Möbius inversion) and combinatorics (Burnside's lemma), opening pathways to formalize Chebotarev equidistribution. The multivariate Schwartz-Zippel extension (Direction 3) has the broadest applicability, impacting randomized algorithms and complexity theory.

---

### Direction 1: The Necklace Formula and Möbius Inversion for Finite Fields

**Conjecture**: For all primes p and positive integers n, the number of monic irreducible polynomials of degree n over F_p equals

N(n, p) = (1/n) Σ_{d|n} μ(n/d) · p^d

where μ is the Möbius function. Equivalently, n · N(n, p) = Σ_{d|n} μ(n/d) · p^d.

**Test**: For n = 4, p = 5: N(4,5) = (1/4)(μ(4)·5 + μ(2)·25 + μ(1)·625) = (1/4)(0 - 25 + 625) = 150. Verify by enumerating all 625 monic quartics over F_5 and testing irreducibility. Similarly for n = 6, p = 3: N(6,3) = (1/6)(μ(6)·3 + μ(3)·9 + μ(2)·27 + μ(1)·729) = (1/6)(3 - 9 - 27 + 729) = 116.

**Impact**: If formalized, this provides the exact counting function for irreducible polynomials, which is the key input to the equidistribution theorem. It would also demonstrate that Lean can handle multiplicative number theory (Möbius function, divisor sums) effectively.

**Catalog References**: `Algebra/StochasticGalois.lean` (our counting infrastructure), `Algebra/CausalCertification.lean` (valuation/divisibility), `Computation/PadicValuationDepth.lean` (p-adic techniques)

**Proof Strategy**:
1. Define the Möbius function μ on ℕ and prove basic properties (μ(1) = 1, μ is multiplicative, Möbius inversion formula).
2. Prove that x^{q^n} - x = ∏_d|n (product of all irreducible polys of degree d) over F_q. This is the key identity from finite field theory.
3. Take degrees on both sides: q^n = Σ_{d|n} d · N(d, q).
4. Apply Möbius inversion to get N(n, q) = (1/n) Σ_{d|n} μ(n/d) · q^d.
5. Key lemmas needed: `ZMod.instField`, properties of `Polynomial.roots` over finite fields, the factorization of x^{p^n} - x.

**Domain Bridges**: Algebra <-> NumberTheory, Algebra <-> Combinatorics

**Lineage**: Builds on `card_monic_poly_zmod`, `schwartz_zippel_univariate`, and the `SplittingProfile` definition from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Chebotarev Equidistribution for Function Fields

**Conjecture**: For each partition λ of n, the fraction of monic degree-n polynomials over F_q with splitting profile λ converges to |C_λ|/n! as q → ∞, where C_λ is the conjugacy class of S_n with cycle type λ. More precisely:

|N_λ(q)/q^n - |C_λ|/n!| = O(1/q)

where the implied constant depends on n and λ.

**Test**: For n = 3, λ = (1,2): the fraction of cubics with splitting type (1,2) over F_p should converge to 3/6 = 1/2. Compute for p = 101, 1009, 10007 and verify the O(1/p) error bound. Specifically, the count should be p · N(2,p) = p · (p²-p)/2 = p²(p-1)/2, giving fraction (p-1)/2p → 1/2.

**Impact**: This would be a formalization of the function-field Chebotarev density theorem, one of the most important results in arithmetic geometry. Even a special case (e.g., for the splitting field of x^n - 1) would be significant.

**Catalog References**: `Algebra/StochasticGalois.lean`, `Algebra/GaloisObstruction.lean` (Galois group properties)

**Proof Strategy**:
1. Establish that N_λ(q) can be expressed as a product of irreducible polynomial counts via inclusion-exclusion on the factorization structure.
2. For each partition λ = (d₁, ..., d_k), N_λ(q) = (1/|Aut(λ)|) · ∏ N(d_i, q) where Aut(λ) accounts for repeated parts. This needs careful handling of multiplicities.
3. Substitute the necklace formula for each N(d_i, q) and expand.
4. The leading term is q^n / (∏ d_i · |Aut(λ)|) = q^n · |C_λ|/n! (by the cycle-counting formula for S_n).
5. Lower-order terms contribute O(q^{n-1}).

**Domain Bridges**: Algebra <-> NumberTheory, Algebra <-> Probability

**Lineage**: Requires Direction 1 (necklace formula) as a prerequisite. Builds on `root_pairs_eq_sum_fibers` and `root_fiber_card`.

**Ambition**: grand_challenge

---

### Direction 3: Multivariate Schwartz-Zippel and Applications

**Conjecture**: For a nonzero polynomial f ∈ F_q[x₁, ..., x_m] of total degree d, the number of zeros in F_q^m is at most d · q^{m-1}.

**Test**: For the polynomial f(x,y) = x² + y² - 1 over F_7 (total degree 2), the number of zeros should be at most 2 · 7 = 14. Direct count gives 8 zeros: {(0,±1), (±1,0), (±2,±2)} — well within the bound. For f(x,y,z) = xyz over F_5 (degree 3), zeros = 5³ - 4³ = 61; bound = 3 · 25 = 75 ✓.

**Impact**: The Schwartz-Zippel lemma is foundational for randomized algorithms (polynomial identity testing, interactive proofs). Formalizing it would connect algebraic Galois theory to computational complexity. It's also the key ingredient for proving that "most" multivariate polynomials over finite fields have generic behavior.

**Catalog References**: `Algebra/StochasticGalois.lean` (`schwartz_zippel_univariate`), `Algebra/CircuitComplexity/Freivalds.lean` (`nonzero_linear_form_zero_set_bound`)

**Proof Strategy**:
1. Prove by induction on m (number of variables).
2. Base case m = 1 is our `schwartz_zippel_univariate`.
3. Inductive step: Write f = Σ_{i=0}^d g_i(x₂,...,x_m) · x₁^i. Fix (a₂,...,a_m) ∈ F_q^{m-1}.
4. If the specialized polynomial f(x₁, a₂, ..., a_m) is nonzero, it has ≤ d roots in x₁.
5. If it is identically zero, then all g_i vanish at (a₂,...,a_m). The leading g_d is nonzero and has degree ≤ d-d' for some d', so by induction it has ≤ (d-d') · q^{m-2} zeros.
6. Combine to get ≤ d · q^{m-1} total zeros.

**Domain Bridges**: Algebra <-> Computation, Algebra <-> Cryptography

**Lineage**: Direct extension of `schwartz_zippel_univariate` and `nonzero_linear_form_zero_set_bound`.

**Ambition**: extension

---

### Direction 4: Squarefree Polynomial Density over Finite Fields

**Conjecture**: The fraction of monic degree-n polynomials over F_q that are NOT squarefree is exactly

1/q · (1 - 1/q^2)^{-⌊n/2⌋} · (something explicit)

More precisely, the number of non-squarefree monic degree-n polynomials over F_q is q^{n-1} + O(q^{n-2}), so the non-squarefree fraction is 1/q + O(1/q²).

**Test**: For n = 4 over F_5: total = 625. A quartic f is non-squarefree iff gcd(f, f') ≠ 1. Count by enumeration: for each of the 625 quartics, compute gcd(f, f') and check degree > 0. The non-squarefree fraction should be close to 1/5 = 0.2. Exact formula: the number of monic degree-n polys divisible by g² for g irreducible of degree d is q^{n-2d}, sum over all irreducible g gives Σ_d N(d,q) · q^{n-2d}, with inclusion-exclusion for overcounting.

**Impact**: Squarefreeness is the polynomial analog of having no repeated prime factors. In number theory, the density of squarefree integers is 6/π² ≈ 0.608. The polynomial analog has density 1 - 1/q + O(1/q²), which approaches 1 as q → ∞. Formalizing this connects finite field algebra to analytic number theory.

**Catalog References**: `Algebra/StochasticGalois.lean` (`quadDiscriminant`, `schwartz_zippel_univariate`)

**Proof Strategy**:
1. Characterize non-squarefree polynomials via gcd(f, f') ≠ 1 (already noted in our `IsSquarefreePoly` definition attempt).
2. Count the set {f : ∃ irreducible g of degree d, g² | f} for each d.
3. Apply Möbius-style inclusion-exclusion.
4. Key lemma: the number of monic degree-n polys divisible by a fixed monic degree-k polynomial h is q^{n-k} (if k ≤ n).

**Domain Bridges**: Algebra <-> NumberTheory

**Lineage**: Builds on `schwartz_zippel_univariate` and the fiber-counting infrastructure from this cycle.

**Ambition**: extension

---

### Direction 5: Galois Groups over Q via Frobenius Lifting

**Conjecture**: If f ∈ Z[x] is a monic polynomial of degree n, and for two primes p₁, p₂ of good reduction, the splitting profiles of f mod p₁ and f mod p₂ include both an n-cycle (irreducible mod p₁) and a transposition (splitting type (1,...,1,2) mod p₂), then Gal(f/Q) = S_n.

**Test**: Take f(x) = x⁵ - x - 1 (known to have Galois group S₅). Check: f mod 2 = x⁵ + x + 1, which is irreducible over F₂ (profile (5) = 5-cycle ✓). f mod 3 = x⁵ + 2x + 2. Check factorization over F₃: f(0) = 2, f(1) = 2, f(2) = 29 mod 3 = 2 (all nonzero, so no linear factors). Test irreducibility... The key prediction is that there exist p₁ with profile (5) and p₂ with profile (1,1,1,2), and together these generate S₅.

**Impact**: This would connect finite-field factorization (computable) to the Galois group over Q (generally undecidable in full generality). It provides a practical algorithm for proving Galois groups are full symmetric groups, which is relevant to the inverse Galois problem.

**Catalog References**: `Algebra/GaloisObstruction.lean` (`not_solvableByRad_root_of_Gal_not_solvable`), `Algebra/StochasticGalois.lean` (splitting profiles)

**Proof Strategy**:
1. Use the Chebotarev density theorem to show that the set of Frobenius conjugacy classes is dense in Gal(f/Q).
2. An n-cycle and a transposition generate S_n (classical group theory result, partially formalized as `card_perm_fin`).
3. Since the Frobenius classes include both types, Gal(f/Q) contains generators of S_n, hence equals S_n.
4. Key formalization challenge: the reduction mod p map from Gal(f/Q) to Gal(f mod p / F_p) and the compatibility with Frobenius.

**Domain Bridges**: Algebra <-> NumberTheory, Algebra <-> Computation

**Lineage**: Builds on `SplittingProfile`, `card_perm_fin`, `perm_nontrivial`, and the Galois obstruction theorems from the Catalog.

**Ambition**: grand_challenge
