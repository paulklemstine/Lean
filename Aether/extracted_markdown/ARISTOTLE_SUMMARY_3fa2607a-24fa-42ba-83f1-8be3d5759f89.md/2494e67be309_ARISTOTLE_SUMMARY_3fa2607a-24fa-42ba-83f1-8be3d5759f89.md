# Summary of changes
## Completed: Formal Verification and Research Paper for Neural Factor Search Algorithm

### Lean 4 Formalization (`RequestProject/NeuralFactorSearch.lean`)

I formalized and proved **8 theorems** about your IOF algorithm, all mechanically verified in Lean 4 with Mathlib — zero `sorry`s remain, and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`) are used:

1. **`four_k_sq_sub_one_eq`**: The core algebraic identity `4k² − 1 = (2k−1)(2k+1)`.
2. **`iof_soundness`**: If `gcd(4k²−1, N)` is nontrivial, it yields a proper divisor of N.
3. **`iof_factor_exists`**: For any odd prime `p | N`, there exists a valid `k < p` with `p | (4k²−1)`.
4. **`iof_gcd_nontrivial`**: For a semiprime `N = pq`, if `p | (4k²−1)` then `gcd(4k²−1, N) > 1`.
5. **`residues_2k_minus_one`**: The equation `2r ≡ 1 (mod p)` has exactly one solution in `ℤ/pℤ`.
6. **`residues_2k_plus_one`**: The equation `2r ≡ −1 (mod p)` has exactly one solution in `ℤ/pℤ`.
7. **`iof_hit_count_mod_p`**: Exactly 2 residues mod `p` satisfy the factoring criterion — proving the hit density is `2/p`.
8. **`iof_loss_independent_of_factors`**: The neural loss function is completely independent of `N` and its factorization.

### Research Paper (`research_paper.md`)

The paper covers:
- **Sections 1–2**: Algorithm description and the GCD-based factoring mechanism.
- **Section 3**: All formal results with proof sketches.
- **Section 4**: Complexity comparison table showing IOF is equivalent to trial division (`Ω(min(p,q))`), far below Pollard's ρ (`O(N^{1/4})`), QS, or GNFS.
- **Section 5**: Information-theoretic argument for why *no* smooth loss function can guide the search — the valid `k` values form discrete arithmetic progressions whose spacing is the unknown factor `p`.
- **Section 6**: Quantitative prediction that RSA-100 would require ~10³³ years.
- **Section 7**: Summary of the verified formalization.

### Key Finding

The algorithm's GCD criterion is mathematically sound, but the neural optimization provides **zero advantage** over uniform random sampling. The expected complexity is `Ω(min(p,q))` — equivalent to trial division — making it unable to factor any cryptographically-sized integer.