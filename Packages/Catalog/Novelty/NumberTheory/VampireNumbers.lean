import Mathlib

/-!
# A Bestiary of Arithmetic Monsters: Vampire Numbers and their Congruences

A *vampire number* is a composite number `v` with an even number of digits that
factors as `v = x * y`, where the two *fangs* `x` and `y` together use exactly
the same multiset of digits as `v` (the smallest is `1260 = 21 * 60`).  This file
sets up a small "bestiary" of digit-based arithmetic creatures — vampires,
werewolves, ghosts, and zombies — and, more importantly, proves the *arithmetic
law* that every same-digit factorization must obey.

## The central law

The defining relation of a vampire number is that the digits of `x * y` are a
*permutation* of the digits of `x` followed by the digits of `y`.  Digit
permutations preserve digit sums, and in base `b` a number is congruent to its
digit sum modulo `b - 1` (casting out nines when `b = 10`).  Combining these two
facts yields a genuine necessary condition that is *independent of the actual
digits*:

* `fangPair_prod_modEq` : `x * y ≡ x + y [MOD (b - 1)]`.

Reformulated over `ℤ` this says `(x - 1)(y - 1) ≡ 1 [ZMOD (b - 1)]`, i.e. each
fang minus one is a *unit* modulo `b - 1` (see `VampireCongruence.lean`).  In base
`10` this forces a divisibility obstruction on the fangs:

* `fang_factor_not_one_mod_three` : neither fang is `≡ 1 (mod 3)`.

Finally the law generalizes from two fangs to arbitrarily many:

* `fangList_prod_modEq` : for a list `L` of factors whose combined digits are a
  permutation of the digits of the product, `L.prod ≡ L.sum [MOD (b - 1)]`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): brainstormed conjectures about vampire numbers.
(H1) The advertised density law `~ 1/√n` and "every even interval contains a
vampire" are asymptotic/enumeration statements that are effectively as hard as
controlling factorizations of random integers — not provable here.  (H2, kept)
*Every* same-digit factorization satisfies a fixed congruence `xy ≡ x+y` mod
`b-1`, because a digit permutation preserves digit sums and `n ≡ digitsum(n)`
mod `b-1`.  This is surprising: it is a constraint on the *values* `x,y` extracted
purely from a *combinatorial* digit condition.  (H3, surprising) The congruence
forbids a fang `≡ 1 (mod 3)` in base 10, so e.g. no vampire has a fang that is
`1, 4, 7, 10, 13, …` mod 3 — checked against `1260 = 21·60` (21,60 ≡ 0 mod 3).
(H4) The law is not special to two factors; it holds for any number of fangs.

Experiment (Experimenter): computed `Nat.digits 10 1260 = [0,6,2,1]` and verified
the permutation `[0,6,2,1] ~ [1,2] ++ [0,6]` by `decide`; checked `21·60 = 1260`,
`21+60 = 81 ≡ 0 [MOD 9]`, `1260 ≡ 0 [MOD 9]`.  Checked H3 numerically on the
fangs of `1260`.

Analysis (Analyst): H2 reduces to `Nat.modEq_digits_sum` plus `List.Perm.sum_eq`.
H3 is a clean `mod 3` corollary via `Nat.ModEq.of_dvd (3 ∣ 9)`.  H4 needs a small
induction (`flatMap_digits_sum_modEq`).  The density conjecture H1 is left as a
future direction — it is "true-but-hard", not formalizable at this granularity.

Critique (Critic): the theorems are not `decide`/`native_decide` shells — they
are quantified over all `x, y` (and all bases `b ≥ 2`), and their proofs use
`calc`, `omega`, induction, and `Nat.ModEq` algebra.  Corner case `b = 2`
(modulus `b - 1 = 1`) is handled separately in `digits_sum_modEq`.

Synthesis: the "vampire law" `xy ≡ x+y (mod b-1)` and its unit reformulation are
the stable mathematical core of the bestiary; the ecological/density claims are
downstream conjectures.
-- !-- end Lab Notes -- !--
-/

namespace Bestiary

/-- The **fang relation** in base `b`: the digits of the product `x * y` are a
permutation of the digits of `x` together with the digits of `y`.  This is the
defining combinatorial condition behind vampire numbers. -/
def IsFangPair (b x y : ℕ) : Prop :=
  (Nat.digits b (x * y)).Perm (Nat.digits b x ++ Nat.digits b y)

/-- The multi-factor generalization of the fang relation: the digits of the
product `L.prod` are a permutation of all the digits of all factors in `L`. -/
def IsFangList (b : ℕ) (L : List ℕ) : Prop :=
  (Nat.digits b L.prod).Perm (L.flatMap (Nat.digits b))

/-- **Casting out nines, general base.**  In base `b ≥ 2`, every natural number is
congruent to the sum of its base-`b` digits modulo `b - 1`. -/
theorem digits_sum_modEq (b n : ℕ) (hb : 2 ≤ b) :
    n ≡ (Nat.digits b n).sum [MOD (b - 1)] := by
  rcases eq_or_lt_of_le hb with h | h
  · -- `b = 2` : modulus `b - 1 = 1`, so the congruence is trivial.
    subst h; simpa using (Nat.modEq_one)
  · -- `b ≥ 3` : `b % (b - 1) = 1`, so `Nat.modEq_digits_sum` applies.
    have hmod : b % (b - 1) = 1 := by
      have key : (b - 1) + 1 = b := by omega
      calc b % (b - 1) = ((b - 1) + 1) % (b - 1) := by rw [key]
        _ = 1 % (b - 1) := Nat.add_mod_left _ _
        _ = 1 := Nat.mod_eq_of_lt (by omega)
    simpa using Nat.modEq_digits_sum (b - 1) b hmod n

/-- **The vampire law (two fangs).**  Any same-digit factorization `x * y`
satisfies `x * y ≡ x + y` modulo `b - 1`.  The proof extracts a *value*
congruence from a purely *combinatorial* digit condition: a digit permutation
preserves digit sums, and each number is congruent to its digit sum mod `b - 1`. -/
theorem fangPair_prod_modEq (b x y : ℕ) (hb : 2 ≤ b) (h : IsFangPair b x y) :
    x * y ≡ x + y [MOD (b - 1)] := by
  have hsum : (Nat.digits b (x * y)).sum
      = (Nat.digits b x).sum + (Nat.digits b y).sum := by
    have := h.sum_eq; simpa [List.sum_append] using this
  calc x * y ≡ (Nat.digits b (x * y)).sum [MOD (b - 1)] := digits_sum_modEq b _ hb
    _ = (Nat.digits b x).sum + (Nat.digits b y).sum := hsum
    _ ≡ x + y [MOD (b - 1)] :=
        ((digits_sum_modEq b x hb).add (digits_sum_modEq b y hb)).symm

/-- Sum of all digits of all list entries is congruent to the sum of the entries,
modulo `b - 1` (the inductive engine behind the multi-fang law). -/
theorem flatMap_digits_sum_modEq (b : ℕ) (hb : 2 ≤ b) : ∀ L : List ℕ,
    (L.flatMap (Nat.digits b)).sum ≡ L.sum [MOD (b - 1)]
  | [] => by simp [Nat.ModEq]
  | a :: t => by
      simp only [List.flatMap_cons, List.sum_append, List.sum_cons]
      exact (digits_sum_modEq b a hb).symm.add (flatMap_digits_sum_modEq b hb t)

/-- **The vampire law (arbitrarily many fangs).**  If the combined digits of a
list of factors `L` form a permutation of the digits of their product, then
`L.prod ≡ L.sum [MOD (b - 1)]`.  Specializing to a two-element list recovers
`fangPair_prod_modEq`. -/
theorem fangList_prod_modEq (b : ℕ) (hb : 2 ≤ b) (L : List ℕ) (h : IsFangList b L) :
    L.prod ≡ L.sum [MOD (b - 1)] :=
  calc L.prod ≡ (Nat.digits b L.prod).sum [MOD (b - 1)] := digits_sum_modEq b _ hb
    _ = (L.flatMap (Nat.digits b)).sum := h.sum_eq
    _ ≡ L.sum [MOD (b - 1)] := flatMap_digits_sum_modEq b hb L

/-- Base-10 specialization: a vampire number `v = x * y` satisfies the
"casting out nines" law `v ≡ x + y [MOD 9]`. -/
theorem vampire_congr {v x y : ℕ} (h : IsFangPair 10 x y) (hv : v = x * y) :
    v ≡ x + y [MOD 9] := by
  subst hv; simpa using fangPair_prod_modEq 10 x y (by norm_num) h

/-- **Fang obstruction modulo 3.**  For a base-10 same-digit factorization,
neither fang is congruent to `1` modulo `3`.  (Equivalently, `x - 1` and `y - 1`
are units modulo `9`.)  Verified against `1260 = 21 · 60`: `21 ≡ 0`, `60 ≡ 0`
(mod 3). -/
theorem fang_factor_not_one_mod_three {x y : ℕ} (h : IsFangPair 10 x y) :
    x % 3 ≠ 1 ∧ y % 3 ≠ 1 := by
  have hc : x * y ≡ x + y [MOD 9] := fangPair_prod_modEq 10 x y (by norm_num) h
  have h3 : x * y ≡ x + y [MOD 3] := hc.of_dvd (by norm_num)
  constructor
  · intro hx1
    have hxmod : x ≡ 1 [MOD 3] := by unfold Nat.ModEq; simpa using hx1
    have e1 : x * y ≡ 1 * y [MOD 3] := hxmod.mul_right y
    have e2 : x + y ≡ 1 + y [MOD 3] := hxmod.add_right y
    have hchain : (1 * y) ≡ (1 + y) [MOD 3] := (e1.symm.trans h3).trans e2
    have hy : (1 * y) % 3 = (1 + y) % 3 := hchain
    omega
  · intro hy1
    have hymod : y ≡ 1 [MOD 3] := by unfold Nat.ModEq; simpa using hy1
    have e1 : x * y ≡ x * 1 [MOD 3] := hymod.mul_left x
    have e2 : x + y ≡ x + 1 [MOD 3] := hymod.add_left x
    have hchain : (x * 1) ≡ (x + 1) [MOD 3] := (e1.symm.trans h3).trans e2
    have hx : (x * 1) % 3 = (x + 1) % 3 := hchain
    omega

/-! ### The rest of the bestiary (faithful definitions)

These record the other "creatures" from the mission statement.  The main
theorems above apply to any `IsFangPair`/`IsFangList`; the definitions below are
kept for downstream enumeration and future work. -/

/-- A full **vampire number**: composite `v` with `2n` digits factoring as a fang
pair of two `n`-digit numbers, not both ending in `0`. -/
def IsVampire (v : ℕ) : Prop :=
  ∃ x y, 0 < x ∧ 0 < y ∧
    (Nat.digits 10 x).length = (Nat.digits 10 y).length ∧
    (Nat.digits 10 v).length = 2 * (Nat.digits 10 x).length ∧
    ¬ (x % 10 = 0 ∧ y % 10 = 0) ∧
    v = x * y ∧ IsFangPair 10 x y

/-- Digits shared between `v` and `x` (base 10). -/
def commonDigits (v x : ℕ) : Finset ℕ :=
  (Nat.digits 10 v).toFinset ∩ (Nat.digits 10 x).toFinset

/-- A **werewolf number**: `v = x * y` where the factors together share exactly
one digit with `v`. -/
def IsWerewolf (v : ℕ) : Prop :=
  ∃ x y, 0 < x ∧ 0 < y ∧ v = x * y ∧
    (commonDigits v x ∪ commonDigits v y).card = 1

/-- A **ghost number**: `v = x * y` (both factors `> 1`) sharing *no* digit with
either factor. -/
def IsGhost (v : ℕ) : Prop :=
  ∃ x y, 1 < x ∧ 1 < y ∧ v = x * y ∧
    Disjoint (Nat.digits 10 v).toFinset
      ((Nat.digits 10 x).toFinset ∪ (Nat.digits 10 y).toFinset)

/-- A **zombie number**: a fang pair `v = x * y` whose fangs are *both prime*
(these are exceptionally constrained — see the future directions). -/
def IsZombie (v : ℕ) : Prop :=
  ∃ x y, v = x * y ∧ x.Prime ∧ y.Prime ∧ IsFangPair 10 x y

/-! ### Concrete inhabitants (sanity checks, not main results) -/

/-- The smallest vampire number `1260 = 21 · 60` is a fang pair. -/
example : IsFangPair 10 21 60 := by unfold IsFangPair; decide

/-- Consequently `1260 ≡ 21 + 60 [MOD 9]`, i.e. `0 ≡ 0`. -/
example : (1260 : ℕ) ≡ 21 + 60 [MOD 9] :=
  vampire_congr (by unfold IsFangPair; decide) (by norm_num)

/-- `1260` is a genuine vampire number. -/
example : IsVampire 1260 :=
  ⟨21, 60, by norm_num, by norm_num, by decide, by decide, by decide, by norm_num,
    by unfold IsFangPair; decide⟩

/-- `12 = 3 · 4` is a ghost number: `{1,2}` shares no digit with `{3}` or `{4}`. -/
example : IsGhost 12 :=
  ⟨3, 4, by norm_num, by norm_num, by norm_num, by decide⟩

end Bestiary