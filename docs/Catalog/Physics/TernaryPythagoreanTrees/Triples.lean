import Physics.TernaryPythagoreanTrees.Classification

/-!
# From the node tree to the tree of primitive Pythagorean triples

The node set `{1 ≤ n < m, gcd(m,n) = 1, m + n odd}` is the set of *Euclid parameters*.  This
file makes the dictionary precise:

* `TernaryTree.toTriple m n = (m² - n², 2mn, m² + n²)` sends a node to a primitive Pythagorean
  triple with even second leg (`isPPT_toTriple`);
* the correspondence is injective (`toTriple_inj`) and surjective onto such triples
  (`exists_node_of_isPPT`), hence a bijection (`ppt_equiv_node`);
* consequently *every* ternary Pythagorean tree of the classification enumerates every
  primitive Pythagorean triple exactly once, starting from `(3,4,5)`
  (`tree_generates_all_ppt`, `toTriple_root`).

Combined with `TernaryTree.tree_classification` this says: there are exactly three ways to
organise the primitive Pythagorean triples into a ternary tree by integer linear maps of the
Euclid parameters.
-/

namespace TernaryTree

/-- Euclid's map from parameters to a Pythagorean triple. -/
def toTriple (m n : ℤ) : ℤ × ℤ × ℤ := (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

/-- A primitive Pythagorean triple with positive entries and even second leg. -/
structure IsPPT (x y z : ℤ) : Prop where
  /-- the Pythagorean relation -/
  pyth : x ^ 2 + y ^ 2 = z ^ 2
  /-- the odd leg is positive -/
  x_pos : 0 < x
  /-- the even leg is positive -/
  y_pos : 0 < y
  /-- primitivity -/
  cop : Int.gcd x y = 1
  /-- the second leg is the even one -/
  y_even : Even y

/-! ### Elementary consequences of `IsNode` -/

lemma IsNode.gcd_eq_one {m n : ℤ} (h : IsNode m n) : Int.gcd m n = 1 :=
  Int.isCoprime_iff_gcd_eq_one.1 h.cop

lemma IsNode.two_le {m n : ℤ} (h : IsNode m n) : 2 ≤ m := by
  have := h.one_le; have := h.lt; omega

/-- With exactly one of `m`, `n` even, `m² - n²` is odd. -/
lemma not_even_sq_sub_sq {m n : ℤ}
    (hpar : m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0) : ¬ Even (m ^ 2 - n ^ 2) := by
  rintro ⟨k, hk⟩
  rcases hpar with ⟨h1, h2⟩ | ⟨h1, h2⟩
  · obtain ⟨a, rfl⟩ : ∃ a, m = 2 * a := ⟨m / 2, by omega⟩
    obtain ⟨b, rfl⟩ : ∃ b, n = 2 * b + 1 := ⟨n / 2, by omega⟩
    have key : 2 * (2 * a ^ 2 - 2 * b ^ 2 - 2 * b - k) = 1 := by linear_combination hk
    have hdvd : (2 : ℤ) ∣ 1 := ⟨_, key.symm⟩
    norm_num at hdvd
  · obtain ⟨a, rfl⟩ : ∃ a, m = 2 * a + 1 := ⟨m / 2, by omega⟩
    obtain ⟨b, rfl⟩ : ∃ b, n = 2 * b := ⟨n / 2, by omega⟩
    have key : 2 * (2 * a ^ 2 + 2 * a - 2 * b ^ 2 - k) = -1 := by linear_combination hk
    have hdvd : (2 : ℤ) ∣ -1 := ⟨_, key.symm⟩
    norm_num at hdvd

lemma IsNode.parity_mod {m n : ℤ} (h : IsNode m n) :
    m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0 := by
  obtain ⟨k, hk⟩ := h.odd
  omega

/-! ### The forward map -/

@[simp] lemma toTriple_root : toTriple 2 1 = (3, 4, 5) := by
  norm_num [toTriple]

/-- A node gives a primitive Pythagorean triple with even second leg. -/
theorem isPPT_toTriple {m n : ℤ} (h : IsNode m n) :
    IsPPT (toTriple m n).1 (toTriple m n).2.1 (toTriple m n).2.2 := by
  have hn := h.one_le
  have hlt := h.lt
  have hclass :=
    (PythagoreanTriple.coprime_classification (x := m ^ 2 - n ^ 2) (y := 2 * m * n)
      (z := m ^ 2 + n ^ 2)).2
      ⟨m, n, Or.inl ⟨rfl, rfl⟩, Or.inl rfl, h.gcd_eq_one, h.parity_mod⟩
  refine ⟨?_, ?_, ?_, hclass.2, ⟨m * n, by simp [toTriple]; ring⟩⟩
  · have := hclass.1
    simp only [PythagoreanTriple] at this
    simp only [toTriple]
    nlinarith [this]
  · simp only [toTriple]
    nlinarith
  · simp only [toTriple]
    nlinarith

/-- Euclid's map is injective on nodes. -/
theorem toTriple_inj {m n m' n' : ℤ} (h : IsNode m n) (h' : IsNode m' n')
    (heq : toTriple m n = toTriple m' n') : m = m' ∧ n = n' := by
  have h1 : m ^ 2 - n ^ 2 = m' ^ 2 - n' ^ 2 := congrArg Prod.fst heq
  have h3 : m ^ 2 + n ^ 2 = m' ^ 2 + n' ^ 2 := congrArg (fun p => p.2.2) heq
  have hm2 : m ^ 2 = m' ^ 2 := by linarith
  have hn2 : n ^ 2 = n' ^ 2 := by linarith
  have hm : 0 < m := by have := h.two_le; omega
  have hm' : 0 < m' := by have := h'.two_le; omega
  have hn : 0 < n := h.one_le
  have hn' : 0 < n' := h'.one_le
  constructor
  · nlinarith
  · nlinarith

/-! ### Surjectivity -/

/-- Positive Euclid parameters with the right coprimality and parity give a node whose triple
is the prescribed one. -/
lemma node_of_params {m n x y z : ℤ} (hm : 0 < m) (hn : 0 < n)
    (hx : x = m ^ 2 - n ^ 2) (hy : y = 2 * m * n) (hz : z = m ^ 2 + n ^ 2)
    (hco : Int.gcd m n = 1)
    (hpar : m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0)
    (hxpos : 0 < x) : IsNode m n ∧ toTriple m n = (x, y, z) := by
  have hlt : n < m := by nlinarith
  refine ⟨⟨hn, hlt, Int.isCoprime_iff_gcd_eq_one.2 hco, ?_⟩, ?_⟩
  · rcases hpar with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact ⟨(m + n - 1) / 2, by omega⟩
    · exact ⟨(m + n - 1) / 2, by omega⟩
  · simp [toTriple, hx, hy, hz]

/-- Every primitive Pythagorean triple with positive entries and even second leg comes from a
node. -/
theorem exists_node_of_isPPT {x y z : ℤ} (h : IsPPT x y z) (hz : 0 < z) :
    ∃ m n, IsNode m n ∧ toTriple m n = (x, y, z) := by
  have hpt : PythagoreanTriple x y z := by
    simp only [PythagoreanTriple]
    have := h.pyth
    nlinarith [this]
  obtain ⟨m, n, hxy, hzz, hco, hpar⟩ :=
    (PythagoreanTriple.coprime_classification (x := x) (y := y) (z := z)).1 ⟨hpt, h.cop⟩
  -- the second coordinate is the even one, so we are in the first case
  have hxy' : x = m ^ 2 - n ^ 2 ∧ y = 2 * m * n := by
    rcases hxy with hc | ⟨hx2, hy2⟩
    · exact hc
    · exact absurd (hy2 ▸ h.y_even) (not_even_sq_sub_sq hpar)
  obtain ⟨hx, hy⟩ := hxy'
  have hzeq : z = m ^ 2 + n ^ 2 := by
    rcases hzz with h' | h'
    · exact h'
    · exfalso; nlinarith [sq_nonneg m, sq_nonneg n]
  have hmn : 0 < m * n := by
    have h2 := h.y_pos
    rw [hy] at h2
    linarith
  rcases lt_trichotomy m 0 with hm | hm | hm
  · have hn : n < 0 := by nlinarith
    refine ⟨-m, -n, ?_⟩
    refine node_of_params (by omega) (by omega) (by rw [hx]; ring) (by rw [hy]; ring)
      (by rw [hzeq]; ring) (by simpa [Int.gcd] using hco) (by omega) h.x_pos
  · exfalso; simp [hm] at hmn
  · have hn : 0 < n := by nlinarith
    exact ⟨m, n, node_of_params hm hn hx hy hzeq hco hpar h.x_pos⟩

/-! ### The trees enumerate all primitive Pythagorean triples -/

/-- **Every ternary Pythagorean tree generates all primitive Pythagorean triples** from the
root triple `(3,4,5)`: the Euclid parameters of any such triple are reached from `(2,1)` by a
finite word in the three branches. -/
theorem tree_generates_all_ppt {T : Fin 3 → IntMap} (hT : IsTernaryTree T) {x y z : ℤ}
    (h : IsPPT x y z) (hz : 0 < z) :
    ∃ m n, IsTernaryTree.Reach T m n ∧ toTriple m n = (x, y, z) := by
  obtain ⟨m, n, hnode, heq⟩ := exists_node_of_isPPT h hz
  exact ⟨m, n, hT.reach_all m n hnode, heq⟩

/-- **Uniqueness**: a primitive Pythagorean triple has exactly one set of Euclid parameters,
so each triple occurs exactly once in the tree. -/
theorem ppt_unique_node {x y z : ℤ} {m n m' n' : ℤ} (h : IsNode m n) (h' : IsNode m' n')
    (he : toTriple m n = (x, y, z)) (he' : toTriple m' n' = (x, y, z)) : m = m' ∧ n = n' :=
  toTriple_inj h h' (he.trans he'.symm)

end TernaryTree