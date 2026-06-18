# Future Directions — Tropicalization of Arithmetic Height along Berggren Transfer Morphisms

## Synthesis

The new file `Catalog/Bridges/TropicalBerggrenHeight.lean` closes a genuine
cross-domain loop in the catalog. It composes the rational arithmetic-height
observable `ratArithHeight` (from `Bridges/ArithmeticVCDimension.lean`) with the
evaluation map of the three Berggren generators (`berggrenA/B/C`, present in
`Bridges/BerggrenEntropyExtractor.lean`, `Cryptography/BerggrenLatticeReduction.lean`,
and `Algebra/BerggrenLorentz/Core.lean`) and the word/boundary formalism of
`Bridges/BerggrenTransferDuality.lean`. The central observable is

  `htHeight t = ratArithHeight (hypotenuse t : ℚ) = |c| + 1`,

and the work proves a complete chain: a per-generator one-step sandwich
`htHeight t < htHeight (act g t) ≤ 7 · htHeight t` on positive Pythagorean
triples, its inductive lift to words
`6 + |w| ≤ htHeight (evalRoot w) ≤ 7^{|w|} · 6`, boundary control over the
depth-`d` prefix-closed subtree, a multiplicative transfer inequality
`htHeight (evalRoot (u ++ v)) ≤ 7^{|u|} · htHeight (evalRoot v)`, and finally its
tropical (min-plus) shadow `logHeight (u ++ v) ≤ |u| + logHeight v`, restated as
a true inequality in Mathlib's `Tropical ℕ` semiring.

## Results Summary

* `htHeight_root`, `one_le_htHeight` — root normalization and positivity floor.
* `act_pyth`, `act_pos`, `eval_pyth`, `eval_pos` — structural invariance of the
  Pythagorean light cone and coordinate positivity under generators and words.
* `hyp_lt_act`, `hyp_act_le`, `htHeight_act_lt`, `htHeight_act_le` — the one-step
  comparison sandwich (strict growth + multiplicative ceiling 7).
* `htHeight_eval_le`, `htHeight_eval_ge` — word-length induction giving the
  additive floor and multiplicative ceiling.
* `htHeight_evalRoot_le/_ge`, `boundary_sup`, `boundary_inf`,
  `htHeight_evalRoot_mono` — depth-`d` boundary band `[6+d, 7^d·6]` and prefix
  monotonicity.
* `htHeight_transfer`, `tropical_transfer`, `tropical_transfer_trop` — the bridge:
  multiplicative subadditivity and its genuine min-plus shadow.

All main results compile with `sorry = 0` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## Falsifiable Research Directions

### 1. Sharp per-generator height ratio and the true tropical slope

The proven ceiling uses the uniform, deliberately loose constant `7`. Numerically
the one-step hypotenuse ratio `c'/c` stays strictly below `6` and, more sharply,
each generator has its own asymptotic ratio governed by the dominant eigenvalue of
its `3×3` Berggren matrix (the spectral radius is `3 + 2√2 ≈ 5.828`). The
conjecture: for every positive Pythagorean triple and every generator,
`c' ≤ (3 + 2√2)·c`, and along the all-`B` word the ratio converges to `3 + 2√2`.
**The key insight is** that the tropical slope of `logHeight` along a fixed-letter
ray is exactly `log_7(3 + 2√2)`, i.e. the additive transfer constant is the
log-eigenvalue of the transfer matrix, not the crude `1` we currently bound by.
**Why now?** The Lorentz/eigenstructure of the Berggren matrices is already
formalized in `Algebra/BerggrenLorentz/Core.lean`, so the eigenvalue input exists;
replacing the constant `7` by the spectral bound would upgrade `tropical_transfer`
from a coarse `≤ |u| + logHeight v` to a slope-exact statement. This is falsifiable:
exhibit one positive Pythagorean triple with `c' > (3+2√2)c` and the conjecture dies.

### 2. Two-sided tropical band: a matching additive lower transfer bound

Currently the lower control is only additive in word length (`6 + |w|`), while the
upper control is multiplicative. The conjecture: there is a generator-uniform
constant `κ > 1` with `htHeight (act g t) ≥ κ · htHeight t` for positive triples,
hence `logHeight (u ++ v) ≥ |u|·log_7 κ + logHeight v − C`. Together with Direction 1
this would sandwich `logHeight` between two parallel lines of positive slope,
turning the min-plus shadow into a genuine two-sided tropical *valuation*.
**The key insight is** that the boundary inf/sup over the depth-`d` shell would then
collapse to a tropical interval of width `O(d)`, i.e. all boundary words become
log-height-equivalent up to a bounded tropical gap — a finiteness statement of the
same flavor as the Hankel-rank finiteness in `BerggrenTransferDuality.lean`.
**Why now?** The strict one-step growth `hyp_lt_act` is already proven; promoting
"strictly bigger" to "bigger by a factor `κ`" is a localized nlinarith strengthening,
and the rest of the induction infrastructure (`htHeight_eval_ge`) transfers verbatim.
Falsifiable: a triple with `c'` only `1` larger than `c` refutes any `κ > 1`.

### 3. Functoriality on the full GL₃(ℤ) Berggren monoid, not just words at the root

The present observable is anchored at the root `(3,4,5)`. The conjecture: the
transfer inequality is a property of the *monoid action*, not the root —
`htHeight (eval u t) ≤ 7^{|u|} · htHeight t` for every positive Pythagorean `t`
(already proven as `htHeight_eval_le`), and moreover the induced map on the
quotient by the height-band relation is a monoid homomorphism into `(Tropical ℕ, ⊗)`.
**The key insight is** that `eval_append` makes word concatenation into function
composition, so `tropShadow` is a *lax monoid morphism* from `(BWord, ++)` into the
tropical semiring; promoting "lax" (inequality) to "strict" (equality) on a suitable
height-graded quotient would identify the exact tropical character of the Berggren
monoid. **Why now?** `tropical_transfer_trop` already lands in `Tropical ℕ`; the
missing piece is the reverse inequality of Direction 2, after which the homomorphism
property is a two-line consequence. Falsifiable: any pair `u,v` with
`logHeight(u++v) ≠ |u| + logHeight v` on the quotient breaks strict functoriality.

### 4. Density / Northcott finiteness of the height-banded boundary shell

`boundary_sup`/`boundary_inf` show every depth-`d` boundary word has height in
`[6+d, 7^d·6]`. The conjecture: the number of *distinct* triples appearing on the
depth-`d` boundary with height `≤ N` is finite and grows like `Θ(log N)` in depth,
mirroring a Northcott-type finiteness for the Berggren orbit. **The key insight is**
that the height ceiling `7^{|w|}·6` forces words realizing a bounded height to have
bounded length (`|w| ≤ log_7 N`), so the height-bounded boundary is the image of a
finite word set — exactly the finite-arithmetic-trace mechanism that
`ArithmeticVCDimension.lean` uses to bound pseudo-dimension. **Why now?** The
injectivity of root evaluation (`evalAtRoot_injective` in
`Cryptography/BerggrenLatticeReduction.lean`) already gives a bijection between words
and triples, so counting triples reduces to counting words of bounded length — a
clean Sauer–Shelah-style finite count. Falsifiable: produce infinitely many distinct
bounded-height boundary triples and the finiteness claim fails.

### 5. Tropical transfer for the alternative height (rational slope `a/c`)

We deliberately used the hypotenuse to keep `ratArithHeight` a clean `|c|+1`. The
conjecture: the analogous transfer inequality holds for the *slope* observable
`slopeHeight t = ratArithHeight ((a : ℚ)/c)`, namely
`slopeHeight (evalRoot (u++v)) ≤ 7^{|u|} · slopeHeight (evalRoot v)`, but with a
genuinely different (and possibly smaller) tropical slope because slope heights are
bounded by `|a| + c` rather than `c` and involve gcd reduction. **The key insight is**
that for primitive Pythagorean triples `gcd(a,c) = 1`, so `slopeHeight = |a| + c`
exactly, and the same matrix dynamics drives both legs — meaning the tropical shadow
of the slope height differs from that of the hypotenuse height only by a bounded
additive defect tied to leg/hypotenuse ratio. **Why now?** Primitivity and the
coprimality structure of Berggren children are exactly the arithmetic content of
`BerggrenEntropyExtractor.lean` (positivity and norm-growth of children), so the gcd
input is available; this direction would produce a *second*, independent tropical
character and let one compare the two shadows. Falsifiable: a primitive triple with
`gcd(a,c) ≠ 1`, or a word pair violating the slope transfer bound, refutes it.
