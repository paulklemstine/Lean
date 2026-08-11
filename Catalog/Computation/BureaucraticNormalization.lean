/-
# A Strongly Normalizing Bureaucratic Calculus with Exponential Fibers and Short Conclusions

## Where this sits in the thread

Future Direction 3 of the thread "Thermodynamics of Mathematical Proof" asked for

> a finitely presented, strongly normalizing proof calculus containing conclusions of length
> `O(n)` whose shortest normal proofs have `2^n` distinct bounded-length preimages under
> normalization.

Previous cycles only had the *abstract* collapse maps `ThermoProof.bigCollapse` and the
counting bound `card_le_imageCard_mul_maxFiber`, with no rewrite relation behind them.  This
file replaces the abstract selection model by an explicit rewrite system.

## The calculus

A derivation of the calculus `Bureau n` is a pair `(u, c)` where

* `c : Fin n → Bool` is the **conclusion**, an `n`-bit statement, and
* `u : Fin n → Bool` records, for each of `n` independent inference blocks, whether the
  derivation used the *bureaucratic* (permuted) order or the canonical one.

The calculus has exactly `n` rewrite rules, one per block: rule `i` rewrites a derivation
that uses the bureaucratic order in block `i` into the derivation using the canonical order
in that block, leaving the conclusion untouched.  This is the standard shape of a permutative
(commuting) conversion: the *content* of the proof is unchanged, only its bookkeeping.

## Main results

* `step_weight_lt`, `strongly_normalizing` — **strong normalization**: the number of
  bureaucratic blocks is a strictly decreasing measure, so the rewrite relation is
  well-founded.
* `isNormal_iff_no_step` — the normal forms of the calculus are exactly the derivations in
  canonical order (a genuine characterisation, not a definition).
* `reachIn_normalForm`, `weight_le` — **bounded-length normalization**: every derivation
  reaches its normal form in at most `n` rewrite steps.
* `unique_normal_form` — **uniqueness of normal forms**: the calculus is confluent in the
  strong sense that a derivation has exactly one reachable normal form, `normalForm d`.
* `card_fiber_normalForm` — **exponential fibers**: every normal derivation has exactly
  `2 ^ n` preimages under normalization, all of them reachable in `≤ n` steps, while the
  conclusion and its normal proof are only `n` bits long.
* `expectedLogFiber_normalForm`, `condEntropyW_normalForm` — the thermodynamic consequence,
  via the fiber-entropy law of `Computation/FiberUniformityLaw.lean`: normalization on this
  calculus destroys **exactly `n` bits**, with equality (not merely a bound) because the
  uniform law is fiberwise uniform.
* `erasedBits_normalForm` — the same count through the catalog's `ThermoProof.erasedBits`.
* `landauerCost_normalForm` — the dissipated heat is exactly `n · kB · T · log 2`.
* `bureaucratic_exponential_gap` — the packaged statement: `n`-bit conclusions,
  `2 ^ n`-element normalization fibers, `≤ n`-step normalization, `n` bits erased.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the `2^n` multiplicity of the previous cycle's abstract collapse can be
  realised by an honest rewrite system whose conclusions stay linear in `n`, so that
  "exponentially many bureaucratic derivations of one short theorem" is a theorem rather than
  a modelling assumption.
Experiment (Stage 2): a product calculus of `n` independent commuting blocks does it.  The
  delicate points are (i) that normal forms must be *characterised* rather than postulated —
  proved via `isNormal_iff_no_step` — and (ii) that uniqueness of normal forms must be proved
  from the reflexive-transitive closure, not assumed.
Experiment (Stage 2, numeric): for `n = 3` the calculus has `8` conclusions, `64` derivations,
  `8` normal derivations and fibers of size `8`; normalization erases `log₂ 8 = 3` bits and
  every derivation normalises in at most `3` steps.
Analysis (Stage 3): the fiber size is exponential while the conclusion, the normal proof and
  the normalization *time* are all linear — so proof-term multiplicity is not controlled by
  any of the syntactic size parameters.  This is exactly the regime in which the fiber-entropy
  law has non-trivial content.
Critique (Stage 4): the calculus is finitely presented for each `n` (it has `n` rules), which
  is what the conjecture asks for; it is not a single infinite calculus, and we do not claim
  it is.  Strong normalization is proved as well-foundedness of the rewrite relation, not as
  the weaker statement that some reduction terminates.
Synthesis (Stage 5): exponential normalization multiplicity coexists with linear conclusions,
  linear normal proofs and linear normalization time, and costs exactly `n` Landauer bits.
-/
import Mathlib
import Novelty.ThermodynamicsOfProof
import Computation.ReversibleVerificationFrontier
import Computation.FiberEntropyFrontier
import Computation.WeightedFiberEntropy
import Computation.FiberUniformityLaw

open Finset Real ThermoProof ReversibleFrontier WeightedFiberEntropy FiberUniformity

namespace Bureaucracy

variable {n : ℕ}

/-- A **derivation** of the bureaucratic calculus: a bookkeeping vector recording, for each
of the `n` independent inference blocks, whether the bureaucratic order was used, together
with the `n`-bit conclusion the derivation proves. -/
abbrev Deriv (n : ℕ) : Type := (Fin n → Bool) × (Fin n → Bool)

/-- The **rewrite relation**: rule `i` replaces the bureaucratic order in block `i` by the
canonical one and changes nothing else.  The calculus has exactly `n` rules. -/
def Step (d e : Deriv n) : Prop :=
  ∃ i, d.1 i = true ∧ e = (Function.update d.1 i false, d.2)

/-- A derivation is **normal** when no block uses the bureaucratic order. -/
def IsNormal (d : Deriv n) : Prop := ∀ i, d.1 i = false

/-- The **normalization** map: strip all bureaucracy, keep the conclusion. -/
def normalForm (d : Deriv n) : Deriv n := (fun _ => false, d.2)

/-- The **bureaucracy weight**: the number of blocks still in bureaucratic order. -/
def weight (d : Deriv n) : ℕ := (Finset.univ.filter (fun i => d.1 i = true)).card

/-! ## Strong normalization -/

lemma weight_le (d : Deriv n) : weight d ≤ n := by
  refine le_trans (Finset.card_filter_le _ _) ?_
  simp [Finset.card_univ]

lemma weight_eq_zero_iff (d : Deriv n) : weight d = 0 ↔ IsNormal d := by
  rw [weight, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  constructor
  · intro h i; simpa using h (Finset.mem_univ i)
  · intro h i _; simp [h i]

lemma filter_update (d : Deriv n) (i : Fin n) (hi : d.1 i = true) :
    (Finset.univ.filter (fun j => Function.update d.1 i false j = true))
      = (Finset.univ.filter (fun j => d.1 j = true)).erase i := by
  ext j
  by_cases hj : j = i
  · subst hj; simp
  · simp [Function.update_apply, hj]

lemma weight_update (d : Deriv n) (i : Fin n) (hi : d.1 i = true) :
    weight ((Function.update d.1 i false, d.2) : Deriv n) + 1 = weight d := by
  have hmem : i ∈ Finset.univ.filter (fun j => d.1 j = true) := by simp [hi]
  rw [weight, weight, filter_update d i hi, Finset.card_erase_of_mem hmem]
  exact Nat.succ_pred_eq_of_pos (Finset.card_pos.2 ⟨i, hmem⟩)

/-- **The rewrite relation strictly decreases the bureaucracy weight.** -/
theorem step_weight_lt {d e : Deriv n} (h : Step d e) : weight e < weight d := by
  obtain ⟨i, hi, rfl⟩ := h
  have hw := weight_update d i hi
  omega

/-- **Strong normalization.**  The rewrite relation is well-founded, so no derivation admits
an infinite reduction sequence. -/
theorem strongly_normalizing : WellFounded (fun e d : Deriv n => Step d e) := by
  have hw : WellFounded (InvImage (· < ·) (weight : Deriv n → ℕ)) :=
    InvImage.wf _ (Nat.lt_wfRel.wf)
  exact Subrelation.wf (fun {e d} h => step_weight_lt h) hw

/-! ## Normal forms -/

/-- **Characterisation of normal forms.**  A derivation is irreducible exactly when it uses
the canonical order in every block. -/
theorem isNormal_iff_no_step (d : Deriv n) : IsNormal d ↔ ¬ ∃ e, Step d e := by
  constructor
  · rintro h ⟨e, i, hi, -⟩
    rw [h i] at hi; exact Bool.noConfusion hi
  · intro h i
    by_contra hne
    have hi : d.1 i = true := by
      cases hval : d.1 i with
      | false => exact absurd hval hne
      | true => rfl
    exact h ⟨(Function.update d.1 i false, d.2), i, hi, rfl⟩

lemma normalForm_isNormal (d : Deriv n) : IsNormal (normalForm d) := fun _ => rfl

lemma step_preserves_concl {d e : Deriv n} (h : Step d e) : e.2 = d.2 := by
  obtain ⟨i, hi, rfl⟩ := h; rfl

lemma reflTransGen_preserves_concl {d e : Deriv n}
    (h : Relation.ReflTransGen Step d e) : e.2 = d.2 := by
  induction h with
  | refl => rfl
  | tail _ hstep ih => rw [step_preserves_concl hstep, ih]

/-- **Uniqueness of normal forms.**  Whatever reduction strategy is used, the only normal
derivation reachable from `d` is `normalForm d`; in particular the calculus is confluent. -/
theorem unique_normal_form {d e : Deriv n}
    (h : Relation.ReflTransGen Step d e) (he : IsNormal e) : e = normalForm d := by
  have hc := reflTransGen_preserves_concl h
  refine Prod.ext ?_ hc
  funext i
  exact he i

/-! ## Bounded-length normalization -/

/-- `reachIn k d e` holds when `e` is reachable from `d` in at most `k` rewrite steps. -/
def reachIn : ℕ → Deriv n → Deriv n → Prop
  | 0, d, e => d = e
  | (k + 1), d, e => d = e ∨ ∃ m, Step d m ∧ reachIn k m e

lemma reachIn_reflTransGen : ∀ (k : ℕ) (d e : Deriv n), reachIn k d e →
    Relation.ReflTransGen Step d e := by
  intro k
  induction k with
  | zero => intro d e h; rw [(h : d = e)]
  | succ k ih =>
      intro d e h
      rcases h with h | ⟨m, hs, hr⟩
      · rw [h]
      · exact Relation.ReflTransGen.head hs (ih m e hr)

/-- **Every derivation normalises in at most `weight d` steps.** -/
theorem reachIn_weight (d : Deriv n) : reachIn (weight d) d (normalForm d) := by
  generalize hk : weight d = k
  induction k using Nat.strong_induction_on generalizing d with
  | _ k ih =>
      cases k with
      | zero =>
          have hnorm : IsNormal d := (weight_eq_zero_iff d).1 hk
          show d = normalForm d
          exact Prod.ext (funext fun i => hnorm i) rfl
      | succ k =>
          have hne : ¬ IsNormal d := by
            intro hcon
            rw [(weight_eq_zero_iff d).2 hcon] at hk
            exact Nat.noConfusion hk
          obtain ⟨i, hi⟩ : ∃ i, d.1 i = true := by
            by_contra hcon
            push_neg at hcon
            exact hne fun i => by
              cases hval : d.1 i with
              | false => rfl
              | true => exact absurd hval (hcon i)
          refine Or.inr ⟨(Function.update d.1 i false, d.2), ⟨i, hi, rfl⟩, ?_⟩
          have hw := weight_update d i hi
          have hk' : weight ((Function.update d.1 i false, d.2) : Deriv n) = k := by omega
          have hnf : normalForm ((Function.update d.1 i false, d.2) : Deriv n)
              = normalForm d := rfl
          have := ih k (Nat.lt_succ_self k) _ hk'
          rwa [hnf] at this

/-- Normalization takes at most `n` steps: the reduction length is linear in the size of the
conclusion. -/
theorem reachIn_normalForm (d : Deriv n) : ∃ k ≤ n, reachIn k d (normalForm d) :=
  ⟨weight d, weight_le d, reachIn_weight d⟩

/-! ## Exponential fibers -/

lemma fiber_normalForm (d : Deriv n) :
    fiber (normalForm : Deriv n → Deriv n) (normalForm d)
      = (Finset.univ : Finset (Fin n → Bool)) ×ˢ ({d.2} : Finset (Fin n → Bool)) := by
  ext e
  simp only [mem_fiber, Finset.mem_product, Finset.mem_univ, Finset.mem_singleton, true_and]
  constructor
  · intro h
    have := congrArg Prod.snd h
    simpa [normalForm] using this
  · intro h
    simp [normalForm, h]

/-- **Exponentially many bureaucratic derivations of one short theorem.**  Every normal
derivation of the calculus has exactly `2 ^ n` preimages under normalization, although its
conclusion has only `n` bits. -/
theorem card_fiber_normalForm (d : Deriv n) :
    (fiber (normalForm : Deriv n → Deriv n) (normalForm d)).card = 2 ^ n := by
  rw [fiber_normalForm, Finset.card_product, Finset.card_singleton, mul_one, Finset.card_univ]
  simp

/-- Every one of the `2 ^ n` preimages normalises in at most `n` steps. -/
theorem fiber_members_bounded (d e : Deriv n)
    (he : e ∈ fiber (normalForm : Deriv n → Deriv n) (normalForm d)) :
    ∃ k ≤ n, reachIn k e (normalForm d) := by
  have h : normalForm e = normalForm d := mem_fiber.1 he
  obtain ⟨k, hk, hr⟩ := reachIn_normalForm e
  exact ⟨k, hk, by rwa [h] at hr⟩

/-! ## The thermodynamic reading -/

lemma card_deriv (n : ℕ) : Fintype.card (Deriv n) = 2 ^ n * 2 ^ n := by
  simp [Fintype.card_prod]

instance : Nonempty (Deriv n) := ⟨(fun _ => false, fun _ => false)⟩

lemma logb_two_pow (n : ℕ) : Real.logb 2 ((2 : ℝ) ^ n) = n := by
  rw [Real.logb, Real.log_pow, mul_div_assoc,
    div_self (ne_of_gt (Real.log_pos (by norm_num))), mul_one]

/-- **The fiber-counting estimate on the bureaucratic calculus is exactly `n` bits.** -/
theorem expectedLogFiber_normalForm (n : ℕ) :
    expectedLogFiber (normalForm : Deriv n → Deriv n) (unif (Deriv n)) = (n : ℝ) := by
  have hN : (0 : ℝ) < (Fintype.card (Deriv n) : ℝ) := by
    have : 0 < Fintype.card (Deriv n) := Fintype.card_pos
    exact_mod_cast this
  have hterm : ∀ d : Deriv n,
      unif (Deriv n) d * Real.logb 2 ((fiber (normalForm : Deriv n → Deriv n)
        (normalForm d)).card) = (1 / (Fintype.card (Deriv n) : ℝ)) * (n : ℝ) := by
    intro d
    simp only [unif]
    rw [card_fiber_normalForm d,
      show (((2 : ℕ) ^ n : ℕ) : ℝ) = (2 : ℝ) ^ n by push_cast; ring, logb_two_pow]
  rw [expectedLogFiber, Finset.sum_congr rfl (fun d _ => hterm d), Finset.sum_const,
    nsmul_eq_mul, Finset.card_univ]
  field_simp

/-- **Normalization on this calculus destroys exactly `n` bits** — an equality, not a bound,
because the uniform law is fiberwise uniform (`FiberUniformity.fiber_entropy_law`). -/
theorem condEntropyW_normalForm (n : ℕ) :
    condEntropyW (normalForm : Deriv n → Deriv n) (unif (Deriv n)) = (n : ℝ) := by
  rw [condEntropyW_unif_eq_expectedLogFiber, expectedLogFiber_normalForm]

/-- The same count through the catalog's entropy-drop functional. -/
theorem erasedBits_normalForm (n : ℕ) :
    erasedBits (normalForm : Deriv n → Deriv n) = (n : ℝ) := by
  have himg : imageCard (normalForm : Deriv n → Deriv n) = 2 ^ n := by
    -- the image is the set of normal derivations, in bijection with the conclusions
    have himage : (Finset.univ.image (normalForm : Deriv n → Deriv n))
        = ({fun _ => false} : Finset (Fin n → Bool))
            ×ˢ (Finset.univ : Finset (Fin n → Bool)) := by
      ext e
      simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_product,
        Finset.mem_singleton]
      constructor
      · rintro ⟨d, rfl⟩; exact ⟨rfl, trivial⟩
      · rintro ⟨h1, -⟩
        exact ⟨(fun _ => false, e.2), by rw [normalForm]; exact Prod.ext h1.symm rfl⟩
    rw [imageCard, himage, Finset.card_product, Finset.card_singleton, one_mul,
      Finset.card_univ]
    simp
  rw [erasedBits, himg, card_deriv]
  have h1 : (((2 : ℕ) ^ n * (2 : ℕ) ^ n : ℕ) : ℝ) = (2 : ℝ) ^ n * (2 : ℝ) ^ n := by
    push_cast; ring
  have h2 : (((2 : ℕ) ^ n : ℕ) : ℝ) = (2 : ℝ) ^ n := by push_cast; ring
  rw [h1, h2, Real.logb_mul (by positivity) (by positivity), logb_two_pow]
  ring

/-- The Landauer heat of normalizing this calculus is exactly `n · kB · T · log 2`. -/
theorem landauerCost_normalForm (n : ℕ) (kB T : ℝ) :
    landauerCost (erasedBits (normalForm : Deriv n → Deriv n)) kB T
      = (n : ℝ) * (kB * T * Real.log 2) := by
  rw [erasedBits_normalForm, landauerCost]

/-- **The packaged statement of Future Direction 3.**  For every `n` the bureaucratic
calculus is strongly normalizing, has `n`-bit conclusions, normalises in at most `n` steps,
has normalization fibers of size exactly `2 ^ n`, and destroys exactly `n` bits. -/
theorem bureaucratic_exponential_gap (n : ℕ) :
    WellFounded (fun e d : Deriv n => Step d e) ∧
    (∀ d : Deriv n, (fiber (normalForm : Deriv n → Deriv n) (normalForm d)).card = 2 ^ n) ∧
    (∀ d : Deriv n, ∃ k ≤ n, reachIn k d (normalForm d)) ∧
    condEntropyW (normalForm : Deriv n → Deriv n) (unif (Deriv n)) = (n : ℝ) :=
  ⟨strongly_normalizing, card_fiber_normalForm, reachIn_normalForm,
    condEntropyW_normalForm n⟩

end Bureaucracy