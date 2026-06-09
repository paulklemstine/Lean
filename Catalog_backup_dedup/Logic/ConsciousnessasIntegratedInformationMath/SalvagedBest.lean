theorem Phi_le_cut (S : Finset α) (hS : IsNontrivialBipartition S) :
    sys.Phi ≤ sys.cut S := by
  convert Finset.inf'_le _ ( Finset.mem_filter.mpr ⟨ Finset.mem_univ S, hS ⟩ );
  grind +locals

/-
!-- The minimum of a finite nonempty set is achieved by some element. -- !--

**Theorem 3 (PEGB-P)**: The Minimum Information Partition exists: Φ is
attained by some nontrivial bipartition.

*Example (E)*: In K₃ with uniform weights, every bipartition achieves the minimum.
*Generalization (G)*: Extends to weighted hypergraph integration systems.
*Boundary (B)*: Fails for |α| ≤ 1 (no nontrivial bipartitions exist).
-/

theorem Phi_achieved (h : (nontrivialBipartitions α).Nonempty) :
    ∃ S ∈ nontrivialBipartitions α, sys.cut S = sys.Phi := by
  obtain ⟨ S, hS ⟩ := Finset.exists_min_image ( nontrivialBipartitions α ) ( fun S => sys.cut S ) h;
  unfold IntegratedInformation.IntegrationSystem.Phi;
  exact ⟨ S, hS.1, le_antisymm ( by aesop ) ( by aesop ) ⟩

/-
!-- Forward: Φ = 0 and Φ = min of non-neg values ⟹ some value = 0.
Backward: if some cut is 0, then Φ ≤ 0, and Φ ≥ 0, so Φ = 0. -- !--

**Theorem 4 (PEGB-P)**: Φ = 0 iff the system is "reducible" — there exists
a nontrivial bipartition with zero integration.

This is the mathematical formulation of IIT's central claim: consciousness
(Φ > 0) is equivalent to irreducibility (no zero-cost partition exists).

*Example (E)*: A disconnected graph has Φ = 0 (take the disconnecting cut).
*Generalization (G)*: Characterizes reducibility in arbitrary integration systems.
*Boundary (B)*: Requires |α| ≥ 2; for singletons, Φ = 0 vacuously.
-/

theorem Phi_eq_zero_iff (h : (nontrivialBipartitions α).Nonempty) :
    sys.Phi = 0 ↔ ∃ S ∈ nontrivialBipartitions α, sys.cut S = 0 := by
  rw [ IntegratedInformation.IntegrationSystem.Phi ];
  constructor <;> intro H <;> simp_all +decide [ Finset.inf'_eq_csInf_image ];
  · have := ( IsCompact.sInf_mem ( show IsCompact ( sys.cut '' ( nontrivialBipartitions α : Set ( Finset α ) ) ) from Set.Finite.isCompact <| Set.toFinite _ ) <| Set.Nonempty.image _ h ) ; aesop;
  · exact le_antisymm ( csInf_le ⟨ 0, Set.forall_mem_image.2 fun S hS => sys.cut_nonneg S ⟩ ⟨ H.choose, H.choose_spec.1, H.choose_spec.2 ⟩ ) ( le_csInf ⟨ _, Set.mem_image_of_mem _ H.choose_spec.1 ⟩ <| Set.forall_mem_image.2 fun S hS => sys.cut_nonneg S )

/-
For a subsingleton type, there are no nontrivial bipartitions, so Φ = 0.
-/

theorem graphCutSystem_Phi_mono (w₁ w₂ : α → α → ℝ)
    (hw₁ : ∀ a b, 0 ≤ w₁ a b) (hw₂ : ∀ a b, 0 ≤ w₂ a b)
    (hs₁ : ∀ a b, w₁ a b = w₁ b a) (hs₂ : ∀ a b, w₂ a b = w₂ b a)
    (hle : ∀ a b, w₁ a b ≤ w₂ a b) :
    (graphCutSystem w₁ hw₁ hs₁).Phi ≤ (graphCutSystem w₂ hw₂ hs₂).Phi := by
  unfold IntegrationSystem.Phi;
  split_ifs <;> simp_all +decide;
  exact fun S hS => ⟨ S, hS, Finset.sum_le_sum fun a ha => Finset.sum_le_sum fun b hb => hle a b ⟩

end IntegratedInformation

/-!
## FUTURE DIRECTIONS

1. **Conjecture (Submodularity ⟹ MIP structure)**: If the cut function of an
   `IntegrationSystem` is submodular (i.e., `cut(A ∪ B) + cut(A ∩ B) ≤ cut(A) + cut(B)`),
   then the MIP can be found in polynomial time via submodular function minimization.
   *Testable*: Implement SFM and verify on random graphs up to n=20.

2. **Conjecture (Spectral bound on Φ)**: For a `graphCutSystem` with adjacency
   matrix A and Laplacian L, Φ ≥ λ₂(L) · n / 4, where λ₂ is the Fiedler
   eigenvalue (algebraic connectivity). This connects integrated information
   to spectral graph theory.
   *Testable*: Compute both sides for all graphs on ≤ 8 vertices.

3. **Conjecture (Monotone Φ under edge contraction)**: Contracting an edge in
   a graph can only decrease Φ. Equivalently, identifying two elements of α
   yields a system with Φ' ≤ Φ.
   *Testable*: Enumerate all edge contractions of random graphs on ≤ 10 vertices.

4. **Conjecture (Φ and treewidth)**: For graphs with treewidth ≤ k, Φ can be
   computed in time O(n · 2^k), interpolating between the trivial case (trees,
   k=1) and the general exponential case.
   *Testable*: Implement the DP algorithm and verify correctness against brute force.

5. **Cross-connection to ConsciousnessFixedPoint**: An integration system with
   Φ > 0 admits a non-trivial fixed point under the "self-modeling" operator
   of `Catalog.Logic.ConsciousnessFixedPoint`, connecting information integration
   to self-referential fixed-point theory.
-/