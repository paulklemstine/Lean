import NumberTheory.RLHFZetaEulerPolicy

/-!
# The full Euler product of an aligned policy: arbitrarily many primes

`NumberTheory.RLHFZetaEulerPolicy` treated the two-prime smooth response space.  Here we
carry the construction to a response space built from `k` primes with individually bounded
exponents,

`Ω = Π i, Fin (A i + 1)`,   `n(a) = ∏ i, (P i) ^ (a i)`,

and the Dirichlet reward `r(n) = -β s log n`.  The results:

* `RLHF.zetaWeight_prod` — complete multiplicativity of `n ↦ n^{-s}` over finite products.
* `RLHF.zetaSumMulti_eq_prod` — the **Euler product**: the partition function of the
  aligned policy factors as `∏ i, localZeta s (P i) (A i)`.
* `RLHF.gibbs_multi_independent` — the aligned policy is the product of its per-prime
  marginals: *all* prime exponents are mutually independent under RLHF alignment.
* `RLHF.freeEnergy_multi_additive` — the RLHF free energy is a sum of per-prime terms.
* `RLHF.freeEnergy_multi_lt_euler` — a Mertens-type strict upper bound by the genuine
  Euler factors `-∑ log (1 - P i ^ {-s})`.
-/

namespace RLHF

open Finset

variable {k : ℕ}

/-! ## 1. Multi-prime smooth response spaces -/

/-- The multi-exponent response space. -/
abbrev SmoothMulti (A : Fin k → ℕ) := (i : Fin k) → Fin (A i + 1)

/-- The integer named by a tuple of prime exponents. -/
def smoothValMulti (P : Fin k → ℕ) {A : Fin k → ℕ} (a : SmoothMulti A) : ℕ :=
  ∏ i, P i ^ (a i : ℕ)

theorem smoothValMulti_pos {P : Fin k → ℕ} {A : Fin k → ℕ} (hP : ∀ i, 0 < P i)
    (a : SmoothMulti A) : 0 < smoothValMulti P a :=
  Finset.prod_pos (fun i _ => pow_pos (hP i) _)

/-- Complete multiplicativity of the zeta weights over finite products. -/
theorem zetaWeight_prod {s : ℝ} {ι : Type*} (t : Finset ι) (f : ι → ℕ)
    (hf : ∀ i ∈ t, 0 < f i) :
    zetaWeight s (∏ i ∈ t, f i) = ∏ i ∈ t, zetaWeight s (f i) := by
  classical
  induction t using Finset.induction with
  | empty => simp [zetaWeight]
  | insert j t hj ih =>
      have hjpos : 0 < f j := hf j (mem_insert_self _ _)
      have hrest : ∀ i ∈ t, 0 < f i := fun i hi => hf i (mem_insert_of_mem hi)
      have hprodpos : 0 < ∏ i ∈ t, f i := Finset.prod_pos hrest
      rw [Finset.prod_insert hj, Finset.prod_insert hj,
        zetaWeight_mul hjpos hprodpos, ih hrest]

/-! ## 2. The Euler product for the partition function -/

/-- The multi-prime truncated zeta sum. -/
noncomputable def zetaSumMulti (s : ℝ) (P : Fin k → ℕ) (A : Fin k → ℕ) : ℝ :=
  ∑ a : SmoothMulti A, zetaWeight s (smoothValMulti P a)

/-- **Euler product.**  The normalizing constant of the aligned policy factors over the
primes into local (per-prime) partition functions. -/
theorem zetaSumMulti_eq_prod {s : ℝ} {P : Fin k → ℕ} {A : Fin k → ℕ} (hP : ∀ i, 0 < P i) :
    zetaSumMulti s P A = ∏ i, localZeta s (P i) (A i) := by
  classical
  unfold zetaSumMulti localZeta
  rw [Finset.prod_univ_sum, Fintype.piFinset_univ]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  unfold smoothValMulti
  exact zetaWeight_prod _ _ (fun i _ => pow_pos (hP i) _)

theorem zetaSumMulti_pos {s : ℝ} {P : Fin k → ℕ} {A : Fin k → ℕ} (hP : ∀ i, 0 < P i) :
    0 < zetaSumMulti s P A := by
  rw [zetaSumMulti_eq_prod hP]
  exact Finset.prod_pos (fun i _ => localZeta_pos (hP i))

/-! ## 3. The aligned policy and its independence structure -/

/-- The Dirichlet reward on the multi-prime response space. -/
noncomputable def zetaRewardMulti (β s : ℝ) (P : Fin k → ℕ) {A : Fin k → ℕ} :
    SmoothMulti A → ℝ :=
  fun a => -(β * s) * Real.log (smoothValMulti P a : ℝ)

theorem exp_zetaRewardMulti {β s : ℝ} {P : Fin k → ℕ} {A : Fin k → ℕ} (hβ : 0 < β)
    (hP : ∀ i, 0 < P i) (a : SmoothMulti A) :
    Real.exp (zetaRewardMulti β s P a / β) = zetaWeight s (smoothValMulti P a) := by
  have hn : (0 : ℝ) < (smoothValMulti P a : ℝ) := by
    exact_mod_cast smoothValMulti_pos hP a
  unfold zetaRewardMulti zetaWeight
  rw [Real.rpow_def_of_pos hn]
  congr 1
  field_simp

theorem partition_zetaRewardMulti {β s : ℝ} {P : Fin k → ℕ} {A : Fin k → ℕ} (hβ : 0 < β)
    (hP : ∀ i, 0 < P i) :
    partition β (zetaRewardMulti (A := A) β s P) (uniformDist (SmoothMulti A))
      = zetaSumMulti s P A / (Fintype.card (SmoothMulti A) : ℝ) := by
  unfold partition zetaSumMulti uniformDist
  rw [Finset.sum_div]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [exp_zetaRewardMulti hβ hP]
  ring

/-- The optimal RLHF policy for the Dirichlet reward is the multi-prime truncated zeta
distribution. -/
theorem gibbs_multi_policy {β s : ℝ} {P : Fin k → ℕ} {A : Fin k → ℕ} (hβ : 0 < β)
    (hP : ∀ i, 0 < P i) (a : SmoothMulti A) :
    gibbsPolicy β (zetaRewardMulti β s P) (uniformDist (SmoothMulti A)) a
      = zetaWeight s (smoothValMulti P a) / zetaSumMulti s P A := by
  have hcard : (0 : ℝ) < (Fintype.card (SmoothMulti A) : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have hZ : (0 : ℝ) < zetaSumMulti s P A := zetaSumMulti_pos hP
  unfold gibbsPolicy
  rw [partition_zetaRewardMulti hβ hP, exp_zetaRewardMulti hβ hP]
  unfold uniformDist
  field_simp

/-- **Total independence of prime exponents under alignment.**  The optimal policy is the
product of its per-prime marginals — the probabilistic form of the Euler product. -/
theorem gibbs_multi_independent {β s : ℝ} {P : Fin k → ℕ} {A : Fin k → ℕ} (hβ : 0 < β)
    (hP : ∀ i, 0 < P i) (a : SmoothMulti A) :
    gibbsPolicy β (zetaRewardMulti β s P) (uniformDist (SmoothMulti A)) a
      = ∏ i, (zetaWeight s (P i ^ (a i : ℕ)) / localZeta s (P i) (A i)) := by
  rw [gibbs_multi_policy hβ hP, zetaSumMulti_eq_prod hP]
  unfold smoothValMulti
  rw [zetaWeight_prod _ _ (fun i _ => pow_pos (hP i) _), ← Finset.prod_div_distrib]

/-! ## 4. Additivity of the free energy over the primes -/

/-- **Euler-additivity of the RLHF free energy over an arbitrary set of primes.** -/
theorem freeEnergy_multi_additive {β s : ℝ} {P : Fin k → ℕ} {A : Fin k → ℕ} (hβ : 0 < β)
    (hP : ∀ i, 0 < P i) :
    β * Real.log (partition β (zetaRewardMulti (A := A) β s P) (uniformDist (SmoothMulti A)))
      = β * ((∑ i, Real.log (localZeta s (P i) (A i)))
          - Real.log (Fintype.card (SmoothMulti A) : ℝ)) := by
  have hcard : (0 : ℝ) < (Fintype.card (SmoothMulti A) : ℝ) := by
    exact_mod_cast Fintype.card_pos
  have hZ : (0 : ℝ) < zetaSumMulti s P A := zetaSumMulti_pos hP
  rw [partition_zetaRewardMulti hβ hP, Real.log_div (ne_of_gt hZ) (ne_of_gt hcard),
    zetaSumMulti_eq_prod hP]
  congr 2
  exact Real.log_prod (fun i _ => ne_of_gt (localZeta_pos (hP i)))

/-- **Mertens-type ceiling.**  The per-prime contributions to the free energy are strictly
dominated by the genuine Euler factors of the Dirichlet series. -/
theorem freeEnergy_multi_lt_euler {s : ℝ} {P : Fin k → ℕ} {A : Fin k → ℕ}
    (hk : 0 < k) (hP : ∀ i, 2 ≤ P i) (hs : 0 < s) :
    (∑ i, Real.log (localZeta s (P i) (A i)))
      < -∑ i, Real.log (1 - zetaWeight s (P i)) := by
  have hne : (univ : Finset (Fin k)).Nonempty := by
    rw [Finset.univ_nonempty_iff]
    exact Fin.pos_iff_nonempty.mp hk
  have hterm : ∀ i ∈ (univ : Finset (Fin k)),
      Real.log (localZeta s (P i) (A i)) < -Real.log (1 - zetaWeight s (P i)) := by
    intro i _
    have hp0 : 0 < P i := by have := hP i; omega
    have hlt1 : zetaWeight s (P i) < 1 := zetaWeight_lt_one (hP i) hs
    have hpos : 0 < 1 - zetaWeight s (P i) := by linarith
    have hL : 0 < localZeta s (P i) (A i) := localZeta_pos hp0
    have hbound : localZeta s (P i) (A i) < (1 - zetaWeight s (P i))⁻¹ :=
      localZeta_lt_euler_factor (hP i) hs
    have := Real.log_lt_log hL hbound
    rwa [Real.log_inv] at this
  have := Finset.sum_lt_sum_of_nonempty hne hterm
  simpa [Finset.sum_neg_distrib] using this

end RLHF