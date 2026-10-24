module

public import Mathlib

/-!
# Divergence of the sum of prime reciprocals in an arithmetic progression

Mathlib proves Dirichlet's theorem through the non-summability of `Λ(n)/n` over primes in a
residue class (`ArithmeticFunction.vonMangoldt.not_summable_residueClass_prime_div`).  That
statement does **not** directly imply divergence of `∑ 1/p` over such primes (the weights
`log p` are larger).  Here we derive the stronger statement from Mathlib's lower bound
`LSeries_residueClass_lower_bound` by a tail argument:

* if `∑_{p ≡ a} 1/p` converged, its tail beyond `P` would be `≤ c/2`,
  and `log p / p^x ≤ 1 / ((x-1) p)` would give `∑ Λ_a(n)/n^x ≤ H + (c/2)/(x-1)`,
  contradicting the lower bound `c/(x-1) - C` as `x → 1⁺`.

Main result: `PrimeRecipAP.not_summable_recipAP`, and the special case
`PrimeRecipAP.exists_finset_three_mod_four_sum_gt` used for the density-zero theorem.
-/

@[expose] public section

open ArithmeticFunction ArithmeticFunction.vonMangoldt Filter Finset

namespace PrimeRecipAP

/-- The reciprocal `1/n` restricted to primes `n ≡ a (mod q)`. -/
noncomputable def recipAP {q : ℕ} (a : ZMod q) (n : ℕ) : ℝ :=
  if n.Prime ∧ (n : ZMod q) = a then 1 / n else 0

lemma recipAP_nonneg {q : ℕ} (a : ZMod q) (n : ℕ) : 0 ≤ recipAP a n := by
  unfold recipAP; split_ifs <;> positivity

/-- Key pointwise estimate: `log n / n^x ≤ 1 / ((x - 1) n)` for `x > 1`, `n ≥ 1`. -/
lemma log_div_rpow_le {n : ℕ} (hn : 1 ≤ n) {x : ℝ} (hx : 1 < x) :
    Real.log n / (n : ℝ) ^ x ≤ 1 / (x - 1) / n := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have hε : 0 < x - 1 := by linarith
  have hlog := Real.log_le_rpow_div hn0.le hε
  have hpow : (n : ℝ) ^ x = (n : ℝ) ^ (x - 1) * n := by
    rw [← Real.rpow_add_one hn0.ne']; ring_nf
  have hp : 0 < (n : ℝ) ^ (x - 1) := Real.rpow_pos_of_pos hn0 _
  rw [hpow, div_le_iff₀ (by positivity)]
  calc Real.log n ≤ (n : ℝ) ^ (x - 1) / (x - 1) := hlog
    _ = 1 / (x - 1) / n * ((n : ℝ) ^ (x - 1) * n) := by field_simp

/-- **Divergence of `∑ 1/p` over primes `p ≡ a (mod q)`**, for `a` a unit mod `q`. -/
theorem not_summable_recipAP {q : ℕ} [NeZero q] {a : ZMod q} (ha : IsUnit a) :
    ¬ Summable (recipAP a) := by
  intro hg
  obtain ⟨C, hC⟩ := LSeries_residueClass_lower_bound ha
  set c : ℝ := (q.totient : ℝ)⁻¹ with hc_def
  have hc : 0 < c := inv_pos.mpr (by exact_mod_cast Nat.totient_pos.mpr (NeZero.pos q))
  -- small tail
  obtain ⟨P, hP⟩ : ∃ P, ∑' k, recipAP a (k + P) ≤ c / 2 := by
    have := tendsto_sum_nat_add (recipAP a)
    exact (this.eventually (ge_mem_nhds (by positivity))).exists
  set h : ℕ → ℝ := fun n => (if n.Prime then 0 else residueClass a n) / n +
    (if n < P then residueClass a n / n else 0) with h_def
  have hh_nonneg : ∀ n, 0 ≤ h n := by
    intro n
    have := residueClass_nonneg a n
    simp only [h_def]
    apply add_nonneg
    · split_ifs <;> positivity
    · split_ifs <;> positivity
  have hh : Summable h := by
    refine (summable_residueClass_non_primes_div a).add ?_
    refine summable_of_ne_finset_zero (s := range P) ?_
    intro n hn
    simp only [mem_range] at hn
    simp [hn]
  set g : ℕ → ℝ := fun n => if P ≤ n then recipAP a n else 0 with g_def
  have hg_nonneg : ∀ n, 0 ≤ g n := by
    intro n; simp only [g_def]; split_ifs
    · exact recipAP_nonneg a n
    · exact le_rfl
  have hgs : Summable g := by
    refine hg.of_nonneg_of_le hg_nonneg ?_
    intro n; simp only [g_def]; split_ifs
    · exact le_rfl
    · exact recipAP_nonneg a n
  have hgt : ∑' n, g n ≤ c / 2 := by
    rw [← hgs.sum_add_tsum_nat_add P]
    have h1 : ∑ i ∈ range P, g i = 0 := by
      apply Finset.sum_eq_zero
      intro i hi
      simp only [mem_range] at hi
      simp [g_def, show ¬ P ≤ i by omega]
    have h2 : ∀ k, g (k + P) = recipAP a (k + P) := by
      intro k; simp [g_def]
    simp only [h1, h2, zero_add]
    exact hP
  -- termwise bound
  have hterm : ∀ {x : ℝ}, 1 < x → ∀ n : ℕ,
      residueClass a n / (n : ℝ) ^ x ≤ h n + g n / (x - 1) := by
    intro x hx n
    have hε : 0 < x - 1 := by linarith
    have hgx : 0 ≤ g n / (x - 1) := div_nonneg (hg_nonneg n) hε.le
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp only [residueClass_apply_zero, zero_div]
      exact add_nonneg (hh_nonneg 0) hgx
    have hn1 : 1 ≤ n := hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
    have hrc := residueClass_nonneg a n
    have hnx : (n : ℝ) ≤ (n : ℝ) ^ x := by
      calc (n : ℝ) = (n : ℝ) ^ (1 : ℝ) := (Real.rpow_one _).symm
        _ ≤ (n : ℝ) ^ x := Real.rpow_le_rpow_of_exponent_le (by exact_mod_cast hn1) hx.le
    have hle1 : residueClass a n / (n : ℝ) ^ x ≤ residueClass a n / n :=
      div_le_div_of_nonneg_left hrc hn0 hnx
    by_cases hprime : n.Prime
    · by_cases hP' : n < P
      · have : h n = residueClass a n / n := by simp [h_def, hprime, hP']
        rw [this]; linarith
      · -- large prime
        have hhn : 0 ≤ h n := hh_nonneg n
        by_cases hmod : (n : ZMod q) = a
        · have hres : residueClass a n = Real.log n := by
            simp [residueClass, Set.indicator, hmod, vonMangoldt_apply_prime hprime]
          have hgn : g n = 1 / n := by
            simp [g_def, show P ≤ n by omega, recipAP, hprime, hmod]
          rw [hres, hgn]
          have := log_div_rpow_le hn1 hx
          have e : 1 / (n : ℝ) / (x - 1) = 1 / (x - 1) / n := by ring
          rw [e]; linarith
        · have hres : residueClass a n = 0 := by
            simp [residueClass, Set.indicator, hmod]
          rw [hres, zero_div]; exact add_nonneg hhn hgx
    · have : (if n.Prime then 0 else residueClass a n) / n = residueClass a n / n := by
        simp [hprime]
      have h2 : 0 ≤ (if n < P then residueClass a n / n else 0) := by
        split_ifs <;> positivity
      have : residueClass a n / n ≤ h n := by
        simp only [h_def]; rw [this]; linarith
      linarith
  -- summed bound
  have hsum : ∀ {x : ℝ}, 1 < x →
      ∑' n, residueClass a n / (n : ℝ) ^ x ≤ ∑' n, h n + (c / 2) / (x - 1) := by
    intro x hx
    have hε : 0 < x - 1 := by linarith
    have hR : Summable (fun n => h n + g n / (x - 1)) := hh.add (hgs.div_const _)
    have hL : Summable (fun n : ℕ => residueClass a n / (n : ℝ) ^ x) := by
      refine hR.of_nonneg_of_le (fun n => ?_) (hterm hx)
      have := residueClass_nonneg a n
      positivity
    calc ∑' n, residueClass a n / (n : ℝ) ^ x ≤ ∑' n, (h n + g n / (x - 1)) :=
          hL.tsum_le_tsum (hterm hx) hR
      _ = ∑' n, h n + (∑' n, g n) / (x - 1) := by
          rw [hh.tsum_add (hgs.div_const _), tsum_div_const]
      _ ≤ ∑' n, h n + (c / 2) / (x - 1) := by
          gcongr
  -- contradiction as x → 1⁺
  set H := ∑' n, h n
  set M : ℝ := |H + C| + 1 with hM
  have hMpos : 0 < M := by positivity
  set δ : ℝ := min 1 (c / (2 * M)) with hδ
  have hδpos : 0 < δ := lt_min one_pos (by positivity)
  have hδ1 : δ ≤ 1 := min_le_left _ _
  have hδ2 : δ ≤ c / (2 * M) := min_le_right _ _
  have hx : 1 + δ ∈ Set.Ioc (1 : ℝ) 2 := ⟨by linarith, by linarith⟩
  have hlow := hC hx
  have hup := hsum hx.1
  have e : (1 + δ - 1) = δ := by ring
  rw [e] at hlow hup
  have key : c / 2 / δ ≤ H + C := by
    have : c / δ = c / 2 / δ + c / 2 / δ := by ring
    linarith
  have hbig : M ≤ c / 2 / δ := by
    rw [le_div_iff₀ hδpos]
    have := mul_le_mul_of_nonneg_left hδ2 hMpos.le
    have e2 : M * (c / (2 * M)) = c / 2 := by field_simp
    linarith
  have : H + C < M := by
    have := le_abs_self (H + C); linarith
  linarith

/-- The case `q = 4`, `a = 3`: the primes `p ≡ 3 (mod 4)` have divergent reciprocal sum. -/
theorem not_summable_recip_three_mod_four :
    ¬ Summable (fun n : ℕ => if n.Prime ∧ n % 4 = 3 then (1 : ℝ) / n else 0) := by
  have hu : IsUnit (3 : ZMod 4) := by decide
  have := not_summable_recipAP hu
  have hiff : ∀ n : ℕ, (n.Prime ∧ n % 4 = 3) ↔ (n.Prime ∧ (n : ZMod 4) = 3) := by
    intro n
    have : ((n : ZMod 4) = 3) ↔ n % 4 = 3 := by
      have := ZMod.natCast_eq_natCast_iff' n 3 4
      simpa using this
    rw [this]
  have heq : (fun n : ℕ => if n.Prime ∧ n % 4 = 3 then (1 : ℝ) / n else 0) =
      recipAP (3 : ZMod 4) := by
    funext n
    unfold recipAP
    exact if_congr (hiff n) rfl rfl
  rw [heq]; exact this

/-- For every bound `B`, there is a finite set of primes `≡ 3 (mod 4)` whose reciprocals sum
to more than `B`. -/
theorem exists_finset_three_mod_four_sum_gt (B : ℝ) :
    ∃ S : Finset ℕ, (∀ p ∈ S, p.Prime ∧ p % 4 = 3) ∧ B < ∑ p ∈ S, (1 : ℝ) / p := by
  by_contra hcon
  push_neg at hcon
  apply not_summable_recip_three_mod_four
  refine summable_of_sum_range_le (c := B) (fun n => ?_) (fun n => ?_)
  · split_ifs <;> positivity
  · classical
    rw [← Finset.sum_filter]
    exact hcon _ (fun p hp => (Finset.mem_filter.1 hp).2)

end PrimeRecipAP