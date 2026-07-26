import Mathlib

/-! # CatalogBuild.Logic.HolographicSearch

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 15
-/

noncomputable section

/-- A proof system with bulk (full proof) and boundary (certificate). -/
structure BulkBoundaryProof where
  /-- Size of the full proof -/
  bulkSize : ℕ
  /-- Size of the verification certificate -/
  boundarySize : ℕ
  /-- Certificate is smaller than proof -/
  boundary_le_bulk : boundarySize ≤ bulkSize
  /-- Both are positive -/
  bulk_pos : 0 < bulkSize

/-- A proof is "holographic" if boundary grows as a root of bulk. -/
def isHolographicProof (P : BulkBoundaryProof) (d : ℕ) : Prop :=
  P.boundarySize ^ d ≤ P.bulkSize

/-- A proof graph with a partition into two regions. -/
structure PartitionedProof (n : ℕ) where
  /-- Which side of the partition each node belongs to -/
  partition : Fin n → Bool
  /-- Edge relation -/
  edge : Fin n → Fin n → Prop
  /-- Acyclicity -/
  acyclic : ∀ i j, edge i j → j.val < i.val

/-- The "cut" of a partition: edges crossing the boundary. -/
noncomputable def cutSize {n : ℕ} (P : PartitionedProof n)
    [∀ i j, Decidable (P.edge i j)] : ℕ :=
  (Finset.univ.filter (fun p : Fin n × Fin n =>
    P.edge p.1 p.2 ∧ P.partition p.1 ≠ P.partition p.2)).card

/-- The size of region A (true partition). -/
noncomputable def regionSize {n : ℕ} (P : PartitionedProof n) (side : Bool) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => P.partition i = side)).card

/-- A boundary search strategy explores certificates of bounded size. -/
structure BoundarySearch where
  /-- Maximum certificate size -/
  maxCertSize : ℕ
  /-- Verification time per certificate -/
  verifyTime : ℕ → ℕ
  /-- Verification is polynomial -/
  verify_poly : ∃ d c : ℕ, ∀ n, verifyTime n ≤ c * n ^ d

/-- A bulk search strategy explores full proof trees. -/
structure BulkSearch where
  /-- Size of search space -/
  searchSpace : ℕ → ℕ
  /-- Search space is exponential -/
  search_exp : ∃ b : ℕ, 1 < b ∧ ∀ n, n ≤ searchSpace n

/-- [Section: # CatalogBuild.Logic.HolographicSearch
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 15] -/
theorem boundary_faster_than_bulk (cert_size proof_size : ℕ)
    (verify_time : ℕ) (search_time : ℕ)
    (h_cert : cert_size ≤ proof_size)
    (h_verify : verify_time ≤ cert_size ^ 2)
    (h_search : proof_size ≤ search_time) :
    verify_time ≤ search_time ^ 2 := by
  exact le_trans h_verify ( Nat.pow_le_pow_left ( h_cert.trans h_search ) 2 )

/-- An entanglement wedge for a proof: given boundary lemmas S,
the wedge W(S) contains all proof steps recoverable from S. -/
structure EntanglementWedge (n m : ℕ) where
  /-- Which boundary lemmas are known -/
  knownBoundary : Finset (Fin m)
  /-- Which bulk steps can be reconstructed -/
  reconstructible : Finset (Fin n)

/-- [Section: # CatalogBuild.Logic.HolographicSearch
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 15] -/
theorem wedge_monotone {n m : ℕ}
    (W : Finset (Fin m) → Finset (Fin n))
    (h_mono : ∀ S₁ S₂ : Finset (Fin m), S₁ ⊆ S₂ → W S₁ ⊆ W S₂)
    {S₁ S₂ : Finset (Fin m)} (hsub : S₁ ⊆ S₂) :
    (W S₁).card ≤ (W S₂).card := by
  exact Finset.card_le_card ( h_mono S₁ S₂ hsub )

theorem full_boundary_full_wedge {n m : ℕ} (hn : 0 < n)
    (W : Finset (Fin m) → Finset (Fin n))
    (h_complete : W Finset.univ = Finset.univ) :
    (W Finset.univ).card = n := by
  rw [ h_complete, Finset.card_fin ]

/-- A proof is k-resilient if removing any k steps still yields a valid
sub-proof of the conclusion. -/
def isResilient (n k : ℕ) (essential : Finset (Fin n)) : Prop :=
  ∀ removed : Finset (Fin n), removed.card ≤ k →
    ∃ surviving : Finset (Fin n),
      essential ⊆ surviving ∧ surviving.card ≥ n - k

theorem zero_resilient (n : ℕ) (essential : Finset (Fin n))
    (h : essential.card ≤ n) :
    isResilient n 0 essential := by
  intro removed hremoved; use Finset.univ; simp_all +decide ;

/-- A proof is strongly k-resilient if removing any k steps leaves all
essential steps untouched (essential and removed are disjoint). -/
def isStrongResilient (n k : ℕ) (essential : Finset (Fin n)) : Prop :=
  ∀ removed : Finset (Fin n), removed.card = k →
    ¬(essential ⊆ removed)

theorem resilience_bound (n k : ℕ) (essential : Finset (Fin n))
    (hkn : k ≤ n)
    (h : ∀ removed : Finset (Fin n), removed.card = k → Disjoint essential removed) :
    essential.card ≤ n - k := by
  have h_compl : ∃ removed : Finset (Fin n), removed.card = k ∧ essential ⊆ removedᶜ := by
    have h_card : ∃ removed : Finset (Fin n), removed.card = k ∧ Disjoint essential removed := by
      have h_card : Finset.card (Finset.univ \ essential) ≥ k := by
        by_contra h_contra;
        obtain ⟨removed, hremoved⟩ : ∃ removed : Finset (Fin n), removed.card = k ∧ Disjoint essential removed := by
          exact Exists.imp ( by aesop ) ( Finset.exists_subset_card_eq ( show k ≤ Finset.card ( Finset.univ : Finset ( Fin n ) ) from by simpa ) );
        exact h_contra <| le_trans hremoved.1.ge <| Finset.card_le_card <| show removed ⊆ Finset.univ \ essential from fun x hx => Finset.mem_sdiff.mpr ⟨ Finset.mem_univ _, fun hx' => Finset.disjoint_left.mp hremoved.2 hx' hx ⟩
      obtain ⟨ removed, hremoved ⟩ := Finset.exists_subset_card_eq h_card; use removed; aesop;
    exact ⟨ h_card.choose, h_card.choose_spec.1, fun x hx => Finset.mem_compl.mpr fun hx' => Finset.disjoint_left.mp h_card.choose_spec.2 hx hx' ⟩;
  obtain ⟨ removed, hremoved₁, hremoved₂ ⟩ := h_compl; have := Finset.card_le_card hremoved₂; simp_all +decide [ Finset.card_compl ] ;

end
