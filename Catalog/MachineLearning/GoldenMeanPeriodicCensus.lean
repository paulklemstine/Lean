import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.GoldenMeanChaos
import MachineLearning.GoldenMeanEntropy
import MachineLearning.GoldenMeanRigidity

/-!
# The Lucas periodic census of the golden-mean subshift

Eleventh cycle of the research thread begun in `Shared.GraphTheory.FractalTruthMetric`.

Cycle 8 (`MachineLearning.GoldenMeanRigidity`) separated the full shift from the golden-mean
shift by counting *fixed* points: `2` against `1`.  Cycle 10 confirmed the next rung by an
independent computation.  Here we prove the whole census at once, for every period.

For a period `n ≥ 1` the points of `GoldenMean` fixed by `shift^[n]` are exactly the periodic
repetitions of the *cyclically admissible* words of length `n` — admissible words whose first
and last letters are not both `true`.  Counting those words by inclusion–exclusion against the
two Fibonacci counts "first letter `false`" and "last letter `false`" gives the Lucas number

`lucas n = fib (n+1) + fib (n-1)`,

while the full shift has `2 ^ n` points of period `n`.  Since `lucas n < 2 ^ n` for every
`n ≥ 1`, *every* period is an obstruction to conjugacy, upgrading cycle 8's single-period
argument to an infinite hierarchy.

## Main results

* `rep_bijOn_periodicPoints` — the periodic repetition map is a bijection from cyclically
  admissible words of length `n` onto the `n`-periodic points of the subshift.
* `card_cyclicGoldenWords` — there are `fib (n+1) + fib (n-1)` cyclically admissible words.
* `ncard_periodicPoints_goldenMean` — the census: `#{x ∈ GoldenMean | shift^[n] x = x} = lucas n`.
* `ncard_periodicPoints_cantor` — the full shift has `2 ^ n` points of period `n`.
* `lucas_lt_two_pow` and `no_shift_equiv_of_period` — the resulting conjugacy obstruction at
  every period.
-/

namespace FractalTruthCompactness

open FractalTruthMetric

/-! ## Lucas numbers -/

/-- The Lucas numbers, the second solution of the Fibonacci recursion. -/
def lucas : ℕ → ℕ
  | 0 => 2
  | 1 => 1
  | (n + 2) => lucas n + lucas (n + 1)

@[simp] theorem lucas_zero : lucas 0 = 2 := rfl
@[simp] theorem lucas_one : lucas 1 = 1 := rfl
theorem lucas_add_two (n : ℕ) : lucas (n + 2) = lucas n + lucas (n + 1) := rfl

/-- The Lucas numbers in terms of Fibonacci numbers: `L (n+1) = fib (n+2) + fib n`. -/
theorem lucas_succ_eq_fib : ∀ n : ℕ, lucas (n + 1) = Nat.fib (n + 2) + Nat.fib n
  | 0 => by decide
  | 1 => by decide
  | (n + 2) => by
      have ih1 : lucas (n + 1) = Nat.fib (n + 2) + Nat.fib n := lucas_succ_eq_fib n
      have ih2 : lucas (n + 2) = Nat.fib (n + 3) + Nat.fib (n + 1) := lucas_succ_eq_fib (n + 1)
      have hrec : lucas (n + 3) = lucas (n + 1) + lucas (n + 2) := lucas_add_two (n + 1)
      have h1 : Nat.fib (n + 4) = Nat.fib (n + 2) + Nat.fib (n + 3) := Nat.fib_add_two
      have h2 : Nat.fib (n + 2) = Nat.fib n + Nat.fib (n + 1) := Nat.fib_add_two
      show lucas (n + 3) = Nat.fib (n + 4) + Nat.fib (n + 2)
      omega

/-- Lucas numbers grow strictly slower than `2 ^ n`. -/
theorem lucas_lt_two_pow : ∀ n : ℕ, lucas (n + 1) < 2 ^ (n + 1)
  | 0 => by decide
  | 1 => by decide
  | (n + 2) => by
      have ih1 : lucas (n + 1) < 2 ^ (n + 1) := lucas_lt_two_pow n
      have ih2 : lucas (n + 2) < 2 ^ (n + 2) := lucas_lt_two_pow (n + 1)
      have hrec : lucas (n + 3) = lucas (n + 1) + lucas (n + 2) := lucas_add_two (n + 1)
      have h1 : (2 : ℕ) ^ (n + 2) = 2 * 2 ^ (n + 1) := by ring
      have h2 : (2 : ℕ) ^ (n + 3) = 4 * 2 ^ (n + 1) := by ring
      show lucas (n + 3) < 2 ^ (n + 3)
      omega

/-! ## Periodic repetition of a word -/

/-- Repeat a word periodically to obtain a stream (the empty word gives the all-`false`
stream). -/
def rep (w : List Bool) : Cantor := fun k => w.getD (k % w.length) false

theorem rep_apply (w : List Bool) (k : ℕ) : rep w k = w.getD (k % w.length) false := rfl

theorem rep_eq_of_lt {w : List Bool} {k : ℕ} (hk : k < w.length) :
    rep w k = w.getD k false := by
  rw [rep_apply, Nat.mod_eq_of_lt hk]

theorem shift_iterate_rep (w : List Bool) : shift^[w.length] (rep w) = rep w := by
  funext k
  rw [shift_iterate_apply, rep_apply, rep_apply, Nat.add_mod_right]

/-! ## Coordinates of a prefix -/

theorem getD_prefixOf : ∀ (n : ℕ) (x : Cantor) (k : ℕ), k < n →
    (prefixOf n x).getD k false = x k
  | 0, _, _, hk => absurd hk (Nat.not_lt_zero _)
  | (n + 1), x, 0, _ => rfl
  | (n + 1), x, (k + 1), hk => by
      have hk' : k < n := Nat.lt_of_succ_lt_succ hk
      have := getD_prefixOf n (shift x) k hk'
      simpa [shift] using this

theorem head?_prefixOf {n : ℕ} (hn : 0 < n) (x : Cantor) :
    (prefixOf n x).head? = some (x 0) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  rfl

/-- The last letter of a nonempty word is unaffected by prefixing another letter. -/
theorem getLast?_cons_ne_nil {b : Bool} {t : List Bool} (h : t ≠ []) :
    (b :: t).getLast? = t.getLast? := by
  cases t with
  | nil => exact absurd rfl h
  | cons a s => simp [List.getLast?_cons_cons]

theorem getLast?_eq_getD {w : List Bool} (hw : w ≠ []) :
    w.getLast? = some (w.getD (w.length - 1) false) := by
  rw [List.getLast?_eq_getElem?]
  have hlt : w.length - 1 < w.length := by
    have := List.length_pos_of_ne_nil hw
    omega
  rw [List.getElem?_eq_getElem hlt, List.getD_eq_getElem _ _ hlt]

/-! ## Periodic points are periodic repetitions -/

/-- A point fixed by `shift^[n]` has `n`-periodic coordinates. -/
theorem apply_mod_of_periodic {n : ℕ} (hn : 0 < n) {x : Cantor} (hx : shift^[n] x = x) :
    ∀ k, x k = x (k % n) := by
  have hstep : ∀ k, x (k + n) = x k := by
    intro k
    have := congrFun hx k
    rwa [shift_iterate_apply] at this
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
      by_cases hk : k < n
      · rw [Nat.mod_eq_of_lt hk]
      · have hkn : n ≤ k := Nat.le_of_not_lt hk
        have hlt : k - n < k := by omega
        have h1 : x (k - n) = x ((k - n) % n) := ih _ hlt
        have h2 : x (k - n + n) = x (k - n) := hstep (k - n)
        have h3 : k - n + n = k := by omega
        rw [h3] at h2
        have h4 : (k - n + n) % n = (k - n) % n := Nat.add_mod_right _ _
        rw [h3] at h4
        rw [h2, h1, h4]

theorem rep_prefixOf_of_periodic {n : ℕ} (hn : 0 < n) {x : Cantor} (hx : shift^[n] x = x) :
    rep (prefixOf n x) = x := by
  funext k
  have hlen : (prefixOf n x).length = n := length_prefixOf n x
  rw [rep_apply, hlen]
  have hmod : k % n < n := Nat.mod_lt _ hn
  rw [getD_prefixOf n x (k % n) hmod]
  exact (apply_mod_of_periodic hn hx k).symm

theorem prefixOf_rep {n : ℕ} {w : List Bool} (hw : w.length = n) :
    prefixOf n (rep w) = w := by
  have hagree : AgreeTo n (rep w) (extend w) := by
    intro k hk
    have hk' : k < w.length := by omega
    rw [rep_eq_of_lt hk']
    rfl
  have h1 : prefixOf n (rep w) = prefixOf n (extend w) :=
    (prefixOf_eq_iff_agreeTo n _ _).mpr hagree
  rw [h1, ← hw, prefixOf_extend]

/-! ## Cyclically admissible words -/

/-- Admissible words of length `n` whose first and last letters are not both `true`;
equivalently, the words that can be repeated periodically inside the subshift. -/
def cyclicGoldenWords (n : ℕ) : Finset (List Bool) :=
  (goldenWords n).filter (fun w => ¬(w.head? = some true ∧ w.getLast? = some true))

theorem mem_cyclicGoldenWords {n : ℕ} {w : List Bool} :
    w ∈ cyclicGoldenWords n ↔
      (w.length = n ∧ Admissible w) ∧ ¬(w.head? = some true ∧ w.getLast? = some true) := by
  rw [cyclicGoldenWords, Finset.mem_filter, mem_goldenWords]

/-- The periodic repetition of a cyclically admissible word lies in the subshift. -/
theorem rep_mem_goldenMean {n : ℕ} (hn : 0 < n) {w : List Bool}
    (hw : w ∈ cyclicGoldenWords n) : rep w ∈ GoldenMean := by
  obtain ⟨⟨hlen, hadm⟩, hcyc⟩ := mem_cyclicGoldenWords.mp hw
  have hwne : w ≠ [] := by
    intro h
    rw [h] at hlen
    simp at hlen
    omega
  have hpos : 0 < w.length := by
    cases w with
    | nil => simp at hwne
    | cons a t => simp
  intro k
  rintro ⟨h1, h2⟩
  have hmod : k % w.length < w.length := Nat.mod_lt _ hpos
  have hsucc : (k + 1) % w.length = (k % w.length + 1) % w.length := (Nat.mod_add_mod _ _ _).symm
  by_cases hlast : k % w.length + 1 < w.length
  · -- interior clash, forbidden by admissibility
    have hnext : (k + 1) % w.length = k % w.length + 1 := by
      rw [hsucc, Nat.mod_eq_of_lt hlast]
    rw [rep_apply, hnext] at h2
    rw [rep_apply] at h1
    exact admissible_getD hadm (k % w.length) hlast ⟨h1, h2⟩
  · -- wrap-around clash, forbidden by cyclicity
    have heq : k % w.length = w.length - 1 := by omega
    have hnext : (k + 1) % w.length = 0 := by
      rw [hsucc, heq, show w.length - 1 + 1 = w.length by omega, Nat.mod_self]
    rw [rep_apply, hnext] at h2
    rw [rep_apply, heq] at h1
    refine hcyc ⟨?_, ?_⟩
    · rw [List.head?_eq_getElem?, List.getElem?_eq_getElem (by omega)]
      rw [List.getD_eq_getElem _ _ (by omega)] at h2
      exact congrArg some h2
    · rw [getLast?_eq_getD hwne]
      exact congrArg some h1

/-- Conversely, the length-`n` prefix of an `n`-periodic point is cyclically admissible. -/
theorem prefixOf_mem_cyclicGoldenWords {n : ℕ} (hn : 0 < n) {x : Cantor} (hx : x ∈ GoldenMean)
    (hper : shift^[n] x = x) : prefixOf n x ∈ cyclicGoldenWords n := by
  have hmem := prefixOf_mem_goldenWords n hx
  rw [mem_cyclicGoldenWords]
  refine ⟨(mem_goldenWords n _).mp hmem, ?_⟩
  rintro ⟨hhead, hlast⟩
  have hlen : (prefixOf n x).length = n := length_prefixOf n x
  have hne : prefixOf n x ≠ [] := by
    intro h
    rw [h] at hlen
    simp at hlen
    omega
  have h0 : x 0 = true := by
    rw [head?_prefixOf hn x] at hhead
    exact Option.some_injective _ hhead
  have hlastval : (prefixOf n x).getD (n - 1) false = true := by
    rw [getLast?_eq_getD hne, hlen] at hlast
    exact Option.some_injective _ hlast
  have hn1 : x (n - 1) = true := by
    rw [getD_prefixOf n x (n - 1) (by omega)] at hlastval
    exact hlastval
  have hxn : x n = x 0 := by
    have := apply_mod_of_periodic hn hper n
    rwa [Nat.mod_self] at this
  have : n - 1 + 1 = n := by omega
  exact hx (n - 1) ⟨hn1, by rw [this, hxn, h0]⟩

/-! ## The bijection -/

/-- The `n`-periodic points of the golden-mean subshift. -/
def periodicPoints (n : ℕ) : Set Cantor := {x | x ∈ GoldenMean ∧ shift^[n] x = x}

theorem rep_injOn (n : ℕ) :
    Set.InjOn rep (cyclicGoldenWords n : Set (List Bool)) := by
  intro v hv w hw h
  have hv' := (mem_cyclicGoldenWords.mp (by simpa using hv)).1.1
  have hw' := (mem_cyclicGoldenWords.mp (by simpa using hw)).1.1
  have := congrArg (prefixOf n) h
  rwa [prefixOf_rep hv', prefixOf_rep hw'] at this

/-- **The periodic points are exactly the periodic repetitions of cyclically admissible
words.** -/
theorem periodicPoints_eq_image {n : ℕ} (hn : 0 < n) :
    periodicPoints n = rep '' (cyclicGoldenWords n : Set (List Bool)) := by
  ext x
  simp only [Set.mem_image, Finset.mem_coe, periodicPoints, Set.mem_setOf_eq]
  constructor
  · rintro ⟨hx, hper⟩
    exact ⟨prefixOf n x, prefixOf_mem_cyclicGoldenWords hn hx hper,
      rep_prefixOf_of_periodic hn hper⟩
  · rintro ⟨w, hw, rfl⟩
    have hlen := (mem_cyclicGoldenWords.mp hw).1.1
    refine ⟨rep_mem_goldenMean hn hw, ?_⟩
    have := shift_iterate_rep w
    rwa [hlen] at this

/-! ## Counting cyclically admissible words -/

/-- Admissible words starting with `false` are the admissible words of length one less,
prefixed by `false`. -/
theorem filter_head_false_eq_image (m : ℕ) :
    (goldenWords (m + 1)).filter (fun w => w.head? = some false)
      = (goldenWords m).image (List.cons false) := by
  ext w
  rw [Finset.mem_filter, Finset.mem_image, mem_goldenWords]
  constructor
  · rintro ⟨⟨hlen, hadm⟩, hhead⟩
    match w, hlen with
    | (b :: t), hlen =>
      have hb : b = false := by
        have : (b :: t).head? = some b := rfl
        rw [this] at hhead
        exact Option.some_injective _ hhead
      subst hb
      exact ⟨t, (mem_goldenWords m t).mpr ⟨by simpa using hlen, Admissible.tail hadm⟩, rfl⟩
  · rintro ⟨v, hv, rfl⟩
    obtain ⟨hlen, hadm⟩ := (mem_goldenWords m v).mp hv
    exact ⟨⟨by simp [hlen], admissible_false_cons hadm⟩, rfl⟩

theorem card_filter_head_false {n : ℕ} (hn : 0 < n) :
    ((goldenWords n).filter (fun w => w.head? = some false)).card = Nat.fib (n + 1) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  rw [filter_head_false_eq_image m,
    Finset.card_image_of_injective _ cons_false_injective, card_goldenWords]

/-- Admissible words ending with `false` are the admissible words of length one less, with a
`false` appended. -/
theorem filter_getLast_false_eq_image (m : ℕ) :
    (goldenWords (m + 1)).filter (fun w => w.getLast? = some false)
      = (goldenWords m).image (fun v => v ++ [false]) := by
  ext w
  rw [Finset.mem_filter, Finset.mem_image, mem_goldenWords]
  constructor
  · rintro ⟨⟨hlen, hadm⟩, hlast⟩
    have hne : w ≠ [] := by
      intro h
      rw [h] at hlen
      simp at hlen
    have hget : w.getLast hne = false := by
      have := List.getLast?_eq_some_getLast hne
      rw [hlast] at this
      exact (Option.some_injective _ this).symm
    refine ⟨w.dropLast, ?_, ?_⟩
    · rw [mem_goldenWords]
      refine ⟨by rw [List.length_dropLast, hlen]; simp, ?_⟩
      rw [List.dropLast_eq_take]
      exact hadm.take _
    · rw [← hget]
      exact List.dropLast_append_getLast hne
  · rintro ⟨v, hv, rfl⟩
    obtain ⟨hlen, hadm⟩ := (mem_goldenWords m v).mp hv
    refine ⟨⟨by simp [hlen], admissible_append_false hadm⟩, ?_⟩
    simp

theorem append_false_injective : Function.Injective (fun v : List Bool => v ++ [false]) := by
  intro u v h
  simpa using h

theorem card_filter_getLast_false {n : ℕ} (hn : 0 < n) :
    ((goldenWords n).filter (fun w => w.getLast? = some false)).card = Nat.fib (n + 1) := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  rw [filter_getLast_false_eq_image m,
    Finset.card_image_of_injective _ append_false_injective, card_goldenWords]

theorem card_filter_head_and_getLast_false {n : ℕ} (hn : 2 ≤ n) :
    ((goldenWords n).filter
      (fun w => w.head? = some false ∧ w.getLast? = some false)).card = Nat.fib n := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 2 := ⟨n - 2, by omega⟩
  have hset : (goldenWords (m + 2)).filter
      (fun w => w.head? = some false ∧ w.getLast? = some false)
      = ((goldenWords (m + 1)).filter (fun v => v.getLast? = some false)).image
          (List.cons false) := by
    ext w
    rw [Finset.mem_filter, Finset.mem_image, mem_goldenWords]
    constructor
    · rintro ⟨⟨hlen, hadm⟩, hhead, hlast⟩
      match w, hlen with
      | (b :: t), hlen =>
        have hb : b = false := by
          have hh : (b :: t).head? = some b := rfl
          rw [hh] at hhead
          exact Option.some_injective _ hhead
        subst hb
        have htlen : t.length = m + 1 := by simpa using hlen
        have htne : t ≠ [] := by
          intro h
          rw [h] at htlen
          simp at htlen
        refine ⟨t, ?_, rfl⟩
        rw [Finset.mem_filter, mem_goldenWords]
        refine ⟨⟨htlen, Admissible.tail hadm⟩, ?_⟩
        rwa [getLast?_cons_ne_nil htne] at hlast
    · rintro ⟨v, hv, rfl⟩
      rw [Finset.mem_filter, mem_goldenWords] at hv
      obtain ⟨⟨hlen, hadm⟩, hlast⟩ := hv
      have hvne : v ≠ [] := by
        intro h
        rw [h] at hlen
        simp at hlen
      refine ⟨⟨by simp [hlen], admissible_false_cons hadm⟩, rfl, ?_⟩
      rwa [getLast?_cons_ne_nil hvne]
  rw [hset, Finset.card_image_of_injective _ cons_false_injective,
    card_filter_getLast_false (n := m + 1) (by omega)]

/-- **The Lucas count of cyclically admissible words.** -/
theorem card_cyclicGoldenWords {n : ℕ} (hn : 0 < n) :
    (cyclicGoldenWords n).card = lucas n := by
  rcases Nat.lt_or_ge n 2 with hlt | hge
  · -- the single period-one word `[false]`
    have hn1 : n = 1 := by omega
    subst hn1
    decide
  · -- inclusion–exclusion between "starts with `false`" and "ends with `false`"
    have hor : cyclicGoldenWords n =
        (goldenWords n).filter (fun w => w.head? = some false ∨ w.getLast? = some false) := by
      ext w
      rw [cyclicGoldenWords, Finset.mem_filter, Finset.mem_filter]
      constructor
      · rintro ⟨hw, hcyc⟩
        refine ⟨hw, ?_⟩
        have hlen := ((mem_goldenWords n w).mp hw).1
        have hne : w ≠ [] := by
          intro h
          rw [h] at hlen
          simp at hlen
          omega
        obtain ⟨b, hb⟩ : ∃ b, w.head? = some b := by
          cases w with
          | nil => exact absurd rfl hne
          | cons a t => exact ⟨a, rfl⟩
        obtain ⟨c, hc⟩ : ∃ c, w.getLast? = some c :=
          ⟨w.getLast hne, List.getLast?_eq_some_getLast hne⟩
        cases b
        · exact Or.inl hb
        · cases c
          · exact Or.inr hc
          · exact absurd ⟨hb, hc⟩ hcyc
      · rintro ⟨hw, hor⟩
        refine ⟨hw, ?_⟩
        rintro ⟨hb, hc⟩
        rcases hor with h | h
        · rw [hb] at h; simp at h
        · rw [hc] at h; simp at h
    have hunion : (goldenWords n).filter
        (fun w => w.head? = some false ∨ w.getLast? = some false)
        = (goldenWords n).filter (fun w => w.head? = some false) ∪
          (goldenWords n).filter (fun w => w.getLast? = some false) := Finset.filter_or _ _ _
    have hinter : (goldenWords n).filter (fun w => w.head? = some false) ∩
        (goldenWords n).filter (fun w => w.getLast? = some false)
        = (goldenWords n).filter
          (fun w => w.head? = some false ∧ w.getLast? = some false) :=
      (Finset.filter_and _ _ _).symm
    have hIE := Finset.card_union_add_card_inter
      ((goldenWords n).filter (fun w => w.head? = some false))
      ((goldenWords n).filter (fun w => w.getLast? = some false))
    rw [hinter, card_filter_head_false hn, card_filter_getLast_false hn,
      card_filter_head_and_getLast_false hge] at hIE
    rw [hor, hunion]
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 2 := ⟨n - 2, by omega⟩
    have hlucas : lucas (m + 2) = Nat.fib (m + 3) + Nat.fib (m + 1) := lucas_succ_eq_fib (m + 1)
    have hfib : Nat.fib (m + 3) = Nat.fib (m + 1) + Nat.fib (m + 2) := Nat.fib_add_two
    have hnorm : Nat.fib (m + 2 + 1) = Nat.fib (m + 3) := rfl
    omega

/-! ## The census -/

/-- **The Lucas periodic census**: the golden-mean subshift has exactly `lucas n` points of
period `n`. -/
theorem ncard_periodicPoints_goldenMean {n : ℕ} (hn : 0 < n) :
    (periodicPoints n).ncard = lucas n := by
  rw [periodicPoints_eq_image hn, Set.InjOn.ncard_image (rep_injOn n),
    Set.ncard_coe_finset, card_cyclicGoldenWords hn]

/-! ## The full shift, for comparison -/

/-- All words of length `n`. -/
def allWords : ℕ → Finset (List Bool)
  | 0 => {[]}
  | (n + 1) => (allWords n).image (List.cons false) ∪ (allWords n).image (List.cons true)

theorem mem_allWords : ∀ (n : ℕ) (w : List Bool), w ∈ allWords n ↔ w.length = n
  | 0, w => by
      rw [allWords, Finset.mem_singleton]
      constructor
      · rintro rfl; rfl
      · exact fun h => List.length_eq_zero_iff.mp h
  | (n + 1), w => by
      rw [allWords, Finset.mem_union, Finset.mem_image, Finset.mem_image]
      constructor
      · rintro (⟨v, hv, rfl⟩ | ⟨v, hv, rfl⟩) <;>
          simp [(mem_allWords n v).mp hv]
      · intro hlen
        match w, hlen with
        | (b :: t), hlen =>
          have ht : t.length = n := by simpa using hlen
          cases b
          · exact Or.inl ⟨t, (mem_allWords n t).mpr ht, rfl⟩
          · exact Or.inr ⟨t, (mem_allWords n t).mpr ht, rfl⟩

theorem card_allWords : ∀ n : ℕ, (allWords n).card = 2 ^ n
  | 0 => rfl
  | (n + 1) => by
      have ih := card_allWords n
      have hdisj : Disjoint ((allWords n).image (List.cons false))
          ((allWords n).image (List.cons true)) := by
        rw [Finset.disjoint_left]
        rintro a ha hb
        obtain ⟨l, -, rfl⟩ := Finset.mem_image.mp ha
        obtain ⟨m, -, hm⟩ := Finset.mem_image.mp hb
        simp at hm
      have hinj : ∀ b : Bool, Function.Injective (List.cons b) := by
        intro b u v h
        simpa using h
      rw [allWords, Finset.card_union_of_disjoint hdisj,
        Finset.card_image_of_injective _ (hinj false),
        Finset.card_image_of_injective _ (hinj true), ih]
      ring

/-- The `n`-periodic points of the full shift. -/
def cantorPeriodicPoints (n : ℕ) : Set Cantor := {x | shift^[n] x = x}

theorem cantorPeriodicPoints_eq_image {n : ℕ} (hn : 0 < n) :
    cantorPeriodicPoints n = rep '' (allWords n : Set (List Bool)) := by
  ext x
  simp only [Set.mem_image, Finset.mem_coe, cantorPeriodicPoints, Set.mem_setOf_eq]
  constructor
  · intro hper
    exact ⟨prefixOf n x, (mem_allWords n _).mpr (length_prefixOf n x),
      rep_prefixOf_of_periodic hn hper⟩
  · rintro ⟨w, hw, rfl⟩
    have hlen := (mem_allWords n w).mp hw
    have := shift_iterate_rep w
    rwa [hlen] at this

theorem rep_injOn_allWords (n : ℕ) :
    Set.InjOn rep (allWords n : Set (List Bool)) := by
  intro v hv w hw h
  have hv' := (mem_allWords n v).mp (by simpa using hv)
  have hw' := (mem_allWords n w).mp (by simpa using hw)
  have := congrArg (prefixOf n) h
  rwa [prefixOf_rep hv', prefixOf_rep hw'] at this

/-- The full shift has `2 ^ n` points of period `n`. -/
theorem ncard_periodicPoints_cantor {n : ℕ} (hn : 0 < n) :
    (cantorPeriodicPoints n).ncard = 2 ^ n := by
  rw [cantorPeriodicPoints_eq_image hn, Set.InjOn.ncard_image (rep_injOn_allWords n),
    Set.ncard_coe_finset, card_allWords]

/-! ## The conjugacy obstruction at every period -/

/-- **Every period obstructs conjugacy.**  For each `n ≥ 1` the two systems have different
numbers of `n`-periodic points, so no shift-equivariant bijection can exist. -/
theorem no_shift_equiv_of_period {n : ℕ} (hn : 0 < n) :
    (periodicPoints n).ncard < (cantorPeriodicPoints n).ncard := by
  rw [ncard_periodicPoints_goldenMean hn, ncard_periodicPoints_cantor hn]
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  exact lucas_lt_two_pow m

end FractalTruthCompactness