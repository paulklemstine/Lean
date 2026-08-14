/-
Round-10 Closures — Part IV: localising the quantum bypass (experiment 339).

The round-10 verdict on the quantum channel was: Shor's algorithm does **not** break the
trace lemma — the multiplicative order it computes is one of the classified free-witness
coordinates — it breaks the *aggregation* step, barrier 4.  Formally this means two things,
both proved here:

* the residue/order coordinate is **sufficient**: for a semiprime `N = p*q` with distinct
  odd primes there always exists a residue witness (a nontrivial square root of `1`) whose
  single evaluation yields a prime factor of `N`, unconditionally and constructively;
* by the trace lemma the number of square roots of unity is exactly `4`, so exactly two of
  them are the "quantum-useful" ones — the witness is not rare, it is merely expensive to
  *locate* classically (that cost is barrier 4, proved unreachable by aggregation in
  `JointClosure.lean`).

The construction is via CRT: the unit corresponding to `(1, -1)` under
`(ZMod (p*q))ˣ ≃* (ZMod p)ˣ × (ZMod q)ˣ`.
-/
import Geometry.Round10Closures.TraceLemma
import Cryptography.FactoringBarriers.CongruenceOfSquares

namespace Round10

open FactoringBarriers

/-- The CRT unit that is `1` modulo `p` and `-1` modulo `q`: a nontrivial square root of
unity modulo `N = p * q`. -/
noncomputable def crtSqrtOne {p q : ℕ} (hpq : Nat.Coprime p q) : (ZMod (p * q))ˣ :=
  (unitsMulEquivProd hpq).symm (1, -1)

variable {p q : ℕ}

theorem neg_one_ne_one_units (r : ℕ) [Fact r.Prime] (hr : r ≠ 2) : (-1 : (ZMod r)ˣ) ≠ 1 := by
  haveI : Fact (2 < r) := ⟨lt_of_le_of_ne (Fact.out : r.Prime).two_le (Ne.symm hr)⟩
  exact fun h => ZMod.neg_one_ne_one (congrArg Units.val h)

/-- The CRT isomorphism sends `-1` to `(-1, -1)` (it comes from a ring isomorphism). -/
theorem unitsMulEquivProd_neg_one (hpq : Nat.Coprime p q) :
    (unitsMulEquivProd hpq) (-1) = (-1, -1) := by
  refine Prod.ext (Units.ext ?_) (Units.ext ?_) <;>
    simp [unitsMulEquivProd, MulEquiv.prodUnits, Units.mapEquiv]

theorem crtSqrtOne_sq (hpq : Nat.Coprime p q) : (crtSqrtOne hpq) ^ 2 = 1 := by
  have h : ((1 : (ZMod p)ˣ), (-1 : (ZMod q)ˣ)) ^ 2 = 1 := by
    rw [Prod.pow_mk]
    simp
  rw [crtSqrtOne, ← map_pow, h, map_one]

theorem crtSqrtOne_ne_one [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) (hq : q ≠ 2) :
    crtSqrtOne hpq ≠ 1 := by
  intro h
  have := congrArg (unitsMulEquivProd hpq) h
  rw [crtSqrtOne, MulEquiv.apply_symm_apply, map_one] at this
  exact neg_one_ne_one_units q hq (congrArg Prod.snd this)

theorem crtSqrtOne_ne_neg_one [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q)
    (hp : p ≠ 2) : crtSqrtOne hpq ≠ -1 := by
  intro h
  have := congrArg (unitsMulEquivProd hpq) h
  rw [crtSqrtOne, MulEquiv.apply_symm_apply, unitsMulEquivProd_neg_one hpq] at this
  exact neg_one_ne_one_units p hp (congrArg Prod.fst this).symm

/-! ### From a residue witness to a prime factor -/

/-- **The residue/order coordinate is sufficient.**  For a semiprime `N = p*q` built from
distinct odd primes there is an explicit integer `a` with `a² ≡ 1`, `a ≢ ±1 (mod N)`; the
single gcd `gcd(a-1, N)` is then one of the two prime factors.

This is the exact content of the quantum bypass: Shor's algorithm produces such an `a` from
one coherent superposition, and the classical post-processing below is unconditional. -/
theorem residue_witness_factors [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q)
    (hp : p ≠ 2) (hq : q ≠ 2) :
    ∃ a : ℤ, ((p * q : ℕ) : ℤ) ∣ a ^ 2 - 1 ∧
      ¬ ((p * q : ℕ) : ℤ) ∣ (a - 1) ∧ ¬ ((p * q : ℕ) : ℤ) ∣ (a + 1) ∧
      (Int.gcd (a - 1) ((p * q : ℕ) : ℤ) = p ∨ Int.gcd (a - 1) ((p * q : ℕ) : ℤ) = q) := by
  have hp' : p.Prime := Fact.out
  have hq' : q.Prime := Fact.out
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp'.pos.ne' hq'.pos.ne'⟩
  set w : (ZMod (p * q))ˣ := crtSqrtOne hpq with hw
  set a : ℤ := ((w : ZMod (p * q)).val : ℤ) with ha
  have hcast : ((a : ZMod (p * q))) = (w : ZMod (p * q)) := by
    rw [ha]; push_cast; rw [ZMod.natCast_val, ZMod.cast_id]
  have hsq : ((a ^ 2 : ℤ) : ZMod (p * q)) = 1 := by
    push_cast
    rw [hcast, ← Units.val_pow_eq_pow_val, crtSqrtOne_sq hpq, Units.val_one]
  have hdvd_sq : ((p * q : ℕ) : ℤ) ∣ a ^ 2 - 1 := by
    refine (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mp ?_
    push_cast at hsq ⊢
    rw [hsq]; ring
  have hm : ¬ ((p * q : ℕ) : ℤ) ∣ (a - 1) := by
    intro hdiv
    have h0 : ((a - 1 : ℤ) : ZMod (p * q)) = 0 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mpr hdiv
    push_cast at h0
    have : (w : ZMod (p * q)) = 1 := by rw [← hcast]; linear_combination h0
    exact crtSqrtOne_ne_one hpq hq (Units.ext this)
  have hpl : ¬ ((p * q : ℕ) : ℤ) ∣ (a + 1) := by
    intro hdiv
    have h0 : ((a + 1 : ℤ) : ZMod (p * q)) = 0 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ _).mpr hdiv
    push_cast at h0
    have : (w : ZMod (p * q)) = -1 := by rw [← hcast]; linear_combination h0
    exact crtSqrtOne_ne_neg_one hpq hp (Units.ext (by simpa using this))
  refine ⟨a, hdvd_sq, hm, hpl, ?_⟩
  refine congruence_of_squares_factors_semiprime hp' hq' ?_ ?_ hm hpl
  · exact one_lt_mul_of_lt_of_le hp'.one_lt hq'.one_lt.le
  · have : (a - 1) * (a + 1) = a ^ 2 - 1 := by ring
    rw [this]; exact hdvd_sq

/-- **The witness is not rare.**  By the trace lemma there are exactly four square roots of
unity modulo `N = p*q`; two of them (`±1`) are useless and the other two each split `N`.
The quantum advantage is therefore *not* in the trace lemma — the coordinate is classified
and its population is known exactly — but in locating the witness, i.e. in barrier 4. -/
theorem sqrt_one_population [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q)
    (hp : p ≠ 2) (hq : q ≠ 2) :
    freeWitness (p * q) 2 = 4 ∧ (crtSqrtOne hpq) ^ 2 = 1 ∧
      crtSqrtOne hpq ≠ 1 ∧ crtSqrtOne hpq ≠ -1 :=
  ⟨freeWitness_two p q hpq hp hq, crtSqrtOne_sq hpq, crtSqrtOne_ne_one hpq hq,
    crtSqrtOne_ne_neg_one hpq hp⟩

end Round10