/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality III: first-order Markov sources

Third instalment of the thread (after `UniversalRedundancy.Core` and
`UniversalRedundancy.Types`).  Memoryless sources were shown to cost at most
`#A · log₂ (n+1)` bits of universality.  Here we build the class of first-order
Markov chains — the standard model of *sources with memory* — from scratch,
including the (non-trivial) proof that the chain measure is a probability
measure on `Aⁿ⁺¹`, and bound its price of universality.

## Central Idea

The likelihood of a Markov chain factors as

`p_θ(x) = ν(x₀) · ∏_{j<n} T(x_j, x_{j+1})`,

so it depends on `x` only through the first symbol and the matrix of *transition
counts*.  That is a statistic with at most `#A · (n+1)^(#A·#A)` values, and the
abstract counting theorem `shtarkovSum_le_of_product_form` converts this
directly into the redundancy bound

`Cₛ ≤ #A · (n+1)^(#A²)`,  i.e.  `price ≤ log₂ #A + #A² · log₂ (n+1)` bits.

## Main Results

* `markovChain_sum_one` — the Markov chain measure on `Aⁿ⁺¹` is normalized
  (proved by induction on `n`, propagating the initial law through the kernel)
* `markovClass` — the source class of first-order Markov chains
* `shtarkovSum_markovClass_le` — `Cₛ ≤ #A · (n+1)^(#A · #A)`
* `markov_redundancy_bits_le` — bit form: one universal code is within
  `log₂ #A + #A² · log₂ (n+1) + 1` bits of the code tuned to the true chain,
  simultaneously for every chain and every message

## Application Keywords

Markov source, transition counts, universal coding with memory, Rissanen
redundancy, sufficient statistic
-/

import MachineLearning.UniversalRedundancy.Types

open Finset Real

namespace UniversalRedundancy

variable {A : Type*} [Fintype A] [DecidableEq A]

omit [DecidableEq A] in
/-- **The Markov chain measure is a probability measure.**  For any stochastic
kernel `trans` and any initial law `ν`, the induced law on words of length
`n + 1` has total mass `1`.  Proved by induction on `n`, pushing the initial law
through the kernel. -/
theorem markovChain_sum_one (trans : A → A → ℝ) (htrans : ∀ a, ∑ b, trans a b = 1) :
    ∀ (n : ℕ) (ν : A → ℝ), (∑ a, ν a = 1) →
      ∑ x : Fin (n + 1) → A, ν (x 0) * ∏ j : Fin n, trans (x j.castSucc) (x j.succ) = 1 := by
  intro n
  induction n with
  | zero =>
      intro ν hν
      simp only [Finset.univ_eq_empty, Finset.prod_empty, mul_one]
      rw [← hν]
      exact Fintype.sum_equiv (Equiv.funUnique (Fin 1) A) _ _ fun x => rfl
  | succ k ih =>
      intro ν hν
      have hsplit : ∑ x : Fin (k + 2) → A,
          ν (x 0) * ∏ j : Fin (k + 1), trans (x j.castSucc) (x j.succ)
          = ∑ a : A, ∑ y : Fin (k + 1) → A,
              ν a * trans a (y 0) * ∏ i : Fin k, trans (y i.castSucc) (y i.succ) := by
        rw [← Fintype.sum_prod_type']
        refine Fintype.sum_equiv (Fin.consEquiv (fun _ : Fin (k + 2) => A)).symm _ _
          fun x => ?_
        simp only [Fin.consEquiv_symm_apply]
        rw [Fin.prod_univ_succ]
        have h0 : trans (x (0 : Fin (k + 1)).castSucc) (x (0 : Fin (k + 1)).succ)
            = trans (x 0) (Fin.tail x 0) := by
          simp only [Fin.tail, Fin.castSucc_zero]
        have hstep : ∀ i : Fin k,
            trans (x i.succ.castSucc) (x i.succ.succ)
              = trans (Fin.tail x i.castSucc) (Fin.tail x i.succ) := by
          intro i
          simp only [Fin.tail, Fin.succ_castSucc]
        rw [h0, Finset.prod_congr rfl fun i _ => hstep i]
        ring
      rw [hsplit]
      have hswap : ∑ a : A, ∑ y : Fin (k + 1) → A,
            ν a * trans a (y 0) * ∏ i : Fin k, trans (y i.castSucc) (y i.succ)
          = ∑ y : Fin (k + 1) → A,
            (∑ a : A, ν a * trans a (y 0)) * ∏ i : Fin k, trans (y i.castSucc) (y i.succ) := by
        rw [Finset.sum_comm]
        exact Finset.sum_congr rfl fun y _ => by rw [Finset.sum_mul]
      rw [hswap]
      have hν' : ∑ b : A, (∑ a : A, ν a * trans a b) = 1 := by
        rw [Finset.sum_comm]
        calc ∑ a : A, ∑ b : A, ν a * trans a b
            = ∑ a : A, ν a * ∑ b : A, trans a b := by
              exact Finset.sum_congr rfl fun a _ => by rw [Finset.mul_sum]
          _ = ∑ a : A, ν a := by simp [htrans]
          _ = 1 := hν
      exact ih (fun b => ∑ a : A, ν a * trans a b) hν'

/-- The parameter of a first-order Markov source: an initial law together with a
stochastic transition kernel. -/
def MarkovParam (A : Type*) [Fintype A] : Type _ :=
  {θ : (A → ℝ) × (A → A → ℝ) //
    ((∀ a, 0 ≤ θ.1 a) ∧ ∑ a, θ.1 a = 1) ∧ ∀ a, (∀ b, 0 ≤ θ.2 a b) ∧ ∑ b, θ.2 a b = 1}

instance [Nonempty A] : Nonempty (MarkovParam A) := by
  have hcard : (Fintype.card A : ℝ) ≠ 0 := by
    have : 0 < Fintype.card A := Fintype.card_pos
    positivity
  refine ⟨⟨(fun _ => (Fintype.card A : ℝ)⁻¹, fun _ _ => (Fintype.card A : ℝ)⁻¹), ⟨⟨fun _ => ?_, ?_⟩,
    fun _ => ⟨fun _ => ?_, ?_⟩⟩⟩⟩
  · positivity
  · rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp
  · positivity
  · rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp

/-- The class of first-order Markov sources on messages of length `n + 1`. -/
noncomputable def markovClass (A : Type*) [Fintype A] [DecidableEq A] (n : ℕ) :
    SourceClass (Fin (n + 1) → A) (MarkovParam A) where
  prob θ x := θ.1.1 (x 0) * ∏ j : Fin n, θ.1.2 (x j.castSucc) (x j.succ)
  nonneg θ x :=
    mul_nonneg (θ.2.1.1 (x 0)) (Finset.prod_nonneg fun j _ => (θ.2.2 (x j.castSucc)).1 _)
  sum_one θ := markovChain_sum_one θ.1.2 (fun a => (θ.2.2 a).2) n θ.1.1 θ.2.1.2

/-- **Markov sources: `Cₛ ≤ #A · (n+1)^(#A · #A)`.**  The price of universality
over the whole first-order Markov class is at most
`log₂ #A + #A² · log₂ (n+1)` bits — still only logarithmic in the message
length, with the class complexity `#A²` entering as a multiplier. -/
theorem shtarkovSum_markovClass_le [Nonempty A] (n : ℕ) :
    (markovClass A n).shtarkovSum
      ≤ (Fintype.card A : ℝ) * ((n + 1 : ℕ) : ℝ) ^ (Fintype.card A * Fintype.card A) := by
  classical
  have h := (markovClass A n).shtarkovSum_le_of_product_form
    (B := A × A) (C := A) (m := n)
    (feat := fun x j => (x j.castSucc, x j.succ)) (init := fun x => x 0)
    (g := fun θ ab => θ.1.2 ab.1 ab.2) (h := fun θ a => θ.1.1 a)
    (by intro θ x; rfl)
  rwa [Fintype.card_prod] at h

/-- Every message has positive maximum likelihood in the Markov class (witness:
the uniform chain), so the NML code of the class is well defined. -/
lemma maxLik_markovClass_pos [Nonempty A] (n : ℕ) (x : Fin (n + 1) → A) :
    0 < (markovClass A n).maxLik x := by
  have hcard : (0 : ℝ) < (Fintype.card A : ℝ) := by exact_mod_cast Fintype.card_pos
  set θ : MarkovParam A :=
    ⟨(fun _ => (Fintype.card A : ℝ)⁻¹, fun _ _ => (Fintype.card A : ℝ)⁻¹),
      ⟨⟨fun _ => by positivity, by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp⟩,
        fun _ => ⟨fun _ => by positivity, by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp⟩⟩⟩ with hθ
  have hp : 0 < (markovClass A n).prob θ x := by
    simp only [markovClass, hθ]
    exact mul_pos (by positivity) (Finset.prod_pos fun j _ => by positivity)
  exact lt_of_lt_of_le hp ((markovClass A n).le_maxLik θ x)

/-- **The price of universality for Markov sources, in bits.**  One universal
code is within `log₂ #A + #A² · log₂ (n+1) + 1` bits of the code tailored to the
true chain, uniformly over chains and messages. -/
theorem markov_redundancy_bits_le [Nonempty A] (n : ℕ) (θ : MarkovParam A)
    (x : Fin (n + 1) → A) (hx : 0 < (markovClass A n).prob θ x) :
    ((markovClass A n).nmlCodeLength x : ℝ)
      ≤ logb 2 (1 / (markovClass A n).prob θ x)
        + (logb 2 (Fintype.card A)
            + (Fintype.card A : ℝ) * (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1)) + 1 := by
  have hcard : (0 : ℝ) < (Fintype.card A : ℝ) := by exact_mod_cast Fintype.card_pos
  have h1 := (markovClass A n).nmlCodeLength_le (maxLik_markovClass_pos n) hx
  have hC := shtarkovSum_markovClass_le (A := A) n
  have hbase : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
  rw [hbase] at hC
  have hle : logb 2 (markovClass A n).shtarkovSum
      ≤ logb 2 ((Fintype.card A : ℝ) * ((n : ℝ) + 1) ^ (Fintype.card A * Fintype.card A)) :=
    Real.logb_le_logb_of_le (by norm_num) (markovClass A n).shtarkovSum_pos hC
  rw [Real.logb_mul (ne_of_gt hcard) (by positivity), Real.logb_pow] at hle
  push_cast at hle
  linarith

end UniversalRedundancy