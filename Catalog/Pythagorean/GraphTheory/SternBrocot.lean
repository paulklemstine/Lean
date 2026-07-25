import Mathlib

/-! # CatalogBuild.Speculative.Other.SternBrocot

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 10
-/

/-- Left and right directions in the tree. -/
inductive Dir | L | R
  deriving DecidableEq, Repr

/-- A path in the Stern-Brocot tree is a list of directions. -/
abbrev Path := List Dir

/-- Navigate the Stern-Brocot tree: starting from bounds (a/b, c/d),
follow a path to reach a node via mediants. -/
def navigate : Path → ℕ × ℕ × ℕ × ℕ → ℕ × ℕ
  | [], (a, b, c, d) => (a + c, b + d)
  | Dir.L :: rest, (a, b, c, d) => navigate rest (a, b, a + c, b + d)
  | Dir.R :: rest, (a, b, c, d) => navigate rest (a + c, b + d, c, d)

/-- The Stern-Brocot tree entry corresponding to a path,
starting from the standard bounds 0/1 and 1/0. -/
def fromPath (p : Path) : ℕ × ℕ :=
  navigate p (0, 1, 1, 0)

/-- The bounds after navigating a path. -/
def navigateBounds : Path → ℕ × ℕ × ℕ × ℕ → ℕ × ℕ × ℕ × ℕ
  | [], bounds => bounds
  | Dir.L :: rest, (a, b, c, d) => navigateBounds rest (a, b, a + c, b + d)
  | Dir.R :: rest, (a, b, c, d) => navigateBounds rest (a + c, b + d, c, d)

/-- The mediant of a/b and c/d preserves the adjacency invariant:
if bc - ad = 1 then the left and right children also satisfy this. -/
theorem mediant_adjacency_left (a b c d : ℕ)
    (h : b * c = a * d + 1) :
    (b + d) * c = (a + c) * d + 1 := by ring_nf; linarith

/-- [Section: # CatalogBuild.Speculative.Other.SternBrocot
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 10] -/
theorem mediant_adjacency_right (a b c d : ℕ)
    (h : b * c = a * d + 1) :
    b * (a + c) = a * (b + d) + 1 := by ring_nf; linarith

/-- The adjacency invariant is preserved through any path in the tree. -/
theorem adjacency_invariant (p : Path) (a b c d : ℕ)
    (h : b * c = a * d + 1) :
    let (a', b', c', d') := navigateBounds p (a, b, c, d)
    b' * c' = a' * d' + 1 := by
  induction p generalizing a b c d with
  | nil => simpa using h
  | cons dir rest ih =>
    cases dir <;> simp [navigateBounds] <;> apply ih <;> ring_nf <;> linarith

/-- The standard Stern-Brocot tree maintains the adjacency invariant. -/
theorem standard_adjacency (p : Path) :
    let (a', b', c', d') := navigateBounds p (0, 1, 1, 0)
    b' * c' = a' * d' + 1 := by
  exact adjacency_invariant p 0 1 1 0 (by ring)

/-- [Section: # CatalogBuild.Speculative.Other.SternBrocot
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 10] -/
theorem fromPath_den_pos (p : Path) : 0 < (fromPath p).2 := by
  -- By the adjacency invariant, we know that the denominator of any node in the Stern-Brocot tree is positive.
  have h_denom_pos : ∀ a b c d, b * c = a * d + 1 → ∀ p : Path, 0 < (navigate p (a, b, c, d)).2 := by
    intro a b c d h p;
    induction' p with p hp generalizing a b c d;
    · exact add_pos_of_pos_of_nonneg ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ( Nat.zero_le _ );
    · cases p <;> simp_all +decide [ SternBrocot.navigate ];
      · exact ‹∀ a b c d : ℕ, b * c = a * d + 1 → 0 < ( navigate hp ( a, b, c, d ) ).2› _ _ _ _ ( by linarith );
      · exact ‹∀ ( a b c d : ℕ ), b * c = a * d + 1 → 0 < ( navigate hp ( a, b, c, d ) ).2› _ _ _ _ ( by linarith );
  exact h_denom_pos 0 1 1 0 rfl p