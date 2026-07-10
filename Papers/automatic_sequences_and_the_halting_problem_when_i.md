# Computational Evidence — Automatic Sequences & the Zero-in-Sequence Problem

This note records the small computations that guided the formalization in
`AutomaticSequences.lean`.

## 1. The Thue–Morse sequence

`t n` = parity of the number of `1`s in the binary expansion of `n`
(equivalently, the parity of the binary digit sum). Computed via
`tm n = ((Nat.digits 2 n).sum : ZMod 2)`:

```
n :  0 1 2 3 4 5 6 7 8 9 ...15
t : 0 1 1 0 1 0 0 1 1 0  0 1 0 1 1 0
```

This matches **OEIS A010060** (Thue–Morse sequence), first terms
`0,1,1,0,1,0,0,1,1,0,0,1,0,1,1,0`. The defining automatic recurrences
`t(2n)=t(n)`, `t(2n+1)=t(n)+1` are visible in the table and are proved in Lean
(`tm_two_mul`, `tm_two_mul_add_one`), giving `t(2n) ≠ t(2n+1)`
(`tm_consecutive_ne`).

## 2. The parity automaton (2-automatic generation)

Two states (running parity), alphabet = binary digits `Bool`, transition
`s ↦ xor s a`, start `false`, accept `{true}`:

```
eval [true]        = xor false true            = true   (accepted)
eval [true,false]  = xor (xor false true) false = true   (accepted)
eval [true,true]   = xor (xor false true) true  = false  (rejected)
```

`Fintype.card Bool = 2`, so the length-2 accepted word `[true,false]` has length
`≥ card`, which triggers the pumping/infinitude machinery: the language is
infinite (`parityDFA_accepts_infinite`).

## 3. Testing the decidability algorithms (the "100 test sequences" spirit)

The theorems reduce two infinite questions to finite searches:

* **Emptiness / zero-in-sequence** (`accepts_nonempty_iff_bddWitness`):
  a DFA with `N` states accepts *something* iff it accepts a word of length `< N`.
  Test on random DFAs: BFS over states reaches an accept state iff a short word
  exists; the bound `N` is tight (a "counter to N-1" DFA needs a word of length
  exactly `N-1`).

* **Infinitude / zero-infinitely-often** (`accepts_infinite_iff_bounded`):
  infinite iff some accepted word has length in `[N, 2N)`. Test: a DFA accepting
  exactly `{ε}` (only the empty word) is finite and indeed has **no** word of
  length `≥ N` — confirming the corrected claim below.

## 4. Counterexample hunt — correcting a folklore claim

The mission text asserts: *"if the DFA accepts any string, it accepts infinitely
many, so `aₙ = 0` infinitely often."* This is **false**. Minimal counterexample:

```
States {q0, q1}, start q0, accept {q1}
step q0 a = q1,  step q1 a = q1  ... (any dead-accepting variant), OR
the DFA whose only accepted word is the empty string ε:
  start = accept = q0, step _ _ = q_dead (non-accepting sink).
```

The second automaton accepts exactly `{ε}` — a single string — so "accepts some
string" does **not** imply "accepts infinitely many". The correct dichotomy,
proved in Lean, is the pumping criterion: a DFA accepts infinitely many strings
**iff** it accepts one of length `≥ card σ` (`accepts_infinite_iff`).

## Conclusion

The computations confirm the two decidability reductions and expose the error in
the "always infinitely often" claim, all of which are reflected faithfully in the
formal statements.
