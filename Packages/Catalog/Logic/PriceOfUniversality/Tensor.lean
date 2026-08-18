/-
# The Price of Universality VI: tensorization, and why parameter sharing is what makes universality cheap

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The catalog shows that the memoryless class over messages of length `n` costs
only `Θ(log n)` bits of universality: a vanishing fraction of the message.  It
is tempting to conclude that universality is always cheap.  This file shows the
opposite in a precise sense, by isolating the structural feature responsible:
**a single parameter shared by all `n` symbols**.

We introduce the tensor product and the `k`-fold power of source classes — the
model of `k` *independently parameterised* blocks — and prove that the Shtarkov
sum is exactly multiplicative:

`Cₛ(S₁ ⊗ S₂) = Cₛ(S₁) · Cₛ(S₂)`,  `Cₛ(S^k) = Cₛ(S)^k`.

Hence the price of universality is *additive* over independent blocks, and grows
**linearly** in the number of blocks, while the shared-parameter class on a
message of the same total length pays only logarithmically.  For binary
memoryless blocks of length `n = 32` the gap is at least `k/4` bits once
`k ≥ 5000`: a universal decompressor must genuinely absorb `Θ(k)` bits of
"which parameters", exactly the bits that a specialised decompressor gets for
free.

## Main results

* `SourceClass.tensor`, `shtarkovSum_tensor` — `Cₛ` is multiplicative
* `SourceClass.power`, `shtarkovSum_power` — `Cₛ(S^k) = Cₛ(S)^k`
* `price_power_eq` — the price of universality is additive over independent
  blocks: `log₂ Cₛ(S^k) = k · log₂ Cₛ(S)`
* `parameter_sharing_dichotomy` — linear (independent parameters) versus
  logarithmic (shared parameter) price at equal message length
* `sharing_gap_linear` — an explicit linear lower bound on the gap

## Application keywords

tensorization, minimax redundancy, Shtarkov sum, parameter sharing, universal
compression, Rissanen redundancy
-/

import Logic.PriceOfUniversality.TypeDimension
import MachineLearning.UniversalRedundancy.Bernoulli

open Finset Real

namespace UniversalRedundancy

namespace SourceClass

variable {X Y : Type*} [Fintype X] [Fintype Y] {Θ Ψ : Type*}

/-- The tensor product of two source classes: two independent blocks with
independently chosen parameters. -/
def tensor (S : SourceClass X Θ) (T : SourceClass Y Ψ) : SourceClass (X × Y) (Θ × Ψ) where
  prob p z := S.prob p.1 z.1 * T.prob p.2 z.2
  nonneg p z := mul_nonneg (S.nonneg _ _) (T.nonneg _ _)
  sum_one p := by
    rw [Fintype.sum_prod_type]
    simp [← Finset.mul_sum, S.sum_one, T.sum_one]

variable (S : SourceClass X Θ) (T : SourceClass Y Ψ)

/-- **Division trick.**  A bound `c * p_θ x ≤ P` valid for every source, with
`c ≥ 0`, upgrades to a bound on the maximum likelihood.  This replaces an
attainment (compactness) argument and works for an arbitrary, possibly infinite,
parameter space — which is what we need, since the memoryless class is
parameterised by a whole simplex. -/
lemma mul_maxLik_le [Nonempty Θ] {c P : ℝ} (hc : 0 ≤ c) (hP : 0 ≤ P) (x : X)
    (h : ∀ θ, c * S.prob θ x ≤ P) : c * S.maxLik x ≤ P := by
  rcases hc.eq_or_lt with hc0 | hc0
  · simp [← hc0, hP]
  · have hstep : ∀ θ, S.prob θ x ≤ P / c := fun θ => by
      rw [le_div_iff₀ hc0]
      have := h θ; linarith
    have := S.maxLik_le hstep
    rw [le_div_iff₀ hc0] at this
    linarith

/-- The maximum likelihood of a pair factorises. -/
theorem maxLik_tensor [Nonempty Θ] [Nonempty Ψ] (x : X) (y : Y) :
    (S.tensor T).maxLik (x, y) = S.maxLik x * T.maxLik y := by
  refine le_antisymm ?_ ?_
  · refine (S.tensor T).maxLik_le fun p => ?_
    exact mul_le_mul (S.le_maxLik p.1 x) (T.le_maxLik p.2 y) (T.nonneg _ _)
      (S.maxLik_nonneg x)
  · set P := (S.tensor T).maxLik (x, y) with hPdef
    have hP : 0 ≤ P := (S.tensor T).maxLik_nonneg (x, y)
    have step1 : ∀ θ : Θ, S.prob θ x * T.maxLik y ≤ P := by
      intro θ
      refine T.mul_maxLik_le (S.nonneg θ x) hP y fun ψ => ?_
      exact (S.tensor T).le_maxLik (θ, ψ) (x, y)
    have step2 : T.maxLik y * S.maxLik x ≤ P := by
      refine S.mul_maxLik_le (T.maxLik_nonneg y) hP x fun θ => ?_
      have := step1 θ; linarith [mul_comm (T.maxLik y) (S.prob θ x)]
    linarith [mul_comm (T.maxLik y) (S.maxLik x)]

/-- **Multiplicativity of the Shtarkov sum.**  Two independently parameterised
blocks cost the *sum* of their prices of universality. -/
theorem shtarkovSum_tensor [Nonempty Θ] [Nonempty Ψ] :
    (S.tensor T).shtarkovSum = S.shtarkovSum * T.shtarkovSum := by
  unfold shtarkovSum
  rw [Fintype.sum_prod_type, Finset.sum_mul_sum]
  exact Finset.sum_congr rfl fun x _ => Finset.sum_congr rfl fun y _ =>
    maxLik_tensor S T x y

/-! ## Powers: `k` independently parameterised blocks -/

/-- The `k`-fold power of a source class: `k` blocks, each with its own
independently chosen parameter. -/
def power (S : SourceClass X Θ) (k : ℕ) : SourceClass (Fin k → X) (Fin k → Θ) where
  prob θ x := ∏ i, S.prob (θ i) (x i)
  nonneg θ x := Finset.prod_nonneg fun i _ => S.nonneg _ _
  sum_one θ := by
    classical
    have := Finset.prod_univ_sum (fun _ : Fin k => (univ : Finset X))
      (fun i (x : X) => S.prob (θ i) x)
    simp only [Fintype.piFinset_univ, S.sum_one, Finset.prod_const_one] at this
    simpa using this.symm

/-- The coordinatewise maximum-likelihood bound, proved one coordinate at a
time: for every set `s` of coordinates already maximised and every source
assignment `θ` on the remaining coordinates, the mixed product is bounded by the
maximum likelihood of the power class. -/
lemma power_partial_maxLik_le [Nonempty Θ] (k : ℕ) (x : Fin k → X)
    (s : Finset (Fin k)) (θ : Fin k → Θ) :
    (∏ i ∈ s, S.maxLik (x i)) * (∏ i ∈ sᶜ, S.prob (θ i) (x i))
      ≤ (S.power k).maxLik x := by
  classical
  induction s using Finset.induction generalizing θ with
  | empty =>
      simpa using (S.power k).le_maxLik θ x
  | insert j s hj ih =>
      have hjc : j ∈ sᶜ := by simp [hj]
      have hcompl : (insert j s)ᶜ = sᶜ.erase j := by
        ext i; by_cases h : i = j <;> simp [h, hj, Finset.mem_erase]
      set c : ℝ := (∏ i ∈ s, S.maxLik (x i)) * (∏ i ∈ sᶜ.erase j, S.prob (θ i) (x i))
        with hc
      have hcnn : 0 ≤ c :=
        mul_nonneg (Finset.prod_nonneg fun i _ => S.maxLik_nonneg _)
          (Finset.prod_nonneg fun i _ => S.nonneg _ _)
      have hkey : ∀ t : Θ, c * S.prob t (x j) ≤ (S.power k).maxLik x := by
        intro t
        have hIH := ih (Function.update θ j t)
        have hupd : ∏ i ∈ sᶜ, S.prob ((Function.update θ j t) i) (x i)
            = S.prob t (x j) * ∏ i ∈ sᶜ.erase j, S.prob (θ i) (x i) := by
          rw [← Finset.mul_prod_erase _ _ hjc, Function.update_self]
          congr 1
          refine Finset.prod_congr rfl fun i hi => ?_
          rw [Function.update_of_ne (Finset.mem_erase.mp hi).1]
        rw [hupd] at hIH
        calc c * S.prob t (x j)
            = (∏ i ∈ s, S.maxLik (x i))
                * (S.prob t (x j) * ∏ i ∈ sᶜ.erase j, S.prob (θ i) (x i)) := by
              rw [hc]; ring
          _ ≤ (S.power k).maxLik x := hIH
      have hfinal := S.mul_maxLik_le hcnn ((S.power k).maxLik_nonneg x) (x j) hkey
      calc (∏ i ∈ insert j s, S.maxLik (x i)) * (∏ i ∈ (insert j s)ᶜ, S.prob (θ i) (x i))
          = c * S.maxLik (x j) := by
            rw [Finset.prod_insert hj, hcompl, hc]; ring
        _ ≤ (S.power k).maxLik x := hfinal

/-- The maximum likelihood of a block message factorises over blocks. -/
theorem maxLik_power [Nonempty Θ] (k : ℕ) (x : Fin k → X) :
    (S.power k).maxLik x = ∏ i, S.maxLik (x i) := by
  classical
  refine le_antisymm ?_ ?_
  · refine (S.power k).maxLik_le fun θ => ?_
    show ∏ i, S.prob (θ i) (x i) ≤ ∏ i, S.maxLik (x i)
    exact Finset.prod_le_prod (fun i _ => S.nonneg _ _)
      (fun i _ => S.le_maxLik (θ i) (x i))
  · have h := S.power_partial_maxLik_le k x Finset.univ (fun _ => Classical.arbitrary Θ)
    simpa using h

/-- **The Shtarkov sum of a power is the power of the Shtarkov sum.** -/
theorem shtarkovSum_power [Nonempty Θ] (k : ℕ) :
    (S.power k).shtarkovSum = S.shtarkovSum ^ k := by
  classical
  have hmax : (S.power k).shtarkovSum = ∑ x : Fin k → X, ∏ i, S.maxLik (x i) :=
    Finset.sum_congr rfl fun x _ => maxLik_power S k x
  have hprod := Finset.prod_univ_sum (fun _ : Fin k => (univ : Finset X))
    (fun _ (x : X) => S.maxLik x)
  simp only [Fintype.piFinset_univ] at hprod
  rw [hmax, ← hprod]
  simp [shtarkovSum]

/-- **Additivity of the price of universality over independent blocks.**  In
bits: `k` independently parameterised blocks cost exactly `k` times the price of
one block. -/
theorem price_power_eq [Nonempty Θ] (k : ℕ) :
    logb 2 (S.power k).shtarkovSum = (k : ℝ) * logb 2 S.shtarkovSum := by
  rw [shtarkovSum_power, Real.logb_pow]

end SourceClass

/-! ## The dichotomy: shared versus independent parameters -/

/-- **The price of universality is linear in the number of independently
parameterised blocks, but only logarithmic when the parameter is shared.**

Both sides describe messages of the same total length `k · n` over a binary
alphabet.  On the left, `k` blocks of length `n`, each with its own Bernoulli
parameter: the universal code must pay at least `k · (½ log₂ n − 2)` bits.  On
the right, one Bernoulli parameter shared by all `k · n` symbols: at most
`log₂ (k n + 1)` bits.  Parameter sharing, not memorylessness, is what makes
universality cheap. -/
theorem parameter_sharing_dichotomy (n k : ℕ) (hn : 2 ≤ n) :
    (k : ℝ) * ((1 / 2) * logb 2 n - 2)
        ≤ logb 2 ((iidClass Bool n).power k).shtarkovSum ∧
      logb 2 (iidClass Bool (k * n)).shtarkovSum ≤ logb 2 ((k * n : ℕ) + 1 : ℝ) := by
  constructor
  · rw [SourceClass.price_power_eq]
    have h := bernoulli_price_lower_bits n hn
    have hk : (0 : ℝ) ≤ (k : ℝ) := by positivity
    exact mul_le_mul_of_nonneg_left h hk
  · have hC := shtarkovSum_bernoulli_le (k * n)
    exact Real.logb_le_logb_of_le (by norm_num) (iidClass Bool (k * n)).shtarkovSum_pos
      (by push_cast at hC ⊢; linarith)

/-- Elementary bound `log₂ t ≤ 2.9 √t` for `t ≥ 1`, used to compare the linear
and logarithmic prices. -/
lemma logb_le_sqrt_bound {t : ℝ} (ht : 1 ≤ t) : logb 2 t ≤ 2.9 * Real.sqrt t := by
  have ht0 : (0 : ℝ) < t := lt_of_lt_of_le zero_lt_one ht
  have hs : Real.sqrt t ^ 2 = t := Real.sq_sqrt ht0.le
  have hs1 : 1 ≤ Real.sqrt t := by
    nlinarith [Real.sqrt_nonneg t]
  have hlog : Real.log (Real.sqrt t) ≤ Real.sqrt t - 1 :=
    Real.log_le_sub_one_of_pos (lt_of_lt_of_le zero_lt_one hs1)
  have hlogt : Real.log t = 2 * Real.log (Real.sqrt t) := by
    rw [← hs, Real.log_pow]
    push_cast
    ring_nf
    rw [Real.sq_sqrt ht0.le]
  have h2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hlt : Real.log t ≤ 2 * (Real.sqrt t - 1) := by rw [hlogt]; linarith
  have hpos : (0 : ℝ) < Real.log 2 := by linarith
  rw [Real.logb, div_le_iff₀ hpos]
  nlinarith [hs1]

/-- **The gap between the independent-parameter price and the shared-parameter
price grows at least linearly.**  With binary memoryless blocks of length `32`,
once there are `k ≥ 5000` blocks the universal code for independently
parameterised blocks pays at least `k / 4` bits more than the universal code for
the shared-parameter class on a message of the same total length `32 k`.

So specialising the decompressor to a *class* really can move an unbounded
number of bits out of the message and into the shared decompressor — provided
the class has independent parameters. -/
theorem sharing_gap_linear (k : ℕ) (hk : 5000 ≤ k) :
    (k : ℝ) / 4 ≤ logb 2 ((iidClass Bool 32).power k).shtarkovSum
      - logb 2 (iidClass Bool (k * 32)).shtarkovSum := by
  have hkR : (5000 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  obtain ⟨hlow, hhigh⟩ := parameter_sharing_dichotomy 32 k (by norm_num)
  have hlog32 : logb 2 ((32 : ℕ) : ℝ) = 5 := by
    norm_num
    rw [show (32 : ℝ) = 2 ^ (5 : ℕ) by norm_num, Real.logb_pow,
      Real.logb_self_eq_one] <;> norm_num
  have hlow' : (k : ℝ) / 2 ≤ logb 2 ((iidClass Bool 32).power k).shtarkovSum := by
    rw [hlog32] at hlow
    linarith
  -- the shared-parameter price is at most `2.9 √(32k+1)`, which is `≤ k/4`
  have hsq : Real.sqrt ((k * 32 : ℕ) + 1 : ℝ) ≤ Real.sqrt (33 * (k : ℝ)) := by
    apply Real.sqrt_le_sqrt
    push_cast
    linarith
  have hbound : logb 2 ((k * 32 : ℕ) + 1 : ℝ) ≤ 2.9 * Real.sqrt (33 * (k : ℝ)) := by
    refine le_trans (logb_le_sqrt_bound ?_) ?_
    · push_cast; linarith
    · nlinarith [Real.sqrt_nonneg ((k * 32 : ℕ) + 1 : ℝ), Real.sqrt_nonneg (33 * (k : ℝ))]
  have hsqrt_sq : Real.sqrt (33 * (k : ℝ)) ^ 2 = 33 * (k : ℝ) :=
    Real.sq_sqrt (by positivity)
  have hs406 : (406 : ℝ) ≤ Real.sqrt (33 * (k : ℝ)) := by
    nlinarith [Real.sqrt_nonneg (33 * (k : ℝ)), hsqrt_sq, hkR]
  have hfinal : 2.9 * Real.sqrt (33 * (k : ℝ)) ≤ (k : ℝ) / 4 := by
    nlinarith [hs406, hsqrt_sq]
  linarith

end UniversalRedundancy