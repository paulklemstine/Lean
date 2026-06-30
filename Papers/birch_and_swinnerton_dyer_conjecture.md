# Computational Evidence — Probabilistic BSD (Sato–Tate moments & root-number parity)

This cycle attacks the **Probability** facets of the Birch–Swinnerton-Dyer circle:
the *distribution* of normalized Frobenius traces (Sato–Tate) and the *parity*
of ranks predicted by the root number (Goldfeld). Both are statements about
probability measures attached to an elliptic curve's L-function.

## 1. The Sato–Tate measure and its moments

For an elliptic curve E/ℚ without CM, the Sato–Tate conjecture (now a theorem of
Clozel–Harris–Shepherd-Barron–Taylor for such curves) says the normalized
Frobenius traces `a_p / √p = 2 cos θ_p` equidistribute on `[0, π]` with respect to

    dμ_ST = (2/π) sin²θ dθ.

Writing `x = 2 cos θ ∈ [-2, 2]`, the pushforward is the **semicircle law**
`(1/2π)√(4 - x²) dx`. Its even moments are the **Catalan numbers**:

    m_{2k} = ∫₀^π (2 cos θ)^{2k} · (2/π) sin²θ dθ = C_k,   m_{2k+1} = 0.

### Hand / symbolic check of the first moments

Using the Wallis values ∫₀^π sin^{2n}θ dθ = π · ∏_{i<n} (2i+1)/(2i+2):

| n | ∫₀^π sin^{2n} |
|---|----------------|
| 1 | π/2            |
| 2 | 3π/8           |
| 3 | 5π/16          |

- **m₀** = (2/π)·(π/2) = **1**           (total mass — μ_ST is a probability measure)
- **m₁** = (4/π)∫₀^π cosθ sin²θ dθ = (4/π)·0 = **0**   (mean of trace is 0)
- **m₂** = (8/π)∫ cos²sin² = (8/π)(π/2 − 3π/8) = (8/π)(π/8) = **1** = C₁
- **m₄** = (32/π)∫ cos⁴sin² = (32/π)(π/2 − 2·3π/8 + 5π/16) = (32/π)(π/16) = **2** = C₂
- **m₆** = **5** = C₃ (analogous expansion via cos⁶ = (1−sin²)³)

Catalan numbers C₀,C₁,C₂,C₃ = 1,1,2,5 — **OEIS A000108**.
The even-moment sequence of the semicircle law is A000108; the central binomial
intermediate `(2k choose k)` is **OEIS A000984**.

All five values above are proved unconditionally in
`Catalog/Probability/BSD/SatoTateMoments.lean` (theorems `satoTate_total_mass`,
`satoTate_mean`, `satoTate_second_moment`, `satoTate_fourth_moment`,
`satoTate_sixth_moment`, unified as `satoTate_even_moment_catalan` for k ≤ 3).

## 2. Root-number parity (Goldfeld 50% model)

The sign `w ∈ {+1, -1}` of the functional equation forces the parity of the
analytic rank: `Even (rank) ↔ w = +1` (proved in the catalog as
`BSD.FunctionalEquation.rank_even_iff_sign_one`). Under the unbiased model where
`w` is a fair coin, the probability of even rank is therefore exactly **1/2** —
the Goldfeld density heuristic in its cleanest form.

Sanity check on explicit model curves `Λ(s) = (s−1)^r · c`:
- r = 0 (w = +1): rank 0, even   ✓
- r = 1 (w = −1): rank 1, odd    ✓
- r = 2 (w = +1): rank 2, even   ✓
Exactly half of `{w = +1, w = −1}` gives even rank, independent of which ranks
are chosen, confirming the 1/2.

Formalized in `Catalog/Probability/BSD/RootNumberParityModel.lean`
(`prob_even_rank_eq_half`).

## 3. Counterexample hunt
- The Catalan-moment identity was tested for k = 0..3 and matches A000108 exactly.
- The parity equivalence has no counterexample: both signs are realised by the
  model L-functions, so the probability model is non-vacuous.
