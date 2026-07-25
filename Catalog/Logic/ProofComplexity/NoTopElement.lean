import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder
import Catalog.Logic.ProofComplexity.SimulationDegrees
import Catalog.Logic.ProofComplexity.DegreeLattice
import Catalog.Logic.ProofComplexity.OrderType

/-! # The p-degrees have a least element but **no greatest element**

This file is the **fifth cycle** of the order-theoretic Cook–Reckhow development.  The
earlier files built the simulation preorder `Simulates` on abstract proof systems
(`SimulationPreorder`), the generic separation template and the antisymmetrized poset of
p-degrees (`SimulationDegrees`), binary meets and an infinite increasing chain
(`DegreeLattice`), and the *width / bottom / density* triple (`OrderType`): in particular a
**least** p-degree `zeroSys` (`zeroSys_isBot`).

A bounded-below order type begs the dual question — *is there a greatest p-degree?*  Here we
prove the order type is genuinely **asymmetric**: there is a least element but provably
**no greatest one**.

* **No top element.**  For *every* proof system `T` over `ℕ` there is another system that
  `T` fails to p-simulate (`no_top : ∀ T, ¬ IsTop T`).  Equivalently, the simulation
  preorder is unbounded above: no single system simulates them all.

* **The order-type asymmetry.**  Packaging this with the catalog's bottom element gives
  `bot_exists_no_top`: the p-degrees have a least element but no greatest one.

The construction is a *local-to-global diagonalisation*.  A candidate top `T` would have to
p-simulate the diagonal system whose size on theorem `t` is `2 ^ (sec t) + 2 ^ t`, where
`sec t = T.size (a chosen T-proof of t)` is the *local* size datum that `T` exposes at the
theorem `t`.  Polynomial domination forces, at every theorem simultaneously, both
`2 ^ (sec t)` and `2 ^ t` to sit under one fixed polynomial in `sec t`; the first clamp
makes `sec` *globally bounded*, after which the second clamp `2 ^ t ≤ const` is absurd.
Thus the local size data can never be glued into a global simulation.

-- !-- Lab Notebook -- !--
Hypothesis : Dual to the known least element `zeroSys`, the simulation preorder should have
             *no* greatest element: one can always diagonalise against a candidate top by a
             size function that outruns every polynomial blow-up of the candidate's own
             proof sizes.
Result     : Confirmed, `sorry = 0`.  `no_top : ∀ T, ¬ IsTop T`, hence `bot_exists_no_top`
             — least element exists, greatest does not.
Insight    : The decisive growth fact is *eventual* (not just one-point) exponential
             dominance `poly_lt_exp_eventually : ∃ M, ∀ m ≥ M, (m+2)^k < 2^m`.  It lets the
             diagonal size `2^(sec t) + 2^t` clamp `sec` to a finite range via its first
             summand, turning the second summand `2^t` into an unbounded-vs-constant
             contradiction.  Surjectivity of `T.proves` supplies the section `sec` through
             `Function.surjInv`, so the argument needs *no* structure on `T` beyond
             completeness — it is the size layer alone that obstructs a top.
Failure analysis : A one-point dominance `∃ m, (m+2)^k < 2^m` (the shape of
             `exp_dominates_poly`) is too weak: it bounds `sec` at a single argument, not
             uniformly, so it cannot collapse `sec` to a global constant.  Strengthening to
             the eventual form `poly_lt_exp_eventually` is exactly what makes the
             local-to-global step go through.
-- !-- Lab Notebook -- !--
-/

set_option maxHeartbeats 1000000

namespace ProofComplexity

universe u v

/-! ## Eventual exponential dominance -/

/-
!-- comment: Exponential eventually beats any fixed polynomial, *uniformly* in the
argument — the uniform upgrade of `exp_dominates_poly`. -- !--

For every degree `k` there is a threshold `M` past which `(m + 2) ^ k < 2 ^ m` for all
`m ≥ M`.
-/
lemma poly_lt_exp_eventually (k : ℕ) : ∃ M, ∀ m, M ≤ m → (m + 2) ^ k < 2 ^ m := by
  -- We can use the fact that the exponential function grows faster than any polynomial function.
  have h_exp_growth : Filter.Tendsto (fun m : ℕ => ((m + 2 : ℝ) ^ k) / 2 ^ m) Filter.atTop (nhds 0) := by
    -- We can convert this limit into a form that is easier to handle by substituting $m = n$.
    suffices h_convert : Filter.Tendsto (fun n : ℕ => ((n : ℝ) ^ k) / 2 ^ n) Filter.atTop (nhds 0) by
      -- We can convert this limit into a form that is easier to handle by substituting $m = n + 2$.
      have h_convert : Filter.Tendsto (fun n : ℕ => ((n + 2 : ℝ) ^ k) / 2 ^ (n + 2)) Filter.atTop (nhds 0) := by
        exact_mod_cast h_convert.comp ( Filter.tendsto_add_atTop_nat 2 );
      convert h_convert.const_mul 4 using 2 <;> ring;
    -- We can convert this limit into a form that is easier to handle by substituting $m = n \log 2$.
    suffices h_convert : Filter.Tendsto (fun m : ℝ => (m / Real.log 2) ^ k / Real.exp m) Filter.atTop (nhds 0) by
      convert h_convert.comp ( tendsto_natCast_atTop_atTop.atTop_mul_const ( Real.log_pos one_lt_two ) ) using 2 ; norm_num [ Real.exp_nat_mul, Real.exp_log ];
    have := Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero k;
    convert this.div_const ( Real.log 2 ^ k ) using 2 <;> norm_num [ Real.exp_neg, div_eq_mul_inv, mul_pow, mul_assoc, mul_comm, mul_left_comm ];
  exact Filter.eventually_atTop.mp ( h_exp_growth.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ M, hM ⟩ ↦ ⟨ M, fun m hm ↦ by have := hM m hm; rw [ div_lt_one ( by positivity ) ] at this; exact_mod_cast this ⟩

/-! ## The diagonal anti-domination lemma -/

/-
!-- comment: No monotone polynomial blow-up `f` can keep `2^(s t) + 2^t` below `f (s t)`
for all `t`: the `2^(s t)` summand pins `s` to a finite range, then `2^t`
escapes the resulting constant bound. -- !--

**Diagonal anti-domination.**  For any `s : ℕ → ℕ`, the size function
`t ↦ 2 ^ s t + 2 ^ t` is dominated by *no* monotone polynomial blow-up of `s`.
-/
lemma not_dominated_diag (s : ℕ → ℕ) :
    ¬ ∃ f, PolyMono f ∧ ∀ t, 2 ^ s t + 2 ^ t ≤ f (s t) := by
  rintro ⟨ f, ⟨ hmono, hpb ⟩, hb ⟩;
  obtain ⟨ k, hk ⟩ := hpb;
  -- From `poly_lt_exp_eventually k` obtain M with `hM : ∀ m, M ≤ m → (m + 2) ^ k < 2 ^ m`.
  obtain ⟨ M, hM ⟩ := poly_lt_exp_eventually k;
  -- Step A (s is globally bounded by M): For each t, `s t < M`.
  have h_s_lt_M : ∀ t, s t < M := by
    grind;
  -- From `h_s_lt_M` and `hk`, we get `2 ^ t < (M + 1) ^ k` for all `t`.
  have h_contradiction : ∀ t, 2 ^ t < (M + 1) ^ k := by
    intro t; specialize hb t; specialize hk ( s t ) ; specialize h_s_lt_M t;
    linarith [ pow_pos ( by decide : 0 < 2 ) ( s t ), pow_le_pow_left' ( by linarith : s t + 2 ≤ M + 1 ) k ];
  contrapose! h_contradiction;
  exact ⟨ ( M + 1 ) ^ k, le_of_lt ( Nat.recOn ( ( M + 1 ) ^ k ) ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ Nat.one_le_pow n 2 zero_lt_two ] ) ⟩

/-! ## No greatest p-degree -/

/-
!-- comment: A candidate top `T` would simulate the diagonal system built from `T`'s own
local proof sizes `sec`, contradicting `not_dominated_diag`. -- !--

**No greatest p-degree.**  No proof system over `ℕ` is a greatest element of the
simulation preorder: for every `T` there is a system `T` does not p-simulate.
-/
theorem no_top (T : ProofSystem.{0, 0} ℕ) : ¬ IsTop T := by
  intro hT;
  obtain ⟨f, hf⟩ := hT (ProofComplexity.sysOfSize (fun t => 2 ^ (T.size (Function.surjInv T.complete t)) + 2 ^ t));
  simp +decide [ sysOfSize ] at hf;
  exact not_dominated_diag _ ⟨ f, hf.1, fun t => by simpa [ Function.surjInv_eq T.complete t ] using hf.2 ( Function.surjInv T.complete t ) ⟩

-- !-- comment: The order-type asymmetry, in one statement. -- !--
/-- **Order-type asymmetry.**  The p-degrees over `ℕ` have a least element (`zeroSys`) but
*no* greatest element. -/
theorem bot_exists_no_top :
    (∃ b : ProofSystem.{0, 0} ℕ, IsBot b) ∧ (∀ t : ProofSystem.{0, 0} ℕ, ¬ IsTop t) :=
  ⟨⟨zeroSys, zeroSys_isBot⟩, no_top⟩

end ProofComplexity