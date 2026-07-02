/-
# Convex Position and Plane Graphs

This file develops a self-contained combinatorial model of **plane graphs on
points in convex position** and proves exponential lower bounds on their number,
together with the arithmetic mechanism that explains why convex position should
*minimize* the number of plane graphs among all n-point configurations in general
position.

## Background

For a set `P` of `n` points in convex position (labeled `0, …, n-1` around the
hull), a *plane graph* is a straight-line graph on `P` whose edges pairwise do not
cross. Since convex position fixes the cyclic order of the points, two chords
`{a,b}` and `{c,d}` cross iff their endpoints strictly interleave, `a < c < b < d`
(or symmetrically). Thus the number of plane graphs on `n` convex points is a
purely combinatorial quantity, `numPlane n`.

This quantity is OEIS **A054726** (`1, 1, 2, 8, 48, 352, …`), which grows like
`≈ 11.6^n`. The guiding conjecture (the topic of this mission) is that convex
position gives the *fewest* plane graphs among all n-point sets in general
position.

## Main results

* `numPlane_ge_of_plane` : from any plane graph `F`, the number of plane graphs is
  at least `2 ^ |F|` (every subset of a plane graph is plane).
* `numPlane_ge_star`     : `2 ^ (n-1) ≤ numPlane n` (star from vertex `0`).
* `numPlane_ge_fan`      : `2 ^ (2n-3) ≤ numPlane n` for `n ≥ 2` (fan triangulation).
* `convex_minimizes_triLB` / `convex_strict` : the triangulation-subset lower
  bound `2^(3n-3-h)` (for a point set with `h` hull points) is minimized exactly
  at `h = n`, i.e. convex position — the arithmetic core of the conjecture.
* `numPlane_ge_convex_triLB` : the convex triangulation bound `triLB n n` is a
  genuine lower bound for `numPlane n`.

## Lab Notes

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Convex position minimizes the number of plane graphs.
A weaker, provable shadow: the number of plane graphs on convex points grows at
least exponentially, and the natural triangulation-based lower bound is smallest
for convex position.

Experiment (Experimenter): We built the chord model, verified `numPlane` against
OEIS A054726 (`numPlane 3 = 8`, `numPlane 4 = 48`, `numPlane 5 = 352`), and proved
exponential lower bounds via fixed plane subgraphs (star, fan). We proved the
monotonicity of the triangulation-subset bound `2^(3n-3-h)` in the hull size `h`.

Analysis (Analyst): The full conjecture is open and out of reach; but the "subsets
of a triangulation are plane" idea gives `numPlane ≥ 2^(edges)`, and Euler's
formula makes the edge count `3n-3-h` decrease with hull size `h`, uniquely
minimized at convex position `h=n`. This is *true and clean* and captures the
mechanism, though the true count (≈11.6^n) far exceeds the `2^(2n-3)≈2.83^n`
bound. Distinguish: (a) the exact minimization is HARD/open; (b) the bound
monotonicity is TRUE and formalized here.

Critique (Critic): Are the theorems vacuous? No — `numPlane` is validated against
A054726 numerically, the lower bounds are strict inequalities proved by explicit
constructions, and the monotonicity is a strict inequality for `h < n`. The fan
bound is tight at `n = 3` (`2^3 = 8 = numPlane 3`), ruling out a definitional
artifact. Corner cases: Nat truncated subtraction is handled by `omega`; `n = 0,1`
are consistent (`numPlane 0 = numPlane 1 = 1`).

Synthesis (PI): We deliver a faithful model, numeric validation against OEIS, two
exponential lower bounds, and the convex-minimizes-the-bound theorem, tying the
combinatorial count to the conjecture's mechanism.
-/
import Mathlib

namespace ConvexPlaneGraphs

open Finset

/-- A chord of the convex `n`-gon: an ordered pair of distinct vertices `i < j`
(the endpoints of a straight-line edge). -/
abbrev Chord (n : ℕ) := {p : Fin n × Fin n // p.1 < p.2}

/-- Two chords **cross** iff their endpoints strictly interleave around the convex
hull: `a < c < b < d` (or the symmetric arrangement). This is exactly the
straight-line crossing condition for points in convex position. -/
def cross {n : ℕ} (x y : Chord n) : Prop :=
  (((x.1.1 : ℕ) < y.1.1) ∧ ((y.1.1 : ℕ) < x.1.2) ∧ ((x.1.2 : ℕ) < y.1.2)) ∨
  (((y.1.1 : ℕ) < x.1.1) ∧ ((x.1.1 : ℕ) < y.1.2) ∧ ((y.1.2 : ℕ) < x.1.2))

instance instDecidableCross {n : ℕ} (x y : Chord n) : Decidable (cross x y) := by
  unfold cross; infer_instance

/-- A **plane graph**: a set of chords that pairwise do not cross. -/
def Plane {n : ℕ} (G : Finset (Chord n)) : Prop := ∀ x ∈ G, ∀ y ∈ G, ¬ cross x y

instance instDecidablePlane {n : ℕ} (G : Finset (Chord n)) : Decidable (Plane G) := by
  unfold Plane; infer_instance

/-- The number of labeled plane graphs on `n` points in convex position. -/
def numPlane (n : ℕ) : ℕ :=
  (Finset.univ.filter (fun G : Finset (Chord n) => Plane G)).card

/-- Sanity checks against OEIS A054726 (`8, 48, 352`). -/
example : numPlane 3 = 8 := by native_decide
example : numPlane 4 = 48 := by native_decide
example : numPlane 5 = 352 := by native_decide

/-- Any subset of a plane graph is plane (crossing depends only on pairs). -/
lemma plane_of_subset {n : ℕ} {F G : Finset (Chord n)} (h : G ⊆ F) (hF : Plane F) :
    Plane G := fun x hx y hy => hF x (h hx) y (h hy)

/-- The powerset of a plane graph lands inside the set of plane graphs. -/
lemma powerset_subset_planeFilter {n : ℕ} {F : Finset (Chord n)} (hF : Plane F) :
    F.powerset ⊆ Finset.univ.filter (fun G : Finset (Chord n) => Plane G) := by
  intro S hS
  rw [mem_powerset] at hS
  rw [mem_filter]
  exact ⟨mem_univ S, plane_of_subset hS hF⟩

/-- **Key lower bound.** From any single plane graph `F`, the number of plane
graphs is at least `2 ^ |F|`, since all `2^{|F|}` subsets of `F` are distinct plane
graphs. -/
theorem numPlane_ge_of_plane {n : ℕ} {F : Finset (Chord n)} (hF : Plane F) :
    2 ^ F.card ≤ numPlane n := by
  have h := Finset.card_le_card (powerset_subset_planeFilter hF)
  rwa [Finset.card_powerset] at h

/-! ### The star from vertex 0 -/

/-- The **star** at vertex `0`: all chords with lower endpoint `0`. -/
def starFan (n : ℕ) : Finset (Chord n) :=
  Finset.univ.filter (fun c : Chord n => (c.1.1 : ℕ) = 0)

/-- The star is a plane graph: any two of its chords share the endpoint `0`, so
they cannot cross. -/
lemma starFan_plane (n : ℕ) : Plane (starFan n) := by
  intro x hx y hy
  rw [starFan, mem_filter] at hx hy
  obtain ⟨_, hx0⟩ := hx
  obtain ⟨_, hy0⟩ := hy
  unfold cross
  omega

/-
The star at vertex `0` has `n - 1` chords.
-/
lemma starFan_card (n : ℕ) : (starFan n).card = n - 1 := by
  convert Finset.card_range ( n - 1 ) using 1;
  refine' Finset.card_bij ( fun x hx => x.1.2 - 1 ) _ _ _ <;> simp +decide [ starFan ];
  · grind;
  · grind;
  · exact fun b hb => ⟨ ⟨ 0, by omega ⟩, rfl, ⟨ ⟨ b + 1, by omega ⟩, by simp +decide, by simp +decide ⟩ ⟩

/-- The number of plane graphs on `n` convex points is at least `2 ^ (n-1)`. -/
theorem numPlane_ge_star (n : ℕ) : 2 ^ (n - 1) ≤ numPlane n := by
  rw [← starFan_card n]
  exact numPlane_ge_of_plane (starFan_plane n)

/-! ### The fan triangulation -/

/-- The **fan** triangulation from vertex `0`: all chords touching `0` together
with all boundary edges `{k, k+1}`. -/
def fan (n : ℕ) : Finset (Chord n) :=
  Finset.univ.filter
    (fun c : Chord n => (c.1.1 : ℕ) = 0 ∨ (c.1.2 : ℕ) = (c.1.1 : ℕ) + 1)

/-- The fan is a plane graph: chords through `0` never cross each other, boundary
edges `{k,k+1}` leave no room for an interleaving endpoint, and the two families
do not cross either. -/
lemma fan_plane (n : ℕ) : Plane (fan n) := by
  intro x hx y hy
  rw [fan, mem_filter] at hx hy
  obtain ⟨_, hx'⟩ := hx
  obtain ⟨_, hy'⟩ := hy
  unfold cross
  omega

/-
The fan triangulation of the convex `n`-gon has `2n - 3` edges.
-/
lemma fan_card (n : ℕ) (hn : 2 ≤ n) : (fan n).card = 2 * n - 3 := by
  convert Finset.card_eq_sum_ones ( Finset.univ.filter ( fun c : Chord n => ( c.1.1 : ℕ ) = 0 ∨ ( c.1.2 : ℕ ) = ( c.1.1 : ℕ ) + 1 ) ) using 1;
  convert Finset.card_eq_sum_ones ( Finset.filter ( fun c : Fin n × Fin n => c.1.val = 0 ∨ c.2.val = c.1.val + 1 ) ( Finset.univ.filter ( fun c : Fin n × Fin n => c.1 < c.2 ) ) ) |> Eq.symm using 1;
  · rcases n with ( _ | _ | n ) <;> simp_all +arith +decide;
    rw [ show ( Finset.filter ( fun c : Fin ( n + 2 ) × Fin ( n + 2 ) => c.1 = 0 ∨ ( c.2 : ℕ ) = c.1 + 1 ) ( Finset.filter ( fun c : Fin ( n + 2 ) × Fin ( n + 2 ) => c.1 < c.2 ) Finset.univ ) ) = Finset.image ( fun i : Fin ( n + 1 ) => ( 0, Fin.succ i ) ) Finset.univ ∪ Finset.image ( fun i : Fin n => ( Fin.succ ( Fin.castSucc i ), Fin.succ ( Fin.succ i ) ) ) Finset.univ from ?_ ];
    · rw [ Finset.card_union_of_disjoint ] <;> norm_num [ Finset.card_image_of_injective, Function.Injective ] ; ring;
      norm_num [ Finset.disjoint_left ];
    · ext ⟨i, j⟩; simp [Finset.mem_union, Finset.mem_image];
      rcases i with ⟨ _ | i, hi ⟩ <;> rcases j with ⟨ _ | j, hj ⟩ <;> norm_num [ Fin.ext_iff ];
      · exact Nat.succ_pos _;
      · exact ⟨ fun h => ⟨ ⟨ i, by linarith ⟩, rfl, by linarith ⟩, by rintro ⟨ a, rfl, rfl ⟩ ; exact ⟨ by linarith, rfl ⟩ ⟩;
  · rw [ Finset.card_eq_sum_ones ];
    refine' Finset.sum_bij ( fun x hx => x.val ) _ _ _ _ <;> aesop

/-- **Fan lower bound.** For `n ≥ 2`, the number of plane graphs on `n` convex
points is at least `2 ^ (2n - 3)`. -/
theorem numPlane_ge_fan (n : ℕ) (hn : 2 ≤ n) : 2 ^ (2 * n - 3) ≤ numPlane n := by
  rw [← fan_card n hn]
  exact numPlane_ge_of_plane (fan_plane n)

/-! ### Convex position minimizes the triangulation-subset lower bound

A triangulation of a set of `n` points with `h` of them on the convex hull has
`3n - 3 - h` edges (Euler's formula). Every subset of its edge set is a plane
graph, so any such point set has at least `2^(3n-3-h)` plane graphs. This lower
bound is *decreasing* in the hull size `h`, hence minimized exactly at `h = n`,
i.e. at convex position — the arithmetic mechanism behind the conjecture. -/

/-- The triangulation-subset lower bound for an `n`-point set with `h` hull points. -/
def triLB (n h : ℕ) : ℕ := 2 ^ (3 * n - 3 - h)

/-- Convex position (`h = n`) minimizes the triangulation-subset lower bound. -/
theorem convex_minimizes_triLB (n h : ℕ) (h3 : 3 ≤ h) (hn : h ≤ n) :
    triLB n n ≤ triLB n h := by
  unfold triLB
  apply Nat.pow_le_pow_right (by norm_num)
  omega

/-- The minimization is strict whenever the hull is smaller than the whole set. -/
theorem convex_strict (n h : ℕ) (h3 : 3 ≤ h) (hn : h < n) :
    triLB n n < triLB n h := by
  unfold triLB
  apply Nat.pow_lt_pow_right (by norm_num)
  omega

/-- At convex position the bound equals the fan bound `2^(2n-3)`. -/
theorem triLB_convex_eq (n : ℕ) (hn : 2 ≤ n) : triLB n n = 2 ^ (2 * n - 3) := by
  unfold triLB
  congr 1
  omega

/-- **Bridge.** The convex triangulation lower bound is a genuine lower bound for
the actual number of plane graphs on `n` convex points. -/
theorem numPlane_ge_convex_triLB (n : ℕ) (hn : 2 ≤ n) : triLB n n ≤ numPlane n := by
  rw [triLB_convex_eq n hn]
  exact numPlane_ge_fan n hn

/-! ### Parity of the plane-graph count

The boundary chord `{0,1}` joins two consecutive hull vertices, so no chord can
interleave its endpoints: it crosses nothing. Toggling it is therefore a
fixed-point-free involution on the set of plane graphs, forcing `numPlane n` to be
**even** for `n ≥ 2`.

-- !-- Lab Notes -- !--
Hypothesis: the counts `8, 48, 352` are all even — is `numPlane n` always even for
`n ≥ 2`? Experiment: toggling the universally non-crossing boundary edge `{0,1}`
is a fixed-point-free involution on plane graphs. Analysis: parity is robust in
`n` and reflects that every hull edge is crossing-free, an independent binary
degree of freedom consistent with the `2^(2n-3)` bound. Critique: not vacuous —
`numPlane 1 = 1` is odd, so `n ≥ 2` is necessary; the proof is a genuine involution,
not `decide`. Synthesis: a clean `2`-divisibility invariant of the convex count.
-/

/-- The boundary chord `{0,1}` of the convex `n`-gon (needs `n ≥ 2`). -/
def edge01 (n : ℕ) (hn : 2 ≤ n) : Chord n :=
  ⟨(⟨0, by omega⟩, ⟨1, by omega⟩), by simp [Fin.lt_def]⟩

/-- The boundary chord `{0,1}` crosses no chord on the left: its endpoints are
consecutive, so nothing can interleave them. -/
lemma not_cross_edge01_left (n : ℕ) (hn : 2 ≤ n) (y : Chord n) :
    ¬ cross (edge01 n hn) y := by
  unfold cross edge01
  simp only
  omega

/-- The boundary chord `{0,1}` crosses no chord on the right. -/
lemma not_cross_edge01_right (n : ℕ) (hn : 2 ≤ n) (y : Chord n) :
    ¬ cross y (edge01 n hn) := by
  unfold cross edge01
  simp only
  omega

/-- Toggling the boundary edge `{0,1}` preserves planarity. -/
lemma plane_symmDiff_edge01 {n : ℕ} (hn : 2 ≤ n) {G : Finset (Chord n)}
    (hG : Plane G) : Plane (symmDiff G {edge01 n hn}) := by
  intro x hx y hy
  rw [Finset.mem_symmDiff] at hx hy
  have hx' : x ∈ G ∨ x = edge01 n hn := by
    rcases hx with ⟨h, _⟩ | ⟨h, _⟩
    · exact Or.inl h
    · exact Or.inr (Finset.mem_singleton.mp h)
  have hy' : y ∈ G ∨ y = edge01 n hn := by
    rcases hy with ⟨h, _⟩ | ⟨h, _⟩
    · exact Or.inl h
    · exact Or.inr (Finset.mem_singleton.mp h)
  rcases hx' with hxG | hxe <;> rcases hy' with hyG | hye
  · exact hG x hxG y hyG
  · subst hye; exact not_cross_edge01_right n hn x
  · subst hxe; exact not_cross_edge01_left n hn y
  · subst hxe; subst hye; exact not_cross_edge01_left n hn _

/-
**Parity theorem.** For `n ≥ 2`, the number of plane graphs on `n` points in
convex position is even.
-/
theorem even_numPlane (n : ℕ) (hn : 2 ≤ n) : Even (numPlane n) := by
  unfold numPlane;
  -- Let `u := edge01 n hn` and `S := Finset.univ.filter (fun G : Finset (Chord n) => Plane G)`, so `numPlane n = S.card` (by `unfold numPlane`).
  set u : Chord n := edge01 n hn
  set S : Finset (Finset (Chord n)) := Finset.univ.filter (fun G => Plane G);
  -- Partition `S` by whether `u ∈ G`. Let `A := S.filter (fun G => u ∉ G)` and `B := S.filter (fun G => u ∈ G)`.
  set A := S.filter (fun G => u ∉ G)
  set B := S.filter (fun G => u ∈ G);
  -- Show `A.card = B.card` via `Finset.card_bij'` with forward map `fun G _ => insert u G` and inverse `fun H _ => H.erase u`.
  have h_card_eq : A.card = B.card := by
    refine' Finset.card_bij ( fun G hG => G ∪ { u } ) _ _ _;
    · simp +zetaDelta at *;
      intro G hG hu; convert plane_symmDiff_edge01 hn hG using 1; ext; simp +decide [ Finset.mem_symmDiff, Finset.mem_insert ] ;
      grind +qlia;
    · simp +contextual [ Finset.ext_iff ];
      grind;
    · simp +zetaDelta at *;
      exact fun G hG hu => ⟨ G.erase u, ⟨ plane_of_subset ( Finset.erase_subset _ _ ) hG, by aesop ⟩, by aesop ⟩;
  rw [ show S = A ∪ B by ext; by_cases h : u ∈ ‹Finset ( Chord n ) › <;> aesop, Finset.card_union_of_disjoint ] <;> norm_num [ h_card_eq ];
  exact Finset.disjoint_filter.mpr fun _ _ _ _ => by tauto;

/-- The parity fact, phrased as `2 ∣ numPlane n`. -/
theorem two_dvd_numPlane (n : ℕ) (hn : 2 ≤ n) : 2 ∣ numPlane n :=
  (even_numPlane n hn).two_dvd

end ConvexPlaneGraphs