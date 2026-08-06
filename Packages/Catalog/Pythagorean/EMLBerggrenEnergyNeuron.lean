import Mathlib

/-!
# A single exponential–logarithmic neuron that drives the Berggren tree

This file builds a bridge between two areas that do not usually meet:

* **Number theory / Diophantine geometry.** The Berggren (Barning–Hall) ternary tree
  of primitive Pythagorean triples: every primitive triple is obtained from `(3,4,5)`
  by repeatedly applying one of the three integer matrices `A`, `B`, `C`.
* **Neural computation.** A *single* EML ("exponential–logarithmic") activation neuron,
  i.e. the two-parameter real function
  `emlNeuron σ ε x = log (2 + σ · exp (ε · x))`.

The connecting object is the **node energy**
`energy (a,b,c) = ½ · log ((c + a) / (c - a))`,
a single real number attached to each Pythagorean triple.  For the Euclid
parametrisation `a = m² - n²`, `b = 2mn`, `c = m² + n²` the energy is exactly
`log (m / n)`, the logarithm of the Euclid ratio.

The main theorem `energy_step` says: for every node of the tree and every one of
the three Berggren branches, the energy of the child is obtained from the energy
of the parent by evaluating *one fixed neuron* at *one fixed pair of parameters*
`(σ, ε) ∈ {(-1,-1), (1,-1), (1,1)}`.  No information about the node other than
its energy is needed — hence the traversal step costs `O(1)` arithmetic
operations on the energy scalar, independently of the size of the triple.

Going further, `emlNeuron_image_A/B/C` show that on the physical energy range
`(0, ∞)` the three branches of the neuron have images exactly
`(0, log 2)`, `(log 2, log 3)`, `(log 3, ∞)`.
These are pairwise disjoint, so the neuron output alone decides — by two
comparisons — which branch produced a node (`energy_descent_unique`), and the
root energy `log 2` is not in any of them, so the root is not a child
(`root_not_a_child`).  This is the "energy guided tree traversal" of the title:
a two-parameter analytic neuron encodes the whole combinatorial branching
structure of the Diophantine tree.

## Main results

* `euclidTriple_pythagorean`, `berggren_eq_euclid`, `param_coprime`, `param_parity`,
  `param_ordered` — the arithmetic side: the tree is a tree of primitive triples,
  and in Euclid coordinates the three matrices are the maps
  `(m,n) ↦ (2m-n, m), (2m+n, m), (m+2n, n)`.
* `energy_euclidTriple`, `energy_root` — the energy of a node is `log (m/n)`;
  the root `(3,4,5)` has energy `log 2`.
* `energy_step` — **the bridge**: `energy (child) = emlNeuron σ ε (energy parent)`.
* `energy_children_strictOrder` — the neuron sorts the three children uniformly.
* `emlNeuron_image_A/B/C`, `energy_descent_unique`, `root_not_a_child` — the
  neuron's range partition encodes the branching structure.
-/

noncomputable section

namespace EMLBerggren

open Real Set

/-! ## The arithmetic side: Euclid parametrisation and Berggren matrices -/

/-- The Pythagorean triple attached to Euclid parameters `(m, n)`. -/
def euclidTriple (m n : ℤ) : ℤ × ℤ × ℤ := (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

/-- Euclid's parametrisation always produces a Pythagorean triple. -/
theorem euclidTriple_pythagorean (m n : ℤ) :
    (euclidTriple m n).1 ^ 2 + (euclidTriple m n).2.1 ^ 2 = (euclidTriple m n).2.2 ^ 2 := by
  simp only [euclidTriple]
  ring

/-- The three branches of the Berggren tree. -/
inductive Branch : Type
  | A : Branch
  | B : Branch
  | C : Branch
  deriving DecidableEq, Repr

namespace Branch

/-- The Barning–Hall matrix of a branch, acting on a triple `(a, b, c)`:

`A = [[1,-2,2],[2,-1,2],[2,-2,3]]`, `B = [[1,2,2],[2,1,2],[2,2,3]]`,
`C = [[-1,2,2],[-2,1,2],[-2,2,3]]`. -/
def mat : Branch → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | A, (a, b, c) => (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)
  | B, (a, b, c) => (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)
  | C, (a, b, c) => (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)

/-- The same three maps read in Euclid coordinates `(m, n)`. -/
def param : Branch → ℤ → ℤ → ℤ × ℤ
  | A, m, n => (2 * m - n, m)
  | B, m, n => (2 * m + n, m)
  | C, m, n => (m + 2 * n, n)

/-- The exponential-shell sign of the branch's neuron. -/
def sgn : Branch → ℝ
  | A => -1
  | B => 1
  | C => 1

/-- The exponential rate of the branch's neuron. -/
def rate : Branch → ℝ
  | A => -1
  | B => -1
  | C => 1

end Branch

/-- **Conjugation identity.** In Euclid coordinates the Berggren matrices act by the
elementary substitutions `(m,n) ↦ (2m-n, m)`, `(2m+n, m)`, `(m+2n, n)`. -/
theorem berggren_eq_euclid (b : Branch) (m n : ℤ) :
    b.mat (euclidTriple m n) = euclidTriple (b.param m n).1 (b.param m n).2 := by
  cases b <;>
    simp only [Branch.mat, Branch.param, euclidTriple, Prod.mk.injEq] <;>
    refine ⟨by ring, by ring, by ring⟩

/-- The parameter maps preserve the constraint `0 < n < m`. -/
theorem param_ordered (b : Branch) {m n : ℤ} (hn : 0 < n) (hm : n < m) :
    0 < (b.param m n).2 ∧ (b.param m n).2 < (b.param m n).1 := by
  cases b <;> simp only [Branch.param] <;> omega

/-- The parameter maps preserve coprimality of the Euclid parameters. -/
theorem param_coprime (b : Branch) {m n : ℤ} (h : IsCoprime m n) :
    IsCoprime (b.param m n).1 (b.param m n).2 := by
  cases b
  · have h1 : IsCoprime (-n + m * 2) m := (h.symm.neg_left).add_mul_left_left 2
    have h2 : -n + m * 2 = 2 * m - n := by ring
    rwa [h2] at h1
  · have h1 : IsCoprime (n + m * 2) m := h.symm.add_mul_left_left 2
    have h2 : n + m * 2 = 2 * m + n := by ring
    rwa [h2] at h1
  · have h1 : IsCoprime (m + n * 2) n := h.add_mul_left_left 2
    have h2 : m + n * 2 = m + 2 * n := by ring
    rwa [h2] at h1

/-- The parameter maps preserve the opposite-parity condition `m + n` odd. -/
theorem param_parity (b : Branch) {m n : ℤ} (h : (m + n) % 2 = 1) :
    ((b.param m n).1 + (b.param m n).2) % 2 = 1 := by
  cases b <;> simp only [Branch.param] <;> omega

/-! ## The energy of a node -/

/-- The **node energy** of a Pythagorean triple `(a, b, c)`:
`E = ½ log ((c + a) / (c - a))`.  For a triple in Euclid form this is `log (m/n)`. -/
def energy (t : ℤ × ℤ × ℤ) : ℝ :=
  Real.log (((t.2.2 + t.1 : ℤ) : ℝ) / ((t.2.2 - t.1 : ℤ) : ℝ)) / 2

/-- The energy of a Euclid triple is the logarithm of its Euclid ratio. -/
theorem energy_euclidTriple {m n : ℤ} (hn : 0 < n) :
    energy (euclidTriple m n) = Real.log ((m : ℝ) / (n : ℝ)) := by
  have hn0 : ((n : ℝ)) ≠ 0 := by
    exact_mod_cast hn.ne'
  have hkey : (((euclidTriple m n).2.2 + (euclidTriple m n).1 : ℤ) : ℝ) /
      (((euclidTriple m n).2.2 - (euclidTriple m n).1 : ℤ) : ℝ) = ((m : ℝ) / (n : ℝ)) ^ 2 := by
    simp only [euclidTriple]
    push_cast
    field_simp
    ring
  rw [energy, hkey, Real.log_pow]
  push_cast
  ring

/-- The energy of a Euclid triple with `0 < n < m` is positive. -/
theorem energy_euclidTriple_pos {m n : ℤ} (hn : 0 < n) (hm : n < m) :
    0 < energy (euclidTriple m n) := by
  rw [energy_euclidTriple hn]
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hmn : ((n : ℝ)) < (m : ℝ) := by exact_mod_cast hm
  exact Real.log_pos (by rw [lt_div_iff₀ hn0]; linarith)

/-- The root of the Berggren tree is `(3, 4, 5) = euclidTriple 2 1`, of energy `log 2`. -/
theorem energy_root : energy (euclidTriple 2 1) = Real.log 2 := by
  rw [energy_euclidTriple (by norm_num)]
  norm_num

/-! ## The single EML neuron -/

/-- The **EML neuron**: an exponential–logarithmic activation with a sign parameter `σ`
and a rate parameter `ε`, `x ↦ log (2 + σ · exp (ε · x))`. -/
def emlNeuron (σ ε x : ℝ) : ℝ := Real.log (2 + σ * Real.exp (ε * x))

/-- Evaluating the neuron of rate `1` at a logarithm. -/
theorem emlNeuron_rate_one (σ r : ℝ) (hr : 0 < r) :
    emlNeuron σ 1 (Real.log r) = Real.log (2 + σ * r) := by
  rw [emlNeuron, one_mul, Real.exp_log hr]

/-- Evaluating the neuron of rate `-1` at a logarithm. -/
theorem emlNeuron_rate_neg_one (σ r : ℝ) (hr : 0 < r) :
    emlNeuron σ (-1) (Real.log r) = Real.log (2 + σ / r) := by
  rw [emlNeuron, neg_one_mul, Real.exp_neg, Real.exp_log hr, div_eq_mul_inv]

/-! ## The bridge: one neuron computes every Berggren step -/

/-- **Main theorem (bridge).**  For any node of the Berggren tree, given in Euclid
coordinates with `0 < n < m`, and for any of the three branches, the energy of the
child is obtained from the energy of the parent by a *single* EML neuron evaluated at
the branch's two parameters `(σ, ε)`:

`energy (branch · node) = log (2 + σ · exp (ε · energy node))`.

Only the scalar `energy node` is consumed, so a tree step costs `O(1)`. -/
theorem energy_step (b : Branch) {m n : ℤ} (hn : 0 < n) (hm : n < m) :
    energy (b.mat (euclidTriple m n)) = emlNeuron b.sgn b.rate (energy (euclidTriple m n)) := by
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hm0 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hn.trans hm
  have hr : (0 : ℝ) < (m : ℝ) / (n : ℝ) := div_pos hm0 hn0
  rw [berggren_eq_euclid, energy_euclidTriple hn]
  cases b
  · have h := param_ordered Branch.A hn hm
    rw [energy_euclidTriple h.1, Branch.sgn, Branch.rate,
      emlNeuron_rate_neg_one _ _ hr]
    congr 1
    simp only [Branch.param]
    push_cast
    field_simp
    ring
  · have h := param_ordered Branch.B hn hm
    rw [energy_euclidTriple h.1, Branch.sgn, Branch.rate,
      emlNeuron_rate_neg_one _ _ hr]
    congr 1
    simp only [Branch.param]
    push_cast
    field_simp
  · have h := param_ordered Branch.C hn hm
    rw [energy_euclidTriple h.1, Branch.sgn, Branch.rate,
      emlNeuron_rate_one _ _ hr]
    congr 1
    simp only [Branch.param]
    push_cast
    field_simp
    ring

/-! ## The neuron sorts the branches -/

/-- On the physical energy range `x > 0` the three branch neurons are strictly ordered,
uniformly in `x`: branch `A` always yields the smallest child energy and branch `C`
the largest.  Hence a *single* neuron evaluation ranks the three children. -/
theorem energy_children_strictOrder {x : ℝ} (hx : 0 < x) :
    emlNeuron Branch.A.sgn Branch.A.rate x < emlNeuron Branch.B.sgn Branch.B.rate x ∧
      emlNeuron Branch.B.sgn Branch.B.rate x < emlNeuron Branch.C.sgn Branch.C.rate x := by
  have h1 : Real.exp (-1 * x) < 1 := by
    rw [Real.exp_lt_one_iff]; linarith
  have h2 : (0 : ℝ) < Real.exp (-1 * x) := Real.exp_pos _
  have h3 : Real.exp (-1 * x) < Real.exp (1 * x) := by
    apply Real.exp_lt_exp.mpr; linarith
  constructor
  · simp only [Branch.sgn, Branch.rate, emlNeuron]
    apply Real.log_lt_log (by linarith) (by linarith)
  · simp only [Branch.sgn, Branch.rate, emlNeuron]
    apply Real.log_lt_log (by linarith) (by linarith)

/-! ## Range partition: the neuron encodes the branching structure -/

/-- Branch `A`'s neuron maps the energy half-line `(0, ∞)` bijectively onto `(0, log 2)`. -/
theorem emlNeuron_image_A :
    (fun x => emlNeuron Branch.A.sgn Branch.A.rate x) '' Ioi 0 = Ioo 0 (Real.log 2) := by
  ext y
  simp only [Branch.sgn, Branch.rate, emlNeuron, mem_image, mem_Ioi, mem_Ioo]
  constructor
  · rintro ⟨x, hx, rfl⟩
    have h2 : (0 : ℝ) < Real.exp (-1 * x) := Real.exp_pos _
    have h1 : Real.exp (-1 * x) < 1 := by rw [Real.exp_lt_one_iff]; linarith
    constructor
    · have : (1 : ℝ) < 2 + -1 * Real.exp (-1 * x) := by linarith
      exact Real.log_pos this
    · exact Real.log_lt_log (by linarith) (by linarith)
  · rintro ⟨hy0, hy2⟩
    set t := Real.exp y with ht
    have ht1 : 1 < t := by rw [ht]; exact Real.one_lt_exp_iff.mpr hy0
    have ht2 : t < 2 := by
      have : Real.exp y < Real.exp (Real.log 2) := Real.exp_lt_exp.mpr hy2
      rwa [Real.exp_log (by norm_num)] at this
    refine ⟨-Real.log (2 - t), ?_, ?_⟩
    · have : Real.log (2 - t) < 0 := Real.log_neg (by linarith) (by linarith)
      linarith
    · have h2t : (0 : ℝ) < 2 - t := by linarith
      have harg : (-1 : ℝ) * -Real.log (2 - t) = Real.log (2 - t) := by ring
      rw [harg, Real.exp_log h2t]
      have : (2 : ℝ) + -1 * (2 - t) = t := by ring
      rw [this, ht, Real.log_exp]

/-- Branch `B`'s neuron maps `(0, ∞)` bijectively onto `(log 2, log 3)`. -/
theorem emlNeuron_image_B :
    (fun x => emlNeuron Branch.B.sgn Branch.B.rate x) '' Ioi 0 = Ioo (Real.log 2) (Real.log 3) := by
  ext y
  simp only [Branch.sgn, Branch.rate, emlNeuron, mem_image, mem_Ioi, mem_Ioo]
  constructor
  · rintro ⟨x, hx, rfl⟩
    have h2 : (0 : ℝ) < Real.exp (-1 * x) := Real.exp_pos _
    have h1 : Real.exp (-1 * x) < 1 := by rw [Real.exp_lt_one_iff]; linarith
    exact ⟨Real.log_lt_log (by norm_num) (by linarith),
      Real.log_lt_log (by linarith) (by linarith)⟩
  · rintro ⟨hy2, hy3⟩
    set t := Real.exp y with ht
    have ht2 : 2 < t := by
      have : Real.exp (Real.log 2) < Real.exp y := Real.exp_lt_exp.mpr hy2
      rwa [Real.exp_log (by norm_num)] at this
    have ht3 : t < 3 := by
      have : Real.exp y < Real.exp (Real.log 3) := Real.exp_lt_exp.mpr hy3
      rwa [Real.exp_log (by norm_num)] at this
    refine ⟨-Real.log (t - 2), ?_, ?_⟩
    · have : Real.log (t - 2) < 0 := Real.log_neg (by linarith) (by linarith)
      linarith
    · have h2t : (0 : ℝ) < t - 2 := by linarith
      have harg : (-1 : ℝ) * -Real.log (t - 2) = Real.log (t - 2) := by ring
      rw [harg, Real.exp_log h2t]
      have : (2 : ℝ) + 1 * (t - 2) = t := by ring
      rw [this, ht, Real.log_exp]

/-- Branch `C`'s neuron maps `(0, ∞)` bijectively onto `(log 3, ∞)`. -/
theorem emlNeuron_image_C :
    (fun x => emlNeuron Branch.C.sgn Branch.C.rate x) '' Ioi 0 = Ioi (Real.log 3) := by
  ext y
  simp only [Branch.sgn, Branch.rate, emlNeuron, mem_image, mem_Ioi]
  constructor
  · rintro ⟨x, hx, rfl⟩
    have h1 : (1 : ℝ) < Real.exp (1 * x) := Real.one_lt_exp_iff.mpr (by linarith)
    exact Real.log_lt_log (by norm_num) (by linarith)
  · intro hy3
    set t := Real.exp y with ht
    have ht3 : 3 < t := by
      have : Real.exp (Real.log 3) < Real.exp y := Real.exp_lt_exp.mpr hy3
      rwa [Real.exp_log (by norm_num)] at this
    refine ⟨Real.log (t - 2), ?_, ?_⟩
    · exact Real.log_pos (by linarith)
    · have h2t : (0 : ℝ) < t - 2 := by linarith
      have harg : (1 : ℝ) * Real.log (t - 2) = Real.log (t - 2) := by ring
      rw [harg, Real.exp_log h2t]
      have : (2 : ℝ) + 1 * (t - 2) = t := by ring
      rw [this, ht, Real.log_exp]

/-- The argument of the logarithm inside a branch neuron is positive on `x > 0`. -/
theorem emlNeuron_arg_pos (b : Branch) {x : ℝ} (hx : 0 < x) :
    0 < 2 + b.sgn * Real.exp (b.rate * x) := by
  cases b
  · simp only [Branch.sgn, Branch.rate]
    have h1 : Real.exp (-1 * x) < 1 := by rw [Real.exp_lt_one_iff]; linarith
    linarith
  · simp only [Branch.sgn, Branch.rate]
    linarith [Real.exp_pos (-1 * x)]
  · simp only [Branch.sgn, Branch.rate]
    linarith [Real.exp_pos (1 * x)]

/-- Each branch neuron is injective on the physical energy range. -/
theorem emlNeuron_injOn (b : Branch) : InjOn (fun x => emlNeuron b.sgn b.rate x) (Ioi 0) := by
  intro x hx y hy hxy
  simp only [mem_Ioi] at hx hy
  simp only [emlNeuron] at hxy
  have h1 := Real.log_injOn_pos (mem_Ioi.mpr (emlNeuron_arg_pos b hx))
    (mem_Ioi.mpr (emlNeuron_arg_pos b hy)) hxy
  have hs : b.sgn ≠ 0 := by cases b <;> simp [Branch.sgn]
  have hb : b.rate ≠ 0 := by cases b <;> simp [Branch.rate]
  have h2 : Real.exp (b.rate * x) = Real.exp (b.rate * y) :=
    mul_left_cancel₀ hs (by linarith)
  exact mul_left_cancel₀ hb (Real.exp_eq_exp.mp h2)

/-- **Unique descent.**  Every admissible energy value that is not the root energy
`log 2` and is not `log 3` is produced by exactly one branch, from exactly one
parent energy.  The branch is read off by two comparisons against `log 2` and
`log 3`, i.e. in `O(1)` time from the neuron output alone. -/
theorem energy_descent_unique {y : ℝ} (hy : 0 < y) (h2 : y ≠ Real.log 2)
    (h3 : y ≠ Real.log 3) :
    ∃! p : Branch × ℝ, 0 < p.2 ∧ emlNeuron p.1.sgn p.1.rate p.2 = y := by
  have hlog23 : Real.log 2 < Real.log 3 := Real.log_lt_log (by norm_num) (by norm_num)
  -- membership of `y` in exactly one of the three images
  have hmem : ∃ b : Branch, y ∈ (fun x => emlNeuron b.sgn b.rate x) '' Ioi 0 := by
    rcases lt_trichotomy y (Real.log 2) with h | h | h
    · exact ⟨Branch.A, by rw [emlNeuron_image_A]; exact ⟨hy, h⟩⟩
    · exact absurd h h2
    · rcases lt_trichotomy y (Real.log 3) with h' | h' | h'
      · exact ⟨Branch.B, by rw [emlNeuron_image_B]; exact ⟨h, h'⟩⟩
      · exact absurd h' h3
      · exact ⟨Branch.C, by rw [emlNeuron_image_C]; exact h'⟩
  obtain ⟨b, x, hx, hxy⟩ := hmem
  refine ⟨(b, x), ⟨hx, hxy⟩, ?_⟩
  rintro ⟨b', x'⟩ ⟨hx', hx'y⟩
  -- first the branch is determined, by the disjointness of the three images
  have hb : b' = b := by
    have hy_b : y ∈ (fun x => emlNeuron b.sgn b.rate x) '' Ioi 0 := ⟨x, hx, hxy⟩
    have hy_b' : y ∈ (fun x => emlNeuron b'.sgn b'.rate x) '' Ioi 0 := ⟨x', hx', hx'y⟩
    -- translate both memberships into interval constraints
    have locate : ∀ c : Branch, y ∈ (fun x => emlNeuron c.sgn c.rate x) '' Ioi 0 →
        (c = Branch.A ∧ y < Real.log 2) ∨ (c = Branch.B ∧ Real.log 2 < y ∧ y < Real.log 3) ∨
        (c = Branch.C ∧ Real.log 3 < y) := by
      intro c hc
      cases c
      · rw [emlNeuron_image_A] at hc; exact Or.inl ⟨rfl, hc.2⟩
      · rw [emlNeuron_image_B] at hc; exact Or.inr (Or.inl ⟨rfl, hc.1, hc.2⟩)
      · rw [emlNeuron_image_C] at hc; exact Or.inr (Or.inr ⟨rfl, hc⟩)
    rcases locate b hy_b with ⟨e1, k1⟩ | ⟨e1, k1, k1'⟩ | ⟨e1, k1⟩ <;>
      rcases locate b' hy_b' with ⟨e2, k2⟩ | ⟨e2, k2, k2'⟩ | ⟨e2, k2⟩ <;>
      subst e1 <;> subst e2 <;> first | rfl | linarith
  rw [hb] at hx'y
  have hxx : x' = x := by
    apply emlNeuron_injOn b (mem_Ioi.mpr hx') hx
    show emlNeuron b.sgn b.rate x' = emlNeuron b.sgn b.rate x
    rw [hx'y]
    exact hxy.symm
  simp [hb, hxx]

/-- **The root is not a child.**  The root energy `log 2` is not in the image of any
branch neuron on the physical range, so `(3,4,5)` cannot be produced from any node
of positive energy: the Berggren tree really is rooted. -/
theorem root_not_a_child (b : Branch) {x : ℝ} (hx : 0 < x) :
    emlNeuron b.sgn b.rate x ≠ Real.log 2 := by
  have hlog23 : Real.log 2 < Real.log 3 := Real.log_lt_log (by norm_num) (by norm_num)
  intro h
  have hmem : Real.log 2 ∈ (fun z => emlNeuron b.sgn b.rate z) '' Ioi 0 := ⟨x, hx, h⟩
  cases b
  · rw [emlNeuron_image_A] at hmem; exact absurd hmem.2 (lt_irrefl _)
  · rw [emlNeuron_image_B] at hmem; exact absurd hmem.1 (lt_irrefl _)
  · rw [emlNeuron_image_C] at hmem
    simp only [mem_Ioi] at hmem
    linarith

/-- **Corollary (arithmetic form).**  For a Berggren node with `0 < n < m` the child
energies are pairwise distinct and none of them equals the root energy `log 2`; in
particular no child of the tree is the root triple `(3,4,5)`. -/
theorem children_distinct_and_not_root {m n : ℤ} (hn : 0 < n) (hm : n < m) :
    energy (Branch.A.mat (euclidTriple m n)) < energy (Branch.B.mat (euclidTriple m n)) ∧
      energy (Branch.B.mat (euclidTriple m n)) < energy (Branch.C.mat (euclidTriple m n)) ∧
      ∀ b : Branch, energy (b.mat (euclidTriple m n)) ≠ Real.log 2 := by
  have hpos := energy_euclidTriple_pos hn hm
  have hord := energy_children_strictOrder hpos
  refine ⟨?_, ?_, ?_⟩
  · rw [energy_step _ hn hm, energy_step _ hn hm]; exact hord.1
  · rw [energy_step _ hn hm, energy_step _ hn hm]; exact hord.2
  · intro b
    rw [energy_step _ hn hm]
    exact root_not_a_child b hpos

end EMLBerggren

end