# Future Directions: Stereographic Proof Compression

The file `StereographicProofCompression.lean` formalizes a precise model of the
"proofs on spheres" program. A proof is a finite binary sequence (`List Bool`);
its binary expansion `codeReal` lands in `[0,1]`, and stereographic projection
`stereo` lifts that to the unit circle. The "proof distance" is the squared
chord distance `chordSq` between the two stereographic images.

Two facts are settled. **Forward compression** (`compression_bound`,
`spherical_compression`): if two proofs share their first `m` steps, their
spherical distance is at most `4·(1/4)^m` — shared structure forces geometric
proximity. **The converse fails** (`converse_fails`, witnessed by
`counterexample_gap`): `[true]` and `false :: trueⁿ` disagree at step `0` yet
have spherical distance below any `ε`. The obstruction is the non-injectivity
of positional encoding (`0.1 = 0.0111…`). This refutes the literal conjecture
and pinpoints *why* it fails, which is exactly the information the next cycle
should exploit.

These results connect to the existing catalog `Stereographic*` family
(`StereographicSheaf`, `StereographicRG`, `StereographicNeuralField`,
`InverseStereoResearch`): all use the same projection `ℝ → S¹`, so the
compression metric here can be transported onto those geometric constructions.

---

## Direction 1 — Repair the converse with an ultrametric (prefix-injective) code

The naive binary code collapses distances because two codes can name the same
real. Replace `codeReal` by a *prefix-injective* embedding: map a proof to the
real number `Σ (2·bᵢ+1)·3^{-(i+1)}` (a Cantor-style ternary code that never
reuses a value), or equivalently equip proofs with the ultrametric
`d(p,q) = 2^{-lcp(p,q)}` and push it through `stereo`. Conjecture: with this
code the *full* equivalence holds — spherical distance `< 2^{-(m+1)}` forces a
common subproof of length `≥ m`.

**The key insight is** that the conjecture's failure is purely a coding
artifact (value-collision), not a geometric one; an injective code with
positive minimal inter-branch gap restores the lost direction exactly.

**Why now?** We already have the forward bound and an explicit refutation
isolating the single cause (non-injectivity), so the only missing ingredient is
a quantitative *lower* bound `|code p - code q| ≥ c·2^{-lcp}`, which is provable
by the same head-peeling induction already used in `compression_bound`.

## Direction 2 — Lift from `S¹` to `S^n` and trade dimension for resolution

Encode a proof over an alphabet of size `k = 2^n` and map blocks of `n` steps to
points of `S^n` via the higher-dimensional stereographic projection
`ℝ^n → S^n`. Conjecture: the compression bound improves to
`chordSq ≤ C·k^{-2m}`, i.e. each extra sphere dimension multiplies the
distinguishing power by `k`, formalizing the slogan "dimension = proof
resolution" from the original concept (`n − spherical_distance`).

**The key insight is** that a wider step-alphabet packed into a higher sphere
makes distinct sibling subproofs land in *orthogonal* directions, so the chord
gap no longer shrinks geometrically with proof length.

**Why now?** Mathlib already provides `stereographic` for general inner-product
spheres, and our `chordSq_eq` closed form generalizes verbatim to the squared
norm `‖σ(x) − σ(y)‖²`, so only the alphabet-block bookkeeping is new.

## Direction 3 — Stability of the embedding under proof rewriting

Real proof assistants normalize proofs (η/β-reduction, tactic-block reordering).
Model a rewrite as an operation on `List Bool` and ask: for which rewrite
classes is `codeReal` (or its repaired version) Lipschitz, so that semantically
equal proofs stay spherically close? Conjecture: prefix-preserving rewrites are
`1`-Lipschitz, while arbitrary transpositions are not — giving a geometric test
that *detects* non-prefix-preserving proof transformations.

**The key insight is** that the compression bound is governed solely by the
longest *common prefix*, so a rewrite is geometry-preserving iff it preserves
prefixes — turning "does this refactor change the proof's essence?" into a
measurable spherical displacement.

**Why now?** The catalog's `StereographicSheaf`/`StereographicRG` files already
treat stereographic data under flow/gluing operations; the same operadic
language can express proof rewrites, and our metric makes the question
quantitative for the first time.

## Direction 4 — A lemma-mining algorithm with a proven recall guarantee

Use the (repaired, Direction 1) embedding to cluster a corpus of proofs by
spherical distance and extract shared prefixes as candidate lemmas. Conjecture:
any two proofs whose stereographic points fall in a common ball of radius
`2^{-(m+1)}` are *guaranteed* to share an extractable subproof of length `≥ m`
— a provable recall lower bound for nearest-neighbour lemma discovery.

**The key insight is** that with an injective code the ball-radius-to-prefix
implication becomes a theorem, so a purely geometric clustering step inherits a
*certified* lower bound on the common structure it recovers — no heuristics.

**Why now?** Direction 1 supplies the missing converse inequality, and that
inequality is exactly the correctness certificate a metric-ANN lemma miner
needs; the forward bound here already certifies *precision* of the same
pipeline.

## Direction 5 — Triangle/geodesic refinement: angular vs. chord proof distance

Replace chord distance by the true geodesic (angular) distance
`θ = arccos(⟨σx, σy⟩)` and establish the metric-equivalence
`(2/π)·θ ≤ chord ≤ θ` (Jordan's inequality) so that all compression bounds
transfer to genuine spherical *geodesics*. Conjecture: the geodesic proof
metric satisfies a strengthened triangle inequality
`θ(p,r) ≤ θ(p,q) + θ(q,r)` that yields a sharp `n − θ` subproof bound matching
the original concept statement verbatim.

**The key insight is** that chord and arc are bi-Lipschitz on `S^n`, so every
chord-based theorem already proved (`spherical_compression`) upgrades to the
geodesic distance the concept literally asks for, at the cost of one analytic
inequality.

**Why now?** `chordSq_eq` and `stereo_mem_circle` give the exact chord in closed
form, and Mathlib's `Real.arccos`/`inner` API plus `Real.add_pow_le_pow_mul…`
make Jordan's inequality a contained analysis lemma rather than open theory.
