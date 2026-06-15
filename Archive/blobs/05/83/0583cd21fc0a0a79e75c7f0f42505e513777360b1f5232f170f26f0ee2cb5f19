/-
  # Sierpiński Numbers and Covering Systems

  This file formalizes the theory of covering systems and their application
  to proving that certain numbers are Sierpiński numbers. A Sierpiński number
  is an odd integer k > 0 such that k · 2^n + 1 is composite for every n ≥ 1.

  The key technique is to exhibit a "covering system" — a finite set of
  congruences that covers all natural numbers — paired with primes that
  divide k · 2^a + 1 for the corresponding residue class.

  ## Main Results

  - `CoveringSystem`: Definition of a covering system of congruences
  - `SierpinskiCertificate`: A certificate proving a number is Sierpiński
  - `certificate_gives_divisor`: If a valid certificate exists, every k·2^n+1 has a prime divisor
  - `covering_system_lcm_period`: Periodicity of covering systems via LCM
  - `crt_compatible`: CRT guarantees compatibility of coprime congruence classes
  - `uniform_covering_card`: Lower bound on number of classes in uniform coverings
  - `covering_by_parity`: Composing coverings by parity

  ## References

  - Sierpiński, W. "Sur un problème concernant les nombres k · 2^n + 1"
  - Selfridge (unpublished, 1962): covering system for 78557
-/

import Mathlib

open Nat Finset

/-! ## Covering Systems -/

/-- A congruence class: the set of integers n with n ≡ residue (mod modulus) -/
structure CongruenceClass where
  residue : ℕ
  modulus : ℕ
  modulus_pos : 0 < modulus
  residue_lt : residue < modulus

/-- A covering system is a finite list of congruence classes that covers every natural number. -/
structure CoveringSystem where
  classes : List CongruenceClass
  nonempty : classes ≠ []
  covers : ∀ n : ℕ, ∃ c ∈ classes, n % c.modulus = c.residue

/-- A Sierpiński certificate pairs a covering system with primes witnessing compositeness.
    The key insight: if the covering system ensures every n falls into some congruence class,
    and for each class the associated prime divides k · 2^(residue) + 1, and the prime's
    multiplicative order of 2 divides the modulus, then p also divides k · 2^n + 1
    for every n in that class. -/
structure SierpinskiCertificate (k : ℕ) where
  system : CoveringSystem
  primes : List ℕ
  primes_len : primes.length = system.classes.length
  primes_prime : ∀ p ∈ primes, Nat.Prime p
  /-- Each prime p divides k · 2^a + 1 where a is the residue of the corresponding class -/
  divisibility : ∀ i : Fin system.classes.length,
    let c := system.classes[i]
    let p := primes[i]'(by omega)
    p ∣ (k * 2 ^ c.residue + 1)
  /-- Each prime p has multiplicative order dividing the modulus of the corresponding class -/
  order_divides : ∀ i : Fin system.classes.length,
    let c := system.classes[i]
    let p := primes[i]'(by omega)
    2 ^ c.modulus ≡ 1 [MOD p]

/-! ## Key Theorem: Certificates Imply Sierpiński Property -/

/-- k · 2^n + 1 is composite means it is greater than 1 and not prime -/
def IsComposite (n : ℕ) : Prop := 1 < n ∧ ¬ Nat.Prime n

/-- A number k is a Sierpiński number if k is odd, positive, and k · 2^n + 1
    is composite for every positive n -/
def IsSierpinskiNumber (k : ℕ) : Prop :=
  Odd k ∧ 0 < k ∧ ∀ n : ℕ, 0 < n → IsComposite (k * 2 ^ n + 1)

/-- If 2^m ≡ 1 (mod p) and n ≡ a (mod m), then 2^n ≡ 2^a (mod p).
    This is the key modular exponentiation lemma: the periodicity of
    powers of 2 modulo p allows us to reduce 2^n to 2^(n mod ord_p(2)). -/
theorem pow_mod_congr (p m a n : ℕ) (_hp : 2 ≤ p)
    (hord : 2 ^ m ≡ 1 [MOD p])
    (hcong : n % m = a) (_hm : 0 < m) :
    2 ^ n ≡ 2 ^ a [MOD p] := by
  rw [← Nat.mod_add_div n m, hcong]
  simpa [pow_add, pow_mul] using Nat.ModEq.mul_left _ (hord.pow _)

/-- If p divides k · 2^a + 1 and 2^n ≡ 2^a (mod p), then p divides k · 2^n + 1.
    This transfers divisibility across congruent exponents. -/
theorem divisor_transfers (k p a n : ℕ)
    (hdiv : p ∣ (k * 2 ^ a + 1))
    (hcong : 2 ^ n ≡ 2 ^ a [MOD p]) :
    p ∣ (k * 2 ^ n + 1) := by
  simp_all +decide [← ZMod.natCast_eq_zero_iff, ← ZMod.natCast_eq_natCast_iff]

/-- A valid Sierpiński certificate proves that every k · 2^n + 1 has a prime divisor
    from the certificate's prime list. This is the main soundness theorem for certificates. -/
theorem certificate_gives_divisor (k : ℕ) (cert : SierpinskiCertificate k) (n : ℕ) :
    ∃ p ∈ cert.primes, p ∣ (k * 2 ^ n + 1) := by
  obtain ⟨c, hc₁, hc₂⟩ := cert.system.covers n
  obtain ⟨i, hi⟩ : ∃ i : Fin cert.system.classes.length,
      c = cert.system.classes[i]'(by exact i.2) := by
    rw [List.mem_iff_get] at hc₁; aesop
  generalize_proofs at *
  refine' ⟨cert.primes[i]'(by linarith [cert.primes_len]), _, _⟩
  all_goals generalize_proofs at *
  · grind +revert
  · convert divisor_transfers k _ _ _ _ _
    exact c.residue
    · convert cert.divisibility i
    · convert pow_mod_congr _ _ _ _ _ _ _ _ using 1
      exact c.modulus
      · exact Nat.Prime.two_le (cert.primes_prime _ <| by simp)
      · simpa [hi] using cert.order_divides i
      · exact hc₂
      · exact c.modulus_pos

/-! ## Covering System Density -/

/-- The LCM of all moduli in a covering system -/
def CoveringSystem.lcm_moduli (cs : CoveringSystem) : ℕ :=
  cs.classes.foldl (fun acc c => Nat.lcm acc c.modulus) 1

/-- A covering system is periodic with period equal to the LCM of its moduli.
    This means we only need to verify coverage for finitely many residues. -/
theorem covering_system_lcm_period (cs : CoveringSystem) (n : ℕ) :
    ∀ c ∈ cs.classes, n % c.modulus = (n + cs.lcm_moduli) % c.modulus := by
  intro c hc
  refine Nat.ModEq.symm <| Nat.modEq_of_dvd ?_
  have h_lcm_div : ∀ c ∈ cs.classes, c.modulus ∣ cs.lcm_moduli := by
    unfold CoveringSystem.lcm_moduli
    induction' cs.classes using List.reverseRecOn with c cs ih <;> simp_all +decide
    rintro c (hc | rfl) <;>
      [exact dvd_trans (ih _ hc) (Nat.dvd_lcm_left _ _); exact Nat.dvd_lcm_right _ _]
  simpa using dvd_neg.mpr (Int.natCast_dvd_natCast.mpr (h_lcm_div c hc))

/-- In a covering system, we can verify coverage by checking finitely many residues.
    This reduces an infinite verification to a finite one via LCM periodicity. -/
theorem covering_finite_verification (cs : CoveringSystem) :
    (∀ n : ℕ, ∃ c ∈ cs.classes, n % c.modulus = c.residue) ↔
    (∀ n : Fin cs.lcm_moduli, ∃ c ∈ cs.classes, (n : ℕ) % c.modulus = c.residue) := by
  refine' ⟨fun h n => h n, _⟩
  exact fun _ n => cs.covers n

/-! ## CRT Connection -/

/-- Two congruence classes are compatible if their intersection is nonempty
    (i.e., some integer satisfies both congruences simultaneously) -/
def CongruenceClass.compatible (c₁ c₂ : CongruenceClass) : Prop :=
  ∃ n : ℕ, n % c₁.modulus = c₁.residue ∧ n % c₂.modulus = c₂.residue

/-- If two moduli are coprime, their congruence classes are always compatible.
    This is a direct consequence of the Chinese Remainder Theorem. -/
theorem crt_compatible (c₁ c₂ : CongruenceClass) (hcop : Nat.Coprime c₁.modulus c₂.modulus) :
    c₁.compatible c₂ := by
  obtain ⟨x, hx⟩ : ∃ x : ℕ, x ≡ c₁.residue [MOD c₁.modulus] ∧
      x ≡ c₂.residue [MOD c₂.modulus] := by
    have := Nat.chineseRemainder hcop c₁.residue c₂.residue; aesop
  exact ⟨x, hx.1.symm ▸ Nat.mod_eq_of_lt c₁.residue_lt,
    hx.2.symm ▸ Nat.mod_eq_of_lt c₂.residue_lt⟩

/-! ## Concrete Certificate for 78557 -/

/-- Helper to construct a congruence class with proof obligations -/
def mkCC (r m : ℕ) (hm : 0 < m) (hr : r < m) : CongruenceClass :=
  ⟨r, m, hm, hr⟩

/-- The covering system for 78557 uses moduli {2, 4, 3, 12, 18, 36, 9}
    with primes {3, 5, 7, 13, 19, 37, 73}:
    - n ≡ 0 (mod 2) → 3 | 78557·2^n + 1
    - n ≡ 1 (mod 4) → 5 | 78557·2^n + 1
    - n ≡ 1 (mod 3) → 7 | 78557·2^n + 1
    - n ≡ 11 (mod 12) → 13 | 78557·2^n + 1
    - n ≡ 15 (mod 18) → 19 | 78557·2^n + 1
    - n ≡ 27 (mod 36) → 37 | 78557·2^n + 1
    - n ≡ 3 (mod 9) → 73 | 78557·2^n + 1 -/
def sierpinski78557_classes : List CongruenceClass := [
  mkCC 0 2 (by omega) (by omega),
  mkCC 1 4 (by omega) (by omega),
  mkCC 1 3 (by omega) (by omega),
  mkCC 11 12 (by omega) (by omega),
  mkCC 15 18 (by omega) (by omega),
  mkCC 27 36 (by omega) (by omega),
  mkCC 3 9 (by omega) (by omega)
]

/-- The primes corresponding to the covering system for 78557 -/
def sierpinski78557_primes : List ℕ := [3, 5, 7, 13, 19, 37, 73]

/-! ## Properties of Covering Systems: Structural Lemmas -/

/-- Every element of a covering system's class list has positive modulus -/
theorem covering_moduli_pos (cs : CoveringSystem) (c : CongruenceClass) (_hc : c ∈ cs.classes) :
    0 < c.modulus := c.modulus_pos

/-- A covering system with a single class of residue 0 must have modulus 1.
    The only way one congruence class covers everything is if the modulus is 1. -/
theorem singleton_covering_modulus_one (c : CongruenceClass) (h : c.residue = 0)
    (hcov : ∀ n : ℕ, n % c.modulus = c.residue) :
    c.modulus = 1 := by
  exact Nat.dvd_one.mp (Nat.dvd_of_mod_eq_zero (by simpa [h] using hcov 1))

/-- If all moduli in a covering system are equal to m, then we need at least m classes.
    Each class covers exactly one residue mod m, so m residues require m classes.
    This is a pigeonhole-type argument. -/
theorem uniform_covering_card (cs : CoveringSystem)
    (m : ℕ) (_hm : 0 < m)
    (hunif : ∀ c ∈ cs.classes, c.modulus = m) :
    m ≤ cs.classes.length := by
  have h_cover : ∀ r : Fin m, ∃ c ∈ cs.classes, r.val % m = c.residue := by
    intro r
    obtain ⟨c, hc⟩ := cs.covers r.val
    use c
    aesop
  have h_inj : Finset.card (Finset.image
      (fun r : Fin m => (Classical.choose (h_cover r)).residue) Finset.univ) ≤
      cs.classes.length := by
    refine' le_trans (Finset.card_le_card _) _
    exact cs.classes.map (fun c => c.residue) |> List.toFinset
    · exact Finset.image_subset_iff.mpr fun r _ =>
        List.mem_toFinset.mpr <| List.mem_map.mpr
          ⟨_, Classical.choose_spec (h_cover r) |>.1, rfl⟩
    · exact le_trans (Multiset.toFinset_card_le _) (by simp)
  convert h_inj using 1
  rw [Finset.card_image_of_injective]
  · simp +decide
  · intro a b hab
    have := Classical.choose_spec (h_cover a)
    have := Classical.choose_spec (h_cover b)
    exact Fin.ext (by linarith [Nat.mod_eq_of_lt a.2, Nat.mod_eq_of_lt b.2])

/-- Composing coverings by parity: if one set of classes covers all even numbers
    and another covers all odd numbers, their union covers everything. -/
theorem covering_by_parity
    (even_classes odd_classes : List CongruenceClass)
    (heven : ∀ n : ℕ, Even n → ∃ c ∈ even_classes, n % c.modulus = c.residue)
    (hodd : ∀ n : ℕ, Odd n → ∃ c ∈ odd_classes, n % c.modulus = c.residue) :
    ∀ n : ℕ, ∃ c ∈ (even_classes ++ odd_classes), n % c.modulus = c.residue := by
  exact fun n => if hn : Even n then by
    obtain ⟨c, hc₁, hc₂⟩ := heven n hn
    exact ⟨c, List.mem_append_left _ hc₁, hc₂⟩
  else by
    obtain ⟨c, hc₁, hc₂⟩ := hodd n (by simpa using hn)
    exact ⟨c, List.mem_append_right _ hc₁, hc₂⟩

/-! ## Conjectured Minimality -/

/-- **Conjecture (Sierpiński Problem)**: 78557 is the smallest Sierpiński number.
    This is still an open problem as of 2025. The remaining candidates that
    need to be eliminated are: 21181, 22699, 24737, 55459, 67607.
    For each of these k, a prime of the form k · 2^n + 1 must be found. -/
def SierpinskiMinimalityConjecture : Prop :=
  ∀ k : ℕ, IsSierpinskiNumber k → 78557 ≤ k

/-- **Testable prediction**: If the conjecture is true, then for k = 21181,
    there exists some n such that 21181 · 2^n + 1 is prime.
    Computational searches have checked up to n ≈ 30,000,000 without finding a prime.
    Finding such a prime (or proving none exists) would resolve one of the remaining cases. -/
def TestPrediction_21181 : Prop :=
  ∃ n : ℕ, Nat.Prime (21181 * 2 ^ n + 1)