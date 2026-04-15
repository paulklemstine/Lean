/-! # CatalogBuild.Pythagorean.Agents.AgentBeta_TreeDynamics

Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 20
-/

import Mathlib

/-- A path in the ternary Berggren tree. -/
inductive TreePath : Type
  | root : TreePath
  | left : TreePath → TreePath
  | mid : TreePath → TreePath
  | right : TreePath → TreePath
deriving Repr


/-- Compute the Pythagorean triple at a given tree path. -/
def berggrenTripleAux : TreePath → ℤ × ℤ × ℤ
  | .root => (3, 4, 5)
  | .left p =>
    let (a, b, c) := berggrenTripleAux p
    (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .mid p =>
    let (a, b, c) := berggrenTripleAux p
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .right p =>
    let (a, b, c) := berggrenTripleAux p
    (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


/-- M₂ always produces positive components from positive inputs. -/
theorem berggren_M2_pos_a (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < a + 2*b + 2*c := by linarith


/-- [Section: ## Section 2: Positivity Preservation
For the tree to work, we need all three children to have positive components.] -/
theorem berggren_M2_pos_b (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < 2*a + b + 2*c := by linarith


theorem berggren_M2_pos_c (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < 2*a + 2*b + 3*c := by linarith


/-- M₁ produces positive first component when a² + b² = c² and all positive. -/
theorem berggren_M1_pos_a (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < a - 2*b + 2*c := by nlinarith [sq_nonneg (a - b), sq_nonneg b]


/-- M₁ produces positive second component. -/
theorem berggren_M1_pos_b (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < 2*a - b + 2*c := by nlinarith [sq_nonneg a]


/-- M₃ produces positive first component. -/
theorem berggren_M3_pos_a (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -a + 2*b + 2*c := by nlinarith [sq_nonneg (a - b)]


/-- M₃ produces positive second component. -/
theorem berggren_M3_pos_b (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < -2*a + b + 2*c := by nlinarith [sq_nonneg a]


/-- The set of tree paths at exactly depth d. -/
def pathsAtDepth : ℕ → List TreePath
  | 0     => [.root]
  | d + 1 => (pathsAtDepth d).flatMap fun p => [.left p, .mid p, .right p]


/-- [Section: ## Section 3: Node Counting
The Berggren tree is a complete ternary tree: each node has exactly 3 children.
Therefore depth d contains exactly 3^d nodes.] -/
theorem pathsAtDepth_length : ∀ d : ℕ, (pathsAtDepth d).length = 3 ^ d := by
  intro d; induction d with
  | zero => simp [pathsAtDepth]
  | succ n ih =>
  -- By definition of `pathsAtDepth`, we have `pathsAtDepth (n + 1) = (pathsAtDepth n).flatMap fun p => [.left p, .mid p, .right p]`.
  have h_flatMap : pathsAtDepth (n + 1) = (pathsAtDepth n).flatMap fun p => [.left p, .mid p, .right p] := by
    exact?;
  rw [ h_flatMap, List.length_flatMap, List.sum_eq_card_nsmul ] <;> aesop


/-- The M₂-only branch: repeatedly applying M₂ from root. -/
def m2_branch : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 =>
    let (a, b, c) := m2_branch n
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

-- The M₂ branch hypotenuses: 5, 29, 169, 985, ...
#eval (m2_branch 0).2.2  -- 5
#eval (m2_branch 1).2.2  -- 29
#eval (m2_branch 2).2.2  -- 169
#eval (m2_branch 3).2.2  -- 985
#eval (m2_branch 4).2.2  -- 5741


/-- Every M₂-branch triple is Pythagorean. -/
theorem m2_branch_pyth (n : ℕ) :
    let t := m2_branch n
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  induction n with
  | zero => decide
  | succ n ih => simp only [m2_branch]; nlinarith [ih]


/-- Sum of the three children's hypotenuses. -/
theorem children_hyp_sum (a b c : ℤ) :
    (2*a - 2*b + 3*c) + (2*a + 2*b + 3*c) + (-2*a + 2*b + 3*c) = 2*a + 2*b + 9*c := by
  ring


/-- Sum of the three children's first legs. -/
theorem children_leg_a_sum (a b c : ℤ) :
    (a - 2*b + 2*c) + (a + 2*b + 2*c) + (-a + 2*b + 2*c) = a + 2*b + 6*c := by ring


/-- Sum of the three children's second legs. -/
theorem children_leg_b_sum (a b c : ℤ) :
    (2*a - b + 2*c) + (2*a + b + 2*c) + (-2*a + b + 2*c) = 2*a + b + 6*c := by ring


/-- **BETA'S THEOREM**: Sum of all children's perimeters = 5a + 5b + 21c. -/
theorem children_perimeter_sum (a b c : ℤ) :
    let p1 := (a - 2*b + 2*c) + (2*a - b + 2*c) + (2*a - 2*b + 3*c)
    let p2 := (a + 2*b + 2*c) + (2*a + b + 2*c) + (2*a + 2*b + 3*c)
    let p3 := (-a + 2*b + 2*c) + (-2*a + b + 2*c) + (-2*a + 2*b + 3*c)
    p1 + p2 + p3 = 5*a + 5*b + 21*c := by ring


/-- The M₂ hypotenuse recurrence: c_{n+2} = 6c_{n+1} - c_n. -/
theorem m2_hyp_recurrence :
    ∀ n : ℕ, (m2_branch (n + 2)).2.2 = 6 * (m2_branch (n + 1)).2.2 - (m2_branch n).2.2 := by
  intro n
  induction n with
  | zero => norm_num [m2_branch]
  | succ n ih => simp only [m2_branch]; linarith


/-- The perimeter of the M₂ branch. -/
def m2_perimeter (n : ℕ) : ℤ :=
  let t := m2_branch n
  t.1 + t.2.1 + t.2.2

#eval m2_perimeter 0  -- 12
#eval m2_perimeter 1  -- 70
#eval m2_perimeter 2  -- 408
#eval m2_perimeter 3  -- 2378


/-- The minimum hypotenuse growth factor is > 1 for each transformation. -/
theorem min_hyp_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c + 2 ≤ 2 * a + 2 * b + 3 * c := by linarith

