import Combinatorics.BoxDepthReflection

/-!
# The reflection depth is an independent parameter

`Novelty.ArithmetizedQFTReflection` and `Combinatorics.BoxDepthReflection` established
the *depth-graded reflection hierarchy* for the finite-height theories `capSysN n`:
with `DepthReflection d i S` the rule "`⊢ □_i a` implies `⊢ a` for all `a` of box depth
`< d`", the catalog proves

  `capSysN_depthReflection_iff` :  `DepthReflection d i (capSysN n) ↔ d ≤ n`,

so for that family the **reflection depth equals the height**, i.e. equals the least
`k` with `⊢ □_i^{k+1} ⊥`.  Two natural questions are left open by this coincidence:

1. is the reflection depth *determined* by the provable iterated boxed falsa (the
   "inconsistency spectrum") of a consistent GL theory?
2. how far above minimal soundness (`⊬ □_i ⊥`) does the chain of depth-restricted
   reflection rules really start?  The catalog separates minimal soundness from the
   depth-`2` rule (`minSoundness_not_implies_depthReflection_two`); is the depth-`1`
   rule already strictly stronger?

This file answers both, by decoupling the two parameters.  The catalog satisfaction
`sat` makes every atom true at every world, which is exactly why height and reflection
depth are forced to coincide there.  Replacing the atom clause by an arbitrary
valuation (`satV`, `valSys`) keeps all of GL — necessitation, distribution, the `4`
axiom, Löb — and produces, for every height `n` and every `w ≤ n`, a consistent GL
theory

  `spectrumSys n w = valSys (blockVal w) n`,   `blockVal w m p = decide (m < w)`

whose **reflection depth is exactly `n - w`**
(`spectrumSys_depthReflection_iff`) while its **inconsistency spectrum is exactly that
of `capSysN n`**, independently of `w`
(`provable_spectrumSys_boxPow_bot`).  Consequences:

* `reflection_depth_spectrum` and `height_depth_realizable_iff` : a consistent GL
  theory of inconsistency height `n` and reflection depth exactly `d` exists **iff**
  `d ≤ n`; the inequality (proved for arbitrary proof systems in
  `depthReflection_fails_of_inconsistency_height`) is the only constraint tying the two
  invariants together, and the catalog family `capSysN n` occupies only its diagonal;
* `reflection_depth_not_determined_by_inconsistency_spectrum` : answer to question 1 is
  **no** — two theories with literally the same provable iterated boxed falsa can have
  reflection depths `0` and `n`;
* `minSoundness_not_implies_depthReflection_one` : answer to question 2 — already the
  depth-`1` rule is strictly stronger than minimal soundness, which is optimal since
  the depth-`0` rule is vacuous.  This sharpens the catalog separation by one level,
  and it *cannot* be obtained inside the atom-trivial semantics, where a box-free
  formula has a world-independent truth value.

§5 adds the classification of the new family itself: `spectrumSys_inclusion_iff`
computes exactly when one block theory contains another, and `spectrumSys_eq_iff`,
`spectrumSys_shift_injective` show that the family is **rigid** — the height and the
shift point can be read back off the theory, so the `n + 1` theories of height `n` are
pairwise distinct and are classified by their reflection depth.  This is the exact
opposite of the behaviour of the tag-sensitive family `capC c N`, whose massive
redundancy is classified in `Algebra.DepthDominationCriterion`.

The technical engine is a locality lemma for the block valuation
(`satV_blockVal_local`): above the block of `w` "true" worlds, a formula of box depth
`≤ k` cannot tell two worlds apart once both lie at height `≥ w + k`.  The witnesses of
failure are the *depth probes* `probe i k = □_i^k (atom 0)`, whose truth value at a
world `m` is `m < w + k` (`satV_probe`) — a shifted copy of the iterated boxed falsum,
which is the `w = 0` case.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the identity "reflection depth = height" in `capSysN n` is an
  artefact of the atom-trivial semantics, not a theorem of GL; with a genuine valuation
  the two invariants should separate completely, giving the full square `d ≤ n`.
Experiment (Stage 2): the truth tables of the probes `□^k (atom 0)` in the block model
  with `n ≤ 4`, `w ≤ n` were computed: `probe k` holds at the worlds `m < w + k`, hence
  is provable exactly when `n < w + k`, and the unique failure of reflection occurs at
  `k = n - w`.  All `15` pairs `(n, w)` with `n ≤ 4` matched the predicted reflection
  depth `n - w`, and the boxed falsa `□^k ⊥` were provable exactly for `k > n` in all
  of them.
Analysis (Stage 3): the depth probe is a "shifted falsum": `⊥` is the atom that is
  false everywhere (`w = 0`), and `blockVal w` moves the point where truth stops from
  world `0` up to world `w`.  Reflection depth measures the *distance from the top of
  the model to the shift point*, whereas the inconsistency spectrum measures the
  distance from the top to the root; the two agree only when the shift point is the
  root.
Critique (Stage 4): the separating theories are genuine GL theories (all six closure
  conditions are verified in `isGL_valSys`, Löb via the converse well-foundedness of
  `(ℕ, <)`), consistent, and the reflection statements are proved as exact
  biconditionals rather than as one-sided failures.
-/

namespace ReflectionSpectrum

open PhysicsConsistency
open ProofSystemCollapse
open Form

/-! ## §1. Kripke semantics with a valuation -/

/-- Kripke satisfaction over the frame `(ℕ, <)` with an arbitrary valuation `V` of the
atoms.  Taking `V = fun _ _ => true` recovers the catalog's `sat`. -/
def satV (V : ℕ → ℕ → Bool) : ℕ → Form → Bool
  | _, bot => false
  | m, atom p => V m p
  | m, imp a b => (!(satV V m a)) || satV V m b
  | m, box _ a => (List.range m).all (fun n => satV V n a)

theorem satV_imp (V : ℕ → ℕ → Bool) (m : ℕ) (a b : Form) :
    satV V m (imp a b) = true ↔ (satV V m a = true → satV V m b = true) := by
  simp only [satV]; cases satV V m a <;> cases satV V m b <;> simp

theorem satV_box (V : ℕ → ℕ → Bool) (m i : ℕ) (a : Form) :
    satV V m (box i a) = true ↔ ∀ n, n < m → satV V n a = true := by
  simp [satV, List.all_eq_true, List.mem_range]

/-- Converse well-foundedness of `(ℕ, <)` in the valuated semantics: the engine behind
the Löb axiom. -/
theorem satV_loeb_engine (V : ℕ → ℕ → Bool) (i : ℕ) (a : Form) (m : ℕ)
    (h : ∀ n, n < m → satV V n (imp (box i a) a) = true) :
    ∀ n, n < m → satV V n a = true := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro hn
    have hstep := h n hn
    rw [satV_imp] at hstep
    refine hstep ?_
    rw [satV_box]
    intro k hk
    exact ih k hk (hk.trans hn)

/-- The theory of the valuated model truncated at the worlds `0, …, N`. -/
def valSys (V : ℕ → ℕ → Bool) (N : ℕ) : ProofSys Form where
  Proof := { a : Form // ∀ m ≤ N, satV V m a = true }
  concl := Subtype.val
  size := fun _ => 0

theorem provable_valSys (V : ℕ → ℕ → Bool) (N : ℕ) (a : Form) :
    Provable (valSys V N) a ↔ ∀ m ≤ N, satV V m a = true := by
  constructor
  · rintro ⟨⟨b, hb⟩, rfl⟩; exact hb
  · intro h; exact ⟨⟨a, h⟩, rfl⟩

/-- **Valuated finite-height theories are GL theories**, for every tag. -/
theorem isGL_valSys (V : ℕ → ℕ → Bool) (N i : ℕ) : IsGLTheory i (valSys V N) := by
  constructor
  · intro a b hab ha
    rw [provable_valSys] at *
    intro m hm
    exact (satV_imp V m a b).1 (hab m hm) (ha m hm)
  · intro a ha
    rw [provable_valSys] at *
    intro m _
    rw [satV_box]
    intro n hn
    exact ha n (by omega)
  · intro a ha
    rw [provable_valSys]
    intro m _
    exact ha (satV V m) rfl (fun _ _ => rfl)
  · intro a b
    rw [provable_valSys]
    intro m _
    rw [satV_imp]; intro hab
    rw [satV_imp]; intro ha
    rw [satV_box] at hab ha ⊢
    intro n hn
    exact (satV_imp V n a b).1 (hab n hn) (ha n hn)
  · intro a
    rw [provable_valSys]
    intro m _
    rw [satV_imp]; intro h
    rw [satV_box] at h ⊢
    intro n hn
    rw [satV_box]
    intro k hk
    exact h k (hk.trans hn)
  · intro a
    rw [provable_valSys]
    intro m _
    rw [satV_imp]; intro h
    rw [satV_box] at h ⊢
    exact satV_loeb_engine V i a m (fun n hn => h n hn)

/-- Valuated finite-height theories are consistent: `⊥` fails at the root. -/
theorem consistent_valSys (V : ℕ → ℕ → Bool) (N : ℕ) : Consistent (valSys V N) := by
  intro h
  rw [provable_valSys] at h
  have := h 0 (Nat.zero_le N)
  simp [satV] at this

/-- The iterated boxed falsum is true exactly at the worlds of height `< k`, whatever
the valuation: `⊥` contains no atoms. -/
theorem satV_boxPow_bot (V : ℕ → ℕ → Bool) (i : ℕ) :
    ∀ (k m : ℕ), satV V m (boxPow i k bot) = true ↔ m < k := by
  intro k
  induction k with
  | zero => intro m; simp [boxPow, satV]
  | succ k ih =>
      intro m
      rw [boxPow, satV_box]
      constructor
      · intro h
        by_contra hlt
        push_neg at hlt
        exact absurd ((ih k).1 (h k (by omega))) (by omega)
      · intro h j hj
        exact (ih j).2 (by omega)

/-- **The inconsistency spectrum of a valuated finite-height theory does not depend on
the valuation**: `□_i^k ⊥` is provable exactly when `k` exceeds the height. -/
theorem provable_valSys_boxPow_bot (V : ℕ → ℕ → Bool) (N i k : ℕ) :
    Provable (valSys V N) (boxPow i k bot) ↔ N < k := by
  rw [provable_valSys]
  constructor
  · intro h
    exact (satV_boxPow_bot V i k N).1 (h N le_rfl)
  · intro h m hm
    exact (satV_boxPow_bot V i k m).2 (by omega)

/-! ## §2. The block valuation and its locality -/

/-- The **block valuation** with shift point `w`: every atom is true at the worlds
`0, …, w - 1` and false from the world `w` upwards.  `blockVal 0` makes every atom
false everywhere, so the atoms then behave like `⊥`. -/
def blockVal (w : ℕ) : ℕ → ℕ → Bool := fun m _ => decide (m < w)

/-- **Locality above the block.**  A formula of box depth `≤ k` cannot distinguish two
worlds that both lie at height `≥ w + k`: it can look down at most `k` steps, and after
`k` steps both worlds are still inside the constant region of the valuation. -/
theorem satV_blockVal_local (w : ℕ) :
    ∀ (a : Form) (k m m' : ℕ), boxDepth a ≤ k → w + k ≤ m → w + k ≤ m' →
      satV (blockVal w) m a = satV (blockVal w) m' a := by
  intro a
  induction a with
  | bot => intro _ _ _ _ _ _; rfl
  | atom p =>
      intro k m m' _ hm hm'
      simp only [satV, blockVal, decide_eq_decide]
      omega
  | imp p q ihp ihq =>
      intro k m m' hk hm hm'
      simp only [boxDepth, max_le_iff] at hk
      simp only [satV, ihp k m m' hk.1 hm hm', ihq k m m' hk.2 hm hm']
  | box i b ih =>
      intro k m m' hk hm hm'
      simp only [boxDepth_box] at hk
      have key : ∀ p q : ℕ, w + k ≤ p → w + k ≤ q →
          (∀ j, j < p → satV (blockVal w) j b = true) →
          ∀ j, j < q → satV (blockVal w) j b = true := by
        intro p q hp _ h j hj
        by_cases hd : w + (k - 1) ≤ j
        · rw [ih (k - 1) j (p - 1) (by omega) hd (by omega)]
          exact h (p - 1) (by omega)
        · exact h j (by omega)
      rw [Bool.eq_iff_iff, satV_box, satV_box]
      exact ⟨key m m' hm hm', key m' m hm' hm⟩

/-- The **depth probe** `□_i^k (atom 0)`: the shifted analogue of the iterated boxed
falsum.  Its box depth is exactly `k`. -/
def probe (i k : ℕ) : Form := boxPow i k (atom 0)

@[simp] theorem boxDepth_probe (i k : ℕ) : boxDepth (probe i k) = k := by
  induction k with
  | zero => rfl
  | succ k ih => rw [probe, boxPow, boxDepth_box]; rw [probe] at ih; rw [ih]

/-- **The truth table of the depth probes.**  In the block model with shift point `w`
the probe `□_i^k (atom 0)` holds exactly at the worlds of height `< w + k`; for `w = 0`
this is the catalog's `sat_boxPow_bot`. -/
theorem satV_probe (w i : ℕ) :
    ∀ (k m : ℕ), satV (blockVal w) m (probe i k) = true ↔ m < w + k := by
  intro k
  induction k with
  | zero => intro m; simp [probe, boxPow, satV, blockVal]
  | succ k ih =>
      intro m
      rw [probe, boxPow, satV_box]
      constructor
      · intro h
        by_contra hlt
        push_neg at hlt
        have := (ih (w + k)).1 (h (w + k) (by omega))
        omega
      · intro h j hj
        exact (ih j).2 (by omega)

/-! ## §3. The reflection-depth spectrum -/

/-- The **block theory** of height `n` with shift point `w`: the formulas true at all
worlds `0, …, n` of the block model. -/
def spectrumSys (n w : ℕ) : ProofSys Form := valSys (blockVal w) n

theorem consistent_spectrumSys (n w : ℕ) : Consistent (spectrumSys n w) :=
  consistent_valSys _ _

theorem isGL_spectrumSys (n w i : ℕ) : IsGLTheory i (spectrumSys n w) :=
  isGL_valSys _ _ i

/-- **The inconsistency spectrum of the block theories is that of `capSysN n`**, for
every shift point `w`. -/
theorem provable_spectrumSys_boxPow_bot (n w i k : ℕ) :
    Provable (spectrumSys n w) (boxPow i k bot) ↔ n < k :=
  provable_valSys_boxPow_bot _ _ _ _

/-- The probes are provable exactly above the top of the block. -/
theorem provable_spectrumSys_probe (n w i k : ℕ) :
    Provable (spectrumSys n w) (probe i k) ↔ n < w + k := by
  rw [spectrumSys, provable_valSys]
  constructor
  · intro h; exact (satV_probe w i k n).1 (h n le_rfl)
  · intro h m hm; exact (satV_probe w i k m).2 (by omega)

/-- **Reflection holds below the gap.**  In the block theory of height `n` with shift
point `w` the depth-restricted reflection rule is valid for every formula of box depth
`< n - w`: such a formula cannot tell the top world `n` apart from the world `n - 1`,
because both are at height `≥ w + boxDepth a`. -/
theorem spectrumSys_depthReflection (n w i : ℕ) :
    DepthReflection (n - w) i (spectrumSys n w) := by
  intro a hdep hbox
  rw [spectrumSys, provable_valSys] at hbox ⊢
  have hlow : ∀ j, j < n → satV (blockVal w) j a = true := by
    intro j hj
    exact (satV_box (blockVal w) n i a).1 (hbox n le_rfl) j hj
  intro m hm
  rcases Nat.lt_or_ge m n with h | h
  · exact hlow m h
  · have hmn : m = n := by omega
    subst hmn
    rw [satV_blockVal_local w a (boxDepth a) m (m - 1) le_rfl (by omega) (by omega)]
    exact hlow (m - 1) (by omega)

/-- **Reflection fails one step higher**, witnessed by the depth probe of depth exactly
`n - w`: the theory proves it to be provable (`□_i^{n-w+1}(atom 0)` is valid at every
world `≤ n`) and refutes it (it fails at the world `n`). -/
theorem spectrumSys_depthReflection_fails {n w : ℕ} (hw : w ≤ n) (i : ℕ) :
    ¬ DepthReflection (n - w + 1) i (spectrumSys n w) := by
  intro h
  have hbox : Provable (spectrumSys n w) (box i (probe i (n - w))) := by
    have : box i (probe i (n - w)) = probe i (n - w + 1) := rfl
    rw [this, provable_spectrumSys_probe]
    omega
  have hprov := h (probe i (n - w)) (by simp) hbox
  rw [provable_spectrumSys_probe] at hprov
  omega

/-- **The reflection depth of the block theory is exactly `n - w`.** -/
theorem spectrumSys_depthReflection_iff {n w : ℕ} (hw : w ≤ n) (d i : ℕ) :
    DepthReflection d i (spectrumSys n w) ↔ d ≤ n - w := by
  constructor
  · intro h
    by_contra hd
    exact spectrumSys_depthReflection_fails hw i
      (depthReflection_mono (by omega) h)
  · intro hd
    exact depthReflection_mono hd (spectrumSys_depthReflection n w i)

/-- **The full spectrum is realized.**  For every height `n` and every `d ≤ n` there is
a consistent GL theory whose provable iterated boxed falsa are exactly those of
`capSysN n` — so it has height `n` in the sense of the catalog's inconsistency
invariant — and whose reflection depth is exactly `d`. -/
theorem reflection_depth_spectrum {n d : ℕ} (hd : d ≤ n) (i : ℕ) :
    Consistent (spectrumSys n (n - d)) ∧ IsGLTheory i (spectrumSys n (n - d)) ∧
      (∀ k, Provable (spectrumSys n (n - d)) (boxPow i k bot) ↔ n < k) ∧
      (∀ d', DepthReflection d' i (spectrumSys n (n - d)) ↔ d' ≤ d) := by
  refine ⟨consistent_spectrumSys _ _, isGL_spectrumSys _ _ i,
    fun k => provable_spectrumSys_boxPow_bot n (n - d) i k, fun d' => ?_⟩
  have hw : n - d ≤ n := by omega
  rw [spectrumSys_depthReflection_iff hw d' i]
  omega

/-- **The reflection depth never exceeds the inconsistency height.**  This holds for an
*arbitrary* proof system, with no semantics involved: the iterated boxed falsum
`□_i^n ⊥` has box depth `n`, and `□_i (□_i^n ⊥)` is literally `□_i^{n+1} ⊥`, so a
theory that proves the latter and refutes the former violates the depth-`(n+1)` rule. -/
theorem depthReflection_fails_of_inconsistency_height {i n : ℕ} {S : ProofSys Form}
    (hprov : Provable S (boxPow i (n + 1) bot)) (hnot : ¬ Provable S (boxPow i n bot)) :
    ¬ DepthReflection (n + 1) i S := by
  intro h
  exact hnot (h (boxPow i n bot) (by simp) hprov)

/-- **Exact realizability of the pair (height, reflection depth).**  A consistent GL
theory of inconsistency height `n` — one proving `□_i^k ⊥` exactly for `k > n` — with
reflection depth exactly `d` exists **iff** `d ≤ n`.  Necessity is the general bound
above; sufficiency is the block theory `spectrumSys n (n - d)`.  So the single
inequality `d ≤ n` is the *only* constraint linking the two invariants, whereas in the
catalog family `capSysN n` they are forced to be equal. -/
theorem height_depth_realizable_iff (n d i : ℕ) :
    (∃ S : ProofSys.{0, 0} Form, Consistent S ∧ IsGLTheory i S ∧
        (∀ k, Provable S (boxPow i k bot) ↔ n < k) ∧
        (∀ d', DepthReflection d' i S ↔ d' ≤ d)) ↔ d ≤ n := by
  constructor
  · rintro ⟨S, _, _, hheight, hdepth⟩
    by_contra hd
    push_neg at hd
    have hprov : Provable S (boxPow i (n + 1) bot) := (hheight (n + 1)).2 (by omega)
    have hnot : ¬ Provable S (boxPow i n bot) := fun h => absurd ((hheight n).1 h) (by omega)
    exact depthReflection_fails_of_inconsistency_height hprov hnot
      ((hdepth (n + 1)).2 (by omega))
  · intro hd
    obtain ⟨hcon, hgl, hheight, hdepth⟩ := reflection_depth_spectrum hd i
    exact ⟨spectrumSys n (n - d), hcon, hgl, hheight, hdepth⟩

/-- **The reflection depth is not determined by the inconsistency spectrum.**  For
every `n ≥ 1` the two block theories with shift points `0` and `n` prove exactly the
same iterated boxed falsa `□_i^k ⊥` (namely those with `k > n`), yet the first obeys
depth-`n` reflection while the second fails already at depth `1`.  Hence no function of
the provable iterated boxed falsa can compute the reflection depth. -/
theorem reflection_depth_not_determined_by_inconsistency_spectrum {n : ℕ} (hn : 1 ≤ n)
    (i : ℕ) :
    (∀ k, Provable (spectrumSys n 0) (boxPow i k bot) ↔
        Provable (spectrumSys n n) (boxPow i k bot)) ∧
      DepthReflection n i (spectrumSys n 0) ∧
      DepthReflection 1 i (spectrumSys n 0) ∧
      ¬ DepthReflection 1 i (spectrumSys n n) := by
  have hpos : DepthReflection n i (spectrumSys n 0) := by
    have := spectrumSys_depthReflection n 0 i
    simpa using this
  refine ⟨fun k => by
      rw [provable_spectrumSys_boxPow_bot, provable_spectrumSys_boxPow_bot], hpos,
    depthReflection_mono hn hpos, ?_⟩
  · intro h
    have hfail := spectrumSys_depthReflection_fails (n := n) (w := n) le_rfl i
    exact hfail (depthReflection_mono (by omega) h)

/-! ## §4. The bottom of the depth chain -/

/-- The block theory of height `n ≥ 1` is minimally sound at every tag: `□_i ⊥` is the
iterated boxed falsum of length `1`, provable only when `n < 1`. -/
theorem minSoundness_spectrumSys {n : ℕ} (hn : 1 ≤ n) (w i : ℕ) :
    MinSoundness i (spectrumSys n w) := by
  intro hbox
  have : Provable (spectrumSys n w) (boxPow i 1 bot) := hbox
  rw [provable_spectrumSys_boxPow_bot] at this
  omega

/-- **Minimal soundness is strictly weaker than the depth-`1` reflection rule.**  The
two-world block theory with shift point `1` — atoms true at the root only — is a
consistent GL theory, minimally sound at every tag, which nevertheless refutes
reflection already for the box-free formula `atom 0`: it proves `□_i (atom 0)` and
refutes `atom 0`.

This is optimal: the depth-`0` rule is vacuous, and by
`depthReflection_one_implies_minSoundness` the depth-`1` rule does imply minimal
soundness for consistent theories.  It also sharpens the catalog's
`minSoundness_not_implies_depthReflection_two` by one level, and it is impossible in
the atom-trivial semantics, where box-free formulas are world-independent. -/
theorem minSoundness_not_implies_depthReflection_one (i : ℕ) :
    Consistent (spectrumSys 1 1) ∧ IsGLTheory i (spectrumSys 1 1) ∧
      MinSoundness i (spectrumSys 1 1) ∧
      Provable (spectrumSys 1 1) (box i (probe i 0)) ∧
      ¬ Provable (spectrumSys 1 1) (probe i 0) ∧
      ¬ DepthReflection 1 i (spectrumSys 1 1) := by
  have hbox : Provable (spectrumSys 1 1) (box i (probe i 0)) := by
    have : box i (probe i 0) = probe i 1 := rfl
    rw [this, provable_spectrumSys_probe]
    omega
  have hnp : ¬ Provable (spectrumSys 1 1) (probe i 0) := by
    rw [provable_spectrumSys_probe]
    omega
  exact ⟨consistent_spectrumSys _ _, isGL_spectrumSys _ _ i,
    minSoundness_spectrumSys le_rfl 1 i, hbox, hnp,
    fun h => hnp (h (probe i 0) (by simp) hbox)⟩

/-- **The depth chain starts strictly above minimal soundness.**  Depth-`1` reflection
implies minimal soundness for consistent theories, and the converse fails. -/
theorem depthReflection_one_strictly_stronger :
    (∀ (i : ℕ) (S : ProofSys Form), Consistent S → DepthReflection 1 i S →
        MinSoundness i S) ∧
      ¬ ∀ (i : ℕ) (S : ProofSys.{0, 0} Form), Consistent S → MinSoundness i S →
          DepthReflection 1 i S := by
  refine ⟨fun _ _ hcon h => depthReflection_one_implies_minSoundness hcon h, fun hall => ?_⟩
  exact (minSoundness_not_implies_depthReflection_one 0).2.2.2.2.2
    (hall 0 (spectrumSys 1 1) (consistent_spectrumSys 1 1)
      (minSoundness_spectrumSys le_rfl 1 0))

/-- **Summary: height and reflection depth are independent invariants of consistent GL
theories.**  Every pair `(n, d)` with `d ≤ n` is realized; the inconsistency spectrum
does not see the reflection depth; and the chain of depth-restricted rules begins
strictly above minimal soundness already at its first level. -/
theorem reflection_depth_summary :
    (∀ n d i : ℕ, d ≤ n →
        Consistent (spectrumSys n (n - d)) ∧ IsGLTheory i (spectrumSys n (n - d)) ∧
        (∀ k, Provable (spectrumSys n (n - d)) (boxPow i k bot) ↔ n < k) ∧
        (∀ d', DepthReflection d' i (spectrumSys n (n - d)) ↔ d' ≤ d)) ∧
      (∀ n w i : ℕ, w ≤ n → ∀ d, DepthReflection d i (spectrumSys n w) ↔ d ≤ n - w) ∧
      (∀ n d i : ℕ, (∃ S : ProofSys.{0, 0} Form, Consistent S ∧ IsGLTheory i S ∧
          (∀ k, Provable S (boxPow i k bot) ↔ n < k) ∧
          (∀ d', DepthReflection d' i S ↔ d' ≤ d)) ↔ d ≤ n) ∧
      (∀ i : ℕ, Consistent (spectrumSys 1 1) ∧ MinSoundness i (spectrumSys 1 1) ∧
        ¬ DepthReflection 1 i (spectrumSys 1 1)) :=
  ⟨fun _ _ i hd => reflection_depth_spectrum hd i,
    fun _ _ i hw d => spectrumSys_depthReflection_iff hw d i,
    height_depth_realizable_iff,
    fun i => ⟨consistent_spectrumSys 1 1, minSoundness_spectrumSys le_rfl 1 i,
      (minSoundness_not_implies_depthReflection_one i).2.2.2.2.2⟩⟩

/-! ## §5. Rigidity of the block family

The family `capC c N` of `Novelty.HeightSpectrumTransfer` is highly redundant: many
height functions generate the same theory, and the classification of that redundancy is
the content of `Algebra.DepthDominationCriterion`.  The block family behaves in the
opposite way: the parameters `(n, w)` are recoverable from the theory, so the family is
*rigid*.  The proof uses world guards — formulas that pin the current world down to a
prescribed distance from the root and then assert something about it — the tag-free
analogue of the discriminators used for the inclusion criterion. -/

theorem satV_neg (V : ℕ → ℕ → Bool) (m : ℕ) (a : Form) :
    satV V m (neg a) = true ↔ satV V m a ≠ true := by
  rw [neg, satV_imp]
  constructor
  · intro hx hy
    have := hx hy
    simp [satV] at this
  · intro hx hy
    exact absurd hy hx

/-- The **world guard**: `□_i^{j+1}⊥ → (¬□_i^j⊥ → a)` asserts `a` at the unique world
lying at distance exactly `j` from the root, and is vacuously true everywhere else. -/
def worldGuard (i j : ℕ) (a : Form) : Form :=
  imp (boxPow i (j + 1) bot) (imp (neg (boxPow i j bot)) a)

theorem satV_worldGuard (V : ℕ → ℕ → Bool) (i j : ℕ) (a : Form) (m : ℕ) :
    satV V m (worldGuard i j a) = true ↔ (m = j → satV V m a = true) := by
  rw [worldGuard, satV_imp]
  constructor
  · intro h hm
    subst hm
    have h1 : satV V m (boxPow i (m + 1) bot) = true :=
      (satV_boxPow_bot V i (m + 1) m).2 (by omega)
    have h2 : satV V m (neg (boxPow i m bot)) = true := by
      rw [satV_neg]
      intro hx
      exact absurd ((satV_boxPow_bot V i m m).1 hx) (by omega)
    exact (satV_imp V m _ a).1 (h h1) h2
  · intro h h1
    have hm : m < j + 1 := (satV_boxPow_bot V i (j + 1) m).1 h1
    rw [satV_imp]
    intro h2
    have hm' : ¬ m < j := by
      intro hx
      exact (satV_neg V m _).1 h2 ((satV_boxPow_bot V i j m).2 hx)
    exact h (by omega)

/-- A world guard is a theorem exactly when the guarded world is outside the model or
the guarded formula holds there. -/
theorem provable_valSys_worldGuard (V : ℕ → ℕ → Bool) (N i j : ℕ) (a : Form) :
    Provable (valSys V N) (worldGuard i j a) ↔ (j ≤ N → satV V j a = true) := by
  rw [provable_valSys]
  constructor
  · intro h hj
    exact (satV_worldGuard V i j a j).1 (h j hj) rfl
  · intro h m _
    rw [satV_worldGuard]
    rintro rfl
    exact h (by omega)

/-- Two block valuations that agree below a world are indistinguishable at that world. -/
theorem satV_blockVal_congr {w w' : ℕ} :
    ∀ (a : Form) (m : ℕ), (∀ j ≤ m, (j < w ↔ j < w')) →
      satV (blockVal w) m a = satV (blockVal w') m a := by
  intro a
  induction a with
  | bot => intro m _; rfl
  | atom p =>
      intro m h
      simp only [satV, blockVal, decide_eq_decide]
      exact h m le_rfl
  | imp p q ihp ihq =>
      intro m h
      simp only [satV, ihp m h, ihq m h]
  | box i b ih =>
      intro m h
      rw [Bool.eq_iff_iff, satV_box, satV_box]
      constructor
      · intro hb n hn
        rw [← ih n (fun j hj => h j (by omega))]
        exact hb n hn
      · intro hb n hn
        rw [ih n (fun j hj => h j (by omega))]
        exact hb n hn

/-- **The inclusion criterion for the block family.**  The theory of the block model
`(n', w')` is contained in the theory of `(n, w)` exactly when the second model is not
taller and the two valuations agree at every world of the smaller model. -/
theorem spectrumSys_inclusion_iff (n w n' w' : ℕ) :
    (∀ a : Form, Provable (spectrumSys n' w') a → Provable (spectrumSys n w) a) ↔
      (n ≤ n' ∧ ∀ j ≤ n, (j < w ↔ j < w')) := by
  constructor
  · intro h
    have hn : n ≤ n' := by
      by_contra hlt
      push_neg at hlt
      have hp : Provable (spectrumSys n' w') (boxPow 0 (n' + 1) bot) :=
        (provable_spectrumSys_boxPow_bot n' w' 0 (n' + 1)).2 (by omega)
      have := (provable_spectrumSys_boxPow_bot n w 0 (n' + 1)).1 (h _ hp)
      omega
    refine ⟨hn, fun j hj => ?_⟩
    constructor
    · intro hjw
      by_contra hjw'
      have hp : Provable (spectrumSys n' w') (worldGuard 0 j (neg (atom 0))) := by
        rw [spectrumSys, provable_valSys_worldGuard]
        intro _
        rw [satV_neg]
        simp only [satV, blockVal, ne_eq, decide_eq_true_eq]
        omega
      have hq := (provable_valSys_worldGuard (blockVal w) n 0 j (neg (atom 0))).1 (h _ hp) hj
      rw [satV_neg] at hq
      simp only [satV, blockVal, ne_eq, decide_eq_true_eq] at hq
      omega
    · intro hjw'
      by_contra hjw
      have hp : Provable (spectrumSys n' w') (worldGuard 0 j (atom 0)) := by
        rw [spectrumSys, provable_valSys_worldGuard]
        intro _
        simp only [satV, blockVal, decide_eq_true_eq]
        omega
      have hq := (provable_valSys_worldGuard (blockVal w) n 0 j (atom 0)).1 (h _ hp) hj
      simp only [satV, blockVal, decide_eq_true_eq] at hq
      omega
  · rintro ⟨hn, hval⟩ a ha
    rw [spectrumSys, provable_valSys] at ha ⊢
    intro m hm
    rw [satV_blockVal_congr a m (fun j hj => hval j (by omega))]
    exact ha m (by omega)

/-- **The block family is rigid.**  Two block theories coincide exactly when they have
the same height and their valuations agree on all worlds of the model; in particular
the parameters are recoverable from the theory. -/
theorem spectrumSys_eq_iff (n w n' w' : ℕ) :
    (∀ a : Form, Provable (spectrumSys n w) a ↔ Provable (spectrumSys n' w') a) ↔
      (n = n' ∧ ∀ j ≤ n, (j < w ↔ j < w')) := by
  constructor
  · intro h
    obtain ⟨h1, hval⟩ := (spectrumSys_inclusion_iff n w n' w').1 (fun a ha => (h a).2 ha)
    obtain ⟨h2, _⟩ := (spectrumSys_inclusion_iff n' w' n w).1 (fun a ha => (h a).1 ha)
    exact ⟨le_antisymm h1 h2, hval⟩
  · rintro ⟨rfl, hval⟩ a
    exact ⟨fun ha => (spectrumSys_inclusion_iff n w' n w).2
        ⟨le_rfl, fun j hj => (hval j hj).symm⟩ a ha,
      fun ha => (spectrumSys_inclusion_iff n w n w').2 ⟨le_rfl, hval⟩ a ha⟩

/-- **Distinct reflection depths, distinct theories — and no other coincidences.**
Inside the range `w ≤ n` the shift point is recoverable from the theory, so the block
family of height `n` is a scale of `n + 1` pairwise distinct consistent GL theories,
indexed by their reflection depth `n - w`. -/
theorem spectrumSys_shift_injective {n w w' : ℕ} (hw : w ≤ n) (hw' : w' ≤ n)
    (h : ∀ a : Form, Provable (spectrumSys n w) a ↔ Provable (spectrumSys n w') a) :
    w = w' := by
  obtain ⟨_, hval⟩ := (spectrumSys_eq_iff n w n w').1 h
  by_contra hne
  rcases Nat.lt_or_ge w w' with hlt | hge
  · have := hval w hw
    omega
  · have hlt' : w' < w := by omega
    have := hval w' hw'
    omega

end ReflectionSpectrum