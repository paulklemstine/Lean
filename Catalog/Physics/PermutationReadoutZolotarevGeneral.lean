import Mathlib
import Physics.PermutationReadoutCore
import Physics.PermutationReadoutAsymmetry
import Physics.PermutationReadoutParityLocalization
import Physics.PermutationReadoutZolotarev
import Physics.PermutationReadoutPrimePower

/-!
# Zolotarev–Frobenius for the full stratified readout (conjecture C1, closed)

This file proves conjecture **C1** of `FUTURE_DIRECTIONS.md` in full: for *every*
odd modulus `N > 0` and every multiplier `a` coprime to `N`,

`J(a | N) = 1  ⟺  N − #cycles(x ↦ a·x on ZMod N)  is even`,

i.e. the sign of the multiplication permutation of the whole ring `ZMod N` is
the Jacobi symbol.  The proof is the parity-localization programme carried out
to the end:

* the index `i_e = φ(e)/ord_e(a)` of a stratum whose label `e` splits into two
  coprime factors `> 2` is **even** (`even_totient_div_orderOf_mul`), so such
  strata are parity-dead;
* on a prime-power label the index is parity-constant along the tower
  (`index_prime_pow_parity`), so `∑_{e ∣ p^k} i_e ≡ 1 + k·i_p`;
* hence, by induction on the coprime factorisation,
  `∑_{e ∣ N} i_e ≡ 1 + ∑_{p ∈ primeFactorsList N} i_p (mod 2)`;
* `N = ∑_{e ∣ N} φ(e)` and `#cycles = ∑_{e ∣ N} i_e`, so
  `N − #cycles ≡ ∑_{p ∈ primeFactorsList N} i_p`;
* finally `J(a|N) = ∏_{p ∈ primeFactorsList N} (a|p)` and `(a|p) = 1` iff `i_p`
  is even (Euler's criterion, `isSquare_iff_even_index`).

## Main results

* `Physics.PermReadout.idx` — the stratum index `φ(N)/ord_N(a)`.
* `Physics.PermReadout.sum_idx_prime_pow` — the prime-power divisor sum.
* `Physics.PermReadout.sum_idx_divisors` — the divisor sum modulo `2` is
  `1 + ∑_{p ∈ primeFactorsList N} i_p`.
* `Physics.PermReadout.parity_readout_eq_sum_prime_indices` —
  `N − #cycles ≡ ∑_{p ∈ primeFactorsList N} i_p (mod 2)`.
* `Physics.PermReadout.jacobiSym_eq_one_iff_even_index_sum` — the Jacobi symbol
  as the parity of that sum.
* `Physics.PermReadout.zolotarev_general` — **the theorem**: `J(a|N) = 1` iff
  `x ↦ a·x` is an even permutation of `ZMod N`, for every odd `N`.
-/

namespace Physics.PermReadout

open Finset

section General

/-- The **index** of the modulus `N` for the multiplier `a`: the number of
cycles of `x ↦ a·x` on the unit stratum of `ZMod N`. -/
noncomputable def idx (N a : ℕ) : ℕ := Nat.totient N / orderOf ((a : ZMod N))

@[simp] theorem idx_one (a : ℕ) : idx 1 a = 1 := by
  have h : orderOf ((a : ZMod 1)) = 1 :=
    orderOf_eq_one_iff.mpr (Subsingleton.elim _ _)
  simp [idx, h]

/-- Parity in `ZMod 2` versus parity in `ℕ`. -/
theorem natCast_zmod_two_eq_zero_iff (x : ℕ) : ((x : ZMod 2) = 0) ↔ x % 2 = 0 := by
  rw [ZMod.natCast_eq_zero_iff x 2]
  omega

/-- A sum over the divisors of a product of coprime numbers splits as a double
sum. -/
theorem sum_divisors_mul_coprime {M : Type*} [AddCommMonoid M] {m n : ℕ}
    (h : Nat.Coprime m n) (f : ℕ → M) :
    ∑ d ∈ (m * n).divisors, f d = ∑ i ∈ m.divisors, ∑ j ∈ n.divisors, f (i * j) := by
  rw [Nat.divisors_mul, Finset.mul_def, Finset.sum_image]
  · rw [Finset.sum_product]
  · intro x hx y hy heq
    rw [Finset.mem_coe, Finset.mem_product] at hx hy
    obtain ⟨hx1, hx2⟩ := hx
    obtain ⟨hy1, hy2⟩ := hy
    have hxm := Nat.dvd_of_mem_divisors hx1
    have hym := Nat.dvd_of_mem_divisors hy1
    have hxn := Nat.dvd_of_mem_divisors hx2
    have hyn := Nat.dvd_of_mem_divisors hy2
    simp only at heq
    have c12 : Nat.Coprime x.1 y.2 := (h.coprime_dvd_left hxm).coprime_dvd_right hyn
    have c21 : Nat.Coprime y.1 x.2 := (h.coprime_dvd_left hym).coprime_dvd_right hxn
    have h1 : x.1 ∣ y.1 :=
      c12.dvd_of_dvd_mul_right (heq ▸ Dvd.intro x.2 (mul_comm x.1 x.2 ▸ rfl))
    have h2 : y.1 ∣ x.1 := c21.dvd_of_dvd_mul_right (heq ▸ Dvd.intro y.2 rfl)
    have hfst : x.1 = y.1 := Nat.dvd_antisymm h1 h2
    have hx1pos : 0 < x.1 := Nat.pos_of_mem_divisors hx1
    have hsnd : x.2 = y.2 := by
      have hmul := heq
      rw [hfst] at hmul
      exact Nat.eq_of_mul_eq_mul_left (hfst ▸ hx1pos) hmul
    exact Prod.ext hfst hsnd

/-- **The prime-power divisor sum.**  Along the tower `1, p, …, p^k` the index
is parity-constant, so the divisor sum has parity `1 + k·i_p`. -/
theorem sum_idx_prime_pow {p a : ℕ} (hp : p.Prime) (hodd : p ≠ 2)
    (hcop : Nat.Coprime a p) (k : ℕ) :
    ∑ e ∈ (p ^ k).divisors, ((idx e a : ℕ) : ZMod 2) = 1 + (k : ZMod 2) * (idx p a : ℕ) := by
  rw [Nat.divisors_prime_pow hp, Finset.sum_map]
  simp only [Function.Embedding.coeFn_mk]
  rw [Finset.sum_range_succ']
  have hzero : ((idx (p ^ 0) a : ℕ) : ZMod 2) = 1 := by simp
  have hstep : ∀ j ∈ Finset.range k,
      ((idx (p ^ (j + 1)) a : ℕ) : ZMod 2) = ((idx p a : ℕ) : ZMod 2) := by
    intro j _
    have hpar : idx (p ^ (j + 1)) a % 2 = idx p a % 2 := by
      have := index_prime_pow_parity (p := p) (a := a) (k := j + 1) hp hodd
        (Nat.succ_pos j) hcop
      simpa [idx, pow_one, Nat.totient_prime hp] using this
    have h2 : ((idx (p ^ (j + 1)) a % 2 : ℕ) : ZMod 2) = ((idx p a % 2 : ℕ) : ZMod 2) := by
      rw [hpar]
    simpa [ZMod.natCast_mod] using h2
  rw [Finset.sum_congr rfl hstep, Finset.sum_const, Finset.card_range, hzero,
    nsmul_eq_mul, add_comm]

/-- **The divisor-sum parity law.**  For an odd modulus the sum of the stratum
indices over all divisors is congruent to `1 + ∑_{p ∈ primeFactorsList N} i_p`
modulo `2`: every divisor with two coprime factors `> 2` is parity-dead, and the
prime-power tower over `p` contributes `v_p(N)` copies of `i_p`. -/
theorem sum_idx_divisors {a : ℕ} :
    ∀ N : ℕ, Odd N → Nat.Coprime a N →
      ∑ e ∈ N.divisors, ((idx e a : ℕ) : ZMod 2)
        = 1 + (N.primeFactorsList.map (fun p => ((idx p a : ℕ) : ZMod 2))).sum := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro hodd hcop
    have hN0 : N ≠ 0 := by
      rintro rfl
      simp at hodd
    rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.mpr hN0) with h1 | h1
    · -- `N = 1`
      rw [← h1]
      simp
    -- `N > 1`: split off the minimal prime power
    set p := N.minFac with hpdef
    have hp : p.Prime := Nat.minFac_prime (by omega)
    have hpdvd : p ∣ N := Nat.minFac_dvd N
    have hpodd : p ≠ 2 := by
      intro hp2
      rw [hp2] at hpdvd
      rw [Nat.odd_iff] at hodd
      omega
    set k := N.factorization p with hkdef
    set M := N / p ^ k with hMdef
    have hk : 0 < k := hp.factorization_pos_of_dvd hN0 hpdvd
    have hsplit : p ^ k * M = N := Nat.ordProj_mul_ordCompl_eq_self N p
    have hcopkM : Nat.Coprime (p ^ k) M :=
      Nat.Coprime.pow_left k (Nat.coprime_ordCompl hp hN0)
    have hMdvd : M ∣ N := ⟨p ^ k, by rw [← hsplit]; ring⟩
    have hM0 : M ≠ 0 := by
      intro h
      rw [h, mul_zero] at hsplit
      exact hN0 hsplit.symm
    have hpk1 : 1 < p ^ k := Nat.one_lt_pow hk.ne' hp.one_lt
    have hM0' : 0 < M := Nat.pos_of_ne_zero hM0
    have hMlt : M < N := by
      have : M < p ^ k * M := by nlinarith
      omega
    have hModd : Odd M := by
      by_contra hcon
      have h2 : (2 : ℕ) ∣ M := by
        rcases Nat.even_or_odd M with hev | hod
        · exact hev.two_dvd
        · exact absurd hod hcon
      have h2N : (2 : ℕ) ∣ N := h2.trans hMdvd
      rw [Nat.odd_iff] at hodd
      omega
    have hcopaM : Nat.Coprime a M := hcop.coprime_dvd_right hMdvd
    have hcopap : Nat.Coprime a p := hcop.coprime_dvd_right hpdvd
    -- all divisors of `N` are odd
    have hdivodd : ∀ e : ℕ, e ∣ N → e ≠ 1 → 2 < e := by
      intro e he hne
      have he0 : e ≠ 0 := by
        rintro rfl
        exact hN0 (Nat.eq_zero_of_zero_dvd he)
      have heodd : ¬ ((2 : ℕ) ∣ e) := by
        intro h2
        have h2N : (2 : ℕ) ∣ N := h2.trans he
        rw [Nat.odd_iff] at hodd
        omega
      rcases Nat.lt_or_ge e 3 with hlt | hge
      · interval_cases e
        · omega
        · exact absurd hne (by omega)
        · exact absurd (by norm_num) heodd
      · omega
    rw [← hsplit, sum_divisors_mul_coprime hcopkM]
    -- the `i = 1` slice is the whole divisor sum of `M`
    have hone : (1 : ℕ) ∈ (p ^ k).divisors :=
      Nat.one_mem_divisors.mpr (pow_ne_zero k hp.pos.ne')
    rw [← Finset.add_sum_erase _ _ hone]
    have hslice1 : ∑ j ∈ M.divisors, ((idx (1 * j) a : ℕ) : ZMod 2)
        = 1 + (M.primeFactorsList.map (fun q => ((idx q a : ℕ) : ZMod 2))).sum := by
      simpa using ih M hMlt hModd hcopaM
    -- every other slice collapses to its `j = 1` term
    have hslice : ∀ i ∈ (p ^ k).divisors.erase 1,
        ∑ j ∈ M.divisors, ((idx (i * j) a : ℕ) : ZMod 2) = ((idx i a : ℕ) : ZMod 2) := by
      intro i hi
      have hine : i ≠ 1 := (Finset.mem_erase.mp hi).1
      have hidvd : i ∣ p ^ k := Nat.dvd_of_mem_divisors (Finset.mem_erase.mp hi).2
      have hidvdN : i ∣ N := hidvd.trans ⟨M, hsplit.symm⟩
      have hi3 : 2 < i := hdivodd i hidvdN hine
      have honeM : (1 : ℕ) ∈ M.divisors := Nat.one_mem_divisors.mpr hM0
      rw [← Finset.add_sum_erase _ _ honeM, mul_one]
      have hrest : ∑ j ∈ M.divisors.erase 1, ((idx (i * j) a : ℕ) : ZMod 2) = 0 := by
        refine Finset.sum_eq_zero ?_
        intro j hj
        have hjne : j ≠ 1 := (Finset.mem_erase.mp hj).1
        have hjdvd : j ∣ M := Nat.dvd_of_mem_divisors (Finset.mem_erase.mp hj).2
        have hjdvdN : j ∣ N := hjdvd.trans hMdvd
        have hj3 : 2 < j := hdivodd j hjdvdN hjne
        have hcopij : Nat.Coprime i j :=
          (hcopkM.coprime_dvd_left hidvd).coprime_dvd_right hjdvd
        have hijdvd : i * j ∣ N := by
          calc i * j ∣ p ^ k * M := mul_dvd_mul hidvd hjdvd
            _ = N := hsplit
        have hcopa : Nat.Coprime a (i * j) := hcop.coprime_dvd_right hijdvd
        haveI : NeZero i := ⟨by omega⟩
        haveI : NeZero j := ⟨by omega⟩
        have heven : idx (i * j) a % 2 = 0 :=
          even_totient_div_orderOf_mul hcopij hi3 hj3 hcopa
        exact (natCast_zmod_two_eq_zero_iff _).mpr heven
      rw [hrest, add_zero]
    rw [Finset.sum_congr rfl hslice, hslice1]
    -- the erased prime-power sum is `k·i_p`
    have hpp := sum_idx_prime_pow hp hpodd hcopap k
    rw [← Finset.add_sum_erase _ _ hone, idx_one] at hpp
    have herase : ∑ i ∈ (p ^ k).divisors.erase 1, ((idx i a : ℕ) : ZMod 2)
        = (k : ZMod 2) * (idx p a : ℕ) := by
      have h1' : ((1 : ℕ) : ZMod 2) = 1 := by norm_num
      rw [h1'] at hpp
      exact add_left_cancel hpp
    rw [herase]
    -- and the prime list of `N` is the tower list of `p` followed by that of `M`
    have hperm : (p ^ k * M).primeFactorsList.Perm
        ((p ^ k).primeFactorsList ++ M.primeFactorsList) :=
      Nat.perm_primeFactorsList_mul (pow_ne_zero k hp.pos.ne') hM0
    have hlist : ((p ^ k * M).primeFactorsList.map (fun q => ((idx q a : ℕ) : ZMod 2))).sum
        = (k : ZMod 2) * (idx p a : ℕ)
          + (M.primeFactorsList.map (fun q => ((idx q a : ℕ) : ZMod 2))).sum := by
      rw [(hperm.map _).sum_eq, List.map_append, List.sum_append,
        hp.primeFactorsList_pow, List.map_replicate, List.sum_replicate, nsmul_eq_mul]
    rw [hlist]
    ring

/-- **The readout parity.**  For an odd modulus, the number of transpositions of
the permutation `x ↦ a·x` of `ZMod N` is congruent modulo `2` to the sum of the
prime indices `i_p = (p−1)/ord_p(a)`, counted with multiplicity in `N`. -/
theorem parity_readout_eq_sum_prime_indices {N a : ℕ} [NeZero N] (hodd : Odd N)
    (hcop : Nat.Coprime a N) :
    (((N - cycleCount N a : ℕ)) : ZMod 2)
      = (N.primeFactorsList.map (fun p => ((idx p a : ℕ) : ZMod 2))).sum := by
  have hle : cycleCount N a ≤ N := by
    have h1 : cycleCount N a ≤ (Finset.univ : Finset (ZMod N)).card := Finset.card_image_le
    simpa using h1
  have hcyc : cycleCount N a = ∑ e ∈ N.divisors, idx e a := by
    rw [cycleCount_eq_sum hcop]
    simp only [idx]
    exact Nat.sum_div_divisors N (fun e => Nat.totient e / orderOf ((a : ZMod e)))
  have hNodd : ((N : ℕ) : ZMod 2) = 1 := by
    have hm : N % 2 = 1 := Nat.odd_iff.mp hodd
    calc ((N : ℕ) : ZMod 2) = ((N % 2 : ℕ) : ZMod 2) := (ZMod.natCast_mod N 2).symm
      _ = 1 := by rw [hm]; norm_num
  have h11 : (1 : ZMod 2) + 1 = 0 := by decide
  rw [Nat.cast_sub hle, CharTwo.sub_eq_add, hcyc, Nat.cast_sum, hNodd,
    sum_idx_divisors N hodd hcop, ← add_assoc, h11, zero_add]

/-- **The Jacobi symbol is the parity of the prime-index sum.**  `J(a | N) = 1`
exactly when an even number of the prime factors of `N` (with multiplicity) have
`a` as a quadratic non-residue. -/
theorem jacobiSym_eq_one_iff_even_index_sum {a : ℕ} :
    ∀ N : ℕ, Odd N → Nat.Coprime a N →
      (jacobiSym (a : ℤ) N = 1 ↔
        (N.primeFactorsList.map (fun p => ((idx p a : ℕ) : ZMod 2))).sum = 0) := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro hodd hcop
    have hN0 : N ≠ 0 := by
      rintro rfl
      simp at hodd
    rcases eq_or_lt_of_le (Nat.one_le_iff_ne_zero.mpr hN0) with h1 | h1
    · rw [← h1]
      simp
    set p := N.minFac with hpdef
    have hp : p.Prime := Nat.minFac_prime (by omega)
    haveI : Fact p.Prime := ⟨hp⟩
    have hpdvd : p ∣ N := Nat.minFac_dvd N
    have hpodd : p ≠ 2 := by
      intro hp2
      rw [hp2] at hpdvd
      rw [Nat.odd_iff] at hodd
      omega
    set M := N / p with hMdef
    have hsplit : p * M = N := Nat.mul_div_cancel' hpdvd
    have hM0 : M ≠ 0 := by
      intro h
      rw [h, mul_zero] at hsplit
      exact hN0 hsplit.symm
    have hMdvd : M ∣ N := ⟨p, by rw [← hsplit]; ring⟩
    have hM0' : 0 < M := Nat.pos_of_ne_zero hM0
    have hMlt : M < N := by
      have : M < p * M := by nlinarith [hp.two_le]
      omega
    have hModd : Odd M := by
      by_contra hcon
      have h2 : (2 : ℕ) ∣ M := by
        rcases Nat.even_or_odd M with hev | hod
        · exact hev.two_dvd
        · exact absurd hod hcon
      have h2N : (2 : ℕ) ∣ N := h2.trans hMdvd
      rw [Nat.odd_iff] at hodd
      omega
    have hcopaM : Nat.Coprime a M := hcop.coprime_dvd_right hMdvd
    have hcopap : Nat.Coprime a p := hcop.coprime_dvd_right hpdvd
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero M := ⟨hM0⟩
    -- the Legendre symbol at `p`
    have hane : ((a : ZMod p)) ≠ 0 := by
      intro h
      have hdvd : p ∣ a := (ZMod.natCast_eq_zero_iff a p).mp h
      exact hp.ne_one (Nat.Coprime.eq_one_of_dvd hcopap.symm hdvd)
    have hcast : (((a : ℤ) : ZMod p)) ≠ 0 := by push_cast; exact hane
    have hleg : legendreSym p (a : ℤ) = 1 ↔ IsSquare ((a : ZMod p)) := by
      rw [legendreSym.eq_one_iff p hcast]
      push_cast
      rfl
    have hlegpm : legendreSym p (a : ℤ) = 1 ∨ legendreSym p (a : ℤ) = -1 :=
      legendreSym.eq_one_or_neg_one p hcast
    have hsq := isSquare_iff_even_index hp hpodd hcopap
    have hidxp : idx p a = (p - 1) / orderOf ((a : ZMod p)) := by
      rw [idx, Nat.totient_prime hp]
    -- the list of `N` is `p :: list M`
    have hlist : (N.primeFactorsList.map (fun q => ((idx q a : ℕ) : ZMod 2))).sum
        = ((idx p a : ℕ) : ZMod 2)
          + (M.primeFactorsList.map (fun q => ((idx q a : ℕ) : ZMod 2))).sum := by
      have hperm : N.primeFactorsList.Perm (p.primeFactorsList ++ M.primeFactorsList) := by
        rw [← hsplit]
        exact Nat.perm_primeFactorsList_mul hp.pos.ne' hM0
      rw [(hperm.map _).sum_eq, List.map_append, List.sum_append,
        Nat.primeFactorsList_prime hp]
      simp
    have hmul : jacobiSym (a : ℤ) N = legendreSym p (a : ℤ) * jacobiSym (a : ℤ) M := by
      rw [← hsplit, jacobiSym.mul_right, jacobiSym.legendreSym.to_jacobiSym]
    have hMpm : jacobiSym (a : ℤ) M = 1 ∨ jacobiSym (a : ℤ) M = -1 := by
      refine jacobiSym.eq_one_or_neg_one ?_
      simpa [Int.gcd_natCast_natCast] using hcopaM
    have hih := ih M hMlt hModd hcopaM
    rw [hmul, hlist]
    rcases hlegpm with h1 | h1
    · -- `a` is a residue at `p`: the index is even
      have hev : idx p a % 2 = 0 := by
        rw [hidxp]
        exact hsq.mp (hleg.mp h1)
      have hz : ((idx p a : ℕ) : ZMod 2) = 0 := (natCast_zmod_two_eq_zero_iff _).mpr hev
      rw [h1, one_mul, hz, zero_add]
      exact hih
    · -- `a` is a non-residue at `p`: the index is odd
      have hodd' : idx p a % 2 = 1 := by
        by_contra hcon
        have h0 : idx p a % 2 = 0 := by omega
        have : IsSquare ((a : ZMod p)) := hsq.mpr (by rwa [hidxp] at h0)
        have hone := hleg.mpr this
        rw [h1] at hone
        norm_num at hone
      have hz : ((idx p a : ℕ) : ZMod 2) = 1 := by
        have : ((idx p a % 2 : ℕ) : ZMod 2) = ((1 : ℕ) : ZMod 2) := by rw [hodd']
        simpa [ZMod.natCast_mod] using this
      rw [h1, hz]
      rcases hMpm with h2 | h2
      · have : (M.primeFactorsList.map (fun q => ((idx q a : ℕ) : ZMod 2))).sum = 0 :=
          hih.mp h2
        rw [h2, this]
        norm_num
      · have hne : (M.primeFactorsList.map (fun q => ((idx q a : ℕ) : ZMod 2))).sum ≠ 0 := by
          intro h0
          have := hih.mpr h0
          rw [h2] at this
          norm_num at this
        have hz2 : ∀ z : ZMod 2, z ≠ 0 → z = 1 := by decide
        have heq1 : (M.primeFactorsList.map (fun q => ((idx q a : ℕ) : ZMod 2))).sum = 1 :=
          hz2 _ hne
        rw [h2, heq1]
        exact iff_of_true (by norm_num) (by decide)

/-- **Zolotarev–Frobenius for the stratified readout (conjecture C1).**  For
every odd modulus `N` and every multiplier `a` coprime to `N`, the multiplication
permutation `x ↦ a·x` of the whole ring `ZMod N` is even exactly when the Jacobi
symbol `J(a | N)` is `+1`.

Consequently the coarsest global summary of the asymmetric cycle spectrum — the
sign of the permutation, equivalently the parity of `N − #cycles` — is a
polynomial-time computable, factorisation-free quantity: no attack can read
secret structure out of it. -/
theorem zolotarev_general {N a : ℕ} [NeZero N] (hodd : Odd N) (hcop : Nat.Coprime a N) :
    jacobiSym (a : ℤ) N = 1 ↔ (N - cycleCount N a) % 2 = 0 := by
  rw [jacobiSym_eq_one_iff_even_index_sum N hodd hcop,
    ← parity_readout_eq_sum_prime_indices hodd hcop,
    natCast_zmod_two_eq_zero_iff]

end General

end Physics.PermReadout