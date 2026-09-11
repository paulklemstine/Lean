/-
# Singmaster multiplicity: core structure theory

For `n : ℕ` the *Singmaster multiplicity* `mult n` counts the number of positions
`(N, k)` in Pascal's triangle at which the entry `Nat.choose N k` equals `n`.
Singmaster's conjecture asserts that `mult n` is bounded by an absolute constant
(no value larger than `8` is known, and `8` is attained only by `n = 3003`).

This file develops the structural backbone:

* `Singmaster.occ`, `Singmaster.mult` — the occurrence set and the multiplicity.
* `Singmaster.mem_occ` — the search for occurrences of `n ≥ 2` is automatically
  confined to rows `N ≤ n`; this is what makes `mult` a *finite* count.
* `Singmaster.mult_eq_two_add_interior` — the two "trivial" occurrences
  `n = C(n,1) = C(n,n-1)` split off, leaving the *interior* occurrences.
* `Singmaster.mult_eq_two_mul_lower_add_central` — the reflection `k ↦ N - k`
  pairs interior occurrences off, so the multiplicity is
  `2 * (#lower occurrences) + (#central occurrences)`.
* `Singmaster.centralOcc_card_le_one`, `Singmaster.odd_mult_iff` — there is at most
  one central occurrence, hence `mult n` is odd **iff** `n` is a central binomial
  coefficient.  This is the exact parity obstruction behind "`mult n` is generically
  even".
* `Singmaster.mult_eq_two_of_large_prime_factor` — an arithmetic (as opposed to
  combinatorial) obstruction: if `n` has a prime factor `p` with `p(p-1) > 2n`
  then `n` has no interior occurrence at all, so `mult n = 2`.
  Consequences: `mult p = 2` for every prime `p ≥ 5`, `mult (2p) = 2` for `p ≥ 7`,
  and infinitely many `n` with `mult n = 2`.

Everything is proved from scratch on top of `Mathlib`'s `Nat.choose` API.
-/
import Mathlib

namespace Singmaster

open Finset

/-! ## Monotonicity of `Nat.choose` in the lower index -/

/-- `Nat.choose N ·` is monotone on `[0, N/2]`. -/
theorem choose_le_choose_half {N : ℕ} :
    ∀ {j k : ℕ}, j ≤ k → 2 * k ≤ N → N.choose j ≤ N.choose k := by
  intro j k
  induction k with
  | zero => intro h _; simp [Nat.le_zero.mp h]
  | succ m ih =>
    intro hjk hk
    rcases Nat.lt_or_ge j (m + 1) with h | h
    · exact (ih (by omega) (by omega)).trans (Nat.choose_le_succ_of_lt_half_left (by omega))
    · have hj : j = m + 1 := by omega
      subst hj; exact le_refl _

/-- If `j ≤ k` and `j + k ≤ N` then `C(N,j) ≤ C(N,k)`: the binomial row increases
as one moves from an outer index towards the centre. -/
theorem choose_le_choose_left {N j k : ℕ} (hjk : j ≤ k) (hk : j + k ≤ N) :
    N.choose j ≤ N.choose k := by
  rcases Nat.lt_or_ge N (2 * k) with h | h
  · have hkN : k ≤ N := by omega
    rw [← Nat.choose_symm hkN]
    exact choose_le_choose_half (by omega) (by omega)
  · exact choose_le_choose_half hjk h

/-- A non-trivial binomial coefficient in row `N` is at least `N`. -/
theorem self_le_choose {N k : ℕ} (h1 : 1 ≤ k) (h2 : 1 + k ≤ N) : N ≤ N.choose k := by
  have := choose_le_choose_left (N := N) (j := 1) h1 h2
  rwa [Nat.choose_one_right] at this

theorem two_mul_choose_two (N : ℕ) : 2 * N.choose 2 = N * (N - 1) := by
  rw [Nat.choose_two_right]
  exact Nat.two_mul_div_two_of_even (Nat.even_mul_pred_self N)

/-- The fundamental *row bound*: an interior occurrence of `n` in row `N` forces
`N(N-1) ≤ 2n`, i.e. `N = O(√n)`. -/
theorem mul_pred_le_of_choose_eq {N k n : ℕ} (h1 : 2 ≤ k) (h2 : 2 + k ≤ N)
    (h : N.choose k = n) : N * (N - 1) ≤ 2 * n := by
  have h3 := choose_le_choose_left (N := N) (j := 2) h1 h2
  rw [h] at h3
  have h4 := two_mul_choose_two N
  omega

theorem choose_pred_self {N : ℕ} (hN : 1 ≤ N) : N.choose (N - 1) = N := by
  have h : N - (N - 1) = 1 := by omega
  have := Nat.choose_symm (n := N) (k := N - 1) (by omega)
  rw [h, Nat.choose_one_right] at this
  exact this.symm

/-! ## The occurrence set and the multiplicity -/

/-- All positions `(N, k)` of Pascal's triangle, with `N, k ≤ n`, carrying the value `n`.
For `n ≥ 2` the cut-off `N ≤ n` is vacuous (see `mem_occ`), so this really is the set of
*all* occurrences of `n` in Pascal's triangle. -/
def occ (n : ℕ) : Finset (ℕ × ℕ) :=
  ((range (n + 1)) ×ˢ (range (n + 1))).filter (fun p => p.2 ≤ p.1 ∧ p.1.choose p.2 = n)

/-- The Singmaster multiplicity of `n`: the number of times `n` occurs in Pascal's triangle. -/
def mult (n : ℕ) : ℕ := (occ n).card

/-- Any occurrence of `n ≥ 2` lies in a row `N ≤ n`. -/
theorem occ_bound {N k n : ℕ} (hn : 2 ≤ n) (hk : k ≤ N) (h : N.choose k = n) : N ≤ n := by
  rcases Nat.eq_zero_or_pos k with rfl | hk0
  · rw [Nat.choose_zero_right] at h; omega
  rcases eq_or_lt_of_le hk with rfl | hlt
  · rw [Nat.choose_self] at h; omega
  · have := self_le_choose (N := N) (k := k) hk0 (by omega)
    omega

theorem mem_occ {n : ℕ} (hn : 2 ≤ n) {N k : ℕ} :
    (N, k) ∈ occ n ↔ k ≤ N ∧ N.choose k = n := by
  simp only [occ, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  constructor
  · rintro ⟨-, h⟩; exact h
  · rintro ⟨hk, h⟩
    have hN : N ≤ n := occ_bound hn hk h
    exact ⟨⟨by omega, by omega⟩, hk, h⟩

/-- The *interior* occurrences: those with `2 ≤ k ≤ N - 2`. -/
def interiorOcc (n : ℕ) : Finset (ℕ × ℕ) :=
  (occ n).filter (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1)

theorem mem_interiorOcc {n : ℕ} (hn : 2 ≤ n) {N k : ℕ} :
    (N, k) ∈ interiorOcc n ↔ 2 ≤ k ∧ k + 2 ≤ N ∧ N.choose k = n := by
  simp only [interiorOcc, Finset.mem_filter, mem_occ hn]
  constructor
  · rintro ⟨⟨-, hc⟩, h2, h3⟩; exact ⟨h2, h3, hc⟩
  · rintro ⟨h2, h3, hc⟩; exact ⟨⟨by omega, hc⟩, h2, h3⟩

theorem interiorOcc_subset (n : ℕ) : interiorOcc n ⊆ occ n := Finset.filter_subset _ _

theorem occ_sdiff_interiorOcc {n : ℕ} (hn : 3 ≤ n) :
    occ n \ interiorOcc n = {(n, 1), (n, n - 1)} := by
  have hn2 : 2 ≤ n := by omega
  ext p
  obtain ⟨N, k⟩ := p
  simp only [Finset.mem_sdiff, mem_occ hn2, mem_interiorOcc hn2, Finset.mem_insert,
    Finset.mem_singleton, Prod.mk.injEq, not_and]
  constructor
  · rintro ⟨⟨hk, hc⟩, hni⟩
    have hcase : k ≤ 1 ∨ N ≤ k + 1 := by
      by_contra hcon
      push_neg at hcon
      exact absurd hc (hni (by omega) (by omega))
    rcases hcase with h | h
    · interval_cases k
      · rw [Nat.choose_zero_right] at hc; omega
      · rw [Nat.choose_one_right] at hc; exact Or.inl ⟨hc, rfl⟩
    · rcases eq_or_lt_of_le hk with rfl | hlt
      · rw [Nat.choose_self] at hc; omega
      · have hkk : k = N - 1 := by omega
        subst hkk
        rw [choose_pred_self (by omega)] at hc
        exact Or.inr ⟨hc, by omega⟩
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact ⟨⟨by omega, Nat.choose_one_right _⟩, by intro h; omega⟩
    · exact ⟨⟨by omega, choose_pred_self (by omega)⟩, by intro _ h; omega⟩

/-- **Trivial-occurrence splitting.** For `n ≥ 3` the two boundary occurrences
`n = C(n,1) = C(n,n-1)` are always present and distinct, so the multiplicity is
`2` plus the number of interior occurrences. -/
theorem mult_eq_two_add_interior {n : ℕ} (hn : 3 ≤ n) :
    mult n = 2 + (interiorOcc n).card := by
  have h := Finset.card_sdiff_add_card_eq_card (interiorOcc_subset n)
  rw [occ_sdiff_interiorOcc hn] at h
  have hcard : ({(n, 1), (n, n - 1)} : Finset (ℕ × ℕ)).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; omega), Finset.card_singleton]
  rw [hcard] at h
  unfold mult
  omega

/-! ## The reflection `k ↦ N - k` and the parity of `mult` -/

def lowerOcc (n : ℕ) : Finset (ℕ × ℕ) := (occ n).filter (fun p => 2 * p.2 < p.1)
def upperOcc (n : ℕ) : Finset (ℕ × ℕ) := (occ n).filter (fun p => p.1 < 2 * p.2)
def centralOcc (n : ℕ) : Finset (ℕ × ℕ) := (occ n).filter (fun p => p.1 = 2 * p.2)

theorem card_lowerOcc_eq_card_upperOcc {n : ℕ} (hn : 2 ≤ n) :
    (lowerOcc n).card = (upperOcc n).card := by
  refine Finset.card_bij' (fun p _ => (p.1, p.1 - p.2)) (fun q _ => (q.1, q.1 - q.2))
    ?_ ?_ ?_ ?_
  · rintro ⟨N, k⟩ hp
    simp only [lowerOcc, Finset.mem_filter, mem_occ hn] at hp
    simp only [upperOcc, Finset.mem_filter, mem_occ hn]
    obtain ⟨⟨hk, hc⟩, hlt⟩ := hp
    exact ⟨⟨by omega, by rw [Nat.choose_symm hk]; exact hc⟩, by omega⟩
  · rintro ⟨N, k⟩ hq
    simp only [upperOcc, Finset.mem_filter, mem_occ hn] at hq
    simp only [lowerOcc, Finset.mem_filter, mem_occ hn]
    obtain ⟨⟨hk, hc⟩, hlt⟩ := hq
    exact ⟨⟨by omega, by rw [Nat.choose_symm hk]; exact hc⟩, by omega⟩
  · rintro ⟨N, k⟩ hp
    simp only [lowerOcc, Finset.mem_filter, mem_occ hn] at hp
    have hkk : N - (N - k) = k := by omega
    simp [hkk]
  · rintro ⟨N, k⟩ hq
    simp only [upperOcc, Finset.mem_filter, mem_occ hn] at hq
    have hkk : N - (N - k) = k := by omega
    simp [hkk]

theorem occ_eq_union (n : ℕ) : occ n = lowerOcc n ∪ upperOcc n ∪ centralOcc n := by
  ext p
  simp only [Finset.mem_union, lowerOcc, upperOcc, centralOcc, Finset.mem_filter]
  constructor
  · intro h
    rcases Nat.lt_trichotomy p.1 (2 * p.2) with hh | hh | hh
    · exact Or.inl (Or.inr ⟨h, hh⟩)
    · exact Or.inr ⟨h, hh⟩
    · exact Or.inl (Or.inl ⟨h, hh⟩)
  · rintro ((⟨h, -⟩ | ⟨h, -⟩) | ⟨h, -⟩) <;> exact h

theorem card_occ_eq (n : ℕ) :
    mult n = (lowerOcc n).card + (upperOcc n).card + (centralOcc n).card := by
  have hdlu : Disjoint (lowerOcc n) (upperOcc n) := by
    simp only [Finset.disjoint_left, lowerOcc, upperOcc, Finset.mem_filter]
    rintro p ⟨-, h1⟩ ⟨-, h2⟩; omega
  have hdc : Disjoint (lowerOcc n ∪ upperOcc n) (centralOcc n) := by
    simp only [Finset.disjoint_left, lowerOcc, upperOcc, centralOcc, Finset.mem_union,
      Finset.mem_filter]
    rintro p (⟨-, h1⟩ | ⟨-, h1⟩) ⟨-, h2⟩ <;> omega
  unfold mult
  rw [occ_eq_union n, Finset.card_union_of_disjoint hdc, Finset.card_union_of_disjoint hdlu]

/-- **Reflection decomposition.** `mult n = 2 · (#lower occurrences) + (#central occurrences)`. -/
theorem mult_eq_two_mul_lower_add_central {n : ℕ} (hn : 2 ≤ n) :
    mult n = 2 * (lowerOcc n).card + (centralOcc n).card := by
  rw [card_occ_eq n, ← card_lowerOcc_eq_card_upperOcc hn]
  ring

/-! ## Central binomial coefficients -/

theorem centralBinom_lt_succ (m : ℕ) : Nat.centralBinom m < Nat.centralBinom (m + 1) := by
  have h := Nat.succ_mul_centralBinom_succ m
  have hpos := Nat.centralBinom_pos m
  nlinarith [Nat.centralBinom_pos (m + 1)]

theorem centralBinom_strictMono : StrictMono Nat.centralBinom :=
  strictMono_nat_of_lt_succ centralBinom_lt_succ

theorem centralBinom_injective : Function.Injective Nat.centralBinom :=
  centralBinom_strictMono.injective

/-- At most one row of Pascal's triangle has its central entry equal to `n`. -/
theorem centralOcc_card_le_one (n : ℕ) : (centralOcc n).card ≤ 1 := by
  rw [Finset.card_le_one]
  rintro ⟨N₁, k₁⟩ h₁ ⟨N₂, k₂⟩ h₂
  simp only [centralOcc, occ, Finset.mem_filter, Finset.mem_product, Finset.mem_range] at h₁ h₂
  obtain ⟨⟨-, -, hc₁⟩, he₁⟩ := h₁
  obtain ⟨⟨-, -, hc₂⟩, he₂⟩ := h₂
  subst he₁; subst he₂
  have : Nat.centralBinom k₁ = Nat.centralBinom k₂ := by
    unfold Nat.centralBinom; rw [hc₁, hc₂]
  have hk := centralBinom_injective this
  simp [hk]

/-- `mult n` is odd exactly when `n` is a central binomial coefficient. -/
theorem odd_mult_iff {n : ℕ} (hn : 2 ≤ n) :
    Odd (mult n) ↔ ∃ m, Nat.centralBinom m = n := by
  rw [mult_eq_two_mul_lower_add_central hn]
  constructor
  · intro h
    have hc : (centralOcc n).card ≠ 0 := by
      rcases Nat.eq_zero_or_pos (centralOcc n).card with h0 | h0
      · rw [h0] at h; simp [Nat.odd_iff] at h
      · omega
    obtain ⟨p, hp⟩ := Finset.card_pos.mp (Nat.pos_of_ne_zero hc)
    obtain ⟨N, k⟩ := p
    simp only [centralOcc, occ, Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hp
    obtain ⟨⟨-, -, hcc⟩, he⟩ := hp
    subst he
    exact ⟨k, hcc⟩
  · rintro ⟨m, hm⟩
    have hm' : (2 * m).choose m = n := hm
    have hmem : ((2 * m, m) : ℕ × ℕ) ∈ centralOcc n := by
      simp only [centralOcc, Finset.mem_filter, mem_occ hn]
      refine ⟨⟨by omega, hm'⟩, ?_⟩
      simp
    have h1 : 1 ≤ (centralOcc n).card := Finset.card_pos.mpr ⟨_, hmem⟩
    have h2 := centralOcc_card_le_one n
    have : (centralOcc n).card = 1 := by omega
    rw [this]
    exact ⟨(lowerOcc n).card, by ring⟩

/-! ## An arithmetic obstruction: large prime factors force `mult n = 2` -/

/-- Every prime factor of `C(N,k)` is at most `N`. -/
theorem prime_le_of_dvd_choose {N k p : ℕ} (hp : p.Prime) (hk : k ≤ N)
    (hdvd : p ∣ N.choose k) : p ≤ N := by
  have hdvd' : N.choose k ∣ Nat.factorial N := by
    refine ⟨Nat.factorial k * Nat.factorial (N - k), ?_⟩
    rw [← Nat.choose_mul_factorial_mul_factorial hk]; ring
  exact (Nat.Prime.dvd_factorial hp).mp (hdvd.trans hdvd')

/-- If `n` has a prime factor `p` so large that `p(p-1) > 2n`, then `n` has no interior
occurrence in Pascal's triangle. -/
theorem interiorOcc_eq_empty_of_large_prime_factor {n p : ℕ} (hn : 2 ≤ n) (hp : p.Prime)
    (hpn : p ∣ n) (hbig : 2 * n < p * (p - 1)) : interiorOcc n = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  rintro ⟨N, k⟩ hmem
  rw [mem_interiorOcc hn] at hmem
  obtain ⟨h2, h3, hc⟩ := hmem
  have hpN : p ≤ N :=
    prime_le_of_dvd_choose (N := N) (k := k) hp (by omega) (by rw [hc]; exact hpn)
  have hrow : N * (N - 1) ≤ 2 * n := mul_pred_le_of_choose_eq h2 (by omega) hc
  have : p * (p - 1) ≤ N * (N - 1) := Nat.mul_le_mul hpN (by omega)
  omega

/-- **Arithmetic obstruction to Singmaster occurrences.** -/
theorem mult_eq_two_of_large_prime_factor {n p : ℕ} (hn : 3 ≤ n) (hp : p.Prime)
    (hpn : p ∣ n) (hbig : 2 * n < p * (p - 1)) : mult n = 2 := by
  rw [mult_eq_two_add_interior hn,
    interiorOcc_eq_empty_of_large_prime_factor (by omega) hp hpn hbig]
  simp

/-- A prime `p ≥ 5` occurs exactly twice in Pascal's triangle. -/
theorem mult_prime {p : ℕ} (hp : p.Prime) (h5 : 5 ≤ p) : mult p = 2 := by
  refine mult_eq_two_of_large_prime_factor (by omega) hp dvd_rfl ?_
  have : 3 * p ≤ p * (p - 1) := by
    have : 3 ≤ p - 1 := by omega
    calc 3 * p = p * 3 := by ring
    _ ≤ p * (p - 1) := Nat.mul_le_mul_left p this
  omega

/-- Twice a prime `p ≥ 7` occurs exactly twice in Pascal's triangle. -/
theorem mult_two_mul_prime {p : ℕ} (hp : p.Prime) (h7 : 7 ≤ p) : mult (2 * p) = 2 := by
  refine mult_eq_two_of_large_prime_factor (by omega) hp ⟨2, by ring⟩ ?_
  have : 5 * p ≤ p * (p - 1) := by
    have : 5 ≤ p - 1 := by omega
    calc 5 * p = p * 5 := by ring
    _ ≤ p * (p - 1) := Nat.mul_le_mul_left p this
  omega

/-- Infinitely many integers occur exactly twice in Pascal's triangle. -/
theorem infinite_mult_eq_two : {n : ℕ | mult n = 2}.Infinite := by
  apply Set.infinite_of_not_bddAbove
  rintro ⟨B, hB⟩
  obtain ⟨p, hpB, hp⟩ := Nat.exists_infinite_primes (max (B + 1) 5)
  have h5 : 5 ≤ p := le_trans (le_max_right _ _) hpB
  have hmem : p ∈ {n : ℕ | mult n = 2} := mult_prime hp h5
  have := hB hmem
  have : B + 1 ≤ p := le_trans (le_max_left _ _) hpB
  omega

end Singmaster