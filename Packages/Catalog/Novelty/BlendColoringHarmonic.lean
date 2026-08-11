import Mathlib

/-!
# Blend colourings of row-stochastic digraphs: the maximum-principle collapse

A **blend colouring** of a finite digraph with nonnegative weights `w` whose rows sum to `1`
is a real colouring `c` that is *harmonic*: the colour of each vertex is the `w`-average of
the colours of its out-neighbours,

`c i = ∑ j, w i j * c j`.

This file proves the collapse theorem that `Novelty/BlendColoringApplications.lean` builds
on: on a strongly connected such digraph a blend colouring must be **constant**.

The proof is the discrete maximum principle.  Pick a vertex `i₀` where `c` is maximal, with
value `M`.  Harmonicity gives `∑ j, w i₀ j * (M - c j) = 0`, a sum of nonnegative terms, so
every term vanishes; hence `c j = M` for every out-neighbour `j` of `i₀` with positive
weight.  Induction along a walk propagates the maximum to every vertex reachable from `i₀`,
and strong connectivity means that is every vertex.

Main results:

* `Arc` : the arc relation `0 < w i j` underlying strong connectivity;
* `blend_le_max_of_arc` : the one-step maximum principle;
* `blend_const` : **a blend colouring of a finite strongly connected row-stochastic digraph
  is constant**.
-/

namespace Novelty.BlendColoringHarmonic

open scoped BigOperators

variable {V : Type*} [Fintype V]

/-- The arc relation of a weight matrix: `i → j` when the weight is strictly positive. -/
def Arc (w : V → V → ℝ) : V → V → Prop := fun i j => 0 < w i j

/-- **One-step maximum principle.**  If `c` attains its maximum `c i₀` at `i₀`, then every
out-neighbour of `i₀` (an arc of positive weight) also attains it. -/
theorem blend_le_max_of_arc (w : V → V → ℝ) (c : V → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hrow : ∀ i, ∑ j, w i j = 1)
    (hblend : ∀ i, c i = ∑ j, w i j * c j)
    {i₀ : V} (hmax : ∀ x, c x ≤ c i₀) {j : V} (harc : Arc w i₀ j) :
    c j = c i₀ := by
  have hzero : ∑ k, w i₀ k * (c i₀ - c k) = 0 := by
    have hexpand : ∑ k, w i₀ k * (c i₀ - c k)
        = (∑ k, w i₀ k) * c i₀ - ∑ k, w i₀ k * c k := by
      rw [Finset.sum_mul, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun k _ => by ring
    rw [hexpand, hrow i₀, one_mul, ← hblend i₀, sub_self]
  have hnonneg : ∀ k ∈ (Finset.univ : Finset V), 0 ≤ w i₀ k * (c i₀ - c k) :=
    fun k _ => mul_nonneg (hw i₀ k) (sub_nonneg.mpr (hmax k))
  have hterm : w i₀ j * (c i₀ - c j) = 0 :=
    (Finset.sum_eq_zero_iff_of_nonneg hnonneg).mp hzero j (Finset.mem_univ j)
  have := mul_eq_zero.mp hterm
  rcases this with h | h
  · exact absurd h (ne_of_gt harc)
  · linarith [sub_eq_zero.mp h]

/-- **The blend-colouring collapse.**  On a finite strongly connected digraph with
nonnegative row-stochastic weights, every blend (harmonic) colouring is constant. -/
theorem blend_const (w : V → V → ℝ) (c : V → ℝ)
    (hw : ∀ i j, 0 ≤ w i j) (hrow : ∀ i, ∑ j, w i j = 1)
    (hblend : ∀ i, c i = ∑ j, w i j * c j)
    (hsc : ∀ i j, Relation.ReflTransGen (Arc w) i j) :
    ∀ i j, c i = c j := by
  intro i j
  obtain ⟨i₀, -, hmax'⟩ :=
    Finset.exists_max_image (Finset.univ : Finset V) c ⟨i, Finset.mem_univ i⟩
  have hmax : ∀ x, c x ≤ c i₀ := fun x => hmax' x (Finset.mem_univ x)
  have hprop : ∀ u v : V, Relation.ReflTransGen (Arc w) u v → c u = c i₀ → c v = c i₀ := by
    intro u v h
    induction h with
    | refl => exact fun hu => hu
    | @tail b v _ hstep ih =>
        intro hu
        have hb : c b = c i₀ := ih hu
        have hmaxb : ∀ x, c x ≤ c b := fun x => by rw [hb]; exact hmax x
        have hv : c v = c b := blend_le_max_of_arc w c hw hrow hblend hmaxb hstep
        rw [hv, hb]
  have hi : c i = c i₀ := hprop i₀ i (hsc i₀ i) rfl
  have hj : c j = c i₀ := hprop i₀ j (hsc i₀ j) rfl
  rw [hi, hj]

end Novelty.BlendColoringHarmonic