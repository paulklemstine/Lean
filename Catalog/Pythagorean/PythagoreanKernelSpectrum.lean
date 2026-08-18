import Pythagorean.KernelPatterns

/-!
# The kernel spectrum of the Pythagorean equation

Combining the combinatorics of kernel patterns (`Pythagorean.KernelPatterns`) with
elementary number theory, we determine exactly **which** of the `Nat.bell 3 = 5` equality
patterns of a triple are realised by solutions of `a² + b² = c²` in `ℕ`.

Main results.

* `PythagoreanKernel.mul_sq_eq_sq_iff_isSquare`: `∃ a ≠ 0, ∃ c, k * a² = c²` iff `k` is a
  perfect square.  This is the arithmetic obstruction behind everything below.
* `PythagoreanKernel.pyth_kernel_spectrum`: a pattern `p` of a triple is the kernel of some
  Pythagorean triple over `ℕ` **iff** `p ≠ ![0,0,2]`, i.e. iff `p` is not the pattern
  "the two legs agree, the hypotenuse differs".  Hence exactly `4 = Nat.bell 3 - 1` of the
  five patterns occur: the Pythagorean cone is *kernel-deficient of defect one*.
* `PythagoreanKernel.canon_of_pos`: every triple with strictly positive entries has the
  discrete pattern `![0,1,2]`; the positive Pythagorean triples form a single kernel class.
* `PythagoreanKernel.constant_legs_iff`: the higher-dimensional version.  For the equation
  `∑_{i < k} xᵢ² = y²`, a solution with all legs equal and nonzero exists iff `k` is a
  perfect square.  So the missing pattern reappears in dimension `k = 4` (`1²+1²+1²+1² = 2²`)
  but is blocked in dimension `k = 2`: the kernel spectrum genuinely depends on the
  dimension.
-/

open KernelPattern

namespace PythagoreanKernel

/-! ## The arithmetic obstruction -/

/-- If `k * a² = c²` with `a ≠ 0`, then `k` is a perfect square.  (Descent via coprime
parts: after dividing out `gcd a c`, the leg becomes a unit.) -/
theorem isSquare_of_mul_sq_eq_sq {k a c : ℕ} (ha : a ≠ 0) (h : k * a ^ 2 = c ^ 2) :
    IsSquare k := by
  set g := Nat.gcd a c with hg
  have hg0 : g ≠ 0 := fun hgz => ha (Nat.eq_zero_of_gcd_eq_zero_left (hg ▸ hgz))
  set a' := a / g with ha'
  set c' := c / g with hc'
  have hga : g * a' = a := Nat.mul_div_cancel' (Nat.gcd_dvd_left a c)
  have hgc : g * c' = c := Nat.mul_div_cancel' (Nat.gcd_dvd_right a c)
  have hcop : Nat.Coprime a' c' := Nat.coprime_div_gcd_div_gcd (Nat.pos_of_ne_zero hg0)
  have key : k * a' ^ 2 = c' ^ 2 := by
    have h2 : g ^ 2 * (k * a' ^ 2) = g ^ 2 * c' ^ 2 := by
      calc g ^ 2 * (k * a' ^ 2) = k * (g * a') ^ 2 := by ring
        _ = k * a ^ 2 := by rw [hga]
        _ = c ^ 2 := h
        _ = (g * c') ^ 2 := by rw [hgc]
        _ = g ^ 2 * c' ^ 2 := by ring
    exact Nat.eq_of_mul_eq_mul_left (by positivity) h2
  have hdvd : a' ^ 2 ∣ c' ^ 2 := ⟨k, by rw [← key]; ring⟩
  have ha'1 : a' = 1 := by
    have hcp : Nat.Coprime (a' ^ 2) (c' ^ 2) := Nat.Coprime.pow 2 2 hcop
    have h1 : a' ^ 2 = 1 := Nat.Coprime.eq_one_of_dvd hcp hdvd
    exact (Nat.pow_eq_one.mp h1).resolve_right (by norm_num)
  refine ⟨c', ?_⟩
  have : k * 1 = c' ^ 2 := by rw [← key, ha'1]; ring
  rw [mul_one] at this
  rw [this]; ring

/-- **Constant-leg criterion.**  The equation `k · a² = c²` has a solution with `a ≠ 0`
exactly when `k` is a perfect square. -/
theorem mul_sq_eq_sq_iff_isSquare (k : ℕ) :
    (∃ a c : ℕ, a ≠ 0 ∧ k * a ^ 2 = c ^ 2) ↔ IsSquare k := by
  constructor
  · rintro ⟨a, c, ha, h⟩
    exact isSquare_of_mul_sq_eq_sq ha h
  · rintro ⟨m, rfl⟩
    exact ⟨1, m, one_ne_zero, by ring⟩

theorem not_isSquare_two : ¬ IsSquare 2 := by
  rintro ⟨r, hr⟩
  have hr3 : r < 2 := by nlinarith
  interval_cases r <;> omega

/-- The classical obstruction: an isosceles right triangle has no integer sides. -/
theorem two_mul_sq_ne_sq {a c : ℕ} (ha : a ≠ 0) : 2 * a ^ 2 ≠ c ^ 2 := fun h =>
  not_isSquare_two (isSquare_of_mul_sq_eq_sq ha h)

/-! ## Pythagorean triples and their kernels -/

/-- A Pythagorean triple, packaged as a tuple so that its kernel pattern is defined. -/
def IsPythTriple (t : Fin 3 → ℕ) : Prop := t 0 ^ 2 + t 1 ^ 2 = t 2 ^ 2

instance : DecidablePred IsPythTriple :=
  fun t => inferInstanceAs (Decidable (t 0 ^ 2 + t 1 ^ 2 = t 2 ^ 2))

theorem isPythTriple_iff (a b c : ℕ) :
    IsPythTriple ![a, b, c] ↔ a ^ 2 + b ^ 2 = c ^ 2 := Iff.rfl

/-- A Pythagorean triple with equal legs is the zero triple. -/
theorem eq_zero_of_legs_eq {t : Fin 3 → ℕ} (h : IsPythTriple t) (hab : t 0 = t 1) :
    t 0 = 0 ∧ t 1 = 0 ∧ t 2 = 0 := by
  have h2 : 2 * t 0 ^ 2 = t 2 ^ 2 := by
    rw [IsPythTriple, ← hab] at h; linarith [h]
  have ha : t 0 = 0 := by
    by_contra ha
    exact two_mul_sq_ne_sq ha h2
  have hc : t 2 = 0 := by
    have : t 2 ^ 2 = 0 := by rw [← h2, ha]; ring
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 this
  exact ⟨ha, hab ▸ ha, hc⟩

/-- The pattern "legs equal, hypotenuse different" is **not** realised over `ℕ`. -/
theorem canon_ne_isosceles {t : Fin 3 → ℕ} (h : IsPythTriple t) :
    canon t ≠ ![0, 0, 2] := by
  intro hcan
  have h01 : t 0 = t 1 := by
    refine (eq_iff_canon_eq t 0 1).2 ?_
    rw [hcan]; decide
  obtain ⟨h0, h1, h2⟩ := eq_zero_of_legs_eq h h01
  have h02 : t 0 = t 2 := by rw [h0, h2]
  have : canon t 0 = canon t 2 := (eq_iff_canon_eq t 0 2).1 h02
  rw [hcan] at this
  exact absurd this (by decide)

/-- All entries of a positive Pythagorean triple are pairwise distinct, so its kernel is
the discrete partition. -/
theorem canon_of_pos {t : Fin 3 → ℕ} (h : IsPythTriple t) (hpos : ∀ i, 0 < t i) :
    canon t = ![0, 1, 2] := by
  have hab : t 0 ≠ t 1 := fun hab => (hpos 0).ne' (eq_zero_of_legs_eq h hab).1
  have hac : t 0 ≠ t 2 := by
    intro hac
    have hb : t 1 ^ 2 = 0 := by
      have h' := h
      rw [IsPythTriple, ← hac] at h'
      omega
    exact (hpos 1).ne' (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hb)
  have hbc : t 1 ≠ t 2 := by
    intro hbc
    have ha : t 0 ^ 2 = 0 := by
      have h' := h
      rw [IsPythTriple, ← hbc] at h'
      omega
    exact (hpos 0).ne' (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 ha)
  have hinj : Function.Injective t := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all
  rw [canon_eq_id_of_injective hinj]
  decide

/-- Positive Pythagorean triples all have the same kernel: they form a single orbit class
for the equality pattern.  (They are of course *not* a single permutation orbit — the
kernel only sees the pattern of coincidences.) -/
theorem canon_eq_of_pos {s t : Fin 3 → ℕ} (hs : IsPythTriple s) (ht : IsPythTriple t)
    (hsp : ∀ i, 0 < s i) (htp : ∀ i, 0 < t i) : canon s = canon t := by
  rw [canon_of_pos hs hsp, canon_of_pos ht htp]

/-! ## The spectrum -/

/-- The set of kernel patterns realised by Pythagorean triples over `ℕ`. -/
def pythSpectrum : Finset (Fin 3 → Fin 3) := (Patterns 3).erase ![0, 0, 2]

set_option maxRecDepth 40000 in
theorem pythSpectrum_eq :
    pythSpectrum = ({![0, 1, 2], ![0, 1, 1], ![0, 1, 0], ![0, 0, 0]} : Finset (Fin 3 → Fin 3)) := by
  unfold pythSpectrum
  rw [patterns_eq_filter]
  decide

/-- **Kernel spectrum of the Pythagorean equation.**  A pattern of a triple arises as the
equality pattern of a Pythagorean triple over `ℕ` iff it is not the "equal legs" pattern
`![0,0,2]`. -/
theorem pyth_kernel_spectrum (p : Fin 3 → Fin 3) :
    (∃ t : Fin 3 → ℕ, IsPythTriple t ∧ canon t = p) ↔ p ∈ pythSpectrum := by
  constructor
  · rintro ⟨t, ht, rfl⟩
    refine Finset.mem_erase.2 ⟨canon_ne_isosceles ht, canon_mem_patterns t⟩
  · intro hp
    rw [pythSpectrum_eq] at hp
    simp only [Finset.mem_insert, Finset.mem_singleton] at hp
    rcases hp with rfl | rfl | rfl | rfl
    · exact ⟨![3, 4, 5], by decide, by decide⟩
    · exact ⟨![0, 1, 1], by decide, by decide⟩
    · exact ⟨![1, 0, 1], by decide, by decide⟩
    · exact ⟨![0, 0, 0], by decide, by decide⟩

set_option maxRecDepth 40000 in
/-- Exactly four of the five patterns of a triple occur: the Pythagorean cone has kernel
defect one. -/
theorem card_pythSpectrum : pythSpectrum.card = 4 := by
  rw [pythSpectrum_eq]; decide

set_option maxRecDepth 40000 in
theorem card_pythSpectrum_eq_bell_sub_one : pythSpectrum.card = Nat.bell 3 - 1 := by
  rw [card_pythSpectrum, bell_three']

/-- The spectrum is a proper subset of all patterns of a triple. -/
theorem pythSpectrum_ssubset : pythSpectrum ⊂ Patterns 3 := by
  refine Finset.ssubset_iff_of_subset (Finset.erase_subset _ _) |>.2 ⟨![0, 0, 2], ?_, ?_⟩
  · rw [mem_patterns_iff]; decide
  · simp

/-! ## Dimensional dependence -/

/-- For the `k`-dimensional Pythagorean equation `∑ xᵢ² = y²`, a solution whose legs are
all equal to a nonzero value exists **iff** `k` is a perfect square. -/
theorem constant_legs_iff (k : ℕ) :
    (∃ (a y : ℕ), a ≠ 0 ∧ (∑ _i : Fin k, a ^ 2) = y ^ 2) ↔ IsSquare k := by
  have hsum : ∀ a : ℕ, (∑ _i : Fin k, a ^ 2) = k * a ^ 2 := by
    intro a; simp [Finset.sum_const]
  constructor
  · rintro ⟨a, y, ha, h⟩
    rw [hsum] at h
    exact isSquare_of_mul_sq_eq_sq ha h
  · rintro ⟨m, rfl⟩
    exact ⟨1, m, one_ne_zero, by rw [hsum]; ring⟩

/-- In dimension `2` the equal-legs pattern is blocked … -/
theorem constant_legs_blocked_dim_two :
    ¬ (∃ (a y : ℕ), a ≠ 0 ∧ (∑ _i : Fin 2, a ^ 2) = y ^ 2) := by
  rw [constant_legs_iff]
  exact not_isSquare_two

/-- … while in dimension `4` it is realised, by `1² + 1² + 1² + 1² = 2²`. -/
theorem constant_legs_realised_dim_four :
    ∃ (a y : ℕ), a ≠ 0 ∧ (∑ _i : Fin 4, a ^ 2) = y ^ 2 :=
  ⟨1, 2, one_ne_zero, by decide⟩

/-- The dimension threshold, in the sharpest form: among dimensions `2 ≤ k ≤ 4`, the
equal-legs pattern is realised exactly for `k = 4`. -/
theorem constant_legs_dim_two_three_four :
    (¬ ∃ (a y : ℕ), a ≠ 0 ∧ (∑ _i : Fin 2, a ^ 2) = y ^ 2) ∧
    (¬ ∃ (a y : ℕ), a ≠ 0 ∧ (∑ _i : Fin 3, a ^ 2) = y ^ 2) ∧
    (∃ (a y : ℕ), a ≠ 0 ∧ (∑ _i : Fin 4, a ^ 2) = y ^ 2) := by
  refine ⟨constant_legs_blocked_dim_two, ?_, constant_legs_realised_dim_four⟩
  rw [constant_legs_iff]
  rintro ⟨r, hr⟩
  have : r < 3 := by nlinarith
  interval_cases r <;> omega

end PythagoreanKernel