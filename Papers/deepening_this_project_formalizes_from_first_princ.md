# Computational Evidence — Stable Extensions and the Euler Bridge

Small-case checks supporting the theorems in
`Catalog/Novelty/ArgumentationStable.lean`. All claims below are additionally
proved formally in Lean.

## 1. The complete conflict graph `completeAF n`

Attacks: `a` attacks `b` iff `a ≠ b`. Symmetric and irreflexive.

Conflict-free sets = subsingletons (∅ and singletons). Hence the complex
`K(AF)` is `n` isolated points.

| n | conflict-free sets | stable extensions | χ(K(AF)) = Σ_{∅≠s}(-1)^{|s|-1} |
|---|--------------------|-------------------|-------------------------------|
| 1 | ∅, {0}             | {0}               | 1                             |
| 2 | ∅, {0}, {1}        | {0}, {1}          | 1 + 1 = 2                     |
| 3 | ∅ and 3 singletons | 3 singletons      | 3                             |
| 4 | ∅ and 4 singletons | 4 singletons      | 4                             |

For every `n ≥ 1`: #stable extensions = `n` = χ(K(AF)). This is
`euler_eq_stable_completeAF`.

Note each singleton `{a}` is stable: it is conflict-free, and every `b ≠ a` is
attacked by `a`. And it is the *only* kind: a stable set must be a subsingleton
(conflict-free) and nonempty (∅ is not stable for `n ≥ 1`, since no argument
attacks the missing element from inside ∅).

## 2. The stable hierarchy vs. the existence gap

Small directed (asymmetric) frameworks confirm that stable is strictly stronger
than preferred:

* Single self-attacking argument `R a a` (framework on `Fin 1`, `R := (· = ·)`):
  the only conflict-free set is `∅`, which is preferred but **not** stable
  (the argument `a ∉ ∅` is not attacked from ∅). So stable extensions can fail
  to exist while preferred extensions always exist — matching the theory
  (`stable_preferred` gives one inclusion, and this witnesses that the converse
  fails without symmetry/irreflexivity).

## 3. Why the symmetric collapse needs irreflexivity

With a self-loop `R a a`, the argument `a` can never be defeated from a
conflict-free set, so the maximal-conflict-free-⟹-stable direction fails. The
Lean lemma `maximalConflictFree_stable_of_symmetric` therefore takes both
`Symmetric R` and `∀ a, ¬ R a a`; `completeAF n` satisfies both.

These finite checks are subsumed by the formal proofs, which hold for arbitrary
(possibly infinite) argument types.
