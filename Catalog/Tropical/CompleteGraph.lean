/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Graph Divisor Theory on Complete Graphs `Kₙ`

A single, self-contained development of a verified foundational fragment of Baker–Norine
divisor / chip-firing theory, specialized to the complete graphs `Kₙ = completeGraph (Fin n)`.

The file is organised in two layers.

* **General layer.**  Over an arbitrary finite `SimpleGraph V` we define divisors
  (`Divisor`), their degree (`divisorDegree`), the graph Laplacian / chip-firing operator
  (`lap`), the combinatorial genus (`genus`), the canonical divisor (`canonicalDivisor`),
  effectivity (`Effective`), single-vertex divisors (`singleVertexDivisor`), principal
  divisors (`IsPrincipal`), and single-vertex firing divisors (`firingDivisor`).  The
  central invariant — *every principal divisor has degree zero* — is established, along
  with the canonical-degree identity `deg K = 2·g − 2`.

* **Complete-graph layer.**  For `Kₙ` all of these acquire closed forms: every vertex has
  degree `n − 1`, there are `n(n−1)/2` edges, the genus is `(n−1)(n−2)/2`, the canonical
  coefficient is `n − 3`, the canonical degree is `n(n−3)`, and firing a vertex subtracts
  `n − 1` there and adds `1` everywhere else.

The development deliberately stops short of the full graph Riemann–Roch theorem, providing
instead a dependable computational base.

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
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

/-- The empty firing pattern moves no chips. -/
@[simp] theorem lap_zero : lap G (0 : V → ℤ) = 0 := by
  ext v; simp

/-- A constant firing pattern is in the kernel. -/
theorem lap_const (c : ℤ) : lap G (fun _ => c) = 0 := by
  ext v; simp

/-- Additivity of the Laplacian. -/
theorem lap_add (f g : V → ℤ) : lap G (f + g) = lap G f + lap G g := by
  ext v
  simp only [lap_coeff, Divisor.add_coeff, Pi.add_apply, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl; intro u _; ring

/-- The Laplacian commutes with pointwise negation. -/
theorem lap_neg (f : V → ℤ) : lap G (-f) = - lap G f := by
  ext v
  simp only [lap_coeff, Divisor.neg_coeff, Pi.neg_apply, ← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl; intro u _; ring

/-- Every Laplacian has degree zero, by antisymmetry of `f v − f u` under the symmetric
adjacency relation: the swap `(v,u) ↦ (u,v)` on adjacent ordered pairs negates each
summand yet preserves the index set, forcing `X = −X`. -/
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

/-! ## General divisor theory: the canonical degree, principal & firing divisors -/

section General
variable {V : Type*} [Fintype V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-
**Degree of the canonical divisor.**  By the handshake lemma `∑ deg v = 2|E|`,
    `deg K = ∑ (deg v − 2) = 2|E| − 2|V| = 2(|E| − |V| + 1) − 2 = 2·g − 2`.
-/
theorem degree_canonicalDivisor :
    divisorDegree (canonicalDivisor G) = 2 * genus G - 2 := by
  -- By definition of the degree of a divisor, we have:
  have h_deg : divisorDegree (canonicalDivisor G) = ∑ v : V, (G.degree v - 2 : ℤ) := by
    rfl;
  simp_all +decide [ mul_comm ];
  rw [ ← Nat.cast_sum, SimpleGraph.sum_degrees_eq_twice_card_edges ] ; simp +decide [ genus ] ; ring

/-
The Laplacian is additive over a finite sum of firing patterns.
-/
theorem lap_sum {ι : Type*} (s : Finset ι) (F : ι → V → ℤ) :
    lap G (∑ i ∈ s, F i) = ∑ i ∈ s, lap G (F i) := by
  induction' s using Finset.induction with a s' ha ih;
  all_goals try exact Classical.decEq _;
  · aesop;
  · simp +decide [ *, Finset.sum_insert, lap_add ]

/-- A divisor is **principal** if it is the Laplacian of some firing pattern, i.e. it is
    obtained by a sequence of chip-firing / Laplacian moves. -/
def IsPrincipal (D : Divisor V) : Prop := ∃ f : V → ℤ, lap G f = D

/-
Every principal divisor has degree zero — the central conservation law of chip-firing.
-/
theorem IsPrincipal.degree_zero {D : Divisor V} (h : IsPrincipal G D) :
    divisorDegree D = 0 := by
  obtain ⟨f, hf⟩ := h;
  rw [ ← hf, lap_deg_zero ]

variable [DecidableEq V]

/-- The divisor obtained by **firing the single vertex `v`**: `v` loses `deg(v)` chips and
    each neighbour gains `1`.  In Laplacian form this is `lap G (−𝟙_v)`. -/
def firingDivisor (v : V) : Divisor V :=
  lap G (fun w => if w = v then (-1 : ℤ) else 0)

/-- A single-vertex firing divisor is principal. -/
theorem firingDivisor_isPrincipal (v : V) : IsPrincipal G (firingDivisor G v) :=
  ⟨_, rfl⟩

/-- Firing a vertex produces a degree-zero divisor. -/
theorem firingDivisor_degree_zero (v : V) :
    divisorDegree (firingDivisor G v) = 0 :=
  (firingDivisor_isPrincipal G v).degree_zero

/-
**Firing preserves degree:** adding a firing divisor leaves the total degree unchanged.
-/
theorem firing_preserves_degree (D : Divisor V) (v : V) :
    divisorDegree (D + firingDivisor G v) = divisorDegree D := by
  convert divisorDegree_add D ( firingDivisor G v ) using 1;
  rw [ firingDivisor_degree_zero, add_zero ]

/-
**The single-vertex firing divisors sum to zero.**  Firing every vertex once is the
    Laplacian of the constant pattern `−1`, which is trivial.
-/
theorem sum_firingDivisor_eq_zero :
    ∑ v, firingDivisor G v = 0 := by
  -- By definition of lap, we have lap G (∑ v, g v) = ∑ v, lap G (g v).
  have h_lap_sum : lap G (∑ v : V, (fun w => if w = v then (-1 : ℤ) else 0)) = ∑ v : V, lap G (fun w => if w = v then (-1 : ℤ) else 0) := by
    convert lap_sum G Finset.univ _;
  convert h_lap_sum.symm using 1;
  convert lap_const G ( -1 ) |> Eq.symm;
  simp +decide

end General

/-! ## Complete Graph Degree -/

/-- Every vertex of the complete graph `Kₙ` has degree `n - 1`. -/
theorem completeGraph_degree_eq (n : ℕ) (v : Fin n) :
    (completeGraph (Fin n)).degree v = n - 1 := by
  simp +decide

/-! ## Complete Graph Edge Count -/

/-- The complete graph `Kₙ` has `n * (n - 1) / 2` edges. -/
theorem completeGraph_edgeFinset_card (n : ℕ) :
    (completeGraph (Fin n)).edgeFinset.card = n * (n - 1) / 2 := by
  convert Finset.card_powersetCard 2 ( Finset.univ : Finset ( Fin n ) ) using 1;
  · refine' Eq.symm ( Finset.card_bij _ _ _ _ );
    use fun a ha => Sym2.mk ( a.min' ( Finset.card_pos.mp ( by rw [ Finset.mem_powersetCard ] at ha; linarith ) ), a.max' ( Finset.card_pos.mp ( by rw [ Finset.mem_powersetCard ] at ha; linarith ) ) );
    · simp +contextual [ Finset.mem_powersetCard, Finset.card_eq_two ];
    · simp +contextual [ Finset.mem_powersetCard, Sym2.eq ];
      intro a₁ ha₁ a₂ ha₂ h; rw [ Finset.card_eq_two ] at ha₁ ha₂; obtain ⟨ x, y, hx, hy, hxy ⟩ := ha₁; obtain ⟨ u, v, hu, hv, huv ⟩ := ha₂; simp_all +decide [ Finset.min', Finset.max' ] ;
      grind;
    · rintro ⟨ u, v ⟩ huv;
      use {u, v}; simp;
      exact ⟨ Finset.card_pair ( by aesop ), le_total u v ⟩;
  · simp +arith +decide [ Nat.choose_two_right ]

/-! ## Complete Graph Genus -/

/-- The genus of the complete graph `Kₙ` is `(n-1)(n-2)/2`.
    This follows from `g = |E| - |V| + 1 = n(n-1)/2 - n + 1 = (n-1)(n-2)/2`. -/
theorem completeGraph_genus (n : ℕ) (hn : 2 ≤ n) :
    genus (completeGraph (Fin n)) = ((n - 1) * (n - 2) / 2 : ℤ) := by
  have h_genus : genus (completeGraph (Fin n)) = (n * (n - 1) / 2 : ℤ) - n + 1 := by
    have h_genus : genus (completeGraph (Fin n)) = (completeGraph (Fin n)).edgeFinset.card - n + 1 := by
      exact congrArg₂ _ ( congrArg₂ _ rfl ( by simp +decide [ Fintype.card_fin ] ) ) rfl;
    rw [ h_genus, completeGraph_edgeFinset_card ];
    lia;
  grind

/-! ## Complete Graph Canonical Divisor -/

/-- Each vertex of `Kₙ` receives coefficient `n - 3` in the canonical divisor. -/
theorem completeGraph_canonicalDivisor_coeff (n : ℕ) (v : Fin n) :
    (canonicalDivisor (completeGraph (Fin n))).coeff v = (n : ℤ) - 3 := by
  simp only [canonicalDivisor, completeGraph_degree_eq]
  rw [ Nat.cast_sub ] <;> push_cast <;> linarith [ Fin.is_lt v ]

/-
The canonical divisor of `Kₙ` has degree `n * (n - 3)`.
    Summing the constant coefficient `n − 3` over the `n` vertices.
-/
theorem completeGraph_canonicalDivisor_degree (n : ℕ) :
    divisorDegree (canonicalDivisor (completeGraph (Fin n))) = n * ((n : ℤ) - 3) := by
  unfold divisorDegree;
  rw [ Finset.sum_congr rfl fun x hx => completeGraph_canonicalDivisor_coeff n x ] ; norm_num;
  ring

/-- On `Kₙ` the canonical degree equals `2g − 2` (the Riemann–Roch identity for the
    canonical class), a direct specialization of `degree_canonicalDivisor`. -/
theorem completeGraph_canonicalDivisor_degree_eq_genus (n : ℕ) :
    divisorDegree (canonicalDivisor (completeGraph (Fin n)))
      = 2 * genus (completeGraph (Fin n)) - 2 :=
  degree_canonicalDivisor _

/-! ## Explicit Chip-Firing Move on `Kₙ` -/

/-
**Explicit firing formula on `Kₙ`.**  Firing a vertex `v` subtracts `n − 1` at `v` and
    adds `1` at every other vertex.
-/
theorem completeGraph_firingDivisor_coeff (n : ℕ) (v w : Fin n) :
    (firingDivisor (completeGraph (Fin n)) v).coeff w
      = if w = v then -((n : ℤ) - 1) else 1 := by
  split_ifs <;> simp_all +decide [ firingDivisor ];
  rw [ Nat.cast_pred ] <;> linarith [ Fin.is_lt v ]

/-! ## Effective Divisors on Complete Graphs -/

/-- On `Kₙ`, a single-vertex divisor `k·[v]` with `k ≥ 0` is effective. -/
theorem singleVertexDivisor_effective {n : ℕ} (v : Fin n) {k : ℤ} (hk : 0 ≤ k) :
    Effective (singleVertexDivisor v k) := by
  intro w; by_cases hw : w = v <;> simp +decide [ *, singleVertexDivisor ]

/-- The degree of a single-vertex divisor is just its coefficient. -/
theorem singleVertexDivisor_degree {V : Type*} [Fintype V] [DecidableEq V]
    [Nonempty V] (v₀ : V) (k : ℤ) :
    divisorDegree (singleVertexDivisor v₀ k) = k := by
  unfold divisorDegree singleVertexDivisor
  aesop

/-! ## Connectivity of Complete Graphs -/

/-- The complete graph on `n ≥ 2` vertices is connected. -/
theorem completeGraph_connected (n : ℕ) (hn : 2 ≤ n) :
    (completeGraph (Fin n)).Connected := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ]

/-! ## Verified Genus Computation Examples -/

/-- K₃ has genus 1 (it is a triangle, topologically a torus). -/
theorem K3_genus : genus (completeGraph (Fin 3)) = 1 := by
  convert completeGraph_genus 3 ( by decide )

/-- K₄ has genus 3. -/
theorem K4_genus : genus (completeGraph (Fin 4)) = 3 := by
  convert completeGraph_genus 4 ( by decide ) using 1

/-- K₅ has genus 6. -/
theorem K5_genus : genus (completeGraph (Fin 5)) = 6 := by
  convert completeGraph_genus 5 ( by decide ) using 1