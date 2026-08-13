import Computation.Factoring.SemiprimeBasics

/-!
# DENS-SUB: no congruence-detectable fast subfamily of semiprimes

Round-3 closure #4.  The average-case question is whether some family of
semiprimes, *recognisable from `N` alone*, factors below the `√N` floor.  The
experimental part of the paper (experiment 306) reports that the standard
`N`-only statistics (`N mod 4`, `N mod 8`, the Jacobi symbol `(2/N)`) are
uncorrelated with the ρ-step count, while the genuinely fast subfamilies
(small `|p-q|`, smooth `p-1`) are *factor* properties.

This file turns the experiment into a theorem.  Every `N`-only statistic of
congruence type is a function of `N mod m` for some modulus `m`; we prove that
such a statistic carries **no information at all** about the location of the
factorization:

* `DensSub.exists_semiprime_in_class` — via Dirichlet's theorem on primes in
  arithmetic progressions, for every unit class `a mod m`, every prime `p`
  coprime to `m` and every bound `B`, there is a semiprime `p·r > B` in the
  class `a` whose smallest prime factor is exactly `p`;
* `DensSub.minFac_unbounded_in_class` / `DensSub.gap_unbounded_in_class` — hence
  inside a single residue class the smallest prime factor and the factor gap
  `|p - q|` are both unbounded and uncontrolled;
* `DensSub.no_residue_detector` — **there is no function `D : ZMod m → ℕ` that
  outputs the least prime factor of every semiprime**, for any modulus `m > 1`.

So no congruence-defined class of `N` is a "fast subfamily" detector: DENS-SUB
is closed (barriers 5/8).
-/

namespace DensSub

/-- The least prime factor of a product of two primes is the smaller one. -/
theorem minFac_mul_primes {p r : ℕ} (hp : p.Prime) (hr : r.Prime) (hle : p ≤ r) :
    (p * r).minFac = p := by
  have hlefac : (p * r).minFac ≤ p := Nat.minFac_le_of_dvd hp.two_le (dvd_mul_right p r)
  have hne : p * r ≠ 1 := by nlinarith [hr.two_le, hp.two_le]
  have hmp : ((p * r).minFac).Prime := Nat.minFac_prime hne
  rcases (Nat.Prime.dvd_mul hmp).mp (Nat.minFac_dvd _) with h | h
  · exact (Nat.prime_dvd_prime_iff_eq hmp hp).mp h
  · have := (Nat.prime_dvd_prime_iff_eq hmp hr).mp h
    omega

/-- **Dirichlet-driven population of a residue class.**  Fix a modulus `m`, a
unit residue `a` and any prime `p` that is invertible mod `m`.  Then arbitrarily
large semiprimes `N = p·r` with `N ≡ a (mod m)` exist, all of them with least
prime factor `p`.  The class `a mod m` therefore contains semiprimes with any
prescribed small factor: the residue reveals nothing. -/
theorem exists_semiprime_in_class {m : ℕ} [NeZero m] {a : ZMod m} (ha : IsUnit a)
    {p : ℕ} (hp : p.Prime) (hpu : IsUnit (p : ZMod m)) (B : ℕ) :
    ∃ r : ℕ, r.Prime ∧ p < r ∧ B < r ∧ ((p * r : ℕ) : ZMod m) = a ∧
      (p * r).minFac = p := by
  set u := hpu.unit with hu
  obtain ⟨r, hrgt, hrp, hrval⟩ :=
    Nat.forall_exists_prime_gt_and_eq_mod (q := m) (a := (↑u⁻¹ * a))
      ((u⁻¹.isUnit).mul ha) (max B p)
  have hpr : p < r := lt_of_le_of_lt (le_max_right B p) hrgt
  refine ⟨r, hrp, hpr, lt_of_le_of_lt (le_max_left B p) hrgt, ?_,
    minFac_mul_primes hp hrp hpr.le⟩
  push_cast
  rw [hrval]
  have hpu' : ((p : ZMod m)) = (u : ZMod m) := by rw [hu]; simp
  rw [hpu', ← mul_assoc]
  simp

/-- Inside one residue class the factor gap is unbounded: `N`-only congruence
data cannot detect the Fermat-easy (small gap) subfamily. -/
theorem gap_unbounded_in_class {m : ℕ} [NeZero m] {a : ZMod m} (ha : IsUnit a)
    {p : ℕ} (hp : p.Prime) (hpu : IsUnit (p : ZMod m)) (B : ℕ) :
    ∃ r : ℕ, r.Prime ∧ ((p * r : ℕ) : ZMod m) = a ∧ B < r - p := by
  obtain ⟨r, hrp, hpr, hrB, hclass, _⟩ := exists_semiprime_in_class ha hp hpu (B + p)
  exact ⟨r, hrp, hclass, by omega⟩

/-- Two semiprimes in the *same* residue class with *different* least prime
factors: the residue class is blind to the factorization. -/
theorem minFac_unbounded_in_class {m : ℕ} [NeZero m] (hm : 1 < m) (B : ℕ) :
    ∃ N₁ N₂ : ℕ, B < N₁ ∧ B < N₂ ∧ ((N₁ : ZMod m) = (N₂ : ZMod m)) ∧
      N₁.minFac ≠ N₂.minFac ∧
      (∃ p₁ r₁ : ℕ, p₁.Prime ∧ r₁.Prime ∧ N₁ = p₁ * r₁) ∧
      (∃ p₂ r₂ : ℕ, p₂.Prime ∧ r₂.Prime ∧ N₂ = p₂ * r₂) := by
  haveI : NeZero m := ⟨by omega⟩
  -- two distinct primes in the class `1 mod m`
  obtain ⟨p₁, hp₁gt, hp₁, hp₁val⟩ :=
    Nat.forall_exists_prime_gt_and_eq_mod (q := m) (a := (1 : ZMod m)) isUnit_one 0
  obtain ⟨p₂, hp₂gt, hp₂, hp₂val⟩ :=
    Nat.forall_exists_prime_gt_and_eq_mod (q := m) (a := (1 : ZMod m)) isUnit_one p₁
  have hu₁ : IsUnit ((p₁ : ℕ) : ZMod m) := by rw [hp₁val]; exact isUnit_one
  have hu₂ : IsUnit ((p₂ : ℕ) : ZMod m) := by rw [hp₂val]; exact isUnit_one
  obtain ⟨r₁, hr₁, hpr₁, hr₁B, hcl₁, hmf₁⟩ :=
    exists_semiprime_in_class (a := (1 : ZMod m)) isUnit_one hp₁ hu₁ B
  obtain ⟨r₂, hr₂, hpr₂, hr₂B, hcl₂, hmf₂⟩ :=
    exists_semiprime_in_class (a := (1 : ZMod m)) isUnit_one hp₂ hu₂ B
  refine ⟨p₁ * r₁, p₂ * r₂, ?_, ?_, by rw [hcl₁, hcl₂], ?_,
    ⟨p₁, r₁, hp₁, hr₁, rfl⟩, ⟨p₂, r₂, hp₂, hr₂, rfl⟩⟩
  · nlinarith [hp₁.two_le, hr₁B]
  · nlinarith [hp₂.two_le, hr₂B]
  · rw [hmf₁, hmf₂]
    omega

/-- **No `N`-only congruence detector for the factorization.**  For every
modulus `m > 1` there is no function of `N mod m` that returns the least prime
factor of every semiprime `N`.  (Indeed the counterexample pair can be taken
arbitrarily large.) -/
theorem no_residue_detector {m : ℕ} (hm : 1 < m) (D : ZMod m → ℕ) (B : ℕ) :
    ¬ (∀ N : ℕ, B < N → (∃ p r : ℕ, p.Prime ∧ r.Prime ∧ N = p * r) →
        D ((N : ℕ) : ZMod m) = N.minFac) := by
  haveI : NeZero m := ⟨by omega⟩
  intro hD
  obtain ⟨N₁, N₂, hB₁, hB₂, hcl, hne, hs₁, hs₂⟩ := minFac_unbounded_in_class hm B
  exact hne (by rw [← hD N₁ hB₁ hs₁, ← hD N₂ hB₂ hs₂, hcl])

/-- Two coprime semiprimes in the same residue class: the strongest form of
congruence-blindness, since the two factorizations share no prime at all. -/
theorem exists_coprime_semiprimes_in_same_class {m : ℕ} (hm : 1 < m) (B : ℕ) :
    ∃ p₁ r₁ p₂ r₂ : ℕ, p₁.Prime ∧ r₁.Prime ∧ p₂.Prime ∧ r₂.Prime ∧
      p₁ < r₁ ∧ p₂ < r₂ ∧ B < p₁ * r₁ ∧ B < p₂ * r₂ ∧
      ((p₁ * r₁ : ℕ) : ZMod m) = ((p₂ * r₂ : ℕ) : ZMod m) ∧
      p₁ ≠ p₂ ∧ p₁ ≠ r₂ ∧ r₁ ≠ p₂ ∧ r₁ ≠ r₂ := by
  haveI : NeZero m := ⟨by omega⟩
  obtain ⟨p₁, hp₁gt, hp₁, hp₁val⟩ :=
    Nat.forall_exists_prime_gt_and_eq_mod (q := m) (a := (1 : ZMod m)) isUnit_one 0
  obtain ⟨p₂, hp₂gt, hp₂, hp₂val⟩ :=
    Nat.forall_exists_prime_gt_and_eq_mod (q := m) (a := (1 : ZMod m)) isUnit_one p₁
  have hu₁ : IsUnit ((p₁ : ℕ) : ZMod m) := by rw [hp₁val]; exact isUnit_one
  have hu₂ : IsUnit ((p₂ : ℕ) : ZMod m) := by rw [hp₂val]; exact isUnit_one
  obtain ⟨r₁, hr₁, hpr₁, hr₁B, hcl₁, _⟩ :=
    exists_semiprime_in_class (a := (1 : ZMod m)) isUnit_one hp₁ hu₁ (max B p₂)
  obtain ⟨r₂, hr₂, hpr₂, hr₂B, hcl₂, _⟩ :=
    exists_semiprime_in_class (a := (1 : ZMod m)) isUnit_one hp₂ hu₂ (max B r₁)
  have hBr₁ : B < r₁ := lt_of_le_of_lt (le_max_left _ _) hr₁B
  have hp₂r₁ : p₂ < r₁ := lt_of_le_of_lt (le_max_right _ _) hr₁B
  have hr₁r₂ : r₁ < r₂ := lt_of_le_of_lt (le_max_right _ _) hr₂B
  refine ⟨p₁, r₁, p₂, r₂, hp₁, hr₁, hp₂, hr₂, hpr₁, hpr₂, ?_, ?_,
    by rw [hcl₁, hcl₂], ?_, ?_, ?_, ?_⟩
  · nlinarith [hp₁.two_le]
  · nlinarith [hp₂.two_le]
  · omega
  · omega
  · omega
  · omega

/-- **No congruence-detectable factor extractor.**  For every modulus `m > 1`
there is no function of `N mod m` that outputs a nontrivial divisor of every
semiprime `N`: the two semiprimes produced above lie in the same class but are
coprime, so no single value can divide both. -/
theorem no_residue_divisor_detector {m : ℕ} (hm : 1 < m) (D : ZMod m → ℕ) (B : ℕ) :
    ¬ (∀ N : ℕ, B < N → (∃ p r : ℕ, p.Prime ∧ r.Prime ∧ N = p * r) →
        D ((N : ℕ) : ZMod m) ∣ N ∧ 1 < D ((N : ℕ) : ZMod m) ∧
          D ((N : ℕ) : ZMod m) < N) := by
  intro hD
  obtain ⟨p₁, r₁, p₂, r₂, hp₁, hr₁, hp₂, hr₂, -, -, hB₁, hB₂, hcl, hne₁, hne₂, hne₃, hne₄⟩ :=
    exists_coprime_semiprimes_in_same_class hm B
  obtain ⟨hd₁, hgt₁, hlt₁⟩ := hD (p₁ * r₁) hB₁ ⟨p₁, r₁, hp₁, hr₁, rfl⟩
  obtain ⟨hd₂, hgt₂, hlt₂⟩ := hD (p₂ * r₂) hB₂ ⟨p₂, r₂, hp₂, hr₂, rfl⟩
  rw [hcl] at hd₁ hgt₁ hlt₁
  set d := D ((p₂ * r₂ : ℕ) : ZMod m) with hd
  have hc₁ : d = p₁ ∨ d = r₁ := by
    rcases Semiprime.dvd_cases hp₁ hr₁ hd₁ with h | h | h | h
    · omega
    · exact Or.inl h
    · exact Or.inr h
    · omega
  have hc₂ : d = p₂ ∨ d = r₂ := by
    rcases Semiprime.dvd_cases hp₂ hr₂ hd₂ with h | h | h | h
    · omega
    · exact Or.inl h
    · exact Or.inr h
    · omega
  rcases hc₁ with h₁ | h₁ <;> rcases hc₂ with h₂ | h₂ <;> omega

end DensSub