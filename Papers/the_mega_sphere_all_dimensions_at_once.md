# Computational Evidence — The Mega-Sphere

This note records the small-case checks that guided the formalization. Every
claim below is subsequently proved in Lean (no `sorry`), so this is orientation
rather than the final word.

## 1. The inverse limit machinery

The inverse limit of a tower `⋯ → X(n+1) --πₙ--> Xₙ → ⋯` is the set of coherent
sequences `{ x : Πn, Xₙ | ∀n, πₙ(x(n+1)) = xₙ }`. Two extreme towers were tested:

### Constant tower `Xₙ = G`, `πₙ = id`
Coherent sequences satisfy `x(n+1) = xₙ`, so by induction `xₙ = x₀` for all `n`:
the limit is the diagonal copy of `G`. (Formalized: `constTower_invLimit_eq`.)

### Doubling tower `ℤ ←×2— ℤ ←×2— ⋯`
Here `2·x(n+1) = xₙ`, hence `x₀ = 2ᵏ·xₖ`, so `2ᵏ ∣ x₀` for every `k`.
Sample: if `x₀ = 12`, then `x₀` must be divisible by `2,4,8,16,…` — impossible
unless `x₀ = 0`. More generally the only integer divisible by all powers of `2`
is `0`, so the whole limit collapses to `{0}`. (Formalized:
`doublingTower_invLimit_eq_bot`, via `int_eq_zero_of_forall_two_pow_dvd`.)

### `2`-adic tower `ZMod(2^(n+1))` with reduction maps
Reductions `ZMod(2^(n+2)) → ZMod(2^(n+1))` are ring homs; the limit is the ring
of `2`-adic integers `ℤ₂`, which is nontrivial (`0 ≠ 1` already at stage `0`,
i.e. in `ZMod 2`). (Formalized: `padicTower_nontrivial`.)

## 2. Stiefel–Whitney classes and `H*(ℝP^∞; 𝔽₂) = 𝔽₂[w]`

Total SW class of the tautological line bundle: `w(L) = 1 + w`. In `𝔽₂` the
geometric series inverts it by telescoping:

    (1 + w)·(1 + w + w² + w³ + ⋯)
      = (1 + w + w² + ⋯) + (w + w² + w³ + ⋯)
      = 1     (all higher terms cancel in pairs, since 1+1 = 0 in 𝔽₂).

So the dual SW classes are `w̄ₖ = wᵏ`, all `= 1`. This holds only after
completing `𝔽₂[w]` to `𝔽₂⟦w⟧`; in the polynomial ring `1 + w` has degree `1` and
is not a unit. (Formalized: `dual_sw_series`, `sw_isUnit_completion`,
`sw_not_isUnit`.)

Frobenius / Whitney check in char 2:

| k | (1+w)^(2^k) expanded            | = 1 + w^(2^k) ? |
|---|----------------------------------|-----------------|
| 1 | 1 + 2w + w² = 1 + w²  (2w=0)     | yes, 1 + w²     |
| 2 | (1+w²)² = 1 + w⁴                 | yes, 1 + w⁴     |
| 3 | (1+w⁴)² = 1 + w⁸                 | yes, 1 + w⁸     |

(Formalized: `sw_whitney_frobenius`, `sw_square`.)

## 3. Bernoulli numbers (OEIS)

Bernoulli numerators/denominators: `B₀=1, B₁=-1/2, B₂=1/6, B₃=0, B₄=-1/30,
B₅=0, B₆=1/42, …`. Numerators are OEIS **A027641**, denominators **A027642**.
Odd-index Bernoulli numbers vanish beyond `B₁` (parity symmetry).

Faulhaber closed forms extracted from the Bernoulli power-sum formula, checked at
`n = 4` (sum over `k = 0..3`):

| p | ∑_{k<4} kᵖ | closed form value |
|---|-----------|-------------------|
| 1 | 0+1+2+3 = 6      | 4·3/2 = 6            |
| 2 | 0+1+4+9 = 14     | 4·3·7/6 = 14         |
| 3 | 0+1+8+27 = 36    | (4·3/2)² = 6² = 36   |

The `p=3` case is Nicomachus's identity `∑k³ = (∑k)²`. (Formalized:
`faulhaber_one/two/cube`, `nicomachus`, `bernoulli_recurrence`, `bernoulli_two`,
`bernoulli_odd_eq_zero`.)
