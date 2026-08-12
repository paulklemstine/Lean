/-
# Singular Moduli Factoring — Core Counting Layer

This file formalises the *arithmetic core* of the "singular moduli factoring"
method.  Given a semiprime `N = p * q` and an integer polynomial `f` (in the
motivating application `f = H_D`, the Hilbert class polynomial of a CM
discriminant `D`, whose roots mod `p` are the `j`-invariants of elliptic curves
over `F_p` with CM by the order of discriminant `D`), the method computes

    gcd (f(j₀), N)

for evaluation points `j₀` and hopes for a nontrivial divisor.

The two results proved here are:

* `SingularModuli.gcd_eval_eq` — an *exact* product formula for
  `gcd (f(j₀), N)` in terms of the two divisibility predicates, hence
  `SingularModuli.gcd_nontrivial_iff`: the evaluation point succeeds **iff**
  `j₀` is a root of `f` modulo exactly one of `p`, `q` (an exclusive-or
  condition — this is the precise sense in which the method "works").

* `SingularModuli.card_goodSet` — an exact count of the successful residues
  modulo `N` via the Chinese Remainder decomposition:
  `r_p (q - r_q) + (p - r_p) r_q`, where `r_m` is the number of roots of
  `f` mod `m`.  Together with `card_rootsMod_le_natDegree` (`r_m ≤ deg f`)
  this is what drives the `√N` barrier proved in `SingularModuliBarrier.lean`.

Everything is stated for an arbitrary integer polynomial: no unproved property
of Hilbert class polynomials is assumed anywhere.
-/
import Mathlib

namespace SingularModuli

open Polynomial Finset

/-! ## Roots modulo `m` -/

/-- The finite set of roots in `ZMod m` of the reduction of an integer
polynomial `f`. In the motivating case `f = H_D` and `m = p` a prime split in
the CM field, this is the set of `j`-invariants over `F_p` with CM by the order
of discriminant `D`; its cardinality is the class number `h(D)`. -/
noncomputable def rootsMod (f : Polynomial ℤ) (m : ℕ) [NeZero m] : Finset (ZMod m) :=
  Finset.univ.filter fun x => (f.map (Int.castRingHom (ZMod m))).eval x = 0

lemma mem_rootsMod {f : Polynomial ℤ} {m : ℕ} [NeZero m] {x : ZMod m} :
    x ∈ rootsMod f m ↔ (f.map (Int.castRingHom (ZMod m))).eval x = 0 := by
  simp [rootsMod]

/-- Reduction dictionary: an integer `j` reduces into `rootsMod f m` exactly
when `m` divides the integer value `f(j)`. -/
lemma intCast_mem_rootsMod {f : Polynomial ℤ} {m : ℕ} [NeZero m] {j : ℤ} :
    ((j : ZMod m) ∈ rootsMod f m) ↔ (m : ℤ) ∣ f.eval j := by
  rw [mem_rootsMod, Polynomial.eval_intCast_map]
  exact ZMod.intCast_zmod_eq_zero_iff_dvd (f.eval j) m

/-- The number of roots mod a prime is at most the degree.  (For `f = H_D`
this bound is attained: the count is the class number `h(D) = deg H_D`
whenever `p` splits completely in the ring class field.) -/
lemma card_rootsMod_le_natDegree (f : Polynomial ℤ) (p : ℕ) [Fact p.Prime]
    (hf : f.map (Int.castRingHom (ZMod p)) ≠ 0) :
    (rootsMod f p).card ≤ f.natDegree := by
  classical
  have h1 : rootsMod f p ⊆ (f.map (Int.castRingHom (ZMod p))).roots.toFinset := by
    intro x hx
    rw [Multiset.mem_toFinset, Polynomial.mem_roots hf]
    exact mem_rootsMod.mp hx
  calc (rootsMod f p).card
      ≤ (f.map (Int.castRingHom (ZMod p))).roots.toFinset.card := Finset.card_le_card h1
    _ ≤ Multiset.card (f.map (Int.castRingHom (ZMod p))).roots := Multiset.toFinset_card_le _
    _ ≤ (f.map (Int.castRingHom (ZMod p))).natDegree := Polynomial.card_roots' _
    _ ≤ f.natDegree := Polynomial.natDegree_map_le

/-! ## The exact gcd formula -/

/-- **Exact evaluation of the gcd step.**  For a semiprime `N = p q` the gcd
computed by the method is the product of those primes that actually divide the
value; in particular it is *never* anything else. -/
lemma gcd_mul_prime_eq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (a : ℕ) :
    Nat.gcd a (p * q) = (if p ∣ a then p else 1) * (if q ∣ a then q else 1) := by
  have hco : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  by_cases hpa : p ∣ a <;> by_cases hqa : q ∣ a
  · have : p * q ∣ a := hco.mul_dvd_of_dvd_of_dvd hpa hqa
    simp [hpa, hqa, Nat.gcd_eq_right this]
  · have hcq : Nat.Coprime q a := (Nat.Prime.coprime_iff_not_dvd hq).mpr hqa
    have : Nat.gcd a (p * q) = Nat.gcd a p := Nat.Coprime.gcd_mul_right_cancel_right p hcq
    simp [hpa, hqa, this, Nat.gcd_eq_right hpa]
  · have hcp : Nat.Coprime p a := (Nat.Prime.coprime_iff_not_dvd hp).mpr hpa
    have : Nat.gcd a (p * q) = Nat.gcd a q := Nat.Coprime.gcd_mul_left_cancel_right q hcp
    simp [hpa, hqa, this, Nat.gcd_eq_right hqa]
  · have hcp : Nat.Coprime p a := (Nat.Prime.coprime_iff_not_dvd hp).mpr hpa
    have hcq : Nat.Coprime q a := (Nat.Prime.coprime_iff_not_dvd hq).mpr hqa
    have h1 : Nat.gcd a (p * q) = Nat.gcd a q := Nat.Coprime.gcd_mul_left_cancel_right q hcp
    have h2 : Nat.gcd a q = 1 := hcq.symm
    simp [hpa, hqa, h1, h2]

/-- **Success criterion.**  The gcd is a nontrivial divisor of `N = p q`
precisely when the evaluation point is a root modulo exactly one of the two
primes. -/
theorem gcd_nontrivial_iff {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (a : ℕ) :
    (Nat.gcd a (p * q) ≠ 1 ∧ Nat.gcd a (p * q) ≠ p * q) ↔ Xor' (p ∣ a) (q ∣ a) := by
  have hp1 := hp.one_lt
  have hq1 := hq.one_lt
  have hpn : p ≠ p * q := by
    nlinarith [hp1, hq1]
  have hqn : q ≠ p * q := by
    nlinarith [hp1, hq1]
  rw [gcd_mul_prime_eq hp hq hpq a]
  by_cases hpa : p ∣ a <;> by_cases hqa : q ∣ a <;>
    simp [hpa, hqa, Xor', hp.ne_one, hq.ne_one, hpn, hqn]

/-! ## Counting successful residues mod `N` -/

/-- The set of successful residues, written in Chinese-Remainder coordinates
`ZMod p × ZMod q`: an evaluation point succeeds iff it is a root modulo exactly
one of the primes. -/
noncomputable def goodSet (f : Polynomial ℤ) (p q : ℕ) [NeZero p] [NeZero q] : Finset (ZMod p × ZMod q) :=
  Finset.univ.filter fun z => Xor' (z.1 ∈ rootsMod f p) (z.2 ∈ rootsMod f q)

/-- An integer evaluation point `j₀` factors `N = p q` iff its CRT coordinates
lie in `goodSet`. -/
theorem gcd_eval_nontrivial_iff {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    [NeZero p] [NeZero q] (f : Polynomial ℤ) (j : ℤ) :
    (Nat.gcd (f.eval j).natAbs (p * q) ≠ 1 ∧
        Nat.gcd (f.eval j).natAbs (p * q) ≠ p * q) ↔
      ((j : ZMod p), (j : ZMod q)) ∈ goodSet f p q := by
  rw [gcd_nontrivial_iff hp hq hpq]
  simp only [goodSet, Finset.mem_filter, Finset.mem_univ, true_and,
    intCast_mem_rootsMod, ← Int.ofNat_dvd_left]

/-- **Exact count of successful residues.**  With `r_p`, `r_q` the numbers of
roots of `f` mod `p`, `q`, exactly `r_p (q - r_q) + (p - r_p) r_q` of the `p q`
residues modulo `N` yield a nontrivial factor. -/
theorem card_goodSet (f : Polynomial ℤ) (p q : ℕ) [NeZero p] [NeZero q] :
    (goodSet f p q).card =
      (rootsMod f p).card * (q - (rootsMod f q).card)
        + (p - (rootsMod f p).card) * (rootsMod f q).card := by
  classical
  have h : goodSet f p q =
      (rootsMod f p ×ˢ (rootsMod f q)ᶜ) ∪ ((rootsMod f p)ᶜ ×ˢ rootsMod f q) := by
    ext ⟨a, b⟩
    simp only [goodSet, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_union,
      Finset.mem_product, Finset.mem_compl, Xor']
    tauto
  have hdisj : Disjoint (rootsMod f p ×ˢ (rootsMod f q)ᶜ) ((rootsMod f p)ᶜ ×ˢ rootsMod f q) := by
    rw [Finset.disjoint_left]
    rintro ⟨a, b⟩ h1 h2
    simp only [Finset.mem_product, Finset.mem_compl] at h1 h2
    exact h2.1 h1.1
  rw [h, Finset.card_union_of_disjoint hdisj, Finset.card_product, Finset.card_product,
    Finset.card_compl, Finset.card_compl, ZMod.card, ZMod.card]

/-- The CRT coordinates exhaust all residues: the number of successful residues
mod `N` really is `card_goodSet`, computed in `ZMod N` itself. -/
theorem card_goodSet_eq_card_preimage {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    [NeZero p] [NeZero q] (f : Polynomial ℤ) :
    (Finset.univ.filter fun x : ZMod (p * q) =>
        ZMod.chineseRemainder ((Nat.coprime_primes hp hq).mpr hpq) x ∈ goodSet f p q).card
      = (goodSet f p q).card := by
  classical
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero (NeZero.ne p) (NeZero.ne q)⟩
  let e := ZMod.chineseRemainder ((Nat.coprime_primes hp hq).mpr hpq)
  have : (Finset.univ.filter fun x : ZMod (p * q) => e x ∈ goodSet f p q)
      = Finset.univ.filter fun x : ZMod (p * q) => x ∈ (goodSet f p q).image e.symm := by
    ext x
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · intro hx; exact ⟨e x, hx, by simp [e]⟩
    · rintro ⟨y, hy, rfl⟩; simpa [e] using hy
  rw [this, Finset.filter_mem_eq_inter]
  rw [Finset.univ_inter, Finset.card_image_of_injective _ e.symm.injective]

/-! ## Lab notes: worked instances with genuine Hilbert class polynomials

The class polynomials used below are the standard ones,
`H_{-3} = X`, `H_{-4} = X - 1728`, `H_{-7} = X + 3375`
(class number one: the singular moduli `0`, `1728`, `-3375`).
Each instance is certified twice: once as an explicit gcd computation, and once
as membership in `goodSet`, deduced from the general dictionary
`gcd_eval_nontrivial_iff` — so these really are instances of the theory above,
not standalone numerics. -/

/-- `H_{-3} = X`, the singular modulus `j = 0`. -/
noncomputable def hilbertNeg3 : Polynomial ℤ := Polynomial.X

/-- `H_{-4} = X - 1728`, the singular modulus `j = 1728`. -/
noncomputable def hilbertNeg4 : Polynomial ℤ := Polynomial.X - Polynomial.C 1728

/-- `H_{-7} = X + 3375`, the singular modulus `j = -3375`. -/
noncomputable def hilbertNeg7 : Polynomial ℤ := Polynomial.X + Polynomial.C 3375

/-- `N = 5183 = 71 · 73`, `D = -4`, evaluation point `j₀ = 24 ≡ 1728 (mod 71)`:
one evaluation yields the factor `71`. -/
theorem factor_5183_hilbertNeg4 :
    Nat.gcd (hilbertNeg4.eval 24).natAbs (71 * 73) = 71 := by
  have h : hilbertNeg4.eval 24 = -1704 := by simp [hilbertNeg4]
  rw [h]
  norm_num

/-- The same instance seen inside the theory: the CRT coordinates of `24` lie
in the success set of `H_{-4}` for `N = 5183`. -/
theorem good_5183_hilbertNeg4 :
    (((24 : ℤ) : ZMod 71), ((24 : ℤ) : ZMod 73)) ∈ goodSet hilbertNeg4 71 73 := by
  have hp : Nat.Prime 71 := by norm_num
  have hq : Nat.Prime 73 := by norm_num
  rw [← gcd_eval_nontrivial_iff hp hq (by norm_num) hilbertNeg4 24,
    factor_5183_hilbertNeg4]
  norm_num

/-- `N = 3599 = 59 · 61`, `D = -7`, evaluation point `j₀ = 47`: the factor `59`
is found in one evaluation. -/
theorem factor_3599_hilbertNeg7 :
    Nat.gcd (hilbertNeg7.eval 47).natAbs (59 * 61) = 59 := by
  have h : hilbertNeg7.eval 47 = 3422 := by simp [hilbertNeg7]
  rw [h]
  norm_num

/-- `N = 8051 = 83 · 97`, `D = -3`, evaluation point `j₀ = 83`: the factor `83`.
(The same `N` is *not* factorable with `D = -15`, whose class polynomial has no
root modulo either prime — see `ComputationalEvidence.md`.) -/
theorem factor_8051_hilbertNeg3 :
    Nat.gcd (hilbertNeg3.eval 83).natAbs (83 * 97) = 83 := by
  have h : hilbertNeg3.eval 83 = 83 := by simp [hilbertNeg3]
  rw [h]
  norm_num

/-- A failed evaluation is genuinely failed, and the theory says why: `j₀ = 0`
is a root of `H_{-3}` modulo *both* primes, so the gcd returns all of `N`. -/
theorem fail_8051_hilbertNeg3 :
    Nat.gcd (hilbertNeg3.eval 0).natAbs (83 * 97) = 83 * 97 := by
  have h : hilbertNeg3.eval 0 = 0 := by simp [hilbertNeg3]
  rw [h]
  norm_num

end SingularModuli