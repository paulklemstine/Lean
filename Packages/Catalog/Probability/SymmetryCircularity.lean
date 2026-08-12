/-
# Barriers II: symmetry (MMM), computational circularity (TTT),
# and known-method-in-disguise (ZZZ)

* **MMM, the symmetry barrier.**  Every power-sum invariant `p^k + q^k` of the
  hidden factors is a fixed polynomial in the two elementary symmetric
  functions `s = p + q` and `N = p * q` (`FactoringLab.powerSum_eq`).  Hence any
  two factorizations with the same `(N, s)` are indistinguishable by *every*
  symmetric invariant of this family (`FactoringLab.powerSum_congr`).
* **TTT, computational circularity.**  The pair `(N, s)` however *determines*
  the factorization (`FactoringLab.factors_determined_by_sum_prod`), and `s` is
  recoverable from Euler's totient value, so an invariant strong enough to
  break the symmetry barrier already factors `N`.  This is made effective by
  `FactoringLab.factor_recovery_from_totient`, an explicit closed-form recovery
  of `p` and `q` from `N` and `(p-1)(q-1)`.
* **ZZZ, known-method-in-disguise.**  Any method producing a nontrivial
  difference-of-squares representation of an odd `N` is exactly Fermat's method:
  `FactoringLab.fermat_representation_iff` shows the two notions coincide.
-/
import Mathlib

namespace FactoringLab

/-! ### MMM: the symmetry barrier -/

/-- The Newton recursion for the power sums of two numbers with elementary
symmetric functions `e₁ = p + q` and `e₂ = p * q`.  Note that it refers only to
`e₁` and `e₂`, never to `p` and `q` separately. -/
def powerSum (e₁ e₂ : ℤ) : ℕ → ℤ
  | 0 => 2
  | 1 => e₁
  | (k + 2) => e₁ * powerSum e₁ e₂ (k + 1) - e₂ * powerSum e₁ e₂ k

/-- **Newton's identity.**  Every power sum of the hidden factors is the value
of a fixed recursion in the elementary symmetric functions. -/
theorem powerSum_eq (p q : ℤ) : ∀ k : ℕ, powerSum (p + q) (p * q) k = p ^ k + q ^ k := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    match k with
    | 0 => simp [powerSum]
    | 1 => simp [powerSum]
    | (m + 2) =>
      have h1 := ih (m + 1) (by omega)
      have h0 := ih m (by omega)
      rw [show powerSum (p + q) (p * q) (m + 2)
            = (p + q) * powerSum (p + q) (p * q) (m + 1)
              - (p * q) * powerSum (p + q) (p * q) m from rfl, h1, h0]
      ring

/-- **The symmetry barrier (MMM).**  Two factorizations sharing the same
product and the same sum agree on *every* power-sum invariant: symmetric
invariants of this family cannot separate them. -/
theorem powerSum_congr {p q p' q' : ℤ} (hprod : p * q = p' * q') (hsum : p + q = p' + q')
    (k : ℕ) : p ^ k + q ^ k = p' ^ k + q' ^ k := by
  rw [← powerSum_eq p q k, ← powerSum_eq p' q' k, hprod, hsum]

/-! ### TTT: computational circularity -/

/-- The pair `(sum, product)` determines an ordered factorization.  Together
with `powerSum_congr` this is the circularity: the *only* extra datum that a
symmetric invariant could add to `N` is `p + q`, and that datum already
factors `N`. -/
theorem factors_determined_by_sum_prod {p q p' q' : ℤ} (hle : p ≤ q) (hle' : p' ≤ q')
    (hprod : p * q = p' * q') (hsum : p + q = p' + q') : p = p' ∧ q = q' := by
  have key : (p - p') * (p - q') = 0 := by
    have : p * p - (p' + q') * p + p' * q' = 0 := by
      rw [← hsum, ← hprod]; ring
    linear_combination this
  have hq : q = p' + q' - p := by linarith
  rcases mul_eq_zero.1 key with h | h
  · have hp : p = p' := by linarith
    exact ⟨hp, by rw [hq, hp]; ring⟩
  · have hp : p = q' := by linarith
    have hq'p : q = p' := by rw [hq, hp]; ring
    have : p' = q' := le_antisymm (by linarith) (by linarith)
    exact ⟨by rw [hp, ← this], by rw [hq'p, this]⟩

/-- **The recovery formula.**  If the sum `s = p + q` and the product `N = p*q`
of two integers `p ≤ q` are known, then `s² - 4N` is the perfect square
`(q - p)²` and the two factors are recovered in closed form as
`(s ∓ √(s² - 4N))/2`.  This is the engine behind the circularity barrier: any
invariant revealing `p + q` factors `N`. -/
theorem recovery_from_sum {p q s N : ℤ} (hpq : p ≤ q) (hN : N = p * q) (hs : s = p + q) :
    s ^ 2 - 4 * N = (q - p) ^ 2 ∧
      (s - (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = p ∧
      (s + (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = q := by
  have hd : s ^ 2 - 4 * N = (q - p) ^ 2 := by rw [hs, hN]; ring
  have hsq : (Int.sqrt (s ^ 2 - 4 * N) : ℤ) = q - p := by
    rw [hd, show (q - p) ^ 2 = (q - p) * (q - p) from by ring, Int.sqrt_eq]
    exact Int.natAbs_of_nonneg (by linarith)
  refine ⟨hd, ?_, ?_⟩
  · rw [hsq, hs, show p + q - (q - p) = 2 * p from by ring,
      Int.mul_ediv_cancel_left _ (by norm_num)]
  · rw [hsq, hs, show p + q + (q - p) = 2 * q from by ring,
      Int.mul_ediv_cancel_left _ (by norm_num)]

/-- **Explicit recovery from Euler's totient value (TTT).**  If `N = p * q`
with `p ≤ q` and `T = (p-1)(q-1)` is the totient value of `N` (for `p ≠ q`
prime), then `p` and `q` are obtained from `N` and `T` in closed form:
`s = N + 1 - T` is the sum of the factors, `s² - 4N` is a perfect square, and
the two factors are `(s ∓ √(s² - 4N))/2`.  Computing the totient of a semiprime
is therefore *at least as hard* as factoring it. -/
theorem factor_recovery_from_totient {p q : ℤ} (hpq : p ≤ q) :
    let N := p * q
    let T := (p - 1) * (q - 1)
    let s := N + 1 - T
    s = p + q ∧ s ^ 2 - 4 * N = (q - p) ^ 2 ∧
      (s - (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = p ∧
      (s + (Int.sqrt (s ^ 2 - 4 * N) : ℤ)) / 2 = q := by
  intro N T s
  have hs : s = p + q := by simp only [s, N, T]; ring
  obtain ⟨hd, h1, h2⟩ := recovery_from_sum hpq (rfl : N = p * q) hs
  exact ⟨hs, hd, h1, h2⟩

/-- The totient value of a semiprime, expressed through the barrier data. -/
theorem totient_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    Nat.totient (p * q) = (p - 1) * (q - 1) := by
  rw [Nat.totient_mul ((Nat.coprime_primes hp hq).2 hne), Nat.totient_prime hp,
    Nat.totient_prime hq]

/-! ### ZZZ: known-method-in-disguise (Fermat) -/

/-- **Fermat in disguise (ZZZ).**  For an odd integer `N`, producing a
nontrivial difference-of-squares representation `N = a² - b²` is *equivalent*
to producing a nontrivial factorization `N = p * q` with `1 < p ≤ q`.  Any
"new" method whose output is a difference of squares is therefore Fermat's
method in disguise. -/
theorem fermat_representation_iff {N : ℤ} (hodd : Odd N) :
    (∃ a b : ℤ, 0 ≤ b ∧ b + 1 < a ∧ N = a ^ 2 - b ^ 2) ↔
      (∃ p q : ℤ, 1 < p ∧ p ≤ q ∧ N = p * q) := by
  constructor
  · rintro ⟨a, b, hb, hba, rfl⟩
    exact ⟨a - b, a + b, by linarith, by linarith, by ring⟩
  · rintro ⟨p, q, hp, hpq, rfl⟩
    -- `N` odd forces both factors odd, so `p + q` and `q - p` are even.
    have hpodd : Odd p := by
      rcases Int.even_or_odd p with hev | h
      · exact absurd hodd (by
          simp [Int.not_odd_iff_even, (hev.mul_right q)])
      · exact h
    have hqodd : Odd q := by
      rcases Int.even_or_odd q with hev | h
      · exact absurd hodd (by
          simp [Int.not_odd_iff_even, (hev.mul_left p)])
      · exact h
    obtain ⟨m, hm⟩ := hpodd
    obtain ⟨n, hn⟩ := hqodd
    refine ⟨m + n + 1, n - m, by omega, by omega, ?_⟩
    rw [hm, hn]; ring

end FactoringLab