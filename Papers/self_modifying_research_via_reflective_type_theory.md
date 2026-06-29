# Computational Evidence — Reflective Research Convergence

Topic: *Self-Modifying Research via Reflective Type Theory.* We model a research
system as a `ReflectiveSystem`: a state space with an integer **quality** that is
bounded above by a ceiling `bound`, and a self-improvement operator `step` that
never decreases quality. The **outcome** of cycle `n` is the quality after `n`
iterated cycles. We claim outcomes (and the dependent *cycle types* indexed by
them) converge.

## 1. Small-case calculations (`capSystem B`, start state 0)

`capSystem B` has states `ℕ`, `quality s = min s B`, `step s = s + 1`. Outcome of
cycle `n` is `min n B`. Computed in Lean via `#eval`:

| B | outcomes for n = 0..6                 | converges at | limit |
|---|---------------------------------------|--------------|-------|
| 3 | 0, 1, 2, 3, 3, 3, 3                    | n = 3        | 3     |
| 5 | 0, 1, 2, 3, 4, 5, 5                    | n = 5        | 5     |
| 0 | 0, 0, 0, 0, 0, 0, 0                    | n = 0        | 0     |

`#eval (capSystem 3).outcome (capStart 3) 5 = 3` and
`#eval (capSystem 3).outcome (capStart 3) 2 = 2` confirm the saturating behaviour.
This matches `capSystem_outcome : outcome n = min n B` and
`capSystem_converged : ∀ n ≥ B, outcome n = B`.

## 2. Sequence / OEIS

The outcome sequence of `capSystem B` is `min n B`, i.e. `0,1,2,…,B,B,B,…`. This is
the elementary "ramp then plateau" family; no specialized OEIS entry is needed —
its only structural content is monotone + saturating, which is exactly the
hypothesis class of the convergence theorem.

## 3. Counterexample hunt — the bold (FALSE) variant

Bold conjecture tested: *"a monotone quality bounded by `B` stabilizes by cycle
`B`"* (i.e. `outcome n = outcome B` for all `n ≥ B`).

Counterexample (hand-computed, ceiling B = 2):

```
quality sequence:  0, 0, 0, 0, 1, 2, 2, 2, ...
```

This is monotone and bounded by 2, but `outcome 2 = 0 ≠ 2 = outcome 5`. So the
stabilization *time* is NOT bounded by `B`. What *is* bounded is the **number of
strict improvements** (here 2 ≤ B). This contradiction forced the corrected
formalization:

* keep `reflective_convergence` as *eventual* constancy (no time bound);
* prove `improvement_count_le_bound`: at most `bound` cycles strictly improve.

## 4. Conclusion

The computational landscape confirms the *eventual-constancy* statement and the
*bounded-improvement-count* statement, and refutes the *bounded-time* statement.
The Lean proofs in `ReflectiveResearch.lean`,
`ReflectiveResearchDependent.lean`, and `ReflectiveResearchExamples.lean` encode
exactly these corrected claims (all `#print axioms` clean; all `#eval`s decidable).
