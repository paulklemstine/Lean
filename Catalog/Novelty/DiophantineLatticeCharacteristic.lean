import Novelty.DiophantineLatticeCompleteSquare

/-!
# Cycle 4: characteristic vectors and the `mod 8` law behind the gap of `2`

`Novelty/DiophantineLatticeShiftedTheta.lean` proved that for `ℤⁿ` with the standard form the
shifted spectrum at the deep hole `(1/2,…,1/2)` lies in `n/4 + 2ℤ`, via the elementary fact
that a sum of `n` odd squares is `≡ n (mod 8)`.  Conjecture 3 of `FUTURE_DIRECTIONS.md` asked
for the structural reason.  This file answers it: the deep hole is `w/2` for the all-ones
vector `w`, and `w` is a **characteristic vector** of the standard form.  For an arbitrary
symmetric integral form `Q` on `ℤⁿ`:

* `characteristic_iff_dvd_eight` : `v` is characteristic (i.e. `Bil(v,u) + Q(u)` is even for
  every `u`) **iff** `Q(v + 2u) ≡ Q(v) (mod 8)` for every `u`.  So the mod-8 congruence is not
  a coincidence of `ℤⁿ` but an exact characterisation of characteristic vectors.
* `characteristic_shifted_spectrum` : consequently the shifted spectrum of the rational form at
  the half point `v/2` is contained in `Q(v)/4 + 2ℤ`, and
* `characteristic_gap_two` : distinct attained values differ by at least `2`.
* `standard_allOnes_characteristic` : the all-ones vector is characteristic for the standard
  form, so the cycle-1 result is recovered as a special case, and `sum_sq_sub_self_even`
  becomes the statement that `0` is characteristic-shifted by `w`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `mod 8` law is equivalent to a `mod 2` condition on the linear
functional `u ↦ Bil(v,u) + Q(u)`, i.e. to `v` being characteristic; the "gap 2" phenomenon
should therefore hold for *every* lattice at the half of a characteristic vector, not just for
`ℤⁿ`.
Experiment (Experimenter): expanding `Q(v + 2u) = Q(v) + 4(Bil(v,u) + Q(u))` shows both
directions at once, since `8 ∣ 4t ↔ 2 ∣ t`.  For the standard form
`Bil(w,u) + Q(u) = Σ uᵢ(1 + uᵢ)` is visibly even, matching the enumeration in
`ComputationalEvidence.md`.
Analysis (Analyst): the factor `4` in the expansion is the same `4` as in the `λ₁/4` spectral
gap — both come from `[L : 2L]`-scaling — but the two theorems are logically independent: one
is archimedean, one is `2`-adic.  The equivalence is sharp: a non-characteristic `v` always
produces a value `≡ Q(v) + 4 (mod 8)`, breaking the gap from `2` down to `1`.
Critique (Critic): the statement is an `iff`, so it cannot be vacuous; and it is instantiated
(`standard_allOnes_characteristic`) rather than left abstract.  Positive definiteness is *not*
needed anywhere in this file — an honest hypothesis reduction relative to cycles 1–3.
Synthesis (PI): "gap 2 in the shifted theta spectrum" ⟺ "the shift is half a characteristic
vector"; the cycle-1 deep-hole theorem is the case `L = ℤⁿ`, `v = (1,…,1)`.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-! ## Integral forms -/

/-- The integral bilinear form attached to an integer matrix. -/
def zbil (B : Matrix (Fin n) (Fin n) ℤ) (x y : Fin n → ℤ) : ℤ := ∑ i, ∑ j, B i j * x i * y j

/-- The integral quadratic form `Q(x) = xᵀBx`. -/
def zform (B : Matrix (Fin n) (Fin n) ℤ) (x : Fin n → ℤ) : ℤ := zbil B x x

/-- `v` is a **characteristic vector** of `Q`: the functional `u ↦ Bil(v,u) + Q(u)` is even. -/
def IsCharacteristic (B : Matrix (Fin n) (Fin n) ℤ) (v : Fin n → ℤ) : Prop :=
  ∀ u : Fin n → ℤ, 2 ∣ (zbil B v u + zform B u)

lemma zbil_comm {B : Matrix (Fin n) (Fin n) ℤ} (hsym : ∀ i j, B i j = B j i) (x y : Fin n → ℤ) :
    zbil B x y = zbil B y x := by
  simp only [zbil]
  rw [Finset.sum_comm]
  exact sum_congr rfl fun i _ => sum_congr rfl fun j _ => by rw [hsym j i]; ring

lemma zform_add {B : Matrix (Fin n) (Fin n) ℤ} (hsym : ∀ i j, B i j = B j i) (x y : Fin n → ℤ) :
    zform B (fun i => x i + y i) = zform B x + 2 * zbil B x y + zform B y := by
  have hc := zbil_comm hsym x y
  simp only [zform, zbil] at hc ⊢
  have expand : ∀ i : Fin n, ∑ j, B i j * (x i + y i) * (x j + y j)
      = (∑ j, B i j * x i * x j) + (∑ j, B i j * x i * y j)
        + ((∑ j, B i j * y i * x j) + (∑ j, B i j * y i * y j)) := by
    intro i
    rw [← sum_add_distrib, ← sum_add_distrib, ← sum_add_distrib]
    exact sum_congr rfl fun j _ => by ring
  rw [sum_congr rfl fun i _ => expand i]
  rw [sum_add_distrib, sum_add_distrib, sum_add_distrib]
  linarith

lemma zbil_two_right (B : Matrix (Fin n) (Fin n) ℤ) (x u : Fin n → ℤ) :
    zbil B x (fun i => 2 * u i) = 2 * zbil B x u := by
  simp only [zbil, mul_sum]
  exact sum_congr rfl fun i _ => sum_congr rfl fun j _ => by ring

lemma zform_two (B : Matrix (Fin n) (Fin n) ℤ) (u : Fin n → ℤ) :
    zform B (fun i => 2 * u i) = 4 * zform B u := by
  simp only [zform, zbil, mul_sum]
  exact sum_congr rfl fun i _ => sum_congr rfl fun j _ => by ring

/-- The fundamental expansion `Q(v + 2u) = Q(v) + 4·(Bil(v,u) + Q(u))`. -/
lemma zform_add_two_smul {B : Matrix (Fin n) (Fin n) ℤ} (hsym : ∀ i j, B i j = B j i)
    (v u : Fin n → ℤ) :
    zform B (fun i => v i + 2 * u i) = zform B v + 4 * (zbil B v u + zform B u) := by
  rw [zform_add hsym v (fun i => 2 * u i), zbil_two_right, zform_two]
  ring

/-- **Characteristic vectors are exactly the vectors satisfying the `mod 8` law.** -/
theorem characteristic_iff_dvd_eight {B : Matrix (Fin n) (Fin n) ℤ}
    (hsym : ∀ i j, B i j = B j i) (v : Fin n → ℤ) :
    IsCharacteristic B v ↔
      ∀ u : Fin n → ℤ, (8 : ℤ) ∣ zform B (fun i => v i + 2 * u i) - zform B v := by
  constructor
  · intro hchar u
    obtain ⟨t, ht⟩ := hchar u
    refine ⟨t, ?_⟩
    rw [zform_add_two_smul hsym, ht]
    ring
  · intro h u
    obtain ⟨t, ht⟩ := h u
    refine ⟨t, ?_⟩
    rw [zform_add_two_smul hsym] at ht
    omega

/-! ## Transfer to the rational form and the spectral consequence -/

/-- The rational form attached to an integral matrix. -/
def toRat (B : Matrix (Fin n) (Fin n) ℤ) : Matrix (Fin n) (Fin n) ℚ :=
  B.map (fun z : ℤ => (z : ℚ))

lemma form_toRat (B : Matrix (Fin n) (Fin n) ℤ) (x : Fin n → ℤ) :
    form (toRat B) (emb x) = ((zform B x : ℤ) : ℚ) := by
  simp only [form, bil, zform, zbil, toRat, Matrix.map_apply, emb_apply]
  push_cast
  rfl

/-- Any lattice point `m` gives `v - 2m`, which is `v + 2(-m)`. -/
lemma sub_two_eq_add_two_neg (v m : Fin n → ℤ) :
    (fun i => v i - 2 * m i) = fun i => v i + 2 * (-m i) := by
  funext i; ring

/-- **The shifted spectrum at half a characteristic vector lies in `Q(v)/4 + 2ℤ`.** -/
theorem characteristic_shifted_spectrum {B : Matrix (Fin n) (Fin n) ℤ}
    (hsym : ∀ i j, B i j = B j i) {v : Fin n → ℤ} (hchar : IsCharacteristic B v)
    (m : Fin n → ℤ) :
    ∃ k : ℤ, form (toRat B) (fun i => halfPt v i - emb m i)
      = ((zform B v : ℤ) : ℚ) / 4 + 2 * k := by
  obtain ⟨t, ht⟩ := (characteristic_iff_dvd_eight hsym v).1 hchar (fun i => -m i)
  refine ⟨t, ?_⟩
  rw [form_half_sub, sub_two_eq_add_two_neg, form_toRat]
  have : zform B (fun i => v i + 2 * -m i) = zform B v + 8 * t := by omega
  rw [this]
  push_cast
  ring

/-- **Gap `2`.**  Distinct values of the non-homogeneous form at half a characteristic vector
differ by at least `2`. -/
theorem characteristic_gap_two {B : Matrix (Fin n) (Fin n) ℤ} (hsym : ∀ i j, B i j = B j i)
    {v : Fin n → ℤ} (hchar : IsCharacteristic B v) (m m' : Fin n → ℤ)
    (hne : form (toRat B) (fun i => halfPt v i - emb m i)
      ≠ form (toRat B) (fun i => halfPt v i - emb m' i)) :
    2 ≤ |form (toRat B) (fun i => halfPt v i - emb m i)
      - form (toRat B) (fun i => halfPt v i - emb m' i)| := by
  obtain ⟨k, hk⟩ := characteristic_shifted_spectrum hsym hchar m
  obtain ⟨k', hk'⟩ := characteristic_shifted_spectrum hsym hchar m'
  have hkk : k ≠ k' := by
    rintro rfl
    exact hne (by rw [hk, hk'])
  have hdiff : form (toRat B) (fun i => halfPt v i - emb m i)
      - form (toRat B) (fun i => halfPt v i - emb m' i) = 2 * ((k : ℚ) - k') := by
    rw [hk, hk']; ring
  rw [hdiff, abs_mul]
  have h0 : (1 : ℤ) ≤ |k - k'| := Int.one_le_abs (sub_ne_zero.mpr hkk)
  have h1 : (1 : ℚ) ≤ |(k : ℚ) - k'| := by exact_mod_cast h0
  have habs : |(2 : ℚ)| = 2 := by norm_num
  rw [habs]
  linarith

/-! ## The standard form: the all-ones vector is characteristic -/

/-- The all-ones vector of `ℤⁿ`. -/
def allOnes (n : ℕ) : Fin n → ℤ := fun _ => 1

lemma zbil_one_matrix (x y : Fin n → ℤ) :
    zbil (1 : Matrix (Fin n) (Fin n) ℤ) x y = ∑ i, x i * y i := by
  simp only [zbil, Matrix.one_apply, ite_mul, one_mul, zero_mul, sum_ite_eq, mem_univ, if_true]

lemma one_matrix_isSymm (i j : Fin n) :
    (1 : Matrix (Fin n) (Fin n) ℤ) i j = (1 : Matrix (Fin n) (Fin n) ℤ) j i := by
  rcases eq_or_ne i j with h | h
  · simp [Matrix.one_apply, h]
  · simp [h, h.symm]

/-- The all-ones vector is a characteristic vector of the standard form: this is the structural
reason for the `mod 8` congruence of cycle 1. -/
theorem standard_allOnes_characteristic :
    IsCharacteristic (1 : Matrix (Fin n) (Fin n) ℤ) (allOnes n) := by
  intro u
  rw [zbil_one_matrix, zform, zbil_one_matrix]
  have hcomb : (∑ i, (allOnes n) i * u i) + ∑ i, u i * u i = ∑ i, u i * (1 + u i) := by
    rw [← sum_add_distrib]
    exact sum_congr rfl fun i _ => by simp [allOnes]; ring
  rw [hcomb]
  refine Finset.dvd_sum fun i _ => ?_
  rcases Int.even_or_odd (u i) with ⟨t, ht⟩ | ⟨t, ht⟩
  · exact ⟨t * (1 + u i), by rw [ht]; ring⟩
  · exact ⟨u i * (t + 1), by rw [ht]; ring⟩

/-- Recovering cycle 1: for `ℤⁿ` the half of the all-ones vector *is* the deep hole. -/
lemma halfPt_allOnes : halfPt (allOnes n) = deepHole n := by
  funext i; simp [halfPt, allOnes, deepHole]

/-- The cycle-1 deep-hole spectrum theorem, re-derived from the characteristic-vector law. -/
theorem deepHole_spectrum_via_characteristic (m : Fin n → ℤ) :
    ∃ k : ℤ, form (1 : Matrix (Fin n) (Fin n) ℚ) (fun i => deepHole n i - emb m i)
      = (n : ℚ) / 4 + 2 * k := by
  obtain ⟨k, hk⟩ := characteristic_shifted_spectrum one_matrix_isSymm
    (standard_allOnes_characteristic (n := n)) m
  refine ⟨k, ?_⟩
  have hQ : zform (1 : Matrix (Fin n) (Fin n) ℤ) (allOnes n) = (n : ℤ) := by
    rw [zform, zbil_one_matrix]
    simp [allOnes, card_univ]
  have hB : toRat (1 : Matrix (Fin n) (Fin n) ℤ) = (1 : Matrix (Fin n) (Fin n) ℚ) := by
    funext i j
    rcases eq_or_ne i j with h | h
    · simp [toRat, Matrix.one_apply, h]
    · simp [toRat, h]
  rw [halfPt_allOnes, hB, hQ] at hk
  exact hk

end DiophantineLattice