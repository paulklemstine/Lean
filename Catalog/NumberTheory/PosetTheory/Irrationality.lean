import Mathlib

/-!
# Irrationality criteria and the Euler–Mascheroni constant

This file develops the *Diophantine engine* behind every irrationality proof
(the existence of arbitrarily good but never exact integer linear forms) and
specializes it to the Euler–Mascheroni constant `γ = eulerMascheroniConstant`.

Whether `γ` is irrational is a famous open problem.  We therefore do **not**
claim to settle it.  Instead we make precise *what an irrationality proof of `γ`
would have to produce*, and we record the structural facts about `γ` that are
already provable (positivity, the sandwich `seq n < γ < seq' n`, and the fact
that the trapping interval shrinks to a point).

-- !-- Lab Notes -- !--
HYPOTHESIS (engine).  A real `x` is irrational *iff* for every `ε > 0` there are
integers `q ≥ 1`, `p` with `0 < |q·x − p| < ε`.  Intuition: rationals `a/b` have
a hard floor `|q·x − p| ≥ 1/b` whenever the form is nonzero, while irrationals
admit arbitrarily small nonzero forms (Dirichlet).  This is the abstract content
of Apéry-style irrationality proofs.

EXPERIMENT.  Forward (irrational ⇒ small forms) is `Real.exists_nat_abs_mul_sub_round_le`
(Dirichlet's approximation theorem, already in Mathlib).  Backward uses the
nonzero-integer floor `|n| ≥ 1`.

INSIGHT / FAILURE ANALYSIS for `γ`.  The natural approximating sequences to `γ`
are `seq n = H_n − log(n+1)` and `seq' n = H_n − log n`.  These trap `γ` in an
interval of width `log(n+1) − log n = log(1 + 1/n) → 0`, but the **endpoints are
not rational** — they carry a logarithm.  So the obvious sandwich does *not*
feed the engine above (which needs rational/integer data).  This is precisely
why `γ`'s irrationality is hard: no elementary rational approximation is known.
-/

open Filter Topology Real

namespace EulerMascheroni

/-! ## Part 1 : the abstract irrationality engine -/

/-
**Diophantine engine (sequence form).**  If a real `x` admits integer linear
forms `q n · x − p n` that are always nonzero yet tend to `0`, with `q n ≥ 1`,
then `x` is irrational.
-/
theorem irrational_of_tendsto_linear_form
    (x : ℝ) (q : ℕ → ℕ) (p : ℕ → ℤ)
    (hne : ∀ n, (q n : ℝ) * x - (p n : ℝ) ≠ 0)
    (htend : Tendsto (fun n => (q n : ℝ) * x - (p n : ℝ)) atTop (𝓝 0)) :
    Irrational x := by
  contrapose! hne; simp_all +decide [ Irrational ] ;
  obtain ⟨ y, rfl ⟩ := hne; simp_all +decide [ Rat.cast_def ] ;
  -- Since $q n * (y.num / y.den) - p n$ tends to $0$, for every $\epsilon > 0$, there exists an $N$ such that for all $n \geq N$, we have $|q n * (y.num / y.den) - p n| < \epsilon$.
  have h_eps : ∀ ε > 0, ∃ N, ∀ n ≥ N, |(q n : ℝ) * (y.num / y.den) - p n| < ε := by
    simpa using Metric.tendsto_atTop.mp htend;
  obtain ⟨ N, hN ⟩ := h_eps ( 1 / ( y.den : ℝ ) ) ( by positivity ) ; use N; specialize hN N le_rfl; simp_all +decide [ div_eq_mul_inv ] ;
  field_simp at hN ⊢;
  rw [ abs_div, abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ y.den ) ] at hN ; rw [ mul_div_cancel₀ _ ( by norm_cast; exact Nat.cast_ne_zero.mpr y.pos.ne' ) ] at hN ; norm_cast at * ; aesop;

/-
**Diophantine engine (ε form, sufficient direction).**
-/
theorem irrational_of_forall_eps_linear_form
    (x : ℝ)
    (h : ∀ ε : ℝ, 0 < ε → ∃ (q : ℕ) (p : ℤ),
        1 ≤ q ∧ 0 < |(q : ℝ) * x - (p : ℝ)| ∧ |(q : ℝ) * x - (p : ℝ)| < ε) :
    Irrational x := by
  contrapose! h;
  obtain ⟨q, p, hq, hp⟩ : ∃ q : ℕ, ∃ p : ℤ, q > 0 ∧ x = p / q := by
    rcases Classical.not_not.1 h with ⟨ q, hq ⟩;
    exact ⟨ q.den, q.num, Nat.cast_pos.mpr q.pos, by simpa only [ Rat.cast_def ] using hq.symm ⟩;
  use 1 / q; simp_all +decide ;
  field_simp;
  intro a b ha hb; rw [ abs_div, abs_of_nonneg ( by positivity : ( 0 : ℝ ) ≤ q ) ] ; rw [ mul_div_cancel₀ _ ( by positivity ) ] ; norm_cast at *;
  exact abs_pos.mpr hb

/-
**Necessary direction** via Dirichlet's approximation theorem.
-/
theorem forall_eps_linear_form_of_irrational
    (x : ℝ) (hx : Irrational x) :
    ∀ ε : ℝ, 0 < ε → ∃ (q : ℕ) (p : ℤ),
        1 ≤ q ∧ 0 < |(q : ℝ) * x - (p : ℝ)| ∧ |(q : ℝ) * x - (p : ℝ)| < ε := by
  intro ε hε;
  obtain ⟨k, hk₁, hk₂⟩ : ∃ k : ℕ, 0 < k ∧ |(k : ℝ) * x - (round ((k : ℝ) * x) : ℤ)| < ε := by
    -- Choose $n$ such that $\frac{1}{n+1} < \epsilon$.
    obtain ⟨n, hn⟩ : ∃ n : ℕ, 0 < n ∧ 1 / (n + 1 : ℝ) < ε := by
      exact ⟨ ⌊ε⁻¹⌋₊ + 1, Nat.succ_pos _, by simpa using inv_lt_of_inv_lt₀ hε <| by linarith [ Nat.lt_floor_add_one <| ε⁻¹ ] ⟩;
    exact Exists.elim ( Real.exists_nat_abs_mul_sub_round_le x ( by linarith ) ) fun k hk => ⟨ k, hk.1, lt_of_le_of_lt hk.2.2 hn.2 ⟩;
  refine' ⟨ k, round ( k * x ), hk₁, _, _ ⟩ <;> simp_all +decide;
  exact sub_ne_zero_of_ne <| mod_cast hx.ratCast_mul ( Nat.cast_ne_zero.mpr hk₁.ne' ) |> fun h => h.ne_int _

/-- **Characterization of irrationality by small nonzero linear forms.** -/
theorem irrational_iff_forall_eps_linear_form (x : ℝ) :
    Irrational x ↔ ∀ ε : ℝ, 0 < ε → ∃ (q : ℕ) (p : ℤ),
        1 ≤ q ∧ 0 < |(q : ℝ) * x - (p : ℝ)| ∧ |(q : ℝ) * x - (p : ℝ)| < ε :=
  ⟨forall_eps_linear_form_of_irrational x, irrational_of_forall_eps_linear_form x⟩

/-! ## Part 2 : structural facts about `γ` -/

/-- `γ` is positive. -/
theorem eulerMascheroniConstant_pos : 0 < eulerMascheroniConstant :=
  lt_trans (by norm_num) one_half_lt_eulerMascheroniConstant

/-- `γ < 1`. -/
theorem eulerMascheroniConstant_lt_one : eulerMascheroniConstant < 1 :=
  lt_trans eulerMascheroniConstant_lt_two_thirds (by norm_num)

/-- The Mathlib sandwich `seq n < γ < seq' n`, combined. -/
theorem eulerMascheroniSeq_sandwich (n : ℕ) :
    eulerMascheroniSeq n < eulerMascheroniConstant ∧
      eulerMascheroniConstant < eulerMascheroniSeq' n :=
  ⟨eulerMascheroniSeq_lt_eulerMascheroniConstant n,
   eulerMascheroniConstant_lt_eulerMascheroniSeq' n⟩

/-
The trapping interval `[seq n, seq' n]` shrinks to a point: its width tends
to `0`.  (Both endpoints converge to `γ`.)
-/
theorem tendsto_eulerMascheroni_trap_width :
    Tendsto (fun n : ℕ => eulerMascheroniSeq' n - eulerMascheroniSeq n) atTop (𝓝 0) := by
  convert Filter.Tendsto.sub ( Real.tendsto_eulerMascheroniSeq' ) ( Real.tendsto_eulerMascheroniSeq ) using 2 ; ring!

/-- **Specialization of the engine to `γ`.**  The Euler–Mascheroni constant is
irrational iff arbitrarily small nonzero integer linear forms `q·γ − p` exist.
This makes explicit the Diophantine statement an irrationality proof must
establish. -/
theorem irrational_eulerMascheroniConstant_iff :
    Irrational eulerMascheroniConstant ↔
      ∀ ε : ℝ, 0 < ε → ∃ (q : ℕ) (p : ℤ),
        1 ≤ q ∧ 0 < |(q : ℝ) * eulerMascheroniConstant - (p : ℝ)| ∧
          |(q : ℝ) * eulerMascheroniConstant - (p : ℝ)| < ε :=
  irrational_iff_forall_eps_linear_form _

end EulerMascheroni