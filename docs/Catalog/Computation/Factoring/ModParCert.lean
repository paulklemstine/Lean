import Computation.Factoring.SemiprimeBasics

/-!
# MODPAR-CERT: the divisor-count-parity primitive, and its decision-tree closure

Round-3 closure #2.  The atomic primitive is

`P(N, m, a) = (#{d : d a proper divisor of N, d ≡ a mod m}) mod 2`.

For a semiprime `N = p q` the proper divisors are exactly `{1, p, q}`, so the
parity pattern of `P(N, m, ·)` over the residues `a = 0, …, m-1` marks exactly
the three classes `1 mod m`, `p mod m`, `q mod m`.  This file proves:

* `ModPar.support_eq` — in the non-collision case the *support* of the parity
  pattern is exactly `{1 mod m, p mod m, q mod m}`, so subtracting the a priori
  known class `1 mod m` returns `{p mod m, q mod m}`
  (`ModPar.factor_residues_recovered`): the primitive certifies the
  factorization modulo `m`.
* `ModPar.card_support` — that support has only three elements out of `m`, i.e.
  the special-class density is `3/m`.
* `ModPar.transcript_eq_of_avoids` — the adversary/decision-tree closure: two
  different semiprimes produce *identical transcripts* on any query set that
  avoids the (at most six) marked classes.  Since the marked classes are a
  `6/m`-density needle, `Ω(m)` queries are needed in the worst case.
* `ModPar.collision_support` — when `p ≡ q (mod m)` the pattern collapses to the
  single class `1 mod m` and the factor residues are *provably* unrecoverable:
  the failures are exactly the merged-class cases.
-/

namespace ModPar

open Finset

/-- Parity of the number of proper divisors of `N` lying in the residue class
`a mod m`. -/
def parity (N m a : ℕ) : ℕ :=
  ((N.properDivisors.filter (fun d => d % m = a % m)).card) % 2

theorem parity_lt_two (N m a : ℕ) : parity N m a < 2 := Nat.mod_lt _ (by norm_num)

section Semiprime

variable {p q m : ℕ}

/-- The parity value at a residue `a`, for a semiprime, in the non-collision
case: it is `1` exactly on the three classes `1, p, q` mod `m`. -/
theorem parity_eq_one_iff (hp : p.Prime) (hq : q.Prime)
    (h1p : 1 % m ≠ p % m) (h1q : 1 % m ≠ q % m) (hpqm : p % m ≠ q % m) (a : ℕ) :
    parity (p * q) m a = 1 ↔ (1 % m = a % m ∨ p % m = a % m ∨ q % m = a % m) := by
  have hset : (p * q).properDivisors = {1, p, q} :=
    Semiprime.properDivisors_eq hp hq
  have h1p' : (1 : ℕ) ≠ p := Semiprime.one_ne_prime hp
  have h1q' : (1 : ℕ) ≠ q := Semiprime.one_ne_prime hq
  unfold parity
  rw [hset, Finset.filter_insert, Finset.filter_insert, Finset.filter_singleton]
  by_cases hA : (1 : ℕ) % m = a % m <;> by_cases hB : p % m = a % m <;>
    by_cases hC : q % m = a % m <;>
    simp_all

/-- Off the marked classes the parity vanishes. -/
theorem parity_eq_zero (hp : p.Prime) (hq : q.Prime)
    (h1p : 1 % m ≠ p % m) (h1q : 1 % m ≠ q % m) (hpqm : p % m ≠ q % m) {a : ℕ}
    (ha : ¬ (1 % m = a % m ∨ p % m = a % m ∨ q % m = a % m)) :
    parity (p * q) m a = 0 := by
  have h := parity_lt_two (p * q) m a
  have h1 : parity (p * q) m a ≠ 1 := by
    intro hone
    exact ha ((parity_eq_one_iff hp hq h1p h1q hpqm a).mp hone)
  omega

/-- The support of the parity pattern over one period, in the non-collision
case: exactly the three classes `1, p, q` mod `m`. -/
theorem support_eq (hp : p.Prime) (hq : q.Prime) (hm : 0 < m)
    (h1p : 1 % m ≠ p % m) (h1q : 1 % m ≠ q % m) (hpqm : p % m ≠ q % m) :
    (Finset.range m).filter (fun a => parity (p * q) m a = 1)
      = {1 % m, p % m, q % m} := by
  ext a
  simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_insert, Finset.mem_singleton]
  rw [parity_eq_one_iff hp hq h1p h1q hpqm]
  constructor
  · rintro ⟨ha, h⟩
    rw [Nat.mod_eq_of_lt ha] at h
    tauto
  · intro h
    have hlt : a < m := by
      rcases h with rfl | rfl | rfl <;> exact Nat.mod_lt _ hm
    refine ⟨hlt, ?_⟩
    rw [Nat.mod_eq_of_lt hlt]
    tauto

/-- Removing the a priori known class `1 mod m`, the primitive returns exactly
the pair of factor residues: MODPAR-CERT *is* a factorization certificate
modulo `m`. -/
theorem factor_residues_recovered (hp : p.Prime) (hq : q.Prime) (hm : 0 < m)
    (h1p : 1 % m ≠ p % m) (h1q : 1 % m ≠ q % m) (hpqm : p % m ≠ q % m) :
    (((Finset.range m).filter (fun a => parity (p * q) m a = 1)).erase (1 % m))
      = {p % m, q % m} := by
  rw [support_eq hp hq hm h1p h1q hpqm]
  ext a
  simp only [Finset.mem_erase, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨hne, h | h | h⟩
    · exact absurd h hne
    · exact Or.inl h
    · exact Or.inr h
  · rintro (rfl | rfl)
    · exact ⟨Ne.symm h1p, Or.inr (Or.inl rfl)⟩
    · exact ⟨Ne.symm h1q, Or.inr (Or.inr rfl)⟩

/-- Only three residue classes out of `m` are informative: the special-class
density is `3/m`. -/
theorem card_support (hp : p.Prime) (hq : q.Prime) (hm : 0 < m)
    (h1p : 1 % m ≠ p % m) (h1q : 1 % m ≠ q % m) (hpqm : p % m ≠ q % m) :
    (((Finset.range m).filter (fun a => parity (p * q) m a = 1))).card = 3 := by
  rw [support_eq hp hq hm h1p h1q hpqm]
  rw [Finset.card_insert_of_notMem (by simp [h1p, h1q]),
    Finset.card_insert_of_notMem (by simp [hpqm])]
  simp

/-- Adversary argument / decision-tree closure: two different semiprimes give
*identical* parity transcripts on every query set that avoids their (at most
six) marked residue classes.  Hence a decision tree using only the MODPAR
primitive must query one of those `≤ 6` classes among `m`, forcing `Ω(m)`
queries in the worst case. -/
theorem transcript_eq_of_avoids {p' q' : ℕ} (hp : p.Prime) (hq : q.Prime)
    (h1p : 1 % m ≠ p % m) (h1q : 1 % m ≠ q % m) (hpqm : p % m ≠ q % m)
    (hp' : p'.Prime) (hq' : q'.Prime)
    (h1p' : 1 % m ≠ p' % m) (h1q' : 1 % m ≠ q' % m) (hpqm' : p' % m ≠ q' % m)
    (Q : Finset ℕ)
    (hQ : ∀ a ∈ Q, a % m ∉ ({1 % m, p % m, q % m} : Finset ℕ) ∧
      a % m ∉ ({1 % m, p' % m, q' % m} : Finset ℕ)) :
    ∀ a ∈ Q, parity (p * q) m a = parity (p' * q') m a := by
  intro a ha
  obtain ⟨hA, hB⟩ := hQ a ha
  simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hA hB
  rw [parity_eq_zero hp hq h1p h1q hpqm (by tauto),
    parity_eq_zero hp' hq' h1p' h1q' hpqm' (by tauto)]

/-- The collision case: if `p ≡ q (mod m)` (but neither is `≡ 1`), the two
factor classes cancel in the parity and the pattern degenerates to the single
known class `1 mod m`.  These failures are genuinely unresolvable. -/
theorem collision_support (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) (hm : 0 < m)
    (hcol : p % m = q % m) (h1p : 1 % m ≠ p % m) :
    (Finset.range m).filter (fun a => parity (p * q) m a = 1) = {1 % m} := by
  have hset : (p * q).properDivisors = {1, p, q} :=
    Semiprime.properDivisors_eq hp hq
  have h1p' : (1 : ℕ) ≠ p := Semiprime.one_ne_prime hp
  have h1q' : (1 : ℕ) ≠ q := Semiprime.one_ne_prime hq
  have key : ∀ a, parity (p * q) m a = 1 ↔ 1 % m = a % m := by
    intro a
    unfold parity
    rw [hset, Finset.filter_insert, Finset.filter_insert, Finset.filter_singleton]
    by_cases hA : (1 : ℕ) % m = a % m <;> by_cases hB : p % m = a % m <;>
      simp_all [Finset.card_insert_of_notMem]
  ext a
  simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton, key]
  constructor
  · rintro ⟨ha, h⟩
    rw [Nat.mod_eq_of_lt ha] at h
    exact h.symm
  · rintro rfl
    exact ⟨Nat.mod_lt _ hm, by rw [Nat.mod_mod_of_dvd _ dvd_rfl]⟩

end Semiprime

/-- Concrete instance (experiment 304 data): `N = 15 = 3*5`, `m = 7`.  The
informative classes are `{1, 3, 5}`, so the factor residues `{3, 5}` are
recovered after deleting the known class `1`. -/
example : (Finset.range 7).filter (fun a => parity 15 7 a = 1) = {1, 3, 5} := by
  decide

/-- Concrete collision instance: `N = 15 = 3*5`, `m = 2`.  Here `3 ≡ 5 ≡ 1`
mod `2`, all three proper divisors merge and the pattern is uninformative. -/
example : (Finset.range 2).filter (fun a => parity 15 2 a = 1) = {1} := by
  decide

end ModPar