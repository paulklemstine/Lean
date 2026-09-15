import Combinatorics.BerggrenCongruentDefs

/-!
# Fermat's right triangle theorem as a descent *inside the Berggren tree*

No node of the Berggren tree has square area: for admissible Euclid parameters
`m > n > 0`, coprime and of opposite parity, the area `mn(m² − n²)` is never a perfect
square.

The proof is Fermat's infinite descent, but carried out entirely in the tree's own
coordinates.  From a node `(m, n)` of square area we manufacture a *new node* `(p, q)`
of square area with `p < m`:

1. `m`, `n`, `m − n`, `m + n` are pairwise coprime with square product, hence each is a
   square: `m = a²`, `n = b²`, `m − n = c²`, `m + n = d²`.
2. `u = (d + c)/2`, `v = (d − c)/2` are coprime positive integers with `u² + v² = a²`
   and `2uv = b²`.
3. Splitting off the even one of `u, v` shows that the primitive triple with legs `u, v`
   and hypotenuse `a` has an even leg of the form `2g²` and an odd leg `h²`; by the
   catalog's Barning–Hall theorem (`isNode_iff`, `isNode_param`) that triple is
   `euclidTriple p q` for admissible parameters `p, q`, whose area `pq(p² − q²) = (gh)²`
   is again a square.
4. `p < a` and `a < m`, so the descent terminates.

## Main results

* `four_factors_sq` — the four factors of a square node area are squares.
* `descent_step` — from a node of square area to a strictly smaller one.
* `euclidArea_ne_sq` — Fermat's right triangle theorem, tree form.
-/

namespace BerggrenCongruent

open BerggrenStars

/-- An odd integer is coprime to `2`. -/
theorem isCoprime_two_of_odd {z : ℤ} (h : Odd z) : IsCoprime z 2 := by
  obtain ⟨t, ht⟩ := h
  exact ⟨1, -t, by rw [ht]; ring⟩

/-- A positive factor of a square that is coprime to the complementary factor is itself a
square. -/
theorem sq_of_isCoprime_pos {A B k : ℤ} (hA : 0 < A) (h : IsCoprime A B)
    (hk : A * B = k ^ 2) : ∃ a : ℤ, 0 < a ∧ A = a ^ 2 := by
  obtain ⟨a, ha | ha⟩ := Int.sq_of_isCoprime h hk
  · refine ⟨|a|, ?_, by rw [sq_abs]; exact ha⟩
    rcases eq_or_ne a 0 with rfl | hne
    · exfalso; rw [ha] at hA; simp at hA
    · exact abs_pos.mpr hne
  · exfalso
    nlinarith [sq_nonneg a]

/-- **Step 1 of the descent.**  In a node of square area each of `m`, `n`, `m − n`,
`m + n` is a perfect square. -/
theorem four_factors_sq {m n k : ℤ} (h : IsParam m n) (hk : euclidArea m n = k ^ 2) :
    ∃ a b c d : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ 0 < d ∧
      m = a ^ 2 ∧ n = b ^ 2 ∧ m - n = c ^ 2 ∧ m + n = d ^ 2 := by
  have hm : 0 < m := h.mpos
  have hn : 0 < n := h.npos
  have hlt : n < m := h.lt
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
  obtain ⟨a, ha0, ha⟩ := sq_of_isCoprime_pos hm (hmn.mul_right (hmC.mul_right hmD))
    (by rw [← hk]; simp only [euclidArea]; ring)
  obtain ⟨b, hb0, hb⟩ := sq_of_isCoprime_pos hn (hmn.symm.mul_right (hnC.mul_right hnD))
    (by rw [← hk]; simp only [euclidArea]; ring)
  obtain ⟨c, hc0, hc⟩ := sq_of_isCoprime_pos (show (0:ℤ) < m - n by linarith)
    (hmC.symm.mul_right (hnC.symm.mul_right hCD))
    (by rw [← hk]; simp only [euclidArea]; ring)
  obtain ⟨d, hd0, hd⟩ := sq_of_isCoprime_pos (show (0:ℤ) < m + n by linarith)
    (hmD.symm.mul_right (hnD.symm.mul_right hCD.symm))
    (by rw [← hk]; simp only [euclidArea]; ring)
  exact ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩

/-- **Step 3 of the descent.**  A primitive triple with legs `u` (even) and `v`,
hypotenuse `a`, whose leg product is twice a square, comes from admissible Euclid
parameters `p, q` with `p < a` and square area. -/
private theorem descent_from_pair {u v a b₁ : ℤ} (hu : 0 < u) (hv : 0 < v) (ha : 0 < a)
    (hcop : IsCoprime u v) (hsum : u ^ 2 + v ^ 2 = a ^ 2) (hprod : u * v = 2 * b₁ ^ 2)
    (heven : Even u) :
    ∃ p q k' : ℤ, IsParam p q ∧ p < a ∧ euclidArea p q = k' ^ 2 := by
  obtain ⟨u₁, hu₁⟩ := heven
  have hu₁' : u = 2 * u₁ := by omega
  have hu₁0 : 0 < u₁ := by omega
  -- `u₁ v = b₁²` with `u₁`, `v` coprime
  have hcop₁ : IsCoprime u₁ v := hcop.of_isCoprime_of_dvd_left ⟨2, by omega⟩
  have hprod₁ : u₁ * v = b₁ ^ 2 := by
    have : 2 * (u₁ * v) = 2 * b₁ ^ 2 := by rw [← hprod, hu₁']; ring
    linarith
  obtain ⟨g, hg0, hg⟩ := sq_of_isCoprime_pos hu₁0 hcop₁ hprod₁
  obtain ⟨w, hw0, hw⟩ := sq_of_isCoprime_pos hv hcop₁.symm (by rw [← hprod₁]; ring)
  -- `v` is odd, so `(v, u, a)` is a node of the tree
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
  obtain ⟨p, q, hpar, hpq⟩ := isNode_param hnode
  have hv' : v = p ^ 2 - q ^ 2 := congrArg Prod.fst hpq
  have hu' : u = 2 * p * q := congrArg (fun w : Vec => w.2.1) hpq
  have ha' : a = p ^ 2 + q ^ 2 := congrArg (fun w : Vec => w.2.2) hpq
  refine ⟨p, q, g * w, hpar, ?_, ?_⟩
  · -- `p < p² + q² = a`
    have hq : 0 < q := hpar.npos
    have hp : 0 < p := hpar.mpos
    nlinarith [ha', hp, hq]
  · -- the area of the new node is `u₁ v = g² h² `
    have hpq' : p * q = u₁ := by
      have : 2 * (p * q) = 2 * u₁ := by rw [← hu₁', hu']; ring
      linarith
    calc euclidArea p q = (p * q) * (p ^ 2 - q ^ 2) := rfl
      _ = u₁ * v := by rw [hpq', hv']
      _ = g ^ 2 * w ^ 2 := by rw [hg, hw]
      _ = (g * w) ^ 2 := by ring

set_option maxHeartbeats 1000000 in
/-- **The descent step.**  A node of square area produces a node of square area with a
strictly smaller first Euclid parameter. -/
theorem descent_step {m n k : ℤ} (h : IsParam m n) (hk : euclidArea m n = k ^ 2) :
    ∃ p q k' : ℤ, IsParam p q ∧ p < m ∧ euclidArea p q = k' ^ 2 := by
  obtain ⟨a, b, c, d, ha0, hb0, hc0, hd0, ha, hb, hc, hd⟩ := four_factors_sq h hk
  have hn : 0 < n := h.npos
  have hm : 0 < m := h.mpos
  have hlt : n < m := h.lt
  -- `c` and `d` are odd
  have hcodd : Odd c := by
    rcases Int.even_or_odd c with hce | hco
    · exfalso
      have : Even (c ^ 2) := by
        obtain ⟨t, ht⟩ := hce
        exact ⟨2 * t ^ 2, by rw [ht]; ring⟩
      rw [← hc] at this
      rcases this with ⟨t, ht⟩
      rcases h.par with ⟨s, hs⟩
      omega
    · exact hco
  have hdodd : Odd d := by
    rcases Int.even_or_odd d with hde | hdo
    · exfalso
      have : Even (d ^ 2) := by
        obtain ⟨t, ht⟩ := hde
        exact ⟨2 * t ^ 2, by rw [ht]; ring⟩
      rw [← hd] at this
      rcases this with ⟨t, ht⟩
      rcases h.par with ⟨s, hs⟩
      omega
    · exact hdo
  have hcltd : c < d := by nlinarith [hc, hd, hn, hc0, hd0]
  obtain ⟨c₁, hc₁⟩ := hcodd
  obtain ⟨d₁, hd₁⟩ := hdodd
  -- the coprime pair `u = (d+c)/2`, `v = (d−c)/2`
  obtain ⟨u, hu⟩ : ∃ u : ℤ, u = c₁ + d₁ + 1 := ⟨_, rfl⟩
  obtain ⟨v, hv⟩ : ∃ v : ℤ, v = d₁ - c₁ := ⟨_, rfl⟩
  have huv_add : u + v = d := by omega
  have huv_sub : u - v = c := by omega
  have hu0 : 0 < u := by omega
  have hv0 : 0 < v := by omega
  have hsum : u ^ 2 + v ^ 2 = a ^ 2 := by nlinarith [huv_add, huv_sub, hc, hd, ha]
  have hprodb : 2 * (u * v) = b ^ 2 := by nlinarith [huv_add, huv_sub, hc, hd, hb]
  -- `b` is even, and `uv = 2(b/2)²`
  have hbeven : Even b := by
    rcases Int.even_or_odd b with hbe | ⟨t, ht⟩
    · exact hbe
    · exfalso
      have : b ^ 2 = 4 * (t ^ 2 + t) + 1 := by rw [ht]; ring
      omega
  obtain ⟨b₁, hb₁⟩ := hbeven
  have hprod : u * v = 2 * b₁ ^ 2 := by
    have hb₁' : b = 2 * b₁ := by omega
    have : 2 * (u * v) = 2 * (2 * b₁ ^ 2) := by rw [hprodb, hb₁']; ring
    linarith
  -- `c`, `d` coprime, hence `u`, `v` coprime
  have hCD : IsCoprime c d := by
    have hmn : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr h.cop
    have hnC : IsCoprime n (m - n) := by
      have := hmn.symm.add_mul_left_right (-1)
      rwa [show m + n * (-1) = m - n by ring] at this
    have hCD' : IsCoprime (m - n) (m + n) := by
      have h2 : IsCoprime (m - n) 2 := isCoprime_two_of_odd h.par
      have := (h2.mul_right hnC.symm).add_mul_left_right 1
      rwa [show 2 * n + (m - n) * 1 = m + n by ring] at this
    rw [hc, hd] at hCD'
    exact (hCD'.of_isCoprime_of_dvd_left (dvd_pow_self c two_ne_zero)).of_isCoprime_of_dvd_right
      (dvd_pow_self d two_ne_zero)
  have hcopuv : IsCoprime u v := by
    obtain ⟨s, t, hst⟩ := hCD
    exact ⟨s + t, t - s, by rw [← huv_add, ← huv_sub] at hst; linear_combination hst⟩
  -- one of `u`, `v` is even; apply the extraction lemma to that one
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
  have key : ∃ p q k' : ℤ, IsParam p q ∧ p < a ∧ euclidArea p q = k' ^ 2 := by
    rcases Int.even_or_odd u with hue | huo
    · exact descent_from_pair hu0 hv0 ha0 hcopuv hsum hprod hue
    · have hve : Even v := by
        rcases Int.even_or_odd v with hve | hvo
        · exact hve
        · exfalso
          obtain ⟨s, hs⟩ := huo
          obtain ⟨t, ht⟩ := hvo
          have : u * v = 2 * (2 * s * t + s + t) + 1 := by rw [hs, ht]; ring
          omega
      exact descent_from_pair hv0 hu0 ha0 hcopuv.symm (by linarith [hsum])
        (by rw [← hprod]; ring) hve
  obtain ⟨p, q, k', hpar, hpa, harea⟩ := key
  exact ⟨p, q, k', hpar, by linarith, harea⟩

/-- **Fermat's right triangle theorem, tree form**: the area of a node of the Berggren
tree is never a perfect square. -/
theorem euclidArea_ne_sq {m n : ℤ} (h : IsParam m n) (k : ℤ) : euclidArea m n ≠ k ^ 2 := by
  have main : ∀ M : ℕ, ∀ m n k : ℤ, m.toNat ≤ M → IsParam m n → euclidArea m n ≠ k ^ 2 := by
    intro M
    induction M with
    | zero =>
        intro m n k hM hpar _
        have := hpar.mpos
        omega
    | succ M ih =>
        intro m n k hM hpar hk
        obtain ⟨p, q, k', hpar', hpm, harea⟩ := descent_step hpar hk
        have hp : 0 < p := hpar'.mpos
        exact ih p q k' (by omega) hpar' harea
  exact main m.toNat m n k le_rfl h

end BerggrenCongruent