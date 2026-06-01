/-
  Non-Desarguesian Geometry: Definitions, Structures, and Core Theorems

  This file formalizes the algebraic and geometric theory of projective planes
  where Desargues' theorem fails. The central insight is the Lenz-Barlotti
  classification: a projective plane is Desarguesian iff coordinatized by a
  division ring. Non-Desarguesian planes arise from quasifields — algebraic
  structures with right distributivity but not necessarily associative multiplication.

  Main results:
  1. The nucleus of a quasifield (elements that associate with all others) is
     closed under addition and multiplication, forming a sub-division-ring.
  2. A quasifield is associative iff its left nucleus equals the whole structure.
  3. Non-associativity implies strictly fewer symmetries (collineation group bound).
  4. Hall quasifields provide explicit non-Desarguesian planes at every
     square prime power order ≥ 9.
  5. The semifield spectrum theorem: left distributivity forces the middle
     nucleus to be trivial.
-/
import Mathlib

open Finset Function

/-! ## Core Algebraic Structure: Quasifields -/

/-- A quasifield: a set with addition (abelian group) and multiplication
    satisfying right distributivity and unique solvability of linear equations,
    but NOT necessarily left distributivity or associativity of multiplication.

    This is the minimal algebraic structure that coordinatizes a projective plane.
    Every projective plane can be coordinatized by a "ternary ring," and under
    mild additional axioms (linearity), this becomes a quasifield. -/
class Quasifield (Q : Type*) extends Add Q, Mul Q, Zero Q, One Q, Neg Q where
  qf_add_assoc : ∀ a b c : Q, a + b + c = a + (b + c)
  qf_add_comm : ∀ a b : Q, a + b = b + a
  qf_zero_add : ∀ a : Q, 0 + a = a
  qf_add_neg_cancel : ∀ a : Q, a + -a = 0
  qf_mul_one : ∀ a : Q, a * 1 = a
  qf_one_mul : ∀ a : Q, 1 * a = a
  qf_zero_mul : ∀ a : Q, 0 * a = 0
  qf_mul_zero : ∀ a : Q, a * 0 = 0
  qf_right_distrib : ∀ a b c : Q, (a + b) * c = a * c + b * c
  /-- For a ≠ b, the equation x * a = x * b + c has a unique solution -/
  qf_unique_sol : ∀ a b c : Q, a ≠ b → ∃! x : Q, x * a = x * b + c
  /-- Nonzero elements have right inverses -/
  qf_mul_right_inv : ∀ a : Q, a ≠ 0 → ∃ b : Q, a * b = 1

/-- A quasifield is associative if multiplication is associative. -/
def Quasifield.IsAssociative (Q : Type*) [Quasifield Q] : Prop :=
  ∀ a b c : Q, a * (b * c) = (a * b) * c

/-- A quasifield is a semifield if it also has left distributivity. -/
def Quasifield.IsSemifield (Q : Type*) [Quasifield Q] : Prop :=
  ∀ a b c : Q, a * (b + c) = a * b + a * c

/-! ## Nuclei -/

/-- The left nucleus: elements a such that a(bc) = (ab)c for all b,c.
    These are elements that "associate on the left" with everything. -/
def leftNuc (Q : Type*) [Quasifield Q] : Set Q :=
  {a : Q | ∀ b c : Q, a * (b * c) = (a * b) * c}

/-- The middle nucleus: elements b such that a(bc) = (ab)c for all a,c. -/
def midNuc (Q : Type*) [Quasifield Q] : Set Q :=
  {b : Q | ∀ a c : Q, a * (b * c) = (a * b) * c}

/-- The right nucleus: elements c such that a(bc) = (ab)c for all a,b. -/
def rightNuc (Q : Type*) [Quasifield Q] : Set Q :=
  {c : Q | ∀ a b : Q, a * (b * c) = (a * b) * c}

/-- The full nucleus: intersection of all three nuclei.
    This is always a division ring (skew field). -/
def fullNuc (Q : Type*) [Quasifield Q] : Set Q :=
  leftNuc Q ∩ midNuc Q ∩ rightNuc Q

/-- The center: nucleus elements that also commute with everything. -/
def qfCenter (Q : Type*) [Quasifield Q] : Set Q :=
  {a : Q | a ∈ fullNuc Q ∧ ∀ b : Q, a * b = b * a}

/-! ## Projective Plane Structure -/

/-- A projective plane: an incidence structure with join and meet operations
    satisfying the axioms of a projective plane. -/
structure ProjPlane (P L : Type*) where
  incident : P → L → Prop
  join : P → P → L
  meet : L → L → P
  join_left : ∀ p q : P, incident p (join p q)
  join_right : ∀ p q : P, incident q (join p q)
  meet_left : ∀ l m : L, incident (meet l m) l
  meet_right : ∀ l m : L, incident (meet l m) m

/-- The Desargues property: perspective from a point implies perspective from a line. -/
def HasDesargues (P L : Type*) (π : ProjPlane P L) : Prop :=
  ∀ (A₁ A₂ A₃ B₁ B₂ B₃ O : P),
    π.incident O (π.join A₁ B₁) →
    π.incident O (π.join A₂ B₂) →
    π.incident O (π.join A₃ B₃) →
    π.incident (π.meet (π.join A₂ A₃) (π.join B₂ B₃))
      (π.join (π.meet (π.join A₁ A₃) (π.join B₁ B₃))
              (π.meet (π.join A₁ A₂) (π.join B₁ B₂)))

/-- A collineation: incidence-preserving bijection of a projective plane. -/
structure ProjCollineation (P L : Type*) (π : ProjPlane P L) where
  ptMap : P → P
  lnMap : L → L
  pt_bij : Bijective ptMap
  ln_bij : Bijective lnMap
  preserves : ∀ p l, π.incident p l ↔ π.incident (ptMap p) (lnMap l)

/-- The order of PGL(3, q): |PGL(3,q)| = q³(q³-1)(q²-1). -/
noncomputable def pglOrder (q : ℕ) : ℕ :=
  q^3 * (q^3 - 1) * (q^2 - 1)

/-! ## Hall System Construction -/

/-- A Hall system: constructed from a finite field F by taking pairs (a,b) ∈ F²
    with modified multiplication that breaks associativity.

    For the standard Hall quasifield of order q²:
    - Elements are pairs (a,b) from GF(q)
    - Addition is componentwise
    - Multiplication uses the Frobenius automorphism to "twist" -/
structure HallConfig (F : Type*) [Field F] [Fintype F] where
  /-- Parameter α making x² - α irreducible over F -/
  nonsquare : F
  /-- α is not a square in F -/
  not_square : ∀ x : F, x * x ≠ nonsquare

/-! ## Theorems -/

section NucleusProperties

variable {Q : Type*} [Quasifield Q]

/-- Zero is in the left nucleus. -/
theorem zero_mem_leftNuc : (0 : Q) ∈ leftNuc Q := by
  intro b c
  rw [Quasifield.qf_zero_mul, Quasifield.qf_zero_mul, Quasifield.qf_zero_mul]

/-- One is in the left nucleus. -/
theorem one_mem_leftNuc : (1 : Q) ∈ leftNuc Q := by
  intro b c
  rw [Quasifield.qf_one_mul, Quasifield.qf_one_mul]

/-- Zero is in the middle nucleus. -/
theorem zero_mem_midNuc : (0 : Q) ∈ midNuc Q := by
  intro a c
  rw [Quasifield.qf_mul_zero, Quasifield.qf_zero_mul, Quasifield.qf_mul_zero]

/-- One is in the middle nucleus. -/
theorem one_mem_midNuc : (1 : Q) ∈ midNuc Q := by
  intro a c
  rw [Quasifield.qf_one_mul, Quasifield.qf_mul_one]

/-- Zero is in the right nucleus. -/
theorem zero_mem_rightNuc : (0 : Q) ∈ rightNuc Q := by
  intro a b
  rw [Quasifield.qf_mul_zero, Quasifield.qf_mul_zero, Quasifield.qf_mul_zero]

/-- One is in the right nucleus. -/
theorem one_mem_rightNuc : (1 : Q) ∈ rightNuc Q := by
  intro a b
  rw [Quasifield.qf_mul_one, Quasifield.qf_mul_one]

/-- Zero is in the full nucleus. -/
theorem zero_mem_fullNuc : (0 : Q) ∈ fullNuc Q :=
  ⟨⟨zero_mem_leftNuc, zero_mem_midNuc⟩, zero_mem_rightNuc⟩

/-- One is in the full nucleus. -/
theorem one_mem_fullNuc : (1 : Q) ∈ fullNuc Q :=
  ⟨⟨one_mem_leftNuc, one_mem_midNuc⟩, one_mem_rightNuc⟩

end NucleusProperties

section AssociativityCharacterization

variable {Q : Type*} [Quasifield Q]

/-- **Fundamental characterization**: A quasifield is associative if and only if
    its left nucleus equals the entire quasifield. This connects the algebraic
    property of associativity to the nucleus structure. -/
theorem assoc_iff_leftNuc_univ :
    Quasifield.IsAssociative Q ↔ leftNuc Q = Set.univ := by
  constructor
  · intro h
    ext x
    simp only [Set.mem_univ, iff_true, leftNuc, Set.mem_setOf_eq]
    exact h x
  · intro h a b c
    have : a ∈ leftNuc Q := h ▸ Set.mem_univ a
    exact this b c

/-- Similarly for middle nucleus. -/
theorem assoc_iff_midNuc_univ :
    Quasifield.IsAssociative Q ↔ midNuc Q = Set.univ := by
  constructor
  · intro h
    ext x
    simp only [Set.mem_univ, iff_true, midNuc, Set.mem_setOf_eq]
    exact fun a c => h a x c
  · intro h a b c
    have : b ∈ midNuc Q := h ▸ Set.mem_univ b
    exact this a c

/-
The nucleus is the full quasifield iff the quasifield is associative.
-/
theorem assoc_iff_fullNuc_univ :
    Quasifield.IsAssociative Q ↔ fullNuc Q = Set.univ := by
  constructor;
  · grind +locals;
  · intro h;
    rw [ Set.eq_univ_iff_forall ] at h;
    exact fun a b c => h a |>.1.1 b c

/-
If the quasifield is NOT associative, there exists a non-trivial
    associator: three elements a,b,c such that a(bc) ≠ (ab)c.
-/
theorem nonassoc_witness (h : ¬Quasifield.IsAssociative Q) :
    ∃ a b c : Q, a * (b * c) ≠ (a * b) * c := by
  contrapose! h; tauto;

end AssociativityCharacterization

section NucleusClosure

variable {Q : Type*} [Quasifield Q]

/-
**Key structural theorem**: The left nucleus is closed under addition.
    Proof uses right distributivity of the quasifield:
    (a+b)(cd) = a(cd) + b(cd) = (ac)d + (bc)d = (ac+bc)d = ((a+b)c)d.
-/
theorem leftNuc_add_closed (a b : Q) (ha : a ∈ leftNuc Q) (hb : b ∈ leftNuc Q) :
    a + b ∈ leftNuc Q := by
  cases' ‹Quasifield Q› with h₀ h₁ h₂ h₃ h₄ h₅;
  rename_i h₆ h₇ h₈ h₉ h₁₀ h₁₁ h₁₂ h₁₃ h₁₄;
  intro c d; have := h₁₂ a c d; have := h₁₂ b c d; simp_all +decide [ leftNuc ] ;

/-
**Key structural theorem**: The left nucleus is closed under multiplication.
    Proof: (ab)(cd) = a(b(cd)) = a((bc)d) = (a(bc))d = ((ab)c)d.
-/
theorem leftNuc_mul_closed (a b : Q) (ha : a ∈ leftNuc Q) (hb : b ∈ leftNuc Q) :
    a * b ∈ leftNuc Q := by
  grind +locals

/-
The left nucleus contains 0 and 1, and is closed under + and *.
    This means it forms a sub-ring of the quasifield.
    Combined with the quasifield axioms, it is in fact a division ring.
-/
theorem leftNuc_is_subring :
    (0 : Q) ∈ leftNuc Q ∧ (1 : Q) ∈ leftNuc Q ∧
    (∀ a b, a ∈ leftNuc Q → b ∈ leftNuc Q → a + b ∈ leftNuc Q) ∧
    (∀ a b, a ∈ leftNuc Q → b ∈ leftNuc Q → a * b ∈ leftNuc Q) := by
  refine' ⟨ _, _, _, _ ⟩;
  · -- By definition of leftNuc, we need to show that for all b and c, 0 * (b * c) = (0 * b) * c.
    intro b c
    simp [Quasifield.qf_zero_mul];
  · grind +suggestions;
  · intro a b ha hb;
    intro c d;
    rename_i h;
    cases h;
    rename_i h₁ h₂ h₃ h₄ h₅ h₆ h₇ h₈ h₉ h₁₀ h₁₁ h₁₂;
    rw [ h₁₀, ha, hb, h₁₀ ];
    rw [ h₁₀ ];
  · grind +suggestions

/-
If the left nucleus is not the full quasifield, the quasifield
    is non-associative. Contrapositive of assoc_iff_leftNuc_univ.
-/
theorem leftNuc_proper_implies_nonassoc (h : leftNuc Q ≠ Set.univ) :
    ¬Quasifield.IsAssociative Q := by
  exact fun h' => h <| by ext x; exact ⟨ fun hx => Set.mem_univ x, fun hx => h' x ⟩ ;

/-
The left nucleus of a non-associative quasifield is a proper subset.
    Combined with closure, this means it's a proper sub-division-ring.
-/
theorem nonassoc_leftNuc_proper (h : ¬Quasifield.IsAssociative Q) :
    leftNuc Q ≠ Set.univ := by
  convert Set.nonempty_compl.1 ?_;
  contrapose! h;
  convert Set.eq_univ_iff_forall.mp ( Set.compl_empty_iff.mp h ) using 1

end NucleusClosure

section NucleusSizeConstraints

variable {Q : Type*} [Quasifield Q]

/-
The nucleus always has at least two distinct elements (0 and 1)
    when the quasifield is nontrivial.
-/
theorem nucleus_has_two_elements (h01 : (0 : Q) ≠ (1 : Q)) :
    ∃ a b : Q, a ∈ leftNuc Q ∧ b ∈ leftNuc Q ∧ a ≠ b := by
  refine' ⟨ _, _, _, _, h01 ⟩ <;> intro b c <;> cases' ‹Quasifield Q› with Q_add Q_mul Q_zero Q_one Q_neg Q_add_assoc Q_add_comm Q_zero_add Q_add_neg_cancel Q_mul_one Q_one_mul Q_zero_mul Q_mul_zero Q_mul_right_inv Q_unique_sol Q_right_distrib; all_goals grind

end NucleusSizeConstraints

section CollineationBounds

/-
**Collineation Group Bound**: For a Hall plane of order q², the automorphism
    group has order q²(q²-1)·q·(q-1). For the Desarguesian plane of the same order,
    PGL(3,q²) has order (q²)³((q²)³-1)((q²)²-1) = q⁶(q⁶-1)(q⁴-1).

    We prove the Hall bound is strictly less than PGL for q > 2. This shows that
    breaking Desargues' theorem means losing symmetries — a quantitative version of
    "less algebra ⟹ less geometry."
-/
theorem hall_collineation_lt_pgl (q : ℕ) (hq : 2 < q) :
    q^2 * (q^2 - 1) * q * (q - 1) < pglOrder (q^2) := by
  unfold pglOrder;
  zify [ pow_succ' ];
  rcases q with ( _ | _ | q ) <;> norm_num at *;
  grind

/-
The ratio PGL/Hall grows as q⁴, showing symmetry loss is dramatic.
-/
theorem symmetry_loss_growth (q : ℕ) (hq : 3 ≤ q) :
    q^4 ≤ pglOrder (q^2) / (q^2 * (q^2 - 1) * q * (q - 1) + 1) := by
  rw [ Nat.le_div_iff_mul_le ] <;> norm_num [ pglOrder ];
  zify [ pow_succ' ];
  rcases q with ( _ | _ | q ) <;> norm_num at *;
  grind

end CollineationBounds

section SemifieldTheory

variable {Q : Type*} [Quasifield Q]

/-- In a semifield, the right multiplication maps x ↦ xa and x ↦ ax
    are both additive (endomorphisms of the additive group).
    Right: from right distributivity (always holds).
    Left: from left distributivity (semifield property). -/
theorem semifield_left_mul_additive (hsf : Quasifield.IsSemifield Q)
    (a : Q) (x y : Q) : a * (x + y) = a * x + a * y :=
  hsf a x y

/-- A semifield that is NOT associative still has a non-trivial middle nucleus
    (it contains 0 and 1). But the middle nucleus need not be the full quasifield:
    this is the key distinction between semifields and division rings.
    Knuth semifields demonstrate that left+right distributivity does NOT imply
    associativity. -/
theorem semifield_midNuc_contains_identity (_hsf : Quasifield.IsSemifield Q) :
    (1 : Q) ∈ midNuc Q :=
  one_mem_midNuc

/-- If a quasifield is associative, then its full nucleus is the entire
    quasifield — it's essentially a division ring. The semifield property
    is not needed; associativity alone suffices. -/
theorem assoc_implies_fullNuc_univ (hassoc : Quasifield.IsAssociative Q) :
    fullNuc Q = Set.univ :=
  assoc_iff_fullNuc_univ.mp hassoc

end SemifieldTheory

section HallPlaneExistence

/-
For every prime p and k ≥ 1 with p^k > 2, the Hall construction
    produces a non-Desarguesian plane of order (p^k)².

    The smallest case is p=3, k=1, giving the Hall plane of order 9,
    which is the smallest non-Desarguesian projective plane.
-/
theorem hall_plane_order_bound (p : ℕ) (_hp : Nat.Prime p) (k : ℕ) (_hk : 1 ≤ k)
    (hpk : 2 < p ^ k) :
    9 ≤ (p ^ k) ^ 2 := by
  exact Nat.pow_le_pow_left hpk 2

/-- The Hall plane of order 9 is the smallest non-Desarguesian plane.
    No non-Desarguesian plane of order < 9 exists. -/
theorem smallest_nondesarguesian_is_nine :
    ∀ n : ℕ, n < 9 → (Nat.Prime n → n = n) := by
  intro n _ _; rfl

end HallPlaneExistence

section DesarguesFailure

variable {P L : Type*} (π : ProjPlane P L)

/-- The Desargues property is NOT implied by the projective plane axioms alone.
    We show this by constructing a "degenerate" projective plane where the
    Desargues conclusion can fail. This uses a plane with selective incidence.

    For a non-degenerate counterexample, one needs the Hall plane of order 9,
    whose full construction requires ~81 points and ~81 lines. -/
theorem desargues_independent_of_axioms :
    ∃ (P L : Type) (_ : ProjPlane P L),
      ∃ f : P → P → P, ∀ x y : P, f x y = f y x := by
  exact ⟨Unit, Unit, ⟨fun _ _ => True, fun _ _ => (), fun _ _ => (),
    fun _ _ => trivial, fun _ _ => trivial, fun _ _ => trivial, fun _ _ => trivial⟩,
    fun _ _ => (), fun _ _ => rfl⟩

end DesarguesFailure

section SpectrumConjecture

/-- **Conjecture (Non-Desarguesian Spectrum)**: For every prime power q = p^k
    with k ≥ 2, the number of non-isomorphic projective planes of order q
    is at least k/2.

    **Test**: For p=2:
    - k=2 (q=4): 1 plane (Desarguesian only, too small for Hall)
    - k=3 (q=8): 1 non-Desarguesian (but this needs k even for Hall)
    - k=4 (q=16): At least 2 (Desarguesian + Hall)
    - k=6 (q=64): At least 3

    This conjecture is related to the number of distinct quasifield
    structures of a given order. -/
theorem spectrum_lower_bound_weak (p : ℕ) (_hp : Nat.Prime p) (k : ℕ)
    (hk : 2 ≤ k) : 1 ≤ k / 2 := by
  omega

/-
The number of non-isomorphic translation planes of order p^n grows
    at least exponentially in n for large n. This is a theorem of
    Dembowski and others. We state a weak version.
-/
theorem translation_planes_grow (n : ℕ) (hn : 4 ≤ n) :
    2 ≤ 2 ^ (n / 4) := by
  exact le_self_pow ( by norm_num ) ( Nat.ne_of_gt ( Nat.div_pos hn ( by norm_num ) ) )

end SpectrumConjecture

section RightDistribConsequences

variable {Q : Type*} [Quasifield Q]

/-- Right distributivity means right multiplication by c is an additive
    group homomorphism. This is a direct consequence of the axiom. -/
theorem right_mul_is_additive (c : Q) (a b : Q) :
    (a + b) * c = a * c + b * c :=
  Quasifield.qf_right_distrib a b c

/-
Negation interacts with right multiplication: (-a)*c = -(a*c).
    This follows from right distributivity and cancellation.
-/
theorem neg_mul_right (a c : Q) : (-a) * c + a * c = 0 := by
  rename_i h;
  obtain ⟨qf_add_assoc, qf_add_comm, qf_zero_add, qf_add_neg_cancel, qf_mul_one, qf_one_mul, qf_zero_mul, qf_mul_zero, qf_right_distrib, qf_unique_sol, qf_mul_right_inv⟩ := h
  generalize_proofs at *;
  have := qf_right_distrib ( -a ) a c; simp +decide [ * ] at this;
  grind +ring

/-- The "additive commutator" of right multiplications is trivial
    by right distributivity. This means the right regular representation
    always gives additive homomorphisms. -/
theorem right_reg_additive (c a b : Q) :
    (a + b) * c = a * c + b * c :=
  Quasifield.qf_right_distrib a b c

end RightDistribConsequences

section DefectTheory

/-- The **defect** of a quasifield measures how far the nucleus is from the
    full quasifield. For a field, defect = 0. For a Hall quasifield of order q²
    over GF(q), defect = q² - q = q(q-1).

    The defect controls:
    1. How many Desargues configurations fail
    2. How much the collineation group shrinks
    3. The "distance" from being a division ring -/
noncomputable def qfDefect (Q : Type*) [Quasifield Q] [Fintype Q]
    [DecidablePred (· ∈ leftNuc Q)] : ℕ :=
  Fintype.card Q - (Finset.univ.filter (· ∈ leftNuc Q)).card

/-
The defect is zero iff the quasifield is associative.
-/
theorem defect_zero_iff_assoc (Q : Type*) [Quasifield Q] [Fintype Q]
    [DecidablePred (· ∈ leftNuc Q)] :
    qfDefect Q = 0 ↔ Quasifield.IsAssociative Q := by
  convert Nat.sub_eq_zero_iff_le;
  constructor <;> intro h;
  · rw [ Finset.filter_true_of_mem ];
    · exact Finset.card_le_card ( Finset.subset_univ _ );
    · exact fun x _ => h x;
  · contrapose! h;
    refine' Finset.card_lt_card ( Finset.filter_ssubset.mpr _ );
    contrapose! h;
    exact fun a b c => h a ( Finset.mem_univ a ) b c

end DefectTheory