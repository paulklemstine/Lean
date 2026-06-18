Create a new standalone Lean 4 file proving a strict density result for a minimal asymptotic preorder on unary complexity functions. Do not continue or repair the partial Hecke file. Do not import or reference the Hecke packet development. The target should be a completed, sorry-free file with a small API and one main theorem.

Use the following exact mathematical plan.

1. Define a structure
   `structure PSystem where
      size : ℕ → ℕ`

2. Define eventual domination
   `def EventuallyLE (S T : PSystem) : Prop := ∃ N, ∀ n ≥ N, S.size n ≤ T.size n`
   and introduce notation `S ≼ T`.

3. Define strict comparison
   `def EventuallyLT (S T : PSystem) : Prop := S ≼ T ∧ ¬ T ≼ S`
   and notation `S ≺ T`.

4. Define the polynomial systems
   `def powSystem (k : ℕ) : PSystem := ⟨fun n => n^k⟩`.

5. Define an explicit intermediate witness between consecutive polynomial rungs. Prefer the parity-glued definition
   `def interPowSys (k : ℕ) : PSystem :=
      ⟨fun n => if Even n then n^(k+1) else n^k⟩`
   If this exact form causes avoidable Lean friction, an equivalent explicit split on `n % 2 = 0` is acceptable.

6. Prove the basic upper and lower eventual bounds:
   - `powSystem k ≼ interPowSys k`
   - `interPowSys k ≼ powSystem (k+1)`
   These should be easy pointwise inequalities for all `n`, or all sufficiently large `n`.

7. Prove strictness for `k ≥ 1`:
   - `¬ interPowSys k ≼ powSystem k`
   - `¬ powSystem (k+1) ≼ interPowSys k`
   The intended proof is by contradiction from the definition of eventual domination, then evaluating on infinitely many even or odd numbers beyond any threshold. For the first, on even `n`, `interPowSys k n = n^(k+1)` dominates `n^k`, and for `k ≥ 1` one can force `n^(k+1) ≤ n^k` to fail for all sufficiently large even `n` (indeed for all even `n ≥ 2`). For the second, on odd `n`, `interPowSys k n = n^k`, so eventual domination of `powSystem (k+1)` by `interPowSys k` would imply `n^(k+1) ≤ n^k` for all sufficiently large odd `n`, which fails for odd `n ≥ 3` when `k ≥ 1`.

8. Main theorem:
   `theorem strict_density_between_consecutive_powers {k : ℕ} (hk : 1 ≤ k) :
      powSystem k ≺ interPowSys k ∧ interPowSys k ≺ powSystem (k+1)`

9. Keep the development elementary and self-contained. Avoid introducing general asymptotic classes, quotient constructions, filters, big-O notation, or profile machinery. The goal is one clean theorem with explicit witnesses.

10. If helpful, first prove small arithmetic lemmas such as:
   - for `n ≥ 1`, `n^k ≤ n^(k+1)`
   - for `k ≥ 1` and `n ≥ 2`, `¬ n^(k+1) ≤ n^k`
   These can be proved using `pow_le_pow_right`, `Nat.mul_le_mul_left`, positivity of powers, and rewriting `n^(k+1) = n^k * n`.

11. Produce only a completed file with no placeholders, no commented-out theorem stubs, and no unnecessary abstractions. Name the file something appropriate under an applications or asymptotics-themed path.

The key deliverable is a fully formalized, sorry-free strict density theorem showing that between `n^k` and `n^(k+1)` there is an explicit intermediate unary complexity system under eventual domination.