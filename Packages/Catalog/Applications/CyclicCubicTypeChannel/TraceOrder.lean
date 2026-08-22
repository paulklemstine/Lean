/-
# The Frobenius trace criterion for an arbitrary conductor

## Context (FACT round-32 #3, cycle 2)

`Applications.CyclicCubicTypeChannel.Splitting` settles conductor `7`: the cubic
`X³ + X² − 2X − 1` has a root mod `p` iff `p ≡ ±1 (mod 7)`.  The proof used one
structural fact — the companion matrix of `Y² − xY + 1` has order `7` exactly
when `x = ζ + ζ⁻¹` — which has nothing to do with `7`.

This file isolates that structure for an arbitrary odd prime conductor `m`,
using the Chebyshev-type coefficient sequence

  `A₀ = 0`, `A₁ = 1`, `A_{n+2}(t) = t·A_{n+1}(t) − A_n(t)`,

which satisfies `M^{n+1} = A_{n+1}(t)·M − A_n(t)·I` for every `2 × 2` matrix of
trace `t` and determinant `1`.  Main results:

* `TraceOrder.pow_eq_cheb` — the closed form for powers;
* `TraceOrder.companion_pow_of_matrix_pow` — *any* order-`m` element of
  `SL₂(𝔽_p)` that is not scalar transfers its order to the companion matrix of
  its trace;
* `TraceOrder.exists_companion_order_iff` — for odd primes `m ≠ p`:
  a companion matrix of order `m` exists over `𝔽_p` **iff** `p ≡ ±1 (mod m)`
  (in the form `m ∣ p² − 1`);
* `TraceOrder.cheb_root_iff` — the polynomial form: the pair
  `(A_m, A_{m−1}) = (0, −1)` is solvable over `𝔽_p` iff `m ∣ p² − 1`;
* `TraceOrder.golden_iff` — conductor `5`: `X² + X − 1` has a root mod `p` iff
  `p ≡ ±1 (mod 5)` (the golden-ratio / Fibonacci criterion);
* `TraceOrder.cubic_seven_iff` — conductor `7`: an independent second proof of
  `CyclicCubic.root_iff`, obtained by specialising the general criterion;
* `TraceOrder.quintic_eleven_iff` — conductor `11`: the quintic
  `X⁵ + X⁴ − 4X³ − 3X² + 3X + 1` (minimal polynomial of `ζ₁₁ + ζ₁₁⁻¹`) has a
  root mod `p` iff `p ≡ ±1 (mod 11)`.
-/
import Mathlib
import Applications.CyclicCubicTypeChannel.Splitting

open Matrix

namespace TraceOrder

/-! ## Chebyshev-type coefficients -/

/-- `A₀ = 0`, `A₁ = 1`, `A_{n+2} = t·A_{n+1} − A_n`. -/
def chebA {R : Type*} [CommRing R] (t : R) : ℕ → R
  | 0 => 0
  | 1 => 1
  | (n + 2) => t * chebA t (n + 1) - chebA t n

@[simp] lemma chebA_zero {R : Type*} [CommRing R] (t : R) : chebA t 0 = 0 := rfl
@[simp] lemma chebA_one {R : Type*} [CommRing R] (t : R) : chebA t 1 = 1 := rfl
lemma chebA_succ_succ {R : Type*} [CommRing R] (t : R) (n : ℕ) :
    chebA t (n + 2) = t * chebA t (n + 1) - chebA t n := rfl

variable {R : Type*} [CommRing R]

/-- Powers of a trace-`t`, determinant-one `2 × 2` matrix. -/
theorem pow_eq_cheb {M : Matrix (Fin 2) (Fin 2) R} {t : R} (hM : M ^ 2 = t • M - 1) :
    ∀ n : ℕ, M ^ (n + 1) = chebA t (n + 1) • M - chebA t n • 1 := by
  intro n
  induction n with
  | zero => simp
  | succ k ih =>
      have h := CyclicCubic.pow_step hM ih
      rw [h, chebA_succ_succ]
      congr 1
      congr 1
      ring

/-! ## The companion matrix -/

variable (R) in
/-- The companion matrix of `Y² − tY + 1`. -/
def comp (t : R) : Matrix (Fin 2) (Fin 2) R := !![t, -1; 1, 0]

lemma comp_sq (t : R) : (comp R t) ^ 2 = t • comp R t - 1 := CyclicCubic.companion_sq t

lemma comp_det (t : R) : (comp R t).det = 1 := by simp [comp, Matrix.det_fin_two_of]

lemma comp_ne_one [Nontrivial R] (t : R) : comp R t ≠ 1 := by
  intro h
  have h10 : (comp R t) 1 0 = (1 : Matrix (Fin 2) (Fin 2) R) 1 0 := by rw [h]
  simp [comp] at h10

/-- The companion matrix of `t` has order dividing `m` exactly when the
Chebyshev coefficients vanish appropriately. -/
lemma comp_pow_eq_one_iff [Nontrivial R] (t : R) (n : ℕ) :
    comp R t ^ (n + 1) = 1 ↔ chebA t (n + 1) • comp R t - chebA t n • 1
      = (1 : Matrix (Fin 2) (Fin 2) R) := by
  rw [pow_eq_cheb (comp_sq t) n]

/-- If the coefficients satisfy `A_m = 0` and `A_{m−1} = −1`, the companion
matrix has order dividing `m`. -/
lemma comp_pow_eq_one [Nontrivial R] {t : R} {n : ℕ} (h0 : chebA t (n + 1) = 0)
    (h1 : chebA t n = -1) : comp R t ^ (n + 1) = 1 := by
  rw [pow_eq_cheb (comp_sq t) n, h0, h1]
  simp

/-! ## Transfer from an arbitrary matrix to a companion matrix -/

section Field

variable {K : Type*} [Field K]

/-- A determinant-one matrix `M` with `M^m = 1` which is *not* scalar forces
`A_m(tr M) = 0` and `A_{m−1}(tr M) = −1`; hence the companion matrix of its
trace also has order dividing `m`. -/
theorem companion_pow_of_matrix_pow {M : Matrix (Fin 2) (Fin 2) K} {n : ℕ}
    (hdet : M.det = 1) (hpow : M ^ (n + 1) = 1)
    (hns : ∀ c : K, M ≠ c • (1 : Matrix (Fin 2) (Fin 2) K)) :
    chebA M.trace (n + 1) = 0 ∧ chebA M.trace n = -1 := by
  have hM2 : M ^ 2 = M.trace • M - 1 := by rw [CyclicCubic.cayley_two M, hdet, one_smul]
  have hkey := pow_eq_cheb hM2 n
  rw [hpow] at hkey
  by_cases h0 : chebA M.trace (n + 1) = 0
  · refine ⟨h0, ?_⟩
    rw [h0, zero_smul, zero_sub] at hkey
    have h11 : (1 : K) = -(chebA M.trace n) := by
      have h := congrArg (fun N : Matrix (Fin 2) (Fin 2) K => N 0 0) hkey
      simpa [Matrix.one_apply] using h
    linear_combination h11
  · exfalso
    have hscal : (chebA M.trace (n + 1)) • M
        = (1 + chebA M.trace n) • (1 : Matrix (Fin 2) (Fin 2) K) := by
      linear_combination (norm := module) -hkey
    have hMc : M = ((chebA M.trace (n + 1))⁻¹ * (1 + chebA M.trace n))
        • (1 : Matrix (Fin 2) (Fin 2) K) := by
      have h2 := congrArg (fun N => (chebA M.trace (n + 1))⁻¹ • N) hscal
      simpa [smul_smul, inv_mul_cancel₀ h0] using h2
    exact hns _ hMc

end Field

/-! ## The order criterion over `𝔽_p` -/

section Prime

variable (p : ℕ) [hp : Fact p.Prime]

private lemma card_GL_two_eq :
    Fintype.card (GL (Fin 2) (ZMod p)) = (p ^ 2 - 1) * (p ^ 2 - p) := by
  rw [← Nat.card_eq_fintype_card, Matrix.card_GL_field]
  simp [Fin.prod_univ_two, ZMod.card]

/-- Any matrix of prime order `m ≠ p` over `𝔽_p` forces `m ∣ p² − 1`. -/
theorem dvd_sq_sub_one_of_order {M : Matrix (Fin 2) (Fin 2) (ZMod p)} {m : ℕ}
    (hm : m.Prime) (hmp : m ≠ p) (hpow : M ^ m = 1) (hne : M ≠ 1) : m ∣ p ^ 2 - 1 := by
  have hp2 : 2 ≤ p := hp.out.two_le
  have hm1 : 1 ≤ m := hm.one_lt.le
  let U : (Matrix (Fin 2) (Fin 2) (ZMod p))ˣ :=
    ⟨M, M ^ (m - 1), by
        rw [← pow_succ', Nat.sub_add_cancel hm1]
        exact hpow, by
        rw [← pow_succ]
        rwa [Nat.sub_add_cancel hm1]⟩
  have hUpow : U ^ m = 1 := Units.ext (by simpa using hpow)
  have hUne : U ≠ 1 := fun h => hne (congrArg Units.val h)
  have hord : orderOf U = m := by
    rcases (Nat.Prime.eq_one_or_self_of_dvd hm _ (orderOf_dvd_of_pow_eq_one hUpow)) with h | h
    · exact absurd (orderOf_eq_one_iff.mp h) hUne
    · exact h
  have hdvd : m ∣ (p ^ 2 - 1) * (p ^ 2 - p) := by
    have hdc := orderOf_dvd_natCard (G := GL (Fin 2) (ZMod p)) U
    rwa [hord, Nat.card_eq_fintype_card, card_GL_two_eq p] at hdc
  rcases (Nat.Prime.dvd_mul hm).mp hdvd with h1 | h2
  · exact h1
  · have hfac : (p : ℕ) ^ 2 - p = p * (p - 1) := by rw [Nat.mul_sub, mul_one, sq]
    rw [hfac] at h2
    rcases (Nat.Prime.dvd_mul hm).mp h2 with hA | hB
    · exact absurd ((Nat.prime_dvd_prime_iff_eq hm hp.out).mp hA) hmp
    · -- `m ∣ p − 1` also gives `m ∣ p² − 1 = (p−1)(p+1)`
      obtain ⟨k, hk⟩ := hB
      refine ⟨k * (p + 1), ?_⟩
      have hpp : p ^ 2 - 1 = (p - 1) * (p + 1) := by
        obtain ⟨q, rfl⟩ : ∃ q, p = q + 1 := ⟨p - 1, by omega⟩
        have h1 : (q + 1) ^ 2 = q * (q + 1 + 1) + 1 := by ring
        rw [h1, Nat.add_sub_cancel, Nat.add_sub_cancel]
      rw [hpp, hk, mul_assoc]

/-- A companion matrix is never a scalar matrix (its `(1,0)` entry is `1`). -/
lemma comp_ne_smul_one {K : Type*} [Field K] (t c : K) :
    comp K t ≠ c • (1 : Matrix (Fin 2) (Fin 2) K) := by
  intro h
  have h10 := congrArg (fun N : Matrix (Fin 2) (Fin 2) K => N 1 0) h
  simp [comp] at h10

/-- Over a field, the companion matrix of `t` has order dividing `n+1`
exactly when the Chebyshev coefficients take the values `0` and `-1`. -/
theorem comp_pow_eq_one_iff' {K : Type*} [Field K] (t : K) (n : ℕ) :
    comp K t ^ (n + 1) = 1 ↔ chebA t (n + 1) = 0 ∧ chebA t n = -1 := by
  constructor
  · intro h
    have hkey := companion_pow_of_matrix_pow (comp_det t) h (comp_ne_smul_one t)
    have htr : (comp K t).trace = t := by simp [comp, Matrix.trace_fin_two_of]
    rwa [htr] at hkey
  · rintro ⟨h0, h1⟩
    exact comp_pow_eq_one h0 h1

/-- Any non-scalar determinant-one matrix killed by `X^(n+1) - 1` produces a
companion matrix with the same property. -/
theorem exists_comp_of_nonscalar {K : Type*} [Field K] {M : Matrix (Fin 2) (Fin 2) K} {n : ℕ}
    (hdet : M.det = 1) (hpow : M ^ (n + 1) = 1)
    (hns : ∀ c : K, M ≠ c • (1 : Matrix (Fin 2) (Fin 2) K)) :
    ∃ t : K, comp K t ^ (n + 1) = 1 ∧ comp K t ≠ 1 := by
  obtain ⟨h0, h1⟩ := companion_pow_of_matrix_pow hdet hpow hns
  exact ⟨M.trace, comp_pow_eq_one h0 h1, comp_ne_one _⟩

set_option maxRecDepth 4000 in
/-- Existence of an order-`m` companion matrix over `𝔽_p`, for an odd prime
`m ≠ p`, is exactly the congruence `p ≡ ±1 (mod m)` in the form `m ∣ p² − 1`. -/
theorem exists_companion_order_iff {m : ℕ} (hm : m.Prime) (hm2 : m ≠ 2) (hmp : m ≠ p) :
    (∃ t : ZMod p, comp (ZMod p) t ^ m = 1 ∧ comp (ZMod p) t ≠ 1) ↔ m ∣ p ^ 2 - 1 := by
  haveI : Fact m.Prime := ⟨hm⟩
  have hp2 : 2 ≤ p := hp.out.two_le
  constructor
  · rintro ⟨t, hpow, hne⟩
    exact dvd_sq_sub_one_of_order p hm hmp hpow hne
  · intro hdvd
    obtain ⟨n, rfl⟩ : ∃ n, m = n + 1 := ⟨m - 1, by have := hm.two_le; omega⟩
    by_cases hcase : (n + 1) ∣ p - 1
    · -- a primitive `m`-th root of unity already lives in `𝔽_p`
      have hcard : (n + 1) ∣ Fintype.card (ZMod p)ˣ := by
        rwa [ZMod.card_units_eq_totient, Nat.totient_prime hp.out]
      obtain ⟨u, hu⟩ := exists_prime_orderOf_dvd_card (G := (ZMod p)ˣ) (n + 1) hcard
      have huone : u ^ (n + 1) = 1 := by rw [← hu]; exact pow_orderOf_eq_one u
      have hvw : (u : ZMod p) * ((u⁻¹ : (ZMod p)ˣ) : ZMod p) = 1 := u.mul_inv
      have hv7 : (u : ZMod p) ^ (n + 1) = 1 := by
        rw [← Units.val_pow_eq_pow_val, huone, Units.val_one]
      have hw7 : ((u⁻¹ : (ZMod p)ˣ) : ZMod p) ^ (n + 1) = 1 := by
        rw [← Units.val_pow_eq_pow_val, inv_pow, huone, inv_one, Units.val_one]
      have hne2 : (u : ZMod p) ≠ ((u⁻¹ : (ZMod p)ˣ) : ZMod p) := by
        intro heq
        have huu : u = u⁻¹ := Units.ext heq
        have hu2 : u ^ 2 = 1 := by
          rw [sq]
          nth_rewrite 2 [huu]
          simp
        have hdvd2 : (n + 1) ∣ 2 := hu ▸ orderOf_dvd_of_pow_eq_one hu2
        have h2le := Nat.le_of_dvd (by norm_num) hdvd2
        have := hm.two_le
        omega
      refine exists_comp_of_nonscalar
        (M := Matrix.diagonal ![(u : ZMod p), ((u⁻¹ : (ZMod p)ˣ) : ZMod p)]) ?_ ?_ ?_
      · rw [Matrix.det_diagonal, Fin.prod_univ_two]
        exact hvw
      · have hfun :
            (![(u : ZMod p), ((u⁻¹ : (ZMod p)ˣ) : ZMod p)] : Fin 2 → ZMod p) ^ (n + 1) = 1 := by
          funext i
          fin_cases i
          · exact hv7
          · exact hw7
        rw [Matrix.diagonal_pow, hfun]
        simp
      · intro c hc
        refine hne2 ?_
        have h00 : (u : ZMod p) = c := by
          have h := congrArg (fun N : Matrix (Fin 2) (Fin 2) (ZMod p) => N 0 0) hc
          simp only [Matrix.diagonal_apply_eq, Matrix.smul_apply, Matrix.one_apply_eq,
            smul_eq_mul, mul_one] at h
          exact h
        have h11 : ((u⁻¹ : (ZMod p)ˣ) : ZMod p) = c := by
          have h := congrArg (fun N : Matrix (Fin 2) (Fin 2) (ZMod p) => N 1 1) hc
          simp only [Matrix.diagonal_apply_eq, Matrix.smul_apply, Matrix.one_apply_eq,
            smul_eq_mul, mul_one] at h
          exact h
        rw [h00, h11]
    · -- otherwise use Cauchy's theorem inside `GL₂(𝔽_p)`
      have key : ∀ x : ZMod p, x ≠ 0 → x ^ (n + 1) = 1 → x = 1 := by
        intro x hx0 hx
        have h1 : orderOf x ∣ n + 1 := orderOf_dvd_of_pow_eq_one hx
        have h2 : orderOf x ∣ p - 1 :=
          orderOf_dvd_of_pow_eq_one (ZMod.pow_card_sub_one_eq_one hx0)
        rcases hm.eq_one_or_self_of_dvd _ h1 with h | h
        · exact orderOf_eq_one_iff.mp h
        · exact absurd (h ▸ h2) hcase
      have hcard : (n + 1) ∣ Fintype.card (GL (Fin 2) (ZMod p)) := by
        rw [card_GL_two_eq p]
        exact hdvd.mul_right _
      obtain ⟨U, hU⟩ := exists_prime_orderOf_dvd_card (G := GL (Fin 2) (ZMod p)) (n + 1) hcard
      set M : Matrix (Fin 2) (Fin 2) (ZMod p) := (U : Matrix (Fin 2) (Fin 2) (ZMod p)) with hM
      have hMpow : M ^ (n + 1) = 1 := by
        have h : U ^ (n + 1) = 1 := by rw [← hU]; exact pow_orderOf_eq_one U
        have := congrArg (Units.val) h
        simpa [hM] using this
      have hMunit : IsUnit M := hM ▸ U.isUnit
      have hdet0 : M.det ≠ 0 := (Matrix.isUnit_iff_isUnit_det M |>.mp hMunit).ne_zero
      have hdet : M.det = 1 := by
        refine key _ hdet0 ?_
        rw [← Matrix.det_pow, hMpow, Matrix.det_one]
      have hns : ∀ c : ZMod p, M ≠ c • (1 : Matrix (Fin 2) (Fin 2) (ZMod p)) := by
        intro c hc
        have hcpow : c ^ (n + 1) = 1 := by
          have h := hMpow
          rw [hc, smul_pow, one_pow] at h
          have h00 := congrArg (fun N : Matrix (Fin 2) (Fin 2) (ZMod p) => N 0 0) h
          simpa [Matrix.one_apply] using h00
        have hc0 : c ≠ 0 := by
          intro h0
          rw [h0, zero_smul] at hc
          rw [hc, Matrix.det_zero ⟨0⟩] at hdet
          exact zero_ne_one hdet
        have hc1 : c = 1 := key c hc0 hcpow
        have hM1 : M = 1 := by rw [hc, hc1, one_smul]
        have hU1 : U = 1 := Units.ext (by simpa [hM] using hM1)
        rw [hU1, orderOf_one] at hU
        have := hm.two_le
        omega
      exact exists_comp_of_nonscalar hdet hMpow hns

/-- Polynomial form of the criterion: the Chebyshev coefficient pair
`(A_m, A_{m-1}) = (0, -1)` is solvable over `𝔽_p` iff `m ∣ p² − 1`. -/
theorem cheb_root_iff {m : ℕ} (hm : m.Prime) (hm2 : m ≠ 2) (hmp : m ≠ p) :
    (∃ t : ZMod p, chebA t m = 0 ∧ chebA t (m - 1) = -1) ↔ m ∣ p ^ 2 - 1 := by
  obtain ⟨n, rfl⟩ : ∃ n, m = n + 1 := ⟨m - 1, by have := hm.two_le; omega⟩
  rw [← exists_companion_order_iff p hm hm2 hmp]
  simp only [Nat.add_sub_cancel]
  constructor
  · rintro ⟨t, h0, h1⟩
    exact ⟨t, (comp_pow_eq_one_iff' t n).mpr ⟨h0, h1⟩, comp_ne_one t⟩
  · rintro ⟨t, hpow, -⟩
    exact ⟨t, (comp_pow_eq_one_iff' t n).mp hpow⟩

end Prime


/-! ## Explicit Chebyshev coefficients -/

section Values

variable {R : Type*} [CommRing R]

lemma chebA_four (t : R) : chebA t 4 = t ^ 3 - 2 * t := by simp [chebA]; ring

lemma chebA_five (t : R) : chebA t 5 = t ^ 4 - 3 * t ^ 2 + 1 := by simp [chebA]; ring

lemma chebA_six (t : R) : chebA t 6 = t ^ 5 - 4 * t ^ 3 + 3 * t := by simp [chebA]; ring

lemma chebA_seven (t : R) : chebA t 7 = t ^ 6 - 5 * t ^ 4 + 6 * t ^ 2 - 1 := by
  simp [chebA]; ring

lemma chebA_ten (t : R) :
    chebA t 10 = t ^ 9 - 8 * t ^ 7 + 21 * t ^ 5 - 20 * t ^ 3 + 5 * t := by
  simp [chebA]; ring

lemma chebA_eleven (t : R) :
    chebA t 11 = t ^ 10 - 9 * t ^ 8 + 28 * t ^ 6 - 35 * t ^ 4 + 15 * t ^ 2 - 1 := by
  simp [chebA]; ring

end Values

/-! ## Reading the criterion as a congruence -/

private lemma sq_eq_one_zmod5 : ∀ a : ZMod 5, a ^ 2 = 1 ↔ (a = 1 ∨ a = 4) := by decide

private lemma sq_eq_one_zmod11 : ∀ a : ZMod 11, a ^ 2 = 1 ↔ (a = 1 ∨ a = 10) := by decide

private lemma sq_eq_one_zmod7' : ∀ a : ZMod 7, a ^ 2 = 1 ↔ (a = 1 ∨ a = 6) := by decide

section Congruence

variable (p : ℕ) [hp : Fact p.Prime]

/-- `m ∣ p² − 1` is the congruence `p ≡ ±1 (mod m)`, written multiplicatively. -/
lemma dvd_sq_sub_one_iff_sq_cast {m : ℕ} [NeZero m] :
    m ∣ p ^ 2 - 1 ↔ ((p : ZMod m)) ^ 2 = 1 := by
  have hp2 : 2 ≤ p := hp.out.two_le
  have hp1 : 1 ≤ p ^ 2 := Nat.one_le_pow _ _ (by omega)
  have h : ((p ^ 2 - 1 : ℕ) : ZMod m) = (p : ZMod m) ^ 2 - 1 := by
    rw [Nat.cast_sub hp1]
    push_cast
    ring
  rw [← ZMod.natCast_eq_zero_iff, h, sub_eq_zero]

/-! ## Conductor 5: the golden-ratio criterion -/

/-- **Conductor 5.**  For a prime `p ≠ 5` the quadratic `X² + X − 1` (minimal
polynomial of `ζ₅ + ζ₅⁻¹`, the golden ratio conjugate) has a root modulo `p`
exactly when `p ≡ ±1 (mod 5)`.  This is the `C₂`-analogue of the cyclic-cubic
splitting law, obtained from the same trace-order machinery. -/
theorem golden_iff (hp5 : p ≠ 5) :
    (∃ x : ZMod p, x ^ 2 + x - 1 = 0) ↔ ((p : ZMod 5) = 1 ∨ (p : ZMod 5) = 4) := by
  rw [← sq_eq_one_zmod5, ← dvd_sq_sub_one_iff_sq_cast p,
    ← cheb_root_iff p (by norm_num) (by norm_num) (Ne.symm hp5)]
  simp only [show (5 : ℕ) - 1 = 4 from rfl, chebA_five, chebA_four]
  constructor
  · rintro ⟨x, hx⟩
    exact ⟨x, by linear_combination (x ^ 2 - x - 1) * hx, by linear_combination (x - 1) * hx⟩
  · rintro ⟨t, h5, h4⟩
    have hfac : (t - 1) * (t ^ 2 + t - 1) = 0 := by linear_combination h4
    rcases mul_eq_zero.mp hfac with h | h
    · exfalso
      have ht : t = 1 := by linear_combination h
      rw [ht] at h5
      have h10 : (1 : ZMod p) = 0 := by linear_combination -h5
      exact one_ne_zero h10
    · exact ⟨t, h⟩

/-! ## Conductor 7: an independent proof of the cyclic-cubic splitting law -/

/-- **Conductor 7, second proof.**  The splitting criterion
`CyclicCubic.root_iff` re-derived from the general trace-order theorem: the
cubic `X³ + X² − 2X − 1` has a root mod `p` iff `7 ∣ p² − 1`.  The two proofs
are logically independent (this one never uses `CyclicCubic.root_iff`), so the
agreement is a genuine consistency check on the conductor-7 channel. -/
theorem cubic_seven_iff (hp7 : p ≠ 7) :
    (∃ x : ZMod p, CyclicCubic.fval x = 0) ↔ ((p : ZMod 7) = 1 ∨ (p : ZMod 7) = 6) := by
  rw [← sq_eq_one_zmod7', ← dvd_sq_sub_one_iff_sq_cast p,
    ← cheb_root_iff p (by norm_num) (by norm_num) (Ne.symm hp7)]
  simp only [show (7 : ℕ) - 1 = 6 from rfl, chebA_seven, chebA_six, CyclicCubic.fval]
  constructor
  · rintro ⟨x, hx⟩
    refine ⟨x, by linear_combination (x ^ 3 - x ^ 2 - 2 * x + 1) * hx, ?_⟩
    linear_combination (x ^ 2 - x - 1) * hx
  · rintro ⟨t, h7, h6⟩
    by_cases hf : t ^ 3 + t ^ 2 - 2 * t - 1 = 0
    · exact ⟨t, hf⟩
    · exfalso
      have hfac : (t ^ 3 + t ^ 2 - 2 * t - 1) * (t ^ 3 - t ^ 2 - 2 * t + 1) = 0 := by
        linear_combination h7
      have hg : t ^ 3 - t ^ 2 - 2 * t + 1 = 0 := by
        rcases mul_eq_zero.mp hfac with h | h
        · exact absurd h hf
        · exact h
      have hfac2 : (t ^ 3 + t ^ 2 - 2 * t - 1) * (t ^ 2 - t - 1) = 0 := by
        linear_combination h6
      have hq : t ^ 2 - t - 1 = 0 := by
        rcases mul_eq_zero.mp hfac2 with h | h
        · exact absurd h hf
        · exact h
      have ht : t = 1 := by linear_combination -hg + t * hq
      rw [ht] at hq
      have h10 : (1 : ZMod p) = 0 := by linear_combination -hq
      exact one_ne_zero h10

/-! ## Conductor 11: the quintic criterion -/

/-- **Conductor 11.**  For a prime `p ≠ 11` the quintic
`X⁵ + X⁴ − 4X³ − 3X² + 3X + 1` — the minimal polynomial of `ζ₁₁ + ζ₁₁⁻¹`,
defining the cyclic quintic field of conductor `11` — has a root modulo `p`
exactly when `p ≡ ±1 (mod 11)`.

The proof is the conductor-7 argument verbatim with a different pair of
factorisations, `A₁₁ = Ψ·Ψ⁻` and `A₁₀ + 1 = Ψ·S`, together with the Bézout
identity `(2t − t³)·Ψ⁻ + (1 − 3t² + t⁴)·S = 1` over `ℤ[t]`, which shows that the
two spurious branches are coprime with *no* exceptional prime. -/
theorem quintic_eleven_iff (hp11 : p ≠ 11) :
    (∃ x : ZMod p, x ^ 5 + x ^ 4 - 4 * x ^ 3 - 3 * x ^ 2 + 3 * x + 1 = 0) ↔
      ((p : ZMod 11) = 1 ∨ (p : ZMod 11) = 10) := by
  rw [← sq_eq_one_zmod11, ← dvd_sq_sub_one_iff_sq_cast p,
    ← cheb_root_iff p (by norm_num) (by norm_num) (Ne.symm hp11)]
  simp only [show (11 : ℕ) - 1 = 10 from rfl, chebA_eleven, chebA_ten]
  constructor
  · rintro ⟨x, hx⟩
    refine ⟨x, ?_, ?_⟩
    · linear_combination (x ^ 5 - x ^ 4 - 4 * x ^ 3 + 3 * x ^ 2 + 3 * x - 1) * hx
    · linear_combination (x ^ 4 - x ^ 3 - 3 * x ^ 2 + 2 * x + 1) * hx
  · rintro ⟨t, h11, h10⟩
    by_cases hf : t ^ 5 + t ^ 4 - 4 * t ^ 3 - 3 * t ^ 2 + 3 * t + 1 = 0
    · exact ⟨t, hf⟩
    · exfalso
      have hfac1 : (t ^ 5 + t ^ 4 - 4 * t ^ 3 - 3 * t ^ 2 + 3 * t + 1) *
          (t ^ 5 - t ^ 4 - 4 * t ^ 3 + 3 * t ^ 2 + 3 * t - 1) = 0 := by
        linear_combination h11
      have hfac2 : (t ^ 5 + t ^ 4 - 4 * t ^ 3 - 3 * t ^ 2 + 3 * t + 1) *
          (t ^ 4 - t ^ 3 - 3 * t ^ 2 + 2 * t + 1) = 0 := by
        linear_combination h10
      have hg : t ^ 5 - t ^ 4 - 4 * t ^ 3 + 3 * t ^ 2 + 3 * t - 1 = 0 := by
        rcases mul_eq_zero.mp hfac1 with h | h
        · exact absurd h hf
        · exact h
      have hs : t ^ 4 - t ^ 3 - 3 * t ^ 2 + 2 * t + 1 = 0 := by
        rcases mul_eq_zero.mp hfac2 with h | h
        · exact absurd h hf
        · exact h
      have hone : (1 : ZMod p) = 0 := by
        linear_combination (2 * t - t ^ 3) * hg + (1 - 3 * t ^ 2 + t ^ 4) * hs
      exact one_ne_zero hone

end Congruence

end TraceOrder