/-
# D5-HINT-VALUE: the dihedral dial of `x⁵ + 20x + 32` carries exactly half a bit of hint

FACT round 35, experiment #6 (paper 125) reads the semiprime battery of the solvable quintic
`f = x⁵ + 20x + 32` (Galois group the dihedral group `D₅` of order 10) through the
factor-residue views of `Algebra.SumDiffHintValue` at the modulus `m* = 320` and reports a
**hint value** `I(T ; s,d) - I(T ; N) = +0.6940` bits.  This file completes the `D₅` row of
the law table: it identifies the dial, proves where it lives, and evaluates the Chebotarev-limit
hint value exactly.

## The dial

* `legendreSym_neg_five_eq_chi20` — the residue dial of `f` is the **Kronecker character of
  `ℚ(√-5)`**: for every prime `p ∤ 10`, `(-5 / p) = χ₂₀(p)`, where `χ₂₀` is the explicit
  mod-`20` table `chi20`.  This is proved from quadratic reciprocity (`5 ≡ 1 mod 4`) and the
  first supplement; it is the reason a modulus divisible by `20` (such as `320`) is needed.
* `rootCount_eq_one_iff_chi20` — experimental confirmation inside Lean: for all 22 primes
  `7 ≤ p < 100`, `f` has exactly one root mod `p` iff `χ₂₀(p) = -1`, and it always has `0`,
  `1` or `5` roots.
* `d5_unique_real_root` — `f` has exactly one real root (it lies in `(-2,-1)`), so complex
  conjugation fixes exactly one root: it is a *reflection* of `D₅`, which is why the quadratic
  subfield of the splitting field is imaginary.
* `d5_disc_trinomial` — the trinomial discriminant `5⁵·32⁴ + 4⁴·20⁵ = 64000²` is a square,
  so the Galois group lies in `A₅`, consistent with `D₅`.

## The Chebotarev box and the exact hint law

`D₅` is modelled as the maps `y ↦ ±y + b` on `ZMod 5` (encoded `x = 5e + b`, `e ∈ {0,1}`).
The label of a prime is the number of roots of `f mod p` = the number of fixed points of the
Frobenius (`5`, `0` or `1`, i.e. types `[1⁵]`, `[5]`, `[1,2,2]`); the dial is `e`, i.e.
`χ₂₀(p)`.

* `dFix_spec`, `dAct_reflection_involutive`, `dAct_rotation_order_five` — the fixed-point
  label really is the cycle type: reflections are involutions with one fixed point,
  non-trivial rotations are fixed-point free of order five.
* `d5_prime_dial_pinned` — at the prime level the dial is a function of the type and carries
  exactly `1` bit: `I(T ; χ) = H(χ) = 1`, with residual `H(T | χ) = (log₂ 5)/2 - 4/5`.
* `d5_unordered_pair_view`, `d5_unordered_product_view`,
  **`d5_hint_value_unordered`** — for the unordered type pair of a semiprime:
  `I(T ; χ(p),χ(q)) = 3/2`, `I(T ; χ(N)) = 1`, **hint value exactly `1/2` bit**.
* `d5_hint_value_ordered` — if the label also records which factor is which the hint value is
  exactly `1` bit.
* `mutInfo_eq_uEnt_of_factor` — **the pinned-dial law** (general, any finite box): if the dial
  is a function of the label, the label transmits the whole dial entropy, `I(T ; D) = H(D)`.
* `d5_product_view_is_pinned`, `d5_pair_view_not_pinned` — the structural reading of the two
  rows: the product dial `χ(N)` is a function of the unordered type pair (so its row is
  `H(χ(N)) = 1`), the pair dial is not (`3/2 < 2`); the hint value is what the label can
  recover of the second character.
* `d3_hint_value_unordered`, `d3_hint_value_ordered`, `dihedral_hint_universal` — the same
  numbers `1/2` and `1` for the `D₃ = S₃` field of `x³ - 2`, although the label entropies differ:
  the hint value is a *dihedral* invariant, not a quintic one.

## The residue views at `m* = 320`

* `chi20_mul` — `χ₂₀` is completely multiplicative.
* `joint_view_determines_chi` — the joint residue view `(p + q, q - p) mod 320` determines
  `χ₂₀(p)` and `χ₂₀(q)` separately (it pins `p, q mod 160`, and `20 ∣ 160`).
* `product_view_determines_chi_product` — the product view `N mod 320` determines only
  `χ₂₀(p)·χ₂₀(q)`.
* `product_view_merges_semiprimes` — **the hint, with real primes**: `11·13 ≡ 7·569 (mod 320)`,
  but `f` has one root mod `11` and mod `13` and no root mod `7` and mod `569`; the joint view
  separates the two semiprimes.
* `d5_verdict` — THE-D5-DIAL-CARRIES-A-HINT: the Chebotarev-limit hint value `1/2` is strictly
  positive, and the reported `0.6940` lies strictly between the unordered limit `1/2` and the
  ordered limit `1`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the `D₅` dial is the quadratic character of the unique quadratic subfield
  `K` of the splitting field; the hint value in the Chebotarev limit is the dihedral constant
  `3/2 - 1 = 1/2` (unordered labels), and the reported `+0.6940` contains plug-in bias.
Experiment (Stage 2): (see `ComputationalEvidence.md`) root counts of `f mod p` for the 427
  primes `7 ≤ p < 3000`: `0` roots 174 times, `1` root 221 times, `5` roots 32 times, never
  anything else.  Of the seven candidate quadratic fields ramified only at `2, 5`, exactly
  `ℚ(√-5)` matches (`1` root ⟺ `(-5/p) = -1`) on all 427 primes.  Plug-in hint value of the
  real semiprime battery at `m = 320` (unordered root-count labels, all pairs `p < q` of primes
  `7 ≤ p, q < B`): `B = 500` → `+0.8557`, `B = 1500` → `+0.7363`, `B = 4000` → `+0.6135`;
  the product view reads `1.0228, 1.0035, 1.0006` → `1`.  The residue-pair view reads
  `1.4873, 1.4979, 1.4987` → `3/2`.
Analysis (Stage 3): the decreasing sequence of plug-in readings brackets the round-35 value
  `0.6940` and converges to the exact limit `1/2` proved below; the excess over `1/2` is the
  bias of the `320²`-cell joint view, while the product view (`320` cells) is already at its
  limit.  The value `1/2` is universal for dihedral fields of odd degree (`D₃`, `D₅` proved
  here; `D₇`, `D₉` checked numerically), contrasting with `9/8` for the Frobenius field `F₂₀`.
Critique (Stage 4): the Chebotarev model (Frobenius uniform on the group, independent for the
  two factors) is an assumption about the limit, not a theorem about finite batteries; the
  number-theoretic identification of the dial with `ℚ(√-5)` is proved only at the level of the
  character table (reciprocity) plus a finite check of root counts, not via Galois theory of
  `f`.  All entropies are exact rationals computed from fibre counts; no `native_decide`.
-/
import Mathlib
import Shared.CyclicTypeChannel
import Shared.CyclicTypeChannelNonneg

namespace D5Hint

open Finset CyclicTypeChannel

set_option maxRecDepth 100000

/-! ## 1. The quadratic dial `χ₂₀ = (-5 / ·)` -/

/-- The Kronecker character of `ℚ(√-5)` on residues mod `20`. -/
def chi20Res : ℕ → ℤ
  | 1 | 3 | 7 | 9 => 1
  | 11 | 13 | 17 | 19 => -1
  | _ => 0

/-- The Kronecker character `χ₂₀` of `ℚ(√-5)`, of conductor `20`. -/
def chi20 (n : ℕ) : ℤ := chi20Res (n % 20)

instance fact_prime_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩

/-- The quadratic character mod `5`, evaluated on residues. -/
lemma legendre_five_res (k : ℕ) (hk : k % 5 ≠ 0) :
    legendreSym 5 (k : ℤ) = if k % 5 = 1 ∨ k % 5 = 4 then 1 else -1 := by
  rw [legendreSym.mod]
  have h5 : ((k : ℤ) % ((5 : ℕ) : ℤ)) = ((k % 5 : ℕ) : ℤ) := by push_cast; omega
  rw [h5]
  have : k % 5 < 5 := Nat.mod_lt _ (by norm_num)
  interval_cases h : k % 5
  · exact absurd rfl hk
  · simp only [true_or, if_true]; rw [legendreSym.eq_one_iff _ (by decide)]; decide
  · simp; rw [legendreSym.eq_neg_one_iff]; decide
  · simp; rw [legendreSym.eq_neg_one_iff]; decide
  · simp; rw [legendreSym.eq_one_iff _ (by decide)]; decide

/-- **The dial is `ℚ(√-5)`.**  For every prime `p ∉ {2, 5}`, the Legendre symbol `(-5 / p)`
equals the explicit mod-`20` character `χ₂₀(p)`.  Proof: `(-5/p) = (-1/p)(5/p)`, the first
supplement gives `χ₄(p)`, and quadratic reciprocity (`5 ≡ 1 mod 4`) turns `(5/p)` into
`(p/5)`. -/
theorem legendreSym_neg_five_eq_chi20 (p : ℕ) [hp : Fact p.Prime] (hp2 : p ≠ 2)
    (hp5 : p ≠ 5) : legendreSym p (-5) = chi20 p := by
  have hm : (-5 : ℤ) = (-1) * ((5 : ℕ) : ℤ) := by norm_num
  rw [hm, legendreSym.mul, legendreSym.at_neg_one hp2,
    legendreSym.quadratic_reciprocity_one_mod_four (by norm_num) hp2]
  have hodd : p % 2 = 1 := by
    rcases Nat.even_or_odd p with ⟨r, hr⟩ | ho
    · exact absurd (hp.out.eq_one_or_self_of_dvd 2 ⟨r, by omega⟩) (by omega)
    · exact Nat.odd_iff.mp ho
  have h5 : p % 5 ≠ 0 := by
    intro h
    rcases hp.out.eq_one_or_self_of_dvd 5 (Nat.dvd_of_mod_eq_zero h) with h1 | h1 <;> omega
  rw [legendre_five_res p h5, ZMod.χ₄_nat_mod_four, chi20]
  have : p % 20 < 20 := Nat.mod_lt _ (by norm_num)
  have h4 : p % 4 = p % 20 % 4 := (Nat.mod_mod_of_dvd p (by norm_num)).symm
  have h5' : p % 5 = p % 20 % 5 := (Nat.mod_mod_of_dvd p (by norm_num)).symm
  rw [h4, h5']
  interval_cases h : p % 20 <;> first | omega | decide

/-- `χ₂₀` is completely multiplicative. -/
theorem chi20_mul (a b : ℕ) : chi20 (a * b) = chi20 a * chi20 b := by
  have key : ∀ i < 20, ∀ j < 20, chi20Res (i * j % 20) = chi20Res i * chi20Res j := by decide
  unfold chi20
  rw [Nat.mul_mod]
  exact key _ (Nat.mod_lt _ (by norm_num)) _ (Nat.mod_lt _ (by norm_num))

/-! ## 2. The polynomial `x⁵ + 20x + 32` -/

/-- The number of roots of `x⁵ + 20x + 32` modulo `p`. -/
def rootCount (p : ℕ) : ℕ :=
  ((List.range p).filter (fun x => (x ^ 5 + 20 * x + 32) % p = 0)).length

/-- The primes `7 ≤ p < 100`. -/
def smallPrimes : List ℕ :=
  [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

/-- **Experimental confirmation of the dial.**  For every prime `7 ≤ p < 100`, the polynomial
`x⁵ + 20x + 32` has `0`, `1` or `5` roots mod `p` (the three fixed-point counts of `D₅`), and it
has exactly one root iff `χ₂₀(p) = -1`, i.e. iff `p` is inert in `ℚ(√-5)`. -/
theorem rootCount_eq_one_iff_chi20 :
    ∀ p ∈ smallPrimes, (rootCount p = 0 ∨ rootCount p = 1 ∨ rootCount p = 5) ∧
      (rootCount p = 1 ↔ chi20 p = -1) := by
  decide

/-- The same statement phrased with the Legendre symbol `(-5 / p)`, via reciprocity. -/
theorem rootCount_eq_one_iff_legendre (p : ℕ) [Fact p.Prime] (hp : p ∈ smallPrimes) :
    rootCount p = 1 ↔ legendreSym p (-5) = -1 := by
  have h2 : p ≠ 2 := by rintro rfl; revert hp; decide
  have h5 : p ≠ 5 := by rintro rfl; revert hp; decide
  rw [legendreSym_neg_five_eq_chi20 p h2 h5]
  exact (rootCount_eq_one_iff_chi20 p hp).2

/-- The trinomial discriminant `5⁵ b⁴ + 4⁴ a⁵` of `x⁵ + a x + b` at `(a, b) = (20, 32)` is the
perfect square `64000² = 2¹⁸ · 5⁶`: the Galois group lies in `A₅`. -/
theorem d5_disc_trinomial :
    (5 : ℤ) ^ 5 * 32 ^ 4 + 4 ^ 4 * 20 ^ 5 = 64000 ^ 2 ∧ (64000 : ℤ) = 2 ^ 9 * 5 ^ 3 := by
  constructor <;> norm_num

/-- `x ↦ x⁵ + 20x + 32` is strictly increasing on `ℝ`. -/
theorem d5_strictMono : StrictMono (fun x : ℝ => x ^ 5 + 20 * x + 32) := by
  intro x y hxy
  have h5 : x ^ 5 < y ^ 5 := Odd.strictMono_pow (by decide) hxy
  simp only
  linarith

/-- **Complex conjugation is a reflection.**  `x⁵ + 20x + 32` has exactly one real root, and it
lies in `(-2, -1)`.  Hence complex conjugation fixes exactly one of the five roots, i.e. acts as
a reflection of `D₅` — which forces the quadratic subfield of the splitting field to be
imaginary, in agreement with `ℚ(√-5)`. -/
theorem d5_unique_real_root :
    ∃! r : ℝ, r ^ 5 + 20 * r + 32 = 0 ∧ -2 < r ∧ r < -1 := by
  have hcont : ContinuousOn (fun x : ℝ => x ^ 5 + 20 * x + 32) (Set.Icc (-2) (-1)) := by
    fun_prop
  obtain ⟨r, hr, hr0⟩ := intermediate_value_Icc (by norm_num : (-2 : ℝ) ≤ -1) hcont
    (show (0 : ℝ) ∈ Set.Icc ((-2 : ℝ) ^ 5 + 20 * (-2) + 32) ((-1 : ℝ) ^ 5 + 20 * (-1) + 32) by
      norm_num)
  simp only at hr0
  have hne2 : r ≠ -2 := by rintro rfl; norm_num at hr0
  have hne1 : r ≠ -1 := by rintro rfl; norm_num at hr0
  refine ⟨r, ⟨hr0, lt_of_le_of_ne hr.1 (Ne.symm hne2), lt_of_le_of_ne hr.2 hne1⟩, ?_⟩
  rintro y ⟨hy, -, -⟩
  apply d5_strictMono.injective
  change y ^ 5 + 20 * y + 32 = r ^ 5 + 20 * r + 32
  rw [hy, hr0]

/-- Every real root of `x⁵ + 20x + 32` is the one in `(-2,-1)`: there is exactly one. -/
theorem d5_real_root_unique (x y : ℝ) (hx : x ^ 5 + 20 * x + 32 = 0)
    (hy : y ^ 5 + 20 * y + 32 = 0) : x = y := by
  apply d5_strictMono.injective
  change x ^ 5 + 20 * x + 32 = y ^ 5 + 20 * y + 32
  rw [hx, hy]

/-! ## 3. The dihedral Chebotarev box -/

/-- The dihedral group `Dₙ` acting on `ZMod n`, element `x = n e + b` acting by
`y ↦ (-1)^e y + b`. -/
def dihAct (n : ℕ) (x : ℕ) (y : ZMod n) : ZMod n :=
  (if x / n = 0 then y else -y) + ((x % n : ℕ) : ZMod n)

/-- The same action on the representatives `0 ≤ y < n`, computed in `ℕ`. -/
def dihActN (n : ℕ) (x : ℕ) (y : ℕ) : ℕ :=
  ((if x / n = 0 then y else n - y) + x % n) % n

/-- The label: the number of fixed points of the Frobenius = the number of roots mod `p`. -/
def dihFix (n : ℕ) (x : ℕ) : ℕ := #{y ∈ range n | dihActN n x y = y}

/-- The representative action computes the `ZMod n` action. -/
theorem dihActN_cast (n x y : ℕ) (hy : y ≤ n) :
    ((dihActN n x y : ℕ) : ZMod n) = dihAct n x (y : ZMod n) := by
  unfold dihActN dihAct
  rw [ZMod.natCast_mod]
  split_ifs with h
  · push_cast; ring
  · rw [Nat.cast_add, Nat.cast_sub hy, ZMod.natCast_self]; ring

/-- The quadratic dial: `0` for rotations (`χ(p) = +1`), `1` for reflections (`χ(p) = -1`). -/
def dihDial (n : ℕ) (x : ℕ) : ℕ := x / n

/-- The single-prime box `Dₙ` (`2n` Frobenius classes). -/
def dihFrob (n : ℕ) : Finset ℕ := range (2 * n)

/-- The semiprime box `Dₙ × Dₙ`: independent Frobenii of the two factors. -/
def dihBox (n : ℕ) : Finset (ℕ × ℕ) := dihFrob n ×ˢ dihFrob n

/-- Ordered pair of labels. -/
def dihOrd (n : ℕ) (p : ℕ × ℕ) : ℕ × ℕ := (dihFix n p.1, dihFix n p.2)

/-- Unordered pair of labels (the adversary is not told which factor is which). -/
def dihUn (n : ℕ) (p : ℕ × ℕ) : ℕ × ℕ :=
  (min (dihFix n p.1) (dihFix n p.2), max (dihFix n p.1) (dihFix n p.2))

/-- The joint residue view, read through the dial: `(χ(p), χ(q))`. -/
def dihPairDial (n : ℕ) (p : ℕ × ℕ) : ℕ × ℕ := (dihDial n p.1, dihDial n p.2)

/-- The product view, read through the dial: `χ(N) = χ(p) χ(q)`. -/
def dihProdDial (n : ℕ) (p : ℕ × ℕ) : ℕ := (dihDial n p.1 + dihDial n p.2) % 2

/-- The hint value `I(T ; χ(p), χ(q)) - I(T ; χ(N))` of a label on the semiprime box. -/
noncomputable def hintValue {β : Type*} [DecidableEq β] (n : ℕ) (T : ℕ × ℕ → β) : ℝ :=
  mutInfo (dihBox n) T (dihPairDial n) - mutInfo (dihBox n) T (dihProdDial n)

/-- **The fixed-point label is the cycle type** (for `D₅`): identity `5`, non-trivial rotations
`0`, reflections `1`. -/
theorem dFix_spec : ∀ x ∈ dihFrob 5,
    dihFix 5 x = if x / 5 = 0 then (if x % 5 = 0 then 5 else 0) else 1 := by
  decide

/-- Reflections are involutions. -/
theorem dAct_reflection_involutive (x : ℕ) (hx : x / 5 = 1) (y : ZMod 5) :
    dihAct 5 x (dihAct 5 x y) = y := by
  simp only [dihAct, hx, one_ne_zero, if_false]
  ring

/-- Rotations have order dividing five. -/
theorem dAct_rotation_order_five (x : ℕ) (hx : x / 5 = 0) (y : ZMod 5) :
    (dihAct 5 x)^[5] y = y := by
  have h : ∀ k : ℕ, (dihAct 5 x)^[k] y = y + (k : ZMod 5) * ((x % 5 : ℕ) : ZMod 5) := by
    intro k
    induction k with
    | zero => simp
    | succ k ih =>
      rw [Function.iterate_succ_apply', ih]
      simp only [dihAct, hx, if_true]
      push_cast
      ring
  rw [h]
  have : ((5 : ℕ) : ZMod 5) = 0 := by decide
  rw [this, zero_mul, add_zero]

/-! ### Logarithm bookkeeping -/

lemma lb_20 : Real.logb 2 (20 : ℝ) = 2 + Real.logb 2 5 := by
  rw [show (20 : ℝ) = 4 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4]

lemma lb_40 : Real.logb 2 (40 : ℝ) = 3 + Real.logb 2 5 := by
  rw [show (40 : ℝ) = 8 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_8]

lemma lb_50 : Real.logb 2 (50 : ℝ) = 1 + 2 * Real.logb 2 5 := by
  rw [show (50 : ℝ) = 2 * 25 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_25,
    Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]

lemma lb_18 : Real.logb 2 (18 : ℝ) = 1 + 2 * Real.logb 2 3 := by
  rw [show (18 : ℝ) = 2 * 9 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_9,
    Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]

lemma lb_2 : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)

/-! ## 4. The `D₅` row: prime level -/

lemma d5Frob_card : (dihFrob 5).card = 10 := by decide

lemma d5_dial_fiber_0 : #{x ∈ dihFrob 5 | dihDial 5 x = 0} = 5 := by decide
lemma d5_dial_fiber_1 : #{x ∈ dihFrob 5 | dihDial 5 x = 1} = 5 := by decide
lemma d5_dial_image : (dihFrob 5).image (dihDial 5) = range 2 := by decide

/-- The quintic type entropy of `D₅`: `H(T) = 1/5 + (log₂ 5)/2`, from the Chebotarev
distribution `(1/10, 4/10, 5/10)` on `[1⁵], [5], [1,2,2]`. -/
theorem d5_typeEntropy : uEnt (dihFrob 5) (dihFix 5) = 1 / 5 + (1 / 2) * Real.logb 2 5 := by
  have h : ((dihFrob 5).image (dihFix 5)).val.map
      (fun v => (#{x ∈ dihFrob 5 | dihFix 5 x = v} : ℕ)) = (↑[1, 4, 5] : Multiset ℕ) := by
    decide
  rw [uEnt_eq_countSum _ _ _ h, d5Frob_card]
  norm_num [lb_10, lb_4]
  ring

/-- `H(T | χ) = (log₂ 5)/2 - 4/5`: the `[1⁵]/[5]` ambiguity among the rotations, which no
residue class can resolve. -/
theorem d5_condEnt_type_dial :
    condEnt (dihFrob 5) (dihFix 5) (dihDial 5) = (1 / 2) * Real.logb 2 5 - 4 / 5 := by
  have e0 : uEnt {x ∈ dihFrob 5 | dihDial 5 x = 0} (dihFix 5) = Real.logb 2 5 - 8 / 5 := by
    have h : (({x ∈ dihFrob 5 | dihDial 5 x = 0}).image (dihFix 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihFrob 5 | dihDial 5 x = 0} | dihFix 5 q = v} : ℕ))
        = (↑[1, 4] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_dial_fiber_0]
    norm_num [lb_4]
  have e1 : uEnt {x ∈ dihFrob 5 | dihDial 5 x = 1} (dihFix 5) = 0 := by
    have h : (({x ∈ dihFrob 5 | dihDial 5 x = 1}).image (dihFix 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihFrob 5 | dihDial 5 x = 1} | dihFix 5 q = v} : ℕ))
        = (↑[5] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_dial_fiber_1]
    norm_num
  rw [condEnt, d5_dial_image, Finset.sum_range_succ, Finset.sum_range_one, e0, e1,
    d5_dial_fiber_0, d5_dial_fiber_1, d5Frob_card]
  ring

/-- **The prime-level dial is pinned.**  The residue dial `χ₂₀(p)` carries exactly one bit about
the splitting type of `x⁵ + 20x + 32`, and this bit is all of the dial: `I(T ; χ) = H(χ) = 1`. -/
theorem d5_prime_dial_pinned :
    mutInfo (dihFrob 5) (dihFix 5) (dihDial 5) = 1 ∧ uEnt (dihFrob 5) (dihDial 5) = 1 := by
  refine ⟨?_, ?_⟩
  · rw [mutInfo, d5_typeEntropy, d5_condEnt_type_dial]; ring
  · have h : ((dihFrob 5).image (dihDial 5)).val.map
        (fun v => (#{x ∈ dihFrob 5 | dihDial 5 x = v} : ℕ)) = (↑[5, 5] : Multiset ℕ) := by
      decide
    rw [uEnt_eq_countSum _ _ _ h, d5Frob_card]
    norm_num [lb_10]
    ring

/-! ## 5. The `D₅` row: semiprime level -/

lemma d5Box_card : (dihBox 5).card = 100 := by decide

lemma d5_pair_image : (dihBox 5).image (dihPairDial 5) = {(0, 0), (0, 1), (1, 0), (1, 1)} := by
  decide

lemma d5_prod_image : (dihBox 5).image (dihProdDial 5) = range 2 := by decide

lemma d5_pair_fiber (c : ℕ × ℕ)
    (hc : c ∈ ({(0, 0), (0, 1), (1, 0), (1, 1)} : Finset (ℕ × ℕ))) :
    #{x ∈ dihBox 5 | dihPairDial 5 x = c} = 25 := by
  revert c; decide

lemma d5_prod_fiber_0 : #{x ∈ dihBox 5 | dihProdDial 5 x = 0} = 50 := by decide
lemma d5_prod_fiber_1 : #{x ∈ dihBox 5 | dihProdDial 5 x = 1} = 50 := by decide

/-- Entropy of the unordered type pair: `H(T) = log₂ 5 - 9/50`. -/
theorem d5_unordered_entropy : uEnt (dihBox 5) (dihUn 5) = Real.logb 2 5 - 9 / 50 := by
  have h : ((dihBox 5).image (dihUn 5)).val.map
      (fun v => (#{x ∈ dihBox 5 | dihUn 5 x = v} : ℕ))
      = (↑[1, 8, 16, 10, 40, 25] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, d5Box_card]
  norm_num [lb_100, lb_8, lb_16, lb_10, lb_40, lb_25]
  ring

/-- `H(T | χ(p), χ(q)) = log₂ 5 - 42/25`. -/
theorem d5_unordered_condEnt_pair :
    condEnt (dihBox 5) (dihUn 5) (dihPairDial 5) = Real.logb 2 5 - 42 / 25 := by
  have e00 : uEnt {x ∈ dihBox 5 | dihPairDial 5 x = (0, 0)} (dihUn 5)
      = 2 * Real.logb 2 5 - 88 / 25 := by
    have h : (({x ∈ dihBox 5 | dihPairDial 5 x = (0, 0)}).image (dihUn 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihPairDial 5 x = (0, 0)} | dihUn 5 q = v} : ℕ))
        = (↑[1, 8, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_pair_fiber _ (by decide)]
    norm_num [lb_25, lb_8, lb_16]
  have e01 : uEnt {x ∈ dihBox 5 | dihPairDial 5 x = (0, 1)} (dihUn 5)
      = Real.logb 2 5 - 8 / 5 := by
    have h : (({x ∈ dihBox 5 | dihPairDial 5 x = (0, 1)}).image (dihUn 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihPairDial 5 x = (0, 1)} | dihUn 5 q = v} : ℕ))
        = (↑[5, 20] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_pair_fiber _ (by decide)]
    norm_num [lb_25, lb_20]
    ring
  have e10 : uEnt {x ∈ dihBox 5 | dihPairDial 5 x = (1, 0)} (dihUn 5)
      = Real.logb 2 5 - 8 / 5 := by
    have h : (({x ∈ dihBox 5 | dihPairDial 5 x = (1, 0)}).image (dihUn 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihPairDial 5 x = (1, 0)} | dihUn 5 q = v} : ℕ))
        = (↑[5, 20] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_pair_fiber _ (by decide)]
    norm_num [lb_25, lb_20]
    ring
  have e11 : uEnt {x ∈ dihBox 5 | dihPairDial 5 x = (1, 1)} (dihUn 5) = 0 := by
    have h : (({x ∈ dihBox 5 | dihPairDial 5 x = (1, 1)}).image (dihUn 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihPairDial 5 x = (1, 1)} | dihUn 5 q = v} : ℕ))
        = (↑[25] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_pair_fiber _ (by decide)]
    norm_num
  rw [condEnt, d5_pair_image]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [e00, e01, e10, e11, d5_pair_fiber _ (by decide), d5_pair_fiber (0, 1) (by decide),
    d5_pair_fiber (1, 0) (by decide), d5_pair_fiber (1, 1) (by decide), d5Box_card]
  ring

/-- `H(T | χ(N)) = log₂ 5 - 59/50`. -/
theorem d5_unordered_condEnt_prod :
    condEnt (dihBox 5) (dihUn 5) (dihProdDial 5) = Real.logb 2 5 - 59 / 50 := by
  have e0 : uEnt {x ∈ dihBox 5 | dihProdDial 5 x = 0} (dihUn 5)
      = Real.logb 2 5 - 19 / 25 := by
    have h : (({x ∈ dihBox 5 | dihProdDial 5 x = 0}).image (dihUn 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihProdDial 5 x = 0} | dihUn 5 q = v} : ℕ))
        = (↑[1, 8, 16, 25] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_prod_fiber_0]
    norm_num [lb_50, lb_25, lb_8, lb_16]
    ring
  have e1 : uEnt {x ∈ dihBox 5 | dihProdDial 5 x = 1} (dihUn 5)
      = Real.logb 2 5 - 8 / 5 := by
    have h : (({x ∈ dihBox 5 | dihProdDial 5 x = 1}).image (dihUn 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihProdDial 5 x = 1} | dihUn 5 q = v} : ℕ))
        = (↑[10, 40] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_prod_fiber_1]
    norm_num [lb_50, lb_10, lb_40]
    ring
  rw [condEnt, d5_prod_image, Finset.sum_range_succ, Finset.sum_range_one, e0, e1,
    d5_prod_fiber_0, d5_prod_fiber_1, d5Box_card]
  ring

/-- The joint residue view transmits `I(T ; χ(p), χ(q)) = 3/2` bits about the unordered
type pair. -/
theorem d5_unordered_pair_view : mutInfo (dihBox 5) (dihUn 5) (dihPairDial 5) = 3 / 2 := by
  rw [mutInfo, d5_unordered_entropy, d5_unordered_condEnt_pair]; ring

/-- The product view transmits `I(T ; χ(N)) = 1` bit about the unordered type pair. -/
theorem d5_unordered_product_view : mutInfo (dihBox 5) (dihUn 5) (dihProdDial 5) = 1 := by
  rw [mutInfo, d5_unordered_entropy, d5_unordered_condEnt_prod]; ring

/-- **THE-D5-DIAL-CARRIES-A-HINT (Chebotarev limit).**  For the unordered splitting-type pair
of a semiprime, the hint value of the `D₅` dial of `x⁵ + 20x + 32` is exactly `1/2` bit. -/
theorem d5_hint_value_unordered : hintValue 5 (dihUn 5) = 1 / 2 := by
  rw [hintValue, d5_unordered_pair_view, d5_unordered_product_view]; norm_num

/-- Entropy of the ordered type pair: twice the prime-level entropy. -/
theorem d5_ordered_entropy : uEnt (dihBox 5) (dihOrd 5) = 2 / 5 + Real.logb 2 5 := by
  have h : ((dihBox 5).image (dihOrd 5)).val.map
      (fun v => (#{x ∈ dihBox 5 | dihOrd 5 x = v} : ℕ))
      = (↑[1, 4, 5, 4, 16, 20, 5, 20, 25] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, d5Box_card]
  norm_num [lb_100, lb_4, lb_16, lb_20, lb_25]
  ring

theorem d5_ordered_condEnt_pair :
    condEnt (dihBox 5) (dihOrd 5) (dihPairDial 5) = Real.logb 2 5 - 8 / 5 := by
  have e00 : uEnt {x ∈ dihBox 5 | dihPairDial 5 x = (0, 0)} (dihOrd 5)
      = 2 * Real.logb 2 5 - 16 / 5 := by
    have h : (({x ∈ dihBox 5 | dihPairDial 5 x = (0, 0)}).image (dihOrd 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihPairDial 5 x = (0, 0)} | dihOrd 5 q = v} : ℕ))
        = (↑[1, 4, 4, 16] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_pair_fiber _ (by decide)]
    norm_num [lb_25, lb_4, lb_16]
  have e01 : uEnt {x ∈ dihBox 5 | dihPairDial 5 x = (0, 1)} (dihOrd 5)
      = Real.logb 2 5 - 8 / 5 := by
    have h : (({x ∈ dihBox 5 | dihPairDial 5 x = (0, 1)}).image (dihOrd 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihPairDial 5 x = (0, 1)} | dihOrd 5 q = v} : ℕ))
        = (↑[5, 20] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_pair_fiber _ (by decide)]
    norm_num [lb_25, lb_20]
    ring
  have e10 : uEnt {x ∈ dihBox 5 | dihPairDial 5 x = (1, 0)} (dihOrd 5)
      = Real.logb 2 5 - 8 / 5 := by
    have h : (({x ∈ dihBox 5 | dihPairDial 5 x = (1, 0)}).image (dihOrd 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihPairDial 5 x = (1, 0)} | dihOrd 5 q = v} : ℕ))
        = (↑[5, 20] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_pair_fiber _ (by decide)]
    norm_num [lb_25, lb_20]
    ring
  have e11 : uEnt {x ∈ dihBox 5 | dihPairDial 5 x = (1, 1)} (dihOrd 5) = 0 := by
    have h : (({x ∈ dihBox 5 | dihPairDial 5 x = (1, 1)}).image (dihOrd 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihPairDial 5 x = (1, 1)} | dihOrd 5 q = v} : ℕ))
        = (↑[25] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_pair_fiber _ (by decide)]
    norm_num
  rw [condEnt, d5_pair_image]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [e00, e01, e10, e11, d5_pair_fiber _ (by decide), d5_pair_fiber (0, 1) (by decide),
    d5_pair_fiber (1, 0) (by decide), d5_pair_fiber (1, 1) (by decide), d5Box_card]
  ring

theorem d5_ordered_condEnt_prod :
    condEnt (dihBox 5) (dihOrd 5) (dihProdDial 5) = Real.logb 2 5 - 3 / 5 := by
  have e0 : uEnt {x ∈ dihBox 5 | dihProdDial 5 x = 0} (dihOrd 5)
      = Real.logb 2 5 - 3 / 5 := by
    have h : (({x ∈ dihBox 5 | dihProdDial 5 x = 0}).image (dihOrd 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihProdDial 5 x = 0} | dihOrd 5 q = v} : ℕ))
        = (↑[1, 4, 4, 16, 25] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_prod_fiber_0]
    norm_num [lb_50, lb_25, lb_4, lb_16]
    ring
  have e1 : uEnt {x ∈ dihBox 5 | dihProdDial 5 x = 1} (dihOrd 5)
      = Real.logb 2 5 - 3 / 5 := by
    have h : (({x ∈ dihBox 5 | dihProdDial 5 x = 1}).image (dihOrd 5)).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 5 | dihProdDial 5 x = 1} | dihOrd 5 q = v} : ℕ))
        = (↑[5, 20, 5, 20] : Multiset ℕ) := by decide
    rw [uEnt_eq_countSum _ _ _ h, d5_prod_fiber_1]
    norm_num [lb_50, lb_20]
    ring
  rw [condEnt, d5_prod_image, Finset.sum_range_succ, Finset.sum_range_one, e0, e1,
    d5_prod_fiber_0, d5_prod_fiber_1, d5Box_card]
  ring

/-- **The ordered hint value is exactly one bit**: `I(T ; χ(p),χ(q)) = 2`, `I(T ; χ(N)) = 1`.
The difference `1 - 1/2` from the unordered law is the which-factor information. -/
theorem d5_hint_value_ordered :
    mutInfo (dihBox 5) (dihOrd 5) (dihPairDial 5) = 2 ∧
    mutInfo (dihBox 5) (dihOrd 5) (dihProdDial 5) = 1 ∧ hintValue 5 (dihOrd 5) = 1 := by
  have h1 : mutInfo (dihBox 5) (dihOrd 5) (dihPairDial 5) = 2 := by
    rw [mutInfo, d5_ordered_entropy, d5_ordered_condEnt_pair]; ring
  have h2 : mutInfo (dihBox 5) (dihOrd 5) (dihProdDial 5) = 1 := by
    rw [mutInfo, d5_ordered_entropy, d5_ordered_condEnt_prod]; ring
  exact ⟨h1, h2, by rw [hintValue, h1, h2]; norm_num⟩

/-! ## 6. The pinned-dial law (general) -/

section Pinned

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- **The pinned-dial law.**  If on the box `s` the dial `D` is a function of the label `T`
(`D = g ∘ T` on `s`), then the label transmits everything the dial knows:
`I(T ; D) = H(D)`.  This is why the product view of any dihedral semiprime battery reads exactly
`H(χ(N)) = 1` bit. -/
theorem mutInfo_eq_uEnt_of_factor (s : Finset α) (T : α → β) (D : α → γ) (g : β → γ)
    (hg : ∀ x ∈ s, D x = g (T x)) : mutInfo s T D = uEnt s D := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [mutInfo, uEnt, condEnt]
  have hN0 : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast card_pos.2 hs
  rw [mutInfo_eq_double s T D hs]
  have hterm : ∀ c ∈ s.image D, ∀ v ∈ s.image T,
      ((#{x ∈ s | D x = c ∧ T x = v} : ℝ) / s.card) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | T x = v} : ℝ)
          - Real.logb 2 (#{x ∈ s | D x = c} : ℝ)
          + Real.logb 2 (#{x ∈ s | D x = c ∧ T x = v} : ℝ))
      = ((#{x ∈ s | D x = c ∧ T x = v} : ℝ) / s.card) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | D x = c} : ℝ)) := by
    intro c _ v _
    by_cases hv : g v = c
    · have hfil : ({x ∈ s | D x = c ∧ T x = v} : Finset α) = {x ∈ s | T x = v} := by
        apply Finset.filter_congr
        intro x hx
        constructor
        · exact fun h => h.2
        · intro h; exact ⟨by rw [hg x hx, h, hv], h⟩
      rw [hfil]; ring
    · have hfil : ({x ∈ s | D x = c ∧ T x = v} : Finset α) = ∅ := by
        apply Finset.filter_eq_empty_iff.2
        rintro x hx ⟨h1, h2⟩
        exact hv (by rw [← h2, ← hg x hx, h1])
      rw [hfil]; simp
  rw [Finset.sum_congr rfl fun c hc => Finset.sum_congr rfl (hterm c hc)]
  have hinner : ∀ c ∈ s.image D, ∑ v ∈ s.image T,
      ((#{x ∈ s | D x = c ∧ T x = v} : ℝ) / s.card) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | D x = c} : ℝ))
      = ((#{x ∈ s | D x = c} : ℝ) / s.card) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | D x = c} : ℝ)) := by
    intro c _
    rw [← Finset.sum_mul, ← Finset.sum_div]
    congr 2
    exact_mod_cast jointCount_sum_g s T D c
  rw [Finset.sum_congr rfl hinner, uEnt_eq_image]
  have hsum : ∑ c ∈ s.image D, (#{x ∈ s | D x = c} : ℝ) = (s.card : ℝ) := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s D)
  have e : ∑ c ∈ s.image D, ((#{x ∈ s | D x = c} : ℝ) / s.card) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | D x = c} : ℝ))
      = (∑ c ∈ s.image D, (#{x ∈ s | D x = c} : ℝ)) / s.card * Real.logb 2 (s.card : ℝ)
        - (∑ c ∈ s.image D, (#{x ∈ s | D x = c} : ℝ) *
            Real.logb 2 (#{x ∈ s | D x = c} : ℝ)) / s.card := by
    rw [Finset.sum_div, Finset.sum_mul, Finset.sum_div, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun c _ => ?_
    ring
  rw [e, hsum, div_self (ne_of_gt hN0), one_mul]

end Pinned

/-- The `D₅` product dial is a function of the unordered type pair: a semiprime has
`χ(N) = -1` exactly when exactly one of its factors has the reflection type (one root). -/
theorem d5_prodDial_factors_through_type : ∀ x ∈ dihBox 5,
    dihProdDial 5 x = (if ((dihUn 5 x).1 = 1) = ((dihUn 5 x).2 = 1) then 0 else 1) := by
  decide

/-- **Structural reading of the product row.**  By the pinned-dial law the product view carries
exactly the entropy of `χ(N)`, one bit — an independent derivation of
`d5_unordered_product_view` that does not compute any conditional entropy. -/
theorem d5_product_view_is_pinned :
    mutInfo (dihBox 5) (dihUn 5) (dihProdDial 5) = uEnt (dihBox 5) (dihProdDial 5) ∧
    uEnt (dihBox 5) (dihProdDial 5) = 1 := by
  refine ⟨mutInfo_eq_uEnt_of_factor _ _ _
    (fun t : ℕ × ℕ => if (t.1 = 1) = (t.2 = 1) then 0 else 1)
    d5_prodDial_factors_through_type, ?_⟩
  have h : ((dihBox 5).image (dihProdDial 5)).val.map
      (fun v => (#{x ∈ dihBox 5 | dihProdDial 5 x = v} : ℕ)) = (↑[50, 50] : Multiset ℕ) := by
    decide
  rw [uEnt_eq_countSum _ _ _ h, d5Box_card]
  norm_num [lb_100, lb_50]
  ring

/-- The joint view is *not* pinned by the unordered label: the label cannot say which factor is
the reflection, so `I(T ; χ(p),χ(q)) = 3/2 < 2 = H(χ(p),χ(q))`. The half-bit shortfall is
exactly the hint value's distance from the ordered value `1`. -/
theorem d5_pair_view_not_pinned :
    mutInfo (dihBox 5) (dihUn 5) (dihPairDial 5) < uEnt (dihBox 5) (dihPairDial 5) := by
  have h : ((dihBox 5).image (dihPairDial 5)).val.map
      (fun v => (#{x ∈ dihBox 5 | dihPairDial 5 x = v} : ℕ))
      = (↑[25, 25, 25, 25] : Multiset ℕ) := by decide
  rw [d5_unordered_pair_view, uEnt_eq_countSum _ _ _ h, d5Box_card]
  norm_num [lb_100, lb_25]
  ring_nf
  norm_num

/-! ## 7. The `D₃` control: `x³ - 2` -/

lemma d3Box_card : (dihBox 3).card = 36 := by decide

lemma d3_pair_image : (dihBox 3).image (dihPairDial 3) = {(0, 0), (0, 1), (1, 0), (1, 1)} := by
  decide

lemma d3_prod_image : (dihBox 3).image (dihProdDial 3) = range 2 := by decide

lemma d3_pair_fiber (c : ℕ × ℕ)
    (hc : c ∈ ({(0, 0), (0, 1), (1, 0), (1, 1)} : Finset (ℕ × ℕ))) :
    #{x ∈ dihBox 3 | dihPairDial 3 x = c} = 9 := by
  revert c; decide

lemma d3_prod_fiber_0 : #{x ∈ dihBox 3 | dihProdDial 3 x = 0} = 18 := by decide
lemma d3_prod_fiber_1 : #{x ∈ dihBox 3 | dihProdDial 3 x = 1} = 18 := by decide

theorem d3_unordered_entropy : uEnt (dihBox 3) (dihUn 3) = Real.logb 2 3 + 13 / 18 := by
  have h : ((dihBox 3).image (dihUn 3)).val.map
      (fun v => (#{x ∈ dihBox 3 | dihUn 3 x = v} : ℕ))
      = (↑[1, 4, 4, 6, 12, 9] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, d3Box_card]
  norm_num [lb_36, lb_4, lb_6, lb_12, lb_9]
  ring

theorem d3_ordered_entropy : uEnt (dihBox 3) (dihOrd 3) = Real.logb 2 3 + 4 / 3 := by
  have h : ((dihBox 3).image (dihOrd 3)).val.map
      (fun v => (#{x ∈ dihBox 3 | dihOrd 3 x = v} : ℕ))
      = (↑[1, 2, 3, 2, 4, 6, 3, 6, 9] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, d3Box_card]
  norm_num [lb_36, lb_2, lb_4, lb_6, lb_9]
  ring

/-- Conditional entropies of the `D₃` labels given the two views. -/
theorem d3_condEnts :
    condEnt (dihBox 3) (dihUn 3) (dihPairDial 3) = Real.logb 2 3 - 7 / 9 ∧
    condEnt (dihBox 3) (dihUn 3) (dihProdDial 3) = Real.logb 2 3 - 5 / 18 ∧
    condEnt (dihBox 3) (dihOrd 3) (dihPairDial 3) = Real.logb 2 3 - 2 / 3 ∧
    condEnt (dihBox 3) (dihOrd 3) (dihProdDial 3) = Real.logb 2 3 + 1 / 3 := by
  have hp : ∀ (c : ℕ × ℕ) (T : ℕ × ℕ → ℕ × ℕ) (cs : Multiset ℕ) (val : ℝ),
      (({x ∈ dihBox 3 | dihPairDial 3 x = c}).image T).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 3 | dihPairDial 3 x = c} | T q = v} : ℕ)) = cs →
      c ∈ ({(0, 0), (0, 1), (1, 0), (1, 1)} : Finset (ℕ × ℕ)) →
      Real.logb 2 9 - (cs.map (fun c : ℕ => (c : ℝ) * Real.logb 2 (c : ℝ))).sum / 9 = val →
      uEnt {x ∈ dihBox 3 | dihPairDial 3 x = c} T = val := by
    intro c T cs val h hc hv
    rw [uEnt_eq_countSum _ _ _ h, d3_pair_fiber c hc]
    exact_mod_cast hv
  have hq : ∀ (c : ℕ) (T : ℕ × ℕ → ℕ × ℕ) (cs : Multiset ℕ) (val : ℝ),
      (({x ∈ dihBox 3 | dihProdDial 3 x = c}).image T).val.map
        (fun v => (#{q ∈ {x ∈ dihBox 3 | dihProdDial 3 x = c} | T q = v} : ℕ)) = cs →
      #{x ∈ dihBox 3 | dihProdDial 3 x = c} = 18 →
      Real.logb 2 18 - (cs.map (fun c : ℕ => (c : ℝ) * Real.logb 2 (c : ℝ))).sum / 18 = val →
      uEnt {x ∈ dihBox 3 | dihProdDial 3 x = c} T = val := by
    intro c T cs val h hc hv
    rw [uEnt_eq_countSum _ _ _ h, hc]
    exact_mod_cast hv
  have u00 := hp (0, 0) (dihUn 3) (↑[1, 4, 4] : Multiset ℕ) (2 * Real.logb 2 3 - 16 / 9) (by decide)
    (by decide)
    (by norm_num [lb_9, lb_4])
  have u01 := hp (0, 1) (dihUn 3) (↑[3, 6] : Multiset ℕ) (Real.logb 2 3 - 2 / 3) (by decide)
    (by decide)
    (by norm_num [lb_9, lb_6]; ring)
  have u10 := hp (1, 0) (dihUn 3) (↑[3, 6] : Multiset ℕ) (Real.logb 2 3 - 2 / 3) (by decide)
    (by decide)
    (by norm_num [lb_9, lb_6]; ring)
  have u11 := hp (1, 1) (dihUn 3) (↑[9] : Multiset ℕ) 0 (by decide) (by decide) (by norm_num)
  have o00 := hp (0, 0) (dihOrd 3) (↑[1, 2, 2, 4] : Multiset ℕ) (2 * Real.logb 2 3 - 4 / 3) (by decide)
    (by decide)
    (by norm_num [lb_9, lb_2, lb_4])
  have o01 := hp (0, 1) (dihOrd 3) (↑[3, 6] : Multiset ℕ) (Real.logb 2 3 - 2 / 3) (by decide)
    (by decide)
    (by norm_num [lb_9, lb_6]; ring)
  have o10 := hp (1, 0) (dihOrd 3) (↑[3, 6] : Multiset ℕ) (Real.logb 2 3 - 2 / 3) (by decide)
    (by decide)
    (by norm_num [lb_9, lb_6]; ring)
  have o11 := hp (1, 1) (dihOrd 3) (↑[9] : Multiset ℕ) 0 (by decide) (by decide) (by norm_num)
  have v0 := hq 0 (dihUn 3) (↑[1, 4, 4, 9] : Multiset ℕ) (Real.logb 2 3 + 1 / 9) (by decide)
    d3_prod_fiber_0
    (by norm_num [lb_18, lb_4, lb_9]; ring)
  have v1 := hq 1 (dihUn 3) (↑[6, 12] : Multiset ℕ) (Real.logb 2 3 - 2 / 3) (by decide)
    d3_prod_fiber_1
    (by norm_num [lb_18, lb_6, lb_12]; ring)
  have w0 := hq 0 (dihOrd 3) (↑[1, 2, 2, 4, 9] : Multiset ℕ) (Real.logb 2 3 + 1 / 3) (by decide)
    d3_prod_fiber_0
    (by norm_num [lb_18, lb_2, lb_4, lb_9]; ring)
  have w1 := hq 1 (dihOrd 3) (↑[3, 6, 3, 6] : Multiset ℕ) (Real.logb 2 3 + 1 / 3) (by decide)
    d3_prod_fiber_1
    (by norm_num [lb_18, lb_6]; ring)
  have hpair : ∀ T : ℕ × ℕ → ℕ × ℕ, condEnt (dihBox 3) T (dihPairDial 3) =
      (1 / 4) * (uEnt {x ∈ dihBox 3 | dihPairDial 3 x = (0, 0)} T
        + uEnt {x ∈ dihBox 3 | dihPairDial 3 x = (0, 1)} T
        + uEnt {x ∈ dihBox 3 | dihPairDial 3 x = (1, 0)} T
        + uEnt {x ∈ dihBox 3 | dihPairDial 3 x = (1, 1)} T) := by
    intro T
    rw [condEnt, d3_pair_image]
    rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
      Finset.sum_insert (by decide), Finset.sum_singleton]
    rw [d3_pair_fiber (0, 0) (by decide), d3_pair_fiber (0, 1) (by decide),
      d3_pair_fiber (1, 0) (by decide), d3_pair_fiber (1, 1) (by decide), d3Box_card]
    ring
  have hprod : ∀ T : ℕ × ℕ → ℕ × ℕ, condEnt (dihBox 3) T (dihProdDial 3) =
      (1 / 2) * (uEnt {x ∈ dihBox 3 | dihProdDial 3 x = 0} T
        + uEnt {x ∈ dihBox 3 | dihProdDial 3 x = 1} T) := by
    intro T
    rw [condEnt, d3_prod_image, Finset.sum_range_succ, Finset.sum_range_one,
      d3_prod_fiber_0, d3_prod_fiber_1, d3Box_card]
    ring
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [hpair, u00, u01, u10, u11]; ring
  · rw [hprod, v0, v1]; ring
  · rw [hpair, o00, o01, o10, o11]; ring
  · rw [hprod, w0, w1]; ring

/-- **The `D₃` row.**  In the Chebotarev model of the `S₃ = D₃` field of `x³ - 2` (whose
quadratic subfield is `ℚ(√-3)`), the unordered hint value is again exactly `1/2` bit, the
ordered one exactly `1` bit. -/
theorem d3_hint_value_unordered : hintValue 3 (dihUn 3) = 1 / 2 := by
  obtain ⟨h1, h2, -, -⟩ := d3_condEnts
  rw [hintValue, mutInfo, mutInfo, h1, h2]; ring

theorem d3_hint_value_ordered : hintValue 3 (dihOrd 3) = 1 := by
  obtain ⟨-, -, h3, h4⟩ := d3_condEnts
  rw [hintValue, mutInfo, mutInfo, h3, h4]; ring

/-- **Dihedral universality of the hint value** (rows `D₃` and `D₅`): the hint value does not
depend on the degree — although the label entropies (`log₂ 3 + 13/18` vs `log₂ 5 - 9/50`) do. -/
theorem dihedral_hint_universal :
    hintValue 3 (dihUn 3) = hintValue 5 (dihUn 5) ∧
    hintValue 3 (dihOrd 3) = hintValue 5 (dihOrd 5) ∧
    uEnt (dihBox 5) (dihUn 5) < uEnt (dihBox 3) (dihUn 3) := by
  refine ⟨by rw [d3_hint_value_unordered, d5_hint_value_unordered],
    by rw [d3_hint_value_ordered, d5_hint_value_ordered.2.2], ?_⟩
  rw [d3_unordered_entropy, d5_unordered_entropy]
  have h3 := lb_three_gt
  have h5 := lb_five_lt
  linarith

/-! ## 8. The residue views at `m* = 320` -/

/-- **The joint view pins both characters.**  If two factor pairs have the same sum and the same
gap modulo `320`, then their factors agree modulo `160`, hence modulo the conductor `20`:
the joint residue view determines `χ₂₀(p)` and `χ₂₀(q)` separately. -/
theorem joint_view_determines_chi (p q p' q' : ℕ)
    (hs : (p + q) % 320 = (p' + q') % 320)
    (hd : ((q : ℤ) - p) % 320 = ((q' : ℤ) - p') % 320) :
    chi20 p = chi20 p' ∧ chi20 q = chi20 q' := by
  have hp : p % 20 = p' % 20 := by omega
  have hq : q % 20 = q' % 20 := by omega
  exact ⟨by rw [chi20, chi20, hp], by rw [chi20, chi20, hq]⟩

/-- **The product view pins only the product character**: `N mod 320` determines
`χ₂₀(N) = χ₂₀(p) χ₂₀(q)`. -/
theorem product_view_determines_chi_product (p q p' q' : ℕ)
    (hN : (p * q) % 320 = (p' * q') % 320) :
    chi20 p * chi20 q = chi20 p' * chi20 q' := by
  rw [← chi20_mul, ← chi20_mul]
  have : p * q % 20 = p' * q' % 20 := by omega
  rw [chi20, chi20, this]

/-- **The hint, with real primes.**  `11 · 13 ≡ 7 · 569 ≡ 143 (mod 320)`, so the product view
cannot tell these semiprimes apart; yet `x⁵ + 20x + 32` has one root modulo `11` and `13`
(type `[1,2,2]`, `χ₂₀ = -1`) and no root modulo `7` and `569` (`χ₂₀ = +1`).  The joint view
separates them: their sums differ mod `320`. -/
theorem product_view_merges_semiprimes :
    Nat.Prime 7 ∧ Nat.Prime 11 ∧ Nat.Prime 13 ∧ Nat.Prime 569 ∧
    (11 * 13) % 320 = (7 * 569) % 320 ∧
    rootCount 11 = 1 ∧ rootCount 13 = 1 ∧ rootCount 7 = 0 ∧ rootCount 569 = 0 ∧
    chi20 11 = -1 ∧ chi20 13 = -1 ∧ chi20 7 = 1 ∧ chi20 569 = 1 ∧
    (11 + 13) % 320 ≠ (7 + 569) % 320 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by decide, by decide,
    by decide, by decide, by decide, by decide, by decide, by decide, by norm_num⟩

/-- **THE-D5-DIAL-CARRIES-A-HINT — verdict.**  The Chebotarev-limit hint value of the `D₅` dial
is strictly positive (`1/2`), and the round-35 reading `0.6940` lies strictly between the
unordered limit `1/2` and the ordered limit `1`: it is consistent with a positive hint plus a
finite-sample excess, and it cannot be the ordered law. -/
theorem d5_verdict :
    0 < hintValue 5 (dihUn 5) ∧ hintValue 5 (dihUn 5) < (0.6940 : ℝ) ∧
    (0.6940 : ℝ) < hintValue 5 (dihOrd 5) := by
  rw [d5_hint_value_unordered, d5_hint_value_ordered.2.2]
  norm_num

end D5Hint