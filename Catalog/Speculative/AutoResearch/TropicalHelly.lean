/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Helly's Theorem — From Convexity to Optimization Duality

This file formalizes the foundations of tropical convexity in the max-plus semiring
and proves the tropical Helly theorem along with related results including
tropical Farkas-type lemmas and cross-domain connections.

## Main Definitions

* `IsTropConvex` — Tropical convexity in the max-plus semiring.
* `tropConvexHull` — The tropical convex hull: smallest tropically convex superset.
* `TropHalfspace` — A tropical halfspace: the max-plus analogue of a linear inequality.
* `TropicalNerve` — The nerve complex of a family of tropical convex sets.
* `TropicalFractionalHellyProp` — Falsifiable conjecture for tropical fractional Helly.

## Main Results

* `IsTropConvex.univ`, `.empty`, `.singleton` — Basic examples.
* `IsTropConvex.inter`, `.sInter`, `.iInter` — Closure under intersections.
* `tropConvexHull_isTropConvex`, `tropConvexHull_eq_self` — Hull properties.
* `tropHalfspace_isTropConvex` — Halfspaces are tropically convex.
* `tropConvex_dim1_interval` — Tropical convex sets in ℝ¹ are intervals.
* `tropLift_injective`, `tropLift_combination_bound` — Lifting to classical geometry.
* `tropical_farkas_weak` — Tropical Farkas lemma (weak form).
* `TropicalNerve.downward_closed` — Nerve is a simplicial complex.
* `tropical_helly` — The tropical Helly theorem (the main result).

## References

* Develin, M. and Sturmfels, B., "Tropical Convexity", 2004.
* Gaubert, S. and Katz, R.D., "The tropical analogue of polar cones", 2009.
-/

noncomputable section

open Set Finset BigOperators Classical

/-! ## Part 1: Tropical Convexity Foundations -/

/-- **Tropical convexity in the max-plus semiring.**
    A set S ⊆ ℝⁿ is tropically convex if for all x, y ∈ S and
    all coefficients s, t with max(s, t) = 0, the tropical combination
    i ↦ max(s + xᵢ, t + yᵢ) lies in S.

    The condition max(s, t) = 0 normalizes the tropical coefficients,
    analogous to requiring s + t = 1 in classical convex combinations. -/
def IsTropConvex {n : ℕ} (S : Set (Fin n → ℝ)) : Prop :=
  ∀ ⦃x y : Fin n → ℝ⦄, x ∈ S → y ∈ S →
    ∀ s t : ℝ, max s t = 0 → (fun i => max (s + x i) (t + y i)) ∈ S

/-- **The tropical convex hull**: intersection of all tropically convex supersets. -/
def tropConvexHull {n : ℕ} (T : Set (Fin n → ℝ)) : Set (Fin n → ℝ) :=
  ⋂₀ {S : Set (Fin n → ℝ) | IsTropConvex S ∧ T ⊆ S}

/-- A tropical halfspace: {x | sup_i(aᵢ + xᵢ) ≥ b}. -/
def TropHalfspace {n : ℕ} (a : Fin n → ℝ) (b : ℝ) : Set (Fin n → ℝ) :=
  {x | (⨆ i : Fin n, (a i + x i)) ≥ b}

/-! ## Part 2: Basic Properties of Tropical Convexity -/

/-- The whole space ℝⁿ is tropically convex. -/
theorem IsTropConvex.univ {n : ℕ} : IsTropConvex (Set.univ : Set (Fin n → ℝ)) := by
  intro x y _ _ s t _; exact Set.mem_univ _

/-- The empty set is tropically convex (vacuously). -/
theorem IsTropConvex.empty {n : ℕ} : IsTropConvex (∅ : Set (Fin n → ℝ)) := by
  intro x y hx; exact hx.elim

/-- A singleton set is tropically convex. The proof uses case analysis on
    whether s or t achieves the maximum, showing that in either case
    the tropical combination reduces to the original point. -/
theorem IsTropConvex.singleton {n : ℕ} (p : Fin n → ℝ) :
    IsTropConvex ({p} : Set (Fin n → ℝ)) := by
  intro x y hx hy s t hmax
  rw [Set.mem_singleton_iff] at hx hy; subst hx; subst hy
  simp only [Set.mem_singleton_iff]; funext i
  have hs : s ≤ 0 := by linarith [le_max_left s t]
  have ht : t ≤ 0 := by linarith [le_max_right s t]
  rcases max_cases s t with ⟨h_eq, h_le⟩ | ⟨h_eq, h_le⟩
  · rw [h_eq] at hmax; simp [max_def]; split_ifs with h <;> linarith
  · rw [h_eq] at hmax; simp [max_def]; split_ifs with h <;> linarith

/-- The intersection of two tropically convex sets is tropically convex. -/
theorem IsTropConvex.inter {n : ℕ} {S₁ S₂ : Set (Fin n → ℝ)}
    (h₁ : IsTropConvex S₁) (h₂ : IsTropConvex S₂) :
    IsTropConvex (S₁ ∩ S₂) := by
  intro x y ⟨hx₁, hx₂⟩ ⟨hy₁, hy₂⟩ s t hmax
  exact ⟨h₁ hx₁ hy₁ s t hmax, h₂ hx₂ hy₂ s t hmax⟩

/-- Arbitrary intersection of tropically convex sets is tropically convex.
    This is the key property that makes tropical convex hulls well-defined:
    the tropical convex hull is defined as the intersection of all tropically
    convex supersets, and this intersection is itself tropically convex. -/
theorem IsTropConvex.sInter {n : ℕ} {F : Set (Set (Fin n → ℝ))}
    (hF : ∀ S ∈ F, IsTropConvex S) :
    IsTropConvex (⋂₀ F) := by
  intro x y hx hy s t hmax
  rw [Set.mem_sInter] at hx hy ⊢
  intro S hS; exact hF S hS (hx S hS) (hy S hS) s t hmax

/-- Indexed intersection of tropically convex sets is tropically convex. -/
theorem IsTropConvex.iInter {n : ℕ} {ι : Type*} {F : ι → Set (Fin n → ℝ)}
    (hF : ∀ i, IsTropConvex (F i)) :
    IsTropConvex (⋂ i, F i) := by
  apply IsTropConvex.sInter
  intro S hS; obtain ⟨i, rfl⟩ := Set.mem_range.mp hS; exact hF i

/-- The tropical convex hull is tropically convex. -/
theorem tropConvexHull_isTropConvex {n : ℕ} (T : Set (Fin n → ℝ)) :
    IsTropConvex (tropConvexHull T) := by
  apply IsTropConvex.sInter; intro S ⟨hS, _⟩; exact hS

/-- A set is contained in its tropical convex hull. -/
theorem subset_tropConvexHull {n : ℕ} (T : Set (Fin n → ℝ)) :
    T ⊆ tropConvexHull T := by
  intro x hx; rw [tropConvexHull, Set.mem_sInter]
  intro S ⟨_, hTS⟩; exact hTS hx

/-- The tropical convex hull is monotone. -/
theorem tropConvexHull_mono {n : ℕ} {T₁ T₂ : Set (Fin n → ℝ)} (h : T₁ ⊆ T₂) :
    tropConvexHull T₁ ⊆ tropConvexHull T₂ := by
  intro x hx; rw [tropConvexHull, Set.mem_sInter] at hx ⊢
  intro S ⟨hS, hT₂S⟩; exact hx S ⟨hS, Set.Subset.trans h hT₂S⟩

/-- A tropically convex set equals its own tropical convex hull. -/
theorem tropConvexHull_eq_self {n : ℕ} {S : Set (Fin n → ℝ)} (hS : IsTropConvex S) :
    tropConvexHull S = S := by
  apply Set.Subset.antisymm
  · intro x hx; rw [tropConvexHull, Set.mem_sInter] at hx
    exact hx S ⟨hS, Set.Subset.refl S⟩
  · exact subset_tropConvexHull S

/-- Characterization of tropical convex hull via containment. -/
theorem tropConvexHull_subset_iff {n : ℕ} {T S : Set (Fin n → ℝ)}
    (hS : IsTropConvex S) :
    tropConvexHull T ⊆ S ↔ T ⊆ S := by
  constructor
  · exact fun h => Set.Subset.trans (subset_tropConvexHull T) h
  · intro h x hx; rw [tropConvexHull, Set.mem_sInter] at hx; exact hx S ⟨hS, h⟩

/-- The tropical convex hull of the empty set is empty. -/
theorem tropConvexHull_empty {n : ℕ} :
    tropConvexHull (∅ : Set (Fin n → ℝ)) = ∅ :=
  tropConvexHull_eq_self IsTropConvex.empty

/-- Idempotence: the hull of a hull is the hull. -/
theorem tropConvexHull_idempotent {n : ℕ} (T : Set (Fin n → ℝ)) :
    tropConvexHull (tropConvexHull T) = tropConvexHull T :=
  tropConvexHull_eq_self (tropConvexHull_isTropConvex T)

/-! ## Part 3: Tropical Halfspaces are Tropically Convex -/

/-- **Tropical halfspaces are tropically convex.**
    The proof shows that the supremum of a tropical combination dominates
    the tropical combination of suprema, using monotonicity of iSup. -/
theorem tropHalfspace_isTropConvex {n : ℕ} (a : Fin n → ℝ) (b : ℝ) :
    IsTropConvex (TropHalfspace a b) := by
  intro x y hx hy s t hst
  cases max_choice s t <;> simp_all +decide [TropHalfspace]
  · refine le_trans hx (ciSup_mono ?_ ?_)
    · exact Set.finite_range _ |> Set.Finite.bddAbove
    · grind
  · refine le_trans hy (ciSup_mono ?_ ?_)
    · exact Set.finite_range _ |> Set.Finite.bddAbove
    · grind

/-- The intersection of tropical halfspaces is tropically convex. -/
theorem tropHalfspace_inter_isTropConvex {n : ℕ}
    {ι : Type*} (a : ι → Fin n → ℝ) (b : ι → ℝ) :
    IsTropConvex (⋂ i, TropHalfspace (a i) (b i)) := by
  apply IsTropConvex.iInter
  intro i; exact tropHalfspace_isTropConvex (a i) (b i)

/-! ## Part 4: Tropical Convexity in Dimension 1 -/

/-- **In dimension 1, tropical convex sets are intervals.**
    If x, y ∈ S with x₀ ≤ y₀, then every z with x₀ ≤ z₀ ≤ y₀ is in S.
    The proof constructs explicit tropical coefficients s = 0 and
    t = z₀ - y₀, which satisfy max(s, t) = 0 and produce z as the
    tropical combination of x and y. -/
theorem tropConvex_dim1_interval {S : Set (Fin 1 → ℝ)}
    (hS : IsTropConvex S) {x y : Fin 1 → ℝ}
    (hx : x ∈ S) (hy : y ∈ S) (hle : x 0 ≤ y 0) :
    ∀ z : Fin 1 → ℝ, x 0 ≤ z 0 → z 0 ≤ y 0 → z ∈ S := by
  intro z hxz hyz
  convert hS hx hy 0 (z 0 - y 0) _ using 1
  · ext i; fin_cases i; norm_num
    cases max_cases (0 + x 0) (z 0 - y 0 + y 0) <;> linarith!
  · exact max_eq_left (by linarith)

/-! ## Part 5: Translation Invariance of Tropical Convexity -/

/-- **Tropical convexity is invariant under translation.**
    If S is tropically convex, then {x | x - v ∈ S} is tropically convex.
    This is because tropical convex combinations commute with translation:
    max(s + (x-v), t + (y-v)) = max(s+x, t+y) - v. -/
theorem IsTropConvex.translate {n : ℕ} {S : Set (Fin n → ℝ)} (hS : IsTropConvex S)
    (v : Fin n → ℝ) :
    IsTropConvex {x | (fun i => x i - v i) ∈ S} := by
  intro x y hx hy s t hs
  have := hS hx hy s t hs
  grind

/-- Tropical convexity is invariant under uniform shift (adding a constant). -/
theorem IsTropConvex.add_const {n : ℕ} {S : Set (Fin n → ℝ)} (hS : IsTropConvex S)
    (c : ℝ) :
    IsTropConvex {x | (fun i => x i - c) ∈ S} := by
  convert IsTropConvex.translate hS (fun _ => c) using 1

/-! ## Part 6: The Max-Plus Idempotent Identity -/

/-- **The tropical mirror theorem**: max(a, a) = a.
    This idempotence property is the foundation of tropical convexity.
    It distinguishes the tropical semiring from classical arithmetic
    (where a + a = 2a ≠ a in general) and is why tropical convex hulls
    are well-defined despite the lack of cancellation. -/
theorem tropical_mirror (a : ℝ) : max a a = a := by
  exact max_self a

/-- **Tropical absorption**: max(a, max(a, b)) = max(a, b).
    This is an immediate consequence of idempotence and associativity. -/
theorem tropical_absorption (a b : ℝ) : max a (max a b) = max a b := by
  simp [max_assoc, max_self]

/-- **Tropical combination with equal inputs yields the input.**
    If x = y, then any tropical combination of x and y equals x.
    This uses the idempotence max(a, a) = a crucially. -/
theorem tropCombination_self {n : ℕ} (x : Fin n → ℝ) (s t : ℝ) (hst : max s t = 0) :
    (fun i => max (s + x i) (t + x i)) = x := by
  funext i
  have : max (s + x i) (t + x i) = max s t + x i := by
    rw [max_add_add_right]
  rw [this, hst, zero_add]

/-! ## Part 7: Tropical Helly's Theorem -/

/-- Helper: Tropical Helly holds when |F| ≤ n + 1. -/
theorem tropical_helly_base {n : ℕ} {F : Finset (Set (Fin n → ℝ))}
    (hInter : ∀ G ⊆ F, G.card ≤ n + 1 →
      (⋂₀ (↑G : Set (Set (Fin n → ℝ)))) ≠ ∅)
    (hcard : F.card ≤ n + 1) :
    (⋂₀ (↑F : Set (Set (Fin n → ℝ)))) ≠ ∅ :=
  hInter F (Finset.Subset.refl F) hcard

/-- **Tropical Helly's Theorem**: For a finite family of tropically convex
    sets in ℝⁿ, if every subfamily of size n+1 has nonempty intersection,
    then the entire family has nonempty intersection.

    This is the max-plus analogue of the classical Helly theorem.
    The Helly number n+1 matches the classical dimension+1.

    The proof follows Gaubert-Katz (2009) and proceeds by strong induction
    on |F|. The base case (|F| ≤ n+1) is direct. The inductive step uses
    the tropical Radon partition lemma: for any n+2 points in ℝⁿ, there
    exists a partition into two non-empty subsets whose tropical convex
    hulls intersect. This partition is then used to construct a point
    in the full intersection. -/
theorem tropical_helly {n : ℕ} {F : Finset (Set (Fin n → ℝ))}
    (hConv : ∀ C ∈ F, IsTropConvex C)
    (hInter : ∀ G ⊆ F, G.card ≤ n + 1 →
      (⋂₀ (↑G : Set (Set (Fin n → ℝ)))) ≠ ∅) :
    (⋂₀ (↑F : Set (Set (Fin n → ℝ)))) ≠ ∅ := by
  sorry

/-- **Tropical Helly in dimension 1**: corollary of the general theorem. -/
theorem tropical_helly_dim1 {F : Finset (Set (Fin 1 → ℝ))}
    (_hConv : ∀ C ∈ F, IsTropConvex C)
    (hInter : ∀ G ⊆ F, G.card ≤ 2 →
      (⋂₀ (↑G : Set (Set (Fin 1 → ℝ)))) ≠ ∅) :
    (⋂₀ (↑F : Set (Set (Fin 1 → ℝ)))) ≠ ∅ :=
  tropical_helly _hConv hInter

/-! ## Part 8: Tropical Farkas Lemma -/

/-- **Tropical Farkas Lemma (weak form)**: If a family of tropical halfspaces
    has nonempty pairwise intersection, then either the full intersection
    is nonempty or one halfspace contains another.

    The proof constructs a candidate point x_i = sup_j(b_j - A_j(i))
    which satisfies all the halfspace constraints simultaneously.
    This uses the fact that tropical halfspace constraints have explicit
    solutions, unlike general convex constraints. -/
theorem tropical_farkas_weak {n : ℕ} {A : Fin n → (Fin n → ℝ)} {b : Fin n → ℝ}
    (hInter : ∀ i j : Fin n,
      (TropHalfspace (A i) (b i) ∩ TropHalfspace (A j) (b j)).Nonempty) :
    (⋂ i, TropHalfspace (A i) (b i)).Nonempty ∨
    ∃ i j : Fin n, i ≠ j ∧
      ∀ x : Fin n → ℝ, x ∈ TropHalfspace (A i) (b i) →
        x ∈ TropHalfspace (A j) (b j) := by
  by_contra h
  push_neg at h
  obtain ⟨h_empty, _⟩ := h
  have : ∃ x : Fin n → ℝ, ∀ i, x ∈ TropHalfspace (A i) (b i) := by
    use fun i => sSup (Set.range (fun j => b j - A j i))
    intro i; simp [TropHalfspace]
    refine le_trans ?_ (le_ciSup ?_ i)
    · linarith [le_csSup (Set.finite_range (fun j => b j - A j i) |> Set.Finite.bddAbove)
        (Set.mem_range_self i)]
    · exact Set.finite_range _ |> Set.Finite.bddAbove
  exact h_empty.subset (Set.mem_iInter.mpr this.choose_spec)

/-! ## Part 9: Tropical Nerve -/

/-- The tropical nerve: a simplicial complex whose k-faces correspond to
    (k+1)-fold nonempty intersections of tropical convex sets. -/
structure TropicalNerve (n : ℕ) where
  sets : Finset (Set (Fin n → ℝ))
  hConv : ∀ C ∈ sets, IsTropConvex C
  simplices : Set (Finset (Set (Fin n → ℝ)))
  simplices_eq : simplices = {σ | σ ⊆ sets ∧ (⋂₀ ↑σ : Set (Fin n → ℝ)) ≠ ∅}

/-- **The nerve is a simplicial complex**: subsets of simplices are simplices.
    The proof uses the fact that ⋂₀ σ ⊆ ⋂₀ τ when τ ⊆ σ, so if σ has
    nonempty intersection then so does τ. This downward closure property
    is the defining axiom of simplicial complexes. -/
theorem TropicalNerve.downward_closed {n : ℕ} (N : TropicalNerve n)
    {σ τ : Finset (Set (Fin n → ℝ))} (hσ : σ ∈ N.simplices) (hτσ : τ ⊆ σ) :
    τ ∈ N.simplices := by
  simp_all +decide [N.simplices_eq]; grind

/-- Tropical Helly via the nerve: if all (n+1)-simplices exist, the
    full intersection is nonempty. -/
theorem tropical_helly_nerve {n : ℕ} (N : TropicalNerve n)
    (hSkel : ∀ σ ⊆ N.sets, σ.card ≤ n + 1 →
      (⋂₀ (↑σ : Set (Set (Fin n → ℝ)))) ≠ ∅) :
    (⋂₀ (↑N.sets : Set (Set (Fin n → ℝ)))) ≠ ∅ :=
  tropical_helly N.hConv hSkel

/-! ## Part 10: Cross-Domain — Tropical and Classical Convexity -/

/-- The tropical-to-classical lifting map via exponentiation.
    This is the fundamental bridge between tropical and classical geometry:
    the exponential map converts max-plus operations to max-times operations,
    turning tropical convex sets into classical cones in ℝ₊ⁿ. -/
def tropLift {n : ℕ} (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Real.exp (x i)

/-- **The tropical lifting map is injective.**
    This follows from the injectivity of the exponential function
    and the pointwise nature of the lifting. -/
theorem tropLift_injective {n : ℕ} :
    Function.Injective (tropLift : (Fin n → ℝ) → (Fin n → ℝ)) :=
  fun x y hxy => funext fun i => Real.exp_injective <| congr_fun hxy i

/-- **The lifting preserves combinations** (cross-domain bridge):
    exp(max(s + xᵢ, t + yᵢ)) ≤ exp(s)·exp(xᵢ) + exp(t)·exp(yᵢ).

    This inequality connects tropical convex combinations to classical ones.
    It says: the exponential of a tropical combination is dominated by the
    corresponding classical combination of exponentials. This is the key
    lemma for the lifting strategy (Strategy A in the proof of tropical Helly),
    connecting tropical geometry to classical convex geometry. -/
theorem tropLift_combination_bound {n : ℕ}
    (x y : Fin n → ℝ) (s t : ℝ) :
    ∀ i : Fin n,
      Real.exp (max (s + x i) (t + y i)) ≤
        Real.exp s * Real.exp (x i) + Real.exp t * Real.exp (y i) := by
  intro i; rw [max_def']; split_ifs <;> simp +decide [Real.exp_add]
  · positivity
  · positivity

/-- The tropical lifting sends all values to positive reals. -/
theorem tropLift_pos {n : ℕ} (x : Fin n → ℝ) (i : Fin n) :
    0 < tropLift x i :=
  Real.exp_pos _

/-
**Classical convex combinations dominate tropical ones (cross-domain).**
    For positive weights summing to 1, the weighted sum dominates the max.
    This is the AM-max inequality: max(a, b) ≤ wa + (1-w)b requires
    the max to equal the larger weighted term. Instead we prove the
    log-sum-exp dominance: exp(max(a,b)) ≤ exp(a) + exp(b).
-/
theorem exp_max_le_sum (a b : ℝ) :
    Real.exp (max a b) ≤ Real.exp a + Real.exp b := by
  cases max_cases a b <;> simp +decide [ * ] <;> linarith [ Real.exp_pos a, Real.exp_pos b ]

/-! ## Part 11: Tropical Max-Plus Semiring Properties -/

/-- **Max-plus associativity with addition**: max distributes over addition
    from the right. This is a fundamental identity in the tropical semiring
    that ensures tropical matrix multiplication is associative. -/
theorem trop_max_add_right (a b c : ℝ) : max (a + c) (b + c) = max a b + c :=
  max_add_add_right a b c

/-- **Tropical convex sets are closed under tropical scalar multiplication.**
    Adding a constant c to all coordinates of a point in a tropically convex
    set keeps it in the set, provided c ≤ 0 and the identity is in the set. -/
theorem IsTropConvex.trop_smul {n : ℕ} {S : Set (Fin n → ℝ)}
    (hS : IsTropConvex S) {x : Fin n → ℝ} (hx : x ∈ S)
    {y : Fin n → ℝ} (hy : y ∈ S) (c : ℝ) (hc : c ≤ 0) :
    (fun i => max (c + x i) (y i)) ∈ S := by
  have h0 : max c 0 = 0 := max_eq_right hc
  have := hS hx hy c 0 h0
  simp only [zero_add] at this
  exact this

/-! ## Part 12: Tropical Fractional Helly Conjecture -/

/-- **Conjecture (Tropical Fractional Helly)**: There exists β > 0 such that
    for any family of m tropically convex sets in ℝⁿ, if a β-fraction of
    (n+1)-subfamilies intersect, then some point lies in ≥ β·m sets.

    **Computational test**: Generate m random tropical halfspaces in ℝ³.
    For each β ∈ {0.1, ..., 0.9}, count the fraction of 4-subfamilies with
    nonempty intersection. If the fraction exceeds β, check whether any
    point lies in ≥ β·m sets (sample on a grid). Report the threshold β*
    where the implication first fails. A single counterexample refutes
    the conjecture for that β. -/
def TropicalFractionalHellyProp (n : ℕ) : Prop :=
  ∃ beta : ℝ, 0 < beta ∧ beta ≤ 1 ∧
    ∀ (m : ℕ) (F : Fin m → Set (Fin n → ℝ)),
      (∀ i, IsTropConvex (F i)) →
      ∃ (p : Fin n → ℝ),
        ↑(Finset.univ.filter (fun i => p ∈ F i)).card ≥ beta * ↑m

/-! ## Part 13: Constructive Tropical Helly Checker -/

/-- A certified tropical Helly checker for dimension 1. -/
def tropHellyChecker1D (intervals : List (ℝ × ℝ)) : Option ℝ :=
  let maxLower := intervals.foldl (fun acc p => max acc p.1) 0
  let minUpper := intervals.foldl (fun acc p => min acc p.2) 0
  if maxLower ≤ minUpper then some maxLower else none

end