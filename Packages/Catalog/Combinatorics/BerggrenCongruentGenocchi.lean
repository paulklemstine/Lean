import Combinatorics.BerggrenCongruentMain
import Combinatorics.BerggrenCongruentFermat

/-!
# An unconditional infinite family: primes `p ≡ 3 (mod 8)` are not congruent

Genocchi's theorem, proved here as a law of the Berggren tree: if `p ≡ 3 (mod 8)` is
prime then **no node of the tree has area `p k²`**, so `p` is not a congruent number.

The proof is the tree-native descent of `BerggrenCongruentFermat.lean` with the prime `p`
carried along.  Writing a node area as the product of the four pairwise coprime factors
`m`, `n`, `m − n`, `m + n`, the prime lands in exactly one of them, giving four shapes.
Three of the shapes (and one half of the fourth) are impossible modulo `8`; the surviving
shape produces a strictly smaller node whose area is again `p` times a square.

## Main results

* `split_prime_sq` — coprime factorisation of `p k²`.
* `four_shapes_of_prime` — the four possible shapes of a node of area `p k²`.
* `prime_descent_step` — the surviving shape descends.
* `euclidArea_ne_prime_mul_sq` — no node has area `p k²` when `p ≡ 3 (mod 8)`.
* `prime_three_mod_eight_not_congruent` — Genocchi's theorem.
-/

namespace BerggrenCongruent

open BerggrenStars

/-! ### Arithmetic preliminaries -/

/-- **Coprime factorisation of `p k²`.**  If `A B = p k²` with `A`, `B` positive and
coprime and `p` a positive prime, then the prime goes to exactly one of the factors and
the other factor is a square. -/
theorem split_prime_sq {p A B k : ℤ} (hp : Prime p) (hp0 : 0 < p) (hA : 0 < A) (hB : 0 < B)
    (hcop : IsCoprime A B) (h : A * B = p * k ^ 2) :
    (∃ a b : ℤ, 0 < a ∧ 0 < b ∧ A = p * a ^ 2 ∧ B = b ^ 2) ∨
    (∃ a b : ℤ, 0 < a ∧ 0 < b ∧ A = a ^ 2 ∧ B = p * b ^ 2) := by
  have hdvd : p ∣ A * B := ⟨k ^ 2, h⟩
  rcases hp.dvd_or_dvd hdvd with hpA | hpB
  · obtain ⟨A₁, hA₁⟩ := hpA
    have hA₁0 : 0 < A₁ := by
      rcases le_or_gt A₁ 0 with h' | h'
      · exfalso; nlinarith [hA, hp0]
      · exact h'
    have hcop₁ : IsCoprime A₁ B := hcop.of_isCoprime_of_dvd_left ⟨p, by rw [hA₁]; ring⟩
    have hmul : A₁ * B = k ^ 2 := by
      have : p * (A₁ * B) = p * k ^ 2 := by rw [← h, hA₁]; ring
      exact mul_left_cancel₀ hp0.ne' this
    obtain ⟨a, ha0, ha⟩ := sq_of_isCoprime_pos hA₁0 hcop₁ hmul
    obtain ⟨b, hb0, hb⟩ := sq_of_isCoprime_pos hB hcop₁.symm (by rw [← hmul]; ring)
    exact Or.inl ⟨a, b, ha0, hb0, by rw [hA₁, ha], hb⟩
  · obtain ⟨B₁, hB₁⟩ := hpB
    have hB₁0 : 0 < B₁ := by
      rcases le_or_gt B₁ 0 with h' | h'
      · exfalso; nlinarith [hB, hp0]
      · exact h'
    have hcop₁ : IsCoprime A B₁ := hcop.of_isCoprime_of_dvd_right ⟨p, by rw [hB₁]; ring⟩
    have hmul : A * B₁ = k ^ 2 := by
      have : p * (A * B₁) = p * k ^ 2 := by rw [← h, hB₁]; ring
      exact mul_left_cancel₀ hp0.ne' this
    obtain ⟨a, ha0, ha⟩ := sq_of_isCoprime_pos hA hcop₁ hmul
    obtain ⟨b, hb0, hb⟩ := sq_of_isCoprime_pos hB₁0 hcop₁.symm (by rw [← hmul]; ring)
    exact Or.inr ⟨a, b, ha0, hb0, ha, by rw [hB₁, hb]⟩

/-- An odd square is `1` modulo `8`. -/
private theorem odd_sq_form {z : ℤ} (h : Odd z) : ∃ t : ℤ, z ^ 2 = 8 * t + 1 := by
  obtain ⟨j, hj⟩ := h
  rcases Int.even_or_odd j with ⟨i, hi⟩ | ⟨i, hi⟩
  · exact ⟨i * (2 * i + 1), by rw [hj, hi]; ring⟩
  · exact ⟨(2 * i + 1) * (i + 1), by rw [hj, hi]; ring⟩

/-- An even square is four times a square. -/
private theorem even_sq_form {z : ℤ} (h : Even z) : ∃ w : ℤ, z ^ 2 = 4 * w ^ 2 := by
  obtain ⟨j, hj⟩ := h
  exact ⟨j, by rw [hj]; ring⟩

/-- The pairwise coprimality of the four factors of a node area. -/
theorem param_coprime_factors {m n : ℤ} (h : IsParam m n) :
    IsCoprime m n ∧ IsCoprime m (m - n) ∧ IsCoprime m (m + n) ∧ IsCoprime n (m - n) ∧
      IsCoprime n (m + n) ∧ IsCoprime (m - n) (m + n) := by
  have hmn : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr h.cop
  have hmC : IsCoprime m (m - n) := by
    have := (hmn.neg_right).add_mul_left_right 1
    rwa [show -n + m * 1 = m - n by ring] at this
  have hmD : IsCoprime m (m + n) := by
    have := hmn.add_mul_left_right 1
    rwa [show n + m * 1 = m + n by ring] at this
  have hnC : IsCoprime n (m - n) := by
    have := hmn.symm.add_mul_left_right (-1)
    rwa [show m + n * (-1) = m - n by ring] at this
  have hnD : IsCoprime n (m + n) := by
    have := hmn.symm.add_mul_left_right 1
    rwa [show m + n * 1 = m + n by ring] at this
  have hCD : IsCoprime (m - n) (m + n) := by
    have h2 : IsCoprime (m - n) 2 := isCoprime_two_of_odd h.par
    have := (h2.mul_right hnC.symm).add_mul_left_right 1
    rwa [show 2 * n + (m - n) * 1 = m + n by ring] at this
  exact ⟨hmn, hmC, hmD, hnC, hnD, hCD⟩

/-! ### The four shapes -/

/-- **The four shapes of a node of area `p k²`.**  The prime lands in exactly one of the
four pairwise coprime factors. -/
theorem four_shapes_of_prime {p m n k : ℤ} (hp : Prime p) (hp0 : 0 < p) (h : IsParam m n)
    (hk : euclidArea m n = p * k ^ 2) :
    (∃ a b c d : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ 0 < d ∧
        m = p * a ^ 2 ∧ n = b ^ 2 ∧ m - n = c ^ 2 ∧ m + n = d ^ 2) ∨
    (∃ a b c d : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ 0 < d ∧
        m = a ^ 2 ∧ n = p * b ^ 2 ∧ m - n = c ^ 2 ∧ m + n = d ^ 2) ∨
    (∃ a b c d : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ 0 < d ∧
        m = a ^ 2 ∧ n = b ^ 2 ∧ m - n = p * c ^ 2 ∧ m + n = d ^ 2) ∨
    (∃ a b c d : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ 0 < d ∧
        m = a ^ 2 ∧ n = b ^ 2 ∧ m - n = c ^ 2 ∧ m + n = p * d ^ 2) := by
  obtain ⟨hmn, hmC, hmD, hnC, hnD, hCD⟩ := param_coprime_factors h
  have hm : 0 < m := h.mpos
  have hn : 0 < n := h.npos
  have hlt : n < m := h.lt
  have hCpos : (0 : ℤ) < m - n := by linarith
  have hDpos : (0 : ℤ) < m + n := by linarith
  have hRpos : (0 : ℤ) < n * ((m - n) * (m + n)) := by positivity
  have hsplit : m * (n * ((m - n) * (m + n))) = p * k ^ 2 := by
    rw [← hk]; simp only [euclidArea]; ring
  rcases split_prime_sq hp hp0 hm hRpos (hmn.mul_right (hmC.mul_right hmD)) hsplit with
    ⟨a, R, ha0, hR0, ha, hR⟩ | ⟨a, R, ha0, hR0, ha, hR⟩
  · -- `m = p a²`, the rest is a square
    obtain ⟨b, hb0, hb⟩ := sq_of_isCoprime_pos hn (hnC.mul_right hnD) (by rw [← hR])
    obtain ⟨c, hc0, hc⟩ := sq_of_isCoprime_pos hCpos (hnC.symm.mul_right hCD)
      (by rw [← hR]; ring)
    obtain ⟨d, hd0, hd⟩ := sq_of_isCoprime_pos hDpos (hnD.symm.mul_right hCD.symm)
      (by rw [← hR]; ring)
    exact Or.inl ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩
  · -- `m = a²`, and the prime is in `n (m−n)(m+n)`
    have hCDpos : (0 : ℤ) < (m - n) * (m + n) := by positivity
    rcases split_prime_sq hp hp0 hn hCDpos (hnC.mul_right hnD) (by rw [hR]) with
      ⟨b, S, hb0, hS0, hb, hS⟩ | ⟨b, S, hb0, hS0, hb, hS⟩
    · obtain ⟨c, hc0, hc⟩ := sq_of_isCoprime_pos hCpos hCD (by rw [← hS])
      obtain ⟨d, hd0, hd⟩ := sq_of_isCoprime_pos hDpos hCD.symm (by rw [← hS]; ring)
      exact Or.inr (Or.inl ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩)
    · rcases split_prime_sq hp hp0 hCpos hDpos hCD (by rw [hS]) with
        ⟨c, d, hc0, hd0, hc, hd⟩ | ⟨c, d, hc0, hd0, hc, hd⟩
      · exact Or.inr (Or.inr (Or.inl ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩))
      · exact Or.inr (Or.inr (Or.inr ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩))

/-! ### Three of the four shapes die modulo 8 -/

/-- An integer whose square is odd is odd. -/
private theorem odd_of_odd_sq {z : ℤ} (h : Odd (z ^ 2)) : Odd z := by
  rcases Int.even_or_odd z with hze | hzo
  · exact absurd h (by simp [Int.even_pow, hze, Int.not_odd_iff_even])
  · exact hzo

/-- In a node, `m + n` is odd. -/
private theorem param_odd_add {m n : ℤ} (h : IsParam m n) : Odd (m + n) := by
  obtain ⟨t, ht⟩ := h.par
  exact ⟨t + n, by linarith⟩

/-- Shape 1 (`m = p a²`) is impossible for `p ≡ 3 (mod 8)`. -/
private theorem shape_one_absurd {p m n a c d : ℤ} (hp8 : p % 8 = 3) (h : IsParam m n)
    (ha : m = p * a ^ 2) (hc : m - n = c ^ 2) (hd : m + n = d ^ 2) : False := by
  obtain ⟨P, hP⟩ : ∃ P : ℤ, p = 8 * P + 3 := ⟨p / 8, by omega⟩
  have hcodd : Odd c := odd_of_odd_sq (by rw [← hc]; exact h.par)
  have hdodd : Odd d := odd_of_odd_sq (by rw [← hd]; exact param_odd_add h)
  obtain ⟨tc, htc⟩ := odd_sq_form hcodd
  obtain ⟨td, htd⟩ := odd_sq_form hdodd
  have hsum : c ^ 2 + d ^ 2 = 2 * m := by rw [← hc, ← hd]; ring
  have key : 8 * tc + 1 + (8 * td + 1) = 2 * (p * a ^ 2) := by rw [← htc, ← htd, hsum, ha]
  rcases Int.even_or_odd a with hae | hao
  · obtain ⟨w, hw⟩ := even_sq_form hae
    have key2 : 8 * tc + 1 + (8 * td + 1) = 8 * (p * w ^ 2) := by rw [key, hw]; ring
    omega
  · obtain ⟨A, hA⟩ := odd_sq_form hao
    have key2 : 8 * tc + 1 + (8 * td + 1) = 16 * (p * A) + 16 * P + 6 := by
      rw [key, hA, hP]; ring
    omega

/-- Shape 2 with `m` even is impossible. -/
private theorem shape_two_even_absurd {m n a c d : ℤ} (h : IsParam m n)
    (hae : Even a) (ha : m = a ^ 2) (hc : m - n = c ^ 2) (hd : m + n = d ^ 2) : False := by
  have hcodd : Odd c := odd_of_odd_sq (by rw [← hc]; exact h.par)
  have hdodd : Odd d := odd_of_odd_sq (by rw [← hd]; exact param_odd_add h)
  obtain ⟨tc, htc⟩ := odd_sq_form hcodd
  obtain ⟨td, htd⟩ := odd_sq_form hdodd
  obtain ⟨w, hw⟩ := even_sq_form hae
  have hsum : c ^ 2 + d ^ 2 = 2 * m := by rw [← hc, ← hd]; ring
  have key : 8 * tc + 1 + (8 * td + 1) = 8 * w ^ 2 := by rw [← htc, ← htd, hsum, ha, hw]; ring
  omega

/-- Shape 3 (`m − n = p c²`) is impossible for `p ≡ 3 (mod 8)`. -/
private theorem shape_three_absurd {p m n a b c d : ℤ} (hp8 : p % 8 = 3) (h : IsParam m n)
    (ha : m = a ^ 2) (hb : n = b ^ 2) (hc : m - n = p * c ^ 2) (hd : m + n = d ^ 2) :
    False := by
  obtain ⟨P, hP⟩ : ∃ P : ℤ, p = 8 * P + 3 := ⟨p / 8, by omega⟩
  have hCodd : Odd (p * c ^ 2) := by rw [← hc]; exact h.par
  have hcodd : Odd c := by
    rcases Int.even_or_odd c with hce | hco
    · exact absurd hCodd (by simp [Int.even_pow, hce, Int.not_odd_iff_even])
    · exact hco
  have hdodd : Odd d := odd_of_odd_sq (by rw [← hd]; exact param_odd_add h)
  obtain ⟨tc, htc⟩ := odd_sq_form hcodd
  obtain ⟨td, htd⟩ := odd_sq_form hdodd
  obtain ⟨Q, hQ⟩ : ∃ Q : ℤ, p * c ^ 2 = 64 * Q + 8 * P + 24 * tc + 3 :=
    ⟨P * tc, by rw [hP, htc]; ring⟩
  have hsum : a ^ 2 + b ^ 2 = d ^ 2 := by rw [← ha, ← hb, ← hd]
  have hdiff : a ^ 2 - b ^ 2 = p * c ^ 2 := by rw [← ha, ← hb, ← hc]
  have hpar : Odd (m - n) := h.par
  obtain ⟨sp, hsp⟩ := hpar
  rcases Int.even_or_odd a with hae | hao
  · obtain ⟨wa, hwa⟩ := even_sq_form hae
    rcases Int.even_or_odd b with hbe | hbo
    · -- both even: `m − n` would be even
      obtain ⟨wb, hwb⟩ := even_sq_form hbe
      rw [ha, hb, hwa, hwb] at hsp
      omega
    · obtain ⟨B, hB⟩ := odd_sq_form hbo
      rw [hwa, hB, htd] at hsum
      rw [hwa, hB, hQ] at hdiff
      omega
  · obtain ⟨A, hA⟩ := odd_sq_form hao
    rcases Int.even_or_odd b with hbe | hbo
    · obtain ⟨wb, hwb⟩ := even_sq_form hbe
      rw [hA, hwb, htd] at hsum
      rw [hA, hwb, hQ] at hdiff
      omega
    · obtain ⟨B, hB⟩ := odd_sq_form hbo
      rw [ha, hb, hA, hB] at hsp
      omega

/-- Shape 4 (`m + n = p d²`) is impossible for `p ≡ 3 (mod 8)`. -/
private theorem shape_four_absurd {p m n a b c d : ℤ} (hp8 : p % 8 = 3) (h : IsParam m n)
    (ha : m = a ^ 2) (hb : n = b ^ 2) (hc : m - n = c ^ 2) (hd : m + n = p * d ^ 2) :
    False := by
  obtain ⟨P, hP⟩ : ∃ P : ℤ, p = 8 * P + 3 := ⟨p / 8, by omega⟩
  have hcodd : Odd c := odd_of_odd_sq (by rw [← hc]; exact h.par)
  have hDodd : Odd (p * d ^ 2) := by rw [← hd]; exact param_odd_add h
  have hdodd : Odd d := by
    rcases Int.even_or_odd d with hde | hdo
    · exact absurd hDodd (by simp [Int.even_pow, hde, Int.not_odd_iff_even])
    · exact hdo
  obtain ⟨tc, htc⟩ := odd_sq_form hcodd
  obtain ⟨td, htd⟩ := odd_sq_form hdodd
  obtain ⟨Q, hQ⟩ : ∃ Q : ℤ, p * d ^ 2 = 64 * Q + 8 * P + 24 * td + 3 :=
    ⟨P * td, by rw [hP, htd]; ring⟩
  have hsum : a ^ 2 + b ^ 2 = p * d ^ 2 := by rw [← ha, ← hb, ← hd]
  have hdiff : a ^ 2 - b ^ 2 = c ^ 2 := by rw [← ha, ← hb, ← hc]
  obtain ⟨sp, hsp⟩ := h.par
  rcases Int.even_or_odd a with hae | hao
  · obtain ⟨wa, hwa⟩ := even_sq_form hae
    rcases Int.even_or_odd b with hbe | hbo
    · obtain ⟨wb, hwb⟩ := even_sq_form hbe
      rw [ha, hb, hwa, hwb] at hsp
      omega
    · obtain ⟨B, hB⟩ := odd_sq_form hbo
      rw [hwa, hB, htc] at hdiff
      omega
  · obtain ⟨A, hA⟩ := odd_sq_form hao
    rcases Int.even_or_odd b with hbe | hbo
    · obtain ⟨wb, hwb⟩ := even_sq_form hbe
      rw [hA, hwb, htc] at hdiff
      rw [hA, hwb, hQ] at hsum
      omega
    · obtain ⟨B, hB⟩ := odd_sq_form hbo
      rw [ha, hb, hA, hB] at hsp
      omega

/-! ### The surviving shape descends -/

/-- The extraction lemma with the prime carried along: a primitive triple with even leg
`u`, odd leg `v` and hypotenuse `a` whose leg product is `2p` times a square comes from
Euclid parameters `r, s` with `r < a` whose area is `p` times a square. -/
private theorem prime_descent_from_pair {p u v a b₁ : ℤ} (hu : 0 < u) (hv : 0 < v)
    (ha : 0 < a) (hcop : IsCoprime u v) (hsum : u ^ 2 + v ^ 2 = a ^ 2)
    (hprod : u * v = 2 * p * b₁ ^ 2) (heven : Even u) :
    ∃ r s k' : ℤ, IsParam r s ∧ r < a ∧ euclidArea r s = p * k' ^ 2 := by
  obtain ⟨u₁, hu₁⟩ := heven
  have hu₁' : u = 2 * u₁ := by omega
  have hu₁0 : 0 < u₁ := by omega
  have hprod₁ : u₁ * v = p * b₁ ^ 2 := by
    have h2 : 2 * (u₁ * v) = 2 * (p * b₁ ^ 2) := by
      calc 2 * (u₁ * v) = (2 * u₁) * v := by ring
        _ = u * v := by rw [← hu₁']
        _ = 2 * p * b₁ ^ 2 := hprod
        _ = 2 * (p * b₁ ^ 2) := by ring
    linarith
  have hvodd : Odd v := by
    rcases Int.even_or_odd v with hve | hvo
    · exfalso
      have h2 : (2 : ℤ) ∣ u := ⟨u₁, hu₁'⟩
      have h2' : (2 : ℤ) ∣ v := hve.two_dvd
      have := hcop.isUnit_of_dvd' h2 h2'
      rw [Int.isUnit_iff] at this
      omega
    · exact hvo
  have hgcd : Int.gcd v u = 1 := Int.isCoprime_iff_gcd_eq_one.mp hcop.symm
  have hnode : IsNode (v, u, a) :=
    (isNode_iff v u a).mpr ⟨hv, hu, ha, by linarith [hsum], hgcd, hvodd⟩
  obtain ⟨r, t, hpar, hrt⟩ := isNode_param hnode
  have hv' : v = r ^ 2 - t ^ 2 := congrArg Prod.fst hrt
  have hu' : u = 2 * r * t := congrArg (fun w : Vec => w.2.1) hrt
  have ha' : a = r ^ 2 + t ^ 2 := congrArg (fun w : Vec => w.2.2) hrt
  refine ⟨r, t, b₁, hpar, ?_, ?_⟩
  · have ht : 0 < t := hpar.npos
    have hr : 0 < r := hpar.mpos
    nlinarith [ha', hr, ht]
  · have hrt' : r * t = u₁ := by
      have : 2 * (r * t) = 2 * u₁ := by rw [← hu₁', hu']; ring
      linarith
    calc euclidArea r t = (r * t) * (r ^ 2 - t ^ 2) := rfl
      _ = u₁ * v := by rw [hrt', hv']
      _ = p * b₁ ^ 2 := hprod₁

set_option maxHeartbeats 1000000 in
/-- **The descent step for `p ≡ 3 (mod 8)`.**  A node of area `p k²` yields a node of
area `p k'²` with a strictly smaller first Euclid parameter. -/
theorem prime_descent_step {p m n k : ℤ} (hp : Prime p) (hp0 : 0 < p) (hp8 : p % 8 = 3)
    (h : IsParam m n) (hk : euclidArea m n = p * k ^ 2) :
    ∃ r s k' : ℤ, IsParam r s ∧ r < m ∧ euclidArea r s = p * k' ^ 2 := by
  have hm : 0 < m := h.mpos
  have hn : 0 < n := h.npos
  have hlt : n < m := h.lt
  rcases four_shapes_of_prime hp hp0 h hk with
    ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩ |
    ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩ |
    ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩ |
    ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩
  · exact absurd (shape_one_absurd hp8 h ha hc hd) not_false
  · -- the surviving shape: `m = a²`, `n = p b²`
    rcases Int.even_or_odd a with hae | hao
    · exact absurd (shape_two_even_absurd h hae ha hc hd) not_false
    · -- `m` is odd, hence `n` is even and `b` is even
      have hnodd_or : Even n := by
        obtain ⟨A, hA⟩ := hao
        obtain ⟨s', hs'⟩ := h.par
        have hma : m = (2 * A + 1) ^ 2 := by rw [ha, hA]
        have hma' : m = 4 * (A * (A + 1)) + 1 := by rw [hma]; ring
        rcases Int.even_or_odd n with hne | ⟨t, ht⟩
        · exact hne
        · exfalso; omega
      have hbe : Even b := by
        rcases Int.even_or_odd b with hbe | hbo
        · exact hbe
        · exfalso
          obtain ⟨B, hB⟩ := odd_sq_form hbo
          obtain ⟨P, hP⟩ : ∃ P : ℤ, p = 8 * P + 3 := ⟨p / 8, by omega⟩
          obtain ⟨w, hw⟩ := hnodd_or
          obtain ⟨R, hR⟩ : ∃ R : ℤ, p * b ^ 2 = 8 * R + 3 :=
            ⟨P * (8 * B + 1) + 3 * B, by rw [hP, hB]; ring⟩
          omega
      obtain ⟨b₁, hb₁⟩ := hbe
      have hb₁' : b = 2 * b₁ := by omega
      have hb₁0 : 0 < b₁ := by omega
      -- the half-sum / half-difference pair
      have hCodd : Odd (m - n) := h.par
      have hDodd : Odd (m + n) := param_odd_add h
      have hcodd : Odd c := odd_of_odd_sq (by rw [← hc]; exact hCodd)
      have hdodd : Odd d := odd_of_odd_sq (by rw [← hd]; exact hDodd)
      have hcltd : c < d := by nlinarith [hc, hd, hn, hc0, hd0]
      obtain ⟨c₁, hc₁⟩ := hcodd
      obtain ⟨d₁, hd₁⟩ := hdodd
      obtain ⟨u, hu⟩ : ∃ u : ℤ, u = c₁ + d₁ + 1 := ⟨_, rfl⟩
      obtain ⟨v, hv⟩ : ∃ v : ℤ, v = d₁ - c₁ := ⟨_, rfl⟩
      have huv_add : u + v = d := by omega
      have huv_sub : u - v = c := by omega
      have hu0 : 0 < u := by omega
      have hv0 : 0 < v := by omega
      have hsum : u ^ 2 + v ^ 2 = a ^ 2 := by
        have h1 : 2 * (u ^ 2 + v ^ 2) = (u + v) ^ 2 + (u - v) ^ 2 := by ring
        rw [huv_add, huv_sub, ← hd, ← hc] at h1
        have h2 : (m + n) + (m - n) = 2 * m := by ring
        rw [h2, ha] at h1
        linarith
      have hprod : u * v = 2 * p * b₁ ^ 2 := by
        have h1 : 4 * (u * v) = (u + v) ^ 2 - (u - v) ^ 2 := by ring
        rw [huv_add, huv_sub, ← hd, ← hc] at h1
        have h2 : (m + n) - (m - n) = 2 * n := by ring
        rw [h2, hb, hb₁'] at h1
        linarith
      have hCD : IsCoprime c d := by
        obtain ⟨-, -, -, -, -, hCD'⟩ := param_coprime_factors h
        rw [hc, hd] at hCD'
        exact (hCD'.of_isCoprime_of_dvd_left
          (dvd_pow_self c two_ne_zero)).of_isCoprime_of_dvd_right (dvd_pow_self d two_ne_zero)
      have hcopuv : IsCoprime u v := by
        obtain ⟨s', t', hst⟩ := hCD
        exact ⟨s' + t', t' - s', by rw [← huv_add, ← huv_sub] at hst; linear_combination hst⟩
      have ha2 : 2 ≤ a := by
        by_contra hcon
        push_neg at hcon
        have ha1 : a = 1 := by omega
        rw [ha1] at ha
        simp at ha
        omega
      have haltm : a < m := by
        have h1 : a * 1 < a * a := mul_lt_mul_of_pos_left (by omega) ha0
        rw [ha, sq]
        linarith
      have key : ∃ r s k' : ℤ, IsParam r s ∧ r < a ∧ euclidArea r s = p * k' ^ 2 := by
        rcases Int.even_or_odd u with hue | huo
        · exact prime_descent_from_pair hu0 hv0 ha0 hcopuv hsum hprod hue
        · have hve : Even v := by
            rcases Int.even_or_odd v with hve | hvo
            · exact hve
            · exfalso
              obtain ⟨s', hs'⟩ := huo
              obtain ⟨t', ht'⟩ := hvo
              have h1 : u * v = 2 * (2 * s' * t' + s' + t') + 1 := by rw [hs', ht']; ring
              omega
          exact prime_descent_from_pair hv0 hu0 ha0 hcopuv.symm (by linarith [hsum])
            (by rw [← hprod]; ring) hve
      obtain ⟨r, s', k', hpar, hra, harea⟩ := key
      exact ⟨r, s', k', hpar, by linarith, harea⟩
  · exact absurd (shape_three_absurd hp8 h ha hb hc hd) not_false
  · exact absurd (shape_four_absurd hp8 h ha hb hc hd) not_false

/-- **No node of the Berggren tree has area `p k²` when `p ≡ 3 (mod 8)` is prime.** -/
theorem euclidArea_ne_prime_mul_sq {p : ℤ} (hp : Prime p) (hp0 : 0 < p) (hp8 : p % 8 = 3)
    {m n : ℤ} (h : IsParam m n) (k : ℤ) : euclidArea m n ≠ p * k ^ 2 := by
  have main : ∀ M : ℕ, ∀ m n k : ℤ, m.toNat ≤ M → IsParam m n → euclidArea m n ≠ p * k ^ 2 := by
    intro M
    induction M with
    | zero =>
        intro m n k hM hpar _
        have := hpar.mpos
        omega
    | succ M ih =>
        intro m n k hM hpar hk
        obtain ⟨r, s, k', hpar', hrm, harea⟩ := prime_descent_step hp hp0 hp8 hpar hk
        have hr : 0 < r := hpar'.mpos
        exact ih r s k' (by omega) hpar' harea
  exact main m.toNat m n k le_rfl h

/-- **Genocchi's theorem, tree form.**  A prime `p ≡ 3 (mod 8)` is not a congruent
number: an unconditional infinite family of non-congruent numbers. -/
theorem prime_three_mod_eight_not_congruent {p : ℕ} (hp : p.Prime) (hp8 : p % 8 = 3) :
    ¬ IsCongruentNumber (p : ℚ) := by
  intro hcong
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  have hp0 : (0 : ℤ) < (p : ℤ) := by exact_mod_cast hp.pos
  have hp8Z : (p : ℤ) % 8 = 3 := by omega
  have hs : Squarefree ((p : ℤ)) := hpZ.squarefree
  obtain ⟨m, n, k, hpar, hk, harea⟩ := (congruent_iff_exists_param hs).mp hcong
  exact euclidArea_ne_prime_mul_sq hpZ hp0 hp8Z hpar k harea

/-- The whole square class of a prime `p ≡ 3 (mod 8)` consists of non-congruent
numbers. -/
theorem prime_mul_sq_not_congruentNumber {p : ℕ} (hp : p.Prime) (hp8 : p % 8 = 3) {t : ℚ}
    (ht : t ≠ 0) : ¬ IsCongruentNumber ((p : ℚ) * t ^ 2) := by
  intro h
  exact prime_three_mod_eight_not_congruent hp hp8
    ((isCongruentNumber_mul_sq_iff (p : ℚ) ht).mp h)

/-! ### Lab notes: the first members of the family -/

/-- `3` is not a congruent number. -/
theorem three_not_congruentNumber : ¬ IsCongruentNumber (3 : ℚ) := by
  have h := prime_three_mod_eight_not_congruent (p := 3) (by norm_num) (by norm_num)
  simpa using h

/-- `11` is not a congruent number. -/
theorem eleven_not_congruentNumber : ¬ IsCongruentNumber (11 : ℚ) := by
  have h := prime_three_mod_eight_not_congruent (p := 11) (by norm_num) (by norm_num)
  simpa using h

/-- `19` is not a congruent number. -/
theorem nineteen_not_congruentNumber : ¬ IsCongruentNumber (19 : ℚ) := by
  have h := prime_three_mod_eight_not_congruent (p := 19) (by norm_num) (by norm_num)
  simpa using h

/-- `43` is not a congruent number. -/
theorem fortythree_not_congruentNumber : ¬ IsCongruentNumber (43 : ℚ) := by
  have h := prime_three_mod_eight_not_congruent (p := 43) (by norm_num) (by norm_num)
  simpa using h

end BerggrenCongruent