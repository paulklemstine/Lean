# Future Directions: Berggren Reduction Certificates

The file `Catalog/Bridges/BerggrenReductionCertificate.lean` builds an inverse
descent on the Berggren tree of primitive Pythagorean triples and proves it is a
*certified reduction algorithm*: every primitive triple `(a,b,c)` (positive,
coprime legs, `a` odd, `b` even) admits a unique reduced Berggren word back to
the root `(3,4,5)`, the admissible inverse move at each step is unique, and it is
selected purely by the sign of two Lorentz discriminants `ppForm = a+2b-2c` and
`qqForm = 2a+b-2c`. This bridges the geometric Lorentz picture
(`Algebra/BerggrenLorentz/Core.lean`, `lorentzQ`, `IsPythag`) with the
algorithmic word picture (`Cryptography/BerggrenLatticeReduction.lean`, `actGen`,
`evalWord`, `evalAtRoot_injective`). Several concrete continuations follow.

## 1. A sharp logarithmic length bound for the normal-form word

We proved descent terminates and `height_lower_bound_root` already gives
`5 + |w| ≤ tripleHeight (evalAtRoot w)`, i.e. a *lower* bound on the hypotenuse in
terms of word length. The reduction certificate now lets us ask for the matching
*upper* bound: there should be a constant `K` with
`(nfWord t).length ≤ K · Real.log (tripleHeight t)` for every primitive `t`.
Combined with the existing linear lower bound this would pin the word length to
`Θ(log c)`, making the certificate a genuine `O(log c)` data structure.
**The key insight is** that each inverse step replaces the hypotenuse `c` by
`3c − 2a − 2b`, and from `2(a+b) ≤ 3c` (already formalized as `inv_hyp_pos`) plus
`c < a+b` (as `inv_hyp_lt`) one gets a uniform multiplicative contraction
`3c − 2a − 2b ≤ (1 − δ)c` for an explicit `δ > 0`, which integrates to a
logarithmic depth. **Why now?** The descent contraction inequalities are already
isolated as standalone lemmas (`inv_hyp_pos`, `inv_hyp_lt`), so the only missing
ingredient is converting a per-step multiplicative drop into a length bound — a
self-contained real-analysis induction that needs no new geometry. This is
falsifiable: a triple whose certificate length exceeds `K·log c` for every `K`
would refute it.

## 2. Prefix-stability of certificates under the forward action

`certificate_unique` gives a unique reduced word `nfWord t`; the forward lemma
`evalWord_append` says `evalWord (g :: nfWord t) = actGen g t`. The conjecture is
the exact compatibility `nfWord (actGen g t) = g :: nfWord t` for every primitive
`t` and generator `g` — i.e. the normal form is a true *prefix code* in which one
forward Berggren move is exactly one letter prepended, with no rewriting of the
tail. **The key insight is** that `admissible_parent_unique` already shows the
inverse move is unique, so `parentGen (actGen g t) = g` should hold by the same
sign analysis applied to the image discriminants; the tail then matches by
`parent (actGen g t) = t` (a consequence of `invGen_actGen`). **Why now?** Both
halves — uniqueness of the inverse generator and the left-inverse identity
`invGen_actGen` — are already proved, so the conjecture reduces to a single
discriminant-sign computation. It is falsifiable: any `(g, t)` with
`parentGen (actGen g t) ≠ g` breaks it, and such a counterexample is decidable by
`#eval`.

## 3. Lorentz-norm cost monotonicity and a metric on the tree

The descent strictly decreases the hypotenuse height. A stronger, geometric
statement is that the *Lorentz-perimeter cost* `a + b + c` is also strictly
decreasing under `parent`, and moreover that the path metric
`d(s,t) = |nfWord s| + |nfWord t| − 2·|lcpWord (nfWord s) (nfWord t)|` (using the
existing `lcpWord`) is a genuine tree metric realizing geodesic distance between
triples. **The key insight is** that `a+b+c` and the hypotenuse `c` are
*simultaneously* monotone because all three inverse generators share the third
coordinate `3c−2a−2b`, so a single inequality controls every coordinate's
descent; the longest-common-prefix machinery (`lcpWord_prefix_left/right`,
`lcpLength_le_left`) already in the catalog then turns word lengths into a metric.
**Why now?** The reduction certificate makes `nfWord` total on primitive triples,
which is exactly the input the `lcpWord` rigidity theorems
(`prefix_rigidity_exact`) were waiting for; the perimeter monotonicity is one more
`nlinarith` in the spirit of `inv_hyp_lt`. Falsifiable: a primitive triple whose
parent has equal or larger perimeter would refute the monotonicity half.

## 4. Reduction modulo a prime: certificates as `ZMod p` invariants

Because every step is unimodular over `ℤ`, the descent commutes with reduction
modulo `p`. The conjecture is that for each odd prime `p` the map
`t ↦ (nfWord t).length mod (period_p)` is eventually periodic along
`B`-branches, governed by the order of the Berggren `B`-matrix in `GL₃(ZMod p)`,
giving a cheap *fingerprint* that distinguishes triples without computing the full
certificate. **The key insight is** that the `B`-branch hypotenuse recurrence is a
Pell-type linear recurrence (already noted in `Computation/QuantumBerggrenWalk.lean`),
so its reduction mod `p` is a linear recurrence over a finite field and hence
periodic by pigeonhole; the certificate length inherits this periodicity through
`parent_descent`. **Why now?** The catalog already contains the Pell connection
and the Lorentz-preservation `MᵀQM = Q`, so the matrices are known to lie in
`O(2,1; ZMod p)`; the new total `nfWord` is what lets us define the length-mod-`p`
fingerprint in the first place. Falsifiable: exhibit a prime `p` and branch along
which the length residue is provably aperiodic.

## 5. A cryptographic shortest-certificate hardness assumption

Treat the reduced word `nfWord t` as a secret key and the triple `t` (a single
large integer pair) as the public value. Forward evaluation `evalWord` is cheap,
and `certificate_unique` guarantees the key is *uniquely* determined, ruling out
key-equivocation. The conjecture is a quantitative trapdoor: recovering `nfWord t`
from `t` *without* the descent rule is no easier than factoring the legs, while
*with* the discriminant-sign rule it is `O(log c)`. **The key insight is** that
`admissible_parent_unique` collapses the seemingly ternary search at each node to
a single decidable inequality test, so the asymmetry between "knows the Lorentz
discriminants" and "does not" is exactly the gap that a hardness assumption can be
hung on — connecting `Cryptography/BerggrenLatticeCryptography.lean`'s SVP bounds
to a concrete shortest-word problem. **Why now?** The reduction is now *certified*
(unique, terminating, height-decreasing) rather than heuristic, which is the
prerequisite for any honest hardness claim; the candidate assumption can be
stress-tested immediately against the existing `candidateWordSet_finite` and
`finite_nearby_words` enumeration bounds. Falsifiable: a polynomial-time recovery
of `nfWord t` from `t` alone that does not implicitly recompute the discriminants
would refute the asymmetry.
