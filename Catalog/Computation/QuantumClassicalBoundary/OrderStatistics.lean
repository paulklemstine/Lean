import Mathlib
import Computation.QuantumClassicalBoundary.SampleBarrier

/-!
# Cycle 3: a sharper count of low-order bases

`SampleBarrier.lean` proved `#{a : ord a ≤ B} ≤ B²` in a finite cyclic group by
covering with root sets.  The bound is wasteful: only *divisors* of the group
order can occur as orders, so the covering may be indexed by the divisors of
`|G|` that are `≤ B`.  This yields

  `#{a : ord a ≤ B} ≤ B · #{d ∣ |G| : d ≤ B}`,

which refines `B²` because `#{d ∣ |G| : d ≤ B} ≤ B`
(`card_divisors_le_bound`), and is dramatically better when `|G|` has few
divisors — the typical case for `|G| = p - 1` is `#divisors = |G|^{o(1)}`.
Consequently a base of order `> B` exists as soon as
`B · #{d ∣ |G| : d ≤ B} < |G|` (`exists_large_order_divisor_bound`), a strictly
weaker requirement than `B² < |G|`.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): the `B²` bound of cycle 1 is lossy; replacing the
  index set `{1,…,B}` by `{d ∣ n : d ≤ B}` should give `B^{1+o(1)}`.
* Experiment (Experimenter): re-ran the covering argument with the divisor index
  set, using `orderOf_dvd_card` for membership and
  `IsCyclic.card_pow_eq_one_le` for each fibre.  Both refinement and the
  comparison `#{d ∣ n : d ≤ B} ≤ B` go through.
* Analysis (Analyst): for `n = p - 1` with `p - 1` having `τ` divisors this
  produces a base of order `> n / τ` rather than only `> √n`; since `τ` is
  `n^{o(1)}`, this is `n^{1-o(1)}` — the quantitative shape conjectured as C4 in
  `FUTURE_DIRECTIONS.md`, now proved in the divisor-counting form.
* Critique (Critic): the statement is conditional on the divisor count, which is
  the honest formulation; converting `τ(n) = n^{o(1)}` into an explicit bound
  requires the divisor-bound theorem, not developed here.
* Synthesis (PI): cycle 3 closes the loss in cycle 1's counting step.
-/

namespace QuantumClassicalBoundary

open Finset

/-- Distinct positive divisors bounded by `B` number at most `B`. -/
theorem card_divisors_le_bound (n B : ℕ) :
    ((Nat.divisors n).filter (fun d => d ≤ B)).card ≤ B := by
  classical
  have hsub : (Nat.divisors n).filter (fun d => d ≤ B) ⊆ Icc 1 B := by
    intro d hd
    rw [mem_filter] at hd
    exact mem_Icc.mpr ⟨Nat.pos_of_mem_divisors hd.1, hd.2⟩
  calc ((Nat.divisors n).filter (fun d => d ≤ B)).card ≤ (Icc 1 B).card := card_le_card hsub
    _ = B := by simp

/-- **Refined small-order count.**  In a finite cyclic group the number of
elements of order at most `B` is at most `B` times the number of divisors of
`|G|` that are at most `B`. -/
theorem card_small_order_le_divisors {G : Type*} [Group G] [DecidableEq G] [Fintype G]
    [IsCyclic G] (B : ℕ) :
    (univ.filter (fun a : G => orderOf a ≤ B)).card
      ≤ B * ((Nat.divisors (Fintype.card G)).filter (fun d => d ≤ B)).card := by
  classical
  have hcard : Fintype.card G ≠ 0 := Fintype.card_ne_zero
  set D := (Nat.divisors (Fintype.card G)).filter (fun d => d ≤ B) with hD
  have hsub : univ.filter (fun a : G => orderOf a ≤ B) ⊆
      D.biUnion (fun d => univ.filter (fun a : G => a ^ d = 1)) := by
    intro a ha
    simp only [mem_filter, mem_univ, true_and] at ha
    refine mem_biUnion.mpr ⟨orderOf a, ?_, by simp [pow_orderOf_eq_one]⟩
    rw [hD, mem_filter]
    exact ⟨Nat.mem_divisors.mpr ⟨orderOf_dvd_card, hcard⟩, ha⟩
  calc (univ.filter (fun a : G => orderOf a ≤ B)).card
      ≤ (D.biUnion (fun d => univ.filter (fun a : G => a ^ d = 1))).card := card_le_card hsub
    _ ≤ ∑ d ∈ D, (univ.filter (fun a : G => a ^ d = 1)).card := card_biUnion_le
    _ ≤ ∑ d ∈ D, d := by
        refine sum_le_sum fun d hd => ?_
        rw [hD, mem_filter] at hd
        exact IsCyclic.card_pow_eq_one_le (Nat.pos_of_mem_divisors hd.1)
    _ ≤ ∑ _d ∈ D, B := by
        refine sum_le_sum fun d hd => ?_
        rw [hD, mem_filter] at hd
        exact hd.2
    _ = B * D.card := by rw [sum_const, smul_eq_mul, Nat.mul_comm]

/-- The refinement really is a refinement: it implies the `B²` bound. -/
theorem card_small_order_le_of_divisors {G : Type*} [Group G] [DecidableEq G] [Fintype G]
    [IsCyclic G] (B : ℕ) : (univ.filter (fun a : G => orderOf a ≤ B)).card ≤ B * B :=
  le_trans (card_small_order_le_divisors B)
    (Nat.mul_le_mul_left B (card_divisors_le_bound _ B))

/-- **Existence of a high-order base, divisor form.**  If `B` times the number of
divisors of `|G|` below `B` is smaller than `|G|`, some element has order `> B`.
This is weaker than requiring `B² < |G|`. -/
theorem exists_large_order_divisor_bound {G : Type*} [Group G] [DecidableEq G] [Fintype G]
    [IsCyclic G] {B : ℕ}
    (h : B * ((Nat.divisors (Fintype.card G)).filter (fun d => d ≤ B)).card < Fintype.card G) :
    ∃ a : G, B < orderOf a := by
  classical
  by_contra hcon
  push_neg at hcon
  have huniv : (univ.filter (fun a : G => orderOf a ≤ B)) = univ :=
    eq_univ_of_forall (fun a => by simp [hcon a])
  have hcard := card_small_order_le_divisors (G := G) B
  rw [huniv, card_univ] at hcard
  omega

/-- Specialised to the multiplicative group modulo a prime: a base of order
greater than `B` exists as soon as `B · #{d ∣ p-1 : d ≤ B} < p - 1`. -/
theorem exists_base_large_order_divisor {p B : ℕ} [Fact p.Prime]
    (h : B * ((Nat.divisors (p - 1)).filter (fun d => d ≤ B)).card < p - 1) :
    ∃ a : (ZMod p)ˣ, B < orderOf a := by
  refine exists_large_order_divisor_bound ?_
  rwa [ZMod.card_units p]

end QuantumClassicalBoundary