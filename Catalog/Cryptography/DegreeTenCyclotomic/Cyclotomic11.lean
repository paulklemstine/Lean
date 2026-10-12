import Cryptography.DegreeTenCyclotomic.Frobenius

/-!
# Paper 141, degree ten: the Frobenius type of `ℚ(ζ₁₁)` and the polynomial cross-check

The experiment (exp 473) checked on 400 primes that the factor-degree pattern of `Φ₁₁ mod p`
is `[1¹⁰]/[2⁵]/[5,5]/[10]` according as `ord₁₁(p) = 1, 2, 5, 10`.  Here this is proved for
**every** prime `p ≠ 11`, and in fact for every cyclotomic field:

* `factor_pattern_eq_orbit_pattern` — for `p ∤ n`, the factor-degree multiset of `Φₙ` over
  `𝔽_p` coincides with the cycle pattern of the regular action of the Frobenius class
  `p mod n` on `(ℤ/n)ˣ`: `[index⟨p⟩] copies of [period of p·]`.
* `frobType`, `frobType_eq_orderOf` — a computable Frobenius type agreeing with `ord₁₁`.
* `cyclotomic11_pattern` — for every prime `p ≠ 11` the pattern is one of the four.
* `cyclotomic11_mod23/43/3/2` — one witness per type; `cyclotomic11_irreducible_mod2`.
-/
open Polynomial UniqueFactorizationMonoid
namespace DegreeTen
set_option maxRecDepth 4000000

theorem factor_pattern_eq_orbit_pattern (p n : ℕ) [NeZero n] [Fact p.Prime] (h : p.Coprime n) :
    (normalizedFactors (cyclotomic n (ZMod p))).map natDegree =
      Multiset.replicate (Subgroup.zpowers (frobUnit p n h)).index
        (Function.minimalPeriod (frobUnit p n h * ·) 1) := by
  rw [cyclotomic_factor_pattern p n h, mulLeft_minimalPeriod]
  congr 1
  have h1 := zpowers_index_mul_orderOf (frobUnit p n h)
  rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient] at h1
  rw [← h1, Nat.mul_div_cancel _ (orderOf_pos _)]

/-- **Polynomial-level full pinning, every conductor.**  For primes `p, q ∤ n` with
`p ≡ q (mod n)`, `Φₙ` has the same factor-degree pattern over `𝔽_p` and over `𝔽_q`: the
residue class alone determines the splitting type. -/
theorem factor_pattern_eq_of_modEq (p q n : ℕ) [Fact p.Prime] [Fact q.Prime]
    (hp : p.Coprime n) (hq : q.Coprime n) (hpq : p ≡ q [MOD n]) :
    (normalizedFactors (cyclotomic n (ZMod p))).map natDegree =
      (normalizedFactors (cyclotomic n (ZMod q))).map natDegree := by
  have he : frobUnit p n hp = frobUnit q n hq := by
    ext
    simpa [frobUnit] using (ZMod.natCast_eq_natCast_iff p q n).mpr hpq
  rw [cyclotomic_factor_pattern p n hp, cyclotomic_factor_pattern q n hq, he]

abbrev U11 := (ZMod 11)ˣ

/-- Computable Frobenius type `T(p) = ord₁₁(p)`. -/
def frobType (g : U11) : ℕ :=
  if g = 1 then 1 else if g ^ 2 = 1 then 2 else if g ^ 5 = 1 then 5 else 10

theorem frobType_eq_orderOf (g : U11) : orderOf g = frobType g := by
  have H : ∀ g : U11, 0 < frobType g ∧ g ^ frobType g = 1 ∧
      ∀ m < frobType g, 0 < m → g ^ m ≠ 1 := by decide
  obtain ⟨h0, h1, h2⟩ := H g
  exact (orderOf_eq_iff h0).mpr ⟨h1, h2⟩

theorem orderOf_U11_mem (g : U11) : orderOf g ∈ ({1, 2, 5, 10} : Finset ℕ) := by
  rw [frobType_eq_orderOf]; unfold frobType; split_ifs <;> simp

instance : Fact (Nat.Prime 11) := ⟨by norm_num⟩

theorem cyclotomic11_pattern (p : ℕ) [Fact p.Prime] (hp : p ≠ 11) :
    let P := (normalizedFactors (cyclotomic 11 (ZMod p))).map natDegree
    P = Multiset.replicate 10 1 ∨ P = Multiset.replicate 5 2 ∨
      P = Multiset.replicate 2 5 ∨ P = Multiset.replicate 1 10 := by
  have h : p.Coprime 11 := (Nat.coprime_primes Fact.out Fact.out).mpr hp
  intro P
  have hP : P = _ := cyclotomic_factor_pattern p 11 h
  have hm := orderOf_U11_mem (frobUnit p 11 h)
  have ht : Nat.totient 11 = 10 := by decide
  rw [ht] at hP
  simp only [Finset.mem_insert, Finset.mem_singleton] at hm
  rcases hm with hm | hm | hm | hm <;> rw [hm] at hP <;> simp [hP]

theorem frobUnit_eq (p : ℕ) (h : p.Coprime 11) (r : U11) (hr : ((p : ZMod 11)) = r) :
    frobUnit p 11 h = r := by
  ext; simp [frobUnit, hr]

/-- Pattern of `Φ₁₁ mod p` read off from the residue `p mod 11` alone. -/
theorem cyclotomic11_pattern_of_residue (p : ℕ) [Fact p.Prime] (h : p.Coprime 11) (r : U11)
    (hr : (p : ZMod 11) = r) :
    (normalizedFactors (cyclotomic 11 (ZMod p))).map natDegree =
      Multiset.replicate (10 / frobType r) (frobType r) := by
  rw [cyclotomic_factor_pattern p 11 h, frobUnit_eq p h r hr, frobType_eq_orderOf]
  rfl

/-- `p = 23 ≡ 1`: `Φ₁₁` splits into ten linear factors over `𝔽₂₃` (type `[1¹⁰]`). -/
theorem cyclotomic11_mod23 :
    haveI : Fact (Nat.Prime 23) := ⟨by norm_num⟩
    (normalizedFactors (cyclotomic 11 (ZMod 23))).map natDegree = Multiset.replicate 10 1 := by
  haveI : Fact (Nat.Prime 23) := ⟨by norm_num⟩
  rw [cyclotomic11_pattern_of_residue 23 (by norm_num) 1 (by decide)]; decide

/-- `p = 43 ≡ −1`: five quadratic factors over `𝔽₄₃` (type `[2⁵]`). -/
theorem cyclotomic11_mod43 :
    haveI : Fact (Nat.Prime 43) := ⟨by norm_num⟩
    (normalizedFactors (cyclotomic 11 (ZMod 43))).map natDegree = Multiset.replicate 5 2 := by
  haveI : Fact (Nat.Prime 43) := ⟨by norm_num⟩
  rw [cyclotomic11_pattern_of_residue 43 (by norm_num) (-1) (by decide)]; decide

/-- `p = 3` (a quadratic residue of order 5): two quintic factors over `𝔽₃` (type `[5,5]`). -/
theorem cyclotomic11_mod3 :
    haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
    (normalizedFactors (cyclotomic 11 (ZMod 3))).map natDegree = Multiset.replicate 2 5 := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  rw [cyclotomic11_pattern_of_residue 3 (by norm_num) (ZMod.unitOfCoprime 3 (by norm_num))
    (by simp)]; decide

/-- `p = 2` (a primitive root mod 11): `Φ₁₁` is irreducible over `𝔽₂` (type `[10]`). -/
theorem cyclotomic11_mod2 :
    (normalizedFactors (cyclotomic 11 (ZMod 2))).map natDegree = Multiset.replicate 1 10 := by
  rw [cyclotomic11_pattern_of_residue 2 (by norm_num) (ZMod.unitOfCoprime 2 (by norm_num))
    (by simp)]; decide
/-- `Φ₁₁` is irreducible over `𝔽₂` (2 is a primitive root mod 11). -/
theorem cyclotomic11_irreducible_mod2 : Irreducible (cyclotomic 11 (ZMod 2)) := by
  have hord : orderOf (ZMod.unitOfCoprime 2 (Nat.Prime.coprime_iff_not_dvd
      (Fact.out : Nat.Prime 2) |>.mpr (by norm_num)) : (ZMod 11)ˣ) = 10 := by
    rw [frobType_eq_orderOf]; decide
  exact ZMod.irreducible_of_dvd_cyclotomic_of_natDegree (by norm_num) dvd_rfl
    (by rw [natDegree_cyclotomic, hord]; decide)
end DegreeTen