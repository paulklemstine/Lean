/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality I: Shtarkov's exact minimax redundancy

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1:
**one shared decompressor must serve all inputs**.  The counting core
(`MachineLearning.PRNGCompressionCore`) shows that no code shortens all inputs.
This file asks the quantitative refinement: if the data is known to come from
*some* member of a class of sources `{p_θ}_{θ ∈ Θ}`, how many bits does a single
universal code lose against the code tailored to the true `θ`?

## Central Idea

For a coding distribution `q` the pointwise redundancy at message `x` under
source `θ` is `log₂ (p_θ x / q x)`.  The worst case over `x` and `θ` is governed
by the **Shtarkov sum**

`Cₛ = ∑ₓ sup_θ p_θ x`,

and the optimum is attained by the *normalized maximum likelihood* distribution
`nml x = (sup_θ p_θ x) / Cₛ`.  Both directions are proved here, in a
division-free multiplicative form that needs no positivity assumptions, and in
logarithmic (bit) form under the natural positivity hypotheses.

## Main Results

* `maxLik`, `shtarkovSum`, `nml` — the basic objects
* `one_le_shtarkovSum`, `shtarkovSum_le_card` — `1 ≤ Cₛ ≤ #Θ`
* `prob_le_shtarkovSum_mul_nml` — achievability: NML pays at most `log₂ Cₛ`
  uniformly over messages *and* sources
* `exists_subprob_ratio_ge` — converse: *every* coding sub-probability `q`
  suffers redundancy at least `log₂ Cₛ` somewhere
* `shtarkov_minimax` — the two combined: the minimax pointwise redundancy is
  exactly `log₂ Cₛ`
* `kraft_converse` — code-length form: every code obeying Kraft has a message on
  which it is `log₂ Cₛ` bits worse than the ideal code for the true source
* `nmlCodeLength_le` — a matching universal code within one bit
* `shtarkovSum_eq_card_of_disjoint_supports` — for classes of mutually singular
  sources the price of universality is exactly `log₂ #Θ`: nothing can be shared

## Application Keywords

universal compression, minimax redundancy, Shtarkov sum, normalized maximum
likelihood, Kraft inequality, price of universality
-/

import Mathlib

open Finset Real

namespace UniversalRedundancy

/-- A parametric class of sources on a finite message space `X`, indexed by `Θ`. -/
structure SourceClass (X : Type*) [Fintype X] (Θ : Type*) where
  /-- probability of message `x` under source `θ` -/
  prob : Θ → X → ℝ
  nonneg : ∀ θ x, 0 ≤ prob θ x
  sum_one : ∀ θ, ∑ x, prob θ x = 1

namespace SourceClass

variable {X : Type*} [Fintype X] {Θ : Type*} (S : SourceClass X Θ)

lemma prob_le_one (θ : Θ) (x : X) : S.prob θ x ≤ 1 := by
  rw [← S.sum_one θ]
  exact Finset.single_le_sum (fun i _ => S.nonneg θ i) (Finset.mem_univ x)

include S in
lemma univ_nonempty [Nonempty Θ] : (univ : Finset X).Nonempty := by
  rcases Finset.eq_empty_or_nonempty (univ : Finset X) with h | h
  · exfalso
    have := S.sum_one (Classical.arbitrary Θ)
    rw [h] at this
    simp at this
  · exact h

/-- The maximum-likelihood envelope of the class: `sup_θ p_θ x`. -/
noncomputable def maxLik (x : X) : ℝ := ⨆ θ, S.prob θ x

lemma bddAbove_prob (x : X) : BddAbove (Set.range fun θ => S.prob θ x) := by
  refine ⟨1, ?_⟩
  rintro _ ⟨θ, rfl⟩
  exact S.prob_le_one θ x

lemma le_maxLik (θ : Θ) (x : X) : S.prob θ x ≤ S.maxLik x :=
  le_ciSup (S.bddAbove_prob x) θ

lemma maxLik_le {x : X} {c : ℝ} [Nonempty Θ] (h : ∀ θ, S.prob θ x ≤ c) :
    S.maxLik x ≤ c := ciSup_le h

lemma maxLik_nonneg [Nonempty Θ] (x : X) : 0 ≤ S.maxLik x :=
  le_trans (S.nonneg (Classical.arbitrary Θ) x) (S.le_maxLik _ x)

lemma maxLik_le_one [Nonempty Θ] (x : X) : S.maxLik x ≤ 1 :=
  S.maxLik_le fun θ => S.prob_le_one θ x

/-- **Shtarkov sum** of the class: `Cₛ = ∑ₓ sup_θ p_θ x`. -/
noncomputable def shtarkovSum : ℝ := ∑ x, S.maxLik x

/-- The Shtarkov sum is at least `1`: universality never *helps*. -/
theorem one_le_shtarkovSum [Nonempty Θ] : 1 ≤ S.shtarkovSum := by
  have h := S.sum_one (Classical.arbitrary Θ)
  calc (1 : ℝ) = ∑ x, S.prob (Classical.arbitrary Θ) x := h.symm
    _ ≤ ∑ x, S.maxLik x := Finset.sum_le_sum fun x _ => S.le_maxLik _ x
    _ = S.shtarkovSum := rfl

theorem shtarkovSum_pos [Nonempty Θ] : 0 < S.shtarkovSum :=
  lt_of_lt_of_le zero_lt_one S.one_le_shtarkovSum

/-- The price of universality never exceeds `log₂ #Θ` bits: `Cₛ ≤ #Θ`. -/
theorem shtarkovSum_le_card [Nonempty Θ] [Fintype Θ] :
    S.shtarkovSum ≤ (Fintype.card Θ : ℝ) := by
  have hstep : ∀ x : X, S.maxLik x ≤ ∑ θ : Θ, S.prob θ x := by
    intro x
    refine S.maxLik_le fun θ => ?_
    exact Finset.single_le_sum (f := fun θ => S.prob θ x)
      (fun i _ => S.nonneg i x) (Finset.mem_univ θ)
  calc S.shtarkovSum ≤ ∑ x : X, ∑ θ : Θ, S.prob θ x :=
        Finset.sum_le_sum fun x _ => hstep x
    _ = ∑ θ : Θ, ∑ x : X, S.prob θ x := Finset.sum_comm
    _ = ∑ _θ : Θ, (1 : ℝ) := by simp [S.sum_one]
    _ = (Fintype.card Θ : ℝ) := by simp

/-- The **normalized maximum likelihood** (Shtarkov) coding distribution. -/
noncomputable def nml (x : X) : ℝ := S.maxLik x / S.shtarkovSum

lemma nml_nonneg [Nonempty Θ] (x : X) : 0 ≤ S.nml x :=
  div_nonneg (S.maxLik_nonneg x) S.shtarkovSum_pos.le

lemma nml_sum_one [Nonempty Θ] : ∑ x, S.nml x = 1 := by
  unfold nml
  rw [← Finset.sum_div]
  exact div_self S.shtarkovSum_pos.ne'

/-- **Achievability.**  Under the NML distribution every source `θ` and every
message `x` incur redundancy at most `log₂ Cₛ`. -/
theorem prob_le_shtarkovSum_mul_nml [Nonempty Θ] (θ : Θ) (x : X) :
    S.prob θ x ≤ S.shtarkovSum * S.nml x := by
  unfold nml
  rw [mul_div_cancel₀ _ S.shtarkovSum_pos.ne']
  exact S.le_maxLik θ x

/-- **Converse.**  For any coding sub-probability `q` (in particular for the
implicit distribution `2 ^ (-ℓ x)` of any Kraft-compliant code) there is a
message where the maximum likelihood beats `q` by the factor `Cₛ`. -/
theorem exists_subprob_ratio_ge [Nonempty Θ] (q : X → ℝ) (hq : ∑ x, q x ≤ 1) :
    ∃ x, q x * S.shtarkovSum ≤ S.maxLik x := by
  by_contra hcon
  push_neg at hcon
  have hlt : ∑ x, S.maxLik x < ∑ x, q x * S.shtarkovSum :=
    Finset.sum_lt_sum_of_nonempty S.univ_nonempty fun x _ => hcon x
  have h2 : ∑ x, q x * S.shtarkovSum = (∑ x, q x) * S.shtarkovSum := by
    rw [Finset.sum_mul]
  have h3 : (∑ x, q x) * S.shtarkovSum ≤ S.shtarkovSum := by
    nlinarith [S.shtarkovSum_pos]
  have hcontra : S.shtarkovSum < S.shtarkovSum := by
    calc S.shtarkovSum = ∑ x, S.maxLik x := rfl
      _ < ∑ x, q x * S.shtarkovSum := hlt
      _ = (∑ x, q x) * S.shtarkovSum := h2
      _ ≤ S.shtarkovSum := h3
  exact absurd hcontra (lt_irrefl _)

/-- Converse, with an explicit witnessing source, for a finite class. -/
theorem exists_source_ratio_ge [Nonempty Θ] [Fintype Θ] (q : X → ℝ)
    (hq : ∑ x, q x ≤ 1) : ∃ x θ, q x * S.shtarkovSum ≤ S.prob θ x := by
  obtain ⟨x, hx⟩ := S.exists_subprob_ratio_ge q hq
  obtain ⟨θ, hθ⟩ : ∃ θ : Θ, S.maxLik x = S.prob θ x := by
    obtain ⟨θ, hθ⟩ := Finite.exists_max fun θ : Θ => S.prob θ x
    exact ⟨θ, le_antisymm (S.maxLik_le fun θ' => hθ θ') (S.le_maxLik θ x)⟩
  exact ⟨x, θ, hθ ▸ hx⟩

/-- **Shtarkov's minimax theorem** (multiplicative form).  The constant `Cₛ` is
simultaneously achievable by one universal distribution and unavoidable for
every coding sub-probability: it *is* the minimax pointwise redundancy factor. -/
theorem shtarkov_minimax [Nonempty Θ] :
    (∀ θ x, S.prob θ x ≤ S.shtarkovSum * S.nml x) ∧
      (∀ q : X → ℝ, (∀ x, 0 ≤ q x) → ∑ x, q x ≤ 1 →
        ∀ c : ℝ, (∀ θ x, S.prob θ x ≤ c * q x) → S.shtarkovSum ≤ c) := by
  refine ⟨S.prob_le_shtarkovSum_mul_nml, ?_⟩
  intro q hq0 hq c hc
  have hmax : ∀ x, S.maxLik x ≤ c * q x := fun x => S.maxLik_le fun θ => hc θ x
  have hsum_nonneg : 0 ≤ ∑ x, q x := Finset.sum_nonneg fun x _ => hq0 x
  have key : S.shtarkovSum ≤ c * ∑ x, q x := by
    calc S.shtarkovSum = ∑ x, S.maxLik x := rfl
      _ ≤ ∑ x, c * q x := Finset.sum_le_sum fun x _ => hmax x
      _ = c * ∑ x, q x := by rw [Finset.mul_sum]
  have hone := S.one_le_shtarkovSum
  have hcpos : 0 < c := by nlinarith
  calc S.shtarkovSum ≤ c * ∑ x, q x := key
    _ ≤ c * 1 := by nlinarith
    _ = c := mul_one c

/-! ## Code-length form

A code with lengths `ℓ : X → ℕ` is *Kraft compliant* if `∑ₓ 2 ^ (-ℓ x) ≤ 1`;
this is exactly the condition for a prefix-free binary code to exist.  The ideal
code for a known source `θ` spends `log₂ (1 / p_θ x)` bits on `x`. -/

/-- Kraft compliance of a length function. -/
def Kraft (ℓ : X → ℕ) : Prop := ∑ x, (2 : ℝ) ^ (-(ℓ x : ℤ)) ≤ 1

/-- **Every** Kraft-compliant code overshoots the ideal code length of the true
source by at least `log₂ Cₛ` bits somewhere: multiplicative form
`2 ^ ℓ x * p_θ x ≥ Cₛ`. -/
theorem kraft_converse [Nonempty Θ] [Fintype Θ] (ℓ : X → ℕ) (h : Kraft ℓ) :
    ∃ x θ, S.shtarkovSum ≤ (2 : ℝ) ^ (ℓ x) * S.prob θ x := by
  obtain ⟨x, θ, hx⟩ := S.exists_source_ratio_ge (fun x => (2 : ℝ) ^ (-(ℓ x : ℤ))) h
  refine ⟨x, θ, ?_⟩
  have hpow : (0 : ℝ) < (2 : ℝ) ^ (ℓ x) := by positivity
  have hinv : (2 : ℝ) ^ (-(ℓ x : ℤ)) = ((2 : ℝ) ^ (ℓ x))⁻¹ := by
    rw [zpow_neg, zpow_natCast]
  rw [hinv, inv_mul_eq_div, div_le_iff₀ hpow] at hx
  calc S.shtarkovSum ≤ S.prob θ x * 2 ^ (ℓ x) := hx
    _ = (2 : ℝ) ^ (ℓ x) * S.prob θ x := by ring

lemma logb_two_pow (k : ℕ) : logb 2 ((2 : ℝ) ^ k) = (k : ℝ) := by
  rw [Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  ring

/-- Bit form of the converse: with positive probabilities, some message costs at
least `log₂ (1 / p_θ x) + log₂ Cₛ` bits. -/
theorem kraft_converse_bits [Nonempty Θ] [Fintype Θ] (ℓ : X → ℕ) (h : Kraft ℓ)
    (hpos : ∀ θ x, 0 < S.prob θ x) :
    ∃ x θ, logb 2 (1 / S.prob θ x) + logb 2 S.shtarkovSum ≤ (ℓ x : ℝ) := by
  obtain ⟨x, θ, hx⟩ := S.kraft_converse ℓ h
  refine ⟨x, θ, ?_⟩
  have hp := hpos θ x
  have h1 : logb 2 S.shtarkovSum ≤ logb 2 ((2 : ℝ) ^ (ℓ x) * S.prob θ x) :=
    Real.logb_le_logb_of_le (by norm_num) S.shtarkovSum_pos hx
  rw [logb_mul (by positivity) hp.ne', logb_two_pow] at h1
  have h3 : logb 2 (1 / S.prob θ x) = -logb 2 (S.prob θ x) := by
    rw [one_div, logb_inv]
  rw [h3]
  linarith

/-- The universal NML code: `ℓ*(x) = ⌈log₂ (1 / nml x)⌉`. -/
noncomputable def nmlCodeLength (x : X) : ℕ := ⌈logb 2 (1 / S.nml x)⌉₊

lemma two_pow_neg_nmlCodeLength_le [Nonempty Θ] (hpos : ∀ x, 0 < S.maxLik x)
    (x : X) : (2 : ℝ) ^ (-(S.nmlCodeLength x : ℤ)) ≤ S.nml x := by
  have hnml : 0 < S.nml x := div_pos (hpos x) S.shtarkovSum_pos
  have hceil : logb 2 (1 / S.nml x) ≤ (S.nmlCodeLength x : ℝ) := Nat.le_ceil _
  have h1 : (1 : ℝ) / S.nml x ≤ (2 : ℝ) ^ (S.nmlCodeLength x : ℕ) := by
    have hb : (1 : ℝ) < 2 := by norm_num
    have h := (Real.logb_le_iff_le_rpow hb (by positivity)).mp hceil
    calc (1 : ℝ) / S.nml x ≤ (2 : ℝ) ^ ((S.nmlCodeLength x : ℕ) : ℝ) := h
      _ = (2 : ℝ) ^ (S.nmlCodeLength x : ℕ) := by rw [Real.rpow_natCast]
  have hpow : (0 : ℝ) < (2 : ℝ) ^ (S.nmlCodeLength x : ℕ) := by positivity
  rw [zpow_neg, zpow_natCast, inv_le_comm₀ hpow hnml]
  calc (S.nml x)⁻¹ = 1 / S.nml x := by rw [one_div]
    _ ≤ (2 : ℝ) ^ (S.nmlCodeLength x : ℕ) := h1

/-- The NML code is Kraft compliant, hence realizable by a prefix-free code. -/
theorem kraft_nmlCodeLength [Nonempty Θ] (hpos : ∀ x, 0 < S.maxLik x) :
    Kraft S.nmlCodeLength := by
  unfold Kraft
  calc ∑ x, (2 : ℝ) ^ (-(S.nmlCodeLength x : ℤ))
      ≤ ∑ x, S.nml x :=
        Finset.sum_le_sum fun x _ => S.two_pow_neg_nmlCodeLength_le hpos x
    _ = 1 := S.nml_sum_one

/-- **Achievability in code lengths.**  The universal NML code is within one bit
of the ideal code for the *true* source, uniformly over sources and messages:
the price of universality is at most `log₂ Cₛ + 1` bits. -/
theorem nmlCodeLength_le [Nonempty Θ] (hpos : ∀ x, 0 < S.maxLik x)
    {θ : Θ} {x : X} (hp : 0 < S.prob θ x) :
    (S.nmlCodeLength x : ℝ) ≤ logb 2 (1 / S.prob θ x) + logb 2 S.shtarkovSum + 1 := by
  have hnml : 0 < S.nml x := div_pos (hpos x) S.shtarkovSum_pos
  have hkey : S.prob θ x ≤ S.shtarkovSum * S.nml x := S.prob_le_shtarkovSum_mul_nml θ x
  have hC := S.shtarkovSum_pos
  have hp' := hp
  have hstep : logb 2 (1 / S.nml x) ≤ logb 2 (1 / S.prob θ x) + logb 2 S.shtarkovSum := by
    have h1 : 1 / (S.shtarkovSum * S.nml x) ≤ 1 / S.prob θ x :=
      one_div_le_one_div_of_le hp' hkey
    have h2 : logb 2 (1 / (S.shtarkovSum * S.nml x)) ≤ logb 2 (1 / S.prob θ x) :=
      Real.logb_le_logb_of_le (by norm_num) (div_pos one_pos (mul_pos hC hnml)) h1
    have h3 : logb 2 (1 / (S.shtarkovSum * S.nml x))
        = logb 2 (1 / S.nml x) - logb 2 S.shtarkovSum := by
      rw [one_div, mul_inv, logb_mul (by positivity) (by positivity), logb_inv, logb_inv,
        one_div, logb_inv]
      ring
    linarith
  have hnmlle : S.nml x ≤ 1 := by
    have hs := S.nml_sum_one
    have hle : S.nml x ≤ ∑ y, S.nml y :=
      Finset.single_le_sum (fun y _ => S.nml_nonneg y) (Finset.mem_univ x)
    linarith
  have hceil : (S.nmlCodeLength x : ℝ) < logb 2 (1 / S.nml x) + 1 := by
    refine Nat.ceil_lt_add_one ?_
    have h1 : (1 : ℝ) ≤ 1 / S.nml x := by
      rw [le_div_iff₀ hnml, one_mul]; exact hnmlle
    exact Real.logb_nonneg (by norm_num) h1
  linarith

/-! ## The extreme case: mutually singular sources

If distinct sources live on disjoint supports, nothing can be shared and the
price of universality is the full `log₂ #Θ` bits. -/

/-- If the class admits a partition of the message space into per-source
supports, then `Cₛ = #Θ` exactly: the universal code must spend `log₂ #Θ` extra
bits, i.e. it must effectively *name* the source. -/
theorem shtarkovSum_eq_card_of_disjoint_supports [Nonempty Θ] [Fintype Θ]
    (supp : Θ → Finset X) (hdisj : ∀ θ θ', θ ≠ θ' → Disjoint (supp θ) (supp θ'))
    (hmass : ∀ θ, ∑ x ∈ supp θ, S.prob θ x = 1) :
    S.shtarkovSum = (Fintype.card Θ : ℝ) := by
  classical
  refine le_antisymm S.shtarkovSum_le_card ?_
  have hlow : (Fintype.card Θ : ℝ) = ∑ θ : Θ, ∑ x ∈ supp θ, S.prob θ x := by
    simp [hmass]
  rw [hlow]
  have hstep : ∀ θ : Θ, ∑ x ∈ supp θ, S.prob θ x ≤ ∑ x ∈ supp θ, S.maxLik x :=
    fun θ => Finset.sum_le_sum fun x _ => S.le_maxLik θ x
  have hsum : ∑ θ : Θ, ∑ x ∈ supp θ, S.maxLik x ≤ S.shtarkovSum := by
    have hdisj' : ∀ θ ∈ (univ : Finset Θ), ∀ θ' ∈ (univ : Finset Θ), θ ≠ θ' →
        Disjoint (supp θ) (supp θ') := fun θ _ θ' _ h => hdisj θ θ' h
    have hbiUnion : ∑ θ : Θ, ∑ x ∈ supp θ, S.maxLik x
        = ∑ x ∈ (univ : Finset Θ).biUnion supp, S.maxLik x :=
      (Finset.sum_biUnion hdisj').symm
    rw [hbiUnion]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      fun x _ _ => S.maxLik_nonneg x
  calc ∑ θ : Θ, ∑ x ∈ supp θ, S.prob θ x
      ≤ ∑ θ : Θ, ∑ x ∈ supp θ, S.maxLik x := Finset.sum_le_sum fun θ _ => hstep θ
    _ ≤ S.shtarkovSum := hsum

end SourceClass

end UniversalRedundancy