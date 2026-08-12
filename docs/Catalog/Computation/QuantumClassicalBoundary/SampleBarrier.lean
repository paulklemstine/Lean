import Mathlib
import Cryptography.FactoringBarriers.DFTSampleBound
import Cryptography.FactoringBarriers.AsymptoticLadder

/-!
# Barrier 1: classical Fourier sampling needs `≥ r` samples, and `r` is typically huge

The information-theoretic half of the boundary.  Two ingredients:

1. **Resolution.** Determining a period-`r` signal from `K` Fourier samples
   forces `K ≥ r` (`FactoringBarriers.dft_sample_count_ge_period`, imported).
2. **Typical order.** In a cyclic group of order `n` the elements of order at
   most `B` number at most `B²` (`card_small_order_le`).  Hence as soon as
   `B² < n` some base has order `> B`, and in fact *most* bases do
   (`most_bases_have_large_order`).  For `n = p - 1` this gives bases of order
   `> √p`, i.e. exponential in the bit-length `log p`.

Combining them (`sampling_needs_more_than_order_samples`,
`classical_sampling_barrier`) yields the honest statement of Barrier 1: any
*classical Fourier sampling* determination of the period of `x ↦ aˣ mod p`
needs a number of samples exceeding `√p` for most bases `a`, and
`x ↦ exp (x/2)` — that is `√N` in the bit-size variable `x = log N` — is
superpolynomial (`sqrt_barrier_superpoly`).

No claim is made that classical *factoring* requires superpolynomial time: the
statement is about the sampling model, which is exactly the resource Shor's
algorithm replaces by coherence.

-- !-- Lab Notes -- !--

* Hypothesis (Hypothesizer): "for a random base the order is `Θ(N)`" should have
  a rigorous, elementary lower-bound shadow: the number of low-order elements is
  polynomially small.
* Experiment (Experimenter): counted `{a : ord a ≤ B}` in a cyclic group by
  covering it with the root sets `{a : a^d = 1}`, `1 ≤ d ≤ B`, each of size
  `≤ d` (`IsCyclic.card_pow_eq_one_le`).  Sum `≤ B²`.  Sharp up to constants:
  for `B = √n` the bound is `n`, and indeed a cyclic group of order `n = B²`
  can have all elements of order `≤ B` only if it is not cyclic — the estimate
  is the right one for the argument we need.
* Analysis (Analyst): the quantitative consequence `#{ord ≤ B} ≤ B²` is enough:
  taking `B = ⌊√(p-2)⌋` shows a *majority* of bases have order `> B`, since
  `B² ≤ p - 2 < p - 1 = #(ZMod p)ˣ`; `most_bases_have_large_order` makes the
  majority statement explicit for `B² ≤ (p-1)/2`.
* Critique (Critic): this proves "large order", not "order `Θ(N)`"; the
  expectation statement needs Erdős–Pomerance-type analytic input and is *not*
  claimed here.  We also flag that `dft_sample_count_ge_period` is a statement
  about *linear* measurement schemes; a nonlinear classical estimator is not
  covered, and we say so rather than overclaiming.
* Synthesis (PI): Barrier 1 = (sample count `≥ r`) × (typical `r` exponential).
  Both factors are proved; their product is the honest classical bound.
-/

namespace QuantumClassicalBoundary

open Finset

/-! ## Counting elements of small order in a cyclic group -/

/-- **Small-order count.**  In a finite cyclic group at most `B²` elements have
order `≤ B`. -/
theorem card_small_order_le {G : Type*} [Group G] [DecidableEq G] [Fintype G] [IsCyclic G]
    (B : ℕ) : (univ.filter (fun a : G => orderOf a ≤ B)).card ≤ B * B := by
  classical
  have hsub : univ.filter (fun a : G => orderOf a ≤ B) ⊆
      (Icc 1 B).biUnion (fun d => univ.filter (fun a : G => a ^ d = 1)) := by
    intro a ha
    simp only [mem_filter, mem_univ, true_and] at ha
    exact mem_biUnion.mpr ⟨orderOf a, mem_Icc.mpr ⟨orderOf_pos a, ha⟩, by
      simp [pow_orderOf_eq_one]⟩
  calc (univ.filter (fun a : G => orderOf a ≤ B)).card
      ≤ ((Icc 1 B).biUnion (fun d => univ.filter (fun a : G => a ^ d = 1))).card :=
        card_le_card hsub
    _ ≤ ∑ d ∈ Icc 1 B, (univ.filter (fun a : G => a ^ d = 1)).card := card_biUnion_le
    _ ≤ ∑ d ∈ Icc 1 B, d := by
        refine sum_le_sum fun d hd => ?_
        exact IsCyclic.card_pow_eq_one_le (by simpa using (mem_Icc.mp hd).1)
    _ ≤ ∑ _d ∈ Icc 1 B, B := sum_le_sum fun d hd => (mem_Icc.mp hd).2
    _ = B * B := by simp [Nat.card_Icc]

/-- If `B² < |G|` then some element of the cyclic group `G` has order `> B`. -/
theorem exists_large_order {G : Type*} [Group G] [DecidableEq G] [Fintype G] [IsCyclic G] {B : ℕ}
    (h : B * B < Fintype.card G) : ∃ a : G, B < orderOf a := by
  by_contra hcon
  push_neg at hcon
  have huniv : (univ.filter (fun a : G => orderOf a ≤ B)) = univ :=
    eq_univ_of_forall (fun a => by simp [hcon a])
  have hcard := card_small_order_le (G := G) B
  rw [huniv, card_univ] at hcard
  omega

/-- **Most bases have large order.**  If `2B² ≤ |G|` then strictly more than half
of the elements of the cyclic group have order `> B`. -/
theorem most_bases_have_large_order {G : Type*} [Group G] [DecidableEq G] [Fintype G] [IsCyclic G]
    {B : ℕ} (h : 2 * (B * B) < Fintype.card G) :
    Fintype.card G / 2 < (univ.filter (fun a : G => B < orderOf a)).card := by
  classical
  have hsplit : (univ.filter (fun a : G => B < orderOf a)).card
      + (univ.filter (fun a : G => orderOf a ≤ B)).card = Fintype.card G := by
    have h := card_filter_add_card_filter_not (s := (univ : Finset G))
      (p := fun a : G => B < orderOf a)
    have heq : (univ.filter (fun a : G => ¬ B < orderOf a))
        = univ.filter (fun a : G => orderOf a ≤ B) := by
      apply filter_congr; intro a _; simp
    rw [heq] at h
    simpa [card_univ] using h
  have hsmall := card_small_order_le (G := G) B
  omega

/-! ## Bases modulo a prime -/

/-- For a prime `p`, if `B² < p - 1` then some base modulo `p` has multiplicative
order greater than `B`. -/
theorem exists_base_large_order {p B : ℕ} [Fact p.Prime] (hB : B * B < p - 1) :
    ∃ a : (ZMod p)ˣ, B < orderOf a := by
  refine exists_large_order ?_
  rwa [ZMod.card_units p]

/-- Concretely: modulo a prime `p ≥ 3` there is a base of multiplicative order
exceeding `⌊√(p-2)⌋`. -/
theorem exists_base_order_gt_sqrt {p : ℕ} [Fact p.Prime] (hp : 3 ≤ p) :
    ∃ a : (ZMod p)ˣ, Nat.sqrt (p - 2) < orderOf a := by
  refine exists_base_large_order ?_
  have h1 := Nat.sqrt_le' (p - 2)
  rw [pow_two] at h1
  omega

/-! ## Barrier 1: sample count -/

/-- **Sampling bound in terms of the order.**  If a family of `K` Fourier
frequencies determines every period-`r` signal, and `r` is the multiplicative
order of the base `a`, then `K` exceeds every lower bound on that order. -/
theorem sampling_needs_more_than_order_samples {p : ℕ} [Fact p.Prime] {a : (ZMod p)ˣ}
    {r K B : ℕ} [NeZero r] (hr : orderOf a = r) (hB : B < orderOf a)
    (idx : Fin K → ZMod r)
    (hdet : ∀ v w : ZMod r → ℂ,
      (∀ j : Fin K, ZMod.dft v (idx j) = ZMod.dft w (idx j)) → v = w) :
    B < K := by
  have hle : r ≤ K := FactoringBarriers.dft_sample_count_ge_period idx hdet
  omega

/-- **Barrier 1 (classical sampling barrier).**  Modulo a prime `p ≥ 3` there is
a base whose multiplicative order exceeds `⌊√(p-2)⌋`; for that base, *any*
Fourier-sampling scheme that determines the period signal must use more than
`⌊√(p-2)⌋` samples.  The sample count is therefore exponential in the bit-length
of `p`. -/
theorem classical_sampling_barrier {p : ℕ} [Fact p.Prime] (hp : 3 ≤ p) :
    ∃ a : (ZMod p)ˣ, Nat.sqrt (p - 2) < orderOf a ∧
      ∀ (r K : ℕ) (_ : NeZero r) (idx : Fin K → ZMod r), orderOf a = r →
        (∀ v w : ZMod r → ℂ,
          (∀ j : Fin K, ZMod.dft v (idx j) = ZMod.dft w (idx j)) → v = w) →
        Nat.sqrt (p - 2) < K := by
  obtain ⟨a, ha⟩ := exists_base_order_gt_sqrt hp
  refine ⟨a, ha, ?_⟩
  intro r K hne idx hr hdet
  exact sampling_needs_more_than_order_samples hr ha idx hdet

/-! ## The barrier is superpolynomial in the bit-size -/

/-- In the bit-size variable `x = log N`, the classical sample requirement `√N`
is the function `x ↦ exp (x/2)`, which is superpolynomial: no polynomial in
`log N` bounds it. -/
theorem sqrt_barrier_superpoly :
    FactoringBarriers.Superpoly (fun x => Real.exp (1 / 2 * x)) :=
  FactoringBarriers.Superpoly_exp_linear (by norm_num)

/-- Hence the classical Fourier-sampling requirement is not polynomially bounded
in the bit-size. -/
theorem sqrt_barrier_not_polyBounded :
    ¬ FactoringBarriers.PolyBounded (fun x => Real.exp (1 / 2 * x)) :=
  FactoringBarriers.not_polyBounded_of_superpoly sqrt_barrier_superpoly

end QuantumClassicalBoundary