/-
# Cycle 3: bounded prime gaps as a topological statement about the prime barcode

The bounded-gaps theorem of Zhang and Maynard–Tao says that infinitely many pairs of primes
lie within a bounded distance `B`.  `Catalog/Novelty/BoundedGaps.lean` turns that input into
the statement `liminf (p_{n+1} - p_n) ≤ B` about *consecutive* primes.  The present file
translates the whole picture into persistent homology: bounded gaps are exactly the
assertion that the **Betti defect of the prime point cloud at the finite scale `B` is
unbounded**, i.e. that arbitrarily many merges of connected components have already
happened by the time the Rips parameter reaches `B`.

## Main results

* `PrimeBounded.bettiDefect_eq` — the defect `n + 1 - b₀(ε, n)` counts exactly the bars of
  length `≤ ε`: it is the number of merges that have taken place at scale `ε`.

* `PrimeBounded.infinite_small_bars_iff_defect_unbounded` — the scale-`ε` defect is
  unbounded if and only if infinitely many prime gaps are at most `ε`.

* `PrimeBounded.boundedPairs_defect_unbounded` — **the bounded-gaps theorem in barcode
  form**: if arbitrarily large prime pairs within distance `B` exist, then the prime cloud
  performs arbitrarily many merges at the fixed scale `B`.  With `B = 246` this is the
  Maynard–Tao statement (`PrimeBounded.maynardTao_defect_unbounded`).

* `PrimeBounded.liminf_primeGap_le_of_defect_unbounded` — the converse translation: an
  unbounded scale-`B` defect forces `liminf (p_{n+1} - p_n) ≤ B`.  Combining the two, the
  topological and arithmetic formulations of bounded gaps are equivalent.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  H7: "small gaps" and "early merges" are the same phenomenon, so
the bounded-gaps theorem should be equivalent to unboundedness of the Betti defect at a
fixed finite scale.  H8: the twin prime conjecture is the case `B = 2` of H7 (established
in the previous cycle as `twinPrime_iff_bettiDefect_unbounded`).

Experiment (Experimenter).  The defect identity follows from the Betti staircase by
complementary counting.  The equivalence with an infinite set of small-gap indices reuses
the counting-function machinery from the previous cycle (`exists_card_filter_ge`,
`card_filter_le_of_finite`).  The Zhang/Maynard input is taken in the exact form used by
`Catalog/Novelty/BoundedGaps.lean`, namely `exists_index_gap_le`, so the two developments
compose without restating the sieve theorem.

Analysis (Analyst).  In the barcode language the entire bounded-gaps programme becomes a
single statement about the *left end* of the persistence diagram, while the results of the
first cycle (arbitrarily long bars, unbounded Betti numbers) concern its *right end*.  The
prime barcode therefore has infinitely many bars at both ends of the scale axis, which is
what makes the naive Poisson model both attractive and false.

Critique (Critic).  Every conditional theorem carries its hypothesis explicitly as an
argument, never as an axiom: nothing here silently assumes Zhang's theorem.  The defect is
written with truncated subtraction, which is safe because `b₀(ε, n) ≤ n + 1`, and that
bound is proved rather than assumed.

Synthesis (PI).  Small prime gaps = early merges; large prime gaps = eternal components.
The prime barcode encodes both halves of the modern theory of prime gaps.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Novelty.PrimeBarcodeInvariants
import Catalog.NumberTheory.PrimeBarcodeArithmetic

namespace PrimeBounded

open Finset

/-- The number of bars of length at most `ε` among the first `n` bars: the number of merges
of connected components that have already happened at scale `ε`. -/
noncomputable def mergeCount (ε : ℝ) (n : ℕ) : ℕ :=
  ((Finset.range n).filter (fun i => (TwinPrimeGaps.primeGap i : ℝ) ≤ ε)).card

/-- The Betti number never exceeds the number of points. -/
theorem bettiZero_le (ε : ℝ) (n : ℕ) : PrimeBarcode.bettiZero PrimePH.P ε n ≤ n + 1 := by
  classical
  rw [PrimeBarcode.prime_bettiZero_eq]
  have hcard : ((Finset.range n).filter
      (fun i => ε < (TwinPrimeGaps.primeGap i : ℝ))).card ≤ n := by
    simpa using Finset.card_filter_le (Finset.range n)
      (fun i => ε < (TwinPrimeGaps.primeGap i : ℝ))
  omega

/-- **The Betti defect counts the merges.**  The number of components lost by scale `ε` is
exactly the number of bars of length `≤ ε`. -/
theorem bettiDefect_eq (ε : ℝ) (n : ℕ) :
    n + 1 - PrimeBarcode.bettiZero PrimePH.P ε n = mergeCount ε n := by
  classical
  rw [PrimeBarcode.prime_bettiZero_eq]
  have hsplit :
      ((Finset.range n).filter (fun i => ε < (TwinPrimeGaps.primeGap i : ℝ))).card
        + ((Finset.range n).filter
            (fun i => ¬ (ε < (TwinPrimeGaps.primeGap i : ℝ)))).card = n := by
    simpa using Finset.card_filter_add_card_filter_not (s := Finset.range n)
      (fun i => ε < (TwinPrimeGaps.primeGap i : ℝ))
  have hneg : (Finset.range n).filter (fun i => ¬ (ε < (TwinPrimeGaps.primeGap i : ℝ)))
      = (Finset.range n).filter (fun i => (TwinPrimeGaps.primeGap i : ℝ) ≤ ε) := by
    apply Finset.filter_congr
    intro i _
    exact ⟨fun h => not_lt.mp h, fun h => not_lt.mpr h⟩
  rw [hneg] at hsplit
  unfold mergeCount
  omega

/-- **Small bars are early merges.**  The scale-`ε` defect of the prime cloud is unbounded
if and only if infinitely many prime gaps are at most `ε`. -/
theorem infinite_small_bars_iff_defect_unbounded (ε : ℝ) :
    {i : ℕ | (TwinPrimeGaps.primeGap i : ℝ) ≤ ε}.Infinite ↔
      ∀ K : ℕ, ∃ n, K ≤ n + 1 - PrimeBarcode.bettiZero PrimePH.P ε n := by
  classical
  constructor
  · intro h K
    obtain ⟨n, hn⟩ := PrimeBarcodeArith.exists_card_filter_ge
      (p := fun i => (TwinPrimeGaps.primeGap i : ℝ) ≤ ε) h K
    refine ⟨n, ?_⟩
    rw [bettiDefect_eq]
    simpa [mergeCount] using hn
  · intro h
    by_contra hfin
    rw [Set.not_infinite] at hfin
    obtain ⟨n, hn⟩ := h (hfin.toFinset.card + 1)
    rw [bettiDefect_eq] at hn
    have hle : mergeCount ε n ≤ hfin.toFinset.card := by
      simpa [mergeCount] using PrimeBarcodeArith.card_filter_le_of_finite
        (p := fun i => (TwinPrimeGaps.primeGap i : ℝ) ≤ ε) hfin n
    omega

/-- Infinitely many bars of length `≤ B` occur if arbitrarily large bounded prime pairs
exist (the Zhang / Maynard–Tao input, taken as an explicit hypothesis). -/
theorem infinite_small_bars_of_boundedPairs (B : ℕ)
    (h : ∀ N : ℕ, ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N ≤ p ∧ p < q ∧ q ≤ p + B) :
    {i : ℕ | (TwinPrimeGaps.primeGap i : ℝ) ≤ (B : ℝ)}.Infinite := by
  classical
  rw [Set.infinite_iff_exists_gt]
  intro a
  obtain ⟨n, hn1, hn2⟩ := TwinPrimeGaps.exists_index_gap_le B h (a + 1)
  refine ⟨n, ?_, by omega⟩
  simpa using (Nat.cast_le (α := ℝ)).mpr hn2

/-- **The bounded-gaps theorem in barcode form.**  If arbitrarily large prime pairs within
distance `B` exist, then the prime point cloud undergoes arbitrarily many component merges
at the single fixed scale `B`: its Betti defect at scale `B` is unbounded. -/
theorem boundedPairs_defect_unbounded (B : ℕ)
    (h : ∀ N : ℕ, ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N ≤ p ∧ p < q ∧ q ≤ p + B) :
    ∀ K : ℕ, ∃ n, K ≤ n + 1 - PrimeBarcode.bettiZero PrimePH.P (B : ℝ) n :=
  (infinite_small_bars_iff_defect_unbounded (B : ℝ)).mp
    (infinite_small_bars_of_boundedPairs B h)

/-- **Maynard–Tao in barcode form** (`B = 246`). -/
theorem maynardTao_defect_unbounded
    (h : ∀ N : ℕ, ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ N ≤ p ∧ p < q ∧ q ≤ p + 246) :
    ∀ K : ℕ, ∃ n, K ≤ n + 1 - PrimeBarcode.bettiZero PrimePH.P (246 : ℝ) n := by
  simpa using boundedPairs_defect_unbounded 246 h

/-- **Converse translation.**  An unbounded Betti defect at scale `B` forces the arithmetic
bounded-gaps conclusion `liminf (p_{n+1} - p_n) ≤ B`. -/
theorem liminf_primeGap_le_of_defect_unbounded (B : ℕ)
    (h : ∀ K : ℕ, ∃ n, K ≤ n + 1 - PrimeBarcode.bettiZero PrimePH.P (B : ℝ) n) :
    Filter.atTop.liminf TwinPrimeGaps.primeGap ≤ B := by
  classical
  have hinf : {i : ℕ | (TwinPrimeGaps.primeGap i : ℝ) ≤ (B : ℝ)}.Infinite :=
    (infinite_small_bars_iff_defect_unbounded (B : ℝ)).mpr h
  have hfreq : ∀ M : ℕ, ∃ n ≥ M, TwinPrimeGaps.primeGap n ≤ B := by
    intro M
    obtain ⟨n, hn1, hn2⟩ := (Set.infinite_iff_exists_gt.mp hinf) M
    exact ⟨n, le_of_lt hn2, by exact_mod_cast hn1⟩
  refine csSup_le ⟨0, Filter.Eventually.of_forall fun _ => Nat.zero_le _⟩ ?_
  intro b hb
  have hb' : ∀ᶠ n in Filter.atTop, b ≤ TwinPrimeGaps.primeGap n := hb
  rw [Filter.eventually_atTop] at hb'
  obtain ⟨x, hx⟩ := hb'
  obtain ⟨n, hn1, hn2⟩ := hfreq x
  exact le_trans (hx n hn1) hn2

end PrimeBounded