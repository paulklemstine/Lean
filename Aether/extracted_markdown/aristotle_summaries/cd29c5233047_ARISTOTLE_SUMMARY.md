# Summary of changes for run 0c2dbcf4-e097-4e9d-ad8b-383c30c4ec46
## Completed: Proof-Theoretic Ordinal Analysis — Extended Framework

### Files produced
- **`Logic/ProofTheoreticOrdinals.lean`** — 298 lines, 0 sorries, fully compiled
- **`FUTURE_DIRECTIONS.md`** — 5 testable conjectures for future research cycles

### Main theorems proved (8 total, all sorry-free)

1. **`meet_pto_eq_min`** — The PTO of the meet (intersection) of two nonempty theories equals the minimum of their PTOs. This completes the lattice-homomorphism picture together with the existing `join_pto_eq_max`.

2. **`pto_fiber_convex`** — The fibers of the PTO map are convex in the inclusion order: if T₁ ≤ T ≤ T₂ and pto(T₁) = pto(T₂), then pto(T) equals that common value. This is the key structural result showing that PTO non-injectivity is "well-behaved."

3. **`depthDist_triangle_directed`** — For ordered theories T₁ ≤ T₂ ≤ T₃, the depth distance satisfies the triangle inequality, making it a genuine metric on chains.

4. **`ordinal_sub_triangle`** — The arithmetic backbone: for a ≤ b ≤ c, (c - a) ≤ (b - a) + (c - b) in ordinal subtraction.

5. **`ofOrdinal_le_iff`** — The map α ↦ ofOrdinal(α) is an order embedding: ofOrdinal α ≤ ofOrdinal β ↔ α ≤ β.

6. **`pto_ofOrdinal_le`** — PTO of ofOrdinal α is always ≤ α.

7. **`pto_ofOrdinal_zero`** — PTO of the empty theory (ofOrdinal 0) is 0.

8. **`pto_strict_mono_counterexample`** — Formal counterexample: {β | β < ω} ⊊ {β | β ≤ ω} but both have PTO = ω, proving strict inclusion does NOT imply strict PTO increase.

### Key mathematical insights
- The PTO map is a lattice homomorphism (preserving meet and join) but not an order embedding — its fibers are convex clusters.
- The depth distance becomes a true metric on chains, with the directed triangle inequality following from a clean ordinal subtraction identity.
- The counterexample at ω demonstrates that non-injectivity arises from the distinction between open and closed initial segments at limit ordinals.

All theorems use only standard axioms (propext, Classical.choice, Quot.sound).