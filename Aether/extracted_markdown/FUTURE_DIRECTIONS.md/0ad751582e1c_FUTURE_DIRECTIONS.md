# Future Research Directions

## Synthesis

This cycle formalized the GL₁ Langlands correspondence for quadratic characters, establishing a "shape-color dictionary" connecting fundamental discriminants to Dirichlet characters via the Jacobi symbol. The key structural insight is that the Jacobi symbol's bilinear structure (multiplicative in both arguments) is the algebraic foundation of the correspondence — it forces injectivity (distinct discriminants produce distinct characters) and connects to the Gauss sum bridge between additive and multiplicative worlds.

The most promising cross-domain connection is between the bilinear symbol framework (from the existing `Cryptography/GL1LanglandsBilinear.lean`) and the character orthogonality theory developed here. Together, they suggest a path toward formalizing the full GL₁ Langlands correspondence via Artin reciprocity: the bilinear structure provides the algebraic skeleton, while character orthogonality provides the analytic content. The Gauss sum bridge (g(χ)² = χ(-1)·|F|) is the connecting tissue.

The highest breakthrough potential lies in Direction 2 (Cubic Reciprocity as GL₁ Shape-Color for Degree 3), because it extends the formalized framework to non-quadratic characters while remaining computationally testable, and because cubic reciprocity is substantially less formalized than quadratic reciprocity in existing theorem provers.

---

### Direction 1: Artin Reciprocity as GL₁ Completeness

**Conjecture**: The map sending each fundamental discriminant D to the quadratic character χ_D = J(D, ·) is a bijection from the set of fundamental discriminants to the set of primitive quadratic Dirichlet characters. Formally: for every primitive quadratic character χ mod N, there exists a unique fundamental discriminant D with |D| = N such that χ(p) = J(D, p) for all primes p ∤ N.

**Test**: Computationally verify for all moduli N ≤ 500: enumerate all primitive quadratic characters mod N (using the Dirichlet group structure), enumerate all fundamental discriminants D with |D| = N, and verify the bijection. For each pair, check J(D, p) = χ(p) for primes p ≤ 200.

**Impact**: This would formalize the surjectivity half of the GL₁ Langlands correspondence for quadratic characters, complementing the injectivity witnesses already verified. It connects to the Chebotarev density theorem and Hecke L-functions.

**Catalog References**: `Cryptography/GL1LanglandsBilinear.lean`, `Algebra/LanglandsToddlers.lean`

**Proof Strategy**: Define `PrimitiveQuadraticChar N` as a structure. Construct the map from fundamental discriminants to primitive characters. Prove injectivity using the bilinear expansion theorem. Prove surjectivity by showing that for each primitive quadratic character, the conductor equals |D| for some fundamental discriminant D. The key intermediate lemma is that the Jacobi symbol at a fundamental discriminant is a *primitive* character (not induced from a smaller modulus).

**Domain Bridges**: Number Theory (Artin reciprocity) <-> Algebra (bilinear symbols) <-> Analysis (L-functions)

**Lineage**: Builds on `IsFundDiscriminant`, `QuadraticShapeColorDict`, and `gl1_shape_color_injectivity` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Cubic Reciprocity as GL₁ Shape-Color for Degree 3

**Conjecture**: There exists a "cubic shape-color dictionary" analogous to the quadratic one: each cube-free integer d determines a cubic character χ_d of order 3, and the map d ↦ χ_d is injective on an appropriate class of "fundamental cubic discriminants." The dictionary is governed by the cubic residue symbol in ℤ[ω] where ω = e^{2πi/3}.

**Test**: For the Eisenstein integers ℤ[ω], compute the cubic residue symbol (a/π)₃ for primary primes π of norm ≤ 100. Verify that the cubic reciprocity law holds: (α/β)₃ = (β/α)₃ for coprime primary elements α, β ≡ 2 (mod 3). This is the "self-duality" statement for the cubic dictionary.

**Impact**: Extends the shape-color framework beyond quadratic fields. Cubic reciprocity is much less formalized than quadratic reciprocity, so this would be genuinely novel formalization territory. The cubic case also connects to the theory of elliptic curves with complex multiplication.

**Catalog References**: `Algebra/LanglandsToddlers.lean` (quadratic dictionary), `Cryptography/GL1LanglandsBilinear.lean` (bilinear symbol structure)

**Proof Strategy**: Define the Eisenstein integers ℤ[ω] = ℤ[X]/(X² + X + 1). Define "primary" elements (analogous to positive odd integers in the quadratic case). Define the cubic residue symbol using Euler's criterion: (a/π)₃ = a^{(Nπ-1)/3} mod π. Prove cubic reciprocity as self-duality of the cubic symbol. The main technical challenge is formalizing the ring of Eisenstein integers and its arithmetic.

**Domain Bridges**: Number Theory (cubic reciprocity) <-> Algebra (Eisenstein integers) <-> Cryptography (third-party residue symbols)

**Lineage**: Direct extension of the quadratic shape-color dictionary from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Gauss Sum Phase Distribution

**Conjecture**: For the quadratic character mod p, the argument of the Gauss sum g(χ) satisfies |arg(g(χ))| < π/4 for primes p ≡ 1 (mod 4), and |arg(g(χ)) - π/2| < π/4 for primes p ≡ 3 (mod 4). More precisely, g(χ) = ε·√p where ε is a specific fourth root of χ(-1).

**Test**: Compute the Gauss sum g(χ_p) for all primes p ≤ 500 using the explicit formula g = Σ_{a=1}^{p-1} (a/p)·e^{2πia/p}. Verify that g² = (-1)^{(p-1)/2}·p and check the phase distribution of g. For p ≡ 1 (mod 4), g should be real and positive (equal to √p); for p ≡ 3 (mod 4), g should be purely imaginary (equal to i√p).

**Impact**: The Gauss sum phase is directly connected to the sign of the functional equation of L(s, χ), which determines the parity of the analytic rank. Understanding Gauss sum phases leads to explicit class number formulas and connections to L-functions.

**Catalog References**: `Algebra/LanglandsToddlers.lean` (gauss_sum_sq_quadratic), `Cryptography/GL1LanglandsBilinear.lean`

**Proof Strategy**: Start from the proved g(χ)² = χ(-1)·p. For p ≡ 1 (mod 4), χ(-1) = 1, so g² = p, giving g = ±√p. Determine the sign using the explicit formula. For p ≡ 3 (mod 4), χ(-1) = -1, so g² = -p, giving g = ±i√p. The sign determination requires the theory of Gauss sums over ℤ (not just finite fields).

**Domain Bridges**: Number Theory (Gauss sums) <-> Analysis (L-function functional equations) <-> Physics (quantum walks on ℤ/pℤ)

**Lineage**: Builds directly on `gauss_sum_sq_quadratic` from this cycle.

**Ambition**: extension

---

### Direction 4: Bilinear Symbol Classification

**Conjecture**: Every bilinear symbol σ: ℤ × ℕ → ℤ (in the sense of `BilinearSymbol` from `GL1LanglandsBilinear.lean`) that is periodic in the first argument and whose kernel contains the ideal (N) for some N is determined by a Dirichlet character mod N. Formally: the category of bilinear symbols with conductor N is equivalent to the group of Dirichlet characters mod N.

**Test**: For N = 12, enumerate all bilinear symbols σ with σ(a + 12, b) = σ(a, b) and verify they correspond to the Dirichlet characters mod 12. There are φ(12) = 4 such characters: the trivial character, χ₃, χ₄, and χ₃·χ₄.

**Impact**: This would establish that the `BilinearSymbol` structure from the existing catalog is *exactly* the right abstraction: bilinear symbols are Dirichlet characters in disguise. This unifies the algebraic and analytic perspectives on the GL₁ correspondence.

**Catalog References**: `Cryptography/GL1LanglandsBilinear.lean` (BilinearSymbol definition, jacobiSym_bilinear)

**Proof Strategy**: Define "conductor" of a bilinear symbol as the minimal N such that σ(a + N, b) = σ(a, b). Show that a bilinear symbol with conductor N factors through ℤ/Nℤ. Show that the factored map is a Dirichlet character using multiplicativity and the trichotomy (values in {-1, 0, 1}). The key lemma is that a completely multiplicative function on ℤ/Nℤ with values in {-1, 0, 1} is a quadratic Dirichlet character.

**Domain Bridges**: Algebra (bilinear symbols) <-> Number Theory (Dirichlet characters) <-> Computation (character enumeration)

**Lineage**: Builds on `BilinearSymbol`, `jacobiSym_bilinear`, and `bilinear_agrees_on_small_primes` from `GL1LanglandsBilinear.lean`.

**Ambition**: extension

---

### Direction 5: Modular Forms as GL₂ Colors

**Conjecture**: Define a formal structure `ModularFormColor` capturing weight-k modular forms as "GL₂ colors" and `EllipticCurveShape` capturing elliptic curves over ℚ as "GL₂ shapes." State the modularity theorem (Wiles et al.) as a shape-color bijection at GL₂ level. Verify computationally for the curves y² = x³ - x (conductor 32) and y² = x³ - 1 (conductor 36) that the L-function of the curve matches the L-function of the associated modular form.

**Test**: For the curve E: y² = x³ - x with conductor N = 32, compute a_p(E) = p + 1 - #E(𝔽_p) for primes p ≤ 100. Compare with the Fourier coefficients of the unique weight-2 newform of level 32. They should match.

**Impact**: This would extend the shape-color framework from GL₁ to GL₂, which is the domain of the modularity theorem. Even a formal statement (without proof) would be valuable for structuring future formalization of modularity.

**Catalog References**: `Algebra/LanglandsToddlers.lean`, `Cryptography/GL1LanglandsBilinear.lean`

**Proof Strategy**: Define `EllipticCurveShape` using the Weierstrass equation. Define `ModularFormColor` using q-expansions. State the correspondence as: for each E over ℚ of conductor N, there exists a weight-2 newform f of level N with a_p(f) = a_p(E) for all primes p ∤ N. The proof is Wiles's theorem and is far beyond current formalization — the goal is to state it cleanly and verify instances.

**Domain Bridges**: Number Theory (elliptic curves) <-> Analysis (modular forms) <-> Algebra (Galois representations)

**Lineage**: Natural GL₂ extension of the GL₁ shape-color dictionary from this cycle.

**Ambition**: grand_challenge
