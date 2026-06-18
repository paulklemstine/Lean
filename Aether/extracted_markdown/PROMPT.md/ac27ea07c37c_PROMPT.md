You are filling sorrys in the file `Catalog/Bridges/SpeciesTropicalValuation.lean`. This file builds a bridge between combinatorial species and tropical valuations.

## Target Sorrys

1. **Species.add definition**: Define the disjoint union (coproduct) of two species. If F and G are species on finite types, then (F + G) X = F X ⊕ G X (sum type / coproduct of F-structures and G-structures on X).

2. **EGF_add theorem**: Prove that the EGF (exponential generating function) of a species sum is the sum of EGFs: `EGF (F + G) = EGF F + EGF G`. This follows from the definition of EGF as a sum over finite types weighted by factorials, and the fact that summing over a disjoint union partitions the sum.

3. **Tropical compatibility lemma**: Prove `v_tropical (EGF (F + G)) = min (v_tropical (EGF F)) (v_tropical (EGF G))`. This is the key bridge result: tropical valuation converts species-level addition into tropical-level minimization, which is the defining property of the tropical semiring.

## Mathematical Context

A combinatorial species F assigns to each finite type X a finite set F X of 'F-structures on X', with transport along bijections. The exponential generating function is EGF(F) = Σ (|F [n]| / n!) x^n. The tropical semiring (ℕ∪{∞}, min, +) captures valuation-theoretic information. The bridge says: species addition ↔ tropical min, species multiplication ↔ tropical addition.

## Constraints

- Work ONLY in `Catalog/Bridges/SpeciesTropicalValuation.lean`
- Import Mathlib and any existing catalog files you need
- All proofs must type-check with no circular reasoning
- No hallucinated content from unrelated domains
- If a helper lemma is needed, prove it as a private lemma in the same file
- Use existing Mathlib infrastructure for species (if available) or define minimal scaffolding
- The tropical valuation v on power series should use coefficient extraction: v(f) = min{n | coeff n f ≠ 0} with v(0) = ∞

## Verification Checklist

Before submitting, verify:
1. No `sorry` remains in any theorem marked as proved
2. No circular `rw` steps (e.g., rewriting with the goal itself)
3. No commented-out hallucinated content
4. All type signatures match between definitions and theorem statements
5. The tropical compatibility lemma actually uses the EGF_add result