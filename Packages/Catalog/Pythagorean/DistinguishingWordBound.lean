import Mathlib

/-!
# Bounding the length of distinguishing experiments

For two deterministic Moore machines `M` (state set `S`) and `N` (state set `T`) over a
common input alphabet `A` and a common observation type `O`, two initial states `s : S`
and `t : T` are *behaviourally equivalent* when every input word produces the same
observation.  The central result of this file is that inequivalence is always witnessed
by a **short** experiment:

* `Machine.exists_short_distinguishing_word` —
  if `s` and `t` are inequivalent then there is a distinguishing word of length
  `< |S| * |T|`.

The proof is the product-automaton / fixpoint-refinement argument, carried out on the
increasing chain of "distinguishable within `k` steps" relations
`DistBy M N k ⊆ S × T`.  The chain is monotone, it is *saturating* (once a level repeats,
all later levels agree with it), and it lives inside the finite set `S × T`; hence it must
stabilise after at most `|S| * |T| - 1` strict increases.

Consequences proved here:

* `Machine.equivalent_iff_agreeUpTo` — a **finite test suite** characterisation:
  behavioural equivalence is decided by the words of length `< |S| * |T|`.
* `Machine.decidableEquivalent` — decidability of behavioural equivalence for finite
  alphabets, obtained from a genuinely computable bounded-agreement recursion.

The companion file `DistinguishingWordSharpness.lean` shows the bound is attained and
that no fixed finite test suite can work once finiteness of the state set is dropped.
-/

namespace Pythagorean.DistinguishingWord

universe u v w x

/-- A deterministic Moore machine: a transition function together with an observation
(output) attached to every state. -/
structure Machine (A : Type u) (O : Type v) (S : Type w) where
  /-- The (deterministic, total) transition function. -/
  step : S → A → S
  /-- The observation made in a state. -/
  out : S → O

namespace Machine

variable {A : Type u} {O : Type v} {S : Type w} {T : Type x}

/-- Run a machine from a state along an input word. -/
def run (M : Machine A O S) : S → List A → S
  | s, [] => s
  | s, a :: w => M.run (M.step s a) w

/-- The observation produced by running `M` from `s` along `w`. -/
def obs (M : Machine A O S) (s : S) (w : List A) : O := M.out (M.run s w)

@[simp] theorem run_nil (M : Machine A O S) (s : S) : M.run s [] = s := rfl

@[simp] theorem run_cons (M : Machine A O S) (s : S) (a : A) (w : List A) :
    M.run s (a :: w) = M.run (M.step s a) w := rfl

@[simp] theorem obs_nil (M : Machine A O S) (s : S) : M.obs s [] = M.out s := rfl

@[simp] theorem obs_cons (M : Machine A O S) (s : S) (a : A) (w : List A) :
    M.obs s (a :: w) = M.obs (M.step s a) w := rfl

/-- Two initial states (of possibly different machines) are *behaviourally equivalent*
when no experiment tells them apart. -/
def Equivalent (M : Machine A O S) (N : Machine A O T) (s : S) (t : T) : Prop :=
  ∀ w : List A, M.obs s w = N.obs t w

/-- `DistBy M N k s t`: the states `s` and `t` are separated by some word of length
at most `k`. -/
def DistBy (M : Machine A O S) (N : Machine A O T) (k : ℕ) (s : S) (t : T) : Prop :=
  ∃ w : List A, w.length ≤ k ∧ M.obs s w ≠ N.obs t w

/-- `AgreeUpTo M N k s t`: the states `s` and `t` agree on all words of length at most
`k`; this is the negation of `DistBy`. -/
def AgreeUpTo (M : Machine A O S) (N : Machine A O T) (k : ℕ) (s : S) (t : T) : Prop :=
  ∀ w : List A, w.length ≤ k → M.obs s w = N.obs t w

variable {M : Machine A O S} {N : Machine A O T}

theorem not_distBy_iff_agreeUpTo (k : ℕ) (s : S) (t : T) :
    ¬ DistBy M N k s t ↔ AgreeUpTo M N k s t := by
  unfold DistBy AgreeUpTo
  push_neg
  rfl

/-- Level `0`: only the immediate observation is available. -/
theorem distBy_zero_iff (s : S) (t : T) :
    DistBy M N 0 s t ↔ M.out s ≠ N.out t := by
  constructor
  · rintro ⟨w, hw, hne⟩
    rw [List.length_eq_zero_iff.mp (Nat.le_zero.mp hw)] at hne
    simpa using hne
  · intro h
    exact ⟨[], le_rfl, by simpa using h⟩

/-- The one-step unfolding of distinguishability: a word of length `≤ k+1` is either
empty (so the outputs already differ) or starts with a letter after which the successor
states are distinguishable within `k` steps. -/
theorem distBy_succ_iff (k : ℕ) (s : S) (t : T) :
    DistBy M N (k + 1) s t ↔
      M.out s ≠ N.out t ∨ ∃ a : A, DistBy M N k (M.step s a) (N.step t a) := by
  constructor
  · rintro ⟨w, hw, hne⟩
    match w with
    | [] => exact Or.inl (by simpa using hne)
    | a :: v =>
        refine Or.inr ⟨a, v, ?_, ?_⟩
        · simpa using Nat.succ_le_succ_iff.mp hw
        · simpa using hne
  · rintro (h | ⟨a, v, hv, hne⟩)
    · exact ⟨[], Nat.zero_le _, by simpa using h⟩
    · exact ⟨a :: v, by simpa using Nat.succ_le_succ hv, by simpa using hne⟩

/-- Distinguishability within `k` steps is monotone in `k`. -/
theorem distBy_mono {k l : ℕ} (h : k ≤ l) {s : S} {t : T} (hd : DistBy M N k s t) :
    DistBy M N l s t := by
  obtain ⟨w, hw, hne⟩ := hd
  exact ⟨w, hw.trans h, hne⟩

/-- If the observation map is globally constant across the two machines, nothing can be
distinguished. -/
theorem obs_eq_of_out_eq (h : ∀ (s : S) (t : T), M.out s = N.out t) :
    ∀ (w : List A) (s : S) (t : T), M.obs s w = N.obs t w := by
  intro w
  induction w with
  | nil => intro s t; simpa using h s t
  | cons a v ih => intro s t; simpa using ih (M.step s a) (N.step t a)

/-- **Saturation**: if level `k+1` adds nothing to level `k`, then no later level does
either.  Proved by an induction that transports stability one level up at a time. -/
theorem distBy_stable_succ {k : ℕ}
    (h : ∀ (s : S) (t : T), DistBy M N (k + 1) s t → DistBy M N k s t) :
    ∀ j : ℕ, ∀ (s : S) (t : T), DistBy M N (k + j + 1) s t → DistBy M N (k + j) s t := by
  intro j
  induction j with
  | zero => simpa using h
  | succ j ih =>
      intro s t hd
      have h1 : k + (j + 1) + 1 = (k + j + 1) + 1 := by omega
      rw [h1, distBy_succ_iff] at hd
      rcases hd with hd | ⟨a, ha⟩
      · exact ⟨[], Nat.zero_le _, by simpa using hd⟩
      · have := ih _ _ ha
        have h2 : k + (j + 1) = (k + j) + 1 := by omega
        rw [h2, distBy_succ_iff]
        exact Or.inr ⟨a, this⟩

/-- All levels above a stable level collapse back to it. -/
theorem distBy_of_stable {k : ℕ}
    (h : ∀ (s : S) (t : T), DistBy M N (k + 1) s t → DistBy M N k s t) :
    ∀ j : ℕ, ∀ (s : S) (t : T), DistBy M N (k + j) s t → DistBy M N k s t := by
  intro j
  induction j with
  | zero => intro s t hd; simpa using hd
  | succ j ih =>
      intro s t hd
      have h2 : k + (j + 1) = (k + j) + 1 := by omega
      rw [h2] at hd
      exact ih s t (distBy_stable_succ h j s t hd)

section Finite

variable [Fintype S] [Fintype T]

/-- **Main theorem.**  If two initial states of finite-state Moore machines are
behaviourally inequivalent, they are already separated by an experiment of length
strictly less than `|S| * |T|`. -/
theorem exists_short_distinguishing_word (M : Machine A O S) (N : Machine A O T)
    (s : S) (t : T) (h : ¬ Equivalent M N s t) :
    ∃ w : List A, w.length < Fintype.card S * Fintype.card T ∧ M.obs s w ≠ N.obs t w := by
  classical
  set n : ℕ := Fintype.card S * Fintype.card T with hn
  -- the finite chain of distinguishability levels
  set D : ℕ → Finset (S × T) :=
    fun k => Finset.univ.filter (fun p : S × T => DistBy M N k p.1 p.2) with hDdef
  have hmem : ∀ (k : ℕ) (p : S × T), p ∈ D k ↔ DistBy M N k p.1 p.2 := by
    intro k p; simp [hDdef]
  have hmono : ∀ k, D k ⊆ D (k + 1) := by
    intro k p hp
    rw [hmem] at hp ⊢
    exact distBy_mono (Nat.le_succ k) hp
  have hcard_le : ∀ k, (D k).card ≤ n := by
    intro k
    calc (D k).card ≤ Fintype.card (S × T) := by
          simpa using Finset.card_le_univ (D k)
      _ = n := by rw [hn, Fintype.card_prod]
  -- the whole chain is nonempty at level `0`
  have hne : ∃ (s0 : S) (t0 : T), M.out s0 ≠ N.out t0 := by
    by_contra hc
    push_neg at hc
    exact h fun w => obs_eq_of_out_eq hc w s t
  have hD0 : (D 0).Nonempty := by
    obtain ⟨s0, t0, h0⟩ := hne
    exact ⟨(s0, t0), by rw [hmem]; exact (distBy_zero_iff s0 t0).mpr h0⟩
  -- stabilisation happens before step `n`
  have hstab : ∃ k < n, ∀ (s' : S) (t' : T), DistBy M N (k + 1) s' t' → DistBy M N k s' t' := by
    by_contra hc
    push_neg at hc
    have hgrow : ∀ k ≤ n, k + 1 ≤ (D k).card := by
      intro k
      induction k with
      | zero => intro _; exact Finset.card_pos.mpr hD0
      | succ k ih =>
          intro hk
          have hk' : k ≤ n := Nat.le_of_succ_le hk
          have hlt : k < n := hk
          obtain ⟨s', t', hd1, hd2⟩ := hc k hlt
          have hsub : D k ⊂ D (k + 1) := by
            refine ⟨hmono k, ?_⟩
            intro hcon
            exact hd2 (by
              have : ((s', t') : S × T) ∈ D (k + 1) := by rw [hmem]; exact hd1
              have := hcon this
              rwa [hmem] at this)
          have := Finset.card_lt_card hsub
          omega
    have := hgrow n le_rfl
    have := hcard_le n
    omega
  obtain ⟨k, hkn, hk⟩ := hstab
  -- pull the (arbitrarily long) witness down to level `k`
  have hexists : ∃ w : List A, M.obs s w ≠ N.obs t w := by
    by_contra hc
    push_neg at hc
    exact h hc
  obtain ⟨w, hw⟩ := hexists
  have hlong : DistBy M N (k + w.length) s t :=
    distBy_mono (Nat.le_add_left _ _) ⟨w, le_rfl, hw⟩
  obtain ⟨v, hv, hvne⟩ := distBy_of_stable hk w.length s t hlong
  exact ⟨v, lt_of_le_of_lt hv hkn, hvne⟩

/-- **Finite test suite theorem.**  Behavioural equivalence of finite-state Moore
machines is *exactly* agreement on the finitely many words of length `< |S| * |T|`. -/
theorem equivalent_iff_agree_short (M : Machine A O S) (N : Machine A O T) (s : S) (t : T) :
    Equivalent M N s t ↔
      ∀ w : List A, w.length < Fintype.card S * Fintype.card T → M.obs s w = N.obs t w := by
  constructor
  · intro h w _; exact h w
  · intro h
    by_contra hc
    obtain ⟨w, hlen, hne⟩ := exists_short_distinguishing_word M N s t hc
    exact hne (h w hlen)

/-- Reformulation of the test suite theorem in terms of `AgreeUpTo`. -/
theorem equivalent_iff_agreeUpTo (M : Machine A O S) (N : Machine A O T) (s : S) (t : T)
    (hpos : 0 < Fintype.card S * Fintype.card T) :
    Equivalent M N s t ↔
      AgreeUpTo M N (Fintype.card S * Fintype.card T - 1) s t := by
  rw [equivalent_iff_agree_short]
  constructor
  · intro h w hw; exact h w (by omega)
  · intro h w hw; exact h w (by omega)

end Finite

section Decidability

variable [Fintype A] [DecidableEq O]

omit [Fintype A] [DecidableEq O] in
theorem agreeUpTo_zero_iff (M : Machine A O S) (N : Machine A O T) (s : S) (t : T) :
    AgreeUpTo M N 0 s t ↔ M.out s = N.out t := by
  rw [← not_distBy_iff_agreeUpTo, distBy_zero_iff, not_not]

omit [Fintype A] [DecidableEq O] in
theorem agreeUpTo_succ_iff (M : Machine A O S) (N : Machine A O T) (k : ℕ) (s : S) (t : T) :
    AgreeUpTo M N (k + 1) s t ↔
      M.out s = N.out t ∧ ∀ a : A, AgreeUpTo M N k (M.step s a) (N.step t a) := by
  rw [← not_distBy_iff_agreeUpTo, distBy_succ_iff]
  push_neg
  simp only [← not_distBy_iff_agreeUpTo]

/-- Bounded agreement is decidable by an explicit recursion on the bound. -/
instance decidableAgreeUpTo (M : Machine A O S) (N : Machine A O T) :
    ∀ (k : ℕ) (s : S) (t : T), Decidable (AgreeUpTo M N k s t)
  | 0, s, t => decidable_of_iff _ (agreeUpTo_zero_iff M N s t).symm
  | k + 1, s, t =>
      letI : ∀ (s' : S) (t' : T), Decidable (AgreeUpTo M N k s' t') :=
        fun s' t' => decidableAgreeUpTo M N k s' t'
      decidable_of_iff _ (agreeUpTo_succ_iff M N k s t).symm

/-- **Decidability of behavioural equivalence** for finite alphabets and finite state
sets: run the (decidable) bounded-agreement test up to the length bound. -/
instance decidableEquivalent [Fintype S] [Fintype T] [Nonempty S] [Nonempty T]
    (M : Machine A O S) (N : Machine A O T) (s : S) (t : T) :
    Decidable (Equivalent M N s t) := by
  have hpos : 0 < Fintype.card S * Fintype.card T :=
    Nat.mul_pos Fintype.card_pos Fintype.card_pos
  exact decidable_of_iff _ (equivalent_iff_agreeUpTo M N s t hpos).symm

end Decidability

end Machine

end Pythagorean.DistinguishingWord