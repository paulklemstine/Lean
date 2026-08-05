import Mathlib

/-!
# Non-interactive zero knowledge: the Fiat–Shamir transform in the random-oracle model

An interactive `Σ`-protocol (commit `a`, random challenge `c`, response `r`) is made
*non-interactive* by replacing the verifier's coin flips with the value `H a` of a hash
function. In the random-oracle model the hash function is drawn uniformly from the finite
set of *all* functions `Msg → Chal`, and this file carries out the resulting exact
counting.

## Main results

* `fiber_card_const` — for a fixed query `a`, all the fibers `{H | H a = c}` have the same
  size. Equivalently: *the value of a random oracle at a point is uniformly distributed*,
  and reprogramming the oracle at one point is undetectable — the counting fact behind
  zero knowledge of the transformed protocol.
* `fiber_prob` — the probability that a uniform oracle sends `a` to a fixed challenge is
  exactly `1/|Chal|`.
* `hashHits_card_mul` and `fsError_eq` — the probability that `H a` lands in a set `B` of
  bad challenges is exactly `|B|/|Chal|`, i.e. Fiat–Shamir with a single fixed first
  message inherits the soundness error of the interactive protocol.
* `fs_union_bound` — a cheating prover that may try any first message from a set `A₀`
  succeeds with probability at most `|A₀| · d / |Chal|`, where `d` bounds the number of
  answerable challenges.
* `SigmaProtocol.fiat_shamir_soundness` — the same statement for a `d`-special-sound
  `Σ`-protocol on a false statement: the non-interactive proof system is sound with error
  `|A₀| · d / |Chal|`.
-/

open Finset

namespace ZKFiatShamir

variable {A C : Type*} [Fintype A] [DecidableEq A] [Fintype C] [DecidableEq C]

/-! ## Random oracles: exact fiber counting -/

/-- The set of oracles sending the query `a` to the answer `c`. -/
def fiber (a : A) (c : C) : Finset (A → C) := univ.filter fun H => H a = c

/-- **Reprogramming a random oracle at one point is undetectable**: all fibers over a
fixed query have the same cardinality. -/
theorem fiber_card_const (a : A) (c₁ c₂ : C) : (fiber a c₁).card = (fiber a c₂).card := by
  apply Finset.card_nbij' (fun H => Function.update H a c₂) (fun H => Function.update H a c₁)
    <;> intro H hH <;> simp_all [fiber, funext_iff, Function.update_apply]

/-- The fibers over a fixed query partition the space of oracles. -/
theorem sum_fiber_card (a : A) : ∑ c : C, (fiber a c).card = Fintype.card (A → C) := by
  simp only [fiber]
  rw [← Finset.card_univ (α := A → C)]
  exact (Finset.card_eq_sum_card_fiberwise fun H _ => mem_univ (H a)).symm

/-- Exact uniformity: `|{H | H a = c}| · |Chal| = |Msg → Chal|`. -/
theorem fiber_card_mul (a : A) (c : C) :
    (fiber a c).card * Fintype.card C = Fintype.card (A → C) := by
  rw [← sum_fiber_card a, Finset.sum_congr rfl fun c' _ => fiber_card_const a c' c,
    Finset.sum_const, smul_eq_mul, Finset.card_univ, mul_comm]

/-- The probability that a uniformly random oracle answers `c` on the query `a` is
`1/|Chal|`. -/
theorem fiber_prob [Nonempty C] (a : A) (c : C) :
    ((fiber a c).card : ℝ) / Fintype.card (A → C) = 1 / Fintype.card C := by
  have hC : (0 : ℝ) < Fintype.card C := by exact_mod_cast Fintype.card_pos_iff.mpr ‹Nonempty C›
  have hAC : (0 : ℝ) < Fintype.card (A → C) := by
    have : Nonempty (A → C) := ⟨fun _ => Classical.arbitrary C⟩
    exact_mod_cast Fintype.card_pos_iff.mpr this
  have h : ((fiber a c).card : ℝ) * Fintype.card C = Fintype.card (A → C) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) (fiber_card_mul a c)
  field_simp
  linarith [h]

/-! ## Soundness of the Fiat–Shamir transform -/

/-- The oracles whose answer on `a` lies in the "bad" set `B`. -/
def hashHits (a : A) (B : Finset C) : Finset (A → C) := univ.filter fun H => H a ∈ B

/-- Exact count of the bad oracles: `|{H | H a ∈ B}| · |Chal| = |B| · |Msg → Chal|`. -/
theorem hashHits_card_mul (a : A) (B : Finset C) :
    (hashHits a B).card * Fintype.card C = B.card * Fintype.card (A → C) := by
  have hsplit : (hashHits a B).card = ∑ c ∈ B, (fiber a c).card := by
    have h := Finset.card_eq_sum_card_fiberwise
      (f := fun H : A → C => H a) (s := hashHits a B) (t := B)
      (fun H hH => by simpa [hashHits] using hH)
    refine h.trans (Finset.sum_congr rfl fun c hc => ?_)
    congr 1
    ext H
    simp only [hashHits, mem_filter, mem_univ, true_and, fiber]
    exact ⟨fun h => h.2, fun h => ⟨h ▸ hc, h⟩⟩
  rcases B.eq_empty_or_nonempty with rfl | ⟨c₀, hc₀⟩
  · simp [hsplit]
  · have hconst : ∑ c ∈ B, (fiber a c).card = B.card * (fiber a c₀).card := by
      rw [Finset.sum_congr rfl fun c _ => fiber_card_const a c c₀]
      simp
    rw [hsplit, hconst, mul_assoc, fiber_card_mul a c₀]

/-- The soundness error of the Fiat–Shamir transform for a single first message `a`:
the fraction of oracles that hand the prover a bad challenge. -/
noncomputable def fsError (a : A) (B : Finset C) : ℝ :=
  ((hashHits a B).card : ℝ) / Fintype.card (A → C)

/-- **The transform preserves the soundness error exactly**: the probability that a
uniform oracle produces a challenge in `B` equals `|B|/|Chal|`, the acceptance probability
of the interactive protocol on the bad challenge set `B`. -/
theorem fsError_eq [Nonempty C] (a : A) (B : Finset C) :
    fsError a B = (B.card : ℝ) / Fintype.card C := by
  have hC : (0 : ℝ) < Fintype.card C := by exact_mod_cast Fintype.card_pos_iff.mpr ‹Nonempty C›
  have hAC : (0 : ℝ) < Fintype.card (A → C) := by
    have : Nonempty (A → C) := ⟨fun _ => Classical.arbitrary C⟩
    exact_mod_cast Fintype.card_pos_iff.mpr this
  have h : ((hashHits a B).card : ℝ) * Fintype.card C = B.card * Fintype.card (A → C) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℝ) (hashHits_card_mul a B)
  rw [fsError]
  field_simp
  linarith [h]

/-- If at most `d` challenges are answerable, the transformed protocol has soundness error
at most `d/|Chal|` per first message. -/
theorem fsError_le [Nonempty C] (a : A) (B : Finset C) (d : ℕ) (h : B.card ≤ d) :
    fsError a B ≤ (d : ℝ) / Fintype.card C := by
  have hC : (0 : ℝ) < Fintype.card C := by exact_mod_cast Fintype.card_pos_iff.mpr ‹Nonempty C›
  rw [fsError_eq]
  gcongr

/-- **Union bound over the prover's choice of first message**: a cheating prover that is
allowed to grind through all first messages in `A₀` fools the non-interactive verifier for
at most a `|A₀| · d / |Chal|` fraction of oracles. -/
theorem fs_union_bound [Nonempty C] (A₀ : Finset A) (bad : A → Finset C) (d : ℕ)
    (hd : ∀ a, (bad a).card ≤ d) :
    ((univ.filter fun H : A → C => ∃ a ∈ A₀, H a ∈ bad a).card : ℝ) / Fintype.card (A → C)
      ≤ (A₀.card : ℝ) * d / Fintype.card C := by
  classical
  have hAC : (0 : ℝ) < Fintype.card (A → C) := by
    have : Nonempty (A → C) := ⟨fun _ => Classical.arbitrary C⟩
    exact_mod_cast Fintype.card_pos_iff.mpr this
  have hsub : (univ.filter fun H : A → C => ∃ a ∈ A₀, H a ∈ bad a)
      ⊆ A₀.biUnion fun a => hashHits a (bad a) := by
    intro H hH
    simp only [mem_filter, mem_univ, true_and] at hH
    obtain ⟨a, ha, hab⟩ := hH
    exact mem_biUnion.mpr ⟨a, ha, by simpa [hashHits] using hab⟩
  have hcard : ((univ.filter fun H : A → C => ∃ a ∈ A₀, H a ∈ bad a).card : ℝ)
      ≤ ∑ a ∈ A₀, ((hashHits a (bad a)).card : ℝ) := by
    have h1 := Finset.card_le_card hsub
    have h2 := Finset.card_biUnion_le (s := A₀) (t := fun a => hashHits a (bad a))
    have : (univ.filter fun H : A → C => ∃ a ∈ A₀, H a ∈ bad a).card
        ≤ ∑ a ∈ A₀, (hashHits a (bad a)).card := le_trans h1 h2
    exact_mod_cast this
  calc ((univ.filter fun H : A → C => ∃ a ∈ A₀, H a ∈ bad a).card : ℝ) / Fintype.card (A → C)
      ≤ (∑ a ∈ A₀, ((hashHits a (bad a)).card : ℝ)) / Fintype.card (A → C) := by
        gcongr
    _ = ∑ a ∈ A₀, fsError a (bad a) := by
        rw [Finset.sum_div]
        rfl
    _ ≤ ∑ _a ∈ A₀, (d : ℝ) / Fintype.card C :=
        Finset.sum_le_sum fun a _ => fsError_le a (bad a) d (hd a)
    _ = (A₀.card : ℝ) * d / Fintype.card C := by
        rw [Finset.sum_const, nsmul_eq_mul]
        ring

/-! ## Application to `Σ`-protocols -/

/-- A three-move public-coin proof system: on statement `x` the prover sends a first
message `a`, receives a challenge `c` and answers with `r`. -/
structure SigmaProtocol (Stmt Msg Chal Resp : Type*) where
  /-- The verifier's decision predicate. -/
  verify : Stmt → Msg → Chal → Resp → Bool

variable {Stmt Msg Resp : Type*}

/-- The challenges that a (possibly cheating) prover can answer after having committed to
the first message `a`. -/
def SigmaProtocol.answerable [Fintype Resp] (P : SigmaProtocol Stmt Msg C Resp)
    (x : Stmt) (a : Msg) : Finset C :=
  univ.filter fun c => ∃ r, P.verify x a c r

/-- `d`-special soundness relative to a set of false statements: after any first message,
at most `d` of the challenges admit a valid response. (For Schnorr-like protocols
`d = 1`.) -/
def SigmaProtocol.SpecialSound [Fintype Resp] (P : SigmaProtocol Stmt Msg C Resp)
    (bad : Stmt → Prop) (d : ℕ) : Prop :=
  ∀ x, bad x → ∀ a, (P.answerable x a).card ≤ d

omit [DecidableEq C] in
/-- Soundness of the *interactive* protocol: on a false statement the verifier accepts
with probability at most `d/|Chal|` over its own coins. -/
theorem SigmaProtocol.interactive_soundness [Nonempty C] [Fintype Resp]
    (P : SigmaProtocol Stmt Msg C Resp) {bad : Stmt → Prop} {d : ℕ}
    (hP : P.SpecialSound bad d) {x : Stmt} (hx : bad x) (a : Msg) :
    ((P.answerable x a).card : ℝ) / Fintype.card C ≤ (d : ℝ) / Fintype.card C := by
  have hC : (0 : ℝ) < Fintype.card C := by exact_mod_cast Fintype.card_pos_iff.mpr ‹Nonempty C›
  gcongr
  exact_mod_cast hP x hx a

/-- **Soundness of the Fiat–Shamir transform.** For a `d`-special-sound `Σ`-protocol and a
false statement `x`, a cheating prover ranging over the first messages in `A₀` convinces
the non-interactive verifier for at most a `|A₀| · d / |Chal|` fraction of the random
oracles. -/
theorem SigmaProtocol.fiat_shamir_soundness [Nonempty C] [Fintype Msg] [DecidableEq Msg]
    [Fintype Resp] (P : SigmaProtocol Stmt Msg C Resp) {bad : Stmt → Prop} {d : ℕ}
    (hP : P.SpecialSound bad d) {x : Stmt} (hx : bad x) (A₀ : Finset Msg) :
    ((univ.filter fun H : Msg → C => ∃ a ∈ A₀, H a ∈ P.answerable x a).card : ℝ)
        / Fintype.card (Msg → C)
      ≤ (A₀.card : ℝ) * d / Fintype.card C :=
  fs_union_bound A₀ (fun a => P.answerable x a) d fun a => hP x hx a

end ZKFiatShamir