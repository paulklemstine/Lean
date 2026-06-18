# Future Directions: Algebraic Fixed-Point Theorems for EML Closure Semimodules

The new file `Catalog/Bridges/AlgebraEMLClosureFixedPoint.lean` upgrades the catalog's
*postulated-idempotent* closure interfaces (`SetClosureOperator`, `FiniteClosureSystem`,
`ClosureSemimoduleSystem`) into a **constructed** least-fixed-point theory: any inflationary
monotone generator `f : Finset α → Finset α` on a finite carrier stabilizes, in at most
`card α - card s` iterations, at the least `f`-closed superset `clStar f s`, which is a genuine
`ClosureOperator` and is reconstructible from any separating family of closure-stable probes.
The directions below are concrete, falsifiable next steps that build directly on these results.

## 1. Sharp potential-descent bound via a generic integer `ClosurePotential`

The current convergence bound `card α - card s` is a coarse cardinality counter. Conjecture:
if a strictly-decreasing integer-valued `ClosurePotential` `Φ : Finset α → ℕ` exists with
`Φ (f s) < Φ s` on every non-fixed iterate, then `clStar` is reached in at most `Φ s` steps,
and this is tight — there is a generator achieving exactly `Φ s` non-trivial steps.
**The key insight is** that the cardinality `card` used in `card_iter_ge` is just one instance of a
descending potential, so abstracting it to any well-founded `ℕ`-valued `Φ` decouples the
*existence* of stabilization (well-foundedness) from its *quantitative* rate (the specific `Φ`),
matching the `ClosurePotential` interface in `AlgebraicEMLThermodynamicFormalism.lean`.
**Why now?** `exists_iterate_eq_fixed` already isolates the descent argument in `card_iter_ge`;
replacing `Finset.card` with an abstract strictly-monotone `Φ` is a localized refactor that turns
a fixed bound into a parameterized one, immediately connecting to the thermodynamic pressure layer.

## 2. Galois adjunction between generators and closure operators

Conjecture: the assignment `f ↦ generatedClosureOperator f` and the "forgetful" map sending a
closure operator `c` to its own underlying inflationary monotone map form a Galois insertion on
the poset of inflationary monotone endomaps of `Finset α` ordered pointwise by `⊆`; in particular
`clStar (clStar f) = clStar f` as operators, and `clStar f = f` iff `f` is already idempotent.
**The key insight is** that `clStar_least` exhibits `clStar f s` as an infimum over closed supersets,
which is exactly the universal property that makes `clStar` a *reflection* of generators into
closure operators — a Galois-connection skeleton already half-present in `EMLClosureUnification/Core.lean`.
**Why now?** With `clStar_idempotent`, `clStar_mono`, and `clStar_least` proven, the two adjunction
inequalities are short corollaries; the remaining work is the order-theoretic packaging, for which
Mathlib's `GaloisInsertion` API is directly applicable.

## 3. Probe-complexity lower bound for fixed-point reconstruction

`clStar_eq_iff_probes` shows a separating closure-stable family determines the stabilized closure.
Conjecture: for a carrier of size `n`, any separating family of `{0,1}`-valued closure-stable
probes must have at least `n` members, and `n` suffices (the indicator probes of a maximal chain
of closed sets). Hence reconstruction has probe-complexity exactly `Θ(n)`.
**The key insight is** that closure-stability forces each probe to be constant on every closed
"layer", so a separating family must shatter the lattice of closed sets along a maximal chain,
turning a reconstruction question into a chain-counting / antichain argument.
**Why now?** The qualitative reconstruction theorem is done; the quantitative version reuses the
same `ProbeStable` invariance lemma (`probe_iter`) plus standard finite-lattice chain combinatorics
already in Mathlib (`Finset` chains), making it a clean, self-contained follow-up.

## 4. Kernel/interior dual and a closed-set fixed-point interval

Dualizing, conjecture: every *deflationary* monotone `g : Finset α → Finset α` iterates down to a
greatest `g`-open subset `krStar g s`, and for a Galois-style pair `(f, g)` the closed/open fixed
points are order-anti-isomorphic, so `krStar g (clStar f s)` recovers a canonical "core" of the
fixed point. The pair `(clStar f s, krStar g s)` bounds a nonempty interval of mutual fixed points.
**The key insight is** that the entire iteration argument is order-theoretic and self-dual: replacing
`⊆`/extensive by `⊇`/deflationary turns `clStar` into a kernel operator with no new ideas, mirroring
the `IsEMLKernelOn` dual already declared in `EMLClosureUnification/Core.lean`.
**Why now?** The proofs of `iter_subset_succ`, `card_iter_ge`, and `iter_stable_of_eq` dualize line by
line under `OrderDual`, so the kernel theory is essentially a free-of-charge mirror image.

## 5. Lifting the finite theory to compact/algebraic closure systems

Conjecture: when `α` is infinite but `f` is *finitary* (`f s = ⋃ {f t | t ⊆ s finite}`), the
`Finset`-level `clStar` extends to a closure operator on `Set α` whose closed sets are exactly the
directed unions of finite closed sets, and the least-fixed-point characterization `clStar_least`
survives verbatim (without the cardinality bound). This bridges the finite result to the
`SetClosureOperator` / `algebraicLike_finite_witness` machinery of `AlgebraEMLReconstruction.lean`.
**The key insight is** that finiteness was used *only* for the termination bound, never for the
order-theoretic core (`clStar_least` needs no `Fintype`), so compactness can replace finiteness as
the mechanism guaranteeing that finite probes still detect the global fixed point.
**Why now?** `clStar_least` is already stated and proved using only monotonicity and closedness; the
finitary-compactness hypothesis is precisely the standard tool for transporting such finite-support
arguments to the infinite setting, and the target `SetClosureOperator` interface already exists.
