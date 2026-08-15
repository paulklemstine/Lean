import Mathlib
import Tropical.FreeWitnessClassification

/-!
# Barrier 4 made unconditional: free witnesses admit no formula in `N`

`Tropical.FreeWitnessClassification` proved the *positive* half of the free-witness
classification: for a strictly monotone CRT weight `w`, the semiprime aggregate
`A_w(pq) = (1 + w p)(1 + w q)` pins the factorisation.  What the programme calls
"sealing" (barrier 4) is the complementary, negative half: the aggregate is *not*
a function of `N` that one could evaluate cheaply.  Section 5 of the source paper
only conjectures this, on empirical mod-`2^k` evidence.

This file proves two unconditional forms of the sealing statement.

* **No polynomial formula** (`no_polynomial_of_prime_separation`).  If a CRT weight
  separates two primes and is "generically prime-visible" (`q ∤ 1 + w q` for
  arbitrarily large primes `q`), then *no* polynomial `P ∈ ℤ[X]` satisfies
  `P(pq) = A_w(pq)` for all semiprimes.  The mechanism is the trace/derivative
  identity `a - b ∣ P(a) - P(b)`: two semiprimes sharing the large prime `q` differ
  by a multiple of `q`, while their aggregates differ by `(w p₁ - w p₂)(1 + w q)`,
  which `q` cannot divide.  Corollaries: the divisor power sums `σ_k` (`k ≥ 1`,
  `sigma_pow_not_polynomial`) and the trace channel `p + q` itself
  (`trace_not_polynomial`).

* **No residue formula** (`no_residue_formula_of_inverse_pair`).  Sharper: for a
  suitable modulus `M`, `A_w(N) mod M` is not even a function of `N mod M`.  This is
  exactly the mod-`2^k` addendum of the paper, upgraded from experiment to theorem,
  using Dirichlet's theorem on primes in arithmetic progressions: two inverse residue
  classes `u, v = u⁻¹` produce semiprimes with the same `N mod M` but different
  aggregates.  Instances: `σ₁` mod `8` (`sigma_one_no_mod_eight_formula`), `σ₂` mod
  `128` (`sigma_two_no_mod_128_formula`), and — the general statement — for *every*
  `k ≥ 1` some prime modulus works (`sigma_pow_no_residue_formula`), proved with a
  primitive root.

Together with the dichotomy of the previous file this closes the classification
loop: a strictly monotone CRT weight is a free witness (recovery is `O(1)` from the
factors) and its aggregate is genuinely sealed (no polynomial, and not even a
residue-local, shortcut in `N`).
-/

namespace FreeWitnessBarriers

open Finset FreeWitness

/-! ## 1. The aggregate is not a polynomial in `N` -/

/-- **Sealing, polynomial form.**  Let `w` be a CRT weight separating the primes
`p₁ ≠ p₂` in the sense `w p₁ ≠ w p₂`, and suppose arbitrarily large primes `q`
satisfy `q ∤ 1 + w q` (true for every power weight).  Then no polynomial in `N`
computes the semiprime aggregate `∑_{d ∣ N} w d`. -/
theorem no_polynomial_of_prime_separation {w : ℕ → ℕ} (hw : IsCRTWeight w)
    {p₁ p₂ : ℕ} (hp₁ : p₁.Prime) (hp₂ : p₂.Prime) (hne : w p₁ ≠ w p₂)
    (hgen : ∀ M : ℕ, ∃ q : ℕ, q.Prime ∧ M < q ∧ ¬ ((q : ℤ) ∣ 1 + (w q : ℤ))) :
    ¬ ∃ P : Polynomial ℤ, ∀ x y : ℕ, x.Prime → y.Prime → x ≠ y →
        P.eval ((x * y : ℕ) : ℤ) = ((∑ d ∈ (x * y).divisors, w d : ℕ) : ℤ) := by
  rintro ⟨P, hP⟩
  obtain ⟨q, hq, hqbig, hqdvd⟩ := hgen (p₁ + p₂ + w p₁ + w p₂)
  have h₁q : p₁ ≠ q := by omega
  have h₂q : p₂ ≠ q := by omega
  have e₁ := hP p₁ q hp₁ hq h₁q
  have e₂ := hP p₂ q hp₂ hq h₂q
  rw [aggregate_semiprime hw p₁ q hp₁ hq h₁q] at e₁
  rw [aggregate_semiprime hw p₂ q hp₂ hq h₂q] at e₂
  -- the two semiprimes differ by a multiple of `q`
  have hdvd := Polynomial.sub_dvd_eval_sub ((p₁ * q : ℕ) : ℤ) ((p₂ * q : ℕ) : ℤ) P
  rw [e₁, e₂] at hdvd
  have hdvd' : ((p₁ : ℤ) - p₂) * q ∣ ((w p₁ : ℤ) - (w p₂ : ℤ)) * (1 + (w q : ℤ)) := by
    have hL : ((p₁ * q : ℕ) : ℤ) - ((p₂ * q : ℕ) : ℤ) = ((p₁ : ℤ) - p₂) * q := by
      push_cast; ring
    have hR : (((1 + w p₁) * (1 + w q) : ℕ) : ℤ) - (((1 + w p₂) * (1 + w q) : ℕ) : ℤ)
        = ((w p₁ : ℤ) - (w p₂ : ℤ)) * (1 + (w q : ℤ)) := by push_cast; ring
    rw [hL, hR] at hdvd
    exact hdvd
  have hqd : (q : ℤ) ∣ ((w p₁ : ℤ) - (w p₂ : ℤ)) * (1 + (w q : ℤ)) :=
    dvd_trans ⟨(p₁ : ℤ) - p₂, by ring⟩ hdvd'
  have hqp : Prime (q : ℤ) := Nat.prime_iff_prime_int.mp hq
  rcases hqp.dvd_mul.mp hqd with hcase | hcase
  · -- `q` divides a nonzero difference smaller than `q`
    have hnz : ((w p₁ : ℤ) - (w p₂ : ℤ)) ≠ 0 := by
      simp only [sub_ne_zero]
      exact_mod_cast hne
    have habs : ((w p₁ : ℤ) - (w p₂ : ℤ)).natAbs ≠ 0 := by
      simpa [Int.natAbs_eq_zero] using hnz
    have hdvdn : q ∣ ((w p₁ : ℤ) - (w p₂ : ℤ)).natAbs := by
      have := Int.natAbs_dvd_natAbs.mpr hcase
      simpa using this
    have hle := Nat.le_of_dvd (Nat.pos_of_ne_zero habs) hdvdn
    have hb : ((w p₁ : ℤ) - (w p₂ : ℤ)).natAbs ≤ w p₁ + w p₂ := by omega
    omega
  · exact hqdvd hcase

/-- Power weights are prime-visible: `q ∤ 1 + q ^ k` for every prime `q` and `k ≥ 1`. -/
theorem pow_weight_prime_visible {k : ℕ} (hk : 1 ≤ k) (M : ℕ) :
    ∃ q : ℕ, q.Prime ∧ M < q ∧ ¬ ((q : ℤ) ∣ 1 + ((q ^ k : ℕ) : ℤ)) := by
  obtain ⟨q, hqM, hq⟩ := Nat.exists_infinite_primes (M + 1)
  refine ⟨q, hq, by omega, ?_⟩
  intro hdvd
  have hqk : (q : ℤ) ∣ ((q ^ k : ℕ) : ℤ) := by
    have : (q : ℤ) ∣ (q : ℤ) ^ k := dvd_pow_self _ (by omega)
    simpa using this
  have : (q : ℤ) ∣ 1 := (dvd_add_right hqk).mp (by simpa [add_comm] using hdvd)
  have hq1 : (q : ℤ) ≤ 1 := Int.le_of_dvd one_pos this
  have := hq.two_le
  omega

/-- **The SIGK witness is sealed.**  For `k ≥ 1` the divisor power sum `σ_k` restricted
to semiprimes is not the evaluation of any integer polynomial in `N`. -/
theorem sigma_pow_not_polynomial {k : ℕ} (hk : 1 ≤ k) :
    ¬ ∃ P : Polynomial ℤ, ∀ x y : ℕ, x.Prime → y.Prime → x ≠ y →
        P.eval ((x * y : ℕ) : ℤ) = ((∑ d ∈ (x * y).divisors, d ^ k : ℕ) : ℤ) := by
  refine no_polynomial_of_prime_separation (isCRTWeight_pow k) Nat.prime_two Nat.prime_three
    ?_ (fun M => pow_weight_prime_visible hk M)
  have : (2 : ℕ) ^ k < 3 ^ k := Nat.pow_lt_pow_left (by norm_num) (by omega)
  exact Nat.ne_of_lt this

/-- **The trace channel is sealed.**  The trace `p + q` of a semiprime is not the
evaluation of any integer polynomial in `N = pq`: two semiprimes sharing the large
prime `q` have traces differing by the constant `p₁ - p₂`, which the modulus `q`
cannot divide. -/
theorem trace_not_polynomial :
    ¬ ∃ P : Polynomial ℤ, ∀ x y : ℕ, x.Prime → y.Prime → x ≠ y →
        P.eval ((x * y : ℕ) : ℤ) = ((x + y : ℕ) : ℤ) := by
  rintro ⟨P, hP⟩
  obtain ⟨q, hqbig, hq⟩ := Nat.exists_infinite_primes 6
  have h₂ : (2 : ℕ) ≠ q := by omega
  have h₃ : (3 : ℕ) ≠ q := by omega
  have e₁ := hP 2 q Nat.prime_two hq h₂
  have e₂ := hP 3 q Nat.prime_three hq h₃
  have hdvd := Polynomial.sub_dvd_eval_sub ((2 * q : ℕ) : ℤ) ((3 * q : ℕ) : ℤ) P
  rw [e₁, e₂] at hdvd
  have hL : ((2 * q : ℕ) : ℤ) - ((3 * q : ℕ) : ℤ) = -(q : ℤ) := by push_cast; ring
  have hR : ((2 + q : ℕ) : ℤ) - ((3 + q : ℕ) : ℤ) = -1 := by push_cast; ring
  rw [hL, hR] at hdvd
  have : (q : ℤ) ∣ 1 := by
    have h1 : (q : ℤ) ∣ (-1 : ℤ) := (neg_dvd).mp hdvd
    exact (dvd_neg).mp h1
  have hq1 : (q : ℤ) ≤ 1 := Int.le_of_dvd one_pos this
  omega

/-! ## 2. The aggregate is not even a function of `N mod M` -/

/-- The semiprime aggregate of a power weight, read in `ZMod M`. -/
theorem sigma_pow_cast {M : ℕ} (k : ℕ) {x y : ℕ} (hx : x.Prime) (hy : y.Prime) (hxy : x ≠ y) :
    ((∑ d ∈ (x * y).divisors, d ^ k : ℕ) : ZMod M)
      = (1 + (x : ZMod M) ^ k) * (1 + (y : ZMod M) ^ k) := by
  rw [aggregate_semiprime (isCRTWeight_pow k) x y hx hy hxy]
  push_cast
  ring

/-- **Sealing, residue form (the mod-`2^k` addendum, proved).**  Suppose the modulus
`M` carries a pair of inverse residues `u * v = 1` with
`(1 + u^k)(1 + v^k) ≠ 4`.  Then `σ_k(N) mod M` is *not* a function of `N mod M`:
Dirichlet's theorem supplies semiprimes `p₁q₁ ≡ p₂q₂ ≡ 1 (mod M)` whose aggregates
differ mod `M`.  Since every polynomial (indeed every formula depending only on the
residues of `N`) would give such a function, this is the sharp form of barrier 4. -/
theorem no_residue_formula_of_inverse_pair {M : ℕ} [NeZero M] (k : ℕ) {u v : ZMod M}
    (huv : u * v = 1) (hkey : (1 + u ^ k) * (1 + v ^ k) ≠ 4) :
    ¬ ∃ f : ZMod M → ZMod M, ∀ x y : ℕ, x.Prime → y.Prime → x ≠ y →
        ((∑ d ∈ (x * y).divisors, d ^ k : ℕ) : ZMod M) = f ((x * y : ℕ) : ZMod M) := by
  rintro ⟨f, hf⟩
  have hu : IsUnit u := IsUnit.of_mul_eq_one v huv
  have hv : IsUnit v := IsUnit.of_mul_eq_one u (by rw [mul_comm]; exact huv)
  have hone : IsUnit (1 : ZMod M) := isUnit_one
  -- primes in the residue classes `1`, `u`, `v`
  have S1 : {p : ℕ | p.Prime ∧ (p : ZMod M) = 1}.Infinite :=
    Nat.infinite_setOf_prime_and_eq_mod hone
  have Su : {p : ℕ | p.Prime ∧ (p : ZMod M) = u}.Infinite :=
    Nat.infinite_setOf_prime_and_eq_mod hu
  have Sv : {p : ℕ | p.Prime ∧ (p : ZMod M) = v}.Infinite :=
    Nat.infinite_setOf_prime_and_eq_mod hv
  obtain ⟨p₁, hp₁, -⟩ := S1.exists_gt 0
  obtain ⟨q₁, hq₁, hq₁gt⟩ := S1.exists_gt p₁
  obtain ⟨p₂, hp₂, -⟩ := Su.exists_gt 0
  obtain ⟨q₂, hq₂, hq₂gt⟩ := Sv.exists_gt p₂
  obtain ⟨hp₁p, hp₁v⟩ := hp₁
  obtain ⟨hq₁p, hq₁v⟩ := hq₁
  obtain ⟨hp₂p, hp₂v⟩ := hp₂
  obtain ⟨hq₂p, hq₂v⟩ := hq₂
  have hne₁ : p₁ ≠ q₁ := by omega
  have hne₂ : p₂ ≠ q₂ := by omega
  have hN₁ : ((p₁ * q₁ : ℕ) : ZMod M) = 1 := by push_cast [hp₁v, hq₁v]; ring
  have hN₂ : ((p₂ * q₂ : ℕ) : ZMod M) = 1 := by push_cast [hp₂v, hq₂v]; exact huv
  have e₁ := hf p₁ q₁ hp₁p hq₁p hne₁
  have e₂ := hf p₂ q₂ hp₂p hq₂p hne₂
  rw [sigma_pow_cast k hp₁p hq₁p hne₁, hp₁v, hq₁v, hN₁] at e₁
  rw [sigma_pow_cast k hp₂p hq₂p hne₂, hp₂v, hq₂v, hN₂] at e₂
  apply hkey
  rw [e₂.trans e₁.symm]
  norm_num

/-- `σ₁` mod `8`: the class `3 · 3 = 1` witnesses the failure, since
`(1 + 3)(1 + 3) = 0 ≠ 4` in `ZMod 8`.  Concretely, `33 = 3·11` and `697 = 17·41` are
both `≡ 1 (mod 8)` while `σ₁(33) = 48` and `σ₁(697) = 756` differ mod `8`. -/
theorem sigma_one_no_mod_eight_formula :
    ¬ ∃ f : ZMod 8 → ZMod 8, ∀ x y : ℕ, x.Prime → y.Prime → x ≠ y →
        ((∑ d ∈ (x * y).divisors, d ^ 1 : ℕ) : ZMod 8) = f ((x * y : ℕ) : ZMod 8) :=
  no_residue_formula_of_inverse_pair (M := 8) 1 (u := 3) (v := 3) (by decide) (by decide)

/-- `σ₂` mod `128`: here `3 · 43 = 1` and `(1 + 3²)(1 + 43²) ≠ 4` in `ZMod 128`.
(Smaller powers of two fail: for `k = 2` every inverse pair gives exactly `4` modulo
`2^m` with `m ≤ 5`, which is why the empirical addendum needed a large window.) -/
theorem sigma_two_no_mod_128_formula :
    ¬ ∃ f : ZMod 128 → ZMod 128, ∀ x y : ℕ, x.Prime → y.Prime → x ≠ y →
        ((∑ d ∈ (x * y).divisors, d ^ 2 : ℕ) : ZMod 128) = f ((x * y : ℕ) : ZMod 128) :=
  no_residue_formula_of_inverse_pair (M := 128) 2 (u := 3) (v := 43) (by decide) (by decide)

/-- **The general sealing theorem.**  For *every* exponent `k ≥ 1` there is a modulus
`M` (indeed a prime one) for which `σ_k(N) mod M` is not a function of `N mod M`.
The modulus is any prime `P > k + 1`: a primitive root `g` of `ZMod P` has
`g ^ k ≠ 1`, and in a field `t ≠ 1` implies `(t - 1)^2 ≠ 0`, i.e.
`(1 + t)(1 + t⁻¹) ≠ 4`. -/
theorem sigma_pow_no_residue_formula {k : ℕ} (hk : 1 ≤ k) :
    ∃ M : ℕ, 1 < M ∧ ¬ ∃ f : ZMod M → ZMod M, ∀ x y : ℕ, x.Prime → y.Prime → x ≠ y →
        ((∑ d ∈ (x * y).divisors, d ^ k : ℕ) : ZMod M) = f ((x * y : ℕ) : ZMod M) := by
  obtain ⟨P, hPk, hP⟩ := Nat.exists_infinite_primes (k + 2)
  haveI : Fact P.Prime := ⟨hP⟩
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := (ZMod P)ˣ)
  have hord : orderOf g = P - 1 := by
    rw [orderOf_eq_card_of_forall_mem_zpowers hg, Nat.card_eq_fintype_card,
      ZMod.card_units_eq_totient, Nat.totient_prime hP]
  have hgk : g ^ k ≠ 1 := by
    intro hcon
    have hdvd : orderOf g ∣ k := orderOf_dvd_of_pow_eq_one hcon
    rw [hord] at hdvd
    have hle := Nat.le_of_dvd (by omega) hdvd
    omega
  set u : ZMod P := (g : ZMod P) with hu
  set v : ZMod P := ((g⁻¹ : (ZMod P)ˣ) : ZMod P) with hv
  have huv : u * v = 1 := by
    rw [hu, hv, ← Units.val_mul, mul_inv_cancel, Units.val_one]
  have hab : u ^ k * v ^ k = 1 := by rw [← mul_pow, huv, one_pow]
  have hune : u ^ k ≠ 1 := by
    intro hcon
    apply hgk
    refine Units.ext ?_
    rw [Units.val_pow_eq_pow_val, Units.val_one, ← hu]
    exact hcon
  have hkey : (1 + u ^ k) * (1 + v ^ k) ≠ 4 := by
    intro hcon
    have hsq : (u ^ k - 1) ^ 2 = 0 := by
      linear_combination (u ^ k) * hcon - (u ^ k + 1) * hab
    have h0 : u ^ k - 1 = 0 := by
      have := pow_eq_zero_iff (M₀ := ZMod P) (n := 2) (by norm_num) |>.mp hsq
      exact this
    exact hune (by linear_combination h0)
  exact ⟨P, by have := hP.two_le; omega, no_residue_formula_of_inverse_pair k huv hkey⟩

end FreeWitnessBarriers