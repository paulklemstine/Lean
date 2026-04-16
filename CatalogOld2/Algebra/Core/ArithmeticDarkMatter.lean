/-! # CatalogBuild.Algebra.Core.ArithmeticDarkMatter

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 24
-/

import Mathlib

/-- The Lorentz form Q(a,b,c) = a² + b² - c² -/
def Q_form (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2


/-- An arithmetic particle: an integer triple with its mass classification -/
structure ArithParticle where
  a : ℤ
  b : ℤ
  c : ℤ
  a_pos : 0 < a
  b_pos : 0 < b
  c_pos : 0 < c


/-- The mass-squared of a particle -/
def ArithParticle.massSq (p : ArithParticle) : ℤ :=
  p.c ^ 2 - p.a ^ 2 - p.b ^ 2


/-- A particle is a photon (null/massless) -/
def ArithParticle.isPhoton (p : ArithParticle) : Prop :=
  p.massSq = 0


/-- A particle is massive (timelike) -/
def ArithParticle.isMassive' (p : ArithParticle) : Prop :=
  p.massSq > 0


/-- A particle is tachyonic (spacelike) -/
def ArithParticle.isTachyon (p : ArithParticle) : Prop :=
  p.massSq < 0


/-- The mass spectrum: which mass-squared values are realized? -/
def massIsRealized (m_sq : ℤ) : Prop :=
  ∃ a b c : ℤ, 0 < a ∧ 0 < b ∧ 0 < c ∧ c ^ 2 - a ^ 2 - b ^ 2 = m_sq


theorem every_nonneg_mass_realized (m_sq : ℕ) :
    massIsRealized (m_sq : ℤ) := by
  by_contra h;
  -- For even m_sq, we can take a=1, b=m_sq/2, c=m_sq/2+1.
  by_cases h_even : Even m_sq;
  · obtain ⟨ k, rfl ⟩ := h_even;
    exact h ⟨ 1, k, k + 1, by norm_num, by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by rintro rfl; exact h ⟨ 3, 4, 5, by norm_num ⟩ ) ], by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by rintro rfl; exact h ⟨ 3, 4, 5, by norm_num ⟩ ) ], by push_cast; linarith ⟩;
  · -- For odd m_sq, we can take a=2, b=(m_sq+3)/2, c=(m_sq+5)/2.
    obtain ⟨k, hk⟩ : ∃ k : ℕ, m_sq = 2 * k + 1 := by
      exact m_sq.even_or_odd.resolve_left h_even;
    refine h ⟨ 2, k + 2, k + 3, by norm_num, by linarith, by linarith, ?_ ⟩ ; push_cast [ hk ] ; ring


/-- The Berggren B₁ matrix action on a triple -/
def berggren_B1 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


/-- The Berggren matrices preserve Q (the full Lorentz form, not just Q=0) -/
theorem B1_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B1 a b c).1 (berggren_B1 a b c).2.1 (berggren_B1 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B1 Q_form
  ring


/-- B₂ also preserves Q -/
def berggren_B2 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


theorem B2_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B2 a b c).1 (berggren_B2 a b c).2.1 (berggren_B2 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B2 Q_form
  ring


/-- B₃ also preserves Q -/
def berggren_B3 (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


theorem B3_preserves_Q (a b c : ℤ) :
    Q_form (berggren_B3 a b c).1 (berggren_B3 a b c).2.1 (berggren_B3 a b c).2.2
    = Q_form a b c := by
  unfold berggren_B3 Q_form
  ring


/-- A path in the dark matter tree (same branching as the photon tree) -/
inductive DarkPath where
  | root : DarkPath
  | b1 : DarkPath → DarkPath
  | b2 : DarkPath → DarkPath
  | b3 : DarkPath → DarkPath
  deriving Repr


/-- The triple at a given dark matter path, starting from seed (a₀, b₀, c₀) -/
def darkTriple (seed : ℤ × ℤ × ℤ) : DarkPath → ℤ × ℤ × ℤ
  | .root => seed
  | .b1 p =>
    let (a, b, c) := darkTriple seed p
    (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .b2 p =>
    let (a, b, c) := darkTriple seed p
    (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .b3 p =>
    let (a, b, c) := darkTriple seed p
    (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


/-- The dark matter tree preserves the Lorentz form (mass conservation) -/
theorem dark_mass_conservation (seed : ℤ × ℤ × ℤ) (p : DarkPath) :
    Q_form (darkTriple seed p).1 (darkTriple seed p).2.1 (darkTriple seed p).2.2
    = Q_form seed.1 seed.2.1 seed.2.2 := by
  induction p with
  | root => rfl
  | b1 p ih =>
    simp only [darkTriple]
    rw [show (darkTriple seed p).1 = (darkTriple seed p).1 from rfl]
    have : Q_form (darkTriple seed p).1 (darkTriple seed p).2.1 (darkTriple seed p).2.2
      = Q_form seed.1 seed.2.1 seed.2.2 := ih
    set a := (darkTriple seed p).1
    set b := (darkTriple seed p).2.1
    set c := (darkTriple seed p).2.2
    show Q_form (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = Q_form seed.1 seed.2.1 seed.2.2
    rw [show Q_form (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = Q_form a b c from by unfold Q_form; ring]
    exact ih
  | b2 p ih =>
    simp only [darkTriple]
    set a := (darkTriple seed p).1
    set b := (darkTriple seed p).2.1
    set c := (darkTriple seed p).2.2
    show Q_form (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = Q_form seed.1 seed.2.1 seed.2.2
    rw [show Q_form (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = Q_form a b c from by unfold Q_form; ring]
    exact ih
  | b3 p ih =>
    simp only [darkTriple]
    set a := (darkTriple seed p).1
    set b := (darkTriple seed p).2.1
    set c := (darkTriple seed p).2.2
    show Q_form (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = Q_form seed.1 seed.2.1 seed.2.2
    rw [show Q_form (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = Q_form a b c from by unfold Q_form; ring]
    exact ih


/-- Count triples by mass-squared value up to bound N -/
def massCensus (N : ℕ) : List (ℤ × ℕ) :=
  let triples := do
    let c ← List.range (N + 1)
    let b ← List.range (c + 1)
    let a ← List.range (b + 1)
    if a > 0 && b > 0 && c > 0 then
      return (a, b, c)
    else .nil
  let masses := triples.map fun (a, b, c) =>
    ((c * c : ℤ) - (a * a : ℤ) - (b * b : ℤ))
  -- Group by mass-squared and count
  let distinct := masses.eraseDups
  let counts := distinct.map fun m => (m, (masses.filter (· == m)).length)
  let filtered := counts.filter (fun p => p.2 > 2)
  filtered.take 20

-- #eval massCensus 15  -- slow


/-- The fraction of Pythagorean triples among all positive triples -/
def photonFraction (N : ℕ) : ℕ × ℕ :=
  let triples := do
    let c ← List.range (N + 1)
    let b ← List.range (c + 1)
    let a ← List.range (b + 1)
    if a > 0 && b > 0 && c > 0 then return (a, b, c) else .nil
  let total := triples.length
  let photons := triples.filter (fun (a, b, c) => a*a + b*b == c*c) |>.length
  (photons, total)

-- Watch the photon fraction shrink toward zero:
#eval photonFraction 20   -- photons vs total
#eval photonFraction 50
#eval photonFraction 100


/-- Generate the dark matter tree from a massive seed -/
def darkTreeLevel (seed : ℤ × ℤ × ℤ) : ℕ → List (ℤ × ℤ × ℤ)
  | 0 => [seed]
  | n + 1 =>
    let parents := darkTreeLevel seed n
    parents.flatMap fun (a, b, c) =>
      [ (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c),
        (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c),
        (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c) ]

-- Dark matter tree from seed (1, 1, 2) [mass² = 2]:
#eval darkTreeLevel (1, 1, 2) 0
#eval darkTreeLevel (1, 1, 2) 1
-- Verify mass conservation:
#eval (darkTreeLevel (1, 1, 2) 1).map fun (a, b, c) => c^2 - a^2 - b^2

-- Dark matter tree from seed (1, 2, 3) [mass² = 4]:
#eval darkTreeLevel (1, 2, 3) 0
#eval darkTreeLevel (1, 2, 3) 1
#eval (darkTreeLevel (1, 2, 3) 1).map fun (a, b, c) => c^2 - a^2 - b^2

-- Tachyon tree from seed (2, 2, 1) [mass² = -7]:
#eval darkTreeLevel (2, 2, 1) 0
#eval darkTreeLevel (2, 2, 1) 1
#eval (darkTreeLevel (2, 2, 1) 1).map fun (a, b, c) => c^2 - a^2 - b^2


/-- The universal branching number (independent of mass) -/
theorem universal_branching : ∀ (seed : ℤ × ℤ × ℤ),
    (darkTreeLevel seed 1).length = 3 * (darkTreeLevel seed 0).length := by
  intro seed
  simp [darkTreeLevel]


/-- The number of possible photon states at depth n -/
def photonStates (n : ℕ) : ℕ := 3 ^ n


/-- The number of possible dark matter states at depth n with m mass choices -/
def darkStates (n m : ℕ) : ℕ := m * 3 ^ n


/-- Dark matter has strictly more states when there's more than one mass -/
theorem dark_has_more_states (n : ℕ) (m : ℕ) (hm : 1 < m) :
    photonStates n < darkStates n m := by
  unfold photonStates darkStates
  have h3 : 0 < 3 ^ n := Nat.pos_of_ne_zero (by positivity)
  nlinarith

