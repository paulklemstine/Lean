# Future Directions — Reverse Mathematics of Ramsey's Theorem (Cohesiveness / CJS)

This file seeds the next research cycle building on
`Catalog/Shared/ReverseMath/Extensions.lean`, which extends the catalog's
`Shared.ReverseMath.Defs` / `Shared.ReverseMath.Implications`.

## Synthesis

The catalog already contained the combinatorial core of Ramsey's theorem for
pairs: `rt2_2_proof` (RT²₂), `rt1_2_bool_proof` (RT¹₂), and the *trivial*
implications among RT²₂, SRT²₂, RT¹₂. But two load-bearing pieces of the
reverse-mathematics picture were merely *stated*, never *proved*: the
cohesiveness principle `COH`, and the genuine Cholak–Jockusch–Slaman reduction
`SRT²₂ → RT²₂`. The catalog's `CJS_decomposition` in fact discharged
`SRT²₂ ∧ COH → RT²₂` by silently invoking `rt2_2_proof`, so cohesiveness played
no role at all. This cycle closes both gaps with self-contained constructions.
To force honesty we imported **only** `Defs`, deliberately removing `rt2_2_proof`
and `rt1_2_bool_proof` from scope, so each theorem had to carry its own
combinatorial argument rather than delegate.

The structural insight that emerged is that the *entire* difficulty of
`SRT²₂ → RT²₂` is concentrated in a single, surprisingly clean lemma:
`inducedColoring_stable`. Cohesiveness of a set `C` against the "true-rows" of a
coloring `c` is *exactly* the statement that pulling `c` back along any increasing
enumeration of `C` yields a *stable* coloring. Once this is seen, the reduction is
mechanical: COH supplies a cohesive `C` (`coh_proof`), enumeration makes the
induced coloring stable (`every_coloring_stabilizes`), SRT²₂ handles stable
colorings, and the homogeneous set transports back along the strictly monotone
enumeration (`inducedColoring_homogeneous_map`). The whole route is the
metamathematically-meaningful one: it shows RT²₂'s strength splits cleanly into a
"limit-finding" part (COH) and a "1-dimensional pigeonhole on the limit colors"
part (SRT²₂).

What failed: the natural generalization `RTpair_k` (Ramsey for pairs with `k`
colors) resisted both an induction-merging-colors attempt and an ultrafilter
attempt within the time budget — not for mathematical reasons but because of
`Fin k → Fin (k-1)` color-shifting bookkeeping and the absence of an in-scope
2-color base case (deliberately removed). This is the obvious next target and is
the spine of the directions below.

## Results Summary

- `infinite_inter_or_diff`: proved — an infinite set splits into an infinite
  intersection-or-difference against any predicate (the pigeonhole atom reused
  throughout).
- `exists_strictMono_mem`: proved — every infinite set of naturals has a strictly
  monotone enumeration landing inside it (the enumeration backbone).
- `coh_proof`: proved — the cohesiveness principle COH, by diagonalising a
  decreasing chain of infinite sets; **new**, the catalog never established COH.
- `inducedColoring` / `inducedColoring_color`: definition — the coloring pulled
  back along a subsequence.
- `inducedColoring_stable`: proved — cohesion of `C` against the true-rows makes
  the induced coloring stable; the genuine heart of the CJS decomposition.
- `every_coloring_stabilizes`: proved — every 2-coloring of pairs becomes stable
  along some increasing subsequence (COH + induced stability).
- `inducedColoring_homogeneous_map`: proved — homogeneous sets transport back
  along the enumeration without changing color.
- `rt2_2_via_stabilization`: proved — the genuine `SRT²₂ → RT²₂` reduction, built
  from the pieces above rather than by delegating to `rt2_2_proof`.
- `rtpair_k_conjecture`: conjecture (`sorry`) — Ramsey for pairs with `k` colors;
  believed true, deferred due to finite-color bookkeeping.

## Research Directions

### Direction 1: Finite-color Ramsey for pairs (`RTpair_k`)
**Hypothesis**: `RTpair_k k` holds for every `k ≥ 1`: every symmetric
`Fin k`-coloring of pairs of naturals has an infinite homogeneous set.
**Test**: Prove by induction on `k`. Base `k = 1` is trivial; for the step, fold
color `0` against the rest into a `Bool` coloring, apply a *2-color base lemma*
(re-prove it in-scope, or import `rt2_2_proof`), and recurse on `Fin (k-1)` over
the homogeneous set where color `0` is absent. Refute by exhibiting a `k` and a
coloring with no infinite homogeneous set (this should be impossible).
**Why now**: This cycle isolated the only hard primitive — `infinite_inter_or_diff`
plus a monochromatic-subsequence extraction — both already available; the key
insight is that the `Fin k → Fin (k-1)` step only needs an order-embedding of the
nonzero colors, not genuine new Ramsey content.
**If true**: completes the finite-color layer and lets every downstream principle
(stability, cohesion) be stated uniformly in `k`.
**If false**: would expose a soundness bug in our `Fin`-coloring formalization,
since `RTpair_k` is a classical theorem.

### Direction 2: A reusable strictly-monotone enumeration with `range = C`
**Hypothesis**: Every infinite `C ⊆ ℕ` admits `e : ℕ → ℕ` with `StrictMono e` and
`Set.range e = C` (not merely `∀ n, e n ∈ C`).
**Test**: Strengthen `exists_strictMono_mem` by choosing, at each step, the
*least* element of `C` above the previous one, and prove surjectivity onto `C` by
induction. Disproof would require an infinite `C` with no order-isomorphism to ℕ
— impossible, so this is a pure formalization task.
**Why now**: `inducedColoring_homogeneous_map` currently transports along an
arbitrary monotone `e`; the key insight is that an *onto* enumeration would let us
state cohesion and stability intrinsically on `C` rather than on an index copy of
ℕ, removing the `e '' S` bookkeeping from every downstream proof.
**If true**: gives a clean `Set ℕ`-level API for the whole development.
**If false**: nothing — but the attempt will surface the exact Mathlib lemma
(`Nat.nth` / `Nat.Subtype.orderIsoOfNat`) best suited as the canonical enumerator.

### Direction 3: COH from SRT²₂ is *not* provable over RCA₀ — internalize the boundary
**Hypothesis**: In our CIC setting `COH`, `SRT²₂`, and `RT²₂` are all theorems, but
the implication `SRT²₂ → COH` is exactly the one that *fails* over RCA₀
(Chong–Slaman–Yang 2014). We can make this boundary explicit by formalizing a
*relativized* version: define principles relative to a Turing ideal / oracle and
show `inducedColoring_stable` is the only step that consumes the oracle's power.
**Test**: Introduce an abstract "definability budget" predicate on the chosen
witnesses (e.g. a `Filter`/oracle parameter) and re-prove `coh_proof` tracking
which choices are non-effective; check whether `rt2_2_via_stabilization` factors
through it.
**Why now**: the key insight from this cycle is that all non-effectivity in our
proofs is localized to two `Classical.choice` sites (`coh_proof`'s chain and
`exists_strictMono_mem`); isolating them is the first concrete step toward an
honest reverse-math separation inside Lean.
**If true**: opens a path to formalizing genuine ω-model separations.
**If false**: teaches us which classical step is irreducibly non-constructive
here, sharpening where Seetapun's separation must bite.

### Direction 4: The full CJS equivalence `RT²₂ ↔ SRT²₂ ∧ COH`
**Hypothesis**: `RT2_2 ↔ (SRT2_2 ∧ COH)` with *both* directions carrying real
content (the catalog's forward direction is trivial; ours is `←`).
**Test**: Prove `RT2_2 → COH` genuinely (apply RT²₂ to a coloring encoding the
sets `R i`, extracting a cohesive set from a homogeneous one) and `RT2_2 → SRT2_2`
as the restriction; combine with `rt2_2_via_stabilization` for `←`.
**Why now**: with `coh_proof` and `rt2_2_via_stabilization` in hand, the only
missing arrow is `RT2_2 → COH`; the key insight is that a homogeneous set for the
"product" coloring `c(i,j) = (membership of j in R i)` is already almost-cohesive,
so this is one more application of the techniques proved this cycle.
**If true**: yields the first end-to-end, non-delegating CJS equivalence in the
catalog.
**If false**: would indicate our `IsCohesive` definition is mis-stated relative to
the literature, a valuable correction.

### Direction 5: Stability is necessary — a non-stable coloring with a hard homogeneous set
**Hypothesis**: There is a computable coloring `c` that is *not* stable yet whose
only homogeneous sets are "complicated", witnessing that `every_coloring_stabilizes`
genuinely needs the cohesive detour (i.e. one cannot skip COH).
**Test**: Construct an explicit oscillating coloring (e.g. `c(i,j)` depending on
the parity of the number of primes in `(i,j]`) and prove it is not stable
(`¬ IsStable c`); then show, relative to an oracle budget, that its homogeneous
sets compute something its rows do not.
**Why now**: the key insight is that `inducedColoring_stable` converts *any* `c`
into a stable one only after paying the COH cost; a concrete non-stable witness
quantifies that cost and is the natural "Critic" counterexample to the tempting
conjecture "every coloring is already eventually stable."
**If true**: pins down why the cohesive set is indispensable, not a convenience.
**If false** (i.e. the candidate turns out stable): refines our intuition about
which arithmetic colorings are secretly stable, a useful library of examples.
