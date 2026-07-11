# Computational Evidence

The central results are impossibility/undecidability statements and universal
fixed-point theorems, so the "evidence" is structural rather than numerical.
Two concrete finite checks support the constructions, and both are discharged
inside Lean (not by ad-hoc scripting).

## 1. Fixed-point-free witnesses (basis of Cantor via Lawvere)

`cantor_bool` relies on `Bool.not` having no fixed point. This is a finite
check verified by `decide` in Lean:

| `b`     | `Bool.not b` | `Bool.not b = b` |
|---------|--------------|------------------|
| `false` | `true`       | `false`          |
| `true`  | `false`      | `false`          |

So `∀ b, Bool.not b ≠ b`, exactly the hypothesis of `no_point_surjection`.
`cantor_powerset` uses the analogous fact that `¬ : Prop → Prop` is fixed-point
free (`Function.cantor_surjective`).

## 2. The `diagMachine` run ↔ `evaln` correspondence (small cases)

`diagMachine n` on program `c` and counter `s` halts precisely when the bounded
universal evaluator `Nat.Partrec.Code.evaln` first succeeds:

* At counter `s`, if `(evaln s c n).isSome` then the machine halts immediately.
* Otherwise it advances to counter `s + 1`.

Hence a run of `N` steps from counter `0` returns `none` iff
`∃ i < N, (evaln i c n).isSome`. Unrolling the first few steps:

| steps `N` | halts within `N`? |
|-----------|-------------------|
| `0`       | never (`some (c,0)`) |
| `1`       | iff `evaln 0 c n` succeeds |
| `2`       | iff `evaln 0` or `evaln 1` succeeds |
| `k+1`     | iff some `evaln i`, `i ≤ k`, succeeds |

This is proved in full generality as `diag_run`, and combined with
`evaln_complete`/`evaln_sound` gives
`diag_halts_iff : (diagMachine n).halts (c,0) ↔ (c.eval n).Dom`.

## 3. Counterexample hunt

The universal claims (`lawvere_fixed_point`, `cantor_bool`, Kleene's
`fixed_point`) are theorems of Mathlib-level generality; a counterexample would
contradict established mathematics. The one place a naive statement *does* fail
is the earlier cycle's `diagonal_no_decider`, whose `Surjective enum` hypothesis
is unsatisfiable (Cantor), making it vacuous — this cycle's
`selfmod_halting_undecidable` was written specifically to avoid that pitfall by
reducing to Mathlib's honest halting problem.

## Notes

No OEIS sequence is relevant: the objects are machines, codes, and predicates,
not integer sequences.
