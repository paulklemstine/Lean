import RequestProject.Catalog.Tropical.SeparatorEscape

/-!
# Lifting grid snakes to hypercube snakes, and a one-coordinate escape at `L = K = 4`

`SnakeEscape.lift_gridSnake` : any induced path in the abstract graph
`P_{L+1} □ P_{K+1} □ Q_c` (described with the capped path distance `capDist` on the two
grid coordinates) lifts, through arbitrary snakes `p` of length `L` and `q` of length `K`,
to a snake in `Q_{m+n+c}`.

`SnakeEscape.one_coordinate_escape_4_4` : for *every* pair of snakes of length `4`,
a single extra coordinate already gives a snake of length `29 ≥ 25 = (4+1)(4+1)`.
The witness is a 30-vertex induced path in `P_5 □ P_5 □ Q_1` found by exhaustive search.
-/

namespace SnakeEscape

/-- Capped path distance: `0` on the diagonal, `1` for neighbours, `2` otherwise. -/
def capDist (x y : ℕ) : ℕ := if x = y then 0 else if x + 1 = y ∨ y + 1 = x then 1 else 2

section

variable {ι : Type*} [Fintype ι] {p : ℕ → ι → Bool} {L : ℕ}

theorem IsSnake.capDist_le (hp : IsSnake p L) {x y : ℕ} (hx : x ≤ L) (hy : y ≤ L) :
    capDist x y ≤ hammingDist (p x) (p y) := by
  unfold capDist
  split_ifs with h1 h2
  · exact Nat.zero_le _
  · exact hp.dist_pos hx hy h1
  · exact hp.dist_two hx hy (by omega)

theorem IsSnake.capDist_eq (hp : IsSnake p L) {x y : ℕ} (hx : x ≤ L) (hy : y ≤ L)
    (h : capDist x y ≤ 1) : hammingDist (p x) (p y) = capDist x y := by
  unfold capDist at *
  split_ifs at * with h1 h2
  · subst h1; exact hammingDist_self _
  · rcases h2 with h2 | h2
    · subst h2; exact hp.dist_one hy
    · subst h2; rw [hammingDist_comm]; exact hp.dist_one hx
  · omega

end

/-- An induced path of length `N` in `P_{L+1} □ P_{K+1} □ Q_σ`, given by its coordinate
sequences `f`, `g` (grid positions) and `t` (separator bits). -/
def IsGridSnake {σ : Type*} [Fintype σ] (f g : ℕ → ℕ) (t : ℕ → σ → Bool) (N : ℕ) : Prop :=
  ∀ i j, i < j → j ≤ N →
    (j = i + 1 → capDist (f i) (f j) + capDist (g i) (g j) + hammingDist (t i) (t j) = 1) ∧
    (i + 1 < j → 2 ≤ capDist (f i) (f j) + capDist (g i) (g j) + hammingDist (t i) (t j))

/-- **Grid lifting lemma.**  Grid snakes lift through arbitrary snakes to hypercube snakes. -/
theorem lift_gridSnake {ι κ σ : Type*} [Fintype ι] [Fintype κ] [Fintype σ]
    {p : ℕ → ι → Bool} {q : ℕ → κ → Bool} {L K N : ℕ} (hp : IsSnake p L) (hq : IsSnake q K)
    {f g : ℕ → ℕ} {t : ℕ → σ → Bool} (hf : ∀ k ≤ N, f k ≤ L) (hg : ∀ k ≤ N, g k ≤ K)
    (hs : IsGridSnake f g t N) :
    IsSnake (fun k => Sum.elim (Sum.elim (p (f k)) (q (g k))) (t k)) N := by
  intro i j hij hj
  have hfi := hf i (by omega); have hfj := hf j hj
  have hgi := hg i (by omega); have hgj := hg j hj
  simp only [hammingDist_sumElim]
  have a1 := hp.capDist_le hfi hfj
  have a2 := hq.capDist_le hgi hgj
  refine ⟨fun h => ?_, fun h => ?_⟩
  · have e := (hs i j hij hj).1 h
    rw [hp.capDist_eq hfi hfj (by omega), hq.capDist_eq hgi hgj (by omega)]
    exact e
  · have e := (hs i j hij hj).2 h
    omega

/-- The 30-vertex induced path in `P_5 □ P_5 □ Q_1` (column, row, separator bit),
found by exhaustive depth-first search. -/
def path55 : List (ℕ × ℕ × Bool) :=
  [(0,0,false),(0,0,true),(1,0,true),(1,1,true),(1,1,false),(2,1,false),(2,0,false),
   (3,0,false),(4,0,false),(4,0,true),(4,1,true),(3,1,true),(3,2,true),(3,2,false),
   (4,2,false),(4,3,false),(4,3,true),(4,4,true),(3,4,true),(3,4,false),(2,4,false),
   (2,3,false),(2,3,true),(1,3,true),(1,4,true),(0,4,true),(0,4,false),(0,3,false),
   (0,2,false),(0,2,true)]

def f55 (k : ℕ) : ℕ := (path55.getD k (0, 0, false)).1
def g55 (k : ℕ) : ℕ := (path55.getD k (0, 0, false)).2.1
def t55 (k : ℕ) : Fin 1 → Bool := fun _ => (path55.getD k (0, 0, false)).2.2

theorem gridSnake55 : IsGridSnake f55 g55 t55 29 := by
  intro i j hij hj
  interval_cases j <;> interval_cases i <;> decide

/-- **One-coordinate escape at `L = K = 4`.**  For all snakes of length `4` in `Q_m` and
`Q_n`, there is a snake of length `29` (30 vertices, more than `(4+1)(4+1) = 25`) in
`Q_{m+n+1}`. -/
theorem one_coordinate_escape_4_4 {m n : ℕ} (p : ℕ → Fin m → Bool) (q : ℕ → Fin n → Bool)
    (hp : IsSnake p 4) (hq : IsSnake q 4) :
    ∃ s : ℕ → Fin (m + n + 1) → Bool, IsSnake s 29 := by
  let e : Fin (m + n + 1) ≃ (Fin m ⊕ Fin n) ⊕ Fin 1 :=
    finSumFinEquiv.symm.trans (Equiv.sumCongr finSumFinEquiv.symm (Equiv.refl _))
  have hf : ∀ k ≤ 29, f55 k ≤ 4 := by decide
  have hg : ∀ k ≤ 29, g55 k ≤ 4 := by decide
  exact ⟨_, (lift_gridSnake hp hq hf hg gridSnake55).comp_equiv e⟩

/-- A concrete snake of length `4` in `Q_3` (the maximum there), used to show the
hypotheses above are satisfiable. -/
def q3snake : ℕ → Fin 3 → Bool
  | 0 => ![false, false, false]
  | 1 => ![true, false, false]
  | 2 => ![true, true, false]
  | 3 => ![true, true, true]
  | _ => ![false, true, true]

theorem q3snake_isSnake : IsSnake q3snake 4 := by
  intro i j hij hj
  interval_cases j <;> interval_cases i <;> decide

/-- Instance of the `L = K = 4` test case: snakes of length `29` in `Q_7` (one separator
coordinate) and of length `28` in `Q_8` (two separator coordinates, general construction). -/
theorem escape_examples_4_4 :
    (∃ s : ℕ → Fin (3 + 3 + 1) → Bool, IsSnake s 29) ∧
      (∃ s : ℕ → Fin (3 + 3 + 2) → Bool, IsSnake s 28) :=
  ⟨one_coordinate_escape_4_4 _ _ q3snake_isSnake q3snake_isSnake,
    separator_escape _ _ 4 4 q3snake_isSnake q3snake_isSnake⟩

end SnakeEscape