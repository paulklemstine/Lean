import Mathlib

/-!
# Sierpiński numbers and covering systems

This file proves that `78557` is a Sierpiński number.  The proof uses the classical
seven congruence classes with moduli `2, 4, 3, 12, 18, 36, 9`, and packages their
finite arithmetic into a period-`36` certificate.  It also develops the basic
periodicity and Chinese-remainder facts behind covering arguments.

The stronger assertion that `78557` is the *smallest* Sierpiński number is not
asserted here: it remains the Sierpiński problem.
-/

namespace Sierpinski

/-- `k` has the universal non-primality property required of a Sierpiński number. -/
def IsSierpinski (k : ℕ) : Prop := ∀ n : ℕ, ¬ Nat.Prime (k * 2 ^ n + 1)

/-- A natural number is composite when it is greater than one and is not prime. -/
def IsComposite (m : ℕ) : Prop := 1 < m ∧ ¬ Nat.Prime m

/-- The conventional Sierpiński property, including positivity, oddness, and
compositeness for every exponent. -/
def IsClassicalSierpinski (k : ℕ) : Prop :=
  0 < k ∧ Odd k ∧ ∀ n : ℕ, IsComposite (k * 2 ^ n + 1)

/-- If `2^M` is one modulo `p`, then powers of two are periodic modulo `p` with
period `M`. -/
theorem pow_periodic (M p n : ℕ) (h : 2 ^ M ≡ 1 [MOD p]) :
    2 ^ n ≡ 2 ^ (n % M) [MOD p] := by
  rw [← Nat.mod_add_div n M]
  simpa [pow_add, pow_mul] using Nat.ModEq.mul_left _ (h.pow _)

/-- Divisibility at one exponent transfers to every exponent in the same residue
class of a valid period. -/
theorem dvd_transfer (k M p n r : ℕ) (hper : 2 ^ M ≡ 1 [MOD p])
    (hdvd : p ∣ k * 2 ^ r + 1) (hr : n % M = r) : p ∣ k * 2 ^ n + 1 := by
  rw [← Nat.mod_add_div n M, hr]
  simp_all +decide [pow_add, pow_mul, ← ZMod.natCast_eq_natCast_iff]
  simp_all +decide [← ZMod.natCast_eq_zero_iff]

/-- A finite period certificate assigning a proper prime divisor to every residue. -/
structure CoveringCert where
  k : ℕ
  M : ℕ
  Mpos : 0 < M
  table : Fin M → ℕ
  primality : ∀ r, Nat.Prime (table r)
  periodicity : ∀ r, 2 ^ M ≡ 1 [MOD table r]
  divisibility : ∀ r, table r ∣ k * 2 ^ r.val + 1
  proper : ∀ r, k * 2 ^ r.val + 1 ≠ table r

/-- Every finite covering certificate proves universal non-primality. -/
theorem CoveringCert.isSierpinski (cert : CoveringCert) : IsSierpinski cert.k := by
  intro n
  let r : Fin cert.M := ⟨n % cert.M, Nat.mod_lt _ cert.Mpos⟩
  have hp : Nat.Prime (cert.table r) := cert.primality r
  have hbase : cert.table r ∣ cert.k * 2 ^ r.val + 1 := cert.divisibility r
  have hn : cert.table r ∣ cert.k * 2 ^ n + 1 :=
    dvd_transfer cert.k cert.M (cert.table r) n r.val
      (cert.periodicity r) hbase rfl
  have hle : cert.table r ≤ cert.k * 2 ^ r.val + 1 :=
    Nat.le_of_dvd (Nat.succ_pos _) hbase
  have hltBase : cert.table r < cert.k * 2 ^ r.val + 1 :=
    lt_of_le_of_ne hle (fun h => cert.proper r h.symm)
  have hrle : r.val ≤ n := Nat.mod_le _ _
  have hpow : (2 : ℕ) ^ r.val ≤ 2 ^ n :=
    Nat.pow_le_pow_right (by norm_num) hrle
  have hmono : cert.k * 2 ^ r.val + 1 ≤ cert.k * 2 ^ n + 1 := by
    exact Nat.add_le_add_right (Nat.mul_le_mul_left cert.k hpow) 1
  have hlt : cert.table r < cert.k * 2 ^ n + 1 := lt_of_lt_of_le hltBase hmono
  intro hprime
  rcases hprime.eq_one_or_self_of_dvd _ hn with hOne | hSelf
  · exact hp.ne_one hOne
  · exact (Nat.ne_of_lt hlt) hSelf

/-- A normalized congruence class of natural numbers. -/
structure CongruenceClass where
  residue : ℕ
  modulus : ℕ
  modulus_pos : 0 < modulus
  residue_lt : residue < modulus

/-- Membership in a normalized congruence class. -/
def CongruenceClass.Contains (c : CongruenceClass) (n : ℕ) : Prop :=
  n % c.modulus = c.residue

/-- Two congruence classes are compatible when they have a common member. -/
def CongruenceClass.Compatible (c₁ c₂ : CongruenceClass) : Prop :=
  ∃ n, c₁.Contains n ∧ c₂.Contains n

/-- Coprime moduli make any two normalized congruence classes compatible, by the
Chinese remainder theorem. -/
theorem CongruenceClass.compatible_of_coprime (c₁ c₂ : CongruenceClass)
    (hcop : Nat.Coprime c₁.modulus c₂.modulus) : c₁.Compatible c₂ := by
  obtain ⟨x, hx₁, hx₂⟩ := Nat.chineseRemainder hcop c₁.residue c₂.residue
  refine ⟨x, ?_, ?_⟩
  · simpa [CongruenceClass.Contains, Nat.ModEq,
      Nat.mod_eq_of_lt c₁.residue_lt] using hx₁
  · simpa [CongruenceClass.Contains, Nat.ModEq,
      Nat.mod_eq_of_lt c₂.residue_lt] using hx₂

/-- The generalized Chinese remainder criterion: residues agreeing modulo the gcd
of two moduli have a simultaneous solution. -/
theorem CongruenceClass.compatible_of_modEq_gcd (c₁ c₂ : CongruenceClass)
    (h : c₁.residue ≡ c₂.residue [MOD Nat.gcd c₁.modulus c₂.modulus]) :
    c₁.Compatible c₂ := by
  obtain ⟨x, hx₁, hx₂⟩ := Nat.chineseRemainder' h
  refine ⟨x, ?_, ?_⟩
  · simpa [CongruenceClass.Contains, Nat.ModEq,
      Nat.mod_eq_of_lt c₁.residue_lt] using hx₁
  · simpa [CongruenceClass.Contains, Nat.ModEq,
      Nat.mod_eq_of_lt c₂.residue_lt] using hx₂

/-- A finite list of congruence classes covering every natural number. -/
structure CoveringSystem where
  classes : List CongruenceClass
  covers : ∀ n, ∃ c ∈ classes, c.Contains n

/-- Constructor for a normalized congruence class. -/
def mkClass (residue modulus : ℕ) (hpos : 0 < modulus)
    (hlt : residue < modulus) : CongruenceClass :=
  ⟨residue, modulus, hpos, hlt⟩

/-- The seven classical congruence classes in Selfridge's covering for `78557`. -/
def classes78557 : List CongruenceClass := [
  mkClass 0 2 (by omega) (by omega),
  mkClass 1 4 (by omega) (by omega),
  mkClass 1 3 (by omega) (by omega),
  mkClass 11 12 (by omega) (by omega),
  mkClass 15 18 (by omega) (by omega),
  mkClass 27 36 (by omega) (by omega),
  mkClass 3 9 (by omega) (by omega)
]

/-- The seven congruence classes for `78557` cover every natural number. -/
theorem classes78557_cover (n : ℕ) :
    ∃ c ∈ classes78557, c.Contains n := by
  have hn36 : n % 36 < 36 := Nat.mod_lt _ (by omega)
  interval_cases h : n % 36 <;>
    simp only [classes78557, List.mem_cons, exists_eq_or_imp, mkClass,
      CongruenceClass.Contains] <;>
    omega

/-- The seven classes form a covering system. -/
def coveringSystem78557 : CoveringSystem where
  classes := classes78557
  covers := classes78557_cover

/-- The prime assigned to each residue modulo `36` in the covering certificate. -/
def table78557 : Fin 36 → ℕ :=
  ![3, 5, 3, 73, 3, 5, 3, 7, 3, 5, 3, 13, 3, 5, 3, 19, 3, 5,
    3, 7, 3, 5, 3, 13, 3, 5, 3, 37, 3, 5, 3, 7, 3, 5, 3, 13]

/-- Every entry of the period table is one of the seven covering primes. -/
theorem table78557_mem (r : Fin 36) :
    table78557 r ∈ ({3, 5, 7, 13, 19, 37, 73} : Finset ℕ) := by
  fin_cases r <;> decide

/-- A checked period-`36` covering certificate for `78557`. -/
def cert78557 : CoveringCert where
  k := 78557
  M := 36
  Mpos := by norm_num
  table := table78557
  primality := by decide
  periodicity := by decide
  divisibility := by decide
  proper := by decide

/-- For every exponent, one of `3, 5, 7, 13, 19, 37, 73` is a proper prime
divisor of `78557 * 2^n + 1`. -/
theorem proper_prime_divisor_78557 (n : ℕ) :
    ∃ p ∈ ({3, 5, 7, 13, 19, 37, 73} : Finset ℕ),
      Nat.Prime p ∧ p ∣ 78557 * 2 ^ n + 1 ∧ p < 78557 * 2 ^ n + 1 := by
  let r : Fin cert78557.M := ⟨n % cert78557.M, Nat.mod_lt _ cert78557.Mpos⟩
  refine ⟨cert78557.table r, ?_, cert78557.primality r, ?_, ?_⟩
  · exact table78557_mem r
  · exact dvd_transfer cert78557.k cert78557.M (cert78557.table r) n r.val
      (cert78557.periodicity r) (cert78557.divisibility r) rfl
  · have hle : cert78557.table r ≤ cert78557.k * 2 ^ r.val + 1 :=
      Nat.le_of_dvd (Nat.succ_pos _) (cert78557.divisibility r)
    have hlt : cert78557.table r < cert78557.k * 2 ^ r.val + 1 :=
      lt_of_le_of_ne hle (fun h => cert78557.proper r h.symm)
    have hrle : r.val ≤ n := Nat.mod_le _ _
    have hpow : (2 : ℕ) ^ r.val ≤ 2 ^ n :=
      Nat.pow_le_pow_right (by norm_num) hrle
    exact lt_of_lt_of_le hlt
      (Nat.add_le_add_right (Nat.mul_le_mul_left cert78557.k hpow) 1)

/-- `78557 * 2^n + 1` is composite for every natural exponent `n`. -/
theorem composite_78557 (n : ℕ) : IsComposite (78557 * 2 ^ n + 1) := by
  constructor
  · have hpow : 0 < (2 : ℕ) ^ n := pow_pos (by norm_num) _
    omega
  · exact cert78557.isSierpinski n

/-- `78557` is a Sierpiński number. -/
theorem sierpinski_78557 : IsSierpinski 78557 := cert78557.isSierpinski

/-- `78557` satisfies the conventional positive, odd, universal-compositeness
definition of a Sierpiński number. -/
theorem classical_sierpinski_78557 : IsClassicalSierpinski 78557 := by
  refine ⟨by norm_num, by norm_num, composite_78557⟩

end Sierpinski