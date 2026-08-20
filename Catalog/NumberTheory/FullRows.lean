/-
# Rows of the `q`-Pascal triangle that are entirely prime to `ℓ`

Kummer's theorem says that the `N`-th row of Pascal's triangle contains no multiple of a prime
`p` exactly when adding `A` and `N - A` in base `p` never carries, for every `A ≤ N`.  This file
turns that into a closed arithmetic description, first classically and then for the Gaussian
binomial coefficients.

* `QKummer.not_dvd_choose_row_iff` — **the classical full rows**: `p ∤ C(N,A)` for *every*
  `A ≤ N` iff `N + 1 = c · p ^ t` for some `1 ≤ c ≤ p`.  (Equivalently: every base-`p` digit of
  `N` below the leading one equals `p - 1`.)  In particular all rows `N < p` are full, which is
  why the naive guess "`N + 1` is a power of `p`" is false.
* `QKummer.not_dvd_qBinom_row_iff_crit` / `QKummer.not_dvd_qBinom_row_iff` — **the `q`-analogue**:
  for a `q`-Lucas period `d` of `ℓ`, the whole `n`-th `q`-Pascal row is prime to `ℓ` iff
  `n + 1 ≤ d` or `n + 1 = d · c · ℓ ^ t` with `1 ≤ c ≤ ℓ`.  The base-`d` dilation therefore
  *rescales* the classical set of full rows by `d`, and adds the `d` initial rows.
* `QKummer.not_dvd_qBinom_row_iff_orderOf` — the same statement at every prime `ℓ ∤ q`, with
  `d = ord_ℓ(q)` (no oddness hypothesis, degenerate case `d = 1` included).
* `QKummer.card_row_eq_iff_full` and `QKummer.card_row_not_dvd_qBinom_eq_succ_iff` — the counting
  form: the row count of `Catalog/NumberTheory/QKummer/RowCount.lean` attains its maximum `n + 1`
  exactly on those rows.

* `QKummer.padicValNat_qBinom_residual` and `QKummer.exists_padicValNat_qBinom_ge_offset` — the
  complementary statement for a regular datum `(d, e)`: if `n ≥ d` and `n % d < d - 1`, then the
  entry `k = n % d + 1` forces a base-`d` carry and has valuation exactly `e + v_ℓ(⌊n/d⌋)`.  So
  the residual term `e` is available in every row except those with maximal last digit — exactly
  the residue excluded by the full-row criterion.

These statements settle the "`q`-Sierpiński boundary" question left open by the row-count
formula: the fully surviving rows of the `q`-triangle are exactly the `d`-dilates of the
classical ones, preceded by the `d` initial rows.
-/
import Catalog.NumberTheory.QKummer.RowCount
import Catalog.NumberTheory.QKummer.Valuation

namespace QKummer

open Finset

section Classical

variable {p : ℕ} [hp : Fact p.Prime]

/-- **One digit at a time.**  For `N ≥ p`, the `N`-th Pascal row is free of multiples of `p`
exactly when its last base-`p` digit is `p - 1` and the row of the block index `⌊N/p⌋` is free of
multiples of `p`. -/
theorem not_dvd_choose_row_step {N : ℕ} (hN : p ≤ N) :
    (∀ A ≤ N, ¬ p ∣ N.choose A) ↔
      (N % p = p - 1 ∧ ∀ B ≤ N / p, ¬ p ∣ (N / p).choose B) := by
  have hmod : N % p < p := Nat.mod_lt _ hp.out.pos
  have hdm := Nat.div_add_mod N p
  constructor
  · intro hfull
    have hlast : N % p = p - 1 := by
      have hle : p - 1 ≤ N := le_trans (by omega) hN
      have hstep := (not_dvd_choose_iff_step (p := p) (N := N) (A := p - 1)).mp (hfull _ hle)
      have hpm : (p - 1) % p = p - 1 := Nat.mod_eq_of_lt (by omega)
      omega
    refine ⟨hlast, fun B hB => ?_⟩
    have hle : p * B ≤ N := by
      have h1 : p * B ≤ p * (N / p) := Nat.mul_le_mul_left p hB
      omega
    have hstep := (not_dvd_choose_iff_step (p := p) (N := N) (A := p * B)).mp (hfull _ hle)
    rw [Nat.mul_div_cancel_left B hp.out.pos] at hstep
    exact hstep.2
  · rintro ⟨hlast, hblock⟩ A hA
    refine (not_dvd_choose_iff_step (p := p)).mpr ⟨?_, hblock _ (Nat.div_le_div_right hA)⟩
    have hAmod : A % p < p := Nat.mod_lt _ hp.out.pos
    omega

/-- **The full rows of Pascal's triangle.**  For a prime `p`, the `N`-th row contains no multiple
of `p` if and only if `N + 1 = c · p ^ t` for some `1 ≤ c ≤ p`; equivalently `N` is of the form
`c · p ^ t - 1`.  For `t = 0` this covers all rows `N < p`. -/
theorem not_dvd_choose_row_iff (N : ℕ) :
    (∀ A ≤ N, ¬ p ∣ N.choose A) ↔ ∃ c t, 1 ≤ c ∧ c ≤ p ∧ N + 1 = c * p ^ t := by
  have hp1 : 1 < p := hp.out.one_lt
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    rcases Nat.lt_or_ge N p with hsmall | hge
    · constructor
      · intro _
        exact ⟨N + 1, 0, by omega, by omega, by ring⟩
      · intro _ A hA
        exact not_dvd_choose_of_lt_prime hA hsmall
    · have hlt : N / p < N := Nat.div_lt_self (by omega) hp1
      have hdm := Nat.div_add_mod N p
      have hmod : N % p < p := Nat.mod_lt _ hp.out.pos
      have hmul : p * (N / p + 1) = p * (N / p) + p := by ring
      constructor
      · intro hfull
        obtain ⟨hlast, hblock⟩ := (not_dvd_choose_row_step hge).mp hfull
        obtain ⟨c, t, hc1, hcp, hct⟩ := (ih _ hlt).mp hblock
        refine ⟨c, t + 1, hc1, hcp, ?_⟩
        calc N + 1 = p * (N / p + 1) := by omega
          _ = p * (c * p ^ t) := by rw [hct]
          _ = c * p ^ (t + 1) := by ring
      · rintro ⟨c, t, hc1, hcp, hct⟩
        have htpos : 1 ≤ t := by
          rcases Nat.eq_zero_or_pos t with rfl | h
          · simp at hct; omega
          · exact h
        obtain ⟨t', rfl⟩ : ∃ t', t = t' + 1 := ⟨t - 1, by omega⟩
        have hct' : N + 1 = p * (c * p ^ t') := by rw [hct]; ring
        have hMpos : 0 < c * p ^ t' := Nat.mul_pos (by omega) (Nat.pow_pos hp.out.pos)
        have hge' : N / p + 1 ≤ c * p ^ t' := by
          by_contra hcon
          push_neg at hcon
          have : p * (c * p ^ t') ≤ p * (N / p) := Nat.mul_le_mul_left p (by omega)
          omega
        have hle2 : p * (N / p) + p ≤ p * (c * p ^ t') := by
          have := Nat.mul_le_mul_left p hge'
          omega
        have hlast : N % p = p - 1 := by omega
        have heq : p * (N / p + 1) = p * (c * p ^ t') := by omega
        refine (not_dvd_choose_row_step hge).mpr ⟨hlast, ?_⟩
        exact (ih _ hlt).mpr ⟨c, t', hc1, hcp, Nat.eq_of_mul_eq_mul_left hp.out.pos heq⟩

end Classical

section QRows

variable {q ℓ d : ℕ} [hp : Fact ℓ.Prime]

/-- **Full `q`-Pascal rows, criterion form.**  Given the Lucas-type indivisibility criterion with
period `d`, the whole `n`-th row of the `q`-Pascal triangle is prime to `ℓ` iff either `n < d`,
or the last base-`d` digit of `n` is `d - 1` and the classical block row `⌊n/d⌋` is full. -/
theorem not_dvd_qBinom_row_iff_crit (hd : 0 < d)
    (hcrit : ∀ n k : ℕ, k ≤ n →
      (¬ ℓ ∣ qBinom q n k ↔ (k % d ≤ n % d ∧ ¬ ℓ ∣ (n / d).choose (k / d)))) (n : ℕ) :
    (∀ k ≤ n, ¬ ℓ ∣ qBinom q n k) ↔
      (n < d ∨ (n % d = d - 1 ∧ ∀ A ≤ n / d, ¬ ℓ ∣ (n / d).choose A)) := by
  have hmod : n % d < d := Nat.mod_lt _ hd
  have hdm := Nat.div_add_mod n d
  constructor
  · intro hfull
    rcases Nat.lt_or_ge n d with hlt | hge
    · exact Or.inl hlt
    refine Or.inr ⟨?_, fun A hA => ?_⟩
    · have hle : d - 1 ≤ n := by omega
      have hstep := (hcrit n (d - 1) hle).mp (hfull _ hle)
      have hdmod : (d - 1) % d = d - 1 := Nat.mod_eq_of_lt (by omega)
      omega
    · have hle : d * A ≤ n := by
        have h1 : d * A ≤ d * (n / d) := Nat.mul_le_mul_left d hA
        omega
      have hstep := (hcrit n (d * A) hle).mp (hfull _ hle)
      rw [Nat.mul_div_cancel_left A hd] at hstep
      exact hstep.2
  · intro hcase k hk
    refine (hcrit n k hk).mpr ?_
    rcases hcase with hlt | ⟨hlast, hblock⟩
    · have hn0 : n / d = 0 := Nat.div_eq_of_lt hlt
      have hk0 : k / d = 0 := Nat.div_eq_of_lt (by omega)
      refine ⟨?_, ?_⟩
      · rw [Nat.mod_eq_of_lt hlt, Nat.mod_eq_of_lt (by omega : k < d)]
        exact hk
      · rw [hn0, hk0]
        simpa using hp.out.ne_one
    · have hkmod : k % d < d := Nat.mod_lt _ hd
      exact ⟨by omega, hblock _ (Nat.div_le_div_right hk)⟩

/-- **Full `q`-Pascal rows, arithmetic form.**  The whole `n`-th `q`-Pascal row is prime to `ℓ`
iff `n + 1 ≤ d` or `n + 1 = d · (c · ℓ ^ t)` for some `1 ≤ c ≤ ℓ`. -/
theorem not_dvd_qBinom_row_iff_crit_arith (hd : 0 < d)
    (hcrit : ∀ n k : ℕ, k ≤ n →
      (¬ ℓ ∣ qBinom q n k ↔ (k % d ≤ n % d ∧ ¬ ℓ ∣ (n / d).choose (k / d)))) (n : ℕ) :
    (∀ k ≤ n, ¬ ℓ ∣ qBinom q n k) ↔
      (n + 1 ≤ d ∨ ∃ c t, 1 ≤ c ∧ c ≤ ℓ ∧ n + 1 = d * (c * ℓ ^ t)) := by
  have hmod : n % d < d := Nat.mod_lt _ hd
  have hdm := Nat.div_add_mod n d
  have hmul : d * (n / d + 1) = d * (n / d) + d := by ring
  rw [not_dvd_qBinom_row_iff_crit hd hcrit n]
  constructor
  · rintro (hlt | ⟨hlast, hblock⟩)
    · exact Or.inl (by omega)
    · obtain ⟨c, t, hc1, hcl, hct⟩ := (not_dvd_choose_row_iff (p := ℓ) (n / d)).mp hblock
      refine Or.inr ⟨c, t, hc1, hcl, ?_⟩
      calc n + 1 = d * (n / d + 1) := by omega
        _ = d * (c * ℓ ^ t) := by rw [hct]
  · rintro (hlt | ⟨c, t, hc1, hcl, hct⟩)
    · exact Or.inl (by omega)
    · have hMpos : 0 < c * ℓ ^ t := Nat.mul_pos (by omega) (Nat.pow_pos hp.out.pos)
      have hge' : n / d + 1 ≤ c * ℓ ^ t := by
        by_contra hcon
        push_neg at hcon
        have : d * (c * ℓ ^ t) ≤ d * (n / d) := Nat.mul_le_mul_left d (by omega)
        omega
      have hle2 : d * (n / d) + d ≤ d * (c * ℓ ^ t) := by
        have := Nat.mul_le_mul_left d hge'
        omega
      have hlast : n % d = d - 1 := by omega
      have heq : d * (n / d + 1) = d * (c * ℓ ^ t) := by omega
      refine Or.inr ⟨hlast, ?_⟩
      exact (not_dvd_choose_row_iff (p := ℓ) (n / d)).mpr
        ⟨c, t, hc1, hcl, Nat.eq_of_mul_eq_mul_left hd heq⟩

/-- **Full `q`-Pascal rows for a `q`-Lucas datum.**  The `n`-th row of the `q`-Pascal triangle
consists entirely of integers prime to `ℓ` if and only if `n + 1 ≤ d` or
`n + 1 = d · c · ℓ ^ t` with `1 ≤ c ≤ ℓ`: the full rows of the `q`-triangle are exactly the
`d`-dilates of the classical full rows, together with the first `d` rows. -/
theorem not_dvd_qBinom_row_iff (h : IsQLucas q ℓ d) (n : ℕ) :
    (∀ k ≤ n, ¬ ℓ ∣ qBinom q n k) ↔
      (n + 1 ≤ d ∨ ∃ c t, 1 ≤ c ∧ c ≤ ℓ ∧ n + 1 = d * (c * ℓ ^ t)) :=
  not_dvd_qBinom_row_iff_crit_arith h.pos (fun _ _ hk => not_dvd_qBinom_iff_lucas h hk) n

/-- **Full `q`-Pascal rows at every prime `ℓ ∤ q`**, with `d = ord_ℓ(q)`.  No oddness hypothesis
is required, and the degenerate case `d = 1` (where the statement reduces to the classical
description of the full rows of Pascal's triangle) is included. -/
theorem not_dvd_qBinom_row_iff_orderOf (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) (n : ℕ) :
    (∀ k ≤ n, ¬ ℓ ∣ qBinom q n k) ↔
      (n + 1 ≤ orderOf ((q : ℕ) : ZMod ℓ) ∨
        ∃ c t, 1 ≤ c ∧ c ≤ ℓ ∧ n + 1 = orderOf ((q : ℕ) : ZMod ℓ) * (c * ℓ ^ t)) :=
  not_dvd_qBinom_row_iff_crit_arith (orderOf_pos_of_not_dvd hnd)
    (fun _ _ hk => not_dvd_qBinom_iff_orderOf hq hnd hk) n

end QRows

section Counting

variable {q ℓ d : ℕ} [hp : Fact ℓ.Prime]

/-- A row is full exactly when its surviving-entry count is maximal. -/
theorem card_row_eq_iff_full (P : ℕ → Prop) [DecidablePred P] (n : ℕ) :
    ((range (n + 1)).filter P).card = n + 1 ↔ ∀ k ≤ n, P k := by
  constructor
  · intro hcard k hk
    have hsub : (range (n + 1)).filter P ⊆ range (n + 1) := Finset.filter_subset _ _
    have heq : (range (n + 1)).filter P = range (n + 1) :=
      Finset.eq_of_subset_of_card_le hsub (by rw [hcard, Finset.card_range])
    have hmem : k ∈ (range (n + 1)).filter P := by
      rw [heq]
      exact Finset.mem_range.mpr (by omega)
    exact (Finset.mem_filter.mp hmem).2
  · intro hfull
    have hfilter : (range (n + 1)).filter P = range (n + 1) := by
      refine Finset.filter_true_of_mem ?_
      intro k hk
      exact hfull k (Nat.lt_succ_iff.mp (Finset.mem_range.mp hk))
    rw [hfilter, Finset.card_range]

/-- **Maximal rows of the `q`-Kummer row count.**  The count
`#{k ≤ n : ℓ ∤ binom(n,k)_q}` attains its maximal possible value `n + 1` exactly for
`n + 1 ≤ d` and for `n + 1 = d · (c · ℓ ^ t)` with `1 ≤ c ≤ ℓ`. -/
theorem card_row_not_dvd_qBinom_eq_succ_iff (h : IsQLucas q ℓ d) (n : ℕ) :
    ((range (n + 1)).filter (fun k => ¬ ℓ ∣ qBinom q n k)).card = n + 1 ↔
      (n + 1 ≤ d ∨ ∃ c t, 1 ≤ c ∧ c ≤ ℓ ∧ n + 1 = d * (c * ℓ ^ t)) := by
  rw [card_row_eq_iff_full, not_dvd_qBinom_row_iff h]

end Counting

section RowMaximum

variable {q ℓ d e : ℕ} [hp : Fact ℓ.Prime]

/-- **The residual entry of a row.**  If `n ≥ d` and the last base-`d` digit of `n` is not maximal
(`n % d < d - 1`), then the entry `k = n % d + 1` forces a base-`d` carry, and its valuation is
exactly `e + v_ℓ(⌊n/d⌋)`.  This is the mechanism that switches the residual term `e` on. -/
theorem padicValNat_qBinom_residual (h : IsQRegular q ℓ d e) {n : ℕ} (hn : d ≤ n)
    (hr : n % d < d - 1) :
    padicValNat ℓ (qBinom q n (n % d + 1)) = e + padicValNat ℓ (n / d) := by
  have hd := h.pos
  have hdm := Nat.div_add_mod n d
  have hmod : n % d < d := Nat.mod_lt _ hd
  set k := n % d + 1 with hkdef
  have hkd : k < d := by omega
  have hk : k ≤ n := by omega
  have hNpos : 1 ≤ n / d := Nat.one_le_div_iff hd |>.mpr hn
  obtain ⟨M, hM⟩ : ∃ M, n / d = M + 1 := ⟨n / d - 1, by omega⟩
  have hmul : d * (M + 1) = d * M + d := by ring
  rw [hM] at hdm
  have hnk : n - k = d * M + (d - 1) := by omega
  have hkmod : k % d = k := Nat.mod_eq_of_lt hkd
  have hkdiv : k / d = 0 := Nat.div_eq_of_lt hkd
  have hnkmod : (n - k) % d = d - 1 := by
    rw [hnk, Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]
  have hnkdiv : (n - k) / d = M := by
    rw [hnk, Nat.mul_add_div hd, Nat.div_eq_of_lt (by omega), Nat.add_zero]
  have hcarry : d ≤ k % d + (n - k) % d := by rw [hkmod, hnkmod]; omega
  rw [qBinom_padicValNat h hk, if_pos hcarry, hkdiv, hnkdiv, hM, Nat.choose_zero_right,
    padicValNat.one]
  omega

/-- **Availability of the residual term.**  For `n ≥ d` whose last base-`d` digit is not maximal,
some entry of the `n`-th `q`-Pascal row has valuation at least `e`.  Together with
`QKummer.not_dvd_qBinom_row_iff` (which shows that the excluded residue `n % d = d - 1` can make
the whole row prime to `ℓ`) this pins down when the residual term contributes to the row
maximum. -/
theorem exists_padicValNat_qBinom_ge_offset (h : IsQRegular q ℓ d e) {n : ℕ} (hn : d ≤ n)
    (hr : n % d < d - 1) : ∃ k ≤ n, e ≤ padicValNat ℓ (qBinom q n k) := by
  have hmod : n % d < d := Nat.mod_lt _ h.pos
  exact ⟨n % d + 1, by omega, by rw [padicValNat_qBinom_residual h hn hr]; omega⟩

end RowMaximum

end QKummer