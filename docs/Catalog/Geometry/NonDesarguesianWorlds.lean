import Mathlib

/-!
# Projective completion of a planar ternary ring

This file isolates the incidence-theoretic core of coordinatization.  Multiplication
need not be associative: the three solution axioms of a planar ternary operation
are exactly what the usual affine-coordinate proof needs in order to construct a
projective plane.
-/

namespace NonDesarguesianWorlds

/-- The solution axioms needed from a planar ternary operation.  The pair in
`two_points` is `(slope, intercept)`; the pair in `two_slopes` is `(x,y)`.
No associativity or distributivity is assumed. -/
structure PlanarTernaryRing (α : Type*) where
  ternary : α → α → α → α
  intercept : ∀ x m y, ∃! b, ternary x m b = y
  two_points : ∀ {x₁ x₂ : α}, x₁ ≠ x₂ → ∀ y₁ y₂,
    ∃! mb : α × α,
      ternary x₁ mb.1 mb.2 = y₁ ∧ ternary x₂ mb.1 mb.2 = y₂
  two_slopes : ∀ {m₁ m₂ : α}, m₁ ≠ m₂ → ∀ b₁ b₂,
    ∃! xy : α × α,
      xy.2 = ternary xy.1 m₁ b₁ ∧ xy.2 = ternary xy.1 m₂ b₂

/-- Points in the projective completion: affine points, one point for each
slope, and the distinguished point of the vertical direction. -/
inductive Point (α : Type*)
  | affine : α → α → Point α
  | ideal : α → Point α
  | verticalIdeal : Point α
  deriving DecidableEq, Fintype

/-- Lines in the projective completion: ordinary affine lines, vertical lines,
and the line at infinity. -/
inductive Line (α : Type*)
  | ordinary : α → α → Line α
  | vertical : α → Line α
  | atInfinity : Line α
  deriving DecidableEq, Fintype

/-- Incidence in the completion of a planar ternary ring. -/
def Incident {α : Type*} (R : PlanarTernaryRing α) : Point α → Line α → Prop
  | .affine x y, .ordinary m b => y = R.ternary x m b
  | .affine x _, .vertical a => x = a
  | .affine _ _, .atInfinity => False
  | .ideal m, .ordinary n _ => m = n
  | .ideal _, .vertical _ => False
  | .ideal _, .atInfinity => True
  | .verticalIdeal, .ordinary _ _ => False
  | .verticalIdeal, .vertical _ => True
  | .verticalIdeal, .atInfinity => True

/-- Any two distinct points in the completion determine a unique line. -/
theorem unique_line_through {α : Type*} (R : PlanarTernaryRing α)
    {P Q : Point α} (hne : P ≠ Q) :
    ∃! L : Line α, Incident R P L ∧ Incident R Q L := by
  rcases P with ⟨x₁, y₁⟩ | m₁ | rfl
  · rcases Q with ⟨x₂, y₂⟩ | m₂ | rfl
    · -- Both affine
      by_cases hx : x₁ = x₂
      · -- Same x-coordinate: vertical line
        subst hx
        refine ⟨Line.vertical x₁, ?_, ?_⟩
        · trivial
        · intro L hL
          rcases L with ⟨m, b⟩ | ⟨a⟩ | ⟨⟩
          · simp [Incident] at hL; cases hne (by simp_all)
          · simp [Incident] at hL; rw [hL]
          · simp [Incident] at hL
      · -- Different x-coordinates: use two_points
        have ⟨mb, ⟨hb₁, hb₂⟩, hb_unique⟩ := R.two_points hx y₁ y₂
        use Line.ordinary mb.1 mb.2
        refine ⟨⟨by simp [Incident, hb₁], by simp [Incident, hb₂]⟩, ?_⟩
        intro L hL
        rcases L with ⟨m, b'⟩ | ⟨a⟩ | ⟨_⟩
        · simp [Incident] at hL
          have heq := (hb_unique (m, b') ⟨hL.1.symm, hL.2.symm⟩).symm
          rw [heq]
        · simp [Incident] at hL; exact absurd (hL.1.trans hL.2.symm) hx
        · simp [Incident] at hL
    · -- P affine, Q ideal
      have ⟨b, hb, hb_unique⟩ := R.intercept x₁ m₂ y₁
      use Line.ordinary m₂ b
      refine ⟨⟨by simp [Incident, hb], rfl⟩, ?_⟩
      intro L hL
      rcases L with ⟨m, b'⟩ | ⟨a⟩ | ⟨⟩
      · simp [Incident] at hL
        have hm : m = m₂ := hL.2.symm
        have hb' : R.ternary x₁ m₂ b' = y₁ := by rw [← hm]; exact hL.1.symm
        rw [← hm]; simp [hb_unique b' hb']
      · simp [Incident] at hL
      · simp [Incident] at hL
    · -- P affine, Q verticalIdeal
      refine ⟨Line.vertical x₁, ?_, ?_⟩
      · trivial
      · intro L hL
        rcases L with ⟨_⟩ | ⟨_⟩ | ⟨_⟩
        · simp [Incident] at hL
        · simp [Incident] at hL; rw [hL]
        · simp [Incident] at hL
  · -- P ideal
    rcases Q with ⟨x₂, y₂⟩ | m₂ | rfl
    · -- P ideal, Q affine
      have ⟨b, hb, hb_unique⟩ := R.intercept x₂ m₁ y₂
      use Line.ordinary m₁ b
      refine ⟨⟨rfl, by simp [Incident, hb]⟩, ?_⟩
      intro L hL
      rcases L with ⟨m, b'⟩ | ⟨a⟩ | ⟨⟩
      · simp [Incident] at hL
        have hm : m = m₁ := hL.1.symm
        have hb' : R.ternary x₂ m₁ b' = y₂ := by rw [← hm]; exact hL.2.symm
        rw [← hm]; simp [hb_unique b' hb']
      · simp [Incident] at hL
      · simp [Incident] at hL
    · -- P ideal m₁, Q ideal m₂
      refine ⟨Line.atInfinity, ?_, ?_⟩
      · trivial
      · intro L hL
        rcases L with ⟨m, b⟩ | a | ⟨⟩
        · exfalso; simp [Incident] at hL; exact hne (congrArg Point.ideal (hL.1.trans hL.2.symm))
        · cases hL.1
        · trivial
    · -- P ideal, Q verticalIdeal
      refine ⟨Line.atInfinity, ?_, ?_⟩
      · trivial
      · intro L hL
        rcases L with ⟨_⟩ | ⟨_⟩ | ⟨_⟩
        · simp [Incident] at hL
        · simp [Incident] at hL
        · trivial
  · -- P verticalIdeal
    rcases Q with ⟨x₂, y₂⟩ | m₂ | rfl
    · -- P verticalIdeal, Q affine
      refine ⟨Line.vertical x₂, ?_, ?_⟩
      · trivial
      · intro L hL
        rcases L with ⟨_⟩ | ⟨_⟩ | ⟨_⟩
        · simp [Incident] at hL
        · simp [Incident] at hL; rw [hL]
        · simp [Incident] at hL
    · -- P verticalIdeal, Q ideal
      refine ⟨Line.atInfinity, ?_, ?_⟩
      · trivial
      · intro L hL
        rcases L with ⟨_⟩ | ⟨_⟩ | ⟨_⟩
        · simp [Incident] at hL
        · simp [Incident] at hL
        · trivial
    · -- P verticalIdeal, Q verticalIdeal (contradiction)
      contradiction

/-- Any two distinct lines in the completion meet in a unique point. -/
theorem unique_intersection {α : Type*} (R : PlanarTernaryRing α)
    {L K : Line α} (hne : L ≠ K) :
    ∃! P : Point α, Incident R P L ∧ Incident R P K := by
  cases L <;> cases K <;> try trivial
  -- ordinary m b, ordinary n c
  · rename_i m b n c
    by_cases h : m = n
    · -- same slope, different intercepts: meet at ideal point
      subst h
      refine ⟨Point.ideal m, ⟨rfl, rfl⟩, ?_⟩
      intro y hy
      rcases y with ⟨x, y'⟩ | ⟨m'⟩ | ⟨⟩
      · simp [Incident] at hy
        have huniq := R.intercept x m y'
        have hbc := huniq.unique hy.1.symm hy.2.symm
        exact False.elim (hne (by rw [hbc]))
      · simp [Incident] at hy; rw [hy]
      · simp [Incident] at hy
    · -- different slopes: use two_slopes
      obtain ⟨⟨x, y⟩, ⟨hx₁, hx₂⟩, huniq⟩ := R.two_slopes h b c
      use Point.affine x y
      refine ⟨⟨hx₁, hx₂⟩, ?_⟩
      intro P ⟨hPL, hPK⟩
      match P with
      | Point.affine x' y' =>
        simp [Incident] at hPL hPK
        have heq := huniq (x', y') ⟨hPL, hPK⟩
        rw [Prod.ext_iff] at heq
        exact congrArg₂ Point.affine heq.1 heq.2
      | Point.ideal m' =>
        simp [Incident] at hPL hPK
        exact False.elim (h (hPL.symm.trans hPK))
      | Point.verticalIdeal => simp [Incident] at hPL
  -- ordinary m b, vertical a
  · rename_i m b a
    use Point.affine a (R.ternary a m b)
    refine ⟨⟨rfl, rfl⟩, ?_⟩
    intro P ⟨hPL, hPK⟩
    match P with
    | Point.affine x' y' =>
      simp [Incident] at hPL hPK
      rw [hPK] at hPL
      exact congrArg₂ Point.affine hPK hPL
    | Point.ideal m' => simp [Incident] at hPK
    | Point.verticalIdeal => simp [Incident] at hPL
  -- ordinary m b, atInfinity
  · rename_i m b
    use Point.ideal m
    refine ⟨⟨rfl, trivial⟩, ?_⟩
    intro P ⟨hPL, hPK⟩
    match P with
    | Point.affine x' y' => simp [Incident] at hPK
    | Point.ideal m' => simp_all [Incident]
    | Point.verticalIdeal => simp [Incident] at hPL
  -- vertical a, ordinary m b
  · rename_i a m b
    use Point.affine a (R.ternary a m b)
    refine ⟨⟨rfl, rfl⟩, ?_⟩
    intro P ⟨hPL, hPK⟩
    match P with
    | Point.affine x' y' =>
      simp [Incident] at hPL hPK
      rw [hPL] at hPK
      exact congrArg₂ Point.affine hPL hPK
    | Point.ideal m' => simp [Incident] at hPL
    | Point.verticalIdeal => simp [Incident] at hPK
  -- vertical a, vertical b with a ≠ b
  · rename_i a b
    use Point.verticalIdeal
    refine ⟨⟨trivial, trivial⟩, ?_⟩
    intro P ⟨hPL, hPK⟩
    match P with
    | Point.affine x' y' => simp_all [Incident]
    | Point.ideal m' => simp_all [Incident]
    | Point.verticalIdeal => rfl
  -- vertical a, atInfinity
  · rename_i a
    use Point.verticalIdeal
    refine ⟨⟨trivial, trivial⟩, ?_⟩
    intro P ⟨hPL, hPK⟩
    match P with
    | Point.affine x' y' => simp_all [Incident]
    | Point.ideal m' => simp_all [Incident]
    | Point.verticalIdeal => rfl
  -- atInfinity, ordinary m b
  · rename_i m b
    use Point.ideal m
    refine ⟨⟨trivial, rfl⟩, ?_⟩
    intro P ⟨hPL, hPK⟩
    match P with
    | Point.affine x' y' => simp_all [Incident]
    | Point.ideal m' => simp_all [Incident]
    | Point.verticalIdeal => simp [Incident] at hPK
  -- atInfinity, vertical a
  · rename_i a
    use Point.verticalIdeal
    refine ⟨⟨trivial, trivial⟩, ?_⟩
    intro P ⟨hPL, hPK⟩
    match P with
    | Point.affine x' y' => simp_all [Incident]
    | Point.ideal m' => simp_all [Incident]
    | Point.verticalIdeal => rfl

/-- The two characteristic unique-incidence axioms of a projective plane. -/
def HasProjectiveIncidence {P L : Type*} (I : P → L → Prop) : Prop :=
  (∀ ⦃p q⦄, p ≠ q → ∃! l, I p l ∧ I q l) ∧
  (∀ ⦃l k⦄, l ≠ k → ∃! p, I p l ∧ I p k)

/-- **Projective completion theorem.** Every planar ternary ring, without any
associativity assumption, yields an incidence structure satisfying both
unique-incidence axioms. -/
theorem completion_has_projective_incidence {α : Type*} (R : PlanarTernaryRing α) :
    HasProjectiveIncidence (Incident R) := by
  exact ⟨fun {_ _} h => unique_line_through R h,
    fun {_ _} h => unique_intersection R h⟩

/-- The constructors of `Point` exhibit it as a disjoint sum. -/
def pointEquiv (α : Type*) : Point α ≃ (α × α) ⊕ α ⊕ Unit where
  toFun
    | .affine x y => .inl (x, y)
    | .ideal m => .inr (.inl m)
    | .verticalIdeal => .inr (.inr ())
  invFun
    | .inl (x, y) => .affine x y
    | .inr (.inl m) => .ideal m
    | .inr (.inr _) => .verticalIdeal
  left_inv x := by cases x <;> rfl
  right_inv x := by
    rcases x with xy | rest
    · rfl
    · rcases rest with m | u
      · rfl
      · cases u
        rfl

/-- The constructors of `Line` exhibit it as the same disjoint sum. -/
def lineEquiv (α : Type*) : Line α ≃ (α × α) ⊕ α ⊕ Unit where
  toFun
    | .ordinary m b => .inl (m, b)
    | .vertical a => .inr (.inl a)
    | .atInfinity => .inr (.inr ())
  invFun
    | .inl (m, b) => .ordinary m b
    | .inr (.inl a) => .vertical a
    | .inr (.inr _) => .atInfinity
  left_inv x := by cases x <;> rfl
  right_inv x := by
    rcases x with mb | rest
    · rfl
    · rcases rest with a | u
      · rfl
      · cases u
        rfl

/-- The coordinate construction has exactly `q² + q + 1` points. -/
theorem point_count (α : Type*) [Fintype α] :
    Fintype.card (Point α) = Fintype.card α ^ 2 + Fintype.card α + 1 := by
  rw [Fintype.card_congr (pointEquiv α)]
  simp [pow_two, Nat.add_assoc]

/-- The coordinate construction has the same number of lines as points. -/
theorem line_count (α : Type*) [Fintype α] :
    Fintype.card (Line α) = Fintype.card α ^ 2 + Fintype.card α + 1 := by
  rw [Fintype.card_congr (lineEquiv α)]
  simp [pow_two, Nat.add_assoc]

/-- Associativity is equivalent to every element belonging to the left nucleus.
This is the precise algebraic obstruction used in quasifield coordinatizations. -/
def LeftNucleus {Q : Type*} (mul : Q → Q → Q) : Set Q :=
  {a | ∀ b c, mul a (mul b c) = mul (mul a b) c}

theorem leftNucleus_eq_univ_iff {Q : Type*} (mul : Q → Q → Q) :
    LeftNucleus mul = Set.univ ↔
      ∀ a b c, mul a (mul b c) = mul (mul a b) c := by
  constructor
  · intro h a b c
    have ha : a ∈ LeftNucleus mul := by rw [h]; trivial
    exact ha b c
  · intro h
    exact Set.eq_univ_iff_forall.mpr (fun a b c => h a b c)

/-- Consequently, a proper left nucleus supplies an explicit failure of
associativity. -/
theorem proper_leftNucleus_iff_nonassociative {Q : Type*} (mul : Q → Q → Q) :
    LeftNucleus mul ≠ Set.univ ↔
      ∃ a b c, mul a (mul b c) ≠ mul (mul a b) c := by
  rw [ne_eq, leftNucleus_eq_univ_iff]
  simp only [not_forall]

end NonDesarguesianWorlds