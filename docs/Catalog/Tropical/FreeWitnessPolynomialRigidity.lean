import Mathlib
import Tropical.FreeWitnessNonPolynomiality

/-!
# Rigidity: the only polynomial CRT weights are the monomials

The classification says the free-witness mechanism needs a *non-polynomial* local
weight.  That phrasing hides a question: which CRT-multiplicative weights are
polynomial at all?  This file answers it completely.

* **Rigidity theorem** (`polynomial_crt_weight_is_monomial`): if a polynomial
  `P ∈ ℤ[X]` is multiplicative across coprime arguments and normalised (`P(1) = 1`),
  then `P = X ^ deg P`.  So the *only* polynomial CRT weights are the power weights
  `d ↦ d ^ k` whose aggregates are the divisor power sums `σ_k` — the SIGK family
  predicted by the paper is not merely an example, it is the whole polynomial part of
  the class.  The proof is a rigidity argument: multiplicativity at the infinitely many
  primes `q > m` upgrades to the polynomial identity `P(mX) = P(m) P(X)`, whose leading
  coefficients force `P(m) = m ^ deg P` for every `m ≥ 1`, and a polynomial is pinned by
  infinitely many values.

* **Consequence for weights** (`crt_weight_polynomial_eq_pow`): a CRT weight in the
  sense of `FreeWitness.IsCRTWeight` that is computed by a polynomial is a power weight
  on all positive arguments.

* **The polynomial dichotomy** (`polynomial_crt_weight_dichotomy`): consequently every
  polynomial CRT weight is either the constant `1` — whose aggregate is the constant `4`
  on semiprimes, carrying no factor information — or a genuine power weight with
  `k ≥ 1`, whose aggregate pins the factorisation (trace lemma) *and* is provably not
  computable by any polynomial in `N` (barrier 4, from
  `Tropical.FreeWitnessNonPolynomiality`).  There is no polynomial weight in between.

The moral: inside the polynomial world, "free witness" and "power weight" are the same
thing, and every such witness is sealed.
-/

namespace FreeWitnessRigidity

open Finset Polynomial FreeWitness

/-! ## 1. The rigidity theorem -/

/-- **Rigidity.**  A normalised polynomial that is multiplicative on coprime natural
arguments is a monomial `X ^ k`. -/
theorem polynomial_crt_weight_is_monomial (P : Polynomial ℤ)
    (hmul : ∀ m n : ℕ, Nat.Coprime m n →
      P.eval ((m : ℤ) * (n : ℤ)) = P.eval (m : ℤ) * P.eval (n : ℤ))
    (hone : P.eval 1 = 1) : P = X ^ P.natDegree := by
  have hP0 : P ≠ 0 := by
    intro h; rw [h] at hone; simp at hone
  set k := P.natDegree with hk
  have ha : P.coeff k ≠ 0 := Polynomial.leadingCoeff_ne_zero.mpr hP0
  -- `P` agrees with `X ^ k` at every positive integer
  have hval : ∀ m : ℕ, 1 ≤ m → P.eval (m : ℤ) = (m : ℤ) ^ k := by
    intro m hm
    have hcomp : P.comp (C (m : ℤ) * X) = C (P.eval (m : ℤ)) * P := by
      refine Polynomial.eq_of_infinite_eval_eq _ _ ?_
      have hinf : {q : ℕ | q.Prime ∧ m < q}.Infinite := by
        have hset : {q : ℕ | q.Prime ∧ m < q} = {q : ℕ | q.Prime} \ {q : ℕ | q ≤ m} := by
          ext q; simp [not_le]
        rw [hset]
        exact Nat.infinite_setOf_prime.diff (Set.finite_Iic m)
      have hinj : Set.InjOn (fun q : ℕ => (q : ℤ)) {q : ℕ | q.Prime ∧ m < q} :=
        fun a _ b _ h => by simpa using h
      refine (hinf.image hinj).mono ?_
      rintro x ⟨q, ⟨hq, hqm⟩, rfl⟩
      have hcop : Nat.Coprime m q :=
        Nat.coprime_comm.mp (hq.coprime_iff_not_dvd.mpr
          (fun hdvd => by have := Nat.le_of_dvd (by omega) hdvd; omega))
      simp only [Set.mem_setOf_eq, eval_comp, eval_mul, eval_C, eval_X]
      rw [← hmul m q hcop]
    have hcoeff := congrArg (fun R => Polynomial.coeff R k) hcomp
    simp only [Polynomial.comp_C_mul_X_coeff, Polynomial.coeff_C_mul] at hcoeff
    have h2 : P.coeff k * (m : ℤ) ^ k = P.coeff k * P.eval (m : ℤ) := by
      rw [hcoeff]; ring
    exact (mul_left_cancel₀ ha h2).symm
  have hfinal : P = X ^ k := by
    refine Polynomial.eq_of_infinite_eval_eq _ _ ?_
    refine (Set.Ioi_infinite (0 : ℤ)).mono ?_
    intro x hx
    have hx0 : 0 < x := hx
    have hxe : x = ((x.toNat : ℤ)) := by omega
    simp only [Set.mem_setOf_eq, eval_pow, eval_X]
    rw [hxe]
    exact hval x.toNat (by omega)
  simpa [hk] using hfinal

/-! ## 2. Polynomial CRT weights are power weights -/

/-- A CRT weight computed by a polynomial is a power weight on positive arguments. -/
theorem crt_weight_polynomial_eq_pow {w : ℕ → ℕ} (hw : IsCRTWeight w) (P : Polynomial ℤ)
    (hPw : ∀ m : ℕ, P.eval (m : ℤ) = (w m : ℤ)) :
    ∀ m : ℕ, 1 ≤ m → w m = m ^ P.natDegree := by
  have hmul : ∀ m n : ℕ, Nat.Coprime m n →
      P.eval ((m : ℤ) * (n : ℤ)) = P.eval (m : ℤ) * P.eval (n : ℤ) := by
    intro m n hcop
    have : ((m : ℤ) * (n : ℤ)) = ((m * n : ℕ) : ℤ) := by push_cast; ring
    rw [this, hPw, hPw, hPw, hw.mul m n hcop]
    push_cast
    ring
  have hone : P.eval 1 = 1 := by
    have := hPw 1
    simpa [hw.one] using this
  have hmono := polynomial_crt_weight_is_monomial P hmul hone
  intro m hm
  have := hPw m
  rw [hmono] at this
  simp only [eval_pow, eval_X] at this
  exact_mod_cast this.symm

/-! ## 3. The polynomial dichotomy -/

/-- The semiprime aggregate only sees positive divisors, so weights agreeing on
positive arguments have equal aggregates. -/
theorem aggregate_congr_of_pos {w v : ℕ → ℕ} (h : ∀ m : ℕ, 1 ≤ m → w m = v m) (N : ℕ) :
    ∑ d ∈ N.divisors, w d = ∑ d ∈ N.divisors, v d :=
  Finset.sum_congr rfl fun d hd => h d (Nat.pos_of_mem_divisors hd)

/-- **The polynomial dichotomy.**  Let `w` be a CRT weight computed by a polynomial, of
degree `k`.  Either `k = 0`, and the aggregate is the constant `4` on every semiprime
(no information at all), or `k ≥ 1`, and then the aggregate is the `σ_k` witness: it
determines the factorisation among coprime factorisations of `N` (trace lemma) and it is
computed by no polynomial in `N` (sealing).  Nothing else can happen. -/
theorem polynomial_crt_weight_dichotomy {w : ℕ → ℕ} (hw : IsCRTWeight w) (P : Polynomial ℤ)
    (hPw : ∀ m : ℕ, P.eval (m : ℤ) = (w m : ℤ)) :
    (∀ x y : ℕ, x.Prime → y.Prime → x ≠ y → ∑ d ∈ (x * y).divisors, w d = 4)
      ∨ (1 ≤ P.natDegree
          ∧ (∀ N a b a' b' : ℕ, Nat.Coprime a b → Nat.Coprime a' b' → a ≤ b → a' ≤ b' →
              a * b = N → a' * b' = N →
              (1 + a ^ P.natDegree) * (1 + b ^ P.natDegree)
                = (1 + a' ^ P.natDegree) * (1 + b' ^ P.natDegree) → a = a' ∧ b = b')
          ∧ ¬ ∃ Q : Polynomial ℤ, ∀ x y : ℕ, x.Prime → y.Prime → x ≠ y →
              Q.eval ((x * y : ℕ) : ℤ)
                = ((∑ d ∈ (x * y).divisors, d ^ P.natDegree : ℕ) : ℤ)) := by
  have hpow := crt_weight_polynomial_eq_pow hw P hPw
  rcases Nat.eq_zero_or_pos P.natDegree with hk | hk
  · left
    intro x y hx hy hxy
    rw [aggregate_congr_of_pos (v := fun d => d ^ P.natDegree) hpow (x * y)]
    rw [aggregate_semiprime (isCRTWeight_pow P.natDegree) x y hx hy hxy, hk]
    norm_num
  · exact Or.inr ⟨hk, fun N a b a' b' hab hab' hle hle' h h' hA =>
      crt_free_witness_recovery_pow hk hab hab' hle hle' h h' hA,
      FreeWitnessBarriers.sigma_pow_not_polynomial hk⟩

end FreeWitnessRigidity