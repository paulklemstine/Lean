/-
# Cycle 5: the join half of the lattice bridge, and squarefreeness

Cycle 2 (`Computation.AlexanderTorusKnot.GcdBridge`) proved the *meet* half of the bridge,
`gcd(A_M, A_N) = A_{gcd(M,N)}`. The naive join statement `lcm(A_M, A_N) = A_{lcm(M,N)}` is
**false** — degrees already refute it: `deg lcm(A_3, A_5) = 6` while `deg A_15 = 14`, because
the divisor set of `lcm(M,N)` is strictly larger than the union of the divisor sets. The
correct statement carries an explicit *join defect*, a product of the cyclotomic factors
indexed by the divisors of `lcm(M,N)` that divide neither `M` nor `N`:

* `alexander_gcd_lcm_identity` : `A_M · A_N · C_{M,N} = A_{gcd(M,N)} · A_{lcm(M,N)}`
  with `C_{M,N} = ∏_{d ∣ lcm, d ∤ M, d ∤ N} Φ_{2d}` (`joinDefect`);
* `joinDefect_eq_one_iff_dvd` : the defect is trivial exactly when one parameter divides the
  other, i.e. exactly when the two knots are "nested";
* `torusAlexander_squarefree_rat` : `Δ_{a,b}` is squarefree over `ℚ` for all coprime `a, b`,
  so the Alexander module of any torus knot is a product of *distinct* cyclotomic fields.
-/
import Computation.AlexanderTorusKnot.Palindromic
import Computation.AlexanderTorusKnot.GcdBridge

namespace Computation.AlexanderTorusKnot

open Polynomial Finset Bridges.AlexanderTorus

/-! ## The join defect -/

/-- The cyclotomic factors of `A_{lcm(M,N)}` that are seen by neither `A_M` nor `A_N`. -/
noncomputable def joinDefect (M N : ℕ) : ℤ[X] :=
  ∏ d ∈ ((Nat.lcm M N).divisors.erase 1) \ (M.divisors ∪ N.divisors), cyclotomic (2 * d) ℤ

/-- The catalog's cyclotomic factorization of `A_N`, extended to `N = 1`. -/
lemma alexander_eq_prod_cyclotomic' {N : ℕ} (hN : Odd N) (hpos : 0 < N) :
    alexander N = ∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) ℤ := by
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.2 hpos.ne') with h1 | h1
  · have hN1 : N = 1 := h1.symm
    subst hN1
    simp [alexander]
  · exact alexander_eq_prod_cyclotomic hN h1

lemma divisors_erase_one_inter {M N : ℕ} (hM : 0 < M) (hN : 0 < N) :
    (M.divisors.erase 1) ∩ (N.divisors.erase 1) = (Nat.gcd M N).divisors.erase 1 := by
  ext d
  simp only [Finset.mem_inter, Finset.mem_erase, Nat.mem_divisors]
  constructor
  · rintro ⟨⟨hd1, hdM, -⟩, ⟨-, hdN, -⟩⟩
    exact ⟨hd1, Nat.dvd_gcd hdM hdN, (Nat.gcd_pos_of_pos_left N hM).ne'⟩
  · rintro ⟨hd1, hdg, -⟩
    exact ⟨⟨hd1, hdg.trans (Nat.gcd_dvd_left M N), hM.ne'⟩,
      ⟨hd1, hdg.trans (Nat.gcd_dvd_right M N), hN.ne'⟩⟩

lemma divisors_erase_one_union_subset {M N : ℕ} (hM : 0 < M) (hN : 0 < N) :
    (M.divisors.erase 1) ∪ (N.divisors.erase 1) ⊆ (Nat.lcm M N).divisors.erase 1 := by
  intro d hd
  have hlcm : 0 < Nat.lcm M N := Nat.pos_of_ne_zero (by
    simp [Nat.lcm_eq_zero_iff, hM.ne', hN.ne'])
  simp only [Finset.mem_union, Finset.mem_erase, Nat.mem_divisors] at hd ⊢
  rcases hd with ⟨hd1, hdM, -⟩ | ⟨hd1, hdN, -⟩
  · exact ⟨hd1, hdM.trans (Nat.dvd_lcm_left M N), hlcm.ne'⟩
  · exact ⟨hd1, hdN.trans (Nat.dvd_lcm_right M N), hlcm.ne'⟩

lemma sdiff_eq_sdiff_erase {M N : ℕ} :
    ((Nat.lcm M N).divisors.erase 1) \ (M.divisors ∪ N.divisors)
      = ((Nat.lcm M N).divisors.erase 1) \ ((M.divisors.erase 1) ∪ (N.divisors.erase 1)) := by
  ext d
  simp only [Finset.mem_sdiff, Finset.mem_union, Finset.mem_erase, Finset.mem_erase]
  constructor
  · rintro ⟨hd, hnot⟩
    refine ⟨hd, ?_⟩
    rintro (⟨-, h⟩ | ⟨-, h⟩)
    · exact hnot (Or.inl h)
    · exact hnot (Or.inr h)
  · rintro ⟨hd, hnot⟩
    refine ⟨hd, ?_⟩
    rintro (h | h)
    · exact hnot (Or.inl ⟨hd.1, h⟩)
    · exact hnot (Or.inr ⟨hd.1, h⟩)

/-- **The lattice identity with defect.** For odd positive `M, N`,
`A_M · A_N · C_{M,N} = A_{gcd(M,N)} · A_{lcm(M,N)}`, where the join defect `C_{M,N}` collects
the cyclotomic factors indexed by divisors of `lcm(M,N)` dividing neither `M` nor `N`. -/
theorem alexander_gcd_lcm_identity {M N : ℕ} (hM : Odd M) (hN : Odd N) :
    alexander M * alexander N * joinDefect M N
      = alexander (Nat.gcd M N) * alexander (Nat.lcm M N) := by
  have hMp : 0 < M := hM.pos
  have hNp : 0 < N := hN.pos
  have hgcd : Odd (Nat.gcd M N) := odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  have hgp : 0 < Nat.gcd M N := Nat.gcd_pos_of_pos_left N hMp
  have hlp : 0 < Nat.lcm M N := Nat.pos_of_ne_zero (by
    simp [Nat.lcm_eq_zero_iff, hMp.ne', hNp.ne'])
  have hlcm : Odd (Nat.lcm M N) :=
    odd_of_dvd_odd (hM.mul hN) (Nat.lcm_dvd (dvd_mul_right M N) (dvd_mul_left N M))
  rw [alexander_eq_prod_cyclotomic' hM hMp, alexander_eq_prod_cyclotomic' hN hNp,
    alexander_eq_prod_cyclotomic' hgcd hgp, alexander_eq_prod_cyclotomic' hlcm hlp,
    joinDefect, sdiff_eq_sdiff_erase]
  have hunion := Finset.prod_union_inter (s₁ := M.divisors.erase 1)
    (s₂ := N.divisors.erase 1) (f := fun d => cyclotomic (2 * d) ℤ)
  rw [divisors_erase_one_inter hMp hNp] at hunion
  have hsdiff := Finset.prod_sdiff (f := fun d => cyclotomic (2 * d) ℤ)
    (divisors_erase_one_union_subset hMp hNp)
  calc (∏ d ∈ M.divisors.erase 1, cyclotomic (2 * d) ℤ)
        * (∏ d ∈ N.divisors.erase 1, cyclotomic (2 * d) ℤ)
        * ∏ d ∈ ((Nat.lcm M N).divisors.erase 1) \
            ((M.divisors.erase 1) ∪ (N.divisors.erase 1)), cyclotomic (2 * d) ℤ
      = ((∏ d ∈ (M.divisors.erase 1) ∪ (N.divisors.erase 1), cyclotomic (2 * d) ℤ)
          * ∏ d ∈ (Nat.gcd M N).divisors.erase 1, cyclotomic (2 * d) ℤ)
        * ∏ d ∈ ((Nat.lcm M N).divisors.erase 1) \
            ((M.divisors.erase 1) ∪ (N.divisors.erase 1)), cyclotomic (2 * d) ℤ := by
        rw [hunion]
    _ = (∏ d ∈ (Nat.gcd M N).divisors.erase 1, cyclotomic (2 * d) ℤ)
        * ((∏ d ∈ ((Nat.lcm M N).divisors.erase 1) \
              ((M.divisors.erase 1) ∪ (N.divisors.erase 1)), cyclotomic (2 * d) ℤ)
          * ∏ d ∈ (M.divisors.erase 1) ∪ (N.divisors.erase 1), cyclotomic (2 * d) ℤ) := by
        ring
    _ = (∏ d ∈ (Nat.gcd M N).divisors.erase 1, cyclotomic (2 * d) ℤ)
        * ∏ d ∈ (Nat.lcm M N).divisors.erase 1, cyclotomic (2 * d) ℤ := by
        rw [hsdiff]

lemma joinDefect_monic (M N : ℕ) : (joinDefect M N).Monic :=
  monic_prod_of_monic _ _ fun d _ => cyclotomic.monic (2 * d) ℤ

/-- **Degree form of the lattice identity**: the join defect has degree
`gcd(M,N) + lcm(M,N) - M - N`, the exact failure of `N ↦ deg A_N` to be a lattice
homomorphism. -/
theorem joinDefect_natDegree {M N : ℕ} (hM : Odd M) (hN : Odd N) :
    (joinDefect M N).natDegree + M + N = Nat.gcd M N + Nat.lcm M N := by
  have hMp : 0 < M := hM.pos
  have hNp : 0 < N := hN.pos
  have hgcd : Odd (Nat.gcd M N) := odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  have hlcm : Odd (Nat.lcm M N) :=
    odd_of_dvd_odd (hM.mul hN) (Nat.lcm_dvd (dvd_mul_right M N) (dvd_mul_left N M))
  have hgp : 0 < Nat.gcd M N := Nat.gcd_pos_of_pos_left N hMp
  have hlp : 0 < Nat.lcm M N := Nat.pos_of_ne_zero (by
    simp [Nat.lcm_eq_zero_iff, hMp.ne', hNp.ne'])
  have hid := alexander_gcd_lcm_identity hM hN
  have hdeg := congrArg Polynomial.natDegree hid
  rw [((alexander_monic_of_odd hM).mul (alexander_monic_of_odd hN)).natDegree_mul
        (joinDefect_monic M N),
    (alexander_monic_of_odd hM).natDegree_mul (alexander_monic_of_odd hN),
    (alexander_monic_of_odd hgcd).natDegree_mul (alexander_monic_of_odd hlcm),
    alexander_natDegree hM, alexander_natDegree hN, alexander_natDegree hgcd,
    alexander_natDegree hlcm] at hdeg
  omega

/-- The join defect is trivial exactly for nested pairs: `C_{M,N} = 1` iff `M ∣ N` or
`N ∣ M`. -/
theorem joinDefect_eq_one_iff_dvd {M N : ℕ} (hM : 0 < M) (hN : 0 < N) :
    ((Nat.lcm M N).divisors.erase 1) \ (M.divisors ∪ N.divisors) = ∅
      ↔ (M ∣ N ∨ N ∣ M) := by
  have hlp : 0 < Nat.lcm M N := Nat.pos_of_ne_zero (by
    simp [Nat.lcm_eq_zero_iff, hM.ne', hN.ne'])
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hL : Nat.lcm M N ∈ ((Nat.lcm M N).divisors.erase 1) \ (M.divisors ∪ N.divisors) := by
      simp only [Finset.mem_sdiff, Finset.mem_erase, Nat.mem_divisors, Finset.mem_union,
        not_or]
      refine ⟨⟨?_, dvd_rfl, hlp.ne'⟩, ?_, ?_⟩
      · intro h1
        have hMd : M ∣ 1 := h1 ▸ Nat.dvd_lcm_left M N
        have hM1 : M = 1 := Nat.eq_one_of_dvd_one hMd
        exact hcon.1 (hM1 ▸ one_dvd N)
      · rintro ⟨hdvd, -⟩
        exact hcon.2 ((Nat.dvd_lcm_right M N).trans hdvd)
      · rintro ⟨hdvd, -⟩
        exact hcon.1 ((Nat.dvd_lcm_left M N).trans hdvd)
    rw [h] at hL
    exact absurd hL (Finset.notMem_empty _)
  · intro h
    rw [Finset.eq_empty_iff_forall_notMem]
    intro d hd
    simp only [Finset.mem_sdiff, Finset.mem_erase, Nat.mem_divisors, Finset.mem_union,
      not_or] at hd
    obtain ⟨⟨-, hdL, -⟩, hnM, hnN⟩ := hd
    rcases h with h | h
    · rw [Nat.lcm_eq_right h] at hdL
      exact hnN ⟨hdL, hN.ne'⟩
    · rw [Nat.lcm_eq_left h] at hdL
      exact hnM ⟨hdL, hM.ne'⟩

/-! ## Squarefreeness of the general torus-knot Alexander polynomial -/

lemma torusAlexander_dvd_X_pow_sub_one {a b : ℕ} (hab : 0 < a * b) :
    torusAlexander a b ∣ (X : ℤ[X]) ^ (a * b) - 1 := by
  rw [torusAlexander, ← prod_cyclotomic_eq_X_pow_sub_one hab ℤ]
  refine Finset.prod_dvd_prod_of_subset _ _ (fun d => cyclotomic d ℤ) ?_
  intro d hd
  exact Nat.mem_divisors.2 ⟨(mem_spectrum.1 hd).1, (mem_spectrum.1 hd).2.1⟩

/-- Over `ℚ`, the Alexander polynomial of any torus knot is separable: its `(a-1)(b-1)`
complex roots are pairwise distinct. -/
theorem torusAlexander_separable_rat {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    ((torusAlexander a b).map (Int.castRingHom ℚ)).Separable := by
  have hab : 0 < a * b := Nat.mul_pos ha hb
  have hsep : ((X : ℚ[X]) ^ (a * b) - C 1).Separable := by
    refine separable_X_pow_sub_C (1 : ℚ) ?_ one_ne_zero
    exact_mod_cast hab.ne'
  refine hsep.of_dvd ?_
  have := Polynomial.map_dvd (Int.castRingHom ℚ) (torusAlexander_dvd_X_pow_sub_one hab)
  simpa using this

/-- Hence `Δ_{a,b}` is squarefree over `ℚ`: the Alexander module `ℚ[X]/(Δ_{a,b})` of a torus
knot is a product of *distinct* cyclotomic fields. -/
theorem torusAlexander_squarefree_rat {a b : ℕ} (ha : 0 < a) (hb : 0 < b) :
    Squarefree ((torusAlexander a b).map (Int.castRingHom ℚ)) :=
  (torusAlexander_separable_rat ha hb).squarefree

end Computation.AlexanderTorusKnot