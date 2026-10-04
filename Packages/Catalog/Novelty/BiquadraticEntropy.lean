/-
# The biquadratic type channel: exact entropies and the swap-symmetry law

Companion to `Novelty.BiquadraticTypeChannel`.  There we proved that for every prime
`p ≥ 5` the splitting type of `x⁴ - 10x² + 1` is `classType (p mod 24)`, i.e. `4`
(complete splitting) on the two classes `±1 (mod 24)` and `0` (type `(2,2)`) on the
other six classes of `(ℤ/24)ˣ`.  Here we evaluate the channel *exactly* at the level
of residue classes (the Chebotarev limit) and explain the reported numbers.

* `prime_mod24_mem` — every prime `p ≥ 5` lands in one of the 8 unit classes.
* `classEntropy_eq` — `H(T) = 2 - (3/4)·log₂ 3 = h(1/4)` exactly; and
  `classEntropy_bounds`: `0.8109 < H(T) < 0.8114`.  The reported finite-sample value
  `0.8074` lies strictly below the limit (`empirical_below_limit`).
* `pair_mutInfo_eq` — for a semiprime `N = pq` the residue `N mod 24` carries
  exactly `19/8 - (21/16)·log₂ 3 ≈ 0.2947` bits about the type pair `(T p, T q)`
  (reported finite-sample value: `0.2909`).
* `mutInfo_eq_zero_of_flip` — a general law: if an involution preserves the side
  channel and flips a Boolean read-out, the read-out carries **zero** information.
* `which_factor_zero` — consequently `N mod 24` carries *exactly* `0` bits about
  *which* factor of a mixed semiprime splits (reported: `0.0001`).
-/
import Novelty.BiquadraticTypeChannel

namespace BiquadraticTypeChannel

open Finset CyclicTypeChannel

/-! ## 1. The eight unit classes mod 24 -/

/-- The unit classes of `ℤ/24`. -/
def U24 : Finset ℕ := {1, 5, 7, 11, 13, 17, 19, 23}

/-- Every prime `p ≥ 5` reduces to a unit class mod 24. -/
theorem prime_mod24_mem {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) (hp3 : p ≠ 3) : p % 24 ∈ U24 := by
  have h2 : p % 2 ≠ 0 := fun h =>
    hp2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).1 (Nat.dvd_of_mod_eq_zero h)).symm
  have h3 : p % 3 ≠ 0 := fun h =>
    hp3 ((Nat.prime_dvd_prime_iff_eq Nat.prime_three hp).1 (Nat.dvd_of_mod_eq_zero h)).symm
  simp only [U24, mem_insert, mem_singleton]
  omega

/-! ## 2. The exact type entropy -/

/-- **Exact class-level type entropy.**  Two types with weights `1/4, 3/4`:
`H(T) = 2 - (3/4)·log₂ 3`. -/
theorem classEntropy_eq : uEnt U24 classType = 2 - 3 / 4 * Real.logb 2 3 := by
  rw [uEnt_eq_countSum U24 classType {2, 6} (by decide), show U24.card = 8 from rfl]
  norm_num [lb_8, lb_6, Real.logb_self_eq_one]
  ring

/-- `84/53 < log₂ 3` (from `2⁸⁴ < 3⁵³`). -/
theorem logb_two_three_gt : (84 / 53 : ℝ) < Real.logb 2 3 := by
  rw [Real.lt_logb_iff_rpow_lt (by norm_num) (by norm_num)]
  have h : ((2 : ℝ) ^ (84 / 53 : ℝ)) ^ (53 : ℕ) < (3 : ℝ) ^ (53 : ℕ) := by
    rw [← Real.rpow_natCast, ← Real.rpow_mul (by norm_num)]
    norm_num
  exact lt_of_pow_lt_pow_left₀ 53 (by norm_num) h

set_option exponentiation.threshold 600 in
/-- `log₂ 3 < 485/306` (from `3³⁰⁶ < 2⁴⁸⁵`). -/
theorem logb_two_three_lt : Real.logb 2 3 < 485 / 306 := by
  rw [Real.logb_lt_iff_lt_rpow (by norm_num) (by norm_num)]
  have h : (3 : ℝ) ^ (306 : ℕ) < ((2 : ℝ) ^ (485 / 306 : ℝ)) ^ (306 : ℕ) := by
    rw [← Real.rpow_natCast ((2 : ℝ) ^ (485 / 306 : ℝ)) 306, ← Real.rpow_mul (by norm_num)]
    norm_num
  exact lt_of_pow_lt_pow_left₀ 306 (by positivity) h

/-- **Numerical window.**  `0.8109 < H(T) < 0.8114`. -/
theorem classEntropy_bounds : (0.8109 : ℝ) < uEnt U24 classType ∧ uEnt U24 classType < 0.8114 := by
  rw [classEntropy_eq]
  have h1 := logb_two_three_gt
  have h2 := logb_two_three_lt
  constructor <;> nlinarith

/-- The reported finite-sample entropy `0.8074` lies strictly *below* the Chebotarev
limit: the sample under-represents the split classes `±1 (mod 24)`. -/
theorem empirical_below_limit : (0.8074 : ℝ) < uEnt U24 classType :=
  lt_trans (by norm_num) classEntropy_bounds.1

/-- **Pinning at the class level.**  `I(T ; class) = H(T)` on the eight classes. -/
theorem class_full_pinning : mutInfo U24 classType id = uEnt U24 classType :=
  S3SignChannelUniversal.mutInfo_eq_uEnt_of_factor _ _ _ fun _ _ _ _ h => by
    simp only [id] at h; rw [h]

/-! ## 3. The semiprime pair channel -/

/-- Ordered pairs of unit classes `(p mod 24, q mod 24)`. -/
def U24sq : Finset (ℕ × ℕ) := U24 ×ˢ U24

/-- The type pair `(T p, T q)`. -/
def pairType (x : ℕ × ℕ) : ℕ × ℕ := (classType x.1, classType x.2)

/-- The semiprime residue `N = pq mod 24`. -/
def prodClass (x : ℕ × ℕ) : ℕ := x.1 * x.2 % 24

/-- Entropy of the type pair: `2·h(1/4)`. -/
theorem pair_uEnt_eq : uEnt U24sq pairType = 4 - 3 / 2 * Real.logb 2 3 := by
  rw [uEnt_eq_countSum U24sq pairType {4, 12, 12, 36} (by decide),
    show U24sq.card = 64 from rfl]
  norm_num [lb_4, lb_12, lb_36, lb_64]
  ring

/-- Each residue `N mod 24` is hit by exactly `8` ordered class pairs. -/
lemma prodClass_fiber_card (c : ℕ) (hc : c ∈ U24) : #{x ∈ U24sq | prodClass x = c} = 8 := by
  simp only [U24, mem_insert, mem_singleton] at hc
  rcases hc with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl <;> decide

/-- The conditional entropy of the type pair on one residue fibre. -/
lemma pair_fiber_uEnt (c : ℕ) (hc : c ∈ U24) :
    uEnt {x ∈ U24sq | prodClass x = c} pairType =
      if c = 1 ∨ c = 23 then 2 - 3 / 4 * Real.logb 2 3 else 3 / 2 := by
  simp only [U24, mem_insert, mem_singleton] at hc
  rcases hc with rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
  all_goals first
    | (rw [uEnt_eq_countSum _ pairType {2, 6} (by decide), prodClass_fiber_card _ (by decide)]
       norm_num [lb_8, lb_6, Real.logb_self_eq_one]; ring)
    | (rw [uEnt_eq_countSum _ pairType {2, 2, 4} (by decide), prodClass_fiber_card _ (by decide)]
       norm_num [lb_8, lb_4, Real.logb_self_eq_one])

/-- **The semiprime pair channel, exactly.**  `I((T p, T q) ; pq mod 24) =
19/8 - (21/16)·log₂ 3 ≈ 0.2947` bits. -/
theorem pair_mutInfo_eq :
    mutInfo U24sq pairType prodClass = 19 / 8 - 21 / 16 * Real.logb 2 3 := by
  have himg : U24sq.image prodClass = U24 := by decide
  have hcond : condEnt U24sq pairType prodClass = 9 / 8 + 1 / 4 * (2 - 3 / 4 * Real.logb 2 3) := by
    rw [condEnt, himg, Finset.sum_congr rfl fun c hc => by
      rw [prodClass_fiber_card c hc, pair_fiber_uEnt c hc, show U24sq.card = 64 from rfl]]
    simp only [U24]
    norm_num
    ring
  rw [mutInfo, pair_uEnt_eq, hcond]
  ring

/-- Numerical window for the pair channel: `0.2943 < I < 0.2951`. -/
theorem pair_mutInfo_bounds :
    (0.2943 : ℝ) < mutInfo U24sq pairType prodClass ∧
      mutInfo U24sq pairType prodClass < 0.2951 := by
  rw [pair_mutInfo_eq]
  have h1 := logb_two_three_gt
  have h2 := logb_two_three_lt
  constructor <;> nlinarith

/-! ## 4. Swap symmetry kills the which-factor information -/

section Flip

variable {α γ : Type*} [DecidableEq γ]

/-- An involution of `t` flipping a Boolean read-out balances the two read-out fibres. -/
lemma card_flip_eq {t : Finset α} (g : α → Bool) (σ : α → α) (hσt : ∀ x ∈ t, σ x ∈ t)
    (hσσ : ∀ x ∈ t, σ (σ x) = x) (hflip : ∀ x ∈ t, g (σ x) = !g x) (b : Bool) :
    #{x ∈ t | g x = b} = #{x ∈ t | g x = !b} := by
  refine card_nbij' σ σ ?_ ?_ ?_ ?_
  · intro x hx
    simp only [coe_filter, Set.mem_setOf_eq] at hx ⊢
    exact ⟨hσt x hx.1, by rw [hflip x hx.1, hx.2]⟩
  · intro x hx
    simp only [coe_filter, Set.mem_setOf_eq] at hx ⊢
    refine ⟨hσt x hx.1, ?_⟩
    rw [hflip x hx.1, hx.2, Bool.not_not]
  · intro x hx
    simp only [coe_filter, Set.mem_setOf_eq] at hx
    exact hσσ x hx.1
  · intro x hx
    simp only [coe_filter, Set.mem_setOf_eq] at hx
    exact hσσ x hx.1

/-- A balanced Boolean read-out on a nonempty set carries exactly one bit. -/
lemma uEnt_flip_eq_one {t : Finset α} (ht : t.Nonempty) (g : α → Bool) (σ : α → α)
    (hσt : ∀ x ∈ t, σ x ∈ t) (hσσ : ∀ x ∈ t, σ (σ x) = x)
    (hflip : ∀ x ∈ t, g (σ x) = !g x) : uEnt t g = 1 := by
  have hhalf : ∀ b, 2 * #{x ∈ t | g x = b} = t.card := by
    intro b
    have hsplit := card_filter_add_card_filter_not (s := t) (fun x => g x = b)
    have hneg : t.filter (fun x => ¬ g x = b) = t.filter (fun x => g x = !b) := by
      ext x; cases g x <;> cases b <;> simp
    rw [hneg, ← card_flip_eq g σ hσt hσσ hflip b] at hsplit
    omega
  have hc : ∀ a ∈ t, #{x ∈ t | g x = g a} = t.card / 2 := fun a _ => by
    have := hhalf (g a); omega
  rw [S3SignChannelUniversal.uEnt_const_fiber t g (t.card / 2) hc ht]
  have hpos : 0 < t.card / 2 := by
    obtain ⟨a, ha⟩ := ht
    have h1 := hhalf (g a)
    have h2 : 0 < #{x ∈ t | g x = g a} := fiber_card_pos ha
    omega
  have hcast : (t.card : ℝ) = 2 * ((t.card / 2 : ℕ) : ℝ) := by
    have := hhalf true
    have h' : t.card = 2 * (t.card / 2) := by omega
    exact_mod_cast h'
  rw [hcast, Real.logb_mul (by norm_num) (by exact_mod_cast hpos.ne'), Real.logb_self_eq_one
    (by norm_num)]
  ring

/-- **Swap-symmetry law.**  If an involution `σ` of `s` preserves the side channel `k`
and flips the Boolean read-out `g`, then `I(g ; k) = 0`: the side channel is blind to
`g`. -/
theorem mutInfo_eq_zero_of_flip (s : Finset α) (g : α → Bool) (k : α → γ) (σ : α → α)
    (hσs : ∀ x ∈ s, σ x ∈ s) (hσσ : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, g (σ x) = !g x) (hk : ∀ x ∈ s, k (σ x) = k x) : mutInfo s g k = 0 := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [mutInfo, uEnt, condEnt]
  have hN : (s.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.2 hs).ne'
  have hfib : ∀ c ∈ s.image k, uEnt {x ∈ s | k x = c} g = 1 := by
    intro c hc
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
    refine uEnt_flip_eq_one ⟨a, by simp [ha]⟩ g σ ?_ ?_ ?_
    · intro x hx
      simp only [mem_filter] at hx ⊢
      exact ⟨hσs x hx.1, by rw [hk x hx.1, hx.2]⟩
    · intro x hx; exact hσσ x (mem_filter.1 hx).1
    · intro x hx; exact hflip x (mem_filter.1 hx).1
  have hcond : condEnt s g k = 1 := by
    rw [condEnt, Finset.sum_congr rfl fun c hc => by rw [hfib c hc, mul_one],
      ← Finset.sum_div]
    have := card_eq_sum_card_image k s
    rw [div_eq_one_iff_eq hN]
    exact_mod_cast this.symm
  rw [mutInfo, uEnt_flip_eq_one hs g σ hσs hσσ hflip, hcond, sub_self]

end Flip

/-- Mixed semiprimes: exactly one of the two prime factors splits completely. -/
def mixedPairs : Finset (ℕ × ℕ) := U24sq.filter fun x => (classType x.1 = 4) ≠ (classType x.2 = 4)

/-- "The first factor is the split one." -/
def firstSplits (x : ℕ × ℕ) : Bool := decide (classType x.1 = 4)

/-- **Which-factor information is exactly zero.**  For mixed semiprimes, `N mod 24`
carries no information about *which* factor splits: swapping the factors fixes
`N mod 24` and flips the answer. -/
theorem which_factor_zero : mutInfo mixedPairs firstSplits prodClass = 0 := by
  refine mutInfo_eq_zero_of_flip _ _ _ Prod.swap ?_ ?_ ?_ ?_
  · intro x hx
    simp only [mixedPairs, U24sq, mem_filter, mem_product] at hx ⊢
    exact ⟨⟨hx.1.2, hx.1.1⟩, fun h => hx.2 h.symm⟩
  · intro x _; rfl
  · intro x hx
    simp only [mixedPairs, mem_filter] at hx
    simp only [firstSplits, Prod.fst_swap]
    by_cases h1 : classType x.1 = 4 <;> by_cases h2 : classType x.2 = 4 <;> simp_all
  · intro x _
    simp only [prodClass, Prod.fst_swap, Prod.snd_swap, mul_comm]

/-- The which-factor read-out itself is a full bit: the zero above is not because
the question is trivial. -/
theorem which_factor_entropy : uEnt mixedPairs firstSplits = 1 :=
  uEnt_flip_eq_one (by decide) _ Prod.swap
    (fun x hx => by
      simp only [mixedPairs, U24sq, mem_filter, mem_product] at hx ⊢
      exact ⟨⟨hx.1.2, hx.1.1⟩, fun h => hx.2 h.symm⟩)
    (fun _ _ => rfl)
    (fun x hx => by
      simp only [mixedPairs, mem_filter] at hx
      simp only [firstSplits, Prod.fst_swap]
      by_cases h1 : classType x.1 = 4 <;> by_cases h2 : classType x.2 = 4 <;> simp_all)

end BiquadraticTypeChannel