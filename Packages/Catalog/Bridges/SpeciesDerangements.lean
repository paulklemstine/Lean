/-
# Derangements as a species, and the generating series `e^{-X}/(1-X)`

A *derangement* of a set is a permutation without fixed points.  Derangements form a
species `D`: a bijection of the underlying sets transports a derangement to a
derangement.

The species-theoretic content of this file is the isomorphism of structure sets

    D · E  ≅  S ,

("every permutation is a derangement of its non-fixed points together with a set of
fixed points"), which by the product rule `Species.card_mul` yields the classical
binomial identity `∑ₖ C(n,k) Dₖ = n!` and, through the bridge `Species.egf_mul`, the
generating-series identity

    egf D · exp(X) · (1 - X) = 1,     i.e.    egf D = e^{-X}/(1-X).

Reading off coefficients gives `Dₙ / n! = ∑_{k ≤ n} (-1)ᵏ/k!`, and hence
`Dₙ/n! → e⁻¹`.
-/
import Bridges.SpeciesLinearOrders

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries Function

namespace Species

/-- The species of derangements: a `D`-structure on `A` is a fixed-point-free
permutation of `A`. -/
def derang : Species where
  obj A := ↥(derangements A)
  map e x := Equiv.derangementsCongr e x
  map_refl x := Subtype.ext (Equiv.ext fun _ => rfl)
  map_trans _ _ _ := Subtype.ext (Equiv.ext fun _ => rfl)
  finite A _ := by
    have : Finite (Equiv.Perm A) := Equiv.finite_left
    exact Subtype.finite

/-- The number of derangements of an `n`-element set is Mathlib's `numDerangements n`. -/
@[simp] theorem card_derang (n : ℕ) : derang.card n = numDerangements n := by
  classical
  show Nat.card ↥(derangements (Fin n)) = numDerangements n
  rw [Nat.card_eq_fintype_card]
  exact card_derangements_fin_eq_numDerangements

/-! ## The decomposition `D · E ≅ S` -/

/-- **Every permutation is a derangement of its non-fixed points.**  The structure set of
`D · E` on `A` — a splitting of `A` into a part carrying a derangement and a part
carrying the (unique) set structure — is in bijection with the permutations of `A`. -/
def derangMulSetEquivPerm (A : Type) : (derang.mul set).obj A ≃ Equiv.Perm A := by
  classical
  refine Equiv.trans ?_
    (Equiv.sigmaFiberEquiv (fun f : Equiv.Perm A => fun a => decide (f a ≠ a)))
  refine Equiv.sigmaCongrRight fun p => ?_
  refine (Equiv.prodPUnit _).trans ?_
  refine (derangements.subtypeEquiv (fun a => p a = true)).trans (Equiv.subtypeEquivRight ?_)
  intro f
  constructor
  · intro h
    funext a
    have := h a
    simp only [mem_fixedPoints, IsFixedPt, Bool.not_eq_true] at this
    by_cases hf : f a = a
    · simpa [hf] using (this.2 hf).symm
    · have hp : p a = true := by
        by_contra hpa
        exact hf (this.1 (by simpa using hpa))
      simp [hf, hp]
  · intro h a
    have ha : decide (f a ≠ a) = p a := congrFun h a
    simp only [mem_fixedPoints, IsFixedPt, Bool.not_eq_true]
    constructor
    · intro hpa
      have : decide (f a ≠ a) = false := by rw [ha, hpa]
      simpa using this
    · intro hfa
      have : decide (f a ≠ a) = false := by simp [hfa]
      rw [ha] at this
      exact this

/-- The underlying permutation of a `D · E`-structure is the derangement of the marked
part extended by the identity. -/
theorem derangMulSetEquivPerm_apply (A : Type) (z : (derang.mul set).obj A) (b : A) :
    derangMulSetEquivPerm A z b = Equiv.Perm.ofSubtype z.2.1.1 b := by
  obtain ⟨p, d, u⟩ := z
  classical
  simp [derangMulSetEquivPerm, derangements.subtypeEquiv, Equiv.sigmaCongrRight,
    Equiv.Perm.subtypeEquivSubtypePerm, Trans.trans, Equiv.subtypeEquiv, Equiv.prodPUnit]
  rfl

/-- The bijection `D · E ≅ S` is natural in the underlying set. -/
theorem derangMulSetEquivPerm_naturality {A B : Type} (e : A ≃ B) (z : (derang.mul set).obj A) :
    derangMulSetEquivPerm B ((derang.mul set).map e z)
      = perm.map e (derangMulSetEquivPerm A z) := by
  refine Equiv.ext fun b => ?_
  rw [derangMulSetEquivPerm_apply]
  show _ = e (derangMulSetEquivPerm A z (e.symm b))
  rw [derangMulSetEquivPerm_apply]
  by_cases hb : z.1 (e.symm b) = true
  · have h1 := Equiv.Perm.ofSubtype_apply_of_mem (p := fun a : A => z.1 a = true) z.2.1.1 hb
    have h2 := Equiv.Perm.ofSubtype_apply_of_mem
      (p := fun b' : B => z.1 (e.symm b') = true) ((derang.mul set).map e z).2.1.1 hb
    rw [h1]
    exact h2.trans rfl
  · have h1 := Equiv.Perm.ofSubtype_apply_of_not_mem (p := fun a : A => z.1 a = true) z.2.1.1 hb
    have h2 := Equiv.Perm.ofSubtype_apply_of_not_mem
      (p := fun b' : B => z.1 (e.symm b') = true) ((derang.mul set).map e z).2.1.1 hb
    rw [h1]
    exact h2.trans (by simp)

/-- **`D · E ≅ S` as an isomorphism of species**: a permutation is the same thing as a
derangement of a subset together with the complementary set of fixed points. -/
def derangMulSetIso : derang.mul set ≃ₛ perm where
  hom := derangMulSetEquivPerm
  naturality := derangMulSetEquivPerm_naturality

/-- The counting form of `D · E ≅ S`: there are `n!` pairs (derangement of a subset,
its complement). -/
@[simp] theorem card_derang_mul_set (n : ℕ) : (derang.mul set).card n = n.factorial := by
  rw [card, Nat.card_congr (derangMulSetEquivPerm (Fin n)), Nat.card_eq_fintype_card,
    Fintype.card_perm]
  simp

/-- **Classical binomial identity for derangements**: choosing the set of fixed points of
a permutation gives `∑ₖ C(n,k)·D_k = n!`. -/
theorem sum_choose_numDerangements (n : ℕ) :
    ∑ k ∈ Finset.range (n + 1), n.choose k * numDerangements k = n.factorial := by
  have h := card_mul derang set n
  rw [card_derang_mul_set] at h
  simpa using h.symm

/-! ## The generating series -/

/-- `egf D · exp = egf S`: the bridge theorem `egf_mul` applied to `D · E ≅ S`. -/
theorem egf_derang_mul_exp : derang.egf * PowerSeries.exp ℚ = perm.egf := by
  rw [← egf_set, ← egf_mul]
  exact (egf_eq_iff _ _).2 fun n => by simp

/-- **The exponential generating series of derangements is `e^{-X}/(1-X)`**, stated
without division: `egf D · exp(X) · (1 - X) = 1`. -/
theorem egf_derang_mul_exp_mul : derang.egf * PowerSeries.exp ℚ * (1 - PowerSeries.X) = 1 := by
  rw [egf_derang_mul_exp]
  exact egf_perm

/-- The same identity in the form `egf D · (1 - X) = e^{-X}`. -/
theorem egf_derang_mul_one_sub_X :
    derang.egf * (1 - PowerSeries.X) = PowerSeries.evalNegHom (PowerSeries.exp ℚ) := by
  have hexp : PowerSeries.exp ℚ * PowerSeries.evalNegHom (PowerSeries.exp ℚ) = 1 :=
    PowerSeries.exp_mul_exp_neg_eq_one
  calc derang.egf * (1 - PowerSeries.X)
      = derang.egf * (PowerSeries.exp ℚ * PowerSeries.evalNegHom (PowerSeries.exp ℚ))
          * (1 - PowerSeries.X) := by rw [hexp, mul_one]
    _ = derang.egf * PowerSeries.exp ℚ * (1 - PowerSeries.X)
          * PowerSeries.evalNegHom (PowerSeries.exp ℚ) := by ring
    _ = PowerSeries.evalNegHom (PowerSeries.exp ℚ) := by rw [egf_derang_mul_exp_mul, one_mul]

/-! ## The alternating sum formula -/

/-- `Dₙ / n! = ∑_{k=0}^{n} (-1)ᵏ/k!`, obtained from Mathlib's alternating sum formula for
`numDerangements`. -/
theorem coeff_egf_derang (n : ℕ) :
    coeff n derang.egf = ∑ k ∈ Finset.range (n + 1), (-1 : ℚ) ^ k / k.factorial := by
  rw [coeff_egf, card_derang]
  have hcast : (numDerangements n : ℚ)
      = ∑ k ∈ Finset.range (n + 1), (-1 : ℚ) ^ k * ((k + 1).ascFactorial (n - k) : ℚ) := by
    have h := numDerangements_sum n
    have : ((numDerangements n : ℤ) : ℚ)
        = ((∑ k ∈ Finset.range (n + 1), (-1 : ℤ) ^ k * (k + 1).ascFactorial (n - k) : ℤ) : ℚ) := by
      exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) h
    push_cast at this
    simpa using this
  rw [hcast, Finset.sum_div]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hk' : k ≤ n := Nat.lt_succ_iff.1 (Finset.mem_range.1 hk)
  have hfac : (k.factorial : ℚ) * ((k + 1).ascFactorial (n - k) : ℚ) = (n.factorial : ℚ) := by
    have := Nat.factorial_mul_ascFactorial k (n - k)
    rw [Nat.add_sub_cancel' hk'] at this
    exact_mod_cast this
  have h1 : (k.factorial : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero k)
  have h2 : (n.factorial : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero n)
  field_simp
  rw [← hfac]
  ring

/-- Consequently the proportion of derangements tends to `e⁻¹`: the coefficients of the
exponential generating series of `D`, read as real numbers, converge to `Real.exp (-1)`. -/
theorem tendsto_coeff_egf_derang :
    Filter.Tendsto (fun n => ((coeff n derang.egf : ℚ) : ℝ)) Filter.atTop
      (nhds (Real.exp (-1))) := by
  have h := numDerangements_tendsto_inv_e
  refine h.congr fun n => ?_
  rw [coeff_egf, card_derang]
  push_cast
  ring

end Species

end SpeciesEGF