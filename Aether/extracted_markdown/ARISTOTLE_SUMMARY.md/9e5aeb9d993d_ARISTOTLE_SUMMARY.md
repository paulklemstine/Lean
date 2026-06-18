# Summary of changes for run 3ee5aad7-6156-4293-acb6-c77ff54c9c26
## Hadamard Matrix Theory — Formalized in Lean 4

### Deliverables

**`Hadamard/Basic.lean`** — A complete, sorry-free formalization of Hadamard matrix theory (≈230 lines), containing:

1. **Definition**: `IsHadamard H` — a structure requiring ±1 entries and orthogonality (`H * Hᵀ = n • I`).

2. **Four main theorems (all fully proved, 0 sorries)**:

   - **`isHadamard_kronecker`** — The Kronecker (tensor) product of two Hadamard matrices is Hadamard. Uses the mixed-product property `(A⊗B)(C⊗D) = (AC)⊗(BD)` and `(m•I)⊗(n•I) = mn•I`.
   
   - **`hadamard_exists_pow_two`** — Hadamard matrices exist for every power of 2 (Sylvester's 1867 construction). Proved by induction: base case is 1×1 identity, inductive step tensors with H₂ = [[1,1],[1,−1]].
   
   - **`hadamard_order_even`** — If a Hadamard matrix of order n ≥ 2 exists, then 2 ∣ n. Uses the fact that the inner product of two ±1 vectors being zero forces even length.
   
   - **`hadamard_order_div_four`** — If a Hadamard matrix of order n > 2 exists, then 4 ∣ n. The classical necessary condition for the Hadamard conjecture. Uses a WLOG argument (column-negation to normalize the first row to all 1s) followed by a mod-4 counting argument on three rows.

3. **Supporting lemmas**: `IsHadamard.entry_sq`, `IsHadamard.entry_abs`, `IsHadamard.diag_eq`, `IsHadamard.off_diag_eq`, `IsHadamard.inner_product_zero`, `IsHadamard.row_norm_sq` — all fully proved.

4. **Axiom check**: All theorems depend only on `propext`, `Classical.choice`, and `Quot.sound`.

**`FUTURE_DIRECTIONS.md`** — Five research directions: Paley construction via quadratic residues, Hadamard determinant bound, equivalence classes, Reed-Muller code connection, and Williamson's construction for pushing the formal frontier toward the smallest open case (n = 668).