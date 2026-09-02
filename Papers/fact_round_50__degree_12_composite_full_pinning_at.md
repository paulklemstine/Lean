# Computational evidence — degree-12 composite rung (conductor 56)

All numbers below were produced by direct enumeration before formalisation, and
every claim that appears in the Lean files was subsequently re-derived inside Lean
(by `decide` on the finite data, or by a proof from Mathlib for the field-theoretic
statements). Nothing in this note is used as an assumption by the proofs.

## 1. The reduced residues mod 56 and their types

`(ZMod 56)ˣ` has `φ(56) = 24` elements. For a residue `a` coprime to 56 put

```
resDeg a = min { k ≥ 1 : a^k ≡ ±1 (mod 56) }
```

which is the order of the class of `a` in `G⁺ = (ZMod 56)ˣ/{±1}`, i.e. the residue
degree of an unramified prime `p ≡ a (mod 56)` in `Q(ζ₅₆)⁺`.

Enumeration over the 24 reduced residues:

| type `f` | # residues | density | # elements of `C₆ × C₂` of that order |
|---|---|---|---|
| 1 | 2  | 1/12 | 1 |
| 2 | 6  | 1/4  | 3 |
| 3 | 4  | 1/6  | 2 |
| 6 | 12 | 1/2  | 6 |

Every residue satisfies `a^6 = 1`, so the unit group has exponent 6; combined with
`|G⁺| = 12` this already forces `G⁺` to be non-cyclic.

Formal counterparts: `typeCount_one/two/three/six`, `chebotarev_match`,
`resDeg_mem_types`, `not_isAddCyclic`.

## 2. Chebotarev check against actual primes

Types of all 17 982 primes `3 ≤ p < 200 000` with `p ∤ 56`:

| type `f` | empirical density | Chebotarev density |
|---|---|---|
| 1 | 0.08247 | 0.08333 |
| 2 | 0.24992 | 0.25000 |
| 3 | 0.16466 | 0.16667 |
| 6 | 0.50295 | 0.50000 |

Agreement to ~3 decimal places, as expected for this range. (The Lean files prove
the *residue-class* statement, which is the exact, finite content; the equidistribution
of primes among residue classes is Dirichlet/Chebotarev and is not re-proved here.)

## 3. Entropy

With densities `{1/12, 1/4, 1/6, 1/2}`:

```
H(T) = 1/12·log₂12 + 1/4·log₂4 + 1/6·log₂6 + 1/2·log₂2
     = 4/3 + (log₂ 3)/4 = 1.7295739585136223
```

matching the reported `1.7296` bits. Since the type is a *function* of `p mod 56`,
the joint entropy collapses, `H(X,T) = H(X)`, so `I(X;T) = H(T)` exactly — the gap
is `0` by an identity, not by a numerical coincidence.

Residual uncertainty: `H(X|T) = log₂24 − H(T) = 5/3 + (3/4)log₂3 = 2.85539...` bits.

Formal counterparts: `entropyOut_Units56_resDeg`, `entropyOut_numeric`
(`1.7295 < H < 1.7296`), `mutualInfo_eq_entropyOut`, `pinning_gap_zero`,
`entropyCond_Units56`.

## 4. Separation of the two abelian groups of order 12

For `C₁₂` the order profile is `{1/12, 1/12, 1/6, 1/6, 1/6, 1/3}` (orders 1,2,3,4,6,12),
giving

```
H(C₁₂) = 5/6 + log₂ 3 = 2.4182958340544896
H(C₆ × C₂) = 4/3 + (log₂3)/4 = 1.7295739585136223
```

so the measured entropy alone separates the two possible degree-12 abelian Galois
groups, with the threshold `2` strictly between them.

Formal counterparts: `orderEntropy_C12`, `orderEntropy_C6xC2`, `entropy_separates`,
`noncyclic_of_entropy_lt_two`.

## 5. Orbit purity (12/12)

For each of the 12 elements `g ∈ C₆ × C₂`, the translation `x ↦ x + g` on the 12
cosets was enumerated:

| `g` | order | # orbits | orbit sizes |
|---|---|---|---|
| (0,0) | 1 | 12 | {1} |
| (0,1) | 2 | 6  | {2} |
| (1,0) | 6 | 2  | {6} |
| (1,1) | 6 | 2  | {6} |
| (2,0) | 3 | 4  | {3} |
| (2,1) | 6 | 2  | {6} |
| (3,0) | 2 | 6  | {2} |
| (3,1) | 2 | 6  | {2} |
| (4,0) | 3 | 4  | {3} |
| (4,1) | 6 | 2  | {6} |
| (5,0) | 6 | 2  | {6} |
| (5,1) | 6 | 2  | {6} |

Every orbit set is *pure*: a single size per element (12/12 pure), and
`#orbits · order = 12` in all cases. Formalised in general
(`card_transOrbit`, `card_orbits_mul_addOrderOf`) and specialised (`efg_law`,
`splitting_shapes`).

## 6. Semiprime pair channel

Enumerating all `24 × 24 = 576` ordered pairs of reduced residues and taking the
type of the product:

| type `d` | # pairs | `24 · typeCount d` |
|---|---|---|
| 1 | 48  | 48  |
| 2 | 144 | 144 |
| 3 | 96  | 96  |
| 6 | 288 | 288 |

Exact match, i.e. the semiprime channel has the same output law as the prime
channel. Formalised as `pair_channel_card` (general translation-invariant law) and
`pair_channel_Units56` / `pair_channel_density`.

## 7. OEIS

No new integer sequence arises: the counts `(1, 3, 2, 6)` are just the order
statistics of `C₆ × C₂`, and `(1, 1, 2, 2, 2, 4)` for `C₁₂` are the values of
Euler's totient on the divisors of 12 (A000010 restricted to divisors).
