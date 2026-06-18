# Future Directions — Berggren Height Certificates

## Synthesis

This cycle bridges three catalog domains that previously sat apart: the
*Berggren–Lorentz* theory of primitive Pythagorean triples
(`Algebra/BerggrenLorentz/Core.lean`), order-theoretic *termination/acyclicity*
arguments, and the *certificate* idiom of
`Cryptography/NoetherianCertification.lean`. The unifying object is a single
arithmetic functional, the linear size `H(a,b,c) = a + b + c`, which we prove is
**strictly monotone** under all three Berggren generators on the positive
Pythagorean branch. From that one inequality everything else follows
mechanically: the branch is invariant, the Berggren child graph is **acyclic**,
height is **injective along any lineage**, and a finite word of generators
becomes a **checkable ancestry certificate** whose soundness theorems guarantee a
valid, strictly-deeper, cycle-free primitive triple lineage.

The conceptual payoff is the separation of two roles that the catalog had kept
implicit. The Lorentz quadratic form `lorentzQ` is an *invariant* — it is
constant (zero) along the whole light cone, so it can verify membership but can
never order the tree. The size `H` is a *transverse* functional — it is strictly
increasing, so it orders the tree and supplies the well-founded measure that
turns reachability into a decidable, certificate-checkable relation. Invariant
plus transverse functional together give a complete navigational calculus for
the Berggren search space.

## Results summary

* `height_lt_applyMove`: `H` strictly increases under each generator A, B, C
  (increments `4a−6b+6c`, `4a+4b+6c`, `4b−6a+6c`, each positive because the
  hypotenuse dominates both legs).
* `onBranch_applyMove`: each generator preserves the primitive positive branch.
* `acyclic`: no on-branch triple is Berggren-reachable from itself.
* `height_injective_on_chain`: equal-height reachable triples coincide, so the
  minimal (and maximal) representative of a lineage is unique.
* `BerggrenAncestryCert` with `target_onBranch`, `cert_reaches`, `cert_strict`,
  `cert_no_cycle`, `cert_unique_at_height`: a self-contained, sound ancestry
  certificate for the Berggren tree.

All results are proved with no `sorry` and depend only on the standard axioms.

## Direction 1 — Quantitative depth bounds: `H` grows geometrically

We proved `H` strictly increases; the next target is the *rate*. Conjecture: for
any on-branch triple, `3 * H t ≤ H (applyMove k t) ≤ 7 * H t` for every generator
`k`, and consequently any certificate of word-length `n` satisfies
`3^n * H root ≤ H target ≤ 7^n * H root`. This upgrades acyclicity to an explicit
`O(log H)` depth bound for ancestry search. *The key insight is* that the catalog
already isolates the relevant constants — `hypB_lower_bound` (factor 3) and
`hypB_upper_bound` (factor 7) bound a single coordinate, and summing the three
coordinate bounds should propagate the same constants to `H`. *Why now?* The
monotonicity scaffold and the per-coordinate catalog bounds are both in place, so
the geometric two-sided bound is a direct, falsifiable next step (it fails iff
some generator violates the 3×/7× window on a concrete triple).

## Direction 2 — Uniqueness of parents: a true tree, not just a DAG

Berggren's classical theorem says every primitive triple except `(3,4,5)` has a
*unique* parent via the inverse generators `invA, invB, invC` (already in the
catalog). Conjecture: the `Step` relation restricted to the branch is not only
acyclic but **uniquely-parented**, i.e. for each non-root on-branch triple there
is exactly one `(t, k)` with `applyMove k t = s` and `t` on the branch. Combined
with this cycle's acyclicity, that promotes the Berggren graph to a genuine
rooted tree and makes `cert_reaches` paths *unique*. *The key insight is* that
the sign pattern of the inverse images (which of `invA/invB/invC` lands back in
the positive cone) is mutually exclusive, exactly as the catalog's determinant
signature `(+1,−1,+1)` suggests. *Why now?* The inverse matrices and their
`O(2,1;ℤ)` membership are already verified in `Core.lean`; uniqueness of parents
is the missing structural theorem that turns the certificate into a *canonical*
address (a base-3 numbering) for every primitive triple.

## Direction 3 — A decidable certificate checker with extracted code

Make the ancestry certificate *executable*: define `checkCert : Triple → List
(Fin 3) → Triple → Bool` that replays moves and verifies the height trace, and
prove `checkCert root moves target = true ↔ (OnBranch root ∧ applyPath moves root
= target)`. Conjecture: this checker is correct and runs in time linear in the
word length and logarithmic in the entry size. *The key insight is* that every
predicate involved (`IsPythag`, positivity, equality of triples) is decidable
over `ℤ`, so the soundness theorems of this file lift verbatim to a `Decidable`
instance. *Why now?* The non-computational soundness layer is finished and
axiom-clean; wrapping it in a `Bool`-valued checker is the natural bridge to the
`NoetherianCertification` certificate idiom and to any later "geometric
key-generation" heuristic that needs an actual verifier.

## Direction 4 — Lattice / cryptographic hardness of ancestry reversal

The forward map is cheap and monotone; the conjecture is that the *backward*
problem is hard in a precise sense. Formalize: given only `target` (a large
primitive triple), recovering the unique generator word back to `(3,4,5)` costs
`Θ(log H target)` inverse steps, but recovering a word to a *prescribed*
intermediate ancestor among exponentially many candidates is search-hard. *The
key insight is* that the determinant grading (`det matB = −1` versus `det matA =
det matC = +1`, from `Core.lean`) gives a `ℤ/2ℤ` parity invariant that prunes —
but does not collapse — the `3^n` word space, mirroring the noise-ideal structure
in lattice cryptography. *Why now?* With acyclicity (no shortcuts via loops) and
the geometric depth bound of Direction 1, the search tree has exactly the
balanced exponential shape needed to state a falsifiable hardness assumption,
connecting Bridges ↔ Pythagorean ↔ Cryptography concretely.

## Direction 5 — Replacing `H` by a Lorentz-derived height on indefinite cones

Our height is the *linear* size. Conjecture: there is a strictly monotone height
built purely from `lorentzBilinear` against a fixed timelike reference vector
`r = (0,0,1)`, namely `Hℒ(v) = lorentzBilinear v r = −c`, suitably normalized,
and more generally `B(v, M·r)` for a generator product `M`; and that *some*
positive-definite combination of such Lorentz pairings reproduces the
monotonicity of `H` while extending to triples on *other* indefinite cones
(`Q = d` for fixed nonzero `d`). *The key insight is* that monotonicity should be
a statement about the *direction* of the Berggren boosts relative to the timelike
axis, so it ought to survive deformation of the cone constant `d`. *Why now?* The
bilinear form, its symmetry, and its bilinearity are already proved in `Core.lean`
(`lorentzBilinear_symm`, `lorentzBilinear_add_left`, `lorentzBilinear_smul_left`),
giving exactly the algebra needed to test whether a Lorentz-intrinsic height can
replace the ad hoc linear size — and to falsify the claim on an explicit
non-Pythagorean cone if it cannot.
