# Computational Evidence

All computations below were run with `#eval` inside the project's Lean 4 /
Mathlib environment (they are exploratory: the *proved* statements are the Lean
theorems in `Catalog/Novelty/Nonstandard*.lean`, which are sorry-free and use
only `propext`, `Classical.choice`, `Quot.sound`).

Every construction used in the formal proofs is a *pointwise* recipe on
representative sequences, so it can be evaluated coordinatewise.  This is what
we test here.

## 1. The overspill diagonal

`overspill` builds its unlimited witness as
`f i = Nat.findGreatest (· ∈ A i) i`.  For the sample internal set
`A i = {k | k ≤ i / 2}` (which contains every standard `n` for large `i`):

```
i    :  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
f i  :  0 0 1 1 2 2 3 3 4 4  5  5  6  6  7  7  8  8  9  9
```

`f i → ∞` while `f i ∈ A i` for every `i`, exactly as the proof requires: the
germ `[f]` is unlimited and lies in the internal set.

## 2. Continuum-many hypernaturals: slope separation

`floorSlope r = [⌊n·r⌋]`.  For `r = 1/3` and `s = 1/2` the two staircases
(computed over ℚ):

```
n        :  0  1  2  3  4  5  6  7  8  9 10 11
⌊n/3⌋    :  0  0  0  1  1  1  2  2  2  3  3  3
⌊n/2⌋    :  0  0  1  1  2  2  3  3  4  4  5  5
```

Coincidences `⌊n/3⌋ = ⌊n/2⌋` occur only at `n ∈ {0, 1, 3}` (checked for
`n < 40`); from `n > 1/(s-r) = 6` on the sequences separate permanently, which
is the quantitative content of `floorSlope_lt`.  Since the hyperfilter refines
the cofinite filter, distinct positive slopes give distinct germs, giving the
injection `ℝ_{>0} ↪ HyperNat` used in `mk_hyperNat : #HyperNat = 𝔠`.

## 3. Hyperprimes: pointwise Euclid, Fermat, Wilson

Least prime strictly above `i²` (the pointwise recipe behind
`exists_least_hyperprime_gt` applied to `H = [i²]`):

```
i²   :  0  1  4  9 16 25 36 49 64 81
next :  2  2  5 11 17 29 37 53 67 83
```

Residues `((p-1)! + 1) mod p`, `(3^p - 3) mod p`, `(5^p - 5) mod p` for the
first eight primes:

```
p            :  2  3  5  7 11 13 17 19
Wilson       :  0  0  0  0  0  0  0  0
Fermat (a=3) :  0  0  0  0  0  0  0  0
Fermat (a=5) :  0  0  0  0  0  0  0  0
```

All zero, i.e. the divisibilities hold at every coordinate; the formal proofs
`hyper_wilson` and `hyper_fermat` only need them on an ultrafilter-large set of
coordinates, and they allow a *nonstandard exponent*.

## 4. Galaxy midpoints

`far_dense` inserts the pointwise midpoint `m i = h i + (k i - h i)/2` between
two galaxies.  For `h i = i` and `k i = i²`:

```
i      : 0 1 2 3  4  5  6  7  8  9
h i    : 0 1 2 3  4  5  6  7  8  9
m i    : 0 1 3 6 10 15 21 28 36 45
k i    : 0 1 4 9 16 25 36 49 64 81
```

Both gaps `m i - h i` and `k i - m i` grow without bound, which is exactly the
condition "`[m]` is in a galaxy strictly between `[h]` and `[k]`".

## 5. Counterexample hunt

We looked for failures of the claims before formalising them:

* *Least number principle for arbitrary (external) sets* — **fails**, and the
  failure is formalised: `no_least_unlimited` shows `H ↦ H - 1` produces an
  infinite descending chain of unlimited elements.  Correspondingly, the
  unlimited part is not internal (`unlimited_not_internal`).
* *Induction for arbitrary predicates* — **fails**: `external_induction_fails`
  ("is standard" is closed under `0` and successor but is not everything).
* *Uniqueness of the "next hyperprime"* — holds, but only because the
  minimality is taken inside the internal set of primes exceeding `H`; the
  pointwise `minFac`-style witnesses above are **not** minimal in general,
  which is why `exists_least_hyperprime_gt` goes through
  `internal_least_element` rather than through a direct construction.
* *Sequences with two different standard parts at unlimited indices* — found:
  `(-1)^n` at `[2i]` and `[2i+1]`, formalised as
  `alternating_not_convergent`.

No OEIS lookup was relevant: the sequences appearing above (`⌊n/2⌋`, triangular
numbers, primes) are elementary and appear only as witnesses, not as objects of
study.
