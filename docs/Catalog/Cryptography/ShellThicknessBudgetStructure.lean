/-
# Cycle 4c: the thick shells form the innermost block

The counting bound of `Cryptography.ShellThicknessBudget` says *how many* shells of an
equal-volume peeling can violate a thickness budget `δ`.  This file says *which* ones.

`shellThickness_mono_inward` : shell thicknesses increase monotonically towards the centre.
The proof is concavity of `x ↦ x^{1/d}` (`Real.concaveOn_rpow`) applied to the three equally
spaced volume fractions `(N-k)/N, (N-k-1)/N, (N-k-2)/N` — a convexity input, as opposed to the
rpow inequalities used for the two-sided bounds.

Consequently (`exists_thick_threshold`) there is a threshold index `k₀ ≤ N` with
`δ < thickness_k ↔ k₀ ≤ k` for all `k < N`: the violating shells are exactly the terminal block
`[k₀, N)`, whose length is `thickCount R d N δ = N - k₀`.  `peeling_structure` packages the
cycle: an equal-volume peeling under a budget `δ` consists of `k₀` thin outer skins followed by
`N - k₀ ≤ 1 + R/(dδ)` thick inner layers, and the inner block is empty as soon as
`N ≥ (R/δ)^d`.

## Lab notes

`R = 1, d = 2, δ = 0.01`, `N = 100`: the thick shells are exactly the innermost `25`, i.e.
`k₀ = 75`; `N = 200` gives `k₀ = 187` (13 thick).  `d = 5, N = 1000, δ = 0.01`: `8` thick
shells, all innermost.  No run ever produced a thick shell outside the terminal block, as
`exists_thick_threshold` now proves.
-/
import Mathlib
import Cryptography.ShellThicknessBudgetSharp

namespace Catalog.Cryptography.ShellBudget

open Finset Catalog.Geometry.Peel Catalog.Shared.ShellSharp

/-- **Shells get thicker towards the centre.** -/
theorem shellThickness_mono_inward {R : ℝ} (hR : 0 ≤ R) {d N k : ℕ} (hd : 0 < d)
    (hk : k + 1 < N) :
    shellThickness R d N k ≤ shellThickness R d N (k + 1) := by
  have hN : 0 < N := by omega
  have hNpos : (0 : ℝ) < N := by exact_mod_cast hN
  have hk2 : (k : ℝ) + 2 ≤ N := by exact_mod_cast hk
  have hk0 : (0 : ℝ) ≤ k := Nat.cast_nonneg k
  set p : ℝ := (d : ℝ)⁻¹ with hp
  have hp0 : (0 : ℝ) ≤ p := by rw [hp]; positivity
  have hp1 : p ≤ 1 := inv_natCast_le_one hd
  set A : ℝ := ((N : ℝ) - k) / N with hA
  set B : ℝ := ((N : ℝ) - k - 1) / N with hB
  set C : ℝ := ((N : ℝ) - k - 2) / N with hC
  have hA0 : (0 : ℝ) ≤ A := by rw [hA]; exact div_nonneg (by linarith) hNpos.le
  have hC0 : (0 : ℝ) ≤ C := by
    rw [hC]; exact div_nonneg (by linarith) hNpos.le
  have hmid : (1 / 2 : ℝ) * A + (1 / 2 : ℝ) * C = B := by
    rw [hA, hB, hC]; field_simp; ring
  have hconc := (Real.concaveOn_rpow hp0 hp1).2 (Set.mem_Ici.2 hA0) (Set.mem_Ici.2 hC0)
    (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (0:ℝ) ≤ 1/2) (by norm_num : (1/2 : ℝ) + 1/2 = 1)
  simp only [smul_eq_mul] at hconc
  rw [hmid] at hconc
  have hthick1 : shellThickness R d N k = R * (A ^ p - B ^ p) := by
    rw [shellThickness_eq' (by omega : k < N), hA, hB, hp]
  have hthick2 : shellThickness R d N (k + 1) = R * (B ^ p - C ^ p) := by
    rw [shellThickness_eq' (by omega : k + 1 < N), hB, hC, hp]
    push_cast
    ring_nf
  rw [hthick1, hthick2]
  have hstep : A ^ p - B ^ p ≤ B ^ p - C ^ p := by linarith
  exact mul_le_mul_of_nonneg_left hstep hR

/-- Thickness is monotone in the shell index. -/
theorem shellThickness_mono_of_le {R : ℝ} (hR : 0 ≤ R) {d N : ℕ} (hd : 0 < d) :
    ∀ {k j : ℕ}, k ≤ j → j < N → shellThickness R d N k ≤ shellThickness R d N j := by
  intro k j
  induction j with
  | zero => intro hkj _; simp [Nat.le_zero.1 hkj]
  | succ n ih =>
      intro hkj hn
      rcases Nat.lt_or_ge k (n + 1) with hlt | hge
      · exact le_trans (ih (by omega) (by omega)) (shellThickness_mono_inward hR hd hn)
      · have hkeq : k = n + 1 := by omega
        rw [hkeq]

/-- **The thick shells are exactly the innermost ones.**  There is a threshold index `k₀` such
that a shell violates the budget iff its index is at least `k₀`: an equal-volume peeling splits
into an outer block of thin skins and an inner block of thick layers. -/
theorem exists_thick_threshold {R δ : ℝ} (hR : 0 ≤ R) {d N : ℕ} (hd : 0 < d) :
    ∃ k₀ ≤ N, (∀ k < N, (δ < shellThickness R d N k ↔ k₀ ≤ k)) ∧
      thickCount R d N δ = N - k₀ := by
  classical
  have main : ∃ k₀ ≤ N, ∀ k < N, (δ < shellThickness R d N k ↔ k₀ ≤ k) := by
    by_cases hne : ((range N).filter (fun k => δ < shellThickness R d N k)).Nonempty
    · refine ⟨((range N).filter (fun k => δ < shellThickness R d N k)).min' hne, ?_, ?_⟩
      · have hmem := mem_filter.1 (Finset.min'_mem _ hne)
        have hlt := mem_range.1 hmem.1
        omega
      · intro k hk
        constructor
        · intro hthick
          exact Finset.min'_le _ k (mem_filter.2 ⟨mem_range.2 hk, hthick⟩)
        · intro hle
          have hmem := mem_filter.1 (Finset.min'_mem _ hne)
          exact lt_of_lt_of_le hmem.2 (shellThickness_mono_of_le hR hd hle hk)
    · refine ⟨N, le_rfl, ?_⟩
      intro k hk
      constructor
      · intro hthick
        exact absurd ⟨k, mem_filter.2 ⟨mem_range.2 hk, hthick⟩⟩ hne
      · intro hle; omega
  obtain ⟨k₀, hk₀N, hiff⟩ := main
  refine ⟨k₀, hk₀N, hiff, ?_⟩
  have hset : (range N).filter (fun k => δ < shellThickness R d N k) = Ico k₀ N := by
    ext k
    rw [mem_filter, mem_range, mem_Ico]
    constructor
    · rintro ⟨hk, hthick⟩
      exact ⟨(hiff k hk).1 hthick, hk⟩
    · rintro ⟨hk0, hk⟩
      exact ⟨hk, (hiff k hk).2 hk0⟩
  rw [thickCount, hset, Nat.card_Ico]

/-- **Structure theorem for equal-volume peelings under a thickness budget.**  The peeling
splits into an outer block of thin skins and an inner block of at most `1 + R/(dδ)` thick
layers, and the thick block is empty as soon as `N ≥ (R/δ)^d`. -/
theorem peeling_structure {R δ : ℝ} (hR : 0 < R) (hδ : 0 < δ) {d N : ℕ} (hd : 0 < d)
    (hN : 0 < N) :
    ∃ k₀ ≤ N, (∀ k < N, (δ < shellThickness R d N k ↔ k₀ ≤ k)) ∧
      ((N : ℝ) - k₀ ≤ 1 + R / (d * δ)) ∧
      ((R / δ) ^ d ≤ (N : ℝ) → k₀ = N) := by
  obtain ⟨k₀, hk₀N, hiff, hcard⟩ := exists_thick_threshold hR.le hd (δ := δ) (N := N)
  refine ⟨k₀, hk₀N, hiff, ?_, ?_⟩
  · have h1 := thickCount_le hR.le hδ (d := d) (N := N) hd
    rw [hcard, Nat.cast_sub hk₀N] at h1
    exact h1
  · intro hthr
    have hthin := (all_thin_iff_card hR hδ hd hN).2 hthr
    by_contra hne
    have hlt : k₀ < N := lt_of_le_of_ne hk₀N hne
    have hthick : δ < shellThickness R d N k₀ := (hiff k₀ hlt).2 le_rfl
    exact absurd (hthin k₀ hlt) (not_le.2 hthick)

end Catalog.Cryptography.ShellBudget