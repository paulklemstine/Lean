# Future Directions: Ordinal Analysis Across Systems

## 1. Full Transfinite Veblen Hierarchy

The current formalization defines the Veblen hierarchy at finite levels `veblenN : ℕ → (Ordinal → Ordinal)` by iterating `Ordinal.deriv`. The natural next step is extending this to transfinite levels using ordinal-indexed recursion: define `veblen : Ordinal → Ordinal → Ordinal` where `veblen α` for limit `α` enumerates the common fixed points of all `veblen β` for `β < α`.

The key insight is that Mathlib's `Ordinal.deriv` already handles the successor case perfectly, so the challenge reduces to formalizing the limit case using `Ordinal.nfp` over a family indexed by ordinals below `α`.

Why now? Mathlib's ordinal fixed-point infrastructure (`deriv`, `nfp`, `derivFamily`) is mature enough to support this. The missing piece is a clean transfinite recursion scheme for function-valued ordinal families, which could be built using `Ordinal.rec` or well-founded recursion on ordinals.

## 2. Semantic Interpretation of BHOrd and Correctness of ψ

The `BHOrd` notation system defines ordinal terms syntactically but lacks a semantic interpretation function `BHOrd → Ordinal`. The conjecture is that one can define a partial interpretation function `interp : BHOrd → Option Ordinal` such that for all well-formed terms `t`, `interp t` agrees with the standard ordinal it represents, and moreover `interp (psi zero) = Some epsilon0` where `epsilon0` is our formalized ε₀.

The key insight is that the interpretation of `psi` requires defining the collapsing set `C(α)` as a well-founded inductive-recursive definition, not just the approximation sequence we currently have. The full `collapsingSet` needs to be shown to be closed under the required operations, and the minimum ordinal not in `collapsingSet α` gives `ψ(α)`.

Why now? We have both the syntactic system (`BHOrd`) and the semantic foundation (`collapsingApprox`, `collapsingSet`) formalized. Connecting them is the natural bridge theorem.

## 3. Proof-Theoretic Strength Separation: PA vs. KP

The central claim of ordinal analysis is that ε₀ is the proof-theoretic ordinal of PA while ψ(Ω^ω) is that of KP (Kripke-Platek set theory). A formalization of this would involve: (a) defining a notion of "provably well-ordered" for a formal system, (b) showing that PA proves the well-ordering of all ordinal notations below ε₀, and (c) showing PA cannot prove the well-ordering of ε₀ itself.

The key insight is that (b) can be formalized as a meta-theorem about derivability in PA, using Gödel numbering of ordinal terms. The hard part is (c), which requires formalizing Gentzen's consistency proof or its modern refinements.

Why now? Lean 4 has increasingly good support for meta-programming and proof reflection. The `ONote` type in Mathlib already provides ordinal notations below ε₀ with decidable ordering, which is exactly the structure needed for encoding "provably well-ordered" statements.

## 4. Ordinal Notation Comparison and Normal Forms

Our `BHOrd` type permits non-normal-form terms (e.g., `add (add one one) one` vs. `add one (add one one)`). A decidable comparison function `BHOrd.compare : BHOrd → BHOrd → Ordering` that respects ordinal semantics would require defining Cantor Normal Form for the extended system and proving that every term has a unique normal form.

The key insight is that comparison of `psi` terms reduces to comparison of their arguments when the arguments are in normal form, making the recursion well-founded on term size. This is essentially the Bachmann property: ψ is order-preserving on its domain.

Why now? The `termSize` function and `isSmall`/`psiDepth` predicates we defined provide the structural foundation for well-founded recursion on BHOrd terms. The comparison algorithm is well-documented in Buchholz's work on ordinal notation systems.

## 5. Automated Ordinal Bounds for Recursive Programs

A long-term application: given a structurally recursive function in Lean 4, automatically compute an ordinal bound on its computational complexity (in the sense of the slow-growing hierarchy). The Veblen hierarchy provides natural complexity classes: functions below ε₀ correspond to primitive recursive functions, those below Γ₀ to predicative functions.

The key insight is that Lean 4's termination checker already computes a well-founded relation for recursive functions. Mapping these relations to ordinal notations in our `BHOrd` system would give automatic complexity bounds, connecting proof-theoretic ordinal analysis to practical program analysis.

Why now? The formalized Veblen hierarchy provides the semantic foundation, and Lean 4's elaboration and meta-programming infrastructure makes it feasible to inspect termination proofs programmatically. The `veblenN_succ_fixedPoint` theorem ensures the hierarchy is coherent across levels.
