# Summary of changes for run 8bb2deaf-adb7-402b-b7a1-0c7ab0b14dfa
Added a new self-contained Lean file `Catalog/Applications/FibonacciRankOfApparition.lean` and a `FUTURE_DIRECTIONS.md`.

## New theorems (all proved, sorry = 0, standard axioms only)
The file builds a first-principles theory of the **rank of apparition** (entry point) of the Fibonacci sequence, driven entirely by the strong-divisibility identity `Nat.fib_gcd`:

1. `fib_dvd_gcd` — if `p ∣ fib m` and `p ∣ fib n` then `p ∣ fib (gcd m n)` (the "compression" lemma).
2. `fib_entry_point` — for any modulus `p` with least positive index of appearance `z`, the indices `n` with `p ∣ fib n` are exactly the multiples of `z`. Fully general (no primality needed).
3. `fib_strong_divisibility` — for `3 ≤ m`, `fib m ∣ fib n ↔ m ∣ n`.
4. `fib_coprime_iff` — `fib m` and `fib n` are coprime iff `gcd m n ≤ 2`.
5. `fib_primitive_divisor_entry` — a primitive divisor of `fib n` has entry point exactly `n`, so its appearance set is precisely the multiples of `n`.

Each carries a one–two sentence `!--`-marked proof sketch, and the file opens with a `Lab Notebook` block (Hypothesis / Result / Insight / Failure analysis). All five results were verified to depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Catalog synthesis
These results form the structural skeleton underneath the catalog's Carmichael primitive-divisor work (`Catalog/Shared/CarmichaelProof.lean`, `Catalog/Novelty/KorseltCarmichael.lean`): `fib_primitive_divisor_entry` is exactly the `bridge_lemma` used there, generalized to all indices. The file extends rather than reproves that material.

## FUTURE_DIRECTIONS.md
Contains a Synthesis, a Results Summary table, and 5 falsifiable research directions (entry-point multiplicativity, Pisano-period control, generalization to Lucas sequences, a sieve route to closing the Carmichael composite tail, and an effective density bound), each with a "The key insight is…" sentence and a "Why now?" justification.

## Note on the existing open `sorry`
The project's one remaining code-level `sorry`, in `Catalog/Shared/CarmichaelProof.lean`, is the infinite composite tail `n > 10000` of Carmichael's theorem — a research-hard statement requiring cyclotomic/Zsygmondy growth estimates beyond the finite `native_decide` range. It was left in place (it is pre-existing and not one of the new main results); the structural meaning of "primitive divisor" needed to attack it is now a proved equivalence here, and a concrete reduction strategy is documented as Direction 4 in FUTURE_DIRECTIONS.md. (The broader catalog build is independently misconfigured — missing helper imports such as `Shared.CarmichaelHelper` and an `Applications` library target — so the new file was verified directly via standalone elaboration with `import Mathlib`.)