# Computational Evidence — Anti-Mathematics (Ackermann model of HF)

The Ackermann coding reads a natural number `b` as the finite set
`{ a | Nat.testBit b a }` (positions of the `1`s in the binary expansion).
`a ∈ₐ b :⟺ Nat.testBit b a`.

## 1. Small-case membership (`members b`)

| `b` | binary | members |
|----:|-------:|:--------|
| 0 | 0      | `∅`       |
| 1 | 1      | `{0}`     |
| 2 | 10     | `{1}`     |
| 3 | 11     | `{0,1}`   |
| 5 | 101    | `{0,2}`   |

These are exactly the von-Neumann-style hereditarily finite sets, confirming the
model is `V_ω`.

## 2. Separation schema

`sep a = {x ∈ a | x even}`. For `a = 11` (`members 11 = {0,1,3}`):

```
members (sep 11) = [0]
```

matching `{x ∈ {0,1,3} | x even} = {0}`.  (Theorem `separation`.)

## 3. Replacement schema

`repl a = {x+1 | x ∈ a}`. For `a = 11`:

```
members (repl 11) = [1, 2, 4]
```

matching `{0+1, 1+1, 3+1} = {1,2,4}`.  (Theorem `replacement`.)

## 4. Axiom of Choice (choice set)

Take `a = {{0,2}, {1,3}}`, coded as `2^5 ||| 2^10 = 1056` with `members = {5,10}`
(since `5 = {0,2}`, `10 = {1,3}`).  The choice set selects the least element of
each member:

```
members (choiceSet 1056) = [0, 1]
```

i.e. `0 ∈ {0,2}` and `1 ∈ {1,3}`, meeting each member in exactly one point.
(Theorem `choice_HF`.)

## 5. Counterexample hunt

No counterexamples: every schema instance and choice instance sampled agrees with
the formal theorem.  The key structural facts (`a ∈ₐ b → a < b`, well-foundedness,
hereditary finiteness) are consequences of `Nat.testBit b a → a < b`, verified in
Lean for all `a, b`.

## Notes

- No OEIS sequence is central here; the objects are set-theoretic, not a single
  integer sequence.  (The cardinalities of `V_n` do form OEIS A014221:
  `1, 2, 4, 16, 65536, …`, i.e. iterated `2^`, but that is peripheral to the
  theorems proved.)
- All computations above were run with `#eval` against the same Lean/Mathlib
  version used for the proofs.


# Computational Evidence — Anti-Mathematics (Ackermann model of HF)

The Ackermann coding reads a natural number `b` as the finite set
`{ a | Nat.testBit b a }` (positions of the `1`s in the binary expansion).
`a ∈ₐ b :⟺ Nat.testBit b a`.

## 1. Small-case membership (`members b`)

| `b` | binary | members |
|----:|-------:|:--------|
| 0 | 0      | `∅`       |
| 1 | 1      | `{0}`     |
| 2 | 10     | `{1}`     |
| 3 | 11     | `{0,1}`   |
| 5 | 101    | `{0,2}`   |

These are exactly the von-Neumann-style hereditarily finite sets, confirming the
model is `V_ω`.

## 2. Separation schema

`sep a = {x ∈ a | x even}`. For `a = 11` (`members 11 = {0,1,3}`):

```
members (sep 11) = [0]
```

matching `{x ∈ {0,1,3} | x even} = {0}`.  (Theorem `separation`.)

## 3. Replacement schema

`repl a = {x+1 | x ∈ a}`. For `a = 11`:

```
members (repl 11) = [1, 2, 4]
```

matching `{0+1, 1+1, 3+1} = {1,2,4}`.  (Theorem `replacement`.)

## 4. Axiom of Choice (choice set)

Take `a = {{0,2}, {1,3}}`, coded as `2^5 ||| 2^10 = 1056` with `members = {5,10}`
(since `5 = {0,2}`, `10 = {1,3}`).  The choice set selects the least element of
each member:

```
members (choiceSet 1056) = [0, 1]
```

i.e. `0 ∈ {0,2}` and `1 ∈ {1,3}`, meeting each member in exactly one point.
(Theorem `choice_HF`.)

## 5. Counterexample hunt

No counterexamples: every schema instance and choice instance sampled agrees with
the formal theorem.  The key structural facts (`a ∈ₐ b → a < b`, well-foundedness,
hereditary finiteness) are consequences of `Nat.testBit b a → a < b`, verified in
Lean for all `a, b`.

## Notes

- No OEIS sequence is central here; the objects are set-theoretic, not a single
  integer sequence.  (The cardinalities of `V_n` do form OEIS A014221:
  `1, 2, 4, 16, 65536, …`, i.e. iterated `2^`, but that is peripheral to the
  theorems proved.)
- All computations above were run with `#eval` against the same Lean/Mathlib
  version used for the proofs.
