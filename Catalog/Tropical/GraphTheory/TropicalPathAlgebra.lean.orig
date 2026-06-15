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
* `reachable_iff_exists_walk` — Boolean reachability characterized by walk existence
* `tropical_idempotence` — max a a = a, the foundation of tropical aggregation

## References

This formalizes the classical connection between the max-plus semiring and
shortest/longest path problems in weighted directed graphs.
-/

open Finset Matrix

noncomputable section

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

/-
`sup'` distributes over addition from the right.
-/
theorem sup'_add_right {n : ℕ}
    (f : Fin n.succ → ℝ) (c : ℝ) :
    Finset.univ.sup' Finset.univ_nonempty f + c =
    Finset.univ.sup' Finset.univ_nonempty (fun k => f k + c) := by
  grind +suggestions

/-
`sup'` distributes over addition from the left.
-/
theorem add_sup'_left' {n : ℕ}
    (f : Fin n.succ → ℝ) (c : ℝ) :
    c + Finset.univ.sup' Finset.univ_nonempty f =
    Finset.univ.sup' Finset.univ_nonempty (fun k => c + f k) := by
  refine' le_antisymm _ _ <;> simp_all +decide [Finset.le_sup'_iff];
  · simpa using Finset.exists_max_image Finset.univ f ( Finset.univ_nonempty );
  · grind

/-
Finset.sup' over a bivariate function can be computed in either order.
-/
theorem sup'_sup'_comm {n : ℕ}
    (f : Fin n.succ → Fin n.succ → ℝ) :
    Finset.univ.sup' Finset.univ_nonempty (fun k =>
      Finset.univ.sup' Finset.univ_nonempty (fun l => f k l)) =
    Finset.univ.sup' Finset.univ_nonempty (fun l =>
      Finset.univ.sup' Finset.univ_nonempty (fun k => f k l)) := by
  exact Finset.sup'_comm univ_nonempty univ_nonempty fun b l => f b l

/-
**Tropical matrix multiplication is associative.** This is the algebraic engine
    behind path concatenation: composing optimal paths over two segments and then a
    third is the same as composing over the first and then the last two.
-/
theorem tropMul_assoc {n : ℕ}
    (A B C : Matrix (Fin n.succ) (Fin n.succ) ℝ) :
    tropMul (tropMul A B) C = tropMul A (tropMul B C) := by
  -- By definition of tropMul, we need to show that tropMul (tropMul A B) C = tropMul A (tropMul B C).
  funext i j;
  unfold tropMul;
  convert sup'_sup'_comm _ using 2;
  convert sup'_add_right _ _;
  convert add_sup'_left' _ _ using 2 ; ring

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

theorem pathFinset_one_nonempty {n : ℕ} (i j : Fin n) :
    (pathFinset n 1 i j).Nonempty := by
  exact ⟨ fun k => if k = 0 then i else j, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, rfl, rfl ⟩ ⟩

theorem pathFinset_pos_nonempty {n : ℕ} (m : ℕ) (i j : Fin n.succ) :
    (pathFinset n.succ (m + 1) i j).Nonempty := by
  refine' ⟨ fun k => if k = 0 then i else if k = m + 1 then j else 0, _ ⟩ ; simp +decide [ pathFinset ]

/-! ### Base case: length-1 walks -/

/-
For length-1 walks, the sup over pathFinset equals W i j.
-/
theorem sup_pathWeight_one {n : ℕ} (W : Matrix (Fin n.succ) (Fin n.succ) ℝ)
    (i j : Fin n.succ) :
    (pathFinset n.succ 1 i j).sup' (pathFinset_one_nonempty i j)
      (fun f => seqWeight W f) = W i j := by
  refine' le_antisymm ( Finset.sup'_le _ _ _ ) _;
  · unfold pathFinset seqWeight;
    aesop;
  · refine' le_trans _ ( Finset.le_sup' _ _ );
    rotate_left;
    exact fun k => if k = 0 then i else j;
    · exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, rfl, rfl ⟩;
    · unfold seqWeight; aesop;

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
  unfold seqWeight
  simp [Fin.sum_univ_castSucc] at *;
  rfl

/-! ### Main theorem: tropical powers = max walk weight -/

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
  intro m i j;
  induction' m with m ih generalizing i j <;> simp_all +decide [ tropPow ];
  · convert sup_pathWeight_one W i j |> Eq.symm;
  · refine' le_antisymm _ _;
    · simp +decide [ tropMul, ih ];
      -- By definition of pathFinset, there exists a walk of length m+2 from i to j.
      obtain ⟨f, hf⟩ : ∃ f : Fin (m + 2 + 1) → Fin (n + 1), f 0 = i ∧ f ⟨m + 2, by omega⟩ = j ∧ ∀ k : Fin (n + 1), (pathFinset (n + 1) (m + 1) i k).sup' (pathFinset_pos_nonempty m i k) (fun x => seqWeight W x) + W k j ≤ seqWeight W (fun t => f t.castSucc) + W (f ⟨m + 1, by omega⟩) (f ⟨m + 2, by omega⟩) := by
        -- By definition of supremum, there exists a vertex $k$ such that $(pathFinset (n + 1) (m + 1) i k).sup' (pathFinset_pos_nonempty m i k) (fun x => seqWeight W x) + W k j$ is maximal.
        obtain ⟨k, hk⟩ : ∃ k : Fin (n + 1), ∀ l : Fin (n + 1), (pathFinset (n + 1) (m + 1) i l).sup' (pathFinset_pos_nonempty m i l) (fun x => seqWeight W x) + W l j ≤ (pathFinset (n + 1) (m + 1) i k).sup' (pathFinset_pos_nonempty m i k) (fun x => seqWeight W x) + W k j := by
          simpa using Finset.exists_max_image Finset.univ ( fun l => ( pathFinset ( n + 1 ) ( m + 1 ) i l ).sup' ( pathFinset_pos_nonempty _ _ _ ) ( fun x => seqWeight W x ) + W l j ) ⟨ i, Finset.mem_univ i ⟩;
        -- By definition of supremum, there exists a walk $f$ of length $m+1$ from $i$ to $k$ such that $seqWeight W f = (pathFinset (n + 1) (m + 1) i k).sup' (pathFinset_pos_nonempty m i k) (fun x => seqWeight W x)$.
        obtain ⟨f, hf⟩ : ∃ f : Fin (m + 1 + 1) → Fin (n + 1), f 0 = i ∧ f ⟨m + 1, by omega⟩ = k ∧ seqWeight W f = (pathFinset (n + 1) (m + 1) i k).sup' (pathFinset_pos_nonempty m i k) (fun x => seqWeight W x) := by
          have := Finset.exists_max_image ( pathFinset ( n + 1 ) ( m + 1 ) i k ) ( fun x => seqWeight W x ) ( pathFinset_pos_nonempty m i k );
          obtain ⟨ f, hf₁, hf₂ ⟩ := this; use f; simp_all +decide [ pathFinset ] ;
          exact le_antisymm ( Finset.le_sup' ( fun x => seqWeight W x ) ( by aesop ) ) ( Finset.sup'_le _ _ fun x hx => hf₂ x ( by aesop ) ( by aesop ) );
        use Fin.snoc f j;
        simp_all +decide [ Fin.snoc ];
      use f; simp_all +decide [ pathFinset ] ;
      intro k; specialize hf; have := hf.2.2 k; simp_all +decide [ seqWeight ] ;
      rw [ Fin.sum_univ_castSucc ] ; aesop;
    · refine' Finset.sup'_le _ _ _;
      intro f hf;
      -- By definition of `seqWeight`, we can split the sum into the sum of the first `m + 1` steps and the last step.
      have h_split : seqWeight W f = seqWeight W (fun t => f t.castSucc) + W (f ⟨m + 1, by omega⟩) (f ⟨m + 2, by omega⟩) := by
        convert seqWeight_snoc W f using 1;
      refine' le_trans _ ( Finset.le_sup' _ <| show f ⟨ m + 1, by linarith ⟩ ∈ Finset.univ from Finset.mem_univ _ );
      simp_all +decide [ pathFinset ];
      exact ⟨ fun t => f t.castSucc, ⟨ hf.1, rfl ⟩, le_rfl ⟩

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
  constructor;
  · induction' m with m ih generalizing i j;
    · intro h
      use fun _ => i
      aesop;
    · intro h
      obtain ⟨k, hk⟩ := h;
      obtain ⟨ f, hf₁, hf₂, hf₃ ⟩ := ih k j hk.2;
      use Fin.cons i f;
      simp_all +decide [ Fin.forall_fin_succ ];
      exact hf₂;
  · rintro ⟨ f, rfl, rfl, hf ⟩;
    induction' m with m ihizing f;
    · simp [ReachableInExactly]
    · exact ⟨ f 1, hf 0, ihizing ( fun t => f t.succ ) fun t => hf t.succ ⟩

/-! ## Tropical idempotence (catalog connection) -/

/-- Tropical idempotence: `max a a = a`. Foundation of tropical aggregation.
    This is the idempotence axiom underlying tropical semirings, connecting
    to the catalog theorem `tropical_mirror_theorem`. -/
theorem tropical_idempotence (a : ℝ) : max a a = a := max_self a

end