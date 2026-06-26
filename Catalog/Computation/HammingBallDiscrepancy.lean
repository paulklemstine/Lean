import Mathlib

/-!
# Average Discrepancy of Codes for Hamming Balls

This file formalizes the *rigorous combinatorial kernel* behind the conjecture on the
discrepancy of random linear codes for all Hamming balls.

## Background (the conjecture)

For a finite field `𝔽_q`, integers `n`, `ρ ∈ (0,1)` and `ε > 0`, one takes a random
linear code `C ⊆ 𝔽_q^n` of dimension `k = ⌈(1 - (1/n)·log_q |B_ρ| + ε)·n⌉` and asks
that, with probability `1-o(1)`, simultaneously for *every* centre `z`,
`|C ∩ B_ρ(z)| = (1 ± o(1)) · |C| · |B_ρ| / q^n`.

The target value `|C| · |B_ρ| / q^n` is exactly the count one would expect if `C` were
a uniformly random set of its size, and the ball `B_ρ(z)` had volume `|B_ρ|` independent
of its centre.

## What is proved here (the unconditional kernel)

The heart of the "first moment" of that statement is a *deterministic, exact* identity:
for **any** subset `C` of the group `G = ι → α` (no linearity, no randomness), the
average over all centres `z` of `|C ∩ B_r(z)|` equals exactly `|C| · |B_r| / |G|`.

* `hammingDist_add_right` — Hamming distance is translation invariant.
* `ball_card_eq` — the ball volume `|B_r(z)|` is independent of the centre `z`.
* `sum_inter_ball` — **exact averaging identity**: `∑_z |C ∩ B_r(z)| = |C| · |B_r|`.
* `card_bad_centres_le` — a one-sided (Markov) discrepancy bound: the centres where
  `|C ∩ B_r(z)|` is at least `t` number at most `|C| · |B_r| / t`.

These isolate precisely the part of the conjecture that holds with certainty; the
remaining gap (per-centre concentration) is what genuinely needs randomness/linearity.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The claimed target value `|C|·|B_ρ|/q^n` is not merely a
heuristic; it is the *exact average* of `|C ∩ B_ρ(z)|` over all centres, for every set
`C`.  If true, the conjecture is exactly a concentration-around-the-mean statement.

Experiment (Experimenter): Formalize the double counting
`∑_z |C ∩ B_r(z)| = ∑_{c∈C} #{z : d(c,z) ≤ r} = ∑_{c∈C} |B_r(c)| = |C|·|B_r|`,
using translation invariance to get `|B_r(c)| = |B_r(0)|`.

Analysis (Analyst): The averaging identity is unconditional and dimension-free; it
needs *no* algebraic structure beyond a group acting by translation.  This shows the
"hard" content of the conjecture is purely the upper/lower tail concentration over the
`q^n` centres, not the value of the mean.  The Markov bound `card_bad_centres_le`
already gives one half (the upper tail for all-but-few centres) for free.

Critique (Critic): The identity is exact, not vacuous: it computes a genuine double sum
and is false if the ball volume depended on the centre, which is why translation
invariance is isolated as a load-bearing lemma.  Linearity of `C` is deliberately *not*
assumed, making the statement strictly more general than the conjecture's hypothesis.
-/

namespace HammingBallDiscrepancy

open Finset

variable {ι : Type*} {α : Type*} [Fintype ι] [DecidableEq ι] [DecidableEq α] [Fintype α]

section Group
variable [AddGroup α]

omit [DecidableEq ι] [Fintype α] in
/-- Hamming distance is invariant under right translation by a common vector `a`. -/
theorem hammingDist_add_right (x y a : ι → α) :
    hammingDist (x + a) (y + a) = hammingDist x y := by
  unfold hammingDist
  congr 1
  ext i
  simp [add_left_inj]

/-- The Hamming ball of radius `r` about centre `z` inside `G = ι → α`. -/
def ball (r : ℕ) (z : ι → α) : Finset (ι → α) :=
  Finset.univ.filter (fun x => hammingDist x z ≤ r)

omit [AddGroup α] in
@[simp]
theorem mem_ball {r : ℕ} {z x : ι → α} :
    x ∈ ball r z ↔ hammingDist x z ≤ r := by
  simp [ball]

/-- The ball about `z` is the translate by `z` of the ball about `0`. -/
theorem ball_eq_image (r : ℕ) (z : ι → α) :
    ball r z = (ball r 0).image (· + z) := by
  ext x
  simp only [mem_ball, mem_image]
  constructor
  · intro hx
    refine ⟨x - z, ?_, sub_add_cancel x z⟩
    have h := hammingDist_add_right (x - z) 0 z
    simp only [sub_add_cancel, zero_add] at h
    rw [← h]; exact hx
  · rintro ⟨y, hy, rfl⟩
    have h := hammingDist_add_right y 0 z
    simp only [zero_add] at h
    rw [h]; exact hy

/-- **Ball volume is independent of the centre.** -/
theorem ball_card_eq (r : ℕ) (z : ι → α) :
    (ball r z).card = (ball r (0 : ι → α)).card := by
  rw [ball_eq_image]
  exact Finset.card_image_of_injective _ (add_left_injective z)

/-- The number of centres `z` whose ball of radius `r` contains a fixed point `c`
equals the ball volume. -/
theorem card_centres_containing (r : ℕ) (c : ι → α) :
    (Finset.univ.filter (fun z => hammingDist c z ≤ r)).card
      = (ball r (0 : ι → α)).card := by
  have hset : (Finset.univ.filter (fun z => hammingDist c z ≤ r)) = ball r c := by
    ext z
    simp only [ball, mem_filter, Finset.mem_univ, true_and]
    rw [hammingDist_comm]
  rw [hset, ball_card_eq]

/-- **Exact averaging identity.** For any subset `C`, the total count of pairs
`(c, z)` with `c ∈ C` and `c` in the ball of radius `r` about `z` equals
`|C| · |B_r|`; equivalently the average over centres `z` of `|C ∩ B_r(z)|` is
exactly `|C| · |B_r| / |G|`. -/
theorem sum_inter_ball (C : Finset (ι → α)) (r : ℕ) :
    ∑ z, (C ∩ ball r z).card = C.card * (ball r (0 : ι → α)).card := by
  have hcount : ∀ z, (C ∩ ball r z).card
      = ∑ c ∈ C, (if hammingDist c z ≤ r then 1 else 0) := by
    intro z
    have heq : C ∩ ball r z = C.filter (fun c => hammingDist c z ≤ r) := by
      ext c
      simp [ball, Finset.mem_inter]
    rw [heq, Finset.card_filter]
  simp_rw [hcount]
  rw [Finset.sum_comm]
  have hinner : ∀ c ∈ C, (∑ z, (if hammingDist c z ≤ r then 1 else 0))
      = (ball r (0 : ι → α)).card := by
    intro c _
    rw [← Finset.card_filter]
    exact card_centres_containing r c
  rw [Finset.sum_congr rfl hinner, Finset.sum_const, smul_eq_mul, mul_comm]

/-- **One-sided (Markov) discrepancy bound.** For any threshold `t`, the centres `z`
at which `|C ∩ B_r(z)|` is at least `t` number at most `|C| · |B_r| / t`. -/
theorem card_bad_centres_le (C : Finset (ι → α)) (r t : ℕ) :
    (Finset.univ.filter (fun z => t ≤ (C ∩ ball r z).card)).card * t
      ≤ C.card * (ball r (0 : ι → α)).card := by
  rw [← sum_inter_ball C r]
  calc (Finset.univ.filter (fun z => t ≤ (C ∩ ball r z).card)).card * t
      = ∑ _z ∈ Finset.univ.filter (fun z => t ≤ (C ∩ ball r z).card), t := by
        rw [Finset.sum_const, smul_eq_mul]
    _ ≤ ∑ z ∈ Finset.univ.filter (fun z => t ≤ (C ∩ ball r z).card),
          (C ∩ ball r z).card := by
        apply Finset.sum_le_sum
        intro z hz
        exact (Finset.mem_filter.mp hz).2
    _ ≤ ∑ z, (C ∩ ball r z).card := by
        apply Finset.sum_le_sum_of_subset
        exact Finset.filter_subset _ _

end Group

end HammingBallDiscrepancy