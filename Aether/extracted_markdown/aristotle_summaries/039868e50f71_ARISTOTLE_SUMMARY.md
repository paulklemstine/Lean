# Summary of changes for run 189f1cff-173a-4dac-ba21-a64620426d88
# Cyclotomic-Alexander Bridge: Deep Extensions

## Summary

This research cycle deepened the known connection between Alexander polynomials of torus knots T(2,p) and cyclotomic polynomials Φ_{2p}, producing **13 fully verified Lean 4 theorems** with zero `sorry` statements, plus all required deliverables.

## Key Mathematical Results (Lean 4 Proofs)

All proofs are in `Catalog/Pythagorean/CyclotomicAlexanderBridge.lean` (235 lines, compiles cleanly):

1. **Negation Bridge** (`cyclotomic_negation_bridge`): For odd prime p, Φ_{2p}(X) = Φ_p(−X). This reveals *why* the Alexander polynomial equals the cyclotomic polynomial — the alternating signs in the Alexander polynomial correspond to composing the prime cyclotomic polynomial with the negation map X ↦ −X.

2. **Alexander = Cyclotomic Composition** (`alexander_eq_cyclotomic_comp_neg`): A_p(X) = Φ_p(−X), the compositional form of the bridge.

3. **Irreducibility Transfer** (`alexander_irreducible`): The Alexander polynomial of T(2,p) is irreducible over ℤ, inherited from cyclotomic irreducibility via the bridge. This gives a number-theoretic proof that torus knots T(2,p) are "algebraically prime."

4. **Fox Normalization** (`alexander_fox_normalization`): A_p(1) = 1 for odd prime p.

5. **Knot Determinant** (`alexander_determinant`): A_n(−1) = n, giving det(T(2,n)) = n.

6. **Degree-Genus Bridge** (`alexander_degree_eq_totient`, `seifert_genus_eq`): deg(A_p) = φ(2p) and genus(T(2,p)) = (p−1)/2, connecting Seifert genus to Euler's totient.

7. **Totient Identity** (`totient_two_mul_odd_prime`): φ(2p) = p−1 for odd prime p.

8. **Cyclotomic Product Decomposition** (`cyclotomic_product_Xn_plus_one`): X^n + 1 = ∏_{d|n} Φ_{2d} for all odd n > 0, generalizing the bridge from prime to composite parameters.

9. **Galois-Knot Bridge** (`alexander_degree_eq_galois_order`): deg(A_p) = |Gal(ℚ(ζ_{2p})/ℚ)|, identifying a knot invariant with a Galois group order.

10. **Fundamental Identity** (`alexander_fundamental`): A_n(X)·(X+1) = X^n + 1 for odd n.

11. **Monicity** (`alexander_monic`): A_n has leading coefficient 1 for odd n > 1.

12. **Arithmetic Lemma** (`two_mul_prime_not_prime_pow`): 2p is not a prime power for odd prime p.

## Deliverables

- **Lean proofs**: `Catalog/Pythagorean/CyclotomicAlexanderBridge.lean` — 13 theorems, 0 sorries
- **Article**: `Catalog/Pythagorean/ARTICLE.md` — "The Knot That Knew It Was a Number" (popular science)
- **Research paper**: `Catalog/Pythagorean/RESEARCH_PAPER.md` — full technical paper with PEGB analysis
- **Future directions**: `Catalog/Pythagorean/FUTURE_DIRECTIONS.md` — 5 concrete research directions
- **Python demos**: `Catalog/Pythagorean/demo.py` — numerical demonstrations
- **Algorithms**: `Catalog/Pythagorean/algorithms.py` — type-hinted implementations
- **Package**: `Catalog/Pythagorean/PACKAGE.json` — bundled artifacts with 3 interactive HTML widgets

## Note on Build Configuration

Added `srcDir = "Catalog"` to `lakefile.toml` so that `lake build` correctly locates source files in the `Catalog/` directory. This was necessary because the lakefile's lean_lib entries reference modules like `Pythagorean.+` but files reside under `Catalog/Pythagorean/`.