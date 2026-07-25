import Mathlib

namespace CounterfactualPrimeFactorization

/-- The Hilbert multiplicative universe consists of naturals congruent to `1` modulo `4`. -/
def InHilbertMonoid (n : ℕ) : Prop := n % 4 = 1

instance : DecidablePred InHilbertMonoid := fun n => by
  unfold InHilbertMonoid
  infer_instance

/-- A Hilbert prime is a nonunit that has no nontrivial factorization within the
Hilbert multiplicative universe. -/
def HilbertPrime (n : ℕ) : Prop :=
  2 ≤ n ∧ InHilbertMonoid n ∧
    ∀ a b : ℕ, InHilbertMonoid a → InHilbertMonoid b → a * b = n → a = 1 ∨ b = 1

/-- The Hilbert universe is closed under multiplication. -/
theorem hilbertMonoid_mul {a b : ℕ}
    (ha : InHilbertMonoid a) (hb : InHilbertMonoid b) :
    InHilbertMonoid (a * b) := by
  unfold InHilbertMonoid at *
  simp [Nat.mul_mod, ha, hb]

/-- The composite integer `9` is prime in the Hilbert universe. -/
theorem hilbertPrime_nine : HilbertPrime 9 := by
  refine ⟨by norm_num, rfl, ?_⟩
  intro a b ha hb hab
  unfold InHilbertMonoid at ha hb
  have hle : a ≤ 9 := Nat.le_of_dvd (by norm_num) ⟨b, hab.symm⟩
  interval_cases a <;> omega

/-- The composite integer `21` is prime in the Hilbert universe. -/
theorem hilbertPrime_twentyOne : HilbertPrime 21 := by
  refine ⟨by norm_num, rfl, ?_⟩
  intro a b ha hb hab
  unfold InHilbertMonoid at ha hb
  have hle : a ≤ 21 := Nat.le_of_dvd (by norm_num) ⟨b, hab.symm⟩
  interval_cases a <;> omega

/-- The composite integer `49` is prime in the Hilbert universe. -/
theorem hilbertPrime_fortyNine : HilbertPrime 49 := by
  refine ⟨by norm_num, rfl, ?_⟩
  intro a b ha hb hab
  unfold InHilbertMonoid at ha hb
  have hle : a ≤ 49 := Nat.le_of_dvd (by norm_num) ⟨b, hab.symm⟩
  interval_cases a <;> omega

/-- Unique factorization fails after replacing ordinary primes by Hilbert primes:
`441 = 9 * 49 = 21 * 21`, and the two multisets of prime factors differ. -/
theorem unique_factorization_collapses :
    HilbertPrime 9 ∧ HilbertPrime 21 ∧ HilbertPrime 49 ∧
      9 * 49 = 441 ∧ 21 * 21 = 441 ∧
      ({9, 49} : Multiset ℕ) ≠ ({21, 21} : Multiset ℕ) := by
  exact ⟨hilbertPrime_nine, hilbertPrime_twentyOne, hilbertPrime_fortyNine,
    by norm_num, by norm_num, by decide⟩

/-- Every ordinary prime congruent to `1` modulo `4` remains prime in the
Hilbert universe. -/
theorem hilbertPrime_of_prime_mod_four {p : ℕ}
    (hp : p.Prime) (hmod : p % 4 = 1) : HilbertPrime p := by
  refine ⟨hp.two_le, hmod, ?_⟩
  intro a b _ _ hab
  have hdvd : a ∣ p := ⟨b, hab.symm⟩
  rcases hp.eq_one_or_self_of_dvd a hdvd with h1 | hself
  · exact Or.inl h1
  · right
    subst hself
    nlinarith [hab, hp.pos]

/-- There are infinitely many Hilbert primes. -/
theorem infinitely_many_hilbertPrimes :
    {n : ℕ | HilbertPrime n}.Infinite := by
  have h := Nat.frequently_atTop_modEq_one (k := 4) (by norm_num)
  rw [Nat.frequently_atTop_iff_infinite] at h
  apply h.mono
  intro p hp
  simp only [Set.mem_setOf_eq] at hp ⊢
  exact hilbertPrime_of_prime_mod_four hp.1 (by
    have hm := hp.2
    unfold Nat.ModEq at hm
    omega)

end CounterfactualPrimeFactorization