# Computational evidence for the guarded transfer principle

All numbers below come from an exact-rational implementation of the four
constructors `fin q | pinf | ninf | null` with Anderson-style total arithmetic
(`0·∞ = ∞−∞ = 0/0 = Φ`, `q/0 = ±∞` for `q ≠ 0`), evaluated over the finite
sample

```
S = { fin(-2), fin(-1), fin(-1/2), fin(0), fin(1/2), fin(1), fin(2), pinf, ninf, null }
```

(10 elements; 100 pairs; 1000 triples).  The sample is closed under nothing in
particular, so each law is checked only on the tuples listed — this is
exploratory evidence, not proof.  Every claim that survived here has been
turned into a machine-checked Lean theorem; the file names are given.

## 1. Small-case law checking (exhaustive on the sample)

| law | verdict on the sample | Lean status |
|---|---|---|
| `a + b = b + a` | HOLDS (100/100) | `Transreal.add_comm` (proved) |
| `(a+b)+c = a+(b+c)` | HOLDS (1000/1000) | `Transreal.add_assoc` (proved) |
| `a * b = b * a` | HOLDS (100/100) | `Transreal.mul_comm` (proved) |
| `(a*b)*c = a*(b*c)` | HOLDS (1000/1000) | not formalised (see FUTURE_DIRECTIONS) |
| `a*(b+c) = a*b + a*c` | **FAILS** | `Transreal.not_mul_add_distrib` (proved) |
| `x / y = fin(x/y)` for finite `x`, finite `y ≠ 0` | HOLDS | `Transreal.fin_div_fin_of_ne` (proved) |
| `a · a⁻¹ = 1` **iff** `a` finite nonzero | HOLDS | `Transreal.exists_mul_eq_one_iff` (proved) |

Smallest distributivity counterexample found on the sample:

```
a = pinf, b = fin(-2), c = fin(0):
    a*(b+c) = pinf * fin(-2)              = ninf
    a*b + a*c = ninf + (pinf * fin 0)     = ninf + null = null
```

The Lean proof uses the even smaller witness `(pinf, fin 1, fin 0)`:
`pinf*(1+0) = pinf` but `pinf*1 + pinf*0 = pinf + null = null`.

## 2. Units and additive invertibles (counterexample hunt for the guard)

Computed by brute force over the sample:

```
units (∃ b, a*b = 1)        : fin(-2), fin(-1), fin(-1/2), fin(1/2), fin(1), fin(2)
additive invertibles         : the same, plus fin(0)
```

No exceptional constructor is invertible on either side.  This is exactly the
statement later proved in `Boundary.lean`: *the legal denominators are precisely
the units*, so the "nowhere-zero denominator" guard is forced by the algebra.

## 3. The division boundary, numerically

```
x            :  -1/10     -1/1000     0        1/1000      1/10
x / x        :  fin 1     fin 1       null     fin 1       fin 1
1 / x        :  fin -10   fin -1000   pinf     fin 1000    fin 10
1 / x²       :  fin 100   fin 1e6     pinf     fin 1e6     fin 100
```

Three qualitatively different behaviours, which became the trichotomy proved in
`PoleTransfer.lean`:

1. `x/x` — nearby values are the constant `fin 1`, the value at `0` is the
   *isolated* point `null`: discontinuous, and no topology with T₁ separation
   can fix it (`selfDiv_not_continuous_of_t1`).
2. `1/x` — the two one-sided limits are `+∞` and `−∞`: discontinuous in any
   Hausdorff topology in which the finite fragment converges to the ends
   (`not_continuousAt_of_sign_change`).
3. `1/x²` — both one-sided limits are `+∞`, which is exactly the value the
   transreal arithmetic assigns: **continuous**
   (`continuousAt_div_of_positive_pole`, `continuous_one_div_sq`).

Item 3 was the surprise of the computational stage: it refutes the reading of
the conjecture in which *every* unguarded quotient fails, and forced the final
statement of the boundary to be a trichotomy rather than a dichotomy.

## 4. OEIS

No integer sequence arises in this development (the objects are a 4-constructor
carrier and its topology), so no OEIS lookup applies.
