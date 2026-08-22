# Computational Evidence — rigidity of the Shtarkov sum

All computations below were run in Lean 4 with exact rational arithmetic
(`ℚ`), representing a source class as a list of probability vectors and the
Shtarkov sum as `∑ₓ max_θ p_θ x`.  They are exploratory (`#eval`) checks used to
select and sanity-test the conjectures; each conjecture that survived was then
proved formally in `Catalog/MachineLearning/UniversalRedundancy/Rigidity.lean`
and `.../MemorylessStrict.lean`.  Nothing in this file is a substitute for those
proofs.

## Setup

```lean
def maxLikL (cls : List (List ℚ)) : List ℚ :=
  match cls with
  | []      => []
  | p :: ps => ps.foldl (fun acc q => List.zipWith max acc q) p

def shtarkov (cls : List (List ℚ)) : ℚ := (maxLikL cls).sum
def tv (p q : List ℚ) : ℚ := (List.zipWith (fun a b => |a - b|) p q).sum / 2
def overlap (cls : List (List ℚ)) : ℚ := (cls.length : ℚ) - shtarkov cls
```

## 1. Two-source formula `Cₛ = 1 + d_TV`

| `p`                   | `q`                   | `Cₛ`  | `1 + d_TV` |
|-----------------------|-----------------------|-------|------------|
| `(1/2, 1/3, 1/6)`     | `(1/4, 1/4, 1/2)`     | `4/3` | `4/3`      |
| `(1, 0, 0)`           | `(0, 1/2, 1/2)`       | `2`   | `2`        |
| `(1/3, 1/3, 1/3)`     | `(1/3, 1/3, 1/3)`     | `1`   | `1`        |

Agreement in every case, including both rigid endpoints (`d_TV = 0` gives the
free class, `d_TV = 1` the mutually singular pair).
Formalised as `SourceClass.shtarkovSum_pair_eq_one_add_tvDist`.

## 2. Conservation law `Cₛ + Ω = #Θ`

For the three-fold repetition of the uniform law on three letters,
`Cₛ = 1` and `Ω = 2 = #Θ − Cₛ`.  For the point-mass class on `k` letters,
`Ω = 0` and `Cₛ = k`.  Formalised as `SourceClass.shtarkovSum_add_overlap_eq_card`.

## 3. Counterexample hunt for the upper-endpoint characterisation

Claim tested: `Cₛ = #Θ` iff no message is charged by two sources.  All `8³ = 512`
classes of three sources on a three-letter alphabet built from the palette

```
(1,0,0) (0,1,0) (0,0,1) (½,½,0) (½,0,½) (0,½,½) (⅓,⅓,⅓) (¼,¼,½)
```

were enumerated and the predicate `Cₛ = 3` compared with mutual singularity of
the supports:

```
enumerated classes : 512
disagreements      : 0
```

No counterexample.  Formalised as
`SourceClass.shtarkovSum_eq_card_iff_mutuallySingular`.

## 4. Tied products: strictness of subadditivity

Take `Θ = {0,1}`, `X₁ = X₂ = {0,1}` and `p_θ = δ_θ` in both blocks.  Then

```
Cₛ(block)          = 2
Cₛ(tied product)   = 2      (only the diagonal outcomes survive)
Cₛ(block)·Cₛ(block)= 4
```

so subadditivity is strict, and the tied envelope is `1` on the diagonal and `0`
off it, exactly matching the "no common maximiser" criterion.
Formalised as `shtarkovSum_tiedProdClass_pointMass` and
`shtarkovSum_tiedProdClass_pointMass_lt`.

## 5. Memoryless class, binary alphabet

`Cₛ(n)` for the Bernoulli class computed by maximising `(k/n)^k((n−k)/n)^{n−k}`
over types:

| `n` | `Cₛ(n)` (exact) | `≈`     | `Cₛ(1)^n = 2^n` | strict? |
|-----|-----------------|---------|-----------------|---------|
| 1   | `2`             | `2.000` | `2`             | equal   |
| 2   | `5/2`           | `2.500` | `4`             | yes     |
| 3   | `26/9`          | `2.889` | `8`             | yes     |
| 4   | `103/32`        | `3.219` | `16`            | yes     |
| 5   | `2194/625`      | `3.510` | `32`            | yes     |

The gap widens with `n`, consistent with — and the motivation for — the proved
statements `shtarkovSum_iidClass_strict_submultiplicative` and
`shtarkovSum_iidClass_lt_pow` (`Cₛ(n) < (#A)^n` for `n ≥ 2`).  The values for
`n ≥ 2` in the table are exact rational `#eval` outputs of the type-sum formula
`∑_k C(n,k) (k/n)^k ((n−k)/n)^{n−k}`; they are exploratory data, not part of the
formal development.  What is machine-checked are the strict inequalities.
