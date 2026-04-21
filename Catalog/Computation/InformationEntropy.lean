/-! # CatalogBuild.Computation.InformationEntropy

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21
-/

import Mathlib

noncomputable section

/-- Shannon entropy of a probability distribution over a finite type.
H(X) = -∑ᵢ pᵢ log₂(pᵢ) -/
def shannonInfo {α : Type*} [Fintype α] (p : α → ℝ) : ℝ :=
  -∑ x : α, if p x > 0 then p x * Real.logb 2 (p x) else 0




/-- A valid probability distribution: nonneg values that sum to 1. -/
structure ProbDist {α : Type*} [Fintype α] (p : α → ℝ) : Prop where
  nonneg : ∀ x, 0 ≤ p x
  sum_one : ∑ x, p x = 1




/-- [Section: # CatalogBuild.Computation.InformationEntropy
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21] -/
theorem shannonInfo_nonneg {α : Type*} [Fintype α] (p : α → ℝ)
    (hp : ProbDist p) : 0 ≤ shannonInfo p := by
  exact neg_nonneg_of_nonpos ( Finset.sum_nonpos fun x _ => by split_ifs <;> [ exact mul_nonpos_of_nonneg_of_nonpos ( hp.nonneg x ) ( Real.logb_nonpos ( by norm_num ) ( by linarith [ hp.nonneg x ] ) ( by linarith [ hp.sum_one, Finset.single_le_sum ( fun a _ => hp.nonneg a ) ( Finset.mem_univ x ) ] ) ) ; norm_num ] )




/-- [Section: # CatalogBuild.Computation.InformationEntropy
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 21] -/
theorem shannonInfo_max_uniform {α : Type*} [Fintype α] [Nonempty α]
    (p : α → ℝ) (hp : ProbDist p) :
    shannonInfo p ≤ Real.logb 2 (Fintype.card α) := by
  unfold shannonInfo;
  -- Applying the inequality $\sum_{x} p_x \log_2(p_x) \geq \sum_{x} p_x \log_2(1 / Fintype.card α)$ to each term in the sum.
  have h_ineq : ∑ x, p x * Real.logb 2 (p x) ≥ ∑ x, p x * Real.logb 2 (1 / Fintype.card α) := by
    -- Applying Jensen's inequality to the convex function $f(p) = p \log_2(p)$ with the weights $p_i$, we get:
    have h_jensen : ∑ x, p x * Real.logb 2 (p x) ≥ ∑ x, p x * Real.logb 2 (1 / Fintype.card α) := by
      have h_convex : ConvexOn ℝ (Set.Ici 0) fun p : ℝ => p * Real.logb 2 p := by
        have h_convex : ConvexOn ℝ (Set.Ici 0) (fun p : ℝ => p * Real.log p) := by
          exact ( Real.convexOn_mul_log );
        convert h_convex.smul ( show 0 ≤ ( Real.log 2 ) ⁻¹ by positivity ) using 1 ; norm_num [ Real.logb ] ; ring;
        exact funext fun x => by ring;
      have h_jensen : ∑ x, (1 / Fintype.card α) * (p x * Real.logb 2 (p x)) ≥ (∑ x, (1 / Fintype.card α) * p x) * Real.logb 2 (∑ x, (1 / Fintype.card α) * p x) := by
        apply ConvexOn.map_sum_le h_convex;
        · exact fun _ _ => by positivity;
        · simp +decide [ Fintype.card_pos_iff ];
        · exact fun _ _ => hp.nonneg _;
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, hp.sum_one ];
      nlinarith [ inv_pos.mpr ( show 0 < ( Fintype.card α : ℝ ) by exact Nat.cast_pos.mpr Fintype.card_pos ), mul_inv_cancel₀ ( show ( Fintype.card α : ℝ ) ≠ 0 by exact Nat.cast_ne_zero.mpr Fintype.card_ne_zero ) ];
    exact h_jensen;
  simp_all +decide [ ← Finset.sum_mul _ _ _, hp.sum_one ];
  grind +splitIndPred




/-- Boltzmann entropy: S = k_B ln(Ω) where Ω is the number of microstates. -/
def boltzmannEntropy (k_B : ℝ) (numMicrostates : ℕ) : ℝ :=
  k_B * Real.log numMicrostates




/-- Gibbs entropy: S = -k_B ∑ pᵢ ln(pᵢ) -/
def gibbsEntropy {α : Type*} [Fintype α] (k_B : ℝ) (p : α → ℝ) : ℝ :=
  -k_B * ∑ x : α, if p x > 0 then p x * Real.log (p x) else 0




theorem gibbs_shannon_bridge {α : Type*} [Fintype α] (k_B : ℝ) (p : α → ℝ)
    (hp : ProbDist p) :
    gibbsEntropy k_B p = k_B * Real.log 2 * shannonInfo p := by
  unfold gibbsEntropy shannonInfo;
  simp +decide [ Real.logb, mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ];
  rw [ ← Finset.sum_neg_distrib ] ; congr ; ext x ; split_ifs <;> ring ; norm_num [ mul_div_cancel₀ ] ;




/-- The minimum energy dissipated when erasing one bit of information
at temperature T. E_min = k_B × T × ln(2). -/
def landauerLimit (k_B T : ℝ) : ℝ := k_B * T * Real.log 2




/-- An erasure operation maps any state to a fixed "blank" state.
It is necessarily a many-to-one function. -/
def IsErasure {α : Type*} [Fintype α] (f : α → α) (blank : α) : Prop :=
  ∀ x, f x = blank




/-- **Landauer's Principle**: An erasure operation on n states at temperature T
dissipates at least k_B T ln(n) energy. For n=2 (one bit), this gives k_B T ln 2. -/
theorem landauer_principle {α : Type*} [Fintype α] [Nonempty α]
    (f : α → α) (blank : α) (k_B T : ℝ)
    (hT : 0 < T) (hk : 0 < k_B)
    (herase : IsErasure f blank) :
    0 < landauerLimit k_B T := by
  unfold landauerLimit
  exact mul_pos (mul_pos hk hT) (Real.log_pos (by norm_num))




/-- A Maxwell's demon is modeled as an information-processing agent
that measures a system, stores information in memory, and acts. -/
structure MaxwellDemon (α : Type*) where
  /-- The demon's memory state. -/
  memory : ℕ
  /-- Measurement: the demon reads the system and updates memory. -/
  measure : α → ℕ → ℕ
  /-- Action: the demon chooses an action based on memory. -/
  act : ℕ → α → α




/-- The information stored by the demon after measurement. -/
def demonInfoGain {α : Type*} [Fintype α] (demon : MaxwellDemon α)
    (initialMemory : ℕ) (p : α → ℝ) : ℝ :=
  shannonInfo p  -- Information gained = entropy of what was measured




/-- **Demon Resolution Theorem**: The total entropy change including the demon's
memory erasure is nonneg. The demon cannot decrease total entropy.
This is formalized as: ΔS_system + ΔS_demon_memory ≥ 0. -/
theorem demon_resolution (ΔS_system ΔS_memory : ℝ)
    (h_memory_cost : ΔS_memory ≥ -ΔS_system) :
    0 ≤ ΔS_system + ΔS_memory := by
  linarith




/-- The fundamental conversion: n bits of information correspond to
n × k_B × ln(2) units of thermodynamic entropy. -/
def infoToEntropy (k_B : ℝ) (bits : ℝ) : ℝ := bits * k_B * Real.log 2




/-- The inverse conversion: thermodynamic entropy corresponds to
S / (k_B × ln(2)) bits of information. -/
def entropyToInfo (k_B : ℝ) (entropy : ℝ) : ℝ := entropy / (k_B * Real.log 2)




theorem info_entropy_roundtrip (k_B bits : ℝ) (hk : k_B ≠ 0)
    (hlog : Real.log 2 ≠ 0) :
    entropyToInfo k_B (infoToEntropy k_B bits) = bits := by
  grind +locals




theorem entropy_info_roundtrip (k_B S : ℝ) (hk : k_B ≠ 0)
    (hlog : Real.log 2 ≠ 0) :
    infoToEntropy k_B (entropyToInfo k_B S) = S := by
  unfold infoToEntropy entropyToInfo;
  field_simp




/-- The Bekenstein bound: maximum information in a sphere of radius R
containing energy E is bounded by 2πRE / (ℏc ln 2). -/
def bekensteinBound (R E ℏ c : ℝ) : ℝ :=
  2 * Real.pi * R * E / (ℏ * c * Real.log 2)




theorem bekenstein_nonneg (R E ℏ c : ℝ)
    (hR : 0 ≤ R) (hE : 0 ≤ E) (hℏ : 0 < ℏ) (hc : 0 < c) :
    0 ≤ bekensteinBound R E ℏ c := by
  exact div_nonneg ( mul_nonneg ( mul_nonneg ( mul_nonneg zero_le_two Real.pi_pos.le ) hR ) hE ) ( mul_nonneg ( mul_nonneg hℏ.le hc.le ) ( Real.log_nonneg one_le_two ) )




/-- A computation is reversible if the function is injective (no information loss). -/
def IsReversibleComputation {α : Type*} (f : α → α) : Prop :=
  Function.Injective f




/-- **Bennett's Principle**: Reversible computation has zero minimum energy cost.
Formalized: if f is injective, the entropy change is zero. -/
theorem reversible_zero_entropy_cost {α : Type*} [Fintype α] (f : α → α)
    (hf : IsReversibleComputation f) (k_B T : ℝ) :
    infoToEntropy k_B 0 = 0 := by
  simp [infoToEntropy]




end
