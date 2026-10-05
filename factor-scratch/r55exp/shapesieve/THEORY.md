# THEORY: why shape-sensitivity cannot enter a sieving primitive

Worked out before the measurements, so the measurements can refute it.

## 1. What a sieving primitive actually is

Every sieving method for integer factoring — Dixon, QS, NFS, ECM stage 1,
Coppersmith factor-base sieves — has the same skeleton:

1. a **candidate set** `C`, an index set of size `M` (usually `M = |{u : 0 < u < X}|`
   for some range `X`, or a box `(u,v)` in the number-field case);
2. a **sieving function** `g(u)` producing an integer of size `~N^theta`
   (`theta = 1/2` for Dixon/QS on the natural range, `theta = 1/d` for NFS);
3. a **factor base** `Q = {q prime : q <= B}`;
4. the test "`g(u)` is `B`-smooth", implemented by sieving: for each `q in Q`,
   cross off the `u` with `q | g(u)`.

Cost accounting, precisely:

    total marking cost  =  sum_{q in Q}  #{u in C : q | g(u)}
                       ~  sum_{q in Q}  M / q        (if `g` is equidistributed mod q)
                       =  M * log log B  (Mertens)

    survivors          =  M * rho(u),  u = log(max g)/log B  (Dickman)

    cost PER RELATION  =  (M log log B) / (M rho(u)) = log log B / rho(u)

**This is the whole cost model.** Note what is *not* in it: no `N` except through
`log(max g)` and through the equidistribution of `g` mod `q`.

## 2. THE SHAPE-BLINDNESS MECHANISM (this is the closure argument)

Claim (Shape-Blindness Lemma). Fix a sieve with parameters `(B, X)`. Suppose
`g(u)` is a fixed polynomial/rational function of `u` with `gcd` of
coefficients coprime to `N`, evaluated modulo `N` and reduced to `[0,N)`. Then

  (a) `#{u in [0,X) : q | g(u)} = X/q + O(q^{deg g - 1} X^{1/2}/q^{1/2} + q^{deg g})`
      — an equidistribution statement whose error term is a function of `B` and
      `deg g` ONLY. The shape of `N` does not appear.
  (b) Therefore the marking cost `sum_q #{u : q | g(u)}` is, to within the
      error term, `M log log B` for *every* `N` of the same size.
  (c) And `rho(u)` depends only on `log(max g)/log B`, i.e. on `log N`.
  (d) Hence cost per relation is a function of `(log N, B)` only.

**So a sieving primitive whose sieving function `g` is a fixed function of `u`
and `N` is shape-blind — and this is a theorem about the *structure of the
sieve*, not a property of the particular implementations we happen to have.**

## 3. Where shape COULD enter: the only three channels

For shape to enter, one of these must be non-rigid:

**Channel A — `g` depends on the shape.** If `g` is chosen using knowledge of
the factorization shape of `N`, the equidistribution error (a) changes.
  *What stops it*: to choose `g` you need `minFac N`, and computing `minFac N`
  for `N = a^k b` IS the factoring problem for that shape (Pollard's rho does it
  in `sqrt(a)`). **The channel is closed by the discovery cost, not by the
  sieve cost.** Moreover for `N = a^2 b` the corpus itself notes `a` is visible
  (it is the largest square divisor) — but then you have already factored `N`.

**Channel B — the range `X` shrinks because the shape tells you where to look.**
This is not a new primitive; it is **Pollard's rho**, which is exactly "search
a range of length `sqrt(a)` for a factor of `N`." Its cost is `sqrt(a)` and the
shape-sensitivity is total. This is the corpus's own observation.

**Channel C — the factor base `Q` is augmented by shape-derived primes.** If
`a <= B`, then `a` is in the factor base and `N = a^2 b` factors immediately:
`gcd` any relation against `a`. So the channel exists but only in a regime
where trial division / rho has already won by a polynomial margin.

## 4. THE SHAPE SIEVE IS ALREADY BUILT, AND IT IS NOT A SIEVE

**This is the load-bearing observation.** Pollinger up:

- **Pollard p-1**: cost `~ B` where `B` is the smoothness bound for `p-1`. The
  "sieving" is a group-order smoothness test, and it *is* shape-sensitive in
  the only sense that matters: if `p-1` is `B`-smooth for small `B`, you win.
  The `B`-smoothness test on `p-1` costs `~ B` — this is a smoothness test on a
  SINGLE quantity whose size is controlled by the shape.
- **ECM**: cost `L_p[1/2, sqrt(2)]` where `p` is the smallest prime factor.
  Stage 1 is again a smoothness sieve, on the group order.
- **Seysen / class-group methods**: cost `L[1/2, c]` on the class group of
  `Q(sqrt N)`.

All of these have cost governed by `minFac N` — they ARE shape-sensitive. The
corpus's table notes this. **What they have in common is that they are NOT
`sieving a range`.** The reason is now visible from §1: a *range* sieve pays
`M log log B / rho(u)` with `M` proportional to the range length, and the range
length is chosen from `log N` because you have no idea where the factors are.
Shape-sensitivity would let you shrink `M`, but shrinking `M` means searching a
*range*, and searching a range for a factor is precisely rho. **The moment
shape-sensitivity shortens the range, the method has stopped being a sieve.**

## 5. THE FORMAL CLOSURE STATEMENT

Let `A` be an algorithm that factors `N` and whose cost is
`T_A(N) = F(log N, sigma(N))` where `sigma(N)` is any computable function of
`N` that is *not* determined by `log N` (i.e. `sigma` is shape-sensitive).
Suppose moreover that `A` is a **range sieve**: it enumerates candidates
`u in [0, X)` with `X` determined by `log N` and `B`, and forms relations from
`B`-smooth values of a `deg`-bounded `g(u)`.

Then:

  (i)   By §2, `T_A(N) = F'(log N)` for some `F'` independent of `sigma`,
        so the shape channel contributes a CONSTANT.

  (ii)  For the shape channel to be non-constant, `X` or `B` or `g` must
        depend on `sigma(N)`.

  (iii) If `B` depends on `sigma`: `B >= minFac N`, so `minFac N <= B`, and
        trial division to `B` already costs `B >= minFac N`. Since
        `minFac N <= B <= L_N[1/3,c] / something`... more precisely the regime
        `minFac N <= B` is the regime where `rho` costs `sqrt(minFac N) <= sqrt(B)`,
        which **beats** the sieve, whose cost is at least `B`-ish. So the
        shape-in-`B` channel only helps where a better method already wins.

  (iv) If `X` depends on `sigma`: then the algorithm searches a sub-range of
        `[0,X)` determined by `sigma`, and finding a factor of `N` in a
        prescribed range is the **congruence-of-squares / rho** problem. The
        best known cost is `~sqrt(r)` for a range of length `r`
        (Baby-step giant-step on the group), so shrinking the range from `X`
        to `r` costs `sqrt(X/r)`, a saving of `sqrt(r)` in candidates — but you
        pay `sqrt(minFac N)` for rho instead, and rho is *shape-optimal* here.

  (v)  If `g` depends on `sigma`: `g` has coefficients depending on `sigma(N)`,
        which requires computing `sigma(N)`; for the shapes in question
        (`a^k b`) computing `sigma` is rho's job.

**Therefore: within the class of range sieves, the shape-sensitivity channel
is closed — every opening is either (a) a rho/BSGS search in disguise, or
(b) available only where a polynomial-cost method already wins.**

## 6. WHAT THIS DOES NOT PROVE

- It does not prove no shape-sensitive primitive exists in the *unrestricted*
  class. It closes the range-sieve class.
- It does not address methods that are not range sieves: e.g. a
  non-range-based smoothness test, or an oracle that gives smoothness of a
  *specific structured* integer for free.
- The exponent/constant question (`L[1/2, c<1]`) is untouched by this.

## 7. THE POSITIVE COROLLARY (the actual deliverable)

**Corollary.** The cheapest shape-sensitive primitive is the one that reads the
shape and then searches: cost `~ sqrt(minFac N)`, and the shape is readable at
cost `~ sqrt(minFac N)` as well (rho's own cost). So the shape channel has
**zero net value**: you pay `sqrt(minFac N)` to learn the shape and `sqrt(minFac N)`
to exploit it, whereas rho pays `sqrt(minFac N)` once. **The shape-aware sieve
must be `sqrt(minFac N)` MORE expensive than just being rho.**

This is exactly the corpus's own walk-back ("on the `a^2 b` shape the right
answer is *just use rho*"), and §5 shows the walk-back is not a detail — it is
forced.
