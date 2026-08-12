/-
# The Knot–Number bridge, third cycle: divisibility, separability, duality

Three structural theorems about the Alexander polynomial `A_N` of the torus knot
`T(2,N)`, all consequences of the cyclotomic factorization proved in
`Bridges.AlexanderKnotNumberBridge`:

* `alexander_dvd_iff_dvd` : **the divisibility bridge**
  `A_d ∣ A_M ↔ d ∣ M` (odd `d, M > 1`).
  Divisibility of torus-knot Alexander polynomials is *exactly* divisibility of the
  knot parameters — the divisor lattice of `N` is faithfully encoded in the
  divisibility order of the polynomials.
* `alexander_separable_rat` / `alexander_squarefree_rat` : `A_N` is separable
  (hence squarefree) over `ℚ`: the `N-1` roots are pairwise distinct, so the
  Alexander module `ℚ[X]/(A_N)` is a product of `τ(N)-1` distinct cyclotomic fields.
* `alexander_reverse` : `A_N` is palindromic, `A_N.reverse = A_N`, the polynomial
  shadow of Poincaré duality for the knot complement.
-/
import Bridges.AlexanderKnotNumberBridge

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-! ## The divisibility bridge -/

/-- `Φ_{2d}` divides `A_M` whenever `d ∣ M`, `d > 1`. -/
lemma cyclotomic_dvd_alexander {d M : ℕ} (hM : Odd M) (hM1 : 1 < M) (hdvd : d ∣ M)
    (hd1 : d ≠ 1) : cyclotomic (2 * d) ℤ ∣ alexander M := by
  have hmem : d ∈ M.divisors.erase 1 :=
    Finset.mem_erase.2 ⟨hd1, Nat.mem_divisors.2 ⟨hdvd, by omega⟩⟩
  rw [alexander_eq_prod_cyclotomic hM hM1]
  exact Finset.dvd_prod_of_mem _ hmem

/-- Easy direction: `d ∣ M` implies `A_d ∣ A_M`. -/
theorem alexander_dvd_of_dvd {d M : ℕ} (hM : Odd M) (hd1 : 1 < d) (hM1 : 1 < M)
    (hdvd : d ∣ M) : alexander d ∣ alexander M := by
  have hd : Odd d := odd_of_dvd_odd hM hdvd
  rw [alexander_eq_prod_cyclotomic hd hd1, alexander_eq_prod_cyclotomic hM hM1]
  refine Finset.prod_dvd_prod_of_subset _ _ _ ?_
  intro e he
  obtain ⟨he1, hemem⟩ := Finset.mem_erase.1 he
  exact Finset.mem_erase.2
    ⟨he1, Nat.mem_divisors.2 ⟨(Nat.mem_divisors.1 hemem).1.trans hdvd, by omega⟩⟩

/-- If an irreducible monic polynomial divides another monic irreducible one, they are
equal. -/
lemma eq_of_monic_irreducible_dvd {f g : ℤ[X]} (hf : f.Monic) (hg : g.Monic)
    (hfi : Irreducible f) (hgi : Irreducible g) (h : f ∣ g) : f = g := by
  obtain ⟨c, hc⟩ := h
  rcases hgi.isUnit_or_isUnit hc with hu | hu
  · exact absurd hu hfi.not_isUnit
  · have hcm : c.Monic := by
      have hlead := congrArg Polynomial.leadingCoeff hc
      rw [Polynomial.leadingCoeff_mul, hf.leadingCoeff, hg.leadingCoeff, one_mul] at hlead
      exact hlead.symm
    rw [hcm.eq_one_of_isUnit hu, mul_one] at hc
    exact hc.symm

/-- Hard direction: `A_d ∣ A_M` forces `d ∣ M`. -/
theorem dvd_of_alexander_dvd {d M : ℕ} (hd : Odd d) (hM : Odd M) (hd1 : 1 < d) (hM1 : 1 < M)
    (h : alexander d ∣ alexander M) : d ∣ M := by
  have hcyc : cyclotomic (2 * d) ℤ ∣ alexander M :=
    (cyclotomic_dvd_alexander hd hd1 dvd_rfl (by omega)).trans h
  have hirr : Irreducible (cyclotomic (2 * d) ℤ) := cyclotomic.irreducible (by omega)
  have hprime : Prime (cyclotomic (2 * d) ℤ) := irreducible_iff_prime.1 hirr
  rw [alexander_eq_prod_cyclotomic hM hM1] at hcyc
  obtain ⟨e, hemem, hdvd⟩ := hprime.exists_mem_finset_dvd hcyc
  obtain ⟨he1, hediv⟩ := Finset.mem_erase.1 hemem
  have hepos : 0 < e := Nat.pos_of_mem_divisors hediv
  have heq : cyclotomic (2 * d) ℤ = cyclotomic (2 * e) ℤ :=
    eq_of_monic_irreducible_dvd (cyclotomic.monic _ _) (cyclotomic.monic _ _) hirr
      (cyclotomic.irreducible (by omega)) hdvd
  have : 2 * d = 2 * e := cyclotomic_injective (R := ℤ) heq
  have hde : d = e := by omega
  rw [hde]
  exact (Nat.mem_divisors.1 hediv).1

/-- **The divisibility bridge.** For odd `d, M > 1`, the Alexander polynomial of
`T(2,d)` divides that of `T(2,M)` if and only if `d` divides `M`. -/
theorem alexander_dvd_iff_dvd {d M : ℕ} (hd : Odd d) (hM : Odd M) (hd1 : 1 < d)
    (hM1 : 1 < M) : alexander d ∣ alexander M ↔ d ∣ M :=
  ⟨dvd_of_alexander_dvd hd hM hd1 hM1, alexander_dvd_of_dvd hM hd1 hM1⟩

/-! ## Separability: the `N-1` roots are distinct -/

/-- `A_N` divides `X^{2N} - 1` (over any commutative ring), for odd `N`. -/
lemma alexander_dvd_X_pow_sub_one {N : ℕ} (hN : Odd N) :
    alexander N ∣ (X : ℤ[X]) ^ (2 * N) - 1 := by
  refine ⟨(X + 1) * ((X : ℤ[X]) ^ N - 1), ?_⟩
  have h := X_add_one_mul_alexander_odd hN
  have hX : ((X : ℤ[X]) ^ (2 * N) - 1) = ((X ^ N + 1) * (X ^ N - 1)) := by
    rw [two_mul, pow_add]; ring
  rw [hX, ← h]; ring

/-- Over `ℚ`, the Alexander polynomial of `T(2,N)` is separable: its `N-1` complex roots
are pairwise distinct. -/
theorem alexander_separable_rat {N : ℕ} (hN : Odd N) :
    ((alexander N).map (Int.castRingHom ℚ)).Separable := by
  have hpos : 0 < N := hN.pos
  have hsep : ((X : ℚ[X]) ^ (2 * N) - C 1).Separable := by
    refine separable_X_pow_sub_C (1 : ℚ) ?_ one_ne_zero
    have : (0 : ℚ) < (2 * N : ℕ) := by positivity
    exact_mod_cast this.ne'
  refine hsep.of_dvd ?_
  have hdvd := alexander_dvd_X_pow_sub_one hN
  have := Polynomial.map_dvd (Int.castRingHom ℚ) hdvd
  simpa using this

/-- Consequently `A_N` is squarefree over `ℚ`: the Alexander module `ℚ[X]/(A_N)` is a
product of distinct cyclotomic fields. -/
theorem alexander_squarefree_rat {N : ℕ} (hN : Odd N) :
    Squarefree ((alexander N).map (Int.castRingHom ℚ)) :=
  (alexander_separable_rat hN).squarefree

/-! ## Palindromicity (Poincaré duality shadow) -/

lemma reverse_X_pow_add_one {N : ℕ} (hpos : 0 < N) :
    ((X : ℤ[X]) ^ N + 1).reverse = (X : ℤ[X]) ^ N + 1 := by
  have hdeg : ((X : ℤ[X]) ^ N + 1).natDegree = N := by
    have hC : ((X : ℤ[X]) ^ N + 1) = (X ^ N + C 1) := by simp
    rw [hC, natDegree_X_pow_add_C]
  ext n
  rw [coeff_reverse, hdeg]
  rcases le_or_gt n N with h | h
  · rw [revAt_le h]
    simp only [coeff_add, coeff_X_pow, coeff_one]
    have h1 : (N - n = N) ↔ (n = 0) := by omega
    have h2 : (N - n = 0) ↔ (n = N) := by omega
    by_cases hn0 : n = 0
    · subst hn0; simp [hpos.ne, hpos.ne']
    · by_cases hnN : n = N
      · subst hnN; simp [hpos.ne, hpos.ne']
      · rw [if_neg (by omega), if_neg (by omega), if_neg hnN, if_neg hn0]
  · rw [revAt_eq_self_of_lt h]

/-- **Palindromicity.** `A_N` is its own reverse: the coefficient sequence
`1, -1, 1, …, 1` is symmetric. This is the polynomial shadow of the duality
`Δ(t) ≐ Δ(t⁻¹)` satisfied by Alexander polynomials of knots. -/
theorem alexander_reverse {N : ℕ} (hN : Odd N) : (alexander N).reverse = alexander N := by
  have hpos : 0 < N := hN.pos
  have h := X_add_one_mul_alexander_odd hN
  have hrev := congrArg Polynomial.reverse h
  rw [reverse_mul_of_domain, reverse_X_pow_add_one hpos] at hrev
  have hX1 : ((X : ℤ[X]) + 1).reverse = X + 1 := by
    have := reverse_X_pow_add_one (N := 1) one_pos
    simpa using this
  rw [hX1, ← h] at hrev
  have hne : (X + 1 : ℤ[X]) ≠ 0 := fun hc => by
    simpa using congrArg (Polynomial.eval 0) hc
  exact mul_left_cancel₀ hne hrev

end Bridges.AlexanderTorus