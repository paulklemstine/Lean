# Summary of changes for run 515a8c97-46dc-4ee1-a803-52073aeb5f89
# Braid Group Invariants — Formal Verification

## Deliverables

### Lean 4 File: `Novelty/BraidInvariants/BraidGroup.lean` (also in `Catalog/Novelty/BraidInvariants/`)
- **394 lines**, **0 sorries**, clean build, standard axioms only (propext, Classical.choice, Quot.sound)

### Novel Structure: `BraidInvariant n α`
A structure axiomatizing functions from braid words to a target type that are constant on braid equivalence classes. It requires invariance under the three generating relations of the braid group B_n (cancellation, braid relation, far commutativity). This provides a compositional framework for constructing and verifying braid/knot invariants — one proves three axioms and obtains full invariance.

### Core Definitions
- `BraidGen n` — Signed generators (σ_i, σ_i⁻¹) of the braid group B_n
- `BraidWord n` — Braid words as lists of generators
- `expSum` — Exponent sum (abelianization B_n → ℤ)
- `wordPerm` — Permutation representation B_n → S_n
- `wordInv` — Word inversion (group inverse in the free group)

### 5 Main Theorems (all with PEGB structure)

1. **`wordPerm_braidRel`** — The permutation map respects the Yang–Baxter/braid relation σ_iσ_{i+1}σ_i = σ_{i+1}σ_iσ_{i+1}. Both sides induce the transposition swap(i, i+2). Proved via `swap_braid_rel` using `Equiv.swap_mul_swap_mul_swap`.

2. **`wordPerm_farComm`** — The permutation map respects far commutativity. When |i−j| ≥ 2, swaps of disjoint strand pairs commute. Proved via disjointness of the underlying transpositions.

3. **`wordPerm_cancel`** — Cancellation σ_iσ_i⁻¹ preserves the permutation (swap is self-inverse). Uses `Equiv.swap_mul_self`.

4. **`expSum_wordInv`** — The exponent sum negates under word inversion, reflecting that B_n → ℤ is a group homomorphism.

5. **`permBraidInvariant`** — The permutation map assembles into a `BraidInvariant` instance, witnessing that `wordPerm` descends to a well-defined homomorphism B_n → S_n.

### Additional Results (10 more proved theorems)
- `expSum_append`, `wordPerm_append` — Homomorphism properties
- `expSum_cancel`, `expSum_braidRel` — Exponent sum invariance
- `wordPerm_cancel'` — Reverse cancellation
- `expSum_self_inv` — A word composed with its inverse has zero exponent sum
- `wordInv_wordInv` — Word inversion is an involution
- `braidGen_empty_of_lt_two`, `braidGen_two_strand` — Boundary cases
- `B2_perm_determined` — On 2 strands, the permutation is completely determined by parity of exponent sum
- `BraidInvariant.prod`, `BraidInvariant.map` — Product and post-composition of invariants

### FUTURE_DIRECTIONS.md
Five research directions: Burau representation, Lawrence–Krammer–Bigelow representation, Dehornoy ordering, knot invariants via braid closure, and Garside normal forms — each with key insight, justification, and falsifiable prediction.