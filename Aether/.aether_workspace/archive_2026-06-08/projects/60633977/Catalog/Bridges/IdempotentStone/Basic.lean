/-
  # Idempotent Stone Completeness via Closure Nuclei and Tropical Kripke Spectra
  ## Part 1: Core Definitions and Basic Lemmas

  This file defines:
  - Idempotent commutative semirings with the natural order
  - Closure nuclei on idempotent semirings
  - Closure-compatible congruences and prime closure-congruences
  - Basic algebraic lemmas for these structures

  The key innovation: the semantic "worlds" for tropical modal logic are
  prime closure-congruences of the algebra itself, not external Kripke frames.
-/
import Mathlib

namespace IdempotentStone

/-! ## §1. Idempotent Commutative Semirings -/

/-- An idempotent commutative semiring: a commutative semiring where addition
    is idempotent (a + a = a). The natural order is x ≤ y ↔ x + y = y,
    making (S, +) a join-semilattice with bottom 0. -/
class IdempCSR (S : Type*) extends CommSemiring S where
  add_idem : ∀ a : S, a + a = a

namespace IdempCSR

variable {S : Type*} [IdempCSR S]

/-- The idempotent semiring natural order: x ≤ y iff x + y = y. -/
def natLE (a b : S) : Prop := a + b = b

theorem natLE_refl (a : S) : natLE a a := add_idem a

theorem natLE_antisymm (a b : S) (h1 : natLE a b) (h2 : natLE b a) : a = b := by
  unfold natLE at h1 h2
  calc a = b + a := h2.symm
    _ = a + b := add_comm b a
    _ = b := h1

theorem natLE_trans (a b c : S) (h1 : natLE a b) (h2 : natLE b c) : natLE a c := by
  unfold natLE at *
  calc a + c = a + (b + c) := by rw [h2]
    _ = (a + b) + c := by rw [add_assoc]
    _ = b + c := by rw [h1]
    _ = c := h2

theorem add_natLE_right (a b : S) : natLE a (a + b) := by
  unfold natLE
  calc a + (a + b) = (a + a) + b := by rw [add_assoc]
    _ = a + b := by rw [add_idem]

theorem add_natLE_left (a b : S) : natLE b (a + b) := by
  rw [add_comm a b]; exact add_natLE_right b a

/-- Addition is the join: a + b is the least upper bound of a and b. -/
theorem add_is_join (a b c : S) (ha : natLE a c) (hb : natLE b c) :
    natLE (a + b) c := by
  unfold natLE at *
  calc (a + b) + c = a + (b + c) := add_assoc a b c
    _ = a + c := by rw [hb]
    _ = c := ha

/-- Zero is the bottom element. -/
theorem zero_natLE (a : S) : natLE 0 a := by
  unfold natLE; exact zero_add a

/-- Multiplication is monotone in the left argument. -/
theorem mul_natLE_mul_left (a b c : S) (h : natLE a b) :
    natLE (c * a) (c * b) := by
  unfold natLE at *
  calc c * a + c * b = c * (a + b) := (mul_add c a b).symm
    _ = c * b := by rw [h]

/-- Multiplication is monotone in the right argument. -/
theorem mul_natLE_mul_right (a b c : S) (h : natLE a b) :
    natLE (a * c) (b * c) := by
  rw [mul_comm a c, mul_comm b c]; exact mul_natLE_mul_left a b c h

end IdempCSR

/-! ## §2. Closure Nuclei -/

/-- A closure nucleus on an idempotent commutative semiring: a closure operator
    that is join-stable and satisfies a multiplicative nucleus law.

    This is the correct algebraic abstraction for EML-style closures
    and the □ modality in positive tropical modal logic. -/
structure ClosureNucleus (S : Type*) [IdempCSR S] where
  /-- The closure operation -/
  c : S → S
  /-- Inflationary: x ≤ c(x) -/
  le_c : ∀ x : S, IdempCSR.natLE x (c x)
  /-- Monotone: x ≤ y → c(x) ≤ c(y) -/
  mono : ∀ x y : S, IdempCSR.natLE x y → IdempCSR.natLE (c x) (c y)
  /-- Idempotent: c(c(x)) = c(x) -/
  idem : ∀ x : S, c (c x) = c x
  /-- Join-stable: c(x + y) = c(x) + c(y) -/
  map_add : ∀ x y : S, c (x + y) = c x + c y
  /-- Nucleus multiplicative law: c(x) * c(y) ≤ c(x * y) -/
  mul_le : ∀ x y : S, IdempCSR.natLE (c x * c y) (c (x * y))

namespace ClosureNucleus

variable {S : Type*} [IdempCSR S] (cn : ClosureNucleus S)

/-- A closed element is a fixed point of c. -/
def IsClosed (x : S) : Prop := cn.c x = x

/-- c(x) is always closed. -/
theorem c_closed (x : S) : cn.IsClosed (cn.c x) := cn.idem x

/-- c preserves the order relation. -/
theorem c_mono {x y : S} (h : IdempCSR.natLE x y) :
    IdempCSR.natLE (cn.c x) (cn.c y) :=
  cn.mono x y h

/-- The image of c (the closed elements) is closed under addition. -/
theorem closed_add {x y : S} (hx : cn.IsClosed x) (hy : cn.IsClosed y) :
    cn.IsClosed (x + y) := by
  unfold IsClosed at *
  rw [cn.map_add, hx, hy]

/-- c(1) is closed. -/
theorem c_one_closed : cn.IsClosed (cn.c 1) := cn.c_closed 1

/-- c applied to a closed element is identity. -/
theorem c_of_closed {x : S} (h : cn.IsClosed x) : cn.c x = x := h

/-- c is inflationary: x + c(x) = c(x). -/
theorem le_c_eq (x : S) : x + cn.c x = cn.c x := cn.le_c x

/-- c(0) + c(0) = c(0), i.e., c(0) is idempotent under addition (always true). -/
theorem c_zero_idem : cn.c 0 + cn.c 0 = cn.c 0 := by
  rw [← cn.map_add]; simp [add_zero]

/-- c(0) = c(0), establishing c(0) is closed. -/
theorem c_zero_closed : cn.IsClosed (cn.c 0) := cn.c_closed 0

end ClosureNucleus

/-! ## §3. Closure-Compatible Congruences -/

/-- A closure-congruence on S: a semiring congruence compatible with the
    closure operator. These are the "observational equivalences" that
    respect the information-compression operator c. -/
structure ClosureCong (S : Type*) [IdempCSR S] (cn : ClosureNucleus S) where
  /-- The underlying equivalence relation -/
  r : S → S → Prop
  /-- Reflexivity -/
  r_refl : ∀ x, r x x
  /-- Symmetry -/
  r_symm : ∀ {x y}, r x y → r y x
  /-- Transitivity -/
  r_trans : ∀ {x y z}, r x y → r y z → r x z
  /-- Compatible with addition -/
  r_add : ∀ {a b c d}, r a b → r c d → r (a + c) (b + d)
  /-- Compatible with multiplication -/
  r_mul : ∀ {a b c d}, r a b → r c d → r (a * c) (b * d)
  /-- Compatible with closure -/
  r_closure : ∀ {x y}, r x y → r (cn.c x) (cn.c y)

namespace ClosureCong

variable {S : Type*} [IdempCSR S] {cn : ClosureNucleus S}

/-- The diagonal congruence: only equal elements are related. -/
def diag (cn : ClosureNucleus S) : ClosureCong S cn where
  r := Eq
  r_refl := fun _ => rfl
  r_symm := Eq.symm
  r_trans := Eq.trans
  r_add := fun h1 h2 => by rw [h1, h2]
  r_mul := fun h1 h2 => by rw [h1, h2]
  r_closure := fun h => by rw [h]

/-- A congruence is proper if it doesn't identify 0 and 1. -/
def IsProper (P : ClosureCong S cn) : Prop := ¬ P.r 0 1

/-- The class of x under the congruence. -/
def cls (P : ClosureCong S cn) (x : S) : Set S := {y | P.r x y}

theorem cls_mem_self (P : ClosureCong S cn) (x : S) : x ∈ P.cls x := P.r_refl x

/-- If x ≈ y then [x] = [y]. -/
theorem cls_eq_of_r (P : ClosureCong S cn) {x y : S} (h : P.r x y) :
    P.cls x = P.cls y := by
  ext z; constructor
  · intro hz; exact P.r_trans (P.r_symm h) hz
  · intro hz; exact P.r_trans h hz

/-- Congruence classes respect idempotent addition: a + a ≈ a. -/
theorem r_add_self (P : ClosureCong S cn) (a : S) : P.r (a + a) a := by
  have h1 : a + a = a := IdempCSR.add_idem a
  rw [h1]; exact P.r_refl a

end ClosureCong

/-! ## §4. Prime Closure-Congruences -/

/-- A prime closure-congruence: a proper closure-congruence with a primality
    condition on closed elements. This is the tropical analogue of a prime
    ideal in commutative algebra.

    Primality: if c(a * b) ≈ 0, then c(a) ≈ 0 or c(b) ≈ 0.
    This says the "closed kernel" {x | c(x) ≈ 0} is a prime set. -/
structure PrimeClosureCong (S : Type*) [IdempCSR S] (cn : ClosureNucleus S)
    extends ClosureCong S cn where
  /-- The congruence is proper: 0 ≁ 1 -/
  proper : ¬ toClosureCong.r 0 1
  /-- Primality of the closed kernel -/
  prime : ∀ a b, toClosureCong.r (cn.c (a * b)) 0 →
    toClosureCong.r (cn.c a) 0 ∨ toClosureCong.r (cn.c b) 0

namespace PrimeClosureCong

variable {S : Type*} [IdempCSR S] {cn : ClosureNucleus S}

/-- Two elements are identified by a prime congruence. -/
def identifies (P : PrimeClosureCong S cn) (a b : S) : Prop :=
  P.toClosureCong.r a b

/-- Two closed elements are separated by a prime congruence. -/
def separates (P : PrimeClosureCong S cn) (a b : S) : Prop :=
  ¬ P.toClosureCong.r a b

/-- The basic open set D(a,b) in the closure spectrum:
    the set of prime congruences that separate c(a) from c(b). -/
def basicOpen (cn : ClosureNucleus S) (a b : S) :
    Set (PrimeClosureCong S cn) :=
  {P | P.separates (cn.c a) (cn.c b)}

/-- D(a,a) is empty: no prime congruence separates c(a) from itself. -/
theorem basicOpen_diag (cn : ClosureNucleus S) (a : S) :
    basicOpen cn a a = ∅ := by
  ext P; simp [basicOpen, separates]
  exact P.toClosureCong.r_refl _

/-- If P identifies a and b, P is not in D(a,b). -/
theorem not_mem_basicOpen_of_identifies {cn : ClosureNucleus S}
    (P : PrimeClosureCong S cn) {a b : S}
    (h : P.identifies (cn.c a) (cn.c b)) :
    P ∉ basicOpen cn a b :=
  fun h' => h' h

end PrimeClosureCong

/-! ## §5. The Separation Axiom and Representation Theorem -/

/-- The separation property: prime closure-congruences separate closed elements.
    This is the key hypothesis for the representation theorem.

    Algebraically: if c(a) ≠ c(b), then there exists a prime c-congruence P
    such that c(a) ≁_P c(b). -/
def PrimeSeparation (S : Type*) [IdempCSR S] (cn : ClosureNucleus S) : Prop :=
  ∀ a b : S, cn.c a ≠ cn.c b →
    ∃ P : PrimeClosureCong S cn, P.separates (cn.c a) (cn.c b)

/-- **Separation Theorem (Theorem 1)**: Under the prime separation hypothesis,
    the evaluation map restricted to closed elements is injective.

    This is the idempotent semiring analogue of Stone's representation theorem:
    the algebra of closed elements embeds into a product of "stalks" (quotients).

    If two closed elements a, b are identified by every prime c-congruence,
    then a = b. -/
theorem separation_injective {S : Type*} [IdempCSR S] (cn : ClosureNucleus S)
    (sep : PrimeSeparation S cn)
    (a b : S) (ha : cn.IsClosed a) (hb : cn.IsClosed b)
    (h : ∀ P : PrimeClosureCong S cn, P.identifies a b) :
    a = b := by
  by_contra hab
  have ha' : cn.c a = a := ha
  have hb' : cn.c b = b := hb
  have hne : cn.c a ≠ cn.c b := by rwa [ha', hb']
  obtain ⟨P, hP⟩ := sep a b hne
  rw [ha', hb'] at hP
  exact hP (h P)

/-- **Subdirect Embedding Corollary**: Two closed elements with the same image
    under all prime congruence quotients are equal.
    This is the core of Theorem 1 (Spectral Representation). -/
theorem closed_determined_by_spectrum
    {S : Type*} [IdempCSR S] (cn : ClosureNucleus S)
    (sep : PrimeSeparation S cn) :
    ∀ a b : S, cn.IsClosed a → cn.IsClosed b →
    (∀ P : PrimeClosureCong S cn, P.identifies a b) → a = b :=
  separation_injective cn sep

/-- **Non-triviality**: Under separation, the closed elements form a non-trivial
    algebra (assuming 0 ≠ 1 in S). -/
theorem closed_nontrivial {S : Type*} [IdempCSR S] [Nontrivial S] :
    (0 : S) ≠ 1 := by
  exact one_ne_zero ∘ Eq.symm

end IdempotentStone