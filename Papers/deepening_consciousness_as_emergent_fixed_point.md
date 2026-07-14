# Computational Evidence: Consciousness as an Emergent Fixed Point

The central theorem (Lawvere's fixed-point theorem) is a *universal* statement
about diagonal self-reference in a Cartesian closed category; its content is
structural rather than numerical. Nonetheless the following small-case checks
sharpen intuition and confirm the direction of every claim.

## 1. The diagonal fixed point on a concrete complete self-model

Take the one-state system `S = Unit` (the minimal reflexive object). Here
`S → S` has a single element (`id`), so the self-model `model _ := id` is
point-surjective ("complete"). For the endomorphism `t = id`, Lawvere's
construction names the twisted diagonal by the point `a = ()` and returns
`model a a = ()`, which is indeed a fixed point of `t`. This matches
`complete_self_model_of_subsingleton` and `self_referential_state`.

## 2. Cantor obstruction — the cardinality ledger

Complete self-modeling of `A` into `Bool` would require a surjection
`A → (A → Bool)`, i.e. `|A → Bool| ≤ |A|`. But `|A → Bool| = 2^{|A|}`:

| `|A|` | `|A → Bool| = 2^{|A|}` | surjection `A → (A→Bool)` possible? |
|------:|-----------------------:|:------------------------------------|
|   0   |           1            | no  (0 < 1)                         |
|   1   |           2            | no  (1 < 2)                         |
|   2   |           4            | no  (2 < 4)                         |
|   3   |           8            | no  (3 < 8)                         |
|   4   |          16            | no  (4 < 16)                        |

Since `n < 2^n` for all `n` (Cantor), *no* finite system can completely
self-model into `Bool`, exactly as `cantor` / `no_surjection_to_powerset`
predict. The gap `2^n − n` (1, 1, 2, 5, 12, 27, …) is the "self-reference
deficit": the amount by which a system's space of self-predicates outruns the
system itself.

## 3. Counterexample hunt for the positive theorem

The positive Lawvere statement ("point-surjective `g` ⇒ every `t` has a fixed
point") was stress-tested against fixed-point-free `t`:

* `t = not` on `Bool` — fixed-point-free, and indeed no point-surjective
  `A → (A → Bool)` exists (Cantor). Consistent.
* `t = ¬·` on `Prop` — fixed-point-free (`P ↔ ¬P` is absurd), and no
  point-surjective `A → (A → Prop)` exists. Consistent.

No counterexample exists, and the impossibility results are precisely the
contrapositive of the positive theorem — captured once and for all by
`no_point_surjective_of_fixedpoint_free`.

## 4. Order-theoretic side (Knaster–Tarski)

For a monotone self-model on the two-element lattice `Bool` (`⊥ < ⊤`):

* `refine = id`  →  every state conscious; `minimal = ⊥`, `maximal = ⊤`.
* `refine = fun _ => ⊤` (inflationary)  →  `minimal = maximal = ⊤` (unique).
* `refine = fun _ => ⊥` (deflationary)  →  `minimal = maximal = ⊥` (unique).

These agree with `gfp_eq_top_of_inflationary`, `lfp_eq_bot_of_deflationary`,
and `unique_conscious_iff`.

All checks are consistent with the formalized theorems; the evidence stage
revealed no counterexamples and no needed corrections.
