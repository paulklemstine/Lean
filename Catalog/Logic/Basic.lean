/-
# Constructive Analysis: Bishop-Style Computable Reals — Core Definitions

This module develops a computational core of Bishop-style analysis inside Lean 4:
reals as executable approximation processes, continuity as a modulus-bearing structure,
and existence theorems that output certified approximants.
-/
import Mathlib

open Set

/-! ## ComputableReal: Bishop-Style Real Numbers -/

/-- A Bishop-style computable real number, represented by a rational approximation
sequence `seq` together with a Cauchy modulus `mod`. The coherence condition states
that for indices beyond `mod n`, successive approximants agree to within `1/2^n`. -/
structure ComputableReal where
  seq : ℕ → ℚ
  mod : ℕ → ℕ
  mono_mod : Monotone mod
  cauchy' : ∀ n i j, mod n ≤ i → mod n ≤ j → |seq i - seq j| ≤ (1 : ℚ) / 2 ^ n

namespace ComputableReal

/-- The canonical approximant at precision level `n`. -/
def approxAt (x : ComputableReal) (n : ℕ) : ℚ := x.seq (x.mod n)

/-- Coherence of canonical approximants: approximants at higher precision
levels are consistent with lower precision levels. -/
theorem approxAt_coherent (x : ComputableReal) (m n : ℕ) (hmn : m ≤ n) :
    |x.approxAt m - x.approxAt n| ≤ (1 : ℚ) / 2 ^ m := by
  unfold approxAt
  exact x.cauchy' m (x.mod m) (x.mod n) le_rfl (x.mono_mod hmn)

/-- Construct a computable real from a rational constant. -/
def ofRat (q : ℚ) : ComputableReal where
  seq := fun _ => q
  mod := fun _ => 0
  mono_mod := monotone_const
  cauchy' := by simp

/-- Construct the sum of two computable reals. -/
def add (x y : ComputableReal) : ComputableReal where
  seq := fun k => x.seq k + y.seq k
  mod := fun n => max (x.mod (n + 1)) (y.mod (n + 1))
  mono_mod := by
    intro a b hab
    exact max_le_max (x.mono_mod (by omega)) (y.mono_mod (by omega))
  cauchy' := by
    intro n i j hi hj
    have hxi : x.mod (n + 1) ≤ i := le_trans (le_max_left _ _) hi
    have hxj : x.mod (n + 1) ≤ j := le_trans (le_max_left _ _) hj
    have hyi : y.mod (n + 1) ≤ i := le_trans (le_max_right _ _) hi
    have hyj : y.mod (n + 1) ≤ j := le_trans (le_max_right _ _) hj
    have hx := x.cauchy' (n + 1) i j hxi hxj
    have hy := y.cauchy' (n + 1) i j hyi hyj
    calc |x.seq i + y.seq i - (x.seq j + y.seq j)|
        = |(x.seq i - x.seq j) + (y.seq i - y.seq j)| := by ring_nf
      _ ≤ |x.seq i - x.seq j| + |y.seq i - y.seq j| := abs_add_le _ _
      _ ≤ 1 / 2 ^ (n + 1) + 1 / 2 ^ (n + 1) := add_le_add hx hy
      _ = 1 / 2 ^ n := by rw [pow_succ]; ring

/-- Construct the negation of a computable real. -/
def neg (x : ComputableReal) : ComputableReal where
  seq := fun k => -x.seq k
  mod := x.mod
  mono_mod := x.mono_mod
  cauchy' := by
    intro n i j hi hj
    have := x.cauchy' n i j hi hj
    show |-(x.seq i) - (-(x.seq j))| ≤ _
    rw [show -(x.seq i) - (-(x.seq j)) = -(x.seq i - x.seq j) from by ring, abs_neg]
    exact this

/-- The real number value associated to a computable real, defined as the limit
of the rational Cauchy sequence using Mathlib's `limUnder`. -/
noncomputable def value (x : ComputableReal) : ℝ :=
  limUnder Filter.atTop (fun n => (x.seq n : ℝ))

/-
The sequence of a computable real converges to its value in ℝ.
-/
theorem tendsto_value (x : ComputableReal) :
    Filter.Tendsto (fun n => (x.seq n : ℝ)) Filter.atTop (nhds x.value) := by
  unfold value
  -- Show that the sequence is Cauchy.
  have h_cauchy : CauchySeq (fun n => (x.seq n : ℝ)) := by
    refine' Metric.cauchySeq_iff'.2 fun ε hε => _;
    -- Choose $N$ such that $1 / 2^N < \epsilon$.
    obtain ⟨N, hN⟩ : ∃ N : ℕ, (1 : ℝ) / 2 ^ N < ε := by
      simpa using exists_pow_lt_of_lt_one hε one_half_lt_one;
    -- By the properties of the Cauchy sequence, for any $n \geq \text{mod}(N)$, we have $|x.seq n - x.seq (\text{mod}(N))| \leq 1 / 2^N$.
    have h_cauchy_mod : ∀ n ≥ x.mod N, |(x.seq n : ℝ) - (x.seq (x.mod N) : ℝ)| ≤ 1 / 2 ^ N := by
      intro n hn; have := x.cauchy' N n ( x.mod N ) hn ( by linarith ) ; norm_cast at *;
      rw [ le_div_iff₀ ] at * <;> norm_cast at * <;> aesop;
    exact ⟨ x.mod N, fun n hn => lt_of_le_of_lt ( h_cauchy_mod n hn ) hN ⟩;
  exact h_cauchy.tendsto_limUnder

/-
The value of a rational constant computable real is the rational itself.
-/
theorem ofRat_value (q : ℚ) : (ofRat q).value = (q : ℝ) := by
  exact tendsto_nhds_unique ( tendsto_value _ ) ( tendsto_const_nhds )

/-
Addition of computable reals is compatible with their real values.
-/
theorem add_value (x y : ComputableReal) :
    (add x y).value = x.value + y.value := by
  convert tendsto_nhds_unique _ ( Filter.Tendsto.add ( ComputableReal.tendsto_value x ) ( ComputableReal.tendsto_value y ) );
  convert ComputableReal.tendsto_value ( ComputableReal.add x y ) using 1;
  exact funext fun n => by simp +decide [ ComputableReal.add ] ;

/-
Negation of computable reals is compatible with their real values.
-/
theorem neg_value (x : ComputableReal) :
    (neg x).value = -x.value := by
  convert tendsto_nhds_unique _ ( x.neg.tendsto_value ) using 1;
  · convert tendsto_nhds_unique ( Filter.Tendsto.neg ( x.tendsto_value ) ) _ using 1;
    convert x.neg.tendsto_value using 1;
    exact funext fun n => by simp +decide [ ComputableReal.neg ] ;
  · convert x.neg.tendsto_value using 1

end ComputableReal

/-! ## ModulusContinuousOn: Quantitative Uniform Continuity -/

/-- A structure expressing uniform continuity of `f` on `[a,b]` with an explicit
modulus `μ`. The modulus guarantees: if `|x - y| ≤ 1/2^(μ n)` for `x, y ∈ [a,b]`,
then `|f x - f y| ≤ 1/2^n`. -/
structure ModulusContinuousOn (f : ℝ → ℝ) (a b : ℝ) where
  μ : ℕ → ℕ
  mono_μ : Monotone μ
  spec :
    ∀ {x y : ℝ} {n : ℕ},
      x ∈ Icc a b →
      y ∈ Icc a b →
      |x - y| ≤ (1 : ℝ) / 2 ^ (μ n) →
      |f x - f y| ≤ (1 : ℝ) / 2 ^ n

/-
A modulus-continuous function is uniformly continuous in the classical sense.
-/
theorem ModulusContinuousOn.uniformContinuousOn {f : ℝ → ℝ} {a b : ℝ}
    (hcont : ModulusContinuousOn f a b) :
    ∀ ε > 0, ∃ δ > 0, ∀ x y : ℝ,
      x ∈ Icc a b → y ∈ Icc a b → |x - y| < δ → |f x - f y| < ε := by
  -- Let ε be any positive real number.
  intro ε hεpos
  -- By definition of uniform continuity, there exists a positive integer N such that for any n ≥ N, 1/2^n < ε.
  obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, (1 : ℝ) / 2 ^ n < ε := by
    simpa using ( tendsto_inv_atTop_zero.comp ( tendsto_pow_atTop_atTop_of_one_lt one_lt_two ) ) |> fun h => h.eventually ( gt_mem_nhds hεpos );
  -- We set δ = 1/2^(μ N).
  use 1 / 2 ^ (hcont.μ N);
  exact ⟨ by positivity, fun x y hx hy hxy => lt_of_le_of_lt ( hcont.spec hx hy hxy.le ) ( hN N le_rfl ) ⟩

/-! ## SignedBisectionState: Certified Root Isolation -/

/-- A certified state for constructive root isolation via bisection.
Maintains an interval `[l, r]` with a sign change: `f l ≤ 0 ≤ f r`. -/
structure SignedBisectionState (f : ℝ → ℝ) where
  l : ℝ
  r : ℝ
  hlr : l ≤ r
  sign_left : f l ≤ 0
  sign_right : 0 ≤ f r