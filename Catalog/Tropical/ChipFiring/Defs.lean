/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Chip-Firing and Divisor Theory on a Finite Graph — Definitions

This file lays the *load-bearing foundation* of Baker–Norine divisor theory on a finite
graph, working entirely over an ordinary Mathlib `SimpleGraph V`.

The central object is the **graph Laplacian** (chip-firing operator)

  `(lap G f).coeff v = ∑_{u ∼ v} (f v − f u)`,

a map `(V → ℤ) → Divisor V`.  We record here the definitions (`Divisor`, `lap`,
`divisorDegree`, `genus`, `canonicalDivisor`, `Effective`, `singleVertexDivisor`,
`bnNumber`) together with the *homomorphism layer*: `lap` is additive, kills constants,
respects negation, and lands in degree zero.  These five facts are exactly the axioms
needed to make chip-firing (linear) equivalence an `Equivalence` and degree a class
invariant (developed in `Tropical.ChipFiring.Theorems`).

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)

-- !-- Lab Notebook -- !--
Hypothesis: The whole algebraic layer of divisor theory is the *coset relation of one
  homomorphism* `lap`.  If `lap` is an additive, constant-killing, degree-zero map then
  linear equivalence and its degree invariance must follow purely formally.
Result: Confirmed.  `lap_zero`/`lap_neg`/`lap_add` are literally the three
  equivalence-relation axioms; `lap_deg_zero` is literally degree invariance.
Insight: `lap_deg_zero` needs *no* handshake/degree counting — it is pure antisymmetry of
  `f v − f u` under the symmetric adjacency relation, witnessed by a single
  `Finset.sum_nbij'` swap `(v,u) ↦ (u,v)` that negates every summand.
Failure analysis: Earlier encodings (a weighted multigraph `V → V → ℤ` carrying explicit
  symmetry, and a `deg(v)·f v − ∑ f u` Laplacian) obscured the antisymmetry that does all
  the work; the clean `∑_{u∼v}(f v − f u)` form makes the swap argument immediate.
-- !-- end -- !--
-/

import Mathlib

open Finset BigOperators SimpleGraph

/-! ## Divisors -/

/-- A divisor on a graph with vertex set `V` is an integer-valued function on vertices
(a formal `ℤ`-linear combination of vertices). -/
structure Divisor (V : Type*) where
  coeff : V → ℤ

namespace Divisor
variable {V : Type*}

@[ext] lemma ext {D E : Divisor V} (h : D.coeff = E.coeff) : D = E := by
  cases D; cases E; simpa using h

instance : Zero (Divisor V) := ⟨⟨fun _ => 0⟩⟩
instance : Add (Divisor V) := ⟨fun D E => ⟨fun v => D.coeff v + E.coeff v⟩⟩
instance : Neg (Divisor V) := ⟨fun D => ⟨fun v => -D.coeff v⟩⟩
instance : Sub (Divisor V) := ⟨fun D E => ⟨fun v => D.coeff v - E.coeff v⟩⟩
instance : SMul ℕ (Divisor V) := ⟨fun n D => ⟨fun v => n • D.coeff v⟩⟩
instance : SMul ℤ (Divisor V) := ⟨fun n D => ⟨fun v => n • D.coeff v⟩⟩

@[simp] lemma zero_coeff (v : V) : (0 : Divisor V).coeff v = 0 := rfl
@[simp] lemma add_coeff (D E : Divisor V) (v : V) :
    (D + E).coeff v = D.coeff v + E.coeff v := rfl
@[simp] lemma neg_coeff (D : Divisor V) (v : V) : (-D).coeff v = -D.coeff v := rfl
@[simp] lemma sub_coeff (D E : Divisor V) (v : V) :
    (D - E).coeff v = D.coeff v - E.coeff v := rfl
@[simp] lemma nsmul_coeff (n : ℕ) (D : Divisor V) (v : V) :
    (n • D).coeff v = n • D.coeff v := rfl
@[simp] lemma zsmul_coeff (n : ℤ) (D : Divisor V) (v : V) :
    (n • D).coeff v = n • D.coeff v := rfl

/-- The coefficient projection `Divisor V → (V → ℤ)` is injective; hence divisors form an
additive commutative group under pointwise operations. -/
instance : AddCommGroup (Divisor V) :=
  Function.Injective.addCommGroup (Divisor.coeff)
    (fun _ _ h => Divisor.ext h)
    rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl)

end Divisor

/-- A divisor is **effective** when every coefficient is non-negative. -/
def Effective {V : Type*} (D : Divisor V) : Prop := ∀ v, 0 ≤ D.coeff v

/-! ## Degree -/

section Degree
variable {V : Type*} [Fintype V]

/-- The **degree** of a divisor is the sum of its coefficients. -/
def divisorDegree (D : Divisor V) : ℤ := ∑ v, D.coeff v

@[simp] lemma divisorDegree_zero : divisorDegree (0 : Divisor V) = 0 := by
  simp [divisorDegree]

lemma divisorDegree_add (D E : Divisor V) :
    divisorDegree (D + E) = divisorDegree D + divisorDegree E := by
  simp [divisorDegree, Finset.sum_add_distrib]

lemma divisorDegree_neg (D : Divisor V) : divisorDegree (-D) = -divisorDegree D := by
  simp [divisorDegree, Finset.sum_neg_distrib]

end Degree

/-! ## The graph Laplacian (chip-firing operator) -/

section Laplacian
variable {V : Type*} [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The graph Laplacian applied to a firing pattern `f : V → ℤ`.  Firing along `f` moves
chips according to `(lap G f).coeff v = ∑_{u ∼ v} (f v − f u)`. -/
def lap (f : V → ℤ) : Divisor V := ⟨fun v => ∑ u ∈ G.neighborFinset v, (f v - f u)⟩

@[simp] lemma lap_coeff (f : V → ℤ) (v : V) :
    (lap G f).coeff v = ∑ u ∈ G.neighborFinset v, (f v - f u) := rfl

-- !-- The empty firing pattern moves no chips: each summand `0 - 0` vanishes. -- !--
@[simp] theorem lap_zero : lap G (0 : V → ℤ) = 0 := by
  ext v; simp

-- !-- A constant firing pattern is in the kernel: every summand `c - c` vanishes. -- !--
theorem lap_const (c : ℤ) : lap G (fun _ => c) = 0 := by
  ext v; simp

-- !-- Additivity: `(f+g)v - (f+g)u = (f v - f u) + (g v - g u)`, then split the sum. -- !--
theorem lap_add (f g : V → ℤ) : lap G (f + g) = lap G f + lap G g := by
  ext v
  simp only [lap_coeff, Divisor.add_coeff, Pi.add_apply, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl; intro u _; ring

-- !-- Negation: `lap` is `ℤ`-linear, so it commutes with pointwise negation. -- !--
theorem lap_neg (f : V → ℤ) : lap G (-f) = - lap G f := by
  ext v
  simp only [lap_coeff, Divisor.neg_coeff, Pi.neg_apply, ← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl; intro u _; ring

-- !-- Every Laplacian has degree zero, by antisymmetry of `f v - f u` under the symmetric
--     adjacency relation: the swap `(v,u) ↦ (u,v)` on adjacent ordered pairs negates each
--     summand yet preserves the index set, forcing `X = -X`. -- !--
theorem lap_deg_zero (f : V → ℤ) : divisorDegree (lap G f) = 0 := by
  unfold divisorDegree
  simp only [lap_coeff]
  have key : (∑ v, ∑ u ∈ G.neighborFinset v, (f v - f u))
      = ∑ v, ∑ u ∈ G.neighborFinset v, (f u - f v) := by
    rw [Finset.sum_sigma', Finset.sum_sigma']
    apply Finset.sum_nbij' (fun x => (⟨x.2, x.1⟩ : Σ _ : V, V)) (fun x => ⟨x.2, x.1⟩)
    · rintro ⟨v, u⟩ h
      simp only [Finset.mem_sigma, Finset.mem_univ, true_and, mem_neighborFinset] at *
      exact h.symm
    · rintro ⟨v, u⟩ h
      simp only [Finset.mem_sigma, Finset.mem_univ, true_and, mem_neighborFinset] at *
      exact h.symm
    · rintro ⟨v, u⟩ _; rfl
    · rintro ⟨v, u⟩ _; rfl
    · rintro ⟨v, u⟩ _; rfl
  have hneg : (∑ v, ∑ u ∈ G.neighborFinset v, (f u - f v))
      = -(∑ v, ∑ u ∈ G.neighborFinset v, (f v - f u)) := by
    rw [← Finset.sum_neg_distrib]; apply Finset.sum_congr rfl; intro v _
    rw [← Finset.sum_neg_distrib]; apply Finset.sum_congr rfl; intro u _; ring
  have := key.trans hneg
  linarith

/-! ## Genus and the canonical divisor -/

/-- The (combinatorial) **genus** of a graph: `g = |E| − |V| + 1`, the first Betti number. -/
def genus : ℤ := (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-- The **canonical divisor** assigns to each vertex `deg(v) − 2`. -/
def canonicalDivisor : Divisor V := ⟨fun v => (G.degree v : ℤ) - 2⟩

end Laplacian

/-! ## Single-vertex divisors -/

section Single
variable {V : Type*} [DecidableEq V]

/-- The divisor `k·[v₀]` placing `k` chips on `v₀` and none elsewhere. -/
def singleVertexDivisor (v₀ : V) (k : ℤ) : Divisor V :=
  ⟨fun w => if w = v₀ then k else 0⟩

end Single

/-! ## The Brill–Noether number -/

/-- The **Brill–Noether number** `ρ(g,r,d) = g − (r+1)(g − d + r)`. -/
def bnNumber (g r d : ℤ) : ℤ := g - (r + 1) * (g - d + r)