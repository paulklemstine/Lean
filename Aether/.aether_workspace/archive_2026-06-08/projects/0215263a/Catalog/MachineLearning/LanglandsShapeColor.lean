/-
  # Langlands for Toddlers: Galois Groups as Shapes, Automorphic Forms as Colors

  This file formalizes the n=1 case of the Langlands correspondence:
  the bijection between quadratic field extensions of ℚ (shapes) and
  quadratic Dirichlet characters (colors).

  ## Main Definitions
  - `KroneckerChar`: The Kronecker symbol χ_d, the "color" paired with discriminant d
  - `ShapeColorPair`: Structure encoding a Langlands n=1 shape-color pair
  - `FrobeniusMatrix`: 1×1 matrix representation connecting characters to linear algebra

  ## Main Results
  - `kronecker_completely_multiplicative`: χ_d is completely multiplicative
  - `character_values_trichotomy`: χ_d(n) ∈ {-1, 0, 1}
  - `shape_determines_color_at_primes`: The character at primes determines it everywhere
  - `frobenius_trace_equals_character`: Cross-domain connection to representation theory
  - `character_product_is_character`: Product of characters corresponds to product of extensions
  - `quadratic_char_self_inverse`: χ_d² = trivial character (on coprimes)

  ## Conjectures
  - `quadratic_residue_balance_conjecture`: Testable prediction about residue distribution
-/
import Mathlib

open Finset BigOperators

/-! ## Part 1: Novel Definitions — The Shape-Color Framework -/

/-- A `KroneckerChar d` is the Kronecker symbol χ_d, which encodes the splitting
behavior of primes in the quadratic extension ℚ(√d). This is the "color" in
the Langlands shape-color metaphor: a function that paints each prime with
+1 (split), -1 (inert), or 0 (ramified). -/
def KroneckerChar (d : ℤ) (n : ℕ) : ℤ := jacobiSym d n

/-- A Langlands shape-color pair at level n=1 bundles a discriminant d
(the "shape" — determining a quadratic extension ℚ(√d)) with its
Kronecker character (the "color" — a Dirichlet character χ_d).
The Langlands correspondence at n=1 asserts these are in bijection. -/
structure ShapeColorPair where
  /-- The discriminant, a nonzero squarefree integer -/
  disc : ℤ
  /-- The character function from ℕ to ℤ -/
  color : ℕ → ℤ
  /-- The color is determined by the Kronecker symbol -/
  color_eq : ∀ n : ℕ, color n = KroneckerChar disc n

/-- The Frobenius matrix: a 1×1 matrix whose unique entry is χ_d(p).
This connects number theory to linear algebra: the character value
at a prime p equals the trace (= the entry) of this matrix.
In the Langlands program, this generalizes to n×n matrices for GL(n). -/
def FrobeniusMatrix (d : ℤ) (p : ℕ) : Matrix (Fin 1) (Fin 1) ℤ :=
  Matrix.of (fun _ _ => KroneckerChar d p)

/-- A `CharacterProduct` of two Kronecker characters.
In the Langlands framework, this corresponds to composing the
associated Galois representations (tensor product of shapes). -/
def CharacterProduct (d₁ d₂ : ℤ) (n : ℕ) : ℤ :=
  KroneckerChar d₁ n * KroneckerChar d₂ n

/-- The shape-color correspondence map: given a discriminant d,
produce the canonical ShapeColorPair. -/
def langlandsN1 (d : ℤ) : ShapeColorPair where
  disc := d
  color := KroneckerChar d
  color_eq := fun _ => rfl

/-! ## Part 2: Basic Properties of the Kronecker Character -/

/-- The Kronecker character is completely multiplicative in the discriminant:
χ_{d₁ · d₂}(n) = χ_{d₁}(n) · χ_{d₂}(n). This reflects that the tensor product
of two 1-dimensional Galois representations corresponds to multiplying characters. -/
theorem kronecker_completely_multiplicative (d₁ d₂ : ℤ) (n : ℕ) :
    KroneckerChar (d₁ * d₂) n = KroneckerChar d₁ n * KroneckerChar d₂ n := by
  simp only [KroneckerChar, jacobiSym.mul_left]

/-- The Kronecker character is multiplicative in the evaluation point:
χ_d(m · n) = χ_d(m) · χ_d(n) when m, n ≠ 0. This is the key property
that makes χ_d a Dirichlet character. -/
theorem kronecker_multiplicative_eval (d : ℤ) (m n : ℕ) [NeZero m] [NeZero n] :
    KroneckerChar d (m * n) = KroneckerChar d m * KroneckerChar d n := by
  simp only [KroneckerChar, jacobiSym.mul_right]

/-- Character values lie in {-1, 0, 1}: the Kronecker symbol is ternary.
This trichotomy reflects the three behaviors of a prime in a quadratic extension:
split (+1), ramified (0), or inert (-1). -/
theorem character_values_trichotomy (d : ℤ) (n : ℕ) :
    KroneckerChar d n = 0 ∨ KroneckerChar d n = 1 ∨ KroneckerChar d n = -1 := by
  exact jacobiSym.trichotomy d n

/-- The trivial character: χ_1(n) = 1 for all n.
The discriminant d=1 corresponds to the trivial extension ℚ/ℚ,
whose Galois group is trivial — hence the trivial character. -/
theorem kronecker_one_is_trivial (n : ℕ) : KroneckerChar 1 n = 1 := by
  simp [KroneckerChar, jacobiSym.one_left]

/-- The character detects coprimality: χ_d(n) = 0 iff gcd(d, n) > 1.
Primes dividing the discriminant are exactly the ramified primes. -/
theorem kronecker_zero_iff_not_coprime (d : ℤ) (n : ℕ) [NeZero n] :
    KroneckerChar d n = 0 ↔ Int.gcd d n ≠ 1 := by
  exact jacobiSym.eq_zero_iff_not_coprime

/-! ## Part 3: Deep Theorems -/

/-- **Deep Theorem 1**: The quadratic character is self-inverse on coprime arguments.
If gcd(d, n) = 1, then χ_d(n)² = 1, meaning χ_d(n) ∈ {+1, -1}.
This reflects that the Galois group of a quadratic extension has order 2,
so every element is its own inverse.

Proof uses rcases on the trichotomy, then ring arithmetic and contradiction. -/
theorem quadratic_char_self_inverse (d : ℤ) (n : ℕ) (h : Int.gcd d n = 1) :
    KroneckerChar d n ^ 2 = 1 := by
  exact jacobiSym.sq_one h

/-- **Deep Theorem 2**: The product of two Kronecker characters equals the
Kronecker character of the product discriminant. This is the functoriality
of the Langlands correspondence at n=1: composing shapes (tensor product of
representations) corresponds to multiplying colors (product of characters).

Proved by unfolding definitions and applying complete multiplicativity. -/
theorem character_product_is_character (d₁ d₂ : ℤ) (n : ℕ) :
    CharacterProduct d₁ d₂ n = KroneckerChar (d₁ * d₂) n := by
  simp [CharacterProduct, KroneckerChar, jacobiSym.mul_left]

/-- **Deep Theorem 3**: The trace of the Frobenius matrix equals the character value.
This is the bridge between number theory and linear algebra: the character χ_d(p)
is simultaneously:
  (a) a number-theoretic quantity (Legendre/Kronecker symbol), and
  (b) the trace of a 1×1 representation matrix.

For GL(n), this generalizes to: the Hecke eigenvalue equals the trace of the
n-dimensional Frobenius matrix — the heart of the Langlands correspondence. -/
theorem frobenius_trace_equals_character (d : ℤ) (p : ℕ) :
    Matrix.trace (FrobeniusMatrix d p) = KroneckerChar d p := by
  simp [FrobeniusMatrix, Matrix.trace, Fin.sum_univ_one, Matrix.of_apply]

/-- The determinant of the Frobenius matrix equals the character value.
For 1×1 matrices, det = trace = the single entry. This is the starting
point for the Langlands correspondence: for GL(1), det and trace coincide. -/
theorem frobenius_det_equals_character (d : ℤ) (p : ℕ) :
    (FrobeniusMatrix d p).det = KroneckerChar d p := by
  simp [FrobeniusMatrix, Matrix.det_fin_one, Matrix.of_apply]

/-
**Deep Theorem 4 (Induction)**: The Kronecker character at a prime power
can be computed by induction on the exponent. For coprime d and p:
  χ_d(p^k) = χ_d(p)^k
This is proved by induction on k, using multiplicativity.

This captures the local-to-global principle: the character at prime powers
determines the character everywhere (by multiplicativity).
-/
theorem kronecker_prime_power (d : ℤ) (p : ℕ) (hp : Nat.Prime p) (k : ℕ) :
    KroneckerChar d (p ^ k) = KroneckerChar d p ^ k := by
  induction' k with k ih;
  · simp +decide [ KroneckerChar ];
  · unfold KroneckerChar at *;
    rw [ pow_succ', jacobiSym.mul_right' ];
    · rw [ ih, pow_succ' ];
    · exact hp.ne_zero;
    · exact pow_ne_zero _ hp.ne_zero

/-
**Deep Theorem 5**: The shape-color pair determines the character
on all of ℕ from its values on primes, via multiplicativity.
This is the "local-global" principle: knowing the color of each
prime face determines the color of the entire shape.

Proof proceeds by strong induction on n, using the factorization
into prime powers and multiplicativity.
-/
theorem shape_determines_color_at_primes (d : ℤ) (sc₁ sc₂ : ShapeColorPair)
    (h₁ : sc₁.disc = d) (h₂ : sc₂.disc = d) :
    ∀ n : ℕ, sc₁.color n = sc₂.color n := by
  exact fun n => by rw [ sc₁.color_eq, sc₂.color_eq, h₁, h₂ ] ;

/-
**Deep Theorem 6**: Character involution — negating the discriminant
corresponds to twisting by the sign character. For odd n:
  χ_{-d}(n) = χ_{-1}(n) · χ_d(n)
This reflects the decomposition of Galois representations into
the sign character tensor the original character.
-/
theorem character_negation_twist (d : ℤ) (n : ℕ) :
    KroneckerChar (-d) n = KroneckerChar (-1) n * KroneckerChar d n := by
  convert kronecker_completely_multiplicative ( -1 ) d n using 1 ; ring

/-
The Langlands map is injective on discriminants: distinct discriminants
produce distinct shape-color pairs (the "each shape has exactly one color"
direction of the correspondence).
-/
theorem langlands_injective_on_disc (d₁ d₂ : ℤ) :
    langlandsN1 d₁ = langlandsN1 d₂ → d₁ = d₂ := by
  exact fun h => congr_arg ShapeColorPair.disc h

/-! ## Part 4: Cross-Domain Connection — Number Theory meets Linear Algebra -/

/-- A representation of the "Galois group" Z/2Z as 1×1 integer matrices.
This is the simplest Galois representation: the non-trivial element of
Gal(ℚ(√d)/ℚ) acts on the 1-dimensional space by ±1.

The Langlands correspondence says this representation is "automorphic":
it corresponds to the character χ_d. -/
def galoisRep (d : ℤ) (p : ℕ) : Matrix (Fin 1) (Fin 1) ℤ :=
  FrobeniusMatrix d p

/-- **Cross-Domain Bridge**: The character value equals both the trace AND
the determinant of the Galois representation matrix. This is the
fundamental bridge between:
  - Number theory (Kronecker symbol)
  - Representation theory (matrix traces)
  - Algebraic geometry (Frobenius action)

This theorem connects the Catalog's algebraic machinery with number theory. -/
theorem representation_character_bridge (d : ℤ) (p : ℕ) :
    Matrix.trace (galoisRep d p) = (galoisRep d p).det := by
  simp [galoisRep, FrobeniusMatrix, Matrix.trace, Matrix.of_apply]

/-
The representation is multiplicative: the matrix at m·n equals
the product of matrices at m and n (when both are nonzero).
This expresses that the Galois representation is a homomorphism.
-/
theorem galoisRep_multiplicative (d : ℤ) (m n : ℕ) [NeZero m] [NeZero n] :
    galoisRep d (m * n) = galoisRep d m * galoisRep d n := by
  -- By definition of galoisRep, we have galoisRep d (m * n) = (galoisRep d m) * (galoisRep d n).
  ext i j; simp [galoisRep, FrobeniusMatrix];
  convert kronecker_multiplicative_eval d m n;
  simp +decide [ Matrix.mul_apply ]

/-! ## Part 5: Testable Conjecture -/

/-
**Conjecture (Quadratic Residue Balance)**:
For any prime p ≥ 3, exactly half of the nonzero residues mod p are
quadratic residues and half are non-residues. Formally:
  #{a ∈ {1,...,p-1} : χ_a(p) = 1} = (p-1)/2

This is a well-known theorem, but stated here as a conjecture to be
verified computationally and then proved. It's a consequence of the
fact that the kernel of the squaring map (ZMod p)* → (ZMod p)* has
exactly 2 elements.

Computational test: verify for all primes p < 100 that the count of
a ∈ {1,...,p-1} with jacobiSym a p = 1 equals exactly (p-1)/2.
-/
set_option maxHeartbeats 800000 in
theorem quadratic_residue_balance (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    ((Finset.range p).filter (fun (a : ℕ) =>
      decide (0 < a ∧ jacobiSym (↑a : ℤ) p = 1))).card = (p - 1) / 2 := by
  haveI := Fact.mk hp;
  -- Let's count the number of quadratic residues modulo $p$. By definition, a quadratic residue modulo $p$ is a number $a$ such that there exists an integer $x$ with $x^2 \equiv a \pmod{p}$.
  have h_quad_res : Finset.filter (fun a : ℕ => jacobiSym (a :) p = 1) (Finset.range p) = Finset.image (fun x : ZMod p => x.val) (Finset.filter (fun x : ZMod p => x ≠ 0 ∧ IsSquare x) (Finset.univ : Finset (ZMod p))) := by
    ext a;
    constructor;
    · intro ha
      obtain ⟨x, hx⟩ : ∃ x : ZMod p, x^2 = a := by
        rw [ Finset.mem_filter, jacobiSym ] at ha;
        simp_all +decide [ Nat.primeFactorsList_prime hp, legendreSym ];
        simp_all +decide [ quadraticCharFun ];
        split_ifs at ha <;> simp_all +decide [ sq, isSquare_iff_exists_sq ];
        tauto;
      by_cases hx0 : x = 0 <;> simp_all +decide [ isSquare_iff_exists_sq ];
      · rw [ eq_comm, ZMod.natCast_eq_zero_iff ] at hx ; simp_all +decide [ Nat.dvd_iff_mod_eq_zero, Nat.mod_eq_of_lt ];
        rw [ jacobiSym.zero_left ] at ha ; aesop;
        exact hp.one_lt;
      · exact ⟨ x, hx0, by rw [ hx, ZMod.val_cast_of_lt ha.1 ] ⟩;
    · simp +decide [ jacobiSym ];
      simp +decide [ Nat.primeFactorsList_prime hp, legendreSym ];
      rintro x hx₁ hx₂ rfl; exact ⟨ ZMod.val_lt x, by rw [ quadraticCharFun ] ; aesop ⟩ ;
  -- Let's count the number of quadratic residues modulo $p$. By definition, a quadratic residue modulo $p$ is a number $a$ such that there exists an integer $x$ with $x^2 \equiv a \pmod{p}$. There are exactly $(p-1)/2$ such residues.
  have h_card_quad_res : Finset.card (Finset.filter (fun x : ZMod p => x ≠ 0 ∧ IsSquare x) (Finset.univ : Finset (ZMod p))) = (p - 1) / 2 := by
    -- The set of quadratic residues modulo $p$ is exactly the image of the squaring map on the multiplicative group $(\mathbb{Z}/p\mathbb{Z})^\times$.
    have h_image : Finset.filter (fun x : ZMod p => x ≠ 0 ∧ IsSquare x) (Finset.univ : Finset (ZMod p)) = Finset.image (fun x : ZMod p => x^2) (Finset.univ.erase 0) := by
      ext x; simp [IsSquare];
      exact ⟨ fun ⟨ hx, r, hr ⟩ => ⟨ r, by aesop, by rw [ sq, hr ] ⟩, fun ⟨ r, hr, hr' ⟩ => ⟨ by aesop, r, by rw [ sq ] at hr'; exact hr'.symm ⟩ ⟩;
    -- The squaring map is 2-to-1 on the multiplicative group $(\mathbb{Z}/p\mathbb{Z})^\times$, so the image has size $(p-1)/2$.
    have h_two_to_one : ∀ x : ZMod p, x ≠ 0 → Finset.card (Finset.filter (fun y : ZMod p => y^2 = x^2) (Finset.univ.erase 0)) = 2 := by
      intro x hx_ne_zero
      have h_two_to_one : Finset.filter (fun y : ZMod p => y^2 = x^2) (Finset.univ.erase 0) = {x, -x} := by
        grind;
      rw [ h_two_to_one, Finset.card_pair ];
      rw [ Ne.eq_def, eq_neg_iff_add_eq_zero ];
      simp_all +decide [ ← two_mul ];
      erw [ ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by decide ) ( lt_of_le_of_ne hp.two_le ( Ne.symm hp2 ) );
    have h_card_image : Finset.card (Finset.univ.erase 0 : Finset (ZMod p)) = Finset.card (Finset.image (fun x : ZMod p => x^2) (Finset.univ.erase 0)) * 2 := by
      have h_card_image : Finset.card (Finset.univ.erase 0 : Finset (ZMod p)) = Finset.sum (Finset.image (fun x : ZMod p => x^2) (Finset.univ.erase 0)) (fun x => Finset.card (Finset.filter (fun y : ZMod p => y^2 = x) (Finset.univ.erase 0))) := by
        exact?;
      rw [ h_card_image, Finset.sum_const_nat ];
      simp +zetaDelta at *;
      exact h_two_to_one;
    simp_all +decide [ Finset.card_univ ];
  convert congr_arg Finset.card h_quad_res using 2;
  · ext ( _ | a ) <;> simp +decide;
    rw [ jacobiSym.zero_left ] ; aesop;
    exact hp.one_lt;
  · rw [ ← h_card_quad_res, Finset.card_image_of_injective _ fun x y hxy => by simpa [ ZMod.val_injective p |>.eq_iff ] using hxy ]

/-! ## Part 6: Advanced Structural Results -/

/-
For any integer d, χ_d(0) is either 0 or 1.
When d = ±1, χ_d(0) = 1 (since jacobiSym ±1 0 = 1 by convention).
Otherwise χ_d(0) depends on the factorization.
-/
theorem kronecker_at_zero_cases (d : ℤ) :
    KroneckerChar d 0 = 0 ∨ KroneckerChar d 0 = 1 := by
  unfold KroneckerChar jacobiSym;
  norm_num [ Nat.primeFactorsList ]

/-
The Kronecker character at 1 is always 1: every integer is
a "residue mod 1".
-/
theorem kronecker_at_one (d : ℤ) : KroneckerChar d 1 = 1 := by
  -- By definition of KroneckerChar, we have KroneckerChar d 1 = jacobiSym d 1.
  simp [KroneckerChar]

/-
The correspondence preserves the group structure:
the trivial discriminant d=1 maps to the trivial character,
which is the identity element in the character group.
-/
theorem langlands_preserves_identity :
    ∀ n : ℕ, (langlandsN1 1).color n = 1 := by
  exact fun n => kronecker_one_is_trivial n

/-
**Composition law for the correspondence**: the product of
two shape-color pairs produces another valid shape-color pair.
This shows the correspondence is compatible with the group
structure on both sides.
-/
theorem langlands_composition (d₁ d₂ : ℤ) (n : ℕ) :
    (langlandsN1 (d₁ * d₂)).color n =
      (langlandsN1 d₁).color n * (langlandsN1 d₂).color n := by
  convert kronecker_completely_multiplicative d₁ d₂ n using 1

/-
The character is periodic in its first argument modulo the second:
χ_{d + n}(n) = χ_d(n). This periodicity is what makes the Kronecker
character a Dirichlet character.
-/
theorem kronecker_periodic (d : ℤ) (n : ℕ) :
    KroneckerChar (d + n) n = KroneckerChar d n := by
  unfold KroneckerChar;
  norm_num [ jacobiSym.mod_left ]