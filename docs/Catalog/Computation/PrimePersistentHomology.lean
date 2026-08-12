/-
# Persistent Homology of the Prime Point Cloud

The prime numbers `2, 3, 5, 7, 11, …` form a point cloud on the real line, the
`n`-th prime sitting at position `p_n`.  Sweeping a scale parameter `ε ≥ 0` and
joining two points whenever they lie within distance `ε` produces the
Vietoris–Rips filtration of the cloud.  Its degree-zero persistent homology
records how the connected components merge as `ε` grows: a *bar* is born when a
component appears and dies when it is absorbed by an older one.

For a point cloud on a line the entire zero-dimensional barcode is governed by
the *gaps* between consecutive points.  This file makes that statement precise
and specialises it to the primes.

## Main results

* `PrimePH.line_component_iff` — **single-linkage on a line**: two indices `i ≤ j`
  lie in the same `ε`-component if and only if every consecutive gap between them
  is at most `ε`.  This is the combinatorial heart of the barcode: components are
  exactly the maximal runs of small gaps.

* `PrimePH.adjacent_component_iff` — the death scale of the merge between the
  components of neighbouring points `i` and `i+1` is exactly the gap
  `p_{i+1} - p_i`.  Thus the finite `H_0` bar lengths are precisely the gaps.

* `PrimePH.death_scale_eq_primeGap` — for the prime cloud the death scale of the
  `i`-th adjacent merge equals the `i`-th prime gap `p_{i+1} - p_i`, linking the
  topology to the arithmetic gap sequence of `BoundedGaps.lean`.

* `PrimePH.twinPrime_iff_infinitely_many_gap_two` — the **twin prime conjecture**
  is equivalent to the existence of infinitely many prime gaps equal to `2`; via
  `death_scale_eq_primeGap` these are exactly the `H_0` bars whose death scale is
  `2`.  So the twin prime conjecture is the statement that the prime barcode has
  infinitely many bars of length `2`.

-- !-- Lab Notes -- !--
Hypothesis.  The zero-dimensional persistent homology of a point cloud on ℝ is
determined by the gap sequence; for the primes the twin prime conjecture should
translate into a statement about the barcode.

Experiment.  We formalised the Vietoris–Rips adjacency `|p a - p b| ≤ ε` and its
connectivity closure, and proved the single-linkage characterisation via a
covering argument on integer intervals: an edge `a — b` certifies every gap
strictly between `a` and `b`, and the interval `[min a b, max a b)` is always
covered by the two sub-intervals produced along a transitive step.

Analysis.  The line makes the barcode collapse to the gap multiset because gaps
are positive and telescope: `p_{k+1} − p_k ≤ p_b − p_a` whenever `a ≤ k < b`.
The twin prime bridge reduces to the arithmetic fact that consecutive primes are
`2` apart exactly at a twin pair, using `next_prime_le_of_prime_lt` from the
catalog to identify the successor prime.

Critique.  The connectivity relation is the genuine reflexive–transitive–
symmetric closure of the Rips graph, not a definitional restatement of the gap
condition, so the equivalence is a theorem rather than a `rfl`.  The twin prime
equivalence is stated over the honest sets and proved in both directions.

Synthesis.  "Primes have topology": their gap sequence *is* the `H_0` barcode,
and the twin prime conjecture is the assertion that the length-`2` bar recurs
forever.
-/
import Mathlib
import Novelty.BoundedGaps

open Relation

namespace PrimePH

/-- Vietoris–Rips adjacency at scale `ε`: two indices are joined when the
corresponding points lie within distance `ε`. -/
def RipsAdj (p : ℕ → ℝ) (ε : ℝ) (a b : ℕ) : Prop := |p a - p b| ≤ ε

/-- Being in the same `ε`-connected component: the reflexive–transitive closure
of the (symmetric) Rips adjacency relation. -/
def RipsConn (p : ℕ → ℝ) (ε : ℝ) : ℕ → ℕ → Prop :=
  Relation.ReflTransGen (RipsAdj p ε)

/-
A single gap is dominated by any endpoint difference straddling it.
-/
lemma gap_le_sub {p : ℕ → ℝ} (hp : StrictMono p) {a b k : ℕ}
    (h1 : a ≤ k) (h2 : k < b) : p (k + 1) - p k ≤ p b - p a := by
  linarith [ hp.monotone h1, hp.monotone ( Nat.succ_le_of_lt h2 ) ]

/-
An `ε`-edge `a — b` certifies that every consecutive gap strictly between
`a` and `b` is at most `ε`.
-/
lemma edge_gaps {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ} {a b : ℕ}
    (h : RipsAdj p ε a b) :
    ∀ k, min a b ≤ k → k < max a b → p (k + 1) - p k ≤ ε := by
  cases le_total a b <;> simp_all +decide [ RipsAdj ];
  · intro k hk₁ hk₂; linarith [ hp.monotone ( show k + 1 ≤ b by linarith ), hp.monotone ( show a ≤ k by linarith ), abs_le.mp h ] ;
  · intro k hk₁ hk₂; linarith [ abs_le.mp h, hp.monotone hk₁, hp.monotone ( Nat.le_succ k ), hp.monotone hk₂ ] ;

/-
Backward direction of single-linkage: small gaps chain into connectivity.
-/
lemma chain_of_gaps {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ} (hε : 0 ≤ ε)
    (i n : ℕ) (h : ∀ k, i ≤ k → k < i + n → p (k + 1) - p k ≤ ε) :
    RipsConn p ε i (i + n) := by
  induction' n with n ih generalizing i;
  · exact Relation.ReflTransGen.refl;
  · convert Relation.ReflTransGen.tail ( ih i fun k hk₁ hk₂ => h k hk₁ ( by linarith ) ) _ using 1;
    exact abs_sub_le_iff.mpr ⟨ by linarith! [ h ( i + n ) ( by linarith ) ( by linarith ), hp ( Nat.lt_succ_self ( i + n ) ) ], by linarith! [ h ( i + n ) ( by linarith ) ( by linarith ), hp ( Nat.lt_succ_self ( i + n ) ) ] ⟩

/-
Forward direction of single-linkage: connectivity forces all intermediate
gaps to be small.
-/
lemma gaps_of_chain {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ} {a b : ℕ}
    (h : RipsConn p ε a b) :
    ∀ k, min a b ≤ k → k < max a b → p (k + 1) - p k ≤ ε := by
  have := @edge_gaps;
  induction h <;> simp_all +decide;
  grind

/-
**Single-linkage clustering on a line.**  For a strictly increasing point
cloud, indices `i ≤ j` lie in the same `ε`-component precisely when every
consecutive gap between them is at most `ε`.
-/
theorem line_component_iff {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ} (hε : 0 ≤ ε)
    {i j : ℕ} (hij : i ≤ j) :
    RipsConn p ε i j ↔ ∀ k, i ≤ k → k < j → p (k + 1) - p k ≤ ε := by
  constructor;
  · exact fun h k hk₁ hk₂ => gaps_of_chain hp h k ( by aesop ) ( by aesop );
  · exact fun h => by simpa only [ Nat.add_sub_cancel' hij ] using chain_of_gaps hp hε i ( j - i ) fun k hk₁ hk₂ => h k hk₁ ( by omega ) ;

/-
The merge of neighbouring points `i` and `i+1` happens at scale `ε` exactly
when `ε` reaches the gap `p_{i+1} - p_i`; i.e. the `i`-th finite `H_0` bar has
death scale equal to that gap.
-/
theorem adjacent_component_iff {p : ℕ → ℝ} (hp : StrictMono p) {ε : ℝ}
    (hε : 0 ≤ ε) (i : ℕ) :
    RipsConn p ε i (i + 1) ↔ p (i + 1) - p i ≤ ε := by
  convert line_component_iff hp hε ( Nat.le_succ i ) using 1;
  exact ⟨ fun h k hk₁ hk₂ => by rw [ show k = i by linarith ] ; exact h, fun h => h i le_rfl ( Nat.lt_succ_self i ) ⟩

/-! ### The prime point cloud -/

/-- The prime point cloud: the `n`-th prime placed on the real line. -/
noncomputable def P (n : ℕ) : ℝ := (Nat.nth Nat.Prime n : ℝ)

/-
The prime positions are strictly increasing.
-/
lemma P_strictMono : StrictMono P := by
  exact fun a b hab => Nat.cast_lt.mpr ( Nat.nth_strictMono ( Nat.infinite_setOf_prime ) hab )

/-
The death scale of the `i`-th adjacent merge in the prime barcode equals the
`i`-th prime gap of `BoundedGaps.lean`.
-/
theorem death_scale_eq_primeGap (i : ℕ) :
    P (i + 1) - P i = (TwinPrimeGaps.primeGap i : ℝ) := by
  unfold P TwinPrimeGaps.primeGap;
  rw [ Nat.cast_sub ( Nat.nth_monotone ( Nat.infinite_setOf_prime ) ( Nat.le_succ _ ) ) ]

/-
Neighbouring primes merge at scale `ε` iff `ε` is at least their gap.
-/
theorem prime_adjacent_component_iff {ε : ℝ} (hε : 0 ≤ ε) (i : ℕ) :
    RipsConn P ε i (i + 1) ↔ (TwinPrimeGaps.primeGap i : ℝ) ≤ ε := by
  grind +suggestions

/-! ### The twin prime bar -/

/-
**The twin prime conjecture as a barcode statement.**  There are infinitely
many twin prime pairs `(p, p+2)` if and only if there are infinitely many indices
`n` with prime gap exactly `2` — equivalently, infinitely many `H_0` bars of
death scale `2`.
-/
theorem twinPrime_iff_infinitely_many_gap_two :
    {p : ℕ | p.Prime ∧ (p + 2).Prime}.Infinite ↔
      {n : ℕ | TwinPrimeGaps.primeGap n = 2}.Infinite := by
  constructor <;> intro h;
  · refine Set.infinite_iff_exists_gt.mpr ?_;
    intro a
    obtain ⟨p, hp⟩ : ∃ p, Nat.Prime p ∧ Nat.Prime (p + 2) ∧ a < Nat.count Nat.Prime p := by
      contrapose! h;
      refine Set.finite_iff_bddAbove.mpr ⟨ Nat.nth Nat.Prime a, fun p hp => ?_ ⟩;
      exact Nat.le_of_lt_succ <| Nat.lt_succ_of_le <| Nat.le_trans ( Nat.le_of_lt_succ <| by { have := Nat.nth_count hp.1; aesop } ) ( Nat.nth_monotone ( Nat.infinite_setOf_prime ) <| h p hp.1 hp.2 );
    refine' ⟨ Nat.count Nat.Prime p, _, _ ⟩ <;> simp_all +decide [ TwinPrimeGaps.primeGap ];
    -- By definition of $p$, we know that $p$ is prime and $p + 2$ is prime.
    have h_prime : Nat.nth Nat.Prime (Nat.count Nat.Prime p) = p := by
      rw [ Nat.nth_count ] ; aesop
    have h_prime_plus_two : Nat.nth Nat.Prime (Nat.count Nat.Prime p + 1) = p + 2 := by
      refine' le_antisymm _ _;
      · refine' Nat.le_of_lt_succ ( Nat.nth_lt_of_lt_count _ );
        grind +suggestions;
      · refine' Nat.le_of_not_lt fun h => _;
        -- If $Nat.nth Nat.Prime (Nat.count Nat.Prime p + 1) < p + 2$, then it must be equal to $p + 1$.
        have h_eq : Nat.nth Nat.Prime (Nat.count Nat.Prime p + 1) = p + 1 := by
          exact le_antisymm ( Nat.le_of_lt_succ h ) ( Nat.succ_le_of_lt ( Nat.lt_of_le_of_lt ( Nat.le_of_eq h_prime.symm ) ( Nat.nth_strictMono ( Nat.infinite_setOf_prime ) ( Nat.lt_succ_self _ ) ) ) );
        cases Nat.Prime.eq_two_or_odd hp.1 <;> cases Nat.Prime.eq_two_or_odd ( show Nat.Prime ( p + 1 ) from h_eq ▸ Nat.prime_nth_prime _ ) <;> simp_all +arith +decide [ Nat.add_mod ]
    rw [h_prime_plus_two]
    simp;
  · rw [ Set.infinite_iff_exists_gt ] at *;
    intro a; obtain ⟨ b, hb₁, hb₂ ⟩ := h a; use Nat.nth Nat.Prime b; simp_all +decide [ TwinPrimeGaps.primeGap ] ;
    exact ⟨ by simp [ ← hb₁, Nat.add_sub_of_le ( Nat.le_of_lt ( Nat.nth_strictMono ( Nat.infinite_setOf_prime ) ( Nat.lt_succ_self _ ) ) ) ], by linarith [ show Nat.nth Nat.Prime b ≥ b + 1 from Nat.recOn b ( Nat.Prime.pos ( by norm_num ) ) fun n ihn => Nat.succ_le_of_lt ( Nat.lt_of_le_of_lt ihn ( Nat.nth_strictMono ( Nat.infinite_setOf_prime ) ( Nat.lt_succ_self _ ) ) ) ] ⟩

end PrimePH