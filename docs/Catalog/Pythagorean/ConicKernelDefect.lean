import Pythagorean.FermatKernelSpectrum

/-!
# The kernel defect of a ternary conic, and its surjectivity onto `{0,1,2,3,4}`

`Pythagorean.PythagoreanKernelSpectrum` computes the kernel spectrum of the Pythagorean
cone `x² + y² = z²`: exactly four of the `Nat.bell 3 = 5` equality patterns of a triple are
realised, the missing one being "the two legs agree".  The *defect* is `1`.

This file puts that computation inside a one-parameter family and shows that the defect is
a genuinely fine invariant.

Main results.

* `ConicKernel.mul_sq_eq_mul_sq_ne_iff` — the arithmetic engine.  For `Q ≠ 0`,
  `P u² = Q v²` has a solution with `u ≠ 0` and `u ≠ v` **iff** `P * Q` is a perfect square
  and `P ≠ Q`.  Both clauses matter: the square condition is the classical descent
  obstruction, the clause `P ≠ Q` is a *degeneracy* obstruction which is invisible in the
  Pythagorean case and is exactly what blocks the family at `A + B = C`.
* `ConicKernel.mem_conicSpectrum_002_iff`, `..._010_iff`, `..._011_iff` — a complete
  determination of the three non-discrete, non-trivial patterns for an arbitrary conic
  `A x² + B y² = C z²`.  All three criteria contain the same degeneracy clause `A+B ≠ C`.
* `ConicKernel.diagonal_degeneracy` — consequently, whenever the diagonal point `(1,1,1)`
  lies on the conic (`A + B = C`), *all three* mixed patterns are blocked at once.
* `ConicKernel.defect_eq_zero_fifty`, `..._one`, `..._eight`, `..._two`, `..._three` and
  `ConicKernel.conicDefect_surjective` — in the sub-family `x² + y² = C z²` the defect takes
  **every** possible value `0, 1, 2, 3, 4`, witnessed by `C = 50, 1, 8, 2, 3`.  The extreme
  case `C = 3` uses a `3`-adic descent (`ConicKernel.eq_zero_of_sq_add_sq_eq_three_mul_sq`).
-/

open KernelPattern PythagoreanKernel

namespace ConicKernel

/-! ## A dictionary for the five patterns of a triple -/

section Dictionary

variable {α : Type*} [DecidableEq α]

/-- A tuple has canonical form `p` (where `p` is itself canonical) exactly when its equality
pattern agrees with that of `p`. -/
theorem canon_eq_iff_ker {n : ℕ} {t : Fin n → α} {p : Fin n → Fin n} (hp : canon p = p) :
    canon t = p ↔ ∀ i j, t i = t j ↔ p i = p j := by
  constructor
  · intro h i j
    rw [eq_iff_canon_eq t i j, h]
  · intro h
    conv_rhs => rw [← hp]
    rw [canon_eq_canon_iff, ker_eq_iff]
    exact h

theorem canon_012_iff (t : Fin 3 → α) :
    canon t = ![0, 1, 2] ↔ t 0 ≠ t 1 ∧ t 0 ≠ t 2 ∧ t 1 ≠ t 2 := by
  rw [canon_eq_iff_ker (by decide)]
  constructor
  · intro h
    exact ⟨fun hc => by simpa using (h 0 1).1 hc, fun hc => by simpa using (h 0 2).1 hc,
      fun hc => by simpa using (h 1 2).1 hc⟩
  · rintro ⟨h1, h2, h3⟩ i j
    have h1' := Ne.symm h1
    have h2' := Ne.symm h2
    have h3' := Ne.symm h3
    fin_cases i <;> fin_cases j <;> simp_all

theorem canon_002_iff (t : Fin 3 → α) : canon t = ![0, 0, 2] ↔ t 0 = t 1 ∧ t 0 ≠ t 2 := by
  rw [canon_eq_iff_ker (by decide)]
  constructor
  · intro h
    exact ⟨(h 0 1).2 (by decide), fun hc => by simpa using (h 0 2).1 hc⟩
  · rintro ⟨h1, h2⟩ i j
    have h1' := h1.symm
    have h2' := Ne.symm h2
    fin_cases i <;> fin_cases j <;> simp_all

theorem canon_010_iff (t : Fin 3 → α) : canon t = ![0, 1, 0] ↔ t 0 = t 2 ∧ t 0 ≠ t 1 := by
  rw [canon_eq_iff_ker (by decide)]
  constructor
  · intro h
    exact ⟨(h 0 2).2 (by decide), fun hc => by simpa using (h 0 1).1 hc⟩
  · rintro ⟨h1, h2⟩ i j
    have h1' := h1.symm
    have h2' := Ne.symm h2
    fin_cases i <;> fin_cases j <;> simp_all

theorem canon_011_iff (t : Fin 3 → α) : canon t = ![0, 1, 1] ↔ t 1 = t 2 ∧ t 0 ≠ t 1 := by
  rw [canon_eq_iff_ker (by decide)]
  constructor
  · intro h
    exact ⟨(h 1 2).2 (by decide), fun hc => by simpa using (h 0 1).1 hc⟩
  · rintro ⟨h1, h2⟩ i j
    have h1' := h1.symm
    have h2' := Ne.symm h2
    fin_cases i <;> fin_cases j <;> simp_all

theorem canon_000_iff (t : Fin 3 → α) : canon t = ![0, 0, 0] ↔ t 0 = t 1 ∧ t 1 = t 2 := by
  rw [canon_eq_iff_ker (by decide)]
  constructor
  · intro h
    exact ⟨(h 0 1).2 (by decide), (h 1 2).2 (by decide)⟩
  · rintro ⟨h1, h2⟩ i j
    have h3 : t 0 = t 2 := h1.trans h2
    fin_cases i <;> fin_cases j <;> simp_all

/-- The five canonical patterns of a triple, as a disjunction. -/
theorem mem_patterns_three_iff (q : Fin 3 → Fin 3) :
    q ∈ Patterns 3 ↔
      q = ![0, 1, 2] ∨ q = ![0, 1, 1] ∨ q = ![0, 1, 0] ∨ q = ![0, 0, 0] ∨ q = ![0, 0, 2] := by
  rw [FermatKernel.patterns_three_eq]
  simp only [Finset.mem_insert, Finset.mem_singleton]

end Dictionary

/-! ## The arithmetic engine -/

/-- **Two-parameter descent.**  For `Q ≠ 0`, the equation `P u² = Q v²` has a solution with
`u ≠ 0` iff `P * Q` is a perfect square. -/
theorem mul_sq_eq_mul_sq_iff {P Q : ℕ} (hQ : Q ≠ 0) :
    (∃ u v : ℕ, u ≠ 0 ∧ P * u ^ 2 = Q * v ^ 2) ↔ IsSquare (P * Q) := by
  constructor
  · rintro ⟨u, v, hu, h⟩
    refine isSquare_of_mul_sq_eq_sq (a := u) (c := Q * v) hu ?_
    calc P * Q * u ^ 2 = Q * (P * u ^ 2) := by ring
      _ = Q * (Q * v ^ 2) := by rw [h]
      _ = (Q * v) ^ 2 := by ring
  · rintro ⟨m, hm⟩
    refine ⟨Q, m, hQ, ?_⟩
    calc P * Q ^ 2 = (P * Q) * Q := by ring
      _ = (m * m) * Q := by rw [hm]
      _ = Q * m ^ 2 := by ring

/-- **Two-parameter descent with a non-degeneracy clause.**  For `Q ≠ 0`, the equation
`P u² = Q v²` has a solution with `u ≠ 0` *and* `u ≠ v` iff `P * Q` is a perfect square and
`P ≠ Q`.  The second clause is the "diagonal" obstruction. -/
theorem mul_sq_eq_mul_sq_ne_iff {P Q : ℕ} (hQ : Q ≠ 0) :
    (∃ u v : ℕ, u ≠ 0 ∧ u ≠ v ∧ P * u ^ 2 = Q * v ^ 2) ↔ IsSquare (P * Q) ∧ P ≠ Q := by
  constructor
  · rintro ⟨u, v, hu, huv, h⟩
    refine ⟨(mul_sq_eq_mul_sq_iff hQ).1 ⟨u, v, hu, h⟩, ?_⟩
    rintro rfl
    have : u ^ 2 = v ^ 2 := Nat.eq_of_mul_eq_mul_left (Nat.pos_of_ne_zero hQ) h
    exact huv (Nat.pow_left_injective (by norm_num) this)
  · rintro ⟨⟨m, hm⟩, hPQ⟩
    refine ⟨Q, m, hQ, ?_, ?_⟩
    · rintro rfl
      exact hPQ (Nat.eq_of_mul_eq_mul_right (Nat.pos_of_ne_zero hQ) (by rw [← hm]))
    · calc P * Q ^ 2 = (P * Q) * Q := by ring
        _ = (m * m) * Q := by rw [hm]
        _ = Q * m ^ 2 := by ring

/-! ## Conics and their kernel spectra -/

/-- The ternary conic `A x² + B y² = C z²`, as a predicate on triples. -/
def IsConic (A B C : ℕ) (t : Fin 3 → ℕ) : Prop :=
  A * t 0 ^ 2 + B * t 1 ^ 2 = C * t 2 ^ 2

theorem isConic_iff (A B C a b c : ℕ) :
    IsConic A B C ![a, b, c] ↔ A * a ^ 2 + B * b ^ 2 = C * c ^ 2 := Iff.rfl

/-- The set of kernel patterns realised by integral points of the conic. -/
noncomputable def conicSpectrum (A B C : ℕ) : Finset (Fin 3 → Fin 3) :=
  open Classical in
  (Patterns 3).filter (fun q => ∃ t : Fin 3 → ℕ, IsConic A B C t ∧ canon t = q)

theorem mem_conicSpectrum {A B C : ℕ} {q : Fin 3 → Fin 3} :
    q ∈ conicSpectrum A B C ↔ ∃ t : Fin 3 → ℕ, IsConic A B C t ∧ canon t = q := by
  classical
  rw [conicSpectrum, Finset.mem_filter]
  refine ⟨fun h => h.2, fun h => ⟨?_, h⟩⟩
  obtain ⟨t, -, rfl⟩ := h
  exact canon_mem_patterns t

theorem conicSpectrum_subset (A B C : ℕ) : conicSpectrum A B C ⊆ Patterns 3 := by
  intro q hq
  obtain ⟨t, -, rfl⟩ := mem_conicSpectrum.1 hq
  exact canon_mem_patterns t

/-- The **kernel defect** of a conic: the number of patterns of a triple that it fails to
realise. -/
noncomputable def conicDefect (A B C : ℕ) : ℕ := 5 - (conicSpectrum A B C).card

theorem card_conicSpectrum_le (A B C : ℕ) : (conicSpectrum A B C).card ≤ 5 := by
  have := Finset.card_le_card (conicSpectrum_subset A B C)
  rwa [card_patterns_three] at this

/-! ### The trivial pattern is always present -/

theorem mem_conicSpectrum_000 (A B C : ℕ) : (![0, 0, 0] : Fin 3 → Fin 3) ∈ conicSpectrum A B C :=
  mem_conicSpectrum.2 ⟨![0, 0, 0], by simp [IsConic], by decide⟩

theorem one_le_card_conicSpectrum (A B C : ℕ) : 1 ≤ (conicSpectrum A B C).card :=
  Finset.card_pos.2 ⟨_, mem_conicSpectrum_000 A B C⟩

/-! ### The three mixed patterns -/

/-- **Equal legs.**  The pattern `![0,0,2]` (`x = y ≠ z`) is realised iff `(A+B)·C` is a
square and `A + B ≠ C`. -/
theorem mem_conicSpectrum_002_iff {A B C : ℕ} (hC : C ≠ 0) :
    (![0, 0, 2] : Fin 3 → Fin 3) ∈ conicSpectrum A B C ↔ IsSquare ((A + B) * C) ∧ A + B ≠ C := by
  rw [mem_conicSpectrum]
  constructor
  · rintro ⟨t, ht, hcan⟩
    obtain ⟨h01, h02⟩ := (canon_002_iff t).1 hcan
    have ha : t 0 ≠ 0 := by
      rintro h0
      have h1 : t 1 = 0 := by rw [← h01, h0]
      have : C * t 2 ^ 2 = 0 := by rw [← ht, h0, h1]; ring
      have : t 2 = 0 := by
        rcases Nat.mul_eq_zero.1 this with h | h
        · exact absurd h hC
        · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h
      exact h02 (by rw [h0, this])
    refine (mul_sq_eq_mul_sq_ne_iff hC).1 ⟨t 0, t 2, ha, h02, ?_⟩
    rw [← ht, ← h01]; ring
  · intro h
    obtain ⟨a, z, ha, haz, hz⟩ := (mul_sq_eq_mul_sq_ne_iff hC).2 h
    refine ⟨![a, a, z], ?_, (canon_002_iff _).2 ⟨rfl, ?_⟩⟩
    · show A * a ^ 2 + B * a ^ 2 = C * z ^ 2
      rw [← hz]; ring
    · simpa using haz

/-- **First leg meets the hypotenuse.**  The pattern `![0,1,0]` (`x = z ≠ y`) is realised iff
`A ≤ C`, `(C-A)·B` is a square, and `A + B ≠ C`. -/
theorem mem_conicSpectrum_010_iff {A B C : ℕ} (hB : B ≠ 0) :
    (![0, 1, 0] : Fin 3 → Fin 3) ∈ conicSpectrum A B C ↔
      A ≤ C ∧ IsSquare ((C - A) * B) ∧ A + B ≠ C := by
  rw [mem_conicSpectrum]
  constructor
  · rintro ⟨t, ht, hcan⟩
    obtain ⟨h02, h01⟩ := (canon_010_iff t).1 hcan
    have ht' : A * t 0 ^ 2 + B * t 1 ^ 2 = C * t 0 ^ 2 := by
      have : A * t 0 ^ 2 + B * t 1 ^ 2 = C * t 2 ^ 2 := ht
      rw [← h02] at this; exact this
    have ha : t 0 ≠ 0 := by
      rintro h0
      have hz : B * t 1 ^ 2 = 0 := by rw [h0] at ht'; simpa using ht'
      have h1z : t 1 = 0 := by
        rcases Nat.mul_eq_zero.1 hz with h | h
        · exact absurd h hB
        · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h
      exact h01 (by rw [h0, h1z])
    have hpos : 0 < t 0 ^ 2 := by positivity
    have hAC : A ≤ C := by
      by_contra hcon
      push_neg at hcon
      have h1 : C * t 0 ^ 2 < A * t 0 ^ 2 := Nat.mul_lt_mul_of_lt_of_le hcon (le_refl _) hpos
      omega
    have key : (C - A) * t 0 ^ 2 = B * t 1 ^ 2 := by
      have h2 : (C - A) * t 0 ^ 2 = C * t 0 ^ 2 - A * t 0 ^ 2 := by rw [Nat.sub_mul]
      omega
    have hres := (mul_sq_eq_mul_sq_ne_iff hB).1 ⟨t 0, t 1, ha, fun hc => h01 hc, key⟩
    exact ⟨hAC, hres.1, fun hc => hres.2 (by omega)⟩
  · rintro ⟨hAC, hsq, hne⟩
    have hne' : C - A ≠ B := fun hc => hne (by omega)
    obtain ⟨a, b, ha, hab, hb⟩ := (mul_sq_eq_mul_sq_ne_iff hB).2 ⟨hsq, hne'⟩
    refine ⟨![a, b, a], ?_, (canon_010_iff _).2 ⟨rfl, ?_⟩⟩
    · show A * a ^ 2 + B * b ^ 2 = C * a ^ 2
      have : A * a ^ 2 + (C - A) * a ^ 2 = C * a ^ 2 := by
        rw [← Nat.add_mul]
        congr 1
        omega
      rw [← hb]; omega
    · simpa using hab

/-- **Second leg meets the hypotenuse.**  The pattern `![0,1,1]` (`y = z ≠ x`) is realised iff
`B ≤ C`, `(C-B)·A` is a square, and `A + B ≠ C`. -/
theorem mem_conicSpectrum_011_iff {A B C : ℕ} (hA : A ≠ 0) :
    (![0, 1, 1] : Fin 3 → Fin 3) ∈ conicSpectrum A B C ↔
      B ≤ C ∧ IsSquare ((C - B) * A) ∧ A + B ≠ C := by
  rw [mem_conicSpectrum]
  constructor
  · rintro ⟨t, ht, hcan⟩
    obtain ⟨h12, h01⟩ := (canon_011_iff t).1 hcan
    have ht' : A * t 0 ^ 2 + B * t 1 ^ 2 = C * t 1 ^ 2 := by
      have : A * t 0 ^ 2 + B * t 1 ^ 2 = C * t 2 ^ 2 := ht
      rw [← h12] at this; exact this
    have ha : t 1 ≠ 0 := by
      rintro h1
      have hz : A * t 0 ^ 2 = 0 := by rw [h1] at ht'; simpa using ht'
      have h0z : t 0 = 0 := by
        rcases Nat.mul_eq_zero.1 hz with h | h
        · exact absurd h hA
        · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h
      exact h01 (by rw [h1, h0z])
    have hpos : 0 < t 1 ^ 2 := by positivity
    have hBC : B ≤ C := by
      by_contra hcon
      push_neg at hcon
      have h1 : C * t 1 ^ 2 < B * t 1 ^ 2 := Nat.mul_lt_mul_of_lt_of_le hcon (le_refl _) hpos
      omega
    have key : (C - B) * t 1 ^ 2 = A * t 0 ^ 2 := by
      have h2 : (C - B) * t 1 ^ 2 = C * t 1 ^ 2 - B * t 1 ^ 2 := by rw [Nat.sub_mul]
      omega
    have hres := (mul_sq_eq_mul_sq_ne_iff hA).1 ⟨t 1, t 0, ha, fun hc => h01 hc.symm, key⟩
    exact ⟨hBC, hres.1, fun hc => hres.2 (by omega)⟩
  · rintro ⟨hBC, hsq, hne⟩
    have hne' : C - B ≠ A := fun hc => hne (by omega)
    obtain ⟨a, b, ha, hab, hb⟩ := (mul_sq_eq_mul_sq_ne_iff hA).2 ⟨hsq, hne'⟩
    refine ⟨![b, a, a], ?_, (canon_011_iff _).2 ⟨rfl, ?_⟩⟩
    · show A * b ^ 2 + B * a ^ 2 = C * a ^ 2
      have : B * a ^ 2 + (C - B) * a ^ 2 = C * a ^ 2 := by
        rw [← Nat.add_mul]
        congr 1
        omega
      rw [← hb]; omega
    · simpa using (Ne.symm hab)

/-- **Diagonal degeneracy.**  If the diagonal point `(1,1,1)` lies on the conic, i.e.
`A + B = C`, then *all three* mixed patterns are blocked simultaneously: the spectrum is
contained in `{![0,1,2], ![0,0,0]}` and the defect is at least `3`. -/
theorem diagonal_degeneracy {A B C : ℕ} (hA : A ≠ 0) (hB : B ≠ 0) (hC : C ≠ 0)
    (hdiag : A + B = C) :
    conicSpectrum A B C ⊆ ({![0, 1, 2], ![0, 0, 0]} : Finset (Fin 3 → Fin 3)) := by
  intro q hq
  have hmem := (mem_patterns_three_iff q).1 (conicSpectrum_subset A B C hq)
  simp only [Finset.mem_insert, Finset.mem_singleton]
  rcases hmem with rfl | rfl | rfl | rfl | rfl
  · exact Or.inl rfl
  · exact absurd ((mem_conicSpectrum_011_iff hA).1 hq).2.2 (by omega)
  · exact absurd ((mem_conicSpectrum_010_iff hB).1 hq).2.2 (by omega)
  · exact Or.inr rfl
  · exact absurd ((mem_conicSpectrum_002_iff hC).1 hq).2 (by omega)

/-! ### The discrete pattern -/

theorem mem_conicSpectrum_012_iff (A B C : ℕ) :
    (![0, 1, 2] : Fin 3 → Fin 3) ∈ conicSpectrum A B C ↔
      ∃ x y z : ℕ, x ≠ y ∧ x ≠ z ∧ y ≠ z ∧ A * x ^ 2 + B * y ^ 2 = C * z ^ 2 := by
  rw [mem_conicSpectrum]
  constructor
  · rintro ⟨t, ht, hcan⟩
    obtain ⟨h1, h2, h3⟩ := (canon_012_iff t).1 hcan
    exact ⟨t 0, t 1, t 2, h1, h2, h3, ht⟩
  · rintro ⟨x, y, z, h1, h2, h3, h⟩
    exact ⟨![x, y, z], h, (canon_012_iff _).2 ⟨by simpa using h1, by simpa using h2,
      by simpa using h3⟩⟩


/-! ## Small non-squares -/

theorem not_isSquare_six : ¬ IsSquare 6 := by
  rintro ⟨r, hr⟩
  have : r < 3 := by nlinarith
  interval_cases r <;> omega

theorem not_isSquare_seven : ¬ IsSquare 7 := by
  rintro ⟨r, hr⟩
  have : r < 3 := by nlinarith
  interval_cases r <;> omega

/-! ## Three-adic descent: `x² + y² = 3z²` has only the trivial point

This is the deepest arithmetic input of the file: it is what makes the defect attain its
maximal value `4`. -/

/-- Squares are `0` or `1` mod `3`, so `3 ∣ x² + y²` forces `3 ∣ x` and `3 ∣ y`. -/
theorem three_dvd_of_sq_add_sq {x y : ℕ} (h : 3 ∣ x ^ 2 + y ^ 2) : 3 ∣ x ∧ 3 ∣ y := by
  have hx : x ^ 2 % 3 = (x % 3) ^ 2 % 3 := by rw [Nat.pow_mod]
  have hy : y ^ 2 % 3 = (y % 3) ^ 2 % 3 := by rw [Nat.pow_mod]
  have h0 : (x ^ 2 + y ^ 2) % 3 = 0 := Nat.mod_eq_zero_of_dvd h
  rw [Nat.add_mod, hx, hy] at h0
  have hx3 : x % 3 < 3 := Nat.mod_lt _ (by norm_num)
  have hy3 : y % 3 < 3 := Nat.mod_lt _ (by norm_num)
  refine ⟨Nat.dvd_of_mod_eq_zero ?_, Nat.dvd_of_mod_eq_zero ?_⟩ <;>
    · interval_cases hxx : (x % 3) <;> interval_cases hyy : (y % 3) <;> simp_all

/-- Infinite descent, packaged as strong induction on `x + y + z`. -/
theorem descent_three_aux : ∀ n x y z : ℕ, x + y + z ≤ n → x ^ 2 + y ^ 2 = 3 * z ^ 2 →
    x = 0 ∧ y = 0 ∧ z = 0 := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro x y z hn h
    rcases Nat.eq_zero_or_pos (x + y + z) with h0 | hpos
    · exact ⟨by omega, by omega, by omega⟩
    · obtain ⟨hx, hy⟩ := three_dvd_of_sq_add_sq (⟨z ^ 2, h⟩ : 3 ∣ x ^ 2 + y ^ 2)
      obtain ⟨a, rfl⟩ := hx
      obtain ⟨b, rfl⟩ := hy
      have h2 : 3 * (a ^ 2 + b ^ 2) = z ^ 2 := by nlinarith [h]
      have hz : 3 ∣ z := Nat.Prime.dvd_of_dvd_pow Nat.prime_three ⟨a ^ 2 + b ^ 2, h2.symm⟩
      obtain ⟨c, rfl⟩ := hz
      have h3 : a ^ 2 + b ^ 2 = 3 * c ^ 2 := by nlinarith [h2]
      obtain ⟨ha, hb, hc⟩ := ih (a + b + c) (by omega) a b c (le_refl _) h3
      exact ⟨by omega, by omega, by omega⟩

/-- **Descent.**  The conic `x² + y² = 3z²` has only the origin as an integral point. -/
theorem eq_zero_of_sq_add_sq_eq_three_mul_sq (x y z : ℕ) (h : x ^ 2 + y ^ 2 = 3 * z ^ 2) :
    x = 0 ∧ y = 0 ∧ z = 0 := descent_three_aux (x + y + z) x y z (le_refl _) h

/-! ## The five spectra: the defect takes every value in `{0,1,2,3,4}`

The sub-family is `x² + y² = C z²`, i.e. `A = B = 1`.  Note that `C = 1` reproduces
`PythagoreanKernel.pythSpectrum`. -/

theorem isConic_one_one_one (t : Fin 3 → ℕ) : IsConic 1 1 1 t ↔ IsPythTriple t := by
  simp [IsConic, IsPythTriple]

/-- `C = 1`: the Pythagorean cone.  Defect `1`. -/
theorem conicSpectrum_one : conicSpectrum 1 1 1 = pythSpectrum := by
  ext q
  rw [mem_conicSpectrum, ← pyth_kernel_spectrum]
  exact exists_congr fun t => and_congr (isConic_one_one_one t) Iff.rfl

/-- `C = 50`: **all five** patterns occur; the defect vanishes. -/
theorem conicSpectrum_fifty : conicSpectrum 1 1 50 = Patterns 3 := by
  refine Finset.Subset.antisymm (conicSpectrum_subset _ _ _) ?_
  intro q hq
  rcases (mem_patterns_three_iff q).1 hq with rfl | rfl | rfl | rfl | rfl
  · exact (mem_conicSpectrum_012_iff _ _ _).2
      ⟨17, 31, 5, by norm_num, by norm_num, by norm_num, by norm_num⟩
  · exact (mem_conicSpectrum_011_iff one_ne_zero).2 ⟨by norm_num, ⟨7, by norm_num⟩, by norm_num⟩
  · exact (mem_conicSpectrum_010_iff one_ne_zero).2 ⟨by norm_num, ⟨7, by norm_num⟩, by norm_num⟩
  · exact mem_conicSpectrum_000 _ _ _
  · exact (mem_conicSpectrum_002_iff (by norm_num)).2 ⟨⟨10, by norm_num⟩, by norm_num⟩

/-- `C = 8`: the equal-legs pattern reappears, but the two mixed patterns die.  Defect `2`. -/
theorem conicSpectrum_eight :
    conicSpectrum 1 1 8 = ({![0, 1, 2], ![0, 0, 0], ![0, 0, 2]} : Finset (Fin 3 → Fin 3)) := by
  refine Finset.Subset.antisymm ?_ ?_
  · intro q hq
    have hmem := (mem_patterns_three_iff q).1 (conicSpectrum_subset _ _ _ hq)
    simp only [Finset.mem_insert, Finset.mem_singleton]
    rcases hmem with rfl | rfl | rfl | rfl | rfl
    · exact Or.inl rfl
    · exact absurd ((mem_conicSpectrum_011_iff one_ne_zero).1 hq).2.1
        (by simpa using not_isSquare_seven)
    · exact absurd ((mem_conicSpectrum_010_iff one_ne_zero).1 hq).2.1
        (by simpa using not_isSquare_seven)
    · exact Or.inr (Or.inl rfl)
    · exact Or.inr (Or.inr rfl)
  · intro q hq
    simp only [Finset.mem_insert, Finset.mem_singleton] at hq
    rcases hq with rfl | rfl | rfl
    · exact (mem_conicSpectrum_012_iff _ _ _).2
        ⟨2, 14, 5, by norm_num, by norm_num, by norm_num, by norm_num⟩
    · exact mem_conicSpectrum_000 _ _ _
    · exact (mem_conicSpectrum_002_iff (by norm_num)).2 ⟨⟨4, by norm_num⟩, by norm_num⟩

/-- `C = 2`: the diagonal `(1,1,1)` lies on the conic, so all three mixed patterns die at
once.  Defect `3`. -/
theorem conicSpectrum_two :
    conicSpectrum 1 1 2 = ({![0, 1, 2], ![0, 0, 0]} : Finset (Fin 3 → Fin 3)) := by
  refine Finset.Subset.antisymm
    (diagonal_degeneracy one_ne_zero one_ne_zero (by norm_num) (by norm_num)) ?_
  intro q hq
  simp only [Finset.mem_insert, Finset.mem_singleton] at hq
  rcases hq with rfl | rfl
  · exact (mem_conicSpectrum_012_iff _ _ _).2
      ⟨1, 7, 5, by norm_num, by norm_num, by norm_num, by norm_num⟩
  · exact mem_conicSpectrum_000 _ _ _

/-- `C = 3`: only the origin lies on the conic, so the spectrum collapses to the single
all-equal pattern.  Defect `4`, the maximum possible. -/
theorem conicSpectrum_three :
    conicSpectrum 1 1 3 = ({![0, 0, 0]} : Finset (Fin 3 → Fin 3)) := by
  refine Finset.Subset.antisymm ?_ ?_
  · intro q hq
    have hmem := (mem_patterns_three_iff q).1 (conicSpectrum_subset _ _ _ hq)
    simp only [Finset.mem_singleton]
    rcases hmem with rfl | rfl | rfl | rfl | rfl
    · obtain ⟨x, y, z, hxy, -, -, h⟩ := (mem_conicSpectrum_012_iff _ _ _).1 hq
      have h' : x ^ 2 + y ^ 2 = 3 * z ^ 2 := by simpa using h
      obtain ⟨hx, hy, -⟩ := eq_zero_of_sq_add_sq_eq_three_mul_sq x y z h'
      exact absurd (hx.trans hy.symm) hxy
    · exact absurd ((mem_conicSpectrum_011_iff one_ne_zero).1 hq).2.1
        (by simpa using not_isSquare_two)
    · exact absurd ((mem_conicSpectrum_010_iff one_ne_zero).1 hq).2.1
        (by simpa using not_isSquare_two)
    · rfl
    · exact absurd ((mem_conicSpectrum_002_iff (by norm_num)).1 hq).1
        (by simpa using not_isSquare_six)
  · intro q hq
    rw [Finset.mem_singleton] at hq
    subst hq
    exact mem_conicSpectrum_000 _ _ _

/-! ### Cardinalities and defects -/

set_option maxRecDepth 40000 in
theorem card_conicSpectrum_one : (conicSpectrum 1 1 1).card = 4 := by
  rw [conicSpectrum_one, card_pythSpectrum]

theorem card_conicSpectrum_fifty : (conicSpectrum 1 1 50).card = 5 := by
  rw [conicSpectrum_fifty, card_patterns_three]

set_option maxRecDepth 40000 in
theorem card_conicSpectrum_eight : (conicSpectrum 1 1 8).card = 3 := by
  rw [conicSpectrum_eight]; decide

set_option maxRecDepth 40000 in
theorem card_conicSpectrum_two : (conicSpectrum 1 1 2).card = 2 := by
  rw [conicSpectrum_two]; decide

theorem card_conicSpectrum_three : (conicSpectrum 1 1 3).card = 1 := by
  rw [conicSpectrum_three]; decide

theorem conicDefect_fifty : conicDefect 1 1 50 = 0 := by
  rw [conicDefect, card_conicSpectrum_fifty]

theorem conicDefect_one : conicDefect 1 1 1 = 1 := by
  rw [conicDefect, card_conicSpectrum_one]

theorem conicDefect_eight : conicDefect 1 1 8 = 2 := by
  rw [conicDefect, card_conicSpectrum_eight]

theorem conicDefect_two : conicDefect 1 1 2 = 3 := by
  rw [conicDefect, card_conicSpectrum_two]

theorem conicDefect_three : conicDefect 1 1 3 = 4 := by
  rw [conicDefect, card_conicSpectrum_three]

/-- **The kernel defect is a surjective invariant on the conic pencil `x² + y² = C z²`.**
Every value in `{0,1,2,3,4}` — that is, every value the defect can possibly take — is
attained, by `C = 50, 1, 8, 2, 3` respectively.  In particular the defect is not constant
along the pencil, and the Pythagorean value `1` is neither the minimum nor the maximum. -/
theorem conicDefect_surjective (d : ℕ) (hd : d ≤ 4) : ∃ C : ℕ, conicDefect 1 1 C = d := by
  interval_cases d
  · exact ⟨50, conicDefect_fifty⟩
  · exact ⟨1, conicDefect_one⟩
  · exact ⟨8, conicDefect_eight⟩
  · exact ⟨2, conicDefect_two⟩
  · exact ⟨3, conicDefect_three⟩

/-- The defect never exceeds `4`, because the all-equal pattern is always realised. -/
theorem conicDefect_le_four (A B C : ℕ) : conicDefect A B C ≤ 4 := by
  have := one_le_card_conicSpectrum A B C
  rw [conicDefect]
  omega

/-- Sharp form: the defect of the pencil `x² + y² = C z²` is a *complete* invariant for the
range `{0,…,4}` — it is surjective and bounded by `4`. -/
theorem conicDefect_range_eq :
    {d : ℕ | ∃ C : ℕ, conicDefect 1 1 C = d} = {d : ℕ | d ≤ 4} := by
  ext d
  constructor
  · rintro ⟨C, rfl⟩
    exact conicDefect_le_four 1 1 C
  · intro hd
    exact conicDefect_surjective d hd

end ConicKernel