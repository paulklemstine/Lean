/-
# Characters and infinitesimal characters of the bialgebras on a free monoid

This file formalizes the classification sentence of the paper *Various bialgebras of
representative functions on free monoids*:

> ... the graded noncommutative co-commutative bialgebras of polynomials having,
> for the concatenation, only Kleene stars of the planes as characters, or equivalently,
> only the planes are infinitesimal characters (thanks to a Ree's theorem like).

Concretely, a *character* of the concatenation bialgebra `(K⟨X⟩, conc, Δ_⧢)` is a linear
form `f` on polynomials which is multiplicative for concatenation, i.e. a function
`f : X* → K` with `f(1) = 1` and `f(uv) = f(u) f(v)`; a *plane* is a homogeneous element
of degree one, i.e. a linear form supported on the alphabet; and the *Kleene star* of the
plane `ℓ = Σ_x c_x x` is `ℓ* = Σ_n ℓ^n`, whose coefficient at the word `w = x_1 ⋯ x_n`
is `c_{x_1} ⋯ c_{x_n}`.

Main results:

* `isConcatCharacter_iff_planeStar` : the characters of the concatenation bialgebra are
  exactly the Kleene stars of planes.
* `isConcatInfChar_iff_isPlane` : the infinitesimal characters of the concatenation
  bialgebra are exactly the planes.
* `isShuffleCharacter_expPlane` : dually, the exponential of a plane is a character of
  the shuffle algebra (a group-like series for the unshuffle coproduct).
* `shuffleCharacter_pow_letter` : any shuffle character has divided-power values along a
  single letter, `f(aⁿ) = f(a)ⁿ / n!` — the one-letter case of Ree's theorem.
-/
import Novelty.FreeMonoidUnshuffle

namespace FreeMonoidShuffle

variable {X : Type*} {K : Type*}

/-! ## The counit -/

/-- The counit `ε` of both bialgebras: `ε(w) = 1` if `w` is the empty word, `0` otherwise. -/
def counit [Zero K] [One K] : List X → K
  | [] => 1
  | _ :: _ => 0

@[simp] lemma counit_nil [Zero K] [One K] : (counit ([] : List X) : K) = 1 := rfl
@[simp] lemma counit_cons [Zero K] [One K] (a : X) (w : List X) :
    (counit (a :: w) : K) = 0 := rfl

lemma counit_eq_zero_of_ne_nil [Zero K] [One K] {w : List X} (hw : w ≠ []) :
    (counit w : K) = 0 := by
  cases w with
  | nil => exact absurd rfl hw
  | cons a w => rfl

section CommRing
variable [CommRing K]

/-! ## Characters of the concatenation bialgebra -/

/-- A character of the concatenation bialgebra: a multiplicative, unital linear form. -/
def IsConcatCharacter (f : List X → K) : Prop :=
  f [] = 1 ∧ ∀ u v : List X, f (u ++ v) = f u * f v

/-- The Kleene star `ℓ*` of the plane `ℓ = Σ_x c_x x`, read off as a function on words:
its coefficient at `w = x_1 ⋯ x_n` is `c_{x_1} ⋯ c_{x_n}`. -/
def planeStar (c : X → K) : List X → K := fun w => (w.map c).prod

@[simp] lemma planeStar_nil (c : X → K) : planeStar c ([] : List X) = 1 := rfl

@[simp] lemma planeStar_letter (c : X → K) (a : X) : planeStar c [a] = c a := by
  simp [planeStar]

lemma isConcatCharacter_planeStar (c : X → K) : IsConcatCharacter (planeStar c) :=
  ⟨rfl, fun u v => by simp [planeStar]⟩

/-- **Every character of the concatenation bialgebra is the Kleene star of a plane.** -/
theorem eq_planeStar_of_isConcatCharacter {f : List X → K} (hf : IsConcatCharacter f) :
    f = planeStar (fun x => f [x]) := by
  funext w
  induction w with
  | nil => simpa using hf.1
  | cons a w ih =>
    have : f ([a] ++ w) = f [a] * f w := hf.2 [a] w
    simp only [List.singleton_append] at this
    rw [this, ih]
    simp [planeStar]

/-- **Characters of the concatenation bialgebra = Kleene stars of planes.** -/
theorem isConcatCharacter_iff_planeStar (f : List X → K) :
    IsConcatCharacter f ↔ ∃ c : X → K, f = planeStar c :=
  ⟨fun hf => ⟨_, eq_planeStar_of_isConcatCharacter hf⟩,
   fun ⟨c, hc⟩ => hc ▸ isConcatCharacter_planeStar c⟩

/-! ## Infinitesimal characters of the concatenation bialgebra -/

/-- An infinitesimal character of the concatenation bialgebra: a linear form which is a
derivation from the concatenation product to the counit, i.e. `g(uv) = g(u)ε(v) + ε(u)g(v)`. -/
def IsConcatInfChar (g : List X → K) : Prop :=
  ∀ u v : List X, g (u ++ v) = g u * counit v + counit u * g v

/-- A *plane*: a linear form supported by the alphabet, i.e. a homogeneous element of
degree one of the graded dual. -/
def IsPlane (g : List X → K) : Prop := ∀ w : List X, w.length ≠ 1 → g w = 0

/-- **The infinitesimal characters of the concatenation bialgebra are exactly the
planes.** -/
theorem isConcatInfChar_iff_isPlane (g : List X → K) : IsConcatInfChar g ↔ IsPlane g := by
  constructor
  · intro hg
    have hnil : g [] = 0 := by
      have h := hg [] []
      simp only [List.append_nil, counit_nil, mul_one, one_mul] at h
      have h2 : g [] + g [] = g [] + 0 := by rw [add_zero]; exact h.symm
      exact (add_left_cancel h2)
    intro w hw
    match w, hw with
    | [], _ => exact hnil
    | [a], hw => exact absurd rfl hw
    | a :: b :: w, _ =>
      have := hg [a] (b :: w)
      simpa using this
  · intro hg u v
    rcases eq_or_ne v [] with rfl | hv
    · have h0 : g [] = 0 := hg [] (by simp)
      simp [h0]
    · rcases eq_or_ne u [] with rfl | hu
      · have h0 : g [] = 0 := hg [] (by simp)
        simp [h0, counit_eq_zero_of_ne_nil hv]
      · have hlen : (u ++ v).length ≠ 1 := by
          have h1 : 1 ≤ u.length := List.length_pos_iff.2 hu
          have h2 : 1 ≤ v.length := List.length_pos_iff.2 hv
          simp only [List.length_append]
          omega
        rw [hg _ hlen, counit_eq_zero_of_ne_nil hu, counit_eq_zero_of_ne_nil hv]
        ring

end CommRing

/-! ## Characters of the shuffle algebra -/

section Shuffle
variable [CommRing K]

/-- A character of the shuffle algebra, equivalently (by shuffle/unshuffle duality) a
group-like series for the unshuffle coproduct. -/
def IsShuffleCharacter (f : List X → K) : Prop :=
  f [] = 1 ∧ ∀ u v : List X, f u * f v = ((shuf u v).map f).sum

/-- Every shuffle of `u` and `v` has the same multiplicative letter-weight as `uv`. -/
theorem prod_map_of_mem_shuf (c : X → K) {u v z : List X} (hz : z ∈ shuf u v) :
    (z.map c).prod = (u.map c).prod * (v.map c).prod := by
  induction hn : u.length + v.length using Nat.strong_induction_on generalizing u v z with
  | _ n ih =>
  match u, v with
  | [], v => rw [shuf_nil_left] at hz; simp only [Multiset.mem_singleton] at hz; simp [hz]
  | u, [] => rw [shuf_nil_right] at hz; simp only [Multiset.mem_singleton] at hz; simp [hz]
  | a :: u, b :: v =>
    subst hn
    rw [shuf_cons_cons] at hz
    rcases Multiset.mem_add.1 hz with h | h
    · obtain ⟨y, hy, rfl⟩ := Multiset.mem_map.1 h
      have := ih (u.length + (b :: v).length) (by simp) hy rfl
      simp only [List.map_cons, List.prod_cons, this]
      ring
    · obtain ⟨y, hy, rfl⟩ := Multiset.mem_map.1 h
      have := ih ((a :: u).length + v.length) (by simp) hy rfl
      simp only [List.map_cons, List.prod_cons, this]
      ring

end Shuffle

section Field
variable [Field K] [CharZero K]

/-- The exponential `exp(ℓ)` of the plane `ℓ = Σ_x c_x x`, as a function on words:
its coefficient at `w` is `c_{x_1} ⋯ c_{x_n} / n!`. -/
def expPlane (c : X → K) : List X → K := fun w => (w.map c).prod / (Nat.factorial w.length)

@[simp] lemma expPlane_nil (c : X → K) : expPlane c ([] : List X) = 1 := by
  simp [expPlane]

/-- **The exponential of a plane is a character of the shuffle algebra.** -/
theorem isShuffleCharacter_expPlane (c : X → K) : IsShuffleCharacter (expPlane c) := by
  refine ⟨by simp, fun u v => ?_⟩
  have hconst : ∀ z ∈ shuf u v,
      expPlane c z = (u.map c).prod * (v.map c).prod /
        (Nat.factorial (u.length + v.length) : K) := by
    intro z hz
    rw [expPlane, prod_map_of_mem_shuf c hz, shuf_length_mem hz]
  rw [Multiset.map_congr rfl hconst, Multiset.map_const', Multiset.sum_replicate,
    shuf_card]
  have hfac : ((u.length + v.length).choose u.length : K) *
      ((Nat.factorial u.length : K) * (Nat.factorial v.length : K)) =
      (Nat.factorial (u.length + v.length) : K) := by
    have h := Nat.choose_mul_factorial_mul_factorial
      (Nat.le_add_right u.length v.length)
    have h2 : (u.length + v.length) - u.length = v.length := by omega
    rw [h2] at h
    exact_mod_cast congrArg (fun n : ℕ => (n : K)) (by rw [← h]; ring)
  have hu : (Nat.factorial u.length : K) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero _)
  have hv : (Nat.factorial v.length : K) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero _)
  have hw : (Nat.factorial (u.length + v.length) : K) ≠ 0 :=
    Nat.cast_ne_zero.2 (Nat.factorial_ne_zero _)
  rw [expPlane, expPlane, nsmul_eq_mul]
  field_simp
  rw [← hfac]
  ring

end Field

/-! ## Divided powers: the one-letter case of Ree's theorem -/

theorem shuf_replicate_letter {X : Type*} (a : X) (n : ℕ) :
    shuf (List.replicate n a) [a] = Multiset.replicate (n + 1) (List.replicate (n + 1) a) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [List.replicate_succ, shuf_cons_cons, ih, shuf_nil_right]
    simp only [Multiset.map_replicate, Multiset.map_singleton, ← List.replicate_succ]
    rw [Multiset.replicate_add (n + 1) 1]
    rfl

/-- **Divided powers along one letter.**  Any character of the shuffle algebra satisfies
`f(aⁿ) = f(a)ⁿ / n!`; in particular a shuffle character is completely determined on the
free monoid generated by one letter by its value on that letter, and is the exponential
of a plane there. -/
theorem shuffleCharacter_pow_letter {X : Type*} {K : Type*} [Field K] [CharZero K]
    {f : List X → K} (hf : IsShuffleCharacter f) (a : X) (n : ℕ) :
    f (List.replicate n a) = f [a] ^ n / (Nat.factorial n) := by
  induction n with
  | zero => simpa using hf.1
  | succ n ih =>
    have hfn : (Nat.factorial n : K) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero _)
    have hfn1 : (Nat.factorial (n + 1) : K) ≠ 0 := Nat.cast_ne_zero.2 (Nat.factorial_ne_zero _)
    have hfac : (Nat.factorial (n + 1) : K) = ((n : K) + 1) * (Nat.factorial n : K) := by
      rw [Nat.factorial_succ]; push_cast; ring
    have h := hf.2 (List.replicate n a) [a]
    rw [shuf_replicate_letter a n, Multiset.map_replicate, Multiset.sum_replicate,
      nsmul_eq_mul, ih] at h
    push_cast at h
    rw [div_mul_eq_mul_div, div_eq_iff hfn] at h
    rw [eq_div_iff hfn1, hfac]
    linear_combination -h

end FreeMonoidShuffle