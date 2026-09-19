import Cryptography.ThreeStrataPlane.StratumA

/-!
# Stratum C: the quantum corner, and the classical reduction that it rests on

Shor's algorithm is quantum only in one place: finding the multiplicative order
`r` of a unit modulo `N`.  Everything else — the step that turns `r` into a
factor — is classical, unconditional, and provable here.

* `order_halving_splits` : if `x² ≡ 1 (mod N)` but `x ≢ ±1 (mod N)` for a
  semiprime `N = pq`, then `gcd(x - 1, N)` is *exactly* one of the two prime
  factors.  This is the split step.
* `shor_reduction` : the same statement in the form the algorithm uses, with
  `x = a^{r/2}` for an even order `r`.
* `shor_split_nontrivial` : the output is a genuine nontrivial factorization.

Combined with `Plane.shorProfile_exponent` (exponent `0`) and
`Plane.quantum_below_classical`, this says precisely what the quantum corner of
the plane owns: the *search* for `r`, not the arithmetic that follows it.
-/

namespace ThreeStrata

/-- **The split step of Shor's algorithm.**  A nontrivial square root of `1`
modulo a semiprime splits it, and the split is exact: the gcd is one of the two
prime factors, never `1` and never `N`. -/
theorem order_halving_splits {p q : ℕ} {x : ℤ} (hp : p.Prime) (hq : q.Prime)
    (hsq : ((p * q : ℕ) : ℤ) ∣ x ^ 2 - 1)
    (h1 : ¬ ((p * q : ℕ) : ℤ) ∣ x - 1) (h2 : ¬ ((p * q : ℕ) : ℤ) ∣ x + 1) :
    Int.gcd (x - 1) ((p * q : ℕ) : ℤ) = p ∨ Int.gcd (x - 1) ((p * q : ℕ) : ℤ) = q := by
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  have hp1 : 1 < p := hp.one_lt
  have hgN : Int.gcd (x - 1) ((p * q : ℕ) : ℤ) ∣ p * q := by
    have h := Int.gcd_dvd_right (x - 1) ((p * q : ℕ) : ℤ)
    exact_mod_cast h
  have hmem : Int.gcd (x - 1) ((p * q : ℕ) : ℤ) ∈ (p * q).divisors :=
    Nat.mem_divisors.2 ⟨hgN, by positivity⟩
  rw [divisors_semiprime hp hq] at hmem
  simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
  rcases hmem with h | h | h | h
  · -- coprime case: then `N ∣ x + 1`, contradiction
    exfalso
    have hcop : IsCoprime ((p * q : ℕ) : ℤ) (x - 1) := by
      rw [Int.isCoprime_iff_gcd_eq_one, Int.gcd_comm]
      exact h
    have hfac : ((p * q : ℕ) : ℤ) ∣ (x + 1) * (x - 1) := by
      have : (x + 1) * (x - 1) = x ^ 2 - 1 := by ring
      rw [this]; exact hsq
    exact h2 (hcop.dvd_of_dvd_mul_right hfac)
  · exact Or.inl h
  · exact Or.inr h
  · exfalso
    have hdl := Int.gcd_dvd_left (x - 1) ((p * q : ℕ) : ℤ)
    rw [h] at hdl
    exact h1 hdl

/-- **Shor's reduction, classical part.**  If `a` has even order `2m` modulo the
semiprime `N = pq` and `a^m` is not `±1`, then one gcd returns a prime factor. -/
theorem shor_reduction {p q m : ℕ} {a : ℤ} (hp : p.Prime) (hq : q.Prime)
    (horder : ((p * q : ℕ) : ℤ) ∣ a ^ (2 * m) - 1)
    (h1 : ¬ ((p * q : ℕ) : ℤ) ∣ a ^ m - 1) (h2 : ¬ ((p * q : ℕ) : ℤ) ∣ a ^ m + 1) :
    Int.gcd (a ^ m - 1) ((p * q : ℕ) : ℤ) = p ∨
      Int.gcd (a ^ m - 1) ((p * q : ℕ) : ℤ) = q := by
  refine order_halving_splits hp hq ?_ h1 h2
  have : (a ^ m) ^ 2 - 1 = a ^ (2 * m) - 1 := by
    rw [← pow_mul, mul_comm]
  rw [this]
  exact horder

/-- The factor produced by the split is nontrivial: strictly between `1` and `N`,
and it divides `N`. -/
theorem shor_split_nontrivial {p q : ℕ} {x : ℤ} (hp : p.Prime) (hq : q.Prime)
    (hsq : ((p * q : ℕ) : ℤ) ∣ x ^ 2 - 1)
    (h1 : ¬ ((p * q : ℕ) : ℤ) ∣ x - 1) (h2 : ¬ ((p * q : ℕ) : ℤ) ∣ x + 1) :
    1 < Int.gcd (x - 1) ((p * q : ℕ) : ℤ) ∧
      Int.gcd (x - 1) ((p * q : ℕ) : ℤ) < p * q ∧
      Int.gcd (x - 1) ((p * q : ℕ) : ℤ) ∣ p * q := by
  have hp1 : 1 < p := hp.one_lt
  have hq1 : 1 < q := hq.one_lt
  have hgN : Int.gcd (x - 1) ((p * q : ℕ) : ℤ) ∣ p * q := by
    have h := Int.gcd_dvd_right (x - 1) ((p * q : ℕ) : ℤ)
    exact_mod_cast h
  rcases order_halving_splits hp hq hsq h1 h2 with h | h
  · refine ⟨by omega, ?_, hgN⟩
    rw [h]; nlinarith
  · refine ⟨by omega, ?_, hgN⟩
    rw [h]; nlinarith

end ThreeStrata