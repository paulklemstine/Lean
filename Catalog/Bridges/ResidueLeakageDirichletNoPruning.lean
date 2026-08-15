/-
# The Residue-Leakage Curve and the Dirichlet No-Pruning Theorem

Phase A research file (Bridges domain): bridging **quadratic residue theory /
Jacobi symbols**, **analytic number theory (Dirichlet's theorem on primes in
arithmetic progressions)** and **information-theoretic search pruning**.

## Setting

For a finite list `A` of primes (think: the first `K` primes `2,3,5,7,11,...`)
the *QR fingerprint* of `N` is
`F_A(N) = [ (a | N) : a ∈ A ]`, a list of Jacobi symbols; every entry is
computable in `poly(log N)` time, so `F_A` is the maximal *cheap* residue handle
attached to `N`.

The experimental claim under test (experiment QRLEAK) was:

* `F_A` has full discriminative power (on a finite sample it separates all `N`),
* but it yields **zero** reduction of the factor-candidate set.

We prove the second half as a theorem, and we *refute* the naive reading of the
first half: `F_A` is periodic modulo `4 * ∏ A`, hence massively non-injective —
every realised fingerprint class already contains infinitely many primes.

## Main results

* `qrFingerprint_mul` — the fingerprint is multiplicative in the modulus
  (the "symmetric residue structure": `F(pq) = F(p)·F(q)` entrywise).
* `qrFingerprint_of_modEq` — the fingerprint only depends on `N mod 4·∏A`
  (the conductor bound; for `A` containing `2` this is the classical `8·∏ a_i`).
* `infinite_primes_jacobi_eq` — **key lemma**: every residue-symbol pattern
  realised by *some* odd `N` coprime to `A` is realised by *infinitely many
  primes*.  (Dirichlet.)
* `dirichlet_no_pruning` — **main theorem**: for every `N₀` and *every* candidate
  prime `p`, there are infinitely many primes `q` with `F_A(p·q) = F_A(N₀)`.
  The fingerprint prunes nothing.
* `qrFingerprint_class_infinite` — the fingerprint is not a collision-free hash:
  each realised class contains infinitely many primes.
-/

import Mathlib

namespace Bridges.ResidueLeakage

/-! ## Definitions -/

/-- The QR fingerprint of `N` relative to a list `A` of "probe" primes:
the list of Jacobi symbols `(a | N)` for `a ∈ A`. -/
def qrFingerprint (A : List ℕ) (N : ℕ) : List ℤ :=
  A.map (fun a : ℕ => jacobiSym (a : ℤ) N)

/-- The conductor of the fingerprint: `4 * ∏ a`.  If `2 ∈ A` this is the
classical `8 * ∏_{a odd} a`. -/
def qrConductor (A : List ℕ) : ℕ := 4 * A.prod

/-- The list of the first `K` primes, `[2,3,5,7,...]`. -/
noncomputable def primeBasis (K : ℕ) : List ℕ :=
  (List.range K).map (Nat.nth Nat.Prime)

@[simp] theorem primeBasis_length (K : ℕ) : (primeBasis K).length = K := by
  simp [primeBasis]

theorem primeBasis_prime {K a : ℕ} (ha : a ∈ primeBasis K) : a.Prime := by
  simp only [primeBasis, List.mem_map] at ha
  obtain ⟨i, _, rfl⟩ := ha
  exact Nat.prime_nth_prime i

/-! ## Basic structure of the fingerprint -/

@[simp] theorem qrFingerprint_length (A : List ℕ) (N : ℕ) :
    (qrFingerprint A N).length = A.length := by
  simp [qrFingerprint]

/-- Entrywise criterion for two fingerprints to agree. -/
theorem qrFingerprint_congr {A : List ℕ} {m n : ℕ}
    (h : ∀ a ∈ A, jacobiSym (a : ℤ) m = jacobiSym (a : ℤ) n) :
    qrFingerprint A m = qrFingerprint A n :=
  List.map_congr_left h

/-- **Multiplicativity.**  The fingerprint of a product is the entrywise product
of the fingerprints: this is exactly the "symmetric residue structure" that a
semiprime `N = p·q` leaks. -/
theorem qrFingerprint_mul (A : List ℕ) {m n : ℕ} (hm : m ≠ 0) (hn : n ≠ 0) :
    qrFingerprint A (m * n) =
      List.zipWith (· * ·) (qrFingerprint A m) (qrFingerprint A n) := by
  have : NeZero m := ⟨hm⟩
  have : NeZero n := ⟨hn⟩
  induction A with
  | nil => simp [qrFingerprint]
  | cons a t ih =>
      simp only [qrFingerprint, List.map_cons, List.zipWith_cons_cons] at *
      rw [jacobiSym.mul_right (a : ℤ) m n, ih]

/-- **Conductor / periodicity.**  The fingerprint of an odd number depends only
on its residue class modulo `4 * ∏ A`. -/
theorem qrFingerprint_of_modEq {A : List ℕ} {m n : ℕ} (hm : Odd m) (hn : Odd n)
    (h : m ≡ n [MOD qrConductor A]) :
    qrFingerprint A m = qrFingerprint A n := by
  refine qrFingerprint_congr fun a ha => ?_
  have hdvd : 4 * a ∣ qrConductor A := mul_dvd_mul_left 4 (List.dvd_prod ha)
  have h' : m % (4 * a) = n % (4 * a) := h.of_dvd hdvd
  rw [jacobiSym.mod_right' a hm, jacobiSym.mod_right' a hn, h']

/-! ## Coprimality bookkeeping -/

theorem coprime_list_prod {A : List ℕ} {m : ℕ} (h : ∀ a ∈ A, Nat.Coprime m a) :
    Nat.Coprime m A.prod := by
  induction A with
  | nil => simp
  | cons a t ih =>
      simp only [List.prod_cons]
      exact Nat.Coprime.mul_right (h a (by simp))
        (ih fun b hb => h b (by simp [hb]))

theorem coprime_conductor {A : List ℕ} {m : ℕ} (hm : Odd m)
    (h : ∀ a ∈ A, Nat.Coprime m a) : Nat.Coprime m (qrConductor A) := by
  have h2 : Nat.Coprime m 4 := by
    have h2' : Nat.Coprime m 2 := Nat.coprime_two_right.2 hm
    have := h2'.pow_right 2
    norm_num at this
    exact this
  exact Nat.Coprime.mul_right h2 (coprime_list_prod h)

theorem prod_ne_zero_of_prime {A : List ℕ} (hA : ∀ a ∈ A, a.Prime) :
    A.prod ≠ 0 := by
  induction A with
  | nil => simp
  | cons a t ih =>
      have ha : a.Prime := hA a (by simp)
      have ht : t.prod ≠ 0 := ih fun b hb => hA b (by simp [hb])
      simpa [List.prod_cons] using mul_ne_zero ha.ne_zero ht

theorem conductor_ne_zero (A : List ℕ) (hA : ∀ a ∈ A, a.Prime) :
    qrConductor A ≠ 0 := by
  simpa [qrConductor] using prod_ne_zero_of_prime hA

/-! ## The Dirichlet realisation lemma -/

/-- **Key lemma (Dirichlet).**  Any pattern of Jacobi symbols realised by an odd
number `m` coprime to the probe primes is realised by infinitely many *primes*.

This is the analytic input: each entry of the fingerprint is a character of the
group `(ℤ/4∏A)ˣ`, and Dirichlet's theorem populates every unit class with
infinitely many primes. -/
theorem infinite_primes_jacobi_eq {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    {m : ℕ} (hm : Odd m) (hcop : ∀ a ∈ A, Nat.Coprime m a) :
    {q : ℕ | q.Prime ∧ Odd q ∧
      ∀ a ∈ A, jacobiSym (a : ℤ) q = jacobiSym (a : ℤ) m}.Infinite := by
  set M := qrConductor A with hM
  have hM0 : M ≠ 0 := conductor_ne_zero A hA
  have : NeZero M := ⟨hM0⟩
  have hunit : IsUnit ((m : ZMod M)) :=
    (ZMod.isUnit_iff_coprime m M).2 (coprime_conductor hm hcop)
  refine (Nat.infinite_setOf_prime_and_eq_mod hunit).mono ?_
  rintro q ⟨hq, hqm⟩
  have hmod : q ≡ m [MOD M] := (ZMod.natCast_eq_natCast_iff q m M).1 hqm
  have h2 : (2 : ℕ) ∣ M := ⟨2 * A.prod, by rw [hM, qrConductor]; ring⟩
  have hq2 : q % 2 = m % 2 := hmod.of_dvd h2
  have hqodd : Odd q := by
    rw [Nat.odd_iff] at hm ⊢; omega
  refine ⟨hq, hqodd, fun a ha => ?_⟩
  have hdvd : 4 * a ∣ M := mul_dvd_mul_left 4 (List.dvd_prod ha)
  have h' : q % (4 * a) = m % (4 * a) := hmod.of_dvd hdvd
  rw [jacobiSym.mod_right' a hqodd, jacobiSym.mod_right' a hm, h']

/-- Restated for fingerprints: every realised fingerprint class contains
infinitely many primes.  In particular `F_A` is *not* a collision-free hash of
`N`, contrary to the finite-sample reading of the experiment. -/
theorem qrFingerprint_class_infinite {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    {m : ℕ} (hm : Odd m) (hcop : ∀ a ∈ A, Nat.Coprime m a) :
    {q : ℕ | q.Prime ∧ qrFingerprint A q = qrFingerprint A m}.Infinite := by
  refine (infinite_primes_jacobi_eq hA hm hcop).mono ?_
  rintro q ⟨hq, -, hsym⟩
  exact ⟨hq, qrFingerprint_congr hsym⟩

/-! ## Main theorem: no pruning -/

private theorem jacobi_prime_sq {a p : ℕ} (ha : a.Prime) (hp : p.Prime)
    (hne : a ≠ p) : jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) p = 1 := by
  have hcop : Int.gcd (a : ℤ) (p : ℕ) = 1 := by
    simpa [Int.gcd_natCast_natCast] using (Nat.coprime_primes ha hp).2 hne
  rcases jacobiSym.eq_one_or_neg_one hcop with h | h <;> rw [h] <;> norm_num

/-- **Dirichlet no-pruning theorem.**
Fix any target `N₀` (odd, coprime to the probe primes) and *any* candidate prime
`p` (odd, not itself a probe prime).  Then there are infinitely many primes `q`
such that the semiprime `p * q` has exactly the same QR fingerprint as `N₀`.

Consequently the observed fingerprint `F_A(N₀)`, however many probe primes it
uses, removes **no** candidate prime `p` from the divisor search: every `p`
remains consistent with the residue data.  The cheap residue channel has zero
pruning power. -/
theorem dirichlet_no_pruning {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    {N₀ p : ℕ} (hN₀ : Odd N₀) (hp : p.Prime) (hpodd : Odd p)
    (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) (hpA : ∀ a ∈ A, a ≠ p) :
    {q : ℕ | q.Prime ∧ qrFingerprint A (p * q) = qrFingerprint A N₀}.Infinite := by
  have hp0 : p ≠ 0 := hp.ne_zero
  have hN0 : N₀ ≠ 0 := by rintro rfl; simp at hN₀
  set m := N₀ * p with hmdef
  have hmodd : Odd m := hN₀.mul hpodd
  have hmcop : ∀ a ∈ A, Nat.Coprime m a := fun a ha =>
    Nat.Coprime.mul_left (hNA a ha)
      ((Nat.coprime_primes hp (hA a ha)).2 (fun h => hpA a ha h.symm))
  refine (infinite_primes_jacobi_eq hA hmodd hmcop).mono ?_
  rintro q ⟨hq, hqodd, hsym⟩
  have hq0 : q ≠ 0 := hq.ne_zero
  have hNZp : NeZero p := ⟨hp0⟩
  have hNZq : NeZero q := ⟨hq0⟩
  have hNZN : NeZero N₀ := ⟨hN0⟩
  refine ⟨hq, qrFingerprint_congr fun a ha => ?_⟩
  calc jacobiSym (a : ℤ) (p * q)
      = jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) q := jacobiSym.mul_right _ _ _
    _ = jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) (N₀ * p) := by rw [hsym a ha]
    _ = jacobiSym (a : ℤ) N₀ * (jacobiSym (a : ℤ) p * jacobiSym (a : ℤ) p) := by
        rw [jacobiSym.mul_right (a : ℤ) N₀ p]; ring
    _ = jacobiSym (a : ℤ) N₀ := by
        rw [jacobi_prime_sq (hA a ha) hp (hpA a ha), mul_one]

/-- Existence form of the no-pruning theorem, matching the statement of the
QRLEAK experiment: *for any `N₀` and any candidate prime `p` there is a
compensating prime `q` with the same fingerprint.* -/
theorem exists_compensating_prime {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    {N₀ p : ℕ} (hN₀ : Odd N₀) (hp : p.Prime) (hpodd : Odd p)
    (hNA : ∀ a ∈ A, Nat.Coprime N₀ a) (hpA : ∀ a ∈ A, a ≠ p) :
    ∃ q : ℕ, q.Prime ∧ qrFingerprint A (p * q) = qrFingerprint A N₀ := by
  obtain ⟨q, hq⟩ := (dirichlet_no_pruning hA hN₀ hp hpodd hNA hpA).nonempty
  exact ⟨q, hq.1, hq.2⟩

end Bridges.ResidueLeakage