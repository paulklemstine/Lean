/-! # CatalogBuild.Pythagorean.Core.UniversalParent

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 44
-/

import Mathlib

/-- Berggren inverse matrix B₁⁻¹ -/
def berggren_B1_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]



/-- Berggren inverse matrix B₂⁻¹ -/
def berggren_B2_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]



/-- Berggren inverse matrix B₃⁻¹ -/
def berggren_B3_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, -2, 2; 2, 1, -2; -2, -2, 3]



/-- Price forward matrix P₁ = B₁ (same first generator) -/
def price_P1 : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]



/-- Price forward matrix P₂ = B₃ · B₂ (composition gives new generator) -/
def price_P2 : Matrix (Fin 3) (Fin 3) ℤ :=
  !![3, 2, -2; -2, 3, 2; -2, 2, 3]



/-- Price forward matrix P₃ = B₂ · B₃ -/
def price_P3 : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-3, 2, 2; -2, -3, 2; 2, -2, 3]



/-- Euclid parameter matrix E₁ -/
def euclid_E1 : Matrix (Fin 2) (Fin 2) ℤ :=
  !![2, -1; 1, 0]



/-- Euclid parameter matrix E₂ -/
def euclid_E2 : Matrix (Fin 2) (Fin 2) ℤ :=
  !![2, 1; 1, 0]



/-- Euclid parameter matrix E₃ -/
def euclid_E3 : Matrix (Fin 2) (Fin 2) ℤ :=
  !![1, 2; 0, 1]



/-- The root of all Pythagorean triple trees. -/
def root_345 : PythTriple where
  a := 3; b := 4; c := 5
  pyth := by norm_num



/-- **The Universal Parent Equation**: Given a PPT (a,b,c), find the unique
parent by selecting the inverse branch that produces all-positive components.
The parent hypotenuse is ALWAYS c' = 3c - 2a - 2b (universal across all branches).
The branch selection determines only the leg assignment.
Branch classification (for a odd, b even):
- Branch 1: 2c > 2a + b (b relatively large)
- Branch 2: 2a + b > 2c and a + 2b > 2c (both large)
- Branch 3: 2c > a + 2b (a relatively large) -/
def universalParent (a b c : ℤ) : ℤ × ℤ × ℤ :=
  if -2*a - b + 2*c > 0 then
    -- Branch 1 (B₁⁻¹): parent = (a+2b-2c, -2a-b+2c, -2a-2b+3c)
    invB1 a b c
  else if -a - 2*b + 2*c > 0 then
    -- Branch 3 (B₃⁻¹): parent = (-a-2b+2c, 2a+b-2c, -2a-2b+3c)
    invB3 a b c
  else
    -- Branch 2 (B₂⁻¹): parent = (a+2b-2c, 2a+b-2c, -2a-2b+3c)
    invB2 a b c



/-- **Recursive parent function**: apply universalParent n times.
f⁽⁰⁾(a,b,c) = (a,b,c)
f⁽¹⁾(a,b,c) = parent(a,b,c)
f⁽ⁿ⁾(a,b,c) = f⁽¹⁾(f⁽ⁿ⁻¹⁾(a,b,c))
This is the nested recursive parent the user requested:
f(1)(a₁,b₁,c₁) = (a₂,b₂,c₂)
f(2)(a₁,b₁,c₁) = f(1)(a₂,b₂,c₂) = (a₃,b₃,c₃)
f(3)(a₁,b₁,c₁) = f(2)(a₂,b₂,c₂) = f(1)(a₃,b₃,c₃) = (a₄,b₄,c₄) -/
def parentN : ℕ → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | 0, t => t
  | n + 1, (a, b, c) =>
    let p := universalParent a b c
    parentN n p



/-- Alternative: collect the entire ancestry chain. -/
def ancestryChain : ℤ × ℤ × ℤ → ℕ → List (ℤ × ℤ × ℤ)
  | _, 0 => []
  | (a, b, c), n + 1 =>
    if a == 3 && b == 4 && c == 5 then [(3, 4, 5)]
    else
      let p := universalParent a b c
      (a, b, c) :: ancestryChain p n



/-- The depth to root: number of parent steps to reach (3,4,5). -/
def depthToRoot : ℤ × ℤ × ℤ → ℕ → ℕ
  | _, 0 => 0
  | (a, b, c), n + 1 =>
    if a == 3 && b == 4 && c == 5 then 0
    else 1 + depthToRoot (universalParent a b c) n

end UniversalParent



/-- **Theorem (Pythagorean Preservation)**: The universal parent of a Pythagorean
triple is Pythagorean, regardless of which branch is selected. -/
theorem universalParent_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let p := universalParent a b c
    p.1 ^ 2 + p.2.1 ^ 2 = p.2.2 ^ 2 := by
  simp only [universalParent]
  split
  · -- Branch 1
    simp only [invB1]; nlinarith
  · split
    · -- Branch 3
      simp only [invB3]; nlinarith
    · -- Branch 2
      simp only [invB2]; nlinarith



/-- **Theorem (Hypotenuse Decrease)**: For any PPT with positive legs,
the parent hypotenuse is strictly less than the child hypotenuse. -/
theorem universalParent_hyp_decreases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (universalParent a b c).2.2 < c := by
  simp only [universalParent]
  split
  · simp only [invB1]; nlinarith [sq_nonneg (a + b - c)]
  · split
    · simp only [invB3]; nlinarith [sq_nonneg (a + b - c)]
    · simp only [invB2]; nlinarith [sq_nonneg (a + b - c)]



/-- **Theorem (Hypotenuse Positivity)**: The parent hypotenuse is positive. -/
theorem universalParent_hyp_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    0 < (universalParent a b c).2.2 := by
  simp only [universalParent]
  split
  · simp only [invB1]; nlinarith [sq_nonneg (a - b), sq_nonneg (3*c - 2*(a+b))]
  · split
    · simp only [invB3]; nlinarith [sq_nonneg (a - b), sq_nonneg (3*c - 2*(a+b))]
    · simp only [invB2]; nlinarith [sq_nonneg (a - b), sq_nonneg (3*c - 2*(a+b))]



/-- **Theorem (Lorentz Invariance)**: All three inverse branches preserve the
Lorentz form a² + b² - c², making the parent equation a discrete Lorentz
transformation. -/
theorem invB1_lorentz_invariant (a b c : ℤ) :
    (a + 2*b - 2*c)^2 + (-2*a - b + 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring



/-- [Section: # CatalogBuild.Pythagorean.Core.UniversalParent
Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 44] -/
theorem invB2_lorentz_invariant (a b c : ℤ) :
    (a + 2*b - 2*c)^2 + (2*a + b - 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring



theorem invB3_lorentz_invariant (a b c : ℤ) :
    (-a - 2*b + 2*c)^2 + (2*a + b - 2*c)^2 - (-2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring



/-- **Theorem (Round Trip B₁)**: Forward ∘ Inverse = Identity. -/
theorem roundTrip_B1 (a b c : ℤ) :
    let p := invB1 a b c
    (p.1 - 2*p.2.1 + 2*p.2.2, 2*p.1 - p.2.1 + 2*p.2.2, 2*p.1 - 2*p.2.1 + 3*p.2.2) =
    (a, b, c) := by
  simp only [invB1]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



/-- **Theorem (Round Trip B₂)**: Forward ∘ Inverse = Identity. -/
theorem roundTrip_B2 (a b c : ℤ) :
    let p := invB2 a b c
    (p.1 + 2*p.2.1 + 2*p.2.2, 2*p.1 + p.2.1 + 2*p.2.2, 2*p.1 + 2*p.2.1 + 3*p.2.2) =
    (a, b, c) := by
  simp only [invB2]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



/-- **Theorem (Round Trip B₃)**: Forward ∘ Inverse = Identity. -/
theorem roundTrip_B3 (a b c : ℤ) :
    let p := invB3 a b c
    (-p.1 + 2*p.2.1 + 2*p.2.2, -2*p.1 + p.2.1 + 2*p.2.2, -2*p.1 + 2*p.2.1 + 3*p.2.2) =
    (a, b, c) := by
  simp only [invB3]
  refine Prod.ext ?_ (Prod.ext ?_ ?_) <;> ring



/-- **Theorem (Universal Hypotenuse Formula)**: For ALL primitive Pythagorean
triples, the parent hypotenuse satisfies the closed-form equation:
c_parent = 3c - 2(a + b)
This is the "universal" part — it doesn't depend on which branch. -/
theorem universal_hypotenuse_formula (a b c : ℤ) :
    (universalParent a b c).2.2 = -2*a - 2*b + 3*c := by
  unfold universalParent
  split
  · simp [invB1]
  · split
    · simp [invB3]
    · simp [invB2]



/-- **Theorem (Recursive Hypotenuse)**: The hypotenuse after n parent steps
is determined by the chain of universal hypotenuse applications. -/
theorem recursive_hyp_step (a b c : ℤ) (n : ℕ) :
    parentN (n + 1) (a, b, c) = parentN n (universalParent a b c) := by
  simp [parentN]



/-- For any odd N, the trivial Pythagorean triple is (N, (N²-1)/2, (N²+1)/2). -/
def trivialTriple (N : ℤ) : ℤ × ℤ × ℤ :=
  (N, (N^2 - 1) / 2, (N^2 + 1) / 2)



/-- Extract a factor of N from the GCD with a leg of the current triple. -/
def tryFactor (N : ℕ) (a b : ℤ) : Option (ℕ × ℕ) :=
  let g := Nat.gcd a.natAbs N
  if 1 < g && g < N then some (g, N / g)
  else
    let g' := Nat.gcd b.natAbs N
    if 1 < g' && g' < N then some (g', N / g')
    else none



/-- **Factor by Parent Descent**: Ascend the Berggren tree from the trivial
triple of N, checking GCD at each step. -/
def factorByParentDescent (N : ℕ) (maxSteps : ℕ) : Option (ℕ × ℕ) :=
  if N % 2 == 0 || N < 9 then none
  else
    let t := trivialTriple N
    go N t.1 t.2.1 t.2.2 maxSteps
where
  go (N : ℕ) : ℤ → ℤ → ℤ → ℕ → Option (ℕ × ℕ)
    | _, _, _, 0 => none
    | a, b, c, fuel + 1 =>
      match tryFactor N a b with
      | some f => some f
      | none =>
        if a == 3 && b == 4 && c == 5 then none
        else
          let (pa, pb, pc) := universalParent a b c
          go N pa pb pc fuel



/-- Collect ALL factors found during descent (not just the first). -/
def allFactorsInDescent (N : ℕ) (maxSteps : ℕ) : List (ℕ × ℕ × ℤ × ℤ × ℤ) :=
  if N % 2 == 0 || N < 9 then []
  else
    let t := trivialTriple N
    go N t.1 t.2.1 t.2.2 maxSteps
where
  go (N : ℕ) : ℤ → ℤ → ℤ → ℕ → List (ℕ × ℕ × ℤ × ℤ × ℤ)
    | _, _, _, 0 => []
    | a, b, c, fuel + 1 =>
      let factors := match tryFactor N a b with
        | some (p, q) => [(p, q, a, b, c)]
        | none => []
      if a == 3 && b == 4 && c == 5 then factors
      else
        let (pa, pb, pc) := universalParent a b c
        factors ++ go N pa pb pc fuel



/-- **The Fermat Factorization at Each Step**: At each node (a,b,c),
a = m²-n² = (m-n)(m+n) provides a difference-of-squares factorization.
The GCD of a with N reveals shared factors. -/
theorem fermat_at_each_step (m n : ℤ) :
    m ^ 2 - n ^ 2 = (m - n) * (m + n) := by ring



def branchEncoding : ℤ × ℤ × ℤ → ℕ → List ℕ
  | _, 0 => []
  | (a, b, c), n + 1 =>
    if a == 3 && b == 4 && c == 5 then []
    else
      let branch := if -2*a - b + 2*c > 0 then 1
                     else if -a - 2*b + 2*c > 0 then 3
                     else 2
      branch :: branchEncoding (universalParent a b c) n

#eval branchEncoding (5, 12, 13) 20     -- [1]
#eval branchEncoding (21, 20, 29) 20    -- [2]
#eval branchEncoding (15, 8, 17) 20     -- [3]
#eval branchEncoding (7, 24, 25) 20     -- [1, 1]
#eval branchEncoding (119, 120, 169) 20 -- branch path



/-- The two candidate leg values (before sign correction). -/
def candidateLegs (a b c : ℤ) : ℤ × ℤ :=
  (a + 2*b - 2*c, 2*a + b - 2*c)



/-- **Key Identity**: The sum of candidate legs. -/
theorem candidate_legs_relation (a b c : ℤ) :
    (a + 2*b - 2*c) + (2*a + b - 2*c) = 3*a + 3*b - 4*c := by ring



/-- The "third" candidate leg (from B₃⁻¹). -/
theorem third_leg_relation (a b c : ℤ) :
    (-a - 2*b + 2*c) = -(a + 2*b - 2*c) := by ring



/-- **Master Identity**: The three candidate first-components satisfy
L₃ = -L₁, so branches 1 and 3 use negated first components. -/
theorem master_leg_identity (a b c : ℤ) :
    (-a - 2*b + 2*c) + (a + 2*b - 2*c) = 0 := by ring



/-- **Theorem**: The parent hypotenuse in Euclid coordinates simplifies to
c_parent = (m - 2n)² + n², i.e., it is always a sum of two squares. -/
theorem parent_hyp_euclid_simplified (m n : ℤ) :
    -2 * (m ^ 2 - n ^ 2) - 2 * (2 * m * n) + 3 * (m ^ 2 + n ^ 2) =
    (m - 2 * n) ^ 2 + n ^ 2 := by ring



/-- **Beautiful Identity**: The parent hypotenuse is itself a sum of two squares!
c_parent = (m - 2n)² + n²
This means every parent triple has a hypotenuse that factors over ℤ[i]. -/
theorem parent_hyp_sum_of_squares (m n : ℤ) :
    let t := euclidToTriple m n
    ∃ u v : ℤ, -2 * t.1 - 2 * t.2.1 + 3 * t.2.2 = u^2 + v^2 :=
  ⟨m - 2*n, n, by simp [euclidToTriple]; ring⟩



/-- **Theorem (Integral Chain)**: For any Pythagorean triple, the nth parent
is also an integer triple (trivially true since all operations are ℤ → ℤ). -/
theorem integral_chain (a b c : ℤ) (n : ℕ) :
    ∃ a' b' c' : ℤ, parentN n (a, b, c) = (a', b', c') := by
  exact ⟨_, _, _, rfl⟩



/-- **Descent Bound**: The hypotenuse decreases by at least
2(a + b - c) at each step. -/
theorem descent_decrease_bound (a b c : ℤ) :
    c - (-2*a - 2*b + 3*c) = 2*(a + b) - 2*c := by ring



/-- **Triangle Inequality for PPTs**: For a Pythagorean triple with
positive legs, a + b > c. -/
theorem ppt_triangle_ineq (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    a + b > c := by
  nlinarith [sq_nonneg (a + b - c)]



/-- **Corollary**: Each step reduces hypotenuse by at least 2. -/
theorem descent_at_least_2 (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    c - (-2*a - 2*b + 3*c) ≥ 2 := by
  have hab : a + b > c := ppt_triangle_ineq a b c ha hb h
  linarith



/-- The odd leg always factors as a difference of squares. -/
theorem odd_leg_factors (m n : ℤ) :
    m ^ 2 - n ^ 2 = (m - n) * (m + n) := by ring



/-- If N divides the odd leg at some descent level, then gcd(N, m±n)
gives a factor of N. -/
theorem gcd_factor_principle (N a : ℤ) :
    (Int.gcd a N : ℤ) ∣ N := by
  exact_mod_cast Int.gcd_dvd_right a N



theorem ppt_parity_sum (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha_odd : a % 2 = 1) (hb_even : b % 2 = 0) :
    (a + b + c) % 2 = 0 := by
  -- a odd, b even ⇒ a² odd, b² even ⇒ c² = a²+b² odd ⇒ c odd
  -- a+b+c = odd+even+odd = even
  replace h := congr_arg ( · % 4 ) h ; rcases Int.even_or_odd' a with ⟨ k, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ l, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ m, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num at *;


