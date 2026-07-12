/-
# The exact Ramsey number `R(4,4) = 18`

Building on `Applications.Ramsey` (the arrow relation `Arrows n s t`, the
Erdős–Szekeres recursion `arrows_step`, and `R(3,3) = 6`) and
`Applications.RamseyThreeFour` (`R(3,4) = 9`), this file pins down the classical
diagonal value `R(4,4) = 18`.

* `arrows_symm`              : `Arrows n s t → Arrows n t s` (red/blue symmetry).
* `arrows_four_three`        : `Arrows 9 4 3` (the colour-swap of `R(3,4) = 9`).
* `arrows_four_four`         : `Arrows 18 4 4`, every 2-colouring of `K₁₈` has a
                               monochromatic `K₄`.  Obtained from the single
                               Erdős–Szekeres step `9 + 9 → (4, 4)`.
* `not_arrows_seventeen_four_four` : `¬ Arrows 17 4 4`, witnessed by the
                               **Paley graph** on `ℤ/17` (the unique extremal
                               colouring of `K₁₇`).
* `ramsey_four_four`         : `Arrows 18 4 4 ∧ ¬ Arrows 17 4 4`, i.e. `R(4,4) = 18`.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib
import Applications.RamseyThreeFour

open scoped Classical
open SimpleGraph Finset

namespace RamseyTheory

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): R(4,4) = 18.  Unlike R(3,4), the *upper* bound here is
already tight from pure Erdős–Szekeres recursion: R(4,4) ≤ R(3,4) + R(4,3) =
9 + 9 = 18 (no parity refinement needed).  The *lower* bound R(4,4) > 17 should
come from a single highly symmetric self-complementary construction, conjecturally
the Paley graph on the field 𝔽₁₇.

EXPERIMENT (Experimenter): the colour-swap symmetry `Arrows n s t → Arrows n t s`
turns `R(3,4) = 9` into `R(4,3) = 9` for free, and one application of `arrows_step`
yields `Arrows 18 4 4`.  For the lower bound, the Paley graph on ℤ/17 (difference
set = nonzero quadratic residues {1,2,4,8,9,13,15,16}) was certified clique-free
of order 4 in both colours; since 17 ≡ 1 (mod 4) the residue set is symmetric, so
`fromRel` produces exactly this graph and it is self-complementary.
-/

/-! ## Red/blue symmetry of the arrow relation -/

/--
**Colour-swap symmetry.** Swapping the two colours (replacing a colouring by its
complement) turns `n → (s, t)` into `n → (t, s)`.  Applying `Arrows n s t` to the
complement `Gᶜ` produces a red `s`-clique of `Gᶜ` (a blue `s`-clique of `G`) or a
blue `t`-clique of `Gᶜᶜ = G` (a red `t`-clique of `G`).
-/
theorem arrows_symm {n s t : ℕ} (h : Arrows n s t) : Arrows n t s := by
  intro V _ G W hW
  rcases h Gᶜ W hW with ⟨S, hSsub, hSc⟩ | ⟨S, hSsub, hSc⟩
  · exact Or.inr ⟨S, hSsub, hSc⟩
  · refine Or.inl ⟨S, hSsub, ?_⟩
    rwa [compl_compl] at hSc

/-- `R(4,3) = 9` upper bound: the colour-swap of `arrows_three_four`. -/
theorem arrows_four_three : Arrows 9 4 3 := arrows_symm arrows_three_four

/-! ## Upper bound `R(4,4) ≤ 18` -/

/--
**Upper bound.** Every red/blue colouring of `K₁₈` contains a monochromatic `K₄`,
i.e. `Arrows 18 4 4`.  This is the single Erdős–Szekeres step
`9 → (3,4)` and `9 → (4,3)` ⟹ `18 → (4,4)`.
-/
theorem arrows_four_four : Arrows 18 4 4 :=
  arrows_step (m := 9) (n := 9) (s := 3) (t := 3)
    (by norm_num) (by norm_num) arrows_three_four arrows_four_three

/-! ## Lower bound `R(4,4) > 17` via the Paley graph on `ℤ/17` -/

/-- The nonzero quadratic residues modulo `17`, i.e. the squares
`{1,2,4,8,9,13,15,16}`.  Because `17 ≡ 1 (mod 4)`, `-1` is a residue and this set
is symmetric under negation, so it defines a genuine (undirected) graph. -/
def QR17 : Finset (Fin 17) := {1, 2, 4, 8, 9, 13, 15, 16}

/-- The **Paley graph** on `ℤ/17`: vertices `a, b` are red-adjacent iff their
difference is a nonzero quadratic residue.  This is the unique extremal colouring
of `K₁₇` witnessing `R(4,4) > 17`; it is self-complementary. -/
def paley17 : SimpleGraph (Fin 17) := SimpleGraph.fromRel (fun a b => (a - b) ∈ QR17)

instance : DecidableRel paley17.Adj := by unfold paley17; infer_instance

/-- The Paley graph on `17` vertices has no red `K₄`. -/
theorem paley17_no_red_K4 : ¬ ∃ S : Finset (Fin 17), paley17.IsNClique 4 S := by
  native_decide

/-- The complement of the Paley graph on `17` vertices has no blue `K₄`. -/
theorem paley17_no_blue_K4 : ¬ ∃ S : Finset (Fin 17), paley17ᶜ.IsNClique 4 S := by
  native_decide

/-- **Lower bound.** The Paley colouring of `K₁₇` has neither a red `K₄` nor a
blue `K₄`, so `¬ Arrows 17 4 4`, i.e. `R(4,4) > 17`. -/
theorem not_arrows_seventeen_four_four : ¬ Arrows 17 4 4 := by
  intro h
  have := h paley17 Finset.univ (by simp)
  rcases this with ⟨S, _, hS⟩ | ⟨S, _, hS⟩
  · exact paley17_no_red_K4 ⟨S, hS⟩
  · exact paley17_no_blue_K4 ⟨S, hS⟩

/-- **The exact value `R(4,4) = 18`.** -/
theorem ramsey_four_four : Arrows 18 4 4 ∧ ¬ Arrows 17 4 4 :=
  ⟨arrows_four_four, not_arrows_seventeen_four_four⟩

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst): The R(4,4) upper bound is *purely recursive* — in sharp
contrast to R(3,4), where the binomial bound (10) overshoots the truth (9) and a
handshake-parity obstruction is required.  Here Erdős–Szekeres gives
R(4,4) ≤ R(3,4) + R(4,3) = 18, and the binomial bound C(6,3) = 20 is the looser
estimate.  The colour symmetry `arrows_symm` is the missing ingredient that lets
a single off-diagonal value `R(3,4)` feed both recursive branches.

The lower bound is genuinely *algebraic*: the Paley graph derives its
clique-freeness from the multiplicative structure of 𝔽₁₇.  No 4 vertices can be
mutually adjacent because that would require 4 elements pairwise differing by
quadratic residues, which the finite field forbids — certified here exhaustively.

CRITIQUE (Critic): `arrows_four_four` is not a `decide`-style result: it threads
`arrows_step`, `arrows_symm`, and the imported `arrows_three_four` together.  The
two Paley facts use `native_decide`, but only to certify a *fixed finite
construction* (exactly as the `decide` certificates for R(3,3) and R(3,4)); they
are supporting lemmas, while the headline `ramsey_four_four` couples them with the
recursive upper bound.  The residue set is symmetric (17 ≡ 1 mod 4), so `fromRel`
faithfully encodes the Paley graph rather than an accidental orientation.

SYNTHESIS (PI): With `arrows_symm` added to the toolkit, the full diagonal/near-
diagonal block R(3,3)=6, R(3,4)=9, R(4,4)=18 is now formalised on one common
`Arrows` framework.  The three sharp values exhibit three *different* extremal
mechanisms: recursion (R(3,3)), recursion+parity (R(3,4)), and recursion+algebraic
construction (R(4,4)).
-/

end RamseyTheory