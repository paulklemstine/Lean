import Mathlib
import Novelty.QSNoDecouplingTheorem
/-!
# Large primes are split primes: the Legendre-symbol form of the LP no-decoupling theorem

Round 43 claims the large-prime / partial-relation (LP) variant of the quadratic sieve cannot
decouple the column count from the split set, because a large prime `r ∣ c² − N` forces
`(N/r) = +1`.  `QSNoDecoupling.largePrime_isSplit` already gives the `IsSquare` version.
This file adds the Legendre-symbol form and what follows from it:

* **Legendre form.**  `r ∣ c² − N`, `r ∤ N` ⟹ `legendreSym r N = 1`
  (`legendreSym_eq_one_of_dvd_qsValue`).  Inert primes (`(N/r) = −1`) never divide a value
  (`inert_never_divides`); the sieve hit count per period is exactly `1 + (N/r)`
  (`hitCount_eq_one_add_legendre`).  The same holds for every Silverman form of
  discriminant `D` (`QForm.legendreSym_disc_eq_one`).
* **Any number of large primes.**  Every prime factor of every nonzero value is split
  (`primeFactors_subset_admissible`).  So the columns of an LP-`k` relation matrix, for any
  `k`, lie inside `admissiblePrimes N L` (`lpColumns_subset_admissible`).
* **The LP variant grows `Q`.**  A large prime `r ∈ (B, L]` strictly enlarges the split set:
  `|admissiblePrimes N B| < |admissiblePrimes N L|` (`largePrime_strictly_enlarges_Q`).
* **Pairing.**  If there are more partial relations than distinct large primes, two of them
  share a large prime, and their product has its odd-exponent support in the *small* split
  set (`partial_pigeonhole_pair`).
* **Reciprocity: the split set is a union of residue classes mod `4N`.**  If `r ≡ r'
  (mod 4N)` are odd primes and `r ∤ N` divides some value, then so does `r'`
  (`split_periodic_mod_four_N`).  A large prime cannot be chosen to avoid the split
  condition; whether it is split depends only on its class mod `4N`.
* **Euler form.**  `N^((r−1)/2) ≡ 1 (mod r)` for every odd large prime `r ∤ N`
  (`euler_power_eq_one_of_dvd`).
* **Round-43 sanity instance.**  For `N = 15916539906629`, `c = 3989570`, the value
  `c² − N = 128878271` is itself prime, and `(N / 128878271) = 1`
  (`round43_instance`).  The value is a partial relation with smooth part `1`.
-/

namespace LPSplit

open QSRelationPool QSDimension QSNoDecoupling

/-! ## The Legendre-symbol form -/

/-- **Large primes are split (Legendre form).**  If a prime `r ∤ N` divides the sieve value
`c² − N`, then `(N/r) = +1`. -/
theorem legendreSym_eq_one_of_dvd_qsValue {r : ℕ} [Fact r.Prime] {N c : ℤ}
    (hN : ¬ (r : ℤ) ∣ N) (h : (r : ℤ) ∣ qsValue N c) : legendreSym r N = 1 := by
  have hN0 : (N : ZMod r) ≠ 0 := by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  exact (legendreSym.eq_one_iff r hN0).2 (isSquare_of_dvd_qsValue h)

/-- A prime dividing a sieve value is never inert: `(N/r) ≠ −1` (no coprimality needed). -/
theorem legendreSym_ne_neg_one_of_dvd {r : ℕ} [Fact r.Prime] {N c : ℤ}
    (h : (r : ℤ) ∣ qsValue N c) : legendreSym r N ≠ -1 := by
  rw [Ne, legendreSym.eq_neg_one_iff]
  exact not_not.2 (isSquare_of_dvd_qsValue h)

/-- **Inert primes never appear as columns**, large or small. -/
theorem inert_never_divides {r : ℕ} [Fact r.Prime] {N : ℤ} (h : legendreSym r N = -1)
    (c : ℤ) : ¬ (r : ℤ) ∣ qsValue N c :=
  fun hd => legendreSym_ne_neg_one_of_dvd hd h

/-- The legendre symbol of `N` at a prime dividing a value is `0` or `1`. -/
theorem legendreSym_zero_or_one_of_dvd {r : ℕ} [Fact r.Prime] {N c : ℤ}
    (h : (r : ℤ) ∣ qsValue N c) : legendreSym r N = 0 ∨ legendreSym r N = 1 := by
  by_cases hN : (r : ℤ) ∣ N
  · left
    rw [legendreSym.eq_zero_iff]
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd N r).2 hN
  · exact Or.inr (legendreSym_eq_one_of_dvd_qsValue hN h)

/-- **Hit count = `1 + (N/r)`.**  For an odd prime `r`, the number of residues `c mod r`
with `r ∣ c² − N` equals `1 + (N/r)`: `2` for split, `0` for inert, `1` for ramified.
This is the per-column sieve weight that the LP variant adds to. -/
theorem hitCount_eq_one_add_legendre {r : ℕ} [Fact r.Prime] (hr : r ≠ 2) (N : ℤ) :
    (((Finset.univ.filter (fun c : ZMod r => (r : ℤ) ∣ qsValue N (c.val : ℤ))).card : ℕ) : ℤ)
      = 1 + legendreSym r N := by
  have hset : Finset.univ.filter (fun c : ZMod r => (r : ℤ) ∣ qsValue N (c.val : ℤ))
      = {x : ZMod r | x ^ 2 = (N : ZMod r)}.toFinset := by
    ext c
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Set.mem_toFinset,
      Set.mem_setOf_eq, dvd_qsValue_iff_sq_eq]
    push_cast
    simp
  rw [hset, legendreSym.card_sqrts r hr N]
  ring

/-- **Silverman forms.**  For any form `f` of discriminant `D`, a prime `r ∤ D` dividing a
value has `(D/r) = 1`: the multi-polynomial large primes are split for `D` as well. -/
theorem QForm.legendreSym_disc_eq_one (f : QForm) {r : ℕ} [Fact r.Prime] {x : ℤ}
    (hD : ¬ (r : ℤ) ∣ f.disc) (h : (r : ℤ) ∣ f.eval x) : legendreSym r f.disc = 1 := by
  have hD0 : (f.disc : ZMod r) ≠ 0 := by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  exact (legendreSym.eq_one_iff r hD0).2 (f.isSquare_disc_of_dvd_eval h)

/-! ## Any number of large primes -/

/-- **LP-`k` support theorem.**  Every prime factor of a nonzero sieve value `|x² − N|`
is split, and lies in the split set at any bound `L ≥ |x² − N|` — no matter how many
"large" primes the value contains. -/
theorem primeFactors_subset_admissible {N x : ℤ} {L : ℕ} (hv0 : qsValue N x ≠ 0)
    (hL : (qsValue N x).natAbs ≤ L) :
    (qsValue N x).natAbs.primeFactors ⊆ admissiblePrimes N L := by
  classical
  intro p hp
  have hpr := Nat.prime_of_mem_primeFactors hp
  have hdn := Nat.dvd_of_mem_primeFactors hp
  have hpL : p ≤ L := (Nat.le_of_dvd (Int.natAbs_pos.2 hv0) hdn).trans hL
  have hd : (p : ℤ) ∣ qsValue N x := Int.natCast_dvd.2 hdn
  exact Finset.mem_filter.2 ⟨SmoothSparsity.mem_factorBase.2 ⟨hpr, hpL⟩,
    isSquare_of_dvd_qsValue hd⟩

/-- **LP-matrix columns.**  For any finite family of relations (values `x_i² − N`, each
`L`-smooth but allowed to contain arbitrarily many primes above the small bound), the union
of their prime supports — the column set of the LP relation matrix — is contained in the
split set `admissiblePrimes N L`, hence has at most `Q(L) = |admissiblePrimes N L|`
elements. -/
theorem lpColumns_subset_admissible {ι : Type*} (S : Finset ι) {N : ℤ} {L : ℕ}
    (X : ι → ℤ)
    (hsm : ∀ i ∈ S, ∀ p ∈ (qsValue N (X i)).natAbs.primeFactors, p ≤ L) :
    S.biUnion (fun i => (qsValue N (X i)).natAbs.primeFactors) ⊆ admissiblePrimes N L ∧
    (S.biUnion (fun i => (qsValue N (X i)).natAbs.primeFactors)).card
      ≤ (admissiblePrimes N L).card := by
  classical
  have hsub : S.biUnion (fun i => (qsValue N (X i)).natAbs.primeFactors)
      ⊆ admissiblePrimes N L := by
    intro p hp
    obtain ⟨i, hi, hpi⟩ := Finset.mem_biUnion.1 hp
    have hpr := Nat.prime_of_mem_primeFactors hpi
    have hd : (p : ℤ) ∣ qsValue N (X i) := Int.natCast_dvd.2 (Nat.dvd_of_mem_primeFactors hpi)
    exact Finset.mem_filter.2 ⟨SmoothSparsity.mem_factorBase.2 ⟨hpr, hsm i hi p hpi⟩,
      isSquare_of_dvd_qsValue hd⟩
  exact ⟨hsub, Finset.card_le_card hsub⟩

/-- **The LP variant strictly enlarges `Q`.**  A large prime `r` with `B < r ≤ L` dividing a
sieve value is a split prime *not* in the small split set, so the split set at `L` is
strictly larger than at `B`. -/
theorem largePrime_strictly_enlarges_Q {N x : ℤ} {r B L : ℕ} (hr : r.Prime) (hBr : B < r)
    (hrL : r ≤ L) (hd : (r : ℤ) ∣ qsValue N x) :
    (admissiblePrimes N B).card < (admissiblePrimes N L).card := by
  classical
  apply Finset.card_lt_card
  refine Finset.ssubset_iff_of_subset (admissiblePrimes_mono N (hBr.le.trans hrL)) |>.2 ?_
  refine ⟨r, ?_, ?_⟩
  · obtain ⟨s, hs⟩ := hd
    exact largePrime_isSplit hr hrL (s := s) (by rw [hs]; ring)
  · intro hmem
    have := (SmoothSparsity.mem_factorBase.1
      (Finset.mem_filter.1 hmem).1).2
    omega

/-- **Extra columns are exactly split primes.**  The new columns that an LP variant with
large-prime bound `L` can add above `B` are counted by the number of split primes in
`(B, L]`; inert primes in that range contribute nothing. -/
theorem lp_new_columns_eq {N : ℤ} {B L : ℕ} (hBL : B ≤ L) :
    (admissiblePrimes N L).card
      = (admissiblePrimes N B).card + (admissiblePrimes N L \ admissiblePrimes N B).card := by
  rw [← Finset.card_sdiff_add_card_eq_card (admissiblePrimes_mono N hBL)]
  ring

/-! ## Pairing partial relations -/

/-- **Partial-relation pigeonhole.**  Given `m` partial relations `x_i² − N = s_i·r_i`
(`s_i` `B`-smooth, `r_i` prime) whose large primes take values in a set `R` with
`|R| < m`, two distinct partials share a large prime, and their product has every
odd-exponent prime inside the *small* split set `admissiblePrimes N B`. -/
theorem partial_pigeonhole_pair {m B : ℕ} {N : ℤ} (X : Fin m → ℤ) (s r : Fin m → ℕ)
    (R : Finset ℕ) (hR : ∀ i, r i ∈ R) (hcard : R.card < m)
    (hr : ∀ i, (r i).Prime) (hs0 : ∀ i, s i ≠ 0)
    (hv : ∀ i, qsValue N (X i) = ((s i * r i : ℕ) : ℤ))
    (hsm : ∀ i, ∀ p ∈ (s i).primeFactors, p ≤ B) :
    ∃ i j, i ≠ j ∧ r i = r j ∧
      ∀ p, Odd (((s i * r i) * (s j * r j)).factorization p) → p ∈ admissiblePrimes N B := by
  classical
  obtain ⟨i, -, j, -, hij, hrij⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to (s := Finset.univ) (t := R)
      (by simpa using hcard) (fun i _ => hR i)
  refine ⟨i, j, hij, hrij, ?_⟩
  have h2 : qsValue N (X j) = ((s j * r i : ℕ) : ℤ) := by rw [hv j, hrij]
  have := lpPair_oddSupport_subset (hr i) (hs0 i) (hs0 j) (hv i) h2 (hsm i) (hsm j)
  rwa [hrij] at this ⊢

/-- **Critic's boundary: combined LP relations need only `Q(B) + 1` rows.**  Take `n` LP
pairs `x₁ᵢ² − N = s₁ᵢ·rᵢ`, `x₂ᵢ² − N = s₂ᵢ·rᵢ` (`s` `B`-smooth, `rᵢ` arbitrary — primality is not even needed).
If `n > |admissiblePrimes N B|`, some nonempty set of pairs has a perfect-square product of
all its values.  The final `𝔽₂` matrix has `Q(B)` columns, independent of the large-prime
bound: the large primes occupy columns only in the partial-relation bookkeeping, and cancel
in the combined relations.  So after pairing, LP neither decouples nor enlarges the column
count. -/
theorem lp_combined_congruence {n B : ℕ} {N : ℤ} (X₁ X₂ : Fin n → ℤ) (s₁ s₂ r : Fin n → ℕ)
    (hs₁ : ∀ i, s₁ i ≠ 0) (hs₂ : ∀ i, s₂ i ≠ 0)
    (hv₁ : ∀ i, qsValue N (X₁ i) = ((s₁ i * r i : ℕ) : ℤ))
    (hv₂ : ∀ i, qsValue N (X₂ i) = ((s₂ i * r i : ℕ) : ℤ))
    (hsm₁ : ∀ i, ∀ p ∈ (s₁ i).primeFactors, p ≤ B)
    (hsm₂ : ∀ i, ∀ p ∈ (s₂ i).primeFactors, p ≤ B)
    (hcard : (admissiblePrimes N B).card < n) :
    ∃ T : Finset (Fin n), T.Nonempty ∧
      IsSquare (∏ i ∈ T, ((s₁ i * r i) * (s₂ i * r i))) := by
  classical
  have hsplit : ∀ {x : ℤ} {s t : ℕ}, qsValue N x = ((s * t : ℕ) : ℤ) →
      (∀ p ∈ s.primeFactors, p ≤ B) → ∀ p ∈ s.primeFactors, p ∈ admissiblePrimes N B := by
    intro x s t hv hsm p hp
    have hpr := Nat.prime_of_mem_primeFactors hp
    have hd : (p : ℤ) ∣ qsValue N x := by
      rw [hv]; exact_mod_cast Dvd.dvd.mul_right (Nat.dvd_of_mem_primeFactors hp) t
    exact Finset.mem_filter.2 ⟨SmoothSparsity.mem_factorBase.2 ⟨hpr, hsm p hp⟩,
      isSquare_of_dvd_qsValue hd⟩
  have hsupp : ∀ i, ∀ p, (s₁ i * s₂ i).factorization p ≠ 0 → p ∈ admissiblePrimes N B := by
    intro i p hp
    rw [Nat.factorization_mul (hs₁ i) (hs₂ i), Finsupp.add_apply] at hp
    by_cases h1 : (s₁ i).factorization p = 0
    · rw [h1, zero_add] at hp
      exact hsplit (hv₂ i) (hsm₂ i) p
        (by rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 hp)
    · exact hsplit (hv₁ i) (hsm₁ i) p
        (by rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 h1)
  obtain ⟨T, hT, hsq⟩ := exists_nonempty_subset_prod_isSquare (admissiblePrimes N B)
    (fun i => s₁ i * s₂ i) (fun i => mul_ne_zero (hs₁ i) (hs₂ i)) hsupp (by simpa using hcard)
  refine ⟨T, hT, ?_⟩
  have e : ∏ i ∈ T, ((s₁ i * r i) * (s₂ i * r i))
      = (∏ i ∈ T, (s₁ i * s₂ i)) * ((∏ i ∈ T, r i) * (∏ i ∈ T, r i)) := by
    rw [← Finset.prod_mul_distrib, ← Finset.prod_mul_distrib]
    exact Finset.prod_congr rfl fun i _ => by ring
  rw [e]
  exact hsq.mul ⟨_, rfl⟩

/-! ## Reciprocity: splitness is a congruence condition mod `4N` -/

/-- **The split set is periodic mod `4N`.**  For `N > 0`, if odd primes `r ≡ r' (mod 4N)`
and `r ∤ N` divides some sieve value `c² − N`, then `r'` also divides some sieve value.
(Jacobi reciprocity: `(N/r) = J(N | r)` depends only on `r mod 4N`.)  Large primes cannot
be selected to escape the split condition: it is a union of residue classes. -/
theorem split_periodic_mod_four_N {N : ℕ} {r r' : ℕ} (hr : r.Prime) (hr' : r'.Prime)
    (hro : Odd r) (hro' : Odd r') (hmod : r % (4 * N) = r' % (4 * N))
    (hN : ¬ (r : ℤ) ∣ (N : ℤ)) {c : ℤ} (hc : (r : ℤ) ∣ qsValue (N : ℤ) c) :
    ∃ c' : ℤ, (r' : ℤ) ∣ qsValue (N : ℤ) c' := by
  haveI := Fact.mk hr
  haveI := Fact.mk hr'
  have h1 : legendreSym r (N : ℤ) = 1 := legendreSym_eq_one_of_dvd_qsValue hN hc
  have hJ : jacobiSym (N : ℤ) r' = 1 := by
    have e1 := jacobiSym.mod_right' N hro
    have e2 := jacobiSym.mod_right' N hro'
    rw [hmod] at e1
    rw [e2, ← e1, ← jacobiSym.legendreSym.to_jacobiSym]
    exact h1
  rw [← jacobiSym.legendreSym.to_jacobiSym] at hJ
  have hN0 : ((N : ℤ) : ZMod r') ≠ 0 := by
    intro h0
    rw [← legendreSym.eq_zero_iff] at h0
    rw [h0] at hJ
    exact zero_ne_one hJ
  exact (exists_dvd_qsValue_iff_isSquare (N : ℤ)).2 ((legendreSym.eq_one_iff r' hN0).1 hJ)

/-- **Euler form.**  For an odd prime `r ∤ N` dividing `c² − N`,
`N^((r−1)/2) ≡ 1 (mod r)` (written `N^(r/2) = 1` in `ZMod r`). -/
theorem euler_power_eq_one_of_dvd {r : ℕ} [Fact r.Prime] {N c : ℤ}
    (hN : ¬ (r : ℤ) ∣ N) (h : (r : ℤ) ∣ qsValue N c) : (N : ZMod r) ^ (r / 2) = 1 := by
  have hN0 : (N : ZMod r) ≠ 0 := by rwa [Ne, ZMod.intCast_zmod_eq_zero_iff_dvd]
  exact (ZMod.euler_criterion r hN0).1 (isSquare_of_dvd_qsValue h)

/-! ## The round-43 sanity instance -/

/-- **Round-43 instance.**  For `N = 15916539906629` and `c = 3989570` the sieve value
`c² − N = 128878271` is prime — a partial relation consisting of a single large prime — and
this large prime is split: `(N / 128878271) = 1`.  The split conclusion is derived from
`legendreSym_eq_one_of_dvd_qsValue`, not by evaluating the symbol. -/
theorem round43_instance :
    qsValue 15916539906629 3989570 = 128878271 ∧ Nat.Prime 128878271 ∧
      @legendreSym 128878271 ⟨by norm_num⟩ 15916539906629 = 1 := by
  have hv : qsValue 15916539906629 3989570 = 128878271 := by norm_num [qsValue]
  have hp : Nat.Prime 128878271 := by norm_num
  haveI := Fact.mk hp
  refine ⟨hv, hp, ?_⟩
  apply legendreSym_eq_one_of_dvd_qsValue (c := 3989570)
  · norm_num
  · rw [hv]; norm_num

end LPSplit