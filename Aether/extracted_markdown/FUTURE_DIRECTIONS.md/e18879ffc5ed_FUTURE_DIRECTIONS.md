# Future Directions: Proof-Theoretic Ordinal Analysis

## 1. Complete Lattice Structure and the PTO Homomorphism

We proved that `meet_pto_eq_min` and the existing `join_pto_eq_max` show the PTO map preserves both binary meets and joins. The natural next step is to show that the collection of OrdinalTheories forms a complete lattice under inclusion (with arbitrary intersections and unions of initial segments), and that PTO is a complete lattice homomorphism to the ordinals. The key insight is that arbitrary intersections of initial segments are initial segments (straightforward), but arbitrary *unions* are only initial segments when the family is directed — characterizing when this fails would reveal the exact lattice-theoretic structure. Why now? The `pto_fiber_convex` theorem we proved shows fibers are convex, which is the first structural result about the lattice that goes beyond binary operations.

**Testable conjecture**: The set of all OrdinalTheories with `provablyWO ⊆ Set.Iio α` for fixed α forms a complete lattice isomorphic to the lattice of initial segments of α, which in turn is isomorphic to `Set.Iic α` as a complete lattice.

## 2. Fiber Characterization: From Convexity to Exact Description

We proved that PTO fibers are convex (if T₁ ≤ T ≤ T₂ and pto(T₁) = pto(T₂) then pto(T) equals that common value). But what *are* the fibers exactly? For a successor ordinal α+1, the fiber consists of all theories T with Iio(α+1) ⊆ T.provablyWO ⊆ Iic(α+1), since sSup must equal α+1 and downward closure forces containment of Iio(α+1). For limit ordinals α, the fiber is a singleton {Iio α} since sSup(Iio α) = α and any strictly larger initial segment would have a larger sSup. The key insight is that fibers are singletons at limit ordinals and intervals at successor ordinals — the counterexample `pto_strict_mono_counterexample` only works because ω is a limit ordinal but the *enlarged* theory contains ω itself (a successor-like phenomenon). Why now? The combination of `pto_fiber_convex` and `pto_strict_mono_counterexample` gives us both the structural constraint and the existence of non-trivial fibers.

**Testable conjecture**: For limit ordinals α, the PTO fiber over α is the singleton `{OrdinalTheory.ofOrdinal α}`. For successor ordinals α+1, the fiber is the two-element set `{ofOrdinal (α+1), ⟨Iic α, ...⟩}`.

## 3. Metric Completion and Cauchy Sequences of Theories

The directed triangle inequality (`depthDist_triangle_directed`) makes `depthDist` a genuine metric on any chain of theories. This suggests studying Cauchy sequences: a sequence T₁ ≤ T₂ ≤ ... of theories where depthDist(Tₙ, Tₘ) → 0 should converge to ⋃ Tₙ. The key insight is that since depthDist(Tₙ, Tₘ) = pto(Tₘ) - pto(Tₙ) for n ≤ m, Cauchy sequences are exactly those where pto(Tₙ) converges in the ordinals — and ordinal convergence from below is just having a supremum. Why now? The `ordinal_sub_triangle` lemma provides the arithmetic backbone, and connecting metric convergence to ordinal suprema would bridge analysis and proof theory.

**Testable conjecture**: For any monotone sequence T₁ ≤ T₂ ≤ ... of theories, the theory ⟨⋃ₙ Tₙ.provablyWO, ...⟩ has PTO equal to sup{pto(Tₙ)}, and this is the unique depthDist-limit of the sequence.

## 4. Ordinal Notation Systems and Decidable Theory Comparison

The `ofOrdinal_le_iff` theorem shows that the map α ↦ ofOrdinal(α) is an order embedding of ordinals into theories. Restricting to ordinals representable in Cantor Normal Form (via Mathlib's `ONote`) would give a *decidable* fragment: for `ONote` values n₁, n₂, we have `ofOrdinal n₁.repr ≤ ofOrdinal n₂.repr ↔ n₁.repr ≤ n₂.repr`, and the latter is decidable. The key insight is that `ONote` ordering is decidable and `ofOrdinal_le_iff` transfers this to theory comparison, giving a concrete algorithm for comparing proof-theoretic strengths of theories with PTOs below ε₀. Why now? The order-embedding result removes the gap between abstract ordinals and computable notations for the `ofOrdinal` family.

**Testable conjecture**: There exists an instance `DecidableEq` on the image of `ONote → OrdinalTheory` via `n ↦ ofOrdinal n.repr`, and the induced ordering is a decidable linear order isomorphic to `ONote`.

## 5. Interpolation Theorems and Craig's Lemma Analogue

The `pto_sandwich` theorem (from the base file) shows that elements in the symmetric difference of two theories are "sandwiched" between their PTOs. Combined with `pto_fiber_convex`, this suggests an interpolation theorem: given T₁ < T₂ with pto(T₁) < pto(T₂), for any ordinal α with pto(T₁) ≤ α ≤ pto(T₂), there exists an interpolating theory T with T₁ ≤ T ≤ T₂ and pto(T) = α. The key insight is that `ofOrdinal α` provides the interpolant when T₁ = ofOrdinal(pto(T₁)) — but the general case requires showing that "trimming" T₂ down to Iio α ∩ T₂.provablyWO gives a well-formed theory with the right PTO. Why now? The meet construction provides the trimming tool: meet(T₂, ofOrdinal α) should be the interpolant, and `meet_pto_eq_min` would give pto = min(pto(T₂), α) = α.

**Testable conjecture**: For theories T₁ ≤ T₂ and any ordinal α with pto(T₁) ≤ α ≤ pto(T₂), we have T₁ ≤ meet(T₂, ofOrdinal α) ≤ T₂ and pto(meet(T₂, ofOrdinal α)) = α, provided both theories are nonempty and α is a limit ordinal.
