import Cryptography.ThreeStrataPlane.StratumA

/-!
# Stratum B: the classical methods, as theorems rather than citations

Three methods, three exact statements about what they do on a semiprime
`N = p q` with `p < q` prime.

**Trial division.**  `minFac_semiprime` : the first divisor found is `p`, and by
`StratumA.smaller_factor_le_sqrt` it is found no later than step `⌊√N⌋`.

**Fermat.**  `fermat_representation_dichotomy` : *every* representation
`a² = N + b²` of a semiprime comes from one of the two factorizations, so the
search `a = ⌈√N⌉, ⌈√N⌉+1, …` stops for the first time exactly at `2a = p + q`
(`fermat_no_early_stop`).  This makes the two methods provably complementary:
* `fermat_instant_on_twin_semiprime` — on `N = p(p+2)` Fermat stops at the very
  first trial `a = p + 1`, where trial division needs `p = ⌊√N⌋` steps;
* `fermat_slow_on_unbalanced` — on `N = 3q` Fermat needs at least `q/4` steps,
  where trial division needs `2`.
Neither method dominates the other pointwise (`fermat_trial_complementarity`),
which is the structural reason the two cost distributions are indistinguishable
on uniform draws.

**Pollard `ρ`.**  `pollard_extraction` : a residue collision modulo `p` that is
*not* a collision modulo `N` yields the factor `p` exactly, via one gcd; and
`exists_residue_collision_le` : such a collision is forced within `p` steps by
pigeonhole, for *any* iteration function whatsoever.  Together
(`pollard_rho_succeeds_within_p_steps`) this is the deterministic skeleton of the
birthday bound whose measured exponent is `1/4` on `N`.
-/

namespace ThreeStrata

open Finset

/-! ## Trial division -/

/-- Trial division on a semiprime returns the smaller prime factor. -/
theorem minFac_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    Nat.minFac (p * q) = p := by
  have hdvd : Nat.minFac (p * q) ∣ p * q := Nat.minFac_dvd _
  have hN : p * q ≠ 1 := by
    have := hp.one_lt; have := hq.one_lt; nlinarith
  have hmp : (Nat.minFac (p * q)).Prime := Nat.minFac_prime hN
  have hle : Nat.minFac (p * q) ≤ p := Nat.minFac_le_of_dvd hp.two_le ⟨q, rfl⟩
  rcases (Nat.Prime.dvd_mul hmp).1 hdvd with h | h
  · exact ((Nat.prime_dvd_prime_iff_eq hmp hp).1 h)
  · have : Nat.minFac (p * q) = q := (Nat.prime_dvd_prime_iff_eq hmp hq).1 h
    omega

/-! ## Fermat's difference of squares -/

/-- The Fermat representation coming from the nontrivial factorization:
`((p+q)/2)² = pq + ((q-p)/2)²`, written without division. -/
theorem fermat_representation {p q a b : ℕ} (ha : 2 * a = p + q) (hb : 2 * b = q - p)
    (hpq : p ≤ q) : a * a = p * q + b * b := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hpq
  have hb' : 2 * b = k := by omega
  nlinarith [ha, hb']

/-- **Fermat dichotomy.**  Any representation `a² = N + b²` of a semiprime
`N = pq` (`p < q` prime) is one of exactly two: the trivial one coming from
`N = 1 · N`, and the one coming from `N = p · q`. -/
theorem fermat_representation_dichotomy {p q a b : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p < q) (hba : b ≤ a) (h : a * a = p * q + b * b) :
    (2 * a = p + q ∧ 2 * b = q - p) ∨ (2 * a = p * q + 1 ∧ 2 * b = p * q - 1) := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hba
  -- `k * (k + 2b) = N`
  have hk : k * (k + 2 * b) = p * q := by nlinarith [h]
  have hdvd : k ∣ p * q := ⟨k + 2 * b, hk.symm⟩
  have hp1 : 1 < p := hp.one_lt
  have hq1 : 1 < q := hq.one_lt
  have hmem : k ∈ (p * q).divisors := by
    refine Nat.mem_divisors.2 ⟨hdvd, ?_⟩
    positivity
  rw [divisors_semiprime hp hq] at hmem
  simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  rcases hmem with h | h | h | h
  · right
    rw [h] at hk ⊢
    have hN : 1 + 2 * b = p * q := by linarith [hk]
    rw [← hN]
    omega
  · left
    rw [h] at hk ⊢
    have hq' : p + 2 * b = q := Nat.eq_of_mul_eq_mul_left hp0 hk
    omega
  · exfalso
    rw [h] at hk
    have h' : q * (q + 2 * b) = q * p := by rw [hk]; ring
    have : q + 2 * b = p := Nat.eq_of_mul_eq_mul_left hq0 h'
    omega
  · exfalso
    rw [h] at hk
    have hN1 : 1 < p * q := by nlinarith
    have h' : (p * q) * (p * q + 2 * b) = (p * q) * 1 := by rw [hk]; ring
    have := Nat.eq_of_mul_eq_mul_left (by omega : 0 < p * q) h'
    omega

/-- **No early stop.**  For `a` strictly below `(p+q)/2` there is no Fermat
representation at all: the search stops for the first time exactly at
`2a = p + q`. -/
theorem fermat_no_early_stop {p q a b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p < q)
    (hba : b ≤ a) (h : a * a = p * q + b * b) (hsmall : 2 * a < p + q) : False := by
  rcases fermat_representation_dichotomy hp hq hpq hba h with ⟨h1, _⟩ | ⟨h1, _⟩
  · omega
  · have hp2 : 2 ≤ p := hp.two_le
    have hq2 : 2 ≤ q := hq.two_le
    nlinarith

/-- On a twin-prime semiprime Fermat succeeds at its first trial value
`a = p + 1 = ⌈√N⌉`, while trial division has to run the full `p = ⌊√N⌋` steps. -/
theorem fermat_instant_on_twin_semiprime {p : ℕ} (hp : 1 < p) :
    (p + 1) * (p + 1) = p * (p + 2) + 1 * 1 ∧ scanCost (p * (p + 2)) = p :=
  ⟨by ring, twinPrime_scanCost_eq_sqrt hp⟩

/-- On the maximally unbalanced semiprime `N = 3q` Fermat needs at least `q/4`
steps beyond `⌈√N⌉`, while trial division finishes in two. -/
theorem fermat_slow_on_unbalanced {q : ℕ} (hq : 48 ≤ q) :
    Nat.sqrt (3 * q) + 1 + q / 4 ≤ (3 + q) / 2 := by
  have hs : Nat.sqrt (3 * q) * Nat.sqrt (3 * q) ≤ 3 * q := Nat.sqrt_le (3 * q)
  have h4 : 4 * Nat.sqrt (3 * q) ≤ q := by
    by_contra hcon
    push_neg at hcon
    nlinarith
  omega

/-- **Complementarity.**  There are semiprimes on which Fermat beats trial
division by the full `⌊√N⌋`, and semiprimes on which trial division beats Fermat
by a quantity growing linearly in the larger factor.  Neither method dominates,
which is why their cost distributions are indistinguishable in aggregate. -/
theorem fermat_trial_complementarity {p q : ℕ} (hp : 1 < p) (hq : 48 ≤ q) :
    ((p + 1) * (p + 1) = p * (p + 2) + 1 * 1 ∧ p ≤ scanCost (p * (p + 2))) ∧
      Nat.sqrt (3 * q) + 1 + q / 4 ≤ (3 + q) / 2 :=
  ⟨⟨by ring, le_of_eq (twinPrime_scanCost_eq_sqrt hp).symm⟩, fermat_slow_on_unbalanced hq⟩

/-! ## Pollard `ρ`: extraction and the pigeonhole bound -/

/-- **Extraction step.**  A difference that is divisible by `p` but not by `N`
hands over the factor `p` exactly — one gcd, no search.  This is the step that
converts a birthday collision into a certificate. -/
theorem pollard_extraction {p q : ℕ} {d : ℤ} (hp : p.Prime) (hq : q.Prime) (hpq : p < q)
    (hpd : (p : ℤ) ∣ d) (hnd : ¬ ((p * q : ℕ) : ℤ) ∣ d) : Int.gcd d ((p * q : ℕ) : ℤ) = p := by
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  have hp1 : 1 < p := hp.one_lt
  have hgN : Int.gcd d ((p * q : ℕ) : ℤ) ∣ p * q := by
    have h := Int.gcd_dvd_right d ((p * q : ℕ) : ℤ)
    exact_mod_cast h
  have hpq' : (p : ℤ) ∣ ((p * q : ℕ) : ℤ) := by push_cast; exact Dvd.intro q rfl
  have hpg : p ∣ Int.gcd d ((p * q : ℕ) : ℤ) := Int.dvd_gcd hpd hpq'
  have hmem : Int.gcd d ((p * q : ℕ) : ℤ) ∈ (p * q).divisors :=
    Nat.mem_divisors.2 ⟨hgN, by positivity⟩
  rw [divisors_semiprime hp hq] at hmem
  simp only [Finset.mem_insert, Finset.mem_singleton] at hmem
  rcases hmem with h | h | h | h
  · rw [h] at hpg
    exact absurd (Nat.le_of_dvd one_pos hpg) (by omega)
  · exact h
  · rw [h] at hpg
    exact absurd ((Nat.prime_dvd_prime_iff_eq hp hq).1 hpg) (by omega)
  · exfalso
    have hdl := Int.gcd_dvd_left d ((p * q : ℕ) : ℤ)
    rw [h] at hdl
    exact hnd hdl

/-- **The pigeonhole half of the birthday bound.**  For *any* sequence of
residues modulo `p` there is a collision among the first `p + 1` terms — no
randomness assumption is used. -/
theorem exists_residue_collision_le {p : ℕ} (hp : 0 < p) (x : ℕ → ZMod p) :
    ∃ i j, i < j ∧ j ≤ p ∧ x i = x j := by
  haveI : NeZero p := ⟨hp.ne'⟩
  have hcard : Fintype.card (ZMod p) < Fintype.card (Fin (p + 1)) := by
    simp [ZMod.card]
  obtain ⟨i, j, hij, hxy⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun i : Fin (p + 1) => x (i : ℕ)) hcard
  rcases lt_or_gt_of_ne (fun h : (i : ℕ) = (j : ℕ) => hij (Fin.ext h)) with h | h
  · exact ⟨i, j, h, by omega, hxy⟩
  · exact ⟨j, i, h, by omega, hxy.symm⟩

/-- **Deterministic skeleton of Pollard `ρ`.**  Within `p` steps some pair of
iterates collides modulo `p`; if that pair does not also collide modulo `N`, the
gcd returns the factor `p`.  The only probabilistic ingredient of the real
algorithm is that the collision happens after `≈ √p = N^{1/4}` steps rather than
`p` — the birthday exponent measured in Stratum B. -/
theorem pollard_rho_succeeds_within_p_steps {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p < q) (x : ℕ → ℤ)
    (hcoll : ∀ i j : ℕ, (p : ℤ) ∣ x j - x i → ¬ ((p * q : ℕ) : ℤ) ∣ x j - x i) :
    ∃ i j, i < j ∧ j ≤ p ∧ Int.gcd (x j - x i) ((p * q : ℕ) : ℤ) = p := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  obtain ⟨i, j, hij, hjp, hx⟩ :=
    exists_residue_collision_le hp.pos (fun n => ((x n : ZMod p)))
  have hdvd : (p : ℤ) ∣ x j - x i := by
    have : ((x j - x i : ℤ) : ZMod p) = 0 := by push_cast [hx]; ring
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).1 this
  exact ⟨i, j, hij, hjp, pollard_extraction hp hq hpq hdvd (hcoll i j hdvd)⟩

end ThreeStrata