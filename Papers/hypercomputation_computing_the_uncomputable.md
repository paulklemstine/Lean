# Computational Evidence

The theorems in this project are foundational statements of computability theory
(undecidability, cardinality of function spaces, closure of computability under
finite oracle information). They are *universally* quantified structural facts
rather than numerical conjectures, so the relevant "evidence" is small sanity
checks confirming that the objects behave as the proofs assume.

## 1. The halting set is genuinely infinite (so precision cannot be bounded)

For the "infinite precision" theorems to be non-vacuous, infinitely many programs
must halt (otherwise the halting stream would be eventually constant and finitely
describable). This is easy to witness: every constant program halts on every
input. In Mathlib terms, for each `k` the code `Nat.Partrec.Code.const k` has
`eval (const k) n = Part.some k`, which is defined for all `n`. Thus the halting
predicate is `true` on an infinite set of codes, and no finite prefix of the
halting bit-stream determines it.

## 2. Finite bit tables are finite (precision `p` ⇒ `2^p` behaviours)

A precision-`p` measurement yields `readBits b p`, a list of length exactly `p`
(`readBits_length`). There are only `2^p` such bit-tables:

| precision p | distinct tables `2^p` |
|-------------|-----------------------|
| 0           | 1                     |
| 1           | 2                     |
| 2           | 4                     |
| 3           | 8                     |
| 8           | 256                   |

Because a finite-precision device's answer depends only on its input and one of
these finitely many fixed tables, its output is a computable function — exactly
`finitePrecision_computable`.

## 3. Counting argument behind uncountability

The computable functions inject into the countable set of program codes
(`toCode_inj`), so they are countable. The full space `ℕ → Bool` has cardinality
`2^{ℵ₀} = 𝔠 > ℵ₀`. A quick finite analogue: on the first `n` inputs there are
`2^n` Boolean patterns while the number of "short" programs grows, but the gap
`2^n` versus the program count already illustrates why almost every function
escapes computation in the limit. No counterexample to the countability /
uncountability split is possible — it is a cardinal inequality.

## Counterexample hunt

No universal numerical claim is being made that could admit a counterexample; the
claims are the standard diagonalization / cardinality facts, all machine-checked
in the accompanying `.lean` files with only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).
