# Computational Evidence — Round 43 no-decoupling

Exploratory script (Python, not formally verified; the formal statements are in
`Catalog/Novelty/QSNoDecouplingTheorem.lean`). Setup: semiprime `N` of the stated bit size,
factor-base bound `B = 2000` (303 primes), sieve interval `M = 1000`, four Silverman forms
`A = q²`, `b² ≡ N (mod A)`, `f(x) = A x² + 2b x + (b² − N)/A` (every form checked to have
discriminant `4N`). "multipoly_cols" = fraction of primes `≤ B` dividing at least one value
`f(x)`, `|x| ≤ M`, over all four forms.

| bits | N | split fraction (single poly) | multi-poly column fraction | non-split columns | two unrelated discriminants | `B²M / (0.707√N)` |
|---|---|---|---|---|---|---|
| 30 | 303574303 | 0.429 | 0.429 | 0 | 0.244 | 324670 |
| 41 | 1078527772867 | 0.472 | 0.472 | 0 | 0.218 | 5447 |
| 42 | 1779335612009 | 0.502 | 0.502 | 0 | 0.248 | 4241 |

Observations:
1. **Counterexample hunt** for "a Silverman column outside the split set": 0 found (all three sizes),
   as the proved theorem `family_support_subset_admissible` requires.
2. The multi-poly column set **equals** the split set exactly (not just contained), matching
   `QForm.exists_dvd_eval_iff`: every odd split prime not dividing `A` is realised.
3. The `≈1/4` fraction appears only for two **unrelated** discriminants (0.218–0.248), the
   construction the corrected #446 confused with Silverman's.
4. Gate ratio: at 41–42 bits with `B = 2000, M = 1000` the gate `B²M ≲ 0.707√N` fails by
   ~`4·10³`; the formal bound `gate_fails_at_42_bits` (`B, M ≥ 1000`) gives `> 600`.
5. Boundary: for the cubic `x³ − 2`, `5 ∣ 3³ − 2` while `2` is a non-residue mod 5
   (`cubic_breaks_split_constraint`).

No OEIS sequence is relevant (the objects are split-prime densities, ≈ 1/2 by Chebotarev).
