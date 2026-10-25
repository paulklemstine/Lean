import Catalog.Geometry.ProductSnake

/-!
# The hypercube as a box product, and turn bounds for snakes in `Q_n`

`Q n` is the `n`-dimensional hypercube on `Fin n → Bool` (adjacent iff Hamming distance `1`).
Splitting coordinates as `Fin (a + b) = Fin a ⊕ Fin b` embeds `Q (a + b)` into the box product
`Q a □ Q b` isomorphically on adjacency.  Consequently, for any snake in `Q (a + b)`:

* `TurnMinimal.hypercube_rowTurns_add_colTurns`: (flips among the first `a` coordinates) +
  (flips among the last `b` coordinates) = length;
* `TurnMinimal.hypercube_succ_le_turns_mul`: if every snake in `Q b` has length `≤ S`, then
  `L + 1 ≤ (rowTurns + 1) * (S + 1)`;
* `TurnMinimal.hypercube_succ_le_turns_mul_pow`: unconditionally,
  `L + 1 ≤ (rowTurns + 1) * 2 ^ b`.
-/

namespace TurnMinimal

variable {V W : Type*}

/-- The `n`-dimensional hypercube graph. -/
def Q (n : ℕ) : SimpleGraph (Fin n → Bool) where
  Adj x y := hammingDist x y = 1
  symm x y h := by simpa [hammingDist_comm] using h
  loopless := ⟨fun x h => by simp at h⟩

/-- Split a vertex of `Q (a + b)` into its first `a` and last `b` coordinates. -/
def split (a b : ℕ) (x : Fin (a + b) → Bool) : (Fin a → Bool) × (Fin b → Bool) :=
  (fun i => x (Fin.castAdd b i), fun j => x (Fin.natAdd a j))

lemma split_injective (a b : ℕ) : Function.Injective (split a b) := by
  intro x y h
  simp only [split, Prod.mk.injEq] at h
  funext k
  refine Fin.addCases (fun i => ?_) (fun j => ?_) k
  · exact congrFun h.1 i
  · exact congrFun h.2 j

lemma hammingDist_split (a b : ℕ) (x y : Fin (a + b) → Bool) :
    hammingDist x y = hammingDist (split a b x).1 (split a b y).1 +
      hammingDist (split a b x).2 (split a b y).2 := by
  simp only [hammingDist, split, Finset.card_filter]
  exact Fin.sum_univ_add (fun k => if x k ≠ y k then 1 else 0)

/-- The coordinate split is a graph isomorphism `Q (a + b) ≅ Q a □ Q b` on adjacency. -/
theorem Q_adj_iff_split (a b : ℕ) (x y : Fin (a + b) → Bool) :
    (Q (a + b)).Adj x y ↔ (Q a □ Q b).Adj (split a b x) (split a b y) := by
  change hammingDist x y = 1 ↔ _
  rw [SimpleGraph.boxProd_adj, hammingDist_split]
  change _ ↔ (hammingDist _ _ = 1 ∧ _) ∨ (hammingDist _ _ = 1 ∧ _)
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos (hammingDist (split a b x).1 (split a b y).1) with h0 | h0
    · exact Or.inr ⟨by omega, hammingDist_eq_zero.1 h0⟩
    · exact Or.inl ⟨by omega, hammingDist_eq_zero.1 (by omega)⟩
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · rw [h1, h2, hammingDist_self]
    · rw [h1, h2, hammingDist_self]

/-- Snakes transfer along adjacency-preserving-and-reflecting injections. -/
theorem IsSnakeOn.map {G : SimpleGraph V} {G' : SimpleGraph W} {f : V → W}
    (hf : Function.Injective f) (hadj : ∀ x y, G.Adj x y ↔ G'.Adj (f x) (f y))
    {p : ℕ → V} {a b : ℕ} (h : IsSnakeOn G p a b) : IsSnakeOn G' (fun i => f (p i)) a b :=
  ⟨fun i j hai hib haj hjb hij => h.1 i j hai hib haj hjb (hf hij),
   fun i j hai hib haj hjb => (hadj _ _).symm.trans (h.2 i j hai hib haj hjb)⟩

/-- Trivial snake bound: a snake visits distinct vertices. -/
theorem snakeBound_card [Fintype V] (G : SimpleGraph V) :
    SnakeBound G (Fintype.card V - 1) := by
  classical
  intro p a b hab h
  have hinj : Set.InjOn p (Finset.Icc a b : Set ℕ) := by
    intro i hi j hj hij
    simp only [Finset.coe_Icc, Set.mem_Icc] at hi hj
    exact h.1 i j hi.1 hi.2 hj.1 hj.2 hij
  have := Finset.card_le_univ ((Finset.Icc a b).image p)
  rw [Finset.card_image_of_injOn hinj, Nat.card_Icc] at this
  omega

/-- Step accounting in `Q (a + b)`: flips of the first `a` coordinates plus flips of the
last `b` coordinates equal the length. -/
theorem hypercube_rowTurns_add_colTurns {a b L : ℕ} {p : ℕ → Fin (a + b) → Bool}
    (hp : IsSnake (Q (a + b)) p L) :
    turnCount (fun s => (split a b (p s)).1) L + turnCount (fun s => (split a b (p s)).2) L
      = L := by
  have h' : IsSnake (Q a □ Q b) (fun s => split a b (p s)) L :=
    IsSnakeOn.map (split_injective a b) (Q_adj_iff_split a b) hp
  exact turnCount_row_add_turnCount_col h'.isWalk

/-- **Direction changes are essential in `Q_n`.** If every snake in `Q b` has length at most
`S`, then a snake of length `L` in `Q (a + b)` flips one of its first `a` coordinates at least
`(L + 1) / (S + 1) - 1` times. -/
theorem hypercube_succ_le_turns_mul {a b L S : ℕ} {p : ℕ → Fin (a + b) → Bool}
    (hp : IsSnake (Q (a + b)) p L) (hS : SnakeBound (Q b) S) :
    L + 1 ≤ (turnCount (fun s => (split a b (p s)).1) L + 1) * (S + 1) := by
  have h' : IsSnake (Q a □ Q b) (fun s => split a b (p s)) L :=
    IsSnakeOn.map (split_injective a b) (Q_adj_iff_split a b) hp
  exact succ_le_turnCount_succ_mul h' hS

/-- Unconditional version: `L + 1 ≤ (rowTurns + 1) * 2 ^ b`. -/
theorem hypercube_succ_le_turns_mul_pow {a b L : ℕ} {p : ℕ → Fin (a + b) → Bool}
    (hp : IsSnake (Q (a + b)) p L) :
    L + 1 ≤ (turnCount (fun s => (split a b (p s)).1) L + 1) * 2 ^ b := by
  have h := hypercube_succ_le_turns_mul hp (snakeBound_card (Q b))
  have hc : Fintype.card (Fin b → Bool) = 2 ^ b := by simp
  rw [hc, Nat.sub_add_cancel (Nat.one_le_two_pow)] at h
  exact h

end TurnMinimal