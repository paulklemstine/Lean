# Future Directions: Proof-Theoretic Ordinal Analysis

## 1. Ordinal Collapsing Functions and the Bachmann-Howard Ordinal

The current framework models theories by their set of provably well-ordered ordinals, but stops at the supremum (sSup). The next natural step is to formalize ordinal collapsing functions — the Bachmann-Howard hierarchy — which provide concrete ordinal notation systems for theories significantly beyond ε₀. The key insight is that ordinal collapsing functions (ψ, θ) allow us to "name" large ordinals using smaller ones as indices, creating a computable notation system for ordinals up to the Bachmann-Howard ordinal. Why now? Mathlib already has `ONote` for ordinals below ε₀; extending to collapsing functions would be the first formalization of these in any proof assistant, bridging the gap between concrete notation systems and abstract ordinal theory.

**Testable conjecture**: A collapsing function ψ_Ω defined on ordinal notations below Ω (the first uncountable ordinal) yields a well-founded notation system whose order type is exactly the Bachmann-Howard ordinal.

## 2. Proof-Theoretic Ordinals of Concrete Theories

Our `BoundedTheory` framework is abstract — it characterizes theories by their provably-WO sets without connecting to specific formal systems. The key insight is that by formalizing the encoding of well-ordering proofs in specific theories (PA, ATR₀, Π¹₁-CA₀), we can prove that the abstract PTO matches the known values: |PA| = ε₀, |ATR₀| = Γ₀, |Π¹₁-CA₀| = ψ_Ω(ε_{Ω+1}). Why now? The `bounded_theory_saturated` theorem shows all BoundedTheories are automatically saturated, which means the abstract framework perfectly captures the "initial segment" structure of provability — this is exactly the structure needed to connect to concrete theories.

**Testable conjecture**: There exists a computable function mapping PA proofs of transfinite induction principles to ordinal notations below ε₀, and every notation below ε₀ arises this way.

## 3. The Ordinal Triangle Inequality Obstruction and Commutative Quotients

We discovered that the natural ordinal-valued "distance" depthDist fails the triangle inequality due to non-commutativity of ordinal addition. The key insight is that this failure is not a bug but a feature: it reflects the genuine asymmetry of proof-theoretic strength, where combining two theories is not commutative at the ordinal level. Why now? The `depthDist_monotone_right` theorem shows that monotonicity holds, suggesting that the right framework is a directed metric space (quasi-metric) rather than a metric space. Formalizing the quasi-metric structure and characterizing when the triangle inequality does hold (e.g., for theories with PTOs below ω^ω, where ordinal arithmetic is commutative up to Cantor normal form) would give a precise boundary.

**Testable conjecture**: depthDist satisfies the triangle inequality if and only if all three PTOs involved are additive principal ordinals (ordinals α such that β + γ < α whenever β, γ < α).

## 4. Theory Strength as a Well-Quasi-Order

The `pto_strictly_increasing_chain` theorem shows that strictly increasing chains of theories have strictly increasing PTOs. The key insight is that by combining this with the well-foundedness of ordinals below a bound, we can show that the space of theories with bounded PTO forms a well-quasi-order under the provability inclusion relation. Why now? This would connect proof-theoretic ordinal analysis to the theory of well-quasi-orders (Kruskal's theorem, graph minor theorem), potentially yielding new independence results.

**Testable conjecture**: The set of BoundedTheories with PTO below ε₀, ordered by provablyWO inclusion, contains no infinite antichain (and is in fact a better-quasi-order).

## 5. Effective Ordinal Assignments via Fast-Growing Hierarchies

Mathlib's `ONote.fastGrowing` and `fastGrowingε₀` provide a computable hierarchy of functions ℕ → ℕ indexed by ordinal notations. The key insight is that the fast-growing hierarchy gives an effective characterization of proof-theoretic ordinals: a theory T has PTO ≥ α if and only if T can prove totality of the fast-growing function f_α. Why now? The `FinitelyDescribedTheory` structure already connects abstract PTOs to concrete `NONote` values; the next step is to connect these to the function-growth characterization, which is the historically primary way proof-theoretic ordinals were computed.

**Testable conjecture**: For every NONote α, there is a BoundedTheory T_α with PTO = α.repr such that T_α proves totality of `ONote.fastGrowing α` but no theory with PTO < α.repr can prove the same.
