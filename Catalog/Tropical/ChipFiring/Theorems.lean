/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Chip-Firing Theorems: Degree Invariance, Canonical Class, and Cross-Domain Connections

This file proves the fundamental theorems of tropical divisor theory on finite graphs:

1. **Degree invariance under chip-firing** (`divisorDegree_laplacian_zero`):
   The Laplacian divisor has degree zero, certifying that chip-firing preserves total chip count.
   This is equivalent to conservation of charge in discrete electrostatics.

2. **Degree preserved by linear equivalence** (`linearEquivalent_degree_eq`):
   Linearly equivalent divisors have equal degree.

3. **Canonical divisor degree** (`degree_canonicalDivisor`):
   The canonical divisor `K_G` has degree `2g - 2`, the tropical shadow of the
   algebro-geometric canonical class formula.

4. **Cross-domain characterization** (`linearEquivalent_iff_diff_in_laplacian_image`):
   Two divisors are linearly equivalent iff their difference lies in the image of the
   negative Laplacian. This connects tropical geometry to discrete potential theory.

5. **Linear equivalence is an equivalence relation**: reflexivity, symmetry, transitivity.

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Tropical.ChipFiring.Defs

open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## Theorem 1: Degree of the Laplacian Divisor is Zero

This is the foundational conservation law: chip-firing neither creates nor destroys chips.
In discrete electrostatics, this says that the Laplacian represents a zero-total-charge
perturbation—the discrete analogue of ∫ Δf = 0.

The proof requires a genuine summation rearrangement: we swap the order of summation
over the double sum ∑_v ∑_w [v~w](f(v) - f(w)) and use the symmetry of adjacency
to cancel terms.
-/

/-
**Conservation of charge / Chip-firing preserves degree.**
    The Laplacian divisor of any potential function has degree zero.
    Equivalently, ∑_v ∑_{w~v} (f(v) - f(w)) = 0 for any f : V → ℤ.

    This is simultaneously:
    - A tropical geometry fact (principal divisors have degree zero)
    - A discrete electrostatics fact (conservation of charge)
    - A graph theory fact (the Laplacian matrix has zero row-sum property)
-/
theorem divisorDegree_laplacian_zero
    (f : V → ℤ) :
    divisorDegree (laplacianDivisor G f) = 0 := by
  -- Apply the Finset.sum_comm to change the order of summation.
  have h_flip_symmetry : ∑ v : V, ∑ w : V, (if G.Adj v w then f v - f w else 0) = ∑ w : V, ∑ v : V, (if G.Adj v w then f v - f w else 0) := by
    exact Finset.sum_comm;
  unfold divisorDegree laplacianDivisor; simp +decide [ Finset.sum_ite, Finset.filter_congr, SimpleGraph.adj_comm ] ; ring!;
  simp_all +decide [ Finset.sum_ite, Finset.filter_congr, SimpleGraph.adj_comm ] ; ring!;
  linarith!;

/-! ## Theorem 1b: Degree is Invariant Under Linear Equivalence -/

/-
Linearly equivalent divisors have the same degree. This follows directly from
    the fact that principal divisors (Laplacian divisors) have degree zero.
-/
theorem linearEquivalent_degree_eq
    {D E : GraphDivisor V}
    (h : LinearEquivalent G D E) :
    divisorDegree D = divisorDegree E := by
  obtain ⟨ f, hf ⟩ := h;
  have h_deg : divisorDegree E = divisorDegree D - divisorDegree (laplacianDivisor G f) := by
    unfold divisorDegree;
    rw [ ← Finset.sum_sub_distrib, Finset.sum_congr rfl fun _ _ => hf _ ];
  rw [ h_deg, divisorDegree_laplacian_zero, sub_zero ]

/-! ## Theorem 2: Canonical Divisor Degree = 2g - 2

The canonical divisor K_G assigns deg(v) - 2 to each vertex v.
Its degree is ∑_v (deg(v) - 2) = (∑_v deg(v)) - 2|V| = 2|E| - 2|V| = 2(|E| - |V| + 1) - 2 = 2g - 2.

This uses the handshaking lemma ∑_v deg(v) = 2|E| (available as
`SimpleGraph.sum_degrees_eq_twice_card_edges` in Mathlib).
-/

/-
**Tropical canonical class formula.**
    The canonical divisor has degree `2g - 2`, where `g = |E| - |V| + 1` is the genus.

    This is the combinatorial backbone of the Riemann–Roch theorem and the tropical
    analogue of the Gauss–Bonnet theorem / Riemann–Hurwitz formula.
-/
theorem degree_canonicalDivisor :
    divisorDegree (canonicalDivisor G) = 2 * genus G - 2 := by
  unfold divisorDegree canonicalDivisor genus;
  simp +decide [ Finset.sum_sub_distrib, SimpleGraph.sum_degrees_eq_twice_card_edges ] ; ring;
  linarith [ SimpleGraph.sum_degrees_eq_twice_card_edges G ]

/-! ## Theorem 3: Cross-Domain Characterization of Linear Equivalence

This theorem provides an equivalent characterization: two divisors are linearly equivalent
iff their difference lies in the image of the negative Laplacian operator. This connects:
- **Tropical geometry**: divisor classes = cokernel of the Laplacian
- **Discrete electrostatics**: potential differences = Laplacian image
- **Algebraic graph theory**: chip-firing equivalence = integer Laplacian kernel structure
-/

/-
**Linear equivalence ↔ difference in Laplacian image.**
    `D ~ E` iff there exists a potential `f` with `E(v) - D(v) = -Δf(v)` for all `v`.
-/
theorem linearEquivalent_iff_diff_in_laplacian_image
    (D E : GraphDivisor V) :
    LinearEquivalent G D E ↔
    ∃ f : V → ℤ, ∀ v, E.coeff v - D.coeff v = -(laplacianDivisor G f).coeff v := by
  constructor <;> intro h;
  · exact ⟨ h.choose, fun v => by linarith [ h.choose_spec v ] ⟩;
  · exact ⟨ h.choose, fun v => by linarith [ h.choose_spec v ] ⟩

/-! ## Linear Equivalence is an Equivalence Relation

These are essential structural facts for the divisor class group.
-/

/-
Linear equivalence is reflexive: every divisor is equivalent to itself
    (witnessed by the zero potential).
-/
theorem linearEquivalent_refl (D : GraphDivisor V) :
    LinearEquivalent G D D := by
  exact ⟨ fun _ => 0, fun _ => by simp +decide [ laplacianDivisor ] ⟩

/-
Linear equivalence is symmetric: if D ~ E then E ~ D
    (negate the witnessing potential).
-/
theorem linearEquivalent_symm {D E : GraphDivisor V}
    (h : LinearEquivalent G D E) :
    LinearEquivalent G E D := by
  obtain ⟨ f, hf ⟩ := h;
  -- By definition of linear equivalence, we need to show that there exists a potential function $g$ such that $D = E - \Delta g$.
  use -f;
  unfold laplacianDivisor; simp +decide [ hf ] ;
  unfold laplacianDivisor; simp +decide [ Finset.sum_ite ] ;
  simp +decide [ Finset.sum_add_distrib, Finset.sum_neg_distrib, mul_comm ];
  exact fun v => by ring;

/-
Linear equivalence is transitive: if D ~ E and E ~ F then D ~ F
    (add the witnessing potentials).
-/
theorem linearEquivalent_trans {D E F : GraphDivisor V}
    (h₁ : LinearEquivalent G D E) (h₂ : LinearEquivalent G E F) :
    LinearEquivalent G D F := by
  obtain ⟨ f₁, hf₁ ⟩ := h₁
  obtain ⟨ f₂, hf₂ ⟩ := h₂;
  -- By definition of Laplacian, we know that (laplacianDivisor G (f₁ + f₂)).coeff v = (laplacianDivisor G f₁).coeff v + (laplacianDivisor G f₂).coeff v.
  have h_laplacian_add : ∀ v, (laplacianDivisor G (f₁ + f₂)).coeff v = (laplacianDivisor G f₁).coeff v + (laplacianDivisor G f₂).coeff v := by
    unfold laplacianDivisor; simp +decide [ Finset.sum_add_distrib ] ;
    exact fun v => by rw [ ← Finset.sum_add_distrib ] ; congr ; ext ; split_ifs <;> ring;
  exact ⟨ f₁ + f₂, fun v => by linarith [ hf₁ v, hf₂ v, h_laplacian_add v ] ⟩

/-! ## Handshaking Lemma Consequence: Sum of Degrees

We include this as a standalone lemma since it's the key ingredient
in the canonical divisor degree proof and connects to graph theory. -/

/-
The sum of vertex degrees equals twice the number of edges.
    This is the handshaking lemma, used as a bridge between
    degree-sum identities and edge-counting formulas.
-/
theorem sum_degrees_eq_twice_edges :
    (∑ v : V, (G.degree v : ℤ)) = 2 * (G.edgeFinset.card : ℤ) := by
  exact mod_cast G.sum_degrees_eq_twice_card_edges

/-! ## Effective Divisor Properties -/

/-
An effective divisor has nonnegative degree.
-/
theorem effective_nonneg_degree {D : GraphDivisor V}
    (hD : Effective D) : 0 ≤ divisorDegree D := by
  exact Finset.sum_nonneg fun v _ => hD v

/-
The zero divisor is effective.
-/
theorem effective_zero : Effective (0 : GraphDivisor V) := by
  exact fun _ => rfl.le

/-! ## Laplacian Properties -/

/-
The Laplacian of the zero function is the zero divisor.
-/
theorem laplacianDivisor_zero :
    laplacianDivisor G (0 : V → ℤ) = 0 := by
  exact congr_arg _ ( funext fun v => Finset.sum_eq_zero fun w hw => by aesop )

/-
The Laplacian is linear: Δ(f + g) = Δf + Δg.
-/
theorem laplacianDivisor_add (f g : V → ℤ) :
    laplacianDivisor G (f + g) = laplacianDivisor G f + laplacianDivisor G g := by
  ext v;
  simp +decide [ laplacianDivisor, Finset.sum_add_distrib ];
  simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_congr rfl fun w _ => by split_ifs <;> ring;

/-
The Laplacian negates: Δ(-f) = -Δf.
-/
theorem laplacianDivisor_neg (f : V → ℤ) :
    laplacianDivisor G (-f) = -laplacianDivisor G f := by
  unfold laplacianDivisor;
  ext v; simp +decide [ neg_add_eq_sub, Finset.sum_ite ] ;

/-! ## Chip-Firing and Single-Vertex Firing

Connection between the Laplacian framework and individual vertex firing. -/

/-
Firing a single vertex `v₀` (setting f = indicator of {v₀}) produces a Laplacian
    divisor that removes `deg(v₀)` chips from `v₀` and adds one chip to each neighbor.
-/
theorem laplacianDivisor_indicator_vertex (v₀ : V) :
    (laplacianDivisor G (fun v => if v = v₀ then 1 else 0)).coeff v₀ = G.degree v₀ := by
  unfold laplacianDivisor; simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset ] ;
  simp +decide [ Finset.sum_ite, SimpleGraph.adj_comm ]