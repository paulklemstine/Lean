/-
# HINT-SIZE-SCALING, part II: the four plateaus of exp 464 in closed form

Exact Dirichlet–Chebotarev values of the four hint dials of FACT round 37 #1, via the
residue-lift and residual theorems of `Logic.HintSizeScaling`:

| dial    | field                 | exact hint value                  | reported (k=14/18/22)  |
|---------|-----------------------|-----------------------------------|------------------------|
| `S₃@31` | `x³ + x + 1`          | `1/2`                     (0.5)   | 0.5584 / 0.5425 / 0.5415 |
| `C₃@7`  | cubic in `ℚ(ζ₇)`      | `log₂ 3 - 2/3`         (0.91830)  | 0.9115 / 0.9140 / 0.9169 |
| `D₄@8`  | `x⁴ - 2`              | `3/2 - (9/32) log₂ 3`  (1.05423)  | 1.0540 / 1.0536 / 1.0507 |
| `C₅@11` | quintic in `ℚ(ζ₁₁)`   | `log₂ 5 - (12/25) log₂ 3 - 16/25` (0.92115) | 0.9030 / 0.9190 / 0.9268 |

and the residuals `H(L | p mod m*, q mod m*)`: `log₂ 3 - 7/9` (`S₃`), `15/32` (`D₄`), `0`
(`C₃`, `C₅`).

## Main results

* `s3_hint_exact`, `s3_hint_universal`, `s3_hint_size_stable` — the `S₃` plateau is exactly
  `1/2` at conductor `31`, at every conductor with a surjective quadratic dial, and at every
  size.  `s3_residual`, `s3_residual_pos`, `s3_pool_ceiling`, `s3_pool_floor_window` — the
  residual `log₂ 3 - 7/9 > 0` and the pool ceiling `log₂ 3 - 5/18`; the anomalous `k = 10`
  reading `0.7423` lies strictly between the plateau and the ceiling, as the pool-floor
  diagnosis requires.
* `d4_hint_exact`, `d4_residual` — identification of the `D₄@8` labels as root counts of
  `x⁴ - 2` and the exact plateau `3/2 - (9/32) log₂ 3`, with residual `15/32`: `D₄` is *not*
  an abelian dial.
* `c3_hint_exact`, `c3_hint_eq_hintMap`, `c5_hint_exact`, `c5_hint_eq_hintMap`,
  `cyc_residual_zero` — the abelian plateaus equal the catalog's exponent-model hint map
  `SexticHintValue.hintMap 3`, `hintMap 5`, with residual exactly `0`.
* `s3_rootCount_check`, `d4_rootCount_check` — kernel-checked confirmation of the dial laws on
  all primes below `200`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): each reported plateau is a finite-sample reading of an exact
  dial-box constant; the `D₄` battery uses root-count labels.
Experiment (Stage 2): enumeration of the dial boxes (`36`, `64`, `36`, `100` points) gave
  `0.500000, 1.054229, 0.918296, 0.921146`; the `D₄` box with *cycle-type* labels gives
  `1.193599`, ruling that encoding out, while root-count labels give `1.054229`, matching the
  reported `1.0540 / 1.0536`.
Analysis (Stage 3): abelian readings sit within `0.8%` (`C₃`) and `2.0%` (`C₅`) of the exact
  values, `D₄` within `0.4%`; the `S₃` readings are biased upward by `≈ 0.04` bits — the
  plateau is size-stable, but it is not the exact value.
Critique (Stage 4): the identification of the `S₃` and `D₄` fields is confirmed on the
  character/root-count tables for `p < 200` only (no Galois theory of the polynomials); the
  Chebotarev coin is modelled as uniform and independent of the residue given the dial.
-/
import Logic.HintSizeScaling
import Physics.SexticHintValue

namespace HintSizeScaling

open Finset CyclicTypeChannel

set_option maxRecDepth 100000

private lemma lb2' : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)
private lemma lb1' : Real.logb 2 (1 : ℝ) = 0 := Real.logb_one
private lemma lb3_eq : Real.logb 2 (3 : ℝ) = Real.logb 2 3 := rfl
private lemma lb20' : Real.logb 2 (20 : ℝ) = 2 + Real.logb 2 5 := by
  rw [show (20 : ℝ) = 4 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4]

/-! ## 1. `S₃` at conductor `31`: the cubic `x³ + x + 1` (discriminant `-31`) -/

instance fact_prime_31 : Fact (Nat.Prime 31) := ⟨by norm_num⟩

/-- The quadratic dial of the `S₃` cubic of discriminant `-31`: the Legendre symbol mod `31`
as a homomorphism `(ℤ/31)ˣ → ℤˣ`. -/
noncomputable def psi31 : (ZMod 31)ˣ →* ℤˣ := (quadraticChar (ZMod 31)).toUnitHom

theorem psi31_surjective : Function.Surjective psi31 := by
  intro h
  rcases Int.units_eq_one_or h with rfl | rfl
  · exact ⟨1, map_one _⟩
  · refine ⟨Units.mk0 3 (by decide), ?_⟩
    apply Units.ext
    rw [psi31, MulChar.coe_toUnitHom, Units.val_mk0]
    simp only [Units.val_neg, Units.val_one]
    exact quadraticChar_neg_one_iff_not_isSquare.2 (by decide)

/-- Root count of `x³ + x + 1` modulo a prime with dial value `h` and Chebotarev coin `c`:
non-residues (Frobenius a transposition) have `1` root; residues split completely (`3` roots)
for coin `0` and are inert (`0` roots, Frobenius a `3`-cycle) for coins `1, 2`. -/
def s3Roots (h : ℤˣ) (c : Fin 3) : ℕ := if h = -1 then 1 else if c = 0 then 3 else 0

/-- The `S₃` label: the unordered pair of root counts of `x³ + x + 1` mod `p` and mod `q`. -/
def s3Label (d : ℤˣ × ℤˣ) (c : Fin 3 × Fin 3) : ℕ × ℕ :=
  (min (s3Roots d.1 c.1) (s3Roots d.2 c.2), max (s3Roots d.1 c.1) (s3Roots d.2 c.2))

/-- Experimental check of the dial: for every prime `3 ≤ p < 200`, `p ≠ 31`, the cubic
`x³ + x + 1` has `0`, `1` or `3` roots mod `p`, and exactly one root iff `p` is a quadratic
non-residue mod `31` (Euler's criterion `p¹⁵ ≡ -1`). -/
theorem s3_rootCount_check : ∀ p ∈ [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 37, 41, 43, 47, 53, 59,
    61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157,
    163, 167, 173, 179, 181, 191, 193, 197, 199],
    let r := ((List.range p).filter (fun x => (x ^ 3 + x + 1) % p = 0)).length
    (r = 0 ∨ r = 1 ∨ r = 3) ∧ (r = 1 ↔ p ^ 15 % 31 = 30) := by
  decide

/-- Dial-box entropy of the `S₃` label: `log₂ 3 + 13/18`. -/
theorem s3_dial_uEnt : uEnt (univ : Finset ((ℤˣ × ℤˣ) × (Fin 3 × Fin 3))) (dialLabel s3Label)
    = Real.logb 2 3 + 13 / 18 := by
  rw [uEnt_eq_countSum _ _ (↑[1, 4, 4, 6, 9, 12] : Multiset ℕ) (by decide)]
  simp only [card_univ, Fintype.card_prod, Fintype.card_units_int, Fintype.card_fin]
  norm_num [lb1', lb_4, lb_6, lb_9, lb_12, lb_36]
  ring

/-- Dial-box pair row: `I(L ; χ(p), χ(q)) = 3/2`. -/
theorem s3_dial_pair : mutInfo (univ : Finset ((ℤˣ × ℤˣ) × (Fin 3 × Fin 3))) (dialLabel s3Label)
    pairView = 3 / 2 := by
  rw [mutInfo_eq_symm_form, s3_dial_uEnt,
    uEnt_eq_countSum _ (pairView (C := Fin 3 × Fin 3)) (↑[9, 9, 9, 9] : Multiset ℕ) (by decide),
    uEnt_eq_countSum _ _ (↑[1, 3, 3, 4, 4, 6, 6, 9] : Multiset ℕ) (by decide)]
  simp only [card_univ, Fintype.card_prod, Fintype.card_units_int, Fintype.card_fin]
  norm_num [lb1', lb2', lb_4, lb_6, lb_9, lb_36]
  ring

/-- Dial-box product row: `I(L ; χ(N)) = 1`. -/
theorem s3_dial_prod : mutInfo (univ : Finset ((ℤˣ × ℤˣ) × (Fin 3 × Fin 3))) (dialLabel s3Label)
    prodView = 1 := by
  rw [mutInfo_eq_symm_form, s3_dial_uEnt,
    uEnt_eq_countSum _ (prodView (C := Fin 3 × Fin 3)) (↑[18, 18] : Multiset ℕ) (by decide),
    uEnt_eq_countSum _ _ (↑[1, 4, 4, 6, 9, 12] : Multiset ℕ) (by decide)]
  simp only [card_univ, Fintype.card_prod, Fintype.card_units_int, Fintype.card_fin]
  have h18 : Real.logb 2 (18 : ℝ) = 1 + 2 * Real.logb 2 3 := by
    rw [show (18 : ℝ) = 2 * 9 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb2', lb_9]
  norm_num [lb1', lb2', lb_4, lb_6, lb_9, lb_12, lb_36, h18]
  ring

/-- **THE S₃ PLATEAU IS EXACTLY HALF A BIT.**  On the residue box mod `31` (factor residues
uniform on `(ℤ/31)ˣ`, Frobenius uniform on `S₃` given the quadratic character — the
Dirichlet–Chebotarev law of the experiment), the hint value
`I(L ; p mod 31, q mod 31) - I(L ; N mod 31)` is exactly `1/2` bit.  The reported plateau
`0.5425 / 0.5415` sits `+0.04` above it: the plug-in bias of the `900`-cell pair view. -/
theorem s3_hint_exact :
    hint (liftLabel psi31 s3Label) (pairView (C := Fin 3 × Fin 3)) prodView = 1 / 2 := by
  rw [hint_residue_lift psi31 psi31_surjective, hint, s3_dial_pair, s3_dial_prod]
  norm_num

/-- **S₃ universality across conductors.**  For *any* finite abelian conductor group and any
surjective quadratic dial, the `S₃` hint value is `1/2`: the plateau depends neither on the
factor size nor on the conductor. -/
theorem s3_hint_universal {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]
    (ψ : G →* ℤˣ) (hψ : Function.Surjective ψ) :
    hint (liftLabel ψ s3Label) (pairView (C := Fin 3 × Fin 3)) prodView = 1 / 2 := by
  rw [hint_residue_lift ψ hψ, hint, s3_dial_pair, s3_dial_prod]
  norm_num

/-- **S₃ size-stability.**  Replicating every residue class mod `31` by any number of prime
identities (any factor size `k`) leaves the hint value at exactly `1/2`. -/
theorem s3_hint_size_stable (F : Type*) [Fintype F] [Nonempty F] :
    hint (fun x : (((ZMod 31)ˣ × (ZMod 31)ˣ) × (Fin 3 × Fin 3)) × F =>
        liftLabel psi31 s3Label x.1)
      (fun x => pairView (C := Fin 3 × Fin 3) x.1)
      (fun x => prodView (C := Fin 3 × Fin 3) x.1) = 1 / 2 := by
  rw [hint_blowup, s3_hint_exact]

/-- The residue-level label entropy of the `S₃` battery mod `31`. -/
theorem s3_uEnt : uEnt univ (liftLabel psi31 s3Label (C := Fin 3 × Fin 3))
    = Real.logb 2 3 + 13 / 18 := by
  rw [← s3_dial_uEnt]
  exact uEnt_transport (dialMap psi31) _ (pow_pos (kerCard_pos psi31) 2)
    (card_fiber_dialMap psi31 psi31_surjective) (dialLabel s3Label)

/-- **The S₃ residual is strictly positive**: `H(L | p mod 31, q mod 31) = log₂ 3 - 7/9`
(`≈ 0.807` bits).  The `S₃` label is *not* a residue function — the Frobenius coin of the
quadratic residues is invisible to every residue view. -/
theorem s3_residual : condEnt univ (liftLabel psi31 s3Label) (pairView (C := Fin 3 × Fin 3))
    = Real.logb 2 3 - 7 / 9 := by
  have h := mutInfo_pair_lift (C := Fin 3 × Fin 3) psi31 psi31_surjective s3Label
  rw [s3_dial_pair, mutInfo, s3_uEnt] at h
  linarith

theorem s3_residual_pos :
    0 < condEnt univ (liftLabel psi31 s3Label) (pairView (C := Fin 3 × Fin 3)) := by
  rw [s3_residual]; linarith [lb_three_gt]

/-- **The S₃ pool-floor ceiling**: `H(L | N mod 31) = log₂ 3 - 5/18` (`≈ 1.307` bits).  A pool
too thin to resolve the residue classes can inflate the hint value from `1/2` up to this ceiling
(`hint_le_condEnt`, attained by `hint_eq_condEnt_of_injective`); the observed `k = 10` reading
`0.7423` lies strictly inside the window `(1/2, log₂ 3 - 5/18)`. -/
theorem s3_pool_ceiling : condEnt univ (liftLabel psi31 s3Label) (prodView (C := Fin 3 × Fin 3))
    = Real.logb 2 3 - 5 / 18 := by
  have h := mutInfo_prod_lift (C := Fin 3 × Fin 3) psi31 psi31_surjective s3Label
  rw [s3_dial_prod, mutInfo, s3_uEnt] at h
  linarith

theorem s3_pool_floor_window :
    (1 / 2 : ℝ) < 0.7423 ∧ (0.7423 : ℝ) < Real.logb 2 3 - 5 / 18 := by
  constructor
  · norm_num
  · linarith [lb_three_gt]

/-! ## 2. `D₄` at conductor `8`: the quartic `x⁴ - 2` -/

/-- Root count of `x⁴ - 2` modulo a prime with residue `h mod 8` and Chebotarev coin `c`:
`p ≡ 1 (8)`: `4` roots (coin `0`, Frobenius trivial) or `0` roots (coin `1`, central
rotation); `p ≡ 7 (8)`: `2` roots (a vertex reflection); `p ≡ 3, 5 (8)`: `0` roots. -/
def d4Roots (h : (ZMod 8)ˣ) (c : Fin 2) : ℕ :=
  if h = 1 then (if c = 0 then 4 else 0) else if (h : ZMod 8) = 7 then 2 else 0

/-- The `D₄` label: the unordered pair of root counts of `x⁴ - 2` mod `p` and mod `q`. -/
def d4Label (d : (ZMod 8)ˣ × (ZMod 8)ˣ) (c : Fin 2 × Fin 2) : ℕ × ℕ :=
  (min (d4Roots d.1 c.1) (d4Roots d.2 c.2), max (d4Roots d.1 c.1) (d4Roots d.2 c.2))

/-- Experimental check of the `D₄` root law for every odd prime `p < 200`. -/
theorem d4_rootCount_check : ∀ p ∈ [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59,
    61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157,
    163, 167, 173, 179, 181, 191, 193, 197, 199],
    let r := ((List.range p).filter (fun x => (x ^ 4 + (p - 2)) % p = 0)).length
    (p % 8 = 1 → r = 0 ∨ r = 4) ∧ (p % 8 = 7 → r = 2) ∧ (p % 8 = 3 ∨ p % 8 = 5 → r = 0) := by
  decide

instance : Fintype (ZMod 8)ˣ := inferInstance

theorem card_units_8 : Fintype.card (ZMod 8)ˣ = 4 := by decide

theorem d4_uEnt : uEnt (univ : Finset (((ZMod 8)ˣ × (ZMod 8)ˣ) × (Fin 2 × Fin 2)))
    (dialLabel d4Label) = 6 - 33 / 32 - (5 / 4) * Real.logb 2 5 := by
  rw [uEnt_eq_countSum _ _ (↑[1, 4, 4, 10, 20, 25] : Multiset ℕ) (by decide)]
  simp only [card_univ, Fintype.card_prod, card_units_8, Fintype.card_fin]
  norm_num [lb1', lb_4, lb_10, lb20', lb_25, lb_64]
  ring

/-- `D₄` pair row: `I(L ; p mod 8, q mod 8) = 9/2 - (5/4) log₂ 5`. -/
theorem d4_pair : mutInfo (univ : Finset (((ZMod 8)ˣ × (ZMod 8)ˣ) × (Fin 2 × Fin 2)))
    (dialLabel d4Label) pairView = 9 / 2 - (5 / 4) * Real.logb 2 5 := by
  rw [mutInfo_eq_symm_form, d4_uEnt,
    uEnt_eq_countSum _ (pairView (C := Fin 2 × Fin 2))
      (↑[4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4] : Multiset ℕ) (by decide),
    uEnt_eq_countSum _ _ (↑[1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 4,
      4, 4] : Multiset ℕ) (by decide)]
  simp only [card_univ, Fintype.card_prod, card_units_8, Fintype.card_fin]
  norm_num [lb1', lb2', lb_4, lb_64]
  ring

/-- `D₄` product row: `I(L ; N mod 8) = 3 - (5/4) log₂ 5 + (9/32) log₂ 3`. -/
theorem d4_prod : mutInfo (univ : Finset (((ZMod 8)ˣ × (ZMod 8)ˣ) × (Fin 2 × Fin 2)))
    (dialLabel d4Label) prodView = 3 - (5 / 4) * Real.logb 2 5 + (9 / 32) * Real.logb 2 3 := by
  rw [mutInfo_eq_symm_form, d4_uEnt,
    uEnt_eq_countSum _ (prodView (C := Fin 2 × Fin 2)) (↑[16, 16, 16, 16] : Multiset ℕ)
      (by decide),
    uEnt_eq_countSum _ _ (↑[1, 2, 4, 4, 4, 4, 4, 4, 4, 8, 8, 8, 9] : Multiset ℕ) (by decide)]
  simp only [card_univ, Fintype.card_prod, card_units_8, Fintype.card_fin]
  norm_num [lb1', lb2', lb_4, lb_8, lb_9, lb_16, lb_64]
  ring

/-- **THE D₄ PLATEAU.**  The `D₄` hint value of the root-count battery of `x⁴ - 2` at
`m* = 8` is exactly `3/2 - (9/32) log₂ 3 ≈ 1.05423` bits (reported `1.0540 / 1.0536 / 1.0507`
at `k = 14 / 18 / 22`). -/
theorem d4_hint_exact :
    hint (dialLabel d4Label) (pairView (C := Fin 2 × Fin 2)) prodView
      = 3 / 2 - (9 / 32) * Real.logb 2 3 := by
  rw [hint, d4_pair, d4_prod]; ring

/-- **The D₄ residual**: `H(L | p mod 8, q mod 8) = 15/32` exactly — positive, because the
coin of the class `p ≡ 1 (8)` (is `2` a quartic residue?) is invisible mod `8`. -/
theorem d4_residual : condEnt (univ : Finset (((ZMod 8)ˣ × (ZMod 8)ˣ) × (Fin 2 × Fin 2)))
    (dialLabel d4Label) pairView = 15 / 32 := by
  have h := d4_pair
  rw [mutInfo, d4_uEnt] at h
  linarith

/-! ## 3. The abelian dials: `C₃` at `7` and `C₅` at `11` -/

instance fact_prime_7' : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance fact_prime_11' : Fact (Nat.Prime 11) := ⟨by norm_num⟩

/-- Residue degree of `p` in the cyclic field of conductor `f` and odd prime degree `n` inside
`ℚ(ζ_f)⁺`: `1` if `p ≡ ±1 (f)`, otherwise `n` (here `(f - 1)/2 = n`). -/
def cycType {f : ℕ} (n : ℕ) (a : (ZMod f)ˣ) : ℕ := if a = 1 ∨ a = -1 then 1 else n

/-- The abelian label: unordered pair of residue degrees — a *residue function*. -/
def cycLabel {f : ℕ} (n : ℕ) (x : ((ZMod f)ˣ × (ZMod f)ˣ) × Unit) : ℕ × ℕ :=
  (min (cycType n x.1.1) (cycType n x.1.2), max (cycType n x.1.1) (cycType n x.1.2))

/-- **Abelian residual entropy is exactly zero** (at every size, every conductor). -/
theorem cyc_residual_zero {f : ℕ} [NeZero f] (n : ℕ) :
    condEnt univ (cycLabel (f := f) n) (pairView (C := Unit)) = 0 :=
  condEnt_eq_zero_of_factor _ _ _ (fun d => cycLabel n (d, ())) fun _ _ => rfl

theorem card_units_7' : Fintype.card (ZMod 7)ˣ = 6 := by
  rw [ZMod.card_units_eq_totient]; decide

theorem card_units_11' : Fintype.card (ZMod 11)ˣ = 10 := by
  rw [ZMod.card_units_eq_totient]; decide

/-- **THE C₃ PLATEAU**: the cubic subfield of `ℚ(ζ₇)` gives hint value exactly
`log₂ 3 - 2/3 ≈ 0.91830` (reported `0.9115 / 0.9140 / 0.9169`), equal to the catalog's
exponent-model value `hintMap 3`. -/
theorem c3_hint_exact :
    hint (cycLabel (f := 7) 3) (pairView (C := Unit)) prodView = Real.logb 2 3 - 2 / 3 := by
  rw [hint_eq_condEnt_of_residue_function (cycLabel 3) pairView prodView
      (fun d => cycLabel 3 (d, ())) (fun _ => rfl),
    condEnt_eq_uEnt_pair_sub,
    uEnt_eq_countSum _ _ (↑[2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4] : Multiset ℕ) (by decide),
    uEnt_eq_countSum _ (prodView (C := Unit)) (↑[6, 6, 6, 6, 6, 6] : Multiset ℕ) (by decide)]
  simp only [card_univ, Fintype.card_prod, card_units_7', Fintype.card_unit]
  norm_num [lb2', lb_4, lb_6]
  ring

theorem c3_hint_eq_hintMap :
    hint (cycLabel (f := 7) 3) (pairView (C := Unit)) prodView = SexticHintValue.hintMap 3 := by
  rw [c3_hint_exact, SexticHintValue.hintMap_three]

/-- **THE C₅ PLATEAU**: the quintic subfield of `ℚ(ζ₁₁)` gives hint value exactly
`log₂ 5 - (12/25) log₂ 3 - 16/25 ≈ 0.92115` (reported `0.9030 / 0.9190 / 0.9268`), equal to
the catalog's `hintMap 5`. -/
theorem c5_hint_exact :
    hint (cycLabel (f := 11) 5) (pairView (C := Unit)) prodView
      = Real.logb 2 5 - (12 / 25) * Real.logb 2 3 - 16 / 25 := by
  rw [hint_eq_condEnt_of_residue_function (cycLabel 5) pairView prodView
      (fun d => cycLabel 5 (d, ())) (fun _ => rfl),
    condEnt_eq_uEnt_pair_sub,
    uEnt_eq_countSum _ _ (↑[2, 2, 4, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6, 6, 6, 6, 6, 8, 8] :
      Multiset ℕ) (by decide),
    uEnt_eq_countSum _ (prodView (C := Unit)) (↑[10, 10, 10, 10, 10, 10, 10, 10, 10, 10] :
      Multiset ℕ) (by decide)]
  simp only [card_univ, Fintype.card_prod, card_units_11', Fintype.card_unit]
  norm_num [lb2', lb_4, lb_6, lb_8, lb_10, lb_100]
  ring

theorem c5_hint_eq_hintMap :
    hint (cycLabel (f := 11) 5) (pairView (C := Unit)) prodView = SexticHintValue.hintMap 5 := by
  rw [c5_hint_exact, SexticHintValue.hintMap_five]

end HintSizeScaling