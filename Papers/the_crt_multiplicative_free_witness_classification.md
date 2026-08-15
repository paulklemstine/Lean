# Computational evidence — CRT-multiplicative free witnesses

All numbers below are **kernel-checked in Lean** (by `decide`) in
`Catalog/Tropical/FreeWitnessLabNotes.lean`; nothing here rests on an unchecked script.

## 1. SIGK (the predicted member `σ_k`, `k ≥ 2`)

| `N = p·q` | `σ₂(N)` | `(1+p²)(1+q²)` | `σ₂ − 1 − N²` | `p² + q²` |
|---|---|---|---|---|
| `15 = 3·5` | 260 | 260 | 34 | 34 |

`sigma_two_fifteen`, `sigma_two_recovery_fifteen`. The general statement
`σ_k(pq) = (1+p^k)(1+q^k)` is the catalog theorem `TraceLemma.sigma_semiprime`;
the general recovery is `TraceLemma.recoverSmallFactor_sigma_two`.

## 2. The residue barrier (paper §5, "mod-2^k addendum")

Two semiprimes with the *same* residue of `N` but *different* residues of the witness:

| `N` | factorisation | `N mod 8` | `σ₁(N)` | `σ₁(N) mod 8` |
|---|---|---|---|---|
| 33 | `3 · 11` | 1 | 48 | 0 |
| 697 | `17 · 41` | 1 | 756 | 4 |

`residue_barrier_data`. Any formula computing `σ₁(N) mod 8` from `N mod 8` would have to
return one value for both rows. This single pair falsifies the existence of such a
formula, and the general theorem
`FreeWitnessBarriers.sigma_one_no_mod_eight_formula` proves the same statement for
*all* semiprimes via Dirichlet's theorem, with
`FreeWitnessBarriers.sigma_pow_no_residue_formula` covering every exponent `k ≥ 1`.

Search note: `σ₁` residues mod 8 cannot be separated using semiprimes `N ≡ 7 (mod 8)` —
there `p + q ≡ 0 (mod 8)` always — which is why the witnessing pair is taken in the
class `N ≡ 1 (mod 8)`. Likewise for `k = 2` the moduli `8, 16, 32` all fail
(every inverse pair gives exactly `4`), and `128` is the first power of two that works;
this is visible in the proof of `sigma_two_no_mod_128_formula`.

## 3. Fibres of the witness (counterexample hunt)

The slogan "the witness value *is* the factorisation" is **false**:

| value `V` | semiprimes with `σ₁ = V` | `τ(V)` |
|---|---|---|
| 24 | `14 = 2·7`, `15 = 3·5` | 8 |

`fibre_data`, and the theorem `FreeWitnessShadow.sigma_one_collision`. The proved
replacement is the fibre bound `FreeWitnessShadow.aggregate_fibre_card_le_tau`: at most
`τ(V)` semiprimes share a value, since `(p,q) ↦ 1 + w p` injects the fibre into the
divisors of `V`.

## 4. KROOT order counts

| `N` | `k` | `#{x ∈ (ZMod N)ˣ : x^k = 1}` | `gcd(p−1,k)·gcd(q−1,k)` |
|---|---|---|---|
| 15 | 2 | 4 | `2·2 = 4` |
| 15 | 8 | 8 | `2·4 = 8` |

`kroot_two_fifteen`, `kroot_totient_fifteen`, `kroot_formula_check`. The `k = 2` row is
constant over all odd semiprimes (`FreeWitnessOrder.card_sqrtOne_semiprime`), so that
member of the family is information-free; the `k = φ(N)` row attains the maximum
`φ(N) = (p−1)(q−1)` (`FreeWitnessOrder.kroot_max_eq_totient`), from which
`p + q = N + 1 − φ(N)` recovers the factors.

## 5. OEIS

The sequences that appear are the classical ones: `σ₁` is A000203, `σ₂` is A001157,
`τ` is A000005, and `φ` is A000010. No new sequence is introduced by this work; the
content is the barrier and rigidity statements about these functions restricted to
semiprimes.
