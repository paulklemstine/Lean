import Mathlib
import Physics.DerivedModulusNoGo

/-!
# The hint-amplification frontier

The MULTIMOD verdict is that a *second, internally derived* modulus is useless.
The residual hope identified in the experiment is an **external hint** that
shares a prime with `N`.  This file makes that dichotomy precise and quantifies
the frontier.

## Main results

* `Physics.DerivedModulus.gcd_semiprime_cases` : for a semiprime `N = p·q` with
  distinct primes, the gcd attack against any hint `h` returns one of the four
  values `1, p, q, N`; only the middle two are useful.
* `Physics.DerivedModulus.gcd_eq_left_iff` : the gcd attack returns `p`
  *exactly* when the hint is divisible by `p` and not by `q` — the hint must
  share a prime with `N`, nothing else works.
* `Physics.DerivedModulus.useful_hint_count` : among the `N` residues, exactly
  `p + q - 1` hints are useful.  Together with
  `Physics.DerivedModulus.useful_hint_density` this says a *random* hint works
  with probability at most `2/B` when both factors exceed `B`: the frontier
  needs structure, not luck.
* `Physics.DerivedModulus.derived_hints_useless` : every MULTIMOD derived
  modulus lands in the useless case `gcd = 1`, for every semiprime.
-/

namespace Physics.DerivedModulus

/-- Divisors of a product of two primes. -/
theorem dvd_semiprime_cases {p q d : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h : d ∣ p * q) : d = 1 ∨ d = p ∨ d = q ∨ d = p * q := by
  obtain ⟨a, b, ha, hb, rfl⟩ := (Nat.dvd_mul).mp h
  rcases hp.eq_one_or_self_of_dvd a ha with rfl | rfl <;>
    rcases hq.eq_one_or_self_of_dvd b hb with rfl | rfl <;> simp

/-- **The gcd attack has only four possible outcomes** on a semiprime. -/
theorem gcd_semiprime_cases {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (h : ℕ) :
    Nat.gcd (p * q) h = 1 ∨ Nat.gcd (p * q) h = p ∨ Nat.gcd (p * q) h = q ∨
      Nat.gcd (p * q) h = p * q :=
  dvd_semiprime_cases hp hq (Nat.gcd_dvd_left _ _)

/-- **Exact criterion for a useful hint.**  The gcd attack recovers the factor
`p` from the hint `h` if and only if `h` shares the prime `p` with `N` and
misses the prime `q`. -/
theorem gcd_eq_left_iff {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (h : ℕ) : Nat.gcd (p * q) h = p ↔ (p ∣ h ∧ ¬ q ∣ h) := by
  constructor
  · intro hg
    refine ⟨hg ▸ Nat.gcd_dvd_right (p * q) h, ?_⟩
    intro hqh
    have hpq' : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
    have hdd : p * q ∣ Nat.gcd (p * q) h :=
      Nat.dvd_gcd dvd_rfl (Nat.Coprime.mul_dvd_of_dvd_of_dvd hpq'
        (hg ▸ Nat.gcd_dvd_right (p * q) h) hqh)
    rw [hg] at hdd
    have hle : p * q ≤ p := Nat.le_of_dvd hp.pos hdd
    have h2 := hp.two_le
    have h3 := hq.two_le
    nlinarith
  · rintro ⟨hph, hqh⟩
    have hdvd : p ∣ Nat.gcd (p * q) h := Nat.dvd_gcd (Dvd.intro q rfl) hph
    rcases gcd_semiprime_cases hp hq h with hg | hg | hg | hg
    · rw [hg] at hdvd; exact absurd (Nat.dvd_one.mp hdvd) hp.one_lt.ne'
    · exact hg
    · exfalso; exact hqh (hg ▸ Nat.gcd_dvd_right (p * q) h)
    · exfalso
      have hpqh : (p * q) ∣ h := hg ▸ Nat.gcd_dvd_right (p * q) h
      exact hqh (dvd_trans (Dvd.intro_left p rfl) hpqh)

/-- If the gcd attack returns a proper nontrivial divisor, the factorisation is
complete: the cofactor is the other prime. -/
theorem factor_from_useful_hint {p q h : ℕ} (hp : p.Prime)
    (hg : Nat.gcd (p * q) h = p) : (p * q) / Nat.gcd (p * q) h = q := by
  rw [hg]
  exact Nat.mul_div_cancel_left q hp.pos

/-- **Counting the useful hints.**  Exactly `p + q - 1` of the `p·q` residues
share a prime with `N = p·q`; all other hints leave the gcd attack at `1`. -/
theorem useful_hint_count {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    ((Finset.range (p * q)).filter (fun h => Nat.gcd (p * q) h ≠ 1)).card
      = p + q - 1 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 2 := ⟨p - 2, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 2 := ⟨q - 2, by omega⟩
  have hcop : Nat.Coprime (a + 2) (b + 2) := (Nat.coprime_primes hp hq).mpr hpq
  have htot : Nat.totient ((a + 2) * (b + 2)) = (a + 1) * (b + 1) := by
    rw [Nat.totient_mul hcop, Nat.totient_prime hp, Nat.totient_prime hq]
    simp
  have htot' : ((Finset.range ((a + 2) * (b + 2))).filter
      (fun h => Nat.gcd ((a + 2) * (b + 2)) h = 1)).card
        = Nat.totient ((a + 2) * (b + 2)) := by
    rw [Nat.totient]
  have hsplit :
      ((Finset.range ((a + 2) * (b + 2))).filter
          (fun h => Nat.gcd ((a + 2) * (b + 2)) h = 1)).card
        + ((Finset.range ((a + 2) * (b + 2))).filter
          (fun h => ¬ Nat.gcd ((a + 2) * (b + 2)) h = 1)).card
        = (Finset.range ((a + 2) * (b + 2))).card :=
    Finset.card_filter_add_card_filter_not (s := Finset.range ((a + 2) * (b + 2)))
      (fun h => Nat.gcd ((a + 2) * (b + 2)) h = 1)
  rw [htot', htot, Finset.card_range] at hsplit
  have key : (a + 1) * (b + 1) + (a + b + 3) = (a + 2) * (b + 2) := by ring
  have hfin := Nat.add_left_cancel (hsplit.trans key.symm)
  simp only [ne_eq]
  omega

/-- **Density of the frontier.**  If both prime factors exceed `B`, the fraction
of useful hints is at most `2/B`: an unstructured external hint is useless with
overwhelming probability. -/
theorem useful_hint_density {p q B : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hB : 0 < B) (hBp : B ≤ p) (hBq : B ≤ q) :
    (((Finset.range (p * q)).filter (fun h => Nat.gcd (p * q) h ≠ 1)).card) * B
      ≤ 2 * (p * q) := by
  rw [useful_hint_count hp hq hpq]
  have h1 : p * B ≤ p * q := Nat.mul_le_mul_left p hBq
  have h2 : q * B ≤ q * p := Nat.mul_le_mul_left q hBp
  have : (p + q - 1) * B ≤ (p + q) * B := Nat.mul_le_mul_right B (by omega)
  nlinarith [this, h1, h2]

/-! ## Derived moduli are always on the useless side -/

/-- Bridge between the integer gcd used for polynomial moduli and the natural
gcd used for the hint analysis. -/
theorem intGcd_eq_natGcd (N : ℕ) (M : ℤ) : Int.gcd (N : ℤ) M = Nat.gcd N M.natAbs := by
  simp [Int.gcd]

/-- **Closing the corner.**  For every semiprime `N = p·q` and every derived
modulus of the MULTIMOD family, the gcd attack returns `1`: derived hints are
never on the useful side of the frontier. -/
theorem derived_hints_useless (p q : ℕ) (i : Fin 6) :
    Nat.gcd (p * q) (family i ((p * q : ℕ) : ℤ)).natAbs = 1 := by
  have := family_coprime i ((p * q : ℕ) : ℤ)
  rwa [intGcd_eq_natGcd] at this

/-- Consequently no derived modulus can ever produce the factor `p`, whereas an
external hint does so precisely under the sharing condition of
`gcd_eq_left_iff`.  This is the exact statement of the frontier: derived data
sits strictly inside the trivial class. -/
theorem frontier_dichotomy {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (i : Fin 6) :
    Nat.gcd (p * q) (family i ((p * q : ℕ) : ℤ)).natAbs ≠ p ∧
    ∀ h : ℕ, Nat.gcd (p * q) h = p ↔ (p ∣ h ∧ ¬ q ∣ h) := by
  refine ⟨?_, gcd_eq_left_iff hp hq hpq⟩
  rw [derived_hints_useless p q i]
  exact fun hcon => hp.one_lt.ne' hcon.symm

end Physics.DerivedModulus