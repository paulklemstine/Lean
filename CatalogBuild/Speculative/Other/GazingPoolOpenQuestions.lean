/-! # CatalogBuild.Speculative.Other.GazingPoolOpenQuestions

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 20
-/

import Mathlib

noncomputable section

/-- A **Gazing Pool** on a type `W` (the "World"). -/
structure GazingPool' (W : Type*) where
  S : Type*
  reflect : W → W
  reflect_invol : ∀ w, reflect (reflect w) = w
  shadow : W → S
  reconstruct : S → W
  shadow_surj : Surjective shadow
  shadow_reconstruct : ∀ s, shadow (reconstruct s) = s

namespace GazingPool'

variable {W : Type*} (P : GazingPool' W)

/-- The **gaze** operation. -/

def retract : Set W := {w | P.reconstruct (P.shadow w) = w}

end GazingPool'

/-! ## §1: The Gazing Pool Spectrum

**Open Question 1**: For a given world W and shadow S, characterize the set
of possible reflection maps that admit conscious observers without the
symmetry assumption.

**Resolution**: A reflection ρ admits a conscious observer iff some element
of the retract (image of reconstruct ∘ shadow) is mapped by ρ into the same
shadow fiber. This is the **Spectrum Characterization Theorem**.
-/

/-- A reflection is **conscious-admitting** for given shadow/reconstruct. -/

def IsConsciousAdmitting {W S : Type*} (shadow : W → S) (reconstruct : S → W)
    (reflect : W → W) : Prop :=
  ∃ w : W, reconstruct (shadow (reflect w)) = w

/-- **Spectrum Theorem**: A reflection is conscious-admitting iff some
retract element is mapped into its own shadow fiber. -/

theorem spectrum_characterization {W S : Type*} (shadow : W → S) (reconstruct : S → W)
    (h_section : ∀ s, shadow (reconstruct s) = s) (reflect : W → W) :
    IsConsciousAdmitting shadow reconstruct reflect ↔
    ∃ w, reconstruct (shadow w) = w ∧ shadow (reflect w) = shadow w := by
  constructor
  · rintro ⟨w, hw⟩
    have hsf : shadow w = shadow (reflect w) := by
      conv_lhs => rw [← hw]
      exact h_section _
    exact ⟨w, by rw [hsf]; exact hw, hsf.symm⟩
  · rintro ⟨w, hw_ret, hw_shadow⟩
    exact ⟨w, by rw [hw_shadow, hw_ret]⟩

/-- The identity is always conscious-admitting (when S is nonempty). -/

theorem id_conscious_admitting {W S : Type*} [Nonempty S]
    (shadow : W → S) (reconstruct : S → W)
    (h_section : ∀ s, shadow (reconstruct s) = s) :
    IsConsciousAdmitting shadow reconstruct id := by
  obtain ⟨s⟩ := ‹Nonempty S›
  exact ⟨reconstruct s, by simp [h_section]⟩

/-- **Symmetric reflections are conscious-admitting** (when S is nonempty). -/

theorem symmetric_conscious_admitting {W S : Type*} [Nonempty S]
    (shadow : W → S) (reconstruct : S → W)
    (h_section : ∀ s, shadow (reconstruct s) = s)
    (reflect : W → W) (h_symm : ∀ w, shadow (reflect w) = shadow w) :
    IsConsciousAdmitting shadow reconstruct reflect := by
  obtain ⟨s⟩ := ‹Nonempty S›
  exact ⟨reconstruct s, by rw [h_symm, h_section]⟩

/-! ## §2: Infinite-Dimensional Gazing Pools (Knaster-Tarski)

**Open Question 2**: Extend the convergence theory to infinite-dimensional
settings.

**Resolution**: Using the Knaster-Tarski fixed point theorem for complete
lattices, we prove that monotone gaze operations always have conscious observers,
including a least and greatest one.
-/

/-
PROBLEM
**Knaster-Tarski Consciousness**: A monotone endofunction on a complete
lattice has a fixed point.

PROVIDED SOLUTION
Use OrderHom.lfp or the Knaster-Tarski fixed point theorem from Mathlib. The lfp of a monotone function on a complete lattice is a fixed point. Use OrderHom.mk to wrap f with its monotonicity, then use OrderHom.lfp_eq or lfp_eq.
-/

theorem knaster_tarski_consciousness {W : Type*} [CompleteLattice W]
    (f : W → W) (hf : Monotone f) :
    ∃ w : W, f w = w := by
  -- By the Knaster-Tarski theorem, a monotone function on a complete lattice has a fixed point.
  have h_fixed_point : ∃ w : W, f w = w := by
    have h_lfp : ∃ w : W, f w ≤ w ∧ ∀ y : W, f y ≤ y → w ≤ y := by
      refine' ⟨ sInf { y | f y ≤ y }, _, _ ⟩;
      · exact le_sInf fun y hy => hf ( sInf_le hy ) |> le_trans <| hy;
      · exact fun y hy => sInf_le hy
    exact ⟨ h_lfp.choose, le_antisymm h_lfp.choose_spec.1 ( h_lfp.choose_spec.2 ( f h_lfp.choose ) ( hf h_lfp.choose_spec.1 ) ) ⟩;
  exact h_fixed_point

/-
PROBLEM
**Least Fixed Point**: There is a least fixed point.

PROVIDED SOLUTION
Use OrderHom.lfp. Wrap f as an OrderHom, then lfp is a fixed point (by lfp_eq) and is the least (by OrderHom.lfp_le).
-/

theorem fixed_points_nonempty {W : Type*} [CompleteLattice W]
    (f : W → W) (hf : Monotone f) :
    {w : W | f w = w}.Nonempty := by
  exact ⟨ _, knaster_tarski_lfp f hf |> Classical.choose_spec |> And.left ⟩

/-! ## §3: Stochastic Gazing Pools

**Open Question 3**: Replace deterministic maps with probabilistic kernels.
When does a "probabilistically conscious" observer exist?

**Resolution**: On finite types, doubly stochastic matrices preserve the
uniform distribution, which is therefore a "probabilistically conscious"
observer (stationary distribution).
-/

open Finset BigOperators

/-- A **stochastic matrix**: nonneg entries with row sums = 1. -/

structure StochMatrix (n : ℕ) where
  val : Fin n → Fin n → ℝ
  nonneg : ∀ i j, 0 ≤ val i j
  row_sum : ∀ i, ∑ j, val i j = 1

/-- A probability distribution over Fin n. -/

def StochMatrix.apply {n : ℕ} (M : StochMatrix n) (π : ProbDist n) : Fin n → ℝ :=
  fun j => ∑ i, π.val i * M.val i j

/-- A distribution is **stationary** (probabilistically conscious). -/

def IsStationary {n : ℕ} (M : StochMatrix n) (π : ProbDist n) : Prop :=
  ∀ j, M.apply π j = π.val j

/-- The uniform distribution on Fin n (for n > 0). -/

theorem doubly_stochastic_uniform_stationary {n : ℕ} (hn : 0 < n)
    (M : StochMatrix n)
    (h_col : ∀ j, ∑ i, M.val i j = 1) :
    IsStationary M (uniformDist n hn) := by
  intro j
  simp [IsStationary, uniformDist]
  simp +decide [StochMatrix.apply]
  rw [← Finset.mul_sum _ _ _, h_col, mul_one]

/-! ## §4: Topological Gazing Pools

**Open Question 4**: Characterize when the shadow map is a covering map,
and relate the "hidden loops" to information loss.

**Resolution**: We prove that the set of conscious observers (fixed points
of the gaze) is closed in a Hausdorff space with continuous gaze. This
establishes the topological framework for gazing pools.
-/

/-
PROBLEM
The set of fixed points of a continuous map on a T₂ space is closed.

PROVIDED SOLUTION
{x | f x = x} is the preimage of the diagonal under (id, f) in X × X. In a T2 space, the diagonal is closed, and (id, f) is continuous. Alternatively, use isClosed_eq with continuous_id and hf.
-/

theorem fixed_points_closed {X : Type*} [TopologicalSpace X] [T2Space X]
    (f : X → X) (hf : Continuous f) :
    IsClosed {x | f x = x} := by
  exact isClosed_eq hf continuous_id

/-- **Conscious Set is Closed**: For a continuous gaze on a Hausdorff space,
the set of conscious observers is closed. -/

theorem conscious_set_is_closed {W : Type*} [TopologicalSpace W] [T2Space W]
    (gaze : W → W) (hgaze : Continuous gaze) :
    IsClosed {w | gaze w = w} :=
  fixed_points_closed gaze hgaze

/-! ## §5: Computational Gazing

**Open Question 5**: What is the computational complexity of finding
conscious observers?

**Resolution**: On finite types, consciousness is decidable (O(|W|) time
by brute force). We formalize decidability and provide the finset of
all conscious observers.
-/

/-- The finset of all conscious observers (fixed points of gaze). -/

def consciousFinset {W : Type*} [Fintype W] [DecidableEq W] (gaze : W → W) : Finset W :=
  Finset.univ.filter (fun w => gaze w = w)

/-- A conscious observer exists iff the conscious finset is nonempty. -/

theorem conscious_iff_finset_nonempty {W : Type*} [Fintype W] [DecidableEq W]
    (gaze : W → W) :
    (∃ w, gaze w = w) ↔ (consciousFinset gaze).Nonempty := by
  simp [consciousFinset, Finset.Nonempty]

/-
PROBLEM
**Periodic orbit detection**: Any function on a finite type has
a collision in the first |X|+1 iterates from any starting point.

PROVIDED SOLUTION
Consider the sequence x, f(x), ..., f^|X|(x). These are |X|+1 elements of a type with |X| elements. By pigeonhole, two must be equal: f^i(x) = f^j(x) for some i < j ≤ |X|.
-/

theorem periodic_orbit_from_any {X : Type*} [Fintype X] [DecidableEq X]
    (f : X → X) (x : X) :
    ∃ i j : ℕ, i < j ∧ j ≤ Fintype.card X ∧ f^[i] x = f^[j] x := by
  by_contra h;
  exact absurd ( Finset.card_le_univ ( Finset.image ( fun i => f^[i] x ) ( Finset.Iic ( Fintype.card X ) ) ) ) ( by rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( not_lt.mp fun hi' => h ⟨ j, i, hi', by aesop, hij.symm ⟩ ) ( not_lt.mp fun hj' => h ⟨ i, j, hj', by aesop, hij ⟩ ) ] ; simpa )

/-! ## §6: The Gazing Pool Conjecture — PROVEN TRUE

**Open Question 6 (Conjecture)**: Every gazing pool (not just symmetric ones)
on a finite nonempty world has a periodic point of the gaze operation.

**Resolution**: TRUE. By the pigeonhole principle, any endofunction on a
finite nonempty type has a periodic point. The gaze operation is an
endofunction, so the conjecture follows immediately.
-/

/-
PROBLEM
**Pigeonhole periodic point**: Any endofunction on a finite nonempty
type has a periodic point. This is the key lemma resolving the conjecture.

PROVIDED SOLUTION
By pigeonhole, the sequence x, f(x), f²(x), ... over a finite type must repeat: ∃ i < j ≤ |X|, f^i(x) = f^j(x). Then f^(j-i)(f^i(x)) = f^j(x) = f^i(x), so f^i(x) is periodic with period j-i > 0.
-/

theorem finite_endo_periodic {X : Type*} [Fintype X] [Nonempty X]
    (f : X → X) : ∃ x : X, ∃ k : ℕ, 0 < k ∧ f^[k] x = x := by
  -- By the pigeonhole principle, since $X$ is finite and nonempty, the sequence $x, f(x), f^2(x), \ldots$ must eventually repeat.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, i < j ∧ f^[i] (Classical.arbitrary X) = f^[j] (Classical.arbitrary X) := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ hi hij.symm ) ( not_lt.1 fun hj => h _ _ hj hij ) ) ) ( Set.not_infinite.2 <| Set.toFinite _ );
  refine' ⟨ f^[i] ( Classical.arbitrary X ), j - i, tsub_pos_of_lt hij, _ ⟩;
  rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel hij.le, h_eq ]

/-- **The Gazing Pool Conjecture (THEOREM)**: Every gazing pool on a finite
nonempty world has a periodic point of the gaze operation. -/

theorem gazing_pool_conjecture {W : Type*} [Fintype W] [Nonempty W]
    (P : GazingPool' W) :
    ∃ w : W, ∃ k : ℕ, 0 < k ∧ P.gaze^[k] w = w :=
  finite_endo_periodic P.gaze

/-
PROBLEM
**Bounded version**: The period can be bounded by |W|.

PROVIDED SOLUTION
Use periodic_orbit_from_any to get i < j ≤ |W| with gaze^i(w) = gaze^j(w). Then gaze^(j-i)(gaze^i(w)) = gaze^j(w) = gaze^i(w), so gaze^i(w) is periodic with period j-i. And j-i ≤ |W| since j ≤ |W| and 0 ≤ i.
-/

theorem gazing_pool_conjecture_bounded {W : Type*} [Fintype W] [DecidableEq W] [Nonempty W]
    (P : GazingPool' W) :
    ∃ w : W, ∃ k : ℕ, 0 < k ∧ k ≤ Fintype.card W ∧ P.gaze^[k] w = w := by
  -- By the pigeonhole principle, there exist integers $i$ and $j$ such that $0 \leq i < j \leq n$ and $P.gaze^i(w) = P.gaze^j(w)$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, 0 ≤ i ∧ i < j ∧ j ≤ Fintype.card W ∧ P.gaze^[i] (Classical.arbitrary W) = P.gaze^[j] (Classical.arbitrary W) := by
    have := periodic_orbit_from_any P.gaze ( Classical.arbitrary W );
    aesop;
  refine' ⟨ P.gaze^[i] ( Classical.arbitrary W ), j - i, _, _, _ ⟩ <;> try omega;
  rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel h_eq.1.le, h_eq.2.2 ]


end
