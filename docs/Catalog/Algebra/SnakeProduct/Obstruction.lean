import Algebra.SnakeProduct.Comb

/-!
# The 3/4 obstruction: product-supported snakes cannot lose only `O(L+K)`

The conjecture under investigation asserts an absolute constant `C` with

  `s(m + n) ≥ (L + 1)(K + 1) - C (L + K)`

for snakes of lengths `L` in `Q_m` and `K` in `Q_n`, the proposed mechanism being that
the Cartesian product of the two snakes is a long grid walk whose defects are *localised*
at the interfaces between the two factors.

Here we refute that mechanism in a strong, quantitative form.  Any snake **supported on
the product vertex set** `{(p i, q j)}` is an induced path in the grid `P_{L+1} □ P_{K+1}`,
and an induced path can never contain all four vertices of a `2 × 2` square (they would
span a `4`-cycle, while four indices of a path admit at most three consecutive pairs).
Tiling the grid by `2 × 2` squares gives the hard cap

  `#vertices ≤ 3 ⌈(L+1)/2⌉ ⌈(K+1)/2⌉ ≈ (3/4)(L+1)(K+1)`,

which for `L = K = N` large is *below* `(N+1)^2 - 2CN` for any fixed `C`.

## Main results

* `SnakeProduct.grid_adj_index` : grid-adjacent vertices of a product-supported snake
  have adjacent indices.
* `SnakeProduct.no_two_by_two` : a product-supported snake omits a corner of every
  `2 × 2` square.
* `SnakeProduct.product_support_card_bound` : the `3/4` cap.
* `SnakeProduct.product_mechanism_fails` : for every constant `C` and every
  `N ≥ 8C + 7`, no snake supported on a product of two length-`N` snakes reaches
  `(N+1)^2 - C(N+N)`.
-/

namespace SnakeProduct

open Finset

variable {α β : Type*} [Fintype α] [Fintype β] {L K M : ℕ}
  {p : ℕ → α → Bool} {q : ℕ → β → Bool} {v : ℕ → α ⊕ β → Bool} {a b : ℕ → ℕ}

/-- A snake supported on the product of two snakes visits distinct grid points. -/
lemma grid_inj (hv : IsSnake (α ⊕ β) M v)
    (hav : ∀ s, s ≤ M → v s = Sum.elim (p (a s)) (q (b s)))
    {s s' : ℕ} (hs : s ≤ M) (hs' : s' ≤ M) (h1 : a s = a s') (h2 : b s = b s') :
    s = s' :=
  hv.injOn hs hs' (by rw [hav s hs, hav s' hs', h1, h2])

/-- If two vertices of a product-supported snake are neighbours in the grid, then their
positions along the snake are neighbours. -/
lemma grid_adj_index (hp : IsSnake α L p) (hq : IsSnake β K q) (hv : IsSnake (α ⊕ β) M v)
    (ha : ∀ s, s ≤ M → a s ≤ L) (hb : ∀ s, s ≤ M → b s ≤ K)
    (hav : ∀ s, s ≤ M → v s = Sum.elim (p (a s)) (q (b s)))
    {s s' : ℕ} (hs : s ≤ M) (hs' : s' ≤ M)
    (h : nd (a s) (a s') + nd (b s) (b s') = 1) : nd s s' = 1 := by
  have hd : hdist (v s) (v s') = 1 := by
    rw [hav s hs, hav s' hs']
    rcases (show (nd (a s) (a s') = 0 ∧ nd (b s) (b s') = 1) ∨
        (nd (a s) (a s') = 1 ∧ nd (b s) (b s') = 0) by omega) with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · have e : a s = a s' := by simp only [nd] at h1; omega
      rw [e]
      exact hdist_prod_row hq (hb s hs) (hb s' hs') (by simp only [nd] at h2; omega)
    · have e : b s = b s' := by simp only [nd] at h2; omega
      rw [e]
      exact hdist_prod_col hp (ha s hs) (ha s' hs') (by simp only [nd] at h1; omega)
  rcases Nat.lt_or_ge (nd s s') 2 with h2 | h2
  · rcases (show nd s s' = 0 ∨ nd s s' = 1 by omega) with h3 | h3
    · exfalso
      have : s = s' := by simp only [nd] at h3; omega
      rw [this, hdist_self] at hd
      omega
    · exact h3
  · exfalso
    have := hv.dist_ge_two hs hs' (by simp only [nd] at h2; omega)
    omega

/-- **No `2 × 2` square.**  A product-supported snake cannot contain all four corners of a
unit square of the grid: the four corners would span a `4`-cycle, but four positions along
a path support at most three adjacent pairs. -/
lemma no_two_by_two (hp : IsSnake α L p) (hq : IsSnake β K q) (hv : IsSnake (α ⊕ β) M v)
    (ha : ∀ s, s ≤ M → a s ≤ L) (hb : ∀ s, s ≤ M → b s ≤ K)
    (hav : ∀ s, s ≤ M → v s = Sum.elim (p (a s)) (q (b s)))
    {i j s₁ s₂ s₃ s₄ : ℕ} (h₁ : s₁ ≤ M) (h₂ : s₂ ≤ M) (h₃ : s₃ ≤ M) (h₄ : s₄ ≤ M)
    (e₁ : a s₁ = i ∧ b s₁ = j) (e₂ : a s₂ = i + 1 ∧ b s₂ = j)
    (e₃ : a s₃ = i ∧ b s₃ = j + 1) (e₄ : a s₄ = i + 1 ∧ b s₄ = j + 1) : False := by
  have k₁₂ : nd s₁ s₂ = 1 :=
    grid_adj_index hp hq hv ha hb hav h₁ h₂ (by simp only [nd, e₁.1, e₁.2, e₂.1, e₂.2]; omega)
  have k₁₃ : nd s₁ s₃ = 1 :=
    grid_adj_index hp hq hv ha hb hav h₁ h₃ (by simp only [nd, e₁.1, e₁.2, e₃.1, e₃.2]; omega)
  have k₂₄ : nd s₂ s₄ = 1 :=
    grid_adj_index hp hq hv ha hb hav h₂ h₄ (by simp only [nd, e₂.1, e₂.2, e₄.1, e₄.2]; omega)
  have k₃₄ : nd s₃ s₄ = 1 :=
    grid_adj_index hp hq hv ha hb hav h₃ h₄ (by simp only [nd, e₃.1, e₃.2, e₄.1, e₄.2]; omega)
  have hne23 : s₂ ≠ s₃ := by
    intro h; rw [h, e₃.1] at e₂; omega
  have hne14 : s₁ ≠ s₄ := by
    intro h; rw [h, e₄.1] at e₁; omega
  simp only [nd] at k₁₂ k₁₃ k₂₄ k₃₄
  omega

/-- **The `3/4` cap.**  A snake supported on the product of a length-`L` snake and a
length-`K` snake has at most `3 ⌈(L+1)/2⌉ ⌈(K+1)/2⌉` vertices. -/
theorem product_support_card_bound (hp : IsSnake α L p) (hq : IsSnake β K q)
    (hv : IsSnake (α ⊕ β) M v)
    (ha : ∀ s, s ≤ M → a s ≤ L) (hb : ∀ s, s ≤ M → b s ≤ K)
    (hav : ∀ s, s ≤ M → v s = Sum.elim (p (a s)) (q (b s))) :
    M + 1 ≤ 3 * ((L + 2) / 2 * ((K + 2) / 2)) := by
  classical
  set S : Finset (ℕ × ℕ) := (Finset.range (M + 1)).image (fun s => (a s, b s)) with hSdef
  set T : Finset (ℕ × ℕ) :=
    (Finset.range ((L + 2) / 2)) ×ˢ (Finset.range ((K + 2) / 2)) with hTdef
  have hcard : S.card = M + 1 := by
    rw [hSdef, Finset.card_image_of_injOn, Finset.card_range]
    intro x hx y hy hxy
    simp only [Finset.coe_range, Set.mem_Iio] at hx hy
    exact grid_inj hv hav (by omega) (by omega) (congrArg Prod.fst hxy) (congrArg Prod.snd hxy)
  -- each grid point of `S` lies in a `2 × 2` block
  have hmem : ∀ z ∈ S, z.1 ≤ L ∧ z.2 ≤ K := by
    intro z hz
    rw [hSdef, Finset.mem_image] at hz
    obtain ⟨s, hs, rfl⟩ := hz
    rw [Finset.mem_range] at hs
    exact ⟨ha s (by omega), hb s (by omega)⟩
  have hmaps : Set.MapsTo (fun z : ℕ × ℕ => (z.1 / 2, z.2 / 2)) ↑S ↑T := by
    intro z hz
    obtain ⟨h1, h2⟩ := hmem z hz
    simp only [hTdef, Finset.coe_product, Set.mem_prod, Finset.coe_range, Set.mem_Iio]
    exact ⟨by omega, by omega⟩
  -- every fibre has at most three elements
  have hfib : ∀ w ∈ T, ({z ∈ S | (z.1 / 2, z.2 / 2) = w}).card ≤ 3 := by
    intro w _
    obtain ⟨u, y⟩ := w
    by_contra hc
    push_neg at hc
    set F : Finset (ℕ × ℕ) := ({2 * u, 2 * u + 1} : Finset ℕ) ×ˢ ({2 * y, 2 * y + 1} : Finset ℕ)
      with hFdef
    have hFcard : F.card = 4 := by
      rw [hFdef, Finset.card_product, Finset.card_pair (by omega), Finset.card_pair (by omega)]
    have hsub : {z ∈ S | (z.1 / 2, z.2 / 2) = (u, y)} ⊆ F := by
      intro z hz
      simp only [Finset.mem_filter, Prod.mk.injEq] at hz
      simp only [hFdef, Finset.mem_product, Finset.mem_insert, Finset.mem_singleton]
      exact ⟨by omega, by omega⟩
    have hEq : {z ∈ S | (z.1 / 2, z.2 / 2) = (u, y)} = F :=
      Finset.eq_of_subset_of_card_le hsub (by omega)
    -- all four corners of the block belong to `S`
    have corner : ∀ x y' : ℕ, (x, y') ∈ F → (x, y') ∈ S := by
      intro x y' hxy
      have : (x, y') ∈ {z ∈ S | (z.1 / 2, z.2 / 2) = (u, y)} := by rw [hEq]; exact hxy
      exact (Finset.mem_filter.mp this).1
    have mem_of : ∀ x y' : ℕ, (x, y') ∈ S → ∃ s, s ≤ M ∧ a s = x ∧ b s = y' := by
      intro x y' hxy
      rw [hSdef, Finset.mem_image] at hxy
      obtain ⟨s, hs, hs2⟩ := hxy
      rw [Finset.mem_range] at hs
      exact ⟨s, by omega, congrArg Prod.fst hs2, congrArg Prod.snd hs2⟩
    have hF1 : ((2 * u, 2 * y) : ℕ × ℕ) ∈ F := by
      simp [hFdef, Finset.mem_product]
    have hF2 : ((2 * u + 1, 2 * y) : ℕ × ℕ) ∈ F := by
      simp [hFdef, Finset.mem_product]
    have hF3 : ((2 * u, 2 * y + 1) : ℕ × ℕ) ∈ F := by
      simp [hFdef, Finset.mem_product]
    have hF4 : ((2 * u + 1, 2 * y + 1) : ℕ × ℕ) ∈ F := by
      simp [hFdef, Finset.mem_product]
    obtain ⟨s₁, hs₁, e₁⟩ := mem_of _ _ (corner _ _ hF1)
    obtain ⟨s₂, hs₂, e₂⟩ := mem_of _ _ (corner _ _ hF2)
    obtain ⟨s₃, hs₃, e₃⟩ := mem_of _ _ (corner _ _ hF3)
    obtain ⟨s₄, hs₄, e₄⟩ := mem_of _ _ (corner _ _ hF4)
    exact no_two_by_two hp hq hv ha hb hav hs₁ hs₂ hs₃ hs₄ e₁ e₂ e₃ e₄
  calc M + 1 = S.card := hcard.symm
    _ = ∑ w ∈ T, ({z ∈ S | (z.1 / 2, z.2 / 2) = w}).card :=
        Finset.card_eq_sum_card_fiberwise hmaps
    _ ≤ ∑ _w ∈ T, 3 := Finset.sum_le_sum hfib
    _ = T.card * 3 := by rw [Finset.sum_const, smul_eq_mul]
    _ = 3 * ((L + 2) / 2 * ((K + 2) / 2)) := by
        rw [hTdef, Finset.card_product, Finset.card_range, Finset.card_range]; ring

/-- **The product mechanism fails.**  Fix any constant `C`.  As soon as both snakes are
longer than `8C + 11`, no snake supported on their product can have length
`(L+1)(K+1) - C(L+K)`; in fact its length `M` satisfies `M + C(L+K) < (L+1)(K+1)`.  Thus
the conjectured "multiplicative main term with `O(L+K)` loss" is unreachable by product
constructions, whatever the absolute constant: the loss of a product construction is
`Θ(LK)`. -/
theorem product_mechanism_fails (C : ℕ) (hL : 8 * C + 11 ≤ L) (hK : 8 * C + 11 ≤ K)
    (hp : IsSnake α L p) (hq : IsSnake β K q) (hv : IsSnake (α ⊕ β) M v)
    (ha : ∀ s, s ≤ M → a s ≤ L) (hb : ∀ s, s ≤ M → b s ≤ K)
    (hav : ∀ s, s ≤ M → v s = Sum.elim (p (a s)) (q (b s))) :
    M + C * (L + K) < (L + 1) * (K + 1) := by
  have hcap := product_support_card_bound hp hq hv ha hb hav
  have h2L : 2 * ((L + 2) / 2) ≤ L + 2 := by omega
  have h2K : 2 * ((K + 2) / 2) ≤ K + 2 := by omega
  have h4 : 4 * (M + 1) ≤ 3 * ((L + 2) * (K + 2)) := by
    calc 4 * (M + 1) ≤ 4 * (3 * ((L + 2) / 2 * ((K + 2) / 2))) := by omega
      _ = 3 * (2 * ((L + 2) / 2) * (2 * ((K + 2) / 2))) := by ring
      _ ≤ 3 * ((L + 2) * (K + 2)) := Nat.mul_le_mul_left 3 (Nat.mul_le_mul h2L h2K)
  have hLK : (8 * C + 11) * K ≤ L * K := Nat.mul_le_mul_right K hL
  have hKL : (8 * C + 11) * L ≤ K * L := Nat.mul_le_mul_right L hK
  nlinarith [h4, hLK, hKL, hL, hK]

/-- **Consistency of the two bounds.**  The comb is itself product-supported, so it must
respect the `3/4` cap; instantiating the cap at the comb turns the pair of results into a
sandwich `⌊L/2⌋(K+2) + K + 1 ≤ 3 ⌈(L+1)/2⌉ ⌈(K+1)/2⌉` for the number of vertices of a
product-supported snake. -/
theorem comb_within_cap (hp : IsSnake α L p) (hq : IsSnake β K q) :
    combLen L K + 1 ≤ 3 * ((L + 2) / 2 * ((K + 2) / 2)) :=
  product_support_card_bound hp hq (isSnake_comb hp hq)
    (fun s hs => combRow_le L K s hs) (fun s _ => combCol_le K s) (fun _ _ => rfl)

end SnakeProduct