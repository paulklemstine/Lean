Formalize a complete, type-checking Lean 4 file in Catalog/Bridges/NumericalMonsters/Bestiary.lean containing ONLY the numerical monster content described below. Do NOT include any unrelated content (no simplicial complexes, no Vietoris-Rips, no Belnap logic).

## Required Definitions (all must be complete, well-typed, with full type signatures)

1. `IsNarcissistic (n : ℕ) : Prop` — n equals the sum of its digits each raised to the power of its digit count. Provide a computable version `isNarcissistic : ℕ → Bool` and a decidability instance.

2. `IsVampire (v : ℕ) : Prop` — v is composite, has an even number of digits 2k, and there exist fangs x, y each with k digits, not both trailing-zero, such that v = x * y and the digit multiset of v equals the digit multiset of x ∪ y. Provide computable version and decidability.

3. `IsGhost (v : ℕ) : Prop` — there exist x, y ≥ 2 with v = x * y such that digits(v) ∩ (digits(x) ∪ digits(y)) = ∅ (as sets, not multisets). Provide computable version and decidability.

4. `IsWerewolf (v : ℕ) : Prop` — there exist x, y ≥ 2 with v = x * y such that |digits(v) ∩ (digits(x) ∪ digits(y))| = 1 (as sets). Provide computable version and decidability.

## Required Theorem Statements (all must have COMPLETE statements with full conclusions)

1. `narcissistic_lt : ∀ n, IsNarcissistic n → n < 10^60` — the finiteness bound. Proof sketch: reduce to showing d · 9^d < 10^(d-1) for all d ≥ 61, by induction where the step uses 9(d+1) < 10d (since d ≥ 61 > 9). Base case d=61 by native_decide.

2. `ghost_number_exists : IsGhost 161` — since 161 = 23 * 7, and digits(161) = {1,6} while digits(23) ∪ digits(7) = {2,3,7}, and {1,6} ∩ {2,3,7} = ∅. Prove by native_decide or explicit computation.

3. `vampire_harshad_bridge : IsVampire 1530 ∧ IsHarshad 1530` — since 1530 = 30 * 51 (fangs, digits match) and digit sum 9 divides 1530.

4. `triple_monster_9 : IsNarcissistic 9 ∧ IsHarshad 9 ∧ IsKaprekar 9` — single-digit narcissistic, divides by 9, and 9² = 81 with 8+1=9.

5. `vampire_not_prime (v : ℕ) : IsVampire v → ¬Nat.Prime v` — vampire numbers are composite by definition.

6. `harshad_infinite : ∀ n, ∃ m ≥ n, IsHarshad m` — all powers of 10 are Harshad.

## Required Proofs

- All proofs must type-check. Use `native_decide` for concrete specimens. Use `sorry` ONLY for the inductive step of narcissistic_lt if needed, but the theorem statement and proof structure must be complete and well-formed. The inequality lemma `pow_ineq : ∀ d ≥ 61, d * 9^d < 10^(d-1)` should have a complete proof by induction.

## Do NOT Include
- No simplicial complexes, Vietoris-Rips complexes, or topological content
- No Belnap four-valued logic
- No truncated theorem statements (every theorem must have a complete conclusion after `:`)
- No partial proof scripts that leave tactics hanging