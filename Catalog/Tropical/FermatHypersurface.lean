/-
  # Tropical Fermat Hypersurface: Exponent Invariance, Primitive Abundance, and Transfer Obstruction

  This file formalizes a package of theorems about the tropical analogue of Fermat's equation.
  In the min-plus semiring, the tropical Fermat polynomial F_n(x,y,z) = min(nx, ny, nz) defines
  a tropical hypersurface — the locus where the minimum is attained at least twice.

  We prove:
  - **Theorem A**: The tropical zero set is independent of the exponent n (for n ≥ 1).
  - **Theorem B**: The tropical Fermat hypersurface contains infinitely many primitive lattice points.
  - **Theorem C**: The tropical condition is scale-invariant, demonstrating information loss
    that obstructs any naive transfer to classical FLT.
  - **Stretch Theorem**: Equal-degree collapse generalizes across exponents.
-/
import Mathlib

/-- The tropical Fermat polynomial F_n(x,y,z) = min(n*x, min(n*y, n*z)). -/
def tropFermat (n : ℕ) (p : ℤ × ℤ × ℤ) : ℤ :=
  let x := p.1
  let y := p.2.1
  let z := p.2.2
  min (n * x) (min (n * y) (n * z))

/-- The tropical vanishing locus: the minimum among n*x, n*y, n*z is attained at least twice. -/
def TropZero (n : ℕ) (p : ℤ × ℤ × ℤ) : Prop :=
  let x := p.1
  let y := p.2.1
  let z := p.2.2
  ((n * x = n * y ∧ n * x ≤ n * z) ∨
   (n * x = n * z ∧ n * x ≤ n * y) ∨
   (n * y = n * z ∧ n * y ≤ n * x))

/-- A pair (a, b) of natural numbers is primitive if gcd(a, b) = 1. -/
def PrimitivePair (a b : ℕ) : Prop := Nat.Coprime a b

/-! ## Theorem A: Tropical Fermat hypersurface is exponent-invariant

The tropical zero set TropZero(F_n) equals the set of (x,y,z) where at least two coordinates
are equal and minimal. Since multiplying by a positive integer n preserves equality and order,
the zero set is independent of n. -/

/-
**Theorem A.** For n ≥ 1, the tropical Fermat zero set is characterized by pairwise
equality of coordinates at the minimum, independent of n.
-/
theorem tropFermat_zero_iff
    {n : ℕ} (hn : 0 < n) (p : ℤ × ℤ × ℤ) :
    TropZero n p ↔
      (let x := p.1; let y := p.2.1; let z := p.2.2
       (x = y ∧ x ≤ z) ∨ (x = z ∧ x ≤ y) ∨ (y = z ∧ y ≤ x)) := by
  unfold TropZero;
  aesop

/-! ## Theorem B: Infinitely many primitive lattice points

The family (m, m, m+1) for m ≥ N gives primitive points on the tropical Fermat hypersurface,
since gcd(m, m+1) = 1 and m ≤ m+1. -/

/-
**Theorem B.** For every n ≥ 1, there exist infinitely many primitive lattice points
on the tropical Fermat hypersurface.
-/
theorem tropFermat_has_infinite_primitive_points
    {n : ℕ} (_hn : 0 < n) :
    ∀ N : ℕ, ∃ a b : ℕ,
      N ≤ a ∧ a ≤ b ∧ PrimitivePair a b ∧
      TropZero n ((a : ℤ), ((a : ℤ), (b : ℤ))) := by
  intro N
  use N + 1, N + 2
  constructor
  · linarith
  · constructor
    · linarith
    · constructor
      · exact Nat.Coprime.gcd_eq_one (by
        norm_num [ ( by ring : N + 2 = N + 1 + 1 ) ])
      · use Or.inl ⟨by
        rfl, by
          grind⟩

/-! ## Theorem C: Scale invariance and transfer obstruction

The tropical zero condition is invariant under positive scaling of coordinates,
demonstrating that tropical geometry loses the arithmetic information needed
for classical FLT. -/

/-- The valuation shadow (identity map, representing that tropicalization
projects to valuations). -/
def ValuationShadow (p : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ := p

/-
**Theorem C1.** The tropical zero condition is invariant under positive scaling.
-/
theorem tropFermat_shadow_scale_invariant
    {n k : ℕ} (hn : 0 < n) (hk : 0 < k) (p : ℤ × ℤ × ℤ) :
    TropZero n p ↔ TropZero n
      (k * p.1, (k * p.2.1, k * p.2.2)) := by
  constructor <;> simp_all +decide [ TropZero ];
  · aesop;
  · grind

/-
**Theorem C2 (corrected).** Scaling produces infinitely many distinct points in TropZero
that are tropically indistinguishable (they lie on the same wall of the hyperplane arrangement).
This formalizes information loss: the tropical shadow cannot distinguish a primitive
solution from any of its positive multiples.
-/
theorem tropical_scaling_produces_distinct_points
    {n : ℕ} (hn : 0 < n) (p : ℤ × ℤ × ℤ) (hp : TropZero n p)
    (hp1 : p.1 ≠ 0 ∨ p.2.1 ≠ 0 ∨ p.2.2 ≠ 0) :
    ∀ N : ℕ, ∃ q : ℤ × ℤ × ℤ, q ≠ p ∧ TropZero n q ∧
      ∃ k : ℕ, N ≤ k ∧ q = (k * p.1, (k * p.2.1, k * p.2.2)) := by
  -- For any natural number N, we can choose k = max N 2. This ensures that k ≥ N and k ≥ 2.
  intro N
  use (max N 2 * p.1, max N 2 * p.2.1, max N 2 * p.2.2);
  refine' ⟨ _, _, max N 2, le_max_left _ _, rfl ⟩;
  · contrapose! hp1;
    rcases p with ⟨ x, y, z ⟩ ; simp_all +decide [ mul_eq_zero ];
    exact ⟨ by nlinarith [ le_max_right ( N : ℤ ) 2 ], by nlinarith [ le_max_right ( N : ℤ ) 2 ], by nlinarith [ le_max_right ( N : ℤ ) 2 ] ⟩;
  · have := tropFermat_shadow_scale_invariant hn ( by positivity : 0 < ( max N 2 : ℕ ) ) p; aesop;

/-
**Theorem C3.** The tropical zero set is infinite: for every finite bound,
there exist more tropical zero points beyond it. This is the core
obstruction to using tropical vanishing for finiteness results like FLT.
-/
theorem tropical_zero_set_infinite
    {n : ℕ} (hn : 0 < n) :
    ∀ N : ℕ, ∃ S : Finset (ℤ × ℤ × ℤ),
      N ≤ S.card ∧ ∀ p ∈ S, TropZero n p := by
  intro N
  use Finset.image (fun i : ℕ => (i, i, i + 1)) (Finset.range N);
  simp +decide [ TropZero ];
  exact ⟨ by rw [ Finset.card_image_of_injective _ fun x y hxy => by simpa using hxy ] ; simp +decide, fun a ha => Or.inl <| by nlinarith ⟩

/-! ## Stretch Theorem: Universal equal-degree collapse

The tropical zero set is identical for all positive exponents, establishing
that equal-degree tropicalization erases all arithmetic complexity. -/

/-
**Stretch Theorem.** The tropical Fermat zero set is the same for any two positive exponents.
-/
theorem trop_equal_degree_scale_invariant
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m) :
    ∀ p : ℤ × ℤ × ℤ,
      TropZero n p ↔ TropZero m p := by
  exact fun p => by rw [ tropFermat_zero_iff hn p, tropFermat_zero_iff hm p ] ;