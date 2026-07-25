import Mathlib

/-!
# Singleton defect and protected information

For an `[[n,k,d]]` code the quantum Singleton bound is `k + 2(d-1) ≤ n`.
The exact nonnegative capacity budget is therefore `n + 2 - 2d`, rather than
`n - 2d`.  The normalized quantities differ by `2/n`, so they agree
asymptotically for growing block length.  The results below need no locality or
geometric assumptions beyond this parameter inequality.
-/

open Filter Topology

namespace SingletonDefect

structure CodeParameters where
  n : ℕ
  k : ℕ
  d : ℕ
  distance_pos : 0 < d
  singleton : k + 2 * (d - 1) ≤ n

def defect (C : CodeParameters) : ℤ := (C.n : ℤ) + 2 - 2 * (C.d : ℤ)
noncomputable def rate (C : CodeParameters) : ℝ := (C.k : ℝ) / C.n
noncomputable def normalizedDefect (C : CodeParameters) : ℝ := (defect C : ℝ) / C.n
def geometricDefect (C : CodeParameters) : ℤ := (C.n : ℤ) - 2 * (C.d : ℤ)

lemma singleton_rearranged (C : CodeParameters) : (C.k : ℤ) ≤ defect C := by
  have hd := C.distance_pos
  have hs := C.singleton
  have hnat : C.k + 2 * C.d ≤ C.n + 2 := by omega
  have hint : (C.k : ℤ) + 2 * (C.d : ℤ) ≤ (C.n : ℤ) + 2 := by
    exact_mod_cast hnat
  unfold defect
  linarith

lemma defect_nonnegative (C : CodeParameters) : 0 ≤ defect C := by
  have hk : (0 : ℤ) ≤ C.k := by omega
  exact hk.trans (singleton_rearranged C)

/-- Exact finite-length defect-capacity law. -/
theorem logical_dimension_le_defect (C : CodeParameters) : (C.k : ℤ) ≤ defect C :=
  singleton_rearranged C

/-- Any protected entropy bounded by `k` is bounded by the exact defect. -/
theorem protected_entropy_le_defect (C : CodeParameters) (S : ℝ)
    (hSk : S ≤ C.k) : S ≤ defect C := by
  have hcast : (C.k : ℝ) ≤ (defect C : ℝ) := by
    exact_mod_cast singleton_rearranged C
  exact hSk.trans hcast

/-- Exact and geometric defects differ by the universal endpoint correction. -/
theorem defect_eq_geometric_add_two (C : CodeParameters) :
    defect C = geometricDefect C + 2 := by
  simp only [defect, geometricDefect]
  ring

/-- A bounded geometric defect uniformly bounds every protected entropy. -/
theorem bounded_geometric_defect_bounds_entropy
    (C : ℕ → CodeParameters) (S : ℕ → ℝ) (B : ℤ)
    (hdef : ∀ i, geometricDefect (C i) ≤ B)
    (hSk : ∀ i, S i ≤ (C i).k) :
    ∀ i, S i ≤ (B : ℝ) + 2 := by
  intro i
  calc
    S i ≤ ((C i).k : ℝ) := hSk i
    _ ≤ (defect (C i) : ℝ) := by
      exact_mod_cast singleton_rearranged (C i)
    _ = (geometricDefect (C i) : ℝ) + 2 := by
      rw [defect_eq_geometric_add_two]
      norm_num
    _ ≤ (B : ℝ) + 2 := by
      have hcast : (geometricDefect (C i) : ℝ) ≤ (B : ℝ) := by
        exact_mod_cast hdef i
      linarith

/-- At positive block length, logical rate is at most normalized exact defect. -/
theorem rate_le_normalizedDefect (C : CodeParameters) (hn : 0 < C.n) :
    rate C ≤ normalizedDefect C := by
  unfold rate normalizedDefect
  apply div_le_div_of_nonneg_right _ (by positivity)
  exact_mod_cast singleton_rearranged C

/-- Normalized exact defect is geometric defect density plus `2/n`. -/
theorem normalizedDefect_eq_geometric (C : CodeParameters) :
    normalizedDefect C = (geometricDefect C : ℝ) / C.n + 2 / C.n := by
  unfold normalizedDefect
  rw [defect_eq_geometric_add_two]
  push_cast
  ring

/-- Endpoint correction vanishes when block lengths diverge. -/
theorem normalized_defect_sub_geometric_tendsto_zero
    (C : ℕ → CodeParameters) (hn : Tendsto (fun i => (C i).n) atTop atTop) :
    Tendsto (fun i => normalizedDefect (C i) -
      (geometricDefect (C i) : ℝ) / (C i).n) atTop (𝓝 0) := by
  have hnR : Tendsto (fun i => ((C i).n : ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop.comp hn
  have htwo : Tendsto (fun i => (2 : ℝ) / (C i).n) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop hnR
  convert htwo using 1
  · funext i
    rw [normalizedDefect_eq_geometric]
    ring

/-- No extensive logical information at bounded geometric defect. -/
theorem bounded_defect_implies_zero_rate
    (C : ℕ → CodeParameters) (B : ℤ)
    (hdef : ∀ i, geometricDefect (C i) ≤ B)
    (hn : Tendsto (fun i => (C i).n) atTop atTop) :
    Tendsto (fun i => rate (C i)) atTop (𝓝 0) := by
  have hnR : Tendsto (fun i => ((C i).n : ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop.comp hn
  have hbound : ∀ i, rate (C i) ≤ ((B : ℝ) + 2) / (C i).n := by
    intro i
    unfold rate
    apply div_le_div_of_nonneg_right _ (by positivity)
    calc
      ((C i).k : ℝ) ≤ (defect (C i) : ℝ) := by
        exact_mod_cast singleton_rearranged (C i)
      _ = (geometricDefect (C i) : ℝ) + 2 := by
        rw [defect_eq_geometric_add_two]
        norm_num
      _ ≤ (B : ℝ) + 2 := by
        have hcast : (geometricDefect (C i) : ℝ) ≤ (B : ℝ) := by
          exact_mod_cast hdef i
        linarith
  have hnonneg : ∀ i, 0 ≤ rate (C i) := by
    intro i
    unfold rate
    positivity
  apply squeeze_zero hnonneg hbound
  exact tendsto_const_nhds.div_atTop hnR

/-- The same zero-density obstruction for any nonnegative entropy bounded by `k`. -/
theorem bounded_defect_implies_zero_entropy_density
    (C : ℕ → CodeParameters) (S : ℕ → ℝ) (B : ℤ)
    (hdef : ∀ i, geometricDefect (C i) ≤ B)
    (hS0 : ∀ i, 0 ≤ S i) (hSk : ∀ i, S i ≤ (C i).k)
    (hnpos : ∀ i, 0 < (C i).n)
    (hn : Tendsto (fun i => (C i).n) atTop atTop) :
    Tendsto (fun i => S i / (C i).n) atTop (𝓝 0) := by
  have hnR : Tendsto (fun i => ((C i).n : ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop.comp hn
  have hbound : ∀ i, S i / (C i).n ≤ ((B : ℝ) + 2) / (C i).n := by
    intro i
    apply div_le_div_of_nonneg_right _ (by exact_mod_cast (Nat.le_of_lt (hnpos i)))
    exact bounded_geometric_defect_bounds_entropy C S B hdef hSk i
  apply squeeze_zero (fun i => div_nonneg (hS0 i) (by positivity)) hbound
  exact tendsto_const_nhds.div_atTop hnR

/-- Quantitative contrapositive: positive rate forces positive exact defect density. -/
theorem positive_rate_forces_positive_defect (C : CodeParameters) (ε : ℝ)
    (hn : 0 < C.n) (hε : ε ≤ rate C) :
    ε ≤ normalizedDefect C :=
  hε.trans (rate_le_normalizedDefect C hn)

end SingletonDefect