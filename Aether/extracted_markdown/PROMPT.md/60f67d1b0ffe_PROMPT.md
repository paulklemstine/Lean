
## PHASE A: LEAN 4 ONLY — DOING THE MATH

You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

### DELIVERABLES (strict — only this):
1. **lean files (count chosen by the Plan)**
2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
   conjectures as a freeform narrative (NOT a form). Each direction MUST
   include a "The key insight is..." sentence and a "Why now?" justification.
   This file drives the next research cycle — make it count.

### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
- NO `ARTICLE.md`
- NO `RESEARCH_PAPER.md`
- NO `demo.py` / `algorithms.py`
- NO HTML widgets
- NO `PACKAGE.json`
- NO prose for human readers (except FUTURE_DIRECTIONS.md)

### WHY THIS NARROW:
The Lean 4 file IS the deliverable. A self-contained Lean file with
3-5 world-class theorems is worth more than 30K characters of prose
about trivial results. Focus 100% of your compute on the math.
If your work is genuinely world-class, the packaging step is dispatched
automatically and cheaply.


## Concept

**Title**: The current `OrdinalTheory` framework works with abstract `Ordinal` values from 
**Domain**: Logic
**Mathematical framing**: # Future Directions: Proof-Theoretic Ordinal Analysis

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

**Concept description**: # Future Directions: Proof-Theoretic Ordinal Analysis

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

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Logic
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v6 Depth Requirements — Correct Proofs First

You are working on the frontier of mathematics. Your goal is to produce
Lean 4 code that COMPILES and PROVES non-trivial results. A correct proof
of one good theorem is worth more than 5 theorems with `sorry`.

### STEP 1: BRIEF PLAN (2-3 lines)

Before writing Lean code, state:
- **Strategy**: New structure (Grothendieck) OR extend existing result (Cauchy)
- **Theorems**: List the 2-4 theorems you will prove (one sentence each)
- **Why non-trivial**: One sentence explaining the key insight

### STEP 2: PROVE THEOREMS (correctness > completeness)

Write Lean 4 proofs that COMPILE. Every theorem should have:
- A complete proof (no `sorry` for the main result)
- A brief proof sketch as a comment (1-2 sentences)
- An `example` block showing the theorem in action (if practical)

For your BEST theorem, also provide:
- A generalization or strengthening (can use `sorry` if proving it would take too long)
- A boundary case or counterexample showing where the result fails

You do NOT need full PEGB on every theorem. Deep PEGB on your best theorem
and solid proofs on the rest is the target.

### STEP 3: Anti-patterns (avoid these)

These tactics indicate trivial proofs that add no value:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on the main theorem statement

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for generalizations and boundary cases.

### STEP 4: Novelty

Your theorems should be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
