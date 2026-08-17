import Cryptography.LatticePointUniqueness

/-!
# Worked examples and computational sanity checks

Concrete evaluations of the lattice-point enumerator, used as machine-checked evidence that the
definitions in `Cryptography.LatticePointEnumerator` behave as intended.

## Main results

* `LatticeEnumerator.dilCount_unitInterval` : in dimension one, `L_{[0,1)}(t) = ⌈t⌉` for every
  `t > 0`; in particular `L(t)/t → 1 = vol([0,1))`, in agreement with the Gauss–Weyl theorem.
* `LatticeEnumerator.dilCount_unitInterval_examples` : numerical instances.
* `LatticeEnumerator.dilCount_empty`, `LatticeEnumerator.shiftCount_empty` : degenerate cases.
-/

noncomputable section

open MeasureTheory Metric Set Filter Topology

namespace LatticeEnumerator

@[simp] lemma dilCount_empty (t : ℝ) : dilCount (∅ : Set (Fin 1 → ℝ)) t = 0 := by
  simp [dilCount, dilLattice, shiftLattice]

@[simp] lemma shiftCount_empty (t : ℝ) (y : Fin 1 → ℝ) :
    shiftCount (∅ : Set (Fin 1 → ℝ)) t y = 0 := by
  simp [shiftCount, shiftLattice]

/-- **One-dimensional evaluation.**  The half-open unit interval has enumerator `⌈t⌉`. -/
theorem dilCount_unitInterval {t : ℝ} (ht : 0 < t) :
    dilCount (Set.univ.pi fun _ : Fin 1 => Set.Ico (0 : ℝ) 1) t = ⌈t⌉₊ := by
  have hset : dilLattice (Set.univ.pi fun _ : Fin 1 => Set.Ico (0 : ℝ) 1) t
      = (fun z : ℤ => (fun _ : Fin 1 => z)) '' (Set.Ico (0 : ℤ) ⌈t⌉) := by
    ext k
    simp only [mem_dilLattice, Set.mem_pi, Set.mem_univ, forall_true_left, Set.mem_Ico,
      Set.mem_image]
    constructor
    · intro hk
      obtain ⟨h1, h2⟩ := hk 0
      refine ⟨k 0, ⟨?_, ?_⟩, ?_⟩
      · have : (0 : ℝ) ≤ (k 0 : ℝ) := by
          rw [le_div_iff₀ ht] at h1; linarith
        exact_mod_cast this
      · refine Int.lt_ceil.2 ?_
        rw [div_lt_one ht] at h2
        exact h2
      · funext i
        fin_cases i
        rfl
    · rintro ⟨z, ⟨hz0, hz1⟩, rfl⟩
      intro i
      refine ⟨?_, ?_⟩
      · have : (0 : ℝ) ≤ (z : ℝ) := by exact_mod_cast hz0
        positivity
      · rw [div_lt_one ht]
        exact Int.lt_ceil.1 hz1
  have hinj : Function.Injective (fun z : ℤ => (fun _ : Fin 1 => z)) := by
    intro a b hab
    exact congrFun hab 0
  have hIco : (Set.Ico (0 : ℤ) ⌈t⌉) = ↑(Finset.Ico (0 : ℤ) ⌈t⌉) := by simp
  rw [dilCount, hset, Set.ncard_image_of_injective _ hinj, hIco, Set.ncard_coe_finset]
  have hceil : ((⌈t⌉₊ : ℕ) : ℤ) = ⌈t⌉ := Int.natCast_ceil_eq_ceil ht.le
  simp only [Int.card_Ico, sub_zero]
  omega

/-- Numerical instances of the one-dimensional evaluation. -/
theorem dilCount_unitInterval_examples :
    dilCount (Set.univ.pi fun _ : Fin 1 => Set.Ico (0 : ℝ) 1) (5 / 2) = 3 ∧
    dilCount (Set.univ.pi fun _ : Fin 1 => Set.Ico (0 : ℝ) 1) 4 = 4 ∧
    dilCount (Set.univ.pi fun _ : Fin 1 => Set.Ico (0 : ℝ) 1) (1 / 3) = 1 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [dilCount_unitInterval (by norm_num)]
    norm_num [Nat.ceil_eq_iff]
  · rw [dilCount_unitInterval (by norm_num)]
    norm_num
  · rw [dilCount_unitInterval (by norm_num)]
    norm_num [Nat.ceil_eq_iff]

/-- The asymptotics predicted by the Gauss–Weyl theorem, verified directly in the
one-dimensional example: `⌈t⌉/t → 1`. -/
theorem tendsto_dilCount_unitInterval :
    Tendsto (fun t : ℝ => (dilCount (Set.univ.pi fun _ : Fin 1 => Set.Ico (0 : ℝ) 1) t : ℝ) / t)
      atTop (𝓝 1) := by
  have hsq : ∀ t : ℝ, 0 < t →
      (dilCount (Set.univ.pi fun _ : Fin 1 => Set.Ico (0 : ℝ) 1) t : ℝ) / t ≤ 1 + 1 / t := by
    intro t ht
    rw [dilCount_unitInterval ht, div_le_iff₀ ht]
    have h1 : ((⌈t⌉₊ : ℕ) : ℝ) < t + 1 := Nat.ceil_lt_add_one ht.le
    have h2 : (1 + 1 / t) * t = t + 1 := by field_simp
    rw [h2]
    exact h1.le
  have hsq' : ∀ t : ℝ, 0 < t →
      (1 : ℝ) ≤ (dilCount (Set.univ.pi fun _ : Fin 1 => Set.Ico (0 : ℝ) 1) t : ℝ) / t := by
    intro t ht
    rw [dilCount_unitInterval ht, le_div_iff₀ ht, one_mul]
    exact Nat.le_ceil t
  have hupper : Tendsto (fun t : ℝ => 1 + 1 / t) atTop (𝓝 1) := by
    have : Tendsto (fun t : ℝ => 1 / t) atTop (𝓝 0) := by
      simpa [one_div] using tendsto_inv_atTop_zero
    simpa using tendsto_const_nhds.add this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht using hsq' t ht
  · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht using hsq t ht

end LatticeEnumerator