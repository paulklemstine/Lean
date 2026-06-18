# Future Directions — Tropical Cryptocurrency on the Min-Plus Semiring

## Synthesis

This cycle formalized the tropical hash `TSHA h m = min_i (m_i + h_i)` and its
two-key strengthening `TSHA2 h h' m = (TSHA h m, TSHA h' m)` in
`Catalog/Tropical/TropicalMining.lean`, and proved six theorems (`sorry = 0`,
standard axioms only) that pin down the deterministic, structural core of the
"mining IS mathematics" proposal.

The unifying lens is **local-to-global**. A tropical hash value is a single global
scalar that is *glued from one local generator*: the argmin coordinate. The
forward map (`TSHA_realized`, `TSHA_le`) is an `O(k)` single pass that exhibits
this generator. The inverse map is obstructed precisely because the generator is
local: every **slack** coordinate (one not attaining the minimum) is an
unconstrained direction in the preimage fiber (`TSHA_collision_abundant`). The
second key is a *second cover*: it re-selects which coordinate is the local
generator, so a coordinate that is invisible to `h` (slack) but is the strict
argmin for `h'` is detected (`TSHA2_detects_collision`). Smoothness
(`TSHA_lipschitz`, `1`-Lipschitz) and min-plus linearity
(`TSHA_tropical_additive`, `TSHA_translation`) show the map is a genuine tropical
linear functional, connecting to the matrix-level theory in
`Tropical/MinPlusAlgebra.lean` (`tropMatVecMul`, `abs_inf_sub_inf_le_sup`,
`tropMatMul_lipschitz`).

## Results Summary

- `TSHA_le` / `TSHA_realized` — forward bound and argmin realization (the `O(k)`
  single-pass evaluation).
- `TSHA_lipschitz` — `|TSHA h m − TSHA h m'| ≤ ‖m − m'‖_∞`: `1`-Lipschitz
  smoothness (extends `abs_inf_sub_inf_le_sup` to the hash functional).
- `TSHA_tropical_additive` — `TSHA h (m ⊓ m') = TSHA h m ⊓ TSHA h m'`: min-plus
  additivity (the hash is a tropical linear functional / `⊕`-homomorphism).
- `TSHA_translation` — `TSHA h (m + c) = TSHA h m + c`: tropical scalar
  equivariance (`⊗`-homogeneity).
- `TSHA_collision_abundant` — slack ⇒ collision: any non-argmin coordinate can be
  raised arbitrarily to produce a *distinct* message with the *same* hash;
  the one-wayness obstruction.
- `TSHA2_detects_collision` — a slack-for-`h` coordinate that is the *strict*
  argmin for an independent key `h'` is detected by `TSHA2`; the second cover
  resolves the obstruction the first cover misses.

## Research Directions

### 1. The slack sheaf and an H¹ obstruction class for tropical preimages

Make the local-to-global picture literal. Over the message index set `Fin k`,
define a presheaf whose section over a subset `S` is the set of partial messages
that are consistent with the observed hash *when restricted to `S`* (i.e. the
local feasibility constraints `m_i + h_i ≥ y`, with equality somewhere). Gluing
local sections to a global preimage of a fixed value `y` should succeed iff a
Čech-style obstruction class in `H¹` of the index cover vanishes; for a single
key the class is generically non-trivial (matching `TSHA_collision_abundant`),
and for `TSHA2` the refined cover kills more of it (matching
`TSHA2_detects_collision`). *The key insight is* that collision abundance is not
an accident of `min`'s symmetry but the non-vanishing of a first cohomology of the
"feasibility presheaf," so adding keys is literally refining the cover. *Why now?*
We already have the deterministic local data (slack ⇒ free coordinate; strict
argmin ⇒ detection) isolated as theorems, so the presheaf and its `H⁰`/`H¹` can be
built directly on top with no new analytic input.

### 2. Exact preimage-fiber dimension as a falsifiable counting law

Conjecture: for `TSHA`, the preimage of a value `y` that is attained with a unique
strict argmin is an unbounded polyhedral set whose "free" directions are exactly
the slack coordinates, so the fiber over a generic `y` is `(k−1)`-dimensional;
for `TSHA2` with two keys in *general position* the joint fiber drops to
`(k−2)`-dimensional. *The key insight is* that each independent key removes exactly
one degree of freedom from the preimage polyhedron, so `r` independent keys give a
`(k−r)`-dimensional fiber until `r = k` forces (generic) injectivity. *Why now?*
`TSHA_collision_abundant` already exhibits one explicit free direction per slack
coordinate; counting them and proving the two-key drop is a finite linear-algebra
/ polyhedral argument well within reach, and it is sharply falsifiable (just
exhibit a fiber of the wrong dimension).

### 3. Quantitative `1 − O(1/k)` collision resistance under a key model

Promote `TSHA2_detects_collision` from a deterministic detection statement to the
original probabilistic claim. Fix a probability model on keys (e.g. `h, h'` i.i.d.
continuous), and prove that for two fixed distinct messages the probability that
they collide under *both* keys is `O(1/k)`, hence `TSHA2` is collision-resistant
with probability `1 − O(1/k)`. *The key insight is* that a joint collision forces
the same coordinate to be (near-)argmin for two independent keys, an event of
probability `~1/k` by symmetry over the `k` coordinates. *Why now?* The
deterministic skeleton — "distinct strict argmins ⇒ detection" — is already a
theorem, so the remaining work is a clean probabilistic estimate (argmin
distribution of i.i.d. perturbations) rather than new tropical structure.

### 4. The shortest-path reduction: TSHA-preimage ≡ tropical optimization

Formalize the headline reduction. Encode a weighted DAG so that `h` carries edge
weights and admissible messages `m` are indicator-style encodings of source-to-
sink paths; prove `TSHA h m` equals the path length and that finding `m` realizing
the minimal hash value equals computing the shortest path (the min-plus
matrix-power identity `(A^{⊗n})_{s,t} = ` shortest `s→t` length, building on
`tropMatMul_assoc` in `MinPlusAlgebra.lean`). *The key insight is* that the
tropical preimage problem is the *optimization* form of shortest paths, so "mining
= solving the hardest instance" is a statement about the worst-case path polytope,
not about brute force. *Why now?* The associativity and matrix-vector machinery
needed for iterated min-plus products already exist in the catalog, so the
reduction is an encoding lemma plus an induction on path length.

### 5. r-key hashing as a stalk-separating cover (injectivity threshold)

Generalize `TSHA2` to an `r`-key hash `TSHA_r` and identify the threshold at which
the family of keys *separates messages up to tropical equivalence*. Conjecture:
there is a finite set of `r = O(k)` keys in general position such that
`m ↦ (TSHA_{h_1} m, …, TSHA_{h_r} m)` is injective modulo global translation
(the unavoidable kernel from `TSHA_translation`). *The key insight is* that each
key is a *stalk probe* selecting one local generator, and enough probes in general
position recover every coordinate's relative value — collision resistance is a
covering/stalk-separation property, the dual of direction 1's obstruction.
*Why now?* `TSHA_translation` already exhibits the exact kernel that any injectivity
statement must quotient by, and `TSHA2_detects_collision` is the `r = 2` base case;
the induction on the number of separating keys is the natural next step.
