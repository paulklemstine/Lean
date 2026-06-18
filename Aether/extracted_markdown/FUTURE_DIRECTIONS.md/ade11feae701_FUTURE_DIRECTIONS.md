# Future Directions — Arithmetic-Height Monotonicity for Berggren Transfer Boundaries

## Synthesis

This cycle bridged the *combinatorial* boundary framework of
`Bridges/BerggrenTransferDuality.lean` (`prefixClosed`, `finiteBerggrenSubtree`,
`boundaryWords`, `prefixClosed_take_mem`, `boundaryWords_finite`, `exists_max_depth`)
with the *arithmetic-height* API of `Bridges/ArithmeticVCDimension.lean`
(`ArithmeticVCDim.ratArithHeight`, `ratArithHeight_pos`). The new file
`Bridges/ArithmeticBoundaryMonotonicity.lean` pushes each Berggren word through the
Berggren transfer action `evalWord` (the `(3,4,5)`-rooted iteration of the three
generator maps `actGen`, the same maps as `Algebra/BerggrenLorentz/Core` `childA/B/C`
and `Cryptography/BerggrenLatticeReduction` `actGen`) to a Pythagorean state, and
measures the coordinatewise rational arithmetic height `triHeight`.

## Results Summary (all proved, `sorry`-free, only standard axioms)

- `evalWord_good` — the order invariant `0 < a, 0 < b, a < c, b < c` is preserved by
  **all three** generators; this single fact powers every height bound.
- `evalWord_pythagorean` — transfer states never leave the light cone `a² + b² = c²`.
- `triHeight_eq` — on the positive cone the height collapses to `a + b + c + 3`.
- `triHeight_step_lb` — **additive monotonicity**: `triHeight w + 10 ≤ triHeight (w ++ [g])`.
- `triHeight_lt_extend`, `triHeight_mono_append` — strict / weak monotonicity along
  one-step and arbitrary right extensions.
- `triHeight_linear_lb` — `15 + 10 · |w| ≤ triHeight w`: height certifies depth.
- `boundary_mem_prefixes_extend`, `boundaryWords_nonempty` — boundary structure.
- `exists_min_height_boundary` — **transfer-selection**: every finite Berggren subtree
  has a canonical minimal-height boundary representative.

The headline surprise: monotonicity is *strict and uniformly additive* (`+10` per step),
strictly stronger than the "cannot decrease" target, and it needs only the order
invariant — Pythagoreanness is a passenger, not a hypothesis.

## Falsifiable Research Directions

**1. Sharp per-generator step spectrum.**
We proved the uniform bound `+10`, but the three generators are *not* symmetric: at the
root, `A` adds `18`, `B` adds `30`, `C` adds `14` to the coordinate-sum height. Conjecture:
for every word `w` with state `(a,b,c)` the exact increments are `Δ_A = 4a + 6(c−b)`,
`Δ_B = 4a + 4b + 6c`, `Δ_C = 6(c−a) + 4b`, and consequently `B` is *always* the
height-maximal child while the height-minimal child alternates between `A` and `C`
according to the sign of `(c−b) − (c−a) = a − b`. The key insight is that the additive
height increment is an explicit *linear functional of the current state*, so the
"cheapest frontier extension" is decidable from a single sign test `a ⋚ b`. Why now? The
closed form `triHeight = a+b+c+3` from this cycle turns each increment into pure linear
arithmetic, making the comparison `omega`-checkable and the minimizing-child selection a
one-line decision procedure — exactly the primitive a branch-and-bound frontier search
needs. Falsifiable: a single word where the minimal child disagrees with `sign(a−b)` kills it.

**2. Height-stratified frontier counting and a Northcott bound.**
Conjecture: the number of boundary words of height `≤ H` in any Berggren subtree is finite
and bounded by a polynomial in `H`, because `triHeight_linear_lb` forces `|w| ≤ (H−15)/10`
and each depth level has at most `3^{|w|}` words — but the additive lower bound actually
collapses this to far fewer realizable heights. The key insight is that arithmetic height
is a *Northcott function* on Berggren words: finitely many words below any height bound,
with an explicit depth ceiling. Why now? `triHeight_linear_lb` already gives the depth
ceiling and `boundaryWords_finite` gives finiteness on subtrees; the missing step is a
counting lemma over `BerggrenWord` of bounded length, which is elementary `List`-combinatorics.
Falsifiable: exhibit infinitely many words of bounded height, or a super-polynomial growth rate.

**3. Monotonicity transfer to the *reduced* leg-ratio height.**
We deliberately used the coordinatewise height to avoid gcd reduction. Conjecture: along
the Berggren tree every state is a *primitive* triple, so the leg ratio `a/c` is already in
lowest terms and `ratArithHeight (a/c : ℚ) = |a| + c` is **also** strictly monotone under
generator extension. The key insight is that primitivity preservation (provable from the
matrix action mod small primes) upgrades the integer-coordinate result to a genuine height
on rational points of the unit circle, connecting to heights on `ℙ¹(ℚ)`. Why now? The
catalog already contains Pythagorean/Berggren primitivity machinery
(`Cryptography/BerggrenLatticeReduction`, `Algebra/BerggrenLorentz/Core`) and this cycle
supplies the order invariant `a < c`; combining them is the only obstacle. Falsifiable: a
Berggren descendant with `gcd(a,c) > 1`, or a generator step that decreases `|a| + c`.

**4. Two-sided height control and an inverse (reconstruction) bound.**
We have a lower bound `triHeight w ≥ 15 + 10|w|`. Conjecture: there is a matching
*geometric upper bound* `triHeight w ≤ 15 · 6^{|w|}` (the hypotenuse at most sextuples per
step), giving two-sided control `10|w| ≲ triHeight w ≲ 6^{|w|}`, and hence a *reconstruction*
statement: a finite Berggren subtree is determined up to `RootedIso`
(`Bridges/BerggrenTransferDuality`) by the multiset of its boundary heights together with
its depth profile. The key insight is that height sandwiches depth from both sides, so the
height histogram is a near-complete observable — tying this monotonicity result back to the
`berggren_transfer_duality` reconstruction theorem. Why now? `triHeight_eq` reduces both
bounds to explicit linear-recurrence estimates on `a+b+c`, and the duality scaffold for
"observables determine the subtree" is already proved in the catalog. Falsifiable: two
non-isomorphic subtrees with identical boundary-height multiset and depth profile.

**5. Failure boundary under generator restriction and weighted heights.**
Adversarial test: drop the order invariant by allowing the *inverse* generators
(matrices `actGen⁻¹`), which move toward the root. Conjecture: monotonicity *fails* exactly
on inverse steps and the height becomes a discrete Lyapunov function whose unique minimum on
each orbit is the root `(3,4,5)` — i.e. `triHeight` is a strict potential for the Berggren
*group* action, not just the semigroup. The key insight is that the `+10` forward bound makes
`triHeight` a coercive Lyapunov/word-norm, so descent must terminate at the root, yielding an
independent proof of the classical fact that every primitive triple reduces uniquely to
`(3,4,5)`. Why now? This cycle already established strict forward monotonicity and the order
invariant; negating it on inverse moves is the natural adversarial stress-test, and the
catalog's Lorentz/lattice files give the inverse maps off the shelf. Falsifiable: a
non-root primitive triple that is a strict local height minimum under the full group action.
