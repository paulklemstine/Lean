/-
# Euclid's algorithm on knots: `gcd(A_M, A_N) = A_{gcd(M,N)}`

The catalog's knot–number bridge (`Bridges.AlexanderKnotNumberBridge`) shows that the
Alexander polynomial `A_N = (X^N+1)/(X+1)` of the torus knot `T(2,N)` factors as
`∏_{d ∣ N, d > 1} Φ_{2d}`, so that its *divisor spectrum* sees the divisors of `N`.

This file proves that the assignment `N ↦ A_N` is a **morphism of divisibility lattices**:
the greatest common divisor of two torus-knot Alexander polynomials is the Alexander
polynomial of the gcd of the two knot parameters. Consequently a *polynomial* Euclidean
algorithm run on the pair `(A_M, A_N)` computes the *integer* `gcd(M, N)`, readable off
the degree: `deg gcd(A_M, A_N) + 1 = gcd(M, N)`.

The engine is a purely ring-theoretic lemma of independent interest:

* `pow_gcd_eq_neg_one` : in any commutative ring, if `x^M = -1` and `x^N = -1` with `M, N`
  odd then `x^{gcd(M,N)} = -1`.

Main results:

* `dvd_X_pow_add_one_gcd` : if `f ∣ X^M + 1` and `f ∣ X^N + 1` (`M, N` odd) in `R[X]`
  then `f ∣ X^{gcd(M,N)} + 1`;
* `alexanderQ_dvd_iff` : `f ∣ A_M ∧ f ∣ A_N ↔ f ∣ A_{gcd(M,N)}` in `ℚ[X]`;
* `alexanderQ_gcd` : `gcd (A_M) (A_N) = A_{gcd(M,N)}` (normalized gcd in `ℚ[X]`);
* `alexanderQ_gcd_natDegree` : `deg gcd(A_M, A_N) + 1 = gcd(M, N)` — the knot-theoretic
  Euclidean algorithm computes the number-theoretic gcd;
* `alexanderQ_isCoprime_iff_coprime` : `A_M` and `A_N` are coprime iff `M` and `N` are.

The "catch" of the bridge is quantified at the end: `alexander_support_card_exp_lower`
shows `A_N` has `≥ 2^(log₂ N)` nonzero coefficients, i.e. exponential size in the bit
length of `N`.
-/
import Bridges.AlexanderKnotNumberBridgeV

namespace Computation.AlexanderTorusKnot

open Polynomial

/-! ## A Bézout lemma over `ℕ` -/

/-- **Positive Bézout.** For positive `M, N` there are *natural numbers* `s, t` with
`s·M = gcd(M,N) + t·N`. -/
lemma exists_bezout_nat {M N : ℕ} (hM : 0 < M) (hN : 0 < N) :
    ∃ s t : ℕ, s * M = Nat.gcd M N + t * N := by
  obtain ⟨M', hM'⟩ : Nat.gcd M N ∣ M := Nat.gcd_dvd_left M N
  obtain ⟨N', hN'⟩ : Nat.gcd M N ∣ N := Nat.gcd_dvd_right M N
  set g : ℕ := Nat.gcd M N with hg
  have hbez : (g : ℤ) = M * Nat.gcdA M N + N * Nat.gcdB M N := Nat.gcd_eq_gcd_ab M N
  set A : ℤ := Nat.gcdA M N
  set B : ℤ := Nat.gcdB M N
  set k : ℤ := |A| + |B| with hk
  set S : ℤ := A + k * N' with hS
  set T : ℤ := -B + k * M' with hT
  have hN'pos : 0 < (N' : ℤ) := by
    rcases Nat.eq_zero_or_pos N' with h | h
    · exfalso; rw [h, mul_zero] at hN'; omega
    · exact_mod_cast h
  have hM'pos : 0 < (M' : ℤ) := by
    rcases Nat.eq_zero_or_pos M' with h | h
    · exfalso; rw [h, mul_zero] at hM'; omega
    · exact_mod_cast h
  have hkpos : 0 ≤ k := by positivity
  have hSnn : 0 ≤ S := by
    have h1 : k * 1 ≤ k * N' := by
      exact mul_le_mul_of_nonneg_left (by omega) hkpos
    have h2 : -A ≤ k := by
      have := abs_nonneg B
      have := neg_abs_le A
      omega
    simp only [hS]
    omega
  have hTnn : 0 ≤ T := by
    have h1 : k * 1 ≤ k * M' := by
      exact mul_le_mul_of_nonneg_left (by omega) hkpos
    have h2 : B ≤ k := by
      have := abs_nonneg A
      have := le_abs_self B
      omega
    simp only [hT]
    omega
  have hkey : S * M = (g : ℤ) + T * N := by
    have hMc : (M : ℤ) = g * M' := by exact_mod_cast hM'
    have hNc : (N : ℤ) = g * N' := by exact_mod_cast hN'
    simp only [hS, hT]
    rw [hMc, hNc] at hbez ⊢
    ring_nf
    ring_nf at hbez
    linarith [hbez]
  refine ⟨S.toNat, T.toNat, ?_⟩
  have hSc : (S.toNat : ℤ) = S := Int.toNat_of_nonneg hSnn
  have hTc : (T.toNat : ℤ) = T := Int.toNat_of_nonneg hTnn
  have : ((S.toNat * M : ℕ) : ℤ) = ((g + T.toNat * N : ℕ) : ℤ) := by
    push_cast [hSc, hTc]
    exact hkey
  exact_mod_cast this

/-! ## The ring-theoretic engine -/

/-- **Key lemma.** In any commutative ring, an element that is a "`-1`-th root" for two odd
exponents is one for their gcd. -/
theorem pow_gcd_eq_neg_one {R : Type*} [CommRing R] {x : R} {M N : ℕ}
    (hM : Odd M) (hN : Odd N) (hMx : x ^ M = -1) (hNx : x ^ N = -1) :
    x ^ Nat.gcd M N = -1 := by
  obtain ⟨s, t, hst⟩ := exists_bezout_nat hM.pos hN.pos
  have hgodd : Odd (Nat.gcd M N) :=
    Bridges.AlexanderTorus.odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  -- parity bookkeeping: `s + t` is odd
  have hsum : Odd (s + t) := by
    have hMm : M % 2 = 1 := Nat.odd_iff.1 hM
    have hNm : N % 2 = 1 := Nat.odd_iff.1 hN
    have hgm : Nat.gcd M N % 2 = 1 := Nat.odd_iff.1 hgodd
    have hsM : (s * M) % 2 = s % 2 := by
      conv_lhs => rw [Nat.mul_mod, hMm]
      simp
    have htN : (t * N) % 2 = t % 2 := by
      conv_lhs => rw [Nat.mul_mod, hNm]
      simp
    have hkey2 : (s * M) % 2 = (Nat.gcd M N + t * N) % 2 := by rw [hst]
    rw [hsM, Nat.add_mod, hgm, htN] at hkey2
    refine Nat.odd_iff.2 ?_
    omega
  have hL : x ^ (s * M) = (-1 : R) ^ s := by rw [mul_comm, pow_mul, hMx]
  have hR : x ^ (Nat.gcd M N + t * N) = x ^ Nat.gcd M N * (-1 : R) ^ t := by
    rw [pow_add, mul_comm t N, pow_mul, hNx]
  rw [hst, hR] at hL
  have hfinal : x ^ Nat.gcd M N * ((-1 : R) ^ t * (-1 : R) ^ t) = (-1 : R) ^ s * (-1 : R) ^ t := by
    rw [← mul_assoc, ← hL]
  rw [← pow_add, ← pow_add] at hfinal
  have h2t : ((-1 : R)) ^ (t + t) = 1 := (Even.neg_one_pow ⟨t, rfl⟩)
  rw [h2t, mul_one] at hfinal
  rw [hfinal, hsum.neg_one_pow]

/-- If `f` divides `X^M + 1` and `X^N + 1` (odd `M, N`), it divides `X^{gcd(M,N)} + 1`. -/
theorem dvd_X_pow_add_one_gcd {R : Type*} [CommRing R] {f : R[X]} {M N : ℕ}
    (hM : Odd M) (hN : Odd N) (h1 : f ∣ X ^ M + 1) (h2 : f ∣ X ^ N + 1) :
    f ∣ X ^ Nat.gcd M N + 1 := by
  set I : Ideal R[X] := Ideal.span {f} with hI
  have key : ∀ g : R[X], f ∣ g ↔ Ideal.Quotient.mk I g = 0 := by
    intro g
    rw [Ideal.Quotient.eq_zero_iff_mem, hI, Ideal.mem_span_singleton]
  have hx : ∀ (k : ℕ), f ∣ X ^ k + 1 →
      (Ideal.Quotient.mk I X) ^ k = -1 := by
    intro k hk
    have := (key _).1 hk
    have hmap : (Ideal.Quotient.mk I X) ^ k + 1 = 0 := by
      simpa using this
    linear_combination hmap
  have hgcd := pow_gcd_eq_neg_one hM hN (hx M h1) (hx N h2)
  refine (key _).2 ?_
  have : (Ideal.Quotient.mk I X) ^ Nat.gcd M N + 1 = 0 := by rw [hgcd]; ring
  simpa using this

/-! ## The Alexander polynomial over `ℚ` -/

open Bridges.AlexanderTorus

/-- The Alexander polynomial of `T(2,N)`, viewed in `ℚ[X]`. -/
noncomputable def alexanderQ (N : ℕ) : ℚ[X] := (alexander N).map (Int.castRingHom ℚ)

lemma X_add_one_mul_alexanderQ {N : ℕ} (hN : Odd N) :
    (X + 1) * alexanderQ N = X ^ N + 1 := by
  have h := congrArg (Polynomial.map (Int.castRingHom ℚ)) (X_add_one_mul_alexander_odd hN)
  simpa [alexanderQ, Polynomial.map_mul, Polynomial.map_add, Polynomial.map_pow] using h

/-- For odd `N`, `A_N` is monic (its top coefficient is `(-1)^{N-1} = 1`). -/
lemma alexander_monic_of_odd {N : ℕ} (hN : Odd N) : (alexander N).Monic := by
  have h1 : ((X : ℤ[X]) + 1).Monic := by simpa using monic_X_add_C (1 : ℤ)
  have h2 : ((X : ℤ[X]) ^ N + 1).Monic := by
    simpa using monic_X_pow_add_C (1 : ℤ) (n := N) hN.pos.ne'
  exact h1.of_mul_monic_left (by rw [X_add_one_mul_alexander_odd hN]; exact h2)

lemma alexanderQ_monic {N : ℕ} (hN : Odd N) : (alexanderQ N).Monic :=
  (alexander_monic_of_odd hN).map (Int.castRingHom ℚ)

lemma alexanderQ_eval_neg_one (N : ℕ) : (alexanderQ N).eval (-1) = (N : ℚ) := by
  have h : (alexanderQ N).eval ((-1 : ℤ) : ℚ) = (((alexander N).eval (-1) : ℤ) : ℚ) :=
    Polynomial.eval_intCast_map (Int.castRingHom ℚ) (alexander N) (-1)
  rw [knot_determinant N] at h
  simpa using h

lemma alexanderQ_natDegree {N : ℕ} (hN : Odd N) : (alexanderQ N).natDegree = N - 1 := by
  rw [alexanderQ, Polynomial.natDegree_map_eq_of_injective
    (fun a b hab => Int.cast_injective hab) (alexander N), alexander_natDegree hN]

lemma alexanderQ_one : alexanderQ 1 = 1 := by
  simp [alexanderQ, alexander]

/-- `A_d ∣ A_M` whenever `d ∣ M` (both odd) — the easy half of the lattice morphism. -/
lemma alexanderQ_dvd_of_dvd {d M : ℕ} (hd : Odd d) (hM : Odd M) (hdvd : d ∣ M) :
    alexanderQ d ∣ alexanderQ M := by
  rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.2 hd.pos.ne') with h1 | h1
  · rw [← h1, alexanderQ_one]
    exact one_dvd _
  · have hM1 : 1 < M := lt_of_lt_of_le h1 (Nat.le_of_dvd hM.pos hdvd)
    have hZ : alexander d ∣ alexander M :=
      (alexander_dvd_iff_dvd hd hM h1 hM1).2 hdvd
    exact Polynomial.map_dvd (Int.castRingHom ℚ) hZ

/-! ## The gcd theorem -/

/-- **Euclid's algorithm on knots.** A polynomial divides both `A_M` and `A_N` exactly when
it divides `A_{gcd(M,N)}`; i.e. `A_{gcd(M,N)}` is a greatest common divisor of `A_M, A_N`. -/
theorem alexanderQ_dvd_iff {M N : ℕ} (hM : Odd M) (hN : Odd N) (f : ℚ[X]) :
    (f ∣ alexanderQ M ∧ f ∣ alexanderQ N) ↔ f ∣ alexanderQ (Nat.gcd M N) := by
  have hgodd : Odd (Nat.gcd M N) :=
    Bridges.AlexanderTorus.odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  constructor
  · rintro ⟨h1, h2⟩
    have hd1 : f ∣ (X : ℚ[X]) ^ M + 1 :=
      h1.trans ⟨X + 1, by rw [← X_add_one_mul_alexanderQ hM]; ring⟩
    have hd2 : f ∣ (X : ℚ[X]) ^ N + 1 :=
      h2.trans ⟨X + 1, by rw [← X_add_one_mul_alexanderQ hN]; ring⟩
    have hg := dvd_X_pow_add_one_gcd hM hN hd1 hd2
    rw [← X_add_one_mul_alexanderQ hgodd] at hg
    have hXf : ¬ ((X : ℚ[X]) + 1) ∣ f := by
      rintro ⟨c, rfl⟩
      obtain ⟨e, he⟩ := h1
      have := congrArg (Polynomial.eval (-1 : ℚ)) he
      rw [alexanderQ_eval_neg_one] at this
      simp at this
      exact hM.pos.ne' (by exact_mod_cast this)
    have hirr : Irreducible ((X : ℚ[X]) + 1) := by
      simpa [sub_neg_eq_add] using irreducible_X_sub_C (-1 : ℚ)
    have hcop : IsCoprime ((X : ℚ[X]) + 1) f := hirr.coprime_iff_not_dvd.2 hXf
    exact hcop.symm.dvd_of_dvd_mul_left hg
  · intro h
    exact ⟨h.trans (alexanderQ_dvd_of_dvd hgodd hM (Nat.gcd_dvd_left M N)),
      h.trans (alexanderQ_dvd_of_dvd hgodd hN (Nat.gcd_dvd_right M N))⟩

/-- The normalized gcd in `ℚ[X]` of the two Alexander polynomials is the Alexander
polynomial of the gcd. -/
theorem alexanderQ_gcd {M N : ℕ} (hM : Odd M) (hN : Odd N) :
    gcd (alexanderQ M) (alexanderQ N) = alexanderQ (Nat.gcd M N) := by
  have hgodd : Odd (Nat.gcd M N) :=
    Bridges.AlexanderTorus.odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  have h2 : gcd (alexanderQ M) (alexanderQ N) ∣ alexanderQ (Nat.gcd M N) :=
    (alexanderQ_dvd_iff hM hN _).1 ⟨gcd_dvd_left _ _, gcd_dvd_right _ _⟩
  have h1 : alexanderQ (Nat.gcd M N) ∣ gcd (alexanderQ M) (alexanderQ N) := by
    refine dvd_gcd ?_ ?_
    · exact alexanderQ_dvd_of_dvd hgodd hM (Nat.gcd_dvd_left M N)
    · exact alexanderQ_dvd_of_dvd hgodd hN (Nat.gcd_dvd_right M N)
  have hnorm := normalize_eq_normalize h2 h1
  rwa [normalize_gcd, (alexanderQ_monic hgodd).normalize_eq_self] at hnorm

/-- **Degree readout.** The degree of the gcd of the two knot polynomials recovers the
integer gcd of the knot parameters. -/
theorem alexanderQ_gcd_natDegree {M N : ℕ} (hM : Odd M) (hN : Odd N) :
    (gcd (alexanderQ M) (alexanderQ N)).natDegree + 1 = Nat.gcd M N := by
  have hgodd : Odd (Nat.gcd M N) :=
    Bridges.AlexanderTorus.odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  rw [alexanderQ_gcd hM hN, alexanderQ_natDegree hgodd]
  have := hgodd.pos
  omega

/-- `A_M` and `A_N` are coprime in `ℚ[X]` exactly when `M` and `N` are coprime. -/
theorem alexanderQ_isCoprime_iff_coprime {M N : ℕ} (hM : Odd M) (hN : Odd N) :
    IsCoprime (alexanderQ M) (alexanderQ N) ↔ Nat.Coprime M N := by
  have hgodd : Odd (Nat.gcd M N) :=
    Bridges.AlexanderTorus.odd_of_dvd_odd hM (Nat.gcd_dvd_left M N)
  rw [← gcd_isUnit_iff, alexanderQ_gcd hM hN]
  constructor
  · intro hu
    have hdeg := Polynomial.natDegree_eq_zero_of_isUnit hu
    rw [alexanderQ_natDegree hgodd] at hdeg
    have : Nat.gcd M N = 1 := by
      have := hgodd.pos
      omega
    exact this
  · intro hcop
    rw [Nat.Coprime] at hcop
    rw [hcop, alexanderQ_one]
    exact isUnit_one

/-! ## The catch, quantified -/

/-- The Alexander polynomial of `T(2,N)` has at least `2^{⌊log₂ N⌋}` nonzero coefficients:
writing it down costs exponentially much in the bit length of `N`. -/
theorem alexander_support_card_exp_lower {N : ℕ} (hN : 0 < N) :
    2 ^ Nat.log 2 N ≤ (alexander N).support.card := by
  rw [alexander_support_card]
  exact Nat.pow_log_le_self 2 hN.ne'

end Computation.AlexanderTorusKnot