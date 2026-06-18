# Future Directions — The Boltzmann Bridge: Cones, Sharpness, and the Road to Homology

## Synthesis

This cycle pressure-tested the catalog's persistence backbone
(`HigherPersistence.lean`'s `Filtration` / `VRfaces` calculus,
`CechNerve.lean`'s combinatorial Nerve interleaving, and `FaceVector.lean`'s
f-vector / Euler–Poincaré bridge `eulerChar_eq_alt_fVector`) from two adversarial
angles, and *closed* both with sorry-free proofs.

First, **`ConeContractibility.lean`** turns the catalog's numerical fact
"the full simplex has Euler characteristic `1`" into a *structural* theorem about
an operation on complexes. We defined the combinatorial cone
`cone v K = K ∪ K.image (insert v)` and proved two results: the **Pascal
recurrence** `fVector_cone` (`f_k(cone) = f_k(K) + f_{k-1}(K)` for `k ≥ 1`), and
the **contractibility theorem** `eulerCharFin_cone`: *every* cone (over any finite
complex containing the empty face, by any fresh apex) has Euler characteristic `1`.
The proof is a clean ledger split: the cone's nonempty faces partition into the
disjoint base `K` and the sign-flipped, dimension-shifted apex layer
`K.image (insert v)`; the base contributes `eulerCharFin K` and the apex layer
contributes exactly `1 - eulerCharFin K`, so the total telescopes to `1`
regardless of `K`. This is a reusable *contractibility detector* and the honest
inductive engine behind `euler_char_full_simplex` (the full simplex is an iterated
cone over a point). The structural lesson: the apex layer is *always* a
sign-reversed copy of the base, so coning is, at the level of the Euler ledger, a
projection onto the constant `1`.

Second, **`NerveSharpness.lean`** attacked the most suspicious constant in the
whole development — the slack factor `2` in `cech_subset_vr`
(`Čech(ε) ⊆ VR(2ε)`). The adversarial question: can the `2` be lowered? The answer
is **no, not even on the real line**. The antipodal pair `{-1, 1} ⊆ ℝ` lies in the
common closed unit ball at the origin (`cech_two_point_witness`: it is a Čech face
at scale `1`) yet has pairwise distance exactly `2`, so it is *not* a VR face below
scale `2` (`vr_two_point_fails`). Assembling these (`nerve_interleaving_sharp`)
shows `Čech(1) ⊄ VR(c)` for every `c < 2`: the interleaving constant is optimal.
This pins the worst-case Vietoris–Rips-vs-Čech approximation error — the quantity
controlling how much persistence the cheap VR complex can miss relative to the
faithful nerve.

The emergent picture from this and the prior cycle: persistence is governed by two
orthogonal ledgers — a **metric** ledger (distances, controlling interleaving
slack, now shown to be *sharply* a factor `2` in the worst case) and a
**combinatorial** ledger (face counts, controlling the Euler characteristic, now
shown to be a *projection onto `1`* under coning). The `Filtration` and `fVector`
abstractions let each be reasoned about without touching the other.

## Results Summary

- `cone` — definition: the combinatorial cone of a complex by a fresh apex.
- `fVector_cone` — proved: Pascal recurrence `f_k(cone v K) = f_k(K) + f_{k-1}(K)` for `k ≥ 1`.
- `eulerCharFin_cone` — proved: every cone (over a complex with the empty face) has Euler characteristic `1`.
- `sum_sign_image_insert` — proved: the apex layer's signed face count is the sign-flipped, dimension-shifted copy of `K`.
- `sum_sign_eq_one_sub_euler` — proved: `∑_{σ∈K} (-1)^{card σ} = 1 - eulerCharFin K` when `∅ ∈ K`.
- `cech_two_point_witness` — proved: `{-1,1} ∈ Čech(1)` via the midpoint center `0`.
- `vr_two_point_fails` — proved: `{-1,1} ∉ VR(c)` for every `c < 2`.
- `nerve_interleaving_sharp` — proved: the constant `2` in `cech_subset_vr` is optimal, even over `ℝ`.

## Research Directions

### Direction 1: Iterated cones, suspensions, and the reduced-Euler calculus
The cone theorem `eulerCharFin_cone` says coning collapses the Euler ledger to `1`.
The natural next object is the **suspension** `susp K = cone v₁ K ∪ cone v₂ K` (two
apexes glued along `K`), whose reduced Euler characteristic should *double* that of
`K`: conjecture `eulerCharFin (susp K) = 2 - eulerCharFin K`, i.e. reduced χ flips
sign and the unreduced value obeys `χ̃(susp K) = -χ̃(K)`. **Test**: prove a
`fVector_susp` recurrence `f_k(susp) = f_k(K) + 2·f_{k-1}(K)` by the same
disjoint-layer accounting, then feed it through `eulerChar_eq_alt_fVector`. The key
insight is that suspension is *two* sign-flipped copies of the base glued on a
shared base, so the two apex layers contribute `2(1 - eulerCharFin K)` minus the
double-counted base. **Why now?** `eulerCharFin_cone` already isolates the exact
"apex layer = sign-flipped copy" lemma (`sum_sign_image_insert`); suspension only
needs that lemma applied twice with a single inclusion–exclusion correction. **If
true**: gives the full reduced-homology Euler calculus (`Sⁿ` has χ = `1 + (-1)ⁿ`)
purely combinatorially. **If false**: the gluing term is mis-accounted, exposing a
double-counting bug in how shared faces are handled — caught before homology.

### Direction 2: The midpoint center and the *Euclidean* interleaving constant
`nerve_interleaving_sharp` shows the constant `2` is sharp over general (even
1-D Euclidean) data — but only because we used a *vertex-agnostic* center. The
deeper conjecture: on the *real line*, the reverse inclusion improves to
`VR(ε) ⊆ Čech(ε/2)·`(via the midpoint), and more generally on `ℝ^d` the Čech
radius of a VR-`ε` simplex is bounded by the **Jung constant**
`√(d/(2(d+1)))·ε`, strictly below the naive `ε`. **Test**: for `d = 1`, replace the
"pick a vertex" center of `vr_subset_cech` with the midpoint
`(min + max)/2` of the vertex coordinates and prove `VR(ε) ⊆ Čech(ε/2)` on `ℝ`.
The key insight is that the sharp example `{-1,1}` is *also* the witness that the
midpoint is optimal — its smallest enclosing ball has radius exactly half its
diameter. **Why now?** `vr_subset_cech` localizes the center construction to a
single `∃ c` obligation, so only the center *formula* needs upgrading; the rest of
the interleaving plumbing is untouched. **If true**: halves the provable
VR-vs-Čech error on the line, the first quantitative Euclidean refinement in the
catalog. **If false**: a metric obstruction on `ℝ` would be genuinely surprising
and would point to a defect in `diamWeight`.

### Direction 3: f-vector monotonicity and the Euler characteristic curve
With `fVector_cone` in hand, the filtration-level question becomes tractable: for a
sublevel `Filtration F` restricted to a finite ambient complex, each
`fVector (sublevel at t) k` is a **monotone nondecreasing step function** of `t`,
and `eulerCharFin (sublevel at t)` is **piecewise constant**, jumping only at the
finite set of weight values `{F.weight σ}`. **Test**: prove
`t₁ ≤ t₂ → fVector_at t₁ k ≤ fVector_at t₂ k` from `sublevel_mono` (monotone
`Finset.card` under `⊆`), then constancy of `eulerCharFin` on any interval avoiding
weight values. The key insight is that `eulerChar_eq_alt_fVector` already routes
the Euler characteristic through the f-vector, so monotonicity of the *components*
upgrades to a structure theorem for the *invariant*. **Why now?** `sublevel_mono`
supplies the nesting and `Finset.card_le_card` the monotonicity; the only new work
is the finite jump-set bookkeeping. **If true**: yields the computable
Euler-characteristic curve (ECC/ECT) of a filtration. **If false**: reveals
`eulerCharFin` is not additive across the filtration — a definitional mismatch with
persistent homology worth catching now.

### Direction 4: A combinatorial Mayer–Vietoris / inclusion–exclusion for χ
The cone proof is secretly an inclusion–exclusion (`χ(A ∪ B) = χ(A) + χ(B) -
χ(A ∩ B)` with `A = K`, `B` the apex layer, `A ∩ B = ∅`). The conjecture: for *any*
two finite complexes `K, L`, `eulerCharFin (K ∪ L) = eulerCharFin K +
eulerCharFin L - eulerCharFin (K ∩ L)`. **Test**: prove it directly from
`Finset.sum_union` / `Finset.inclusion_exclusion`-style identities on the signed
face sums, no metric or dimension hypotheses needed. The key insight is that
`eulerCharFin` is a *signed measure* on faces, so it is automatically modular
(valuation-like) under `∪`/`∩`. **Why now?** `eulerCharFin_cone` already exercises
the `sum_union` + disjointness machinery; dropping disjointness and adding the
`K ∩ L` correction term is a direct generalization. **If true**: gives the
Euler-characteristic valuation, the gateway to gluing arguments and a
combinatorial Mayer–Vietoris. **If false**: the signed sum fails modularity,
signaling that `eulerCharFin` secretly depends on more than the face set.

### Direction 5: From the f-vector shadow to genuine persistent Betti numbers
The honest limitation flagged last cycle stands: we compute the Euler
characteristic (the *alternating* sum of Betti numbers) but not the Betti numbers
themselves. The conjecture worth committing to: the `Finset`-of-faces model can
support a **boundary map** `∂_k : (k-faces) → (k-1)-faces` over `ZMod 2` with
`∂_{k-1} ∘ ∂_k = 0`, and the resulting ranks satisfy
`eulerCharFin K = ∑_k (-1)^k · (Betti_k K)` — upgrading `eulerChar_eq_alt_fVector`
from f-vector to homology. **Test**: define `∂` via the signed (here `ZMod 2`,
unsigned) sum over facet deletions, prove `∂² = 0` by the standard
"each codimension-2 face is hit twice" cancellation, and verify `χ = Σ(-1)^k bₖ`
via rank–nullity. The key insight is that `fVector_cone`'s Pascal recurrence is the
*shadow* of the cone's contractibility (`Hₖ(cone) = 0` for `k ≥ 1`), so the cone
theorem becomes the first non-trivial homology computation to target. **Why now?**
Every ingredient on the χ side is now sorry-free, so the homology layer has a fully
proved scaffold to reduce to and check against. **If true**: lands genuine
persistent homology in the catalog. **If false**: pinpoints exactly which Mathlib
chain-complex API gap blocks the `Finset` model — the most valuable possible
negative result for steering the next cycle.
