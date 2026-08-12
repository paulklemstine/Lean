/-
# The Knot–Number bridge, fourth cycle: coprimality and the size obstruction

Two final structural results.

* **Coprimality bridge** (`alexander_common_divisors_unit_iff_coprime`):
  for odd `M, N > 1`, *every* common divisor of `A_M` and `A_N` in `ℤ[X]` is a unit
  **iff** `gcd(M, N) = 1`. Together with `alexander_dvd_iff_dvd` of cycle III this
  says the map `N ↦ A_N` is an embedding of the divisibility lattice of odd numbers
  into the divisibility lattice of `ℤ[X]`.

* **The size obstruction** (`alexander_support_card`, `alexander_coeff`):
  every one of the `N` coefficients of `A_N` is `±1`, so `A_N` has exactly `N`
  nonzero terms. Writing `A_N` down costs `Θ(N) = Θ(exp(log N))` — this is the
  precise sense in which the bridge is *not* a factoring algorithm.
-/
import Bridges.AlexanderKnotNumberBridgeIII

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-! ## Coefficients: the size obstruction -/

theorem alexander_coeff (N i : ℕ) :
    (alexander N).coeff i = if i < N then (-1 : ℤ) ^ i else 0 := by
  induction N with
  | zero => simp
  | succ n ih =>
      have hterm : ((-1 : ℤ[X]) ^ n * X ^ n).coeff i = if i = n then (-1 : ℤ) ^ n else 0 := by
        rw [show ((-1 : ℤ[X]) ^ n) = C ((-1 : ℤ) ^ n) by simp [map_pow], coeff_C_mul,
          coeff_X_pow]
        split <;> simp_all
      rw [alexander_succ, coeff_add, ih, hterm]
      rcases lt_trichotomy i n with h | h | h
      · rw [if_pos h, if_neg (by omega), if_pos (by omega), add_zero]
      · subst h
        rw [if_neg (by omega), if_pos rfl, if_pos (by omega), zero_add]
      · rw [if_neg (by omega), if_neg (by omega), if_neg (by omega), add_zero]

/-- Every coefficient of `A_N` below the degree is `±1`, hence nonzero: the support of
`A_N` is all of `{0, …, N-1}`. -/
theorem alexander_support (N : ℕ) : (alexander N).support = Finset.range N := by
  ext i
  rw [Polynomial.mem_support_iff, alexander_coeff, Finset.mem_range]
  constructor
  · intro h
    by_contra hc
    rw [if_neg hc] at h
    exact h rfl
  · intro h
    rw [if_pos h]
    exact pow_ne_zero i (by norm_num)

/-- **The size obstruction.** `A_N` has exactly `N` nonzero coefficients, all `±1`. -/
theorem alexander_support_card (N : ℕ) : (alexander N).support.card = N := by
  rw [alexander_support, Finset.card_range]

/-! ## Coprimality bridge -/

/-- If an irreducible `p` divides `A_M` (`M` odd `> 1`), then `p` is associated to
`Φ_{2d}` for some divisor `d > 1` of `M`. -/
lemma exists_divisor_of_irreducible_dvd_alexander {M : ℕ} (hM : Odd M) (hM1 : 1 < M)
    {p : ℤ[X]} (hp : Irreducible p) (hdvd : p ∣ alexander M) :
    ∃ d, d ∣ M ∧ 1 < d ∧ Associated p (cyclotomic (2 * d) ℤ) := by
  have hprime : Prime p := irreducible_iff_prime.1 hp
  rw [alexander_eq_prod_cyclotomic hM hM1] at hdvd
  obtain ⟨d, hdmem, hdvd'⟩ := hprime.exists_mem_finset_dvd hdvd
  obtain ⟨hd1, hddiv⟩ := Finset.mem_erase.1 hdmem
  have hdpos : 0 < d := Nat.pos_of_mem_divisors hddiv
  exact ⟨d, (Nat.mem_divisors.1 hddiv).1, by omega,
    hp.associated_of_dvd (cyclotomic.irreducible (by omega)) hdvd'⟩

/-- **Coprimality bridge.** For odd `M, N > 1`: the Alexander polynomials of `T(2,M)`
and `T(2,N)` have only unit common divisors iff `M` and `N` are coprime. -/
theorem alexander_common_divisors_unit_iff_coprime {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hM1 : 1 < M) (hN1 : 1 < N) :
    (∀ f : ℤ[X], f ∣ alexander M → f ∣ alexander N → IsUnit f) ↔ Nat.Coprime M N := by
  constructor
  · intro h
    by_contra hcop
    obtain ⟨g, hgdef⟩ : ∃ g, g = Nat.gcd M N := ⟨_, rfl⟩
    have hgM : g ∣ M := hgdef ▸ Nat.gcd_dvd_left M N
    have hgN : g ∣ N := hgdef ▸ Nat.gcd_dvd_right M N
    have hg1 : 1 < g := by
      have hgpos : 0 < g := hgdef ▸ Nat.gcd_pos_of_pos_left N (by omega)
      have hgne : g ≠ 1 := fun hc => hcop (hgdef.symm.trans hc)
      omega
    have hgodd : Odd g := odd_of_dvd_odd hM hgM
    have hu := h (alexander g) (alexander_dvd_of_dvd hM hg1 hM1 hgM)
      (alexander_dvd_of_dvd hN hg1 hN1 hgN)
    have hdeg : 0 < (alexander g).natDegree := by
      rw [alexander_natDegree hgodd]; omega
    exact (Polynomial.not_isUnit_of_natDegree_pos _ hdeg) hu
  · intro hcop f hfM hfN
    by_contra hnu
    have hf0 : f ≠ 0 := by
      rintro rfl
      exact alexander_ne_zero hM (zero_dvd_iff.1 hfM)
    obtain ⟨p, hp, hpf⟩ := WfDvdMonoid.exists_irreducible_factor hnu hf0
    obtain ⟨d, hdM, hd1, hpd⟩ :=
      exists_divisor_of_irreducible_dvd_alexander hM hM1 hp (hpf.trans hfM)
    obtain ⟨e, heN, he1, hpe⟩ :=
      exists_divisor_of_irreducible_dvd_alexander hN hN1 hp (hpf.trans hfN)
    have hassoc : Associated (cyclotomic (2 * d) ℤ) (cyclotomic (2 * e) ℤ) :=
      hpd.symm.trans hpe
    have heq : cyclotomic (2 * d) ℤ = cyclotomic (2 * e) ℤ :=
      eq_of_monic_irreducible_dvd (cyclotomic.monic _ _) (cyclotomic.monic _ _)
        (cyclotomic.irreducible (by omega)) (cyclotomic.irreducible (by omega)) hassoc.dvd
    have hde : d = e := by
      have := cyclotomic_injective (R := ℤ) heq
      omega
    subst hde
    have hdvd1 : d ∣ 1 := hcop ▸ Nat.dvd_gcd hdM heN
    have : d ≤ 1 := Nat.le_of_dvd one_pos hdvd1
    omega

end Bridges.AlexanderTorus