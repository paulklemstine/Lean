/-
# The Extrinsic Class-Group Representation Vector is a Residue Dial

Formal core of the *factor3* investigation
`ResearchOutput/NewMathematics/35_ClassGroup_ResidueDial.md`
(experiment RANDOM-BQF #370).

## The question

Attach to an integer `N` an *extrinsic* discriminant `D` (independent of `N`),
form the finitely many reduced binary quadratic forms `Q_1, … , Q_h` of
discriminant `D`, and record the **representation vector**

  `r(N) = ( #{(x,y) : Q_1(x,y) = N}, … , #{(x,y) : Q_h(x,y) = N} )`.

Computing this vector is cheap (`poly(|D|, log N)`, no factoring).  The hope of
the round-13 brainstorm was that the individual entries feel the *separate*
Legendre symbols `(D/p)`, `(D/q)` of the factors of `N = p q`, so that the
vector could distinguish factorisation *types* which have the same residue
`N mod |D|`.

## What is proved here (`D = -20`, `h = 2`)

The two reduced forms of discriminant `-20` are

  `P(x,y) = x² + 5y²`   and   `Q(x,y) = 2x² + 2xy + 3y²`.

* `ClassGroupResidueDial.sound20` : a value of `P` coprime to `20` is `≡ 1, 9 (mod 20)`;
  a value of `Q` coprime to `20` is `≡ 3, 7 (mod 20)`  (finite check in `ZMod 20`).
* `ClassGroupResidueDial.ResidueDial.readout_eq` : consequently the *index of the class that
  represents `N`* is a **function of `N mod 20` alone** — the "residue dial".
* `ClassGroupResidueDial.comp20` : Gauss composition, realised by explicit bilinear
  identities: the two classes form the group `ℤ/2` under multiplication of
  represented integers (`P·P = P`, `Q·Q = P`, `P·Q = Q`).
* `ClassGroupResidueDial.obs_pp_eq_obs_nn` : **the refutation.**  If `p, q` are both
  represented by the principal form and `p', q'` are both represented by the
  non-principal form, then `pq` and `p'q'` have *identical* observation vectors
  `(true, false)`.  The "PP" and "NN" factorisation types are invisible.
* Exact counts (`reps_21_ncard`, `reps_87_ncard`, `reps_1189_ncard`) confirm the
  numerical `(8,0)` signature of the experiment on both a PP and an NN semiprime.

The abstract notion `ResidueDial` isolates exactly what makes the collapse
happen: *soundness* (each class only represents certain residues) plus
*disjointness* of those residue sets.  Any such family is factor-blind.
-/
import Mathlib

namespace ClassGroupResidueDial

/-! ## 1. Abstract residue dials -/

/-- A **residue dial** modulo `m` with class index type `ι`: a family of
"is represented by class `i`" predicates on `ℤ`, together with pairwise disjoint
sets of residues mod `m` that *contain* all the unit values of each class.

The only inputs are `sound` and `disj`; everything in §1 is a consequence. -/
structure ResidueDial (m : ℕ) (ι : Type*) where
  /-- `repr i N` : the integer `N` is represented by the `i`-th class. -/
  repr : ι → ℤ → Prop
  /-- The residues mod `m` allowed for the `i`-th class. -/
  res : ι → Finset (ZMod m)
  /-- Soundness: a unit value of class `i` lands in `res i`. -/
  sound : ∀ i (N : ℤ), (∃ u : ZMod m, u * (N : ZMod m) = 1) → repr i N → ((N : ZMod m) ∈ res i)
  /-- The residue sets of distinct classes are disjoint. -/
  disj : ∀ i j, i ≠ j → ∀ a, a ∈ res i → a ∉ res j

variable {m : ℕ} {ι : Type*}

/-- Cast an integer coprime to `m` to a unit of `ZMod m`. -/
theorem unit_cast_of_isCoprime {N : ℤ} (h : IsCoprime N (m : ℤ)) :
    ∃ u : ZMod m, u * (N : ZMod m) = 1 := by
  obtain ⟨a, b, hab⟩ := h
  refine ⟨(a : ZMod m), ?_⟩
  have := congrArg (fun z : ℤ => (z : ZMod m)) hab
  push_cast at this
  simpa [ZMod.natCast_self] using this

/-- At most one class represents a given unit residue: the class index is
well defined. -/
theorem ResidueDial.index_unique (d : ResidueDial m ι) {N : ℤ}
    (hN : ∃ u : ZMod m, u * (N : ZMod m) = 1) {i j : ι}
    (hi : d.repr i N) (hj : d.repr j N) : i = j := by
  by_contra hne
  exact d.disj i j hne _ (d.sound i N hN hi) (d.sound j N hN hj)

/-- **Factor-blindness.**  The class index of `N` depends only on `N mod m`:
two integers with the same residue are represented by the same class.  No
arithmetic feature of `N` finer than its residue can be read off. -/
theorem ResidueDial.factor_blind (d : ResidueDial m ι) {N M : ℤ}
    (hN : ∃ u : ZMod m, u * (N : ZMod m) = 1)
    (hM : ∃ u : ZMod m, u * (M : ZMod m) = 1)
    (hres : ((N : ℤ) : ZMod m) = ((M : ℤ) : ZMod m)) {i j : ι}
    (hi : d.repr i N) (hj : d.repr j M) : i = j := by
  by_contra hne
  have h1 := d.sound i N hN hi
  have h2 := d.sound j M hM hj
  rw [← hres] at h2
  exact d.disj i j hne _ h1 h2

open Classical in
/-- The **dial**: the explicit function `ZMod m → ι` that the observation
factors through. -/
noncomputable def ResidueDial.readout [Inhabited ι] (d : ResidueDial m ι) (a : ZMod m) : ι :=
  if h : ∃ i, a ∈ d.res i then h.choose else default

/-- The readout really computes the class index from the residue only. -/
theorem ResidueDial.readout_eq [Inhabited ι] (d : ResidueDial m ι) {N : ℤ} {i : ι}
    (hN : ∃ u : ZMod m, u * (N : ZMod m) = 1) (hi : d.repr i N) :
    d.readout ((N : ℤ) : ZMod m) = i := by
  classical
  have hmem : ((N : ℤ) : ZMod m) ∈ d.res i := d.sound i N hN hi
  have hex : ∃ j, ((N : ℤ) : ZMod m) ∈ d.res j := ⟨i, hmem⟩
  have hspec := hex.choose_spec
  have : d.readout ((N : ℤ) : ZMod m) = hex.choose := by
    simp [ResidueDial.readout, hex]
  rw [this]
  by_contra hne
  exact d.disj _ _ hne _ hspec hmem

/-! ## 2. The discriminant `-20` dial -/

/-- Represented by the principal form `x² + 5y²` of discriminant `-20`. -/
def ReprP (N : ℤ) : Prop := ∃ x y : ℤ, x ^ 2 + 5 * y ^ 2 = N

/-- Represented by the non-principal form `2x² + 2xy + 3y²` of discriminant `-20`. -/
def ReprQ (N : ℤ) : Prop := ∃ x y : ℤ, 2 * x ^ 2 + 2 * x * y + 3 * y ^ 2 = N

/-- The two-element family of reduced forms of discriminant `-20`,
indexed by `Bool` (`false` = principal class, `true` = non-principal class). -/
def repr20 : Bool → ℤ → Prop
  | false => ReprP
  | true => ReprQ

/-- The genus characters mod `20`: the principal class only represents `1, 9`,
the other class only `3, 7`. -/
def res20 : Bool → Finset (ZMod 20)
  | false => {1, 9}
  | true => {3, 7}

/-- Finite check in `ZMod 20`: every unit value of `x² + 5y²` is `1` or `9`. -/
theorem key20P : ∀ a b u : ZMod 20, u * (a ^ 2 + 5 * b ^ 2) = 1 →
    (a ^ 2 + 5 * b ^ 2) ∈ ({1, 9} : Finset (ZMod 20)) := by decide

/-- Finite check in `ZMod 20`: every unit value of `2x² + 2xy + 3y²` is `3` or `7`. -/
theorem key20Q : ∀ a b u : ZMod 20, u * (2 * a ^ 2 + 2 * a * b + 3 * b ^ 2) = 1 →
    (2 * a ^ 2 + 2 * a * b + 3 * b ^ 2) ∈ ({3, 7} : Finset (ZMod 20)) := by decide

theorem sound20 : ∀ (i : Bool) (N : ℤ), (∃ u : ZMod 20, u * (N : ZMod 20) = 1) →
    repr20 i N → ((N : ZMod 20) ∈ res20 i) := by
  rintro (_ | _) N ⟨u, hu⟩ ⟨x, y, rfl⟩
  · have h : ((x ^ 2 + 5 * y ^ 2 : ℤ) : ZMod 20) = (x : ZMod 20) ^ 2 + 5 * (y : ZMod 20) ^ 2 := by
      push_cast; ring
    rw [h] at hu ⊢
    exact key20P _ _ _ hu
  · have h : ((2 * x ^ 2 + 2 * x * y + 3 * y ^ 2 : ℤ) : ZMod 20)
        = 2 * (x : ZMod 20) ^ 2 + 2 * (x : ZMod 20) * (y : ZMod 20) + 3 * (y : ZMod 20) ^ 2 := by
      push_cast; ring
    rw [h] at hu ⊢
    exact key20Q _ _ _ hu

theorem disj20 : ∀ i j : Bool, i ≠ j → ∀ a : ZMod 20, a ∈ res20 i → a ∉ res20 j := by decide

/-- The discriminant `-20` residue dial. -/
def dial20 : ResidueDial 20 Bool where
  repr := repr20
  res := res20
  sound := sound20
  disj := disj20

/-! ## 3. Consequences for `D = -20`: exclusivity and the dial -/

theorem mod20_of_reprP {N : ℤ} (hN : IsCoprime N 20) (h : ReprP N) :
    (N : ZMod 20) = 1 ∨ (N : ZMod 20) = 9 := by
  have := sound20 false N (unit_cast_of_isCoprime (by exact_mod_cast hN)) h
  simpa [res20] using this

theorem mod20_of_reprQ {N : ℤ} (hN : IsCoprime N 20) (h : ReprQ N) :
    (N : ZMod 20) = 3 ∨ (N : ZMod 20) = 7 := by
  have := sound20 true N (unit_cast_of_isCoprime (by exact_mod_cast hN)) h
  simpa [res20] using this

/-- No integer coprime to `20` is represented by both reduced forms of
discriminant `-20`. -/
theorem not_reprP_and_reprQ {N : ℤ} (hN : IsCoprime N 20) : ¬(ReprP N ∧ ReprQ N) := by
  rintro ⟨hP, hQ⟩
  have h : (false : Bool) = true :=
    dial20.index_unique (unit_cast_of_isCoprime (by exact_mod_cast hN)) hP hQ
  exact Bool.false_ne_true h

/-- **Residue dial for `D = -20`.**  Which of the two classes represents `N` is a
function of `N mod 20`: if `N ≡ M (mod 20)` (both coprime to `20`) then they are
represented by the same class. -/
theorem dial20_factor_blind {N M : ℤ} (hN : IsCoprime N 20) (hM : IsCoprime M 20)
    (hres : (N : ZMod 20) = (M : ZMod 20)) {i j : Bool}
    (hi : repr20 i N) (hj : repr20 j M) : i = j :=
  dial20.factor_blind (unit_cast_of_isCoprime (by exact_mod_cast hN))
    (unit_cast_of_isCoprime (by exact_mod_cast hM)) hres hi hj

/-- The explicit dial function for `D = -20`. -/
theorem dial20_readout {N : ℤ} {i : Bool} (hN : IsCoprime N 20) (hi : repr20 i N) :
    dial20.readout (N : ZMod 20) = i :=
  dial20.readout_eq (unit_cast_of_isCoprime (by exact_mod_cast hN)) hi

/-! ## 4. Gauss composition: the class group is `ℤ/2` -/

/-- **Composition law.**  The set of integers represented by the forms of
discriminant `-20` is closed under multiplication, and the class index adds in
`ℤ/2` (here: `Bool` with `xor`).  Proved by explicit bilinear identities
(Brahmagupta for `P·P`, and the `2Q(x,y) = P(2x+y, y)` trick for the rest). -/
theorem comp20 : ∀ (i j : Bool) (a b : ℤ), repr20 i a → repr20 j b →
    repr20 (xor i j) (a * b) := by
  rintro (_ | _) (_ | _) a b <;> simp only [repr20, ReprP, ReprQ, Bool.xor_false,
    Bool.xor_true, Bool.not_false, Bool.not_true] <;>
    rintro ⟨x, y, rfl⟩ ⟨u, v, rfl⟩
  · exact ⟨x * u - 5 * y * v, x * v + y * u, by ring⟩
  · exact ⟨x * u - y * u - 3 * y * v, x * v + 2 * y * u + y * v, by ring⟩
  · exact ⟨u * x - v * x - 3 * v * y, u * y + 2 * v * x + v * y, by ring⟩
  · exact ⟨2 * x * u + x * v + y * u - 2 * y * v, x * v + y * v + y * u, by ring⟩

/-- `P · P = P` (Brahmagupta). -/
theorem reprP_mul_reprP {a b : ℤ} (ha : ReprP a) (hb : ReprP b) : ReprP (a * b) :=
  comp20 false false a b ha hb

/-- `Q · Q = P`: the non-principal class squares to the principal one. -/
theorem reprQ_mul_reprQ {a b : ℤ} (ha : ReprQ a) (hb : ReprQ b) : ReprP (a * b) :=
  comp20 true true a b ha hb

/-- `P · Q = Q`. -/
theorem reprP_mul_reprQ {a b : ℤ} (ha : ReprP a) (hb : ReprQ b) : ReprQ (a * b) :=
  comp20 false true a b ha hb

/-! ## 5. The refutation: PP and NN semiprimes are indistinguishable -/

open Classical in
/-- The observation available to a would-be factoring algorithm: which reduced
forms of discriminant `-20` represent `N`. -/
noncomputable def obs (N : ℤ) : Bool × Bool := (decide (ReprP N), decide (ReprQ N))

/-- A semiprime whose two prime factors are both *principal* ("PP") and a
semiprime whose two prime factors are both *non-principal* ("NN") produce the
**same** observation vector `(true, false)`.  The extrinsic class-group data
carries no information separating the two factorisation types. -/
theorem obs_pp_eq_obs_nn {p q p' q' : ℤ}
    (hp : ReprP p) (hq : ReprP q) (hp' : ReprQ p') (hq' : ReprQ q')
    (h1 : IsCoprime (p * q) 20) (h2 : IsCoprime (p' * q') 20) :
    obs (p * q) = (true, false) ∧ obs (p' * q') = (true, false) := by
  classical
  have hPP : ReprP (p * q) := reprP_mul_reprP hp hq
  have hNN : ReprP (p' * q') := reprQ_mul_reprQ hp' hq'
  have hQ1 : ¬ ReprQ (p * q) := fun h => not_reprP_and_reprQ h1 ⟨hPP, h⟩
  have hQ2 : ¬ ReprQ (p' * q') := fun h => not_reprP_and_reprQ h2 ⟨hNN, h⟩
  constructor
  · simp [obs, hPP, hQ1]
  · simp [obs, hNN, hQ2]

/-- **Sharp reading of the dial.**  For `N` coprime to `20` that is represented
at all, representability by the principal form is *equivalent* to a condition on
`N mod 20`. -/
theorem reprP_iff_residue {N : ℤ} (hN : IsCoprime N 20) (h : ReprP N ∨ ReprQ N) :
    ReprP N ↔ ((N : ZMod 20) = 1 ∨ (N : ZMod 20) = 9) := by
  refine ⟨mod20_of_reprP hN, fun hres => ?_⟩
  rcases h with hP | hQ
  · exact hP
  · exfalso
    rcases hres with hr | hr <;> rcases mod20_of_reprQ hN hQ with h' | h' <;>
      rw [hr] at h' <;> exact absurd h' (by decide)

/-- The same for the non-principal form. -/
theorem reprQ_iff_residue {N : ℤ} (hN : IsCoprime N 20) (h : ReprP N ∨ ReprQ N) :
    ReprQ N ↔ ((N : ZMod 20) = 3 ∨ (N : ZMod 20) = 7) := by
  refine ⟨mod20_of_reprQ hN, fun hres => ?_⟩
  rcases h with hP | hQ
  · exfalso
    rcases hres with hr | hr <;> rcases mod20_of_reprP hN hP with h' | h' <;>
      rw [hr] at h' <;> exact absurd h' (by decide)
  · exact hQ

/-- **The observation vector is a function of `N mod 20`.**  Two integers coprime
to `20`, each represented by some class, with the same residue, are reported
identically.  This is the formal content of "the vector is a pure residue dial". -/
theorem obs_eq_of_residue_eq {N M : ℤ} (hN : IsCoprime N 20) (hM : IsCoprime M 20)
    (hrN : ReprP N ∨ ReprQ N) (hrM : ReprP M ∨ ReprQ M)
    (hres : (N : ZMod 20) = (M : ZMod 20)) : obs N = obs M := by
  classical
  have hP : ReprP N ↔ ReprP M := by
    rw [reprP_iff_residue hN hrN, reprP_iff_residue hM hrM, hres]
  have hQ : ReprQ N ↔ ReprQ M := by
    rw [reprQ_iff_residue hN hrN, reprQ_iff_residue hM hrM, hres]
  simp only [obs, Prod.mk.injEq, decide_eq_decide]
  exact ⟨hP, hQ⟩

/-- Moreover the two products land in the same *pair* of residue classes
`{1, 9} (mod 20)`: even the residue is not separating. -/
theorem residue_pp_nn {p q p' q' : ℤ}
    (hp : ReprP p) (hq : ReprP q) (hp' : ReprQ p') (hq' : ReprQ q')
    (h1 : IsCoprime (p * q) 20) (h2 : IsCoprime (p' * q') 20) :
    ((p * q : ℤ) : ZMod 20) ∈ ({1, 9} : Finset (ZMod 20)) ∧
      ((p' * q' : ℤ) : ZMod 20) ∈ ({1, 9} : Finset (ZMod 20)) := by
  refine ⟨?_, ?_⟩
  · simpa [res20] using sound20 false _ (unit_cast_of_isCoprime (by exact_mod_cast h1))
      (reprP_mul_reprP hp hq)
  · simpa [res20] using sound20 false _ (unit_cast_of_isCoprime (by exact_mod_cast h2))
      (reprQ_mul_reprQ hp' hq')

/-- A mixed ("PN") semiprime is the only type the dial can see — and it is
already visible in `N mod 20`, i.e. it needs no factorisation knowledge. -/
theorem obs_pn {p q : ℤ} (hp : ReprP p) (hq : ReprQ q) (h : IsCoprime (p * q) 20) :
    obs (p * q) = (false, true) := by
  classical
  have hPQ : ReprQ (p * q) := reprP_mul_reprQ hp hq
  have hP : ¬ ReprP (p * q) := fun h' => not_reprP_and_reprQ h ⟨h', hPQ⟩
  simp [obs, hPQ, hP]

/-- Non-vacuity of the collision, with concrete primes: `29 = 3² + 5·2²` and
`41 = 6² + 5·1²` are principal, `3` and `7` are not, and the two semiprimes
`1189 = 29·41` (PP) and `21 = 3·7` (NN) are reported identically. -/
theorem obs_1189_eq_obs_21 : obs 1189 = obs 21 := by
  obtain ⟨h1, h2⟩ := obs_pp_eq_obs_nn (p := 29) (q := 41) (p' := 3) (q' := 7)
    ⟨3, 2, by norm_num⟩ ⟨6, 1, by norm_num⟩ ⟨0, 1, by norm_num⟩ ⟨1, 1, by norm_num⟩
    ⟨9, -535, by norm_num⟩ ⟨1, -1, by norm_num⟩
  norm_num at h1 h2
  rw [h1, h2]

/-! ## 6. Why the collision is unavoidable: the dial is a quadratic character -/

/-- The four residues mod `20` that occur at all (`(D/N) = 1`). -/
def D20 : Finset (ZMod 20) := {1, 3, 7, 9}

/-- The dial bit: `false` = principal class, `true` = non-principal class. -/
def dialBit (a : ZMod 20) : Bool := !(a = 1 || a = 9)

/-- `D20` is closed under multiplication (it is the subgroup of `(ZMod 20)ˣ`
cut out by `(D/·) = 1`). -/
theorem D20_mul_mem : ∀ a b : ZMod 20, a ∈ D20 → b ∈ D20 → a * b ∈ D20 := by decide

/-- **The dial is a character.**  On `D20` the dial bit is multiplicative:
`dialBit (ab) = dialBit a ⊕ dialBit b`.  This is the algebraic root of the
collapse: the observation is a homomorphism to `ℤ/2`. -/
theorem dialBit_mul : ∀ a b : ZMod 20, a ∈ D20 → b ∈ D20 →
    dialBit (a * b) = xor (dialBit a) (dialBit b) := by decide

/-- **A character is blind to squares.**  Whatever the class of `p`, a product of
two integers in the *same* class reads as principal — so "PP" and "NN" can never
be separated by this observation. -/
theorem dialBit_sq (a : ZMod 20) (ha : a ∈ D20) : dialBit (a * a) = false := by
  rw [dialBit_mul a a ha ha]
  exact Bool.xor_self _

/-- The dial bit of an actual integer agrees with the class index. -/
theorem dialBit_eq_index {N : ℤ} {i : Bool} (hN : IsCoprime N 20) (hi : repr20 i N) :
    dialBit ((N : ℤ) : ZMod 20) = i := by
  have h := sound20 i N (unit_cast_of_isCoprime (by exact_mod_cast hN)) hi
  cases i <;> revert h <;> simp only [res20] <;> revert hN <;> intro _ <;>
    generalize ((N : ℤ) : ZMod 20) = a <;> revert a <;> decide

/-! ## 7. Lab notes: exact representation counts

The experiment reported the signature `(8, 0)` for semiprimes `N ≡ 1, 9 (mod 20)`
whose prime factors are split, *independently of the PP/NN type*.  Here are three
certified instances:

| `N`    | factorisation | type | `r_P(N)` | `r_Q(N)` |
|--------|---------------|------|----------|----------|
| `21`   | `3 · 7`       | NN   | `8`      | `0`      |
| `1189` | `29 · 41`     | PP   | `8`      | `0`      |
| `87`   | `3 · 29`      | PN   | `0`      | `8`      |
-/

/-- All representations of `N` by `x² + 5y²` inside an explicit box. -/
def boxP (N Bx By : ℤ) : Finset (ℤ × ℤ) :=
  ((Finset.Icc (-Bx) Bx) ×ˢ (Finset.Icc (-By) By)).filter (fun p => p.1 ^ 2 + 5 * p.2 ^ 2 = N)

/-- All representations of `N` by `2x² + 2xy + 3y²` inside an explicit box. -/
def boxQ (N Bx By : ℤ) : Finset (ℤ × ℤ) :=
  ((Finset.Icc (-Bx) Bx) ×ˢ (Finset.Icc (-By) By)).filter
    (fun p => 2 * p.1 ^ 2 + 2 * p.1 * p.2 + 3 * p.2 ^ 2 = N)

/-- The box `[-Bx, Bx] × [-By, By]` captures *all* representations by `P`
as soon as `N ≤ Bx²` and `N ≤ 5By²`. -/
theorem repsP_eq_boxP (N Bx By : ℤ) (hBx : N ≤ Bx ^ 2) (hBy : N ≤ 5 * By ^ 2)
    (hBx0 : 0 ≤ Bx) (hBy0 : 0 ≤ By) :
    {p : ℤ × ℤ | p.1 ^ 2 + 5 * p.2 ^ 2 = N} = ↑(boxP N Bx By) := by
  ext ⟨x, y⟩
  simp only [Set.mem_setOf_eq, boxP, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_product,
    Finset.mem_Icc]
  constructor
  · intro h
    refine ⟨⟨⟨?_, ?_⟩, ?_, ?_⟩, h⟩
    · nlinarith [sq_nonneg y, sq_nonneg (x + Bx)]
    · nlinarith [sq_nonneg y, sq_nonneg (x - Bx)]
    · nlinarith [sq_nonneg x, sq_nonneg (y + By)]
    · nlinarith [sq_nonneg x, sq_nonneg (y - By)]
  · tauto

/-- The box `[-Bx, Bx] × [-By, By]` captures all representations by `Q`
as soon as `2N ≤ Bx²` and `2N ≤ 5By²` (using `2Q(x,y) = (2x+y)² + 5y²`). -/
theorem repsQ_eq_boxQ (N Bx By : ℤ) (hBx : 2 * N ≤ Bx ^ 2) (hBy : 2 * N ≤ 5 * By ^ 2)
    (hBx0 : 0 ≤ Bx) (hBy0 : 0 ≤ By) :
    {p : ℤ × ℤ | 2 * p.1 ^ 2 + 2 * p.1 * p.2 + 3 * p.2 ^ 2 = N} = ↑(boxQ N Bx By) := by
  ext ⟨x, y⟩
  simp only [Set.mem_setOf_eq, boxQ, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_product,
    Finset.mem_Icc]
  constructor
  · intro h
    refine ⟨⟨⟨?_, ?_⟩, ?_, ?_⟩, h⟩
    · nlinarith [sq_nonneg (x + y), sq_nonneg y, sq_nonneg (x + Bx)]
    · nlinarith [sq_nonneg (x + y), sq_nonneg y, sq_nonneg (x - Bx)]
    · nlinarith [sq_nonneg (2 * x + y), sq_nonneg (y + By)]
    · nlinarith [sq_nonneg (2 * x + y), sq_nonneg (y - By)]
  · tauto

/-- A fixed-point-free involution halves a finite set: the counting device behind
the unit action `{±1}` on representations. -/
theorem card_eq_two_mul_of_involutive {S : Finset (ℤ × ℤ)} (g : ℤ × ℤ → ℤ × ℤ)
    (hinv : ∀ p, g (g p) = p) (hgS : ∀ p ∈ S, g p ∈ S)
    (P : ℤ × ℤ → Prop) [DecidablePred P] (hgP : ∀ p ∈ S, (P p ↔ ¬ P (g p))) :
    S.card = 2 * (S.filter P).card := by
  classical
  have hginj : Function.Injective g := Function.LeftInverse.injective hinv
  have himg : (S.filter P).image g = S.filter (fun q => ¬ P q) := by
    ext q
    simp only [Finset.mem_image, Finset.mem_filter]
    constructor
    · rintro ⟨p, ⟨hpS, hp⟩, rfl⟩
      exact ⟨hgS p hpS, (hgP p hpS).mp hp⟩
    · rintro ⟨hqS, hq⟩
      refine ⟨g q, ⟨hgS q hqS, ?_⟩, hinv q⟩
      have h := hgP (g q) (hgS q hqS)
      rw [hinv q] at h
      exact h.mpr hq
  have hcard : (S.filter (fun q => ¬ P q)).card = (S.filter P).card := by
    rw [← himg, Finset.card_image_of_injective _ hginj]
  have := Finset.card_filter_add_card_filter_not (s := S) (p := P)
  omega

/-- **The unit action is free.**  If `N` is coprime to `20` and is not a perfect
square, then no representation `N = x² + 5y²` has `x = 0` or `y = 0`, so the four
sign changes `(±x, ±y)` are distinct: the number of representations is divisible
by `4`.  (This is the `4` in the observed `8 = 4 · 2`: two ideal factorisations,
four units.) -/
theorem four_dvd_boxP_card {N : ℤ} (hN : IsCoprime N 20) (hsq : ∀ k : ℤ, k ^ 2 ≠ N)
    (Bx By : ℤ) : 4 ∣ (boxP N Bx By).card := by
  classical
  have hmem : ∀ p ∈ boxP N Bx By, (-Bx ≤ p.1 ∧ p.1 ≤ Bx) ∧ (-By ≤ p.2 ∧ p.2 ≤ By) ∧
      p.1 ^ 2 + 5 * p.2 ^ 2 = N := by
    intro p hp
    simp only [boxP, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc] at hp
    exact ⟨hp.1.1, hp.1.2, hp.2⟩
  have hne : ∀ p ∈ boxP N Bx By, p.1 ≠ 0 ∧ p.2 ≠ 0 := by
    intro p hp
    obtain ⟨-, -, heq⟩ := hmem p hp
    constructor
    · rintro h0
      obtain ⟨a, b, hab⟩ := hN
      have h5 : (5 : ℤ) ∣ N := ⟨p.2 ^ 2, by rw [← heq, h0]; ring⟩
      have h1 : (5 : ℤ) ∣ 1 := by
        rw [← hab]
        exact dvd_add (Dvd.dvd.mul_left h5 a) ⟨4 * b, by ring⟩
      norm_num at h1
    · rintro h0
      exact hsq p.1 (by rw [← heq, h0]; ring)
  set S := boxP N Bx By with hS
  have h1 : S.card = 2 * (S.filter (fun p => 0 < p.1)).card := by
    refine card_eq_two_mul_of_involutive (fun p => (-p.1, p.2)) (by intro p; simp) ?_ _ ?_
    · intro p hp
      obtain ⟨⟨hx1, hx2⟩, ⟨hy1, hy2⟩, heq⟩ := hmem p hp
      simp only [hS, boxP, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
      exact ⟨⟨⟨by omega, by omega⟩, by omega, by omega⟩, by rw [← heq]; ring⟩
    · intro p hp
      have := (hne p hp).1
      simp only
      omega
  have h2 : (S.filter (fun p => 0 < p.1)).card
      = 2 * ((S.filter (fun p => 0 < p.1)).filter (fun p => 0 < p.2)).card := by
    refine card_eq_two_mul_of_involutive (fun p => (p.1, -p.2)) (by intro p; simp) ?_ _ ?_
    · intro p hp
      simp only [Finset.mem_filter] at hp ⊢
      obtain ⟨⟨hx1, hx2⟩, ⟨hy1, hy2⟩, heq⟩ := hmem p hp.1
      refine ⟨?_, hp.2⟩
      simp only [hS, boxP, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
      exact ⟨⟨⟨by omega, by omega⟩, by omega, by omega⟩, by rw [← heq]; ring⟩
    · intro p hp
      have := (hne p (Finset.mem_filter.mp hp).1).2
      simp only
      omega
  omega

/-- The same statement for the full (infinite-ambient) representation set. -/
theorem four_dvd_repP_ncard {N : ℤ} (hN0 : 0 < N) (hN : IsCoprime N 20)
    (hsq : ∀ k : ℤ, k ^ 2 ≠ N) : 4 ∣ {p : ℤ × ℤ | p.1 ^ 2 + 5 * p.2 ^ 2 = N}.ncard := by
  rw [repsP_eq_boxP N N N (by nlinarith) (by nlinarith) (by omega) (by omega),
    Set.ncard_coe_finset]
  exact four_dvd_boxP_card hN hsq N N

/-- `r_P(21) = 8`:  `21 = 3 · 7` is an **NN** semiprime. -/
theorem reps_21_ncard : {p : ℤ × ℤ | p.1 ^ 2 + 5 * p.2 ^ 2 = 21}.ncard = 8 := by
  rw [repsP_eq_boxP 21 5 3 (by norm_num) (by norm_num) (by norm_num) (by norm_num),
    Set.ncard_coe_finset]
  decide

/-- `r_Q(21) = 0`. -/
theorem reps_21_Q_ncard : {p : ℤ × ℤ | 2 * p.1 ^ 2 + 2 * p.1 * p.2 + 3 * p.2 ^ 2 = 21}.ncard = 0 := by
  rw [repsQ_eq_boxQ 21 7 4 (by norm_num) (by norm_num) (by norm_num) (by norm_num),
    Set.ncard_coe_finset]
  decide

set_option maxRecDepth 20000 in
/-- `r_P(1189) = 8`:  `1189 = 29 · 41` is a **PP** semiprime — the *same*
vector as the NN semiprime `21`. -/
theorem reps_1189_ncard : {p : ℤ × ℤ | p.1 ^ 2 + 5 * p.2 ^ 2 = 1189}.ncard = 8 := by
  rw [repsP_eq_boxP 1189 35 16 (by norm_num) (by norm_num) (by norm_num) (by norm_num),
    Set.ncard_coe_finset]
  decide

/-- `r_Q(87) = 8` for the mixed semiprime `87 = 3 · 29`. -/
theorem reps_87_ncard :
    {p : ℤ × ℤ | 2 * p.1 ^ 2 + 2 * p.1 * p.2 + 3 * p.2 ^ 2 = 87}.ncard = 8 := by
  rw [repsQ_eq_boxQ 87 14 6 (by norm_num) (by norm_num) (by norm_num) (by norm_num),
    Set.ncard_coe_finset]
  decide

/-- `r_P(87) = 0`. -/
theorem reps_87_P_ncard : {p : ℤ × ℤ | p.1 ^ 2 + 5 * p.2 ^ 2 = 87}.ncard = 0 := by
  rw [repsP_eq_boxP 87 10 5 (by norm_num) (by norm_num) (by norm_num) (by norm_num),
    Set.ncard_coe_finset]
  decide

end ClassGroupResidueDial