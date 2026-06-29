# Computational Evidence — Additive Energy via Fourier on ℤ/Nℤ

Target identity (`addEnergy_eq_dft`):

    E[A] = N⁻¹ · Σ_k ‖𝓕 1_A (k)‖⁴      for A ⊆ ℤ/Nℤ,

with the Mathlib DFT convention `𝓕 Φ (k) = Σ_j stdAddChar(-(j·k))·Φ(j)`, so the normalizing factor
`N` sits on the inverse transform and Plancherel reads `Σ_k ‖𝓕 f k‖² = N · Σ_j ‖f j‖²`.

Here `E[A] = #{(a,b,c,d) ∈ A⁴ : a + b = c + d}` is `Finset.addEnergy A A`.

## Small-case checks (done by hand / direct enumeration)

* **N = 5, A = {0,1,2}.** Representation counts `r(t) = #{(x,y)∈A² : x+y=t}` over ℤ/5ℤ:
  `r(0)=1, r(1)=2, r(2)=3, r(3)=2, r(4)=1` (sums 0..4). Then
  `E[A] = Σ_t r(t)² = 1+4+9+4+1 = 19`.
  Cross-check via `|A|⁴/N = 81/5 = 16.2`, and indeed `19 ≥ 16.2`, matching the proven lower bound
  `card_pow_four_div_le_addEnergy`.

* **N = 4, A = {0,2} (a coset of the subgroup {0,2}).** `r(0)=2 (0+0,2+2), r(2)=2 (0+2,2+0)`,
  others 0. `E[A] = 4+4 = 8 = |A|⁴/|H| = 16/2`. Subgroups/cosets saturate energy, consistent with
  the spectral picture: `𝓕 1_H` is supported on the annihilator, giving few large Fourier modes.

* **Full set A = univ (N arbitrary).** `r(t) = N` for all `t`, so `E = N·N² = N³`. On the spectral
  side `𝓕 1_univ` is `N` at `k=0` and `0` elsewhere, so `N⁻¹·N⁴ = N³`. ✓

* **Singleton A = {a}.** `E = 1`, and `‖𝓕 1_A k‖ = 1` for all `k`, so `N⁻¹·(N·1) = 1`. ✓

## Sanity of the lower bound

For all cases above `E[A] ≥ |A|⁴/N` holds, with equality exactly when `𝓕 1_A` is concentrated at
`k = 0` (i.e. `A` essentially a full coset). This is the equality case of dropping all `k ≠ 0`
terms, and is consistent with the structure theory of sets with large additive energy.

## OEIS

Additive-energy sequences depend on the chosen sets, so no single canonical OEIS entry applies;
the per-`A` counts above are elementary convolution squares and need no external table.

## Conclusion

All finite checks agree with both the exact identity `addEnergy_eq_dft` and the inequality
`card_pow_four_div_le_addEnergy`. Both are fully proved in `FourierFiniteGroups.lean` (0 sorries),
so the computational evidence is corroborative rather than load-bearing.
