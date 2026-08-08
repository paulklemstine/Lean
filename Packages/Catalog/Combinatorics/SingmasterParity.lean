/-
# The parity of Singmaster's multiplicity function

Third research cycle.  The empirical mystery quoted in the problem statement is that
no number is known to occur exactly five or exactly seven times, while multiplicities
`1, 2, 3, 4, 6, 8` all occur.  This file isolates the structural reason why *odd*
multiplicities are so rare:

> **`N(t)` is odd if and only if `t` is a central binomial coefficient `C(2m,m)`.**

The proof is a reflection argument.  The symmetry `C(n,k) = C(n,n-k)` is an involution
of the occurrence set `Singmaster.occ t` which exchanges the positions strictly left of
the centre of their row with those strictly right of it; the only positions it fixes
are the central ones `(2m, m)`.  Hence

`N(t) = 2 · #(left positions) + #(central positions)`,

and the central positions are at most one in number, because `m ↦ C(2m,m)` is strictly
increasing.  So an odd multiplicity forces `t = C(2m,m)`.

Consequently the search for a number of multiplicity `5` or `7` can be restricted to
the central binomial coefficients `2, 6, 20, 70, 252, 924, …`.

Main results:
* `Singmaster.mult_eq_two_mul_add_center` — the reflection decomposition;
* `Singmaster.centerOcc_card_le_one` — at most one central occurrence;
* `Singmaster.odd_mult_iff_centralBinom` — the parity criterion;
* `Singmaster.even_mult_of_not_centralBinom` — the contrapositive, in usable form;
* `Singmaster.no_five_or_seven_of_centralBinom_mult_three` — a conditional reduction of
  the `5`/`7` question to the single sequence of central binomial coefficients.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences

open Finset

namespace Singmaster

/-! ## Strict growth of the central binomial coefficients -/

/-- `m ↦ C(2m,m)` is strictly increasing. -/
theorem centralBinom_lt_succ (m : ℕ) : (2 * m).choose m < (2 * (m + 1)).choose (m + 1) := by
  have e1 : (2 * (m + 1)).choose (m + 1)
      = (2 * m + 1).choose m + (2 * m + 1).choose (m + 1) := by
    have h : 2 * (m + 1) = (2 * m + 1) + 1 := by ring
    rw [h, Nat.choose_succ_succ]
  have e2 : (2 * m + 1).choose (m + 1) = (2 * m).choose m + (2 * m).choose (m + 1) :=
    Nat.choose_succ_succ (2 * m) m
  have e3 : 0 < (2 * m + 1).choose m := Nat.choose_pos (by omega)
  omega

/-- Injectivity of `m ↦ C(2m,m)`. -/
theorem centralBinom_injective {m m' : ℕ} (h : (2 * m).choose m = (2 * m').choose m') :
    m = m' := by
  have mono : ∀ p q : ℕ, p < q → (2 * p).choose p < (2 * q).choose q := by
    intro p q hpq
    induction q with
    | zero => omega
    | succ r ih =>
      rcases Nat.lt_or_ge p r with hr | hr
      · exact lt_trans (ih hr) (centralBinom_lt_succ r)
      · have hpr : p = r := by omega
        subst hpr
        exact centralBinom_lt_succ p
  rcases lt_trichotomy m m' with hlt | heq | hgt
  · exact absurd h (Nat.ne_of_lt (mono m m' hlt))
  · exact heq
  · exact absurd h.symm (Nat.ne_of_lt (mono m' m hgt))

/-! ## The reflection decomposition -/

/-- Occurrences strictly left of the centre of their row. -/
def leftOcc (t : ℕ) : Finset (ℕ × ℕ) := (occ t).filter (fun p => 2 * p.2 < p.1)

/-- Occurrences strictly right of the centre of their row. -/
def rightOcc (t : ℕ) : Finset (ℕ × ℕ) := (occ t).filter (fun p => p.1 < 2 * p.2)

/-- Occurrences exactly at the centre of their row. -/
def centerOcc (t : ℕ) : Finset (ℕ × ℕ) := (occ t).filter (fun p => p.1 = 2 * p.2)

theorem mem_leftOcc {t n k : ℕ} : (n, k) ∈ leftOcc t ↔ (n, k) ∈ occ t ∧ 2 * k < n :=
  mem_filter

theorem mem_rightOcc {t n k : ℕ} : (n, k) ∈ rightOcc t ↔ (n, k) ∈ occ t ∧ n < 2 * k :=
  mem_filter

theorem mem_centerOcc {t n k : ℕ} : (n, k) ∈ centerOcc t ↔ (n, k) ∈ occ t ∧ n = 2 * k :=
  mem_filter

theorem occ_eq_union (t : ℕ) : occ t = leftOcc t ∪ (rightOcc t ∪ centerOcc t) := by
  ext p
  simp only [leftOcc, rightOcc, centerOcc, mem_union, mem_filter]
  constructor
  · intro h
    rcases lt_trichotomy (2 * p.2) p.1 with hc | hc | hc
    · exact Or.inl ⟨h, hc⟩
    · exact Or.inr (Or.inr ⟨h, hc.symm⟩)
    · exact Or.inr (Or.inl ⟨h, hc⟩)
  · rintro (⟨h, _⟩ | ⟨h, _⟩ | ⟨h, _⟩) <;> exact h

/-- Reflection is a bijection between the left and the right occurrences. -/
theorem leftOcc_card_eq_rightOcc_card {t : ℕ} (ht : 2 ≤ t) :
    (leftOcc t).card = (rightOcc t).card := by
  classical
  refine Finset.card_bij (fun p _ => (p.1, p.1 - p.2)) ?_ ?_ ?_
  · rintro ⟨n, k⟩ hp
    rw [mem_leftOcc, mem_occ_iff ht] at hp
    obtain ⟨⟨hk, hck⟩, hlt⟩ := hp
    rw [mem_rightOcc, mem_occ_iff ht]
    refine ⟨⟨by omega, ?_⟩, by omega⟩
    rw [Nat.choose_symm hk]
    exact hck
  · rintro ⟨n, k⟩ hp ⟨n', k'⟩ hp' heq
    rw [mem_leftOcc, mem_occ_iff ht] at hp hp'
    rw [Prod.mk.injEq] at heq
    obtain ⟨hn, hk⟩ := heq
    simp only at hn hk
    subst hn
    rw [Prod.mk.injEq]
    exact ⟨rfl, by omega⟩
  · rintro ⟨n, l⟩ hq
    rw [mem_rightOcc, mem_occ_iff ht] at hq
    obtain ⟨⟨hl, hcl⟩, hgt⟩ := hq
    refine ⟨(n, n - l), ?_, ?_⟩
    · rw [mem_leftOcc, mem_occ_iff ht]
      refine ⟨⟨by omega, ?_⟩, by omega⟩
      rw [Nat.choose_symm hl]
      exact hcl
    · rw [Prod.mk.injEq]
      exact ⟨rfl, by omega⟩

/-- **Reflection decomposition of the multiplicity.** -/
theorem mult_eq_two_mul_add_center {t : ℕ} (ht : 2 ≤ t) :
    mult t = 2 * (leftOcc t).card + (centerOcc t).card := by
  classical
  have hdisj1 : Disjoint (rightOcc t) (centerOcc t) := by
    rw [Finset.disjoint_left]
    rintro ⟨n, k⟩ h1 h2
    simp only [rightOcc, centerOcc, mem_filter] at h1 h2
    omega
  have hdisj2 : Disjoint (leftOcc t) (rightOcc t ∪ centerOcc t) := by
    rw [Finset.disjoint_left]
    rintro ⟨n, k⟩ h1 h2
    simp only [leftOcc, rightOcc, centerOcc, mem_union, mem_filter] at h1 h2
    omega
  have hcard : mult t = (leftOcc t).card + ((rightOcc t).card + (centerOcc t).card) := by
    rw [mult, occ_eq_union t, Finset.card_union_of_disjoint hdisj2,
      Finset.card_union_of_disjoint hdisj1]
  rw [hcard, ← leftOcc_card_eq_rightOcc_card ht]
  ring

/-! ## At most one central occurrence -/

theorem centerOcc_card_le_one {t : ℕ} (ht : 2 ≤ t) : (centerOcc t).card ≤ 1 := by
  classical
  refine Finset.card_le_one.2 ?_
  rintro ⟨n, k⟩ h1 ⟨n', k'⟩ h2
  rw [mem_centerOcc, mem_occ_iff ht] at h1 h2
  obtain ⟨⟨_, hv1⟩, he1⟩ := h1
  obtain ⟨⟨_, hv2⟩, he2⟩ := h2
  subst he1
  subst he2
  have hkk : k = k' := centralBinom_injective (by rw [hv1, hv2])
  rw [hkk]

/-- The central occurrence set is nonempty exactly when `t` is a central binomial
coefficient. -/
theorem centerOcc_nonempty_iff {t : ℕ} (ht : 2 ≤ t) :
    (centerOcc t).Nonempty ↔ ∃ m, t = (2 * m).choose m := by
  constructor
  · rintro ⟨⟨n, k⟩, hp⟩
    rw [mem_centerOcc, mem_occ_iff ht] at hp
    obtain ⟨⟨hk, hck⟩, he⟩ := hp
    subst he
    exact ⟨k, hck.symm⟩
  · rintro ⟨m, rfl⟩
    refine ⟨(2 * m, m), ?_⟩
    rw [mem_centerOcc]
    exact ⟨mem_occ ht (by omega) rfl, rfl⟩

/-! ## The parity criterion -/

/-- **The multiplicity of `t` is odd exactly when `t` is a central binomial
coefficient.**  In particular, any number of multiplicity `5` or `7` would have to be
of the form `C(2m,m)`. -/
theorem odd_mult_iff_centralBinom {t : ℕ} (ht : 2 ≤ t) :
    Odd (mult t) ↔ ∃ m, t = (2 * m).choose m := by
  classical
  rw [mult_eq_two_mul_add_center ht]
  constructor
  · intro hodd
    have hc : (centerOcc t).card ≠ 0 := by
      rintro h0
      rw [h0] at hodd
      obtain ⟨r, hr⟩ := hodd
      omega
    have hne : (centerOcc t).Nonempty := Finset.card_pos.1 (by omega)
    exact (centerOcc_nonempty_iff ht).1 hne
  · intro hex
    have hne : (centerOcc t).Nonempty := (centerOcc_nonempty_iff ht).2 hex
    have h1 : 1 ≤ (centerOcc t).card := Finset.card_pos.2 hne
    have h2 : (centerOcc t).card ≤ 1 := centerOcc_card_le_one ht
    exact ⟨(leftOcc t).card, by omega⟩

/-- Contrapositive form: a number that is not a central binomial coefficient occurs an
even number of times. -/
theorem even_mult_of_not_centralBinom {t : ℕ} (ht : 2 ≤ t)
    (h : ∀ m, t ≠ (2 * m).choose m) : Even (mult t) := by
  rcases Nat.even_or_odd (mult t) with he | ho
  · exact he
  · obtain ⟨m, hm⟩ := (odd_mult_iff_centralBinom ht).1 ho
    exact absurd hm (h m)

/-- **Consequence for Singmaster's `5`/`7` question.**  If some number occurs exactly
five (or exactly seven) times, it is a central binomial coefficient. -/
theorem centralBinom_of_mult_five_or_seven {t : ℕ} (ht : 2 ≤ t)
    (h : mult t = 5 ∨ mult t = 7) : ∃ m, t = (2 * m).choose m := by
  refine (odd_mult_iff_centralBinom ht).1 ?_
  rcases h with h | h <;> rw [h]
  · exact ⟨2, by norm_num⟩
  · exact ⟨3, by norm_num⟩

/-- **Conditional resolution of the `5`/`7` question.**  If (as the numerical evidence
suggests) every central binomial coefficient `C(2m,m)` with `m ≥ 2` occurs exactly
three times, then no number occurs exactly five or exactly seven times.

The hypothesis `H` is supplied as an explicit assumption, not as an axiom: this is a
reduction of Singmaster's `5`/`7` question to a statement about the single sequence
`2, 6, 20, 70, 252, 924, …`. -/
theorem no_five_or_seven_of_centralBinom_mult_three
    (H : ∀ m, 2 ≤ m → mult ((2 * m).choose m) = 3) {t : ℕ} (ht : 2 ≤ t) :
    mult t ≠ 5 ∧ mult t ≠ 7 := by
  constructor <;> intro hcon
  · obtain ⟨m, hm⟩ := centralBinom_of_mult_five_or_seven ht (Or.inl hcon)
    rcases Nat.lt_or_ge m 2 with hlt | hge
    · interval_cases m
      · rw [hm] at ht; norm_num at ht
      · rw [hm] at hcon
        norm_num [mult_two] at hcon
    · rw [hm] at hcon
      rw [H m hge] at hcon
      omega
  · obtain ⟨m, hm⟩ := centralBinom_of_mult_five_or_seven ht (Or.inr hcon)
    rcases Nat.lt_or_ge m 2 with hlt | hge
    · interval_cases m
      · rw [hm] at ht; norm_num at ht
      · rw [hm] at hcon
        norm_num [mult_two] at hcon
    · rw [hm] at hcon
      rw [H m hge] at hcon
      omega

end Singmaster