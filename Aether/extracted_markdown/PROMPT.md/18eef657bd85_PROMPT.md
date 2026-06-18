Complete the formalization of diagonalization for three-valued oracles in Lean 4. This is a retry of a severely truncated file.

## Definitions (all must be completed)

```
abbrev Predicate := ℕ → Bool
abbrev Verdict := Option Bool
abbrev Oracle := ℕ → Verdict

def agrees (O : Oracle) (g : Predicate) : Prop := ∀ n, O n ≠ some (!(g n))
-- An oracle agrees with a predicate iff it never returns the opposite answer.
-- Equivalently: whenever O n = some b, then b = g n.

def Complete (O : Oracle) : Prop := ∀ n, ∃ b, O n = some b
-- A complete oracle always returns a definite answer.
```

## Theorems to prove (all must compile)

1. **diagonal_escape**: `∀ F : ℕ → ℕ → Bool, ∃ g : Predicate, ∀ i, g i ≠ F i i`
   Proof: take `g n = !(F n n)`. Then `g i = !(F i i) ≠ F i i` since `b ≠ !b` for any `Bool`.

2. **not_surjective_nat_to_predicate**: `¬Function.Surjective (λ (i : ℕ) (n : ℕ), F i n)` for any `F : ℕ → ℕ → Bool`.
   This follows from `diagonal_escape`.

3. **not_exists_surjective_nat_to_predicate**: `¬∃ f : ℕ → Predicate, Function.Surjective f`
   Direct corollary.

4. **complete_family_forces_error**: `∀ F : ℕ → Oracle, (∀ i, Complete (F i)) → ∃ g : Predicate, ∀ i, F i i ≠ some (g i)`
   Key result: any countable family of *total* oracles has a predicate that every oracle gets wrong at its own index. Proof: let `g n` be the Boolean opposite of whatever `F n n` returns (which is `some b` since `F n` is complete). Then `F n n = some b ≠ some (!b) = some (g n)`.

5. **family_error_or_incomplete**: `∀ F : ℕ → Oracle, ∀ i, F i i = none ∨ ∃ g : Predicate, F i i = some (!g i)`
   Weakening: each oracle is either silent at its own index, or we can find a predicate it's wrong about. Proof: by cases on `F i i`. If `none`, left. If `some b`, take `g` with `g i = !b`.

6. **no_oracle_family_captures_all_predicates**: `∀ F : ℕ → Oracle, ¬∀ g : Predicate, ∃ i, agrees (F i) g`
   No countable family of oracles captures all predicates. Proof by contradiction: if every `g` has some `i` with `agrees (F i) g`, define `g n = match F n n with | some b => !b | none => true`. Then for any `i`, if `F i i = some b` then `g i = !b` but `F i i = some b`, so `F i` disagrees at `i`. If `F i i = none`, then `F i` is incomplete.

## Important implementation notes
- The `diag` definition must be completed (it was truncated)
- For `Bool` inequality: use `Bool.ne` or prove `b ≠ !b` as a lemma
- For `not_surjective_nat_to_predicate`: the proof should unfold `diagonal_escape` and derive the surjection contradiction
- All proofs must be complete and compile without errors
- Import `Mathlib` and work in a namespace
- Do NOT leave any `sorry` or incomplete proofs