/-
# Abstract sign-change counting on two-letter words

This file isolates the *domain-general* combinatorial kernel underlying the peak/valley
identity used on the greedy-Tamari side of the conjectured bijection (see
`DyckValleys.lean`).  Over an arbitrary two-letter alphabet — here modelled by `Bool`
(`true` = "rise", `false` = "fall") — the number of `rise→fall` descents and the number of
`fall→rise` ascents of a word differ by a **pure boundary term** depending only on the first
and last letters.

This is a genuinely general statement: it makes no positivity or balance assumption (unlike
Dyck words), and specialises, on words that begin with a rise and end with a fall, to
"there is exactly one more descent than ascent".

## Main results

* `Applications.GreedyTamariMaps.SignChange.descents_sub_ascents`: for any nonempty
  `Bool`-word, `#descents − #ascents = w(head) − w(last)` (as integers), where `w true = 1`,
  `w false = 0`.
* `Applications.GreedyTamariMaps.SignChange.descents_eq_ascents_succ`: a `Bool`-word that
  starts with `true` and ends with `false` has `#descents = #ascents + 1`.
* `Applications.GreedyTamariMaps.SignChange.descents_eq_ascents_of_closed`: a `Bool`-word
  that starts and ends with the *same* letter has `#descents = #ascents`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The peak/valley identity is a shadow of an alphabet-independent
  fact: on any two-letter word, descents minus ascents is a boundary invariant.  Surprising
  angle: the interior of the word is irrelevant — only the first and last letters matter.
Experiment (Experimenter): Checked on `Bool`-words up to length 5 that
  `#descents − #ascents` equals `w(head) − w(last)` and, for words starting `true` ending
  `false`, that `#descents = #ascents + 1` (mirroring the Dyck computation in
  `ComputationalEvidence.md`).
Analysis (Analyst): The naive statement (descents = ascents + 1) is not closed under taking
  tails; the *signed boundary invariant* is the induction-closed strengthening, proved by a
  two-step list induction with a four-way case split on the two leading letters.
Critique (Critic): No result is vacuous.  `descents_sub_ascents` is a genuine induction
  (`omega` closes each of the four leading-letter cases, not `rfl`/`decide`).  The two
  corollaries are non-vacuous specialisations; the `closed` case needs both endpoints equal,
  and is false for open words, so the hypothesis is load-bearing.
Synthesis (PI): This is the reusable, alphabet-agnostic backbone that the Dyck-specific
  `peaks_eq_valleys_succ` instantiates; it is stated over `Bool` so any future two-letter
  encoding (e.g. black/white boundary letters of bipartite maps) can reuse it directly.
-/
import Mathlib

namespace Applications.GreedyTamariMaps.SignChange

/-- Number of **descents** (`true` immediately followed by `false`) in a `Bool`-word. -/
def descents : List Bool → ℕ
  | true :: false :: t => 1 + descents (false :: t)
  | _ :: t => descents t
  | [] => 0

/-- Number of **ascents** (`false` immediately followed by `true`) in a `Bool`-word. -/
def ascents : List Bool → ℕ
  | false :: true :: t => 1 + ascents (true :: t)
  | _ :: t => ascents t
  | [] => 0

/-- Boundary weight `w true = 1`, `w false = 0`. -/
def wt : Bool → ℤ
  | true => 1
  | false => 0

/-
**Signed boundary invariant.**  For any nonempty `Bool`-word,
`#descents − #ascents = w(head) − w(last)`.
-/
theorem descents_sub_ascents (l : List Bool) (h : l ≠ []) :
    (descents l : ℤ) - ascents l = wt (l.head h) - wt (l.getLast h) := by
  induction l <;> simp_all +decide;
  · contradiction;
  · rename_i k l ih;
    rcases l with ( _ | ⟨ a, _ | ⟨ b, l ⟩ ⟩ ) <;> simp_all +decide [ List.getLast ];
    · cases k <;> trivial;
    · cases k <;> cases a <;> trivial;
    · cases k <;> cases a <;> cases b <;> simp_all +decide [ descents, ascents ];
      · unfold wt at * ; linarith;
      · unfold wt at * ; linarith!;
      · unfold wt at * ; linarith;
      · unfold wt at * ; linarith!

/-
A `Bool`-word that begins with a rise and ends with a fall has exactly one more descent
than ascent.
-/
theorem descents_eq_ascents_succ (l : List Bool) (h : l ≠ [])
    (hhead : l.head h = true) (hlast : l.getLast h = false) :
    descents l = ascents l + 1 := by
  convert descents_sub_ascents l h using 1;
  simp +decide [ hhead, hlast, wt ] ; omega;

/-
A `Bool`-word whose first and last letters agree has equally many descents and
ascents.
-/
theorem descents_eq_ascents_of_closed (l : List Bool) (h : l ≠ [])
    (hcl : l.head h = l.getLast h) :
    descents l = ascents l := by
  convert descents_sub_ascents l h using 1;
  grind +locals

end Applications.GreedyTamariMaps.SignChange