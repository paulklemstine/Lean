import Tropical.EtaQuotientHeadStructure

/-!
# The second coefficient `c(2)` of a normalised eta quotient

Continuation of `Catalog/Tropical/EtaQuotientHeadCoeff.lean`.  There the head
coefficient `c(1)` of

  `q / η_a = ∏_m (1 - q^m)^{-b m}`,  `b m = ∑_{k ∣ m} a k`

was computed.  Here the calculus is pushed one degree further, to the coefficient of
`q³` in the product, i.e. to `c(2)` in the indexing `1/η_a = q^{-1} + c(0) + c(1) q
+ c(2) q² + ⋯`.

The answer (`coeff_three_etaQuotientProd`) is

  `c(2) = a₁(a₁+1)(a₁+2)/6 + a₁(a₁+a₂) + a₁ + a₃`.

Structurally: `c(2)` is the *third* invariant of the unipotent (Heisenberg-type)
group of `3`-jets of units of `ℤ⟦X⟧`; the extra ingredient beyond the `2`-jet
calculus is the tetrahedral number `Tet n = C(n,3)`, entering through the
`zpow` law `u^n ↦ (n c₁, n c₂ + C(n,2) c₁², n c₃ + n(n-1) c₁c₂ + C(n,3) c₁³)`.

Sanity check: for `Δ = η^{24}` (`a₁ = 24`) the formula returns `3200`, the known
coefficient in `1/Δ = q⁻¹ + 24 + 324 q + 3200 q² + ⋯` (`coeff_three_delta`).
-/

namespace EtaHead

open PowerSeries Finset

/-! ## Tetrahedral numbers -/

/-- `Tet n = n(n-1)(n-2)/6`, i.e. `C(n,3)` extended to all integers. -/
def Tet (n : ℤ) : ℤ := n * (n - 1) * (n - 2) / 6

lemma six_dvd_prod_three (n : ℤ) : (6 : ℤ) ∣ n * (n - 1) * (n - 2) := by
  have h : ((n * (n - 1) * (n - 2) : ℤ) : ZMod 6) = 0 := by
    push_cast
    generalize ((n : ZMod 6)) = x
    revert x
    decide
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ 6).mp h

lemma six_mul_Tet (n : ℤ) : 6 * Tet n = n * (n - 1) * (n - 2) := by
  have h := six_dvd_prod_three n
  unfold Tet
  omega

lemma Tet_succ (n : ℤ) : Tet (n + 1) = Tet n + Tri n := by
  have h1 := six_mul_Tet (n + 1)
  have h2 := six_mul_Tet n
  have h3 := two_mul_Tri n
  have e : (n + 1) * (n + 1 - 1) * (n + 1 - 2) = n * (n - 1) * (n - 2) + 3 * (n * (n - 1)) := by
    ring
  omega

lemma Tet_pred (n : ℤ) : Tet (n - 1) = Tet n - Tri (n - 1) := by
  have h := Tet_succ (n - 1)
  have e : n - 1 + 1 = n := by ring
  rw [e] at h
  omega

/-! ## 3-jets -/

/-- `Jet3 f c₁ c₂ c₃` records that `f = 1 + c₁X + c₂X² + c₃X³ + O(X⁴)`. -/
def Jet3 (f : PowerSeries ℤ) (c1 c2 c3 : ℤ) : Prop := Jet f c1 c2 ∧ coeff 3 f = c3

lemma coeff_three_mul (f g : PowerSeries ℤ) :
    coeff 3 (f * g) = coeff 0 f * coeff 3 g + coeff 1 f * coeff 2 g
      + coeff 2 f * coeff 1 g + coeff 3 f * coeff 0 g := by
  rw [coeff_mul]; simp [Finset.antidiagonal]; ring

lemma Jet3.one : Jet3 1 0 0 0 := ⟨Jet.one, by simp [PowerSeries.coeff_one]⟩

lemma Jet3.mul {f g : PowerSeries ℤ} {c1 c2 c3 d1 d2 d3 : ℤ}
    (hf : Jet3 f c1 c2 c3) (hg : Jet3 g d1 d2 d3) :
    Jet3 (f * g) (c1 + d1) (c2 + c1 * d1 + d2) (c3 + c2 * d1 + c1 * d2 + d3) := by
  obtain ⟨⟨hf0, hf1, hf2⟩, hf3⟩ := hf
  obtain ⟨⟨hg0, hg1, hg2⟩, hg3⟩ := hg
  refine ⟨Jet.mul ⟨hf0, hf1, hf2⟩ ⟨hg0, hg1, hg2⟩, ?_⟩
  rw [← coeff_zero_eq_constantCoeff_apply] at hf0 hg0
  rw [coeff_three_mul, hf0, hg0, hf1, hg1, hf2, hg2, hf3, hg3]
  ring

lemma Jet3.inv {u : (PowerSeries ℤ)ˣ} {c1 c2 c3 : ℤ} (hu : Jet3 (u : PowerSeries ℤ) c1 c2 c3) :
    Jet3 ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) (-c1) (c1 ^ 2 - c2)
      (-c3 + 2 * c1 * c2 - c1 ^ 3) := by
  obtain ⟨hu2, hu3⟩ := hu
  obtain ⟨hu0, hu1, hu2'⟩ := hu2
  have hinv := Jet.inv (u := u) ⟨hu0, hu1, hu2'⟩
  obtain ⟨hi0, hi1, hi2⟩ := hinv
  refine ⟨⟨hi0, hi1, hi2⟩, ?_⟩
  have hmul : (u : PowerSeries ℤ) * (u⁻¹ : (PowerSeries ℤ)ˣ) = 1 := u.mul_inv
  have hu0' : coeff 0 (u : PowerSeries ℤ) = 1 := by
    rw [coeff_zero_eq_constantCoeff_apply]; exact hu0
  have hi0' : coeff 0 ((u⁻¹ : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 1 := by
    rw [coeff_zero_eq_constantCoeff_apply]; exact hi0
  have h := congrArg (fun f => coeff 3 f) hmul
  simp only [coeff_three_mul, hu0', hi0', hu1, hu2', hu3, hi1, hi2] at h
  simp [PowerSeries.coeff_one] at h
  nlinarith [h]

lemma Jet3.zpow {u : (PowerSeries ℤ)ˣ} {c1 c2 c3 : ℤ} (hu : Jet3 (u : PowerSeries ℤ) c1 c2 c3) :
    ∀ n : ℤ, Jet3 ((u ^ n : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) (n * c1)
      (n * c2 + Tri n * c1 ^ 2) (n * c3 + n * (n - 1) * c1 * c2 + Tet n * c1 ^ 3) := by
  intro n
  induction n using Int.induction_on with
  | zero =>
      have h1 : (0 : ℤ) * c1 = 0 := by ring
      have h2 : (0 : ℤ) * c2 + Tri 0 * c1 ^ 2 = 0 := by rw [Tri_zero]; ring
      have h3 : (0 : ℤ) * c3 + 0 * (0 - 1) * c1 * c2 + Tet 0 * c1 ^ 3 = 0 := by
        have : Tet 0 = 0 := by unfold Tet; decide
        rw [this]; ring
      rw [zpow_zero, Units.val_one, h1, h2, h3]
      exact Jet3.one
  | succ k ih =>
      have hstep := ih.mul hu
      have e1 : ((k : ℤ) + 1) * c1 = (k : ℤ) * c1 + c1 := by ring
      have e2 : ((k : ℤ) + 1) * c2 + Tri ((k : ℤ) + 1) * c1 ^ 2
          = ((k : ℤ) * c2 + Tri (k : ℤ) * c1 ^ 2) + ((k : ℤ) * c1) * c1 + c2 := by
        rw [Tri_succ]; ring
      have e3 : ((k : ℤ) + 1) * c3 + ((k : ℤ) + 1) * ((k : ℤ) + 1 - 1) * c1 * c2
            + Tet ((k : ℤ) + 1) * c1 ^ 3
          = ((k : ℤ) * c3 + (k : ℤ) * ((k : ℤ) - 1) * c1 * c2 + Tet (k : ℤ) * c1 ^ 3)
            + ((k : ℤ) * c2 + Tri (k : ℤ) * c1 ^ 2) * c1 + ((k : ℤ) * c1) * c2 + c3 := by
        rw [Tet_succ]; ring
      rw [zpow_add_one, Units.val_mul, e1, e2, e3]
      exact hstep
  | pred k ih =>
      have hstep := ih.mul hu.inv
      have e1 : (-(k : ℤ) - 1) * c1 = (-(k : ℤ)) * c1 + -c1 := by ring
      have e2 : (-(k : ℤ) - 1) * c2 + Tri (-(k : ℤ) - 1) * c1 ^ 2
          = ((-(k : ℤ)) * c2 + Tri (-(k : ℤ)) * c1 ^ 2) + ((-(k : ℤ)) * c1) * (-c1)
            + (c1 ^ 2 - c2) := by
        rw [Tri_pred]; ring
      have e3 : (-(k : ℤ) - 1) * c3 + (-(k : ℤ) - 1) * ((-(k : ℤ) - 1) - 1) * c1 * c2
            + Tet (-(k : ℤ) - 1) * c1 ^ 3
          = ((-(k : ℤ)) * c3 + (-(k : ℤ)) * ((-(k : ℤ)) - 1) * c1 * c2
              + Tet (-(k : ℤ)) * c1 ^ 3)
            + ((-(k : ℤ)) * c2 + Tri (-(k : ℤ)) * c1 ^ 2) * (-c1)
            + ((-(k : ℤ)) * c1) * (c1 ^ 2 - c2) + (-c3 + 2 * c1 * c2 - c1 ^ 3) := by
        rw [Tet_pred, Tri_pred]; ring
      rw [zpow_sub_one, Units.val_mul, e1, e2, e3]
      exact hstep

lemma Jet3.zpow_trivial {u : (PowerSeries ℤ)ˣ} (hu : Jet3 (u : PowerSeries ℤ) 0 0 0) (n : ℤ) :
    Jet3 ((u ^ n : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 0 0 := by
  have h := hu.zpow n
  simpa using h

lemma Jet3.mul_right_trivial {f g : PowerSeries ℤ} {c1 c2 c3 : ℤ}
    (hf : Jet3 f c1 c2 c3) (hg : Jet3 g 0 0 0) : Jet3 (f * g) c1 c2 c3 := by
  have h := hf.mul hg
  simpa using h

lemma Jet3.mul_left_trivial {f g : PowerSeries ℤ} {c1 c2 c3 : ℤ}
    (hf : Jet3 f 0 0 0) (hg : Jet3 g c1 c2 c3) : Jet3 (f * g) c1 c2 c3 := by
  have h := hf.mul hg
  simpa using h

lemma Jet3.prod_trivial {ι : Type*} {s : Finset ι} {f : ι → PowerSeries ℤ}
    (h : ∀ i ∈ s, Jet3 (f i) 0 0 0) : Jet3 (∏ i ∈ s, f i) 0 0 0 := by
  classical
  induction s using Finset.induction with
  | empty => simpa using Jet3.one
  | insert i s hi ih =>
      rw [Finset.prod_insert hi]
      exact (h i (by simp)).mul_left_trivial (ih fun j hj => h j (by simp [hj]))

lemma Jet3.prod_units_trivial {ι : Type*} {s : Finset ι} {u : ι → (PowerSeries ℤ)ˣ}
    (h : ∀ i ∈ s, Jet3 ((u i : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 0 0) :
    Jet3 ((∏ i ∈ s, u i : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 0 0 := by
  rw [Units.coe_prod]
  exact Jet3.prod_trivial h

/-! ## 3-jets of the basic units -/

lemma jet3_oneSubXPow_one : Jet3 ((oneSubXPow 1 : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) (-1) 0 0 := by
  refine ⟨jet_oneSubXPow_one, ?_⟩
  rw [coe_oneSubXPow (le_refl 1), coeff_one_sub_X_pow 3 1]
  norm_num

lemma jet3_oneSubXPow_two : Jet3 ((oneSubXPow 2 : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 (-1) 0 := by
  refine ⟨jet_oneSubXPow_two, ?_⟩
  rw [coe_oneSubXPow (by norm_num), coeff_one_sub_X_pow 3 2]
  norm_num

lemma jet3_oneSubXPow_three :
    Jet3 ((oneSubXPow 3 : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 0 (-1) := by
  refine ⟨jet_oneSubXPow_ge_three (le_refl 3), ?_⟩
  rw [coe_oneSubXPow (by norm_num), coeff_one_sub_X_pow 3 3]
  norm_num

lemma jet3_oneSubXPow_ge_four {m : ℕ} (hm : 4 ≤ m) :
    Jet3 ((oneSubXPow m : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 0 0 := by
  refine ⟨jet_oneSubXPow_ge_three (by omega), ?_⟩
  rw [coe_oneSubXPow (by omega), coeff_one_sub_X_pow 3 m]
  have h3 : ¬ (3 = m) := by omega
  simp [h3]

/-! ## The divisor sum at `3` and the second coefficient -/

lemma bCoeff_three (a : ℕ → ℤ) : bCoeff a 3 = a 1 + a 3 := by
  have h : (3 : ℕ).divisors = {1, 3} := by decide
  rw [bCoeff, h]
  simp

/-- The second coefficient `c(2) = a₁(a₁+1)(a₁+2)/6 + a₁(a₁+a₂) + a₁ + a₃`. -/
def secondCoeff (a : ℕ → ℤ) : ℤ :=
  a 1 * (a 1 + 1) * (a 1 + 2) / 6 + a 1 * (a 1 + a 2) + a 1 + a 3

lemma six_mul_secondCoeff (a : ℕ → ℤ) :
    6 * secondCoeff a = a 1 * (a 1 + 1) * (a 1 + 2)
      + 6 * (a 1 * (a 1 + a 2)) + 6 * a 1 + 6 * a 3 := by
  have h : (6 : ℤ) ∣ a 1 * (a 1 + 1) * (a 1 + 2) := by
    have h6 := six_dvd_prod_three (a 1 + 2)
    have e : (a 1 + 2) * (a 1 + 2 - 1) * (a 1 + 2 - 2) = a 1 * (a 1 + 1) * (a 1 + 2) := by ring
    rwa [e] at h6
  unfold secondCoeff
  omega

lemma neg_Tet_neg (b : ℤ) : -Tet (-b) = b * (b + 1) * (b + 2) / 6 := by
  have h1 := six_mul_Tet (-b)
  have h2 : (6 : ℤ) ∣ b * (b + 1) * (b + 2) := by
    have h6 := six_dvd_prod_three (b + 2)
    have e : (b + 2) * (b + 2 - 1) * (b + 2 - 2) = b * (b + 1) * (b + 2) := by ring
    rwa [e] at h6
  have e2 : (-b) * (-b - 1) * (-b - 2) = -(b * (b + 1) * (b + 2)) := by ring
  rw [e2] at h1
  omega

/-! ## The main computation in degree 3 -/

/-- The `3`-jet of the truncated eta quotient. -/
theorem jet3_etaQuotientProd (a : ℕ → ℤ) {N : ℕ} (hN : 3 ≤ N) :
    Jet3 ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      (a 1) (headCoeff a) (secondCoeff a) := by
  induction N with
  | zero => omega
  | succ N ih =>
      rcases Nat.lt_or_ge N 3 with hlt | hge
      · -- base case `N + 1 = 3`
        have hN3 : N = 2 := by omega
        subst hN3
        have hIcc : Icc 1 3 = ({1, 2, 3} : Finset ℕ) := by decide
        rw [etaQuotientProd, hIcc, Finset.prod_insert (by decide),
          Finset.prod_insert (by decide), Finset.prod_singleton, Units.val_mul, Units.val_mul,
          bCoeff_one, bCoeff_two, bCoeff_three]
        have h1 := jet3_oneSubXPow_one.zpow (-(bCoeff a 1))
        have h2 := jet3_oneSubXPow_two.zpow (-(bCoeff a 2))
        have h3 := jet3_oneSubXPow_three.zpow (-(bCoeff a 3))
        have hcomb := h1.mul (h2.mul h3)
        rw [bCoeff_one, bCoeff_two, bCoeff_three] at hcomb
        obtain ⟨⟨hc0, hc1, hc2⟩, hc3⟩ := hcomb
        refine ⟨⟨hc0, ?_, ?_⟩, ?_⟩
        · rw [hc1]; ring
        · rw [hc2]
          linarith [two_mul_Tri (-(a 1)), two_mul_headCoeff a]
        · rw [hc3]
          have hTet := neg_Tet_neg (a 1)
          simp only [secondCoeff, ← hTet]
          ring
      · -- inductive step: the new factor is `1` modulo `X⁴`
        have hih : Jet3 ((∏ m ∈ Icc 1 N, (oneSubXPow m) ^ (-(bCoeff a m)) :
            (PowerSeries ℤ)ˣ) : PowerSeries ℤ) (a 1) (headCoeff a) (secondCoeff a) :=
          ih (by omega)
        have hins : Icc 1 (N + 1) = insert (N + 1) (Icc 1 N) :=
          (Finset.insert_Icc_right_eq_Icc_add_one (by omega)).symm
        rw [etaQuotientProd, hins, Finset.prod_insert (by simp), Units.val_mul]
        have hnew := (jet3_oneSubXPow_ge_four (m := N + 1) (by omega)).zpow_trivial
          (-(bCoeff a (N + 1)))
        exact hnew.mul_left_trivial hih

/-- **Second coefficient of the eta quotient.**
`c(2) = a₁(a₁+1)(a₁+2)/6 + a₁(a₁+a₂) + a₁ + a₃`, for every truncation `N ≥ 3`. -/
theorem coeff_three_etaQuotientProd (a : ℕ → ℤ) {N : ℕ} (hN : 3 ≤ N) :
    coeff 3 ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = a 1 * (a 1 + 1) * (a 1 + 2) / 6 + a 1 * (a 1 + a 2) + a 1 + a 3 :=
  (jet3_etaQuotientProd a hN).2

/-- The value is independent of the truncation `N ≥ 3`. -/
theorem coeff_three_etaQuotientProd_stable (a : ℕ → ℤ) {N M : ℕ} (hN : 3 ≤ N) (hM : 3 ≤ M) :
    coeff 3 ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      = coeff 3 ((etaQuotientProd a M : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  rw [coeff_three_etaQuotientProd a hN, coeff_three_etaQuotientProd a hM]

/-- `1/Δ = q⁻¹ + 24 + 324 q + 3200 q² + ⋯`: the degree-`3` coefficient of the
normalised eta quotient of `Δ` is `3200`, matching the classical expansion. -/
theorem coeff_three_delta {N : ℕ} (hN : 3 ≤ N) :
    coeff 3 ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 3200 := by
  rw [coeff_three_etaQuotientProd deltaExp hN]
  norm_num [deltaExp]

end EtaHead