import Pythagorean.PythagoreanKernelSpectrum

/-!
# Kernel spectra of the Fermat equations, and a phase transition at `p = 2`

For an exponent `p`, consider the solutions of `x^p + y^p = z^p` over `ℕ` and ask which of
the `Nat.bell 3 = 5` equality patterns of a triple they realise (`Pythagorean.KernelPatterns`,
`Pythagorean.PythagoreanKernelSpectrum`).

* `FermatKernel.two_mul_pow_ne_pow`: for `p ≥ 2` and `a ≠ 0` one has `2 * a^p ≠ c^p`
  (the `2`-adic valuation of the left side is `≡ 1 mod p`).  Hence the "equal legs"
  pattern `![0,0,2]` is blocked for **every** exponent `p ≥ 2`, not just for `p = 2`.
* `FermatKernel.spectrum_one`: at `p = 1` all five patterns are realised — the defect is a
  genuine `p ≥ 2` phenomenon, a phase transition in the exponent.
* `FermatKernel.degenerate_patterns_realised`: the three patterns involving a coincidence
  with the hypotenuse are realised for every `p`.
* `FermatKernel.discrete_iff_exists_pos`: the discrete pattern `![0,1,2]` is realised at
  exponent `p ≥ 2` **iff** the Fermat equation has a solution in positive integers.  So for
  `p ≥ 3` the kernel spectrum of the Fermat equation is a purely combinatorial restatement
  of Fermat's Last Theorem: the spectrum has four elements iff FLT fails at `p`, and three
  elements iff FLT holds at `p` (`FermatKernel.spectrum_card_iff_flt`).
-/

open KernelPattern PythagoreanKernel

namespace FermatKernel

/-! ## The 2-adic obstruction -/

/-- For `p ≥ 2` the number `2` is not a `p`-th power times a `p`-th power: `2 * a^p = c^p`
forces `a = 0`.  (Compare `PythagoreanKernel.two_mul_sq_ne_sq`, the case `p = 2`.) -/
theorem two_mul_pow_ne_pow {p a c : ℕ} (hp : 2 ≤ p) (ha : a ≠ 0) : 2 * a ^ p ≠ c ^ p := by
  intro h
  have hap : a ^ p ≠ 0 := pow_ne_zero _ ha
  have hc : c ≠ 0 := by
    rintro rfl
    rw [zero_pow (by omega)] at h
    omega
  have h2 : (2 * a ^ p).factorization 2 = (c ^ p).factorization 2 := by rw [h]
  rw [Nat.factorization_mul two_ne_zero hap, Nat.factorization_pow, Nat.factorization_pow] at h2
  simp only [Finsupp.coe_add, Finsupp.coe_smul, Pi.add_apply, Pi.smul_apply, smul_eq_mul,
    Nat.Prime.factorization Nat.prime_two, Finsupp.single_eq_same] at h2
  set x := a.factorization 2
  set y := c.factorization 2
  have hxy : p * (y - x) = 1 := by
    rw [Nat.mul_sub]
    omega
  have : p ≤ 1 := Nat.le_of_dvd one_pos ⟨y - x, hxy.symm⟩
  omega

/-! ## Fermat triples and their kernels -/

/-- A solution of `x^p + y^p = z^p`, packaged as a triple. -/
def IsFermatTriple (p : ℕ) (t : Fin 3 → ℕ) : Prop := t 0 ^ p + t 1 ^ p = t 2 ^ p

instance (p : ℕ) : DecidablePred (IsFermatTriple p) :=
  fun t => inferInstanceAs (Decidable (t 0 ^ p + t 1 ^ p = t 2 ^ p))

theorem isFermatTriple_two_iff (t : Fin 3 → ℕ) : IsFermatTriple 2 t ↔ IsPythTriple t := Iff.rfl

/-- Equal legs force the trivial solution, for every exponent `p ≥ 2`. -/
theorem eq_zero_of_legs_eq {p : ℕ} (hp : 2 ≤ p) {t : Fin 3 → ℕ} (h : IsFermatTriple p t)
    (hab : t 0 = t 1) : t 0 = 0 ∧ t 1 = 0 ∧ t 2 = 0 := by
  have h2 : 2 * t 0 ^ p = t 2 ^ p := by
    rw [IsFermatTriple, ← hab] at h; omega
  have ha : t 0 = 0 := by
    by_contra ha
    exact two_mul_pow_ne_pow hp ha h2
  have hc : t 2 = 0 := by
    have hz : t 2 ^ p = 0 := by rw [← h2, ha, zero_pow (by omega)]; ring
    exact pow_eq_zero_iff (by omega : p ≠ 0) |>.1 hz
  exact ⟨ha, hab ▸ ha, hc⟩

/-- **The equal-legs pattern is blocked for every exponent `p ≥ 2`.** -/
theorem canon_ne_isosceles {p : ℕ} (hp : 2 ≤ p) {t : Fin 3 → ℕ} (h : IsFermatTriple p t) :
    canon t ≠ ![0, 0, 2] := by
  intro hcan
  have h01 : t 0 = t 1 := by
    refine (eq_iff_canon_eq t 0 1).2 ?_
    rw [hcan]; decide
  obtain ⟨h0, -, h2⟩ := eq_zero_of_legs_eq hp h h01
  have h02 : canon t 0 = canon t 2 := (eq_iff_canon_eq t 0 2).1 (by rw [h0, h2])
  rw [hcan] at h02
  exact absurd h02 (by decide)

/-- The three patterns with a coincidence involving the hypotenuse are realised at every
exponent. -/
theorem degenerate_patterns_realised {p : ℕ} (hp : p ≠ 0) :
    (∃ t : Fin 3 → ℕ, IsFermatTriple p t ∧ canon t = ![0, 1, 1]) ∧
    (∃ t : Fin 3 → ℕ, IsFermatTriple p t ∧ canon t = ![0, 1, 0]) ∧
    (∃ t : Fin 3 → ℕ, IsFermatTriple p t ∧ canon t = ![0, 0, 0]) := by
  refine ⟨⟨![0, 1, 1], ?_, by decide⟩, ⟨![1, 0, 1], ?_, by decide⟩, ⟨![0, 0, 0], ?_, by decide⟩⟩
  · show (0 : ℕ) ^ p + 1 ^ p = 1 ^ p
    simp [zero_pow hp]
  · show (1 : ℕ) ^ p + 0 ^ p = 1 ^ p
    simp [zero_pow hp]
  · show (0 : ℕ) ^ p + 0 ^ p = 0 ^ p
    simp [zero_pow hp]

/-- The discrete pattern is realised exactly when the Fermat equation has a solution in
strictly positive integers (`p ≥ 2`). -/
theorem discrete_iff_exists_pos {p : ℕ} (hp : 2 ≤ p) :
    (∃ t : Fin 3 → ℕ, IsFermatTriple p t ∧ canon t = ![0, 1, 2]) ↔
      ∃ x y z : ℕ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ p + y ^ p = z ^ p := by
  constructor
  · rintro ⟨t, ht, hcan⟩
    have hne : ∀ i j : Fin 3, i ≠ j → t i ≠ t j := by
      intro i j hij hteq
      have := (eq_iff_canon_eq t i j).1 hteq
      rw [hcan] at this
      revert hij this
      fin_cases i <;> fin_cases j <;> decide
    have h0 : t 0 ≠ 0 := by
      intro hz
      have : t 1 ^ p = t 2 ^ p := by
        have := ht
        rw [IsFermatTriple, hz, zero_pow (by omega)] at this
        omega
      exact hne 1 2 (by decide) (Nat.pow_left_injective (by omega) this)
    have h1 : t 1 ≠ 0 := by
      intro hz
      have : t 0 ^ p = t 2 ^ p := by
        have := ht
        rw [IsFermatTriple, hz, zero_pow (by omega)] at this
        omega
      exact hne 0 2 (by decide) (Nat.pow_left_injective (by omega) this)
    have h2 : t 2 ≠ 0 := by
      intro hz
      have := ht
      rw [IsFermatTriple, hz, zero_pow (by omega)] at this
      have : t 0 ^ p = 0 := by omega
      exact h0 (pow_eq_zero_iff (by omega : p ≠ 0) |>.1 this)
    exact ⟨t 0, t 1, t 2, Nat.pos_of_ne_zero h0, Nat.pos_of_ne_zero h1,
      Nat.pos_of_ne_zero h2, ht⟩
  · rintro ⟨x, y, z, hx, hy, hz, hxyz⟩
    refine ⟨![x, y, z], hxyz, ?_⟩
    have hxy : x ≠ y := by
      rintro rfl
      have : 2 * x ^ p = z ^ p := by omega
      exact two_mul_pow_ne_pow hp hx.ne' this
    have hxz : x ≠ z := by
      rintro rfl
      have hy0 : y ^ p = 0 := by omega
      exact hy.ne' (pow_eq_zero_iff (by omega : p ≠ 0) |>.1 hy0)
    have hyz : y ≠ z := by
      rintro rfl
      have hx0 : x ^ p = 0 := by omega
      exact hx.ne' (pow_eq_zero_iff (by omega : p ≠ 0) |>.1 hx0)
    have hinj : Function.Injective (![x, y, z] : Fin 3 → ℕ) := by
      intro i j hij
      fin_cases i <;> fin_cases j <;> simp_all
    rw [canon_eq_id_of_injective hinj]
    decide

/-! ## The spectrum -/

/-- The set of kernel patterns realised by solutions of `x^p + y^p = z^p`. -/
noncomputable def spectrum (p : ℕ) : Finset (Fin 3 → Fin 3) :=
  open Classical in
  (Patterns 3).filter (fun q => ∃ t : Fin 3 → ℕ, IsFermatTriple p t ∧ canon t = q)

theorem mem_spectrum {p : ℕ} {q : Fin 3 → Fin 3} :
    q ∈ spectrum p ↔ ∃ t : Fin 3 → ℕ, IsFermatTriple p t ∧ canon t = q := by
  classical
  rw [spectrum, Finset.mem_filter]
  refine ⟨fun h => h.2, fun h => ⟨?_, h⟩⟩
  obtain ⟨t, -, rfl⟩ := h
  exact canon_mem_patterns t

set_option maxRecDepth 40000 in
/-- The five patterns of a triple, listed explicitly. -/
theorem patterns_three_eq :
    Patterns 3 = ({![0, 1, 2], ![0, 1, 1], ![0, 1, 0], ![0, 0, 0], ![0, 0, 2]} :
      Finset (Fin 3 → Fin 3)) := by
  rw [patterns_eq_filter]; decide

/-- At exponent `1` every pattern occurs: `1 + 1 = 2` realises the equal-legs pattern that
is forbidden for all `p ≥ 2`. -/
theorem spectrum_one : spectrum 1 = Patterns 3 := by
  refine Finset.Subset.antisymm ?_ ?_
  · intro q hq
    obtain ⟨t, -, rfl⟩ := mem_spectrum.1 hq
    exact canon_mem_patterns t
  · intro q hq
    rw [patterns_three_eq] at hq
    rw [mem_spectrum]
    have hcases : q = ![0, 1, 2] ∨ q = ![0, 1, 1] ∨ q = ![0, 1, 0] ∨ q = ![0, 0, 0] ∨
        q = ![0, 0, 2] := by
      simpa using hq
    obtain ⟨h1, h2, h3⟩ := degenerate_patterns_realised (p := 1) one_ne_zero
    rcases hcases with rfl | rfl | rfl | rfl | rfl
    · exact ⟨![3, 4, 7], by decide, by decide⟩
    · exact h1
    · exact h2
    · exact h3
    · exact ⟨![1, 1, 2], by decide, by decide⟩

/-- For `p ≥ 2` the equal-legs pattern is missing, so the spectrum is contained in the
Pythagorean spectrum. -/
theorem spectrum_subset_pythSpectrum {p : ℕ} (hp : 2 ≤ p) : spectrum p ⊆ pythSpectrum := by
  intro q hq
  obtain ⟨t, ht, rfl⟩ := mem_spectrum.1 hq
  exact Finset.mem_erase.2 ⟨canon_ne_isosceles hp ht, canon_mem_patterns t⟩

/-- The three degenerate patterns are always in the spectrum. -/
theorem degenerate_subset_spectrum {p : ℕ} (hp : p ≠ 0) :
    ({![0, 1, 1], ![0, 1, 0], ![0, 0, 0]} : Finset (Fin 3 → Fin 3)) ⊆ spectrum p := by
  obtain ⟨h1, h2, h3⟩ := degenerate_patterns_realised hp
  intro q hq
  simp only [Finset.mem_insert, Finset.mem_singleton] at hq
  rcases hq with rfl | rfl | rfl
  · exact mem_spectrum.2 h1
  · exact mem_spectrum.2 h2
  · exact mem_spectrum.2 h3

/-- **Spectrum with a positive solution.**  For `p ≥ 2`, if the Fermat equation has a
positive solution the spectrum consists of four patterns: everything except equal legs. -/
theorem spectrum_eq_of_exists_pos {p : ℕ} (hp : 2 ≤ p)
    (hflt : ∃ x y z : ℕ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ p + y ^ p = z ^ p) :
    spectrum p = ({![0, 1, 2], ![0, 1, 1], ![0, 1, 0], ![0, 0, 0]} : Finset (Fin 3 → Fin 3)) := by
  refine Finset.Subset.antisymm ?_ ?_
  · intro q hq
    have hq' := spectrum_subset_pythSpectrum hp hq
    rwa [pythSpectrum_eq] at hq'
  · intro q hq
    simp only [Finset.mem_insert, Finset.mem_singleton] at hq
    rcases hq with rfl | hq
    · exact mem_spectrum.2 ((discrete_iff_exists_pos hp).2 hflt)
    · exact degenerate_subset_spectrum (by omega) (by simpa using hq)

/-- **Spectrum without a positive solution.**  For `p ≥ 2`, if the Fermat equation has no
positive solution the spectrum consists of exactly the three degenerate patterns. -/
theorem spectrum_eq_of_not_exists_pos {p : ℕ} (hp : 2 ≤ p)
    (hflt : ¬ ∃ x y z : ℕ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ p + y ^ p = z ^ p) :
    spectrum p = ({![0, 1, 1], ![0, 1, 0], ![0, 0, 0]} : Finset (Fin 3 → Fin 3)) := by
  refine Finset.Subset.antisymm ?_ (degenerate_subset_spectrum (by omega))
  intro q hq
  have hq' := spectrum_subset_pythSpectrum hp hq
  rw [pythSpectrum_eq] at hq'
  simp only [Finset.mem_insert, Finset.mem_singleton] at hq' ⊢
  rcases hq' with rfl | hq'
  · exact absurd ((discrete_iff_exists_pos hp).1 (mem_spectrum.1 hq)) hflt
  · exact hq'

theorem card_spectrum_of_exists_pos {p : ℕ} (hp : 2 ≤ p)
    (hflt : ∃ x y z : ℕ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ p + y ^ p = z ^ p) :
    (spectrum p).card = 4 := by
  rw [spectrum_eq_of_exists_pos hp hflt]; decide

theorem card_spectrum_of_not_exists_pos {p : ℕ} (hp : 2 ≤ p)
    (hflt : ¬ ∃ x y z : ℕ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ p + y ^ p = z ^ p) :
    (spectrum p).card = 3 := by
  rw [spectrum_eq_of_not_exists_pos hp hflt]; decide

/-- **Kernel-theoretic form of Fermat's Last Theorem at exponent `p`.**  For `p ≥ 2` the
Fermat equation realises exactly three of the five patterns of a triple iff it has no
positive solution, and exactly four otherwise. -/
theorem spectrum_card_iff_flt {p : ℕ} (hp : 2 ≤ p) :
    ((spectrum p).card = 3 ↔ ¬ ∃ x y z : ℕ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ p + y ^ p = z ^ p) ∧
    ((spectrum p).card = 4 ↔ ∃ x y z : ℕ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ p + y ^ p = z ^ p) := by
  by_cases hflt : ∃ x y z : ℕ, 0 < x ∧ 0 < y ∧ 0 < z ∧ x ^ p + y ^ p = z ^ p
  · have h4 := card_spectrum_of_exists_pos hp hflt
    exact ⟨⟨fun h3 => absurd (h3 ▸ h4) (by omega), fun h => absurd hflt h⟩,
      ⟨fun _ => hflt, fun _ => h4⟩⟩
  · have h3 := card_spectrum_of_not_exists_pos hp hflt
    exact ⟨⟨fun _ => hflt, fun _ => h3⟩,
      ⟨fun h4 => absurd (h3 ▸ h4) (by omega), fun h => absurd h hflt⟩⟩

/-- The Pythagorean case `p = 2`: four patterns, the missing one being the equal legs. -/
theorem spectrum_two : spectrum 2 = pythSpectrum := by
  rw [spectrum_eq_of_exists_pos (le_refl 2) ⟨3, 4, 5, by norm_num⟩, pythSpectrum_eq]

end FermatKernel