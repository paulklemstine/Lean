/-
# Snake-in-the-Box: structure of induced paths in the hypercube

A *snake* in the hypercube `Q n` is an induced (chordless) path: a sequence of
vertices `v 0, v 1, …, v L` in which consecutive vertices are adjacent and any
two vertices at index distance at least two are at Hamming distance at least
two (i.e. non-adjacent and distinct).

This file develops, in a chain, the basic structure theory of snakes and proves
a **rigidity theorem near the Boolean-cube ceiling**:

> for every `n ≥ 3`, a snake in `Q n` omits at least `2 ^ (n - 2)` vertices.

The proof is a double count of the edge boundary of the vertex set of a snake:
chordlessness forces every snake vertex to have at most two of its `n` cube
neighbours on the snake, so the snake sends at least `(n - 2) · |S|` edges out
of `S`, while the complement can absorb at most `n · |Sᶜ|` of them.
-/
import Mathlib

namespace SnakeInTheBox

open Finset

/-- Vertices of the `n`-dimensional hypercube. -/
abbrev Cube (n : ℕ) := Fin n → Bool

variable {n : ℕ}

/-- Flip the `i`-th coordinate of a cube vertex. -/
def flipAt (x : Cube n) (i : Fin n) : Cube n := fun j => if j = i then !x j else x j

/-- Hypercube adjacency: `y` is obtained from `x` by flipping one coordinate. -/
def Adj (x y : Cube n) : Prop := ∃ i, y = flipAt x i

instance : DecidableEq (Cube n) := by infer_instance

instance (x y : Cube n) : Decidable (Adj x y) := by
  unfold Adj; infer_instance

/-- A snake of length `L` (number of edges) in `Q n`: an induced path. -/
structure Snake (n L : ℕ) where
  /-- The vertices of the snake, indexed by `ℕ` (only `0 … L` matter). -/
  v : ℕ → Cube n
  /-- Consecutive vertices are adjacent. -/
  step : ∀ i, i < L → Adj (v i) (v (i + 1))
  /-- Vertices at index distance ≥ 2 are at Hamming distance ≥ 2. -/
  chord : ∀ i j, j ≤ L → i + 2 ≤ j → 2 ≤ hammingDist (v i) (v j)

/-! ## Step 1: elementary properties of cube adjacency -/

theorem flipAt_apply_self (x : Cube n) (i : Fin n) : flipAt x i i = !x i := by
  simp [flipAt]

theorem flipAt_apply_of_ne (x : Cube n) {i j : Fin n} (h : j ≠ i) : flipAt x i j = x j := by
  simp [flipAt, h]

/-- Adjacent vertices are at Hamming distance one. -/
theorem hammingDist_of_adj {x y : Cube n} (h : Adj x y) : hammingDist x y = 1 := by
  obtain ⟨i, rfl⟩ := h
  rw [hammingDist]
  have hset : (univ.filter fun j => x j ≠ flipAt x i j) = {i} := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
    constructor
    · intro hj; by_contra hne; exact hj (flipAt_apply_of_ne x hne).symm
    · intro hj; subst hj; simp [flipAt_apply_self]
  simp [hset]

/-- Vertices at Hamming distance one are adjacent. -/
theorem adj_of_hammingDist {x y : Cube n} (h : hammingDist x y = 1) : Adj x y := by
  rw [hammingDist] at h
  obtain ⟨i, hi⟩ := Finset.card_eq_one.mp h
  use i
  rw [hi] at h
  ext j
  rw [flipAt]
  by_cases hj : j = i
  · simp [hj]
    have hne : x i ≠ y i := by
      have : i ∈ ({i} : Finset (Fin n)) := Finset.mem_singleton_self i
      rw [← hi] at this
      simp at this
      exact this
    cases hx : x i <;> cases hy : y i <;> simp_all
  · simp only [hj, ↓reduceIte]
    have hne : x j = y j := by
      by_contra hne
      have : j ∈ ({i} : Finset (Fin n)) := by rw [← hi]; simp [hne]
      simp [hj] at this
    exact hne.symm

theorem adj_irrefl (x : Cube n) : ¬ Adj x x := by
  intro ⟨i, hx⟩
  have := congr_fun hx i
  simp [flipAt_apply_self] at this

theorem adj_symm {x y : Cube n} (h : Adj x y) : Adj y x := by
  obtain ⟨i, hi⟩ := h
  use i
  ext j
  by_cases hj : j = i
  · simp [hj, hi, flipAt]
  · simp [hj, hi, flipAt]

/-- Hamming distance at least two means: distinct and non-adjacent. -/
theorem two_le_hammingDist_iff {x y : Cube n} :
    2 ≤ hammingDist x y ↔ x ≠ y ∧ ¬ Adj x y := by
  constructor
  · intro h
    refine ⟨?_, ?_⟩
    · intro heq
      rw [heq] at h
      simp at h
    · intro hadj
      have := hammingDist_of_adj hadj
      omega
  · intro ⟨hne, hnadj⟩
    have h1 : 1 ≤ hammingDist x y := by
      by_contra h
      push_neg at h
      exact hne (hammingDist_eq_zero.mp (Nat.lt_one_iff.mp h))
    have h2 : hammingDist x y ≠ 1 := fun h => hnadj (adj_of_hammingDist h)
    omega

/-- The sphere of radius one around `x` has exactly `n` points. -/
theorem card_sphere (x : Cube n) : (univ.filter fun y => Adj x y).card = n := by
  have h_eq : (univ.filter fun y => Adj x y) = (Finset.univ.image fun i => flipAt x i) := by
    ext y
    simp [Adj]
    constructor
    · rintro ⟨i, rfl⟩; exact ⟨i, rfl⟩
    · rintro ⟨i, rfl⟩; exact ⟨i, rfl⟩
  rw [h_eq]
  rw [card_image_of_injective]
  · simp
  · intro i j hij
    by_contra hne
    have hne' : j ≠ i := Ne.symm hne
    have : (flipAt x i) j ≠ (flipAt x j) j := by
      simp [flipAt_apply_self, flipAt_apply_of_ne x hne']
    exact this (congr_fun hij j)

/-! ## Step 2: elementary properties of snakes -/

variable {L : ℕ}

/-- Chordlessness, in adjacency form. -/
theorem Snake.not_adj (s : Snake n L) {i j : ℕ} (hj : j ≤ L) (hij : i + 2 ≤ j) :
    ¬ Adj (s.v i) (s.v j) :=
  (two_le_hammingDist_iff.1 (s.chord i j hj hij)).2

/-- Distinctness of far-apart snake vertices. -/
theorem Snake.ne_of_add_two_le (s : Snake n L) {i j : ℕ} (hj : j ≤ L) (hij : i + 2 ≤ j) :
    s.v i ≠ s.v j :=
  (two_le_hammingDist_iff.1 (s.chord i j hj hij)).1

/-- The vertices of a snake are pairwise distinct. -/
theorem Snake.injOn (s : Snake n L) :
    Set.InjOn s.v (Set.Iic L) := by
  intro i hi j hj hij
  by_contra hne
  rcases Nat.lt_or_gt_of_ne hne with hlt | hgt
  · -- i < j, so j - i ≥ 1
    by_cases hge : j - i ≥ 2
    · have := s.ne_of_add_two_le hj (by omega : i + 2 ≤ j)
      exact this hij
    · -- j - i = 1, so they are consecutive and adjacent
      have hji : j = i + 1 := by omega
      rw [hji] at hij
      -- Adjacent vertices are equal, contradicts adj_irrefl
      have hilt : i < L := by simp [Set.Iic] at hj; omega
      have hadj := s.step i hilt
      rw [hij] at hadj
      exact adj_irrefl _ hadj
  · -- j < i, symmetric argument
    by_cases hge : i - j ≥ 2
    · have := s.ne_of_add_two_le hi (by omega : j + 2 ≤ i)
      exact this hij.symm
    · -- i = j + 1
      have hij' : i = j + 1 := by omega
      rw [hij'] at hij
      -- Adjacent vertices are equal, contradicts adj_irrefl
      have hjlt : j < L := by simp [Set.Iic] at hi; omega
      have hadj := adj_symm (s.step j hjlt)
      rw [hij] at hadj
      exact adj_irrefl _ hadj

/-- The vertex set of a snake. -/
def Snake.vset (s : Snake n L) : Finset (Cube n) := (range (L + 1)).image s.v

theorem Snake.card_vset (s : Snake n L) : s.vset.card = L + 1 := by
  rw [Snake.vset, card_image_of_injOn]
  · simp
  · exact s.injOn.mono (fun i hi => Finset.mem_range_succ_iff.mp hi)

theorem Snake.mem_vset (s : Snake n L) {i : ℕ} (hi : i ≤ L) : s.v i ∈ s.vset := by
  rw [Snake.vset]
  exact Finset.mem_image_of_mem s.v (Finset.mem_range.mpr (Nat.lt_succ_of_le hi))

/-- If a snake vertex is adjacent to another snake vertex, their indices are consecutive. -/
theorem Snake.index_adj (s : Snake n L) {i j : ℕ} (hi : i ≤ L) (hj : j ≤ L)
    (h : Adj (s.v i) (s.v j)) : j = i + 1 ∨ i = j + 1 := by
  by_contra hne
  push_neg at hne
  have hne' : i ≠ j := fun hij => by rw [hij] at h; exact adj_irrefl _ h
  have hcases : j ≥ i + 2 ∨ i ≥ j + 2 := by omega
  rcases hcases with hij | hji
  · exact Snake.not_adj s hj hij h
  · exact Snake.not_adj s hi hji (adj_symm h)

/-! ## Step 3: parity -/

/-- The parity (weight mod two) of a cube vertex. -/
def par (x : Cube n) : ZMod 2 := ∑ i : Fin n, if x i then (1 : ZMod 2) else 0

theorem par_flipAt (x : Cube n) (i : Fin n) : par (flipAt x i) = par x + 1 := by
  unfold par flipAt
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
  simp (config := { decide := true })
  have heq : {x_1 ∈ univ.erase i | if x_1 = i then x x_1 = false else x x_1 = true} = {x_1 ∈ univ.erase i | x x_1 = true} := by
    ext j
    simp [Finset.mem_filter, Finset.mem_erase]
  rw [heq]
  by_cases h : x i <;> simp [h]
  · abel
  · abel

/-- Along a snake, parity alternates. -/
theorem Snake.par_v (s : Snake n L) {i : ℕ} (hi : i ≤ L) :
    par (s.v i) = par (s.v 0) + (i : ZMod 2) := by
  induction i with
  | zero => simp
  | succ k ih =>
    have hk : k ≤ L := Nat.le_of_succ_le hi
    have hstep := s.step k (Nat.lt_of_succ_le hi)
    obtain ⟨j, hj⟩ := hstep
    rw [hj]
    rw [par_flipAt, ih hk]
    simp [Nat.cast_add]
    abel

/-- Parities add up to the Hamming distance, modulo two. -/
theorem par_add_par (x y : Cube n) : par x + par y = (hammingDist x y : ZMod 2) := by
  unfold par hammingDist
  simp only [Finset.card_filter]
  rw [← Finset.sum_add_distrib, Nat.cast_sum]
  congr 1
  ext i
  cases x i <;> cases y i <;> simp
  rfl

/-- Vertices of opposite index parity that are far apart on the snake are at
Hamming distance at least three: the distance-two constraint is upgraded by a
parity argument. -/
theorem Snake.three_le_hammingDist (s : Snake n L) {i j : ℕ} (hj : j ≤ L) (hij : i + 2 ≤ j)
    (hpar : (i : ZMod 2) ≠ (j : ZMod 2)) : 3 ≤ hammingDist (s.v i) (s.v j) := by
  -- From chord property, Hamming distance ≥ 2
  have hdist : 2 ≤ hammingDist (s.v i) (s.v j) := s.chord i j hj hij
  -- We'll show the Hamming distance is odd, hence at least three
  -- Use par_v to get parities of s.v i and s.v j
  have pir : par (s.v i) = par (s.v 0) + (i : ZMod 2) := Snake.par_v s (by omega : i ≤ L)
  have pj : par (s.v j) = par (s.v 0) + (j : ZMod 2) := Snake.par_v s hj
  -- Their sum is i + j in ZMod 2
  have hsum : par (s.v i) + par (s.v j) = (i : ZMod 2) + (j : ZMod 2) := by
    rw [pir, pj]
    have h2 : (2 : ZMod 2) = 0 := by decide
    calc par (s.v 0) + (i : ZMod 2) + (par (s.v 0) + (j : ZMod 2))
        = 2 * par (s.v 0) + ((i : ZMod 2) + (j : ZMod 2)) := by ring
      _ = 0 * par (s.v 0) + ((i : ZMod 2) + (j : ZMod 2)) := by rw [h2]
      _ = (i : ZMod 2) + (j : ZMod 2) := by ring
  -- Since i ≠ j in ZMod 2, i + j = 1
  have hsum_one : (i : ZMod 2) + (j : ZMod 2) = 1 := by
    have : ∀ x : ZMod 2, x = 0 ∨ x = 1 := by decide
    rcases this (i : ZMod 2) with hi | hi <;> rcases this (j : ZMod 2) with hj | hj <;> simp_all
  -- So hammingDist is odd
  have hold : (hammingDist (s.v i) (s.v j) : ZMod 2) = 1 := by
    rw [← par_add_par, hsum, hsum_one]
  -- Hamming distance ≥ 2 and odd means ≥ 3
  have hodd : hammingDist (s.v i) (s.v j) % 2 = 1 := by
    have := congr_arg ZMod.val hold
    simp only [ZMod.val_one, ZMod.val_natCast] at this
    exact this
  by_contra h
  push_neg at h
  omega

/-! ## Step 4: the degree bound -/

/-- Chordlessness: every snake vertex has at most two cube neighbours on the snake. -/
theorem Snake.degree_le_two (s : Snake n L) {x : Cube n} (hx : x ∈ s.vset) :
    (s.vset.filter fun y => Adj x y).card ≤ 2 := by
  -- x ∈ s.vset means x = s.v i for some i ≤ L
  rw [Snake.vset] at hx
  obtain ⟨i, hi_mem, rfl⟩ := Finset.mem_image.mp hx
  simp at hi_mem
  -- The filter is contained in {s.v (i-1), s.v (i+1)} ∩ vset
  -- First, show any adjacent vertex has index in {i-1, i+1}
  have h_bound : ∀ y ∈ s.vset, Adj (s.v i) y → y = s.v (i - 1) ∨ y = s.v (i + 1) := by
    intro y hy hadj
    rw [Snake.vset] at hy
    obtain ⟨j, hj_mem, rfl⟩ := Finset.mem_image.mp hy
    simp at hj_mem
    -- By chord property: if i + 2 ≤ j, then hammingDist ≥ 2, but Adj implies hammingDist = 1
    by_cases hij : i + 2 ≤ j
    · have := s.chord i j hj_mem hij
      have hadj_dist := hammingDist_of_adj hadj
      omega
    · push_neg at hij
      -- So j ≤ i + 1
      -- Similarly, if j + 2 ≤ i, then hammingDist ≥ 2
      by_cases hji : j + 2 ≤ i
      · have := s.chord j i hi_mem hji
        have hadj_dist := hammingDist_of_adj (adj_symm hadj)
        omega
      · push_neg at hji
        -- So i ≤ j + 1, meaning |i - j| ≤ 1
        -- Since Adj is irrefl, i ≠ j, so i = j + 1 or j = i + 1
        have hne : i ≠ j := by
          intro heq
          rw [heq] at hadj
          exact adj_irrefl _ hadj
        by_cases heq : i = j + 1
        · left
          simp [heq]
        · right
          have : j = i + 1 := by omega
          simp [this]
  -- The filter is a subset of {s.v (i-1), s.v (i+1)}
  have hsub : (s.vset.filter fun y => Adj (s.v i) y) ⊆ {s.v (i - 1), s.v (i + 1)} := by
    intro y hy
    simp at hy
    rcases h_bound y hy.1 hy.2 with rfl | rfl <;> simp
  calc #{y ∈ s.vset | Adj (s.v i) y}
      ≤ #{s.v (i - 1), s.v (i + 1)} := Finset.card_le_card hsub
    _ ≤ 2 := Finset.card_insert_le _ _

/-- Hence every snake vertex sends at least `n - 2` edges out of the snake. -/
theorem Snake.out_degree_ge (s : Snake n L) {x : Cube n} (hx : x ∈ s.vset) :
    n - 2 ≤ (s.vsetᶜ.filter fun y => Adj x y).card := by
  have h_sphere : (univ.filter fun y => Adj x y).card = n := card_sphere x
  have h_in : (s.vset.filter fun y => Adj x y).card ≤ 2 := s.degree_le_two hx
  have h_disj : Disjoint (s.vset.filter fun y => Adj x y) (s.vsetᶜ.filter fun y => Adj x y) := by
    simp [Finset.disjoint_left]
    tauto
  have h_card_part : n = (s.vset.filter fun y => Adj x y).card + (s.vsetᶜ.filter fun y => Adj x y).card := by
    have key : (s.vset.filter fun y => Adj x y).card + (s.vsetᶜ.filter fun y => Adj x y).card = 
               (univ.filter fun y => Adj x y).card := by
      rw [← Finset.card_union_of_disjoint h_disj]
      congr 1
      ext y
      simp
      tauto
    linarith [key, h_sphere]
  omega

/-! ## Step 5: the double count -/

/-- The number of cube edges leaving the snake, counted from the snake side. -/
def Snake.boundary (s : Snake n L) : ℕ :=
  ∑ x ∈ s.vset, (s.vsetᶜ.filter fun y => Adj x y).card

theorem Snake.boundary_lower (s : Snake n L) : (n - 2) * (L + 1) ≤ s.boundary := by
  have h : (n - 2) * (L + 1) = ∑ _ ∈ s.vset, (n - 2) := by
    rw [← s.card_vset]
    simp [mul_comm]
  rw [h]
  exact Finset.sum_le_sum fun x hx => s.out_degree_ge hx

theorem Snake.boundary_upper (s : Snake n L) : s.boundary ≤ n * (2 ^ n - (L + 1)) := by
  -- The complement of vset has cardinality 2^n - (L+1)
  have h_compl : s.vsetᶜ.card = 2 ^ n - (L + 1) := by
    rw [card_compl, Snake.card_vset]
    simp [Finset.card_univ]
  -- Double counting: rewrite the sum by swapping the order
  have h_double : s.boundary = ∑ y ∈ s.vsetᶜ, (s.vset.filter fun x => Adj x y).card := by
    unfold Snake.boundary
    simp_rw [Finset.card_filter]
    rw [Finset.sum_comm]
  -- Each vertex in the complement has at most n neighbors total
  have h_bound : ∀ y ∈ s.vsetᶜ, (s.vset.filter fun x => Adj x y).card ≤ n := by
    intro y _
    have h_univ : (univ.filter fun x => Adj x y).card = n := by
      have h_eq : (univ.filter fun x => Adj x y) = (univ.filter fun x => Adj y x) := by
        ext x
        simp only [Finset.mem_filter, Finset.mem_univ, true_and]
        constructor <;> intro h <;> exact adj_symm h
      rw [h_eq, card_sphere]
    calc (s.vset.filter fun x => Adj x y).card
        ≤ (univ.filter fun x => Adj x y).card := Finset.card_le_card (Finset.filter_subset_filter _ (Finset.subset_univ s.vset))
      _ = n := h_univ
  -- Now bound the sum
  calc s.boundary
      = ∑ y ∈ s.vsetᶜ, (s.vset.filter fun x => Adj x y).card := h_double
    _ ≤ ∑ _ ∈ s.vsetᶜ, n := Finset.sum_le_sum h_bound
    _ = n * s.vsetᶜ.card := by simp [mul_comm]
    _ = n * (2 ^ n - (L + 1)) := by rw [h_compl]

/-- The master counting inequality for snakes. -/
theorem Snake.count (s : Snake n L) : (n - 2) * (L + 1) + n * (L + 1) ≤ n * 2 ^ n := by
  have h1 := s.boundary_lower
  have h2 := s.boundary_upper
  have h3 : L + 1 ≤ 2 ^ n := by
    have h := Finset.card_le_univ s.vset
    simpa [s.card_vset, Fintype.card_fun] using h
  have h4 : n * (2 ^ n - (L + 1)) + n * (L + 1) = n * 2 ^ n := by
    rw [Nat.mul_sub, Nat.sub_add_cancel (Nat.mul_le_mul_left n h3)]
  omega

/-! ## Step 6: rigidity near the Boolean-cube ceiling -/

/-- **Main theorem.** For `n ≥ 3`, a snake in `Q n` has at most `3 · 2 ^ (n-2)` vertices. -/
theorem Snake.card_le (s : Snake n L) (hn : 3 ≤ n) : L + 1 ≤ 3 * 2 ^ (n - 2) := by
  have hcount := s.count
  -- Simplify hcount: (n-2 + n) * (L+1) = (2n-2) * (L+1)
  have h1 : (2 * n - 2) * (L + 1) ≤ n * 2 ^ n := by
    have hdist : (n - 2 + n) * (L + 1) = (n - 2) * (L + 1) + n * (L + 1) := by ring
    have heq : n - 2 + n = 2 * n - 2 := by omega
    calc (2 * n - 2) * (L + 1) = (n - 2 + n) * (L + 1) := by rw [heq]
      _ = (n - 2) * (L + 1) + n * (L + 1) := hdist
      _ ≤ n * 2 ^ n := hcount
  -- Key: n * 2^n = n * 4 * 2^(n-2) = 4n * 2^(n-2)
  -- And 3 * 2^(n-2) * (2n-2) = (6n-6) * 2^(n-2)
  -- So we need 4n ≤ 6n - 6, i.e., 6 ≤ 2n, which holds for n ≥ 3
  have h2 : n * 2 ^ n ≤ 3 * 2 ^ (n - 2) * (2 * n - 2) := by
    have hpow : 2 ^ n = 2 ^ (n - 2) * 4 := by
      have hn2 : 2 ≤ n := by omega
      have : n = (n - 2) + 2 := (Nat.sub_add_cancel hn2).symm
      conv_lhs => rw [this, pow_add, pow_two]; norm_num
    have hkey : 4 * n ≤ 3 * (2 * n - 2) := by omega
    calc n * 2 ^ n = n * (2 ^ (n - 2) * 4) := by rw [hpow]
      _ = 4 * n * 2 ^ (n - 2) := by ring
      _ ≤ 3 * (2 * n - 2) * 2 ^ (n - 2) := by gcongr
      _ = 3 * 2 ^ (n - 2) * (2 * n - 2) := by ring
  -- Combine h1 and h2
  have h3 : (L + 1) * (2 * n - 2) ≤ 3 * 2 ^ (n - 2) * (2 * n - 2) := by
    rw [mul_comm] at h1
    exact le_trans h1 h2
  -- Cancel (2 * n - 2) which is positive for n ≥ 3
  have hpos : 0 < 2 * n - 2 := by omega
  exact Nat.le_of_mul_le_mul_right h3 hpos

/-- **Main theorem (rigidity form).** For `n ≥ 3`, a snake in `Q n` omits at least
`2 ^ (n - 2)` vertices of the cube. -/
theorem Snake.omits (s : Snake n L) (hn : 3 ≤ n) : 2 ^ (n - 2) ≤ s.vsetᶜ.card := by
  have h_card : s.vsetᶜ.card = 2 ^ n - (L + 1) := by
    rw [Finset.card_compl, s.card_vset]
    simp [Finset.card_univ]
  rw [h_card]
  have h := s.card_le hn
  have h2 : 2 ^ n = 4 * 2 ^ (n - 2) := by
    have : n = 2 + (n - 2) := by omega
    conv_lhs => rw [this, pow_add]
    norm_num
  omega

/-- No snake is Hamiltonian once `n ≥ 3`. -/
theorem Snake.not_hamiltonian (s : Snake n L) (hn : 3 ≤ n) : s.vset ≠ univ := by
  intro heq
  have h₁ := s.omits hn
  rw [heq] at h₁
  simp at h₁

/-! ## Step 7: non-vacuity -/

/-- The standard snake `000 → 001 → 011 → 111 → 110` of length four in `Q 3`. -/
def snake3v : ℕ → Cube 3
  | 0 => ![false, false, false]
  | 1 => ![false, false, true]
  | 2 => ![false, true, true]
  | 3 => ![true, true, true]
  | 4 => ![true, true, false]
  | _ => ![false, false, false]

theorem snake3_step : ∀ i, i < 4 → Adj (snake3v i) (snake3v (i + 1)) := by
  intro i hi
  interval_cases i <;> decide

theorem snake3_chord : ∀ i j, j ≤ 4 → i + 2 ≤ j → 2 ≤ hammingDist (snake3v i) (snake3v j) := by
  intro i j hj hij
  interval_cases j
  · omega
  · omega
  · have hi : i = 0 := by omega
    subst hi; decide
  · have hi3 : i ≤ 1 := by omega
    interval_cases i <;> decide
  · have hi4 : i ≤ 2 := by omega
    interval_cases i <;> decide

/-- A snake of length four in `Q 3`. -/
def snake3 : Snake 3 4 := ⟨snake3v, snake3_step, snake3_chord⟩

/-- Embedding of a lower-dimensional cube into a higher-dimensional one. -/
def extend (m n : ℕ) (x : Cube m) : Cube n := fun j => if h : (j : ℕ) < m then x ⟨j, h⟩ else false

theorem hammingDist_extend {m : ℕ} (hmn : m ≤ n) (x y : Cube m) :
    hammingDist (extend m n x) (extend m n y) = hammingDist x y := by
  unfold hammingDist
  -- Goal: #{i : Fin n | extend x i ≠ extend y i} = #{i : Fin m | x i ≠ y i}
  let LHS : Finset (Fin n) := Finset.univ.filter fun j => extend m n x j ≠ extend m n y j
  let RHS : Finset (Fin m) := Finset.univ.filter fun i => x i ≠ y i
  let embed : Fin m → Fin n := fun i => ⟨i, by omega⟩
  have goal_eq : #{i : Fin n | extend m n x i ≠ extend m n y i} = LHS.card ∧
                 #{i : Fin m | x i ≠ y i} = RHS.card := by
    simp [LHS, RHS]
  rw [goal_eq.1, goal_eq.2]
  have hLHS_eq : LHS = RHS.image embed := by
    ext j
    simp only [LHS, RHS, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · intro hj
      have hjm : (j : ℕ) < m := by
        by_contra hc
        push_neg at hc
        simp only [extend] at hj
        simp only [dif_neg (not_lt.mpr hc)] at hj
        simp at hj
      refine ⟨⟨j, hjm⟩, ?_, rfl⟩
      simp_all [extend]
    · rintro ⟨i, hi, rfl⟩
      simp_all [extend, embed]
  rw [hLHS_eq]
  exact Finset.card_image_of_injective _ (fun a b h => Fin.ext (by simpa [embed] using h))

theorem adj_extend {m : ℕ} (hmn : m ≤ n) {x y : Cube m} (h : Adj x y) :
    Adj (extend m n x) (extend m n y) := by
  obtain ⟨i, hi⟩ := h
  use ⟨i.val, by linarith [i.is_lt]⟩
  ext j
  rw [hi]
  unfold extend flipAt
  split_ifs with hj hj2 hj3
  all_goals simp_all [Fin.ext_iff]

/-- Snakes persist under increasing the dimension of the cube. -/
def Snake.embed {m : ℕ} (s : Snake m L) (hmn : m ≤ n) : Snake n L where
  v i := extend m n (s.v i)
  step i hi := adj_extend hmn (s.step i hi)
  chord i j hj hij := by
    rw [hammingDist_extend hmn]; exact s.chord i j hj hij

/-- Snakes of length four exist in every dimension `n ≥ 3`, so the rigidity bound is
not vacuous. -/
theorem exists_snake_four (hn : 3 ≤ n) : Nonempty (Snake n 4) :=
  ⟨snake3.embed hn⟩

/-- Summary: for `n ≥ 3` the maximal snake length in `Q n` lies between `4` and
`3 * 2 ^ (n - 2) - 1`. -/
theorem snake_length_bounds (hn : 3 ≤ n) :
    (∃ L, 4 ≤ L ∧ Nonempty (Snake n L)) ∧ ∀ L, ∀ _ : Snake n L, L + 1 ≤ 3 * 2 ^ (n - 2) :=
  ⟨⟨4, le_refl 4, exists_snake_four hn⟩, fun _ s => s.card_le hn⟩

/-! ## Step 8: exact endpoint degrees and the sharpened count

The double count of Step 5 only used `deg_S ≤ 2`.  In fact the vertex set of a
snake spans exactly `L` cube edges (the path edges), because two snake vertices
are cube-adjacent only when their indices are consecutive.  Feeding this exact
information into the same double count sharpens the ceiling to a *strict*
inequality, which in low dimensions already pins down the optimum. -/

/-- Sums over the vertex set of a snake are sums over the index range. -/
theorem Snake.sum_vset (s : Snake n L) (f : Cube n → ℕ) :
    ∑ x ∈ s.vset, f x = ∑ i ∈ range (L + 1), f (s.v i) := by
  rw [Snake.vset, Finset.sum_image]
  exact s.injOn.mono (fun i hi => Finset.mem_range_succ_iff.mp hi)

/-- Inside and outside neighbours of a vertex add up to the full sphere. -/
theorem Snake.deg_split (s : Snake n L) (x : Cube n) :
    (s.vset.filter fun y => Adj x y).card + (s.vsetᶜ.filter fun y => Adj x y).card = n := by
  have heq : (univ.filter fun y => Adj x y) =
      (s.vset.filter fun y => Adj x y) ∪ (s.vsetᶜ.filter fun y => Adj x y) := by
    ext y
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    rw [Finset.mem_union]
    by_cases hy : y ∈ s.vset <;> simp [hy]
  have key : (s.vset.filter fun y => Adj x y).card + (s.vsetᶜ.filter fun y => Adj x y).card =
      (univ.filter fun y => Adj x y).card := by
    have hdisj : Disjoint (s.vset.filter fun y => Adj x y) (s.vsetᶜ.filter fun y => Adj x y) := by
      rw [Finset.disjoint_iff_ne]
      intro a ha b hb hab
      simp only [Finset.mem_filter] at ha hb
      obtain ⟨haset, _⟩ := ha
      simp only [Finset.mem_compl] at hb
      obtain ⟨hbset, _⟩ := hb
      rw [hab] at haset
      exact hbset haset
    rw [← card_union_of_disjoint hdisj]
    congr 1
    exact heq.symm
  rw [key, card_sphere x]

/-- The snake neighbours of `s.v i` are among `s.v (i-1)` and `s.v (i+1)`, and the
first (resp. last) of these is missing at the initial (resp. final) vertex. -/
theorem Snake.nbrs_subset (s : Snake n L) {i : ℕ} (hi : i ≤ L) :
    (s.vset.filter fun y => Adj (s.v i) y) ⊆
      (if i = 0 then ∅ else {s.v (i - 1)}) ∪ (if i = L then ∅ else {s.v (i + 1)}) := by
  intro y hy
  simp at hy
  obtain ⟨hj, hadj⟩ := hy
  rw [Snake.vset] at hj
  obtain ⟨j, hj_mem, rfl⟩ := Finset.mem_image.mp hj
  simp at hj_mem
  rcases s.index_adj hi hj_mem hadj with hj_eq | hj_eq
  · -- j = i + 1
    simp [hj_eq]
    split_ifs with h0 hL
    · -- i = 0, i = L: then j = 1 > L = 0, contradicts hj_mem
      omega
    · -- i = 0, i ≠ L: j = i + 1 = 1 ∈ {s.v (i + 1)}
      exact Or.inr (Finset.mem_singleton_self _)
    · -- i ≠ 0, i = L: j = i + 1 = L + 1 > L, contradicts hj_mem
      omega
    · -- i ≠ 0, i ≠ L: j = i + 1 ∈ {s.v (i + 1)}
      exact Or.inr (Finset.mem_singleton_self _)
  · -- i = j + 1, so j = i - 1
    have hj' : j = i - 1 := by omega
    rw [hj']
    by_cases h0 : i = 0 <;> by_cases hL : i = L
    · omega
    · omega
    · rw [hL]
      simp [show L ≠ 0 by omega]
    · simp [h0, hL]

/-- Degree bound refined at the two endpoints of the snake. -/
theorem Snake.degree_index_le (s : Snake n L) {i : ℕ} (hi : i ≤ L) :
    (s.vset.filter fun y => Adj (s.v i) y).card
      ≤ (if i = 0 then 0 else 1) + (if i = L then 0 else 1) := by
  have hcard : (((if i = 0 then ∅ else {s.v (i - 1)}) : Finset (Cube n)) ∪
      (if i = L then ∅ else {s.v (i + 1)})).card ≤ (if i = 0 then 0 else 1) + (if i = L then 0 else 1) := by
    by_cases h0 : i = 0 <;> by_cases hL : i = L
    · subst h0 hL; simp
    · subst h0; simp [hL]
    · subst hL; simp [h0]
    · simp [h0, hL]
      exact Finset.card_insert_le _ _
  exact le_trans (Finset.card_le_card (s.nbrs_subset hi)) hcard

/-- The vertex set of a snake spans at most `L` cube edges. -/
theorem Snake.sum_degree_le (s : Snake n L) :
    ∑ i ∈ range (L + 1), (s.vset.filter fun y => Adj (s.v i) y).card ≤ 2 * L := by
  have h : ∀ i ∈ range (L + 1), (s.vset.filter fun y => Adj (s.v i) y).card ≤
      (if i = 0 then 0 else 1) + (if i = L then 0 else 1) := by
    intro i hi
    apply s.degree_index_le
    simp at hi
    omega
  calc ∑ i ∈ range (L + 1), (s.vset.filter fun y => Adj (s.v i) y).card
      ≤ ∑ i ∈ range (L + 1), ((if i = 0 then 0 else 1) + (if i = L then 0 else 1)) :=
        Finset.sum_le_sum h
    _ ≤ 2 * L := by
        by_cases hL : L = 0
        · simp [hL]
        · have hL' : L ≥ 1 := Nat.one_le_iff_ne_zero.mpr hL
          set M := L - 1 with hM_def
          have hML : L = M + 1 := (Nat.sub_add_cancel hL').symm
          rw [hML, Finset.sum_range_succ, Finset.sum_range_succ']
          have h1 : ∀ k ∈ range M, ((if k + 1 = 0 then 0 else 1) + if k + 1 = M + 1 then 0 else 1) = 2 := by
            intro k hk
            have hk' : k < M := Finset.mem_range.mp hk
            simp only [Nat.succ_ne_zero, ↓reduceIte]
            simp [hk'.ne]
          rw [Finset.sum_congr rfl h1]
          simp only [Finset.sum_const, Finset.card_range, smul_eq_mul]
          simp; omega

/-- Sharp lower bound for the edge boundary of a snake. -/
theorem Snake.boundary_ge (s : Snake n L) : n * (L + 1) ≤ s.boundary + 2 * L := by
  -- Rewrite the sum over vset as a sum over range (L + 1)
  have h_sum_eq : ∑ x ∈ s.vset, (s.vset.filter fun y => Adj x y).card =
                  ∑ i ∈ range (L + 1), (s.vset.filter fun y => Adj (s.v i) y).card :=
    s.sum_vset _
  -- For each vertex x in vset, out_degree + in_degree = n
  have h_split : ∀ x ∈ s.vset, (s.vset.filter fun y => Adj x y).card
      + (s.vsetᶜ.filter fun y => Adj x y).card = n := fun x _ => s.deg_split x
  -- Express boundary in terms of n * (L + 1) minus sum of internal degrees
  have h_boundary_eq : s.boundary = n * (L + 1) - ∑ x ∈ s.vset, (s.vset.filter fun y => Adj x y).card := by
    rw [Snake.boundary]
    have h_card : s.vset.card = L + 1 := s.card_vset
    have h_eq : ∑ x ∈ s.vset, (s.vsetᶜ.filter fun y => Adj x y).card + ∑ x ∈ s.vset, (s.vset.filter fun y => Adj x y).card = n * (L + 1) := by
      have h_reorder : ∀ x ∈ s.vset, (s.vsetᶜ.filter fun y => Adj x y).card + (s.vset.filter fun y => Adj x y).card = n := by
        intro x hx; rw [add_comm]; exact h_split x hx
      rw [← Finset.sum_add_distrib, Finset.sum_congr rfl h_reorder]
      rw [Finset.sum_const, smul_eq_mul, mul_comm, h_card]
    omega
  -- Now use sum_degree_le to finish
  have h_deg_sum := s.sum_degree_le
  omega

/-- **Sharpened counting inequality.**  Compare with `Snake.count`, which only gives
`(n-2)(L+1) + n(L+1) ≤ n·2ⁿ`; here the two path endpoints are accounted for exactly. -/
theorem Snake.count_sharp (s : Snake n L) : 2 * n * (L + 1) ≤ n * 2 ^ n + 2 * L := by
  have h1 := s.boundary_ge
  have h2 := s.boundary_upper
  have h3 : L + 1 ≤ 2 ^ n := by
    have h := Finset.card_le_univ s.vset
    simpa [s.card_vset, Fintype.card_fun] using h
  have h4 : n * (2 ^ n - (L + 1)) + n * (L + 1) = n * 2 ^ n := by
    rw [Nat.mul_sub, Nat.sub_add_cancel (Nat.mul_le_mul_left n h3)]
  -- From h1 and h2: n * (L + 1) ≤ n * (2 ^ n - (L + 1)) + 2 * L
  have h5 : n * (L + 1) ≤ n * (2 ^ n - (L + 1)) + 2 * L := by
    calc n * (L + 1) ≤ s.boundary + 2 * L := h1
      _ ≤ n * (2 ^ n - (L + 1)) + 2 * L := by gcongr
  -- From h4: n * (2 ^ n - (L + 1)) = n * 2 ^ n - n * (L + 1)
  have h6 : n * (2 ^ n - (L + 1)) = n * 2 ^ n - n * (L + 1) := by
    rw [← h4]; omega
  -- Substitute h6 into h5
  rw [h6] at h5
  -- Now h5 says: n * (L + 1) ≤ n * 2 ^ n - n * (L + 1) + 2 * L
  -- Adding n * (L + 1) to both sides: 2 * n * (L + 1) ≤ n * 2 ^ n + 2 * L
  have h7 : n * (L + 1) + n * (L + 1) ≤ n * 2 ^ n + 2 * L := by omega
  linarith

/-! ## Step 9: strict rigidity -/

/-- **Strict rigidity.**  For `n ≥ 3` a snake has *fewer* than `3·2^(n-2)` vertices. -/
theorem Snake.card_lt (s : Snake n L) (hn : 3 ≤ n) : L + 1 < 3 * 2 ^ (n - 2) := by
  have h := s.count_sharp
  have h2 : 2 ^ n = 4 * 2 ^ (n - 2) := by
    have hsub : n - 2 + 2 - 2 = n - 2 := by omega
    rw [show n = n - 2 + 2 by omega, pow_add, pow_two]
    rw [hsub]
    ring
  rw [h2] at h
  by_contra h_neg
  push_neg at h_neg
  clear s
  set p := 2 ^ (n - 2) with hp_def
  have hp_ge2 : p ≥ 2 := by
    simp [hp_def]
    exact Nat.le_trans (by decide : 2 ^ 1 ≤ 2)
      (Nat.pow_le_pow_right (by decide : 1 ≤ 2) (by omega : 1 ≤ n - 2))
  -- h : 2 * n * L + 2 * n ≤ 4 * n * p + 2 * L
  have h_p : 2 * n * L + 2 * n ≤ 4 * n * p + 2 * L := by
    have h3 : 2 * n * (L + 1) = 2 * n * L + 2 * n := by ring
    have h4 : n * (4 * 2 ^ (n - 2)) = 4 * n * p := by simp [hp_def]; ring
    rw [h3, h4] at h; exact h
  -- From h_neg: L + 1 ≥ 3 * p, so L ≥ 3 * p - 1
  have L_ge : L ≥ 3 * p - 1 := by omega
  -- Derive L * (n - 1) ≤ n * (2 * p - 1) from h_p
  have hL_bound : L * (n - 1) ≤ n * (2 * p - 1) := by nlinarith
  -- (3p - 1)(n - 1) ≤ n(2p - 1)
  have h_contra : (3 * p - 1) * (n - 1) ≤ n * (2 * p - 1) := by
    calc (3 * p - 1) * (n - 1) ≤ L * (n - 1) := Nat.mul_le_mul_right _ L_ge
         _ ≤ n * (2 * p - 1) := hL_bound
  -- From h_contra derive contradiction using nlinarith
  nlinarith [Nat.sub_add_cancel (by omega : 1 ≤ 2 * p), Nat.sub_add_cancel (by omega : 1 ≤ 3 * p),
             Nat.sub_add_cancel (by omega : 1 ≤ n), Nat.sub_add_cancel (by omega : 3 ≤ n)]

/-- **Strict rigidity, omission form.**  For `n ≥ 3` a snake omits more than `2^(n-2)`
vertices of the cube. -/
theorem Snake.omits_lt (s : Snake n L) (hn : 3 ≤ n) : 2 ^ (n - 2) < s.vsetᶜ.card := by
  have hcard := s.card_vset
  have huniv : Fintype.card (Cube n) = 2 ^ n := by simp
  -- vsetᶜ.card = 2^n - (L + 1)
  have hcompl : s.vsetᶜ.card = 2 ^ n - (L + 1) := by
    rw [Finset.card_compl, huniv, hcard]
  rw [hcompl]
  -- Use card_lt: L + 1 < 3 * 2^(n-2)
  have hcard_lt := s.card_lt hn
  -- 2^n = 4 * 2^(n-2), so 2^n - (L+1) > 4*2^(n-2) - 3*2^(n-2) = 2^(n-2)
  have hpow : 2 ^ n = 4 * 2 ^ (n - 2) := by
    calc 2 ^ n = 2 ^ (2 + (n - 2)) := by congr 1; omega
      _ = 2 ^ 2 * 2 ^ (n - 2) := pow_add 2 2 (n - 2)
      _ = 4 * 2 ^ (n - 2) := by norm_num
  rw [hpow]
  omega

/-! ## Step 10: the exact optimum in dimensions two and three -/

/-- In `Q 2` a snake has at most two edges. -/
theorem Snake.length_le_dim_two (s : Snake 2 L) : L ≤ 2 := by
  have h := s.count_sharp
  norm_num at h
  omega

/-- In `Q 3` a snake has at most four edges: the counting ceiling is attained. -/
theorem Snake.length_le_dim_three (s : Snake 3 L) : L ≤ 4 := by
  have h := s.count_sharp
  norm_num at h
  omega

/-- Any initial segment of a snake is a snake. -/
def Snake.truncate (s : Snake n L) {K : ℕ} (hK : K ≤ L) : Snake n K where
  v := s.v
  step i hi := s.step i (lt_of_lt_of_le hi hK)
  chord i j hj hij := s.chord i j (le_trans hj hK) hij

/-- The snake `00 → 01 → 11` of length two in `Q 2`. -/
def snake2v : ℕ → Cube 2
  | 0 => ![false, false]
  | 1 => ![false, true]
  | 2 => ![true, true]
  | _ => ![false, false]

theorem snake2_step : ∀ i, i < 2 → Adj (snake2v i) (snake2v (i + 1)) := by
  intro i hi
  interval_cases i <;> decide

theorem snake2_chord : ∀ i j, j ≤ 2 → i + 2 ≤ j → 2 ≤ hammingDist (snake2v i) (snake2v j) := by
  intro i j hj hij
  interval_cases j
  · omega
  · omega
  · have hi : i = 0 := by omega
    subst hi; decide

/-- A snake of length two in `Q 2`. -/
def snake2 : Snake 2 2 := ⟨snake2v, snake2_step, snake2_chord⟩

/-- **Exact optimum in dimension two**: `Q 2` has snakes of length `L` exactly for
`L ≤ 2`. -/
theorem snake_max_dim_two (L : ℕ) : Nonempty (Snake 2 L) ↔ L ≤ 2 :=
  ⟨fun ⟨s⟩ => s.length_le_dim_two, fun h => ⟨snake2.truncate h⟩⟩

/-- **Exact optimum in dimension three**: `Q 3` has snakes of length `L` exactly for
`L ≤ 4`.  So the longest snake in `Q 3` has four edges, matching the classical value
`s(3) = 4`, and the sharpened counting bound is tight in this dimension. -/
theorem snake_max_dim_three (L : ℕ) : Nonempty (Snake 3 L) ↔ L ≤ 4 :=
  ⟨fun ⟨s⟩ => s.length_le_dim_three, fun h => ⟨snake3.truncate h⟩⟩

end SnakeInTheBox