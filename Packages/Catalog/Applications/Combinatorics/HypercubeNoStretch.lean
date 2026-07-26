import Mathlib

/-! # No-stretching for labelings into the hypercube over GF(2)

Let `G` be a connected simple graph on `V`, and `ℓ : V → (Fin k → ZMod 2)` a labeling such that
every `G`-edge `{u,v}` satisfies either `ℓ u = ℓ v` or `HammingDist (ℓ u) (ℓ v) = 1`.

We prove that such a labeling does not stretch distances: the hypercube distance between labels is
bounded by the graph distance.

The hypercube `Q_k` has vertex set `Fin k → ZMod 2` and an edge between two vertices at Hamming
distance `1`.

* `hypercube_dist_eq_hammingDist`: the graph distance in `Q_k` equals the Hamming distance.
* `exists_image_walk`: a `G`-walk maps to a hypercube walk of no greater length.
* `no_stretching`: `(hypercube k).dist (ℓ u) (ℓ v) ≤ G.dist u v`.
-/

open SimpleGraph

namespace HypercubeNoStretch

/-- A vertex of the `k`-dimensional hypercube over `GF(2)`. -/
abbrev Cube (k : ℕ) := Fin k → ZMod 2

/-- Hamming distance: the number of coordinates where `x` and `y` differ. -/
def HammingDist {k : ℕ} (x y : Cube k) : ℕ :=
  (Finset.univ.filter (fun i => x i ≠ y i)).card

lemma HammingDist_comm {k : ℕ} (x y : Cube k) : HammingDist x y = HammingDist y x := by
  unfold HammingDist
  congr 1
  ext i
  simp [ne_comm]

lemma HammingDist_self {k : ℕ} (x : Cube k) : HammingDist x x = 0 := by
  simp [HammingDist]

lemma HammingDist_eq_zero {k : ℕ} {x y : Cube k} : HammingDist x y = 0 ↔ x = y := by
  unfold HammingDist
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  constructor
  · intro h; funext i; have := h (Finset.mem_univ i); simpa using this
  · intro h; subst h; simp

lemma HammingDist_triangle {k : ℕ} (x y z : Cube k) :
    HammingDist x z ≤ HammingDist x y + HammingDist y z := by
  unfold HammingDist
  refine le_trans (Finset.card_le_card ?_) (Finset.card_union_le _ _)
  intro i hi
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi
  simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and]
  by_contra h
  push_neg at h
  exact hi (by rw [h.1, h.2])

/-- The `k`-dimensional hypercube graph over `GF(2)`: two vertices are adjacent iff their Hamming
distance is `1`. -/
def hypercube (k : ℕ) : SimpleGraph (Cube k) :=
  SimpleGraph.fromRel (fun x y => HammingDist x y = 1)

lemma hypercube_adj_iff {k : ℕ} {x y : Cube k} :
    (hypercube k).Adj x y ↔ HammingDist x y = 1 := by
  unfold hypercube
  rw [fromRel_adj]
  constructor
  · rintro ⟨_, h | h⟩
    · exact h
    · rwa [HammingDist_comm]
  · intro h
    refine ⟨?_, Or.inl h⟩
    intro hxy; subst hxy; rw [HammingDist_self] at h; exact absurd h (by norm_num)

/-- **Lower bound.** Any walk in the hypercube has length at least the Hamming distance of its
endpoints. -/
lemma walk_length_ge {k : ℕ} {x y : Cube k} (w : (hypercube k).Walk x y) :
    HammingDist x y ≤ w.length := by
  induction w with
  | nil => simp [HammingDist_self]
  | @cons a b c h p ih =>
      have hab : HammingDist a b = 1 := hypercube_adj_iff.mp h
      calc HammingDist a c ≤ HammingDist a b + HammingDist b c := HammingDist_triangle a b c
        _ ≤ 1 + p.length := by rw [hab]; exact Nat.add_le_add_left ih 1
        _ = (p.cons h).length := by rw [SimpleGraph.Walk.length_cons]; ring

/-- Flip coordinate `i` of `x` (add `1` in `GF(2)`). -/
def flipCoord {k : ℕ} (x : Cube k) (i : Fin k) : Cube k := Function.update x i (x i + 1)

lemma HammingDist_flip_self {k : ℕ} (x : Cube k) (i : Fin k) :
    HammingDist x (flipCoord x i) = 1 := by
  unfold HammingDist flipCoord
  rw [Finset.card_eq_one]
  refine ⟨i, ?_⟩
  ext j
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton,
    Function.update_apply]
  by_cases hj : j = i
  · subst hj; simp
  · simp [hj]

lemma HammingDist_flip {k : ℕ} (x y : Cube k) (i : Fin k) (hi : x i ≠ y i) :
    HammingDist (flipCoord x i) y + 1 = HammingDist x y := by
  have hyi : y i = x i + 1 := by
    have : ∀ a b : ZMod 2, a ≠ b → b = a + 1 := by decide
    exact this _ _ hi
  unfold HammingDist flipCoord
  have hset : (Finset.univ.filter (fun j => Function.update x i (x i + 1) j ≠ y j))
      = (Finset.univ.filter (fun j => x j ≠ y j)).erase i := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_erase,
      Function.update_apply]
    by_cases hj : j = i
    · subst hj; simp [hyi]
    · simp [hj]
  rw [hset, Finset.card_erase_of_mem (by simp [hi])]
  have hmem : i ∈ Finset.univ.filter (fun j => x j ≠ y j) := by simp [hi]
  have hpos := Finset.card_pos.mpr ⟨i, hmem⟩
  omega

/-- For any two cube vertices there is a hypercube walk between them whose length is exactly the
Hamming distance. -/
lemma exists_walk_of_hammingDist {k : ℕ} :
    ∀ (n : ℕ) (x y : Cube k), HammingDist x y = n →
      ∃ w : (hypercube k).Walk x y, w.length = n := by
  intro n
  induction n with
  | zero =>
      intro x y h
      obtain rfl := HammingDist_eq_zero.mp h
      exact ⟨SimpleGraph.Walk.nil, rfl⟩
  | succ m ih =>
      intro x y h
      -- x ≠ y since HammingDist > 0, so a differing coordinate exists.
      have hxy : x ≠ y := by
        intro hxy; subst hxy; rw [HammingDist_self] at h; exact absurd h (by omega)
      obtain ⟨i, hi⟩ : ∃ i, x i ≠ y i := by
        by_contra hc; push_neg at hc; exact hxy (funext hc)
      set x' := flipCoord x i with hx'
      have hadj : (hypercube k).Adj x x' := by
        rw [hypercube_adj_iff, hx']; exact HammingDist_flip_self x i
      have hd : HammingDist x' y = m := by
        have := HammingDist_flip x y i hi
        rw [← hx'] at this; omega
      obtain ⟨w', hw'⟩ := ih x' y hd
      exact ⟨SimpleGraph.Walk.cons hadj w', by rw [SimpleGraph.Walk.length_cons, hw']⟩

/-- **Theorem 1.** In the hypercube, the graph distance equals the Hamming distance. -/
theorem hypercube_dist_eq_hammingDist {k : ℕ} (x y : Cube k) :
    (hypercube k).dist x y = HammingDist x y := by
  obtain ⟨w, hw⟩ := exists_walk_of_hammingDist (HammingDist x y) x y rfl
  refine le_antisymm ?_ ?_
  · calc (hypercube k).dist x y ≤ w.length := SimpleGraph.dist_le w
      _ = HammingDist x y := hw
  · have hr : (hypercube k).Reachable x y := ⟨w⟩
    obtain ⟨p, hp⟩ := hr.exists_walk_length_eq_dist
    rw [← hp]
    exact walk_length_ge p

variable {V : Type*} {G : SimpleGraph V} {k : ℕ} {ℓ : V → Cube k}

/-- **Theorem 2.** Under a labeling whose `G`-edges have label Hamming distance `≤ 1`, any `G`-walk
maps to a hypercube walk of no greater length. -/
theorem exists_image_walk
    (hℓ : ∀ {u v : V}, G.Adj u v → ℓ u = ℓ v ∨ HammingDist (ℓ u) (ℓ v) = 1)
    {u v : V} (w : G.Walk u v) :
    ∃ w' : (hypercube k).Walk (ℓ u) (ℓ v), w'.length ≤ w.length := by
  induction w with
  | nil => exact ⟨SimpleGraph.Walk.nil, le_rfl⟩
  | @cons a b c h p ih =>
      obtain ⟨w', hw'⟩ := ih
      rcases hℓ h with heq | hone
      · -- ℓ a = ℓ b: reuse the walk from ℓ b to ℓ c, transported to start at ℓ a.
        refine ⟨w'.copy heq.symm rfl, ?_⟩
        rw [SimpleGraph.Walk.length_copy, SimpleGraph.Walk.length_cons]
        omega
      · -- HammingDist (ℓ a) (ℓ b) = 1: prepend a single hypercube edge.
        have hadj : (hypercube k).Adj (ℓ a) (ℓ b) := hypercube_adj_iff.mpr hone
        refine ⟨SimpleGraph.Walk.cons hadj w', ?_⟩
        rw [SimpleGraph.Walk.length_cons, SimpleGraph.Walk.length_cons]
        omega

/-- **Theorem 3 (no-stretching).** A labeling whose `G`-edges have label Hamming distance `≤ 1` does
not stretch distances: the hypercube distance between labels is bounded by the graph distance. -/
theorem no_stretching
    (hG : G.Connected)
    (hℓ : ∀ {u v : V}, G.Adj u v → ℓ u = ℓ v ∨ HammingDist (ℓ u) (ℓ v) = 1)
    (u v : V) :
    (hypercube k).dist (ℓ u) (ℓ v) ≤ G.dist u v := by
  obtain ⟨p, hp⟩ := (hG.preconnected u v).exists_walk_length_eq_dist
  obtain ⟨w', hw'⟩ := exists_image_walk hℓ p
  calc (hypercube k).dist (ℓ u) (ℓ v) ≤ w'.length := SimpleGraph.dist_le w'
    _ ≤ p.length := hw'
    _ = G.dist u v := hp

end HypercubeNoStretch