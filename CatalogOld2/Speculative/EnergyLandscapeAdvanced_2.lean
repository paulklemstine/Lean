/-! # CatalogBuild.Speculative.EnergyLandscapeAdvanced_2

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 9
-/

import Mathlib

def E' (N x : ℕ) : ℕ := N % x


theorem energy_at_divisor' (N d : ℕ) (hd : d ∣ N) : E' N d = 0 :=
  Nat.mod_eq_zero_of_dvd hd


theorem energy_lt_x (N x : ℕ) (hx : 0 < x) : E' N x < x :=
  Nat.mod_lt N hx


theorem energy_pos_nondivisor (N x : ℕ) (hx : 0 < x) (hnd : ¬(x ∣ N)) :
    0 < E' N x :=
  Nat.pos_of_ne_zero fun h => hnd (Nat.dvd_of_mod_eq_zero h)


def sublevel' (N t : ℕ) : Finset ℕ :=
  (Finset.Icc 1 N).filter (fun x => E' N x ≤ t)


theorem sublevel_antitone (N s t : ℕ) (hst : s ≤ t) :
    sublevel' N s ⊆ sublevel' N t := by
  intro x hx
  simp only [sublevel', Finset.mem_filter] at hx ⊢
  exact ⟨hx.1, le_trans hx.2 hst⟩


theorem energy_max_between_divisors' (N d₁ d₂ : ℕ) (hlt : d₁ < d₂) :
    ∃ x, d₁ ≤ x ∧ x ≤ d₂ ∧ ∀ y, d₁ ≤ y → y ≤ d₂ → E' N y ≤ E' N x := by
  have hne : (Finset.Icc d₁ d₂).Nonempty :=
    ⟨d₁, Finset.mem_Icc.mpr ⟨le_refl _, le_of_lt hlt⟩⟩
  obtain ⟨x, hx_mem, hx_max⟩ := Finset.exists_max_image _ (E' N) hne
  exact ⟨x, (Finset.mem_Icc.mp hx_mem).1, (Finset.mem_Icc.mp hx_mem).2,
    fun y hy1 hy2 => hx_max y (Finset.mem_Icc.mpr ⟨hy1, hy2⟩)⟩


/-- At a divisor d, E(N,d) = 0 which is the global minimum.
Therefore E(N,d) ≤ E(N,y) for all y, making d a global minimum point. -/
theorem energy_global_min_at_divisor (N d y : ℕ) (hd : d ∣ N) :
    E' N d ≤ E' N y := by
  rw [energy_at_divisor' N d hd]
  exact Nat.zero_le _


theorem energy_sum_upper (N : ℕ) (hN : 0 < N) :
    ∑ x ∈ Finset.Icc 1 N, E' N x ≤ N * N := by
  calc ∑ x ∈ Finset.Icc 1 N, E' N x
      ≤ ∑ x ∈ Finset.Icc 1 N, N :=
        Finset.sum_le_sum fun x _ => Nat.mod_le N x
    _ = (Finset.Icc 1 N).card * N := by rw [Finset.sum_const, smul_eq_mul]
    _ ≤ N * N := by
        have : (Finset.Icc 1 N).card ≤ N := by rw [Nat.card_Icc]; omega
        exact Nat.mul_le_mul_right N this

