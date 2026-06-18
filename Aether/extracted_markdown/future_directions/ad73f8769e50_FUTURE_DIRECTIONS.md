# Future Directions — Berggren-Word Lattice Reduction as Height Descent

## Synthesis

The new file `Catalog/Bridges/BerggrenHeightReduction.lean` closes the loop on the
Berggren material scattered across the catalog. The cryptography file
`Cryptography/BerggrenLatticeReduction.lean` had built the *forward* theory — the
three generators `actGen` grow the hypotenuse, `evalAtRoot` is injective (the
positive Berggren semigroup is free) — and `Algebra/BerggrenLorentz/Core.lean`
had supplied the conserved Lorentz form `a² + b² − c²`. What was missing was the
*inverse* direction: a certified, terminating reduction that takes an arbitrary
primitive Pythagorean triple back down to the root.

We supplied it. Concretely we defined the explicit inverse generators `invGen`
(the action of `matₓ⁻¹ = Q·matₓᵀ·Q`), the deterministic predecessor selector
`predGen`, and proved the full package:

* **`pred_spec`** — every non-root tree triple has the explicit predecessor
  `pred t = invGen (predGen t) t`, again a tree triple, of *strictly smaller
  height*, mapping forward onto `t`.
* **`predecessor_unique`** — the predecessor move is the *only* generator-inverse
  landing on a good triple.
* **`berggren_canonical`** — every tree triple is the image of a **unique**
  Berggren word (existence by descent, uniqueness by freeness).
* **`normalForm` / `normalForm_eval` / `normalForm_length_le`** — a recursive
  extractor, well-founded on the height, that terminates and re-evaluates to its
  input, with descent length bounded by the hypotenuse.

The mathematical heart is the sign-pattern dichotomy: with `p = a+2b−2c`,
`q = 2a+b−2c`, the three inverse images have first two coordinates `(p,−q)`,
`(p,q)`, `(−p,q)`, and exactly one is positive because `p ≠ 0` is *parity*,
`q ≠ 0` is *primitivity*, and `(p<0 ∧ q<0)` is *geometrically impossible*. This
is a self-contained Lean formalization of the Barning–Hall / Berggren tree
completeness theorem, repackaged as a lattice-reduction algorithm with proof
certificates.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `invGen_actGen`, `actGen_invGen` | `invGen` is a two-sided inverse of `actGen` | ✅ |
| `tripleQ_invGen` | descent preserves the Lorentz form (stays on the light cone) | ✅ |
| `invGen_preserves_gcd` | predecessor preserves primitivity | ✅ |
| `pred_spec` | predecessor theorem (exists, tree, smaller height, forward) | ✅ |
| `predecessor_unique` | uniqueness of the predecessor move | ✅ |
| `berggren_canonical` | unique canonical reduced word for each tree triple | ✅ |
| `normalForm_eval` | the reduction algorithm is correct | ✅ |
| `normalForm_length_le` | quantitative termination bound | ✅ |

All depend only on `propext`, `Classical.choice`, `Quot.sound`. Zero `sorry`.

## Conjectures for the Next Cycle

**1. Logarithmic depth bound for the reduction.**
We proved `normalForm_length_le : (normalForm t).length + 5 ≤ tripleHeight t`, a
*linear* upper bound. The conjecture is the matching *logarithmic* statement:
there is a constant `K` with `(normalForm t).length ≤ K · Nat.log 2 (tripleHeight t)`
for all tree triples `t`, i.e. the Berggren reduction is exponentially fast.
The key insight is that the B-branch already triples the hypotenuse and every
generator at least multiplies `c` by a factor `> 1` bounded away from `1`
(the `hyp_strictly_increases` data can be sharpened to `c < (actGen g t).2.2 ≤ 7c`),
so the inverse contracts geometrically. Falsifiable: exhibit a family of triples
whose `normalForm` length grows faster than any logarithm of the height. Why now?
The `logRatHeight`/`Nat.log` height machinery is already imported and used in
`Bridges/ArithmeticOperadicStability.lean`, so the statement can reuse the exact
same height vocabulary and slot directly into the height-descent bridge.

**2. Equivalence with the 2×2 Gauss/continued-fraction reduction.**
`EML/LatticeTreeCorrespondence.lean` has the 2×2 Berggren matrices
`berggren_M₁', berggren_M₃'` and their inverses as continued-fraction steps on
`(m,n)`. The conjecture is that the 3-generator descent `predGen` on `(a,b,c)`
is *conjugate* to the 2×2 reduction on the Gaussian parameters `(m,n)` with
`(a,b,c) = (m²−n², 2mn, m²+n²)`: there is a length-preserving bijection between
Berggren words and reduced `SL(2,ℤ)` words. The key insight is that `predGen`'s
sign test on `(p,q)` is exactly the quotient/swap decision of Gauss's algorithm
once `(a,b,c)` is pulled back to `(m,n)`. Falsifiable: find a triple whose 3-gen
descent length differs from its 2×2 reduction length. Why now? Both halves are
already formalized in the catalog (`EML` 2×2 side, this file's 3×3 side); only the
parametrization bridge `(m,n) ↔ (a,b,c)` is missing.

**3. Tree triples are in bijection with Berggren words.**
`berggren_canonical` gives, for each tree triple, a unique word; the converse —
`evalAtRoot w` is always a tree triple — needs only that `actGen` preserves the
full `TreeTriple` invariant (primitivity + oddness forward), which is the dual of
`invGen_preserves_gcd`/`invGen_preserves_odd` we already proved. The conjecture
is therefore a clean **equivalence of types** `BerggrenWord ≃ {t // TreeTriple t}`
realized by `evalAtRoot`/`normalForm`. The key insight is that the forward and
backward primitivity-preservation proofs are mirror images, so the round trips
`normalForm ∘ evalAtRoot = id` and `evalAtRoot ∘ normalForm = id` both reduce to
the already-proved `evalAtRoot_injective` and `normalForm_eval`. Falsifiable: a
word `w` with `evalAtRoot w` not primitive, or a primitive triple missed by the
bijection. Why now? It upgrades the existing freeness result into a structural
classification — the single most reusable statement for downstream cryptography.

**4. Generalized descent for twisted Lorentz forms / Pell trees.**
`Computation/QuantumBerggrenWalk.lean` notes a Pell connection via the B-branch
hypotenuse recurrence. The conjecture is that the predecessor construction
generalizes to the form `Q_D(x,y,z) = x² + D y² − z²`: for suitable `D` there is
a finite generating set of `O(Q_D; ℤ)` whose positive semigroup admits the same
sign-pattern predecessor, giving canonical words for the solutions of
`x² + D y² = z²`. The key insight is that nothing in `pred_spec` used `D = 1`
beyond the discriminant inequality `5a²−8ab+5b² > 0`; replacing it by the
`D`-twisted quadratic positivity certificate should preserve the whole pipeline.
Falsifiable: a value of `D` for which no finite predecessor set decreases the
height (the orbit fails to be a tree). Why now? The Lorentz-form abstraction is
already in `Algebra/BerggrenLorentz/Core.lean`, so the twist is a parameter
change rather than a new theory.

**5. Average word length and a reduction-hardness heuristic.**
Combining `finite_nearby_words`/`candidateWordSet_finite` (cryptography file) with
the canonical word, the conjecture is a counting law: the number of tree triples
of height `≤ H` equals the number of Berggren words `w` with `tripleHeight
(evalAtRoot w) ≤ H`, and this count grows like `H^{log_2 3 / 1}`-style polynomially
in the *word length* but the *height threshold* induces an exponential gap,
quantifying a one-way "easy to grow, certified to reduce" asymmetry. The key
insight is that `height_lower_bound_root` makes the word-length-to-height map
provably expanding, so the candidate-set finiteness yields explicit codebook
sizes. Falsifiable: a height regime where the two counts diverge, or where the
asymmetry collapses. Why now? The finiteness and pruning lemmas already exist in
`Cryptography/BerggrenLatticeReduction.lean`; pairing them with `normalForm`
turns them into a quantitative complexity statement for the `cryptographic_gravity`
research arc.
