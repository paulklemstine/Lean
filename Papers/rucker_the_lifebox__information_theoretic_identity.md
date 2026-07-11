# Computational Evidence — Lifebox: Information-Theoretic Identity

This note records the small-case checks that motivated the formal statements in
`LifeboxInformationIdentity.lean`.

## 1. Person-equivalence as functional equivalence

`PersonEquiv f g := ∀ i, f i = g i`. On a finite stimulus set this is exactly equality
of the finite behaviour tables.

Small case (`I = O = Bool`): there are `2^2 = 4` distinct systems `Bool → Bool`
(`const false`, `const true`, `id`, `not`). Person-equivalence partitions the `4^... ` pairs
into the diagonal, i.e. equality — confirming `personEquiv_iff_eq`.

## 2. Finite-state ⇒ decidable

Decision procedure: compute the *distinguishing-stimulus set*
`{ i ∈ univ | f i ≠ g i }` and test emptiness. For `I` finite this is a finite
computation, so `Decidable (PersonEquiv f g)` (instance `decidablePersonEquiv`), and
`finiteState_decidable` states the emptiness characterisation.

| `|I|` | systems `I→Bool` | equivalence classes |
|-------|------------------|---------------------|
| 1     | 2                | each singleton (equality) |
| 2     | 4                | each singleton |
| n     | `2^n`            | `2^n` (equality) |

## 3. Contrarian — no finite test over an infinite input space

For any finite probe set `S ⊂ ℕ` pick `n ∉ S` and compare
`f = 𝟙[· = n]` against `g = const false`. They agree on all of `S` yet differ at `n`.

Sample: `S = {0,1,2,3,4}` ⇒ `n = 5`, `f 5 = true ≠ false = g 5`. This holds for every
finite `S`, so no finite battery of tests certifies equivalence — proved as
`no_finite_test`. This is the precise obstruction contrasting the finite-state case.

## 4. Quantum obstruction — no-cloning

A candidate linear cloner `C : k² → k² ⊗ k²` with `C x = x ⊗ x` fails on
`e₁=(1,0)`, `e₂=(0,1)`:

```
C(e₁+e₂) = (e₁+e₂)⊗(e₁+e₂) = e₁⊗e₁ + e₁⊗e₂ + e₂⊗e₁ + e₂⊗e₂   (nonlinear diagonal)
C(e₁)+C(e₂) = e₁⊗e₁ + e₂⊗e₂                                     (linearity)
```

Subtracting forces `e₁⊗e₂ + e₂⊗e₁ = 0`. Applying the functional `a⊗b ↦ a₁·b₂` gives
`1·1 + 0·0 = 1 = 0`, a contradiction in any field. Verified as `no_cloning`.

## 5. Kolmogorov bound is finite

Identities describable in `b` bits = `Fin b → Bool`, of which there are exactly `2^b`:

| `b` | # identities |
|-----|--------------|
| 1   | 2            |
| 2   | 4            |
| 8   | 256          |
| 10^15 | 2^(10^15) (finite) |

Proved as `card_identities` and instantiated at Rucker's `~10^15`-bit figure in
`lifebox_bound`.
