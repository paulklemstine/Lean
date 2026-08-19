import Mathlib

/-!
# Erdős–Graham: exact coverings by distinct unit fractions (core theory)

The **Erdős–Graham conjecture** (proved by Croot in 2003 by a hard analytic argument)
states: for every finite colouring of the integers `> 1` there is a *monochromatic*
finite set `S` with `∑_{n ∈ S} 1/n = 1`.

This file develops the combinatorial core of the problem:

* the predicate `ErdosGraham.Egyptian S` : a finite set of integers `≥ 2` whose
  reciprocals sum to exactly `1`;
* the *splitting operator* `1/m = 1/(m+1) + 1/(m(m+1))`, which shows the set of
  admissible cardinalities is upward closed, giving Egyptian sets of every size `k ≥ 3`;
* sharp cardinality obstructions: no Egyptian set has `≤ 2` elements, every Egyptian set
  has an element `≤ card` and an element `≥ card`;
* the colouring formalism `ErdosGrahamProperty r`, its monotonicity in `r`, the
  one-colour case, and the *first step of every known proof*: some colour class has
  divergent reciprocal sum (proved from a self-contained dyadic harmonic lower bound
  over `ℚ`).

The obstruction theory (`p`-adic valuations, Egyptian-free sets, and the failure of the
naive converse "divergence ⟹ Egyptian subset") lives in `ErdosGrahamObstructions.lean`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The colouring problem splits into an *analytic* half (some
class is reciprocally large) and an *arithmetic* half (largeness must be converted into
an exact representation of `1`). The arithmetic half has a purely local obstruction.

Experiment (Experimenter): We formalised the splitting operator and verified that the
set of realisable cardinalities of Egyptian sets is exactly `{k : k ≥ 3}`; and we
formalised the pigeonhole step over `ℚ` using the dyadic bound
`∑_{n=2}^{2^k} 1/n ≥ k/2` (proved by induction, no analysis needed).

Analysis (Analyst): The cardinality spectrum `{3,4,5,...}` is *tight*: `k ≤ 2` is
impossible because two distinct denominators `≥ 2` give at most `1/2 + 1/3 < 1`.

Critique (Critic): every statement below is guarded by `2 ≤ n` on members, so no
degenerate `1/0`, `1/1` terms sneak in; the sums are over `Finset`s, so distinctness of
the denominators is automatic and the results are not vacuous (`{2,3,6}` witnesses).
-- !-- Lab Notes -- !--
-/

namespace ErdosGraham

open Finset

/-- `Egyptian S` : the finite set `S` consists of integers `≥ 2` (automatically distinct,
being a `Finset`) and the sum of their reciprocals is exactly `1`. -/
def Egyptian (S : Finset ℕ) : Prop :=
  (∀ n ∈ S, 2 ≤ n) ∧ ∑ n ∈ S, (1 : ℚ) / n = 1

/-- A set `A ⊆ ℕ` is *Egyptian-free* if no finite subset of it has reciprocal sum `1`. -/
def EgyptianFree (A : Set ℕ) : Prop :=
  ∀ S : Finset ℕ, ↑S ⊆ A → ¬ Egyptian S

/-- The `i`-th colour class of a colouring `c` of the integers `≥ 2`. -/
def ColorClass {r : ℕ} (c : ℕ → Fin r) (i : Fin r) : Set ℕ := {n | 2 ≤ n ∧ c n = i}

/-- The reciprocals of `A` have unbounded finite partial sums. -/
def DivergentReciprocals (A : Set ℕ) : Prop :=
  ∀ M : ℚ, ∃ S : Finset ℕ, ↑S ⊆ A ∧ M < ∑ n ∈ S, (1 : ℚ) / n

/-- The Erdős–Graham property for `r` colours: every `r`-colouring of the integers `≥ 2`
admits a monochromatic finite set of reciprocal sum `1`. -/
def ErdosGrahamProperty (r : ℕ) : Prop :=
  ∀ c : ℕ → Fin r, ∃ (S : Finset ℕ) (i : Fin r), Egyptian S ∧ ∀ n ∈ S, c n = i

section Basic

theorem Egyptian.nonempty {S : Finset ℕ} (h : Egyptian S) : S.Nonempty := by
  rcases S.eq_empty_or_nonempty with rfl | hS
  · simp [Egyptian] at h
  · exact hS

/-- The classical witness `1 = 1/2 + 1/3 + 1/6`. -/
theorem egyptian_two_three_six : Egyptian {2, 3, 6} := by
  refine ⟨?_, ?_⟩
  · intro n hn
    fin_cases hn <;> norm_num
  · norm_num

/-- An Egyptian set has an element which is at most its cardinality:
`1 = ∑ 1/n ≤ card / min`. -/
theorem Egyptian.exists_le_card {S : Finset ℕ} (h : Egyptian S) : ∃ n ∈ S, n ≤ S.card := by
  obtain ⟨m, hm, hmin⟩ := S.exists_min_image id h.nonempty
  refine ⟨m, hm, ?_⟩
  have hm2 : 2 ≤ m := h.1 m hm
  have hmpos : (0 : ℚ) < m := by exact_mod_cast Nat.lt_of_lt_of_le two_pos hm2
  have key : (1 : ℚ) ≤ S.card / m := by
    calc (1 : ℚ) = ∑ n ∈ S, (1 : ℚ) / n := h.2.symm
      _ ≤ ∑ n ∈ S, (1 : ℚ) / m := by
          refine Finset.sum_le_sum fun n hn => ?_
          have : (m : ℚ) ≤ n := by exact_mod_cast hmin n hn
          exact one_div_le_one_div_of_le hmpos this
      _ = S.card / m := by rw [Finset.sum_const, nsmul_eq_mul]; ring
  rw [le_div_iff₀ hmpos, one_mul] at key
  exact_mod_cast key

/-- An Egyptian set has an element which is at least its cardinality:
`1 = ∑ 1/n ≥ card / max`. -/
theorem Egyptian.exists_card_le {S : Finset ℕ} (h : Egyptian S) : ∃ n ∈ S, S.card ≤ n := by
  obtain ⟨M, hM, hmax⟩ := S.exists_max_image id h.nonempty
  refine ⟨M, hM, ?_⟩
  have hM2 : 2 ≤ M := h.1 M hM
  have hMpos : (0 : ℚ) < M := by exact_mod_cast Nat.lt_of_lt_of_le two_pos hM2
  have key : (S.card : ℚ) / M ≤ 1 := by
    calc (S.card : ℚ) / M = ∑ _n ∈ S, (1 : ℚ) / M := by
          rw [Finset.sum_const, nsmul_eq_mul]; ring
      _ ≤ ∑ n ∈ S, (1 : ℚ) / n := by
          refine Finset.sum_le_sum fun n hn => ?_
          have hn2 : 2 ≤ n := h.1 n hn
          have hnpos : (0 : ℚ) < n := by exact_mod_cast Nat.lt_of_lt_of_le two_pos hn2
          have : (n : ℚ) ≤ M := by exact_mod_cast hmax n hn
          exact one_div_le_one_div_of_le hnpos this
      _ = 1 := h.2
  rw [div_le_one hMpos] at key
  exact_mod_cast key

/-- **No short Egyptian sets**: one or two distinct unit fractions with denominators `≥ 2`
can never sum to `1`. -/
theorem Egyptian.three_le_card {S : Finset ℕ} (h : Egyptian S) : 3 ≤ S.card := by
  by_contra hc
  push_neg at hc
  have h1 : 1 ≤ S.card := Finset.card_pos.mpr h.nonempty
  interval_cases hcard : S.card
  · obtain ⟨a, rfl⟩ := Finset.card_eq_one.mp hcard
    have ha : 2 ≤ a := h.1 a (by simp)
    have hsum : (1 : ℚ) / a = 1 := by simpa using h.2
    have hapos : (0 : ℚ) < a := by exact_mod_cast Nat.lt_of_lt_of_le two_pos ha
    have : (a : ℚ) = 1 := by field_simp at hsum; linarith
    have : (2 : ℚ) ≤ a := by exact_mod_cast ha
    linarith [this]
  · obtain ⟨a, b, hab, rfl⟩ := Finset.card_eq_two.mp hcard
    have ha : 2 ≤ a := h.1 a (by simp)
    have hb : 2 ≤ b := h.1 b (by simp)
    have hsum : (1 : ℚ) / a + (1 : ℚ) / b = 1 := by
      have h2 := h.2
      rw [Finset.sum_pair hab] at h2
      simpa using h2
    -- the larger of the two denominators is at least `3`
    have key : ∀ x y : ℕ, 2 ≤ x → 3 ≤ y → (1 : ℚ) / x + (1 : ℚ) / y < 1 := by
      intro x y hx hy
      have hx' : (2 : ℚ) ≤ x := by exact_mod_cast hx
      have hy' : (3 : ℚ) ≤ y := by exact_mod_cast hy
      have h1 : (1 : ℚ) / x ≤ 1 / 2 := by
        apply one_div_le_one_div_of_le (by norm_num) hx'
      have h2 : (1 : ℚ) / y ≤ 1 / 3 := by
        apply one_div_le_one_div_of_le (by norm_num) hy'
      linarith
    rcases lt_or_gt_of_ne hab with hlt | hlt
    · have hb3 : 3 ≤ b := by omega
      linarith [key a b ha hb3]
    · have ha3 : 3 ≤ a := by omega
      have := key b a hb ha3
      linarith

/-- The sorted three-term case of `1 = 1/a + 1/b + 1/c` forces `(a, b, c) = (2, 3, 6)`. -/
private lemma egyptian_triple_sorted {a b c : ℕ} (ha : 2 ≤ a) (hab : a < b) (hbc : b < c)
    (h : (1 : ℚ) / a + 1 / b + 1 / c = 1) : a = 2 ∧ b = 3 ∧ c = 6 := by
  have haq : (2 : ℚ) ≤ a := by exact_mod_cast ha
  have ha0 : (0 : ℚ) < a := by linarith
  have habq : (a : ℚ) < b := by exact_mod_cast hab
  have hbcq : (b : ℚ) < c := by exact_mod_cast hbc
  have hb0 : (0 : ℚ) < b := by linarith
  have hc0 : (0 : ℚ) < c := by linarith
  -- first denominator
  have k1 : (1 : ℚ) / b < 1 / a := one_div_lt_one_div_of_lt ha0 habq
  have k2 : (1 : ℚ) / c < 1 / a := one_div_lt_one_div_of_lt ha0 (lt_trans habq hbcq)
  have h3 : (a : ℚ) < 3 := by
    have hlt : (1 : ℚ) < 3 * (1 / a) := by linarith
    rw [mul_one_div, lt_div_iff₀ ha0] at hlt
    linarith
  have ha2 : a = 2 := by
    have : a < 3 := by exact_mod_cast h3
    omega
  subst ha2
  -- second denominator
  have hb3 : 3 ≤ b := by omega
  have hbq : (3 : ℚ) ≤ b := by exact_mod_cast hb3
  have hsum2 : (1 : ℚ) / b + 1 / c = 1 / 2 := by
    have : (1 : ℚ) / ((2 : ℕ) : ℚ) = 1 / 2 := by norm_num
    rw [this] at h
    linarith
  have k3 : (1 : ℚ) / c < 1 / b := one_div_lt_one_div_of_lt hb0 hbcq
  have hb4 : (b : ℚ) < 4 := by
    have hlt : (1 : ℚ) / 2 < 2 * (1 / b) := by linarith
    rw [mul_one_div, lt_div_iff₀ hb0] at hlt
    linarith
  have hb3' : b = 3 := by
    have : b < 4 := by exact_mod_cast hb4
    omega
  subst hb3'
  -- third denominator
  refine ⟨rfl, rfl, ?_⟩
  have hcval : (1 : ℚ) / c = 1 / 6 := by
    have : (1 : ℚ) / ((3 : ℕ) : ℚ) = 1 / 3 := by norm_num
    rw [this] at hsum2
    linarith
  have : (c : ℚ) = 6 := by
    field_simp at hcval
    linarith
  exact_mod_cast this

/-- **Classification of the smallest Egyptian sets.**  The only exact Egyptian covering of
`1` with three distinct denominators is `1 = 1/2 + 1/3 + 1/6`. -/
theorem egyptian_card_three_unique {S : Finset ℕ} (h : Egyptian S) (hcard : S.card = 3) :
    S = {2, 3, 6} := by
  obtain ⟨a, b, c, hab, hac, hbc, rfl⟩ := Finset.card_eq_three.mp hcard
  have ha : 2 ≤ a := h.1 a (by simp)
  have hb : 2 ≤ b := h.1 b (by simp)
  have hc : 2 ≤ c := h.1 c (by simp)
  have hsum : (1 : ℚ) / a + 1 / b + 1 / c = 1 := by
    have h2 := h.2
    rw [Finset.sum_insert (by simp [hab, hac]), Finset.sum_insert (by simp [hbc]),
      Finset.sum_singleton] at h2
    linarith [h2]
  -- run the sorted classification on the correct ordering of `a`, `b`, `c`
  rcases lt_trichotomy a b with h1 | h1 | h1
  · rcases lt_trichotomy b c with h2 | h2 | h2
    · obtain ⟨rfl, rfl, rfl⟩ := egyptian_triple_sorted ha h1 h2 hsum
      rfl
    · exact absurd h2 hbc
    · rcases lt_trichotomy a c with h3 | h3 | h3
      · obtain ⟨rfl, rfl, rfl⟩ := egyptian_triple_sorted ha h3 h2 (by linarith)
        decide
      · exact absurd h3 hac
      · obtain ⟨rfl, rfl, rfl⟩ := egyptian_triple_sorted hc h3 h1 (by linarith)
        decide
  · exact absurd h1 hab
  · rcases lt_trichotomy a c with h2 | h2 | h2
    · obtain ⟨rfl, rfl, rfl⟩ := egyptian_triple_sorted hb h1 h2 (by linarith)
      decide
    · exact absurd h2 hac
    · rcases lt_trichotomy b c with h3 | h3 | h3
      · obtain ⟨rfl, rfl, rfl⟩ := egyptian_triple_sorted hb h3 h2 (by linarith)
        decide
      · exact absurd h3 hbc
      · obtain ⟨rfl, rfl, rfl⟩ := egyptian_triple_sorted hc h3 h1 (by linarith)
        decide

end Basic

section Splitting

/-- **Splitting operator.** If `S` is Egyptian with largest element `m`, then removing `m`
and inserting `m+1` and `m(m+1)` produces an Egyptian set with one more element, whose
largest element is `m(m+1)`.  This is the identity `1/m = 1/(m+1) + 1/(m(m+1))`. -/
theorem egyptian_split {S : Finset ℕ} (h : Egyptian S) {m : ℕ} (hm : m ∈ S)
    (hmax : ∀ n ∈ S, n ≤ m) :
    ∃ T : Finset ℕ, Egyptian T ∧ T.card = S.card + 1 ∧
      (m * (m + 1) ∈ T ∧ ∀ n ∈ T, n ≤ m * (m + 1)) := by
  have hm2 : 2 ≤ m := h.1 m hm
  set T : Finset ℕ := insert (m + 1) (insert (m * (m + 1)) (S.erase m)) with hT
  have hlt : m + 1 < m * (m + 1) := by nlinarith
  have hnot1 : m * (m + 1) ∉ S.erase m := by
    intro hmem
    have := hmax _ (Finset.mem_of_mem_erase hmem)
    omega
  have hnot2 : m + 1 ∉ insert (m * (m + 1)) (S.erase m) := by
    simp only [Finset.mem_insert, not_or]
    refine ⟨by omega, fun hmem => ?_⟩
    have := hmax _ (Finset.mem_of_mem_erase hmem)
    omega
  have hmpos : (0 : ℚ) < m := by exact_mod_cast Nat.lt_of_lt_of_le two_pos hm2
  have hsum_erase : ∑ n ∈ S.erase m, (1 : ℚ) / n = 1 - 1 / m := by
    have := Finset.sum_erase_add S (fun n => (1 : ℚ) / n) hm
    rw [h.2] at this
    linarith [this]
  refine ⟨T, ⟨?_, ?_⟩, ?_, ?_, ?_⟩
  · intro n hn
    rw [hT] at hn
    simp only [Finset.mem_insert] at hn
    rcases hn with rfl | rfl | hn
    · omega
    · nlinarith
    · exact h.1 n (Finset.mem_of_mem_erase hn)
  · rw [hT, Finset.sum_insert hnot2, Finset.sum_insert hnot1, hsum_erase]
    have h1 : ((m : ℚ) + 1) ≠ 0 := by positivity
    push_cast
    field_simp
    ring
  · rw [hT, Finset.card_insert_of_notMem hnot2, Finset.card_insert_of_notMem hnot1,
      Finset.card_erase_of_mem hm]
    have : 1 ≤ S.card := Finset.card_pos.mpr ⟨m, hm⟩
    omega
  · rw [hT]; simp
  · intro n hn
    rw [hT] at hn
    simp only [Finset.mem_insert] at hn
    rcases hn with rfl | rfl | hn
    · omega
    · exact le_rfl
    · have := hmax _ (Finset.mem_of_mem_erase hn)
      nlinarith

/-- **Cardinality spectrum, existence half**: Egyptian sets of every cardinality `k ≥ 3`
exist. Together with `Egyptian.three_le_card` this determines the spectrum exactly. -/
theorem exists_egyptian_card {k : ℕ} (hk : 3 ≤ k) : ∃ S : Finset ℕ, Egyptian S ∧ S.card = k := by
  suffices H : ∀ j : ℕ, ∃ (S : Finset ℕ) (m : ℕ), Egyptian S ∧ S.card = j + 3 ∧ m ∈ S ∧
      ∀ n ∈ S, n ≤ m by
    obtain ⟨S, _, hS, hcard, -⟩ := H (k - 3)
    exact ⟨S, hS, by omega⟩
  intro j
  induction j with
  | zero =>
      refine ⟨{2, 3, 6}, 6, egyptian_two_three_six, by decide, by decide, ?_⟩
      intro n hn; fin_cases hn <;> norm_num
  | succ j ih =>
      obtain ⟨S, m, hS, hcard, hm, hmax⟩ := ih
      obtain ⟨T, hT, hTcard, hmemT, hTmax⟩ := egyptian_split hS hm hmax
      exact ⟨T, m * (m + 1), hT, by omega, hmemT, hTmax⟩

/-- The set of cardinalities realised by Egyptian sets is exactly `{k | 3 ≤ k}`. -/
theorem egyptian_card_spectrum (k : ℕ) :
    (∃ S : Finset ℕ, Egyptian S ∧ S.card = k) ↔ 3 ≤ k := by
  constructor
  · rintro ⟨S, hS, rfl⟩; exact hS.three_le_card
  · exact exists_egyptian_card

end Splitting

section Harmonic

/-- **Dyadic harmonic lower bound** over `ℚ`: `∑_{n=2}^{2^k} 1/n ≥ k/2`.
Proved by induction on `k`; the block `(2^k, 2^{k+1}]` contributes at least `1/2`. -/
theorem half_le_sum_Ioc_two_pow (k : ℕ) :
    (k : ℚ) / 2 ≤ ∑ n ∈ Finset.Ioc 1 (2 ^ k : ℕ), (1 : ℚ) / n := by
  induction k with
  | zero => simp
  | succ k ih =>
      have hsplit := Finset.sum_Ioc_consecutive (fun n : ℕ => (1 : ℚ) / n)
        (m := 1) (n := 2 ^ k) (k := 2 ^ (k + 1)) (Nat.one_le_two_pow)
        (Nat.pow_le_pow_right (by norm_num) (Nat.le_succ k))
      have hblock : (1 : ℚ) / 2 ≤ ∑ n ∈ Finset.Ioc (2 ^ k) (2 ^ (k + 1) : ℕ), (1 : ℚ) / n := by
        have hcard : (Finset.Ioc (2 ^ k) (2 ^ (k + 1) : ℕ)).card = 2 ^ k := by
          rw [Nat.card_Ioc]; ring_nf; omega
        have hlow : ∀ n ∈ Finset.Ioc (2 ^ k) (2 ^ (k + 1) : ℕ),
            (1 : ℚ) / (2 ^ (k + 1)) ≤ (1 : ℚ) / n := by
          intro n hn
          rw [Finset.mem_Ioc] at hn
          have hn0 : (0 : ℚ) < n := by
            have : 0 < n := lt_of_le_of_lt (Nat.zero_le _) (lt_of_le_of_lt (Nat.zero_le _) hn.1)
            exact_mod_cast Nat.pos_of_ne_zero (by omega)
          have hle : (n : ℚ) ≤ 2 ^ (k + 1) := by exact_mod_cast hn.2
          exact one_div_le_one_div_of_le hn0 hle
        have := Finset.card_nsmul_le_sum (Finset.Ioc (2 ^ k) (2 ^ (k + 1) : ℕ))
          (fun n => (1 : ℚ) / n) ((1 : ℚ) / (2 ^ (k + 1))) hlow
        rw [hcard, nsmul_eq_mul] at this
        refine le_trans (le_of_eq ?_) this
        rw [pow_succ]
        push_cast
        field_simp
      rw [← hsplit]
      push_cast
      push_cast at ih
      linarith

/-- The integers `≥ 2` have divergent reciprocal sum. -/
theorem divergentReciprocals_two_le : DivergentReciprocals {n : ℕ | 2 ≤ n} := by
  intro M
  obtain ⟨k, hk⟩ := exists_nat_gt (2 * M + 1)
  refine ⟨Finset.Ioc 1 (2 ^ k : ℕ), ?_, ?_⟩
  · intro n hn
    simp only [Finset.coe_Ioc, Set.mem_Ioc, Set.mem_setOf_eq] at hn ⊢
    omega
  · have := half_le_sum_Ioc_two_pow k
    linarith

/-- **Pigeonhole / first step of the Erdős–Graham programme.**  For any finite colouring
of the integers `≥ 2`, some colour class already has divergent reciprocal sum. -/
theorem exists_divergent_colorClass {r : ℕ} (c : ℕ → Fin r) :
    ∃ i : Fin r, DivergentReciprocals (ColorClass c i) := by
  by_contra hcon
  push_neg at hcon
  have hcon' : ∀ i : Fin r, ∃ M : ℚ, ∀ S : Finset ℕ, ↑S ⊆ ColorClass c i →
      ∑ n ∈ S, (1 : ℚ) / n ≤ M := by
    intro i
    have hi := hcon i
    unfold DivergentReciprocals at hi
    push_neg at hi
    exact hi
  choose M hM using hcon'
  obtain ⟨S, hSsub, hSlt⟩ := divergentReciprocals_two_le (∑ i : Fin r, M i)
  have hsplit : ∑ n ∈ S, (1 : ℚ) / n =
      ∑ i : Fin r, ∑ n ∈ S with c n = i, (1 : ℚ) / n :=
    (Finset.sum_fiberwise S c fun n => (1 : ℚ) / n).symm
  have hle : ∀ i : Fin r, ∑ n ∈ S with c n = i, (1 : ℚ) / n ≤ M i := by
    intro i
    refine hM i _ ?_
    intro n hn
    simp only [Finset.coe_filter, Set.mem_setOf_eq] at hn
    exact ⟨hSsub hn.1, hn.2⟩
  have : ∑ n ∈ S, (1 : ℚ) / n ≤ ∑ i : Fin r, M i := by
    rw [hsplit]
    exact Finset.sum_le_sum fun i _ => hle i
  linarith

end Harmonic

section Colorings

/-- The Erdős–Graham property holds for one colour. -/
theorem erdosGrahamProperty_one : ErdosGrahamProperty 1 := by
  intro c
  refine ⟨{2, 3, 6}, c 2, egyptian_two_three_six, ?_⟩
  intro n _
  exact Subsingleton.elim _ _

/-- The Erdős–Graham property is *antitone* in the number of colours: more colours is a
stronger statement. -/
theorem erdosGrahamProperty_antitone {r s : ℕ} (hrs : r ≤ s) (h : ErdosGrahamProperty s) :
    ErdosGrahamProperty r := by
  intro c
  obtain ⟨S, j, hS, hmono⟩ := h fun n => Fin.castLE hrs (c n)
  obtain ⟨n₀, hn₀⟩ := hS.nonempty
  refine ⟨S, c n₀, hS, fun n hn => ?_⟩
  have h1 := hmono n hn
  have h2 := hmono n₀ hn₀
  exact Fin.castLE_injective hrs (h1.trans h2.symm)

/-- Restricting a colouring to a colour class: if some colour class contains an Egyptian
set, the colouring has a monochromatic Egyptian set. -/
theorem erdosGraham_of_colorClass {r : ℕ} (c : ℕ → Fin r) (i : Fin r) {S : Finset ℕ}
    (hS : Egyptian S) (hsub : ↑S ⊆ ColorClass c i) :
    ∃ (T : Finset ℕ) (j : Fin r), Egyptian T ∧ ∀ n ∈ T, c n = j :=
  ⟨S, i, hS, fun _ hn => (hsub hn).2⟩

end Colorings

end ErdosGraham