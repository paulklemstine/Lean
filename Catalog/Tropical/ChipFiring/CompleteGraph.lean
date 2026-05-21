/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Complete Graph Specializations for Tropical Divisor Theory

This file specializes the general chip-firing theory to complete graphs `Kₙ`,
where explicit formulas for genus, canonical divisor, and vertex degrees are available.
The complete graph is the most symmetric case and serves as the testing ground
for tropical Riemann–Roch phenomena.

## Main Results

* `completeGraph_genus` — genus of `Kₙ` is `(n-1)(n-2)/2`
* `completeGraph_degree` — every vertex of `Kₙ` has degree `n-1`
* `completeGraph_edgeFinset_card` — `Kₙ` has `n(n-1)/2` edges
* `completeGraph_canonicalDivisor_coeff` — canonical divisor coefficient is `n-3`
* `completeGraph_canonicalDivisor_degree` — canonical divisor degree is `n(n-3)`

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Tropical.ChipFiring.Theorems

open Finset BigOperators SimpleGraph

/-! ## Complete Graph Degree -/

/-
Every vertex of the complete graph `Kₙ` has degree `n - 1`.
-/
theorem completeGraph_degree_eq (n : ℕ) (v : Fin n) :
    (completeGraph (Fin n)).degree v = n - 1 := by
  simp +decide [ Finset.filter_ne', Finset.card_erase_of_mem ]

/-! ## Complete Graph Edge Count -/

/-
The complete graph `Kₙ` has `n * (n - 1) / 2` edges.
-/
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
      use {u, v}; simp [huv];
      exact ⟨ Finset.card_pair ( by aesop ), le_total u v ⟩;
  · simp +arith +decide [ Nat.choose_two_right ]

/-! ## Complete Graph Genus -/

/-
The genus of the complete graph `Kₙ` is `(n-1)(n-2)/2`.
    This follows from `g = |E| - |V| + 1 = n(n-1)/2 - n + 1 = (n-1)(n-2)/2`.
-/
theorem completeGraph_genus (n : ℕ) (hn : 2 ≤ n) :
    genus (completeGraph (Fin n)) = ((n - 1) * (n - 2) / 2 : ℤ) := by
  -- Substitute the values of the edge count and vertex count into the genus formula.
  have h_genus : genus (completeGraph (Fin n)) = (n * (n - 1) / 2 : ℤ) - n + 1 := by
    have h_genus : genus (completeGraph (Fin n)) = (completeGraph (Fin n)).edgeFinset.card - n + 1 := by
      exact congrArg₂ _ ( congrArg₂ _ rfl ( by simp +decide [ Fintype.card_fin ] ) ) rfl;
    rw [ h_genus, completeGraph_edgeFinset_card ];
    lia;
  grind

/-! ## Complete Graph Canonical Divisor -/

/-
Each vertex of `Kₙ` receives coefficient `n - 3` in the canonical divisor.
-/
theorem completeGraph_canonicalDivisor_coeff (n : ℕ) (v : Fin n) :
    (canonicalDivisor (completeGraph (Fin n))).coeff v = (n : ℤ) - 3 := by
  -- By definition of canonical divisor, we have that (canonicalDivisor (completeGraph (Fin n))).coeff v = (completeGraph (Fin n)).degree v - 2.
  simp [canonicalDivisor, completeGraph_degree_eq];
  rw [ Nat.cast_sub ] <;> push_cast <;> linarith [ Fin.is_lt v ]

/-
The canonical divisor of `Kₙ` has degree `n * (n - 3)`.
    This equals `2g - 2 = (n-1)(n-2) - 2 = n² - 3n`.
-/
theorem completeGraph_canonicalDivisor_degree (n : ℕ) (hn : 2 ≤ n) :
    divisorDegree (canonicalDivisor (completeGraph (Fin n))) = n * ((n : ℤ) - 3) := by
  convert degree_canonicalDivisor ( G := completeGraph ( Fin n ) ) using 1;
  rw [ completeGraph_genus ] <;> ring;
  · rw [ Int.ediv_mul_cancel ] <;> norm_num [ ← even_iff_two_dvd, parity_simps ];
    ring;
  · grobner

/-! ## Effective Divisors on Complete Graphs -/

/-
On `Kₙ`, a single-vertex divisor `k·[v]` with `k ≥ 0` is effective.
-/
theorem singleVertexDivisor_effective {n : ℕ} (v : Fin n) {k : ℤ} (hk : 0 ≤ k) :
    Effective (singleVertexDivisor v k) := by
  intro w; by_cases hw : w = v <;> simp +decide [ *, singleVertexDivisor ] ;

/-
The degree of a single-vertex divisor is just its coefficient.
-/
theorem singleVertexDivisor_degree {V : Type*} [Fintype V] [DecidableEq V]
    [Nonempty V] (v₀ : V) (k : ℤ) :
    divisorDegree (singleVertexDivisor v₀ k) = k := by
  unfold divisorDegree singleVertexDivisor;
  aesop

/-! ## Connectivity of Complete Graphs -/

/-
The complete graph on `n ≥ 2` vertices is connected.
-/
theorem completeGraph_connected (n : ℕ) (hn : 2 ≤ n) :
    (completeGraph (Fin n)).Connected := by
  rcases n with ( _ | _ | n ) <;> simp_all +decide [ SimpleGraph.connected_iff_exists_forall_reachable ]

/-! ## Verified Genus Computation Examples -/

/-
K₃ has genus 1 (it is a triangle, topologically a torus).
-/
theorem K3_genus : genus (completeGraph (Fin 3)) = 1 := by
  convert completeGraph_genus 3 ( by decide )

/-
K₄ has genus 3.
-/
theorem K4_genus : genus (completeGraph (Fin 4)) = 3 := by
  convert completeGraph_genus 4 ( by decide ) using 1

/-
K₅ has genus 6.
-/
theorem K5_genus : genus (completeGraph (Fin 5)) = 6 := by
  convert completeGraph_genus 5 ( by decide ) using 1