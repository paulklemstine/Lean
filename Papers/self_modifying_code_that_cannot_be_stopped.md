# Computational Evidence

The central claims are logical (undecidability / non-existence of total deciders),
so the relevant "evidence" is finite sanity-checking of the model and of the
diagonal construction, all of which is discharged inside the Lean file itself.

## 1. The self-modifying / standard simulation agrees on small runs

The simulation theorem `halts_iff_std` says `m.halts cfg ↔ m.toStd.halts (prog, state)`.
Sanity check on concrete tiny machines (verified by `decide`/evaluation in Lean
while developing the proof):

| machine (P=S=ℕ), step                                   | start | halts? | steps to halt |
|---------------------------------------------------------|-------|--------|---------------|
| `fun _ _ => none`                                       | (0,0) | yes    | 1             |
| countdown `fun p s => if p+s=0 then none else (p,s-1)`  | (0,3) | yes    | 4             |
| self-rewriter `fun p s => some (p+1, s)`                | (0,0) | no     | —             |

Under `toStd` each of these produces exactly the same halting verdict, as the
step-indexed lemma `run_none_iff` requires.

## 2. The diagonal (contrarian) construction

The self-referential core is: with a candidate decider `H` and the contrarian
`d` satisfying `Halts d q ↔ H q q = false`, plug in `q = d`:

```
Halts d d ↔ H d d = false      (contrarian spec at d)
H d d = true ↔ Halts d d       (H correct at (d,d))
```

Truth-table over the single Boolean `H d d`:

| `H d d` | `Halts d d` (spec) | `Halts d d` (correctness) |
|---------|--------------------|---------------------------|
| true    | false              | true                      |
| false   | true               | false                     |

Both rows are contradictory, so no `(H, d)` pair can coexist — exactly what
`no_correct_decider` / `halting_contradiction` prove. This is a 2-row finite
check, so no larger search is needed.

## 3. Non-vacuity check

`selfref_hypotheses_satisfiable` exhibits `Prog = ℕ`, `Halts p _ := p ≠ 0`,
`H := fun _ _ => true`, `d := 0`. Then `Halts 0 q ↔ (0 ≠ 0) ↔ (true = false)` —
both `False` — so the contrarian hypothesis is satisfiable and the theorems are
not vacuous.

## 4. OEIS / counterexample hunt

No integer sequence is associated with these logical statements, so there is no
OEIS entry to report. The "counterexample hunt" is the truth-table above: the
universal claim (no correct total decider given a contrarian) has no
counterexample because both Boolean cases collapse to a contradiction.
