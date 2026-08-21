import Pythagorean.DistinguishingWordMoore

/-!
# Sharpness of the distinguishing-word bound, and the infinite-state barrier

`DistinguishingWordBound.lean` proves that inequivalent initial states of finite Moore
machines are separated by a word of length `< |S| * |T|`.  This file delimits that result
from both sides.

## Sharpness

The *counter family* `counterMachine n` (states `Fin (n+1)`, a saturating counter that
reports `true` only in the top state) against the one-state `sinkMachine` (constantly
`false`) has

* `counterMachine_distinguishes_iff` — a word distinguishes the two initial states
  **iff** its length is at least `n`;
* `counterMachine_min_distinguishing_length` — hence the shortest experiment has length
  exactly `|Fin (n+1)| * |Unit| - 1`.

So the bound `< |S| * |T|` of the main theorem is attained for every `n`, and no bound
independent of the state counts can exist (`no_uniform_length_bound`).

## The infinite-state barrier

Every function `f : List A → Bool` is the behaviour of the *free* machine on state set
`List A` (`freeMachine_obs_nil`).  Consequently, once the state set is allowed to be
infinite, **no fixed finite test suite works**:

* `no_finite_test` — for any finite set of test words `W` there are two functions
  agreeing on all of `W` yet different;
* `no_finite_test_machines` — the machine-level form: two inequivalent initial states
  that pass every test in `W`.

This is exactly the dividing line: finiteness of `S × T` is what converts decidability
into a finite test suite.
-/

namespace Pythagorean.DistinguishingWord

namespace Machine

/-! ### The saturating counter family -/

/-- A saturating counter on `Fin (n+1)`: every input advances the state by one until the
top state `n` is reached, and only the top state observes `true`. -/
def counterMachine (n : ℕ) : Machine Unit Bool (Fin (n + 1)) where
  step i _ := if h : (i : ℕ) < n then ⟨(i : ℕ) + 1, by omega⟩ else i
  out i := decide ((i : ℕ) = n)

/-- The one-state machine that always observes `false`. -/
def sinkMachine : Machine Unit Bool Unit where
  step _ _ := ()
  out _ := false

/-- Running the counter from `i` along a word of length `ℓ` lands in state `min (i + ℓ) n`. -/
theorem counterMachine_run (n : ℕ) :
    ∀ (w : List Unit) (i : Fin (n + 1)),
      ((counterMachine n).run i w : ℕ) = min ((i : ℕ) + w.length) n := by
  intro w
  induction w with
  | nil => intro i; simp [Nat.min_eq_left i.is_le]
  | cons a v ih =>
      intro i
      rw [run_cons, ih]
      by_cases h : (i : ℕ) < n
      · have : (((counterMachine n).step i a : Fin (n + 1)) : ℕ) = (i : ℕ) + 1 := by
          simp [counterMachine, h]
        rw [this]
        simp only [List.length_cons]
        omega
      · have hi : (i : ℕ) = n := by have := i.is_le; omega
        have : (((counterMachine n).step i a : Fin (n + 1)) : ℕ) = (i : ℕ) := by
          simp [counterMachine, h]
        rw [this]
        simp only [List.length_cons]
        omega

/-- The observation of the counter after a word only depends on the word's length. -/
theorem counterMachine_obs (n : ℕ) (w : List Unit) :
    (counterMachine n).obs ⟨0, Nat.succ_pos n⟩ w = decide (n ≤ w.length) := by
  have h := counterMachine_run n w ⟨0, Nat.succ_pos n⟩
  simp only [Nat.zero_add] at h
  show decide ((((counterMachine n).run ⟨0, Nat.succ_pos n⟩ w : Fin (n + 1)) : ℕ) = n)
      = decide (n ≤ w.length)
  rw [h]
  by_cases hle : n ≤ w.length
  · simp [hle]
  · have : min w.length n = w.length := Nat.min_eq_left (le_of_not_ge hle)
    simp [this, hle]
    omega

@[simp] theorem sinkMachine_obs (w : List Unit) : sinkMachine.obs () w = false := by
  induction w with
  | nil => rfl
  | cons a v ih => simp [sinkMachine] at ih ⊢; exact ih

/-- **Exact characterisation of the distinguishing words** for the counter family: a word
separates the counter's initial state from the sink exactly when it is long enough. -/
theorem counterMachine_distinguishes_iff (n : ℕ) (w : List Unit) :
    (counterMachine n).obs ⟨0, Nat.succ_pos n⟩ w ≠ sinkMachine.obs () w ↔ n ≤ w.length := by
  rw [counterMachine_obs, sinkMachine_obs]
  by_cases h : n ≤ w.length <;> simp [h]

/-- The counter's initial state and the sink are inequivalent. -/
theorem counterMachine_not_equivalent (n : ℕ) :
    ¬ Equivalent (counterMachine n) sinkMachine ⟨0, Nat.succ_pos n⟩ () := by
  intro h
  have := (counterMachine_distinguishes_iff n (List.replicate n ())).mpr
    (by simp)
  exact this (h _)

/-- **Sharpness.**  For the counter family the shortest distinguishing experiment has
length exactly `|S| * |T| - 1`, so the bound `< |S| * |T|` of
`exists_short_distinguishing_word` is attained for every `n`. -/
theorem counterMachine_min_distinguishing_length (n : ℕ) :
    (∃ w : List Unit,
        w.length = Fintype.card (Fin (n + 1)) * Fintype.card Unit - 1 ∧
        (counterMachine n).obs ⟨0, Nat.succ_pos n⟩ w ≠ sinkMachine.obs () w) ∧
      (∀ w : List Unit,
        (counterMachine n).obs ⟨0, Nat.succ_pos n⟩ w ≠ sinkMachine.obs () w →
          Fintype.card (Fin (n + 1)) * Fintype.card Unit - 1 ≤ w.length) := by
  have hcard : Fintype.card (Fin (n + 1)) * Fintype.card Unit - 1 = n := by simp
  constructor
  · refine ⟨List.replicate n (), by simp, ?_⟩
    exact (counterMachine_distinguishes_iff n _).mpr (by simp)
  · intro w hw
    rw [hcard]
    exact (counterMachine_distinguishes_iff n w).mp hw

/-- **The Moore bound is attained too.**  For the counter family the shortest
distinguishing experiment has length exactly `|S| + |T| - 2`, so the linear bound of
`exists_distinguishing_word_moore` cannot be improved either. -/
theorem counterMachine_moore_bound_tight (n : ℕ) :
    (∃ w : List Unit,
        w.length = Fintype.card (Fin (n + 1)) + Fintype.card Unit - 2 ∧
        (counterMachine n).obs ⟨0, Nat.succ_pos n⟩ w ≠ sinkMachine.obs () w) ∧
      (∀ w : List Unit,
        (counterMachine n).obs ⟨0, Nat.succ_pos n⟩ w ≠ sinkMachine.obs () w →
          Fintype.card (Fin (n + 1)) + Fintype.card Unit - 2 ≤ w.length) := by
  have hcard : Fintype.card (Fin (n + 1)) + Fintype.card Unit - 2 = n := by simp
  refine ⟨⟨List.replicate n (), by simp, ?_⟩, ?_⟩
  · exact (counterMachine_distinguishes_iff n _).mpr (by simp)
  · intro w hw
    rw [hcard]
    exact (counterMachine_distinguishes_iff n w).mp hw

/-- **No uniform bound.**  For every `k` there is a pair of finite machines whose
inequivalence needs an experiment of length at least `k`; hence any bound must grow with
the state counts. -/
theorem no_uniform_length_bound (k : ℕ) :
    ∃ (n : ℕ), ¬ Equivalent (counterMachine n) sinkMachine ⟨0, Nat.succ_pos n⟩ () ∧
      ∀ w : List Unit,
        (counterMachine n).obs ⟨0, Nat.succ_pos n⟩ w ≠ sinkMachine.obs () w → k ≤ w.length := by
  refine ⟨k, counterMachine_not_equivalent k, ?_⟩
  intro w hw
  exact (counterMachine_distinguishes_iff k w).mp hw

/-! ### Every behaviour is realised by a machine: the free machine -/

variable {A : Type*}

/-- The *free* machine on the alphabet `A`: states are the words read so far, and the
observation in a state is the value of `f` there. -/
def freeMachine (f : List A → Bool) : Machine A Bool (List A) where
  step s a := s ++ [a]
  out := f

theorem freeMachine_run (f : List A → Bool) :
    ∀ (w s : List A), (freeMachine f).run s w = s ++ w := by
  intro w
  induction w with
  | nil => intro s; simp
  | cons a v ih =>
      intro s
      have hs : (freeMachine f).step s a = s ++ [a] := rfl
      rw [run_cons, hs, ih (s ++ [a])]
      simp

/-- Every function on words is the behaviour of (the initial state of) some machine. -/
theorem freeMachine_obs_nil (f : List A → Bool) (w : List A) :
    (freeMachine f).obs [] w = f w := by
  show (freeMachine f).out ((freeMachine f).run [] w) = f w
  rw [freeMachine_run, List.nil_append]
  rfl

/-! ### No finite test suite for arbitrary behaviours -/

/-- **`no_finite_test`.**  Over a nonempty alphabet, no finite set of test words can
separate all pairs of distinct behaviours: for every finite `W` there are two functions
that agree on all of `W` yet differ somewhere. -/
theorem no_finite_test [Nonempty A] [DecidableEq A] (W : Finset (List A)) :
    ∃ f g : List A → Bool, (∀ w ∈ W, f w = g w) ∧ f ≠ g := by
  classical
  obtain ⟨a⟩ := ‹Nonempty A›
  set m : ℕ := W.sup List.length with hm
  set u : List A := List.replicate (m + 1) a with hu
  have hlen : u.length = m + 1 := by simp [hu]
  have hnot : u ∉ W := by
    intro hmem
    have : u.length ≤ m := Finset.le_sup (f := List.length) hmem
    omega
  refine ⟨fun _ => false, fun v => decide (v = u), ?_, ?_⟩
  · intro w hw
    have : w ≠ u := by rintro rfl; exact hnot hw
    simp [this]
  · intro hfg
    have : (false : Bool) = decide (u = u) := congrFun hfg u
    simp at this

/-- Machine-level form of `no_finite_test`: with infinite state sets allowed, for every
finite test suite `W` there are two machines whose initial states pass every test in `W`
but are behaviourally inequivalent.  Contrast with `equivalent_iff_agree_short`, where
finiteness of `S × T` makes the suite `{w : |w| < |S| * |T|}` complete. -/
theorem no_finite_test_machines [Nonempty A] [DecidableEq A] (W : Finset (List A)) :
    ∃ (f g : List A → Bool),
      (∀ w ∈ W, (freeMachine f).obs [] w = (freeMachine g).obs [] w) ∧
      ¬ Equivalent (freeMachine f) (freeMachine g) [] [] := by
  obtain ⟨f, g, hagree, hne⟩ := no_finite_test (A := A) W
  refine ⟨f, g, ?_, ?_⟩
  · intro w hw
    rw [freeMachine_obs_nil, freeMachine_obs_nil]
    exact hagree w hw
  · intro hEq
    exact hne (funext fun w => by
      have := hEq w
      rwa [freeMachine_obs_nil, freeMachine_obs_nil] at this)

end Machine

end Pythagorean.DistinguishingWord