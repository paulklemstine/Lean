import Novelty.SymmetryBreakingCostKernel

/-!
# The witness always exists: information present, search sealed

Cycles 1–3 measured the two classical resources.  This fourth cycle closes the loop on the
*asymmetric* side by showing that the object Shor's algorithm hunts for is never missing:

* `exists_nontrivial_sqrt_one` : every odd semiprime `N = p q` admits an explicit `x` with
  `x² ≡ 1 (mod N)` and `x ≢ ±1 (mod N)` — built by the Chinese remainder theorem, exactly the
  same freedom that makes the residue oracle cheap.
* `gcd_witness_eq_prime` : for that witness, `gcd(x - 1, N) = p` **on the nose**; one gcd
  recovers the factor.
* `factor_of_any_nontrivial_sqrt` : conversely *every* nontrivial square root of `1` mod `N`
  factors `N` — `gcd(z - 1, N)` is `p` or `q`, there is no third kind of witness.
* `symmetry_breaking_cost_table` : the three measurements side by side for an odd semiprime —
  the oracle cost is exactly `⌈log₂ |S|⌉`, the public battery excludes no candidate at all, and
  an asymmetric witness that factors `N` in one gcd exists.

The moral of the measurement: for every odd semiprime, factoring data is *present* in the
arithmetic (a residue signature isolating `p₀` in `⌈log₂ |S|⌉` bits, a square root of unity
revealing `p` in one gcd).  What is missing is a symmetry-breaking *resource* that points at it;
the classical public data `[(a | N)]` is provably blind (cycle 2), and this is what the quantum
order-finding channel buys.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 4): the nontrivial square roots of unity are never rare or
absent — the obstruction is purely search, never existence.

Experiment (Experimenter): for `(p, q) = (3,5), (3,7), (3,11), (5,7), (7,11), (11,13)` the CRT
witness `x ≡ 1 mod p`, `x ≡ -1 mod q` is `x = 4, 13, 10, 6, 43, 12`; in every case `x² ≡ 1 mod
N` and `gcd(x - 1, N) = p`, i.e. `3, 3, 3, 5, 7, 11`, confirming the two theorems below on
concrete inputs.

Analysis (Analyst): the construction and the oracle construction of cycle 1 are the *same*
mechanism — prescribing independent local data and gluing by CRT.  What differs is whether the
prescribed data is readable from `N`: the local Legendre symbols and the local square roots are
both invisible to the symmetric battery, by the kernel theorem of cycle 2.

Critique (Critic): `gcd_witness_eq_prime` must not be vacuous, so the witness is produced
explicitly rather than assumed, and the hypotheses are only `p ≠ q` odd primes; the numerical
run above checks the statement on six semiprimes.
-/

namespace SymmetryBreakingCost

open Finset
open scoped NumberTheorySymbols

/-- **The witness always exists.**  For distinct odd primes `p ≠ q` there is an integer `x` with
`p ∣ x - 1` and `q ∣ x + 1`; it is a square root of `1` modulo `N = p q` that is neither `1` nor
`-1`. -/
theorem exists_nontrivial_sqrt_one {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) :
    ∃ x : ℤ, (p : ℤ) ∣ x - 1 ∧ (q : ℤ) ∣ x + 1 ∧
      ((p * q : ℕ) : ℤ) ∣ x ^ 2 - 1 ∧ ¬((p * q : ℕ) : ℤ) ∣ x - 1 ∧ ¬((p * q : ℕ) : ℤ) ∣ x + 1 := by
  classical
  have hcop : (({p, q} : Finset ℕ) : Set ℕ).Pairwise Nat.Coprime := by
    intro x hx y hy hxy
    simp only [Finset.coe_insert, Finset.coe_singleton, Set.mem_insert_iff,
      Set.mem_singleton_iff] at hx hy
    rcases hx with rfl | rfl <;> rcases hy with rfl | rfl <;>
      first
        | exact absurd rfl hxy
        | exact (Nat.coprime_primes hp hq).mpr hpq
        | exact (Nat.coprime_primes hq hp).mpr (Ne.symm hpq)
  obtain ⟨x, hx⟩ := crt_finset {p, q} hcop (fun r => if r = p then 1 else -1)
  have hxp : (p : ℤ) ∣ x - 1 := by simpa using hx p (by simp)
  have hxq : (q : ℤ) ∣ x + 1 := by
    have := hx q (by simp)
    rw [if_neg (Ne.symm hpq)] at this
    simpa [sub_neg_eq_add] using this
  have hp2' : ¬((p : ℤ) ∣ 2) := by
    intro h
    have : p ∣ 2 := by exact_mod_cast h
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp this)
  have hq2' : ¬((q : ℤ) ∣ 2) := by
    intro h
    have : q ∣ 2 := by exact_mod_cast h
    exact hq2 ((Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp this)
  refine ⟨x, hxp, hxq, ?_, ?_, ?_⟩
  · have : ((p * q : ℕ) : ℤ) = (p : ℤ) * (q : ℤ) := by push_cast; ring
    rw [this, show x ^ 2 - 1 = (x - 1) * (x + 1) by ring]
    exact mul_dvd_mul hxp hxq
  · intro hdvd
    have hqd : (q : ℤ) ∣ x - 1 := dvd_trans ⟨(p : ℤ), by push_cast; ring⟩ hdvd
    exact hq2' (by simpa using dvd_sub hxq hqd)
  · intro hdvd
    have hpd : (p : ℤ) ∣ x + 1 := dvd_trans ⟨(q : ℤ), by push_cast; ring⟩ hdvd
    exact hp2' (by simpa using dvd_sub hpd hxp)

/-- If `w` is divisible by `p` but not by `q` (both prime), its gcd with `p q` is exactly `p`. -/
theorem gcd_eq_prime_of_dvd {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {w : ℤ} (hpw : (p : ℤ) ∣ w)
    (hqw : ¬(q : ℤ) ∣ w) : Int.gcd w ((p * q : ℕ) : ℤ) = p := by
  set d : ℕ := Int.gcd w ((p * q : ℕ) : ℤ) with hd
  have hdvdN : d ∣ p * q := by
    have := Int.gcd_dvd_right w ((p * q : ℕ) : ℤ)
    exact_mod_cast this
  have hpd : p ∣ d :=
    Nat.dvd_gcd (Int.natCast_dvd_natCast.mp (by simpa using Int.dvd_natAbs.mpr hpw))
      (by simp [Int.natAbs_mul])
  have hqnd : ¬q ∣ d := by
    intro hqd
    exact hqw (((Int.natCast_dvd_natCast.mpr hqd).trans (Int.gcd_dvd_left w ((p * q : ℕ) : ℤ))))
  obtain ⟨e, he⟩ := hpd
  have hedvd : e ∣ q := (mul_dvd_mul_iff_left hp.ne_zero).mp (he ▸ hdvdN)
  rcases hq.eq_one_or_self_of_dvd e hedvd with rfl | rfl
  · simpa using he
  · exact absurd (he ▸ Dvd.intro_left p rfl) hqnd

/-- **One gcd recovers the factor.**  For the CRT witness of `exists_nontrivial_sqrt_one`,
`gcd(x - 1, p q) = p` exactly. -/
theorem gcd_witness_eq_prime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2) (hq2 : q ≠ 2)
    (hpq : p ≠ q) : ∃ x : ℤ, ((p * q : ℕ) : ℤ) ∣ x ^ 2 - 1 ∧ ¬((p * q : ℕ) : ℤ) ∣ x - 1 ∧
      ¬((p * q : ℕ) : ℤ) ∣ x + 1 ∧ Int.gcd (x - 1) ((p * q : ℕ) : ℤ) = p := by
  obtain ⟨x, hxp, hxq, hsq, hne1, hne2⟩ := exists_nontrivial_sqrt_one hp hq hp2 hq2 hpq
  refine ⟨x, hsq, hne1, hne2, gcd_eq_prime_of_dvd hp hq hxp (fun hq1 => ?_)⟩
  have : (q : ℤ) ∣ 2 := by simpa using dvd_sub hxq hq1
  have : q ∣ 2 := by exact_mod_cast this
  exact hq2 ((Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp this)

/-- **The measurement, assembled.**  For an odd semiprime `N = p q` and a candidate set `S` of
odd primes containing the hidden factor `p`:

1. the residue **oracle** isolates every candidate at a cost of exactly `⌈log₂ |S|⌉` queries;
2. the **public** Jacobi battery of `N` excludes no candidate whatsoever — each `r ∈ S` sits
   inside a modulus with literally the same battery;
3. an **asymmetric** witness exists that yields `p` from one gcd.

The gap between 1 and 2 is the symmetry-breaking cost; 3 is what the quantum channel pays for. -/
theorem symmetry_breaking_cost_table {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) (S : Finset ℕ) (hS : ∀ r ∈ S, r.Prime ∧ r ≠ 2) :
    IsLeast (IsolationCost S) (Nat.clog 2 S.card) ∧
    (∀ r ∈ S, ∃ M : ℕ, r ∣ M ∧ sqKernel M = sqKernel (p * q) ∧
      ∀ a : ℤ, Int.gcd a (M * (p * q)) = 1 → J(a | M) = J(a | p * q)) ∧
    (∃ x : ℤ, Int.gcd (x - 1) ((p * q : ℕ) : ℤ) = p) := by
  refine ⟨isolationCost_isLeast S hS, ?_, ?_⟩
  · intro r hr
    obtain ⟨hrp, hr2⟩ := hS r hr
    have hNo : Odd (p * q) := (hp.odd_of_ne_two hp2).mul (hq.odd_of_ne_two hq2)
    obtain ⟨M, hdvd, -, hker, hbat⟩ :=
      zero_pruning_sharp (p * q) r (Nat.mul_ne_zero hp.ne_zero hq.ne_zero) hrp.ne_zero hNo
        (hrp.odd_of_ne_two hr2)
    exact ⟨M, hdvd, hker, hbat⟩
  · obtain ⟨x, -, -, -, hgcd⟩ := gcd_witness_eq_prime hp hq hp2 hq2 hpq
    exact ⟨x, hgcd⟩

/-! ## Cycle 5.  Every nontrivial square root factors, and there is no third kind -/

/-- **Classification of the witnesses.**  Modulo an odd semiprime `p q`, a square root of `1`
splits the two primes: it is congruent to `1` at one of them and to `-1` at the other, unless it
is globally `±1`.  Consequently *every* nontrivial square root of unity factors `N`, with
`gcd(z - 1, N)` equal to `p` or to `q`. -/
theorem factor_of_any_nontrivial_sqrt {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (hpq : p ≠ q) {z : ℤ} (hz : ((p * q : ℕ) : ℤ) ∣ z ^ 2 - 1)
    (h1 : ¬((p * q : ℕ) : ℤ) ∣ z - 1) (h2 : ¬((p * q : ℕ) : ℤ) ∣ z + 1) :
    Int.gcd (z - 1) ((p * q : ℕ) : ℤ) = p ∨ Int.gcd (z - 1) ((p * q : ℕ) : ℤ) = q := by
  have hcast : ((p * q : ℕ) : ℤ) = (p : ℤ) * (q : ℤ) := by push_cast; ring
  have hfac : (z - 1) * (z + 1) = z ^ 2 - 1 := by ring
  have hpprime : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
  have hqprime : Prime (q : ℤ) := Nat.prime_iff_prime_int.mp hq
  have hcopZ : IsCoprime ((p : ℤ)) ((q : ℤ)) := by
    rw [Int.isCoprime_iff_gcd_eq_one]
    simpa [Int.gcd_natCast_natCast] using (Nat.coprime_primes hp hq).mpr hpq
  have hpz : (p : ℤ) ∣ (z - 1) * (z + 1) := by
    rw [hfac]
    exact dvd_trans (by rw [hcast]; exact Dvd.intro (q : ℤ) rfl) hz
  have hqz : (q : ℤ) ∣ (z - 1) * (z + 1) := by
    rw [hfac]
    exact dvd_trans (by rw [hcast]; exact Dvd.intro_left (p : ℤ) rfl) hz
  have hnot2p : ¬((p : ℤ) ∣ 2) := by
    intro h
    exact hp2 ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp (by exact_mod_cast h))
  have hnot2q : ¬((q : ℤ) ∣ 2) := by
    intro h
    exact hq2 ((Nat.prime_dvd_prime_iff_eq hq Nat.prime_two).mp (by exact_mod_cast h))
  rcases hpprime.dvd_mul.mp hpz with hpm | hpp <;> rcases hqprime.dvd_mul.mp hqz with hqm | hqp
  · exact absurd (by rw [hcast]; exact hcopZ.mul_dvd hpm hqm) h1
  · exact Or.inl (gcd_eq_prime_of_dvd hp hq hpm (fun hc => hnot2q (by simpa using dvd_sub hqp hc)))
  · refine Or.inr ?_
    rw [Nat.mul_comm]
    exact gcd_eq_prime_of_dvd hq hp hqm (fun hc => hnot2p (by simpa using dvd_sub hpp hc))
  · exact absurd (by rw [hcast]; exact hcopZ.mul_dvd hpp hqp) h2

end SymmetryBreakingCost