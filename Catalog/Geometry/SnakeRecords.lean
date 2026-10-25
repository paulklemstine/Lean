import Catalog.Geometry.TurnNormalForm

/-!
# Lab notes: record snakes for `n ≤ 7` and their turn profiles

Snakes are given by transition sequences (the coordinate flipped at each step, starting at the
all-`false` vertex).  We certify that each sequence is a snake in `Q n` and compute its
per-coordinate flip counts, i.e. the turn count of every `Q_1 □ Q_{n-1}` decomposition.
-/

namespace TurnMinimal

instance (n : ℕ) : DecidableRel (Q n).Adj := fun x y =>
  inferInstanceAs (Decidable (hammingDist x y = 1))

instance decIsSnakeOn {V : Type*} (G : SimpleGraph V) [DecidableEq V] [DecidableRel G.Adj]
    (p : ℕ → V) (a b : ℕ) : Decidable (IsSnakeOn G p a b) :=
  decidable_of_iff (∀ i ∈ Finset.Icc a b, ∀ j ∈ Finset.Icc a b,
      (p i = p j → i = j) ∧ (G.Adj (p i) (p j) ↔ (i + 1 = j ∨ j + 1 = i))) (by
    simp only [Finset.mem_Icc, IsSnakeOn]
    constructor
    · intro h
      exact ⟨fun i j hai hib haj hjb => (h i ⟨hai, hib⟩ j ⟨haj, hjb⟩).1,
        fun i j hai hib haj hjb => (h i ⟨hai, hib⟩ j ⟨haj, hjb⟩).2⟩
    · rintro ⟨h1, h2⟩ i hi j hj
      exact ⟨h1 i j hi.1 hi.2 hj.1 hj.2, h2 i j hi.1 hi.2 hj.1 hj.2⟩)

instance (V : Type*) (G : SimpleGraph V) [DecidableEq V] [DecidableRel G.Adj]
    (p : ℕ → V) (L : ℕ) : Decidable (IsSnake G p L) := decIsSnakeOn G p 0 L

/-- Vertex sequence of a transition sequence `t`, starting from the all-`false` vertex. -/
def vtx (n : ℕ) (t : List ℕ) : ℕ → Fin n → Bool
  | 0 => fun _ => false
  | s + 1 => fun k => xor (vtx n t s k) (decide (t[s]? = some k.val))

/-- Flip-count profile `(flips p L 0, …, flips p L (n-1))`. -/
def flipProfile (n : ℕ) (t : List ℕ) : List ℕ :=
  (List.finRange n).map (flips (vtx n t) t.length)

/-- Record transition sequences (lengths 2, 4, 7, 13, 26 for `n = 2, …, 6`). -/
def rec2 : List ℕ := [0, 1]
def rec3 : List ℕ := [0, 1, 2, 0]
def rec4 : List ℕ := [0, 1, 2, 0, 3, 1, 0]
def rec5 : List ℕ := [0, 1, 2, 3, 1, 0, 4, 3, 1, 2, 3, 0, 1]
def rec6 : List ℕ := [0, 1, 2, 3, 1, 0, 4, 3, 0, 5, 4, 0, 1, 3, 4, 0, 2, 4, 1, 0, 4, 3, 1, 5,
  3, 4]

/-- Best snake found by our heuristic search in `Q 7` (length `48`; the record is `50`). -/
def best7 : List ℕ := [3, 4, 6, 1, 4, 3, 0, 1, 4, 6, 1, 3, 4, 5, 0, 3, 4, 6, 1, 4, 3, 0, 4, 6,
  2, 4, 0, 3, 4, 5, 6, 4, 3, 0, 1, 4, 3, 5, 6, 4, 5, 0, 3, 4, 5, 6, 4, 3]

theorem rec2_isSnake : IsSnake (Q 2) (vtx 2 rec2) rec2.length := by decide
theorem rec3_isSnake : IsSnake (Q 3) (vtx 3 rec3) rec3.length := by decide
theorem rec4_isSnake : IsSnake (Q 4) (vtx 4 rec4) rec4.length := by decide
theorem rec5_isSnake : IsSnake (Q 5) (vtx 5 rec5) rec5.length := by native_decide
theorem rec6_isSnake : IsSnake (Q 6) (vtx 6 rec6) rec6.length := by native_decide

theorem best7_isSnake : IsSnake (Q 7) (vtx 7 best7) best7.length := by native_decide
theorem best7_length : best7.length = 48 := rfl

theorem rec4_profile : flipProfile 4 rec4 = [3, 2, 1, 1] := by decide
theorem rec5_profile : flipProfile 5 rec5 = [3, 4, 2, 3, 1] := by native_decide
theorem rec6_profile : flipProfile 6 rec6 = [6, 5, 2, 5, 6, 2] := by native_decide
/-- The `48`-snake in `Q 7` flips coordinate `2` exactly once: it is a one-turn comb
`Q_1 □ Q_6` made of two snakes of `Q_6`. -/
theorem best7_profile : flipProfile 7 best7 = [6, 5, 1, 10, 14, 5, 7] := by native_decide

/-- In the 26-snake of `Q 6`, using coordinate `2` as the row coordinate gives a product
snake in `Q_1 □ Q_5` with only `2` direction changes, within the normal-form bound `26 / 6`.
In contrast, for the balanced split `Q_3 □ Q_3` the general lower bound (with the trivial
bound `S = 7` for snakes in `Q_3`) forces at least `3` direction changes. -/
theorem rec6_turn_profile :
    flips (vtx 6 rec6) 26 2 = 2 ∧ 6 * flips (vtx 6 rec6) 26 2 ≤ 26 ∧
      3 ≤ turnCount (fun s => (split 3 3 (vtx 6 rec6 s)).1) 26 := by
  have h2 : flips (vtx 6 rec6) 26 2 = 2 := by
    have := rec6_profile
    simp only [flipProfile] at this
    have h := congrArg (fun l => l[2]?) this
    simpa using h
  refine ⟨h2, by omega, ?_⟩
  have hb := hypercube_succ_le_turns_mul_pow (a := 3) (b := 3) rec6_isSnake
  have hlen : rec6.length = 26 := rfl
  rw [hlen] at hb
  revert hb
  generalize turnCount (fun s => (split 3 3 (vtx (3 + 3) rec6 s)).1) 26 = m
  intro hb
  norm_num at hb
  omega

end TurnMinimal