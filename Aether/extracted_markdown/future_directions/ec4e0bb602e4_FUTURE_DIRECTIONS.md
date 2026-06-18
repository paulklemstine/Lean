# Future Directions: The Quasi-Metric Geometry of Proof-Theoretic Ordinals

This cycle established, in `Pythagorean/OrdinalQuasiMetric.lean`, the geometric
status of the ordinal-valued separation `depthDist` on the abstract theory space
of `Pythagorean/ProofTheoreticOrdinals.lean`. We proved that `depthDist` is a
*directed quasi-metric*: it is exactly additive along monotone chains
(`depthDist_directed_additive`) yet provably violates the symmetric triangle
inequality (`depthDist_triangle_fails`, via the PTO triple `ω+1, ω, 0` where the
finite leg is absorbed by `1 + ω = ω`). We also showed the principal theories
`ofOrdinal` form an order-embedding of the ordinals (`ofOrdinal_le_iff`,
`ofOrdinal_lt_iff`) that is totally ordered and well-founded under strict
inclusion (`ofOrdinal_totally_ordered`, `wellFounded_lt_ofOrdinal`). The
following directions extend this geometry.

## 1. The exact additive-principal boundary of the triangle inequality

Our `depthDist_directed_additive` shows additivity holds when the three PTOs are
linearly arranged, and `depthDist_triangle_fails` shows it can fail otherwise.
The remaining question is the precise frontier. The key insight is that the
single mechanism behind every failure is left-absorption of a finite (more
generally, small) remainder by a larger limit ordinal — exactly the negation of
the additive-principal property. We conjecture that for a *peak* configuration
`p ≤ q ≥ r`, the triangle inequality `depthDist(p,r) ≤ depthDist(p,q) +
depthDist(q,r)` holds **iff** the relevant gaps are additively absorbed in the
correct order, and that it holds unconditionally exactly when all three PTOs lie
below the least additive principal ordinal exceeding them. Why now? We already
have the additive identity and one explicit counterexample as endpoints of the
spectrum; the missing piece is a single absorption lemma about ordinal
subtraction, which Mathlib's `Ordinal.add_sub_cancel` family nearly provides.

**Testable conjecture:** `depthDist` restricted to theories whose PTOs are all
strictly below a fixed additive principal ordinal `δ` (e.g. `δ = ω^ω`) satisfies
the full symmetric triangle inequality, and `δ` additive principal is necessary.

## 2. A Hessenberg (natural-sum) metric that repairs the obstruction

`depthDist` fails the triangle law precisely because ordinary `+` is
non-commutative. The key insight is that replacing ordinal subtraction/addition
by the *natural* (Hessenberg) operations `⊕`, which are commutative and
cancellative, should yield a genuine `Ordinal`-valued metric `natDist` on the
theory space, with `depthDist ≤ natDist` pointwise. Why now? Mathlib provides
`Ordinal.nadd` (`♯`) with a full commutative-monoid API, so the metric axioms
become algebraic identities rather than case analyses; our
`depthDist_directed_additive` already supplies the monotone-case calibration to
compare the two distances.

**Testable conjecture:** `natDist T₁ T₂ := (T₁.pto ⊖ T₂.pto) ♯ (T₂.pto ⊖ T₁.pto)`
(natural subtraction and natural addition) satisfies `natDist a c ≤ natDist a b ♯
natDist b c` for all theories, making `(OrdinalTheory, natDist)` a bona fide
generalized metric space, with `depthDist a b ≤ natDist a b` always.

## 3. The principal embedding is an initial order-isomorphism onto a segment

We proved `ofOrdinal` is a strictly monotone, totally ordered, well-founded
embedding. The key insight is that it is in fact an *initial* embedding: its
image is exactly the sub-poset of theories whose `provablyWO` is downward closed
*and* open (a true `Iio`), so `ofOrdinal` realizes `Ordinal` as an initial
segment of the theory poset under inclusion. Why now? The catalog's
`Iio_pto_subset` already shows every theory contains `Iio (pto)`, so the only
obstruction to being principal is whether the theory contains its own supremum —
a single decidable alternative that cleanly splits the poset.

**Testable conjecture:** A theory `T` equals `ofOrdinal (T.pto)` iff
`T.pto ∉ T.provablyWO`; consequently `ofOrdinal` is an order-isomorphism from
`Ordinal` onto the set of "open" theories, and this set is a strict initial
segment of `(OrdinalTheory, ≤)`.

## 4. Well-quasi-order of all bounded theories, not just principal ones

`wellFounded_lt_ofOrdinal` gives well-foundedness on the principal slice. The key
insight is that the full poset of theories with bounded PTO is also a
well-quasi-order: any infinite sequence of theories has, by well-foundedness of
ordinals, a non-decreasing PTO subsequence, and `pto_monotone` together with the
`Iio_pto_subset` saturation forces a comparable pair. Why now? This upgrades the
linear well-foundedness we proved to the genuine antichain-free statement that
connects proof-theoretic strength to Kruskal/graph-minor-style WQO theory, and
every ingredient (monotonicity, saturation, ordinal well-foundedness) is already
formalized in the two files.

**Testable conjecture:** The poset of `OrdinalTheory` with PTO below a fixed
bound contains no infinite antichain under `≤`; equivalently `pto` is a WQO
reflection of theory inclusion.

## 5. Fast-growing calibration of the directed metric

Mathlib's `ONote.fastGrowing` assigns to each ordinal notation a function
`ℕ → ℕ`. The key insight is that `depthDist_directed_additive` makes `depthDist`
behave like an *ordinal-valued length along a chain*, which should match the
eventual-domination gap between the associated fast-growing functions: a longer
directed distance means a strictly faster-growing totality witness. Why now? The
`FinitelyDescribedTheory`/`NONote` infrastructure already links abstract PTOs to
concrete notations, so the directed additivity proved here is exactly the
compositional law one needs to transport distances to growth-rate hierarchies.

**Testable conjecture:** For principal theories `ofOrdinal a ≤ ofOrdinal b` with
notations `α, β`, the directed distance `b ⊖ a` (natural subtraction) controls
the eventual ratio of `ONote.fastGrowing β` to `ONote.fastGrowing α`; in
particular `depthDist` zero iff the two fast-growing functions are eventually
equal.
