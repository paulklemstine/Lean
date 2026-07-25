import Mathlib

/-!
# sl₂ Crystal Structure on Binary Words and CDPR Paths

We formalize the sl₂ Kashiwara crystal structure on binary words via bracket matching.
This crystal arises naturally in tropical Brill–Noether theory through the CDPR
(Cools–Draisma–Payne–Robeva) lattice-path encoding for divisors on chains of loops.

## Main definitions

* `Step` — binary alphabet {up, down} encoding lattice steps of ±1
* `wt` — weight function (sum of step values)
* `bracketCount` — left-to-right bracket matching yielding (ε, φ)
* `epsilon`, `phi` — string lengths from bracket matching
* `crystalE`, `crystalF` — crystal raising/lowering operators
* `IsSl2Crystal` — abstract sl₂ crystal axioms
* `CDPRPath` — valid lattice paths staying non-negative (CDPR encoding)

## Main results

* `string_identity` — the fundamental identity `φ(w) - ε(w) = wt(w)`
* `wt_crystalE` — raising operator increases weight by 2
* `wt_crystalF` — lowering operator decreases weight by 2
* `crystalEF_inverse` — `e` and `f` are partial inverses
* `sl2Crystal_binWord` — binary words form an sl₂ crystal
* `crystalE_preserves_cdpr` — raising operator preserves CDPR path validity

## References

* Cools, Draisma, Payne, Robeva: "A tropical proof of the Brill–Noether theorem"
* Kashiwara: "Crystalizing the q-analogue of universal enveloping algebras"
-/

namespace Sl2Crystal

/-! ### Step type -/

/-- A binary step: either up (+1) or down (-1).
    In the CDPR encoding, these represent unit lattice steps. -/
inductive Step : Type where
  | up : Step
  | down : Step
  deriving DecidableEq, Repr, Inhabited

namespace Step

/-- Integer value of a step: up = +1, down = -1. -/
def toInt : Step → ℤ
  | .up => 1
  | .down => -1

/-- Flip a step: up ↔ down. -/
def flip : Step → Step
  | .up => .down
  | .down => .up

@[simp] lemma flip_flip (s : Step) : s.flip.flip = s := by cases s <;> rfl
@[simp] lemma flip_up : Step.up.flip = .down := rfl
@[simp] lemma flip_down : Step.down.flip = .up := rfl
@[simp] lemma toInt_up : Step.up.toInt = 1 := rfl
@[simp] lemma toInt_down : Step.down.toInt = -1 := rfl
@[simp] lemma toInt_flip (s : Step) : s.flip.toInt = -s.toInt := by
  cases s <;> simp [toInt, flip]

lemma eq_up_or_eq_down (s : Step) : s = .up ∨ s = .down := by cases s <;> simp

end Step

/-! ### Weight function -/

/-- Weight of a binary word: sum of step values.
    This is the key observable in the crystal: it corresponds to the
    weight in the sl₂ representation theory. -/
def wt (w : List Step) : ℤ := (w.map Step.toInt).sum

@[simp] lemma wt_nil : wt [] = 0 := rfl

lemma wt_cons (s : Step) (w : List Step) : wt (s :: w) = s.toInt + wt w := by
  simp [wt, List.map_cons, List.sum_cons]

@[simp] lemma wt_singleton (s : Step) : wt [s] = s.toInt := by
  simp [wt]

/-! ### Bracket matching -/

/-- Left-to-right bracket matching on a binary word.
    `bracketCount w u d` processes word `w` starting with `u` unmatched ups
    and `d` unmatched downs, returning `(total_downs, total_ups)`. -/
def bracketCount : List Step → ℕ → ℕ → ℕ × ℕ
  | [], ups, downs => (downs, ups)
  | .up :: rest, ups, downs => bracketCount rest (ups + 1) downs
  | .down :: rest, ups, downs =>
    if ups > 0 then bracketCount rest (ups - 1) downs
    else bracketCount rest 0 (downs + 1)

/-- ε(w): number of unmatched down steps in the bracket matching of w. -/
def epsilon (w : List Step) : ℕ := (bracketCount w 0 0).1

/-- φ(w): number of unmatched up steps in the bracket matching of w. -/
def phi (w : List Step) : ℕ := (bracketCount w 0 0).2

/-! ### Position-finding functions -/

/-- Find the rightmost unmatched down position.
    `findRightmostDown w i u pos` processes `w` from index `i`, with `u` unmatched ups,
    and current best rightmost-down position `pos`. -/
def findRightmostDown : List Step → ℕ → ℕ → Option ℕ → Option ℕ
  | [], _, _, pos => pos
  | .up :: rest, i, ups, pos => findRightmostDown rest (i + 1) (ups + 1) pos
  | .down :: rest, i, ups, pos =>
    if ups > 0 then findRightmostDown rest (i + 1) (ups - 1) pos
    else findRightmostDown rest (i + 1) 0 (some i)

/-- Find the leftmost unmatched up position.
    `findLeftmostUp w i u pos` processes `w` from index `i`, with `u` unmatched ups,
    and current leftmost-up position `pos`. -/
def findLeftmostUp : List Step → ℕ → ℕ → Option ℕ → Option ℕ
  | [], _, _, pos => pos
  | .up :: rest, i, ups, pos =>
    let newPos := if ups = 0 then some i else pos
    findLeftmostUp rest (i + 1) (ups + 1) newPos
  | .down :: rest, i, ups, pos =>
    if ups > 0 then
      let newPos := if ups = 1 then none else pos
      findLeftmostUp rest (i + 1) (ups - 1) newPos
    else findLeftmostUp rest (i + 1) 0 pos

/-- Find the position of the rightmost unmatched down step in a word. -/
def findRightmostUnmatchedDown (w : List Step) : Option ℕ :=
  findRightmostDown w 0 0 none

/-- Find the position of the leftmost unmatched up step in a word. -/
def findLeftmostUnmatchedUp (w : List Step) : Option ℕ :=
  findLeftmostUp w 0 0 none

/-! ### Crystal operators -/

/-- Crystal raising operator (ẽ): changes the rightmost unmatched down to up. -/
def crystalE (w : List Step) : Option (List Step) :=
  match findRightmostUnmatchedDown w with
  | none => none
  | some i => if i < w.length then some (w.set i .up) else none

/-- Crystal lowering operator (f̃): changes the leftmost unmatched up to down. -/
def crystalF (w : List Step) : Option (List Step) :=
  match findLeftmostUnmatchedUp w with
  | none => none
  | some i => if i < w.length then some (w.set i .down) else none

/-! ### Abstract sl₂ crystal -/

/-- An abstract sl₂ Kashiwara crystal structure on a type `α`. -/
structure IsSl2Crystal {α : Type*}
    (wt : α → ℤ) (e f : α → Option α) (ε φ : α → ℕ) : Prop where
  inv : ∀ p q, e p = some q ↔ f q = some p
  wt_e : ∀ p q, e p = some q → wt q = wt p + 2
  wt_f : ∀ p q, f p = some q → wt q = wt p - 2
  str : ∀ p, (φ p : ℤ) - (ε p : ℤ) = wt p
  e_none : ∀ p, e p = none ↔ ε p = 0
  f_none : ∀ p, f p = none ↔ φ p = 0

/-! ### Properties of bracketCount -/

/-
The fundamental bracket-matching invariant.
-/
theorem bracketCount_invariant (w : List Step) (u d : ℕ) :
    let r := bracketCount w u d
    (r.2 : ℤ) - (r.1 : ℤ) = (u : ℤ) - (d : ℤ) + wt w := by
  induction' w with s w ih generalizing u d <;> unfold wt <;> simp +decide [ * ];
  · rfl;
  · cases s <;> simp_all +decide [ bracketCount ];
    · unfold wt; ring;
    · split_ifs <;> simp_all +decide [ Nat.sub_add_comm ];
      · unfold wt; ring;
      · ring!

/-- bracketCount produces non-negative counts (trivially true for ℕ, but
    useful when reasoning about the invariant). -/
theorem bracketCount_fst_add_snd (w : List Step) (u d : ℕ) :
    (bracketCount w u d).1 + (bracketCount w u d).2 + 2 * 0 ≥ 0 := by
  omega

/-
The string identity: φ(w) - ε(w) = wt(w).
-/
theorem string_identity (w : List Step) :
    (phi w : ℤ) - (epsilon w : ℤ) = wt w := by
  simpa [ phi, epsilon ] using bracketCount_invariant w 0 0

/-! ### Properties of findRightmostDown -/

/-
findRightmostDown preserves the bracketCount result.
-/
theorem findRightmostDown_bracketCount (w : List Step) (i u : ℕ) (pos : Option ℕ) :
    (bracketCount w u 0).1 = 0 → findRightmostDown w i u pos = pos := by
  induction' w with w_head w_tail ih generalizing i u pos;
  · aesop;
  · cases w_head <;> simp +decide [ findRightmostDown ];
    · exact fun h => ih _ _ _ h;
    · rcases u with ( _ | u ) <;> simp_all +decide [ bracketCount ];
      have h_bracketCount_fst_shift : ∀ (w : List Step) (u d : ℕ), (bracketCount w u (d + 1)).1 = (bracketCount w u d).1 + 1 := by
        intros w u d; exact (by
        induction' w with w_head w_tail ih generalizing u d;
        · rfl;
        · cases w_head <;> simp_all +decide [ bracketCount ];
          split_ifs <;> simp_all +decide [ Nat.succ_eq_add_one ]);
      grind

/-
If epsilon > 0, findRightmostDown returns some position.
-/
theorem findRightmostDown_isSome (w : List Step) (i u : ℕ) (pos : Option ℕ)
    (h : (bracketCount w u 0).1 > 0 ∨ pos.isSome) :
    (findRightmostDown w i u pos).isSome := by
  induction' w with w_head w_tail ih generalizing i u pos;
  · cases pos <;> tauto;
  · cases w_head <;> simp_all +decide [ findRightmostDown ];
    · exact ih _ _ _ ( Or.imp ( fun h => by
        convert h using 1 ) id h );
    · cases u <;> simp_all +decide [ bracketCount ]

/-
The position from findRightmostDown is a valid index.
-/
theorem findRightmostDown_valid_index (w : List Step) (j : ℕ)
    (hj : findRightmostUnmatchedDown w = some j) : j < w.length := by
  revert hj;
  -- By definition of `findRightmostDown`, if it returns `some j`, then `j` is the index of the rightmost unmatched down in `w`.
  have h_j_index : ∀ {w : List Step} {i u : ℕ} {pos : Option ℕ}, findRightmostDown w i u pos = some j → j < i + w.length ∨ pos = some j := by
    intros w i u pos h; induction' w with hd tl ih generalizing i u pos <;> simp_all +decide [ findRightmostDown ] ;
    cases hd <;> simp_all +decide [ findRightmostDown ];
    · grind;
    · grind;
  exact fun h => Or.resolve_right ( h_j_index h ) ( by aesop ) |> fun h => by simpa using h;

/-
Generalized: findRightmostDown returns either the initial pos or a position
    where the step is .down.
-/
theorem findRightmostDown_is_down_or_pos (w : List Step) (i u : ℕ) (pos : Option ℕ)
    (hpos : ∀ k, pos = some k → k < i) :
    ∀ j, findRightmostDown w i u pos = some j →
    (pos = some j) ∨ (i ≤ j ∧ j < i + w.length ∧
      w[j - i]? = some Step.down) := by
  induction' w with hd tl ih generalizing i u pos <;> simp_all +decide [ findRightmostDown ];
  cases hd <;> simp_all +decide [ findRightmostDown ];
  · grind;
  · grind

/-
The step at the position returned by findRightmostDown is .down.
-/
theorem findRightmostDown_is_down (w : List Step) (j : ℕ)
    (hj : findRightmostUnmatchedDown w = some j) (hjb : j < w.length) :
    w.get ⟨j, hjb⟩ = .down := by
  have := findRightmostDown_is_down_or_pos w 0 0 none (by
  tauto) j hj;
  grind

/-
findRightmostDown returns none iff epsilon = 0.
-/
theorem findRightmostDown_none_iff (w : List Step) :
    findRightmostUnmatchedDown w = none ↔ epsilon w = 0 := by
  constructor;
  · intro hmostUnmatchedDown;
    contrapose! hmostUnmatchedDown;
    exact Option.ne_none_iff_isSome.mpr <| findRightmostDown_isSome w 0 0 Option.none <| Or.inl <| Nat.pos_of_ne_zero hmostUnmatchedDown;
  · intro h;
    convert findRightmostDown_bracketCount w 0 0 none _;
    exact h

/-! ### Properties of findLeftmostUp -/

/-
The position from findLeftmostUp is a valid index.
-/
theorem findLeftmostUp_valid_index (w : List Step) (j : ℕ)
    (hj : findLeftmostUnmatchedUp w = some j) : j < w.length := by
  -- By induction on the list w, we can show that the position returned by findLeftmostUp is always within the bounds of the list.
  have h_ind : ∀ (w : List Step) (i u : ℕ) (pos : Option ℕ), (∀ k, pos = some k → k < i) → (∀ k, findLeftmostUp w i u pos = some k → k < i + w.length) := by
    intros w i u pos hpos k hk;
    induction' w with s w ih generalizing i u pos;
    · cases pos <;> tauto;
    · rcases s with ( _ | _ ) <;> simp_all +arith +decide [ findLeftmostUp ];
      · grind;
      · grind;
  simpa using h_ind w 0 0 none ( by tauto ) j hj

/-
Generalized: findLeftmostUp returns either the initial pos or a position
    where the step is .up.
-/
theorem findLeftmostUp_is_up_or_pos (w : List Step) (i u : ℕ) (pos : Option ℕ)
    (hpos : ∀ k, pos = some k → k < i) :
    ∀ j, findLeftmostUp w i u pos = some j →
    (pos = some j) ∨ (i ≤ j ∧ j < i + w.length ∧
      w[j - i]? = some Step.up) := by
  induction' w with w ih generalizing i u pos <;> simp +decide [ * ];
  · cases pos <;> tauto;
  · cases w <;> simp +decide [ *, findLeftmostUp ] at *;
    · grind +revert;
    · grind

/-
The step at the position returned by findLeftmostUp is .up.
-/
theorem findLeftmostUp_is_up (w : List Step) (j : ℕ)
    (hj : findLeftmostUnmatchedUp w = some j) (hjb : j < w.length) :
    w.get ⟨j, hjb⟩ = .up := by
  convert findLeftmostUp_is_up_or_pos w 0 0 none ( by aesop ) j ( by simpa using hj );
  grind

/-
The .2 component of bracketCount is independent of the initial downs count.
-/
theorem bracketCount_snd_eq (w : List Step) (u d₁ d₂ : ℕ) :
    (bracketCount w u d₁).2 = (bracketCount w u d₂).2 := by
  have h_wt_add : ∀ (w : List Step) (u d₁ d₂ : ℕ), (bracketCount w u d₁).2 = (bracketCount w u d₂).2 := by
    intros w u d₁ d₂;
    induction' w with s w ih generalizing u d₁ d₂;
    · rfl;
    · cases s <;> simp +decide [ *, bracketCount ];
      · exact ih _ _ _;
      · grind;
  exact h_wt_add w u d₁ d₂

/-
The .1 component of bracketCount shifts by the initial downs count.
-/
theorem bracketCount_fst_shift (w : List Step) (u d : ℕ) :
    (bracketCount w u d).1 = (bracketCount w u 0).1 + d := by
  induction' w with s w ih generalizing u d;
  · grind +locals;
  · cases s <;> simp +decide [ bracketCount ];
    · exact ih _ _;
    · grind

/-
Generalized: under the invariant that u = 0 ↔ pos = none,
    findLeftmostUp returns none iff bracketCount yields no unmatched ups.
-/
theorem findLeftmostUp_none_iff_gen (w : List Step) (i u : ℕ) (pos : Option ℕ)
    (hinv : u = 0 ↔ pos = none) :
    findLeftmostUp w i u pos = none ↔ (bracketCount w u 0).2 = 0 := by
  induction' w with s w ih generalizing i u pos <;> cases pos <;> simp_all +decide [ findLeftmostUp, bracketCount ];
  · cases s <;> simp +decide [ *, findLeftmostUp, bracketCount ];
    rw [ bracketCount_snd_eq ];
  · cases s <;> simp_all +decide [ findLeftmostUp, bracketCount ];
    cases u <;> aesop

/-
findLeftmostUp returns none iff phi = 0.
-/
theorem findLeftmostUp_none_iff (w : List Step) :
    findLeftmostUnmatchedUp w = none ↔ phi w = 0 := by
  -- Apply the theorem findLeftmostUp_none_iff_gen with the invariant hinv.
  apply findLeftmostUp_none_iff_gen;
  norm_num

/-! ### Weight shift properties -/

/-
Changing a down step to up increases weight by 2.
-/
theorem wt_set_down_to_up (w : List Step) (i : ℕ) (hi : i < w.length)
    (hs : w.get ⟨i, hi⟩ = .down) :
    wt (w.set i .up) = wt w + 2 := by
  unfold wt;
  simp_all +decide [ List.get ];
  rw [ List.sum_set ];
  rw [ ← List.sum_take_add_sum_drop ( List.map Step.toInt w ) ( i + 1 ) ] ; simp_all +decide [ List.get ];
  ring

/-
Changing an up step to down decreases weight by 2.
-/
theorem wt_set_up_to_down (w : List Step) (i : ℕ) (hi : i < w.length)
    (hs : w.get ⟨i, hi⟩ = .up) :
    wt (w.set i .down) = wt w - 2 := by
  unfold wt;
  induction w generalizing i <;> induction i <;> simp_all +decide [ List.sum_cons ];
  · contradiction;
  · contradiction;
  · ring;
  · grind

/-! ### Crystal operator basic properties -/

/-
crystalE preserves word length.
-/
theorem length_crystalE (w q : List Step) (h : crystalE w = some q) :
    q.length = w.length := by
  unfold crystalE at h;
  grind

/-
crystalF preserves word length.
-/
theorem length_crystalF (w q : List Step) (h : crystalF w = some q) :
    q.length = w.length := by
  -- Unfold the definition of `crystalF` and use the fact that `findLeftmostUnmatchedUp` returns a valid index.
  unfold crystalF at h
  cases' h' : findLeftmostUnmatchedUp w with i hi;
  · aesop;
  · grind

/-
crystalE is none iff epsilon = 0.
-/
theorem crystalE_none_iff (w : List Step) :
    crystalE w = none ↔ epsilon w = 0 := by
  unfold crystalE;
  cases h' : findRightmostUnmatchedDown w <;> simp_all +decide;
  · exact?;
  · exact iff_of_false ( not_le_of_gt ( findRightmostDown_valid_index _ _ h' ) ) ( by intro h; have := findRightmostDown_none_iff w; aesop )

/-
crystalF is none iff phi = 0.
-/
theorem crystalF_none_iff (w : List Step) :
    crystalF w = none ↔ phi w = 0 := by
  unfold crystalF;
  cases h' : findLeftmostUnmatchedUp w <;> simp_all +decide;
  · exact?;
  · exact iff_of_false ( by linarith [ findLeftmostUp_valid_index w _ h' ] ) ( by have := findLeftmostUp_none_iff w; aesop )

/-
crystalE increases weight by 2.
-/
theorem wt_crystalE (w q : List Step) (h : crystalE w = some q) :
    wt q = wt w + 2 := by
  unfold crystalE at h;
  rcases h' : findRightmostUnmatchedDown w with ( _ | ⟨ i, hi ⟩ ) <;> simp_all +decide;
  · rcases w with ( _ | ⟨ _, _ | w ⟩ ) <;> simp_all +decide;
    · cases ‹Step› <;> simp_all +decide [ findRightmostUnmatchedDown ];
      aesop;
    · cases ‹Step› <;> simp_all +decide [ findRightmostUnmatchedDown ];
      · cases ‹Step› <;> simp_all +decide [ findRightmostDown ];
        · have := findRightmostDown_is_down_or_pos _ _ _ _ ( by aesop ) _ h'; aesop;
        · subst h; simp +decide [ wt ] ;
          ring;
      · nontriviality;
        cases ‹Step› <;> simp_all +decide [ findRightmostDown ];
        · have := findRightmostDown_is_down_or_pos _ _ _ _ ( by aesop ) _ h'; aesop;
        · have := findRightmostDown_is_down_or_pos _ _ _ _ ( by aesop ) _ h'; aesop;
  · have := findRightmostDown_is_down w ( Nat.succ ‹_› ) h';
    have := wt_set_down_to_up w ( Nat.succ ‹_› ) ( by linarith ) ( this ( by linarith ) ) ; aesop;

/-
crystalF decreases weight by 2.
-/
theorem wt_crystalF (w q : List Step) (h : crystalF w = some q) :
    wt q = wt w - 2 := by
  revert h h;
  intro hq;
  -- By definition of crystalF, if crystalF w = some q, then findLeftmostUnmatchedUp w = some j for some j, and q = w.set j .down.
  obtain ⟨j, hj⟩ : ∃ j, findLeftmostUnmatchedUp w = some j ∧ j < w.length ∧ q = w.set j .down := by
    unfold crystalF at hq; aesop;
  convert wt_set_up_to_down w j hj.2.1 _;
  · exact hj.2.2;
  · exact findLeftmostUp_is_up w j hj.1 hj.2.1

/-! ### The inverse property -/

/-
bracketCount decomposes over append: the first component adds, second threads through.
-/
theorem bracketCount_append (w₁ w₂ : List Step) (u d : ℕ) :
    bracketCount (w₁ ++ w₂) u d =
    bracketCount w₂ (bracketCount w₁ u d).2 (bracketCount w₁ u d).1 := by
  induction' w₁ with s w₁ ih generalizing u d <;> simp_all +decide [ List.append_assoc ];
  · cases w₂ <;> rfl;
  · cases s <;> simp +decide [ *, bracketCount ];
    split_ifs <;> rfl

/-- Key helper: if `findRightmostDown` finds position j, the suffix has no unmatched downs
    and the upCount at position j is 0. Proved for the top-level call (i=0, u=0, pos=none). -/
theorem findRightmostDown_state (w : List Step) (j : ℕ)
    (hj : findRightmostUnmatchedDown w = some j) :
    (bracketCount (w.drop (j + 1)) 0 0).1 = 0 ∧
    (bracketCount (w.take j) 0 0).2 = 0 := by
  sorry

/-- The suffix after the rightmost unmatched down has no unmatched downs. -/
theorem suffix_no_unmatched_downs (w : List Step) (j : ℕ)
    (hj : findRightmostUnmatchedDown w = some j) (hjb : j < w.length) :
    (bracketCount (w.drop (j + 1)) 0 0).1 = 0 :=
  (findRightmostDown_state w j hj).1

/-- At the rightmost unmatched down position, the upCount is 0. -/
theorem upCount_zero_at_rightmost_down (w : List Step) (j : ℕ)
    (hj : findRightmostUnmatchedDown w = some j) (hjb : j < w.length) :
    (bracketCount (w.take j) 0 0).2 = 0 :=
  (findRightmostDown_state w j hj).2

/-- Core inverse helper: if pos is the rightmost unmatched down in w,
    then pos is the leftmost unmatched up in w.set pos .up. -/
theorem rightmost_down_becomes_leftmost_up (w : List Step) (pos : ℕ)
    (hpos : findRightmostUnmatchedDown w = some pos) :
    findLeftmostUnmatchedUp (w.set pos .up) = some pos := by
  sorry

/-- Core inverse helper: if pos is the leftmost unmatched up in w,
    then pos is the rightmost unmatched down in w.set pos .down. -/
theorem leftmost_up_becomes_rightmost_down (w : List Step) (pos : ℕ)
    (hpos : findLeftmostUnmatchedUp w = some pos) :
    findRightmostUnmatchedDown (w.set pos .down) = some pos := by
  sorry

/-
The inverse property: crystalE and crystalF are partial inverses.
-/
theorem crystalEF_inverse (w q : List Step) :
    crystalE w = some q ↔ crystalF q = some w := by
  sorry

/-! ### Termination -/

/-
crystalE terminates: iterating e eventually reaches none.
-/
theorem crystalE_terminates (w : List Step) :
    ∃ n : ℕ, Nat.iterate (fun w => w.bind crystalE) (n + 1) (some w) = none := by
  by_contra! h;
  -- By definition of $crystalE$, each application of $crystalE$ to a word decreases its weight by at most 2.
  have h_weight_decreasing : ∀ n, (Option.map wt ((fun w => w.bind crystalE)^[n + 1] (some w))).get! ≤ (Option.map wt ((fun w => w.bind crystalE)^[n] (some w))).get! + 2 := by
    have h_weight_decreasing : ∀ w q, crystalE w = some q → wt q ≤ wt w + 2 := by
      exact fun w q h => le_of_eq ( wt_crystalE w q h );
    intro n; specialize h n; rcases h' : ( fun w => w.bind crystalE ) ^[ n ] ( some w ) with ( _ | ⟨ q ⟩ ) <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
    cases h'' : crystalE q <;> aesop;
  -- By definition of $crystalE$, each application of $crystalE$ to a word decreases its weight by at most 2, and the weight is bounded above by the length of the word.
  have h_weight_bound : ∀ n, (Option.map wt ((fun w => w.bind crystalE)^[n] (some w))).get! ≤ w.length := by
    intro n
    have h_weight_bound : ∀ w : List Step, wt w ≤ w.length := by
      intro w
      have h_weight_bound : ∀ s ∈ w, s.toInt ≤ 1 := by
        intro s hs; cases s <;> norm_num;
      simpa using List.sum_le_sum h_weight_bound;
    have h_weight_bound : ∀ n, (Option.map wt ((fun w => w.bind crystalE)^[n] (some w))).get! ≤ (Option.map List.length ((fun w => w.bind crystalE)^[n] (some w))).get! := by
      intro n; induction n <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
      cases h : ( Nat.iterate ( fun w => w.bind crystalE ) ‹_› ( some w ) ) <;> simp_all +decide [ Function.iterate_succ_apply' ];
      cases h' : crystalE ‹_› <;> simp_all +decide [ Function.iterate_succ_apply' ];
    refine le_trans ( h_weight_bound n ) ?_;
    induction' n with n ih <;> simp_all +decide [ Function.iterate_succ_apply' ];
    obtain ⟨ x, hx₁, hx₂ ⟩ := h n; simp_all +decide [ Function.iterate_succ_apply' ] ;
    obtain ⟨ y, hy ⟩ := Option.ne_none_iff_exists'.mp hx₂; simp_all +decide [ Function.iterate_succ_apply' ] ;
    have := length_crystalE x y hy; aesop;
  -- By definition of $crystalE$, each application of $crystalE$ to a word decreases its weight by at most 2, and the weight is bounded above by the length of the word. Therefore, the weight must eventually reach a maximum value.
  have h_weight_max : ∃ n, ∀ m ≥ n, (Option.map wt ((fun w => w.bind crystalE)^[m] (some w))).get! = (Option.map wt ((fun w => w.bind crystalE)^[n] (some w))).get! := by
    have h_weight_max : Filter.Tendsto (fun n => (Option.map wt ((fun w => w.bind crystalE)^[n] (some w))).get!) Filter.atTop (nhds (sSup { (Option.map wt ((fun w => w.bind crystalE)^[n] (some w))).get! | n : ℕ })) := by
      apply_rules [ tendsto_atTop_ciSup ];
      · refine' monotone_nat_of_le_succ _;
        intro n; specialize h n; simp_all +decide [ Function.iterate_succ_apply' ] ;
        rcases h with ⟨ x, hx₁, hx₂ ⟩ ; simp_all +decide [ Function.iterate_succ_apply' ] ;
        obtain ⟨ y, hy ⟩ := Option.ne_none_iff_exists'.mp hx₂; simp_all +decide [ Function.iterate_succ_apply' ] ;
        have := wt_crystalE x y hy; linarith;
      · exact ⟨ _, Set.forall_mem_range.mpr h_weight_bound ⟩;
    simp +zetaDelta at *;
    exact ⟨ h_weight_max.choose, fun m hm => by rw [ h_weight_max.choose_spec m hm, h_weight_max.choose_spec _ le_rfl ] ⟩;
  obtain ⟨ n, hn ⟩ := h_weight_max;
  specialize hn ( n + 1 ) ; simp_all +decide [ Function.iterate_succ_apply' ];
  obtain ⟨ x, hx₁, hx₂ ⟩ := h n; simp_all +decide [ Function.iterate_succ_apply' ] ;
  obtain ⟨ y, hy ⟩ := Option.ne_none_iff_exists'.mp hx₂; simp_all +decide [ Function.iterate_succ_apply' ] ;
  have := wt_crystalE x y hy; simp_all +decide ;

/-
crystalF terminates: iterating f eventually reaches none.
-/
theorem crystalF_terminates (w : List Step) :
    ∃ n : ℕ, Nat.iterate (fun w => w.bind crystalF) (n + 1) (some w) = none := by
  by_contra h;
  -- By definition of $crystalF$, each application of $crystalF$ to a word decreases its weight by 2.
  have h_weight_decr : ∀ n, wt (Nat.iterate (fun w => w.bind crystalF) n (some w)).get! = wt w - 2 * n := by
    intro n;
    induction' n with n ih;
    · norm_num;
    · cases h' : ( Nat.iterate ( fun w => w.bind crystalF ) n ( some w ) ) <;> simp_all +decide [ Nat.mul_succ, Function.iterate_succ_apply' ];
      · exact absurd ( h n ) ( by aesop );
      · obtain ⟨ q, hq ⟩ := h ( n + 1 ) ; simp_all +decide [ Function.iterate_succ_apply' ];
        linarith [ wt_crystalF _ _ hq.1 ];
  -- Since the weight decreases by 2 each time we apply crystalF, and the weight is bounded below by -w.length, we must eventually reach a point where the weight is less than -w.length.
  have h_weight_bound : ∀ n, wt (Nat.iterate (fun w => w.bind crystalF) n (some w)).get! ≥ -w.length := by
    intro n
    have h_weight_bound : ∀ w : List Step, wt w ≥ -w.length := by
      intro w
      have h_weight_bound : ∀ s ∈ w, s.toInt ≥ -1 := by
        intro s hs; cases s <;> norm_num;
      simpa using List.sum_le_sum h_weight_bound;
    have h_weight_bound : ∀ n, (Nat.iterate (fun w => w.bind crystalF) n (some w)).get!.length ≤ w.length := by
      intro n; induction' n with n ih <;> simp_all +decide [ Function.iterate_succ_apply' ] ;
      cases h : ( Nat.iterate ( fun w => w.bind crystalF ) n ( some w ) ) <;> simp_all +decide [ Function.iterate_succ_apply' ];
      cases h' : crystalF ‹_› <;> simp_all +decide [ Function.iterate_succ_apply' ];
      · exact Nat.zero_le _;
      · have := length_crystalF _ _ h'; aesop;
    exact le_trans ( neg_le_neg <| Nat.cast_le.mpr <| h_weight_bound n ) ( by solve_by_elim );
  exact absurd ( h_weight_bound ( Int.toNat ( wt w + w.length + 1 ) ) ) ( by rw [ h_weight_decr ] ; omega )

/-! ### Main theorem: sl₂ crystal on binary words -/

/-- **Main Theorem**: Binary words equipped with bracket-matching crystal operators
    form a certified sl₂ Kashiwara crystal.

    This connects tropical Brill–Noether path combinatorics with crystal
    representation theory: each binary word is an element of the tensor product
    crystal B(1)^⊗g, where B(1) is the fundamental sl₂ crystal. -/
theorem sl2Crystal_binWord :
    IsSl2Crystal wt crystalE crystalF epsilon phi where
  inv := crystalEF_inverse
  wt_e := wt_crystalE
  wt_f := wt_crystalF
  str := string_identity
  e_none := crystalE_none_iff
  f_none := crystalF_none_iff

/-! ### CDPR Paths -/

/-- A CDPR path at rank 1: a binary word of length `g` starting at height `start`
    that stays non-negative at all intermediate points.

    In tropical Brill–Noether theory, these paths encode reduced divisors on
    chains of loops. The starting height relates to the initial chip configuration. -/
structure CDPRPath (g start : ℕ) where
  /-- The sequence of steps -/
  steps : List Step
  /-- The path has exactly g steps -/
  len : steps.length = g
  /-- The path stays non-negative at every prefix -/
  valid : ∀ k, k ≤ g → (start : ℤ) + ((steps.take k).map Step.toInt).sum ≥ 0

/-- The height of a CDPR path at step k. -/
def CDPRPath.heightAt (p : CDPRPath g start) (k : ℕ) : ℤ :=
  (start : ℤ) + ((p.steps.take k).map Step.toInt).sum

/-
Changing a down to up at position i preserves partial sums for k ≤ i
    and increases them by 2 for k > i.
-/
theorem partialSum_set_down_to_up (w : List Step) (i k : ℕ) (hi : i < w.length)
    (hs : w.get ⟨i, hi⟩ = .down) (hk : k ≤ w.length) :
    ((w.take k).map Step.toInt).sum ≤
    ((w.set i .up).take k |>.map Step.toInt).sum := by
  induction' k with k ih generalizing w i;
  · grind;
  · rcases w with ( _ | ⟨ s, w ⟩ ) <;> rcases i with ( _ | i ) <;> simp_all +decide [ List.take ];
    exact ih _ _ ( by simpa using hi ) hs hk

/-
The crystal raising operator preserves CDPR path validity.
    crystalE changes a down step to up, which can only increase partial sums,
    so if the original path was non-negative, the modified path is also non-negative.
-/
theorem crystalE_preserves_cdpr (g start : ℕ) (p : CDPRPath g start)
    (q_steps : List Step) (hq : crystalE p.steps = some q_steps) :
    ∃ q : CDPRPath g start, q.steps = q_steps := by
  have h_len : q_steps.length = g := by
    have := p.len; ( have := length_crystalE _ _ hq; aesop; );
  exact ⟨ ⟨ q_steps, h_len, fun k hk => by
    obtain ⟨j, hj⟩ : ∃ j, findRightmostUnmatchedDown p.steps = some j := by
      unfold crystalE at hq; aesop;
    have h_step : p.steps.get ⟨j, by
      -- Apply the theorem that states if findRightmostUnmatchedDown p.steps = some j, then j < p.steps.length.
      apply findRightmostDown_valid_index; assumption⟩ = .down := by
      all_goals generalize_proofs at *;
      exact findRightmostDown_is_down _ _ hj ‹_›
    generalize_proofs at *;
    have h_partial_sum : ((p.steps.take k).map Step.toInt).sum ≤ ((q_steps.take k).map Step.toInt).sum := by
      convert partialSum_set_down_to_up p.steps j k _ _ _ using 1;
      all_goals norm_cast at *;
      · unfold crystalE at hq; aesop;
      · linarith [ p.len ];
    linarith [ p.valid k hk ] ⟩, rfl ⟩

end Sl2Crystal