/-
# Meromorphic Rigidity (Factoring Lab, Phase A v19c — cycle 2)

Closing **Conjecture 2** of `FUTURE_DIRECTIONS.md`: the holomorphic rigidity
barrier survives the removal of entirety.

The previous cycle proved `FactoringLab.holomorphic_rigidity_barrier`: no
*entire* `f : ℂ → ℂ` satisfies `f(1/N) = 1/p` for every semiprime `N = pq`
with `p < q` prime.  The proof went through the identity theorem at the
accumulation point `0`, which needs `f` to be analytic *at* `0`.

Conjecture 2 asserted that this is an artifact: any function with an isolated,
non-essential singularity at `0` — i.e. any `f` meromorphic at `0`, which
includes every entire function, every finite-order entire function, every
rational function and every function with a pole of finite order — is already
pinned down by countably many values accumulating at `0`.  That is now the
theorem `FactoringLab.meromorphic_rigidity_barrier`, and the original HRB is
recovered from it as the corollary
`FactoringLab.holomorphic_rigidity_of_meromorphic`.

The mechanism replacing the identity theorem is Mathlib's dichotomy
`MeromorphicAt.eventually_eq_zero_or_eventually_ne_zero`: near an isolated
singularity a meromorphic function either vanishes identically or is nonzero on
a punctured neighbourhood.  The semiprimes `3q` force the first alternative for
`f − 1/3`; the semiprimes `5q` then contradict it.  Only the two families
`p = 3` and `p = 5` are used, so the barrier already applies to functions that
are only assumed to compute the factor for these two small primes
(`FactoringLab.meromorphic_rigidity_two_families`).
-/
import Mathlib
import Probability.FactoringBarriers

open Filter Topology

namespace FactoringLab

/-! ## 1.  Reciprocals of a diverging integer sequence accumulate at `0` -/

/-- If `m n → ∞` through positive integers, the reciprocals `1/m n` converge to
`0` while staying nonzero, i.e. they converge in the punctured neighbourhood
filter `𝓝[≠] 0`. -/
theorem tendsto_inv_natCast_nhdsWithin {m : ℕ → ℕ} (hpos : ∀ n, 0 < m n)
    (htop : Tendsto m atTop atTop) :
    Tendsto (fun n => ((m n : ℕ) : ℂ)⁻¹) atTop (nhdsWithin 0 {(0 : ℂ)}ᶜ) := by
  have hreal : Tendsto (fun n => ((m n : ℕ) : ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop.comp htop
  have hnorm : Tendsto (fun n => ‖((m n : ℕ) : ℂ)⁻¹‖) atTop (nhds 0) := by
    have heq : ∀ n, ‖((m n : ℕ) : ℂ)⁻¹‖ = ((m n : ℕ) : ℝ)⁻¹ := by
      intro n; rw [norm_inv, Complex.norm_natCast]
    simp only [heq]
    exact hreal.inv_tendsto_atTop
  refine tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _
    (tendsto_zero_iff_norm_tendsto_zero.2 hnorm) ?_
  filter_upwards with n
  have hne : ((m n : ℕ) : ℂ) ≠ 0 := Nat.cast_ne_zero.2 (hpos n).ne'
  simpa using inv_ne_zero hne

/-! ## 2.  A prime family above `5` -/

/-- Primes strictly larger than `5`, indexed by `ℕ`. -/
noncomputable def hugePrime (n : ℕ) : ℕ := bigPrime (n + 2)

theorem hugePrime_prime (n : ℕ) : (hugePrime n).Prime := bigPrime_prime (n + 2)

theorem five_lt_hugePrime (n : ℕ) : 5 < hugePrime n := by
  have h0 : 3 < bigPrime 0 := three_lt_bigPrime 0
  have h01 : bigPrime 0 < bigPrime 1 := bigPrime_strictMono (by omega)
  have h12 : bigPrime 1 < bigPrime 2 := bigPrime_strictMono (by omega)
  have h2n : bigPrime 2 ≤ bigPrime (n + 2) :=
    bigPrime_strictMono.monotone (by omega)
  unfold hugePrime
  omega

theorem hugePrime_tendsto : Tendsto hugePrime atTop atTop :=
  bigPrime_tendsto.comp (tendsto_add_atTop_nat 2)

/-- The reciprocals of the semiprimes `5q`, `q` prime above `5`, accumulate at
`0`. -/
theorem tendsto_recip_five_semiprime :
    Tendsto (fun n => (((5 * hugePrime n : ℕ) : ℂ))⁻¹) atTop (nhdsWithin 0 {(0 : ℂ)}ᶜ) := by
  refine tendsto_inv_natCast_nhdsWithin (fun n => ?_) ?_
  · have := five_lt_hugePrime n; omega
  · exact Filter.tendsto_atTop_mono
      (fun n => Nat.le_mul_of_pos_left (hugePrime n) (by norm_num)) hugePrime_tendsto

/-! ## 3.  The meromorphic rigidity barrier -/

/-- **Meromorphic rigidity barrier.**  There is no function `f` meromorphic at
`0` — in particular no entire function, no function of finite order and no
function with a pole of finite order at `0` — with `f(1/(pq)) = 1/p` for all
primes `p < q`.  Only the two families `p = 3` and `p = 5` are used. -/
theorem meromorphic_rigidity_two_families (f : ℂ → ℂ) (hf : MeromorphicAt f 0)
    (h3 : ∀ q : ℕ, q.Prime → 3 < q → f (((3 * q : ℕ) : ℂ))⁻¹ = ((3 : ℕ) : ℂ)⁻¹)
    (h5 : ∀ q : ℕ, q.Prime → 5 < q → f (((5 * q : ℕ) : ℂ))⁻¹ = ((5 : ℕ) : ℂ)⁻¹) :
    False := by
  set c : ℂ := ((3 : ℕ) : ℂ)⁻¹ with hc
  have hg : MeromorphicAt (fun z => f z - c) 0 := hf.sub (MeromorphicAt.const c 0)
  have hzero : ∀ n, f ((((3 * bigPrime n : ℕ) : ℂ))⁻¹) - c = 0 := by
    intro n
    rw [h3 (bigPrime n) (bigPrime_prime n) (three_lt_bigPrime n), sub_self]
  -- the second alternative of the meromorphic dichotomy is impossible
  have hnot : ¬ (∀ᶠ z in nhdsWithin (0 : ℂ) {(0 : ℂ)}ᶜ, f z - c ≠ 0) := by
    intro hev
    have := tendsto_recip_semiprime.eventually hev
    obtain ⟨n, hn⟩ := this.exists
    exact hn (hzero n)
  have hall : ∀ᶠ z in nhdsWithin (0 : ℂ) {(0 : ℂ)}ᶜ, f z - c = 0 :=
    hg.eventually_eq_zero_or_eventually_ne_zero.resolve_right hnot
  -- but the family `5q` also accumulates at `0`, and there `f = 1/5`
  obtain ⟨n, hn⟩ := (tendsto_recip_five_semiprime.eventually hall).exists
  rw [h5 (hugePrime n) (hugePrime_prime n) (five_lt_hugePrime n), sub_eq_zero] at hn
  rw [hc] at hn
  have h35 : ((5 : ℕ) : ℂ) = ((3 : ℕ) : ℂ) := inv_injective hn
  norm_num at h35

/-- **Meromorphic rigidity barrier (HRB, general form).**  No function
meromorphic at the origin computes the smaller factor through `f(1/N) = 1/p`. -/
theorem meromorphic_rigidity_barrier (f : ℂ → ℂ) (hf : MeromorphicAt f 0) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        f (((p * q : ℕ) : ℂ))⁻¹ = ((p : ℕ) : ℂ)⁻¹ := by
  intro h
  exact meromorphic_rigidity_two_families f hf
    (fun q hq hlt => h 3 q (by norm_num) hq hlt)
    (fun q hq hlt => h 5 q (by norm_num) hq hlt)

/-- The original holomorphic rigidity barrier is the special case of the
meromorphic one: an entire function is analytic, hence meromorphic, at `0`. -/
theorem holomorphic_rigidity_of_meromorphic (f : ℂ → ℂ) (hf : Differentiable ℂ f) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        f (((p * q : ℕ) : ℂ))⁻¹ = ((p : ℕ) : ℂ)⁻¹ :=
  meromorphic_rigidity_barrier f (hf.analyticAt 0).meromorphicAt

/-- A concrete instance of the strengthening: no *rational* function of `1/N`
computes the smaller factor, however high the order of its pole at the origin.
Every quotient `A / B` of polynomials is meromorphic at `0`. -/
theorem rational_function_rigidity (A B : Polynomial ℂ) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p < q →
        (fun z => A.eval z / B.eval z) (((p * q : ℕ) : ℂ))⁻¹ = ((p : ℕ) : ℂ)⁻¹ := by
  refine meromorphic_rigidity_barrier (fun z => A.eval z / B.eval z) ?_
  have hA : MeromorphicAt (fun z => A.eval z) 0 :=
    (A.differentiable.analyticAt 0).meromorphicAt
  have hBm : MeromorphicAt (fun z => B.eval z) 0 :=
    (B.differentiable.analyticAt 0).meromorphicAt
  exact hA.div hBm

end FactoringLab