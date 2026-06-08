import Mathlib

/-!
# Tropical Matrix Algebra and Graph Path Semantics

This file establishes the fundamental connection between tropical (max-plus) matrix
algebra and weighted directed graph path optimization.

## Main definitions

* `tropMul` — tropical matrix multiplication (max replaces sum, + replaces ×)
* `tropPow` — iterated tropical matrix power
* `seqWeight` — the total weight of a vertex sequence under a weight matrix
* `pathFinset` — the finset of all vertex sequences forming length-m walks i → j

## Main results

* `tropMul_entry` — the (i,j) entry of A ⊗ B is max_k (A_ik + B_kj)
* `tropMul_eq_max_path2_weight` — tropical product = max weight over length-2 paths
* `tropMul_assoc` — associativity of tropical matrix multiplication
* `tropBellman` — Bellman optimality recurrence for tropical powers
* `tropPow_eq_sup_pathWeight` — tropical power = max weight over length-m walks

## References

This formalizes the classical connection between the max-plus semiring and
shortest/longest path problems in weighted directed graphs.
-/

open Finset Matrix

noncomputable section

/-! ## Distributivity lemmas -/

/-- Left distributivity: `c + max a b = max (c + a) (c + b)`. -/
theorem real_add_max_left (a b c : ℝ) :
    c + max a b = max (c + a) (c + b) := by
  grind +splitImp

/-- Right distributivity: `max a b + c = max (a + c) (b + c)`. -/
theorem real_max_add_right (a b c : ℝ) :
    max a b + c = max (a + c) (b + c) := by
  rw [max_add_add_right]

/-! ## Tropical matrix multiplication -/

/-- Tropical matrix multiplication: replace sum with max, product with addition.
    The (i,j) entry is `max_k (A i k + B k j)`. -/
def tropMul {n : ℕ} (A B : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    Matrix (Fin n.succ) (Fin n.succ) ℝ :=
  fun i j => Finset.univ.sup' Finset.univ_nonempty (fun k => A i k + B k j)

/-- The (i,j) entry of the tropical product equals `sup'` over intermediate vertices. -/
theorem tropMul_entry {n : ℕ}
    (A B : Matrix (Fin n.succ) (Fin n.succ) ℝ) (i j : Fin n.succ) :
    tropMul A B i j = Finset.univ.sup' Finset.univ_nonempty (fun k => A i k + B k j) :=
  rfl

/-! ## Path weight for length-2 paths -/

/-- The weight of a length-2 directed path i → k → j using weight matrices W₁, W₂. -/
def Path2Weight {n : ℕ} (W₁ W₂ : Matrix (Fin n) (Fin n) ℝ)
    (i j k : Fin n) : ℝ :=
  W₁ i k + W₂ k j

/-- Tropical product equals the maximum weight over all length-2 paths. -/
theorem tropMul_eq_max_path2_weight {n : ℕ}
    (W₁ W₂ : Matrix (Fin n.succ) (Fin n.succ) ℝ) (i j : Fin n.succ) :
    tropMul W₁ W₂ i j =
      Finset.univ.sup' Finset.univ_nonempty (fun k => Path2Weight W₁ W₂ i j k) :=
  rfl

/-! ## Tropical powers -/

/-- Tropical matrix power: `tropPow W m` represents the optimal weight over
    all walks of length `m + 1`.
    - `tropPow W 0 = W` (length-1 walks = single edges)
    - `tropPow W (m+1) = tropMul (tropPow W m) W` (extend by one edge) -/
def tropPow {n : ℕ} (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    ℕ → Matrix (Fin n.succ) (Fin n.succ) ℝ
  | 0 => W
  | m + 1 => tropMul (tropPow W m) W

@[simp]
theorem tropPow_zero {n : ℕ} (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    tropPow W 0 = W := rfl

theorem tropPow_succ {n : ℕ} (m : ℕ)
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    tropPow W (m + 1) = tropMul (tropPow W m) W := rfl

/-- Bellman optimality recurrence: extending paths by one edge. -/
theorem tropBellman {n : ℕ}
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) (m : ℕ) (i j : Fin n.succ) :
    tropPow W (m + 1) i j =
      Finset.univ.sup' Finset.univ_nonempty
        (fun k => tropPow W m i k + W k j) := rfl

/-! ## Associativity of tropical matrix multiplication -/

/-- Finset.sup' over a bivariate function can be computed in either order. -/
theorem sup'_sup'_comm {n : ℕ}
    (f : Fin n.succ → Fin n.succ → ℝ) :
    Finset.univ.sup' Finset.univ_nonempty (fun k =>
      Finset.univ.sup' Finset.univ_nonempty (fun l => f k l)) =
    Finset.univ.sup' Finset.univ_nonempty (fun l =>
      Finset.univ.sup' Finset.univ_nonempty (fun k => f k l)) := by
  refine' le_antisymm _ _ <;> simp +decide [Finset.sup'_le_iff]
  · have := Finset.exists_max_image Finset.univ (fun p : Fin n.succ × Fin n.succ => f p.1 p.2)
      ⟨⟨0, 0⟩, Finset.mem_univ _⟩; aesop
  · have := Finset.exists_max_image Finset.univ (fun p : Fin (n + 1) × Fin (n + 1) => f p.2 p.1)
      ⟨⟨0, 0⟩, Finset.mem_univ _⟩; aesop

/-- `sup'` distributes over addition from the right. -/
theorem sup'_add_right {n : ℕ}
    (f : Fin n.succ → ℝ) (c : ℝ) :
    Finset.univ.sup' Finset.univ_nonempty f + c =
    Finset.univ.sup' Finset.univ_nonempty (fun k => f k + c) := by
  refine' le_antisymm _ _ <;> simp_all +decide [Finset.sup'_le_iff]
  · simpa using Finset.exists_max_image Finset.univ f Finset.univ_nonempty
  · exact fun i => ⟨i, le_rfl⟩

/-- `sup'` distributes over addition from the left. -/
theorem add_sup'_left {n : ℕ}
    (f : Fin n.succ → ℝ) (c : ℝ) :
    c + Finset.univ.sup' Finset.univ_nonempty f =
    Finset.univ.sup' Finset.univ_nonempty (fun k => c + f k) := by
  exact add_sup' univ f c univ_nonempty

/-- **Tropical matrix multiplication is associative.** This is the algebraic engine
    behind path concatenation. -/
theorem tropMul_assoc {n : ℕ}
    (A B C : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
  funext i j
  unfold tropMul
  convert sup'_sup'_comm _ using 2
  convert sup'_add_right _ _
  convert add_sup'_left _ _ using 2; ring

/-! ## Directed walks and walk weights -/

/-- The finset of all vertex sequences forming a walk of length m from i to j.
    A walk of length m has m+1 vertices: f(0) = i and f(m) = j. -/
def pathFinset (n : ℕ) (m : ℕ) (i j : Fin n) : Finset (Fin (m + 1) → Fin n) :=
  Finset.univ.filter (fun f => f 0 = i ∧ f ⟨m, Nat.lt_succ_of_le le_rfl⟩ = j)

/-- Weight of a vertex sequence: sum of consecutive edge weights. -/
def seqWeight {n m : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (f : Fin (m + 1) → Fin n) : ℝ :=
  ∑ t : Fin m, W (f t.castSucc) (f t.succ)

/-! ### Nonemptiness of path finsets -/

/-
The path finset for length 1 is nonempty (the pair [i, j] is always valid).
-/
theorem pathFinset_one_nonempty {n : ℕ} (i j : Fin n) :
    (pathFinset n 1 i j).Nonempty := by
  -- The set of functions from Fin 2 to Fin n where the first element is i and the second is j is nonempty because it contains at least the function that maps 0 to i and 1 to j.
  use fun k => if k = 0 then i else j;
  exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, rfl, rfl ⟩

/-
The path finset for length m+2 is nonempty when n ≥ 1.
-/
theorem pathFinset_succ_nonempty {n : ℕ} (m : ℕ) (i j : Fin n.succ) :
    (pathFinset n.succ (m + 2) i j).Nonempty := by
  -- Construct a witness function `f : Fin (m + 3) → Fin n.succ` with `f 0 = i`, `f ⟨m + 2,...⟩ = j`, and all other values arbitrary (e.g., 0).
  use fun t => if t.val = 0 then i else if t.val = m + 2 then j else 0;
  unfold pathFinset; aesop

/-- Nonemptiness of pathFinset for any m+1. -/
theorem pathFinset_pos_nonempty {n : ℕ} (m : ℕ) (i j : Fin n.succ) :
    (pathFinset n.succ (m + 1) i j).Nonempty := by
  cases m with
  | zero => exact pathFinset_one_nonempty i j
  | succ m => exact pathFinset_succ_nonempty m i j

/-! ### Base case: length-1 walks -/

/-
For length-1 walks, the sup over pathFinset equals W i j.
-/
theorem sup_pathWeight_one {n : ℕ} (W : Matrix (Fin n.succ) (Fin n.succ) ℝ)
    (i j : Fin n.succ) :
    (pathFinset n.succ 1 i j).sup' (pathFinset_one_nonempty i j)
      (fun f => seqWeight W f) = W i j := by
  refine' le_antisymm ( Finset.sup'_le _ _ _ ) _;
  · simp +decide [ pathFinset, seqWeight ];
    aesop;
  · simp +decide [ pathFinset, seqWeight ];
    exact ⟨ fun k => if k = 0 then i else j, by simp +decide, by simp +decide ⟩

/-! ### Inductive step: extending walks -/

/-
The seqWeight of a length-(m+2) walk decomposes as the seqWeight of its
    first m+1 steps plus the final edge weight.
-/
theorem seqWeight_snoc {n m : ℕ} (W : Matrix (Fin n) (Fin n) ℝ)
    (f : Fin (m + 2 + 1) → Fin n) :
    seqWeight (m := m + 2) W f =
      seqWeight (m := m + 1) W (fun t => f t.castSucc) +
        W (f ⟨m + 1, by omega⟩) (f ⟨m + 2, by omega⟩) := by
  convert Fin.sum_univ_castSucc _ using 1

/-
**Main Theorem**: Tropical matrix power equals the supremum of walk weights.

    `tropPow W m i j = max { seqWeight W f | f is a walk of length (m+1) from i to j }`

    This is the fundamental structural theorem connecting tropical linear algebra
    to graph path optimization.
-/
theorem tropPow_eq_sup_pathWeight {n : ℕ}
    (W : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    ∀ (m : ℕ) (i j : Fin n.succ),
      tropPow W m i j =
        (pathFinset n.succ (m + 1) i j).sup' (pathFinset_pos_nonempty m i j)
          (fun f => seqWeight W f) := by
  intro m
  induction' m with m ih;
  · intro i j;
    convert sup_pathWeight_one W i j |> Eq.symm;
  · -- By definition of tropPow, we have:
    intro i j
    have h_tropPow_succ : tropPow W (m + 1) i j =
      Finset.univ.sup' Finset.univ_nonempty
        (fun k => tropPow W m i k + W k j) := by
          grind +suggestions;
    refine' le_antisymm _ _ <;> simp_all +decide [ Finset.sup'_le_iff ];
    · -- Let's choose any $k$ that maximizes the expression.
      obtain ⟨k, hk⟩ : ∃ k : Fin (n + 1), ∀ k' : Fin (n + 1), ((pathFinset (n + 1) (m + 1) i k').sup' (pathFinset_pos_nonempty m i k') (fun x => seqWeight W x)) + W k' j ≤ ((pathFinset (n + 1) (m + 1) i k).sup' (pathFinset_pos_nonempty m i k) (fun x => seqWeight W x)) + W k j := by
        simpa using Finset.exists_max_image Finset.univ ( fun k => ( ( pathFinset ( n + 1 ) ( m + 1 ) i k ).sup' ( pathFinset_pos_nonempty m i k ) fun x => seqWeight W x ) + W k j ) ⟨ i, Finset.mem_univ i ⟩;
      -- Let's choose any $f$ that maximizes the expression.
      obtain ⟨f, hf⟩ : ∃ f : Fin (m + 2) → Fin (n + 1), f 0 = i ∧ f ⟨m + 1, by omega⟩ = k ∧ seqWeight W f = ((pathFinset (n + 1) (m + 1) i k).sup' (pathFinset_pos_nonempty m i k) (fun x => seqWeight W x)) := by
        have := Finset.exists_max_image ( pathFinset ( n + 1 ) ( m + 1 ) i k ) ( fun x => seqWeight W x ) ( pathFinset_pos_nonempty m i k );
        obtain ⟨ f, hf₁, hf₂ ⟩ := this; use f; simp_all +decide [ pathFinset ] ;
        exact le_antisymm ( Finset.le_sup' ( fun x => seqWeight W x ) ( by aesop ) ) ( Finset.sup'_le _ _ fun x hx => hf₂ x ( by aesop ) ( by aesop ) );
      refine' ⟨ Fin.snoc f j, _, _ ⟩ <;> simp_all +decide [ pathFinset ];
      · simp +decide [ Fin.snoc ];
      · intro b; specialize hk b; simp_all +decide [ seqWeight_snoc ] ;
        simp_all +decide [ Fin.snoc ];
    · obtain ⟨ k, hk ⟩ := Finset.exists_max_image ( pathFinset ( n + 1 ) ( m + 2 ) i j ) ( fun f => seqWeight W f ) ( pathFinset_pos_nonempty ( m + 1 ) i j );
      use k ⟨ m + 1, by linarith ⟩;
      intro x hx; specialize hk; have := hk.2 x hx; simp_all +decide [ seqWeight_snoc ] ;
      refine' le_trans ( hk.2 x hx ) _;
      refine' add_le_add _ _;
      · refine' Finset.le_sup' _ _;
        simp_all +decide [ pathFinset ];
      · unfold pathFinset at hk; aesop;

/-! ## Boolean reachability -/

/-- Boolean reachability: there exists a directed walk of exactly m steps. -/
def ReachableInExactly {n : ℕ} (G : Fin n → Fin n → Bool) : ℕ → Fin n → Fin n → Prop
  | 0, i, j => i = j
  | m + 1, i, j => ∃ k : Fin n, G i k = true ∧ ReachableInExactly G m k j

instance ReachableInExactly_decidable {n : ℕ} (G : Fin n → Fin n → Bool)
    (m : ℕ) (i j : Fin n) : Decidable (ReachableInExactly G m i j) := by
  induction m generalizing i j with
  | zero => simp [ReachableInExactly]; infer_instance
  | succ m ih => simp only [ReachableInExactly]; exact Fintype.decidableExistsFintype

/-
Boolean reachability in m steps iff there exists a vertex sequence
    forming a valid walk.
-/
theorem reachable_iff_exists_walk {n : ℕ} (G : Fin n → Fin n → Bool)
    (m : ℕ) (i j : Fin n) :
    ReachableInExactly G m i j ↔
    ∃ f : Fin (m + 1) → Fin n,
      f 0 = i ∧ f ⟨m, Nat.lt_succ_of_le le_rfl⟩ = j ∧
      ∀ t : Fin m, G (f t.castSucc) (f t.succ) = true := by
  induction' m with m ih generalizing i j;
  · simp [ReachableInExactly];
    exact ⟨ fun h => ⟨ fun _ => i, rfl, h ▸ rfl ⟩, by rintro ⟨ f, rfl, rfl ⟩ ; rfl ⟩;
  · constructor;
    · rintro ⟨ k, hk₁, hk₂ ⟩;
      obtain ⟨ f, hf₁, hf₂, hf₃ ⟩ := ih k j |>.1 hk₂;
      refine' ⟨ Fin.cons i f, _, _, _ ⟩ <;> simp_all +decide [ Fin.forall_fin_succ ];
      exact hf₂;
    · rintro ⟨ f, rfl, rfl, hf ⟩;
      exact ⟨ f 1, hf 0, ih _ _ |>.2 ⟨ fun t => f ( Fin.succ t ), rfl, rfl, fun t => hf ( Fin.succ t ) ⟩ ⟩

/-! ## Tropical idempotence (from catalog) -/

/-- Tropical idempotence: `max a a = a`. Foundation of tropical aggregation.
    Connects to catalog theorem `tropical_mirror_theorem`. -/
theorem tropical_idempotence (a : ℝ) : max a a = a := max_self a

end