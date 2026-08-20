import Combinatorics.RLHFBooleanLattice

/-!
# Supermodular neurosymbolic rewards: FKG positive association and stochastic dominance

Third research cycle on the RLHF/InstructGPT objective over the Boolean lattice
`Finset (Fin n)`.  Cycles 1–2 treated *additive* (per-feature) rewards, for which the
aligned policy is a product measure.  Real neurosymbolic reward models are **not**
additive: a rule bonus such as "give `c` extra reward if all premises of rule `R` are
satisfied" couples the features.  The right combinatorial class is *supermodularity*
`r S + r T ≤ r (S ∩ T) + r (S ∪ T)`.

Main results (all `sorry`-free):

* `sizeReward_supermodular`, `ruleBonus_supermodular`, `Supermodular.add`,
  `Supermodular.smul_nonneg` — the counting reward is modular, a rule bonus over a
  principal filter is supermodular, and supermodularity is a convex cone, so every
  "counting + rule bonuses" neurosymbolic reward is supermodular.
* `gibbsPolicy_logSupermodular` — the KL-regularized aligned policy of a supermodular
  reward is a **log-supermodular (FKG) measure** on the Boolean lattice.
* `gibbs_positive_association` — hence, by the Fortuin–Kasteleyn–Ginibre inequality,
  any two monotone observables are *positively correlated* under the aligned policy:
  `𝔼[f]·𝔼[g] ≤ 𝔼[f g]`.  Alignment with synergistic symbolic rules provably *entangles*
  features; it can never make monotone features negatively correlated.
* `feature_positive_correlation` — the concrete two-feature instance.
* `gibbs_stochastic_dominance` — via Holley's inequality, if the reward is monotone then
  the aligned policy stochastically dominates the SFT reference: *every* monotone
  observable increases under alignment, uniformly in `β`.

The cross-domain content: the RLHF objective (statistics/optimization) is analysed with
lattice combinatorics (the four functions theorem of Ahlswede–Daykin and its FKG/Holley
corollaries) rather than with analysis.
-/

namespace RLHFCombinatorics

open Finset RLHF

section Supermodular

variable {n : ℕ}

/-- A reward is *supermodular* on the Boolean lattice of feature sets when features are
(weakly) synergistic: `r S + r T ≤ r (S ∩ T) + r (S ∪ T)`. -/
def Supermodular (r : Finset (Fin n) → ℝ) : Prop :=
  ∀ S T : Finset (Fin n), r S + r T ≤ r (S ∩ T) + r (S ∪ T)

theorem Supermodular.add {r s : Finset (Fin n) → ℝ} (hr : Supermodular r)
    (hs : Supermodular s) : Supermodular (fun S => r S + s S) := by
  intro S T
  have h1 := hr S T
  have h2 := hs S T
  simp only
  linarith

theorem Supermodular.smul_nonneg {r : Finset (Fin n) → ℝ} {c : ℝ} (hc : 0 ≤ c)
    (hr : Supermodular r) : Supermodular (fun S => c * r S) := by
  intro S T
  have h := hr S T
  simp only
  nlinarith

/-- The counting reward `a|S|` is modular, hence supermodular (for every sign of `a`). -/
theorem sizeReward_supermodular (n : ℕ) (a : ℝ) : Supermodular (sizeReward n a) := by
  intro S T
  have hcard : (S ∩ T).card + (S ∪ T).card = S.card + T.card :=
    Finset.card_inter_add_card_union S T
  have : ((S ∩ T).card : ℝ) + ((S ∪ T).card : ℝ) = (S.card : ℝ) + (T.card : ℝ) := by
    exact_mod_cast hcard
  have key : a * ((S ∩ T).card : ℝ) + a * ((S ∪ T).card : ℝ)
      = a * (S.card : ℝ) + a * (T.card : ℝ) := by
    rw [← mul_add, ← mul_add, this]
  simp only [sizeReward]
  linarith

/-- A neurosymbolic *rule bonus*: reward `c ≥ 0` exactly when every premise in `R` fires. -/
noncomputable def ruleBonus (R : Finset (Fin n)) (c : ℝ) : Finset (Fin n) → ℝ :=
  fun S => if R ⊆ S then c else 0

/-- **A rule bonus is supermodular.**  Conjunctive symbolic rules create synergies. -/
theorem ruleBonus_supermodular (R : Finset (Fin n)) {c : ℝ} (hc : 0 ≤ c) :
    Supermodular (ruleBonus R c) := by
  intro S T
  by_cases hS : R ⊆ S <;> by_cases hT : R ⊆ T <;>
    simp only [ruleBonus, hS, hT, if_true, if_false]
  · have h1 : R ⊆ S ∩ T := Finset.subset_inter hS hT
    have h2 : R ⊆ S ∪ T := hS.trans Finset.subset_union_left
    simp [h1, h2]
  · have h2 : R ⊆ S ∪ T := hS.trans Finset.subset_union_left
    simp [h2]
    positivity
  · have h2 : R ⊆ S ∪ T := hT.trans Finset.subset_union_right
    simp [h2]
    positivity
  · by_cases h1 : R ⊆ S ∩ T <;> by_cases h2 : R ⊆ S ∪ T <;> simp [h1, h2, hc]

/-! ## The aligned policy of a supermodular reward is log-supermodular -/

theorem gibbsPolicy_uniform_apply {β : ℝ} (r : Finset (Fin n) → ℝ) (S : Finset (Fin n)) :
    gibbsPolicy β r (uniformSubsets n) S
      = (1 / 2 ^ n) * Real.exp (r S / β) / partition β r (uniformSubsets n) := rfl

/-- **Log-supermodularity (the FKG lattice condition) of the aligned policy.** -/
theorem gibbsPolicy_logSupermodular {β : ℝ} (hβ : 0 < β) {r : Finset (Fin n) → ℝ}
    (hr : Supermodular r) (S T : Finset (Fin n)) :
    gibbsPolicy β r (uniformSubsets n) S * gibbsPolicy β r (uniformSubsets n) T
      ≤ gibbsPolicy β r (uniformSubsets n) (S ∩ T)
        * gibbsPolicy β r (uniformSubsets n) (S ∪ T) := by
  have hZ : 0 < partition β r (uniformSubsets n) :=
    partition_pos (uniformSubsets_isPosDist n)
  have hexp : Real.exp (r S / β) * Real.exp (r T / β)
      ≤ Real.exp (r (S ∩ T) / β) * Real.exp (r (S ∪ T) / β) := by
    rw [← Real.exp_add, ← Real.exp_add, Real.exp_le_exp, ← add_div, ← add_div]
    exact div_le_div_of_nonneg_right (hr S T) hβ.le
  have hc : (0:ℝ) ≤ (1 / 2 ^ n : ℝ) * (1 / 2 ^ n : ℝ) := by positivity
  have hnum : ((1 / 2 ^ n : ℝ) * Real.exp (r S / β)) * ((1 / 2 ^ n : ℝ) * Real.exp (r T / β))
      ≤ ((1 / 2 ^ n : ℝ) * Real.exp (r (S ∩ T) / β))
        * ((1 / 2 ^ n : ℝ) * Real.exp (r (S ∪ T) / β)) := by
    nlinarith [hexp, hc]
  rw [gibbsPolicy_uniform_apply, gibbsPolicy_uniform_apply, gibbsPolicy_uniform_apply,
    gibbsPolicy_uniform_apply, div_mul_div_comm, div_mul_div_comm]
  gcongr

/-- **FKG positive association of the aligned policy.**  For a supermodular reward, any two
monotone nonnegative observables are positively correlated under the RLHF-optimal policy. -/
theorem gibbs_positive_association {β : ℝ} (hβ : 0 < β) {r : Finset (Fin n) → ℝ}
    (hr : Supermodular r) {f g : Finset (Fin n) → ℝ} (hf0 : 0 ≤ f) (hg0 : 0 ≤ g)
    (hf : Monotone f) (hg : Monotone g) :
    (∑ S, gibbsPolicy β r (uniformSubsets n) S * f S)
        * (∑ S, gibbsPolicy β r (uniformSubsets n) S * g S)
      ≤ ∑ S, gibbsPolicy β r (uniformSubsets n) S * (f S * g S) := by
  have hgib : IsPosDist (gibbsPolicy β r (uniformSubsets n)) :=
    gibbsPolicy_isPosDist (uniformSubsets_isPosDist n)
  have hmu : (0 : Finset (Fin n) → ℝ) ≤ gibbsPolicy β r (uniformSubsets n) :=
    fun S => (hgib.1 S).le
  have hlat : ∀ a b : Finset (Fin n),
      gibbsPolicy β r (uniformSubsets n) a * gibbsPolicy β r (uniformSubsets n) b
        ≤ gibbsPolicy β r (uniformSubsets n) (a ⊓ b)
          * gibbsPolicy β r (uniformSubsets n) (a ⊔ b) :=
    fun a b => gibbsPolicy_logSupermodular hβ hr a b
  have h := fkg f g (gibbsPolicy β r (uniformSubsets n)) hmu hf0 hg0 hf hg hlat
  rwa [hgib.2, one_mul] at h

/-- The indicator of "feature `i` fired" is a monotone observable. -/
theorem monotone_featureIndicator (i : Fin n) :
    Monotone (fun S : Finset (Fin n) => if i ∈ S then (1:ℝ) else 0) := by
  intro S T hST
  by_cases hi : i ∈ S
  · simp [hi, hST hi]
  · by_cases hj : i ∈ T <;> simp [hi, hj]

/-- **Feature entanglement.**  Under the aligned policy of any supermodular neurosymbolic
reward, the events "feature `i` fires" and "feature `j` fires" are positively correlated. -/
theorem feature_positive_correlation {β : ℝ} (hβ : 0 < β) {r : Finset (Fin n) → ℝ}
    (hr : Supermodular r) (i j : Fin n) :
    (∑ S, gibbsPolicy β r (uniformSubsets n) S * (if i ∈ S then (1:ℝ) else 0))
        * (∑ S, gibbsPolicy β r (uniformSubsets n) S * (if j ∈ S then (1:ℝ) else 0))
      ≤ ∑ S, gibbsPolicy β r (uniformSubsets n) S
          * ((if i ∈ S then (1:ℝ) else 0) * (if j ∈ S then (1:ℝ) else 0)) := by
  refine gibbs_positive_association hβ hr ?_ ?_ (monotone_featureIndicator i)
    (monotone_featureIndicator j)
  · intro S; by_cases hi : i ∈ S <;> simp [hi]
  · intro S; by_cases hj : j ∈ S <;> simp [hj]

/-! ## Stochastic dominance of the aligned policy over the SFT reference -/

/-- For a monotone reward the aligned policy is a monotone measure on the lattice. -/
theorem gibbsPolicy_monotone {β : ℝ} (hβ : 0 < β) {r : Finset (Fin n) → ℝ}
    (hr : Monotone r) : Monotone (gibbsPolicy β r (uniformSubsets n)) := by
  have hZ : 0 < partition β r (uniformSubsets n) :=
    partition_pos (uniformSubsets_isPosDist n)
  intro S T hST
  rw [gibbsPolicy_uniform_apply, gibbsPolicy_uniform_apply]
  have hexp : Real.exp (r S / β) ≤ Real.exp (r T / β) := by
    rw [Real.exp_le_exp]
    exact div_le_div_of_nonneg_right (hr hST) hβ.le
  have hc : (0:ℝ) < 1 / 2 ^ n := by positivity
  gcongr

/-- **Stochastic dominance.**  If the neurosymbolic reward is monotone in the feature set,
then the RLHF-aligned policy dominates the SFT reference: the expectation of *every*
monotone nonnegative observable increases under alignment. -/
theorem gibbs_stochastic_dominance {β : ℝ} (hβ : 0 < β) {r : Finset (Fin n) → ℝ}
    (hr : Monotone r) {μ : Finset (Fin n) → ℝ} (hμ0 : 0 ≤ μ) (hμ : Monotone μ) :
    ∑ S, μ S * uniformSubsets n S ≤ ∑ S, μ S * gibbsPolicy β r (uniformSubsets n) S := by
  have hunif := uniformSubsets_isPosDist n
  have hgib : IsPosDist (gibbsPolicy β r (uniformSubsets n)) :=
    gibbsPolicy_isPosDist hunif
  have hf0 : (0 : Finset (Fin n) → ℝ) ≤ uniformSubsets n := fun S => (hunif.1 S).le
  have hg0 : (0 : Finset (Fin n) → ℝ) ≤ gibbsPolicy β r (uniformSubsets n) :=
    fun S => (hgib.1 S).le
  have hsum : ∑ S, uniformSubsets n S = ∑ S, gibbsPolicy β r (uniformSubsets n) S := by
    rw [hunif.2, hgib.2]
  have hcond : ∀ a b : Finset (Fin n),
      uniformSubsets n a * gibbsPolicy β r (uniformSubsets n) b
        ≤ uniformSubsets n (a ⊓ b) * gibbsPolicy β r (uniformSubsets n) (a ⊔ b) := by
    intro a b
    have hmono := gibbsPolicy_monotone hβ hr (le_sup_right : b ≤ a ⊔ b)
    have hu : uniformSubsets n a = uniformSubsets n (a ⊓ b) := rfl
    rw [hu]
    exact mul_le_mul_of_nonneg_left hmono (hf0 _)
  exact holley (uniformSubsets n) (gibbsPolicy β r (uniformSubsets n)) μ hμ0 hf0 hg0 hμ
    hsum hcond

end Supermodular

end RLHFCombinatorics