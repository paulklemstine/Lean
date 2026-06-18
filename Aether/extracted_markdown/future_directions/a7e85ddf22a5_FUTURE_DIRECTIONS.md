# FUTURE_DIRECTIONS — Tropicalization of Berggren Dynamics

## Synthesis

This cycle built the max-plus (tropical) shadow of the Berggren generation of primitive
Pythagorean triples and discovered that tropicalization does something *stronger* than merely
echoing the classical Lorentz invariance `Bᵀ Q B = Q`. Replacing `×` by `+` and `+` by `max`
in the all-positive Berggren matrix `B = [[1,2,2],[2,1,2],[2,2,3]]` yields a piecewise-affine
map `tropB`. On the tropical light cone `max(a,b) ≤ c`, this map collapses to the single
affine piece `(a,b,c) ↦ (2+c, 2+c, 3+c)` (`tropB_on_cone`). The immediate consequence is that
the **tropical Lorentz defect** `c − max(a,b)` is not conserved but *contracted to the fixed
value 1* after one step (`tropB_defect_collapse`): the cone interior is swept onto a
codimension-one attractor. This is the genuinely new structural phenomenon — a quadratic
conservation law tropicalizes into a linear contraction with a unique fixed defect.

The second discovery is a clean exp/log bridge between exact arithmetic and its tropical
shadow. The tropical norm (third coordinate) grows *additively* by exactly `3` per step
(`tropB_third_growth`), and we proved the matching exact statement on the integer side: the
classical hypotenuse grows *multiplicatively* by at least `3` per positive Berggren step, so
`3^n · 5 ≤ c_n` (`berggren_mid_hypotenuse_growth`). The shared constant `3` is the exp image of
the tropical slope. Because tropicalization of a positive-entry map only ever underestimates
(`max ≤ sum`), the tropical recurrence is a *sound, computable growth certificate* and yields a
branch-pruning bound for Berggren-tree search.

What failed / what is open: exact tropical invariance for the signed generators `A` and `C`
(negative entries) does not hold without sign bookkeeping, so the exact theory is anchored on
the positive generator `B`, exactly as the catalog's `BerggrenTropicalBridge.lean` does. The
multiplicative-vs-additive bridge is an inequality, not an equality; the missing gap is exactly
`log((2a+2b+3c)/(3c)) ∈ (0, log(7/3)]`, which is the seed of Direction 1.

## Results Summary

- `tropB_mono`: proved — the tropical Berggren step is coordinatewise monotone, the property
  that lets tropical bounds propagate along an entire Berggren word.
- `tropB_on_cone`: proved — on the light cone the step collapses to the affine piece
  `(a,b,c) ↦ (2+c,2+c,3+c)`, the structural heart of the file.
- `tropB_cone_preserved`: proved — the tropical light cone is forward invariant.
- `tropB_defect_collapse`: proved — the tropical Lorentz defect is driven to the fixed value 1,
  the exact max-plus analogue of `Bᵀ Q B = Q` (and strictly stronger: a contraction).
- `tropB_iterate`: proved — closed form `tropB^[n+1](a,b,c) = (3n+2+c, 3n+2+c, 3n+3+c)`.
- `tropB_third_growth`: proved — tropical norm grows additively by exactly 3 per step.
- `midStep_step`: proved — one classical step keeps coordinates nonnegative and triples ≥ 3×c.
- `berggren_mid_hypotenuse_growth`: proved — `3^n·5 ≤ c_n`, a computable norm-growth certificate.
- `tropical_certifies_classical_growth`: proved — the bridge: tropical additive slope 3 ⇄
  classical multiplicative base 3, certifying that exact evolution dominates its tropical shadow.

## Research Directions

### Direction 1: Quantify the tropical–classical gap as a convergent error functional
**Hypothesis**: For every positive Pythagorean triple `(a,b,c)` on the cone, the per-step gap
`log c' − (3 + log c)` between the classical log-hypotenuse and the tropical prediction lies in
`(0, log(7/3)]`, and along any infinite Berggren word it converges to a limit determined only by
the asymptotic angle of the triple (the ray in the light cone).
**Test**: Formalize `gap n := Real.log (c_n) − (3*n + Real.log 5)`, prove it is monotone and
bounded, hence convergent; compute the limit for the three pure words `A^∞, B^∞, C^∞`.
**Why now**: This cycle pinned the gap to the exact interval `(0, log(7/3)]` via
`midStep_step` (`3c ≤ c' ≤ 7c`); the key insight is that the gap is a telescoping sum of
bounded positive terms, so monotone-bounded convergence applies directly.
**If true**: tropical evolution becomes an *asymptotically exact* coordinate for the Berggren
tree, giving O(1)-additive-error hypotenuse estimates at unbounded depth.
**If false**: the gap oscillates, revealing genuine arithmetic chaos invisible to max-plus.

### Direction 2: Signed tropical semiring for the full generating set {A, B, C}
**Hypothesis**: Using signed tropical numbers (sign, magnitude) — the `SignedTropical` structure
already sketched in `Catalog/Tropical/BerggrenTropicalBridge.lean` — the generators `A` and `C`
admit a tropicalization for which a *signed* defect functional is still collapsed to a constant.
**Test**: Define `tropA`, `tropC` on signed states, prove a `tropX_on_cone`-style closed form
and a signed analogue of `tropB_defect_collapse`.
**Why now**: The key insight is that `A` and `C` are obtained from `B` by sign flips of one
column (`berggren_A`, `berggren_C` differ from `berggren_B` only in column signs), so their
tropical closed forms should differ from `tropB`'s only by tracked signs — a finite case split.
**If true**: a uniform tropical invariant for the *entire* Berggren tree, not just the `B`-spine.
**If false**: identifies precisely which sign patterns break tropical conservation, sharpening
the boundary of the max-plus correspondence.

### Direction 3: p-adic valuation-depth as an exact min-plus shadow
**Hypothesis**: For the 2-adic valuation `ν₂`, the classical Berggren step satisfies the exact
min-plus inequality `ν₂(B·v)ᵢ ≥ minⱼ (ν₂(Bᵢⱼ) + ν₂(vⱼ))`, i.e. the valuation-depth profile of a
triple is bounded below by the min-plus Berggren recurrence with weights `ν₂` of the entries.
**Test**: Prove the single-coordinate inequality
`padicValInt 2 (a + 2b + 2c) ≥ min (padicValInt 2 a) (min (1 + padicValInt 2 b) (1 + padicValInt 2 c))`
under nonvanishing hypotheses, then assemble the three coordinates and iterate over words.
**Why now**: The key insight is that valuation of a sum is ≥ the min of valuations — the *dual*
(min-plus) tropicalization to this cycle's max-plus one — so the same "tropical bound on exact
arithmetic" template applies, now with `+` weighting by `ν₂(2)=1`, `ν₂(1)=ν₂(3)=0`.
**If true**: a second, complementary tropical certificate (depth, not size) usable for pruning in
Diophantine enumeration and for the cryptographic Berggren-lattice search of `Catalog/Cryptography`.
**If false**: the failure pinpoints triples whose 2-adic depth drops below the tropical floor,
i.e. unexpected cancellations in `a+2b+2c` — interesting in their own right.

### Direction 4: Tropical-defect certificate refutes spurious Berggren tree nodes
**Hypothesis**: Any state reachable from the root by ≥ 1 positive Berggren steps has tropical
defect exactly 1; hence a candidate triple whose tropical defect ≠ 1 cannot lie on the `B`-spine,
giving a constant-time membership filter.
**Test**: Combine `tropB_defect_collapse` with `tropB_cone_preserved` into an iterate-level
statement `n ≥ 1 → defectZ (tropB^[n] x) = 1`, and contrapose for a non-membership certificate.
**Why now**: The key insight is that `tropB_defect_collapse` already proves the one-step fact and
`tropB_cone_preserved` keeps us on the cone, so the iterate statement is a one-line induction
available immediately from this cycle's lemmas.
**If true**: an O(1) pruning oracle for tree exploration and a structural fingerprint of the
Berggren orbit, complementing the `BerggrenFingerprintRigidity` results in the catalog.
**If false**: would mean the defect is not iterate-invariant, contradicting the closed form —
so a disproof here would expose an error and is itself diagnostic.

### Direction 5: General Lorentz max-plus dynamics beyond Berggren
**Hypothesis**: For *any* positive integer matrix `M` preserving a Lorentz form `Q = diag(1,1,−1)`
whose last row dominates (entry `(2,2)` strictly largest), the tropicalization collapses the cone
defect to the constant `M₂₂ − max(M₂₀, M₂₁)`.
**Test**: State the abstract lemma over a matrix `M` with hypotheses `0 < Mᵢⱼ` and the row-domination
condition, and prove the cone closed form and defect value by the same `omega`-driven argument.
**Why now**: The key insight is that this cycle's proofs never used special values — only the
row-domination inequalities — so the argument generalizes verbatim; Berggren's `B` is the case
`(2,2,3)` giving defect `3 − 2 = 1`.
**If true**: a general theorem on tropical contraction of Lorentz-preserving positive maps,
turning a one-off Pythagorean result into a reusable bridge primitive.
**If false**: reveals that Berggren's specific entries (not just positivity) are essential,
isolating the arithmetic source of the defect-collapse phenomenon.
