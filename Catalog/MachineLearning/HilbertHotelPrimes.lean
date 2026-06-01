/-
# Hilbert's Hotel for Primes: Asymptotically Identity Permutations

This module develops the theory of "asymptotically identity" permutations of ℕ,
motivated by rearrangements of the prime sequence in Hilbert's Hotel.

## Main Definitions

* `AsympId σ` — a permutation σ of ℕ is asymptotically identity if σ(n)/n → 1
* `EventuallyFixed σ` — σ fixes all sufficiently large elements
* `AdjacentSwap` — the permutation swapping (2k, 2k+1) for each k

## Main Results

* `perm_tendsto_atTop` — any permutation of ℕ tends to ∞
* `asympId_of_eventuallyFixed` — eventually fixed permutations are asymptotically identity
* `asympId_comp` — asymptotically identity permutations are closed under composition
* `asympId_inv` — asymptotically identity permutations are closed under inverse
* `asympId_adjacentSwap` — the adjacent swap permutation is asymptotically identity

## Mathematical Context

By the Prime Number Theorem, the n-th prime p_n ~ n·ln(n). For a permutation σ,
p_{σ(n)}/p_n ~ σ(n)·ln(σ(n))/(n·ln(n)). This ratio → 1 iff σ(n)/n → 1
(since ln(σ(n))/ln(n) → 1 whenever σ(n)/n → 1). Thus, the asymptotically
identity permutations characterize exactly those rearrangements of the primes
that preserve asymptotic room assignments.
-/

import Mathlib

open Filter Topology

noncomputable section

/-! ## Core Definitions -/

/-- A permutation σ of ℕ is **asymptotically identity** if σ(n)/n → 1.
This captures the idea that σ doesn't move elements "too far" from their
original position in the limit. -/
def AsympId (σ : Equiv.Perm ℕ) : Prop :=
  Tendsto (fun n : ℕ => (σ n : ℝ) / (n : ℝ)) atTop (nhds 1)

/-- A permutation is **eventually fixed** if it agrees with the identity
outside a finite set. This is stronger than having finite support in the
Fintype sense and works naturally for ℕ. -/
def EventuallyFixed (σ : Equiv.Perm ℕ) : Prop :=
  ∃ N : ℕ, ∀ n ≥ N, σ n = n

/-- The **adjacent swap** permutation: swaps 2k ↔ 2k+1 for each k.
This is a natural example of an asymptotically identity permutation
that moves every single element. -/
def AdjacentSwap : Equiv.Perm ℕ where
  toFun n := if n % 2 = 0 then n + 1 else n - 1
  invFun n := if n % 2 = 0 then n + 1 else n - 1
  left_inv n := by simp only; split_ifs with h1 h2 h2 <;> omega
  right_inv n := by simp only; split_ifs with h1 h2 h2 <;> omega

/-! ## Fundamental Lemma: Permutations of ℕ Tend to Infinity -/

/-
Any bijection ℕ → ℕ sends n → ∞ as n → ∞. This is because a bijection
must eventually exceed any bound — it cannot map infinitely many values
below a finite threshold. This is the key enabling lemma for composition
closure of AsympId.
-/
theorem perm_tendsto_atTop (σ : Equiv.Perm ℕ) :
    Tendsto (fun n => (σ n : ℝ)) atTop atTop := by
  refine' tendsto_natCast_atTop_atTop.comp _;
  refine' Filter.tendsto_atTop_atTop.mpr fun n => _;
  -- Since $\sigma$ is a bijection, the set $\{a \in \mathbb{N} \mid \sigma(a) < n\}$ is finite.
  have h_finite : Set.Finite {a : ℕ | σ a < n} := by
    exact Set.Finite.preimage ( fun x => by aesop ) ( Set.finite_lt_nat n );
  exact ⟨ h_finite.bddAbove.some + 1, fun a ha => not_lt.1 fun contra => not_lt_of_ge ( h_finite.bddAbove.choose_spec contra ) ha ⟩

/-! ## Eventually Fixed Permutations are AsympId -/

/-
If σ fixes all elements ≥ N, then σ(n)/n → 1. For n ≥ N,
σ(n) = n, so σ(n)/n = 1 eventually.
-/
theorem asympId_of_eventuallyFixed {σ : Equiv.Perm ℕ}
    (h : EventuallyFixed σ) : AsympId σ := by
  obtain ⟨ N, hN ⟩ := h;
  exact tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ge_atTop N, Filter.eventually_gt_atTop 0 ] with n hn hn'; rw [ hN n hn, div_self <| Nat.cast_ne_zero.mpr hn'.ne' ] )

/-! ## Composition Closure -/

/-
The composition of two asymptotically identity permutations is again
asymptotically identity. The proof uses: σ(τ(n))/n = (σ(τ(n))/τ(n)) · (τ(n)/n),
and since τ(n) → ∞ (by `perm_tendsto_atTop`), the first factor → 1.
-/
theorem asympId_comp {σ τ : Equiv.Perm ℕ}
    (hσ : AsympId σ) (hτ : AsympId τ) : AsympId (σ * τ) := by
  -- We need to show that (σ * τ)(n)/n → 1, i.e., σ(τ(n))/n → 1. Write this as (σ(τ(n))/τ(n)) · (τ(n)/n).
  have h_comp : Filter.Tendsto (fun n => (σ (τ n) : ℝ) / (τ n : ℝ) * ((τ n : ℝ) / (n : ℝ))) Filter.atTop (nhds 1) := by
    convert Filter.Tendsto.mul ( hσ.comp ( show Filter.Tendsto ( fun n => τ n : ℕ → ℕ ) Filter.atTop Filter.atTop from _ ) ) hτ using 2;
    · norm_num;
    · convert perm_tendsto_atTop τ using 1;
      norm_num [ Filter.tendsto_atTop_atTop ];
      exact ⟨ fun h b => by rcases h ⌈b⌉₊ with ⟨ i, hi ⟩ ; exact ⟨ i, fun n hin => le_trans ( Nat.le_ceil _ ) ( mod_cast hi n hin ) ⟩, fun h b => by rcases h b with ⟨ i, hi ⟩ ; exact ⟨ i, fun n hin => mod_cast hi n hin ⟩ ⟩;
  refine h_comp.congr' ?_;
  filter_upwards [ hτ.eventually_ne one_ne_zero ] with n hn using by rw [ div_mul_div_cancel₀ ( by aesop ) ] ; rfl;

/-! ## Inverse Closure -/

/-
The inverse of an asymptotically identity permutation is asymptotically
identity. If σ(n)/n → 1, then σ⁻¹(n)/n → 1.
-/
theorem asympId_inv {σ : Equiv.Perm ℕ}
    (hσ : AsympId σ) : AsympId σ⁻¹ := by
  -- Let m = σ⁻¹(n). Then σ(m) = n, so σ(m)/m tends to 1 as m tends to infinity.
  have hm : Filter.Tendsto (fun m => (σ m : ℝ) / (m : ℝ)) Filter.atTop (nhds 1) := by
    exact hσ;
  -- Since σ is a permutation, σ⁻¹(n) tends to infinity as n tends to infinity.
  have h_inv_tendsto : Filter.Tendsto (fun n => (σ⁻¹ n : ℕ)) Filter.atTop Filter.atTop := by
    convert perm_tendsto_atTop σ⁻¹;
    norm_num [ Filter.tendsto_atTop_atTop ];
    exact ⟨ fun h b => by rcases h ⌈b⌉₊ with ⟨ i, hi ⟩ ; exact ⟨ i, fun n hin => le_trans ( Nat.le_ceil _ ) ( mod_cast hi n hin ) ⟩, fun h b => by rcases h b with ⟨ i, hi ⟩ ; exact ⟨ i, fun n hin => mod_cast hi n hin ⟩ ⟩;
  convert Filter.Tendsto.inv₀ ( hm.comp h_inv_tendsto ) _ using 2 <;> norm_num;
  unfold AsympId; aesop;

/-! ## The Identity is Asymptotically Identity -/

/-
The identity permutation is trivially asymptotically identity.
-/
theorem asympId_id : AsympId (1 : Equiv.Perm ℕ) := by
  refine' tendsto_atTop_of_eventually_const _;
  exacts [ 1, fun i hi => by simp +decide [ show i ≠ 0 by linarith ] ]

/-! ## The Adjacent Swap is Asymptotically Identity -/

/-
The adjacent swap permutation is asymptotically identity.
For even n: σ(n) = n+1, so σ(n)/n = 1 + 1/n → 1.
For odd n: σ(n) = n-1, so σ(n)/n = 1 - 1/n → 1.
In both cases, |σ(n)/n - 1| ≤ 1/n → 0.
-/
theorem asympId_adjacentSwap : AsympId AdjacentSwap := by
  refine' ( Metric.tendsto_atTop.mpr _ );
  intro ε hε; use ⌈ε⁻¹⌉₊ + 1; intro n hn; rw [ dist_eq_norm ] ; rcases Nat.even_or_odd' n with ⟨ k, rfl | rfl ⟩ <;> norm_num [ AdjacentSwap ] at *;
  · rw [ abs_of_nonneg ] <;> ring_nf <;> nlinarith [ Nat.le_ceil ( ε⁻¹ ), mul_inv_cancel₀ ( ne_of_gt hε ), ( by norm_cast : ( ⌈ε⁻¹⌉₊ : ℝ ) + 1 ≤ 2 * k ), mul_inv_cancel₀ ( show ( k : ℝ ) ≠ 0 by norm_cast; linarith ) ];
  · rw [ abs_lt ] ; constructor <;> nlinarith [ mul_inv_cancel₀ hε.ne', mul_div_cancel₀ ( 2 * ( k : ℝ ) ) ( by linarith : ( 2 * ( k : ℝ ) + 1 ) ≠ 0 ) ]

/-! ## Bounded Displacement implies AsympId -/

/-
A permutation that only moves elements by at most k positions is AsympId.
If |σ(n) - n| ≤ k for all n, then σ(n)/n = 1 + O(1/n) → 1.
-/
theorem asympId_of_bounded_displacement {σ : Equiv.Perm ℕ} {k : ℕ}
    (hk : ∀ n : ℕ, (σ n : ℤ) - (n : ℤ) ∈ Set.Icc (-(k : ℤ)) (k : ℤ)) :
    AsympId σ := by
  refine' ( Metric.tendsto_atTop.mpr _ );
  intro ε hε; use ⌈ε⁻¹ * ( k + 1 ) ⌉₊ + 1; intro n hn; rw [ dist_eq_norm ] ; norm_num [ abs_div ];
  rw [ abs_lt ] ; constructor <;> nlinarith [ Nat.le_ceil ( ε⁻¹ * ( k + 1 ) ), mul_inv_cancel₀ ( ne_of_gt hε ), show ( n : ℝ ) ≥ ⌈ε⁻¹ * ( k + 1 ) ⌉₊ + 1 by exact_mod_cast hn, show ( σ n : ℝ ) - n ≥ -k by exact_mod_cast hk n |>.1, show ( σ n : ℝ ) - n ≤ k by exact_mod_cast hk n |>.2, mul_div_cancel₀ ( ( σ n : ℝ ) : ℝ ) ( show ( n : ℝ ) ≠ 0 by norm_cast; linarith ) ] ;

/-! ## Subgroup Structure -/

/-- The set of asymptotically identity permutations satisfies the subgroup
axioms: contains 1, closed under multiplication, closed under inverse. -/
theorem asympId_subgroup_properties :
    AsympId (1 : Equiv.Perm ℕ) ∧
    (∀ σ τ : Equiv.Perm ℕ, AsympId σ → AsympId τ → AsympId (σ * τ)) ∧
    (∀ σ : Equiv.Perm ℕ, AsympId σ → AsympId σ⁻¹) :=
  ⟨asympId_id, fun _ _ hσ hτ => asympId_comp hσ hτ,
   fun _ hσ => asympId_inv hσ⟩

/-! ## Connection to Primes: Log Ratio Lemma -/

/-
If σ(n)/n → 1, then log(σ(n))/log(n) → 1.
This is the key bridge: since p_n ~ n·log(n) by PNT,
p_{σ(n)}/p_n ~ (σ(n)/n) · (log(σ(n))/log(n)) → 1·1 = 1.
-/
theorem log_ratio_tendsto_one {σ : Equiv.Perm ℕ}
    (hσ : AsympId σ) :
    Tendsto (fun n : ℕ => Real.log (σ n : ℝ) / Real.log (n : ℝ)) atTop (nhds 1) := by
  -- Write log(σ(n))/log(n) = log(n · (σ(n)/n))/log(n) = (log(n) + log(σ(n)/n))/log(n) = 1 + log(σ(n)/n)/log(n).
  suffices h_suff : Tendsto (fun n => 1 + Real.log (σ n / n) / Real.log n) atTop (nhds 1) by
    refine h_suff.congr' ?_;
    filter_upwards [ Filter.eventually_gt_atTop 1, hσ.eventually ( lt_mem_nhds one_pos ) ] with n hn hn';
    rw [ Real.log_div ] <;> first | positivity | ring;
    · rw [ mul_inv_cancel₀ ( ne_of_gt ( Real.log_pos ( Nat.one_lt_cast.mpr hn ) ) ) ] ; ring;
    · aesop;
  simpa using tendsto_const_nhds.add ( Filter.Tendsto.div_atTop ( Filter.Tendsto.log hσ one_ne_zero ) ( Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop ) )

end