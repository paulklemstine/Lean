import Mathlib
import Computation.HammingBallDiscrepancy

/-!
# The Hamming-Ball Volume Formula

This file computes the volume `|B_ρ|` that appears in the dimension `k` of the
discrepancy conjecture.  Over the ambient space `G = ι → α` with `n = |ι|` coordinates and
alphabet size `q = |α|`, the number of points at Hamming distance exactly `r` from a fixed
centre is `C(n, r) · (q - 1)^r`, and the ball volume is the partial sum of these.

* `sphere_card` — `|{x : d(x,0) = r}| = C(n,r) · (q-1)^r`.
* `ball_card_eq_sum_sphere` — `|B_r(0)| = ∑_{i ≤ r} |sphere i|`.
* `ball_card_formula` — `|B_r(0)| = ∑_{i ≤ r} C(n,i) · (q-1)^i`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The ball volume in the conjecture's dimension formula is the
classical sum `∑_{i≤r} C(n,i)(q-1)^i`; the per-sphere count is exactly `C(n,i)(q-1)^i`.

Experiment (Experimenter): Count spheres by support: a point at distance `r` from `0` is
determined by a size-`r` support `S ⊆ univ` (`C(n,r)` choices) together with a nonzero
value at each coordinate of `S` (`(q-1)^r` choices).  The ball is the disjoint union of
spheres of radii `0,…,r`.

Analysis (Analyst): The volume is centre-independent (`ball_card_eq` in
`HammingBallDiscrepancy`), so the single quantity `|B_r(0)|` controls every centre in the
averaging identity.  This closes the loop: the conjecture's target `|C|·|B_r|/q^n` is
`|C| · (∑_{i≤r} C(n,i)(q-1)^i) / q^n`, an explicit rational.

Critique (Critic): The support-counting bijection is the load-bearing step; `q - 1` is a
truncated `ℕ` subtraction, which is correct here because `q ≥ 1` for a nonempty alphabet.
-/

namespace HammingBallDiscrepancy

open Finset

variable {ι : Type*} {α : Type*} [Fintype ι] [DecidableEq ι] [DecidableEq α] [Fintype α]
variable [AddGroup α]

/-- The Hamming sphere of radius `r` about `z`: points at distance exactly `r`. -/
def sphere (r : ℕ) (z : ι → α) : Finset (ι → α) :=
  Finset.univ.filter (fun x => hammingDist x z = r)

omit [AddGroup α] in
@[simp] theorem mem_sphere {r : ℕ} {z x : ι → α} :
    x ∈ sphere r z ↔ hammingDist x z = r := by
  simp [sphere]

/-- **Sphere count.** The number of points at Hamming distance exactly `r` from the origin
is `C(n,r) · (q-1)^r`, with `n = |ι|` and `q = |α|`. -/
theorem sphere_card (r : ℕ) :
    (sphere r (0 : ι → α)).card
      = (Fintype.card ι).choose r * (Fintype.card α - 1) ^ r := by
  classical
  have hdist : ∀ x : ι → α, hammingDist x 0 = (univ.filter (fun i => x i ≠ 0)).card := by
    intro x; unfold hammingDist; simp only [Pi.zero_apply]
  have hfiber : ∀ S : Finset ι,
      (univ.filter (fun x : ι → α => (univ.filter (fun i => x i ≠ 0)) = S)).card
        = (Fintype.card α - 1) ^ S.card := by
    intro S
    set T : ι → Finset α := fun i => if i ∈ S then (univ.filter (fun a : α => a ≠ 0)) else {0}
      with hT
    have hpi : (univ.filter (fun x : ι → α => (univ.filter (fun i => x i ≠ 0)) = S))
        = Fintype.piFinset T := by
      ext x
      simp only [mem_filter, Finset.mem_univ, true_and, Fintype.mem_piFinset, hT]
      constructor
      · intro hx i
        by_cases hi : i ∈ S
        · simp only [hi, if_true, mem_filter, Finset.mem_univ, true_and]
          rw [← hx] at hi
          simpa using (mem_filter.mp hi).2
        · simp only [hi, if_false, Finset.mem_singleton]
          by_contra hne
          apply hi; rw [← hx]; simp [hne]
      · intro hx
        ext i
        simp only [mem_filter, Finset.mem_univ, true_and]
        constructor
        · intro hne
          by_contra hi
          have := hx i
          simp only [hi, if_false, Finset.mem_singleton] at this
          exact hne this
        · intro hi
          have := hx i
          simp only [hi, if_true, mem_filter, Finset.mem_univ, true_and] at this
          exact this
    rw [hpi, Fintype.card_piFinset]
    have hval : ∀ i, (T i).card = if i ∈ S then (Fintype.card α - 1) else 1 := by
      intro i
      simp only [hT]
      by_cases hi : i ∈ S
      · simp only [hi, if_true]
        rw [Finset.filter_ne', Finset.card_erase_of_mem (Finset.mem_univ 0)]; rfl
      · simp [hi]
    rw [Finset.prod_congr rfl (fun i _ => hval i), Finset.prod_ite_mem]
    simp
  rw [card_eq_sum_card_fiberwise
        (f := fun x : ι → α => univ.filter (fun i => x i ≠ 0))
        (t := powersetCard r (univ : Finset ι))]
  · have hterm : ∀ S ∈ powersetCard r (univ : Finset ι),
        ((sphere r (0:ι→α)).filter (fun x => univ.filter (fun i => x i ≠ 0) = S)).card
          = (Fintype.card α - 1) ^ r := by
      intro S hS
      rw [Finset.mem_powersetCard] at hS
      have hScard : S.card = r := hS.2
      have hset : (sphere r (0:ι→α)).filter (fun x => univ.filter (fun i => x i ≠ 0) = S)
          = univ.filter (fun x : ι → α => univ.filter (fun i => x i ≠ 0) = S) := by
        ext x
        simp only [sphere, mem_filter, Finset.mem_univ, true_and]
        constructor
        · rintro ⟨_, h2⟩; exact h2
        · intro h2
          refine ⟨?_, h2⟩
          rw [hdist, h2, hScard]
      rw [hset, hfiber, hScard]
    rw [Finset.sum_congr rfl hterm, Finset.sum_const, Finset.card_powersetCard]
    simp [Finset.card_univ]
  · intro x hx
    simp only [Finset.mem_coe, sphere, mem_filter, Finset.mem_univ, true_and] at hx
    rw [Finset.mem_coe]
    dsimp only
    rw [Finset.mem_powersetCard]
    refine ⟨Finset.filter_subset _ _, ?_⟩
    rw [← hdist]; exact hx

/-- The ball of radius `r` is the disjoint union of the spheres of radii `0,…,r`, so its
volume is the sum of the sphere volumes. -/
theorem ball_card_eq_sum_sphere (r : ℕ) :
    (ball r (0 : ι → α)).card = ∑ i ∈ Finset.range (r + 1), (sphere i (0 : ι → α)).card := by
  have hbi : ball r (0 : ι → α)
      = (Finset.range (r + 1)).biUnion (fun i => sphere i (0 : ι → α)) := by
    ext x
    simp only [ball, sphere, mem_filter, Finset.mem_univ, true_and, Finset.mem_biUnion,
      Finset.mem_range, Nat.lt_succ_iff]
    constructor
    · intro h; exact ⟨hammingDist x 0, h, rfl⟩
    · rintro ⟨i, hi, he⟩; exact he ▸ hi
  rw [hbi, Finset.card_biUnion]
  intro i _ j _ hij
  simp only [Finset.disjoint_left, sphere, mem_filter, Finset.mem_univ, true_and]
  intro x hxi hxj
  exact hij (hxi ▸ hxj)

/-- **Ball volume formula.** `|B_r(0)| = ∑_{i ≤ r} C(n,i) · (q-1)^i`. -/
theorem ball_card_formula (r : ℕ) :
    (ball r (0 : ι → α)).card
      = ∑ i ∈ Finset.range (r + 1),
          (Fintype.card ι).choose i * (Fintype.card α - 1) ^ i := by
  rw [ball_card_eq_sum_sphere]
  exact Finset.sum_congr rfl (fun i _ => sphere_card i)

end HammingBallDiscrepancy