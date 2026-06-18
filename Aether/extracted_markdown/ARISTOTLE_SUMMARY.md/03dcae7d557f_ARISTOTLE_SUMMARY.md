# Summary of changes for run 4fb5980a-e96d-4310-85e7-7bb882db20d4
# Braid Group Invariants and the BraidSignature

## Deliverables

### Lean 4 file: `Catalog/Physics/BraidInvariant/BraidInvariant.lean`
316 lines, **0 sorry's**, all 21 lemmas/theorems fully machine-verified. Builds cleanly with no warnings. All axioms are standard (propext, Classical.choice, Quot.sound).

### Novel mathematical structure: `BraidSignature`
The `BraidSignature n` packages the writhe (algebraic crossing number, ℤ) and strand permutation (S_{n+2}) into a combined invariant for the braid group B_{n+2}. We prove it is a well-defined braid invariant and that its components are *independent* — strictly stronger than either alone.

### 5 non-trivial proved theorems (PEGB documented in-file):

1. **`writhe_braidEquiv`** — The writhe is a braid invariant: equivalent braid words have equal exponent sums. This realizes the abelianization homomorphism B_n → ℤ.

2. **`wordPerm_braidEquiv`** — The strand permutation is a braid invariant: equivalent braid words induce the same permutation in S_n. This realizes the canonical surjection B_n ↠ S_n.

3. **`genPerm_braid_relation`** — Adjacent transpositions satisfy the Yang-Baxter (braid) equation: swap(i,i+1) · swap(i+1,i+2) · swap(i,i+1) = swap(i+1,i+2) · swap(i,i+1) · swap(i+1,i+2). This is the Coxeter relation of type A.

4. **`genPerm_far_commute`** — Non-adjacent transpositions commute: swap(i,i+1) · swap(j,j+1) = swap(j,j+1) · swap(i,i+1) when |i−j| ≥ 2.

5. **`exists_same_writhe_diff_perm` / `exists_same_perm_diff_writhe`** — Independence: writhe does not determine permutation (witnessed by [σ₁] vs [σ₂]), and permutation does not determine writhe (witnessed by [σ₁,σ₁] vs []). This proves the BraidSignature is strictly stronger than either component.

### Supporting infrastructure (all proved):
- `BraidGen`, `BraidWord`, `BraidRelStep`, `BraidEquiv` — Full Artin presentation of B_{n+2}
- `writhe_append`, `wordPerm_append` — Additivity/multiplicativity under concatenation
- `genPerm_mul_self` — Self-inverse property of transpositions
- `braidSignature_braidEquiv` — Combined signature invariance
- Concrete examples: trivial braid (writhe=0), trefoil σ₁³ (writhe=3), figure-eight (writhe=0)

### Research directions: `Catalog/Physics/BraidInvariant/FUTURE_DIRECTIONS.md`
5 falsifiable research directions with "key insight" and "why now" for each:
1. Burau representation faithfulness (open for n=4)
2. Dehornoy order and braid decidability
3. Lawrence-Krammer representation (braid linearity)
4. Garside normal form (verified decision procedure)
5. Jones polynomial via Temperley-Lieb traces (cross-connection to existing `BraidingUniversality.lean`)

### Build system
Added `Catalog` lean_lib entry to `lakefile.toml` to enable building files in the `Catalog/` directory.