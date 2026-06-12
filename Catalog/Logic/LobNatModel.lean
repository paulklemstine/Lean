import Logic.LobFixedPoint

/-!
# A Concrete Consistent Gödel–Löb Algebra: the Well-Founded Frame `(ℕ, >)`

This file builds an explicit, consistent model `NatGL` of the abstract
`GLOperator` typeclass from `Catalog/Logic/LobFixedPoint.lean`, witnessing that the
Gödel–Löb axioms are not vacuous, and then *computes everything explicitly* in it.

The carrier is the Boolean (hence Heyting) algebra `Set ℕ`.  The provability
operator is the **box of the converse well-founded frame `(ℕ, >)`**:
`natBox S = { n | ∀ m < n, m ∈ S }` — "`n` is provable iff every strictly smaller
world satisfies `S`".  This is the algebraic shadow of the Kripke box
`GLFrame.boxSet` of `Catalog/Logic/GLKripke.lean` for the canonical frame whose
accessibility relation is `>` on `ℕ`.

## Main results

* `natBox_loeb` / the `GLOperator (Set ℕ)` instance — Löb's axiom holds, proved by
  strong induction; so all of `loeb_rule`, `loeb_fixed_point`, `box_transitive`,
  `godel_second` transfer to this concrete model for free.
* `natGL_consistent` — the model is **consistent**: `natBox ⊥ ≠ ⊤`.
* `natBox_iterate_eq_Iio` — **the provability-rank computation**:
  `natBox^[k] ∅ = Set.Iio k`.  The `k`-fold inconsistency statement is *exactly* the
  initial segment of length `k`; its "rank" is literally `k`.
* `consistency_strength_strictMono` — the consistency strengths
  `k ↦ natBox^[k] ⊥` form a **strictly increasing** chain, never reaching `⊤`.
* `godel_hierarchy` — **graded Gödel II**: for every `k`, the `k`-fold consistency
  statement `natBox^[k] ⊥ ⇨ ⊥` is *unprovable* in `NatGL`.  A strictly increasing
  spectrum of unprovable consistency strengths, refining the single Gödel II.

## Catalog synthesis

This realises, in the algebraic language of `GLOperator`, the concrete frame model
that `Catalog/Logic/GLKripke.lean` constructs semantically: `natBox` is
`GLFrame.boxSet` for the frame `(ℕ, >)`, and `natBox_loeb` is the algebraic image of
`gl_frame_validates_loeb`.  It also makes the "time-stamped" intuition of
`Catalog/Logic/TemporalGL.lean` precise — here the stage index `k` is *exactly* the
frame depth, and `natBox^[k] ⊥ = Iio k` turns the qualitative `godel_second_at_time`
into a quantitative hierarchy.

-- !-- Lab Notebook -- !--
**Hypothesis.** `(ℕ, >)` is a converse-well-founded GL frame, so its box gives a
*consistent* model of `GLOperator`, in which the iterated falsity `□^k⊥` is the
initial segment `Iio k`, yielding a strictly increasing, never-trivial hierarchy of
unprovable consistencies.

**Result.** Confirmed. `natBox_loeb` is strong induction on the world. The keystone
computation `natBox^[k] ∅ = Iio k` is a one-line induction: `natBox (Iio k) =
Iio (k+1)` because `(∀ m<n, m<k) ↔ n ≤ k`. Consistency, strict monotonicity, and the
graded Gödel II then fall out by `simp`/order reasoning plus `consistency_unprovable`.

**Insight.** Provability *rank* is not an extra structure to be defined — in the
canonical model it is the identity function on `ℕ`: `□^k⊥` literally *is* the set of
worlds of depth `< k`. Gödel II is the `k=1` slice (`□⊥ = {0} ≠ univ`), and the full
unprovability spectrum is the statement that `Iio` is strictly monotone.

**Failure analysis.** Encoding the frame as `(ℕ, <)` (the naive "future is larger")
fails: `<` is *not* converse well-founded (`0<1<2<⋯`), so Löb's axiom is false there.
The converse order `>` ("smaller worlds are the accessible counterexamples") is the
correct, well-founded choice — the same reason GL frames must be converse-well-founded.
-- !-- end Lab Notebook -- !--
-/

open GLOperator

/-- The **provability box of the well-founded frame `(ℕ, >)`**: a world `n` "proves"
`S` iff every strictly smaller world lies in `S`.  Equivalently `natBox S` is the set
of `n` all of whose `>`-successors satisfy `S`. -/
def natBox (S : Set ℕ) : Set ℕ := { n | ∀ m, m < n → m ∈ S }

@[simp] theorem mem_natBox {S : Set ℕ} {n : ℕ} :
    n ∈ natBox S ↔ ∀ m, m < n → m ∈ S := Iff.rfl

-- !-- `⊤ = univ`: every smaller world is trivially in `univ`. -- !--
theorem natBox_top : natBox (⊤ : Set ℕ) = ⊤ := by
  ext n; simp [natBox]

-- !-- `natBox` distributes over `∩`: "all smaller in A and B" = "all smaller in A"
--     and "all smaller in B". -- !--
theorem natBox_inf (A B : Set ℕ) : natBox (A ∩ B) = natBox A ∩ natBox B := by
  ext n
  simp only [mem_natBox, Set.mem_inter_iff]
  constructor
  · intro h; exact ⟨fun m hm => (h m hm).1, fun m hm => (h m hm).2⟩
  · rintro ⟨hA, hB⟩ m hm; exact ⟨hA m hm, hB m hm⟩

-- !-- Löb's axiom by strong induction. To show every `k < n` is in `S`, induct on `k`:
--     the IH gives `k ∈ natBox S`, so `k ∉ (natBox S)ᶜ`; the hypothesis then forces
--     `k ∈ S`. Mirrors `gl_frame_validates_loeb` for the frame `(ℕ, >)`. -- !--
/-- **Löb's axiom for `natBox`.**  `natBox (natBox S ⇨ S) ≤ natBox S`. -/
theorem natBox_loeb (S : Set ℕ) : natBox ((natBox S) ⇨ S) ≤ natBox S := by
  intro n hn k hk
  induction' k using Nat.strong_induction_on with k ih
  exact hn k hk ( fun m hm => ih m hm ( lt_trans hm hk ) )

/-- The **canonical Gödel–Löb algebra `NatGL`** on `Set ℕ`, with box the frame `(ℕ, >)`
provability operator.  This instance makes every theorem of `GLOperator` — Löb's rule,
the Sambin fixed point, axiom 4, Gödel II — available for `Set ℕ`. -/
instance NatGL : GLOperator (Set ℕ) where
  box := natBox
  box_top := natBox_top
  box_inf := natBox_inf
  loeb := natBox_loeb

@[simp] theorem natGL_box (S : Set ℕ) : (□S) = natBox S := rfl

-- !-- `□⊥ = natBox ∅ = {0}`; it is not `univ` since `1 ∉ natBox ∅` (`0 < 1`, `0 ∉ ∅`). -- !--
/-- **`NatGL` is consistent.**  Falsity is not "provable everywhere":
`□⊥ ≠ ⊤`.  Indeed `□⊥ = {0}`, the single world of depth `0`. -/
theorem natGL_consistent : (□(⊥ : Set ℕ)) ≠ ⊤ :=
  fun h => by simpa using Set.ext_iff.mp h 1

/-- **`NatGL` cannot prove its own consistency** — Gödel II, concretely.  This is the
abstract `GLOperator.consistency_unprovable` applied at the consistent model `NatGL`. -/
theorem natGL_godel_second : (□((□(⊥ : Set ℕ)) ⇨ ⊥)) ≠ ⊤ :=
  consistency_unprovable natGL_consistent

-- !-- Induction on `k`. Step: `natBox (Iio k) = Iio (k+1)` since `(∀ m<n, m<k) ↔ n ≤ k`. -- !--
/-- **The provability-rank computation.**  In `NatGL` the `k`-fold falsity is exactly
the initial segment of length `k`: `□^k⊥ = {0,1,…,k-1}`.  The frame depth and the
iteration index coincide. -/
theorem natBox_iterate_eq_Iio (k : ℕ) : natBox^[k] (∅ : Set ℕ) = Set.Iio k := by
  induction' k with k ih;
  · aesop;
  · simp_all +decide [ Function.iterate_succ_apply' ];
    ext n; simp [natBox];
    exact ⟨ fun h => le_of_not_gt fun h' => by linarith [ h _ h' ], fun h m hm => lt_of_lt_of_le hm h ⟩

-- !-- `□^k⊥ = Iio k` and `Iio` is strictly monotone in `k`, never equal to `univ`. -- !--
/-- **A strictly increasing hierarchy of consistency strengths.**  The map
`k ↦ □^k⊥` is strictly monotone: each consistency statement is genuinely stronger than
the last, and none is trivial. -/
theorem consistency_strength_strictMono :
    StrictMono (fun k => natBox^[k] (∅ : Set ℕ)) := by
  intro m n hmn; simp only [];
  convert Set.ssubset_of_ssubset_of_subset ( Set.Iio_ssubset_Iio hmn ) ?_;
  · convert natBox_iterate_eq_Iio m using 1;
  · rw [ natBox_iterate_eq_Iio ]

-- !-- `□^{k+1}⊥ = Iio (k+1)` is nonempty (`0 ∈`), so its complement misses `0`; hence
--     the box at world `1` fails, witnessing `□(□^{k+1}⊥ ⇨ ⊥) ≠ univ`. -- !--
/-- **Graded Gödel II / the unprovability spectrum.**  For *every* `k`, the `k`-fold
consistency statement `□^k⊥ ⇨ ⊥` is unprovable in `NatGL`.  This refines the single
Gödel II (`natGL_godel_second`, the `k = 1` case) into a strictly increasing family of
unprovable consistency strengths indexed by the natural numbers.  (The level `0`
is genuinely excluded: `□^0⊥ = ⊥`, whose consistency `⊥ ⇨ ⊥ = ⊤` *is* provable —
only the *nontrivial* consistency strengths `□^{k+1}⊥` are unprovable.) -/
theorem godel_hierarchy (k : ℕ) :
    (□((natBox^[(k + 1)] (∅ : Set ℕ)) ⇨ ⊥)) ≠ ⊤ := by
  simp +decide [ Set.ext_iff ];
  -- Choose $x = k + 1$ and $x_1 = k$.
  use k + 1, k;
  -- By definition of `natBox`, we know that `k ∈ natBox^[k] (natBox ∅)`.
  have h_k_in_box : k ∈ natBox^[k] (natBox ∅) := by
    have h_k_in_box : natBox^[k] (natBox ∅) = Set.Iio (k + 1) := by
      convert natBox_iterate_eq_Iio ( k + 1 ) using 1;
    exact h_k_in_box.symm ▸ Nat.lt_succ_self k;
  exact ⟨ Nat.lt_succ_self _, fun h => by simpa using h h_k_in_box ⟩