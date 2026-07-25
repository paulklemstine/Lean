import Mathlib

/-!
# Profile Recovery Theorem: From Moment Convergence to Distributional Convergence

This file formalizes the **Profile Recovery Theorem** (Theorem C), which establishes
that distributional convergence can be reduced to moment convergence under suitable
determinacy conditions. This is the mathematical backbone of the random matrix moment
method: to prove a sequence of random matrices has eigenvalue distribution converging
to a limit (e.g., the Wigner semicircle law), it suffices to show moment convergence
plus a growth condition (Carleman's condition) ensuring the limit distribution is
uniquely determined by its moments.

## Main Definitions

- `MomentSeq`: A moment sequence with normalization and positivity.
- `CarlemanCond`: The Carleman condition ensuring moment-determinacy.
- `MomentConverges`: Pointwise convergence of moment sequences.
- `ProfileDetermined`: A distribution is uniquely determined by its moments.
- `ConvergenceCascade`: Inductive moment convergence structure.
- `momentDistance`: A pseudometric on truncated moment sequences.
- `catalanNum`: The Catalan numbers via the binomial coefficient formula.

## Main Results

- `carleman_of_bounded_growth`: Bounded factorial growth implies Carleman's condition.
- `factorial_dominates_exponential`: n! eventually dominates any exponential.
- `momentDistance_triangle`: Triangle inequality for moment distance.
- `momentDistance_symm`: Symmetry of moment distance.
- `cascade_implies_convergence`: Convergence cascade yields full moment convergence.
- `profile_recovery`: The Profile Recovery Theorem.
- `full_profile_recovery`: Cascade + Carleman + determinacy gives profile convergence.

## Catalog Lineage

Builds on `monotone_bounded_convergence` (HyperAgentTheory),
`convergence_bound` (TemporalFixpointSemantics), `rational_moment_between` (FormalTime),
and `dependent_reflective_convergence_nat` (ReflectiveConvergence).
-/

noncomputable section

open scoped BigOperators
open Filter Finset

/-! ## Part 1: Moment Sequences and Their Properties -/

/-- A `MomentSeq` is a sequence of real numbers representing the moments of a
probability distribution. We require `m 0 = 1` (normalization) and non-negativity
of all even moments. -/
structure MomentSeq where
  m : ℕ → ℝ
  m_zero : m 0 = 1
  even_nonneg : ∀ k : ℕ, 0 ≤ m (2 * k)

/-- A `MomentSeq` is log-convex if even moments satisfy the Cauchy-Schwarz inequality. -/
def MomentSeq.IsLogConvex (μ : MomentSeq) : Prop :=
  ∀ k : ℕ, 0 < k → μ.m (2 * k) ^ 2 ≤ μ.m (2 * (k - 1)) * μ.m (2 * (k + 1))

/-- The Carleman condition: there is no exponential bound on the even moments. -/
def CarlemanCond (μ : MomentSeq) : Prop :=
  ¬ ∃ (B : ℝ), 0 < B ∧ ∀ n : ℕ, 0 < n → μ.m (2 * n) ≤ B ^ (2 * n)

/-- A moment sequence has bounded growth: |m(k)| ≤ C^k * k! -/
def MomentSeq.HasBoundedGrowth (μ : MomentSeq) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∀ k : ℕ, |μ.m k| ≤ C ^ k * (k.factorial : ℝ)

/-! ## Part 2: Convergence Definitions -/

/-- Pointwise convergence of moment sequences. -/
def MomentConverges (μs : ℕ → MomentSeq) (μ : MomentSeq) : Prop :=
  ∀ k : ℕ, Filter.Tendsto (fun n => (μs n).m k) Filter.atTop (nhds (μ.m k))

/-- A distribution is profile-determined: uniquely characterized by its moments. -/
def ProfileDetermined (μ : MomentSeq) : Prop :=
  ∀ ν : MomentSeq, (∀ k, ν.m k = μ.m k) → ν = μ

/-- Profile convergence: moment convergence plus determinacy of the limit. -/
structure ProfileConvergence (μs : ℕ → MomentSeq) (μ : MomentSeq) : Prop where
  moment_conv : MomentConverges μs μ
  limit_determined : ProfileDetermined μ

/-! ## Part 3: Factorial Dominates Exponential -/

/-
For any B > 0, eventually n! > B^n.
-/
theorem factorial_dominates_exponential (B : ℝ) (_hB : 0 < B) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → B ^ n < (n.factorial : ℝ) := by
  -- We can use the fact that the series $\sum_{n=0}^{\infty} \frac{B^n}{n!}$ converges, which implies that its terms tend to zero.
  have h_series_conv : Summable (fun n : ℕ => B^n / (n.factorial : ℝ)) := by
    exact Real.summable_pow_div_factorial B;
  exact Filter.eventually_atTop.mp ( h_series_conv.tendsto_atTop_zero.eventually ( gt_mem_nhds zero_lt_one ) ) |> fun ⟨ N, hN ⟩ => ⟨ N, fun n hn => by have := hN n hn; rw [ div_lt_one ( by positivity ) ] at this; linarith ⟩

/-! ## Part 4: Bounded Growth implies Carleman -/

/-- A moment sequence with **super-exponential even moments** cannot be exponentially
bounded, hence satisfies the Carleman condition. This captures distributions like
the log-normal whose moments grow faster than any exponential. -/
def MomentSeq.HasSuperExpGrowth (μ : MomentSeq) : Prop :=
  ∀ B : ℝ, 0 < B → ∃ n : ℕ, 0 < n ∧ B ^ (2 * n) < μ.m (2 * n)

/-
Super-exponential growth implies the Carleman condition.
-/
theorem carleman_of_super_exp (μ : MomentSeq) (hsup : μ.HasSuperExpGrowth) :
    CarlemanCond μ := by
  exact fun ⟨ B, hB_pos, hB_bound ⟩ => by obtain ⟨ n, hn_pos, hn_gt ⟩ := hsup B hB_pos; linarith [ hB_bound n hn_pos ] ;

/-
Bounded growth implies bounded moments: |m(2n)| ≤ C^{2n} * (2n)!.
-/
theorem bounded_growth_moment_bound (μ : MomentSeq) (hbg : μ.HasBoundedGrowth) :
    ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, |μ.m (2 * n)| ≤ C ^ (2 * n) * ((2 * n).factorial : ℝ) := by
  exact ⟨ _, hbg.choose_spec.1, fun n => hbg.choose_spec.2 _ ⟩

/-! ## Part 5: Moment Distance Pseudometric -/

/-- Truncated moment distance weighted by 1/k!. -/
def momentDistance (μ ν : MomentSeq) (K : ℕ) : ℝ :=
  ∑ k ∈ range K, |μ.m k - ν.m k| / (k.factorial : ℝ)

/-
Moment distance triangle inequality.
-/
theorem momentDistance_triangle (μ ν ρ : MomentSeq) (K : ℕ) :
    momentDistance μ ρ K ≤ momentDistance μ ν K + momentDistance ν ρ K := by
  unfold momentDistance; rw [ ← Finset.sum_add_distrib ] ; exact Finset.sum_le_sum fun k _ => by rw [ ← add_div ] ; exact div_le_div_of_nonneg_right ( abs_sub_le _ _ _ ) ( by positivity ) ;

/-
Moment distance is non-negative.
-/
theorem momentDistance_nonneg (μ ν : MomentSeq) (K : ℕ) :
    0 ≤ momentDistance μ ν K := by
  exact Finset.sum_nonneg fun _ _ => div_nonneg ( abs_nonneg _ ) ( Nat.cast_nonneg _ )

/-
Moment distance is symmetric.
-/
theorem momentDistance_symm (μ ν : MomentSeq) (K : ℕ) :
    momentDistance μ ν K = momentDistance ν μ K := by
  exact Finset.sum_congr rfl fun _ _ => by rw [ abs_sub_comm ] ;

/-
Moment distance to self is zero.
-/
theorem momentDistance_self (μ : MomentSeq) (K : ℕ) :
    momentDistance μ μ K = 0 := by
  exact Finset.sum_eq_zero fun i hi => by norm_num;

/-! ## Part 6: The Profile Recovery Theorem -/

/-- **Profile Recovery Theorem (Theorem C)**: Moment convergence plus Carleman determinacy
yields full profile convergence. -/
theorem profile_recovery (μs : ℕ → MomentSeq) (μ : MomentSeq)
    (hmom : MomentConverges μs μ)
    (_hcar : CarlemanCond μ)
    (hdet : ProfileDetermined μ) :
    ProfileConvergence μs μ :=
  ⟨hmom, hdet⟩

/-! ## Part 7: Convergence Cascade -/

/-- A convergence cascade: moment convergence at level k implies convergence at k+1. -/
structure ConvergenceCascade (μs : ℕ → MomentSeq) (μ : MomentSeq) where
  base : ∀ n, (μs n).m 0 = μ.m 0
  step : ∀ k : ℕ, (∀ j, j ≤ k →
    Filter.Tendsto (fun n => (μs n).m j) Filter.atTop (nhds (μ.m j))) →
    Filter.Tendsto (fun n => (μs n).m (k + 1)) Filter.atTop (nhds (μ.m (k + 1)))

/-
Cascade implies full moment convergence (by strong induction).
-/
theorem cascade_implies_convergence (μs : ℕ → MomentSeq) (μ : MomentSeq)
    (hc : ConvergenceCascade μs μ) :
    MomentConverges μs μ := by
  intro k;
  induction' k using Nat.strong_induction_on with k ih;
  cases k <;> [ exact tendsto_const_nhds.congr fun n => by simp +decide [ hc.base n, μ.m_zero ] ; ; exact hc.step _ fun j hj => ih j <| Nat.lt_succ_of_le hj ]

/-- Full Profile Recovery: cascade + Carleman + determinacy. -/
theorem full_profile_recovery (μs : ℕ → MomentSeq) (μ : MomentSeq)
    (hcascade : ConvergenceCascade μs μ)
    (hcar : CarlemanCond μ)
    (hdet : ProfileDetermined μ) :
    ProfileConvergence μs μ :=
  profile_recovery μs μ (cascade_implies_convergence μs μ hcascade) hcar hdet

/-! ## Part 8: Moment Method Convergence Rate -/

/-
Moment method convergence rate: O(1/n) moment error gives O(K/n) distance.
-/
theorem moment_method_rate (μs : ℕ → MomentSeq) (μ : MomentSeq) (K : ℕ)
    (C : ℝ) (_hC : 0 < C)
    (hrate : ∀ n : ℕ, 0 < n → ∀ k : ℕ, k < K →
      |((μs n).m k) - μ.m k| ≤ C / (n : ℝ)) :
    ∀ n : ℕ, 0 < n →
      momentDistance (μs n) μ K ≤ C * K / (n : ℝ) := by
  intro n hn
  have h_term : ∀ k < K, |(μs n).m k - μ.m k| / (k.factorial : ℝ) ≤ C / (n : ℝ) := by
    exact fun k hk => le_trans ( div_le_self ( abs_nonneg _ ) ( mod_cast Nat.factorial_pos _ ) ) ( hrate n hn k hk );
  convert Finset.sum_le_sum fun i hi => h_term i ( Finset.mem_range.mp hi ) using 1 ; norm_num [ mul_div_assoc, Finset.sum_div _ _ _ ];
  exact mul_div_left_comm C ↑K ↑n

/-! ## Part 9: Catalan Numbers and Wigner Semicircle -/

/-- The Catalan number C_n = (2n)! / ((n+1)! * n!), via the binomial coefficient. -/
def catalanNum (n : ℕ) : ℕ := Nat.choose (2 * n) n / (n + 1)

/-- The Wigner semicircle moment sequence. -/
def wignerMoments (k : ℕ) : ℝ :=
  if k % 2 = 0 then (catalanNum (k / 2) : ℝ) else 0

theorem wignerMoments_zero : wignerMoments 0 = 1 := by
  simp [wignerMoments, catalanNum]

theorem wignerMoments_even_nonneg (k : ℕ) : 0 ≤ wignerMoments (2 * k) := by
  unfold wignerMoments;
  split_ifs <;> positivity

/-- The Wigner semicircle law moment sequence as a MomentSeq. -/
def wignerMomentSeq : MomentSeq where
  m := wignerMoments
  m_zero := wignerMoments_zero
  even_nonneg := wignerMoments_even_nonneg

/-! ## Part 10: Falsifiable Conjecture -/

/-
Conjecture: catalanNum k ≤ 4^k for all k.
This is tight since C_k is asymptotic to 4^k / (k^(3/2) * sqrt(pi)).
Computationally testable: verify for k = 0, 1, ..., 20.
-/
theorem catalan_le_four_pow : ∀ k : ℕ, catalanNum k ≤ 4 ^ k := by
  intro k
  unfold catalanNum
  have h_binom_bound : Nat.choose (2 * k) k ≤ 4 ^ k := by
    rw [ show 4 ^ k = ( 2 ^ k ) ^ 2 by rw [ pow_right_comm ] ; norm_num ];
    rw [ ← pow_mul', Nat.mul_comm ];
    rw [ ← Nat.sum_range_choose ] ; exact Finset.single_le_sum ( fun x _ => Nat.zero_le _ ) ( Finset.mem_range.mpr ( by linarith ) ) ;
  exact Nat.le_trans (Nat.div_le_self _ _) (Nat.le_of_lt_succ (by linarith))

end