# Computational Evidence — Reflective Type Theory

The central object is the reflective modal sentence

    G(A) := □A ∧ ¬□□A      ("A is provable but not provably provable").

## 1. Small-case model search (satisfiability of G)

We look for a finite Kripke model `(W, R, V)` and a world `w` with `G(atom)`
true at `w`. Reading `□φ` at `x` as "φ holds at every `R`-successor of `x`":

* `□A` at `w`  ⇔  every successor of `w` satisfies `A`.
* `¬□□A` at `w` ⇔ some successor `v` of `w` has a successor `u` with `A` false.

For both to hold, the "bad" world `u` (where `A` is false) must be reachable in
two steps from `w` but must NOT be a direct successor of `w`. This is possible
only when `R` is **not transitive**.

Smallest witness (3 worlds, chain `a → b → c`, `A` true only at `b`):

| world | A? | successors | □A here? | □□A here? |
|-------|----|-----------|----------|-----------|
| a     | F  | {b}       | T (b⊨A)  | F (□A fails at b) |
| b     | T  | {c}       | F (c⊭A)  | —         |
| c     | F  | {}        | T (vac.) | T (vac.)  |

So `G(A)` is true at `a`. This is exactly `Kmodel` / `godelian_satisfiable_in_K`.

## 2. Counterexample hunt on transitive frames

Exhaustive reasoning (not an isolated example): in ANY transitive frame the
axiom `4` `□A → □□A` holds, because a 2-step successor is already a 1-step
successor. Hence `G(A) = □A ∧ ¬□□A` is **unsatisfiable on every transitive
frame**. We verified this at the level of a general proof rather than sampling:
`axiom4_of_transitive` and `godelian_unsat_in_transitive`.

This means the "provable but not provably provable" phenomenon is a strict
feature of NON-transitive provability (systems lacking provable
Σ₁-completeness). In standard arithmetic (and in `GL`) it cannot happen — a
genuinely instructive negative result.

## 3. Löb / Gödel-2 sanity check

On the concrete `GL` model `W = ℕ`, `R a b := b < a` (transitive, converse
well-founded), Löb's schema `□(□A → A) → □A` is valid, and its instance
`A := ⊥` gives `□(¬□⊥) → □⊥` (Gödel's second theorem). Small check of converse
well-foundedness: `fun a b => R b a = (a < b)`, and `<` on `ℕ` is well-founded,
so there is no infinite ascending `R`-chain — the hypothesis of Löb's theorem
holds. Encoded as `GLmodel_converse_wf`, `loeb_valid_GLmodel`.

## Conclusion

Computationally the picture is clean and complete: `G(A)` is satisfiable
(3-world non-transitive model) and unsatisfiable on all transitive frames.
No OEIS sequence arises; the content is logical/semantic rather than numerical.
All findings are backed by the machine-checked proofs in
`ReflectiveTypeTheory.lean`.
