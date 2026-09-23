import Mathlib
import Combinatorics.Core

/-!
# Quartet signatures as ternary codes

A phylogenetic tree is encoded as a word in the ternary cube indexed by quadruples of leaves: each
four-leaf set admits exactly three resolved quartet types, recorded by `code3` and, for the
caterpillar with leaf order `π`, by `qcode π`.  Under this dictionary the catalog predicate
`AgreementSubtrees.AgreeOn` on a four-leaf set becomes *equality of a letter*
(`qcode_eq_of_agreeOn`), so "no common quartet" becomes "no constant coordinate" in a ternary code.

The file proves:

* the exact ternary balance `three_mul_qclass_card` — each of the three types is displayed by
  exactly one third of all leaf orders;
* the first-moment construction `exists_quartet_avoiding_family` and, via the bridge to split
  systems, the exponential lower bound `exponential_lower_bound`:
  `¬ IsAgreementThreshold (3^v) (4v+2) 4`;
* the explicit optimal five-leaf pair `not_isAgreementThreshold_five_two`;
* the adversarial collapse `card_le_three_of_pairwise_full_distance`: over a ternary alphabet a
  family at full Hamming distance has at most three members, so the weaker avoidance notion is
  genuinely needed.

-- !-- Lab Notes -- !--
## Hypothesis (Hypothesizer)
Quartet avoidance is a coding condition: if the ternary signatures of a family of trees never agree
in a coordinate, no four leaves carry a common quartet, and a random code should provide such
families with only logarithmically many trees per leaf.

## Experiment (Experimenter)
The first-moment computation is exact rather than asymptotic because the three quartet types are
exactly equinumerous under right translation by a transposition inside the quartet
(`qclass_card_eq_of_swap`): the probability that `m+1` random leaf orders agree on a fixed quartet
is exactly `3^{-m}`, and there are at most `n^4` ordered quadruples.

## Analysis (Analyst)
The union bound `n^4 < 3^m` costs one tree per `3^{1/4} ≈ 1.316` leaves.  The companion files show
the truth is nearer `1.7` per tree, so the loss is in the union bound, not in the encoding.

## Critique (Critic)
The bridge lemmas `qcode_eq_{zero,one,two}_iff_restrict` are stated in terms of the catalog's own
`restrict`, so the ternary letter is proved to record the actual restriction of the split system,
not a convenient surrogate; and `card_le_three_of_pairwise_full_distance` rules out the naive
"large minimum distance" reading of the conjecture.
-/

open Finset

namespace QuartetCodes

/-- The three resolved quartet types of four (distinct) positions `p q r s`:
`0` means the pairing `{p,q} | {r,s}`, `1` means `{p,r} | {q,s}`, `2` means `{p,s} | {q,r}`. -/
def code3 (p q r s : ℕ) : Fin 3 :=
  if max p q < min r s ∨ max r s < min p q then 0
  else if max p r < min q s ∨ max q s < min p r then 1
  else 2

lemma code3_eq_zero_iff (p q r s : ℕ) :
    code3 p q r s = 0 ↔ (max p q < min r s ∨ max r s < min p q) := by
  unfold code3; split_ifs with h1 h2 <;> simp_all

lemma code3_eq_one_iff (p q r s : ℕ) :
    code3 p q r s = 1 ↔ (max p r < min q s ∨ max q s < min p r) := by
  unfold code3
  split_ifs with h1 h2
  · constructor
    · intro h; exact absurd h (by decide)
    · intro h; exfalso; omega
  · exact iff_of_true rfl h2
  · constructor
    · intro h; exact absurd h (by decide)
    · intro h; exact absurd h h2

lemma code3_eq_two_iff {p q r s : ℕ} (hpq : p ≠ q) (hpr : p ≠ r) (hps : p ≠ s)
    (hqr : q ≠ r) (hqs : q ≠ s) (hrs : r ≠ s) :
    code3 p q r s = 2 ↔ (max p s < min q r ∨ max q r < min p s) := by
  unfold code3
  split_ifs with h1 h2
  · constructor
    · intro h; exact absurd h (by decide)
    · intro h; exfalso; omega
  · constructor
    · intro h; exact absurd h (by decide)
    · intro h; exfalso; omega
  · exact iff_of_true rfl (by omega)

/-- The three code values of `Fin 3` are exhaustive. -/
lemma fin3_cases (x : Fin 3) : x = 0 ∨ x = 1 ∨ x = 2 := by revert x; decide

/-- Transposing the second and third position swaps the quartet types `0` and `1`. -/
lemma code3_swap_23 {p q r s : ℕ} (hpq : p ≠ q) (hpr : p ≠ r) (hps : p ≠ s)
    (hqr : q ≠ r) (hqs : q ≠ s) (hrs : r ≠ s) :
    code3 p r q s = Equiv.swap (0 : Fin 3) 1 (code3 p q r s) := by
  rcases fin3_cases (code3 p q r s) with h | h | h
  · rw [h]
    have h0 := (code3_eq_zero_iff p q r s).1 h
    rw [show (Equiv.swap (0 : Fin 3) 1) 0 = 1 by decide]
    exact (code3_eq_one_iff p r q s).2 (by omega)
  · rw [h]
    have h1 := (code3_eq_one_iff p q r s).1 h
    rw [show (Equiv.swap (0 : Fin 3) 1) 1 = 0 by decide]
    exact (code3_eq_zero_iff p r q s).2 (by omega)
  · rw [h]
    have h2 := (code3_eq_two_iff hpq hpr hps hqr hqs hrs).1 h
    rw [show (Equiv.swap (0 : Fin 3) 1) 2 = 2 by decide]
    exact (code3_eq_two_iff hpr hpq hps (Ne.symm hqr) hrs hqs).2 (by omega)

/-- Transposing the second and fourth position swaps the quartet types `0` and `2`. -/
lemma code3_swap_24 {p q r s : ℕ} (hpq : p ≠ q) (hpr : p ≠ r) (hps : p ≠ s)
    (hqr : q ≠ r) (hqs : q ≠ s) (hrs : r ≠ s) :
    code3 p s r q = Equiv.swap (0 : Fin 3) 2 (code3 p q r s) := by
  rcases fin3_cases (code3 p q r s) with h | h | h
  · rw [h]
    have h0 := (code3_eq_zero_iff p q r s).1 h
    rw [show (Equiv.swap (0 : Fin 3) 2) 0 = 2 by decide]
    exact (code3_eq_two_iff hps hpr hpq (Ne.symm hrs) (Ne.symm hqs) (Ne.symm hqr)).2 (by omega)
  · rw [h]
    have h1 := (code3_eq_one_iff p q r s).1 h
    rw [show (Equiv.swap (0 : Fin 3) 2) 1 = 1 by decide]
    exact (code3_eq_one_iff p s r q).2 (by omega)
  · rw [h]
    have h2 := (code3_eq_two_iff hpq hpr hps hqr hqs hrs).1 h
    rw [show (Equiv.swap (0 : Fin 3) 2) 2 = 0 by decide]
    exact (code3_eq_zero_iff p s r q).2 (by omega)

/-! ## Caterpillar trees and their quartet signatures -/

section Caterpillar

variable {n : ℕ}

/-- The quartet type that the caterpillar tree with leaf order `π` displays on the four leaves
`a b c d`. -/
def qcode (π : Equiv.Perm (Fin n)) (a b c d : Fin n) : Fin 3 :=
  code3 (π a).val (π b).val (π c).val (π d).val

lemma perm_val_ne {π : Equiv.Perm (Fin n)} {x y : Fin n} (h : x ≠ y) :
    (π x).val ≠ (π y).val :=
  fun hh => h (π.injective (Fin.val_injective hh))

/-- Precomposing the leaf order with the transposition of the second and third leaf of a quartet
swaps the quartet types `0` and `1`. -/
lemma qcode_mul_swap_bc {π : Equiv.Perm (Fin n)} {a b c d : Fin n} (hab : a ≠ b) (hac : a ≠ c)
    (had : a ≠ d) (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) :
    qcode (π * Equiv.swap b c) a b c d = Equiv.swap (0 : Fin 3) 1 (qcode π a b c d) := by
  have ha : (π * Equiv.swap b c) a = π a := by
    simp [Equiv.Perm.mul_apply, Equiv.swap_apply_of_ne_of_ne hab hac]
  have hb : (π * Equiv.swap b c) b = π c := by simp [Equiv.Perm.mul_apply]
  have hc : (π * Equiv.swap b c) c = π b := by simp [Equiv.Perm.mul_apply]
  have hd : (π * Equiv.swap b c) d = π d := by
    simp [Equiv.Perm.mul_apply, Equiv.swap_apply_of_ne_of_ne (Ne.symm hbd) (Ne.symm hcd)]
  unfold qcode
  rw [ha, hb, hc, hd]
  exact code3_swap_23 (perm_val_ne hab) (perm_val_ne hac) (perm_val_ne had) (perm_val_ne hbc)
    (perm_val_ne hbd) (perm_val_ne hcd)

/-- Precomposing the leaf order with the transposition of the second and fourth leaf of a quartet
swaps the quartet types `0` and `2`. -/
lemma qcode_mul_swap_bd {π : Equiv.Perm (Fin n)} {a b c d : Fin n} (hab : a ≠ b) (hac : a ≠ c)
    (had : a ≠ d) (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) :
    qcode (π * Equiv.swap b d) a b c d = Equiv.swap (0 : Fin 3) 2 (qcode π a b c d) := by
  have ha : (π * Equiv.swap b d) a = π a := by
    simp [Equiv.Perm.mul_apply, Equiv.swap_apply_of_ne_of_ne hab had]
  have hb : (π * Equiv.swap b d) b = π d := by simp [Equiv.Perm.mul_apply]
  have hc : (π * Equiv.swap b d) c = π c := by
    simp [Equiv.Perm.mul_apply, Equiv.swap_apply_of_ne_of_ne (Ne.symm hbc) hcd]
  have hd : (π * Equiv.swap b d) d = π b := by simp [Equiv.Perm.mul_apply]
  unfold qcode
  rw [ha, hb, hc, hd]
  exact code3_swap_24 (perm_val_ne hab) (perm_val_ne hac) (perm_val_ne had) (perm_val_ne hbc)
    (perm_val_ne hbd) (perm_val_ne hcd)

/-- The set of leaf orders realising a prescribed quartet type on `a b c d`. -/
def qclass (a b c d : Fin n) (t : Fin 3) : Finset (Equiv.Perm (Fin n)) :=
  {π : Equiv.Perm (Fin n) | qcode π a b c d = t}

lemma mem_qclass {a b c d : Fin n} {t : Fin 3} {π : Equiv.Perm (Fin n)} :
    π ∈ qclass a b c d t ↔ qcode π a b c d = t := by
  simp [qclass]

/-- Right translation by a transposition inside the quartet is a bijection between two of the
three code classes. -/
lemma qclass_card_eq_of_swap {a b c d : Fin n} (τ : Equiv.Perm (Fin n)) (σ : Equiv.Perm (Fin 3))
    (hτ : τ * τ = 1) (hσ : σ * σ = 1)
    (hcode : ∀ π : Equiv.Perm (Fin n), qcode (π * τ) a b c d = σ (qcode π a b c d))
    (t : Fin 3) : (qclass a b c d t).card = (qclass a b c d (σ t)).card := by
  have hτ' : ∀ π : Equiv.Perm (Fin n), π * τ * τ = π := by
    intro π; rw [mul_assoc, hτ, mul_one]
  have hσ' : ∀ x : Fin 3, σ (σ x) = x := by
    intro x
    have : (σ * σ) x = (1 : Equiv.Perm (Fin 3)) x := by rw [hσ]
    simpa [Equiv.Perm.mul_apply] using this
  refine Finset.card_nbij' (fun π => π * τ) (fun π => π * τ) ?_ ?_ ?_ ?_
  · intro π hπ
    simp only [Finset.mem_coe, mem_qclass] at hπ ⊢
    rw [hcode, hπ]
  · intro π hπ
    simp only [Finset.mem_coe, mem_qclass] at hπ ⊢
    rw [hcode, hπ, hσ']
  · intro π _; exact hτ' π
  · intro π _; exact hτ' π

/-- **Exact ternary balance.**  For four distinct leaves, each of the three quartet types is
displayed by exactly one third of all leaf orders. -/
lemma three_mul_qclass_card {a b c d : Fin n} (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) (t : Fin 3) :
    3 * (qclass a b c d t).card = Fintype.card (Equiv.Perm (Fin n)) := by
  have hswap01 : ∀ u : Fin 3, (qclass a b c d u).card
      = (qclass a b c d (Equiv.swap (0 : Fin 3) 1 u)).card := by
    refine qclass_card_eq_of_swap (Equiv.swap b c) (Equiv.swap (0 : Fin 3) 1) ?_ ?_ ?_
    · exact Equiv.swap_mul_self b c
    · exact Equiv.swap_mul_self (0 : Fin 3) 1
    · intro π; exact qcode_mul_swap_bc hab hac had hbc hbd hcd
  have hswap02 : ∀ u : Fin 3, (qclass a b c d u).card
      = (qclass a b c d (Equiv.swap (0 : Fin 3) 2 u)).card := by
    refine qclass_card_eq_of_swap (Equiv.swap b d) (Equiv.swap (0 : Fin 3) 2) ?_ ?_ ?_
    · exact Equiv.swap_mul_self b d
    · exact Equiv.swap_mul_self (0 : Fin 3) 2
    · intro π; exact qcode_mul_swap_bd hab hac had hbc hbd hcd
  have h01 : (qclass a b c d 0).card = (qclass a b c d 1).card := by
    simpa using hswap01 0
  have h02 : (qclass a b c d 0).card = (qclass a b c d 2).card := by
    simpa using hswap02 0
  have hsum : Fintype.card (Equiv.Perm (Fin n))
      = ∑ u : Fin 3, (qclass a b c d u).card := by
    rw [← Finset.card_univ]
    simp only [qclass]
    exact Finset.card_eq_sum_card_fiberwise
      (f := fun π : Equiv.Perm (Fin n) => qcode π a b c d)
      (t := (Finset.univ : Finset (Fin 3)))
      (fun x _ => Finset.mem_coe.2 (Finset.mem_univ _))
  rw [hsum, Fin.sum_univ_three]
  rcases fin3_cases t with h | h | h <;> subst h <;> omega

end Caterpillar

/-! ## The counting (first-moment) lower bound -/

section LowerBound

variable {n k : ℕ}

/-- The families of leaf orders that all display one and the same quartet type on `a b c d`. -/
def sameCodeSet (i₀ : Fin k) (a b c d : Fin n) : Finset (Fin k → Equiv.Perm (Fin n)) :=
  {T | ∀ i, qcode (T i) a b c d = qcode (T i₀) a b c d}

lemma mem_sameCodeSet {i₀ : Fin k} {a b c d : Fin n} {T : Fin k → Equiv.Perm (Fin n)} :
    T ∈ sameCodeSet i₀ a b c d ↔ ∀ i, qcode (T i) a b c d = qcode (T i₀) a b c d := by
  simp [sameCodeSet]

/-- The fibre of the type map over `t` inside `sameCodeSet` is the product of the class `t`. -/
lemma sameCodeSet_fiber (i₀ : Fin k) (a b c d : Fin n) (t : Fin 3) :
    {T ∈ sameCodeSet i₀ a b c d | qcode (T i₀) a b c d = t}
      = Fintype.piFinset (fun _ : Fin k => qclass a b c d t) := by
  ext T
  simp only [Finset.mem_filter, mem_sameCodeSet, Fintype.mem_piFinset, mem_qclass]
  constructor
  · rintro ⟨h1, h2⟩ i; rw [h1 i, h2]
  · intro h; exact ⟨fun i => by rw [h i, h i₀], h i₀⟩

/-- The number of families sharing a quartet on a fixed set of four distinct leaves. -/
lemma card_sameCodeSet {a b c d : Fin n} (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) (i₀ : Fin k) :
    (sameCodeSet i₀ a b c d).card = 3 * (qclass a b c d 0).card ^ k := by
  have hfib : (sameCodeSet i₀ a b c d).card
      = ∑ t : Fin 3, (qclass a b c d t).card ^ k := by
    rw [Finset.card_eq_sum_card_fiberwise
      (f := fun T : Fin k → Equiv.Perm (Fin n) => qcode (T i₀) a b c d)
      (t := (Finset.univ : Finset (Fin 3))) (fun x _ => Finset.mem_coe.2 (Finset.mem_univ _))]
    refine Finset.sum_congr rfl fun t _ => ?_
    rw [sameCodeSet_fiber, Fintype.card_piFinset]
    simp
  have hb1 := three_mul_qclass_card hab hac had hbc hbd hcd 1
  have hb2 := three_mul_qclass_card hab hac had hbc hbd hcd 2
  have hb0 := three_mul_qclass_card hab hac had hbc hbd hcd 0
  have e1 : (qclass a b c d 1).card = (qclass a b c d 0).card := by omega
  have e2 : (qclass a b c d 2).card = (qclass a b c d 0).card := by omega
  rw [hfib, Fin.sum_univ_three, e1, e2]
  ring

/-- **Weighted count.**  With `k = m+1` trees, the families sharing a quartet on a fixed set of
four distinct leaves are a `3^m`-th fraction of all families. -/
lemma pow_mul_card_sameCodeSet {m : ℕ} {a b c d : Fin n} (hab : a ≠ b) (hac : a ≠ c) (had : a ≠ d)
    (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) (i₀ : Fin (m + 1)) :
    3 ^ m * (sameCodeSet i₀ a b c d).card = Fintype.card (Equiv.Perm (Fin n)) ^ (m + 1) := by
  have hcls := three_mul_qclass_card hab hac had hbc hbd hcd 0
  rw [card_sameCodeSet hab hac had hbc hbd hcd i₀, ← hcls, mul_pow]
  ring

/-- The set of quadruples of pairwise distinct leaves. -/
def distinctQuads (n : ℕ) : Finset (Fin n × Fin n × Fin n × Fin n) :=
  {q | q.1 ≠ q.2.1 ∧ q.1 ≠ q.2.2.1 ∧ q.1 ≠ q.2.2.2 ∧ q.2.1 ≠ q.2.2.1 ∧ q.2.1 ≠ q.2.2.2 ∧
    q.2.2.1 ≠ q.2.2.2}

lemma card_distinctQuads_le (n : ℕ) : (distinctQuads n).card ≤ n ^ 4 := by
  have h := Finset.card_filter_le (Finset.univ : Finset (Fin n × Fin n × Fin n × Fin n))
    (fun q => q.1 ≠ q.2.1 ∧ q.1 ≠ q.2.2.1 ∧ q.1 ≠ q.2.2.2 ∧ q.2.1 ≠ q.2.2.1 ∧ q.2.1 ≠ q.2.2.2 ∧
      q.2.2.1 ≠ q.2.2.2)
  calc (distinctQuads n).card ≤ (Finset.univ : Finset (Fin n × Fin n × Fin n × Fin n)).card := h
    _ = n ^ 4 := by simp [Finset.card_univ]; ring

/-- **Exponential lower bound.**  If `n^4 < 3^m` then there are `m+1` caterpillar leaf orders on
`n` leaves that display no common quartet: on every four distinct leaves two of them disagree. -/
theorem exists_quartet_avoiding_family (n m : ℕ) (h : n ^ 4 < 3 ^ m) :
    ∃ T : Fin (m + 1) → Equiv.Perm (Fin n), ∀ a b c d : Fin n,
      a ≠ b → a ≠ c → a ≠ d → b ≠ c → b ≠ d → c ≠ d →
      ∃ i j, qcode (T i) a b c d ≠ qcode (T j) a b c d := by
  classical
  set i₀ : Fin (m + 1) := ⟨0, Nat.succ_pos m⟩ with hi₀
  set M := Fintype.card (Equiv.Perm (Fin n)) with hM
  -- the union of the bad events
  set Bad : Finset (Fin (m + 1) → Equiv.Perm (Fin n)) :=
    (distinctQuads n).biUnion (fun q => sameCodeSet i₀ q.1 q.2.1 q.2.2.1 q.2.2.2) with hBad
  have hcard : 3 ^ m * Bad.card ≤ n ^ 4 * M ^ (m + 1) := by
    have h1 : Bad.card ≤ ∑ q ∈ distinctQuads n,
        (sameCodeSet i₀ q.1 q.2.1 q.2.2.1 q.2.2.2).card := Finset.card_biUnion_le
    have h2 : 3 ^ m * Bad.card ≤ ∑ q ∈ distinctQuads n,
        3 ^ m * (sameCodeSet i₀ q.1 q.2.1 q.2.2.1 q.2.2.2).card := by
      rw [← Finset.mul_sum]
      exact Nat.mul_le_mul_left _ h1
    have h3 : ∀ q ∈ distinctQuads n,
        3 ^ m * (sameCodeSet i₀ q.1 q.2.1 q.2.2.1 q.2.2.2).card = M ^ (m + 1) := by
      intro q hq
      simp only [distinctQuads, Finset.mem_filter, Finset.mem_univ, true_and] at hq
      obtain ⟨h1, h2, h3, h4, h5, h6⟩ := hq
      exact pow_mul_card_sameCodeSet h1 h2 h3 h4 h5 h6 i₀
    calc 3 ^ m * Bad.card ≤ ∑ q ∈ distinctQuads n,
          3 ^ m * (sameCodeSet i₀ q.1 q.2.1 q.2.2.1 q.2.2.2).card := h2
      _ = ∑ _q ∈ distinctQuads n, M ^ (m + 1) := Finset.sum_congr rfl h3
      _ = (distinctQuads n).card * M ^ (m + 1) := by rw [Finset.sum_const, smul_eq_mul]
      _ ≤ n ^ 4 * M ^ (m + 1) := Nat.mul_le_mul_right _ (card_distinctQuads_le n)
  have hMpos : 0 < M ^ (m + 1) := pow_pos (Fintype.card_pos) _
  have hlt : Bad.card < M ^ (m + 1) := by
    by_contra hcon
    push_neg at hcon
    have : 3 ^ m * M ^ (m + 1) ≤ n ^ 4 * M ^ (m + 1) :=
      le_trans (Nat.mul_le_mul_left _ hcon) hcard
    have := Nat.le_of_mul_le_mul_right this hMpos
    omega
  have huniv : (Finset.univ : Finset (Fin (m + 1) → Equiv.Perm (Fin n))).card = M ^ (m + 1) := by
    simp [Finset.card_univ, hM]
  have : ∃ T : Fin (m + 1) → Equiv.Perm (Fin n), T ∉ Bad := by
    by_contra hcon
    push_neg at hcon
    have : (Finset.univ : Finset (Fin (m + 1) → Equiv.Perm (Fin n))) ⊆ Bad :=
      fun T _ => hcon T
    have := Finset.card_le_card this
    omega
  obtain ⟨T, hT⟩ := this
  refine ⟨T, fun a b c d hab hac had hbc hbd hcd => ?_⟩
  by_contra hcon
  push_neg at hcon
  refine hT ?_
  rw [hBad, Finset.mem_biUnion]
  refine ⟨(a, b, c, d), ?_, ?_⟩
  · simp [distinctQuads, hab, hac, had, hbc, hbd, hcd]
  · exact mem_sameCodeSet.2 (fun i => hcon i i₀)

end LowerBound

/-! ## Bridge to the split-system language of `Combinatorics.Core` -/

section Bridge

open AgreementSubtrees

variable {n : ℕ}

/-- The split system displayed by the caterpillar tree with leaf order `π`: its splits are the
initial segments of the order. -/
def catSystem (π : Equiv.Perm (Fin n)) : SplitSystem (Fin n) :=
  (Finset.univ : Finset (Fin n)).image (fun t => (Finset.univ : Finset (Fin n)).filter
    (fun x => π x ≤ t))

lemma univ_filter_inter (p : Fin n → Prop) [DecidablePred p] (A : Finset (Fin n)) :
    ((Finset.univ : Finset (Fin n)).filter p) ∩ A = A.filter p := by
  ext x; simp [and_comm]

lemma mem_restrict_catSystem {π : Equiv.Perm (Fin n)} {A S : Finset (Fin n)} :
    S ∈ AgreementSubtrees.restrict (catSystem π) A ↔ ∃ t : Fin n, A.filter (fun x => π x ≤ t) = S := by
  unfold AgreementSubtrees.restrict catSystem
  rw [Finset.image_image]
  simp only [Finset.mem_image, Finset.mem_univ, true_and, Function.comp_apply]
  constructor
  · rintro ⟨t, ht⟩; exact ⟨t, by rw [← univ_filter_inter, ht]⟩
  · rintro ⟨t, ht⟩; exact ⟨t, by rw [univ_filter_inter, ht]⟩

/-- A two-element side is displayed by the restricted caterpillar exactly when its two leaves
precede the other two in the order. -/
lemma pair_mem_restrict_catSystem {π : Equiv.Perm (Fin n)} {a b c d : Fin n} (hac : a ≠ c)
    (had : a ≠ d) (hbc : b ≠ c) (hbd : b ≠ d) :
    ({a, b} : Finset (Fin n)) ∈ AgreementSubtrees.restrict (catSystem π) {a, b, c, d}
      ↔ max (π a).val (π b).val < min (π c).val (π d).val := by
  rw [mem_restrict_catSystem]
  constructor
  · rintro ⟨t, ht⟩
    have ha : π a ≤ t := by
      have : a ∈ ({a, b, c, d} : Finset (Fin n)).filter (fun x => π x ≤ t) := by
        rw [ht]; simp
      exact (Finset.mem_filter.1 this).2
    have hb : π b ≤ t := by
      have : b ∈ ({a, b, c, d} : Finset (Fin n)).filter (fun x => π x ≤ t) := by
        rw [ht]; simp
      exact (Finset.mem_filter.1 this).2
    have hc : ¬ (π c ≤ t) := by
      intro hle
      have : c ∈ ({a, b, c, d} : Finset (Fin n)).filter (fun x => π x ≤ t) :=
        Finset.mem_filter.2 ⟨by simp, hle⟩
      rw [ht] at this
      simp only [Finset.mem_insert, Finset.mem_singleton] at this
      rcases this with rfl | rfl
      · exact hac rfl
      · exact hbc rfl
    have hd : ¬ (π d ≤ t) := by
      intro hle
      have : d ∈ ({a, b, c, d} : Finset (Fin n)).filter (fun x => π x ≤ t) :=
        Finset.mem_filter.2 ⟨by simp, hle⟩
      rw [ht] at this
      simp only [Finset.mem_insert, Finset.mem_singleton] at this
      rcases this with rfl | rfl
      · exact had rfl
      · exact hbd rfl
    rw [Fin.le_def] at ha hb
    rw [Fin.not_le, Fin.lt_def] at hc hd
    omega
  · intro hcond
    refine ⟨max (π a) (π b), ?_⟩
    have hmax : (max (π a) (π b)).val = max (π a).val (π b).val := Fin.coe_max _ _
    ext x
    simp only [Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨hx, hle⟩
      rw [Fin.le_def, hmax] at hle
      rcases hx with rfl | rfl | rfl | rfl
      · exact Or.inl rfl
      · exact Or.inr rfl
      · exact absurd hle (by omega)
      · exact absurd hle (by omega)
    · rintro (rfl | rfl)
      · exact ⟨by simp, le_max_left _ _⟩
      · exact ⟨by simp, le_max_right _ _⟩

/-- The quartet type of a caterpillar is read off from its restricted split system. -/
lemma qcode_eq_zero_iff_restrict {π : Equiv.Perm (Fin n)} {a b c d : Fin n}
    (hac : a ≠ c) (had : a ≠ d) (hbc : b ≠ c) (hbd : b ≠ d) :
    qcode π a b c d = 0 ↔
      (({a, b} : Finset (Fin n)) ∈ AgreementSubtrees.restrict (catSystem π) {a, b, c, d} ∨
        ({c, d} : Finset (Fin n)) ∈ AgreementSubtrees.restrict (catSystem π) {a, b, c, d}) := by
  have hset : ({c, d, a, b} : Finset (Fin n)) = {a, b, c, d} := by
    ext x; simp only [Finset.mem_insert, Finset.mem_singleton]; tauto
  rw [qcode, code3_eq_zero_iff, pair_mem_restrict_catSystem hac had hbc hbd,
    show (AgreementSubtrees.restrict (catSystem π) ({a, b, c, d} : Finset (Fin n)))
      = AgreementSubtrees.restrict (catSystem π) ({c, d, a, b} : Finset (Fin n)) by rw [hset],
    pair_mem_restrict_catSystem (Ne.symm hac) (Ne.symm hbc) (Ne.symm had) (Ne.symm hbd)]

lemma qcode_eq_one_iff_restrict {π : Equiv.Perm (Fin n)} {a b c d : Fin n} (hab : a ≠ b)
    (had : a ≠ d) (hbc : b ≠ c) (hcd : c ≠ d) :
    qcode π a b c d = 1 ↔
      (({a, c} : Finset (Fin n)) ∈ AgreementSubtrees.restrict (catSystem π) {a, b, c, d} ∨
        ({b, d} : Finset (Fin n)) ∈ AgreementSubtrees.restrict (catSystem π) {a, b, c, d}) := by
  have hset1 : ({a, c, b, d} : Finset (Fin n)) = {a, b, c, d} := by
    ext x; simp only [Finset.mem_insert, Finset.mem_singleton]; tauto
  have hset2 : ({b, d, a, c} : Finset (Fin n)) = {a, b, c, d} := by
    ext x; simp only [Finset.mem_insert, Finset.mem_singleton]; tauto
  rw [qcode, code3_eq_one_iff,
    show (AgreementSubtrees.restrict (catSystem π) ({a, b, c, d} : Finset (Fin n)))
      = AgreementSubtrees.restrict (catSystem π) ({a, c, b, d} : Finset (Fin n)) by rw [hset1],
    pair_mem_restrict_catSystem hab had (Ne.symm hbc) hcd]
  rw [show (AgreementSubtrees.restrict (catSystem π) ({a, c, b, d} : Finset (Fin n)))
      = AgreementSubtrees.restrict (catSystem π) ({b, d, a, c} : Finset (Fin n)) by rw [hset1, hset2],
    pair_mem_restrict_catSystem (Ne.symm hab) hbc (Ne.symm had) (Ne.symm hcd)]

lemma qcode_eq_two_iff_restrict {π : Equiv.Perm (Fin n)} {a b c d : Fin n} (hab : a ≠ b)
    (hac : a ≠ c) (had : a ≠ d) (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d) :
    qcode π a b c d = 2 ↔
      (({a, d} : Finset (Fin n)) ∈ AgreementSubtrees.restrict (catSystem π) {a, b, c, d} ∨
        ({b, c} : Finset (Fin n)) ∈ AgreementSubtrees.restrict (catSystem π) {a, b, c, d}) := by
  have hset1 : ({a, d, b, c} : Finset (Fin n)) = {a, b, c, d} := by
    ext x; simp only [Finset.mem_insert, Finset.mem_singleton]; tauto
  have hset2 : ({b, c, a, d} : Finset (Fin n)) = {a, b, c, d} := by
    ext x; simp only [Finset.mem_insert, Finset.mem_singleton]; tauto
  rw [qcode, code3_eq_two_iff (perm_val_ne hab) (perm_val_ne hac) (perm_val_ne had)
      (perm_val_ne hbc) (perm_val_ne hbd) (perm_val_ne hcd),
    show (AgreementSubtrees.restrict (catSystem π) ({a, b, c, d} : Finset (Fin n)))
      = AgreementSubtrees.restrict (catSystem π) ({a, d, b, c} : Finset (Fin n)) by rw [hset1],
    pair_mem_restrict_catSystem hab hac (Ne.symm hbd) (Ne.symm hcd)]
  rw [show (AgreementSubtrees.restrict (catSystem π) ({a, d, b, c} : Finset (Fin n)))
      = AgreementSubtrees.restrict (catSystem π) ({b, c, a, d} : Finset (Fin n)) by rw [hset1, hset2],
    pair_mem_restrict_catSystem (Ne.symm hab) hbd (Ne.symm hac) hcd]

/-- **Agreement forces equal quartet types.**  Two caterpillars agreeing on four distinct leaves
display the same quartet there. -/
lemma qcode_eq_of_agreeOn {π ρ : Equiv.Perm (Fin n)} {a b c d : Fin n} (hab : a ≠ b)
    (hac : a ≠ c) (had : a ≠ d) (hbc : b ≠ c) (hbd : b ≠ d) (hcd : c ≠ d)
    (h : AgreeOn (catSystem π) (catSystem ρ) {a, b, c, d}) :
    qcode π a b c d = qcode ρ a b c d := by
  have hR : AgreementSubtrees.restrict (catSystem π) ({a, b, c, d} : Finset (Fin n))
      = AgreementSubtrees.restrict (catSystem ρ) ({a, b, c, d} : Finset (Fin n)) := h
  rcases fin3_cases (qcode π a b c d) with h0 | h0 | h0
  · rw [h0, eq_comm]
    exact (qcode_eq_zero_iff_restrict hac had hbc hbd).2
      (by rw [← hR]; exact (qcode_eq_zero_iff_restrict hac had hbc hbd).1 h0)
  · rw [h0, eq_comm]
    exact (qcode_eq_one_iff_restrict hab had hbc hcd).2
      (by rw [← hR]; exact (qcode_eq_one_iff_restrict hab had hbc hcd).1 h0)
  · rw [h0, eq_comm]
    exact (qcode_eq_two_iff_restrict hab hac had hbc hbd hcd).2
      (by rw [← hR]; exact (qcode_eq_two_iff_restrict hab hac had hbc hbd hcd).1 h0)

/-- A family of caterpillars displaying no common quartet refutes the corresponding agreement
threshold. -/
theorem not_isAgreementThreshold_of_avoiding {n k : ℕ} (T : Fin k → Equiv.Perm (Fin n))
    (hT : ∀ a b c d : Fin n, a ≠ b → a ≠ c → a ≠ d → b ≠ c → b ≠ d → c ≠ d →
      ∃ i j, qcode (T i) a b c d ≠ qcode (T j) a b c d) :
    ¬ IsAgreementThreshold n k 4 := by
  intro hthr
  obtain ⟨A, hAL, hA4, hcommon⟩ :=
    hthr (Fin n) (Finset.univ : Finset (Fin n)) (fun i => catSystem (T i)) (by simp)
  obtain ⟨A', hA'A, hA'card⟩ := Finset.exists_subset_card_eq hA4
  obtain ⟨a, b, c, d, hab, hac, had, hbc, hbd, hcd, rfl⟩ := Finset.card_eq_four.mp hA'card
  have hc' := commonAgreement_subset hA'A hcommon
  obtain ⟨i, j, hij⟩ := hT a b c d hab hac had hbc hbd hcd
  exact hij (qcode_eq_of_agreeOn hab hac had hbc hbd hcd
    (commonAgreement_agreeOn hc' i (Finset.mem_univ i) j (Finset.mem_univ j)))

/-- **Refutation of an agreement threshold.**  If `n^4 < 3^m` then `m+1` phylogenetic trees on
`n` leaves need not share any quartet, so `n` leaves do not force a common agreement subtree on
four leaves. -/
theorem not_isAgreementThreshold_of_pow_lt (n m : ℕ) (h : n ^ 4 < 3 ^ m) :
    ¬ IsAgreementThreshold n (m + 1) 4 := by
  obtain ⟨T, hT⟩ := exists_quartet_avoiding_family n m h
  exact not_isAgreementThreshold_of_avoiding T hT

/-- **A sharp small case.**  Two explicit caterpillars on five leaves — the identity order and the
order obtained by transposing the second and fourth leaf — display no common quartet.  Hence five
leaves do not force two trees to share a quartet (six leaves do, see the note in
`ComputationalEvidence.md`). -/
theorem not_isAgreementThreshold_five_two : ¬ IsAgreementThreshold 5 2 4 := by
  have key : ∀ a b c d : Fin 5, a ≠ b → a ≠ c → a ≠ d → b ≠ c → b ≠ d → c ≠ d →
      qcode (1 : Equiv.Perm (Fin 5)) a b c d ≠ qcode (Equiv.swap 1 3) a b c d := by decide
  refine not_isAgreementThreshold_of_avoiding ![1, Equiv.swap 1 3] ?_
  intro a b c d hab hac had hbc hbd hcd
  exact ⟨0, 1, key a b c d hab hac had hbc hbd hcd⟩

/-- **Exponential lower bound for the Snir–Yuster threshold.**  For every `v`, some `4v+2` trees
on `3^v` leaves share no quartet: the least leaf number forcing a common quartet for `k` trees is
larger than `3^((k-2)/4)`. -/
theorem exponential_lower_bound (v : ℕ) :
    ¬ IsAgreementThreshold (3 ^ v) (4 * v + 2) 4 := by
  have h : (3 ^ v) ^ 4 < 3 ^ (4 * v + 1) := by
    rw [← pow_mul]
    exact Nat.pow_lt_pow_right (by norm_num) (by omega)
  have := not_isAgreementThreshold_of_pow_lt (3 ^ v) (4 * v + 1) h
  simpa [show 4 * v + 1 + 1 = 4 * v + 2 by omega] using this

end Bridge

/-! ## Adversarial check: pure distance in ternary signature space is too weak -/

section CodingCollapse

/-- **Full-distance ternary codes collapse.**  A family of quartet signatures that pairwise
differ in *every* coordinate has at most three members, no matter how many coordinates there
are.  Hence an exponential family of trees can never be produced by maximising Hamming distance
in quartet-signature space; the first-moment (packing) argument above is genuinely needed. -/
theorem card_le_three_of_pairwise_full_distance {ι : Type*} [DecidableEq ι] (S : Finset ι)
    {N : ℕ} (hN : 0 < N) (c : ι → Fin N → Fin 3)
    (h : ∀ i ∈ S, ∀ j ∈ S, i ≠ j → ∀ p : Fin N, c i p ≠ c j p) :
    S.card ≤ 3 := by
  classical
  have hinj : ∀ i ∈ S, ∀ j ∈ S, c i ⟨0, hN⟩ = c j ⟨0, hN⟩ → i = j := by
    intro i hi j hj hij
    by_contra hne
    exact h i hi j hj hne ⟨0, hN⟩ hij
  have := Finset.card_le_card_of_injOn (t := (Finset.univ : Finset (Fin 3)))
    (fun i => c i ⟨0, hN⟩) (fun i _ => Finset.mem_coe.2 (Finset.mem_univ _))
    (fun i hi j hj hij => hinj i hi j hj hij)
  simpa using this

end CodingCollapse

end QuartetCodes