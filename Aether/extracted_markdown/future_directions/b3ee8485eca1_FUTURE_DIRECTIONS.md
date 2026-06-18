# Future Directions: Proof-Theoretic Ordinal Analysis

## 1. Ordinal Notation Systems and the ε₀ Barrier

The current `OrdinalTheory` framework works with abstract `Ordinal` values from Mathlib's set-theoretic ordinals. The next step is to connect this to *computable* ordinal notation systems — specifically Mathlib's `ONote` (ordinal notations below ε₀) and `NONote` (natural ordinal notations). The key insight is that the `pto_ofOrdinal_limit` theorem establishes that limit ordinals faithfully represent theories, but only for abstract ordinals; linking this to `ONote` would give a *decidable* theory comparison for theories with PTO below ε₀. Why now? The `Iio_sSup_subset_initSeg` half-saturation theorem shows that every ordinal below the PTO is provable, which is exactly the structural lemma needed to map between notation-system provability and set-theoretic provability.

**Testable conjecture**: For every `ONote` value `n`, `OrdinalTheory.ofOrdinal n.repr` has PTO exactly `n.repr`, and the inclusion ordering on such theories is decidable via the ordering on `ONote`.

## 2. The Quasi-Metric Geometry of Theory Space

We established that `depthDist` is a symmetric, positive-definite function on theory space (via `depthDist_comm`, `depthDist_self_eq_zero`, and `depthDist_eq_zero_iff`). The triangle inequality fails in general due to non-commutativity of ordinal addition, but the `pto_sandwich` theorem suggests a weaker "directed" triangle inequality may hold. The key insight is that ordinal subtraction satisfies `(a - b) + (b - c) ≥ a - c` when `a ≥ b ≥ c`, which is exactly the directed triangle inequality for the ordering induced by theory inclusion. Why now? The `pto_monotone` theorem guarantees that theory inclusion respects the PTO ordering, giving a directed structure to the space that should make the directed triangle inequality provable.

**Testable conjecture**: For theories T₁ ≤ T₂ ≤ T₃, `depthDist T₁ T₃ ≤ depthDist T₁ T₂ + depthDist T₂ T₃`, and this fails without the ordering assumption.

## 3. Lattice Structure of OrdinalTheories

The `join_pto_eq_max` theorem shows that the join operation is well-behaved with respect to PTOs. A natural next step is to formalize the *meet* (intersection) of theories and show that `OrdinalTheory` forms a complete lattice under inclusion, with PTO providing a lattice homomorphism to the ordinals. The key insight is that intersections of downward-closed sets are downward-closed, and the PTO of the meet should be the infimum of the PTOs — but this requires care because `sSup (S₁ ∩ S₂)` is not always `min (sSup S₁) (sSup S₂)` for general sets. Why now? Our discovery that strict inclusion does NOT imply strict PTO increase (the `{β | β < ω}` vs `{β | β ≤ ω}` counterexample) reveals that the PTO map is not an order embedding — characterizing its fibers (the equivalence classes of theories with the same PTO) is the right structural question.

**Testable conjecture**: The fibers of the PTO map are intervals in the inclusion lattice: if T₁ ≤ T₂ and pto(T₁) = pto(T₂) = α, then for any T with T₁ ≤ T ≤ T₂, pto(T) = α.

## 4. Connecting to Concrete Theories via Fast-Growing Hierarchies

The abstract framework should be connected to Mathlib's `ONote.fastGrowing` function hierarchy. The key insight is that a theory T "knows about" ordinal α if α ∈ T.provablyWO, and the fast-growing function f_α provides a *computational witness* of this knowledge: T should be able to prove totality of f_α for exactly those α in its provablyWO set. Why now? The `pto_le_of_not_mem` theorem gives the exact characterization needed: if T cannot prove α is well-ordered (α ∉ provablyWO), then α ≥ pto(T), which is precisely the "boundary" where the fast-growing hierarchy becomes unprovably total.

**Testable conjecture**: There exists a computable function from `ONote` to `OrdinalTheory` such that the PTO of the resulting theory equals the ordinal represented by the notation, and the theory's provablyWO set coincides with the set of notations whose fast-growing functions are provably total.

## 5. Well-Quasi-Order Structure Under Bounded PTO

The `pto_monotone` theorem shows that infinite ascending chains of theories produce infinite ascending sequences of ordinals. Since ordinals below any fixed bound are well-ordered, the set of theories with PTO below a fixed bound α admits no infinite strictly ascending chain *of PTOs*. The key insight is that while this does not immediately give a well-quasi-order (because PTO is not an order embedding, as we discovered), it does give a weaker "well-directed" structure: every infinite sequence of theories with bounded PTO has an infinite weakly increasing subsequence in the PTO ordering. Why now? The failure of strict monotonicity that we discovered (and documented in the file) actually makes this question more interesting — the PTO fibers add complexity that standard WQO theory for ordinals alone cannot capture.

**Testable conjecture**: The quotient of `{T : OrdinalTheory | T.pto < ε₀}` by PTO-equivalence (T₁ ~ T₂ iff pto(T₁) = pto(T₂)) is a well-order isomorphic to ε₀, and each equivalence class is a complete lattice under theory inclusion.
