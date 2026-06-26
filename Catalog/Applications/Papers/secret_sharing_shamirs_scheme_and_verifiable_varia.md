# Theorem Trace — Secret Sharing: Shamir's Scheme and Verifiable Variants

Internal anti-hallucination map. Every result discussed in `ARTICLE.md` and
`RESEARCH_PAPER.md` maps to an actual Lean name from the Phase A output. No
result is stated in the prose that is not listed here.

## `Catalog/Cryptography/ShamirSecretSharing.lean`

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `shamir_reconstruction` | Two polynomials of degree `< t` agreeing on a finset `s` with `#s = t` are equal (threshold = degree + 1). | §"Recovering the secret" | Thm 1 |
| `shamir_secret_recovered` | Under the reconstruction hypotheses, `f.eval 0 = g.eval 0`. | §"Recovering the secret" | Cor 1 |
| `shamir_privacy` | For every candidate secret `c`, there is a **unique** degree-`< t` polynomial matching the `t-1` observed shares with `f.eval 0 = c`. | §"Zero knowledge below threshold" | Thm 2 |
| `shamir_insufficient` | Two distinct secrets `c₁ ≠ c₂` are both consistent with the same `t-1` shares via distinct polynomials. | §"Zero knowledge below threshold" | Cor 2 |

## `Catalog/Cryptography/FeldmanVSS.lean`

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `feldmanCommit` (def) | `Cⱼ = (f.coeff j)·g`. | §"Catching a cheating dealer" | Def 4 |
| `FeldmanVerifies` (def) | `s·g = ∑_{j<t} xʲ·Cⱼ`. | §"Catching a cheating dealer" | Def 5 |
| `feldman_commitment_eval` | `∑_{j<t} xʲ·feldmanCommit g f j = (f.eval x)·g`. | §"Catching a cheating dealer" | Thm 3 |
| `feldman_complete` | Honest share `f.eval x` always verifies. | §"Catching a cheating dealer" | Cor 3 |
| `feldman_verify_iff` | With `g ≠ 0`, `s` verifies iff `s = f.eval x`. | §"Catching a cheating dealer" | Thm 4 |
| `feldman_catches_cheater` | Any `s ≠ f.eval x` is rejected. | §"Catching a cheating dealer" | Cor 4 |
| `feldman_binding` | Same commitments on `range t` ⇒ equal polynomials (binding). | §"Catching a cheating dealer" | Thm 5 |

## `Catalog/Cryptography/PedersenVSS.lean`

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `pedersenCommit` (def) | `Cⱼ = (f.coeff j)·g + (f'.coeff j)·h`. | §"Hiding everything, perfectly" | Def 6 |
| `PedersenVerifies` (def) | `s·g + s'·h = ∑_{j<t} xʲ·Cⱼ`. | §"Hiding everything, perfectly" | Def 7 |
| `pedersen_commitment_eval` | RHS `= (f.eval x)·g + (f'.eval x)·h`. | §"Hiding everything, perfectly" | Thm 6 |
| `pedersen_complete` | Honest pair `(f.eval x, f'.eval x)` verifies. | §"Hiding everything, perfectly" | Cor 5 |
| `pedersen_commit_add` | Commitments add coefficient-wise. | §"Hiding everything, perfectly" | Thm 7 |
| `pedersen_perfect_hiding` | With `h ≠ 0`, every `f` admits a blinding `f'` reproducing any commitment vector `C` on `range t`. | §"Hiding everything, perfectly" | Thm 8 |
| `pedersen_equivocation` | Any `f₁, f₂` can share the same commitment vector via suitable blindings. | §"Hiding everything, perfectly" | Cor 6 |

## `Catalog/Cryptography/ShamirLagrangeReconstruction.lean`

| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `lagrangeCoeff` (def) | `(Lagrange.basis s v i).eval 0` — node-only reconstruction weight. | §"Recovering the secret" | Def 3 |
| `shamir_reconstruct_at` | For `f.degree < #s`, `f.eval z = ∑ i∈s, f.eval (v i)·(Lagrange.basis s v i).eval z`. | §"Recovering the secret" | Thm 9 |
| `shamir_explicit_reconstruction` | `f.eval 0 = ∑ i∈s, f.eval (v i)·lagrangeCoeff s v i`. | §"Recovering the secret" | Thm 10 |
| `sum_lagrangeCoeff_eq_one` | `∑ i∈s, lagrangeCoeff s v i = 1` (nonempty `s`). | §"Recovering the secret" | Lem 1 |
| `shamir_reconstruct_additive` | Reconstruction is additive in the shares (MPC addition). | §"Adding secrets without revealing them" | Thm 11 |
| `shamir_reconstruct_mul` | Product secret recovered from share products when `(f*g).degree < #s` (BGW core). | §"Adding secrets without revealing them" | Thm 12 |
