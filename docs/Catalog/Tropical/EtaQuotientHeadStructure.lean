import Tropical.EtaQuotientHeadCoeff

/-!
# Structure of the head coefficient map

This file builds on `Catalog/Tropical/EtaQuotientHeadCoeff.lean`, where the head
coefficient of the normalised eta quotient

  `q / η_a = ∏_m (1 - q^m)^{-b m}`,  `b m = ∑_{k ∣ m} a k`

was computed to be `c(1) = a₁(a₁+3)/2 + a₂`.  Here we establish the structural
properties of the map `a ↦ (c(0), c(1)) = (a₁, headCoeff a)`.

Main results:

* `etaQuotientProd_add` : exponent vectors add, eta quotients multiply — the
  truncated eta quotients form a group homomorphic image of `(ℕ → ℤ, +)`.
* `headCoeff_add` : the *Heisenberg cocycle*
  `headCoeff (a + a') = headCoeff a + headCoeff a' + a₁ a'₁`;
  the head coefficient is not additive, its defect is the symmetric-bilinear
  term `a₁ a'₁`, exactly the `2`-jet group law of `ℤ⟦X⟧ˣ`.
* `jet_etaProdRaw`, `jet_etaDenomProd`, `etaProdRaw_mul_etaQuotientProd_jet_trivial` :
  the **divisor regrouping** `∏_k (∏_n (1 - X^{kn}))^{a k} = ∏_m (1 - X^m)^{b m}`,
  verified in degrees `≤ 2`.  This is the step that identifies the product used in
  the main theorem with the actual eta quotient `η_a / q`.
* `pure_headCoeff_iff_sq` : Diophantine description of the head coefficients of
  pure level-one eta powers (`a₂ = 0`): they are the `c` with `8c + 9` a square.
* `headCoeff_surjective`, `exists_admissible_headCoeff` : every integer occurs as
  a head coefficient of an admissible (`∑ k a k = 24`) exponent vector.
* `headCoeff_delta` : the classical `1/Δ = q⁻¹ + 24 + 324 q + ⋯`.
-/

namespace EtaHead

open PowerSeries Finset

/-! ## The weight `∑ k · a k` -/

/-- The weight `∑_{k=1}^{N} k · a k`.  Admissibility of an eta quotient
`η_a = ∏ η(kτ)^{a k}` for the normalisation `q/η_a` is `weight a N = 24`. -/
def weight (a : ℕ → ℤ) (N : ℕ) : ℤ := ∑ k ∈ Icc 1 N, (k : ℤ) * a k

lemma weight_add (a a' : ℕ → ℤ) (N : ℕ) :
    weight (a + a') N = weight a N + weight a' N := by
  simp [weight, Pi.add_apply, mul_add, Finset.sum_add_distrib]

/-! ## Multiplicativity and the Heisenberg cocycle -/

lemma bCoeff_add (a a' : ℕ → ℤ) (m : ℕ) :
    bCoeff (a + a') m = bCoeff a m + bCoeff a' m := by
  simp [bCoeff, Pi.add_apply, Finset.sum_add_distrib]

/-- Exponent vectors add, eta quotients multiply. -/
theorem etaQuotientProd_add (a a' : ℕ → ℤ) (N : ℕ) :
    etaQuotientProd (a + a') N = etaQuotientProd a N * etaQuotientProd a' N := by
  rw [etaQuotientProd, etaQuotientProd, etaQuotientProd, ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun m _ => ?_
  rw [bCoeff_add, neg_add, zpow_add]

/-- **Heisenberg cocycle.**  The head coefficient is a quadratic (not additive)
function of the exponent vector: its additivity defect is `a₁ · a'₁`, which is
precisely the commutator term of the `2`-jet group law on `ℤ⟦X⟧ˣ`. -/
theorem headCoeff_add (a a' : ℕ → ℤ) :
    headCoeff (a + a') = headCoeff a + headCoeff a' + a 1 * a' 1 := by
  have h1 := two_mul_headCoeff a
  have h2 := two_mul_headCoeff a'
  have h3 := two_mul_headCoeff (a + a')
  simp only [Pi.add_apply] at h3
  have e : (a 1 + a' 1) * (a 1 + a' 1 + 3) + 2 * (a 2 + a' 2)
      = (a 1 * (a 1 + 3) + 2 * a 2) + (a' 1 * (a' 1 + 3) + 2 * a' 2)
        + 2 * (a 1 * a' 1) := by ring
  omega

/-- The `2`-jet of an eta quotient packaged as a unipotent integer matrix. -/
def headMatrix (a : ℕ → ℤ) : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, a 1, headCoeff a; 0, 1, a 1; 0, 0, 1]

/-- **Cross-domain bridge: eta quotients → the integer Heisenberg group.**
`a ↦ headMatrix a` is a homomorphism from the additive group of exponent vectors to
the (multiplicative) Heisenberg group of unipotent `3 × 3` integer matrices; the upper
right entry is the head coefficient and the multiplication rule reproduces the
`2`-jet law of `ℤ⟦X⟧ˣ`. -/
theorem headMatrix_add (a a' : ℕ → ℤ) :
    headMatrix (a + a') = headMatrix a * headMatrix a' := by
  simp only [headMatrix, Matrix.mul_fin_three, Pi.add_apply, headCoeff_add]
  norm_num
  refine ⟨⟨by ring, by ring⟩, by ring⟩

/-- The head matrices are unipotent, hence lie in `SL₃(ℤ)`. -/
theorem headMatrix_det (a : ℕ → ℤ) : (headMatrix a).det = 1 := by
  simp [headMatrix, Matrix.det_fin_three]

/-! ## Divisor regrouping: the product really is the eta quotient -/

/-- `∏_{n=1}^{N} (1 - X^{k n})`: the truncated `q`-product part of `η(kτ)`. -/
noncomputable def etaFactorProd (k N : ℕ) : (PowerSeries ℤ)ˣ :=
  ∏ n ∈ Icc 1 N, oneSubXPow (k * n)

/-- The truncated eta product `∏_k (∏_n (1 - X^{kn}))^{a k}`, i.e. `η_a / q`
without the `q`-power normalisation. -/
noncomputable def etaProdRaw (a : ℕ → ℤ) (N : ℕ) : (PowerSeries ℤ)ˣ :=
  ∏ k ∈ Icc 1 N, (etaFactorProd k N) ^ (a k)

/-- The divisor-sum form `∏_m (1 - X^m)^{b m}` of the same product. -/
noncomputable def etaDenomProd (a : ℕ → ℤ) (N : ℕ) : (PowerSeries ℤ)ˣ :=
  ∏ m ∈ Icc 1 N, (oneSubXPow m) ^ (bCoeff a m)

lemma etaQuotientProd_eq_inv (a : ℕ → ℤ) (N : ℕ) :
    etaQuotientProd a N = (etaDenomProd a N)⁻¹ := by
  rw [etaQuotientProd, etaDenomProd, ← Finset.prod_inv_distrib]
  exact Finset.prod_congr rfl fun m _ => by rw [← zpow_neg]

lemma jet_etaFactorProd_one {N : ℕ} (hN : 2 ≤ N) :
    Jet ((etaFactorProd 1 N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) (-1) (-1) := by
  induction N with
  | zero => omega
  | succ N ih =>
      rcases Nat.lt_or_ge N 2 with hlt | hge
      · have hN2 : N = 1 := by omega
        subst hN2
        have hIcc : Icc 1 2 = ({1, 2} : Finset ℕ) := by decide
        rw [etaFactorProd, hIcc, Finset.prod_insert (by decide), Finset.prod_singleton,
          Units.val_mul]
        have h := jet_oneSubXPow_one.mul jet_oneSubXPow_two
        norm_num at h ⊢
        simpa using h
      · have hih : Jet ((∏ n ∈ Icc 1 N, oneSubXPow (1 * n) : (PowerSeries ℤ)ˣ) :
            PowerSeries ℤ) (-1) (-1) := ih (by omega)
        have hins : Icc 1 (N + 1) = insert (N + 1) (Icc 1 N) :=
          (Finset.insert_Icc_right_eq_Icc_add_one (by omega)).symm
        rw [etaFactorProd, hins, Finset.prod_insert (by simp), Units.val_mul]
        have hnew : Jet ((oneSubXPow (1 * (N + 1)) : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 0 := by
          rw [one_mul]
          exact jet_oneSubXPow_ge_three (by omega)
        exact hnew.mul_left_trivial hih

lemma jet_etaFactorProd_two {N : ℕ} (hN : 1 ≤ N) :
    Jet ((etaFactorProd 2 N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 (-1) := by
  induction N with
  | zero => omega
  | succ N ih =>
      rcases Nat.lt_or_ge N 1 with hlt | hge
      · have hN1 : N = 0 := by omega
        subst hN1
        have hIcc : Icc 1 1 = ({1} : Finset ℕ) := by decide
        rw [etaFactorProd, hIcc, Finset.prod_singleton]
        norm_num
        exact jet_oneSubXPow_two
      · have hih : Jet ((∏ n ∈ Icc 1 N, oneSubXPow (2 * n) : (PowerSeries ℤ)ˣ) :
            PowerSeries ℤ) 0 (-1) := ih (by omega)
        have hins : Icc 1 (N + 1) = insert (N + 1) (Icc 1 N) :=
          (Finset.insert_Icc_right_eq_Icc_add_one (by omega)).symm
        rw [etaFactorProd, hins, Finset.prod_insert (by simp), Units.val_mul]
        have hnew : Jet ((oneSubXPow (2 * (N + 1)) : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 0 :=
          jet_oneSubXPow_ge_three (by omega)
        exact hnew.mul_left_trivial hih

lemma jet_etaFactorProd_ge_three {k N : ℕ} (hk : 3 ≤ k) :
    Jet ((etaFactorProd k N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) 0 0 := by
  rw [etaFactorProd]
  refine Jet.prod_units_trivial fun n hn => ?_
  rw [Finset.mem_Icc] at hn
  exact jet_oneSubXPow_ge_three (by nlinarith [hn.1, hn.2])

lemma Icc_one_split {N : ℕ} (hN : 2 ≤ N) :
    Icc 1 N = insert 1 (insert 2 (Icc 3 N)) := by
  ext x
  simp only [Finset.mem_Icc, Finset.mem_insert]
  omega

/-- The `2`-jet of the genuine (truncated) eta product `∏_k (∏_n (1 - X^{kn}))^{a k}`. -/
theorem jet_etaProdRaw (a : ℕ → ℤ) {N : ℕ} (hN : 2 ≤ N) :
    Jet ((etaProdRaw a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) (-(a 1)) (Tri (a 1) - a 1 - a 2) := by
  rw [etaProdRaw, Icc_one_split hN, Finset.prod_insert (by simp),
    Finset.prod_insert (by simp), Units.val_mul, Units.val_mul]
  have h1 := (jet_etaFactorProd_one hN).zpow (a 1)
  have h2 := (jet_etaFactorProd_two (N := N) (by omega)).zpow (a 2)
  have htail : Jet ((∏ k ∈ Icc 3 N, (etaFactorProd k N) ^ (a k) : (PowerSeries ℤ)ˣ) :
      PowerSeries ℤ) 0 0 := by
    refine Jet.prod_units_trivial fun k hk => ?_
    rw [Finset.mem_Icc] at hk
    exact (jet_etaFactorProd_ge_three hk.1).zpow_trivial (a k)
  have hcomb := h1.mul (h2.mul_right_trivial htail)
  have e1 : a 1 * (-1 : ℤ) + a 2 * 0 = -(a 1) := by ring
  have e2 : (a 1 * (-1 : ℤ) + Tri (a 1) * (-1 : ℤ) ^ 2) + (a 1 * (-1 : ℤ)) * (a 2 * 0)
      + (a 2 * (-1 : ℤ) + Tri (a 2) * (0 : ℤ) ^ 2) = Tri (a 1) - a 1 - a 2 := by ring
  rw [e1, e2] at hcomb
  exact hcomb

/-- The `2`-jet of the divisor-sum product `∏_m (1 - X^m)^{b m}`: the *same* as the
jet of the eta product, which is the degree `≤ 2` shadow of the divisor regrouping. -/
theorem jet_etaDenomProd (a : ℕ → ℤ) {N : ℕ} (hN : 2 ≤ N) :
    Jet ((etaDenomProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) (-(a 1))
      (Tri (a 1) - a 1 - a 2) := by
  rw [etaDenomProd, Icc_one_split hN, Finset.prod_insert (by simp),
    Finset.prod_insert (by simp), Units.val_mul, Units.val_mul]
  have h1 := jet_oneSubXPow_one.zpow (bCoeff a 1)
  have h2 := jet_oneSubXPow_two.zpow (bCoeff a 2)
  have htail : Jet ((∏ m ∈ Icc 3 N, (oneSubXPow m) ^ (bCoeff a m) : (PowerSeries ℤ)ˣ) :
      PowerSeries ℤ) 0 0 := by
    refine Jet.prod_units_trivial fun m hm => ?_
    rw [Finset.mem_Icc] at hm
    exact (jet_oneSubXPow_ge_three hm.1).zpow_trivial (bCoeff a m)
  have hcomb := h1.mul (h2.mul_right_trivial htail)
  have e1 : bCoeff a 1 * (-1 : ℤ) + bCoeff a 2 * 0 = -(a 1) := by
    rw [bCoeff_one]; ring
  have e2 : (bCoeff a 1 * 0 + Tri (bCoeff a 1) * (-1 : ℤ) ^ 2)
      + (bCoeff a 1 * (-1 : ℤ)) * (bCoeff a 2 * 0)
      + (bCoeff a 2 * (-1 : ℤ) + Tri (bCoeff a 2) * (0 : ℤ) ^ 2)
        = Tri (a 1) - a 1 - a 2 := by
    rw [bCoeff_one, bCoeff_two]
    ring
  rw [e1, e2] at hcomb
  exact hcomb

/-- **Divisor regrouping, degree `≤ 2`.**  The eta product and its divisor-sum
form have the same coefficients in degrees `1` and `2`. -/
theorem eta_regrouping_jet (a : ℕ → ℤ) {N : ℕ} (hN : 2 ≤ N) :
    coeff 1 ((etaProdRaw a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
        = coeff 1 ((etaDenomProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) ∧
      coeff 2 ((etaProdRaw a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
        = coeff 2 ((etaDenomProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) := by
  obtain ⟨-, h1, h2⟩ := jet_etaProdRaw a hN
  obtain ⟨-, g1, g2⟩ := jet_etaDenomProd a hN
  exact ⟨by rw [h1, g1], by rw [h2, g2]⟩

/-- **Consistency of the normalisation.**  `(η_a/q) · (q/η_a) = 1` in degrees `≤ 2`,
where `q/η_a` is computed by the divisor-sum product whose head coefficient is
`headCoeff a`.  This ties the main theorem to the actual eta product. -/
theorem etaProdRaw_mul_etaQuotientProd_jet_trivial (a : ℕ → ℤ) {N : ℕ} (hN : 2 ≤ N) :
    Jet (((etaProdRaw a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)
      * ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ)) 0 0 := by
  have h := (jet_etaProdRaw a hN).mul (jet_etaQuotientProd a hN)
  have e1 : -(a 1) + a 1 = 0 := by ring
  have e2 : (Tri (a 1) - a 1 - a 2) + (-(a 1)) * (a 1) + headCoeff a = 0 := by
    have hT := two_mul_Tri (a 1)
    have hH := two_mul_headCoeff a
    linarith
  rw [e1, e2] at h
  exact h

/-! ## Which integers are head coefficients? -/

lemma two_dvd_pure (n : ℤ) : (2 : ℤ) ∣ n * (n + 3) := by
  rcases Int.even_or_odd n with he | ho
  · obtain ⟨k, hk⟩ := he; exact ⟨k * (n + 3), by rw [hk]; ring⟩
  · obtain ⟨k, hk⟩ := ho; exact ⟨(2 * k + 1) * (k + 2), by rw [hk]; ring⟩

/-- **Integrality rigidity.**  A pure (`a₂ = 0`) head coefficient is never smaller than
`-1`: the real minimum `-9/8` of `x(x+3)/2` is not attained at an integer, and the
integer minimum `-1` is attained exactly at `a₁ = -1` and `a₁ = -2`. -/
theorem pure_headCoeff_ge_neg_one (n : ℤ) : -1 ≤ n * (n + 3) / 2 := by
  have hd := two_dvd_pure n
  have h : (n + 1) * (n + 2) ≥ 0 := by
    rcases le_or_gt (-1 : ℤ) n with h1 | h1
    · nlinarith
    · nlinarith
  have h2 : n * (n + 3) ≥ -2 := by nlinarith
  omega

/-- **Reflection symmetry.**  Two pure eta powers have the same head coefficient exactly
when their exponents agree or are exchanged by the reflection `n ↦ -3 - n`. -/
theorem pure_headCoeff_eq_iff (n n' : ℤ) :
    n * (n + 3) / 2 = n' * (n' + 3) / 2 ↔ n' = n ∨ n' = -3 - n := by
  have hd := two_dvd_pure n
  have hd' := two_dvd_pure n'
  constructor
  · intro h
    have h2 : n * (n + 3) = n' * (n' + 3) := by omega
    have hf : (n - n') * (n + n' + 3) = 0 := by nlinarith
    rcases mul_eq_zero.mp hf with h3 | h3
    · left; omega
    · right; omega
  · rintro (rfl | rfl)
    · rfl
    · have h2 : (-3 - n) * ((-3 - n) + 3) = n * (n + 3) := by ring
      rw [h2]

/-- **Diophantine characterisation of pure level-one head coefficients.**
For `a₂ = 0` (i.e. `η(τ)^{a₁}` type quotients) the achievable head coefficients are
exactly the `c` for which `8c + 9` is a perfect square. -/
theorem pure_headCoeff_iff_sq (c : ℤ) :
    (∃ n : ℤ, n * (n + 3) / 2 = c) ↔ ∃ s : ℤ, s ^ 2 = 8 * c + 9 := by
  constructor
  · rintro ⟨n, hn⟩
    have hdvd := two_dvd_pure n
    refine ⟨2 * n + 3, ?_⟩
    have h2 : 2 * c = n * (n + 3) := by omega
    nlinarith [h2]
  · rintro ⟨s, hs⟩
    obtain ⟨u, hu⟩ : ∃ u : ℤ, s = 2 * u + 1 := by
      rcases Int.even_or_odd s with he | ho
      · obtain ⟨k, hk⟩ := he
        exfalso
        have h4 : 2 * (2 * k ^ 2) = 8 * c + 9 := by rw [← hs, hk]; ring
        omega
      · obtain ⟨k, hk⟩ := ho; exact ⟨k, hk⟩
    subst hu
    refine ⟨u - 1, ?_⟩
    have key : (u - 1) * (u - 1 + 3) = 2 * c := by nlinarith [hs]
    omega

/-- Not every integer is a pure (`a₂ = 0`) head coefficient: `1` is not. -/
theorem one_not_pure_headCoeff : ¬ ∃ n : ℤ, n * (n + 3) / 2 = 1 := by
  rw [pure_headCoeff_iff_sq]
  rintro ⟨s, hs⟩
  have h : s ^ 2 = 17 := by omega
  have h4 : s ≤ 4 ∧ -4 ≤ s := by constructor <;> nlinarith [sq_nonneg (s - 4), sq_nonneg (s + 4)]
  obtain ⟨h5, h6⟩ := h4
  interval_cases s <;> omega

/-- **Surjectivity of the head coefficient on admissible exponent vectors.**
Every integer `c` is the head coefficient of a finitely supported `a` satisfying the
normalisation `∑ k · a k = 24`. -/
theorem headCoeff_surjective (c : ℤ) :
    ∃ a : ℕ → ℤ, (∀ k, 5 ≤ k → a k = 0) ∧ a 0 = 0 ∧ weight a 4 = 24 ∧ headCoeff a = c := by
  refine ⟨fun k => if k = 2 then c else if k = 3 then 2 * c - 24 else
    if k = 4 then 24 - 2 * c else 0, ?_, ?_, ?_, ?_⟩
  · intro k hk
    have h2 : k ≠ 2 := by omega
    have h3 : k ≠ 3 := by omega
    have h4 : k ≠ 4 := by omega
    simp [h2, h3, h4]
  · norm_num
  · rw [weight]
    have h : Icc 1 4 = ({1, 2, 3, 4} : Finset ℕ) := by decide
    rw [h]
    norm_num
    ring
  · unfold headCoeff
    norm_num

/-- Every integer occurs as the degree-`2` coefficient (`= c(1)`) of an admissible
normalised eta quotient. -/
theorem exists_admissible_headCoeff (c : ℤ) {N : ℕ} (hN : 2 ≤ N) :
    ∃ a : ℕ → ℤ, weight a 4 = 24 ∧
      coeff 2 ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = c := by
  obtain ⟨a, -, -, hw, hc⟩ := headCoeff_surjective c
  exact ⟨a, hw, by rw [(jet_etaQuotientProd a hN).2.2, hc]⟩

/-! ## The classical example `1/Δ` -/

/-- The exponent vector of `Δ = η(τ)^{24}`. -/
def deltaExp : ℕ → ℤ := fun k => if k = 1 then 24 else 0

theorem weight_deltaExp : weight deltaExp 4 = 24 := by
  have h : Icc 1 4 = ({1, 2, 3, 4} : Finset ℕ) := by decide
  simp [weight, h, deltaExp]

/-- `1/Δ = q⁻¹ + 24 + 324 q + ⋯`: the head coefficient of the eta quotient
attached to `Δ = η^{24}` is `324`, and the constant term is `24`. -/
theorem headCoeff_delta : headCoeff deltaExp = 324 ∧ deltaExp 1 = 24 := by
  refine ⟨?_, by simp [deltaExp]⟩
  simp [headCoeff, deltaExp]

theorem coeff_two_delta {N : ℕ} (hN : 2 ≤ N) :
    coeff 2 ((etaQuotientProd deltaExp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 324 := by
  rw [(jet_etaQuotientProd deltaExp hN).2.2, headCoeff_delta.1]

/-- `η(2τ)^{12}` is admissible and its normalised quotient has head coefficient `12`. -/
def eta2Exp : ℕ → ℤ := fun k => if k = 2 then 12 else 0

theorem coeff_two_eta2 {N : ℕ} (hN : 2 ≤ N) :
    weight eta2Exp 4 = 24 ∧
      coeff 2 ((etaQuotientProd eta2Exp N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ) = 12 := by
  have h : Icc 1 4 = ({1, 2, 3, 4} : Finset ℕ) := by decide
  refine ⟨by simp [weight, h, eta2Exp], ?_⟩
  rw [(jet_etaQuotientProd eta2Exp hN).2.2]
  simp [headCoeff, eta2Exp]

/-! ## Tropical shadow: the `X`-adic valuation -/

/-- The normalised eta quotient is a unit, so its `X`-adic (tropical) valuation is `0`:
all the `24`-torsion of the `q`-order has been absorbed into the factor `q`. -/
theorem order_etaQuotientProd (a : ℕ → ℤ) {N : ℕ} (hN : 2 ≤ N) :
    ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ).order = 0 := by
  have h0 : ((0 : ℕ) : ℕ∞) = 0 := by simp
  rw [← h0, PowerSeries.order_eq_nat]
  refine ⟨?_, by omega⟩
  rw [coeff_zero_eq_constantCoeff_apply, constantCoeff_etaQuotientProd a hN]
  norm_num

/-- Tropical additivity of the valuation along the group law of eta quotients:
`ord (F_{a+a'}) = ord F_a + ord F_{a'}` (for `N ≥ 2` both sides are in fact `0`, by
`order_etaQuotientProd`).  Combined with `headCoeff_add` this says: the valuation is
the *additive* (tropical) shadow, while the head coefficient is the first nonabelian
(Heisenberg) invariant. -/
theorem order_etaQuotientProd_add (a a' : ℕ → ℤ) (N : ℕ) :
    ((etaQuotientProd (a + a') N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ).order
      = ((etaQuotientProd a N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ).order
        + ((etaQuotientProd a' N : (PowerSeries ℤ)ˣ) : PowerSeries ℤ).order := by
  rw [etaQuotientProd_add, Units.val_mul, PowerSeries.order_mul]

end EtaHead