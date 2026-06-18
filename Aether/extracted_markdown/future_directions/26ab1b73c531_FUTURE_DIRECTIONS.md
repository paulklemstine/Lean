# Future Directions: Cryptography from Iterated Collatz Maps

This cycle produced `Cryptography/CollatzPreimageStructure.lean`, which extends the
catalog module `Cryptography.CollatzOWF`. The catalog file established the *lower*
side of the preimage picture (`at_least_one_preimage`: every positive value keeps
its even preimage `2n`) and a *conditional* collision result
(`pigeonhole_collisions`, which needs an image-compression hypothesis). The new
file closes three gaps:

* the matching **upper** bound `preimage_ncard_le_two` (every value has at most two
  one-step preimages), so together with the lower bound the branching factor is
  pinned to `{1,2}` by `preimage_branching`;
* an **unconditional** collision `iterate_collision` / `iterate_not_injective`
  (the inputs `1` and `8` collide after every `a ≥ 1` steps, because `T(1)=T(8)=4`),
  removing the compression hypothesis;
* an honest **refutation** of the source concept's central claim:
  `hash_not_collision_resistant` shows the Collatz hash is provably *not* collision
  resistant, so any cryptographic value must come from one-wayness alone.

The directions below build on exactly these results.

## 1. Exact preimage count as an arithmetic predicate

The branching theorem `preimage_branching` says the preimage count is `1` or `2`,
but it does not yet say *which*. Conjecture: the count is exactly `2` precisely when
`n ≡ 4 (mod 6)` (equivalently, `(n-1)/3` is a positive odd integer that maps to `n`),
and exactly `1` otherwise. **The key insight is** that the odd branch `(n-1)/3` is a
genuine second preimage iff it is a positive *odd* number, which is a clean residue
condition mod `6` — turning the qualitative "1 or 2" into a decidable arithmetic
gate. **Why now?** We already have `preimage_mem_pair` isolating the two candidate
values; the only missing step is a validity criterion for the odd candidate, which
is pure `omega`-style modular arithmetic and needs no new theory. This converts the
average branching factor into an exact density statement (`5/6` of values branch
once, `1/6` branch twice), the rigorous form of "2-to-1 on average."

## 2. Two-step preimage cardinality and the start of the tree law

Iterating the one-step bound, the depth-`d` preimage set should satisfy
`ncard ≤ 2^d`. Conjecture: `{k | collatzOWF d k = n}.ncard ≤ 2 ^ d`, with the base
case `d = 0` trivial and the inductive step gluing one-step fibers via
`preimage_ncard_le_two`. **The key insight is** that the depth-`d` fiber is the
disjoint union, over the (at most two) one-step preimages, of their depth-`(d-1)`
fibers, so the bound multiplies cleanly under composition. **Why now?** The
single-step upper bound `preimage_ncard_le_two` is the exact lemma an induction
needs; the catalog already defines `collatzIter_add` for the composition algebra, so
the proof is an induction with a finite-union cardinality estimate rather than new
mathematics. This is the formal backbone of the "exponentially fanning preimage
tree" that the one-wayness heuristic rests on.

## 3. A formal one-wayness game and an inversion-cost lower bound

Define an adversary as any function `A : ℕ → ℕ → ℕ` (taking `(a, target)` to a
guess) and say it `inverts at depth a` if `collatzOWF a (A a (collatzOWF a n)) =
collatzOWF a n` for all `n` in a range. Conjecture: any adversary that is *correct*
must, on inputs of the form `T^a(v)`, output a value of size `≥ 2^a` for the
`even-only` trajectories produced by `iter_double_preimage` (catalog), so its output
length — hence its running time in any reasonable model — is `Ω(a)` bits, i.e.
exponential in the security parameter measured in the target's bit-length. **The key
insight is** that the catalog witness `collatzOWF a (2^a * v) = v` exhibits preimages
that are exponentially larger than the target, so even *writing down* a correct
preimage costs linearly many bits in `a`. **Why now?** `exponential_preimage_witness`
already supplies the hard instances; we only need to wrap them in a `structure`
modelling an adversary and prove an output-size lemma, giving the first machine-
checked (unconditional, model-relative) inversion lower bound for this primitive.

## 4. Replace the hash with a provably injective keyed variant

Because `hash_not_collision_resistant` kills collision resistance for the raw map,
the natural fix is to iterate only the *invertible* even branch: define
`evenHash k x = 2^k * x` (always reversible by `iter_double_preimage`). Conjecture:
`evenHash k` is injective for every `k`, and its inverse costs exactly `k` halvings,
so it is a clean trapdoor permutation skeleton while the *mixed* Collatz map remains
the one-way direction. **The key insight is** that splitting the Collatz map into its
deterministic even branch (a bijection onto evens) and its expanding odd branch
isolates exactly where injectivity is lost, so a keyed primitive can keep the good
half. **Why now?** `even_preimage` and `iter_double_preimage` already prove both
injectivity and explicit invertibility of the doubling map; formalizing
`Function.Injective (evenHash k)` is a one-line consequence, and it gives a *positive*
companion to the negative `hash_not_collision_resistant`.

## 5. Collision *abundance*, not just existence

We proved a single collision pair survives all depths. Conjecture: the number of
colliding pairs grows without bound — for every `N` there are at least `N` distinct
unordered pairs `{x,y}` with `collatzOWF 1 x = collatzOWF 1 y`, witnessed by the
families `x = 2m`, `y = (4m-1)/3` whenever the latter is a valid odd preimage (cf.
Direction 1). **The key insight is** that each value with two preimages (the `1/6`
residue class from Direction 1) contributes one fresh collision pair, so collisions
are not an artifact of the `(1,8)` example but a positive-density phenomenon. **Why
now?** Once Direction 1 characterizes two-preimage values by a residue condition, the
collision pairs are produced by an explicit formula, and counting them reduces to
counting an arithmetic progression below `N` — elementary once the characterization
is in place. This quantifies *how badly* collision resistance fails, sharpening the
honest correction made by `hash_not_collision_resistant`.
