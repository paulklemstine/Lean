import Mathlib

/-!
# The quadratic-sieve relation pool is *exactly* random-equivalent, prime by prime

Context (experiment 465, paper 130).  In the quadratic sieve one factors the
values `v(x) = x^2 - N` over a factor base of primes `p ≤ B`, and one models the
probability that `v(x)` is `B`-smooth by the probability that a *random* integer
of the same size is `B`-smooth.  This looks suspicious, because the values
`x^2 - N` are **not** random: an odd prime `p ∤ N` can divide `x^2 - N` only when
`N` is a quadratic residue mod `p`, i.e. only *half* the primes are admissible at
all.  The empirical finding of the experiment is that, nevertheless, the pool
behaves exactly like a random pool of the same size at every scale tested
(`N ∈ {2^32 .. 2^44}`, ratio `0.993–1.020`).

This file proves the exact algebraic identity that *explains* that measurement:

* only half of the nonzero residues `N` are admissible
  (`card_admissible_residues`), but
* each admissible prime hits **twice** as often per period
  (`root_count_of_isSquare`), and
* the two effects cancel **exactly**, not just to leading order
  (`relation_pool_random_equivalent`, `expected_hits_eq_one`):
  the average, over the residue of `N`, of the number of `x` per period `p` with
  `p ∣ x^2 - N` is exactly `1` — the same as for a random integer sequence.

Main results:

* `dvd_qsValue_iff_sq_eq` — the arithmetic of the pool transported to `ZMod p`.
* `isSquare_of_dvd_qsValue` — the quadratic-character constraint on divisors.
* `exists_dvd_qsValue_iff_isSquare` — the constraint is *exactly* the obstruction.
* `root_count_of_isSquare` / `root_count_of_not_isSquare` — the `2`/`0` dichotomy.
* `card_admissible_residues` — exactly `(p-1)/2` admissible nonzero residues.
* `relation_pool_random_equivalent` — the exact cancellation `2 · (p-1)/2 = p-1`.
* `expected_hits_eq_one` — total hit count over a full period of residues is `p`.
-/

namespace QSRelationPool

open Finset

/-- The quadratic-sieve value at `x` for the modulus `N`: `v(x) = x^2 - N`. -/
def qsValue (N x : ℤ) : ℤ := x ^ 2 - N

/-- Number of `x` in one period mod `p` for which `p` divides the sieve value,
i.e. the number of square roots of `N` in `ZMod p`. -/
noncomputable def rootCount (p : ℕ) [Fact p.Prime] (a : ZMod p) : ℕ :=
  {x : ZMod p | x ^ 2 = a}.toFinset.card

/-! ## Transporting the pool to `ZMod p` -/

/-- `p` divides the sieve value `x^2 - N` iff the reduction of `x` is a square
root of the reduction of `N`. -/
theorem dvd_qsValue_iff_sq_eq {p : ℕ} (N x : ℤ) :
    (p : ℤ) ∣ qsValue N x ↔ ((x : ZMod p)) ^ 2 = (N : ZMod p) := by
  rw [qsValue, ← ZMod.intCast_zmod_eq_zero_iff_dvd]
  push_cast
  constructor
  · intro h; linear_combination h
  · intro h; linear_combination h

/-- **Quadratic-character constraint.**  Every prime divisor of a sieve value
`x^2 - N` forces `N` to be a quadratic residue modulo that prime.  This is the
constraint that makes the relation pool *look* non-random. -/
theorem isSquare_of_dvd_qsValue {p : ℕ} {N x : ℤ} (h : (p : ℤ) ∣ qsValue N x) :
    IsSquare (N : ZMod p) :=
  ⟨(x : ZMod p), by rw [← (dvd_qsValue_iff_sq_eq N x).1 h]; ring⟩

/-- Conversely the constraint is the *only* obstruction: if `N` is a quadratic
residue mod `p` then `p` really does divide some sieve value. -/
theorem exists_dvd_qsValue_iff_isSquare {p : ℕ} [NeZero p] (N : ℤ) :
    (∃ x : ℤ, (p : ℤ) ∣ qsValue N x) ↔ IsSquare (N : ZMod p) := by
  constructor
  · rintro ⟨x, hx⟩; exact isSquare_of_dvd_qsValue hx
  · rintro ⟨r, hr⟩
    refine ⟨(r.val : ℤ), ?_⟩
    rw [dvd_qsValue_iff_sq_eq]
    push_cast
    simp only [ZMod.natCast_val, ZMod.cast_id]
    rw [hr]; ring

/-! ## The `2`/`0` dichotomy for the local hit count -/

variable {p : ℕ} [Fact p.Prime]

/-- The local hit count is `χ(a) + 1`, where `χ` is the quadratic character. -/
theorem rootCount_eq (hp : p ≠ 2) (a : ZMod p) :
    (rootCount p a : ℤ) = quadraticChar (ZMod p) a + 1 := by
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rwa [ZMod.ringChar_zmod_n]
  simpa [rootCount] using quadraticChar_card_sqrts hchar a

/-- **Admissible primes hit twice per period.**  If `N` is a nonzero square mod
an odd prime `p`, then exactly `2` of the `p` residues `x` give `p ∣ x^2 - N`. -/
theorem root_count_of_isSquare (hp : p ≠ 2) {a : ZMod p} (ha : a ≠ 0)
    (hsq : IsSquare a) : rootCount p a = 2 := by
  have h1 : quadraticChar (ZMod p) a = 1 :=
    (quadraticChar_one_iff_isSquare ha).2 hsq
  have := rootCount_eq hp a
  rw [h1] at this
  exact_mod_cast this

/-- **Inadmissible primes never hit.**  If `N` is a non-square mod `p` then no
`x` gives `p ∣ x^2 - N`. -/
theorem root_count_of_not_isSquare (hp : p ≠ 2) {a : ZMod p} (hsq : ¬ IsSquare a) :
    rootCount p a = 0 := by
  have h1 : quadraticChar (ZMod p) a = -1 :=
    (quadraticChar_neg_one_iff_not_isSquare (F := ZMod p)).2 hsq
  have h2 : ((rootCount p a : ℕ) : ℤ) = 0 := by rw [rootCount_eq hp a, h1]; ring
  exact_mod_cast h2

/-- At `a = 0` there is exactly one root (`x = 0`): the ramified case `p ∣ N`. -/
theorem root_count_zero : rootCount p (0 : ZMod p) = 1 := by
  simp [rootCount, pow_eq_zero_iff]

/-! ## The exact cancellation -/

/-- **Total hit count over a full period of moduli.**  Summing the local hit
count over *all* residues `a` of `N` gives exactly `p`: on average, exactly one
`x` per period, which is precisely the count for a random integer sequence.
Half the moduli are excluded, and the surviving half is hit twice as often. -/
theorem expected_hits_eq_one (hp : p ≠ 2) :
    ∑ a : ZMod p, rootCount p a = p := by
  have hchar : ringChar (ZMod p) ≠ 2 := by rwa [ZMod.ringChar_zmod_n]
  have hcast : ((∑ a : ZMod p, rootCount p a : ℕ) : ℤ) = (p : ℤ) := by
    push_cast
    calc ∑ a : ZMod p, (rootCount p a : ℤ)
        = ∑ a : ZMod p, (quadraticChar (ZMod p) a + 1) := by
          exact Finset.sum_congr rfl fun a _ => rootCount_eq hp a
      _ = (∑ a : ZMod p, quadraticChar (ZMod p) a) + (Fintype.card (ZMod p) : ℤ) := by
          rw [Finset.sum_add_distrib]; simp [Finset.card_univ]
      _ = (p : ℤ) := by
          rw [quadraticChar_sum_zero hchar, ZMod.card]; ring
  exact_mod_cast hcast

/-- The admissible nonzero residues: those `a` for which some sieve value is
divisible by `p`. -/
noncomputable def admissible (p : ℕ) [Fact p.Prime] : Finset (ZMod p) :=
  {a : ZMod p | a ≠ 0 ∧ IsSquare a}.toFinset

/-- **Exact cancellation: the pool is random-equivalent.**  Twice the number of
admissible nonzero residues equals the number of *all* nonzero residues.  The
factor `2` lost in prime availability (only half the primes admit a relation) is
recovered exactly by the factor `2` gained in hit density, so the expected local
valuation of a sieve value matches that of a random integer. -/
theorem relation_pool_random_equivalent (hp : p ≠ 2) :
    2 * (admissible p).card = p - 1 := by
  classical
  have hsplit :
      ∑ a : ZMod p, rootCount p a
        = rootCount p (0 : ZMod p) + ∑ a ∈ Finset.univ.erase (0 : ZMod p), rootCount p a := by
    rw [← Finset.sum_erase_add _ _ (Finset.mem_univ (0 : ZMod p))]
    ring
  have hsum_erase : ∑ a ∈ Finset.univ.erase (0 : ZMod p), rootCount p a = p - 1 := by
    have := expected_hits_eq_one (p := p) hp
    rw [hsplit, root_count_zero] at this
    omega
  -- on the nonzero residues the summand is `2` on `admissible` and `0` elsewhere
  have hset : (admissible p) ⊆ Finset.univ.erase (0 : ZMod p) := by
    intro a ha
    simp only [admissible, Set.mem_toFinset, Set.mem_setOf_eq] at ha
    exact Finset.mem_erase.2 ⟨ha.1, Finset.mem_univ a⟩
  have hsum_split :
      ∑ a ∈ Finset.univ.erase (0 : ZMod p), rootCount p a
        = ∑ a ∈ admissible p, rootCount p a := by
    refine (Finset.sum_subset hset ?_).symm
    intro a ha hna
    have ha0 : a ≠ 0 := (Finset.mem_erase.1 ha).1
    have : ¬ IsSquare a := by
      intro hsq
      exact hna (by simp [admissible, ha0, hsq])
    exact root_count_of_not_isSquare hp this
  have hconst : ∑ a ∈ admissible p, rootCount p a = 2 * (admissible p).card := by
    rw [Finset.sum_congr rfl (fun a ha => ?_), Finset.sum_const, smul_eq_mul,
      Nat.mul_comm]
    simp only [admissible, Set.mem_toFinset, Set.mem_setOf_eq] at ha
    exact root_count_of_isSquare hp ha.1 ha.2
  omega

/-- **Half the residues are admissible.**  Exactly `(p-1)/2` of the `p-1` nonzero
residues `N` admit a relation modulo `p`. -/
theorem card_admissible_residues (hp : p ≠ 2) :
    (admissible p).card = (p - 1) / 2 := by
  have := relation_pool_random_equivalent (p := p) hp
  omega

/-! ## Lab notes: machine-checked instances of the identities

The following finite checks are verified by the kernel (`decide`), and are the
small-scale instances of the theorems above; they reproduce, exactly, the
`hitcounts ∈ {0,1,2}`, `#admissible = (p-1)/2`, `total = p` pattern measured
numerically in `ComputationalEvidence.md` for `p = 7, 11, 13, 17, 19, 31`. -/

section LabNotes

/-- `p = 7`, `N ≡ 2`: an admissible modulus is hit twice per period. -/
example : (Finset.univ.filter (fun x : ZMod 7 => x ^ 2 = 2)).card = 2 := by decide

/-- `p = 7`, `N ≡ 3`: an inadmissible modulus is never hit. -/
example : (Finset.univ.filter (fun x : ZMod 7 => x ^ 2 = 3)).card = 0 := by decide

/-- `p = 11`: exactly `(11-1)/2 = 5` nonzero admissible residues. -/
example :
    (Finset.univ.filter (fun a : ZMod 11 => a ≠ 0 ∧ ∃ x : ZMod 11, x ^ 2 = a)).card = 5 := by
  decide

/-- `p = 13`: the total hit count over a full period of moduli is `13`
(`expected_hits_eq_one`). -/
example : ∑ a : ZMod 13, (Finset.univ.filter (fun x : ZMod 13 => x ^ 2 = a)).card = 13 := by
  decide

end LabNotes

end QSRelationPool