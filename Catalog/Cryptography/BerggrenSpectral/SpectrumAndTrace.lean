import Cryptography.BerggrenSpectral.Factorization

/-!
# The Exact Resonance Spectrum and the Berggren–Lucas Trace Sequence

Second research cycle.  Where `HyperbolicResonance.lean` produced *sufficient* resonant
frequencies, this file determines the resonance set **exactly**, decomposes it across the
factors of a semiprime modulus, and extracts an arithmetic sequence — the *Berggren–Lucas
trace sequence* — carrying a Fermat-type congruence.

## Main results

* `berg_two_pow_eq_one_iff` : modulo an odd prime `p`,
  `M₂ ^ k ≡ 1 ⟺ U ^ k = 1 ∧ k even`, where `U = !![3,2;4,3]` is the hyperbolic block.
  This is an exact description of the resonance spectrum, not merely a divisibility bound.
* `berg_two_orderOf` : `ord_p(M₂) = lcm (2, ord_p(U))`.
* `berg_resonance_crt` : for coprime moduli the resonance sets intersect,
  `M₂ ^ k ≡ 1 (mod m n) ⟺ M₂ ^ k ≡ 1 (mod m) ∧ M₂ ^ k ≡ 1 (mod n)`.  Factoring `N = p q`
  is therefore exactly the problem of *separating two resonant frequencies inside one
  modulus*, which is the conceptual content of `Factorization.lean`.
* `berg_trace_rec`, `berg_trace_values` : the traces `t k = tr (M₂ ^ k)` satisfy the
  Newton recurrence `t (k+3) = 5 t (k+2) + 5 t (k+1) - t k` of the characteristic
  polynomial, with `t 0, t 1, t 2, t 3 = 3, 5, 35, 197`.
* `berg_trace_fermat` : for every odd prime `p`, `t p ≡ 5 (mod p)` — a Fermat/Lucas-type
  congruence for the Berggren tree, proved from the matrix Frobenius, *not* from a
  hypothetical eigenvalue computation.
* `berg_trace_composite_witness` : the contrapositive is a compositeness test;
  `berg_nine_composite_witness` runs it on `N = 9`.
-/

namespace BerggrenSpectral

open Matrix

variable (p : ℕ) [Fact p.Prime]

/-! ## The exact resonance spectrum modulo a prime -/

/-- **Exact resonance spectrum.**  Modulo an odd prime, a power of `M₂` is trivial exactly
when the hyperbolic block is trivial *and* the exponent is even (the latter accounts for the
`-1` eigenvalue). -/
theorem berg_two_pow_eq_one_iff (hp : p ≠ 2) (k : ℕ) :
    (redMat p M₂) ^ k = 1 ↔ (bergU (ZMod p)) ^ k = 1 ∧ Even k := by
  rw [redMat_M₂]
  constructor
  · intro h
    have hdet : IsUnit (bergW (ZMod p)).det := by
      rw [det_bergW]; exact (isUnit_iff_ne_zero).mpr (two_ne_zero_of_odd_prime p hp)
    haveI : Invertible (bergW (ZMod p)) := invertibleOfIsUnitDet _ hdet
    have hc := berg_pow_conj (R := ZMod p) k
    rw [h, one_mul] at hc
    have hV : (bergV (ZMod p)) ^ k = 1 := by
      have hW : bergW (ZMod p) * (bergV (ZMod p)) ^ k = bergW (ZMod p) * 1 := by
        rw [mul_one, ← hc]
      exact mul_right_injective_of_invertible (bergW (ZMod p)) hW
    rw [bergV_pow] at hV
    have h00 := congrFun (congrFun hV 0) 0
    have h01 := congrFun (congrFun hV 0) 1
    have h10 := congrFun (congrFun hV 1) 0
    have h11 := congrFun (congrFun hV 1) 1
    have h22 := congrFun (congrFun hV 2) 2
    simp [blockEmbed] at h00 h01 h10 h11 h22
    refine ⟨?_, ?_⟩
    · ext i j; fin_cases i <;> fin_cases j <;> simp <;> assumption
    · rcases Nat.even_or_odd k with he | ho
      · exact he
      · exfalso
        rw [ho.neg_one_pow] at h22
        exact two_ne_zero_of_odd_prime p hp (by linear_combination -h22)
  · rintro ⟨hU, hk⟩
    exact M2R_pow_eq_one p hp hU hk

/-- **The order of `M₂` modulo a prime** is the least common multiple of `2` and the order of
the hyperbolic block. -/
theorem berg_two_orderOf (hp : p ≠ 2) :
    orderOf (redMat p M₂) = Nat.lcm 2 (orderOf (bergU (ZMod p))) := by
  set d := orderOf (bergU (ZMod p)) with hd
  refine Nat.dvd_antisymm ?_ ?_
  · refine orderOf_dvd_of_pow_eq_one ((berg_two_pow_eq_one_iff p hp _).mpr ⟨?_, ?_⟩)
    · exact orderOf_dvd_iff_pow_eq_one.mp (Nat.dvd_lcm_right 2 d)
    · exact (even_iff_exists_two_nsmul _).mpr (Nat.dvd_lcm_left 2 d)
  · obtain ⟨hU, hk⟩ :=
      (berg_two_pow_eq_one_iff p hp (orderOf (redMat p M₂))).mp (pow_orderOf_eq_one _)
    exact Nat.lcm_dvd hk.two_dvd (orderOf_dvd_of_pow_eq_one hU)

/-! ## Resonance across a composite modulus -/

/-- **CRT decomposition of resonance.**  For coprime moduli, the resonance set of the product
is the intersection of the resonance sets.  Factoring `N = p q` is exactly the task of
finding an exponent in one resonance set but not the other. -/
theorem berg_resonance_crt (m n k : ℕ) (h : Nat.Coprime m n) :
    (redMat (m * n) M₂) ^ k = 1 ↔ (redMat m M₂) ^ k = 1 ∧ (redMat n M₂) ^ k = 1 := by
  have hco : IsCoprime (m : ℤ) (n : ℤ) := Nat.isCoprime_iff_coprime.mpr h
  rw [← redMat_pow, ← redMat_pow, ← redMat_pow, redMat_eq_one_iff, redMat_eq_one_iff,
    redMat_eq_one_iff]
  constructor
  · intro hall
    refine ⟨fun i j => ?_, fun i j => ?_⟩
    · exact dvd_trans ⟨(n : ℤ), by push_cast; ring⟩ (hall i j)
    · exact dvd_trans ⟨(m : ℤ), by push_cast; ring⟩ (hall i j)
  · rintro ⟨h1, h2⟩ i j
    have := hco.mul_dvd (h1 i j) (h2 i j)
    simpa [Nat.cast_mul] using this

/-! ## The Berggren–Lucas trace sequence -/

/-- Cayley–Hamilton for `M₂` in explicit power form. -/
theorem berg_two_cayley : M₂ ^ 3 = (5 : ℤ) • M₂ ^ 2 + (5 : ℤ) • M₂ - 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [M₂, pow_succ, Matrix.mul_apply, Fin.sum_univ_succ]

/-- The **Berggren–Lucas sequence** `t k = tr (M₂ ^ k) = (3+2√2)^k + (3-2√2)^k + (-1)^k`. -/
def bergTrace (k : ℕ) : ℤ := Matrix.trace (M₂ ^ k)

theorem berg_trace_values :
    bergTrace 0 = 3 ∧ bergTrace 1 = 5 ∧ bergTrace 2 = 35 ∧ bergTrace 3 = 197 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    simp [bergTrace, M₂, pow_succ, Matrix.trace_fin_three]

/-- **Newton recurrence.**  The trace sequence obeys the characteristic recurrence of `M₂`. -/
theorem berg_trace_rec (k : ℕ) :
    bergTrace (k + 3) = 5 * bergTrace (k + 2) + 5 * bergTrace (k + 1) - bergTrace k := by
  have h : M₂ ^ (k + 3) = M₂ ^ k * ((5 : ℤ) • M₂ ^ 2 + (5 : ℤ) • M₂ - 1) := by
    rw [← berg_two_cayley, ← pow_add]
  have expand : M₂ ^ k * ((5 : ℤ) • M₂ ^ 2 + (5 : ℤ) • M₂ - 1)
      = (5 : ℤ) • M₂ ^ (k + 2) + (5 : ℤ) • M₂ ^ (k + 1) - M₂ ^ k := by
    rw [mul_sub, mul_add, mul_smul_comm, mul_smul_comm, mul_one, ← pow_add, ← pow_succ]
  show Matrix.trace (M₂ ^ (k + 3)) = _
  rw [h, expand, Matrix.trace_sub, Matrix.trace_add, Matrix.trace_smul, Matrix.trace_smul,
    smul_eq_mul, smul_eq_mul]
  rfl

/-- Reduction commutes with the trace. -/
theorem bergTrace_cast (m k : ℕ) :
    ((bergTrace k : ℤ) : ZMod m) = Matrix.trace ((M2R (ZMod m)) ^ k) := by
  rw [← redMat_M₂, ← redMat_pow]
  simp [bergTrace, Matrix.trace_fin_three, redMat_apply]

/-- The trace of a power of `M₂` splits into the hyperbolic and the `-1` contributions. -/
theorem trace_M2R_pow (hp : p ≠ 2) (k : ℕ) :
    Matrix.trace ((M2R (ZMod p)) ^ k)
      = Matrix.trace ((bergU (ZMod p)) ^ k) + (-1 : ZMod p) ^ k := by
  have hdet : IsUnit (bergW (ZMod p)).det := by
    rw [det_bergW]; exact (isUnit_iff_ne_zero).mpr (two_ne_zero_of_odd_prime p hp)
  haveI : Invertible (bergW (ZMod p)) := invertibleOfIsUnitDet _ hdet
  have hc := berg_pow_conj (R := ZMod p) k
  have hinv : (bergW (ZMod p))⁻¹ * bergW (ZMod p) = 1 := Matrix.nonsing_inv_mul _ hdet
  have hM : (M2R (ZMod p)) ^ k = bergW (ZMod p) * (bergV (ZMod p)) ^ k * (bergW (ZMod p))⁻¹ := by
    rw [← hc, Matrix.mul_assoc, Matrix.mul_nonsing_inv _ hdet, mul_one]
  rw [hM, Matrix.mul_assoc, Matrix.trace_mul_comm, Matrix.mul_assoc, hinv, mul_one, bergV_pow]
  simp [blockEmbed, Matrix.trace_fin_three, Matrix.trace_fin_two]

/-- **Fermat-type congruence for the Berggren–Lucas sequence.**  For every odd prime `p`,
`t p ≡ 5 (mod p)`.  (Note `t 1 = 5 = tr M₂`: the Frobenius fixes the trace.) -/
theorem berg_trace_fermat (hp : p ≠ 2) : ((bergTrace p : ℤ) : ZMod p) = 5 := by
  have hodd : Odd p := (Nat.Prime.odd_of_ne_two Fact.out hp)
  have hU : Matrix.trace ((bergU (ZMod p)) ^ p) = 6 := by
    rw [bergU_frob p hp]
    simp [bergS, Matrix.trace_fin_two]
    ring
  rw [bergTrace_cast, trace_M2R_pow p hp, hU, hodd.neg_one_pow]
  ring

/-- Integral form of the congruence. -/
theorem berg_trace_fermat_int (hp : p ≠ 2) : (p : ℤ) ∣ bergTrace p - 5 := by
  have h := berg_trace_fermat p hp
  have : ((bergTrace p - 5 : ℤ) : ZMod p) = 0 := by push_cast [h]; ring
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp this

/-- **Compositeness witness.**  If `N` is odd and `t N ≢ 5 (mod N)`, then `N` is composite.
This is a Berggren-tree analogue of the Fermat/Lucas primality tests. -/
theorem berg_trace_composite_witness (N : ℕ) (hN : N ≠ 2) (h : ¬ ((N : ℤ) ∣ bergTrace N - 5)) :
    ¬ N.Prime := by
  intro hprime
  haveI : Fact N.Prime := ⟨hprime⟩
  exact h (berg_trace_fermat_int N hN)

/-- Worked instance of the test: `9` fails the Berggren–Lucas congruence, hence is composite
(`t 9 = 7761797 ≡ 8 (mod 9)`). -/
theorem berg_nine_composite_witness : ¬ (9 : ℕ).Prime := by
  refine berg_trace_composite_witness 9 (by norm_num) ?_
  have h9 : bergTrace 9 = 7761797 := by
    simp [bergTrace, M₂, pow_succ, Matrix.trace_fin_three]
  rw [h9]
  decide

end BerggrenSpectral