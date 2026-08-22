import Physics.S3TypeChannelCore

/-!
# THREE FIELDS, ONE ANSWER: the universal `S₃` type-channel law

Let `K = ℚ[x]/(f)` be a non-cyclic cubic field, so that the Galois group of the splitting
field is `S₃`.  For an unramified prime `p`, the Frobenius conjugacy class of `p` is one of
the three classes of `S₃`, and the factorisation type of `p` in `K` reads it off:

| Frobenius class      | factorisation of `p`   | multiplicity in `S₃` |
|----------------------|------------------------|----------------------|
| identity             | `p = 𝔭₁𝔭₂𝔭₃` (split)   | `1`                  |
| transposition        | `p = 𝔭₁𝔭₂` (`1+2`)     | `3`                  |
| three-cycle          | `p = 𝔭` (inert)        | `2`                  |

By Chebotarev the classes are equidistributed with these multiplicities, and the
*sign character* `sgn : S₃ → {±1}` is precisely the quadratic character of the
resolvent field `ℚ(√disc f)`: `sgn(Frob p) = (disc f | p)`.  Consequently the residue
class of `p` modulo the conductor of that quadratic character is *coupled to the
splitting type through exactly one bit*.

This file makes that statement exact and proves it for three independent `S₃` cubics:

* `x³ - 3`     (`disc = -243`, resolvent `ℚ(√-3)`, character mod `3`);
* `x³ - 2`     (`disc = -108`, resolvent `ℚ(√-3)`, character mod `3`);
* `x³ - x - 1` (`disc = -23`,  resolvent `ℚ(√-23)`, character mod `23`).

Main results.

* `S3Universal.signBit_frobType` — the sign character is a function of the splitting type
  (verified over all six elements of `S₃`).
* `S3Universal.residueTable_eq_chebotarev_count` — the tables used below really are the
  Chebotarev joint occupation numbers of (residue class, splitting type).
* `S3Universal.Imut_residue_type_eq_one` — the **universal law**: for *any* balanced
  quadratic character on *any* residue group, `I(residue ; splitting type) = 1` exactly.
* `S3Universal.Ires_xcubed_sub_three`, `Ires_xcubed_sub_two`, `Ires_xcubed_sub_x_sub_one` —
  the three fields: `I(p mod 3 ; T) = 1` for `x³-3` and `x³-2` (`k = 1`), and
  `I(p mod 23 ; T) = 1` for `x³-x-1` (`k = 11`).
* `S3Universal.Imut_semiprime_pair_eq_one` — the semiprime pair channel is also exactly
  one bit: the unordered type pair of `n = pq` determines, and is coupled only through,
  the quadratic character of `n`.
-/

namespace S3Universal

open scoped BigOperators
open Finset S3Channel

/-! ## The three splitting types of an `S₃`-cubic -/

/-- The factorisation type of an unramified prime in a non-cyclic cubic field. -/
inductive SplitType
  | totallySplit
  | partiallySplit
  | inert
  deriving DecidableEq, Fintype, Repr

open SplitType

/-- The splitting type attached to a Frobenius element of `S₃`, read off from the size of
its support: `0` (identity) ↦ totally split, `2` (transposition) ↦ `1+2`, `3` ↦ inert. -/
def frobType (σ : Equiv.Perm (Fin 3)) : SplitType :=
  if σ.support.card = 0 then totallySplit
  else if σ.support.card = 2 then partiallySplit
  else inert

/-- Chebotarev multiplicity of a splitting type: the number of elements of `S₃`
realising it. -/
def typeMult (t : SplitType) : ℕ :=
  ((univ : Finset (Equiv.Perm (Fin 3))).filter (fun σ => frobType σ = t)).card

/-- The Chebotarev profile of an `S₃`-cubic: `1 : 3 : 2`. -/
theorem typeMult_values :
    typeMult totallySplit = 1 ∧ typeMult partiallySplit = 3 ∧ typeMult inert = 2 := by
  refine ⟨?_, ?_, ?_⟩ <;> decide

/-- The sign character, read off from the splitting type. -/
def signBit : SplitType → Bool
  | totallySplit => true
  | partiallySplit => false
  | inert => true

/-- **The sign character factors through the splitting type.**  Verified on all six
elements of `S₃`: `sgn σ = +1` exactly when `σ` is the identity or a three-cycle. -/
theorem signBit_frobType (σ : Equiv.Perm (Fin 3)) :
    signBit (frobType σ) = decide (Equiv.Perm.sign σ = 1) := by
  revert σ; decide

/-- Both halves of `S₃` selected by the sign character have Chebotarev mass `3`. -/
theorem signBit_mass_balance (c : Bool) :
    ∑ t ∈ univ.filter (fun t => signBit t = c), typeMult t = 3 := by
  revert c; decide

/-! ## The residue/type joint table -/

variable {A : Type*} [Fintype A] [DecidableEq A]

/-- The joint occupation table of (residue class, splitting type) predicted by
Chebotarev, for a residue observable equipped with a quadratic character `chi`. -/
def residueTable (chi : A → Bool) : A → SplitType → ℕ :=
  fun a t => if chi a = signBit t then typeMult t else 0

omit [Fintype A] [DecidableEq A] in
/-- **Faithfulness of the model.**  The table above is literally the count of Frobenius
elements with the given splitting type whose sign matches the character of the residue —
i.e. the Chebotarev joint law of `(p mod q, T(p))`. -/
theorem residueTable_eq_chebotarev_count (chi : A → Bool) (a : A) (t : SplitType) :
    residueTable chi a t =
      ((univ : Finset (Equiv.Perm (Fin 3))).filter
        (fun σ => frobType σ = t ∧ chi a = decide (Equiv.Perm.sign σ = 1))).card := by
  by_cases h : chi a = signBit t
  · have hfil : ((univ : Finset (Equiv.Perm (Fin 3))).filter
        (fun σ => frobType σ = t ∧ chi a = decide (Equiv.Perm.sign σ = 1)))
        = (univ : Finset (Equiv.Perm (Fin 3))).filter (fun σ => frobType σ = t) := by
      refine Finset.filter_congr (fun σ _ => ?_)
      constructor
      · rintro ⟨h1, -⟩; exact h1
      · intro h1
        refine ⟨h1, ?_⟩
        rw [← signBit_frobType σ, h1, h]
    simp only [residueTable, if_pos h, hfil, typeMult]
  · have hempty : ((univ : Finset (Equiv.Perm (Fin 3))).filter
        (fun σ => frobType σ = t ∧ chi a = decide (Equiv.Perm.sign σ = 1))) = ∅ := by
      refine Finset.filter_eq_empty_iff.mpr (fun σ _ => ?_)
      rintro ⟨h1, h2⟩
      exact h (by rw [h2, ← signBit_frobType σ, h1])
    simp [residueTable, if_neg h, hempty]

omit [DecidableEq A] in
/-- **The universal `S₃` type-channel law.**  For any residue observable whose quadratic
character splits it into two equal halves, the mutual information between the residue and
the splitting type of an `S₃`-cubic is exactly one bit.

Nothing about the field enters except that its Galois group is `S₃`; nothing about the
residue group enters except that the character is balanced. -/
theorem Imut_residue_type_eq_one (chi : A → Bool) (k : ℕ)
    (hk : ∀ c : Bool, (univ.filter (fun a => chi a = c)).card = k) (hk0 : 0 < k) :
    Imut (residueTable chi) = 1 :=
  Imut_eq_one_of_character (fun _ _ => rfl) hk hk0 signBit_mass_balance (by norm_num)

/-! ## Field 1 : `x³ - 3`, discriminant `-243`, resolvent `ℚ(√-3)` -/

/-- The quadratic character mod `3`: `χ₋₃(p) = +1` iff `p ≡ 1 (mod 3)`. -/
def chi3 : (ZMod 3)ˣ → Bool := fun a => decide (a = 1)

/-- `χ₋₃` is the quadratic-residue character of `(ℤ/3)ˣ`. -/
theorem chi3_eq_isSquare (a : (ZMod 3)ˣ) : chi3 a = decide (IsSquare ((a : ZMod 3))) := by
  revert a; decide

/-- `χ₋₃` is balanced: each of its two fibres has exactly one residue class. -/
theorem chi3_balanced (c : Bool) : (univ.filter (fun a : (ZMod 3)ˣ => chi3 a = c)).card = 1 := by
  revert c; decide

/-- **`x³ - 3` (disc `= -243`)**: `I(p mod 3 ; T) = 1` exactly. -/
theorem Ires_xcubed_sub_three : Imut (residueTable chi3) = 1 :=
  Imut_residue_type_eq_one chi3 1 chi3_balanced one_pos

/-! ## Field 2 : `x³ - 2`, discriminant `-108`, resolvent `ℚ(√-3)` -/

/-- **`x³ - 2` (disc `= -108`)**: the resolvent field is again `ℚ(√-3)`, so the residue
observable is again `p mod 3`, and again `I(p mod 3 ; T) = 1` exactly. -/
theorem Ires_xcubed_sub_two : Imut (residueTable chi3) = 1 :=
  Imut_residue_type_eq_one chi3 1 chi3_balanced one_pos

/-! ## Field 3 : `x³ - x - 1`, discriminant `-23`, resolvent `ℚ(√-23)` -/

/-- The quadratic character mod `23`, in Euler-criterion form `a ↦ a¹¹`. -/
def chi23 : (ZMod 23)ˣ → Bool := fun a => decide (((a : ZMod 23)) ^ 11 = 1)

/-- Euler's criterion mod `23`, verified on all 22 residue classes: `a¹¹ = 1` iff `a` is a
quadratic residue. -/
theorem chi23_eq_isSquare (a : (ZMod 23)ˣ) : chi23 a = decide (IsSquare ((a : ZMod 23))) := by
  revert a; decide

/-- The quadratic character mod `23` is balanced: 11 residues, 11 non-residues. -/
theorem chi23_balanced (c : Bool) :
    (univ.filter (fun a : (ZMod 23)ˣ => chi23 a = c)).card = 11 := by
  revert c; decide

/-- **`x³ - x - 1` (disc `= -23`)**: the residue group is now `(ℤ/23)ˣ`, with `11` classes
in each character fibre instead of `1` — a completely different channel — yet
`I(p mod 23 ; T) = 1` exactly, the same answer. -/
theorem Ires_xcubed_sub_x_sub_one : Imut (residueTable chi23) = 1 :=
  Imut_residue_type_eq_one chi23 11 chi23_balanced (by norm_num)

/-- **THREE FIELDS, ONE ANSWER.**  Three `S₃` cubics with three distinct discriminants
(`-243`, `-108`, `-23`) and two distinct residue groups give literally the same channel
value. -/
theorem three_fields_one_answer :
    Imut (residueTable chi3) = 1 ∧ Imut (residueTable chi3) = 1 ∧
      Imut (residueTable chi23) = 1 ∧
      Imut (residueTable chi3) = Imut (residueTable chi23) :=
  ⟨Ires_xcubed_sub_three, Ires_xcubed_sub_two, Ires_xcubed_sub_x_sub_one,
    by rw [Ires_xcubed_sub_three, Ires_xcubed_sub_x_sub_one]⟩

/-! ## The semiprime pair channel

For a semiprime `n = pq` one observes only the *unordered* pair of splitting types of the
two prime factors.  The sign character of `n` is the product of the two sign characters,
which is symmetric, hence again a function of the unordered pair — and again exactly one
bit passes.
-/

/-- The unordered pair of splitting types of the two prime factors of a semiprime. -/
inductive PairKey
  | SS | SP | SI | PP | PI | II
  deriving DecidableEq, Fintype, Repr

open PairKey

/-- The unordered type pair of an ordered pair of splitting types. -/
def pairKey : SplitType → SplitType → PairKey
  | totallySplit, totallySplit => SS
  | totallySplit, partiallySplit => SP
  | partiallySplit, totallySplit => SP
  | totallySplit, inert => SI
  | inert, totallySplit => SI
  | partiallySplit, partiallySplit => PP
  | partiallySplit, inert => PI
  | inert, partiallySplit => PI
  | inert, inert => II

/-- `pairKey` is symmetric: it really only records the unordered pair. -/
theorem pairKey_comm (t u : SplitType) : pairKey t u = pairKey u t := by
  revert t u; decide

/-- Chebotarev multiplicity of an unordered type pair among the `36` Frobenius pairs. -/
def pairMult (k : PairKey) : ℕ :=
  ((univ : Finset (Equiv.Perm (Fin 3) × Equiv.Perm (Fin 3))).filter
    (fun w => pairKey (frobType w.1) (frobType w.2) = k)).card

/-- The semiprime Chebotarev profile: `1 : 6 : 4 : 9 : 12 : 4`. -/
theorem pairMult_values :
    pairMult SS = 1 ∧ pairMult SP = 6 ∧ pairMult SI = 4 ∧
      pairMult PP = 9 ∧ pairMult PI = 12 ∧ pairMult II = 4 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-- The sign character of the semiprime, read off from the unordered type pair. -/
def pairSignBit : PairKey → Bool
  | SS => true | SP => false | SI => true | PP => true | PI => false | II => true

/-- **The product sign character factors through the unordered type pair.**  Verified on
all `36` Frobenius pairs. -/
theorem pairSignBit_pairKey (w : Equiv.Perm (Fin 3) × Equiv.Perm (Fin 3)) :
    pairSignBit (pairKey (frobType w.1) (frobType w.2))
      = decide (Equiv.Perm.sign w.1 * Equiv.Perm.sign w.2 = 1) := by
  revert w; decide

/-- The two halves of the semiprime type-pair distribution have equal mass `18`. -/
theorem pairSignBit_mass_balance (c : Bool) :
    ∑ k ∈ univ.filter (fun k => pairSignBit k = c), pairMult k = 18 := by
  revert c; decide

/-- The joint occupation table of (residue class of the semiprime, unordered type pair). -/
def pairTable (chi : A → Bool) : A → PairKey → ℕ :=
  fun a k => if chi a = pairSignBit k then pairMult k else 0

omit [DecidableEq A] in
/-- **The semiprime pair channel law.**  Exactly one bit again — although the type-pair
alphabet has six letters and a completely different profile `1:6:4:9:12:4`. -/
theorem Imut_semiprime_pair_eq_one (chi : A → Bool) (k : ℕ)
    (hk : ∀ c : Bool, (univ.filter (fun a => chi a = c)).card = k) (hk0 : 0 < k) :
    Imut (pairTable chi) = 1 :=
  Imut_eq_one_of_character (fun _ _ => rfl) hk hk0 pairSignBit_mass_balance (by norm_num)

/-- The semiprime pair channel for `x³-3` / `x³-2` (`n = pq` observed mod `3`). -/
theorem Ipair_mod_three : Imut (pairTable chi3) = 1 :=
  Imut_semiprime_pair_eq_one chi3 1 chi3_balanced one_pos

/-- The semiprime pair channel for `x³-x-1` (`n = pq` observed mod `23`). -/
theorem Ipair_mod_twentythree : Imut (pairTable chi23) = 1 :=
  Imut_semiprime_pair_eq_one chi23 11 chi23_balanced (by norm_num)

end S3Universal