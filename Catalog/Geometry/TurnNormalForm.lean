import Catalog.Geometry.HypercubeSplit

/-!
# Turn-minimal normal form in the split `Q_n = Q_1 □ Q_{n-1}`

For a snake `p` in `Q n` and a coordinate `i`, the *flip count* `flips p L i` is the turn count
of the row sequence `s ↦ p s i`, i.e. the number of direction changes of `p` viewed as a product
snake in `Q_1 □ Q_{n-1}` with row coordinate `i`.

* `TurnMinimal.sum_flips_eq`: the flip counts of all coordinates add up to the length `L`;
* `TurnMinimal.exists_flips_le`: some coordinate is flipped at most `L / n` times;
* `TurnMinimal.flips_lower_bound`: every coordinate is flipped at least
  `(L + 1) / (S + 1) - 1` times, where `S` bounds snakes in `Q_{n-1}`;
* `TurnMinimal.turn_normal_form`: **normal form** — every snake of length `L` in `Q_{1+b}`
  becomes, after relabelling coordinates (a hypercube automorphism, so with *no* loss of length),
  a product snake in `Q_1 □ Q_b` with at most `L / (1 + b)` direction changes, and no product
  decomposition can do better than `(L + 1) / (S + 1) - 1`.
-/

namespace TurnMinimal

/-- Number of steps `s < L` of `p` flipping coordinate `i`. -/
def flips {n : ℕ} (p : ℕ → Fin n → Bool) (L : ℕ) (i : Fin n) : ℕ :=
  turnCount (fun s => p s i) L

/-- Each step of a hypercube walk flips exactly one coordinate, so the flip counts sum to `L`. -/
theorem sum_flips_eq {n L : ℕ} {p : ℕ → Fin n → Bool} (hw : IsWalk (Q n) p L) :
    ∑ i, flips p L i = L := by
  have hstep : ∀ s ∈ Finset.range L,
      ∑ i : Fin n, (if p s i ≠ p (s + 1) i then 1 else 0) = 1 := by
    intro s hs
    have h := hw s (Finset.mem_range.1 hs)
    change hammingDist (p s) (p (s + 1)) = 1 at h
    rw [hammingDist, Finset.card_filter] at h
    exact h
  calc ∑ i, flips p L i
      = ∑ i : Fin n, ∑ s ∈ Finset.range L, (if p s i ≠ p (s + 1) i then 1 else 0) := by
        simp only [flips, turnCount, Finset.card_filter]
    _ = ∑ s ∈ Finset.range L, ∑ i : Fin n, (if p s i ≠ p (s + 1) i then 1 else 0) :=
        Finset.sum_comm
    _ = ∑ s ∈ Finset.range L, 1 := Finset.sum_congr rfl hstep
    _ = L := by simp

/-- Pigeonhole: some coordinate is flipped at most `L / n` times. -/
theorem exists_flips_le {n L : ℕ} (hn : 0 < n) {p : ℕ → Fin n → Bool}
    (hw : IsWalk (Q n) p L) : ∃ i, n * flips p L i ≤ L := by
  by_contra hcon
  push_neg at hcon
  have hsum := sum_flips_eq hw
  have : ∑ _i : Fin n, L < ∑ i, n * flips p L i :=
    Finset.sum_lt_sum_of_nonempty ⟨⟨0, hn⟩, Finset.mem_univ _⟩ (fun i _ => hcon i)
  rw [← Finset.mul_sum, hsum] at this
  simp at this

/-- Hamming distance is invariant under relabelling coordinates. -/
lemma hammingDist_comp_perm {n : ℕ} (σ : Equiv.Perm (Fin n)) (x y : Fin n → Bool) :
    hammingDist (x ∘ σ) (y ∘ σ) = hammingDist x y := by
  simp only [hammingDist, Finset.card_filter, Function.comp]
  exact Equiv.sum_comp σ (fun k => if x k ≠ y k then 1 else 0)

/-- Relabelling coordinates is an automorphism of `Q n`. -/
lemma Q_adj_comp_perm {n : ℕ} (σ : Equiv.Perm (Fin n)) (x y : Fin n → Bool) :
    (Q n).Adj x y ↔ (Q n).Adj (x ∘ σ) (y ∘ σ) := by
  change _ = 1 ↔ _ = 1
  rw [hammingDist_comp_perm]

lemma comp_perm_injective {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    Function.Injective (fun x : Fin n → Bool => x ∘ σ) := by
  intro x y h
  funext k
  simpa using congrFun h (σ.symm k)

/-- Lower bound: every coordinate of a snake in `Q (1 + b)` is flipped at least
`(L + 1) / (S + 1) - 1` times, if snakes in `Q b` have length at most `S`. -/
theorem flips_lower_bound {b L S : ℕ} {p : ℕ → Fin (1 + b) → Bool}
    (hp : IsSnake (Q (1 + b)) p L) (hS : SnakeBound (Q b) S) (i : Fin (1 + b)) :
    L + 1 ≤ (flips p L i + 1) * (S + 1) := by
  set σ : Equiv.Perm (Fin (1 + b)) := Equiv.swap (Fin.castAdd b 0) i
  have hp' : IsSnake (Q (1 + b)) (fun s => p s ∘ σ) L :=
    IsSnakeOn.map (comp_perm_injective σ) (Q_adj_comp_perm σ) hp
  have h := hypercube_succ_le_turns_mul hp' hS
  have hrow : turnCount (fun s => (split 1 b (p s ∘ σ)).1) L = flips p L i := by
    unfold flips turnCount
    congr 1
    apply Finset.filter_congr
    intro s _
    have key : ∀ f g : Fin 1 → Bool, f = g ↔ f 0 = g 0 := fun f g =>
      ⟨fun h => h ▸ rfl, fun h => funext fun j => by rw [Subsingleton.elim j 0]; exact h⟩
    simp only [split, Function.comp, ne_eq, key, σ, Equiv.swap_apply_left]
  rw [hrow] at h
  exact h

/-- **Turn-minimal normal form (split `Q_1 □ Q_b`).** For every snake of length `L` in
`Q (1 + b)` there is a coordinate `i` such that, using `i` as the row coordinate (equivalently,
after the coordinate relabelling swapping `i` to the front, which preserves the snake and its
length exactly), the product snake has at most `L / (1 + b)` direction changes; moreover any
row coordinate has at least `(L + 1) / (S + 1) - 1` direction changes. -/
theorem turn_normal_form {b L S : ℕ} {p : ℕ → Fin (1 + b) → Bool}
    (hp : IsSnake (Q (1 + b)) p L) (hS : SnakeBound (Q b) S) :
    ∃ i, (1 + b) * flips p L i ≤ L ∧ L + 1 ≤ (flips p L i + 1) * (S + 1) := by
  obtain ⟨i, hi⟩ := exists_flips_le (by omega) hp.isWalk
  exact ⟨i, hi, flips_lower_bound hp hS i⟩

end TurnMinimal