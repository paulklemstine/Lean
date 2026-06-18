# Future Directions: Large Cardinal Hierarchy Formalization

## 1. Measurable Cardinals via Ultrafilters

The next step in the large cardinal hierarchy after Mahlo is the measurable cardinal. A cardinal κ is measurable if there exists a κ-complete non-principal ultrafilter on κ. This can be formalized using Mathlib's existing filter and ultrafilter infrastructure. The key theorem to prove would be: every measurable cardinal is Mahlo, establishing the next link in the consistency strength chain.

The key insight is that the existence of a κ-complete ultrafilter on κ implies that the set of regular cardinals below κ is not just stationary but in fact belongs to the ultrafilter — a much stronger property. This can be proved by showing that the set of singular cardinals below κ is not in the ultrafilter (using the Ulam matrix argument).

Why now? Mathlib already has `Filter`, `Ultrafilter`, and `Filter.CountableInter` (the countable completeness analogue). Extending to κ-completeness is a natural generalization, and the Ulam matrix argument has a clean combinatorial structure well-suited to formal verification.

## 2. Club Filter as a Normal Filter

Our formalization defines club and stationary sets with an ω-closure condition. The full theory requires closure under arbitrary sequences of length less than κ (not just countable sequences). Formalizing the club filter as a normal κ-complete filter on κ would unify several results and enable the Fodor pressing-down lemma (Fodor's theorem), which states that every regressive function on a stationary set is constant on a stationary subset.

The key insight is that the club filter is not just closed under finite intersection but under < κ-sized intersection (for regular uncountable κ), making it a normal ideal. This connects set theory to the theory of Boolean algebras and forcing.

Why now? The ω-closed version is formalized. Generalizing to arbitrary cofinality requires Ordinal.bsup infrastructure, which Mathlib now provides. Fodor's theorem has a short inductive proof once the definitions are right.

## 3. Indescribable Cardinals and Reflection Principles

A cardinal κ is Π¹_n-indescribable if for every Π¹_n sentence φ that holds in V_κ, there exists α < κ such that φ holds in V_α. The hierarchy of indescribable cardinals sits between Mahlo and measurable in consistency strength. Formalizing this requires a theory of the cumulative hierarchy V_α, which could be built using well-founded recursion on ordinals.

The key insight is that inaccessibility is equivalent to Π⁰₁-indescribability, and the Mahlo property is equivalent to Π¹₀-indescribability (a classical result of Hanf and Scott). This provides an alternative characterization of the large cardinals we formalized.

Why now? The key infrastructure — ordinal recursion, cardinal arithmetic, and the aleph fixed point theorem — is now in place from our formalization. The cumulative hierarchy can be built as a family of types indexed by ordinals using well-founded recursion.

## 4. Consistency Strength Separation via Inner Models

The ultimate goal is to prove strict separation: Con(ZFC + ∃ Mahlo) → Con(ZFC + ∃ inaccessible), but not vice versa. This requires constructing inner models — for example, showing that if κ is Mahlo, then V_κ is a model of ZFC + "there exists an inaccessible cardinal." This is inherently metamathematical and requires formalizing satisfaction relations for set-theoretic formulas.

The key insight is that the aleph fixed point theorem (proved in our formalization) and the exists_inaccessible_below theorem together show that V_κ for Mahlo κ sees inaccessible cardinals — this is the semantic content of consistency strength separation. Formalizing the satisfaction relation is the missing piece.

Why now? Recent work on formalizing Gödel's incompleteness theorems in Lean (e.g., the FLean project) provides patterns for encoding syntax and satisfaction. Our cardinal arithmetic results (pow_lt, aleph fixed points) provide the mathematical content that the inner model argument needs.

## 5. Cardinal Arithmetic Independence: Easton's Theorem

Easton's theorem states that the function κ ↦ 2^κ on regular cardinals can be essentially arbitrary (subject to König's theorem constraints). Formalizing even a weak version — showing that GCH is independent of ZFC — would connect our cardinal arithmetic results to forcing theory. Our `IsInaccessible.pow_lt` theorem shows that inaccessible cardinals provide natural upper bounds for cardinal exponentiation; Easton's theorem shows these bounds are essentially optimal.

The key insight is that our iterPow construction (used to build strong limits) is a special case of the beth function, and the gap between beth and aleph fixed points is precisely where GCH independence lives.

Why now? The iterPow infrastructure and strong limit theorems from our formalization provide the "ground model" side of the forcing argument. Formalizing Boolean-valued models (the algebraic approach to forcing) could leverage Mathlib's complete Boolean algebra library.
