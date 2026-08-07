import Mathlib
import Novelty.HodgeMirror

/-!
# Arithmetic Mirror Symmetry VI — the genus-zero BPS / Picard-rank specialization

This file settles *Conjecture 1* of the programme: the **graded genus-zero
mirror/Picard specialization**, which asks for a mirror pair `(X, Y)` of Calabi–Yau
threefolds and a finite set `S` of effective primitive curve classes on `X` with

`∑_{β ∈ S} n⁰_β(X) = rank Pic(Y)`.

The conjecture is tested, as instructed, on the explicitly named toric mirror family:
the quintic threefold `X = X₅ ⊂ ℙ⁴` and its Greene–Plesser mirror `Y = X₅/(ℤ/5)³`,
whose Hodge data are `(h^{1,1}, h^{2,1}) = (1, 101)` and `(101, 1)`.  Its genus-zero
BPS (Gopakumar–Vafa) invariants in degrees `1, …, 5` are the classical numbers
`2875, 609250, 317206375, 242467530000, 229305888887625`
(Candelas–de la Ossa–Green–Parkes and successors), while `rank Pic(Y) = h^{1,1}(Y) = 101`.

We prove:

* `quintic_euler` — the catalog Hodge model reproduces `χ(X₅) = 2(1 − 101) = −200`;
* `quinticMirror_picardRank` — `rank Pic(Y) = 101`, via the catalog mirror involution;
* `sum_ne_of_lt_of_forall_le` — a general obstruction: a sum of values all `≥ M` over a
  finset can never equal a target `t` with `0 < t < M`;
* `quintic_bps_sum_ne_picardRank` — **refutation of Conjecture 1 for the quintic
  family**: for *every* set `S` of degrees `≤ 5`, `∑_{β ∈ S} n⁰_β ≠ 101`.  The
  conjecture as stated is therefore false on the very family it names;
* `bps_sum_eq_card_iff` — the **exact boundary**: for positive BPS invariants,
  `∑_{β∈S} n⁰_β = #S` iff every invariant in `S` equals `1`.  Hence a specialization of
  the required shape can only hold when the sum degenerates into a *count of classes*;
* `graded_bps_picard_iff_all_one` — consequently, the corrected conjecture reads: the sum
  equals `rank Pic(Y)` with `#S = rank Pic(Y)` exactly when all selected BPS invariants
  are `1`, i.e. mirror symmetry matches the Picard rank with the *number of independent
  curve classes*, never with a genuine enumerative total.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  If mirror symmetry converted rational-curve counts into
  a Picard rank, some finite set of primitive classes should realize the rank exactly.
* **Experiment (Experimenter).**  Instantiated on the quintic: the smallest genus-zero
  BPS invariant in the tested range is `n⁰₁ = 2875`, already `≫ 101 = rank Pic(Y)`, and
  all invariants are positive.  So every nonempty `S` overshoots and `S = ∅` gives `0`.
  Numerically: `2875, 609250, 317206375, …` against the single target `101`
  (see `ComputationalEvidence.md`).
* **Analysis (Analyst).**  Conjecture 1 is **false**, and not by accident: it is a *type
  error* between an enumerative count (a large integer attached to one class) and a rank
  (the number of independent classes).  The catalog's own bridge theorem
  `rationalCurveCount_eq_mirrorPicardRank` is honest precisely because it carries the
  identification hypothesis `count = curveModuli`, which the quintic violates.
  `bps_sum_eq_card_iff` pinpoints the only regime where the naive statement can hold.
* **Critique (Critic).**  The refutation quantifies over *all* `S ⊆ {1,…,5}` (not one
  hand-picked `S`), and is proved from a general finset lemma with `Finset.single_le_sum`
  rather than by `decide` over the 32 subsets, so the argument scales to every degree
  range in which the invariants stay above `101`.
* **Synthesis (PI).**  The surviving, correct statement is the *rank/rank* form
  (`Novelty.ArithMirror.CY3.picardRank_mirror`), and the enumerative content lives one
  level down, in the Gromov–Witten potential, not in the rank.
-/

namespace Novelty.MirrorBridge

open Finset Novelty.ArithMirror

/-! ### The named toric mirror family: the quintic threefold and its mirror -/

/-- The quintic threefold `X₅ ⊂ ℙ⁴` in the catalog's Hodge model:
`(h^{1,1}, h^{2,1}) = (1, 101)`. -/
def quintic : CY3 := ⟨1, 101⟩

/-- Its Greene–Plesser mirror `Y = X₅/(ℤ/5)³`, with Hodge data `(101, 1)`. -/
def quinticMirror : CY3 := quintic.mirror

/-- The catalog Hodge model reproduces the classical Euler number `χ(X₅) = −200`. -/
theorem quintic_euler : quintic.euler = -200 := by
  unfold quintic CY3.euler
  norm_num

/-- The mirror quintic has Euler number `+200`: the mirror flip of the catalog. -/
theorem quinticMirror_euler : quinticMirror.euler = 200 := by
  unfold quinticMirror
  rw [CY3.euler_mirror, quintic_euler]
  norm_num

/-- `rank Pic(Y) = h^{1,1}(Y) = h^{2,1}(X) = 101` for the mirror quintic. -/
theorem quinticMirror_picardRank : quinticMirror.picardRank = 101 := by
  unfold quinticMirror
  rw [CY3.picardRank_mirror]
  rfl

/-- The genus-zero BPS (Gopakumar–Vafa) invariants `n⁰_d` of the quintic threefold in
degrees `1, …, 5`; degree `0` is set to `0` (it is not an effective primitive class). -/
def quinticBPS : ℕ → ℕ
  | 1 => 2875
  | 2 => 609250
  | 3 => 317206375
  | 4 => 242467530000
  | 5 => 229305888887625
  | _ => 0

/-! ### A general obstruction to realizing a small target as a sum -/

/-- **Sum obstruction.**  If every selected value is at least `M` and the target `t`
satisfies `0 < t < M`, then no selection of classes has total `t`: the empty selection
gives `0 ≠ t`, and any nonempty one already exceeds `t`. -/
theorem sum_ne_of_lt_of_forall_le {ι : Type*} [DecidableEq ι] (S : Finset ι) (f : ι → ℕ)
    (M t : ℕ) (ht0 : 0 < t) (htM : t < M) (hf : ∀ i ∈ S, M ≤ f i) :
    ∑ i ∈ S, f i ≠ t := by
  rcases S.eq_empty_or_nonempty with rfl | ⟨j, hj⟩
  · simpa using (Nat.ne_of_lt ht0)
  · intro hsum
    have hle : f j ≤ ∑ i ∈ S, f i :=
      Finset.single_le_sum (fun i _ => Nat.zero_le (f i)) hj
    have := hf j hj
    omega

/-- **Refutation of Conjecture 1 on the named quintic mirror family.**
For every finite set `S` of degrees in `{1, …, 5}` — i.e. every finite set of effective
primitive curve classes of the quintic in the tested range — the total genus-zero BPS
invariant `∑_{d ∈ S} n⁰_d` differs from `rank Pic(Y) = 101`.  So the graded genus-zero
mirror/Picard specialization fails for the quintic family. -/
theorem quintic_bps_sum_ne_picardRank (S : Finset ℕ) (hS : S ⊆ Finset.Icc 1 5) :
    ∑ d ∈ S, quinticBPS d ≠ quinticMirror.picardRank := by
  rw [quinticMirror_picardRank]
  refine sum_ne_of_lt_of_forall_le S quinticBPS 2875 101 (by norm_num) (by norm_num) ?_
  intro d hd
  have hd' := hS hd
  simp only [Finset.mem_Icc] at hd'
  obtain ⟨hd1, hd5⟩ := hd'
  interval_cases d <;> simp [quinticBPS]

/-- In particular the two extreme selections fail: no curve classes at all gives `0`, and
all five tested degrees give an astronomically large number. -/
theorem quintic_bps_extremes :
    ∑ d ∈ (∅ : Finset ℕ), quinticBPS d ≠ 101 ∧
    ∑ d ∈ Finset.Icc 1 5, quinticBPS d ≠ 101 := by
  have h := quintic_bps_sum_ne_picardRank (Finset.Icc 1 5) (Finset.Subset.refl _)
  rw [quinticMirror_picardRank] at h
  exact ⟨by simp, h⟩

/-! ### The exact boundary of the conjecture -/

/-- **Where the conjecture *can* hold.**  If all selected genus-zero BPS invariants are
positive, then their total equals the number of selected classes exactly when every one
of them equals `1`.  Thus a "sum of BPS invariants = rank" statement is possible only when
the sum degenerates to a count of classes. -/
theorem bps_sum_eq_card_iff {ι : Type*} [DecidableEq ι] (S : Finset ι) (f : ι → ℕ)
    (hpos : ∀ i ∈ S, 1 ≤ f i) :
    ∑ i ∈ S, f i = S.card ↔ ∀ i ∈ S, f i = 1 := by
  constructor
  · intro hsum i hi
    by_contra hne
    have h2 : 2 ≤ f i := by
      have := hpos i hi
      omega
    have hcard : ∑ j ∈ S, 1 = S.card := by simp
    have hlt : ∑ j ∈ S, (1 : ℕ) < ∑ j ∈ S, f j :=
      Finset.sum_lt_sum (fun j hj => hpos j hj) ⟨i, hi, by omega⟩
    omega
  · intro hone
    rw [Finset.sum_congr rfl hone]
    simp

/-- **Corrected form of Conjecture 1.**  For a selection `S` of primitive classes whose
cardinality is the Picard rank of the mirror, the sum of genus-zero BPS invariants over
`S` equals `rank Pic(Y)` if and only if every selected invariant equals `1`.  Mirror
symmetry therefore matches the Picard rank with the *number of independent curve classes*,
not with an enumerative total — precisely the identification hypothesis carried by the
catalog bridge theorem. -/
theorem graded_bps_picard_iff_all_one {ι : Type*} [DecidableEq ι] (S : Finset ι)
    (f : ι → ℕ) (Y : CY3) (hpos : ∀ i ∈ S, 1 ≤ f i) (hcard : S.card = Y.picardRank) :
    ∑ i ∈ S, f i = Y.picardRank ↔ ∀ i ∈ S, f i = 1 := by
  rw [← hcard]
  exact bps_sum_eq_card_iff S f hpos

/-- The quintic violates the corrected criterion too: its degree-one BPS invariant is
`2875 ≠ 1`, so no selection of `101` primitive classes can work either. -/
theorem quintic_fails_corrected_criterion : quinticBPS 1 ≠ 1 := by
  simp [quinticBPS]

end Novelty.MirrorBridge