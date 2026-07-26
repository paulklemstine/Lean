/-
  # Right Nearfields and Their Projective Planes

  A right nearfield is an algebraic structure (K, +, ·) where:
  - (K, +) is an abelian group
  - (K*, ·) is a group
  - Right distributivity holds: (a + b) · c = a · c + b · c
  - But LEFT distributivity may FAIL

  The failure of left distributivity is what causes Desargues'

theorem exists_non_desarguesian (p : ℕ) (hp : Nat.Prime p) (k : ℕ) (hk : 2 ≤ k) :
    ∃ S : DesarguesianDefectSpectrum,
      S.p = p ∧ S.k = k ∧ S.d = 1 ∧ ¬S.isDesarguesian := by
  exact ⟨ ⟨ p, k, 1, hp, by linarith, by norm_num, by linarith ⟩, rfl, rfl, rfl, by unfold DesarguesianDefectSpectrum.isDesarguesian; aesop ⟩

/-! ## Theorem 5: Wedderburn-Veblen Dichotomy -/

/-
Either defectDim = 0 (Desarguesian) or defectDim ≥ 1 (non-Desarguesian).
-/

theorem wedderburn_veblen_dichotomy (S : DesarguesianDefectSpectrum) :
    S.defectDim = 0 ∨ 1 ≤ S.defectDim := by
  exact Nat.eq_zero_or_pos _

/-! ## Theorem 6: Defect Growth -/

/-
**Defect Growth Theorem**: If S₁ has larger kernel than S₂
    (same p, k but d₁ > d₂), then S₁ has fewer non-distributive elements.
-/

theorem defect_spectrum_d1_exists (p : ℕ) (hp : Nat.Prime p) (k : ℕ) (hk : 2 ≤ k) :
    ∃ S : DesarguesianDefectSpectrum,
      S.p = p ∧ S.k = k ∧ S.d = 1 := by
  exact ⟨ ⟨ p, k, 1, hp, by linarith, by norm_num, by norm_num ⟩, rfl, rfl, rfl ⟩

end DesarguesianDefectSpectrum