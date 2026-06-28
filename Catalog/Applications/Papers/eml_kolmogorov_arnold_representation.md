# Computational Evidence — EML Kolmogorov–Arnold rank-one frontier

This note records the small computations that guided the two new files

* `Catalog/Applications/KolmogorovArnoldEMLSeparability.lean`
* `Catalog/Applications/KolmogorovArnoldEMLProductSeparability.lean`

The central object is the **cross-multiplicative invariant**

```
CrossMul f  :=  ∀ x y x' y',  f x y · f x' y'  =  f x y' · f x' y .
```

The theorems prove: for two-variable targets, `CrossMul f` is *exactly*
multiplicative separability, which in turn is *exactly* existence of a rank-one
EML representation `f x y = exp(ψ x + φ y)`.

## 1. Small-case calculations (the invariant, over ℚ — exact arithmetic)

Define `cm f x y x' y' := (f x y * f x' y' == f x y' * f x' y)`.

| target `f`      | `cm f 2 3 5 7` | `cm f 1 1 0 0` |
|-----------------|----------------|----------------|
| `fprod = x·y`   | `true`         | `true`         |
| `fsum  = x+y`   | `false`        | `false`        |

* The product `x·y` passes the invariant at every sampled 4-tuple (it is
  multiplicatively separable; `a = b = id`), matching `mul_crossMul`.
* The sum `x+y` fails it already at `(1,1),(0,0),(1,0),(0,1)`:
  `(1+1)(0+0) = 0` but `(1+0)(0+1) = 1`. This is exactly the witness used in the
  proof of `add_not_crossMul` (hence `add_not_mulSeparable`,
  `add_not_rankOne_exp`).

## 2. Counterexample hunt — does any rank-two target sneak into rank one?

The "geometric-mixture" target

```
g x y = exp(x + y) + exp(2x + 3y)        (a sum of two rank-one EML terms)
```

was sampled with `Float`:

```
g 0 0 · g 1 1 ≈ 311.60        g 0 1 · g 1 0 ≈ 230.49
```

These differ, so `g` violates `CrossMul`; by the characterization it has **no**
rank-one EML representation. This is the numerical seed for Future Direction F1
(a strict rank hierarchy `rank-1 ⊊ rank-2`): a non-separable, strictly positive
target that is a sum of two rank-one EML terms but not a single one.

## 3. OEIS

No integer sequence is involved; the content is an analytic characterization, so
an OEIS search is not applicable.

## 4. Take-away

Every sampled case is consistent with the proved dichotomy:

* `CrossMul` ⇔ multiplicative separability ⇔ rank-one EML (`exp(ψ+φ)`);
* `x·y` lies on the rank-one side, `x+y` strictly off it;
* `exp(x+y)+exp(2x+3y)` is genuinely rank ≥ 2.

All formal statements are discharged with `0` sorries and depend only on
`propext`, `Classical.choice`, `Quot.sound`.
