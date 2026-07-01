# Computational Evidence — Fourier Analysis on Finite Groups

Target identities (discrete Fourier transform `𝓕 = ZMod.dft` on `ZMod N`,
normalisation `𝓕 f (k) = Σ_j e^{-2πi jk/N} f(j)`):

1. Convolution theorem: `𝓕(f ⋆ g) = 𝓕 f · 𝓕 g`.
2. Parseval/Plancherel: `Σ_k |𝓕 f (k)|² = N · Σ_j |f(j)|²`.
3. Donoho–Stark uncertainty: `f ≠ 0 ⟹ |supp f| · |supp 𝓕f| ≥ N`.

## 1. Small-case calculations for the uncertainty principle

We list `|supp f|`, `|supp 𝓕f|` and their product for canonical test functions.

| Group | f | |supp f| | |supp 𝓕f| | product | ≥ N ? |
|------|---|---------|-----------|---------|-------|
| ZMod 4 | δ₀ (indicator of {0}) | 1 | 4 | 4 | = 4 (sharp) |
| ZMod 4 | constant 1 | 4 | 1 | 4 | = 4 (sharp) |
| ZMod 6 | indicator of subgroup {0,3} (size 2) | 2 | 3 | 6 | = 6 (sharp) |
| ZMod 6 | indicator of subgroup {0,2,4} (size 3) | 3 | 2 | 6 | = 6 (sharp) |
| ZMod 5 | δ₀ + δ₁ (two spikes) | 2 | 5 | 10 | ≥ 5 |
| ZMod p (prime) | any 0 < |supp f| < p | a | b | a·b | a·b ≥ p (in fact a+b ≥ p+1, Tao) |

**Sharpness pattern.** Equality `|supp f|·|supp 𝓕f| = N` occurs exactly for
(translates/modulations of) indicators of subgroups: an indicator of a subgroup
`H ≤ ZMod N` with `|H| = d` has Fourier transform supported on the annihilator
`H^⊥`, of size `N/d`, so the product is `d · (N/d) = N`. The achievable products
on `ZMod N` are exactly the numbers `d · (N/d) ≥ N` ranging over divisors `d | N`,
and `N²` for "generic" `f` with full support and full spectral support.

## 2. OEIS / sequence remarks

No new integer sequence is introduced; the relevant structured quantity is the set
of equality products `{ d·(N/d) : d | N } = {N}` — equality is achieved by every
divisor, reflecting the subgroup ⇄ annihilator duality. The divisor lattice of `N`
(the subgroup lattice of the cyclic group, OEIS A000005 counts the divisors) indexes
the sharp cases.

## 3. Counterexample hunt

- **Uncertainty.** The claim is false for `f = 0` (both supports empty, `0 ≥ N`
  fails); this is why `f ≠ 0` is a load-bearing hypothesis. For every nonzero `f`
  on small groups (`ZMod 2..8`, spikes, sums of two spikes, subgroup indicators,
  random ±1 vectors) the inequality held; no counterexample found, consistent with
  the proof.
- **Parseval constant.** Testing `f = δ₀` gives `Σ|𝓕f|² = N` and `Σ|f|² = 1`, so
  the constant must be exactly `N`; any other normalisation (`1`, `1/N`, `√N`)
  fails this test. The proof uses the constant `N`.
- **Convolution.** `𝓕(δ₀ ⋆ g) = 𝓕 g` because `δ₀` is the convolution unit, and
  `𝓕 δ₀ = 1`, matching `𝓕 f · 𝓕 g` with `f = δ₀`. No discrepancy found.

## 4. Method note

All three identities reduce to two structural facts about the standard additive
character `χ = stdAddChar`: it is **multiplicative** (`χ(a+b) = χ(a)χ(b)`) and
**orthogonal** (`Σ_k χ(mk) = N·[m=0]`). The convolution theorem needs only
multiplicativity; Parseval additionally needs orthogonality; the uncertainty
principle needs neither — only `|χ| = 1` and Fourier inversion. This stratification
is what made the formal development tractable and is recorded in the Lab Notes.
