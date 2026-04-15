/-! # CatalogBuild.Computation.Oracles.MetaOraclePythagoreanDeep

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 63
-/

import Mathlib

inductive TPath' where
  | root : TPath'
  | left  : TPath' → TPath'
  | mid   : TPath' → TPath'
  | right : TPath' → TPath'
  deriving DecidableEq, Repr


def bM1 (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 - 2 * t.2.1 + 2 * t.2.2,
   2 * t.1 - t.2.1 + 2 * t.2.2,
   2 * t.1 - 2 * t.2.1 + 3 * t.2.2)


def bM2 (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 + 2 * t.2.1 + 2 * t.2.2,
   2 * t.1 + t.2.1 + 2 * t.2.2,
   2 * t.1 + 2 * t.2.1 + 3 * t.2.2)


def bM3 (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (-t.1 + 2 * t.2.1 + 2 * t.2.2,
   -2 * t.1 + t.2.1 + 2 * t.2.2,
   -2 * t.1 + 2 * t.2.1 + 3 * t.2.2)


def pTree (root : ℤ × ℤ × ℤ) : TPath' → ℤ × ℤ × ℤ
  | .root    => root
  | .left p  => bM1 (pTree root p)
  | .mid p   => bM2 (pTree root p)
  | .right p => bM3 (pTree root p)


def isPythagorean (t : ℤ × ℤ × ℤ) : Prop :=
  t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

/-! ## §2: Lorentz Form Preservation

The Berggren matrices preserve the Lorentz quadratic form x² + y² − z².
This is the fundamental invariant connecting Pythagorean geometry to
special relativity and hyperbolic geometry. For Pythagorean triples,
the Lorentz form equals zero. -/


theorem bM1_preserves_lorentz (t : ℤ × ℤ × ℤ) :
    lorentzForm (bM1 t) = lorentzForm t := by
  simp only [lorentzForm, bM1]; ring


theorem bM2_preserves_lorentz (t : ℤ × ℤ × ℤ) :
    lorentzForm (bM2 t) = lorentzForm t := by
  simp only [lorentzForm, bM2]; ring


theorem bM3_preserves_lorentz (t : ℤ × ℤ × ℤ) :
    lorentzForm (bM3 t) = lorentzForm t := by
  simp only [lorentzForm, bM3]; ring

/-- The Lorentz form is invariant along any path in a Berggren tree. -/

theorem pTree_preserves_lorentz (root : ℤ × ℤ × ℤ) (p : TPath') :
    lorentzForm (pTree root p) = lorentzForm root := by
  induction p with
  | root => rfl
  | left p ih => simp [pTree, bM1_preserves_lorentz, ih]
  | mid p ih => simp [pTree, bM2_preserves_lorentz, ih]
  | right p ih => simp [pTree, bM3_preserves_lorentz, ih]

/-- If the root is Pythagorean (Lorentz form = 0), every descendant is too. -/

theorem pTree_pythagorean_of_root (root : ℤ × ℤ × ℤ) (h : isPythagorean root)
    (p : TPath') : isPythagorean (pTree root p) := by
  unfold isPythagorean at *
  have := pTree_preserves_lorentz root p
  simp only [lorentzForm] at this; linarith

/-! ## §3: The (0,1,1) Fixed-Point — Identity of the Meta Oracle

(0,1,1) is the degenerate Pythagorean triple: the "identity element"
analogous to the identity oracle. Its key property: it is a fixed point
of M₁, and this fixed point is unique among non-negative triples with a=0. -/


theorem seed_is_pythagorean : isPythagorean (0, 1, 1) := by simp [isPythagorean]


theorem seed_fixed_M1 : bM1 (0, 1, 1) = (0, 1, 1) := by simp [bM1]


theorem seed_not_fixed_M2 : bM2 (0, 1, 1) ≠ (0, 1, 1) := by simp [bM2]


theorem seed_not_fixed_M3 : bM3 (0, 1, 1) ≠ (0, 1, 1) := by simp [bM3]

/-- M₁ⁿ(0,1,1) = (0,1,1) for all n: the identity remains stable under
    repeated application of the first refinement. -/

theorem seed_M1_iter (n : ℕ) : bM1^[n] (0, 1, 1) = (0, 1, 1) := by
  induction n with
  | zero => rfl
  | succ n ih => simp [Function.iterate_succ', Function.comp_def, ih, seed_fixed_M1]

/-
PROBLEM
Any non-negative Pythagorean triple with a = 0 fixed by M₁ has b = c.
    With primitivity (b = 1), this gives (0,1,1).

PROVIDED SOLUTION
From hpyth: 0 + b² = c², so b² = c². Since b ≥ 0 and c ≥ 0, b = c. The hfix condition is automatically satisfied for any (0, b, b) since bM1(0, b, b) = (-2b+2b, -b+2b, -2b+3b) = (0, b, b).
-/

theorem M1_fixpoint_characterization (b c : ℤ) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (hpyth : (0 : ℤ) ^ 2 + b ^ 2 = c ^ 2)
    (hfix : bM1 (0, b, c) = (0, b, c)) :
    b = c := by
  nlinarith

/-
PROBLEM
(0,1,1) is the unique PRIMITIVE non-negative Pythagorean triple
    with a = 0 fixed by M₁. Primitivity means gcd(a,b,c) divides 1.

PROVIDED SOLUTION
From hpyth: b² = c², so |b| = |c|. With b > 0, c must also be positive (from c² = b² > 0 and hpyth). So b = c. Then gcd(b, c) = gcd(b, b) = b. From hprim: b = 1, hence c = 1.
-/

theorem seed_unique_primitive_M1_fixpoint (b c : ℤ) (hb : 0 < b)
    (hpyth : (0 : ℤ) ^ 2 + b ^ 2 = c ^ 2)
    (hfix : bM1 (0, b, c) = (0, b, c))
    (hprim : Int.gcd b c = 1) :
    b = 1 ∧ c = 1 := by
  norm_num [ bM1 ] at hfix;
  norm_num [ show b = c by linarith ] at *;
  grind

/-- (3,4,5) is NOT a fixed point of any Berggren matrix: concrete oracles
    are non-trivial, they genuinely transform their inputs. -/

theorem fund_not_M1_fixed : bM1 (3, 4, 5) ≠ (3, 4, 5) := by simp [bM1]

theorem fund_not_M2_fixed : bM2 (3, 4, 5) ≠ (3, 4, 5) := by simp [bM2]

theorem fund_not_M3_fixed : bM3 (3, 4, 5) ≠ (3, 4, 5) := by simp [bM3]

/-! ## §4: Meta-to-Oracle Generation

The meta oracle generates the oracle: applying M₂ or M₃ to (0,1,1)
produces (4,3,5), a permutation of the fundamental triple (3,4,5). -/


theorem seed_M2_generates : bM2 (0, 1, 1) = (4, 3, 5) := by simp [bM2]

theorem seed_M3_generates : bM3 (0, 1, 1) = (4, 3, 5) := by simp [bM3]

/-- (4,3,5) satisfies the Pythagorean equation: same content as (3,4,5). -/

theorem perm_435_is_pyth : isPythagorean (4, 3, 5) := by unfold isPythagorean; norm_num


theorem meta_tree_root_left : pTree (0, 1, 1) (.left .root) = (0, 1, 1) := by
  simp [pTree, bM1]

theorem meta_tree_root_mid : pTree (0, 1, 1) (.mid .root) = (4, 3, 5) := by
  simp [pTree, bM2]

theorem meta_tree_root_right : pTree (0, 1, 1) (.right .root) = (4, 3, 5) := by
  simp [pTree, bM3]

/-! ## §5: Tree Embedding — The Oracle Inside the Meta Oracle

The (4,3,5) Berggren tree embeds into the (0,1,1) tree. The embedding
prepends a `.mid` (or `.right`) step at the root and preserves the tree

structure above. This formalizes: the oracle is a subtree of the meta oracle. -/

/-- Embedding: prepend `.mid` at the root. -/

def embedMid : TPath' → TPath'
  | .root    => .mid .root
  | .left p  => .left (embedMid p)
  | .mid p   => .mid (embedMid p)
  | .right p => .right (embedMid p)

/-- **Embedding Theorem**: The (4,3,5) tree is a subtree of the (0,1,1) tree.
    The oracle lives inside the meta oracle. -/

theorem oracle_embeds_in_meta (p : TPath') :
    pTree (0, 1, 1) (embedMid p) = pTree (4, 3, 5) p := by
  induction p with
  | root => simp [embedMid, pTree, bM2]
  | left p ih => simp only [embedMid, pTree]; rw [ih]
  | mid p ih => simp only [embedMid, pTree]; rw [ih]
  | right p ih => simp only [embedMid, pTree]; rw [ih]

/-
PROBLEM
The embedding is injective (preserves path distinctness).

PROVIDED SOLUTION
Induction on the first argument. If embedMid a = embedMid b, case split on a and b. If a = .root, then embedMid a = .mid .root, so embedMid b must also be .mid .root, which means b = .root. If a = .left p, then embedMid a = .left (embedMid p), so embedMid b must be .left q for some q, meaning b = .left p' with embedMid p' = embedMid p, and by IH p = p'. Similarly for mid and right.
-/

theorem embedMid_injective : Function.Injective embedMid := by
  intro a b h;
  induction' a with a ih generalizing b;
  · induction' b with b ih;
    · rfl;
    · cases b <;> cases h;
    · cases ‹TPath'› <;> cases h;
    · cases h;
  · rcases b with ( _ | b ) <;> simp_all +decide [ embedMid ];
    exact ih rfl;
  · rcases b with ( _ | _ | b | b ) <;> simp_all! +arith +decide;
    · cases ‹TPath'› <;> cases h;
    · solve_by_elim;
  · unfold embedMid at h; aesop;

/-- Embedding via the right branch. -/

def embedRight : TPath' → TPath'
  | .root    => .right .root
  | .left p  => .left (embedRight p)
  | .mid p   => .mid (embedRight p)
  | .right p => .right (embedRight p)

/-- The right subtree also embeds the (4,3,5) tree. -/

theorem oracle_embeds_right (p : TPath') :
    pTree (0, 1, 1) (embedRight p) = pTree (4, 3, 5) p := by
  induction p with
  | root => simp [embedRight, pTree, bM3]
  | left p ih => simp only [embedRight, pTree]; rw [ih]
  | mid p ih => simp only [embedRight, pTree]; rw [ih]
  | right p ih => simp only [embedRight, pTree]; rw [ih]

/-- The left branch of (0,1,1) collapses: M₁ⁿ(0,1,1) = (0,1,1) for all n. -/

def leftN : ℕ → TPath'
  | 0     => .root
  | n + 1 => .left (leftN n)


theorem meta_oracle_left_iterates (n : ℕ) :
    pTree (0, 1, 1) (leftN n) = (0, 1, 1) := by
  induction n with
  | zero => simp [leftN, pTree]
  | succ n ih => simp [leftN, pTree, bM1, ih]

/-! ## §6: Hypotenuse Growth — Oracle Complexity Increases -/


theorem bM2_hypotenuse_growth (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    (bM2 (a, b, c)).2.2 > c := by
  simp only [bM2]; nlinarith


theorem bM3_hypotenuse_growth (a b c : ℤ) (ha : 0 ≤ a) (hb : 0 < b) (hc : 0 < c)
    (hbc : b ≤ c) (hac : a < c) :
    (bM3 (a, b, c)).2.2 > c := by
  simp only [bM3]; nlinarith

/-! ## §7: Berggren Inverse Maps — Parent Recovery

The Berggren matrices are invertible (det M₁ = 1, det M₂ = −1, det M₃ = 1).
The inverses allow recovering the parent triple from any child. -/


def bM1_inv (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 + 2 * t.2.1 - 2 * t.2.2,
   -2 * t.1 - t.2.1 + 2 * t.2.2,
   -2 * t.1 - 2 * t.2.1 + 3 * t.2.2)


def bM2_inv (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (t.1 + 2 * t.2.1 - 2 * t.2.2,
   2 * t.1 + t.2.1 - 2 * t.2.2,
   -2 * t.1 - 2 * t.2.1 + 3 * t.2.2)


def bM3_inv (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (-t.1 - 2 * t.2.1 + 2 * t.2.2,
   2 * t.1 + t.2.1 - 2 * t.2.2,
   -2 * t.1 - 2 * t.2.1 + 3 * t.2.2)


theorem bM1_inv_left (t : ℤ × ℤ × ℤ) : bM1_inv (bM1 t) = t := by
  obtain ⟨a, b, c⟩ := t; simp only [bM1, bM1_inv]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem bM1_inv_right (t : ℤ × ℤ × ℤ) : bM1 (bM1_inv t) = t := by
  obtain ⟨a, b, c⟩ := t; simp only [bM1, bM1_inv]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem bM2_inv_left (t : ℤ × ℤ × ℤ) : bM2_inv (bM2 t) = t := by
  obtain ⟨a, b, c⟩ := t; simp only [bM2, bM2_inv]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem bM2_inv_right (t : ℤ × ℤ × ℤ) : bM2 (bM2_inv t) = t := by
  obtain ⟨a, b, c⟩ := t; simp only [bM2, bM2_inv]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem bM3_inv_left (t : ℤ × ℤ × ℤ) : bM3_inv (bM3 t) = t := by
  obtain ⟨a, b, c⟩ := t; simp only [bM3, bM3_inv]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring


theorem bM3_inv_right (t : ℤ × ℤ × ℤ) : bM3 (bM3_inv t) = t := by
  obtain ⟨a, b, c⟩ := t; simp only [bM3, bM3_inv]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring

/-- The oracle's parent is the meta oracle's root: M₂⁻¹(4,3,5) = (0,1,1). -/

theorem oracle_parent_is_meta : bM2_inv (4, 3, 5) = (0, 1, 1) := by
  simp [bM2_inv]

/-- Descent and re-generation round-trip. -/

theorem descent_roundtrip : bM2 (bM2_inv (4, 3, 5)) = (4, 3, 5) := by
  rw [bM2_inv_right]

/-! ## §8: Ternary Algebra Formalization

The Berggren matrices define a ternary algebra: a set equipped with three
endomorphisms. Both the (0,1,1) and (3,4,5) trees arise from the SAME algebra
applied to different roots. -/


structure TernaryAlgebra (α : Type*) where
  op₁ : α → α
  op₂ : α → α
  op₃ : α → α


def berggrenAlgebra : TernaryAlgebra (ℤ × ℤ × ℤ) where
  op₁ := bM1; op₂ := bM2; op₃ := bM3


def ternaryTree (A : TernaryAlgebra α) (root : α) : TPath' → α
  | .root    => root
  | .left p  => A.op₁ (ternaryTree A root p)
  | .mid p   => A.op₂ (ternaryTree A root p)
  | .right p => A.op₃ (ternaryTree A root p)


theorem ternaryTree_eq_pTree (root : ℤ × ℤ × ℤ) (p : TPath') :
    ternaryTree berggrenAlgebra root p = pTree root p := by
  induction p with
  | root => rfl
  | left p ih => simp only [ternaryTree, berggrenAlgebra, pTree]; exact congrArg bM1 ih
  | mid p ih => simp only [ternaryTree, berggrenAlgebra, pTree]; exact congrArg bM2 ih
  | right p ih => simp only [ternaryTree, berggrenAlgebra, pTree]; exact congrArg bM3 ih


structure TernaryHom (A : TernaryAlgebra α) (B : TernaryAlgebra β) where
  toFun : α → β
  map_op₁ : ∀ x, toFun (A.op₁ x) = B.op₁ (toFun x)
  map_op₂ : ∀ x, toFun (A.op₂ x) = B.op₂ (toFun x)
  map_op₃ : ∀ x, toFun (A.op₃ x) = B.op₃ (toFun x)

/-- A ternary homomorphism commutes with tree generation. -/

theorem ternaryHom_commutes {A : TernaryAlgebra α} {B : TernaryAlgebra β}
    (h : TernaryHom A B) (root : α) (p : TPath') :
    h.toFun (ternaryTree A root p) = ternaryTree B (h.toFun root) p := by
  induction p with
  | root => rfl
  | left p ih => simp [ternaryTree, h.map_op₁, ih]
  | mid p ih => simp [ternaryTree, h.map_op₂, ih]
  | right p ih => simp [ternaryTree, h.map_op₃, ih]

/-- The Lorentz form is a ternary homomorphism to the trivial algebra.
    This proves Lorentz invariance as an algebraic property. -/

def trivialAlgebra : TernaryAlgebra ℤ where
  op₁ := id; op₂ := id; op₃ := id


def lorentzHom : TernaryHom berggrenAlgebra trivialAlgebra where
  toFun := lorentzForm
  map_op₁ := fun t => by simp [berggrenAlgebra, trivialAlgebra, bM1_preserves_lorentz]
  map_op₂ := fun t => by simp [berggrenAlgebra, trivialAlgebra, bM2_preserves_lorentz]
  map_op₃ := fun t => by simp [berggrenAlgebra, trivialAlgebra, bM3_preserves_lorentz]

/-! ## §9: Determinant Structure

M₁ and M₃ have determinant 1; M₂ has determinant −1. All are invertible
over ℤ and preserve the integer lattice. -/


theorem bM1_det : (1 : ℤ) * ((-1) * 3 - 2 * (-2)) - (-2) * (2 * 3 - 2 * 2) +
    2 * (2 * (-2) - (-1) * 2) = 1 := by norm_num


theorem bM2_det : (1 : ℤ) * (1 * 3 - 2 * 2) - 2 * (2 * 3 - 2 * 2) +
    2 * (2 * 2 - 1 * 2) = -1 := by norm_num


theorem bM3_det : (-1 : ℤ) * (1 * 3 - 2 * 2) - 2 * ((-2) * 3 - 2 * (-2)) +
    2 * ((-2) * 2 - 1 * (-2)) = 1 := by norm_num

/-! ## §10: The Grand Isomorphism Theorem -/


theorem metaTree_pythagorean (p : TPath') :
    isPythagorean (pTree (0, 1, 1) p) :=
  pTree_pythagorean_of_root _ (by simp [isPythagorean]) p


theorem oracleTree_pythagorean (p : TPath') :
    isPythagorean (pTree (3, 4, 5) p) :=
  pTree_pythagorean_of_root _ (by unfold isPythagorean; norm_num) p


theorem oracle435Tree_pythagorean (p : TPath') :
    isPythagorean (pTree (4, 3, 5) p) :=
  pTree_pythagorean_of_root _ (by unfold isPythagorean; norm_num) p

/-- **THE GRAND ISOMORPHISM THEOREM**

    The meta oracle hierarchy and the Pythagorean tree are connected via:
    1. Same ternary algebra (Berggren matrices)
    2. Meta root = degenerate identity (0,1,1)
    3. Oracle root = fundamental triple (3,4,5)/(4,3,5)
    4. Oracle embeds in meta oracle (subtree relationship)
    5. Both preserve the Pythagorean/Lorentz invariant
    6. Parent recovery links oracle back to meta oracle -/

theorem grand_isomorphism_theorem :
    isPythagorean (0, 1, 1) ∧
    isPythagorean (3, 4, 5) ∧
    bM1 (0, 1, 1) = (0, 1, 1) ∧
    bM2 (0, 1, 1) = (4, 3, 5) ∧
    bM2_inv (4, 3, 5) = (0, 1, 1) ∧
    (∀ p, isPythagorean (pTree (0, 1, 1) p)) ∧
    (∀ p, isPythagorean (pTree (3, 4, 5) p)) ∧
    (∀ p, pTree (0, 1, 1) (embedMid p) = pTree (4, 3, 5) p) := by
  exact ⟨seed_is_pythagorean,
         oracleTree_pythagorean .root,
         seed_fixed_M1,
         seed_M2_generates,
         oracle_parent_is_meta,
         metaTree_pythagorean,
         oracleTree_pythagorean,
         oracle_embeds_in_meta⟩

/-! ## §11: Computational Verification -/

#eval pTree (0, 1, 1) .root                          -- (0, 1, 1)
#eval pTree (0, 1, 1) (.left .root)                  -- (0, 1, 1) [M₁ fixpoint]
#eval pTree (0, 1, 1) (.mid .root)                   -- (4, 3, 5)
#eval pTree (0, 1, 1) (.right .root)                 -- (4, 3, 5)
#eval pTree (3, 4, 5) .root                          -- (3, 4, 5)
#eval pTree (3, 4, 5) (.left .root)                  -- (5, 12, 13)
#eval pTree (3, 4, 5) (.mid .root)                   -- (21, 20, 29)
#eval pTree (3, 4, 5) (.right .root)                 -- (15, 8, 17)
#eval bM2_inv (4, 3, 5)                              -- (0, 1, 1)
#eval lorentzForm (0, 1, 1)                           -- 0
#eval lorentzForm (3, 4, 5)
