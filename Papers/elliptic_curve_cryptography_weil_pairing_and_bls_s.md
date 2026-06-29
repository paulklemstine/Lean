# Theorem Trace (internal anti-hallucination ledger)

Every prose claim in `ARTICLE.md` and `RESEARCH_PAPER.md` must map to one of the
Lean declarations below. No theorem outside this list may be stated as a result.

Source files:
- `Catalog/Cryptography/WeilPairingBLS.lean`
- `Catalog/Cryptography/WeilPairingMOV.lean` (Phase A `NEW_FILE`)

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `Pairing` | structure | `e : G → G → T` with `add_left`, `add_right` biadditivity axioms | "the bilinear bridge" section | Def. 1 |
| `Pairing.map_one_left` | thm | `e 0 q = 1` | edge-rules paragraph | Lemma 2 |
| `Pairing.map_one_right` | thm | `e p 0 = 1` | edge-rules paragraph | Lemma 2 |
| `Pairing.pairing_nsmul_left` | thm | `e (n • p) q = (e p q)^n` | "sliding the secret" | Lemma 3 |
| `Pairing.pairing_nsmul_right` | thm | `e p (n • q) = (e p q)^n` | "sliding the secret" | Lemma 3 |
| `Pairing.pairing_bilinear_nsmul` | thm | `e (a • p) (b • q) = (e p q)^(a*b)` | "sliding the secret" | Lemma 4 |
| `Pairing.pairing_sum_left` | thm | `e (∑ f i) q = ∏ e (f i) q` | aggregation engine | Lemma 5 |
| `Pairing.bls_verify_correct` | thm | `e (x • H) g = e H (x • g)` | main theorem (plain) | Thm 6 |
| `Pairing.bls_aggregate_correct` | thm | `e (∑ skᵢ • Hᵢ) g = ∏ e (Hᵢ) (skᵢ • g)` | aggregation main | Thm 7 |
| `Pairing.map_neg_left` | thm | `e (-p) q = (e p q)⁻¹` | inverse remark | Lemma 8 |
| `Pairing.pairing_zsmul_left` | thm | `e (n • p) q = (e p q)^n` for `n : ℤ` | inverse remark | Lemma 8 |
| `Pairing.pairing_left_injective` | thm | nondegeneracy ⇒ separation of points | binding section | Thm 9 |
| `Pairing.mov_map` | thm | `e (x • g) g = (e g g)^x` | MOV section | Thm 10 |
| `Pairing.mov_reduction` | thm | `e (a•g) g = e (b•g) g ↔ a ≡ b [MOD orderOf (e g g)]` | MOV section | Thm 11 |
| `Pairing.mov_recovers_dlog` | thm | `n ≤ orderOf(e g g)`, `a,b<n`, equal pairings ⇒ `a=b` | MOV section | Thm 12 |
| `Pairing.homLeft` / `homRight` | def | `e(·,q)`, `e(p,·)` as `G →+ Additive T` | structure remark | Def. 13 |
| `Pairing.nondegenerate_iff_char_injective` | thm | left-nondegeneracy ↔ injectivity of `p ↦ e(p,·)` | binding section | Thm 14 |
| `Pairing.AlternatingPairing` | structure | `Pairing` + `alt : e p p = 1` | Weil signature | Def. 15 |
| `Pairing.AlternatingPairing.mul_swap_eq_one` | thm | `e p q * e q p = 1` | antisymmetry | Thm 16 |
| `Pairing.AlternatingPairing.swap_eq_inv` | thm | `e q p = (e p q)⁻¹` | antisymmetry | Thm 16 |
