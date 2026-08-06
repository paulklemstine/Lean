# Computational evidence

Target file: `Catalog/Novelty/MindToolsBoundedApprehension.lean`.

## 1. Counting binary proofs of bounded size

`shortStrings n : Finset (List Bool)` is the set of binary strings of length ≤ n
(the proofs available under resource bound `n`). Evaluated in Lean:

```lean
#eval (List.range 5).map (fun n => (MindTools.Bounded.shortStrings n).card)
-- [1, 3, 7, 15, 31]
```

| n | #{proofs of size ≤ n} | 2^(n+1) − 1 |
|---|----------------------|-------------|
| 0 | 1                    | 1           |
| 1 | 3                    | 3           |
| 2 | 7                    | 7           |
| 3 | 15                   | 15          |
| 4 | 31                   | 31          |

The sequence 1, 3, 7, 15, 31, 63, … is `2^(n+1) − 1` (Mersenne numbers, OEIS
A000225). This exact count is *proved*, not merely observed, in
`card_shortStrings`; the strict bound `card < 2 ^ (n+1)` used by the pigeonhole
argument is `card_shortStrings_lt`.

Consequence tested and then proved: any decoding `c : List Bool → ℕ` can reach
at most `2^(b+1) − 1` distinct sentences with proofs of size ≤ b, while
`{0, …, 2^(b+1) − 1}` has `2^(b+1)` elements, so at least one number below
`2^(b+1)` is inaccessible under budget `b`
(`exists_lt_two_pow_not_apprehended`).

## 2. The concrete length code

`lengthSystem` proves `n` by exhibiting any bit string of length `n`. Then

* apprehended at budget `b` = `{0, 1, …, b}` (proved: `lengthSystem_apprehends`),
* theory = all of ℕ (proved: `lengthSystem_theory`),
* explicit inaccessible witness at budget `b`: the sentence `b + 1`.

Small cases: budget 0 apprehends `{0}` and misses `1`; budget 3 apprehends
`{0,1,2,3}` and misses `4`. The pigeonhole bound for `b = 3` guarantees a miss
below `16`; the true miss is `4`, so the counting bound is sound but not tight
for this particular code — as expected, since the length code is a very
redundant (unary) encoding.

## 3. Counterexample hunt: is a well-founded tool hierarchy linearly ordered?

Tested on the smallest non-trivial families of extensional theories over
sentences `ℕ`. With `A = {0}` and `B = {1}` neither `A ⊆ B` nor `B ⊆ A`, so
neither is `Stronger` than the other, and the strict-strength relation on
`{A, B}` is empty — hence trivially ordinal-ranked and well-founded. This is a
genuine counterexample to the upgrade "well-founded ⇒ comparable", and it is
formalized as `wellFounded_not_total`.

By contrast, the resource-bounded family is always a chain
(`boundedTool_comparable`), so the failure of linearity is a feature of general
extensional theories, not of bounded apprehension.

## 4. Tightness of the pigeonhole bound (cycle 2)

The counting certificate of §1 says only that *some* sentence below `2^(b+1)`
escapes budget `b`. Is that bound attained? Evidence from the binary numeral
code `bcode l = val l - 1`, where `val` reads a bit string as a binary numeral
with an implicit leading `1` (so `val` is a bijection from strings of length `k`
onto `[2^k, 2^(k+1))`), computed in Lean:

```lean
#eval (List.range 8).map (fun n => bcode (enc (n+1)))
-- [0, 1, 2, 3, 4, 5, 6, 7]          -- enc is a right inverse of bcode
#eval (List.range 10).filter (fun n => decide ((enc (n+1)).length ≤ 2))
-- [0, 1, 2, 3, 4, 5, 6]             -- exactly the numbers < 2^3 - 1
```

| b | numbers apprehended at budget b | count | `2^(b+1) − 1` | least inaccessible |
|---|---------------------------------|-------|---------------|--------------------|
| 0 | {0}                             | 1     | 1             | 1                  |
| 1 | {0,1,2}                         | 3     | 3             | 3                  |
| 2 | {0,…,6}                         | 7     | 7             | 7                  |
| 3 | {0,…,14}                        | 15    | 15            | 15                 |

So the observed least inaccessible sentence is exactly `2^(b+1) − 1`, i.e. the
counting bound is attained. This is then *proved*, not merely observed, as
`bcode_apprehends` and `bcode_isLeast_not_apprehended` in
`Catalog/Novelty/MindToolsTranslations.lean`; strict growth at every single
budget is `bcode_strictMono` (contrast the redundant length code of §2, whose
least inaccessible sentence is only `b + 1`).

## 5. Counterexample hunt: do ordinal ranks ever force comparability?

Extending §3 beyond two tools: for the family of singleton theories
`singletonTool i = ⟨{i}⟩` indexed by any type, no two members are comparable
(`{j} ⊂ {i}` fails for all `i, j`), so the strict-strength relation is empty and
the constant rank `0` witnesses ordinal-rankedness. Searching for a size `n` at
which rank-ability forces some comparable pair therefore returns nothing:
`exists_ordinalRanked_antichain` produces an ordinal-ranked antichain of every
finite size `n`, and `exists_infinite_ordinalRanked_antichain` an infinite one.

## 6. The coded Hilbert calculus (cycle 2)

`Catalog/Novelty/MindToolsCalculus.lean` replaces the abstract `ProofSystem` by
a genuine calculus: formulas `Form` (atoms indexed by ℕ, implication),
derivation trees `Deriv` over the schemes `K`, `S` and modus ponens, a two-valued
semantics `Form.eval`, and the soundness theorem `Deriv.sound`.

```lean
#eval (Deriv.identity (Form.atom 3)).size      -- 79
#eval (Form.imp (Form.atom 3) (Form.atom 3)).size  -- 9
```

| a           | size a | size of the S–K–K derivation of a → a |
|-------------|--------|----------------------------------------|
| atom 0      | 1      | 31                                     |
| atom 1      | 2      | 47                                     |
| atom 3      | 4      | 79                                     |
| atom n      | n+1    | 16n + 31                               |

The affine law `size (identity a) = 16 · size a + 15` is *proved*
(`Deriv.identity_size`); its exactness as a *minimum* is Conjecture B of
`FUTURE_DIRECTIONS.md`. Because every derivation is at least as large as its
conclusion (`Deriv.size_conclusion_le`), the formula `atom (b+1) → atom (b+1)`
is a theorem with no derivation of size ≤ b, giving the unconditional
`hilbert_isMindTool`; soundness gives consistency (`atom_not_provable`).

## 7. Budget asymmetry between two systems with the same theory

`lengthSystem` and `binary bcode` both prove exactly the sentences ℕ, so they are
extensionally identical. Their budgets are not:

| b | `lengthSystem` apprehends | `binary bcode` apprehends |
|---|---------------------------|---------------------------|
| 0 | {0}                       | {0}                       |
| 1 | {0,1}                     | {0,1,2}                   |
| 2 | {0,1,2}                   | {0,…,6}                   |
| 3 | {0,…,3}                   | {0,…,14}                  |
| b | {0,…,b}                   | {0,…,2^(b+1)−2}           |

Translating the unary system into the numeral system costs nothing
(`lengthToBcode`, identity bound), while every translation the other way needs
`bound b ≥ 2^(b+1) − 2` (`bcode_to_lengthSystem_bound_ge`) and hence beats every
polynomial (`no_polynomial_translation_bcode_to_lengthSystem`).

## 8. The reflection hierarchy (cycle 2)

`Catalog/Novelty/MindToolsReflection.lean` iterates a *diagonal operator* — a map
sending each finite theory to a sentence it does not prove — starting from the
empty theory over `ℕ`, with `natDiag X = sInf {n | n ∉ X}`. A decidable model of
the construction was evaluated first:

```lean
def natDiagList (X : List Nat) : Nat :=
  (List.range (X.length + 1)).filter (fun n => !X.contains n) |>.head!
def iterL : Nat → List Nat
  | 0     => []
  | n + 1 => natDiagList (iterL n) :: iterL n
```

| stage `n` | theory `iterL n`   | sentence added at stage `n` |
|-----------|--------------------|-----------------------------|
| 0         | ∅                  | 0                           |
| 1         | {0}                | 1                           |
| 2         | {0,1}              | 2                           |
| 3         | {0,1,2}            | 3                           |
| 4         | {0,1,2,3}          | 4                           |
| 5         | {0,1,2,3,4}        | 5                           |

so the stages are `{k | k < n}` and the reflection step at stage `n` adds exactly
`n`. This is then *proved* as `iter_natDiag_empty`, with the limit computed by
`iterLimit_natDiag_empty`. Because the diagonal property is proved
(`natDiag_diagonal`) rather than assumed, the resulting strictly ascending,
ordinal-ranked, well-founded chain of mind tools is unconditional
(`exists_unconditional_reflection_chain`).

**Counterexample hunt for the conservativity question.** We looked for a pair of
theories that is conservative over a fragment yet extensionally stronger; the
smallest one found is `P = {n | Even n}`, `Q = ℕ`, fragment `F = {n | Even n}`,
witness `1 ∈ Q \ P` (`exists_conservative_fragment_and_stronger`). Conversely no
example of a conservative extension over the *whole* language that is stronger
exists, and this is proved (`not_stronger_of_conservative`).

**Profile gap at equal budget.** Comparing the two profiles of §7 numerically,
`#eval (List.range 8).map (fun b => (b + 1, 2 ^ (b + 1) - 1))` gives
`[(1,1), (2,3), (3,7), (4,15), (5,31), (6,63), (7,127), (8,255)]`: the numbers of
sentences apprehended at budget `b` by `lengthSystem` and by `binary bcode`. They
agree only at `b = 0`, which is exactly the hypothesis `1 ≤ b` in the proved
`apprehends_lengthSystem_ssubset_bcode`.
