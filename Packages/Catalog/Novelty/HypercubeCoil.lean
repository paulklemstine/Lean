/-
# Coils: induced cycles in the hypercube

A *coil* (also called a "snake-in-the-box cycle") is the cyclic analogue of a
snake: an induced cycle in `Q n`.  The catalog files `Computation.SnakeInTheBox`
and `Computation.SnakeMax` treat only the path case.  Coils are the objects that
carry the *tight* instances of the counting bound: the bound
`|S| ≤ 3 · 2 ^ (n-2)` for induced subgraphs of maximum degree two, proved in
`Novelty.HypercubeInducedDegree`, is attained in `Q 3` — not by a snake (which
has only five vertices) but by the induced hexagon, which has six.

This file develops:

* the structure `Coil n L` (an induced cycle with `L` vertices and `L` edges);
* injectivity of the vertex indexing, the cyclic adjacency lemma `index_adj`,
  and the maximum-degree-two bound `degree_le_two`;
* the counting ceiling `Coil.card_le : L ≤ 3 · 2 ^ (n - 2)` for `n ≥ 3`,
  hence `no induced Hamiltonian cycle` in `Q n` for `n ≥ 3`;
* parity: every coil has **even** length;
* the exact classifications
  `Nonempty (Coil 2 L) ↔ L = 4` and `Nonempty (Coil 3 L) ↔ L = 4 ∨ L = 6`,
  so the longest induced cycle in `Q 3` is the hexagon and the counting bound
  is **sharp** in dimension three;
* the lift `Coil n L → Coil (n+1) (L+2)` (re-route one edge through the new
  layer) giving induced cycles of length `2n` in `Q n` for all `n ≥ 3`;
* the maximal coil length function `maxCoil`, with `2n ≤ maxCoil n ≤ 3·2^(n-2)`
  for `n ≥ 3`, `maxCoil 2 = 4`, `maxCoil 3 = 6`, and the comparison
  `maxCoil n ≤ maxLen n + 2` with the maximal snake length of the catalog.
-/
import Mathlib
import Computation.SnakeInTheBox
import Computation.SnakeMax
import Novelty.HypercubeInducedDegree

namespace SnakeInTheBox

open Finset

variable {n L : ℕ}

/-! ## The structure -/

/-- A *coil* of length `L` in `Q n`: an induced cycle `v 0, v 1, …, v (L-1)`.
Consecutive vertices (cyclically) are adjacent, and any two vertices that are not
cyclically consecutive are at Hamming distance at least two. -/
structure Coil (n L : ℕ) where
  /-- The vertices of the coil, indexed by `ℕ` (only `0 … L-1` matter). -/
  v : ℕ → Cube n
  /-- A cycle needs at least four vertices. -/
  hL : 4 ≤ L
  /-- Consecutive vertices are adjacent. -/
  step : ∀ i, i + 1 < L → Adj (v i) (v (i + 1))
  /-- The cycle closes up. -/
  close : Adj (v (L - 1)) (v 0)
  /-- Vertices that are not cyclically consecutive are at Hamming distance ≥ 2. -/
  chord : ∀ i j, i + 2 ≤ j → j < L → j + 2 ≤ i + L → 2 ≤ hammingDist (v i) (v j)

/-! ## Basic structure theory -/

/-- Distinct indices give distinct vertices (the case `i < j`). -/
theorem Coil.ne_of_lt (c : Coil n L) {i j : ℕ} (hij : i < j) (hj : j < L) :
    c.v i ≠ c.v j := by
  by_cases h2 : i + 2 ≤ j
  · by_cases h3 : j + 2 ≤ i + L
    · exact (two_le_hammingDist_iff.mp (c.chord i j h2 hj h3)).1
    · have hi0 : i = 0 := by omega
      have hjL : j = L - 1 := by omega
      intro he
      have hadj : Adj (c.v j) (c.v 0) := by rw [hjL]; exact c.close
      rw [hi0] at he
      rw [← he] at hadj
      exact adj_irrefl _ hadj
  · have hj1 : j = i + 1 := by omega
    intro he
    have hadj : Adj (c.v i) (c.v j) := by rw [hj1]; exact c.step i (by omega)
    rw [he] at hadj
    exact adj_irrefl _ hadj

/-- The vertex indexing of a coil is injective on `{0, …, L-1}`. -/
theorem Coil.injOn (c : Coil n L) {i j : ℕ} (hi : i < L) (hj : j < L)
    (he : c.v i = c.v j) : i = j := by
  rcases lt_trichotomy i j with h | h | h
  · exact absurd he (c.ne_of_lt h hj)
  · exact h
  · exact absurd he.symm (c.ne_of_lt h hi)

/-- The vertex set of a coil. -/
def Coil.vset (c : Coil n L) : Finset (Cube n) := (range L).image c.v

theorem Coil.card_vset (c : Coil n L) : c.vset.card = L := by
  rw [Coil.vset, Finset.card_image_of_injOn, Finset.card_range]
  intro i hi j hj he
  exact c.injOn (Finset.mem_range.mp hi) (Finset.mem_range.mp hj) he

theorem Coil.mem_vset (c : Coil n L) {i : ℕ} (hi : i < L) : c.v i ∈ c.vset :=
  Finset.mem_image.mpr ⟨i, Finset.mem_range.mpr hi, rfl⟩

/-- Two coil vertices are cube-adjacent only if their indices are cyclically consecutive. -/
theorem Coil.index_adj (c : Coil n L) {i j : ℕ} (hi : i < L) (hj : j < L)
    (hadj : Adj (c.v i) (c.v j)) :
    j = i + 1 ∨ i = j + 1 ∨ (i = 0 ∧ j = L - 1) ∨ (j = 0 ∧ i = L - 1) := by
  have hd : hammingDist (c.v i) (c.v j) = 1 := hammingDist_of_adj hadj
  rcases Nat.lt_or_ge i j with h | h
  · by_cases h2 : i + 2 ≤ j
    · by_cases h3 : j + 2 ≤ i + L
      · have := c.chord i j h2 hj h3
        omega
      · exact Or.inr (Or.inr (Or.inl ⟨by omega, by omega⟩))
    · exact Or.inl (by omega)
  · have hne : i ≠ j := by
      intro he; rw [he] at hadj; exact adj_irrefl _ hadj
    have hji : j < i := by omega
    by_cases h2 : j + 2 ≤ i
    · by_cases h3 : i + 2 ≤ j + L
      · have hc := c.chord j i h2 hi h3
        rw [hammingDist_comm] at hc
        omega
      · exact Or.inr (Or.inr (Or.inr ⟨by omega, by omega⟩))
    · exact Or.inr (Or.inl (by omega))

/-- Every coil vertex has at most two cube neighbours on the coil. -/
theorem Coil.degree_le_two (c : Coil n L) {x : Cube n} (hx : x ∈ c.vset) :
    (c.vset.filter fun y => Adj x y).card ≤ 2 := by
  rw [Coil.vset] at hx
  obtain ⟨i, hi_mem, rfl⟩ := Finset.mem_image.mp hx
  rw [Finset.mem_range] at hi_mem
  have hsub : (c.vset.filter fun y => Adj (c.v i) y) ⊆
      {c.v (if i = 0 then L - 1 else i - 1), c.v (if i + 1 = L then 0 else i + 1)} := by
    intro y hy
    rw [Finset.mem_filter] at hy
    obtain ⟨hyv, hadj⟩ := hy
    rw [Coil.vset] at hyv
    obtain ⟨j, hj_mem, rfl⟩ := Finset.mem_image.mp hyv
    rw [Finset.mem_range] at hj_mem
    rcases c.index_adj hi_mem hj_mem hadj with h | h | ⟨h1, h2⟩ | ⟨h1, h2⟩
    · have hL : ¬ (i + 1 = L) := by omega
      simp [hL, h]
    · have h0 : ¬ (i = 0) := by omega
      have hj : j = i - 1 := by omega
      simp [h0, hj]
    · simp [h1, h2]
    · have hL : i + 1 = L := by omega
      simp [hL, h1]
  calc (c.vset.filter fun y => Adj (c.v i) y).card
      ≤ ({c.v (if i = 0 then L - 1 else i - 1), c.v (if i + 1 = L then 0 else i + 1)} :
          Finset (Cube n)).card := Finset.card_le_card hsub
    _ ≤ 2 := Finset.card_insert_le _ _

/-! ## The counting ceiling -/

/-- The vertex set of a coil has maximum induced degree two. -/
theorem Coil.indeg_le_two (c : Coil n L) : ∀ x ∈ c.vset, indeg c.vset x ≤ 2 :=
  fun _ hx => c.degree_le_two hx

/-- **Counting ceiling for coils.**  For `n ≥ 3` an induced cycle of `Q n` has at most
`3 · 2 ^ (n - 2)` vertices. -/
theorem Coil.card_le (c : Coil n L) (hn : 3 ≤ n) : L ≤ 3 * 2 ^ (n - 2) := by
  have := card_le_of_indeg_le_two hn c.indeg_le_two
  rwa [c.card_vset] at this

/-- The master counting inequality for coils. -/
theorem Coil.count (c : Coil n L) : (n - 2) * L + n * L ≤ n * 2 ^ n := by
  have := card_mul_le_of_indeg_le c.indeg_le_two
  rwa [c.card_vset] at this

/-- A coil omits at least `2 ^ (n-2)` vertices of the cube (`n ≥ 3`). -/
theorem Coil.omits (c : Coil n L) (hn : 3 ≤ n) : 2 ^ (n - 2) ≤ c.vsetᶜ.card := by
  have hcard : c.vsetᶜ.card = 2 ^ n - L := by
    rw [Finset.card_compl, c.card_vset]
    simp [Finset.card_univ]
  have h := c.card_le hn
  have h2 : 2 ^ n = 4 * 2 ^ (n - 2) := by
    have : n = 2 + (n - 2) := by omega
    conv_lhs => rw [this, pow_add]
    norm_num
  omega

/-- **No induced Hamiltonian cycle.**  For `n ≥ 3` no induced cycle of `Q n` covers all
vertices. -/
theorem Coil.not_hamiltonian (c : Coil n L) (hn : 3 ≤ n) : c.vset ≠ univ := by
  intro heq
  have h := c.omits hn
  rw [heq] at h
  simp at h

/-- In `Q 2` a coil has exactly four vertices. -/
theorem Coil.length_dim_two (c : Coil 2 L) : L = 4 := by
  have h := c.count
  have := c.hL
  norm_num at h
  omega

/-- In `Q 3` a coil has at most six vertices. -/
theorem Coil.length_le_dim_three (c : Coil 3 L) : L ≤ 6 := by
  have h := c.count
  norm_num at h
  omega

/-! ## Parity: coils have even length -/

theorem par_of_adj {x y : Cube n} (h : Adj x y) : par y = par x + 1 := by
  obtain ⟨i, rfl⟩ := h
  exact par_flipAt x i

theorem Coil.par_v (c : Coil n L) : ∀ i, i < L → par (c.v i) = par (c.v 0) + i := by
  intro i
  induction i with
  | zero => intro _; simp
  | succ k ih =>
    intro hk
    have hk' : k < L := by omega
    rw [par_of_adj (c.step k hk), ih hk']
    push_cast
    ring

/-- **Every coil has even length.**  The parity of the vertices alternates along the
cycle, so the cycle must close after an even number of steps. -/
theorem Coil.even_length (c : Coil n L) : Even L := by
  have hL := c.hL
  have h1 : par (c.v (L - 1)) = par (c.v 0) + ((L - 1 : ℕ) : ZMod 2) :=
    c.par_v (L - 1) (by omega)
  have h2 : par (c.v 0) = par (c.v (L - 1)) + 1 := par_of_adj c.close
  rw [h1] at h2
  have h3 : ((L - 1 : ℕ) : ZMod 2) + 1 = 0 := by
    linear_combination -h2
  have h4 : ((L : ℕ) : ZMod 2) = 0 := by
    have hcast : ((L : ℕ) : ZMod 2) = ((L - 1 : ℕ) : ZMod 2) + 1 := by
      have : L = (L - 1) + 1 := by omega
      conv_lhs => rw [this]
      push_cast
      ring
    rw [hcast, h3]
  exact (ZMod.natCast_eq_zero_iff_even).mp h4

/-! ## Explicit coils in low dimensions -/

/-- The square in `Q 2`. -/
def coil2v : ℕ → Cube 2
  | 0 => ![false, false]
  | 1 => ![false, true]
  | 2 => ![true, true]
  | 3 => ![true, false]
  | _ => ![false, false]

/-- The induced square of `Q 2`. -/
def coil2 : Coil 2 4 where
  v := coil2v
  hL := le_rfl
  step i hi := by
    have hub : i < 4 := by omega
    interval_cases i <;> decide
  close := by decide
  chord i j h1 h2 h3 := by
    have hub : i < 4 := by omega
    have hjb : j < 4 := by omega
    interval_cases j <;> interval_cases i <;> first | omega | decide

/-- An induced square in `Q 3` (a two-dimensional face). -/
def coil3av : ℕ → Cube 3
  | 0 => ![false, false, false]
  | 1 => ![false, false, true]
  | 2 => ![false, true, true]
  | 3 => ![false, true, false]
  | _ => ![false, false, false]

/-- The induced square of `Q 3`. -/
def coil3a : Coil 3 4 where
  v := coil3av
  hL := le_rfl
  step i hi := by
    have hub : i < 4 := by omega
    interval_cases i <;> decide
  close := by decide
  chord i j h1 h2 h3 := by
    have hub : i < 4 := by omega
    have hjb : j < 4 := by omega
    interval_cases j <;> interval_cases i <;> first | omega | decide

/-- The induced hexagon in `Q 3`. -/
def coil3v : ℕ → Cube 3
  | 0 => ![false, false, false]
  | 1 => ![false, false, true]
  | 2 => ![false, true, true]
  | 3 => ![true, true, true]
  | 4 => ![true, true, false]
  | 5 => ![true, false, false]
  | _ => ![false, false, false]

/-- The induced hexagon of `Q 3`: the longest induced cycle in the three-cube. -/
def coil3 : Coil 3 6 where
  v := coil3v
  hL := by omega
  step i hi := by
    have hub : i < 6 := by omega
    interval_cases i <;> decide
  close := by decide
  chord i j h1 h2 h3 := by
    have hub : i < 6 := by omega
    have hjb : j < 6 := by omega
    interval_cases j <;> interval_cases i <;> first | omega | decide

/-! ## Exact classification in dimensions two and three -/

/-- In `Q 2` the only induced cycle is the whole square. -/
theorem coil_max_dim_two (L : ℕ) : Nonempty (Coil 2 L) ↔ L = 4 :=
  ⟨fun ⟨c⟩ => c.length_dim_two, fun h => ⟨h ▸ coil2⟩⟩

/-- **The longest induced cycle in `Q 3` is the hexagon.**  The achievable induced cycle
lengths in the three-cube are exactly four and six. -/
theorem coil_max_dim_three (L : ℕ) : Nonempty (Coil 3 L) ↔ (L = 4 ∨ L = 6) := by
  constructor
  · rintro ⟨c⟩
    have h1 := c.hL
    have h2 := c.length_le_dim_three
    have h3 := c.even_length
    rw [Nat.even_iff] at h3
    omega
  · rintro (rfl | rfl)
    · exact ⟨coil3a⟩
    · exact ⟨coil3⟩

/-! ## Coils, snakes and dimension lifts -/

/-- Deleting one vertex of a coil leaves a snake. -/
def Coil.toSnake (c : Coil n L) : Snake n (L - 2) where
  v := c.v
  step i hi := c.step i (by have := c.hL; omega)
  chord i j hj hij := by
    have hL := c.hL
    exact c.chord i j hij (by omega) (by omega)

/-- A coil of `Q m` embeds into `Q n` for `m ≤ n`. -/
def Coil.embed {m : ℕ} (c : Coil m L) (hmn : m ≤ n) : Coil n L where
  v := fun i => extend m n (c.v i)
  hL := c.hL
  step i hi := adj_extend hmn (c.step i hi)
  close := adj_extend hmn c.close
  chord i j h1 h2 h3 := by
    rw [hammingDist_extend hmn]
    exact c.chord i j h1 h2 h3

/-- Flipping a fixed coordinate preserves adjacency. -/
theorem adj_flipAt {x y : Cube n} (i : Fin n) (h : Adj x y) :
    Adj (flipAt x i) (flipAt y i) := by
  apply adj_of_hammingDist
  rw [hammingDist_flipAt_flipAt]
  exact hammingDist_of_adj h

/-- The vertex sequence of the lifted coil: the old cycle in the layer `xₙ = 0`, with the
edge from `v (L-2)` to `v (L-1)` re-routed through the layer `xₙ = 1`. -/
def liftCV (c : Coil n L) : ℕ → Cube (n + 1) := fun i =>
  if i ≤ L - 2 then extend n (n + 1) (c.v i)
  else if i = L - 1 then flipAt (extend n (n + 1) (c.v (L - 2))) (Fin.last n)
  else if i = L then flipAt (extend n (n + 1) (c.v (L - 1))) (Fin.last n)
  else flipAt (extend n (n + 1) (c.v 0)) (Fin.last n)

theorem liftCV_low (c : Coil n L) {i : ℕ} (hi : i ≤ L - 2) :
    liftCV c i = extend n (n + 1) (c.v i) := by
  simp [liftCV, hi]

theorem liftCV_a (c : Coil n L) :
    liftCV c (L - 1) = flipAt (extend n (n + 1) (c.v (L - 2))) (Fin.last n) := by
  have hL := c.hL
  have h1 : ¬ (L - 1 ≤ L - 2) := by omega
  simp [liftCV, h1]

theorem liftCV_b (c : Coil n L) :
    liftCV c L = flipAt (extend n (n + 1) (c.v (L - 1))) (Fin.last n) := by
  have hL := c.hL
  have h1 : ¬ (L ≤ L - 2) := by omega
  have h2 : ¬ (L = L - 1) := by omega
  simp [liftCV, h1, h2]

theorem liftCV_c (c : Coil n L) :
    liftCV c (L + 1) = flipAt (extend n (n + 1) (c.v 0)) (Fin.last n) := by
  have hL := c.hL
  have h1 : ¬ (L + 1 ≤ L - 2) := by omega
  have h2 : ¬ (L + 1 = L - 1) := by omega
  simp [liftCV, h1, h2]

/-- **Dimension lift for coils.**  A coil of length `L` in `Q n` yields a coil of length
`L + 2` in `Q (n+1)`: re-route the last edge of the cycle through the new layer. -/
def Coil.lift (c : Coil n L) : Coil (n + 1) (L + 2) where
  v := liftCV c
  hL := by have := c.hL; omega
  step i hi := by
    have hL := c.hL
    rcases Nat.lt_or_ge i (L - 2) with h | h
    · rw [liftCV_low c (by omega), liftCV_low c (by omega)]
      exact adj_extend (by omega) (c.step i (by omega))
    rcases Nat.eq_or_lt_of_le h with h2 | h2
    · -- i = L - 2 : step into the new layer
      have hi1 : L - 2 + 1 = L - 1 := by omega
      rw [← h2, liftCV_low c le_rfl, hi1, liftCV_a c]
      exact ⟨Fin.last n, rfl⟩
    rcases Nat.lt_or_ge i (L - 1) with h3 | h3
    · omega
    rcases Nat.eq_or_lt_of_le h3 with h4 | h4
    · -- i = L - 1
      have hi1 : L - 1 + 1 = L := by omega
      rw [← h4, liftCV_a c, hi1, liftCV_b c]
      refine adj_flipAt _ (adj_extend (by omega) ?_)
      have heq : L - 2 + 1 = L - 1 := by omega
      have hstep := c.step (L - 2) (by omega)
      rwa [heq] at hstep
    · -- i = L
      have hiL : i = L := by omega
      subst hiL
      rw [liftCV_b c, liftCV_c c]
      exact adj_flipAt _ (adj_extend (by omega) c.close)
  close := by
    have hL := c.hL
    have h : L + 2 - 1 = L + 1 := by omega
    rw [h, liftCV_c c, liftCV_low c (by omega)]
    exact adj_symm ⟨Fin.last n, rfl⟩
  chord i j h1 h2 h3 := by
    have hL := c.hL
    have hdist : ∀ a b : ℕ, a < L → b < L → a ≠ b → c.v a ≠ c.v b := by
      intro a b ha hb hab he
      exact hab (c.injOn ha hb he)
    rcases Nat.lt_or_ge j (L - 1) with hj | hj
    · -- both in the bottom layer
      rw [liftCV_low c (by omega), liftCV_low c (by omega), hammingDist_extend (by omega)]
      exact c.chord i j h1 (by omega) (by omega)
    rcases Nat.eq_or_lt_of_le hj with hj1 | hj1
    · -- j = L - 1
      rw [← hj1, liftCV_a c, liftCV_low c (by omega)]
      exact two_le_dist_extend_flip (hdist i (L - 2) (by omega) (by omega) (by omega))
    rcases Nat.lt_or_ge j L with hj2 | hj2
    · omega
    rcases Nat.eq_or_lt_of_le hj2 with hj3 | hj3
    · -- j = L
      rw [← hj3, liftCV_b c, liftCV_low c (by omega)]
      exact two_le_dist_extend_flip (hdist i (L - 1) (by omega) (by omega) (by omega))
    · -- j = L + 1
      have hjL : j = L + 1 := by omega
      subst hjL
      rw [liftCV_c c]
      rcases Nat.lt_or_ge i (L - 1) with hi | hi
      · rw [liftCV_low c (by omega)]
        exact two_le_dist_extend_flip (hdist i 0 (by omega) (by omega) (by omega))
      · -- i = L - 1, both new vertices
        have hiL : i = L - 1 := by omega
        subst hiL
        rw [liftCV_a c, hammingDist_flipAt_flipAt, hammingDist_extend (by omega)]
        have := c.chord 0 (L - 2) (by omega) (by omega) (by omega)
        rwa [hammingDist_comm] at this

/-- Induced cycles of length `2n` exist in `Q n` for every `n ≥ 3`. -/
theorem exists_coil_two_mul : ∀ n, 3 ≤ n → Nonempty (Coil n (2 * n)) := by
  intro n
  induction n with
  | zero => intro h; omega
  | succ m ih =>
    intro _
    rcases Nat.lt_or_ge m 3 with hm | hm
    · have hm3 : m = 2 := by omega
      subst hm3
      exact ⟨coil3⟩
    · obtain ⟨c⟩ := ih hm
      have h : 2 * m + 2 = 2 * (m + 1) := by ring
      exact ⟨h ▸ c.lift⟩

/-! ## The maximal coil length function -/

/-- The set of achievable coil lengths in `Q n`. -/
def coilLengths (n : ℕ) : Set ℕ := {L | Nonempty (Coil n L)}

theorem coilLengths_bddAbove (n : ℕ) : BddAbove (coilLengths n) := by
  refine ⟨2 ^ n, ?_⟩
  rintro L ⟨c⟩
  have h1 : c.vset.card = L := c.card_vset
  have h2 : c.vset.card ≤ Fintype.card (Cube n) := by
    simpa using Finset.card_le_univ c.vset
  have h3 : Fintype.card (Cube n) = 2 ^ n := by simp
  omega

/-- The maximal length of an induced cycle in `Q n` (zero if there is none). -/
noncomputable def maxCoil (n : ℕ) : ℕ := sSup (coilLengths n)

theorem le_maxCoil (c : Coil n L) : L ≤ maxCoil n :=
  le_csSup (coilLengths_bddAbove n) ⟨c⟩

theorem coilLengths_nonempty (hn : 2 ≤ n) : (coilLengths n).Nonempty :=
  ⟨4, ⟨coil2.embed hn⟩⟩

/-- The maximal coil length is attained. -/
theorem exists_coil_maxCoil (hn : 2 ≤ n) : Nonempty (Coil n (maxCoil n)) := by
  have h := Nat.sSup_mem (coilLengths_nonempty hn) (coilLengths_bddAbove n)
  exact h

/-- **Lower bound.**  `Q n` contains an induced cycle with `2n` vertices (`n ≥ 3`). -/
theorem maxCoil_lower (hn : 3 ≤ n) : 2 * n ≤ maxCoil n := by
  obtain ⟨c⟩ := exists_coil_two_mul n hn
  exact le_maxCoil c

/-- **Upper bound.**  Every induced cycle of `Q n` has at most `3 · 2^(n-2)` vertices. -/
theorem maxCoil_upper (hn : 3 ≤ n) : maxCoil n ≤ 3 * 2 ^ (n - 2) := by
  obtain ⟨c⟩ := exists_coil_maxCoil (by omega : 2 ≤ n)
  exact c.card_le hn

/-- The maximal coil length is even. -/
theorem maxCoil_even (hn : 2 ≤ n) : Even (maxCoil n) := by
  obtain ⟨c⟩ := exists_coil_maxCoil hn
  exact c.even_length

/-- `maxCoil 2 = 4`. -/
theorem maxCoil_two : maxCoil 2 = 4 := by
  obtain ⟨c⟩ := exists_coil_maxCoil (le_rfl : 2 ≤ 2)
  have h1 : maxCoil 2 = 4 := c.length_dim_two
  exact h1

/-- **`maxCoil 3 = 6`: the hexagon is optimal in the three-cube.** -/
theorem maxCoil_three : maxCoil 3 = 6 := by
  have hle : maxCoil 3 ≤ 6 := by
    obtain ⟨c⟩ := exists_coil_maxCoil (by omega : 2 ≤ 3)
    exact c.length_le_dim_three
  have hge : 6 ≤ maxCoil 3 := le_maxCoil coil3
  omega

/-- Below dimension two there is no coil at all. -/
theorem coilLengths_eq_empty (hn : n < 2) : coilLengths n = ∅ := by
  ext L
  simp only [coilLengths, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
  rintro ⟨c⟩
  have h1 : c.vset.card = L := c.card_vset
  have h2 : c.vset.card ≤ Fintype.card (Cube n) := by
    simpa using Finset.card_le_univ c.vset
  have h3 : Fintype.card (Cube n) = 2 ^ n := by simp
  have h4 : (2 : ℕ) ^ n < 4 := by
    interval_cases n <;> norm_num
  have := c.hL
  omega

theorem maxCoil_eq_zero (hn : n < 2) : maxCoil n = 0 := by
  simp [maxCoil, coilLengths_eq_empty hn]

/-- Each new dimension buys two more vertices on the longest induced cycle. -/
theorem maxCoil_succ_ge_two (hn : 2 ≤ n) : maxCoil n + 2 ≤ maxCoil (n + 1) := by
  obtain ⟨c⟩ := exists_coil_maxCoil hn
  exact le_maxCoil c.lift

/-- The maximal induced cycle length is monotone in the dimension. -/
theorem maxCoil_mono : Monotone maxCoil := by
  refine monotone_nat_of_le_succ fun k => ?_
  rcases Nat.lt_or_ge k 2 with hk | hk
  · rw [maxCoil_eq_zero hk]
    exact Nat.zero_le _
  · have := maxCoil_succ_ge_two hk
    omega

/-- Coils are longer than snakes by at most two: deleting a vertex of a coil gives a snake. -/
theorem maxCoil_le_maxLen_add_two (n : ℕ) : maxCoil n ≤ maxLen n + 2 := by
  rcases Nat.lt_or_ge n 2 with hn | hn
  · simp [maxCoil_eq_zero hn]
  · obtain ⟨c⟩ := exists_coil_maxCoil hn
    have h := le_maxLen c.toSnake
    have := c.hL
    omega

/-- Package: the two-sided bound for the maximal induced cycle length. -/
theorem maxCoil_bounds (hn : 3 ≤ n) :
    2 * n ≤ maxCoil n ∧ maxCoil n ≤ 3 * 2 ^ (n - 2) ∧ Even (maxCoil n) :=
  ⟨maxCoil_lower hn, maxCoil_upper hn, maxCoil_even (by omega)⟩

/-! ## Sharpness of the density theorem in dimension three -/

/-- **The bound `card_le_of_indeg_le_two` is attained.**  In `Q 3` there is a set of
`3 · 2 ^ (3-2) = 6` vertices inducing a subgraph of maximum degree two, namely the
hexagon; no snake achieves this (a snake in `Q 3` has at most five vertices). -/
theorem density_bound_sharp_dim_three :
    ∃ S : Finset (Cube 3), (∀ x ∈ S, indeg S x ≤ 2) ∧ S.card = 3 * 2 ^ (3 - 2) := by
  refine ⟨coil3.vset, coil3.indeg_le_two, ?_⟩
  rw [coil3.card_vset]
  norm_num

end SnakeInTheBox