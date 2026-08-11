import Physics.AdjacencyDegree.Quotient

/-!
# A connected, non-regular six-vertex moment-indistinguishable pair

The regular examples of `RegularFailure.lean` are disconnected or regular, hence arguably
degenerate.  Here we exhibit two **connected, non-regular** graphs on six vertices which share
*all* adjacency-degree moments yet are non-isomorphic: they carry equitable colourings with
identical class sizes and identical quotient data, so `Quotient.lean` applies verbatim, while
one is triangle-free and the other contains a triangle.

* `hex1` : the bipartite graph with edges `03, 04, 05, 13, 15, 23, 24`;
* `hex2` : the graph with edges `01, 02, 05, 15, 23, 24, 34`.

Both have degree sequence `(3,3,2,2,2,2)` and equitable quotient `B = [[1,2],[1,1]]` on the
classes `{degree 3}`, `{degree 2}` of sizes `2, 4`.
-/

namespace AdjDeg

open Matrix Finset

/-- Edge list of the first witness. -/
def hex1Edges : List (Fin 6 × Fin 6) := [(0, 3), (0, 4), (0, 5), (1, 3), (1, 5), (2, 3), (2, 4)]

/-- Edge list of the second witness. -/
def hex2Edges : List (Fin 6 × Fin 6) := [(0, 1), (0, 2), (0, 5), (1, 5), (2, 3), (2, 4), (3, 4)]

/-- The triangle-free witness. -/
def hex1 : SimpleGraph (Fin 6) where
  Adj i j := (i, j) ∈ hex1Edges ∨ (j, i) ∈ hex1Edges
  symm := fun _ _ h => h.symm
  loopless := ⟨by decide⟩

/-- The witness containing a triangle. -/
def hex2 : SimpleGraph (Fin 6) where
  Adj i j := (i, j) ∈ hex2Edges ∨ (j, i) ∈ hex2Edges
  symm := fun _ _ h => h.symm
  loopless := ⟨by decide⟩

instance : DecidableRel hex1.Adj := fun i j =>
  inferInstanceAs (Decidable ((i, j) ∈ hex1Edges ∨ (j, i) ∈ hex1Edges))

instance : DecidableRel hex2.Adj := fun i j =>
  inferInstanceAs (Decidable ((i, j) ∈ hex2Edges ∨ (j, i) ∈ hex2Edges))

/-- Colouring of the first witness by degree class (`0` = degree three). -/
def hex1Color : Fin 6 → Fin 2 := ![0, 1, 1, 0, 1, 1]

/-- Colouring of the second witness by degree class (`0` = degree three). -/
def hex2Color : Fin 6 → Fin 2 := ![0, 1, 0, 1, 1, 1]

/-- Class representatives. -/
def hexRep1 : Fin 2 → Fin 6 := ![0, 1]

/-- Class representatives. -/
def hexRep2 : Fin 2 → Fin 6 := ![0, 1]

lemma hex1_equitable : IsEquitable hex1 hex1Color := by
  unfold IsEquitable
  decide

lemma hex2_equitable : IsEquitable hex2 hex2Color := by
  unfold IsEquitable
  decide

lemma hex1_rep : ∀ v : Fin 6, hex1Color (hexRep1 (hex1Color v)) = hex1Color v := by decide

lemma hex2_rep : ∀ v : Fin 6, hex2Color (hexRep2 (hex2Color v)) = hex2Color v := by decide

lemma hex_classSize_eq (κ : Fin 2) : classSize hex1Color κ = classSize hex2Color κ := by
  have h : ∀ k : Fin 2,
      (Finset.univ.filter fun v : Fin 6 => hex1Color v = k).card
        = (Finset.univ.filter fun v : Fin 6 => hex2Color v = k).card := by decide
  unfold classSize
  exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (h κ)

lemma hex_quotAdj_eq : quotAdj hex1 hex1Color hexRep1 = quotAdj hex2 hex2Color hexRep2 := by
  have h : ∀ κ lam : Fin 2,
      quotCount hex1 hex1Color hexRep1 κ lam = quotCount hex2 hex2Color hexRep2 κ lam := by
    decide
  ext κ lam
  simp only [quotAdj, Matrix.of_apply]
  exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (h κ lam)

lemma hex_deg_eq (κ : Fin 2) :
    (hex1.degree (hexRep1 κ) : ℝ) = (hex2.degree (hexRep2 κ) : ℝ) := by
  have h : ∀ k : Fin 2, hex1.degree (hexRep1 k) = hex2.degree (hexRep2 k) := by decide
  exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) (h κ)

/-- **The two witnesses have identical adjacency-degree moments.** -/
theorem hex_wordMoment_eq (w : List Letter) : wordMoment hex1 w = wordMoment hex2 w :=
  wordMoment_eq_of_quot_eq hex1 hex1Color hexRep1 hex2 hex2Color hexRep2
    hex1_equitable hex1_rep hex2_equitable hex2_rep hex_classSize_eq hex_quotAdj_eq hex_deg_eq w

lemma hex1_triangle_free : ¬ ∃ a b c : Fin 6, hex1.Adj a b ∧ hex1.Adj b c ∧ hex1.Adj a c := by
  decide

lemma hex2_triangle : hex2.Adj 2 3 ∧ hex2.Adj 3 4 ∧ hex2.Adj 2 4 := by decide

/-- The two witnesses are not isomorphic. -/
theorem hex_not_iso : IsEmpty (hex1 ≃g hex2) := by
  refine ⟨fun f => hex1_triangle_free ⟨f.symm 2, f.symm 3, f.symm 4, ?_, ?_, ?_⟩⟩
  · exact f.symm.map_adj_iff.mpr hex2_triangle.1
  · exact f.symm.map_adj_iff.mpr hex2_triangle.2.1
  · exact f.symm.map_adj_iff.mpr hex2_triangle.2.2

/-- Neither witness is regular. -/
theorem hex1_not_regular : ¬ ∃ k, hex1.IsRegularOfDegree k := by
  rintro ⟨k, hk⟩
  have h0 : hex1.degree 0 = k := hk 0
  have h1 : hex1.degree 1 = k := hk 1
  have d0 : hex1.degree 0 = 3 := by decide
  have d1 : hex1.degree 1 = 2 := by decide
  omega

theorem hex2_not_regular : ¬ ∃ k, hex2.IsRegularOfDegree k := by
  rintro ⟨k, hk⟩
  have h0 : hex2.degree 0 = k := hk 0
  have h1 : hex2.degree 1 = k := hk 1
  have d0 : hex2.degree 0 = 3 := by decide
  have d1 : hex2.degree 1 = 2 := by decide
  omega

/-! ### Connectivity of the witnesses -/

lemma hex1_reachable_zero (v : Fin 6) : hex1.Reachable 0 v := by
  have a3 : hex1.Adj 0 3 := by decide
  have a4 : hex1.Adj 0 4 := by decide
  have a5 : hex1.Adj 0 5 := by decide
  have b1 : hex1.Adj 3 1 := by decide
  have b2 : hex1.Adj 3 2 := by decide
  fin_cases v
  · exact SimpleGraph.Reachable.refl 0
  · exact a3.reachable.trans b1.reachable
  · exact a3.reachable.trans b2.reachable
  · exact a3.reachable
  · exact a4.reachable
  · exact a5.reachable

lemma hex2_reachable_zero (v : Fin 6) : hex2.Reachable 0 v := by
  have a1 : hex2.Adj 0 1 := by decide
  have a2 : hex2.Adj 0 2 := by decide
  have a5 : hex2.Adj 0 5 := by decide
  have b3 : hex2.Adj 2 3 := by decide
  have b4 : hex2.Adj 2 4 := by decide
  fin_cases v
  · exact SimpleGraph.Reachable.refl 0
  · exact a1.reachable
  · exact a2.reachable
  · exact a2.reachable.trans b3.reachable
  · exact a2.reachable.trans b4.reachable
  · exact a5.reachable

theorem hex1_connected : hex1.Connected := by
  rw [SimpleGraph.connected_iff_exists_forall_reachable]
  exact ⟨0, hex1_reachable_zero⟩

theorem hex2_connected : hex2.Connected := by
  rw [SimpleGraph.connected_iff_exists_forall_reachable]
  exact ⟨0, hex2_reachable_zero⟩

/-- **Sharp failure of moment determination.** There are two connected, non-regular graphs on
six vertices with identical adjacency-degree moments that are not isomorphic. -/
theorem moment_failure_connected_nonregular :
    (∀ w : List Letter, wordMoment hex1 w = wordMoment hex2 w) ∧
      IsEmpty (hex1 ≃g hex2) ∧ hex1.Connected ∧ hex2.Connected ∧
      (¬ ∃ k, hex1.IsRegularOfDegree k) ∧ (¬ ∃ k, hex2.IsRegularOfDegree k) :=
  ⟨hex_wordMoment_eq, hex_not_iso, hex1_connected, hex2_connected,
    hex1_not_regular, hex2_not_regular⟩

end AdjDeg