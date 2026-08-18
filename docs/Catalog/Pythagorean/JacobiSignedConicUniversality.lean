import Tropical.JacobiSignedMultiplicative
import Tropical.JacobiSignedNonDial

/-!
# Universality of the CRT argument: every polynomial-weighted count is multiplicative,
# and every separable conic weight is a constant

This file settles the structural half of conjecture **C5** of the JACSIGN future-directions
list: *the CRT proof of `circleWeightZ_mul` never used the specific weight.*

For an arbitrary integer polynomial `f` we define the Jacobi-signed count

`WZpoly f n = ∑_{x : ZMod n} ( f(x) / n )`

(the Jacobi symbol of the value of `f`), which for `f = X - X³` is the Jacobi-signed circle
count `JacSign.WZ` of the catalog (`WZpoly_eq_WZ`).

Main results.

* `JacSign.WZpoly_mul` : `WZpoly f (m n) = WZpoly f m · WZpoly f n` for coprime moduli, for
  **every** `f`.  Multiplicativity is a property of the Chinese remainder theorem, not of the
  circle.
* `JacSign.Qroots_prime_of_ne` : for a *separable* quadratic weight `(x-r)(x-s)` and an odd
  prime `p` with `r ≢ s (mod p)`, the statistic is the **constant** `-1`.
* `JacSign.Qroots_squarefree` : hence for squarefree `N` coprime to `r - s`,
  `Qroots r s N = (-1)^{ω(N)}` — the statistic knows only the *number* of prime factors.
* `JacSign.conic_witness_blind` : for every separable conic weight, the value at a semiprime
  `N = p q` is the constant `1`.  A conic-weighted witness of degree 2 therefore carries
  **zero** bits about the factorisation: it dies far below the Weil floor.
* `JacSign.circle_beats_conic` : the cubic circle weight is genuinely different — `WZ 85 = -4`
  whereas every separable conic weight at a semiprime equals `1`.  So the `√N`-sized
  fluctuation of JACSIGN is a real feature of the *cubic* `x - x³`, and even that is at the
  Weil floor.
-/

open Finset Polynomial

namespace JacSign

/-- Evaluation of an integer polynomial in `ZMod n`. -/
noncomputable def evalZMod (n : ℕ) (f : ℤ[X]) (x : ZMod n) : ZMod n :=
  f.eval₂ (Int.castRingHom (ZMod n)) x

/-- **The general polynomial-weighted count.**  `WZpoly f n = ∑_x (f(x)/n)`. -/
noncomputable def WZpoly (f : ℤ[X]) (n : ℕ) [NeZero n] : ℤ :=
  ∑ x : ZMod n, jchar n (evalZMod n f x)

/-- Evaluation commutes with reduction of the modulus. -/
theorem evalZMod_hom {m n : ℕ} (φ : ZMod n →+* ZMod m) (f : ℤ[X]) (x : ZMod n) :
    φ (evalZMod n f x) = evalZMod m f (φ x) := by
  unfold evalZMod
  rw [Polynomial.hom_eval₂ f (Int.castRingHom (ZMod n)) φ x]
  congr 1
  exact RingHom.ext_int _ _

/-- **C5, structural half.**  For *every* integer polynomial weight the count is multiplicative
in the modulus.  The Chinese remainder theorem, not the geometry of the circle, is what makes
the JACSIGN statistic split along the factorisation. -/
theorem WZpoly_mul (f : ℤ[X]) (m n : ℕ) [NeZero m] [NeZero n] (h : m.Coprime n) :
    haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
    WZpoly f (m * n) = WZpoly f m * WZpoly f n := by
  haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
  set F : ZMod (m * n) →+* ZMod m := ZMod.castHom (dvd_mul_right m n) (ZMod m) with hF
  set G : ZMod (m * n) →+* ZMod n := ZMod.castHom (dvd_mul_left n m) (ZMod n) with hG
  have hsplit : ∀ x : ZMod (m * n), jchar (m * n) (evalZMod (m * n) f x)
      = jchar m (evalZMod m f (F x)) * jchar n (evalZMod n f (G x)) := by
    intro x
    show jacobiSym _ (m * n) = _
    rw [jacobiSym.mul_right]
    congr 1
    · rw [jchar_cast (k := m) (evalZMod (m * n) f x) (dvd_mul_right m n)]
      congr 1
      exact evalZMod_hom F f x
    · rw [jchar_cast (k := n) (evalZMod (m * n) f x) (dvd_mul_left n m)]
      congr 1
      exact evalZMod_hom G f x
  have hprod : WZpoly f (m * n)
      = ∑ z : ZMod m × ZMod n, jchar m (evalZMod m f z.1) * jchar n (evalZMod n f z.2) := by
    rw [WZpoly, Finset.sum_congr rfl fun x _ => hsplit x]
    refine Fintype.sum_equiv (ZMod.chineseRemainder h).toEquiv _ _ fun x => ?_
    have h1 : ((ZMod.chineseRemainder h).toEquiv x).1 = F x := by
      simp [hF, ZMod.chineseRemainder]
    have h2 : ((ZMod.chineseRemainder h).toEquiv x).2 = G x := by
      simp [hG, ZMod.chineseRemainder]
    rw [h1, h2]
  rw [hprod, WZpoly, WZpoly, Finset.sum_mul_sum]
  exact Fintype.sum_prod_type _

/-- The Jacobi-signed circle count is the polynomial count of `X - X³`. -/
theorem WZpoly_eq_WZ (n : ℕ) [NeZero n] : WZpoly (X - X ^ 3) n = WZ n := by
  refine Finset.sum_congr rfl fun x _ => ?_
  congr 1
  show evalZMod n (X - X ^ 3) x = x * (1 - x ^ 2)
  simp [evalZMod]
  ring

/-! ### Separable conic weights: the constant statistic -/

/-- The conic (degree two) weight with integer roots `r`, `s`. -/
noncomputable def Qroots (r s : ℤ) (n : ℕ) [NeZero n] : ℤ :=
  WZpoly ((X - C r) * (X - C s)) n

theorem Qroots_eq (r s : ℤ) (n : ℕ) [NeZero n] :
    Qroots r s n = ∑ x : ZMod n, jchar n ((x - (r : ZMod n)) * (x - (s : ZMod n))) := by
  refine Finset.sum_congr rfl fun x _ => ?_
  congr 1
  show evalZMod n ((X - C r) * (X - C s)) x = (x - (r : ZMod n)) * (x - (s : ZMod n))
  simp only [evalZMod, eval₂_mul, eval₂_sub, eval₂_X]
  rw [eval₂_C, eval₂_C]
  simp

/-- Conic weights are multiplicative in the modulus. -/
theorem Qroots_mul (r s : ℤ) (m n : ℕ) [NeZero m] [NeZero n] (h : m.Coprime n) :
    haveI : NeZero (m * n) := ⟨Nat.mul_ne_zero (NeZero.ne m) (NeZero.ne n)⟩
    Qroots r s (m * n) = Qroots r s m * Qroots r s n :=
  WZpoly_mul _ m n h

/-- **A separable conic weight is a constant at every odd prime.**  If `r ≢ s (mod p)` then the
statistic equals `-1`, independently of `p`, `r`, `s`: a conic witness sees nothing at all. -/
theorem Qroots_prime_of_ne (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {r s : ℤ}
    (hrs : (r : ZMod p) ≠ (s : ZMod p)) : Qroots r s p = -1 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  rw [Qroots_eq]
  have hval : ∀ x : ZMod p, jchar p ((x - (r : ZMod p)) * (x - (s : ZMod p)))
      = quadraticChar (ZMod p) ((x - (r : ZMod p)) * (x - (s : ZMod p))) :=
    fun x => jchar_prime p _
  rw [Finset.sum_congr rfl fun x _ => hval x, chiSum_quadratic p hp (r : ZMod p) (s : ZMod p),
    if_neg hrs]

/-- The degenerate (double root) case: the statistic is `p - 1`, again independent of the
factorisation data. -/
theorem Qroots_prime_of_eq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {r s : ℤ}
    (hrs : (r : ZMod p) = (s : ZMod p)) : Qroots r s p = (p : ℤ) - 1 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  rw [Qroots_eq]
  have hval : ∀ x : ZMod p, jchar p ((x - (r : ZMod p)) * (x - (s : ZMod p)))
      = quadraticChar (ZMod p) ((x - (r : ZMod p)) * (x - (s : ZMod p))) :=
    fun x => jchar_prime p _
  rw [Finset.sum_congr rfl fun x _ => hval x, chiSum_quadratic p hp (r : ZMod p) (s : ZMod p),
    if_pos hrs]

/-- **The conic witness is blind.**  For distinct odd primes `p, q` at which the conic is
separable, the statistic of the semiprime `N = p q` is the constant `1`: it carries no
information whatsoever about the factorisation — not even the `O(√N)` fluctuation of the
cubic circle weight. -/
theorem conic_witness_blind {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (hp : p ≠ 2) (hq : q ≠ 2) {r s : ℤ} (hrp : (r : ZMod p) ≠ (s : ZMod p))
    (hrq : (r : ZMod q) ≠ (s : ZMod q)) :
    haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero (Fact.out : p.Prime).ne_zero
      (Fact.out : q.Prime).ne_zero⟩
    Qroots r s (p * q) = 1 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  haveI : NeZero q := ⟨(Fact.out : q.Prime).ne_zero⟩
  have hcop : p.Coprime q := (Nat.coprime_primes Fact.out Fact.out).mpr hpq
  rw [Qroots_mul r s p q hcop, Qroots_prime_of_ne p hp hrp, Qroots_prime_of_ne q hq hrq]
  norm_num

/-- Transport of `Qroots` along an equality of moduli. -/
theorem Qroots_congr (r s : ℤ) {m n : ℕ} (h : m = n) (i : NeZero m) (j : NeZero n) :
    @Qroots r s m i = @Qroots r s n j := by
  subst h; rfl

/-- **The general squarefree law.**  For squarefree `N` all of whose prime factors are odd and
separate the two roots, the conic statistic is exactly `(-1)^{ω(N)}`: it is a function of the
number of prime factors and of nothing else. -/
theorem Qroots_squarefree (r s : ℤ) {N : ℕ} (i : NeZero N) (hN : Squarefree N)
    (hodd : ∀ p ∈ N.primeFactors, p ≠ 2)
    (hsep : ∀ p ∈ N.primeFactors, ∀ (_ : Fact p.Prime), (r : ZMod p) ≠ (s : ZMod p)) :
    @Qroots r s N i = (-1) ^ N.primeFactors.card := by
  have hprod : (∏ p ∈ N.primeFactors, p) = N := Nat.prod_primeFactors_of_squarefree hN
  haveI j : NeZero (∏ p ∈ N.primeFactors, p) := ⟨by rw [hprod]; exact i.out⟩
  rw [← Qroots_congr r s hprod j i]
  -- induction over the set of prime factors
  have key : ∀ (S : Finset ℕ), (∀ p ∈ S, p.Prime) → (∀ p ∈ S, p ≠ 2) →
      (∀ p ∈ S, ∀ (_ : Fact p.Prime), (r : ZMod p) ≠ (s : ZMod p)) →
      ∀ (k : NeZero (∏ p ∈ S, p)), @Qroots r s (∏ p ∈ S, p) k = (-1) ^ S.card := by
    intro S
    induction S using Finset.cons_induction with
    | empty =>
        intro _ _ _ k
        have h1 : (∏ p ∈ (∅ : Finset ℕ), p) = 1 := by simp
        rw [Qroots_congr r s h1 k (⟨one_ne_zero⟩ : NeZero 1)]
        have : @Qroots r s 1 ⟨one_ne_zero⟩ = 1 := by
          simp [Qroots_eq, jchar]
        simpa using this
    | cons a T ha ih =>
        intro hprime h2 hsp k
        have hpa : a.Prime := hprime a (Finset.mem_cons_self a T)
        haveI : Fact a.Prime := ⟨hpa⟩
        haveI ia : NeZero a := ⟨hpa.ne_zero⟩
        have hTpos : 0 < ∏ p ∈ T, p :=
          Finset.prod_pos fun p hp => (hprime p (Finset.mem_cons_of_mem hp)).pos
        haveI iT : NeZero (∏ p ∈ T, p) := ⟨hTpos.ne'⟩
        have hcop : a.Coprime (∏ p ∈ T, p) := by
          refine Nat.Coprime.prod_right fun b hb => ?_
          have hb' : b.Prime := hprime b (Finset.mem_cons_of_mem hb)
          have hne : a ≠ b := by rintro rfl; exact ha hb
          exact (Nat.coprime_primes hpa hb').mpr hne
        have hrec := ih (fun p hp => hprime p (Finset.mem_cons_of_mem hp))
          (fun p hp => h2 p (Finset.mem_cons_of_mem hp))
          (fun p hp => hsp p (Finset.mem_cons_of_mem hp)) iT
        have hcons : (∏ p ∈ Finset.cons a T ha, p) = a * ∏ p ∈ T, p := Finset.prod_cons ha
        rw [Qroots_congr r s hcons k (by infer_instance), Qroots_mul r s a (∏ p ∈ T, p) hcop,
          Qroots_prime_of_ne a (h2 a (Finset.mem_cons_self a T))
            (hsp a (Finset.mem_cons_self a T) ⟨hpa⟩), hrec, Finset.card_cons, pow_succ]
        ring
  exact key N.primeFactors (fun p hp => Nat.prime_of_mem_primeFactors hp) hodd hsep j

/-- **The circle weight is strictly richer than any conic weight.**  Every separable conic
statistic equals `1` at a semiprime, but the cubic circle statistic takes the value `-4` at
`N = 85`; so the JACSIGN fluctuation is a genuinely cubic phenomenon (and, by
`WZ_semiprime_sq_le`, still confined to the Weil floor). -/
theorem circle_beats_conic :
    ∃ (N : ℕ) (i : NeZero N), (∀ r s : ℤ, (r : ZMod 5) ≠ (s : ZMod 5) →
      (r : ZMod 17) ≠ (s : ZMod 17) → @Qroots r s N i = 1) ∧ @WZ N i ≠ 1 := by
  refine ⟨85, ⟨by norm_num⟩, ?_, ?_⟩
  · intro r s h5 h17
    haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
    haveI : Fact (Nat.Prime 17) := ⟨by norm_num⟩
    have h := conic_witness_blind (p := 5) (q := 17) (by norm_num) (by norm_num) (by norm_num)
      h5 h17
    have h85 : (5 : ℕ) * 17 = 85 := by norm_num
    rw [Qroots_congr r s h85 (by infer_instance) (⟨by norm_num⟩ : NeZero 85)] at h
    exact h
  · rw [WZ_85]
    norm_num

end JacSign