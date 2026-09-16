# Computational evidence — the quintic type channel of `F₂₀ = AGL(1,5)`

All numbers below were first obtained by direct enumeration of the 20-element Frobenius
group and its 400-element semiprime box, and were subsequently **re-derived and proved
exactly** inside Lean (`Catalog/Bridges/QuinticTypeChannelF20*.lean`).  Nothing in this file
is load-bearing for the theorems; it records the exploration that fixed the statements.

## 1. The model

The Galois group of `x⁵ - 2` is `F₂₀ = {x ↦ a x + b : a ∈ 𝔽₅ˣ, b ∈ 𝔽₅}` acting on the five
roots.  Writing `a = 2^e` (so `e` is the `C₄` valuation, `V(2) = 1, V(4) = 2, V(3) = 3`), the
cycle type of `x ↦ a x + b` on the five roots is

| `e` | `a` | `b` | cycle type | code | count |
|-----|-----|-----|------------|------|-------|
| 0 | 1 | `= 0` | `[1,1,1,1,1]` | `1`   | 1 |
| 0 | 1 | `≠ 0` | `[5]`         | `5`   | 4 |
| 1,3 | 2,3 | any | `[1,4]`     | `14`  | 10 |
| 2 | 4 | any | `[1,2,2]`      | `122` | 5 |

The class sizes `1 : 4 : 10 : 5` are exactly the Chebotarev densities.

## 2. Small-case calculations (enumeration)

Single prime (uniform on the 20 classes):

```
H(T)                      = 1.6804820237  ( = 11/10 + (log₂ 5)/4 )
H(p mod 5)                = 2.0000000000  ( = log₂ 4 )
I(T ; p mod 5)            = 1.5000000000  ( exactly 3/2 )
H(T | p mod 5)            = 0.1804820237  ( = (log₂ 5)/4 − 2/5 )
H(p mod 5 | T)            = 0.5000000000  ( the merged {2,3} cosets )
```

Semiprime (all 400 ordered pairs of Frobenius classes, observation `N mod 5`):

```
I(ordered type pair   ; N mod 5) = 1.2500000000   (= 5/4)
I(unordered type pair ; N mod 5) = 1.2500000000   (which-factor wall = 0)
I([1,2,2]-fork count  ; N mod 5) = 0.2947367178
Isplit 4 (catalog, C₄ cyclotomic) = 0.2947367178  (agreement to all digits)
Ipair  4 (catalog, C₄ cyclotomic) = 1.2500000000  (agreement)
```

Abelian control `C₅ = ℚ(ζ₁₁)⁺` through the identical pipeline:

```
H(T) = I(T ; p mod 11) = 0.7219280949  ( = log₂ 5 − 8/5 )
H(p mod 11)            = 3.3219280949  ( = log₂ 10 )
loss                   = 2.6000000000  ( = 13/5 )
I(type pair ; N mod 11) = 0.2027100952 ( = Is(5), reproducing the abelian layer )
```

## 3. Counterexample hunt: the coset-label swap

The most informative experiment was a deliberately corrupted dictionary, placing the
order-2 multiplier on valuation `e = 3` instead of `e = 2` (i.e. interchanging the labels of
`3` and `4` in `𝔽₅ˣ`):

```
swapped H(T)                    = 1.6804820237   (identical)
swapped I(T ; p mod 5)          = 1.5000000000   (identical)
swapped I(type pair ; N mod 5)  = 1.1250000000   (≠ 5/4 : differs by 1/8)
```

So the corruption is **invisible to every prime-level statistic** and is detected only by
the semiprime pair channel.  This is `QuinticF20Pair.coset_swap_detected_only_by_the_pair_law`.

## 4. Fibre tables used by the exact proofs

The exact evaluations in Lean use the count form of the entropy; the fibre multisets were
read off by enumeration and are re-checked by the kernel (`decide`) in the source:

```
type fibres over the 20 classes                 : [1, 4, 5, 10]
ordered type-pair fibres over the 400 pairs     : [1,4,5,10, 4,16,20,40, 5,20,25,50, 10,40,50,100]
   conditioned on N ≡ 0 mod 5 (as a C₄ class)   : [1,4,4,16,25,50]
   conditioned on N ≡ 1                         : [5,20,5,20,25,25]
   conditioned on N ≡ 2                         : [5,20,5,20,50]
   conditioned on N ≡ 3                         : [5,20,25,25,5,20]
unordered type-pair fibres                      : [1,8,16,10,40,25,20,80,100,100]
fork split-count fibres                         : [25,150,225]
```

## 5. Sequence search

The rational values produced by the law (`3/2`, `5/4`, `9/8`, `1/2`, `1/8`, `13/5`) are
dyadic/small-denominator constants, not a sequence; no OEIS entry is relevant.  The
non-rational constants are `log₂ 5` and `log₂ 3` only, and they appear solely inside the two
entropies, cancelling in all mutual informations.
