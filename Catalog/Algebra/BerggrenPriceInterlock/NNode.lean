import Algebra.BerggrenPriceInterlock.Trees

/-!
# Berggren–Price interlock, Part III: the N-node identity

A node `(m,n)` carries the primitive triple `(m² - n², 2mn, m² + n²)`.  The **odd leg**
factors as `(m-n)(m+n)`, so *a node is literally a factorisation*.  Conversely every odd
`N = p·q` with `p, q` coprime and `1 ≤ p < q` sits at the **Fermat pair**
`((p+q)/2, (q-p)/2)`, which is a valid node — hence a node of *both* trees, at a unique
address in each.

This makes the slogan "factoring `N` = finding the `N`-node" a theorem, and lets us
compare tree traversal with Fermat's own scan (`fermat_step_bound`: the number of trial
values is `m - r`, and `(m-r)(m+r) ≤ n² + 2r`, the classical `(q-p)²/(8√N)` law).

## Main results

* `pythagorean_triple`, `primitive_triple` — nodes give primitive Pythagorean triples.
* `fermatNode_eq`, `isNode_fermatNode`, `oddLeg_fermatNode` — the Fermat pair is a node
  and its odd leg is exactly `N = p·q`.
* `fermatNode_leftInverse`, `fermatNode_rightInverse`, `factorisation_of_node` — the
  correspondence `{coprime odd pairs} ≃ {nodes}` and extraction of a nontrivial divisor.
* `berg_N_node`, `price_N_node` — every such `N` is a node of *both* trees, at a unique
  address in each.
* `fermat_step_bound` — Fermat's scan length obeys `(m-r)(m+r) ≤ n² + 2r`.
-/

namespace BerggrenPrice

/-! ### The triple carried by a node -/

/-- The odd leg `m² - n²` of the triple at a node. -/
def oddLeg (v : Node) : ℤ := v.1 ^ 2 - v.2 ^ 2
/-- The even leg `2mn` of the triple at a node. -/
def evenLeg (v : Node) : ℤ := 2 * v.1 * v.2
/-- The hypotenuse `m² + n²` of the triple at a node. -/
def hypot (v : Node) : ℤ := v.1 ^ 2 + v.2 ^ 2

theorem pythagorean_triple (v : Node) : oddLeg v ^ 2 + evenLeg v ^ 2 = hypot v ^ 2 := by
  simp only [oddLeg, evenLeg, hypot]; ring

/-- The odd leg of a node is genuinely odd. -/
theorem oddLeg_odd {v : Node} (h : IsNode v) : Odd (oddLeg v) := by
  obtain ⟨-, -, -, s, hs⟩ := h
  have hm : v.1 = 2 * s + 1 - v.2 := by omega
  refine ⟨2 * s * (s - v.2) + s + (s - v.2), ?_⟩
  simp only [oddLeg, hm]; ring

/-- **Primitivity**: the two legs at a node are coprime. -/
theorem primitive_triple {v : Node} (h : IsNode v) : IsCoprime (oddLeg v) (evenLeg v) := by
  obtain ⟨t, ht⟩ := oddLeg_odd h
  obtain ⟨-, -, ⟨x, y, hxy⟩, -⟩ := h
  have c2 : IsCoprime (oddLeg v) (2 : ℤ) := ⟨1, -t, by rw [ht]; ring⟩
  have cm : IsCoprime (oddLeg v) v.1 :=
    ⟨-y ^ 2, x * (1 + y * v.2) + y ^ 2 * v.1, by
      simp only [oddLeg]; linear_combination (y * v.2 + 1) * hxy⟩
  have cn : IsCoprime (oddLeg v) v.2 :=
    ⟨x ^ 2, 2 * y - y ^ 2 * v.2 + x ^ 2 * v.2, by
      simp only [oddLeg]; linear_combination (x * v.1 - y * v.2 + 1) * hxy⟩
  have := (c2.mul_right cm).mul_right cn
  simpa [evenLeg] using this

/-! ### The Fermat pair of a factorisation -/

/-- The **Fermat pair** of the factorisation `N = p·q`: `((p+q)/2, (q-p)/2)`. -/
def fermatNode (p q : ℤ) : Node := ((p + q) / 2, (q - p) / 2)

theorem fermatNode_eq {p q a b : ℤ} (hp : p = 2 * a + 1) (hq : q = 2 * b + 1) :
    fermatNode p q = (a + b + 1, b - a) := by
  have e1 : (p + q) / 2 = a + b + 1 := by omega
  have e2 : (q - p) / 2 = b - a := by omega
  simp only [fermatNode, e1, e2]

variable {p q : ℤ}

/-- The Fermat pair of a coprime odd factorisation is a valid node of both trees. -/
theorem isNode_fermatNode (hp : Odd p) (hq : Odd q) (h1 : 1 ≤ p) (hpq : p < q)
    (hco : IsCoprime p q) : IsNode (fermatNode p q) := by
  obtain ⟨a, ha⟩ := hp
  obtain ⟨b, hb⟩ := hq
  obtain ⟨x, y, hxy⟩ := hco
  rw [ha, hb] at hxy
  rw [fermatNode_eq ha hb]
  refine ⟨?_, ?_, ⟨x + y, y - x, ?_⟩, b, ?_⟩
  · show (1 : ℤ) ≤ b - a
    omega
  · show b - a < a + b + 1
    omega
  · show (x + y) * (a + b + 1) + (y - x) * (b - a) = 1
    linear_combination hxy
  · show a + b + 1 + (b - a) = 2 * b + 1
    omega

/-- **The N-node identity**: the odd leg at the Fermat pair is exactly `N = p·q`. -/
theorem oddLeg_fermatNode (hp : Odd p) (hq : Odd q) : oddLeg (fermatNode p q) = p * q := by
  obtain ⟨a, ha⟩ := hp
  obtain ⟨b, hb⟩ := hq
  rw [fermatNode_eq ha hb]
  simp only [oddLeg, ha, hb]
  ring

/-- The hypotenuse at the Fermat pair is `(p² + q²)/2`. -/
theorem hypot_fermatNode (hp : Odd p) (hq : Odd q) :
    2 * hypot (fermatNode p q) = p ^ 2 + q ^ 2 := by
  obtain ⟨a, ha⟩ := hp
  obtain ⟨b, hb⟩ := hq
  rw [fermatNode_eq ha hb]
  simp only [hypot, ha, hb]
  ring

/-- The even leg at the Fermat pair is `(q² - p²)/2`. -/
theorem evenLeg_fermatNode (hp : Odd p) (hq : Odd q) :
    2 * evenLeg (fermatNode p q) = q ^ 2 - p ^ 2 := by
  obtain ⟨a, ha⟩ := hp
  obtain ⟨b, hb⟩ := hq
  rw [fermatNode_eq ha hb]
  simp only [evenLeg, ha, hb]
  ring

/-- The Fermat-pair map is inverse to `v ↦ (m - n, m + n)`: nodes *are* factorisations. -/
theorem fermatNode_leftInverse (v : Node) (h : IsNode v) :
    fermatNode (v.1 - v.2) (v.1 + v.2) = v := by
  obtain ⟨-, -, -, s, hs⟩ := h
  have ha : v.1 - v.2 = 2 * (s - v.2) + 1 := by omega
  have hb : v.1 + v.2 = 2 * s + 1 := hs
  rw [fermatNode_eq ha hb]
  refine Prod.ext ?_ ?_
  · show s - v.2 + s + 1 = v.1
    omega
  · show s - (s - v.2) = v.2
    omega

/-- Conversely, `(m-n, m+n)` recovers the factorisation from the Fermat pair. -/
theorem fermatNode_rightInverse (hp : Odd p) (hq : Odd q) :
    ((fermatNode p q).1 - (fermatNode p q).2, (fermatNode p q).1 + (fermatNode p q).2)
      = (p, q) := by
  obtain ⟨a, ha⟩ := hp
  obtain ⟨b, hb⟩ := hq
  rw [fermatNode_eq ha hb]
  refine Prod.ext ?_ ?_
  · show a + b + 1 - (b - a) = p
    omega
  · show a + b + 1 + (b - a) = q
    omega

/-- **Finding a node = factoring.**  A node with `m - n > 1` exhibits a nontrivial
divisor of its odd leg. -/
theorem factorisation_of_node (v : Node) (h : IsNode v) (h2 : 1 < v.1 - v.2) :
    (v.1 - v.2) ∣ oddLeg v ∧ 1 < v.1 - v.2 ∧ v.1 - v.2 < oddLeg v := by
  obtain ⟨h1, hlt, -, -⟩ := h
  refine ⟨⟨v.1 + v.2, by simp only [oddLeg]; ring⟩, h2, ?_⟩
  have hfac : oddLeg v = (v.1 - v.2) * (v.1 + v.2) := by simp only [oddLeg]; ring
  rw [hfac]
  nlinarith

/-! ### The N-node lives in both trees -/

/-- **Berggren N-node**: every coprime odd factorisation `N = p·q` occupies a unique
address in the Berggren tree. -/
theorem berg_N_node (hp : Odd p) (hq : Odd q) (h1 : 1 ≤ p) (hpq : p < q) (hco : IsCoprime p q) :
    ∃! w : List (Fin 3), applyWord berg w root = fermatNode p q :=
  berg_tree _ (isNode_fermatNode hp hq h1 hpq hco)

/-- **Price N-node**: the same node has a unique address in the Price tree. -/
theorem price_N_node (hp : Odd p) (hq : Odd q) (h1 : 1 ≤ p) (hpq : p < q) (hco : IsCoprime p q) :
    ∃! w : List (Fin 3), applyWord price w root = fermatNode p q :=
  price_tree _ (isNode_fermatNode hp hq h1 hpq hco)

/-- The odd leg at the Berggren address of `N` is exactly `N`. -/
theorem berg_N_node_oddLeg (hp : Odd p) (hq : Odd q) (h1 : 1 ≤ p) (hpq : p < q)
    (hco : IsCoprime p q) :
    ∃ w : List (Fin 3), oddLeg (applyWord berg w root) = p * q := by
  obtain ⟨w, hw, -⟩ := berg_N_node hp hq h1 hpq hco
  exact ⟨w, by rw [hw, oddLeg_fermatNode hp hq]⟩

/-- The odd leg at the Price address of `N` is exactly `N`. -/
theorem price_N_node_oddLeg (hp : Odd p) (hq : Odd q) (h1 : 1 ≤ p) (hpq : p < q)
    (hco : IsCoprime p q) :
    ∃ w : List (Fin 3), oddLeg (applyWord price w root) = p * q := by
  obtain ⟨w, hw, -⟩ := price_N_node hp hq h1 hpq hco
  exact ⟨w, by rw [hw, oddLeg_fermatNode hp hq]⟩

/-! ### Fermat's own scan -/

/-- **Fermat's cost law.**  If `r = ⌊√N⌋` and `N = m² - n²`, the number of trial values
`m - r` of Fermat's scan satisfies `(m - r)(m + r) ≤ n² + 2r`; i.e. the scan length is
about `n²/(2√N) = (q-p)²/(8√N)`, small exactly when the factors are close. -/
theorem fermat_step_bound {N r m n : ℤ} (hN : N < (r + 1) ^ 2)
    (hmn : m ^ 2 - n ^ 2 = N) : (m - r) * (m + r) ≤ n ^ 2 + 2 * r := by
  nlinarith [hN, hmn]

/-- Fermat's scan for `N = p·q` terminates at the Fermat pair: the witness is `m`. -/
theorem fermat_witness (hp : Odd p) (hq : Odd q) :
    (fermatNode p q).1 ^ 2 - p * q = (fermatNode p q).2 ^ 2 := by
  have h := oddLeg_fermatNode hp hq
  simp only [oddLeg] at h
  linarith

end BerggrenPrice