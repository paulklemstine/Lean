# Future Directions

## Synthesis

This research cycle established the foundational algebraic framework for the GL₁ Langlands correspondence by formalizing the *bilinear symbol* abstraction and proving that the Jacobi symbol satisfies it. The central discovery is that quadratic reciprocity is not merely a computational identity but a *self-duality theorem* for the Jacobi pairing, with a correction sign ε(a,b) = (−1)^{(a/2)(b/2)} that is itself symmetric. This perspective — treating the Jacobi symbol as a bilinear form on ℤ × ℕ taking values in {−1, 0, 1} — unifies multiplicativity, reciprocity, and character detection into a single algebraic structure (the `BilinearSymbol` type) and connects naturally to the shape-color dictionary of the Langlands program.

The most promising cross-domain connection is between the `BilinearSymbol` kernel theory (Theorem: the kernel {a | σ(a,b) = 1} is multiplicatively closed) and the Berggren quadratic form invariant from `Cryptography/DiophantineCryptoCore.lean`. Both structures involve multiplicative invariants of bilinear/quadratic forms over ℤ: the Berggren matrices preserve the Lorentzian form x² + y² − z², while the Jacobi kernel preserves the quadratic residue subgroup. A formal bridge between these would connect Pythagorean triple enumeration to prime splitting in quadratic fields. Additionally, the character detection theorems (J(−1, p) = χ₄(p) and J(2, p) = χ₈(p)) provide a direct link to the `prime_one_mod_four_has_sum_two_squares` result in the Pythagorean module.

Direction 3 (Quadratic Form Duality Bridge) has the highest near-term breakthrough potential because it would unify two existing Catalog results through a concrete algebraic bridge. Direction 1 (Higher Reciprocity) has the highest long-term impact but requires substantially more infrastructure.

---

### Direction 1: Cubic and Quartic Reciprocity via Higher-Order Bilinear Symbols

**Conjecture**: The `BilinearSymbol` framework can be generalized to *n-linear symbols* σ : ℤ[ζₙ] → ℕ → ℤ[ζₙ] taking values in n-th roots of unity ∪ {0}, and the cubic reciprocity law of Eisenstein and the quartic reciprocity law of Gauss and Eisenstein are self-duality theorems for the cubic and quartic residue symbols respectively, with explicit correction signs computable from the arguments.

**Test**: Define a `CubicSymbol` structure over ℤ[ω] (where ω = e^{2πi/3}) with values in {0, 1, ω, ω²}. Verify computationally that for primary primes π, π' ∈ ℤ[ω] with Norm(π), Norm(π') ≤ 100, the cubic residue symbol (π/π')₃ satisfies a self-duality law (π/π')₃ = ε₃(π,π') · (π'/π)₃ for some explicit ε₃. This can be tested with #eval in Lean by implementing the cubic residue symbol over Gaussian integers modulo small primes.

**Impact**: If true, this would establish a uniform algebraic framework for all classical reciprocity laws, suggesting that the self-duality of bilinear symbols is the common algebraic core. If false (i.e., if the correction sign for cubic reciprocity cannot be expressed as a symmetric function), this would reveal a fundamental asymmetry in higher reciprocity that distinguishes it from quadratic reciprocity.

**Catalog References**: `Cryptography/GL1LanglandsBilinear.lean` (BilinearSymbol, ReciprocityData, qrCorrectionSign)

**Proof Strategy**: (1) Define `GaussianInt` and `EisensteinInt` types if not in Mathlib (check `ZMod`, `GaussInt`). (2) Define `HigherSymbol n` generalizing `BilinearSymbol` to n-th roots. (3) Prove the cubic reciprocity law as a `ReciprocityData` instance for n=3. (4) The key lemma is that the correction sign for cubic reciprocity involves the "primary" normalization of Eisenstein integers.

**Domain Bridges**: Number Theory (reciprocity laws) ↔ Algebraic Geometry (étale cohomology of cyclotomic fields) ↔ Cryptography (higher-residue-based primitives)

**Lineage**: Builds on BilinearSymbol and ReciprocityData from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Bilinear Symbol Kernel as Index-2 Subgroup

**Conjecture**: For any non-degenerate bilinear symbol σ and any odd prime p, the kernel {a ∈ (ℤ/pℤ)× | σ(a, p) = 1} is a subgroup of index exactly 2 in (ℤ/pℤ)×. Moreover, this subgroup is the unique subgroup of index 2, and it equals the set of quadratic residues modulo p.

**Test**: For the Jacobi symbol, verify that |ker(J(·, p))| = (p−1)/2 for all primes p ≤ 1000. This can be done with `#eval` by counting elements. The deeper test is proving that the kernel is *closed under inverses* (which, combined with multiplication closure from this cycle, establishes it as a subgroup).

**Impact**: This would complete the algebraic characterization of quadratic residues through the bilinear symbol framework: QR(p) is not defined as "squares mod p" but as "the kernel of the canonical bilinear symbol." This reversal of perspective — defining residues through the symbol rather than the other way around — is the conceptual foundation of class field theory.

**Catalog References**: `Cryptography/GL1LanglandsBilinear.lean` (bilinear_symbol_kernel_mul_closed, bilinear_symbol_kernel_one)

**Proof Strategy**: (1) Prove the kernel is closed under inverses: if σ(a, p) = 1 and gcd(a, p) = 1, then σ(a⁻¹ mod p, p) = 1. Key insight: σ(a, p) · σ(a⁻¹, p) = σ(a · a⁻¹, p) = σ(1, p) = 1, so σ(a⁻¹, p) = 1. (2) Show the kernel has index ≤ 2 by the value constraint: σ maps to {−1, 1} on units, so the kernel is the preimage of {1}. (3) Show the index is exactly 2 by finding a non-residue (use the existence of primitive roots).

**Domain Bridges**: Abstract Algebra (subgroup theory) ↔ Number Theory (quadratic residues) ↔ Cryptography (quadratic residuosity assumption)

**Lineage**: Directly extends bilinear_symbol_kernel_mul_closed and bilinear_symbol_kernel_one from this cycle.

**Ambition**: extension

---

### Direction 3: Quadratic Form Duality Bridge — Berggren Meets Jacobi

**Conjecture**: The Berggren matrices (which preserve the Pythagorean quadratic form x² + y² = z²) and the Jacobi symbol (which detects quadratic residues) are connected by a formal duality: a prime p is representable as a sum of two squares (i.e., appears as the hypotenuse of a primitive Pythagorean triple) if and only if J(−1, p) = 1. Moreover, the Berggren tree enumeration of Pythagorean triples with hypotenuse p corresponds to the splitting of p in ℤ[i], which is detected by χ₄(p) = J(−1, p).

**Test**: (1) Verify computationally for primes p ≤ 10000 that p = a² + b² for some a, b ∈ ℕ if and only if J(−1, p) = 1. (2) For each such prime, verify that the number of representations equals 2 · (number of Berggren tree leaves with hypotenuse p). (3) Formalize the implication: `neg_one_shape_detector` + Fermat's theorem on sums of two squares gives the bridge.

**Impact**: This would create a concrete, formalized bridge between two existing Catalog modules (Cryptography/Berggren and Cryptography/GL1Langlands), demonstrating that the Berggren tree structure and the Jacobi symbol are two views of the same underlying arithmetic. The bridge would also connect to the `prime_one_mod_four_has_sum_two_squares` theorem already in the Pythagorean module.

**Catalog References**: `Cryptography/DiophantineCryptoCore.lean` (berggren_quadratic_form_invariant), `Cryptography/GL1LanglandsBilinear.lean` (neg_one_shape_detector, jacobi_neg_one_eq_chi4), `Pythagorean/TropicalBerggrenZeta.lean` (prime_one_mod_four_has_sum_two_squares)

**Proof Strategy**: (1) State and prove: `p.Prime → p ≠ 2 → (∃ a b : ℕ, a² + b² = p ↔ J(−1, p) = 1)` using neg_one_shape_detector and Fermat's two-square theorem. (2) Connect to Berggren by showing that if p = a² + b² with gcd(a,b) = 1, then (a²−b², 2ab, p) is a primitive Pythagorean triple, hence lies in the Berggren tree. (3) The key lemma is that the Berggren tree contains all primitive triples (berggren_normal_form_exists_unique from Cryptography/Freeness.lean).

**Domain Bridges**: Number Theory (Jacobi symbol, quadratic residues) ↔ Pythagorean Geometry (Berggren tree, primitive triples) ↔ Cryptography (quadratic form invariants, lattice problems)

**Lineage**: Builds on neg_one_shape_detector and jacobi_neg_one_eq_chi4 from this cycle, plus berggren_quadratic_form_invariant from prior cycles.

**Ambition**: extension

---

### Direction 4: L-function Euler Product from Bilinear Symbols

**Conjecture**: For any bilinear symbol σ and fixed discriminant d, the formal Euler product L(s, σ_d) = ∏_p (1 − σ(d, p) · p^{−s})^{−1} converges absolutely for Re(s) > 1 and defines the Dirichlet L-function L(s, χ_d). The non-vanishing L(1, χ_d) ≠ 0 is equivalent to the infinitude of primes splitting in ℚ(√d), which is a consequence of Dirichlet's theorem on primes in arithmetic progressions.

**Test**: (1) Compute the partial Euler product ∏_{p ≤ N} (1 − J(d, p) · p^{−s})^{−1} for d ∈ {−1, −3, 5, −7} and s = 1.5, for N = 100, 1000, 10000, and verify convergence to the known values of L(1.5, χ_d). (2) Verify numerically that L(1, χ_d) ≠ 0 for |d| ≤ 100.

**Impact**: This would connect the algebraic bilinear symbol framework to analytic number theory, establishing that bilinear symbols naturally generate L-functions. The non-vanishing at s=1 is the analytic input to Dirichlet's theorem, and formalizing even a fragment of this connection would bridge algebra and analysis within the Catalog.

**Catalog References**: `Cryptography/GL1LanglandsBilinear.lean` (jacobiSym_bilinear, ShapeColorPairing)

**Proof Strategy**: (1) Define the formal Dirichlet series L(s, σ_d) = Σ σ(d,n)/n^s as a function ℝ → ℝ (or ℂ → ℂ). (2) Prove convergence for s > 1 using comparison with ζ(s). (3) Prove the Euler product factorization using right multiplicativity of σ. (4) The key challenge is connecting the formal series to Mathlib's existing analytic number theory infrastructure (if any).

**Domain Bridges**: Algebra (bilinear symbols) ↔ Analysis (L-functions, Euler products) ↔ Number Theory (Dirichlet's theorem, prime distribution)

**Lineage**: Builds on jacobiSym_bilinear and ShapeColorPairing from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Computational Classification of Small Bilinear Symbols

**Conjecture**: Up to equivalence (permutation of the ℤ argument modulo b), there are exactly φ(b)/2 distinct non-degenerate bilinear symbols σ : ℤ → {b} → {−1, 0, 1} for each odd prime b, corresponding to the quadratic characters modulo b. For composite odd b = p₁^{e₁}···pₖ^{eₖ}, the number of non-degenerate bilinear symbols is ∏ φ(pᵢ^{eᵢ})/2.

**Test**: Enumerate all functions f : ℤ/bℤ → {−1, 0, 1} satisfying f(a₁a₂) = f(a₁)f(a₂) for b ∈ {3, 5, 7, 11, 13, 15, 21}. Count the non-trivial ones and compare with the conjectured formula. This is a finite computation that can be done with #eval.

**Impact**: If confirmed, this provides a complete classification of bilinear symbols at fixed second argument, proving that the Jacobi symbol (and its twists by units) exhausts all possibilities. This is a formal analog of the classification of quadratic Dirichlet characters.

**Catalog References**: `Cryptography/GL1LanglandsBilinear.lean` (BilinearSymbol, bilinear_agrees_on_small_primes)

**Proof Strategy**: (1) For a prime p, any multiplicative function f : (ℤ/pℤ)× → {±1} is a group homomorphism to {±1}. (2) The number of such homomorphisms equals the number of index-2 subgroups of (ℤ/pℤ)×. (3) Since (ℤ/pℤ)× is cyclic of order p−1, it has exactly one subgroup of index 2 (when p−1 is even, which is always for p > 2). (4) Hence there is exactly one non-trivial quadratic character mod p, namely the Legendre symbol.

**Domain Bridges**: Group Theory (character classification) ↔ Number Theory (Dirichlet characters) ↔ Combinatorics (enumeration)

**Lineage**: Builds on BilinearSymbol and the classification conjecture from this cycle.

**Ambition**: extension
