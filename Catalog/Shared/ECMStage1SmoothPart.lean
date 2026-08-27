import Mathlib
import Catalog.Shared.ECMStage1FiringRate

/-!
# The smooth part is the whole story: structure of the stage-1 firing count

Two files up we showed that stage-1 firing is the divisibility `orderOf g ∣ k(B)`, and
that the number of firing points of a cyclic group of order `m` is exactly `gcd(m, k(B))`.
This file identifies that number structurally and pushes the picture to the group shape
that actually occurs for elliptic curves over a prime field (a product of at most two
cyclic groups), and to the analytic comparison with the collision heuristic.

* `gcd_stage1Scalar_isGreatest`: `gcd(m, k(B))` **is** the largest `B`-powersmooth
  divisor of `m`, in the divisibility order.  So "how often does stage 1 fire" is
  literally "how big is the powersmooth part of the order".
* `firing_count_eq_one_of_all_prime_factors_gt`: if every prime factor of the order
  exceeds the bound, the firing count collapses to `1` (only the identity).  This is
  the `found_q` control in exact form: at the large prime factor of the modulus,
  order completion contributes a rate of `1/m`, so any hits there measure something
  else entirely.
* `card_firingSet_prod`: for a rank-two group `ℤ/m₁ × ℤ/m₂` — the actual shape of
  `E(𝔽_p)` — the firing count is the product `gcd(m₁,k)·gcd(m₂,k)` of the two
  smooth parts, and it is at least as large as in the cyclic case
  (`rank_two_fires_at_least_as_often`).
* `orderCompletion_exceeds_collision_baseline`: the analytic comparison.  Since
  `1 - exp(-x) ≤ x`, an order-completion rate above `1.44·B/m` provably exceeds the
  folklore collision baseline `1 - exp(-1.44·B/m)`; the numeric witness of the
  previous file is the special case `m = 720, B = 10`.
-/

namespace ECMStage1

open Finset

/-! ## The firing count is the powersmooth part of the order -/

/-- Divisors of a `B`-powersmooth number are `B`-powersmooth. -/
theorem Powersmooth.of_dvd {B n d : ℕ} (hn : n ≠ 0) (hB : B ≠ 0) (hd : d ∣ n) (hdz : d ≠ 0)
    (h : Powersmooth B n) : Powersmooth B d :=
  (dvd_stage1Scalar_iff hdz hB).mp (hd.trans ((dvd_stage1Scalar_iff hn hB).mpr h))

/-- **The firing count is the largest powersmooth divisor.**  `gcd(m, k(B))` divides
`m`, is `B`-powersmooth, and every `B`-powersmooth divisor of `m` divides it. -/
theorem gcd_stage1Scalar_isGreatest {m B : ℕ} (hm : m ≠ 0) (hB : B ≠ 0) :
    Nat.gcd m (stage1Scalar B) ∣ m ∧ Powersmooth B (Nat.gcd m (stage1Scalar B)) ∧
      ∀ d, d ∣ m → Powersmooth B d → d ∣ Nat.gcd m (stage1Scalar B) := by
  refine ⟨Nat.gcd_dvd_left _ _, ?_, ?_⟩
  · exact (dvd_stage1Scalar_iff (Nat.gcd_ne_zero_left hm) hB).mp (Nat.gcd_dvd_right _ _)
  · intro d hd hsm
    have hdz : d ≠ 0 := by
      rintro rfl
      exact hm (Nat.eq_zero_of_zero_dvd hd)
    exact Nat.dvd_gcd hd ((dvd_stage1Scalar_iff hdz hB).mpr hsm)

/-- **The `found_q` control.**  If every prime factor of the order exceeds the
smoothness bound, only the identity fires: the order-completion rate is exactly
`1/m`, so success at such a factor cannot be order completion. -/
theorem firing_count_eq_one_of_all_prime_factors_gt {m B : ℕ} (hm : m ≠ 0) (hB : B ≠ 0)
    (hlarge : ∀ q ∈ m.primeFactors, B < q) : Nat.gcd m (stage1Scalar B) = 1 := by
  obtain ⟨-, hsm, -⟩ := gcd_stage1Scalar_isGreatest hm hB
  set d := Nat.gcd m (stage1Scalar B) with hd
  have hdz : d ≠ 0 := Nat.gcd_ne_zero_left hm
  by_contra hne
  obtain ⟨q, hq⟩ := Nat.exists_prime_and_dvd hne
  have hqd : q ∈ d.primeFactors := Nat.mem_primeFactors.mpr ⟨hq.1, hq.2, hdz⟩
  have hqm : q ∈ m.primeFactors :=
    Nat.primeFactors_mono (Nat.gcd_dvd_left m (stage1Scalar B)) hm hqd
  have h1 : q ^ d.factorization q ≤ B := hsm q hqd
  have h2 : 0 < d.factorization q :=
    Nat.Prime.factorization_pos_of_dvd hq.1 hdz hq.2
  have h3 : q ≤ q ^ d.factorization q := by
    calc q = q ^ 1 := (pow_one q).symm
      _ ≤ q ^ d.factorization q := Nat.pow_le_pow_right hq.1.pos h2
  have := hlarge q hqm
  omega

/-- The corresponding rate statement: at most one point in `m` fires. -/
theorem firingSet_card_eq_one_of_all_prime_factors_gt {m B : ℕ} (hm : 0 < m) (hB : B ≠ 0)
    (hlarge : ∀ q ∈ m.primeFactors, B < q) :
    (firingSet m (stage1Scalar B)).card = 1 := by
  rw [card_firingSet _ _ hm]
  exact firing_count_eq_one_of_all_prime_factors_gt hm.ne' hB hlarge

/-! ## Rank-two groups: the actual shape of `E(𝔽_p)` -/

/-- **Firing count in a rank-two group.**  For `ℤ/m₁ × ℤ/m₂` the number of firing
points is the product of the two smooth parts. -/
theorem card_firingSet_prod (m₁ m₂ k : ℕ) (h₁ : 0 < m₁) (h₂ : 0 < m₂) :
    (((Finset.range m₁) ×ˢ (Finset.range m₂)).filter
        (fun a => m₁ ∣ k * a.1 ∧ m₂ ∣ k * a.2)).card = Nat.gcd m₁ k * Nat.gcd m₂ k := by
  classical
  have h : ((Finset.range m₁) ×ˢ (Finset.range m₂)).filter
      (fun a => m₁ ∣ k * a.1 ∧ m₂ ∣ k * a.2)
      = firingSet m₁ k ×ˢ firingSet m₂ k := by
    ext a
    simp [firingSet, Finset.mem_filter, Finset.mem_product, and_assoc, and_left_comm,
      and_comm]
  rw [h, Finset.card_product, card_firingSet _ _ h₁, card_firingSet _ _ h₂]

/-- A rank-two group of order `m₁·m₂` fires at least as often as a cyclic group of
order `m₁·m₂` does: splitting the order into two factors can only increase the
powersmooth part. -/
theorem rank_two_fires_at_least_as_often (m₁ m₂ k : ℕ) (h₁ : 0 < m₁) (h₂ : 0 < m₂) :
    Nat.gcd (m₁ * m₂) k ≤ Nat.gcd m₁ k * Nat.gcd m₂ k :=
  Nat.le_of_dvd (Nat.mul_pos (Nat.gcd_pos_of_pos_left k h₁) (Nat.gcd_pos_of_pos_left k h₂))
    (Nat.gcd_mul_left_dvd_mul_gcd k m₁ m₂)

/-! ## Against the collision baseline -/

/-- **The collision baseline is an upper bound of the wrong size.**  The folklore
per-curve collision rate `1 - exp(-1.44·B/m)` never exceeds `1.44·B/m`; hence any
order-completion rate above that linear threshold provably beats it. -/
theorem orderCompletion_exceeds_collision_baseline {m B : ℕ} (hm : 0 < m)
    (hbig : (1.44 : ℝ) * B < (Nat.gcd m (stage1Scalar B) : ℝ)) :
    1 - Real.exp (-(1.44 * B / m)) < (Nat.gcd m (stage1Scalar B) : ℝ) / m := by
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  have hexp : 1 - (1.44 * B / m) ≤ Real.exp (-(1.44 * B / m)) := by
    have := Real.add_one_le_exp (-(1.44 * (B : ℝ) / m))
    linarith
  have hlin : (1.44 : ℝ) * B / m < (Nat.gcd m (stage1Scalar B) : ℝ) / m :=
    by gcongr
  linarith

/-- Explicit instance of the analytic comparison: order `720`, bound `B = 10`.
The exact order-completion rate `1/2` beats the collision baseline. -/
theorem orderCompletion_exceeds_collision_baseline_720 :
    1 - Real.exp (-(1.44 * 10 / 720)) < (Nat.gcd 720 (stage1Scalar 10) : ℝ) / 720 := by
  refine orderCompletion_exceeds_collision_baseline (by norm_num) ?_
  rw [gcd_720_stage1Scalar_ten]
  norm_num

end ECMStage1