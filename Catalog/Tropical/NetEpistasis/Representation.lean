/-
# Representation: which pruning-cost profiles are tropically realizable?

The NET-60 experiment measures a *cost profile* `S ↦ cost S` on subsets of
layers and asks whether joint costs are predictable from solo costs
(pre-registered horn **P2**: "ablation costs are essentially additive").

Here we settle the question at the level of the tropical model: a function
`c : Finset (Fin n) → ℚ` is the pruning-cost profile of some prunable net **iff**
it is monotone and vanishes on the empty set (`realizable_iff`).  Monotonicity is
the *only* constraint: no additivity, sub-additivity or super-additivity law can
hold in general, and the super-additivity ratio is unbounded — solo costs may be
exactly `0` while the joint cost is any prescribed positive number
(`exists_pure_pair_epistasis`).

The complementary positive result `epi_eq_zero_of_modular` isolates the null
model: when the damage is *modular* (each layer contributes its own additive
penalty) all epistasis vanishes.  Thus epistasis is exactly the failure of the
loss landscape to be modular, and the tail-pair verdict of NET-60 is a statement
about which layer sets carry non-modular joint capability.
-/
import Tropical.NetEpistasis.Core

namespace NetEpistasis

open Finset

variable {n : ℕ}

/-- The **canonical realization** of a monotone cost profile `c`: paths are
indexed by the sets of layers they depend on, and the path with support `A`
incurs loss `c Aᶜ` (it is exactly the path that survives when everything outside
`A` is pruned). -/
def ofProfile (c : Finset (Fin n) → ℚ) : PrunableNet n where
  ι := Finset (Fin n)
  supp := id
  loss := fun A => c Aᶜ
  base := ∅
  base_supp := rfl

/-- The tropical loss of the canonical realization recovers the profile. -/
lemma netLoss_ofProfile {c : Finset (Fin n) → ℚ}
    (hmono : ∀ S T : Finset (Fin n), S ⊆ T → c S ≤ c T) (S : Finset (Fin n)) :
    netLoss (ofProfile c) S = c S := by
  refine le_antisymm ?_ ?_
  · have hdisj : Disjoint ((ofProfile c).supp (show Finset (Fin n) from Sᶜ)) S :=
      disjoint_compl_left
    have := netLoss_le (N := ofProfile c) hdisj
    simpa [ofProfile] using this
  · refine le_netLoss ?_
    intro A hA
    have hA' : Disjoint (show Finset (Fin n) from A) S := hA
    have hsub : S ⊆ (show Finset (Fin n) from A)ᶜ := by
      intro x hx
      have hxA : x ∉ (show Finset (Fin n) from A) := fun hxA =>
        (Finset.disjoint_left.mp hA') hxA hx
      simpa using hxA
    exact hmono S _ hsub

/-- **Realization theorem.** Every monotone cost profile vanishing at `∅` is the
pruning-cost profile of a tropical prunable net. -/
theorem cost_ofProfile {c : Finset (Fin n) → ℚ} (hc0 : c ∅ = 0)
    (hmono : ∀ S T : Finset (Fin n), S ⊆ T → c S ≤ c T) (S : Finset (Fin n)) :
    cost (ofProfile c) S = c S := by
  simp [cost, netLoss_ofProfile hmono, hc0]

/-- **Characterization.** A cost profile is tropically realizable exactly when it
is monotone and normalized.  In particular no additivity law constrains joint
ablation costs beyond monotonicity. -/
theorem realizable_iff (c : Finset (Fin n) → ℚ) :
    (∃ N : PrunableNet n, ∀ S, cost N S = c S) ↔
      (c ∅ = 0 ∧ ∀ S T : Finset (Fin n), S ⊆ T → c S ≤ c T) := by
  constructor
  · rintro ⟨N, hN⟩
    refine ⟨by rw [← hN, cost_empty], ?_⟩
    intro S T hST
    rw [← hN, ← hN]
    exact cost_mono hST
  · rintro ⟨hc0, hmono⟩
    exact ⟨ofProfile c, fun S => cost_ofProfile hc0 hmono S⟩

/-!
### Consequences: the additivity horn is false in the strongest possible way
-/

/-- The profile "cost `r` as soon as both `a` and `b` are pruned". -/
def pairProfile (a b : Fin n) (r : ℚ) : Finset (Fin n) → ℚ :=
  fun S => if a ∈ S ∧ b ∈ S then r else 0

lemma pairProfile_empty (a b : Fin n) (r : ℚ) : pairProfile a b r ∅ = 0 := by
  simp [pairProfile]

lemma pairProfile_mono {a b : Fin n} {r : ℚ} (hr : 0 ≤ r) :
    ∀ S T : Finset (Fin n), S ⊆ T → pairProfile a b r S ≤ pairProfile a b r T := by
  intro S T hST
  by_cases h : a ∈ S ∧ b ∈ S
  · simp [pairProfile, h, hST h.1, hST h.2]
  · by_cases h' : a ∈ T ∧ b ∈ T <;> simp [pairProfile, h, h', hr]

/-- **Pure epistasis is realizable at any strength.**  There is a tropical net in
which two layers each cost *nothing* on their own, yet their joint pruning costs
a prescribed amount `r > 0`.  Hence no law predicting joint cost from solo costs
can hold, and the super-additivity ratio is unbounded. -/
theorem exists_pure_pair_epistasis (a b : Fin n) (hab : a ≠ b) {r : ℚ} (hr : 0 < r) :
    ∃ N : PrunableNet n,
      cost N {a} = 0 ∧ cost N {b} = 0 ∧ cost N ({a} ∪ {b}) = r ∧
        epi N {a} {b} = r ∧ SuperAdditive N {a} {b} := by
  set c := pairProfile a b r with hc
  have hcost : ∀ S, cost (ofProfile c) S = c S :=
    cost_ofProfile (pairProfile_empty a b r) (pairProfile_mono hr.le)
  have ha : cost (ofProfile c) {a} = 0 := by
    rw [hcost]; simp [hc, pairProfile, hab.symm]
  have hb : cost (ofProfile c) {b} = 0 := by
    rw [hcost]; simp [hc, pairProfile, hab]
  have hab' : cost (ofProfile c) ({a} ∪ {b}) = r := by
    rw [hcost]; simp [hc, pairProfile]
  refine ⟨ofProfile c, ha, hb, hab', ?_, ?_⟩
  · simp only [epi, ha, hb, hab']; ring
  · simp only [SuperAdditive, epi, ha, hb, hab']
    simpa using hr

/-- The profile "any pruning at all costs one point". -/
def thresholdProfile (n : ℕ) : Finset (Fin n) → ℚ := fun S => if S.Nonempty then 1 else 0

lemma thresholdProfile_empty : thresholdProfile n ∅ = 0 := by simp [thresholdProfile]

lemma thresholdProfile_mono :
    ∀ S T : Finset (Fin n), S ⊆ T → thresholdProfile n S ≤ thresholdProfile n T := by
  intro S T hST
  rcases S.eq_empty_or_nonempty with rfl | hS
  · by_cases h : T.Nonempty <;> simp [thresholdProfile, h]
  · simp [thresholdProfile, hS, hS.mono hST]

/-- Sub-additivity is realizable too: two layers each costing a full point cost
only one point together.  Together with `exists_pure_pair_epistasis` and
`epi_eq_zero_of_modular` this shows all three regimes coexist in the tropical
model. -/
theorem exists_subadditive_pair (a b : Fin n) :
    ∃ N : PrunableNet n,
      cost N {a} = 1 ∧ cost N {b} = 1 ∧ cost N ({a} ∪ {b}) = 1 ∧
        epi N {a} {b} = -1 ∧ SubAdditive N {a} {b} := by
  have hcost : ∀ S, cost (ofProfile (thresholdProfile n)) S = thresholdProfile n S :=
    cost_ofProfile thresholdProfile_empty thresholdProfile_mono
  have ha : cost (ofProfile (thresholdProfile n)) {a} = 1 := by
    rw [hcost]; simp [thresholdProfile]
  have hb : cost (ofProfile (thresholdProfile n)) {b} = 1 := by
    rw [hcost]; simp [thresholdProfile]
  have hab' : cost (ofProfile (thresholdProfile n)) ({a} ∪ {b}) = 1 := by
    rw [hcost]
    have hne : ({a} ∪ {b} : Finset (Fin n)).Nonempty := ⟨a, by simp⟩
    simp only [thresholdProfile, if_pos hne]
  refine ⟨ofProfile (thresholdProfile n), ha, hb, hab', ?_, ?_⟩
  · simp only [epi, ha, hb, hab']; norm_num
  · simp only [SubAdditive, epi, ha, hb, hab']; norm_num

/-!
### The null model: modular damage has no epistasis
-/

/-- The modular ("independent damage") profile attached to per-layer penalties. -/
def modularProfile (phi : Fin n → ℚ) : Finset (Fin n) → ℚ := fun S => ∑ i ∈ S, phi i

lemma modularProfile_mono {phi : Fin n → ℚ} (hphi : ∀ i, 0 ≤ phi i) :
    ∀ S T : Finset (Fin n), S ⊆ T → modularProfile phi S ≤ modularProfile phi T := by
  intro S T hST
  exact Finset.sum_le_sum_of_subset_of_nonneg hST fun i _ _ => hphi i

/-- **Zero-epistasis null model.**  If the damage is modular — every layer
carries its own additive penalty — then disjoint layer sets have exactly
additive costs; all epistasis vanishes.  Epistasis is therefore precisely the
non-modularity of the tropical loss landscape. -/
theorem epi_eq_zero_of_modular {phi : Fin n → ℚ} (hphi : ∀ i, 0 ≤ phi i)
    {S T : Finset (Fin n)} (hST : Disjoint S T) :
    epi (ofProfile (modularProfile phi)) S T = 0 := by
  have hc0 : modularProfile phi ∅ = 0 := by simp [modularProfile]
  have hcost := cost_ofProfile hc0 (modularProfile_mono hphi)
  simp only [epi, hcost, modularProfile, Finset.sum_union hST]
  ring

end NetEpistasis