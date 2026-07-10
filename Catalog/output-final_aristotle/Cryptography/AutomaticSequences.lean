/-
  # Automatic Sequences and the Decidability of the "Zero-in-Sequence" Problem

  An *automatic sequence* `(aₙ)` is one whose `n`-th term is computed by a
  deterministic finite automaton (DFA) reading the base-`k` digits of `n`.
  The Thue–Morse sequence `0110100110010110…` (OEIS A010060) is the canonical
  example: `aₙ` is the parity of the number of `1`s in the binary expansion of
  `n`, computed by a two–state automaton.

  A recurring theme in this area is the *decidability* of the "zero-in-sequence"
  (or *halting*) problem: given the automaton, decide whether the sequence ever
  takes the value `0`.  For automatic sequences this reduces to deciding whether
  the underlying DFA accepts **any** word, i.e. whether its accepted language is
  nonempty.  We prove:

  * `accepts_nonempty_iff_bddWitness` — the language is nonempty **iff** it
    contains a word shorter than the number of states.  (Reachability bound.)
  * `decidableAcceptsNonempty` — consequently, nonemptiness (= the
    zero-in-sequence problem) is **decidable**: search all words of length
    `< card σ`.

  We also settle the finer *"zero infinitely often"* question and, in doing so,
  correct a common misstatement.  It is **not** true that "a DFA that accepts any
  string accepts infinitely many" (a DFA can accept exactly one word).  The
  correct statement, which we prove, is the pumping-lemma dichotomy:

  * `accepts_infinite_of_long` — a word of length `≥ card σ` forces the language
    to be infinite (pump upward).
  * `accepts_infinite_iff` — the language is infinite **iff** it contains a word
    of length `≥ card σ`.
  * `accepts_infinite_iff_bounded` — infinitude is witnessed by a word of length
    in the interval `[card σ, 2·card σ)`, hence
  * `decidableAcceptsInfinite` — infinitude is **decidable** too.

  Finally we exhibit the concrete Thue–Morse automaton, verify the automatic
  recurrences `t(2n) = t(n)`, `t(2n+1) = t(n)+1`, and instantiate the general
  decidability results on it.

  Everything is built on `Mathlib.Computability.DFA`.
-/
import Mathlib

open Computability

namespace AutomaticSeq

variable {α : Type*} {σ : Type*} (M : DFA α σ)

/-! ## Pumping downward: a long accepted word can be shortened -/

/-
**Pump-down core.**  If `M` accepts a word `x` at least as long as the number
of states, then `x` decomposes as `a ++ b ++ c` with a nonempty pumpable block
`b` (of controlled size) such that the *deflated* word `a ++ c` is still
accepted.  This is `DFA.pumping_lemma` specialised to the `0`-th power.
-/
theorem exists_pump_down [Fintype σ] {x : List α}
    (hx : x ∈ M.accepts) (hlen : Fintype.card σ ≤ x.length) :
    ∃ a b c : List α,
      x = a ++ b ++ c ∧ b ≠ [] ∧ a.length + b.length ≤ Fintype.card σ ∧
        a ++ c ∈ M.accepts := by
  obtain ⟨a, b, c, habc, hlen, hb_ne⟩ : ∃ a b c, x = a ++ b ++ c ∧ a.length + b.length ≤ Fintype.card σ ∧ b ≠ [] ∧ ∀ k : ℕ, M.eval (a ++ List.flatten (List.replicate k b) ++ c) ∈ M.accept := by
    obtain ⟨a, b, c, habc, hlen, hb_ne⟩ : ∃ a b c, x = a ++ b ++ c ∧ a.length + b.length ≤ Fintype.card σ ∧ b ≠ [] ∧ M.eval (a ++ b) = M.eval a ∧ M.eval (a ++ b ++ c) ∈ M.accept := by
      obtain ⟨i, j, hij, hpath⟩ : ∃ i j, i < j ∧ j ≤ Fintype.card σ ∧ M.eval (List.take i x) = M.eval (List.take j x) := by
        by_contra! h' ; have := Fintype.card_le_of_injective ( fun i : Fin ( Fintype.card σ + 1 ) ↦ M.eval ( List.take i x ) ) ( fun i j hij ↦ le_antisymm ( not_lt.mp fun hi ↦ h' _ _ hi ( by linarith [ Fin.is_lt i, Fin.is_lt j ] ) hij.symm ) ( not_lt.mp fun hj ↦ h' _ _ hj ( by linarith [ Fin.is_lt i, Fin.is_lt j ] ) hij ) ) ; simp_all +decide ;
      refine' ⟨ List.take i x, List.drop i x |>.take ( j - i ), List.drop j x, _, _, _, _ ⟩ <;> simp_all +decide;
      · simp +decide [ ← List.append_assoc, ← List.take_add, hij.le ];
      · grind;
      · exact ⟨ Nat.sub_ne_zero_of_lt hij, lt_of_lt_of_le hij ( le_trans hpath.1 hlen ) ⟩;
      · rw [ ← List.append_assoc, ← List.take_add ];
        rw [ add_tsub_cancel_of_le hij.le ] ; aesop;
    refine' ⟨ a, b, c, habc, hlen, hb_ne.1, fun k => _ ⟩;
    induction' k with k ih <;> simp_all +decide [ List.replicate ];
    · simp_all +decide [ DFA.eval, DFA.evalFrom ];
      grobner;
    · simp_all +decide [ DFA.eval ];
      simp_all +decide [ ← List.append_assoc, DFA.evalFrom ];
  exact ⟨ a, b, c, habc, hb_ne.1, hlen, by simpa using hb_ne.2 0 ⟩

/-
A word of length `≥ card σ` is never a shortest accepted word: it can always
be shortened while staying in the language.
-/
theorem exists_shorter_of_long [Fintype σ] {x : List α}
    (hx : x ∈ M.accepts) (hlen : Fintype.card σ ≤ x.length) :
    ∃ y ∈ M.accepts, y.length < x.length := by
  obtain ⟨ a, b, c, rfl, hb, hbc, hac ⟩ := exists_pump_down M hx hlen; exact ⟨ a ++ c, hac, by simp +arith +decide ; linarith [ List.length_pos_of_ne_nil hb ] ⟩ ;

/-! ## Reachability bound and decidability of emptiness -/

/-
**Reachability bound.**  A DFA's language is nonempty iff it already contains
a word shorter than the number of states.  (The forward direction is the pumping
argument: repeatedly shorten a witness until it drops below `card σ`.)
-/
theorem accepts_nonempty_iff_bddWitness [Fintype σ] :
    M.accepts.Nonempty ↔ ∃ x ∈ M.accepts, x.length < Fintype.card σ := by
  constructor;
  · intro h_nonempty
    obtain ⟨x, hx⟩ := h_nonempty
    induction' n : x.length using Nat.strong_induction_on with n ih generalizing x;
    exact if h : Fintype.card σ ≤ x.length then by obtain ⟨ y, hy ⟩ := exists_shorter_of_long M hx h; exact ih _ ( by linarith ) _ hy.1 rfl else ⟨ x, hx, by linarith ⟩;
  · exact fun ⟨ x, hx, _ ⟩ => ⟨ x, hx ⟩

/-- Membership in the accepted language is decidable when the accept set is. -/
instance decMemAccepts [∀ s, Decidable (s ∈ M.accept)] (x : List α) :
    Decidable (x ∈ M.accepts) :=
  inferInstanceAs (Decidable (M.eval x ∈ M.accept))

/-- **The zero-in-sequence problem is decidable.**  For a DFA over a finite
alphabet with finitely many states and a decidable accept set, it is decidable
whether the accepted language is nonempty — we simply search all words of length
`< card σ`, a finite set by `List.finite_length_lt`. -/
noncomputable instance decidableAcceptsNonempty [Fintype α] [Fintype σ]
    [∀ s, Decidable (s ∈ M.accept)] : Decidable M.accepts.Nonempty :=
  decidable_of_iff
    (∃ x ∈ (List.finite_length_lt α (Fintype.card σ)).toFinset, x ∈ M.accepts)
    (by
      rw [accepts_nonempty_iff_bddWitness]
      constructor
      · rintro ⟨x, _, hmem⟩
        exact ⟨x, hmem, by
          have := (Set.Finite.mem_toFinset (List.finite_length_lt α (Fintype.card σ))).1 ‹_›
          simpa using this⟩
      · rintro ⟨x, hmem, hlt⟩
        exact ⟨x, (Set.Finite.mem_toFinset _).2 (by simpa using hlt), hmem⟩)

/-! ## Pumping upward: infinitude -/

/-
**Pump-up.**  A single accepted word of length `≥ card σ` forces the language
to be infinite: the pumping block can be repeated arbitrarily often, producing
words of strictly increasing length, all accepted.
-/
theorem accepts_infinite_of_long [Fintype σ] {x : List α}
    (hx : x ∈ M.accepts) (hlen : Fintype.card σ ≤ x.length) :
    M.accepts.Infinite := by
  have := DFA.pumping_lemma M hx hlen;
  obtain ⟨ a, b, c, rfl, h₁, h₂, h₃ ⟩ := this;
  refine Set.infinite_of_injective_forall_mem ( fun n m hnm => ?_ ) fun n => h₃ ( show a ++ ( List.replicate n b ).flatten ++ c ∈ { a } * { b } ∗ * { c } from ?_ );
  · replace hnm := congr_arg List.length hnm ; simp_all +decide [ List.length_flatten ];
  · grind +suggestions

/-
**Infinitude criterion.**  Over a finite alphabet, the language is infinite
iff it contains a word of length `≥ card σ`.  (`→`: only finitely many short
words exist, so an infinite language must contain a long one; `←`: pump up.)
-/
theorem accepts_infinite_iff [Fintype α] [Fintype σ] :
    M.accepts.Infinite ↔ ∃ x ∈ M.accepts, Fintype.card σ ≤ x.length := by
  -- Split the iff into two implications.
  apply Iff.intro;
  · intro h_inf
    by_contra h_contra
    push_neg at h_contra;
    refine' h_inf ( Set.Finite.subset ( Set.finite_coe_iff.mp ( List.finite_length_lt α ( Fintype.card σ ) ) ) fun x hx => h_contra x hx );
  · grind +suggestions

/-
If some accepted word has length `≥ card σ`, then some accepted word has
length in the *bounded* window `[card σ, 2·card σ)`.  (Pump a too-long word down;
removing a block of size `≤ card σ` keeps the length `≥ card σ`.)
-/
theorem exists_bounded_long_of_long [Fintype σ]
    (h : ∃ x ∈ M.accepts, Fintype.card σ ≤ x.length) :
    ∃ x ∈ M.accepts, Fintype.card σ ≤ x.length ∧ x.length < 2 * Fintype.card σ := by
  revert h;
  intro h
  obtain ⟨x, hx⟩ := h
  have h_aux : ∀ n, ∀ x ∈ M.accepts, x.length = n → Fintype.card σ ≤ x.length → ∃ y ∈ M.accepts, Fintype.card σ ≤ y.length ∧ y.length < 2 * Fintype.card σ := by
    intro n x hx hn hge
    induction' n using Nat.strong_induction_on with n ih generalizing x;
    by_cases h : x.length < 2 * Fintype.card σ;
    · exact ⟨ x, hx, hge, h ⟩;
    · obtain ⟨ a, b, c, rfl, hb, hbc, hac ⟩ := exists_pump_down M hx hge;
      refine' ih _ _ _ hac rfl _;
      · simp +arith +decide [ ← hn ];
        exact List.length_pos_iff.mpr hb;
      · grind;
  exact h_aux _ _ hx.1 rfl hx.2

/-
**Bounded infinitude criterion.**  The language is infinite iff it contains a
word whose length lies in `[card σ, 2·card σ)` — a finite search.
-/
theorem accepts_infinite_iff_bounded [Fintype α] [Fintype σ] :
    M.accepts.Infinite ↔
      ∃ x ∈ M.accepts, Fintype.card σ ≤ x.length ∧ x.length < 2 * Fintype.card σ := by
  refine' ⟨ _, fun h => _ ⟩;
  · intro h_inf;
    exact exists_bounded_long_of_long M ( by simpa using ( accepts_infinite_iff M ).mp h_inf );
  · exact AutomaticSeq.accepts_infinite_of_long M h.choose_spec.1 h.choose_spec.2.1

/-- **The "zero infinitely often" problem is decidable.**  Search the finite set
of words of length `< 2·card σ`. -/
noncomputable instance decidableAcceptsInfinite [Fintype α] [Fintype σ]
    [∀ s, Decidable (s ∈ M.accept)] : Decidable M.accepts.Infinite := by
  haveI : Decidable (∃ x ∈ (List.finite_length_lt α (2 * Fintype.card σ)).toFinset,
      Fintype.card σ ≤ x.length ∧ x ∈ M.accepts) := inferInstance
  refine decidable_of_iff
    (∃ x ∈ (List.finite_length_lt α (2 * Fintype.card σ)).toFinset,
      Fintype.card σ ≤ x.length ∧ x ∈ M.accepts) ?_
  rw [accepts_infinite_iff_bounded]
  constructor
  · rintro ⟨x, hx, hge, hmem⟩
    exact ⟨x, hmem, hge, by simpa using (Set.Finite.mem_toFinset _).1 hx⟩
  · rintro ⟨x, hmem, hge, hlt⟩
    exact ⟨x, (Set.Finite.mem_toFinset _).2 (by simpa using hlt), hge, hmem⟩

/-! ## Concrete example: the Thue–Morse automaton

The Thue–Morse sequence is `2`-automatic: reading the binary digits of `n`, a
two-state parity automaton outputs `aₙ`.  We package the automaton as a DFA over
`Bool` (alphabet = binary digits) with two states (running parity), accepting the
words whose digit-sum is odd. -/

/-- The two-state parity DFA underlying the Thue–Morse sequence. -/
def parityDFA : DFA Bool Bool where
  step s a := xor s a
  start := false
  accept := {true}

@[simp] theorem parityDFA_card : Fintype.card Bool = 2 := rfl

/-- The parity automaton accepts the singleton word `[true]`. -/
theorem parityDFA_accepts_true : [true] ∈ parityDFA.accepts := by
  simp [DFA.mem_accepts, DFA.eval, DFA.evalFrom, parityDFA]

/-- The Thue–Morse language is nonempty: the automaton does output `1`
somewhere — equivalently the zero/one-in-sequence problem is answered
affirmatively. -/
theorem parityDFA_accepts_nonempty : parityDFA.accepts.Nonempty :=
  ⟨[true], parityDFA_accepts_true⟩

/-- The parity automaton accepts the length-`2` word `[true, false]`. -/
theorem parityDFA_accepts_long : [true, false] ∈ parityDFA.accepts := by
  simp [DFA.mem_accepts, DFA.eval, DFA.evalFrom, parityDFA]

/-- The Thue–Morse language is infinite: `1` occurs infinitely often.  This uses
`accepts_infinite_of_long` on the length-`2` witness (`2 ≥ card Bool`). -/
theorem parityDFA_accepts_infinite : parityDFA.accepts.Infinite :=
  accepts_infinite_of_long parityDFA parityDFA_accepts_long (by simp)

/-! ## The Thue–Morse sequence and its automatic recurrences

We define `tm n` as the parity of the binary digit sum of `n` and verify the
defining recurrences of a `2`-automatic sequence. -/

/-- The Thue–Morse sequence, valued in `ZMod 2`: parity of the binary digit sum. -/
def tm (n : ℕ) : ZMod 2 := ((Nat.digits 2 n).sum : ZMod 2)

@[simp] theorem tm_zero : tm 0 = 0 := by simp [tm]

/-
Automatic recurrence: `t(2n) = t(n)` (prepending a `0` digit).
-/
theorem tm_two_mul (n : ℕ) : tm (2 * n) = tm n := by
  unfold tm;
  cases n <;> norm_num

/-
Automatic recurrence: `t(2n+1) = t(n) + 1` (prepending a `1` digit).
-/
theorem tm_two_mul_add_one (n : ℕ) : tm (2 * n + 1) = tm n + 1 := by
  unfold tm;
  norm_num [ Nat.add_mod, Nat.add_div ];
  ring

/-
The two recurrences show consecutive terms `t(2n)` and `t(2n+1)` always
differ — the hallmark of the Thue–Morse sequence.
-/
theorem tm_consecutive_ne (n : ℕ) : tm (2 * n) ≠ tm (2 * n + 1) := by
  simp +decide [ tm_two_mul, tm_two_mul_add_one ]

end AutomaticSeq